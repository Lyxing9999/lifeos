import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../application/task_providers.dart';
import '../../../content/task_copy.dart';
import '../../../domain/entities/schedule_select_option.dart';
import '../../../../../core/widgets/app_form_section.dart';

class TaskScheduleLinkSection extends StatelessWidget {
  final ScheduleSelectOption? selected;
  final String? initialLinkedScheduleBlockId;
  final ValueChanged<ScheduleSelectOption?> onChanged;

  const TaskScheduleLinkSection({
    super.key,
    required this.selected,
    required this.initialLinkedScheduleBlockId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: TaskCopy.formSectionAdvanced,
      subtitle: 'Optional links and context',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TaskCopy.formScheduleLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          _ScheduleBlockSelector(
            selected: selected,
            initialLinkedScheduleBlockId: initialLinkedScheduleBlockId,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ScheduleBlockSelector extends ConsumerWidget {
  final ScheduleSelectOption? selected;
  final String? initialLinkedScheduleBlockId;
  final ValueChanged<ScheduleSelectOption?> onChanged;

  const _ScheduleBlockSelector({
    required this.selected,
    required this.initialLinkedScheduleBlockId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(taskScheduleSelectOptionsProvider);

    return optionsAsync.when(
      loading: () {
        return const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          title: Text('Loading schedule blocks...'),
        );
      },
      error: (error, _) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            AppIcons.error,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Could not load schedule blocks'),
          subtitle: Text(error.toString()),
          trailing: IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: () => ref.invalidate(taskScheduleSelectOptionsProvider),
          ),
        );
      },
      data: (options) {
        final resolvedSelected =
            selected ??
            _resolveInitialSelection(options, initialLinkedScheduleBlockId);

        if (options.isEmpty) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              AppIcons.calendar,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: const Text(TaskCopy.formScheduleEmpty),
            subtitle: const Text(
              'Create a schedule block first, then link tasks to it.',
            ),
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () async {
            final value = await _openSchedulePicker(
              context: context,
              options: options,
              current: resolvedSelected,
            );

            HapticFeedback.selectionClick();
            onChanged(value);
          },
          child: Container(
            padding: AppSpacing.cardInsetsSm,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  resolvedSelected == null
                      ? AppIcons.schedule
                      : AppIcons.linked,
                  color: resolvedSelected == null
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolvedSelected?.title ?? TaskCopy.formScheduleNone,
                        style: AppTextStyles.cardTitle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resolvedSelected?.label ?? TaskCopy.formScheduleHint,
                        style: AppTextStyles.bodySecondary(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (resolvedSelected != null)
                  IconButton(
                    tooltip: TaskCopy.formScheduleClear,
                    icon: const Icon(AppIcons.close),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onChanged(null);
                    },
                  )
                else
                  const Icon(AppIcons.chevronRight),
              ],
            ),
          ),
        );
      },
    );
  }

  ScheduleSelectOption? _resolveInitialSelection(
    List<ScheduleSelectOption> options,
    String? linkedId,
  ) {
    final id = (linkedId ?? '').trim();
    if (id.isEmpty) return null;

    for (final option in options) {
      if (option.scheduleBlockId == id || option.value == id) {
        return option;
      }
    }

    return null;
  }

  Future<ScheduleSelectOption?> _openSchedulePicker({
    required BuildContext context,
    required List<ScheduleSelectOption> options,
    required ScheduleSelectOption? current,
  }) {
    return showModalBottomSheet<ScheduleSelectOption?>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.cardLg),
        ),
      ),
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.30,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  TaskCopy.formScheduleLabel,
                  style: AppTextStyles.pageTitle(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  TaskCopy.formScheduleHint,
                  style: AppTextStyles.bodySecondary(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    AppIcons.unlinked,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  title: const Text(TaskCopy.formScheduleNone),
                  subtitle: const Text('Keep this task independent.'),
                  onTap: () => Navigator.of(context).pop(null),
                ),
                const Divider(),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected =
                          current?.scheduleBlockId == option.scheduleBlockId;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          AppIcons.schedule,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          option.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? Icon(
                                AppIcons.success,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(option),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
