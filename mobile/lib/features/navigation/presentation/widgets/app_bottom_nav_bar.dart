import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_radius.dart';
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
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
    ),
    _NavItemData(
      label: 'Timeline',
      icon: Icons.timeline_outlined,
      selectedIcon: Icons.timeline,
    ),
    _NavItemData(
      label: 'Tasks',
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist,
    ),
    _NavItemData(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.5,
            color: colorScheme.outlineVariant.withValues(alpha: 0.75),
          ),
          SafeArea(
            top: false,
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
        ],
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
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.58,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      hint: selected ? '${data.label} tab selected' : 'Open ${data.label} tab',
      child: InkWell(
        onTap: onTap,
        splashColor: selectedColor.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 32,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    width: 40,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedColor.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Icon(
                      selected ? data.selectedIcon : data.icon,
                      size: 20,
                      color: selected ? selectedColor : unselectedColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 12,
                child: Center(
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.metaLabel(context).copyWith(
                      color: selected ? selectedColor : unselectedColor,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
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
