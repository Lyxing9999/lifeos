import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../application/place_providers.dart';
import '../widgets/place_map_preview.dart';
import '../widgets/place_primary_badge.dart';
import '../widgets/place_type_chip.dart';
import 'place_form_page.dart';

class PlaceDetailPage extends ConsumerWidget {
  final String id;

  const PlaceDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placeNotifierProvider);
    final place = state.selectedItem;
    final userId = ref.read(currentUserIdProvider);

    if (place == null) {
      return const Scaffold(body: AppLoadingView());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Detail'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlaceFormPage(
                    existing: place,
                    isSaving: false,
                    onSubmit: (result) async {
                      await ref
                          .read(placeNotifierProvider.notifier)
                          .update(
                            userId: userId,
                            id: place.id,
                            name: result.name,
                            placeType: result.placeType,
                            latitude: result.latitude,
                            longitude: result.longitude,
                            matchRadiusMeters: result.matchRadiusMeters,
                            active: result.active,
                          );
                    },
                  ),
                ),
              );

              await ref.read(placeNotifierProvider.notifier).loadById(id);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete place?'),
                  content: Text('"${place.name}" will be permanently removed.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;

              await ref
                  .read(placeNotifierProvider.notifier)
                  .delete(userId: userId, id: place.id);

              if (context.mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.pageVertical,
          AppSpacing.pageHorizontal,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place.name, style: AppTextStyles.pageTitle(context)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                PlaceTypeChip(type: place.placeType),
                if (!place.active) const PlacePrimaryBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            PlaceMapPreview(
              latitude: place.latitude,
              longitude: place.longitude,
              radius: place.matchRadiusMeters,
            ),
            const SizedBox(height: AppSpacing.md),

            Card(
              child: Padding(
                padding: AppSpacing.cardInsets,
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Latitude',
                      value: place.latitude.toStringAsFixed(6),
                    ),
                    const Divider(height: AppSpacing.xl),
                    _DetailRow(
                      label: 'Longitude',
                      value: place.longitude.toStringAsFixed(6),
                    ),
                    const Divider(height: AppSpacing.xl),
                    _DetailRow(
                      label: 'Radius',
                      value: '${place.matchRadiusMeters.toInt()} m',
                    ),
                    const Divider(height: AppSpacing.xl),
                    _DetailRow(
                      label: 'Status',
                      value: place.active ? 'Active' : 'Inactive',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTextStyles.bodySecondary(context)),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.cardTitle(context),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
