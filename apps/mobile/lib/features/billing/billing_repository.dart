class EntitlementLimits {
  const EntitlementLimits({
    required this.maxProfiles,
    required this.maxReports,
    required this.maxShareLinks,
    required this.aiChatEnabled,
  });

  final int maxProfiles;
  final int maxReports;
  final int maxShareLinks;
  final bool aiChatEnabled;
}

class EntitlementSummary {
  const EntitlementSummary({
    required this.planName,
    required this.tier,
    required this.creditBalance,
    required this.status,
    required this.limits,
    required this.activatedAt,
    this.expiresAt,
  });

  final String planName;
  final String tier;
  final double creditBalance;
  final String status;
  final EntitlementLimits limits;
  final DateTime activatedAt;
  final DateTime? expiresAt;

  bool get isFreeTier => tier == 'free';
  bool get hasCredits => creditBalance > 0;
  bool get showUpgradeCta => isFreeTier || !hasCredits;
}

class CreditPack {
  const CreditPack({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceInr,
    required this.priceUsd,
  });

  final String id;
  final String name;
  final int credits;
  final double priceInr;
  final double priceUsd;
}

class CreateOrderResult {
  const CreateOrderResult({
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.razorpayKeyId,
  });

  final String orderId;
  final String razorpayOrderId;
  final int amount;
  final String currency;
  final String razorpayKeyId;
}

class PromoValidationResult {
  const PromoValidationResult({
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
    required this.promoCodeId,
  });

  final double discountAmount;
  final double finalAmount;
  final String currency;
  final String promoCodeId;
}

class VerifyPaymentResult {
  const VerifyPaymentResult({
    required this.creditsAdded,
    required this.orderStatus,
    required this.entitlementSummary,
  });

  final int creditsAdded;
  final BillingOrderStatus orderStatus;
  final EntitlementSummary entitlementSummary;
}

enum BillingOrderStatus { pending, paid, reconciled, failed }

class BillingOrderStatusItem {
  const BillingOrderStatusItem({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.finalAmount,
    required this.currency,
    required this.credited,
    required this.razorpayOrderId,
    required this.updatedAt,
    this.failureReason,
  });

  final String id;
  final BillingOrderStatus status;
  final String statusLabel;
  final double finalAmount;
  final String currency;
  final bool credited;
  final String razorpayOrderId;
  final DateTime updatedAt;
  final String? failureReason;

  bool get isAwaitingCapture =>
      status == BillingOrderStatus.pending || status == BillingOrderStatus.paid;
  bool get canRetry => status == BillingOrderStatus.failed;
  bool get isReconciled => status == BillingOrderStatus.reconciled;
}

class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.tier,
    required this.limits,
    required this.priceInfo,
    required this.isCurrentPlan,
  });

  final String id;
  final String name;
  final String tier;
  final EntitlementLimits limits;
  final Map<String, dynamic>? priceInfo;
  final bool isCurrentPlan;
}

class CreateSubscriptionResult {
  const CreateSubscriptionResult({
    required this.subscriptionId,
    required this.razorpaySubscriptionId,
    required this.razorpayKeyId,
    required this.planName,
  });

  final String subscriptionId;
  final String razorpaySubscriptionId;
  final String razorpayKeyId;
  final String planName;
}

class VerifySubscriptionResult {
  const VerifySubscriptionResult({
    required this.planName,
    required this.entitlementSummary,
  });

  final String planName;
  final EntitlementSummary entitlementSummary;
}

abstract class BillingRepository {
  Future<EntitlementSummary> getEntitlementSummary();
  Future<List<CreditPack>> listCreditPacks();
  Future<CreateOrderResult> createOrder(
    String creditPackId, {
    String? promoCode,
  });
  Future<VerifyPaymentResult> verifyPayment(
    String razorpayOrderId,
    String razorpayPaymentId,
    String razorpaySignature,
  );
  Future<List<BillingOrderStatusItem>> listRecentOrders({int limit = 5});
  Future<PromoValidationResult> validatePromoCode({
    required String promoCode,
    required String productType,
    required String productId,
  });
  Future<List<Plan>> listPlans();
  Future<CreateSubscriptionResult> createSubscription(String planId);
  Future<VerifySubscriptionResult> verifySubscription(
    String razorpaySubscriptionId,
    String razorpayPaymentId,
    String razorpaySignature,
  );
}
