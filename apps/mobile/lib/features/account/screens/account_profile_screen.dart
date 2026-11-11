import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/language_selector.dart';
import '../../../l10n/l10n.dart';
import '../../../core/localized_error.dart';

import '../../../core/api_client.dart';
import '../../../core/api_config.dart';
import '../../../core/feedback/status_messenger.dart';
import '../account_repository.dart';
import '../account_avatar.dart';
import '../../billing/billing_repository.dart';
import '../restriction_repository.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

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
    this.onGoToProfiles,
    this.onGoToReferrals,
    this.onGoToSessions,
    this.onGoToNotifications,
    this.onGoToDataRights,
    this.onGoToPrivacy,
    this.onGoToExport,
    this.onGoToHelp,
    this.onGoToAbout,
    this.onGoToSharedLinks,
    this.supportRepository,
    this.onLogout,
    this.language = 'en',
    this.onLanguageChanged,
    this.isSavingLanguage = false,
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
  final VoidCallback? onGoToProfiles;
  final VoidCallback? onGoToReferrals;
  final VoidCallback? onGoToSessions;
  final VoidCallback? onGoToNotifications;
  final VoidCallback? onGoToDataRights;
  final VoidCallback? onGoToPrivacy;
  final VoidCallback? onGoToExport;
  final VoidCallback? onGoToHelp;
  final VoidCallback? onGoToAbout;
  final VoidCallback? onGoToSharedLinks;
  final SupportRepository? supportRepository;
  final VoidCallback? onLogout;
  final String language;
  final Future<void> Function(String)? onLanguageChanged;
  final bool isSavingLanguage;

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
      return localizedError(context, error);
    }
    if (error is AccountException) {
      return context.l10n.genericError;
    }
    return context.l10n.genericError;
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
              : context
                    .l10n
                    .uiProfileUpdatesAreTemporarilyUnavailableWhileYour);
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
          _error = _friendlyErrorMessage(e);
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
        StatusMessenger.showSuccess(context, context.l10n.profileUpdated);
      }
    } on AccountException catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyErrorMessage(e);
          _saving = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = _friendlyErrorMessage(e);
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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                context.l10n.changePhoto,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            ListTile(
              key: const Key('profile-photo-gallery'),
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.gallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            ListTile(
              key: const Key('profile-photo-camera'),
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(context.l10n.camera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    setState(() => _uploadingAvatar = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final updated = await widget.accountRepository.uploadAvatar(picked.path);
      // Stable storage keys can produce the same signed URL within a second.
      // Evict cached bytes so replacement photos become visible immediately.
      final avatarUrl = updated.avatarUrl?.trim();
      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          !avatarUrl.startsWith('data:')) {
        await NetworkImage(_avatarUrl(avatarUrl)).evict();
      }
      if (!mounted) return;
      setState(() => _profile = updated);
      StatusMessenger.showSuccess(context, context.l10n.photoUpdated);
    } catch (error) {
      if (mounted) {
        StatusMessenger.showError(
          context,
          error is ApiException || error is AccountException
              ? _friendlyErrorMessage(error)
              : context.l10n.photoFailed,
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
                          : context.l10n.yourAccount,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile?.email ??
                          (_loading
                              ? context.l10n.profileLoading
                              : context.l10n.profileLoadAction),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
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

  Widget _settingsTile({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    String? subtitle,
  }) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      key: key,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: colors.primary),
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSettings() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.accountData,
          style: theme.textTheme.labelSmall?.copyWith(
            letterSpacing: 1.2,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _settingsTile(
          icon: Icons.person_outline_rounded,
          label: context.l10n.personalInformation,
          onTap: _openProfileEditor,
        ),
        LanguageSelector(
          value: widget.language,
          settings: true,
          saving: widget.isSavingLanguage,
          onChanged: widget.onLanguageChanged == null
              ? null
              : (language) async {
                  try {
                    await widget.onLanguageChanged!(language);
                  } catch (_) {
                    if (mounted) {
                      StatusMessenger.showError(
                        context,
                        context.l10n.languageSaveFailed,
                      );
                    }
                  }
                },
        ),

        _settingsTile(
          icon: Icons.notifications_none_rounded,
          label: context.l10n.notificationPreferences,
          onTap: widget.onGoToNotifications,
        ),
        _settingsTile(
          icon: Icons.shield_outlined,
          label: context.l10n.privacySecurity,
          onTap: widget.onGoToPrivacy ?? widget.onGoToDataRights,
        ),
        _settingsTile(
          icon: Icons.link_outlined,
          label: context.l10n.sharedLinks,
          onTap: widget.onGoToSharedLinks,
        ),
        _settingsTile(
          icon: Icons.download_outlined,
          label: context.l10n.exportData,
          onTap: widget.onGoToExport ?? widget.onGoToDataRights,
        ),
        if (widget.onGoToProfiles != null ||
            widget.onGoToBilling != null ||
            widget.onGoToReferrals != null ||
            widget.onGoToSessions != null ||
            widget.onThemeChanged != null) ...[
          const SizedBox(height: 28),
          Container(
            key: const Key('additional-account-information'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.manage_accounts_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.additionalAccount,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.additionalAccountHelp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (widget.onGoToProfiles != null)
            _settingsTile(
              key: const Key('account-family-profiles'),
              icon: Icons.people_outline,
              label: context.l10n.familyProfiles,
              subtitle: context.l10n.manageProfiles,
              onTap: widget.onGoToProfiles,
            ),
          if (widget.onGoToBilling != null)
            FutureBuilder<EntitlementSummary>(
              future: _entitlement,
              builder: (context, snapshot) {
                final summary = snapshot.data;
                return _settingsTile(
                  key: const Key('account-credits'),
                  icon: Icons.account_balance_wallet_outlined,
                  label: context.l10n.planCredits,
                  subtitle: summary != null
                      ? '${summary.planName} · ${summary.creditBalance.toStringAsFixed(summary.creditBalance % 1 == 0 ? 0 : 1)} credits'
                      : snapshot.hasError
                      ? context.l10n.viewPlanBalance
                      : context.l10n.balanceLoading,
                  onTap: widget.onGoToBilling,
                );
              },
            ),
          if (widget.onGoToReferrals != null)
            _settingsTile(
              key: const Key('account-referrals'),
              icon: Icons.card_giftcard_outlined,
              label: context.l10n.referFriends,
              subtitle: context.l10n.referralRewards,
              onTap: widget.onGoToReferrals,
            ),
          if (widget.onGoToSessions != null)
            _settingsTile(
              icon: Icons.devices_outlined,
              label: context.l10n.activeSessions,
              onTap: widget.onGoToSessions,
            ),
          if (widget.onThemeChanged != null) ...[
            const SizedBox(height: 16),
            Text(context.l10n.appearance, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final choice in [
                  (
                    ThemeMode.system,
                    context.l10n.system,
                    Icons.brightness_auto_outlined,
                  ),
                  (
                    ThemeMode.light,
                    context.l10n.light,
                    Icons.light_mode_outlined,
                  ),
                  (ThemeMode.dark, context.l10n.dark, Icons.dark_mode_outlined),
                ])
                  ChoiceChip(
                    key: Key('appearance-${choice.$1.name}'),
                    showCheckmark: false,
                    avatar: Icon(choice.$3, size: 18),
                    label: Text(choice.$2),
                    selected: widget.themeMode == choice.$1,
                    onSelected: (_) => widget.onThemeChanged!(choice.$1),
                  ),
              ],
            ),
          ],
        ],
        const Divider(height: 32),
        _settingsTile(
          icon: Icons.help_outline_rounded,
          label: context.l10n.helpSupport,
          onTap:
              widget.onGoToHelp ??
              (widget.supportRepository == null
                  ? null
                  : () => showSupportRequestSheet(
                      context: context,
                      supportRepository: widget.supportRepository!,
                      supportContext: buildSupportRequestContext(
                        actionType: SupportActionType.productHelp,
                      ),
                    )),
        ),
        _settingsTile(
          icon: Icons.info_outline_rounded,
          label: context.l10n.aboutDoclyzer,
          onTap:
              widget.onGoToAbout ??
              () => showAboutDialog(
                context: context,
                applicationName: 'Doclyzer',
                children: [Text(context.l10n.aboutCopy)],
              ),
        ),
        if (widget.onLogout != null) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: Text(context.l10n.logOut),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRestricted = _restrictionStatus?.isRestricted ?? false;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.editProfile
              ? context.l10n.personalInformation
              : context.l10n.profile,
        ),
        leading: widget.showBackButton
            ? BackButton(onPressed: widget.onBack)
            : null,
      ),
      bottomNavigationBar: widget.editProfile && !_loading
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton.icon(
                key: const Key('account-profile-save'),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(context.l10n.saveChanges),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (!widget.editProfile) ...[
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSettings(),
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
                              Text(
                                context.l10n.accountRestricted,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                semanticsLabel: context.l10n.accountRestricted,
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
                      Center(
                        child: Column(
                          children: [
                            _buildAvatar(),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _uploadingAvatar
                                  ? null
                                  : _pickAndUploadAvatar,
                              icon: const Icon(Icons.add_a_photo_outlined),
                              label: Text(
                                _uploadingAvatar
                                    ? context.l10n.photoUploading
                                    : context.l10n.changePhotoShort,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.accountDetails,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
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
                        decoration: InputDecoration(
                          labelText: context.l10n.emailAddress,
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                          helperText: context.l10n.emailHelp,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('account-profile-display-name'),
                        controller: _displayNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.accountName,
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        maxLength: 100,
                      ),
                    ],
                  ),
        ],
      ),
    );
  }
}
