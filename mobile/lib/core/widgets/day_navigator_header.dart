import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Shared day navigation header.
/// The date label slides left/right when the day changes — gives
/// a spatial sense of moving through time.
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
  late AnimationController _ctrl;
  late Animation<Offset> _slideIn;
  late Animation<double> _fade;

  DateTime _displayDate = DateTime.now();
  bool _goingForward = true;

  @override
  void initState() {
    super.initState();
    _displayDate = widget.date;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _buildAnimations();
    _ctrl.value = 1.0; // start fully visible
  }

  void _buildAnimations() {
    // Slide in from right (forward) or left (backward)
    _slideIn = Tween<Offset>(
      begin: Offset(_goingForward ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(DayNavigatorHeader old) {
    super.didUpdateWidget(old);
    if (old.date != widget.date) {
      _goingForward = widget.date.isAfter(old.date);
      _buildAnimations();
      _displayDate = widget.date;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat('EEE, dd MMM yyyy').format(_displayDate);
    final isToday = _isToday(_displayDate);
    final showOverflowGenerate =
        widget.onGenerate != null && !widget.showGenerateButton;
    final hasOverflow = widget.onDelete != null || showOverflowGenerate;
    final generateText = widget.isSaving ? 'Generating…' : widget.generateLabel;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Previous day
                IconButton(
                  onPressed: () {
                    _goingForward = false;
                    widget.onPreviousDay();
                  },
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: 'Previous day',
                  style: IconButton.styleFrom(
                    minimumSize: const Size(
                      AppSpacing.minTapTarget,
                      AppSpacing.minTapTarget,
                    ),
                  ),
                ),

                // Animated date label
                Expanded(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) => FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slideIn,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  label,
                                  style: AppTextStyles.dayLabel(context),
                                ),
                                if (isToday) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  _TodayBadge(),
                                ],
                              ],
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                style: AppTextStyles.dayCount(context),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Next day + overflow
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        _goingForward = true;
                        widget.onNextDay();
                      },
                      icon: const Icon(Icons.chevron_right_rounded),
                      tooltip: 'Next day',
                      style: IconButton.styleFrom(
                        minimumSize: const Size(
                          AppSpacing.minTapTarget,
                          AppSpacing.minTapTarget,
                        ),
                      ),
                    ),
                    if (hasOverflow)
                      PopupMenuButton<_DayAction>(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'More options',
                        onSelected: (action) {
                          if (action == _DayAction.generate) {
                            widget.onGenerate?.call();
                          }
                          if (action == _DayAction.delete) widget.onDelete!();
                        },
                        itemBuilder: (_) => [
                          if (showOverflowGenerate)
                            PopupMenuItem(
                              value: _DayAction.generate,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_outlined,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.overflowGenerateLabel ??
                                        'Regenerate',
                                  ),
                                ],
                              ),
                            ),
                          if (widget.onDelete != null)
                            const PopupMenuItem(
                              value: _DayAction.delete,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.danger,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),

            // Generate button — secondary by default, primary if requested
            if (widget.onGenerate != null && widget.showGenerateButton) ...[
              const SizedBox(height: AppSpacing.xs), // Tighter
              SizedBox(
                width: double.infinity,
                child: widget.primaryGenerate
                    ? FilledButton.icon(
                        onPressed: widget.isSaving ? null : widget.onGenerate,
                        icon: widget.isSaving
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(generateText),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: widget.isSaving ? null : widget.onGenerate,
                        icon: widget.isSaving
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : const Icon(
                                Icons.auto_awesome,
                                size: 16,
                              ), // Smaller icon
                        label: Text(generateText),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ), // Slightly smaller
                        ),
                      ),
              ),
            ],
            if (widget.isLoadingDay) ...[
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  minHeight: 2.5,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

enum _DayAction { generate, delete }

class _TodayBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Today',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
