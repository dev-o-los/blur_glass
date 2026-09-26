import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'attention_snapshot.dart';

/// Global theme controller to toggle Light, Dark, or System mode.
class ThemeController extends ChangeNotifier {
  ThemeController({ThemeMode initialMode = ThemeMode.system})
      : _themeMode = initialMode;

  static final ThemeController instance = ThemeController();

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }
}

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
      sliderTheme: _sliderTheme(blue, isDark: false),
      dialogTheme: _dialogTheme(isDark: false),
      dividerTheme: const DividerThemeData(
        color: BrandColors.lightHairline,
        thickness: 1,
        space: 1,
      ),
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
      onSecondary: BrandColors.darkCanvas,
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
      sliderTheme: _sliderTheme(blue, isDark: true),
      dialogTheme: _dialogTheme(isDark: true),
      dividerTheme: const DividerThemeData(
        color: BrandColors.darkHairline,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(Color blue) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
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
            isDark ? const Color(0x14FFFFFF) : const Color(0x08000000),
        side: BorderSide(
          color: isDark
              ? BrandColors.darkHairlineStrong
              : BrandColors.lightHairlineStrong,
        ),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.05,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Color blue) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: blue,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.05,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    );
  }

  static SliderThemeData _sliderTheme(Color blue, {required bool isDark}) {
    return SliderThemeData(
      activeTrackColor: blue,
      inactiveTrackColor: isDark
          ? const Color(0x28FFFFFF)
          : const Color(0x18000000),
      thumbColor: Colors.white,
      overlayColor: blue.withValues(alpha: 0.12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 7,
        elevation: 2,
        pressedElevation: 3,
      ),
    );
  }

  static DialogThemeData _dialogTheme({required bool isDark}) {
    return DialogThemeData(
      backgroundColor:
          isDark ? const Color(0xFF22242B) : const Color(0xFFFFFFFF),
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: BorderSide(
          color: isDark
              ? BrandColors.darkHairlineStrong
              : BrandColors.lightHairlineStrong,
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

/// A raised macOS container card that automatically responds to light and dark theme.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
    this.backgroundColor,
    this.borderColor,
    this.blur = 0.0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? colors.hairline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A high-fidelity brand mark representing the Privacy Iris lens.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: BrandColors.markGradient,
        ),
        borderRadius: BorderRadius.circular(size * 0.225),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 0.75,
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.blueDark.withValues(alpha: 0.35),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ApertureIrisPainter(),
      ),
    );
  }
}

class _ApertureIrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawCircle(center, radius * 0.76, ringPaint);

    final dotPaint = Paint()..color = Colors.white;
    const dotCount = 8;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * math.pi / dotCount) - (math.pi / 2);
      final dotPos = Offset(
        center.dx + math.cos(angle) * (radius * 0.52),
        center.dy + math.sin(angle) * (radius * 0.52),
      );
      canvas.drawCircle(dotPos, radius * 0.09, dotPaint);
    }

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + (math.pi / 4);
      final sparklePos = Offset(
        center.dx + math.cos(angle) * (radius * 0.74),
        center.dy + math.sin(angle) * (radius * 0.74),
      );
      canvas.drawCircle(
        sparklePos,
        radius * 0.055,
        dotPaint..color = Colors.white.withValues(alpha: 0.9),
      );
    }

    canvas.drawCircle(center, radius * 0.14, dotPaint..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A crisp, vector-based macOS Protection Halo & Scanning Radar.
class HaloRings extends StatefulWidget {
  const HaloRings({
    super.key,
    required this.child,
    this.size = 224,
    this.accent = BrandColors.blue,
    this.isPulsing = true,
  });

  final Widget child;
  final double size;
  final Color accent;
  final bool isPulsing;

  @override
  State<HaloRings> createState() => _HaloRingsState();
}

class _HaloRingsState extends State<HaloRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RadarHaloPainter(
                  accent: widget.accent,
                  pulseProgress: widget.isPulsing ? progress : 0.0,
                  isDark: isDark,
                ),
              ),
              Container(
                width: widget.size * 0.58,
                height: widget.size * 0.58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.heroCore,
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.85),
                    width: 3.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accent.withValues(alpha: isDark ? 0.3 : 0.2),
                      blurRadius: 24,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: widget.child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RadarHaloPainter extends CustomPainter {
  _RadarHaloPainter({
    required this.accent,
    required this.pulseProgress,
    required this.isDark,
  });

  final Color accent;
  final double pulseProgress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: isDark ? 0.16 : 0.12),
          accent.withValues(alpha: isDark ? 0.04 : 0.02),
          Colors.transparent,
        ],
        stops: const [0.4, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, glowPaint);

    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = accent.withValues(alpha: isDark ? 0.18 : 0.22);
    canvas.drawCircle(center, maxRadius * 0.95, outerRing);

    final midRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = accent.withValues(alpha: isDark ? 0.12 : 0.16);
    canvas.drawCircle(center, maxRadius * 0.78, midRing);

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: isDark ? 0.28 : 0.35);

    const tickCount = 36;
    for (int i = 0; i < tickCount; i++) {
      final angle = i * (2 * math.pi / tickCount);
      final isMajor = i % 9 == 0;
      final tickLength = isMajor ? 6.0 : 3.0;
      final rOuter = maxRadius * 0.95;
      final rInner = rOuter - tickLength;

      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * rInner,
            center.dy + math.sin(angle) * rInner),
        Offset(center.dx + math.cos(angle) * rOuter,
            center.dy + math.sin(angle) * rOuter),
        isMajor
            ? (tickPaint
              ..strokeWidth = 1.8
              ..color = accent.withValues(alpha: isDark ? 0.45 : 0.55))
            : (tickPaint
              ..strokeWidth = 1.0
              ..color = accent.withValues(alpha: isDark ? 0.2 : 0.25)),
      );
    }

    if (pulseProgress > 0) {
      final waveRadius = (maxRadius * 0.58) +
          ((maxRadius * 0.92 - maxRadius * 0.58) * pulseProgress);
      final waveOpacity = (1.0 - pulseProgress).clamp(0.0, 1.0) * 0.45;
      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accent.withValues(alpha: waveOpacity);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarHaloPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.pulseProgress != pulseProgress ||
      oldDelegate.isDark != isDark;
}
