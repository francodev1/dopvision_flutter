import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DopCardType { normal, elevated, outline, glass }

/// Card customizado estilo Apple/DoPVision com glassmorphism
class DopCard extends StatefulWidget {
  final Widget child;
  final DopCardType type;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool showShadow;
  final bool animated;
  final Color? backgroundColor;
  final Gradient? gradient;

  const DopCard({
    super.key,
    required this.child,
    this.type = DopCardType.glass,
    this.padding,
    this.onTap,
    this.showShadow = false,
    this.animated = true,
    this.backgroundColor,
    this.gradient,
  });

  @override
  State<DopCard> createState() => _DopCardState();
}

class _DopCardState extends State<DopCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.animated) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null && widget.animated) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null && widget.animated) {
      _controller.reverse();
    }
  }

  BoxDecoration _getDecoration() {
    Color? bgColor;
    Gradient? gradient;
    List<BoxShadow>? shadows;
    BorderSide? border;

    switch (widget.type) {
      case DopCardType.normal:
        bgColor = widget.backgroundColor ?? AppTheme.cardDark;
        break;
      case DopCardType.elevated:
        bgColor = widget.backgroundColor ?? AppTheme.cardDarkHover;
        shadows = AppTheme.cardShadow;
        break;
      case DopCardType.outline:
        bgColor = Colors.transparent;
        border = const BorderSide(color: AppTheme.borderDark, width: 1);
        break;
      case DopCardType.glass:
        gradient = widget.gradient ?? AppTheme.cardGradient;
        border = const BorderSide(color: AppTheme.borderDark, width: 1);
        if (widget.showShadow) {
          shadows = AppTheme.cardShadow;
        }
        break;
    }

    return BoxDecoration(
      color: gradient == null ? bgColor : null,
      gradient: gradient,
      borderRadius: AppTheme.radiusMedium,
      border: border != null ? Border.fromBorderSide(border) : null,
      boxShadow: shadows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: _getDecoration(),
      child: widget.child,
    );

    if (widget.onTap == null) {
      return cardContent;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: widget.animated
          ? ScaleTransition(
              scale: _scaleAnimation,
              child: cardContent,
            )
          : cardContent,
    );
  }
}
