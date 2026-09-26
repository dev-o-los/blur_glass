import 'package:flutter/material.dart';

import '../services/privacy_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard/about_pane.dart';
import '../widgets/dashboard/home_pane.dart';
import '../widgets/dashboard/settings_pane.dart';
import '../widgets/dashboard/sidebar.dart';

export '../widgets/dashboard/about_pane.dart';
export '../widgets/dashboard/home_pane.dart';
export '../widgets/dashboard/pane_scaffold.dart';
export '../widgets/dashboard/primary_action.dart';
export '../widgets/dashboard/settings_pane.dart';
export '../widgets/dashboard/sidebar.dart';
export '../widgets/dashboard/stat_card.dart';
export '../widgets/dashboard/status_hero.dart';
export '../widgets/dashboard/telemetry_grid.dart';

/// Live status + controls, framed by a high-end macOS-style sidebar:
/// Home (status + start), Settings (sensitivity + appearance), About.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardPane _pane = DashboardPane.home;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardSidebar(
            selected: _pane,
            onSelect: (pane) => setState(() => _pane = pane),
            controller: widget.controller,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colors.hairline,
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: switch (_pane) {
                DashboardPane.home => HomePane(
                    key: const ValueKey('home'),
                    controller: widget.controller,
                  ),
                DashboardPane.settings => SettingsPane(
                    key: const ValueKey('settings'),
                    controller: widget.controller,
                  ),
                DashboardPane.about => AboutPane(
                    key: const ValueKey('about'),
                    controller: widget.controller,
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
