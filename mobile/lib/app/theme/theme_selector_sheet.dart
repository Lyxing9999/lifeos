import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme_providers.dart';
import '../../app/theme/theme_type.dart';

class ThemeSelectorSheet extends ConsumerWidget {
  const ThemeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final themeTypes = AppThemeType.values;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose Theme', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final type in themeTypes)
                ChoiceChip(
                  label: Text(type.label),
                  selected: themeSettings.themeType == type,
                  backgroundColor: type.previewColor.withValues(alpha: 0.08),
                  selectedColor: type.previewColor.withValues(alpha: 0.24),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  avatar: CircleAvatar(
                    backgroundColor: type.previewColor,
                    radius: 10,
                  ),
                  onSelected: (_) => notifier.setThemeType(type),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
