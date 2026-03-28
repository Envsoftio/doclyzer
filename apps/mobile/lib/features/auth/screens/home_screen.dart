import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/api_client.dart';
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
    required this.onGoToUploadReport,
    required this.onGoToTimeline,
    required this.onGoToBilling,
    required this.restrictionRepository,
  });

  final Future<void> Function() onLogout;
  final VoidCallback onGoToAccount;
  final VoidCallback onGoToProfiles;
  final VoidCallback onGoToSessions;
  final VoidCallback onGoToCommunicationPreferences;
  final VoidCallback onGoToDataRights;
  final Future<void> Function() onGoToUploadReport;
  final Future<void> Function() onGoToTimeline;
  final VoidCallback onGoToBilling;
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
    try {
      final status = await widget.restrictionRepository.getStatus();
      if (mounted) {
        setState(() {
          _restrictionStatus = status;
        });
      }
    } on ApiException catch (e) {
      if (e.code == 'AUTH_UNAUTHORIZED' && mounted) {
        await widget.onLogout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRestricted = _restrictionStatus?.isRestricted ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doclyzer'),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isRestricted) ...[
                      _RestrictionBanner(
                        rationale: _restrictionStatus?.rationale ?? '',
                        nextSteps: _restrictionStatus?.nextSteps ?? '',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(
                      'Welcome to Doclyzer',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your health reports in one place.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Quick actions',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _HomeNavCard(
                    key: const Key('go-to-upload-report'),
                    icon: Icons.upload_file_rounded,
                    title: 'Upload Report',
                    subtitle: 'Add a new health report',
                    onTap: () => widget.onGoToUploadReport(),
                  ),
                  _HomeNavCard(
                    key: const Key('go-to-timeline'),
                    icon: Icons.timeline_rounded,
                    title: 'Timeline',
                    subtitle: 'View reports by date',
                    onTap: () => widget.onGoToTimeline(),
                  ),
                  _HomeNavCard(
                    key: const Key('go-to-profiles'),
                    icon: Icons.person_rounded,
                    title: 'Profiles',
                    subtitle: 'Switch or add profiles',
                    onTap: widget.onGoToProfiles,
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Account & settings',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _HomeNavCard(
                    key: const Key('go-to-billing'),
                    icon: Icons.credit_card_rounded,
                    title: 'Plan & Credits',
                    subtitle: 'View your plan and credit balance',
                    onTap: widget.onGoToBilling,
                  ),
                  _HomeNavCard(
                    key: const Key('go-to-account'),
                    icon: Icons.account_circle_rounded,
                    title: 'Account',
                    onTap: widget.onGoToAccount,
                  ),
                  _HomeNavCard(
                    key: const Key('go-to-sessions'),
                    icon: Icons.devices_rounded,
                    title: 'Active Sessions',
                    onTap: widget.onGoToSessions,
                  ),
                  _HomeNavCard(
                    key: const Key('go-to-communication-preferences'),
                    icon: Icons.notifications_rounded,
                    title: 'Communication Preferences',
                    onTap: widget.onGoToCommunicationPreferences,
                  ),
                  _HomeNavCard(
                    key: const Key('go-to-data-rights'),
                    icon: Icons.shield_rounded,
                    title: 'Data Rights',
                    onTap: widget.onGoToDataRights,
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                ),
                child: OutlinedButton(
                  key: const Key('logout-submit'),
                  onPressed: () async {
                    await widget.onLogout();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                  ),
                  child: const Text('Log out'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestrictionBanner extends StatelessWidget {
  const _RestrictionBanner({
    required this.rationale,
    required this.nextSteps,
  });

  final String rationale;
  final String nextSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('restriction-banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Account Restricted',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (rationale.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: const Key('restriction-rationale'),
              rationale,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
          if (nextSteps.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              key: const Key('restriction-next-steps'),
              nextSteps,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeNavCard extends StatelessWidget {
  const _HomeNavCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
