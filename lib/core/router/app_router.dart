import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
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
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
