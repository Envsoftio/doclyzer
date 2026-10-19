import '../../reports/report_processing_store.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';

import '../../reports/reports_repository.dart';
import '../../reports/screens/report_detail_screen.dart';
import '../../profiles/profiles_repository.dart';
import '../../billing/billing_repository.dart';

import '../../../core/theme/app_theme.dart';
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
    required this.onGoToBilling,
    required this.onGoToReferrals,
    required this.restrictionRepository,
    required this.reportsRepository,
    required this.profilesRepository,
    required this.billingRepository,
    this.incidentStatus,
  });

  final Future<void> Function() onLogout;
  final VoidCallback onGoToAccount;
  final VoidCallback onGoToProfiles;
  final VoidCallback onGoToSessions;
  final VoidCallback onGoToCommunicationPreferences;
  final VoidCallback onGoToDataRights;
  final Future<void> Function() onGoToUploadReport;
  final Future<void> Function() onGoToTimeline;
  final VoidCallback onGoToBilling;
  final VoidCallback onGoToReferrals;
  final RestrictionRepository restrictionRepository;
  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final BillingRepository billingRepository;
  final PublicIncidentStatus? incidentStatus;

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
  List<Profile>? _profiles;
  EntitlementSummary? _entitlement;
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
      _loadSection(() async {
        final profiles = await widget.profilesRepository.getProfiles();
        if (mounted) setState(() => _profiles = profiles);
      }),
      _loadSection(() async {
        if (_isActionBlocked('view_timeline')) {
          if (mounted) setState(() => _reports = null);
          return;
        }
        final reports = await widget.reportsRepository.listAllReports();
        reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (mounted) setState(() => _reports = reports);
      }),
      _loadSection(() async {
        final entitlement = await widget.billingRepository
            .getEntitlementSummary();
        if (mounted) setState(() => _entitlement = entitlement);
      }),
    ]);
    if (mounted) setState(() => _loading = false);
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

  void _openProfiles() {
    if (_isActionBlocked('manage_profiles')) {
      _showBlockedMessage();
      return;
    }
    widget.onGoToProfiles();
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

  void _showSettings() {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Account & settings',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: 16),
                for (final item in [
                  (
                    Icons.account_circle_outlined,
                    'Account',
                    'go-to-account',
                    widget.onGoToAccount,
                  ),
                  (
                    Icons.devices_rounded,
                    'Active Sessions',
                    'go-to-sessions',
                    widget.onGoToSessions,
                  ),
                  (
                    Icons.notifications_outlined,
                    'Communication Preferences',
                    'go-to-communication-preferences',
                    widget.onGoToCommunicationPreferences,
                  ),
                  (
                    Icons.shield_outlined,
                    'Data Rights',
                    'go-to-data-rights',
                    widget.onGoToDataRights,
                  ),
                  (
                    Icons.group_add_outlined,
                    'Referrals',
                    'go-to-referrals',
                    widget.onGoToReferrals,
                  ),
                ])
                  ListTile(
                    key: Key(item.$3),
                    leading: Icon(item.$1, color: colors.primary),
                    title: Text(
                      item.$2,
                      style: TextStyle(color: colors.onSurface),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      item.$4();
                    },
                  ),
                const Divider(),
                ListTile(
                  key: const Key('logout-submit'),
                  leading: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text('Log out', style: TextStyle(color: colors.error)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onLogout();
                  },
                ),
              ],
            ),
          ),
        ),
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
    final incident = widget.incidentStatus;
    final reports = _reports;
    final ready = reports?.where((r) => r.status == 'parsed').length;
    final processing = reports
        ?.where((r) => ['uploading', 'queued', 'parsing'].contains(r.status))
        .length;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.health_and_safety_rounded, color: colors.primary),
            const SizedBox(width: 8),
            const Text('Doclyzer'),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('dashboard-settings'),
            tooltip: 'Account & settings',
            onPressed: _showSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (incident != null &&
                              incident.isActive &&
                              incident.affectsSurface('mobile_app')) ...[
                            IncidentBanner(incident: incident),
                            const SizedBox(height: 20),
                          ],
                          if (_restrictionStatus?.isRestricted ?? false) ...[
                            _RestrictionBanner(
                              rationale: _restrictionStatus?.rationale ?? '',
                              nextSteps: _restrictionStatus?.nextSteps ?? '',
                            ),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            'Your health,\nin one place.',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontSize: 32,
                              height: 1.15,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'A clearer view of your reports and records.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF075C69), Color(0xFF0A7C8C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.post_add_rounded,
                                  color: Color(0xFFB7F1E7),
                                  size: 32,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Make room for clarity',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add a lab report to keep results together and follow changes over time.',
                                  style: TextStyle(
                                    color: Color(0xFFDBF0F2),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FilledButton.icon(
                                  key: const Key('go-to-upload-report'),
                                  onPressed: _upload,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF075C69),
                                  ),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Upload Report'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Your report overview',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Across all profiles',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          if (_loading) ...[
                            const LinearProgressIndicator(
                              minHeight: 2,
                              semanticsLabel: 'Loading dashboard',
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_loadFailed) ...[
                            Text(
                              'Some information could not be refreshed. Pull down to try again.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow =
                                  constraints.maxWidth < 340 ||
                                  MediaQuery.textScalerOf(context).scale(14) >
                                      22;
                              final stats = [
                                _Stat(
                                  label: 'Reports',
                                  value: reports?.length.toString() ?? '—',
                                  icon: Icons.description_outlined,
                                ),
                                _Stat(
                                  label: 'Ready',
                                  value: ready?.toString() ?? '—',
                                  icon: Icons.task_alt_rounded,
                                ),
                                _Stat(
                                  label: 'Processing',
                                  value: processing?.toString() ?? '—',
                                  icon: Icons.hourglass_top_rounded,
                                ),
                              ];
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final stat in stats)
                                    SizedBox(
                                      width: narrow
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth - 20) / 3,
                                      child: stat,
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Recent reports',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (reports == null)
                                    Text(
                                      _loading
                                          ? 'Fetching your latest reports…'
                                          : 'Report overview unavailable.',
                                      style: theme.textTheme.bodyMedium,
                                    )
                                  else if (reports.isEmpty) ...[
                                    Icon(
                                      Icons.folder_open_rounded,
                                      size: 40,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Your story starts here',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Upload your first report to start building your health history.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ] else
                                    for (final report in reports.take(3))
                                      _RecentReport(
                                        report: report,
                                        onTap: () => _openReport(report),
                                      ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    key: const Key('go-to-timeline'),
                                    onPressed: _openTimeline,
                                    icon: const Icon(Icons.timeline_rounded),
                                    label: const Text('Open Timeline'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _HomeNavCard(
                            key: const Key('go-to-profiles'),
                            icon: Icons.people_outline_rounded,
                            title: 'Health profiles',
                            subtitle: _profiles == null
                                ? 'Manage your profiles'
                                : '${_profiles!.length} profiles • Manage your family’s records',
                            onTap: _openProfiles,
                          ),
                          _HomeNavCard(
                            key: const Key('go-to-billing'),
                            icon: Icons.account_balance_wallet_outlined,
                            title: _entitlement?.planName ?? 'Plan & Credits',
                            subtitle: _entitlement == null
                                ? 'View your plan and credit balance'
                                : '${_entitlement!.creditBalance.toStringAsFixed(_entitlement!.creditBalance % 1 == 0 ? 0 : 1)} credits available',
                            onTap: widget.onGoToBilling,
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
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RecentReport extends StatelessWidget {
  const _RecentReport({required this.report, required this.onTap});
  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon) = switch (report.status) {
      'parsed' => ('Ready', Icons.check_circle_outline_rounded),
      'uploading' ||
      'queued' ||
      'parsing' => ('Processing', Icons.schedule_rounded),
      'failed_transient' ||
      'failed_terminal' => ('Processing failed', Icons.error_outline_rounded),
      'content_not_recognized' => (
        'Not recognized',
        Icons.info_outline_rounded,
      ),
      'unparsed' => ('Saved without analysis', Icons.description_outlined),
      _ => ('Uploaded', Icons.description_outlined),
    };
    final date = AppDateFormat.dateWithRelative(report.createdAt);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.originalFileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${report.profileName ?? 'Health profile'} • $date',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(label, style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _HomeNavCard extends StatelessWidget {
  const _HomeNavCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
