import 'package:flutter/material.dart';

import '../auth_repository.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.onReset,
    required this.onGoToLogin,
  });

  final Future<void> Function(String token, String newPassword) onReset;
  final VoidCallback onGoToLogin;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
    });

    final token = _tokenController.text.trim();
    final password = _passwordController.text;

    if (token.isEmpty) {
      setState(() {
        _error = 'Enter the reset token from your email link';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _error = 'Enter your new password';
      });
      return;
    }

    try {
      await widget.onReset(token, password);
    } on AuthException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to reset password. Please request a new link.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the reset token from the link in your email and your new password.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('reset-password-token'),
              controller: _tokenController,
              decoration: const InputDecoration(labelText: 'Reset Token'),
            ),
            TextField(
              key: const Key('reset-password-new-password'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  key: const Key('reset-password-error'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('reset-password-submit'),
              onPressed: _submit,
              child: const Text('Reset Password'),
            ),
            TextButton(
              key: const Key('reset-password-back-to-login'),
              onPressed: widget.onGoToLogin,
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
