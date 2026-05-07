import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_icons.dart';
import '../../application/auth_providers.dart';
import 'login_page.dart';

class SplashAuthGate extends ConsumerStatefulWidget {
  final WidgetBuilder authenticatedBuilder;

  const SplashAuthGate({super.key, required this.authenticatedBuilder});

  @override
  ConsumerState<SplashAuthGate> createState() => _SplashAuthGateState();
}

class _SplashAuthGateState extends ConsumerState<SplashAuthGate> {
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bootstrapped) return;
    _bootstrapped = true;

    Future.microtask(() {
      ref.read(authNotifierProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    if (!auth.isReady || auth.isLoading) {
      return const _SplashLoadingPage();
    }

    if (auth.isAuthenticated) {
      return widget.authenticatedBuilder(context);
    }

    return LoginPage(
      onAuthenticated: () {
        // The gate will rebuild from provider state.
      },
    );
  }
}

class _SplashLoadingPage extends StatelessWidget {
  const _SplashLoadingPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  AppIcons.success,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 34,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Preparing LifeOS...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
