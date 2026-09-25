import 'dart:async';

import 'package:flutter/material.dart';

import '../privacy_controller.dart';
import '../theme.dart';

/// First-run flow, built like a native macOS setup assistant:
///
/// 1. Welcome — what Blur Glass is, before asking for anything.
/// 2. How it works — exactly when the screen blurs.
/// 3. Camera — the system permission, with context and a recovery path.
/// 4. Verify — explains the macOS password prompt *before* it appears, then
///    captures the face template. Ends in a success state.
///
/// No system dialog is shown before the user has read what it is for.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _stepCount = 4;
  static const _stepLabels = ['Welcome', 'How it works', 'Camera', 'Verify'];

  int _step = 0;

  bool get _canGoBack => _step > 0 && _step < _stepCount - 1;

  void _next() {
    if (_step < _stepCount - 1) {
      setState(() => _step += 1);
    }
  }

  void _back() {
    if (_canGoBack) {
      setState(() => _step -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepHeader(
                step: _step,
                    stepCount: _stepCount,
                    label: _stepLabels[_step],
                    canGoBack: _canGoBack,
                    onBack: _back,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.03, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: switch (_step) {
                        0 => const _WelcomeStep(key: ValueKey(0)),
                        1 => const _HowItWorksStep(key: ValueKey(1)),
                        2 => _CameraStep(
                            key: const ValueKey(2),
                            controller: widget.controller,
                            onContinue: _next,
                          ),
                        _ => _VerifyStep(
                            key: const ValueKey(3),
                            controller: widget.controller,
                          ),
                      },
                    ),
                  ),
                  if (_step < 2) ...[
                    const SizedBox(height: 16),
                    _WizardFooter(
                      showBack: false,
                      primaryLabel: 'Continue',
                      onPrimary: _next,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
    );
  }
}

/// Caption + thin progress bar + optional back button, macOS-assistant style.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
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
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
              )
            else
              const SizedBox(width: 36),
            const Spacer(),
            Text(
              'Step ${step + 1} of $stepCount · $label',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (step + 1) / stepCount,
            minHeight: 3,
            backgroundColor: BrandColors.hairlineStrong,
            valueColor: const AlwaysStoppedAnimation(BrandColors.blue),
          ),
        ),
      ],
    );
  }
}

/// Back on the left, primary action on the right — macOS dialog convention.
class _WizardFooter extends StatelessWidget {
  const _WizardFooter({
    required this.showBack,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
  });

  final bool showBack;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool primaryEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          OutlinedButton(
            onPressed: () => Navigator.maybeOf(context)?.maybePop(),
            child: const Text('Back'),
          ),
        const Spacer(),
        FilledButton(
          onPressed: primaryEnabled ? onPrimary : null,
          child: Text(primaryLabel),
        ),
      ],
    );
  }
}

/// A feature row: quiet tinted icon chip + title + one-line explanation.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
    this.tint = BrandColors.blueTint,
    this.iconColor = BrandColors.blue,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(body, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key});

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
          TextButton(
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
          const SizedBox(height: 16),
          const Center(child: BrandMark(size: 64)),
          const SizedBox(height: 20),
          Text(
            'Blur Glass',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Your Mac, visible only to you.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: BrandColors.textSecondary,
                ),
          ),
          const SizedBox(height: 28),
          const _FeatureRow(
            icon: Icons.visibility_outlined,
            title: 'Reads attention, not video',
            body:
                'The camera is used only to check that you are present and '
                'looking at the screen.',
          ),
          const SizedBox(height: 18),
          const _FeatureRow(
            icon: Icons.blur_on_rounded,
            title: 'Blurs the entire screen',
            body:
                'When someone approaches or you look away, a frosted layer '
                'covers everything — over every app — until it is you again.',
          ),
          const SizedBox(height: 18),
          const _FeatureRow(
            icon: Icons.lock_outline_rounded,
            title: 'Private by design',
            body:
                'Your face template never leaves this Mac. No cloud, no '
                'analytics, no recordings.',
          ),
          const SizedBox(height: 24),
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

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'When does the screen blur?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Blur Glass watches for three situations. In each one, the whole '
            'screen turns into frosted glass until it recognizes you again.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const _FeatureRow(
            icon: Icons.groups_rounded,
            title: 'Someone appears behind you',
            body:
                'A second face entering the camera blurs the screen '
                'instantly — even if you are still looking at it.',
            tint: BrandColors.redTint,
            iconColor: BrandColors.red,
          ),
          const SizedBox(height: 18),
          const _FeatureRow(
            icon: Icons.visibility_off_outlined,
            title: 'You look away for too long',
            body:
                'Gaze drifting off the display — to the side, up or down — '
                'settles the frost in after a moment.',
            tint: BrandColors.amberTint,
            iconColor: BrandColors.amber,
          ),
          const SizedBox(height: 18),
          const _FeatureRow(
            icon: Icons.directions_walk_rounded,
            title: 'You step away',
            body:
                'No face, no content. The screen stays blurred until you '
                'sit back down.',
            tint: BrandColors.neutralTint,
            iconColor: BrandColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrandColors.blueTint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BrandColors.hairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 18, color: BrandColors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The frost lifts automatically the moment Blur Glass '
                    'recognizes you again — no clicking required.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrandColors.neutralTint,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BrandColors.hairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.face_outlined,
                    size: 18, color: BrandColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'One-time face enrollment is required. It is how Blur '
                    'Glass tells you apart from everyone else — without it, '
                    'protection cannot run.',
                    style: Theme.of(context).textTheme.bodySmall,
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

class _CameraStep extends StatelessWidget {
  const _CameraStep({
    super.key,
    required this.controller,
    required this.onContinue,
  });

  final PrivacyController controller;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: controller.permission,
      initialData: controller.currentPermission,
      builder: (context, snapshot) {
        final status = snapshot.data ?? 'notDetermined';
        final authorized = status == 'authorized';
        final blocked = status == 'denied' || status == 'restricted';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Camera access', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Blur Glass needs the camera to know when you are at the Mac. '
                'Frames are analyzed in memory and discarded immediately — '
                'nothing is ever recorded.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Panel(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: authorized
                            ? BrandColors.greenTint
                            : blocked
                                ? BrandColors.amberTint
                                : BrandColors.blueTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        authorized
                            ? Icons.check_rounded
                            : blocked
                                ? Icons.error_outline_rounded
                                : Icons.videocam_outlined,
                        size: 22,
                        color: authorized
                            ? BrandColors.green
                            : blocked
                                ? BrandColors.amber
                                : BrandColors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      switch (status) {
                        'authorized' => 'Camera is ready',
                        'denied' || 'restricted' => 'Camera access is blocked',
                        _ => 'Waiting for permission',
                      },
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      switch (status) {
                        'authorized' =>
                          'Camera is ready. Next: a one-time face check so '
                              'Blur Glass can recognize you — this is '
                              'required before protection can start.',
                        'denied' || 'restricted' =>
                          'Camera access was declined for this app. You can '
                              'turn it back on in System Settings › Privacy & '
                              'Security › Camera.',
                        _ =>
                          'macOS will now show the standard camera permission '
                              'dialog. Choose “Allow” to continue.',
                      },
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    if (!authorized)
                      FilledButton.icon(
                        onPressed: status == 'notDetermined'
                            ? controller.requestCameraPermission
                            : controller.openCameraSettings,
                        icon: Icon(
                          status == 'notDetermined'
                              ? Icons.photo_camera_outlined
                              : Icons.settings_outlined,
                          size: 16,
                        ),
                        label: Text(
                          status == 'notDetermined'
                              ? 'Enable camera'
                              : 'Open System Settings',
                        ),
                      ),
                    if (status != 'notDetermined' && !authorized) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: controller.refresh,
                        child: const Text('Re-check after allowing'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _WizardFooter(
                showBack: true,
                primaryLabel: authorized ? 'Continue' : 'Skip for now',
                primaryEnabled: authorized,
                onPrimary: onContinue,
              ),
              const SizedBox(height: 8),
              if (!authorized)
                Text(
                  'You can grant camera access later from the menu bar icon.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The final step: explains the macOS identity prompt BEFORE showing it,
/// runs enrollment with live progress, and lands on success.
class _VerifyStep extends StatefulWidget {
  const _VerifyStep({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<_VerifyStep> createState() => _VerifyStepState();
}

class _VerifyStepState extends State<_VerifyStep> {
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
      return _SuccessBody(controller: widget.controller);
    }
    if (enrolling) {
      return _EnrollingBody(message: message, onCancel: () {
        unawaited(widget.controller.cancelEnrollment());
      });
    }
    return _VerifyIntro(controller: widget.controller);
  }
}

class _VerifyIntro extends StatelessWidget {
  const _VerifyIntro({required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Verify it\'s you', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Required before protection can start — Blur Glass must learn '
            'your face to tell you apart from a stranger. Two quick checks, '
            'about twenty seconds.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const _FeatureRow(
            icon: Icons.password_rounded,
            title: '1 · Verify with macOS',
            body:
                'The standard macOS password or Touch ID prompt will appear. '
                'It confirms that you — the Mac\'s owner — authorize Blur '
                'Glass to learn your face. Blur Glass never sees your '
                'password.',
          ),
          const SizedBox(height: 18),
          const _FeatureRow(
            icon: Icons.face_retouching_natural_rounded,
            title: '2 · Look at the camera',
            body:
                'Blur Glass captures about ten quick face samples while you '
                'sit normally. They are matched on-device and stored in '
                'Blur Glass\'s private app storage.',
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => unawaited(controller.enroll()),
            icon: const Icon(Icons.shield_outlined, size: 16),
            label: const Text('Verify with macOS'),
          ),
          const SizedBox(height: 8),
          Text(
            'You can re-run this any time from the app.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _EnrollingBody extends StatelessWidget {
  const _EnrollingBody({required this.message, required this.onCancel});

  final String? message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 24),
        Text(
          message ?? 'Learning your face…',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Sit like you normally do and keep your eyes on the screen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: BrandColors.greenTint,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, size: 36, color: BrandColors.green),
        ),
        const SizedBox(height: 20),
        Text('You\'re all set', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Your face template is saved privately on this Mac. From now on, '
          'the screen blurs whenever you\'re not the only one looking.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: controller.finishOnboarding,
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: const Text('Open Blur Glass'),
        ),
      ],
    );
  }
}
