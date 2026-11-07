import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';
import '../auth_repository.dart';
import '../../../shared/language_selector.dart';
import '../../../l10n/l10n.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.onSignup,
    required this.onGoToLogin,
    this.language = 'en',
    this.onLanguageChanged,
  });

  final Future<void> Function(
    String email,
    String password,
    String? referralCode,
  )
  onSignup;
  final VoidCallback onGoToLogin;
  final String language;
  final ValueChanged<String>? onLanguageChanged;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _referralFocus = FocusNode();
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    _passwordFocus.dispose();
    _referralFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final referralCode = _referralController.text.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ||
        password.isEmpty) {
      setState(() {
        _error = context.l10n.invalidCredentialsInput;
        _isLoading = false;
      });
      return;
    }

    try {
      await widget.onSignup(
        email,
        password,
        referralCode.isEmpty ? null : referralCode,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is Exception ? e.toString() : context.l10n.signupFailed;
        _isLoading = false;
      });
    }
  }

  Widget _labelledField(String label, Widget field) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
      const SizedBox(height: 8),
      Semantics(label: label, child: field),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onGoToLogin),
        title: const SizedBox.shrink(),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  const DoclyzerMark(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.signupTitle,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 31,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.signupIntro,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LanguageSelector(
                    value: widget.language,
                    onChanged: _isLoading ? null : widget.onLanguageChanged,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.languageHelp,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _labelledField(
                    context.l10n.emailAddress,
                    TextField(
                      key: const Key('signup-email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _labelledField(
                    context.l10n.password,
                    TextField(
                      key: const Key('signup-password'),
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _referralFocus.requestFocus(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _labelledField(
                    context.l10n.referralCode,
                    TextField(
                      key: const Key('signup-referral-code'),
                      controller: _referralController,
                      focusNode: _referralFocus,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.card_giftcard_rounded),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    key: const Key('signup-submit'),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(context.l10n.createAccount),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        context.l10n.alreadyAccount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onGoToLogin,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(context.l10n.signIn),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
