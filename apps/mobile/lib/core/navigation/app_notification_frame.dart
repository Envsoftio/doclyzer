import 'package:flutter/widgets.dart';

/// Keeps the Navigator in the same child slot as status notices appear.
class AppNotificationFrame extends StatelessWidget {
  const AppNotificationFrame({
    super.key,
    required this.child,
    this.uploadNotice,
    this.readyNotice,
  });

  final Widget child;
  final Widget? uploadNotice;
  final Widget? readyNotice;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      uploadNotice ?? const SizedBox.shrink(),
      readyNotice ?? const SizedBox.shrink(),
      Expanded(key: const Key('app-notification-content'), child: child),
    ],
  );
}
