import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── VITA DESIGN TOKENS ───────────────────────────────────────────────────────
class VitaColors {
  // Primary palette
  static const Color green = Color(0xFF1A6B4A);
  static const Color teal = Color(0xFF18A574);
  static const Color lightGreen = Color(0xFFE8F5EE);
  static const Color gold = Color(0xFFD4A017);
  static const Color dark = Color(0xFF1A1A2E);
  static const Color gray = Color(0xFF6B7280);
  static const Color red = Color(0xFFC0392B);
  static const Color white = Color(0xFFFAFAF8);
  static const Color ink = Color(0xFF0D0D0D);
  static const Color background = Color(0xFFEBEBEA);

  // Derived / semantic
  static const Color darkGreen = Color(0xFF0D2A1E);
  static const Color deepGreen = Color(0xFF155a3d);
  static const Color lightTeal = Color(0xFF6FFFC2);
  static const Color lightRed = Color(0xFFFF8070);
  static const Color goldLight = Color(0xFFF5D060);
  static const Color lightRedBg = Color(0xFFFEF0EF);
  static const Color goldBg = Color(0xFFFFF8E6);
  static const Color cardBorder = Color(0x0F000000);
  static const Color divider = Color(0x0D000000);
}

// ─── VITA TEXT STYLES ─────────────────────────────────────────────────────────
class VitaText {
  // Display / Headings — Plus Jakarta Sans (≈ Clash Display)
  static TextStyle display(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? VitaColors.ink,
        letterSpacing: -size * 0.035,
      );

  // Body — Inter (≈ Cabinet Grotesk)
  static TextStyle body(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? VitaColors.ink,
      );

  // Mono — DM Mono
  static TextStyle mono(double size, {Color? color, FontWeight? weight}) =>
      GoogleFonts.dmMono(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? VitaColors.gray,
      );

  // Serif / Italic — Playfair Display (≈ Instrument Serif italic)
  static TextStyle serif(double size, {Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: color ?? VitaColors.ink,
      );

  // Label (uppercase mono)
  static TextStyle label(double size, {Color? color}) =>
      GoogleFonts.dmMono(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? VitaColors.gray,
        letterSpacing: 1.5,
      );
}

// ─── VITA THEME ───────────────────────────────────────────────────────────────
class VitaTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: VitaColors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: VitaColors.green,
          primary: VitaColors.green,
          secondary: VitaColors.teal,
          error: VitaColors.red,
          surface: VitaColors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: VitaColors.white,
          foregroundColor: VitaColors.ink,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: VitaColors.ink,
            letterSpacing: -0.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: VitaColors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F2F0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: VitaColors.teal, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFFB0B0AE),
            fontWeight: FontWeight.w400,
          ),
          labelStyle: GoogleFonts.dmMono(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: VitaColors.dark,
            letterSpacing: 0.8,
          ),
        ),
      );
}

// ─── SHARED DECORATIONS ───────────────────────────────────────────────────────
class VitaDecorations {
  static BoxDecoration card({Color? color, double radius = 20}) => BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0x0F000000)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
