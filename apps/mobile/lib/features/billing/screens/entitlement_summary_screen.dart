import 'package:flutter/material.dart';

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
  bool _loading = true;
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
      if (mounted) {
        setState(() {
          _summary = summary;
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
                  Text(
                    summary.planName,
                    style: theme.textTheme.headlineSmall,
                  ),
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
            Text(
              'Plan Limits',
              style: theme.textTheme.titleMedium,
            ),
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
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
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
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text('Buy Credits'),
        ),
      ],
    );
  }
}
