import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onLogout,
    required this.onGoToAccount,
    required this.onGoToProfiles,
  });

  final Future<void> Function() onLogout;
  final VoidCallback onGoToAccount;
  final VoidCallback onGoToProfiles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doclyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Doclyzer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('go-to-account'),
              onPressed: onGoToAccount,
              child: const Text('Account'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('go-to-profiles'),
              onPressed: onGoToProfiles,
              child: const Text('Profiles'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('logout-submit'),
              onPressed: () async {
                await onLogout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
