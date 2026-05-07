import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_glass_icon_button.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_button.dart';
import '../../application/schedule_providers.dart';
import '../../content/schedule_copy.dart';
import '../../domain/command/update_schedule_block_command.dart';
import '../../domain/entities/schedule_block.dart';
import '../../domain/enum/schedule_block_type.dart';
import '../../domain/enum/schedule_recurrence_type.dart';
import '../widgets/schedule_type_chip.dart';
import 'schedule_form_page.dart';

enum _ScheduleDetailMenuAction { activate, remove }

enum _ScheduleRemoveAction { primary, deletePermanently, cancel }

class ScheduleDetailPage extends ConsumerStatefulWidget {
  final String id;

  const ScheduleDetailPage({super.key, required this.id});

  @override
  ConsumerState<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends ConsumerState<ScheduleDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(scheduleNotifierProvider.notifier).loadById(id: widget.id);
    });
  }

  Future<void> _openEdit(ScheduleBlock block) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Consumer(
          builder: (context, ref, child) {
            final formState = ref.watch(scheduleNotifierProvider);
            return ScheduleFormPage(
              existing: block,
              isSaving: formState.isSaving,
              shouldPopOnSubmit: false,
              onSubmit: (result) async {
                final command = UpdateScheduleBlockCommand(
                  title: result.title,
                  description: result.description,
                  type: result.type,
                  recurrenceType: result.recurrenceType,
                  startTime: result.startTime,
                  endTime: result.endTime,
                  recurrenceDaysOfWeek: result.daysOfWeek,
                  recurrenceStartDate: result.recurrenceStartDate,
                  recurrenceEndDate: result.recurrenceEndDate,
                  active: block.active,
                );

                // STRICT ARCHITECTURE: Use Coordinator
                await ref
                    .read(scheduleMutationCoordinatorProvider)
                    .update(id: block.id, command: command);

                final latest = ref.read(scheduleNotifierProvider);
                if (!context.mounted) return;

                if (latest.errorMessage != null) {
                  AppFeedback.error(context, message: latest.errorMessage!);
                  return;
                }

                Navigator.of(context).pop(ScheduleCopy.successUpdated);
              },
            );
          },
        ),
      ),
    );

    if (!mounted) return;
    if (result is String && result.trim().isNotEmpty) {
      AppFeedback.success(context, title: 'Updated', message: result);
    }

    await ref.read(scheduleNotifierProvider.notifier).loadById(id: widget.id);
  }

  Future<_ScheduleRemoveAction?> _showRemoveDialog(bool isActive) {
    return showDialog<_ScheduleRemoveAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ScheduleCopy.removeDialogTitle),
        actions: [
          AppButton.ghost(
            onPressed: () =>
                Navigator.of(ctx).pop(_ScheduleRemoveAction.cancel),
            label: ScheduleCopy.cancelAction,
          ),
          AppButton.ghost(
            onPressed: () =>
                Navigator.of(ctx).pop(_ScheduleRemoveAction.deletePermanently),
            label: ScheduleCopy.removeDialogDelete,
          ),
          AppButton.primary(
            onPressed: () =>
                Navigator.of(ctx).pop(_ScheduleRemoveAction.primary),
            label: isActive
                ? ScheduleCopy.removeDialogDeactivate
                : ScheduleCopy.removeDialogActivate,
          ),
        ],
      ),
    );
  }

  Future<void> _runPrimaryScheduleAction({required ScheduleBlock block}) async {
    if (block.active) {
      // STRICT ARCHITECTURE: Use Coordinator
      await ref
          .read(scheduleMutationCoordinatorProvider)
          .deactivate(id: block.id);
      if (!mounted) return;

      final latest = ref.read(scheduleNotifierProvider);
      if (latest.errorMessage != null) {
        AppFeedback.error(context, message: latest.errorMessage!);
        return;
      }
      Navigator.of(context).pop(ScheduleCopy.successDeactivated);
      return;
    }

    // STRICT ARCHITECTURE: Use Coordinator
    await ref.read(scheduleMutationCoordinatorProvider).activate(id: block.id);
    if (!mounted) return;

    final latest = ref.read(scheduleNotifierProvider);
    if (latest.errorMessage != null) {
      AppFeedback.error(context, message: latest.errorMessage!);
      return;
    }
    Navigator.of(context).pop(ScheduleCopy.successActivated);
  }

  Future<void> _deleteSchedule({required ScheduleBlock block}) async {
    // STRICT ARCHITECTURE: Use Coordinator
    await ref.read(scheduleMutationCoordinatorProvider).delete(id: block.id);
    if (!mounted) return;

    final latest = ref.read(scheduleNotifierProvider);
    if (latest.errorMessage != null) {
      AppFeedback.error(context, message: latest.errorMessage!);
      return;
    }
    Navigator.of(context).pop(ScheduleCopy.successDeleted);
  }

  Future<void> _openRemoveDialog({required ScheduleBlock block}) async {
    final action = await _showRemoveDialog(block.active);
    if (action == null || action == _ScheduleRemoveAction.cancel) return;

    if (action == _ScheduleRemoveAction.primary) {
      await _runPrimaryScheduleAction(block: block);
      return;
    }

    await _deleteSchedule(block: block);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleNotifierProvider);
    final block = state.selectedItem;

    if (block == null || block.id != widget.id) {
      return const Scaffold(body: AppLoadingView());
    }

    final dateFormat = DateFormat('EEE, d MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(ScheduleCopy.detailTitle),
        actions: [
          AppGlassIconButton(
            icon: AppIcons.edit,
            tooltip: 'Edit',
            onPressed: () async => await _openEdit(block),
          ),
          PopupMenuButton<_ScheduleDetailMenuAction>(
            onSelected: (action) async {
              if (action == _ScheduleDetailMenuAction.activate) {
                await _runPrimaryScheduleAction(block: block);
                return;
              }
              await _openRemoveDialog(block: block);
            },
            itemBuilder: (context) => [
              if (!block.active)
                const PopupMenuItem(
                  value: _ScheduleDetailMenuAction.activate,
                  child: Text(ScheduleCopy.activateTooltip),
                ),
              const PopupMenuItem(
                value: _ScheduleDetailMenuAction.remove,
                child: Text(ScheduleCopy.removeDialogTitle),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.pageVertical,
          AppSpacing.pageHorizontal,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(block.title, style: AppTextStyles.pageTitle(context)),
            const SizedBox(height: AppSpacing.sm),
            ScheduleTypeChip(type: block.type),
            const SizedBox(height: AppSpacing.xl),

            _DetailCard(
              title: ScheduleCopy.detailSectionCore,
              rows: [
                _DetailRow(ScheduleCopy.detailType, block.type.label),
                _DetailRow(
                  ScheduleCopy.detailDescription,
                  (block.description ?? '').trim().isEmpty
                      ? ScheduleCopy.detailNoDescription
                      : block.description!,
                ),
                _DetailRow(
                  ScheduleCopy.detailStatus,
                  block.active
                      ? ScheduleCopy.detailStatusActive
                      : ScheduleCopy.detailStatusInactive,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _DetailCard(
              title: ScheduleCopy.detailSectionRecurrenceWindow,
              rows: [
                _DetailRow(
                  ScheduleCopy.detailRecurrenceStartDate,
                  dateFormat.format(block.recurrenceStartDate),
                ),
                _DetailRow(
                  ScheduleCopy.detailRecurrenceEndDate,
                  block.recurrenceEndDate != null
                      ? dateFormat.format(block.recurrenceEndDate!)
                      : ScheduleCopy.noEndDate,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _DetailCard(
              title: ScheduleCopy.detailSectionTime,
              rows: [
                _DetailRow(
                  ScheduleCopy.detailStartTime,
                  block.startTime.format(context),
                ),
                _DetailRow(
                  ScheduleCopy.detailEndTime,
                  block.endTime.format(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _DetailCard(
              title: ScheduleCopy.detailSectionRecurrence,
              rows: [
                _DetailRow(
                  ScheduleCopy.detailRecurrenceType,
                  block.recurrenceType.label,
                ),
                _DetailRow(
                  ScheduleCopy.detailRecurrenceDays,
                  block.recurrenceDaysOfWeek.isEmpty
                      ? ScheduleCopy.detailNone
                      : block.recurrenceDaysOfWeek.map(_dayLabel).join(', '),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '$day';
    }
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;

  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionHeader(context)),
          const SizedBox(height: AppSpacing.sm),
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final isLast = index == rows.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: AppTextStyles.bodySecondary(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      row.value,
                      style: AppTextStyles.cardTitle(context),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);
}
