// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get trendLatestResult => 'சமீபத்திய முடிவு';

  @override
  String get trendPreviousResult => 'முந்தைய முடிவு';

  @override
  String get trendSourceUnit => 'இந்த வரம்பின் அசல் அலகு';

  @override
  String get trendNoSavedResults =>
      'இந்தப் பரிசோதனைக்குச் சேமிக்கப்பட்ட முடிவுகள் இன்னும் இல்லை.';

  @override
  String get trendNoPlottableResults =>
      'மாதிரி எடுத்த தேதியுடன் துல்லியமான எண் முடிவுகளை வரைபடத்தில் காட்ட முடியாது.';

  @override
  String get trendOneResultHelp =>
      'ஒரு முடிவு சேமிக்கப்பட்டுள்ளது. மாற்றத்தைக் காண மற்றொரு அறிக்கையைச் சேர்க்கவும்.';

  @override
  String get trendMultipleResultsHelp =>
      'தேதிகள் கடந்த கால அளவுக்கேற்ப காட்டப்படுகின்றன. மதிப்பைக் காண புள்ளியைத் தட்டவும்.';

  @override
  String trendUnplottedNote(int count) {
    return 'மாதிரி எடுத்த தேதி அல்லது துல்லியமான எண் மதிப்பு இல்லாததால் $count முடிவுகளை வரைபடத்தில் காட்ட முடியவில்லை.';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$count முடிவுகளுடன் $testName மாற்ற வரைபடம்';
  }

  @override
  String get trendDateReview =>
      'மாதிரி எடுத்த தேதி முந்தைய தரவு பிரித்தெடுப்பிலிருந்து வந்தது. அசல் அறிக்கையில் சரிபார்க்கவும்.';

  @override
  String get trendNotPlotted => 'வரைபடத்தில் காட்டப்படவில்லை';

  @override
  String get trendExactNumberUnavailable => 'முடிவு துல்லியமான எண் அல்ல';

  @override
  String get preferredLanguage => 'விருப்ப மொழி';

  @override
  String get descriptionLanguage => 'விளக்க மொழி';

  @override
  String get languageHelp =>
      'செயலியின் இடைமுகச் சொற்களுக்கும் அறிக்கை விளக்கங்களுக்கும் பயன்படுத்தப்படும். விளக்கத்தின் மொழியை எப்போது வேண்டுமானாலும் மாற்றலாம்.';

  @override
  String get languageSaveFailed =>
      'உங்கள் மொழியைச் சேமிக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get translationLoading => 'மொழிபெயர்க்கப்பட்ட விளக்கம் தயாராகிறது…';

  @override
  String get translationFailed =>
      'மொழிபெயர்ப்பு கிடைக்கவில்லை. மீண்டும் முயலவும் அல்லது ஆங்கிலத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get translationNote =>
      'சேமிக்கப்பட்ட ஆங்கில விளக்கத்திலிருந்து AI மூலம் மொழிபெயர்க்கப்பட்டது. துல்லியமான முடிவுகளுக்கு அசல் அறிக்கையைச் சரிபார்க்கவும்.';

  @override
  String get sourceChanged =>
      'அறிக்கை மாறியுள்ளது. சமீபத்திய விளக்கத்தைப் பார்க்க அதை மீண்டும் ஏற்றவும்.';

  @override
  String get signupTitle => 'தெளிவான புரிதல்\nஇங்கே தொடங்குகிறது.';

  @override
  String get signupIntro =>
      'உங்கள் அறிக்கைகளையும் முடிவுகளையும் ஒன்றாக வைத்திருக்கக் கணக்கை உருவாக்கவும்.';

  @override
  String get loginIntro =>
      'உங்கள் உடல்நல அறிக்கைகளை அணுகவும் புரிந்துகொள்ளவும் உள்நுழையவும்.';

  @override
  String get emailAddress => 'மின்னஞ்சல் முகவரி';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get referralCode => 'பரிந்துரைக் குறியீடு (விருப்பத்திற்குரியது)';

  @override
  String get createAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get alreadyAccount => 'ஏற்கெனவே கணக்கு உள்ளதா? ';

  @override
  String get noAccount => 'கணக்கு இல்லையா? ';

  @override
  String get signIn => 'உள்நுழையவும்';

  @override
  String get showPassword => 'கடவுச்சொல்லைக் காட்டவும்';

  @override
  String get hidePassword => 'கடவுச்சொல்லை மறைக்கவும்';

  @override
  String get needHelp => 'உதவி தேவையா?';

  @override
  String get forgotPassword => 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?';

  @override
  String get invalidCredentialsInput =>
      'செல்லுபடியாகும் மின்னஞ்சல் முகவரியையும் கடவுச்சொல்லையும் உள்ளிடவும்';

  @override
  String get signupFailed => 'கணக்கை உருவாக்க முடியவில்லை';

  @override
  String get loginFailed =>
      'உள்நுழைய முடியவில்லை. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get genericError => 'ஏதோ தவறு ஏற்பட்டது. மீண்டும் முயலவும்.';

  @override
  String get profileUpdated => 'சுயவிவரம் புதுப்பிக்கப்பட்டது';

  @override
  String get changePhoto => 'சுயவிவரப் புகைப்படத்தை மாற்றவும்';

  @override
  String get gallery => 'படத்தொகுப்பிலிருந்து தேர்ந்தெடுக்கவும்';

  @override
  String get camera => 'புகைப்படம் எடுக்கவும்';

  @override
  String get photoUpdated => 'சுயவிவரப் புகைப்படம் புதுப்பிக்கப்பட்டது';

  @override
  String get photoFailed =>
      'உங்கள் புகைப்படத்தைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get yourAccount => 'உங்கள் கணக்கு';

  @override
  String get profileLoading => 'சுயவிவரம் ஏற்றப்படுகிறது…';

  @override
  String get profileLoadAction => 'உங்கள் சுயவிவரத்தை ஏற்றத் தட்டவும்';

  @override
  String get accountData => 'கணக்கும் தரவும்';

  @override
  String get personalInformation => 'தனிப்பட்ட தகவல்கள்';

  @override
  String get notificationPreferences => 'அறிவிப்பு விருப்பங்கள்';

  @override
  String get privacySecurity => 'தனியுரிமையும் பாதுகாப்பும்';

  @override
  String get sharedLinks => 'பகிரப்பட்ட இணைப்புகள்';

  @override
  String get exportData => 'உங்கள் தரவை ஏற்றுமதி செய்யவும்';

  @override
  String get additionalAccount => 'கூடுதல் கணக்குத் தகவல்கள்';

  @override
  String get additionalAccountHelp =>
      'குடும்பம், திட்டம், பரிந்துரைகள், அமர்வுகள் மற்றும் தோற்றம்';

  @override
  String get familyProfiles => 'குடும்பச் சுயவிவரங்கள்';

  @override
  String get manageProfiles => 'சுயவிவரங்களை மாற்றவும் அல்லது நிர்வகிக்கவும்';

  @override
  String get planCredits => 'திட்டமும் கிரெடிட்களும்';

  @override
  String get viewPlanBalance => 'உங்கள் திட்டத்தையும் இருப்பையும் பார்க்கவும்';

  @override
  String get balanceLoading => 'இருப்பு ஏற்றப்படுகிறது…';

  @override
  String get referFriends => 'நண்பர்களைப் பரிந்துரைக்கவும்';

  @override
  String get referralRewards => 'அழைப்புகளும் பரிந்துரை வெகுமதிகளும்';

  @override
  String get activeSessions => 'செயலில் உள்ள அமர்வுகள்';

  @override
  String get appearance => 'தோற்றம்';

  @override
  String get system => 'சாதன அமைப்பின்படி';

  @override
  String get light => 'வெளிர்';

  @override
  String get dark => 'அடர்';

  @override
  String get helpSupport => 'உதவியும் ஆதரவும்';

  @override
  String get aboutDoclyzer => 'Doclyzer பற்றி';

  @override
  String get aboutCopy =>
      'அறிக்கைகளை நபர்வாரியாக ஒழுங்குபடுத்தி, பிரித்தெடுக்கப்பட்ட முடிவுகளை அசல் அறிக்கையுடன் ஒப்பிட்டுச் சரிபார்க்கவும்.';

  @override
  String get logOut => 'வெளியேறவும்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get saveChanges => 'மாற்றங்களைச் சேமிக்கவும்';

  @override
  String get accountRestricted => 'கணக்கு கட்டுப்படுத்தப்பட்டுள்ளது';

  @override
  String get photoUploading => 'புகைப்படம் பதிவேற்றப்படுகிறது…';

  @override
  String get changePhotoShort => 'புகைப்படத்தை மாற்றவும்';

  @override
  String get accountDetails => 'கணக்கு விவரங்கள்';

  @override
  String get emailHelp =>
      'கணக்கை அணுகப் பயன்படுத்தப்படுகிறது. இதை மாற்ற ஆதரவுக் குழுவைத் தொடர்புகொள்ளவும்.';

  @override
  String get accountName => 'கணக்குப் பெயர்';

  @override
  String get belowLabRange => 'இந்த ஆய்வகத்தின் ஒப்பீட்டு வரம்பிற்குக் கீழே';

  @override
  String get withinLabRange => 'இந்த ஆய்வகத்தின் ஒப்பீட்டு வரம்பிற்குள்';

  @override
  String get aboveLabRange => 'இந்த ஆய்வகத்தின் ஒப்பீட்டு வரம்பிற்கு மேலே';

  @override
  String get cannotCompare => 'ஆய்வக வரம்புடன் ஒப்பிட முடியவில்லை';

  @override
  String get understandResult => 'இந்த முடிவைப் புரிந்துகொள்ளவும்';

  @override
  String get yourResult => 'உங்கள் முடிவு';

  @override
  String get labReferenceRange => 'ஆய்வக ஒப்பீட்டு வரம்பு';

  @override
  String get resultUnavailable => 'இந்த முடிவில் கிடைக்கவில்லை';

  @override
  String get sampleDate => 'மாதிரி எடுத்த தேதி';

  @override
  String get resultHistory => 'முடிவு வரலாறு';

  @override
  String get originalReport => 'அசல் அறிக்கை';

  @override
  String get reviewValue => 'மதிப்பைச் சரிபார்க்கவும்';

  @override
  String get understandYourResult => 'உங்கள் முடிவைப் புரிந்துகொள்ளவும்';

  @override
  String get educationalContext =>
      'இந்த முடிவைப் பற்றிக் கலந்துரையாட உதவும் கல்விசார் பின்னணித் தகவல்கள்.';

  @override
  String get explanationUnavailable => 'விளக்கம் கிடைக்கவில்லை';

  @override
  String get explanationFailed => 'இப்போது விளக்கத்தை ஏற்ற முடியவில்லை.';

  @override
  String get checkOriginal => 'அசல் அறிக்கையைச் சரிபார்க்கவும்';

  @override
  String get tryAgain => 'மீண்டும் முயலவும்';

  @override
  String get aiGuidance => 'AI உருவாக்கிய வழிகாட்டுதல்';

  @override
  String get understandingResult => 'இந்த முடிவைப் புரிந்துகொள்ளுதல்';

  @override
  String get possibleMeaning => 'இது எதைக் குறிக்கக்கூடும்';

  @override
  String get whatTestMeasures => 'இந்தப் பரிசோதனை எதை அளவிடுகிறது';

  @override
  String get suggestedNextStep => 'பரிந்துரைக்கப்படும் அடுத்த படி';

  @override
  String get resultLimitations =>
      'இந்த முடிவால் உங்களுக்குத் தெரிவிக்க முடியாதவை';

  @override
  String get oneResultLimit =>
      'ஒரே ஒரு முடிவை மட்டும் வைத்து நோய்நிலையைக் கண்டறியவோ அறிகுறிகளை விளக்கவோ முடியாது.';

  @override
  String get detailsToCheck => 'சரிபார்க்க வேண்டிய விவரங்கள்';

  @override
  String get lifestyleFactors => 'கலந்துரையாட வேண்டிய வாழ்க்கைமுறைக் காரணிகள்';

  @override
  String get insightContext =>
      'இந்த மதிப்பு உங்கள் அறிக்கையிலிருந்து பிரித்தெடுக்கப்பட்டது. பெயர், மதிப்பு, அலகு அல்லது வரம்பு தவறாகத் தோன்றினால் அசல் அறிக்கையைச் சரிபார்க்கவும். AI விளக்கங்கள் கல்வி நோக்கத்திற்கானவை; உங்களுக்கு எந்தச் சிகிச்சை தேவை என்பதை அவற்றால் கூற முடியாது.';

  @override
  String get yourProfile => 'உங்கள் சுயவிவரம்';

  @override
  String get cancel => 'ரத்துசெய்யவும்';

  @override
  String get delete => 'நீக்கவும்';

  @override
  String get moveReport => 'அறிக்கையை நகர்த்தவும்';

  @override
  String get gotIt => 'புரிந்தது';

  @override
  String get reportDetails => 'அறிக்கை விவரங்கள்';

  @override
  String get shareReport => 'அறிக்கையைப் பகிரவும்';

  @override
  String get moreReportActions => 'அறிக்கைக்கான கூடுதல் செயல்கள்';

  @override
  String get attemptHistory => 'முயற்சி வரலாறு';

  @override
  String get compareReports => 'அறிக்கைகளை ஒப்பிடவும்';

  @override
  String get readParsedReport => 'பிரித்தெடுக்கப்பட்ட அறிக்கையைப் படிக்கவும்';

  @override
  String get moveRecycle => 'மீட்புத் தொட்டிக்கு நகர்த்தவும்';

  @override
  String get retry => 'மீண்டும் முயலவும்';

  @override
  String get reportSummary => 'அறிக்கைச் சுருக்கம்';

  @override
  String get updateSummary => 'சுருக்கத்தைப் புதுப்பிக்கவும்';

  @override
  String get summaryLoading =>
      'உங்கள் முடிவுகள் எளிய மொழியில் விளக்கப்படுகின்றன…';

  @override
  String get checkSummary => 'சுருக்கத்தைச் சரிபார்க்கவும்';

  @override
  String get summaryFailed =>
      'சுருக்கத்தை உருவாக்க முடியவில்லை. நீங்கள் மீண்டும் முயலலாம்.';

  @override
  String get summaryPlaceholder =>
      'முக்கிய முடிவுகளின் எளிய மொழி விளக்கம் இங்கே தோன்றும்.';

  @override
  String get retrySummary => 'சுருக்கத்தை மீண்டும் உருவாக்க முயலவும்';

  @override
  String get generateSummary => 'சுருக்கத்தை உருவாக்கவும்';

  @override
  String get loadingResults => 'அறிக்கை முடிவுகள் ஏற்றப்படுகின்றன…';

  @override
  String get somethingWrong => 'ஏதோ தவறு ஏற்பட்டது';

  @override
  String get viewTrends => 'காலப்போக்கிலான மாற்றங்களைப் பார்க்கவும்';

  @override
  String get originalFile => 'அசல் கோப்பு';

  @override
  String get testValues => 'பரிசோதனை மதிப்புகள்';

  @override
  String get summary => 'சுருக்கம்';

  @override
  String get checkStatus => 'நிலையைச் சரிபார்க்கவும்';

  @override
  String get viewOriginal => 'அசலைப் பார்க்கவும்';

  @override
  String get verifiedResults => 'சரிபார்க்கப்பட்ட முடிவுகள்';

  @override
  String get resultTapHelp =>
      'பரிசோதனை எதை அளவிடுகிறது என்பதைப் புரிந்துகொள்ள ஒரு முடிவைத் தட்டவும்.';

  @override
  String get reviewResults => 'கண்டறியப்பட்ட முடிவுகளைச் சரிபார்க்கவும்';

  @override
  String get keepFile => 'இருப்பினும் கோப்பை வைத்திருக்கவும்';

  @override
  String get patientDetails => 'நோயாளி விவரங்கள்';

  @override
  String get name => 'பெயர்';

  @override
  String get age => 'வயது';

  @override
  String get gender => 'பாலினம்';

  @override
  String get bookingId => 'முன்பதிவு ID';

  @override
  String get sampleCollection => 'மாதிரி சேகரிப்பு';

  @override
  String get labDetails => 'ஆய்வக விவரங்கள்';

  @override
  String get labName => 'ஆய்வகப் பெயர்';

  @override
  String get address => 'முகவரி';

  @override
  String get phone => 'தொலைபேசி';

  @override
  String get location => 'இடம்';

  @override
  String get belowRange => 'வரம்பிற்குக் கீழே';

  @override
  String get aboveRange => 'வரம்பிற்கு மேலே';

  @override
  String get withinRange => 'குறிப்பிட்ட வரம்பிற்குள்';

  @override
  String get rangeUnclear => 'வரம்பு தெளிவாக இல்லை';

  @override
  String get understandResultAction => 'இந்த முடிவைப் புரிந்துகொள்ளவும்  →';

  @override
  String get parsedReport => 'பிரித்தெடுக்கப்பட்ட அறிக்கை';

  @override
  String get reports => 'அறிக்கைகள்';

  @override
  String get trends => 'காலப்போக்கிலான மாற்றங்கள்';

  @override
  String get openingPage => 'தொடக்கப் பக்கம்';

  @override
  String get home => 'முகப்பு';

  @override
  String get family => 'குடும்பம்';

  @override
  String get switchProfile => 'சுயவிவரத்தை மாற்றவும்';

  @override
  String get currentProfile => 'தற்போதைய சுயவிவரம்';

  @override
  String get viewProfile => 'இந்தச் சுயவிவரத்தைப் பார்க்கவும்';

  @override
  String get manageFamily => 'குடும்பத்தை நிர்வகிக்கவும்';

  @override
  String get chooseProfile => 'ஒரு சுயவிவரத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get homeTitle => 'இன்னும் கொஞ்சம் தெளிவு.\nஅனைத்தும் ஒரே இடத்தில்.';

  @override
  String get nextReportTitle =>
      'உங்கள் அடுத்த அறிக்கை,\nநீங்கள் தயாராகும்போது அதுவும் தயார்.';

  @override
  String get homeSubtitle =>
      'PDFகள், புகைப்படங்கள் மற்றும் குடும்பப் பதிவுகள்.';

  @override
  String get uploadReport => 'அறிக்கையைப் பதிவேற்றவும்';

  @override
  String get recentReport => 'அண்மைய அறிக்கை';

  @override
  String get viewAll => 'அனைத்தையும் பார்க்கவும்';

  @override
  String get reportsUnavailable =>
      'அறிக்கைகள் கிடைக்கவில்லை. இணைப்பு கிடைக்கும்போது மீண்டும் முயலவும்.';

  @override
  String get emptyHomeTitle => 'உங்கள் கதை இங்கே தொடங்குகிறது';

  @override
  String get emptyHomeHelp =>
      'உங்கள் பதிவுகளின் தெளிவான வரலாற்றைத் தொடங்க முதல் அறிக்கையைப் பதிவேற்றவும்.';

  @override
  String get uploadFirstReport => 'உங்கள் முதல் அறிக்கையைப் பதிவேற்றவும்';

  @override
  String get latestResults => 'சமீபத்திய முடிவுகள்';

  @override
  String get allTrends => 'காலப்போக்கிலான அனைத்து மாற்றங்களும்';

  @override
  String get reviewedResultsHelp =>
      'சரிபார்க்கப்பட்ட முடிவுகள் கிடைக்கும்போது இங்கே தோன்றும்.';

  @override
  String get searchTests => 'பரிசோதனைகளைத் தேடவும்';

  @override
  String get noHealthData =>
      'இன்னும் உடல்நலத் தரவு இல்லை. உங்கள் உடல்நல வரலாற்றைப் பார்க்க ஓர் அறிக்கையைப் பதிவேற்றவும்.';

  @override
  String get noTestsFound => 'பரிசோதனைகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get shorterTestName =>
      'சுருக்கமான பரிசோதனைப் பெயரைப் பயன்படுத்தி முயலவும்.';

  @override
  String get clearSearch => 'தேடலை அழிக்கவும்';

  @override
  String get unitUnavailable => 'அலகு கிடைக்கவில்லை';

  @override
  String get uploadingReport => 'அறிக்கை பதிவேற்றப்படுகிறது…';

  @override
  String get organizingReport => 'உங்கள் அறிக்கை ஒழுங்குபடுத்தப்படுகிறது…';

  @override
  String get uploadAReport => 'ஓர் அறிக்கையைப் பதிவேற்றவும்';

  @override
  String get uploadHelp =>
      'ஒரு PDF அல்லது தெளிவான புகைப்படத்தைத் தேர்ந்தெடுக்கவும். சேமிப்பதற்கு முன் விவரங்களைச் சரிபார்க்கலாம்.';

  @override
  String get chooseSource => 'மூலத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get uploadPdfImage => 'PDF அல்லது படத்தைப் பதிவேற்றவும்';

  @override
  String get chooseReportFiles =>
      'உங்கள் கோப்புகளிலிருந்து ஓர் அறிக்கையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectReportPages =>
      'ஒன்று அல்லது அதற்கு மேற்பட்ட அறிக்கைப் பக்கங்களைத் தேர்ந்தெடுக்கவும்';

  @override
  String get capturePage => 'முழுப் பக்கத்தையும் படமெடுக்கவும்';

  @override
  String get supportedFormats => 'ஆதரிக்கப்படும் வடிவங்கள்: PDF, JPG, PNG';

  @override
  String get confirmFile =>
      'நீங்கள் சேர்க்க விரும்பும் கோப்பு இதுதானா என்பதை உறுதிசெய்யவும்.';

  @override
  String get addReport => 'அறிக்கையைச் சேர்க்கவும்';

  @override
  String get chooseDifferentFile => 'வேறு கோப்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get uploadWait =>
      'இதற்குச் சிறிது நேரம் ஆகலாம். செயலியைத் திறந்தே வைத்திருக்கவும்.';

  @override
  String get reportNeedsAttention => 'அறிக்கையில் கவனிக்க வேண்டியவை உள்ளன';

  @override
  String get verifyBeforeSaving =>
      'கண்டறியப்பட்ட முடிவுகளைச் சேமிப்பதற்கு முன் அசல் அறிக்கையுடன் ஒப்பிட்டுச் சரிபார்க்கவும்.';

  @override
  String get viewVerifiedResults => 'சரிபார்க்கப்பட்ட முடிவுகளைப் பார்க்கவும்';

  @override
  String get viewOriginalReport => 'அசல் அறிக்கையைப் பார்க்கவும்';

  @override
  String get viewReportStatus => 'அறிக்கையின் நிலையைப் பார்க்கவும்';

  @override
  String get viewResults => 'முடிவுகளைப் பார்க்கவும்';

  @override
  String get viewOriginalFile => 'அசல் கோப்பைப் பார்க்கவும்';

  @override
  String get retryExtraction => 'மீண்டும் பிரித்தெடுக்க முயலவும்';

  @override
  String get done => 'முடிந்தது';

  @override
  String get duplicateReport =>
      'இந்த அறிக்கை ஏற்கெனவே இருப்பதன் நகல் போல் தெரிகிறது';

  @override
  String get duplicateHelp =>
      'இந்தக் கோப்பு உங்கள் அறிக்கைகளில் ஏற்கெனவே இருக்கலாம்.';

  @override
  String get keepExisting => 'ஏற்கெனவே உள்ளதை வைத்திருக்கவும்';

  @override
  String get processAgain => 'PDFஐ மீண்டும் செயலாக்கவும்';

  @override
  String get uploadNewCopy => 'புதிய நகலாகப் பதிவேற்றவும்';

  @override
  String get reportLimitReached => 'அறிக்கை வரம்பை எட்டிவிட்டீர்கள்';

  @override
  String get reportLimitHelp => 'உங்கள் அறிக்கை வரம்பை எட்டிவிட்டீர்கள்.';

  @override
  String get upgrade => 'மேம்படுத்தவும்';

  @override
  String get back => 'பின்செல்லவும்';

  @override
  String get uploadFailedTitle => 'அறிக்கையைப் பதிவேற்ற முடியவில்லை';

  @override
  String get uploadFailed => 'பதிவேற்றம் தோல்வியடைந்தது';

  @override
  String get retrySameFile => 'அதே கோப்புடன் மீண்டும் முயலவும்';

  @override
  String get chooseAnotherFile => 'மற்றொரு கோப்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get aiDisclaimer =>
      'உங்கள் உடல்நல அறிக்கைகளை ஒழுங்குபடுத்தவும் நன்றாகப் புரிந்துகொள்ளவும் Doclyzer உதவுகிறது. வழங்கப்படும் தகவல்கள் கல்வி நோக்கத்திற்காக மட்டுமே; இவை மருத்துவ ஆலோசனையோ, நோய் கண்டறிதலோ, சிகிச்சையோ அல்ல. மருத்துவ வழிகாட்டுதலுக்கு எப்போதும் தகுதிவாய்ந்த சுகாதார நிபுணரை அணுகவும்.';

  @override
  String collectedOn(String date) {
    return 'சேகரிக்கப்பட்டது $date';
  }

  @override
  String uploadedOn(String date) {
    return 'பதிவேற்றப்பட்டது $date';
  }

  @override
  String labRangeValue(String range) {
    return 'ஆய்வக வரம்பு $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits கிரெடிட்கள்';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அறிக்கைகள்',
      one: '1 அறிக்கை',
      zero: 'அறிக்கைகள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'அறிக்கையை ஏற்ற எதிர்பார்த்ததைவிட அதிக நேரம் ஆகிறது. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get summaryUpdateFailed =>
      'இப்போது சுருக்கத்தைப் புதுப்பிக்க முடியவில்லை. சேமிக்கப்பட்ட சுருக்கம் இன்னும் கிடைக்கிறது.';

  @override
  String get summaryCreateFailed =>
      'இப்போது சுருக்கத்தை உருவாக்க முடியவில்லை. உங்கள் முடிவுகள் கீழே தொடர்ந்து கிடைக்கின்றன.';

  @override
  String get reassignFailed =>
      'அறிக்கையை வேறொரு சுயவிவரத்திற்கு மாற்ற முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get confirmRecycle => 'மீட்புத் தொட்டிக்கு நகர்த்தவா?';

  @override
  String get recycleHelp =>
      'அறிக்கைகள் > மீட்புத் தொட்டி என்பதிலிருந்து இந்த அறிக்கையை 30 நாட்களுக்குள் மீட்டெடுக்கலாம். அதன் பிறகு, இது நிரந்தரமாக நீக்கப்படும்.';

  @override
  String get reportRecycled => 'அறிக்கை மீட்புத் தொட்டிக்கு நகர்த்தப்பட்டது';

  @override
  String get reportDeleteFailed =>
      'அறிக்கையை நீக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get addProfileBeforeMove =>
      'இந்த அறிக்கையை நகர்த்துவதற்கு முன் மற்றொரு குடும்பச் சுயவிவரத்தைச் சேர்க்கவும்.';

  @override
  String get moveReportHelp =>
      'இந்த அறிக்கை தவறான சுயவிவரத்தில் சேர்க்கப்பட்டிருந்தால் மற்றொரு குடும்ப உறுப்பினரைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get confirmMoveReport => 'இந்த அறிக்கையை நகர்த்தவா?';

  @override
  String get aboutSampleDates => 'மாதிரி எடுத்த தேதிகள் பற்றி';

  @override
  String get multipleDatesHelp =>
      'இந்த அறிக்கையில் ஒன்றுக்கும் மேற்பட்ட தேதிகளில் எடுக்கப்பட்ட மாதிரிகளின் முடிவுகள் உள்ளன. ஒரு முடிவைத் திறந்து, அதன் தேதியை அசல் அறிக்கையுடன் ஒப்பிட்டுச் சரிபார்க்கவும்.';

  @override
  String get missingDateHelp =>
      'மாதிரி எடுத்த தேதி என்பது மாதிரி எடுக்கப்பட்ட நாளாகும். இந்த அறிக்கையில் நம்பகமான தேதியைக் கண்டறிய முடியவில்லை. மாதிரி எடுத்த தேதியும் பதிவேற்றிய தேதியும் வேறுபட்டவை. ஒரு முடிவைத் திறந்து, அதன் தேதியைச் சரிபார்க்கவும் அல்லது திருத்தவும்.';

  @override
  String get uploading => 'பதிவேற்றப்படுகிறது';

  @override
  String get waitingToProcess => 'செயலாக்கத்திற்காகக் காத்திருக்கிறது';

  @override
  String get readingReport => 'அறிக்கை படிக்கப்படுகிறது';

  @override
  String get readyToReview => 'சரிபார்க்கத் தயார்';

  @override
  String get someResultsNeedReview => 'சில முடிவுகளைச் சரிபார்க்க வேண்டும்';

  @override
  String get couldNotReadReport => 'அறிக்கையைப் படிக்க முடியவில்லை';

  @override
  String get processingStopped => 'செயலாக்கம் நின்றுவிட்டது';

  @override
  String get couldNotProcessReport => 'அறிக்கையைச் செயலாக்க முடியவில்லை';

  @override
  String get reportRefreshFailed =>
      'இந்த அறிக்கையைப் புதுப்பிக்க முடியவில்லை. கடைசியாக ஏற்றப்பட்ட முடிவு காட்டப்படுகிறது.';

  @override
  String get multipleSampleDates => 'மாதிரி எடுத்த பல தேதிகள் ';

  @override
  String get missingSampleDate => 'மாதிரி எடுத்த தேதி கிடைக்கவில்லை ';

  @override
  String get reportAnalyzing =>
      'இந்த அறிக்கையை ஆய்வு செய்கிறோம். நீங்கள் இந்தத் திரையிலிருந்து வெளியேறலாம்; முடிவுகள் தயாரானதும் தோன்றும்.';

  @override
  String get extractionIncompleteTitle =>
      'எல்லா முடிவுகளையும் நம்பகமாகப் பிரித்தெடுக்க முடியவில்லை';

  @override
  String get extractionIncompleteHelp =>
      'தானியங்கிப் பிரித்தெடுத்தல் முழுமையடையவில்லை. கண்டறியப்பட்ட வரிசைகளைச் சேமிப்பதற்கு முன் அசல் அறிக்கையுடன் ஒப்பிட்டுச் சரிபார்க்கவும்.';

  @override
  String get verifiedRowsHelp =>
      'இந்த வரிசைகள் அசல் அறிக்கையுடன் ஒப்பிட்டுச் சரிபார்க்கப்பட்டன. மற்ற வரிசைகளை இன்னும் சரிபார்க்க வேண்டியிருக்கலாம்.';

  @override
  String get noTestValues =>
      'இந்த அறிக்கையில் பரிசோதனை மதிப்புகள் எதுவும் கண்டறியப்படவில்லை. அதன் உள்ளடக்கத்தைச் சரிபார்க்க அசல் கோப்பைத் திறக்கவும்.';

  @override
  String get processingRetryHelp =>
      'செயலாக்கம் முடிவடைவதற்கு முன்பே நின்றுவிட்டது. உங்கள் கோப்பு சேமிக்கப்பட்டுள்ளது. மீண்டும் முயல, ‘மீண்டும் முயலவும்’ என்பதைத் தட்டவும்.';

  @override
  String get resultsNeedCheck =>
      'சில முடிவுகளை அசல் அறிக்கையுடன் ஒப்பிட்டுச் சரிபார்க்க வேண்டும். கீழே கண்டறியப்பட்ட வரிசைகளை நீங்கள் சரிபார்க்கலாம்.';

  @override
  String get readerModeHelp =>
      'எளிதாக அணுகவும் தெளிவாகப் படிக்கவும் பிரித்தெடுக்கப்பட்ட அறிக்கை வாசிப்பு முறையில் கிடைக்கிறது.';

  @override
  String get aiRangeHelp =>
      'செயலாக்கத்தின்போது AI வரம்பைப் பொருள்படுத்தியுள்ளது. அசல் அறிக்கையைச் சரிபார்க்கவும்.';

  @override
  String get checkResultHelp =>
      'இந்த முடிவை நம்பிப் பயன்படுத்துவதற்கு முன் அசல் அறிக்கையுடன் ஒப்பிட்டுச் சரிபார்க்கவும்.';

  @override
  String get preferredRangeHelp =>
      'ஆய்வகம் அச்சிட்டுள்ள விரும்பத்தக்க பிரிவுடன் ஒப்பிடப்பட்டுள்ளது; அந்தப் பிரிவு உங்களுக்குப் பொருந்துகிறதா என்பதை உறுதிசெய்யவும்.';

  @override
  String get categoryComparisonHelp =>
      'இந்த ஒப்பீடு ஆய்வகம் அச்சிட்டுள்ள விரும்பத்தக்க பிரிவைப் பயன்படுத்துகிறது. அந்தப் பிரிவு உங்களுக்குப் பொருந்துகிறதா என்பதைச் சரிபார்க்கவும்.';

  @override
  String get missingSavedResult =>
      'இந்த மதிப்பைச் சேமிக்கப்பட்ட முடிவுடன் பொருத்த முடியவில்லை. அசல் அறிக்கையைச் சரிபார்க்கவும் அல்லது இந்த அறிக்கையைப் புதுப்பிக்கவும்.';

  @override
  String get unreviewedTest =>
      'AI விளக்கங்களை வழங்குவதற்காக இந்தப் பரிசோதனை இன்னும் மதிப்பாய்வு செய்யப்படவில்லை. அசல் அறிக்கையைச் சரிபார்த்து, முடிவைப் பற்றி உங்கள் மருத்துவருடன் கலந்துரையாடவும்.';

  @override
  String get unsafeResult =>
      'பிரித்தெடுக்கப்பட்ட முடிவு தெளிவாக இல்லாததால், அதைப் பாதுகாப்பாக விளக்க முடியாது. அசல் அறிக்கையைச் சரிபார்க்கவும்.';

  @override
  String get filterReports => 'அறிக்கைகளை வடிகட்டவும்';

  @override
  String get sortReports => 'அறிக்கைகளை வரிசைப்படுத்தவும்';

  @override
  String get recycleBin => 'மீட்புத் தொட்டி';

  @override
  String get healthHistory => 'உடல்நல வரலாறு';

  @override
  String get shareProfile => 'சுயவிவரத்தைப் பகிரவும்';

  @override
  String get reportsUnavailableTitle => 'அறிக்கைகள் கிடைக்கவில்லை';

  @override
  String get reportsLoadFailed =>
      'அறிக்கைகளை ஏற்ற முடியவில்லை. இணைப்பு கிடைக்கும்போது மீண்டும் முயலவும்.';

  @override
  String get upload => 'பதிவேற்றவும்';

  @override
  String get reportsFor => 'இவருக்கான அறிக்கைகள்';

  @override
  String get searchReports => 'அறிக்கைகள் அல்லது ஆய்வகங்களைத் தேடவும்';

  @override
  String get filters => 'வடிகட்டிகள்';

  @override
  String get noReportsYet => 'இன்னும் அறிக்கைகள் இல்லை';

  @override
  String get noMatchingReports =>
      'உங்கள் தேடலுக்குப் பொருந்தும் அறிக்கைகள் இல்லை.';

  @override
  String get differentSearch =>
      'வேறு பரிசோதனை, ஆய்வகம் அல்லது வடிகட்டியைப் பயன்படுத்தி முயலவும்.';

  @override
  String get clearFilters => 'தேடலையும் வடிகட்டிகளையும் அழிக்கவும்';

  @override
  String get original => 'அசல்';

  @override
  String get switchActiveProfile => 'செயலில் உள்ள சுயவிவரத்தை மாற்றவும்';

  @override
  String get switchProfileHelp =>
      'மற்றொரு நபரின் அறிக்கைகளைப் பார்க்கவும். பதிவேற்றங்களுக்கும் காலப்போக்கிலான மாற்றங்களுக்கும் பயன்படுத்தப்படும் செயலில் உள்ள சுயவிவரமும் மாறும்.';

  @override
  String get multipleCollectionDates => 'மாதிரி சேகரித்த பல தேதிகள்';

  @override
  String get unknownCollectionDate => 'மாதிரி சேகரித்த தேதி தெரியவில்லை';

  @override
  String get profileLoadFailed =>
      'சுயவிவரங்களை ஏற்ற முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get pleaseTryAgain => 'மீண்டும் முயலவும்.';

  @override
  String get deleteProfileConfirm => 'சுயவிவரத்தை நீக்கவா?';

  @override
  String get deleteProfileHelp =>
      'இந்தச் சுயவிவரம் அகற்றப்படும். இதனுடன் இணைக்கப்பட்டுள்ள தரவுகள் பாதிக்கப்படும்.';

  @override
  String get profileDeleteFailed =>
      'சுயவிவரத்தை நீக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get addFamilyMember => 'குடும்ப உறுப்பினரைச் சேர்க்கவும்';

  @override
  String get familyUnavailable => 'குடும்பச் சுயவிவரங்கள் கிடைக்கவில்லை';

  @override
  String get familyIntro =>
      'நபர்வாரியாக ஒழுங்குபடுத்தப்பட்ட அறிக்கைகளும் காலப்போக்கிலான மாற்றங்களும்';

  @override
  String get noProfilesYet => 'இன்னும் சுயவிவரங்கள் இல்லை';

  @override
  String get noProfilesHelp =>
      'உங்களுக்கோ குடும்ப உறுப்பினர்களுக்கோ அறிக்கைகளை ஒழுங்குபடுத்த ஒரு சுயவிவரத்தைச் சேர்க்கவும்.';

  @override
  String get yourFamily => 'உங்கள் குடும்பம்';

  @override
  String get upgradeProfiles => 'மேலும் சுயவிவரங்களைச் சேர்க்க மேம்படுத்தவும்';

  @override
  String get editProfile => 'சுயவிவரத்தைத் திருத்தவும்';

  @override
  String get deleteProfile => 'சுயவிவரத்தை நீக்கவும்';

  @override
  String get active => 'செயலில் உள்ளது';

  @override
  String get setActive => 'செயலில் உள்ளதாக அமைக்கவும்';

  @override
  String get viewReports => 'அறிக்கைகளைப் பார்க்கவும்';

  @override
  String get notNow => 'இப்போது வேண்டாம்';

  @override
  String get openSettings => 'அமைப்புகளைத் திறக்கவும்';

  @override
  String get enableNotifications => 'அறிவிப்புகளை இயக்கவும்';

  @override
  String get enableNotificationsConfirm => 'அறிவிப்புகளை இயக்கவா?';

  @override
  String get notificationsEnabled => 'அறிக்கை அறிவிப்புகள் இயக்கப்பட்டன';

  @override
  String get notificationsStayOff =>
      'அறிவிப்புகள் தொடர்ந்து முடக்கப்பட்டுள்ளன. பிறகு சாதன அமைப்புகளில் அவற்றை இயக்கலாம்.';

  @override
  String get notificationsFailed =>
      'அறிவிப்புகளை இயக்க முடியவில்லை. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get switchProfileFailed =>
      'சுயவிவரங்களை மாற்ற முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get sourceReportFailed => 'மூல அறிக்கையைத் திறக்க முடியவில்லை.';

  @override
  String get partialRefreshFailed =>
      'சில தகவல்களைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயலக் கீழே இழுக்கவும்.';

  @override
  String get knowReportReady => 'உங்கள் அறிக்கை தயாரானதும் அறிந்துகொள்ளுங்கள்';

  @override
  String get oneResult => 'ஒரு முடிவு';

  @override
  String get sameDayResults => 'ஒரே நாளின் முடிவுகள்';

  @override
  String get verificationRequired => 'சரிபார்ப்பு தேவை';

  @override
  String get accountCreatedLogin =>
      'உங்கள் கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது. உள்நுழையத் தொடரவும்.';

  @override
  String get continueLogin => 'உள்நுழையத் தொடரவும்';

  @override
  String get allReports => 'அனைத்து அறிக்கைகள்';

  @override
  String get filterReviewed => 'சரிபார்க்கப்பட்டது';

  @override
  String get filterNeedsReview => 'சரிபார்க்க வேண்டும்';

  @override
  String get filterProcessing => 'செயலாக்கப்படுகிறது';

  @override
  String get filterOriginalOnly => 'அசல் மட்டும்';

  @override
  String get reportDateNewest => 'அறிக்கைத் தேதி · புதியவை முதலில்';

  @override
  String get reportDateOldest => 'அறிக்கைத் தேதி · பழையவை முதலில்';

  @override
  String get uploadDateNewest => 'பதிவேற்றிய தேதி · புதியவை முதலில்';

  @override
  String get uploadDateOldest => 'பதிவேற்றிய தேதி · பழையவை முதலில்';

  @override
  String get switchAction => 'மாற்றவும்';

  @override
  String get collectionDate => 'மாதிரி சேகரித்த தேதி';

  @override
  String get copy => 'நகலெடுக்கவும்';

  @override
  String get history => 'வரலாறு';

  @override
  String get loadingReport => 'அறிக்கை ஏற்றப்படுகிறது…';

  @override
  String get restore => 'மீட்டெடுக்கவும்';

  @override
  String get revoke => 'ரத்துசெய்யவும்';

  @override
  String get testName => 'பரிசோதனைப் பெயர்';

  @override
  String get viewReport => 'அறிக்கையைப் பார்க்கவும்';

  @override
  String get closeAccount => 'கணக்கை மூடவும்';

  @override
  String get createShareLink => 'பகிர்வு இணைப்பை உருவாக்கவும்';

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'தோற்றம் மாறியது, ஆனால் அடுத்த முறை சேமிக்க முடியவில்லை.';

  @override
  String get uiThisReportIsNoLongerAvailable => 'இந்த அறிக்கை இனி கிடைக்காது.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'அறிவிப்பு மாதிரிக்காட்சிகளை நிர்வகிக்க சாதன அமைப்புகளைத் திறக்கவும்.';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'பதிவேற்றம் ஏற்றுக்கொள்ளப்படும் வரை இந்தத் திரையைத் திறந்து வைக்கவும்.';

  @override
  String get uiAnUploadMayHaveBeenInterrupted => 'பதிவேற்றம் தடைபட்டிருக்கலாம்';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'அறிக்கைகளை சரிபார்க்கவும். அது விடுபட்டால், அதே கோப்பை மீண்டும் சேர்க்கவும்.';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'அறிவிப்புகளை நிராகரிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiConnectionUnavailable => 'இணைப்பு கிடைக்கவில்லை';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'உங்கள் அமர்வைச் சரிபார்க்க முடியவில்லை. இணையத்துடன் இணைத்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiSignInWithAnotherAccount => 'மற்றொரு கணக்கில் உள்நுழையவும்';

  @override
  String get uiNoActiveProfile => 'செயலில் சுயவிவரம் இல்லை';

  @override
  String get uiDismissUploadNotice => 'பதிவேற்ற அறிவிப்பை நிராகரி';

  @override
  String get uiDismissReadyNotifications => 'தயார் அறிவிப்புகளை நிராகரி';

  @override
  String get uiRequestSupport => 'ஆதரவைக் கோருங்கள்';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'கண்டறியும் ஐடிகளைச் சேர்ப்போம், அதனால் குழு விசாரிக்க முடியும்.';

  @override
  String get uiSendRequest => 'கோரிக்கையை அனுப்பவும்';

  @override
  String get uiWhatHappenedOptional => 'என்ன நடந்தது? (விரும்பினால்)';

  @override
  String get uiReviewResult => 'மதிப்பாய்வு முடிவை';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'சேமிப்பதற்கு முன் இந்தப் புலங்களை அசல் அறிக்கையுடன் ஒப்பிடவும்.';

  @override
  String get uiOriginallyExtracted => 'முதலில் பிரித்தெடுக்கப்பட்டது';

  @override
  String get uiReloadReport => 'அறிக்கையை மீண்டும் ஏற்றவும்';

  @override
  String get uiResultAsPrinted => 'அச்சிடப்பட்ட முடிவு';

  @override
  String get uiUnitIfShown => 'அலகு (காட்டப்பட்டால்)';

  @override
  String get uiLabReferenceRangeIfShown =>
      'ஆய்வக குறிப்பு வரம்பு (காட்டப்பட்டால்)';

  @override
  String get uiCheckYourReport => 'உங்கள் அறிக்கையைச் சரிபார்க்கவும்';

  @override
  String get uiNoAttemptHistoryAvailable => 'முயற்சி வரலாறு இல்லை.';

  @override
  String get uiIInspectedTheOriginal => 'அசலை ஆய்வு செய்தேன்';

  @override
  String get uiChooseTwoReports => 'இரண்டு அறிக்கைகளைத் தேர்ந்தெடுக்கவும்';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'ஒரே நபருக்கான பதிவுகளைப் பயன்படுத்தவும். பொருந்தும் சோதனைகள் அருகருகே தோன்றும்.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'முதலில் பழைய அறிக்கையையும் இரண்டாவது புதிய அறிக்கையையும் தேர்ந்தெடுக்கவும்.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'இணக்கமாக இருக்கும்போது மட்டுமே ஒப்பிடப்படுகிறது. இணக்கத்தன்மை உறுதிப்படுத்தப்படும் வரை வெவ்வேறு அலகுகள் அல்லது முறைகள் தனித்தனியாகக் காட்டப்படும்.';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'மாற்றம் என்பது நோயறிதல் அல்ல. ஒவ்வொரு முடிவையும் அதன் சொந்த அறிக்கை இடைவெளியுடன் ஒப்பிட்டு உங்கள் மருத்துவரிடம் சூழலைப் பற்றி விவாதிக்கவும்.';

  @override
  String get uiChooseDifferentReports =>
      'வெவ்வேறு அறிக்கைகளைத் தேர்ந்தெடுக்கவும்';

  @override
  String get uiEarlierReport => 'முந்தைய அறிக்கை';

  @override
  String get uiLaterReport => 'பின்னர் அறிக்கை';

  @override
  String get uiYourReportPages => 'உங்கள் அறிக்கை பக்கங்கள்';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'அறிக்கையின் அதே வரிசையில் பக்கங்களை வைக்கவும்.';

  @override
  String get uiAddAnotherPage => 'மற்றொரு பக்கத்தைச் சேர்க்கவும்';

  @override
  String get uiChoosePagesFromGallery =>
      'கேலரியில் இருந்து பக்கங்களைத் தேர்ந்தெடுக்கவும்';

  @override
  String get uiAdjustPage => 'பக்கத்தை சரிசெய்யவும்';

  @override
  String get uiRetake => 'மீண்டும் எடுக்கவும்';

  @override
  String get uiUseAdjustedPage => 'சரிசெய்யப்பட்ட பக்கத்தைப் பயன்படுத்தவும்';

  @override
  String get uiResetChanges => 'மாற்றங்களை மீட்டமைக்கவும்';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'ஒவ்வொரு முடிவையும் மூலைகளுக்குள் வைத்திருங்கள்.';

  @override
  String get uiRotate => 'சுழற்று';

  @override
  String get uiReportRestored => 'அறிக்கை மீட்டெடுக்கப்பட்டது';

  @override
  String get uiDeleteReportPermanently => 'அறிக்கையை நிரந்தரமாக நீக்கவா?';

  @override
  String get uiDeletePermanently => 'நிரந்தரமாக நீக்கு';

  @override
  String get uiReportPermanentlyDeleted => 'அறிக்கை நிரந்தரமாக நீக்கப்பட்டது';

  @override
  String get uiEmptyRecycleBin => 'மறுசுழற்சி தொட்டி காலியா?';

  @override
  String get uiDeleteAll => 'அனைத்தையும் நீக்கு';

  @override
  String get uiRecycleBinIsEmpty => 'மறுசுழற்சி தொட்டி காலியாக உள்ளது.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'நீக்கப்பட்ட அறிக்கைகள் அகற்றப்படுவதற்கு முன் இங்கே தோன்றும்.';

  @override
  String get uiEmptyRecycleBind657e2 => 'காலி மறுசுழற்சி தொட்டி';

  @override
  String get uiCheckDetectedResult => 'கண்டறியப்பட்ட முடிவைச் சரிபார்க்கவும்';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'இந்த வரிசையை அசல் அறிக்கையுடன் ஒப்பிடுக. சேமிக்கும் முன் OCR தவறுகளை சரிசெய்யவும்.';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'இந்த முடிவை அசல் அறிக்கைக்கு எதிராகச் சரிபார்த்தேன்';

  @override
  String get uiSaving => 'சேமிக்கிறது…';

  @override
  String get uiSaveVerifiedResult => 'சரிபார்க்கப்பட்ட முடிவைச் சேமிக்கவும்';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'முடிவுகள் எதுவும் கண்டறியப்படவில்லை. அசல் அறிக்கையைப் பார்க்கவும் அல்லது செயலாக்கத்தை மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'கண்டறியப்பட்ட மதிப்புகள் சேமிக்கப்பட்ட முடிவுகளாக மாறுவதற்கு முன், அசல் அறிக்கைக்கு எதிராகச் சரிபார்க்கப்பட வேண்டும்.';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'சில வரிசைகள் விடுபட்டிருக்கலாம். முழு அசல் அறிக்கையையும் சரிபார்க்கவும்.';

  @override
  String get uiResult => 'முடிவு';

  @override
  String get uiUnitOptional => 'அலகு (விரும்பினால்)';

  @override
  String get uiReferenceRangeOptional => 'குறிப்பு வரம்பு (விரும்பினால்)';

  @override
  String get uiVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get uiGiftVoucher => 'பரிசு வவுச்சர்';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'கிஃப்ட் வவுச்சரை ரிடீம் செய்து உங்கள் இருப்புக்கு நேரடியாக கிரெடிட்களைச் சேர்க்கவும்.';

  @override
  String get uiCurrentPlan => 'தற்போதைய திட்டம்';

  @override
  String get uiCreditBalance => 'கடன் இருப்பு';

  @override
  String get uiPlanLimits => 'திட்ட வரம்புகள்';

  @override
  String get uiBuyCredits => 'கடன் வாங்கவும்';

  @override
  String get uiRecentBillingActivity => 'சமீபத்திய பில்லிங் செயல்பாடு';

  @override
  String get uiRefreshStatus => 'நிலையை புதுப்பிக்கவும்';

  @override
  String get uiNoRecentOrdersYet => 'இன்னும் சமீபத்திய ஆர்டர்கள் இல்லை.';

  @override
  String get uiVoucherCode => 'வவுச்சர் குறியீடு';

  @override
  String get uiCheckout => 'வெளியேறு';

  @override
  String get uiApply => 'விண்ணப்பிக்கவும்';

  @override
  String get uiClear => 'தெளிவு';

  @override
  String get uiPay => 'செலுத்து';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'இந்த நேரத்தில் கிரெடிட் பேக்குகள் எதுவும் இல்லை.';

  @override
  String get uiBuy => 'வாங்க';

  @override
  String get uiRetryPayment => 'மீண்டும் பணம் செலுத்த முயற்சிக்கவும்';

  @override
  String get uiPromoCode => 'விளம்பர குறியீடு';

  @override
  String get uiEnterPromoCode => 'விளம்பரக் குறியீட்டை உள்ளிடவும்';

  @override
  String get uiChooseAPlan => 'ஒரு திட்டத்தை தேர்வு செய்யவும்';

  @override
  String get uiNoPlansAvailableAtThisTime =>
      'இந்த நேரத்தில் திட்டங்கள் எதுவும் இல்லை.';

  @override
  String get uiHaveAPromoCode => 'விளம்பரக் குறியீடு உள்ளதா?';

  @override
  String get uiCURRENTPLAN => 'தற்போதைய திட்டம்';

  @override
  String get uiManageNotifications => 'அறிவிப்புகளை நிர்வகிக்கவும்';

  @override
  String get uiAll => 'அனைத்து';

  @override
  String get uiUnread => 'படிக்காதது';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'அணுகல் உடனடியாக நிறுத்தப்படும். நீங்கள் உள்நுழைந்து 30 நாட்களுக்குள் மீட்டெடுக்கலாம். அதன் பிறகு, உங்கள் கணக்கு மற்றும் சேமிக்கப்பட்ட கோப்புகள் செயலில் உள்ள சேமிப்பகத்திலிருந்து நீக்கப்படும்.';

  @override
  String get uiCloseMyAccount => 'எனது கணக்கை மூடு';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'உங்கள் பதிவுகள் Doclyzer இல் இருக்கும்.';

  @override
  String get uiTakeACopyOfYourRecords =>
      'உங்கள் பதிவுகளின் நகலை எடுத்துக் கொள்ளுங்கள்.';

  @override
  String get uiWhoseRecords => 'யாருடைய பதிவுகள்?';

  @override
  String get uiCouldNotLoadProfiles => 'சுயவிவரங்களை ஏற்ற முடியவில்லை';

  @override
  String get uiLoadingProfiles => 'சுயவிவரங்களை ஏற்றுகிறது…';

  @override
  String get uiAllProfiles => 'அனைத்து சுயவிவரங்கள்';

  @override
  String get uiDateRange => 'தேதி வரம்பு';

  @override
  String get uiUseAllDates => 'அனைத்து தேதிகளையும் பயன்படுத்தவும்';

  @override
  String get uiINCLUDEINTHISEXPORT => 'இந்த ஏற்றுமதியில் சேர்க்கவும்';

  @override
  String get uiOriginalReports => 'அசல் அறிக்கைகள்';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'நீங்கள் பதிவேற்றிய PDFகள் மற்றும் படங்கள்';

  @override
  String get uiTestResults => 'சோதனை முடிவுகள்';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'CSV ஆக முடிவுகள், அவற்றின் மதிப்பாய்வு நிலை';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'ஏற்றுமதியில் தனிப்பட்ட தகவல்கள் உள்ளன. நீங்கள் நம்பும் இடத்தில் அவற்றை சேமிக்கவும்.';

  @override
  String get uiDeleteAccount => 'கணக்கை நீக்கு';

  @override
  String get uiContinueToDeletion => 'நீக்குவதைத் தொடரவும்';

  @override
  String get uiKeepMyAccount => 'எனது கணக்கை வைத்திருங்கள்';

  @override
  String get uiBeforeYouLeave => 'நீங்கள் கிளம்பும் முன்';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'இது எதை நீக்கும் என்பதைப் படியுங்கள்.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'உங்கள் கணக்கை நீக்குவது நீங்கள் நிர்வகிக்கும் அனைத்து சுயவிவரங்களையும் பாதிக்கும்.';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'உங்கள் கணக்கு மற்றும் தனிப்பட்ட சுயவிவரம்';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'உங்கள் பகிரப்பட்ட இணைப்புகள் மூலம் அணுகவும்';

  @override
  String get uiKeepACopyFirst => 'முதலில் ஒரு பிரதியை வைத்துக் கொள்ளுங்கள்';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'நீங்கள் வைத்திருக்க விரும்பும் தகவலை ஏற்றுமதி செய்யவும்.';

  @override
  String get uiExportData => 'தரவு ஏற்றுமதி';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'அணுகல் உடனடியாக நிறுத்தப்படும். நீங்கள் 30 நாட்களுக்குள் மீட்டெடுக்கலாம். அதன் பிறகு, செயலில் உள்ள சேமிப்பகத்திலிருந்து உங்கள் தரவு அகற்றப்படும்.';

  @override
  String get uiAccountPendingDeletion => 'கணக்கு நீக்கம் நிலுவையில் உள்ளது';

  @override
  String get uiRestoreMyAccount => 'எனது கணக்கை மீட்டெடுக்கவும்';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'உங்கள் சுயவிவரம், சுயவிவரங்கள் மற்றும் ஒப்புதல் பதிவுகள் உட்பட உங்கள் கணக்குத் தரவின் நகலைப் பதிவிறக்கவும்.';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'உங்கள் கணக்கு உடனடியாக முடக்கப்பட்டுள்ளது. நீங்கள் அதை 30 நாட்களுக்குள் மீட்டெடுக்கலாம். அதன் பிறகு, உங்கள் தரவு நிரந்தரமாக நீக்கப்படும்.';

  @override
  String get uiCurrentPassword => 'தற்போதைய கடவுச்சொல்';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'ஆப்ஸ் பூட்டை மாற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'உங்கள் பதிவுகள்.\nபகிர்வதற்கான உங்கள் விருப்பம்.';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'உங்களுக்குத் தேவைப்படும்போது அணுகலை மதிப்பாய்வு செய்யவும்.';

  @override
  String get uiAppLock => 'பயன்பாட்டு பூட்டு';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'உங்கள் சாதனத்தின் பயோமெட்ரிக் அல்லது கடவுக்குறியீடு பூட்டைப் பயன்படுத்தவும்.';

  @override
  String get uiNotificationPreviews => 'அறிவிப்பு முன்னோட்டங்கள்';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'உங்கள் சாதன அமைப்புகளில் பூட்டு-திரை மாதிரிக்காட்சிகளைக் கட்டுப்படுத்தவும்.';

  @override
  String get uiContactSupport => 'ஆதரவைத் தொடர்பு கொள்ளவும்';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'நீங்கள் தேர்வு செய்தால் மட்டுமே அறிக்கைகளை இணைக்கவும்.';

  @override
  String get uiWhatCanWeHelpYouWith => 'நாங்கள் உங்களுக்கு என்ன உதவ முடியும்?';

  @override
  String get uiPOPULARQUESTIONS => 'பிரபலமான கேள்விகள்';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'உங்கள் தேடலுடன் எந்த உதவிக் கட்டுரைகளும் பொருந்தவில்லை.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'உங்கள் உடல்நலம் அல்லது சோதனை முடிவுகள் பற்றிய கேள்விகளுக்கு, தகுதியான சுகாதார நிபுணரிடம் பேசவும்.';

  @override
  String get uiYourReportsAClearerPicture =>
      'உங்கள் அறிக்கைகள். ஒரு தெளிவான படம்.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'உங்கள் சுகாதார வரலாற்றை ஒன்றாக வைத்திருங்கள்.';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'அறிக்கைகளைச் சேமிக்கவும், முடிவுகளை மதிப்பாய்வு செய்யவும், மாற்றங்களைப் பின்பற்றவும் மற்றும் உங்கள் மருத்துவரிடம் பகிரவும்.';

  @override
  String get uiEducationalInformationOnly => 'கல்வி தகவல் மட்டுமே';

  @override
  String get uiSearchHelpArticles => 'உதவிக் கட்டுரைகளைத் தேடுங்கள்';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'அறிவிப்பு அணுகலை மாற்ற, சாதன அமைப்புகள் பயன்பாட்டைத் திறக்கவும்.';

  @override
  String get uiSavePreferences => 'விருப்பங்களைச் சேமிக்கவும்';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'சாதன அனுமதிகளை அமைப்புகளில் மாற்றலாம்.';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'இந்தச் சாதனத்தில் அறிக்கை அறிவிப்புகளைப் பெறவும்';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'அறிக்கை எப்போது தயாராக உள்ளது என்பதை அறிய அறிவிப்புகளை அனுமதிக்கவும். மார்க்கெட்டிங் என்பது கீழே ஒரு தனி தேர்வு.';

  @override
  String get uiREPORTACTIVITY => 'நடவடிக்கை அறிக்கை';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'அறிக்கை செயல்பாட்டு அமைப்புகளுக்கு சமீபத்திய சர்வர் பதிப்பு தேவை.';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'உணர்திறன் பூட்டு-திரை மாதிரிக்காட்சிகள்';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'அறிக்கையின் பெயர்கள் மற்றும் தனிப்பட்ட விவரங்கள் எப்போதும் மறைக்கப்படும்.';

  @override
  String get uiOTHERMESSAGES => 'மற்ற செய்திகள்';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'ஒவ்வொரு நபரின் அறிக்கைகளையும் போக்குகளையும் ஒன்றாக வைத்திருங்கள்.';

  @override
  String get uiPersonDetails => 'நபர் விவரங்கள்';

  @override
  String get uiDateOfBirth => 'பிறந்த தேதி';

  @override
  String get uiRelationship => 'உறவு';

  @override
  String get uiEnterAName => 'ஒரு பெயரை உள்ளிடவும்';

  @override
  String get uiClearDateOfBirth => 'தெளிவான பிறந்த தேதி';

  @override
  String get uiOptionalEGParentOrChild =>
      'விருப்பமானது, எ.கா. பெற்றோர் அல்லது குழந்தை';

  @override
  String get uiInviteFriendsEarnCredits =>
      'நண்பர்களை அழைக்கவும், வரவுகளை சம்பாதிக்கவும்';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'உங்கள் குறியீட்டைப் பகிரவும் மற்றும் ரிவார்டு அன்லாக் ஆக ஒவ்வொரு அழைப்பையும் பின்பற்றவும்.';

  @override
  String get uiYOURREFERRALCODE => 'உங்கள் பரிந்துரை குறியீடு';

  @override
  String get uiShareInvite => 'அழைப்பைப் பகிரவும்';

  @override
  String get uiCopyCode => 'குறியீட்டை நகலெடுக்கவும்';

  @override
  String get uiHaveACode => 'குறியீடு உள்ளதா?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'உங்கள் அழைப்பு வெகுமதியைப் பெற உங்களுடன் பகிரப்பட்ட குறியீட்டை உள்ளிடவும்.';

  @override
  String get uiHowRewardsWork => 'வெகுமதிகள் எவ்வாறு வேலை செய்கின்றன';

  @override
  String get uiNoFriendsReferredYet =>
      'இதுவரை நண்பர்கள் யாரும் குறிப்பிடப்படவில்லை';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'அவர்களின் முன்னேற்றத்தைக் காண உங்கள் அழைப்பை இங்கே பகிரவும்.';

  @override
  String get uiReferralCode => 'பரிந்துரை குறியீடு';

  @override
  String get uiSetNewPassword => 'புதிய கடவுச்சொல்லை அமைக்கவும்';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'உங்கள் மின்னஞ்சலில் உள்ள இணைப்பிலிருந்து மீட்டமைக்கப்பட்ட டோக்கனையும் உங்கள் புதிய கடவுச்சொல்லையும் உள்ளிடவும்.';

  @override
  String get uiResetPassword => 'கடவுச்சொல்லை மீட்டமைக்கவும்';

  @override
  String get uiBackToLogin => 'உள்நுழைவுக்குத் திரும்பு';

  @override
  String get uiResetToken => 'டோக்கனை மீட்டமைக்கவும்';

  @override
  String get uiNewPassword => 'புதிய கடவுச்சொல்';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'உங்கள் கணக்குடன் தொடர்புடைய மின்னஞ்சல் முகவரியை உள்ளிடவும், உங்கள் கடவுச்சொல்லை மீட்டமைப்பதற்கான இணைப்பை நாங்கள் உங்களுக்கு அனுப்புவோம்.';

  @override
  String get uiSendResetLink => 'மீட்டமை இணைப்பை அனுப்பவும்';

  @override
  String get uiRevokeSession => 'அமர்வை ரத்து செய்யவா?';

  @override
  String get uiCurrentSession => 'தற்போதைய அமர்வு';

  @override
  String get uiSkip => 'தவிர்க்கவும்';

  @override
  String get uiChangePassword => 'கடவுச்சொல்லை மாற்றவும்';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிட்டு புதிய ஒன்றைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get uiNewPasswordd850ee => 'புதிய கடவுச்சொல்';

  @override
  String get uiConfirmNewPassword => 'புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get uiGettingThingsReady => 'பொருட்களை தயார் செய்கிறது…';

  @override
  String get uiLinkAccessHistory => 'இணைப்பு அணுகல் வரலாறு';

  @override
  String get uiNoAccessEventsYet => 'இதுவரை அணுகல் நிகழ்வுகள் இல்லை.';

  @override
  String get uiDefaultShareLinkExpiry =>
      'இயல்புநிலை பகிர்வு இணைப்பு காலாவதியாகும்';

  @override
  String get uiSave => 'சேமிக்கவும்';

  @override
  String get uiReviewSharing => 'மதிப்பாய்வு பகிர்வு';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'நபர், அறிக்கைகள் மற்றும் அணுகலைச் சரிபார்க்கவும்.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'தேர்வு அல்லது அணுகல் அமைப்புகளைத் திருத்தவும்';

  @override
  String get uiRevokeShareLink => 'பகிர்வு இணைப்பை திரும்பப் பெறவா?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'இந்த இணைப்பு வேலை செய்வதை நிறுத்தும். நீங்கள் புதிய ஒன்றை உருவாக்கலாம்.';

  @override
  String get uiShareLinkReady => 'பகிர்வு இணைப்பு தயாராக உள்ளது';

  @override
  String get uiAccessCodeShareSeparately =>
      'அணுகல் குறியீடு - தனித்தனியாகப் பகிரவும்';

  @override
  String get uiCopyAccessCode => 'அணுகல் குறியீட்டை நகலெடுக்கவும்';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'இந்தக் குறியீட்டைச் சாதனத்தில் சேமிக்க முடியவில்லை. பின்னர் பயன்படுத்த இப்போது அதை நகலெடுக்கவும்.';

  @override
  String get uiShareLink => 'இணைப்பைப் பகிரவும்';

  @override
  String get uiCopyLink => 'இணைப்பை நகலெடுக்கவும்';

  @override
  String get uiRevokeLink => 'இணைப்பை ரத்துசெய்';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'இந்தச் சாதனத்தில் குறியீடு இல்லை. சேமித்த குறியீட்டைப் பயன்படுத்தவும் அல்லது புதிய இணைப்பை உருவாக்கவும்.';

  @override
  String get uiActiveSharedLinks => 'செயலில் பகிரப்பட்ட இணைப்புகள்';

  @override
  String get uiShare => 'பகிரவும்';

  @override
  String get uiCreateANewShareLink => 'புதிய பகிர்வு இணைப்பை உருவாக்கவும்';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'இந்த சுயவிவரத்திற்கான தற்போதைய மற்றும் எதிர்கால அறிக்கைகளைச் சேர்க்கவும்.';

  @override
  String get uiChooseReports => 'அறிக்கைகளைத் தேர்ந்தெடுக்கவும்';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'கீழே தேர்ந்தெடுக்கப்பட்ட அறிக்கைகளை மட்டும் பகிரவும்.';

  @override
  String get uiSelectAll => 'அனைத்தையும் தேர்ந்தெடுக்கவும்';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'பகிர்ந்து கொள்ள மதிப்பாய்வு செய்யப்பட்ட அறிக்கைகள் எதுவும் இல்லை.';

  @override
  String get uiSelectedTestResults => 'தேர்ந்தெடுக்கப்பட்ட சோதனை முடிவுகள்';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'இந்த அறிக்கைகளிலிருந்து நீங்கள் தேர்ந்தெடுக்கும் முடிவுகளை மட்டும் சேர்க்கவும்.';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'இந்த அறிக்கைகளில் சேமிக்கப்பட்ட சோதனை முடிவுகள் எதுவும் இல்லை.';

  @override
  String get uiUpgradeOrManage => 'மேம்படுத்தவும் அல்லது நிர்வகிக்கவும்';

  @override
  String get uiExpiry => 'காலாவதி:';

  @override
  String get uiRequireAnAccessCode => 'அணுகல் குறியீடு தேவை';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'இணைப்பிலிருந்து தனித்தனியாக குறியீட்டைப் பகிரவும்.';

  @override
  String get uiTryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get uiClearExpiry => 'தெளிவான காலாவதி';

  @override
  String get onboardingStoreEyebrow => '01 / சேமிக்கவும்';

  @override
  String get onboardingStoreTitle => 'ஒவ்வொரு அறிக்கையும்,\nஒரு பழக்கமான இடம்.';

  @override
  String get onboardingStoreBody =>
      'உங்களுக்கும் நீங்கள் விரும்பும் நபர்களுக்கும் PDFகள் மற்றும் புகைப்படங்களை ஒன்றாக வைத்திருங்கள்.';

  @override
  String get onboardingUnderstandEyebrow => '02 / புரிந்து கொள்ளுங்கள்';

  @override
  String get onboardingUnderstandTitle => 'எண்கள்,\nபடிக்க எளிதாக்கியது.';

  @override
  String get onboardingUnderstandBody =>
      'உங்கள் அறிக்கையிலிருந்து ஒவ்வொரு சோதனையையும், அதன் அலகு மற்றும் இடைவெளியையும் பார்க்கவும். எந்த நேரத்திலும் அசல் சரிபார்க்கவும்.';

  @override
  String get onboardingTrackEyebrow => '03 / ட்ராக் & ஷேர்';

  @override
  String get onboardingTrackTitle =>
      'மாற்றங்களைப் பார்க்கவும்.\nசூழலைப் பகிரவும்.';

  @override
  String get onboardingTrackBody =>
      'காலப்போக்கில் முடிவுகளைப் பின்பற்றி, உங்கள் மருத்துவர் பார்க்கக்கூடியதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get onboardingNext => 'அடுத்து';

  @override
  String get onboardingGetStarted => 'தொடங்குங்கள்';

  @override
  String get uiSupportRequestSent => 'ஆதரவு கோரிக்கை அனுப்பப்பட்டது.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'சோதனையின் பெயர் மற்றும் முடிவு தேவை.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD வடிவத்தில் சரியான சேகரிப்பு தேதியைப் பயன்படுத்தவும்.';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'இந்தத் திருத்தத்தைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiReportsUnavailable => 'அறிக்கைகள் கிடைக்கவில்லை';

  @override
  String get uiTryAgain042c86 => 'மீண்டும் முயலவும்';

  @override
  String get uiTwoReportsAreNeeded => 'இரண்டு அறிக்கைகள் தேவை';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'முடிவுகளை ஒப்பிட, இந்த சுயவிவரத்திற்கு பழைய அறிக்கையைச் சேர்க்கவும்.';

  @override
  String get uiCannotCompareYet => 'இன்னும் ஒப்பிட முடியாது';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'இந்த அறிக்கைகளை ஒப்பிடுவதற்கு பொருத்தமான முடிவுகள் எதுவும் இல்லை.';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'அறிக்கைகளை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCouldNotOpenPhotosOrCamera =>
      'புகைப்படங்கள் அல்லது கேமராவைத் திறக்க முடியவில்லை.';

  @override
  String get uiCouldNotOpenCamera => 'கேமராவைத் திறக்க முடியவில்லை.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'இந்தப் பக்கங்களைத் தயாரிக்க முடியவில்லை. படிக்க முடியாத பக்கத்தை மீண்டும் எடுத்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCouldNotAdjustThisPage =>
      'இந்தப் பக்கத்தைச் சரிசெய்ய முடியவில்லை.';

  @override
  String get uiNoChartableResultYet => 'இன்னும் அட்டவணை முடிவு இல்லை';

  @override
  String get uiProfiles => 'சுயவிவரங்கள்';

  @override
  String get uiReports => 'அறிக்கைகள்';

  @override
  String get uiShareLinks => 'இணைப்புகளைப் பகிரவும்';

  @override
  String get uiAIChat => 'AI அரட்டை';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'உரிமைச் சுருக்கத்தை ஏற்றுவதில் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'பில்லிங் நிலையைப் புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'ரசீது பதிவிறக்கம் விரைவில் கிடைக்கும்.';

  @override
  String get uiSubtotal => 'துணைத்தொகை';

  @override
  String get uiDiscount => 'தள்ளுபடி';

  @override
  String get uiTotal => 'மொத்தம்';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'கிரெடிட் பேக்குகளை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'ஒரு பேமெண்ட் பிடிப்பு நிலுவையில் உள்ளது. மற்றொரு செக் அவுட்டைத் தொடங்கும் முன் நிலையைப் புதுப்பிக்கவும்.';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'கடன்கள் வெற்றிகரமாகப் பயன்படுத்தப்பட்டன.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ஆர்டரை உருவாக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'பணம் பெறப்பட்டது. கிரெடிட்கள் சேர்க்கப்படும் முன் சர்வர் சமரசத்திற்காக காத்திருக்கிறது.';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'பணம் செலுத்த முடியவில்லை. தயாரானதும் செக் அவுட்டை மீண்டும் முயற்சிக்கலாம்.';

  @override
  String get uiPaymentFailedTryAgain =>
      'பணம் செலுத்த முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCreditsAdded => 'கடன் சேர்க்கப்பட்டது!';

  @override
  String get uiPromoCodeApplied => 'விளம்பர குறியீடு பயன்படுத்தப்பட்டது.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'பணம் பெறப்பட்டது, ஆனால் இந்த ஆர்டர் மதிப்பாய்வு நிலுவையில் உள்ளது.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'சமரசத்தின் போது பணம் செலுத்த முடியவில்லை.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'கட்டணம் உறுதிப்படுத்தப்பட்டது. சர்வர் சமரசம் இன்னும் நிலுவையில் உள்ளது.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'கட்டணம் சரிபார்க்கப்பட்டது. சமரசம் நிலுவையில் உள்ளது, விரைவில் புதுப்பிக்கவும்.';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'பணம் பெறப்பட்டது, ஆனால் சரிபார்ப்பு இன்னும் நிலுவையில் உள்ளது. நிலையைப் புதுப்பிக்கவும்.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'திட்டங்களை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'சந்தாவை உருவாக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'சந்தா தோல்வியடைந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiPlanUpgraded => 'திட்டம் மேம்படுத்தப்பட்டது!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'பணம் பெறப்பட்டது, ஆனால் சரிபார்ப்பு தோல்வியடைந்தது. திட்டம் விரைவில் மேம்படுத்தப்படும்.';

  @override
  String get uiNotificationsUnavailable => 'அறிவிப்புகள் கிடைக்கவில்லை';

  @override
  String get uiAllQuietForNow => 'இப்போதைக்கு எல்லாம் அமைதி.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'புதுப்பிப்புகள் மற்றும் பகிர்தல் நினைவூட்டல்கள் புதியதாக இருக்கும் போது இங்கே தோன்றும்.';

  @override
  String get uiNoUnreadUpdates => 'படிக்காத புதுப்பிப்புகள் இல்லை';

  @override
  String get uiYouReAllCaughtUp => 'நீங்கள் அனைவரும் பிடித்துவிட்டீர்கள்.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'அறிவிப்புகளை ஏற்ற முடியவில்லை. இணைக்கப்பட்டதும் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiManageSharedLinks => 'பகிரப்பட்ட இணைப்புகளை நிர்வகிக்கவும்';

  @override
  String get uiExportYourData => 'உங்கள் தரவை ஏற்றுமதி செய்யவும்';

  @override
  String get uiReadThePrivacyPolicy => 'தனியுரிமைக் கொள்கையைப் படிக்கவும்';

  @override
  String get uiTermsOfUse => 'பயன்பாட்டு விதிமுறைகள்';

  @override
  String get uiPrivacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get uiDateOfBirthOptional => 'பிறந்த தேதி, விருப்பமானது';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'உறவில் 50 எழுத்துகள் அல்லது அதற்கும் குறைவாக இருக்க வேண்டும்.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'சுயவிவரத்தைச் சேமிப்பதில் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiReferralsUnavailable => 'பரிந்துரைகள் கிடைக்கவில்லை';

  @override
  String get uiYourRewards => 'உங்கள் வெகுமதிகள்';

  @override
  String get uiReferralProgress => 'பரிந்துரை முன்னேற்றம்';

  @override
  String get uiFriendsReferred => 'நண்பர்கள் குறிப்பிட்டனர்';

  @override
  String get uiCreditsEarned => 'சம்பாதித்த கடன்கள்';

  @override
  String get uiPendingRewards => 'நிலுவையில் உள்ள வெகுமதிகள்';

  @override
  String get uiBlockedRewards => 'தடுக்கப்பட்ட வெகுமதிகள்';

  @override
  String get uiInviteeBonus => 'அழைப்பாளர் போனஸ்';

  @override
  String get uiFirstAnalysis => 'முதல் பகுப்பாய்வு';

  @override
  String get uiFirstPurchase => 'முதல் கொள்முதல்';

  @override
  String get uiMonthlyCap => 'மாதாந்திர தொப்பி';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'பரிந்துரைகளை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiReferralCodeCopied => 'பரிந்துரை குறியீடு நகலெடுக்கப்பட்டது.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'உங்கள் மின்னஞ்சல் இணைப்பிலிருந்து மீட்டமைப்பு டோக்கனை உள்ளிடவும்';

  @override
  String get uiEnterYourNewPassword => 'உங்கள் புதிய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'கடவுச்சொல்லை மீட்டமைக்க முடியவில்லை. புதிய இணைப்பைக் கோரவும்.';

  @override
  String get uiEnterYourEmailAddress => 'உங்கள் மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'மீட்டமைப்பு இணைப்பை அனுப்ப முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiFailedToLoadSessions => 'அமர்வுகளை ஏற்றுவதில் தோல்வி.';

  @override
  String get uiFailedToRevokeSession => 'அமர்வை திரும்பப் பெற முடியவில்லை.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'கடவுச்சொல்லை மாற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'சாதன அமைப்புகளைத் திறந்து, Doclyzer க்கான அறிவிப்புகளை அனுமதிக்கவும்.';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'அறிக்கைகளை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'சோதனை முடிவுகளை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'பகிர குறைந்தபட்சம் ஒரு அறிக்கையைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'பகிர்வதற்கு குறைந்தபட்சம் ஒரு சோதனை முடிவைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get uiLinkCopiedToClipboard =>
      'இணைப்பு கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'அணுகல் குறியீடு கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது';

  @override
  String get uiOnePerson => '1 நபர்';

  @override
  String uiPeopleCount(String count) {
    return '$count மக்கள்';
  }

  @override
  String uiActionsFor(String name) {
    return '$name க்கான செயல்கள்';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'சுயவிவரங்களை மாற்ற முடியவில்லை. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name க்கு மாறியது';
  }

  @override
  String get uiAnalyzeOnePage => '1 பக்கத்தை பகுப்பாய்வு செய்யவும்';

  @override
  String uiAnalyzePages(String count) {
    return '$count பக்கங்களை பகுப்பாய்வு செய்யவும்';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'உங்கள் அறிக்கையில் காட்டப்பட்டுள்ள வரிசையில் பக்கங்களை இழுக்கவும்';

  @override
  String get uiCheckEveryPage =>
      'பகுப்பாய்வு செய்வதற்கு முன் ஒவ்வொரு பக்கத்தையும் சரிபார்க்கவும்';

  @override
  String get uiOnePageAdded => '1 பக்கம் சேர்க்கப்பட்டது';

  @override
  String uiPagesAdded(String count) {
    return '$count பக்கங்கள் சேர்க்கப்பட்டன';
  }

  @override
  String get uiReorder => 'மறுவரிசைப்படுத்து';

  @override
  String uiPageNumber(String number) {
    return 'பக்கம் $number';
  }

  @override
  String uiRemovePage(String number) {
    return 'பக்கத்தை அகற்று $number';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · பக்கம் $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'வெட்டு விளிம்புகள்: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count தேர்ந்தெடுக்கப்பட்ட அறிக்கைகள்';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count தேர்வு முடிவுகள்';
  }

  @override
  String get uiAllCurrentFutureReports =>
      'அனைத்து தற்போதைய மற்றும் எதிர்கால அறிக்கைகள்';

  @override
  String get uiNoExpiry => 'காலாவதி இல்லை';

  @override
  String uiExpiresDate(String date) {
    return '$date காலாவதியாகிறது';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'அணுகல் குறியீடு தேவை. இணைப்பிலிருந்து தனித்தனியாகப் பகிரவும்.';

  @override
  String get uiNoAccessCodeRequired => 'அணுகல் குறியீடு தேவையில்லை.';

  @override
  String uiExpiresColonDate(String date) {
    return 'காலாவதியாகும்: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name இன் அறிக்கைகளைப் பகிரவும்';
  }

  @override
  String uiProfileReports(String name) {
    return '$name இன் அறிக்கைகள்';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count தேர்ந்தெடுக்கப்பட்ட முடிவுகள்';
  }

  @override
  String get uiAccessCodeRequiredShort => 'அணுகல் குறியீடு தேவை';

  @override
  String uiPastLinksCount(String count) {
    return 'கடந்த இணைப்புகள் · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return 'காலாவதியானது $date';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'ரத்து செய்யப்பட்டது · $date உருவாக்கப்பட்டது';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum செயலில் உள்ள இணைப்புகளின் $current ஐப் பயன்படுத்துதல்.';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename மற்றும் அதில் சேமிக்கப்பட்ட கோப்பை நீக்கவா? இதை செயல்தவிர்க்க முடியாது.';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'அறிக்கையை நீக்க முடியவில்லை: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'அனைத்து $count அறிக்கைகளையும் அவற்றின் சேமிக்கப்பட்ட கோப்புகளையும் நிரந்தரமாக நீக்கவா? இதை செயல்தவிர்க்க முடியாது.';
  }

  @override
  String get uiRecycleBinEmptied => 'மறுசுழற்சி தொட்டி காலியானது';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return 'நீக்கப்பட்ட $deleted அறிக்கைகள். $failed ஐ நீக்க முடியவில்லை; மீண்டும் முயற்சிக்கவும்.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'மறுசுழற்சி தொட்டியை காலி செய்ய முடியவில்லை: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'சுயவிவரம்: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'சேகரிக்கப்பட்டது: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'பதிவேற்றப்பட்டது: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'நீக்கப்பட்டது: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'நிரந்தர நீக்கல்: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'மீதமுள்ள நாட்கள்: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer =>
      'Doclyzer ஆப்ஸ் பூட்டை உறுதிப்படுத்தவும்';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'ஆப் லாக்கை முடக்கும் முன் உறுதிப்படுத்தவும்';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'உங்கள் உடல்நலப் பதிவுகளைப் பார்க்க டாக்லைசரைத் திறக்கவும்';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'அறிக்கையைப் பதிவேற்றும் முன் இயல்புநிலை சுயவிவரத்தை உருவாக்கவும்.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'உங்கள் காலவரிசையைப் பார்க்கும் முன் இயல்புநிலை சுயவிவரத்தை உருவாக்கவும்.';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'இப்போது சுயவிவரங்களை ஏற்ற முடியவில்லை.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'சுயவிவரத் தரவை ஏற்ற முடியாததால் இப்போது பதிவேற்ற முடியாது. API சேவையகம் இயங்குவதை உறுதிசெய்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'சுயவிவரத் தரவை ஏற்ற முடியாததால், இப்போது காலவரிசையைத் திறக்க முடியாது. API சேவையகம் இயங்குவதை உறுதிசெய்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'இப்போது சுயவிவரங்களை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'பகிர்வு இணைப்புகளை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiPasswordChanged => 'கடவுச்சொல் மாற்றப்பட்டது';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'அந்த அறிக்கையைத் திறக்க முடியவில்லை. அறிக்கை நூலகத்தை முயற்சிக்கவும்.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'உங்கள் கணக்கு மதிப்பாய்வில் இருக்கும்போது இந்தச் செயல் தற்காலிகமாக கிடைக்காது.';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'இந்தப் பகுதியைத் திறக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiAppLockIsUnavailable => 'பயன்பாட்டு பூட்டு கிடைக்கவில்லை';

  @override
  String get uiDoclyzerIsLocked => 'டாக்லைசர் பூட்டப்பட்டுள்ளது';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'சேமிக்கப்பட்ட ஆப் லாக் அமைப்பைப் படிக்க முடியவில்லை. தொடர மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'தொடர, உங்கள் சாதன கடவுக்குறியீடு அல்லது பயோமெட்ரிக்ஸைப் பயன்படுத்தவும்.';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'உங்கள் கணக்கு மதிப்பாய்வில் இருக்கும் போது பதிவேற்றங்கள் தற்காலிகமாக கிடைக்காது.';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'பதிவேற்றத்தைத் தொடங்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiJustNow => 'இப்போதுதான்';

  @override
  String get uiAdditionalDetails => 'கூடுதல் விவரங்கள்:';

  @override
  String get uiSaveCorrection => 'திருத்தத்தை சேமிக்கவும்';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'கோப்புகளைத் திறக்க முடியவில்லை. அணுகலைச் சரிபார்த்து, மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'கேமராவைத் திறக்க முடியவில்லை. அனுமதியைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'புகைப்படங்களைத் திறக்க முடியவில்லை. அனுமதியைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'தேர்ந்தெடுக்கப்பட்ட கோப்பை அணுக முடியவில்லை.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'தேர்ந்தெடுக்கப்பட்ட கோப்பை அணுக முடியவில்லை';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'இணைப்பு துண்டிக்கப்பட்டது. பதிவேற்றம் சர்வரை அடைந்திருக்கலாம். அதே கோப்பை பாதுகாப்பாக மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiCouldNotLoadExistingReport =>
      'ஏற்கனவே உள்ள அறிக்கையை ஏற்ற முடியவில்லை';

  @override
  String get uiAddingTo => 'சேர்க்கிறது';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'சில முடிவுகளை மதிப்பாய்வு செய்ய வேண்டும். உங்கள் அசல் அறிக்கை சேமிக்கப்பட்டது.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'இந்த வடிவமைப்பை எங்களால் படிக்க முடியவில்லை. உங்கள் கோப்பு சேமிக்கப்பட்டது.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'அறிக்கை பாகுபடுத்தப்பட்டது. முடிவுகள் மற்றும் போக்குகள் உள்ளன.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'உங்கள் அறிக்கை இன்னும் பகுப்பாய்வு செய்யப்படுகிறது. அதன் நிலையைச் சரிபார்க்க அதைத் திறக்கவும்.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'செயலாக்கம் நிறுத்தப்பட்டது. உங்கள் கோப்பு சேமிக்கப்பட்டது. நீங்கள் மீண்டும் முயற்சி செய்யலாம்.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'பிரித்தெடுக்கப்பட்ட சோதனை மதிப்புகள் எதுவும் சேர்க்கப்படவில்லை. நீங்கள் இன்னும் ஆவணத்தைத் திறந்து பகிரலாம். உங்கள் போக்குகள் மாறாமல் உள்ளன.';

  @override
  String get uiYourOriginalIsSaved => 'உங்கள் அசல் சேமிக்கப்பட்டது.';

  @override
  String get uiInitialUpload => 'ஆரம்ப பதிவேற்றம்';

  @override
  String get uiParsedSuccessfully => 'வெற்றிகரமாக பாகுபடுத்தப்பட்டது';

  @override
  String get uiParsingFailed => 'பாகுபடுத்த முடியவில்லை';

  @override
  String get uiExtractionIncomplete => 'பிரித்தெடுத்தல் முழுமையடையவில்லை';

  @override
  String get uiTransientFailure => 'நிலையற்ற தோல்வி';

  @override
  String get uiTerminalFailure => 'டெர்மினல் தோல்வி';

  @override
  String get uiFailedToLoadAttemptHistory =>
      'முயற்சி வரலாற்றை ஏற்றுவதில் தோல்வி';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'இந்த அறிக்கையின் கோப்பு இனி கிடைக்காது.';

  @override
  String get uiCompareResults => 'முடிவுகளை ஒப்பிடுக';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'எந்த வித்தியாசமும் கணக்கிடப்படவில்லை. இணக்கத்தன்மை உறுதிப்படுத்தல் தேவை.';

  @override
  String get uiUnitNotRecorded => 'அலகு பதிவு செய்யப்படவில்லை';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'இந்த அறிக்கைகளுக்கு இடையே எண் மாற்றம் இல்லை.';

  @override
  String get uiUnableToRestore => 'மீட்டெடுக்க முடியவில்லை:';

  @override
  String get uiEnterAGiftVoucherCode => 'பரிசு வவுச்சர் குறியீட்டை உள்ளிடவும்.';

  @override
  String get uiApplyVoucher => 'வவுச்சரை விண்ணப்பிக்கவும்';

  @override
  String get uiNotAvailable => 'கிடைக்கவில்லை';

  @override
  String get uiViewReceipt => 'ரசீதை பார்க்கவும்';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'கிஃப்ட் வவுச்சர் தவறானது அல்லது ஏற்கனவே ரிடீம் செய்யப்பட்டது.';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'கிஃப்ட் வவுச்சர் ஏற்கனவே ரிடீம் செய்யப்பட்டுள்ளது.';

  @override
  String get uiGiftVoucherHasBeenVoided =>
      'பரிசு வவுச்சர் ரத்து செய்யப்பட்டுள்ளது.';

  @override
  String get uiGiftVoucherHasExpired => 'பரிசு வவுச்சர் காலாவதியானது.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'இந்த கிஃப்ட் வவுச்சரை ரிடீம் செய்ய முடியவில்லை.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'இந்த கிஃப்ட் வவுச்சரை ரிடீம் செய்ய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiEnterAPromoCodeToApply =>
      'விண்ணப்பிக்க விளம்பரக் குறியீட்டை உள்ளிடவும்.';

  @override
  String get uiPromoCodeNotFound => 'விளம்பர குறியீடு கிடைக்கவில்லை.';

  @override
  String get uiPromoCodeIsInactive =>
      'விளம்பர குறியீடு செயலற்ற நிலையில் உள்ளது.';

  @override
  String get uiPromoCodeHasExpired => 'விளம்பரக் குறியீடு காலாவதியானது.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'இந்த பேக்கிற்கு விளம்பரக் குறியீடு பொருந்தாது.';

  @override
  String get uiPromoCodeUsageLimitReached =>
      'விளம்பர குறியீடு பயன்பாட்டு வரம்பை அடைந்துவிட்டது.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'நீங்கள் ஏற்கனவே இந்த விளம்பரக் குறியீட்டைப் பயன்படுத்தியுள்ளீர்கள்.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'விளம்பரக் குறியீட்டைப் பயன்படுத்துவதில் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'கிரெடிட்களைச் சேர்க்கும் முன் இந்த ஆர்டர் மதிப்பாய்வுக்காகக் கொடியிடப்பட்டது.';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'சமரசத்தின் போது பணம் செலுத்த முடியவில்லை. நீங்கள் பாதுகாப்பாக மீண்டும் முயற்சி செய்யலாம்.';

  @override
  String get uiAwaitingCapture => 'பிடிப்பிற்காக காத்திருக்கிறது';

  @override
  String get uiLastPaymentFailed => 'கடைசியாக பணம் செலுத்த முடியவில்லை';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'நீங்கள் பாதுகாப்பாக மீண்டும் செக் அவுட் செய்ய முயற்சிக்கலாம்.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'சந்தாக்களுக்கு விளம்பரக் குறியீடுகள் இன்னும் ஆதரிக்கப்படவில்லை.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'ஏற்றுமதியைப் பதிவிறக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'அசல் அறிக்கைகள் அல்லது சோதனை முடிவுகளைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'ஏற்றுமதி கோரப்பட்டது. புதுப்பிக்க, \"நிலையைச் சரிபார்க்கவும்\" என்பதைத் தட்டவும்.';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'ஏற்றுமதியைக் கோருவதில் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'ஏற்றுமதி தயார். பதிவிறக்க URL உள்ளது.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'ஏற்றுமதி நிலையைச் சரிபார்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'கணக்கை மூட முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiPrepareExport => 'ஏற்றுமதியை தயார் செய்யுங்கள்';

  @override
  String get uiSaveExport => 'ஏற்றுமதியைச் சேமிக்கவும்';

  @override
  String get uiPrepareExportAgain => 'மீண்டும் ஏற்றுமதியை தயார் செய்யவும்';

  @override
  String get uiAllDates => 'அனைத்து தேதிகளும்';

  @override
  String get uiPreparingAccountDetails => 'கணக்கு விவரங்களைத் தயாரித்தல்';

  @override
  String get uiFamilyMemberProfiles => 'குடும்ப உறுப்பினர் சுயவிவரங்கள்';

  @override
  String get uiUploadedReports => 'பதிவேற்றப்பட்ட அறிக்கைகள்';

  @override
  String get uiDownloadReady => 'பதிவிறக்கம் தயார்';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'இந்தச் சாதனத்தில் அறிவிப்புகளைப் புகாரளிக்கவும்';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'சாதன அமைப்புகள் திறக்கப்பட்டன. Doclyzer க்கான அறிவிப்புகளை அனுமதித்து, பின்னர் இங்கு திரும்பவும்.';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'அறிவிப்புகள் இன்னும் முடக்கத்தில் உள்ளன. அறிக்கை புதுப்பிப்புகளைப் பெற சாதன அமைப்புகளில் அவர்களை அனுமதிக்கவும்.';

  @override
  String get uiPreferencesSaved => 'விருப்பத்தேர்வுகள் சேமிக்கப்பட்டன';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'உங்கள் கணக்குத் தேர்வு சேமிக்கப்பட்டது, ஆனால் இந்தச் சாதனம் மார்க்கெட்டிங் புஷ் பதிவு செய்வதை முடிக்கவில்லை. இந்தச் சாதனத்தில் சந்தைப்படுத்தல் தடைசெய்யப்பட்டுள்ளது; அறிவிப்பு அனுமதியை சரிபார்த்து, மீண்டும் சேமிக்க முயற்சிக்கவும்.';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'உங்கள் கணக்கு தேர்வு சேமிக்கப்பட்டது. இந்தச் சாதனத்தின் உள்ளூர் விருப்பத்தை இன்னும் உறுதிப்படுத்த முடியவில்லை, ஆனால் கணக்கு அளவில் சந்தைப்படுத்தல் தடைசெய்யப்பட்டுள்ளது.';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'உங்கள் கணக்குத் தேர்வு சேமிக்கப்பட்டது, ஆனால் இந்தச் சாதனத்தில் மார்க்கெட்டிங் புஷ் இயக்க முடியவில்லை. அறிவிப்பு அனுமதியை சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'சேமிக்க அதிக நேரம் எடுத்தது. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get uiReportReadyForReview => 'ஆய்வுக்கு அறிக்கை தயார்';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'உங்கள் முடிவுகள் எப்போது சரிபார்க்க தயாராக உள்ளன என்பதை அறியவும்.';

  @override
  String get uiUploadUpdates => 'புதுப்பிப்புகளைப் பதிவேற்றவும்';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'பதிவேற்றம் கவனம் தேவை என்றால் ஒரு செய்தியைப் பெறவும்.';

  @override
  String get uiSharedLinkReminders => 'பகிரப்பட்ட இணைப்பு நினைவூட்டல்கள்';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'இணைப்பு எப்போது காலாவதியாகப்போகிறது என்பதைக் கேட்கவும்.';

  @override
  String get uiSecurityAlerts => 'பாதுகாப்பு எச்சரிக்கைகள்';

  @override
  String get uiRequiredForAccountSafety => 'கணக்கு பாதுகாப்பு தேவை.';

  @override
  String get uiComplianceNotices => 'இணக்க அறிவிப்புகள்';

  @override
  String get uiRequiredAccountInformation => 'தேவையான கணக்கு தகவல்.';

  @override
  String get uiMarketingPushNotifications =>
      'சந்தைப்படுத்தல் புஷ் அறிவிப்புகள்';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'சலுகைகள் மற்றும் அறிவிப்புகள். இந்தத் தேர்வைச் சேமிப்பது இந்தச் சாதனத்திற்கும் பொருந்தும்.';

  @override
  String get uiProductUpdates => 'தயாரிப்பு புதுப்பிப்புகள்';

  @override
  String get uiOptionalNewsAboutDoclyzer =>
      'Doclyzer பற்றிய விருப்பச் செய்திகள்.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'சேவையகத்துடன் இணைக்க முடியவில்லை. உங்கள் இணையம் அல்லது API சேவையகத்தைச் சரிபார்க்கவும்.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'உங்கள் கணக்கு மதிப்பாய்வில் இருக்கும்போது சுயவிவரப் புதுப்பிப்புகள் தற்காலிகமாக கிடைக்காது.';

  @override
  String get uiUse100CharactersOrFewer =>
      '100 அல்லது அதற்கும் குறைவான எழுத்துக்களைப் பயன்படுத்தவும்';

  @override
  String get uiAddProfile => 'சுயவிவரத்தைச் சேர்க்கவும்';

  @override
  String get uiCreateProfile => 'சுயவிவரத்தை உருவாக்கவும்';

  @override
  String get uiUpdateTheirDetails => 'அவர்களின் விவரங்களை புதுப்பிக்கவும்';

  @override
  String get uiWhoIsThisProfileFor => 'இந்த சுயவிவரம் யாருக்காக?';

  @override
  String get uiNotSelected => 'தேர்ந்தெடுக்கப்படவில்லை';

  @override
  String get uiEnterAReferralCode => 'பரிந்துரை குறியீட்டை உள்ளிடவும்.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'பரிந்துரை பயன்படுத்தப்பட்டது. மின்னஞ்சல் சரிபார்ப்புக்குப் பிறகு போனஸ் திறக்கப்படும்.';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'பரிந்துரை பயன்படுத்தப்பட்டது. போனஸ் கிரெடிட்கள் தயாராக உள்ளன.';

  @override
  String get uiApplyCode => 'குறியீட்டைப் பயன்படுத்தவும்';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'உங்களின் சொந்த பரிந்துரைக் குறியீட்டைப் பயன்படுத்த முடியாது.';

  @override
  String get uiReferralCodeIsInvalid => 'பரிந்துரை குறியீடு தவறானது.';

  @override
  String get uiFailedToApplyReferralCode =>
      'பரிந்துரைக் குறியீட்டைப் பயன்படுத்துவதில் தோல்வி.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'பரிந்துரைக் குறியீட்டைப் பயன்படுத்துவதில் தோல்வி. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiThisDevice => 'இந்த சாதனம்';

  @override
  String get uiSignedInDevice => 'உள்நுழைந்த சாதனம்';

  @override
  String get uiUnknownDevice => 'தெரியாத சாதனம்';

  @override
  String get uiRevokeAndLogOut => 'திரும்பப் பெற்று வெளியேறவும்';

  @override
  String get uiRevokeSessionca8440 => 'அமர்வை ரத்து செய்';

  @override
  String get uiEnterYourCurrentPassword =>
      'உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'பெரிய எழுத்து, சிற்றெழுத்து, எண் மற்றும் சிறப்பு எழுத்துகளுடன் குறைந்தபட்சம் 8 எழுத்துகளைப் பயன்படுத்தவும்';

  @override
  String get uiChooseADifferentPassword => 'வேறு கடவுச்சொல்லை தேர்வு செய்யவும்';

  @override
  String get uiNewPasswordsDoNotMatch => 'புதிய கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'கிடைக்கக்கூடிய அனைத்து பதிவேற்ற கிரெடிட்களையும் நீங்கள் பயன்படுத்திவிட்டீர்கள். மேலும் சேர்க்க திட்டம் & கிரெடிட்ஸைப் பார்வையிடவும்.';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'Doclyzer க்கான அறிவிப்புகள் முடக்கப்பட்டுள்ளன. அறிக்கை தயார் மற்றும் கணக்கு புதுப்பிப்புகளை அனுமதிக்க சாதன அமைப்புகளைத் திறக்கவும். நீங்கள் அதைத் தேர்ந்தெடுக்கும் வரை மார்க்கெட்டிங் நிறுத்தப்படும்.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'இந்தச் சாதனத்தில் அறிக்கை தயார் மற்றும் கணக்குப் புதுப்பிப்புகளைப் பெறவும். நீங்கள் அதைத் தேர்ந்தெடுக்கும் வரை மார்க்கெட்டிங் நிறுத்தப்படும்.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'இந்தச் சாதனத்திற்கான அறிவிப்புகள் முடக்கப்பட்டுள்ளன. அறிக்கை தயார் மற்றும் கணக்கு புதுப்பிப்புகளைப் பெற அமைப்புகளைத் திறக்கவும்.';

  @override
  String get uiBlockedExpiredRevoked =>
      'தடுக்கப்பட்டது (காலாவதியானது/திரும்பப் பெற்றது)';

  @override
  String get uiFailedToLoadPolicy => 'கொள்கையை ஏற்றுவதில் தோல்வி';

  @override
  String get uiUploadPaused => 'பதிவேற்றம் இடைநிறுத்தப்பட்டது';

  @override
  String get uiSevenDays => '7 நாட்கள்';

  @override
  String get uiThirtyDays => '30 நாட்கள்';

  @override
  String get uiNinetyDays => '90 நாட்கள்';

  @override
  String get uiUploadingAClearReport => 'தெளிவான அறிக்கையைப் பதிவேற்றுகிறது';

  @override
  String get uiPDFsPhotosAndMultiplePages =>
      'PDFகள், புகைப்படங்கள் மற்றும் பல பக்கங்கள்';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'PDFஐத் தேர்வு செய்யவும் அல்லது ஒவ்வொரு பக்கத்தின் தெளிவான புகைப்படங்களை எடுக்கவும். முழுப் பக்கத்தையும் சட்டகத்தில் வைத்து, கண்ணை கூசுவதைத் தவிர்க்கவும், பகுப்பாய்வு செய்வதற்கு முன் பக்க வரிசையைச் சரிபார்க்கவும். பிரித்தெடுக்கப்பட்ட மதிப்புகளை அசலுக்கு எதிராக சரிசெய்யலாம்.';

  @override
  String get uiCorrectingAResult => 'முடிவை சரிசெய்தல்';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'அசல் மதிப்புகளுக்கு எதிராக மதிப்பாய்வு செய்யவும்';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'அறிக்கையைத் திறந்து, பிரித்தெடுக்கப்பட்ட ஒவ்வொரு சோதனையையும் அசலுக்கு எதிராக மதிப்பாய்வு செய்து, தவறாகப் படிக்கப்பட்ட மதிப்பு, அலகு அல்லது தேதியை சரிசெய்யவும். நீங்கள் போக்குகளை நம்புவதற்கு முன் உறுதிப்படுத்தப்படாத முடிவுகள் சரிபார்க்கப்பட வேண்டும்.';

  @override
  String get uiManagingFamilyRecords => 'குடும்ப பதிவுகளை நிர்வகித்தல்';

  @override
  String get uiProfilesAccessAndPermissions =>
      'சுயவிவரங்கள், அணுகல் மற்றும் அனுமதிகள்';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'சுயவிவரங்களை உருவாக்க மற்றும் மாற்ற குடும்பத்தைப் பயன்படுத்தவும். அறிக்கையைப் பதிவேற்றும் அல்லது பகிர்வதற்கு முன் தேர்ந்தெடுக்கப்பட்ட நபரைச் சரிபார்க்கவும். நீங்கள் அணுகுவதற்கு அங்கீகரிக்கப்பட்ட பதிவுகளை மட்டும் நிர்வகிக்கவும்.';

  @override
  String get uiSharingAndRevokingLinks =>
      'இணைப்புகளைப் பகிர்தல் மற்றும் திரும்பப் பெறுதல்';

  @override
  String get uiControlTheRecordsYouShare =>
      'நீங்கள் பகிரும் பதிவுகளைக் கட்டுப்படுத்தவும்';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'நீங்கள் பகிர விரும்பும் அறிக்கைகள் அல்லது முடிவுகளைத் தேர்ந்தெடுத்து, காலாவதி மற்றும் அணுகல் குறியீட்டை மதிப்பாய்வு செய்து, இணைப்பையும் குறியீட்டையும் தனித்தனியாக அனுப்பவும். அணுகல் தேவையில்லாத போது பகிரப்பட்ட இணைப்புகளிலிருந்து செயலில் உள்ள இணைப்பைத் திரும்பப் பெறவும்.';

  @override
  String get uiInformationYouProvide => 'நீங்கள் வழங்கும் தகவல்';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'கணக்கு விவரங்கள் மற்றும் குடும்ப சுயவிவரங்கள் நீங்கள் யாருடைய பதிவுகளை நிர்வகிக்கிறீர்கள் என்பதைக் கண்டறியும். பதிவேற்றப்பட்ட ஆவணங்களில் முக்கியமான சுகாதாரத் தகவல்கள் இருக்கலாம்.';

  @override
  String get uiSharingControls => 'பகிர்தல் கட்டுப்பாடுகள்';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'ஒவ்வொரு இணைப்பின் உள்ளடக்கம், காலாவதி மற்றும் அணுகல் அமைப்புகளை மதிப்பாய்வு செய்யவும். உங்கள் கணக்கு அமைப்புகளிலிருந்து செயலில் உள்ள இணைப்புகளை நிர்வகிக்கவும்.';

  @override
  String get uiExportAndAccountChoices => 'ஏற்றுமதி மற்றும் கணக்கு தேர்வுகள்';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'பதிவுகளை ஏற்றுமதி செய்ய அல்லது கணக்கு நீக்குதல் கோரிக்கையைத் தொடங்க அமைப்புகளைப் பயன்படுத்தவும். தக்கவைப்பு விவரங்கள் முழுமையான கொள்கையில் அடங்கும்.';

  @override
  String get uiEducationalScope => 'கல்வி நோக்கம்';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'Doclyzer அறிக்கைகளை ஒழுங்கமைத்து காலப்போக்கில் முடிவுகளைக் காட்டுகிறது. கல்வி விளக்கங்கள் மருத்துவ ஆலோசனை அல்லது நோய் கண்டறிதல் அல்ல.';

  @override
  String get uiReviewYourRecords => 'உங்கள் பதிவுகளை மதிப்பாய்வு செய்யவும்';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'அசல் அறிக்கைக்கு எதிராக பிரித்தெடுக்கப்பட்ட மதிப்புகள், அலகுகள் மற்றும் தேதிகளைச் சரிபார்க்கவும். உங்கள் முடிவுகளைப் பற்றி ஒரு சுகாதார நிபுணரிடம் கேளுங்கள்.';

  @override
  String get uiManageAndShareResponsibly =>
      'பொறுப்புடன் நிர்வகிக்கவும் பகிரவும்';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'நீங்கள் அணுகுவதற்கு அங்கீகரிக்கப்பட்ட பதிவுகளை மட்டும் நிர்வகிக்கவும். பகிர்வதற்கு முன் தேர்ந்தெடுக்கப்பட்ட தகவலையும் பெறுநரையும் சரிபார்க்கவும்.';

  @override
  String get uiPrivacyPolicy7ceacd => 'தனியுரிமைக் கொள்கை';

  @override
  String get uiTermsOfUse8a069e => 'பயன்பாட்டு விதிமுறைகள்';

  @override
  String get uiOpenPrivacyControls => 'தனியுரிமைக் கட்டுப்பாடுகளைத் திறக்கவும்';

  @override
  String get uiGetHelpWithTheApp => 'பயன்பாட்டின் மூலம் உதவி பெறவும்';

  @override
  String get uiExportYourDataInAccountSettings =>
      'கணக்கு அமைப்புகளில் உங்கள் தரவை ஏற்றுமதி செய்யவும்';

  @override
  String get uiYOURDATACHOICES => 'உங்கள் தரவு மற்றும் தேர்வுகள்';

  @override
  String get uiUSINGDOCLYZER => 'டாக்லைசரைப் பயன்படுத்துதல்';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'நீங்கள் Doclyzer இல் வைத்திருக்கும்\nதகவலைப் புரிந்து கொள்ளுங்கள்.';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'பயன்பாட்டின் பங்கு பற்றிய தெளிவான புரிதல்\n.';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name இலிருந்து $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · சமீபத்திய $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'இந்த நூலகத்தைத் தொடங்க $nameக்கான அறிக்கையைப் பதிவேற்றவும்.';
  }

  @override
  String uiIpAddress(String address) {
    return 'ஐபி முகவரி: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'உள்நுழைந்துள்ளீர்கள்: $date';
  }

  @override
  String get uiUnknown => 'தெரியவில்லை';

  @override
  String uiResultsFor(String name) {
    return '$name க்கான முடிவுகள்';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count ஆய்வக அளவுருக்கள் கண்காணிக்கப்பட்டன';
  }

  @override
  String uiSampledDate(String date) {
    return 'மாதிரி $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'சேகரிப்பு தேதி: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'ஆய்வக வரம்பு: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI இந்த வரம்பை $range என வாசிக்கிறது. அச்சிடப்பட்ட உரை: $printed. இந்த ஒப்பீட்டை நம்புவதற்கு முன் அசல் அறிக்கையை சரிபார்க்கவும்.';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount தயார்';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count வரவுகள்';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'இந்தக் கணக்கில் ஏற்கனவே பரிந்துரைக் குறியீடு பயன்படுத்தப்பட்டுள்ளது.';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ஆப் லாக்கை இயக்கும் முன் சாதன கடவுக்குறியீட்டை அமைக்கவும்.';

  @override
  String get uiLanguagePreferenceNotSaved =>
      'மொழி விருப்பம் சேமிக்கப்படவில்லை.';

  @override
  String get uiExportUnavailable => 'ஏற்றுமதி கிடைக்கவில்லை';

  @override
  String get uiUnreadableImage => 'படிக்க முடியாத படம்';

  @override
  String uiStatusWithValue(String status) {
    return 'நிலை: $status';
  }

  @override
  String get uiPending => 'நிலுவையில் உள்ளது';

  @override
  String get uiCompleted => 'முடிக்கப்பட்டது';

  @override
  String get uiFailed => 'தோல்வியடைந்தது';

  @override
  String get uiInactive => 'செயலற்றது';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'உங்கள் அறிக்கைகள் மற்றும் சுயவிவரங்களை வைத்திருக்க $date க்கு முன் மீட்டமைக்கவும்.';
  }

  @override
  String get uiThirtyDayDeadline => '30 நாள் காலக்கெடு';

  @override
  String uiWhatsAffected(String details) {
    return 'என்ன பாதிக்கப்படுகிறது: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'கடைசியாக புதுப்பிக்கப்பட்டது: $time இல் $date';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename தற்போதைய சுயவிவரத்திற்கு பதிலாக $name கீழ் தோன்றும்.';
  }

  @override
  String get uiOneVerifiedResult =>
      '1 சரிபார்க்கப்பட்ட முடிவு சேமிக்கப்பட்டது.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count சரிபார்க்கப்பட்ட முடிவுகள் சேமிக்கப்பட்டன.';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'சுயவிவரங்களை மாற்ற முடியவில்லை. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'சேகரிக்கப்பட்டது: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'பதிவேற்றப்பட்டது $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount ஆல் அதிகரிக்கப்பட்டது';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount ஆல் குறைக்கப்பட்டது';
  }

  @override
  String get uiPercentagePoints => 'சதவீத புள்ளிகள்';

  @override
  String uiTestValuesCount(String count) {
    return 'சோதனை மதிப்புகள் ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'செயலாக்கத்தின் போது AI ஆல் மதிப்பு சரிபார்க்கப்பட்டது. அசல் OCR: $value. அறிக்கைக்கு எதிராக அதை உறுதிப்படுத்தவும்.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return 'ஏற்கனவே $name இல் புகாரளிக்கவும்';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return '$name இல் அறிக்கை சேர்க்கப்பட்டது';
  }

  @override
  String uiAddedOn(String date) {
    return '$date சேர்க்கப்பட்டது';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max அறிக்கைகளின் $current ஐப் பயன்படுத்துதல்.';
  }

  @override
  String get uiNeedHelp => 'உதவி தேவையா?';

  @override
  String get uiEnabled => 'இயக்கப்பட்டது';

  @override
  String get uiEnable => 'இயக்கு';

  @override
  String get uiSubscribe => 'குழுசேர்';

  @override
  String get uiApplying => 'விண்ணப்பிக்கும்';

  @override
  String get uiCheckStatus => 'நிலையைச் சரிபார்க்கவும்';

  @override
  String get uiEditProfile => 'சுயவிவரத்தைத் திருத்தவும்';

  @override
  String get uiSaveChanges => 'மாற்றங்களைச் சேமிக்கவும்';

  @override
  String get uiOptional => 'விருப்பமானது';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ஆர்டர் $orderId சமரசத்திற்காக காத்திருக்கிறது. நிலை தெளிவாகும் வரை வாங்குதல் இடைநிறுத்தப்படும்.';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'மாதாந்திர திட்டம் - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'கிரெடிட் பேக் - $name';
  }

  @override
  String get uiUnreadable => 'படிக்க முடியாதது';

  @override
  String uiLatestValue(String value) {
    return 'சமீபத்தியது: $value';
  }

  @override
  String get uiEarlier => 'முன்னதாக';

  @override
  String get uiLater => 'பின்னர்';

  @override
  String get uiViewed => 'பார்க்கப்பட்டது';

  @override
  String get uiBlocked => 'தடுக்கப்பட்டது';

  @override
  String get uiCapped => 'தொப்பி';

  @override
  String uiLastChange(String label) {
    return 'கடைசி மாற்றம்: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'கடைசியாக மாற்றம்: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'பரிசு வவுச்சர் பயன்படுத்தப்பட்டது. $credits வரவுகள் சேர்க்கப்பட்டன.';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'அசலை இன்னும் சேமிக்க முடியவில்லை. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'திரும்பப் பெற முடியவில்லை: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'எனது Doclyzer பரிந்துரைக் குறியீட்டைப் பயன்படுத்தவும் $code: $link';
  }

  @override
  String get uiAMomentAgo => 'ஒரு கணம் முன்பு';

  @override
  String uiMinutesAgo(String count) {
    return '$count நிமிடத்திற்கு முன்பு';
  }

  @override
  String get uiOneHourAgo => '1 மணி நேரத்திற்கு முன்பு';

  @override
  String uiHoursAgo(String count) {
    return '$count மணிநேரங்களுக்கு முன்பு';
  }

  @override
  String get uiToday => 'இன்று';

  @override
  String get uiYesterday => 'நேற்று';

  @override
  String get uiOneDayAgo => '1 நாள் முன்பு';

  @override
  String uiDaysAgo(String count) {
    return '$count நாட்களுக்கு முன்பு';
  }

  @override
  String get uiOneWeekAgo => '1 வாரம் முன்பு';

  @override
  String uiWeeksAgo(String count) {
    return '$count வாரங்களுக்கு முன்பு';
  }

  @override
  String get uiOneMonthAgo => '1 மாதம் முன்பு';

  @override
  String uiMonthsAgo(String count) {
    return '$count மாதங்களுக்கு முன்பு';
  }

  @override
  String get uiOneYearAgo => '1 வருடம் முன்பு';

  @override
  String uiYearsAgo(String count) {
    return '$count ஆண்டுகளுக்கு முன்பு';
  }

  @override
  String get uiInOneDay => '1 நாளில்';

  @override
  String uiInDays(String count) {
    return '$count நாட்களில்';
  }

  @override
  String uiInMinutes(String count) {
    return '$count நிமிடத்தில்';
  }

  @override
  String get uiInOneHour => '1 மணி நேரத்தில்';

  @override
  String uiInHours(String count) {
    return '$count மணிநேரத்தில்';
  }

  @override
  String get uiMissingExtractedTestName =>
      'பிரித்தெடுக்கப்பட்ட முடிவில் சோதனையின் பெயர் இல்லை.';

  @override
  String get uiMissingCapturedLabRange =>
      'இந்த சோதனைக்கு ஆய்வக குறிப்பு வரம்பு எதுவும் எடுக்கப்படவில்லை.';

  @override
  String get uiNonNumericExtractedValue =>
      'பிரித்தெடுக்கப்பட்ட மதிப்பு சாதாரண எண் அல்ல. அசல் அறிக்கையில் சரிபார்க்கவும்.';

  @override
  String get uiLabFlagRangeConflict =>
      'ஆய்வகக் கொடி அச்சிடப்பட்ட வரம்புடன் முரண்படுகிறது. அசல் அறிக்கையை சரிபார்க்கவும்.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'பிரித்தெடுக்கப்பட்ட மதிப்பு, அச்சிடப்பட்ட வரம்பு அல்லது ஆய்வகக் கொடி ஆகியவை அசல் அறிக்கையில் சரிபார்க்கப்பட வேண்டும்.';

  @override
  String get uiInitialEntitlement => 'ஆரம்ப உரிமை';

  @override
  String get uiCreditPackPurchase => 'கிரெடிட் பேக் வாங்குதல்';

  @override
  String get uiSubscriptionUpgrade => 'சந்தா மேம்படுத்தல்';

  @override
  String get uiPlanDowngrade => 'தரமிறக்க திட்டமிடுங்கள்';

  @override
  String get uiAdminAdjustment => 'நிர்வாக சரிசெய்தல்';

  @override
  String get uiSystemReconciliation => 'அமைப்பு சமரசம்';

  @override
  String get uiReferralInviteBonus => 'பரிந்துரை அழைப்பு போனஸ்';

  @override
  String get uiReferralAnalysisMilestone => 'பரிந்துரை பகுப்பாய்வு மைல்கல்';

  @override
  String get uiReferralPurchaseMilestone => 'பரிந்துரை கொள்முதல் மைல்கல்';

  @override
  String get uiFreePromoCreditPack => 'இலவச விளம்பர கிரெடிட் பேக்';

  @override
  String get uiGiftVoucherRedeemed => 'பரிசு வவுச்சர் மீட்டெடுக்கப்பட்டது';

  @override
  String get uiNotYetChanged => 'இன்னும் மாறவில்லை';

  @override
  String get uiCannotReachServer =>
      'சேவையகத்தை அடைய முடியவில்லை. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயலவும்.';

  @override
  String get uiInvalidEmailOrPassword =>
      'தவறான மின்னஞ்சல் அல்லது கடவுச்சொல். உங்கள் விவரங்களைச் சரிபார்த்து, மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiTooManyAuthAttempts =>
      'பல முயற்சிகள். சில நிமிடங்கள் காத்திருந்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get uiEnterValidEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்.';

  @override
  String get uiPasswordRequirements =>
      'கடவுச்சொல்லில் குறைந்தபட்சம் 8 எழுத்துகள் இருக்க வேண்டும் மற்றும் பெரிய எழுத்து, சிறிய எழுத்து, எண் மற்றும் சிறப்பு எழுத்து ஆகியவை இருக்க வேண்டும்.';

  @override
  String get uiAccountWithEmailExists =>
      'இந்த மின்னஞ்சலுடன் கணக்கு ஏற்கனவே உள்ளது. உள்நுழையவும் அல்லது வேறு மின்னஞ்சலைப் பயன்படுத்தவும்.';

  @override
  String get uiUploadedStatus => 'பதிவேற்றப்பட்டது';

  @override
  String uiSupportAction(String action) {
    return 'செயல்: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'தொடர்பு ஐடி: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'கிளையண்ட் நடவடிக்கை ஐடி: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'பிழைக் குறியீடு: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'பிழை: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'உங்கள் அமர்வு முடிந்தது. மீண்டும் உள்நுழையவும்.';

  @override
  String get uiProfileLimitReached =>
      'உங்கள் திட்ட சுயவிவர வரம்பை அடைந்து விட்டது. மேலும் சேர்க்க திட்டம் & கடன்களை மதிப்பாய்வு செய்யவும்.';

  @override
  String get uiCorrectionConflictReload =>
      'இந்த முடிவு வேறு இடத்தில் மாறிவிட்டது. அறிக்கையை சரிசெய்வதற்கு முன் அதை மீண்டும் ஏற்றவும்.';

  @override
  String get uiSeePlanCreditsOptions =>
      'கிடைக்கக்கூடிய விருப்பங்களுக்கு திட்டம் & கிரெடிட்களைப் பார்க்கவும்.';

  @override
  String get uiShareLinkLimitHelp =>
      'செயலில் உள்ள பகிர்வு-இணைப்பு வரம்பை அடைந்துவிட்டீர்கள்.';

  @override
  String get uiScopedExportUnavailable =>
      'ஸ்கோப் செய்யப்பட்ட ஏற்றுமதி கிடைக்கவில்லை. பிறகு முயற்சிக்கவும்.';

  @override
  String get uiRestorationUnavailable =>
      'மறுசீரமைப்பு கிடைக்கவில்லை. பிறகு முயற்சிக்கவும்.';

  @override
  String get uiExportRequestNotFound =>
      'ஏற்றுமதி கோரிக்கை கிடைக்கவில்லை. புதிய ஏற்றுமதியைக் கோரவும்.';

  @override
  String get uiClosureConfirmationRequired =>
      'தொடர, கணக்கை மூடுவதை உறுதிப்படுத்தவும்.';

  @override
  String get uiCurrentPasswordIncorrect => 'தற்போதைய கடவுச்சொல் தவறானது.';

  @override
  String get uiLaboratories => 'ஆய்வகங்கள்';

  @override
  String get uiUnlock => 'திறக்கவும்';
}
