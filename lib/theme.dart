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

  static ThemeData get highContrastTheme {
    const Color highContrastBackground = Colors.black;
    const Color highContrastYellow = Color(0xFFFFE600);
    const Color highContrastWhite = Colors.white;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: highContrastBackground,
      colorScheme: const ColorScheme.highContrastDark(
        primary: highContrastYellow,
        onPrimary: Colors.black,
        secondary: highContrastYellow,
        onSecondary: Colors.black,
        surface: highContrastBackground,
        onSurface: highContrastWhite,
        surfaceContainerLow: Color(0xFF1C1C1C),
        surfaceContainer: Color(0xFF262626),
        surfaceContainerHighest: Color(0xFF333333),
        error: Colors.redAccent,
        onError: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1C1C),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: highContrastYellow, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C1C1C),
        hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
        labelStyle: const TextStyle(color: highContrastYellow, fontSize: 16, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: highContrastYellow, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: highContrastYellow, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: highContrastWhite, width: 2.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: highContrastYellow),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: highContrastYellow),
        titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: highContrastYellow),
        bodyLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: highContrastWhite),
        bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: highContrastWhite),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: highContrastBackground,
        foregroundColor: highContrastYellow,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: highContrastYellow, size: 28),
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: highContrastYellow),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return highContrastYellow;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return highContrastYellow;
          return Colors.grey[800];
        }),
        trackOutlineColor: WidgetStateProperty.all(highContrastYellow),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highContrastYellow,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: highContrastWhite, width: 2),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: highContrastYellow,
          side: const BorderSide(color: highContrastYellow, width: 2),
          textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: highContrastBackground,
        selectedItemColor: highContrastYellow,
        unselectedItemColor: highContrastWhite,
      ),
      dividerTheme: const DividerThemeData(
        color: highContrastYellow,
        thickness: 2,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: highContrastWhite,
        iconColor: highContrastYellow,
      ),
    );
  }
}
