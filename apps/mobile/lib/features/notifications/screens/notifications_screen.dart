import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';
import '../../../shared/app_date_format.dart';
import '../notifications_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.repository,
    required this.onBack,
    required this.onManagePreferences,
    this.onOpenRelated,
  });

  final NotificationsRepository repository;
  final VoidCallback onBack;
  final VoidCallback onManagePreferences;
  final Future<void> Function(InboxNotification notification)? onOpenRelated;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<InboxNotification>? _items;
  final Set<String> _opened = {};
  bool _unreadOnly = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await widget.repository.getInbox();
      if (mounted) {
        setState(() {
          _items = items;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = context.l10n.uiUnableToLoadNotificationsTryAgainWhen,
        );
      }
    }
  }

  Future<void> _open(InboxNotification item) async {
    if (!item.read && !_opened.contains(item.id)) {
      try {
        await widget.repository.markInboxRead(item.sourceType, item.id);
        if (mounted) setState(() => _opened.add(item.id));
      } catch (_) {
        // Keep the item unread when the server cannot record the open.
      }
    }
    if (!mounted) return;
    if (item.deepLink != null && widget.onOpenRelated != null) {
      await widget.onOpenRelated!(item);
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                AppDateFormat.dateTime(item.occurredAt),
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Text(item.body, style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(context.l10n.done),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final visible = items
        ?.where(
          (item) => !_unreadOnly || (!item.read && !_opened.contains(item.id)),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notifications),
        leading: BackButton(onPressed: widget.onBack),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: context.l10n.notificationPreferences,
            onPressed: widget.onManagePreferences,
          ),
        ],
      ),
      bottomNavigationBar: items != null && items.isEmpty
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: FilledButton(
                onPressed: widget.onManagePreferences,
                child: Text(context.l10n.uiManageNotifications),
              ),
            )
          : null,
      body: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        child: _error != null
            ? DesignEmptyState(
                key: const Key('notifications-error'),
                icon: Icons.cloud_off_outlined,
                title: context.l10n.uiNotificationsUnavailable,
                message: _error!,
                action: context.l10n.uiTryAgain042c86,
                onAction: _load,
              )
            : items == null
            ? const Center(
                key: Key('notifications-loading'),
                child: CircularProgressIndicator(),
              )
            : items.isEmpty
            ? DesignEmptyState(
                key: Key('notifications-empty'),
                icon: Icons.notifications_none_outlined,
                title: context.l10n.uiAllQuietForNow,
                message:
                    context.l10n.uiReportUpdatesAndSharingRemindersWillAppear,
              )
            : Column(
                key: const Key('notifications-list'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(context.l10n.uiAll),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(context.l10n.uiUnread),
                        ),
                      ],
                      selected: {_unreadOnly},
                      onSelectionChanged: (value) =>
                          setState(() => _unreadOnly = value.first),
                      showSelectedIcon: false,
                    ),
                  ),
                  Expanded(
                    child: visible!.isEmpty
                        ? DesignEmptyState(
                            icon: Icons.notifications_none_outlined,
                            title: context.l10n.uiNoUnreadUpdates,
                            message: context.l10n.uiYouReAllCaughtUp,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = visible[index];
                              final unread =
                                  !item.read && !_opened.contains(item.id);
                              return Card(
                                child: InkWell(
                                  onTap: () => _open(item),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.cardRadius,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          child: Icon(
                                            Icons.notifications_none_outlined,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            size: 19,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleSmall,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                AppDateFormat.dateWithRelative(
                                                  item.occurredAt,
                                                ),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (unread)
                                          const CircleAvatar(
                                            radius: 4,
                                            backgroundColor: AppColors.teal,
                                          ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
