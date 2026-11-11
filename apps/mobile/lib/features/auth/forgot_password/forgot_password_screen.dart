import '../auth_error_localization.dart';
import 'package:mobile/l10n/l10n.dart';
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
        _error = context.l10n.uiEnterYourEmailAddress;
      });
      return;
    }

    try {
      await widget.onSubmit(email);
      widget.onResetSent();
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = localizedAuthError(context, error);
      });
    } catch (_) {
      setState(() {
        _error = context.l10n.uiUnableToSendResetLinkPleaseTry;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onGoToLogin),
        title: Text(context.l10n.forgotPassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.uiEnterTheEmailAddressAssociatedWithYour,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('forgot-password-email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: context.l10n.email),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('forgot-password-submit'),
              onPressed: _submit,
              child: Text(context.l10n.uiSendResetLink),
            ),
            TextButton(
              key: const Key('forgot-password-back-to-login'),
              onPressed: widget.onGoToLogin,
              child: Text(context.l10n.uiBackToLogin),
            ),
          ],
        ),
      ),
    );
  }
}
