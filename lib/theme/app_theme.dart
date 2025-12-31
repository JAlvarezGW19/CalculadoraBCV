import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF0A192F); // Deep Navy
  static const Color cardBackground = Color(
    0xFF1A2B42,
  ); // Slightly lighter navy
  static const Color textPrimary = Color(0xFFF8FAFC); // Off-White
  static const Color textAccent = Color(0xFF10B981); // Vibrant Emerald
  static const Color textSubtle = Color(0xFFA0AEC0); // Light Grayish Blue

  // Text Styles
  static Locale? currentLocale;

  static const _supportedCustomFontCodes = ['en', 'es', 'fr', 'it', 'pt', 'de'];

  static TextStyle _getFont({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    // If locale is null or NOT in the clean list (Latin based), use system font
    // This ensures CJK/Arabic/Cyrillic render correctly with system fonts
    final code = currentLocale?.languageCode ?? 'en';
    if (_supportedCustomFontCodes.contains(code)) {
      return GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } else {
      // Return system font (no family specified)
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFamilyFallback: const [
          'Roboto',
          'sans-serif',
          'Arial',
        ], // Basic fallback
      );
    }
  }

  // Text Styles
  static TextStyle get rateStyle =>
      _getFont(fontSize: 24, fontWeight: FontWeight.bold, color: textAccent);

  static TextStyle get rateLabelStyle =>
      _getFont(fontSize: 24, fontWeight: FontWeight.w500, color: textPrimary);

  static TextStyle get inputTextStyle =>
      _getFont(fontSize: 36, fontWeight: FontWeight.bold, color: textPrimary);

  static TextStyle get inputLabelStyle =>
      _getFont(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary);

  static TextStyle get subtitleStyle =>
      _getFont(fontSize: 14, fontWeight: FontWeight.w400, color: textSubtle);

  // Global Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: background,
      colorScheme: ColorScheme.dark(
        primary: textAccent,
        surface: cardBackground,
      ),
      textTheme: TextTheme(
        bodyMedium: _getFont(color: textPrimary),
        bodyLarge: _getFont(color: textPrimary),
      ),
    );
  }
}
