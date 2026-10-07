import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/privacy_controller.dart';

/// Compact, frosted macOS-style settings panel displayed within the popover.
class PopoverSettingsView extends StatefulWidget {
  const PopoverSettingsView({
    super.key,
    required this.controller,
    required this.onClose,
  });

  final PrivacyController controller;
  final VoidCallback onClose;

  @override
  State<PopoverSettingsView> createState() => _PopoverSettingsViewState();
}

class _PopoverSettingsViewState extends State<PopoverSettingsView> {
  double _yaw = 22.0;
  double _pitch = 18.0;
  double _unlockMs = 280.0;
  double _noFaceMs = 900.0;
  bool _hasTemplate = false;
  bool _hasPass = false;
  bool _loading = false;
  String? _statusNotice;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    _hasTemplate = widget.controller.currentHasTemplate;
    _hasPass = await widget.controller.hasEmergencyPassword();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 42, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Back / Done with true centered title
          SizedBox(
            height: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onClose,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.chevron_left,
                            size: 16,
                            color: Color(0xFF007AFF),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF007AFF),
                              fontFamily: '.SF Pro Text',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onClose,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007AFF),
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (_statusNotice != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Text(
                _statusNotice!,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.white,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ),
          ],

          // Scrollable Settings Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section: Biometrics & Face Enrollment
                  _buildSectionHeader('BIOMETRICS & CAMERA'),
                  _buildCard([
                    _buildTile(
                      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                      title: 'Face Template',
                      subtitle: _hasTemplate
                          ? 'Enrolled on this Mac'
                          : 'Not enrolled yet',
                      trailing: _buildButton(
                        label: _hasTemplate ? 'Re-enroll' : 'Enroll',
                        isPrimary: true,
                        onPressed: _loading ? null : _handleEnroll,
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.75, color: Color(0x14FFFFFF)),
                    _buildTile(
                      icon: CupertinoIcons.camera,
                      title: 'Camera Access',
                      subtitle: 'System permission',
                      trailing: _buildButton(
                        label: 'System Prefs',
                        onPressed: () => widget.controller.openCameraSettings(),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // Section: Gaze Sensitivity
                  _buildSectionHeader('GAZE SENSITIVITY'),
                  _buildCard([
                    _buildSliderTile(
                      label: 'Look-Away Yaw',
                      value: _yaw,
                      min: 10,
                      max: 45,
                      suffix: '°',
                      onChanged: (v) {
                        setState(() => _yaw = v);
                        _applyConfig();
                      },
                    ),
                    const Divider(height: 1, thickness: 0.75, color: Color(0x14FFFFFF)),
                    _buildSliderTile(
                      label: 'Look-Away Pitch',
                      value: _pitch,
                      min: 8,
                      max: 35,
                      suffix: '°',
                      onChanged: (v) {
                        setState(() => _pitch = v);
                        _applyConfig();
                      },
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // Section: Response Timings
                  _buildSectionHeader('RESPONSE TIMING'),
                  _buildCard([
                    _buildSliderTile(
                      label: 'Unlock Speed',
                      value: _unlockMs,
                      min: 100,
                      max: 1000,
                      suffix: 'ms',
                      onChanged: (v) {
                        setState(() => _unlockMs = v);
                        _applyConfig();
                      },
                    ),
                    const Divider(height: 1, thickness: 0.75, color: Color(0x14FFFFFF)),
                    _buildSliderTile(
                      label: 'No-Face Delay',
                      value: _noFaceMs,
                      min: 300,
                      max: 3000,
                      suffix: 'ms',
                      onChanged: (v) {
                        setState(() => _noFaceMs = v);
                        _applyConfig();
                      },
                    ),
                  ]),

                  const SizedBox(height: 12),

                  // Section: Security
                  _buildSectionHeader('EMERGENCY UNLOCK'),
                  _buildCard([
                    _buildTile(
                      icon: CupertinoIcons.lock_shield,
                      title: 'Emergency Password',
                      subtitle: _hasPass
                          ? 'Backup password set'
                          : 'No backup password',
                      trailing: _buildButton(
                        label: _hasPass ? 'Change' : 'Set Up',
                        onPressed: _showPasswordDialog,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.45),
          letterSpacing: 0.5,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.75,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.75)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: '.SF Pro Text',
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.48),
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    final enabled = onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: isPrimary
                ? const Color(0xFF007AFF)
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.14),
              width: 0.75,
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.35),
                      blurRadius: 5,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
              fontFamily: '.SF Pro Text',
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
      child: Row(
        children: [
          // Left side: Setting label
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: '.SF Pro Text',
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(width: 14),
          // Right side: Slider and Value badge spread to the right
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
                    child: SizedBox(
                      width: 150,
                      height: 20,
                      child: _MacSlider(
                        value: value,
                        min: min,
                        max: max,
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Container(
                  width: 46,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    '${value.round()}$suffix',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD6DBE5),
                      fontFamily: '.SF Pro Text',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyConfig() {
    widget.controller.setConfig(
      yawDegrees: _yaw,
      pitchDegrees: _pitch,
      unlockMs: _unlockMs,
      noFaceLockMs: _noFaceMs,
    );
  }

  Future<void> _handleEnroll() async {
    setState(() {
      _loading = true;
      _statusNotice = 'Authenticating with Mac biometrics…';
    });
    try {
      await widget.controller.enroll();
      await _loadState();
      setState(() {
        _statusNotice = 'Face enrolled successfully!';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showPasswordDialog() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Emergency Password'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            obscureText: true,
            placeholder: 'Enter password',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save'),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                await widget.controller.setEmergencyPassword(text);
                await _loadState();
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

/// Compact, modern macOS Sequoia style slider.
class _MacSlider extends StatefulWidget {
  const _MacSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  State<_MacSlider> createState() => _MacSliderState();
}

class _MacSliderState extends State<_MacSlider> {
  void _handleDrag(Offset localPosition, double width) {
    const thumbRadius = 7.0;
    final trackWidth = width - thumbRadius * 2;
    if (trackWidth <= 0) return;
    final clampedX = (localPosition.dx - thumbRadius).clamp(0.0, trackWidth);
    final ratio = clampedX / trackWidth;
    final newValue = widget.min + ratio * (widget.max - widget.min);
    widget.onChanged(newValue.clamp(widget.min, widget.max));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const thumbRadius = 7.0;
        final trackWidth = width - thumbRadius * 2;
        final ratio = (widget.value - widget.min) / (widget.max - widget.min);
        final thumbOffset = thumbRadius + ratio.clamp(0.0, 1.0) * trackWidth;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _handleDrag(details.localPosition, width),
            onHorizontalDragUpdate: (details) =>
                _handleDrag(details.localPosition, width),
            child: SizedBox(
              width: width,
              height: 20,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track background
                  Container(
                    width: width,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Active Track fill (macOS Blue)
                  Container(
                    width: thumbOffset,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Sleek macOS circular thumb
                  Positioned(
                    left: thumbOffset - thumbRadius,
                    top: (20 - thumbRadius * 2) / 2,
                    child: Container(
                      width: thumbRadius * 2,
                      height: thumbRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
