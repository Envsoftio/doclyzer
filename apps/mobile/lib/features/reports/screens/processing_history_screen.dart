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
  State<ProcessingHistoryScreen> createState() => _ProcessingHistoryScreenState();
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
      final attempts =
          await widget.reportsRepository.getProcessingAttempts(widget.reportId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attempt History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
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
            FilledButton(
              onPressed: _loadAttempts,
              child: const Text('Retry'),
            ),
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
    return ListView.builder(
      itemCount: _attempts.length,
      itemBuilder: (context, index) {
        final a = _attempts[index];
        return ListTile(
          key: Key('processing-history-attempt-${a.id}'),
          title: Text(_triggerLabel(a.trigger)),
          subtitle: Text(_outcomeLabel(a.outcome)),
          trailing: Text(
            _formatDateTime(a.attemptedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}
