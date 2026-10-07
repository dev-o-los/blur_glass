import 'package:flutter/material.dart';

import '../services/privacy_controller.dart';
import '../widgets/popover/blur_glass_popover.dart';

/// In the new design, the window-sized card serves as the unified interface.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return BlurGlassPopover(controller: controller);
  }
}
