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
      Colors.white.withValues(alpha: 0.03),
      Colors.white.withValues(alpha: 0.01),
    ],
  );

  // ========== SHADOWS ==========
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.4),
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
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.2),
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

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: radiusMedium,
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
