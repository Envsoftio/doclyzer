import 'package:flutter/material.dart';

import '../account_repository.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({
    super.key,
    required this.accountRepository,
    required this.onBack,
  });

  final AccountRepository accountRepository;
  final VoidCallback onBack;

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  AccountProfile? _profile;
  String? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await widget.accountRepository.getProfile();
      setState(() {
        _profile = profile;
        _emailController.text = profile.email;
        _displayNameController.text = profile.displayName ?? '';
        _loading = false;
      });
    } on AccountException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await widget.accountRepository.updateProfile(
        displayName: _displayNameController.text.trim(),
      );
      setState(() {
        _profile = updated;
        _saving = false;
      });
    } on AccountException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Text(
                      _error!,
                      key: const Key('account-profile-error'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  TextField(
                    key: const Key('account-profile-email'),
                    readOnly: true,
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('account-profile-display-name'),
                    controller: _displayNameController,
                    decoration: const InputDecoration(labelText: 'Display Name'),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('account-profile-save'),
                    onPressed: _saving ? null : _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
      ),
    );
  }
}
