import 'package:flutter/material.dart';

import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  final VoidCallback? onAuthenticated;

  const RegisterPage({
    super.key,
    this.onAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      onAuthenticated: onAuthenticated,
    );
  }
}