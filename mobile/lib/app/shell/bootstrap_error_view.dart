import 'package:flutter/material.dart';

import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_button.dart';
import '../theme/app_colors.dart';
import 'bootstrap_background.dart';
import 'bootstrap_glass_card.dart';

class BootstrapErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const BootstrapErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BootstrapBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BootstrapGlassCard(
              child: _BootstrapErrorContent(message: message, onRetry: onRetry),
            ),
          ),
        ),
      ),
    );
  }
}

class _BootstrapErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BootstrapErrorContent({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 52, color: AppColors.blue),
        const SizedBox(height: 20),
        Text(
          'Could not start LifeOS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: scheme.onSurfaceVariant, height: 1.35),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: AppButton.primary(
            label: 'Try again',
            onPressed: onRetry,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}
