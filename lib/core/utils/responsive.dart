import 'package:flutter/material.dart';

/// Breakpoints responsivos estilo Apple
class ResponsiveBreakpoints {
  // Mobile (iPhone)
  static const double mobile = 375;
  static const double mobileLarge = 428; // iPhone Pro Max
  
  // Tablet (iPad)
  static const double tablet = 768;
  static const double tabletLarge = 1024; // iPad Pro
  
  // Desktop
  static const double desktop = 1280;
  static const double desktopLarge = 1920;
}

/// Extension para facilitar responsividade
extension ResponsiveContext on BuildContext {
  /// Largura da tela
  double get width => MediaQuery.of(this).size.width;
  
  /// Altura da tela
  double get height => MediaQuery.of(this).size.height;
  
  /// É mobile? (< 768px)
  bool get isMobile => width < ResponsiveBreakpoints.tablet;
  
  /// É tablet? (>= 768px e < 1280px)
  bool get isTablet => width >= ResponsiveBreakpoints.tablet && width < ResponsiveBreakpoints.desktop;
  
  /// É desktop? (>= 1280px)
  bool get isDesktop => width >= ResponsiveBreakpoints.desktop;
  
  /// Padding horizontal responsivo
  double get horizontalPadding {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }
  
  /// Máximo de largura de conteúdo
  double get maxContentWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 768;
    return 1200;
  }
  
  /// Grid columns responsivo
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }
  
  /// Safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;
  
  /// Bottom safe area (para notch)
  double get bottomSafeArea => MediaQuery.of(this).padding.bottom;
  
  /// Top safe area (para status bar)
  double get topSafeArea => MediaQuery.of(this).padding.top;
}

/// Widget responsivo que retorna widgets diferentes por tamanho
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!;
    }
    
    if (context.isTablet && tablet != null) {
      return tablet!;
    }
    
    return mobile;
  }
}

/// Layout com max-width centrado
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.maxContentWidth,
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
        ),
        child: child,
      ),
    );
  }
}
