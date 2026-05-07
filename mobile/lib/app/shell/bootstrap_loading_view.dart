import 'package:flutter/material.dart';

import '../../core/widgets/app_logo.dart';
import '../theme/app_colors.dart';
import 'bootstrap_background.dart';
import 'bootstrap_glass_card.dart';

class BootstrapLoadingView extends StatelessWidget {
  const BootstrapLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BootstrapBackground(
        child: Center(
          child: BootstrapGlassCard(child: _BootstrapLoadingContent()),
        ),
      ),
    );
  }
}

class _BootstrapLoadingContent extends StatelessWidget {
  const _BootstrapLoadingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogo(size: 58, color: AppColors.blue),
        const SizedBox(height: 16),
        const Text(
          'LifeOS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
            color: AppColors.blue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Design your day with clarity.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.25,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 30),
        const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ],
    );
  }
}
