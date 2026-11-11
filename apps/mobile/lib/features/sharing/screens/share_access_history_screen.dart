import 'package:mobile/core/localized_error.dart';
import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';
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
  State<ShareAccessHistoryScreen> createState() =>
      _ShareAccessHistoryScreenState();
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final events = await widget.sharingRepository.listAccessEvents(
        widget.linkId,
      );
      if (mounted) {
        setState(() {
          _events = events;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = localizedError(
            context,
            e,
            fallback: context.l10n.genericError,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dt) => AppDateFormat.dateTimeWithRelative(dt);

  String _outcomeLabel(String outcome) => switch (outcome) {
    'accessed' => context.l10n.uiViewed,
    'expired_or_revoked' => context.l10n.uiBlockedExpiredRevoked,
    _ => outcome,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.uiLinkAccessHistory)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  key: Key('access-history-loading'),
                ),
              )
            : _error != null
            ? Column(
                children: [
                  Text(
                    _error!,
                    key: const Key('access-history-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _load, child: Text(context.l10n.retry)),
                ],
              )
            : _events.isEmpty
            ? Center(
                child: Text(
                  context.l10n.uiNoAccessEventsYet,
                  key: Key('access-history-empty'),
                ),
              )
            : ListView.builder(
                itemCount: _events.length,
                itemBuilder: (_, i) {
                  final ev = _events[i];
                  return ListTile(
                    key: Key('access-event-${ev.id}'),
                    leading: Icon(
                      ev.outcome == 'accessed'
                          ? Icons.check_circle_outline
                          : Icons.block_outlined,
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
