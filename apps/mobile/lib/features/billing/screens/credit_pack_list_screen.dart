import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/api_client.dart';
import '../billing_repository.dart';

class CreditPackListScreen extends StatefulWidget {
  const CreditPackListScreen({
    super.key,
    required this.billingRepository,
    required this.onBack,
    required this.onPurchaseComplete,
  });

  final BillingRepository billingRepository;
  final VoidCallback onBack;
  final VoidCallback onPurchaseComplete;

  @override
  State<CreditPackListScreen> createState() => _CreditPackListScreenState();
}

class _CreditPackListScreenState extends State<CreditPackListScreen> {
  List<CreditPack>? _packs;
  bool _loading = true;
  String? _error;
  String? _purchasingPackId;
  late final Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPacks();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadPacks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packs = await widget.billingRepository.listCreditPacks();
      if (mounted) {
        setState(() {
          _packs = packs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load credit packs. Please try again.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _startPurchase(CreditPack pack, {String? promoCode}) async {
    if (_purchasingPackId != null) return;

    setState(() => _purchasingPackId = pack.id);
    try {
      final order = await widget.billingRepository.createOrder(
        pack.id,
        promoCode: promoCode,
      );

      _razorpay.open({
        'key': order.razorpayKeyId,
        'amount': order.amount,
        'currency': order.currency,
        'order_id': order.razorpayOrderId,
        'name': 'Doclyzer',
        'description': 'Credit Pack - ${pack.name}',
      });
    } catch (e) {
      if (mounted) {
        setState(() => _purchasingPackId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create order. Please try again.'),
            action: SnackBarAction(
              label: 'Try again',
              onPressed: () => _openCheckoutSheet(pack),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openCheckoutSheet(CreditPack pack) async {
    final promoController = TextEditingController();
    PromoValidationResult? promoResult;
    String? appliedPromoCode;
    String? promoError;
    bool promoApplying = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          final viewInsets = MediaQuery.of(sheetContext).viewInsets;
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                final theme = Theme.of(context);
                final hasPromo = promoResult != null;
                final finalAmount = hasPromo
                    ? promoResult!.finalAmount
                    : pack.priceInr;
                final discountAmount = hasPromo
                    ? promoResult!.discountAmount
                    : 0.0;

                Future<void> applyPromo() async {
                  final code = promoController.text.trim();
                  if (code.isEmpty) {
                    setModalState(() {
                      promoError = 'Enter a promo code to apply.';
                    });
                    return;
                  }

                  setModalState(() {
                    promoApplying = true;
                    promoError = null;
                  });

                  try {
                    final result = await widget.billingRepository
                        .validatePromoCode(
                          promoCode: code,
                          productType: 'credit_pack',
                          productId: pack.id,
                        );
                    setModalState(() {
                      promoResult = result;
                      appliedPromoCode = code;
                      promoError = null;
                    });
                  } catch (e) {
                    setModalState(() {
                      promoResult = null;
                      appliedPromoCode = null;
                      promoError = _promoErrorMessage(e);
                    });
                  } finally {
                    setModalState(() {
                      promoApplying = false;
                    });
                  }
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Checkout',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pack.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pack.credits} credits',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: promoController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Promo code',
                        hintText: 'Enter promo code',
                      ),
                    ),
                    if (promoError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        promoError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: promoApplying ? null : applyPromo,
                            child: promoApplying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Apply'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (hasPromo)
                          TextButton(
                            onPressed: promoApplying
                                ? null
                                : () {
                                    setModalState(() {
                                      promoResult = null;
                                      appliedPromoCode = null;
                                      promoError = null;
                                      promoController.clear();
                                    });
                                  },
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAmountRow(
                      theme,
                      label: 'Subtotal',
                      value: _formatInr(pack.priceInr),
                    ),
                    if (hasPromo)
                      _buildAmountRow(
                        theme,
                        label: 'Discount',
                        value: '- ${_formatInr(discountAmount)}',
                      ),
                    const SizedBox(height: 4),
                    _buildAmountRow(
                      theme,
                      label: 'Total',
                      value: _formatInr(finalAmount),
                      isEmphasis: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: promoApplying
                            ? null
                            : () async {
                                Navigator.of(context).pop();
                                await _startPurchase(
                                  pack,
                                  promoCode: promoResult != null
                                      ? appliedPromoCode
                                      : null,
                                );
                              },
                        child: const Text('Pay'),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    } finally {
      promoController.dispose();
    }
  }

  String _promoErrorMessage(Object error) {
    if (error is ApiException) {
      switch (error.code) {
        case 'BILLING_PROMO_NOT_FOUND':
          return 'Promo code not found.';
        case 'BILLING_PROMO_INACTIVE':
          return 'Promo code is inactive.';
        case 'BILLING_PROMO_EXPIRED':
          return 'Promo code has expired.';
        case 'BILLING_PROMO_NOT_APPLICABLE':
          return 'Promo code is not applicable to this pack.';
        case 'BILLING_PROMO_CAP_REACHED':
          return 'Promo code usage limit reached.';
        case 'BILLING_PROMO_USER_CAP_REACHED':
          return 'You have already used this promo code.';
      }
    }
    return 'Failed to apply promo code. Please try again.';
  }

  Widget _buildAmountRow(
    ThemeData theme, {
    required String label,
    required String value,
    bool isEmphasis = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isEmphasis
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: isEmphasis
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  String _formatInr(double amount) => '\u20B9${amount.toStringAsFixed(2)}';

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await widget.billingRepository.verifyPayment(
        response.orderId ?? '',
        response.paymentId ?? '',
        response.signature ?? '',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credits added!'),
            duration: Duration(seconds: 3),
          ),
        );
        widget.onPurchaseComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment received but verification failed. Credits will be added shortly.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
        widget.onPurchaseComplete();
      }
    } finally {
      if (mounted) setState(() => _purchasingPackId = null);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _purchasingPackId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed. Try again.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selected — Razorpay handles the flow
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Credits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError(theme)
            : _buildPackList(theme),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _loadPacks,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackList(ThemeData theme) {
    final packs = _packs ?? [];
    if (packs.isEmpty) {
      return const Center(
        child: Text('No credit packs available at this time.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packs.length,
      itemBuilder: (context, index) => _buildPackCard(theme, packs[index]),
    );
  }

  Widget _buildPackCard(ThemeData theme, CreditPack pack) {
    final isPurchasing = _purchasingPackId == pack.id;
    final isDisabled = _purchasingPackId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pack.credits} credits',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\u20B9${pack.priceInr.toStringAsFixed(0)} / \$${pack.priceUsd.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: isDisabled ? null : () => _openCheckoutSheet(pack),
              child: isPurchasing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
