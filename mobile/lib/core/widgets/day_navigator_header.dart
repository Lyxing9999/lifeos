import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Shared day navigation header — flat, no glass shell.
class DayNavigatorHeader extends StatefulWidget {
  final DateTime date;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final String? subtitle;
  final VoidCallback? onGenerate;
  final VoidCallback? onDelete;
  final bool isSaving;
  final bool primaryGenerate;
  final bool showGenerateButton;
  final String generateLabel;
  final String? overflowGenerateLabel;
  final bool isLoadingDay;

  const DayNavigatorHeader({
    super.key,
    required this.date,
    required this.onPreviousDay,
    required this.onNextDay,
    this.subtitle,
    this.onGenerate,
    this.onDelete,
    this.isSaving = false,
    this.primaryGenerate = false,
    this.showGenerateButton = true,
    this.generateLabel = 'Generate',
    this.overflowGenerateLabel,
    this.isLoadingDay = false,
  });

  @override
  State<DayNavigatorHeader> createState() => _DayNavigatorHeaderState();
}

class _DayNavigatorHeaderState extends State<DayNavigatorHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  late DateTime _displayDate;
  bool _goingForward = true;

  @override
  void initState() {
    super.initState();
    _displayDate = widget.date;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );
    _buildAnimations();
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant DayNavigatorHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.date, widget.date)) {
      _goingForward = widget.date.isAfter(oldWidget.date);
      _displayDate = widget.date;
      _buildAnimations();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buildAnimations() {
    _slide = Tween<Offset>(
      begin: Offset(_goingForward ? 0.24 : -0.24, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday() {
    final now = DateTime.now();
    return _isSameDay(_displayDate, now);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasOverflow =
        widget.onDelete != null ||
        (widget.onGenerate != null && !widget.showGenerateButton);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Flat navigation row ──────────────────────────────────────────
          Row(
            children: [
              // Previous
              IconButton(
                tooltip: 'Previous day',
                icon: Icon(
                  AppIcons.chevronLeft,
                  color: scheme.onSurfaceVariant,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  widget.onPreviousDay();
                },
              ),

              // Date label (animated)
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE, dd MMM yyyy')
                                  .format(_displayDate),
                              style: AppTextStyles.pageTitle(context).copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_isToday()) ...[
                              const SizedBox(width: AppSpacing.sm),
                              _TodayChip(),
                            ],
                          ],
                        ),
                        if ((widget.subtitle ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!.trim(),
                            style: AppTextStyles.dayCount(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Next + overflow
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Next day',
                    icon: Icon(
                      AppIcons.chevronRight,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      widget.onNextDay();
                    },
                  ),
                  if (hasOverflow)
                    _DayOverflowMenu(
                      onGenerate: widget.showGenerateButton
                          ? null
                          : widget.onGenerate,
                      onDelete: widget.onDelete,
                      generateLabel:
                          widget.overflowGenerateLabel ?? 'Regenerate',
                    ),
                ],
              ),
            ],
          ),

          // ── Optional generate button ─────────────────────────────────────
          if (widget.onGenerate != null && widget.showGenerateButton) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: widget.primaryGenerate
                  ? AppButton.primary(
                      label: widget.isSaving
                          ? 'Generating...'
                          : widget.generateLabel,
                      icon: AppIcons.sparkle,
                      isLoading: widget.isSaving,
                      onPressed: widget.isSaving ? null : widget.onGenerate,
                    )
                  : AppButton.secondary(
                      label: widget.isSaving
                          ? 'Generating...'
                          : widget.generateLabel,
                      icon: AppIcons.sparkle,
                      isLoading: widget.isSaving,
                      onPressed: widget.isSaving ? null : widget.onGenerate,
                    ),
            ),
          ],

          // ── Loading bar ──────────────────────────────────────────────────
          if (widget.isLoadingDay) ...[
            const SizedBox(height: AppSpacing.sm),
            _DayLoadingBar(),
          ],
        ],
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
      child: Text(
        'TODAY',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _DayOverflowMenu extends StatelessWidget {
  final VoidCallback? onGenerate;
  final VoidCallback? onDelete;
  final String generateLabel;

  const _DayOverflowMenu({
    required this.onGenerate,
    required this.onDelete,
    required this.generateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<_DayAction>(
      tooltip: 'More options',
      icon: Icon(AppIcons.moreVertical, color: scheme.onSurfaceVariant),
      onSelected: (action) {
        HapticFeedback.selectionClick();
        switch (action) {
          case _DayAction.generate:
            onGenerate?.call();
          case _DayAction.delete:
            onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        if (onGenerate != null)
          PopupMenuItem(
            value: _DayAction.generate,
            child: Row(
              children: [
                Icon(AppIcons.sparkle, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(generateLabel),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: _DayAction.delete,
            child: Row(
              children: [
                Icon(AppIcons.delete, size: 18, color: AppColors.danger),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: AppColors.danger)),
              ],
            ),
          ),
      ],
    );
  }
}

enum _DayAction { generate, delete }

class _DayLoadingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: LinearProgressIndicator(
        minHeight: 2.5,
        backgroundColor: scheme.primary.withValues(alpha: 0.08),
        color: scheme.primary.withValues(alpha: 0.76),
      ),
    );
  }
}

