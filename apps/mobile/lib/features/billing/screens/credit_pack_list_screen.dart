import 'dart:async';

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/api_client.dart';
import '../../../core/feedback/incident_banner.dart';
import '../../../core/feedback/status_messenger.dart';
import '../../incidents/incident_repository.dart';
import '../billing_repository.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

class CreditPackListScreen extends StatefulWidget {
  const CreditPackListScreen({
    super.key,
    required this.billingRepository,
    required this.onBack,
    required this.onPurchaseComplete,
    required this.supportRepository,
    this.incidentStatus,
  });

  final BillingRepository billingRepository;
  final VoidCallback onBack;
  final VoidCallback onPurchaseComplete;
  final SupportRepository supportRepository;
  final PublicIncidentStatus? incidentStatus;

  @override
  State<CreditPackListScreen> createState() => _CreditPackListScreenState();
}

class _CreditPackListScreenState extends State<CreditPackListScreen> {
  List<CreditPack>? _packs;
  List<BillingOrderStatusItem> _recentOrders = const [];
  bool _loading = true;
  bool _refreshingStatuses = false;
  String? _error;
  String? _purchasingPackId;
  String? _statusBannerMessage;
  SupportRequestContext? _supportContext;
  String? _supportErrorMessage;
  String? _activeOrderId;
  late final Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPacks();
    unawaited(_refreshOrderStatuses());
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
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.billingEntitlement,
          );
          _supportErrorMessage = _error;
        });
      }
    }
  }

  Future<void> _startPurchase(CreditPack pack, {String? promoCode}) async {
    if (_purchasingPackId != null) return;
    if (_latestPendingOrder != null) {
      setState(() {
        _statusBannerMessage =
            'A payment is pending capture. Refresh status before starting another checkout.';
      });
      return;
    }

    setState(() => _purchasingPackId = pack.id);
    try {
      final order = await widget.billingRepository.createOrder(
        pack.id,
        promoCode: promoCode,
      );
      _activeOrderId = order.orderId;

      if (!order.paymentRequired) {
        await _refreshOrderStatuses();
        if (mounted) {
          setState(() {
            _purchasingPackId = null;
            _statusBannerMessage = 'Credits were applied successfully.';
          });
          StatusMessenger.showSuccess(context, 'Credits added!');
          widget.onPurchaseComplete();
        }
        return;
      }

      if (order.razorpayKeyId == null || order.razorpayOrderId == null) {
        throw StateError('Checkout requires provider order details.');
      }

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
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.billingCheckout,
        );
        _supportErrorMessage = 'Failed to create order. Please try again.';
        StatusMessenger.showError(
          context,
          'Failed to create order. Please try again.',
          actionLabel: 'Need help?',
          onAction: _openSupportSheet,
        );
      }
    }
  }

  Future<void> _refreshOrderStatuses() async {
    if (_refreshingStatuses) return;
    setState(() {
      _refreshingStatuses = true;
    });
    try {
      final orders = await widget.billingRepository.listRecentOrders();
      if (mounted) {
        setState(() {
          _recentOrders = orders;
          if (_latestPendingOrder == null && _statusBannerMessage != null) {
            _statusBannerMessage = null;
          }
        });
      }
    } catch (_) {
      // Keep UI functional even if status polling fails.
    } finally {
      if (mounted) {
        setState(() {
          _refreshingStatuses = false;
        });
      }
    }
  }

  Future<BillingOrderStatusItem?> _pollOrderStatus(String orderId) async {
    const maxAttempts = 8;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final order = await widget.billingRepository.getOrderStatus(orderId);
      if (!mounted) return order;

      final knownOrderIndex = _recentOrders.indexWhere((item) => item.id == order.id);
      setState(() {
        if (knownOrderIndex >= 0) {
          _recentOrders = [
            ..._recentOrders.sublist(0, knownOrderIndex),
            order,
            ..._recentOrders.sublist(knownOrderIndex + 1),
          ];
        } else {
          _recentOrders = [order, ..._recentOrders].take(5).toList();
        }
      });

      if (!order.isAwaitingCapture) {
        return order;
      }

      await Future<void>.delayed(const Duration(seconds: 2));
    }

    return null;
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
      final verification = await widget.billingRepository.verifyPayment(
        response.orderId ?? '',
        response.paymentId ?? '',
        response.signature ?? '',
      );
      final orderId = _activeOrderId;
      await _refreshOrderStatuses();
      if (mounted) {
        if (verification.orderStatus == BillingOrderStatus.reconciled) {
          StatusMessenger.showSuccess(context, 'Credits added!');
          widget.onPurchaseComplete();
        } else if (orderId != null) {
          final polled = await _pollOrderStatus(orderId);
          await _refreshOrderStatuses();
          if (!mounted) return;
          if (polled?.isReconciled ?? false) {
            StatusMessenger.showSuccess(context, 'Credits added!');
            widget.onPurchaseComplete();
          } else if (polled?.needsReview ?? false) {
            setState(() {
              _statusBannerMessage =
                  polled?.reviewReason ??
                  'This order was flagged for review before credits could be added.';
            });
            StatusMessenger.showWarning(
              context,
              'Payment received, but this order is pending review.',
              duration: const Duration(seconds: 5),
            );
          } else if (polled?.canRetry ?? false) {
            setState(() {
              _statusBannerMessage =
                  polled?.failureReason ??
                  'Payment failed during reconciliation. You can retry safely.';
            });
            StatusMessenger.showWarning(
              context,
              'Payment failed during reconciliation.',
            );
          } else {
            setState(() {
              _statusBannerMessage =
                  'Payment received. Awaiting server reconciliation before credits are added.';
            });
            StatusMessenger.showWarning(
              context,
              'Payment confirmed. Server reconciliation is still pending.',
              duration: const Duration(seconds: 5),
            );
          }
        } else {
          setState(() {
            _statusBannerMessage =
                'Payment received. Awaiting server reconciliation before credits are added.';
          });
          StatusMessenger.showWarning(
            context,
            'Payment verified. Reconciliation is pending, please refresh shortly.',
          );
        }
      }
    } catch (e) {
      await _refreshOrderStatuses();
      if (mounted) {
        StatusMessenger.showWarning(
          context,
          'Payment received but verification is still pending. Please refresh status.',
          duration: const Duration(seconds: 5),
        );
      }
    } finally {
      _activeOrderId = null;
      if (mounted) setState(() => _purchasingPackId = null);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() {
        _purchasingPackId = null;
        _statusBannerMessage =
            'Payment failed. You can retry checkout when ready.';
      });
      unawaited(_refreshOrderStatuses());
      _supportContext = buildSupportRequestContext(
        actionType: SupportActionType.billingCheckout,
      );
      _supportErrorMessage = 'Payment failed. Try again.';
      StatusMessenger.showError(
        context,
        'Payment failed. Try again.',
        actionLabel: 'Need help?',
        onAction: _openSupportSheet,
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selected — Razorpay handles the flow
  }

  BillingOrderStatusItem? get _latestPendingOrder {
    for (final order in _recentOrders) {
      if (order.isAwaitingCapture) {
        return order;
      }
    }
    return null;
  }

  BillingOrderStatusItem? get _latestFailedOrder {
    for (final order in _recentOrders) {
      if (order.canRetry) {
        return order;
      }
    }
    return null;
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
            if (_supportContext != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _openSupportSheet,
                child: const Text('Need help?'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openSupportSheet() {
    final supportContext = _supportContext;
    if (supportContext == null) return;
    showSupportRequestSheet(
      context: context,
      supportRepository: widget.supportRepository,
      supportContext: supportContext,
      errorMessage: _supportErrorMessage,
    );
  }

  Widget _buildPackList(ThemeData theme) {
    final packs = _packs ?? [];
    if (packs.isEmpty) {
      return const Center(
        child: Text('No credit packs available at this time.'),
      );
    }

    final incident = widget.incidentStatus;
    final showIncidentBanner = incident != null &&
        incident.isActive &&
        incident.affectsSurface('mobile_app');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showIncidentBanner) ...[
          IncidentBanner(incident: incident),
          const SizedBox(height: 16),
        ],
        if (_latestPendingOrder != null ||
            _latestFailedOrder != null ||
            _statusBannerMessage != null)
          _buildStatusBanner(theme),
        ...packs.map((pack) => _buildPackCard(theme, pack)),
      ],
    );
  }

  Widget _buildPackCard(ThemeData theme, CreditPack pack) {
    final isPurchasing = _purchasingPackId == pack.id;
    final isDisabled = _purchasingPackId != null || _latestPendingOrder != null;

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

  Widget _buildStatusBanner(ThemeData theme) {
    final pending = _latestPendingOrder;
    final failed = _latestFailedOrder;
    final isPending = pending != null;
    final heading = isPending ? 'Awaiting capture' : 'Last payment failed';
    final description =
        _statusBannerMessage ??
        (isPending
            ? 'Order ${_shortOrderId(pending.razorpayOrderId ?? pending.id)} is waiting for reconciliation. Buying is paused until status is clear.'
            : failed?.failureReason ?? 'You can retry checkout safely.');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isPending
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPending)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    heading,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _refreshingStatuses ? null : _refreshOrderStatuses,
                  child: const Text('Refresh status'),
                ),
                if (!isPending)
                  FilledButton.tonal(
                    onPressed: () {
                      final packs = _packs ?? [];
                      if (packs.isNotEmpty) {
                        _openCheckoutSheet(packs.first);
                      }
                    },
                    child: const Text('Retry payment'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortOrderId(String orderId) {
    if (orderId.length <= 8) return orderId;
    return orderId.substring(0, 8);
  }
}
