import '../../reports/report_processing_store.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';

import '../../reports/reports_repository.dart';
import '../../reports/screens/report_detail_screen.dart';
import '../../reports/screens/trend_chart_screen.dart';
import '../../profiles/profiles_repository.dart';
import '../../billing/billing_repository.dart';
import '../../account/account_repository.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';
import '../../../core/feedback/status_messenger.dart';
import '../../../core/feedback/incident_banner.dart';
import '../../../core/api_client.dart';
import '../../../features/account/restriction_repository.dart';
import '../../../features/incidents/incident_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onLogout,
    required this.onGoToAccount,
    required this.onGoToProfiles,
    required this.onGoToSessions,
    required this.onGoToCommunicationPreferences,
    required this.onGoToDataRights,
    required this.onGoToUploadReport,
    required this.onGoToTimeline,
    this.onGoToTrends,
    this.onGoToNotifications,
    required this.onGoToBilling,
    required this.onGoToReferrals,
    required this.restrictionRepository,
    required this.reportsRepository,
    required this.profilesRepository,
    required this.billingRepository,
    required this.accountRepository,
    this.incidentStatus,
    this.onShareReport,
  });

  final Future<void> Function() onLogout;
  final VoidCallback onGoToAccount;
  final VoidCallback onGoToProfiles;
  final VoidCallback onGoToSessions;
  final VoidCallback onGoToCommunicationPreferences;
  final VoidCallback onGoToDataRights;
  final Future<void> Function() onGoToUploadReport;
  final Future<void> Function() onGoToTimeline;
  final VoidCallback? onGoToTrends;
  final VoidCallback? onGoToNotifications;
  final VoidCallback onGoToBilling;
  final VoidCallback onGoToReferrals;
  final RestrictionRepository restrictionRepository;
  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final BillingRepository billingRepository;
  final AccountRepository accountRepository;
  final PublicIncidentStatus? incidentStatus;
  final ValueChanged<Report>? onShareReport;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _defaultBlockedMessage =
      'This action is temporarily unavailable while your account is under review.';
  static const String _uploadBlockedFallbackMessage =
      'You have used all available upload credits. Visit Plan & Credits to add more.';

  RestrictionStatus? _restrictionStatus;
  List<Report>? _reports;
  Profile? _activeProfile;
  List<TrendParameter> _latestTrends = [];
  AccountProfile? _accountProfile;
  bool _loading = true;
  bool _loadFailed = false;

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    await _loadRestrictionStatus();
    if (!mounted) return;
    await Future.wait([
      _loadAccountProfile(),
      _loadSection(() async {
        if (_isActionBlocked('view_timeline')) {
          if (mounted) setState(() => _reports = null);
          return;
        }
        final profiles = await widget.profilesRepository.getProfiles();
        final active = profiles.where((p) => p.isActive).firstOrNull;
        if (active == null) {
          if (mounted) {
            setState(() {
              _activeProfile = null;
              _reports = [];
              _latestTrends = [];
            });
          }
          return;
        }
        final reports = await widget.reportsRepository.listReports(active.id);
        reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        List<TrendParameter> trends = [];
        try {
          final result = await widget.reportsRepository.getLabTrends(active.id);
          trends =
              result.parameters.where((p) => p.dataPoints.isNotEmpty).toList()
                ..sort(
                  (a, b) =>
                      b.dataPoints.last.date.compareTo(a.dataPoints.last.date),
                );
        } catch (_) {
          // The report library remains available if trends cannot be fetched.
        }
        if (mounted) {
          setState(() {
            _activeProfile = active;
            _reports = reports;
            _latestTrends = trends;
          });
        }
      }),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadAccountProfile() async {
    try {
      final profile = await widget.accountRepository.getProfile();
      if (mounted) setState(() => _accountProfile = profile);
    } on ApiException catch (error) {
      if (error.code == 'AUTH_UNAUTHORIZED' && mounted) {
        await widget.onLogout();
      }
    } catch (_) {
      // Reports remain usable if account details cannot load.
    }
  }

  Future<void> _loadSection(Future<void> Function() load) async {
    try {
      await load();
    } catch (error) {
      if (!mounted) return;
      if (error is ApiException && error.code == 'AUTH_UNAUTHORIZED') {
        await widget.onLogout();
        return;
      }
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _openTimeline() async {
    if (_isActionBlocked('view_timeline')) {
      _showBlockedMessage();
      return;
    }
    await widget.onGoToTimeline();
  }

  Future<void> _openReport(Report report) async {
    if (_isActionBlocked('view_timeline')) {
      _showBlockedMessage();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => ReportDetailScreen(
          reportsRepository: widget.reportsRepository,
          profilesRepository: widget.profilesRepository,
          reportId: report.id,
          profileId: report.profileId,
          onBack: () => Navigator.of(routeContext).pop(),
          onShareReport: widget.onShareReport,
        ),
      ),
    );
    if (mounted) await _refresh();
  }

  Future<void> _upload() async {
    if (_isActionBlocked('upload_report')) {
      _showBlockedMessage(fallbackMessage: _uploadBlockedFallbackMessage);
      return;
    }
    await widget.onGoToUploadReport();
  }

  Future<void> _selectProfile() async {
    try {
      final profiles = await widget.profilesRepository.getProfiles();
      if (!mounted) return;
      final selected = await showModalBottomSheet<Profile>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text(
                  'Switch profile',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              for (final profile in profiles)
                ListTile(
                  title: Text(profile.name),
                  subtitle: Text(
                    profile.isActive ? 'Current profile' : 'View this profile',
                  ),
                  leading: CircleAvatar(child: Text(_initials(profile.name))),
                  trailing: profile.isActive
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(profile),
                ),
              ListTile(
                leading: const Icon(Icons.person_add_outlined),
                title: const Text('Manage family'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  widget.onGoToProfiles();
                },
              ),
            ],
          ),
        ),
      );
      if (selected != null && !selected.isActive) {
        await widget.profilesRepository.activateProfile(selected.id);
        if (!mounted) return;
        setState(() {
          _activeProfile = selected;
          _reports = null;
          _latestTrends = [];
        });
        await _refresh();
        if (mounted && !_loadFailed) {
          StatusMessenger.showSuccess(context, 'Switched to ${selected.name}');
        }
      }
    } catch (error) {
      if (mounted) {
        StatusMessenger.showError(
          context,
          error is ApiException && error.message.isNotEmpty
              ? 'Unable to switch profiles. ${error.message}'
              : 'Unable to switch profiles. Please try again.',
        );
      }
    }
  }

  String _initials(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  void _openTrend(TrendParameter parameter) {
    final profile = _activeProfile;
    if (profile == null) return;
    Navigator.of(context).push(
      designPageRoute(
        TrendChartScreen(
          reportsRepository: widget.reportsRepository,
          profileId: profile.id,
          parameterName: parameter.parameterName,
          unit: parameter.unit ?? '',
          onBack: () => Navigator.of(context).pop(),
          onOpenReport: (reportId) async {
            try {
              final report = await widget.reportsRepository.getReport(reportId);
              if (mounted) await _openReport(report);
            } catch (_) {
              if (mounted) {
                StatusMessenger.showError(
                  context,
                  'Unable to open source report.',
                );
              }
            }
          },
        ),
        context,
      ),
    );
  }

  bool _isActionBlocked(String action) {
    final status = _restrictionStatus;
    if (status == null || !status.isRestricted) {
      return false;
    }
    final configuredActions = status.restrictedActions;
    if (configuredActions == null || configuredActions.isEmpty) {
      return true;
    }
    return configuredActions.contains(action);
  }

  void _showBlockedMessage({String? fallbackMessage}) {
    final status = _restrictionStatus;
    final nextSteps = status?.nextSteps?.trim();
    final rationale = status?.rationale?.trim();
    final defaultMessage = fallbackMessage ?? _defaultBlockedMessage;
    final message = (nextSteps != null && nextSteps.isNotEmpty)
        ? nextSteps
        : ((rationale != null && rationale.isNotEmpty)
              ? rationale
              : defaultMessage);
    StatusMessenger.showWarning(context, message);
  }

  void _processingChanged() {
    if (mounted) _refresh();
  }

  @override
  void dispose() {
    ReportProcessingStore.instance.removeListener(_processingChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ReportProcessingStore.instance.addListener(_processingChanged);
    _refresh();
  }

  Future<void> _loadRestrictionStatus() async {
    try {
      final status = await widget.restrictionRepository.getStatus();
      if (mounted) {
        setState(() {
          _restrictionStatus = status;
        });
      }
    } on ApiException catch (e) {
      if (e.code == 'AUTH_UNAUTHORIZED' && mounted) {
        await widget.onLogout();
      }
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final reports = _reports;
    final profile = _activeProfile;
    final incident = widget.incidentStatus;
    final latest = _latestTrends.take(2).toList();
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: _selectProfile,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 21,
                                        backgroundColor:
                                            colors.primaryContainer,
                                        child: Text(
                                          profile == null
                                              ? 'D'
                                              : _initials(profile.name),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    colors.onPrimaryContainer,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profile?.name ??
                                                  _accountProfile
                                                      ?.displayName ??
                                                  'Your profile',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(fontSize: 15),
                                            ),
                                            Text(
                                              profile == null
                                                  ? 'Choose a profile'
                                                  : 'Your profile',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton.filledTonal(
                                tooltip: 'Notifications',
                                onPressed:
                                    widget.onGoToNotifications ??
                                    widget.onGoToCommunicationPreferences,
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'A little clarity.\nAll in one place.',
                            style: theme.textTheme.displaySmall?.copyWith(
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (incident != null &&
                              incident.isActive &&
                              incident.affectsSurface('mobile_app')) ...[
                            IncidentBanner(incident: incident),
                            const SizedBox(height: 16),
                          ],
                          if (_restrictionStatus?.isRestricted ?? false) ...[
                            _RestrictionBanner(
                              rationale: _restrictionStatus?.rationale ?? '',
                              nextSteps: _restrictionStatus?.nextSteps ?? '',
                            ),
                            const SizedBox(height: 16),
                          ],
                          Container(
                            width: double.infinity,
                            height: 143,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [AppColors.blue, Color(0xFF168F9F)],
                                begin: Alignment.centerLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.antiAlias,
                              children: [
                                Positioned(
                                  right: -28,
                                  top: -20,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.teal.withValues(
                                        alpha: .48,
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  right: 34,
                                  top: 27,
                                  child: Icon(
                                    Icons.note_add_outlined,
                                    size: 44,
                                    color: Colors.white,
                                  ),
                                ),
                                const Positioned(
                                  left: 20,
                                  top: 20,
                                  child: Text(
                                    'Your next report,\nready when you are.',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  left: 20,
                                  top: 74,
                                  child: Text(
                                    'PDFs, photos and family records.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFDDEEF2),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  bottom: 16,
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9),
                                    child: InkWell(
                                      key: const Key('go-to-upload-report'),
                                      onTap: _upload,
                                      borderRadius: BorderRadius.circular(9),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              size: 16,
                                              color: AppColors.blue,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              'Upload report',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: AppColors.blue,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          DesignSectionHeading(
                            title: 'Recent report',
                            action: 'View all',
                            onAction: _openTimeline,
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 220),
                            child: _loading && reports == null
                                ? const Card(
                                    key: Key('home-loading'),
                                    child: SizedBox(
                                      height: 120,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  )
                                : _loadFailed && reports == null
                                ? Card(
                                    key: const Key('home-error'),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Reports are unavailable. Try again when connected.',
                                          ),
                                          TextButton(
                                            onPressed: _refresh,
                                            child: const Text('Try again'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : reports == null || reports.isEmpty
                                ? Card(
                                    key: const Key('home-empty'),
                                    child: DesignEmptyState(
                                      icon: Icons.folder_open_outlined,
                                      title: 'Your story starts here',
                                      message:
                                          'Upload your first report to begin a clear history of your records.',
                                      action: 'Upload your first report',
                                      onAction: _upload,
                                    ),
                                  )
                                : DesignReportCard(
                                    key: ValueKey(reports.first.id),
                                    report: reports.first,
                                    onTap: () => _openReport(reports.first),
                                  ),
                          ),
                          if (reports != null && reports.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            DesignSectionHeading(
                              title: 'Latest results',
                              action: 'All trends',
                              onAction: widget.onGoToTrends ?? _openTimeline,
                            ),
                            const SizedBox(height: 8),
                            if (latest.isEmpty)
                              Text(
                                'Reviewed results will appear here when available.',
                                style: theme.textTheme.bodySmall,
                              )
                            else
                              Row(
                                children: [
                                  for (var i = 0; i < latest.length; i++) ...[
                                    if (i > 0) const SizedBox(width: 10),
                                    Expanded(
                                      child: _ResultPreview(
                                        parameter: latest[i],
                                        onTap: () => _openTrend(latest[i]),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                          if (_loadFailed && reports != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Some information could not be refreshed. Pull down to try again.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPreview extends StatelessWidget {
  const _ResultPreview({required this.parameter, required this.onTap});
  final TrendParameter parameter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final point = parameter.dataPoints.last;
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parameter.parameterName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: point.originalValue ?? point.value.toString(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 26,
                        ),
                      ),
                      TextSpan(
                        text: ' ${parameter.unit ?? ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (parameter.dataPoints
                      .map((point) => point.date)
                      .toSet()
                      .length >=
                  2)
                SizedBox(
                  height: 26,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _MiniTrendPainter(
                      parameter.dataPoints,
                      color: theme.colorScheme.primary,
                      accent: AppColors.teal,
                    ),
                  ),
                )
              else
                Text(
                  '${parameter.dataPoints.length == 1 ? 'One result' : 'Same-day results'} · ${AppDateFormat.dateWithRelative(point.date, hasTime: false)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTrendPainter extends CustomPainter {
  const _MiniTrendPainter(
    this.points, {
    required this.color,
    required this.accent,
  });

  final List<TrendDataPoint> points;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.isEmpty) return;
    final low = points
        .map((point) => point.value)
        .reduce((a, b) => a < b ? a : b);
    final high = points
        .map((point) => point.value)
        .reduce((a, b) => a > b ? a : b);
    final firstDate = points.first.date.millisecondsSinceEpoch;
    final lastDate = points.last.date.millisecondsSinceEpoch;
    final dateSpan = lastDate - firstDate;
    if (dateSpan <= 0) return;
    final span = high == low ? 1.0 : high - low;
    final path = Path();
    final offsets = <Offset>[];
    for (var index = 0; index < points.length; index++) {
      final x =
          2 +
          (size.width - 4) *
              (points[index].date.millisecondsSinceEpoch - firstDate) /
              dateSpan;
      final y =
          size.height -
          4 -
          (size.height - 8) * (points[index].value - low) / span;
      final point = Offset(x, y);
      offsets.add(point);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (var index = 0; index < offsets.length; index++) {
      canvas.drawCircle(
        offsets[index],
        index == offsets.length - 1 ? 2.4 : 1.8,
        Paint()..color = index == offsets.length - 1 ? accent : color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniTrendPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.accent != accent;
}

class _RestrictionBanner extends StatelessWidget {
  const _RestrictionBanner({required this.rationale, required this.nextSteps});

  final String rationale;
  final String nextSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('restriction-banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Account Restricted',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (rationale.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: const Key('restriction-rationale'),
              rationale,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
          if (nextSteps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              key: const Key('restriction-next-steps'),
              nextSteps,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
