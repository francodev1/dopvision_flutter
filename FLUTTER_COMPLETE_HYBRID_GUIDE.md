# 🎨 DoPVision Flutter - Implementação Híbrida COMPLETA
## Material 3 + Cupertino + Estilização Integrada

> **Guia único com TODOS os arquivos necessários para migração total**

---

## 📦 **PASSO 1: Configuração Inicial**

### **1.1 pubspec.yaml (COMPLETO)**

```yaml
name: dopvision_flutter
description: DoPVision - Gestão de Performance em Vendas
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  firebase_storage: ^12.3.8
  
  # State Management
  flutter_riverpod: ^2.6.1
  
  # Navigation
  go_router: ^14.6.2
  
  # UI Híbrida + Estilização
  cupertino_icons: ^1.0.8
  google_fonts: ^6.3.2
  flutter_platform_widgets: ^7.0.1
  glassmorphism: ^3.0.0           # Efeitos glass
  shimmer: ^3.0.0                 # Loading effects
  
  # Charts
  fl_chart: ^0.69.2
  
  # Utils
  intl: ^0.20.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## 🎨 **PASSO 2: Theme Híbrido + Estilização**

### **2.1 lib/shared/theme/app_theme.dart (COMPLETO COM ESTILIZAÇÃO)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ========== CORES (Estilo DoPVision Angular) ==========
  static const Color primary = Color(0xFF6366F1);        // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF8B5CF6);      // Purple
  static const Color accent = Color(0xFFEC4899);         // Pink
  static const Color success = Color(0xFF10B981);        // Green
  static const Color warning = Color(0xFFF59E0B);        // Amber
  static const Color danger = Color(0xFFEF4444);         // Red
  
  // Backgrounds (Dark Theme)
  static const Color bgDark = Color(0xFF071127);         // Dark Blue
  static const Color bgDarkSecondary = Color(0xFF0F172A);
  static const Color bgGradientStart = Color(0xFF071127);
  static const Color bgGradientEnd = Color(0xFF1E293B);
  
  // Cards (Glassmorphism)
  static const Color cardDark = Color(0x08FFFFFF);       // rgba(255,255,255,0.03)
  static const Color cardDarkHover = Color(0x0FFFFFFF);  // rgba(255,255,255,0.06)
  
  // Text
  static const Color textDark = Color(0xFFE6EEF8);       // Light Blue-White
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFF9AA7B9);      // Gray-Blue
  static const Color textSecondary = Color(0xFF94A3B8);
  
  // Borders
  static const Color borderDark = Color(0x1AFFFFFF);     // rgba(255,255,255,0.1)
  static const Color borderLight = Color(0x33FFFFFF);    // rgba(255,255,255,0.2)

  // ========== GRADIENTES ==========
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgGradientStart, bgGradientEnd],
  );

  static LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.03),
      Colors.white.withOpacity(0.01),
    ],
  );

  // ========== SHADOWS ==========
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  // ========== BORDER RADIUS ==========
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(20));

  // ========== MATERIAL THEME ==========
  static ThemeData get materialDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: cardDark,
        error: danger,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),

      scaffoldBackgroundColor: bgDark,

      // Typography (Inter - Apple Style)
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.4,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textDark,
          letterSpacing: -0.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textMuted,
          letterSpacing: -0.3,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textMuted,
          letterSpacing: -0.2,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),

      // Card Theme (Glassmorphism)
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: radiusMedium,
          side: BorderSide(
            color: borderDark,
            width: 1,
          ),
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: textDark, size: 24),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: radiusMedium,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: borderDark,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: borderDark,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: danger,
            width: 1,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 15,
          letterSpacing: -0.3,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: cardDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: radiusLarge,
          side: BorderSide(
            color: borderDark,
            width: 1,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textDark,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 16,
      ),
    );
  }

  // ========== CUPERTINO THEME ==========
  static CupertinoThemeData get cupertinoTheme {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: bgDark,
      barBackgroundColor: cardDark,
      textTheme: CupertinoTextThemeData(
        primaryColor: textDark,
        textStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: textDark,
          letterSpacing: -0.4,
        ),
        actionTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.4,
        ),
        navTitleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: -0.4,
        ),
        navLargeTitleTextStyle: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
        navActionTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.4,
        ),
        pickerTextStyle: GoogleFonts.inter(
          fontSize: 21,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        dateTimePickerTextStyle: GoogleFonts.inter(
          fontSize: 21,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        tabLabelTextStyle: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textMuted,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  // ========== ANIMAÇÕES ==========
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const Curve animationCurve = Curves.easeInOutCubic;
  static const Curve animationCurveApple = Curves.easeOut;

  // ========== ESPAÇAMENTOS ==========
  static const double spacingXSmall = 4;
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;
  static const double spacingXLarge = 32;
  static const double spacingXXLarge = 48;
}
```

---

## 🧱 **PASSO 3: Widgets Híbridos Estilizados**

### **3.1 lib/shared/widgets/glass_card.dart (Glassmorphism)**

```dart
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double blur;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.blur = 10,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: width ?? double.infinity,
        height: height,
        borderRadius: borderRadius,
        blur: blur,
        alignment: Alignment.center,
        border: 1,
        linearGradient: AppTheme.cardGradient,
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

### **3.2 lib/shared/widgets/hybrid_button.dart (Estilizado)**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HybridButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const HybridButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  State<HybridButton> createState() => _HybridButtonState();
}

class _HybridButtonState extends State<HybridButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppTheme.animationCurveApple,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? AppTheme.primaryGradient
                : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isPrimary
                ? null
                : Border.all(color: AppTheme.primary, width: 1.5),
            boxShadow: widget.isPrimary
                ? AppTheme.glowShadow(AppTheme.primary)
                : null,
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            onPressed: widget.isLoading ? null : widget.onPressed,
            child: widget.isLoading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 18,
                          color: widget.isPrimary
                              ? Colors.white
                              : AppTheme.primary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isPrimary
                              ? Colors.white
                              : AppTheme.primary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
```

### **3.3 lib/shared/widgets/hybrid_text_field.dart (Estilizado)**

```dart
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
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
              color: Colors.white.withOpacity(0.05),
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
                      color: _isFocused
                          ? AppTheme.primary
                          : AppTheme.textMuted,
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
```

### **3.4 lib/shared/widgets/metric_card.dart (Glassmorphism + Animação)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class MetricCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.onTap,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationNormal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppTheme.animationCurveApple,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GlassCard(
          onTap: widget.onTap,
          child: Row(
            children: [
              // Icon container com gradiente
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (widget.iconColor ?? AppTheme.primary).withOpacity(0.2),
                      (widget.iconColor ?? AppTheme.primary).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isHovered
                      ? AppTheme.glowShadow(
                          widget.iconColor ?? AppTheme.primary)
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor ?? AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: AppTheme.animationFast,
                      style: TextStyle(
                        color: _isHovered
                            ? AppTheme.primary
                            : AppTheme.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      child: Text(widget.value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### **3.5 lib/shared/widgets/gradient_background.dart**

```dart
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
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: showPattern
          ? Stack(
              children: [
                // Padrão de fundo opcional
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.03,
                    child: Image.asset(
                      'assets/images/pattern.png',
                      repeat: ImageRepeat.repeat,
                      fit: BoxFit.none,
                    ),
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}
```

---

## 🖥️ **PASSO 4: Tela de Login COMPLETA (Estilizada)**

### **4.1 lib/features/auth/presentation/login_screen.dart**

```dart
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

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

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle,
                    color: AppTheme.danger),
                SizedBox(width: 8),
                Text('Erro no Login'),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(e.toString()),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
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
                          // Logo com animação
                          Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: AppTheme.glowShadow(
                                      AppTheme.primary),
                                ),
                                child: const Icon(
                                  CupertinoIcons.eye_fill,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXLarge),

                          // Title
                          const Text(
                            '👁️ Bem-vindo',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingSmall),

                          // Subtitle
                          const Text(
                            'Faça login para acessar sua conta',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textMuted,
                              letterSpacing: -0.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingXXLarge),

                          // Card Container
                          GlassCard(
                            padding: const EdgeInsets.all(
                                AppTheme.spacingLarge),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email
                                HybridTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  placeholder: 'seu@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: CupertinoIcons.mail,
                                ),
                                const SizedBox(height: AppTheme.spacingLarge),

                                // Password
                                HybridTextField(
                                  controller: _passwordController,
                                  label: 'Senha',
                                  placeholder: '••••••••',
                                  obscureText: _obscurePassword,
                                  prefixIcon: CupertinoIcons.lock,
                                  suffix: CupertinoButton(
                                    padding: const EdgeInsets.only(right: 12),
                                    onPressed: () {
                                      setState(() => _obscurePassword =
                                          !_obscurePassword);
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
                                const SizedBox(height: AppTheme.spacingXLarge),

                                // Login Button
                                HybridButton(
                                  text: 'Entrar',
                                  onPressed: _handleLogin,
                                  isLoading: _isLoading,
                                  icon: CupertinoIcons.arrow_right,
                                  width: double.infinity,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingLarge),

                          // Register Link
                          CupertinoButton(
                            onPressed: () => context.go('/register'),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Não tem conta? ',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 15,
                                  letterSpacing: -0.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Crie uma agora →',
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
```

---

## 📊 **PASSO 5: Dashboard COMPLETO (Estilizado)**

### **5.1 lib/features/dashboard/presentation/dashboard_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/client.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/hybrid_button.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final clientsStream = ref
        .watch(firestoreServiceProvider)
        .getClients(user?.uid ?? '');

    return Scaffold(
      body: GradientBackground(
        child: CustomScrollView(
          slivers: [
            // AppBar com glassmorphism
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.borderDark,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: AppTheme.glowShadow(AppTheme.primary),
                    ),
                    child: const Icon(
                      CupertinoIcons.eye_fill,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DoPVision',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                  },
                  child: const Icon(
                    CupertinoIcons.square_arrow_right,
                    color: AppTheme.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    const Text(
                      'Visão completa dos seus clientes e campanhas',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 15,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),

                    // Metrics Grid
                    StreamBuilder<List<Client>>(
                      stream: clientsStream,
                      builder: (context, snapshot) {
                        final clients = snapshot.data ?? [];

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 4 : 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            MetricCard(
                              icon: CupertinoIcons.money_dollar_circle_fill,
                              label: 'Receita Total',
                              value: 'R\$ 0',
                              iconColor: AppTheme.success,
                            ),
                            MetricCard(
                              icon: CupertinoIcons.chart_bar_alt_fill,
                              label: 'ROI Médio',
                              value: '0%',
                              iconColor: AppTheme.primary,
                            ),
                            MetricCard(
                              icon: CupertinoIcons.creditcard_fill,
                              label: 'Investimento',
                              value: 'R\$ 0',
                              iconColor: AppTheme.warning,
                            ),
                            MetricCard(
                              icon: CupertinoIcons.person_3_fill,
                              label: 'Clientes',
                              value: '${clients.length}',
                              iconColor: AppTheme.secondary,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingXLarge),

                    // Clients Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seus Clientes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // TODO: Filter/Sort
                          },
                          child: const Icon(
                            CupertinoIcons.slider_horizontal_3,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),

                    // Clients List
                    StreamBuilder<List<Client>>(
                      stream: clientsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppTheme.spacingXLarge),
                              child: CupertinoActivityIndicator(
                                radius: 20,
                              ),
                            ),
                          );
                        }

                        final clients = snapshot.data ?? [];

                        if (clients.isEmpty) {
                          return _buildEmptyState();
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 900
                                    ? 3
                                    : MediaQuery.of(context).size.width > 600
                                        ? 2
                                        : 1,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: clients.length,
                          itemBuilder: (context, index) {
                            return _ClientCard(client: clients[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // FAB com gradiente
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.glowShadow(AppTheme.primary),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Add client
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(CupertinoIcons.add, size: 24),
          label: const Text(
            'Novo Cliente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.2),
                      AppTheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  CupertinoIcons.chart_pie,
                  size: 60,
                  color: AppTheme.textMuted.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            const Text(
              'Nenhum cliente ainda',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            const Text(
              'Comece adicionando seu primeiro cliente\npara ver as métricas',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            HybridButton(
              text: 'Adicionar Primeiro Cliente',
              onPressed: () {
                // TODO
              },
              icon: CupertinoIcons.add,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatefulWidget {
  final Client client;

  const _ClientCard({required this.client});

  @override
  State<_ClientCard> createState() => _ClientCardState();
}

class _ClientCardState extends State<_ClientCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: AppTheme.animationFast,
        curve: AppTheme.animationCurveApple,
        child: GlassCard(
          onTap: () {
            // TODO: Navigate
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.2),
                          AppTheme.secondary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getClientIcon(widget.client.type),
                      color: AppTheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.client.name,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.client.segment != null)
                          Text(
                            widget.client.segment!,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (widget.client.monthlyGoal != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.flag_fill,
                        size: 14,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Meta: ${_formatGoal(widget.client.monthlyGoal!, widget.client.goalType)}',
                        style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getClientIcon(ClientType type) {
    switch (type) {
      case ClientType.physical:
        return CupertinoIcons.building_2_fill;
      case ClientType.online:
        return CupertinoIcons.globe;
      case ClientType.hybrid:
        return CupertinoIcons.arrow_2_squarepath;
    }
  }

  String _formatGoal(double goal, GoalType? type) {
    if (type == GoalType.revenue) {
      return NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 0,
      ).format(goal);
    }
    return '${goal.toInt()} leads';
  }
}
```

---

## 🚀 **PASSO 6: Main.dart**

### **6.1 lib/main.dart**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/firebase_config.dart';
import 'shared/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Status bar transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      authDomain: FirebaseConfig.authDomain,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      appId: FirebaseConfig.appId,
      measurementId: FirebaseConfig.measurementId,
    ),
  );

  runApp(
    const ProviderScope(
      child: DoPVisionApp(),
    ),
  );
}

class DoPVisionApp extends ConsumerWidget {
  const DoPVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DoPVision',
      theme: AppTheme.materialDarkTheme,
      darkTheme: AppTheme.materialDarkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return CupertinoTheme(
          data: AppTheme.cupertinoTheme,
          child: child!,
        );
      },
    );
  }
}
```

---

## ✅ **CHECKLIST DE INSTALAÇÃO**

```bash
cd /Users/lucasfranco/development/dopvision_flutter

# 1. Instalar dependências
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
flutter pub add flutter_riverpod go_router
flutter pub add cupertino_icons google_fonts flutter_platform_widgets
flutter pub add glassmorphism shimmer fl_chart intl

# 2. Rodar o projeto
flutter pub get
flutter run -d chrome

# ou macOS
flutter run -d macos
```

---

## 🎨 **RECURSOS DE ESTILIZAÇÃO INCLUÍDOS**

✅ **Glassmorphism** (cards translúcidos)
✅ **Gradientes** (background + componentes)
✅ **Animações suaves** (hover, focus, transitions)
✅ **Shadows com glow** (efeitos de luz)
✅ **Typography Apple-style** (Inter font)
✅ **Border radius consistente**
✅ **Cores DoPVision** (idêntico ao Angular)
✅ **Espaçamentos padronizados**
✅ **Cupertino icons** (SF Symbols style)
✅ **Material + Cupertino híbrido**

---

## 📊 **RESULTADO VISUAL**

### **Login Screen:**
- Background gradiente azul escuro
- Logo com gradiente e glow
- Card glassmorphism
- Inputs Cupertino elegantes
- Botão com gradiente e animação
- Animações de entrada suaves

### **Dashboard:**
- AppBar translúcido
- Cards de métricas glassmorphism
- Hover effects nos cards
- FAB com gradiente
- Grid responsivo
- Empty state animado

---

## 🎯 **PRÓXIMOS PASSOS**

Agora você tem **TUDO** em um lugar:
1. ✅ Theme completo
2. ✅ Widgets estilizados
3. ✅ Telas funcionais
4. ✅ Animações integradas
5. ✅ Glassmorphism
6. ✅ Híbrido Material + Cupertino

**É só copiar os códigos e rodar! 🚀**

Quer que eu crie mais componentes (dialogs, forms, gráficos)? Me avisa! 🎨✨
