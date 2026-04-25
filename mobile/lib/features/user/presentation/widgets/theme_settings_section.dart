import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/theme_providers.dart';
import '../../../../app/theme/theme_type.dart';

class ThemeSettingsSection extends ConsumerWidget {
  const ThemeSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme mode', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<AppThemeMode>(
              showSelectedIcon: false,
              segments: AppThemeMode.values
                  .map(
                    (mode) => ButtonSegment<AppThemeMode>(
                      value: mode,
                      label: Text(mode.label),
                    ),
                  )
                  .toList(),
              style: SegmentedButton.styleFrom(
                textStyle: AppTextStyles.metaLabel(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              selected: {settings.themeMode},
              onSelectionChanged: (values) {
                notifier.setThemeMode(values.first);
              },
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Text('Accent color', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: AppThemeType.values.map((item) {
                final isSelected = item == settings.themeType;
                return _ThemeSwatch(
                  label: item.label,
                  color: item.previewColor,
                  selected: isSelected,
                  onTap: () => notifier.setThemeType(item),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: selected ? 0.22 : 0.10),
                    blurRadius: selected ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: color,
                          size: 13,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.metaLabel(context).copyWith(
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
