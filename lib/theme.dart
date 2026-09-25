import 'package:flutter/material.dart';

import 'attention_snapshot.dart';

/// Blur Glass palette — dark mode only.
///
/// Charcoal surfaces, white primary text, muted gray secondary text,
/// macOS system blue as the single accent.
abstract final class BrandColors {
  // macOS system blue (dark appearance).
  static const blue = Color(0xFF0A84FF);

  // Lighter blue for selected sidebar labels on tinted fills.
  static const blueBright = Color(0xFF6DB2FF);

  // Backgrounds — near-black canvas, raised charcoal surfaces.
  static const canvas = Color(0xFF161618);
  static const surface = Color(0xFF232326);
  static const surfaceRaised = Color(0xFF2C2C2F);

  // Deep navy core of the protection halo.
  static const heroCore = Color(0xFF0B1A2E);

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

  /// The brand-mark gradient, mirrored by the macOS app icon.
  static const markGradient = [
    Color(0xFF33A0FF),
    Color(0xFF0A72F0),
  ];
}

/// Maps a snapshot tone to its restrained accent color.
Color toneColor(SnapshotTone tone) => switch (tone) {
      SnapshotTone.good => BrandColors.green,
      SnapshotTone.warning => BrandColors.amber,
      SnapshotTone.danger => BrandColors.red,
      SnapshotTone.info => BrandColors.blue,
      SnapshotTone.neutral => BrandColors.blueBright,
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

/// Paints the white dot grid (iris) inside the blue brand mark.
class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final center = Offset(size.width / 2, size.height / 2);
    final u = size.shortestSide; // unit scale

    void dot(Offset c, double r) => canvas.drawCircle(c, r * u, paint);

    // Center dot.
    dot(center, 0.08);

    // Inner ring of eight dots.
    for (var i = 0; i < 8; i++) {
      final angle = -90.0 + i * 45.0;
      final c = center + Offset.fromDirection(angle * 3.14159265 / 180, 0.24 * u);
      dot(c, 0.055);
    }

    // Four small outer dots on the diagonals — the "iris" sparkle.
    for (final angleDeg in const [45.0, 135.0, 225.0, 315.0]) {
      final c =
          center + Offset.fromDirection(angleDeg * 3.14159265 / 180, 0.375 * u);
      dot(c, 0.032);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The app mark: a rounded blue square (Apple-squircle radius) with the
/// white dotted iris. Matches the macOS app icon.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: BrandColors.markGradient,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: CustomPaint(painter: _DottedGridPainter()),
    );
  }
}

/// The protection halo: soft outer glow, a faint ring, and a crisp
/// blue ring around a deep navy core holding the state glyph.
class HaloRings extends StatelessWidget {
  const HaloRings({
    super.key,
    required this.child,
    this.size = 224,
    this.accent = BrandColors.blue,
  });

  final Widget child;
  final double size;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft radial glow behind everything.
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.16),
                  accent.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.5, 0.78, 1.0],
              ),
            ),
          ),
          // Faint outer ring.
          Container(
            width: size * 0.97,
            height: size * 0.97,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.12)),
            ),
          ),
          // Crisp blue ring around the navy core.
          Container(
            width: size * 0.68,
            height: size * 0.68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BrandColors.heroCore,
              border: Border.all(color: accent, width: 5),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ],
      ),
    );
  }
}
