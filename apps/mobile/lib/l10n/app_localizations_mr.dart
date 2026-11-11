// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get trendLatestResult => 'नवीनतम निकाल';

  @override
  String get trendPreviousResult => 'मागील निकाल';

  @override
  String get trendSourceUnit => 'या मर्यादेचे मूळ एकक';

  @override
  String get trendNoSavedResults =>
      'या चाचणीसाठी अद्याप कोणताही जतन केलेला निकाल नाही.';

  @override
  String get trendNoPlottableResults =>
      'नमुना घेतल्याची तारीख असलेले अचूक संख्यात्मक निकाल आलेखात दाखवता येत नाहीत.';

  @override
  String get trendOneResultHelp =>
      'एक निकाल जतन केला आहे. बदल पाहण्यासाठी आणखी एक अहवाल जोडा.';

  @override
  String get trendMultipleResultsHelp =>
      'तारखा गेलेल्या वेळेनुसार दाखवल्या आहेत. मूल्य पाहण्यासाठी बिंदूवर टॅप करा.';

  @override
  String trendUnplottedNote(int count) {
    return 'नमुना घेतल्याची तारीख किंवा अचूक संख्यात्मक मूल्य नसल्यामुळे $count निकाल आलेखात दाखवलेले नाहीत.';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$count निकालांसह $testName बदलांचा आलेख';
  }

  @override
  String get trendDateReview =>
      'नमुना घेतल्याची तारीख आधी काढलेल्या माहितीतून आली आहे. मूळ अहवालात तपासा.';

  @override
  String get trendNotPlotted => 'आलेखात दाखवलेले नाही';

  @override
  String get trendExactNumberUnavailable => 'निकाल अचूक संख्या नाही';

  @override
  String get preferredLanguage => 'पसंतीची भाषा';

  @override
  String get descriptionLanguage => 'वर्णनाची भाषा';

  @override
  String get languageHelp =>
      'ॲपमधील मजकूर आणि अहवालांचे स्पष्टीकरण यांसाठी वापरली जाते. तुम्ही स्पष्टीकरणाची भाषा कधीही बदलू शकता.';

  @override
  String get languageSaveFailed =>
      'तुमची भाषेची निवड जतन करता आली नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get translationLoading => 'भाषांतरित वर्णन तयार होत आहे…';

  @override
  String get translationFailed =>
      'भाषांतर उपलब्ध नाही. पुन्हा प्रयत्न करा किंवा इंग्रजी निवडा.';

  @override
  String get translationNote =>
      'जतन केलेल्या इंग्रजी स्पष्टीकरणाचे AI द्वारे भाषांतर केले आहे. अचूक निकालांसाठी मूळ अहवाल तपासा.';

  @override
  String get sourceChanged =>
      'अहवाल बदलला आहे. नवीनतम स्पष्टीकरण पाहण्यासाठी तो पुन्हा लोड करा.';

  @override
  String get signupTitle => 'अधिक स्पष्ट समज\nइथून सुरू होते.';

  @override
  String get signupIntro =>
      'तुमचे अहवाल आणि निकाल एकत्र ठेवण्यासाठी खाते तयार करा.';

  @override
  String get loginIntro =>
      'तुमचे आरोग्य अहवाल पाहण्यासाठी आणि समजून घेण्यासाठी साइन इन करा.';

  @override
  String get emailAddress => 'ईमेल पत्ता';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get referralCode => 'रेफरल कोड (ऐच्छिक)';

  @override
  String get createAccount => 'खाते तयार करा';

  @override
  String get alreadyAccount => 'आधीच खाते आहे? ';

  @override
  String get noAccount => 'खाते नाही? ';

  @override
  String get signIn => 'साइन इन करा';

  @override
  String get showPassword => 'पासवर्ड दाखवा';

  @override
  String get hidePassword => 'पासवर्ड लपवा';

  @override
  String get needHelp => 'मदत हवी आहे?';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get invalidCredentialsInput => 'वैध ईमेल पत्ता आणि पासवर्ड टाका';

  @override
  String get signupFailed => 'खाते तयार करता आले नाही';

  @override
  String get loginFailed =>
      'साइन इन करता आले नाही. कृपया तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get genericError => 'काहीतरी चुकले. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get profileUpdated => 'प्रोफाइल अद्ययावत केले';

  @override
  String get changePhoto => 'प्रोफाइल फोटो बदला';

  @override
  String get gallery => 'गॅलरीमधून निवडा';

  @override
  String get camera => 'फोटो काढा';

  @override
  String get photoUpdated => 'प्रोफाइल फोटो अद्ययावत केला';

  @override
  String get photoFailed =>
      'तुमचा फोटो अद्ययावत करता आला नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get yourAccount => 'तुमचे खाते';

  @override
  String get profileLoading => 'प्रोफाइल लोड होत आहे…';

  @override
  String get profileLoadAction => 'तुमचे प्रोफाइल लोड करण्यासाठी टॅप करा';

  @override
  String get accountData => 'खाते आणि डेटा';

  @override
  String get personalInformation => 'वैयक्तिक माहिती';

  @override
  String get notificationPreferences => 'सूचनांबाबतची प्राधान्ये';

  @override
  String get privacySecurity => 'गोपनीयता आणि सुरक्षितता';

  @override
  String get sharedLinks => 'शेअर केलेल्या लिंक';

  @override
  String get exportData => 'तुमचा डेटा निर्यात करा';

  @override
  String get additionalAccount => 'खात्याची अतिरिक्त माहिती';

  @override
  String get additionalAccountHelp => 'कुटुंब, योजना, रेफरल, सत्रे आणि स्वरूप';

  @override
  String get familyProfiles => 'कुटुंबातील सदस्यांची प्रोफाइल';

  @override
  String get manageProfiles => 'प्रोफाइल बदला किंवा व्यवस्थापित करा';

  @override
  String get planCredits => 'योजना आणि क्रेडिट्स';

  @override
  String get viewPlanBalance => 'तुमची योजना आणि शिल्लक पाहा';

  @override
  String get balanceLoading => 'शिल्लक लोड होत आहे…';

  @override
  String get referFriends => 'मित्रांना आमंत्रित करा';

  @override
  String get referralRewards => 'आमंत्रणे आणि रेफरल बक्षिसे';

  @override
  String get activeSessions => 'सक्रिय सत्रे';

  @override
  String get appearance => 'स्वरूप';

  @override
  String get system => 'सिस्टमनुसार';

  @override
  String get light => 'फिकट';

  @override
  String get dark => 'गडद';

  @override
  String get helpSupport => 'मदत आणि सहाय्य';

  @override
  String get aboutDoclyzer => 'Doclyzer बद्दल';

  @override
  String get aboutCopy =>
      'अहवाल व्यक्तीनुसार व्यवस्थित ठेवा आणि अहवालातून काढलेले निकाल मूळ अहवालाशी पडताळून पाहा.';

  @override
  String get logOut => 'लॉग आउट करा';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get saveChanges => 'बदल जतन करा';

  @override
  String get accountRestricted => 'खात्यावर निर्बंध आहेत';

  @override
  String get photoUploading => 'फोटो अपलोड होत आहे…';

  @override
  String get changePhotoShort => 'फोटो बदला';

  @override
  String get accountDetails => 'खात्याचे तपशील';

  @override
  String get emailHelp =>
      'खात्यात प्रवेश करण्यासाठी वापरला जातो. तो बदलण्यासाठी सहाय्य पथकाशी संपर्क साधा.';

  @override
  String get accountName => 'खात्याचे नाव';

  @override
  String get belowLabRange => 'या प्रयोगशाळेच्या संदर्भ मर्यादेपेक्षा कमी';

  @override
  String get withinLabRange => 'या प्रयोगशाळेच्या संदर्भ मर्यादेत';

  @override
  String get aboveLabRange => 'या प्रयोगशाळेच्या संदर्भ मर्यादेपेक्षा जास्त';

  @override
  String get cannotCompare => 'प्रयोगशाळेच्या मर्यादेशी तुलना करता येत नाही';

  @override
  String get understandResult => 'हा निकाल समजून घ्या';

  @override
  String get yourResult => 'तुमचा निकाल';

  @override
  String get labReferenceRange => 'प्रयोगशाळेची संदर्भ मर्यादा';

  @override
  String get resultUnavailable => 'या निकालात उपलब्ध नाही';

  @override
  String get sampleDate => 'नमुना घेतल्याची तारीख';

  @override
  String get resultHistory => 'निकालांचा इतिहास';

  @override
  String get originalReport => 'मूळ अहवाल';

  @override
  String get reviewValue => 'मूल्य तपासा';

  @override
  String get understandYourResult => 'तुमचा निकाल समजून घ्या';

  @override
  String get educationalContext =>
      'या निकालाबद्दल चर्चा करण्यास मदत करणारी शैक्षणिक माहिती.';

  @override
  String get explanationUnavailable => 'स्पष्टीकरण उपलब्ध नाही';

  @override
  String get explanationFailed => 'सध्या स्पष्टीकरण लोड करता आले नाही.';

  @override
  String get checkOriginal => 'मूळ अहवाल तपासा';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get aiGuidance => 'AI द्वारे तयार केलेले मार्गदर्शन';

  @override
  String get understandingResult => 'हा निकाल समजून घेऊया';

  @override
  String get possibleMeaning => 'याचा संभाव्य अर्थ';

  @override
  String get whatTestMeasures => 'ही चाचणी काय मोजते';

  @override
  String get suggestedNextStep => 'सुचवलेले पुढील पाऊल';

  @override
  String get resultLimitations => 'या निकालावरून काय समजू शकत नाही';

  @override
  String get oneResultLimit =>
      'केवळ एका निकालावरून एखाद्या आजाराचे निदान करता येत नाही किंवा लक्षणांचे कारण समजू शकत नाही.';

  @override
  String get detailsToCheck => 'तपासायचे तपशील';

  @override
  String get lifestyleFactors => 'चर्चा करण्याजोगे जीवनशैलीचे घटक';

  @override
  String get insightContext =>
      'हे मूल्य तुमच्या अहवालातून काढले आहे. नाव, मूल्य, एकक किंवा मर्यादा चुकीची वाटत असल्यास मूळ अहवाल तपासा. AI स्पष्टीकरणे शैक्षणिक आहेत आणि तुम्हाला कोणत्या उपचारांची गरज आहे हे सांगू शकत नाहीत.';

  @override
  String get yourProfile => 'तुमचे प्रोफाइल';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get delete => 'हटवा';

  @override
  String get moveReport => 'अहवाल हलवा';

  @override
  String get gotIt => 'समजले';

  @override
  String get reportDetails => 'अहवालाचे तपशील';

  @override
  String get shareReport => 'अहवाल शेअर करा';

  @override
  String get moreReportActions => 'अहवालासाठी आणखी कृती';

  @override
  String get attemptHistory => 'प्रयत्नांचा इतिहास';

  @override
  String get compareReports => 'अहवालांची तुलना करा';

  @override
  String get readParsedReport => 'संरचित स्वरूपातील अहवाल वाचा';

  @override
  String get moveRecycle => 'रीसायकल बिनमध्ये हलवा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get reportSummary => 'अहवालाचा सारांश';

  @override
  String get updateSummary => 'सारांश अद्ययावत करा';

  @override
  String get summaryLoading => 'तुमचे निकाल सोप्या भाषेत मांडत आहोत…';

  @override
  String get checkSummary => 'सारांश तपासा';

  @override
  String get summaryFailed =>
      'सारांश तयार करता आला नाही. तुम्ही पुन्हा प्रयत्न करू शकता.';

  @override
  String get summaryPlaceholder =>
      'महत्त्वाच्या निकालांचे सोप्या भाषेतील स्पष्टीकरण येथे दिसेल.';

  @override
  String get retrySummary => 'सारांशासाठी पुन्हा प्रयत्न करा';

  @override
  String get generateSummary => 'सारांश तयार करा';

  @override
  String get loadingResults => 'अहवालातील निकाल लोड होत आहेत…';

  @override
  String get somethingWrong => 'काहीतरी चुकले';

  @override
  String get viewTrends => 'कालानुसार बदल पाहा';

  @override
  String get originalFile => 'मूळ फाइल';

  @override
  String get testValues => 'चाचण्यांची मूल्ये';

  @override
  String get summary => 'सारांश';

  @override
  String get checkStatus => 'स्थिती तपासा';

  @override
  String get viewOriginal => 'मूळ पाहा';

  @override
  String get verifiedResults => 'पडताळलेले निकाल';

  @override
  String get resultTapHelp =>
      'चाचणी काय मोजते हे समजून घेण्यासाठी निकालावर टॅप करा.';

  @override
  String get reviewResults => 'ओळखलेले निकाल तपासा';

  @override
  String get keepFile => 'तरीही फाइल ठेवा';

  @override
  String get patientDetails => 'रुग्णाचे तपशील';

  @override
  String get name => 'नाव';

  @override
  String get age => 'वय';

  @override
  String get gender => 'लिंग';

  @override
  String get bookingId => 'बुकिंग आयडी';

  @override
  String get sampleCollection => 'नमुना संकलन';

  @override
  String get labDetails => 'प्रयोगशाळेचे तपशील';

  @override
  String get labName => 'प्रयोगशाळेचे नाव';

  @override
  String get address => 'पत्ता';

  @override
  String get phone => 'फोन';

  @override
  String get location => 'ठिकाण';

  @override
  String get belowRange => 'मर्यादेपेक्षा कमी';

  @override
  String get aboveRange => 'मर्यादेपेक्षा जास्त';

  @override
  String get withinRange => 'दिलेल्या मर्यादेत';

  @override
  String get rangeUnclear => 'मर्यादा अस्पष्ट';

  @override
  String get understandResultAction => 'हा निकाल समजून घ्या  →';

  @override
  String get parsedReport => 'संरचित स्वरूपातील अहवाल';

  @override
  String get reports => 'अहवाल';

  @override
  String get trends => 'कालानुसार बदल';

  @override
  String get openingPage => 'सुरुवातीचे पृष्ठ';

  @override
  String get home => 'मुख्यपृष्ठ';

  @override
  String get family => 'कुटुंब';

  @override
  String get switchProfile => 'प्रोफाइल बदला';

  @override
  String get currentProfile => 'सध्याचे प्रोफाइल';

  @override
  String get viewProfile => 'हे प्रोफाइल पाहा';

  @override
  String get manageFamily => 'कुटुंब व्यवस्थापित करा';

  @override
  String get chooseProfile => 'प्रोफाइल निवडा';

  @override
  String get notifications => 'सूचना';

  @override
  String get homeTitle => 'थोडी अधिक स्पष्टता.\nसर्व एकाच ठिकाणी.';

  @override
  String get nextReportTitle =>
      'तुमचा पुढचा अहवाल,\nतुम्ही तयार असाल तेव्हा सज्ज.';

  @override
  String get homeSubtitle => 'PDF, फोटो आणि कुटुंबाच्या नोंदी.';

  @override
  String get uploadReport => 'अहवाल अपलोड करा';

  @override
  String get recentReport => 'अलीकडील अहवाल';

  @override
  String get viewAll => 'सर्व पाहा';

  @override
  String get reportsUnavailable =>
      'अहवाल उपलब्ध नाहीत. इंटरनेटशी जोडल्यावर पुन्हा प्रयत्न करा.';

  @override
  String get emptyHomeTitle => 'तुमचा प्रवास इथून सुरू होतो';

  @override
  String get emptyHomeHelp =>
      'तुमच्या नोंदींचा स्पष्ट इतिहास तयार करण्यासाठी पहिला अहवाल अपलोड करा.';

  @override
  String get uploadFirstReport => 'तुमचा पहिला अहवाल अपलोड करा';

  @override
  String get latestResults => 'नवीनतम निकाल';

  @override
  String get allTrends => 'कालानुसार झालेले सर्व बदल';

  @override
  String get reviewedResultsHelp =>
      'तपासलेले निकाल उपलब्ध झाल्यावर येथे दिसतील.';

  @override
  String get searchTests => 'चाचण्या शोधा';

  @override
  String get noHealthData =>
      'अद्याप आरोग्यविषयक डेटा नाही. तुमचा आरोग्य इतिहास पाहण्यासाठी अहवाल अपलोड करा.';

  @override
  String get noTestsFound => 'चाचण्या सापडल्या नाहीत';

  @override
  String get shorterTestName => 'चाचणीचे नाव थोडक्यात टाकून पाहा.';

  @override
  String get clearSearch => 'शोध साफ करा';

  @override
  String get unitUnavailable => 'एकक उपलब्ध नाही';

  @override
  String get uploadingReport => 'अहवाल अपलोड होत आहे…';

  @override
  String get organizingReport => 'तुमचा अहवाल व्यवस्थित मांडत आहोत…';

  @override
  String get uploadAReport => 'अहवाल अपलोड करा';

  @override
  String get uploadHelp =>
      'PDF किंवा स्पष्ट फोटो निवडा. जतन करण्यापूर्वी तुम्ही तपशील तपासू शकता.';

  @override
  String get chooseSource => 'स्रोत निवडा';

  @override
  String get uploadPdfImage => 'PDF किंवा प्रतिमा अपलोड करा';

  @override
  String get chooseReportFiles => 'तुमच्या फाइलमधून अहवाल निवडा';

  @override
  String get selectReportPages => 'अहवालाची एक किंवा अधिक पाने निवडा';

  @override
  String get capturePage => 'संपूर्ण पानाचा फोटो काढा';

  @override
  String get supportedFormats => 'समर्थित स्वरूपे: PDF, JPG, PNG';

  @override
  String get confirmFile =>
      'तुम्हाला जोडायची असलेली फाइल हीच आहे याची खात्री करा.';

  @override
  String get addReport => 'अहवाल जोडा';

  @override
  String get chooseDifferentFile => 'वेगळी फाइल निवडा';

  @override
  String get uploadWait => 'यासाठी थोडा वेळ लागू शकतो. कृपया ॲप उघडे ठेवा.';

  @override
  String get reportNeedsAttention => 'अहवालाकडे लक्ष देणे आवश्यक आहे';

  @override
  String get verifyBeforeSaving =>
      'ओळखलेले निकाल जतन करण्यापूर्वी मूळ अहवालाशी पडताळून पाहा.';

  @override
  String get viewVerifiedResults => 'पडताळलेले निकाल पाहा';

  @override
  String get viewOriginalReport => 'मूळ अहवाल पाहा';

  @override
  String get viewReportStatus => 'अहवालाची स्थिती पाहा';

  @override
  String get viewResults => 'निकाल पाहा';

  @override
  String get viewOriginalFile => 'मूळ फाइल पाहा';

  @override
  String get retryExtraction => 'माहिती काढण्याचा पुन्हा प्रयत्न करा';

  @override
  String get done => 'पूर्ण झाले';

  @override
  String get duplicateReport => 'हा अहवाल आधीच्या अहवालाची प्रत वाटतो';

  @override
  String get duplicateHelp => 'ही फाइल तुमच्या अहवालांमध्ये आधीच असू शकते.';

  @override
  String get keepExisting => 'आधीचा अहवाल ठेवा';

  @override
  String get processAgain => 'PDF वर पुन्हा प्रक्रिया करा';

  @override
  String get uploadNewCopy => 'नवीन प्रत म्हणून अपलोड करा';

  @override
  String get reportLimitReached => 'अहवालांची मर्यादा गाठली';

  @override
  String get reportLimitHelp => 'तुम्ही अहवालांची मर्यादा गाठली आहे.';

  @override
  String get upgrade => 'श्रेणीवाढ करा';

  @override
  String get back => 'मागे';

  @override
  String get uploadFailedTitle => 'अहवाल अपलोड करता आला नाही';

  @override
  String get uploadFailed => 'अपलोड अयशस्वी झाले';

  @override
  String get retrySameFile => 'त्याच फाइलसाठी पुन्हा प्रयत्न करा';

  @override
  String get chooseAnotherFile => 'दुसरी फाइल निवडा';

  @override
  String get aiDisclaimer =>
      'Doclyzer तुम्हाला तुमचे आरोग्य अहवाल व्यवस्थित ठेवण्यास आणि अधिक चांगल्या प्रकारे समजून घेण्यास मदत करते. दिलेली माहिती केवळ शैक्षणिक उद्देशांसाठी आहे; ती वैद्यकीय सल्ला, निदान किंवा उपचार नाही. वैद्यकीय मार्गदर्शनासाठी नेहमी पात्र आरोग्यसेवा व्यावसायिकाचा सल्ला घ्या.';

  @override
  String collectedOn(String date) {
    return 'नमुना घेतल्याची तारीख $date';
  }

  @override
  String uploadedOn(String date) {
    return 'अपलोड केल्याची तारीख $date';
  }

  @override
  String labRangeValue(String range) {
    return 'प्रयोगशाळेची मर्यादा $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits क्रेडिट्स';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अहवाल',
      one: '1 अहवाल',
      zero: 'अहवाल नाहीत',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'अहवाल लोड होण्यासाठी अपेक्षेपेक्षा जास्त वेळ लागत आहे. तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get summaryUpdateFailed =>
      'सध्या सारांश अद्ययावत करता आला नाही. जतन केलेला सारांश अजूनही उपलब्ध आहे.';

  @override
  String get summaryCreateFailed =>
      'सध्या सारांश तयार करता आला नाही. तुमचे निकाल अजूनही खाली उपलब्ध आहेत.';

  @override
  String get reassignFailed =>
      'अहवाल दुसऱ्या प्रोफाइलला जोडता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get confirmRecycle => 'रीसायकल बिनमध्ये हलवायचा?';

  @override
  String get recycleHelp =>
      'तुम्ही हा अहवाल 30 दिवसांपर्यंत अहवाल > रीसायकल बिन येथून पुनर्संचयित करू शकता. त्यानंतर तो कायमचा हटवला जाईल.';

  @override
  String get reportRecycled => 'अहवाल रीसायकल बिनमध्ये हलवला';

  @override
  String get reportDeleteFailed => 'अहवाल हटवता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get addProfileBeforeMove =>
      'हा अहवाल हलवण्यापूर्वी कुटुंबातील आणखी एका सदस्याचे प्रोफाइल जोडा.';

  @override
  String get moveReportHelp =>
      'हा अहवाल चुकीच्या प्रोफाइलमध्ये जोडला असल्यास कुटुंबातील दुसरा सदस्य निवडा.';

  @override
  String get confirmMoveReport => 'हा अहवाल हलवायचा?';

  @override
  String get aboutSampleDates => 'नमुना घेतल्याच्या तारखांबद्दल';

  @override
  String get multipleDatesHelp =>
      'या अहवालात एकापेक्षा जास्त तारखांना घेतलेल्या नमुन्यांचे निकाल आहेत. निकाल उघडून त्याची तारीख मूळ अहवालाशी पडताळून पाहा.';

  @override
  String get missingDateHelp =>
      'नमुन्याची तारीख म्हणजे नमुना घेतल्याचा दिवस. या अहवालात विश्वासार्ह तारीख सापडली नाही. नमुन्याची तारीख अपलोडच्या तारखेपेक्षा वेगळी असते. निकालाची तारीख तपासण्यासाठी किंवा दुरुस्त करण्यासाठी तो उघडा.';

  @override
  String get uploading => 'अपलोड होत आहे';

  @override
  String get waitingToProcess => 'प्रक्रियेच्या प्रतीक्षेत';

  @override
  String get readingReport => 'अहवाल वाचत आहोत';

  @override
  String get readyToReview => 'तपासण्यासाठी तयार';

  @override
  String get someResultsNeedReview => 'काही निकाल तपासणे आवश्यक आहे';

  @override
  String get couldNotReadReport => 'अहवाल वाचता आला नाही';

  @override
  String get processingStopped => 'प्रक्रिया थांबली';

  @override
  String get couldNotProcessReport => 'अहवालावर प्रक्रिया करता आली नाही';

  @override
  String get reportRefreshFailed =>
      'हा अहवाल पुन्हा लोड करता आला नाही. शेवटचा लोड केलेला निकाल दाखवत आहोत.';

  @override
  String get multipleSampleDates => 'नमुना घेतल्याच्या अनेक तारखा ';

  @override
  String get missingSampleDate => 'नमुना घेतल्याची तारीख सापडली नाही ';

  @override
  String get reportAnalyzing =>
      'आम्ही या अहवालाचे विश्लेषण करत आहोत. तुम्ही या स्क्रीनवरून बाहेर जाऊ शकता; निकाल तयार झाल्यावर दिसतील.';

  @override
  String get extractionIncompleteTitle =>
      'सर्व निकाल विश्वासार्हपणे काढता आले नाहीत';

  @override
  String get extractionIncompleteHelp =>
      'स्वयंचलितपणे माहिती काढणे अपूर्ण राहिले. ओळखलेल्या ओळी जतन करण्यापूर्वी मूळ अहवालाशी पडताळून पाहा.';

  @override
  String get verifiedRowsHelp =>
      'या ओळी मूळ अहवालाशी पडताळल्या आहेत. इतर ओळी अजूनही तपासाव्या लागू शकतात.';

  @override
  String get noTestValues =>
      'या अहवालात चाचण्यांची मूल्ये सापडली नाहीत. त्यातील माहिती तपासण्यासाठी मूळ फाइल उघडा.';

  @override
  String get processingRetryHelp =>
      'प्रक्रिया पूर्ण होण्यापूर्वी थांबली. तुमची फाइल जतन केली आहे. पुन्हा प्रयत्न करण्यासाठी ‘पुन्हा प्रयत्न करा’ वर टॅप करा.';

  @override
  String get resultsNeedCheck =>
      'काही निकाल मूळ अहवालाशी पडताळणे आवश्यक आहे. खाली ओळखलेल्या ओळी तुम्ही तपासू शकता.';

  @override
  String get readerModeHelp =>
      'सहज पाहता यावा आणि अधिक सुलभपणे वाचता यावा यासाठी संरचित स्वरूपातील अहवाल वाचन मोडमध्ये उपलब्ध आहे.';

  @override
  String get aiRangeHelp =>
      'प्रक्रियेदरम्यान AI ने मर्यादेचा अर्थ लावला आहे. मूळ अहवाल तपासा.';

  @override
  String get checkResultHelp =>
      'या निकालावर अवलंबून राहण्यापूर्वी तो मूळ अहवालाशी पडताळून पाहा.';

  @override
  String get preferredRangeHelp =>
      'प्रयोगशाळेने छापलेल्या प्राधान्य श्रेणीशी तुलना केली आहे; ती तुम्हाला लागू होते याची खात्री करा.';

  @override
  String get categoryComparisonHelp =>
      'या तुलनेसाठी प्रयोगशाळेने छापलेली प्राधान्य श्रेणी वापरली आहे. ती श्रेणी तुम्हाला लागू होते का ते तपासा.';

  @override
  String get missingSavedResult =>
      'हे मूल्य जतन केलेल्या निकालाशी जुळवता आले नाही. मूळ अहवाल तपासा किंवा हा अहवाल पुन्हा लोड करा.';

  @override
  String get unreviewedTest =>
      'AI स्पष्टीकरणांसाठी या चाचणीचे अद्याप पुनरावलोकन झालेले नाही. मूळ अहवाल तपासा आणि तुमच्या डॉक्टरांशी निकालाबद्दल चर्चा करा.';

  @override
  String get unsafeResult =>
      'अहवालातून काढलेला निकाल अस्पष्ट असल्याने त्याचे सुरक्षितपणे स्पष्टीकरण देता येत नाही. मूळ अहवाल तपासा.';

  @override
  String get filterReports => 'अहवाल फिल्टर करा';

  @override
  String get sortReports => 'अहवालांचा क्रम लावा';

  @override
  String get recycleBin => 'रीसायकल बिन';

  @override
  String get healthHistory => 'आरोग्य इतिहास';

  @override
  String get shareProfile => 'प्रोफाइल शेअर करा';

  @override
  String get reportsUnavailableTitle => 'अहवाल उपलब्ध नाहीत';

  @override
  String get reportsLoadFailed =>
      'अहवाल लोड करता आले नाहीत. इंटरनेटशी जोडल्यावर पुन्हा प्रयत्न करा.';

  @override
  String get upload => 'अपलोड करा';

  @override
  String get reportsFor => 'यांच्यासाठी अहवाल';

  @override
  String get searchReports => 'अहवाल किंवा प्रयोगशाळा शोधा';

  @override
  String get filters => 'फिल्टर';

  @override
  String get noReportsYet => 'अद्याप अहवाल नाहीत';

  @override
  String get noMatchingReports => 'तुमच्या शोधाशी जुळणारे अहवाल नाहीत.';

  @override
  String get differentSearch =>
      'वेगळी चाचणी, प्रयोगशाळा किंवा फिल्टर वापरून पाहा.';

  @override
  String get clearFilters => 'शोध आणि फिल्टर साफ करा';

  @override
  String get original => 'मूळ';

  @override
  String get switchActiveProfile => 'सक्रिय प्रोफाइल बदला';

  @override
  String get switchProfileHelp =>
      'दुसऱ्या व्यक्तीचे अहवाल पाहा. अपलोड आणि कालानुसार बदलांसाठी तुमचे सक्रिय प्रोफाइलही बदलेल.';

  @override
  String get multipleCollectionDates => 'नमुना संकलनाच्या अनेक तारखा';

  @override
  String get unknownCollectionDate => 'नमुना संकलनाची तारीख अज्ञात';

  @override
  String get profileLoadFailed =>
      'प्रोफाइल लोड करता आली नाहीत. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get pleaseTryAgain => 'कृपया पुन्हा प्रयत्न करा.';

  @override
  String get deleteProfileConfirm => 'प्रोफाइल हटवायचे?';

  @override
  String get deleteProfileHelp =>
      'हे प्रोफाइल काढून टाकले जाईल. त्याच्याशी जोडलेल्या सर्व डेटावर परिणाम होईल.';

  @override
  String get profileDeleteFailed =>
      'प्रोफाइल हटवता आले नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get addFamilyMember => 'कुटुंबातील सदस्य जोडा';

  @override
  String get familyUnavailable => 'कुटुंबातील सदस्यांची प्रोफाइल उपलब्ध नाहीत';

  @override
  String get familyIntro =>
      'व्यक्तीनुसार व्यवस्थित ठेवलेले अहवाल आणि कालानुसार बदल';

  @override
  String get noProfilesYet => 'अद्याप प्रोफाइल नाहीत';

  @override
  String get noProfilesHelp =>
      'स्वतःचे किंवा कुटुंबातील सदस्यांचे अहवाल व्यवस्थित ठेवण्यासाठी प्रोफाइल जोडा.';

  @override
  String get yourFamily => 'तुमचे कुटुंब';

  @override
  String get upgradeProfiles => 'आणखी प्रोफाइल जोडण्यासाठी श्रेणीवाढ करा';

  @override
  String get editProfile => 'प्रोफाइल संपादित करा';

  @override
  String get deleteProfile => 'प्रोफाइल हटवा';

  @override
  String get active => 'सक्रिय';

  @override
  String get setActive => 'सक्रिय करा';

  @override
  String get viewReports => 'अहवाल पाहा';

  @override
  String get notNow => 'आत्ता नको';

  @override
  String get openSettings => 'सेटिंग्ज उघडा';

  @override
  String get enableNotifications => 'सूचना सुरू करा';

  @override
  String get enableNotificationsConfirm => 'सूचना सुरू करायच्या?';

  @override
  String get notificationsEnabled => 'अहवालाच्या सूचना सुरू केल्या';

  @override
  String get notificationsStayOff =>
      'सूचना अजूनही बंद आहेत. तुम्ही त्या नंतर डिव्हाइसच्या सेटिंग्जमध्ये सुरू करू शकता.';

  @override
  String get notificationsFailed =>
      'सूचना सुरू करता आल्या नाहीत. तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get switchProfileFailed =>
      'प्रोफाइल बदलता आले नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get sourceReportFailed => 'मूळ अहवाल उघडता आला नाही.';

  @override
  String get partialRefreshFailed =>
      'काही माहिती अद्ययावत करता आली नाही. पुन्हा प्रयत्न करण्यासाठी खाली ओढा.';

  @override
  String get knowReportReady => 'तुमचा अहवाल तयार झाल्यावर जाणून घ्या';

  @override
  String get oneResult => 'एक निकाल';

  @override
  String get sameDayResults => 'एकाच दिवसाचे निकाल';

  @override
  String get verificationRequired => 'पडताळणी आवश्यक';

  @override
  String get accountCreatedLogin =>
      'तुमचे खाते यशस्वीपणे तयार झाले. लॉग इन करण्यासाठी पुढे जा.';

  @override
  String get continueLogin => 'लॉग इन करण्यासाठी पुढे जा';

  @override
  String get allReports => 'सर्व अहवाल';

  @override
  String get filterReviewed => 'तपासलेले';

  @override
  String get filterNeedsReview => 'तपासणे आवश्यक';

  @override
  String get filterProcessing => 'प्रक्रिया सुरू आहे';

  @override
  String get filterOriginalOnly => 'केवळ मूळ';

  @override
  String get reportDateNewest => 'अहवालाची तारीख · नवीन आधी';

  @override
  String get reportDateOldest => 'अहवालाची तारीख · जुने आधी';

  @override
  String get uploadDateNewest => 'अपलोडची तारीख · नवीन आधी';

  @override
  String get uploadDateOldest => 'अपलोडची तारीख · जुने आधी';

  @override
  String get switchAction => 'बदला';

  @override
  String get collectionDate => 'नमुना संकलनाची तारीख';

  @override
  String get copy => 'कॉपी करा';

  @override
  String get history => 'इतिहास';

  @override
  String get loadingReport => 'अहवाल लोड होत आहे…';

  @override
  String get restore => 'पुनर्संचयित करा';

  @override
  String get revoke => 'रद्द करा';

  @override
  String get testName => 'चाचणीचे नाव';

  @override
  String get viewReport => 'अहवाल पाहा';

  @override
  String get closeAccount => 'खाते बंद करा';

  @override
  String get createShareLink => 'शेअर करण्यासाठी लिंक तयार करा';

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'देखावा बदलला, परंतु पुढील वेळेसाठी जतन करणे शक्य झाले नाही.';

  @override
  String get uiThisReportIsNoLongerAvailable => 'हा अहवाल आता उपलब्ध नाही.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'सूचना पूर्वावलोकन व्यवस्थापित करण्यासाठी डिव्हाइस सेटिंग्ज उघडा.';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'अपलोड स्वीकारेपर्यंत ही स्क्रीन उघडी ठेवा.';

  @override
  String get uiAnUploadMayHaveBeenInterrupted => 'अपलोडमध्ये व्यत्यय आला असावा';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'अहवाल तपासा. ती गहाळ असल्यास, तीच फाइल पुन्हा जोडा.';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'सूचना डिसमिस करू शकलो नाही. पुन्हा प्रयत्न करा.';

  @override
  String get uiConnectionUnavailable => 'कनेक्शन अनुपलब्ध';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'तुमचे सत्र तपासले जाऊ शकले नाही. इंटरनेटशी कनेक्ट करा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiSignInWithAnotherAccount => 'दुसऱ्या खात्याने साइन इन करा';

  @override
  String get uiNoActiveProfile => 'सक्रिय प्रोफाइल नाही';

  @override
  String get uiDismissUploadNotice => 'अपलोड सूचना डिसमिस करा';

  @override
  String get uiDismissReadyNotifications => 'तयार सूचना डिसमिस करा';

  @override
  String get uiRequestSupport => 'समर्थनाची विनंती करा';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'आम्ही डायग्नोस्टिक आयडी समाविष्ट करू जेणेकरून टीम तपास करू शकेल.';

  @override
  String get uiSendRequest => 'विनंती पाठवा';

  @override
  String get uiWhatHappenedOptional => 'काय झालं? (पर्यायी)';

  @override
  String get uiReviewResult => 'पुनरावलोकन परिणाम';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'जतन करण्यापूर्वी मूळ अहवालाशी या फील्डची तुलना करा.';

  @override
  String get uiOriginallyExtracted => 'मूलतः काढले';

  @override
  String get uiReloadReport => 'अहवाल रीलोड करा';

  @override
  String get uiResultAsPrinted => 'छापल्याप्रमाणे परिणाम';

  @override
  String get uiUnitIfShown => 'युनिट (दर्शविले असल्यास)';

  @override
  String get uiLabReferenceRangeIfShown =>
      'प्रयोगशाळा संदर्भ श्रेणी (दाखवले असल्यास)';

  @override
  String get uiCheckYourReport => 'तुमचा अहवाल तपासा';

  @override
  String get uiNoAttemptHistoryAvailable => 'प्रयत्न इतिहास उपलब्ध नाही.';

  @override
  String get uiIInspectedTheOriginal => 'मी मूळ तपासणी केली';

  @override
  String get uiChooseTwoReports => 'दोन अहवाल निवडा';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'एकाच व्यक्तीसाठी रेकॉर्ड वापरा. जुळणाऱ्या चाचण्या शेजारी दिसतील.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'प्रथम जुना अहवाल आणि दुसरा नवीन अहवाल निवडा.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'सुसंगत तेव्हाच तुलना. सुसंगततेची पुष्टी होईपर्यंत भिन्न एकके किंवा पद्धती स्वतंत्रपणे दर्शविल्या जातात.';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'बदल म्हणजे निदान नाही. प्रत्येक निकालाची त्याच्या स्वत:च्या अहवालाच्या अंतराने तुलना करा आणि संदर्भाविषयी तुमच्या डॉक्टरांशी चर्चा करा.';

  @override
  String get uiChooseDifferentReports => 'भिन्न अहवाल निवडा';

  @override
  String get uiEarlierReport => 'पूर्वीचा अहवाल';

  @override
  String get uiLaterReport => 'नंतर अहवाल';

  @override
  String get uiYourReportPages => 'तुमची अहवाल पृष्ठे';

  @override
  String get uiKeepPagesInTheSameOrderAs => 'अहवालाप्रमाणेच पृष्ठे ठेवा.';

  @override
  String get uiAddAnotherPage => 'दुसरे पृष्ठ जोडा';

  @override
  String get uiChoosePagesFromGallery => 'गॅलरीमधून पृष्ठे निवडा';

  @override
  String get uiAdjustPage => 'पृष्ठ समायोजित करा';

  @override
  String get uiRetake => 'पुन्हा घ्या';

  @override
  String get uiUseAdjustedPage => 'समायोजित पृष्ठ वापरा';

  @override
  String get uiResetChanges => 'बदल रीसेट करा';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'प्रत्येक परिणाम कोपर्यात ठेवा.';

  @override
  String get uiRotate => 'फिरवा';

  @override
  String get uiReportRestored => 'अहवाल पुनर्संचयित केला';

  @override
  String get uiDeleteReportPermanently => 'अहवाल कायमचा हटवायचा?';

  @override
  String get uiDeletePermanently => 'कायमचे हटवा';

  @override
  String get uiReportPermanentlyDeleted => 'अहवाल कायमचा हटवला';

  @override
  String get uiEmptyRecycleBin => 'रिसायकल बिन रिकामा?';

  @override
  String get uiDeleteAll => 'सर्व हटवा';

  @override
  String get uiRecycleBinIsEmpty => 'रिसायकल बिन रिकामा आहे.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'हटवलेले अहवाल काढण्यापूर्वी येथे दिसतील.';

  @override
  String get uiEmptyRecycleBind657e2 => 'रिसायकल बिन रिकामा';

  @override
  String get uiCheckDetectedResult => 'आढळलेला निकाल तपासा';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'या पंक्तीची मूळ अहवालाशी तुलना करा. सेव्ह करण्यापूर्वी कोणत्याही OCR चुका दुरुस्त करा.';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'मी मूळ अहवालाविरुद्ध हा निकाल तपासला';

  @override
  String get uiSaving => 'सेव्ह करत आहे...';

  @override
  String get uiSaveVerifiedResult => 'सत्यापित परिणाम जतन करा';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'कोणतेही परिणाम आढळले नाहीत. मूळ अहवाल पहा किंवा पुन्हा प्रक्रिया करण्याचा प्रयत्न करा.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'शोधलेली मूल्ये जतन केलेले परिणाम होण्यापूर्वी मूळ अहवालाविरुद्ध तपासणे आवश्यक आहे.';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'काही पंक्ती गहाळ असू शकतात. संपूर्ण मूळ अहवालाची तपासणी करा.';

  @override
  String get uiResult => 'परिणाम';

  @override
  String get uiUnitOptional => 'युनिट (पर्यायी)';

  @override
  String get uiReferenceRangeOptional => 'संदर्भ श्रेणी (पर्यायी)';

  @override
  String get uiVerified => 'सत्यापित';

  @override
  String get uiGiftVoucher => 'गिफ्ट व्हाउचर';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'गिफ्ट व्हाउचर रिडीम करा आणि क्रेडिट्स थेट तुमच्या शिल्लकमध्ये जोडा.';

  @override
  String get uiCurrentPlan => 'चालू योजना';

  @override
  String get uiCreditBalance => 'क्रेडिट शिल्लक';

  @override
  String get uiPlanLimits => 'योजना मर्यादा';

  @override
  String get uiBuyCredits => 'क्रेडिट्स खरेदी करा';

  @override
  String get uiRecentBillingActivity => 'अलीकडील बिलिंग क्रियाकलाप';

  @override
  String get uiRefreshStatus => 'स्थिती रिफ्रेश करा';

  @override
  String get uiNoRecentOrdersYet => 'अद्याप कोणतेही अलीकडील ऑर्डर नाहीत.';

  @override
  String get uiVoucherCode => 'व्हाउचर कोड';

  @override
  String get uiCheckout => 'चेकआउट';

  @override
  String get uiApply => 'अर्ज करा';

  @override
  String get uiClear => 'साफ';

  @override
  String get uiPay => 'पे';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'यावेळी कोणतेही क्रेडिट पॅक उपलब्ध नाहीत.';

  @override
  String get uiBuy => 'खरेदी करा';

  @override
  String get uiRetryPayment => 'पेमेंटचा पुन्हा प्रयत्न करा';

  @override
  String get uiPromoCode => 'प्रोमो कोड';

  @override
  String get uiEnterPromoCode => 'प्रोमो कोड प्रविष्ट करा';

  @override
  String get uiChooseAPlan => 'एक योजना निवडा';

  @override
  String get uiNoPlansAvailableAtThisTime =>
      'यावेळी कोणतीही योजना उपलब्ध नाही.';

  @override
  String get uiHaveAPromoCode => 'प्रोमो कोड आहे का?';

  @override
  String get uiCURRENTPLAN => 'चालू योजना';

  @override
  String get uiManageNotifications => 'सूचना व्यवस्थापित करा';

  @override
  String get uiAll => 'सर्व';

  @override
  String get uiUnread => 'न वाचलेले';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'प्रवेश त्वरित थांबतो. तुम्ही 30 दिवसांच्या आत साइन इन आणि रिस्टोअर करू शकता. त्यानंतर, तुमचे खाते आणि संग्रहित फायली सक्रिय संचयनातून हटविल्या जातात.';

  @override
  String get uiCloseMyAccount => 'माझे खाते बंद करा';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'तुमचे रेकॉर्ड डॉक्लायझरमध्ये राहतात.';

  @override
  String get uiTakeACopyOfYourRecords => 'तुमच्या नोंदींची एक प्रत घ्या.';

  @override
  String get uiWhoseRecords => 'कोणाच्या नोंदी?';

  @override
  String get uiCouldNotLoadProfiles => 'प्रोफाइल लोड करू शकलो नाही';

  @override
  String get uiLoadingProfiles => 'प्रोफाइल लोड करत आहे...';

  @override
  String get uiAllProfiles => 'सर्व प्रोफाइल';

  @override
  String get uiDateRange => 'तारीख श्रेणी';

  @override
  String get uiUseAllDates => 'सर्व तारखा वापरा';

  @override
  String get uiINCLUDEINTHISEXPORT => 'या निर्यातीत समाविष्ट करा';

  @override
  String get uiOriginalReports => 'मूळ अहवाल';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'तुम्ही अपलोड केलेल्या PDF आणि प्रतिमा';

  @override
  String get uiTestResults => 'चाचणी परिणाम';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'CSV म्हणून परिणाम, त्यांच्या पुनरावलोकन स्थितीसह';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'निर्यातीत वैयक्तिक माहिती असते. तुमचा विश्वास असलेल्या ठिकाणी ते साठवा.';

  @override
  String get uiDeleteAccount => 'खाते हटवा';

  @override
  String get uiContinueToDeletion => 'हटविणे सुरू ठेवा';

  @override
  String get uiKeepMyAccount => 'माझे खाते ठेवा';

  @override
  String get uiBeforeYouLeave => 'जाण्यापूर्वी';

  @override
  String get uiPleaseReadWhatThisWillRemove => 'कृपया हे काय काढेल ते वाचा.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'तुमचे खाते हटवल्याने तुम्ही व्यवस्थापित केलेल्या सर्व प्रोफाइलवर परिणाम होतो.';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'तुमचे खाते आणि वैयक्तिक प्रोफाइल';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'तुमच्या शेअर केलेल्या लिंक्सद्वारे प्रवेश करा';

  @override
  String get uiKeepACopyFirst => 'प्रथम एक प्रत ठेवा';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'तुम्हाला राखून ठेवायची असलेली माहिती निर्यात करा.';

  @override
  String get uiExportData => 'डेटा निर्यात करा';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'प्रवेश त्वरित थांबतो. आपण 30 दिवसांच्या आत पुनर्संचयित करू शकता. त्यानंतर, तुमचा डेटा सक्रिय स्टोरेजमधून काढून टाकला जाईल.';

  @override
  String get uiAccountPendingDeletion => 'खाते हटविणे प्रलंबित आहे';

  @override
  String get uiRestoreMyAccount => 'माझे खाते पुनर्संचयित करा';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'तुमच्या प्रोफाईल, प्रोफाईल आणि संमती रेकॉर्डसह तुमच्या खाते डेटाची प्रत डाउनलोड करा.';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'तुमचे खाते त्वरित अक्षम केले आहे. तुम्ही ते 30 दिवसांच्या आत पुनर्संचयित करू शकता. त्यानंतर, तुमचा डेटा कायमचा हटवला जाईल.';

  @override
  String get uiCurrentPassword => 'वर्तमान पासवर्ड';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'ॲप लॉक बदलू शकलो नाही. पुन्हा प्रयत्न करा.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'तुमचे रेकॉर्ड.\nशेअर करण्याची तुमची निवड.';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'आपल्याला आवश्यक असेल तेव्हा प्रवेशाचे पुनरावलोकन करा.';

  @override
  String get uiAppLock => 'ॲप लॉक';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'तुमच्या डिव्हाइसचे बायोमेट्रिक किंवा पासकोड लॉक वापरा.';

  @override
  String get uiNotificationPreviews => 'सूचना पूर्वावलोकन';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'तुमच्या डिव्हाइस सेटिंग्जमध्ये लॉक-स्क्रीन पूर्वावलोकन नियंत्रित करा.';

  @override
  String get uiContactSupport => 'सपोर्टशी संपर्क साधा';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'तुम्ही निवडल्यासच अहवाल संलग्न करा.';

  @override
  String get uiWhatCanWeHelpYouWith => 'आम्ही तुम्हाला काय मदत करू शकतो?';

  @override
  String get uiPOPULARQUESTIONS => 'लोकप्रिय प्रश्न';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'तुमच्या शोधाशी जुळणारे कोणतेही मदत लेख नाहीत.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'तुमच्या आरोग्याबद्दल किंवा चाचणी परिणामांबद्दलच्या प्रश्नांसाठी, एखाद्या योग्य आरोग्यसेवा व्यावसायिकाशी बोला.';

  @override
  String get uiYourReportsAClearerPicture => 'तुमचे अहवाल. अधिक स्पष्ट चित्र.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'तुमचा आरोग्य इतिहास एकत्र ठेवा.';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'अहवाल संग्रहित करा, परिणामांचे पुनरावलोकन करा, बदलांचे अनुसरण करा आणि तुमच्या डॉक्टरांशी शेअर करा.';

  @override
  String get uiEducationalInformationOnly => 'फक्त शैक्षणिक माहिती';

  @override
  String get uiSearchHelpArticles => 'मदत लेख शोधा';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'सूचना प्रवेश बदलण्यासाठी डिव्हाइस सेटिंग्ज ॲप उघडा.';

  @override
  String get uiSavePreferences => 'प्राधान्ये जतन करा';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'सेटिंग्जमध्ये डिव्हाइस परवानग्या बदलल्या जाऊ शकतात.';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'या डिव्हाइसवर अहवाल अद्यतने मिळवा';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'अहवाल तयार झाल्यावर सूचनांना अनुमती द्या. विपणन खाली एक स्वतंत्र निवड आहे.';

  @override
  String get uiREPORTACTIVITY => 'अहवाल क्रियाकलाप';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'अहवाल क्रियाकलाप सेटिंग्जसाठी नवीनतम सर्व्हर आवृत्ती आवश्यक आहे.';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'संवेदनशील लॉक-स्क्रीन पूर्वावलोकने';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'अहवालाची नावे आणि वैयक्तिक तपशील नेहमी लपवले जातात.';

  @override
  String get uiOTHERMESSAGES => 'इतर संदेश';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'प्रत्येक व्यक्तीचे अहवाल आणि ट्रेंड एकत्र ठेवा.';

  @override
  String get uiPersonDetails => 'व्यक्ती तपशील';

  @override
  String get uiDateOfBirth => 'जन्मतारीख';

  @override
  String get uiRelationship => 'नातेसंबंध';

  @override
  String get uiEnterAName => 'एक नाव प्रविष्ट करा';

  @override
  String get uiClearDateOfBirth => 'जन्मतारीख स्पष्ट करा';

  @override
  String get uiOptionalEGParentOrChild => 'पर्यायी, उदा. पालक किंवा मूल';

  @override
  String get uiInviteFriendsEarnCredits =>
      'मित्रांना आमंत्रित करा, क्रेडिट्स मिळवा';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'तुमचा कोड शेअर करा आणि रिवॉर्ड अनलॉक म्हणून प्रत्येक आमंत्रणाचे अनुसरण करा.';

  @override
  String get uiYOURREFERRALCODE => 'तुमचा रेफरल कोड';

  @override
  String get uiShareInvite => 'आमंत्रण शेअर करा';

  @override
  String get uiCopyCode => 'कोड कॉपी करा';

  @override
  String get uiHaveACode => 'कोड आहे का?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'तुमच्या आमंत्रण पुरस्कारावर दावा करण्यासाठी तुमच्यासोबत शेअर केलेला कोड एंटर करा.';

  @override
  String get uiHowRewardsWork => 'पुरस्कार कसे कार्य करतात';

  @override
  String get uiNoFriendsReferredYet =>
      'अद्याप कोणत्याही मित्रांना संदर्भित केले नाही';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'त्यांची प्रगती येथे पाहण्यासाठी तुमचे आमंत्रण शेअर करा.';

  @override
  String get uiReferralCode => 'रेफरल कोड';

  @override
  String get uiSetNewPassword => 'नवीन पासवर्ड सेट करा';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'तुमच्या ईमेलमधील लिंकवरून रीसेट टोकन आणि तुमचा नवीन पासवर्ड एंटर करा.';

  @override
  String get uiResetPassword => 'पासवर्ड रीसेट करा';

  @override
  String get uiBackToLogin => 'लॉगिन वर परत';

  @override
  String get uiResetToken => 'टोकन रीसेट करा';

  @override
  String get uiNewPassword => 'नवीन पासवर्ड';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'तुमच्या खात्याशी संबंधित ईमेल पत्ता प्रविष्ट करा आणि आम्ही तुम्हाला तुमचा पासवर्ड रीसेट करण्यासाठी एक लिंक पाठवू.';

  @override
  String get uiSendResetLink => 'रीसेट लिंक पाठवा';

  @override
  String get uiRevokeSession => 'सत्र मागे घ्यायचे?';

  @override
  String get uiCurrentSession => 'चालू सत्र';

  @override
  String get uiSkip => 'वगळा';

  @override
  String get uiChangePassword => 'पासवर्ड बदला';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'तुमचा वर्तमान पासवर्ड एंटर करा आणि एक नवीन निवडा.';

  @override
  String get uiNewPasswordd850ee => 'नवीन पासवर्ड';

  @override
  String get uiConfirmNewPassword => 'नवीन पासवर्डची पुष्टी करा';

  @override
  String get uiGettingThingsReady => 'गोष्टी तयार करत आहे...';

  @override
  String get uiLinkAccessHistory => 'दुवा प्रवेश इतिहास';

  @override
  String get uiNoAccessEventsYet => 'अद्याप कोणतेही प्रवेश कार्यक्रम नाहीत.';

  @override
  String get uiDefaultShareLinkExpiry => 'डीफॉल्ट शेअर लिंक एक्सपायरी';

  @override
  String get uiSave => 'जतन करा';

  @override
  String get uiReviewSharing => 'शेअरिंगचे पुनरावलोकन करा';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'व्यक्ती, अहवाल आणि प्रवेश तपासा.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'निवड किंवा प्रवेश सेटिंग्ज संपादित करा';

  @override
  String get uiRevokeShareLink => 'शेअर लिंक मागे घ्यायची?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'ही लिंक काम करणे थांबवेल. तुम्ही एक नवीन तयार करू शकता.';

  @override
  String get uiShareLinkReady => 'शेअर लिंक तयार आहे';

  @override
  String get uiAccessCodeShareSeparately =>
      'प्रवेश कोड — स्वतंत्रपणे सामायिक करा';

  @override
  String get uiCopyAccessCode => 'प्रवेश कोड कॉपी करा';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'हा कोड या डिव्हाइसवर जतन केला जाऊ शकला नाही. नंतर वापरण्यासाठी ते आता कॉपी करा.';

  @override
  String get uiShareLink => 'लिंक शेअर करा';

  @override
  String get uiCopyLink => 'लिंक कॉपी करा';

  @override
  String get uiRevokeLink => 'लिंक मागे घ्या';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'या डिव्हाइसवर कोड अनुपलब्ध आहे. सेव्ह केलेला कोड वापरा किंवा नवीन लिंक तयार करा.';

  @override
  String get uiActiveSharedLinks => 'सक्रिय सामायिक दुवे';

  @override
  String get uiShare => 'शेअर करा';

  @override
  String get uiCreateANewShareLink => 'नवीन शेअर लिंक तयार करा';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'या प्रोफाइलसाठी वर्तमान आणि भविष्यातील अहवाल समाविष्ट करा.';

  @override
  String get uiChooseReports => 'अहवाल निवडा';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'खाली निवडलेले फक्त अहवाल शेअर करा.';

  @override
  String get uiSelectAll => 'सर्व निवडा';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'शेअर करण्यासाठी कोणतेही पुनरावलोकन केलेले अहवाल उपलब्ध नाहीत.';

  @override
  String get uiSelectedTestResults => 'निवडलेले चाचणी परिणाम';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'या अहवालांमधून तुम्ही निवडलेले परिणाम समाविष्ट करा.';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'या अहवालांमध्ये कोणतेही जतन केलेले चाचणी परिणाम उपलब्ध नाहीत.';

  @override
  String get uiUpgradeOrManage => 'श्रेणीसुधारित करा किंवा व्यवस्थापित करा';

  @override
  String get uiExpiry => 'कालबाह्यता:';

  @override
  String get uiRequireAnAccessCode => 'प्रवेश कोड आवश्यक आहे';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'लिंकवरून कोड स्वतंत्रपणे शेअर करा.';

  @override
  String get uiTryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get uiClearExpiry => 'कालबाह्यता साफ करा';

  @override
  String get onboardingStoreEyebrow => '01 / जतन करा';

  @override
  String get onboardingStoreTitle => 'प्रत्येक अहवाल,\nएक परिचित ठिकाण.';

  @override
  String get onboardingStoreBody =>
      'तुमच्यासाठी आणि तुमची काळजी घेत असलेल्या लोकांसाठी PDF आणि फोटो एकत्र ठेवा.';

  @override
  String get onboardingUnderstandEyebrow => '02 / समजून घ्या';

  @override
  String get onboardingUnderstandTitle => 'संख्या,\nवाचणे सोपे केले.';

  @override
  String get onboardingUnderstandBody =>
      'तुमच्या अहवालातील प्रत्येक चाचणी, त्याचे एकक आणि मध्यांतर पहा. मूळ कधीही तपासा.';

  @override
  String get onboardingTrackEyebrow => '03 / ट्रॅक आणि शेअर करा';

  @override
  String get onboardingTrackTitle => 'बदल पहा.\nसंदर्भ सामायिक करा.';

  @override
  String get onboardingTrackBody =>
      'कालांतराने परिणामांचे अनुसरण करा आणि तुमचा चिकित्सक नेमके काय पाहू शकेल ते निवडा.';

  @override
  String get onboardingNext => 'पुढे';

  @override
  String get onboardingGetStarted => 'सुरुवात करा';

  @override
  String get uiSupportRequestSent => 'समर्थन विनंती पाठवली.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'चाचणीचे नाव आणि निकाल आवश्यक आहे.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD फॉरमॅटमध्ये वैध संकलन तारीख वापरा.';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'ही सुधारणा जतन करू शकलो नाही. पुन्हा प्रयत्न करा.';

  @override
  String get uiReportsUnavailable => 'अहवाल उपलब्ध नाहीत';

  @override
  String get uiTryAgain042c86 => 'पुन्हा प्रयत्न करा';

  @override
  String get uiTwoReportsAreNeeded => 'दोन अहवाल आवश्यक आहेत';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'परिणामांची तुलना करण्यासाठी या प्रोफाइलसाठी जुना अहवाल जोडा.';

  @override
  String get uiCannotCompareYet => 'अजून तुलना करता येत नाही';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'या अहवालांमध्ये तुलना करण्यासाठी कोणतेही जुळणारे परिणाम उपलब्ध नाहीत.';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'अहवाल लोड करण्यात अक्षम. पुन्हा प्रयत्न करा.';

  @override
  String get uiCouldNotOpenPhotosOrCamera =>
      'फोटो किंवा कॅमेरा उघडता आला नाही.';

  @override
  String get uiCouldNotOpenCamera => 'कॅमेरा उघडता आला नाही.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'ही पाने तयार करता आली नाहीत. न वाचता येणारे पृष्ठ पुन्हा घ्या आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiCouldNotAdjustThisPage => 'हे पृष्ठ समायोजित करू शकलो नाही.';

  @override
  String get uiNoChartableResultYet => 'अद्याप कोणतेही चार्टेबल परिणाम नाही';

  @override
  String get uiProfiles => 'प्रोफाइल';

  @override
  String get uiReports => 'अहवाल';

  @override
  String get uiShareLinks => 'लिंक्स शेअर करा';

  @override
  String get uiAIChat => 'एआय गप्पा';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'पात्रता सारांश लोड करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'बिलिंग स्थिती रीफ्रेश करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'पावती डाउनलोड लवकरच उपलब्ध होईल.';

  @override
  String get uiSubtotal => 'बेरजे';

  @override
  String get uiDiscount => 'सवलत';

  @override
  String get uiTotal => 'एकूण';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'क्रेडिट पॅक लोड करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'पेमेंट कॅप्चर प्रलंबित आहे. दुसरे चेकआउट सुरू करण्यापूर्वी स्थिती रिफ्रेश करा.';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'क्रेडिट यशस्वीरित्या लागू केले गेले.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ऑर्डर तयार करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'पेमेंट मिळाले. क्रेडिट्स जोडण्यापूर्वी सर्व्हर सामंजस्याची प्रतीक्षा करत आहे.';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'पेमेंट अयशस्वी. तयार झाल्यावर तुम्ही चेकआउटचा पुन्हा प्रयत्न करू शकता.';

  @override
  String get uiPaymentFailedTryAgain => 'पेमेंट अयशस्वी. पुन्हा प्रयत्न करा.';

  @override
  String get uiCreditsAdded => 'क्रेडिट जोडले!';

  @override
  String get uiPromoCodeApplied => 'प्रोमो कोड लागू केला.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'पेमेंट प्राप्त झाले, परंतु या ऑर्डरचे पुनरावलोकन प्रलंबित आहे.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'समेट करताना पेमेंट अयशस्वी झाले.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'पेमेंट निश्चित केले. सर्व्हर सामंजस्य अद्याप प्रलंबित आहे.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'पेमेंट सत्यापित केले. समेट प्रलंबित आहे, कृपया लवकरच रीफ्रेश करा.';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'पेमेंट प्राप्त झाले परंतु पडताळणी अद्याप बाकी आहे. कृपया स्थिती रिफ्रेश करा.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'योजना लोड करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'सदस्यता तयार करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'सदस्यता अयशस्वी. पुन्हा प्रयत्न करा.';

  @override
  String get uiPlanUpgraded => 'योजना अपग्रेड केली!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'पेमेंट प्राप्त झाले परंतु सत्यापन अयशस्वी झाले. योजना लवकरच अपग्रेड केली जाईल.';

  @override
  String get uiNotificationsUnavailable => 'सूचना अनुपलब्ध';

  @override
  String get uiAllQuietForNow => 'तूर्तास सर्व शांत.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'जेव्हा काहीतरी नवीन असेल तेव्हा अहवाल अद्यतने आणि शेअरिंग स्मरणपत्रे येथे दिसून येतील.';

  @override
  String get uiNoUnreadUpdates => 'कोणतेही न वाचलेले अपडेट नाहीत';

  @override
  String get uiYouReAllCaughtUp => 'तुम्ही सर्व पकडले आहात.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'सूचना लोड करण्यात अक्षम. कनेक्ट झाल्यावर पुन्हा प्रयत्न करा.';

  @override
  String get uiManageSharedLinks => 'शेअर केलेले दुवे व्यवस्थापित करा';

  @override
  String get uiExportYourData => 'तुमचा डेटा निर्यात करा';

  @override
  String get uiReadThePrivacyPolicy => 'गोपनीयता धोरण वाचा';

  @override
  String get uiTermsOfUse => 'वापराच्या अटी';

  @override
  String get uiPrivacyPolicy => 'गोपनीयता धोरण';

  @override
  String get uiDateOfBirthOptional => 'जन्मतारीख, ऐच्छिक';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'नातेसंबंध 50 वर्ण किंवा त्यापेक्षा कमी असणे आवश्यक आहे.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'प्रोफाइल सेव्ह करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiReferralsUnavailable => 'संदर्भ अनुपलब्ध';

  @override
  String get uiYourRewards => 'तुमचे बक्षिसे';

  @override
  String get uiReferralProgress => 'रेफरल प्रगती';

  @override
  String get uiFriendsReferred => 'मित्रांचा संदर्भ दिला';

  @override
  String get uiCreditsEarned => 'क्रेडिट मिळाले';

  @override
  String get uiPendingRewards => 'प्रलंबित पुरस्कार';

  @override
  String get uiBlockedRewards => 'अवरोधित पुरस्कार';

  @override
  String get uiInviteeBonus => 'आमंत्रित बोनस';

  @override
  String get uiFirstAnalysis => 'पहिले विश्लेषण';

  @override
  String get uiFirstPurchase => 'प्रथम खरेदी';

  @override
  String get uiMonthlyCap => 'मासिक कॅप';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'रेफरल लोड करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiReferralCodeCopied => 'रेफरल कोड कॉपी केला.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'तुमच्या ईमेल लिंकवरून रीसेट टोकन एंटर करा';

  @override
  String get uiEnterYourNewPassword => 'तुमचा नवीन पासवर्ड टाका';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'पासवर्ड रीसेट करण्यात अक्षम. कृपया नवीन लिंकची विनंती करा.';

  @override
  String get uiEnterYourEmailAddress => 'तुमचा ईमेल पत्ता प्रविष्ट करा';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'रीसेट लिंक पाठवण्यात अक्षम. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiFailedToLoadSessions => 'सत्र लोड करण्यात अयशस्वी.';

  @override
  String get uiFailedToRevokeSession => 'सत्र मागे घेण्यात अयशस्वी.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'पासवर्ड बदलण्यात अक्षम. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'डिव्हाइस सेटिंग्ज उघडा आणि डॉक्लायझरसाठी सूचनांना अनुमती द्या.';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'अहवाल लोड करता आले नाहीत. पुन्हा प्रयत्न करा.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'चाचणी परिणाम लोड करणे शक्य झाले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'शेअर करण्यासाठी किमान एक अहवाल निवडा.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'शेअर करण्यासाठी किमान एक चाचणी निकाल निवडा.';

  @override
  String get uiLinkCopiedToClipboard => 'लिंक क्लिपबोर्डवर कॉपी केली';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'प्रवेश कोड क्लिपबोर्डवर कॉपी केला';

  @override
  String get uiOnePerson => '1 व्यक्ती';

  @override
  String uiPeopleCount(String count) {
    return '$count लोक';
  }

  @override
  String uiActionsFor(String name) {
    return '$name साठी क्रिया';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'प्रोफाइल स्विच करण्यात अक्षम. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name वर स्विच केले';
  }

  @override
  String get uiAnalyzeOnePage => '1 पृष्ठाचे विश्लेषण करा';

  @override
  String uiAnalyzePages(String count) {
    return '$count पृष्ठांचे विश्लेषण करा';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'तुमच्या अहवालात दाखवलेल्या क्रमाने पेज ड्रॅग करा';

  @override
  String get uiCheckEveryPage => 'विश्लेषण करण्यापूर्वी प्रत्येक पृष्ठ तपासा';

  @override
  String get uiOnePageAdded => '1 पृष्ठ जोडले';

  @override
  String uiPagesAdded(String count) {
    return '$count पृष्ठे जोडली';
  }

  @override
  String get uiReorder => 'पुनर्क्रमित करा';

  @override
  String uiPageNumber(String number) {
    return 'पृष्ठ $number';
  }

  @override
  String uiRemovePage(String number) {
    return '$number पृष्ठ काढा';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · पृष्ठ $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'क्रॉप कडा: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count निवडलेले अहवाल';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count निवडलेले चाचणी परिणाम';
  }

  @override
  String get uiAllCurrentFutureReports => 'सर्व वर्तमान आणि भविष्यातील अहवाल';

  @override
  String get uiNoExpiry => 'एक्सपायरी नाही';

  @override
  String uiExpiresDate(String date) {
    return '$date कालबाह्य होईल';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'प्रवेश कोड आवश्यक आहे. दुव्यापासून ते स्वतंत्रपणे सामायिक करा.';

  @override
  String get uiNoAccessCodeRequired => 'प्रवेश कोड आवश्यक नाही.';

  @override
  String uiExpiresColonDate(String date) {
    return 'कालबाह्य: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name चे अहवाल शेअर करा';
  }

  @override
  String uiProfileReports(String name) {
    return '$name चे अहवाल';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count निवडलेले परिणाम';
  }

  @override
  String get uiAccessCodeRequiredShort => 'प्रवेश कोड आवश्यक आहे';

  @override
  String uiPastLinksCount(String count) {
    return 'मागील दुवे · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return 'कालबाह्य $date';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'रद्द केले · $date तयार केले';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum सक्रिय लिंक्सपैकी $current वापरणे.';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename आणि त्याची संग्रहित फाइल हटवायची? हे पूर्ववत केले जाऊ शकत नाही.';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'अहवाल हटविण्यात अक्षम: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'सर्व $count अहवाल आणि त्यांच्या संग्रहित फायली कायमचे हटवायचे? हे पूर्ववत केले जाऊ शकत नाही.';
  }

  @override
  String get uiRecycleBinEmptied => 'रीसायकल बिन रिकामा केला';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted अहवाल हटवले. $failed हटवता आले नाही; पुन्हा प्रयत्न करा.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'रीसायकल बिन रिकामा करण्यात अक्षम: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'प्रोफाइल: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'संकलित: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'अपलोड केले: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'यावर हटवले: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'यावर कायमस्वरूपी हटवा: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'दिवस शिल्लक: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer => 'Doclyzer साठी ॲप लॉकची पुष्टी करा';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'ॲप लॉक बंद करण्यापूर्वी पुष्टी करा';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'तुमचे आरोग्य रेकॉर्ड पाहण्यासाठी डॉक्लायझर अनलॉक करा';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'अहवाल अपलोड करण्यापूर्वी डीफॉल्ट प्रोफाइल तयार करा.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'तुमची टाइमलाइन पाहण्यापूर्वी डीफॉल्ट प्रोफाइल तयार करा.';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'आत्ता प्रोफाइल लोड करण्यात अक्षम.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'आत्ता अपलोड करू शकत नाही कारण प्रोफाइल डेटा लोड केला जाऊ शकत नाही. कृपया API सर्व्हर चालू असल्याची खात्री करा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'आत्ता टाइमलाइन उघडू शकत नाही कारण प्रोफाइल डेटा लोड केला जाऊ शकत नाही. कृपया API सर्व्हर चालू असल्याची खात्री करा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'आत्ता प्रोफाइल लोड करण्यात अक्षम. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'शेअरिंग लिंक लोड करण्यात अक्षम. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiPasswordChanged => 'पासवर्ड बदलला';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'तो अहवाल उघडण्यात अक्षम. अहवाल लायब्ररी वापरून पहा.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'तुमचे खाते पुनरावलोकनाधीन असताना ही क्रिया तात्पुरती अनुपलब्ध आहे.';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'हा विभाग उघडण्यात अक्षम. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiAppLockIsUnavailable => 'ॲप लॉक अनुपलब्ध आहे';

  @override
  String get uiDoclyzerIsLocked => 'डॉक्लायझर कुलूपबंद आहे';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'सेव्ह केलेले ॲप लॉक सेटिंग वाचू शकलो नाही. सुरू ठेवण्यासाठी पुन्हा प्रयत्न करा.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'सुरू ठेवण्यासाठी तुमचा डिव्हाइस पासकोड किंवा बायोमेट्रिक्स वापरा.';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'तुमचे खाते पुनरावलोकनाधीन असताना अपलोड तात्पुरते अनुपलब्ध असतात.';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'अपलोड सुरू करण्यात अक्षम. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiJustNow => 'आत्ताच';

  @override
  String get uiAdditionalDetails => 'अतिरिक्त तपशील:';

  @override
  String get uiSaveCorrection => 'दुरुस्ती जतन करा';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'फायली उघडू शकलो नाही. प्रवेश तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'कॅमेरा उघडता आला नाही. परवानगी तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'फोटो उघडता आले नाहीत. परवानगी तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'निवडलेल्या फाईलमध्ये प्रवेश करणे शक्य झाले नाही.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'निवडलेल्या फाईलमध्ये प्रवेश करणे शक्य झाले नाही';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'कनेक्शन तुटले. अपलोड सर्व्हरवर पोहोचला असावा. तीच फाइल सुरक्षितपणे पुन्हा प्रयत्न करा.';

  @override
  String get uiCouldNotLoadExistingReport => 'विद्यमान अहवाल लोड करू शकलो नाही';

  @override
  String get uiAddingTo => 'मध्ये जोडत आहे';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'काही परिणामांचे पुनरावलोकन आवश्यक आहे. तुमचा मूळ अहवाल जतन केला आहे.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'आम्ही हे स्वरूप वाचू शकलो नाही. तुमची फाईल सेव्ह झाली आहे.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'अहवाल यशस्वीरित्या पार्स केला. परिणाम आणि ट्रेंड उपलब्ध आहेत.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'तुमच्या अहवालाचे अजून विश्लेषण केले जात आहे. त्याची स्थिती तपासण्यासाठी ते उघडा.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'प्रक्रिया थांबवली. तुमची फाईल सेव्ह झाली आहे. तुम्ही पुन्हा प्रयत्न करू शकता.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'कोणतीही काढलेली चाचणी मूल्ये जोडली गेली नाहीत. तुम्ही अजूनही दस्तऐवज उघडू आणि शेअर करू शकता. तुमचे ट्रेंड अपरिवर्तित आहेत.';

  @override
  String get uiYourOriginalIsSaved => 'तुमचे मूळ जतन केले आहे.';

  @override
  String get uiInitialUpload => 'प्रारंभिक अपलोड';

  @override
  String get uiParsedSuccessfully => 'यशस्वीरित्या पार्स केले';

  @override
  String get uiParsingFailed => 'पार्सिंग अयशस्वी';

  @override
  String get uiExtractionIncomplete => 'निष्कर्षण अपूर्ण';

  @override
  String get uiTransientFailure => 'क्षणिक अपयश';

  @override
  String get uiTerminalFailure => 'टर्मिनल अपयश';

  @override
  String get uiFailedToLoadAttemptHistory =>
      'प्रयत्न इतिहास लोड करण्यात अयशस्वी';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'या अहवालाची फाइल यापुढे उपलब्ध नाही.';

  @override
  String get uiCompareResults => 'परिणामांची तुलना करा';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'फरक मोजला नाही. सुसंगततेची पुष्टी आवश्यक आहे.';

  @override
  String get uiUnitNotRecorded => 'युनिट रेकॉर्ड नाही';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'या अहवालांमध्ये संख्यात्मक बदल नाही.';

  @override
  String get uiUnableToRestore => 'पुनर्संचयित करण्यात अक्षम:';

  @override
  String get uiEnterAGiftVoucherCode => 'गिफ्ट व्हाउचर कोड एंटर करा.';

  @override
  String get uiApplyVoucher => 'व्हाउचर लागू करा';

  @override
  String get uiNotAvailable => 'उपलब्ध नाही';

  @override
  String get uiViewReceipt => 'पावती पहा';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'गिफ्ट व्हाउचर अवैध आहे किंवा आधीच रिडीम केलेले आहे.';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'गिफ्ट व्हाउचर आधीच रिडीम केले गेले आहे.';

  @override
  String get uiGiftVoucherHasBeenVoided => 'गिफ्ट व्हाउचर रद्द केले गेले आहे.';

  @override
  String get uiGiftVoucherHasExpired => 'गिफ्ट व्हाउचर कालबाह्य झाले आहे.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'हे गिफ्ट व्हाउचर रिडीम करण्यात अक्षम.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'हे गिफ्ट व्हाउचर रिडीम करण्यात अक्षम. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiEnterAPromoCodeToApply => 'अर्ज करण्यासाठी प्रोमो कोड एंटर करा.';

  @override
  String get uiPromoCodeNotFound => 'प्रोमो कोड सापडला नाही.';

  @override
  String get uiPromoCodeIsInactive => 'प्रोमो कोड निष्क्रिय आहे.';

  @override
  String get uiPromoCodeHasExpired => 'प्रोमो कोड कालबाह्य झाला आहे.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'या पॅकवर प्रोमो कोड लागू नाही.';

  @override
  String get uiPromoCodeUsageLimitReached => 'प्रोमो कोड वापर मर्यादा गाठली.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'तुम्ही हा प्रोमो कोड आधीच वापरला आहे.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'प्रोमो कोड लागू करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'क्रेडिट जोडण्याआधी ही ऑर्डर पुनरावलोकनासाठी ध्वजांकित केली गेली.';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'समेट करताना पेमेंट अयशस्वी झाले. तुम्ही सुरक्षितपणे पुन्हा प्रयत्न करू शकता.';

  @override
  String get uiAwaitingCapture => 'कॅप्चरच्या प्रतीक्षेत';

  @override
  String get uiLastPaymentFailed => 'शेवटचे पेमेंट अयशस्वी झाले';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'तुम्ही सुरक्षितपणे चेकआउट करण्याचा पुन्हा प्रयत्न करू शकता.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'प्रोमो कोड अद्याप सदस्यतांसाठी समर्थित नाहीत.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'निर्यात डाउनलोड करू शकलो नाही. पुन्हा प्रयत्न करा.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'मूळ अहवाल किंवा चाचणी परिणाम निवडा.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'निर्यातीची विनंती केली. रिफ्रेश करण्यासाठी \"स्थिती तपासा\" वर टॅप करा.';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'निर्यातीची विनंती करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'निर्यात तयार आहे. डाउनलोड URL उपलब्ध.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'निर्यात स्थिती तपासण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'खाते बंद करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiPrepareExport => 'निर्यात तयार करा';

  @override
  String get uiSaveExport => 'निर्यात वाचवा';

  @override
  String get uiPrepareExportAgain => 'पुन्हा निर्यात तयार करा';

  @override
  String get uiAllDates => 'सर्व तारखा';

  @override
  String get uiPreparingAccountDetails => 'खाते तपशील तयार करत आहे';

  @override
  String get uiFamilyMemberProfiles => 'कुटुंब सदस्य प्रोफाइल';

  @override
  String get uiUploadedReports => 'अपलोड केलेले अहवाल';

  @override
  String get uiDownloadReady => 'डाउनलोड तयार';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'या डिव्हाइसवर सक्षम केलेल्या सूचनांचा अहवाल द्या';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'डिव्हाइस सेटिंग्ज उघडल्या. Doclyzer साठी सूचनांना अनुमती द्या, नंतर येथे परत या.';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'सूचना अजूनही बंद आहेत. त्यांना डिव्हाइस सेटिंग्जमध्ये अहवाल अद्यतने प्राप्त करण्याची अनुमती द्या.';

  @override
  String get uiPreferencesSaved => 'प्राधान्ये जतन केली';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'तुमची खाते निवड जतन केली गेली, परंतु या डिव्हाइसने मार्केटिंग पुशसाठी नोंदणी करणे पूर्ण केले नाही. या डिव्हाइसवर विपणन अवरोधित राहते; सूचना परवानगी तपासा आणि पुन्हा सेव्ह करण्याचा प्रयत्न करा.';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'तुमची खाते निवड सेव्ह झाली. हे डिव्हाइस अद्याप त्याच्या स्थानिक प्राधान्याची पुष्टी करू शकले नाही, परंतु खाते स्तरावर विपणन अवरोधित राहिले आहे.';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'तुमची खाते निवड जतन केली गेली, परंतु हे डिव्हाइस मार्केटिंग पुश सक्षम करू शकले नाही. सूचना परवानगी तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'जतन करण्यात खूप वेळ लागला. तुमचे कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiReportReadyForReview => 'पुनरावलोकनासाठी अहवाल तयार आहे';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'तुमचे परिणाम तपासण्यासाठी तयार आहेत तेव्हा जाणून घ्या.';

  @override
  String get uiUploadUpdates => 'अद्यतने अपलोड करा';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'अपलोडकडे लक्ष देणे आवश्यक असल्यास संदेश मिळवा.';

  @override
  String get uiSharedLinkReminders => 'सामायिक लिंक स्मरणपत्रे';

  @override
  String get uiHearWhenALinkIsAboutTo => 'लिंक कालबाह्य होणार आहे तेव्हा ऐका.';

  @override
  String get uiSecurityAlerts => 'सुरक्षा सूचना';

  @override
  String get uiRequiredForAccountSafety => 'खात्याच्या सुरक्षिततेसाठी आवश्यक.';

  @override
  String get uiComplianceNotices => 'अनुपालन सूचना';

  @override
  String get uiRequiredAccountInformation => 'आवश्यक खाते माहिती.';

  @override
  String get uiMarketingPushNotifications => 'विपणन पुश सूचना';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ऑफर आणि घोषणा. ही निवड सेव्ह केल्याने ती या डिव्हाइसवर देखील लागू होते.';

  @override
  String get uiProductUpdates => 'उत्पादन अद्यतने';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'Doclyzer बद्दल पर्यायी बातम्या.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'सर्व्हरशी कनेक्ट करू शकत नाही. कृपया तुमचे इंटरनेट किंवा API सर्व्हर तपासा.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'तुमचे खाते पुनरावलोकनाधीन असताना प्रोफाइल अपडेट्स तात्पुरते अनुपलब्ध असतात.';

  @override
  String get uiUse100CharactersOrFewer => '100 किंवा कमी वर्ण वापरा';

  @override
  String get uiAddProfile => 'प्रोफाइल जोडा';

  @override
  String get uiCreateProfile => 'प्रोफाइल तयार करा';

  @override
  String get uiUpdateTheirDetails => 'त्यांचे तपशील अपडेट करा';

  @override
  String get uiWhoIsThisProfileFor => 'हे प्रोफाइल कोणासाठी आहे?';

  @override
  String get uiNotSelected => 'निवडले नाही';

  @override
  String get uiEnterAReferralCode => 'रेफरल कोड एंटर करा.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'रेफरल लागू केले. ईमेल पडताळणीनंतर बोनस अनलॉक होतो.';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'रेफरल लागू केले. बोनस क्रेडिट्स तयार आहेत.';

  @override
  String get uiApplyCode => 'कोड लागू करा';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'तुम्ही तुमचा स्वतःचा रेफरल कोड लागू करू शकत नाही.';

  @override
  String get uiReferralCodeIsInvalid => 'रेफरल कोड अवैध आहे.';

  @override
  String get uiFailedToApplyReferralCode => 'रेफरल कोड लागू करण्यात अयशस्वी.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'रेफरल कोड लागू करण्यात अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get uiThisDevice => 'हे उपकरण';

  @override
  String get uiSignedInDevice => 'साइन इन केलेले डिव्हाइस';

  @override
  String get uiUnknownDevice => 'अज्ञात उपकरण';

  @override
  String get uiRevokeAndLogOut => 'मागे घ्या आणि लॉग आउट करा';

  @override
  String get uiRevokeSessionca8440 => 'सत्र मागे घ्या';

  @override
  String get uiEnterYourCurrentPassword => 'तुमचा सध्याचा पासवर्ड टाका';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'अप्परकेस, लोअरकेस, एक संख्या आणि विशेष वर्णांसह किमान 8 वर्ण वापरा';

  @override
  String get uiChooseADifferentPassword => 'वेगळा पासवर्ड निवडा';

  @override
  String get uiNewPasswordsDoNotMatch => 'नवीन पासवर्ड जुळत नाहीत';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'तुम्ही सर्व उपलब्ध अपलोड क्रेडिट्स वापरल्या आहेत. अधिक जोडण्यासाठी योजना आणि क्रेडिट्सला भेट द्या.';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'Doclyzer साठी सूचना अक्षम केल्या आहेत. अहवाल तयार आणि खाते अद्यतनांना अनुमती देण्यासाठी डिव्हाइस सेटिंग्ज उघडा. जोपर्यंत तुम्ही ते निवडले नाही तोपर्यंत विपणन बंद राहते.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'या डिव्हाइसवर अहवाल तयार आणि खाते अद्यतने मिळवा. जोपर्यंत तुम्ही ते निवडले नाही तोपर्यंत विपणन बंद राहते.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'या डिव्हाइससाठी सूचना बंद आहेत. अहवाल-तयार आणि खाते अद्यतने प्राप्त करण्यासाठी सेटिंग्ज उघडा.';

  @override
  String get uiBlockedExpiredRevoked => 'अवरोधित (कालबाह्य / रद्द)';

  @override
  String get uiFailedToLoadPolicy => 'धोरण लोड करण्यात अयशस्वी';

  @override
  String get uiUploadPaused => 'अपलोड थांबवले';

  @override
  String get uiSevenDays => '7 दिवस';

  @override
  String get uiThirtyDays => '30 दिवस';

  @override
  String get uiNinetyDays => '90 दिवस';

  @override
  String get uiUploadingAClearReport => 'स्पष्ट अहवाल अपलोड करत आहे';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'PDF, फोटो आणि एकाधिक पृष्ठे';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'पीडीएफ निवडा किंवा प्रत्येक पृष्ठाचे स्पष्ट फोटो घ्या. संपूर्ण पृष्ठ फ्रेममध्ये ठेवा, चकाकी टाळा आणि विश्लेषण करण्यापूर्वी पृष्ठ क्रम तपासा. तुम्ही मूळ विरुद्ध काढलेली मूल्ये दुरुस्त करू शकता.';

  @override
  String get uiCorrectingAResult => 'निकाल दुरुस्त करत आहे';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'मूळ विरुद्ध मूल्यांचे पुनरावलोकन करा';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'अहवाल उघडा, प्रत्येक काढलेल्या चाचणीचे मूळ विरुद्ध पुनरावलोकन करा आणि चुकीचे वाचलेले कोणतेही मूल्य, एकक किंवा तारीख दुरुस्त करा. आपण ट्रेंडवर अवलंबून राहण्यापूर्वी अपुष्ट परिणाम तपासले पाहिजेत.';

  @override
  String get uiManagingFamilyRecords => 'कौटुंबिक नोंदी व्यवस्थापित करणे';

  @override
  String get uiProfilesAccessAndPermissions => 'प्रोफाइल, प्रवेश आणि परवानग्या';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'प्रोफाइल तयार करण्यासाठी आणि स्विच करण्यासाठी कुटुंब वापरा. रिपोर्ट अपलोड किंवा शेअर करण्यापूर्वी निवडलेल्या व्यक्तीची तपासणी करा. तुम्ही प्रवेश करण्यासाठी अधिकृत आहात फक्त रेकॉर्ड व्यवस्थापित करा.';

  @override
  String get uiSharingAndRevokingLinks => 'दुवे सामायिक करणे आणि रद्द करणे';

  @override
  String get uiControlTheRecordsYouShare =>
      'तुम्ही शेअर करत असलेले रेकॉर्ड नियंत्रित करा';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'तुम्हाला शेअर करायचे असलेले अहवाल किंवा परिणाम निवडा, एक्सपायरी आणि ऍक्सेस कोडचे पुनरावलोकन करा, त्यानंतर लिंक आणि कोड स्वतंत्रपणे पाठवा. यापुढे प्रवेशाची आवश्यकता नसताना सामायिक केलेल्या दुव्यांमधून सक्रिय दुवा मागे घ्या.';

  @override
  String get uiInformationYouProvide => 'तुम्ही दिलेली माहिती';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'खाते तपशील आणि कौटुंबिक प्रोफाइल ओळखतात की तुम्ही कोणाचे रेकॉर्ड व्यवस्थापित करता. अपलोड केलेल्या दस्तऐवजांमध्ये संवेदनशील आरोग्य माहिती असू शकते.';

  @override
  String get uiSharingControls => 'सामायिकरण नियंत्रणे';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'प्रत्येक दुव्याची सामग्री, कालबाह्यता आणि प्रवेश सेटिंग्जचे पुनरावलोकन करा. तुमच्या खाते सेटिंग्जमधून सक्रिय लिंक व्यवस्थापित करा.';

  @override
  String get uiExportAndAccountChoices => 'निर्यात आणि खाते निवड';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'रेकॉर्ड निर्यात करण्यासाठी सेटिंग्ज वापरा किंवा खाते हटवण्याची विनंती सुरू करा. धारणा तपशील संपूर्ण पॉलिसीमध्ये आहेत.';

  @override
  String get uiEducationalScope => 'शैक्षणिक व्याप्ती';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'डॉक्लायझर अहवाल आयोजित करते आणि कालांतराने परिणाम दाखवते. शैक्षणिक स्पष्टीकरण वैद्यकीय सल्ला किंवा निदान नाही.';

  @override
  String get uiReviewYourRecords => 'तुमच्या नोंदींचे पुनरावलोकन करा';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'मूळ अहवालाच्या तुलनेत काढलेली मूल्ये, एकके आणि तारखा तपासा. तुमच्या परिणामांबद्दल आरोग्यसेवा व्यावसायिकांना विचारा.';

  @override
  String get uiManageAndShareResponsibly =>
      'व्यवस्थापित करा आणि जबाबदारीने शेअर करा';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'फक्त तुम्ही प्रवेश करण्यासाठी अधिकृत असलेले रेकॉर्ड व्यवस्थापित करा. शेअर करण्यापूर्वी निवडलेली माहिती आणि प्राप्तकर्ता तपासा.';

  @override
  String get uiPrivacyPolicy7ceacd => 'गोपनीयता धोरण';

  @override
  String get uiTermsOfUse8a069e => 'वापरण्याच्या अटी';

  @override
  String get uiOpenPrivacyControls => 'गोपनीयता नियंत्रणे उघडा';

  @override
  String get uiGetHelpWithTheApp => 'ॲपची मदत घ्या';

  @override
  String get uiExportYourDataInAccountSettings =>
      'खाते सेटिंग्जमध्ये तुमचा डेटा निर्यात करा';

  @override
  String get uiYOURDATACHOICES => 'तुमचा डेटा आणि निवडी';

  @override
  String get uiUSINGDOCLYZER => 'डॉक्लायझर वापरणे';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'तुम्ही Doclyzer मध्ये ठेवलेली\nमाहिती समजून घ्या.';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'ॲपच्या भूमिकेची\nस्पष्ट समज.';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name वरून $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · नवीनतम $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'ही लायब्ररी सुरू करण्यासाठी $name साठी अहवाल अपलोड करा.';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP पत्ता: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'साइन इन केले: $date';
  }

  @override
  String get uiUnknown => 'अज्ञात';

  @override
  String uiResultsFor(String name) {
    return '$name साठी परिणाम';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count लॅब पॅरामीटर्स ट्रॅक केले';
  }

  @override
  String uiSampledDate(String date) {
    return 'नमुना $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'संकलन तारीख: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'लॅब श्रेणी: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI ने ही श्रेणी $range म्हणून वाचली. मुद्रित मजकूर: $printed. या तुलनेवर अवलंबून राहण्यापूर्वी मूळ अहवाल तपासा.';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount तयार';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count क्रेडिट्स';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'या खात्यावर रेफरल कोड आधीच लागू केला गेला आहे.';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ॲप लॉक चालू करण्यापूर्वी डिव्हाइस पासकोड सेट करा.';

  @override
  String get uiLanguagePreferenceNotSaved => 'भाषा प्राधान्य जतन केले नाही.';

  @override
  String get uiExportUnavailable => 'निर्यात अनुपलब्ध';

  @override
  String get uiUnreadableImage => 'न वाचता येणारी प्रतिमा';

  @override
  String uiStatusWithValue(String status) {
    return 'स्थिती: $status';
  }

  @override
  String get uiPending => 'प्रलंबित';

  @override
  String get uiCompleted => 'पूर्ण झाले';

  @override
  String get uiFailed => 'अयशस्वी';

  @override
  String get uiInactive => 'निष्क्रिय';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'तुमचे अहवाल आणि प्रोफाइल ठेवण्यासाठी $date पूर्वी पुनर्संचयित करा.';
  }

  @override
  String get uiThirtyDayDeadline => '30 दिवसांची अंतिम मुदत';

  @override
  String uiWhatsAffected(String details) {
    return 'काय प्रभावित आहे: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'शेवटचे अपडेट: $date वर $time';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename वर्तमान प्रोफाइलऐवजी $name अंतर्गत दिसेल.';
  }

  @override
  String get uiOneVerifiedResult => '1 सत्यापित निकाल जतन केला.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count सत्यापित परिणाम जतन केले.';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'प्रोफाइल स्विच करण्यात अक्षम. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'संकलित: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'अपलोड केल्याची तारीख $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount ने वाढले';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount ने कमी';
  }

  @override
  String get uiPercentagePoints => 'टक्केवारी गुण';

  @override
  String uiTestValuesCount(String count) {
    return 'चाचणी मूल्ये ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'प्रक्रियेदरम्यान AI द्वारे तपासलेले मूल्य. मूळ OCR: $value. अहवालाविरुद्ध याची पुष्टी करा.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return 'आधीच $name मध्ये अहवाल द्या';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return '$name वर अहवाल जोडला';
  }

  @override
  String uiAddedOn(String date) {
    return '$date जोडले';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max अहवालांचा $current वापरणे.';
  }

  @override
  String get uiNeedHelp => 'मदत हवी आहे?';

  @override
  String get uiEnabled => 'सक्षम केले';

  @override
  String get uiEnable => 'सक्षम करा';

  @override
  String get uiSubscribe => 'सदस्यता घ्या';

  @override
  String get uiApplying => 'अर्ज करत आहे';

  @override
  String get uiCheckStatus => 'स्थिती तपासा';

  @override
  String get uiEditProfile => 'प्रोफाइल संपादित करा';

  @override
  String get uiSaveChanges => 'बदल जतन करा';

  @override
  String get uiOptional => 'ऐच्छिक';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ऑर्डर $orderId सलोख्याची वाट पाहत आहे. स्थिती स्पष्ट होईपर्यंत खरेदीला विराम दिला आहे.';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'मासिक योजना - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'क्रेडिट पॅक - $name';
  }

  @override
  String get uiUnreadable => 'वाचता येत नाही';

  @override
  String uiLatestValue(String value) {
    return 'नवीनतम: $value';
  }

  @override
  String get uiEarlier => 'तत्पूर्वी';

  @override
  String get uiLater => 'नंतर';

  @override
  String get uiViewed => 'पाहिले';

  @override
  String get uiBlocked => 'अवरोधित';

  @override
  String get uiCapped => 'कॅप्ड';

  @override
  String uiLastChange(String label) {
    return 'शेवटचा बदल: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'शेवटचा बदल: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'गिफ्ट व्हाउचर लागू केले. $credits क्रेडिट जोडले.';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'मूळ अद्याप जतन करू शकलो नाही. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'मागे घेण्यात अयशस्वी: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'माझा Doclyzer रेफरल कोड $code: $link वापरा';
  }

  @override
  String get uiAMomentAgo => 'काही क्षणापूर्वी';

  @override
  String uiMinutesAgo(String count) {
    return '$count मिनिटापूर्वी';
  }

  @override
  String get uiOneHourAgo => '1 तासापूर्वी';

  @override
  String uiHoursAgo(String count) {
    return '$count तासांपूर्वी';
  }

  @override
  String get uiToday => 'आज';

  @override
  String get uiYesterday => 'काल';

  @override
  String get uiOneDayAgo => '1 दिवसापूर्वी';

  @override
  String uiDaysAgo(String count) {
    return '$count दिवसांपूर्वी';
  }

  @override
  String get uiOneWeekAgo => '1 आठवड्यापूर्वी';

  @override
  String uiWeeksAgo(String count) {
    return '$count आठवड्यांपूर्वी';
  }

  @override
  String get uiOneMonthAgo => '1 महिन्यापूर्वी';

  @override
  String uiMonthsAgo(String count) {
    return '$count महिन्यांपूर्वी';
  }

  @override
  String get uiOneYearAgo => '1 वर्षापूर्वी';

  @override
  String uiYearsAgo(String count) {
    return '$count वर्षांपूर्वी';
  }

  @override
  String get uiInOneDay => '1 दिवसात';

  @override
  String uiInDays(String count) {
    return '$count दिवसांमध्ये';
  }

  @override
  String uiInMinutes(String count) {
    return '$count मि मध्ये';
  }

  @override
  String get uiInOneHour => '1 तासात';

  @override
  String uiInHours(String count) {
    return '$count तासांमध्ये';
  }

  @override
  String get uiMissingExtractedTestName =>
      'काढलेल्या निकालातून चाचणीचे नाव गहाळ आहे.';

  @override
  String get uiMissingCapturedLabRange =>
      'या चाचणीसाठी कोणतीही प्रयोगशाळा संदर्भ श्रेणी कॅप्चर केलेली नाही.';

  @override
  String get uiNonNumericExtractedValue =>
      'काढलेले मूल्य साधी संख्या नाही. मूळ अहवालात ते तपासा.';

  @override
  String get uiLabFlagRangeConflict =>
      'लॅब ध्वज मुद्रित श्रेणीशी विरोधाभास आहे. मूळ अहवाल तपासा.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'मूळ अहवालात काढलेले मूल्य, मुद्रित श्रेणी किंवा प्रयोगशाळेतील ध्वज तपासणे आवश्यक आहे.';

  @override
  String get uiInitialEntitlement => 'प्रारंभिक हक्क';

  @override
  String get uiCreditPackPurchase => 'क्रेडिट पॅक खरेदी';

  @override
  String get uiSubscriptionUpgrade => 'सदस्यता अपग्रेड';

  @override
  String get uiPlanDowngrade => 'योजना अवनत करा';

  @override
  String get uiAdminAdjustment => 'प्रशासन समायोजन';

  @override
  String get uiSystemReconciliation => 'सिस्टम सलोखा';

  @override
  String get uiReferralInviteBonus => 'रेफरल आमंत्रण बोनस';

  @override
  String get uiReferralAnalysisMilestone => 'रेफरल विश्लेषण मैलाचा दगड';

  @override
  String get uiReferralPurchaseMilestone => 'रेफरल खरेदी मैलाचा दगड';

  @override
  String get uiFreePromoCreditPack => 'मोफत प्रोमो क्रेडिट पॅक';

  @override
  String get uiGiftVoucherRedeemed => 'गिफ्ट व्हाउचर रिडीम केले';

  @override
  String get uiNotYetChanged => 'अजून बदलला नाही';

  @override
  String get uiCannotReachServer =>
      'सर्व्हरपर्यंत पोहोचण्यात अक्षम. तुमचे कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiInvalidEmailOrPassword =>
      'अवैध ईमेल किंवा पासवर्ड. तुमचे तपशील तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiTooManyAuthAttempts =>
      'बरेच प्रयत्न. काही मिनिटे थांबा आणि पुन्हा प्रयत्न करा.';

  @override
  String get uiEnterValidEmail => 'कृपया वैध ईमेल पत्ता प्रविष्ट करा.';

  @override
  String get uiPasswordRequirements =>
      'पासवर्ड किमान 8 वर्णांचा असणे आवश्यक आहे आणि त्यात अप्परकेस, लोअरकेस, एक संख्या आणि एक विशेष वर्ण असणे आवश्यक आहे.';

  @override
  String get uiAccountWithEmailExists =>
      'या ईमेलसह खाते आधीपासून अस्तित्वात आहे. साइन इन करा किंवा वेगळा ईमेल वापरा.';

  @override
  String get uiUploadedStatus => 'अपलोड केले';

  @override
  String uiSupportAction(String action) {
    return 'क्रिया: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'सहसंबंध आयडी: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'क्लायंट ॲक्शन आयडी: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'त्रुटी कोड: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'तुमचे सत्र संपले. पुन्हा साइन इन करा.';

  @override
  String get uiProfileLimitReached =>
      'तुमची योजना प्रोफाइल मर्यादा गाठली आहे. अधिक जोडण्यासाठी योजना आणि क्रेडिटचे पुनरावलोकन करा.';

  @override
  String get uiCorrectionConflictReload =>
      'हा निकाल इतरत्र बदलला. अहवाल दुरुस्त करण्यापूर्वी रीलोड करा.';

  @override
  String get uiSeePlanCreditsOptions =>
      'उपलब्ध पर्यायांसाठी योजना आणि क्रेडिट पहा.';

  @override
  String get uiShareLinkLimitHelp =>
      'तुम्ही सक्रिय शेअर-लिंक मर्यादा गाठली आहे.';

  @override
  String get uiScopedExportUnavailable =>
      'व्याप्ती निर्यात अनुपलब्ध आहे. नंतर पुन्हा प्रयत्न करा.';

  @override
  String get uiRestorationUnavailable =>
      'जीर्णोद्धार अनुपलब्ध आहे. नंतर पुन्हा प्रयत्न करा.';

  @override
  String get uiExportRequestNotFound =>
      'निर्यात विनंती आढळली नाही. नवीन निर्यातीची विनंती करा.';

  @override
  String get uiClosureConfirmationRequired =>
      'सुरू ठेवण्यासाठी खाते बंद केल्याची पुष्टी करा.';

  @override
  String get uiCurrentPasswordIncorrect => 'सध्याचा पासवर्ड चुकीचा आहे.';

  @override
  String get uiLaboratories => 'प्रयोगशाळा';

  @override
  String get uiUnlock => 'अनलॉक करा';
}
