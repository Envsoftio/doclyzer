// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get trendLatestResult => 'ಇತ್ತೀಚಿನ ಫಲಿತಾಂಶ';

  @override
  String get trendPreviousResult => 'ಹಿಂದಿನ ಫಲಿತಾಂಶ';

  @override
  String get trendSourceUnit => 'ಈ ವ್ಯಾಪ್ತಿಯ ಮೂಲ ಘಟಕ';

  @override
  String get trendNoSavedResults => 'ಈ ಪರೀಕ್ಷೆಗೆ ಇನ್ನೂ ಉಳಿಸಿದ ಫಲಿತಾಂಶಗಳಿಲ್ಲ.';

  @override
  String get trendNoPlottableResults =>
      'ಸಂಗ್ರಹ ದಿನಾಂಕವಿರುವ ನಿಖರ ಸಂಖ್ಯಾತ್ಮಕ ಫಲಿತಾಂಶಗಳನ್ನು ಚಾರ್ಟ್‌ನಲ್ಲಿ ತೋರಿಸಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get trendOneResultHelp =>
      'ಒಂದು ಫಲಿತಾಂಶ ಉಳಿಸಲಾಗಿದೆ. ಪ್ರವೃತ್ತಿಯನ್ನು ನೋಡಲು ಇನ್ನೊಂದು ವರದಿಯನ್ನು ಸೇರಿಸಿ.';

  @override
  String get trendMultipleResultsHelp =>
      'ದಿನಾಂಕಗಳನ್ನು ಕಳೆದ ಸಮಯಕ್ಕೆ ಅನುಗುಣವಾಗಿ ತೋರಿಸಲಾಗಿದೆ. ಮೌಲ್ಯವನ್ನು ನೋಡಲು ಬಿಂದುವನ್ನು ತಟ್ಟಿ.';

  @override
  String trendUnplottedNote(int count) {
    return 'ಸಂಗ್ರಹ ದಿನಾಂಕ ಅಥವಾ ನಿಖರ ಸಂಖ್ಯಾತ್ಮಕ ಮೌಲ್ಯ ಲಭ್ಯವಿಲ್ಲದ ಕಾರಣ $count ಫಲಿತಾಂಶಗಳನ್ನು ಚಾರ್ಟ್‌ನಲ್ಲಿ ತೋರಿಸಲಾಗಿಲ್ಲ.';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$count ಫಲಿತಾಂಶಗಳೊಂದಿಗೆ $testName ಪ್ರವೃತ್ತಿ ಚಾರ್ಟ್';
  }

  @override
  String get trendDateReview =>
      'ಸಂಗ್ರಹ ದಿನಾಂಕ ಹಿಂದಿನ ಹೊರತೆಗೆದ ಮಾಹಿತಿಯಿಂದ ಬಂದಿದೆ. ಮೂಲ ವರದಿಯಲ್ಲಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get trendNotPlotted => 'ಚಾರ್ಟ್‌ನಲ್ಲಿ ತೋರಿಸಲಾಗಿಲ್ಲ';

  @override
  String get trendExactNumberUnavailable => 'ಫಲಿತಾಂಶವು ನಿಖರ ಸಂಖ್ಯೆಯಲ್ಲ';

  @override
  String get preferredLanguage => 'ಆದ್ಯತೆಯ ಭಾಷೆ';

  @override
  String get descriptionLanguage => 'ವಿವರಣೆಯ ಭಾಷೆ';

  @override
  String get languageHelp =>
      'ಆ್ಯಪ್‌ನ ಪಠ್ಯಗಳು ಮತ್ತು ವರದಿಯ ವಿವರಣೆಗಳಿಗೆ ಬಳಸಲಾಗುತ್ತದೆ. ವಿವರಣೆಯ ಭಾಷೆಯನ್ನು ನೀವು ಯಾವಾಗ ಬೇಕಾದರೂ ಬದಲಾಯಿಸಬಹುದು.';

  @override
  String get languageSaveFailed =>
      'ನಿಮ್ಮ ಭಾಷೆಯ ಆಯ್ಕೆಯನ್ನು ಉಳಿಸಲಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get translationLoading => 'ಅನುವಾದಿತ ವಿವರಣೆಯನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ…';

  @override
  String get translationFailed =>
      'ಅನುವಾದ ಲಭ್ಯವಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ ಅಥವಾ ಇಂಗ್ಲಿಷ್ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get translationNote =>
      'ಉಳಿಸಿದ ಇಂಗ್ಲಿಷ್ ವಿವರಣೆಯಿಂದ AI ಮೂಲಕ ಅನುವಾದಿಸಲಾಗಿದೆ. ನಿಖರ ಫಲಿತಾಂಶಗಳಿಗಾಗಿ ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get sourceChanged =>
      'ವರದಿ ಬದಲಾಗಿದೆ. ಇತ್ತೀಚಿನ ವಿವರಣೆಯನ್ನು ನೋಡಲು ಅದನ್ನು ಮತ್ತೆ ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get signupTitle => 'ಇನ್ನಷ್ಟು ಸ್ಪಷ್ಟವಾದ ನೋಟ\nಇಲ್ಲಿಂದ ಆರಂಭವಾಗುತ್ತದೆ.';

  @override
  String get signupIntro =>
      'ನಿಮ್ಮ ವರದಿಗಳು ಮತ್ತು ಫಲಿತಾಂಶಗಳನ್ನು ಒಂದೇ ಕಡೆ ಇರಿಸಲು ಖಾತೆ ರಚಿಸಿ.';

  @override
  String get loginIntro =>
      'ನಿಮ್ಮ ಆರೋಗ್ಯ ವರದಿಗಳನ್ನು ನೋಡಲು ಮತ್ತು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಲು ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get emailAddress => 'ಇಮೇಲ್ ವಿಳಾಸ';

  @override
  String get email => 'ಇಮೇಲ್';

  @override
  String get password => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get referralCode => 'ಪರಿಚಯಿಸಿದವರ ಕೋಡ್ (ಐಚ್ಛಿಕ)';

  @override
  String get createAccount => 'ಖಾತೆ ರಚಿಸಿ';

  @override
  String get alreadyAccount => 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ? ';

  @override
  String get noAccount => 'ಖಾತೆ ಇಲ್ಲವೇ? ';

  @override
  String get signIn => 'ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String get showPassword => 'ಪಾಸ್‌ವರ್ಡ್ ತೋರಿಸಿ';

  @override
  String get hidePassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆಮಾಡಿ';

  @override
  String get needHelp => 'ಸಹಾಯ ಬೇಕೇ?';

  @override
  String get forgotPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?';

  @override
  String get invalidCredentialsInput =>
      'ಮಾನ್ಯವಾದ ಇಮೇಲ್ ವಿಳಾಸ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String get signupFailed => 'ಖಾತೆ ರಚಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get loginFailed =>
      'ಸೈನ್ ಇನ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ, ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get genericError => 'ಏನೋ ತಪ್ಪಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get profileUpdated => 'ಪ್ರೊಫೈಲ್ ನವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get changePhoto => 'ಪ್ರೊಫೈಲ್ ಫೋಟೋ ಬದಲಾಯಿಸಿ';

  @override
  String get gallery => 'ಚಿತ್ರಸಂಗ್ರಹದಿಂದ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get camera => 'ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get photoUpdated => 'ಪ್ರೊಫೈಲ್ ಫೋಟೋ ನವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get photoFailed =>
      'ನಿಮ್ಮ ಫೋಟೋ ನವೀಕರಿಸಲಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get yourAccount => 'ನಿಮ್ಮ ಖಾತೆ';

  @override
  String get profileLoading => 'ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get profileLoadAction => 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get accountData => 'ಖಾತೆ ಮತ್ತು ಡೇಟಾ';

  @override
  String get personalInformation => 'ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ';

  @override
  String get notificationPreferences => 'ಅಧಿಸೂಚನೆಗಳ ಆದ್ಯತೆಗಳು';

  @override
  String get privacySecurity => 'ಗೌಪ್ಯತೆ ಮತ್ತು ಸುರಕ್ಷತೆ';

  @override
  String get sharedLinks => 'ಹಂಚಿಕೊಂಡ ಲಿಂಕ್‌ಗಳು';

  @override
  String get exportData => 'ನಿಮ್ಮ ಡೇಟಾವನ್ನು ರಫ್ತು ಮಾಡಿ';

  @override
  String get additionalAccount => 'ಹೆಚ್ಚುವರಿ ಖಾತೆ ಮಾಹಿತಿ';

  @override
  String get additionalAccountHelp =>
      'ಕುಟುಂಬ, ಯೋಜನೆ, ಪರಿಚಯಗಳು, ಸೆಷನ್‌ಗಳು ಮತ್ತು ನೋಟ';

  @override
  String get familyProfiles => 'ಕುಟುಂಬದ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get manageProfiles => 'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಿ ಅಥವಾ ನಿರ್ವಹಿಸಿ';

  @override
  String get planCredits => 'ಯೋಜನೆ ಮತ್ತು ಕ್ರೆಡಿಟ್‌ಗಳು';

  @override
  String get viewPlanBalance => 'ನಿಮ್ಮ ಯೋಜನೆ ಮತ್ತು ಉಳಿದ ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ನೋಡಿ';

  @override
  String get balanceLoading => 'ಉಳಿದ ಕ್ರೆಡಿಟ್‌ಗಳ ವಿವರ ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get referFriends => 'ಸ್ನೇಹಿತರನ್ನು ಪರಿಚಯಿಸಿ';

  @override
  String get referralRewards => 'ಆಹ್ವಾನಗಳು ಮತ್ತು ಪರಿಚಯಿಸಿದ್ದಕ್ಕಾಗಿ ಬಹುಮಾನಗಳು';

  @override
  String get activeSessions => 'ಸಕ್ರಿಯ ಸೆಷನ್‌ಗಳು';

  @override
  String get appearance => 'ನೋಟ';

  @override
  String get system => 'ಸಾಧನದ ಸೆಟ್ಟಿಂಗ್ ಪ್ರಕಾರ';

  @override
  String get light => 'ತಿಳಿ';

  @override
  String get dark => 'ಗಾಢ';

  @override
  String get helpSupport => 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ';

  @override
  String get aboutDoclyzer => 'Doclyzer ಕುರಿತು';

  @override
  String get aboutCopy =>
      'ವರದಿಗಳನ್ನು ವ್ಯಕ್ತಿಗನುಸಾರ ವ್ಯವಸ್ಥಿತವಾಗಿ ಇರಿಸಿ ಮತ್ತು ಹೊರತೆಗೆದ ಫಲಿತಾಂಶಗಳನ್ನು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಸಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get logOut => 'ಲಾಗ್ ಔಟ್ ಮಾಡಿ';

  @override
  String get profile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get saveChanges => 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get accountRestricted => 'ಖಾತೆಗೆ ನಿರ್ಬಂಧ ವಿಧಿಸಲಾಗಿದೆ';

  @override
  String get photoUploading => 'ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get changePhotoShort => 'ಫೋಟೋ ಬದಲಾಯಿಸಿ';

  @override
  String get accountDetails => 'ಖಾತೆಯ ವಿವರಗಳು';

  @override
  String get emailHelp =>
      'ಖಾತೆ ಪ್ರವೇಶಕ್ಕೆ ಬಳಸಲಾಗುತ್ತದೆ. ಇದನ್ನು ಬದಲಾಯಿಸಲು ಬೆಂಬಲ ತಂಡವನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String get accountName => 'ಖಾತೆಯ ಹೆಸರು';

  @override
  String get belowLabRange => 'ಈ ಪ್ರಯೋಗಾಲಯದ ಉಲ್ಲೇಖ ವ್ಯಾಪ್ತಿಗಿಂತ ಕಡಿಮೆ';

  @override
  String get withinLabRange => 'ಈ ಪ್ರಯೋಗಾಲಯದ ಉಲ್ಲೇಖ ವ್ಯಾಪ್ತಿಯೊಳಗಿದೆ';

  @override
  String get aboveLabRange => 'ಈ ಪ್ರಯೋಗಾಲಯದ ಉಲ್ಲೇಖ ವ್ಯಾಪ್ತಿಗಿಂತ ಹೆಚ್ಚು';

  @override
  String get cannotCompare => 'ಪ್ರಯೋಗಾಲಯದ ವ್ಯಾಪ್ತಿಯೊಂದಿಗೆ ಹೋಲಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ';

  @override
  String get understandResult => 'ಈ ಫಲಿತಾಂಶವನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ';

  @override
  String get yourResult => 'ನಿಮ್ಮ ಫಲಿತಾಂಶ';

  @override
  String get labReferenceRange => 'ಪ್ರಯೋಗಾಲಯದ ಉಲ್ಲೇಖ ವ್ಯಾಪ್ತಿ';

  @override
  String get resultUnavailable => 'ಈ ಫಲಿತಾಂಶದಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get sampleDate => 'ಮಾದರಿ ಪಡೆದ ದಿನಾಂಕ';

  @override
  String get resultHistory => 'ಫಲಿತಾಂಶಗಳ ಇತಿಹಾಸ';

  @override
  String get originalReport => 'ಮೂಲ ವರದಿ';

  @override
  String get reviewValue => 'ಮೌಲ್ಯವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get understandYourResult => 'ನಿಮ್ಮ ಫಲಿತಾಂಶವನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ';

  @override
  String get educationalContext =>
      'ಈ ಫಲಿತಾಂಶದ ಬಗ್ಗೆ ಚರ್ಚಿಸಲು ನೆರವಾಗುವ ಶೈಕ್ಷಣಿಕ ಮಾಹಿತಿ.';

  @override
  String get explanationUnavailable => 'ವಿವರಣೆ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get explanationFailed => 'ಈಗ ವಿವರಣೆಯನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';

  @override
  String get checkOriginal => 'ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get tryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get aiGuidance => 'AI ರಚಿಸಿದ ಮಾರ್ಗದರ್ಶನ';

  @override
  String get understandingResult => 'ಈ ಫಲಿತಾಂಶವನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳುವುದು';

  @override
  String get possibleMeaning => 'ಇದರ ಅರ್ಥ ಏನಾಗಿರಬಹುದು';

  @override
  String get whatTestMeasures => 'ಈ ಪರೀಕ್ಷೆ ಏನನ್ನು ಅಳೆಯುತ್ತದೆ';

  @override
  String get suggestedNextStep => 'ಸೂಚಿಸಲಾದ ಮುಂದಿನ ಹಂತ';

  @override
  String get resultLimitations => 'ಈ ಫಲಿತಾಂಶದಿಂದ ತಿಳಿಯಲು ಸಾಧ್ಯವಿಲ್ಲದ ವಿಷಯಗಳು';

  @override
  String get oneResultLimit =>
      'ಒಂದೇ ಫಲಿತಾಂಶದಿಂದ ಯಾವುದೇ ಕಾಯಿಲೆಯನ್ನು ನಿರ್ಣಯಿಸಲು ಅಥವಾ ರೋಗಲಕ್ಷಣಗಳನ್ನು ವಿವರಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get detailsToCheck => 'ಪರಿಶೀಲಿಸಬೇಕಾದ ವಿವರಗಳು';

  @override
  String get lifestyleFactors => 'ಚರ್ಚಿಸಬೇಕಾದ ಜೀವನಶೈಲಿಯ ಅಂಶಗಳು';

  @override
  String get insightContext =>
      'ಈ ಮೌಲ್ಯವನ್ನು ನಿಮ್ಮ ವರದಿಯಿಂದ ಹೊರತೆಗೆಯಲಾಗಿದೆ. ಹೆಸರು, ಮೌಲ್ಯ, ಘಟಕ ಅಥವಾ ವ್ಯಾಪ್ತಿ ತಪ್ಪಾಗಿ ಕಂಡರೆ ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ. AI ವಿವರಣೆಗಳು ಶೈಕ್ಷಣಿಕ ಉದ್ದೇಶಕ್ಕಾಗಿವೆ ಮತ್ತು ನಿಮಗೆ ಯಾವ ಚಿಕಿತ್ಸೆ ಬೇಕು ಎಂದು ತಿಳಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get yourProfile => 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get moveReport => 'ವರದಿಯನ್ನು ಸ್ಥಳಾಂತರಿಸಿ';

  @override
  String get gotIt => 'ಅರ್ಥವಾಯಿತು';

  @override
  String get reportDetails => 'ವರದಿಯ ವಿವರಗಳು';

  @override
  String get shareReport => 'ವರದಿಯನ್ನು ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get moreReportActions => 'ವರದಿಗೆ ಸಂಬಂಧಿಸಿದ ಇನ್ನಷ್ಟು ಆಯ್ಕೆಗಳು';

  @override
  String get attemptHistory => 'ಪ್ರಯತ್ನಗಳ ಇತಿಹಾಸ';

  @override
  String get compareReports => 'ವರದಿಗಳನ್ನು ಹೋಲಿಸಿ';

  @override
  String get readParsedReport => 'ಮಾಹಿತಿ ಹೊರತೆಗೆದು ಸಿದ್ಧಪಡಿಸಿದ ವರದಿಯನ್ನು ಓದಿ';

  @override
  String get moveRecycle => 'ಮರುಬಳಕೆ ಬುಟ್ಟಿಗೆ ಸರಿಸಿ';

  @override
  String get retry => 'ಮರುಪ್ರಯತ್ನಿಸಿ';

  @override
  String get reportSummary => 'ವರದಿಯ ಸಾರಾಂಶ';

  @override
  String get updateSummary => 'ಸಾರಾಂಶ ನವೀಕರಿಸಿ';

  @override
  String get summaryLoading =>
      'ನಿಮ್ಮ ಫಲಿತಾಂಶಗಳನ್ನು ಸರಳ ಭಾಷೆಯಲ್ಲಿ ವಿವರಿಸಲಾಗುತ್ತಿದೆ…';

  @override
  String get checkSummary => 'ಸಾರಾಂಶ ಪರಿಶೀಲಿಸಿ';

  @override
  String get summaryFailed =>
      'ಸಾರಾಂಶ ರಚಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನೀವು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಬಹುದು.';

  @override
  String get summaryPlaceholder =>
      'ಪ್ರಮುಖ ಫಲಿತಾಂಶಗಳ ಸರಳ ಭಾಷೆಯ ವಿವರಣೆ ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.';

  @override
  String get retrySummary => 'ಸಾರಾಂಶಕ್ಕಾಗಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get generateSummary => 'ಸಾರಾಂಶ ರಚಿಸಿ';

  @override
  String get loadingResults => 'ವರದಿಯ ಫಲಿತಾಂಶಗಳು ಲೋಡ್ ಆಗುತ್ತಿವೆ…';

  @override
  String get somethingWrong => 'ಏನೋ ತಪ್ಪಾಗಿದೆ';

  @override
  String get viewTrends => 'ಪ್ರವೃತ್ತಿಗಳನ್ನು ನೋಡಿ';

  @override
  String get originalFile => 'ಮೂಲ ಫೈಲ್';

  @override
  String get testValues => 'ಪರೀಕ್ಷಾ ಮೌಲ್ಯಗಳು';

  @override
  String get summary => 'ಸಾರಾಂಶ';

  @override
  String get checkStatus => 'ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ';

  @override
  String get viewOriginal => 'ಮೂಲವನ್ನು ನೋಡಿ';

  @override
  String get verifiedResults => 'ದೃಢೀಕರಿಸಿದ ಫಲಿತಾಂಶಗಳು';

  @override
  String get resultTapHelp =>
      'ಪರೀಕ್ಷೆ ಏನನ್ನು ಅಳೆಯುತ್ತದೆ ಎಂದು ತಿಳಿಯಲು ಫಲಿತಾಂಶವನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get reviewResults => 'ಪತ್ತೆಯಾದ ಫಲಿತಾಂಶಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get keepFile => 'ಆದರೂ ಫೈಲ್ ಉಳಿಸಿಕೊಳ್ಳಿ';

  @override
  String get patientDetails => 'ರೋಗಿಯ ವಿವರಗಳು';

  @override
  String get name => 'ಹೆಸರು';

  @override
  String get age => 'ವಯಸ್ಸು';

  @override
  String get gender => 'ಲಿಂಗ';

  @override
  String get bookingId => 'ಬುಕಿಂಗ್ ID';

  @override
  String get sampleCollection => 'ಮಾದರಿ ಸಂಗ್ರಹ';

  @override
  String get labDetails => 'ಪ್ರಯೋಗಾಲಯದ ವಿವರಗಳು';

  @override
  String get labName => 'ಪ್ರಯೋಗಾಲಯದ ಹೆಸರು';

  @override
  String get address => 'ವಿಳಾಸ';

  @override
  String get phone => 'ಫೋನ್';

  @override
  String get location => 'ಸ್ಥಳ';

  @override
  String get belowRange => 'ವ್ಯಾಪ್ತಿಗಿಂತ ಕಡಿಮೆ';

  @override
  String get aboveRange => 'ವ್ಯಾಪ್ತಿಗಿಂತ ಹೆಚ್ಚು';

  @override
  String get withinRange => 'ನಮೂದಿಸಿದ ವ್ಯಾಪ್ತಿಯೊಳಗಿದೆ';

  @override
  String get rangeUnclear => 'ವ್ಯಾಪ್ತಿ ಅಸ್ಪಷ್ಟವಾಗಿದೆ';

  @override
  String get understandResultAction => 'ಈ ಫಲಿತಾಂಶವನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ  →';

  @override
  String get parsedReport => 'ಮಾಹಿತಿ ಹೊರತೆಗೆದು ಸಿದ್ಧಪಡಿಸಿದ ವರದಿ';

  @override
  String get reports => 'ವರದಿಗಳು';

  @override
  String get trends => 'ಪ್ರವೃತ್ತಿಗಳು';

  @override
  String get openingPage => 'ಆರಂಭಿಕ ಪುಟ';

  @override
  String get home => 'ಮುಖಪುಟ';

  @override
  String get family => 'ಕುಟುಂಬ';

  @override
  String get switchProfile => 'ಪ್ರೊಫೈಲ್ ಬದಲಾಯಿಸಿ';

  @override
  String get currentProfile => 'ಪ್ರಸ್ತುತ ಪ್ರೊಫೈಲ್';

  @override
  String get viewProfile => 'ಈ ಪ್ರೊಫೈಲ್ ನೋಡಿ';

  @override
  String get manageFamily => 'ಕುಟುಂಬವನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get chooseProfile => 'ಪ್ರೊಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get notifications => 'ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get homeTitle => 'ಸ್ವಲ್ಪ ಸ್ಪಷ್ಟತೆ.\nಎಲ್ಲವೂ ಒಂದೇ ಕಡೆ.';

  @override
  String get nextReportTitle =>
      'ನಿಮ್ಮ ಮುಂದಿನ ವರದಿ,\nನೀವು ಸಿದ್ಧರಾದಾಗ ಅದೂ ಸಿದ್ಧ.';

  @override
  String get homeSubtitle => 'PDFಗಳು, ಫೋಟೋಗಳು ಮತ್ತು ಕುಟುಂಬದ ದಾಖಲೆಗಳು.';

  @override
  String get uploadReport => 'ವರದಿ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get recentReport => 'ಇತ್ತೀಚಿನ ವರದಿ';

  @override
  String get viewAll => 'ಎಲ್ಲವನ್ನೂ ನೋಡಿ';

  @override
  String get reportsUnavailable =>
      'ವರದಿಗಳು ಲಭ್ಯವಿಲ್ಲ. ಸಂಪರ್ಕ ದೊರೆತಾಗ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get emptyHomeTitle => 'ನಿಮ್ಮ ಕಥೆ ಇಲ್ಲಿಂದ ಆರಂಭವಾಗುತ್ತದೆ';

  @override
  String get emptyHomeHelp =>
      'ನಿಮ್ಮ ದಾಖಲೆಗಳ ಸ್ಪಷ್ಟ ಇತಿಹಾಸವನ್ನು ಆರಂಭಿಸಲು ಮೊದಲ ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get uploadFirstReport => 'ನಿಮ್ಮ ಮೊದಲ ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get latestResults => 'ಇತ್ತೀಚಿನ ಫಲಿತಾಂಶಗಳು';

  @override
  String get allTrends => 'ಎಲ್ಲ ಪ್ರವೃತ್ತಿಗಳು';

  @override
  String get reviewedResultsHelp =>
      'ಪರಿಶೀಲಿಸಿದ ಫಲಿತಾಂಶಗಳು ಲಭ್ಯವಾದಾಗ ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ.';

  @override
  String get searchTests => 'ಪರೀಕ್ಷೆಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get noHealthData =>
      'ಇನ್ನೂ ಆರೋಗ್ಯ ಡೇಟಾ ಇಲ್ಲ. ನಿಮ್ಮ ಆರೋಗ್ಯ ಇತಿಹಾಸವನ್ನು ನೋಡಲು ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get noTestsFound => 'ಯಾವುದೇ ಪರೀಕ್ಷೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ';

  @override
  String get shorterTestName =>
      'ಪರೀಕ್ಷೆಯ ಹೆಸರನ್ನು ಚಿಕ್ಕದಾಗಿ ನಮೂದಿಸಿ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get clearSearch => 'ಹುಡುಕಾಟ ತೆರವುಗೊಳಿಸಿ';

  @override
  String get unitUnavailable => 'ಘಟಕ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uploadingReport => 'ವರದಿ ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get organizingReport => 'ನಿಮ್ಮ ವರದಿಯನ್ನು ವ್ಯವಸ್ಥಿತಗೊಳಿಸಲಾಗುತ್ತಿದೆ…';

  @override
  String get uploadAReport => 'ಒಂದು ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get uploadHelp =>
      'PDF ಅಥವಾ ಸ್ಪಷ್ಟವಾದ ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ. ಉಳಿಸುವ ಮೊದಲು ವಿವರಗಳನ್ನು ಪರಿಶೀಲಿಸಬಹುದು.';

  @override
  String get chooseSource => 'ಮೂಲವನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uploadPdfImage => 'PDF ಅಥವಾ ಚಿತ್ರ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get chooseReportFiles => 'ನಿಮ್ಮ ಫೈಲ್‌ಗಳಿಂದ ವರದಿಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get selectReportPages => 'ವರದಿಯ ಒಂದು ಅಥವಾ ಹೆಚ್ಚಿನ ಪುಟಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get capturePage => 'ಪೂರ್ಣ ಪುಟದ ಚಿತ್ರ ತೆಗೆಯಿರಿ';

  @override
  String get supportedFormats => 'ಬೆಂಬಲಿತ ಸ್ವರೂಪಗಳು: PDF, JPG, PNG';

  @override
  String get confirmFile => 'ನೀವು ಸೇರಿಸಲು ಬಯಸುವ ಫೈಲ್ ಇದೇ ಎಂದು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.';

  @override
  String get addReport => 'ವರದಿ ಸೇರಿಸಿ';

  @override
  String get chooseDifferentFile => 'ಬೇರೆ ಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uploadWait =>
      'ಇದಕ್ಕೆ ಸ್ವಲ್ಪ ಸಮಯ ಬೇಕಾಗಬಹುದು. ದಯವಿಟ್ಟು ಆ್ಯಪ್ ತೆರೆದಿಡಿ.';

  @override
  String get reportNeedsAttention => 'ವರದಿಗೆ ಗಮನ ನೀಡಬೇಕಿದೆ';

  @override
  String get verifyBeforeSaving =>
      'ಪತ್ತೆಯಾದ ಫಲಿತಾಂಶಗಳನ್ನು ಉಳಿಸುವ ಮೊದಲು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಸಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get viewVerifiedResults => 'ದೃಢೀಕರಿಸಿದ ಫಲಿತಾಂಶಗಳನ್ನು ನೋಡಿ';

  @override
  String get viewOriginalReport => 'ಮೂಲ ವರದಿ ನೋಡಿ';

  @override
  String get viewReportStatus => 'ವರದಿಯ ಸ್ಥಿತಿ ನೋಡಿ';

  @override
  String get viewResults => 'ಫಲಿತಾಂಶಗಳನ್ನು ನೋಡಿ';

  @override
  String get viewOriginalFile => 'ಮೂಲ ಫೈಲ್ ನೋಡಿ';

  @override
  String get retryExtraction => 'ಫಲಿತಾಂಶಗಳನ್ನು ಹೊರತೆಗೆಯಲು ಮರುಪ್ರಯತ್ನಿಸಿ';

  @override
  String get done => 'ಮುಗಿಯಿತು';

  @override
  String get duplicateReport => 'ಈ ವರದಿ ನಕಲಿನಂತೆ ಕಾಣುತ್ತಿದೆ';

  @override
  String get duplicateHelp => 'ಈ ಫೈಲ್ ಈಗಾಗಲೇ ನಿಮ್ಮ ವರದಿಗಳಲ್ಲಿ ಇರಬಹುದು.';

  @override
  String get keepExisting => 'ಈಗಿರುವುದನ್ನೇ ಉಳಿಸಿಕೊಳ್ಳಿ';

  @override
  String get processAgain => 'PDF ಅನ್ನು ಮತ್ತೆ ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಿ';

  @override
  String get uploadNewCopy => 'ಹೊಸ ಪ್ರತಿಯಾಗಿ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get reportLimitReached => 'ವರದಿಗಳ ಮಿತಿ ತಲುಪಿದೆ';

  @override
  String get reportLimitHelp => 'ನಿಮ್ಮ ವರದಿಗಳ ಮಿತಿಯನ್ನು ತಲುಪಿದ್ದೀರಿ.';

  @override
  String get upgrade => 'ಮೇಲ್ದರ್ಜೆಯ ಯೋಜನೆಗೆ ಬದಲಾಯಿಸಿ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get uploadFailedTitle => 'ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get uploadFailed => 'ಅಪ್‌ಲೋಡ್ ವಿಫಲವಾಗಿದೆ';

  @override
  String get retrySameFile => 'ಅದೇ ಫೈಲ್‌ನೊಂದಿಗೆ ಮರುಪ್ರಯತ್ನಿಸಿ';

  @override
  String get chooseAnotherFile => 'ಇನ್ನೊಂದು ಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get aiDisclaimer =>
      'ನಿಮ್ಮ ಆರೋಗ್ಯ ವರದಿಗಳನ್ನು ವ್ಯವಸ್ಥಿತವಾಗಿ ಇರಿಸಲು ಮತ್ತು ಉತ್ತಮವಾಗಿ ಅರ್ಥಮಾಡಿಕೊಳ್ಳಲು Doclyzer ನೆರವಾಗುತ್ತದೆ. ನೀಡಲಾದ ಮಾಹಿತಿ ಶೈಕ್ಷಣಿಕ ಉದ್ದೇಶಗಳಿಗೆ ಮಾತ್ರ; ಇದು ವೈದ್ಯಕೀಯ ಸಲಹೆ, ರೋಗನಿರ್ಣಯ ಅಥವಾ ಚಿಕಿತ್ಸೆ ಅಲ್ಲ. ವೈದ್ಯಕೀಯ ಮಾರ್ಗದರ್ಶನಕ್ಕಾಗಿ ಯಾವಾಗಲೂ ಅರ್ಹ ಆರೋಗ್ಯ ವೃತ್ತಿಪರರನ್ನು ಸಂಪರ್ಕಿಸಿ.';

  @override
  String collectedOn(String date) {
    return 'ಸಂಗ್ರಹಿಸಿದ ದಿನಾಂಕ $date';
  }

  @override
  String uploadedOn(String date) {
    return 'ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ದಿನಾಂಕ $date';
  }

  @override
  String labRangeValue(String range) {
    return 'ಪ್ರಯೋಗಾಲಯದ ವ್ಯಾಪ್ತಿ $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits ಕ್ರೆಡಿಟ್‌ಗಳು';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ವರದಿಗಳು',
      one: '1 ವರದಿ',
      zero: 'ವರದಿಗಳಿಲ್ಲ',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'ವರದಿ ಲೋಡ್ ಆಗಲು ನಿರೀಕ್ಷೆಗಿಂತ ಹೆಚ್ಚು ಸಮಯ ತೆಗೆದುಕೊಳ್ಳುತ್ತಿದೆ. ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ, ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get summaryUpdateFailed =>
      'ಈಗ ಸಾರಾಂಶವನ್ನು ನವೀಕರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಉಳಿಸಿದ ಸಾರಾಂಶ ಇನ್ನೂ ಲಭ್ಯವಿದೆ.';

  @override
  String get summaryCreateFailed =>
      'ಈಗ ಸಾರಾಂಶವನ್ನು ರಚಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಫಲಿತಾಂಶಗಳು ಕೆಳಗೆ ಇನ್ನೂ ಲಭ್ಯವಿವೆ.';

  @override
  String get reassignFailed =>
      'ವರದಿಯನ್ನು ಬೇರೆ ಪ್ರೊಫೈಲ್‌ಗೆ ನಿಯೋಜಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get confirmRecycle => 'ಮರುಬಳಕೆ ಬುಟ್ಟಿಗೆ ಸರಿಸಬೇಕೇ?';

  @override
  String get recycleHelp =>
      '30 ದಿನಗಳವರೆಗೆ ವರದಿಗಳು > ಮರುಬಳಕೆ ಬುಟ್ಟಿಯಿಂದ ಈ ವರದಿಯನ್ನು ಮರುಸ್ಥಾಪಿಸಬಹುದು. ಅದರ ನಂತರ, ಅದನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get reportRecycled => 'ವರದಿಯನ್ನು ಮರುಬಳಕೆ ಬುಟ್ಟಿಗೆ ಸರಿಸಲಾಗಿದೆ';

  @override
  String get reportDeleteFailed =>
      'ವರದಿಯನ್ನು ಅಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get addProfileBeforeMove =>
      'ಈ ವರದಿಯನ್ನು ಸ್ಥಳಾಂತರಿಸುವ ಮೊದಲು ಕುಟುಂಬದ ಇನ್ನೊಂದು ಪ್ರೊಫೈಲ್ ಸೇರಿಸಿ.';

  @override
  String get moveReportHelp =>
      'ಈ ವರದಿಯನ್ನು ತಪ್ಪು ಪ್ರೊಫೈಲ್‌ಗೆ ಸೇರಿಸಿದ್ದರೆ ಕುಟುಂಬದ ಇನ್ನೊಬ್ಬ ಸದಸ್ಯರನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get confirmMoveReport => 'ಈ ವರದಿಯನ್ನು ಸ್ಥಳಾಂತರಿಸಬೇಕೇ?';

  @override
  String get aboutSampleDates => 'ಮಾದರಿ ಪಡೆದ ದಿನಾಂಕಗಳ ಕುರಿತು';

  @override
  String get multipleDatesHelp =>
      'ಈ ವರದಿಯಲ್ಲಿ ಒಂದಕ್ಕಿಂತ ಹೆಚ್ಚು ದಿನಾಂಕಗಳಲ್ಲಿ ಪಡೆದ ಮಾದರಿಗಳ ಫಲಿತಾಂಶಗಳಿವೆ. ಫಲಿತಾಂಶವನ್ನು ತೆರೆದು ಅದರ ದಿನಾಂಕವನ್ನು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಸಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get missingDateHelp =>
      'ಮಾದರಿ ಪಡೆದ ದಿನಾಂಕ ಎಂದರೆ ಮಾದರಿಯನ್ನು ತೆಗೆದುಕೊಂಡ ದಿನ. ಈ ವರದಿಯಲ್ಲಿ ವಿಶ್ವಾಸಾರ್ಹ ದಿನಾಂಕವನ್ನು ಕಂಡುಹಿಡಿಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮಾದರಿ ಪಡೆದ ದಿನಾಂಕವು ಅಪ್‌ಲೋಡ್ ದಿನಾಂಕಕ್ಕಿಂತ ಭಿನ್ನವಾಗಿದೆ. ಫಲಿತಾಂಶದ ದಿನಾಂಕವನ್ನು ಪರಿಶೀಲಿಸಲು ಅಥವಾ ಸರಿಪಡಿಸಲು ಅದನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get uploading => 'ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ';

  @override
  String get waitingToProcess => 'ಪ್ರಕ್ರಿಯೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get readingReport => 'ವರದಿಯನ್ನು ಓದಲಾಗುತ್ತಿದೆ';

  @override
  String get readyToReview => 'ಪರಿಶೀಲನೆಗೆ ಸಿದ್ಧವಾಗಿದೆ';

  @override
  String get someResultsNeedReview => 'ಕೆಲವು ಫಲಿತಾಂಶಗಳ ಪರಿಶೀಲನೆ ಅಗತ್ಯವಿದೆ';

  @override
  String get couldNotReadReport => 'ವರದಿಯನ್ನು ಓದಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get processingStopped => 'ಪ್ರಕ್ರಿಯೆ ನಿಂತಿದೆ';

  @override
  String get couldNotProcessReport =>
      'ವರದಿಯನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get reportRefreshFailed =>
      'ಈ ವರದಿಯನ್ನು ಮತ್ತೆ ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಕೊನೆಯದಾಗಿ ಲೋಡ್ ಮಾಡಿದ ಫಲಿತಾಂಶವನ್ನು ತೋರಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get multipleSampleDates => 'ಮಾದರಿ ಪಡೆದ ಹಲವು ದಿನಾಂಕಗಳು ';

  @override
  String get missingSampleDate => 'ಮಾದರಿ ಪಡೆದ ದಿನಾಂಕ ಕಂಡುಬಂದಿಲ್ಲ ';

  @override
  String get reportAnalyzing =>
      'ನಾವು ಈ ವರದಿಯನ್ನು ವಿಶ್ಲೇಷಿಸುತ್ತಿದ್ದೇವೆ. ನೀವು ಈ ಪರದೆಯಿಂದ ಹೊರಹೋಗಬಹುದು; ಫಲಿತಾಂಶಗಳು ಸಿದ್ಧವಾದಾಗ ಕಾಣಿಸುತ್ತವೆ.';

  @override
  String get extractionIncompleteTitle =>
      'ಎಲ್ಲ ಫಲಿತಾಂಶಗಳನ್ನು ವಿಶ್ವಾಸಾರ್ಹವಾಗಿ ಹೊರತೆಗೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get extractionIncompleteHelp =>
      'ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಹೊರತೆಗೆಯುವ ಪ್ರಕ್ರಿಯೆ ಅಪೂರ್ಣವಾಗಿದೆ. ಪತ್ತೆಯಾದ ಸಾಲುಗಳನ್ನು ಉಳಿಸುವ ಮೊದಲು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಸಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get verifiedRowsHelp =>
      'ಈ ಸಾಲುಗಳನ್ನು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಸಿ ಪರಿಶೀಲಿಸಲಾಗಿದೆ. ಇತರ ಸಾಲುಗಳ ಪರಿಶೀಲನೆ ಇನ್ನೂ ಅಗತ್ಯವಿರಬಹುದು.';

  @override
  String get noTestValues =>
      'ಈ ವರದಿಯಲ್ಲಿ ಯಾವುದೇ ಪರೀಕ್ಷಾ ಮೌಲ್ಯಗಳು ಕಂಡುಬಂದಿಲ್ಲ. ಅದರಲ್ಲಿರುವ ವಿಷಯವನ್ನು ಪರಿಶೀಲಿಸಲು ಮೂಲ ಫೈಲ್ ತೆರೆಯಿರಿ.';

  @override
  String get processingRetryHelp =>
      'ಪೂರ್ಣಗೊಳ್ಳುವ ಮೊದಲೇ ಪ್ರಕ್ರಿಯೆ ನಿಂತಿದೆ. ನಿಮ್ಮ ಫೈಲ್ ಉಳಿಸಲಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ‘ಮರುಪ್ರಯತ್ನಿಸಿ’ ಅನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get resultsNeedCheck =>
      'ಕೆಲವು ಫಲಿತಾಂಶಗಳನ್ನು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಸಿ ಪರಿಶೀಲಿಸಬೇಕಿದೆ. ಪತ್ತೆಯಾದ ಸಾಲುಗಳನ್ನು ಕೆಳಗೆ ಪರಿಶೀಲಿಸಬಹುದು.';

  @override
  String get readerModeHelp =>
      'ಸುಲಭವಾಗಿ ತೆರೆಯಲು ಮತ್ತು ಓದಲು ಅನುಕೂಲವಾಗುವಂತೆ, ಮಾಹಿತಿ ಹೊರತೆಗೆದು ಸಿದ್ಧಪಡಿಸಿದ ವರದಿ ಓದುವ ಕ್ರಮದಲ್ಲಿ ಲಭ್ಯವಿದೆ.';

  @override
  String get aiRangeHelp =>
      'ಪ್ರಕ್ರಿಯೆಯ ಸಮಯದಲ್ಲಿ AI ವ್ಯಾಪ್ತಿಯನ್ನು ಅರ್ಥೈಸಿದೆ. ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get checkResultHelp =>
      'ಈ ಫಲಿತಾಂಶವನ್ನು ಅವಲಂಬಿಸುವ ಮೊದಲು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಸಿ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get preferredRangeHelp =>
      'ಪ್ರಯೋಗಾಲಯ ಮುದ್ರಿಸಿರುವ ಆದ್ಯತೆಯ ವರ್ಗದೊಂದಿಗೆ ಹೋಲಿಸಲಾಗಿದೆ; ಅದು ನಿಮಗೆ ಅನ್ವಯಿಸುತ್ತದೆಯೇ ಎಂದು ದೃಢಪಡಿಸಿಕೊಳ್ಳಿ.';

  @override
  String get categoryComparisonHelp =>
      'ಈ ಹೋಲಿಕೆಗೆ ಪ್ರಯೋಗಾಲಯ ಮುದ್ರಿಸಿರುವ ಆದ್ಯತೆಯ ವರ್ಗವನ್ನು ಬಳಸಲಾಗಿದೆ. ಆ ವರ್ಗವು ನಿಮಗೆ ಅನ್ವಯಿಸುತ್ತದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get missingSavedResult =>
      'ಈ ಮೌಲ್ಯವನ್ನು ಉಳಿಸಿದ ಫಲಿತಾಂಶದೊಂದಿಗೆ ಹೊಂದಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ ಅಥವಾ ಈ ವರದಿಯನ್ನು ಮತ್ತೆ ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get unreviewedTest =>
      'AI ವಿವರಣೆಗಳಿಗಾಗಿ ಈ ಪರೀಕ್ಷೆಯನ್ನು ಇನ್ನೂ ಪರಿಶೀಲಿಸಲಾಗಿಲ್ಲ. ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಫಲಿತಾಂಶದ ಬಗ್ಗೆ ನಿಮ್ಮ ವೈದ್ಯರೊಂದಿಗೆ ಚರ್ಚಿಸಿ.';

  @override
  String get unsafeResult =>
      'ಹೊರತೆಗೆದ ಫಲಿತಾಂಶ ಅಸ್ಪಷ್ಟವಾಗಿದೆ, ಆದ್ದರಿಂದ ಅದನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ವಿವರಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get filterReports => 'ವರದಿಗಳನ್ನು ಫಿಲ್ಟರ್ ಮಾಡಿ';

  @override
  String get sortReports => 'ವರದಿಗಳನ್ನು ವಿಂಗಡಿಸಿ';

  @override
  String get recycleBin => 'ಮರುಬಳಕೆ ಬುಟ್ಟಿ';

  @override
  String get healthHistory => 'ಆರೋಗ್ಯ ಇತಿಹಾಸ';

  @override
  String get shareProfile => 'ಪ್ರೊಫೈಲ್ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get reportsUnavailableTitle => 'ವರದಿಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get reportsLoadFailed =>
      'ವರದಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಸಂಪರ್ಕ ದೊರೆತಾಗ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get upload => 'ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get reportsFor => 'ಇವರ ವರದಿಗಳು';

  @override
  String get searchReports => 'ವರದಿಗಳು ಅಥವಾ ಪ್ರಯೋಗಾಲಯಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get filters => 'ಫಿಲ್ಟರ್‌ಗಳು';

  @override
  String get noReportsYet => 'ಇನ್ನೂ ವರದಿಗಳಿಲ್ಲ';

  @override
  String get noMatchingReports => 'ನಿಮ್ಮ ಹುಡುಕಾಟಕ್ಕೆ ಹೊಂದುವ ವರದಿಗಳಿಲ್ಲ.';

  @override
  String get differentSearch =>
      'ಬೇರೆ ಪರೀಕ್ಷೆ, ಪ್ರಯೋಗಾಲಯ ಅಥವಾ ಫಿಲ್ಟರ್ ಬಳಸಿ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get clearFilters => 'ಹುಡುಕಾಟ ಮತ್ತು ಫಿಲ್ಟರ್‌ಗಳನ್ನು ತೆರವುಗೊಳಿಸಿ';

  @override
  String get original => 'ಮೂಲ';

  @override
  String get switchActiveProfile => 'ಸಕ್ರಿಯ ಪ್ರೊಫೈಲ್ ಬದಲಾಯಿಸಿ';

  @override
  String get switchProfileHelp =>
      'ಇನ್ನೊಬ್ಬ ವ್ಯಕ್ತಿಯ ವರದಿಗಳನ್ನು ನೋಡಿ. ಅಪ್‌ಲೋಡ್‌ಗಳು ಮತ್ತು ಪ್ರವೃತ್ತಿಗಳಿಗೆ ಬಳಸುವ ನಿಮ್ಮ ಸಕ್ರಿಯ ಪ್ರೊಫೈಲ್ ಕೂಡ ಬದಲಾಗುತ್ತದೆ.';

  @override
  String get multipleCollectionDates => 'ಮಾದರಿ ಸಂಗ್ರಹಿಸಿದ ಹಲವು ದಿನಾಂಕಗಳು';

  @override
  String get unknownCollectionDate => 'ಮಾದರಿ ಸಂಗ್ರಹಿಸಿದ ದಿನಾಂಕ ತಿಳಿದಿಲ್ಲ';

  @override
  String get profileLoadFailed =>
      'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get pleaseTryAgain => 'ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get deleteProfileConfirm => 'ಪ್ರೊಫೈಲ್ ಅಳಿಸಬೇಕೇ?';

  @override
  String get deleteProfileHelp =>
      'ಈ ಪ್ರೊಫೈಲ್ ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ. ಇದಕ್ಕೆ ಸಂಬಂಧಿಸಿದ ಯಾವುದೇ ಡೇಟಾದ ಮೇಲೆ ಪರಿಣಾಮ ಬೀರುತ್ತದೆ.';

  @override
  String get profileDeleteFailed =>
      'ಪ್ರೊಫೈಲ್ ಅಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get addFamilyMember => 'ಕುಟುಂಬದ ಸದಸ್ಯರನ್ನು ಸೇರಿಸಿ';

  @override
  String get familyUnavailable => 'ಕುಟುಂಬದ ಪ್ರೊಫೈಲ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get familyIntro =>
      'ವ್ಯಕ್ತಿಗನುಸಾರ ವ್ಯವಸ್ಥಿತಗೊಳಿಸಿದ ವರದಿಗಳು ಮತ್ತು ಪ್ರವೃತ್ತಿಗಳು';

  @override
  String get noProfilesYet => 'ಇನ್ನೂ ಪ್ರೊಫೈಲ್‌ಗಳಿಲ್ಲ';

  @override
  String get noProfilesHelp =>
      'ನಿಮ್ಮ ಅಥವಾ ಕುಟುಂಬದ ಸದಸ್ಯರ ವರದಿಗಳನ್ನು ವ್ಯವಸ್ಥಿತವಾಗಿ ಇರಿಸಲು ಪ್ರೊಫೈಲ್ ಸೇರಿಸಿ.';

  @override
  String get yourFamily => 'ನಿಮ್ಮ ಕುಟುಂಬ';

  @override
  String get upgradeProfiles =>
      'ಇನ್ನಷ್ಟು ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಸೇರಿಸಲು ಮೇಲ್ದರ್ಜೆಯ ಯೋಜನೆಗೆ ಬದಲಾಯಿಸಿ';

  @override
  String get editProfile => 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ';

  @override
  String get deleteProfile => 'ಪ್ರೊಫೈಲ್ ಅಳಿಸಿ';

  @override
  String get active => 'ಸಕ್ರಿಯ';

  @override
  String get setActive => 'ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get viewReports => 'ವರದಿಗಳನ್ನು ನೋಡಿ';

  @override
  String get notNow => 'ಈಗ ಬೇಡ';

  @override
  String get openSettings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get enableNotifications => 'ಅಧಿಸೂಚನೆಗಳನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get enableNotificationsConfirm => 'ಅಧಿಸೂಚನೆಗಳನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಬೇಕೇ?';

  @override
  String get notificationsEnabled => 'ವರದಿಯ ಅಧಿಸೂಚನೆಗಳನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get notificationsStayOff =>
      'ಅಧಿಸೂಚನೆಗಳು ನಿಷ್ಕ್ರಿಯವಾಗಿಯೇ ಇವೆ. ನಂತರ ಸಾಧನದ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಬಹುದು.';

  @override
  String get notificationsFailed =>
      'ಅಧಿಸೂಚನೆಗಳನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ, ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get switchProfileFailed =>
      'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get sourceReportFailed => 'ಮೂಲ ವರದಿಯನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';

  @override
  String get partialRefreshFailed =>
      'ಕೆಲವು ಮಾಹಿತಿಯನ್ನು ಮತ್ತೆ ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಕೆಳಕ್ಕೆ ಎಳೆಯಿರಿ.';

  @override
  String get knowReportReady => 'ನಿಮ್ಮ ವರದಿ ಸಿದ್ಧವಾದಾಗ ತಿಳಿದುಕೊಳ್ಳಿ';

  @override
  String get oneResult => 'ಒಂದು ಫಲಿತಾಂಶ';

  @override
  String get sameDayResults => 'ಒಂದೇ ದಿನದ ಫಲಿತಾಂಶಗಳು';

  @override
  String get verificationRequired => 'ದೃಢೀಕರಣ ಅಗತ್ಯವಿದೆ';

  @override
  String get accountCreatedLogin =>
      'ನಿಮ್ಮ ಖಾತೆಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ರಚಿಸಲಾಗಿದೆ. ಲಾಗಿನ್ ಮಾಡಲು ಮುಂದುವರಿಯಿರಿ.';

  @override
  String get continueLogin => 'ಲಾಗಿನ್ ಮಾಡಲು ಮುಂದುವರಿಯಿರಿ';

  @override
  String get allReports => 'ಎಲ್ಲ ವರದಿಗಳು';

  @override
  String get filterReviewed => 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get filterNeedsReview => 'ಪರಿಶೀಲನೆ ಅಗತ್ಯವಿದೆ';

  @override
  String get filterProcessing => 'ಪ್ರಕ್ರಿಯೆ ನಡೆಯುತ್ತಿದೆ';

  @override
  String get filterOriginalOnly => 'ಮೂಲ ಮಾತ್ರ';

  @override
  String get reportDateNewest => 'ವರದಿ ದಿನಾಂಕ · ಹೊಸದು ಮೊದಲು';

  @override
  String get reportDateOldest => 'ವರದಿ ದಿನಾಂಕ · ಹಳೆಯದು ಮೊದಲು';

  @override
  String get uploadDateNewest => 'ಅಪ್‌ಲೋಡ್ ದಿನಾಂಕ · ಹೊಸದು ಮೊದಲು';

  @override
  String get uploadDateOldest => 'ಅಪ್‌ಲೋಡ್ ದಿನಾಂಕ · ಹಳೆಯದು ಮೊದಲು';

  @override
  String get switchAction => 'ಬದಲಾಯಿಸಿ';

  @override
  String get collectionDate => 'ಮಾದರಿ ಸಂಗ್ರಹಿಸಿದ ದಿನಾಂಕ';

  @override
  String get copy => 'ನಕಲಿಸಿ';

  @override
  String get history => 'ಇತಿಹಾಸ';

  @override
  String get loadingReport => 'ವರದಿ ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get restore => 'ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get revoke => 'ಹಿಂಪಡೆಯಿರಿ';

  @override
  String get testName => 'ಪರೀಕ್ಷೆಯ ಹೆಸರು';

  @override
  String get viewReport => 'ವರದಿ ನೋಡಿ';

  @override
  String get closeAccount => 'ಖಾತೆ ಮುಚ್ಚಿ';

  @override
  String get createShareLink => 'ಹಂಚಿಕೊಳ್ಳುವ ಲಿಂಕ್ ರಚಿಸಿ';

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'ಗೋಚರತೆ ಬದಲಾಗಿದೆ, ಆದರೆ ಮುಂದಿನ ಬಾರಿಗೆ ಉಳಿಸಲಾಗಲಿಲ್ಲ.';

  @override
  String get uiThisReportIsNoLongerAvailable => 'ಈ ವರದಿ ಇನ್ನು ಮುಂದೆ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'ಅಧಿಸೂಚನೆ ಪೂರ್ವವೀಕ್ಷಣೆಗಳನ್ನು ನಿರ್ವಹಿಸಲು ಸಾಧನ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'ಅಪ್‌ಲೋಡ್ ಸ್ವೀಕರಿಸುವವರೆಗೆ ಈ ಪರದೆಯನ್ನು ತೆರೆದಿಡಿ.';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'ಅಪ್‌ಲೋಡ್‌ಗೆ ಅಡಚಣೆ ಉಂಟಾಗಿರಬಹುದು';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'ವರದಿಗಳನ್ನು ಪರಿಶೀಲಿಸಿ. ಅದು ಕಾಣೆಯಾಗಿದ್ದರೆ, ಅದೇ ಫೈಲ್ ಅನ್ನು ಮತ್ತೆ ಸೇರಿಸಿ.';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'ಅಧಿಸೂಚನೆಗಳನ್ನು ವಜಾಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiConnectionUnavailable => 'ಸಂಪರ್ಕ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'ನಿಮ್ಮ ಅಧಿವೇಶನವನ್ನು ಪರಿಶೀಲಿಸಲಾಗಲಿಲ್ಲ. ಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiSignInWithAnotherAccount => 'ಮತ್ತೊಂದು ಖಾತೆಯೊಂದಿಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String get uiNoActiveProfile => 'ಸಕ್ರಿಯ ಪ್ರೊಫೈಲ್ ಇಲ್ಲ';

  @override
  String get uiDismissUploadNotice => 'ಅಪ್‌ಲೋಡ್ ಸೂಚನೆಯನ್ನು ವಜಾಗೊಳಿಸಿ';

  @override
  String get uiDismissReadyNotifications => 'ಸಿದ್ಧ ಅಧಿಸೂಚನೆಗಳನ್ನು ವಜಾಗೊಳಿಸಿ';

  @override
  String get uiRequestSupport => 'ಬೆಂಬಲವನ್ನು ವಿನಂತಿಸಿ';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'ನಾವು ಡಯಾಗ್ನೋಸ್ಟಿಕ್ ಐಡಿಗಳನ್ನು ಸೇರಿಸುತ್ತೇವೆ ಆದ್ದರಿಂದ ತಂಡವು ತನಿಖೆ ಮಾಡಬಹುದು.';

  @override
  String get uiSendRequest => 'ವಿನಂತಿಯನ್ನು ಕಳುಹಿಸಿ';

  @override
  String get uiWhatHappenedOptional => 'ಏನಾಯಿತು? (ಐಚ್ಛಿಕ)';

  @override
  String get uiReviewResult => 'ಫಲಿತಾಂಶವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'ಉಳಿಸುವ ಮೊದಲು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಈ ಕ್ಷೇತ್ರಗಳನ್ನು ಹೋಲಿಕೆ ಮಾಡಿ.';

  @override
  String get uiOriginallyExtracted => 'ಮೂಲತಃ ಹೊರತೆಗೆಯಲಾಗಿದೆ';

  @override
  String get uiReloadReport => 'ವರದಿಯನ್ನು ಮರುಲೋಡ್ ಮಾಡಿ';

  @override
  String get uiResultAsPrinted => 'ಮುದ್ರಿತ ಫಲಿತಾಂಶ';

  @override
  String get uiUnitIfShown => 'ಘಟಕ (ತೋರಿಸಿದರೆ)';

  @override
  String get uiLabReferenceRangeIfShown => 'ಲ್ಯಾಬ್ ಉಲ್ಲೇಖ ಶ್ರೇಣಿ (ತೋರಿಸಿದರೆ)';

  @override
  String get uiCheckYourReport => 'ನಿಮ್ಮ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get uiNoAttemptHistoryAvailable => 'ಯಾವುದೇ ಪ್ರಯತ್ನದ ಇತಿಹಾಸ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get uiIInspectedTheOriginal => 'ನಾನು ಮೂಲವನ್ನು ಪರಿಶೀಲಿಸಿದೆ';

  @override
  String get uiChooseTwoReports => 'ಎರಡು ವರದಿಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'ಒಂದೇ ವ್ಯಕ್ತಿಗೆ ದಾಖಲೆಗಳನ್ನು ಬಳಸಿ. ಹೊಂದಾಣಿಕೆಯ ಪರೀಕ್ಷೆಗಳು ಅಕ್ಕಪಕ್ಕದಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'ಹಳೆಯ ವರದಿಯನ್ನು ಮೊದಲು ಮತ್ತು ಹೊಸ ವರದಿಯನ್ನು ಎರಡನೆಯದನ್ನು ಆರಿಸಿ.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'ಹೊಂದಾಣಿಕೆಯಾದಾಗ ಮಾತ್ರ ಹೋಲಿಸಲಾಗುತ್ತದೆ. ಹೊಂದಾಣಿಕೆಯನ್ನು ದೃಢೀಕರಿಸುವವರೆಗೆ ವಿಭಿನ್ನ ಘಟಕಗಳು ಅಥವಾ ವಿಧಾನಗಳನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ತೋರಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'ಬದಲಾವಣೆಯು ರೋಗನಿರ್ಣಯವಲ್ಲ. ಪ್ರತಿ ಫಲಿತಾಂಶವನ್ನು ಅದರ ಸ್ವಂತ ವರದಿಯ ಮಧ್ಯಂತರದೊಂದಿಗೆ ಹೋಲಿಕೆ ಮಾಡಿ ಮತ್ತು ನಿಮ್ಮ ವೈದ್ಯರೊಂದಿಗೆ ಸಂದರ್ಭವನ್ನು ಚರ್ಚಿಸಿ.';

  @override
  String get uiChooseDifferentReports => 'ವಿಭಿನ್ನ ವರದಿಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uiEarlierReport => 'ಹಿಂದಿನ ವರದಿ';

  @override
  String get uiLaterReport => 'ನಂತರ ವರದಿ';

  @override
  String get uiYourReportPages => 'ನಿಮ್ಮ ವರದಿ ಪುಟಗಳು';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'ವರದಿಯಂತೆಯೇ ಪುಟಗಳನ್ನು ಅದೇ ಕ್ರಮದಲ್ಲಿ ಇರಿಸಿ.';

  @override
  String get uiAddAnotherPage => 'ಇನ್ನೊಂದು ಪುಟವನ್ನು ಸೇರಿಸಿ';

  @override
  String get uiChoosePagesFromGallery => 'ಗ್ಯಾಲರಿಯಿಂದ ಪುಟಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uiAdjustPage => 'ಪುಟವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get uiRetake => 'ಮರುಪಡೆಯಿರಿ';

  @override
  String get uiUseAdjustedPage => 'ಹೊಂದಿಸಲಾದ ಪುಟವನ್ನು ಬಳಸಿ';

  @override
  String get uiResetChanges => 'ಬದಲಾವಣೆಗಳನ್ನು ಮರುಹೊಂದಿಸಿ';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'ಪ್ರತಿಯೊಂದು ಫಲಿತಾಂಶವನ್ನು ಮೂಲೆಗಳಲ್ಲಿ ಇರಿಸಿ.';

  @override
  String get uiRotate => 'ತಿರುಗಿಸಿ';

  @override
  String get uiReportRestored => 'ವರದಿಯನ್ನು ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ';

  @override
  String get uiDeleteReportPermanently => 'ವರದಿಯನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುವುದೇ?';

  @override
  String get uiDeletePermanently => 'ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಿ';

  @override
  String get uiReportPermanentlyDeleted => 'ವರದಿಯನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗಿದೆ';

  @override
  String get uiEmptyRecycleBin => 'ಖಾಲಿ ಮರುಬಳಕೆ ಬಿನ್?';

  @override
  String get uiDeleteAll => 'ಎಲ್ಲವನ್ನೂ ಅಳಿಸಿ';

  @override
  String get uiRecycleBinIsEmpty => 'ಮರುಬಳಕೆ ಬಿನ್ ಖಾಲಿಯಾಗಿದೆ.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'ತೆಗೆದುಹಾಕುವ ಮೊದಲು ಅಳಿಸಿದ ವರದಿಗಳು ಇಲ್ಲಿ ಗೋಚರಿಸುತ್ತವೆ.';

  @override
  String get uiEmptyRecycleBind657e2 => 'ಖಾಲಿ ಮರುಬಳಕೆ ಬಿನ್';

  @override
  String get uiCheckDetectedResult => 'ಪತ್ತೆಯಾದ ಫಲಿತಾಂಶವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'ಈ ಸಾಲನ್ನು ಮೂಲ ವರದಿಯೊಂದಿಗೆ ಹೋಲಿಕೆ ಮಾಡಿ. ಉಳಿಸುವ ಮೊದಲು ಯಾವುದೇ OCR ತಪ್ಪುಗಳನ್ನು ಸರಿಪಡಿಸಿ.';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'ನಾನು ಈ ಫಲಿತಾಂಶವನ್ನು ಮೂಲ ವರದಿಗೆ ವಿರುದ್ಧವಾಗಿ ಪರಿಶೀಲಿಸಿದ್ದೇನೆ';

  @override
  String get uiSaving => 'ಉಳಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get uiSaveVerifiedResult => 'ಪರಿಶೀಲಿಸಿದ ಫಲಿತಾಂಶವನ್ನು ಉಳಿಸಿ';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'ಯಾವುದೇ ಫಲಿತಾಂಶಗಳು ಪತ್ತೆಯಾಗಿಲ್ಲ. ಮೂಲ ವರದಿಯನ್ನು ವೀಕ್ಷಿಸಿ ಅಥವಾ ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲು ಮರುಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'ಪತ್ತೆಯಾದ ಮೌಲ್ಯಗಳನ್ನು ಉಳಿಸಿದ ಫಲಿತಾಂಶಗಳಾಗುವ ಮೊದಲು ಮೂಲ ವರದಿಯ ವಿರುದ್ಧ ಪರಿಶೀಲಿಸಬೇಕಾಗುತ್ತದೆ.';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'ಕೆಲವು ಸಾಲುಗಳು ಕಾಣೆಯಾಗಿರಬಹುದು. ಸಂಪೂರ್ಣ ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiResult => 'ಫಲಿತಾಂಶ';

  @override
  String get uiUnitOptional => 'ಘಟಕ (ಐಚ್ಛಿಕ)';

  @override
  String get uiReferenceRangeOptional => 'ಉಲ್ಲೇಖ ಶ್ರೇಣಿ (ಐಚ್ಛಿಕ)';

  @override
  String get uiVerified => 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get uiGiftVoucher => 'ಗಿಫ್ಟ್ ವೋಚರ್';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'ಉಡುಗೊರೆ ವೋಚರ್ ಅನ್ನು ರಿಡೀಮ್ ಮಾಡಿ ಮತ್ತು ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ನೇರವಾಗಿ ನಿಮ್ಮ ಬ್ಯಾಲೆನ್ಸ್‌ಗೆ ಸೇರಿಸಿ.';

  @override
  String get uiCurrentPlan => 'ಪ್ರಸ್ತುತ ಯೋಜನೆ';

  @override
  String get uiCreditBalance => 'ಕ್ರೆಡಿಟ್ ಬ್ಯಾಲೆನ್ಸ್';

  @override
  String get uiPlanLimits => 'ಯೋಜನೆ ಮಿತಿಗಳು';

  @override
  String get uiBuyCredits => 'ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಖರೀದಿಸಿ';

  @override
  String get uiRecentBillingActivity => 'ಇತ್ತೀಚಿನ ಬಿಲ್ಲಿಂಗ್ ಚಟುವಟಿಕೆ';

  @override
  String get uiRefreshStatus => 'ಸ್ಥಿತಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ';

  @override
  String get uiNoRecentOrdersYet => 'ಇನ್ನೂ ಯಾವುದೇ ಇತ್ತೀಚಿನ ಆದೇಶಗಳಿಲ್ಲ.';

  @override
  String get uiVoucherCode => 'ವೋಚರ್ ಕೋಡ್';

  @override
  String get uiCheckout => 'ಚೆಕ್ಔಟ್';

  @override
  String get uiApply => 'ಅನ್ವಯಿಸು';

  @override
  String get uiClear => 'ತೆರವುಗೊಳಿಸಿ';

  @override
  String get uiPay => 'ಪಾವತಿಸಿ';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'ಈ ಸಮಯದಲ್ಲಿ ಯಾವುದೇ ಕ್ರೆಡಿಟ್ ಪ್ಯಾಕ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get uiBuy => 'ಖರೀದಿಸಿ';

  @override
  String get uiRetryPayment => 'ಪಾವತಿಯನ್ನು ಮರುಪ್ರಯತ್ನಿಸಿ';

  @override
  String get uiPromoCode => 'ಪ್ರೋಮೋ ಕೋಡ್';

  @override
  String get uiEnterPromoCode => 'ಪ್ರೋಮೋ ಕೋಡ್ ನಮೂದಿಸಿ';

  @override
  String get uiChooseAPlan => 'ಯೋಜನೆಯನ್ನು ಆರಿಸಿ';

  @override
  String get uiNoPlansAvailableAtThisTime =>
      'ಈ ಸಮಯದಲ್ಲಿ ಯಾವುದೇ ಯೋಜನೆಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get uiHaveAPromoCode => 'ಪ್ರೋಮೋ ಕೋಡ್ ಹೊಂದಿರುವಿರಾ?';

  @override
  String get uiCURRENTPLAN => 'ಪ್ರಸ್ತುತ ಯೋಜನೆ';

  @override
  String get uiManageNotifications => 'ಅಧಿಸೂಚನೆಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get uiAll => 'ಎಲ್ಲಾ';

  @override
  String get uiUnread => 'ಓದಿಲ್ಲ';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'ಪ್ರವೇಶವು ತಕ್ಷಣವೇ ನಿಲ್ಲುತ್ತದೆ. ನೀವು 30 ದಿನಗಳಲ್ಲಿ ಸೈನ್ ಇನ್ ಮಾಡಬಹುದು ಮತ್ತು ಮರುಸ್ಥಾಪಿಸಬಹುದು. ಅದರ ನಂತರ, ನಿಮ್ಮ ಖಾತೆ ಮತ್ತು ಸಂಗ್ರಹಿಸಿದ ಫೈಲ್‌ಗಳನ್ನು ಸಕ್ರಿಯ ಸಂಗ್ರಹಣೆಯಿಂದ ಅಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get uiCloseMyAccount => 'ನನ್ನ ಖಾತೆಯನ್ನು ಮುಚ್ಚಿ';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'ನಿಮ್ಮ ದಾಖಲೆಗಳು ಡಾಕ್ಲೈಜರ್‌ನಲ್ಲಿ ಉಳಿಯುತ್ತವೆ.';

  @override
  String get uiTakeACopyOfYourRecords => 'ನಿಮ್ಮ ದಾಖಲೆಗಳ ನಕಲನ್ನು ತೆಗೆದುಕೊಳ್ಳಿ.';

  @override
  String get uiWhoseRecords => 'ಯಾರ ದಾಖಲೆಗಳು?';

  @override
  String get uiCouldNotLoadProfiles =>
      'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get uiLoadingProfiles => 'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...';

  @override
  String get uiAllProfiles => 'ಎಲ್ಲಾ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get uiDateRange => 'ದಿನಾಂಕ ವ್ಯಾಪ್ತಿ';

  @override
  String get uiUseAllDates => 'ಎಲ್ಲಾ ದಿನಾಂಕಗಳನ್ನು ಬಳಸಿ';

  @override
  String get uiINCLUDEINTHISEXPORT => 'ಈ ರಫ್ತಿನಲ್ಲಿ ಸೇರಿಸಿ';

  @override
  String get uiOriginalReports => 'ಮೂಲ ವರದಿಗಳು';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'ನೀವು ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ PDF ಗಳು ಮತ್ತು ಚಿತ್ರಗಳು';

  @override
  String get uiTestResults => 'ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶಗಳು';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'CSV ನಂತೆ ಫಲಿತಾಂಶಗಳು, ಅವುಗಳ ವಿಮರ್ಶೆ ಸ್ಥಿತಿಯೊಂದಿಗೆ';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'ರಫ್ತುಗಳು ವೈಯಕ್ತಿಕ ಮಾಹಿತಿಯನ್ನು ಒಳಗೊಂಡಿರುತ್ತವೆ. ನೀವು ನಂಬುವ ಸ್ಥಳದಲ್ಲಿ ಅವುಗಳನ್ನು ಸಂಗ್ರಹಿಸಿ.';

  @override
  String get uiDeleteAccount => 'ಖಾತೆಯನ್ನು ಅಳಿಸಿ';

  @override
  String get uiContinueToDeletion => 'ಅಳಿಸುವಿಕೆಯನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String get uiKeepMyAccount => 'ನನ್ನ ಖಾತೆಯನ್ನು ಇರಿಸಿಕೊಳ್ಳಿ';

  @override
  String get uiBeforeYouLeave => 'ನೀವು ಹೊರಡುವ ಮೊದಲು';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'ಇದು ಏನು ತೆಗೆದುಹಾಕುತ್ತದೆ ಎಂಬುದನ್ನು ದಯವಿಟ್ಟು ಓದಿ.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'ನಿಮ್ಮ ಖಾತೆಯನ್ನು ಅಳಿಸುವುದರಿಂದ ನೀವು ನಿರ್ವಹಿಸುವ ಎಲ್ಲಾ ಪ್ರೊಫೈಲ್‌ಗಳ ಮೇಲೆ ಪರಿಣಾಮ ಬೀರುತ್ತದೆ.';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'ನಿಮ್ಮ ಖಾತೆ ಮತ್ತು ವೈಯಕ್ತಿಕ ಪ್ರೊಫೈಲ್';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'ನಿಮ್ಮ ಹಂಚಿಕೊಂಡ ಲಿಂಕ್‌ಗಳ ಮೂಲಕ ಪ್ರವೇಶಿಸಿ';

  @override
  String get uiKeepACopyFirst => 'ಮೊದಲು ಒಂದು ಪ್ರತಿಯನ್ನು ಇಟ್ಟುಕೊಳ್ಳಿ';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'ನೀವು ಉಳಿಸಿಕೊಳ್ಳಲು ಬಯಸುವ ಮಾಹಿತಿಯನ್ನು ರಫ್ತು ಮಾಡಿ.';

  @override
  String get uiExportData => 'ಡೇಟಾವನ್ನು ರಫ್ತು ಮಾಡಿ';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'ಪ್ರವೇಶವು ತಕ್ಷಣವೇ ನಿಲ್ಲುತ್ತದೆ. ನೀವು 30 ದಿನಗಳಲ್ಲಿ ಮರುಸ್ಥಾಪಿಸಬಹುದು. ಅದರ ನಂತರ, ನಿಮ್ಮ ಡೇಟಾವನ್ನು ಸಕ್ರಿಯ ಸಂಗ್ರಹಣೆಯಿಂದ ತೆಗೆದುಹಾಕಲಾಗುತ್ತದೆ.';

  @override
  String get uiAccountPendingDeletion => 'ಖಾತೆಯ ಅಳಿಸುವಿಕೆ ಬಾಕಿಯಿದೆ';

  @override
  String get uiRestoreMyAccount => 'ನನ್ನ ಖಾತೆಯನ್ನು ಮರುಸ್ಥಾಪಿಸಿ';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್, ಪ್ರೊಫೈಲ್‌ಗಳು ಮತ್ತು ಸಮ್ಮತಿ ದಾಖಲೆಗಳನ್ನು ಒಳಗೊಂಡಂತೆ ನಿಮ್ಮ ಖಾತೆಯ ಡೇಟಾದ ನಕಲನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ.';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'ನಿಮ್ಮ ಖಾತೆಯನ್ನು ತಕ್ಷಣವೇ ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ. ನೀವು ಅದನ್ನು 30 ದಿನಗಳಲ್ಲಿ ಮರುಸ್ಥಾಪಿಸಬಹುದು. ಅದರ ನಂತರ, ನಿಮ್ಮ ಡೇಟಾವನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get uiCurrentPassword => 'ಪ್ರಸ್ತುತ ಪಾಸ್ವರ್ಡ್';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್ ಅನ್ನು ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'ನಿಮ್ಮ ದಾಖಲೆಗಳು.\nಹಂಚಿಕೊಳ್ಳಲು ನಿಮ್ಮ ಆಯ್ಕೆ.';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'ನಿಮಗೆ ಅಗತ್ಯವಿರುವಾಗ ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiAppLock => 'ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'ನಿಮ್ಮ ಸಾಧನದ ಬಯೋಮೆಟ್ರಿಕ್ ಅಥವಾ ಪಾಸ್ಕೋಡ್ ಲಾಕ್ ಅನ್ನು ಬಳಸಿ.';

  @override
  String get uiNotificationPreviews => 'ಅಧಿಸೂಚನೆ ಪೂರ್ವವೀಕ್ಷಣೆಗಳು';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'ನಿಮ್ಮ ಸಾಧನದ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಲಾಕ್-ಸ್ಕ್ರೀನ್ ಪೂರ್ವವೀಕ್ಷಣೆಗಳನ್ನು ನಿಯಂತ್ರಿಸಿ.';

  @override
  String get uiContactSupport => 'ಬೆಂಬಲವನ್ನು ಸಂಪರ್ಕಿಸಿ';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'ನೀವು ಆಯ್ಕೆ ಮಾಡಿದರೆ ಮಾತ್ರ ವರದಿಗಳನ್ನು ಲಗತ್ತಿಸಿ.';

  @override
  String get uiWhatCanWeHelpYouWith => 'ನಾವು ನಿಮಗೆ ಏನು ಸಹಾಯ ಮಾಡಬಹುದು?';

  @override
  String get uiPOPULARQUESTIONS => 'ಜನಪ್ರಿಯ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'ನಿಮ್ಮ ಹುಡುಕಾಟಕ್ಕೆ ಯಾವುದೇ ಸಹಾಯ ಲೇಖನಗಳು ಹೊಂದಿಕೆಯಾಗುವುದಿಲ್ಲ.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'ನಿಮ್ಮ ಆರೋಗ್ಯ ಅಥವಾ ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶಗಳ ಕುರಿತು ಪ್ರಶ್ನೆಗಳಿಗಾಗಿ, ಅರ್ಹ ಆರೋಗ್ಯ ವೃತ್ತಿಪರರೊಂದಿಗೆ ಮಾತನಾಡಿ.';

  @override
  String get uiYourReportsAClearerPicture => 'ನಿಮ್ಮ ವರದಿಗಳು. ಸ್ಪಷ್ಟ ಚಿತ್ರಣ.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'ನಿಮ್ಮ ಆರೋಗ್ಯ ಇತಿಹಾಸವನ್ನು ಒಟ್ಟಿಗೆ ಇರಿಸಿ.';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'ವರದಿಗಳನ್ನು ಸಂಗ್ರಹಿಸಿ, ಫಲಿತಾಂಶಗಳನ್ನು ಪರಿಶೀಲಿಸಿ, ಬದಲಾವಣೆಗಳನ್ನು ಅನುಸರಿಸಿ ಮತ್ತು ನಿಮ್ಮ ವೈದ್ಯರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get uiEducationalInformationOnly => 'ಶೈಕ್ಷಣಿಕ ಮಾಹಿತಿ ಮಾತ್ರ';

  @override
  String get uiSearchHelpArticles => 'ಸಹಾಯ ಲೇಖನಗಳನ್ನು ಹುಡುಕಿ';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'ಅಧಿಸೂಚನೆ ಪ್ರವೇಶವನ್ನು ಬದಲಾಯಿಸಲು ಸಾಧನ ಸೆಟ್ಟಿಂಗ್‌ಗಳ ಅಪ್ಲಿಕೇಶನ್ ತೆರೆಯಿರಿ.';

  @override
  String get uiSavePreferences => 'ಆದ್ಯತೆಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'ಸಾಧನದ ಅನುಮತಿಗಳನ್ನು ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಬದಲಾಯಿಸಬಹುದು.';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'ಈ ಸಾಧನದಲ್ಲಿ ವರದಿ ನವೀಕರಣಗಳನ್ನು ಪಡೆಯಿರಿ';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'ವರದಿಯು ಯಾವಾಗ ಸಿದ್ಧವಾಗಿದೆ ಎಂಬುದನ್ನು ತಿಳಿಯಲು ಅಧಿಸೂಚನೆಗಳನ್ನು ಅನುಮತಿಸಿ. ಮಾರ್ಕೆಟಿಂಗ್ ಕೆಳಗೆ ಪ್ರತ್ಯೇಕ ಆಯ್ಕೆಯಾಗಿದೆ.';

  @override
  String get uiREPORTACTIVITY => 'ಚಟುವಟಿಕೆಯನ್ನು ವರದಿ ಮಾಡಿ';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'ವರದಿ ಚಟುವಟಿಕೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳಿಗೆ ಇತ್ತೀಚಿನ ಸರ್ವರ್ ಆವೃತ್ತಿಯ ಅಗತ್ಯವಿದೆ.';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'ಸೂಕ್ಷ್ಮ ಲಾಕ್-ಸ್ಕ್ರೀನ್ ಪೂರ್ವವೀಕ್ಷಣೆಗಳು';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'ವರದಿಯ ಹೆಸರುಗಳು ಮತ್ತು ವೈಯಕ್ತಿಕ ವಿವರಗಳನ್ನು ಯಾವಾಗಲೂ ಮರೆಮಾಡಲಾಗಿದೆ.';

  @override
  String get uiOTHERMESSAGES => 'ಇತರ ಸಂದೇಶಗಳು';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'ಪ್ರತಿಯೊಬ್ಬ ವ್ಯಕ್ತಿಯ ವರದಿಗಳು ಮತ್ತು ಪ್ರವೃತ್ತಿಗಳನ್ನು ಒಟ್ಟಿಗೆ ಇರಿಸಿ.';

  @override
  String get uiPersonDetails => 'ವ್ಯಕ್ತಿ ವಿವರಗಳು';

  @override
  String get uiDateOfBirth => 'ಹುಟ್ಟಿದ ದಿನಾಂಕ';

  @override
  String get uiRelationship => 'ಸಂಬಂಧ';

  @override
  String get uiEnterAName => 'ಹೆಸರನ್ನು ನಮೂದಿಸಿ';

  @override
  String get uiClearDateOfBirth => 'ಹುಟ್ಟಿದ ದಿನಾಂಕವನ್ನು ತೆರವುಗೊಳಿಸಿ';

  @override
  String get uiOptionalEGParentOrChild => 'ಐಚ್ಛಿಕ, ಉದಾ. ಪೋಷಕರು ಅಥವಾ ಮಗು';

  @override
  String get uiInviteFriendsEarnCredits =>
      'ಸ್ನೇಹಿತರನ್ನು ಆಹ್ವಾನಿಸಿ, ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಗಳಿಸಿ';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'ನಿಮ್ಮ ಕೋಡ್ ಅನ್ನು ಹಂಚಿಕೊಳ್ಳಿ ಮತ್ತು ರಿವಾರ್ಡ್ ಅನ್‌ಲಾಕ್ ಆಗಿ ಪ್ರತಿ ಆಹ್ವಾನವನ್ನು ಅನುಸರಿಸಿ.';

  @override
  String get uiYOURREFERRALCODE => 'ನಿಮ್ಮ ರೆಫರಲ್ ಕೋಡ್';

  @override
  String get uiShareInvite => 'ಆಹ್ವಾನವನ್ನು ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get uiCopyCode => 'ಕೋಡ್ ನಕಲಿಸಿ';

  @override
  String get uiHaveACode => 'ಕೋಡ್ ಹೊಂದಿರುವಿರಾ?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'ನಿಮ್ಮ ಆಹ್ವಾನದ ಬಹುಮಾನವನ್ನು ಪಡೆಯಲು ನಿಮ್ಮೊಂದಿಗೆ ಹಂಚಿಕೊಂಡಿರುವ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get uiHowRewardsWork => 'ಪ್ರತಿಫಲಗಳು ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತವೆ';

  @override
  String get uiNoFriendsReferredYet =>
      'ಇನ್ನೂ ಯಾವುದೇ ಸ್ನೇಹಿತರನ್ನು ಉಲ್ಲೇಖಿಸಲಾಗಿಲ್ಲ';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'ಅವರ ಪ್ರಗತಿಯನ್ನು ನೋಡಲು ನಿಮ್ಮ ಆಹ್ವಾನವನ್ನು ಇಲ್ಲಿ ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get uiReferralCode => 'ರೆಫರಲ್ ಕೋಡ್';

  @override
  String get uiSetNewPassword => 'ಹೊಸ ಪಾಸ್ವರ್ಡ್ ಹೊಂದಿಸಿ';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'ನಿಮ್ಮ ಇಮೇಲ್ ಮತ್ತು ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ನಲ್ಲಿರುವ ಲಿಂಕ್‌ನಿಂದ ಮರುಹೊಂದಿಸುವ ಟೋಕನ್ ಅನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get uiResetPassword => 'ಪಾಸ್ವರ್ಡ್ ಮರುಹೊಂದಿಸಿ';

  @override
  String get uiBackToLogin => 'ಲಾಗಿನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get uiResetToken => 'ಟೋಕನ್ ಅನ್ನು ಮರುಹೊಂದಿಸಿ';

  @override
  String get uiNewPassword => 'ಹೊಸ ಪಾಸ್ವರ್ಡ್';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'ನಿಮ್ಮ ಖಾತೆಯೊಂದಿಗೆ ಸಂಯೋಜಿತವಾಗಿರುವ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ ಮತ್ತು ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಅನ್ನು ಮರುಹೊಂದಿಸಲು ನಾವು ನಿಮಗೆ ಲಿಂಕ್ ಅನ್ನು ಕಳುಹಿಸುತ್ತೇವೆ.';

  @override
  String get uiSendResetLink => 'ಮರುಹೊಂದಿಸುವ ಲಿಂಕ್ ಕಳುಹಿಸಿ';

  @override
  String get uiRevokeSession => 'ಅಧಿವೇಶನವನ್ನು ಹಿಂತೆಗೆದುಕೊಳ್ಳುವುದೇ?';

  @override
  String get uiCurrentSession => 'ಪ್ರಸ್ತುತ ಅಧಿವೇಶನ';

  @override
  String get uiSkip => 'ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String get uiChangePassword => 'ಪಾಸ್ವರ್ಡ್ ಬದಲಾಯಿಸಿ';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಪಾಸ್‌ವರ್ಡ್ ಅನ್ನು ನಮೂದಿಸಿ ಮತ್ತು ಹೊಸದನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get uiNewPasswordd850ee => 'ಹೊಸ ಪಾಸ್ವರ್ಡ್';

  @override
  String get uiConfirmNewPassword => 'ಹೊಸ ಪಾಸ್ವರ್ಡ್ ಅನ್ನು ದೃಢೀಕರಿಸಿ';

  @override
  String get uiGettingThingsReady => 'ವಿಷಯಗಳನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get uiLinkAccessHistory => 'ಲಿಂಕ್ ಪ್ರವೇಶ ಇತಿಹಾಸ';

  @override
  String get uiNoAccessEventsYet => 'ಇನ್ನೂ ಯಾವುದೇ ಪ್ರವೇಶ ಈವೆಂಟ್‌ಗಳಿಲ್ಲ.';

  @override
  String get uiDefaultShareLinkExpiry => 'ಡೀಫಾಲ್ಟ್ ಹಂಚಿಕೆ ಲಿಂಕ್ ಮುಕ್ತಾಯ';

  @override
  String get uiSave => 'ಉಳಿಸಿ';

  @override
  String get uiReviewSharing => 'ವಿಮರ್ಶೆ ಹಂಚಿಕೆ';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'ವ್ಯಕ್ತಿ, ವರದಿಗಳು ಮತ್ತು ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'ಆಯ್ಕೆ ಅಥವಾ ಪ್ರವೇಶ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಸಂಪಾದಿಸಿ';

  @override
  String get uiRevokeShareLink => 'ಹಂಚಿಕೆ ಲಿಂಕ್ ಹಿಂತೆಗೆದುಕೊಳ್ಳುವುದೇ?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'ಈ ಲಿಂಕ್ ಕೆಲಸ ಮಾಡುವುದನ್ನು ನಿಲ್ಲಿಸುತ್ತದೆ. ನೀವು ಹೊಸದನ್ನು ರಚಿಸಬಹುದು.';

  @override
  String get uiShareLinkReady => 'ಹಂಚಿಕೆ ಲಿಂಕ್ ಸಿದ್ಧವಾಗಿದೆ';

  @override
  String get uiAccessCodeShareSeparately =>
      'ಪ್ರವೇಶ ಕೋಡ್ - ಪ್ರತ್ಯೇಕವಾಗಿ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get uiCopyAccessCode => 'ಪ್ರವೇಶ ಕೋಡ್ ಅನ್ನು ನಕಲಿಸಿ';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'ಈ ಸಾಧನದಲ್ಲಿ ಈ ಕೋಡ್ ಅನ್ನು ಉಳಿಸಲಾಗಲಿಲ್ಲ. ನಂತರದ ಬಳಕೆಗಾಗಿ ಈಗ ಅದನ್ನು ನಕಲಿಸಿ.';

  @override
  String get uiShareLink => 'ಲಿಂಕ್ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get uiCopyLink => 'ಲಿಂಕ್ ನಕಲಿಸಿ';

  @override
  String get uiRevokeLink => 'ಲಿಂಕ್ ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'ಈ ಸಾಧನದಲ್ಲಿ ಕೋಡ್ ಲಭ್ಯವಿಲ್ಲ. ಉಳಿಸಿದ ಕೋಡ್ ಬಳಸಿ ಅಥವಾ ಹೊಸ ಲಿಂಕ್ ರಚಿಸಿ.';

  @override
  String get uiActiveSharedLinks => 'ಸಕ್ರಿಯ ಹಂಚಿದ ಲಿಂಕ್‌ಗಳು';

  @override
  String get uiShare => 'ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get uiCreateANewShareLink => 'ಹೊಸ ಹಂಚಿಕೆ ಲಿಂಕ್ ಅನ್ನು ರಚಿಸಿ';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'ಈ ಪ್ರೊಫೈಲ್‌ಗಾಗಿ ಪ್ರಸ್ತುತ ಮತ್ತು ಭವಿಷ್ಯದ ವರದಿಗಳನ್ನು ಸೇರಿಸಿ.';

  @override
  String get uiChooseReports => 'ವರದಿಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'ಕೆಳಗೆ ಆಯ್ಕೆಮಾಡಿದ ವರದಿಗಳನ್ನು ಮಾತ್ರ ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get uiSelectAll => 'ಎಲ್ಲವನ್ನೂ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'ಹಂಚಿಕೊಳ್ಳಲು ಯಾವುದೇ ಪರಿಶೀಲಿಸಿದ ವರದಿಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get uiSelectedTestResults => 'ಆಯ್ದ ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶಗಳು';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'ಈ ವರದಿಗಳಿಂದ ನೀವು ಆಯ್ಕೆ ಮಾಡಿದ ಫಲಿತಾಂಶಗಳನ್ನು ಮಾತ್ರ ಸೇರಿಸಿ.';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'ಈ ವರದಿಗಳಲ್ಲಿ ಯಾವುದೇ ಉಳಿಸಿದ ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶಗಳು ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get uiUpgradeOrManage => 'ನವೀಕರಿಸಿ ಅಥವಾ ನಿರ್ವಹಿಸಿ';

  @override
  String get uiExpiry => 'ಮುಕ್ತಾಯ:';

  @override
  String get uiRequireAnAccessCode => 'ಪ್ರವೇಶ ಕೋಡ್ ಅಗತ್ಯವಿದೆ';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'ಲಿಂಕ್‌ನಿಂದ ಪ್ರತ್ಯೇಕವಾಗಿ ಕೋಡ್ ಅನ್ನು ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get uiTryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get uiClearExpiry => 'ಮುಕ್ತಾಯವನ್ನು ತೆರವುಗೊಳಿಸಿ';

  @override
  String get onboardingStoreEyebrow => '01 / ಸಂಗ್ರಹಿಸಿ';

  @override
  String get onboardingStoreTitle => 'ಪ್ರತಿ ವರದಿ,\nಒಂದು ಪರಿಚಿತ ಸ್ಥಳ.';

  @override
  String get onboardingStoreBody =>
      'ನಿಮಗಾಗಿ ಮತ್ತು ನೀವು ಕಾಳಜಿವಹಿಸುವ ಜನರಿಗೆ PDF ಗಳು ಮತ್ತು ಫೋಟೋಗಳನ್ನು ಒಟ್ಟಿಗೆ ಇರಿಸಿ.';

  @override
  String get onboardingUnderstandEyebrow => '02 / ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ';

  @override
  String get onboardingUnderstandTitle => 'ಸಂಖ್ಯೆಗಳು,\nಓದಲು ಸುಲಭವಾಗಿದೆ.';

  @override
  String get onboardingUnderstandBody =>
      'ನಿಮ್ಮ ವರದಿಯಿಂದ ಪ್ರತಿ ಪರೀಕ್ಷೆ, ಅದರ ಘಟಕ ಮತ್ತು ಮಧ್ಯಂತರವನ್ನು ನೋಡಿ. ಯಾವುದೇ ಸಮಯದಲ್ಲಿ ಮೂಲವನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get onboardingTrackEyebrow => '03 / ಟ್ರ್ಯಾಕ್ ಮಾಡಿ ಮತ್ತು ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get onboardingTrackTitle =>
      'ಬದಲಾವಣೆಗಳನ್ನು ನೋಡಿ.\nಸಂದರ್ಭವನ್ನು ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get onboardingTrackBody =>
      'ಕಾಲಾನಂತರದಲ್ಲಿ ಫಲಿತಾಂಶಗಳನ್ನು ಅನುಸರಿಸಿ ಮತ್ತು ನಿಮ್ಮ ವೈದ್ಯರು ಏನನ್ನು ನೋಡಬಹುದು ಎಂಬುದನ್ನು ನಿಖರವಾಗಿ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get onboardingNext => 'ಮುಂದೆ';

  @override
  String get onboardingGetStarted => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get uiSupportRequestSent => 'ಬೆಂಬಲ ವಿನಂತಿಯನ್ನು ಕಳುಹಿಸಲಾಗಿದೆ.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'ಪರೀಕ್ಷೆಯ ಹೆಸರು ಮತ್ತು ಫಲಿತಾಂಶದ ಅಗತ್ಯವಿದೆ.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD ಸ್ವರೂಪದಲ್ಲಿ ಮಾನ್ಯವಾದ ಸಂಗ್ರಹಣೆ ದಿನಾಂಕವನ್ನು ಬಳಸಿ.';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'ಈ ತಿದ್ದುಪಡಿಯನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiReportsUnavailable => 'ವರದಿಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uiTryAgain042c86 => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get uiTwoReportsAreNeeded => 'ಎರಡು ವರದಿಗಳ ಅಗತ್ಯವಿದೆ';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'ಫಲಿತಾಂಶಗಳನ್ನು ಹೋಲಿಸಲು ಈ ಪ್ರೊಫೈಲ್‌ಗೆ ಹಳೆಯ ವರದಿಯನ್ನು ಸೇರಿಸಿ.';

  @override
  String get uiCannotCompareYet => 'ಇನ್ನೂ ಹೋಲಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'ಈ ವರದಿಗಳು ಹೋಲಿಕೆಗಾಗಿ ಯಾವುದೇ ಹೊಂದಾಣಿಕೆಯ ಫಲಿತಾಂಶಗಳನ್ನು ಹೊಂದಿಲ್ಲ.';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'ವರದಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCouldNotOpenPhotosOrCamera =>
      'ಫೋಟೋಗಳು ಅಥವಾ ಕ್ಯಾಮರಾವನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';

  @override
  String get uiCouldNotOpenCamera => 'ಕ್ಯಾಮರಾ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'ಈ ಪುಟಗಳನ್ನು ಸಿದ್ಧಪಡಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಓದಲಾಗದ ಪುಟವನ್ನು ರೀಟೇಕ್ ಮಾಡಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCouldNotAdjustThisPage =>
      'ಈ ಪುಟವನ್ನು ಸರಿಹೊಂದಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';

  @override
  String get uiNoChartableResultYet => 'ಇನ್ನೂ ಯಾವುದೇ ಚಾರ್ಟಬಲ್ ಫಲಿತಾಂಶವಿಲ್ಲ';

  @override
  String get uiProfiles => 'ಪ್ರೊಫೈಲ್ಗಳು';

  @override
  String get uiReports => 'ವರದಿಗಳು';

  @override
  String get uiShareLinks => 'ಲಿಂಕ್‌ಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get uiAIChat => 'AI ಚಾಟ್';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'ಅರ್ಹತೆಯ ಸಾರಾಂಶವನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'ಬಿಲ್ಲಿಂಗ್ ಸ್ಥಿತಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'ರಶೀದಿ ಡೌನ್‌ಲೋಡ್ ಶೀಘ್ರದಲ್ಲೇ ಲಭ್ಯವಿರುತ್ತದೆ.';

  @override
  String get uiSubtotal => 'ಉಪಮೊತ್ತ';

  @override
  String get uiDiscount => 'ರಿಯಾಯಿತಿ';

  @override
  String get uiTotal => 'ಒಟ್ಟು';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'ಕ್ರೆಡಿಟ್ ಪ್ಯಾಕ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'ಪಾವತಿಯು ಬಾಕಿ ಉಳಿದಿದೆ ಕ್ಯಾಪ್ಚರ್. ಮತ್ತೊಂದು ಚೆಕ್‌ಔಟ್ ಪ್ರಾರಂಭಿಸುವ ಮೊದಲು ಸ್ಥಿತಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಅನ್ವಯಿಸಲಾಗಿದೆ.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ಆದೇಶವನ್ನು ರಚಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'ಪಾವತಿಯನ್ನು ಸ್ವೀಕರಿಸಲಾಗಿದೆ. ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಸೇರಿಸುವ ಮೊದಲು ಸರ್ವರ್ ಸಮನ್ವಯಕ್ಕಾಗಿ ನಿರೀಕ್ಷಿಸಲಾಗುತ್ತಿದೆ.';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'ಪಾವತಿ ವಿಫಲವಾಗಿದೆ. ಸಿದ್ಧವಾದಾಗ ನೀವು ಚೆಕ್ಔಟ್ ಅನ್ನು ಮರುಪ್ರಯತ್ನಿಸಬಹುದು.';

  @override
  String get uiPaymentFailedTryAgain => 'ಪಾವತಿ ವಿಫಲವಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCreditsAdded => 'ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ!';

  @override
  String get uiPromoCodeApplied => 'ಪ್ರೋಮೋ ಕೋಡ್ ಅನ್ವಯಿಸಲಾಗಿದೆ.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'ಪಾವತಿಯನ್ನು ಸ್ವೀಕರಿಸಲಾಗಿದೆ, ಆದರೆ ಈ ಆದೇಶವು ಪರಿಶೀಲನೆಗೆ ಬಾಕಿ ಇದೆ.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'ಸಮನ್ವಯದ ಸಮಯದಲ್ಲಿ ಪಾವತಿ ವಿಫಲವಾಗಿದೆ.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'ಪಾವತಿಯನ್ನು ದೃಢೀಕರಿಸಲಾಗಿದೆ. ಸರ್ವರ್ ಹೊಂದಾಣಿಕೆ ಇನ್ನೂ ಬಾಕಿ ಇದೆ.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'ಪಾವತಿಯನ್ನು ಪರಿಶೀಲಿಸಲಾಗಿದೆ. ಸಮನ್ವಯವು ಬಾಕಿ ಉಳಿದಿದೆ, ದಯವಿಟ್ಟು ಶೀಘ್ರದಲ್ಲೇ ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'ಪಾವತಿಯನ್ನು ಸ್ವೀಕರಿಸಲಾಗಿದೆ ಆದರೆ ಪರಿಶೀಲನೆ ಇನ್ನೂ ಬಾಕಿಯಿದೆ. ದಯವಿಟ್ಟು ಸ್ಥಿತಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'ಯೋಜನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'ಚಂದಾದಾರಿಕೆಯನ್ನು ರಚಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'ಚಂದಾದಾರಿಕೆ ವಿಫಲವಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiPlanUpgraded => 'ಯೋಜನೆಯನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'ಪಾವತಿಯನ್ನು ಸ್ವೀಕರಿಸಲಾಗಿದೆ ಆದರೆ ಪರಿಶೀಲನೆ ವಿಫಲವಾಗಿದೆ. ಯೋಜನೆಯನ್ನು ಶೀಘ್ರದಲ್ಲೇ ನವೀಕರಿಸಲಾಗುವುದು.';

  @override
  String get uiNotificationsUnavailable => 'ಅಧಿಸೂಚನೆಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uiAllQuietForNow => 'ಸದ್ಯಕ್ಕೆ ಎಲ್ಲಾ ಸ್ತಬ್ಧ.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'ಹೊಸದೇನಾದರೂ ಇದ್ದಾಗ ವರದಿ ಅಪ್‌ಡೇಟ್‌ಗಳು ಮತ್ತು ಹಂಚಿಕೆ ಜ್ಞಾಪನೆಗಳು ಇಲ್ಲಿ ಗೋಚರಿಸುತ್ತವೆ.';

  @override
  String get uiNoUnreadUpdates => 'ಓದದಿರುವ ನವೀಕರಣಗಳಿಲ್ಲ';

  @override
  String get uiYouReAllCaughtUp => 'ನೀವೆಲ್ಲರೂ ಸಿಕ್ಕಿಬಿದ್ದಿದ್ದೀರಿ.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'ಅಧಿಸೂಚನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ಸಂಪರ್ಕಗೊಂಡಾಗ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiManageSharedLinks => 'ಹಂಚಿದ ಲಿಂಕ್‌ಗಳನ್ನು ನಿರ್ವಹಿಸಿ';

  @override
  String get uiExportYourData => 'ನಿಮ್ಮ ಡೇಟಾವನ್ನು ರಫ್ತು ಮಾಡಿ';

  @override
  String get uiReadThePrivacyPolicy => 'ಗೌಪ್ಯತೆ ನೀತಿಯನ್ನು ಓದಿ';

  @override
  String get uiTermsOfUse => 'ಬಳಕೆಯ ನಿಯಮಗಳು';

  @override
  String get uiPrivacyPolicy => 'ಗೌಪ್ಯತೆ ನೀತಿ';

  @override
  String get uiDateOfBirthOptional => 'ಹುಟ್ಟಿದ ದಿನಾಂಕ, ಐಚ್ಛಿಕ';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'ಸಂಬಂಧವು 50 ಅಕ್ಷರಗಳು ಅಥವಾ ಅದಕ್ಕಿಂತ ಕಡಿಮೆ ಇರಬೇಕು.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'ಪ್ರೊಫೈಲ್ ಉಳಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiReferralsUnavailable => 'ರೆಫರಲ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uiYourRewards => 'ನಿಮ್ಮ ಪ್ರತಿಫಲಗಳು';

  @override
  String get uiReferralProgress => 'ಉಲ್ಲೇಖದ ಪ್ರಗತಿ';

  @override
  String get uiFriendsReferred => 'ಸ್ನೇಹಿತರು ಉಲ್ಲೇಖಿಸಿದ್ದಾರೆ';

  @override
  String get uiCreditsEarned => 'ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಗಳಿಸಿದೆ';

  @override
  String get uiPendingRewards => 'ಬಾಕಿ ಉಳಿದಿರುವ ಬಹುಮಾನಗಳು';

  @override
  String get uiBlockedRewards => 'ಬಹುಮಾನಗಳನ್ನು ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ';

  @override
  String get uiInviteeBonus => 'ಆಹ್ವಾನಿತರ ಬೋನಸ್';

  @override
  String get uiFirstAnalysis => 'ಮೊದಲ ವಿಶ್ಲೇಷಣೆ';

  @override
  String get uiFirstPurchase => 'ಮೊದಲ ಖರೀದಿ';

  @override
  String get uiMonthlyCap => 'ಮಾಸಿಕ ಕ್ಯಾಪ್';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'ರೆಫರಲ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiReferralCodeCopied => 'ರೆಫರಲ್ ಕೋಡ್ ಅನ್ನು ನಕಲಿಸಲಾಗಿದೆ.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'ನಿಮ್ಮ ಇಮೇಲ್ ಲಿಂಕ್‌ನಿಂದ ಮರುಹೊಂದಿಸುವ ಟೋಕನ್ ಅನ್ನು ನಮೂದಿಸಿ';

  @override
  String get uiEnterYourNewPassword => 'ನಿಮ್ಮ ಹೊಸ ಗುಪ್ತಪದವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'ಪಾಸ್ವರ್ಡ್ ಅನ್ನು ಮರುಹೊಂದಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು ಹೊಸ ಲಿಂಕ್ ಅನ್ನು ವಿನಂತಿಸಿ.';

  @override
  String get uiEnterYourEmailAddress => 'ನಿಮ್ಮ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'ಮರುಹೊಂದಿಸುವ ಲಿಂಕ್ ಅನ್ನು ಕಳುಹಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiFailedToLoadSessions => 'ಸೆಷನ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ.';

  @override
  String get uiFailedToRevokeSession =>
      'ಅಧಿವೇಶನವನ್ನು ಹಿಂತೆಗೆದುಕೊಳ್ಳಲು ವಿಫಲವಾಗಿದೆ.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'ಪಾಸ್ವರ್ಡ್ ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'ಸಾಧನ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ ಮತ್ತು ಡಾಕ್ಲೈಜರ್‌ಗಾಗಿ ಅಧಿಸೂಚನೆಗಳನ್ನು ಅನುಮತಿಸಿ.';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'ವರದಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'ಹಂಚಿಕೊಳ್ಳಲು ಕನಿಷ್ಠ ಒಂದು ವರದಿಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'ಹಂಚಿಕೊಳ್ಳಲು ಕನಿಷ್ಠ ಒಂದು ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶವನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get uiLinkCopiedToClipboard =>
      'ಲಿಂಕ್ ಅನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'ಪ್ರವೇಶ ಕೋಡ್ ಅನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ';

  @override
  String get uiOnePerson => '1 ವ್ಯಕ್ತಿ';

  @override
  String uiPeopleCount(String count) {
    return '$count ಜನರು';
  }

  @override
  String uiActionsFor(String name) {
    return '$name ಗಾಗಿ ಕ್ರಿಯೆಗಳು';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name ಗೆ ಬದಲಾಯಿಸಲಾಗಿದೆ';
  }

  @override
  String get uiAnalyzeOnePage => '1 ಪುಟವನ್ನು ವಿಶ್ಲೇಷಿಸಿ';

  @override
  String uiAnalyzePages(String count) {
    return '$count ಪುಟಗಳನ್ನು ವಿಶ್ಲೇಷಿಸಿ';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'ನಿಮ್ಮ ವರದಿಯಲ್ಲಿ ತೋರಿಸಿರುವ ಕ್ರಮದಲ್ಲಿ ಪುಟಗಳನ್ನು ಎಳೆಯಿರಿ';

  @override
  String get uiCheckEveryPage => 'ವಿಶ್ಲೇಷಿಸುವ ಮೊದಲು ಪ್ರತಿ ಪುಟವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get uiOnePageAdded => '1 ಪುಟವನ್ನು ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String uiPagesAdded(String count) {
    return '$count ಪುಟಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String get uiReorder => 'ಮರುಕ್ರಮಗೊಳಿಸಿ';

  @override
  String uiPageNumber(String number) {
    return 'ಪುಟ $number';
  }

  @override
  String uiRemovePage(String number) {
    return 'ಪುಟವನ್ನು ತೆಗೆದುಹಾಕಿ $number';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · ಪುಟ $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'ಕ್ರಾಪ್ ಅಂಚುಗಳು: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count ಆಯ್ಕೆಮಾಡಿದ ವರದಿಗಳು';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶಗಳನ್ನು ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String get uiAllCurrentFutureReports =>
      'ಎಲ್ಲಾ ಪ್ರಸ್ತುತ ಮತ್ತು ಭವಿಷ್ಯದ ವರದಿಗಳು';

  @override
  String get uiNoExpiry => 'ಅವಧಿ ಮುಗಿಯುವುದಿಲ್ಲ';

  @override
  String uiExpiresDate(String date) {
    return '$date ಅವಧಿ ಮುಗಿಯುತ್ತದೆ';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'ಪ್ರವೇಶ ಕೋಡ್ ಅಗತ್ಯವಿದೆ. ಲಿಂಕ್‌ನಿಂದ ಪ್ರತ್ಯೇಕವಾಗಿ ಹಂಚಿಕೊಳ್ಳಿ.';

  @override
  String get uiNoAccessCodeRequired => 'ಪ್ರವೇಶ ಕೋಡ್ ಅಗತ್ಯವಿಲ್ಲ.';

  @override
  String uiExpiresColonDate(String date) {
    return 'ಅವಧಿ ಮುಗಿಯುತ್ತದೆ: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name ವರದಿಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಿ';
  }

  @override
  String uiProfileReports(String name) {
    return '$name ವರದಿಗಳು';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count ಆಯ್ಕೆಮಾಡಿದ ಫಲಿತಾಂಶಗಳು';
  }

  @override
  String get uiAccessCodeRequiredShort => 'ಪ್ರವೇಶ ಕೋಡ್ ಅಗತ್ಯವಿದೆ';

  @override
  String uiPastLinksCount(String count) {
    return 'ಹಿಂದಿನ ಲಿಂಕ್‌ಗಳು · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return '$date ಅವಧಿ ಮುಗಿದಿದೆ';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'ಹಿಂತೆಗೆದುಕೊಳ್ಳಲಾಗಿದೆ · $date ರಚಿಸಲಾಗಿದೆ';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum ಸಕ್ರಿಯ ಲಿಂಕ್‌ಗಳ $current ಅನ್ನು ಬಳಸುವುದು.';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename ಮತ್ತು ಅದರ ಸಂಗ್ರಹವಾಗಿರುವ ಫೈಲ್ ಅನ್ನು ಅಳಿಸುವುದೇ? ಇದನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'ವರದಿಯನ್ನು ಅಳಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'ಎಲ್ಲಾ $count ವರದಿಗಳು ಮತ್ತು ಅವುಗಳ ಸಂಗ್ರಹಿಸಿದ ಫೈಲ್‌ಗಳನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುವುದೇ? ಇದನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗುವುದಿಲ್ಲ.';
  }

  @override
  String get uiRecycleBinEmptied => 'ಮರುಬಳಕೆ ಬಿನ್ ಖಾಲಿಯಾಗಿದೆ';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted ವರದಿಗಳನ್ನು ಅಳಿಸಲಾಗಿದೆ. $failed ಅಳಿಸಲಾಗಲಿಲ್ಲ; ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'ಮರುಬಳಕೆ ಬಿನ್ ಅನ್ನು ಖಾಲಿ ಮಾಡಲು ಸಾಧ್ಯವಿಲ್ಲ: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'ಪ್ರೊಫೈಲ್: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'ಸಂಗ್ರಹಿಸಲಾಗಿದೆ: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'ಈ ದಿನಾಂಕದಂದು ಅಳಿಸಲಾಗಿದೆ: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'ಇದರಲ್ಲಿ ಶಾಶ್ವತ ಅಳಿಸುವಿಕೆ: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'ಉಳಿದಿರುವ ದಿನಗಳು: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer =>
      'ಡಾಕ್ಲೈಜರ್‌ಗಾಗಿ ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್ ಅನ್ನು ದೃಢೀಕರಿಸಿ';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್ ಅನ್ನು ಆಫ್ ಮಾಡುವ ಮೊದಲು ದೃಢೀಕರಿಸಿ';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'ನಿಮ್ಮ ಆರೋಗ್ಯ ದಾಖಲೆಗಳನ್ನು ವೀಕ್ಷಿಸಲು ಡಾಕ್ಲೈಜರ್ ಅನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಿ';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಡೀಫಾಲ್ಟ್ ಪ್ರೊಫೈಲ್ ಅನ್ನು ರಚಿಸಿ.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'ನಿಮ್ಮ ಟೈಮ್‌ಲೈನ್ ಅನ್ನು ವೀಕ್ಷಿಸುವ ಮೊದಲು ಡೀಫಾಲ್ಟ್ ಪ್ರೊಫೈಲ್ ಅನ್ನು ರಚಿಸಿ.';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'ಇದೀಗ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'ಪ್ರೊಫೈಲ್ ಡೇಟಾವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗದ ಕಾರಣ ಇದೀಗ ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು API ಸರ್ವರ್ ಚಾಲನೆಯಲ್ಲಿದೆ ಎಂದು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'ಪ್ರೊಫೈಲ್ ಡೇಟಾವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗದ ಕಾರಣ ಇದೀಗ ಟೈಮ್‌ಲೈನ್ ತೆರೆಯಲು ಸಾಧ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು API ಸರ್ವರ್ ಚಾಲನೆಯಲ್ಲಿದೆ ಎಂದು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'ಇದೀಗ ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'ಹಂಚಿಕೆ ಲಿಂಕ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiPasswordChanged => 'ಪಾಸ್ವರ್ಡ್ ಬದಲಾಗಿದೆ';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'ಆ ವರದಿಯನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ವರದಿ ಲೈಬ್ರರಿಯನ್ನು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'ನಿಮ್ಮ ಖಾತೆಯು ಪರಿಶೀಲನೆಯಲ್ಲಿರುವಾಗ ಈ ಕ್ರಿಯೆಯು ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿರುವುದಿಲ್ಲ.';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'ಈ ವಿಭಾಗವನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiAppLockIsUnavailable => 'ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uiDoclyzerIsLocked => 'ಡಾಕ್ಲೈಸರ್ ಲಾಕ್ ಆಗಿದೆ';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'ಉಳಿಸಿದ ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್ ಸೆಟ್ಟಿಂಗ್ ಅನ್ನು ಓದಲಾಗಲಿಲ್ಲ. ಮುಂದುವರಿಸಲು ಮರುಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'ಮುಂದುವರಿಸಲು ನಿಮ್ಮ ಸಾಧನದ ಪಾಸ್‌ಕೋಡ್ ಅಥವಾ ಬಯೋಮೆಟ್ರಿಕ್‌ಗಳನ್ನು ಬಳಸಿ.';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'ನಿಮ್ಮ ಖಾತೆಯು ಪರಿಶೀಲನೆಯಲ್ಲಿರುವಾಗ ಅಪ್‌ಲೋಡ್‌ಗಳು ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿರುವುದಿಲ್ಲ.';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'ಅಪ್‌ಲೋಡ್ ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiJustNow => 'ಈಗಷ್ಟೇ';

  @override
  String get uiAdditionalDetails => 'ಹೆಚ್ಚುವರಿ ವಿವರಗಳು:';

  @override
  String get uiSaveCorrection => 'ತಿದ್ದುಪಡಿಯನ್ನು ಉಳಿಸಿ';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'ಫೈಲ್‌ಗಳನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಪ್ರವೇಶವನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'ಕ್ಯಾಮರಾ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಅನುಮತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'ಫೋಟೋಗಳನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಅನುಮತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'ಆಯ್ಕೆಮಾಡಿದ ಫೈಲ್ ಅನ್ನು ಪ್ರವೇಶಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'ಆಯ್ಕೆಮಾಡಿದ ಫೈಲ್ ಅನ್ನು ಪ್ರವೇಶಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'ಸಂಪರ್ಕ ಕಳೆದುಕೊಂಡಿದೆ. ಅಪ್‌ಲೋಡ್ ಸರ್ವರ್ ಅನ್ನು ತಲುಪಿರಬಹುದು. ಅದೇ ಫೈಲ್ ಅನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಮರುಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiCouldNotLoadExistingReport =>
      'ಅಸ್ತಿತ್ವದಲ್ಲಿರುವ ವರದಿಯನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ';

  @override
  String get uiAddingTo => 'ಗೆ ಸೇರಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'ಕೆಲವು ಫಲಿತಾಂಶಗಳನ್ನು ಪರಿಶೀಲಿಸುವ ಅಗತ್ಯವಿದೆ. ನಿಮ್ಮ ಮೂಲ ವರದಿಯನ್ನು ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'ನಮಗೆ ಈ ಸ್ವರೂಪವನ್ನು ಓದಲಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಫೈಲ್ ಅನ್ನು ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'ವರದಿಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಪಾರ್ಸ್ ಮಾಡಲಾಗಿದೆ. ಫಲಿತಾಂಶಗಳು ಮತ್ತು ಪ್ರವೃತ್ತಿಗಳು ಲಭ್ಯವಿದೆ.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'ನಿಮ್ಮ ವರದಿಯನ್ನು ಇನ್ನೂ ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ. ಅದರ ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಲು ಅದನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'ಪ್ರಕ್ರಿಯೆ ನಿಲ್ಲಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಫೈಲ್ ಅನ್ನು ಉಳಿಸಲಾಗಿದೆ. ನೀವು ಮರುಪ್ರಯತ್ನಿಸಬಹುದು.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'ಯಾವುದೇ ಹೊರತೆಗೆಯಲಾದ ಪರೀಕ್ಷಾ ಮೌಲ್ಯಗಳನ್ನು ಸೇರಿಸಲಾಗಿಲ್ಲ. ನೀವು ಇನ್ನೂ ಡಾಕ್ಯುಮೆಂಟ್ ಅನ್ನು ತೆರೆಯಬಹುದು ಮತ್ತು ಹಂಚಿಕೊಳ್ಳಬಹುದು. ನಿಮ್ಮ ಪ್ರವೃತ್ತಿಗಳು ಬದಲಾಗಿಲ್ಲ.';

  @override
  String get uiYourOriginalIsSaved => 'ನಿಮ್ಮ ಮೂಲವನ್ನು ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get uiInitialUpload => 'ಆರಂಭಿಕ ಅಪ್ಲೋಡ್';

  @override
  String get uiParsedSuccessfully => 'ಯಶಸ್ವಿಯಾಗಿ ಪಾರ್ಸ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get uiParsingFailed => 'ಪಾರ್ಸಿಂಗ್ ವಿಫಲವಾಗಿದೆ';

  @override
  String get uiExtractionIncomplete => 'ಹೊರತೆಗೆಯುವಿಕೆ ಅಪೂರ್ಣ';

  @override
  String get uiTransientFailure => 'ತಾತ್ಕಾಲಿಕ ವೈಫಲ್ಯ';

  @override
  String get uiTerminalFailure => 'ಟರ್ಮಿನಲ್ ವೈಫಲ್ಯ';

  @override
  String get uiFailedToLoadAttemptHistory =>
      'ಪ್ರಯತ್ನದ ಇತಿಹಾಸವನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'ಈ ವರದಿಯ ಫೈಲ್ ಇನ್ನು ಮುಂದೆ ಲಭ್ಯವಿರುವುದಿಲ್ಲ.';

  @override
  String get uiCompareResults => 'ಫಲಿತಾಂಶಗಳನ್ನು ಹೋಲಿಕೆ ಮಾಡಿ';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'ಯಾವುದೇ ವ್ಯತ್ಯಾಸವನ್ನು ಲೆಕ್ಕಹಾಕಲಾಗಿಲ್ಲ. ಹೊಂದಾಣಿಕೆಯ ದೃಢೀಕರಣದ ಅಗತ್ಯವಿದೆ.';

  @override
  String get uiUnitNotRecorded => 'ಘಟಕವನ್ನು ದಾಖಲಿಸಲಾಗಿಲ್ಲ';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'ಈ ವರದಿಗಳ ನಡುವೆ ಯಾವುದೇ ಸಂಖ್ಯಾ ಬದಲಾವಣೆ ಇಲ್ಲ.';

  @override
  String get uiUnableToRestore => 'ಮರುಸ್ಥಾಪಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ:';

  @override
  String get uiEnterAGiftVoucherCode => 'ಉಡುಗೊರೆ ವೋಚರ್ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get uiApplyVoucher => 'ವೋಚರ್ ಅನ್ನು ಅನ್ವಯಿಸಿ';

  @override
  String get uiNotAvailable => 'ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uiViewReceipt => 'ರಶೀದಿಯನ್ನು ವೀಕ್ಷಿಸಿ';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'ಗಿಫ್ಟ್ ವೋಚರ್ ಅಮಾನ್ಯವಾಗಿದೆ ಅಥವಾ ಈಗಾಗಲೇ ರಿಡೀಮ್ ಮಾಡಲಾಗಿದೆ.';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'ಗಿಫ್ಟ್ ವೋಚರ್ ಅನ್ನು ಈಗಾಗಲೇ ರಿಡೀಮ್ ಮಾಡಲಾಗಿದೆ.';

  @override
  String get uiGiftVoucherHasBeenVoided =>
      'ಗಿಫ್ಟ್ ವೋಚರ್ ಅನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ.';

  @override
  String get uiGiftVoucherHasExpired => 'ಗಿಫ್ಟ್ ವೋಚರ್ ಅವಧಿ ಮುಗಿದಿದೆ.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'ಈ ಉಡುಗೊರೆ ವೋಚರ್ ಅನ್ನು ರಿಡೀಮ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'ಈ ಉಡುಗೊರೆ ವೋಚರ್ ಅನ್ನು ರಿಡೀಮ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiEnterAPromoCodeToApply => 'ಅನ್ವಯಿಸಲು ಪ್ರೋಮೋ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get uiPromoCodeNotFound => 'ಪ್ರೋಮೋ ಕೋಡ್ ಕಂಡುಬಂದಿಲ್ಲ.';

  @override
  String get uiPromoCodeIsInactive => 'ಪ್ರೋಮೋ ಕೋಡ್ ನಿಷ್ಕ್ರಿಯವಾಗಿದೆ.';

  @override
  String get uiPromoCodeHasExpired => 'ಪ್ರೋಮೋ ಕೋಡ್ ಅವಧಿ ಮುಗಿದಿದೆ.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'ಈ ಪ್ಯಾಕ್‌ಗೆ ಪ್ರೋಮೋ ಕೋಡ್ ಅನ್ವಯಿಸುವುದಿಲ್ಲ.';

  @override
  String get uiPromoCodeUsageLimitReached =>
      'ಪ್ರೋಮೋ ಕೋಡ್ ಬಳಕೆಯ ಮಿತಿಯನ್ನು ತಲುಪಿದೆ.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'ನೀವು ಈಗಾಗಲೇ ಈ ಪ್ರೋಮೋ ಕೋಡ್ ಅನ್ನು ಬಳಸಿದ್ದೀರಿ.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'ಪ್ರೋಮೋ ಕೋಡ್ ಅನ್ನು ಅನ್ವಯಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಸೇರಿಸುವ ಮೊದಲು ಈ ಆದೇಶವನ್ನು ಪರಿಶೀಲನೆಗಾಗಿ ಫ್ಲ್ಯಾಗ್ ಮಾಡಲಾಗಿದೆ.';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'ಸಮನ್ವಯದ ಸಮಯದಲ್ಲಿ ಪಾವತಿ ವಿಫಲವಾಗಿದೆ. ನೀವು ಸುರಕ್ಷಿತವಾಗಿ ಮರುಪ್ರಯತ್ನಿಸಬಹುದು.';

  @override
  String get uiAwaitingCapture => 'ಸೆರೆಹಿಡಿಯುವಿಕೆಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ';

  @override
  String get uiLastPaymentFailed => 'ಕೊನೆಯ ಪಾವತಿ ವಿಫಲವಾಗಿದೆ';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'ನೀವು ಸುರಕ್ಷಿತವಾಗಿ ಚೆಕ್ಔಟ್ ಅನ್ನು ಮರುಪ್ರಯತ್ನಿಸಬಹುದು.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'ಚಂದಾದಾರಿಕೆಗಳಿಗೆ ಪ್ರೋಮೋ ಕೋಡ್‌ಗಳು ಇನ್ನೂ ಬೆಂಬಲಿತವಾಗಿಲ್ಲ.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'ರಫ್ತು ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'ಮೂಲ ವರದಿಗಳು ಅಥವಾ ಪರೀಕ್ಷಾ ಫಲಿತಾಂಶಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'ರಫ್ತು ಮಾಡಲು ವಿನಂತಿಸಲಾಗಿದೆ. ರಿಫ್ರೆಶ್ ಮಾಡಲು \"ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ\" ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'ರಫ್ತು ಮಾಡಲು ವಿನಂತಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'ರಫ್ತು ಸಿದ್ಧವಾಗಿದೆ. ಡೌನ್‌ಲೋಡ್ URL ಲಭ್ಯವಿದೆ.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'ರಫ್ತು ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'ಖಾತೆಯನ್ನು ಮುಚ್ಚಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiPrepareExport => 'ರಫ್ತು ತಯಾರಿಸಿ';

  @override
  String get uiSaveExport => 'ರಫ್ತು ಉಳಿಸಿ';

  @override
  String get uiPrepareExportAgain => 'ಮತ್ತೆ ರಫ್ತು ತಯಾರಿಸಿ';

  @override
  String get uiAllDates => 'ಎಲ್ಲಾ ದಿನಾಂಕಗಳು';

  @override
  String get uiPreparingAccountDetails => 'ಖಾತೆ ವಿವರಗಳನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get uiFamilyMemberProfiles => 'ಕುಟುಂಬ ಸದಸ್ಯರ ಪ್ರೊಫೈಲ್‌ಗಳು';

  @override
  String get uiUploadedReports => 'ವರದಿಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get uiDownloadReady => 'ಡೌನ್‌ಲೋಡ್ ಸಿದ್ಧವಾಗಿದೆ';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'ಈ ಸಾಧನದಲ್ಲಿ ವರದಿ ಅಧಿಸೂಚನೆಗಳನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'ಸಾಧನ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಲಾಗಿದೆ. ಡಾಕ್ಲೈಜರ್‌ಗಾಗಿ ಅಧಿಸೂಚನೆಗಳನ್ನು ಅನುಮತಿಸಿ, ನಂತರ ಇಲ್ಲಿಗೆ ಹಿಂತಿರುಗಿ.';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'ಅಧಿಸೂಚನೆಗಳು ಇನ್ನೂ ಆಫ್ ಆಗಿವೆ. ವರದಿ ನವೀಕರಣಗಳನ್ನು ಸ್ವೀಕರಿಸಲು ಸಾಧನ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅವರಿಗೆ ಅನುಮತಿಸಿ.';

  @override
  String get uiPreferencesSaved => 'ಪ್ರಾಶಸ್ತ್ಯಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'ನಿಮ್ಮ ಖಾತೆಯ ಆಯ್ಕೆಯನ್ನು ಉಳಿಸಲಾಗಿದೆ, ಆದರೆ ಈ ಸಾಧನವು ಮಾರ್ಕೆಟಿಂಗ್ ಪುಶ್‌ಗಾಗಿ ನೋಂದಾಯಿಸುವುದನ್ನು ಪೂರ್ಣಗೊಳಿಸಲಿಲ್ಲ. ಈ ಸಾಧನದಲ್ಲಿ ಮಾರ್ಕೆಟಿಂಗ್ ಅನ್ನು ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ; ಅಧಿಸೂಚನೆ ಅನುಮತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಉಳಿಸಲು ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'ನಿಮ್ಮ ಖಾತೆಯ ಆಯ್ಕೆಯನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಈ ಸಾಧನವು ಅದರ ಸ್ಥಳೀಯ ಆದ್ಯತೆಯನ್ನು ಇನ್ನೂ ದೃಢೀಕರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ, ಆದರೆ ಖಾತೆ ಮಟ್ಟದಲ್ಲಿ ಮಾರ್ಕೆಟಿಂಗ್ ಅನ್ನು ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ.';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'ನಿಮ್ಮ ಖಾತೆಯ ಆಯ್ಕೆಯನ್ನು ಉಳಿಸಲಾಗಿದೆ, ಆದರೆ ಈ ಸಾಧನವು ಮಾರ್ಕೆಟಿಂಗ್ ಪುಶ್ ಅನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಅಧಿಸೂಚನೆ ಅನುಮತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'ಉಳಿತಾಯವು ತುಂಬಾ ಸಮಯ ತೆಗೆದುಕೊಂಡಿತು. ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಹಾಗೂ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiReportReadyForReview => 'ವರದಿ ಪರಿಶೀಲನೆಗೆ ಸಿದ್ಧವಾಗಿದೆ';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'ನಿಮ್ಮ ಫಲಿತಾಂಶಗಳು ಯಾವಾಗ ಪರಿಶೀಲಿಸಲು ಸಿದ್ಧವಾಗಿವೆ ಎಂಬುದನ್ನು ತಿಳಿದುಕೊಳ್ಳಿ.';

  @override
  String get uiUploadUpdates => 'ನವೀಕರಣಗಳನ್ನು ಅಪ್ಲೋಡ್ ಮಾಡಿ';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'ಅಪ್‌ಲೋಡ್‌ಗೆ ಗಮನ ಬೇಕಾದರೆ ಸಂದೇಶವನ್ನು ಪಡೆಯಿರಿ.';

  @override
  String get uiSharedLinkReminders => 'ಹಂಚಿಕೊಂಡ ಲಿಂಕ್ ರಿಮೈಂಡರ್‌ಗಳು';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'ಲಿಂಕ್ ಅವಧಿ ಮುಕ್ತಾಯಗೊಳ್ಳಲಿದೆ ಎಂಬುದನ್ನು ಕೇಳಿ.';

  @override
  String get uiSecurityAlerts => 'ಭದ್ರತಾ ಎಚ್ಚರಿಕೆಗಳು';

  @override
  String get uiRequiredForAccountSafety => 'ಖಾತೆ ಸುರಕ್ಷತೆಗಾಗಿ ಅಗತ್ಯವಿದೆ.';

  @override
  String get uiComplianceNotices => 'ಅನುಸರಣೆ ಸೂಚನೆಗಳು';

  @override
  String get uiRequiredAccountInformation => 'ಅಗತ್ಯವಿರುವ ಖಾತೆ ಮಾಹಿತಿ.';

  @override
  String get uiMarketingPushNotifications => 'ಮಾರ್ಕೆಟಿಂಗ್ ಪುಶ್ ಅಧಿಸೂಚನೆಗಳು';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ಕೊಡುಗೆಗಳು ಮತ್ತು ಪ್ರಕಟಣೆಗಳು. ಈ ಆಯ್ಕೆಯನ್ನು ಉಳಿಸುವುದು ಈ ಸಾಧನಕ್ಕೆ ಸಹ ಅನ್ವಯಿಸುತ್ತದೆ.';

  @override
  String get uiProductUpdates => 'ಉತ್ಪನ್ನ ನವೀಕರಣಗಳು';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'ಡಾಕ್ಲೈಜರ್ ಬಗ್ಗೆ ಐಚ್ಛಿಕ ಸುದ್ದಿ.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'ಸರ್ವರ್‌ಗೆ ಸಂಪರ್ಕಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಅಥವಾ API ಸರ್ವರ್ ಅನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'ನಿಮ್ಮ ಖಾತೆಯು ಪರಿಶೀಲನೆಯಲ್ಲಿರುವಾಗ ಪ್ರೊಫೈಲ್ ನವೀಕರಣಗಳು ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿರುವುದಿಲ್ಲ.';

  @override
  String get uiUse100CharactersOrFewer =>
      '100 ಅಥವಾ ಅದಕ್ಕಿಂತ ಕಡಿಮೆ ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ';

  @override
  String get uiAddProfile => 'ಪ್ರೊಫೈಲ್ ಸೇರಿಸಿ';

  @override
  String get uiCreateProfile => 'ಪ್ರೊಫೈಲ್ ರಚಿಸಿ';

  @override
  String get uiUpdateTheirDetails => 'ಅವರ ವಿವರಗಳನ್ನು ನವೀಕರಿಸಿ';

  @override
  String get uiWhoIsThisProfileFor => 'ಈ ಪ್ರೊಫೈಲ್ ಯಾರಿಗಾಗಿ?';

  @override
  String get uiNotSelected => 'ಆಯ್ಕೆಯಾಗಿಲ್ಲ';

  @override
  String get uiEnterAReferralCode => 'ರೆಫರಲ್ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'ರೆಫರಲ್ ಅನ್ವಯಿಸಲಾಗಿದೆ. ಇಮೇಲ್ ಪರಿಶೀಲನೆಯ ನಂತರ ಬೋನಸ್ ಅನ್‌ಲಾಕ್ ಆಗುತ್ತದೆ.';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'ರೆಫರಲ್ ಅನ್ವಯಿಸಲಾಗಿದೆ. ಬೋನಸ್ ಕ್ರೆಡಿಟ್‌ಗಳು ಸಿದ್ಧವಾಗಿವೆ.';

  @override
  String get uiApplyCode => 'ಕೋಡ್ ಅನ್ನು ಅನ್ವಯಿಸಿ';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'ನಿಮ್ಮ ಸ್ವಂತ ರೆಫರಲ್ ಕೋಡ್ ಅನ್ನು ನೀವು ಅನ್ವಯಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.';

  @override
  String get uiReferralCodeIsInvalid => 'ರೆಫರಲ್ ಕೋಡ್ ಅಮಾನ್ಯವಾಗಿದೆ.';

  @override
  String get uiFailedToApplyReferralCode =>
      'ರೆಫರಲ್ ಕೋಡ್ ಅನ್ನು ಅನ್ವಯಿಸಲು ವಿಫಲವಾಗಿದೆ.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'ರೆಫರಲ್ ಕೋಡ್ ಅನ್ನು ಅನ್ವಯಿಸಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiThisDevice => 'ಈ ಸಾಧನ';

  @override
  String get uiSignedInDevice => 'ಸೈನ್ ಇನ್ ಮಾಡಿದ ಸಾಧನ';

  @override
  String get uiUnknownDevice => 'ಅಜ್ಞಾತ ಸಾಧನ';

  @override
  String get uiRevokeAndLogOut => 'ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ ಮತ್ತು ಲಾಗ್ ಔಟ್ ಮಾಡಿ';

  @override
  String get uiRevokeSessionca8440 => 'ಅಧಿವೇಶನವನ್ನು ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ';

  @override
  String get uiEnterYourCurrentPassword =>
      'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಗುಪ್ತಪದವನ್ನು ನಮೂದಿಸಿ';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'ದೊಡ್ಡಕ್ಷರ, ಸಣ್ಣಕ್ಷರ, ಸಂಖ್ಯೆ ಮತ್ತು ವಿಶೇಷ ಅಕ್ಷರದೊಂದಿಗೆ ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ';

  @override
  String get uiChooseADifferentPassword => 'ಬೇರೆ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uiNewPasswordsDoNotMatch =>
      'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'ನೀವು ಲಭ್ಯವಿರುವ ಎಲ್ಲಾ ಅಪ್‌ಲೋಡ್ ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಬಳಸಿದ್ದೀರಿ. ಇನ್ನಷ್ಟು ಸೇರಿಸಲು ಯೋಜನೆ ಮತ್ತು ಕ್ರೆಡಿಟ್‌ಗಳಿಗೆ ಭೇಟಿ ನೀಡಿ.';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'ಡಾಕ್ಲೈಜರ್‌ಗಾಗಿ ಅಧಿಸೂಚನೆಗಳನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ. ವರದಿ-ಸಿದ್ಧ ಮತ್ತು ಖಾತೆ ನವೀಕರಣಗಳನ್ನು ಅನುಮತಿಸಲು ಸಾಧನ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ. ನೀವು ಅದನ್ನು ಆಯ್ಕೆ ಮಾಡದ ಹೊರತು ಮಾರ್ಕೆಟಿಂಗ್ ಆಫ್ ಆಗಿರುತ್ತದೆ.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'ಈ ಸಾಧನದಲ್ಲಿ ವರದಿ-ಸಿದ್ಧ ಮತ್ತು ಖಾತೆ ನವೀಕರಣಗಳನ್ನು ಪಡೆಯಿರಿ. ನೀವು ಅದನ್ನು ಆಯ್ಕೆ ಮಾಡದ ಹೊರತು ಮಾರ್ಕೆಟಿಂಗ್ ಆಫ್ ಆಗಿರುತ್ತದೆ.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'ಈ ಸಾಧನಕ್ಕೆ ಅಧಿಸೂಚನೆಗಳು ಆಫ್ ಆಗಿವೆ. ವರದಿ-ಸಿದ್ಧ ಮತ್ತು ಖಾತೆ ನವೀಕರಣಗಳನ್ನು ಸ್ವೀಕರಿಸಲು ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ.';

  @override
  String get uiBlockedExpiredRevoked =>
      'ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ (ಅವಧಿ ಮೀರಿದೆ/ಹಿಂತೆಗೆದುಕೊಳ್ಳಲಾಗಿದೆ)';

  @override
  String get uiFailedToLoadPolicy => 'ನೀತಿಯನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ';

  @override
  String get uiUploadPaused => 'ಅಪ್‌ಲೋಡ್ ಅನ್ನು ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get uiSevenDays => '7 ದಿನಗಳು';

  @override
  String get uiThirtyDays => '30 ದಿನಗಳು';

  @override
  String get uiNinetyDays => '90 ದಿನಗಳು';

  @override
  String get uiUploadingAClearReport =>
      'ಸ್ಪಷ್ಟ ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ';

  @override
  String get uiPDFsPhotosAndMultiplePages =>
      'PDF ಗಳು, ಫೋಟೋಗಳು ಮತ್ತು ಬಹು ಪುಟಗಳು';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'PDF ಅನ್ನು ಆಯ್ಕೆಮಾಡಿ ಅಥವಾ ಪ್ರತಿ ಪುಟದ ಸ್ಪಷ್ಟ ಫೋಟೋಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳಿ. ಇಡೀ ಪುಟವನ್ನು ಚೌಕಟ್ಟಿನಲ್ಲಿ ಇರಿಸಿ, ಪ್ರಜ್ವಲಿಸುವಿಕೆಯನ್ನು ತಪ್ಪಿಸಿ ಮತ್ತು ವಿಶ್ಲೇಷಿಸುವ ಮೊದಲು ಪುಟದ ಕ್ರಮವನ್ನು ಪರಿಶೀಲಿಸಿ. ನೀವು ಮೂಲಕ್ಕೆ ವಿರುದ್ಧವಾಗಿ ಹೊರತೆಗೆಯಲಾದ ಮೌಲ್ಯಗಳನ್ನು ಸರಿಪಡಿಸಬಹುದು.';

  @override
  String get uiCorrectingAResult => 'ಫಲಿತಾಂಶವನ್ನು ಸರಿಪಡಿಸುವುದು';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'ಮೂಲ ವಿರುದ್ಧ ಮೌಲ್ಯಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'ವರದಿಯನ್ನು ತೆರೆಯಿರಿ, ಪ್ರತಿ ಹೊರತೆಗೆದ ಪರೀಕ್ಷೆಯನ್ನು ಮೂಲಕ್ಕೆ ವಿರುದ್ಧವಾಗಿ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ತಪ್ಪಾಗಿ ಓದಲಾದ ಯಾವುದೇ ಮೌಲ್ಯ, ಘಟಕ ಅಥವಾ ದಿನಾಂಕವನ್ನು ಸರಿಪಡಿಸಿ. ನೀವು ಟ್ರೆಂಡ್‌ಗಳನ್ನು ಅವಲಂಬಿಸುವ ಮೊದಲು ದೃಢೀಕರಿಸದ ಫಲಿತಾಂಶಗಳನ್ನು ಪರಿಶೀಲಿಸಬೇಕು.';

  @override
  String get uiManagingFamilyRecords => 'ಕುಟುಂಬದ ದಾಖಲೆಗಳನ್ನು ನಿರ್ವಹಿಸುವುದು';

  @override
  String get uiProfilesAccessAndPermissions =>
      'ಪ್ರೊಫೈಲ್‌ಗಳು, ಪ್ರವೇಶ ಮತ್ತು ಅನುಮತಿಗಳು';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ರಚಿಸಲು ಮತ್ತು ಬದಲಾಯಿಸಲು ಕುಟುಂಬವನ್ನು ಬಳಸಿ. ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡುವ ಅಥವಾ ಹಂಚಿಕೊಳ್ಳುವ ಮೊದಲು ಆಯ್ಕೆಮಾಡಿದ ವ್ಯಕ್ತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ. ನೀವು ಪ್ರವೇಶಿಸಲು ಅಧಿಕಾರ ಹೊಂದಿರುವ ದಾಖಲೆಗಳನ್ನು ಮಾತ್ರ ನಿರ್ವಹಿಸಿ.';

  @override
  String get uiSharingAndRevokingLinks =>
      'ಲಿಂಕ್‌ಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳುವುದು ಮತ್ತು ಹಿಂಪಡೆಯುವುದು';

  @override
  String get uiControlTheRecordsYouShare =>
      'ನೀವು ಹಂಚಿಕೊಳ್ಳುವ ದಾಖಲೆಗಳನ್ನು ನಿಯಂತ್ರಿಸಿ';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'ನೀವು ಹಂಚಿಕೊಳ್ಳಲು ಬಯಸುವ ವರದಿಗಳು ಅಥವಾ ಫಲಿತಾಂಶಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ, ಮುಕ್ತಾಯ ಮತ್ತು ಪ್ರವೇಶ ಕೋಡ್ ಅನ್ನು ಪರಿಶೀಲಿಸಿ, ನಂತರ ಲಿಂಕ್ ಮತ್ತು ಕೋಡ್ ಅನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ಕಳುಹಿಸಿ. ಇನ್ನು ಮುಂದೆ ಪ್ರವೇಶ ಅಗತ್ಯವಿಲ್ಲದಿದ್ದಾಗ ಹಂಚಿಕೊಂಡ ಲಿಂಕ್‌ಗಳಿಂದ ಸಕ್ರಿಯ ಲಿಂಕ್ ಅನ್ನು ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ.';

  @override
  String get uiInformationYouProvide => 'ನೀವು ಒದಗಿಸುವ ಮಾಹಿತಿ';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'ಖಾತೆಯ ವಿವರಗಳು ಮತ್ತು ಕುಟುಂಬದ ಪ್ರೊಫೈಲ್‌ಗಳು ನೀವು ಯಾರ ದಾಖಲೆಗಳನ್ನು ನಿರ್ವಹಿಸುತ್ತೀರಿ ಎಂಬುದನ್ನು ಗುರುತಿಸುತ್ತವೆ. ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾದ ಡಾಕ್ಯುಮೆಂಟ್‌ಗಳು ಸೂಕ್ಷ್ಮ ಆರೋಗ್ಯ ಮಾಹಿತಿಯನ್ನು ಹೊಂದಿರಬಹುದು.';

  @override
  String get uiSharingControls => 'ಹಂಚಿಕೆ ನಿಯಂತ್ರಣಗಳು';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'ಪ್ರತಿ ಲಿಂಕ್‌ನ ವಿಷಯಗಳು, ಮುಕ್ತಾಯ ಮತ್ತು ಪ್ರವೇಶ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ. ನಿಮ್ಮ ಖಾತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳಿಂದ ಸಕ್ರಿಯ ಲಿಂಕ್‌ಗಳನ್ನು ನಿರ್ವಹಿಸಿ.';

  @override
  String get uiExportAndAccountChoices => 'ರಫ್ತು ಮತ್ತು ಖಾತೆ ಆಯ್ಕೆಗಳು';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'ದಾಖಲೆಗಳನ್ನು ರಫ್ತು ಮಾಡಲು ಅಥವಾ ಖಾತೆ ಅಳಿಸುವಿಕೆ ವಿನಂತಿಯನ್ನು ಪ್ರಾರಂಭಿಸಲು ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಬಳಸಿ. ಧಾರಣ ವಿವರಗಳು ಸಂಪೂರ್ಣ ನೀತಿಯಲ್ಲಿ ಸೇರಿವೆ.';

  @override
  String get uiEducationalScope => 'ಶೈಕ್ಷಣಿಕ ವ್ಯಾಪ್ತಿ';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'ಡಾಕ್ಲೈಜರ್ ವರದಿಗಳನ್ನು ಆಯೋಜಿಸುತ್ತದೆ ಮತ್ತು ಕಾಲಾನಂತರದಲ್ಲಿ ಫಲಿತಾಂಶಗಳನ್ನು ತೋರಿಸುತ್ತದೆ. ಶೈಕ್ಷಣಿಕ ವಿವರಣೆಗಳು ವೈದ್ಯಕೀಯ ಸಲಹೆ ಅಥವಾ ರೋಗನಿರ್ಣಯವಲ್ಲ.';

  @override
  String get uiReviewYourRecords => 'ನಿಮ್ಮ ದಾಖಲೆಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'ಮೂಲ ವರದಿಯ ವಿರುದ್ಧ ಹೊರತೆಗೆಯಲಾದ ಮೌಲ್ಯಗಳು, ಘಟಕಗಳು ಮತ್ತು ದಿನಾಂಕಗಳನ್ನು ಪರಿಶೀಲಿಸಿ. ನಿಮ್ಮ ಫಲಿತಾಂಶಗಳ ಬಗ್ಗೆ ಆರೋಗ್ಯ ವೃತ್ತಿಪರರನ್ನು ಕೇಳಿ.';

  @override
  String get uiManageAndShareResponsibly =>
      'ನಿರ್ವಹಿಸಿ ಮತ್ತು ಜವಾಬ್ದಾರಿಯುತವಾಗಿ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'ನೀವು ಪ್ರವೇಶಿಸಲು ಅಧಿಕಾರ ಹೊಂದಿರುವ ದಾಖಲೆಗಳನ್ನು ಮಾತ್ರ ನಿರ್ವಹಿಸಿ. ಹಂಚಿಕೊಳ್ಳುವ ಮೊದಲು ಆಯ್ಕೆಮಾಡಿದ ಮಾಹಿತಿ ಮತ್ತು ಸ್ವೀಕರಿಸುವವರನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiPrivacyPolicy7ceacd => 'ಗೌಪ್ಯತೆ ನೀತಿ';

  @override
  String get uiTermsOfUse8a069e => 'ಬಳಕೆಯ ನಿಯಮಗಳು';

  @override
  String get uiOpenPrivacyControls => 'ಗೌಪ್ಯತೆ ನಿಯಂತ್ರಣಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get uiGetHelpWithTheApp => 'ಅಪ್ಲಿಕೇಶನ್‌ನೊಂದಿಗೆ ಸಹಾಯ ಪಡೆಯಿರಿ';

  @override
  String get uiExportYourDataInAccountSettings =>
      'ಖಾತೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ನಿಮ್ಮ ಡೇಟಾವನ್ನು ರಫ್ತು ಮಾಡಿ';

  @override
  String get uiYOURDATACHOICES => 'ನಿಮ್ಮ ಡೇಟಾ ಮತ್ತು ಆಯ್ಕೆಗಳು';

  @override
  String get uiUSINGDOCLYZER => 'ಡಾಕ್ಲೈಜರ್ ಅನ್ನು ಬಳಸುವುದು';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'ನೀವು ಡಾಕ್ಲೈಜರ್‌ನಲ್ಲಿ ಇರಿಸಿಕೊಳ್ಳುವ\nಮಾಹಿತಿಯನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ.';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'ಅಪ್ಲಿಕೇಶನ್‌ನ ಪಾತ್ರದ ಸ್ಪಷ್ಟ ತಿಳುವಳಿಕೆ\n.';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name ನಿಂದ $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · ಇತ್ತೀಚಿನ $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'ಈ ಲೈಬ್ರರಿಯನ್ನು ಪ್ರಾರಂಭಿಸಲು $name ಗಾಗಿ ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP ವಿಳಾಸ: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'ಸೈನ್ ಇನ್ ಮಾಡಲಾಗಿದೆ: $date';
  }

  @override
  String get uiUnknown => 'ಅಜ್ಞಾತ';

  @override
  String uiResultsFor(String name) {
    return '$name ಗಾಗಿ ಫಲಿತಾಂಶಗಳು';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count ಲ್ಯಾಬ್ ಪ್ಯಾರಾಮೀಟರ್‌ಗಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String uiSampledDate(String date) {
    return 'ಮಾದರಿ $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'ಸಂಗ್ರಹಣೆ ದಿನಾಂಕ: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'ಲ್ಯಾಬ್ ಶ್ರೇಣಿ: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI ಈ ಶ್ರೇಣಿಯನ್ನು $range ಎಂದು ಓದಿದೆ. ಮುದ್ರಿತ ಪಠ್ಯ: $printed. ಈ ಹೋಲಿಕೆಯನ್ನು ಅವಲಂಬಿಸುವ ಮೊದಲು ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount ಸಿದ್ಧವಾಗಿದೆ';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count ಕ್ರೆಡಿಟ್‌ಗಳು';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'ಈ ಖಾತೆಗೆ ರೆಫರಲ್ ಕೋಡ್ ಅನ್ನು ಈಗಾಗಲೇ ಅನ್ವಯಿಸಲಾಗಿದೆ.';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ಅಪ್ಲಿಕೇಶನ್ ಲಾಕ್ ಅನ್ನು ಆನ್ ಮಾಡುವ ಮೊದಲು ಸಾಧನದ ಪಾಸ್‌ಕೋಡ್ ಅನ್ನು ಹೊಂದಿಸಿ.';

  @override
  String get uiLanguagePreferenceNotSaved =>
      'ಭಾಷಾ ಪ್ರಾಶಸ್ತ್ಯವನ್ನು ಉಳಿಸಲಾಗಿಲ್ಲ.';

  @override
  String get uiExportUnavailable => 'ರಫ್ತು ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get uiUnreadableImage => 'ಓದಲಾಗದ ಚಿತ್ರ';

  @override
  String uiStatusWithValue(String status) {
    return 'ಸ್ಥಿತಿ: $status';
  }

  @override
  String get uiPending => 'ಬಾಕಿಯಿದೆ';

  @override
  String get uiCompleted => 'ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get uiFailed => 'ವಿಫಲವಾಗಿದೆ';

  @override
  String get uiInactive => 'ನಿಷ್ಕ್ರಿಯ';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'ನಿಮ್ಮ ವರದಿಗಳು ಮತ್ತು ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಇರಿಸಿಕೊಳ್ಳಲು $date ಮೊದಲು ಮರುಸ್ಥಾಪಿಸಿ.';
  }

  @override
  String get uiThirtyDayDeadline => '30 ದಿನಗಳ ಗಡುವು';

  @override
  String uiWhatsAffected(String details) {
    return 'ಏನು ಪರಿಣಾಮ ಬೀರುತ್ತದೆ: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'ಕೊನೆಯದಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ: $time ನಲ್ಲಿ $date';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename ಪ್ರಸ್ತುತ ಪ್ರೊಫೈಲ್ ಬದಲಿಗೆ $name ಅಡಿಯಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.';
  }

  @override
  String get uiOneVerifiedResult => '1 ಪರಿಶೀಲಿಸಿದ ಫಲಿತಾಂಶವನ್ನು ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count ಪರಿಶೀಲಿಸಿದ ಫಲಿತಾಂಶಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ.';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'ಪ್ರೊಫೈಲ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'ಸಂಗ್ರಹಿಸಲಾಗಿದೆ: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ದಿನಾಂಕ $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount ಯಿಂದ ಹೆಚ್ಚಿಸಲಾಗಿದೆ';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount ನಿಂದ ಕಡಿಮೆಯಾಗಿದೆ';
  }

  @override
  String get uiPercentagePoints => 'ಶೇಕಡಾವಾರು ಅಂಕಗಳು';

  @override
  String uiTestValuesCount(String count) {
    return 'ಪರೀಕ್ಷಾ ಮೌಲ್ಯಗಳು ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'ಪ್ರಕ್ರಿಯೆಯ ಸಮಯದಲ್ಲಿ AI ನಿಂದ ಮೌಲ್ಯವನ್ನು ಪರಿಶೀಲಿಸಲಾಗಿದೆ. ಮೂಲ OCR: $value. ವರದಿಯ ವಿರುದ್ಧ ಅದನ್ನು ದೃಢೀಕರಿಸಿ.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return 'ಈಗಾಗಲೇ $name ನಲ್ಲಿ ವರದಿ ಮಾಡಿ';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return 'ವರದಿಯನ್ನು $name ಗೆ ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String uiAddedOn(String date) {
    return '$date ಸೇರಿಸಲಾಗಿದೆ';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max ವರದಿಗಳ $current ಅನ್ನು ಬಳಸುವುದು.';
  }

  @override
  String get uiNeedHelp => 'ಸಹಾಯ ಬೇಕೇ?';

  @override
  String get uiEnabled => 'ಸಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ';

  @override
  String get uiEnable => 'ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get uiSubscribe => 'ಚಂದಾದಾರರಾಗಿ';

  @override
  String get uiApplying => 'ಅರ್ಜಿ ಸಲ್ಲಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get uiCheckStatus => 'ಸ್ಥಿತಿ ಪರಿಶೀಲಿಸಿ';

  @override
  String get uiEditProfile => 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ';

  @override
  String get uiSaveChanges => 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get uiOptional => 'ಐಚ್ಛಿಕ';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ಆರ್ಡರ್ $orderId ಸಮನ್ವಯಕ್ಕಾಗಿ ಕಾಯುತ್ತಿದೆ. ಸ್ಥಿತಿ ಸ್ಪಷ್ಟವಾಗುವವರೆಗೆ ಖರೀದಿಯನ್ನು ವಿರಾಮಗೊಳಿಸಲಾಗುತ್ತದೆ.';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'ಮಾಸಿಕ ಯೋಜನೆ - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'ಕ್ರೆಡಿಟ್ ಪ್ಯಾಕ್ - $name';
  }

  @override
  String get uiUnreadable => 'ಓದಲಾಗದು';

  @override
  String uiLatestValue(String value) {
    return 'ಇತ್ತೀಚಿನದು: $value';
  }

  @override
  String get uiEarlier => 'ಹಿಂದಿನ';

  @override
  String get uiLater => 'ನಂತರ';

  @override
  String get uiViewed => 'ವೀಕ್ಷಿಸಲಾಗಿದೆ';

  @override
  String get uiBlocked => 'ನಿರ್ಬಂಧಿಸಲಾಗಿದೆ';

  @override
  String get uiCapped => 'ಕ್ಯಾಪ್ಡ್';

  @override
  String uiLastChange(String label) {
    return 'ಕೊನೆಯ ಬದಲಾವಣೆ: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'ಕೊನೆಯ ಬದಲಾವಣೆ: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'ಗಿಫ್ಟ್ ವೋಚರ್ ಅನ್ವಯಿಸಲಾಗಿದೆ. $credits ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ.';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'ಮೂಲವನ್ನು ಇನ್ನೂ ಉಳಿಸಲಾಗಲಿಲ್ಲ. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'ಹಿಂತೆಗೆದುಕೊಳ್ಳಲು ವಿಫಲವಾಗಿದೆ: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'ನನ್ನ ಡಾಕ್ಲೈಜರ್ ರೆಫರಲ್ ಕೋಡ್ $code ಬಳಸಿ: $link';
  }

  @override
  String get uiAMomentAgo => 'ಒಂದು ಕ್ಷಣ ಹಿಂದೆ';

  @override
  String uiMinutesAgo(String count) {
    return '$count ನಿಮಿಷಗಳ ಹಿಂದೆ';
  }

  @override
  String get uiOneHourAgo => '1 ಗಂಟೆ ಹಿಂದೆ';

  @override
  String uiHoursAgo(String count) {
    return '$count ಗಂಟೆಗಳ ಹಿಂದೆ';
  }

  @override
  String get uiToday => 'ಇಂದು';

  @override
  String get uiYesterday => 'ನಿನ್ನೆ';

  @override
  String get uiOneDayAgo => '1 ದಿನದ ಹಿಂದೆ';

  @override
  String uiDaysAgo(String count) {
    return '$count ದಿನಗಳ ಹಿಂದೆ';
  }

  @override
  String get uiOneWeekAgo => '1 ವಾರದ ಹಿಂದೆ';

  @override
  String uiWeeksAgo(String count) {
    return '$count ವಾರಗಳ ಹಿಂದೆ';
  }

  @override
  String get uiOneMonthAgo => '1 ತಿಂಗಳ ಹಿಂದೆ';

  @override
  String uiMonthsAgo(String count) {
    return '$count ತಿಂಗಳ ಹಿಂದೆ';
  }

  @override
  String get uiOneYearAgo => '1 ವರ್ಷದ ಹಿಂದೆ';

  @override
  String uiYearsAgo(String count) {
    return '$count ವರ್ಷಗಳ ಹಿಂದೆ';
  }

  @override
  String get uiInOneDay => '1 ದಿನದಲ್ಲಿ';

  @override
  String uiInDays(String count) {
    return '$count ದಿನಗಳಲ್ಲಿ';
  }

  @override
  String uiInMinutes(String count) {
    return '$count ನಿಮಿಷದಲ್ಲಿ';
  }

  @override
  String get uiInOneHour => '1 ಗಂಟೆಯಲ್ಲಿ';

  @override
  String uiInHours(String count) {
    return '$count ಗಂಟೆಗಳಲ್ಲಿ';
  }

  @override
  String get uiMissingExtractedTestName =>
      'ಹೊರತೆಗೆದ ಫಲಿತಾಂಶದಿಂದ ಪರೀಕ್ಷೆಯ ಹೆಸರು ಕಾಣೆಯಾಗಿದೆ.';

  @override
  String get uiMissingCapturedLabRange =>
      'ಈ ಪರೀಕ್ಷೆಗಾಗಿ ಯಾವುದೇ ಲ್ಯಾಬ್ ಉಲ್ಲೇಖ ಶ್ರೇಣಿಯನ್ನು ಸೆರೆಹಿಡಿಯಲಾಗಿಲ್ಲ.';

  @override
  String get uiNonNumericExtractedValue =>
      'ಹೊರತೆಗೆಯಲಾದ ಮೌಲ್ಯವು ಸರಳ ಸಂಖ್ಯೆಯಲ್ಲ. ಮೂಲ ವರದಿಯಲ್ಲಿ ಅದನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiLabFlagRangeConflict =>
      'ಲ್ಯಾಬ್ ಫ್ಲ್ಯಾಗ್ ಮುದ್ರಿತ ಶ್ರೇಣಿಯೊಂದಿಗೆ ಸಂಘರ್ಷಿಸುತ್ತದೆ. ಮೂಲ ವರದಿಯನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'ಹೊರತೆಗೆಯಲಾದ ಮೌಲ್ಯ, ಮುದ್ರಿತ ಶ್ರೇಣಿ ಅಥವಾ ಲ್ಯಾಬ್ ಫ್ಲ್ಯಾಗ್ ಅನ್ನು ಮೂಲ ವರದಿಯಲ್ಲಿ ಪರಿಶೀಲಿಸುವ ಅಗತ್ಯವಿದೆ.';

  @override
  String get uiInitialEntitlement => 'ಆರಂಭಿಕ ಅರ್ಹತೆ';

  @override
  String get uiCreditPackPurchase => 'ಕ್ರೆಡಿಟ್ ಪ್ಯಾಕ್ ಖರೀದಿ';

  @override
  String get uiSubscriptionUpgrade => 'ಚಂದಾದಾರಿಕೆ ಅಪ್‌ಗ್ರೇಡ್';

  @override
  String get uiPlanDowngrade => 'ಡೌನ್‌ಗ್ರೇಡ್ ಯೋಜನೆ';

  @override
  String get uiAdminAdjustment => 'ನಿರ್ವಹಣೆ ಹೊಂದಾಣಿಕೆ';

  @override
  String get uiSystemReconciliation => 'ಸಿಸ್ಟಮ್ ಸಮನ್ವಯ';

  @override
  String get uiReferralInviteBonus => 'ರೆಫರಲ್ ಆಹ್ವಾನ ಬೋನಸ್';

  @override
  String get uiReferralAnalysisMilestone => 'ಉಲ್ಲೇಖಿತ ವಿಶ್ಲೇಷಣೆಯ ಮೈಲಿಗಲ್ಲು';

  @override
  String get uiReferralPurchaseMilestone => 'ಉಲ್ಲೇಖಿತ ಖರೀದಿಯ ಮೈಲಿಗಲ್ಲು';

  @override
  String get uiFreePromoCreditPack => 'ಉಚಿತ ಪ್ರೋಮೋ ಕ್ರೆಡಿಟ್ ಪ್ಯಾಕ್';

  @override
  String get uiGiftVoucherRedeemed => 'ಗಿಫ್ಟ್ ವೋಚರ್ ಅನ್ನು ರಿಡೀಮ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get uiNotYetChanged => 'ಇನ್ನೂ ಬದಲಾಗಿಲ್ಲ';

  @override
  String get uiCannotReachServer =>
      'ಸರ್ವರ್ ಅನ್ನು ತಲುಪಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಹಾಗೂ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiInvalidEmailOrPassword =>
      'ಅಮಾನ್ಯ ಇಮೇಲ್ ಅಥವಾ ಪಾಸ್‌ವರ್ಡ್. ನಿಮ್ಮ ವಿವರಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಹಾಗೂ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiTooManyAuthAttempts =>
      'ಹಲವಾರು ಪ್ರಯತ್ನಗಳು. ಕೆಲವು ನಿಮಿಷ ನಿರೀಕ್ಷಿಸಿ ಮತ್ತು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiEnterValidEmail => 'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get uiPasswordRequirements =>
      'ಪಾಸ್ವರ್ಡ್ ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳಾಗಿರಬೇಕು ಮತ್ತು ದೊಡ್ಡಕ್ಷರ, ಸಣ್ಣಕ್ಷರ, ಸಂಖ್ಯೆ ಮತ್ತು ವಿಶೇಷ ಅಕ್ಷರವನ್ನು ಒಳಗೊಂಡಿರಬೇಕು.';

  @override
  String get uiAccountWithEmailExists =>
      'ಈ ಇಮೇಲ್‌ನೊಂದಿಗೆ ಖಾತೆಯು ಈಗಾಗಲೇ ಅಸ್ತಿತ್ವದಲ್ಲಿದೆ. ಸೈನ್ ಇನ್ ಮಾಡಿ ಅಥವಾ ಬೇರೆ ಇಮೇಲ್ ಬಳಸಿ.';

  @override
  String get uiUploadedStatus => 'ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String uiSupportAction(String action) {
    return 'ಕ್ರಿಯೆ: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'ಪರಸ್ಪರ ಸಂಬಂಧ ID: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'ಕ್ಲೈಂಟ್ ಕ್ರಿಯೆಯ ID: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'ದೋಷ ಕೋಡ್: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'ದೋಷ: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'ನಿಮ್ಮ ಸೆಷನ್ ಕೊನೆಗೊಂಡಿದೆ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get uiProfileLimitReached =>
      'ನಿಮ್ಮ ಯೋಜನೆಯ ಪ್ರೊಫೈಲ್ ಮಿತಿಯನ್ನು ತಲುಪಲಾಗಿದೆ. ಇನ್ನಷ್ಟು ಸೇರಿಸಲು ಯೋಜನೆ ಮತ್ತು ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get uiCorrectionConflictReload =>
      'ಈ ಫಲಿತಾಂಶ ಬೇರೆಡೆ ಬದಲಾಗಿದೆ. ವರದಿಯನ್ನು ಸರಿಪಡಿಸುವ ಮೊದಲು ಅದನ್ನು ಮರುಲೋಡ್ ಮಾಡಿ.';

  @override
  String get uiSeePlanCreditsOptions =>
      'ಲಭ್ಯವಿರುವ ಆಯ್ಕೆಗಳಿಗಾಗಿ ಯೋಜನೆ ಮತ್ತು ಕ್ರೆಡಿಟ್‌ಗಳನ್ನು ನೋಡಿ.';

  @override
  String get uiShareLinkLimitHelp =>
      'ನೀವು ಸಕ್ರಿಯ ಹಂಚಿಕೆ-ಲಿಂಕ್ ಮಿತಿಯನ್ನು ತಲುಪಿರುವಿರಿ.';

  @override
  String get uiScopedExportUnavailable =>
      'ಸ್ಕೋಪ್ಡ್ ರಫ್ತು ಲಭ್ಯವಿಲ್ಲ. ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiRestorationUnavailable =>
      'ಮರುಸ್ಥಾಪನೆ ಲಭ್ಯವಿಲ್ಲ. ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get uiExportRequestNotFound =>
      'ರಫ್ತು ವಿನಂತಿ ಕಂಡುಬಂದಿಲ್ಲ. ಹೊಸ ರಫ್ತಿಗೆ ವಿನಂತಿಸಿ.';

  @override
  String get uiClosureConfirmationRequired =>
      'ಮುಂದುವರಿಸಲು ಖಾತೆಯ ಮುಚ್ಚುವಿಕೆಯನ್ನು ದೃಢೀಕರಿಸಿ.';

  @override
  String get uiCurrentPasswordIncorrect => 'ಪ್ರಸ್ತುತ ಪಾಸ್‌ವರ್ಡ್ ತಪ್ಪಾಗಿದೆ.';

  @override
  String get uiLaboratories => 'ಪ್ರಯೋಗಾಲಯಗಳು';

  @override
  String get uiUnlock => 'ಅನ್ಲಾಕ್ ಮಾಡಿ';
}
