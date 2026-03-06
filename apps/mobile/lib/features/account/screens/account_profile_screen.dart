import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api_client.dart';
import '../../../core/api_config.dart';
import '../account_repository.dart';
import '../restriction_repository.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({
    super.key,
    required this.accountRepository,
    required this.restrictionRepository,
    required this.onBack,
  });

  final AccountRepository accountRepository;
  final RestrictionRepository restrictionRepository;
  final VoidCallback onBack;

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  AccountProfile? _profile;
  RestrictionStatus? _restrictionStatus;
  String? _error;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRestrictionStatus();
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
      if (mounted) {
        setState(() {
          _profile = profile;
          _emailController.text = profile.email;
          _displayNameController.text = profile.displayName ?? '';
          _loading = false;
        });
      }
    } on AccountException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadRestrictionStatus() async {
    final status = await widget.restrictionRepository.getStatus();
    if (mounted) {
      setState(() {
        _restrictionStatus = status;
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
      if (mounted) {
        setState(() {
          _profile = updated;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AccountException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _saving = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _saving = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final updated = await widget.accountRepository.uploadAvatar(picked.path);
      if (mounted) {
        setState(() {
          _profile = updated;
          _uploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on AccountException catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildAvatar() {
    final avatarUrl = _profile?.avatarUrl;
    final fullUrl = avatarUrl != null
        ? (avatarUrl.startsWith('http') ? avatarUrl : '$apiBaseUrl$avatarUrl')
        : null;

    return GestureDetector(
      key: const Key('account-profile-avatar'),
      onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                fullUrl != null ? NetworkImage(fullUrl) : null,
            child: fullUrl == null
                ? const Icon(Icons.person, size: 48, color: Colors.grey)
                : null,
          ),
          if (_uploadingAvatar)
            const Positioned.fill(
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.edit, size: 14, color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRestricted = _restrictionStatus?.isRestricted ?? false;

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
                  if (isRestricted) ...[
                    Container(
                      key: const Key('account-restriction-banner'),
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Restricted',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                            semanticsLabel: 'Account Restricted',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            key: const Key('account-restriction-rationale'),
                            _restrictionStatus?.rationale ?? '',
                            semanticsLabel: _restrictionStatus?.rationale,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            key: const Key('account-restriction-next-steps'),
                            _restrictionStatus?.nextSteps ?? '',
                            semanticsLabel: _restrictionStatus?.nextSteps,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Center(child: _buildAvatar()),
                  const SizedBox(height: 24),
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
                    decoration:
                        const InputDecoration(labelText: 'Display Name'),
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
