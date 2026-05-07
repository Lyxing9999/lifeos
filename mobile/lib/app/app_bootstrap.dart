import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'app.dart';
import 'shell/bootstrap_error_view.dart';
import 'shell/bootstrap_loading_view.dart';
import 'shell/bootstrap_material_shell.dart';
import 'theme/theme_providers.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(authNotifierProvider.notifier).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final themeSettings = ref.watch(themeProvider);

    if (authState.isAuthenticated && authState.isReady) {
      return const LifeOsApp();
    }

    return BootstrapMaterialShell(
      themeSettings: themeSettings,
      child: _buildAuthShell(
        isLoading: authState.isLoading,
        isReady: authState.isReady,
        errorMessage: authState.errorMessage,
        isAuthenticated: authState.isAuthenticated,
      ),
    );
  }

  Widget _buildAuthShell({
    required bool isLoading,
    required bool isReady,
    required String? errorMessage,
    required bool isAuthenticated,
  }) {
    if (errorMessage != null && !isReady) {
      return BootstrapErrorView(
        message: errorMessage,
        onRetry: () {
          ref.read(authNotifierProvider.notifier).bootstrap();
        },
      );
    }

    if (isLoading || !isReady) {
      return const BootstrapLoadingView();
    }

    if (!isAuthenticated) {
      return const LoginPage();
    }

    return const BootstrapLoadingView();
  }
}
