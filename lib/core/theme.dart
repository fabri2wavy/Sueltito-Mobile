import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color verdeAzulado = Color(0xFF199D89);
  static const Color violetaRuso = Color(0xFF280033);
  static const Color gris = Color(0xFFD9D9D9);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: violetaRuso,
        primary: violetaRuso,
        secondary: verdeAzulado,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.getTextTheme('Fredoka'),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verdeAzulado,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}
