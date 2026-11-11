import '../auth_error_localization.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';

import '../auth_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final current = _currentPassword.text;
    final next = _newPassword.text;
    final confirmation = _confirmPassword.text;
    String? error;
    if (current.isEmpty) {
      error = context.l10n.uiEnterYourCurrentPassword;
    } else if (next.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(next) ||
        !RegExp(r'[a-z]').hasMatch(next) ||
        !RegExp(r'[0-9]').hasMatch(next) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(next)) {
      error = context.l10n.uiUseAtLeast8CharactersWithUppercase;
    } else if (next == current) {
      error = context.l10n.uiChooseADifferentPassword;
    } else if (next != confirmation) {
      error = context.l10n.uiNewPasswordsDoNotMatch;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.authRepository.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = localizedAuthError(context, error));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = context.l10n.uiUnableToChangePasswordPleaseTryAgain,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.uiChangePassword)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(context.l10n.uiEnterYourCurrentPasswordAndChooseA),
          const SizedBox(height: 20),
          TextField(
            key: const Key('change-password-current'),
            controller: _currentPassword,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.uiCurrentPassword,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('change-password-new'),
            controller: _newPassword,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.uiNewPasswordd850ee,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('change-password-confirm'),
            controller: _confirmPassword,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: context.l10n.uiConfirmNewPassword,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const Key('change-password-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('change-password-submit'),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.uiChangePassword),
          ),
        ],
      ),
    );
  }
}
