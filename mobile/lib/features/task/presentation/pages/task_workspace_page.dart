import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page_fab.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../../domain/entities/task.dart';
import '../../domain/enum/task_filter.dart';
import '../widgets/list/task_sliver_list.dart';
import 'create_task_page.dart';
import 'task_detail_page.dart';

class TaskWorkspacePage extends ConsumerStatefulWidget {
  final TaskFilter filter;

  const TaskWorkspacePage({super.key, required this.filter});

  @override
  ConsumerState<TaskWorkspacePage> createState() => _TaskWorkspacePageState();
}

class _TaskWorkspacePageState extends ConsumerState<TaskWorkspacePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TaskFilter get filter => widget.filter;

  BuildContext get _feedbackContext => _scaffoldKey.currentContext ?? context;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final selectedDate = ref.read(taskNotifierProvider).selectedDate;

    await ref
        .read(taskNotifierProvider.notifier)
        .loadSurfaces(date: selectedDate, filter: filter);
  }

  List<Task> _tasksForState() {
    final state = ref.read(taskNotifierProvider);
    final surfaces = state.surfaces;

    if (surfaces == null) {
      return const [];
    }

    return surfaces.tasksFor(filter);
  }

  Future<void> _openCreateTask() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateTaskPage()));

    if (!mounted) return;

    _showResultMessage(result);
    await _load();
  }

  Future<void> _openTask(String taskId) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: taskId)));

    if (!mounted) return;

    _showResultMessage(result);
    await _load();
  }

  Future<void> _completeTask(String taskId, DateTime selectedDate) async {
    // 1. Haptic Feedback: Give the user a physical "click" feel
    HapticFeedback.lightImpact();

    await ref
        .read(taskMutationCoordinatorProvider)
        .completeTask(taskId: taskId, date: selectedDate);

    if (!mounted) return;

    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      AppFeedback.error(_feedbackContext, message: latest.errorMessage!);
      return;
    }

    // 2. Success Message: Minimalist feedback
    AppFeedback.success(_feedbackContext, message: 'Task completed');

    await _load();
  }

  Future<void> _reopenTask(String taskId, DateTime selectedDate) async {
    await ref
        .read(taskMutationCoordinatorProvider)
        .reopenTask(taskId: taskId, date: selectedDate);

    if (!mounted) return;

    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      AppFeedback.error(_feedbackContext, message: latest.errorMessage!);
      return;
    }

    await _load();
  }

  void _showResultMessage(Object? result) {
    if (result is! String || result.trim().isEmpty) return;
    AppFeedback.success(_feedbackContext, message: result.trim());
  }

  String get _title {
    switch (filter) {
      case TaskFilter.all:
        return 'Task library';
      case TaskFilter.paused:
        return 'Paused tasks';
      case TaskFilter.history:
        return 'Task history';
      case TaskFilter.archive:
        return 'Archived tasks';
      case TaskFilter.due:
        return 'Due tasks';
      case TaskFilter.inbox:
        return 'Inbox';
      case TaskFilter.done:
        return 'Done';
    }
  }

  bool get _canCreate {
    switch (filter) {
      case TaskFilter.all:
        return true;
      case TaskFilter.due:
      case TaskFilter.inbox:
        return true;
      case TaskFilter.done:
      case TaskFilter.paused:
      case TaskFilter.history:
      case TaskFilter.archive:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final selectedDate = state.selectedDate;
    final tasks = _tasksForState();
    final bottomPad = AppSpacing.navBarClearance(context) + 18;

    ref.listen(taskNotifierProvider, (previous, next) {
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      if (!isCurrentRoute) return;

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppFeedback.error(_feedbackContext, message: next.errorMessage!);
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(_title)),
      floatingActionButton: _canCreate
          ? AppPageFab(
              heroTag: 'task-workspace-new-${filter.name}',
              onPressed: _openCreateTask,
              tooltip: TaskCopy.createTooltip,
              icon: AppIcons.add,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            TaskSliverList(
              state: state,
              tasks: tasks,
              selectedDate: selectedDate,
              selectedFilter: filter,
              bottomPadding: bottomPad,
              onRetry: _load,
              onCreateTask: _canCreate ? _openCreateTask : null,
              onOpenTask: _openTask,
              onCompleteTask: _completeTask,
              onReopenTask: _reopenTask,
            ),
          ],
        ),
      ),
    );
  }
}
