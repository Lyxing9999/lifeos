import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../application/location_providers.dart';
import '../widgets/location_log_tile.dart';

class LocationHistoryPage extends ConsumerStatefulWidget {
  const LocationHistoryPage({super.key});

  @override
  ConsumerState<LocationHistoryPage> createState() =>
      _LocationHistoryPageState();
}

class _LocationHistoryPageState extends ConsumerState<LocationHistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(currentUserIdProvider);
      ref
          .read(locationNotifierProvider.notifier)
          .loadByDay(userId: userId, date: DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    ref.listen(locationNotifierProvider, (previous, next) {
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
        onRefresh: () async {
          await ref
              .read(locationNotifierProvider.notifier)
              .loadByDay(userId: userId, date: state.selectedDate);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AppPageHeader(
              title: 'Location logs',
              subtitle:
                  'Raw location data that powers stay sessions and summaries',
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: PopupMenuButton<_LocationToolAction>(
                    tooltip: 'Location tools',
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (action) async {
                      if (action == _LocationToolAction.addLocationLog) {
                        await ref
                            .read(locationNotifierProvider.notifier)
                            .addSingle(
                              userId: userId,
                              latitude: 11.5621,
                              longitude: 104.9310,
                              accuracyMeters: 6,
                              source: 'MOBILE_GPS',
                              recordedAt: DateTime.now(),
                            );
                        return;
                      }

                      await ref
                          .read(locationNotifierProvider.notifier)
                          .addDemoBatch(userId: userId);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _LocationToolAction.addLocationLog,
                        child: Text('Add location log'),
                      ),
                      PopupMenuItem(
                        value: _LocationToolAction.importSampleBatch,
                        child: Text('Import sample batch'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: DayNavigatorHeader(
                date: state.selectedDate,
                subtitle: state.logs.isNotEmpty
                    ? '${state.logs.length} logs'
                    : null,
                isLoadingDay: state.isLoading,
                onPreviousDay: () => ref
                    .read(locationNotifierProvider.notifier)
                    .changeDay(
                      userId: userId,
                      date: state.selectedDate.subtract(
                        const Duration(days: 1),
                      ),
                    ),
                onNextDay: () => ref
                    .read(locationNotifierProvider.notifier)
                    .changeDay(
                      userId: userId,
                      date: state.selectedDate.add(const Duration(days: 1)),
                    ),
              ),
            ),
            _buildBody(state, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(dynamic state, String userId) {
    if (state.isLoading && state.logs.isEmpty) {
      return SliverAppLoadingList(
        itemCount: 6,
        bottomPadding: AppSpacing.navBarClearance(context),
      );
    }

    if (state.errorMessage != null && state.logs.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: Icons.location_on_outlined,
          title: 'Failed to load location logs',
          subtitle: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Try again',
          actionIcon: Icons.refresh,
          onAction: () => ref
              .read(locationNotifierProvider.notifier)
              .loadByDay(userId: userId, date: state.selectedDate),
        ),
      );
    }

    if (state.logs.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: Icons.location_on_outlined,
          title: 'No location data for this day',
          subtitle: 'Location logs for the selected day will appear here.',
          actionLabel: 'Add location log',
          actionIcon: Icons.add_location_alt_outlined,
          onAction: () => ref
              .read(locationNotifierProvider.notifier)
              .addSingle(
                userId: userId,
                latitude: 11.5621,
                longitude: 104.9310,
                accuracyMeters: 6,
                source: 'MOBILE_GPS',
                recordedAt: DateTime.now(),
              ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.pageVertical,
        bottom: AppSpacing.navBarClearance(context) + 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
            child: LocationLogTile(log: state.logs[index]),
          ),
          childCount: state.logs.length,
        ),
      ),
    );
  }
}

enum _LocationToolAction { addLocationLog, importSampleBatch }
