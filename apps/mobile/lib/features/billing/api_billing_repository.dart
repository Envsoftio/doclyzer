import '../../core/api_client.dart';
import 'billing_repository.dart';

class ApiBillingRepository implements BillingRepository {
  ApiBillingRepository(this._client);

  final ApiClient _client;

  @override
  Future<EntitlementSummary> getEntitlementSummary() async {
    final data = await _client.get('v1/entitlements/summary');
    final d = data['data'] as Map<String, dynamic>;
    return _summaryFromJson(d);
  }

  @override
  Future<List<CreditPack>> listCreditPacks() async {
    final data = await _client.get('v1/billing/credit-packs');
    final list = data['data'] as List<dynamic>;
    return list.map((item) {
      final json = item as Map<String, dynamic>;
      return CreditPack(
        id: json['id'] as String,
        name: json['name'] as String,
        credits: json['credits'] as int,
        priceInr: (json['priceInr'] as num).toDouble(),
        priceUsd: (json['priceUsd'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<CreateOrderResult> createOrder(String creditPackId) async {
    final data = await _client.post(
      'v1/billing/orders',
      body: {'creditPackId': creditPackId},
    );
    final d = data['data'] as Map<String, dynamic>;
    return CreateOrderResult(
      orderId: d['orderId'] as String,
      razorpayOrderId: d['razorpayOrderId'] as String,
      amount: d['amount'] as int,
      currency: d['currency'] as String,
      razorpayKeyId: d['razorpayKeyId'] as String,
    );
  }

  @override
  Future<VerifyPaymentResult> verifyPayment(
    String razorpayOrderId,
    String razorpayPaymentId,
    String razorpaySignature,
  ) async {
    final data = await _client.post(
      'v1/billing/orders/verify',
      body: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    final d = data['data'] as Map<String, dynamic>;
    final summaryJson = d['entitlementSummary'] as Map<String, dynamic>;
    return VerifyPaymentResult(
      creditsAdded: d['creditsAdded'] as int,
      entitlementSummary: _summaryFromJson(summaryJson),
    );
  }

  @override
  Future<List<Plan>> listPlans() async {
    final data = await _client.get('v1/billing/plans');
    final list = data['data'] as List<dynamic>;
    return list.map((item) {
      final json = item as Map<String, dynamic>;
      final limitsJson = json['limits'] as Map<String, dynamic>;
      return Plan(
        id: json['id'] as String,
        name: json['name'] as String,
        tier: json['tier'] as String,
        limits: EntitlementLimits(
          maxProfiles: limitsJson['maxProfiles'] as int,
          maxReports: limitsJson['maxReports'] as int,
          maxShareLinks: limitsJson['maxShareLinks'] as int,
          aiChatEnabled: limitsJson['aiChatEnabled'] as bool,
        ),
        priceInfo: json['priceInfo'] as Map<String, dynamic>?,
        isCurrentPlan: json['isCurrentPlan'] as bool,
      );
    }).toList();
  }

  @override
  Future<CreateSubscriptionResult> createSubscription(String planId) async {
    final data = await _client.post(
      'v1/billing/subscriptions',
      body: {'planId': planId},
    );
    final d = data['data'] as Map<String, dynamic>;
    return CreateSubscriptionResult(
      subscriptionId: d['subscriptionId'] as String,
      razorpaySubscriptionId: d['razorpaySubscriptionId'] as String,
      razorpayKeyId: d['razorpayKeyId'] as String,
      planName: d['planName'] as String,
    );
  }

  @override
  Future<VerifySubscriptionResult> verifySubscription(
    String razorpaySubscriptionId,
    String razorpayPaymentId,
    String razorpaySignature,
  ) async {
    final data = await _client.post(
      'v1/billing/subscriptions/verify',
      body: {
        'razorpaySubscriptionId': razorpaySubscriptionId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      },
    );
    final d = data['data'] as Map<String, dynamic>;
    final summaryJson = d['entitlementSummary'] as Map<String, dynamic>;
    return VerifySubscriptionResult(
      planName: d['planName'] as String,
      entitlementSummary: _summaryFromJson(summaryJson),
    );
  }

  EntitlementSummary _summaryFromJson(Map<String, dynamic> json) {
    final limitsJson = json['limits'] as Map<String, dynamic>;
    final activatedAt = json['activatedAt'] as String?;
    final expiresAt = json['expiresAt'] as String?;

    return EntitlementSummary(
      planName: json['planName'] as String,
      tier: json['tier'] as String,
      creditBalance: (json['creditBalance'] as num).toDouble(),
      status: json['status'] as String,
      limits: EntitlementLimits(
        maxProfiles: limitsJson['maxProfiles'] as int,
        maxReports: limitsJson['maxReports'] as int,
        maxShareLinks: limitsJson['maxShareLinks'] as int,
        aiChatEnabled: limitsJson['aiChatEnabled'] as bool,
      ),
      activatedAt: activatedAt != null
          ? DateTime.parse(activatedAt)
          : DateTime.now(),
      expiresAt: expiresAt != null ? DateTime.parse(expiresAt) : null,
    );
  }
}
