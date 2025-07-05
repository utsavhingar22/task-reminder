import 'package:flutter/material.dart';

class AppTheme {
  // Modern Color Palette
  static const primaryColor = Color(0xFF6366F1); // Indigo
  static const secondaryColor = Color(0xFF8B5CF6); // Violet
  static const accentColor = Color(0xFF06B6D4); // Cyan
  static const successColor = Color(0xFF10B981); // Emerald
  static const warningColor = Color(0xFFF59E0B); // Amber
  static const errorColor = Color(0xFFEF4444); // Red

  // Light Theme Colors
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF1F2937);
  static const lightTextSecondary = Color(0xFF6B7280);

  // Dark Theme Colors
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard = Color(0xFF334155);
  static const darkText = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [accentColor, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [successColor, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Animation constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  static const Curve defaultAnimationCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;

  // Modern Typography
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.3,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      height: 1.4,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      height: 1.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15,
      height: 1.4,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.6,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.6,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.4,
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      background: lightBackground,
      onBackground: lightText,
      surface: lightSurface,
      onSurface: lightText,
      surfaceVariant: Color(0xFFF1F5F9),
      onSurfaceVariant: lightTextSecondary,
      outline: Color(0xFFE2E8F0),
      outlineVariant: Color(0xFFCBD5E1),
    ),
    scaffoldBackgroundColor: lightBackground,
    textTheme: textTheme,
    cardTheme: CardTheme(
      color: lightCard,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        animationDuration: defaultAnimationDuration,
        shadowColor: primaryColor.withOpacity(0.3),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      extendedTextStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: errorColor),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: lightText),
      titleTextStyle: TextStyle(
        color: lightText,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      actionsIconTheme: IconThemeData(color: lightText),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightText,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
    ),
    iconTheme: const IconThemeData(color: secondaryColor, size: 24),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 24,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 8,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      circularTrackColor: primaryColor.withOpacity(0.2),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: lightText),
      contentTextStyle:
          textTheme.bodyMedium?.copyWith(color: lightTextSecondary),
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade100,
      selectedColor: primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF818CF8),
      onPrimary: Colors.black,
      secondary: Color(0xFFA78BFA),
      onSecondary: Colors.black,
      tertiary: Color(0xFF22D3EE),
      onTertiary: Colors.black,
      error: Color(0xFFF87171),
      onError: Colors.black,
      background: darkBackground,
      onBackground: darkText,
      surface: darkSurface,
      onSurface: darkText,
      surfaceVariant: Color(0xFF475569),
      onSurfaceVariant: darkTextSecondary,
      outline: Color(0xFF64748B),
      outlineVariant: Color(0xFF475569),
    ),
    scaffoldBackgroundColor: darkBackground,
    textTheme: textTheme.apply(
      bodyColor: darkText,
      displayColor: darkText,
    ),
    cardTheme: CardTheme(
      color: darkCard,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        elevation: 0,
        backgroundColor: const Color(0xFF818CF8),
        foregroundColor: Colors.black,
        animationDuration: defaultAnimationDuration,
        shadowColor: const Color(0xFF818CF8).withOpacity(0.3),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF22D3EE),
      foregroundColor: Colors.black,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      extendedTextStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      filled: true,
      fillColor: darkCard,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: darkTextSecondary,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: darkText),
      titleTextStyle: TextStyle(
        color: darkText,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      actionsIconTheme: IconThemeData(color: darkText),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkText,
      contentTextStyle: TextStyle(color: Colors.black),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      elevation: 8,
    ),
    iconTheme: const IconThemeData(color: Color(0xFFA78BFA), size: 24),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF475569),
      thickness: 1,
      space: 24,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 8,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF818CF8),
      circularTrackColor: Color(0xFF475569),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkText,
      ),
      contentTextStyle: const TextStyle(fontSize: 16, color: darkTextSecondary),
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF475569),
      selectedColor: const Color(0xFF818CF8),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
