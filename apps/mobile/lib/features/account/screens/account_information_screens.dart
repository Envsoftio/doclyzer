import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';
import '../../../shared/ai_disclaimer_note.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({
    super.key,
    required this.onSharedLinks,
    required this.onExport,
    required this.onPrivacyPolicy,
    required this.onChangePassword,
    required this.onNotificationSettings,
    required this.onDeleteAccount,
    required this.appLockEnabled,
    required this.onAppLockChanged,
  });
  final VoidCallback onSharedLinks;
  final VoidCallback onExport;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onChangePassword;
  final VoidCallback onNotificationSettings;
  final VoidCallback onDeleteAccount;
  final bool appLockEnabled;
  final Future<bool> Function(bool) onAppLockChanged;

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  late bool _appLockEnabled = widget.appLockEnabled;
  bool _changingLock = false;

  Future<void> _changeLock(bool enabled) async {
    setState(() => _changingLock = true);
    try {
      final changed = await widget.onAppLockChanged(enabled);
      if (mounted) setState(() => _appLockEnabled = changed);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not change App lock. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _changingLock = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy & security')),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 6, 24, 18),
      child: TextButton(
        onPressed: widget.onDeleteAccount,
        child: const Text('Delete account'),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.white, size: 30),
                  SizedBox(width: 16),
                  Text(
                    'Your records.\nYour choice to share.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Review access whenever you need.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SettingsLink(
          key: const Key('privacy-change-password'),
          icon: Icons.lock_outline_rounded,
          title: 'Change password',
          onTap: widget.onChangePassword,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('App lock', style: Theme.of(context).textTheme.titleSmall),
          subtitle: Text('Use your device’s biometric or passcode lock.',
              style: Theme.of(context).textTheme.bodySmall),
          trailing: Switch.adaptive(
            key: const Key('app-lock-switch'),
            value: _appLockEnabled,
            onChanged: _changingLock ? null : _changeLock,
          ),
        ),
        const Divider(),
        ListTile(
          key: const Key('privacy-notification-settings'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Notification previews'),
          subtitle: const Text(
            'Control lock-screen previews in your device settings.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: widget.onNotificationSettings,
        ),
        const Divider(),
        const SizedBox(height: 20),
        _SettingsLink(
          icon: Icons.link,
          title: 'Manage shared links',
          onTap: widget.onSharedLinks,
        ),
        _SettingsLink(
          icon: Icons.download_outlined,
          title: 'Export your data',
          onTap: widget.onExport,
        ),
        _SettingsLink(
          icon: Icons.policy_outlined,
          title: 'Read the Privacy Policy',
          onTap: widget.onPrivacyPolicy,
        ),
      ],
    ),
  );
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key, required this.supportRepository});
  final SupportRepository supportRepository;

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _query = '';

  static const _articles = [
    (
      'Uploading a clear report',
      'PDFs, photos and multiple pages',
      Icons.document_scanner_outlined,
      'Choose a PDF or take clear photos of every page. Keep the whole page in frame, avoid glare, and check the page order before analyzing. You can correct extracted values against the original.',
    ),
    (
      'Correcting a result',
      'Review values against the original',
      Icons.edit_outlined,
      'Open a report, review each extracted test against the original, and correct any value, unit, or date that was read incorrectly. Unconfirmed results should be checked before you rely on trends.',
    ),
    (
      'Managing family records',
      'Profiles, access and permissions',
      Icons.people_outline,
      'Use Family to create and switch profiles. Check the selected person before uploading or sharing a report. Manage only records you are authorized to access.',
    ),
    (
      'Sharing and revoking links',
      'Control the records you share',
      Icons.link,
      'Select the reports or results you want to share, review the expiry and access code, then send the link and code separately. Revoke an active link from Shared links when access is no longer needed.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _articles
        .where(
          (article) => '${article.$1} ${article.$2} ${article.$4}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => showSupportRequestSheet(
                context: context,
                supportRepository: widget.supportRepository,
                supportContext: buildSupportRequestContext(
                  actionType: SupportActionType.productHelp,
                ),
              ),
              child: const Text('Contact support'),
            ),
            const SizedBox(height: 8),
            Text(
              'Attach reports only if you choose to.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'What can we help you with?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search help articles',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 30),
          Text(
            'POPULAR QUESTIONS',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Text(
              'No help articles match your search.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          for (final article in filtered) ...[
            Card(
              child: ListTile(
                leading: Icon(
                  article.$3,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(article.$1),
                subtitle: Text(article.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  designPageRoute(
                    _HelpArticleScreen(title: article.$1, text: article.$4),
                    context,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 24),
          Text(
            'For questions about your health or test results, speak with a qualified healthcare professional.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HelpArticleScreen extends StatelessWidget {
  const _HelpArticleScreen({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [Text(text, style: Theme.of(context).textTheme.bodyLarge)],
    ),
  );
}

class AboutDoclyzerScreen extends StatelessWidget {
  const AboutDoclyzerScreen({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
  });
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About Doclyzer')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(child: DoclyzerMark(size: 76)),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'doclyzer',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Your reports. A clearer picture.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Keep your health history together.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Store reports, review results, follow changes and share with your clinician.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Educational information only',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              AiDisclaimerNote(key: Key('about-medical-disclaimer')),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _SettingsLink(
          icon: Icons.description_outlined,
          title: 'Terms of Use',
          onTap: onTerms,
        ),
        _SettingsLink(
          icon: Icons.policy_outlined,
          title: 'Privacy Policy',
          onTap: onPrivacy,
        ),
      ],
    ),
  );
}

enum LegalSummaryKind { privacy, terms }

class LegalSummaryScreen extends StatelessWidget {
  const LegalSummaryScreen({
    super.key,
    required this.kind,
    this.onPrimary,
    this.onSecondary,
  });
  final LegalSummaryKind kind;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final privacy = kind == LegalSummaryKind.privacy;
    final sections = privacy
        ? const [
            (
              'Information you provide',
              'Account details and family profiles identify whose records you manage. Uploaded documents may contain sensitive health information.',
            ),
            (
              'Sharing controls',
              'Review the contents, expiry and access settings of each link. Manage active links from your account settings.',
            ),
            (
              'Export and account choices',
              'Use settings to export records or start an account deletion request. Retention details belong in the complete policy.',
            ),
          ]
        : const [
            (
              'Educational scope',
              'Doclyzer organizes reports and shows results over time. Educational explanations are not medical advice or a diagnosis.',
            ),
            (
              'Review your records',
              'Check extracted values, units and dates against the original report. Ask a healthcare professional about your results.',
            ),
            (
              'Manage and share responsibly',
              'Only manage records you are authorized to access. Check the selected information and recipient before sharing.',
            ),
          ];
    return Scaffold(
      appBar: AppBar(title: Text(privacy ? 'Privacy policy' : 'Terms of use')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: onPrimary,
              child: Text(
                privacy ? 'Open privacy controls' : 'Get help with the app',
              ),
            ),
            TextButton(
              onPressed: onSecondary,
              child: Text(
                privacy
                    ? 'Export your data in account settings'
                    : 'Read the Privacy Policy',
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            privacy ? 'YOUR DATA & CHOICES' : 'USING DOCLYZER',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            privacy
                ? 'Understand the information\nyou keep in Doclyzer.'
                : 'A clear understanding\nof the app’s role.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 28),
          for (var index = 0; index < sections.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sections[index].$1,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sections[index].$2,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
    ),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
