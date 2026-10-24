import 'package:flutter/material.dart';

import '../../../core/feedback/status_messenger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';
import '../auth_repository.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onGoToSignup,
    required this.onGoToForgotPassword,
    this.initialEmail,
    required this.supportRepository,
  });

  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback onGoToSignup;
  final VoidCallback onGoToForgotPassword;
  final String? initialEmail;
  final SupportRepository supportRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  String? _error;
  SupportRequestContext? _supportContext;
  String? _supportErrorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) ||
        password.isEmpty) {
      setState(() {
        _error = 'Enter a valid email address and password';
        _isLoading = false;
      });
      return;
    }

    try {
      await widget.onLogin(email, password);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.auth,
        );
        _supportErrorMessage = error.message;
      });
      _showStatus(error.message);
    } catch (_) {
      if (!mounted) return;
      const message =
          'Unable to sign in. Please check your connection and try again.';
      setState(() {
        _error = message;
        _isLoading = false;
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.auth,
        );
        _supportErrorMessage = message;
      });
      _showStatus(message);
    }
  }

  void _showStatus(String message) {
    if (!mounted) return;
    StatusMessenger.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
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
                    'A clearer view\nstarts here.',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 31,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Sign in to access and understand your health reports.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    key: const Key('login-email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    key: const Key('login-password'),
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    child: _error == null
                        ? const SizedBox.shrink()
                        : Padding(
                            key: ValueKey(_error),
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              _error!,
                              key: const Key('login-error'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                  ),
                  if (_error != null) ...[
                    if (_supportContext != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      TextButton(
                        onPressed: () {
                          final supportContext = _supportContext;
                          if (supportContext == null) return;
                          showSupportRequestSheet(
                            context: context,
                            supportRepository: widget.supportRepository,
                            supportContext: supportContext,
                            errorMessage: _supportErrorMessage,
                          );
                        },
                        child: const Text('Need help?'),
                      ),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const Key('go-to-forgot-password'),
                      onPressed: widget.onGoToForgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    key: const Key('login-submit'),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        key: const Key('go-to-signup'),
                        onPressed: widget.onGoToSignup,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
