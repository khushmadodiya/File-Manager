import 'package:flutter/material.dart';

class AppTheme {
  static const _accentBlue = Color(0xFF0A84FF);

  /// 🌤 Light Bubble Theme (macOS style)
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor: const Color(0xFFF5F6F7),

      colorScheme: ColorScheme.light(
        primary: _accentBlue,
        secondary: _accentBlue,
        surface: Colors.white.withOpacity(0.9),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      dividerColor: Colors.black.withOpacity(0.08),

      textTheme: _textTheme(Colors.black87),

      hoverColor: _accentBlue.withOpacity(0.12),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 🌙 Dark Bubble Theme (Recommended)
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      scaffoldBackgroundColor: const Color(0xFF252A2B),

      colorScheme: ColorScheme.dark(
        primary: _accentBlue,
        secondary: _accentBlue,
        surface: Colors.white.withOpacity(0.12),
      ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          contentTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      dividerColor: Colors.white.withOpacity(0.15),

      textTheme: _textTheme(Colors.white),

      hoverColor: _accentBlue.withOpacity(0.15),
      drawerTheme: DrawerThemeData(
        backgroundColor: Color(0xFF1D2022),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      )
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      bodyMedium: TextStyle(color: color, fontSize: 14),
      bodySmall: TextStyle(color: color.withOpacity(0.8)),
      titleMedium: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}