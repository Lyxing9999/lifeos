import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_providers.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../application/user_providers.dart';
import 'profile_form_page.dart';


class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userNotifierProvider);
    final profile = state.profile;
    final userId = ref.read(currentUserIdProvider);

    if (profile == null) {
      return const Scaffold(body: AppLoadingView());
    }

    return ProfileFormPage(
      profile: profile,
      isSaving: state.isSaving,
      onSubmit: (result) async {
        final success = await ref
            .read(userNotifierProvider.notifier)
            .updateProfile(
              userId: userId,
              name: result.name,
              timezone: result.timezone,
              locale: result.locale,
            );

        if (success && context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
