import 'package:flutter/material.dart';

import '../../profiles/profiles_repository.dart';
import '../reports_repository.dart';
import '../../../shared/ai_disclaimer_note.dart';
import 'health_history_screen.dart';
import 'pdf_viewer_screen.dart';
import 'processing_history_screen.dart';
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

  @override
  void initState() {
    super.initState();
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
    if (_report == null) return;
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

  Future<void> _showReassignDialog() async {
    final otherProfiles = _profiles
        .where((p) => p.id != widget.profileId)
        .toList();
    if (otherProfiles.isEmpty) return;
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
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
      body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
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
    final statusColor = _statusColor(context, report.status);

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
                      label: Text(_statusLabel(report.status)),
                    ),
                    Chip(
                      avatar: const Icon(Icons.event, size: 16),
                      label: Text(_formatDate(report.createdAt)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                  label: const Text('View PDF'),
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
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.show_chart),
                  label: const Text('Compare reports'),
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
                report.status != 'content_not_recognized') ...[
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
              report.status == 'content_not_recognized') ...[
            const SizedBox(height: 12),
            if (report.status == 'content_not_recognized') ...[
              Text(
                'This file does not appear to be a valid lab report. You can still keep and view the PDF.',
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
              report.structuredReport!.sections.isNotEmpty) ...[
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
                      value: report
                          .structuredReport!
                          .patientDetails
                          .sampleCollectionDate!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _SectionTitle(
              'Categorized test results',
              icon: Icons.analytics_outlined,
            ),
            const SizedBox(height: 8),
            ...report.structuredReport!.sections.map((section) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.heading,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        ...section.tests.map((test) {
                          final unitSuffix =
                              (test.unit != null && test.unit!.isNotEmpty)
                              ? ' ${test.unit}'
                              : '';
                          final referenceRange = test.referenceRange;
                          final abnormal = test.isAbnormal == true;
                          final normalRangeColor = abnormal
                              ? Colors.red.shade700
                              : Theme.of(context).colorScheme.onSurfaceVariant;
                          return InkWell(
                            onTap: () => _openTrendChart(test.parameterName),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      test.parameterName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${test.value}$unitSuffix',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: abnormal
                                                  ? Colors.red.shade700
                                                  : null,
                                              fontWeight: abnormal
                                                  ? FontWeight.w600
                                                  : null,
                                            ),
                                      ),
                                      if (referenceRange != null &&
                                          referenceRange.isNotEmpty)
                                        Text(
                                          'Normal: $referenceRange',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: normalRangeColor,
                                                fontWeight: abnormal
                                                    ? FontWeight.w600
                                                    : null,
                                              ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right, size: 16),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
          if (report.extractedLabValues.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _SectionTitle('Lab values', icon: Icons.biotech_outlined),
            const SizedBox(height: 4),
            Text(
              'Tap any value to open its trend graph and compare with older reports.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              key: const Key('report-detail-lab-values'),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.extractedLabValues.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lab = report.extractedLabValues[index];
                  final abnormal = lab.isAbnormal == true;
                  final referenceRange = lab.referenceRange;
                  final normalRangeColor = abnormal
                      ? Colors.red.shade700
                      : Theme.of(context).colorScheme.onSurfaceVariant;
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lab.value.isNotEmpty ? lab.value : '—',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: abnormal
                                            ? Colors.red.shade700
                                            : null,
                                        fontWeight: abnormal
                                            ? FontWeight.w600
                                            : null,
                                      ),
                                ),
                                if (referenceRange != null &&
                                    referenceRange.isNotEmpty)
                                  Text(
                                    'Normal: $referenceRange',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: normalRangeColor,
                                          fontWeight: abnormal
                                              ? FontWeight.w600
                                              : null,
                                        ),
                                  ),
                              ],
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
        Text(title, style: Theme.of(context).textTheme.titleSmall),
      ],
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
