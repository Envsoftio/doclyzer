import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/api_config.dart';
import 'core/token_storage.dart';
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

  @override
  State<DoclyzerApp> createState() => _DoclyzerAppState();
}

class _DoclyzerAppState extends State<DoclyzerApp> {
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

  _AuthView _authView = _AuthView.login;
  String? _prefillEmail;
  Profile? _editingProfile;
  String _activeProfileNameForUpload = '';
  String? _timelineProfileId;
  String? _timelineProfileName;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.authRepository != null) {
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
      setState(() => _initialized = true);
    } else {
      final tokenStorage = TokenStorage();
      _apiClient = ApiClient(
        baseUrl: apiBaseUrl,
        onRefreshToken: () => _authRepository!.refreshTokens(),
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
      _initAuth();
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            final profiles = await _profilesRepository.getProfiles();
            Profile? active;
            for (final p in profiles) {
              if (p.isActive) {
                active = p;
                break;
              }
            }
            if (active == null) {
              if (mounted) _showMissingProfileSnackBar(forUpload: true);
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
            final profiles = await _profilesRepository.getProfiles();
            Profile? active;
            for (final p in profiles) {
              if (p.isActive) {
                active = p;
                break;
              }
            }
            if (active == null) {
              if (mounted) _showMissingProfileSnackBar(forUpload: false);
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
          onBack: () {
            setState(() => _authView = _AuthView.home);
          },
          onComplete: () {
            setState(() => _authView = _AuthView.home);
          },
          onUpgrade: () {
            setState(() => _authView = _AuthView.billing);
          },
        ),
        _AuthView.timeline =>
          _timelineProfileId != null
              ? TimelineScreen(
                  reportsRepository: _reportsRepository,
                  profilesRepository: _profilesRepository,
                  profileId: _timelineProfileId!,
                  profileName: _timelineProfileName!,
                  sharingRepository: _sharingRepository,
                  onBack: () {
                    setState(() => _authView = _AuthView.home);
                  },
                  onUpgrade: () {
                    setState(() => _authView = _AuthView.billing);
                  },
                )
              : const Scaffold(body: Center(child: Text('No active profile'))),
        _AuthView.billing => EntitlementSummaryScreen(
          billingRepository: _billingRepository,
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
          onBack: () {
            setState(() => _authView = _AuthView.billing);
          },
          onPurchaseComplete: () {
            setState(() => _authView = _AuthView.billing);
          },
        ),
        _AuthView.planSelection => PlanSelectionScreen(
          billingRepository: _billingRepository,
          onBack: () {
            setState(() => _authView = _AuthView.billing);
          },
          onSubscribeComplete: () {
            setState(() => _authView = _AuthView.billing);
          },
        ),
      },
    );
  }
}
