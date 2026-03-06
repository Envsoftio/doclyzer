import 'package:flutter/material.dart';

import '../sessions_repository.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({
    super.key,
    required this.sessionsRepository,
    required this.onLogout,
    required this.onBack,
  });

  final SessionsRepository sessionsRepository;
  final VoidCallback onLogout;
  final VoidCallback onBack;

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  List<DeviceSessionSummary> _sessions = [];
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sessions =
          await widget.sessionsRepository.getSessions();
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load sessions.';
        _loading = false;
      });
    }
  }

  Future<void> _showRevokeConfirm(DeviceSessionSummary session) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('session-revoke-dialog'),
        title: const Text('Revoke session?'),
        content: Text(
          '${session.ip}\n${session.userAgent}',
        ),
        actions: [
          TextButton(
            key: const Key('session-revoke-cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('session-revoke-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await widget.sessionsRepository.revokeSession(session.sessionId);
        if (session.isCurrent) {
          widget.onLogout();
          return;
        }
        await _loadSessions();
      } catch (e) {
        setState(() {
          _error = 'Failed to revoke session.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Sessions'),
        leading: BackButton(onPressed: widget.onBack),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        key: const Key('session-list-error'),
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        return Card(
                          key: Key('session-item-${session.sessionId}'),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (session.isCurrent)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Chip(
                                      label: const Text('Current'),
                                      key: Key(
                                          'session-current-${session.sessionId}'),
                                    ),
                                  ),
                                Text(
                                  session.userAgent,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.ip,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.createdAt,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  key: Key(
                                      'session-revoke-${session.sessionId}'),
                                  onPressed: () =>
                                      _showRevokeConfirm(session),
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                  child: Text(session.isCurrent
                                      ? 'Revoke (Logout)'
                                      : 'Revoke'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
