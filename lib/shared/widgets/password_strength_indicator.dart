import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../core/services/security_service.dart';

/// Indicador de força de senha (OWASP M4)
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final securityService = SecurityService();
    final strength = securityService.validatePasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getColor(strength, 0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getColor(strength, 1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _getColor(strength, 2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              _getIcon(strength),
              size: 14,
              color: _getTextColor(strength),
            ),
            const SizedBox(width: 4),
            Text(
              _getLabel(strength),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getTextColor(strength),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        if (strength == PasswordStrength.weak) ...[
          const SizedBox(height: 4),
          const Text(
            'Use letras, números e símbolos',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );
  }

  Color _getColor(PasswordStrength strength, int index) {
    switch (strength) {
      case PasswordStrength.weak:
        return index == 0 ? AppTheme.danger : AppTheme.borderDark;
      case PasswordStrength.medium:
        return index <= 1 ? AppTheme.warning : AppTheme.borderDark;
      case PasswordStrength.strong:
        return AppTheme.success;
    }
  }

  Color _getTextColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppTheme.danger;
      case PasswordStrength.medium:
        return AppTheme.warning;
      case PasswordStrength.strong:
        return AppTheme.success;
    }
  }

  IconData _getIcon(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Icons.warning_rounded;
      case PasswordStrength.medium:
        return Icons.check_circle_outline;
      case PasswordStrength.strong:
        return Icons.check_circle;
    }
  }

  String _getLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Senha fraca';
      case PasswordStrength.medium:
        return 'Senha média';
      case PasswordStrength.strong:
        return 'Senha forte';
    }
  }
}
