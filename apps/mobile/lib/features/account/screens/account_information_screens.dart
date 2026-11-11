import 'package:mobile/l10n/l10n.dart';
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
          SnackBar(content: Text(context.l10n.uiCouldNotChangeAppLockTryAgain)),
        );
      }
    } finally {
      if (mounted) setState(() => _changingLock = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.privacySecurity)),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 6, 24, 18),
      child: TextButton(
        onPressed: widget.onDeleteAccount,
        child: Text(context.l10n.uiDeleteAccount),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(width: 16),
                  Text(
                    context.l10n.uiYourRecordsYourChoiceToShare,
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
                context.l10n.uiReviewAccessWheneverYouNeed,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _SettingsLink(
          key: const Key('privacy-change-password'),
          icon: Icons.lock_outline_rounded,
          title: context.l10n.uiChangePassword,
          onTap: widget.onChangePassword,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            context.l10n.uiAppLock,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            context.l10n.uiUseYourDeviceSBiometricOrPasscode,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
          title: Text(context.l10n.uiNotificationPreviews),
          subtitle: Text(context.l10n.uiControlLockScreenPreviewsInYourDevice),
          trailing: const Icon(Icons.chevron_right),
          onTap: widget.onNotificationSettings,
        ),
        const Divider(),
        const SizedBox(height: 20),
        _SettingsLink(
          icon: Icons.link,
          title: context.l10n.uiManageSharedLinks,
          onTap: widget.onSharedLinks,
        ),
        _SettingsLink(
          icon: Icons.download_outlined,
          title: context.l10n.uiExportYourData,
          onTap: widget.onExport,
        ),
        _SettingsLink(
          icon: Icons.policy_outlined,
          title: context.l10n.uiReadThePrivacyPolicy,
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

  List<(String, String, IconData, String)> _articles(BuildContext context) => [
    (
      context.l10n.uiUploadingAClearReport,
      context.l10n.uiPDFsPhotosAndMultiplePages,
      Icons.document_scanner_outlined,
      context.l10n.uiChooseAPDFOrTakeClearPhotos,
    ),
    (
      context.l10n.uiCorrectingAResult,
      context.l10n.uiReviewValuesAgainstTheOriginal,
      Icons.edit_outlined,
      context.l10n.uiOpenAReportReviewEachExtractedTest,
    ),
    (
      context.l10n.uiManagingFamilyRecords,
      context.l10n.uiProfilesAccessAndPermissions,
      Icons.people_outline,
      context.l10n.uiUseFamilyToCreateAndSwitchProfiles,
    ),
    (
      context.l10n.uiSharingAndRevokingLinks,
      context.l10n.uiControlTheRecordsYouShare,
      Icons.link,
      context.l10n.uiSelectTheReportsOrResultsYouWant,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _articles(context)
        .where(
          (article) => '${article.$1} ${article.$2} ${article.$4}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.helpSupport)),
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
              child: Text(context.l10n.uiContactSupport),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.uiAttachReportsOnlyIfYouChooseTo,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            context.l10n.uiWhatCanWeHelpYouWith,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: context.l10n.uiSearchHelpArticles,
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 30),
          Text(
            context.l10n.uiPOPULARQUESTIONS,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Text(
              context.l10n.uiNoHelpArticlesMatchYourSearch,
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
            context.l10n.uiForQuestionsAboutYourHealthOrTest,
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
    appBar: AppBar(title: Text(context.l10n.aboutDoclyzer)),
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
            context.l10n.uiYourReportsAClearerPicture,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          context.l10n.uiKeepYourHealthHistoryTogether,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.uiStoreReportsReviewResultsFollowChangesAnd,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.uiEducationalInformationOnly,
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
          title: context.l10n.uiTermsOfUse,
          onTap: onTerms,
        ),
        _SettingsLink(
          icon: Icons.policy_outlined,
          title: context.l10n.uiPrivacyPolicy,
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
        ? [
            (
              context.l10n.uiInformationYouProvide,
              context.l10n.uiAccountDetailsAndFamilyProfilesIdentifyWhose,
            ),
            (
              context.l10n.uiSharingControls,
              context.l10n.uiReviewTheContentsExpiryAndAccessSettings,
            ),
            (
              context.l10n.uiExportAndAccountChoices,
              context.l10n.uiUseSettingsToExportRecordsOrStart,
            ),
          ]
        : [
            (
              context.l10n.uiEducationalScope,
              context.l10n.uiDoclyzerOrganizesReportsAndShowsResultsOver,
            ),
            (
              context.l10n.uiReviewYourRecords,
              context.l10n.uiCheckExtractedValuesUnitsAndDatesAgainst,
            ),
            (
              context.l10n.uiManageAndShareResponsibly,
              context.l10n.uiOnlyManageRecordsYouAreAuthorizedTo,
            ),
          ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          privacy
              ? context.l10n.uiPrivacyPolicy7ceacd
              : context.l10n.uiTermsOfUse8a069e,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: onPrimary,
              child: Text(
                privacy
                    ? context.l10n.uiOpenPrivacyControls
                    : context.l10n.uiGetHelpWithTheApp,
              ),
            ),
            TextButton(
              onPressed: onSecondary,
              child: Text(
                privacy
                    ? context.l10n.uiExportYourDataInAccountSettings
                    : context.l10n.uiReadThePrivacyPolicy,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            privacy
                ? context.l10n.uiYOURDATACHOICES
                : context.l10n.uiUSINGDOCLYZER,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            privacy
                ? context.l10n.uiUnderstandTheInformationYouKeepInDoclyzer
                : context.l10n.uiAClearUnderstandingOfTheAppsRole,
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
