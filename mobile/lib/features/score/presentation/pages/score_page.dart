import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/content/product_terms.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../application/score_providers.dart';
import '../../application/score_state.dart';
import '../widgets/score_breakdown_card.dart';
import '../widgets/score_hero_card.dart';

class ScorePage extends ConsumerStatefulWidget {
  const ScorePage({super.key});

  @override
  ConsumerState<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends ConsumerState<ScorePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  String get _userId => ref.read(currentUserIdProvider);

  Future<void> _load() async {
    if (_userId.isEmpty) return;

    await ref
        .read(scoreNotifierProvider.notifier)
        .load(
          userId: _userId,
          date: ref.read(scoreNotifierProvider).selectedDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scoreNotifierProvider);
    final hasScore = state.score != null;

    ref.listen(scoreNotifierProvider, (previous, next) {
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
              title: ProductTerms.dailyScore,
              subtitle: ProductCopy.scoreSubtitle,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: DayNavigatorHeader(
                  date: state.selectedDate,
                  subtitle: hasScore ? '1 score snapshot' : null,
                  isSaving: state.isSaving,
                  isLoadingDay: state.isLoading,
                  primaryGenerate: !hasScore,
                  showGenerateButton: !hasScore,
                  overflowGenerateLabel: 'Refresh score',
                  onPreviousDay: () => ref
                      .read(scoreNotifierProvider.notifier)
                      .changeDay(
                        userId: _userId,
                        date: state.selectedDate.subtract(
                          const Duration(days: 1),
                        ),
                      ),
                  onNextDay: () => ref
                      .read(scoreNotifierProvider.notifier)
                      .changeDay(
                        userId: _userId,
                        date: state.selectedDate.add(const Duration(days: 1)),
                      ),
                  onGenerate: () => ref
                      .read(scoreNotifierProvider.notifier)
                      .generate(userId: _userId, date: state.selectedDate),
                  onDelete: () => ref
                      .read(scoreNotifierProvider.notifier)
                      .delete(userId: _userId, date: state.selectedDate),
                ),
              ),
            ),
            _buildBody(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScoreState state) {
    if (state.isLoading && state.score == null) {
      return SliverAppLoadingList(
        itemCount: 3,
        bottomPadding: AppSpacing.navBarClearance(context),
      );
    }

    if (state.errorMessage != null && state.score == null) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: Icons.auto_graph_outlined,
          title: 'Failed to load score',
          subtitle: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Try again',
          actionIcon: Icons.refresh,
          onAction: _load,
        ),
      );
    }

    if (state.score == null) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: Icons.auto_graph_outlined,
          title: 'No daily score yet',
          subtitle:
              'Generate a score to see how completion and structure came together.',
          actionLabel: 'Generate score',
          actionIcon: Icons.auto_graph_outlined,
          onAction: () async {
            await ref
                .read(scoreNotifierProvider.notifier)
                .generate(userId: _userId, date: state.selectedDate);
          },
        ),
      );
    }

    final score = state.score!;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.md,
        bottom: AppSpacing.navBarClearance(context),
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ScoreHeroCard(score: score),
          const SizedBox(height: AppSpacing.md),
          ScoreBreakdownCard(score: score),
          const SizedBox(height: AppSpacing.xxl),
        ]),
      ),
    );
  }
}
