import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_fab.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_stat_block.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../../domain/model/task_overview.dart';
import '../../domain/enum/task_status.dart';
import '../widgets/task_card.dart';
import '../widgets/task_empty_state.dart';
import '../widgets/task_filter_bar.dart';
import 'create_task_page.dart';
import 'task_detail_page.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  TaskListFilter _selectedFilter = TaskListFilter.active;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final userId = ref.read(currentUserIdProvider);
    final date = ref.read(taskNotifierProvider).selectedDate;

    await ref
        .read(taskNotifierProvider.notifier)
        .loadTasks(userId, filter: _selectedFilter.apiValue);

    await ref
        .read(taskNotifierProvider.notifier)
        .loadOverview(userId: userId, date: date);
  }

  Future<void> _openCreateTask() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateTaskPage()));
    if (!mounted) return;
    if (result is String && result.trim().isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }
    if (!mounted) return;
    await _load();
  }

  Future<void> _openTask(String taskId) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: taskId)));
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final userId = ref.read(currentUserIdProvider);
    final tasks = state.tasks;

    ref.listen(taskNotifierProvider, (previous, next) {
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
      if (!isCurrentRoute) return;

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.successMessage!)));
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final bottomPad = AppSpacing.navBarClearance(context) + 18;

    return Scaffold(
      floatingActionButton: AppPageFab(
        heroTag: 'tasks-new',
        onPressed: _openCreateTask,
        tooltip: TaskCopy.createTooltip,
        icon: Icons.add,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const AppPageHeader(
              title: TaskCopy.pageTitle,
              subtitle: TaskCopy.pageSubtitle,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: TaskFilterBar(
                  selected: _selectedFilter,
                  onChanged: (value) async {
                    setState(() => _selectedFilter = value);
                    await _load();
                  },
                ),
              ),
            ),
            if (state.overview != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.sm,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: _TaskOverviewStrip(overview: state.overview!),
                ),
              ),
            if (state.isLoading && tasks.isEmpty)
              SliverAppLoadingList(bottomPadding: bottomPad)
            else if (state.errorMessage != null && tasks.isEmpty)
              SliverFillRemaining(
                child: AppEmptyView(
                  icon: Icons.checklist_outlined,
                  title: TaskCopy.loadErrorTitle,
                  subtitle: state.errorMessage ?? TaskCopy.loadErrorFallback,
                  actionLabel: TaskCopy.retry,
                  actionIcon: Icons.refresh,
                  onAction: _load,
                ),
              )
            else if (tasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: TaskEmptyState(
                  onCreateTask: _openCreateTask,
                  centered: false,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  bottomPad,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.listItemGap,
                      ),
                      child: TaskCard(
                        task: task,
                        onTap: () => _openTask(task.id),
                        onComplete: task.status.isDone
                            ? null
                            : () async {
                                await ref
                                    .read(taskNotifierProvider.notifier)
                                    .completeTask(
                                      userId: userId,
                                      taskId: task.id,
                                    );
                              },
                        compactCompleted:
                            _selectedFilter == TaskListFilter.completed,
                      ),
                    );
                  }, childCount: tasks.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskOverviewStrip extends StatelessWidget {
  final TaskOverview overview;

  const _TaskOverviewStrip({required this.overview});

  @override
  Widget build(BuildContext context) {
    final counts = overview.todayCounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overview.currentTask != null) ...[
          Text('Current focus', style: AppTextStyles.metaLabel(context)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            overview.currentTask!.title,
            style: AppTextStyles.cardTitle(context),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          children: [
            Expanded(
              child: AppStatBlock(
                label: 'Active',
                value: '${counts.active}',
                color: AppColors.blue,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppStatBlock(
                label: 'Completed',
                value: '${counts.completed}',
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppStatBlock(
                label: 'Urgent',
                value: '${counts.urgent}',
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
