import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';

import '../../../core/api_client.dart';
import '../../../core/theme/app_theme.dart';
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
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingProfile?.name ?? '',
    );
    _selectedDob = _parseDob(widget.existingProfile?.dateOfBirth);
    _relationController = TextEditingController(
      text: widget.existingProfile?.relation ?? '',
    );
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
      if (!mounted) return;
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final name = _nameController.text.trim();
    final relation = _relationController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter a name');
      return;
    }
    if (name.length > 100) {
      setState(() => _nameError = 'Use 100 characters or fewer');
      return;
    }
    if (relation.length > 50) {
      setState(() => _error = 'Relationship must be 50 characters or fewer.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
      _nameError = null;
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
      if (!mounted) return;
      widget.onComplete();
    } on ProfileLimitExceededException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message.isNotEmpty
            ? e.message
            : 'Failed to save profile. Please try again.';
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to save profile. Please try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProfile != null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit profile' : 'Add profile'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: FilledButton(
            key: const Key('profile-submit'),
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEdit ? 'Save changes' : 'Create profile'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEdit ? 'Update their details' : 'Who is this profile for?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep each person’s reports and trends together.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (_error != null) ...[
            Container(
              key: const Key('profile-form-error'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              ),
              child: Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text('Person details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('profile-name-field'),
                  controller: _nameController,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: 'Enter a name',
                    errorText: _nameError,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                Text('Date of birth', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Semantics(
                  button: true,
                  label: 'Date of birth, optional',
                  value: _selectedDob == null
                      ? 'Not selected'
                      : AppDateFormat.date(_selectedDob!, local: false),
                  child: InkWell(
                    key: const Key('profile-dob-field'),
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        suffixIcon: _selectedDob == null
                            ? const Icon(Icons.chevron_right_rounded)
                            : IconButton(
                                tooltip: 'Clear date of birth',
                                onPressed: () =>
                                    setState(() => _selectedDob = null),
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                      child: Text(
                        _selectedDob != null
                            ? AppDateFormat.date(_selectedDob!, local: false)
                            : 'Optional',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _selectedDob == null
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Relationship', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('profile-relation-field'),
                  controller: _relationController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  maxLength: 50,
                  decoration: const InputDecoration(
                    hintText: 'Optional, e.g. parent or child',
                    counterText: '',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
