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
          _reportsError = 'Reports could not be loaded. Try again.';
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
          _valuesError = 'Test results could not be loaded. Try again.';
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
          _listError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _createLink() async {
    if (_selectReports && _selectedReportIds.isEmpty) {
      setState(() {
        _createState = _CreateState.error;
        _createError = 'Select at least one report to share.';
      });
      return;
    }
    if (_shareSelectedResults && _selectedLabValueIds.isEmpty) {
      setState(() {
        _createState = _CreateState.error;
        _createError = 'Select at least one test result to share.';
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
          _limitMessage = e.message;
          _limitUpgradeHint = data?['upgradeHint'] as String?;
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
          _createError = e.toString().replaceFirst('Exception: ', '');
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
          _createError = e.toString().replaceFirst('Exception: ', '');
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
        _createError = 'Select at least one report to share.';
      });
      return;
    }
    if (_shareSelectedResults && _selectedLabValueIds.isEmpty) {
      setState(() {
        _createState = _CreateState.error;
        _createError = 'Select at least one test result to share.';
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
                'Review sharing',
                style: Theme.of(sheetContext).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Check the person, reports and access.'),
              const SizedBox(height: 20),
              Text(
                widget.profileName,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _selectReports
                    ? '${_selectedReportIds.length} selected reports'
                    : 'All current and future reports',
              ),
              if (_shareSelectedResults)
                Text('${_selectedLabValueIds.length} selected test results'),
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
                    ? 'No expiry'
                    : 'Expires ${_formatDate(_selectedExpiry!)}',
              ),
              Text(
                _requireAccessCode
                    ? 'Access code required. Share it separately from the link.'
                    : 'No access code required.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('Create link'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                child: const Text('Edit selection or access settings'),
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
      StatusMessenger.showSuccess(context, 'Link copied to clipboard');
    }
  }

  Future<void> _copyAccessCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      StatusMessenger.showSuccess(context, 'Access code copied to clipboard');
    }
  }

  Future<void> _shareLink(String url) async {
    await Share.share(url);
  }

  Future<void> _revokeLink(String linkId, {bool isNewLink = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke share link?'),
        content: const Text(
          'This link will stop working. You can create a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('revoke-confirm-button'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke'),
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
          'Failed to revoke: ${e.toString().replaceFirst('Exception: ', '')}',
          actionLabel: 'Need help?',
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
            Text('Share link ready', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(link.shareUrl, key: const Key('share-url-text')),
            if (link.expiresAt != null) ...[
              const SizedBox(height: 4),
              Text('Expires: ${_formatDate(link.expiresAt!)}'),
            ],
            if (link.accessCode != null) ...[
              const SizedBox(height: 16),
              Text(
                'Access code — share separately',
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
                label: const Text('Copy access code'),
              ),
              if (_codeSaveFailed)
                Text(
                  'This code could not be saved on this device. Copy it now for later use.',
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
                  label: const Text('Share link'),
                ),
                OutlinedButton.icon(
                  key: const Key('copy-link-button'),
                  onPressed: () => _copyLink(link.shareUrl),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy link'),
                ),
                TextButton(
                  key: const Key('new-link-revoke-button'),
                  onPressed: () => _revokeLink(link.id, isNewLink: true),
                  child: const Text('Revoke link'),
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
      return const Text(
        'Code unavailable on this device. Use the saved code or create a new link.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Access code — share separately',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SelectableText(
          code,
          key: Key('existing-share-access-code-${link.id}'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: () => _copyAccessCode(code),
          child: const Text('Copy access code'),
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
        title: Text('Share ${widget.profileName}\'s Reports'),
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
                const Text(
                  'Active shared links',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(activeLinks.length, (i) {
                  final link = activeLinks[i];
                  final expiry = link.expiresAt != null
                      ? 'Expires ${_formatDate(link.expiresAt!)}'
                      : 'No expiry';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text('${widget.profileName}’s reports'),
                          subtitle: Text(
                            '${link.scope == 'selected_results'
                                ? '${link.labValueIds?.length ?? 0} selected results'
                                : link.scope == 'selected_reports'
                                ? '${link.reportIds?.length ?? 0} selected reports'
                                : 'All reports'} · $expiry${link.requiresAccessCode ? ' · Access code required' : ''}',
                          ),
                          trailing: TextButton(
                            key: Key('revoke-existing-link-${link.id}'),
                            onPressed: () => _revokeLink(link.id),
                            child: const Text('Revoke'),
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
                                label: const Text('History'),
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
                                label: const Text('Share'),
                                onPressed: () => _shareLink(link.shareUrl),
                              ),
                              TextButton.icon(
                                key: Key('copy-existing-link-${link.id}'),
                                icon: const Icon(Icons.copy_outlined, size: 18),
                                label: const Text('Copy'),
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
                  'Past links · ${pastLinks.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final link in pastLinks)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${widget.profileName}’s reports'),
                      subtitle: Text(
                        link.isActive
                            ? 'Expired ${_formatDate(link.expiresAt!)}'
                            : 'Revoked · Created ${_formatDate(link.createdAt)}',
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
                const Text('Create a new share link'),
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
                            title: const Text('All reports'),
                            subtitle: const Text(
                              'Include current and future reports for this profile.',
                            ),
                            value: false,
                          ),
                          RadioListTile<bool>(
                            title: const Text('Choose reports'),
                            subtitle: const Text(
                              'Share only the reports selected below.',
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
                          child: const Text('Select all'),
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
                            child: const Text('Try again'),
                          ),
                        ],
                      )
                    else if (_availableReports.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No reviewed reports are available to share.',
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
                      title: const Text('Selected test results'),
                      subtitle: const Text(
                        'Include only the results you choose from these reports.',
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
                              child: const Text('Try again'),
                            ),
                          ],
                        )
                      else if (_selectableValues.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No saved test results are available in these reports.',
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
                    Text('Using $_limitCurrent of $_limitMax active links.'),
                  ],
                  if (_limitUpgradeHint != null) ...[
                    const SizedBox(height: 4),
                    Text(_limitUpgradeHint!),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const Key('share-limit-upgrade'),
                    onPressed: widget.onUpgrade,
                    child: const Text('Upgrade or Manage'),
                  ),
                  const SizedBox(height: 12),
                ],
                // Expiry picker row
                Row(
                  children: [
                    const Text('Expiry:'),
                    const SizedBox(width: 8),
                    TextButton(
                      key: const Key('share-link-expiry-picker'),
                      onPressed: _pickExpiry,
                      child: Text(
                        _selectedExpiry != null
                            ? _formatDate(_selectedExpiry!)
                            : 'No expiry',
                      ),
                    ),
                    if (_selectedExpiry != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _expiryTouched = true;
                          _selectedExpiry = null;
                        }),
                        tooltip: 'Clear expiry',
                      ),
                  ],
                ),
                SwitchListTile(
                  value: _requireAccessCode,
                  title: const Text('Require an access code'),
                  subtitle: const Text(
                    'Share the code separately from the link.',
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
                  child: const Text('Review sharing'),
                ),
                if (_createState == _CreateState.error) ...[
                  const SizedBox(height: 8),
                  Text(
                    _createError ?? 'Something went wrong',
                    key: const Key('share-link-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: _reviewAndCreate,
                    child: const Text('Try Again'),
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
                      child: const Text('Need help?'),
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
