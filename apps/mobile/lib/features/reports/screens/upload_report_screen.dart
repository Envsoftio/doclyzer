import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../reports_repository.dart';
import 'pdf_viewer_screen.dart';

enum _UploadState { idle, uploading, reading, success, error }

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({
    super.key,
    required this.reportsRepository,
    required this.activeProfileName,
    required this.onBack,
    required this.onComplete,
    this.initialReport,
  });

  final ReportsRepository reportsRepository;
  final String activeProfileName;
  final VoidCallback onBack;
  final VoidCallback onComplete;
  /// For testing: when set, shows result state immediately (bypasses file pick).
  final UploadedReport? initialReport;

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  _UploadState _state = _UploadState.idle;
  String? _errorMessage;
  UploadedReport? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialReport != null) {
      _result = widget.initialReport;
      _state = _UploadState.success;
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
      // Show "Uploading…" for the whole request (network transfer); server does upload+parse in one call
      final report = await widget.reportsRepository.uploadReport(path);
      if (mounted) {
        setState(() {
          _state = _UploadState.success;
          _result = report;
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
        (r.status == 'unparsed' || r.status == 'failed_terminal');
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
          'We couldn\'t read this format. Your file is saved.',
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
