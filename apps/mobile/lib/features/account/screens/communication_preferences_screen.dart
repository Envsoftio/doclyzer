import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/device_notification_settings.dart';

import '../communication_preferences_repository.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

enum DeviceNotificationActionResult { enabled, settingsOpened, denied }

enum _PushFeedbackTone { success, warning, error }

class CommunicationPreferencesScreen extends StatefulWidget {
  const CommunicationPreferencesScreen({
    super.key,
    required this.communicationPreferencesRepository,
    required this.onBack,
    required this.supportRepository,
    this.onEnablePush,
    this.getPushEnabled,
    this.onMarketingChanged,
    this.saveTimeout = const Duration(seconds: 15),
  });

  final CommunicationPreferencesRepository communicationPreferencesRepository;
  final VoidCallback onBack;
  final SupportRepository supportRepository;
  final Future<DeviceNotificationActionResult> Function()? onEnablePush;
  final Future<bool> Function()? getPushEnabled;
  final Future<void> Function(bool)? onMarketingChanged;
  final Duration saveTimeout;

  @override
  State<CommunicationPreferencesScreen> createState() =>
      _CommunicationPreferencesScreenState();
}

class _CommunicationPreferencesScreenState
    extends State<CommunicationPreferencesScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _saving = false;
  bool _checkingPush = false;
  bool _enablingPush = false;
  bool _pushEnabled = false;
  String? _pushFeedback;
  _PushFeedbackTone? _pushFeedbackTone;
  String? _error;
  String? _warning;
  SupportRequestContext? _supportContext;
  String? _supportErrorMessage;
  String? _successMessage;
  List<CommunicationPreferenceItem> _preferences = [];
  final Map<String, bool> _pendingChanges = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
    unawaited(_refreshPushStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_enablingPush) {
      unawaited(_refreshPushStatus());
    }
  }

  Future<void> _refreshPushStatus() async {
    final getPushEnabled = widget.getPushEnabled;
    if (getPushEnabled == null || _checkingPush) return;
    setState(() => _checkingPush = true);
    try {
      final enabled = await getPushEnabled();
      if (mounted) {
        setState(() {
          if (enabled && !_pushEnabled && _pushFeedback != null) {
            _pushFeedback = 'Report notifications enabled on this device';
            _pushFeedbackTone = _PushFeedbackTone.success;
          }
          _pushEnabled = enabled;
        });
      }
    } catch (_) {
      // Permission status is supplementary; the enable action can still retry.
    } finally {
      if (mounted) setState(() => _checkingPush = false);
    }
  }

  Future<void> _enablePush() async {
    final onEnablePush = widget.onEnablePush;
    if (onEnablePush == null ||
        _checkingPush ||
        _enablingPush ||
        _pushEnabled) {
      return;
    }
    setState(() {
      _enablingPush = true;
      _error = null;
      _warning = null;
      _successMessage = null;
      _pushFeedback = null;
      _pushFeedbackTone = null;
    });
    try {
      final result = await onEnablePush();
      if (!mounted) return;
      setState(() {
        switch (result) {
          case DeviceNotificationActionResult.enabled:
            _pushEnabled = true;
            _pushFeedback = 'Report notifications enabled on this device';
            _pushFeedbackTone = _PushFeedbackTone.success;
            break;
          case DeviceNotificationActionResult.settingsOpened:
            _pushFeedback =
                'Device settings opened. Allow notifications for Doclyzer, then return here.';
            _pushFeedbackTone = _PushFeedbackTone.warning;
            break;
          case DeviceNotificationActionResult.denied:
            _pushFeedback =
                'Notifications are still off. Allow them in device settings to receive report updates.';
            _pushFeedbackTone = _PushFeedbackTone.warning;
            break;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pushFeedback =
            'Could not enable notifications. Check your connection and try again.';
        _pushFeedbackTone = _PushFeedbackTone.error;
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.notificationPreferences,
        );
        _supportErrorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _enablingPush = false);
    }
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
    if (_loading || _saving || _preferences.isEmpty) return;
    final changes = Map<String, bool>.from(_pendingChanges);
    // Save explicitly reapplies the displayed choice to this installation,
    // including retries after account save succeeded but device sync failed.
    for (final item in _preferences) {
      if (item.category == 'marketingPush') {
        changes['marketingPush'] = _effectiveEnabled(item);
      }
    }
    if (changes.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
      _warning = null;
      _successMessage = null;
    });
    try {
      final result = await widget.communicationPreferencesRepository
          .updatePreferences(changes)
          .timeout(widget.saveTimeout);
      if (!mounted) return;
      setState(() {
        _preferences = result.preferences;
        _pendingChanges.clear();
        _successMessage = 'Preferences saved';
      });

      if (changes.containsKey('marketingPush') &&
          widget.onMarketingChanged != null) {
        try {
          await widget.onMarketingChanged!
              .call(changes['marketingPush']!)
              .timeout(widget.saveTimeout);
        } on TimeoutException {
          if (mounted) {
            setState(() {
              _warning = changes['marketingPush']!
                  ? 'Your account choice was saved, but this device did not finish registering for marketing push. Marketing remains blocked on this device; check notification permission and try saving again.'
                  : 'Your account choice was saved. This device could not confirm its local preference yet, but marketing remains blocked at account level.';
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _warning = changes['marketingPush']!
                  ? 'Your account choice was saved, but this device could not enable marketing push. Check notification permission and try again.'
                  : 'Your account choice was saved. This device could not confirm its local preference yet, but marketing remains blocked at account level.';
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is TimeoutException
            ? 'Saving took too long. Check your connection and try again.'
            : e.toString();
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.notificationPreferences,
        );
        _supportErrorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _saving = false);
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
              onPressed: _loading || _saving || _preferences.isEmpty
                  ? null
                  : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save preferences'),
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
                if (widget.onEnablePush != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Get report updates on this device'),
                    subtitle: const Text(
                      'Allow notifications to know when a report is ready. Marketing is a separate choice below.',
                    ),
                    trailing: TextButton.icon(
                      key: const Key('enable-report-notifications'),
                      onPressed: _checkingPush || _enablingPush || _pushEnabled
                          ? null
                          : _enablePush,
                      icon: _checkingPush || _enablingPush
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _pushEnabled
                                  ? Icons.check_circle_outline
                                  : Icons.notifications_active_outlined,
                              size: 18,
                            ),
                      label: Text(_pushEnabled ? 'Enabled' : 'Enable'),
                    ),
                  ),
                  if (_pushFeedback != null)
                    Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _pushFeedback!,
                          key: const Key('push-permission-feedback'),
                          style: TextStyle(
                            color: switch (_pushFeedbackTone) {
                              _PushFeedbackTone.success =>
                                theme.colorScheme.primary,
                              _PushFeedbackTone.warning =>
                                theme.colorScheme.tertiary,
                              _PushFeedbackTone.error =>
                                theme.colorScheme.error,
                              null => null,
                            },
                          ),
                        ),
                      ),
                    ),
                ],
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
                    onChanged: item.mandatory || _loading || _saving
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
                      onChanged: item.mandatory || _loading || _saving
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
                if (_warning != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _warning!,
                      key: const Key('communication-preferences-warning'),
                      style: TextStyle(color: theme.colorScheme.tertiary),
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
