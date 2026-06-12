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
