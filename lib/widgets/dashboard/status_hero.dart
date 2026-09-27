import 'package:flutter/material.dart';

import '../../models/attention_snapshot.dart';
import '../../theme/app_colors.dart';
import '../common/halo_rings.dart';

/// Centered halo + animated status heading + status capsule.
class StatusHero extends StatelessWidget {
  const StatusHero({super.key, required this.state});

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
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...previousChildren
                      .where((child) => child.key != currentChild?.key),
                  ?currentChild,
                ],
              );
            },
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
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ...previousChildren
                    .where((child) => child.key != currentChild?.key),
                ?currentChild,
              ],
            );
          },
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
