import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_page_fab.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_surface.dart';
import '../../domain/enum/task_filter.dart';
import '../widgets/list/clear_done_card.dart';
import '../widgets/list/task_list_toolbar.dart';
import '../widgets/list/task_sliver_list.dart';
import 'archived_tasks_page.dart';
import 'create_task_page.dart';
import 'task_detail_page.dart';
import 'task_workspace_page.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TaskFilter _selectedFilter = TaskFilter.due;

  BuildContext get _feedbackContext => _scaffoldKey.currentContext ?? context;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  void resetToDue() {
    _setPrimaryFilter(TaskFilter.due);
  }

  void resetToInbox() {
    _setPrimaryFilter(TaskFilter.inbox);
  }

  void resetToDone() {
    _setPrimaryFilter(TaskFilter.done);
  }

  void _setPrimaryFilter(TaskFilter filter) {
    if (!mounted) return;

    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<void> _load() async {
    final selectedDate = ref.read(taskNotifierProvider).selectedDate;

    await ref
        .read(taskNotifierProvider.notifier)
        .loadSurfaces(date: selectedDate, filter: _selectedFilter);
  }

  List<Task> _tasksForSurface(TaskSurfaceOverview? surfaces) {
    if (surfaces == null) {
      return const <Task>[];
    }

    return surfaces.tasksFor(_selectedFilter);
  }

  Future<void> _handleFilterChanged(TaskFilter filter) async {
    switch (filter) {
      case TaskFilter.due:
      case TaskFilter.inbox:
      case TaskFilter.done:
        _setPrimaryFilter(filter);
        return;

      case TaskFilter.all:
      case TaskFilter.paused:
      case TaskFilter.history:
        await _openWorkspace(filter);
        return;

      case TaskFilter.archive:
        await _openArchivedTasks();
        return;
    }
  }

  Future<void> _openWorkspace(TaskFilter filter) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskWorkspacePage(filter: filter)),
    );

    if (!mounted) return;

    _showResultMessage(result);

    // Main Task page returns to the clean daily workflow instantly.
    _setPrimaryFilter(TaskFilter.due);
  }

  Future<void> _openArchivedTasks() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ArchivedTasksPage()));

    if (!mounted) return;

    _showResultMessage(result);

    // Archive is maintenance. Return user to Due after leaving.
    _setPrimaryFilter(TaskFilter.due);
  }

  Future<void> _openCreateTask() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateTaskPage()));

    if (!mounted) return;

    _showResultMessage(result, fallbackTitle: 'Task created');
  }

  Future<void> _openTask(String taskId) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: taskId)));

    if (!mounted) return;

    _showResultMessage(result, fallbackTitle: 'Task updated');
  }

  Future<void> _completeTask(String taskId, DateTime selectedDate) async {
    // 1. Physical Feedback (The Senior touch)
    HapticFeedback.mediumImpact();

    // 2. Perform Mutation
    await ref
        .read(taskMutationCoordinatorProvider)
        .completeTask(taskId: taskId, date: selectedDate);

    if (!mounted) return;

    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      _showError(latest.errorMessage!);
      return;
    }

    // 3. Informative Feedback with "Undo" context
    AppFeedback.success(
      _feedbackContext,
      title: 'Task Done',
      message: 'Task moved to review list.',
    );

    // 4. Lifecycle Logic: If the 'Due' list is now empty,
    // auto-navigate to 'Done' so the user sees their progress.
    final remainingDue = _tasksForSurface(latest.surfaces);
    if (remainingDue.isEmpty && _selectedFilter == TaskFilter.due) {
      _setPrimaryFilter(TaskFilter.done);
    }
  }

  Future<void> _reopenTask(String taskId, DateTime selectedDate) async {
    await ref
        .read(taskMutationCoordinatorProvider)
        .reopenTask(taskId: taskId, date: selectedDate);

    if (!mounted) return;

    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      _showError(latest.errorMessage!);
      return;
    }

    AppFeedback.success(
      _feedbackContext,
      title: 'Task Reopened',
      message: 'Back in your active workflow.',
    );

    // 4. Auto-Navigation: If we reopen the last task in 'Done', go back to 'Due'
    final remainingDone = _tasksForSurface(latest.surfaces);
    if (remainingDone.isEmpty && _selectedFilter == TaskFilter.done) {
      _setPrimaryFilter(TaskFilter.due);
    }
  }

  Future<void> _clearDoneForDay(DateTime selectedDate) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: TaskCopy.clearDoneTitle,
      message: TaskCopy.clearDoneBody,
      cancelLabel: TaskCopy.removeDialogCancel,
      confirmLabel: TaskCopy.clearDoneConfirm,
      icon: AppIcons.complete,
      color: AppColors.green,
    );

    if (!confirmed) return;

    await ref
        .read(taskMutationCoordinatorProvider)
        .clearDoneForDay(date: selectedDate);

    if (!mounted) return;

    final latest = ref.read(taskNotifierProvider);

    if (latest.errorMessage != null) {
      _showError(latest.errorMessage!);
      return;
    }

    AppFeedback.success(
      _feedbackContext,
      title: 'Done cleared',
      message: latest.successMessage ?? TaskCopy.successDoneCleared,
    );

    if (!mounted) return;

    _setPrimaryFilter(TaskFilter.done);
  }

  void _showResultMessage(Object? result, {String fallbackTitle = 'Done'}) {
    if (result is! String) return;

    final message = result.trim();
    if (message.isEmpty) return;

    AppFeedback.success(
      _feedbackContext,
      title: fallbackTitle,
      message: message,
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    AppFeedback.error(_feedbackContext, message: message);
  }

  String get _pageSubtitle {
    switch (_selectedFilter) {
      case TaskFilter.due:
        return 'Tasks needing time attention.';
      case TaskFilter.inbox:
        return 'Captured tasks not planned yet.';
      case TaskFilter.done:
        return 'Completed tasks ready for review.';
      case TaskFilter.all:
      case TaskFilter.paused:
      case TaskFilter.history:
      case TaskFilter.archive:
        return 'Plan, track, and review your tasks.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final selectedDate = state.selectedDate;
    final surfaces = state.surfaces;

    final tasks = _tasksForSurface(surfaces);
    final bottomPadding = AppSpacing.navBarClearance(context) + AppSpacing.lg;

    final showClearDoneCard =
        _selectedFilter == TaskFilter.done && tasks.isNotEmpty;

    ref.listen(taskNotifierProvider, (previous, next) {
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      if (!isCurrentRoute) return;

      final error = next.errorMessage;
      final previousError = previous?.errorMessage;

      if (error != null && error != previousError) {
        _showError(error);
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _selectedFilter.canCreate
          ? AppPageFab(
              heroTag: 'tasks-new',
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
            AppPageHeader(title: TaskCopy.pageTitle, subtitle: _pageSubtitle),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: TaskListToolbar(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: _handleFilterChanged,
                ),
              ),
            ),
            if (showClearDoneCard)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: ClearDoneCard(
                    count: tasks.length,
                    isSaving: state.isSaving,
                    onClear: () => _clearDoneForDay(selectedDate),
                  ),
                ),
              ),
            TaskSliverList(
              state: state,
              tasks: tasks,
              selectedDate: selectedDate,
              selectedFilter: _selectedFilter,
              bottomPadding: bottomPadding,
              onRetry: _load,
              onCreateTask: _selectedFilter.canCreate ? _openCreateTask : null,
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
