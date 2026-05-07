import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifeos_mobile/features/task/domain/enum/task_recurrence_type.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_status.dart';
import '../../domain/entities/task.dart';
import '../style/task_style.dart';
import 'task_progress_bar.dart';
import 'task_status_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onReopen;
  final bool compactCompleted;
  final bool showLibraryIntent;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onComplete,
    this.onReopen,
    this.compactCompleted = false,
    this.showLibraryIntent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status.isDone;
    final canComplete =
        onComplete != null && !isDone && !task.archived && !task.paused;
    final canReopen =
        onReopen != null && isDone && !task.archived && !task.paused;

    final card = _TaskCardSurface(
      onTap: onTap,
      isMuted: task.archived || task.paused || isDone,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TaskCheckButton(
            isDone: isDone,
            isArchived: task.archived,
            isPaused: task.paused,
            onComplete: onComplete,
            onReopen: onReopen,
            readOnly: showLibraryIntent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _TaskCardBody(
              task: task,
              compactCompleted: compactCompleted,
              showLibraryIntent: showLibraryIntent,
            ),
          ),
          if (canReopen && !showLibraryIntent) ...[
            const SizedBox(width: AppSpacing.xs),
            _ReopenIconButton(onPressed: onReopen!),
          ],
        ],
      ),
    );

    if (!canComplete || showLibraryIntent) {
      return card;
    }

    return Dismissible(
      key: ValueKey('task-swipe-complete-${task.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.heavyImpact();
        onComplete?.call();
        return false;
      },
      background: const _CompleteSwipeBackground(),
      child: card,
    );
  }
}

// ── THE DOPAMINE CHECK BUTTON ────────────────────────────────────────────────
// Converts an instant state change into a beautiful micro-interaction sequence.

class _TaskCheckButton extends StatefulWidget {
  final bool isDone;
  final bool isArchived;
  final bool isPaused;
  final bool readOnly;
  final VoidCallback? onComplete;
  final VoidCallback? onReopen;

  const _TaskCheckButton({
    required this.isDone,
    required this.isArchived,
    required this.isPaused,
    required this.onComplete,
    required this.onReopen,
    this.readOnly = false,
  });

  @override
  State<_TaskCheckButton> createState() => _TaskCheckButtonState();
}

class _TaskCheckButtonState extends State<_TaskCheckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isOptimisticallyDone = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant _TaskCheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync state if Riverpod updates us externally
    if (widget.isDone != oldWidget.isDone) {
      _isOptimisticallyDone = widget.isDone;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isDone) {
      HapticFeedback.selectionClick();
      widget.onReopen?.call();
      return;
    }

    // 1. The Squeeze (Button goes down)
    HapticFeedback.lightImpact();
    _scaleController.reverse();

    // 2. The Flip (Trigger optimistic state for UI fill)
    setState(() {
      _isOptimisticallyDone = true;
    });

    // Wait for the squeeze
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // 3. The Pop (Button springs back up, Checkmark appears)
    HapticFeedback.heavyImpact(); // The Dopamine Hit!
    _scaleController.forward();

    // 4. The Bask (Let the user admire the checkmark for a split second)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // 5. Fire to Backend
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.readOnly) {
      return _ReadOnlyIntentIcon(
        isDone: widget.isDone,
        isArchived: widget.isArchived,
        isPaused: widget.isPaused,
      );
    }

    final scheme = Theme.of(context).colorScheme;

    final canTap =
        !widget.isArchived &&
        !widget.isPaused &&
        (widget.isDone ? widget.onReopen != null : widget.onComplete != null);

    final showAsFilled =
        _isOptimisticallyDone ||
        widget.isDone ||
        widget.isPaused ||
        widget.isArchived;

        
    final borderColor = widget.isArchived || widget.isPaused
        ? scheme.outline.withValues(alpha: 0.42)
        : scheme.outline.withValues(alpha: 0.82);

    final fillColor = widget.isArchived || widget.isPaused
        ? scheme.surfaceContainerHighest
        : TaskStyle.completedColor();

    return Semantics(
      button: true,
      enabled: canTap,
      label: widget.isPaused
          ? 'Paused task'
          : widget.isArchived
          ? 'Archived task'
          : widget.isDone
          ? 'Reopen task'
          : 'Complete task',
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: GestureDetector(
          onTap: canTap ? _handleTap : null,
          behavior: HitTestBehavior.opaque,
          child: ScaleTransition(
            scale: _scaleController,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: showAsFilled ? fillColor : Colors.transparent,
                border: showAsFilled
                    ? null
                    : Border.all(color: borderColor, width: 1.45),
                boxShadow:
                    showAsFilled && !widget.isPaused && !widget.isArchived
                    ? [
                        BoxShadow(
                          color: fillColor.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: -2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: showAsFilled ? 1.0 : 0.0,
                child: Icon(
                  widget.isArchived
                      ? AppIcons.archive
                      : widget.isPaused
                      ? AppIcons.paused
                      : AppIcons.check,
                  size: 16,
                  color: widget.isArchived || widget.isPaused
                      ? scheme.onSurfaceVariant
                      : Colors.white, // Crisp white checkmark
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── SURFACE & LAYOUT ─────────────────────────────────────────────────────────

class _TaskCardSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isMuted;

  const _TaskCardSurface({
    required this.child,
    required this.onTap,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(
              alpha: isMuted ? (isDark ? 0.48 : 0.74) : (isDark ? 0.62 : 0.92),
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: scheme.outlineVariant.withValues(
                alpha: isDark ? 0.30 : 0.42,
              ),
              width: 0.75,
            ),
            boxShadow: AppShadows.card(isDark),
          ),
          child: Stack(
            children: [
              const _CardGlassHighlight(),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  splashColor: scheme.primary.withValues(alpha: 0.07),
                  highlightColor: scheme.primary.withValues(alpha: 0.035),
                  child: Padding(
                    padding: AppSpacing.cardInsetsSm,
                    child: child,
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

class _TaskCardBody extends StatelessWidget {
  final Task task;
  final bool compactCompleted;
  final bool showLibraryIntent;

  const _TaskCardBody({
    required this.task,
    required this.compactCompleted,
    required this.showLibraryIntent,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status.isDone;

    final shouldShowDescription =
        !compactCompleted &&
        !showLibraryIntent &&
        (task.description ?? '').trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TitleRow(task: task, showStatusChip: _shouldShowStatusChip),
        if (shouldShowDescription) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            task.description!.trim(),
            style: AppTextStyles.bodySecondary(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _MetadataWrap(task: task, compact: showLibraryIntent),
        if (showLibraryIntent) ...[
          const SizedBox(height: AppSpacing.sm),
          _TaskIntentLine(task: task),
        ],
        if (!compactCompleted && task.taskMode == TaskMode.progress) ...[
          const SizedBox(height: AppSpacing.sm),
          TaskProgressBar(progress: task.progressPercent),
        ],
        if (task.archived) ...[
          const SizedBox(height: AppSpacing.sm),
          _MutedHint(text: 'Archived · restore from task details'),
        ] else if (task.paused) ...[
          const SizedBox(height: AppSpacing.sm),
          _MutedHint(text: 'Paused · resume from task details'),
        ] else if (isDone && !compactCompleted && !showLibraryIntent) ...[
          const SizedBox(height: AppSpacing.xs),
          _MutedHint(text: 'Tap the checkmark to reopen'),
        ],
      ],
    );
  }

  bool get _shouldShowStatusChip {
    if (compactCompleted) return false;
    if (showLibraryIntent) {
      return task.paused ||
          task.archived ||
          task.status == TaskStatus.cancelled;
    }
    return task.status != TaskStatus.todo || task.paused || task.archived;
  }
}

class _TitleRow extends StatelessWidget {
  final Task task;
  final bool showStatusChip;

  const _TitleRow({required this.task, required this.showStatusChip});

  @override
  Widget build(BuildContext context) {
    final isDone = task.status.isDone;
    final scheme = Theme.of(context).colorScheme;
    final muted = isDone || task.archived || task.paused;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            style: AppTextStyles.cardTitle(context).copyWith(
              decoration: isDone ? TextDecoration.lineThrough : null,
              decorationColor: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
            ),
            child: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (showStatusChip) ...[
          const SizedBox(width: AppSpacing.sm),
          TaskStatusChip(status: task.status),
        ],
      ],
    );
  }
}

// ── METADATA & UTILS (Kept clean and exactly as you had them) ────────────────

class _MetadataWrap extends StatelessWidget {
  final Task task;
  final bool compact;

  const _MetadataWrap({required this.task, required this.compact});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (_shouldShowMode) {
      chips.add(
        AppChip.metadata(
          label: task.taskMode.label,
          icon: TaskStyle.modeIcon(task.taskMode),
          color: TaskStyle.modeColor(task.taskMode),
        ),
      );
    }

    if (_shouldShowPriority) {
      chips.add(
        AppChip.metadata(
          label: task.priority.label,
          icon: TaskStyle.priorityIcon(task.priority),
          color: TaskStyle.priorityColor(task.priority),
        ),
      );
    }

    final category = (task.category ?? '').trim();
    if (category.isNotEmpty) {
      chips.add(AppChip.metadata(label: category, icon: AppIcons.label));
    }

    if (!compact) {
      final due = task.dueDateTime ?? task.dueDate;
      final dueLabel = _dueLabel(due, hasTime: task.dueDateTime != null);

      if (dueLabel != null) {
        chips.add(
          AppChip.metadata(
            label: dueLabel,
            icon: TaskStyle.dueIcon(
              due: due,
              today: DateTime.now(),
              status: task.status,
              archived: task.archived,
              paused: task.paused,
            ),
            color: TaskStyle.dueColor(
              due: due,
              today: DateTime.now(),
              status: task.status,
              archived: task.archived,
              paused: task.paused,
            ),
          ),
        );
      }

      if (task.isRecurring) {
        final recurrenceLabel = task.recurrenceType.label;
        final modeLabel = task.taskMode.label;

        final isRedundant =
            _shouldShowMode &&
            (recurrenceLabel.toLowerCase() == modeLabel.toLowerCase());

        if (!isRedundant) {
          chips.add(
            AppChip.metadata(
              label: recurrenceLabel,
              icon: AppIcons.recurrence,
              color: TaskStyle.modeColor(TaskMode.daily),
            ),
          );
        }
      }

      if (_hasScheduleLink) {
        chips.add(
          AppChip.metadata(
            label: 'Linked',
            icon: AppIcons.linked,
            color: TaskStyle.linkedScheduleColor(),
          ),
        );
      }
    }

    if (task.archived) {
      chips.add(AppChip.metadata(label: 'Archived', icon: AppIcons.archive));
    }

    if (task.paused) {
      chips.add(AppChip.metadata(label: 'Paused', icon: AppIcons.paused));
    }

    final maxTags = compact ? 1 : 2;
    for (final tag in task.tags.take(maxTags)) {
      chips.add(AppChip.metadata(label: tag.name, icon: AppIcons.tags));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips,
    );
  }

  bool get _shouldShowMode => task.taskMode != TaskMode.standard;
  bool get _shouldShowPriority => task.priority == TaskPriority.high;
  bool get _hasScheduleLink =>
      (task.linkedScheduleBlockId ?? '').trim().isNotEmpty;

  String? _dueLabel(DateTime? due, {required bool hasTime}) {
    if (due == null) return null;
    final m = due.month.toString().padLeft(2, '0');
    final d = due.day.toString().padLeft(2, '0');

    if (!hasTime) return '$m/$d';

    final hh = due.hour.toString().padLeft(2, '0');
    final mm = due.minute.toString().padLeft(2, '0');
    return '$m/$d $hh:$mm';
  }
}

class _TaskIntentLine extends StatelessWidget {
  final Task task;

  const _TaskIntentLine({required this.task});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = _intentText;
    final icon = _intentIcon;
    final color = _intentColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String get _intentText {
    if (task.isRecurring) {
      final label = task.recurrenceType.label;
      if (task.status.isDone) return '$label repeat · Done for selected day';
      return '$label repeat · Active series';
    }
    if ((task.linkedScheduleBlockId ?? '').trim().isNotEmpty) {
      return 'Linked to schedule · Planned by schedule';
    }
    final due = task.dueDateTime ?? task.dueDate;
    if (due != null) {
      if (_isOverdue(due)) return 'One-time task · Overdue';
      return 'One-time task · Due ${_shortDate(due)}';
    }
    if (task.isProgressTask) {
      return 'Progress intent · ${task.progressPercent}% complete';
    }
    if (task.isInbox) return 'Inbox intent · Not planned yet';
    return 'Active intent';
  }

  IconData get _intentIcon {
    final due = task.dueDateTime ?? task.dueDate;
    if (task.isRecurring) return AppIcons.recurrence;
    if ((task.linkedScheduleBlockId ?? '').trim().isNotEmpty) {
      return AppIcons.linked;
    }
    if (due != null && _isOverdue(due)) return AppIcons.warning;
    if (due != null) return AppIcons.date;
    if (task.isProgressTask) return AppIcons.progressTask;
    if (task.isInbox) return AppIcons.inbox;
    return AppIcons.tasks;
  }

  Color _intentColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final due = task.dueDateTime ?? task.dueDate;
    if (due != null && _isOverdue(due)) return TaskStyle.overdueColor();
    if (task.isRecurring) return scheme.primary;
    if ((task.linkedScheduleBlockId ?? '').trim().isNotEmpty) {
      return TaskStyle.linkedScheduleColor();
    }
    if (task.isProgressTask) {
      return TaskStyle.progressColor(task.progressPercent);
    }
    if (task.isInbox) return scheme.tertiary;
    return scheme.onSurfaceVariant;
  }

  bool _isOverdue(DateTime due) {
    if (task.status.isDone || task.archived || task.paused) return false;
    final now = DateTime.now();
    return DateTime(
      due.year,
      due.month,
      due.day,
    ).isBefore(DateTime(now.year, now.month, now.day));
  }

  String _shortDate(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$m/$d';
  }
}

class _ReadOnlyIntentIcon extends StatelessWidget {
  final bool isDone;
  final bool isArchived;
  final bool isPaused;

  const _ReadOnlyIntentIcon({
    required this.isDone,
    required this.isArchived,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = isArchived
        ? AppIcons.archive
        : isPaused
        ? AppIcons.paused
        : isDone
        ? AppIcons.complete
        : AppIcons.tasks;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.72),
            width: 1.1,
          ),
        ),
        child: Icon(icon, size: 15, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _MutedHint extends StatelessWidget {
  final String text;
  const _MutedHint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySecondary(context),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ReopenIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ReopenIconButton({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Reopen task',
      child: IconButton(
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        icon: Icon(AppIcons.reopen, size: 20, color: scheme.onSurfaceVariant),
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
      ),
    );
  }
}

class _CompleteSwipeBackground extends StatelessWidget {
  const _CompleteSwipeBackground();
  @override
  Widget build(BuildContext context) {
    final color = TaskStyle.completedColor();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.8),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: Icon(AppIcons.complete, color: color, size: 24),
    );
  }
}

class _CardGlassHighlight extends StatelessWidget {
  const _CardGlassHighlight();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.045 : 0.18),
                Colors.white.withValues(alpha: isDark ? 0.012 : 0.04),
                Colors.transparent,
              ],
              stops: const [0.0, 0.36, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
