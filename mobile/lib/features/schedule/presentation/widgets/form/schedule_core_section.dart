import 'package:flutter/material.dart';
import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../../../core/widgets/app_form_widget.dart';
import '../../../content/schedule_copy.dart';
import '../../../domain/enum/schedule_block_type.dart';
import '../../widgets/schedule_type_chip.dart';

class ScheduleCoreSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final FocusNode titleFocus;
  final FocusNode descriptionFocus;
  final ScheduleBlockType selectedType;
  final ValueChanged<ScheduleBlockType> onSelectType;

  const ScheduleCoreSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.titleFocus,
    required this.descriptionFocus,
    required this.selectedType,
    required this.onSelectType,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: ScheduleCopy.formSectionCore,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextFormField(
            controller: titleController,
            focusNode: titleFocus,
            hintText: ScheduleCopy.formTitleHint,
            prefixIcon: AppIcons.schedule,
            textInputAction: TextInputAction.next,
            validator: FormValidators.requiredField('Title'),
            onFieldSubmitted: (_) => descriptionFocus.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ScheduleBlockType.values.map((type) {
              return GestureDetector(
                onTap: () => onSelectType(type),
                child: ScheduleTypeChip(
                  type: type,
                  selected: selectedType == type,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppTextFormField(
            controller: descriptionController,
            focusNode: descriptionFocus,
            hintText: ScheduleCopy.formDescriptionHint,
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
