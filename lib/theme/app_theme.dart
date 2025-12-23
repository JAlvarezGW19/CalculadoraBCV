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
  static TextStyle get rateStyle => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textAccent,
  );

  static TextStyle get rateLabelStyle => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get inputTextStyle => GoogleFonts.montserrat(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get inputLabelStyle => GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get subtitleStyle => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSubtle,
  );

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
        bodyMedium: GoogleFonts.montserrat(color: textPrimary),
        bodyLarge: GoogleFonts.montserrat(color: textPrimary),
      ),
    );
  }
}
