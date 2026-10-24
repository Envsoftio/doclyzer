import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';
import '../../reports/reports_repository.dart';
import '../profiles_repository.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({
    super.key,
    required this.profilesRepository,
    required this.reportsRepository,
    required this.onCreateProfile,
    required this.onEditProfile,
    required this.onOpenProfileReports,
    required this.onBack,
    this.showBackButton = true,
  });

  final ProfilesRepository profilesRepository;
  final ReportsRepository reportsRepository;
  final VoidCallback onCreateProfile;
  final void Function(Profile) onEditProfile;
  final void Function(Profile) onOpenProfileReports;
  final VoidCallback onBack;
  final bool showBackButton;

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  List<Profile> _profiles = [];
  Map<String, int> _reportCountByProfileId = {};
  int? _maxProfiles;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final profiles = await widget.profilesRepository.getProfiles();
      final reports = await widget.reportsRepository.listAllReports();
      final maxProfiles = await widget.profilesRepository.getMaxProfiles();
      final reportCountByProfileId = <String, int>{};
      for (final report in reports) {
        final profileId = report.profileId;
        reportCountByProfileId[profileId] =
            (reportCountByProfileId[profileId] ?? 0) + 1;
      }
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _reportCountByProfileId = reportCountByProfileId;
        _maxProfiles = maxProfiles;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load profiles. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _activateProfile(String id) async {
    try {
      await widget.profilesRepository.activateProfile(id);
      if (mounted) await _loadProfiles();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to switch profiles. ${error is ApiException && error.message.isNotEmpty ? error.message : 'Please try again.'}',
        );
      }
    }
  }

  Future<void> _showDeleteConfirm(Profile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('profile-delete-dialog'),
        title: const Text('Delete profile?'),
        content: const Text(
          'This profile will be removed. Any data linked to it will be affected.',
        ),
        actions: [
          TextButton(
            key: const Key('profile-delete-cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('profile-delete-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await widget.profilesRepository.deleteProfile(profile.id);
        await _loadProfiles();
      } catch (e) {
        setState(() {
          _error = 'Failed to delete profile. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAddProfile =
        !_loading && (_maxProfiles == null || _profiles.length < _maxProfiles!);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Family'),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              )
            : null,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(theme),
      ),
      bottomNavigationBar: canAddProfile
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: FilledButton.icon(
                  key: const Key('profile-create-new'),
                  onPressed: widget.onCreateProfile,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add family member'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_error != null && _profiles.isEmpty) {
      return DesignEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Family profiles unavailable',
        message: _error!,
        action: 'Try again',
        onAction: _loadProfiles,
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.group_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_profiles.length} ${_profiles.length == 1 ? 'person' : 'people'}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reports and trends, organized by person',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                0,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_profiles.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('No profiles yet', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add a profile to organize reports for yourself or family members.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text('Your family', style: theme.textTheme.titleMedium),
            ),
          ),
        if (_profiles.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              0,
              AppSpacing.screenPadding,
              AppSpacing.lg,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final profile = _profiles[index];
                return _ProfileCard(
                  key: Key('profile-list-item-${profile.id}'),
                  profile: profile,
                  reportCount: _reportCountByProfileId[profile.id] ?? 0,
                  onOpenReports: () => widget.onOpenProfileReports(profile),
                  onActivate: () => _activateProfile(profile.id),
                  onEdit: () => widget.onEditProfile(profile),
                  onDelete: () => _showDeleteConfirm(profile),
                );
              }, childCount: _profiles.length),
            ),
          ),
        if (_maxProfiles != null &&
            _profiles.isNotEmpty &&
            _profiles.length >= _maxProfiles!)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.xl,
              ),
              child: OutlinedButton(
                key: const Key('profile-upgrade-cta'),
                onPressed: () {
                  // TODO: Navigate to upgrade/paywall when Epic 4 is implemented
                },
                child: const Text('Upgrade to add more profiles'),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    super.key,
    required this.profile,
    required this.reportCount,
    required this.onOpenReports,
    required this.onActivate,
    required this.onEdit,
    required this.onDelete,
  });

  final Profile profile;
  final int reportCount;
  final VoidCallback onOpenReports;
  final VoidCallback onActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onOpenReports,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (profile.relation != null &&
                            profile.relation!.isNotEmpty)
                          Text(
                            profile.relation!,
                            style: theme.textTheme.bodySmall,
                          ),
                        Text(
                          '$reportCount ${reportCount == 1 ? 'report' : 'reports'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    key: Key('profile-actions-${profile.id}'),
                    tooltip: 'Actions for ${profile.name}',
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (action) {
                      if (action == 'edit') onEdit();
                      if (action == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit profile'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete_outline_rounded,
                            color: theme.colorScheme.error,
                          ),
                          title: Text('Delete profile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (profile.isActive)
                    Container(
                      key: Key('profile-active-chip-${profile.id}'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Active',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      key: Key('profile-activate-${profile.id}'),
                      onPressed: onActivate,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Set active'),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onOpenReports,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('View reports'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
