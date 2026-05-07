import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_status_banner.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../../location/application/location_providers.dart';
import '../../application/stay_session_providers.dart';
import '../../domain/model/stay_session.dart';
import '../widgets/stay_session_card.dart';

class StaySessionPage extends ConsumerStatefulWidget {
  const StaySessionPage({super.key});

  @override
  ConsumerState<StaySessionPage> createState() => _StaySessionPageState();
}

class _StaySessionPageState extends ConsumerState<StaySessionPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final selectedDate = ref.read(staySessionNotifierProvider).selectedDate;
    await _loadDay(selectedDate);
  }

  Future<void> _loadDay(DateTime date) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return;

    await ref
        .read(locationNotifierProvider.notifier)
        .loadByDay(userId: userId, date: date);

    await ref
        .read(staySessionNotifierProvider.notifier)
        .load(userId: userId, date: date);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staySessionNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    ref.listen(staySessionNotifierProvider, (previous, next) {
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
              title: 'Stay sessions',
              subtitle:
                  'Grouped stay sessions derived from your raw location logs',
            ),
            SliverToBoxAdapter(
              child: DayNavigatorHeader(
                date: state.selectedDate,
                isSaving: state.isSaving,
                subtitle: state.items.isNotEmpty
                    ? '${state.items.length} sessions'
                    : null,
                isLoadingDay: state.isLoading,
                onPreviousDay: () async {
                  await _loadDay(
                    state.selectedDate.subtract(const Duration(days: 1)),
                  );
                },
                onNextDay: () async {
                  await _loadDay(
                    state.selectedDate.add(const Duration(days: 1)),
                  );
                },
                onDelete: () async {
                  await ref
                      .read(staySessionNotifierProvider.notifier)
                      .delete(userId: userId, date: state.selectedDate);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: _StaySessionStatusBanner(
                  hasLocationLogs: locationState.logs.isNotEmpty,
                  sessions: state.items,
                  isSaving: state.isSaving,
                  onOpenLocationLogs: () => context.push(AppRoutes.location),
                  onRebuild: () async {
                    await ref
                        .read(staySessionNotifierProvider.notifier)
                        .rebuild(userId: userId, date: state.selectedDate);
                  },
                ),
              ),
            ),
            _buildBody(
              state: state,
              hasLocationLogs: locationState.logs.isNotEmpty,
              onOpenLocationLogs: () => context.push(AppRoutes.location),
              onRebuild: () async {
                await ref
                    .read(staySessionNotifierProvider.notifier)
                    .rebuild(userId: userId, date: state.selectedDate);
              },
              onRetry: () async {
                await _loadDay(state.selectedDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required dynamic state,
    required bool hasLocationLogs,
    required VoidCallback onOpenLocationLogs,
    required VoidCallback onRebuild,
    required VoidCallback onRetry,
  }) {
    if (state.isLoading && state.items.isEmpty) {
      return SliverAppLoadingList(
        itemCount: 4,
        bottomPadding: AppSpacing.navBarClearance(context),
      );
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.places,
          title: 'Failed to load stay sessions',
          subtitle: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Try again',
          actionIcon: AppIcons.refresh,
          onAction: onRetry,
        ),
      );
    }

    if (state.items.isEmpty) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.places,
          title: 'No stay sessions yet',
          subtitle: hasLocationLogs
              ? 'Rebuild stay sessions to group your location data.'
              : 'Add location logs first, then rebuild stay sessions for this day.',
          actionLabel: hasLocationLogs
              ? 'Rebuild stay sessions'
              : 'Open location logs',
          actionIcon: hasLocationLogs
              ? AppIcons.sparkle
              : AppIcons.externalLink,
          onAction: hasLocationLogs ? onRebuild : onOpenLocationLogs,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.pageVertical,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.listItemGap),
            child: StaySessionCard(item: state.items[index]),
          ),
          childCount: state.items.length,
        ),
      ),
    );
  }
}

class _StaySessionStatusBanner extends StatelessWidget {
  final bool hasLocationLogs;
  final List<StaySession> sessions;
  final bool isSaving;
  final VoidCallback onOpenLocationLogs;
  final VoidCallback onRebuild;

  const _StaySessionStatusBanner({
    required this.hasLocationLogs,
    required this.sessions,
    required this.isSaving,
    required this.onOpenLocationLogs,
    required this.onRebuild,
  });

  bool get _needsRebuild {
    return sessions.any((session) {
      final placeName = session.placeName.trim().toLowerCase();
      return placeName.isEmpty ||
          placeName == 'unknown' ||
          placeName == 'unknown location';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLocationLogs) {
      return AppStatusBanner(
        icon: AppIcons.locate,
        title: 'No location logs yet',
        message:
            'Stay sessions are derived from raw location logs. Add or import logs for this day first.',
        color: AppColors.amber,
        actions: [
          FilledButton.icon(
            onPressed: onOpenLocationLogs,
            icon: const Icon(AppIcons.externalLink),
            label: const Text('Open location logs'),
          ),
        ],
      );
    }

    if (sessions.isEmpty) {
      return AppStatusBanner(
        icon: AppIcons.magic,
        title: 'Ready to rebuild stay sessions',
        message:
            'Location logs are available. Rebuild stay sessions for this day.',
        color: AppColors.violet,
        actions: [
          FilledButton.icon(
            onPressed: isSaving ? null : onRebuild,
            icon: const Icon(AppIcons.magic),
            label: Text(isSaving ? 'Rebuilding…' : 'Rebuild'),
          ),
        ],
      );
    }

    if (_needsRebuild) {
      return AppStatusBanner(
        icon: AppIcons.warning,
        title: 'Some sessions need rebuilding',
        message:
            'Some stay sessions still need better place matching. Rebuild for this day.',
        color: AppColors.amber,
        actions: [
          FilledButton.icon(
            onPressed: isSaving ? null : onRebuild,
            icon: const Icon(AppIcons.sync),
            label: Text(isSaving ? 'Rebuilding…' : 'Rebuild'),
          ),
        ],
      );
    }

    return AppStatusBanner(
      icon: AppIcons.success,
      title: 'Stay sessions are ready',
      message:
          'This day already has stay sessions and is ready for summary and score insights.',
      color: AppColors.green,
    );
  }
}
