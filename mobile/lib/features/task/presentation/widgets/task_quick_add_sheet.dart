import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_button.dart';
import '../../content/task_copy.dart';

/// Low-friction bottom sheet for quickly adding a task.
/// Only the title is required. Everything else is optional tap-to-select.
/// No free-text date fields. No typing categories.
///
/// Usage:
///   final result = await TaskQuickAddSheet.show(context);
class TaskQuickAddSheet extends StatefulWidget {
  const TaskQuickAddSheet({super.key});

  static Future<TaskQuickAddResult?> show(BuildContext context) {
    return showModalBottomSheet<TaskQuickAddResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.cardLg),
        ),
      ),
      builder: (_) => const TaskQuickAddSheet(),
    );
  }

  @override
  State<TaskQuickAddSheet> createState() => _TaskQuickAddSheetState();
}

class _TaskQuickAddSheetState extends State<TaskQuickAddSheet> {
  final _titleController = TextEditingController();
  final _titleFocus = FocusNode();

  String? _category;
  DateTime? _dueDate;

  static const List<String> _categories = [
    'Work',
    'Personal',
    'Health',
    'Finance',
    TaskCopy.formCategoryDefault,
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _titleFocus.requestFocus());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _titleFocus.requestFocus();
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      TaskQuickAddResult(
        title: title,
        category: _category ?? TaskCopy.formCategoryDefault,
        dueDate: _dueDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, d MMM');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text('New Task', style: AppTextStyles.pageTitle(context)),
            const SizedBox(height: AppSpacing.xl),

            // Task title — only required field, autofocused
            TextField(
              controller: _titleController,
              focusNode: _titleFocus,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.cardTitle(context),
              decoration: InputDecoration(
                hintText: TaskCopy.formTitleHint,
                hintStyle: AppTextStyles.cardTitle(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(height: AppSpacing.xl),

            // Category chips — tap to select, no typing
            Text('Category', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _categories
                  .map(
                    (label) => AppChip.filter(
                      label: label,
                      selected: _category == label,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _category = _category == label ? null : label;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Due date — tap to open calendar, tap X to clear
            Text('Due Date', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickDueDate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: _dueDate != null
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: _dueDate != null
                      ? Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.date,
                      size: 18,
                      color: _dueDate != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _dueDate != null
                            ? dateFormat.format(_dueDate!)
                            : 'No due date',
                        style: AppTextStyles.cardTitle(context).copyWith(
                          color: _dueDate != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _dueDate = null);
                        },
                        child: Icon(
                          AppIcons.close,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: AppButton.primary(
                label: TaskCopy.formSubmitCreate,
                icon: AppIcons.addTask,
                onPressed: _submit,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result ─────────────────────────────────────────────────────────────────────

class TaskQuickAddResult {
  final String title;
  final String? category;
  final DateTime? dueDate;

  const TaskQuickAddResult({
    required this.title,
    required this.category,
    required this.dueDate,
  });
}
