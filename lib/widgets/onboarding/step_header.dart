import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// macOS assistant step progression header.
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.step,
    required this.stepCount,
    required this.label,
    required this.canGoBack,
    required this.onBack,
  });

  final int step;
  final int stepCount;
  final String label;
  final bool canGoBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (canGoBack)
              IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              )
            else
              const SizedBox(width: 28),
            const Spacer(),
            Builder(
              builder: (context) {
                final colors = AppColors.of(context);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.hairline),
                  ),
                  child: Text(
                    'Step ${step + 1} of $stepCount · $label',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (step + 1) / stepCount,
            minHeight: 3.5,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation(BrandColors.blue),
          ),
        ),
      ],
    );
  }
}
