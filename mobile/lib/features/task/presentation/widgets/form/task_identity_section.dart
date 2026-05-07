import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_chip.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../../../core/widgets/app_form_widget.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../content/task_copy.dart';
import 'task_form_constants.dart';

class TaskIdentitySection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController customCategoryController;

  final FocusNode titleFocus;
  final FocusNode descriptionFocus;
  final FocusNode customCategoryFocus;

  final String selectedCategory;
  final bool showCustomCategory;
  final bool showDescription;

  final ValueChanged<String> onSelectCategory;
  final VoidCallback onToggleCustomCategory;
  final VoidCallback onToggleDescription;

  const TaskIdentitySection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.customCategoryController,
    required this.titleFocus,
    required this.descriptionFocus,
    required this.customCategoryFocus,
    required this.selectedCategory,
    required this.showCustomCategory,
    required this.showDescription,
    required this.onSelectCategory,
    required this.onToggleCustomCategory,
    required this.onToggleDescription,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: TaskCopy.formSectionWhat,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextFormField(
            controller: titleController,
            focusNode: titleFocus,
            labelText: TaskCopy.formTitleLabel,
            hintText: TaskCopy.formTitleHint,
            textInputAction: TextInputAction.done,
            validator: FormValidators.requiredField(TaskCopy.formTitleLabel),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            TaskCopy.formCategoryLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ...taskCategoryOptions.map(
                (category) => AppChip.filter(
                  label: category,
                  selected: !showCustomCategory && selectedCategory == category,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectCategory(category);
                  },
                ),
              ),
              AppChip.filter(
                label: TaskCopy.formCategoryMore,
                icon: AppIcons.edit,
                selected: showCustomCategory,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggleCustomCategory();
                },
              ),
            ],
          ),
          if (showCustomCategory) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextFormField(
              controller: customCategoryController,
              focusNode: customCategoryFocus,
              labelText: TaskCopy.formCategoryCustomLabel,
              hintText: TaskCopy.formCategoryCustomHint,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          AppButton.ghost(
            label: showDescription
                ? TaskCopy.formHideNote
                : TaskCopy.formAddNote,
            icon: showDescription ? AppIcons.note : AppIcons.addNote,
            onPressed: () {
              HapticFeedback.selectionClick();
              onToggleDescription();
            },
          ),
          if (showDescription)
            AppTextFormField(
              controller: descriptionController,
              focusNode: descriptionFocus,
              labelText: TaskCopy.formNoteLabel,
              hintText: TaskCopy.formNoteHint,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
        ],
      ),
    );
  }
}
