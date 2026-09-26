import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../common/brand_mark.dart';
import 'feature_row.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  void _showPrivacyDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacy details'),
        content: const Text(
          '• Face matching runs entirely on this Mac using Apple\'s Vision '
          'framework.\n'
          '• Your face template is stored in Blur Glass\'s private, '
          'user-only app storage on this Mac — never uploaded.\n'
          '• Camera frames are analyzed in memory and immediately discarded — '
          'nothing is recorded or saved.\n'
          '• No network access is used for any part of face processing.\n'
          '• You can delete the template at any time from the app.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Center(child: BrandMark(size: 64)),
          const SizedBox(height: 16),
          Text(
            'Blur Glass',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your Mac, visible only to you.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BrandColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          const FeatureRow(
            icon: Icons.visibility_outlined,
            title: 'Reads attention, not video',
            body:
                'The camera is used only to check that you are present and '
                'looking at the screen.',
          ),
          const SizedBox(height: 10),
          const FeatureRow(
            icon: Icons.blur_on_rounded,
            title: 'Blurs the entire screen',
            body:
                'When someone approaches or you look away, a frosted layer '
                'covers everything — over every app — until it is you again.',
          ),
          const SizedBox(height: 10),
          const FeatureRow(
            icon: Icons.lock_outline_rounded,
            title: 'Private by design',
            body:
                'Your face template never leaves this Mac. No cloud, no '
                'analytics, no recordings.',
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _showPrivacyDetails(context),
              child: const Text('Read the privacy details'),
            ),
          ),
        ],
      ),
    );
  }
}
