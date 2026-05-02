import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/api_config.dart';
import 'core/feedback/status_messenger.dart';
import 'core/theme/app_theme.dart';
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
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/session_list_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/verification_screen.dart';
import 'features/profiles/profiles_repository.dart';
import 'features/profiles/api_profiles_repository.dart';
import 'features/profiles/screens/create_edit_profile_screen.dart';
import 'features/profiles/screens/profile_list_screen.dart';
import 'features/reports/reports_repository.dart';
import 'features/reports/api_reports_repository.dart';
import 'features/reports/screens/timeline_screen.dart';
import 'features/reports/screens/upload_report_screen.dart';
import 'features/billing/billing_repository.dart';
import 'features/billing/api_billing_repository.dart';
import 'features/billing/screens/credit_pack_list_screen.dart';
import 'features/billing/screens/entitlement_summary_screen.dart';
import 'features/billing/screens/plan_selection_screen.dart';
import 'features/sharing/sharing_repository.dart';
import 'features/sharing/api_sharing_repository.dart';
import 'features/support/api_support_repository.dart';
import 'features/support/support_repository.dart';

void main() {
  runApp(const DoclyzerApp());
}

enum _AuthView {
  login,
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
  billing,
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
    this.incidentRepository,
    this.supportRepository,
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
  final IncidentRepository? incidentRepository;
  final SupportRepository? supportRepository;

  @override
  State<DoclyzerApp> createState() => _DoclyzerAppState();
}

class _DoclyzerAppState extends State<DoclyzerApp> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  ApiClient? _apiClient;
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
  late final IncidentRepository _incidentRepository;
  late final SupportRepository _supportRepository;

  _AuthView _authView = _AuthView.login;
  String? _prefillEmail;
  Profile? _editingProfile;
  String _activeProfileNameForUpload = '';
  String? _timelineProfileId;
  String? _timelineProfileName;
  bool _initialized = false;
  bool _isHandlingUnauthorized = false;
  PublicIncidentStatus? _incidentStatus;
  DateTime? _incidentFetchedAt;

  static const Duration _incidentCacheTtl = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.authRepository != null) {
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
      _incidentRepository =
          widget.incidentRepository ?? ApiIncidentRepository(_apiClient!);
      _supportRepository =
          widget.supportRepository ?? ApiSupportRepository(_apiClient!);
      setState(() => _initialized = true);
      _refreshIncidentStatus(force: true);
    } else {
      final tokenStorage = TokenStorage();
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
      _reportsRepository = ApiReportsRepository(_apiClient!);
      _sharingRepository =
          widget.sharingRepository ?? ApiSharingRepository(_apiClient!);
      _billingRepository =
          widget.billingRepository ?? ApiBillingRepository(_apiClient!);
      _incidentRepository =
          widget.incidentRepository ?? ApiIncidentRepository(_apiClient!);
      _supportRepository =
          widget.supportRepository ?? ApiSupportRepository(_apiClient!);
      _initAuth();
      _refreshIncidentStatus(force: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIncidentStatus();
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
    final restored = await _authRepository!.restoreSession();
    if (restored && mounted) {
      setState(() {
        _authView = _AuthView.home;
        _initialized = true;
      });
    } else if (mounted) {
      setState(() => _initialized = true);
    }
  }

  AuthRepository get _auth => _authRepository ?? widget.authRepository!;

  Future<void> _register(String email, String password) async {
    final result = await _auth.register(email: email, password: password);

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

  Future<void> _login(String email, String password) async {
    await _auth.login(email: email, password: password);
    if (mounted) {
      setState(() => _authView = _AuthView.home);
    }
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) {
      setState(() => _authView = _AuthView.login);
    }
  }

  Future<void> _handleUnauthorized() async {
    if (_isHandlingUnauthorized) return;
    _isHandlingUnauthorized = true;
    try {
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

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Doclyzer',
      theme: AppTheme.light,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: switch (_authView) {
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
          onLogout: _logout,
          onGoToAccount: () {
            setState(() => _authView = _AuthView.accountProfile);
          },
          onGoToProfiles: () {
            setState(() => _authView = _AuthView.profileList);
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
          restrictionRepository: _restrictionRepository,
          incidentStatus: _incidentStatus,
        ),
        _AuthView.accountProfile => AccountProfileScreen(
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
            setState(() => _authView = _AuthView.home);
          },
        ),
        _AuthView.profileList => ProfileListScreen(
          profilesRepository: _profilesRepository,
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
          onBack: () {
            setState(() => _authView = _AuthView.home);
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
          communicationPreferencesRepository:
              _communicationPreferencesRepository,
          onBack: () {
            setState(() => _authView = _AuthView.home);
          },
          supportRepository: _supportRepository,
        ),
        _AuthView.dataRights => DataRightsScreen(
          dataRightsRepository: _dataRightsRepository,
          onBack: () {
            setState(() => _authView = _AuthView.home);
          },
          onAccountClosed: () async {
            await _logout();
          },
        ),
        _AuthView.uploadReport => UploadReportScreen(
          reportsRepository: _reportsRepository,
          activeProfileName: _activeProfileNameForUpload,
          incidentStatus: _incidentStatus,
          onBack: () {
            setState(() => _authView = _AuthView.home);
          },
          onComplete: () {
            setState(() => _authView = _AuthView.home);
          },
          onGoToTimeline: () async {
            final active = await _getActiveProfileOrNotify(forUpload: false);
            if (active == null || !mounted) return;
            setState(() {
              _authView = _AuthView.timeline;
              _timelineProfileId = active.id;
              _timelineProfileName = active.name;
            });
          },
          onUpgrade: () {
            setState(() => _authView = _AuthView.billing);
          },
          supportRepository: _supportRepository,
        ),
        _AuthView.timeline =>
          _timelineProfileId != null
              ? TimelineScreen(
                  reportsRepository: _reportsRepository,
                  profilesRepository: _profilesRepository,
                  profileId: _timelineProfileId!,
                  profileName: _timelineProfileName!,
                  sharingRepository: _sharingRepository,
                  incidentStatus: _incidentStatus,
                  onBack: () {
                    setState(() => _authView = _AuthView.home);
                  },
                  onUpgrade: () {
                    setState(() => _authView = _AuthView.billing);
                  },
                  supportRepository: _supportRepository,
                )
              : const Scaffold(body: Center(child: Text('No active profile'))),
        _AuthView.billing => EntitlementSummaryScreen(
          billingRepository: _billingRepository,
          incidentStatus: _incidentStatus,
          onBack: () {
            setState(() => _authView = _AuthView.home);
          },
          onBuyCredits: () {
            setState(() => _authView = _AuthView.creditPackList);
          },
          onUpgrade: () {
            setState(() => _authView = _AuthView.planSelection);
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
      },
    );
  }
}
