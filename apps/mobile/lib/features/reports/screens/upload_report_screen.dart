import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../../../core/feedback/incident_banner.dart';
import '../../../features/incidents/incident_repository.dart';
import '../reports_repository.dart';
import 'pdf_viewer_screen.dart';

enum _UploadState { idle, uploading, reading, success, error, duplicate, limit }

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({
    super.key,
    required this.reportsRepository,
    required this.activeProfileName,
    required this.onBack,
    required this.onComplete,
    this.incidentStatus,
    this.onUpgrade,
    this.initialReport,
    this.initialDuplicateExistingReport,
    this.initialDuplicatePendingPath,
  });

  final ReportsRepository reportsRepository;
  final String activeProfileName;
  final VoidCallback onBack;
  final VoidCallback onComplete;
  final VoidCallback? onUpgrade;
  final PublicIncidentStatus? incidentStatus;
  /// For testing: when set, shows result state immediately (bypasses file pick).
  final UploadedReport? initialReport;
  /// For testing duplicate UX: when set with [initialDuplicatePendingPath], shows duplicate dialog immediately.
  final Map<String, dynamic>? initialDuplicateExistingReport;
  final String? initialDuplicatePendingPath;

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  _UploadState _state = _UploadState.idle;
  String? _errorMessage;
  UploadedReport? _result;
  String? _pendingDuplicatePath;
  Map<String, dynamic>? _existingReport;
  String? _limitMessage;
  String? _limitUpgradeHint;
  int? _limitCurrent;
  int? _limitMax;

  @override
  void initState() {
    super.initState();
    if (widget.initialReport != null) {
      _result = widget.initialReport;
      _state = _UploadState.success;
    } else if (widget.initialDuplicateExistingReport != null &&
        widget.initialDuplicatePendingPath != null) {
      _existingReport = widget.initialDuplicateExistingReport;
      _pendingDuplicatePath = widget.initialDuplicatePendingPath;
      _state = _UploadState.duplicate;
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final path = result.files.single.path;
    if (path == null || path.isEmpty) {
      if (mounted) {
        setState(() {
          _state = _UploadState.error;
          _errorMessage = 'Could not access file';
        });
      }
      return;
    }

    setState(() {
      _state = _UploadState.uploading;
      _errorMessage = null;
    });

    try {
      final report = await widget.reportsRepository.uploadReport(path);
      if (mounted) {
        setState(() {
          _state = _UploadState.success;
          _result = report;
          _pendingDuplicatePath = null;
          _existingReport = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted && e.code == 'REPORT_DUPLICATE_DETECTED') {
        final existing = e.data?['existingReport'] as Map<String, dynamic>?;
        if (existing != null) {
          setState(() {
            _state = _UploadState.duplicate;
            _pendingDuplicatePath = path;
            _existingReport = existing;
            _errorMessage = null;
          });
          return;
        }
      }
      if (mounted && e.code == 'REPORT_LIMIT_EXCEEDED') {
        final data = e.data?['data'] as Map<String, dynamic>?;
        setState(() {
          _state = _UploadState.limit;
          _limitMessage = e.message;
          _limitUpgradeHint = data?['upgradeHint'] as String?;
          final current = data?['current'];
          final max = data?['limit'];
          _limitCurrent = current is num ? current.toInt() : null;
          _limitMax = max is num ? max.toInt() : null;
          _errorMessage = null;
        });
        return;
      }
      if (mounted) {
        setState(() {
          _state = _UploadState.error;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UploadState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _onDuplicateKeepExisting() async {
    final existing = _existingReport;
    if (existing == null) return;
    final id = existing['id'] as String?;
    if (id == null) return;
    setState(() {
      _state = _UploadState.reading;
      _errorMessage = null;
    });
    try {
      final report = await widget.reportsRepository.getReport(id);
      if (mounted) {
        setState(() {
          _state = _UploadState.success;
          _result = UploadedReport(
            reportId: report.id,
            profileId: report.profileId,
            fileName: report.originalFileName,
            contentType: report.contentType,
            sizeBytes: report.sizeBytes,
            status: report.status,
          );
          _pendingDuplicatePath = null;
          _existingReport = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _state = _UploadState.duplicate;
          _errorMessage = 'Could not load existing report';
        });
      }
    }
  }

  Future<void> _onDuplicateUploadAnyway() async {
    final path = _pendingDuplicatePath;
    if (path == null) return;
    setState(() {
      _state = _UploadState.uploading;
      _errorMessage = null;
    });
    try {
      final report = await widget.reportsRepository.uploadReport(path,
          forceUploadAnyway: true);
      if (mounted) {
        setState(() {
          _state = _UploadState.success;
          _result = report;
          _pendingDuplicatePath = null;
          _existingReport = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UploadState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incidentStatus;
    final showIncidentBanner = incident != null &&
        incident.isActive &&
        incident.affectsSurface('mobile_app');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showIncidentBanner) ...[
              IncidentBanner(incident: incident),
              const SizedBox(height: 24),
            ],
            Text(
              'Uploading to: ${widget.activeProfileName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            switch (_state) {
              _UploadState.idle => _buildIdle(),
              _UploadState.uploading => _buildProgress('Uploading…'),
              _UploadState.reading => _buildProgress('Reading report…'),
              _UploadState.success => _isParseFailure()
                  ? _buildParseFailure()
                  : _buildSuccess(),
              _UploadState.duplicate => _buildDuplicateDialog(),
              _UploadState.limit => _buildLimitWarning(),
              _UploadState.error => _buildError(),
            },
          ],
        ),
      ),
    );
  }

  Widget _buildIdle() {
    return Column(
      children: [
        FilledButton.icon(
          key: const Key('upload-report-pick'),
          onPressed: _pickAndUpload,
          icon: const Icon(Icons.upload_file),
          label: const Text('Pick PDF'),
        ),
      ],
    );
  }

  Widget _buildProgress(String message) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message, key: const Key('upload-status')),
      ],
    );
  }

  bool _isParseFailure() {
    final r = _result;
    return r != null &&
        (r.status == 'unparsed' ||
            r.status == 'content_not_recognized' ||
            r.status == 'failed_terminal');
  }

  String _parseFailureMessage() {
    final r = _result;
    if (r?.status == 'content_not_recognized') {
      return 'This doesn\'t look like a health report. Your file is saved.';
    }
    return 'We couldn\'t read this format. Your file is saved.';
  }

  Future<void> _onRetry() async {
    final r = _result;
    if (r == null) return;
    setState(() {
      _state = _UploadState.reading;
      _errorMessage = null;
    });
    try {
      final report = await widget.reportsRepository.retryParse(r.reportId);
      if (mounted) {
        setState(() {
          _result = UploadedReport(
            reportId: report.id,
            profileId: report.profileId,
            fileName: report.originalFileName,
            contentType: report.contentType,
            sizeBytes: report.sizeBytes,
            status: report.status,
          );
          _state = _UploadState.success;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UploadState.success; // keep parse-failure UI
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _onKeepFile() async {
    final r = _result;
    if (r == null) return;
    try {
      await widget.reportsRepository.keepFile(r.reportId);
    } catch (_) {
      // Idempotent; already unparsed is fine
    }
    if (mounted) widget.onComplete();
  }

  void _onViewPdf() {
    final r = _result;
    if (r == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => PdfViewerScreen(
          reportsRepository: widget.reportsRepository,
          reportId: r.reportId,
          fileName: r.fileName,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  Widget _buildParseFailure() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.warning_amber_outlined,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          _parseFailureMessage(),
          key: const Key('parse-failure-message'),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (_errorMessage case final err?) ...[
          const SizedBox(height: 8),
          Text(
            err,
            key: const Key('parse-failure-retry-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('view-pdf-button'),
          onPressed: _onViewPdf,
          child: const Text('View PDF'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('parse-failure-retry'),
          onPressed: _onRetry,
          child: const Text('Retry'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('parse-failure-keep-file'),
          onPressed: _onKeepFile,
          child: const Text('Keep file anyway'),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final r = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 16),
        Text(
          'Report added to ${widget.activeProfileName}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (r != null)
          Text(
            r.fileName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('view-pdf-button'),
          onPressed: _onViewPdf,
          child: const Text('View PDF'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('upload-report-done'),
          onPressed: () {
            widget.onComplete();
          },
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildDuplicateDialog() {
    final existing = _existingReport;
    final name = existing?['originalFileName'] as String? ?? 'existing report';
    final createdAt = existing?['createdAt'] as String?;
    final subtitle = createdAt != null
        ? 'Added ${DateTime.tryParse(createdAt)?.toString().substring(0, 10) ?? createdAt}'
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.copy_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'This report looks like a duplicate',
          key: const Key('duplicate-dialog'),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('duplicate-keep-existing'),
          onPressed: _onDuplicateKeepExisting,
          child: const Text('Keep existing'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('duplicate-upload-anyway'),
          onPressed: _onDuplicateUploadAnyway,
          child: const Text('Upload anyway'),
        ),
      ],
    );
  }

  Widget _buildLimitWarning() {
    final usageText = (_limitCurrent != null && _limitMax != null)
        ? 'Using $_limitCurrent of $_limitMax reports.'
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        Text(
          _limitMessage ?? 'You have reached your report limit.',
          key: const Key('upload-limit-warning'),
        ),
        if (usageText != null) ...[
          const SizedBox(height: 8),
          Text(usageText),
        ],
        if (_limitUpgradeHint != null) ...[
          const SizedBox(height: 8),
          Text(_limitUpgradeHint!),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('upload-limit-upgrade'),
          onPressed: widget.onUpgrade,
          child: const Text('Upgrade'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: widget.onBack,
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? 'Upload failed',
          key: const Key('upload-error'),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            setState(() {
              _state = _UploadState.idle;
              _errorMessage = null;
            });
          },
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}
