import 'package:flutter/material.dart';

import '../reports_repository.dart';

enum _RecycleBinState { loading, loaded, error }

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({
    super.key,
    required this.reportsRepository,
    required this.profileId,
  });

  final ReportsRepository reportsRepository;
  final String profileId;

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  _RecycleBinState _state = _RecycleBinState.loading;
  List<Report> _reports = [];
  String? _errorMessage;

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
    try {
      await widget.reportsRepository.restoreReport(report.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report restored')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', 'Unable to restore: '),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  int? _daysLeft(DateTime? purgeAfterAt) {
    if (purgeAfterAt == null) return null;
    final now = DateTime.now();
    final diff = purgeAfterAt.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recycle Bin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
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
        child: Text(
          'Recycle bin is empty.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
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
                const SizedBox(height: 8),
                if (deleted != null)
                  Text('Deleted on: ${_formatDate(deleted)}'),
                if (purgeAfter != null)
                  Text('Permanent delete on: ${_formatDate(purgeAfter)}'),
                if (daysLeft != null) Text('Days left: $daysLeft'),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => _restore(report),
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
