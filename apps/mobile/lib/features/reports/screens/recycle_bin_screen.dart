import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';

import '../reports_repository.dart';

enum _RecycleBinState { loading, loaded, error }

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({
    super.key,
    required this.reportsRepository,
    this.profileId,
  });

  final ReportsRepository reportsRepository;
  final String? profileId;

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  _RecycleBinState _state = _RecycleBinState.loading;
  List<Report> _reports = [];
  String? _errorMessage;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = _RecycleBinState.loading;
      _errorMessage = null;
    });
    try {
      final list = await widget.reportsRepository.listRecycleBin(
        profileId: widget.profileId,
      );
      if (!mounted) return;
      setState(() {
        _reports = list;
        _state = _RecycleBinState.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _RecycleBinState.error;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _restore(Report report) async {
    setState(() => _busy = true);
    try {
      await widget.reportsRepository.restoreReport(report.id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report restored')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', 'Unable to restore: '),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _permanentlyDelete(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete report permanently?'),
        content: Text(
          'Delete ${report.originalFileName} and its stored file? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.reportsRepository.permanentlyDeleteReport(report.id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report permanently deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to delete report: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _emptyBin() async {
    final count = _reports.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Empty Recycle Bin?'),
        content: Text(
          'Permanently delete all $count reports and their stored files? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final result = await widget.reportsRepository.emptyRecycleBin();
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      final message = result.failedCount == 0
          ? 'Recycle Bin emptied'
          : 'Deleted ${result.deletedCount} reports. ${result.failedCount} could not be deleted; try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to empty Recycle Bin: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatDate(DateTime d) {
    return AppDateFormat.dateWithRelative(d);
  }

  int? _daysLeft(DateTime? purgeAfterAt) {
    if (purgeAfterAt == null) return null;
    final milliseconds = purgeAfterAt.difference(DateTime.now()).inMilliseconds;
    if (milliseconds <= 0) return 0;
    const dayMilliseconds = 24 * 60 * 60 * 1000;
    return (milliseconds + dayMilliseconds - 1) ~/ dayMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle bin'),
        actions: [
          if (_reports.isNotEmpty)
            IconButton(
              key: const Key('recycle-bin-empty'),
              onPressed: _busy ? null : _emptyBin,
              tooltip: 'Empty recycle bin',
              icon: const Icon(Icons.delete_forever_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_busy) const LinearProgressIndicator(),
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
    if (_state == _RecycleBinState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_state == _RecycleBinState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Recycle bin is empty.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Deleted reports will appear here before removal.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _reports.length,
            itemBuilder: (context, index) {
              final report = _reports[index];
              final deleted = report.deletedAt;
              final purgeAfter = report.purgeAfterAt;
              final daysLeft = _daysLeft(purgeAfter);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.originalFileName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (report.profileName != null)
                        Text('Profile: ${report.profileName}'),
                      const SizedBox(height: 8),
                      Text(
                        'Collected: ${report.collectionDateStatus == 'multiple'
                            ? 'Multiple collection dates'
                            : report.collectionDate == null || report.collectionDate!.trim().isEmpty
                            ? 'Unknown'
                            : AppDateFormat.fromRaw(report.collectionDate!)}',
                      ),
                      Text('Uploaded: ${_formatDate(report.createdAt)}'),
                      if (deleted != null)
                        Text('Deleted on: ${_formatDate(deleted)}'),
                      if (purgeAfter != null)
                        Text('Permanent delete on: ${_formatDate(purgeAfter)}'),
                      if (daysLeft != null) Text('Days left: $daysLeft'),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _busy ? null : () => _restore(report),
                            icon: const Icon(Icons.restore),
                            label: const Text('Restore'),
                          ),
                          TextButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _permanentlyDelete(report),
                            icon: const Icon(Icons.delete_forever_outlined),
                            label: const Text('Delete permanently'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
