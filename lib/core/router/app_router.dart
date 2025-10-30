import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/privacy_policy_screen.dart';
import '../../features/auth/presentation/terms_of_service_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../services/auth_service.dart';

// Transições customizadas estilo Apple
Page<dynamic> _buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
  bool fadeTransition = false,
}) {
  if (fadeTransition) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeOut).animate(animation),
          child: child,
        );
      },
    );
  }

  // Transição slide estilo iOS (da direita para esquerda)
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: tween.animate(curvedAnimation),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Enquanto carrega auth, mostra splash
      if (authState.isLoading) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      final isLoggedIn = authState.value != null;
      final currentPath = state.matchedLocation;
      final isAuthScreen = currentPath == '/login' || currentPath == '/register';
      final isSplash = currentPath == '/splash';

      // Se terminou de carregar e está na splash, redireciona
      if (isSplash && !authState.isLoading) {
        return isLoggedIn ? '/dashboard' : '/login';
      }

      // Se não está logado e não está em tela de auth, vai para login
      if (!isLoggedIn && !isAuthScreen) {
        return '/login';
      }

      // Se está logado e está em tela de auth, vai para dashboard
      if (isLoggedIn && isAuthScreen) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const SplashScreen(),
          state: state,
          fadeTransition: true,
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const LoginScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const RegisterScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const ForgotPasswordScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/privacy-policy',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const PrivacyPolicyScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/terms-of-service',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const TermsOfServiceScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          child: const DashboardScreen(),
          state: state,
          fadeTransition: true, // Dashboard com fade suave
        ),
      ),
    ],
  );
});
