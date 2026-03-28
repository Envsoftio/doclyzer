import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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

  Future<void> _buyPack(CreditPack pack) async {
    if (_purchasingPackId != null) return;

    setState(() => _purchasingPackId = pack.id);
    try {
      final order = await widget.billingRepository.createOrder(pack.id);

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
              onPressed: () => _buyPack(pack),
            ),
          ),
        );
      }
    }
  }

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
            content: Text('Payment received but verification failed. Credits will be added shortly.'),
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
              onPressed: isDisabled ? null : () => _buyPack(pack),
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
