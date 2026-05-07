import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../content/task_copy.dart';

class TaskTagsSection extends StatelessWidget {
  final TextEditingController tagController;
  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;

  const TaskTagsSection({
    super.key,
    required this.tagController,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: TaskCopy.formSectionTags,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: tagController,
            textCapitalization: TextCapitalization.none,
            decoration: const InputDecoration(
              labelText: 'Add tag',
              hintText: 'focus, deep-work, errands',
              border: OutlineInputBorder(),
              suffixIcon: Icon(AppIcons.tags, size: 18),
            ),
            onSubmitted: (_) => onAddTag(),
            onChanged: (value) {
              if (value.endsWith(',') || value.endsWith(' ,')) {
                onAddTag();
              }
            },
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: tags.map((tag) {
                return InputChip(
                  label: Text(tag),
                  onDeleted: () {
                    HapticFeedback.selectionClick();
                    onRemoveTag(tag);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
