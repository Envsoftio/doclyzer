import 'consent_repository.dart';

class InMemoryConsentRepository implements ConsentRepository {
  InMemoryConsentRepository({bool hasPending = true})
      : _termsAccepted = !hasPending,
        _privacyAccepted = !hasPending;

  bool _termsAccepted;
  bool _privacyAccepted;
  DateTime? _termsAcceptedAt;
  DateTime? _privacyAcceptedAt;

  @override
  Future<ConsentStatus> getStatus() async {
    return ConsentStatus(
      policies: [
        PolicyStatusItem(
          type: 'terms',
          version: '1.0.0',
          title: 'Terms of Service',
          url: '/legal/terms',
          accepted: _termsAccepted,
          acceptedAt: _termsAcceptedAt,
        ),
        PolicyStatusItem(
          type: 'privacy',
          version: '1.0.0',
          title: 'Privacy Policy',
          url: '/legal/privacy',
          accepted: _privacyAccepted,
          acceptedAt: _privacyAcceptedAt,
        ),
      ],
      hasPending: !_termsAccepted || !_privacyAccepted,
    );
  }

  @override
  Future<ConsentStatus> acceptPolicies(List<String> policyTypes) async {
    final now = DateTime.now();
    if (policyTypes.contains('terms')) {
      _termsAccepted = true;
      _termsAcceptedAt = now;
    }
    if (policyTypes.contains('privacy')) {
      _privacyAccepted = true;
      _privacyAcceptedAt = now;
    }
    return getStatus();
  }
}
