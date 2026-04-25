import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_fab.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_sparse_state_card.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../application/schedule_providers.dart';
import '../../content/schedule_copy.dart';
import '../../domain/model/schedule_occurrence.dart';
import 'schedule_form_page.dart';
import 'schedule_detail_page.dart';
import '../widgets/schedule_day_summary_card.dart';
import '../widgets/schedule_empty_state.dart';
import '../widgets/schedule_filters_bar.dart';
import '../widgets/schedule_occurrence_card.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  ScheduleViewFilter _filter = ScheduleViewFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadToday);
  }

  Future<void> _loadToday() async {
    final userId = ref.read(currentUserIdProvider);
    await ref
        .read(scheduleNotifierProvider.notifier)
        .loadByDay(userId: userId, date: DateTime.now());
  }

  Future<void> _reloadSelectedDay() async {
    final state = ref.read(scheduleNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    await ref
        .read(scheduleNotifierProvider.notifier)
        .loadByDay(userId: userId, date: state.selectedDate);
  }

  Future<void> _openCreateForm() async {
    final userId = ref.read(currentUserIdProvider);

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Consumer(
          builder: (context, ref, child) {
            final formState = ref.watch(scheduleNotifierProvider);
            return ScheduleFormPage(
              isSaving: formState.isSaving,
              shouldPopOnSubmit: false,
              onSubmit: (result) async {
                await ref
                    .read(scheduleNotifierProvider.notifier)
                    .create(
                      userId: userId,
                      title: result.title,
                      description: result.description,
                      type: result.type,
                      recurrenceType: result.recurrenceType,
                      startTime: result.startTime,
                      endTime: result.endTime,
                      daysOfWeek: result.daysOfWeek,
                      recurrenceStartDate: result.recurrenceStartDate,
                      recurrenceEndDate: result.recurrenceEndDate,
                    );

                final latest = ref.read(scheduleNotifierProvider);
                if (!context.mounted) return;

                if (latest.errorMessage != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(latest.errorMessage!)));
                  return;
                }

                Navigator.of(context).pop(ScheduleCopy.successCreated);
              },
            );
          },
        ),
      ),
    );
    if (!mounted) return;
    if (result is String && result.trim().isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    }

    await _reloadSelectedDay();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    ref.listen(scheduleNotifierProvider, (previous, next) {
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

    final List<ScheduleOccurrence> allItems = List<ScheduleOccurrence>.from(
      state.items,
    );
    final List<ScheduleOccurrence> visibleItems = _applyFilter(
      allItems,
      _filter,
    );

    return Scaffold(
      floatingActionButton: AppPageFab(
        heroTag: 'schedule-new',
        onPressed: _openCreateForm,
        tooltip: ScheduleCopy.createBlock,
        icon: Icons.add,
      ),
      body: RefreshIndicator(
        onRefresh: _reloadSelectedDay,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const AppPageHeader(
              title: ScheduleCopy.pageTitle,
              subtitle: ScheduleCopy.pageSubtitle,
            ),

            SliverToBoxAdapter(
              child: DayNavigatorHeader(
                date: state.selectedDate,
                subtitle: allItems.isNotEmpty
                    ? ScheduleCopy.plannedBlocksCount(allItems.length)
                    : null,
                isLoadingDay: state.isLoading,
                onPreviousDay: () async {
                  await ref
                      .read(scheduleNotifierProvider.notifier)
                      .changeDay(
                        userId: userId,
                        date: state.selectedDate.subtract(
                          const Duration(days: 1),
                        ),
                      );
                },
                onNextDay: () async {
                  await ref
                      .read(scheduleNotifierProvider.notifier)
                      .changeDay(
                        userId: userId,
                        date: state.selectedDate.add(const Duration(days: 1)),
                      );
                },
              ),
            ),

            if (state.isLoading && state.items.isEmpty)
              SliverAppLoadingList(
                itemCount: 4,
                bottomPadding: AppSpacing.navBarClearance(context),
              )
            else if (state.errorMessage != null && allItems.isEmpty)
              SliverFillRemaining(
                child: AppEmptyView(
                  icon: Icons.calendar_month_outlined,
                  title: ScheduleCopy.loadErrorTitle,
                  subtitle:
                      state.errorMessage ?? ScheduleCopy.loadErrorFallback,
                  actionLabel: ScheduleCopy.retry,
                  actionIcon: Icons.refresh,
                  onAction: _reloadSelectedDay,
                ),
              )
            else if (allItems.isEmpty)
              SliverFillRemaining(
                child: ScheduleEmptyState(onCreateSchedule: _openCreateForm),
              )
            else
              SliverPadding(
                padding: EdgeInsets.only(
                  left: AppSpacing.pageHorizontal,
                  right: AppSpacing.pageHorizontal,
                  top: AppSpacing.md,
                  bottom: AppSpacing.navBarClearance(context) + 72,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ScheduleDaySummaryCard(items: allItems),
                    const SizedBox(height: AppSpacing.md),
                    if (allItems.length <= 1) ...[
                      AppSparseStateCard(
                        icon: Icons.calendar_today_outlined,
                        title: ScheduleCopy.sparseTitle,
                        message: ScheduleCopy.sparseMessage,
                        actionLabel: ScheduleCopy.createBlock,
                        onAction: _openCreateForm,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    ScheduleFiltersBar(
                      selected: _filter,
                      onChanged: (value) {
                        setState(() => _filter = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    ...visibleItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.listItemGap,
                        ),
                        child: ScheduleOccurrenceCard(
                          item: item,
                          onTap: () async {
                            await ref
                                .read(scheduleNotifierProvider.notifier)
                                .loadById(
                                  userId: userId,
                                  id: item.scheduleBlockId,
                                );

                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ScheduleDetailPage(
                                  id: item.scheduleBlockId,
                                ),
                              ),
                            );

                            await _reloadSelectedDay();
                          },
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<ScheduleOccurrence> _applyFilter(
    List<ScheduleOccurrence> items,
    ScheduleViewFilter filter,
  ) {
    switch (filter) {
      case ScheduleViewFilter.all:
        return items;
      case ScheduleViewFilter.work:
        return items.where((e) => e.type.name == 'work').toList();
      case ScheduleViewFilter.study:
        return items.where((e) => e.type.name == 'study').toList();
      case ScheduleViewFilter.personal:
        return items.where((e) {
          return e.type.name == 'personal' ||
              e.type.name == 'rest' ||
              e.type.name == 'exercise';
        }).toList();
    }
  }
}
