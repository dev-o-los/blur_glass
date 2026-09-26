import 'package:flutter/material.dart';

import '../../services/privacy_controller.dart';
import '../../theme/app_colors.dart';
import '../common/panel.dart';
import 'wizard_footer.dart';

class CameraStep extends StatelessWidget {
  const CameraStep({
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
              Text(
                'Camera access',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Blur Glass needs the camera to know when you are at the Mac. '
                'Frames are analyzed in memory and discarded immediately — '
                'nothing is ever recorded.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BrandColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 20),
              Panel(
                padding: const EdgeInsets.all(22),
                borderRadius: 12,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: authorized
                            ? BrandColors.greenTint
                            : blocked
                                ? BrandColors.amberTint
                                : BrandColors.blueTint,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: authorized
                              ? BrandColors.green.withValues(alpha: 0.4)
                              : blocked
                                  ? BrandColors.amber.withValues(alpha: 0.4)
                                  : BrandColors.blue.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        authorized
                            ? Icons.check_rounded
                            : blocked
                                ? Icons.error_outline_rounded
                                : Icons.videocam_outlined,
                        size: 24,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: BrandColors.textSecondary,
                          ),
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
              WizardFooter(
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: BrandColors.textTertiary,
                      ),
                ),
            ],
          ),
        );
      },
    );
  }
}
