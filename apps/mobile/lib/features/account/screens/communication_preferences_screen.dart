import 'package:mobile/l10n/l10n.dart';
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
            _pushFeedback =
                context.l10n.uiReportNotificationsEnabledOnThisDevice;
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
            _pushFeedback =
                context.l10n.uiReportNotificationsEnabledOnThisDevice;
            _pushFeedbackTone = _PushFeedbackTone.success;
            break;
          case DeviceNotificationActionResult.settingsOpened:
            _pushFeedback = context
                .l10n
                .uiDeviceSettingsOpenedAllowNotificationsForDoclyzer;
            _pushFeedbackTone = _PushFeedbackTone.warning;
            break;
          case DeviceNotificationActionResult.denied:
            _pushFeedback = context.l10n.uiNotificationsAreStillOffAllowThemIn;
            _pushFeedbackTone = _PushFeedbackTone.warning;
            break;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pushFeedback = context.l10n.notificationsFailed;
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
        _successMessage = context.l10n.uiPreferencesSaved;
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
                  ? context.l10n.uiYourAccountChoiceWasSavedButThis
                  : context.l10n.uiYourAccountChoiceWasSavedThisDevice;
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _warning = changes['marketingPush']!
                  ? context.l10n.uiYourAccountChoiceWasSavedButThisaf7de6
                  : context.l10n.uiYourAccountChoiceWasSavedThisDevice;
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is TimeoutException
            ? context.l10n.uiSavingTookTooLongCheckYourConnection
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
        SnackBar(
          content: Text(context.l10n.uiOpenTheDeviceSettingsAppToChange),
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
        title: Text(context.l10n.notifications),
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
                  : Text(context.l10n.uiSavePreferences),
            ),
            TextButton(
              onPressed: _openDeviceSettings,
              child: Text(context.l10n.openSettings),
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
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: Text(context.l10n.notificationPreferences),
                    subtitle: Text(
                      context.l10n.uiDevicePermissionsCanBeChangedInSettings,
                    ),
                  ),
                ),
                if (widget.onEnablePush != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.uiGetReportUpdatesOnThisDevice),
                    subtitle: Text(
                      context.l10n.uiAllowNotificationsToKnowWhenAReport,
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
                      label: Text(
                        _pushEnabled
                            ? context.l10n.uiEnabled
                            : context.l10n.uiEnable,
                      ),
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
                  context.l10n.uiREPORTACTIVITY,
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                if (reportPreferences.isEmpty && !_loading)
                  Text(
                    context.l10n.uiReportActivitySettingsRequireTheLatestServer,
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.uiSensitiveLockScreenPreviews),
                  subtitle: Text(
                    context.l10n.uiReportNamesAndPersonalDetailsAreAlways,
                  ),
                  trailing: Icon(Icons.lock_outline),
                ),
                if (otherPreferences.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.uiOTHERMESSAGES,
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
                      child: Text(context.l10n.needHelp),
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

  (String, String) _copy(BuildContext context) => switch (item.category) {
    commPrefCategoryReportReady => (
      context.l10n.uiReportReadyForReview,
      context.l10n.uiKnowWhenYourResultsAreReadyTo,
    ),
    commPrefCategoryUploadUpdates => (
      context.l10n.uiUploadUpdates,
      context.l10n.uiGetAMessageIfAnUploadNeeds,
    ),
    commPrefCategoryShareReminders => (
      context.l10n.uiSharedLinkReminders,
      context.l10n.uiHearWhenALinkIsAboutTo,
    ),
    commPrefCategorySecurity => (
      context.l10n.uiSecurityAlerts,
      context.l10n.uiRequiredForAccountSafety,
    ),
    commPrefCategoryCompliance => (
      context.l10n.uiComplianceNotices,
      context.l10n.uiRequiredAccountInformation,
    ),
    'marketingPush' => (
      context.l10n.uiMarketingPushNotifications,
      context.l10n.uiOffersAndAnnouncementsSavingThisChoiceAlso,
    ),
    commPrefCategoryProduct => (
      context.l10n.uiProductUpdates,
      context.l10n.uiOptionalNewsAboutDoclyzer,
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
                  Text(
                    _copy(context).$1,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _copy(context).$2,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
