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
}
