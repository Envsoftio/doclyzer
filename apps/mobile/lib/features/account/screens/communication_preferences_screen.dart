import 'package:flutter/material.dart';
import '../../../core/device_notification_settings.dart';

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
    this.onEnablePush,
    this.onMarketingChanged,
  });

  final CommunicationPreferencesRepository communicationPreferencesRepository;
  final VoidCallback onBack;
  final SupportRepository supportRepository;
  final Future<void> Function()? onEnablePush;
  final Future<void> Function(bool)? onMarketingChanged;

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
      final result = await widget.communicationPreferencesRepository
          .getPreferences();
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
      if (_pendingChanges.containsKey('marketingPush')) {
        await widget.onMarketingChanged?.call(
          _pendingChanges['marketingPush']!,
        );
      }
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

  Future<void> _openDeviceSettings() async {
    if (!await openDeviceNotificationSettings() && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Open the device Settings app to change notification access.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const categories = [
      commPrefCategoryReportReady,
      commPrefCategoryUploadUpdates,
      commPrefCategoryShareReminders,
    ];
    final reportPreferences = [
      for (final category in categories)
        ..._preferences.where((item) => item.category == category),
    ];
    final otherPreferences = _preferences
        .where((item) => !categories.contains(item.category))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              key: const Key('pref-save'),
              onPressed: _loading || _pendingChanges.isEmpty ? null : _save,
              child: const Text('Save preferences'),
            ),
            TextButton(
              onPressed: _openDeviceSettings,
              child: const Text('Open device settings'),
            ),
          ],
        ),
      ),
      body: _loading && _preferences.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.info_outline),
                    title: Text('Notification preferences'),
                    subtitle: Text(
                      'Device permissions can be changed in Settings.',
                    ),
                  ),
                ),
                if (widget.onEnablePush != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Get report updates on this device'),
                    subtitle: const Text(
                      'Allow notifications to know when a report is ready. Marketing is a separate choice below.',
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        try {
                          await widget.onEnablePush!();
                        } catch (e) {
                          if (mounted) setState(() => _error = e.toString());
                        }
                      },
                      child: const Text('Enable'),
                    ),
                  ),
                const SizedBox(height: 32),
                Text(
                  'REPORT ACTIVITY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                if (reportPreferences.isEmpty && !_loading)
                  const Text(
                    'Report activity settings require the latest server version.',
                  ),
                for (final item in reportPreferences)
                  _PreferenceRow(
                    item: item,
                    effectiveEnabled: _effectiveEnabled(item),
                    onChanged: item.mandatory || _loading
                        ? null
                        : (value) => setState(
                            () => _pendingChanges[item.category] = value,
                          ),
                  ),
                const SizedBox(height: 4),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Sensitive lock-screen previews'),
                  subtitle: Text(
                    'Report names and personal details are always hidden.',
                  ),
                  trailing: Icon(Icons.lock_outline),
                ),
                if (otherPreferences.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'OTHER MESSAGES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                  for (final item in otherPreferences)
                    _PreferenceRow(
                      item: item,
                      effectiveEnabled: _effectiveEnabled(item),
                      onChanged: item.mandatory || _loading
                          ? null
                          : (value) => setState(
                              () => _pendingChanges[item.category] = value,
                            ),
                    ),
                ],
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _successMessage!,
                      key: const Key('communication-preferences-success'),
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                if (_error != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      key: const Key('communication-preferences-error'),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  if (_supportContext != null)
                    TextButton(
                      onPressed: () => showSupportRequestSheet(
                        context: context,
                        supportRepository: widget.supportRepository,
                        supportContext: _supportContext!,
                        errorMessage: _supportErrorMessage,
                      ),
                      child: const Text('Need help?'),
                    ),
                ],
              ],
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

  (String, String) get _copy => switch (item.category) {
    commPrefCategoryReportReady => (
      'Report ready for review',
      'Know when your results are ready to check.',
    ),
    commPrefCategoryUploadUpdates => (
      'Upload updates',
      'Get a message if an upload needs attention.',
    ),
    commPrefCategoryShareReminders => (
      'Shared link reminders',
      'Hear when a link is about to expire.',
    ),
    commPrefCategorySecurity => (
      'Security alerts',
      'Required for account safety.',
    ),
    commPrefCategoryCompliance => (
      'Compliance notices',
      'Required account information.',
    ),
    'marketingPush' => (
      'Marketing push notifications',
      'Offers and announcements. Saving this choice also applies it to this device.',
    ),
    commPrefCategoryProduct => (
      'Product updates',
      'Optional news about Doclyzer.',
    ),
    _ => (item.category, ''),
  };

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_copy.$1, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(_copy.$2, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Switch.adaptive(
              key: Key('pref-${item.category}'),
              value: effectiveEnabled,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );
}
