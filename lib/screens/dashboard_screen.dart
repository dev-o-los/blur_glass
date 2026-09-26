import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../attention_snapshot.dart';
import '../privacy_controller.dart';
import '../theme.dart';

/// Applies sensitivity values to the native engine via the controller.
class BlurGlassSettings {
  static void apply(
    PrivacyController controller, {
    required double yaw,
    required double pitch,
    required double unlockMs,
    required double noFaceMs,
  }) {
    controller.setConfig(
      yawDegrees: yaw,
      pitchDegrees: pitch,
      unlockMs: unlockMs,
      noFaceLockMs: noFaceMs,
    );
  }
}

enum _Pane { home, settings, about }

/// Live status + controls, framed by a high-end macOS-style sidebar:
/// Home (status + start), Settings (sensitivity + appearance), About.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _Pane _pane = _Pane.home;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sidebar(
            selected: _pane,
            onSelect: (pane) => setState(() => _pane = pane),
            controller: widget.controller,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colors.hairline,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: switch (_pane) {
                _Pane.home => _HomePane(
                    key: const ValueKey('home'),
                    controller: widget.controller,
                  ),
                _Pane.settings => _SettingsPane(
                    key: const ValueKey('settings'),
                    controller: widget.controller,
                  ),
                _Pane.about => _AboutPane(
                    key: const ValueKey('about'),
                    controller: widget.controller,
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation sidebar styled to macOS standards.
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selected,
    required this.onSelect,
    required this.controller,
  });

  final _Pane selected;
  final ValueChanged<_Pane> onSelect;
  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;

    return SizedBox(
      width: 216,
      child: Container(
        color: colors.sidebar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safe margin for macOS window traffic lights
            const SizedBox(height: 44),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const BrandMark(size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blur Glass',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: colors.textPrimary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Screen privacy, naturally.',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.textTertiary,
                                fontSize: 10.5,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.shield_outlined,
                    activeIcon: Icons.shield_rounded,
                    label: 'Home',
                    selected: selected == _Pane.home,
                    onTap: () => onSelect(_Pane.home),
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.tune_rounded,
                    activeIcon: Icons.tune_rounded,
                    label: 'Settings',
                    selected: selected == _Pane.settings,
                    onTap: () => onSelect(_Pane.settings),
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.info_outline_rounded,
                    activeIcon: Icons.info_rounded,
                    label: 'About',
                    selected: selected == _Pane.about,
                    onTap: () => onSelect(_Pane.about),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Live engine status widget
            Padding(
              padding: const EdgeInsets.all(12),
              child: StreamBuilder<AttentionSnapshot>(
                stream: controller.snapshots,
                initialData: controller.currentSnapshot,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final protected = state?.isShielded ?? false;
                  final tone = state?.tone ?? SnapshotTone.neutral;
                  final accent = toneColor(tone, isDark);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x18FFFFFF)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.hairline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              protected ? 'SCREEN FROSTED' : 'SCREEN VISIBLE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          protected
                              ? 'Screen status · Blurred'
                              : 'Screen status · Visible',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive sidebar item with smooth hover transition.
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selected = widget.selected;
    final color = selected
        ? (colors.isDark ? Colors.white : colors.blue)
        : (_hovered ? colors.textPrimary : colors.textSecondary);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? (colors.isDark
                    ? BrandColors.blue.withValues(alpha: 0.85)
                    : colors.blue.withValues(alpha: 0.12))
                : (_hovered
                    ? (colors.isDark
                        ? const Color(0x14FFFFFF)
                        : const Color(0x0A000000))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: selected && colors.isDark
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.75,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? widget.activeIcon : widget.icon,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: color,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared pane layout wrapper.
class _PaneScaffold extends StatelessWidget {
  const _PaneScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.maxWidth = 620,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return LayoutBuilder(
      builder: (context, viewport) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: math.max(0, viewport.maxHeight - 44),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: colors.textPrimary,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home: Protection Center with live radar visualizer and telemetry metrics.
class _HomePane extends StatelessWidget {
  const _HomePane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return _PaneScaffold(
      title: 'Screen Privacy',
      subtitle: 'Automatically blur your screen when you look away.',
      maxWidth: 620,
      child: StreamBuilder<AttentionSnapshot>(
        stream: controller.snapshots,
        initialData: controller.currentSnapshot,
        builder: (context, snapshot) {
          final state = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Panel(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusHero(state: state),
                    const SizedBox(height: 20),
                    _PrimaryAction(controller: controller, state: state),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _TelemetryGrid(state: state),
            ],
          );
        },
      ),
    );
  }
}

/// Centered halo + animated status heading + status capsule.
class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.state});

  final AttentionSnapshot? state;

  String get _title {
    final s = state;
    if (s == null) return 'Protection is off';
    return switch (s.state) {
      'owner' => 'Protection is on',
      'extraFace' => 'Extra face detected',
      'stranger' => 'Unrecognized face',
      'noFace' => 'You left the frame',
      'lookAway' => 'Looking away',
      'enrolling' => 'Learning your face',
      'error' => 'Camera error',
      _ => 'Protection is off',
    };
  }

  String get _subtitle {
    final s = state;
    if (s == null) {
      return 'Turn on protection to automatically blur your screen when you '
          'look away.';
    }
    if (s.message.isNotEmpty) return s.message;
    return switch (s.state) {
      'owner' => 'Your screen is visible only to you.',
      'noFace' => 'The screen is blurred until you come back.',
      'lookAway' => 'The screen is blurred while your gaze is away.',
      _ => 'The screen is blurred for your privacy.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tone = state?.tone ?? SnapshotTone.neutral;
    final accent = toneColor(tone, colors.isDark);
    final isProtecting = state != null && state!.state != 'idle';

    return Column(
      children: [
        HaloRings(
          size: 156,
          accent: accent,
          isPulsing: isProtecting,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              _heroIcon,
              key: ValueKey(_heroIcon),
              size: 48,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _title,
            key: ValueKey(_title),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 21,
                  letterSpacing: -0.3,
                  color: colors.textPrimary,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                fontSize: 13,
              ),
        ),
      ],
    );
  }

  IconData get _heroIcon {
    final s = state;
    return switch (s?.state) {
      'owner' => Icons.verified_user_rounded,
      'extraFace' => Icons.groups_rounded,
      'stranger' => Icons.person_off_rounded,
      'noFace' => Icons.directions_walk_rounded,
      'lookAway' => Icons.visibility_off_rounded,
      'enrolling' => Icons.face_retouching_natural_rounded,
      'error' => Icons.error_outline_rounded,
      _ => Icons.shield_rounded,
    };
  }
}

/// Primary button styled with tactile macOS feel and comfortable width.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.controller, required this.state});

  final PrivacyController controller;
  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final enrolling = state?.state == 'enrolling';
    final protecting = state != null && state!.state != 'idle' && !enrolling;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: protecting
                  ? (colors.isDark
                      ? const Color(0xFF33353E)
                      : const Color(0xFFE2E4E9))
                  : colors.blue,
              foregroundColor: protecting
                  ? (colors.isDark ? Colors.white : colors.textPrimary)
                  : Colors.white,
              elevation: protecting ? 0 : 2,
              shadowColor: colors.blue.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            onPressed: enrolling
                ? null
                : protecting
                    ? controller.stopProtection
                    : controller.startProtection,
            icon: Icon(
              protecting
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              size: 20,
            ),
            label: Text(
              protecting ? 'Pause protection' : 'Start protection',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3-card telemetry grid showing live security metrics.
class _TelemetryGrid extends StatelessWidget {
  const _TelemetryGrid({required this.state});

  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final blurred = s?.isShielded ?? false;
    final faceCount = s?.faceCount ?? 0;
    final yaw = s?.yaw;
    final pitch = s?.pitch;

    String gazeText = 'Centered';
    if (yaw != null && pitch != null) {
      if (yaw.abs() > 18 || pitch.abs() > 20) {
        gazeText = 'Averted';
      }
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.person_outline_rounded,
            label: 'Faces in view',
            value: '$faceCount',
            badgeText: faceCount == 1 ? 'Owner locked' : (faceCount > 1 ? 'Multiple' : 'None'),
            badgeColor: faceCount == 1
                ? BrandColors.green
                : (faceCount > 1 ? BrandColors.red : BrandColors.darkTextTertiary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.visibility_outlined,
            label: 'Screen status',
            value: blurred ? 'Blurred' : 'Visible',
            badgeText: blurred ? 'Shield on' : 'Clear',
            badgeColor: blurred ? BrandColors.blue : BrandColors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.remove_red_eye_outlined,
            label: 'Gaze direction',
            value: gazeText,
            badgeText: yaw != null ? '${yaw.abs().toStringAsFixed(0)}° yaw' : 'Tracking',
            badgeColor: gazeText == 'Centered' ? BrandColors.blue : BrandColors.amber,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String badgeText;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: colors.textSecondary),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textTertiary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: colors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Settings Pane: Grouped macOS Cards with sensitivity sliders, appearance toggle, and biometric tools.
class _SettingsPane extends StatefulWidget {
  const _SettingsPane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<_SettingsPane> createState() => _SettingsPaneState();
}

class _SettingsPaneState extends State<_SettingsPane> {
  double _yaw = 22;
  double _pitch = 24;
  double _unlockMs = 350;
  double _noFaceMs = 500;
  bool _saved = false;

  void _apply() {
    BlurGlassSettings.apply(
      widget.controller,
      yaw: _yaw,
      pitch: _pitch,
      unlockMs: _unlockMs,
      noFaceMs: _noFaceMs,
    );
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _setPreset(String name) {
    setState(() {
      if (name == 'sensitive') {
        _yaw = 15;
        _pitch = 16;
        _unlockMs = 250;
        _noFaceMs = 300;
      } else if (name == 'relaxed') {
        _yaw = 32;
        _pitch = 34;
        _unlockMs = 600;
        _noFaceMs = 900;
      } else {
        _yaw = 22;
        _pitch = 24;
        _unlockMs = 350;
        _noFaceMs = 500;
      }
    });
    _apply();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasTemplate = widget.controller.currentHasTemplate;

    return _PaneScaffold(
      title: 'Settings',
      subtitle: 'Fine-tune attention sensitivity, theme mode, and screen lock timing.',
      maxWidth: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              // Appearance Card (Theme Toggle)
              Panel(
                padding: const EdgeInsets.all(20),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select a light or dark theme, or sync with macOS system appearance.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    ListenableBuilder(
                      listenable: ThemeController.instance,
                      builder: (context, _) {
                        final currentMode = ThemeController.instance.themeMode;
                        return Row(
                          children: [
                            Expanded(
                              child: _ThemeModeTile(
                                title: 'Light',
                                icon: Icons.light_mode_rounded,
                                selected: currentMode == ThemeMode.light,
                                onTap: () => ThemeController.instance
                                    .setThemeMode(ThemeMode.light),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ThemeModeTile(
                                title: 'Dark',
                                icon: Icons.dark_mode_rounded,
                                selected: currentMode == ThemeMode.dark,
                                onTap: () => ThemeController.instance
                                    .setThemeMode(ThemeMode.dark),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ThemeModeTile(
                                title: 'System',
                                icon: Icons.brightness_auto_rounded,
                                selected: currentMode == ThemeMode.system,
                                onTap: () => ThemeController.instance
                                    .setThemeMode(ThemeMode.system),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Presets selector
              Row(
                children: [
                  Text(
                    'SENSITIVITY PRESETS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: colors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  _PresetChip(label: 'Sensitive', onTap: () => _setPreset('sensitive')),
                  const SizedBox(width: 6),
                  _PresetChip(label: 'Balanced', onTap: () => _setPreset('balanced')),
                  const SizedBox(width: 6),
                  _PresetChip(label: 'Relaxed', onTap: () => _setPreset('relaxed')),
                ],
              ),
              const SizedBox(height: 10),
              // Sensitivity Card
              Panel(
                padding: const EdgeInsets.all(20),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Look-Away Sensitivity',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lower angular thresholds engage blur sooner when turning your head.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    _sliderRow(
                      label: 'Look-away yaw threshold',
                      value: _yaw,
                      min: 10,
                      max: 40,
                      format: (v) => '${v.toStringAsFixed(0)}°',
                      onChanged: (v) => setState(() => _yaw = v),
                    ),
                    Divider(color: colors.hairline, height: 20),
                    _sliderRow(
                      label: 'Look-away pitch threshold',
                      value: _pitch,
                      min: 10,
                      max: 40,
                      format: (v) => '${v.toStringAsFixed(0)}°',
                      onChanged: (v) => setState(() => _pitch = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Timing Card
              Panel(
                padding: const EdgeInsets.all(20),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hysteresis & Timing',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prevents screen flickering during natural blinks and micro-movements.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    _sliderRow(
                      label: 'Unlock delay',
                      value: _unlockMs,
                      min: 150,
                      max: 1000,
                      format: (v) => '${v.toStringAsFixed(0)} ms',
                      onChanged: (v) => setState(() => _unlockMs = v),
                    ),
                    Divider(color: colors.hairline, height: 20),
                    _sliderRow(
                      label: 'No-face grace period',
                      value: _noFaceMs,
                      min: 200,
                      max: 1500,
                      format: (v) => '${v.toStringAsFixed(0)} ms',
                      onChanged: (v) => setState(() => _noFaceMs = v),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _apply,
                        icon: Icon(
                          _saved ? Icons.check_rounded : Icons.save_outlined,
                          size: 16,
                        ),
                        label: Text(_saved ? 'Applied' : 'Apply'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Biometric Enrollment Card
              Panel(
                padding: const EdgeInsets.all(18),
                borderRadius: 12,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.blueTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.face_retouching_natural_rounded,
                        size: 22,
                        color: colors.blue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owner face biometric template',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasTemplate
                                ? 'Encrypted and stored in macOS Keychain on this Mac.'
                                : 'No face template registered — complete setup to enroll.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (hasTemplate)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BrandColors.red,
                          side: BorderSide(
                            color: BrandColors.red.withValues(alpha: 0.4),
                          ),
                        ),
                        onPressed: _confirmRemoveTemplate,
                        child: const Text('Remove'),
                      )
                    else
                      FilledButton(
                        onPressed: widget.controller.redoOnboarding,
                        child: const Text('Set up'),
                      ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  void _confirmRemoveTemplate() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove face template?'),
        content: const Text(
          'Blur Glass will forget your face and return to setup. Protection '
          'cannot run without a verified template.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BrandColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.clearOwner();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
  }) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.isDark
                    ? const Color(0x18FFFFFF)
                    : const Color(0x0C000000),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                format(value),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.blue,
                      fontSize: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 5).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ThemeModeTile extends StatefulWidget {
  const _ThemeModeTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeModeTile> createState() => _ThemeModeTileState();
}

class _ThemeModeTileState extends State<_ThemeModeTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;
    final selected = widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? colors.blue.withValues(alpha: isDark ? 0.20 : 0.12)
                : (_hovered
                    ? (isDark
                        ? const Color(0x18FFFFFF)
                        : const Color(0x0C000000))
                    : (isDark
                        ? const Color(0x0EFFFFFF)
                        : const Color(0x06000000))),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? colors.blue
                  : (isDark ? BrandColors.darkHairline : BrandColors.lightHairline),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: selected ? colors.blue : colors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? colors.blue : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.isDark
              ? const Color(0x14FFFFFF)
              : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.hairline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// About: Architecture, security pledges, and local diagnostic verification.
class _AboutPane extends StatelessWidget {
  const _AboutPane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return _PaneScaffold(
      title: 'About Blur Glass',
      subtitle: 'Version 1.0.0 (Build 2026.1) • Apple Silicon & Intel Native',
      maxWidth: 620,
      child: Column(
        children: [
              const SizedBox(height: 8),
              const BrandMark(size: 64),
              const SizedBox(height: 16),
              Text(
                'Blur Glass',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Screen privacy, naturally.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              Panel(
                padding: const EdgeInsets.all(18),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: BrandColors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'On-Device Privacy Guarantees',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _AboutPledgeRow(
                      icon: Icons.memory_rounded,
                      title: 'Apple Vision Neural Engine',
                      desc: 'Face detection and gaze inference execute 100% on-device.',
                    ),
                    const SizedBox(height: 10),
                    const _AboutPledgeRow(
                      icon: Icons.wifi_off_rounded,
                      title: 'Zero Network Activity',
                      desc: 'No cloud APIs, no telemetry, no tracking packets sent.',
                    ),
                    const SizedBox(height: 10),
                    const _AboutPledgeRow(
                      icon: Icons.layers_outlined,
                      title: 'GPU-Accelerated Shield',
                      desc: 'Metal & ScreenCaptureKit provide instantaneous frosted glass coverage.',
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}

class _AboutPledgeRow extends StatelessWidget {
  const _AboutPledgeRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
