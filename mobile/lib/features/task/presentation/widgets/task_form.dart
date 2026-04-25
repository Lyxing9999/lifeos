import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_form_section.dart';
import '../../../../core/widgets/app_form_widget.dart';
import '../../../../core/widgets/app_picker_tile.dart';
import '../../content/task_copy.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';
import '../../domain/model/task.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TaskForm — Senior-level embedded form widget.
//
// This is NOT a page — it does NOT use AppFormMixin or wrap in a Form.
// The parent page (TaskFormPage) provides:
//   • The Form key via buildFormPage()
//   • The submit bar
//   • The pop-after-submit
//
// This widget is responsible for:
//   • Field state + controllers
//   • Inline validation via TextFormField (validated by parent Form key)
//   • Keyboard focus chaining
//   • Auto-tag on comma/Enter
//   • Chip pickers for mode/priority (zero typing)
//   • Date formatting via intl
//   • Cross-field validation
//   • Collecting and submitting TaskFormInput
// ─────────────────────────────────────────────────────────────────────────────

class TaskForm extends StatefulWidget {
  final Task? existing;
  final bool isSaving;
  final TaskFormController? controller;
  final Future<void> Function(TaskFormInput result) onSubmit;

  const TaskForm({
    super.key,
    this.existing,
    required this.isSaving,
    this.controller,
    required this.onSubmit,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  // ── Controllers ────────────────────────────────────────────────────────

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _tagController;
  late final TextEditingController _linkedScheduleBlockController;

  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _customCategoryFocus = FocusNode();

  // ── State ──────────────────────────────────────────────────────────────

  late TaskMode _taskMode;
  late TaskPriority _priority;
  late TaskRecurrenceType _recurrenceType;

  DateTime? _dueDate;
  bool _useDueTime = false;
  TimeOfDay? _dueTime;

  int _progressPercent = 0;
  String _selectedCategory = TaskCopy.formCategoryDefault;
  bool _showCustomCategory = false;
  bool _showDescription = false;

  bool _showRecurrence = false;
  DateTime? _recurrenceStartDate;
  DateTime? _recurrenceEndDate;
  final Set<String> _recurrenceDaysOfWeek = <String>{};

  final List<String> _tags = <String>[];

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _customCategoryController = TextEditingController();
    _tagController = TextEditingController();
    _linkedScheduleBlockController = TextEditingController(
      text: existing?.linkedScheduleBlockId ?? '',
    );

    final existingCategory = (existing?.category ?? '').trim();
    if (existingCategory.isEmpty) {
      _selectedCategory = TaskCopy.formCategoryDefault;
      _showCustomCategory = false;
    } else if (_taskCategoryOptions.contains(existingCategory)) {
      _selectedCategory = existingCategory;
      _showCustomCategory = false;
    } else {
      _selectedCategory = TaskCopy.formCategoryDefault;
      _showCustomCategory = true;
      _customCategoryController.text = existingCategory;
    }

    _showDescription = (existing?.description ?? '').trim().isNotEmpty;

    _taskMode = existing?.taskMode ?? TaskMode.standard;
    _priority = existing?.priority ?? TaskPriority.medium;
    _recurrenceType = existing?.recurrenceType ?? TaskRecurrenceType.none;

    _dueDate =
        existing?.dueDate ??
        (existing?.dueDateTime == null
            ? DateTime.now() // Smart default: today for new tasks
            : DateTime(
                existing!.dueDateTime!.year,
                existing.dueDateTime!.month,
                existing.dueDateTime!.day,
              ));

    if (existing?.dueDateTime != null) {
      _useDueTime = true;
      _dueTime = TimeOfDay.fromDateTime(existing!.dueDateTime!);
    }

    _progressPercent = existing?.progressPercent ?? 0;

    _showRecurrence = _recurrenceType.isRecurring;
    _recurrenceStartDate = existing?.recurrenceStartDate;
    _recurrenceEndDate = existing?.recurrenceEndDate;
    _recurrenceDaysOfWeek.addAll(existing?.recurrenceDaysOfWeek ?? const []);

    _tags.addAll(
      (existing?.tags ?? const [])
          .map((tag) => tag.name.trim())
          .where((name) => name.isNotEmpty),
    );

    widget.controller?._submit = _submit;
    Future.microtask(() => _titleFocus.requestFocus());
  }

  @override
  void didUpdateWidget(covariant TaskForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._submit = null;
    }
    widget.controller?._submit = _submit;
  }

  @override
  void dispose() {
    if (widget.controller?._submit == _submit) {
      widget.controller?._submit = null;
    }
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _tagController.dispose();
    _linkedScheduleBlockController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _customCategoryFocus.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) => DateFormat.yMMMd().format(date);

  /// Show a themed error SnackBar for cross-field validation.
  void _showError(String message) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: cs.onError, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );
  }

  String? _nullIfBlank(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? null : text;
  }

  List<String> _orderedDays(List<String> days) {
    return _weekdayOptions.where(days.contains).toList();
  }

  String _resolvedCategory() {
    if (_showCustomCategory) {
      return _nullIfBlank(_customCategoryController.text) ??
          TaskCopy.formCategoryDefault;
    }
    return _selectedCategory.trim().isEmpty
        ? TaskCopy.formCategoryDefault
        : _selectedCategory;
  }

  // ── Pickers ────────────────────────────────────────────────────────────

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _dueTime = picked);
    }
  }

  Future<void> _pickRecurrenceStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _recurrenceStartDate = picked);
    }
  }

  Future<void> _pickRecurrenceEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _recurrenceEndDate ?? (_recurrenceStartDate ?? DateTime.now()),
      firstDate: _recurrenceStartDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      setState(() => _recurrenceEndDate = picked);
    }
  }

  // ── Interactions ───────────────────────────────────────────────────────

  void _handleModeChange(TaskMode mode) {
    HapticFeedback.selectionClick();
    setState(() {
      _taskMode = mode;
      if (_taskMode != TaskMode.progress) {
        _progressPercent = 0;
      }
      if (_taskMode != TaskMode.daily &&
          _recurrenceType == TaskRecurrenceType.none) {
        _showRecurrence = false;
      }
    });
  }

  void _selectCategory(String category) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = category;
      _showCustomCategory = false;
      _customCategoryController.clear();
    });
  }

  void _toggleCustomCategory() {
    HapticFeedback.selectionClick();
    setState(() {
      _showCustomCategory = !_showCustomCategory;
      if (!_showCustomCategory) {
        _customCategoryController.clear();
      }
    });
    if (_showCustomCategory) {
      Future.microtask(() => _customCategoryFocus.requestFocus());
    }
  }

  void _addTag() {
    final raw = _tagController.text.trim().toLowerCase();
    final tag = raw.endsWith(',')
        ? raw.substring(0, raw.length - 1).trim()
        : raw;
    if (tag.isEmpty || _tags.contains(tag)) {
      _tagController.clear();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _tags.add(tag);
      _tagController.clear();
    });
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Cross-field validation (not coverable by inline TextFormField validators)
    if (_taskMode == TaskMode.progress &&
        (_progressPercent < 0 || _progressPercent > 100)) {
      _showError('Progress must be between 0 and 100.');
      return;
    }

    if (_showRecurrence && _recurrenceType != TaskRecurrenceType.none) {
      if (_recurrenceStartDate == null) {
        _showError('Recurrence start date is required.');
        return;
      }
      if (_recurrenceType == TaskRecurrenceType.customWeekly &&
          _recurrenceDaysOfWeek.isEmpty) {
        _showError('Select at least one weekday for custom weekly recurrence.');
        return;
      }
      if (_recurrenceEndDate != null &&
          _recurrenceStartDate != null &&
          _recurrenceEndDate!.isBefore(_recurrenceStartDate!)) {
        _showError('Recurrence end date cannot be before start date.');
        return;
      }
    }

    final dueDateTime = (_dueDate != null && _useDueTime && _dueTime != null)
        ? DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            _dueTime!.hour,
            _dueTime!.minute,
          )
        : null;

    await widget.onSubmit(
      TaskFormInput(
        title: _titleController.text.trim(),
        description: _nullIfBlank(_descriptionController.text),
        category: _resolvedCategory(),
        taskMode: _taskMode,
        priority: _priority,
        dueDate: _dueDate,
        dueDateTime: dueDateTime,
        progressPercent: _taskMode == TaskMode.progress
            ? _progressPercent
            : null,
        recurrenceType: _showRecurrence
            ? _recurrenceType
            : TaskRecurrenceType.none,
        recurrenceStartDate: _showRecurrence ? _recurrenceStartDate : null,
        recurrenceEndDate: _showRecurrence ? _recurrenceEndDate : null,
        recurrenceDaysOfWeek: _showRecurrence
            ? _orderedDays(_recurrenceDaysOfWeek.toList())
            : const [],
        tags: _tags,
        linkedScheduleBlockId: _nullIfBlank(
          _linkedScheduleBlockController.text,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final recurrenceVisible = _showRecurrence && _recurrenceType.isRecurring;

    // No Form wrapper here — the parent TaskFormPage.buildFormPage() provides it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── What ───────────────────────────────────────────────────
        AppFormSection(
          title: TaskCopy.formSectionWhat,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                labelText: TaskCopy.formTitleLabel,
                hintText: TaskCopy.formTitleHint,
                textInputAction: TextInputAction.done,
                validator: FormValidators.requiredField(
                  TaskCopy.formTitleLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                TaskCopy.formCategoryLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ..._taskCategoryOptions.map(
                    (category) => AppChip.filter(
                      label: category,
                      selected:
                          !_showCustomCategory && _selectedCategory == category,
                      onTap: () => _selectCategory(category),
                    ),
                  ),
                  AppChip.filter(
                    label: TaskCopy.formCategoryMore,
                    icon: Icons.edit_outlined,
                    selected: _showCustomCategory,
                    onTap: _toggleCustomCategory,
                  ),
                ],
              ),
              if (_showCustomCategory) ...[
                const SizedBox(height: AppSpacing.sm),
                AppTextFormField(
                  controller: _customCategoryController,
                  focusNode: _customCategoryFocus,
                  labelText: TaskCopy.formCategoryCustomLabel,
                  hintText: TaskCopy.formCategoryCustomHint,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showDescription = !_showDescription);
                  if (_showDescription) {
                    Future.microtask(() => _descriptionFocus.requestFocus());
                  }
                },
                icon: Icon(
                  _showDescription
                      ? Icons.notes_outlined
                      : Icons.note_add_outlined,
                  size: 18,
                ),
                label: Text(
                  _showDescription
                      ? TaskCopy.formHideNote
                      : TaskCopy.formAddNote,
                ),
              ),
              if (_showDescription)
                AppTextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  labelText: TaskCopy.formNoteLabel,
                  hintText: TaskCopy.formNoteHint,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
            ],
          ),
        ),

        // ── When ───────────────────────────────────────────────────
        AppFormSection(
          title: TaskCopy.formSectionWhen,
          subtitle:
              _taskMode == TaskMode.urgent && (_dueDate == null || !_useDueTime)
              ? 'Urgent tasks should have a date and time'
              : null,
          child: Column(
            children: [
              AppPickerTile(
                label: 'Due date',
                icon: Icons.calendar_today_outlined,
                value: _dueDate == null ? 'Not set' : _formatDate(_dueDate!),
                onTap: _pickDueDate,
                trailing: _dueDate == null
                    ? null
                    : IconButton(
                        onPressed: () => setState(() {
                          _dueDate = null;
                          _useDueTime = false;
                          _dueTime = null;
                        }),
                        icon: const Icon(Icons.close),
                      ),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _useDueTime,
                onChanged: _dueDate == null
                    ? null
                    : (value) => setState(() => _useDueTime = value),
                title: const Text('Use due time'),
              ),
              if (_useDueTime)
                AppPickerTile(
                  label: 'Due time',
                  icon: Icons.schedule,
                  value: _dueTime == null
                      ? 'Pick time'
                      : _dueTime!.format(context),
                  onTap: _pickDueTime,
                ),
            ],
          ),
        ),

        // ── How ────────────────────────────────────────────────────
        AppFormSection(
          title: TaskCopy.formSectionHow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: TaskMode.values
                    .map(
                      (mode) => AppChip.filter(
                        label: mode.label,
                        selected: _taskMode == mode,
                        onTap: () => _handleModeChange(mode),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: TaskPriority.values
                    .map(
                      (priority) => AppChip.filter(
                        label: priority.label,
                        selected: _priority == priority,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _priority = priority);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),

        // ── Progress (conditional) ─────────────────────────────────
        if (_taskMode == TaskMode.progress)
          AppFormSection(
            title: TaskCopy.formSectionProgress,
            subtitle: TaskCopy.formProgressSubtitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        TaskCopy.formProgressCurrent,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Text(
                      '$_progressPercent%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _progressPercent.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '$_progressPercent%',
                  onChanged: (value) {
                    setState(() => _progressPercent = value.round());
                  },
                ),
                Text(
                  TaskCopy.progressHint(_progressPercent),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

        // ── Repeat ─────────────────────────────────────────────────
        AppFormSection(
          title: TaskCopy.formSectionRepeat,
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _showRecurrence,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _showRecurrence = value;
                    if (_showRecurrence) {
                      // Smart default: auto-select 'daily' so user
                      // doesn't land on 'None' chip which hides everything.
                      if (_recurrenceType == TaskRecurrenceType.none) {
                        _recurrenceType = TaskRecurrenceType.daily;
                      }
                    } else {
                      _recurrenceType = TaskRecurrenceType.none;
                      _recurrenceStartDate = null;
                      _recurrenceEndDate = null;
                      _recurrenceDaysOfWeek.clear();
                    }
                  });
                },
                title: const Text('Repeat task'),
              ),
              if (_showRecurrence) ...[
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: TaskRecurrenceType.values
                      .where((type) => type != TaskRecurrenceType.none)
                      .map(
                        (type) => AppChip.filter(
                          label: type.label,
                          selected: _recurrenceType == type,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _recurrenceType = type;
                              if (_recurrenceType !=
                                  TaskRecurrenceType.customWeekly) {
                                _recurrenceDaysOfWeek.clear();
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                if (recurrenceVisible) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppPickerTile(
                    label: 'Recurrence start',
                    icon: Icons.play_circle_outline,
                    value: _recurrenceStartDate == null
                        ? 'Pick date'
                        : _formatDate(_recurrenceStartDate!),
                    onTap: _pickRecurrenceStartDate,
                  ),
                  AppPickerTile(
                    label: 'Recurrence end',
                    icon: Icons.stop_circle_outlined,
                    value: _recurrenceEndDate == null
                        ? 'Optional'
                        : _formatDate(_recurrenceEndDate!),
                    onTap: _pickRecurrenceEndDate,
                  ),
                ],
                if (_recurrenceType == TaskRecurrenceType.customWeekly)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _weekdayOptions
                          .map(
                            (day) => FilterChip(
                              label: Text(_weekdayLabel(day)),
                              selected: _recurrenceDaysOfWeek.contains(day),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _recurrenceDaysOfWeek.add(day);
                                  } else {
                                    _recurrenceDaysOfWeek.remove(day);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ],
          ),
        ),

        // ── Tags ───────────────────────────────────────────────────
        AppFormSection(
          title: TaskCopy.formSectionTags,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      textCapitalization: TextCapitalization.none,
                      decoration: const InputDecoration(
                        labelText: 'Add tag',
                        hintText: 'focus, deep-work, errands',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.sell_outlined, size: 18),
                      ),
                      onSubmitted: (_) => _addTag(),
                      onChanged: (value) {
                        if (value.endsWith(',') || value.endsWith(' ,')) {
                          _addTag();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(onPressed: _addTag, icon: const Icon(Icons.add)),
                ],
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _tags
                      .map(
                        (tag) => InputChip(
                          label: Text(tag),
                          onDeleted: () {
                            HapticFeedback.selectionClick();
                            setState(() => _tags.remove(tag));
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        // ── Advanced (collapsed) ──────────────────────────────────
        AppFormSection(
          title: TaskCopy.formSectionAdvanced,
          child: AppTextFormField(
            controller: _linkedScheduleBlockController,
            labelText: 'Linked Schedule Block',
            hintText: 'Paste a schedule block ID (optional)',
            prefixIcon: Icons.link_rounded,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }

  String _weekdayLabel(String day) {
    switch (day) {
      case 'MONDAY':
        return 'Mon';
      case 'TUESDAY':
        return 'Tue';
      case 'WEDNESDAY':
        return 'Wed';
      case 'THURSDAY':
        return 'Thu';
      case 'FRIDAY':
        return 'Fri';
      case 'SATURDAY':
        return 'Sat';
      case 'SUNDAY':
        return 'Sun';
      default:
        return day;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller (unchanged public API)
// ─────────────────────────────────────────────────────────────────────────────

class TaskFormController {
  Future<void> Function()? _submit;

  Future<void> submit() async {
    await _submit?.call();
  }
}

const List<String> _taskCategoryOptions = <String>[
  'Work',
  'Personal',
  'Health',
  'Finance',
  TaskCopy.formCategoryDefault,
];

const List<String> _weekdayOptions = <String>[
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

// ─────────────────────────────────────────────────────────────────────────────
// TaskFormInput (unchanged public API)
// ─────────────────────────────────────────────────────────────────────────────

class TaskFormInput {
  final String title;
  final String? description;
  final String? category;
  final TaskMode taskMode;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime? dueDateTime;
  final int? progressPercent;
  final TaskRecurrenceType recurrenceType;
  final DateTime? recurrenceStartDate;
  final DateTime? recurrenceEndDate;
  final List<String> recurrenceDaysOfWeek;
  final List<String> tags;
  final String? linkedScheduleBlockId;

  const TaskFormInput({
    required this.title,
    required this.description,
    required this.category,
    required this.taskMode,
    required this.priority,
    required this.dueDate,
    required this.dueDateTime,
    required this.progressPercent,
    required this.recurrenceType,
    required this.recurrenceStartDate,
    required this.recurrenceEndDate,
    required this.recurrenceDaysOfWeek,
    required this.tags,
    required this.linkedScheduleBlockId,
  });
}
