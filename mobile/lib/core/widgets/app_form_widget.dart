import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import 'app_button.dart';
import 'app_form_page.dart';

mixin AppFormMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  BuildContext get feedbackContext => scaffoldKey.currentContext ?? context;

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String formatTime(BuildContext context, TimeOfDay time) {
    return time.format(context);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }

  void showFormError(String message) {
    if (!mounted) return;

    final scheme = Theme.of(feedbackContext).colorScheme;

    ScaffoldMessenger.of(feedbackContext)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(AppIcons.error, color: scheme.onError, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: scheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          margin: const EdgeInsets.all(AppSpacing.md),
        ),
      );
  }

  Future<void> submitForm({
    required Future<void> Function() onSubmit,
    bool shouldPop = true,
  }) async {
    final valid = formKey.currentState?.validate() == true;

    if (!valid) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.lightImpact();

    final navigator = shouldPop ? Navigator.of(context) : null;

    await onSubmit();

    if (shouldPop && mounted) {
      navigator?.pop();
    }
  }

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
    bool scrollable = true,
  }) {
    final effectiveLabel = isEdit
        ? (editSubmitLabel ?? 'Save Changes')
        : submitLabel;

    final effectiveIcon = isEdit
        ? AppIcons.check
        : (submitIcon ?? AppIcons.add);

    return AppFormPage(
      scaffoldKey: scaffoldKey,
      title: title,
      subtitle: subtitle,
      actions: actions,
      scrollable: scrollable,
      bottomBar: _SubmitBar(
        label: effectiveLabel,
        icon: effectiveIcon,
        isSaving: isSaving,
        onPressed: () {
          submitForm(onSubmit: onSubmit, shouldPop: shouldPopOnSubmit);
        },
      ),
      child: Form(
        key: formKey,
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

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
    return AppButton.primary(
      label: isSaving ? 'Saving…' : label,
      icon: icon,
      isLoading: isSaving,
      fullWidth: true,
      onPressed: isSaving ? null : onPressed,
    );
  }
}

class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final int maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final Widget? suffixIcon;

  const AppTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.78),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.78),
            width: 1.25,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(
            color: scheme.error.withValues(alpha: 0.78),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: scheme.error, width: 1.25),
        ),
      ),
    );
  }
}

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

  static String? minLength(
    String? value,
    int min, [
    String fieldName = 'This field',
  ]) {
    final text = value?.trim() ?? '';

    if (text.isNotEmpty && text.length < min) {
      return '$fieldName must be at least $min characters';
    }

    return null;
  }

  static String? Function(String?) minLengthField(
    int min, [
    String fieldName = 'This field',
  ]) {
    return (value) => minLength(value, min, fieldName);
  }

  static String? rangeInt(
    String? value,
    int min,
    int max, [
    String fieldName = 'Value',
  ]) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) return null;

    final parsed = int.tryParse(text);

    if (parsed == null || parsed < min || parsed > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }

  static String? Function(String?) rangeIntField(
    int min,
    int max, [
    String fieldName = 'Value',
  ]) {
    return (value) => rangeInt(value, min, max, fieldName);
  }

  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }

      return null;
    };
  }
}
