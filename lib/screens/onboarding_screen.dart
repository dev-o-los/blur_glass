import 'package:flutter/material.dart';

import '../privacy_channel.dart';
import '../privacy_controller.dart';

/// First-run flow: grant camera access, verify Mac identity, enroll the owner
/// face. All capture and matching happen natively and stay on this Mac.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Hero(),
                  const SizedBox(height: 28),
                  _PermissionCard(controller: controller),
                  const SizedBox(height: 16),
                  _EnrollCard(controller: controller),
                  const SizedBox(height: 16),
                  const _PrivacyNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.tealAccent.withValues(alpha: 0.25),
                Colors.indigoAccent.withValues(alpha: 0.25),
              ],
            ),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.blur_on_rounded, size: 44, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          'Blur Glass',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your screen. Your eyes. Nobody else's.",
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: controller.permission,
      initialData: controller.currentPermission,
      builder: (context, snapshot) {
        final status = snapshot.data ?? 'notDetermined';
        return _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    status == 'authorized'
                        ? Icons.check_circle_rounded
                        : Icons.videocam_rounded,
                    color: status == 'authorized'
                        ? Colors.tealAccent
                        : Colors.white70,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Step 1 · Camera access',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                switch (status) {
                  'authorized' =>
                    'Camera is ready. Frames are processed on-device and never leave this Mac.',
                  'denied' || 'restricted' =>
                    'Camera access is blocked in System Settings. Blur Glass cannot watch for shoulder surfers without it.',
                  _ =>
                    'Blur Glass needs the camera to see when you look away or when someone else appears.',
                },
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if (status != 'authorized')
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: status == 'notDetermined'
                          ? controller.requestCameraPermission
                          : controller.openCameraSettings,
                      icon: Icon(
                        status == 'notDetermined'
                            ? Icons.photo_camera_rounded
                            : Icons.settings_rounded,
                        size: 18,
                      ),
                      label: Text(
                        status == 'notDetermined'
                            ? 'Grant camera access'
                            : 'Open System Settings',
                      ),
                    ),
                    if (status != 'notDetermined') ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: controller.refresh,
                        child: const Text('Re-check'),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EnrollCard extends StatelessWidget {
  const _EnrollCard({required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: controller.enrollmentActive,
      initialData: controller.currentEnrollment,
      builder: (context, enrollmentSnapshot) {
        final enrolling = enrollmentSnapshot.data ?? false;
        return StreamBuilder<AttentionSnapshot>(
          stream: controller.snapshots,
          initialData: controller.currentSnapshot,
          builder: (context, snap) {
            final message = snap.data?.message;
            return _GlassCard(
              child: enrolling
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message ?? 'Learning your face…',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: controller.cancelEnrollment,
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step 2 · Teach Blur Glass your face',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'After a quick Mac identity check, sit like you normally do and look at the camera. Blur Glass captures a few on-device face templates — they are stored encrypted in your Keychain and never uploaded.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: controller.enroll,
                            icon: const Icon(Icons.face_retouching_natural_rounded,
                                size: 20),
                            label: const Text('Enroll my face'),
                          ),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.lock_outline_rounded,
            size: 16, color: Colors.white.withValues(alpha: 0.45)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Face data never leaves this Mac. No cloud, no analytics, no frames stored.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.45)),
          ),
        ),
      ],
    );
  }
}
