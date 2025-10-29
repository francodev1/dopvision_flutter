import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'token_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(tokenServiceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TokenService _tokenService;

  AuthService(this._tokenService);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;

  // Login com salvamento de token
  Future<UserCredential> signIn(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Salva tokens
      final token = await credential.user?.getIdToken();
      if (token != null) {
        await _tokenService.saveTokens(
          accessToken: token,
          refreshToken: token, // Firebase gerencia refresh automaticamente
          rememberMe: rememberMe,
        );
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Registro
  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout com limpeza de tokens
  Future<void> signOut() async {
    await _tokenService.clearTokens();
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
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
