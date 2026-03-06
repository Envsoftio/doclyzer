import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
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
                      style: const TextStyle(color: Colors.red),
                    ),
                  ..._profiles.map(
                    (profile) => ListTile(
                      key: Key('profile-list-item-${profile.id}'),
                      title: Text(profile.name),
                      subtitle: profile.relation != null
                          ? Text(profile.relation!)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (profile.isActive)
                            Chip(
                              key: Key('profile-active-chip-${profile.id}'),
                              label: const Text('Active'),
                            )
                          else
                            OutlinedButton(
                              key: Key('profile-activate-${profile.id}'),
                              onPressed: () => _activateProfile(profile.id),
                              child: const Text('Set Active'),
                            ),
                          IconButton(
                            key: Key('profile-edit-${profile.id}'),
                            icon: const Icon(Icons.edit),
                            onPressed: () => widget.onEditProfile(profile),
                          ),
                          IconButton(
                            key: Key('profile-delete-${profile.id}'),
                            icon: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => _showDeleteConfirm(profile),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_maxProfiles != null && _profiles.length >= _maxProfiles!)
                    OutlinedButton(
                      key: const Key('profile-upgrade-cta'),
                      onPressed: () {
                        // TODO: Navigate to upgrade/paywall when Epic 4 is implemented
                      },
                      child: const Text('Upgrade to add more profiles'),
                    )
                  else
                    FilledButton(
                      key: const Key('profile-create-new'),
                      onPressed: widget.onCreateProfile,
                      child: const Text('Add Profile'),
                    ),
                ],
              ),
      ),
    );
  }
}
