import 'package:flutter/material.dart';

import '../data_rights_repository.dart';

class DataRightsScreen extends StatefulWidget {
  const DataRightsScreen({
    super.key,
    required this.dataRightsRepository,
    required this.onBack,
    required this.onAccountClosed,
    this.onAccountRestored,
  });

  final DataRightsRepository dataRightsRepository;
  final VoidCallback onBack;
  final Future<void> Function() onAccountClosed;
  final Future<void> Function()? onAccountRestored;

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

  @override
  void initState() {
    super.initState();
    _loadClosure();
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
      final req = await widget.dataRightsRepository.createExportRequest();
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

  @override
  Widget build(BuildContext context) {
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
