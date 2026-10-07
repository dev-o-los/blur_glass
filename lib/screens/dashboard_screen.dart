import 'package:flutter/material.dart';

import '../services/privacy_controller.dart';
import '../widgets/popover/blur_glass_popover.dart';

export '../widgets/popover/blur_glass_popover.dart';

/// The base UI of Blur Glass: high-end macOS frosted glass window.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return BlurGlassPopover(controller: controller);
  }
}
