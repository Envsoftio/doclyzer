import 'package:flutter/material.dart';

import '../../../features/account/restriction_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onLogout,
    required this.onGoToAccount,
    required this.onGoToProfiles,
    required this.onGoToSessions,
    required this.onGoToCommunicationPreferences,
    required this.onGoToDataRights,
    required this.restrictionRepository,
  });

  final Future<void> Function() onLogout;
  final VoidCallback onGoToAccount;
  final VoidCallback onGoToProfiles;
  final VoidCallback onGoToSessions;
  final VoidCallback onGoToCommunicationPreferences;
  final VoidCallback onGoToDataRights;
  final RestrictionRepository restrictionRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RestrictionStatus? _restrictionStatus;

  @override
  void initState() {
    super.initState();
    _loadRestrictionStatus();
  }

  Future<void> _loadRestrictionStatus() async {
    final status = await widget.restrictionRepository.getStatus();
    if (mounted) {
      setState(() {
        _restrictionStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRestricted = _restrictionStatus?.isRestricted ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Doclyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRestricted) ...[
              Container(
                key: const Key('restriction-banner'),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Restricted',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      semanticsLabel: 'Account Restricted',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      key: const Key('restriction-rationale'),
                      _restrictionStatus?.rationale ?? '',
                      semanticsLabel: _restrictionStatus?.rationale,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      key: const Key('restriction-next-steps'),
                      _restrictionStatus?.nextSteps ?? '',
                      semanticsLabel: _restrictionStatus?.nextSteps,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Welcome to Doclyzer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('go-to-account'),
              onPressed: widget.onGoToAccount,
              child: const Text('Account'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('go-to-profiles'),
              onPressed: widget.onGoToProfiles,
              child: const Text('Profiles'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('go-to-sessions'),
              onPressed: widget.onGoToSessions,
              child: const Text('Active Sessions'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('go-to-communication-preferences'),
              onPressed: widget.onGoToCommunicationPreferences,
              child: const Text('Communication Preferences'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('go-to-data-rights'),
              onPressed: widget.onGoToDataRights,
              child: const Text('Data Rights'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('logout-submit'),
              onPressed: () async {
                await widget.onLogout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
