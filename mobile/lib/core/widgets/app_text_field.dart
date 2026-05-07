import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_glass_style.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import 'app_glass_icon_button.dart';

/// LifeOS shared input field.
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool showClearButton;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.onTap,
    this.showClearButton = false,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;
  bool _hasText = false;
  bool _focused = false;
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();

    _obscure = widget.obscureText;
    _hasText = (widget.controller?.text ?? '').isNotEmpty;
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_onFocusChanged);

    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
      _hasText = (widget.controller?.text ?? '').isNotEmpty;
    }

    if (oldWidget.focusNode != widget.focusNode) {
      _effectiveFocusNode.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) {
        _effectiveFocusNode.dispose();
      }
      _effectiveFocusNode = widget.focusNode ?? FocusNode();
      _effectiveFocusNode.addListener(_onFocusChanged);
    }

    if (oldWidget.obscureText != widget.obscureText) {
      _obscure = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = (widget.controller?.text ?? '').isNotEmpty;

    if (hasText == _hasText) return;

    setState(() => _hasText = hasText);
  }

  void _onFocusChanged() {
    setState(() => _focused = _effectiveFocusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = AppColors.liquidControl(context);
    final border = AppColors.glassBorder(context);
    final radius = BorderRadius.circular(AppRadius.card);

    final field = TextFormField(
      controller: widget.controller,
      focusNode: _effectiveFocusNode,
      validator: widget.validator,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      textCapitalization: widget.textCapitalization,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffix(context),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: border, width: 0.9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: border, width: 0.9),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: isDark ? 0.90 : 0.85),
            width: 1.35,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: scheme.error.withValues(alpha: 0.78),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error, width: 1.35),
        ),
      ),
    );

    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.fast),
      curve: AppMotion.standardCurve,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: _focused
            ? AppGlassStyle.surfaceDecoration(
                context,
                borderRadius: radius,
              ).boxShadow
            : const [],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppGlassStyle.iconBlurSigma,
            sigmaY: AppGlassStyle.iconBlurSigma,
          ),
          child: field,
        ),
      ),
    );
  }

  Widget? _buildSuffix(BuildContext context) {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (widget.obscureText) {
      return AppGlassIconButton(
        icon: _obscure ? AppIcons.eye : AppIcons.eyeOff,
        tooltip: _obscure ? 'Show' : 'Hide',
        size: 38,
        iconSize: 18,
        onPressed: () {
          HapticFeedback.selectionClick();
          setState(() => _obscure = !_obscure);
        },
      );
    }

    if (widget.showClearButton && _hasText && widget.controller != null) {
      return AppGlassIconButton(
        icon: AppIcons.close,
        tooltip: 'Clear',
        size: 38,
        iconSize: 18,
        onPressed: () {
          HapticFeedback.selectionClick();
          widget.controller?.clear();
          widget.onChanged?.call('');
        },
      );
    }

    return null;
  }
}
