import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../core/feedback/incident_banner.dart';
import '../../../core/feedback/status_messenger.dart';
import '../../incidents/incident_repository.dart';
import '../billing_repository.dart';
import '../../support/support_models.dart';
import '../../support/support_repository.dart';
import '../../support/support_request_sheet.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({
    super.key,
    required this.billingRepository,
    required this.onBack,
    required this.onSubscribeComplete,
    required this.supportRepository,
    this.incidentStatus,
  });

  final BillingRepository billingRepository;
  final VoidCallback onBack;
  final VoidCallback onSubscribeComplete;
  final SupportRepository supportRepository;
  final PublicIncidentStatus? incidentStatus;

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  List<Plan>? _plans;
  bool _loading = true;
  String? _error;
  String? _subscribingPlanId;
  String? _promoError;
  SupportRequestContext? _supportContext;
  String? _supportErrorMessage;
  final TextEditingController _promoController = TextEditingController();
  late final Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPlans();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await widget.billingRepository.listPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = context.l10n.uiFailedToLoadPlansPleaseTryAgain;
          _loading = false;
          _supportContext = buildSupportRequestContext(
            actionType: SupportActionType.billingEntitlement,
          );
          _supportErrorMessage = _error;
        });
      }
    }
  }

  Future<void> _subscribe(Plan plan) async {
    if (_subscribingPlanId != null) return;

    final description = context.l10n.uiMonthlyPlanDescription(plan.name);
    setState(() => _subscribingPlanId = plan.id);
    try {
      final result = await widget.billingRepository.createSubscription(plan.id);

      _razorpay.open({
        'key': result.razorpayKeyId,
        'subscription_id': result.razorpaySubscriptionId,
        'name': 'Doclyzer',
        'description': description,
      });
    } catch (e) {
      if (mounted) {
        setState(() => _subscribingPlanId = null);
        _supportContext = buildSupportRequestContext(
          actionType: SupportActionType.billingCheckout,
        );
        _supportErrorMessage =
            context.l10n.uiFailedToCreateSubscriptionPleaseTryAgain;
        StatusMessenger.showError(
          context,
          context.l10n.uiFailedToCreateSubscriptionPleaseTryAgain,
          actionLabel: context.l10n.uiNeedHelp,
          onAction: _openSupportSheet,
        );
      }
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await widget.billingRepository.verifySubscription(
        response.orderId ?? '',
        response.paymentId ?? '',
        response.signature ?? '',
      );
      if (mounted) {
        StatusMessenger.showSuccess(context, context.l10n.uiPlanUpgraded);
        widget.onSubscribeComplete();
      }
    } catch (e) {
      if (mounted) {
        StatusMessenger.showWarning(
          context,
          context.l10n.uiPaymentReceivedButVerificationFailedPlanWill,
          duration: const Duration(seconds: 5),
        );
        widget.onSubscribeComplete();
      }
    } finally {
      if (mounted) setState(() => _subscribingPlanId = null);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _subscribingPlanId = null);
      _supportContext = buildSupportRequestContext(
        actionType: SupportActionType.billingCheckout,
      );
      _supportErrorMessage = context.l10n.uiSubscriptionFailedTryAgain;
      StatusMessenger.showError(
        context,
        context.l10n.uiSubscriptionFailedTryAgain,
        actionLabel: context.l10n.uiNeedHelp,
        onAction: _openSupportSheet,
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selected — Razorpay handles the flow
  }

  void _applySubscriptionPromo() {
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _promoError = context.l10n.uiEnterAPromoCodeToApply;
      });
      return;
    }
    setState(() {
      _promoError = context.l10n.uiPromoCodesNotSupportedForSubscriptionsYet;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.uiChooseAPlan),
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
            : _buildPlanList(theme),
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
              onPressed: _loadPlans,
              child: Text(context.l10n.retry),
            ),
            if (_supportContext != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _openSupportSheet,
                child: Text(context.l10n.needHelp),
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

  Widget _buildPlanList(ThemeData theme) {
    final plans = _plans ?? [];
    if (plans.isEmpty) {
      return Center(child: Text(context.l10n.uiNoPlansAvailableAtThisTime));
    }

    final incident = widget.incidentStatus;
    final showIncidentBanner =
        incident != null &&
        incident.isActive &&
        incident.affectsSurface('mobile_app');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showIncidentBanner) ...[
          IncidentBanner(incident: incident),
          const SizedBox(height: 16),
        ],
        _buildPromoSection(theme),
        const SizedBox(height: 16),
        ...plans.map((plan) => _buildPlanCard(theme, plan)),
      ],
    );
  }

  Widget _buildPromoSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.uiHaveAPromoCode,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promoController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: context.l10n.uiPromoCode,
                hintText: context.l10n.uiEnterPromoCode,
              ),
            ),
            if (_promoError != null) ...[
              const SizedBox(height: 6),
              Text(_promoError!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _applySubscriptionPromo,
                child: Text(context.l10n.uiApply),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(ThemeData theme, Plan plan) {
    final isSubscribing = _subscribingPlanId == plan.id;
    final isDisabled = _subscribingPlanId != null || plan.isCurrentPlan;

    final monthlyInr = plan.priceInfo != null
        ? plan.priceInfo!['monthlyInr']
        : null;
    final monthlyUsd = plan.priceInfo != null
        ? plan.priceInfo!['monthlyUsd']
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (plan.isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      context.l10n.uiCURRENTPLAN,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (monthlyInr != null || monthlyUsd != null) ...[
              const SizedBox(height: 8),
              Text(
                '\u20B9${(monthlyInr as num?)?.toStringAsFixed(0) ?? '-'} / \$${(monthlyUsd as num?)?.toStringAsFixed(2) ?? '-'} per month',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildFeatureRow(
              theme,
              Icons.person_outline,
              context.l10n.uiProfiles,
              '${plan.limits.maxProfiles}',
            ),
            _buildFeatureRow(
              theme,
              Icons.description_outlined,
              context.l10n.reports,
              '${plan.limits.maxReports}',
            ),
            _buildFeatureRow(
              theme,
              Icons.link,
              context.l10n.uiShareLinks,
              '${plan.limits.maxShareLinks}',
            ),
            _buildFeatureRow(
              theme,
              Icons.smart_toy_outlined,
              context.l10n.uiAIChat,
              plan.limits.aiChatEnabled
                  ? context.l10n.uiEnabled
                  : context.l10n.uiNotAvailable,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isDisabled ? null : () => _subscribe(plan),
                child: isSubscribing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        plan.isCurrentPlan
                            ? context.l10n.uiCurrentPlan
                            : context.l10n.uiSubscribe,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
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
}
