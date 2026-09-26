import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/privacy_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';
import '../common/panel.dart';
import 'pane_scaffold.dart';

/// Applies sensitivity values to the native engine via the controller.
class BlurGlassSettings {
  static void apply(
    PrivacyController controller, {
    required double yaw,
    required double pitch,
    required double unlockMs,
    required double noFaceMs,
  }) {
    controller.setConfig(
      yawDegrees: yaw,
      pitchDegrees: pitch,
      unlockMs: unlockMs,
      noFaceLockMs: noFaceMs,
    );
  }
}

/// Settings Pane: Grouped macOS Cards with sensitivity sliders, appearance toggle, and biometric tools.
class SettingsPane extends StatefulWidget {
  const SettingsPane({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<SettingsPane> createState() => _SettingsPaneState();
}

class _SettingsPaneState extends State<SettingsPane> {
  double _yaw = 22;
  double _pitch = 24;
  double _unlockMs = 350;
  double _noFaceMs = 500;
  bool _saved = false;
  Timer? _saveTimer;

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  void _apply() {
    BlurGlassSettings.apply(
      widget.controller,
      yaw: _yaw,
      pitch: _pitch,
      unlockMs: _unlockMs,
      noFaceMs: _noFaceMs,
    );
    setState(() => _saved = true);
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _setPreset(String name) {
    setState(() {
      if (name == 'sensitive') {
        _yaw = 15;
        _pitch = 16;
        _unlockMs = 250;
        _noFaceMs = 300;
      } else if (name == 'relaxed') {
        _yaw = 32;
        _pitch = 34;
        _unlockMs = 600;
        _noFaceMs = 900;
      } else {
        _yaw = 22;
        _pitch = 24;
        _unlockMs = 350;
        _noFaceMs = 500;
      }
    });
    _apply();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasTemplate = widget.controller.currentHasTemplate;

    return PaneScaffold(
      title: 'Settings',
      subtitle: 'Fine-tune attention sensitivity, theme mode, and screen lock timing.',
      maxWidth: 620,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Appearance Card (Theme Toggle)
          Panel(
            padding: const EdgeInsets.all(20),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Select a light or dark theme, or sync with macOS system appearance.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                ListenableBuilder(
                  listenable: ThemeController.instance,
                  builder: (context, _) {
                    final currentMode = ThemeController.instance.themeMode;
                    return Row(
                      children: [
                        Expanded(
                          child: ThemeModeTile(
                            title: 'Light',
                            icon: Icons.light_mode_rounded,
                            selected: currentMode == ThemeMode.light,
                            onTap: () => ThemeController.instance
                                .setThemeMode(ThemeMode.light),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ThemeModeTile(
                            title: 'Dark',
                            icon: Icons.dark_mode_rounded,
                            selected: currentMode == ThemeMode.dark,
                            onTap: () => ThemeController.instance
                                .setThemeMode(ThemeMode.dark),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ThemeModeTile(
                            title: 'System',
                            icon: Icons.brightness_auto_rounded,
                            selected: currentMode == ThemeMode.system,
                            onTap: () => ThemeController.instance
                                .setThemeMode(ThemeMode.system),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Presets selector
          Row(
            children: [
              Text(
                'SENSITIVITY PRESETS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colors.textTertiary,
                ),
              ),
              const Spacer(),
              PresetChip(label: 'Sensitive', onTap: () => _setPreset('sensitive')),
              const SizedBox(width: 6),
              PresetChip(label: 'Balanced', onTap: () => _setPreset('balanced')),
              const SizedBox(width: 6),
              PresetChip(label: 'Relaxed', onTap: () => _setPreset('relaxed')),
            ],
          ),
          const SizedBox(height: 10),
          // Sensitivity Card
          Panel(
            padding: const EdgeInsets.all(20),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Look-Away Sensitivity',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Lower angular thresholds engage blur sooner when turning your head.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                _sliderRow(
                  label: 'Look-away yaw threshold',
                  value: _yaw,
                  min: 10,
                  max: 40,
                  format: (v) => '${v.toStringAsFixed(0)}°',
                  onChanged: (v) => setState(() => _yaw = v),
                ),
                Divider(color: colors.hairline, height: 20),
                _sliderRow(
                  label: 'Look-away pitch threshold',
                  value: _pitch,
                  min: 10,
                  max: 40,
                  format: (v) => '${v.toStringAsFixed(0)}°',
                  onChanged: (v) => setState(() => _pitch = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Timing Card
          Panel(
            padding: const EdgeInsets.all(20),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hysteresis & Timing',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Prevents screen flickering during natural blinks and micro-movements.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                _sliderRow(
                  label: 'Unlock delay',
                  value: _unlockMs,
                  min: 150,
                  max: 1000,
                  format: (v) => '${v.toStringAsFixed(0)} ms',
                  onChanged: (v) => setState(() => _unlockMs = v),
                ),
                Divider(color: colors.hairline, height: 20),
                _sliderRow(
                  label: 'No-face grace period',
                  value: _noFaceMs,
                  min: 200,
                  max: 1500,
                  format: (v) => '${v.toStringAsFixed(0)} ms',
                  onChanged: (v) => setState(() => _noFaceMs = v),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _apply,
                    icon: Icon(
                      _saved ? Icons.check_rounded : Icons.save_outlined,
                      size: 16,
                    ),
                    label: Text(_saved ? 'Applied' : 'Apply'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Biometric Enrollment Card
          Panel(
            padding: const EdgeInsets.all(18),
            borderRadius: 12,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.blueTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.face_retouching_natural_rounded,
                    size: 22,
                    color: colors.blue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owner face biometric template',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasTemplate
                            ? 'Encrypted and stored in macOS Keychain on this Mac.'
                            : 'No face template registered — complete setup to enroll.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (hasTemplate)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BrandColors.red,
                      side: BorderSide(
                        color: BrandColors.red.withValues(alpha: 0.4),
                      ),
                    ),
                    onPressed: _confirmRemoveTemplate,
                    child: const Text('Remove'),
                  )
                else
                  FilledButton(
                    onPressed: widget.controller.redoOnboarding,
                    child: const Text('Set up'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveTemplate() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove face template?'),
        content: const Text(
          'Blur Glass will forget your face and return to setup. Protection '
          'cannot run without a verified template.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BrandColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.clearOwner();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required String Function(double) format,
    required ValueChanged<double> onChanged,
  }) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.isDark
                    ? const Color(0x18FFFFFF)
                    : const Color(0x0C000000),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                format(value),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.blue,
                      fontSize: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / 5).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class ThemeModeTile extends StatefulWidget {
  const ThemeModeTile({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<ThemeModeTile> createState() => _ThemeModeTileState();
}

class _ThemeModeTileState extends State<ThemeModeTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;
    final selected = widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? colors.blue.withValues(alpha: isDark ? 0.20 : 0.12)
                : (_hovered
                    ? (isDark
                        ? const Color(0x18FFFFFF)
                        : const Color(0x0C000000))
                    : (isDark
                        ? const Color(0x0EFFFFFF)
                        : const Color(0x06000000))),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? colors.blue
                  : (isDark ? BrandColors.darkHairline : BrandColors.lightHairline),
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: selected ? colors.blue : colors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? colors.blue : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PresetChip extends StatelessWidget {
  const PresetChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colors.isDark
              ? const Color(0x14FFFFFF)
              : const Color(0x0A000000),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.hairline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
