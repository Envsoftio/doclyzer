import '../report_processing_store.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api_client.dart';
import '../../../core/feedback/incident_banner.dart';
import '../../../features/incidents/incident_repository.dart';
import '../../../features/support/support_models.dart';
import '../../../features/support/support_repository.dart';
import '../../../features/support/support_request_sheet.dart';
import '../../profiles/profiles_repository.dart';
import '../reports_repository.dart';
import 'pdf_viewer_screen.dart';
import 'report_detail_screen.dart';
import 'report_review_screen.dart';

enum _UploadState {
  idle,
  selected,
  uploading,
  reading,
  success,
  error,
  duplicate,
  limit,
}

class UploadReportScreen extends StatefulWidget {
  const UploadReportScreen({
    super.key,
    required this.reportsRepository,
    required this.profilesRepository,
    required this.activeProfileName,
    required this.onBack,
    required this.onComplete,
    this.onUploadBusyChanged,
    this.onUploadAccepted,
    this.incidentStatus,
    this.onUpgrade,
    required this.supportRepository,
    this.initialReport,
    this.initialDuplicateExistingReport,
    this.initialDuplicatePendingPath,
  });

  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final String activeProfileName;
  final VoidCallback onBack;
  final VoidCallback onComplete;
  final ValueChanged<bool>? onUploadBusyChanged;
  final VoidCallback? onUploadAccepted;
  final VoidCallback? onUpgrade;
  final PublicIncidentStatus? incidentStatus;
  final SupportRepository supportRepository;

  /// For testing: when set, shows result state immediately (bypasses file pick).
  final UploadedReport? initialReport;

  /// For testing duplicate UX: when set with [initialDuplicatePendingPath], shows duplicate dialog immediately.
  final Map<String, dynamic>? initialDuplicateExistingReport;
  final String? initialDuplicatePendingPath;

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  static const List<String> _allowedUploadExtensions = <String>[
    'pdf',
    'jpg',
    'jpeg',
    'png',
  ];

  final ImagePicker _imagePicker = ImagePicker();
  _UploadState _state = _UploadState.idle;
  String? _errorMessage;
  UploadedReport? _result;
  int _verifiedResultCount = 0;
  String? _pendingDuplicatePath;
  String? _selectedPath;
  Map<String, dynamic>? _existingReport;
  String? _limitMessage;
  String? _limitUpgradeHint;
  int? _limitCurrent;
  int? _limitMax;
  SupportRequestContext? _supportContext;
  String? _supportErrorMessage;

  void _onProcessingChanged() {
    final result = _result;
    if (!mounted || result == null) return;
    final update = ReportProcessingStore.instance.reports[result.reportId];
    if (update == null) return;
    const legacy = {
      'ready': 'parsed',
      'processing': 'parsing',
      'retry_scheduled': 'failed_transient',
      'failed': 'failed_terminal',
      'needs_attention': 'content_not_recognized',
      'cancelled': 'unparsed',
    };
    final status = legacy[update['status']] ?? update['status'] as String;
    if (status == result.status) return;
    setState(
      () => _result = UploadedReport(
        reportId: result.reportId,
        profileId: result.profileId,
        fileName: result.fileName,
        contentType: result.contentType,
        sizeBytes: result.sizeBytes,
        status: status,
        reused: result.reused,
      ),
    );
  }

  @override
  void dispose() {
    ReportProcessingStore.instance.removeListener(_onProcessingChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ReportProcessingStore.instance.addListener(_onProcessingChanged);
    // Android can kill the activity while the camera or photo picker is open.
    _recoverLostImage();
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
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedUploadExtensions,
      );
      if (result == null || result.files.isEmpty || !mounted) return;
      _selectPath(result.files.single.path);
    } catch (_) {
      _showPickerError('Could not open files. Check access and try again.');
    }
  }

  Future<void> _captureAndUpload() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 95,
      );
      if (image != null && mounted) _selectPath(image.path);
    } catch (_) {
      _showPickerError(
        'Could not open camera or photos. Check permission and try again.',
      );
    }
  }

  Future<void> _recoverLostImage() async {
    if (widget.initialReport != null) return;
    try {
      final lost = await _imagePicker.retrieveLostData();
      if (!mounted || lost.isEmpty) return;
      final image = lost.files?.firstOrNull;
      if (image != null) _selectPath(image.path);
    } catch (_) {
      // The user can choose the file again if recovery is unavailable.
    }
  }

  void _showPickerError(String message) {
    if (!mounted) return;
    setState(() {
      _state = _UploadState.error;
      _errorMessage = message;
    });
  }

  void _selectPath(String? path) {
    if (!mounted) return;
    if (path == null || path.isEmpty) {
      _showPickerError('Could not access selected file.');
      return;
    }
    setState(() {
      _selectedPath = path;
      _state = _UploadState.selected;
      _errorMessage = null;
    });
  }

  Future<void> _uploadFromPath(String? path) async {
    if (path == null || path.isEmpty) {
      if (mounted) {
        setState(() {
          _state = _UploadState.error;
          _errorMessage = 'Could not access selected file';
        });
      }
      return;
    }

    setState(() {
      _state = _UploadState.uploading;
      _errorMessage = null;
      _verifiedResultCount = 0;
    });
    widget.onUploadBusyChanged?.call(true);

    try {
      final report = await widget.reportsRepository.uploadReport(path);
      widget.onUploadAccepted?.call();
      if (mounted) {
        setState(() {
          _state = _UploadState.success;
          _result = report;
          _pendingDuplicatePath = null;
          _selectedPath = null;
          _existingReport = null;
          if (_isParseFailureStatus(report.status)) {
            _supportContext = buildSupportRequestContext(
              actionType: SupportActionType.reportParse,
              entityIds: {'reportId': report.reportId},
            );
            _supportErrorMessage = _parseFailureMessage(report.status);
          } else {
            _supportContext = null;
            _supportErrorMessage = null;
          }
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
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.reportUpload,
            apiException: e,
          );
          _supportErrorMessage = e.message;
        });
        return;
      }
      if (mounted) {
        setState(() {
          _state = _UploadState.error;
          _errorMessage = e.code == 'NETWORK_ERROR'
              ? 'Connection lost. The upload may have reached the server. Retry the same file safely.'
              : e.message;
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.reportUpload,
            apiException: e,
          );
          _supportErrorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UploadState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.reportUpload,
          );
          _supportErrorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      widget.onUploadBusyChanged?.call(false);
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
            reused: true,
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
      _verifiedResultCount = 0;
    });
    widget.onUploadBusyChanged?.call(true);
    try {
      final report = await widget.reportsRepository.uploadReport(
        path,
        forceUploadAnyway: true,
      );
      if (mounted) {
        widget.onUploadAccepted?.call();
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
    } finally {
      widget.onUploadBusyChanged?.call(false);
    }
  }

  Future<void> _onDuplicateProcessAgain() async {
    final existing = _existingReport;
    if (existing == null) return;
    final id = existing['id'] as String?;
    if (id == null) return;
    setState(() {
      _state = _UploadState.reading;
      _errorMessage = null;
    });
    try {
      final report = await widget.reportsRepository.retryParse(id, force: true);
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
          _supportContext = null;
          _supportErrorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UploadState.duplicate;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
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
        title: const Text('Upload Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _state == _UploadState.uploading ? null : widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                _UploadState.selected => _buildSelected(),
                _UploadState.uploading => _buildProgress('Uploading report…'),
                _UploadState.reading => _buildProgress('Reading report…'),
                _UploadState.success =>
                  _isParseFailure() ? _buildParseFailure() : _buildSuccess(),
                _UploadState.duplicate => _buildDuplicateDialog(),
                _UploadState.limit => _buildLimitWarning(),
                _UploadState.error => _buildError(),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('upload-report-pick'),
          onPressed: _pickAndUpload,
          icon: const Icon(Icons.upload_file),
          label: const Text('Pick PDF or Image'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choose Photo'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('upload-report-camera'),
          onPressed: _captureAndUpload,
          icon: const Icon(Icons.photo_camera_outlined),
          label: const Text('Take Photo'),
        ),
        const SizedBox(height: 8),
        Text(
          'Accepted formats: PDF, JPG, PNG',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSelected() {
    final path = _selectedPath;
    if (path == null) return _buildIdle();
    final fileName = path.split(RegExp(r'[/\\]')).last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Check your report',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(fileName),
          subtitle: Text('For ${widget.activeProfileName}'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _uploadFromPath(path),
          child: const Text('Add report'),
        ),
        TextButton(
          onPressed: () => setState(() {
            _selectedPath = null;
            _state = _UploadState.idle;
          }),
          child: const Text('Choose a different file'),
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
    return r != null && _isParseFailureStatus(r.status);
  }

  bool _isParseFailureStatus(String status) {
    return status == 'unparsed' ||
        status == 'content_not_recognized' ||
        status == 'failed_terminal' ||
        status == 'failed_transient';
  }

  String _parseFailureMessage(String? status) {
    if (status == 'failed_transient') {
      return 'Processing stopped before it finished. Your file is saved. Tap Retry to try again.';
    }
    if (status == 'content_not_recognized') {
      return 'Some results need review. Your original report is saved.';
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
          if (_isParseFailureStatus(report.status)) {
            _supportContext = buildSupportRequestContext(
              actionType: SupportActionType.reportParse,
              entityIds: {'reportId': report.id},
            );
            _supportErrorMessage = _parseFailureMessage(report.status);
          } else {
            _supportContext = null;
            _supportErrorMessage = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _UploadState.success; // keep parse-failure UI
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.reportParse,
            apiException: e is ApiException ? e : null,
            entityIds: _result != null ? {'reportId': _result!.reportId} : null,
          );
          _supportErrorMessage = e.toString().replaceFirst('Exception: ', '');
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

  Future<void> _onViewReport() async {
    final report = _result;
    if (report == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (routeContext) => ReportDetailScreen(
          reportsRepository: widget.reportsRepository,
          profilesRepository: widget.profilesRepository,
          reportId: report.reportId,
          profileId: report.profileId,
          onBack: () => Navigator.of(routeContext).pop(),
        ),
      ),
    );
    try {
      final refreshed = await widget.reportsRepository.getReport(
        report.reportId,
      );
      if (mounted) {
        setState(
          () => _verifiedResultCount = refreshed.extractedLabValues.length,
        );
      }
    } catch (_) {
      // The report detail screen handles refresh errors itself.
    }
  }

  Future<void> _onReviewReport() async {
    final report = _result;
    if (report == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReportReviewScreen(
          reportsRepository: widget.reportsRepository,
          reportId: report.reportId,
          fileName: report.fileName,
        ),
      ),
    );
    try {
      final refreshed = await widget.reportsRepository.getReport(
        report.reportId,
      );
      if (mounted) {
        setState(
          () => _verifiedResultCount = refreshed.extractedLabValues.length,
        );
      }
    } catch (_) {
      // The review screen shows save errors; a refresh can be retried later.
    }
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
          _parseFailureMessage(_result?.status),
          key: const Key('parse-failure-message'),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (_result?.status == 'content_not_recognized') ...[
          const SizedBox(height: 8),
          Text(
            'Check detected results against the original report before saving them.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (_verifiedResultCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$_verifiedResultCount verified result${_verifiedResultCount == 1 ? '' : 's'} saved.',
              textAlign: TextAlign.center,
            ),
          ],
        ],
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
        if (_result?.status == 'content_not_recognized') ...[
          FilledButton(
            key: const Key('parse-failure-review-results'),
            onPressed: _verifiedResultCount > 0
                ? _onViewReport
                : _onReviewReport,
            child: Text(
              _verifiedResultCount > 0
                  ? 'View verified results'
                  : 'Review detected results',
            ),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton(
          key: const Key('view-pdf-button'),
          onPressed: _onViewPdf,
          child: const Text('View original report'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('parse-failure-retry'),
          onPressed: _onRetry,
          child: const Text('Retry'),
        ),
        if (_result?.status != 'content_not_recognized') ...[
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('parse-failure-keep-file'),
            onPressed: _onKeepFile,
            child: const Text('Keep file anyway'),
          ),
        ],
        if (_supportContext != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              final supportContext = _supportContext;
              if (supportContext == null) return;
              showSupportRequestSheet(
                context: context,
                supportRepository: widget.supportRepository,
                supportContext: supportContext,
                errorMessage: _supportErrorMessage,
              );
            },
            child: const Text('Need help?'),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccess() {
    final r = _result;
    final status = r?.status ?? '';
    final processingInProgress =
        status == 'uploading' || status == 'queued' || status == 'parsing';
    final statusMessage = switch (status) {
      'parsed' =>
        'Report parsed successfully. Results and trends are available.',
      'uploading' || 'queued' || 'parsing' =>
        'Your report is still being analyzed. Open it to check its status.',
      'failed_transient' =>
        'Processing stopped. Your file is saved. You can retry.',
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          processingInProgress ? Icons.hourglass_top : Icons.check_circle,
          color: processingInProgress ? Colors.orange : Colors.green,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          r?.reused == true
              ? 'Report already in ${widget.activeProfileName}'
              : 'Report added to ${widget.activeProfileName}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (r != null)
          Text(r.fileName, style: Theme.of(context).textTheme.bodyMedium),
        if (statusMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            statusMessage,
            key: const Key('upload-success-status-message'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('upload-view-results'),
          onPressed: _onViewReport,
          icon: Icon(
            processingInProgress ? Icons.schedule : Icons.analytics_outlined,
          ),
          label: Text(
            processingInProgress ? 'View report status' : 'View results',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('view-pdf-button'),
          onPressed: _onViewPdf,
          child: const Text('View original file'),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('upload-report-done'),
          onPressed: widget.onComplete,
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
        ? 'Added ${AppDateFormat.fromRawWithRelative(createdAt)}'
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
        FilledButton(
          key: const Key('duplicate-process-again'),
          onPressed: _onDuplicateProcessAgain,
          child: const Text('Process PDF Again'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('duplicate-upload-anyway'),
          onPressed: _onDuplicateUploadAnyway,
          child: const Text('Upload as new copy'),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            key: const Key('duplicate-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
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
        if (usageText != null) ...[const SizedBox(height: 8), Text(usageText)],
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
        OutlinedButton(onPressed: widget.onBack, child: const Text('Back')),
        if (_supportContext != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              final supportContext = _supportContext;
              if (supportContext == null) return;
              showSupportRequestSheet(
                context: context,
                supportRepository: widget.supportRepository,
                supportContext: supportContext,
                errorMessage: _supportErrorMessage,
              );
            },
            child: const Text('Need help?'),
          ),
        ],
      ],
    );
  }

  Widget _buildError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        Text(_errorMessage ?? 'Upload failed', key: const Key('upload-error')),
        const SizedBox(height: 24),
        if (_selectedPath != null)
          FilledButton(
            key: const Key('upload-retry-same-file'),
            onPressed: () => _uploadFromPath(_selectedPath),
            child: const Text('Retry same file'),
          ),
        TextButton(
          onPressed: () => setState(() {
            _selectedPath = null;
            _state = _UploadState.idle;
            _errorMessage = null;
          }),
          child: Text(
            _selectedPath == null ? 'Try again' : 'Choose another file',
          ),
        ),
        if (_supportContext != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              final supportContext = _supportContext;
              if (supportContext == null) return;
              showSupportRequestSheet(
                context: context,
                supportRepository: widget.supportRepository,
                supportContext: supportContext,
                errorMessage: _supportErrorMessage,
              );
            },
            child: const Text('Need help?'),
          ),
        ],
      ],
    );
  }
}
