import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_sparse_state_card.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../task/presentation/pages/create_task_page.dart';
import '../../../timeline/domain/model/timeline_item.dart';
import '../../application/today_providers.dart';
import '../../domain/model/today_financial_insight.dart';
import '../../domain/model/today_overview.dart';
import '../../domain/model/today_place_insight.dart';
import '../widgets/today_current_block_card.dart';
import '../widgets/today_financial_insight_card.dart';
import '../widgets/today_greeting_card.dart';
import '../widgets/today_place_insight_card.dart';
import '../widgets/today_quick_actions_section.dart';
import '../widgets/today_score_card.dart';
import '../widgets/today_summary_card.dart';
import '../widgets/today_timeline_preview_card.dart';
import '../widgets/today_top_task_card.dart';

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
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return;

    await ref
        .read(todayNotifierProvider.notifier)
        .load(
          userId: userId,
          date: ref.read(todayNotifierProvider).selectedDate,
        );
  }

  Future<void> _changeDay(DateTime date) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return;

    await ref
        .read(todayNotifierProvider.notifier)
        .load(userId: userId, date: date);
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
                subtitle: itemCount > 0 ? '$itemCount items' : null,
                isLoadingDay: state.isLoading,
                onPreviousDay: () => _changeDay(
                  state.selectedDate.subtract(const Duration(days: 1)),
                ),
                onNextDay: () =>
                    _changeDay(state.selectedDate.add(const Duration(days: 1))),
              ),
            ),
            _buildBody(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state) {
    if (state.isLoading && state.data == null) {
      return SliverAppLoadingList(
        itemCount: 4,
        bottomPadding: AppSpacing.navBarClearance(context),
      );
    }

    if (state.errorMessage != null && state.data == null) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: Icons.today_outlined,
          title: 'Failed to load today',
          subtitle: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Try again',
          actionIcon: Icons.refresh,
          onAction: _load,
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return const SliverFillRemaining(
        child: AppEmptyView(
          icon: Icons.today_outlined,
          title: 'No today data yet',
          subtitle: 'Your day truth will appear here once data arrives.',
        ),
      );
    }

    final currentBlock = data.currentScheduleBlock;
    final previewItems = List<TimelineItem>.from(
      data.timeline?.items ?? const <TimelineItem>[],
    ).take(4).toList();
    final now = DateTime.now();
    final placeInsight = _meaningfulPlaceInsight(data.topPlaceInsight);
    final financialInsight = _meaningfulFinancialInsight(data.financialInsight);
    final hasSecondaryInsights =
        placeInsight != null || financialInsight != null;
    final hasCurrentFocus =
        data.currentScheduleBlock != null || data.topActiveTask != null;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.sm,
        bottom: AppSpacing.navBarClearance(context),
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          TodayGreetingCard(
            name: data.userName,
            date: data.date,
            timezone: data.timezone,
            hasCurrentBlock: currentBlock != null,
            timelineCount: itemCountForDay(data),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Text('Current focus', style: AppTextStyles.sectionHeader(context)),
          const SizedBox(height: AppSpacing.sm),
          if (hasCurrentFocus) ...[
            if (currentBlock != null)
              TodayCurrentBlockCard(
                block: currentBlock,
                onTap: () => context.push(
                  ScheduleRoutes.detail(currentBlock.scheduleBlockId),
                ),
              ),
            if (currentBlock != null && data.topActiveTask != null)
              const SizedBox(height: AppSpacing.sm),
            if (data.topActiveTask != null)
              TodayTopTaskCard(
                task: data.topActiveTask!,
                onTap: () =>
                    context.push(TaskRoutes.detail(data.topActiveTask!.id)),
              ),
          ] else ...[
            AppSparseStateCard(
              icon: Icons.radar_outlined,
              title: 'No current focus yet',
              message: 'No active task or current planned block right now.',
              actionLabel: 'Open tasks',
              onAction: () => context.go(AppRoutes.tasks),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          TodayScoreCard(
            overallScore: data.overallScore,
            completionScore: data.completionScore,
            structureScore: data.structureScore,
            onTap: () => context.push(AppRoutes.score),
          ),
          if (data.summary != null) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            TodaySummaryCard(
              summary: data.summary!,
              onTap: () => context.push(AppRoutes.summary),
            ),
          ],
          if (previewItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            TodayTimelinePreviewCard(
              items: previewItems,
              now: now,
              onTap: () => context.go(AppRoutes.timeline),
            ),
          ],
          if (hasSecondaryInsights) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Text(
              'Supporting signals',
              style: AppTextStyles.sectionHeader(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SecondaryInsightsRow(
              placeInsight: placeInsight,
              financialInsight: financialInsight,
              onPlaceTap: () => context.push(AppRoutes.places),
              onSpendingTap: () => context.push(AppRoutes.finance),
            ),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          TodayQuickActionsSection(
            onAddTaskTap: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CreateTaskPage()));
              if (context.mounted) {
                await _load();
              }
            },
            onAddScheduleTap: () => context.go(AppRoutes.schedule),
            onTasksTap: () => context.go(AppRoutes.tasks),
            onScheduleTap: () => context.go(AppRoutes.schedule),
          ),
          const SizedBox(height: AppSpacing.md),
        ]),
      ),
    );
  }

  int itemCountForDay(TodayOverview data) {
    return data.timeline?.items.length ?? 0;
  }

  TodayPlaceInsight? _meaningfulPlaceInsight(TodayPlaceInsight? insight) {
    if (insight == null) return null;

    final placeName = insight.placeName.trim().toLowerCase();
    if (placeName.isEmpty ||
        placeName.contains('unknown') ||
        insight.durationMinutes < 60) {
      return null;
    }

    return insight;
  }

  TodayFinancialInsight? _meaningfulFinancialInsight(
    TodayFinancialInsight? insight,
  ) {
    if (insight == null) return null;

    if (insight.totalEvents <= 0 || insight.totalOutgoingAmount <= 0) {
      return null;
    }

    return insight;
  }
}

class _SecondaryInsightsRow extends StatelessWidget {
  final TodayPlaceInsight? placeInsight;
  final TodayFinancialInsight? financialInsight;
  final VoidCallback? onPlaceTap;
  final VoidCallback? onSpendingTap;

  const _SecondaryInsightsRow({
    this.placeInsight,
    this.financialInsight,
    this.onPlaceTap,
    this.onSpendingTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      if (placeInsight != null)
        Expanded(
          child: TodayPlaceInsightCard(
            insight: placeInsight!,
            onTap: onPlaceTap,
          ),
        ),
      if (financialInsight != null)
        Expanded(
          child: TodayFinancialInsightCard(
            insight: financialInsight!,
            onTap: onSpendingTap,
          ),
        ),
    ];

    if (cards.isEmpty) return const SizedBox.shrink();

    if (cards.length == 1) return cards.first;

    return Row(
      children: [
        cards[0],
        const SizedBox(width: AppSpacing.sm),
        cards[1],
      ],
    );
  }
}
