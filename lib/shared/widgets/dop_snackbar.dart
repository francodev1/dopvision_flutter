import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DopSnackbarType { success, error, warning, info }

/// Snackbar customizado estilo Apple
class DopSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    DopSnackbarType type = DopSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Remove snackbar anterior se existir
    messenger.clearSnackBars();

    final (color, icon) = _getColorAndIcon(type);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusMedium,
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: onTap != null
            ? SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: onTap,
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: DopSnackbarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: DopSnackbarType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: DopSnackbarType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: DopSnackbarType.info);
  }

  static (Color, IconData) _getColorAndIcon(DopSnackbarType type) {
    switch (type) {
      case DopSnackbarType.success:
        return (AppTheme.success, Icons.check_circle_outline);
      case DopSnackbarType.error:
        return (AppTheme.danger, Icons.error_outline);
      case DopSnackbarType.warning:
        return (AppTheme.warning, Icons.warning_amber_outlined);
      case DopSnackbarType.info:
        return (AppTheme.primary, Icons.info_outline);
    }
  }
}
