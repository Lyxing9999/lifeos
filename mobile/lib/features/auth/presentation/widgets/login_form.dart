import 'package:flutter/material.dart';

import 'google_sign_in_button.dart';

class LoginForm extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onGooglePressed;

  const LoginForm({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GoogleSignInButton(isLoading: isLoading, onPressed: onGooglePressed),
        if (errorMessage != null && errorMessage!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
