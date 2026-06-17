class ReferralPolicyTier {
  const ReferralPolicyTier({
    required this.label,
    required this.thresholdAmount,
    required this.rewardCredits,
  });

  final String label;
  final double thresholdAmount;
  final double rewardCredits;
}

class ReferralPolicySummary {
  const ReferralPolicySummary({
    required this.inviteeBonusCredits,
    required this.milestoneACredits,
    required this.milestoneBTiers,
    required this.monthlyRewardCap,
    required this.zeroAmountOrderEligible,
  });

  final double inviteeBonusCredits;
  final double milestoneACredits;
  final List<ReferralPolicyTier> milestoneBTiers;
  final double monthlyRewardCap;
  final bool zeroAmountOrderEligible;
}

class ReferralTimelineItem {
  const ReferralTimelineItem({
    required this.key,
    required this.label,
    required this.status,
    required this.occurredAt,
  });

  final String key;
  final String label;
  final String status;
  final DateTime? occurredAt;
}

class ReferralFriendProgress {
  const ReferralFriendProgress({
    required this.referralLogId,
    required this.inviteeDisplayName,
    required this.inviteeEmailMasked,
    required this.reviewStatus,
    required this.inviteeBonusStatus,
    required this.milestoneAStatus,
    required this.milestoneBStatus,
    required this.blockedReasonCode,
    required this.createdAt,
    required this.timeline,
  });

  final String referralLogId;
  final String inviteeDisplayName;
  final String? inviteeEmailMasked;
  final String reviewStatus;
  final String inviteeBonusStatus;
  final String milestoneAStatus;
  final String milestoneBStatus;
  final String? blockedReasonCode;
  final DateTime createdAt;
  final List<ReferralTimelineItem> timeline;
}

class ReferralDashboard {
  const ReferralDashboard({
    required this.referralCode,
    required this.referralLink,
    required this.totalReferredCount,
    required this.creditsEarned,
    required this.pendingRewards,
    required this.blockedRewards,
    required this.policySummary,
    required this.referredFriends,
  });

  final String referralCode;
  final String? referralLink;
  final int totalReferredCount;
  final double creditsEarned;
  final int pendingRewards;
  final int blockedRewards;
  final ReferralPolicySummary policySummary;
  final List<ReferralFriendProgress> referredFriends;
}

class ApplyReferralResult {
  const ApplyReferralResult({
    required this.referralLogId,
    required this.appliedReferralCode,
    required this.inviteeBonusStatus,
    required this.inviteeBonusCredits,
    required this.emailVerificationRequired,
  });

  final String referralLogId;
  final String appliedReferralCode;
  final String inviteeBonusStatus;
  final double inviteeBonusCredits;
  final bool emailVerificationRequired;
}

abstract class ReferralsRepository {
  Future<ReferralDashboard> getDashboard();
  Future<ApplyReferralResult> applyReferralCode(String referralCode);
}
