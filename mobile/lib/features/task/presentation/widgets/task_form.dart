import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../content/task_copy.dart';
import '../../domain/enum/task_mode.dart';
import '../../domain/enum/task_priority.dart';
import '../../domain/enum/task_recurrence_type.dart';
import '../../domain/entities/schedule_select_option.dart';
import '../../domain/entities/task.dart';
import 'form/task_due_section.dart';
import 'form/task_form_constants.dart';
import 'form/task_form_models.dart';
import 'form/task_identity_section.dart';
import 'form/task_mode_priority_section.dart';
import 'form/task_progress_section.dart';
import 'form/task_recurrence_section.dart';
import 'form/task_schedule_link_section.dart';
import 'form/task_tags_section.dart';

export 'form/task_form_models.dart';

class TaskForm extends StatefulWidget {
  final Task? existing;
  final bool isSaving;
  final TaskFormController? controller;
  final Future<void> Function(
    TaskFormInput result,
    BuildContext feedbackContext,
  )
  onSubmit;

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
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _tagController;

  final _titleFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _customCategoryFocus = FocusNode();

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

  ScheduleSelectOption? _selectedScheduleBlock;
  String? _initialLinkedScheduleBlockId;

  bool _didChangeScheduleBlock = false;
  bool _didClearDueDate = false;
  bool _didClearDueDateTime = false;
  bool _didClearRecurrence = false;

  bool get _isEditing => widget.existing != null;

  bool get _hasDuePlanning {
    return _dueDate != null || _useDueTime || _dueTime != null;
  }

  bool get _hasRecurrencePlanning {
    return _showRecurrence && _recurrenceType.isRecurring;
  }

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

    _taskMode = existing?.taskMode ?? TaskMode.standard;
    _priority = existing?.priority ?? TaskPriority.medium;
    _recurrenceType = existing?.recurrenceType ?? TaskRecurrenceType.none;

    _hydrateCategory(existing);
    _hydrateDueDate(existing);
    _hydrateRecurrence(existing);
    _hydrateTags(existing);

    _showDescription = (existing?.description ?? '').trim().isNotEmpty;
    _initialLinkedScheduleBlockId = existing?.linkedScheduleBlockId?.trim();

    widget.controller?.bind(_submit);

    Future.microtask(() {
      if (mounted && !_isEditing) {
        _titleFocus.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TaskForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.unbind(_submit);
      widget.controller?.bind(_submit);
    }
  }

  @override
  void dispose() {
    widget.controller?.unbind(_submit);

    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _tagController.dispose();

    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _customCategoryFocus.dispose();

    super.dispose();
  }

  void _hydrateCategory(Task? existing) {
    final category = (existing?.category ?? '').trim();

    if (category.isEmpty) {
      _selectedCategory = TaskCopy.formCategoryDefault;
      _showCustomCategory = false;
      return;
    }

    if (taskCategoryOptions.contains(category)) {
      _selectedCategory = category;
      _showCustomCategory = false;
      return;
    }

    _selectedCategory = TaskCopy.formCategoryDefault;
    _showCustomCategory = true;
    _customCategoryController.text = category;
  }

  void _hydrateDueDate(Task? existing) {
    if (existing == null) {
      _dueDate = null;
      _useDueTime = false;
      _dueTime = null;
      _progressPercent = 0;
      return;
    }

    final dueDateTime = existing.dueDateTime;

    _dueDate =
        existing.dueDate ??
        (dueDateTime == null
            ? null
            : DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day));

    if (dueDateTime != null) {
      _useDueTime = true;
      _dueTime = TimeOfDay.fromDateTime(dueDateTime);
    } else {
      _useDueTime = false;
      _dueTime = null;
    }

    _progressPercent = existing.progressPercent;
  }

  void _hydrateRecurrence(Task? existing) {
    _showRecurrence = _recurrenceType.isRecurring;
    _recurrenceStartDate = existing?.recurrenceStartDate;
    _recurrenceEndDate = existing?.recurrenceEndDate;
    _recurrenceDaysOfWeek.addAll(existing?.recurrenceDaysOfWeek ?? const []);
  }

  void _hydrateTags(Task? existing) {
    _tags.addAll(
      (existing?.tags ?? const [])
          .map((tag) => tag.name.trim().toLowerCase())
          .where((name) => name.isNotEmpty)
          .toSet(),
    );
  }

  String? _nullIfBlank(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? null : text;
  }

  String _resolvedCategory() {
    if (_showCustomCategory) {
      return _nullIfBlank(_customCategoryController.text) ??
          TaskCopy.formCategoryDefault;
    }

    final category = _selectedCategory.trim();
    return category.isEmpty ? TaskCopy.formCategoryDefault : category;
  }

  List<String> _orderedDays() {
    return taskWeekdayOptions.where(_recurrenceDaysOfWeek.contains).toList();
  }

  DateTime _localDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _showError(String message) {
    if (!mounted) return;

    AppFeedback.error(context, title: 'Check task', message: message);
  }

  void _clearDuePlanning() {
    _dueDate = null;
    _useDueTime = false;
    _dueTime = null;

    _didClearDueDate = true;
    _didClearDueDateTime = true;
  }

  void _clearRecurrencePlanning() {
    _showRecurrence = false;
    _recurrenceType = TaskRecurrenceType.none;
    _recurrenceStartDate = null;
    _recurrenceEndDate = null;
    _recurrenceDaysOfWeek.clear();

    _didClearRecurrence = true;
  }

  void _makeOneTimePlanning() {
    if (_hasRecurrencePlanning || _showRecurrence) {
      _clearRecurrencePlanning();
    }
  }

  void _makeRecurringPlanning({TaskRecurrenceType? type, DateTime? startDate}) {
    if (_hasDuePlanning) {
      _clearDuePlanning();
    }

    _showRecurrence = true;
    _recurrenceType = type ?? _recurrenceType;

    if (!_recurrenceType.isRecurring) {
      _recurrenceType = TaskRecurrenceType.daily;
    }

    _recurrenceStartDate ??= _localDay(startDate ?? DateTime.now());
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    HapticFeedback.selectionClick();

    setState(() {
      _makeOneTimePlanning();

      _dueDate = _localDay(picked);
      _didClearDueDate = false;
    });
  }

  Future<void> _pickDueTime() async {
    if (_dueDate == null) {
      _showError('Select a due date before adding a due time.');
      return;
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (picked == null) return;

    HapticFeedback.selectionClick();

    setState(() {
      _makeOneTimePlanning();

      _useDueTime = true;
      _dueTime = picked;
      _didClearDueDateTime = false;
    });
  }

  Future<void> _pickRecurrenceStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    HapticFeedback.selectionClick();

    setState(() {
      _makeRecurringPlanning(
        type: _recurrenceType.isRecurring
            ? _recurrenceType
            : TaskRecurrenceType.daily,
        startDate: picked,
      );

      _recurrenceStartDate = _localDay(picked);
      _didClearRecurrence = false;
    });
  }

  Future<void> _pickRecurrenceEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? _recurrenceStartDate ?? DateTime.now(),
      firstDate: _recurrenceStartDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    HapticFeedback.selectionClick();

    setState(() {
      _makeRecurringPlanning(
        type: _recurrenceType.isRecurring
            ? _recurrenceType
            : TaskRecurrenceType.daily,
        startDate: _recurrenceStartDate ?? DateTime.now(),
      );

      _recurrenceEndDate = _localDay(picked);
      _didClearRecurrence = false;
    });
  }

  void _handleModeChange(TaskMode mode) {
    HapticFeedback.selectionClick();

    setState(() {
      _taskMode = mode;

      if (_taskMode != TaskMode.progress) {
        _progressPercent = 0;
      }

      if (_taskMode == TaskMode.progress) {
        _clearRecurrencePlanning();
      }

      if (_taskMode == TaskMode.daily) {
        _makeRecurringPlanning(
          type: TaskRecurrenceType.daily,
          startDate: _recurrenceStartDate ?? DateTime.now(),
        );
        _didClearRecurrence = false;
      }
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
      Future.microtask(() {
        if (mounted) {
          _customCategoryFocus.requestFocus();
        }
      });
    }
  }

  void _toggleDescription() {
    HapticFeedback.selectionClick();

    setState(() => _showDescription = !_showDescription);

    if (_showDescription) {
      Future.microtask(() {
        if (mounted) {
          _descriptionFocus.requestFocus();
        }
      });
    }
  }

  void _toggleRecurrence(bool value) {
    HapticFeedback.selectionClick();

    if (_taskMode == TaskMode.progress) {
      _showError('Progress tasks cannot repeat. Use a Daily task instead.');
      return;
    }

    if (value) {
      setState(() {
        _makeRecurringPlanning(
          type: _recurrenceType.isRecurring
              ? _recurrenceType
              : TaskRecurrenceType.daily,
          startDate: _recurrenceStartDate ?? DateTime.now(),
        );

        _didClearRecurrence = false;
      });

      return;
    }

    Future.microtask(() async {
      if (!_hasRecurrencePlanning) {
        if (!mounted) return;
        setState(() => _showRecurrence = false);
        return;
      }

      if (!mounted) return;
      final confirm = await AppFeedback.confirm(
        context,
        title: 'Clear recurrence',
        message: 'Remove recurrence settings for this task?',
        confirmLabel: 'Clear',
        cancelLabel: 'Keep',
      );

      if (confirm != true) return;
      if (!mounted) return;

      setState(() {
        _clearRecurrencePlanning();
      });
    });
  }

  void _selectRecurrenceType(TaskRecurrenceType type) {
    HapticFeedback.selectionClick();

    if (_taskMode == TaskMode.progress) {
      _showError('Progress tasks cannot repeat. Use a Daily task instead.');
      return;
    }

    setState(() {
      _makeRecurringPlanning(
        type: type,
        startDate: _recurrenceStartDate ?? DateTime.now(),
      );

      _didClearRecurrence = false;

      if (_recurrenceType != TaskRecurrenceType.customWeekly) {
        _recurrenceDaysOfWeek.clear();
      }
    });
  }

  void _toggleWeekday(String day) {
    HapticFeedback.selectionClick();

    if (_taskMode == TaskMode.progress) {
      _showError('Progress tasks cannot repeat. Use a Daily task instead.');
      return;
    }

    setState(() {
      _makeRecurringPlanning(
        type: TaskRecurrenceType.customWeekly,
        startDate: _recurrenceStartDate ?? DateTime.now(),
      );

      if (_recurrenceDaysOfWeek.contains(day)) {
        _recurrenceDaysOfWeek.remove(day);
      } else {
        _recurrenceDaysOfWeek.add(day);
      }

      _didClearRecurrence = false;
    });
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

  void _removeTag(String tag) {
    HapticFeedback.selectionClick();

    setState(() {
      _tags.remove(tag);
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

  void _changePriority(TaskPriority priority) {
    HapticFeedback.selectionClick();

    setState(() => _priority = priority);
  }

  void _changeScheduleBlock(ScheduleSelectOption? value) {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedScheduleBlock = value;
      _initialLinkedScheduleBlockId = value?.scheduleBlockId;
      _didChangeScheduleBlock = true;
    });
  }

  void _clearDueDate() {
    HapticFeedback.selectionClick();

    Future.microtask(() async {
      if (!_hasDuePlanning) return;

      if (!mounted) return;
      final confirm = await AppFeedback.confirm(
        context,
        title: 'Clear due date',
        message: 'Remove the due date and time for this task?',
        confirmLabel: 'Clear',
        cancelLabel: 'Keep',
      );

      if (confirm != true) return;
      if (!mounted) return;

      setState(() {
        _clearDuePlanning();
      });
    });
  }

  void _toggleDueTime(bool value) {
    HapticFeedback.selectionClick();

    setState(() {
      _makeOneTimePlanning();

      _useDueTime = value;

      if (value) {
        if (_dueDate == null) {
          _useDueTime = false;
          _dueTime = null;
          _showError('Select a due date before adding a due time.');
          return;
        }

        _dueTime ??= TimeOfDay.now();
        _didClearDueDateTime = false;
      } else {
        _dueTime = null;
        _didClearDueDateTime = true;
      }
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showError('Task title is required.');
      _titleFocus.requestFocus();
      return;
    }

    if (_taskMode == TaskMode.progress &&
        (_progressPercent < 0 || _progressPercent > 100)) {
      _showError('Progress must be between 0 and 100.');
      return;
    }

    if (_taskMode == TaskMode.progress && _hasRecurrencePlanning) {
      _showError(
        'Progress tasks represent a finite milestone to 100% and cannot be recurring. Use a Daily task instead.',
      );
      return;
    }

    if (_hasDuePlanning && _hasRecurrencePlanning) {
      _showError('Choose either a due date or recurrence, not both.');
      return;
    }

    if (_hasRecurrencePlanning) {
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

    DateTime? dueDateTime;

    if (_useDueTime) {
      if (_dueDate == null) {
        _showError('Select a due date before adding a due time.');
        return;
      }

      final time = _dueTime ?? TimeOfDay.now();

      dueDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        time.hour,
        time.minute,
      );
    }

    await widget.onSubmit(
      TaskFormInput(
        title: title,
        description: _nullIfBlank(_descriptionController.text),
        category: _resolvedCategory(),
        taskMode: _taskMode,
        priority: _priority,

        dueDate: _hasRecurrencePlanning ? null : _dueDate,
        dueDateTime: _hasRecurrencePlanning
            ? null
            : _useDueTime
            ? dueDateTime
            : null,
        clearDueDate: _didClearDueDate || _hasRecurrencePlanning,
        clearDueDateTime: _didClearDueDateTime || _hasRecurrencePlanning,

        recurrenceType: _hasRecurrencePlanning
            ? _recurrenceType
            : TaskRecurrenceType.none,
        recurrenceStartDate: _hasRecurrencePlanning
            ? _recurrenceStartDate
            : null,
        recurrenceEndDate: _hasRecurrencePlanning ? _recurrenceEndDate : null,
        recurrenceDaysOfWeek: _hasRecurrencePlanning
            ? _orderedDays()
            : const [],
        clearRecurrence: _didClearRecurrence || _hasDuePlanning,

        progressPercent: _taskMode == TaskMode.progress
            ? _progressPercent
            : null,

        tags: List<String>.unmodifiable(_tags),

        linkedScheduleBlockId:
            _selectedScheduleBlock?.scheduleBlockId ??
            _nullIfBlank(_initialLinkedScheduleBlockId),
        clearLinkedScheduleBlock:
            _didChangeScheduleBlock && _selectedScheduleBlock == null,
      ),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskIdentitySection(
          titleController: _titleController,
          descriptionController: _descriptionController,
          customCategoryController: _customCategoryController,
          titleFocus: _titleFocus,
          descriptionFocus: _descriptionFocus,
          customCategoryFocus: _customCategoryFocus,
          selectedCategory: _selectedCategory,
          showCustomCategory: _showCustomCategory,
          showDescription: _showDescription,
          onSelectCategory: _selectCategory,
          onToggleCustomCategory: _toggleCustomCategory,
          onToggleDescription: _toggleDescription,
        ),
        TaskDueSection(
          taskMode: _taskMode,
          dueDate: _dueDate,
          useDueTime: _useDueTime,
          dueTime: _dueTime,
          recurrenceActive: _hasRecurrencePlanning,
          onPickDueDate: _pickDueDate,
          onClearDueDate: _clearDueDate,
          onUseDueTimeChanged: _toggleDueTime,
          onPickDueTime: _pickDueTime,
        ),
        TaskModePrioritySection(
          taskMode: _taskMode,
          priority: _priority,
          onModeChanged: _handleModeChange,
          onPriorityChanged: _changePriority,
        ),
        if (_taskMode == TaskMode.progress)
          TaskProgressSection(
            progressPercent: _progressPercent,
            onChanged: (value) {
              setState(() => _progressPercent = value);
            },
          ),
        TaskRecurrenceSection(
          showRecurrence: _showRecurrence && _taskMode != TaskMode.progress,
          recurrenceType: _recurrenceType,
          recurrenceStartDate: _recurrenceStartDate,
          recurrenceEndDate: _recurrenceEndDate,
          recurrenceDaysOfWeek: _recurrenceDaysOfWeek,
          onToggleRecurrence: _toggleRecurrence,
          onSelectRecurrenceType: _selectRecurrenceType,
          onPickStartDate: _pickRecurrenceStartDate,
          onPickEndDate: _pickRecurrenceEndDate,
          onToggleWeekday: _toggleWeekday,
        ),
        TaskTagsSection(
          tagController: _tagController,
          tags: _tags,
          onAddTag: _addTag,
          onRemoveTag: _removeTag,
        ),
        TaskScheduleLinkSection(
          selected: _selectedScheduleBlock,
          initialLinkedScheduleBlockId: _initialLinkedScheduleBlockId,
          onChanged: _changeScheduleBlock,
        ),
      ],
    );
  }
}
