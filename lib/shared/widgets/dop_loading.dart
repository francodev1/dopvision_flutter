import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Loading indicator customizado estilo Apple
class DopLoading extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? message;

  const DopLoading({
    super.key,
    this.size,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading overlay que cobre a tela inteira
class DopLoadingOverlay extends StatelessWidget {
  final String? message;

  const DopLoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgDark.withValues(alpha: 0.9),
      child: DopLoading(message: message),
    );
  }
}
