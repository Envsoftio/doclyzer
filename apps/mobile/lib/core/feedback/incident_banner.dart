import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../features/incidents/incident_repository.dart';

class IncidentBanner extends StatelessWidget {
  const IncidentBanner({
    super.key,
    required this.incident,
    this.surface = 'mobile_app',
  });

  final PublicIncidentStatus? incident;
  final String surface;

  @override
  Widget build(BuildContext context) {
    final activeIncident = incident;
    if (activeIncident == null || !activeIncident.isActive) {
      return const SizedBox.shrink();
    }
    if (!activeIncident.affectsSurface(surface)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCritical = activeIncident.severity == 'critical';

    final backgroundColor = isCritical
        ? colorScheme.errorContainer
        : colorScheme.tertiaryContainer;
    final borderColor = isCritical
        ? colorScheme.error.withOpacity(0.35)
        : colorScheme.tertiary.withOpacity(0.35);
    final titleColor = isCritical
        ? colorScheme.error
        : colorScheme.tertiary;
    final bodyColor = isCritical
        ? colorScheme.onErrorContainer
        : colorScheme.onTertiaryContainer;

    final updatedAt = activeIncident.updatedAt.toLocal();
    final dateLabel = MaterialLocalizations.of(context).formatFullDate(updatedAt);
    final timeLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(updatedAt));

    return Container(
      key: const Key('incident-banner'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCritical
                    ? Icons.report_gmailerrorred_rounded
                    : Icons.warning_amber_rounded,
                color: titleColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  activeIncident.headline,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            activeIncident.message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: bodyColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'What\'s affected: ${activeIncident.whatsAffected}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: bodyColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Last updated: $dateLabel at $timeLabel',
            style: theme.textTheme.labelSmall?.copyWith(
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}
