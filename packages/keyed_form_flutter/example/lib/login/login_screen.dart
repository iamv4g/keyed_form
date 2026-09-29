import 'package:flutter/material.dart';

import '../tour_builder/tour_builder_screen.dart';
import '../widgets/demo_scaffold.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Sign in',
      maxWidth: 380,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'keyed_form_flutter',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in, then build a tour.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          LoginForm(
            onSignedIn: (value) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TourBuilderScreen(email: value.email),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
