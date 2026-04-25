import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_fab.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/app_sparse_state_card.dart';
import '../../application/place_providers.dart';
import '../../domain/model/place.dart';
import 'place_detail_page.dart';
import 'place_form_page.dart';
import '../widgets/place_card.dart';
import '../widgets/place_empty_state.dart';

class PlaceListPage extends ConsumerStatefulWidget {
  const PlaceListPage({super.key});

  @override
  ConsumerState<PlaceListPage> createState() => _PlaceListPageState();
}

class _PlaceListPageState extends ConsumerState<PlaceListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final userId = ref.read(currentUserIdProvider);
    await ref.read(placeNotifierProvider.notifier).loadPlaces(userId);
  }

  Future<void> _openCreateForm() async {
    final userId = ref.read(currentUserIdProvider);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceFormPage(
          isSaving: false,
          onSubmit: (result) async {
            await ref
                .read(placeNotifierProvider.notifier)
                .create(
                  userId: userId,
                  name: result.name,
                  placeType: result.placeType,
                  latitude: result.latitude,
                  longitude: result.longitude,
                  matchRadiusMeters: result.matchRadiusMeters,
                );
          },
        ),
      ),
    );

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placeNotifierProvider);
    final userId = ref.read(currentUserIdProvider);

    ref.listen(placeNotifierProvider, (previous, next) {
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

    final items = List<Place>.from(state.items);
    final bottomPad =
        AppSpacing.navBarClearance(context) + (items.length < 4 ? 6 : 24);

    return Scaffold(
      floatingActionButton: AppPageFab(
        heroTag: 'places-new',
        onPressed: _openCreateForm,
        tooltip: 'New place',
        icon: Icons.add,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const AppPageHeader(
              title: 'Places',
              subtitle: ProductCopy.placesSubtitle,
            ),
            if (state.isLoading && items.isEmpty)
              SliverAppLoadingList(
                itemCount: 4,
                bottomPadding: AppSpacing.navBarClearance(context),
              )
            else if (state.errorMessage != null && items.isEmpty)
              SliverFillRemaining(
                child: AppEmptyView(
                  icon: Icons.place_outlined,
                  title: 'Failed to load places',
                  subtitle: state.errorMessage ?? 'Something went wrong.',
                  actionLabel: 'Try again',
                  actionIcon: Icons.refresh,
                  onAction: _load,
                ),
              )
            else if (items.isEmpty)
              SliverFillRemaining(
                child: PlaceEmptyState(onCreatePlace: _openCreateForm),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0 && items.length < 2) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AppSparseStateCard(
                          icon: Icons.insights_outlined,
                          title: 'Place insights need more anchors',
                          message:
                              'Add a few key places so stay sessions and summaries become clearer.',
                          actionLabel: 'Open location logs',
                          onAction: () => context.push(AppRoutes.location),
                        ),
                      );
                    }

                    final listIndex = items.length < 2 ? index - 1 : index;
                    if (listIndex < 0) return const SizedBox.shrink();

                    final item = items[listIndex];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: PlaceCard(
                        item: item,
                        onTap: () async {
                          await ref
                              .read(placeNotifierProvider.notifier)
                              .loadById(item.id);

                          if (!context.mounted) return;

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailPage(id: item.id),
                            ),
                          );

                          await ref
                              .read(placeNotifierProvider.notifier)
                              .loadPlaces(userId);
                        },
                      ),
                    );
                  }, childCount: items.length + (items.length < 2 ? 1 : 0)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
