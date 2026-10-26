import 'package:flutter/material.dart';

import '../../core/api_config.dart';
import 'account_repository.dart';

/// Consistent account photo with a readable initial when no image is available.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.profile,
    required this.radius,
    this.fallbackInitials,
  });

  final AccountProfile? profile;
  final double radius;
  final String? fallbackInitials;

  static ImageProvider? imageFor(String? avatarUrl) {
    final rawUrl = avatarUrl?.trim();
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.startsWith('data:')) {
      try {
        return MemoryImage(UriData.parse(rawUrl).contentAsBytes());
      } on FormatException {
        return null;
      }
    }
    return NetworkImage(
      rawUrl.startsWith('http') ? rawUrl : '$apiBaseUrl$rawUrl',
    );
  }

  static String initialFor(AccountProfile? profile) {
    final name = profile?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .take(2)
          .map((part) => String.fromCharCode(part.runes.first).toUpperCase())
          .join();
    }
    final email = profile?.email.trim();
    if (email == null || email.isEmpty) return '?';
    return String.fromCharCode(email.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final image = imageFor(profile?.avatarUrl);
    final fallback = Center(
      child: Text(
        fallbackInitials ?? initialFor(profile),
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontSize: radius * 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      child: ClipOval(
        child: image == null
            ? fallback
            : Image(
                image: image,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
                    frame != null || wasSynchronouslyLoaded ? child : fallback,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
