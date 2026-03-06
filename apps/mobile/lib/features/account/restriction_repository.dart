class RestrictionStatus {
  const RestrictionStatus({
    required this.isRestricted,
    this.rationale,
    this.nextSteps,
    this.restrictedActions,
  });

  final bool isRestricted;
  final String? rationale;
  final String? nextSteps;
  final List<String>? restrictedActions;
}

abstract class RestrictionRepository {
  Future<RestrictionStatus> getStatus();
}
