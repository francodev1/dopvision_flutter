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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

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

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      
      if (mounted) {
        setState(() => _emailSent = true);
        _showSuccess(
          'Email enviado!',
          'Verifique seu email para instruções de redefinição de senha.',
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _translateAuthError(e.toString());
        _showError(errorMessage);
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
            Icon(CupertinoIcons.exclamationmark_triangle, color: AppTheme.danger, size: 20),
            SizedBox(width: 8),
            Text('Erro'),
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

  void _showSuccess(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill, color: AppTheme.success, size: 20),
            const SizedBox(width: 8),
            Text(title),
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
            onPressed: () {
              Navigator.pop(context);
              if (_emailSent) {
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  String _translateAuthError(String error) {
    if (error.contains('user-not-found')) {
      return 'Email não encontrado. Verifique ou crie uma nova conta.';
    }
    if (error.contains('invalid-email')) {
      return 'Email inválido. Verifique o formato.';
    }
    if (error.contains('too-many-requests')) {
      return 'Muitas tentativas. Tente novamente mais tarde.';
    }
    if (error.contains('network-request-failed')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    
    if (error.contains('[firebase_auth')) {
      final start = error.indexOf('] ') + 2;
      if (start > 1 && start < error.length) {
        final message = error.substring(start);
        return 'Erro: $message';
      }
    }
    
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: CupertinoButton(
                  onPressed: () => context.pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.back, color: AppTheme.textDark),
                      SizedBox(width: 4),
                      Text(
                        'Voltar',
                        style: TextStyle(color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_emailSent) ...[
                            // Icon
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.glowShadow(AppTheme.primary),
                                ),
                                child: const Icon(
                                  CupertinoIcons.lock_rotation,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            const Text(
                              'Esqueceu a senha?',
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
                              'Digite seu email e enviaremos instruções para redefinir sua senha',
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
                                  const SizedBox(height: 24),

                                  // Send Button
                                  HybridButton(
                                    text: 'Enviar instruções',
                                    onPressed: _handleResetPassword,
                                    isLoading: _isLoading,
                                    icon: CupertinoIcons.paperplane,
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Success State
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.success.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  CupertinoIcons.checkmark_alt,
                                  color: AppTheme.success,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            const Text(
                              'Email enviado!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Enviamos um email para ${_emailController.text.trim()} com instruções para redefinir sua senha.',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textMuted,
                                letterSpacing: -0.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // Back to Login Button
                            HybridButton(
                              text: 'Voltar para o login',
                              onPressed: () => context.go('/login'),
                              icon: CupertinoIcons.arrow_left,
                              isPrimary: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
