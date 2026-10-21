import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/app_date_format.dart';

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
      final sessions = await widget.sessionsRepository.getSessions();
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
        content: Text('${session.ip}\n${session.userAgent}'),
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
                    child: ListView.separated(
                      itemCount: _sessions.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        final colors = Theme.of(context).colorScheme;
                        final textTheme = Theme.of(context).textTheme;
                        return Card(
                          key: Key('session-item-${session.sessionId}'),
                          color: session.isCurrent
                              ? colors.primaryContainer.withValues(alpha: 0.35)
                              : colors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.cardRadius,
                            ),
                            side: BorderSide(
                              color: session.isCurrent
                                  ? colors.primary.withValues(alpha: 0.4)
                                  : colors.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colors.primary.withValues(
                                          alpha: 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.devices_outlined,
                                        color: colors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.isCurrent
                                                ? 'This device'
                                                : 'Signed-in device',
                                            style: textTheme.titleMedium,
                                          ),
                                          if (session.isCurrent) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Current session',
                                              key: Key(
                                                'session-current-${session.sessionId}',
                                              ),
                                              style: textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: colors.primary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  session.userAgent.isEmpty
                                      ? 'Unknown device'
                                      : session.userAgent,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'IP address: ${session.ip.isEmpty ? 'Unknown' : session.ip}',
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Signed in: ${AppDateFormat.dateTimeFromRawWithRelative(session.createdAt)}',
                                  style: textTheme.bodySmall,
                                ),
                                const Divider(height: AppSpacing.lg),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    key: Key(
                                      'session-revoke-${session.sessionId}',
                                    ),
                                    onPressed: () =>
                                        _showRevokeConfirm(session),
                                    style: TextButton.styleFrom(
                                      foregroundColor: colors.error,
                                    ),
                                    icon: const Icon(Icons.logout, size: 18),
                                    label: Text(
                                      session.isCurrent
                                          ? 'Revoke and log out'
                                          : 'Revoke session',
                                    ),
                                  ),
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
