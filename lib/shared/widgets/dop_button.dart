import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DopButtonType { primary, secondary, outline, ghost, danger }
enum DopButtonSize { small, medium, large }

/// Botão customizado estilo Apple/DoPVision
class DopButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final DopButtonType type;
  final DopButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool haptic;

  const DopButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = DopButtonType.primary,
    this.size = DopButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.haptic = true,
  });

  @override
  State<DopButton> createState() => _DopButtonState();
}

class _DopButtonState extends State<DopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null) return AppTheme.textMuted.withValues(alpha: 0.3);
    
    switch (widget.type) {
      case DopButtonType.primary:
        return _isPressed ? AppTheme.primaryDark : AppTheme.primary;
      case DopButtonType.secondary:
        return _isPressed
            ? AppTheme.secondary.withValues(alpha: 0.9)
            : AppTheme.secondary;
      case DopButtonType.outline:
        return _isPressed
            ? AppTheme.cardDarkHover
            : Colors.transparent;
      case DopButtonType.ghost:
        return _isPressed
            ? AppTheme.cardDarkHover
            : Colors.transparent;
      case DopButtonType.danger:
        return _isPressed
            ? AppTheme.danger.withValues(alpha: 0.9)
            : AppTheme.danger;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null) return AppTheme.textMuted;
    
    switch (widget.type) {
      case DopButtonType.primary:
      case DopButtonType.secondary:
      case DopButtonType.danger:
        return Colors.white;
      case DopButtonType.outline:
      case DopButtonType.ghost:
        return AppTheme.textDark;
    }
  }

  BorderSide? _getBorder() {
    if (widget.type == DopButtonType.outline) {
      return BorderSide(
        color: widget.onPressed == null
            ? AppTheme.borderDark
            : AppTheme.borderLight,
        width: 1.5,
      );
    }
    return null;
  }

  double _getHeight() {
    switch (widget.size) {
      case DopButtonSize.small:
        return 36;
      case DopButtonSize.medium:
        return 48;
      case DopButtonSize.large:
        return 56;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case DopButtonSize.small:
        return 13;
      case DopButtonSize.medium:
        return 15;
      case DopButtonSize.large:
        return 17;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case DopButtonSize.small:
        return 16;
      case DopButtonSize.medium:
        return 20;
      case DopButtonSize.large:
        return 22;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed != null && !widget.isLoading
          ? () {
              if (widget.haptic) {
                // HapticFeedback.lightImpact();
              }
              widget.onPressed!();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppTheme.animationFast,
          curve: AppTheme.animationCurve,
          height: _getHeight(),
          width: widget.fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.size == DopButtonSize.small ? 16 : 24,
          ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: AppTheme.radiusMedium,
            border: _getBorder() != null ? Border.fromBorderSide(_getBorder()!) : null,
            boxShadow: widget.type == DopButtonType.primary && widget.onPressed != null
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                  ),
                )
              else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: _getIconSize(),
                  color: _getTextColor(),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
