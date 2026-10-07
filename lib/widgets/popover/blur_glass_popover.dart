import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/attention_snapshot.dart';
import '../../services/privacy_controller.dart';
import '../../services/window_service.dart';
import '../common/brand_mark.dart';
import 'popover_settings_view.dart';

/// The window-sized core UI of Blur Glass.
class BlurGlassPopover extends StatefulWidget {
  const BlurGlassPopover({super.key, required this.controller});

  final PrivacyController controller;

  @override
  State<BlurGlassPopover> createState() => _BlurGlassPopoverState();
}

class _BlurGlassPopoverState extends State<BlurGlassPopover> {
  bool _showSettings = false;
  bool _isSwitchToggling = false;

  void _openSettings() {
    setState(() => _showSettings = true);
    WindowService.setWindowSize(width: 420, height: 480);
  }

  void _closeSettings() {
    setState(() => _showSettings = false);
    WindowService.setWindowSize(width: 420, height: 228);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AttentionSnapshot>(
      stream: widget.controller.snapshots,
      initialData: widget.controller.currentSnapshot,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final enrolling = state?.state == 'enrolling';
        final isProtecting =
            state != null && state.state != 'idle' && !enrolling;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xEB232734), // Deep frosted slate
                Color(0xF2181B25), // Dark glass base
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
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
                child: _showSettings
                    ? PopoverSettingsView(
                        key: const ValueKey('settings'),
                        controller: widget.controller,
                        onClose: _closeSettings,
                      )
                    : _buildMainCard(isProtecting, state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainCard(bool isProtecting, AttentionSnapshot? state) {
    return Padding(
      key: const ValueKey('main_card'),
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Header Row: Icon, Title & Tagline, Settings Button
          _buildHeaderRow(),

          const SizedBox(height: 14),

          // 2. Middle Container: "Screen Privacy", Shield Icon & Toggle
          _buildScreenPrivacyCard(isProtecting),

          const SizedBox(height: 14),

          // 3. Subtle Hairline Divider
          Container(
            height: 0.75,
            color: Colors.white.withValues(alpha: 0.10),
          ),

          const SizedBox(height: 12),

          // 4. Bottom Status Row: Glowing Indicator Dot & Status Text
          _buildStatusRow(isProtecting, state),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        // App Icon Badge (48x48 squircle with aperture iris)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C92FF),
                Color(0xFF0066EB),
              ],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 0.75,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066EB).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CustomPaint(
            painter: ApertureIrisPainter(color: Colors.white),
          ),
        ),

        const SizedBox(width: 14),

        // App Name and Tagline
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Blur Glass',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.2,
                  fontFamily: '.SF Pro Display',
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Screen privacy, naturally.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9EACB9),
                  letterSpacing: -0.1,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ],
          ),
        ),

        // Settings Button
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _openSettings,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                CupertinoIcons.gear_alt,
                size: 19,
                color: Color(0xD8FFFFFF),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScreenPrivacyCard(bool isProtecting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // Crisp Solid White Shield Icon
          const Icon(
            CupertinoIcons.shield_fill,
            color: Colors.white,
            size: 26,
          ),

          const SizedBox(width: 14),

          // Title and Subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Screen Privacy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.1,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Blur when you look away',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9EA3B0),
                    letterSpacing: -0.1,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ],
            ),
          ),

          // Toggle Switch
          _buildMacSwitch(isProtecting),
        ],
      ),
    );
  }

  Widget _buildMacSwitch(bool isProtecting) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _toggleProtection(isProtecting),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 50,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isProtecting
                ? const Color(0xFF007AFF) // macOS system blue
                : Colors.white.withValues(alpha: 0.22),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment:
                isProtecting ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleProtection(bool currentlyProtecting) async {
    if (_isSwitchToggling) return;
    setState(() => _isSwitchToggling = true);

    try {
      if (currentlyProtecting) {
        await widget.controller.stopProtection();
      } else {
        await widget.controller.startProtection();
      }
    } finally {
      if (mounted) {
        setState(() => _isSwitchToggling = false);
      }
    }
  }

  Widget _buildStatusRow(bool isProtecting, AttentionSnapshot? state) {
    Color dotColor;
    List<BoxShadow> glowShadow;
    String statusText;

    if (!isProtecting) {
      dotColor = Colors.white.withValues(alpha: 0.40);
      glowShadow = const [];
      statusText = 'Protection paused';
    } else {
      switch (state?.state) {
        case 'owner':
          dotColor = const Color(0xFF34C759); // Vibrant green
          glowShadow = [
            BoxShadow(
              color: const Color(0xFF34C759).withValues(alpha: 0.75),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ];
          statusText = 'Screen clear';
          break;
        case 'lookAway':
        case 'noFace':
          dotColor = const Color(0xFFFF9F0A); // Amber
          glowShadow = [
            BoxShadow(
              color: const Color(0xFFFF9F0A).withValues(alpha: 0.75),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ];
          statusText = state?.state == 'lookAway'
              ? 'Looking away — Screen blurred'
              : 'Left frame — Screen blurred';
          break;
        case 'stranger':
        case 'extraFace':
          dotColor = const Color(0xFFFF453A); // Red
          glowShadow = [
            BoxShadow(
              color: const Color(0xFFFF453A).withValues(alpha: 0.75),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ];
          statusText = state?.state == 'stranger'
              ? 'Stranger detected — Screen blurred'
              : 'Extra face detected — Screen blurred';
          break;
        case 'enrolling':
          dotColor = const Color(0xFF007AFF); // Blue
          glowShadow = [
            BoxShadow(
              color: const Color(0xFF007AFF).withValues(alpha: 0.75),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ];
          statusText = 'Enrolling face…';
          break;
        case 'error':
          dotColor = const Color(0xFFFF453A);
          glowShadow = const [];
          statusText = 'Camera error';
          break;
        default:
          dotColor = const Color(0xFF34C759);
          glowShadow = [
            BoxShadow(
              color: const Color(0xFF34C759).withValues(alpha: 0.75),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ];
          statusText = 'Screen clear';
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          // Status Dot Indicator
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              boxShadow: glowShadow,
            ),
          ),

          const SizedBox(width: 10),

          // Status Text
          Expanded(
            child: Text(
              statusText,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFFB5BAC5),
                letterSpacing: -0.1,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
