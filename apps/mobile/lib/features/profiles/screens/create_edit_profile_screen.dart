import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../profiles_repository.dart';

DateTime? _parseDob(String? s) {
  if (s == null || s.trim().isEmpty) return null;
  return DateTime.tryParse(s.trim());
}

String _formatDob(DateTime d) {
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

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
  late final TextEditingController _relationController;
  DateTime? _selectedDob;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingProfile?.name ?? '');
    _selectedDob = _parseDob(widget.existingProfile?.dateOfBirth);
    _relationController =
        TextEditingController(text: widget.existingProfile?.relation ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? DateTime(now.year - 30, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final relation = _relationController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    if (name.length > 100) {
      setState(() => _error = 'Name must be 100 characters or fewer.');
      return;
    }
    if (relation.length > 50) {
      setState(
        () => _error = 'Relation must be 50 characters or fewer.',
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final dob = _selectedDob != null ? _formatDob(_selectedDob!) : null;
      final relationValue = relation.isEmpty ? null : relation;

      if (widget.existingProfile != null) {
        await widget.profilesRepository.updateProfile(
          id: widget.existingProfile!.id,
          name: name,
          dateOfBirth: dob,
          relation: relationValue,
        );
      } else {
        await widget.profilesRepository.createProfile(
          name: name,
          dateOfBirth: dob,
          relation: relationValue,
        );
      }
      widget.onComplete();
    } on ProfileLimitExceededException catch (e) {
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message.isNotEmpty
            ? e.message
            : 'Failed to save profile. Please try again.';
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
            InkWell(
              key: const Key('profile-dob-field'),
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (optional)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDob != null
                      ? _formatDob(_selectedDob!)
                      : 'Tap to select date',
                  style: TextStyle(
                    color: _selectedDob != null
                        ? null
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
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
