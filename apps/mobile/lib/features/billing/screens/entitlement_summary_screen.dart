import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../shared/app_date_format.dart';

import '../../../core/api_client.dart';
import '../../../core/feedback/confetti_burst.dart';
import '../../../core/feedback/incident_banner.dart';
import '../../../core/feedback/status_messenger.dart';
import '../../incidents/incident_repository.dart';
import '../billing_repository.dart';

class EntitlementSummaryScreen extends StatefulWidget {
  const EntitlementSummaryScreen({
    super.key,
    required this.billingRepository,
    required this.onBack,
    this.onBuyCredits,
    this.onUpgrade,
    this.incidentStatus,
  });

  final BillingRepository billingRepository;
  final VoidCallback onBack;
  final VoidCallback? onBuyCredits;
  final VoidCallback? onUpgrade;
  final PublicIncidentStatus? incidentStatus;

  @override
  State<EntitlementSummaryScreen> createState() =>
      _EntitlementSummaryScreenState();
}

class _EntitlementSummaryScreenState extends State<EntitlementSummaryScreen> {
  final TextEditingController _voucherController = TextEditingController();
  EntitlementSummary? _summary;
  List<BillingOrderStatusItem> _recentOrders = const [];
  bool _loading = true;
  bool _refreshingOrders = false;
  bool _redeemingVoucher = false;
  String? _error;
  String? _voucherError;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await widget.billingRepository.getEntitlementSummary();
      final recentOrders = await widget.billingRepository.listRecentOrders();
      if (mounted) {
        setState(() {
          _summary = summary;
          _recentOrders = recentOrders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = context.l10n.uiFailedToLoadEntitlementSummaryPleaseTry;
          _loading = false;
        });
      }
    }
  }

  Future<void> _refreshOrders() async {
    if (_refreshingOrders) return;

    setState(() {
      _refreshingOrders = true;
    });
    try {
      final recentOrders = await widget.billingRepository.listRecentOrders();
      if (mounted) {
        setState(() {
          _recentOrders = recentOrders;
        });
      }
    } catch (_) {
      if (mounted) {
        StatusMessenger.showError(
          context,
          context.l10n.uiFailedToRefreshBillingStatusPleaseTry,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _refreshingOrders = false;
        });
      }
    }
  }

  Future<void> _redeemGiftVoucher() async {
    final code = _voucherController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _voucherError = context.l10n.uiEnterAGiftVoucherCode;
      });
      return;
    }

    setState(() {
      _redeemingVoucher = true;
      _voucherError = null;
    });

    try {
      final result = await widget.billingRepository.redeemGiftVoucher(code);
      if (!mounted) return;
      setState(() {
        _summary = result.entitlementSummary;
        _voucherController.clear();
      });
      ConfettiBurst.show(context);
      StatusMessenger.showSuccess(
        context,
        context.l10n.uiGiftVoucherApplied(
          result.creditsAdded.toStringAsFixed(2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _voucherError = _giftVoucherErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _redeemingVoucher = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.planCredits),
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
            : _buildContent(theme),
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
              onPressed: _loadSummary,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final summary = _summary!;
    final incident = widget.incidentStatus;
    final showIncidentBanner =
        incident != null &&
        incident.isActive &&
        incident.affectsSurface('mobile_app');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showIncidentBanner) ...[
            IncidentBanner(incident: incident),
            const SizedBox(height: 16),
          ],
          _buildPlanCard(theme, summary),
          const SizedBox(height: 16),
          _buildCreditCard(theme, summary),
          const SizedBox(height: 16),
          _buildLimitsCard(theme, summary),
          const SizedBox(height: 16),
          _buildGiftVoucherCard(theme),
          const SizedBox(height: 16),
          _buildRecentOrdersCard(theme),
          if (summary.showUpgradeCta) ...[
            const SizedBox(height: 24),
            _buildUpgradeCta(theme, summary),
          ],
        ],
      ),
    );
  }

  Widget _buildGiftVoucherCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.uiGiftVoucher,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.uiRedeemAGiftVoucherAndAddCredits,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('gift-voucher-code'),
              controller: _voucherController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _redeemGiftVoucher(),
              decoration: InputDecoration(
                labelText: context.l10n.uiVoucherCode,
                prefixIcon: Icon(Icons.card_giftcard_rounded),
              ),
            ),
            if (_voucherError != null) ...[
              const SizedBox(height: 8),
              Text(
                _voucherError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('gift-voucher-redeem'),
                onPressed: _redeemingVoucher ? null : _redeemGiftVoucher,
                icon: _redeemingVoucher
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.redeem_rounded),
                label: Text(
                  _redeemingVoucher
                      ? context.l10n.uiApplying
                      : context.l10n.uiApplyVoucher,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(ThemeData theme, EntitlementSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.uiCurrentPlan,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(summary.planName, style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            _buildTierBadge(theme, summary.tier),
          ],
        ),
      ),
    );
  }

  Widget _buildTierBadge(ThemeData theme, String tier) {
    final isFreeTier = tier == 'free';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFreeTier
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tier.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFreeTier
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCreditCard(ThemeData theme, EntitlementSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.uiCreditBalance,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              summary.creditBalance.toStringAsFixed(2),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: summary.hasCredits
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.uiStatusWithValue(switch (summary.status
                  .toLowerCase()) {
                'active' => context.l10n.active,
                'inactive' => context.l10n.uiInactive,
                'pending' => context.l10n.uiPending,
                'failed' => context.l10n.uiFailed,
                _ => summary.status,
              }),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _buildLastChangeLine(summary),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitsCard(ThemeData theme, EntitlementSummary summary) {
    final limits = summary.limits;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.uiPlanLimits, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildLimitRow(
              theme,
              icon: Icons.person_outline,
              label: context.l10n.uiProfiles,
              value: '${limits.maxProfiles}',
            ),
            _buildLimitRow(
              theme,
              icon: Icons.description_outlined,
              label: context.l10n.uiReports,
              value: '${limits.maxReports}',
            ),
            _buildLimitRow(
              theme,
              icon: Icons.link,
              label: context.l10n.uiShareLinks,
              value: '${limits.maxShareLinks}',
            ),
            _buildLimitRow(
              theme,
              icon: Icons.smart_toy_outlined,
              label: context.l10n.uiAIChat,
              value: limits.aiChatEnabled
                  ? context.l10n.uiEnabled
                  : context.l10n.uiNotAvailable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeCta(ThemeData theme, EntitlementSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary.isFreeTier)
          FilledButton(
            onPressed: widget.onUpgrade,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(context.l10n.upgrade),
          ),
        if (summary.isFreeTier) const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: widget.onBuyCredits,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(context.l10n.uiBuyCredits),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.uiRecentBillingActivity,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _refreshingOrders ? null : _refreshOrders,
                  icon: _refreshingOrders
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(context.l10n.uiRefreshStatus),
                ),
              ],
            ),
            if (_recentOrders.isEmpty)
              Text(
                context.l10n.uiNoRecentOrdersYet,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ..._recentOrders.take(3).map((order) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildOrderRow(theme, order),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(ThemeData theme, BillingOrderStatusItem order) {
    final chipColors = _orderChipColors(theme, order.status);
    final actionLabel = order.canRetry
        ? context.l10n.uiRetryPayment
        : order.isReconciled
        ? context.l10n.uiViewReceipt
        : context.l10n.uiRefreshStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _shortOrderId(order.razorpayOrderId ?? order.id),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: chipColors.$1,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                order.statusLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: chipColors.$2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${order.currency} ${order.finalAmount.toStringAsFixed(2)} • ${_formatTime(order.updatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (order.failureReason != null && order.failureReason!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            order.failureReason!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ] else if (order.reviewReason != null &&
            order.reviewReason!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            order.reviewReason!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.tertiary,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              if (order.canRetry) {
                widget.onBuyCredits?.call();
                return;
              }
              if (order.isReconciled) {
                StatusMessenger.showInfo(
                  context,
                  context.l10n.uiReceiptDownloadWillBeAvailableSoon,
                );
                return;
              }
              _refreshOrders();
            },
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }

  (Color, Color) _orderChipColors(ThemeData theme, BillingOrderStatus status) {
    switch (status) {
      case BillingOrderStatus.created:
      case BillingOrderStatus.paymentPending:
      case BillingOrderStatus.clientPurchaseConfirmed:
      case BillingOrderStatus.webhookPending:
        return (
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
        );
      case BillingOrderStatus.pendingReview:
        return (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
        );
      case BillingOrderStatus.failed:
        return (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        );
      case BillingOrderStatus.reconciled:
        return (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        );
    }
  }

  String _shortOrderId(String orderId) {
    if (orderId.length <= 8) return orderId;
    return '${orderId.substring(0, 8)}…';
  }

  String _formatTime(DateTime time) {
    return AppDateFormat.dateTimeWithRelative(time);
  }

  String _buildLastChangeLine(EntitlementSummary summary) {
    final label = switch (summary.lastChangeReason) {
      'initial_provision' => context.l10n.uiInitialEntitlement,
      'credit_pack_purchase' => context.l10n.uiCreditPackPurchase,
      'subscription_upgrade' => context.l10n.uiSubscriptionUpgrade,
      'plan_downgrade' => context.l10n.uiPlanDowngrade,
      'admin_adjustment' => context.l10n.uiAdminAdjustment,
      'system_reconciliation' => context.l10n.uiSystemReconciliation,
      'referral_invitee_bonus' => context.l10n.uiReferralInviteBonus,
      'referral_milestone_a' => context.l10n.uiReferralAnalysisMilestone,
      'referral_milestone_b' => context.l10n.uiReferralPurchaseMilestone,
      'promo_free_credit_pack' => context.l10n.uiFreePromoCreditPack,
      'gift_voucher_redeem' => context.l10n.uiGiftVoucherRedeemed,
      _ => context.l10n.uiNotYetChanged,
    };
    final changedAt = summary.lastChangeAt;
    if (changedAt == null) {
      return context.l10n.uiLastChange(label);
    }
    return context.l10n.uiLastChangeAt(label, _formatLongDateTime(changedAt));
  }

  String _formatLongDateTime(DateTime time) {
    return AppDateFormat.dateTimeWithRelative(time);
  }

  String _giftVoucherErrorMessage(Object error) {
    if (error is ApiException) {
      switch (error.code) {
        case 'GIFT_VOUCHER_INVALID':
          return context.l10n.uiGiftVoucherIsInvalidOrAlreadyRedeemed;
        case 'GIFT_VOUCHER_ALREADY_REDEEMED':
          return context.l10n.uiGiftVoucherHasAlreadyBeenRedeemed;
        case 'GIFT_VOUCHER_VOIDED':
          return context.l10n.uiGiftVoucherHasBeenVoided;
        case 'GIFT_VOUCHER_EXPIRED':
          return context.l10n.uiGiftVoucherHasExpired;
        case 'GIFT_VOUCHER_CODE_REQUIRED':
          return context.l10n.uiEnterAGiftVoucherCode;
      }
      return context.l10n.uiUnableToRedeemThisGiftVoucher;
    }
    return context.l10n.uiUnableToRedeemThisGiftVoucherPlease;
  }
}
