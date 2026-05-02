import 'package:flutter/material.dart';

class StatusMessenger {
  const StatusMessenger._();

  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      variant: _StatusVariant.success,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      variant: _StatusVariant.error,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      variant: _StatusVariant.info,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      variant: _StatusVariant.warning,
    );
  }

  static void showInfoOnMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showOnMessenger(
      messenger,
      message,
      variant: _StatusVariant.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showErrorOnMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showOnMessenger(
      messenger,
      message,
      variant: _StatusVariant.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required _StatusVariant variant,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    _showOnMessenger(
      messenger,
      message,
      variant: variant,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _showOnMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    required _StatusVariant variant,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(messenger.context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = switch (variant) {
      _StatusVariant.success => colorScheme.primaryContainer,
      _StatusVariant.error => colorScheme.errorContainer,
      _StatusVariant.warning => colorScheme.tertiaryContainer,
      _StatusVariant.info => colorScheme.surfaceContainerHighest,
    };

    final foregroundColor = switch (variant) {
      _StatusVariant.success => colorScheme.onPrimaryContainer,
      _StatusVariant.error => colorScheme.onErrorContainer,
      _StatusVariant.warning => colorScheme.onTertiaryContainer,
      _StatusVariant.info => colorScheme.onSurface,
    };

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.snackBarTheme.contentTextStyle?.copyWith(
            color: foregroundColor,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
                textColor: foregroundColor,
              )
            : null,
      ),
    );
  }
}

enum _StatusVariant { success, error, info, warning }
