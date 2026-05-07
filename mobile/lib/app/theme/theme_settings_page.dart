import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/section_header.dart';
import 'app_icons.dart';
import 'theme_providers.dart';
import 'theme_type.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return AppScaffold(
      title: 'Appearance',
      body: ListView(
        children: [
          const SectionHeader(title: 'Mode'),
          const SizedBox(height: 8),
          _ThemeModeList(
            selected: settings.themeMode,
            onChanged: notifier.setThemeMode,
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Theme'),
          const SizedBox(height: 8),
          _ThemeTypeList(
            selected: settings.themeType,
            onChanged: notifier.setThemeType,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton.secondary(
              label: 'Reset to default',
              icon: AppIcons.refresh,
              onPressed: notifier.resetTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeList extends StatelessWidget {
  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeModeList({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final mode in AppThemeMode.values) ...[
          _ThemeRow(
            title: mode.label,
            subtitle: _subtitleForMode(mode),
            color: Theme.of(context).colorScheme.primary,
            selected: selected == mode,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(mode);
            },
          ),
          if (mode != AppThemeMode.values.last) const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _subtitleForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Follow your device setting';
      case AppThemeMode.light:
        return 'Always use light appearance';
      case AppThemeMode.dark:
        return 'Always use dark appearance';
    }
  }
}

class _ThemeTypeList extends StatelessWidget {
  final AppThemeType selected;
  final ValueChanged<AppThemeType> onChanged;

  const _ThemeTypeList({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final type in AppThemeType.values) ...[
          _ThemeRow(
            title: type.label,
            subtitle: type.isDark ? 'Dark palette' : 'Light palette',
            color: type.previewColor,
            selected: selected == type,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(type);
            },
          ),
          if (type != AppThemeType.values.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeRow({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? color.withValues(alpha: 0.10)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.50),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.70)
                  : scheme.outlineVariant.withValues(alpha: 0.40),
              width: selected ? 1.4 : 0.8,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 14, backgroundColor: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(AppIcons.success, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
