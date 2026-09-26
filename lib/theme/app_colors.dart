import 'package:flutter/material.dart';

import '../models/attention_snapshot.dart';

/// Blur Glass design tokens for both Light and Dark macOS modes.
abstract final class BrandColors {
  // macOS system blue
  static const blue = Color(0xFF0A84FF);
  static const blueLight = Color(0xFF007AFF);
  static const blueBright = Color(0xFF5AC8FA);
  static const blueDark = Color(0xFF0056B3);

  // Dark Theme Colors
  static const darkCanvas = Color(0xFF141518);
  static const darkSurface = Color(0xFF1E2026);
  static const darkSurfaceRaised = Color(0xFF282A32);
  static const darkSidebar = Color(0xFF17181D);
  static const darkHeroCore = Color(0xFF0B1728);

  static const darkTextPrimary = Color(0xFFF7F7F8);
  static const darkTextSecondary = Color(0xFFA2A3AB);
  static const darkTextTertiary = Color(0xFF6F717B);
  static const darkHairline = Color(0x28FFFFFF);
  static const darkHairlineStrong = Color(0x40FFFFFF);

  // Light Theme Colors
  static const lightCanvas = Color(0xFFF4F5F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceRaised = Color(0xFFF9FAFC);
  static const lightSidebar = Color(0xFFEBECEF);
  static const lightHeroCore = Color(0xFFE8F2FF);

  static const lightTextPrimary = Color(0xFF1A1B1E);
  static const lightTextSecondary = Color(0xFF666873);
  static const lightTextTertiary = Color(0xFF8E909B);
  static const lightHairline = Color(0x18000000);
  static const lightHairlineStrong = Color(0x2E000000);

  // Semantics
  static const green = Color(0xFF30D158);
  static const greenLight = Color(0xFF34C759);
  static const amber = Color(0xFFFFD60A);
  static const amberLight = Color(0xFFFF9500);
  static const red = Color(0xFFFF453A);
  static const redLight = Color(0xFFFF3B30);

  // Tints
  static const blueTintDark = Color(0x240A84FF);
  static const blueTintLight = Color(0x1A007AFF);
  static const greenTintDark = Color(0x2430D158);
  static const greenTintLight = Color(0x1A34C759);
  static const amberTintDark = Color(0x24FFD60A);
  static const amberTintLight = Color(0x1AFF9500);
  static const redTintDark = Color(0x24FF453A);
  static const redTintLight = Color(0x1AFF3B30);

  // Static defaults for direct access
  static const textPrimary = darkTextPrimary;
  static const textSecondary = darkTextSecondary;
  static const textTertiary = darkTextTertiary;
  static const hairline = darkHairline;
  static const hairlineStrong = darkHairlineStrong;
  static const sidebar = darkSidebar;
  static const surface = darkSurface;
  static const surfaceRaised = darkSurfaceRaised;
  static const canvas = darkCanvas;
  static const heroCore = darkHeroCore;

  static const blueTint = blueTintDark;
  static const greenTint = greenTintDark;
  static const amberTint = amberTintDark;
  static const redTint = redTintDark;
  static const neutralTint = Color(0x1CFFFFFF);

  static const markGradient = [
    Color(0xFF3A9DFF),
    Color(0xFF0067E6),
  ];
}

/// Resolved dynamic colors based on current context brightness.
class AppColors {
  const AppColors({required this.isDark});

  final bool isDark;

  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppColors(isDark: isDark);
  }

  Color get canvas => isDark ? BrandColors.darkCanvas : BrandColors.lightCanvas;
  Color get surface => isDark ? BrandColors.darkSurface : BrandColors.lightSurface;
  Color get surfaceRaised =>
      isDark ? BrandColors.darkSurfaceRaised : BrandColors.lightSurfaceRaised;
  Color get sidebar => isDark ? BrandColors.darkSidebar : BrandColors.lightSidebar;
  Color get heroCore => isDark ? BrandColors.darkHeroCore : BrandColors.lightHeroCore;

  Color get textPrimary =>
      isDark ? BrandColors.darkTextPrimary : BrandColors.lightTextPrimary;
  Color get textSecondary =>
      isDark ? BrandColors.darkTextSecondary : BrandColors.lightTextSecondary;
  Color get textTertiary =>
      isDark ? BrandColors.darkTextTertiary : BrandColors.lightTextTertiary;

  Color get hairline =>
      isDark ? BrandColors.darkHairline : BrandColors.lightHairline;
  Color get hairlineStrong =>
      isDark ? BrandColors.darkHairlineStrong : BrandColors.lightHairlineStrong;

  Color get blue => isDark ? BrandColors.blue : BrandColors.blueLight;
  Color get green => isDark ? BrandColors.green : BrandColors.greenLight;
  Color get amber => isDark ? BrandColors.amber : BrandColors.amberLight;
  Color get red => isDark ? BrandColors.red : BrandColors.redLight;

  Color get blueTint =>
      isDark ? BrandColors.blueTintDark : BrandColors.blueTintLight;
  Color get greenTint =>
      isDark ? BrandColors.greenTintDark : BrandColors.greenTintLight;
  Color get amberTint =>
      isDark ? BrandColors.amberTintDark : BrandColors.amberTintLight;
  Color get redTint =>
      isDark ? BrandColors.redTintDark : BrandColors.redTintLight;
  Color get neutralTint =>
      isDark ? const Color(0x1FFFFFFF) : const Color(0x0C000000);
}

Color toneColor(SnapshotTone tone, [bool isDark = true]) => switch (tone) {
      SnapshotTone.good => isDark ? BrandColors.green : BrandColors.greenLight,
      SnapshotTone.warning => isDark ? BrandColors.amber : BrandColors.amberLight,
      SnapshotTone.danger => isDark ? BrandColors.red : BrandColors.redLight,
      SnapshotTone.info => isDark ? BrandColors.blue : BrandColors.blueLight,
      SnapshotTone.neutral => isDark ? BrandColors.blueBright : BrandColors.blueLight,
    };

Color toneTint(SnapshotTone tone, [bool isDark = true]) => switch (tone) {
      SnapshotTone.good =>
        isDark ? BrandColors.greenTintDark : BrandColors.greenTintLight,
      SnapshotTone.warning =>
        isDark ? BrandColors.amberTintDark : BrandColors.amberTintLight,
      SnapshotTone.danger =>
        isDark ? BrandColors.redTintDark : BrandColors.redTintLight,
      SnapshotTone.info =>
        isDark ? BrandColors.blueTintDark : BrandColors.blueTintLight,
      SnapshotTone.neutral =>
        isDark ? const Color(0x1CFFFFFF) : const Color(0x0C000000),
    };
