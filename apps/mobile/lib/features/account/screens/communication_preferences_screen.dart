import 'package:flutter/material.dart';

import '../communication_preferences_repository.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

class CommunicationPreferencesScreen extends StatefulWidget {
  const CommunicationPreferencesScreen({
    super.key,
    required this.communicationPreferencesRepository,
    required this.onBack,
    required this.supportRepository,
  });

  final CommunicationPreferencesRepository communicationPreferencesRepository;
  final VoidCallback onBack;
  final SupportRepository supportRepository;

  @override
  State<CommunicationPreferencesScreen> createState() =>
      _CommunicationPreferencesScreenState();
}

class _CommunicationPreferencesScreenState
    extends State<CommunicationPreferencesScreen> {
  bool _loading = true;
  String? _error;
  SupportRequestContext? _supportContext;
  String? _supportErrorMessage;
  String? _successMessage;
  List<CommunicationPreferenceItem> _preferences = [];
  final Map<String, bool> _pendingChanges = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });
    try {
      final result =
          await widget.communicationPreferencesRepository.getPreferences();
      setState(() {
        _preferences = result.preferences;
        _pendingChanges.clear();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.notificationPreferences,
        );
        _supportErrorMessage = e.toString();
      });
    }
  }

  bool _effectiveEnabled(CommunicationPreferenceItem item) {
    return _pendingChanges.containsKey(item.category)
        ? _pendingChanges[item.category]!
        : item.enabled;
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });
    try {
      final result = await widget.communicationPreferencesRepository
          .updatePreferences(_pendingChanges);
      setState(() {
        _preferences = result.preferences;
        _pendingChanges.clear();
        _loading = false;
        _successMessage = 'Preferences saved';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.notificationPreferences,
        );
        _supportErrorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication Preferences'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._preferences.map((item) => _PreferenceRow(
                        item: item,
                        effectiveEnabled: _effectiveEnabled(item),
                        onChanged: item.mandatory
                            ? null
                            : (value) {
                                setState(() {
                                  _pendingChanges[item.category] = value;
                                });
                              },
                      )),
                  const SizedBox(height: 16),
                  if (_successMessage != null)
                    Padding(
                      key: const Key('communication-preferences-success'),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      key: const Key('communication-preferences-error'),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_error != null && _supportContext != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextButton(
                        onPressed: () {
                          final supportContext = _supportContext;
                          if (supportContext == null) return;
                          showSupportRequestSheet(
                            context: context,
                            supportRepository: widget.supportRepository,
                            supportContext: supportContext,
                            errorMessage: _supportErrorMessage,
                          );
                        },
                        child: const Text('Need help?'),
                      ),
                    ),
                  FilledButton(
                    key: const Key('pref-save'),
                    onPressed: _pendingChanges.isEmpty ? null : _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.item,
    required this.effectiveEnabled,
    required this.onChanged,
  });

  final CommunicationPreferenceItem item;
  final bool effectiveEnabled;
  final ValueChanged<bool>? onChanged;

  String get _label {
    switch (item.category) {
      case commPrefCategorySecurity:
        return 'Security Alerts';
      case commPrefCategoryCompliance:
        return 'Compliance Notices';
      case commPrefCategoryProduct:
        return 'Product Updates';
      default:
        return item.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_label),
                if (item.mandatory)
                  Text(
                    key: Key('pref-${item.category}-mandatory-hint'),
                    'Required for your account',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            key: Key('pref-${item.category}'),
            value: effectiveEnabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
