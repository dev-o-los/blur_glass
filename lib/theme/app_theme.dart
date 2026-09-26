import 'package:flutter/material.dart';

import 'app_colors.dart';

class BlurGlassTheme {
  static ThemeData light() {
    const blue = BrandColors.blueLight;
    final scheme = ColorScheme.light(
      primary: blue,
      onPrimary: Colors.white,
      primaryContainer: BrandColors.blueTintLight,
      onPrimaryContainer: blue,
      secondary: BrandColors.lightTextSecondary,
      onSecondary: Colors.white,
      surface: BrandColors.lightSurface,
      onSurface: BrandColors.lightTextPrimary,
      surfaceContainerLowest: BrandColors.lightCanvas,
      surfaceContainerLow: BrandColors.lightSurface,
      surfaceContainer: BrandColors.lightSurfaceRaised,
      surfaceContainerHigh: BrandColors.lightSidebar,
      surfaceContainerHighest: BrandColors.lightSidebar,
      error: BrandColors.redLight,
      onError: Colors.white,
      outline: BrandColors.lightHairlineStrong,
      outlineVariant: BrandColors.lightHairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamily: '.SF Pro Text',
      scaffoldBackgroundColor: BrandColors.lightCanvas,
      splashFactory: NoSplash.splashFactory,
      typography: Typography.material2021(platform: TargetPlatform.macOS),
      textTheme: _textTheme(isDark: false),
      filledButtonTheme: _filledButtonTheme(blue),
      outlinedButtonTheme: _outlinedButtonTheme(isDark: false),
      textButtonTheme: _textButtonTheme(blue),
      iconTheme: const IconThemeData(color: BrandColors.lightTextPrimary),
      dividerTheme: const DividerThemeData(
        color: BrandColors.lightHairline,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: _dialogTheme(isDark: false),
      sliderTheme: _sliderTheme(blue, isDark: false),
      tooltipTheme: _tooltipTheme(isDark: false),
    );
  }

  static ThemeData dark() {
    const blue = BrandColors.blue;
    final scheme = ColorScheme.dark(
      primary: blue,
      onPrimary: Colors.white,
      primaryContainer: BrandColors.blueTintDark,
      onPrimaryContainer: BrandColors.blueBright,
      secondary: BrandColors.darkTextSecondary,
      onSecondary: Colors.white,
      surface: BrandColors.darkSurface,
      onSurface: BrandColors.darkTextPrimary,
      surfaceContainerLowest: BrandColors.darkCanvas,
      surfaceContainerLow: BrandColors.darkSurface,
      surfaceContainer: BrandColors.darkSurfaceRaised,
      surfaceContainerHigh: BrandColors.darkSidebar,
      surfaceContainerHighest: BrandColors.darkSidebar,
      error: BrandColors.red,
      onError: Colors.white,
      outline: BrandColors.darkHairlineStrong,
      outlineVariant: BrandColors.darkHairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: '.SF Pro Text',
      scaffoldBackgroundColor: BrandColors.darkCanvas,
      splashFactory: NoSplash.splashFactory,
      typography: Typography.material2021(platform: TargetPlatform.macOS),
      textTheme: _textTheme(isDark: true),
      filledButtonTheme: _filledButtonTheme(blue),
      outlinedButtonTheme: _outlinedButtonTheme(isDark: true),
      textButtonTheme: _textButtonTheme(blue),
      iconTheme: const IconThemeData(color: BrandColors.darkTextPrimary),
      dividerTheme: const DividerThemeData(
        color: BrandColors.darkHairline,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: _dialogTheme(isDark: true),
      sliderTheme: _sliderTheme(blue, isDark: true),
      tooltipTheme: _tooltipTheme(isDark: true),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(Color blue) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor:
            isDark ? BrandColors.darkTextPrimary : BrandColors.lightTextPrimary,
        backgroundColor:
            isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        minimumSize: const Size(0, 32),
        side: BorderSide(
          color: isDark ? BrandColors.darkHairline : BrandColors.lightHairline,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color blue) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: blue,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(0, 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static SliderThemeData _sliderTheme(Color blue, {required bool isDark}) {
    return SliderThemeData(
      activeTrackColor: blue,
      inactiveTrackColor:
          isDark ? const Color(0x28FFFFFF) : const Color(0x1E000000),
      thumbColor: Colors.white,
      overlayColor: blue.withValues(alpha: 0.15),
      trackHeight: 3.5,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 7,
        elevation: 2,
      ),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    );
  }

  static TooltipThemeData _tooltipTheme({required bool isDark}) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE62A2C34) : const Color(0xF0FFFFFF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? BrandColors.darkHairline : BrandColors.lightHairline,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      textStyle: TextStyle(
        fontSize: 11,
        color: isDark ? BrandColors.darkTextPrimary : BrandColors.lightTextPrimary,
      ),
      waitDuration: const Duration(milliseconds: 400),
    );
  }

  static DialogThemeData _dialogTheme({required bool isDark}) {
    return DialogThemeData(
      backgroundColor:
          isDark ? BrandColors.darkSurfaceRaised : BrandColors.lightSurface,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? BrandColors.darkHairline : BrandColors.lightHairline,
        ),
      ),
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? BrandColors.darkTextPrimary : BrandColors.lightTextPrimary,
      ),
      contentTextStyle: TextStyle(
        fontSize: 13,
        height: 1.5,
        color:
            isDark ? BrandColors.darkTextSecondary : BrandColors.lightTextSecondary,
      ),
    );
  }

  static TextTheme _textTheme({required bool isDark}) {
    final base =
        isDark ? BrandColors.darkTextPrimary : BrandColors.lightTextPrimary;
    final secondary =
        isDark ? BrandColors.darkTextSecondary : BrandColors.lightTextSecondary;
    final tertiary =
        isDark ? BrandColors.darkTextTertiary : BrandColors.lightTextTertiary;

    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: base,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: base,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
        color: base,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: base,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        color: base,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: base,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: base,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.05,
        color: base,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: tertiary,
      ),
    );
  }
}
