import 'package:flutter/material.dart';

import '../profiles_repository.dart';

class CreateEditProfileScreen extends StatefulWidget {
  const CreateEditProfileScreen({
    super.key,
    required this.profilesRepository,
    this.existingProfile,
    required this.onComplete,
    required this.onBack,
  });

  final ProfilesRepository profilesRepository;
  final Profile? existingProfile;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  @override
  State<CreateEditProfileScreen> createState() =>
      _CreateEditProfileScreenState();
}

class _CreateEditProfileScreenState extends State<CreateEditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _relationController;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingProfile?.name ?? '');
    _dobController =
        TextEditingController(text: widget.existingProfile?.dateOfBirth ?? '');
    _relationController =
        TextEditingController(text: widget.existingProfile?.relation ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final dob =
          _dobController.text.trim().isEmpty ? null : _dobController.text.trim();
      final relation = _relationController.text.trim().isEmpty
          ? null
          : _relationController.text.trim();

      if (widget.existingProfile != null) {
        await widget.profilesRepository.updateProfile(
          id: widget.existingProfile!.id,
          name: name,
          dateOfBirth: dob,
          relation: relation,
        );
      } else {
        await widget.profilesRepository.createProfile(
          name: name,
          dateOfBirth: dob,
          relation: relation,
        );
      }
      widget.onComplete();
    } on ProfileLimitExceededException catch (e) {
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to save profile. Please try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProfile != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Profile' : 'Create Profile'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Text(
                _error!,
                key: const Key('profile-form-error'),
                style: const TextStyle(color: Colors.red),
              ),
            TextField(
              key: const Key('profile-name-field'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('profile-dob-field'),
              controller: _dobController,
              decoration:
                  const InputDecoration(labelText: 'Date of Birth (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('profile-relation-field'),
              controller: _relationController,
              decoration:
                  const InputDecoration(labelText: 'Relation (optional)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('profile-submit'),
              onPressed: _submitting ? null : _submit,
              child: Text(isEdit ? 'Update Profile' : 'Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
