import '../report_processing_store.dart';
import 'package:flutter/material.dart';

import '../../profiles/profiles_repository.dart';
import '../reports_repository.dart';
import '../result_palette.dart';
import '../result_range.dart';
import '../../../shared/ai_disclaimer_note.dart';
import '../../../shared/app_date_format.dart';
import 'health_history_screen.dart';
import 'pdf_viewer_screen.dart';
import 'processing_history_screen.dart';
import 'result_insight_screen.dart';
import 'trend_chart_screen.dart';

enum _ReportDetailState { loading, loaded, error }

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportsRepository,
    required this.profilesRepository,
    required this.reportId,
    required this.profileId,
    required this.onBack,
  });

  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final String reportId;
  final String profileId;
  final VoidCallback onBack;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  _ReportDetailState _state = _ReportDetailState.loading;
  Report? _report;
  String? _errorMessage;
  List<Profile> _profiles = [];
  bool _acknowledging = false;

  void _onProcessingChanged() {
    if (mounted) _loadReport();
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
    _loadReport();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final profiles = await widget.profilesRepository.getProfiles();
      if (mounted) {
        setState(() => _profiles = profiles);
      }
    } catch (_) {
      // Fail-open: if profiles can't be loaded, hide the reassign button
    }
  }

  Future<void> _loadReport() async {
    setState(() {
      _state = _ReportDetailState.loading;
      _errorMessage = null;
    });
    try {
      final report = await widget.reportsRepository.getReport(widget.reportId);
      if (mounted) {
        setState(() {
          _report = report;
          _state = _ReportDetailState.loaded;
        });
        final store = ReportProcessingStore.instance;
        final processing = store.reports[widget.reportId];
        if (!_acknowledging && report.status == 'parsed' &&
            processing?['acknowledgedAt'] == null) {
          _acknowledging = true;
          try {
            await store.acknowledge(widget.reportId);
          } catch (_) {
            // A notification acknowledgement must not hide readable results.
          } finally {
            _acknowledging = false;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _ReportDetailState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _openTrendChart(String parameterName, String? unit) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => TrendChartScreen(
          reportsRepository: widget.reportsRepository,
          profileId: widget.profileId,
          parameterName: parameterName,
          unit: unit ?? '',
          onBack: () => Navigator.of(ctx).pop(),
          onOpenReport: (reportId) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (sourceCtx) => ReportDetailScreen(
                reportsRepository: widget.reportsRepository,
                profilesRepository: widget.profilesRepository,
                reportId: reportId,
                profileId: widget.profileId,
                onBack: () => Navigator.of(sourceCtx).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openResult(ExtractedLabValue result) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => ResultInsightScreen(
          result: result,
          loadInsight: () => widget.reportsRepository.getResultInsight(
            widget.reportId,
            result,
          ),
          onViewTrend: () => _openTrendChart(result.parameterName, result.unit),
          onViewOriginal: _openPdf,
        ),
      ),
    );
  }

  List<ExtractedLabValue> _displayResults(Report report) {
    if (report.extractedLabValues.isNotEmpty) return report.extractedLabValues;
    return [
      for (final section
          in report.structuredReport?.sections ?? const <StructuredSection>[])
        for (final test in section.tests)
          ExtractedLabValue(
            parameterName: test.parameterName,
            value: test.value,
            unit: test.unit,
            sampleDate: test.sampleDate,
            referenceRange: test.referenceRange,
            isAbnormal: test.isAbnormal,
          ),
    ];
  }

  void _openPdf() {
    if (_report == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => PdfViewerScreen(
          reportsRepository: widget.reportsRepository,
          reportId: _report!.id,
          fileName: _report!.originalFileName,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _openParsedReportReader() {
    final text = _report?.parsedTranscript;
    if (text == null || text.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ParsedReportReaderScreen(rawText: text),
      ),
    );
  }

  Future<void> _onRetryParse() async {
    if (_report == null || _state == _ReportDetailState.loading) return;
    setState(() {
      _state = _ReportDetailState.loading;
      _errorMessage = null;
    });
    try {
      final report = await widget.reportsRepository.retryParse(_report!.id);
      if (mounted) {
        setState(() {
          _report = report;
          _state = _ReportDetailState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _ReportDetailState.loaded;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _onKeepFile() async {
    if (_report == null) return;
    try {
      await widget.reportsRepository.keepFile(_report!.id);
      if (mounted) _loadReport();
    } catch (_) {}
  }

  Future<void> _onReassign(String targetProfileId) async {
    if (_report == null) return;
    setState(() {
      _state = _ReportDetailState.loading;
      _errorMessage = null;
    });
    try {
      await widget.reportsRepository.reassignReport(
        _report!.id,
        targetProfileId,
      );
      if (mounted) widget.onBack();
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _ReportDetailState.loaded;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _onDeleteReport() async {
    final report = _report;
    if (report == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Move to recycle bin?'),
        content: const Text(
          'This report will move to recycle bin and be permanently deleted after 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _state = _ReportDetailState.loading;
      _errorMessage = null;
    });
    try {
      await widget.reportsRepository.deleteReport(report.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report moved to recycle bin')),
      );
      widget.onBack();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ReportDetailState.loaded;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _showReassignDialog() async {
    final currentProfileId = _report?.profileId ?? widget.profileId;
    final otherProfiles = _profiles
        .where((p) => p.id != currentProfileId)
        .toList();
    if (otherProfiles.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create another profile to reassign this report.'),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Reassign to profile'),
        children: otherProfiles.map((profile) {
          return SimpleDialogOption(
            key: Key('reassign-profile-${profile.id}'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _onReassign(profile.id);
            },
            child: Text(profile.name),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return AppDateFormat.dateWithRelative(d);
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
        return 'Extraction incomplete';
      case 'unparsed':
        return 'Unparsed';
      case 'failed_transient':
        return 'Processing stopped — retry available';
      case 'failed_terminal':
        return 'Parsing failed';
      default:
        return status;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'parsed':
        return Colors.green.shade700;
      case 'failed_terminal':
      case 'content_not_recognized':
      case 'unparsed':
        return Theme.of(context).colorScheme.error;
      case 'failed_transient':
        return Colors.orange.shade700;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('report-detail-scaffold'),
      appBar: AppBar(
        title: const Text('Report'),
        leading: IconButton(
          key: const Key('report-detail-back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          if (_report?.summaryStatus == 'failed')
            TextButton(
              onPressed: () async {
                try {
                  await ReportProcessingStore.instance.retrySummary(
                    widget.reportId,
                  );
                  await _loadReport();
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Summary retry is unavailable.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Summary unavailable — retry summary'),
            ),
          if (_report?.summaryStatus == 'pending')
            TextButton(
              onPressed: _loadReport,
              child: const Text('Summary pending — refresh'),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_state == _ReportDetailState.loading) {
      return const Center(
        key: Key('report-detail-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (_state == _ReportDetailState.error) {
      return Center(
        key: const Key('report-detail-error'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadReport, child: const Text('Retry')),
          ],
        ),
      );
    }

    final report = _report!;
    final summary = report.summary;
    final statusColor =
        report.structuredReport?.extractionReview?.required == true
        ? Colors.orange.shade700
        : _statusColor(context, report.status);
    final results = _displayResults(report);

    return SingleChildScrollView(
      key: const Key('report-detail-content'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.originalFileName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(Icons.circle, size: 10, color: statusColor),
                      label: Text(
                        report.structuredReport?.extractionReview?.required ==
                                true
                            ? 'Extraction incomplete'
                            : _statusLabel(report.status),
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.event, size: 16),
                      label: Text(
                        'Collected: ${report.collectionDateStatus == 'multiple'
                            ? 'Multiple collection dates'
                            : report.collectionDate == null || report.collectionDate!.trim().isEmpty
                            ? 'Unknown'
                            : AppDateFormat.fromRaw(report.collectionDate!)}',
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: Text('Uploaded: ${_formatDate(report.createdAt)}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (report.status == 'uploading' ||
              report.status == 'queued' ||
              report.status == 'parsing') ...[
            const SizedBox(height: 16),
            Text(
              'We are analyzing this report. You can leave this screen; results will appear when ready.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const Key('report-detail-check-status'),
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Check status'),
            ),
          ],
          if (report.structuredReport?.extractionReview?.required == true) ...[
            const SizedBox(height: 16),
            Card(
              key: const Key('report-detail-extraction-review'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We could not extract all results reliably',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Automatic extraction was incomplete. The original report is available; no manual correction is required.',
                    ),
                    for (final reason
                        in report
                            .structuredReport!
                            .extractionReview!
                            .reasons) ...[
                      const SizedBox(height: 4),
                      Text('• $reason'),
                    ],
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _openPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('View original'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (results.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Your results',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap a result to understand what the test measures.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              key: const Key('report-detail-lab-values'),
              children: [
                for (final result in results)
                  _ResultCard(
                    result: result,
                    onTap: () => _openResult(result),
                  ),
              ],
            ),
          ],
          if (results.isEmpty && report.status == 'parsed') ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No test values were found in this report. Open the original file to check its contents.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
          if (summary != null && summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              key: const Key('report-detail-summary'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    const AiDisclaimerNote(
                      key: Key('report-detail-summary-disclaimer'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SectionCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  key: const Key('report-detail-view-pdf'),
                  onPressed: _openPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('View original'),
                ),
                OutlinedButton.icon(
                  key: const Key('report-detail-view-attempts'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ProcessingHistoryScreen(
                        reportId: report.id,
                        reportsRepository: widget.reportsRepository,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('Attempt history'),
                ),
                OutlinedButton.icon(
                  key: const Key('report-detail-health-history'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => HealthHistoryScreen(
                        profileId: widget.profileId,
                        reportsRepository: widget.reportsRepository,
                        profilesRepository: widget.profilesRepository,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Compare reports'),
                ),
                OutlinedButton.icon(
                  key: const Key('report-detail-delete'),
                  onPressed: _onDeleteReport,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                if (report.parsedTranscript != null &&
                    report.parsedTranscript!.trim().isNotEmpty)
                  FilledButton.tonalIcon(
                    key: const Key('report-detail-open-parsed-reader'),
                    onPressed: _openParsedReportReader,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Read Parsed Report'),
                  ),
              ],
            ),
          ),
          if (_profiles.where((p) => p.id != widget.profileId).isNotEmpty) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('report-detail-reassign'),
              onPressed: _showReassignDialog,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Reassign to profile'),
            ),
            if (_errorMessage != null &&
                report.status != 'unparsed' &&
                report.status != 'content_not_recognized' &&
                report.status != 'failed_transient' &&
                report.status != 'failed_terminal') ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                key: const Key('report-detail-reassign-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ],
          if (report.status == 'unparsed' ||
              report.status == 'content_not_recognized' ||
              report.status == 'failed_transient' ||
              report.status == 'failed_terminal') ...[
            const SizedBox(height: 12),
            if (report.status == 'failed_transient') ...[
              const Text(
                'Processing stopped before it finished. Your file is saved. Tap Retry to try again.',
              ),
              const SizedBox(height: 8),
            ],
            if (report.status == 'content_not_recognized') ...[
              Text(
                'We could not read all results reliably. Your original file is saved; no manual correction is required.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                key: const Key('report-detail-retry-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            FilledButton(
              key: const Key('report-detail-retry'),
              onPressed: _onRetryParse,
              child: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('report-detail-keep-file'),
              onPressed: _onKeepFile,
              child: const Text('Keep file anyway'),
            ),
          ],
          if (report.structuredReport != null &&
              (report.structuredReport!.sections.isNotEmpty ||
                  ((report.structuredReport!.labDetails?.name ?? '')
                      .trim()
                      .isNotEmpty))) ...[
            const SizedBox(height: 24),
            const _SectionTitle('Patient details', icon: Icons.person_outline),
            const SizedBox(height: 8),
            _SectionCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (report.structuredReport!.patientDetails.name != null)
                    _InfoPill(
                      label: 'Name',
                      value: report.structuredReport!.patientDetails.name!,
                    ),
                  if (report.structuredReport!.patientDetails.age != null)
                    _InfoPill(
                      label: 'Age',
                      value: report.structuredReport!.patientDetails.age!,
                    ),
                  if (report.structuredReport!.patientDetails.gender != null)
                    _InfoPill(
                      label: 'Gender',
                      value: report.structuredReport!.patientDetails.gender!,
                    ),
                  if (report.structuredReport!.patientDetails.bookingId != null)
                    _InfoPill(
                      label: 'Booking ID',
                      value: report.structuredReport!.patientDetails.bookingId!,
                    ),
                  if (report
                          .structuredReport!
                          .patientDetails
                          .sampleCollectionDate !=
                      null)
                    _InfoPill(
                      label: 'Sample Collection',
                      value: AppDateFormat.fromRawWithRelative(
                        report
                            .structuredReport!
                            .patientDetails
                            .sampleCollectionDate!,
                      ),
                    ),
                ],
              ),
            ),
            if (((report.structuredReport!.labDetails?.name ?? '')
                .trim()
                .isNotEmpty)) ...[
              const SizedBox(height: 16),
              const _SectionTitle(
                'Lab details',
                icon: Icons.local_hospital_outlined,
              ),
              const SizedBox(height: 8),
              _SectionCard(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (report.structuredReport!.labDetails!.name != null)
                      _InfoPill(
                        label: 'Lab Name',
                        value: report.structuredReport!.labDetails!.name!,
                      ),
                    if (report.structuredReport!.labDetails!.address != null)
                      _InfoPill(
                        label: 'Address',
                        value: report.structuredReport!.labDetails!.address!,
                      ),
                    if (report.structuredReport!.labDetails!.phone != null)
                      _InfoPill(
                        label: 'Phone',
                        value: report.structuredReport!.labDetails!.phone!,
                      ),
                    if (report.structuredReport!.labDetails!.email != null)
                      _InfoPill(
                        label: 'Email',
                        value: report.structuredReport!.labDetails!.email!,
                      ),
                    if (report.structuredReport!.labDetails!.location != null)
                      _InfoPill(
                        label: 'Location',
                        value: report.structuredReport!.labDetails!.location!,
                      ),
                  ],
                ),
              ),
            ],
          ],
          if (report.parsedTranscript != null &&
              report.parsedTranscript!.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Parsed report is available in Reader mode for easier access and better readability.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.onTap});

  final ExtractedLabValue result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final position = compareWithPrintedRange(result);
    final palette = ResultPalette.forPosition(context, position);
    final status = switch (position) {
      RangePosition.below => 'Below range',
      RangePosition.above => 'Above range',
      RangePosition.within => 'In listed range',
      RangePosition.unknown => 'Range unclear',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 0,
        color: palette.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          key: Key('lab-row-${result.parameterName}'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        result.parameterName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  result.unit?.trim().isNotEmpty == true
                      ? '${result.value} ${result.unit}'
                      : result.value,
                  key: Key('lab-value-${result.parameterName}'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: palette.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                if (result.reviewState == 'needs_review') ...[
                  const Text(
                    'Automatic interpretation is unavailable for this test or unit.',
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: palette.foreground.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            palette.icon,
                            size: 15,
                            color: palette.foreground,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (result.referenceRange?.trim().isNotEmpty == true)
                      Text(
                        'Lab range ${result.referenceRange}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Understand this result  →',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ParsedReportReaderScreen extends StatelessWidget {
  const _ParsedReportReaderScreen({required this.rawText});

  final String rawText;

  @override
  Widget build(BuildContext context) {
    final blocks = _toBlocks(rawText);
    return Scaffold(
      appBar: AppBar(title: const Text('Parsed Report')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: blocks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final block = blocks[index];
          return _buildBlock(context, block);
        },
      ),
    );
  }

  Widget _buildBlock(BuildContext context, _ReaderBlock block) {
    switch (block.type) {
      case _ReaderBlockType.heading:
        return Text(
          block.text,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        );
      case _ReaderBlockType.bullet:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 8),
              child: Icon(
                Icons.circle,
                size: 7,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: SelectableText(
                block.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        );
      case _ReaderBlockType.paragraph:
        return SelectableText(
          block.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        );
    }
  }

  List<_ReaderBlock> _toBlocks(String text) {
    final lines = text
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((e) => e.trimRight())
        .toList();
    final blocks = <_ReaderBlock>[];
    final paragraph = StringBuffer();

    void flushParagraph() {
      final value = paragraph.toString().trim();
      if (value.isNotEmpty) {
        blocks.add(_ReaderBlock(_ReaderBlockType.paragraph, value));
      }
      paragraph.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        flushParagraph();
        continue;
      }

      final heading = _stripMarkdownHeading(line);
      if (heading != null) {
        flushParagraph();
        blocks.add(_ReaderBlock(_ReaderBlockType.heading, heading));
        continue;
      }

      final bullet = _stripMarkdownBullet(line);
      if (bullet != null) {
        flushParagraph();
        blocks.add(_ReaderBlock(_ReaderBlockType.bullet, bullet));
        continue;
      }

      if (paragraph.isNotEmpty) paragraph.write(' ');
      paragraph.write(_stripInlineMarkdown(line));
    }
    flushParagraph();
    return blocks;
  }

  String? _stripMarkdownHeading(String line) {
    final match = RegExp(r'^#{1,6}\s+(.+)$').firstMatch(line);
    if (match != null) return _stripInlineMarkdown(match.group(1)!);
    final looksLikeAllCaps =
        line.length > 4 && line == line.toUpperCase() && !line.contains(':');
    if (looksLikeAllCaps) return _stripInlineMarkdown(line);
    return null;
  }

  String? _stripMarkdownBullet(String line) {
    final match = RegExp(r'^[-*]\s+(.+)$').firstMatch(line);
    if (match != null) return _stripInlineMarkdown(match.group(1)!);
    final numbered = RegExp(r'^\d+\.\s+(.+)$').firstMatch(line);
    if (numbered != null) return _stripInlineMarkdown(numbered.group(1)!);
    return null;
  }

  String _stripInlineMarkdown(String line) {
    return line
        .replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'__(.*?)__'), (m) => m.group(1) ?? '')
        .replaceAllMapped(RegExp(r'`(.*?)`'), (m) => m.group(1) ?? '')
        .trim();
  }
}

enum _ReaderBlockType { heading, paragraph, bullet }

class _ReaderBlock {
  const _ReaderBlock(this.type, this.text);

  final _ReaderBlockType type;
  final String text;
}
