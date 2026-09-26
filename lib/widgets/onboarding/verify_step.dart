import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/privacy_controller.dart';
import '../../theme/app_colors.dart';
import '../common/halo_rings.dart';
import 'feature_row.dart';

/// Biometric verification step: explains macOS security prompt & runs on-device enrollment.
class VerifyStep extends StatefulWidget {
  const VerifyStep({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<VerifyStep> createState() => _VerifyStepState();
}

class _VerifyStepState extends State<VerifyStep> {
  StreamSubscription<bool>? _enrollmentSub;

  @override
  void initState() {
    super.initState();
    _enrollmentSub = widget.controller.enrollmentActive.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    unawaited(_enrollmentSub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrolling = widget.controller.currentEnrollment;
    final enrolled = widget.controller.currentHasTemplate;
    final message = widget.controller.currentSnapshot?.message;

    if (enrolled) {
      return SuccessBody(controller: widget.controller);
    }
    if (enrolling) {
      return EnrollingBody(
        message: message,
        onCancel: () {
          unawaited(widget.controller.cancelEnrollment());
        },
      );
    }
    return VerifyIntro(controller: widget.controller);
  }
}

class VerifyIntro extends StatelessWidget {
  const VerifyIntro({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verify it\'s you',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Required before protection can start — Blur Glass must learn '
            'your face to tell you apart from a stranger. Two quick checks, '
            'about twenty seconds.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BrandColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          const FeatureRow(
            icon: Icons.password_rounded,
            title: '1 · Verify with macOS',
            body:
                'The standard macOS password or Touch ID prompt will appear. '
                'It confirms that you — the Mac\'s owner — authorize Blur '
                'Glass to learn your face. Blur Glass never sees your '
                'password.',
          ),
          const SizedBox(height: 10),
          const FeatureRow(
            icon: Icons.face_retouching_natural_rounded,
            title: '2 · Look at the camera',
            body:
                'Blur Glass captures about ten quick face samples while you '
                'sit normally. They are matched on-device and stored in '
                'Blur Glass\'s private app storage.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => unawaited(controller.enroll()),
            icon: const Icon(Icons.shield_outlined, size: 16),
            label: const Text('Verify with macOS'),
          ),
          const SizedBox(height: 8),
          Text(
            'You can re-run this any time from the app.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: BrandColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }
}

class EnrollingBody extends StatelessWidget {
  const EnrollingBody({
    super.key,
    required this.message,
    required this.onCancel,
  });

  final String? message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HaloRings(
            size: 156,
            accent: BrandColors.blueBright,
            child: const Icon(
              Icons.face_retouching_natural_rounded,
              size: 48,
              color: BrandColors.blueBright,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message ?? 'Learning your face…',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sit like you normally do and keep your eyes on the screen.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BrandColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class SuccessBody extends StatelessWidget {
  const SuccessBody({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: BrandColors.greenTint,
              shape: BoxShape.circle,
              border: Border.all(
                color: BrandColors.green.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: BrandColors.green.withValues(alpha: 0.3),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 34,
              color: BrandColors.green,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'You\'re all set',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your face template is saved privately on this Mac. From now on, '
            'the screen blurs whenever you\'re not the only one looking.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BrandColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: controller.finishOnboarding,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Open Blur Glass'),
          ),
        ],
      ),
    );
  }
}
