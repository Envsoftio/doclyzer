import 'package:mobile/core/localized_error.dart';
import 'package:mobile/l10n/l10n.dart';
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
  _PolicyState _state = _PolicyState.loading;
  int? _selected;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = _PolicyState.loading;
      _error = null;
    });
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
          _error = localizedError(
            context,
            e,
            fallback: context.l10n.genericError,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    setState(() {
      _state = _PolicyState.saving;
    });
    try {
      await widget.sharingRepository.setSharePolicy(_selected);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _PolicyState.error;
          _error = localizedError(
            context,
            e,
            fallback: context.l10n.genericError,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.uiDefaultShareLinkExpiry)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_state == _PolicyState.loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('share-policy-loading')),
      );
    }

    if (_state == _PolicyState.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _error ?? context.l10n.uiFailedToLoadPolicy,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: Text(context.l10n.retry)),
        ],
      );
    }

    return RadioGroup<int?>(
      groupValue: _selected,
      onChanged: (val) {
        if (_state != _PolicyState.saving) {
          setState(() => _selected = val);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._options.asMap().entries.map((entry) {
            final idx = entry.key;
            final option = entry.value;
            final key = option == null
                ? const Key('share-policy-option-null')
                : Key('share-policy-option-$option');
            return RadioListTile<int?>(
              key: key,
              title: Text(
                [
                  context.l10n.uiNoExpiry,
                  context.l10n.uiSevenDays,
                  context.l10n.uiThirtyDays,
                  context.l10n.uiNinetyDays,
                ][idx],
              ),
              value: option,
              selected: option == _selected,
              enabled: _state != _PolicyState.saving,
            );
          }),
          const SizedBox(height: 16),
          if (_state == _PolicyState.saving)
            const Center(child: CircularProgressIndicator())
          else
            FilledButton(
              key: const Key('share-policy-save-button'),
              onPressed: _save,
              child: Text(context.l10n.uiSave),
            ),
        ],
      ),
    );
  }
}
