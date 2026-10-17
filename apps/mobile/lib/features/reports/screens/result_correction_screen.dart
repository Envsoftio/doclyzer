import 'package:flutter/material.dart';

import '../../../core/api_client.dart';
import '../reports_repository.dart';

class ResultCorrectionScreen extends StatefulWidget {
  const ResultCorrectionScreen({
    super.key,
    required this.reportId,
    required this.result,
    required this.reportsRepository,
    required this.onViewOriginal,
  });

  final String reportId;
  final ExtractedLabValue result;
  final ReportsRepository reportsRepository;
  final VoidCallback onViewOriginal;

  @override
  State<ResultCorrectionScreen> createState() => _ResultCorrectionScreenState();
}

class _ResultCorrectionScreenState extends State<ResultCorrectionScreen> {
  late final TextEditingController _name;
  late final TextEditingController _value;
  late final TextEditingController _unit;
  late final TextEditingController _date;
  late final TextEditingController _range;
  bool _saving = false;
  bool _conflict = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final result = widget.result;
    _name = TextEditingController(text: result.parameterName);
    _value = TextEditingController(text: result.value);
    _unit = TextEditingController(text: result.unit ?? '');
    _date = TextEditingController(text: result.sampleDate ?? '');
    _range = TextEditingController(text: result.referenceRange ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _unit.dispose();
    _date.dispose();
    _range.dispose();
    super.dispose();
  }

  bool _validDate(String input) {
    if (input.isEmpty) return true;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) return false;
    final parsed = DateTime.tryParse(input);
    return parsed != null && parsed.toIso8601String().substring(0, 10) == input;
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    final value = _value.text.trim();
    final date = _date.text.trim();
    if (name.isEmpty || value.isEmpty) {
      setState(() => _error = 'Test name and result are required.');
      return;
    }
    if (!_validDate(date)) {
      setState(
        () => _error = 'Use a valid collection date in YYYY-MM-DD format.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _conflict = false;
    });
    try {
      final report = await widget.reportsRepository.correctResult(
        widget.reportId,
        widget.result,
        parameterName: name,
        value: value,
        unit: _unit.text.trim().isEmpty ? null : _unit.text.trim(),
        sampleDate: date.isEmpty ? null : date,
        referenceRange: _range.text.trim().isEmpty ? null : _range.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(report);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _conflict = error.code == 'REPORT_RESULT_VERSION_CONFLICT';
        _error = error.message;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save this correction. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.result.sourceSnapshot;
    return Scaffold(
      appBar: AppBar(title: const Text('Review result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Compare these fields with the original report before saving.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('correction-view-original'),
              onPressed: widget.onViewOriginal,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('View original report'),
            ),
            if (source != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Originally extracted'),
                      Text(
                        '${source['parameterName'] ?? ''}: ${source['value'] ?? ''} ${source['unit'] ?? ''}'
                            .trim(),
                      ),
                      Text(
                        'Collection date: ${source['sampleDate'] ?? 'Unknown'}',
                      ),
                      Text(
                        'Lab range: ${source['referenceRange'] ?? 'Unknown'}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              key: const Key('correction-name'),
              controller: _name,
              maxLength: 256,
              decoration: const InputDecoration(labelText: 'Test name'),
            ),
            TextField(
              key: const Key('correction-value'),
              controller: _value,
              maxLength: 512,
              decoration: const InputDecoration(labelText: 'Result as printed'),
            ),
            TextField(
              key: const Key('correction-unit'),
              controller: _unit,
              maxLength: 64,
              decoration: const InputDecoration(labelText: 'Unit (if shown)'),
            ),
            TextField(
              key: const Key('correction-date'),
              controller: _date,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Collection date',
                hintText: 'YYYY-MM-DD',
              ),
            ),
            TextField(
              key: const Key('correction-range'),
              controller: _range,
              maxLength: 256,
              decoration: const InputDecoration(
                labelText: 'Lab reference range (if shown)',
              ),
            ),
            if (_error != null) ...[
              Text(
                _error!,
                key: const Key('correction-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              if (_conflict)
                TextButton(
                  key: const Key('correction-reload'),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Reload report'),
                ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('correction-save'),
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save correction'),
            ),
          ],
        ),
      ),
    );
  }
}
