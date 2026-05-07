import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../../task/presentation/pages/create_task_page.dart';
import '../../../timeline/domain/entities/timeline_item.dart';
import '../../application/today_providers.dart';
import '../../application/today_state.dart';
import '../../domain/model/today_overview.dart';
import '../../domain/model/today_weather_insight.dart';
import '../widgets/today_action_bar.dart';
import '../widgets/today_command_card.dart';
import '../widgets/today_metrics_strip.dart';
import '../widgets/today_score_insight_card.dart';
import '../widgets/today_timeline_truth_card.dart';
import '../widgets/today_weather_decision_card.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final selectedDate = ref.read(todayNotifierProvider).selectedDate;
    await ref.read(todayNotifierProvider.notifier).load(date: selectedDate);
  }

  Future<void> _changeDay(DateTime date) async {
    await ref.read(todayNotifierProvider.notifier).load(date: date);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todayNotifierProvider);
    final itemCount = state.data?.timeline?.items.length ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const AppPageHeader(
              title: 'Today',
              subtitle: ProductCopy.todaySubtitle,
            ),
            SliverToBoxAdapter(
              child: DayNavigatorHeader(
                date: state.selectedDate,
                subtitle: itemCount > 0 ? '$itemCount signals' : null,
                isLoadingDay: state.isLoading,
                onPreviousDay: () {
                  _changeDay(
                    state.selectedDate.subtract(const Duration(days: 1)),
                  );
                },
                onNextDay: () {
                  _changeDay(state.selectedDate.add(const Duration(days: 1)));
                },
              ),
            ),
            _buildBody(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TodayState state) {
    if (state.isLoading && state.data == null) {
      return SliverAppLoadingList(
        itemCount: 4,
        bottomPadding: AppSpacing.navBarClearance(context),
      );
    }

    if (state.errorMessage != null && state.data == null) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.today,
          title: 'Failed to load Today',
          subtitle: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Try again',
          actionIcon: AppIcons.refresh,
          onAction: _load,
        ),
      );
    }

    final data = state.data;

    if (data == null) {
      return const SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.today,
          title: 'No Today data yet',
          subtitle:
              'Your daily command center will appear here once data arrives.',
        ),
      );
    }

    final realNow = DateTime.now();
    final selectedDate = state.selectedDate;
    final isSelectedToday = _isSameLocalDay(selectedDate, realNow);

    final previewItems = List<TimelineItem>.from(
      data.timeline?.items ?? const <TimelineItem>[],
    ).take(5).toList();

    final nextItem = isSelectedToday ? _nextTimelineItem(data, realNow) : null;

    final hasDaySignals =
        data.totalTasks > 0 ||
        data.totalPlannedBlocks > 0 ||
        previewItems.isNotEmpty;

    final weatherInsight = TodayWeatherInsight.placeholder(
      isSelectedToday: isSelectedToday,
    );

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.sm,
        bottom: AppSpacing.navBarClearance(context),
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          TodayCommandCard(
            isSelectedToday: isSelectedToday,
            currentBlock: isSelectedToday ? data.currentScheduleBlock : null,
            topActiveTask: data.topActiveTask,
            nextItem: nextItem,
            now: realNow,
            onCurrentBlockTap: data.currentScheduleBlock == null
                ? null
                : () => context.push(
                    ScheduleRoutes.detail(
                      data.currentScheduleBlock!.scheduleBlockId,
                    ),
                  ),
            onTopTaskTap: data.topActiveTask == null
                ? null
                : () => context.push(TaskRoutes.detail(data.topActiveTask!.id)),
            onTimelineTap: () => context.go(AppRoutes.timeline),
            onAddTaskTap: _openCreateTask,
            onAddScheduleTap: () => context.go(AppRoutes.schedule),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          TodayMetricsStrip(
            totalTasks: data.totalTasks,
            completedTasks: data.completedTasks,
            plannedBlocks: data.totalPlannedBlocks,
            onTap: data.summary == null
                ? null
                : () => context.push(AppRoutes.summary),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          if (previewItems.isNotEmpty)
            TodayTimelineTruthCard(
              items: previewItems,
              now: realNow,
              isSelectedToday: isSelectedToday,
              onTap: () => context.go(AppRoutes.timeline),
            )
          else
            TodayEmptyTimelineCard(
              onOpenTimeline: () => context.go(AppRoutes.timeline),
              onAddTask: _openCreateTask,
            ),

          const SizedBox(height: AppSpacing.sectionGap),

          TodayScoreInsightCard(
            overallScore: data.overallScore,
            completionScore: data.completionScore,
            structureScore: data.structureScore,
            completedTasks: data.completedTasks,
            totalTasks: data.totalTasks,
            plannedBlocks: data.totalPlannedBlocks,
            explanation: data.score?.scoreExplanation,
            onTap: () => context.push(AppRoutes.score),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          TodayWeatherDecisionCard(insight: weatherInsight, onTap: null),

          const SizedBox(height: AppSpacing.sectionGap),

          TodayActionBar(
            compact: hasDaySignals,
            onAddTaskTap: _openCreateTask,
            onAddScheduleTap: () => context.go(AppRoutes.schedule),
            onTasksTap: () => context.go(AppRoutes.tasks),
            onScheduleTap: () => context.go(AppRoutes.schedule),
          ),

          const SizedBox(height: AppSpacing.md),
        ]),
      ),
    );
  }

  Future<void> _openCreateTask() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateTaskPage()));

    if (context.mounted) {
      await _load();
    }
  }

  TimelineItem? _nextTimelineItem(TodayOverview data, DateTime now) {
    final items = data.timeline?.items ?? const <TimelineItem>[];

    for (final item in items) {
      if (item.isUpcomingAt(now)) {
        return item;
      }
    }

    return null;
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
