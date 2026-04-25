import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_form_section.dart';
import '../../../../core/widgets/app_form_widget.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/model/user.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileFormPage — Senior-level form using AppFormMixin
//
// Principles applied:
//   1. Form key + inline validation via AppTextFormField
//   2. Keyboard submit on Enter (name → submit)
//   3. Chip pickers for locale (zero typing)
//   4. Radio-tile pickers for timezone (rich context: city + offset)
//   5. Safe async submit via AppFormMixin.submitForm
//   6. Read-only field with lock icon for email
// ─────────────────────────────────────────────────────────────────────────────

const _kTimezones = [
  _TzOption('Asia/Phnom_Penh', 'Phnom Penh', 'UTC+7'),
  _TzOption('Asia/Bangkok', 'Bangkok', 'UTC+7'),
  _TzOption('Asia/Singapore', 'Singapore', 'UTC+8'),
  _TzOption('Asia/Tokyo', 'Tokyo', 'UTC+9'),
  _TzOption('UTC', 'UTC', 'UTC+0'),
];

class _TzOption {
  final String value;
  final String city;
  final String offset;

  const _TzOption(this.value, this.city, this.offset);
}

class _LocaleOption {
  final String value;
  final String label;

  const _LocaleOption(this.value, this.label);
}

class ProfileFormPage extends StatefulWidget {
  final AppUser profile;
  final Future<void> Function(ProfileFormResult result) onSubmit;
  final bool isSaving;

  const ProfileFormPage({
    super.key,
    required this.profile,
    required this.onSubmit,
    required this.isSaving,
  });

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage>
    with AppFormMixin {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  late String _selectedLocale;
  late String _selectedTimezone;

  static const _localeOptions = [
    _LocaleOption('en', 'English'),
    _LocaleOption('km', 'ខ្មែរ'),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.profile.name;
    _selectedLocale = widget.profile.locale;
    _selectedTimezone = widget.profile.timezone;
    Future.microtask(() => _nameFocus.requestFocus());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    await widget.onSubmit(
      ProfileFormResult(
        name: _nameController.text.trim(),
        locale: _selectedLocale,
        timezone: _selectedTimezone,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return buildFormPage(
      title: 'Edit Profile',
      subtitle: 'Update your defaults',
      submitLabel: 'Save Changes',
      submitIcon: Icons.check_rounded,
      isSaving: widget.isSaving,
      isEdit: true,
      onSubmit: _submit,
      shouldPopOnSubmit: true,
      children: [
        AppFormSection(
          title: 'Name',
          child: AppTextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            hintText: 'Your display name',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            validator: FormValidators.requiredField('Name'),
            onFieldSubmitted: (_) => _submit(),
          ),
        ),

        AppFormSection(
          title: 'Email',
          subtitle: 'Cannot be changed here',
          child: _ReadOnlyField(
            icon: Icons.email_outlined,
            value: widget.profile.email,
          ),
        ),

        AppFormSection(
          title: 'Language',
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _localeOptions.map((opt) {
              final selected = _selectedLocale == opt.value;
              return _SelectChip(
                label: opt.label,
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedLocale = opt.value);
                },
              );
            }).toList(),
          ),
        ),

        AppFormSection(
          title: 'Timezone',
          subtitle: 'Used for day-based views and summaries',
          child: Column(
            children: _kTimezones.map((tz) {
              final selected = _selectedTimezone == tz.value;
              return _TimezoneTile(
                option: tz,
                selected: selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTimezone = tz.value);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReadOnlyField — Non-editable display field with lock icon
// ─────────────────────────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ReadOnlyField({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      readOnly: true,
      label: 'Read only field',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.bodyPrimary(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.lock_outline,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TimezoneTile — Rich radio tile with city + UTC offset
// ─────────────────────────────────────────────────────────────────────────────

class _TimezoneTile extends StatelessWidget {
  final _TzOption option;
  final bool selected;
  final VoidCallback onTap;

  const _TimezoneTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: selected
            ? AppColors.chipBg(context, color)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: selected
                    ? color
                    : Theme.of(context).colorScheme.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.city,
                        style: AppTextStyles.cardTitle(context).copyWith(
                          color: selected
                              ? color
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.offset,
                        style: AppTextStyles.bodySecondary(context),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SelectChip — Pill-shaped selection chip
// ─────────────────────────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.chipBg(context, color)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color:
                  selected ? color : Theme.of(context).colorScheme.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.chipLabel(context).copyWith(
              color: selected
                  ? color
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileFormResult (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class ProfileFormResult {
  final String name;
  final String locale;
  final String timezone;

  const ProfileFormResult({
    required this.name,
    required this.locale,
    required this.timezone,
  });
}
