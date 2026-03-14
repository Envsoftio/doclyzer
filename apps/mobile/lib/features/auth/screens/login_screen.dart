import 'package:flutter/material.dart';

import '../auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onGoToSignup,
    required this.onGoToForgotPassword,
    this.initialEmail,
  });

  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback onGoToSignup;
  final VoidCallback onGoToForgotPassword;
  final String? initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;

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
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Enter email and password';
        _isLoading = false;
      });
      _showSnackBar('Enter email and password');
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
      });
      _showSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      const message =
          'Unable to sign in. Please check your connection and try again.';
      setState(() {
        _error = message;
        _isLoading = false;
      });
      _showSnackBar(message);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('login-email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              key: const Key('login-password'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
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
              key: const Key('login-submit'),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
            TextButton(
              key: const Key('go-to-signup'),
              onPressed: widget.onGoToSignup,
              child: const Text('Create account'),
            ),
            TextButton(
              key: const Key('go-to-forgot-password'),
              onPressed: widget.onGoToForgotPassword,
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}
