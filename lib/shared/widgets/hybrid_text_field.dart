import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HybridTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const HybridTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  State<HybridTextField> createState() => _HybridTextFieldState();
}

class _HybridTextFieldState extends State<HybridTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: AppTheme.animationFast,
          curve: AppTheme.animationCurveApple,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isFocused
                  ? AppTheme.primary
                  : AppTheme.borderDark,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: CupertinoTextField(
            controller: widget.controller,
            placeholder: widget.placeholder,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
              letterSpacing: -0.4,
            ),
            placeholderStyle: const TextStyle(
              fontSize: 16,
              color: AppTheme.textMuted,
              letterSpacing: -0.4,
            ),
            prefix: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: AppTheme.textMuted,
                    ),
                  )
                : null,
            suffix: widget.suffix,
            onTap: () => setState(() => _isFocused = true),
            onEditingComplete: () => setState(() => _isFocused = false),
            onSubmitted: (_) => setState(() => _isFocused = false),
          ),
        ),
      ],
    );
  }
}
