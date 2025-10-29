import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool showPattern;

  const GradientBackground({
    super.key,
    required this.child,
    this.showPattern = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: showPattern
          ? Stack(
              children: [
                // Padrão de fundo opcional
                child,
              ],
            )
          : child,
    );
  }
}
