import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_spacing.dart';
import 'app_form_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppFormWidget — The single senior-level pattern for all LifeOS forms.
//
// Principles:
//   • One Form key + GlobalKey<FormState> for validate-on-submit
//   • Inline validation via FormField / TextFormField
//   • Unified submit button with loading, disabled, haptic
//   • Pre-captured Navigator for safe async pop
//   • Keyboard-aware: auto-focus first field, textInputAction chaining
//   • Consistent error display: inline under field + optional SnackBar
//   • Date formatting via intl/DateFormat (no manual padLeft)
//   • Progressive disclosure for secondary fields
//   • Haptic feedback on all interactions
// ─────────────────────────────────────────────────────────────────────────────

/// Base mixin for all LifeOS form pages.
///
/// Usage:
/// ```dart
/// class _MyFormState extends State<MyForm> with AppFormMixin {
///   @override
///   Widget build(BuildContext context) {
///     return buildFormPage(
///       title: 'New Task',
///       subtitle: 'What do you need to get done?',
///       submitLabel: 'Create Task',
///       isSaving: widget.isSaving,
///       onSubmit: _submit,
///       children: [ ... ],
///     );
///   }
/// }
/// ```
mixin AppFormMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Format a date using intl — locale-aware, no manual padLeft.
  String formatDate(DateTime date) => DateFormat.yMMMd().format(date);

  /// Format a time using the current context.
  String formatTime(BuildContext context, TimeOfDay time) =>
      time.format(context);

  /// Format date+time using intl.
  String formatDateTime(DateTime dateTime) =>
      DateFormat.yMMMd().add_jm().format(dateTime.toLocal());

  /// Show a themed error SnackBar (for validation errors that don't map to a
  /// single field, e.g. "End time must be after start time").
  void showFormError(String message) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: cs.onError, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );
  }

  /// Validates the form, fires [onSubmit] if valid, then pops if still mounted.
  /// Handles all the safety: haptic, Navigator pre-capture, mounted check.
  Future<void> submitForm({
    required Future<void> Function() onSubmit,
    bool shouldPop = true,
  }) async {
    if (formKey.currentState?.validate() != true) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    // Capture Navigator before the async gap to avoid use-after-dispose.
    final navigator = shouldPop ? Navigator.of(context) : null;

    await onSubmit();

    if (shouldPop && mounted) navigator?.pop();
  }

  // ── Page builder ─────────────────────────────────────────────────────────

  /// Builds the standard form page scaffold.
  ///
  /// [children] are the form body widgets (AppFormSection, TextFormField, etc.)
  /// wrapped automatically in a [Form] with the shared [formKey].
  Widget buildFormPage({
    required String title,
    String? subtitle,
    required String submitLabel,
    String? editSubmitLabel,
    IconData? submitIcon,
    required bool isSaving,
    required Future<void> Function() onSubmit,
    required List<Widget> children,
    bool isEdit = false,
    List<Widget>? actions,
    bool shouldPopOnSubmit = true,
  }) {
    final effectiveLabel = isEdit
        ? (editSubmitLabel ?? 'Save Changes')
        : submitLabel;
    final effectiveIcon = isEdit
        ? Icons.check_rounded
        : (submitIcon ?? Icons.add_rounded);

    return AppFormPage(
      title: title,
      subtitle: subtitle,
      actions: actions,
      bottomBar: _SubmitBar(
        label: effectiveLabel,
        icon: effectiveIcon,
        isSaving: isSaving,
        onPressed: () => submitForm(
          onSubmit: onSubmit,
          shouldPop: shouldPopOnSubmit,
        ),
      ),
      child: Form(
        key: formKey,
        child: FocusTraversalGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unified submit bar
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSaving;
  final VoidCallback onPressed;

  const _SubmitBar({
    required this.label,
    required this.icon,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(isSaving ? 'Saving…' : label),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextFormField — Themed TextFormField with consistent decoration
// ─────────────────────────────────────────────────────────────────────────────

class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool readOnly;
  final bool autofocus;

  const AppTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Common validators
// ─────────────────────────────────────────────────────────────────────────────

class FormValidators {
  FormValidators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? Function(String?) requiredField(String fieldName) {
    return (value) => required(value, fieldName);
  }

  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value != null && value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? rangeInt(String? value, int min, int max, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null || parsed < min || parsed > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  /// Compose multiple validators — returns the first error or null.
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
