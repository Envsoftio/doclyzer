import 'features/reports/report_processing_store.dart';
import 'features/reports/screens/report_detail_screen.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/api_client.dart';
import 'core/api_config.dart';
import 'core/device_notification_settings.dart';
import 'core/feedback/status_messenger.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/design_components.dart';
import 'core/navigation/mobile_navigation_shell.dart';
import 'core/navigation/app_notification_frame.dart';
import 'core/token_storage.dart';
import 'features/incidents/api_incident_repository.dart';
import 'features/incidents/incident_repository.dart';
import 'features/account/api_account_repository.dart';
import 'features/account/api_communication_preferences_repository.dart';
import 'features/account/api_data_rights_repository.dart';
import 'features/account/api_restriction_repository.dart';
import 'features/account/screens/account_profile_screen.dart';
import 'features/account/screens/communication_preferences_screen.dart';
import 'features/account/screens/data_rights_screen.dart';
import 'features/account/screens/account_information_screens.dart';
import 'features/auth/api_auth_repository.dart';
import 'features/account/account_repository.dart';
import 'features/account/communication_preferences_repository.dart';
import 'features/account/data_rights_repository.dart';
import 'features/account/restriction_repository.dart';
import 'features/auth/api_sessions_repository.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/sessions_repository.dart';
import 'features/auth/forgot_password/forgot_password_screen.dart';
import 'features/auth/reset_password/reset_password_screen.dart';
import 'features/auth/screens/home_screen.dart';
import 'features/auth/screens/change_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/session_list_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/startup_loading_screen.dart';
import 'features/auth/screens/verification_screen.dart';
import 'features/profiles/profiles_repository.dart';
import 'features/profiles/api_profiles_repository.dart';
import 'features/profiles/screens/create_edit_profile_screen.dart';
import 'features/profiles/screens/profile_list_screen.dart';
import 'features/reports/reports_repository.dart';
import 'features/reports/api_reports_repository.dart';
import 'features/reports/screens/timeline_screen.dart';
import 'features/reports/screens/health_history_screen.dart';
import 'features/reports/screens/upload_report_screen.dart';
import 'features/referrals/api_referrals_repository.dart';
import 'features/referrals/referrals_repository.dart';
import 'features/referrals/screens/referral_dashboard_screen.dart';
import 'features/billing/billing_repository.dart';
import 'features/billing/api_billing_repository.dart';
import 'features/billing/screens/credit_pack_list_screen.dart';
import 'features/billing/screens/entitlement_summary_screen.dart';
import 'features/billing/screens/plan_selection_screen.dart';
import 'features/notifications/api_notifications_repository.dart';
import 'features/notifications/notifications_repository.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/notifications/push_notification_service.dart';
import 'features/sharing/sharing_repository.dart';
import 'features/sharing/api_sharing_repository.dart';
import 'features/sharing/screens/create_share_link_screen.dart';
import 'features/support/api_support_repository.dart';
import 'features/support/support_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeBackgroundHandling();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const DoclyzerApp());
}

enum _AuthView {
  onboarding,
  login,
  sessionUnavailable,
  signup,
  verification,
  home,
  forgotPassword,
  resetPassword,
  accountProfile,
  profileList,
  sessionList,
  createProfile,
  editProfile,
  communicationPreferences,
  dataRights,
  uploadReport,
  timeline,
  trends,
  billing,
  referrals,
  creditPackList,
  planSelection,
}

class DoclyzerApp extends StatefulWidget {
  const DoclyzerApp({
    super.key,
    this.authRepository,
    this.accountRepository,
    this.profilesRepository,
    this.sessionsRepository,
    this.communicationPreferencesRepository,
    this.dataRightsRepository,
    this.restrictionRepository,
    this.reportsRepository,
    this.sharingRepository,
    this.billingRepository,
    this.referralsRepository,
    this.incidentRepository,
    this.supportRepository,
    this.notificationsRepository,
    this.pushNotificationService,
  });

  final AuthRepository? authRepository;
  final AccountRepository? accountRepository;
  final ProfilesRepository? profilesRepository;
  final SessionsRepository? sessionsRepository;
  final CommunicationPreferencesRepository? communicationPreferencesRepository;
  final DataRightsRepository? dataRightsRepository;
  final RestrictionRepository? restrictionRepository;
  final ReportsRepository? reportsRepository;
  final SharingRepository? sharingRepository;
  final BillingRepository? billingRepository;
  final ReferralsRepository? referralsRepository;
  final IncidentRepository? incidentRepository;
  final SupportRepository? supportRepository;
  final NotificationsRepository? notificationsRepository;
  final PushNotificationService? pushNotificationService;

  @override
  State<DoclyzerApp> createState() => _DoclyzerAppState();
}

class _DoclyzerAppState extends State<DoclyzerApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  ThemeMode _themeMode = ThemeMode.system;
  static const _appearanceStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  bool _savingAppearance = false;
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _appLockEnabled = false;
  bool _appLockPreferenceLoaded = false;
  bool _appLockLoadError = false;
  bool _appLocked = false;
  bool _unlocking = false;

  Future<void> _restoreAppLock() async {
    try {
      final enabled = await _appearanceStorage.read(key: 'doclyzer_app_lock');
      if (mounted) {
        setState(() {
          _appLockEnabled = enabled == 'true';
          _appLocked = enabled == 'true';
          _appLockPreferenceLoaded = true;
          _appLockLoadError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _appLockPreferenceLoaded = true;
          _appLockLoadError = true;
          _appLocked = true;
        });
      }
    }
  }

  Future<bool> _setAppLockEnabled(bool enabled) async {
    try {
      if (enabled) {
        if (!await _localAuthentication.isDeviceSupported()) {
          throw StateError('Set a device passcode before turning on App lock.');
        }
      }
      final confirmed = await _localAuthentication.authenticate(
        localizedReason: enabled
            ? 'Confirm App lock for Doclyzer'
            : 'Confirm before turning off App lock',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!confirmed) return _appLockEnabled;
      await _appearanceStorage.write(
        key: 'doclyzer_app_lock',
        value: enabled ? 'true' : 'false',
      );
      if (mounted) {
        setState(() {
          _appLockEnabled = enabled;
          _appLocked = false;
        });
      }
    } catch (error) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            error is StateError
                ? error.message
                : 'Could not change App lock. Try again.',
          ),
        ),
      );
    }
    return _appLockEnabled;
  }

  Future<void> _unlockApp() async {
    if (!_appLocked || _unlocking) return;
    setState(() => _unlocking = true);
    try {
      final unlocked = await _localAuthentication.authenticate(
        localizedReason: 'Unlock Doclyzer to view your health records',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (mounted && unlocked) setState(() => _appLocked = false);
    } catch (_) {
      // The opaque lock screen stays in place until authentication succeeds.
    } finally {
      if (mounted) setState(() => _unlocking = false);
    }
  }

  Future<void> _restoreAppearance() async {
    try {
      final saved = await _appearanceStorage.read(key: 'doclyzer_theme_mode');
      if (!mounted) return;
      setState(
        () => _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == saved,
          orElse: () => ThemeMode.system,
        ),
      );
    } catch (_) {
      // Use the device appearance when preferences cannot be read.
    }
  }

  Future<void> _changeAppearance(ThemeMode mode) async {
    if (_savingAppearance) return;
    setState(() {
      _themeMode = mode;
      _savingAppearance = true;
    });
    try {
      await _appearanceStorage.write(
        key: 'doclyzer_theme_mode',
        value: mode.name,
      );
    } catch (_) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Appearance changed, but could not be saved for next time.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingAppearance = false);
    }
  }

  ApiClient? _apiClient;
  late final TokenStorage _tokenStorage;
  ApiAuthRepository? _authRepository;
  late final AccountRepository _accountRepository;
  late final ProfilesRepository _profilesRepository;
  late final SessionsRepository _sessionsRepository;
  late final CommunicationPreferencesRepository
  _communicationPreferencesRepository;
  late final DataRightsRepository _dataRightsRepository;
  late final RestrictionRepository _restrictionRepository;
  late final ReportsRepository _reportsRepository;
  late final SharingRepository _sharingRepository;
  late final BillingRepository _billingRepository;
  late final ReferralsRepository _referralsRepository;
  late final IncidentRepository _incidentRepository;
  late final SupportRepository _supportRepository;
  late final NotificationsRepository _notificationsRepository;
  late final PushNotificationService _pushNotificationService;

  _AuthView _authView = _AuthView.login;
  String? _prefillEmail;
  Profile? _editingProfile;
  bool _uploadInFlight = false;
  bool _hasInterruptedUpload = false;
  _AuthView _profileListReturnView = _AuthView.home;
  String _activeProfileNameForUpload = '';
  String? _timelineProfileId;
  String? _timelineProfileName;
  bool _initialized = false;
  bool _isHandlingUnauthorized = false;
  bool _pushPermissionPromptHandled = false;
  PublicIncidentStatus? _incidentStatus;
  DateTime? _incidentFetchedAt;

  static const Duration _incidentCacheTtl = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    unawaited(_restoreAppearance());
    unawaited(_restoreAppLock());
    WidgetsBinding.instance.addObserver(this);
    if (widget.authRepository != null) {
      final tokenStorage = _tokenStorage = TokenStorage();
      _apiClient = ApiClient(
        baseUrl: apiBaseUrl,
        onRefreshToken: () async => null,
        onUnauthorized: _handleUnauthorized,
      );
      _accountRepository = widget.accountRepository!;
      _profilesRepository = widget.profilesRepository!;
      _sessionsRepository = widget.sessionsRepository!;
      _communicationPreferencesRepository =
          widget.communicationPreferencesRepository!;
      _dataRightsRepository = widget.dataRightsRepository!;
      _restrictionRepository = widget.restrictionRepository!;
      _reportsRepository = widget.reportsRepository!;
      _sharingRepository = widget.sharingRepository!;
      _billingRepository = widget.billingRepository!;
      _referralsRepository =
          widget.referralsRepository ?? ApiReferralsRepository(_apiClient!);
      _incidentRepository =
          widget.incidentRepository ?? ApiIncidentRepository(_apiClient!);
      _supportRepository =
          widget.supportRepository ?? ApiSupportRepository(_apiClient!);
      _notificationsRepository =
          widget.notificationsRepository ??
          ApiNotificationsRepository(_apiClient!);
      _pushNotificationService =
          widget.pushNotificationService ??
          PushNotificationService(
            notificationsRepository: _notificationsRepository,
            tokenStorage: tokenStorage,
          );
      setState(() => _initialized = true);
      _refreshIncidentStatus(force: true);
    } else {
      final tokenStorage = _tokenStorage = TokenStorage();
      _apiClient = ApiClient(
        baseUrl: apiBaseUrl,
        onRefreshToken: () => _authRepository!.refreshTokens(),
        onUnauthorized: _handleUnauthorized,
      );
      _authRepository = ApiAuthRepository(_apiClient!, tokenStorage);
      _accountRepository = ApiAccountRepository(_apiClient!);
      _profilesRepository = ApiProfilesRepository(_apiClient!);
      _sessionsRepository = ApiSessionsRepository(_apiClient!);
      _communicationPreferencesRepository =
          ApiCommunicationPreferencesRepository(_apiClient!);
      _dataRightsRepository = ApiDataRightsRepository(_apiClient!);
      _restrictionRepository = ApiRestrictionRepository(_apiClient!);
      _reportsRepository = ApiReportsRepository(
        _apiClient!,
        tokenStorage: _tokenStorage,
      );
      _sharingRepository =
          widget.sharingRepository ?? ApiSharingRepository(_apiClient!);
      _billingRepository =
          widget.billingRepository ?? ApiBillingRepository(_apiClient!);
      _referralsRepository =
          widget.referralsRepository ?? ApiReferralsRepository(_apiClient!);
      _incidentRepository =
          widget.incidentRepository ?? ApiIncidentRepository(_apiClient!);
      _supportRepository =
          widget.supportRepository ?? ApiSupportRepository(_apiClient!);
      _notificationsRepository =
          widget.notificationsRepository ??
          ApiNotificationsRepository(_apiClient!);
      _pushNotificationService =
          widget.pushNotificationService ??
          PushNotificationService(
            notificationsRepository: _notificationsRepository,
            tokenStorage: tokenStorage,
          );
      _initAuth();
      _refreshIncidentStatus(force: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ReportProcessingStore.instance.stop();
    unawaited(_pushNotificationService.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_appLocked) unawaited(_unlockApp());
      _refreshIncidentStatus();
      if (_apiClient?.accessToken != null) {
        ReportProcessingStore.instance.start(_apiClient!);
        unawaited(_pushNotificationService.start());
        unawaited(_pushNotificationService.flushPendingNavigation());
      }
    } else {
      if (_appLockEnabled &&
          (state == AppLifecycleState.paused ||
              state == AppLifecycleState.hidden) &&
          !_unlocking &&
          mounted) {
        setState(() => _appLocked = true);
      }
      ReportProcessingStore.instance.stop();
    }
  }

  Future<void> _refreshIncidentStatus({bool force = false}) async {
    final lastFetched = _incidentFetchedAt;
    if (!force &&
        lastFetched != null &&
        DateTime.now().difference(lastFetched) < _incidentCacheTtl) {
      return;
    }
    try {
      final incident = await _incidentRepository.getActiveIncident();
      if (!mounted) return;
      setState(() {
        _incidentStatus = incident;
        _incidentFetchedAt = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _incidentFetchedAt = DateTime.now();
      });
    }
  }

  Future<void> _initAuth() async {
    bool restored = false;
    try {
      restored = await _authRepository!.restoreSession();
    } catch (_) {
      // Secure storage can fail after a device restore; offer a fresh login.
    }
    if (restored && mounted) {
      ClosureRequest? closure;
      try {
        closure = await _dataRightsRepository.getClosureRequest();
      } catch (_) {}
      final interrupted = await _readInterruptedUpload();
      if (closure?.status != 'pending') _startReportServices();
      setState(() {
        _authView = closure?.status == 'pending'
            ? _AuthView.dataRights
            : _AuthView.home;
        _hasInterruptedUpload = interrupted;
        _initialized = true;
      });
    } else if (mounted) {
      bool hasStoredSession = false;
      bool hasSeenOnboarding = true;
      try {
        hasStoredSession = await _tokenStorage.hasTokens();
      } catch (_) {
        // A broken keychain/keystore must not trap the user on the splash.
      }
      try {
        hasSeenOnboarding =
            await _appearanceStorage.read(key: 'doclyzer_onboarding_seen') ==
            'true';
      } catch (_) {
        // Continue to sign-in if first-launch storage is unavailable.
      }
      if (mounted) {
        setState(() {
          _authView = hasStoredSession
              ? _AuthView.sessionUnavailable
              : hasSeenOnboarding
              ? _AuthView.login
              : _AuthView.onboarding;
          _initialized = true;
        });
      }
    }
  }

  Future<void> _finishOnboarding() async {
    try {
      await _appearanceStorage.write(
        key: 'doclyzer_onboarding_seen',
        value: 'true',
      );
    } catch (_) {
      // Users can proceed even when local onboarding storage is unavailable.
    }
    if (mounted) setState(() => _authView = _AuthView.login);
  }

  Future<bool> _readInterruptedUpload() async {
    try {
      return await _tokenStorage.hasInterruptedReportUpload();
    } catch (_) {
      return false;
    }
  }

  Future<void> _retrySession() async {
    setState(() => _initialized = false);
    await _initAuth();
  }

  AuthRepository get _auth => _authRepository ?? widget.authRepository!;

  Future<void> _register(
    String email,
    String password,
    String? referralCode,
  ) async {
    final result = await _auth.register(
      email: email,
      password: password,
      referralCode: referralCode,
    );

    if (result.requiresVerification && mounted) {
      setState(() {
        _prefillEmail = email;
        _authView = _AuthView.verification;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _prefillEmail = email;
        _authView = _AuthView.login;
      });
    }
  }

  void _startReportServices() {
    if (_apiClient != null) ReportProcessingStore.instance.start(_apiClient!);
    _pushNotificationService.canNavigate = () =>
        mounted &&
        !_appLocked &&
        _initialized &&
        _apiClient?.accessToken != null &&
        _navigatorKey.currentState != null &&
        _authView != _AuthView.login;
    _pushNotificationService.onDestinationOpen = (path) async {
      if (path == '/reports') {
        await _selectTab(1);
      } else if (path == '/account') {
        setState(() => _authView = _AuthView.accountProfile);
      } else {
        _navigatorKey.currentState?.push<void>(
          MaterialPageRoute(
            builder: (_) => NotificationsScreen(
              repository: _notificationsRepository,
              onBack: () => _navigatorKey.currentState?.pop(),
              onOpenRelated: _openNotificationRelated,
              onManagePreferences: () {
                _navigatorKey.currentState?.pop();
                setState(() => _authView = _AuthView.communicationPreferences);
              },
            ),
          ),
        );
      }
    };
    _pushNotificationService.onReportOpen = (id) async {
      final session = _apiClient?.accessToken;
      if (session == null || _appLocked) return false;
      try {
        final report = await _reportsRepository.getReport(id);
        if (!mounted || _appLocked || _apiClient?.accessToken != session) {
          return false;
        }
        final opened = Completer<bool>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ||
              _appLocked ||
              _apiClient?.accessToken != session ||
              _navigatorKey.currentState == null) {
            opened.complete(false);
            return;
          }
          _navigatorKey.currentState!.push(
            MaterialPageRoute<void>(
              builder: (_) => ReportDetailScreen(
                reportsRepository: _reportsRepository,
                profilesRepository: _profilesRepository,
                reportId: report.id,
                profileId: report.profileId,
                onBack: () => _navigatorKey.currentState?.pop(),
                onShareReport: _shareReport,
              ),
            ),
          );
          opened.complete(true);
        });
        WidgetsBinding.instance.scheduleFrame();
        return await opened.future;
      } catch (_) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('This report is no longer available.')),
        );
        return false;
      }
    };
    _pushNotificationService.onForegroundReport = () =>
        ReportProcessingStore.instance.reconcile();
    unawaited(_pushNotificationService.start());
  }

  Future<void> _login(String email, String password) async {
    await _auth.login(email: email, password: password);
    final closure = await _dataRightsRepository.getClosureRequest();
    final interrupted = await _readInterruptedUpload();
    if (closure?.status != 'pending') _startReportServices();
    if (mounted) {
      setState(() {
        _pushPermissionPromptHandled = false;
        _authView = closure?.status == 'pending'
            ? _AuthView.dataRights
            : _AuthView.home;
        _hasInterruptedUpload = interrupted;
      });
    }
  }

  Future<void> _logout() async {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    ReportProcessingStore.instance.stop();
    await _pushNotificationService.dispose();
    await _pushNotificationService.deactivateCurrentToken();
    await _auth.logout();
    if (mounted) {
      setState(() {
        _authView = _AuthView.login;
        _pushPermissionPromptHandled = false;
        _hasInterruptedUpload = false;
        _uploadInFlight = false;
      });
    }
  }

  Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;
    try {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      ReportProcessingStore.instance.stop();
      await _pushNotificationService.invalidateSession();
      await _auth.logout();
      if (mounted) {
        setState(() {
          _authView = _AuthView.login;
          _prefillEmail = null;
          _editingProfile = null;
          _activeProfileNameForUpload = '';
          _timelineProfileId = null;
          _timelineProfileName = null;
        });
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Future<void> _requestPasswordReset(String email) async {
    await _auth.requestPasswordReset(email: email);
  }

  Future<void> _confirmPasswordReset(String token, String newPassword) async {
    await _auth.confirmPasswordReset(token: token, newPassword: newPassword);
    if (mounted) {
      setState(() => _authView = _AuthView.login);
    }
  }

  void _showMissingProfileSnackBar({required bool forUpload}) {
    final message = forUpload
        ? 'Create a default profile before uploading a report.'
        : 'Create a default profile before viewing your timeline.';
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    StatusMessenger.showInfoOnMessenger(messenger, message);
  }

  void _showProfileLoadError(String message) {
    final messenger = _scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    StatusMessenger.showErrorOnMessenger(
      messenger,
      message.isNotEmpty ? message : 'Unable to load profiles right now.',
    );
  }

  String _friendlyProfileLoadError(ApiException e, {required bool forUpload}) {
    if (e.code == 'NETWORK_ERROR') {
      return forUpload
          ? 'Cannot upload right now because profile data could not be loaded. Please ensure API server is running and try again.'
          : 'Cannot open timeline right now because profile data could not be loaded. Please ensure API server is running and try again.';
    }
    return e.message.isNotEmpty
        ? e.message
        : 'Unable to load profiles right now. Please try again.';
  }

  Future<Profile?> _getActiveProfileOrNotify({required bool forUpload}) async {
    try {
      final profiles = await _profilesRepository.getProfiles();
      for (final profile in profiles) {
        if (profile.isActive) return profile;
      }
      if (mounted) _showMissingProfileSnackBar(forUpload: forUpload);
      return null;
    } on ApiException catch (e) {
      if (e.code == 'AUTH_UNAUTHORIZED') {
        await _logout();
        return null;
      }
      if (mounted) {
        _showProfileLoadError(
          _friendlyProfileLoadError(e, forUpload: forUpload),
        );
      }
      return null;
    } catch (_) {
      if (mounted) {
        _showProfileLoadError(
          'Unable to load profiles right now. Please try again.',
        );
      }
      return null;
    }
  }

  void _shareReport(Report report) {
    unawaited(
      _openSharedLinks(profileId: report.profileId, reportId: report.id),
    );
  }

  Future<void> _openSharedLinks({String? profileId, String? reportId}) async {
    Profile? profile;
    if (profileId == null) {
      profile = await _getActiveProfileOrNotify(forUpload: false);
    } else {
      try {
        final profiles = await _profilesRepository.getProfiles();
        profile = profiles
            .where((candidate) => candidate.id == profileId)
            .firstOrNull;
      } catch (_) {
        _showProfileLoadError(
          'Unable to load sharing links. Please try again.',
        );
      }
    }
    if (!mounted || profile == null) return;
    await _navigatorKey.currentState?.push<void>(
      MaterialPageRoute(
        builder: (_) => CreateShareLinkScreen(
          profileId: profile!.id,
          profileName: profile.name,
          sharingRepository: _sharingRepository,
          reportsRepository: _reportsRepository,
          supportRepository: _supportRepository,
          onUpgrade: () => setState(() => _authView = _AuthView.billing),
          incidentStatus: _incidentStatus,
          initialReportId: reportId,
        ),
      ),
    );
  }

  void _pushAccountPage(Widget page) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    _navigatorKey.currentState?.push(designPageRoute<void>(page, context));
  }

  void _openExportScreen() => _pushAccountPage(
    DataRightsScreen(
      mode: DataRightsMode.export,
      dataRightsRepository: _dataRightsRepository,
      profilesRepository: _profilesRepository,
      reportsRepository: _reportsRepository,
      onBack: () => _navigatorKey.currentState?.pop(),
      onAccountClosed: _logout,
    ),
  );

  void _openDeleteScreen() => _pushAccountPage(
    DataRightsScreen(
      mode: DataRightsMode.delete,
      dataRightsRepository: _dataRightsRepository,
      profilesRepository: _profilesRepository,
      reportsRepository: _reportsRepository,
      onBack: () => _navigatorKey.currentState?.pop(),
      onOpenExport: _openExportScreen,
      onAccountClosed: () async {
        await _logout();
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      },
    ),
  );

  Future<void> _openChangePasswordScreen() async {
    final navigator = _navigatorKey.currentState;
    final context = _navigatorKey.currentContext;
    if (navigator == null || context == null) return;
    final changed = await navigator.push<bool>(
      designPageRoute<bool>(
        ChangePasswordScreen(authRepository: _auth),
        context,
      ),
    );
    if (changed == true && navigator.mounted) {
      StatusMessenger.showSuccess(navigator.context, 'Password changed');
    }
  }

  Future<void> _openNotificationPreviewSettings() async {
    if (!await openDeviceNotificationSettings()) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Open device Settings to manage notification previews.',
          ),
        ),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    const siteUrl = String.fromEnvironment(
      'PUBLIC_WEB_BASE_URL',
      defaultValue: 'https://doclyzer.com',
    );
    try {
      final opened = await launchUrl(
        Uri.parse('${siteUrl.replaceFirst(RegExp(r'/$'), '')}/privacy-policy'),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (_) {
      // Show the in-app summary when the browser is unavailable.
    }
    if (mounted) _openLegalScreen(LegalSummaryKind.privacy);
  }

  void _openPrivacyScreen() => _pushAccountPage(
    PrivacySecurityScreen(
      appLockEnabled: _appLockEnabled,
      onAppLockChanged: _setAppLockEnabled,
      onSharedLinks: () => unawaited(_openSharedLinks()),
      onExport: _openExportScreen,
      onPrivacyPolicy: () => unawaited(_openPrivacyPolicy()),
      onNotificationSettings: () =>
          unawaited(_openNotificationPreviewSettings()),
      onChangePassword: () => unawaited(_openChangePasswordScreen()),
      onDeleteAccount: _openDeleteScreen,
    ),
  );

  void _openHelpScreen() => _pushAccountPage(
    HelpSupportScreen(supportRepository: _supportRepository),
  );

  void _openLegalScreen(LegalSummaryKind kind) => _pushAccountPage(
    LegalSummaryScreen(
      kind: kind,
      onPrimary: kind == LegalSummaryKind.privacy
          ? _openPrivacyScreen
          : _openHelpScreen,
      onSecondary: kind == LegalSummaryKind.privacy
          ? _openExportScreen
          : () => _openLegalScreen(LegalSummaryKind.privacy),
    ),
  );

  void _openAboutScreen() => _pushAccountPage(
    AboutDoclyzerScreen(
      onTerms: () => _openLegalScreen(LegalSummaryKind.terms),
      onPrivacy: () => _openLegalScreen(LegalSummaryKind.privacy),
    ),
  );

  Future<void> _openNotificationRelated(InboxNotification notification) async {
    final path = Uri.tryParse(notification.deepLink ?? '')?.path ?? '';
    _navigatorKey.currentState?.pop();
    if (path.startsWith('/reports/')) {
      final reportId = path.substring('/reports/'.length);
      try {
        final report = await _reportsRepository.getReport(reportId);
        if (!mounted) return;
        await _navigatorKey.currentState?.push<void>(
          MaterialPageRoute(
            builder: (routeContext) => ReportDetailScreen(
              reportsRepository: _reportsRepository,
              profilesRepository: _profilesRepository,
              reportId: report.id,
              profileId: report.profileId,
              onBack: () => Navigator.of(routeContext).pop(),
              onShareReport: _shareReport,
            ),
          ),
        );
      } catch (_) {
        if (mounted) {
          _showProfileLoadError(
            'Unable to open that report. Try the report library.',
          );
        }
      }
    } else if (path == '/reports') {
      await _selectTab(1);
    } else if (path.startsWith('/shared-links/')) {
      await _openSharedLinks(
        profileId: path.substring('/shared-links/'.length),
      );
    }
  }

  static const _tabViews = [
    _AuthView.home,
    _AuthView.timeline,
    _AuthView.trends,
    _AuthView.profileList,
    _AuthView.accountProfile,
  ];
  int? _pendingTabIndex;
  int _tabRequestSerial = 0;

  Future<void> _selectTab(int index) async {
    final destination = _tabViews[index];
    if (destination == _authView && _pendingTabIndex == null) return;
    final requestId = ++_tabRequestSerial;
    if (destination != _AuthView.timeline && destination != _AuthView.trends) {
      setState(() {
        _pendingTabIndex = null;
        _authView = destination;
      });
      return;
    }

    setState(() => _pendingTabIndex = index);
    final origin = _authView;
    bool isCurrent() =>
        mounted && requestId == _tabRequestSerial && _authView == origin;
    try {
      final restriction = await _restrictionRepository.getStatus();
      if (!isCurrent()) return;
      const action = 'view_timeline';
      if (restriction.isRestricted &&
          (restriction.restrictedActions?.isEmpty ?? true)) {
        _showProfileLoadError(
          'This action is temporarily unavailable while your account is under review.',
        );
        return;
      }
      if (restriction.isRestricted &&
          (restriction.restrictedActions?.contains(action) ?? false)) {
        _showProfileLoadError(
          'This action is temporarily unavailable while your account is under review.',
        );
        return;
      }
      final active = await _getActiveProfileOrNotify(forUpload: false);
      if (!isCurrent() || active == null) return;
      setState(() {
        _timelineProfileId = active.id;
        _timelineProfileName = active.name;
        _pendingTabIndex = null;
        _authView = destination;
      });
    } catch (_) {
      if (isCurrent()) {
        _showProfileLoadError('Unable to open this section. Please try again.');
      }
    } finally {
      if (mounted &&
          requestId == _tabRequestSerial &&
          _pendingTabIndex != null) {
        setState(() => _pendingTabIndex = null);
      }
    }
  }

  Widget _buildNavigationShell(Widget screen) {
    final selected = _tabViews.indexOf(_authView);
    if (selected < 0) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _backFromSecondary();
        },
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_authView), child: screen),
        ),
      );
    }
    return MobileNavigationShell(
      selectedIndex: _pendingTabIndex ?? selected,
      contentIndex: selected,
      isChangingDestination: _pendingTabIndex != null,
      onDestinationSelected: _selectTab,
      onBackToHome: () => setState(() {
        _tabRequestSerial++;
        _pendingTabIndex = null;
        _authView = _AuthView.home;
      }),
      child: screen,
    );
  }

  void _backFromSecondary() {
    if (_authView == _AuthView.uploadReport && _uploadInFlight) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Keep this screen open until the upload is accepted.'),
        ),
      );
      return;
    }
    final target = switch (_authView) {
      _AuthView.signup ||
      _AuthView.onboarding ||
      _AuthView.verification ||
      _AuthView.forgotPassword ||
      _AuthView.resetPassword => _AuthView.login,
      _AuthView.createProfile || _AuthView.editProfile => _AuthView.profileList,
      _AuthView.creditPackList || _AuthView.planSelection => _AuthView.billing,
      _AuthView.profileList => _profileListReturnView,
      _AuthView.sessionList ||
      _AuthView.communicationPreferences ||
      _AuthView.dataRights ||
      _AuthView.billing ||
      _AuthView.referrals => _AuthView.accountProfile,
      _AuthView.uploadReport => _AuthView.home,
      _ => null,
    };
    if (target != null && mounted) setState(() => _authView = target);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_pushNotificationService.flushPendingNavigation());
    });
    if (!_initialized || !_appLockPreferenceLoaded) {
      return MaterialApp(
        title: 'Doclyzer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemBars(Theme.of(context).brightness),
          child: child ?? const SizedBox.shrink(),
        ),
        home: const StartupLoadingScreen(),
      );
    }

    return MaterialApp(
      title: 'Doclyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      navigatorKey: _navigatorKey,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.systemBars(Theme.of(context).brightness),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNotificationFrame(
              uploadNotice: _hasInterruptedUpload && _authView == _AuthView.home
                  ? Material(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      child: SafeArea(
                        bottom: false,
                        child: ListTile(
                          title: const Text(
                            'An upload may have been interrupted',
                          ),
                          subtitle: const Text(
                            'Check Reports. If it is missing, add the same file again.',
                          ),
                          onTap: () => unawaited(_selectTab(1)),
                          trailing: IconButton(
                            tooltip: 'Dismiss upload notice',
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              await _tokenStorage
                                  .clearInterruptedReportUpload();
                              if (mounted) {
                                setState(() => _hasInterruptedUpload = false);
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  : null,
              readyNotice: AnimatedBuilder(
                animation: ReportProcessingStore.instance,
                builder: (context, _) {
                  final store = ReportProcessingStore.instance;
                  return store.readyCount > 0
                      ? Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          child: SafeArea(
                            bottom: false,
                            child: ListTile(
                              title: Text(
                                '${store.readyCount} report(s) ready',
                              ),
                              trailing: IconButton(
                                tooltip: 'Dismiss ready notifications',
                                icon: const Icon(Icons.close),
                                onPressed: () async {
                                  final ids = store.reports.entries
                                      .where(
                                        (e) =>
                                            e.value['status'] == 'ready' &&
                                            e.value['acknowledgedAt'] == null,
                                      )
                                      .map((e) => e.key)
                                      .toList();
                                  try {
                                    for (final id in ids) {
                                      await store.acknowledge(id);
                                    }
                                  } catch (_) {
                                    _scaffoldMessengerKey.currentState
                                        ?.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Could not dismiss notifications. Try again.',
                                            ),
                                          ),
                                        );
                                  }
                                },
                              ),
                              onTap: () {
                                final ready = store.reports.values.firstWhere(
                                  (r) =>
                                      r['status'] == 'ready' &&
                                      r['acknowledgedAt'] == null,
                                );
                                _pushNotificationService.onReportOpen?.call(
                                  ready['reportId'] as String,
                                );
                              },
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
              child: child ?? const SizedBox.shrink(),
            ),
            if ((_appLocked || _appLockLoadError) &&
                _authView != _AuthView.login &&
                _authView != _AuthView.onboarding &&
                _authView != _AuthView.signup)
              Positioned.fill(
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const DoclyzerMark(size: 72),
                            const SizedBox(height: 24),
                            Text(
                              _appLockLoadError
                                  ? 'App lock is unavailable'
                                  : 'Doclyzer is locked',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _appLockLoadError
                                  ? 'Could not read the saved App lock setting. Retry to continue.'
                                  : 'Use your device passcode or biometrics to continue.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 28),
                            FilledButton(
                              key: Key(
                                _appLockLoadError
                                    ? 'retry-app-lock'
                                    : 'unlock-app',
                              ),
                              onPressed: _unlocking
                                  ? null
                                  : _appLockLoadError
                                  ? _restoreAppLock
                                  : _unlockApp,
                              child: _unlocking
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      _appLockLoadError ? 'Retry' : 'Unlock',
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      home: _buildNavigationShell(switch (_authView) {
        _AuthView.onboarding => OnboardingScreen(
          onComplete: () => unawaited(_finishOnboarding()),
        ),
        _AuthView.sessionUnavailable => Scaffold(
          appBar: AppBar(title: const Text('Connection unavailable')),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_outlined, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Your session could not be checked. Connect to the internet and try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retrySession,
                      child: const Text('Try again'),
                    ),
                    TextButton(
                      onPressed: _logout,
                      child: const Text('Sign in with another account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _AuthView.login => LoginScreen(
          onLogin: _login,
          onGoToSignup: () {
            setState(() => _authView = _AuthView.signup);
          },
          onGoToForgotPassword: () {
            setState(() => _authView = _AuthView.forgotPassword);
          },
          initialEmail: _prefillEmail,
          supportRepository: _supportRepository,
        ),
        _AuthView.signup => SignupScreen(
          onSignup: _register,
          onGoToLogin: () {
            setState(() => _authView = _AuthView.login);
          },
        ),
        _AuthView.verification => VerificationScreen(
          onContinueToLogin: () {
            setState(() => _authView = _AuthView.login);
          },
        ),
        _AuthView.home => HomeScreen(
          onShareReport: _shareReport,
          shouldOfferPushPermission: () async {
            if (_pushPermissionPromptHandled) return false;
            return _pushNotificationService.shouldOfferPermissionPrompt();
          },
          shouldOpenPushPermissionSettings: () =>
              _pushNotificationService.shouldOpenPermissionSettings(),
          onEnablePushPermission: () async {
            final granted = await _pushNotificationService.requestPermission();
            _pushPermissionPromptHandled = true;
            return granted;
          },
          onOpenPushSettings: () async {
            final opened = await openDeviceNotificationSettings();
            if (opened) _pushPermissionPromptHandled = true;
            return opened;
          },
          onPushPermissionPromptHandled: () {
            _pushPermissionPromptHandled = true;
          },
          onGoToNotifications: () {
            _navigatorKey.currentState?.push<void>(
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(
                  repository: _notificationsRepository,
                  onBack: () => _navigatorKey.currentState?.pop(),
                  onOpenRelated: _openNotificationRelated,
                  onManagePreferences: () {
                    _navigatorKey.currentState?.pop();
                    if (mounted) {
                      setState(
                        () => _authView = _AuthView.communicationPreferences,
                      );
                    }
                  },
                ),
              ),
            );
          },
          accountRepository: _accountRepository,
          reportsRepository: _reportsRepository,
          profilesRepository: _profilesRepository,
          billingRepository: _billingRepository,
          onLogout: _logout,
          onGoToAccount: () {
            setState(() => _authView = _AuthView.accountProfile);
          },
          onGoToProfiles: () {
            setState(() {
              _profileListReturnView = _AuthView.home;
              _authView = _AuthView.profileList;
            });
          },
          onGoToSessions: () {
            setState(() => _authView = _AuthView.sessionList);
          },
          onGoToCommunicationPreferences: () {
            setState(() => _authView = _AuthView.communicationPreferences);
          },
          onGoToDataRights: () {
            setState(() => _authView = _AuthView.dataRights);
          },
          onGoToUploadReport: () async {
            final active = await _getActiveProfileOrNotify(forUpload: true);
            if (active == null) {
              return;
            }
            if (!mounted) return;
            final activeProfile = active;
            setState(() {
              _authView = _AuthView.uploadReport;
              _activeProfileNameForUpload = activeProfile.name;
            });
          },
          onGoToBilling: () {
            setState(() => _authView = _AuthView.billing);
          },
          onGoToReferrals: () {
            setState(() => _authView = _AuthView.referrals);
          },
          onGoToTimeline: () async {
            final active = await _getActiveProfileOrNotify(forUpload: false);
            if (active == null) {
              return;
            }
            if (!mounted) return;
            final activeProfile = active;
            setState(() {
              _authView = _AuthView.timeline;
              _timelineProfileId = activeProfile.id;
              _timelineProfileName = activeProfile.name;
            });
          },
          onGoToTrends: () => unawaited(_selectTab(2)),
          restrictionRepository: _restrictionRepository,
          incidentStatus: _incidentStatus,
        ),
        _AuthView.accountProfile => AccountProfileScreen(
          supportRepository: _supportRepository,
          onGoToPrivacy: _openPrivacyScreen,
          onGoToExport: _openExportScreen,
          onGoToHelp: _openHelpScreen,
          onGoToAbout: _openAboutScreen,
          onGoToSharedLinks: () => unawaited(_openSharedLinks()),
          themeMode: _themeMode,
          onThemeChanged: _savingAppearance ? null : _changeAppearance,
          billingRepository: _billingRepository,
          onGoToProfiles: () => setState(() {
            _profileListReturnView = _AuthView.accountProfile;
            _authView = _AuthView.profileList;
          }),
          onGoToBilling: () => setState(() => _authView = _AuthView.billing),
          onGoToReferrals: () =>
              setState(() => _authView = _AuthView.referrals),
          onGoToSessions: () =>
              setState(() => _authView = _AuthView.sessionList),
          onGoToNotifications: () =>
              setState(() => _authView = _AuthView.communicationPreferences),
          onGoToDataRights: () =>
              setState(() => _authView = _AuthView.dataRights),
          onLogout: _logout,
          showBackButton: false,
          accountRepository: _accountRepository,
          restrictionRepository: _restrictionRepository,
          onBack: () {
            setState(() => _authView = _AuthView.home);
          },
        ),
        _AuthView.forgotPassword => ForgotPasswordScreen(
          onSubmit: _requestPasswordReset,
          onGoToLogin: () {
            setState(() => _authView = _AuthView.login);
          },
          onResetSent: () {
            setState(() => _authView = _AuthView.resetPassword);
          },
        ),
        _AuthView.resetPassword => ResetPasswordScreen(
          onReset: _confirmPasswordReset,
          onGoToLogin: () {
            setState(() => _authView = _AuthView.login);
          },
        ),
        _AuthView.sessionList => SessionListScreen(
          sessionsRepository: _sessionsRepository,
          onLogout: _logout,
          onBack: () {
            setState(() => _authView = _AuthView.accountProfile);
          },
        ),
        _AuthView.profileList => ProfileListScreen(
          showBackButton: false,
          profilesRepository: _profilesRepository,
          reportsRepository: _reportsRepository,
          onCreateProfile: () {
            setState(() {
              _editingProfile = null;
              _authView = _AuthView.createProfile;
            });
          },
          onEditProfile: (profile) {
            setState(() {
              _editingProfile = profile;
              _authView = _AuthView.editProfile;
            });
          },
          onOpenProfileReports: (profile) {
            setState(() {
              _timelineProfileId = profile.id;
              _timelineProfileName = profile.name;
              _authView = _AuthView.timeline;
            });
          },
          onBack: () {
            setState(() => _authView = _profileListReturnView);
          },
        ),
        _AuthView.createProfile => CreateEditProfileScreen(
          profilesRepository: _profilesRepository,
          onComplete: () {
            setState(() => _authView = _AuthView.profileList);
          },
          onBack: () {
            setState(() => _authView = _AuthView.profileList);
          },
        ),
        _AuthView.editProfile => CreateEditProfileScreen(
          profilesRepository: _profilesRepository,
          existingProfile: _editingProfile,
          onComplete: () {
            setState(() {
              _editingProfile = null;
              _authView = _AuthView.profileList;
            });
          },
          onBack: () {
            setState(() {
              _editingProfile = null;
              _authView = _AuthView.profileList;
            });
          },
        ),
        _AuthView.communicationPreferences => CommunicationPreferencesScreen(
          onEnablePush: () async {
            if (await _pushNotificationService.shouldOpenPermissionSettings()) {
              final opened = await openDeviceNotificationSettings();
              return opened
                  ? DeviceNotificationActionResult.settingsOpened
                  : DeviceNotificationActionResult.denied;
            }
            final granted = await _pushNotificationService.requestPermission();
            return granted
                ? DeviceNotificationActionResult.enabled
                : DeviceNotificationActionResult.denied;
          },
          getPushEnabled: _pushNotificationService.isPermissionGranted,
          onMarketingChanged: _pushNotificationService.setMarketingConsent,
          communicationPreferencesRepository:
              _communicationPreferencesRepository,
          onBack: () {
            setState(() => _authView = _AuthView.accountProfile);
          },
          supportRepository: _supportRepository,
        ),
        _AuthView.dataRights => DataRightsScreen(
          dataRightsRepository: _dataRightsRepository,
          onBack: () {
            setState(() => _authView = _AuthView.accountProfile);
          },
          onAccountClosed: () async {
            await _logout();
          },
          onAccountRestored: () async {
            _startReportServices();
            if (mounted) setState(() => _authView = _AuthView.home);
          },
        ),
        _AuthView.uploadReport => UploadReportScreen(
          onShareReport: _shareReport,
          reportsRepository: _reportsRepository,
          profilesRepository: _profilesRepository,
          activeProfileName: _activeProfileNameForUpload,
          incidentStatus: _incidentStatus,
          onBack: _backFromSecondary,
          onUploadBusyChanged: (busy) => _uploadInFlight = busy,
          onUploadAccepted: () {
            if (mounted) setState(() => _hasInterruptedUpload = false);
          },
          onComplete: () {
            setState(() => _authView = _AuthView.home);
          },
          onUpgrade: () {
            setState(() => _authView = _AuthView.billing);
          },
          supportRepository: _supportRepository,
        ),
        _AuthView.timeline =>
          _timelineProfileId != null
              ? TimelineScreen(
                  onShareReport: _shareReport,
                  showBackButton: true,
                  reportsRepository: _reportsRepository,
                  profilesRepository: _profilesRepository,
                  profileId: _timelineProfileId!,
                  profileName: _timelineProfileName!,
                  onProfileSelected: (profile) => setState(() {
                    _timelineProfileId = profile.id;
                    _timelineProfileName = profile.name;
                  }),
                  sharingRepository: _sharingRepository,
                  incidentStatus: _incidentStatus,
                  onBack: () {
                    setState(() => _authView = _AuthView.home);
                  },
                  onUploadReport: () async {
                    try {
                      final restriction = await _restrictionRepository
                          .getStatus();
                      if (!mounted) return;
                      if (restriction.isRestricted &&
                          ((restriction.restrictedActions?.isEmpty ?? true) ||
                              (restriction.restrictedActions?.contains(
                                    'upload_report',
                                  ) ??
                                  false))) {
                        _showProfileLoadError(
                          restriction.nextSteps?.trim().isNotEmpty == true
                              ? restriction.nextSteps!
                              : 'Uploads are temporarily unavailable while your account is under review.',
                        );
                        return;
                      }
                      final active = await _getActiveProfileOrNotify(
                        forUpload: true,
                      );
                      if (!mounted || active == null) return;
                      setState(() {
                        _activeProfileNameForUpload = active.name;
                        _authView = _AuthView.uploadReport;
                      });
                    } catch (_) {
                      if (mounted) {
                        _showProfileLoadError(
                          'Unable to start an upload. Please try again.',
                        );
                      }
                    }
                  },
                  onUpgrade: () {
                    setState(() => _authView = _AuthView.billing);
                  },
                  supportRepository: _supportRepository,
                )
              : const Scaffold(body: Center(child: Text('No active profile'))),
        _AuthView.trends =>
          _timelineProfileId != null
              ? HealthHistoryScreen(
                  onShareReport: _shareReport,
                  profileId: _timelineProfileId!,
                  profileName: _timelineProfileName,
                  reportsRepository: _reportsRepository,
                  profilesRepository: _profilesRepository,
                  onBack: () => setState(() => _authView = _AuthView.home),
                )
              : const Scaffold(body: Center(child: Text('No active profile'))),
        _AuthView.billing => EntitlementSummaryScreen(
          billingRepository: _billingRepository,
          incidentStatus: _incidentStatus,
          onBack: () {
            setState(() => _authView = _AuthView.accountProfile);
          },
          onBuyCredits: () {
            setState(() => _authView = _AuthView.creditPackList);
          },
          onUpgrade: () {
            setState(() => _authView = _AuthView.planSelection);
          },
        ),
        _AuthView.referrals => ReferralDashboardScreen(
          referralsRepository: _referralsRepository,
          onBack: () {
            setState(() => _authView = _AuthView.accountProfile);
          },
        ),
        _AuthView.creditPackList => CreditPackListScreen(
          billingRepository: _billingRepository,
          incidentStatus: _incidentStatus,
          onBack: () {
            setState(() => _authView = _AuthView.billing);
          },
          onPurchaseComplete: () {
            setState(() => _authView = _AuthView.billing);
          },
          supportRepository: _supportRepository,
        ),
        _AuthView.planSelection => PlanSelectionScreen(
          billingRepository: _billingRepository,
          incidentStatus: _incidentStatus,
          onBack: () {
            setState(() => _authView = _AuthView.billing);
          },
          onSubscribeComplete: () {
            setState(() => _authView = _AuthView.billing);
          },
          supportRepository: _supportRepository,
        ),
      }),
    );
  }
}
