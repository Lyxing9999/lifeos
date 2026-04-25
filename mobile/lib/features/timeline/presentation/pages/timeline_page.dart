import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/animated_list_item.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_sparse_state_card.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../application/timeline_providers.dart';
import '../../domain/model/timeline_day.dart';
import '../../domain/model/timeline_item.dart';
import '../widgets/timeline_filters_bar.dart';
import '../widgets/timeline_item_card.dart';
import '../widgets/timeline_summary_card.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  TimelineFilter _filter = TimelineFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadToday);
  }

  Future<void> _loadToday() async {
    final userId = ref.read(currentUserIdProvider);
    await ref
        .read(timelineNotifierProvider.notifier)
        .loadDay(userId: userId, date: DateTime.now());
  }

  Future<void> _reloadSelectedDay() async {
    final state = ref.read(timelineNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    await ref
        .read(timelineNotifierProvider.notifier)
        .loadDay(userId: userId, date: state.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timelineNotifierProvider);
    final userId = ref.read(currentUserIdProvider);
    final day = state.day;
    final filteredItems = day == null
        ? const <TimelineItem>[]
        : _applyFilter(day);
    final visibleCount = filteredItems.length;
    final now = DateTime.now();

    ref.listen(timelineNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final bottomPad =
        AppSpacing.navBarClearance(context) + (visibleCount < 3 ? 12 : 36);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _reloadSelectedDay,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const AppPageHeader(
              title: 'Timeline',
              subtitle: ProductCopy.timelineSubtitle,
            ),
            SliverToBoxAdapter(
              child: DayNavigatorHeader(
                date: state.selectedDate,
                subtitle: day != null ? '${day.items.length} items' : null,
                isLoadingDay: state.isLoading,
                onPreviousDay: () async {
                  await ref
                      .read(timelineNotifierProvider.notifier)
                      .changeDay(
                        userId: userId,
                        date: state.selectedDate.subtract(
                          const Duration(days: 1),
                        ),
                      );
                },
                onNextDay: () async {
                  await ref
                      .read(timelineNotifierProvider.notifier)
                      .changeDay(
                        userId: userId,
                        date: state.selectedDate.add(const Duration(days: 1)),
                      );
                },
              ),
            ),
            if (state.isLoading && state.day == null)
              SliverAppLoadingList(
                itemCount: 5,
                bottomPadding: AppSpacing.navBarClearance(context),
              )
            else if (state.errorMessage != null &&
                (day == null || day.items.isEmpty))
              SliverFillRemaining(
                child: AppEmptyView(
                  icon: Icons.timeline_outlined,
                  title: 'Failed to load timeline',
                  subtitle: state.errorMessage ?? 'Something went wrong.',
                  actionLabel: 'Try again',
                  actionIcon: Icons.refresh,
                  onAction: _reloadSelectedDay,
                ),
              )
            else if (day == null || day.items.isEmpty)
              const SliverFillRemaining(
                child: AppEmptyView(
                  icon: Icons.timeline_outlined,
                  title: 'No timeline events yet',
                  subtitle:
                      'Your day feed will appear here once this day has activity.',
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(
                  left: AppSpacing.pageHorizontal,
                  right: AppSpacing.pageHorizontal,
                  top: AppSpacing.xs,
                  bottom: bottomPad,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TimelineSummaryCard(day: day),
                    const SizedBox(height: AppSpacing.sm),
                    TimelineFiltersBar(
                      selected: _filter,
                      onChanged: (value) {
                        setState(() => _filter = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    if (visibleCount == 0)
                      Card(
                        child: Padding(
                          padding: AppSpacing.cardInsets,
                          child: Text(
                            'No items match this filter for the selected day.',
                            style: AppTextStyles.bodySecondary(context),
                          ),
                        ),
                      ),
                    if (visibleCount > 0 && visibleCount <= 2) ...[
                      AppSparseStateCard(
                        icon: Icons.timeline_outlined,
                        title: 'Light activity day',
                        message:
                            'Add tasks or planned blocks to enrich the day timeline.',
                        actionLabel: 'Open tasks',
                        onAction: () => context.go(AppRoutes.tasks),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    ...filteredItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isLast = index == filteredItems.length - 1;

                      return AnimatedListItem(
                        index: index,
                        child: TimelineItemCard(
                          item: item,
                          now: now,
                          showConnector: !isLast,
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.sm),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<TimelineItem> _applyFilter(TimelineDay day) {
    switch (_filter) {
      case TimelineFilter.all:
        return day.items;
      case TimelineFilter.schedule:
        return day.items.where((e) => e.type == 'schedule').toList();
      case TimelineFilter.tasks:
        return day.items.where((e) => e.type == 'task').toList();
      case TimelineFilter.places:
        return day.items.where((e) => e.type == 'stay').toList();
      case TimelineFilter.spending:
        return day.items.where((e) => e.type == 'financial').toList();
    }
  }
}
