import 'package:flutter/material.dart';
import '../../../../../app/theme/app_icons.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_form_section.dart';
import '../../../../../core/widgets/app_picker_tile.dart';
import '../../../content/schedule_copy.dart';

class ScheduleTimeSection extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;

  const ScheduleTimeSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onPickStartTime,
    required this.onPickEndTime,
  });

  String _formatTime(BuildContext context, TimeOfDay time) {
    return time.format(context);
  }

  String get _durationLabel {
    final startMins = startTime.hour * 60 + startTime.minute;
    final endMins = endTime.hour * 60 + endTime.minute;
    final mins = endMins - startMins;
    if (mins <= 0) return 'Invalid range';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: ScheduleCopy.formSectionTimeBlock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppPickerTile(
                  label: ScheduleCopy.formStartTime,
                  value: _formatTime(context, startTime),
                  icon: AppIcons.time,
                  onTap: onPickStartTime,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppPickerTile(
                  label: ScheduleCopy.formEndTime,
                  value: _formatTime(context, endTime),
                  icon: AppIcons.time,
                  onTap: onPickEndTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${ScheduleCopy.formDurationPrefix}: $_durationLabel',
            style: AppTextStyles.bodySecondary(context),
          ),
        ],
      ),
    );
  }
}
