import 'package:flutter/widgets.dart';
import 'app_localizations.dart';
import 'app_localizations_en.dart';

export 'app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsEn();
}

const supportedLanguageNames = {
  'en': 'English',
  'hi': 'हिन्दी',
  'kn': 'ಕನ್ನಡ',
  'te': 'తెలుగు',
  'ml': 'മലയാളം',
  'ta': 'தமிழ்',
  'bn': 'বাংলা',
  'or': 'ଓଡ଼ିଆ',
  'gu': 'ગુજરાતી',
  'pa': 'ਪੰਜਾਬੀ',
  'mr': 'मराठी',
};

String supportedLanguage(String? value) =>
    supportedLanguageNames.containsKey(value) ? value! : 'en';
