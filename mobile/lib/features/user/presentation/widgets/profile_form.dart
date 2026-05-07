import 'package:flutter/material.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController timezoneController;
  final TextEditingController localeController;
  final bool isSaving;
  final VoidCallback onSubmit;

  const ProfileForm({
    super.key,
    required this.nameController,
    required this.timezoneController,
    required this.localeController,
    required this.isSaving,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Name',
          hint: 'Your display name',
          controller: nameController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(AppIcons.profile),
          showClearButton: true,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: 'Timezone',
          hint: 'e.g. Asia/Phnom_Penh',
          controller: timezoneController,
          textInputAction: TextInputAction.next,
          prefixIcon: const Icon(AppIcons.timezone),
          showClearButton: true,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Timezone is required' : null,
        ),
        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: 'Locale',
          hint: 'e.g. en_US',
          controller: localeController,
          textInputAction: TextInputAction.done,
          prefixIcon: const Icon(AppIcons.language),
          showClearButton: true,
          onFieldSubmitted: (_) => onSubmit(),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Locale is required' : null,
        ),
        const SizedBox(height: AppSpacing.xl),

        AppButton.primary(
          label: isSaving ? 'Saving…' : 'Save Profile',
          onPressed: isSaving ? null : onSubmit,
          isLoading: isSaving,
          icon: AppIcons.check,
        ),
      ],
    );
  }
}
