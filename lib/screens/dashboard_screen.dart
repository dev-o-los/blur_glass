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

/// Live status + controls, framed by a macOS-style sidebar:
/// Home (status + start), Settings (sensitivity), About.
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Sidebar(
            selected: _pane,
            onSelect: (pane) => setState(() => _pane = pane),
            controller: widget.controller,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
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

/// Narrow navigation column: brand block on top, three destinations.
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
    return SizedBox(
      width: 200,
      child: Container(
        // Slightly darker fill than the content so the split reads
        // against the wallpaper, like AppKit sidebars.
        color: Colors.black.withValues(alpha: 0.18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Clear the overlay traffic lights (titlebar is transparent).
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const BrandMark(size: 44),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blur Glass',
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Screen privacy, naturally.',
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: selected == _Pane.home,
                    onTap: () => onSelect(_Pane.home),
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    selected: selected == _Pane.settings,
                    onTap: () => onSelect(_Pane.settings),
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About',
                    selected: selected == _Pane.about,
                    onTap: () => onSelect(_Pane.about),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<AttentionSnapshot>(
                stream: controller.snapshots,
                initialData: controller.currentSnapshot,
                builder: (context, snapshot) {
                  final protected = snapshot.data?.isShielded ?? false;
                  return Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: protected
                              ? BrandColors.green
                              : BrandColors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          protected
                              ? 'Screen status · Blurred'
                              : 'Screen status · Visible',
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

/// One sidebar destination — filled blue pill when selected.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? BrandColors.blueBright : BrandColors.textSecondary;
    return Material(
      color: selected ? const Color(0xFF1E3A5F) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

/// Shared pane scaffolding: title + subtitle, then a body that fills the
/// remaining height (scrolling, keeping the inset, when the window shrinks).
class _PaneScaffold extends StatelessWidget {
  const _PaneScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) => SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: viewport.maxHeight - 24),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Home: hero card with halo rings, state heading, primary action, and
/// the two-tile status strip.
class _HomePane extends StatelessWidget {
  const _HomePane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return _PaneScaffold(
      title: 'Screen Privacy',
      subtitle: 'Automatically blur your screen when you look away.',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: StreamBuilder<AttentionSnapshot>(
            stream: controller.snapshots,
            initialData: controller.currentSnapshot,
            builder: (context, snapshot) {
              final state = snapshot.data;
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BrandColors.hairline),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusHero(state: state),
                    const SizedBox(height: 24),
                    _PrimaryAction(controller: controller, state: state),
                    const SizedBox(height: 24),
                    _StatusStrip(state: state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Centered halo + heading + supporting line.
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
    final tone = state?.tone ?? SnapshotTone.neutral;
    final accent = toneColor(tone);

    return Column(
      children: [
        HaloRings(
          size: 208,
          accent: accent,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              _heroIcon,
              key: ValueKey(_heroIcon),
              size: 64,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 28),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _title,
            key: ValueKey(_title),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodyMedium,
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

/// The one prominent action: wide blue pill, play/pause glyph.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.controller, required this.state});

  final PrivacyController controller;
  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final enrolling = state?.state == 'enrolling';
    final protecting = state != null && state!.state != 'idle' && !enrolling;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 42),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
            onPressed: enrolling
                ? null // enrollment in progress; cancel happens on the wizard
                : protecting
                ? controller.stopProtection
                : controller.startProtection, // verified enable flow
            icon: Icon(
              protecting ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 20,
            ),
            label: Text(protecting ? 'Pause protection' : 'Start protection'),
          ),
        ),
      ),
    );
  }
}

/// One bordered status container with two tiles divided by a hairline.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.state});

  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final blurred = s?.isShielded ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BrandColors.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatusTile(
              icon: Icons.person_outline_rounded,
              label: 'Faces in view',
              value: '${s?.faceCount ?? 0}',
            ),
          ),
          Container(width: 1, height: 44, color: BrandColors.hairline),
          Expanded(
            child: _StatusTile(
              icon: Icons.visibility_off_outlined,
              label: 'Screen status',
              value: blurred ? 'Blurred' : 'Visible',
              dotColor: blurred ? BrandColors.blue : BrandColors.red,
              showDot: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.icon,
    required this.label,
    required this.value,
    this.dotColor,
    this.showDot = false,
  }) : valueColor = null;

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? dotColor;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: BrandColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (showDot) ...[
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor ?? BrandColors.red,
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: valueColor ?? BrandColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings: sensitivity sliders, applied on demand, plus owner-face tools.
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

  @override
  Widget build(BuildContext context) {
    final hasTemplate = widget.controller.currentHasTemplate;

    return _PaneScaffold(
      title: 'Settings',
      subtitle: 'Fine-tune when Blur Glass engages.',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Panel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sensitivity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lower values protect sooner; raise them if the shield '
                      'flickers.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    _slider(
                      label: 'Look-away yaw threshold',
                      value: _yaw,
                      min: 10,
                      max: 40,
                      format: (v) => '${v.toStringAsFixed(0)}°',
                      onChanged: (v) => setState(() => _yaw = v),
                    ),
                    _slider(
                      label: 'Look-away pitch threshold',
                      value: _pitch,
                      min: 10,
                      max: 40,
                      format: (v) => '${v.toStringAsFixed(0)}°',
                      onChanged: (v) => setState(() => _pitch = v),
                    ),
                    _slider(
                      label: 'Unlock delay',
                      value: _unlockMs,
                      min: 150,
                      max: 1000,
                      format: (v) => '${v.toStringAsFixed(0)} ms',
                      onChanged: (v) => setState(() => _unlockMs = v),
                    ),
                    _slider(
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
                      child: FilledButton(
                        onPressed: () {
                          BlurGlassSettings.apply(
                            widget.controller,
                            yaw: _yaw,
                            pitch: _pitch,
                            unlockMs: _unlockMs,
                            noFaceMs: _noFaceMs,
                          );
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Panel(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.face_retouching_natural_rounded,
                      size: 22,
                      color: BrandColors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owner face',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasTemplate
                                ? 'Your face template is saved on this Mac.'
                                : 'No face template yet — run setup to enroll.',
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
                            color: BrandColors.red.withValues(alpha: 0.5),
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
        ),
      ),
    );
  }

  void _confirmRemoveTemplate() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x66000000),
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove face template?'),
        content: const Text(
          'Blur Glass will forget your face and reopen setup. Protection '
          'cannot run without a template.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.clearOwner();
            },
            style: TextButton.styleFrom(foregroundColor: BrandColors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              format(value),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: BrandColors.blue,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 10).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// About: brand, version, and the one-paragraph privacy story.
class _AboutPane extends StatelessWidget {
  const _AboutPane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return _PaneScaffold(
      title: 'About',
      subtitle: 'Blur Glass 1.0.0',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 72),
              const SizedBox(height: 16),
              Text(
                'Blur Glass',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Screen privacy, naturally.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              const Panel(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Face matching runs entirely on this Mac with Apple\'s '
                      'Vision framework. Frames are analyzed in memory and '
                      'discarded immediately — nothing is recorded, and no '
                      'network access is used. Your face template lives in '
                      'Blur Glass\'s private, user-only app storage and can '
                      'be removed at any time from Settings.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
