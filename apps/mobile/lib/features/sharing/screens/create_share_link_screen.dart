import 'package:mobile/core/localized_error.dart';
import 'package:mobile/l10n/l10n.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/feedback/incident_banner.dart';
import '../../incidents/incident_repository.dart';
import '../../../core/api_client.dart';
import '../../../core/feedback/status_messenger.dart';
import '../sharing_repository.dart';
import '../share_access_code_store.dart';
import '../../reports/reports_repository.dart';
import 'share_policy_screen.dart';
import 'share_access_history_screen.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

enum _CreateState { idle, loading, created, error }

class CreateShareLinkScreen extends StatefulWidget {
  const CreateShareLinkScreen({
    super.key,
    required this.profileId,
    required this.profileName,
    required this.sharingRepository,
    this.reportsRepository,
    required this.onUpgrade,
    required this.supportRepository,
    this.incidentStatus,
    this.initialReportId,
    this.accessCodeStore = const SecureShareAccessCodeStore(),
  });
  final String profileId;
  final String profileName;
  final SharingRepository sharingRepository;
  final ReportsRepository? reportsRepository;
  final VoidCallback onUpgrade;
  final SupportRepository supportRepository;
  final PublicIncidentStatus? incidentStatus;
  final String? initialReportId;
  final ShareAccessCodeStore accessCodeStore;

  @override
  State<CreateShareLinkScreen> createState() => _CreateShareLinkScreenState();
}

class _CreateShareLinkScreenState extends State<CreateShareLinkScreen> {
  // Existing links loading state
  bool _loadingExistingLinks = false;
  List<ShareLink> _existingLinks = [];
  Map<String, String> _savedAccessCodes = {};
  String? _listError;

  // Create new link state
  _CreateState _createState = _CreateState.idle;
  ShareLink? _newLink;
  bool _codeSaveFailed = false;
  String? _createError;
  SupportRequestContext? _supportContext;
  String? _supportErrorMessage;
  DateTime? _selectedExpiry = DateTime.now().add(const Duration(days: 7));
  bool _expiryTouched = false;
  bool _requireAccessCode = true;
  String? _limitMessage;
  String? _limitUpgradeHint;
  int? _limitCurrent;
  int? _limitMax;
  List<Report> _availableReports = const [];
  final Set<String> _selectedReportIds = <String>{};
  bool _selectReports = true;
  bool _loadingReports = false;
  String? _reportsError;
  bool _shareSelectedResults = false;
  bool _loadingSelectableValues = false;
  String? _valuesError;
  List<(Report, ExtractedLabValue)> _selectableValues = const [];
  final Set<String> _selectedLabValueIds = <String>{};
  int _valuesRequest = 0;

  @override
  void initState() {
    super.initState();
    if (widget.reportsRepository == null) _selectReports = false;
    if (widget.initialReportId != null) {
      _selectedReportIds.add(widget.initialReportId!);
    }
    _loadExistingLinks();
    _loadPolicy();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final repository = widget.reportsRepository;
    if (repository == null) return;
    setState(() {
      _loadingReports = true;
      _reportsError = null;
    });
    try {
      final reports = await repository.listReports(widget.profileId);
      if (mounted) {
        setState(() {
          _availableReports = reports
              .where((report) => report.status == 'parsed')
              .toList();
          _selectedReportIds.removeWhere(
            (id) => !_availableReports.any((report) => report.id == id),
          );
          _loadingReports = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingReports = false;
          _reportsError = context.l10n.uiReportsCouldNotBeLoadedTryAgain;
        });
      }
    }
  }

  Future<void> _loadSelectableValues() async {
    final repository = widget.reportsRepository;
    if (repository == null) return;
    final request = ++_valuesRequest;
    final reportIds = _selectedReportIds.toList();
    setState(() {
      _loadingSelectableValues = true;
      _valuesError = null;
    });
    try {
      final reports = await Future.wait(reportIds.map(repository.getReport));
      if (!mounted || request != _valuesRequest) return;
      final values = <(Report, ExtractedLabValue)>[
        for (final report in reports)
          for (final value in report.extractedLabValues)
            if (value.id != null) (report, value),
      ];
      setState(() {
        _selectableValues = values;
        _selectedLabValueIds.removeWhere(
          (id) => !values.any((entry) => entry.$2.id == id),
        );
        _loadingSelectableValues = false;
      });
    } catch (_) {
      if (mounted && request == _valuesRequest) {
        setState(() {
          _loadingSelectableValues = false;
          _valuesError = context.l10n.uiTestResultsCouldNotBeLoadedTry;
        });
      }
    }
  }

  Future<void> _loadPolicy() async {
    try {
      final policy = await widget.sharingRepository.getSharePolicy();
      if (mounted) {
        setState(() {
          if (!_expiryTouched && policy.defaultExpiresInDays != null) {
            _selectedExpiry = DateTime.now().add(
              Duration(days: policy.defaultExpiresInDays!),
            );
          }
        });
      }
    } catch (_) {
      // Policy load failure is non-fatal; expiry picker stays at "No expiry"
    }
  }

  Future<void> _openPolicySettings() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SharePolicyScreen(sharingRepository: widget.sharingRepository),
      ),
    );
    if (updated == true) _loadPolicy();
  }

  Future<void> _loadExistingLinks() async {
    setState(() {
      _loadingExistingLinks = true;
      _listError = null;
    });
    try {
      final links = await widget.sharingRepository.listShareLinks(
        widget.profileId,
        includePast: true,
      );
      final savedCodes = <String, String>{};
      await Future.wait(
        links.where((link) => link.isActive && link.requiresAccessCode).map((
          link,
        ) async {
          try {
            final code = await widget.accessCodeStore.read(link.id);
            if (code != null) savedCodes[link.id] = code;
          } catch (_) {
            // A storage failure must not hide the link list.
          }
        }),
      );
      if (mounted) {
        setState(() {
          _existingLinks = links;
          _savedAccessCodes = savedCodes;
          _loadingExistingLinks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingExistingLinks = false;
          _listError = localizedError(
            context,
            e,
            fallback: context.l10n.genericError,
          );
        });
      }
    }
  }

  Future<void> _createLink() async {
    if (_selectReports && _selectedReportIds.isEmpty) {
      setState(() {
        _createState = _CreateState.error;
        _createError = context.l10n.uiSelectAtLeastOneReportToShare;
      });
      return;
    }
    if (_shareSelectedResults && _selectedLabValueIds.isEmpty) {
      setState(() {
        _createState = _CreateState.error;
        _createError = context.l10n.uiSelectAtLeastOneTestResultTo;
      });
      return;
    }
    setState(() {
      _createState = _CreateState.loading;
      _createError = null;
      _limitMessage = null;
      _limitUpgradeHint = null;
      _limitCurrent = null;
      _limitMax = null;
    });
    try {
      final link = await widget.sharingRepository.createShareLink(
        widget.profileId,
        expiresAt: _selectedExpiry,
        reportIds: _selectReports ? _selectedReportIds.toList() : null,
        labValueIds: _shareSelectedResults
            ? _selectedLabValueIds.toList()
            : null,
        requireAccessCode: _requireAccessCode,
      );
      var codeSaveFailed = false;
      if (link.accessCode != null) {
        try {
          await widget.accessCodeStore.save(link.id, link.accessCode!);
        } catch (_) {
          codeSaveFailed = true;
        }
      }
      if (mounted) {
        setState(() {
          _newLink = link;
          _codeSaveFailed = codeSaveFailed;
          _createState = _CreateState.created;
        });
      }
    } on ApiException catch (e) {
      if (mounted && e.code == 'SHARE_LINK_LIMIT_EXCEEDED') {
        final data = e.data?['data'] as Map<String, dynamic>?;
        setState(() {
          _createState = _CreateState.error;
          _createError = null;
          _limitMessage = context.l10n.uiShareLinkLimitHelp;
          _limitUpgradeHint = context.l10n.uiSeePlanCreditsOptions;
          final current = data?['current'];
          final max = data?['limit'];
          _limitCurrent = current is num ? current.toInt() : null;
          _limitMax = max is num ? max.toInt() : null;
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.shareLinkCreate,
            apiException: e,
            entityIds: {'profileId': widget.profileId},
          );
          _supportErrorMessage = e.message;
        });
        return;
      }
      if (mounted) {
        setState(() {
          _createState = _CreateState.error;
          _createError = localizedError(
            context,
            e,
            fallback: context.l10n.genericError,
          );
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.shareLinkCreate,
            apiException: e,
            entityIds: {'profileId': widget.profileId},
          );
          _supportErrorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _createState = _CreateState.error;
          _createError = localizedError(
            context,
            e,
            fallback: context.l10n.genericError,
          );
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.shareLinkCreate,
            entityIds: {'profileId': widget.profileId},
          );
          _supportErrorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _reviewAndCreate() async {
    if (_selectReports && _selectedReportIds.isEmpty) {
      setState(() {
        _createState = _CreateState.error;
        _createError = context.l10n.uiSelectAtLeastOneReportToShare;
      });
      return;
    }
    if (_shareSelectedResults && _selectedLabValueIds.isEmpty) {
      setState(() {
        _createState = _CreateState.error;
        _createError = context.l10n.uiSelectAtLeastOneTestResultTo;
      });
      return;
    }
    final approved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.uiReviewSharing,
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(context.l10n.uiCheckThePersonReportsAndAccess),
              const SizedBox(height: 20),
              Text(
                widget.profileName,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _selectReports
                    ? context.l10n.uiSelectedReportsCount(
                        _selectedReportIds.length.toString(),
                      )
                    : context.l10n.uiAllCurrentFutureReports,
              ),
              if (_shareSelectedResults)
                Text(
                  context.l10n.uiSelectedTestResultsCount(
                    _selectedLabValueIds.length.toString(),
                  ),
                ),
              if (_selectReports)
                for (final report in _availableReports.where(
                  (item) => _selectedReportIds.contains(item.id),
                ))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('• ${report.originalFileName}'),
                  ),
              const SizedBox(height: 12),
              Text(
                _selectedExpiry == null
                    ? context.l10n.uiNoExpiry
                    : context.l10n.uiExpiresDate(_formatDate(_selectedExpiry!)),
              ),
              Text(
                _requireAccessCode
                    ? context.l10n.uiAccessCodeRequiredSeparate
                    : context.l10n.uiNoAccessCodeRequired,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: Text(context.l10n.createShareLink),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: Text(context.l10n.uiEditSelectionOrAccessSettings),
              ),
            ],
          ),
        ),
      ),
    );
    if (approved == true && mounted) await _createLink();
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      StatusMessenger.showSuccess(
        context,
        context.l10n.uiLinkCopiedToClipboard,
      );
    }
  }

  Future<void> _copyAccessCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      StatusMessenger.showSuccess(
        context,
        context.l10n.uiAccessCodeCopiedToClipboard,
      );
    }
  }

  Future<void> _shareLink(String url) async {
    await Share.share(url);
  }

  Future<void> _revokeLink(String linkId, {bool isNewLink = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.uiRevokeShareLink),
        content: Text(context.l10n.uiThisLinkWillStopWorkingYouCan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            key: const Key('revoke-confirm-button'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.revoke),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.sharingRepository.revokeShareLink(linkId);
      try {
        await widget.accessCodeStore.delete(linkId);
      } catch (_) {
        // Revocation succeeded even if local cleanup fails.
      }
      if (!mounted) return;
      if (isNewLink) {
        setState(() {
          _newLink = null;
          _createState = _CreateState.idle;
        });
      }
      await _loadExistingLinks();
    } catch (e) {
      if (mounted) {
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.shareLinkRevoke,
          apiException: e is ApiException ? e : null,
          entityIds: {'shareLinkId': linkId},
        );
        _supportErrorMessage = e.toString().replaceFirst('Exception: ', '');
        StatusMessenger.showError(
          context,
          context.l10n.uiFailedToRevoke(localizedError(context, e)),
          actionLabel: context.l10n.uiNeedHelp,
          onAction: _openSupportSheet,
        );
      }
    }
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _expiryTouched = true;
        _selectedExpiry = picked;
      });
    }
  }

  String _formatDate(DateTime dt) => AppDateFormat.dateWithRelative(dt);

  void _openSupportSheet() {
    final supportContext = _supportContext;
    if (supportContext == null) return;
    showSupportRequestSheet(
      context: context,
      supportRepository: widget.supportRepository,
      supportContext: supportContext,
      errorMessage: _supportErrorMessage,
    );
  }

  Widget _buildCreatedLink(BuildContext context, ShareLink link) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.uiShareLinkReady,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(link.shareUrl, key: const Key('share-url-text')),
            if (link.expiresAt != null) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.uiExpiresColonDate(_formatDate(link.expiresAt!)),
              ),
            ],
            if (link.accessCode != null) ...[
              const SizedBox(height: 16),
              Text(
                context.l10n.uiAccessCodeShareSeparately,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              SelectableText(
                link.accessCode!,
                key: const Key('share-access-code'),
                style: theme.textTheme.headlineSmall,
              ),
              TextButton.icon(
                onPressed: () => _copyAccessCode(link.accessCode!),
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: Text(context.l10n.uiCopyAccessCode),
              ),
              if (_codeSaveFailed)
                Text(
                  context.l10n.uiThisCodeCouldNotBeSavedOn,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('share-link-button'),
                  onPressed: () => _shareLink(link.shareUrl),
                  icon: const Icon(Icons.share_outlined),
                  label: Text(context.l10n.uiShareLink),
                ),
                OutlinedButton.icon(
                  key: const Key('copy-link-button'),
                  onPressed: () => _copyLink(link.shareUrl),
                  icon: const Icon(Icons.copy_outlined),
                  label: Text(context.l10n.uiCopyLink),
                ),
                TextButton(
                  key: const Key('new-link-revoke-button'),
                  onPressed: () => _revokeLink(link.id, isNewLink: true),
                  child: Text(context.l10n.uiRevokeLink),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingAccessCode(BuildContext context, ShareLink link) {
    final code = _savedAccessCodes[link.id];
    if (code == null) {
      return Text(context.l10n.uiCodeUnavailableOnThisDeviceUseThe);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.uiAccessCodeShareSeparately,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SelectableText(
          code,
          key: Key('existing-share-access-code-${link.id}'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: () => _copyAccessCode(code),
          child: Text(context.l10n.uiCopyAccessCode),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incidentStatus;
    final now = DateTime.now();
    final activeLinks = _existingLinks
        .where(
          (link) =>
              link.id != _newLink?.id &&
              link.isActive &&
              (link.expiresAt == null || link.expiresAt!.isAfter(now)),
        )
        .toList();
    final pastLinks = _existingLinks
        .where(
          (link) =>
              !link.isActive ||
              (link.expiresAt != null && !link.expiresAt!.isAfter(now)),
        )
        .toList();
    final showIncidentBanner =
        incident != null &&
        incident.isActive &&
        incident.affectsSurface('mobile_app');

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.uiShareProfileReports(widget.profileName)),
        actions: [
          IconButton(
            key: const Key('share-policy-settings-button'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openPolicySettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showIncidentBanner) ...[
                IncidentBanner(incident: incident),
                const SizedBox(height: 16),
              ],
              if (_createState == _CreateState.created && _newLink != null) ...[
                _buildCreatedLink(context, _newLink!),
                const SizedBox(height: 24),
              ],
              // --- Existing links section ---
              if (_loadingExistingLinks)
                const Center(
                  child: CircularProgressIndicator(
                    key: Key('existing-links-loading'),
                  ),
                )
              else if (activeLinks.isNotEmpty) ...[
                Text(
                  context.l10n.uiActiveSharedLinks,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(activeLinks.length, (i) {
                  final link = activeLinks[i];
                  final expiry = link.expiresAt != null
                      ? context.l10n.uiExpiresDate(_formatDate(link.expiresAt!))
                      : context.l10n.uiNoExpiry;
                  final scope = link.scope == 'selected_results'
                      ? context.l10n.uiSelectedResultsCount(
                          (link.labValueIds?.length ?? 0).toString(),
                        )
                      : link.scope == 'selected_reports'
                      ? context.l10n.uiSelectedReportsCount(
                          (link.reportIds?.length ?? 0).toString(),
                        )
                      : context.l10n.allReports;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            context.l10n.uiProfileReports(widget.profileName),
                          ),
                          subtitle: Text(
                            '$scope · $expiry${link.requiresAccessCode ? ' · ${context.l10n.uiAccessCodeRequiredShort}' : ''}',
                          ),
                          trailing: TextButton(
                            key: Key('revoke-existing-link-${link.id}'),
                            onPressed: () => _revokeLink(link.id),
                            child: Text(context.l10n.revoke),
                          ),
                        ),
                        if (link.requiresAccessCode)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: _buildExistingAccessCode(context, link),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Wrap(
                            spacing: 4,
                            children: [
                              TextButton.icon(
                                key: Key('access-history-link-${link.id}'),
                                icon: const Icon(
                                  Icons.history_outlined,
                                  size: 18,
                                ),
                                label: Text(context.l10n.history),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ShareAccessHistoryScreen(
                                      linkId: link.id,
                                      sharingRepository:
                                          widget.sharingRepository,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                key: Key('share-existing-link-${link.id}'),
                                icon: const Icon(
                                  Icons.share_outlined,
                                  size: 18,
                                ),
                                label: Text(context.l10n.uiShare),
                                onPressed: () => _shareLink(link.shareUrl),
                              ),
                              TextButton.icon(
                                key: Key('copy-existing-link-${link.id}'),
                                icon: const Icon(Icons.copy_outlined, size: 18),
                                label: Text(context.l10n.copy),
                                onPressed: () => _copyLink(link.shareUrl),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
              ],
              if (pastLinks.isNotEmpty) ...[
                Text(
                  context.l10n.uiPastLinksCount(pastLinks.length.toString()),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final link in pastLinks)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        context.l10n.uiProfileReports(widget.profileName),
                      ),
                      subtitle: Text(
                        link.isActive
                            ? context.l10n.uiExpiredDate(
                                _formatDate(link.expiresAt!),
                              )
                            : context.l10n.uiRevokedCreatedDate(
                                _formatDate(link.createdAt),
                              ),
                      ),
                    ),
                  ),
                const Divider(height: 24),
              ],
              if (_listError != null) ...[
                Text(
                  _listError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 8),
              ],

              // --- Create new link section ---
              if (_createState == _CreateState.idle ||
                  _createState == _CreateState.error) ...[
                Text(context.l10n.uiCreateANewShareLink),
                const SizedBox(height: 12),
                if (widget.reportsRepository != null) ...[
                  Card(
                    child: RadioGroup<bool>(
                      groupValue: _selectReports,
                      onChanged: (value) => setState(() {
                        _selectReports = value ?? false;
                        if (!_selectReports) _shareSelectedResults = false;
                      }),
                      child: Column(
                        children: [
                          RadioListTile<bool>(
                            title: Text(context.l10n.allReports),
                            subtitle: Text(
                              context
                                  .l10n
                                  .uiIncludeCurrentAndFutureReportsForThis,
                            ),
                            value: false,
                          ),
                          RadioListTile<bool>(
                            title: Text(context.l10n.uiChooseReports),
                            subtitle: Text(
                              context.l10n.uiShareOnlyTheReportsSelectedBelow,
                            ),
                            value: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectReports) ...[
                    if (_availableReports.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedReportIds
                                ..clear()
                                ..addAll(
                                  _availableReports.map((report) => report.id),
                                );
                            });
                            if (_shareSelectedResults) {
                              unawaited(_loadSelectableValues());
                            }
                          },
                          child: Text(context.l10n.uiSelectAll),
                        ),
                      ),
                    if (_loadingReports)
                      const Center(child: CircularProgressIndicator())
                    else if (_reportsError != null)
                      Column(
                        children: [
                          Text(_reportsError!),
                          TextButton(
                            onPressed: _loadReports,
                            child: Text(context.l10n.tryAgain),
                          ),
                        ],
                      )
                    else if (_availableReports.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          context.l10n.uiNoReviewedReportsAreAvailableToShare,
                        ),
                      )
                    else
                      for (final report in _availableReports)
                        CheckboxListTile(
                          key: Key('share-report-${report.id}'),
                          value: _selectedReportIds.contains(report.id),
                          title: Text(report.originalFileName),
                          subtitle: Text(_formatDate(report.createdAt)),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedReportIds.add(report.id);
                              } else {
                                _selectedReportIds.remove(report.id);
                              }
                            });
                            if (_shareSelectedResults) {
                              unawaited(_loadSelectableValues());
                            }
                          },
                        ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _shareSelectedResults,
                      title: Text(context.l10n.uiSelectedTestResults),
                      subtitle: Text(
                        context.l10n.uiIncludeOnlyTheResultsYouChooseFrom,
                      ),
                      onChanged: _selectedReportIds.isEmpty
                          ? null
                          : (value) {
                              setState(() => _shareSelectedResults = value);
                              if (value) unawaited(_loadSelectableValues());
                            },
                    ),
                    if (_shareSelectedResults) ...[
                      if (_loadingSelectableValues)
                        const Center(child: CircularProgressIndicator())
                      else if (_valuesError != null)
                        Column(
                          children: [
                            Text(_valuesError!),
                            TextButton(
                              onPressed: _loadSelectableValues,
                              child: Text(context.l10n.tryAgain),
                            ),
                          ],
                        )
                      else if (_selectableValues.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            context.l10n.uiNoSavedTestResultsAreAvailableIn,
                          ),
                        )
                      else
                        for (final entry in _selectableValues)
                          CheckboxListTile(
                            key: Key('share-value-${entry.$2.id}'),
                            value: _selectedLabValueIds.contains(entry.$2.id),
                            title: Text(entry.$2.parameterName),
                            subtitle: Text(
                              '${entry.$2.value} ${entry.$2.unit ?? ''} · ${entry.$1.originalFileName}',
                            ),
                            onChanged: (checked) => setState(() {
                              if (checked == true) {
                                _selectedLabValueIds.add(entry.$2.id!);
                              } else {
                                _selectedLabValueIds.remove(entry.$2.id);
                              }
                            }),
                          ),
                    ],
                  ],
                ],
                if (_limitMessage != null) ...[
                  Text(
                    _limitMessage!,
                    key: const Key('share-limit-warning'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  if (_limitCurrent != null && _limitMax != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.uiUsingActiveLinks(
                        _limitCurrent.toString(),
                        _limitMax.toString(),
                      ),
                    ),
                  ],
                  if (_limitUpgradeHint != null) ...[
                    const SizedBox(height: 4),
                    Text(_limitUpgradeHint!),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const Key('share-limit-upgrade'),
                    onPressed: widget.onUpgrade,
                    child: Text(context.l10n.uiUpgradeOrManage),
                  ),
                  const SizedBox(height: 12),
                ],
                // Expiry picker row
                Row(
                  children: [
                    Text(context.l10n.uiExpiry),
                    const SizedBox(width: 8),
                    TextButton(
                      key: const Key('share-link-expiry-picker'),
                      onPressed: _pickExpiry,
                      child: Text(
                        _selectedExpiry != null
                            ? _formatDate(_selectedExpiry!)
                            : context.l10n.uiNoExpiry,
                      ),
                    ),
                    if (_selectedExpiry != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _expiryTouched = true;
                          _selectedExpiry = null;
                        }),
                        tooltip: context.l10n.uiClearExpiry,
                      ),
                  ],
                ),
                SwitchListTile(
                  value: _requireAccessCode,
                  title: Text(context.l10n.uiRequireAnAccessCode),
                  subtitle: Text(
                    context.l10n.uiShareTheCodeSeparatelyFromTheLink,
                  ),
                  onChanged: (value) =>
                      setState(() => _requireAccessCode = value),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  key: const Key('create-share-link-button'),
                  onPressed: _createState == _CreateState.loading
                      ? null
                      : _reviewAndCreate,
                  child: Text(context.l10n.uiReviewSharing),
                ),
                if (_createState == _CreateState.error) ...[
                  const SizedBox(height: 8),
                  Text(
                    _createError ?? context.l10n.somethingWrong,
                    key: const Key('share-link-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: _reviewAndCreate,
                    child: Text(context.l10n.uiTryAgain),
                  ),
                  if (_supportContext != null) ...[
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {
                        final supportContext = _supportContext;
                        if (supportContext == null) return;
                        showSupportRequestSheet(
                          context: context,
                          supportRepository: widget.supportRepository,
                          supportContext: supportContext,
                          errorMessage: _supportErrorMessage,
                        );
                      },
                      child: Text(context.l10n.needHelp),
                    ),
                  ],
                ],
              ],
              if (_createState == _CreateState.loading)
                const Center(
                  child: CircularProgressIndicator(
                    key: Key('create-share-link-loading'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
