import 'package:flutter/material.dart';

import '../reports_repository.dart';
import 'pdf_viewer_screen.dart';

/// Keeps OCR suggestions separate from saved results until the source is checked.
class ReportReviewScreen extends StatefulWidget {
  const ReportReviewScreen({
    super.key,
    required this.reportsRepository,
    required this.reportId,
    required this.fileName,
  });

  final ReportsRepository reportsRepository;
  final String reportId;
  final String fileName;

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends State<ReportReviewScreen> {
  ReportReview? _review;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final review = await widget.reportsRepository.getReportReview(
        widget.reportId,
      );
      if (mounted) {
        setState(() {
          _review = review;
          _loading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _reviewCandidate(ReportReviewCandidate candidate) async {
    final current = _review;
    if (current == null) return;
    var name = candidate.testRaw;
    var value = candidate.resultRaw ?? '';
    var unit = candidate.unitRaw ?? '';
    var range = candidate.rangeRaw ?? '';
    var sourceOpened = false;
    var sourceChecked = false;
    var saving = false;
    var version = current.reviewVersion;
    var decisionSaved = false;
    String? saveError;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          title: const Text('Check detected result'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compare this row with the original report. Correct any OCR mistakes before saving.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('review-view-original'),
                    onPressed: () async {
                      final inspected = await Navigator.of(dialogContext)
                          .push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (sourceContext) => PdfViewerScreen(
                                reportsRepository: widget.reportsRepository,
                                reportId: widget.reportId,
                                fileName: widget.fileName,
                                reviewMode: true,
                                onBack: () => Navigator.of(sourceContext).pop(),
                              ),
                            ),
                          );
                      if (dialogContext.mounted && inspected == true) {
                        updateDialog(() => sourceOpened = true);
                      }
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('View original report'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('review-test-name'),
                    initialValue: name,
                    onChanged: (text) => updateDialog(() => name = text),
                    decoration: const InputDecoration(labelText: 'Test name'),
                  ),
                  TextFormField(
                    key: const Key('review-result-value'),
                    initialValue: value,
                    onChanged: (text) => updateDialog(() => value = text),
                    decoration: const InputDecoration(labelText: 'Result'),
                  ),
                  TextFormField(
                    key: const Key('review-unit'),
                    initialValue: unit,
                    onChanged: (text) => updateDialog(() => unit = text),
                    decoration: const InputDecoration(
                      labelText: 'Unit (optional)',
                    ),
                  ),
                  TextFormField(
                    key: const Key('review-range'),
                    initialValue: range,
                    onChanged: (text) => updateDialog(() => range = text),
                    decoration: const InputDecoration(
                      labelText: 'Reference range (optional)',
                    ),
                  ),
                  CheckboxListTile(
                    key: const Key('review-source-checked'),
                    contentPadding: EdgeInsets.zero,
                    value: sourceChecked,
                    onChanged: sourceOpened && !saving
                        ? (checked) => updateDialog(
                            () => sourceChecked = checked ?? false,
                          )
                        : null,
                    title: const Text(
                      'I checked this result against the original report',
                    ),
                  ),
                  if (saveError != null)
                    Text(
                      saveError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving
                  ? null
                  : () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('review-save-result'),
              onPressed:
                  !sourceChecked ||
                      saving ||
                      name.trim().isEmpty ||
                      value.trim().isEmpty
                  ? null
                  : () async {
                      updateDialog(() {
                        saving = true;
                        saveError = null;
                      });
                      try {
                        if (!decisionSaved) {
                          final changed =
                              name.trim() != candidate.testRaw ||
                              value.trim() != (candidate.resultRaw ?? '') ||
                              unit.trim() != (candidate.unitRaw ?? '') ||
                              range.trim() != (candidate.rangeRaw ?? '');
                          version = await widget.reportsRepository
                              .reviewReportCandidate(
                                widget.reportId,
                                candidate.id,
                                expectedVersion: version,
                                action: changed ? 'corrected' : 'confirmed',
                                testRaw: name.trim(),
                                resultRaw: value.trim(),
                                unitRaw: unit.trim().isEmpty
                                    ? null
                                    : unit.trim(),
                                rangeRaw: range.trim().isEmpty
                                    ? null
                                    : range.trim(),
                              );
                          decisionSaved = true;
                        }
                        await widget.reportsRepository.applyReviewedCandidate(
                          widget.reportId,
                          candidate.id,
                          expectedVersion: version,
                        );
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(true);
                        }
                      } catch (error) {
                        if (dialogContext.mounted) {
                          updateDialog(() {
                            saving = false;
                            saveError = error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            );
                          });
                        }
                      }
                    },
              child: saving
                  ? const Text('Saving…')
                  : const Text('Save verified result'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final review = _review;
    return Scaffold(
      appBar: AppBar(title: const Text('Review detected results')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(onPressed: _load, child: const Text('Try again')),
                ],
              ),
            )
          : review == null || review.candidates.isEmpty
          ? const Center(
              child: Text(
                'No results were detected. View the original report or retry processing.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Detected values need to be checked against the original report before they become saved results.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (review.partial) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Some rows may be missing. Inspect the entire original report.',
                  ),
                ],
                const SizedBox(height: 12),
                for (final candidate in review.candidates)
                  Card(
                    child: ListTile(
                      key: Key('review-candidate-${candidate.id}'),
                      title: Text(candidate.testRaw),
                      subtitle: Text(
                        '${candidate.resultRaw ?? 'Unreadable'}${candidate.unitRaw == null ? '' : ' ${candidate.unitRaw}'}',
                      ),
                      trailing: review.applied.contains(candidate.id)
                          ? const Icon(
                              Icons.check_circle,
                              semanticLabel: 'Verified',
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: review.applied.contains(candidate.id)
                          ? null
                          : () => _reviewCandidate(candidate),
                    ),
                  ),
              ],
            ),
    );
  }
}
