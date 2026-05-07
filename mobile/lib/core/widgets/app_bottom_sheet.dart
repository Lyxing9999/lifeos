import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_glass_style.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    String? subtitle,
    List<Widget>? actions,
    bool showHandle = true,
    bool showCloseButton = true,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    bool enableDrag = true,
    bool isDismissible = true,
    EdgeInsetsGeometry? padding,
  }) {
    HapticFeedback.selectionClick();

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (context) {
        return AppBottomSheetShell(
          title: title,
          subtitle: subtitle,
          actions: actions,
          showHandle: showHandle,
          showCloseButton: showCloseButton,
          padding: padding,
          child: child,
        );
      },
    );
  }

  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<AppBottomSheetAction<T>> actions,
    bool showCancel = true,
  }) {
    return show<T>(
      context: context,
      title: title,
      subtitle: subtitle,
      showCloseButton: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions) ...[
            AppBottomSheetActionTile<T>(action: action),
            if (action != actions.last) const SizedBox(height: AppSpacing.sm),
          ],
          if (showCancel) ...[
            const SizedBox(height: AppSpacing.md),
            AppBottomSheetActionTile<T>(
              action: AppBottomSheetAction<T>(
                label: 'Cancel',
                icon: AppIcons.close,
                value: null,
                role: AppBottomSheetActionRole.cancel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppBottomSheetShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showHandle;
  final bool showCloseButton;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheetShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.showHandle = true,
    this.showCloseButton = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md + bottomInset,
        ),
        child: _GlassSheetContainer(
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHandle) ...[
                    const Center(child: _BottomSheetHandle()),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (_hasHeader) ...[
                    _BottomSheetHeader(
                      title: title,
                      subtitle: subtitle,
                      actions: actions,
                      showCloseButton: showCloseButton,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Flexible(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasHeader {
    return (title ?? '').trim().isNotEmpty ||
        (subtitle ?? '').trim().isNotEmpty ||
        (actions ?? const []).isNotEmpty ||
        showCloseButton;
  }
}

class _GlassSheetContainer extends StatelessWidget {
  final Widget child;

  const _GlassSheetContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppGlassStyle.cardBlurSigma + 4,
          sigmaY: AppGlassStyle.cardBlurSigma + 4,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: AppGlassStyle.surfaceDecoration(
            context,
            borderRadius: BorderRadius.circular(28),
            lightSurfaceAlpha: 0.90,
            darkSurfaceAlpha: 0.72,
            lightBorderAlpha: 0.44,
            darkBorderAlpha: 0.34,
            lightShadowAlpha: 0.14,
            darkShadowAlpha: 0.26,
            shadowBlurRadius: 30,
            shadowOffset: const Offset(0, 14),
            accentColor: Theme.of(context).colorScheme.primary,
            lightAccentShadowAlpha: 0.07,
            darkAccentShadowAlpha: 0.04,
            accentShadowBlurRadius: 18,
            accentShadowOffsetY: 4,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showCloseButton;

  const _BottomSheetHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.showCloseButton,
  });

  @override
  Widget build(BuildContext context) {
    final hasText =
        (title ?? '').trim().isNotEmpty || (subtitle ?? '').trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasText)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((title ?? '').trim().isNotEmpty)
                  Text(
                    title!.trim(),
                    style: AppTextStyles.pageTitle(
                      context,
                    ).copyWith(letterSpacing: -0.45),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if ((subtitle ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!.trim(),
                    style: AppTextStyles.bodySecondary(
                      context,
                    ).copyWith(height: 1.28),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          )
        else
          const Spacer(),
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.sm),
          Row(mainAxisSize: MainAxisSize.min, children: actions!),
        ],
        if (showCloseButton) ...[
          const SizedBox(width: AppSpacing.xs),
          _BottomSheetCloseButton(
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ],
    );
  }
}

class _BottomSheetCloseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BottomSheetCloseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Close',
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.full),
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.04),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              AppIcons.close,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

enum AppBottomSheetActionRole { normal, primary, destructive, cancel }

class AppBottomSheetAction<T> {
  final String label;
  final String? subtitle;
  final IconData icon;
  final T? value;
  final AppBottomSheetActionRole role;
  final VoidCallback? onTap;

  const AppBottomSheetAction({
    required this.label,
    required this.icon,
    this.subtitle,
    this.value,
    this.role = AppBottomSheetActionRole.normal,
    this.onTap,
  });
}

class AppBottomSheetActionTile<T> extends StatelessWidget {
  final AppBottomSheetAction<T> action;

  const AppBottomSheetActionTile({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _accentColor(context);
    final isDestructive = action.role == AppBottomSheetActionRole.destructive;
    final isPrimary = action.role == AppBottomSheetActionRole.primary;

    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: isPrimary
            ? accent.withValues(alpha: 0.11)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.cardLg),
          onTap: () {
            HapticFeedback.selectionClick();

            action.onTap?.call();

            if (action.role == AppBottomSheetActionRole.cancel) {
              Navigator.of(context).maybePop();
              return;
            }

            Navigator.of(context).pop<T>(action.value);
          },
          splashColor: accent.withValues(alpha: 0.08),
          highlightColor: accent.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.cardLg),
              border: Border.all(
                color: isPrimary
                    ? accent.withValues(alpha: 0.22)
                    : scheme.outlineVariant.withValues(alpha: 0.36),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(
                      alpha: isDestructive ? 0.10 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.icon),
                  ),
                  child: Icon(action.icon, size: 20, color: accent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.label,
                        style: AppTextStyles.cardTitle(context).copyWith(
                          color: isDestructive ? accent : scheme.onSurface,
                          letterSpacing: -0.12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((action.subtitle ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          action.subtitle!.trim(),
                          style: AppTextStyles.bodySecondary(
                            context,
                          ).copyWith(height: 1.24),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  AppIcons.chevronRight,
                  size: 18,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.68),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (action.role) {
      case AppBottomSheetActionRole.primary:
        return scheme.primary;
      case AppBottomSheetActionRole.destructive:
        return scheme.error;
      case AppBottomSheetActionRole.cancel:
        return scheme.onSurfaceVariant;
      case AppBottomSheetActionRole.normal:
        return scheme.primary;
    }
  }
}
