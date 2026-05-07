import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppStatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final Color? color;
  final CrossAxisAlignment crossAxisAlignment;
  final bool animate;

  const AppStatBlock({
    super.key,
    required this.label,
    required this.value,
    this.helper,
    this.color,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final motionEnabled = animate && AppMotion.enabled(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: motionEnabled ? 0.985 : 1, end: 1),
      duration: AppMotion.duration(context, AppMotion.standard),
      curve: AppMotion.standardCurve,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.cellBg(context, accent),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: isDark ? 0.34 : 0.5),
            width: 0.7,
          ),
        ),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.metaLabel(context).copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedSwitcher(
              duration: AppMotion.duration(context, AppMotion.fast),
              switchInCurve: AppMotion.standardCurve,
              switchOutCurve: AppMotion.fadeCurve,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.985, end: 1).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: AppMotion.standardCurve,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: Text(
                value,
                key: ValueKey<String>(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.statValue(context).copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if ((helper ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: AppMotion.duration(context, AppMotion.fast),
                child: Text(
                  helper!.trim(),
                  key: ValueKey<String>(helper!.trim()),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metaLabel(
                    context,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
