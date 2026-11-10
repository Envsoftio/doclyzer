import 'package:mobile/l10n/l10n.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'dart:async';

import '../report_processing_store.dart';
import 'package:flutter/material.dart';

import '../../profiles/profiles_repository.dart';
import '../reports_repository.dart';
import '../result_palette.dart';
import '../result_range.dart';
import '../../../shared/ai_disclaimer_note.dart';
import '../../../shared/localized_description.dart';
import '../../../shared/app_date_format.dart';
import 'health_history_screen.dart';
import 'compare_reports_screen.dart';
import 'pdf_viewer_screen.dart';
import 'processing_history_screen.dart';
import 'result_insight_screen.dart';
import 'result_correction_screen.dart';
import 'report_review_screen.dart';
import 'trend_chart_screen.dart';

enum _ReportDetailState { loading, loaded, error }

enum _ReportAction { attempts, compare, reassign, readParsed, delete }

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportsRepository,
    required this.profilesRepository,
    required this.reportId,
    required this.profileId,
    required this.onBack,
    this.onShareReport,
  });

  final ReportsRepository reportsRepository;
  final ProfilesRepository profilesRepository;
  final String reportId;
  final String profileId;
  final VoidCallback onBack;
  final ValueChanged<Report>? onShareReport;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen>
    with SingleTickerProviderStateMixin {
  _ReportDetailState _state = _ReportDetailState.loading;
  Report? _report;
  String? _errorMessage;
  List<Profile> _profiles = [];
  bool _acknowledging = false;
  bool _refreshing = false;
  bool _summaryRequesting = false;
  String? _summaryError;
  String? _processingState;
  int _loadVersion = 0;
  late final TabController _reportTabController;
  final GlobalKey _reportTabsKey = GlobalKey();
  int _selectedReportTab = 0;

  void _onProcessingChanged() {
    if (!mounted) return;
    final processing = ReportProcessingStore.instance.reports[widget.reportId];
    if (processing == null) return;
    final state = '${processing['version']}|${processing['status']}';
    if (state == _processingState) return;
    _processingState = state;
    _loadReport();
  }

  @override
  void dispose() {
    ReportProcessingStore.instance.removeListener(_onProcessingChanged);
    _reportTabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _reportTabController = TabController(length: 2, vsync: this);
    ReportProcessingStore.instance.addListener(_onProcessingChanged);
    final processing = ReportProcessingStore.instance.reports[widget.reportId];
    if (processing != null) {
      _processingState = '${processing['version']}|${processing['status']}';
    }
    _loadReport();
    _loadProfiles();
  }

  void _selectReportTab(int index) {
    setState(() => _selectedReportTab = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tabsContext = _reportTabsKey.currentContext;
      if (mounted && tabsContext != null) {
        Scrollable.ensureVisible(
          tabsContext,
          duration: const Duration(milliseconds: 220),
          alignment: 0.08,
        );
      }
    });
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
    final version = ++_loadVersion;
    setState(() {
      if (_report == null) _state = _ReportDetailState.loading;
      _refreshing = _report != null;
      _errorMessage = null;
    });
    try {
      final report = await widget.reportsRepository
          .getReport(widget.reportId)
          .timeout(const Duration(seconds: 20));
      if (mounted && version == _loadVersion) {
        setState(() {
          _report = report;
          _state = _ReportDetailState.loaded;
          _refreshing = false;
        });
        final store = ReportProcessingStore.instance;
        final processing = store.reports[widget.reportId];
        if (!_acknowledging &&
            report.status == 'parsed' &&
            processing != null &&
            processing['status'] == 'ready' &&
            processing['acknowledgedAt'] == null) {
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
      if (mounted && version == _loadVersion) {
        setState(() {
          _state = _report == null
              ? _ReportDetailState.error
              : _ReportDetailState.loaded;
          _refreshing = false;
          _errorMessage = e is TimeoutException
              ? context.l10n.reportLoadSlow
              : e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _requestSummary({bool refresh = false}) async {
    if (_summaryRequesting ||
        (!refresh && _report?.summary?.trim().isNotEmpty == true) ||
        _report?.summaryStatus == 'pending') {
      return;
    }
    setState(() {
      _summaryRequesting = true;
      _summaryError = null;
    });
    try {
      await widget.reportsRepository.requestSummary(
        widget.reportId,
        refresh: refresh,
      );
      if (mounted) await _loadReport();
    } catch (_) {
      // Keep the report readable and show a retry next to the summary.
      if (mounted) await _loadReport();
      if (mounted) {
        setState(() {
          _summaryError = refresh
              ? context.l10n.summaryUpdateFailed
              : context.l10n.summaryCreateFailed;
        });
      }
    } finally {
      if (mounted) setState(() => _summaryRequesting = false);
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
                onShareReport: widget.onShareReport,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openResult(ExtractedLabValue result) {
    final cancellation = InsightRequestCancellation();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => ResultInsightScreen(
          result: result,
          loadInsight: () => widget.reportsRepository.getResultInsight(
            widget.reportId,
            result,
            cancellation: cancellation,
          ),
          loadLocalizedInsight: (locale) =>
              widget.reportsRepository.getResultInsight(
                widget.reportId,
                result,
                locale: locale,
                cancellation: cancellation,
              ),
          cancellation: cancellation,
          onViewTrend: () => _openTrendChart(result.parameterName, result.unit),
          onViewOriginal: _openPdf,
          onReviewResult: result.id == null
              ? null
              : () async {
                  final updated = await Navigator.of(ctx).push<Report>(
                    MaterialPageRoute<Report>(
                      builder: (_) => ResultCorrectionScreen(
                        reportId: widget.reportId,
                        result: result,
                        reportsRepository: widget.reportsRepository,
                        onViewOriginal: _openPdf,
                      ),
                    ),
                  );
                  if (updated == null) return;
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (mounted) await _loadReport();
                },
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

  Future<void> _openReview() async {
    final report = _report;
    if (report == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReportReviewScreen(
          reportsRepository: widget.reportsRepository,
          reportId: report.id,
          fileName: report.originalFileName,
        ),
      ),
    );
    if (mounted) await _loadReport();
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

  void _onReportAction(_ReportAction action) {
    final report = _report;
    if (report == null) return;
    switch (action) {
      case _ReportAction.attempts:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ProcessingHistoryScreen(
              reportId: report.id,
              reportsRepository: widget.reportsRepository,
            ),
          ),
        );
      case _ReportAction.compare:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => CompareReportsScreen(
              profileId: widget.profileId,
              profileName:
                  report.profileName ??
                  _profiles
                      .where((profile) => profile.id == widget.profileId)
                      .firstOrNull
                      ?.name ??
                  context.l10n.yourProfile,
              reportsRepository: widget.reportsRepository,
            ),
          ),
        );
      case _ReportAction.reassign:
        _showReassignDialog();
      case _ReportAction.readParsed:
        _openParsedReportReader();
      case _ReportAction.delete:
        _onDeleteReport();
    }
  }

  void _openTrends() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => HealthHistoryScreen(
          profileId: widget.profileId,
          reportsRepository: widget.reportsRepository,
          profilesRepository: widget.profilesRepository,
          onShareReport: widget.onShareReport,
        ),
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
    } catch (_) {
      if (mounted) {
        setState(() {
          _state = _ReportDetailState.loaded;
          _errorMessage = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.reassignFailed)));
      }
    }
  }

  Future<void> _onDeleteReport() async {
    final report = _report;
    if (report == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.confirmRecycle),
        content: Text(context.l10n.recycleHelp),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.delete),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reportRecycled)));
      widget.onBack();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _ReportDetailState.loaded;
        _errorMessage = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.reportDeleteFailed)));
    }
  }

  Future<void> _showReassignDialog() async {
    final report = _report;
    if (report == null) return;
    final currentProfileId = report.profileId;
    final otherProfiles = _profiles
        .where((p) => p.id != currentProfileId)
        .toList();
    if (otherProfiles.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.addProfileBeforeMove)),
      );
      return;
    }
    final selected = await showDialog<Profile>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(context.l10n.moveReport),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              context.l10n.moveReportHelp,
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
          ),
          for (final profile in otherProfiles)
            SimpleDialogOption(
              key: Key('reassign-profile-${profile.id}'),
              onPressed: () => Navigator.of(ctx).pop(profile),
              child: Text(profile.name),
            ),
        ],
      ),
    );
    if (selected == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.confirmMoveReport),
        content: Text(
          '${report.originalFileName} will appear under ${selected.name} instead of the current profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.moveReport),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _onReassign(selected.id);
  }

  void _showSampleDateHelp(bool hasMultipleDates) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.aboutSampleDates),
        content: Text(
          hasMultipleDates
              ? context.l10n.multipleDatesHelp
              : context.l10n.missingDateHelp,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.gotIt),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'uploading':
        return context.l10n.uploading;
      case 'queued':
        return context.l10n.waitingToProcess;
      case 'parsing':
        return context.l10n.readingReport;
      case 'parsed':
        return context.l10n.readyToReview;
      case 'content_not_recognized':
        return context.l10n.someResultsNeedReview;
      case 'unparsed':
        return context.l10n.couldNotReadReport;
      case 'failed_transient':
        return context.l10n.processingStopped;
      case 'failed_terminal':
        return context.l10n.couldNotProcessReport;
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
        title: Text(context.l10n.reportDetails),
        leading: IconButton(
          key: const Key('report-detail-back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          if (_report != null && _state == _ReportDetailState.loaded) ...[
            if (_report!.status == 'parsed' && widget.onShareReport != null)
              IconButton(
                key: const Key('report-detail-share'),
                tooltip: context.l10n.shareReport,
                onPressed: () => widget.onShareReport!(_report!),
                icon: const Icon(Icons.share_outlined),
              ),
            PopupMenuButton<_ReportAction>(
              key: const Key('report-detail-more-actions'),
              tooltip: context.l10n.moreReportActions,
              onSelected: _onReportAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _ReportAction.attempts,
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text(context.l10n.attemptHistory),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _ReportAction.compare,
                  child: ListTile(
                    leading: Icon(Icons.show_chart),
                    title: Text(context.l10n.compareReports),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (_profiles.any((p) => p.id != _report!.profileId))
                  PopupMenuItem(
                    value: _ReportAction.reassign,
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text(context.l10n.moveReport),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                if (_report!.parsedTranscript?.trim().isNotEmpty == true)
                  PopupMenuItem(
                    value: _ReportAction.readParsed,
                    child: ListTile(
                      leading: Icon(Icons.menu_book_outlined),
                      title: Text(context.l10n.readParsedReport),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                PopupMenuItem(
                  value: _ReportAction.delete,
                  child: ListTile(
                    key: const Key('report-detail-delete'),
                    leading: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      context.l10n.moveRecycle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_refreshing)
            const LinearProgressIndicator(key: Key('report-detail-refreshing')),
          if (_errorMessage != null && _report != null)
            MaterialBanner(
              content: Text(context.l10n.reportRefreshFailed),
              actions: [
                TextButton(
                  onPressed: _loadReport,
                  child: Text(context.l10n.retry),
                ),
              ],
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

  Widget _buildSummarySection(Report report) {
    final summary = report.summary?.trim();
    final hasSummary = summary != null && summary.isNotEmpty;
    final isWaiting = _summaryRequesting || report.summaryStatus == 'pending';
    return Column(
      key: const Key('report-detail-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.reportSummary,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasSummary) ...[
          LocalizedDescription(
            english: summary,
            load: (locale) => widget.reportsRepository.getLocalizedSummary(
              widget.reportId,
              locale,
            ),
            builder: (text) => _ReportSummaryBody(summary: text),
          ),
          const SizedBox(height: 12),
          const AiDisclaimerNote(key: Key('report-detail-summary-disclaimer')),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const Key('report-detail-summary-refresh'),
            onPressed: isWaiting ? null : () => _requestSummary(refresh: true),
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.updateSummary),
          ),
          if (_summaryRequesting) const LinearProgressIndicator(),
          if (_summaryError != null) Text(_summaryError!),
        ] else if (isWaiting) ...[
          const LinearProgressIndicator(
            key: Key('report-detail-summary-progress'),
          ),
          const SizedBox(height: 12),
          Text(context.l10n.summaryLoading),
          if (!_summaryRequesting) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.checkSummary),
            ),
          ],
        ] else ...[
          Text(
            _summaryError ??
                (report.summaryStatus == 'failed'
                    ? context.l10n.summaryFailed
                    : context.l10n.summaryPlaceholder),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('report-detail-summary-retry'),
            onPressed: _requestSummary,
            icon: const Icon(Icons.refresh),
            label: Text(
              report.summaryStatus == 'failed' || _summaryError != null
                  ? context.l10n.retrySummary
                  : context.l10n.generateSummary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    if (_state == _ReportDetailState.loading) {
      return Center(
        key: Key('report-detail-loading'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(context.l10n.loadingResults, textAlign: TextAlign.center),
          ],
        ),
      );
    }
    if (_state == _ReportDetailState.error) {
      return Center(
        key: const Key('report-detail-error'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage ?? context.l10n.somethingWrong,
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadReport,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    final report = _report!;
    final statusColor =
        report.structuredReport?.extractionReview?.required == true
        ? Colors.orange.shade700
        : _statusColor(context, report.status);
    final results = _displayResults(report);
    final sampleDate = report.collectionDate?.trim();
    final hasMultipleSampleDates = report.collectionDateStatus == 'multiple';
    final hasSampleDate =
        !hasMultipleSampleDates && sampleDate != null && sampleDate.isNotEmpty;
    final mutedStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return SingleChildScrollView(
      key: const Key('report-detail-content'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const Key('report-detail-overview'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report.originalFileName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (report.structuredReport?.labDetails?.name
                        ?.trim()
                        .isNotEmpty ==
                    true) ...[
                  const SizedBox(height: 4),
                  Text(
                    report.structuredReport!.labDetails!.name!.trim(),
                    style: mutedStyle,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '● ',
                            style: TextStyle(color: statusColor),
                          ),
                          TextSpan(
                            text:
                                report
                                        .structuredReport
                                        ?.extractionReview
                                        ?.required ==
                                    true
                                ? context.l10n.someResultsNeedReview
                                : _statusLabel(report.status),
                          ),
                        ],
                      ),
                      style: mutedStyle,
                    ),
                    Text(
                      'Uploaded ${AppDateFormat.date(report.createdAt)}',
                      style: mutedStyle,
                    ),
                    if (hasSampleDate)
                      Text(
                        'Sampled ${AppDateFormat.fromRaw(sampleDate)}',
                        style: mutedStyle,
                      )
                    else
                      InkWell(
                        key: const Key('report-detail-sample-date-help'),
                        onTap: () =>
                            _showSampleDateHelp(hasMultipleSampleDates),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: hasMultipleSampleDates
                                      ? context.l10n.multipleSampleDates
                                      : context.l10n.missingSampleDate,
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 15,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            style: mutedStyle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              runSpacing: 0,
              children: [
                TextButton.icon(
                  key: const Key('report-detail-open-trends'),
                  onPressed: _openTrends,
                  icon: const Icon(Icons.show_chart_outlined, size: 18),
                  label: Text(context.l10n.viewTrends),
                ),
                TextButton.icon(
                  key: const Key('report-detail-open-original'),
                  onPressed: _openPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: Text(context.l10n.originalFile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (report.status == 'parsed' &&
              (results.isNotEmpty ||
                  report.summary?.isNotEmpty == true ||
                  report.summaryStatus == 'failed' ||
                  report.summaryStatus == 'pending')) ...[
            Container(
              key: _reportTabsKey,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                key: const Key('report-detail-tabs'),
                controller: _reportTabController,
                onTap: _selectReportTab,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                labelColor: Theme.of(context).colorScheme.onPrimary,
                unselectedLabelColor: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant,
                tabs: [
                  Tab(text: context.l10n.testValues),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child: Text(context.l10n.summary)),
                        if (report.summaryStatus == 'failed' &&
                            report.summary == null) ...[
                          const SizedBox(width: 5),
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: _selectedReportTab == 1
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_selectedReportTab == 1) ...[
              _buildSummarySection(report),
              const SizedBox(height: 12),
            ],
          ],
          if (report.status == 'uploading' ||
              report.status == 'queued' ||
              report.status == 'parsing') ...[
            const SizedBox(height: 16),
            Text(
              context.l10n.reportAnalyzing,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const Key('report-detail-check-status'),
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.checkStatus),
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
                      context.l10n.extractionIncompleteTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(context.l10n.extractionIncompleteHelp),
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
                      label: Text(context.l10n.viewOriginal),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (results.isNotEmpty &&
              (report.status != 'parsed' || _selectedReportTab == 0)) ...[
            const SizedBox(height: 12),
            Text(
              report.status == 'content_not_recognized'
                  ? context.l10n.verifiedResults
                  : 'Test values (${results.length})',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              report.status == 'content_not_recognized'
                  ? context.l10n.verifiedRowsHelp
                  : context.l10n.resultTapHelp,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              key: const Key('report-detail-lab-values'),
              builder: (context, constraints) {
                final twoColumns =
                    constraints.maxWidth >= 320 &&
                    MediaQuery.textScalerOf(context).scale(16) <= 20;
                final cardWidth = twoColumns
                    ? (constraints.maxWidth - 8) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 8,
                  children: [
                    for (final result in results)
                      SizedBox(
                        width: cardWidth,
                        child: _ResultCard(
                          result: result,
                          compact: twoColumns,
                          onTap: () => _openResult(result),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          if (results.isEmpty &&
              report.status == 'parsed' &&
              _selectedReportTab == 0) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.noTestValues,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
          if (report.status == 'unparsed' ||
              report.status == 'content_not_recognized' ||
              report.status == 'failed_transient' ||
              report.status == 'failed_terminal') ...[
            const SizedBox(height: 12),
            if (report.status == 'failed_transient') ...[
              Text(context.l10n.processingRetryHelp),
              const SizedBox(height: 8),
            ],
            if (report.status == 'content_not_recognized') ...[
              Text(
                context.l10n.resultsNeedCheck,
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
            if (report.status == 'content_not_recognized' ||
                report.status == 'unparsed') ...[
              FilledButton.icon(
                key: const Key('report-detail-review-results'),
                onPressed: _openReview,
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(context.l10n.reviewResults),
              ),
              const SizedBox(height: 8),
            ],
            if (report.status != 'content_not_recognized' || results.isEmpty)
              FilledButton(
                key: const Key('report-detail-retry'),
                onPressed: _onRetryParse,
                child: Text(context.l10n.retry),
              ),
            if (report.status != 'content_not_recognized') ...[
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('report-detail-keep-file'),
                onPressed: _onKeepFile,
                child: Text(context.l10n.keepFile),
              ),
            ],
          ],
          if (report.structuredReport != null &&
              (report.structuredReport!.sections.isNotEmpty ||
                  ((report.structuredReport!.labDetails?.name ?? '')
                      .trim()
                      .isNotEmpty))) ...[
            const SizedBox(height: 24),
            _SectionTitle(
              context.l10n.patientDetails,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 8),
            _SectionCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (report.structuredReport!.patientDetails.name != null)
                    _InfoPill(
                      label: context.l10n.name,
                      value: report.structuredReport!.patientDetails.name!,
                    ),
                  if (report.structuredReport!.patientDetails.age != null)
                    _InfoPill(
                      label: context.l10n.age,
                      value: report.structuredReport!.patientDetails.age!,
                    ),
                  if (report.structuredReport!.patientDetails.gender != null)
                    _InfoPill(
                      label: context.l10n.gender,
                      value: report.structuredReport!.patientDetails.gender!,
                    ),
                  if (report.structuredReport!.patientDetails.bookingId != null)
                    _InfoPill(
                      label: context.l10n.bookingId,
                      value: report.structuredReport!.patientDetails.bookingId!,
                    ),
                  if (report
                          .structuredReport!
                          .patientDetails
                          .sampleCollectionDate !=
                      null)
                    _InfoPill(
                      label: context.l10n.sampleCollection,
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
              _SectionTitle(
                context.l10n.labDetails,
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
                        label: context.l10n.labName,
                        value: report.structuredReport!.labDetails!.name!,
                      ),
                    if (report.structuredReport!.labDetails!.address != null)
                      _InfoPill(
                        label: context.l10n.address,
                        value: report.structuredReport!.labDetails!.address!,
                      ),
                    if (report.structuredReport!.labDetails!.phone != null)
                      _InfoPill(
                        label: context.l10n.phone,
                        value: report.structuredReport!.labDetails!.phone!,
                      ),
                    if (report.structuredReport!.labDetails!.email != null)
                      _InfoPill(
                        label: context.l10n.email,
                        value: report.structuredReport!.labDetails!.email!,
                      ),
                    if (report.structuredReport!.labDetails!.location != null)
                      _InfoPill(
                        label: context.l10n.location,
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
              context.l10n.readerModeHelp,
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

class _ReportSummaryBody extends StatelessWidget {
  const _ReportSummaryBody({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final readingStyle = TextStyle(
      inherit: false,
      fontSize: 16,
      fontFamilyFallback: AppTheme.scriptFonts,
      textBaseline: TextBaseline.alphabetic,
      height: 1.5,
      color: colors.onSurface,
    );
    const headings = {
      'Overview',
      'Results to discuss',
      'Other results',
      'What to ask your clinician',
    };
    final sections = summary.trim().split(RegExp(r'\n\s*\n'));
    return Column(
      key: const Key('report-detail-summary-body'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          if (section != sections.first) const SizedBox(height: 16),
          if (headings.contains(section.split('\n').first)) ...[
            Text(
              section.split('\n').first,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            SelectableText(
              section.substring(section.indexOf('\n') + 1).trim(),
              style: readingStyle,
            ),
          ] else
            SelectableText(section, style: readingStyle),
        ],
      ],
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
  const _ResultCard({
    required this.result,
    required this.onTap,
    this.compact = false,
  });

  final ExtractedLabValue result;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final position = compareWithPrintedRange(result);
    final palette = ResultPalette.forPosition(context, position);
    final status = switch (position) {
      RangePosition.below => context.l10n.belowRange,
      RangePosition.above => context.l10n.aboveRange,
      RangePosition.within => context.l10n.withinRange,
      RangePosition.unknown => context.l10n.rangeUnclear,
    };
    final reviewNotice = result.reviewState != 'needs_review'
        ? null
        : result.reviewVersion == 0 &&
              result.sourceSnapshot?['valueSource'] == 'ai_suggestion'
        ? 'Value checked by AI during processing. Original OCR: ${result.sourceSnapshot?['originalValue']}. Confirm it against the report.'
        : result.sourceSnapshot?['rangeSource'] == 'ai_suggestion'
        ? context.l10n.aiRangeHelp
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        color: palette.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          key: Key('lab-row-${result.parameterName}'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        result.parameterName,
                        style:
                            (compact
                                    ? theme.textTheme.titleSmall
                                    : theme.textTheme.titleMedium)
                                ?.copyWith(fontWeight: FontWeight.w700),
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
                const SizedBox(height: 4),
                Text(
                  result.unit?.trim().isNotEmpty == true
                      ? '${result.value} ${result.unit}'
                      : result.value,
                  key: Key('lab-value-${result.parameterName}'),
                  style:
                      (compact
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.headlineMedium)
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: palette.foreground,
                          ),
                ),
                const SizedBox(height: 8),
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
                          Flexible(
                            child: Text(
                              status,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (result.referenceRange?.trim().isNotEmpty == true)
                      Text(
                        context.l10n.labRangeValue(result.referenceRange!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                if (reviewNotice != null) ...[
                  const SizedBox(height: 8),
                  Text(reviewNotice, style: theme.textTheme.bodySmall),
                ],
                if (position == RangePosition.unknown) ...[
                  const SizedBox(height: 8),
                  Text(
                    unavailableRangeReason(result),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (position != RangePosition.unknown &&
                    preferredPrintedRange(result.referenceRange ?? '') !=
                        null) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.preferredRangeHelp,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
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
      appBar: AppBar(title: Text(context.l10n.parsedReport)),
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
