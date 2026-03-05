class PolicyStatusItem {
  const PolicyStatusItem({
    required this.type,
    required this.version,
    required this.title,
    required this.url,
    required this.accepted,
    this.acceptedAt,
  });

  final String type;
  final String version;
  final String title;
  final String url;
  final bool accepted;
  final DateTime? acceptedAt;
}

class ConsentStatus {
  const ConsentStatus({
    required this.policies,
    required this.hasPending,
  });

  final List<PolicyStatusItem> policies;
  final bool hasPending;
}

abstract class ConsentRepository {
  Future<ConsentStatus> getStatus();

  Future<ConsentStatus> acceptPolicies(List<String> policyTypes);
}
