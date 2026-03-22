import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../sharing_repository.dart';
import 'share_policy_screen.dart';
import 'share_access_history_screen.dart';

enum _CreateState { idle, loading, created, error }

class CreateShareLinkScreen extends StatefulWidget {
  const CreateShareLinkScreen({
    super.key,
    required this.profileId,
    required this.profileName,
    required this.sharingRepository,
  });
  final String profileId;
  final String profileName;
  final SharingRepository sharingRepository;

  @override
  State<CreateShareLinkScreen> createState() => _CreateShareLinkScreenState();
}

class _CreateShareLinkScreenState extends State<CreateShareLinkScreen> {
  // Existing links loading state
  bool _loadingExistingLinks = false;
  List<ShareLink> _existingLinks = [];
  String? _listError;

  // Create new link state
  _CreateState _createState = _CreateState.idle;
  ShareLink? _newLink;
  String? _createError;
  DateTime? _selectedExpiry; // null = no expiry

  // Policy
  SharePolicy? _policy;

  @override
  void initState() {
    super.initState();
    _loadExistingLinks();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    try {
      final policy = await widget.sharingRepository.getSharePolicy();
      if (mounted) {
        setState(() {
          _policy = policy;
          if (policy.defaultExpiresInDays != null && _selectedExpiry == null) {
            _selectedExpiry = DateTime.now().add(Duration(days: policy.defaultExpiresInDays!));
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
        builder: (_) => SharePolicyScreen(sharingRepository: widget.sharingRepository),
      ),
    );
    if (updated == true) _loadPolicy();
  }

  Future<void> _loadExistingLinks() async {
    setState(() { _loadingExistingLinks = true; _listError = null; });
    try {
      final links = await widget.sharingRepository.listShareLinks(widget.profileId);
      if (mounted) setState(() { _existingLinks = links; _loadingExistingLinks = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingExistingLinks = false; _listError = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _createLink() async {
    setState(() { _createState = _CreateState.loading; _createError = null; });
    try {
      final link = await widget.sharingRepository.createShareLink(
        widget.profileId,
        expiresAt: _selectedExpiry,
      );
      if (mounted) setState(() { _newLink = link; _createState = _CreateState.created; });
    } catch (e) {
      if (mounted) setState(() { _createState = _CreateState.error; _createError = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')),
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
        title: const Text('Revoke share link?'),
        content: const Text('This link will stop working. You can create a new one.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
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
      if (!mounted) return;
      if (isNewLink) {
        setState(() { _newLink = null; _createState = _CreateState.idle; });
      } else {
        setState(() { _existingLinks.removeWhere((l) => l.id == linkId); });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke: ${e.toString().replaceFirst('Exception: ', '')}')),
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
      setState(() { _selectedExpiry = picked; });
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
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
              // --- Existing links section ---
              if (_loadingExistingLinks)
                const Center(child: CircularProgressIndicator(key: Key('existing-links-loading')))
              else if (_existingLinks.isNotEmpty) ...[
                const Text('Active share links', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(_existingLinks.length, (i) {
                  final link = _existingLinks[i];
                  final expiry = link.expiresAt != null
                      ? 'Expires ${_formatDate(link.expiresAt!)}'
                      : 'No expiry';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(link.shareUrl, style: const TextStyle(fontSize: 12)),
                      subtitle: Text('Created ${_formatDate(link.createdAt)} · $expiry'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            key: Key('access-history-link-${link.id}'),
                            icon: const Icon(Icons.history_outlined),
                            tooltip: 'View access history',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShareAccessHistoryScreen(
                                  linkId: link.id,
                                  sharingRepository: widget.sharingRepository,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            key: Key('share-existing-link-${link.id}'),
                            icon: const Icon(Icons.share_outlined),
                            tooltip: 'Share link',
                            onPressed: () => _shareLink(link.shareUrl),
                          ),
                          IconButton(
                            key: Key('copy-existing-link-${link.id}'),
                            icon: const Icon(Icons.copy_outlined),
                            tooltip: 'Copy link',
                            onPressed: () => _copyLink(link.shareUrl),
                          ),
                          TextButton(
                            key: Key('revoke-existing-link-${link.id}'),
                            onPressed: () => _revokeLink(link.id),
                            child: const Text('Revoke'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(height: 24),
              ],
              if (_listError != null) ...[
                Text(_listError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 8),
              ],

              // --- Create new link section ---
              if (_createState == _CreateState.idle || _createState == _CreateState.error) ...[
                const Text('Create a new share link'),
                const SizedBox(height: 12),
                // Expiry picker row
                Row(
                  children: [
                    const Text('Expiry:'),
                    const SizedBox(width: 8),
                    TextButton(
                      key: const Key('share-link-expiry-picker'),
                      onPressed: _pickExpiry,
                      child: Text(_selectedExpiry != null ? _formatDate(_selectedExpiry!) : 'No expiry'),
                    ),
                    if (_selectedExpiry != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedExpiry = null),
                        tooltip: 'Clear expiry',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  key: const Key('create-share-link-button'),
                  onPressed: _createState == _CreateState.loading ? null : _createLink,
                  child: const Text('Create Share Link'),
                ),
                if (_createState == _CreateState.error) ...[
                  const SizedBox(height: 8),
                  Text(
                    _createError ?? 'Something went wrong',
                    key: const Key('share-link-error'),
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  TextButton(onPressed: _createLink, child: const Text('Try Again')),
                ],
              ],
              if (_createState == _CreateState.loading)
                const Center(child: CircularProgressIndicator(key: Key('create-share-link-loading'))),
              if (_createState == _CreateState.created && _newLink != null) ...[
                const Text('Share link created!'),
                const SizedBox(height: 8),
                SelectableText(_newLink!.shareUrl, key: const Key('share-url-text')),
                if (_newLink!.expiresAt != null) ...[
                  const SizedBox(height: 4),
                  Text('Expires: ${_formatDate(_newLink!.expiresAt!)}',
                      style: const TextStyle(fontSize: 12)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('copy-link-button'),
                  onPressed: () => _copyLink(_newLink!.shareUrl),
                  child: const Text('Copy Link'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('share-link-button'),
                  onPressed: () => _shareLink(_newLink!.shareUrl),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.share_outlined, size: 16), SizedBox(width: 8), Text('Share Link')],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('new-link-revoke-button'),
                  onPressed: () => _revokeLink(_newLink!.id, isNewLink: true),
                  child: const Text('Revoke Link'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
