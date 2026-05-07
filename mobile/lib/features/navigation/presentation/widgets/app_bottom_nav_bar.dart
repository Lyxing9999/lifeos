import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItemData>[
    _NavItemData(
      label: 'Today',
      icon: AppIcons.today,
      selectedIcon: AppIcons.todayActive,
    ),
    _NavItemData(
      label: 'Timeline',
      icon: AppIcons.timeline,
      selectedIcon: AppIcons.timelineActive,
    ),
    _NavItemData(
      label: 'Tasks',
      icon: AppIcons.tasks,
      selectedIcon: AppIcons.tasksActive,
    ),
    _NavItemData(
      label: 'Profile',
      icon: AppIcons.profile,
      selectedIcon: AppIcons.profileActive,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        bottomInset == 0 ? AppSpacing.sm : AppSpacing.xs,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: isDark ? 0.62 : 0.78),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: scheme.outlineVariant.withValues(
                  alpha: isDark ? 0.34 : 0.46,
                ),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: scheme.primary.withValues(alpha: isDark ? 0.05 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    final selected = index == currentIndex;

                    return Expanded(
                      child: _BottomBarItem(
                        data: item,
                        selected: selected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(index);
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _BottomBarItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final selectedColor = scheme.primary;
    final unselectedColor = scheme.onSurfaceVariant.withValues(alpha: 0.66);

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      hint: selected ? '${data.label} tab selected' : 'Open ${data.label} tab',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.full),
          onTap: onTap,
          splashColor: selectedColor.withValues(alpha: 0.08),
          highlightColor: selectedColor.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: selected
                  ? selectedColor.withValues(alpha: 0.11)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: selected
                  ? Border.all(
                      color: selectedColor.withValues(alpha: 0.18),
                      width: 0.8,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavIconBubble(
                  selected: selected,
                  icon: selected ? data.selectedIcon : data.icon,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),
                const SizedBox(height: 3),
                _NavLabel(
                  label: data.label,
                  selected: selected,
                  selectedColor: selectedColor,
                  unselectedColor: unselectedColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIconBubble extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavIconBubble({
    required this.selected,
    required this.icon,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: selected ? 38 : 34,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? selectedColor.withValues(alpha: 0.08)
            : Colors.transparent,

        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        scale: selected ? 1.04 : 1.0,
        child: Icon(
          icon,
          size: selected ? 20.5 : 20,
          color: selected ? selectedColor : unselectedColor,
        ),
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;

  const _NavLabel({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 13,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: AppTextStyles.metaLabel(context).copyWith(
            color: selected ? selectedColor : unselectedColor,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: selected ? -0.15 : -0.05,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
