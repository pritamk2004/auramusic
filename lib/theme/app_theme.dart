import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF1DB954); // Vibrant Green (Spotify style)
  static const Color secondary = Color(0xFF9C27B0); // Deep Violet
  static const Color accent = Color(0xFF00E5FF); // Electric Cyan

  // AMOLED True Black Theme
  static ThemeData get amoledBlackTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: Color(0xFF121212),
        onSurface: Colors.white,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A0A0A),
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF888888),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardColor: const Color(0xFF121212),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF181818),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Spotify Midnight Dark Theme
  static ThemeData get midnightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1ED760),
        secondary: Color(0xFF6366F1),
        surface: Color(0xFF151D2A),
        onSurface: Colors.white,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0E131F),
        selectedItemColor: Color(0xFF1ED760),
        unselectedItemColor: Color(0xFF7E8B9B),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardColor: const Color(0xFF151D2A),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF1A2332),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
