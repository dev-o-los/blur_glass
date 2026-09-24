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

/// Live status + controls. Dark-only, minimal, native macOS utility.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: StreamBuilder<AttentionSnapshot>(
              stream: controller.snapshots,
              initialData: controller.currentSnapshot,
              builder: (context, snapshot) {
                final state = snapshot.data;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _Header(onSettings: () => _openSettings(context)),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 24),
                      _StatusHero(state: state),
                      const SizedBox(height: 24),
                      _PrimaryAction(controller: controller, state: state),
                      const SizedBox(height: 24),
                      _StatusStrip(state: state),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x66000000),
      builder: (_) => const _SettingsDialog(),
    );
  }
}

/// Compact header: mark + name/tagline left, gear right.
class _Header extends StatelessWidget {
  const _Header({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blur Glass',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 1),
              Text(
                'Screen privacy, naturally.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined, size: 20),
        ),
      ],
    );
  }
}

/// Centered protection state: small icon, heading, one supporting line.
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
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tone = state?.tone ?? SnapshotTone.neutral;
    final color = toneColor(tone);
    final tint = toneTint(tone);

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _heroIcon,
            size: 22,
            color: color,
          ),
        ),
        const SizedBox(height: 16),
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  IconData get _heroIcon {
    final s = state;
    return switch (s?.state) {
      'owner' => Icons.shield_outlined,
      'extraFace' => Icons.groups_rounded,
      'stranger' => Icons.person_off_outlined,
      'noFace' => Icons.directions_walk_rounded,
      'lookAway' => Icons.visibility_off_outlined,
      'enrolling' => Icons.face_retouching_natural_rounded,
      'error' => Icons.error_outline_rounded,
      _ => Icons.shield_outlined,
    };
  }
}

/// The one prominent action: full-width blue button, play/pause glyph.
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.controller, required this.state});

  final PrivacyController controller;
  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final protecting = state != null && state!.state != 'idle';
    final hasTemplate = controller.currentHasTemplate;

    if (!hasTemplate) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
        onPressed: controller.redoOnboarding,
        icon: const Icon(Icons.face_retouching_natural_rounded, size: 16),
        label: const Text('Set up face recognition'),
      );
    }

    return FilledButton.icon(
      style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
      onPressed:
          protecting ? controller.stopProtection : controller.startProtection,
      icon: Icon(
        protecting ? Icons.pause_rounded : Icons.play_arrow_rounded,
        size: 18,
      ),
      label: Text(protecting ? 'Pause protection' : 'Start protection'),
    );
  }
}

/// One clean horizontal status section — subtle container, hairline divider.
class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.state});

  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final ownerMatch = s?.ownerMatch ?? false;
    return Container(
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BrandColors.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatusTile(
              icon: Icons.monitor_outlined,
              label: 'Faces in view',
              value: '${s?.faceCount ?? 0}',
            ),
          ),
          Container(width: 1, height: 48, color: BrandColors.hairline),
          Expanded(
            child: _StatusTile(
              icon: Icons.person_outline_rounded,
              label: 'Owner match',
              value: ownerMatch ? 'Yes' : 'No',
              valueColor: ownerMatch ? BrandColors.green : BrandColors.red,
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
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: BrandColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: valueColor ?? BrandColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sensitivity settings as an in-window dialog; scrolls when short.
class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  double _yaw = 22;
  double _pitch = 24;
  double _unlockMs = 350;
  double _noFaceMs = 500;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: BrandColors.surfaceRaised,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: BrandColors.hairline),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sensitivity', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Lower values protect sooner; raise them if the shield '
                'flickers.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      BlurGlassSettings.apply(
                        PrivacyController.instance!,
                        yaw: _yaw,
                        pitch: _pitch,
                        unlockMs: _unlockMs,
                        noFaceMs: _noFaceMs,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
