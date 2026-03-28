import 'package:flutter/material.dart';

import '../../profiles/profiles_repository.dart';
import '../../sharing/sharing_repository.dart';
import '../../sharing/screens/create_share_link_screen.dart';
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
  });

  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final String profileId;
  final VoidCallback onBack;
  final SharingRepository sharingRepository;
  final String profileName;
  final VoidCallback onUpgrade;

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
                  onUpgrade: widget.onUpgrade,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
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
        return Card(
          key: Key('timeline-report-${report.id}'),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(report.originalFileName),
            subtitle: Text(
              '${_statusLabel(report.status)} · ${_formatDate(report.createdAt)}',
            ),
            onTap: () => _openReport(report),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'content_not_recognized':
        return 'Not a health report';
      case 'unparsed':
        return 'Unparsed';
      default:
        return status;
    }
  }
}
