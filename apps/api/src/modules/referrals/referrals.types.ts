export interface ReferralPolicyTier {
  label: string;
  thresholdAmount: number;
  rewardCredits: number;
}

export interface ReferralPolicySnapshot {
  inviteeBonusCredits: number;
  milestoneACredits: number;
  milestoneBTiers: ReferralPolicyTier[];
  monthlyRewardCap: number;
  zeroAmountOrderEligible: boolean;
}

export const DEFAULT_REFERRAL_POLICY: ReferralPolicySnapshot = {
  inviteeBonusCredits: 5,
  milestoneACredits: 5,
  milestoneBTiers: [
    {
      label: 'tier_1',
      thresholdAmount: 0,
      rewardCredits: 10,
    },
    {
      label: 'tier_2',
      thresholdAmount: 499,
      rewardCredits: 20,
    },
    {
      label: 'tier_3',
      thresholdAmount: 999,
      rewardCredits: 30,
    },
  ],
  monthlyRewardCap: 200,
  zeroAmountOrderEligible: false,
};

export interface ReferralPolicySummaryDto {
  inviteeBonusCredits: number;
  milestoneACredits: number;
  milestoneBTiers: ReferralPolicyTier[];
  monthlyRewardCap: number;
  zeroAmountOrderEligible: boolean;
}

export interface ReferralProgressTimelineItemDto {
  key: string;
  label: string;
  status: 'completed' | 'pending' | 'blocked' | 'capped';
  occurredAt: string | null;
}

export interface ReferralFriendProgressDto {
  referralLogId: string;
  inviteeDisplayName: string;
  inviteeEmailMasked: string | null;
  reviewStatus: string;
  inviteeBonusStatus: string;
  milestoneAStatus: string;
  milestoneBStatus: string;
  blockedReasonCode: string | null;
  createdAt: string;
  timeline: ReferralProgressTimelineItemDto[];
}

export interface ReferralDashboardDto {
  referralCode: string;
  referralLink: string | null;
  totalReferredCount: number;
  creditsEarned: number;
  pendingRewards: number;
  blockedRewards: number;
  policySummary: ReferralPolicySummaryDto;
  referredFriends: ReferralFriendProgressDto[];
}
