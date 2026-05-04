import 'package:flutter/material.dart';

import '../../../core/feedback/incident_banner.dart';
import '../../incidents/incident_repository.dart';
import '../../profiles/profiles_repository.dart';
import '../../sharing/sharing_repository.dart';
import '../../sharing/screens/create_share_link_screen.dart';
import '../../support/support_repository.dart';
import '../reports_repository.dart';
import 'health_history_screen.dart';
import 'report_detail_screen.dart';

enum _TimelineState { loading, loaded, error }

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    super.key,
    required this.reportsRepository,
    required this.profilesRepository,
    required this.profileId,
    required this.onBack,
    required this.sharingRepository,
    required this.profileName,
    required this.onUpgrade,
    required this.supportRepository,
    this.incidentStatus,
  });

  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final String profileId;
  final VoidCallback onBack;
  final SharingRepository sharingRepository;
  final String profileName;
  final VoidCallback onUpgrade;
  final SupportRepository supportRepository;
  final PublicIncidentStatus? incidentStatus;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  _TimelineState _state = _TimelineState.loading;
  List<Report> _reports = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void didUpdateWidget(covariant TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId) {
      setState(() {
        _state = _TimelineState.loading;
        _reports = [];
        _errorMessage = null;
      });
      _loadReports();
    }
  }

  Future<void> _loadReports() async {
    setState(() {
      _state = _TimelineState.loading;
      _errorMessage = null;
    });
    try {
      final list = await widget.reportsRepository.listReports(widget.profileId);
      if (mounted) {
        setState(() {
          _reports = list;
          _state = _TimelineState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _TimelineState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
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
        ),
      ),
    );
    if (!mounted) return;
    await _loadReports();
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
        title: const Text('Reports'),
        leading: IconButton(
          key: const Key('timeline-back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            key: const Key('timeline-health-history-button'),
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: 'Health History',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HealthHistoryScreen(
                  profileId: widget.profileId,
                  reportsRepository: widget.reportsRepository,
                ),
              ),
            ),
          ),
          IconButton(
            key: const Key('timeline-share-button'),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CreateShareLinkScreen(
                  profileId: widget.profileId,
                  profileName: widget.profileName,
                  sharingRepository: widget.sharingRepository,
                  supportRepository: widget.supportRepository,
                  onUpgrade: widget.onUpgrade,
                  incidentStatus: widget.incidentStatus,
                ),
              ),
            ),
          ),
        ],
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadReports, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_reports.isEmpty) {
      return Center(
        key: const Key('timeline-empty'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No reports yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a report from the home screen to see it here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      key: const Key('timeline-list'),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final statusColor = _statusColor(context, report.status);
        return Card(
          key: Key('timeline-report-${report.id}'),
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openReport(report),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          report.originalFileName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar: Icon(
                          Icons.circle,
                          size: 10,
                          color: statusColor,
                        ),
                        label: Text(_statusLabel(report.status)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _dateBadge(
                        context,
                        icon: Icons.event_note,
                        label: 'Report date',
                        value: _formatDate(report.createdAt),
                      ),
                      _dateBadge(
                        context,
                        icon: Icons.check_circle_outline,
                        label: 'Parsed date',
                        value: report.parsedAt != null
                            ? _formatDate(report.parsedAt!)
                            : '—',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dateBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text('$label: $value', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'parsed':
        return Colors.green.shade700;
      case 'failed_transient':
        return Colors.orange.shade700;
      case 'failed_terminal':
      case 'content_not_recognized':
      case 'unparsed':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'uploading':
        return 'Uploading';
      case 'queued':
        return 'Queued for parsing';
      case 'parsing':
        return 'Parsing in progress';
      case 'parsed':
        return 'Parsed';
      case 'content_not_recognized':
        return 'Not a lab report';
      case 'unparsed':
        return 'Unparsed';
      case 'failed_transient':
        return 'Processing delayed';
      case 'failed_terminal':
        return 'Parsing failed';
      default:
        return status;
    }
  }
}
