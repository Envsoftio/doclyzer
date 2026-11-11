import 'package:mobile/core/localized_error.dart';
import 'package:mobile/l10n/l10n.dart';
import 'dart:async';

import '../report_processing_store.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';
import '../../../core/theme/design_components.dart';

import '../../../core/feedback/incident_banner.dart';
import '../../incidents/incident_repository.dart';
import '../../profiles/profiles_repository.dart';
import '../../sharing/sharing_repository.dart';
import '../../sharing/screens/create_share_link_screen.dart';
import '../../support/support_repository.dart';
import '../reports_repository.dart';
import 'health_history_screen.dart';
import 'compare_reports_screen.dart';
import 'pdf_viewer_screen.dart';
import 'recycle_bin_screen.dart';
import 'report_detail_screen.dart';

enum _TimelineState { loading, loaded, error }

class _LaboratorySearchHit {
  const _LaboratorySearchHit(this.name, this.reports);

  final String name;
  final List<Report> reports;
}

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    super.key,
    required this.reportsRepository,
    required this.profilesRepository,
    required this.profileId,
    required this.onBack,
    this.onUploadReport,
    this.onProfileSelected,
    this.showBackButton = true,
    required this.sharingRepository,
    required this.profileName,
    required this.onUpgrade,
    required this.supportRepository,
    this.incidentStatus,
    this.onShareReport,
  });

  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final String profileId;
  final VoidCallback onBack;
  final VoidCallback? onUploadReport;
  final ValueChanged<Profile>? onProfileSelected;
  final bool showBackButton;
  final SharingRepository sharingRepository;
  final String profileName;
  final VoidCallback onUpgrade;
  final SupportRepository supportRepository;
  final PublicIncidentStatus? incidentStatus;
  final ValueChanged<Report>? onShareReport;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  _TimelineState _state = _TimelineState.loading;
  List<Report> _reports = [];
  List<Profile> _profiles = [];
  String? _errorMessage;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<Report>? _remoteSearchResults;
  int _searchVersion = 0;
  String _filter = 'All reports';
  String _sort = 'Report date · newest';
  int _loadVersion = 0;

  void _onProcessingChanged() {
    if (mounted) _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    ReportProcessingStore.instance.removeListener(_onProcessingChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ReportProcessingStore.instance.addListener(_onProcessingChanged);
    _loadReports();
  }

  @override
  void didUpdateWidget(covariant TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId) {
      setState(() {
        _state = _TimelineState.loading;
        _reports = [];
        _profiles = [];
        _query = '';
        _searchController.clear();
        _remoteSearchResults = null;
        _errorMessage = null;
      });
      _loadReports();
    }
  }

  void _changeQuery(String value) {
    _searchDebounce?.cancel();
    final version = ++_searchVersion;
    setState(() {
      _query = value;
      _remoteSearchResults = null;
    });
    final query = value.trim();
    if (query.length < 2) return;
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      try {
        final matches = await widget.reportsRepository.searchReports(
          widget.profileId,
          query,
        );
        if (mounted &&
            version == _searchVersion &&
            widget.profileId.isNotEmpty) {
          setState(() => _remoteSearchResults = matches);
        }
      } catch (_) {
        // Keep local filename search usable if the search endpoint is unavailable.
      }
    });
  }

  Future<void> _loadReports() async {
    final version = ++_loadVersion;
    final profileId = widget.profileId;
    if (_state != _TimelineState.loaded) {
      setState(() => _state = _TimelineState.loading);
    }
    try {
      final profiles = await widget.profilesRepository.getProfiles();
      final list = await widget.reportsRepository.listReports(profileId);
      if (mounted && version == _loadVersion && profileId == widget.profileId) {
        setState(() {
          _profiles = profiles;
          _reports = list;
          _state = _TimelineState.loaded;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted && version == _loadVersion && profileId == widget.profileId) {
        setState(() {
          _state = _TimelineState.error;
          _errorMessage = localizedError(
            context,
            e,
            fallback: context.l10n.reportsLoadFailed,
          );
        });
      }
    }
  }

  Future<void> _openRecycleBin() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            RecycleBinScreen(reportsRepository: widget.reportsRepository),
      ),
    );
    if (mounted) await _loadReports();
  }

  Future<void> _openReport(Report report) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => ReportDetailScreen(
          reportsRepository: widget.reportsRepository,
          profilesRepository: widget.profilesRepository,
          reportId: report.id,
          profileId: report.profileId,
          onBack: () => Navigator.of(ctx).pop(),
          onShareReport: widget.onShareReport,
        ),
      ),
    );
    if (!mounted) return;
    await _loadReports();
  }

  void _openLaboratory(_LaboratorySearchHit laboratory) {
    Navigator.of(context).push(
      designPageRoute(
        Scaffold(
          appBar: AppBar(title: Text(laboratory.name)),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.profileName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.uiReportsFromLab(
                  context.l10n.reportCount(laboratory.reports.length),
                  laboratory.name,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              for (final report in laboratory.reports) ...[
                DesignReportCard(
                  report: report,
                  onTap: () => _openReport(report),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        context,
      ),
    );
  }

  void _openOriginal(Report report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => PdfViewerScreen(
          reportsRepository: widget.reportsRepository,
          reportId: report.id,
          fileName: report.originalFileName,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  String _choiceLabel(String value) => switch (value) {
    'All reports' => context.l10n.allReports,
    'Reviewed' => context.l10n.filterReviewed,
    'Needs review' => context.l10n.filterNeedsReview,
    'Processing' => context.l10n.filterProcessing,
    'Original only' => context.l10n.filterOriginalOnly,
    'Report date · newest' => context.l10n.reportDateNewest,
    'Report date · oldest' => context.l10n.reportDateOldest,
    'Upload date · newest' => context.l10n.uploadDateNewest,
    'Upload date · oldest' => context.l10n.uploadDateOldest,
    _ => value,
  };

  bool _matchesFilter(Report report) => switch (_filter) {
    'Reviewed' =>
      report.status == 'parsed' &&
          report.structuredReport?.extractionReview?.required != true,
    'Needs review' =>
      report.status == 'parsed' &&
          report.structuredReport?.extractionReview?.required == true,
    'Processing' => const [
      'queued',
      'uploading',
      'parsing',
    ].contains(report.status),
    'Original only' => report.status == 'unparsed',
    _ => true,
  };

  DateTime _reportDate(Report report) =>
      DateTime.tryParse(report.collectionDate ?? '') ?? report.createdAt;

  String _monthHeading(Report report) {
    final date = _reportDate(report);
    final parts = AppDateFormat.date(date, local: false).split('-');
    return '${parts[1].toUpperCase()} ${parts[2]}';
  }

  Future<void> _chooseFilter() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                context.l10n.filterReports,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            for (final value in const [
              'All reports',
              'Reviewed',
              'Needs review',
              'Processing',
              'Original only',
            ])
              ListTile(
                title: Text(_choiceLabel(value)),
                trailing: value == _filter
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(ctx).pop(value),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _filter = selected);
  }

  Future<void> _chooseSort() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                context.l10n.sortReports,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            for (final value in const [
              'Report date · newest',
              'Report date · oldest',
              'Upload date · newest',
              'Upload date · oldest',
            ])
              ListTile(
                title: Text(_choiceLabel(value)),
                trailing: value == _sort
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(ctx).pop(value),
              ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _sort = selected);
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incidentStatus;
    final showIncidentBanner =
        incident != null &&
        incident.isActive &&
        incident.affectsSurface('mobile_app');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.l10n.reports),
        leading: widget.showBackButton
            ? IconButton(
                key: const Key('timeline-back'),
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              )
            : null,
        actions: [
          IconButton(
            key: const Key('timeline-compare-button'),
            tooltip: context.l10n.compareReports,
            icon: const Icon(Icons.compare_arrows_rounded),
            onPressed: () => Navigator.of(context).push(
              designPageRoute(
                CompareReportsScreen(
                  profileId: widget.profileId,
                  profileName: widget.profileName,
                  reportsRepository: widget.reportsRepository,
                ),
                context,
              ),
            ),
          ),
          IconButton(
            key: const Key('timeline-recycle-bin-button'),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: context.l10n.recycleBin,
            onPressed: _openRecycleBin,
          ),
          IconButton(
            key: const Key('timeline-health-history-button'),
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: context.l10n.healthHistory,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HealthHistoryScreen(
                  profileId: widget.profileId,
                  reportsRepository: widget.reportsRepository,
                  profilesRepository: widget.profilesRepository,
                  onShareReport: widget.onShareReport,
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('timeline-share-button'),
            icon: const Icon(Icons.share_outlined),
            tooltip: context.l10n.shareProfile,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CreateShareLinkScreen(
                  profileId: widget.profileId,
                  profileName: widget.profileName,
                  sharingRepository: widget.sharingRepository,
                  reportsRepository: widget.reportsRepository,
                  supportRepository: widget.supportRepository,
                  onUpgrade: widget.onUpgrade,
                  incidentStatus: widget.incidentStatus,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.onUploadReport == null
          ? null
          : FloatingActionButton.extended(
              key: const Key('timeline-upload-report'),
              onPressed: widget.onUploadReport,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.uploadReport),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (showIncidentBanner) ...[
              IncidentBanner(incident: incident),
              const SizedBox(height: 16),
            ],
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_state == _TimelineState.loading) {
      return const Center(
        key: Key('timeline-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (_state == _TimelineState.error) {
      return Center(
        key: const Key('timeline-error'),
        child: DesignEmptyState(
          icon: Icons.cloud_off_outlined,
          title: context.l10n.reportsUnavailableTitle,
          message: _errorMessage ?? context.l10n.reportsLoadFailed,
          action: context.l10n.tryAgain,
          onAction: _loadReports,
        ),
      );
    }
    final query = _query.trim().toLowerCase();
    final visible = (_remoteSearchResults ?? _reports).where((report) {
      if (!_matchesFilter(report)) return false;
      if (query.isEmpty) return true;
      if (_remoteSearchResults != null) return true;
      return report.originalFileName.toLowerCase().contains(query) ||
          (report.collectionDate ?? '').toLowerCase().contains(query) ||
          (report.laboratoryName ??
                  report.structuredReport?.labDetails?.name ??
                  '')
              .toLowerCase()
              .contains(query) ||
          report.extractedLabValues.any(
            (value) => value.parameterName.toLowerCase().contains(query),
          );
    }).toList();
    final byUpload = _sort.startsWith(context.l10n.upload);
    final oldest = _sort.endsWith('oldest');
    visible.sort((a, b) {
      final first = byUpload ? a.createdAt : _reportDate(a);
      final second = byUpload ? b.createdAt : _reportDate(b);
      return oldest ? first.compareTo(second) : second.compareTo(first);
    });
    final entries = <Object>[];
    if (query.length >= 2) {
      final reportsByLab = <String, List<Report>>{};
      final displayNames = <String, String>{};
      for (final report in _reports) {
        final name =
            (report.laboratoryName ?? report.structuredReport?.labDetails?.name)
                ?.trim();
        if (name == null ||
            name.isEmpty ||
            !name.toLowerCase().contains(query)) {
          continue;
        }
        final key = name.toLowerCase();
        displayNames.putIfAbsent(key, () => name);
        reportsByLab.putIfAbsent(key, () => []).add(report);
      }
      if (reportsByLab.isNotEmpty) {
        entries.add(context.l10n.uiLaboratories);
        for (final key in reportsByLab.keys.toList()..sort()) {
          final reports = reportsByLab[key]!
            ..sort((a, b) => _reportDate(b).compareTo(_reportDate(a)));
          entries.add(_LaboratorySearchHit(displayNames[key]!, reports));
        }
      }
      if (visible.isNotEmpty) entries.add(context.l10n.reports);
      entries.addAll(visible);
    } else {
      String? previous;
      for (final report in visible) {
        final heading = _monthHeading(report);
        if (heading != previous) entries.add(heading);
        entries.add(report);
        previous = heading;
      }
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: const Key('timeline-profile-switcher'),
          onTap: _profiles.length > 1 ? _showProfilePicker : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.surface.withValues(
                    alpha: 0.65,
                  ),
                  child: Text(
                    widget.profileName.isEmpty
                        ? '?'
                        : widget.profileName[0].toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.reportsFor,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        widget.profileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_profiles.length > 1) ...[
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.switchAction,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          key: ValueKey('timeline-search-${widget.profileId}'),
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: context.l10n.searchReports,
          ),
          onChanged: _changeQuery,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: () => setState(() => _filter = 'All reports'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                child: Text(
                  _choiceLabel(_filter),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: _chooseFilter,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: const Icon(Icons.tune, size: 18),
              label: Text(context.l10n.filters, style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 10),
            IconButton.outlined(
              onPressed: _chooseSort,
              icon: const Icon(Icons.sort_rounded),
              tooltip: context.l10n.sortReports,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _reports.isEmpty
              ? DesignEmptyState(
                  key: const Key('timeline-empty'),
                  icon: Icons.folder_open_outlined,
                  title: context.l10n.noReportsYet,
                  message: context.l10n.uiUploadReportForProfile(
                    widget.profileName,
                  ),
                  action: widget.onUploadReport == null
                      ? null
                      : context.l10n.uploadReport,
                  onAction: widget.onUploadReport,
                )
              : entries.isEmpty
              ? DesignEmptyState(
                  icon: Icons.search_off_outlined,
                  title: context.l10n.noMatchingReports,
                  message: context.l10n.differentSearch,
                  action: context.l10n.clearFilters,
                  onAction: () => setState(() {
                    _searchController.clear();
                    _query = '';
                    _filter = 'All reports';
                    _remoteSearchResults = null;
                  }),
                )
              : ListView.builder(
                  key: PageStorageKey('timeline-list-${widget.profileId}'),
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    if (entry is String) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(2, 14, 2, 10),
                        child: Text(
                          entry,
                          style: theme.textTheme.bodySmall?.copyWith(
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }
                    if (entry is _LaboratorySearchHit) {
                      return Card(
                        key: Key(
                          'timeline-laboratory-${entry.name.toLowerCase()}',
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.business_outlined),
                          title: Text(entry.name),
                          subtitle: Text(
                            context.l10n.uiReportsLatestDate(
                              context.l10n.reportCount(entry.reports.length),
                              _formatDate(_reportDate(entry.reports.first)),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openLaboratory(entry),
                        ),
                      );
                    }
                    final report = entry as Report;
                    return Padding(
                      key: Key('timeline-report-${report.id}'),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DesignReportCard(
                            report: report,
                            onTap: () => _openReport(report),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  context.l10n.uiCollectedDate(
                                    _collectionLabel(report),
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  context.l10n.uiUploadedDate(
                                    _formatDate(report.createdAt),
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: () => _openOriginal(report),
                                  child: Text(context.l10n.original),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showProfilePicker() async {
    if (_profiles.isEmpty) return;
    final selected = await showModalBottomSheet<Profile>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                context.l10n.switchActiveProfile,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                context.l10n.switchProfileHelp,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final profile in _profiles)
              ListTile(
                title: Text(profile.name),
                trailing: profile.id == widget.profileId
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () => Navigator.of(ctx).pop(profile),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected.id == widget.profileId || !mounted) return;
    await widget.profilesRepository.activateProfile(selected.id);
    if (mounted) {
      if (widget.onProfileSelected != null) {
        widget.onProfileSelected!(selected);
      } else {
        widget.onBack();
      }
    }
  }

  String _formatDate(DateTime d) {
    return AppDateFormat.dateWithRelative(d);
  }

  String _collectionLabel(Report report) {
    if (report.collectionDateStatus == 'multiple') {
      return context.l10n.multipleCollectionDates;
    }
    final date = report.collectionDate?.trim();
    return date == null || date.isEmpty
        ? context.l10n.unknownCollectionDate
        : AppDateFormat.fromRaw(date);
  }
}
