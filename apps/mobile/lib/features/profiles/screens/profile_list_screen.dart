import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../profiles_repository.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({
    super.key,
    required this.profilesRepository,
    required this.onCreateProfile,
    required this.onEditProfile,
    required this.onBack,
  });

  final ProfilesRepository profilesRepository;
  final VoidCallback onCreateProfile;
  final void Function(Profile) onEditProfile;
  final VoidCallback onBack;

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  List<Profile> _profiles = [];
  int? _maxProfiles;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final profiles = await widget.profilesRepository.getProfiles();
      final maxProfiles = await widget.profilesRepository.getMaxProfiles();
      setState(() {
        _profiles = profiles;
        _maxProfiles = maxProfiles;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profiles. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _activateProfile(String id) async {
    await widget.profilesRepository.activateProfile(id);
    await _loadProfiles();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(theme),
      ),
      floatingActionButton: _loading
          ? null
          : (_maxProfiles != null && _profiles.length >= _maxProfiles!)
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: FloatingActionButton.extended(
                    key: const Key('profile-create-new'),
                    onPressed: widget.onCreateProfile,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add profile'),
                  ),
                ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return CustomScrollView(
      slivers: [
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
                    Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 20),
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
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No profiles yet',
                      style: theme.textTheme.titleLarge,
                    ),
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
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final profile = _profiles[index];
                  return _ProfileCard(
                    key: Key('profile-list-item-${profile.id}'),
                    profile: profile,
                    onActivate: () => _activateProfile(profile.id),
                    onEdit: () => widget.onEditProfile(profile),
                    onDelete: () => _showDeleteConfirm(profile),
                  );
                },
                childCount: _profiles.length,
              ),
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
    required this.onActivate,
    required this.onEdit,
    required this.onDelete,
  });

  final Profile profile;
  final VoidCallback onActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => onEdit(),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
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
                          style: theme.textTheme.titleMedium,
                        ),
                        if (profile.relation != null && profile.relation!.isNotEmpty)
                          Text(
                            profile.relation!,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (profile.isActive)
                    Container(
                      key: Key('profile-active-chip-${profile.id}'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
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
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Set active'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    key: Key('profile-edit-${profile.id}'),
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  IconButton(
                    key: Key('profile-delete-${profile.id}'),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: onDelete,
                    style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
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
