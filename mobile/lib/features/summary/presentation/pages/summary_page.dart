import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../application/summary_providers.dart';
import '../widgets/summary_card.dart';
import '../widgets/summary_explanation_card.dart';
import '../widgets/summary_insight_card.dart';

class SummaryPage extends ConsumerStatefulWidget {
  const SummaryPage({super.key});

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    await ref
        .read(summaryNotifierProvider.notifier)
        .load(date: ref.read(summaryNotifierProvider).selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(summaryNotifierProvider);
    final hasSummary =
        state.summary != null &&
        (state.summary?.summaryText ?? '').trim().isNotEmpty;

    ref.listen(summaryNotifierProvider, (previous, next) {
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const AppPageHeader(
              title: 'Summary',
              subtitle: ProductCopy.summarySubtitle,
            ),
            SliverToBoxAdapter(
              child: DayNavigatorHeader(
                date: state.selectedDate,
                subtitle: hasSummary ? '1 reflection' : null,
                isSaving: state.isSaving,
                isLoadingDay: state.isLoading,
                primaryGenerate: !hasSummary,
                showGenerateButton: !hasSummary,
                overflowGenerateLabel: 'Refresh insight',
                onPreviousDay: () async {
                  await ref
                      .read(summaryNotifierProvider.notifier)
                      .changeDay(
                        date: state.selectedDate.subtract(
                          const Duration(days: 1),
                        ),
                      );
                },
                onNextDay: () async {
                  await ref
                      .read(summaryNotifierProvider.notifier)
                      .changeDay(
                        date: state.selectedDate.add(const Duration(days: 1)),
                      );
                },
                onGenerate: () async {
                  await ref
                      .read(summaryNotifierProvider.notifier)
                      .generate(date: state.selectedDate);
                },
                onDelete: () async {
                  await ref
                      .read(summaryNotifierProvider.notifier)
                      .delete(date: state.selectedDate);
                },
              ),
            ),
            _buildBody(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, dynamic state) {
    if (state.isLoading && state.summary == null) {
      return SliverAppLoadingList(
        itemCount: 3,
        bottomPadding: AppSpacing.navBarClearance(context),
      );
    }

    if (state.errorMessage != null && state.summary == null) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.summary,
          title: 'Failed to load summary',
          subtitle: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Try again',
          actionIcon: AppIcons.refresh,
          onAction: _load,
        ),
      );
    }

    if (state.summary == null) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.sparkle,
          title: 'No daily reflection yet',
          subtitle: 'Generate a summary to turn this day into a story.',
          actionLabel: 'Generate summary',
          actionIcon: AppIcons.sparkle,
          onAction: () async {
            await ref
                .read(summaryNotifierProvider.notifier)
                .generate(date: state.selectedDate);
          },
        ),
      );
    }

    final summary = state.summary;
    final hasExplanation = (summary.scoreExplanationText ?? '')
        .trim()
        .isNotEmpty;
    final hasInsight = (summary.optionalInsight ?? '').trim().isNotEmpty;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.xs,
        bottom: AppSpacing.navBarClearance(context),
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          AiSummaryCard(
            summaryText: summary.summaryText,
            topPlaceName: summary.topPlaceName,
            totalTasks: summary.totalTasks,
            completedTasks: summary.completedTasks,
            totalPlannedBlocks: summary.totalPlannedBlocks,
            totalStaySessions: summary.totalStaySessions,
            summaryMaxLines: 4,
            allowExpand: true,
          ),
          if (hasInsight) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            SummaryInsightCard(text: summary.optionalInsight!),
          ],
          if (hasExplanation) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            SummaryExplanationCard(text: summary.scoreExplanationText!),
          ],
          const SizedBox(height: AppSpacing.md),
        ]),
      ),
    );
  }
}
