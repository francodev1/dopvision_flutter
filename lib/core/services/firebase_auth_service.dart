// lib/core/services/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exceptions/app_exception.dart';
import '../utils/logger.dart';
import '../utils/error_handler.dart';

/// 🔐 Firebase Auth Service
/// 
/// Serviço de autenticação com Firebase.
/// Gerencia login, registro, recuperação de senha e estado de autenticação.
class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  /// Stream do usuário atual
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuário atual (síncrono)
  User? get currentUser => _auth.currentUser;

  /// Verifica se está autenticado
  bool get isAuthenticated => currentUser != null;

  /// UID do usuário atual
  String? get userId => currentUser?.uid;

  // ============================================
  // 📧 Login com Email/Senha
  // ============================================

  /// Faz login com email e senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('🔐 Tentando login: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      AppLogger.info('✅ Login bem-sucedido: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro no login', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado no login', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 📝 Registro
  // ============================================

  /// Registra novo usuário com email e senha
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AppLogger.info('📝 Criando novo usuário: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Atualiza o nome se fornecido
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }

      // Envia email de verificação
      await credential.user?.sendEmailVerification();

      AppLogger.info('✅ Usuário criado: ${credential.user?.email}');
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro ao criar usuário', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado ao criar usuário', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🔑 Recuperação de Senha
  // ============================================

  /// Envia email de recuperação de senha
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      AppLogger.info('📧 Enviando email de recuperação: $email');

      await _auth.sendPasswordResetEmail(email: email.trim());

      AppLogger.info('✅ Email de recuperação enviado');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro ao enviar email de recuperação', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado ao enviar email', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🚪 Logout
  // ============================================

  /// Faz logout do usuário
  Future<void> signOut() async {
    try {
      AppLogger.info('🚪 Fazendo logout');
      await _auth.signOut();
      AppLogger.info('✅ Logout realizado');
    } catch (e, stack) {
      AppLogger.error('❌ Erro ao fazer logout', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 📧 Verificação de Email
  // ============================================

  /// Verifica se o email foi verificado
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Envia email de verificação
  Future<void> sendEmailVerification() async {
    try {
      AppLogger.info('📧 Enviando email de verificação');
      await currentUser?.sendEmailVerification();
      AppLogger.info('✅ Email de verificação enviado');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro ao enviar email de verificação', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Recarrega dados do usuário
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e, stack) {
      AppLogger.error('❌ Erro ao recarregar usuário', e, stack);
    }
  }

  // ============================================
  // 👤 Atualização de Perfil
  // ============================================

  /// Atualiza nome do usuário
  Future<void> updateDisplayName(String displayName) async {
    try {
      AppLogger.info('👤 Atualizando nome: $displayName');
      await currentUser?.updateDisplayName(displayName);
      await reloadUser();
      AppLogger.info('✅ Nome atualizado');
    } catch (e, stack) {
      AppLogger.error('❌ Erro ao atualizar nome', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Atualiza foto do usuário
  Future<void> updatePhotoURL(String photoURL) async {
    try {
      AppLogger.info('📸 Atualizando foto');
      await currentUser?.updatePhotoURL(photoURL);
      await reloadUser();
      AppLogger.info('✅ Foto atualizada');
    } catch (e, stack) {
      AppLogger.error('❌ Erro ao atualizar foto', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Atualiza email do usuário
  Future<void> updateEmail(String newEmail) async {
    try {
      AppLogger.info('📧 Atualizando email');
      await currentUser?.verifyBeforeUpdateEmail(newEmail);
      AppLogger.info('✅ Email de verificação enviado');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro ao atualizar email', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  /// Atualiza senha do usuário
  Future<void> updatePassword(String newPassword) async {
    try {
      AppLogger.info('🔑 Atualizando senha');
      await currentUser?.updatePassword(newPassword);
      AppLogger.info('✅ Senha atualizada');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro ao atualizar senha', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🗑️ Exclusão de Conta
  // ============================================

  /// Deleta a conta do usuário
  Future<void> deleteAccount() async {
    try {
      AppLogger.warning('🗑️ Deletando conta do usuário');
      await currentUser?.delete();
      AppLogger.info('✅ Conta deletada');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro ao deletar conta', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🔄 Reautenticação
  // ============================================

  /// Reautentica o usuário (necessário para operações sensíveis)
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw AuthException.notAuthenticated();
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      AppLogger.info('✅ Reautenticação bem-sucedida');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro na reautenticação', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado na reautenticação', e, stack);
      throw ErrorHandler.handle(e);
    }
  }

  // ============================================
  // 🔗 Link de Contas
  // ============================================

  /// Vincula conta com email/senha
  Future<UserCredential> linkWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential = await currentUser!.linkWithCredential(credential);
      AppLogger.info('✅ Conta vinculada com sucesso');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('❌ Erro ao vincular conta', e);
      throw ErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ Erro inesperado', e, stack);
      throw ErrorHandler.handle(e);
    }
  }
}

// ============================================
// 🎯 Riverpod Providers
// ============================================

/// Provider do FirebaseAuthService
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider do estado de autenticação
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

/// Provider do usuário atual
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

/// Provider para verificar se está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
