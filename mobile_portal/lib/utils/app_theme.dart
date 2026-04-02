import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color darkGreen = Color(0xFF1B4D3E);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF7F8C8D);
  static const Color accentGreen = Color(0xFFE8F8F5);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: darkGreen,
        surface: surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        bodyLarge: GoogleFonts.outfit(color: textDark),
        bodyMedium: GoogleFonts.outfit(color: textDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
    );
  }

  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static TextStyle arabicStyle = GoogleFonts.amiri(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.8,
    color: textDark,
  );
}
