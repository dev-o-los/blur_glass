import 'package:flutter/material.dart';

import '../../services/privacy_controller.dart';
import '../../theme/app_colors.dart';
import '../common/brand_mark.dart';
import '../common/panel.dart';
import 'pane_scaffold.dart';

/// About: Architecture, security pledges, and local diagnostic verification.
class AboutPane extends StatelessWidget {
  const AboutPane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return PaneScaffold(
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
                const AboutPledgeRow(
                  icon: Icons.memory_rounded,
                  title: 'Apple Vision Neural Engine',
                  desc: 'Face detection and gaze inference execute 100% on-device.',
                ),
                const SizedBox(height: 10),
                const AboutPledgeRow(
                  icon: Icons.wifi_off_rounded,
                  title: 'Zero Network Activity',
                  desc: 'No cloud APIs, no telemetry, no tracking packets sent.',
                ),
                const SizedBox(height: 10),
                const AboutPledgeRow(
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

class AboutPledgeRow extends StatelessWidget {
  const AboutPledgeRow({
    super.key,
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
