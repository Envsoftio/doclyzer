import 'package:flutter/material.dart';

import '../../../core/feedback/status_messenger.dart';
import '../billing_repository.dart';

class EntitlementSummaryScreen extends StatefulWidget {
  const EntitlementSummaryScreen({
    super.key,
    required this.billingRepository,
    required this.onBack,
    this.onBuyCredits,
    this.onUpgrade,
  });

  final BillingRepository billingRepository;
  final VoidCallback onBack;
  final VoidCallback? onBuyCredits;
  final VoidCallback? onUpgrade;

  @override
  State<EntitlementSummaryScreen> createState() =>
      _EntitlementSummaryScreenState();
}

class _EntitlementSummaryScreenState extends State<EntitlementSummaryScreen> {
  EntitlementSummary? _summary;
  List<BillingOrderStatusItem> _recentOrders = const [];
  bool _loading = true;
  bool _refreshingOrders = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
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
          _error = 'Failed to load entitlement summary. Please try again.';
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
          'Failed to refresh billing status. Please try again.',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan & Credits'),
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final summary = _summary!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPlanCard(theme, summary),
          const SizedBox(height: 16),
          _buildCreditCard(theme, summary),
          const SizedBox(height: 16),
          _buildLimitsCard(theme, summary),
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
                    'Current Plan',
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
              'Credit Balance',
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
              'Status: ${summary.status}',
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
            Text('Plan Limits', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildLimitRow(
              theme,
              icon: Icons.person_outline,
              label: 'Profiles',
              value: '${limits.maxProfiles}',
            ),
            _buildLimitRow(
              theme,
              icon: Icons.description_outlined,
              label: 'Reports',
              value: '${limits.maxReports}',
            ),
            _buildLimitRow(
              theme,
              icon: Icons.link,
              label: 'Share links',
              value: '${limits.maxShareLinks}',
            ),
            _buildLimitRow(
              theme,
              icon: Icons.smart_toy_outlined,
              label: 'AI Chat',
              value: limits.aiChatEnabled ? 'Enabled' : 'Not available',
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
            child: const Text('Upgrade'),
          ),
        if (summary.isFreeTier) const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: widget.onBuyCredits,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Buy Credits'),
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
                    'Recent Billing Activity',
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
                  label: const Text('Refresh status'),
                ),
              ],
            ),
            if (_recentOrders.isEmpty)
              Text(
                'No recent orders yet.',
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
        ? 'Retry payment'
        : order.isReconciled
        ? 'View receipt'
        : 'Refresh status';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _shortOrderId(order.razorpayOrderId),
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
                  'Receipt download will be available soon.',
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
      case BillingOrderStatus.pending:
      case BillingOrderStatus.paid:
        return (
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
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
    final local = time.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }

  String _buildLastChangeLine(EntitlementSummary summary) {
    final label = summary.lastChangeLabel;
    final changedAt = summary.lastChangeAt;
    if (changedAt == null) {
      return 'Last change: $label';
    }
    return 'Last change: $label · ${_formatLongDateTime(changedAt)}';
  }

  String _formatLongDateTime(DateTime time) {
    final local = time.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}
