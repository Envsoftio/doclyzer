// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get trendLatestResult => 'ਨਵੀਨਤਮ ਨਤੀਜਾ';

  @override
  String get trendPreviousResult => 'ਪਿਛਲਾ ਨਤੀਜਾ';

  @override
  String get trendSourceUnit => 'ਇਸ ਸੀਮਾ ਦੀ ਅਸਲ ਇਕਾਈ';

  @override
  String get trendNoSavedResults =>
      'ਇਸ ਟੈਸਟ ਲਈ ਹਾਲੇ ਕੋਈ ਸੰਭਾਲਿਆ ਨਤੀਜਾ ਨਹੀਂ ਹੈ।';

  @override
  String get trendNoPlottableResults =>
      'ਨਮੂਨੇ ਦੀ ਤਾਰੀਖ ਵਾਲੇ ਸਹੀ ਸੰਖਿਆਤਮਕ ਨਤੀਜੇ ਚਾਰਟ ਵਿੱਚ ਨਹੀਂ ਦਿਖਾਏ ਜਾ ਸਕਦੇ।';

  @override
  String get trendOneResultHelp =>
      'ਇੱਕ ਨਤੀਜਾ ਸੰਭਾਲਿਆ ਗਿਆ ਹੈ। ਬਦਲਾਅ ਵੇਖਣ ਲਈ ਇੱਕ ਹੋਰ ਰਿਪੋਰਟ ਜੋੜੋ।';

  @override
  String get trendMultipleResultsHelp =>
      'ਤਾਰੀਖਾਂ ਬੀਤੇ ਸਮੇਂ ਦੇ ਅਨੁਸਾਰ ਦਿਖਾਈਆਂ ਗਈਆਂ ਹਨ। ਮੁੱਲ ਵੇਖਣ ਲਈ ਬਿੰਦੂ ਨੂੰ ਟੈਪ ਕਰੋ।';

  @override
  String trendUnplottedNote(int count) {
    return 'ਨਮੂਨੇ ਦੀ ਤਾਰੀਖ ਜਾਂ ਸਹੀ ਸੰਖਿਆਤਮਕ ਮੁੱਲ ਨਾ ਹੋਣ ਕਰਕੇ $count ਨਤੀਜੇ ਚਾਰਟ ਵਿੱਚ ਨਹੀਂ ਦਿਖਾਏ ਗਏ।';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$count ਨਤੀਜਿਆਂ ਨਾਲ $testName ਦਾ ਬਦਲਾਅ ਚਾਰਟ';
  }

  @override
  String get trendDateReview =>
      'ਨਮੂਨੇ ਦੀ ਤਾਰੀਖ ਪਿਛਲੀ ਜਾਣਕਾਰੀ ਕੱਢਣ ਤੋਂ ਮਿਲੀ ਹੈ। ਅਸਲ ਰਿਪੋਰਟ ਵਿੱਚ ਜਾਂਚੋ।';

  @override
  String get trendNotPlotted => 'ਚਾਰਟ ਵਿੱਚ ਨਹੀਂ ਦਿਖਾਇਆ ਗਿਆ';

  @override
  String get trendExactNumberUnavailable => 'ਨਤੀਜਾ ਸਹੀ ਸੰਖਿਆ ਨਹੀਂ ਹੈ';

  @override
  String get preferredLanguage => 'ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ';

  @override
  String get descriptionLanguage => 'ਵੇਰਵੇ ਦੀ ਭਾਸ਼ਾ';

  @override
  String get languageHelp =>
      'ਐਪ ਦੇ ਲੇਬਲਾਂ ਅਤੇ ਰਿਪੋਰਟ ਦੀਆਂ ਵਿਆਖਿਆਵਾਂ ਲਈ ਵਰਤੀ ਜਾਂਦੀ ਹੈ। ਤੁਸੀਂ ਕਿਸੇ ਵੀ ਸਮੇਂ ਵਿਆਖਿਆ ਦੀ ਭਾਸ਼ਾ ਬਦਲ ਸਕਦੇ ਹੋ।';

  @override
  String get languageSaveFailed =>
      'ਤੁਹਾਡੀ ਭਾਸ਼ਾ ਸੇਵ ਨਹੀਂ ਹੋ ਸਕੀ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get translationLoading => 'ਅਨੁਵਾਦ ਕੀਤਾ ਵੇਰਵਾ ਤਿਆਰ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ…';

  @override
  String get translationFailed =>
      'ਅਨੁਵਾਦ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ ਜਾਂ ਅੰਗਰੇਜ਼ੀ ਚੁਣੋ।';

  @override
  String get translationNote =>
      'ਸੇਵ ਕੀਤੀ ਅੰਗਰੇਜ਼ੀ ਵਿਆਖਿਆ ਤੋਂ AI ਰਾਹੀਂ ਅਨੁਵਾਦ ਕੀਤਾ ਗਿਆ ਹੈ। ਸਹੀ ਨਤੀਜਿਆਂ ਲਈ ਅਸਲ ਰਿਪੋਰਟ ਦੇਖੋ।';

  @override
  String get sourceChanged =>
      'ਰਿਪੋਰਟ ਬਦਲ ਗਈ ਹੈ। ਨਵੀਨਤਮ ਵਿਆਖਿਆ ਦੇਖਣ ਲਈ ਇਸਨੂੰ ਮੁੜ ਲੋਡ ਕਰੋ।';

  @override
  String get signupTitle => 'ਹੋਰ ਸਪਸ਼ਟ ਸਮਝ ਦੀ\nਸ਼ੁਰੂਆਤ ਇੱਥੋਂ ਹੁੰਦੀ ਹੈ।';

  @override
  String get signupIntro =>
      'ਆਪਣੀਆਂ ਰਿਪੋਰਟਾਂ ਅਤੇ ਨਤੀਜੇ ਇਕੱਠੇ ਰੱਖਣ ਲਈ ਖਾਤਾ ਬਣਾਓ।';

  @override
  String get loginIntro => 'ਆਪਣੀਆਂ ਸਿਹਤ ਰਿਪੋਰਟਾਂ ਦੇਖਣ ਅਤੇ ਸਮਝਣ ਲਈ ਸਾਈਨ ਇਨ ਕਰੋ।';

  @override
  String get emailAddress => 'ਈਮੇਲ ਪਤਾ';

  @override
  String get email => 'ਈਮੇਲ';

  @override
  String get password => 'ਪਾਸਵਰਡ';

  @override
  String get referralCode => 'ਰੈਫਰਲ ਕੋਡ (ਵਿਕਲਪਿਕ)';

  @override
  String get createAccount => 'ਖਾਤਾ ਬਣਾਓ';

  @override
  String get alreadyAccount => 'ਪਹਿਲਾਂ ਹੀ ਖਾਤਾ ਹੈ? ';

  @override
  String get noAccount => 'ਖਾਤਾ ਨਹੀਂ ਹੈ? ';

  @override
  String get signIn => 'ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get showPassword => 'ਪਾਸਵਰਡ ਦਿਖਾਓ';

  @override
  String get hidePassword => 'ਪਾਸਵਰਡ ਲੁਕਾਓ';

  @override
  String get needHelp => 'ਮਦਦ ਚਾਹੀਦੀ ਹੈ?';

  @override
  String get forgotPassword => 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ?';

  @override
  String get invalidCredentialsInput => 'ਵੈਧ ਈਮੇਲ ਪਤਾ ਅਤੇ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ';

  @override
  String get signupFailed => 'ਖਾਤਾ ਨਹੀਂ ਬਣਾਇਆ ਜਾ ਸਕਿਆ';

  @override
  String get loginFailed =>
      'ਸਾਈਨ ਇਨ ਨਹੀਂ ਹੋ ਸਕਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਕਨੈਕਸ਼ਨ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get genericError => 'ਕੁਝ ਗੜਬੜ ਹੋ ਗਈ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get profileUpdated => 'ਪ੍ਰੋਫਾਈਲ ਅੱਪਡੇਟ ਹੋ ਗਈ';

  @override
  String get changePhoto => 'ਪ੍ਰੋਫਾਈਲ ਫੋਟੋ ਬਦਲੋ';

  @override
  String get gallery => 'ਗੈਲਰੀ ਵਿੱਚੋਂ ਚੁਣੋ';

  @override
  String get camera => 'ਫੋਟੋ ਖਿੱਚੋ';

  @override
  String get photoUpdated => 'ਪ੍ਰੋਫਾਈਲ ਫੋਟੋ ਅੱਪਡੇਟ ਹੋ ਗਈ';

  @override
  String get photoFailed =>
      'ਤੁਹਾਡੀ ਫੋਟੋ ਅੱਪਡੇਟ ਨਹੀਂ ਹੋ ਸਕੀ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get yourAccount => 'ਤੁਹਾਡਾ ਖਾਤਾ';

  @override
  String get profileLoading => 'ਪ੍ਰੋਫਾਈਲ ਲੋਡ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get profileLoadAction => 'ਆਪਣੀ ਪ੍ਰੋਫਾਈਲ ਲੋਡ ਕਰਨ ਲਈ ਟੈਪ ਕਰੋ';

  @override
  String get accountData => 'ਖਾਤਾ ਅਤੇ ਡਾਟਾ';

  @override
  String get personalInformation => 'ਨਿੱਜੀ ਜਾਣਕਾਰੀ';

  @override
  String get notificationPreferences => 'ਸੂਚਨਾਵਾਂ ਦੀਆਂ ਤਰਜੀਹਾਂ';

  @override
  String get privacySecurity => 'ਨਿੱਜਤਾ ਅਤੇ ਸੁਰੱਖਿਆ';

  @override
  String get sharedLinks => 'ਸਾਂਝੇ ਕੀਤੇ ਲਿੰਕ';

  @override
  String get exportData => 'ਆਪਣਾ ਡਾਟਾ ਐਕਸਪੋਰਟ ਕਰੋ';

  @override
  String get additionalAccount => 'ਖਾਤੇ ਦੀ ਵਾਧੂ ਜਾਣਕਾਰੀ';

  @override
  String get additionalAccountHelp => 'ਪਰਿਵਾਰ, ਪਲਾਨ, ਰੈਫਰਲ, ਸੈਸ਼ਨ ਅਤੇ ਦਿੱਖ';

  @override
  String get familyProfiles => 'ਪਰਿਵਾਰਕ ਪ੍ਰੋਫਾਈਲਾਂ';

  @override
  String get manageProfiles => 'ਪ੍ਰੋਫਾਈਲਾਂ ਬਦਲੋ ਜਾਂ ਉਹਨਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ';

  @override
  String get planCredits => 'ਪਲਾਨ ਅਤੇ ਕ੍ਰੈਡਿਟ';

  @override
  String get viewPlanBalance => 'ਆਪਣਾ ਪਲਾਨ ਅਤੇ ਬਕਾਇਆ ਦੇਖੋ';

  @override
  String get balanceLoading => 'ਬਕਾਇਆ ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ…';

  @override
  String get referFriends => 'ਦੋਸਤਾਂ ਨੂੰ ਸੱਦਾ ਦਿਓ';

  @override
  String get referralRewards => 'ਸੱਦੇ ਅਤੇ ਰੈਫਰਲ ਇਨਾਮ';

  @override
  String get activeSessions => 'ਸਰਗਰਮ ਸੈਸ਼ਨ';

  @override
  String get appearance => 'ਦਿੱਖ';

  @override
  String get system => 'ਸਿਸਟਮ ਅਨੁਸਾਰ';

  @override
  String get light => 'ਹਲਕਾ';

  @override
  String get dark => 'ਗੂੜ੍ਹਾ';

  @override
  String get helpSupport => 'ਮਦਦ ਅਤੇ ਸਹਾਇਤਾ';

  @override
  String get aboutDoclyzer => 'Doclyzer ਬਾਰੇ';

  @override
  String get aboutCopy =>
      'ਰਿਪੋਰਟਾਂ ਨੂੰ ਵਿਅਕਤੀ ਅਨੁਸਾਰ ਤਰਤੀਬ ਵਿੱਚ ਰੱਖੋ ਅਤੇ ਕੱਢੇ ਗਏ ਨਤੀਜਿਆਂ ਨੂੰ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਮਿਲਾ ਕੇ ਜਾਂਚੋ।';

  @override
  String get logOut => 'ਲੌਗ ਆਉਟ ਕਰੋ';

  @override
  String get profile => 'ਪ੍ਰੋਫਾਈਲ';

  @override
  String get saveChanges => 'ਬਦਲਾਅ ਸੇਵ ਕਰੋ';

  @override
  String get accountRestricted => 'ਖਾਤੇ \'ਤੇ ਪਾਬੰਦੀ ਹੈ';

  @override
  String get photoUploading => 'ਫੋਟੋ ਅੱਪਲੋਡ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get changePhotoShort => 'ਫੋਟੋ ਬਦਲੋ';

  @override
  String get accountDetails => 'ਖਾਤੇ ਦੇ ਵੇਰਵੇ';

  @override
  String get emailHelp =>
      'ਖਾਤੇ ਤੱਕ ਪਹੁੰਚ ਲਈ ਵਰਤਿਆ ਜਾਂਦਾ ਹੈ। ਇਸਨੂੰ ਬਦਲਣ ਲਈ ਸਹਾਇਤਾ ਨਾਲ ਸੰਪਰਕ ਕਰੋ।';

  @override
  String get accountName => 'ਖਾਤੇ ਦਾ ਨਾਮ';

  @override
  String get belowLabRange => 'ਇਸ ਲੈਬ ਦੀ ਹਵਾਲਾ ਸੀਮਾ ਤੋਂ ਹੇਠਾਂ';

  @override
  String get withinLabRange => 'ਇਸ ਲੈਬ ਦੀ ਹਵਾਲਾ ਸੀਮਾ ਦੇ ਅੰਦਰ';

  @override
  String get aboveLabRange => 'ਇਸ ਲੈਬ ਦੀ ਹਵਾਲਾ ਸੀਮਾ ਤੋਂ ਉੱਪਰ';

  @override
  String get cannotCompare => 'ਲੈਬ ਦੀ ਸੀਮਾ ਨਾਲ ਤੁਲਨਾ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕਦੀ';

  @override
  String get understandResult => 'ਇਸ ਨਤੀਜੇ ਨੂੰ ਸਮਝੋ';

  @override
  String get yourResult => 'ਤੁਹਾਡਾ ਨਤੀਜਾ';

  @override
  String get labReferenceRange => 'ਲੈਬ ਦੀ ਹਵਾਲਾ ਸੀਮਾ';

  @override
  String get resultUnavailable => 'ਇਸ ਨਤੀਜੇ ਵਿੱਚ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get sampleDate => 'ਨਮੂਨੇ ਦੀ ਤਾਰੀਖ';

  @override
  String get resultHistory => 'ਨਤੀਜਿਆਂ ਦਾ ਇਤਿਹਾਸ';

  @override
  String get originalReport => 'ਅਸਲ ਰਿਪੋਰਟ';

  @override
  String get reviewValue => 'ਮੁੱਲ ਦੀ ਜਾਂਚ ਕਰੋ';

  @override
  String get understandYourResult => 'ਆਪਣੇ ਨਤੀਜੇ ਨੂੰ ਸਮਝੋ';

  @override
  String get educationalContext =>
      'ਇਸ ਨਤੀਜੇ ਬਾਰੇ ਚਰਚਾ ਕਰਨ ਵਿੱਚ ਮਦਦ ਲਈ ਸਿੱਖਿਆਤਮਕ ਜਾਣਕਾਰੀ।';

  @override
  String get explanationUnavailable => 'ਵਿਆਖਿਆ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get explanationFailed => 'ਅਸੀਂ ਇਸ ਵੇਲੇ ਵਿਆਖਿਆ ਲੋਡ ਨਹੀਂ ਕਰ ਸਕੇ।';

  @override
  String get checkOriginal => 'ਅਸਲ ਰਿਪੋਰਟ ਜਾਂਚੋ';

  @override
  String get tryAgain => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get aiGuidance => 'AI ਰਾਹੀਂ ਤਿਆਰ ਕੀਤਾ ਮਾਰਗਦਰਸ਼ਨ';

  @override
  String get understandingResult => 'ਇਸ ਨਤੀਜੇ ਨੂੰ ਸਮਝਣਾ';

  @override
  String get possibleMeaning => 'ਇਸਦਾ ਕੀ ਅਰਥ ਹੋ ਸਕਦਾ ਹੈ';

  @override
  String get whatTestMeasures => 'ਇਹ ਟੈਸਟ ਕੀ ਮਾਪਦਾ ਹੈ';

  @override
  String get suggestedNextStep => 'ਸੁਝਾਇਆ ਅਗਲਾ ਕਦਮ';

  @override
  String get resultLimitations => 'ਇਹ ਨਤੀਜਾ ਤੁਹਾਨੂੰ ਕੀ ਨਹੀਂ ਦੱਸ ਸਕਦਾ';

  @override
  String get oneResultLimit =>
      'ਸਿਰਫ਼ ਇੱਕ ਨਤੀਜੇ ਨਾਲ ਕਿਸੇ ਬਿਮਾਰੀ ਦਾ ਨਿਦਾਨ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ ਜਾਂ ਲੱਛਣਾਂ ਦਾ ਕਾਰਨ ਨਹੀਂ ਸਮਝਿਆ ਜਾ ਸਕਦਾ।';

  @override
  String get detailsToCheck => 'ਜਾਂਚਣ ਵਾਲੇ ਵੇਰਵੇ';

  @override
  String get lifestyleFactors => 'ਚਰਚਾ ਲਈ ਜੀਵਨਸ਼ੈਲੀ ਨਾਲ ਜੁੜੇ ਕਾਰਕ';

  @override
  String get insightContext =>
      'ਇਹ ਮੁੱਲ ਤੁਹਾਡੀ ਰਿਪੋਰਟ ਤੋਂ ਕੱਢਿਆ ਗਿਆ ਹੈ। ਜੇ ਨਾਮ, ਮੁੱਲ, ਇਕਾਈ ਜਾਂ ਸੀਮਾ ਗਲਤ ਲੱਗੇ ਤਾਂ ਅਸਲ ਰਿਪੋਰਟ ਜਾਂਚੋ। AI ਦੀਆਂ ਵਿਆਖਿਆਵਾਂ ਸਿੱਖਿਆਤਮਕ ਹਨ ਅਤੇ ਇਹ ਨਹੀਂ ਦੱਸ ਸਕਦੀਆਂ ਕਿ ਤੁਹਾਨੂੰ ਕਿਹੜੇ ਇਲਾਜ ਦੀ ਲੋੜ ਹੈ।';

  @override
  String get yourProfile => 'ਤੁਹਾਡੀ ਪ੍ਰੋਫਾਈਲ';

  @override
  String get cancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get delete => 'ਮਿਟਾਓ';

  @override
  String get moveReport => 'ਰਿਪੋਰਟ ਦੂਜੀ ਪ੍ਰੋਫਾਈਲ ਵਿੱਚ ਭੇਜੋ';

  @override
  String get gotIt => 'ਸਮਝ ਆ ਗਿਆ';

  @override
  String get reportDetails => 'ਰਿਪੋਰਟ ਦੇ ਵੇਰਵੇ';

  @override
  String get shareReport => 'ਰਿਪੋਰਟ ਸਾਂਝੀ ਕਰੋ';

  @override
  String get moreReportActions => 'ਰਿਪੋਰਟ ਲਈ ਹੋਰ ਕਾਰਵਾਈਆਂ';

  @override
  String get attemptHistory => 'ਕੋਸ਼ਿਸ਼ਾਂ ਦਾ ਇਤਿਹਾਸ';

  @override
  String get compareReports => 'ਰਿਪੋਰਟਾਂ ਦੀ ਤੁਲਨਾ ਕਰੋ';

  @override
  String get readParsedReport => 'ਜਾਣਕਾਰੀ ਕੱਢ ਕੇ ਤਿਆਰ ਕੀਤੀ ਰਿਪੋਰਟ ਪੜ੍ਹੋ';

  @override
  String get moveRecycle => 'ਰੀਸਾਈਕਲ ਬਿਨ ਵਿੱਚ ਭੇਜੋ';

  @override
  String get retry => 'ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get reportSummary => 'ਰਿਪੋਰਟ ਦਾ ਸਾਰ';

  @override
  String get updateSummary => 'ਸਾਰ ਅੱਪਡੇਟ ਕਰੋ';

  @override
  String get summaryLoading =>
      'ਤੁਹਾਡੇ ਨਤੀਜਿਆਂ ਨੂੰ ਸੌਖੀ ਭਾਸ਼ਾ ਵਿੱਚ ਸਮਝਾਇਆ ਜਾ ਰਿਹਾ ਹੈ…';

  @override
  String get checkSummary => 'ਸਾਰ ਜਾਂਚੋ';

  @override
  String get summaryFailed =>
      'ਅਸੀਂ ਸਾਰ ਤਿਆਰ ਨਹੀਂ ਕਰ ਸਕੇ। ਤੁਸੀਂ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get summaryPlaceholder =>
      'ਮੁੱਖ ਨਤੀਜਿਆਂ ਦੀ ਸੌਖੀ ਭਾਸ਼ਾ ਵਿੱਚ ਵਿਆਖਿਆ ਇੱਥੇ ਦਿਖਾਈ ਦੇਵੇਗੀ।';

  @override
  String get retrySummary => 'ਸਾਰ ਲਈ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get generateSummary => 'ਸਾਰ ਤਿਆਰ ਕਰੋ';

  @override
  String get loadingResults => 'ਰਿਪੋਰਟ ਦੇ ਨਤੀਜੇ ਲੋਡ ਹੋ ਰਹੇ ਹਨ…';

  @override
  String get somethingWrong => 'ਕੁਝ ਗੜਬੜ ਹੋ ਗਈ';

  @override
  String get viewTrends => 'ਰੁਝਾਨ ਦੇਖੋ';

  @override
  String get originalFile => 'ਅਸਲ ਫਾਈਲ';

  @override
  String get testValues => 'ਟੈਸਟ ਦੇ ਮੁੱਲ';

  @override
  String get summary => 'ਸਾਰ';

  @override
  String get checkStatus => 'ਸਥਿਤੀ ਜਾਂਚੋ';

  @override
  String get viewOriginal => 'ਅਸਲ ਦੇਖੋ';

  @override
  String get verifiedResults => 'ਤਸਦੀਕ ਕੀਤੇ ਨਤੀਜੇ';

  @override
  String get resultTapHelp =>
      'ਟੈਸਟ ਕੀ ਮਾਪਦਾ ਹੈ, ਇਹ ਸਮਝਣ ਲਈ ਕਿਸੇ ਨਤੀਜੇ \'ਤੇ ਟੈਪ ਕਰੋ।';

  @override
  String get reviewResults => 'ਪਛਾਣੇ ਗਏ ਨਤੀਜਿਆਂ ਦੀ ਜਾਂਚ ਕਰੋ';

  @override
  String get keepFile => 'ਫਿਰ ਵੀ ਫਾਈਲ ਰੱਖੋ';

  @override
  String get patientDetails => 'ਮਰੀਜ਼ ਦੇ ਵੇਰਵੇ';

  @override
  String get name => 'ਨਾਮ';

  @override
  String get age => 'ਉਮਰ';

  @override
  String get gender => 'ਲਿੰਗ';

  @override
  String get bookingId => 'ਬੁਕਿੰਗ ID';

  @override
  String get sampleCollection => 'ਨਮੂਨਾ ਲੈਣਾ';

  @override
  String get labDetails => 'ਲੈਬ ਦੇ ਵੇਰਵੇ';

  @override
  String get labName => 'ਲੈਬ ਦਾ ਨਾਮ';

  @override
  String get address => 'ਪਤਾ';

  @override
  String get phone => 'ਫੋਨ';

  @override
  String get location => 'ਸਥਾਨ';

  @override
  String get belowRange => 'ਸੀਮਾ ਤੋਂ ਹੇਠਾਂ';

  @override
  String get aboveRange => 'ਸੀਮਾ ਤੋਂ ਉੱਪਰ';

  @override
  String get withinRange => 'ਦਿੱਤੀ ਸੀਮਾ ਦੇ ਅੰਦਰ';

  @override
  String get rangeUnclear => 'ਸੀਮਾ ਅਸਪਸ਼ਟ ਹੈ';

  @override
  String get understandResultAction => 'ਇਸ ਨਤੀਜੇ ਨੂੰ ਸਮਝੋ  →';

  @override
  String get parsedReport => 'ਜਾਣਕਾਰੀ ਕੱਢ ਕੇ ਤਿਆਰ ਕੀਤੀ ਰਿਪੋਰਟ';

  @override
  String get reports => 'ਰਿਪੋਰਟਾਂ';

  @override
  String get trends => 'ਰੁਝਾਨ';

  @override
  String get openingPage => 'ਸ਼ੁਰੂਆਤੀ ਪੰਨਾ';

  @override
  String get home => 'ਮੁੱਖ ਪੰਨਾ';

  @override
  String get family => 'ਪਰਿਵਾਰ';

  @override
  String get switchProfile => 'ਪ੍ਰੋਫਾਈਲ ਬਦਲੋ';

  @override
  String get currentProfile => 'ਮੌਜੂਦਾ ਪ੍ਰੋਫਾਈਲ';

  @override
  String get viewProfile => 'ਇਹ ਪ੍ਰੋਫਾਈਲ ਦੇਖੋ';

  @override
  String get manageFamily => 'ਪਰਿਵਾਰ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ';

  @override
  String get chooseProfile => 'ਇੱਕ ਪ੍ਰੋਫਾਈਲ ਚੁਣੋ';

  @override
  String get notifications => 'ਸੂਚਨਾਵਾਂ';

  @override
  String get homeTitle => 'ਥੋੜ੍ਹੀ ਹੋਰ ਸਪਸ਼ਟਤਾ।\nਸਭ ਇੱਕੋ ਥਾਂ।';

  @override
  String get nextReportTitle =>
      'ਤੁਹਾਡੀ ਅਗਲੀ ਰਿਪੋਰਟ,\nਜਦੋਂ ਤੁਸੀਂ ਤਿਆਰ ਹੋਵੋ, ਇਹ ਵੀ ਤਿਆਰ ਹੈ।';

  @override
  String get homeSubtitle => 'PDF, ਫੋਟੋਆਂ ਅਤੇ ਪਰਿਵਾਰਕ ਰਿਕਾਰਡ।';

  @override
  String get uploadReport => 'ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get recentReport => 'ਹਾਲੀਆ ਰਿਪੋਰਟ';

  @override
  String get viewAll => 'ਸਭ ਦੇਖੋ';

  @override
  String get reportsUnavailable =>
      'ਰਿਪੋਰਟਾਂ ਉਪਲਬਧ ਨਹੀਂ ਹਨ। ਇੰਟਰਨੈੱਟ ਨਾਲ ਜੁੜਨ \'ਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get emptyHomeTitle => 'ਤੁਹਾਡੀ ਕਹਾਣੀ ਇੱਥੋਂ ਸ਼ੁਰੂ ਹੁੰਦੀ ਹੈ';

  @override
  String get emptyHomeHelp =>
      'ਆਪਣੇ ਰਿਕਾਰਡਾਂ ਦਾ ਸਪਸ਼ਟ ਇਤਿਹਾਸ ਬਣਾਉਣਾ ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਆਪਣੀ ਪਹਿਲੀ ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰੋ।';

  @override
  String get uploadFirstReport => 'ਆਪਣੀ ਪਹਿਲੀ ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get latestResults => 'ਨਵੀਨਤਮ ਨਤੀਜੇ';

  @override
  String get allTrends => 'ਸਾਰੇ ਰੁਝਾਨ';

  @override
  String get reviewedResultsHelp =>
      'ਜਾਂਚੇ ਗਏ ਨਤੀਜੇ ਉਪਲਬਧ ਹੋਣ \'ਤੇ ਇੱਥੇ ਦਿਖਾਈ ਦੇਣਗੇ।';

  @override
  String get searchTests => 'ਟੈਸਟ ਖੋਜੋ';

  @override
  String get noHealthData =>
      'ਅਜੇ ਸਿਹਤ ਸੰਬੰਧੀ ਕੋਈ ਡਾਟਾ ਨਹੀਂ ਹੈ। ਆਪਣਾ ਸਿਹਤ ਇਤਿਹਾਸ ਦੇਖਣ ਲਈ ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰੋ।';

  @override
  String get noTestsFound => 'ਕੋਈ ਟੈਸਟ ਨਹੀਂ ਮਿਲਿਆ';

  @override
  String get shorterTestName => 'ਟੈਸਟ ਦਾ ਛੋਟਾ ਨਾਮ ਵਰਤ ਕੇ ਦੇਖੋ।';

  @override
  String get clearSearch => 'ਖੋਜ ਸਾਫ਼ ਕਰੋ';

  @override
  String get unitUnavailable => 'ਇਕਾਈ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get uploadingReport => 'ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get organizingReport => 'ਤੁਹਾਡੀ ਰਿਪੋਰਟ ਤਰਤੀਬ ਵਿੱਚ ਲਿਆਂਦੀ ਜਾ ਰਹੀ ਹੈ…';

  @override
  String get uploadAReport => 'ਇੱਕ ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get uploadHelp =>
      'ਇੱਕ PDF ਜਾਂ ਸਾਫ਼ ਫੋਟੋ ਚੁਣੋ। ਤੁਸੀਂ ਸੇਵ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਵੇਰਵੇ ਜਾਂਚ ਸਕਦੇ ਹੋ।';

  @override
  String get chooseSource => 'ਸਰੋਤ ਚੁਣੋ';

  @override
  String get uploadPdfImage => 'PDF ਜਾਂ ਤਸਵੀਰ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get chooseReportFiles => 'ਆਪਣੀਆਂ ਫਾਈਲਾਂ ਵਿੱਚੋਂ ਰਿਪੋਰਟ ਚੁਣੋ';

  @override
  String get selectReportPages => 'ਰਿਪੋਰਟ ਦੇ ਇੱਕ ਜਾਂ ਵੱਧ ਪੰਨੇ ਚੁਣੋ';

  @override
  String get capturePage => 'ਪੂਰੇ ਪੰਨੇ ਦੀ ਫੋਟੋ ਖਿੱਚੋ';

  @override
  String get supportedFormats => 'ਸਮਰਥਿਤ ਫਾਰਮੈਟ: PDF, JPG, PNG';

  @override
  String get confirmFile =>
      'ਯਕੀਨੀ ਬਣਾਓ ਕਿ ਇਹ ਉਹੀ ਫਾਈਲ ਹੈ ਜੋ ਤੁਸੀਂ ਸ਼ਾਮਲ ਕਰਨੀ ਚਾਹੁੰਦੇ ਹੋ।';

  @override
  String get addReport => 'ਰਿਪੋਰਟ ਸ਼ਾਮਲ ਕਰੋ';

  @override
  String get chooseDifferentFile => 'ਵੱਖਰੀ ਫਾਈਲ ਚੁਣੋ';

  @override
  String get uploadWait =>
      'ਇਸ ਵਿੱਚ ਕੁਝ ਸਮਾਂ ਲੱਗ ਸਕਦਾ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਐਪ ਖੁੱਲ੍ਹੀ ਰੱਖੋ।';

  @override
  String get reportNeedsAttention => 'ਰਿਪੋਰਟ ਵੱਲ ਧਿਆਨ ਦੇਣ ਦੀ ਲੋੜ ਹੈ';

  @override
  String get verifyBeforeSaving =>
      'ਪਛਾਣੇ ਗਏ ਨਤੀਜਿਆਂ ਨੂੰ ਸੇਵ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਮਿਲਾ ਕੇ ਜਾਂਚੋ।';

  @override
  String get viewVerifiedResults => 'ਤਸਦੀਕ ਕੀਤੇ ਨਤੀਜੇ ਦੇਖੋ';

  @override
  String get viewOriginalReport => 'ਅਸਲ ਰਿਪੋਰਟ ਦੇਖੋ';

  @override
  String get viewReportStatus => 'ਰਿਪੋਰਟ ਦੀ ਸਥਿਤੀ ਦੇਖੋ';

  @override
  String get viewResults => 'ਨਤੀਜੇ ਦੇਖੋ';

  @override
  String get viewOriginalFile => 'ਅਸਲ ਫਾਈਲ ਦੇਖੋ';

  @override
  String get retryExtraction => 'ਨਤੀਜੇ ਕੱਢਣ ਦੀ ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get done => 'ਹੋ ਗਿਆ';

  @override
  String get duplicateReport =>
      'ਇਹ ਰਿਪੋਰਟ ਪਹਿਲਾਂ ਤੋਂ ਮੌਜੂਦ ਰਿਪੋਰਟ ਦੀ ਨਕਲ ਲੱਗਦੀ ਹੈ';

  @override
  String get duplicateHelp =>
      'ਇਹ ਫਾਈਲ ਪਹਿਲਾਂ ਹੀ ਤੁਹਾਡੀਆਂ ਰਿਪੋਰਟਾਂ ਵਿੱਚ ਹੋ ਸਕਦੀ ਹੈ।';

  @override
  String get keepExisting => 'ਮੌਜੂਦਾ ਰਿਪੋਰਟ ਰੱਖੋ';

  @override
  String get processAgain => 'PDF \'ਤੇ ਮੁੜ ਪ੍ਰਕਿਰਿਆ ਕਰੋ';

  @override
  String get uploadNewCopy => 'ਨਵੀਂ ਕਾਪੀ ਵਜੋਂ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get reportLimitReached => 'ਰਿਪੋਰਟਾਂ ਦੀ ਸੀਮਾ ਪੂਰੀ ਹੋ ਗਈ ਹੈ';

  @override
  String get reportLimitHelp =>
      'ਤੁਸੀਂ ਆਪਣੀਆਂ ਰਿਪੋਰਟਾਂ ਦੀ ਸੀਮਾ ਤੱਕ ਪਹੁੰਚ ਗਏ ਹੋ।';

  @override
  String get upgrade => 'ਅੱਪਗ੍ਰੇਡ ਕਰੋ';

  @override
  String get back => 'ਵਾਪਸ';

  @override
  String get uploadFailedTitle => 'ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀ';

  @override
  String get uploadFailed => 'ਅੱਪਲੋਡ ਅਸਫਲ ਰਿਹਾ';

  @override
  String get retrySameFile => 'ਉਸੇ ਫਾਈਲ ਨਾਲ ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get chooseAnotherFile => 'ਹੋਰ ਫਾਈਲ ਚੁਣੋ';

  @override
  String get aiDisclaimer =>
      'Doclyzer ਤੁਹਾਡੀਆਂ ਸਿਹਤ ਰਿਪੋਰਟਾਂ ਨੂੰ ਤਰਤੀਬ ਵਿੱਚ ਰੱਖਣ ਅਤੇ ਬਿਹਤਰ ਸਮਝਣ ਵਿੱਚ ਮਦਦ ਕਰਦਾ ਹੈ। ਦਿੱਤੀ ਜਾਣਕਾਰੀ ਸਿਰਫ਼ ਸਿੱਖਿਆਤਮਕ ਉਦੇਸ਼ਾਂ ਲਈ ਹੈ ਅਤੇ ਇਹ ਡਾਕਟਰੀ ਸਲਾਹ, ਨਿਦਾਨ ਜਾਂ ਇਲਾਜ ਨਹੀਂ ਹੈ। ਡਾਕਟਰੀ ਮਾਰਗਦਰਸ਼ਨ ਲਈ ਹਮੇਸ਼ਾ ਕਿਸੇ ਯੋਗ ਸਿਹਤ ਸੰਭਾਲ ਪੇਸ਼ੇਵਰ ਨਾਲ ਸਲਾਹ ਕਰੋ।';

  @override
  String collectedOn(String date) {
    return 'ਨਮੂਨਾ ਲਿਆ ਗਿਆ $date';
  }

  @override
  String uploadedOn(String date) {
    return 'ਅੱਪਲੋਡ ਕੀਤਾ ਗਿਆ $date';
  }

  @override
  String labRangeValue(String range) {
    return 'ਲੈਬ ਦੀ ਸੀਮਾ $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits ਕ੍ਰੈਡਿਟ';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ਰਿਪੋਰਟਾਂ',
      one: '1 ਰਿਪੋਰਟ',
      zero: 'ਕੋਈ ਰਿਪੋਰਟ ਨਹੀਂ',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'ਰਿਪੋਰਟ ਲੋਡ ਹੋਣ ਵਿੱਚ ਉਮੀਦ ਨਾਲੋਂ ਵੱਧ ਸਮਾਂ ਲੱਗ ਰਿਹਾ ਹੈ। ਆਪਣਾ ਕਨੈਕਸ਼ਨ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get summaryUpdateFailed =>
      'ਅਸੀਂ ਇਸ ਵੇਲੇ ਸਾਰ ਅੱਪਡੇਟ ਨਹੀਂ ਕਰ ਸਕੇ। ਸੇਵ ਕੀਤਾ ਸਾਰ ਅਜੇ ਵੀ ਉਪਲਬਧ ਹੈ।';

  @override
  String get summaryCreateFailed =>
      'ਅਸੀਂ ਇਸ ਵੇਲੇ ਸਾਰ ਤਿਆਰ ਨਹੀਂ ਕਰ ਸਕੇ। ਤੁਹਾਡੇ ਨਤੀਜੇ ਅਜੇ ਵੀ ਹੇਠਾਂ ਉਪਲਬਧ ਹਨ।';

  @override
  String get reassignFailed =>
      'ਰਿਪੋਰਟ ਦੂਜੀ ਪ੍ਰੋਫਾਈਲ ਨੂੰ ਨਹੀਂ ਸੌਂਪੀ ਜਾ ਸਕੀ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get confirmRecycle => 'ਰੀਸਾਈਕਲ ਬਿਨ ਵਿੱਚ ਭੇਜਣਾ ਹੈ?';

  @override
  String get recycleHelp =>
      'ਤੁਸੀਂ ਇਸ ਰਿਪੋਰਟ ਨੂੰ ਰਿਪੋਰਟਾਂ > ਰੀਸਾਈਕਲ ਬਿਨ ਤੋਂ 30 ਦਿਨਾਂ ਤੱਕ ਬਹਾਲ ਕਰ ਸਕਦੇ ਹੋ। ਉਸ ਤੋਂ ਬਾਅਦ, ਇਹ ਪੱਕੇ ਤੌਰ \'ਤੇ ਮਿਟਾ ਦਿੱਤੀ ਜਾਵੇਗੀ।';

  @override
  String get reportRecycled => 'ਰਿਪੋਰਟ ਰੀਸਾਈਕਲ ਬਿਨ ਵਿੱਚ ਭੇਜ ਦਿੱਤੀ ਗਈ';

  @override
  String get reportDeleteFailed =>
      'ਰਿਪੋਰਟ ਮਿਟਾਈ ਨਹੀਂ ਜਾ ਸਕੀ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get addProfileBeforeMove =>
      'ਇਹ ਰਿਪੋਰਟ ਦੂਜੀ ਪ੍ਰੋਫਾਈਲ ਵਿੱਚ ਭੇਜਣ ਤੋਂ ਪਹਿਲਾਂ ਇੱਕ ਹੋਰ ਪਰਿਵਾਰਕ ਪ੍ਰੋਫਾਈਲ ਸ਼ਾਮਲ ਕਰੋ।';

  @override
  String get moveReportHelp =>
      'ਜੇ ਇਹ ਰਿਪੋਰਟ ਗਲਤ ਪ੍ਰੋਫਾਈਲ ਵਿੱਚ ਸ਼ਾਮਲ ਕੀਤੀ ਗਈ ਸੀ ਤਾਂ ਪਰਿਵਾਰ ਦਾ ਕੋਈ ਹੋਰ ਮੈਂਬਰ ਚੁਣੋ।';

  @override
  String get confirmMoveReport => 'ਇਹ ਰਿਪੋਰਟ ਦੂਜੀ ਪ੍ਰੋਫਾਈਲ ਵਿੱਚ ਭੇਜਣੀ ਹੈ?';

  @override
  String get aboutSampleDates => 'ਨਮੂਨੇ ਦੀਆਂ ਤਾਰੀਖਾਂ ਬਾਰੇ';

  @override
  String get multipleDatesHelp =>
      'ਇਸ ਰਿਪੋਰਟ ਵਿੱਚ ਵੱਖ-ਵੱਖ ਤਾਰੀਖਾਂ \'ਤੇ ਲਏ ਨਮੂਨਿਆਂ ਦੇ ਨਤੀਜੇ ਹਨ। ਕੋਈ ਨਤੀਜਾ ਖੋਲ੍ਹ ਕੇ ਉਸਦੀ ਤਾਰੀਖ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਮਿਲਾ ਕੇ ਜਾਂਚੋ।';

  @override
  String get missingDateHelp =>
      'ਨਮੂਨੇ ਦੀ ਤਾਰੀਖ ਉਹ ਤਾਰੀਖ ਹੈ ਜਦੋਂ ਨਮੂਨਾ ਲਿਆ ਗਿਆ ਸੀ। ਸਾਨੂੰ ਇਸ ਰਿਪੋਰਟ ਵਿੱਚ ਭਰੋਸੇਯੋਗ ਤਾਰੀਖ ਨਹੀਂ ਮਿਲੀ। ਨਮੂਨੇ ਦੀ ਤਾਰੀਖ ਅੱਪਲੋਡ ਦੀ ਤਾਰੀਖ ਤੋਂ ਵੱਖਰੀ ਹੁੰਦੀ ਹੈ। ਤਾਰੀਖ ਜਾਂਚਣ ਜਾਂ ਠੀਕ ਕਰਨ ਲਈ ਕੋਈ ਨਤੀਜਾ ਖੋਲ੍ਹੋ।';

  @override
  String get uploading => 'ਅੱਪਲੋਡ ਹੋ ਰਿਹਾ ਹੈ';

  @override
  String get waitingToProcess => 'ਪ੍ਰਕਿਰਿਆ ਦੀ ਉਡੀਕ ਵਿੱਚ';

  @override
  String get readingReport => 'ਰਿਪੋਰਟ ਪੜ੍ਹੀ ਜਾ ਰਹੀ ਹੈ';

  @override
  String get readyToReview => 'ਜਾਂਚ ਲਈ ਤਿਆਰ';

  @override
  String get someResultsNeedReview => 'ਕੁਝ ਨਤੀਜਿਆਂ ਦੀ ਜਾਂਚ ਦੀ ਲੋੜ ਹੈ';

  @override
  String get couldNotReadReport => 'ਰਿਪੋਰਟ ਪੜ੍ਹੀ ਨਹੀਂ ਜਾ ਸਕੀ';

  @override
  String get processingStopped => 'ਪ੍ਰਕਿਰਿਆ ਰੁਕ ਗਈ';

  @override
  String get couldNotProcessReport => 'ਰਿਪੋਰਟ \'ਤੇ ਪ੍ਰਕਿਰਿਆ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕੀ';

  @override
  String get reportRefreshFailed =>
      'ਇਹ ਰਿਪੋਰਟ ਤਾਜ਼ਾ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕੀ। ਆਖ਼ਰੀ ਵਾਰ ਲੋਡ ਕੀਤਾ ਨਤੀਜਾ ਦਿਖਾਇਆ ਜਾ ਰਿਹਾ ਹੈ।';

  @override
  String get multipleSampleDates => 'ਨਮੂਨੇ ਦੀਆਂ ਕਈ ਤਾਰੀਖਾਂ ';

  @override
  String get missingSampleDate => 'ਨਮੂਨੇ ਦੀ ਤਾਰੀਖ ਨਹੀਂ ਮਿਲੀ ';

  @override
  String get reportAnalyzing =>
      'ਅਸੀਂ ਇਸ ਰਿਪੋਰਟ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਕਰ ਰਹੇ ਹਾਂ। ਤੁਸੀਂ ਇਹ ਸਕ੍ਰੀਨ ਛੱਡ ਸਕਦੇ ਹੋ; ਨਤੀਜੇ ਤਿਆਰ ਹੋਣ \'ਤੇ ਦਿਖਾਈ ਦੇਣਗੇ।';

  @override
  String get extractionIncompleteTitle =>
      'ਅਸੀਂ ਸਾਰੇ ਨਤੀਜੇ ਭਰੋਸੇਯੋਗ ਢੰਗ ਨਾਲ ਨਹੀਂ ਕੱਢ ਸਕੇ';

  @override
  String get extractionIncompleteHelp =>
      'ਆਪਣੇ ਆਪ ਨਤੀਜੇ ਕੱਢਣ ਦੀ ਪ੍ਰਕਿਰਿਆ ਅਧੂਰੀ ਰਹੀ। ਪਛਾਣੀਆਂ ਗਈਆਂ ਕਤਾਰਾਂ ਨੂੰ ਸੇਵ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਮਿਲਾ ਕੇ ਜਾਂਚੋ।';

  @override
  String get verifiedRowsHelp =>
      'ਇਹ ਕਤਾਰਾਂ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਮਿਲਾ ਕੇ ਜਾਂਚੀਆਂ ਗਈਆਂ ਸਨ। ਹੋਰ ਕਤਾਰਾਂ ਦੀ ਅਜੇ ਵੀ ਜਾਂਚ ਦੀ ਲੋੜ ਹੋ ਸਕਦੀ ਹੈ।';

  @override
  String get noTestValues =>
      'ਇਸ ਰਿਪੋਰਟ ਵਿੱਚ ਟੈਸਟ ਦਾ ਕੋਈ ਮੁੱਲ ਨਹੀਂ ਮਿਲਿਆ। ਇਸਦੀ ਸਮੱਗਰੀ ਜਾਂਚਣ ਲਈ ਅਸਲ ਫਾਈਲ ਖੋਲ੍ਹੋ।';

  @override
  String get processingRetryHelp =>
      'ਪ੍ਰਕਿਰਿਆ ਪੂਰੀ ਹੋਣ ਤੋਂ ਪਹਿਲਾਂ ਰੁਕ ਗਈ। ਤੁਹਾਡੀ ਫਾਈਲ ਸੇਵ ਹੈ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰਨ ਲਈ \'ਮੁੜ ਕੋਸ਼ਿਸ਼ ਕਰੋ\' \'ਤੇ ਟੈਪ ਕਰੋ।';

  @override
  String get resultsNeedCheck =>
      'ਕੁਝ ਨਤੀਜਿਆਂ ਨੂੰ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਮਿਲਾ ਕੇ ਜਾਂਚਣ ਦੀ ਲੋੜ ਹੈ। ਤੁਸੀਂ ਹੇਠਾਂ ਪਛਾਣੀਆਂ ਗਈਆਂ ਕਤਾਰਾਂ ਦੀ ਜਾਂਚ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get readerModeHelp =>
      'ਆਸਾਨ ਪਹੁੰਚ ਅਤੇ ਸੌਖੇ ਢੰਗ ਨਾਲ ਪੜ੍ਹਨ ਲਈ, ਜਾਣਕਾਰੀ ਕੱਢ ਕੇ ਤਿਆਰ ਕੀਤੀ ਰਿਪੋਰਟ ਪੜ੍ਹਨ ਵਾਲੇ ਮੋਡ ਵਿੱਚ ਉਪਲਬਧ ਹੈ।';

  @override
  String get aiRangeHelp =>
      'ਪ੍ਰਕਿਰਿਆ ਦੌਰਾਨ AI ਨੇ ਸੀਮਾ ਦੀ ਵਿਆਖਿਆ ਕੀਤੀ ਹੈ। ਅਸਲ ਰਿਪੋਰਟ ਜਾਂਚੋ।';

  @override
  String get checkResultHelp =>
      'ਇਸ ਨਤੀਜੇ \'ਤੇ ਭਰੋਸਾ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਇਸਨੂੰ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਮਿਲਾ ਕੇ ਜਾਂਚੋ।';

  @override
  String get preferredRangeHelp =>
      'ਲੈਬ ਵੱਲੋਂ ਛਾਪੀ ਤਰਜੀਹੀ ਸ਼੍ਰੇਣੀ ਨਾਲ ਤੁਲਨਾ ਕੀਤੀ ਗਈ ਹੈ; ਪੁਸ਼ਟੀ ਕਰੋ ਕਿ ਇਹ ਤੁਹਾਡੇ \'ਤੇ ਲਾਗੂ ਹੁੰਦੀ ਹੈ।';

  @override
  String get categoryComparisonHelp =>
      'ਇਸ ਤੁਲਨਾ ਲਈ ਲੈਬ ਵੱਲੋਂ ਛਾਪੀ ਤਰਜੀਹੀ ਸ਼੍ਰੇਣੀ ਵਰਤੀ ਗਈ ਹੈ। ਜਾਂਚੋ ਕਿ ਇਹ ਸ਼੍ਰੇਣੀ ਤੁਹਾਡੇ \'ਤੇ ਲਾਗੂ ਹੁੰਦੀ ਹੈ।';

  @override
  String get missingSavedResult =>
      'ਇਸ ਮੁੱਲ ਨੂੰ ਕਿਸੇ ਸੇਵ ਕੀਤੇ ਨਤੀਜੇ ਨਾਲ ਮਿਲਾਇਆ ਨਹੀਂ ਜਾ ਸਕਿਆ। ਅਸਲ ਰਿਪੋਰਟ ਜਾਂਚੋ ਜਾਂ ਇਹ ਰਿਪੋਰਟ ਤਾਜ਼ਾ ਕਰੋ।';

  @override
  String get unreviewedTest =>
      'AI ਵਿਆਖਿਆਵਾਂ ਲਈ ਇਸ ਟੈਸਟ ਦੀ ਅਜੇ ਜਾਂਚ ਨਹੀਂ ਕੀਤੀ ਗਈ। ਅਸਲ ਰਿਪੋਰਟ ਜਾਂਚੋ ਅਤੇ ਆਪਣੇ ਡਾਕਟਰ ਨਾਲ ਨਤੀਜੇ ਬਾਰੇ ਚਰਚਾ ਕਰੋ।';

  @override
  String get unsafeResult =>
      'ਕੱਢਿਆ ਗਿਆ ਨਤੀਜਾ ਅਸਪਸ਼ਟ ਹੈ, ਇਸ ਲਈ ਇਸਦੀ ਸੁਰੱਖਿਅਤ ਢੰਗ ਨਾਲ ਵਿਆਖਿਆ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕਦੀ। ਅਸਲ ਰਿਪੋਰਟ ਜਾਂਚੋ।';

  @override
  String get filterReports => 'ਰਿਪੋਰਟਾਂ ਫਿਲਟਰ ਕਰੋ';

  @override
  String get sortReports => 'ਰਿਪੋਰਟਾਂ ਦਾ ਕ੍ਰਮ ਬਦਲੋ';

  @override
  String get recycleBin => 'ਰੀਸਾਈਕਲ ਬਿਨ';

  @override
  String get healthHistory => 'ਸਿਹਤ ਇਤਿਹਾਸ';

  @override
  String get shareProfile => 'ਪ੍ਰੋਫਾਈਲ ਸਾਂਝੀ ਕਰੋ';

  @override
  String get reportsUnavailableTitle => 'ਰਿਪੋਰਟਾਂ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get reportsLoadFailed =>
      'ਰਿਪੋਰਟਾਂ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀਆਂ। ਇੰਟਰਨੈੱਟ ਨਾਲ ਜੁੜਨ \'ਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get upload => 'ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get reportsFor => 'ਇਨ੍ਹਾਂ ਲਈ ਰਿਪੋਰਟਾਂ';

  @override
  String get searchReports => 'ਰਿਪੋਰਟਾਂ ਜਾਂ ਲੈਬਾਂ ਖੋਜੋ';

  @override
  String get filters => 'ਫਿਲਟਰ';

  @override
  String get noReportsYet => 'ਅਜੇ ਕੋਈ ਰਿਪੋਰਟ ਨਹੀਂ';

  @override
  String get noMatchingReports => 'ਤੁਹਾਡੀ ਖੋਜ ਨਾਲ ਕੋਈ ਰਿਪੋਰਟ ਮੇਲ ਨਹੀਂ ਖਾਂਦੀ।';

  @override
  String get differentSearch => 'ਕੋਈ ਵੱਖਰਾ ਟੈਸਟ, ਲੈਬ ਜਾਂ ਫਿਲਟਰ ਵਰਤ ਕੇ ਦੇਖੋ।';

  @override
  String get clearFilters => 'ਖੋਜ ਅਤੇ ਫਿਲਟਰ ਸਾਫ਼ ਕਰੋ';

  @override
  String get original => 'ਅਸਲ';

  @override
  String get switchActiveProfile => 'ਸਰਗਰਮ ਪ੍ਰੋਫਾਈਲ ਬਦਲੋ';

  @override
  String get switchProfileHelp =>
      'ਕਿਸੇ ਹੋਰ ਵਿਅਕਤੀ ਦੀਆਂ ਰਿਪੋਰਟਾਂ ਦੇਖੋ। ਅੱਪਲੋਡ ਅਤੇ ਰੁਝਾਨਾਂ ਲਈ ਤੁਹਾਡੀ ਸਰਗਰਮ ਪ੍ਰੋਫਾਈਲ ਵੀ ਬਦਲ ਜਾਵੇਗੀ।';

  @override
  String get multipleCollectionDates => 'ਨਮੂਨੇ ਲੈਣ ਦੀਆਂ ਕਈ ਤਾਰੀਖਾਂ';

  @override
  String get unknownCollectionDate => 'ਨਮੂਨਾ ਲੈਣ ਦੀ ਤਾਰੀਖ ਅਣਜਾਣ ਹੈ';

  @override
  String get profileLoadFailed =>
      'ਪ੍ਰੋਫਾਈਲਾਂ ਲੋਡ ਨਹੀਂ ਹੋ ਸਕੀਆਂ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get pleaseTryAgain => 'ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get deleteProfileConfirm => 'ਪ੍ਰੋਫਾਈਲ ਮਿਟਾਉਣੀ ਹੈ?';

  @override
  String get deleteProfileHelp =>
      'ਇਹ ਪ੍ਰੋਫਾਈਲ ਹਟਾ ਦਿੱਤੀ ਜਾਵੇਗੀ। ਇਸ ਨਾਲ ਜੁੜਿਆ ਕੋਈ ਵੀ ਡਾਟਾ ਪ੍ਰਭਾਵਿਤ ਹੋਵੇਗਾ।';

  @override
  String get profileDeleteFailed =>
      'ਪ੍ਰੋਫਾਈਲ ਮਿਟਾਈ ਨਹੀਂ ਜਾ ਸਕੀ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get addFamilyMember => 'ਪਰਿਵਾਰਕ ਮੈਂਬਰ ਸ਼ਾਮਲ ਕਰੋ';

  @override
  String get familyUnavailable => 'ਪਰਿਵਾਰਕ ਪ੍ਰੋਫਾਈਲਾਂ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get familyIntro => 'ਰਿਪੋਰਟਾਂ ਅਤੇ ਰੁਝਾਨ, ਵਿਅਕਤੀ ਅਨੁਸਾਰ ਤਰਤੀਬ ਵਿੱਚ';

  @override
  String get noProfilesYet => 'ਅਜੇ ਕੋਈ ਪ੍ਰੋਫਾਈਲ ਨਹੀਂ';

  @override
  String get noProfilesHelp =>
      'ਆਪਣੀਆਂ ਜਾਂ ਪਰਿਵਾਰਕ ਮੈਂਬਰਾਂ ਦੀਆਂ ਰਿਪੋਰਟਾਂ ਤਰਤੀਬ ਵਿੱਚ ਰੱਖਣ ਲਈ ਪ੍ਰੋਫਾਈਲ ਸ਼ਾਮਲ ਕਰੋ।';

  @override
  String get yourFamily => 'ਤੁਹਾਡਾ ਪਰਿਵਾਰ';

  @override
  String get upgradeProfiles => 'ਹੋਰ ਪ੍ਰੋਫਾਈਲਾਂ ਸ਼ਾਮਲ ਕਰਨ ਲਈ ਅੱਪਗ੍ਰੇਡ ਕਰੋ';

  @override
  String get editProfile => 'ਪ੍ਰੋਫਾਈਲ ਸੋਧੋ';

  @override
  String get deleteProfile => 'ਪ੍ਰੋਫਾਈਲ ਮਿਟਾਓ';

  @override
  String get active => 'ਸਰਗਰਮ';

  @override
  String get setActive => 'ਸਰਗਰਮ ਬਣਾਓ';

  @override
  String get viewReports => 'ਰਿਪੋਰਟਾਂ ਦੇਖੋ';

  @override
  String get notNow => 'ਹੁਣ ਨਹੀਂ';

  @override
  String get openSettings => 'ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ';

  @override
  String get enableNotifications => 'ਸੂਚਨਾਵਾਂ ਚਾਲੂ ਕਰੋ';

  @override
  String get enableNotificationsConfirm => 'ਸੂਚਨਾਵਾਂ ਚਾਲੂ ਕਰਨੀਆਂ ਹਨ?';

  @override
  String get notificationsEnabled => 'ਰਿਪੋਰਟ ਦੀਆਂ ਸੂਚਨਾਵਾਂ ਚਾਲੂ ਹਨ';

  @override
  String get notificationsStayOff =>
      'ਸੂਚਨਾਵਾਂ ਅਜੇ ਵੀ ਬੰਦ ਹਨ। ਤੁਸੀਂ ਬਾਅਦ ਵਿੱਚ ਡਿਵਾਈਸ ਦੀਆਂ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਇਹਨਾਂ ਨੂੰ ਚਾਲੂ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get notificationsFailed =>
      'ਸੂਚਨਾਵਾਂ ਚਾਲੂ ਨਹੀਂ ਹੋ ਸਕੀਆਂ। ਆਪਣਾ ਕਨੈਕਸ਼ਨ ਜਾਂਚੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get switchProfileFailed =>
      'ਪ੍ਰੋਫਾਈਲ ਬਦਲੀ ਨਹੀਂ ਜਾ ਸਕੀ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get sourceReportFailed => 'ਸਰੋਤ ਰਿਪੋਰਟ ਖੋਲ੍ਹੀ ਨਹੀਂ ਜਾ ਸਕੀ।';

  @override
  String get partialRefreshFailed =>
      'ਕੁਝ ਜਾਣਕਾਰੀ ਤਾਜ਼ਾ ਨਹੀਂ ਹੋ ਸਕੀ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰਨ ਲਈ ਹੇਠਾਂ ਖਿੱਚੋ।';

  @override
  String get knowReportReady => 'ਰਿਪੋਰਟ ਤਿਆਰ ਹੋਣ \'ਤੇ ਸੂਚਨਾ ਪ੍ਰਾਪਤ ਕਰੋ';

  @override
  String get oneResult => 'ਇੱਕ ਨਤੀਜਾ';

  @override
  String get sameDayResults => 'ਇੱਕੋ ਦਿਨ ਦੇ ਨਤੀਜੇ';

  @override
  String get verificationRequired => 'ਤਸਦੀਕ ਦੀ ਲੋੜ ਹੈ';

  @override
  String get accountCreatedLogin =>
      'ਤੁਹਾਡਾ ਖਾਤਾ ਸਫਲਤਾਪੂਰਵਕ ਬਣ ਗਿਆ ਹੈ। ਲੌਗ ਇਨ ਕਰਨ ਲਈ ਅੱਗੇ ਵਧੋ।';

  @override
  String get continueLogin => 'ਲੌਗ ਇਨ ਕਰਨ ਲਈ ਅੱਗੇ ਵਧੋ';

  @override
  String get allReports => 'ਸਾਰੀਆਂ ਰਿਪੋਰਟਾਂ';

  @override
  String get filterReviewed => 'ਜਾਂਚ ਕੀਤੀ ਗਈ';

  @override
  String get filterNeedsReview => 'ਜਾਂਚ ਦੀ ਲੋੜ ਹੈ';

  @override
  String get filterProcessing => 'ਪ੍ਰਕਿਰਿਆ ਜਾਰੀ ਹੈ';

  @override
  String get filterOriginalOnly => 'ਸਿਰਫ਼ ਅਸਲ';

  @override
  String get reportDateNewest => 'ਰਿਪੋਰਟ ਦੀ ਤਾਰੀਖ · ਨਵੀਆਂ ਪਹਿਲਾਂ';

  @override
  String get reportDateOldest => 'ਰਿਪੋਰਟ ਦੀ ਤਾਰੀਖ · ਪੁਰਾਣੀਆਂ ਪਹਿਲਾਂ';

  @override
  String get uploadDateNewest => 'ਅੱਪਲੋਡ ਦੀ ਤਾਰੀਖ · ਨਵੀਆਂ ਪਹਿਲਾਂ';

  @override
  String get uploadDateOldest => 'ਅੱਪਲੋਡ ਦੀ ਤਾਰੀਖ · ਪੁਰਾਣੀਆਂ ਪਹਿਲਾਂ';

  @override
  String get switchAction => 'ਬਦਲੋ';

  @override
  String get collectionDate => 'ਨਮੂਨਾ ਲੈਣ ਦੀ ਤਾਰੀਖ';

  @override
  String get copy => 'ਕਾਪੀ ਕਰੋ';

  @override
  String get history => 'ਇਤਿਹਾਸ';

  @override
  String get loadingReport => 'ਰਿਪੋਰਟ ਲੋਡ ਹੋ ਰਹੀ ਹੈ…';

  @override
  String get restore => 'ਬਹਾਲ ਕਰੋ';

  @override
  String get revoke => 'ਰੱਦ ਕਰੋ';

  @override
  String get testName => 'ਟੈਸਟ ਦਾ ਨਾਮ';

  @override
  String get viewReport => 'ਰਿਪੋਰਟ ਦੇਖੋ';

  @override
  String get closeAccount => 'ਖਾਤਾ ਬੰਦ ਕਰੋ';

  @override
  String get createShareLink => 'ਸਾਂਝਾ ਕਰਨ ਲਈ ਲਿੰਕ ਬਣਾਓ';

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'ਦਿੱਖ ਬਦਲ ਗਈ, ਪਰ ਅਗਲੀ ਵਾਰ ਲਈ ਰੱਖਿਅਤ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕੀ।';

  @override
  String get uiThisReportIsNoLongerAvailable => 'ਇਹ ਰਿਪੋਰਟ ਹੁਣ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'ਸੂਚਨਾ ਪ੍ਰੀਵਿਊ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰਨ ਲਈ ਡੀਵਾਈਸ ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ।';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'ਇਸ ਸਕ੍ਰੀਨ ਨੂੰ ਉਦੋਂ ਤੱਕ ਖੁੱਲ੍ਹਾ ਰੱਖੋ ਜਦੋਂ ਤੱਕ ਅੱਪਲੋਡ ਸਵੀਕਾਰ ਨਹੀਂ ਹੋ ਜਾਂਦਾ।';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'ਇੱਕ ਅੱਪਲੋਡ ਵਿੱਚ ਰੁਕਾਵਟ ਹੋ ਸਕਦੀ ਹੈ';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'ਰਿਪੋਰਟਾਂ ਦੀ ਜਾਂਚ ਕਰੋ। ਜੇਕਰ ਇਹ ਗੁੰਮ ਹੈ, ਤਾਂ ਉਹੀ ਫਾਈਲ ਦੁਬਾਰਾ ਜੋੜੋ।';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'ਸੂਚਨਾਵਾਂ ਨੂੰ ਖਾਰਜ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiConnectionUnavailable => 'ਕਨੈਕਸ਼ਨ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'ਤੁਹਾਡੇ ਸੈਸ਼ਨ ਦੀ ਜਾਂਚ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕੀ ਹੈ। ਇੰਟਰਨੈੱਟ ਨਾਲ ਕਨੈਕਟ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiSignInWithAnotherAccount => 'ਕਿਸੇ ਹੋਰ ਖਾਤੇ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get uiNoActiveProfile => 'ਕੋਈ ਕਿਰਿਆਸ਼ੀਲ ਪ੍ਰੋਫਾਈਲ ਨਹੀਂ ਹੈ';

  @override
  String get uiDismissUploadNotice => 'ਅੱਪਲੋਡ ਨੋਟਿਸ ਖਾਰਜ ਕਰੋ';

  @override
  String get uiDismissReadyNotifications => 'ਤਿਆਰ ਸੂਚਨਾਵਾਂ ਨੂੰ ਖਾਰਜ ਕਰੋ';

  @override
  String get uiRequestSupport => 'ਸਹਾਇਤਾ ਲਈ ਬੇਨਤੀ ਕਰੋ';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'ਅਸੀਂ ਡਾਇਗਨੌਸਟਿਕ ਆਈਡੀ ਸ਼ਾਮਲ ਕਰਾਂਗੇ ਤਾਂ ਜੋ ਟੀਮ ਜਾਂਚ ਕਰ ਸਕੇ।';

  @override
  String get uiSendRequest => 'ਬੇਨਤੀ ਭੇਜੋ';

  @override
  String get uiWhatHappenedOptional => 'ਕੀ ਹੋਇਆ? (ਵਿਕਲਪਿਕ)';

  @override
  String get uiReviewResult => 'ਨਤੀਜੇ ਦੀ ਸਮੀਖਿਆ ਕਰੋ';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'ਸੁਰੱਖਿਅਤ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਇਹਨਾਂ ਖੇਤਰਾਂ ਦੀ ਅਸਲ ਰਿਪੋਰਟ ਨਾਲ ਤੁਲਨਾ ਕਰੋ।';

  @override
  String get uiOriginallyExtracted => 'ਮੂਲ ਰੂਪ ਵਿੱਚ ਕੱਢਿਆ ਗਿਆ';

  @override
  String get uiReloadReport => 'ਰਿਪੋਰਟ ਰੀਲੋਡ ਕਰੋ';

  @override
  String get uiResultAsPrinted => 'ਨਤੀਜਾ ਛਾਪਿਆ ਗਿਆ ਹੈ';

  @override
  String get uiUnitIfShown => 'ਯੂਨਿਟ (ਜੇ ਦਿਖਾਇਆ ਗਿਆ ਹੈ)';

  @override
  String get uiLabReferenceRangeIfShown => 'ਲੈਬ ਸੰਦਰਭ ਸੀਮਾ (ਜੇ ਦਿਖਾਇਆ ਗਿਆ ਹੈ)';

  @override
  String get uiCheckYourReport => 'ਆਪਣੀ ਰਿਪੋਰਟ ਦੀ ਜਾਂਚ ਕਰੋ';

  @override
  String get uiNoAttemptHistoryAvailable => 'ਕੋਈ ਕੋਸ਼ਿਸ਼ ਇਤਿਹਾਸ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String get uiIInspectedTheOriginal => 'ਮੈਂ ਅਸਲੀ ਦੀ ਜਾਂਚ ਕੀਤੀ';

  @override
  String get uiChooseTwoReports => 'ਦੋ ਰਿਪੋਰਟਾਂ ਚੁਣੋ';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'ਇੱਕੋ ਵਿਅਕਤੀ ਲਈ ਰਿਕਾਰਡਾਂ ਦੀ ਵਰਤੋਂ ਕਰੋ। ਮੈਚਿੰਗ ਟੈਸਟ ਨਾਲ-ਨਾਲ ਦਿਖਾਈ ਦੇਣਗੇ।';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'ਪਹਿਲਾਂ ਪੁਰਾਣੀ ਰਿਪੋਰਟ ਚੁਣੋ ਅਤੇ ਨਵੀਂ ਰਿਪੋਰਟ ਦੂਜੀ ਨੂੰ ਚੁਣੋ।';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'ਸਿਰਫ਼ ਅਨੁਕੂਲ ਹੋਣ \'ਤੇ ਹੀ ਤੁਲਨਾ ਕੀਤੀ ਜਾਂਦੀ ਹੈ। ਅਨੁਕੂਲਤਾ ਦੀ ਪੁਸ਼ਟੀ ਹੋਣ ਤੱਕ ਵੱਖ-ਵੱਖ ਇਕਾਈਆਂ ਜਾਂ ਵਿਧੀਆਂ ਨੂੰ ਵੱਖਰੇ ਤੌਰ \'ਤੇ ਦਿਖਾਇਆ ਜਾਂਦਾ ਹੈ।';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'ਤਬਦੀਲੀ ਇੱਕ ਨਿਦਾਨ ਨਹੀਂ ਹੈ। ਹਰੇਕ ਨਤੀਜੇ ਦੀ ਆਪਣੀ ਰਿਪੋਰਟ ਅੰਤਰਾਲ ਨਾਲ ਤੁਲਨਾ ਕਰੋ ਅਤੇ ਆਪਣੇ ਡਾਕਟਰੀ ਕਰਮਚਾਰੀ ਨਾਲ ਸੰਦਰਭ \'ਤੇ ਚਰਚਾ ਕਰੋ।';

  @override
  String get uiChooseDifferentReports => 'ਵੱਖਰੀਆਂ ਰਿਪੋਰਟਾਂ ਚੁਣੋ';

  @override
  String get uiEarlierReport => 'ਪਹਿਲਾਂ ਦੀ ਰਿਪੋਰਟ';

  @override
  String get uiLaterReport => 'ਬਾਅਦ ਵਿੱਚ ਰਿਪੋਰਟ';

  @override
  String get uiYourReportPages => 'ਤੁਹਾਡੇ ਰਿਪੋਰਟ ਪੰਨੇ';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'ਪੰਨਿਆਂ ਨੂੰ ਰਿਪੋਰਟ ਦੇ ਉਸੇ ਕ੍ਰਮ ਵਿੱਚ ਰੱਖੋ।';

  @override
  String get uiAddAnotherPage => 'ਕੋਈ ਹੋਰ ਪੰਨਾ ਜੋੜੋ';

  @override
  String get uiChoosePagesFromGallery => 'ਗੈਲਰੀ ਤੋਂ ਪੰਨੇ ਚੁਣੋ';

  @override
  String get uiAdjustPage => 'ਪੰਨਾ ਵਿਵਸਥਿਤ ਕਰੋ';

  @override
  String get uiRetake => 'ਦੁਬਾਰਾ ਲਓ';

  @override
  String get uiUseAdjustedPage => 'ਵਿਵਸਥਿਤ ਪੰਨੇ ਦੀ ਵਰਤੋਂ ਕਰੋ';

  @override
  String get uiResetChanges => 'ਤਬਦੀਲੀਆਂ ਨੂੰ ਰੀਸੈਟ ਕਰੋ';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'ਹਰ ਨਤੀਜੇ ਨੂੰ ਕੋਨਿਆਂ ਦੇ ਅੰਦਰ ਰੱਖੋ.';

  @override
  String get uiRotate => 'ਘੁੰਮਾਓ';

  @override
  String get uiReportRestored => 'ਰਿਪੋਰਟ ਬਹਾਲ ਕੀਤੀ ਗਈ';

  @override
  String get uiDeleteReportPermanently =>
      'ਕੀ ਰਿਪੋਰਟ ਨੂੰ ਪੱਕੇ ਤੌਰ \'ਤੇ ਮਿਟਾਉਣਾ ਹੈ?';

  @override
  String get uiDeletePermanently => 'ਪੱਕੇ ਤੌਰ \'ਤੇ ਮਿਟਾਓ';

  @override
  String get uiReportPermanentlyDeleted =>
      'ਰਿਪੋਰਟ ਨੂੰ ਪੱਕੇ ਤੌਰ \'ਤੇ ਮਿਟਾ ਦਿੱਤਾ ਗਿਆ';

  @override
  String get uiEmptyRecycleBin => 'ਖਾਲੀ ਰੀਸਾਈਕਲ ਬਿਨ?';

  @override
  String get uiDeleteAll => 'ਸਭ ਨੂੰ ਮਿਟਾਓ';

  @override
  String get uiRecycleBinIsEmpty => 'ਰੀਸਾਈਕਲ ਬਿਨ ਖਾਲੀ ਹੈ।';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'ਮਿਟਾਈਆਂ ਗਈਆਂ ਰਿਪੋਰਟਾਂ ਹਟਾਉਣ ਤੋਂ ਪਹਿਲਾਂ ਇੱਥੇ ਦਿਖਾਈ ਦੇਣਗੀਆਂ।';

  @override
  String get uiEmptyRecycleBind657e2 => 'ਖਾਲੀ ਰੀਸਾਈਕਲ ਬਿਨ';

  @override
  String get uiCheckDetectedResult => 'ਖੋਜੇ ਗਏ ਨਤੀਜੇ ਦੀ ਜਾਂਚ ਕਰੋ';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'ਇਸ ਕਤਾਰ ਦੀ ਮੂਲ ਰਿਪੋਰਟ ਨਾਲ ਤੁਲਨਾ ਕਰੋ। ਸੁਰੱਖਿਅਤ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਕਿਸੇ ਵੀ OCR ਗਲਤੀਆਂ ਨੂੰ ਠੀਕ ਕਰੋ।';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'ਮੈਂ ਅਸਲ ਰਿਪੋਰਟ ਦੇ ਵਿਰੁੱਧ ਇਸ ਨਤੀਜੇ ਦੀ ਜਾਂਚ ਕੀਤੀ';

  @override
  String get uiSaving => 'ਰੱਖਿਅਤ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get uiSaveVerifiedResult => 'ਪ੍ਰਮਾਣਿਤ ਨਤੀਜਾ ਸੁਰੱਖਿਅਤ ਕਰੋ';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'ਕੋਈ ਨਤੀਜੇ ਨਹੀਂ ਮਿਲੇ। ਅਸਲੀ ਰਿਪੋਰਟ ਦੇਖੋ ਜਾਂ ਮੁੜ ਪ੍ਰਕਿਰਿਆ ਕਰਨ ਦੀ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'ਖੋਜੇ ਗਏ ਮੁੱਲਾਂ ਨੂੰ ਸੁਰੱਖਿਅਤ ਨਤੀਜੇ ਬਣਨ ਤੋਂ ਪਹਿਲਾਂ ਅਸਲ ਰਿਪੋਰਟ ਦੇ ਵਿਰੁੱਧ ਜਾਂਚ ਕਰਨ ਦੀ ਲੋੜ ਹੁੰਦੀ ਹੈ।';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'ਕੁਝ ਕਤਾਰਾਂ ਗੁੰਮ ਹੋ ਸਕਦੀਆਂ ਹਨ। ਪੂਰੀ ਅਸਲ ਰਿਪੋਰਟ ਦੀ ਜਾਂਚ ਕਰੋ।';

  @override
  String get uiResult => 'ਨਤੀਜਾ';

  @override
  String get uiUnitOptional => 'ਯੂਨਿਟ (ਵਿਕਲਪਿਕ)';

  @override
  String get uiReferenceRangeOptional => 'ਹਵਾਲਾ ਸੀਮਾ (ਵਿਕਲਪਿਕ)';

  @override
  String get uiVerified => 'ਪ੍ਰਮਾਣਿਤ';

  @override
  String get uiGiftVoucher => 'ਗਿਫਟ ਵਾਊਚਰ';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'ਇੱਕ ਤੋਹਫ਼ਾ ਵਾਊਚਰ ਰੀਡੀਮ ਕਰੋ ਅਤੇ ਸਿੱਧੇ ਆਪਣੇ ਬਕਾਏ ਵਿੱਚ ਕ੍ਰੈਡਿਟ ਸ਼ਾਮਲ ਕਰੋ।';

  @override
  String get uiCurrentPlan => 'ਮੌਜੂਦਾ ਯੋਜਨਾ';

  @override
  String get uiCreditBalance => 'ਕ੍ਰੈਡਿਟ ਬਕਾਇਆ';

  @override
  String get uiPlanLimits => 'ਯੋਜਨਾ ਸੀਮਾਵਾਂ';

  @override
  String get uiBuyCredits => 'ਕ੍ਰੈਡਿਟ ਖਰੀਦੋ';

  @override
  String get uiRecentBillingActivity => 'ਹਾਲੀਆ ਬਿਲਿੰਗ ਗਤੀਵਿਧੀ';

  @override
  String get uiRefreshStatus => 'ਸਥਿਤੀ ਨੂੰ ਤਾਜ਼ਾ ਕਰੋ';

  @override
  String get uiNoRecentOrdersYet => 'ਅਜੇ ਤੱਕ ਕੋਈ ਹਾਲੀਆ ਆਰਡਰ ਨਹੀਂ ਹਨ।';

  @override
  String get uiVoucherCode => 'ਵਾਊਚਰ ਕੋਡ';

  @override
  String get uiCheckout => 'ਚੈੱਕਆਉਟ';

  @override
  String get uiApply => 'ਲਾਗੂ ਕਰੋ';

  @override
  String get uiClear => 'ਸਾਫ਼';

  @override
  String get uiPay => 'ਭੁਗਤਾਨ ਕਰੋ';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'ਇਸ ਸਮੇਂ ਕੋਈ ਕ੍ਰੈਡਿਟ ਪੈਕ ਉਪਲਬਧ ਨਹੀਂ ਹਨ।';

  @override
  String get uiBuy => 'ਖਰੀਦੋ';

  @override
  String get uiRetryPayment => 'ਭੁਗਤਾਨ ਦੀ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get uiPromoCode => 'ਪ੍ਰੋਮੋ ਕੋਡ';

  @override
  String get uiEnterPromoCode => 'ਪ੍ਰੋਮੋ ਕੋਡ ਦਾਖਲ ਕਰੋ';

  @override
  String get uiChooseAPlan => 'ਇੱਕ ਯੋਜਨਾ ਚੁਣੋ';

  @override
  String get uiNoPlansAvailableAtThisTime =>
      'ਇਸ ਸਮੇਂ ਕੋਈ ਯੋਜਨਾਵਾਂ ਉਪਲਬਧ ਨਹੀਂ ਹਨ।';

  @override
  String get uiHaveAPromoCode => 'ਕੀ ਇੱਕ ਪ੍ਰੋਮੋ ਕੋਡ ਹੈ?';

  @override
  String get uiCURRENTPLAN => 'ਮੌਜੂਦਾ ਯੋਜਨਾ';

  @override
  String get uiManageNotifications => 'ਸੂਚਨਾਵਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ';

  @override
  String get uiAll => 'ਸਾਰੇ';

  @override
  String get uiUnread => 'ਨਾ ਪੜ੍ਹਿਆ';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'ਪਹੁੰਚ ਤੁਰੰਤ ਬੰਦ ਹੋ ਜਾਂਦੀ ਹੈ। ਤੁਸੀਂ 30 ਦਿਨਾਂ ਦੇ ਅੰਦਰ ਸਾਈਨ ਇਨ ਅਤੇ ਰੀਸਟੋਰ ਕਰ ਸਕਦੇ ਹੋ। ਉਸ ਤੋਂ ਬਾਅਦ, ਤੁਹਾਡੇ ਖਾਤੇ ਅਤੇ ਸਟੋਰ ਕੀਤੀਆਂ ਫਾਈਲਾਂ ਨੂੰ ਕਿਰਿਆਸ਼ੀਲ ਸਟੋਰੇਜ ਤੋਂ ਮਿਟਾ ਦਿੱਤਾ ਜਾਂਦਾ ਹੈ।';

  @override
  String get uiCloseMyAccount => 'ਮੇਰਾ ਖਾਤਾ ਬੰਦ ਕਰੋ';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'ਤੁਹਾਡੇ ਰਿਕਾਰਡ ਡੌਕਲਾਈਜ਼ਰ ਵਿੱਚ ਰਹਿੰਦੇ ਹਨ।';

  @override
  String get uiTakeACopyOfYourRecords => 'ਆਪਣੇ ਰਿਕਾਰਡਾਂ ਦੀ ਇੱਕ ਕਾਪੀ ਲਓ।';

  @override
  String get uiWhoseRecords => 'ਕਿਸਦਾ ਰਿਕਾਰਡ?';

  @override
  String get uiCouldNotLoadProfiles => 'ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਲੋਡ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ';

  @override
  String get uiLoadingProfiles => 'ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਲੋਡ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get uiAllProfiles => 'ਸਾਰੇ ਪ੍ਰੋਫਾਈਲ';

  @override
  String get uiDateRange => 'ਮਿਤੀ ਰੇਂਜ';

  @override
  String get uiUseAllDates => 'ਸਾਰੀਆਂ ਤਾਰੀਖਾਂ ਦੀ ਵਰਤੋਂ ਕਰੋ';

  @override
  String get uiINCLUDEINTHISEXPORT => 'ਇਸ ਨਿਰਯਾਤ ਵਿੱਚ ਸ਼ਾਮਲ ਕਰੋ';

  @override
  String get uiOriginalReports => 'ਮੂਲ ਰਿਪੋਰਟਾਂ';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'PDF ਅਤੇ ਚਿੱਤਰ ਜੋ ਤੁਸੀਂ ਅੱਪਲੋਡ ਕੀਤੇ ਹਨ';

  @override
  String get uiTestResults => 'ਟੈਸਟ ਦੇ ਨਤੀਜੇ';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'CSV ਦੇ ਰੂਪ ਵਿੱਚ ਨਤੀਜੇ, ਉਹਨਾਂ ਦੀ ਸਮੀਖਿਆ ਸਥਿਤੀ ਦੇ ਨਾਲ';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'ਨਿਰਯਾਤ ਵਿੱਚ ਨਿੱਜੀ ਜਾਣਕਾਰੀ ਹੁੰਦੀ ਹੈ। ਉਹਨਾਂ ਨੂੰ ਉਸ ਥਾਂ ਤੇ ਸਟੋਰ ਕਰੋ ਜਿੱਥੇ ਤੁਸੀਂ ਭਰੋਸਾ ਕਰਦੇ ਹੋ।';

  @override
  String get uiDeleteAccount => 'ਖਾਤਾ ਮਿਟਾਓ';

  @override
  String get uiContinueToDeletion => 'ਮਿਟਾਉਣਾ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get uiKeepMyAccount => 'ਮੇਰਾ ਖਾਤਾ ਰੱਖੋ';

  @override
  String get uiBeforeYouLeave => 'ਤੁਹਾਡੇ ਜਾਣ ਤੋਂ ਪਹਿਲਾਂ';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'ਕਿਰਪਾ ਕਰਕੇ ਪੜ੍ਹੋ ਕਿ ਇਹ ਕੀ ਹਟਾ ਦੇਵੇਗਾ।';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'ਤੁਹਾਡੇ ਖਾਤੇ ਨੂੰ ਮਿਟਾਉਣਾ ਤੁਹਾਡੇ ਦੁਆਰਾ ਪ੍ਰਬੰਧਿਤ ਕੀਤੇ ਸਾਰੇ ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਪ੍ਰਭਾਵਿਤ ਕਰਦਾ ਹੈ।';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'ਤੁਹਾਡਾ ਖਾਤਾ ਅਤੇ ਨਿੱਜੀ ਪ੍ਰੋਫਾਈਲ';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'ਆਪਣੇ ਸਾਂਝੇ ਕੀਤੇ ਲਿੰਕਾਂ ਰਾਹੀਂ ਪਹੁੰਚ ਕਰੋ';

  @override
  String get uiKeepACopyFirst => 'ਪਹਿਲਾਂ ਇੱਕ ਕਾਪੀ ਰੱਖੋ';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'ਉਹ ਜਾਣਕਾਰੀ ਨਿਰਯਾਤ ਕਰੋ ਜੋ ਤੁਸੀਂ ਬਰਕਰਾਰ ਰੱਖਣਾ ਚਾਹੁੰਦੇ ਹੋ।';

  @override
  String get uiExportData => 'ਡਾਟਾ ਨਿਰਯਾਤ ਕਰੋ';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'ਪਹੁੰਚ ਤੁਰੰਤ ਬੰਦ ਹੋ ਜਾਂਦੀ ਹੈ। ਤੁਸੀਂ 30 ਦਿਨਾਂ ਦੇ ਅੰਦਰ ਰੀਸਟੋਰ ਕਰ ਸਕਦੇ ਹੋ। ਉਸ ਤੋਂ ਬਾਅਦ, ਤੁਹਾਡਾ ਡੇਟਾ ਕਿਰਿਆਸ਼ੀਲ ਸਟੋਰੇਜ ਤੋਂ ਹਟਾ ਦਿੱਤਾ ਜਾਂਦਾ ਹੈ.';

  @override
  String get uiAccountPendingDeletion => 'ਖਾਤਾ ਮਿਟਾਉਣਾ ਲੰਬਿਤ ਹੈ';

  @override
  String get uiRestoreMyAccount => 'ਮੇਰਾ ਖਾਤਾ ਰੀਸਟੋਰ ਕਰੋ';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'ਤੁਹਾਡੇ ਪ੍ਰੋਫਾਈਲ, ਪ੍ਰੋਫਾਈਲਾਂ ਅਤੇ ਸਹਿਮਤੀ ਦੇ ਰਿਕਾਰਡਾਂ ਸਮੇਤ ਆਪਣੇ ਖਾਤੇ ਦੇ ਡੇਟਾ ਦੀ ਇੱਕ ਕਾਪੀ ਡਾਊਨਲੋਡ ਕਰੋ।';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'ਤੁਹਾਡਾ ਖਾਤਾ ਤੁਰੰਤ ਅਯੋਗ ਕਰ ਦਿੱਤਾ ਗਿਆ ਹੈ। ਤੁਸੀਂ ਇਸਨੂੰ 30 ਦਿਨਾਂ ਦੇ ਅੰਦਰ ਰੀਸਟੋਰ ਕਰ ਸਕਦੇ ਹੋ। ਉਸ ਤੋਂ ਬਾਅਦ, ਤੁਹਾਡਾ ਡੇਟਾ ਸਥਾਈ ਤੌਰ \'ਤੇ ਮਿਟਾ ਦਿੱਤਾ ਜਾਂਦਾ ਹੈ।';

  @override
  String get uiCurrentPassword => 'ਮੌਜੂਦਾ ਪਾਸਵਰਡ';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'ਐਪ ਲੌਕ ਬਦਲਿਆ ਨਹੀਂ ਜਾ ਸਕਿਆ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'ਤੁਹਾਡੇ ਰਿਕਾਰਡ।\nਸ਼ੇਅਰ ਕਰਨ ਲਈ ਤੁਹਾਡੀ ਪਸੰਦ।';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'ਜਦੋਂ ਵੀ ਤੁਹਾਨੂੰ ਲੋੜ ਹੋਵੇ ਪਹੁੰਚ ਦੀ ਸਮੀਖਿਆ ਕਰੋ।';

  @override
  String get uiAppLock => 'ਐਪ ਲੌਕ';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'ਆਪਣੀ ਡਿਵਾਈਸ ਦੇ ਬਾਇਓਮੈਟ੍ਰਿਕ ਜਾਂ ਪਾਸਕੋਡ ਲੌਕ ਦੀ ਵਰਤੋਂ ਕਰੋ।';

  @override
  String get uiNotificationPreviews => 'ਸੂਚਨਾ ਪ੍ਰੀਵਿਊ';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'ਆਪਣੀ ਡਿਵਾਈਸ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਲੌਕ-ਸਕ੍ਰੀਨ ਪ੍ਰੀਵਿਊ ਨੂੰ ਕੰਟਰੋਲ ਕਰੋ।';

  @override
  String get uiContactSupport => 'ਸਹਾਇਤਾ ਨਾਲ ਸੰਪਰਕ ਕਰੋ';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'ਜੇਕਰ ਤੁਸੀਂ ਚੁਣਦੇ ਹੋ ਤਾਂ ਹੀ ਰਿਪੋਰਟਾਂ ਨੱਥੀ ਕਰੋ।';

  @override
  String get uiWhatCanWeHelpYouWith => 'ਅਸੀਂ ਤੁਹਾਡੀ ਕੀ ਮਦਦ ਕਰ ਸਕਦੇ ਹਾਂ?';

  @override
  String get uiPOPULARQUESTIONS => 'ਪ੍ਰਸਿੱਧ ਸਵਾਲ';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'ਕੋਈ ਮਦਦ ਲੇਖ ਤੁਹਾਡੀ ਖੋਜ ਨਾਲ ਮੇਲ ਨਹੀਂ ਖਾਂਦਾ।';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'ਤੁਹਾਡੀ ਸਿਹਤ ਜਾਂ ਟੈਸਟ ਦੇ ਨਤੀਜਿਆਂ ਬਾਰੇ ਸਵਾਲਾਂ ਲਈ, ਕਿਸੇ ਯੋਗ ਸਿਹਤ ਸੰਭਾਲ ਪੇਸ਼ੇਵਰ ਨਾਲ ਗੱਲ ਕਰੋ।';

  @override
  String get uiYourReportsAClearerPicture =>
      'ਤੁਹਾਡੀਆਂ ਰਿਪੋਰਟਾਂ। ਇੱਕ ਸਪਸ਼ਟ ਤਸਵੀਰ.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'ਆਪਣੇ ਸਿਹਤ ਇਤਿਹਾਸ ਨੂੰ ਇਕੱਠੇ ਰੱਖੋ।';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'ਰਿਪੋਰਟਾਂ ਨੂੰ ਸਟੋਰ ਕਰੋ, ਨਤੀਜਿਆਂ ਦੀ ਸਮੀਖਿਆ ਕਰੋ, ਤਬਦੀਲੀਆਂ ਦਾ ਪਾਲਣ ਕਰੋ ਅਤੇ ਆਪਣੇ ਡਾਕਟਰ ਨਾਲ ਸਾਂਝਾ ਕਰੋ।';

  @override
  String get uiEducationalInformationOnly => 'ਸਿਰਫ਼ ਵਿਦਿਅਕ ਜਾਣਕਾਰੀ';

  @override
  String get uiSearchHelpArticles => 'ਮਦਦ ਲੇਖ ਖੋਜੋ';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'ਸੂਚਨਾ ਪਹੁੰਚ ਨੂੰ ਬਦਲਣ ਲਈ ਡਿਵਾਈਸ ਸੈਟਿੰਗਜ਼ ਐਪ ਖੋਲ੍ਹੋ।';

  @override
  String get uiSavePreferences => 'ਤਰਜੀਹਾਂ ਨੂੰ ਸੁਰੱਖਿਅਤ ਕਰੋ';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'ਡਿਵਾਈਸ ਅਨੁਮਤੀਆਂ ਨੂੰ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਬਦਲਿਆ ਜਾ ਸਕਦਾ ਹੈ।';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'ਇਸ ਡੀਵਾਈਸ \'ਤੇ ਰਿਪੋਰਟ ਅੱਪਡੇਟ ਪ੍ਰਾਪਤ ਕਰੋ';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'ਸੂਚਨਾਵਾਂ ਨੂੰ ਇਹ ਜਾਣਨ ਦੀ ਇਜਾਜ਼ਤ ਦਿਓ ਕਿ ਰਿਪੋਰਟ ਕਦੋਂ ਤਿਆਰ ਹੈ। ਮਾਰਕੀਟਿੰਗ ਹੇਠਾਂ ਇੱਕ ਵੱਖਰੀ ਚੋਣ ਹੈ।';

  @override
  String get uiREPORTACTIVITY => 'ਗਤੀਵਿਧੀ ਦੀ ਰਿਪੋਰਟ ਕਰੋ';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'ਰਿਪੋਰਟ ਗਤੀਵਿਧੀ ਸੈਟਿੰਗਾਂ ਲਈ ਨਵੀਨਤਮ ਸਰਵਰ ਸੰਸਕਰਣ ਦੀ ਲੋੜ ਹੁੰਦੀ ਹੈ।';

  @override
  String get uiSensitiveLockScreenPreviews => 'ਸੰਵੇਦਨਸ਼ੀਲ ਲੌਕ-ਸਕ੍ਰੀਨ ਪੂਰਵ-ਝਲਕ';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'ਰਿਪੋਰਟ ਦੇ ਨਾਮ ਅਤੇ ਨਿੱਜੀ ਵੇਰਵੇ ਹਮੇਸ਼ਾ ਲੁਕਾਏ ਜਾਂਦੇ ਹਨ।';

  @override
  String get uiOTHERMESSAGES => 'ਹੋਰ ਸੁਨੇਹੇ';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'ਹਰੇਕ ਵਿਅਕਤੀ ਦੀਆਂ ਰਿਪੋਰਟਾਂ ਅਤੇ ਰੁਝਾਨਾਂ ਨੂੰ ਇਕੱਠੇ ਰੱਖੋ।';

  @override
  String get uiPersonDetails => 'ਵਿਅਕਤੀ ਦੇ ਵੇਰਵੇ';

  @override
  String get uiDateOfBirth => 'ਜਨਮ ਮਿਤੀ';

  @override
  String get uiRelationship => 'ਰਿਸ਼ਤਾ';

  @override
  String get uiEnterAName => 'ਇੱਕ ਨਾਮ ਦਰਜ ਕਰੋ';

  @override
  String get uiClearDateOfBirth => 'ਜਨਮ ਮਿਤੀ ਸਾਫ਼ ਕਰੋ';

  @override
  String get uiOptionalEGParentOrChild =>
      'ਵਿਕਲਪਿਕ, ਉਦਾਹਰਨ ਲਈ ਮਾਤਾ-ਪਿਤਾ ਜਾਂ ਬੱਚਾ';

  @override
  String get uiInviteFriendsEarnCredits => 'ਦੋਸਤਾਂ ਨੂੰ ਸੱਦਾ ਦਿਓ, ਕ੍ਰੈਡਿਟ ਕਮਾਓ';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'ਆਪਣਾ ਕੋਡ ਸਾਂਝਾ ਕਰੋ ਅਤੇ ਇਨਾਮ ਅਨਲੌਕ ਵਜੋਂ ਹਰੇਕ ਸੱਦੇ ਦੀ ਪਾਲਣਾ ਕਰੋ।';

  @override
  String get uiYOURREFERRALCODE => 'ਤੁਹਾਡਾ ਰੈਫਰਲ ਕੋਡ';

  @override
  String get uiShareInvite => 'ਸੱਦਾ ਸਾਂਝਾ ਕਰੋ';

  @override
  String get uiCopyCode => 'ਕੋਡ ਕਾਪੀ ਕਰੋ';

  @override
  String get uiHaveACode => 'ਕੀ ਕੋਈ ਕੋਡ ਹੈ?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'ਆਪਣੇ ਸੱਦਾ ਇਨਾਮ ਦਾ ਦਾਅਵਾ ਕਰਨ ਲਈ ਤੁਹਾਡੇ ਨਾਲ ਸਾਂਝਾ ਕੀਤਾ ਗਿਆ ਕੋਡ ਦਾਖਲ ਕਰੋ।';

  @override
  String get uiHowRewardsWork => 'ਇਨਾਮ ਕਿਵੇਂ ਕੰਮ ਕਰਦੇ ਹਨ';

  @override
  String get uiNoFriendsReferredYet =>
      'ਅਜੇ ਤੱਕ ਕਿਸੇ ਦੋਸਤ ਦਾ ਹਵਾਲਾ ਨਹੀਂ ਦਿੱਤਾ ਗਿਆ';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'ਉਹਨਾਂ ਦੀ ਤਰੱਕੀ ਨੂੰ ਇੱਥੇ ਦੇਖਣ ਲਈ ਆਪਣਾ ਸੱਦਾ ਸਾਂਝਾ ਕਰੋ।';

  @override
  String get uiReferralCode => 'ਰੈਫਰਲ ਕੋਡ';

  @override
  String get uiSetNewPassword => 'ਨਵਾਂ ਪਾਸਵਰਡ ਸੈੱਟ ਕਰੋ';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'ਆਪਣੀ ਈਮੇਲ ਵਿੱਚ ਲਿੰਕ ਤੋਂ ਰੀਸੈਟ ਟੋਕਨ ਅਤੇ ਆਪਣਾ ਨਵਾਂ ਪਾਸਵਰਡ ਦਾਖਲ ਕਰੋ।';

  @override
  String get uiResetPassword => 'ਪਾਸਵਰਡ ਰੀਸੈਟ ਕਰੋ';

  @override
  String get uiBackToLogin => 'ਲੌਗਇਨ \'ਤੇ ਵਾਪਸ ਜਾਓ';

  @override
  String get uiResetToken => 'ਟੋਕਨ ਰੀਸੈਟ ਕਰੋ';

  @override
  String get uiNewPassword => 'ਨਵਾਂ ਪਾਸਵਰਡ';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'ਆਪਣੇ ਖਾਤੇ ਨਾਲ ਸੰਬੰਧਿਤ ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ ਅਤੇ ਅਸੀਂ ਤੁਹਾਨੂੰ ਤੁਹਾਡੇ ਪਾਸਵਰਡ ਨੂੰ ਰੀਸੈਟ ਕਰਨ ਲਈ ਇੱਕ ਲਿੰਕ ਭੇਜਾਂਗੇ।';

  @override
  String get uiSendResetLink => 'ਰੀਸੈਟ ਲਿੰਕ ਭੇਜੋ';

  @override
  String get uiRevokeSession => 'ਕੀ ਸੈਸ਼ਨ ਰੱਦ ਕਰਨਾ ਹੈ?';

  @override
  String get uiCurrentSession => 'ਮੌਜੂਦਾ ਸੈਸ਼ਨ';

  @override
  String get uiSkip => 'ਛੱਡੋ';

  @override
  String get uiChangePassword => 'ਪਾਸਵਰਡ ਬਦਲੋ';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'ਆਪਣਾ ਮੌਜੂਦਾ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ ਅਤੇ ਇੱਕ ਨਵਾਂ ਚੁਣੋ।';

  @override
  String get uiNewPasswordd850ee => 'ਨਵਾਂ ਪਾਸਵਰਡ';

  @override
  String get uiConfirmNewPassword => 'ਨਵੇਂ ਪਾਸਵਰਡ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get uiGettingThingsReady => 'ਚੀਜ਼ਾਂ ਤਿਆਰ ਕੀਤੀਆਂ ਜਾ ਰਹੀਆਂ ਹਨ...';

  @override
  String get uiLinkAccessHistory => 'ਲਿੰਕ ਐਕਸੈਸ ਇਤਿਹਾਸ';

  @override
  String get uiNoAccessEventsYet => 'ਅਜੇ ਤੱਕ ਕੋਈ ਪਹੁੰਚ ਇਵੈਂਟ ਨਹੀਂ ਹਨ।';

  @override
  String get uiDefaultShareLinkExpiry => 'ਡਿਫੌਲਟ ਸ਼ੇਅਰ ਲਿੰਕ ਦੀ ਮਿਆਦ ਸਮਾਪਤੀ';

  @override
  String get uiSave => 'ਸੇਵ ਕਰੋ';

  @override
  String get uiReviewSharing => 'ਸ਼ੇਅਰਿੰਗ ਦੀ ਸਮੀਖਿਆ ਕਰੋ';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'ਵਿਅਕਤੀ, ਰਿਪੋਰਟਾਂ ਅਤੇ ਪਹੁੰਚ ਦੀ ਜਾਂਚ ਕਰੋ।';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'ਚੋਣ ਜਾਂ ਪਹੁੰਚ ਸੈਟਿੰਗਾਂ ਨੂੰ ਸੰਪਾਦਿਤ ਕਰੋ';

  @override
  String get uiRevokeShareLink => 'ਸ਼ੇਅਰ ਲਿੰਕ ਨੂੰ ਰੱਦ ਕਰਨਾ ਹੈ?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'ਇਹ ਲਿੰਕ ਕੰਮ ਕਰਨਾ ਬੰਦ ਕਰ ਦੇਵੇਗਾ। ਤੁਸੀਂ ਇੱਕ ਨਵਾਂ ਬਣਾ ਸਕਦੇ ਹੋ।';

  @override
  String get uiShareLinkReady => 'ਸਾਂਝਾ ਲਿੰਕ ਤਿਆਰ ਹੈ';

  @override
  String get uiAccessCodeShareSeparately =>
      'ਪਹੁੰਚ ਕੋਡ — ਵੱਖਰੇ ਤੌਰ \'ਤੇ ਸਾਂਝਾ ਕਰੋ';

  @override
  String get uiCopyAccessCode => 'ਐਕਸੈਸ ਕੋਡ ਕਾਪੀ ਕਰੋ';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'ਇਹ ਕੋਡ ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਸੁਰੱਖਿਅਤ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ। ਬਾਅਦ ਵਿੱਚ ਵਰਤੋਂ ਲਈ ਇਸਨੂੰ ਹੁਣੇ ਕਾਪੀ ਕਰੋ।';

  @override
  String get uiShareLink => 'ਲਿੰਕ ਸਾਂਝਾ ਕਰੋ';

  @override
  String get uiCopyLink => 'ਲਿੰਕ ਕਾਪੀ ਕਰੋ';

  @override
  String get uiRevokeLink => 'ਲਿੰਕ ਰੱਦ ਕਰੋ';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਕੋਡ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਸੁਰੱਖਿਅਤ ਕੀਤੇ ਕੋਡ ਦੀ ਵਰਤੋਂ ਕਰੋ ਜਾਂ ਨਵਾਂ ਲਿੰਕ ਬਣਾਓ।';

  @override
  String get uiActiveSharedLinks => 'ਸਰਗਰਮ ਸ਼ੇਅਰ ਲਿੰਕ';

  @override
  String get uiShare => 'ਸ਼ੇਅਰ ਕਰੋ';

  @override
  String get uiCreateANewShareLink => 'ਇੱਕ ਨਵਾਂ ਸ਼ੇਅਰ ਲਿੰਕ ਬਣਾਓ';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'ਇਸ ਪ੍ਰੋਫਾਈਲ ਲਈ ਮੌਜੂਦਾ ਅਤੇ ਭਵਿੱਖ ਦੀਆਂ ਰਿਪੋਰਟਾਂ ਸ਼ਾਮਲ ਕਰੋ।';

  @override
  String get uiChooseReports => 'ਰਿਪੋਰਟਾਂ ਦੀ ਚੋਣ ਕਰੋ';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'ਹੇਠਾਂ ਚੁਣੀਆਂ ਗਈਆਂ ਰਿਪੋਰਟਾਂ ਹੀ ਸਾਂਝੀਆਂ ਕਰੋ।';

  @override
  String get uiSelectAll => 'ਸਭ ਚੁਣੋ';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'ਸ਼ੇਅਰ ਕਰਨ ਲਈ ਕੋਈ ਸਮੀਖਿਆ ਕੀਤੀ ਰਿਪੋਰਟ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String get uiSelectedTestResults => 'ਚੁਣੇ ਗਏ ਟੈਸਟ ਦੇ ਨਤੀਜੇ';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'ਇਹਨਾਂ ਰਿਪੋਰਟਾਂ ਵਿੱਚੋਂ ਸਿਰਫ਼ ਉਹ ਨਤੀਜੇ ਸ਼ਾਮਲ ਕਰੋ ਜੋ ਤੁਸੀਂ ਚੁਣਦੇ ਹੋ।';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'ਇਹਨਾਂ ਰਿਪੋਰਟਾਂ ਵਿੱਚ ਕੋਈ ਸੁਰੱਖਿਅਤ ਕੀਤੇ ਟੈਸਟ ਨਤੀਜੇ ਉਪਲਬਧ ਨਹੀਂ ਹਨ।';

  @override
  String get uiUpgradeOrManage => 'ਅੱਪਗ੍ਰੇਡ ਕਰੋ ਜਾਂ ਪ੍ਰਬੰਧਿਤ ਕਰੋ';

  @override
  String get uiExpiry => 'ਮਿਆਦ:';

  @override
  String get uiRequireAnAccessCode => 'ਇੱਕ ਪਹੁੰਚ ਕੋਡ ਦੀ ਲੋੜ ਹੈ';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'ਕੋਡ ਨੂੰ ਲਿੰਕ ਤੋਂ ਵੱਖਰੇ ਤੌਰ \'ਤੇ ਸਾਂਝਾ ਕਰੋ।';

  @override
  String get uiTryAgain => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get uiClearExpiry => 'ਮਿਆਦ ਸਾਫ਼ ਕਰੋ';

  @override
  String get onboardingStoreEyebrow => '01 / ਸੰਭਾਲੋ';

  @override
  String get onboardingStoreTitle => 'ਹਰ ਰਿਪੋਰਟ,\nਇੱਕ ਜਾਣੀ-ਪਛਾਣੀ ਜਗ੍ਹਾ।';

  @override
  String get onboardingStoreBody =>
      'ਤੁਹਾਡੇ ਅਤੇ ਉਹਨਾਂ ਲੋਕਾਂ ਲਈ ਜਿਨ੍ਹਾਂ ਦੀ ਤੁਸੀਂ ਪਰਵਾਹ ਕਰਦੇ ਹੋ, PDF ਅਤੇ ਫ਼ੋਟੋਆਂ ਨੂੰ ਇਕੱਠੇ ਰੱਖੋ।';

  @override
  String get onboardingUnderstandEyebrow => '02 / ਸਮਝੋ';

  @override
  String get onboardingUnderstandTitle => 'ਨੰਬਰ,\nਨੇ ਪੜ੍ਹਨਾ ਆਸਾਨ ਬਣਾ ਦਿੱਤਾ ਹੈ।';

  @override
  String get onboardingUnderstandBody =>
      'ਆਪਣੀ ਰਿਪੋਰਟ ਤੋਂ ਹਰੇਕ ਟੈਸਟ, ਇਸਦੀ ਇਕਾਈ ਅਤੇ ਅੰਤਰਾਲ ਦੇਖੋ। ਕਿਸੇ ਵੀ ਸਮੇਂ ਅਸਲੀ ਦੀ ਜਾਂਚ ਕਰੋ।';

  @override
  String get onboardingTrackEyebrow => '03 / ਟ੍ਰੈਕ ਅਤੇ ਸਾਂਝਾ ਕਰੋ';

  @override
  String get onboardingTrackTitle => 'ਤਬਦੀਲੀਆਂ ਦੇਖੋ।\nਸੰਦਰਭ ਸਾਂਝਾ ਕਰੋ।';

  @override
  String get onboardingTrackBody =>
      'ਸਮੇਂ ਦੇ ਨਾਲ ਨਤੀਜਿਆਂ ਦੀ ਪਾਲਣਾ ਕਰੋ ਅਤੇ ਚੁਣੋ ਕਿ ਤੁਹਾਡਾ ਡਾਕਟਰ ਕੀ ਦੇਖ ਸਕਦਾ ਹੈ।';

  @override
  String get onboardingNext => 'ਅੱਗੇ';

  @override
  String get onboardingGetStarted => 'ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get uiSupportRequestSent => 'ਸਹਾਇਤਾ ਬੇਨਤੀ ਭੇਜੀ ਗਈ।';

  @override
  String get uiTestNameAndResultAreRequired =>
      'ਟੈਸਟ ਦਾ ਨਾਮ ਅਤੇ ਨਤੀਜਾ ਲੋੜੀਂਦਾ ਹੈ।';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD ਫਾਰਮੈਟ ਵਿੱਚ ਇੱਕ ਵੈਧ ਸੰਗ੍ਰਹਿ ਮਿਤੀ ਦੀ ਵਰਤੋਂ ਕਰੋ।';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'ਇਸ ਸੁਧਾਰ ਨੂੰ ਸੁਰੱਖਿਅਤ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiReportsUnavailable => 'ਰਿਪੋਰਟਾਂ ਉਪਲਬਧ ਨਹੀਂ';

  @override
  String get uiTryAgain042c86 => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get uiTwoReportsAreNeeded => 'ਦੋ ਰਿਪੋਰਟਾਂ ਦੀ ਲੋੜ ਹੈ';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'ਨਤੀਜਿਆਂ ਦੀ ਤੁਲਨਾ ਕਰਨ ਲਈ ਇਸ ਪ੍ਰੋਫਾਈਲ ਲਈ ਇੱਕ ਪੁਰਾਣੀ ਰਿਪੋਰਟ ਸ਼ਾਮਲ ਕਰੋ।';

  @override
  String get uiCannotCompareYet => 'ਅਜੇ ਤੁਲਨਾ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕਦੀ';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'ਇਹਨਾਂ ਰਿਪੋਰਟਾਂ ਵਿੱਚ ਤੁਲਨਾ ਲਈ ਕੋਈ ਮੇਲ ਖਾਂਦੇ ਨਤੀਜੇ ਉਪਲਬਧ ਨਹੀਂ ਹਨ।';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'ਰਿਪੋਰਟਾਂ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiCouldNotOpenPhotosOrCamera =>
      'ਫੋਟੋਆਂ ਜਾਂ ਕੈਮਰਾ ਖੋਲ੍ਹਿਆ ਨਹੀਂ ਜਾ ਸਕਿਆ।';

  @override
  String get uiCouldNotOpenCamera => 'ਕੈਮਰਾ ਖੋਲ੍ਹਿਆ ਨਹੀਂ ਜਾ ਸਕਿਆ।';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'ਇਹ ਪੰਨੇ ਤਿਆਰ ਨਹੀਂ ਕੀਤੇ ਜਾ ਸਕੇ। ਇੱਕ ਨਾ-ਪੜ੍ਹਨਯੋਗ ਪੰਨਾ ਦੁਬਾਰਾ ਲਓ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiCouldNotAdjustThisPage =>
      'ਇਸ ਪੰਨੇ ਨੂੰ ਵਿਵਸਥਿਤ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ।';

  @override
  String get uiNoChartableResultYet => 'ਹਾਲੇ ਤੱਕ ਕੋਈ ਚਾਰਟੇਬਲ ਨਤੀਜਾ ਨਹੀਂ ਹੈ';

  @override
  String get uiProfiles => 'ਪ੍ਰੋਫਾਈਲਾਂ';

  @override
  String get uiReports => 'ਰਿਪੋਰਟਾਂ';

  @override
  String get uiShareLinks => 'ਲਿੰਕ ਸਾਂਝੇ ਕਰੋ';

  @override
  String get uiAIChat => 'ਏਆਈ ਚੈਟ';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'ਇੰਟਾਈਟਲਮੈਂਟ ਸਾਰਾਂਸ਼ ਨੂੰ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'ਬਿਲਿੰਗ ਸਥਿਤੀ ਨੂੰ ਤਾਜ਼ਾ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'ਰਸੀਦ ਡਾਊਨਲੋਡ ਜਲਦੀ ਹੀ ਉਪਲਬਧ ਹੋਵੇਗੀ।';

  @override
  String get uiSubtotal => 'ਉਪ-ਯੋਗ';

  @override
  String get uiDiscount => 'ਛੂਟ';

  @override
  String get uiTotal => 'ਕੁੱਲ';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'ਕ੍ਰੈਡਿਟ ਪੈਕ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'ਇੱਕ ਭੁਗਤਾਨ ਕੈਪਚਰ ਲੰਬਿਤ ਹੈ। ਇੱਕ ਹੋਰ ਚੈੱਕਆਉਟ ਸ਼ੁਰੂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਸਥਿਤੀ ਨੂੰ ਤਾਜ਼ਾ ਕਰੋ।';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'ਕ੍ਰੈਡਿਟ ਸਫਲਤਾਪੂਰਵਕ ਲਾਗੂ ਕੀਤੇ ਗਏ ਸਨ।';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ਆਰਡਰ ਬਣਾਉਣ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'ਭੁਗਤਾਨ ਪ੍ਰਾਪਤ ਹੋਇਆ। ਕ੍ਰੈਡਿਟ ਜੋੜਨ ਤੋਂ ਪਹਿਲਾਂ ਸਰਵਰ ਮੇਲ-ਮਿਲਾਪ ਦੀ ਉਡੀਕ ਕਰ ਰਿਹਾ ਹੈ।';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'ਭੁਗਤਾਨ ਅਸਫਲ ਰਿਹਾ। ਤਿਆਰ ਹੋਣ \'ਤੇ ਤੁਸੀਂ ਚੈੱਕਆਊਟ ਦੀ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get uiPaymentFailedTryAgain => 'ਭੁਗਤਾਨ ਅਸਫਲ ਰਿਹਾ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiCreditsAdded => 'ਕ੍ਰੈਡਿਟ ਜੋੜਿਆ ਗਿਆ!';

  @override
  String get uiPromoCodeApplied => 'ਪ੍ਰੋਮੋ ਕੋਡ ਲਾਗੂ ਕੀਤਾ ਗਿਆ।';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'ਭੁਗਤਾਨ ਪ੍ਰਾਪਤ ਹੋਇਆ, ਪਰ ਇਸ ਆਰਡਰ ਦੀ ਸਮੀਖਿਆ ਲੰਬਿਤ ਹੈ।';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'ਮੇਲ-ਮਿਲਾਪ ਦੌਰਾਨ ਭੁਗਤਾਨ ਅਸਫਲ ਰਿਹਾ।';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'ਭੁਗਤਾਨ ਦੀ ਪੁਸ਼ਟੀ ਕੀਤੀ ਗਈ। ਸਰਵਰ ਮੇਲ-ਮਿਲਾਪ ਅਜੇ ਬਾਕੀ ਹੈ।';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'ਭੁਗਤਾਨ ਦੀ ਪੁਸ਼ਟੀ ਕੀਤੀ ਗਈ। ਮੇਲ-ਮਿਲਾਪ ਲੰਬਿਤ ਹੈ, ਕਿਰਪਾ ਕਰਕੇ ਜਲਦੀ ਹੀ ਤਾਜ਼ਾ ਕਰੋ।';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'ਭੁਗਤਾਨ ਪ੍ਰਾਪਤ ਹੋ ਗਿਆ ਹੈ ਪਰ ਪੁਸ਼ਟੀਕਰਨ ਅਜੇ ਬਾਕੀ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਸਥਿਤੀ ਨੂੰ ਤਾਜ਼ਾ ਕਰੋ।';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'ਯੋਜਨਾਵਾਂ ਨੂੰ ਲੋਡ ਕਰਨਾ ਅਸਫਲ ਰਿਹਾ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'ਗਾਹਕੀ ਬਣਾਉਣ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiSubscriptionFailedTryAgain => 'ਗਾਹਕੀ ਅਸਫਲ ਰਹੀ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiPlanUpgraded => 'ਪਲਾਨ ਅੱਪਗ੍ਰੇਡ ਕੀਤਾ ਗਿਆ!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'ਭੁਗਤਾਨ ਪ੍ਰਾਪਤ ਹੋਇਆ ਪਰ ਪੁਸ਼ਟੀਕਰਨ ਅਸਫਲ ਰਿਹਾ। ਯੋਜਨਾ ਨੂੰ ਜਲਦੀ ਹੀ ਅਪਗ੍ਰੇਡ ਕੀਤਾ ਜਾਵੇਗਾ।';

  @override
  String get uiNotificationsUnavailable => 'ਸੂਚਨਾਵਾਂ ਉਪਲਬਧ ਨਹੀਂ ਹਨ';

  @override
  String get uiAllQuietForNow => 'ਹੁਣ ਲਈ ਸਭ ਚੁੱਪ.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'ਕੁਝ ਨਵਾਂ ਹੋਣ \'ਤੇ ਰਿਪੋਰਟ ਅੱਪਡੇਟ ਅਤੇ ਸ਼ੇਅਰਿੰਗ ਰੀਮਾਈਂਡਰ ਇੱਥੇ ਦਿਖਾਈ ਦੇਣਗੇ।';

  @override
  String get uiNoUnreadUpdates => 'ਕੋਈ ਨਾ-ਪੜ੍ਹੇ ਅੱਪਡੇਟ';

  @override
  String get uiYouReAllCaughtUp => 'ਤੁਸੀਂ ਸਾਰੇ ਫੜੇ ਗਏ ਹੋ।';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'ਸੂਚਨਾਵਾਂ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਨੈਕਟ ਹੋਣ \'ਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiManageSharedLinks => 'ਸ਼ੇਅਰ ਕੀਤੇ ਲਿੰਕ ਪ੍ਰਬੰਧਿਤ ਕਰੋ';

  @override
  String get uiExportYourData => 'ਆਪਣਾ ਡਾਟਾ ਐਕਸਪੋਰਟ ਕਰੋ';

  @override
  String get uiReadThePrivacyPolicy => 'ਗੋਪਨੀਯਤਾ ਨੀਤੀ ਪੜ੍ਹੋ';

  @override
  String get uiTermsOfUse => 'ਵਰਤੋਂ ਦੀਆਂ ਸ਼ਰਤਾਂ';

  @override
  String get uiPrivacyPolicy => 'ਗੋਪਨੀਯਤਾ ਨੀਤੀ';

  @override
  String get uiDateOfBirthOptional => 'ਜਨਮ ਮਿਤੀ, ਵਿਕਲਪਿਕ';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'ਰਿਸ਼ਤਾ 50 ਜਾਂ ਘੱਟ ਅੱਖਰਾਂ ਦਾ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ।';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'ਪ੍ਰੋਫਾਈਲ ਨੂੰ ਸੁਰੱਖਿਅਤ ਕਰਨਾ ਅਸਫਲ ਰਿਹਾ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiReferralsUnavailable => 'ਹਵਾਲੇ ਉਪਲਬਧ ਨਹੀਂ ਹਨ';

  @override
  String get uiYourRewards => 'ਤੁਹਾਡੇ ਇਨਾਮ';

  @override
  String get uiReferralProgress => 'ਰੈਫਰਲ ਪ੍ਰਗਤੀ';

  @override
  String get uiFriendsReferred => 'ਦੋਸਤਾਂ ਨੇ ਰੈਫਰ ਕੀਤਾ';

  @override
  String get uiCreditsEarned => 'ਕ੍ਰੈਡਿਟ ਕਮਾਇਆ';

  @override
  String get uiPendingRewards => 'ਬਕਾਇਆ ਇਨਾਮ';

  @override
  String get uiBlockedRewards => 'ਬਲਾਕ ਕੀਤੇ ਇਨਾਮ';

  @override
  String get uiInviteeBonus => 'ਸੱਦਾ ਦੇਣ ਵਾਲਾ ਬੋਨਸ';

  @override
  String get uiFirstAnalysis => 'ਪਹਿਲਾ ਵਿਸ਼ਲੇਸ਼ਣ';

  @override
  String get uiFirstPurchase => 'ਪਹਿਲੀ ਖਰੀਦਦਾਰੀ';

  @override
  String get uiMonthlyCap => 'ਮਹੀਨਾਵਾਰ ਕੈਪ';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'ਰੈਫ਼ਰਲ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiReferralCodeCopied => 'ਰੈਫਰਲ ਕੋਡ ਕਾਪੀ ਕੀਤਾ ਗਿਆ।';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'ਆਪਣੇ ਈਮੇਲ ਲਿੰਕ ਤੋਂ ਰੀਸੈਟ ਟੋਕਨ ਦਾਖਲ ਕਰੋ';

  @override
  String get uiEnterYourNewPassword => 'ਆਪਣਾ ਨਵਾਂ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'ਪਾਸਵਰਡ ਰੀਸੈਟ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਇੱਕ ਨਵੇਂ ਲਿੰਕ ਲਈ ਬੇਨਤੀ ਕਰੋ।';

  @override
  String get uiEnterYourEmailAddress => 'ਆਪਣਾ ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'ਰੀਸੈੱਟ ਲਿੰਕ ਭੇਜਣ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiFailedToLoadSessions => 'ਸੈਸ਼ਨਾਂ ਨੂੰ ਲੋਡ ਕਰਨਾ ਅਸਫਲ ਰਿਹਾ।';

  @override
  String get uiFailedToRevokeSession => 'ਸੈਸ਼ਨ ਨੂੰ ਰੱਦ ਕਰਨਾ ਅਸਫਲ ਰਿਹਾ।';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'ਪਾਸਵਰਡ ਬਦਲਣ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'ਡਿਵਾਈਸ ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ ਅਤੇ Doclyzer ਲਈ ਸੂਚਨਾਵਾਂ ਦੀ ਆਗਿਆ ਦਿਓ।';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'ਰਿਪੋਰਟਾਂ ਲੋਡ ਨਹੀਂ ਕੀਤੀਆਂ ਜਾ ਸਕੀਆਂ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'ਟੈਸਟ ਦੇ ਨਤੀਜੇ ਲੋਡ ਨਹੀਂ ਕੀਤੇ ਜਾ ਸਕੇ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'ਸ਼ੇਅਰ ਕਰਨ ਲਈ ਘੱਟੋ-ਘੱਟ ਇੱਕ ਰਿਪੋਰਟ ਚੁਣੋ।';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'ਸਾਂਝਾ ਕਰਨ ਲਈ ਘੱਟੋ-ਘੱਟ ਇੱਕ ਟੈਸਟ ਨਤੀਜਾ ਚੁਣੋ।';

  @override
  String get uiLinkCopiedToClipboard => 'ਲਿੰਕ ਕਲਿੱਪਬੋਰਡ \'ਤੇ ਕਾਪੀ ਕੀਤਾ ਗਿਆ';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'ਐਕਸੈਸ ਕੋਡ ਕਲਿੱਪਬੋਰਡ \'ਤੇ ਕਾਪੀ ਕੀਤਾ ਗਿਆ';

  @override
  String get uiOnePerson => '1 ਵਿਅਕਤੀ';

  @override
  String uiPeopleCount(String count) {
    return '$count ਲੋਕ';
  }

  @override
  String uiActionsFor(String name) {
    return '$name ਲਈ ਕਾਰਵਾਈਆਂ';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਬਦਲਣ ਵਿੱਚ ਅਸਮਰੱਥ। $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name \'ਤੇ ਬਦਲਿਆ ਗਿਆ';
  }

  @override
  String get uiAnalyzeOnePage => '1 ਪੰਨੇ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਕਰੋ';

  @override
  String uiAnalyzePages(String count) {
    return '$count ਪੰਨਿਆਂ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਕਰੋ';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'ਤੁਹਾਡੀ ਰਿਪੋਰਟ ਵਿੱਚ ਦਿਖਾਏ ਗਏ ਕ੍ਰਮ ਵਿੱਚ ਪੰਨਿਆਂ ਨੂੰ ਖਿੱਚੋ';

  @override
  String get uiCheckEveryPage => 'ਵਿਸ਼ਲੇਸ਼ਣ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਹਰ ਪੰਨੇ ਦੀ ਜਾਂਚ ਕਰੋ';

  @override
  String get uiOnePageAdded => '1 ਪੰਨਾ ਜੋੜਿਆ ਗਿਆ';

  @override
  String uiPagesAdded(String count) {
    return '$count ਪੰਨੇ ਸ਼ਾਮਲ ਕੀਤੇ ਗਏ';
  }

  @override
  String get uiReorder => 'ਮੁੜ ਕ੍ਰਮਬੱਧ ਕਰੋ';

  @override
  String uiPageNumber(String number) {
    return 'ਪੰਨਾ $number';
  }

  @override
  String uiRemovePage(String number) {
    return 'ਪੰਨਾ $number ਹਟਾਓ';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · ਪੰਨਾ $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'ਕਾਂਟ-ਛਾਂਟ ਕਿਨਾਰੇ: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count ਚੁਣੀਆਂ ਗਈਆਂ ਰਿਪੋਰਟਾਂ';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count ਚੁਣੇ ਗਏ ਟੈਸਟ ਨਤੀਜੇ';
  }

  @override
  String get uiAllCurrentFutureReports =>
      'ਸਾਰੀਆਂ ਮੌਜੂਦਾ ਅਤੇ ਭਵਿੱਖ ਦੀਆਂ ਰਿਪੋਰਟਾਂ';

  @override
  String get uiNoExpiry => 'ਕੋਈ ਮਿਆਦ ਨਹੀਂ';

  @override
  String uiExpiresDate(String date) {
    return '$date ਦੀ ਮਿਆਦ ਸਮਾਪਤ ਹੋ ਜਾਵੇਗੀ';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'ਪਹੁੰਚ ਕੋਡ ਦੀ ਲੋੜ ਹੈ। ਇਸ ਨੂੰ ਲਿੰਕ ਤੋਂ ਵੱਖਰਾ ਸਾਂਝਾ ਕਰੋ।';

  @override
  String get uiNoAccessCodeRequired => 'ਕੋਈ ਪਹੁੰਚ ਕੋਡ ਦੀ ਲੋੜ ਨਹੀਂ ਹੈ।';

  @override
  String uiExpiresColonDate(String date) {
    return 'ਮਿਆਦ ਪੁੱਗਦੀ ਹੈ: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name ਦੀਆਂ ਰਿਪੋਰਟਾਂ ਸਾਂਝੀਆਂ ਕਰੋ';
  }

  @override
  String uiProfileReports(String name) {
    return '$name ਦੀਆਂ ਰਿਪੋਰਟਾਂ';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count ਚੁਣੇ ਗਏ ਨਤੀਜੇ';
  }

  @override
  String get uiAccessCodeRequiredShort => 'ਪਹੁੰਚ ਕੋਡ ਦੀ ਲੋੜ ਹੈ';

  @override
  String uiPastLinksCount(String count) {
    return 'ਪਿਛਲੇ ਲਿੰਕ · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return 'ਮਿਆਦ ਪੁੱਗੀ $date';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'ਰੱਦ ਕੀਤਾ ਗਿਆ · $date ਬਣਾਇਆ ਗਿਆ';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum ਸਰਗਰਮ ਲਿੰਕਾਂ ਦੇ $current ਦੀ ਵਰਤੋਂ ਕਰਨਾ।';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename ਅਤੇ ਇਸਦੀ ਸਟੋਰ ਕੀਤੀ ਫਾਈਲ ਨੂੰ ਮਿਟਾਉਣਾ ਹੈ? ਇਸ ਨੂੰ ਅਣਕੀਤਾ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ।';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'ਰਿਪੋਰਟ ਨੂੰ ਮਿਟਾਉਣ ਵਿੱਚ ਅਸਮਰੱਥ: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'ਕੀ ਸਾਰੀਆਂ $count ਰਿਪੋਰਟਾਂ ਅਤੇ ਉਹਨਾਂ ਦੀਆਂ ਸਟੋਰ ਕੀਤੀਆਂ ਫਾਈਲਾਂ ਨੂੰ ਸਥਾਈ ਤੌਰ \'ਤੇ ਮਿਟਾਉਣਾ ਹੈ? ਇਸ ਨੂੰ ਅਣਕੀਤਾ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ।';
  }

  @override
  String get uiRecycleBinEmptied => 'ਰੀਸਾਈਕਲ ਬਿਨ ਖਾਲੀ ਕੀਤਾ ਗਿਆ';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted ਰਿਪੋਰਟਾਂ ਮਿਟਾਈਆਂ ਗਈਆਂ। $failed ਨੂੰ ਮਿਟਾਇਆ ਨਹੀਂ ਜਾ ਸਕਿਆ; ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'ਰੀਸਾਈਕਲ ਬਿਨ ਨੂੰ ਖਾਲੀ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'ਪ੍ਰੋਫਾਈਲ: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'ਇਕੱਤਰ ਕੀਤਾ: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'ਅੱਪਲੋਡ ਕੀਤਾ ਗਿਆ: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'ਇਸ \'ਤੇ ਮਿਟਾਇਆ ਗਿਆ: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'ਇਸ \'ਤੇ ਸਥਾਈ ਮਿਟਾਓ: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'ਬਾਕੀ ਦਿਨ: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer => 'Doclyzer ਲਈ ਐਪ ਲੌਕ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'ਐਪ ਲੌਕ ਨੂੰ ਬੰਦ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'ਆਪਣੇ ਸਿਹਤ ਰਿਕਾਰਡਾਂ ਨੂੰ ਦੇਖਣ ਲਈ ਡੌਕਲਾਈਜ਼ਰ ਨੂੰ ਅਨਲੌਕ ਕਰੋ';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'ਇੱਕ ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਇੱਕ ਡਿਫੌਲਟ ਪ੍ਰੋਫਾਈਲ ਬਣਾਓ।';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'ਆਪਣੀ ਟਾਈਮਲਾਈਨ ਦੇਖਣ ਤੋਂ ਪਹਿਲਾਂ ਇੱਕ ਡਿਫੌਲਟ ਪ੍ਰੋਫਾਈਲ ਬਣਾਓ।';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'ਇਸ ਸਮੇਂ ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ।';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'ਫਿਲਹਾਲ ਅੱਪਲੋਡ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ ਕਿਉਂਕਿ ਪ੍ਰੋਫਾਈਲ ਡਾਟਾ ਲੋਡ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਯਕੀਨੀ ਬਣਾਓ ਕਿ API ਸਰਵਰ ਚੱਲ ਰਿਹਾ ਹੈ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'ਇਸ ਸਮੇਂ ਟਾਈਮਲਾਈਨ ਨੂੰ ਖੋਲ੍ਹਿਆ ਨਹੀਂ ਜਾ ਸਕਦਾ ਕਿਉਂਕਿ ਪ੍ਰੋਫਾਈਲ ਡਾਟਾ ਲੋਡ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਯਕੀਨੀ ਬਣਾਓ ਕਿ API ਸਰਵਰ ਚੱਲ ਰਿਹਾ ਹੈ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'ਇਸ ਸਮੇਂ ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'ਸ਼ੇਅਰਿੰਗ ਲਿੰਕ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiPasswordChanged => 'ਪਾਸਵਰਡ ਬਦਲਿਆ ਗਿਆ';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'ਉਸ ਰਿਪੋਰਟ ਨੂੰ ਖੋਲ੍ਹਣ ਵਿੱਚ ਅਸਮਰੱਥ। ਰਿਪੋਰਟ ਲਾਇਬ੍ਰੇਰੀ ਦੀ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'ਜਦੋਂ ਤੁਹਾਡਾ ਖਾਤਾ ਸਮੀਖਿਆ ਅਧੀਨ ਹੈ ਤਾਂ ਇਹ ਕਾਰਵਾਈ ਅਸਥਾਈ ਤੌਰ \'ਤੇ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'ਇਸ ਭਾਗ ਨੂੰ ਖੋਲ੍ਹਣ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiAppLockIsUnavailable => 'ਐਪ ਲੌਕ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get uiDoclyzerIsLocked => 'ਡੌਕਲਾਈਜ਼ਰ ਲਾਕ ਹੈ';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'ਸੁਰੱਖਿਅਤ ਕੀਤੀ ਐਪ ਲੌਕ ਸੈਟਿੰਗ ਨੂੰ ਪੜ੍ਹਿਆ ਨਹੀਂ ਜਾ ਸਕਿਆ। ਜਾਰੀ ਰੱਖਣ ਲਈ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'ਜਾਰੀ ਰੱਖਣ ਲਈ ਆਪਣੇ ਡਿਵਾਈਸ ਪਾਸਕੋਡ ਜਾਂ ਬਾਇਓਮੈਟ੍ਰਿਕਸ ਦੀ ਵਰਤੋਂ ਕਰੋ।';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'ਜਦੋਂ ਤੁਹਾਡਾ ਖਾਤਾ ਸਮੀਖਿਆ ਅਧੀਨ ਹੁੰਦਾ ਹੈ ਤਾਂ ਅੱਪਲੋਡ ਅਸਥਾਈ ਤੌਰ \'ਤੇ ਉਪਲਬਧ ਨਹੀਂ ਹੁੰਦੇ ਹਨ।';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'ਇੱਕ ਅੱਪਲੋਡ ਸ਼ੁਰੂ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiJustNow => 'ਹੁਣੇ ਹੀ';

  @override
  String get uiAdditionalDetails => 'ਵਾਧੂ ਵੇਰਵੇ:';

  @override
  String get uiSaveCorrection => 'ਸੁਧਾਰ ਸੰਭਾਲੋ';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'ਫ਼ਾਈਲਾਂ ਖੋਲ੍ਹੀਆਂ ਨਹੀਂ ਜਾ ਸਕੀਆਂ। ਪਹੁੰਚ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'ਕੈਮਰਾ ਖੋਲ੍ਹਿਆ ਨਹੀਂ ਜਾ ਸਕਿਆ। ਇਜਾਜ਼ਤ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'ਫੋਟੋਆਂ ਨੂੰ ਖੋਲ੍ਹਿਆ ਨਹੀਂ ਜਾ ਸਕਿਆ। ਇਜਾਜ਼ਤ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'ਚੁਣੀ ਗਈ ਫ਼ਾਈਲ ਤੱਕ ਪਹੁੰਚ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕੀ।';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'ਚੁਣੀ ਗਈ ਫ਼ਾਈਲ ਤੱਕ ਪਹੁੰਚ ਨਹੀਂ ਕੀਤੀ ਜਾ ਸਕੀ';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'ਕਨੈਕਸ਼ਨ ਟੁੱਟ ਗਿਆ। ਹੋ ਸਕਦਾ ਹੈ ਕਿ ਅੱਪਲੋਡ ਸਰਵਰ ਤੱਕ ਪਹੁੰਚ ਗਿਆ ਹੋਵੇ। ਉਸੇ ਫਾਈਲ ਨੂੰ ਸੁਰੱਖਿਅਤ ਢੰਗ ਨਾਲ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiCouldNotLoadExistingReport =>
      'ਮੌਜੂਦਾ ਰਿਪੋਰਟ ਨੂੰ ਲੋਡ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ';

  @override
  String get uiAddingTo => 'ਵਿੱਚ ਜੋੜ ਰਿਹਾ ਹੈ';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'ਕੁਝ ਨਤੀਜਿਆਂ ਦੀ ਸਮੀਖਿਆ ਦੀ ਲੋੜ ਹੈ। ਤੁਹਾਡੀ ਅਸਲ ਰਿਪੋਰਟ ਨੂੰ ਸੁਰੱਖਿਅਤ ਕੀਤਾ ਗਿਆ ਹੈ।';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'ਅਸੀਂ ਇਸ ਫਾਰਮੈਟ ਨੂੰ ਨਹੀਂ ਪੜ੍ਹ ਸਕੇ। ਤੁਹਾਡੀ ਫਾਈਲ ਸੁਰੱਖਿਅਤ ਹੈ।';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'ਰਿਪੋਰਟ ਸਫਲਤਾਪੂਰਵਕ ਪਾਰਸ ਕੀਤੀ ਗਈ। ਨਤੀਜੇ ਅਤੇ ਰੁਝਾਨ ਉਪਲਬਧ ਹਨ।';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'ਤੁਹਾਡੀ ਰਿਪੋਰਟ ਦਾ ਅਜੇ ਵੀ ਵਿਸ਼ਲੇਸ਼ਣ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ। ਇਸਦੀ ਸਥਿਤੀ ਦੀ ਜਾਂਚ ਕਰਨ ਲਈ ਇਸਨੂੰ ਖੋਲ੍ਹੋ।';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'ਪ੍ਰੋਸੈਸਿੰਗ ਬੰਦ ਹੋ ਗਈ। ਤੁਹਾਡੀ ਫਾਈਲ ਸੁਰੱਖਿਅਤ ਹੈ। ਤੁਸੀਂ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'ਕੋਈ ਐਕਸਟਰੈਕਟ ਕੀਤੇ ਟੈਸਟ ਮੁੱਲ ਸ਼ਾਮਲ ਨਹੀਂ ਕੀਤੇ ਗਏ ਸਨ। ਤੁਸੀਂ ਅਜੇ ਵੀ ਦਸਤਾਵੇਜ਼ ਨੂੰ ਖੋਲ੍ਹ ਅਤੇ ਸਾਂਝਾ ਕਰ ਸਕਦੇ ਹੋ। ਤੁਹਾਡੇ ਰੁਝਾਨਾਂ ਵਿੱਚ ਕੋਈ ਬਦਲਾਅ ਨਹੀਂ ਹੈ।';

  @override
  String get uiYourOriginalIsSaved => 'ਤੁਹਾਡਾ ਮੂਲ ਸੁਰੱਖਿਅਤ ਹੈ।';

  @override
  String get uiInitialUpload => 'ਸ਼ੁਰੂਆਤੀ ਅੱਪਲੋਡ';

  @override
  String get uiParsedSuccessfully => 'ਸਫਲਤਾਪੂਰਵਕ ਪਾਰਸ ਕੀਤਾ ਗਿਆ';

  @override
  String get uiParsingFailed => 'ਪਾਰਸ ਕਰਨਾ ਅਸਫਲ ਰਿਹਾ';

  @override
  String get uiExtractionIncomplete => 'ਕੱਢਣਾ ਅਧੂਰਾ';

  @override
  String get uiTransientFailure => 'ਅਸਥਾਈ ਅਸਫਲਤਾ';

  @override
  String get uiTerminalFailure => 'ਟਰਮੀਨਲ ਅਸਫਲਤਾ';

  @override
  String get uiFailedToLoadAttemptHistory =>
      'ਕੋਸ਼ਿਸ਼ ਇਤਿਹਾਸ ਨੂੰ ਲੋਡ ਕਰਨ ਵਿੱਚ ਅਸਫਲ';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'ਇਸ ਰਿਪੋਰਟ ਦੀ ਫ਼ਾਈਲ ਹੁਣ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।';

  @override
  String get uiCompareResults => 'ਨਤੀਜਿਆਂ ਦੀ ਤੁਲਨਾ ਕਰੋ';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'ਕੋਈ ਅੰਤਰ ਨਹੀਂ ਗਿਣਿਆ ਗਿਆ। ਅਨੁਕੂਲਤਾ ਦੀ ਪੁਸ਼ਟੀ ਦੀ ਲੋੜ ਹੈ।';

  @override
  String get uiUnitNotRecorded => 'ਯੂਨਿਟ ਦਰਜ ਨਹੀਂ ਹੈ';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'ਇਹਨਾਂ ਰਿਪੋਰਟਾਂ ਵਿੱਚ ਕੋਈ ਸੰਖਿਆਤਮਕ ਬਦਲਾਅ ਨਹੀਂ ਹੈ।';

  @override
  String get uiUnableToRestore => 'ਰੀਸਟੋਰ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ:';

  @override
  String get uiEnterAGiftVoucherCode => 'ਇੱਕ ਤੋਹਫ਼ਾ ਵਾਊਚਰ ਕੋਡ ਦਾਖਲ ਕਰੋ।';

  @override
  String get uiApplyVoucher => 'ਵਾਊਚਰ ਲਾਗੂ ਕਰੋ';

  @override
  String get uiNotAvailable => 'ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get uiViewReceipt => 'ਰਸੀਦ ਦੇਖੋ';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'ਗਿਫਟ ​​ਵਾਊਚਰ ਅਵੈਧ ਹੈ ਜਾਂ ਪਹਿਲਾਂ ਹੀ ਰੀਡੀਮ ਕੀਤਾ ਗਿਆ ਹੈ।';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'ਗਿਫਟ ​​ਵਾਊਚਰ ਪਹਿਲਾਂ ਹੀ ਰੀਡੀਮ ਕੀਤਾ ਜਾ ਚੁੱਕਾ ਹੈ।';

  @override
  String get uiGiftVoucherHasBeenVoided =>
      'ਗਿਫਟ ​​ਵਾਊਚਰ ਨੂੰ ਰੱਦ ਕਰ ਦਿੱਤਾ ਗਿਆ ਹੈ।';

  @override
  String get uiGiftVoucherHasExpired => 'ਗਿਫਟ ​​ਵਾਊਚਰ ਦੀ ਮਿਆਦ ਪੁੱਗ ਗਈ ਹੈ।';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'ਇਸ ਤੋਹਫ਼ੇ ਵਾਊਚਰ ਨੂੰ ਰੀਡੀਮ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ।';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'ਇਸ ਤੋਹਫ਼ੇ ਵਾਊਚਰ ਨੂੰ ਰੀਡੀਮ ਕਰਨ ਵਿੱਚ ਅਸਮਰੱਥ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiEnterAPromoCodeToApply =>
      'ਅਪਲਾਈ ਕਰਨ ਲਈ ਇੱਕ ਪ੍ਰੋਮੋ ਕੋਡ ਦਾਖਲ ਕਰੋ।';

  @override
  String get uiPromoCodeNotFound => 'ਪ੍ਰੋਮੋ ਕੋਡ ਨਹੀਂ ਮਿਲਿਆ।';

  @override
  String get uiPromoCodeIsInactive => 'ਪ੍ਰੋਮੋ ਕੋਡ ਅਕਿਰਿਆਸ਼ੀਲ ਹੈ।';

  @override
  String get uiPromoCodeHasExpired => 'ਪ੍ਰੋਮੋ ਕੋਡ ਦੀ ਮਿਆਦ ਪੁੱਗ ਗਈ ਹੈ।';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'ਇਸ ਪੈਕ \'ਤੇ ਪ੍ਰੋਮੋ ਕੋਡ ਲਾਗੂ ਨਹੀਂ ਹੁੰਦਾ ਹੈ।';

  @override
  String get uiPromoCodeUsageLimitReached =>
      'ਪ੍ਰੋਮੋ ਕੋਡ ਦੀ ਵਰਤੋਂ ਸੀਮਾ ਪੂਰੀ ਹੋ ਗਈ ਹੈ।';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'ਤੁਸੀਂ ਪਹਿਲਾਂ ਹੀ ਇਸ ਪ੍ਰੋਮੋ ਕੋਡ ਦੀ ਵਰਤੋਂ ਕਰ ਚੁੱਕੇ ਹੋ।';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'ਪ੍ਰੋਮੋ ਕੋਡ ਲਾਗੂ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'ਇਸ ਆਰਡਰ ਨੂੰ ਕ੍ਰੈਡਿਟ ਜੋੜਨ ਤੋਂ ਪਹਿਲਾਂ ਸਮੀਖਿਆ ਲਈ ਫਲੈਗ ਕੀਤਾ ਗਿਆ ਸੀ।';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'ਮੇਲ-ਮਿਲਾਪ ਦੌਰਾਨ ਭੁਗਤਾਨ ਅਸਫਲ ਰਿਹਾ। ਤੁਸੀਂ ਸੁਰੱਖਿਅਤ ਢੰਗ ਨਾਲ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get uiAwaitingCapture => 'ਕੈਪਚਰ ਦੀ ਉਡੀਕ ਕਰ ਰਿਹਾ ਹੈ';

  @override
  String get uiLastPaymentFailed => 'ਪਿਛਲਾ ਭੁਗਤਾਨ ਅਸਫਲ ਰਿਹਾ';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'ਤੁਸੀਂ ਸੁਰੱਖਿਅਤ ਢੰਗ ਨਾਲ ਚੈੱਕਆਉਟ ਦੀ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'ਪ੍ਰੋਮੋ ਕੋਡ ਅਜੇ ਤੱਕ ਗਾਹਕੀਆਂ ਲਈ ਸਮਰਥਿਤ ਨਹੀਂ ਹਨ।';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'ਨਿਰਯਾਤ ਨੂੰ ਡਾਊਨਲੋਡ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'ਅਸਲੀ ਰਿਪੋਰਟਾਂ ਜਾਂ ਟੈਸਟ ਦੇ ਨਤੀਜੇ ਚੁਣੋ।';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'ਨਿਰਯਾਤ ਦੀ ਬੇਨਤੀ ਕੀਤੀ। ਤਾਜ਼ਾ ਕਰਨ ਲਈ \"ਸਥਿਤੀ ਦੀ ਜਾਂਚ ਕਰੋ\" \'ਤੇ ਟੈਪ ਕਰੋ।';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'ਨਿਰਯਾਤ ਦੀ ਬੇਨਤੀ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'ਨਿਰਯਾਤ ਤਿਆਰ ਹੈ। ਡਾਊਨਲੋਡ URL ਉਪਲਬਧ ਹੈ।';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'ਨਿਰਯਾਤ ਸਥਿਤੀ ਦੀ ਜਾਂਚ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'ਖਾਤਾ ਬੰਦ ਕਰਨਾ ਅਸਫਲ ਰਿਹਾ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiPrepareExport => 'ਨਿਰਯਾਤ ਤਿਆਰ ਕਰੋ';

  @override
  String get uiSaveExport => 'ਨਿਰਯਾਤ ਨੂੰ ਸੰਭਾਲੋ';

  @override
  String get uiPrepareExportAgain => 'ਨਿਰਯਾਤ ਨੂੰ ਦੁਬਾਰਾ ਤਿਆਰ ਕਰੋ';

  @override
  String get uiAllDates => 'ਸਾਰੀਆਂ ਤਾਰੀਖਾਂ';

  @override
  String get uiPreparingAccountDetails => 'ਖਾਤੇ ਦੇ ਵੇਰਵੇ ਤਿਆਰ ਕੀਤੇ ਜਾ ਰਹੇ ਹਨ';

  @override
  String get uiFamilyMemberProfiles => 'ਪਰਿਵਾਰਕ ਮੈਂਬਰ ਪ੍ਰੋਫਾਈਲ';

  @override
  String get uiUploadedReports => 'ਅੱਪਲੋਡ ਕੀਤੀਆਂ ਰਿਪੋਰਟਾਂ';

  @override
  String get uiDownloadReady => 'ਡਾਊਨਲੋਡ ਤਿਆਰ ਹੈ';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਸੂਚਨਾਵਾਂ ਦੀ ਰਿਪੋਰਟ ਕਰੋ';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'ਡਿਵਾਈਸ ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੀਆਂ ਗਈਆਂ। Doclyzer ਲਈ ਸੂਚਨਾਵਾਂ ਦੀ ਇਜਾਜ਼ਤ ਦਿਓ, ਫਿਰ ਇੱਥੇ ਵਾਪਸ ਜਾਓ।';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'ਸੂਚਨਾਵਾਂ ਅਜੇ ਵੀ ਬੰਦ ਹਨ। ਉਹਨਾਂ ਨੂੰ ਡਿਵਾਈਸ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਰਿਪੋਰਟ ਅੱਪਡੇਟ ਪ੍ਰਾਪਤ ਕਰਨ ਦਿਓ।';

  @override
  String get uiPreferencesSaved => 'ਤਰਜੀਹਾਂ ਰੱਖਿਅਤ ਕੀਤੀਆਂ ਗਈਆਂ';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'ਤੁਹਾਡੀ ਖਾਤਾ ਚੋਣ ਸੁਰੱਖਿਅਤ ਕੀਤੀ ਗਈ ਸੀ, ਪਰ ਇਸ ਡਿਵਾਈਸ ਨੇ ਮਾਰਕੀਟਿੰਗ ਪੁਸ਼ ਲਈ ਰਜਿਸਟਰ ਕਰਨਾ ਪੂਰਾ ਨਹੀਂ ਕੀਤਾ। ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਮਾਰਕੀਟਿੰਗ ਬਲੌਕ ਰਹਿੰਦੀ ਹੈ; ਸੂਚਨਾ ਅਨੁਮਤੀ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਸੁਰੱਖਿਅਤ ਕਰਨ ਦੀ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'ਤੁਹਾਡੀ ਖਾਤਾ ਚੋਣ ਸੁਰੱਖਿਅਤ ਕੀਤੀ ਗਈ ਸੀ। ਇਹ ਡਿਵਾਈਸ ਅਜੇ ਤੱਕ ਆਪਣੀ ਸਥਾਨਕ ਤਰਜੀਹ ਦੀ ਪੁਸ਼ਟੀ ਨਹੀਂ ਕਰ ਸਕੀ, ਪਰ ਖਾਤਾ ਪੱਧਰ \'ਤੇ ਮਾਰਕੀਟਿੰਗ ਬਲੌਕ ਰਹਿੰਦੀ ਹੈ।';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'ਤੁਹਾਡੀ ਖਾਤਾ ਚੋਣ ਸੁਰੱਖਿਅਤ ਕੀਤੀ ਗਈ ਸੀ, ਪਰ ਇਹ ਡਿਵਾਈਸ ਮਾਰਕੀਟਿੰਗ ਪੁਸ਼ ਨੂੰ ਸਮਰੱਥ ਨਹੀਂ ਕਰ ਸਕਿਆ। ਸੂਚਨਾ ਅਨੁਮਤੀ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'ਸੰਭਾਲਣ ਵਿੱਚ ਬਹੁਤ ਸਮਾਂ ਲੱਗਿਆ। ਆਪਣੇ ਕਨੈਕਸ਼ਨ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiReportReadyForReview => 'ਰਿਪੋਰਟ ਸਮੀਖਿਆ ਲਈ ਤਿਆਰ ਹੈ';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'ਜਾਣੋ ਕਿ ਤੁਹਾਡੇ ਨਤੀਜੇ ਕਦੋਂ ਦੇਖਣ ਲਈ ਤਿਆਰ ਹਨ।';

  @override
  String get uiUploadUpdates => 'ਅੱਪਡੇਟ ਅੱਪਲੋਡ ਕਰੋ';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'ਜੇਕਰ ਕਿਸੇ ਅੱਪਲੋਡ ਨੂੰ ਧਿਆਨ ਦੇਣ ਦੀ ਲੋੜ ਹੈ ਤਾਂ ਸੁਨੇਹਾ ਪ੍ਰਾਪਤ ਕਰੋ।';

  @override
  String get uiSharedLinkReminders => 'ਸ਼ੇਅਰ ਕੀਤੇ ਲਿੰਕ ਰੀਮਾਈਂਡਰ';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'ਸੁਣੋ ਜਦੋਂ ਲਿੰਕ ਦੀ ਮਿਆਦ ਖਤਮ ਹੋਣ ਵਾਲੀ ਹੈ।';

  @override
  String get uiSecurityAlerts => 'ਸੁਰੱਖਿਆ ਚੇਤਾਵਨੀਆਂ';

  @override
  String get uiRequiredForAccountSafety => 'ਖਾਤੇ ਦੀ ਸੁਰੱਖਿਆ ਲਈ ਲੋੜੀਂਦਾ ਹੈ।';

  @override
  String get uiComplianceNotices => 'ਪਾਲਣਾ ਨੋਟਿਸ';

  @override
  String get uiRequiredAccountInformation => 'ਲੋੜੀਂਦੀ ਖਾਤਾ ਜਾਣਕਾਰੀ।';

  @override
  String get uiMarketingPushNotifications => 'ਮਾਰਕੀਟਿੰਗ ਪੁਸ਼ ਸੂਚਨਾਵਾਂ';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ਪੇਸ਼ਕਸ਼ਾਂ ਅਤੇ ਘੋਸ਼ਣਾਵਾਂ। ਇਸ ਵਿਕਲਪ ਨੂੰ ਸੁਰੱਖਿਅਤ ਕਰਨਾ ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਵੀ ਲਾਗੂ ਹੁੰਦਾ ਹੈ।';

  @override
  String get uiProductUpdates => 'ਉਤਪਾਦ ਅੱਪਡੇਟ';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'ਡੌਕਲਾਈਜ਼ਰ ਬਾਰੇ ਵਿਕਲਪਿਕ ਖ਼ਬਰਾਂ।';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'ਸਰਵਰ ਨਾਲ ਕਨੈਕਟ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਦਾ ਹੈ। ਕਿਰਪਾ ਕਰਕੇ ਆਪਣੇ ਇੰਟਰਨੈਟ ਜਾਂ API ਸਰਵਰ ਦੀ ਜਾਂਚ ਕਰੋ।';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'ਜਦੋਂ ਤੁਹਾਡਾ ਖਾਤਾ ਸਮੀਖਿਆ ਅਧੀਨ ਹੁੰਦਾ ਹੈ ਤਾਂ ਪ੍ਰੋਫਾਈਲ ਅੱਪਡੇਟ ਅਸਥਾਈ ਤੌਰ \'ਤੇ ਉਪਲਬਧ ਨਹੀਂ ਹੁੰਦੇ ਹਨ।';

  @override
  String get uiUse100CharactersOrFewer => '100 ਜਾਂ ਘੱਟ ਅੱਖਰ ਵਰਤੋ';

  @override
  String get uiAddProfile => 'ਪ੍ਰੋਫਾਈਲ ਸ਼ਾਮਲ ਕਰੋ';

  @override
  String get uiCreateProfile => 'ਪ੍ਰੋਫਾਈਲ ਬਣਾਓ';

  @override
  String get uiUpdateTheirDetails => 'ਉਹਨਾਂ ਦੇ ਵੇਰਵਿਆਂ ਨੂੰ ਅਪਡੇਟ ਕਰੋ';

  @override
  String get uiWhoIsThisProfileFor => 'ਇਹ ਪ੍ਰੋਫਾਈਲ ਕਿਸ ਲਈ ਹੈ?';

  @override
  String get uiNotSelected => 'ਚੁਣਿਆ ਨਹੀਂ ਗਿਆ';

  @override
  String get uiEnterAReferralCode => 'ਇੱਕ ਰੈਫਰਲ ਕੋਡ ਦਾਖਲ ਕਰੋ।';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'ਰੈਫਰਲ ਲਾਗੂ ਕੀਤਾ ਗਿਆ। ਈਮੇਲ ਪੁਸ਼ਟੀਕਰਨ ਤੋਂ ਬਾਅਦ ਬੋਨਸ ਅਨਲੌਕ ਹੁੰਦਾ ਹੈ।';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'ਰੈਫਰਲ ਲਾਗੂ ਕੀਤਾ ਗਿਆ। ਬੋਨਸ ਕ੍ਰੈਡਿਟ ਤਿਆਰ ਹਨ।';

  @override
  String get uiApplyCode => 'ਕੋਡ ਲਾਗੂ ਕਰੋ';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'ਤੁਸੀਂ ਆਪਣਾ ਰੈਫਰਲ ਕੋਡ ਲਾਗੂ ਨਹੀਂ ਕਰ ਸਕਦੇ।';

  @override
  String get uiReferralCodeIsInvalid => 'ਰੈਫਰਲ ਕੋਡ ਅਵੈਧ ਹੈ।';

  @override
  String get uiFailedToApplyReferralCode => 'ਰੈਫਰਲ ਕੋਡ ਲਾਗੂ ਕਰਨ ਵਿੱਚ ਅਸਫਲ।';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'ਰੈਫਰਲ ਕੋਡ ਲਾਗੂ ਕਰਨ ਵਿੱਚ ਅਸਫਲ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiThisDevice => 'ਇਹ ਯੰਤਰ';

  @override
  String get uiSignedInDevice => 'ਸਾਈਨ-ਇਨ ਕੀਤਾ ਡੀਵਾਈਸ';

  @override
  String get uiUnknownDevice => 'ਅਗਿਆਤ ਡਿਵਾਈਸ';

  @override
  String get uiRevokeAndLogOut => 'ਰੱਦ ਕਰੋ ਅਤੇ ਲੌਗ ਆਊਟ ਕਰੋ';

  @override
  String get uiRevokeSessionca8440 => 'ਸੈਸ਼ਨ ਰੱਦ ਕਰੋ';

  @override
  String get uiEnterYourCurrentPassword => 'ਆਪਣਾ ਮੌਜੂਦਾ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'ਵੱਡੇ ਅੱਖਰ, ਛੋਟੇ ਅੱਖਰ, ਇੱਕ ਨੰਬਰ, ਅਤੇ ਇੱਕ ਵਿਸ਼ੇਸ਼ ਅੱਖਰ ਦੇ ਨਾਲ ਘੱਟੋ-ਘੱਟ 8 ਅੱਖਰਾਂ ਦੀ ਵਰਤੋਂ ਕਰੋ';

  @override
  String get uiChooseADifferentPassword => 'ਕੋਈ ਵੱਖਰਾ ਪਾਸਵਰਡ ਚੁਣੋ';

  @override
  String get uiNewPasswordsDoNotMatch => 'ਨਵੇਂ ਪਾਸਵਰਡ ਮੇਲ ਨਹੀਂ ਖਾਂਦੇ';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'ਤੁਸੀਂ ਸਾਰੇ ਉਪਲਬਧ ਅਪਲੋਡ ਕ੍ਰੈਡਿਟਸ ਦੀ ਵਰਤੋਂ ਕਰ ਲਈ ਹੈ। ਹੋਰ ਜੋੜਨ ਲਈ ਯੋਜਨਾ ਅਤੇ ਕ੍ਰੈਡਿਟ \'ਤੇ ਜਾਓ।';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'Doclyzer ਲਈ ਸੂਚਨਾਵਾਂ ਅਯੋਗ ਹਨ। ਰਿਪੋਰਟ-ਤਿਆਰ ਅਤੇ ਖਾਤਾ ਅੱਪਡੇਟ ਦੀ ਇਜਾਜ਼ਤ ਦੇਣ ਲਈ ਡੀਵਾਈਸ ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ। ਮਾਰਕੀਟਿੰਗ ਬੰਦ ਰਹਿੰਦੀ ਹੈ ਜਦੋਂ ਤੱਕ ਤੁਸੀਂ ਇਸਨੂੰ ਨਹੀਂ ਚੁਣਦੇ.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'ਇਸ ਡਿਵਾਈਸ \'ਤੇ ਰਿਪੋਰਟ-ਤਿਆਰ ਅਤੇ ਖਾਤਾ ਅੱਪਡੇਟ ਪ੍ਰਾਪਤ ਕਰੋ। ਮਾਰਕੀਟਿੰਗ ਬੰਦ ਰਹਿੰਦੀ ਹੈ ਜਦੋਂ ਤੱਕ ਤੁਸੀਂ ਇਸਨੂੰ ਨਹੀਂ ਚੁਣਦੇ.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'ਇਸ ਡਿਵਾਈਸ ਲਈ ਸੂਚਨਾਵਾਂ ਬੰਦ ਹਨ। ਰਿਪੋਰਟ-ਤਿਆਰ ਅਤੇ ਖਾਤਾ ਅੱਪਡੇਟ ਪ੍ਰਾਪਤ ਕਰਨ ਲਈ ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ।';

  @override
  String get uiBlockedExpiredRevoked => 'ਬਲੌਕ ਕੀਤਾ (ਮਿਆਦ ਸਮਾਪਤ/ਰੱਦ)';

  @override
  String get uiFailedToLoadPolicy => 'ਨੀਤੀ ਨੂੰ ਲੋਡ ਕਰਨਾ ਅਸਫਲ ਰਿਹਾ';

  @override
  String get uiUploadPaused => 'ਅੱਪਲੋਡ ਰੋਕਿਆ ਗਿਆ';

  @override
  String get uiSevenDays => '7 ਦਿਨ';

  @override
  String get uiThirtyDays => '30 ਦਿਨ';

  @override
  String get uiNinetyDays => '90 ਦਿਨ';

  @override
  String get uiUploadingAClearReport => 'ਸਪਸ਼ਟ ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰ ਰਿਹਾ ਹੈ';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'PDF, ਫੋਟੋਆਂ ਅਤੇ ਕਈ ਪੰਨੇ';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'ਇੱਕ PDF ਚੁਣੋ ਜਾਂ ਹਰ ਪੰਨੇ ਦੀਆਂ ਸਪਸ਼ਟ ਫੋਟੋਆਂ ਲਓ। ਪੂਰੇ ਪੰਨੇ ਨੂੰ ਫਰੇਮ ਵਿੱਚ ਰੱਖੋ, ਚਮਕ ਤੋਂ ਬਚੋ, ਅਤੇ ਵਿਸ਼ਲੇਸ਼ਣ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਪੰਨੇ ਦੇ ਕ੍ਰਮ ਦੀ ਜਾਂਚ ਕਰੋ। ਤੁਸੀਂ ਮੂਲ ਦੇ ਵਿਰੁੱਧ ਐਕਸਟਰੈਕਟ ਕੀਤੇ ਮੁੱਲਾਂ ਨੂੰ ਠੀਕ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get uiCorrectingAResult => 'ਇੱਕ ਨਤੀਜਾ ਠੀਕ ਕਰਨਾ';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'ਮੂਲ ਦੇ ਵਿਰੁੱਧ ਮੁੱਲਾਂ ਦੀ ਸਮੀਖਿਆ ਕਰੋ';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'ਇੱਕ ਰਿਪੋਰਟ ਖੋਲ੍ਹੋ, ਅਸਲੀ ਦੇ ਵਿਰੁੱਧ ਹਰੇਕ ਐਕਸਟਰੈਕਟ ਕੀਤੇ ਟੈਸਟ ਦੀ ਸਮੀਖਿਆ ਕਰੋ, ਅਤੇ ਕਿਸੇ ਵੀ ਮੁੱਲ, ਇਕਾਈ, ਜਾਂ ਤਾਰੀਖ ਨੂੰ ਠੀਕ ਕਰੋ ਜੋ ਗਲਤ ਪੜ੍ਹਿਆ ਗਿਆ ਸੀ। ਤੁਹਾਡੇ ਰੁਝਾਨਾਂ \'ਤੇ ਭਰੋਸਾ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਅਪੁਸ਼ਟ ਨਤੀਜਿਆਂ ਦੀ ਜਾਂਚ ਕੀਤੀ ਜਾਣੀ ਚਾਹੀਦੀ ਹੈ।';

  @override
  String get uiManagingFamilyRecords => 'ਪਰਿਵਾਰਕ ਰਿਕਾਰਡਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰਨਾ';

  @override
  String get uiProfilesAccessAndPermissions => 'ਪ੍ਰੋਫਾਈਲ, ਪਹੁੰਚ ਅਤੇ ਅਨੁਮਤੀਆਂ';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'ਪ੍ਰੋਫਾਈਲਾਂ ਬਣਾਉਣ ਅਤੇ ਬਦਲਣ ਲਈ ਪਰਿਵਾਰ ਦੀ ਵਰਤੋਂ ਕਰੋ। ਰਿਪੋਰਟ ਨੂੰ ਅਪਲੋਡ ਕਰਨ ਜਾਂ ਸਾਂਝਾ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਚੁਣੇ ਗਏ ਵਿਅਕਤੀ ਦੀ ਜਾਂਚ ਕਰੋ। ਸਿਰਫ਼ ਉਹਨਾਂ ਰਿਕਾਰਡਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ ਜਿਨ੍ਹਾਂ ਤੱਕ ਤੁਸੀਂ ਪਹੁੰਚ ਕਰਨ ਲਈ ਅਧਿਕਾਰਤ ਹੋ।';

  @override
  String get uiSharingAndRevokingLinks => 'ਲਿੰਕਾਂ ਨੂੰ ਸਾਂਝਾ ਕਰਨਾ ਅਤੇ ਰੱਦ ਕਰਨਾ';

  @override
  String get uiControlTheRecordsYouShare =>
      'ਤੁਹਾਡੇ ਦੁਆਰਾ ਸਾਂਝੇ ਕੀਤੇ ਗਏ ਰਿਕਾਰਡਾਂ ਨੂੰ ਨਿਯੰਤਰਿਤ ਕਰੋ';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'ਉਹ ਰਿਪੋਰਟਾਂ ਜਾਂ ਨਤੀਜੇ ਚੁਣੋ ਜੋ ਤੁਸੀਂ ਸਾਂਝਾ ਕਰਨਾ ਚਾਹੁੰਦੇ ਹੋ, ਮਿਆਦ ਪੁੱਗਣ ਅਤੇ ਐਕਸੈਸ ਕੋਡ ਦੀ ਸਮੀਖਿਆ ਕਰੋ, ਫਿਰ ਲਿੰਕ ਅਤੇ ਕੋਡ ਨੂੰ ਵੱਖਰੇ ਤੌਰ \'ਤੇ ਭੇਜੋ। ਸਾਂਝੇ ਕੀਤੇ ਲਿੰਕਾਂ ਤੋਂ ਇੱਕ ਸਰਗਰਮ ਲਿੰਕ ਨੂੰ ਰੱਦ ਕਰੋ ਜਦੋਂ ਐਕਸੈਸ ਦੀ ਲੋੜ ਨਹੀਂ ਹੈ।';

  @override
  String get uiInformationYouProvide => 'ਜਾਣਕਾਰੀ ਜੋ ਤੁਸੀਂ ਪ੍ਰਦਾਨ ਕਰਦੇ ਹੋ';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'ਖਾਤੇ ਦੇ ਵੇਰਵੇ ਅਤੇ ਪਰਿਵਾਰਕ ਪ੍ਰੋਫਾਈਲ ਇਹ ਪਛਾਣ ਕਰਦੇ ਹਨ ਕਿ ਤੁਸੀਂ ਕਿਸ ਦੇ ਰਿਕਾਰਡ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰਦੇ ਹੋ। ਅਪਲੋਡ ਕੀਤੇ ਦਸਤਾਵੇਜ਼ਾਂ ਵਿੱਚ ਸੰਵੇਦਨਸ਼ੀਲ ਸਿਹਤ ਜਾਣਕਾਰੀ ਹੋ ਸਕਦੀ ਹੈ।';

  @override
  String get uiSharingControls => 'ਸ਼ੇਅਰਿੰਗ ਕੰਟਰੋਲ';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'ਹਰੇਕ ਲਿੰਕ ਦੀ ਸਮੱਗਰੀ, ਮਿਆਦ ਅਤੇ ਪਹੁੰਚ ਸੈਟਿੰਗਾਂ ਦੀ ਸਮੀਖਿਆ ਕਰੋ। ਆਪਣੀਆਂ ਖਾਤਾ ਸੈਟਿੰਗਾਂ ਤੋਂ ਕਿਰਿਆਸ਼ੀਲ ਲਿੰਕਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ।';

  @override
  String get uiExportAndAccountChoices => 'ਨਿਰਯਾਤ ਅਤੇ ਖਾਤਾ ਵਿਕਲਪ';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'ਰਿਕਾਰਡਾਂ ਨੂੰ ਨਿਰਯਾਤ ਕਰਨ ਜਾਂ ਖਾਤਾ ਮਿਟਾਉਣ ਦੀ ਬੇਨਤੀ ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਸੈਟਿੰਗਾਂ ਦੀ ਵਰਤੋਂ ਕਰੋ। ਧਾਰਨ ਵੇਰਵੇ ਪੂਰੀ ਨੀਤੀ ਵਿੱਚ ਹਨ।';

  @override
  String get uiEducationalScope => 'ਵਿਦਿਅਕ ਦਾਇਰੇ';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'ਡੌਕਲਾਈਜ਼ਰ ਰਿਪੋਰਟਾਂ ਦਾ ਆਯੋਜਨ ਕਰਦਾ ਹੈ ਅਤੇ ਸਮੇਂ ਦੇ ਨਾਲ ਨਤੀਜੇ ਦਿਖਾਉਂਦਾ ਹੈ। ਵਿਦਿਅਕ ਸਪੱਸ਼ਟੀਕਰਨ ਡਾਕਟਰੀ ਸਲਾਹ ਜਾਂ ਨਿਦਾਨ ਨਹੀਂ ਹਨ।';

  @override
  String get uiReviewYourRecords => 'ਆਪਣੇ ਰਿਕਾਰਡਾਂ ਦੀ ਸਮੀਖਿਆ ਕਰੋ';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'ਮੂਲ ਰਿਪੋਰਟ ਦੇ ਵਿਰੁੱਧ ਐਕਸਟਰੈਕਟ ਕੀਤੇ ਮੁੱਲ, ਇਕਾਈਆਂ ਅਤੇ ਮਿਤੀਆਂ ਦੀ ਜਾਂਚ ਕਰੋ। ਆਪਣੇ ਨਤੀਜਿਆਂ ਬਾਰੇ ਕਿਸੇ ਸਿਹਤ ਸੰਭਾਲ ਪੇਸ਼ੇਵਰ ਨੂੰ ਪੁੱਛੋ।';

  @override
  String get uiManageAndShareResponsibly =>
      'ਜ਼ਿੰਮੇਵਾਰੀ ਨਾਲ ਪ੍ਰਬੰਧਿਤ ਕਰੋ ਅਤੇ ਸਾਂਝਾ ਕਰੋ';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'ਸਿਰਫ਼ ਉਹਨਾਂ ਰਿਕਾਰਡਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ ਜਿਨ੍ਹਾਂ ਤੱਕ ਤੁਸੀਂ ਪਹੁੰਚ ਕਰਨ ਲਈ ਅਧਿਕਾਰਤ ਹੋ। ਸ਼ੇਅਰ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਚੁਣੀ ਹੋਈ ਜਾਣਕਾਰੀ ਅਤੇ ਪ੍ਰਾਪਤਕਰਤਾ ਦੀ ਜਾਂਚ ਕਰੋ।';

  @override
  String get uiPrivacyPolicy7ceacd => 'ਗੋਪਨੀਯਤਾ ਨੀਤੀ';

  @override
  String get uiTermsOfUse8a069e => 'ਵਰਤੋਂ ਦੀਆਂ ਸ਼ਰਤਾਂ';

  @override
  String get uiOpenPrivacyControls => 'ਗੋਪਨੀਯਤਾ ਨਿਯੰਤਰਣ ਖੋਲ੍ਹੋ';

  @override
  String get uiGetHelpWithTheApp => 'ਐਪ ਲਈ ਮਦਦ ਪ੍ਰਾਪਤ ਕਰੋ';

  @override
  String get uiExportYourDataInAccountSettings =>
      'ਖਾਤਾ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਆਪਣਾ ਡੇਟਾ ਨਿਰਯਾਤ ਕਰੋ';

  @override
  String get uiYOURDATACHOICES => 'ਤੁਹਾਡਾ ਡੇਟਾ ਅਤੇ ਚੋਣਾਂ';

  @override
  String get uiUSINGDOCLYZER => 'ਡੌਕਲਾਈਜ਼ਰ ਦੀ ਵਰਤੋਂ ਕਰਨਾ';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'ਦੀ ਜਾਣਕਾਰੀ ਨੂੰ ਸਮਝੋ ਜੋ ਤੁਸੀਂ Doclyzer ਵਿੱਚ ਰੱਖਦੇ ਹੋ।';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'ਐਪ ਦੀ ਭੂਮਿਕਾ ਦੀ ਇੱਕ ਸਪਸ਼ਟ ਸਮਝ\n।';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name ਤੋਂ $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · ਨਵੀਨਤਮ $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'ਇਸ ਲਾਇਬ੍ਰੇਰੀ ਨੂੰ ਸ਼ੁਰੂ ਕਰਨ ਲਈ $name ਲਈ ਇੱਕ ਰਿਪੋਰਟ ਅੱਪਲੋਡ ਕਰੋ।';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP ਪਤਾ: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'ਸਾਈਨ ਇਨ ਕੀਤਾ: $date';
  }

  @override
  String get uiUnknown => 'ਅਗਿਆਤ';

  @override
  String uiResultsFor(String name) {
    return '$name ਲਈ ਨਤੀਜੇ';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count ਲੈਬ ਪੈਰਾਮੀਟਰ ਟਰੈਕ ਕੀਤੇ ਗਏ';
  }

  @override
  String uiSampledDate(String date) {
    return 'ਨਮੂਨਾ $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'ਸੰਗ੍ਰਹਿ ਦੀ ਮਿਤੀ: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'ਲੈਬ ਰੇਂਜ: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI ਇਸ ਰੇਂਜ ਨੂੰ $range ਵਜੋਂ ਪੜ੍ਹਦਾ ਹੈ। ਛਪਿਆ ਟੈਕਸਟ: $printed। ਇਸ ਤੁਲਨਾ \'ਤੇ ਭਰੋਸਾ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਅਸਲ ਰਿਪੋਰਟ ਦੀ ਜਾਂਚ ਕਰੋ।';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount ਤਿਆਰ ਹੈ';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count ਕ੍ਰੈਡਿਟ';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'ਇੱਕ ਰੈਫਰਲ ਕੋਡ ਪਹਿਲਾਂ ਹੀ ਇਸ ਖਾਤੇ \'ਤੇ ਲਾਗੂ ਕੀਤਾ ਜਾ ਚੁੱਕਾ ਹੈ।';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ਐਪ ਲੌਕ ਨੂੰ ਚਾਲੂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਇੱਕ ਡਿਵਾਈਸ ਪਾਸਕੋਡ ਸੈਟ ਕਰੋ।';

  @override
  String get uiLanguagePreferenceNotSaved =>
      'ਭਾਸ਼ਾ ਦੀ ਤਰਜੀਹ ਨੂੰ ਸੁਰੱਖਿਅਤ ਨਹੀਂ ਕੀਤਾ ਗਿਆ ਸੀ।';

  @override
  String get uiExportUnavailable => 'ਨਿਰਯਾਤ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get uiUnreadableImage => 'ਨਾ-ਪੜ੍ਹਨਯੋਗ ਚਿੱਤਰ';

  @override
  String uiStatusWithValue(String status) {
    return 'ਸਥਿਤੀ: $status';
  }

  @override
  String get uiPending => 'ਬਕਾਇਆ';

  @override
  String get uiCompleted => 'ਪੂਰਾ ਹੋਇਆ';

  @override
  String get uiFailed => 'ਅਸਫਲ ਰਿਹਾ';

  @override
  String get uiInactive => 'ਅਕਿਰਿਆਸ਼ੀਲ';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'ਆਪਣੀਆਂ ਰਿਪੋਰਟਾਂ ਅਤੇ ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਰੱਖਣ ਲਈ $date ਤੋਂ ਪਹਿਲਾਂ ਰੀਸਟੋਰ ਕਰੋ।';
  }

  @override
  String get uiThirtyDayDeadline => '30 ਦਿਨਾਂ ਦੀ ਅੰਤਮ ਤਾਰੀਖ';

  @override
  String uiWhatsAffected(String details) {
    return 'ਕੀ ਪ੍ਰਭਾਵਿਤ ਹੁੰਦਾ ਹੈ: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'ਆਖਰੀ ਵਾਰ ਅੱਪਡੇਟ ਕੀਤਾ ਗਿਆ: $time \'ਤੇ $date';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename ਮੌਜੂਦਾ ਪ੍ਰੋਫਾਈਲ ਦੀ ਬਜਾਏ $name ਦੇ ਹੇਠਾਂ ਦਿਖਾਈ ਦੇਵੇਗਾ।';
  }

  @override
  String get uiOneVerifiedResult => '1 ਪ੍ਰਮਾਣਿਤ ਨਤੀਜਾ ਸੁਰੱਖਿਅਤ ਕੀਤਾ ਗਿਆ।';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count ਪ੍ਰਮਾਣਿਤ ਨਤੀਜੇ ਸੁਰੱਖਿਅਤ ਕੀਤੇ ਗਏ।';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'ਪ੍ਰੋਫਾਈਲਾਂ ਨੂੰ ਬਦਲਣ ਵਿੱਚ ਅਸਮਰੱਥ। $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'ਇਕੱਤਰ ਕੀਤਾ: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'ਅੱਪਲੋਡ ਕੀਤਾ ਗਿਆ $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount ਦੁਆਰਾ ਵਧਾਇਆ ਗਿਆ';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount ਦੁਆਰਾ ਘਟਾਇਆ ਗਿਆ';
  }

  @override
  String get uiPercentagePoints => 'ਪ੍ਰਤੀਸ਼ਤ ਅੰਕ';

  @override
  String uiTestValuesCount(String count) {
    return 'ਟੈਸਟ ਮੁੱਲ ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'ਪ੍ਰੋਸੈਸਿੰਗ ਦੌਰਾਨ AI ਦੁਆਰਾ ਮੁੱਲ ਦੀ ਜਾਂਚ ਕੀਤੀ ਗਈ। ਮੂਲ OCR: $value। ਰਿਪੋਰਟ ਦੇ ਵਿਰੁੱਧ ਇਸ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return '$name ਵਿੱਚ ਪਹਿਲਾਂ ਹੀ ਰਿਪੋਰਟ ਕਰੋ';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return '$name ਵਿੱਚ ਰਿਪੋਰਟ ਸ਼ਾਮਲ ਕੀਤੀ ਗਈ';
  }

  @override
  String uiAddedOn(String date) {
    return '$date ਸ਼ਾਮਲ ਕੀਤਾ ਗਿਆ';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max ਰਿਪੋਰਟਾਂ ਦੇ $current ਦੀ ਵਰਤੋਂ ਕਰਨਾ।';
  }

  @override
  String get uiNeedHelp => 'ਮਦਦ ਚਾਹੀਦੀ ਹੈ?';

  @override
  String get uiEnabled => 'ਸਮਰਥਿਤ';

  @override
  String get uiEnable => 'ਯੋਗ ਕਰੋ';

  @override
  String get uiSubscribe => 'ਸਬਸਕ੍ਰਾਈਬ ਕਰੋ';

  @override
  String get uiApplying => 'ਅਪਲਾਈ ਕਰ ਰਿਹਾ ਹੈ';

  @override
  String get uiCheckStatus => 'ਸਥਿਤੀ ਜਾਂਚੋ';

  @override
  String get uiEditProfile => 'ਪ੍ਰੋਫਾਈਲ ਸੋਧੋ';

  @override
  String get uiSaveChanges => 'ਬਦਲਾਅ ਸੇਵ ਕਰੋ';

  @override
  String get uiOptional => 'ਵਿਕਲਪਿਕ';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ਆਰਡਰ $orderId ਸੁਲ੍ਹਾ ਦੀ ਉਡੀਕ ਕਰ ਰਿਹਾ ਹੈ। ਸਥਿਤੀ ਸਪੱਸ਼ਟ ਹੋਣ ਤੱਕ ਖਰੀਦਦਾਰੀ ਨੂੰ ਰੋਕ ਦਿੱਤਾ ਗਿਆ ਹੈ।';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'ਮਹੀਨਾਵਾਰ ਯੋਜਨਾ - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'ਕ੍ਰੈਡਿਟ ਪੈਕ - $name';
  }

  @override
  String get uiUnreadable => 'ਨਾ-ਪੜ੍ਹਨਯੋਗ';

  @override
  String uiLatestValue(String value) {
    return 'ਨਵੀਨਤਮ: $value';
  }

  @override
  String get uiEarlier => 'ਇਸ ਤੋਂ ਪਹਿਲਾਂ';

  @override
  String get uiLater => 'ਬਾਅਦ ਵਿੱਚ';

  @override
  String get uiViewed => 'ਦੇਖਿਆ ਗਿਆ';

  @override
  String get uiBlocked => 'ਬਲੌਕ ਕੀਤਾ';

  @override
  String get uiCapped => 'ਕੈਪਡ';

  @override
  String uiLastChange(String label) {
    return 'ਆਖਰੀ ਤਬਦੀਲੀ: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'ਆਖਰੀ ਤਬਦੀਲੀ: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'ਗਿਫਟ ​​ਵਾਊਚਰ ਲਾਗੂ ਕੀਤਾ ਗਿਆ। $credits ਕ੍ਰੈਡਿਟ ਸ਼ਾਮਲ ਕੀਤੇ ਗਏ।';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'ਅਸਲੀ ਨੂੰ ਹਾਲੇ ਤੱਕ ਸੁਰੱਖਿਅਤ ਨਹੀਂ ਕੀਤਾ ਜਾ ਸਕਿਆ। $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'ਰੱਦ ਕਰਨ ਵਿੱਚ ਅਸਫਲ: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'ਮੇਰੇ ਡੌਕਲਾਈਜ਼ਰ ਰੈਫਰਲ ਕੋਡ $code: $link ਦੀ ਵਰਤੋਂ ਕਰੋ';
  }

  @override
  String get uiAMomentAgo => 'ਇੱਕ ਪਲ ਪਹਿਲਾਂ';

  @override
  String uiMinutesAgo(String count) {
    return '$count ਮਿੰਟ ਪਹਿਲਾਂ';
  }

  @override
  String get uiOneHourAgo => '1 ਘੰਟਾ ਪਹਿਲਾਂ';

  @override
  String uiHoursAgo(String count) {
    return '$count ਘੰਟੇ ਪਹਿਲਾਂ';
  }

  @override
  String get uiToday => 'ਅੱਜ';

  @override
  String get uiYesterday => 'ਕੱਲ੍ਹ';

  @override
  String get uiOneDayAgo => '1 ਦਿਨ ਪਹਿਲਾਂ';

  @override
  String uiDaysAgo(String count) {
    return '$count ਦਿਨ ਪਹਿਲਾਂ';
  }

  @override
  String get uiOneWeekAgo => '1 ਹਫ਼ਤਾ ਪਹਿਲਾਂ';

  @override
  String uiWeeksAgo(String count) {
    return '$count ਹਫ਼ਤੇ ਪਹਿਲਾਂ';
  }

  @override
  String get uiOneMonthAgo => '1 ਮਹੀਨਾ ਪਹਿਲਾਂ';

  @override
  String uiMonthsAgo(String count) {
    return '$count ਮਹੀਨੇ ਪਹਿਲਾਂ';
  }

  @override
  String get uiOneYearAgo => '1 ਸਾਲ ਪਹਿਲਾਂ';

  @override
  String uiYearsAgo(String count) {
    return '$count ਸਾਲ ਪਹਿਲਾਂ';
  }

  @override
  String get uiInOneDay => '1 ਦਿਨ ਵਿੱਚ';

  @override
  String uiInDays(String count) {
    return '$count ਦਿਨਾਂ ਵਿੱਚ';
  }

  @override
  String uiInMinutes(String count) {
    return '$count ਮਿੰਟ ਵਿੱਚ';
  }

  @override
  String get uiInOneHour => '1 ਘੰਟੇ ਵਿੱਚ';

  @override
  String uiInHours(String count) {
    return '$count ਘੰਟਿਆਂ ਵਿੱਚ';
  }

  @override
  String get uiMissingExtractedTestName =>
      'ਐਕਸਟਰੈਕਟ ਕੀਤੇ ਨਤੀਜੇ ਵਿੱਚੋਂ ਟੈਸਟ ਦਾ ਨਾਮ ਗੁੰਮ ਹੈ।';

  @override
  String get uiMissingCapturedLabRange =>
      'ਇਸ ਟੈਸਟ ਲਈ ਕੋਈ ਲੈਬ ਸੰਦਰਭ ਰੇਂਜ ਕੈਪਚਰ ਨਹੀਂ ਕੀਤੀ ਗਈ ਸੀ।';

  @override
  String get uiNonNumericExtractedValue =>
      'ਐਕਸਟਰੈਕਟ ਕੀਤਾ ਮੁੱਲ ਇੱਕ ਸਾਦਾ ਨੰਬਰ ਨਹੀਂ ਹੈ। ਅਸਲੀ ਰਿਪੋਰਟ ਵਿੱਚ ਇਸ ਦੀ ਜਾਂਚ ਕਰੋ।';

  @override
  String get uiLabFlagRangeConflict =>
      'ਲੈਬ ਫਲੈਗ ਪ੍ਰਿੰਟ ਕੀਤੀ ਰੇਂਜ ਨਾਲ ਟਕਰਾਅ ਹੈ। ਅਸਲ ਰਿਪੋਰਟ ਦੀ ਜਾਂਚ ਕਰੋ।';

  @override
  String get uiResultNeedsOriginalCheck =>
      'ਮੂਲ ਰਿਪੋਰਟ ਵਿੱਚ ਐਕਸਟਰੈਕਟ ਕੀਤੇ ਮੁੱਲ, ਪ੍ਰਿੰਟ ਕੀਤੀ ਰੇਂਜ, ਜਾਂ ਲੈਬ ਫਲੈਗ ਦੀ ਜਾਂਚ ਕਰਨ ਦੀ ਲੋੜ ਹੈ।';

  @override
  String get uiInitialEntitlement => 'ਸ਼ੁਰੂਆਤੀ ਹੱਕਦਾਰੀ';

  @override
  String get uiCreditPackPurchase => 'ਕ੍ਰੈਡਿਟ ਪੈਕ ਖਰੀਦਦਾਰੀ';

  @override
  String get uiSubscriptionUpgrade => 'ਗਾਹਕੀ ਅੱਪਗਰੇਡ';

  @override
  String get uiPlanDowngrade => 'ਯੋਜਨਾ ਨੂੰ ਡਾਊਨਗ੍ਰੇਡ ਕਰੋ';

  @override
  String get uiAdminAdjustment => 'ਐਡਮਿਨ ਐਡਜਸਟਮੈਂਟ';

  @override
  String get uiSystemReconciliation => 'ਸਿਸਟਮ ਸੁਲ੍ਹਾ';

  @override
  String get uiReferralInviteBonus => 'ਰੈਫਰਲ ਸੱਦਾ ਬੋਨਸ';

  @override
  String get uiReferralAnalysisMilestone => 'ਰੈਫਰਲ ਵਿਸ਼ਲੇਸ਼ਣ ਮੀਲ ਪੱਥਰ';

  @override
  String get uiReferralPurchaseMilestone => 'ਰੈਫਰਲ ਖਰੀਦ ਮੀਲ ਪੱਥਰ';

  @override
  String get uiFreePromoCreditPack => 'ਮੁਫਤ ਪ੍ਰੋਮੋ ਕ੍ਰੈਡਿਟ ਪੈਕ';

  @override
  String get uiGiftVoucherRedeemed => 'ਗਿਫਟ ਵਾਊਚਰ ਰੀਡੀਮ ਕੀਤਾ ਗਿਆ';

  @override
  String get uiNotYetChanged => 'ਅਜੇ ਤੱਕ ਨਹੀਂ ਬਦਲਿਆ';

  @override
  String get uiCannotReachServer =>
      'ਸਰਵਰ ਤੱਕ ਪਹੁੰਚਣ ਵਿੱਚ ਅਸਮਰੱਥ। ਆਪਣੇ ਕਨੈਕਸ਼ਨ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiInvalidEmailOrPassword =>
      'ਅਵੈਧ ਈਮੇਲ ਜਾਂ ਪਾਸਵਰਡ। ਆਪਣੇ ਵੇਰਵਿਆਂ ਦੀ ਜਾਂਚ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiTooManyAuthAttempts =>
      'ਬਹੁਤ ਸਾਰੀਆਂ ਕੋਸ਼ਿਸ਼ਾਂ। ਕੁਝ ਮਿੰਟ ਉਡੀਕ ਕਰੋ ਅਤੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiEnterValidEmail => 'ਇੱਕ ਜਾਇਜ ਈਮੇਲ ਪਤਾ ਦਰਜ ਕਰੋ.';

  @override
  String get uiPasswordRequirements =>
      'ਪਾਸਵਰਡ ਘੱਟੋ-ਘੱਟ 8 ਅੱਖਰਾਂ ਦਾ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ ਅਤੇ ਇਸ ਵਿੱਚ ਅੱਪਰਕੇਸ, ਲੋਅਰਕੇਸ, ਇੱਕ ਨੰਬਰ ਅਤੇ ਇੱਕ ਵਿਸ਼ੇਸ਼ ਅੱਖਰ ਸ਼ਾਮਲ ਹੋਣਾ ਚਾਹੀਦਾ ਹੈ।';

  @override
  String get uiAccountWithEmailExists =>
      'ਇਸ ਈਮੇਲ ਵਾਲਾ ਖਾਤਾ ਪਹਿਲਾਂ ਹੀ ਮੌਜੂਦ ਹੈ। ਸਾਈਨ ਇਨ ਕਰੋ ਜਾਂ ਕੋਈ ਵੱਖਰੀ ਈਮੇਲ ਵਰਤੋ।';

  @override
  String get uiUploadedStatus => 'ਅੱਪਲੋਡ ਕੀਤਾ';

  @override
  String uiSupportAction(String action) {
    return 'ਕਾਰਵਾਈ: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'ਸਬੰਧ ID: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'ਕਲਾਇੰਟ ਐਕਸ਼ਨ ID: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'ਗਲਤੀ ਕੋਡ: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'ਤਰੁੱਟੀ: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'ਤੁਹਾਡਾ ਸੈਸ਼ਨ ਸਮਾਪਤ ਹੋਇਆ। ਦੁਬਾਰਾ ਸਾਈਨ ਇਨ ਕਰੋ।';

  @override
  String get uiProfileLimitReached =>
      'ਤੁਹਾਡੀ ਯੋਜਨਾ ਪ੍ਰੋਫਾਈਲ ਸੀਮਾ ਪੂਰੀ ਹੋ ਗਈ ਹੈ। ਹੋਰ ਜੋੜਨ ਲਈ ਯੋਜਨਾ ਅਤੇ ਕ੍ਰੈਡਿਟ ਦੀ ਸਮੀਖਿਆ ਕਰੋ।';

  @override
  String get uiCorrectionConflictReload =>
      'ਇਹ ਨਤੀਜਾ ਕਿਤੇ ਹੋਰ ਬਦਲ ਗਿਆ. ਰਿਪੋਰਟ ਨੂੰ ਠੀਕ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਰੀਲੋਡ ਕਰੋ।';

  @override
  String get uiSeePlanCreditsOptions =>
      'ਉਪਲਬਧ ਵਿਕਲਪਾਂ ਲਈ ਯੋਜਨਾ ਅਤੇ ਕ੍ਰੈਡਿਟ ਵੇਖੋ।';

  @override
  String get uiShareLinkLimitHelp =>
      'ਤੁਸੀਂ ਕਿਰਿਆਸ਼ੀਲ ਸ਼ੇਅਰ-ਲਿੰਕ ਸੀਮਾ \'ਤੇ ਪਹੁੰਚ ਗਏ ਹੋ।';

  @override
  String get uiScopedExportUnavailable =>
      'ਸਕੋਪਡ ਨਿਰਯਾਤ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਬਾਅਦ ਵਿੱਚ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiRestorationUnavailable =>
      'ਬਹਾਲੀ ਉਪਲਬਧ ਨਹੀਂ ਹੈ। ਬਾਅਦ ਵਿੱਚ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';

  @override
  String get uiExportRequestNotFound =>
      'ਐਕਸਪੋਰਟ ਬੇਨਤੀ ਨਹੀਂ ਮਿਲੀ। ਇੱਕ ਨਵੇਂ ਨਿਰਯਾਤ ਲਈ ਬੇਨਤੀ ਕਰੋ।';

  @override
  String get uiClosureConfirmationRequired =>
      'ਜਾਰੀ ਰੱਖਣ ਲਈ ਖਾਤਾ ਬੰਦ ਕਰਨ ਦੀ ਪੁਸ਼ਟੀ ਕਰੋ।';

  @override
  String get uiCurrentPasswordIncorrect => 'ਮੌਜੂਦਾ ਪਾਸਵਰਡ ਗਲਤ ਹੈ।';

  @override
  String get uiLaboratories => 'ਪ੍ਰਯੋਗਸ਼ਾਲਾਵਾਂ';

  @override
  String get uiUnlock => 'ਅਨਲੌਕ ਕਰੋ';
}
