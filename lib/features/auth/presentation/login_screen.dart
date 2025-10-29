import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/hybrid_button.dart';
import '../../../shared/widgets/hybrid_text_field.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppTheme.animationSlow,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: AppTheme.animationCurveApple,
      ),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            _emailController.text.trim(),
            _passwordController.text,
            rememberMe: _rememberMe,
          );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle, color: AppTheme.danger, size: 20),
                SizedBox(width: 8),
                Text('Erro no Login'),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(e.toString()),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          const Center(
                            child: AppLogo(size: 80, animated: true),
                          ),
                          const SizedBox(height: 24),

                          // Title
                          const Text(
                            '👁️ Bem-vindo',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            'Faça login para acessar sua conta',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textMuted,
                              letterSpacing: -0.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Card Container
                          GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email
                                HybridTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  placeholder: 'seu@email.com',
                                  prefixIcon: CupertinoIcons.mail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),

                                // Password
                                HybridTextField(
                                  controller: _passwordController,
                                  label: 'Senha',
                                  placeholder: '••••••••',
                                  prefixIcon: CupertinoIcons.lock,
                                  obscureText: _obscurePassword,
                                  suffix: CupertinoButton(
                                    padding: const EdgeInsets.only(right: 12),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    child: Icon(
                                      _obscurePassword
                                          ? CupertinoIcons.eye
                                          : CupertinoIcons.eye_slash,
                                      size: 20,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => context.push('/forgot-password'),
                                    child: const Text(
                                      'Esqueceu a senha?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.primary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Remember Me Checkbox
                                Row(
                                  children: [
                                    CupertinoCheckbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() => _rememberMe = value ?? false);
                                      },
                                      activeColor: AppTheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Lembrar-me por 30 dias',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textMuted,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Login Button
                                HybridButton(
                                  text: 'Entrar',
                                  onPressed: _handleLogin,
                                  isLoading: _isLoading,
                                  icon: CupertinoIcons.arrow_right,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Register Link
                          CupertinoButton(
                            onPressed: () => context.go('/register'),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Não tem conta? ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.textMuted,
                                  letterSpacing: -0.3,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Criar conta',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
