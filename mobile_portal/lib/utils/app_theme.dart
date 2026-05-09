import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system for Qalaam.
///
/// Tokens are organized as:
///   - Color palette (primary / surface / text / semantic)
///   - Spacing + radius scale
///   - Shadows
///   - Typography helpers
///   - Decorations (cards, gradients)
class AppTheme {
  // ═══════════════════════════════════════════════════════════════
  // COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════

  // Primary — deep emerald, less saturated than the old bright green
  static const Color primaryGreen = Color(0xFF0E5C44);
  static const Color primaryGreenDeep = Color(0xFF082E22);
  static const Color primaryGreenSoft = Color(0xFF1B7C5E);

  // Backwards-compat alias
  static const Color darkGreen = primaryGreenDeep;

  // Accents
  static const Color gold = Color(0xFFC5A572);
  static const Color goldSoft = Color(0xFFE8D9B5);

  // Surfaces — warm parchment vibe
  static const Color background = Color(0xFFFAF6EE);
  static const Color surface = Colors.white;
  static const Color parchment = Color(0xFFF4ECDD);
  static const Color cream = Color(0xFFFAF6EE);

  // Text
  static const Color textDark = Color(0xFF1A1F26);
  static const Color textBody = Color(0xFF3D434E);
  static const Color textGrey = Color(0xFF7A7E87);
  static const Color textMuted = Color(0xFFA9ACB4);
  static const Color textOnDark = Color(0xFFF5EFE3);

  // Soft tints for icon backgrounds
  static const Color accentGreen = Color(0xFFE8F1ED);
  static const Color accentGold = Color(0xFFFAF3E5);
  static const Color accentBlue = Color(0xFFE9F0FA);
  static const Color accentRose = Color(0xFFFAEFEC);
  static const Color accentLavender = Color(0xFFEFEAF7);

  // Borders / dividers
  static const Color borderLight = Color(0xFFEBE3D2);
  static const Color borderHair = Color(0xFFF1ECDF);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);

  // ═══════════════════════════════════════════════════════════════
  // SPACING (4-pt grid)
  // ═══════════════════════════════════════════════════════════════
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 32;
  static const double space8 = 40;
  static const double space9 = 48;

  // ═══════════════════════════════════════════════════════════════
  // RADIUS
  // ═══════════════════════════════════════════════════════════════
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;
  static const double radiusPill = 999;

  // ═══════════════════════════════════════════════════════════════
  // SHADOWS
  // ═══════════════════════════════════════════════════════════════
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: const Color(0xFF0E5C44).withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: const Color(0xFF0E5C44).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: const Color(0xFF0E5C44).withOpacity(0.10),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> shadowGlow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.22),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  // ═══════════════════════════════════════════════════════════════
  // TYPOGRAPHY  (Manrope = clean, premium body/heading; Amiri = Arabic)
  // ═══════════════════════════════════════════════════════════════
  static TextStyle display({Color? color}) => GoogleFonts.manrope(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.6,
        color: color ?? textDark,
      );

  static TextStyle h1({Color? color}) => GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.4,
        color: color ?? textDark,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
        color: color ?? textDark,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.manrope(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color ?? textDark,
      );

  static TextStyle body({Color? color}) => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color ?? textBody,
      );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.manrope(
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        height: 1.55,
        color: color ?? textBody,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color ?? textGrey,
      );

  static TextStyle eyebrow({Color? color}) => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: color ?? primaryGreen,
      );

  static TextStyle button({Color? color}) => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: color ?? Colors.white,
      );

  static TextStyle arabicStyle = GoogleFonts.amiri(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    height: 1.85,
    color: textDark,
  );

  static TextStyle arabicLarge({Color? color}) => GoogleFonts.amiri(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        height: 1.9,
        color: color ?? textDark,
      );

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E5C44), Color(0xFF073E2C)],
  );

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E5C44), Color(0xFF082E22)],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD8BB80), Color(0xFFB99257)],
  );

  static const LinearGradient gradientCream = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF6EE), Color(0xFFF1E8D3)],
  );

  // ═══════════════════════════════════════════════════════════════
  // CARD DECORATIONS
  // ═══════════════════════════════════════════════════════════════
  static BoxDecoration cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: borderHair, width: 1),
    boxShadow: shadowSm,
  );

  static BoxDecoration cardElevated = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowMd,
  );

  static BoxDecoration cardFlat = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radiusMd),
    border: Border.all(color: borderHair, width: 1),
  );

  static BoxDecoration cardHero = BoxDecoration(
    gradient: gradientHero,
    borderRadius: BorderRadius.circular(radiusXl),
    boxShadow: shadowGlow(primaryGreenDeep),
  );

  static BoxDecoration tintedBox(Color tint, {double radius = radiusMd}) => BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(radius),
      );

  // ═══════════════════════════════════════════════════════════════
  // MATERIAL THEMEDATA
  // ═══════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: gold,
        surface: surface,
        background: background,
        error: error,
      ),
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: textBody,
        displayColor: textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: textDark,
          letterSpacing: -0.2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderHair, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.manrope(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryGreen, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accentGreen,
        labelStyle: GoogleFonts.manrope(
          color: primaryGreen,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusPill)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
