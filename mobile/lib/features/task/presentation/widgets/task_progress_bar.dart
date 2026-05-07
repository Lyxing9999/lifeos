import 'package:flutter/material.dart';

import '../style/task_style.dart';

class TaskProgressBar extends StatelessWidget {
  final int progress;

  const TaskProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progress.clamp(0, 100);
    final isComplete = clamped >= 100;
    final activeColor = TaskStyle.progressColor(clamped);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: clamped / 100.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: TaskStyle.progressTrackColor(context),
                  valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                );
              },
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
                  ? TaskStyle.completedColor()
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
