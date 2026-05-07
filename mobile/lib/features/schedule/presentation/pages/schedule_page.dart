import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_glass_icon_button.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_fab.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../application/schedule_providers.dart';
import '../../content/schedule_copy.dart';
import '../../domain/command/create_schedule_block_command.dart';
import '../../domain/enum/schedule_filter.dart';
import '../../domain/enum/schedule_view_filter.dart';
import '../widgets/schedule_block_card.dart';
import '../widgets/schedule_empty_state.dart';
import '../widgets/schedule_filters_bar.dart';
import 'schedule_detail_page.dart';
import 'schedule_form_page.dart';
import 'schedule_history_page.dart';
import '../../domain/entities/schedule_block.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  @override
  void initState() {
    super.initState();
    // Use microtask to avoid building during state updates
    Future.microtask(_load);
  }

  Map<String, List<ScheduleBlock>> _groupBlocksByTimeOfDay(
    List<ScheduleBlock> blocks,
  ) {
    // 1. Ensure blocks are sorted by start time first
    final sorted = List<ScheduleBlock>.from(blocks)
      ..sort((a, b) {
        final timeA = a.startTime.hour * 60 + a.startTime.minute;
        final timeB = b.startTime.hour * 60 + b.startTime.minute;
        return timeA.compareTo(timeB);
      });

    // 2. Group them into buckets
    final Map<String, List<ScheduleBlock>> grouped = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };

    for (final block in sorted) {
      if (block.startTime.hour < 12) {
        grouped['Morning']!.add(block);
      } else if (block.startTime.hour < 17) {
        grouped['Afternoon']!.add(block);
      } else {
        grouped['Evening']!.add(block);
      }
    }

    // 3. Remove empty buckets
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  /// Full network load of the BFF Surface
  Future<void> _load() async {
    await ref
        .read(scheduleNotifierProvider.notifier)
        .loadSurfaces(date: DateTime.now());
  }

  /// UI Filter Change (Synchronous local update)
  void _onStatusFilterChanged(ScheduleFilter filter) {
    ref.read(scheduleNotifierProvider.notifier).setFilter(filter);
  }

  /// Category Filter Change (Synchronous local update)
  void _onViewFilterChanged(ScheduleViewFilter filter) {
    ref.read(scheduleNotifierProvider.notifier).setViewFilter(filter);
  }

  Future<void> _openCreateForm() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Consumer(
          builder: (context, ref, child) {
            final formState = ref.watch(scheduleNotifierProvider);
            return ScheduleFormPage(
              isSaving: formState.isSaving,
              shouldPopOnSubmit: false,
              onSubmit: (result) async {
                final command = CreateScheduleBlockCommand(
                  title: result.title,
                  description: result.description,
                  type: result.type,
                  recurrenceType: result.recurrenceType,
                  startTime: result.startTime,
                  endTime: result.endTime,
                  recurrenceDaysOfWeek: result.daysOfWeek,
                  recurrenceStartDate: result.recurrenceStartDate,
                  recurrenceEndDate: result.recurrenceEndDate,
                );

                // Mutation Coordinator handles cross-domain refreshes
                await ref
                    .read(scheduleMutationCoordinatorProvider)
                    .create(command);

                if (!context.mounted) return;

                final state = ref.read(scheduleNotifierProvider);
                if (state.errorMessage != null) {
                  AppFeedback.error(context, message: state.errorMessage!);
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
      AppFeedback.success(context, title: 'Success', message: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleNotifierProvider);

    // Dual filtering applied locally from the cached surface
    final blocks =
        state.surfaces?.blocksFor(state.selectedFilter, state.viewFilter) ??
        const [];

    // Global Error Listener
    ref.listen(scheduleNotifierProvider, (previous, next) {
      if (ModalRoute.of(context)?.isCurrent != true) return;
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppFeedback.error(context, message: next.errorMessage!);
      }
    });

    return Scaffold(
      floatingActionButton: state.selectedFilter == ScheduleFilter.active
          ? AppPageFab(
              heroTag: 'schedule-new',
              onPressed: _openCreateForm,
              tooltip: ScheduleCopy.createBlock,
              icon: AppIcons.add,
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AppPageHeader(
              title: 'Schedule Blueprint',
              subtitle: 'The architectural rules of your LifeOS.',
              leading: AppGlassIconButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Go back',
              ),
              actions: [
                AppGlassIconButton(
                  icon: Icons.history,
                  tooltip: 'View History',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ScheduleHistoryPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // 1. Status Segmented Button (Active vs Inactive)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                  vertical: AppSpacing.sm,
                ),
                child: SegmentedButton<ScheduleFilter>(
                  showSelectedIcon: false,
                  segments: ScheduleFilter.values
                      .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                      .toList(),
                  selected: {state.selectedFilter},
                  onSelectionChanged: (values) =>
                      _onStatusFilterChanged(values.first),
                ),
              ),
            ),

            // 2. Category Filter Bar (Chips)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.pageHorizontal,
                  right: AppSpacing.pageHorizontal,
                  bottom: AppSpacing.md,
                ),
                child: ScheduleFiltersBar(
                  selected: state.viewFilter,
                  onChanged: _onViewFilterChanged,
                ),
              ),
            ),

            // 3. Main Content Area
            if (state.isLoading && blocks.isEmpty)
              SliverAppLoadingList(
                itemCount: 4,
                bottomPadding: AppSpacing.navBarClearance(context),
              )
            else if (state.errorMessage != null && blocks.isEmpty)
              SliverFillRemaining(
                child: AppEmptyView(
                  icon: AppIcons.error,
                  title: ScheduleCopy.loadErrorTitle,
                  subtitle:
                      state.errorMessage ?? ScheduleCopy.loadErrorFallback,
                  actionLabel: ScheduleCopy.retry,
                  actionIcon: AppIcons.refresh,
                  onAction: _load,
                ),
              )
            else if (blocks.isEmpty)
              SliverFillRemaining(
                child: state.selectedFilter == ScheduleFilter.active
                    ? ScheduleEmptyState(onCreateSchedule: _openCreateForm)
                    : const AppEmptyView(
                        icon: AppIcons.archive,
                        title: 'No inactive blocks',
                        subtitle:
                            'Paused or standby rules appear here. View History for expired blocks.',
                      ),
              )
            else
              ...(() {
                final groupedBlocks = _groupBlocksByTimeOfDay(blocks);
                final slivers = <Widget>[];

                groupedBlocks.forEach((sectionName, sectionBlocks) {
                  // 1. Add the Section Header (Morning, Afternoon, etc.)
                  slivers.add(
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          AppSpacing.lg,
                          AppSpacing.pageHorizontal,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          sectionName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  );

                  // 2. Add the List of Cards for that section
                  slivers.add(
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      sliver: SliverList.builder(
                        itemCount: sectionBlocks.length,
                        itemBuilder: (context, index) {
                          final block = sectionBlocks[index];
                          // Check if it's the very last item in the whole page to add bottom padding
                          final isLastSection =
                              sectionName == groupedBlocks.keys.last;
                          final isLastItem = index == sectionBlocks.length - 1;
                          final bottomSpacing = (isLastSection && isLastItem)
                              ? AppSpacing.navBarClearance(context) + 72
                              : AppSpacing.listItemGap;

                          return Padding(
                            padding: EdgeInsets.only(bottom: bottomSpacing),
                            child: ScheduleBlockCard(
                              block: block,
                              onTap: () async {
                                await ref
                                    .read(scheduleNotifierProvider.notifier)
                                    .loadById(id: block.id);
                                if (!context.mounted) return;
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ScheduleDetailPage(id: block.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                });

                return slivers;
              }()),
          ],
        ),
      ),
    );
  }
}
