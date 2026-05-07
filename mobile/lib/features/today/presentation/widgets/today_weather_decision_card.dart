import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../domain/model/today_weather_insight.dart';

class TodayWeatherDecisionCard extends StatefulWidget {
  final TodayWeatherInsight insight;
  final VoidCallback? onTap;

  const TodayWeatherDecisionCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  State<TodayWeatherDecisionCard> createState() =>
      _TodayWeatherDecisionCardState();
}

class _TodayWeatherDecisionCardState extends State<TodayWeatherDecisionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final color = _colorForSeverity(insight.severity);
    final chipLabel = insight.isRealData ? 'Weather' : 'Later';

    return AppCard(
      glass: true,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulse = 0.96 + (_controller.value * 0.08);

                  return Transform.scale(scale: pulse, child: child);
                },
                child: Container(
                  width: AppSpacing.iconContainerSize,
                  height: AppSpacing.iconContainerSize,
                  decoration: BoxDecoration(
                    color: AppColors.iconBg(context, color),
                    borderRadius: BorderRadius.circular(AppRadius.icon),
                  ),
                  child: Icon(
                    _iconForSeverity(insight.severity),
                    color: color,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      title: insight.title,
                      chipLabel: chipLabel,
                      color: color,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      insight.message,
                      style: AppTextStyles.bodySecondary(context),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      insight.actionHint,
                      style: AppTextStyles.metaLabel(
                        context,
                      ).copyWith(color: color),
                    ),
                    if (!insight.isRealData) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _DemoForecastRow(color: color),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorForSeverity(TodayWeatherInsightSeverity severity) {
    switch (severity) {
      case TodayWeatherInsightSeverity.neutral:
        return AppColors.sky;
      case TodayWeatherInsightSeverity.helpful:
        return AppColors.green;
      case TodayWeatherInsightSeverity.caution:
        return AppColors.warning;
    }
  }

  static IconData _iconForSeverity(TodayWeatherInsightSeverity severity) {
    switch (severity) {
      case TodayWeatherInsightSeverity.neutral:
        return AppIcons.cloud;
      case TodayWeatherInsightSeverity.helpful:
        return AppIcons.cloudSun;
      case TodayWeatherInsightSeverity.caution:
        return AppIcons.umbrella;
    }
  }
}

class _DemoForecastRow extends StatelessWidget {
  final Color color;

  const _DemoForecastRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        AppChip.metadata(label: 'Demo preview', color: color),
        AppChip.metadata(label: '18°C', color: color),
        AppChip.metadata(label: '20% rain', color: color),
        AppChip.metadata(label: 'Light wind', color: color),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String chipLabel;
  final Color color;

  const _Header({
    required this.title,
    required this.chipLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.cardTitle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        AppChip.metadata(label: chipLabel, color: color),
      ],
    );
  }
}
