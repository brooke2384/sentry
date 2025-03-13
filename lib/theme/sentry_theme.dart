import 'package:flutter/material.dart';

class SentryTheme {
  // Primary colors
  static const Color primaryUltraviolet = Color(0xFF2B1A5A); // Deep ultraviolet
  static const Color primaryPurple = Color(0xFF6C38CC); // Vibrant purple
  static const Color accentBlue = Color(0xFF3E64FF); // Electric blue
  static const Color accentCyan =
      Color(0xFF00D4FF); // Bright cyan for highlights
  static const Color accentLime = Color(0xFFBCCE2A); // Lime accent color

  // Neutral colors
  static const Color darkBackground =
      Color(0xFF121212); // Near black for dark mode
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark surface
  static const Color lightBackground = Color(0xFFF8F9FC); // Light background
  static const Color lightSurface = Color(0xFFFFFFFF); // White surface

  // Alert colors
  static const Color alertRed = Color(0xFFE02020); // Emergency red
  static const Color alertYellow = Color(0xFFFFD600); // Warning yellow
  static const Color alertGreen = Color(0xFF00C853); // Success green

  // Text colors
  static const Color darkTextPrimary =
      Color(0xFFFFFFFF); // White text for dark mode
  static const Color darkTextSecondary =
      Color(0xFFB0B0B0); // Grey text for dark mode
  static const Color lightTextPrimary =
      Color(0xFF121212); // Dark text for light mode
  static const Color lightTextSecondary =
      Color(0xFF757575); // Grey text for light mode

  // Volumetric lighting effect colors
  static const Color glowPurple = Color(0x336C38CC); // Transparent purple glow
  static const Color glowBlue = Color(0x333E64FF); // Transparent blue glow

  // Create ThemeData for light mode
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryPurple,
        secondary: accentBlue,
        surface: lightSurface,
        error: alertRed,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: darkTextPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Create ThemeData for dark mode
  static ThemeData darkTheme() {
    return ThemeData(
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryPurple,
        secondary: accentBlue,
        surface: darkSurface,
        error: alertRed,
      ),
      textTheme: const TextTheme().apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: darkTextPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // Custom shadow for volumetric lighting effect
  static List<BoxShadow> getVolumetricShadow({bool isPrimary = true}) {
    return [
      BoxShadow(
        color: isPrimary ? glowPurple : glowBlue,
        blurRadius: 15,
        spreadRadius: 2,
      ),
    ];
  }

  // Emergency button style
  static BoxDecoration emergencyButtonDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [alertRed, Color(0xFFFF4D4D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: alertRed.withOpacity(0.4),
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ],
  );

  static var accentColor;

  static var primaryColor;
}
