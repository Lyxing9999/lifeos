import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Shared tappable picker row.
///
/// Use for:
/// - date picker
/// - time picker
/// - category picker
/// - schedule selector
/// - any value selected from a dialog/sheet
class AppPickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool enabled;
  final Color? color;

  const AppPickerTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.trailing,
    this.enabled = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      value: value,
      hint: enabled ? 'Tap to change' : null,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(AppRadius.card),
          splashColor: accent.withValues(alpha: 0.08),
          highlightColor: accent.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.46),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: enabled ? 0.10 : 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.icon),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: enabled
                        ? accent
                        : scheme.onSurfaceVariant.withValues(alpha: 0.48),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.statLabel(
                          context,
                        ).copyWith(color: scheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: AppTextStyles.cardTitle(context).copyWith(
                          color: enabled
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                trailing ??
                    Icon(
                      AppIcons.chevronRight,
                      size: 20,
                      color: scheme.onSurfaceVariant.withValues(
                        alpha: enabled ? 0.78 : 0.38,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
