import '../auth_error_localization.dart';
import 'package:mobile/l10n/l10n.dart';
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
        _error = context.l10n.uiEnterTheResetTokenFromYourEmail;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _error = context.l10n.uiEnterYourNewPassword;
      });
      return;
    }

    try {
      await widget.onReset(token, password);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = localizedAuthError(context, error);
      });
    } catch (_) {
      setState(() {
        _error = context.l10n.uiUnableToResetPasswordPleaseRequestA;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onGoToLogin),
        title: Text(context.l10n.uiSetNewPassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.uiEnterTheResetTokenFromTheLink,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('reset-password-token'),
              controller: _tokenController,
              decoration: InputDecoration(labelText: context.l10n.uiResetToken),
            ),
            TextField(
              key: const Key('reset-password-new-password'),
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.l10n.uiNewPassword,
              ),
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
              child: Text(context.l10n.uiResetPassword),
            ),
            TextButton(
              key: const Key('reset-password-back-to-login'),
              onPressed: widget.onGoToLogin,
              child: Text(context.l10n.uiBackToLogin),
            ),
          ],
        ),
      ),
    );
  }
}
