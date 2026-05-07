import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../application/task_providers.dart';
import '../../content/task_copy.dart';
import '../widgets/task_card.dart';
import 'task_detail_page.dart';
import '../../domain/enum/task_filter.dart';

class ArchivedTasksPage extends ConsumerStatefulWidget {
  const ArchivedTasksPage({super.key});

  @override
  ConsumerState<ArchivedTasksPage> createState() => _ArchivedTasksPageState();
}

class _ArchivedTasksPageState extends ConsumerState<ArchivedTasksPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        .loadSurfaces(date: selectedDate, filter: TaskFilter.archive);
  }

  Future<void> _openTask(String taskId) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: taskId)));

    if (!mounted) return;

    if (result is String && result.trim().isNotEmpty) {
      AppFeedback.success(_feedbackContext, message: result.trim());
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskNotifierProvider);
    final tasks = state.surfaces?.archivedTasks ?? const [];
    final bottomPadding = AppSpacing.navBarClearance(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Archived tasks')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (state.isLoading && tasks.isEmpty)
              SliverAppLoadingList(bottomPadding: bottomPadding)
            else if (state.errorMessage != null && tasks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyView(
                  icon: AppIcons.archive,
                  title: 'Could not load archived tasks',
                  subtitle: state.errorMessage ?? TaskCopy.loadErrorFallback,
                  actionLabel: TaskCopy.retry,
                  actionIcon: AppIcons.refresh,
                  onAction: _load,
                  centered: false,
                ),
              )
            else if (tasks.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyView(
                  icon: AppIcons.archive,
                  title: 'No archived tasks',
                  subtitle:
                      'Archived tasks will appear here for restore or permanent delete.',
                  centered: false,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  bottomPadding,
                ),
                sliver: SliverList.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.listItemGap,
                      ),
                      child: AnimatedListItem(
                        index: index,
                        baseDelay: AppMotion.listBaseDelay,
                        staggerDelay: AppMotion.listStaggerDelay,
                        child: TaskCard(
                          task: task,
                          // today: selectedDate,
                          onTap: () => _openTask(task.id),
                          onComplete: null,
                          onReopen: null,
                          compactCompleted: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
