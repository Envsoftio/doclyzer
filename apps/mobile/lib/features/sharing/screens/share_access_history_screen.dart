import 'package:flutter/material.dart';
import '../sharing_repository.dart';

class ShareAccessHistoryScreen extends StatefulWidget {
  const ShareAccessHistoryScreen({
    super.key,
    required this.linkId,
    required this.sharingRepository,
  });
  final String linkId;
  final SharingRepository sharingRepository;

  @override
  State<ShareAccessHistoryScreen> createState() => _ShareAccessHistoryScreenState();
}

class _ShareAccessHistoryScreenState extends State<ShareAccessHistoryScreen> {
  bool _loading = true;
  List<ShareAccessEvent> _events = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final events = await widget.sharingRepository.listAccessEvents(widget.linkId);
      if (mounted) setState(() { _events = events; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _outcomeLabel(String outcome) => switch (outcome) {
    'accessed' => 'Viewed',
    'expired_or_revoked' => 'Blocked (expired/revoked)',
    _ => outcome,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Access History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
          ? const Center(child: CircularProgressIndicator(key: Key('access-history-loading')))
          : _error != null
            ? Column(
                children: [
                  Text(_error!, key: const Key('access-history-error'),
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              )
            : _events.isEmpty
              ? const Center(child: Text('No access events yet.', key: Key('access-history-empty')))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (_, i) {
                    final ev = _events[i];
                    return ListTile(
                      key: Key('access-event-${ev.id}'),
                      leading: Icon(
                        ev.outcome == 'accessed' ? Icons.check_circle_outline : Icons.block_outlined,
                        color: ev.outcome == 'accessed'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(_outcomeLabel(ev.outcome)),
                      subtitle: Text(_formatDateTime(ev.accessedAt.toLocal())),
                    );
                  },
                ),
      ),
    );
  }
}
