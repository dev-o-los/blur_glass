import 'package:flutter/material.dart';

import '../services/privacy_controller.dart';
import '../widgets/onboarding/camera_step.dart';
import '../widgets/onboarding/how_it_works_step.dart';
import '../widgets/onboarding/step_header.dart';
import '../widgets/onboarding/verify_step.dart';
import '../widgets/onboarding/welcome_step.dart';
import '../widgets/onboarding/wizard_footer.dart';

/// First-run flow, styled to Apple macOS Setup Assistant standards:
///
/// 1. Welcome — what Blur Glass is, before asking for anything.
/// 2. How it works — exactly when the screen blurs.
/// 3. Camera — system permission, context and recovery paths.
/// 4. Verify — biometric setup and owner face enrollment.
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
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Safe top padding for macOS titlebar area
              const SizedBox(height: 12),
              StepHeader(
                step: _step,
                stepCount: _stepCount,
                label: _stepLabels[_step],
                canGoBack: _canGoBack,
                onBack: _back,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: switch (_step) {
                    0 => const WelcomeStep(key: ValueKey(0)),
                    1 => const HowItWorksStep(key: ValueKey(1)),
                    2 => CameraStep(
                        key: const ValueKey(2),
                        controller: widget.controller,
                        onContinue: _next,
                      ),
                    _ => VerifyStep(
                        key: const ValueKey(3),
                        controller: widget.controller,
                      ),
                  },
                ),
              ),
              if (_step < 2) ...[
                const SizedBox(height: 16),
                WizardFooter(
                  showBack: false,
                  primaryLabel: 'Continue',
                  onPrimary: _next,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
