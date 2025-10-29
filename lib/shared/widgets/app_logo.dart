import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool animated;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pattern
          CustomPaint(
            size: Size(size, size),
            painter: _LogoPatternPainter(),
          ),
          // Main icon
          Icon(
            Icons.insights,
            color: Colors.white,
            size: size * 0.5,
          ),
        ],
      ),
    );

    if (animated) {
      logo = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: logo,
      );
    }

    if (!showText) {
      return logo;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(height: size * 0.2),
        Text(
          'DoPVision',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: size * 0.05),
        Text(
          'Performance em Vendas',
          style: TextStyle(
            fontSize: size * 0.15,
            color: AppTheme.textMuted,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LogoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        radius * i / 3,
        paint,
      );
    }

    // Draw cross lines
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
