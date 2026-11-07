import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key, required this.onContinueToLogin});

  final VoidCallback onContinueToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onContinueToLogin),
        title: Text(context.l10n.verificationRequired),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.verificationRequired,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.accountCreatedLogin),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('verification-continue-login'),
              onPressed: onContinueToLogin,
              child: Text(context.l10n.continueLogin),
            ),
          ],
        ),
      ),
    );
  }
}
