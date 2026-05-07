import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_glass_icon_button.dart';
import '../../application/schedule_providers.dart';
import '../../domain/entities/schedule_block.dart';
import '../widgets/schedule_block_card.dart';

class ScheduleHistoryPage extends ConsumerWidget {
  const ScheduleHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleNotifierProvider);
    final historyBlocks = state.surfaces?.historyBlocks ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule History'),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: AppGlassIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Go back',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(scheduleNotifierProvider.notifier)
              .loadSurfaces(date: DateTime.now());
        },
        child: historyBlocks.isEmpty
            ? _buildEmptyState(context)
            : _buildHistoryList(context, historyBlocks),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: AppEmptyView(
            icon: AppIcons.archive,
            title: 'No History Yet',
            subtitle: 'Expired and archived schedules will appear here.',
          ),
        ),
      ],
    );
  }

  // FIXED: Changed List<dynamic> to List<ScheduleBlock>
  Widget _buildHistoryList(
    BuildContext context,
    List<ScheduleBlock> historyBlocks,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            top: AppSpacing.md,
            bottom: AppSpacing.navBarClearance(context),
          ),
          sliver: SliverList.builder(
            itemCount: historyBlocks.length,
            itemBuilder: (context, index) {
              final block = historyBlocks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
                child: Opacity(
                  opacity: 0.6, // Gives it that "disabled/past" look
                  child: ScheduleBlockCard(
                    block: block,
                    onTap: () {}, // Read-only: no navigation on tap
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
