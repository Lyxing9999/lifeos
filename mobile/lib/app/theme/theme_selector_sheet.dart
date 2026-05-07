import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_button.dart';
import 'theme_providers.dart';
import 'theme_type.dart';

class ThemeSelectorSheet extends ConsumerWidget {
  const ThemeSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show<void>(
      context: context,
      title: 'Appearance',
      subtitle: 'Choose how LifeOS looks on this device.',
      child: const ThemeSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModeSelector(
          selected: settings.themeMode,
          onChanged: notifier.setThemeMode,
        ),
        const SizedBox(height: 20),
        _ThemeGrid(
          selected: settings.themeType,
          onChanged: notifier.setThemeType,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AppButton.secondary(
            label: 'Reset to default',
            onPressed: notifier.resetTheme,
          ),
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  const _ModeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final mode in AppThemeMode.values)
          AppChip.filter(
            label: mode.label,
            selected: selected == mode,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(mode);
            },
          ),
      ],
    );
  }
}

class _ThemeGrid extends StatelessWidget {
  final AppThemeType selected;
  final ValueChanged<AppThemeType> onChanged;

  const _ThemeGrid({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final type in AppThemeType.values)
          _ThemeOptionCard(
            type: type,
            selected: selected == type,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(type);
            },
          ),
      ],
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final AppThemeType type;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? type.previewColor.withValues(alpha: 0.12)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 138,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? type.previewColor.withValues(alpha: 0.72)
                  : scheme.outlineVariant.withValues(alpha: 0.42),
              width: selected ? 1.6 : 0.8,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: type.previewColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded, size: 18, color: type.previewColor),
            ],
          ),
        ),
      ),
    );
  }
}
