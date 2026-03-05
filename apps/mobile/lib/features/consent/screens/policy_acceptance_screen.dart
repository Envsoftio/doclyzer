import 'package:flutter/material.dart';

import '../consent_repository.dart';

class PolicyAcceptanceScreen extends StatefulWidget {
  const PolicyAcceptanceScreen({
    super.key,
    required this.consentRepository,
    required this.onComplete,
  });

  final ConsentRepository consentRepository;
  final VoidCallback onComplete;

  @override
  State<PolicyAcceptanceScreen> createState() => _PolicyAcceptanceScreenState();
}

class _PolicyAcceptanceScreenState extends State<PolicyAcceptanceScreen> {
  List<PolicyStatusItem> _policies = [];
  final Set<String> _checked = {};
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await widget.consentRepository.getStatus();
      setState(() {
        _policies = status.policies.where((p) => !p.accepted).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load policies. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.consentRepository.acceptPolicies(_checked.toList());
      widget.onComplete();
    } catch (e) {
      setState(() {
        _error = 'Failed to accept policies. Please try again.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allChecked =
        _policies.isNotEmpty && _policies.every((p) => _checked.contains(p.type));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Acceptance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Text(
                      _error!,
                      key: const Key('policy-acceptance-error'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  const Text(
                    'Please review and accept the following policies to continue:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ..._policies.map((policy) => CheckboxListTile(
                        key: Key('policy-acceptance-item-${policy.type}'),
                        title: Text(policy.title),
                        subtitle: Text('Version ${policy.version}'),
                        value: _checked.contains(policy.type),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _checked.add(policy.type);
                            } else {
                              _checked.remove(policy.type);
                            }
                          });
                        },
                      )),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('policy-acceptance-submit'),
                    onPressed: (allChecked && !_submitting) ? _submit : null,
                    child: const Text('Accept & Continue'),
                  ),
                ],
              ),
      ),
    );
  }
}
