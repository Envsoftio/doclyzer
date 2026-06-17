import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api_client.dart';
import '../../../core/feedback/confetti_burst.dart';
import '../../../core/feedback/status_messenger.dart';
import '../referrals_repository.dart';

class ReferralDashboardScreen extends StatefulWidget {
  const ReferralDashboardScreen({
    super.key,
    required this.referralsRepository,
    required this.onBack,
  });

  final ReferralsRepository referralsRepository;
  final VoidCallback onBack;

  @override
  State<ReferralDashboardScreen> createState() =>
      _ReferralDashboardScreenState();
}

class _ReferralDashboardScreenState extends State<ReferralDashboardScreen> {
  final TextEditingController _applyController = TextEditingController();
  ReferralDashboard? _dashboard;
  bool _loading = true;
  bool _applying = false;
  String? _error;
  String? _applyError;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _applyController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dashboard = await widget.referralsRepository.getDashboard();
      if (mounted) {
        setState(() {
          _dashboard = dashboard;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load referrals. Please try again.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _applyReferralCode() async {
    final code = _applyController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _applyError = 'Enter a referral code.';
      });
      return;
    }

    setState(() {
      _applying = true;
      _applyError = null;
    });

    try {
      final result = await widget.referralsRepository.applyReferralCode(code);
      if (!mounted) return;
      _applyController.clear();
      ConfettiBurst.show(context);
      StatusMessenger.showSuccess(
        context,
        result.emailVerificationRequired
            ? 'Referral applied. Bonus unlocks after email verification.'
            : 'Referral applied. Bonus credits are ready.',
      );
      await _loadDashboard();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _applyError = _applyReferralErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _applying = false;
        });
      }
    }
  }

  Future<void> _copyReferralCode() async {
    final dashboard = _dashboard;
    if (dashboard == null) return;
    await Clipboard.setData(ClipboardData(text: dashboard.referralCode));
    if (mounted) {
      StatusMessenger.showSuccess(context, 'Referral code copied.');
    }
  }

  Future<void> _shareReferralLink() async {
    final dashboard = _dashboard;
    if (dashboard == null) return;
    final link =
        dashboard.referralLink ??
        'https://doclyzer.com/register?ref=${dashboard.referralCode}';
    await Share.share(
      'Use my Doclyzer referral code ${dashboard.referralCode}: $link',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals'),
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
              onPressed: _loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final dashboard = _dashboard!;
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCodeCard(theme, dashboard),
          const SizedBox(height: 12),
          _buildApplyCard(theme),
          const SizedBox(height: 12),
          _buildStatsGrid(dashboard),
          const SizedBox(height: 12),
          _buildPolicyCard(theme, dashboard.policySummary),
          const SizedBox(height: 12),
          _buildFriendsCard(theme, dashboard),
        ],
      ),
    );
  }

  Widget _buildCodeCard(ThemeData theme, ReferralDashboard dashboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Referral Code', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            SelectableText(
              dashboard.referralCode,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            if (dashboard.referralLink != null) ...[
              const SizedBox(height: 6),
              SelectableText(
                dashboard.referralLink!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _shareReferralLink,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Share'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _copyReferralCode,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Code'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Have a Code?', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              key: const Key('referral-apply-code'),
              controller: _applyController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Referral code',
                prefixIcon: Icon(Icons.card_giftcard_rounded),
              ),
              onSubmitted: (_) => _applyReferralCode(),
            ),
            if (_applyError != null) ...[
              const SizedBox(height: 8),
              Text(
                _applyError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('referral-apply-submit'),
                onPressed: _applying ? null : _applyReferralCode,
                icon: _applying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_applying ? 'Applying' : 'Apply Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ReferralDashboard dashboard) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _StatTile(
          label: 'Referred',
          value: dashboard.totalReferredCount.toString(),
          icon: Icons.group_rounded,
        ),
        _StatTile(
          label: 'Credits Earned',
          value: dashboard.creditsEarned.toStringAsFixed(2),
          icon: Icons.stars_rounded,
        ),
        _StatTile(
          label: 'Pending',
          value: dashboard.pendingRewards.toString(),
          icon: Icons.hourglass_top_rounded,
        ),
        _StatTile(
          label: 'Blocked',
          value: dashboard.blockedRewards.toString(),
          icon: Icons.block_rounded,
        ),
      ],
    );
  }

  Widget _buildPolicyCard(ThemeData theme, ReferralPolicySummary policy) {
    final milestoneB = policy.milestoneBTiers
        .map((tier) => '+${tier.rewardCredits.toStringAsFixed(0)}')
        .join(' / ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rewards', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _PolicyRow(
              label: 'Invitee bonus',
              value: '+${policy.inviteeBonusCredits.toStringAsFixed(0)}',
            ),
            _PolicyRow(
              label: 'First analysis',
              value: '+${policy.milestoneACredits.toStringAsFixed(0)}',
            ),
            _PolicyRow(label: 'First purchase', value: milestoneB),
            _PolicyRow(
              label: 'Monthly cap',
              value: policy.monthlyRewardCap.toStringAsFixed(0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsCard(ThemeData theme, ReferralDashboard dashboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Referral Progress', style: theme.textTheme.titleMedium),
            if (dashboard.referredFriends.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No referred friends yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else
              ...dashboard.referredFriends.map(
                (friend) => _FriendProgressTile(friend: friend),
              ),
          ],
        ),
      ),
    );
  }

  String _applyReferralErrorMessage(Object error) {
    if (error is ApiException) {
      switch (error.code) {
        case 'REFERRAL_ALREADY_APPLIED':
          return 'A referral code has already been applied to this account.';
        case 'REFERRAL_SELF_REFERRAL':
          return 'You cannot apply your own referral code.';
        case 'REFERRAL_CODE_INVALID':
          return 'Referral code is invalid.';
      }
      return error.message.isNotEmpty
          ? error.message
          : 'Failed to apply referral code.';
    }
    return 'Failed to apply referral code. Please try again.';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendProgressTile extends StatelessWidget {
  const _FriendProgressTile({required this.friend});

  final ReferralFriendProgress friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            friend.inviteeDisplayName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (friend.inviteeEmailMasked != null)
            Text(
              friend.inviteeEmailMasked!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 8),
          ...friend.timeline.map((item) {
            final colors = _statusColors(theme, item.status);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(_statusIcon(item.status), size: 18, color: colors.$2),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.label)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.$1,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _labelStatus(item.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.$2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'blocked':
        return Icons.block_rounded;
      case 'capped':
        return Icons.pause_circle_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Done';
      case 'blocked':
        return 'Blocked';
      case 'capped':
        return 'Capped';
      default:
        return 'Pending';
    }
  }

  (Color, Color) _statusColors(ThemeData theme, String status) {
    switch (status) {
      case 'completed':
        return (
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        );
      case 'blocked':
        return (
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        );
      case 'capped':
        return (
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
        );
      default:
        return (
          theme.colorScheme.surfaceContainerHighest,
          theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}
