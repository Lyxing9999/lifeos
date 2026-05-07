import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../application/place_providers.dart';
import 'place_form_page.dart';

class EditPlacePage extends ConsumerStatefulWidget {
  final String placeId;

  const EditPlacePage({super.key, required this.placeId});

  @override
  ConsumerState<EditPlacePage> createState() => _EditPlacePageState();
}

class _EditPlacePageState extends ConsumerState<EditPlacePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(placeNotifierProvider.notifier).loadById(widget.placeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placeNotifierProvider);
    final place = state.selectedItem;
    final userId = ref.read(currentUserIdProvider);

    if (place == null || place.id != widget.placeId) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PlaceFormPage(
      existing: place,
      isSaving: state.isSaving,
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
    );
  }
}
