import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Inline progress bar used on TaskCard and TaskDetailPage.
/// Color transitions: primary → warning → success based on progress value.
class TaskProgressBar extends StatelessWidget {
  final int progress;

  const TaskProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progress.clamp(0, 100);
    final isComplete = clamped >= 100;

    // Use semantic score color: red < 50, amber 50–79, green ≥ 80
    final activeColor = isComplete
        ? AppColors.success
        : AppColors.scoreColor(clamped);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped / 100.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 38,
          child: Text(
            '$clamped%',
            textAlign: TextAlign.right,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isComplete
                  ? AppColors.success
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
