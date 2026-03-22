import 'package:flutter/material.dart';
import '../sharing_repository.dart';

enum _PolicyState { loading, loaded, saving, error }

class SharePolicyScreen extends StatefulWidget {
  const SharePolicyScreen({super.key, required this.sharingRepository});
  final SharingRepository sharingRepository;

  @override
  State<SharePolicyScreen> createState() => _SharePolicyScreenState();
}

class _SharePolicyScreenState extends State<SharePolicyScreen> {
  static const List<int?> _options = [null, 7, 30, 90];
  static const List<String> _labels = ['No expiry', '7 days', '30 days', '90 days'];

  _PolicyState _state = _PolicyState.loading;
  int? _selected;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _state = _PolicyState.loading; _error = null; });
    try {
      final policy = await widget.sharingRepository.getSharePolicy();
      if (mounted) {
        setState(() {
          _selected = policy.defaultExpiresInDays;
          _state = _PolicyState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _PolicyState.error;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() { _state = _PolicyState.saving; });
    try {
      await widget.sharingRepository.setSharePolicy(_selected);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _PolicyState.error;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Share Link Expiry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_state == _PolicyState.loading) {
      return const Center(child: CircularProgressIndicator(key: Key('share-policy-loading')));
    }

    if (_state == _PolicyState.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_error ?? 'Failed to load policy', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final key = option == null ? const Key('share-policy-option-null') : Key('share-policy-option-$option');
          return RadioListTile<int?>(
            key: key,
            title: Text(_labels[idx]),
            value: option,
            groupValue: _selected,
            onChanged: _state == _PolicyState.saving
                ? null
                : (val) => setState(() => _selected = val),
          );
        }),
        const SizedBox(height: 16),
        if (_state == _PolicyState.saving)
          const Center(child: CircularProgressIndicator())
        else
          FilledButton(
            key: const Key('share-policy-save-button'),
            onPressed: _save,
            child: const Text('Save'),
          ),
      ],
    );
  }
}
