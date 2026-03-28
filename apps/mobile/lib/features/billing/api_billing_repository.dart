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
  Future<CreateOrderResult> createOrder(
    String creditPackId, {
    String? promoCode,
  }) async {
    final data = await _client.post(
      'v1/billing/orders',
      body: {
        'creditPackId': creditPackId,
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
      },
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
      orderStatus: _orderStatusFromString(d['orderStatus'] as String),
      entitlementSummary: _summaryFromJson(summaryJson),
    );
  }

  @override
  Future<List<BillingOrderStatusItem>> listRecentOrders({int limit = 5}) async {
    final clampedLimit = limit.clamp(1, 5);
    final data = await _client.get('v1/billing/orders?limit=$clampedLimit');
    final list = data['data'] as List<dynamic>;
    return list.map((item) {
      final json = item as Map<String, dynamic>;
      return BillingOrderStatusItem(
        id: json['id'] as String,
        status: _orderStatusFromString(json['status'] as String),
        statusLabel: json['statusLabel'] as String,
        finalAmount: (json['finalAmount'] as num).toDouble(),
        currency: json['currency'] as String,
        credited: json['credited'] as bool,
        razorpayOrderId: json['razorpayOrderId'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        failureReason: json['failureReason'] as String?,
      );
    }).toList();
  }

  @override
  Future<PromoValidationResult> validatePromoCode({
    required String promoCode,
    required String productType,
    required String productId,
  }) async {
    final data = await _client.post(
      'v1/billing/promo/validate',
      body: {
        'promoCode': promoCode,
        'productType': productType,
        'productId': productId,
      },
    );
    final d = data['data'] as Map<String, dynamic>;
    return PromoValidationResult(
      discountAmount: (d['discountAmount'] as num).toDouble(),
      finalAmount: (d['finalAmount'] as num).toDouble(),
      currency: d['currency'] as String,
      promoCodeId: d['promoCodeId'] as String,
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

  BillingOrderStatus _orderStatusFromString(String status) {
    switch (status) {
      case 'pending':
        return BillingOrderStatus.pending;
      case 'paid':
        return BillingOrderStatus.paid;
      case 'reconciled':
        return BillingOrderStatus.reconciled;
      case 'failed':
        return BillingOrderStatus.failed;
      default:
        return BillingOrderStatus.pending;
    }
  }
}
