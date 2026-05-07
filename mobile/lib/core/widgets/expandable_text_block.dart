import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class ExpandableTextBlock extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int collapsedMaxLines;
  final bool allowExpand;
  final String expandLabel;
  final String collapseLabel;

  const ExpandableTextBlock({
    super.key,
    required this.text,
    this.style,
    this.collapsedMaxLines = 4,
    this.allowExpand = true,
    this.expandLabel = 'Read more',
    this.collapseLabel = 'Show less',
  });

  @override
  State<ExpandableTextBlock> createState() => _ExpandableTextBlockState();
}

class _ExpandableTextBlockState extends State<ExpandableTextBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? AppTextStyles.bodyPrimary(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final canExpand = _canTextExpand(
          context: context,
          style: baseStyle,
          maxWidth: constraints.maxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: baseStyle,
                maxLines: canExpand && !_expanded
                    ? widget.collapsedMaxLines
                    : null,
                overflow: canExpand && !_expanded
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
              ),
            ),
            if (canExpand) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _expanded = !_expanded);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  _expanded ? widget.collapseLabel : widget.expandLabel,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  bool _canTextExpand({
    required BuildContext context,
    required TextStyle style,
    required double maxWidth,
  }) {
    if (!widget.allowExpand || widget.text.trim().isEmpty) {
      return false;
    }

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: widget.collapsedMaxLines,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }
}
