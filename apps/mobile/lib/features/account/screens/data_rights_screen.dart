import 'package:flutter/material.dart';

import '../data_rights_repository.dart';

class DataRightsScreen extends StatefulWidget {
  const DataRightsScreen({
    super.key,
    required this.dataRightsRepository,
    required this.onBack,
    required this.onAccountClosed,
  });

  final DataRightsRepository dataRightsRepository;
  final VoidCallback onBack;
  final Future<void> Function() onAccountClosed;

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

  Future<void> _requestExport() async {
    setState(() {
      _exportLoading = true;
      _exportError = null;
      _exportSuccess = null;
    });
    try {
      final req =
          await widget.dataRightsRepository.createExportRequest();
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
      final updated =
          await widget.dataRightsRepository.getExportRequest(current.requestId);
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

  Future<void> _confirmClosure() async {
    setState(() {
      _closureLoading = true;
      _closureError = null;
    });
    try {
      await widget.dataRightsRepository
          .createClosureRequest(confirmClosure: true);
      await widget.onAccountClosed();
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('closure-dialog'),
        title: const Text('Close Account'),
        content: const Text(
          'This action is irreversible. You will lose access to all your data and profiles. '
          'Your sessions will be invalidated immediately.',
          key: Key('closure-impact-text'),
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _confirmClosure();
            },
            child: const Text('Close My Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exportRequest = _exportRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Rights'),
        leading: BackButton(
          key: const Key('data-rights-back'),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              'Permanently close your account. This cannot be undone.',
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
        ),
      ),
    );
  }
}
