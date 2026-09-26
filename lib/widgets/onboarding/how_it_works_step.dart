import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'feature_row.dart';

class HowItWorksStep extends StatelessWidget {
  const HowItWorksStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'When does the screen blur?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Blur Glass watches for three situations. In each one, the whole '
            'screen turns into frosted glass until it recognizes you again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BrandColors.textSecondary,
                ),
          ),
          const SizedBox(height: 18),
          const FeatureRow(
            icon: Icons.groups_rounded,
            title: 'Someone appears behind you',
            body:
                'A second face entering the camera blurs the screen '
                'instantly — even if you are still looking at it.',
            tint: BrandColors.redTint,
            iconColor: BrandColors.red,
          ),
          const SizedBox(height: 10),
          const FeatureRow(
            icon: Icons.visibility_off_outlined,
            title: 'You look away for too long',
            body:
                'Gaze drifting off the display — to the side, up or down — '
                'settles the frost in after a moment.',
            tint: BrandColors.amberTint,
            iconColor: BrandColors.amber,
          ),
          const SizedBox(height: 10),
          const FeatureRow(
            icon: Icons.directions_walk_rounded,
            title: 'You step away',
            body:
                'No face, no content. The screen stays blurred until you '
                'sit back down.',
            tint: BrandColors.neutralTint,
            iconColor: BrandColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final colors = AppColors.of(context);
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.blueTint,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            size: 18, color: colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The frost lifts automatically the moment Blur Glass '
                            'recognizes you again — no clicking required.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.neutralTint,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.hairline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.face_outlined,
                            size: 18, color: colors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'One-time face enrollment is required. It is how Blur '
                            'Glass tells you apart from everyone else — without it, '
                            'protection cannot run.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
