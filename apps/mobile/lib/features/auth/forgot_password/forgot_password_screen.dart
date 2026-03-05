import 'package:flutter/material.dart';

import '../auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.onSubmit,
    required this.onGoToLogin,
    required this.onResetSent,
  });

  final Future<void> Function(String email) onSubmit;
  final VoidCallback onGoToLogin;
  final VoidCallback onResetSent;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _error;
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _error = 'Enter your email address';
      });
      return;
    }

    try {
      await widget.onSubmit(email);
      setState(() {
        _submitted = true;
      });
      widget.onResetSent();
    } on AuthException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Unable to send reset link. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the email address associated with your account and we\'ll send you a link to reset your password.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('forgot-password-email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('forgot-password-submit'),
              onPressed: _submit,
              child: const Text('Send Reset Link'),
            ),
            TextButton(
              key: const Key('forgot-password-back-to-login'),
              onPressed: widget.onGoToLogin,
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
