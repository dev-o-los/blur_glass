import 'package:flutter/material.dart';

import '../../models/attention_snapshot.dart';
import '../../theme/app_colors.dart';
import 'stat_card.dart';

/// 3-card telemetry grid showing live security metrics.
class TelemetryGrid extends StatelessWidget {
  const TelemetryGrid({super.key, required this.state});

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
          child: StatCard(
            icon: Icons.person_outline_rounded,
            label: 'Faces in view',
            value: '$faceCount',
            badgeText: faceCount == 1
                ? 'Owner locked'
                : (faceCount > 1 ? 'Multiple' : 'None'),
            badgeColor: faceCount == 1
                ? BrandColors.green
                : (faceCount > 1 ? BrandColors.red : BrandColors.darkTextTertiary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.visibility_outlined,
            label: 'Screen status',
            value: blurred ? 'Blurred' : 'Visible',
            badgeText: blurred ? 'Shield on' : 'Clear',
            badgeColor: blurred ? BrandColors.blue : BrandColors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
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
