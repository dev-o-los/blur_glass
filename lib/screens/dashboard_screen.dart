import 'package:flutter/material.dart';

import '../attention_snapshot.dart';
import '../privacy_channel.dart';
import '../privacy_controller.dart';

/// Live status + controls. The native agent remains the source of truth;
/// this screen mirrors its snapshots and offers start/pause and tuning.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: StreamBuilder<AttentionSnapshot>(
                stream: controller.snapshots,
                initialData: controller.currentSnapshot,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(
                        onTune: () => _showTuningSheet(context),
                      ),
                      const SizedBox(height: 20),
                      _StatusCard(state: state),
                      const SizedBox(height: 16),
                      _StatChips(state: state),
                      const SizedBox(height: 24),
                      _Controls(controller: controller, state: state),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTuningSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101826),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TuningSheet(controller: controller),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onTune});

  final VoidCallback onTune;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              Colors.tealAccent.withValues(alpha: 0.25),
              Colors.indigoAccent.withValues(alpha: 0.25),
            ]),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.blur_on_rounded, size: 22, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Blur Glass',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text('Menu-bar agent running — look for the eye icon.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white54)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Tune sensitivity',
          onPressed: onTune,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});

  final AttentionSnapshot? state;

  Color get _accent =>
      switch (state?.tone ?? SnapshotTone.neutral) {
        SnapshotTone.good => Colors.tealAccent,
        SnapshotTone.warning => Colors.amberAccent,
        SnapshotTone.danger => Colors.redAccent,
        SnapshotTone.info => Colors.indigoAccent,
        SnapshotTone.neutral => Colors.white24,
      };

  String get _title {
    final s = state;
    if (s == null) return 'Waiting for the agent…';
    switch (s.state) {
      case 'owner':
        return 'Only you can see this screen';
      case 'extraFace':
        return 'Extra face detected';
      case 'stranger':
        return 'Unrecognized face';
      case 'noFace':
        return 'You left the frame';
      case 'lookAway':
        return 'Looking away';
      case 'enrolling':
        return 'Enrolling owner face';
      case 'error':
        return 'Camera error';
      default:
        return 'Protection is off';
    }
  }

  @override
  Widget build(BuildContext context) {
    final shielded = state?.isShielded ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _accent.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: shielded ? 0.22 : 0.10),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            shielded ? Icons.visibility_off_rounded : Icons.verified_user_rounded,
            size: 52,
            color: _accent,
          ),
          const SizedBox(height: 14),
          Text(
            _title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            state?.message ?? 'Native agent status will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _StatChips extends StatelessWidget {
  const _StatChips({required this.state});

  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    String yaw = '–';
    String pitch = '–';
    if (s?.yaw != null) yaw = '${s!.yaw!.toStringAsFixed(0)}°';
    if (s?.pitch != null) pitch = '${s!.pitch!.toStringAsFixed(0)}°';
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(label: 'Faces in view', value: '${s?.faceCount ?? 0}'),
        _StatChip(
            label: 'Owner match',
            value: (s?.ownerMatch ?? false) ? 'yes' : 'no'),
        _StatChip(label: 'Yaw', value: yaw),
        _StatChip(label: 'Pitch', value: pitch),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Colors.white54)),
          const SizedBox(width: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller, required this.state});

  final PrivacyController controller;
  final AttentionSnapshot? state;

  @override
  Widget build(BuildContext context) {
    final protecting = state != null && state!.state != 'idle';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: protecting ? Colors.white12 : null,
              foregroundColor: protecting ? Colors.white : null,
            ),
            onPressed: protecting ? controller.stopProtection : controller.startProtection,
            icon: Icon(protecting
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded),
            label: Text(protecting ? 'Pause protection' : 'Start protection'),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => _confirmReEnroll(context),
          icon: const Icon(Icons.restart_alt_rounded, size: 18),
          label: const Text('Re-enroll owner face'),
        ),
      ],
    );
  }

  void _confirmReEnroll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101826),
        title: const Text('Re-enroll owner face?'),
        content: const Text(
            'The stored face template will be deleted from the Keychain and you will run enrollment again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.clearOwner();
            },
            child: const Text('Re-enroll'),
          ),
        ],
      ),
    );
  }
}

class _TuningSheet extends StatefulWidget {
  const _TuningSheet({required this.controller});

  final PrivacyController controller;

  @override
  State<_TuningSheet> createState() => _TuningSheetState();
}

class _TuningSheetState extends State<_TuningSheet> {
  double _yaw = 22;
  double _pitch = 24;
  double _unlockMs = 350;
  double _noFaceMs = 500;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sensitivity',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Lower values protect sooner; raise them if the shield flickers.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                widget.controller.setConfig(
                  yawDegrees: _yaw,
                  pitchDegrees: _pitch,
                  unlockMs: _unlockMs,
                  noFaceLockMs: _noFaceMs,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
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
            Text(format(value),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.tealAccent)),
          ],
        ),
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
