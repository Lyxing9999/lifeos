import 'package:flutter/material.dart';

import '../../../../core/widgets/app_form_widget.dart';
import '../../content/task_copy.dart';
import '../../domain/model/task.dart';
import '../widgets/task_form.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TaskFormPage — The scaffold that wraps TaskForm.
//
// Senior-level pattern:
//   • Uses buildFormPage() from AppFormMixin for unified chrome + submit bar
//   • Delegates field validation + data collection to TaskForm via controller
//   • Single-responsibility: page handles scaffold, form handles fields
//   • Pop-after-submit is handled by buildFormPage (shouldPopOnSubmit: true)
// ─────────────────────────────────────────────────────────────────────────────

class TaskFormPage extends StatefulWidget {
  final Task? existing;
  final bool isSaving;
  final Future<void> Function(TaskFormInput result) onSubmit;
  final bool shouldPopOnSubmit;

  const TaskFormPage({
    super.key,
    this.existing,
    required this.isSaving,
    required this.onSubmit,
    this.shouldPopOnSubmit = true,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> with AppFormMixin {
  final _controller = TaskFormController();

  bool get _isEdit => widget.existing != null;

  @override
  Widget build(BuildContext context) {
    return buildFormPage(
      title: _isEdit ? TaskCopy.formEditTitle : TaskCopy.formNewTitle,
      subtitle: _isEdit ? TaskCopy.formEditSubtitle : TaskCopy.formNewSubtitle,
      submitLabel: TaskCopy.formSubmitCreate,
      editSubmitLabel: TaskCopy.formSubmitEdit,
      isSaving: widget.isSaving,
      isEdit: _isEdit,
      onSubmit: () => _controller.submit(),
      shouldPopOnSubmit: widget.shouldPopOnSubmit,
      children: [
        TaskForm(
          existing: widget.existing,
          isSaving: widget.isSaving,
          controller: _controller,
          onSubmit: widget.onSubmit,
        ),
      ],
    );
  }
}
