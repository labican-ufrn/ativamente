import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from the screenshots
  static const Color primaryDarkBlue = Color(0xFF1E315A); // Very dark blue for buttons and app bar
  static const Color backgroundLightGrey = Color(0xFFF3F3F3); // Light grey background
  static const Color textDark = Color(0xFF1E315A); // Text is usually the same dark blue
  static const Color white = Colors.white;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLightGrey,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDarkBlue,
        primary: primaryDarkBlue,
        onPrimary: white,
        surface: backgroundLightGrey,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
        titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 18, color: textDark),
        bodyMedium: GoogleFonts.inter(fontSize: 16, color: textDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: white,
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkBlue,
          foregroundColor: white,
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          side: const BorderSide(color: primaryDarkBlue, width: 2),
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryDarkBlue,
        selectedItemColor: white,
        unselectedItemColor: Colors.white60,
      ),
    );
  }
}
