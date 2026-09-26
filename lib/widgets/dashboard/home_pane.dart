import 'package:flutter/material.dart';

import '../../models/attention_snapshot.dart';
import '../../services/privacy_controller.dart';
import '../common/panel.dart';
import 'pane_scaffold.dart';
import 'primary_action.dart';
import 'status_hero.dart';
import 'telemetry_grid.dart';

/// Home: Protection Center with live radar visualizer and telemetry metrics.
class HomePane extends StatelessWidget {
  const HomePane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    return PaneScaffold(
      title: 'Screen Privacy',
      subtitle: 'Automatically blur your screen when you look away.',
      maxWidth: 620,
      child: StreamBuilder<AttentionSnapshot>(
        stream: controller.snapshots,
        initialData: controller.currentSnapshot,
        builder: (context, snapshot) {
          final state = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Panel(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusHero(state: state),
                    const SizedBox(height: 20),
                    PrimaryAction(controller: controller, state: state),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TelemetryGrid(state: state),
            ],
          );
        },
      ),
    );
  }
}
