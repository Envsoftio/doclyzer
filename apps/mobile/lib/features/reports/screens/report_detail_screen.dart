import 'package:flutter/material.dart';

import '../reports_repository.dart';
import 'pdf_viewer_screen.dart';
import 'trend_chart_screen.dart';

enum _ReportDetailState { loading, loaded, error }

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.reportsRepository,
    required this.reportId,
    required this.profileId,
    required this.onBack,
  });

  final ReportsRepository reportsRepository;
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

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _state = _ReportDetailState.loading;
      _errorMessage = null;
    });
    try {
      final report =
          await widget.reportsRepository.getReport(widget.reportId);
      if (mounted) {
        setState(() {
          _report = report;
          _state = _ReportDetailState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _ReportDetailState.error;
          _errorMessage =
              e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _openTrendChart(String parameterName) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => TrendChartScreen(
          reportsRepository: widget.reportsRepository,
          profileId: widget.profileId,
          parameterName: parameterName,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
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

  Future<void> _onRetryParse() async {
    if (_report == null) return;
    setState(() {
      _state = _ReportDetailState.loading;
      _errorMessage = null;
    });
    try {
      final report =
          await widget.reportsRepository.retryParse(_report!.id);
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
          _errorMessage =
              e.toString().replaceFirst('Exception: ', '');
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

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_state == _ReportDetailState.loading) {
      return const Center(
        key: const Key('report-detail-loading'),
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
            FilledButton(
              onPressed: _loadReport,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final report = _report!;
    return SingleChildScrollView(
      key: const Key('report-detail-content'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.originalFileName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_statusLabel(report.status)} · ${_formatDate(report.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('report-detail-view-pdf'),
            onPressed: _openPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('View PDF'),
          ),
          if (report.status == 'unparsed' ||
              report.status == 'content_not_recognized') ...[
            const SizedBox(height: 12),
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
          if (report.extractedLabValues.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Lab values',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Card(
              key: const Key('report-detail-lab-values'),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.extractedLabValues.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lab = report.extractedLabValues[index];
                  return InkWell(
                    key: Key('lab-row-${lab.parameterName}'),
                    onTap: () => _openTrendChart(lab.parameterName),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              lab.parameterName.isNotEmpty
                                  ? lab.parameterName
                                  : '—',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              lab.value.isNotEmpty ? lab.value : '—',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          if (lab.unit != null && lab.unit!.isNotEmpty)
                            Text(
                              lab.unit!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (lab.sampleDate != null &&
                              lab.sampleDate!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                lab.sampleDate!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            Text(
              'No structured data',
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
