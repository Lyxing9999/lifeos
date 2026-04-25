import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/model/location_log.dart';

class LocationLogTile extends StatelessWidget {
  final LocationLog log;

  const LocationLogTile({super.key, required this.log});

  /// Returns a subtle color based on the hour — gives visual rhythm to the log list.
  Color _hourColor(int hour) {
    // Centralize hour-color decisions in AppColors so changes propagate.
    return AppColors.locationHourColor(hour);
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm:ss a').format(log.recordedAt);
    final hour = log.recordedAt.hour;
    final color = _hourColor(hour);
    final accuracyLabel = log.accuracyMeters != null
        ? '±${log.accuracyMeters!.toStringAsFixed(0)}m'
        : null;

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          children: [
            Container(
              width: AppSpacing.iconContainerSize,
              height: AppSpacing.iconContainerSize,
              decoration: BoxDecoration(
                color: AppColors.iconBg(context, color),
                borderRadius: BorderRadius.circular(
                  AppSpacing.iconContainerRadius,
                ),
              ),
              child: Icon(Icons.location_on_outlined, size: 20, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: AppTextStyles.cardTitle(context)),
                  if (accuracyLabel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Accuracy $accuracyLabel',
                      style: AppTextStyles.cardSubtitle(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
