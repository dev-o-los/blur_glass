import 'package:flutter/material.dart';

import '../../models/attention_snapshot.dart';
import '../../services/privacy_controller.dart';
import '../../theme/app_colors.dart';
import '../common/brand_mark.dart';

enum DashboardPane { home, settings, about }

/// Navigation sidebar styled to macOS standards.
class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.controller,
  });

  final DashboardPane selected;
  final ValueChanged<DashboardPane> onSelect;
  final PrivacyController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = colors.isDark;

    return SizedBox(
      width: 216,
      child: Container(
        color: colors.sidebar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Safe margin for macOS window traffic lights
            const SizedBox(height: 44),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const BrandMark(size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blur Glass',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: colors.textPrimary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Screen privacy, naturally.',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.textTertiary,
                                fontSize: 10.5,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _NavItem(
                    icon: Icons.shield_outlined,
                    activeIcon: Icons.shield_rounded,
                    label: 'Home',
                    selected: selected == DashboardPane.home,
                    onTap: () => onSelect(DashboardPane.home),
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.tune_rounded,
                    activeIcon: Icons.tune_rounded,
                    label: 'Settings',
                    selected: selected == DashboardPane.settings,
                    onTap: () => onSelect(DashboardPane.settings),
                  ),
                  const SizedBox(height: 4),
                  _NavItem(
                    icon: Icons.info_outline_rounded,
                    activeIcon: Icons.info_rounded,
                    label: 'About',
                    selected: selected == DashboardPane.about,
                    onTap: () => onSelect(DashboardPane.about),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Live engine status widget
            Padding(
              padding: const EdgeInsets.all(12),
              child: StreamBuilder<AttentionSnapshot>(
                stream: controller.snapshots,
                initialData: controller.currentSnapshot,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final protected = state?.isShielded ?? false;
                  final tone = state?.tone ?? SnapshotTone.neutral;
                  final accent = toneColor(tone, isDark);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0x18FFFFFF)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.hairline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              protected ? 'SCREEN FROSTED' : 'SCREEN VISIBLE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          protected
                              ? 'Screen status · Blurred'
                              : 'Screen status · Visible',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive sidebar item with smooth hover transition.
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final selected = widget.selected;
    final color = selected
        ? (colors.isDark ? Colors.white : colors.blue)
        : (_hovered ? colors.textPrimary : colors.textSecondary);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? (colors.isDark
                    ? BrandColors.blue.withValues(alpha: 0.85)
                    : colors.blue.withValues(alpha: 0.12))
                : (_hovered
                    ? (colors.isDark
                        ? const Color(0x14FFFFFF)
                        : const Color(0x0A000000))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: selected && colors.isDark
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.75,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                selected ? widget.activeIcon : widget.icon,
                size: 17,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: color,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
