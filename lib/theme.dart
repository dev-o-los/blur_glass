import 'package:flutter/material.dart';

import 'attention_snapshot.dart';

/// Blur Glass palette — dark mode only.
///
/// Charcoal surfaces, white primary text, muted gray secondary text,
/// macOS system blue as the single accent. No neon, no glow.
abstract final class BrandColors {
  // macOS system blue (dark appearance).
  static const blue = Color(0xFF0A84FF);

  // Backgrounds — near-black canvas, raised charcoal surfaces.
  static const canvas = Color(0xFF161618);
  static const surface = Color(0xFF232326);
  static const surfaceRaised = Color(0xFF2C2C2F);

  // Text hierarchy.
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFFA1A1A6);
  static const textTertiary = Color(0xFF6E6E73);

  // Hairlines and separators.
  static const hairline = Color(0xFF2F2F33);
  static const hairlineStrong = Color(0xFF3A3A3F);

  // Restrained semantic colors (dark-appearance Apple tones).
  static const green = Color(0xFF30D158);
  static const amber = Color(0xFFFFD60A);
  static const red = Color(0xFFFF453A);

  // Very low-chroma tints for icon chips — never full-saturation blocks.
  static const blueTint = Color(0xFF1C2733);
  static const greenTint = Color(0xFF1C2B22);
  static const amberTint = Color(0xFF2E2A1C);
  static const redTint = Color(0xFF32211F);
  static const neutralTint = Color(0xFF2A2A2E);
}

/// Maps a snapshot tone to its restrained accent color.
Color toneColor(SnapshotTone tone) => switch (tone) {
      SnapshotTone.good => BrandColors.green,
      SnapshotTone.warning => BrandColors.amber,
      SnapshotTone.danger => BrandColors.red,
      SnapshotTone.info => BrandColors.blue,
      SnapshotTone.neutral => BrandColors.textSecondary,
    };

/// Very low-chroma tint for a tone (icon chips only).
Color toneTint(SnapshotTone tone) => switch (tone) {
      SnapshotTone.good => BrandColors.greenTint,
      SnapshotTone.warning => BrandColors.amberTint,
      SnapshotTone.danger => BrandColors.redTint,
      SnapshotTone.info => BrandColors.blueTint,
      SnapshotTone.neutral => BrandColors.neutralTint,
    };

/// The Blur Glass theme — dark mode only, tuned to macOS HIG:
/// system font, Apple's dark typography ramp, hairline separators,
/// unfilled quiet buttons, and system blue reserved for the primary action.
class BlurGlassTheme {
  static ThemeData dark() {
    const blue = BrandColors.blue;
    final scheme = ColorScheme.dark(
      primary: blue,
      onPrimary: Colors.white,
      primaryContainer: BrandColors.blueTint,
      onPrimaryContainer: BrandColors.textPrimary,
      secondary: BrandColors.textSecondary,
      onSecondary: BrandColors.canvas,
      secondaryContainer: BrandColors.surfaceRaised,
      onSecondaryContainer: BrandColors.textPrimary,
      error: BrandColors.red,
      onError: Colors.white,
      errorContainer: BrandColors.redTint,
      onErrorContainer: BrandColors.textPrimary,
      surface: BrandColors.surface,
      onSurface: BrandColors.textPrimary,
      surfaceContainerLowest: BrandColors.canvas,
      surfaceContainerLow: BrandColors.surface,
      surfaceContainer: BrandColors.surface,
      surfaceContainerHigh: BrandColors.surfaceRaised,
      surfaceContainerHighest: BrandColors.surfaceRaised,
      onSurfaceVariant: BrandColors.textSecondary,
      outline: BrandColors.hairlineStrong,
      outlineVariant: BrandColors.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Transparent: the native NSVisualEffectView behind the Flutter surface
      // provides the liquid-glass backdrop (wallpaper blurred through).
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      typography: Typography.material2021(platform: TargetPlatform.macOS),
      textTheme: _textTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.08,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: blue,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.08,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandColors.textPrimary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: BrandColors.hairlineStrong),
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.08,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: blue,
        inactiveTrackColor: BrandColors.hairlineStrong,
        thumbColor: Colors.white,
        overlayColor: Color(0x1F0A84FF),
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: BrandColors.hairline,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BrandColors.surfaceRaised,
        elevation: 24,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: BrandColors.textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 13,
          height: 1.45,
          color: BrandColors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BrandColors.surfaceRaised,
        contentTextStyle: const TextStyle(
          color: BrandColors.textPrimary,
          fontSize: 13,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: BrandColors.textSecondary,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: blue,
        linearTrackColor: BrandColors.hairlineStrong,
      ),
    );
  }

  /// Apple dark-mode type ramp, slightly tightened for a compact utility.
  static TextTheme _textTheme() {
    const base = BrandColors.textPrimary;
    const secondary = BrandColors.textSecondary;
    return TextTheme(
      displaySmall: TextStyle(
          fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: base),
      headlineMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: base),
      headlineSmall: TextStyle(
          fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: base),
      titleLarge: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: base),
      titleMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: base),
      titleSmall: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.1, color: base),
      bodyLarge: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w400, height: 1.4, color: base),
      bodyMedium: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w400, height: 1.45, color: secondary),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, height: 1.4, color: secondary),
      labelLarge: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: -0.08, color: base),
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, color: BrandColors.textTertiary),
    );
  }
}

/// A raised glass surface: translucent white over the native vibrancy,
/// with a hairline border — the base container.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BrandColors.hairline),
      ),
      child: child,
    );
  }
}

/// The app mark: a rounded blue square with the blur glyph.
/// Rendered flat — no glow, no gradient.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: BrandColors.blue,
        borderRadius: BorderRadius.all(Radius.circular(9)),
      ),
      child: Icon(
        Icons.blur_on_rounded,
        size: size * 0.62,
        color: Colors.white,
      ),
    );
  }
}
