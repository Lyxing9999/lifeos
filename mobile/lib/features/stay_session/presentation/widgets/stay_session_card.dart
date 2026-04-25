import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/model/stay_session.dart';

class StaySessionCard extends StatelessWidget {
  final StaySession item;

  const StaySessionCard({super.key, required this.item});

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  IconData _iconForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
      case 'office':
        return Icons.work_outline;
      case 'gym':
        return Icons.fitness_center_outlined;
      case 'cafe':
        return Icons.local_cafe_outlined;
      case 'study':
      case 'library':
        return Icons.menu_book_outlined;
      case 'travel':
        return Icons.flight_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final start = timeFormat.format(item.startTime);
    final end = timeFormat.format(item.endTime);
    final typeLabel = item.placeType ?? 'Location';
    final iconColor = AppColors.placeTypeIconColor(typeLabel);
    final bgColor = AppColors.placeTypeColor(context, typeLabel);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: AppSpacing.iconContainerSize,
              height: AppSpacing.iconContainerSize,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(
                  AppSpacing.iconContainerRadius,
                ),
              ),
              child: Icon(_iconForType(typeLabel), color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.placeName.isNotEmpty
                        ? item.placeName
                        : 'Unknown location',
                    style: AppTextStyles.cardTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$start – $end',
                    style: AppTextStyles.timeLabel(context),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDuration(item.durationMinutes),
                        style: AppTextStyles.cardSubtitle(context),
                      ),
                      if (typeLabel.isNotEmpty &&
                          typeLabel != 'Location') ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '·',
                          style: AppTextStyles.cardSubtitle(context),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          typeLabel,
                          style: AppTextStyles.cardSubtitle(context),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
