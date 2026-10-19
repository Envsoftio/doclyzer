import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api_client.dart';
import '../../../core/api_config.dart';
import '../../../core/feedback/status_messenger.dart';
import '../account_repository.dart';
import '../account_avatar.dart';
import '../../billing/billing_repository.dart';
import '../restriction_repository.dart';

class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({
    super.key,
    required this.accountRepository,
    required this.restrictionRepository,
    required this.onBack,
    this.showBackButton = true,
    this.editProfile = false,
    this.themeMode = ThemeMode.system,
    this.onThemeChanged,
    this.billingRepository,
    this.onGoToBilling,
    this.onGoToReferrals,
    this.onGoToSessions,
    this.onGoToNotifications,
    this.onGoToDataRights,
    this.onLogout,
  });

  final AccountRepository accountRepository;
  final RestrictionRepository restrictionRepository;
  final VoidCallback onBack;
  final bool showBackButton;
  final bool editProfile;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeChanged;
  final BillingRepository? billingRepository;
  final VoidCallback? onGoToBilling;
  final VoidCallback? onGoToReferrals;
  final VoidCallback? onGoToSessions;
  final VoidCallback? onGoToNotifications;
  final VoidCallback? onGoToDataRights;
  final VoidCallback? onLogout;

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
  Future<EntitlementSummary>? _entitlement;
  bool _uploadingAvatar = false;

  String _friendlyErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.code == 'NETWORK_ERROR') {
        return 'Cannot connect to server. Please check your internet or API server.';
      }
      return error.message.isNotEmpty
          ? error.message
          : 'Something went wrong. Please try again.';
    }
    if (error is AccountException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }

  bool _isActionBlocked(String action) {
    final status = _restrictionStatus;
    if (status == null || !status.isRestricted) {
      return false;
    }
    final configuredActions = status.restrictedActions;
    if (configuredActions == null || configuredActions.isEmpty) {
      return true;
    }
    return configuredActions.contains(action);
  }

  void _showBlockedMessage() {
    final nextSteps = _restrictionStatus?.nextSteps?.trim();
    final rationale = _restrictionStatus?.rationale?.trim();
    final message = (nextSteps != null && nextSteps.isNotEmpty)
        ? nextSteps
        : ((rationale != null && rationale.isNotEmpty)
              ? rationale
              : 'Profile updates are temporarily unavailable while your account is under review.');
    StatusMessenger.showWarning(context, message);
  }

  @override
  void initState() {
    super.initState();
    _entitlement = widget.billingRepository?.getEntitlementSummary();
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
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyErrorMessage(e);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyErrorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadRestrictionStatus() async {
    try {
      final status = await widget.restrictionRepository.getStatus();
      if (mounted) {
        setState(() {
          _restrictionStatus = status;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        StatusMessenger.showWarning(context, _friendlyErrorMessage(e));
      }
    } catch (e) {
      if (mounted) {
        StatusMessenger.showWarning(context, _friendlyErrorMessage(e));
      }
    }
  }

  Future<void> _save() async {
    if (_isActionBlocked('update_account_profile')) {
      _showBlockedMessage();
      return;
    }
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
        StatusMessenger.showSuccess(context, 'Profile updated');
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
    if (_uploadingAvatar) return;
    if (_isActionBlocked('update_account_profile')) {
      _showBlockedMessage();
      return;
    }
    setState(() => _uploadingAvatar = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final updated = await widget.accountRepository.uploadAvatar(picked.path);
      // Stable storage keys can produce the same signed URL within a second.
      // Evict cached bytes so replacement photos become visible immediately.
      if (updated.avatarUrl != null) {
        await NetworkImage(_avatarUrl(updated.avatarUrl!)).evict();
      }
      if (!mounted) return;
      setState(() => _profile = updated);
      StatusMessenger.showSuccess(context, 'Profile photo updated');
    } catch (error) {
      if (mounted) {
        StatusMessenger.showError(
          context,
          error is ApiException || error is AccountException
              ? _friendlyErrorMessage(error)
              : 'Could not update your photo. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  String _avatarUrl(String url) =>
      url.startsWith('http') ? url : '$apiBaseUrl$url';

  Future<void> _openProfileEditor() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => AccountProfileScreen(
          accountRepository: widget.accountRepository,
          restrictionRepository: widget.restrictionRepository,
          editProfile: true,
          onBack: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
    if (mounted) await _loadProfile();
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        key: const Key('account-edit-profile'),
        borderRadius: BorderRadius.circular(16),
        onTap: _openProfileEditor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AccountAvatar(profile: _profile, radius: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.displayName?.trim().isNotEmpty == true
                          ? _profile!.displayName!
                          : 'Your account',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile?.email ??
                          (_loading
                              ? 'Loading profile…'
                              : 'Tap to load your profile'),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edit profile',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      key: const Key('account-profile-avatar'),
      onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AccountAvatar(profile: _profile, radius: 48),
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

  Widget _buildSettings() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Column(
            children: [
              if (widget.onGoToBilling != null)
                FutureBuilder<EntitlementSummary>(
                  future: _entitlement,
                  builder: (context, snapshot) {
                    final summary = snapshot.data;
                    return ListTile(
                      key: const Key('account-credits'),
                      leading: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Plan & credits'),
                      subtitle: Text(
                        summary != null
                            ? '${summary.planName} · ${summary.creditBalance.toStringAsFixed(summary.creditBalance % 1 == 0 ? 0 : 1)} credits'
                            : snapshot.hasError
                            ? 'View your plan and balance'
                            : 'Loading balance…',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: widget.onGoToBilling,
                    );
                  },
                ),
              if (widget.onGoToReferrals != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  key: const Key('account-referrals'),
                  leading: Icon(
                    Icons.card_giftcard_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Refer friends'),
                  subtitle: const Text('Invites and referral rewards'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: widget.onGoToReferrals,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Appearance', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose how Doclyzer looks',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final choice in [
                      (
                        ThemeMode.system,
                        'System',
                        Icons.brightness_auto_outlined,
                      ),
                      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
                      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                    ])
                      ChoiceChip(
                        key: Key('appearance-${choice.$1.name}'),
                        showCheckmark: false,
                        avatar: Icon(choice.$3, size: 18),
                        label: Text(choice.$2),
                        selected: widget.themeMode == choice.$1,
                        onSelected: widget.onThemeChanged == null
                            ? null
                            : (_) => widget.onThemeChanged!(choice.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'System follows your device settings.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Settings', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (final item in [
                (
                  Icons.devices_outlined,
                  'Active sessions',
                  widget.onGoToSessions,
                ),
                (
                  Icons.notifications_outlined,
                  'Notifications',
                  widget.onGoToNotifications,
                ),
                (
                  Icons.shield_outlined,
                  'Privacy & data',
                  widget.onGoToDataRights,
                ),
              ])
                if (item.$3 != null)
                  ListTile(
                    leading: Icon(item.$1),
                    title: Text(item.$2),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: item.$3,
                  ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRestricted = _restrictionStatus?.isRestricted ?? false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.editProfile ? 'Edit profile' : 'Account'),
        leading: widget.showBackButton
            ? BackButton(onPressed: widget.onBack)
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!widget.editProfile) ...[
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSettings(),
            if (widget.onLogout != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ],
          if (widget.editProfile)
            _loading
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
                                key: const Key(
                                  'account-restriction-next-steps',
                                ),
                                _restrictionStatus?.nextSteps ?? '',
                                semanticsLabel: _restrictionStatus?.nextSteps,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Center(child: _buildAvatar()),
                      TextButton.icon(
                        onPressed: _uploadingAvatar
                            ? null
                            : _pickAndUploadAvatar,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _uploadingAvatar
                              ? 'Uploading photo…'
                              : 'Change photo',
                        ),
                      ),
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
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('account-profile-display-name'),
                        controller: _displayNameController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                        ),
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
        ],
      ),
    );
  }
}
