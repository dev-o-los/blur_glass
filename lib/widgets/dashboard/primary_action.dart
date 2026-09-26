import 'package:flutter/material.dart';

import '../../models/attention_snapshot.dart';
import '../../services/privacy_controller.dart';
import '../../theme/app_colors.dart';

/// Primary button styled with tactile macOS feel and comfortable width.
class PrimaryAction extends StatelessWidget {
  const PrimaryAction({
    super.key,
    required this.controller,
    required this.state,
  });

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
