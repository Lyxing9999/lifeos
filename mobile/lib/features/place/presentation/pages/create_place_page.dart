import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../application/place_providers.dart';
import 'place_form_page.dart';

class CreatePlacePage extends ConsumerWidget {
  const CreatePlacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(currentUserIdProvider);
    final isSaving = ref.watch(placeNotifierProvider).isSaving;

    return PlaceFormPage(
      isSaving: isSaving,
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
    );
  }
}
