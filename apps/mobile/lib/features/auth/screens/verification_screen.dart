import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({
    super.key,
    required this.onContinueToLogin,
  });

  final VoidCallback onContinueToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Required')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your account was created successfully. Continue to login.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('verification-continue-login'),
              onPressed: onContinueToLogin,
              child: const Text('Continue to login'),
            ),
          ],
        ),
      ),
    );
  }
}
