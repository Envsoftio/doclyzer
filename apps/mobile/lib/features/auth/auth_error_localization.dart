import 'package:flutter/widgets.dart';
import 'package:mobile/l10n/l10n.dart';

import 'auth_repository.dart';

/// API details stay available for support; visible error copy follows the app language.
String localizedAuthError(
  BuildContext context,
  AuthException error, {
  String? fallback,
}) {
  if (error.message.trim().replaceAll(RegExp(r'\.$'), '') ==
      'Current password is incorrect') {
    return context.l10n.uiCurrentPasswordIncorrect;
  }
  return switch (error.code) {
    'NETWORK_ERROR' => context.l10n.uiCannotReachServer,
    'AUTH_INVALID_CREDENTIALS' => context.l10n.uiInvalidEmailOrPassword,
    'AUTH_RATE_LIMITED' => context.l10n.uiTooManyAuthAttempts,
    'AUTH_EMAIL_INVALID' => context.l10n.uiEnterValidEmail,
    'AUTH_PASSWORD_INVALID' => context.l10n.uiPasswordRequirements,
    'AUTH_EMAIL_EXISTS' => context.l10n.uiAccountWithEmailExists,
    _ => fallback ?? context.l10n.genericError,
  };
}
