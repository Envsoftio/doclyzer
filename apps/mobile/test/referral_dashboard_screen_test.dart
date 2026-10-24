import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/referrals/referrals_repository.dart';
import 'package:mobile/features/referrals/screens/referral_dashboard_screen.dart';

class _Referrals extends Fake implements ReferralsRepository {
  String? appliedCode;

  @override
  Future<ReferralDashboard> getDashboard() async => ReferralDashboard(
    referralCode: 'HELLO123',
    referralLink: 'https://doclyzer.com/register?ref=HELLO123',
    totalReferredCount: 1,
    creditsEarned: 12.5,
    pendingRewards: 1,
    blockedRewards: 0,
    policySummary: const ReferralPolicySummary(
      inviteeBonusCredits: 5,
      milestoneACredits: 10,
      milestoneBTiers: [
        ReferralPolicyTier(
          label: 'First tier',
          thresholdAmount: 100,
          rewardCredits: 20,
        ),
      ],
      monthlyRewardCap: 50,
      zeroAmountOrderEligible: false,
    ),
    referredFriends: [
      ReferralFriendProgress(
        referralLogId: '1',
        inviteeDisplayName: 'Alex',
        inviteeEmailMasked: 'a***@example.com',
        reviewStatus: 'pending',
        inviteeBonusStatus: 'completed',
        milestoneAStatus: 'pending',
        milestoneBStatus: 'pending',
        blockedReasonCode: null,
        createdAt: DateTime(2026),
        timeline: [
          const ReferralTimelineItem(
            key: 'joined',
            label: 'Joined Doclyzer',
            status: 'completed',
            occurredAt: null,
          ),
        ],
      ),
    ],
  );

  @override
  Future<ApplyReferralResult> applyReferralCode(String referralCode) async {
    appliedCode = referralCode;
    return const ApplyReferralResult(
      referralLogId: '2',
      appliedReferralCode: 'FRIEND42',
      inviteeBonusStatus: 'pending',
      inviteeBonusCredits: 5,
      emailVerificationRequired: true,
    );
  }
}

void main() {
  testWidgets(
    'referral content and actions fit a narrow screen with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final repository = _Referrals();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: ReferralDashboardScreen(
              referralsRepository: repository,
              onBack: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Invite friends, earn credits'), findsOneWidget);
      expect(find.text('HELLO123'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.byKey(const Key('referral-apply-code')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('referral-apply-code')),
        'FRIEND42',
      );
      await tester.tap(find.byKey(const Key('referral-apply-submit')));
      await tester.pumpAndSettle();
      expect(repository.appliedCode, 'FRIEND42');
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Referral progress'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Alex'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
