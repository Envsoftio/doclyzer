import '../../core/api_client.dart';
import 'referrals_repository.dart';

class ApiReferralsRepository implements ReferralsRepository {
  ApiReferralsRepository(this._client);

  final ApiClient _client;

  @override
  Future<ReferralDashboard> getDashboard() async {
    final data = await _client.get('v1/referrals/me');
    final json = data['data'] as Map<String, dynamic>;
    return _dashboardFromJson(json);
  }

  @override
  Future<ApplyReferralResult> applyReferralCode(String referralCode) async {
    final data = await _client.post(
      'v1/referrals/apply',
      body: {'referralCode': referralCode.trim().toUpperCase()},
    );
    final json = data['data'] as Map<String, dynamic>;
    return ApplyReferralResult(
      referralLogId: json['referralLogId'] as String,
      appliedReferralCode: json['appliedReferralCode'] as String,
      inviteeBonusStatus: json['inviteeBonusStatus'] as String,
      inviteeBonusCredits: (json['inviteeBonusCredits'] as num).toDouble(),
      emailVerificationRequired:
          json['emailVerificationRequired'] as bool? ?? true,
    );
  }

  ReferralDashboard _dashboardFromJson(Map<String, dynamic> json) {
    final policyJson = json['policySummary'] as Map<String, dynamic>;
    final friendsJson = json['referredFriends'] as List<dynamic>? ?? const [];
    return ReferralDashboard(
      referralCode: json['referralCode'] as String,
      referralLink: json['referralLink'] as String?,
      totalReferredCount: json['totalReferredCount'] as int,
      creditsEarned: (json['creditsEarned'] as num).toDouble(),
      pendingRewards: json['pendingRewards'] as int,
      blockedRewards: json['blockedRewards'] as int,
      policySummary: ReferralPolicySummary(
        inviteeBonusCredits: (policyJson['inviteeBonusCredits'] as num)
            .toDouble(),
        milestoneACredits: (policyJson['milestoneACredits'] as num).toDouble(),
        milestoneBTiers:
            ((policyJson['milestoneBTiers'] as List<dynamic>?) ?? const []).map(
              (item) {
                final tier = item as Map<String, dynamic>;
                return ReferralPolicyTier(
                  label: tier['label'] as String,
                  thresholdAmount: (tier['thresholdAmount'] as num).toDouble(),
                  rewardCredits: (tier['rewardCredits'] as num).toDouble(),
                );
              },
            ).toList(),
        monthlyRewardCap: (policyJson['monthlyRewardCap'] as num).toDouble(),
        zeroAmountOrderEligible:
            policyJson['zeroAmountOrderEligible'] as bool? ?? false,
      ),
      referredFriends: friendsJson.map((item) {
        final friend = item as Map<String, dynamic>;
        final timelineJson = friend['timeline'] as List<dynamic>? ?? const [];
        return ReferralFriendProgress(
          referralLogId: friend['referralLogId'] as String,
          inviteeDisplayName: friend['inviteeDisplayName'] as String,
          inviteeEmailMasked: friend['inviteeEmailMasked'] as String?,
          reviewStatus: friend['reviewStatus'] as String,
          inviteeBonusStatus: friend['inviteeBonusStatus'] as String,
          milestoneAStatus: friend['milestoneAStatus'] as String,
          milestoneBStatus: friend['milestoneBStatus'] as String,
          blockedReasonCode: friend['blockedReasonCode'] as String?,
          createdAt: DateTime.parse(friend['createdAt'] as String),
          timeline: timelineJson.map((raw) {
            final timeline = raw as Map<String, dynamic>;
            final occurredAt = timeline['occurredAt'] as String?;
            return ReferralTimelineItem(
              key: timeline['key'] as String,
              label: timeline['label'] as String,
              status: timeline['status'] as String,
              occurredAt: occurredAt != null
                  ? DateTime.parse(occurredAt)
                  : null,
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
