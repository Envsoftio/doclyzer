import 'package:flutter/widgets.dart';
import 'package:mobile/l10n/l10n.dart';

import 'api_client.dart';

/// Keep server details in logs/support context; show a predictable translated
/// message when an API response has no translated, actionable error code.
String localizedError(BuildContext context, Object error, {String? fallback}) {
  if (error is ApiException) {
    switch (error.code) {
      case 'NETWORK_ERROR':
        return context.l10n.uiCannotReachServer;
      case 'AUTH_UNAUTHORIZED':
      case 'AUTH_SESSION_REVOKED':
        return context.l10n.uiSessionExpiredSignInAgain;
    }
  }
  return fallback ?? context.l10n.genericError;
}
