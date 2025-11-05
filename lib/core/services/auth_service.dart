import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'token_service.dart';
import 'security_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(tokenServiceProvider),
    SecurityService(),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TokenService _tokenService;
  final SecurityService _securityService;
  final Logger _logger = Logger();

  AuthService(this._tokenService, this._securityService);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;

  // Login com salvamento de token e criação de documento se necessário
  Future<UserCredential> signIn(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      // OWASP M4: Rate limiting para prevenir brute force
      if (!_securityService.checkRateLimit('login_$email', maxAttempts: 5, window: const Duration(minutes: 5))) {
        _securityService.auditLog('LOGIN_BLOCKED', metadata: {'email': email, 'reason': 'rate_limit'});
        throw 'Muitas tentativas de login. Aguarde 5 minutos.';
      }

      // OWASP M7: Sanitiza input
      final sanitizedEmail = _securityService.sanitizeInput(email.trim().toLowerCase());
      
      // OWASP M7: Valida formato de email
      if (!_securityService.isValidEmail(sanitizedEmail)) {
        throw 'Email inválido';
      }

      // OWASP M7: Detecta SQL Injection (paranoia, mas bom ter)
      if (_securityService.containsSQLInjection(sanitizedEmail) || 
          _securityService.containsSQLInjection(password)) {
        _securityService.auditLog('SQL_INJECTION_ATTEMPT', metadata: {'email': email});
        throw 'Dados inválidos detectados';
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );
      
      // Limpa rate limit após login bem-sucedido
      _securityService.clearRateLimit('login_$sanitizedEmail');

      // LGPD: Audit log de acesso
      _securityService.auditLog('LOGIN_SUCCESS', metadata: {
        'userId': credential.user?.uid,
        'email': sanitizedEmail,
      });
      
      // Salva tokens
      final token = await credential.user?.getIdToken();
      if (token != null) {
        await _tokenService.saveTokens(
          accessToken: token,
          refreshToken: token, // Firebase gerencia refresh automaticamente
          rememberMe: rememberMe,
        );
      }

      // Garante que o documento do usuário existe no Firestore
      if (credential.user != null) {
        await _ensureUserDocument(credential.user!);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      // LGPD: Audit log de falha de login
      _securityService.auditLog('LOGIN_FAILED', metadata: {
        'email': email,
        'error': e.code,
      });
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no login', error: e);
      rethrow;
    }
  }

  // Registro com criação de documento
  Future<UserCredential> register(String email, String password) async {
    try {
      // OWASP M7: Sanitiza input
      final sanitizedEmail = _securityService.sanitizeInput(email.trim().toLowerCase());
      
      // OWASP M7: Valida formato de email
      if (!_securityService.isValidEmail(sanitizedEmail)) {
        throw 'Email inválido';
      }

      // OWASP M4: Valida força da senha
      final passwordStrength = _securityService.validatePasswordStrength(password);
      if (passwordStrength == PasswordStrength.weak) {
        throw 'Senha muito fraca. Use no mínimo 8 caracteres com letras, números e símbolos.';
      }

      // OWASP M7: Detecta SQL Injection
      if (_securityService.containsSQLInjection(sanitizedEmail) || 
          _securityService.containsSQLInjection(password)) {
        _securityService.auditLog('SQL_INJECTION_ATTEMPT', metadata: {'email': email});
        throw 'Dados inválidos detectados';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      // LGPD: Audit log de registro
      _securityService.auditLog('REGISTER_SUCCESS', metadata: {
        'userId': credential.user?.uid,
        'email': sanitizedEmail,
      });

      // Cria o documento do usuário no Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      // LGPD: Audit log de falha de registro
      _securityService.auditLog('REGISTER_FAILED', metadata: {
        'email': email,
        'error': e.code,
      });
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Erro inesperado no registro', error: e);
      rethrow;
    }
  }

  // Cria ou atualiza o documento do usuário no Firestore
  Future<void> _ensureUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Documento não existe, criar
        _logger.i('Criando documento do usuário: ${user.uid}');
        await _createUserDocument(user);
      } else {
        // Documento existe, atualizar updatedAt
        _logger.i('Documento do usuário já existe: ${user.uid}');
        await userDoc.update({
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e, st) {
      _logger.e('Erro ao garantir documento do usuário', error: e, stackTrace: st);
      // Não falha o login se não conseguir criar/atualizar documento
    }
  }

  // Cria o documento inicial do usuário
  Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first ?? 'Usuário',
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
      _logger.i('Documento do usuário criado com sucesso: ${user.uid}');
    } catch (e, st) {
      _logger.e('Erro ao criar documento do usuário', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Logout com limpeza de tokens
  Future<void> signOut() async {
    try {
      final userId = _auth.currentUser?.uid;
      
      // LGPD: Audit log de logout
      _securityService.auditLog('LOGOUT', metadata: {
        'userId': userId,
      });

      await _tokenService.clearTokens();
      await _auth.signOut();
    } catch (e, st) {
      _logger.e('Erro no logout', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Reset password - sends password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // OWASP M7: Sanitiza input
      final sanitizedEmail = _securityService.sanitizeInput(email.trim().toLowerCase());
      
      // OWASP M7: Valida formato de email
      if (!_securityService.isValidEmail(sanitizedEmail)) {
        throw 'Email inválido';
      }

      await _auth.sendPasswordResetEmail(email: sanitizedEmail);
      
      // LGPD: Audit log
      _securityService.auditLog('PASSWORD_RESET_REQUESTED', metadata: {
        'email': sanitizedEmail,
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Alias para compatibilidade com código existente
  Future<void> resetPassword(String email) async {
    return sendPasswordResetEmail(email);
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return e.message ?? 'Erro de autenticação';
    }
  }
}
