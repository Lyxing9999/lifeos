import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class TodayHeaderSection extends StatelessWidget {
  final String userName;
  final DateTime date;
  final VoidCallback onProfileTap;

  const TodayHeaderSection({
    super.key,
    required this.userName,
    required this.date,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final formattedDate = DateFormat('EEEE, d MMMM').format(date);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm, // Tighter (was md)
          AppSpacing.pageHorizontal,
          AppSpacing.xs, // Tighter (was sm)
        ),
        child: Row(
          children: [
            // Logo removed for cleaner look
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(userName),
                    style: AppTextStyles.pageTitle(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: AppTextStyles.bodySecondary(context),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.12), // Softer
                  border: Border.all(
                    color: primary.withValues(alpha: 0.18), // Softer
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(userName),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _greeting(String name) {
    final hour = DateTime.now().hour;
    final first = name.trim().isEmpty ? 'there' : name.split(' ').first;

    if (hour < 5) return 'Still up, $first?';
    if (hour < 12) return 'Good morning, $first';
    if (hour < 17) return 'Good afternoon, $first';
    if (hour < 21) return 'Good evening, $first';
    return 'Good night, $first';
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
