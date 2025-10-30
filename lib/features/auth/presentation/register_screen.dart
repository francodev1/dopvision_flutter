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
import '../../../shared/widgets/password_strength_indicator.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

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

    // Listener para atualizar o indicador de força de senha
    _passwordController.addListener(() {
      setState(() {}); // Atualiza o widget
    });

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validar email
    if (email.isEmpty) {
      _showError('Por favor, insira seu email');
      return;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      _showError('Email inválido');
      return;
    }

    // Validar senha
    if (password.isEmpty) {
      _showError('Por favor, insira uma senha');
      return;
    }

    if (password.length < 8) {
      _showError('A senha deve ter no mínimo 8 caracteres');
      return;
    }

    // Validar confirmação de senha
    if (confirmPassword.isEmpty) {
      _showError('Por favor, confirme sua senha');
      return;
    }

    if (password != confirmPassword) {
      _showError('As senhas não coincidem');
      return;
    }

    // Validar termos
    if (!_acceptTerms) {
      _showError('Você deve aceitar os termos de uso e política de privacidade');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).register(email, password);

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle,
                color: AppTheme.danger, size: 20),
            SizedBox(width: 8),
            Text('Erro no Registro'),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
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
                            '✨ Criar Conta',
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
                            'Preencha os dados para começar',
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
                                
                                // Password Strength Indicator
                                PasswordStrengthIndicator(
                                  password: _passwordController.text,
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password
                                HybridTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar Senha',
                                  placeholder: '••••••••',
                                  prefixIcon: CupertinoIcons.lock_shield,
                                  obscureText: _obscureConfirmPassword,
                                  suffix: CupertinoButton(
                                    padding: const EdgeInsets.only(right: 12),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    child: Icon(
                                      _obscureConfirmPassword
                                          ? CupertinoIcons.eye
                                          : CupertinoIcons.eye_slash,
                                      size: 20,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Terms Checkbox
                                Row(
                                  children: [
                                    CupertinoCheckbox(
                                      value: _acceptTerms,
                                      onChanged: (value) {
                                        setState(() => _acceptTerms = value ?? false);
                                      },
                                      activeColor: AppTheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _acceptTerms = !_acceptTerms);
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'Aceito os ',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textMuted,
                                              letterSpacing: -0.2,
                                            ),
                                            children: [
                                              WidgetSpan(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => const TermsOfServiceScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Termos de Uso',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: AppTheme.primary,
                                                      fontWeight: FontWeight.w600,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const TextSpan(text: ' e '),
                                              WidgetSpan(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => const PrivacyPolicyScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Política de Privacidade',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: AppTheme.primary,
                                                      fontWeight: FontWeight.w600,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Register Button
                                HybridButton(
                                  text: 'Criar Conta',
                                  onPressed: _handleRegister,
                                  isLoading: _isLoading,
                                  icon: CupertinoIcons.checkmark_alt,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login Link
                          CupertinoButton(
                            onPressed: () => context.go('/login'),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Já tem conta? ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.textMuted,
                                  letterSpacing: -0.3,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Fazer login',
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
