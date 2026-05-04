import 'package:flutter/material.dart';

import '../reports_repository.dart';

enum _ProcessingHistoryState { loading, loaded, error }

class ProcessingHistoryScreen extends StatefulWidget {
  const ProcessingHistoryScreen({
    super.key,
    required this.reportId,
    required this.reportsRepository,
  });

  final String reportId;
  final ReportsRepository reportsRepository;

  @override
  State<ProcessingHistoryScreen> createState() =>
      _ProcessingHistoryScreenState();
}

class _ProcessingHistoryScreenState extends State<ProcessingHistoryScreen> {
  _ProcessingHistoryState _state = _ProcessingHistoryState.loading;
  List<ProcessingAttempt> _attempts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    setState(() {
      _state = _ProcessingHistoryState.loading;
      _errorMessage = null;
    });
    try {
      final attempts = await widget.reportsRepository.getProcessingAttempts(
        widget.reportId,
      );
      if (mounted) {
        setState(() {
          _attempts = attempts;
          _state = _ProcessingHistoryState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _ProcessingHistoryState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  static String _triggerLabel(String trigger) {
    switch (trigger) {
      case 'initial_upload':
        return 'Initial upload';
      case 'retry':
        return 'Retry';
      default:
        return trigger;
    }
  }

  static String _outcomeLabel(String outcome) {
    switch (outcome) {
      case 'parsed':
        return 'Parsed successfully';
      case 'unparsed':
        return 'Parsing failed';
      case 'content_not_recognized':
        return 'Not a health report';
      case 'failed_transient':
        return 'Transient failure';
      case 'failed_terminal':
        return 'Terminal failure';
      default:
        return outcome;
    }
  }

  static String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Color _outcomeColor(BuildContext context, String outcome) {
    switch (outcome) {
      case 'parsed':
        return Colors.green.shade700;
      case 'failed_transient':
        return Colors.orange.shade700;
      case 'unparsed':
      case 'content_not_recognized':
      case 'failed_terminal':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attempt History')),
      body: Padding(padding: const EdgeInsets.all(16), child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_state == _ProcessingHistoryState.loading) {
      return const Center(
        key: Key('processing-history-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (_state == _ProcessingHistoryState.error) {
      return Center(
        key: const Key('processing-history-error'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage ?? 'Failed to load attempt history',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadAttempts, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_attempts.isEmpty) {
      return const Center(
        key: Key('processing-history-empty'),
        child: Text('No attempt history available.'),
      );
    }
    return ListView.separated(
      itemCount: _attempts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final a = _attempts[index];
        final outcomeColor = _outcomeColor(context, a.outcome);
        return Card(
          key: Key('processing-history-attempt-${a.id}'),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        a.trigger == 'retry'
                            ? Icons.refresh
                            : Icons.upload_file,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _triggerLabel(a.trigger),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Chip(
                      avatar: Icon(Icons.circle, size: 10, color: outcomeColor),
                      label: Text(_outcomeLabel(a.outcome)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDateTime(a.attemptedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
