import 'package:flutter/material.dart';

import '../../core/api_config.dart';
import 'account_repository.dart';

/// Consistent account photo with a readable initial when no image is available.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.profile, required this.radius});

  final AccountProfile? profile;
  final double radius;

  static String initialFor(AccountProfile? profile) {
    final name = profile?.displayName?.trim();
    final label = name != null && name.isNotEmpty
        ? name
        : profile?.email.trim();
    if (label == null || label.isEmpty) return '?';
    return String.fromCharCode(label.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rawUrl = profile?.avatarUrl?.trim();
    final url = rawUrl == null || rawUrl.isEmpty
        ? null
        : rawUrl.startsWith('http')
        ? rawUrl
        : '$apiBaseUrl$rawUrl';
    final fallback = Center(
      child: Text(
        initialFor(profile),
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      child: ClipOval(
        child: url == null
            ? fallback
            : Image.network(
                url,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
