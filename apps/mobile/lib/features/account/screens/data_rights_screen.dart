import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data_rights_repository.dart';
import '../../profiles/profiles_repository.dart';
import '../../reports/reports_repository.dart';
import '../../../core/theme/app_theme.dart';

enum DataRightsMode { combined, export, delete }

class DataRightsScreen extends StatefulWidget {
  const DataRightsScreen({
    super.key,
    required this.dataRightsRepository,
    required this.onBack,
    required this.onAccountClosed,
    this.onAccountRestored,
    this.mode = DataRightsMode.combined,
    this.profilesRepository,
    this.reportsRepository,
    this.onOpenExport,
  });

  final DataRightsRepository dataRightsRepository;
  final VoidCallback onBack;
  final Future<void> Function() onAccountClosed;
  final Future<void> Function()? onAccountRestored;
  final DataRightsMode mode;
  final ProfilesRepository? profilesRepository;
  final ReportsRepository? reportsRepository;
  final VoidCallback? onOpenExport;

  @override
  State<DataRightsScreen> createState() => _DataRightsScreenState();
}

class _DataRightsScreenState extends State<DataRightsScreen> {
  DataExportRequest? _exportRequest;
  bool _exportLoading = false;
  String? _exportError;
  String? _exportSuccess;

  bool _closureLoading = false;
  String? _closureError;
  ClosureRequest? _closureRequest;
  Future<(int, int)>? _recordCounts;
  Future<List<Profile>>? _profilesFuture;
  String? _selectedProfileId;
  DateTimeRange? _dateRange;
  bool _includeOriginals = true;
  bool _includeResults = true;
  bool _sharingExport = false;

  @override
  void initState() {
    super.initState();
    _loadClosure();
    if (widget.profilesRepository != null && widget.reportsRepository != null) {
      _profilesFuture = widget.profilesRepository!.getProfiles();
      _profilesFuture!.then((profiles) {
        if (!mounted) return;
        for (final profile in profiles) {
          if (profile.isActive) {
            setState(() {
              _selectedProfileId = profile.id;
              _recordCounts = _loadRecordCounts();
            });
            break;
          }
        }
      }).catchError((Object _) {});
      _recordCounts = _loadRecordCounts();
    }
  }

  Future<(int, int)> _loadRecordCounts() async {
    final profiles = await widget.profilesRepository!.getProfiles();
    final reports = await widget.reportsRepository!.listAllReports();
    final selected = _selectedProfileId;
    final range = _dateRange;
    final matchingProfiles = selected == null
        ? profiles
        : profiles.where((profile) => profile.id == selected).toList();
    final matchingReports = reports.where((report) {
      if (selected != null && report.profileId != selected) return false;
      if (range != null && report.createdAt.isBefore(range.start)) return false;
      if (range != null &&
          report.createdAt.isAfter(
            DateTime(
              range.end.year,
              range.end.month,
              range.end.day,
              23,
              59,
              59,
              999,
            ),
          )) {
        return false;
      }
      return true;
    });
    return (matchingProfiles.length, matchingReports.length);
  }

  void _refreshCounts() => setState(() {
    _recordCounts = _loadRecordCounts();
  });

  Future<void> _shareExport() async {
    final request = _exportRequest;
    if (request == null || _sharingExport) return;
    setState(() => _sharingExport = true);
    try {
      final refreshed = await widget.dataRightsRepository.getExportRequest(
        request.requestId,
      );
      final url = refreshed.downloadUrl;
      if (url == null) throw const HttpException('Export unavailable');
      if (mounted) setState(() => _exportRequest = refreshed);
      final List<int> bytes;
      if (url.startsWith('data:')) {
        bytes = base64Decode(url.substring(url.indexOf(',') + 1));
      } else {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) {
          throw const HttpException('Export unavailable');
        }
        bytes = response.bodyBytes;
      }
      final isArchive =
          bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;
      final name = isArchive
          ? 'doclyzer-export.tar.gz'
          : 'doclyzer-account-data.json';
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$name');
      await file.writeAsBytes(bytes, flush: true);
      if (mounted) await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      if (mounted) {
        setState(
          () => _exportError = 'Could not download the export. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _sharingExport = false);
    }
  }

  Future<void> _loadClosure() async {
    try {
      final request = await widget.dataRightsRepository.getClosureRequest();
      if (mounted) setState(() => _closureRequest = request);
    } catch (_) {
      // The action itself reports errors if status could not be loaded.
    }
  }

  Future<void> _restoreClosure() async {
    setState(() {
      _closureLoading = true;
      _closureError = null;
    });
    try {
      await widget.dataRightsRepository.restoreClosure();
      if (widget.onAccountRestored != null) await widget.onAccountRestored!();
      if (mounted) {
        setState(() {
          _closureRequest = null;
          _closureLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _closureLoading = false;
          _closureError = error.toString();
        });
      }
    }
  }

  Future<void> _requestExport() async {
    setState(() {
      _exportLoading = true;
      _exportError = null;
      _exportSuccess = null;
    });
    try {
      if (widget.mode == DataRightsMode.export &&
          !_includeOriginals &&
          !_includeResults) {
        throw const DataRightsException(
          'Select original reports or test results.',
        );
      }
      final req = widget.mode == DataRightsMode.export
          ? await widget.dataRightsRepository.createScopedExportRequest(
              profileId: _selectedProfileId,
              from: _dateRange?.start,
              to: _dateRange == null
                  ? null
                  : DateTime(
                      _dateRange!.end.year,
                      _dateRange!.end.month,
                      _dateRange!.end.day,
                      23,
                      59,
                      59,
                      999,
                    ),
              includeOriginals: _includeOriginals,
              includeResults: _includeResults,
            )
          : await widget.dataRightsRepository.createExportRequest();
      setState(() {
        _exportRequest = req;
        _exportLoading = false;
        _exportSuccess = 'Export requested. Tap "Check Status" to refresh.';
      });
    } on DataRightsException catch (e) {
      setState(() {
        _exportLoading = false;
        _exportError = e.message;
      });
    } catch (_) {
      setState(() {
        _exportLoading = false;
        _exportError = 'Failed to request export. Please try again.';
      });
    }
  }

  Future<void> _checkExportStatus() async {
    final current = _exportRequest;
    if (current == null) return;
    setState(() {
      _exportLoading = true;
      _exportError = null;
    });
    try {
      final updated = await widget.dataRightsRepository.getExportRequest(
        current.requestId,
      );
      setState(() {
        _exportRequest = updated;
        _exportLoading = false;
        if (updated.status == 'completed') {
          _exportSuccess = 'Export ready. Download URL available.';
        }
      });
    } on DataRightsException catch (e) {
      setState(() {
        _exportLoading = false;
        _exportError = e.message;
      });
    } catch (_) {
      setState(() {
        _exportLoading = false;
        _exportError = 'Failed to check export status. Please try again.';
      });
    }
  }

  Future<void> _confirmClosure(String password) async {
    setState(() {
      _closureLoading = true;
      _closureError = null;
    });
    try {
      await widget.dataRightsRepository.createClosureRequest(
        confirmClosure: true,
        password: password,
      );
      await widget.onAccountClosed();
      if (mounted) setState(() => _closureLoading = false);
    } on DataRightsException catch (e) {
      setState(() {
        _closureLoading = false;
        _closureError = e.message;
      });
    } catch (_) {
      setState(() {
        _closureLoading = false;
        _closureError = 'Failed to close account. Please try again.';
      });
    }
  }

  void _showClosureDialog() {
    var password = '';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          key: const Key('closure-dialog'),
          title: const Text('Close Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Access stops immediately. You can sign in and restore within 30 days. After that, your account and stored files are deleted from active storage.',
                key: Key('closure-impact-text'),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                onChanged: (value) => setDialogState(() => password = value),
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              key: const Key('closure-cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('closure-confirm'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: password.isEmpty
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      _confirmClosure(password);
                    },
              child: const Text('Close My Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Export your data')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              key: const Key('export-request-button'),
              onPressed: _exportLoading
                  ? null
                  : _exportRequest == null
                  ? _requestExport
                  : _exportRequest!.status == 'completed'
                  ? _shareExport
                  : _exportRequest!.status == 'failed'
                  ? _requestExport
                  : _checkExportStatus,
              child: _exportLoading || _sharingExport
                  ? const CircularProgressIndicator()
                  : Text(
                      _exportRequest == null
                          ? 'Prepare export'
                          : _exportRequest!.status == 'completed'
                          ? 'Save export'
                          : _exportRequest!.status == 'failed'
                          ? 'Prepare export again'
                          : 'Check status',
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your records stay in Doclyzer.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Take a copy of your records.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Text('Whose records?', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          FutureBuilder<List<Profile>>(
            future: _profilesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Card(
                  child: ListTile(title: Text('Could not load profiles')),
                );
              }
              if (!snapshot.hasData) {
                return const Card(
                  child: ListTile(title: Text('Loading profiles…')),
                );
              }
              return DropdownButtonFormField<String?>(
                key: const Key('export-profile'),
                initialValue: _selectedProfileId,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All profiles'),
                  ),
                  for (final profile in snapshot.data!)
                    DropdownMenuItem<String?>(
                      value: profile.id,
                      child: Text(profile.name),
                    ),
                ],
                onChanged: _exportRequest != null
                    ? null
                    : (value) {
                        _selectedProfileId = value;
                        _refreshCounts();
                      },
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Date range', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              key: const Key('export-date-range'),
              title: Text(
                _dateRange == null
                    ? 'All dates'
                    : '${MaterialLocalizations.of(context).formatMediumDate(_dateRange!.start)} – ${MaterialLocalizations.of(context).formatMediumDate(_dateRange!.end)}',
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _exportRequest != null
                  ? null
                  : () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                      );
                      if (range != null && mounted) {
                        _dateRange = range;
                        _refreshCounts();
                      }
                    },
            ),
          ),
          if (_dateRange != null && _exportRequest == null)
            TextButton(
              onPressed: () {
                _dateRange = null;
                _refreshCounts();
              },
              child: const Text('Use all dates'),
            ),
          const SizedBox(height: 28),
          Text(
            'INCLUDE IN THIS EXPORT',
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                CheckboxListTile(
                  key: const Key('export-originals'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _includeOriginals,
                  onChanged: _exportRequest != null
                      ? null
                      : (value) =>
                            setState(() => _includeOriginals = value ?? false),
                  title: const Text('Original reports'),
                  subtitle: const Text('PDFs and images you uploaded'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                CheckboxListTile(
                  key: const Key('export-results'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _includeResults,
                  onChanged: _exportRequest != null
                      ? null
                      : (value) =>
                            setState(() => _includeResults = value ?? false),
                  title: const Text('Test results'),
                  subtitle: const Text(
                    'Results as CSV, with their review state',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<(int, int)>(
            future: _recordCounts,
            builder: (context, snapshot) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                snapshot.hasData
                    ? '${snapshot.data!.$1} ${snapshot.data!.$1 == 1 ? 'profile' : 'profiles'} · ${snapshot.data!.$2} ${snapshot.data!.$2 == 1 ? 'report' : 'reports'} in your account'
                    : 'Preparing account details',
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Exports contain personal information. Store them somewhere you trust.',
            style: theme.textTheme.bodySmall,
          ),
          if (_exportRequest != null) ...[
            const SizedBox(height: 16),
            Text(
              'Status: ${_exportRequest!.status}',
              key: const Key('export-status'),
            ),
          ],
          if (_exportError != null) ...[
            const SizedBox(height: 12),
            Text(
              _exportError!,
              key: const Key('export-error'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          if (_exportSuccess != null)
            Text(_exportSuccess!, key: const Key('export-success')),
        ],
      ),
    );
  }

  Widget _buildDeleteScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Delete account')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              key: const Key('close-account-button'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              onPressed: _closureLoading ? null : _showClosureDialog,
              child: _closureLoading
                  ? const CircularProgressIndicator()
                  : const Text('Continue to deletion'),
            ),
            TextButton(
              onPressed: widget.onBack,
              child: const Text('Keep my account'),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFBEDEE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_outline, color: AppColors.destructive),
              title: Text(
                'Before you leave',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Please read what this will remove.'),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Deleting your account affects all profiles you manage.',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 28),
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Your account and personal profile'),
          ),
          FutureBuilder<(int, int)>(
            future: _recordCounts,
            builder: (context, snapshot) => Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: Text(
                    snapshot.hasData
                        ? '${snapshot.data!.$1} family member profiles'
                        : 'Family member profiles',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    snapshot.hasData
                        ? '${snapshot.data!.$2} uploaded reports'
                        : 'Uploaded reports',
                  ),
                ),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(Icons.link_off_outlined),
            title: Text('Access through your shared links'),
          ),
          const SizedBox(height: 28),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Keep a copy first'),
              subtitle: const Text(
                'Export the information you want to retain.',
              ),
              trailing: TextButton(
                onPressed: widget.onOpenExport,
                child: const Text('Export data'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Access stops immediately. You can restore within 30 days. After that, your data is removed from active storage.',
          ),
          if (_closureError != null) ...[
            const SizedBox(height: 12),
            Text(
              _closureError!,
              key: const Key('closure-error'),
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == DataRightsMode.export) {
      return _buildExportScreen(context);
    }
    if (widget.mode == DataRightsMode.delete) {
      return _buildDeleteScreen(context);
    }
    final exportRequest = _exportRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Data'),
        leading: _closureRequest?.status == 'pending'
            ? null
            : BackButton(
                key: const Key('data-rights-back'),
                onPressed: widget.onBack,
              ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_closureRequest?.status == 'pending') ...[
                const Text(
                  'Account pending deletion',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Restore before ${_closureRequest!.purgeAfterAt ?? 'the 30-day deadline'} to keep your reports and profiles.',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _closureLoading ? null : _restoreClosure,
                  child: const Text('Restore my account'),
                ),
                if (_closureError != null)
                  Text(
                    _closureError!,
                    style: const TextStyle(color: Colors.red),
                  ),
              ] else ...[
                const Text(
                  'Export My Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Download a copy of your account data including your profile, profiles, and consent records.',
                ),
                const SizedBox(height: 12),
                if (exportRequest == null)
                  FilledButton(
                    key: const Key('export-request-button'),
                    onPressed: _exportLoading ? null : _requestExport,
                    child: _exportLoading
                        ? const SizedBox(
                            key: Key('export-loading'),
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Export My Data'),
                  )
                else ...[
                  Text(
                    key: const Key('export-status'),
                    'Status: ${exportRequest.status}',
                  ),
                  if (exportRequest.status == 'pending') ...[
                    const SizedBox(height: 8),
                    FilledButton(
                      key: const Key('export-check-status-button'),
                      onPressed: _exportLoading ? null : _checkExportStatus,
                      child: _exportLoading
                          ? const SizedBox(
                              key: Key('export-status-loading'),
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Check Status'),
                    ),
                  ],
                  if (exportRequest.status == 'completed' &&
                      exportRequest.downloadUrl != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      key: const Key('export-download-ready'),
                      'Download ready',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
                if (_exportError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    key: const Key('export-error'),
                    _exportError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                if (_exportSuccess != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    key: const Key('export-success'),
                    _exportSuccess!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Close Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account is disabled immediately. You can restore it within 30 days. After that, your data is permanently deleted.',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('close-account-button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _closureLoading ? null : _showClosureDialog,
                  child: _closureLoading
                      ? const SizedBox(
                          key: Key('closure-loading'),
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Close My Account'),
                ),
                if (_closureError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    key: const Key('closure-error'),
                    _closureError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
