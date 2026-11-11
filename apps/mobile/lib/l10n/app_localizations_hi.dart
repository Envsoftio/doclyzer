// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get trendLatestResult => 'नवीनतम परिणाम';

  @override
  String get trendPreviousResult => 'पिछला परिणाम';

  @override
  String get trendSourceUnit => 'इस सीमा की मूल इकाई';

  @override
  String get trendNoSavedResults =>
      'इस जाँच के लिए अभी कोई सहेजा गया परिणाम नहीं है।';

  @override
  String get trendNoPlottableResults =>
      'संग्रह की तारीख वाला कोई सटीक संख्यात्मक परिणाम ग्राफ़ में नहीं दिखाया जा सकता।';

  @override
  String get trendOneResultHelp =>
      'एक परिणाम सहेजा गया है। बदलाव देखने के लिए एक और रिपोर्ट जोड़ें।';

  @override
  String get trendMultipleResultsHelp =>
      'तारीखें बीते समय के अनुसार दिखाई गई हैं। मान देखने के लिए बिंदु पर टैप करें।';

  @override
  String trendUnplottedNote(int count) {
    return 'संग्रह की तारीख या सटीक संख्यात्मक मान न होने के कारण $count परिणाम ग्राफ़ में नहीं दिखाए जा सके।';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$testName का ग्राफ़, $count परिणामों के साथ';
  }

  @override
  String get trendDateReview =>
      'संग्रह की तारीख पहले किए गए निष्कर्षण से है। मूल रिपोर्ट में जाँचें।';

  @override
  String get trendNotPlotted => 'ग्राफ़ में नहीं दिखाया गया';

  @override
  String get trendExactNumberUnavailable => 'परिणाम सटीक संख्या नहीं है';

  @override
  String get preferredLanguage => 'पसंदीदा भाषा';

  @override
  String get descriptionLanguage => 'विवरण की भाषा';

  @override
  String get languageHelp =>
      'ऐप के शब्द और रिपोर्ट के विवरण इस भाषा में दिखेंगे। आप किसी भी विवरण की भाषा कभी भी बदल सकते हैं।';

  @override
  String get languageSaveFailed =>
      'भाषा सेव नहीं हो सकी। कृपया फिर कोशिश करें।';

  @override
  String get translationLoading => 'अनुवादित विवरण तैयार हो रहा है…';

  @override
  String get translationFailed =>
      'अनुवाद उपलब्ध नहीं है। फिर कोशिश करें या English चुनें।';

  @override
  String get translationNote =>
      'सेव किए गए अंग्रेज़ी विवरण का AI अनुवाद। सही परिणामों के लिए मूल रिपोर्ट देखें।';

  @override
  String get sourceChanged =>
      'रिपोर्ट बदल गई है। नया विवरण देखने के लिए इसे फिर लोड करें।';

  @override
  String get signupTitle => 'अपनी रिपोर्ट समझने की\nशुरुआत करें।';

  @override
  String get signupIntro =>
      'अपनी रिपोर्ट और परिणाम एक जगह रखने के लिए खाता बनाएँ।';

  @override
  String get loginIntro =>
      'अपनी स्वास्थ्य रिपोर्ट देखने और समझने के लिए साइन इन करें।';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get referralCode => 'रेफ़रल कोड (वैकल्पिक)';

  @override
  String get createAccount => 'खाता बनाएँ';

  @override
  String get alreadyAccount => 'पहले से खाता है? ';

  @override
  String get noAccount => 'खाता नहीं है? ';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get needHelp => 'मदद चाहिए?';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get invalidCredentialsInput => 'सही ईमेल पता और पासवर्ड दर्ज करें';

  @override
  String get signupFailed => 'खाता नहीं बन सका';

  @override
  String get loginFailed =>
      'साइन इन नहीं हो सका। अपना इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get genericError => 'कुछ गड़बड़ हुई। कृपया फिर कोशिश करें।';

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट हो गई';

  @override
  String get changePhoto => 'प्रोफ़ाइल फ़ोटो बदलें';

  @override
  String get gallery => 'गैलरी से चुनें';

  @override
  String get camera => 'फ़ोटो लें';

  @override
  String get photoUpdated => 'प्रोफ़ाइल फ़ोटो अपडेट हो गई';

  @override
  String get photoFailed => 'फ़ोटो अपडेट नहीं हो सकी। कृपया फिर कोशिश करें।';

  @override
  String get yourAccount => 'आपका खाता';

  @override
  String get profileLoading => 'प्रोफ़ाइल लोड हो रही है…';

  @override
  String get profileLoadAction => 'प्रोफ़ाइल लोड करने के लिए टैप करें';

  @override
  String get accountData => 'खाता और डेटा';

  @override
  String get personalInformation => 'व्यक्तिगत जानकारी';

  @override
  String get notificationPreferences => 'सूचनाओं की सेटिंग';

  @override
  String get privacySecurity => 'निजता और सुरक्षा';

  @override
  String get sharedLinks => 'शेयर किए गए लिंक';

  @override
  String get exportData => 'अपना डेटा डाउनलोड करें';

  @override
  String get additionalAccount => 'खाते की अन्य जानकारी';

  @override
  String get additionalAccountHelp =>
      'परिवार, प्लान, रेफ़रल, सत्र और ऐप का रूप';

  @override
  String get familyProfiles => 'परिवार की प्रोफ़ाइल';

  @override
  String get manageProfiles => 'प्रोफ़ाइल बदलें या प्रबंधित करें';

  @override
  String get planCredits => 'प्लान और क्रेडिट';

  @override
  String get viewPlanBalance => 'अपना प्लान और बचा हुआ बैलेंस देखें';

  @override
  String get balanceLoading => 'बैलेंस लोड हो रहा है…';

  @override
  String get referFriends => 'दोस्तों को आमंत्रित करें';

  @override
  String get referralRewards => 'निमंत्रण और रेफ़रल के लाभ';

  @override
  String get activeSessions => 'सक्रिय सत्र';

  @override
  String get appearance => 'ऐप का रूप';

  @override
  String get system => 'डिवाइस के अनुसार';

  @override
  String get light => 'हल्का';

  @override
  String get dark => 'गहरा';

  @override
  String get helpSupport => 'मदद और सहायता';

  @override
  String get aboutDoclyzer => 'Doclyzer के बारे में';

  @override
  String get aboutCopy =>
      'हर व्यक्ति की रिपोर्ट अलग रखें और निकाले गए परिणामों को मूल रिपोर्ट से मिलाकर जाँचें।';

  @override
  String get logOut => 'लॉग आउट करें';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get saveChanges => 'बदलाव सेव करें';

  @override
  String get accountRestricted => 'खाते पर रोक लगी है';

  @override
  String get photoUploading => 'फ़ोटो अपलोड हो रही है…';

  @override
  String get changePhotoShort => 'फ़ोटो बदलें';

  @override
  String get accountDetails => 'खाते की जानकारी';

  @override
  String get emailHelp =>
      'खाते में साइन इन करने के लिए इस्तेमाल होता है। इसे बदलने के लिए सहायता टीम से संपर्क करें।';

  @override
  String get accountName => 'खाते का नाम';

  @override
  String get belowLabRange => 'इस लैब की संदर्भ सीमा से कम';

  @override
  String get withinLabRange => 'इस लैब की संदर्भ सीमा के भीतर';

  @override
  String get aboveLabRange => 'इस लैब की संदर्भ सीमा से अधिक';

  @override
  String get cannotCompare => 'लैब की संदर्भ सीमा से तुलना संभव नहीं है';

  @override
  String get understandResult => 'इस परिणाम को समझें';

  @override
  String get yourResult => 'आपका परिणाम';

  @override
  String get labReferenceRange => 'लैब की संदर्भ सीमा';

  @override
  String get resultUnavailable => 'इस परिणाम में उपलब्ध नहीं है';

  @override
  String get sampleDate => 'नमूना लेने की तारीख';

  @override
  String get resultHistory => 'पिछले परिणाम';

  @override
  String get originalReport => 'मूल रिपोर्ट';

  @override
  String get reviewValue => 'मान जाँचें';

  @override
  String get understandYourResult => 'अपने परिणाम को समझें';

  @override
  String get educationalContext =>
      'इस परिणाम पर चर्चा करने में मदद के लिए सामान्य जानकारी।';

  @override
  String get explanationUnavailable => 'विवरण उपलब्ध नहीं है';

  @override
  String get explanationFailed => 'विवरण अभी लोड नहीं हो सका।';

  @override
  String get checkOriginal => 'मूल रिपोर्ट जाँचें';

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get aiGuidance => 'AI से तैयार जानकारी';

  @override
  String get understandingResult => 'इस परिणाम को समझना';

  @override
  String get possibleMeaning => 'इसका क्या अर्थ हो सकता है';

  @override
  String get whatTestMeasures => 'यह जाँच क्या मापती है';

  @override
  String get suggestedNextStep => 'आगे क्या करें';

  @override
  String get resultLimitations => 'इस परिणाम से क्या पता नहीं चलता';

  @override
  String get oneResultLimit =>
      'केवल एक परिणाम से किसी बीमारी का निदान या लक्षणों का कारण तय नहीं किया जा सकता।';

  @override
  String get detailsToCheck => 'इन बातों की जाँच करें';

  @override
  String get lifestyleFactors => 'जीवनशैली से जुड़ी बातें जिन पर चर्चा करें';

  @override
  String get insightContext =>
      'यह मान आपकी रिपोर्ट से निकाला गया है। नाम, मान, इकाई या सीमा गलत लगे तो मूल रिपोर्ट जाँचें। AI के विवरण सामान्य जानकारी के लिए हैं और यह तय नहीं कर सकते कि आपको किस इलाज की ज़रूरत है।';

  @override
  String get yourProfile => 'आपकी प्रोफ़ाइल';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get moveReport => 'रिपोर्ट दूसरी प्रोफ़ाइल में भेजें';

  @override
  String get gotIt => 'समझ गए';

  @override
  String get reportDetails => 'रिपोर्ट की जानकारी';

  @override
  String get shareReport => 'रिपोर्ट शेयर करें';

  @override
  String get moreReportActions => 'रिपोर्ट के अन्य विकल्प';

  @override
  String get attemptHistory => 'प्रक्रिया के प्रयास';

  @override
  String get compareReports => 'रिपोर्ट की तुलना करें';

  @override
  String get readParsedReport => 'निकाला गया पाठ पढ़ें';

  @override
  String get moveRecycle => 'रीसायकल बिन में भेजें';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get reportSummary => 'रिपोर्ट का सारांश';

  @override
  String get updateSummary => 'सारांश अपडेट करें';

  @override
  String get summaryLoading => 'आपके परिणामों का सरल विवरण तैयार हो रहा है…';

  @override
  String get checkSummary => 'सारांश देखें';

  @override
  String get summaryFailed =>
      'सारांश तैयार नहीं हो सका। आप फिर कोशिश कर सकते हैं।';

  @override
  String get summaryPlaceholder => 'मुख्य परिणामों का सरल विवरण यहाँ दिखेगा।';

  @override
  String get retrySummary => 'सारांश फिर तैयार करें';

  @override
  String get generateSummary => 'सारांश तैयार करें';

  @override
  String get loadingResults => 'रिपोर्ट के परिणाम लोड हो रहे हैं…';

  @override
  String get somethingWrong => 'कुछ गड़बड़ हुई';

  @override
  String get viewTrends => 'समय के साथ बदलाव देखें';

  @override
  String get originalFile => 'मूल फ़ाइल';

  @override
  String get testValues => 'जाँच के मान';

  @override
  String get summary => 'सारांश';

  @override
  String get checkStatus => 'स्थिति देखें';

  @override
  String get viewOriginal => 'मूल देखें';

  @override
  String get verifiedResults => 'जाँचे गए परिणाम';

  @override
  String get resultTapHelp =>
      'जाँच क्या मापती है, यह समझने के लिए परिणाम पर टैप करें।';

  @override
  String get reviewResults => 'निकाले गए परिणाम जाँचें';

  @override
  String get keepFile => 'फिर भी फ़ाइल रखें';

  @override
  String get patientDetails => 'मरीज़ की जानकारी';

  @override
  String get name => 'नाम';

  @override
  String get age => 'उम्र';

  @override
  String get gender => 'लिंग';

  @override
  String get bookingId => 'बुकिंग आईडी';

  @override
  String get sampleCollection => 'नमूना संग्रह';

  @override
  String get labDetails => 'लैब की जानकारी';

  @override
  String get labName => 'लैब का नाम';

  @override
  String get address => 'पता';

  @override
  String get phone => 'फ़ोन';

  @override
  String get location => 'स्थान';

  @override
  String get belowRange => 'सीमा से कम';

  @override
  String get aboveRange => 'सीमा से अधिक';

  @override
  String get withinRange => 'दी गई सीमा के भीतर';

  @override
  String get rangeUnclear => 'सीमा स्पष्ट नहीं है';

  @override
  String get understandResultAction => 'इस परिणाम को समझें  →';

  @override
  String get parsedReport => 'रिपोर्ट से निकाला गया पाठ';

  @override
  String get reports => 'रिपोर्ट';

  @override
  String get trends => 'समय के साथ बदलाव';

  @override
  String get openingPage => 'पेज खुल रहा है';

  @override
  String get home => 'होम';

  @override
  String get family => 'परिवार';

  @override
  String get switchProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get currentProfile => 'मौजूदा प्रोफ़ाइल';

  @override
  String get viewProfile => 'यह प्रोफ़ाइल देखें';

  @override
  String get manageFamily => 'परिवार की प्रोफ़ाइल सँभालें';

  @override
  String get chooseProfile => 'प्रोफ़ाइल चुनें';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get homeTitle => 'रिपोर्ट समझें।\nसब एक जगह।';

  @override
  String get nextReportTitle => 'अपनी अगली रिपोर्ट\nयहाँ जोड़ें।';

  @override
  String get homeSubtitle => 'PDF, फ़ोटो और परिवार के रिकॉर्ड।';

  @override
  String get uploadReport => 'रिपोर्ट अपलोड करें';

  @override
  String get recentReport => 'हाल की रिपोर्ट';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get reportsUnavailable =>
      'रिपोर्ट उपलब्ध नहीं हैं। इंटरनेट जुड़ने पर फिर कोशिश करें।';

  @override
  String get emptyHomeTitle => 'अपने रिकॉर्ड की शुरुआत करें';

  @override
  String get emptyHomeHelp =>
      'अपने रिकॉर्ड एक जगह रखने के लिए पहली रिपोर्ट अपलोड करें।';

  @override
  String get uploadFirstReport => 'पहली रिपोर्ट अपलोड करें';

  @override
  String get latestResults => 'नए परिणाम';

  @override
  String get allTrends => 'सभी जाँचों के बदलाव';

  @override
  String get reviewedResultsHelp =>
      'जाँचे गए परिणाम उपलब्ध होने पर यहाँ दिखेंगे।';

  @override
  String get searchTests => 'जाँच खोजें';

  @override
  String get noHealthData =>
      'अभी कोई स्वास्थ्य डेटा नहीं है। अपने पुराने परिणाम देखने के लिए रिपोर्ट अपलोड करें।';

  @override
  String get noTestsFound => 'कोई जाँच नहीं मिली';

  @override
  String get shorterTestName => 'जाँच का छोटा नाम लिखकर खोजें।';

  @override
  String get clearSearch => 'खोज हटाएँ';

  @override
  String get unitUnavailable => 'इकाई उपलब्ध नहीं है';

  @override
  String get uploadingReport => 'रिपोर्ट अपलोड हो रही है…';

  @override
  String get organizingReport => 'आपकी रिपोर्ट तैयार हो रही है…';

  @override
  String get uploadAReport => 'एक रिपोर्ट अपलोड करें';

  @override
  String get uploadHelp =>
      'PDF या साफ़ फ़ोटो चुनें। सेव करने से पहले जानकारी जाँच सकते हैं।';

  @override
  String get chooseSource => 'फ़ाइल कहाँ से जोड़ें';

  @override
  String get uploadPdfImage => 'PDF या चित्र अपलोड करें';

  @override
  String get chooseReportFiles => 'अपनी फ़ाइलों से रिपोर्ट चुनें';

  @override
  String get selectReportPages => 'रिपोर्ट के एक या अधिक पेज चुनें';

  @override
  String get capturePage => 'पूरे पेज की फ़ोटो लें';

  @override
  String get supportedFormats => 'इन फ़ॉर्मैट में जोड़ें: PDF, JPG, PNG';

  @override
  String get confirmFile => 'जाँच लें कि आप यही फ़ाइल जोड़ना चाहते हैं।';

  @override
  String get addReport => 'रिपोर्ट जोड़ें';

  @override
  String get chooseDifferentFile => 'दूसरी फ़ाइल चुनें';

  @override
  String get uploadWait => 'इसमें थोड़ा समय लग सकता है। कृपया ऐप खुला रखें।';

  @override
  String get reportNeedsAttention => 'रिपोर्ट की जाँच ज़रूरी है';

  @override
  String get verifyBeforeSaving =>
      'निकाले गए परिणाम सेव करने से पहले उन्हें मूल रिपोर्ट से मिलाकर जाँचें।';

  @override
  String get viewVerifiedResults => 'जाँचे गए परिणाम देखें';

  @override
  String get viewOriginalReport => 'मूल रिपोर्ट देखें';

  @override
  String get viewReportStatus => 'रिपोर्ट की स्थिति देखें';

  @override
  String get viewResults => 'परिणाम देखें';

  @override
  String get viewOriginalFile => 'मूल फ़ाइल देखें';

  @override
  String get retryExtraction => 'परिणाम फिर निकालें';

  @override
  String get done => 'हो गया';

  @override
  String get duplicateReport => 'यह रिपोर्ट पहले से जुड़ी हुई लगती है';

  @override
  String get duplicateHelp => 'यह फ़ाइल आपकी रिपोर्ट में पहले से हो सकती है।';

  @override
  String get keepExisting => 'मौजूदा रिपोर्ट रखें';

  @override
  String get processAgain => 'PDF फिर पढ़ें';

  @override
  String get uploadNewCopy => 'नई कॉपी के रूप में अपलोड करें';

  @override
  String get reportLimitReached => 'रिपोर्ट की सीमा पूरी हो गई';

  @override
  String get reportLimitHelp => 'आपके प्लान में रिपोर्ट की सीमा पूरी हो गई है।';

  @override
  String get upgrade => 'प्लान बढ़ाएँ';

  @override
  String get back => 'वापस';

  @override
  String get uploadFailedTitle => 'रिपोर्ट अपलोड नहीं हो सकी';

  @override
  String get uploadFailed => 'अपलोड नहीं हुआ';

  @override
  String get retrySameFile => 'इसी फ़ाइल से फिर कोशिश करें';

  @override
  String get chooseAnotherFile => 'दूसरी फ़ाइल चुनें';

  @override
  String get aiDisclaimer =>
      'Doclyzer आपकी स्वास्थ्य रिपोर्ट व्यवस्थित करने और समझने में मदद करता है। यह जानकारी केवल समझ बढ़ाने के लिए है; यह चिकित्सकीय सलाह, निदान या इलाज नहीं है। चिकित्सकीय मार्गदर्शन के लिए हमेशा योग्य स्वास्थ्य पेशेवर से सलाह लें।';

  @override
  String collectedOn(String date) {
    return 'नमूना लिया गया: $date';
  }

  @override
  String uploadedOn(String date) {
    return 'अपलोड की तारीख: $date';
  }

  @override
  String labRangeValue(String range) {
    return 'लैब की संदर्भ सीमा: $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits क्रेडिट';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count रिपोर्ट',
      one: '1 रिपोर्ट',
      zero: 'कोई रिपोर्ट नहीं',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'रिपोर्ट लोड होने में ज़्यादा समय लग रहा है। इंटरनेट कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get summaryUpdateFailed =>
      'सारांश अभी अपडेट नहीं हो सका। सेव किया गया सारांश उपलब्ध है।';

  @override
  String get summaryCreateFailed =>
      'सारांश अभी तैयार नहीं हो सका। आपके परिणाम नीचे उपलब्ध हैं।';

  @override
  String get reassignFailed =>
      'रिपोर्ट दूसरी प्रोफ़ाइल में नहीं भेजी जा सकी। फिर कोशिश करें।';

  @override
  String get confirmRecycle => 'रीसायकल बिन में भेजें?';

  @override
  String get recycleHelp =>
      'आप 30 दिनों तक रिपोर्ट > रीसायकल बिन से यह रिपोर्ट वापस ला सकते हैं। इसके बाद यह हमेशा के लिए हट जाएगी।';

  @override
  String get reportRecycled => 'रिपोर्ट रीसायकल बिन में भेज दी गई';

  @override
  String get reportDeleteFailed => 'रिपोर्ट हट नहीं सकी। फिर कोशिश करें।';

  @override
  String get addProfileBeforeMove =>
      'यह रिपोर्ट भेजने से पहले परिवार की दूसरी प्रोफ़ाइल जोड़ें।';

  @override
  String get moveReportHelp =>
      'रिपोर्ट गलत प्रोफ़ाइल में जुड़ गई हो तो परिवार का सही सदस्य चुनें।';

  @override
  String get confirmMoveReport => 'यह रिपोर्ट दूसरी प्रोफ़ाइल में भेजें?';

  @override
  String get aboutSampleDates => 'नमूना लेने की तारीख के बारे में';

  @override
  String get multipleDatesHelp =>
      'इस रिपोर्ट में अलग-अलग तारीखों पर लिए गए नमूनों के परिणाम हैं। किसी परिणाम को खोलकर उसकी तारीख मूल रिपोर्ट से मिलाएँ।';

  @override
  String get missingDateHelp =>
      'नमूना लेने की तारीख वह दिन है जब नमूना लिया गया था। इस रिपोर्ट में भरोसेमंद तारीख नहीं मिली। यह अपलोड की तारीख से अलग है। तारीख जाँचने या सुधारने के लिए परिणाम खोलें।';

  @override
  String get uploading => 'अपलोड हो रहा है';

  @override
  String get waitingToProcess => 'प्रक्रिया शुरू होने का इंतज़ार है';

  @override
  String get readingReport => 'रिपोर्ट पढ़ी जा रही है';

  @override
  String get readyToReview => 'जाँचने के लिए तैयार';

  @override
  String get someResultsNeedReview => 'कुछ परिणामों की जाँच ज़रूरी है';

  @override
  String get couldNotReadReport => 'रिपोर्ट पढ़ी नहीं जा सकी';

  @override
  String get processingStopped => 'प्रक्रिया रुक गई';

  @override
  String get couldNotProcessReport => 'रिपोर्ट तैयार नहीं हो सकी';

  @override
  String get reportRefreshFailed =>
      'रिपोर्ट फिर लोड नहीं हो सकी। पिछला परिणाम दिखाया जा रहा है।';

  @override
  String get multipleSampleDates => 'नमूने अलग-अलग तारीखों पर लिए गए ';

  @override
  String get missingSampleDate => 'नमूना लेने की तारीख नहीं मिली ';

  @override
  String get reportAnalyzing =>
      'रिपोर्ट का विश्लेषण हो रहा है। आप इस स्क्रीन से जा सकते हैं; परिणाम तैयार होने पर दिखेंगे।';

  @override
  String get extractionIncompleteTitle =>
      'सभी परिणाम भरोसेमंद तरीके से नहीं निकाले जा सके';

  @override
  String get extractionIncompleteHelp =>
      'परिणाम निकालने की प्रक्रिया अधूरी रही। निकाले गए परिणाम सेव करने से पहले मूल रिपोर्ट से मिलाकर जाँचें।';

  @override
  String get verifiedRowsHelp =>
      'ये परिणाम मूल रिपोर्ट से मिलाकर जाँचे गए हैं। बाकी परिणामों की जाँच अभी ज़रूरी हो सकती है।';

  @override
  String get noTestValues =>
      'इस रिपोर्ट में जाँच के मान नहीं मिले। जानकारी देखने के लिए मूल फ़ाइल खोलें।';

  @override
  String get processingRetryHelp =>
      'प्रक्रिया पूरी होने से पहले रुक गई। आपकी फ़ाइल सेव है। फिर कोशिश करने का विकल्प चुनें।';

  @override
  String get resultsNeedCheck =>
      'कुछ परिणामों को मूल रिपोर्ट से मिलाकर जाँचना ज़रूरी है। आप नीचे दिए गए परिणाम जाँच सकते हैं।';

  @override
  String get readerModeHelp =>
      'आसानी से पढ़ने के लिए रिपोर्ट से निकाला गया पाठ रीडर मोड में उपलब्ध है।';

  @override
  String get aiRangeHelp =>
      'यह सीमा प्रक्रिया के दौरान AI ने पढ़ी है। मूल रिपोर्ट जाँचें।';

  @override
  String get checkResultHelp =>
      'इस परिणाम पर भरोसा करने से पहले इसे मूल रिपोर्ट से मिलाकर जाँचें।';

  @override
  String get preferredRangeHelp =>
      'लैब की दी गई श्रेणी से तुलना की गई है; जाँचें कि यह श्रेणी आप पर लागू होती है।';

  @override
  String get categoryComparisonHelp =>
      'इस तुलना में लैब की दी गई श्रेणी का इस्तेमाल किया गया है। जाँचें कि यह श्रेणी आप पर लागू होती है।';

  @override
  String get missingSavedResult =>
      'यह मान किसी सेव किए गए परिणाम से मेल नहीं खाता। मूल रिपोर्ट जाँचें या यह रिपोर्ट फिर लोड करें।';

  @override
  String get unreviewedTest =>
      'इस जाँच के लिए AI विवरण अभी उपलब्ध नहीं कराया गया है। मूल रिपोर्ट जाँचें और परिणाम पर अपने चिकित्सक से चर्चा करें।';

  @override
  String get unsafeResult =>
      'निकाला गया परिणाम स्पष्ट नहीं है, इसलिए भरोसेमंद विवरण देना संभव नहीं है। मूल रिपोर्ट जाँचें।';

  @override
  String get filterReports => 'रिपोर्ट फ़िल्टर करें';

  @override
  String get sortReports => 'रिपोर्ट का क्रम चुनें';

  @override
  String get recycleBin => 'रीसायकल बिन';

  @override
  String get healthHistory => 'स्वास्थ्य रिकॉर्ड';

  @override
  String get shareProfile => 'प्रोफ़ाइल शेयर करें';

  @override
  String get reportsUnavailableTitle => 'रिपोर्ट उपलब्ध नहीं हैं';

  @override
  String get reportsLoadFailed =>
      'रिपोर्ट लोड नहीं हो सकीं। इंटरनेट जुड़ने पर फिर कोशिश करें।';

  @override
  String get upload => 'अपलोड करें';

  @override
  String get reportsFor => 'इनकी रिपोर्ट';

  @override
  String get searchReports => 'रिपोर्ट या लैब खोजें';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get noReportsYet => 'अभी कोई रिपोर्ट नहीं है';

  @override
  String get noMatchingReports => 'आपकी खोज से मेल खाती रिपोर्ट नहीं मिली।';

  @override
  String get differentSearch => 'दूसरी जाँच, लैब या फ़िल्टर से खोजें।';

  @override
  String get clearFilters => 'खोज और फ़िल्टर हटाएँ';

  @override
  String get original => 'मूल';

  @override
  String get switchActiveProfile => 'सक्रिय प्रोफ़ाइल बदलें';

  @override
  String get switchProfileHelp =>
      'दूसरे व्यक्ति की रिपोर्ट देखें। अपलोड और समय के साथ बदलाव देखने के लिए सक्रिय प्रोफ़ाइल भी बदल जाएगी।';

  @override
  String get multipleCollectionDates => 'नमूने अलग-अलग तारीखों पर लिए गए';

  @override
  String get unknownCollectionDate => 'नमूना लेने की तारीख उपलब्ध नहीं है';

  @override
  String get profileLoadFailed =>
      'प्रोफ़ाइल लोड नहीं हो सकीं। कृपया फिर कोशिश करें।';

  @override
  String get pleaseTryAgain => 'कृपया फिर कोशिश करें।';

  @override
  String get deleteProfileConfirm => 'प्रोफ़ाइल हटाएँ?';

  @override
  String get deleteProfileHelp =>
      'यह प्रोफ़ाइल हट जाएगी। इससे जुड़ा डेटा भी प्रभावित होगा।';

  @override
  String get profileDeleteFailed =>
      'प्रोफ़ाइल हट नहीं सकी। कृपया फिर कोशिश करें।';

  @override
  String get addFamilyMember => 'परिवार का सदस्य जोड़ें';

  @override
  String get familyUnavailable => 'परिवार की प्रोफ़ाइल उपलब्ध नहीं हैं';

  @override
  String get familyIntro => 'हर व्यक्ति की रिपोर्ट और समय के साथ बदलाव अलग-अलग';

  @override
  String get noProfilesYet => 'अभी कोई प्रोफ़ाइल नहीं है';

  @override
  String get noProfilesHelp =>
      'अपनी या परिवार की रिपोर्ट व्यवस्थित रखने के लिए प्रोफ़ाइल जोड़ें।';

  @override
  String get yourFamily => 'आपका परिवार';

  @override
  String get upgradeProfiles => 'और प्रोफ़ाइल जोड़ने के लिए प्लान बढ़ाएँ';

  @override
  String get editProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get deleteProfile => 'प्रोफ़ाइल हटाएँ';

  @override
  String get active => 'सक्रिय';

  @override
  String get setActive => 'सक्रिय करें';

  @override
  String get viewReports => 'रिपोर्ट देखें';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get openSettings => 'सेटिंग खोलें';

  @override
  String get enableNotifications => 'सूचनाएँ चालू करें';

  @override
  String get enableNotificationsConfirm => 'सूचनाएँ चालू करें?';

  @override
  String get notificationsEnabled => 'रिपोर्ट की सूचनाएँ चालू हो गईं';

  @override
  String get notificationsStayOff =>
      'सूचनाएँ बंद हैं। आप बाद में डिवाइस की सेटिंग में इन्हें चालू कर सकते हैं।';

  @override
  String get notificationsFailed =>
      'सूचनाएँ चालू नहीं हो सकीं। इंटरनेट जाँचें और फिर कोशिश करें।';

  @override
  String get switchProfileFailed =>
      'प्रोफ़ाइल नहीं बदली जा सकी। कृपया फिर कोशिश करें।';

  @override
  String get sourceReportFailed => 'मूल रिपोर्ट नहीं खुल सकी।';

  @override
  String get partialRefreshFailed =>
      'कुछ जानकारी फिर लोड नहीं हो सकी। फिर कोशिश करने के लिए नीचे खींचें।';

  @override
  String get knowReportReady => 'रिपोर्ट तैयार होने की सूचना पाएँ';

  @override
  String get oneResult => 'एक परिणाम';

  @override
  String get sameDayResults => 'एक ही दिन के परिणाम';

  @override
  String get verificationRequired => 'सत्यापन ज़रूरी है';

  @override
  String get accountCreatedLogin => 'आपका खाता बन गया है। अब लॉग इन करें।';

  @override
  String get continueLogin => 'लॉग इन करें';

  @override
  String get allReports => 'सभी रिपोर्ट';

  @override
  String get filterReviewed => 'जाँची गई';

  @override
  String get filterNeedsReview => 'जाँच ज़रूरी है';

  @override
  String get filterProcessing => 'प्रक्रिया जारी है';

  @override
  String get filterOriginalOnly => 'केवल मूल फ़ाइल';

  @override
  String get reportDateNewest => 'रिपोर्ट की तारीख · नई पहले';

  @override
  String get reportDateOldest => 'रिपोर्ट की तारीख · पुरानी पहले';

  @override
  String get uploadDateNewest => 'अपलोड की तारीख · नई पहले';

  @override
  String get uploadDateOldest => 'अपलोड की तारीख · पुरानी पहले';

  @override
  String get switchAction => 'बदलें';

  @override
  String get collectionDate => 'नमूना लेने की तारीख';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get history => 'पिछले परिणाम';

  @override
  String get loadingReport => 'रिपोर्ट लोड हो रही है…';

  @override
  String get restore => 'वापस लाएँ';

  @override
  String get revoke => 'लिंक बंद करें';

  @override
  String get testName => 'जाँच का नाम';

  @override
  String get viewReport => 'रिपोर्ट देखें';

  @override
  String get closeAccount => 'खाता बंद करें';

  @override
  String get createShareLink => 'शेयर लिंक बनाएँ';

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'रूप बदला, लेकिन अगली बार के लिए सहेजा नहीं जा सका.';

  @override
  String get uiThisReportIsNoLongerAvailable => 'यह रिपोर्ट अब उपलब्ध नहीं है.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'अधिसूचना पूर्वावलोकन प्रबंधित करने के लिए डिवाइस सेटिंग्स खोलें।';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'अपलोड स्वीकार होने तक इस स्क्रीन को खुला रखें।';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'हो सकता है कि कोई अपलोड बाधित हो गया हो';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'रिपोर्ट जांचें. यदि यह गुम है, तो वही फ़ाइल दोबारा जोड़ें।';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'सूचनाएं ख़ारिज नहीं की जा सकीं. पुनः प्रयास करें।';

  @override
  String get uiConnectionUnavailable => 'कनेक्शन अनुपलब्ध';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'आपके सत्र की जाँच नहीं की जा सकी. इंटरनेट से कनेक्ट करें और पुनः प्रयास करें।';

  @override
  String get uiSignInWithAnotherAccount => 'किसी अन्य खाते से साइन इन करें';

  @override
  String get uiNoActiveProfile => 'कोई सक्रिय प्रोफ़ाइल नहीं';

  @override
  String get uiDismissUploadNotice => 'अपलोड नोटिस खारिज करें';

  @override
  String get uiDismissReadyNotifications => 'तैयार अधिसूचनाएँ ख़ारिज करें';

  @override
  String get uiRequestSupport => 'समर्थन का अनुरोध करें';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'हम डायग्नोस्टिक आईडी शामिल करेंगे ताकि टीम जांच कर सके।';

  @override
  String get uiSendRequest => 'अनुरोध भेजें';

  @override
  String get uiWhatHappenedOptional => 'क्या हुआ? (वैकल्पिक)';

  @override
  String get uiReviewResult => 'परिणाम की समीक्षा करें';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'सहेजने से पहले इन फ़ील्ड की तुलना मूल रिपोर्ट से करें।';

  @override
  String get uiOriginallyExtracted => 'मूल रूप से निकाला गया';

  @override
  String get uiReloadReport => 'रिपोर्ट पुनः लोड करें';

  @override
  String get uiResultAsPrinted => 'परिणाम मुद्रित के रूप में';

  @override
  String get uiUnitIfShown => 'इकाई (यदि दिखाया गया हो)';

  @override
  String get uiLabReferenceRangeIfShown =>
      'लैब संदर्भ रेंज (यदि दिखाया गया हो)';

  @override
  String get uiCheckYourReport => 'अपनी रिपोर्ट जांचें';

  @override
  String get uiNoAttemptHistoryAvailable => 'कोई प्रयास इतिहास उपलब्ध नहीं है.';

  @override
  String get uiIInspectedTheOriginal => 'मैंने मूल का निरीक्षण किया';

  @override
  String get uiChooseTwoReports => 'दो रिपोर्ट चुनें';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'एक ही व्यक्ति के लिए रिकॉर्ड का उपयोग करें. मिलान परीक्षण साथ-साथ दिखाई देंगे।';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'पहले पुरानी रिपोर्ट चुनें और बाद में नई रिपोर्ट चुनें।';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'संगत होने पर ही तुलना की जाती है। अनुकूलता की पुष्टि होने तक विभिन्न इकाइयों या विधियों को अलग-अलग दिखाया जाता है।';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'परिवर्तन कोई निदान नहीं है. प्रत्येक परिणाम की तुलना उसके स्वयं के रिपोर्ट अंतराल से करें और अपने चिकित्सक से संदर्भ पर चर्चा करें।';

  @override
  String get uiChooseDifferentReports => 'अलग-अलग रिपोर्ट चुनें';

  @override
  String get uiEarlierReport => 'पहले की रिपोर्ट';

  @override
  String get uiLaterReport => 'बाद में रिपोर्ट';

  @override
  String get uiYourReportPages => 'आपके रिपोर्ट पृष्ठ';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'पृष्ठों को रिपोर्ट के समान क्रम में रखें।';

  @override
  String get uiAddAnotherPage => 'एक और पेज जोड़ें';

  @override
  String get uiChoosePagesFromGallery => 'गैलरी से पेज चुनें';

  @override
  String get uiAdjustPage => 'पृष्ठ समायोजित करें';

  @override
  String get uiRetake => 'पुनः लेना';

  @override
  String get uiUseAdjustedPage => 'समायोजित पृष्ठ का प्रयोग करें';

  @override
  String get uiResetChanges => 'परिवर्तन रीसेट करें';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'प्रत्येक परिणाम को कोनों के अंदर रखें।';

  @override
  String get uiRotate => 'घुमाएँ';

  @override
  String get uiReportRestored => 'रिपोर्ट पुनर्स्थापित की गई';

  @override
  String get uiDeleteReportPermanently => 'रिपोर्ट स्थायी रूप से हटाएँ?';

  @override
  String get uiDeletePermanently => 'स्थायी रूप से हटाएँ';

  @override
  String get uiReportPermanentlyDeleted => 'रिपोर्ट स्थायी रूप से हटा दी गई';

  @override
  String get uiEmptyRecycleBin => 'खाली रीसायकल बिन?';

  @override
  String get uiDeleteAll => 'सभी हटाएं';

  @override
  String get uiRecycleBinIsEmpty => 'रीसायकल बिन खाली है.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'हटाई गई रिपोर्टें हटाने से पहले यहां दिखाई देंगी.';

  @override
  String get uiEmptyRecycleBind657e2 => 'खाली रीसायकल बिन';

  @override
  String get uiCheckDetectedResult => 'पता चला परिणाम की जाँच करें';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'इस पंक्ति की तुलना मूल रिपोर्ट से करें. सहेजने से पहले किसी भी OCR गलतियों को सुधारें।';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'मैंने इस परिणाम की मूल रिपोर्ट से जाँच की';

  @override
  String get uiSaving => 'सहेजा जा रहा है...';

  @override
  String get uiSaveVerifiedResult => 'सत्यापित परिणाम सहेजें';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'कोई परिणाम नहीं पता चला. मूल रिपोर्ट देखें या प्रसंस्करण का पुनः प्रयास करें।';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'सहेजे गए परिणाम बनने से पहले पता लगाए गए मानों को मूल रिपोर्ट के विरुद्ध जांचना आवश्यक है।';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'कुछ पंक्तियाँ गायब हो सकती हैं. संपूर्ण मूल रिपोर्ट का निरीक्षण करें.';

  @override
  String get uiResult => 'नतीजा';

  @override
  String get uiUnitOptional => 'इकाई (वैकल्पिक)';

  @override
  String get uiReferenceRangeOptional => 'संदर्भ सीमा (वैकल्पिक)';

  @override
  String get uiVerified => 'सत्यापित';

  @override
  String get uiGiftVoucher => 'उपहार वाउचर';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'एक उपहार वाउचर भुनाएं और सीधे अपनी शेष राशि में क्रेडिट जोड़ें।';

  @override
  String get uiCurrentPlan => 'वर्तमान योजना';

  @override
  String get uiCreditBalance => 'क्रेडिट शेष';

  @override
  String get uiPlanLimits => 'योजना सीमाएँ';

  @override
  String get uiBuyCredits => 'क्रेडिट खरीदें';

  @override
  String get uiRecentBillingActivity => 'हाल की बिलिंग गतिविधि';

  @override
  String get uiRefreshStatus => 'ताज़ा स्थिति';

  @override
  String get uiNoRecentOrdersYet => 'अभी तक कोई हालिया आदेश नहीं है.';

  @override
  String get uiVoucherCode => 'वाउचर कोड';

  @override
  String get uiCheckout => 'चेकआउट';

  @override
  String get uiApply => 'आवेदन करें';

  @override
  String get uiClear => 'स्पष्ट';

  @override
  String get uiPay => 'भुगतान करें';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'इस समय कोई क्रेडिट पैक उपलब्ध नहीं है.';

  @override
  String get uiBuy => 'खरीदें';

  @override
  String get uiRetryPayment => 'भुगतान का पुनः प्रयास करें';

  @override
  String get uiPromoCode => 'प्रोमो कोड';

  @override
  String get uiEnterPromoCode => 'प्रोमो कोड दर्ज करें';

  @override
  String get uiChooseAPlan => 'एक योजना चुनें';

  @override
  String get uiNoPlansAvailableAtThisTime => 'इस समय कोई योजना उपलब्ध नहीं है.';

  @override
  String get uiHaveAPromoCode => 'क्या प्रोमो कोड है?';

  @override
  String get uiCURRENTPLAN => 'वर्तमान योजना';

  @override
  String get uiManageNotifications => 'सूचनाएं प्रबंधित करें';

  @override
  String get uiAll => 'सब';

  @override
  String get uiUnread => 'अपठित';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'प्रवेश तुरंत बंद हो जाता है. आप साइन इन कर सकते हैं और 30 दिनों के भीतर पुनर्स्थापित कर सकते हैं। उसके बाद, आपका खाता और संग्रहीत फ़ाइलें सक्रिय संग्रहण से हटा दी जाती हैं।';

  @override
  String get uiCloseMyAccount => 'मेरा खाता बंद करें';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'आपके रिकॉर्ड डॉक्लिज़र में रहते हैं।';

  @override
  String get uiTakeACopyOfYourRecords => 'अपने रिकॉर्ड की एक प्रति लें.';

  @override
  String get uiWhoseRecords => 'रिकॉर्ड किसका?';

  @override
  String get uiCouldNotLoadProfiles => 'प्रोफ़ाइल लोड नहीं हो सकीं';

  @override
  String get uiLoadingProfiles => 'प्रोफ़ाइल लोड हो रही हैं…';

  @override
  String get uiAllProfiles => 'सभी प्रोफाइल';

  @override
  String get uiDateRange => 'तिथि सीमा';

  @override
  String get uiUseAllDates => 'सभी तिथियों का उपयोग करें';

  @override
  String get uiINCLUDEINTHISEXPORT => 'इस निर्यात में शामिल करें';

  @override
  String get uiOriginalReports => 'मूल रिपोर्ट';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'आपके द्वारा अपलोड की गई पीडीएफ और छवियां';

  @override
  String get uiTestResults => 'परीक्षण के परिणाम';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'सीएसवी के रूप में परिणाम, उनकी समीक्षा स्थिति के साथ';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'निर्यात में व्यक्तिगत जानकारी शामिल होती है. उन्हें ऐसी जगह स्टोर करें जिस पर आपको भरोसा हो।';

  @override
  String get uiDeleteAccount => 'खाता हटाएँ';

  @override
  String get uiContinueToDeletion => 'हटाना जारी रखें';

  @override
  String get uiKeepMyAccount => 'मेरा हिसाब रखो';

  @override
  String get uiBeforeYouLeave => 'आपके जाने से पहले';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'कृपया पढ़ें कि इससे क्या हट जाएगा.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'आपका खाता हटाने से आपके द्वारा प्रबंधित सभी प्रोफ़ाइल प्रभावित होती हैं।';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'आपका खाता और व्यक्तिगत प्रोफ़ाइल';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'अपने साझा लिंक के माध्यम से पहुंचें';

  @override
  String get uiKeepACopyFirst => 'पहले एक प्रति अपने पास रखें';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'वह जानकारी निर्यात करें जिसे आप बनाए रखना चाहते हैं।';

  @override
  String get uiExportData => 'डेटा निर्यात करें';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'प्रवेश तुरंत बंद हो जाता है. आप 30 दिनों के भीतर पुनर्स्थापित कर सकते हैं. उसके बाद, आपका डेटा सक्रिय संग्रहण से हटा दिया जाता है।';

  @override
  String get uiAccountPendingDeletion => 'खाता विलोपन लंबित है';

  @override
  String get uiRestoreMyAccount => 'मेरा खाता पुनर्स्थापित करें';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'अपनी प्रोफ़ाइल, प्रोफ़ाइल और सहमति रिकॉर्ड सहित अपने खाते के डेटा की एक प्रति डाउनलोड करें।';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'आपका खाता तुरंत अक्षम कर दिया गया है. आप इसे 30 दिनों के भीतर पुनर्स्थापित कर सकते हैं. उसके बाद, आपका डेटा स्थायी रूप से हटा दिया जाता है।';

  @override
  String get uiCurrentPassword => 'वर्तमान पासवर्ड';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'ऐप लॉक नहीं बदला जा सका. पुनः प्रयास करें।';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'आपके रिकॉर्ड.\nसाझा करना आपकी पसंद है।';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'जब भी आपको आवश्यकता हो, पहुंच की समीक्षा करें।';

  @override
  String get uiAppLock => 'ऐप लॉक';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'अपने डिवाइस के बायोमेट्रिक या पासकोड लॉक का उपयोग करें।';

  @override
  String get uiNotificationPreviews => 'अधिसूचना पूर्वावलोकन';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'अपनी डिवाइस सेटिंग में लॉक-स्क्रीन पूर्वावलोकन नियंत्रित करें।';

  @override
  String get uiContactSupport => 'समर्थन से संपर्क करें';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'यदि आप चाहें तो ही रिपोर्ट संलग्न करें।';

  @override
  String get uiWhatCanWeHelpYouWith => 'हम आपकी कैसे मदद कर सकते हैं?';

  @override
  String get uiPOPULARQUESTIONS => 'लोकप्रिय प्रश्न';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'कोई भी सहायता लेख आपकी खोज से मेल नहीं खाता.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'अपने स्वास्थ्य या परीक्षण परिणामों के बारे में प्रश्नों के लिए, किसी योग्य स्वास्थ्य देखभाल पेशेवर से बात करें।';

  @override
  String get uiYourReportsAClearerPicture => 'आपकी रिपोर्ट. एक साफ़ तस्वीर.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'अपना स्वास्थ्य इतिहास साथ रखें।';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'रिपोर्ट संग्रहीत करें, परिणामों की समीक्षा करें, परिवर्तनों का पालन करें और अपने चिकित्सक के साथ साझा करें।';

  @override
  String get uiEducationalInformationOnly => 'केवल शैक्षिक जानकारी';

  @override
  String get uiSearchHelpArticles => 'सहायता लेख खोजें';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'अधिसूचना पहुंच बदलने के लिए डिवाइस सेटिंग ऐप खोलें।';

  @override
  String get uiSavePreferences => 'प्राथमिकताएँ सहेजें';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'डिवाइस अनुमतियाँ सेटिंग्स में बदली जा सकती हैं।';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'इस डिवाइस पर रिपोर्ट अपडेट प्राप्त करें';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'रिपोर्ट तैयार होने पर जानने के लिए सूचनाओं को अनुमति दें। मार्केटिंग नीचे एक अलग विकल्प है.';

  @override
  String get uiREPORTACTIVITY => 'गतिविधि की रिपोर्ट करें';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'रिपोर्ट गतिविधि सेटिंग्स के लिए नवीनतम सर्वर संस्करण की आवश्यकता होती है।';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'संवेदनशील लॉक-स्क्रीन पूर्वावलोकन';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'रिपोर्ट के नाम और व्यक्तिगत विवरण हमेशा छिपे रहते हैं।';

  @override
  String get uiOTHERMESSAGES => 'अन्य संदेश';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'प्रत्येक व्यक्ति की रिपोर्ट और रुझान एक साथ रखें।';

  @override
  String get uiPersonDetails => 'व्यक्ति विवरण';

  @override
  String get uiDateOfBirth => 'जन्मतिथि';

  @override
  String get uiRelationship => 'रिश्ता';

  @override
  String get uiEnterAName => 'एक नाम दर्ज करें';

  @override
  String get uiClearDateOfBirth => 'जन्मतिथि स्पष्ट';

  @override
  String get uiOptionalEGParentOrChild => 'वैकल्पिक, उदा. माता-पिता या बच्चा';

  @override
  String get uiInviteFriendsEarnCredits =>
      'मित्रों को आमंत्रित करें, क्रेडिट अर्जित करें';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'अपना कोड साझा करें और पुरस्कार अनलॉक होने पर प्रत्येक आमंत्रण का अनुसरण करें।';

  @override
  String get uiYOURREFERRALCODE => 'आपका रेफरल कोड';

  @override
  String get uiShareInvite => 'आमंत्रण साझा करें';

  @override
  String get uiCopyCode => 'कोड कॉपी करें';

  @override
  String get uiHaveACode => 'कोई कोड है?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'अपने आमंत्रण पुरस्कार का दावा करने के लिए आपके साथ साझा किया गया कोड दर्ज करें।';

  @override
  String get uiHowRewardsWork => 'पुरस्कार कैसे काम करते हैं';

  @override
  String get uiNoFriendsReferredYet =>
      'अभी तक किसी मित्र का उल्लेख नहीं किया गया';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'उनकी प्रगति देखने के लिए अपना निमंत्रण यहां साझा करें।';

  @override
  String get uiReferralCode => 'रेफरल कोड';

  @override
  String get uiSetNewPassword => 'नया पासवर्ड सेट करें';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'अपने ईमेल में दिए गए लिंक से रीसेट टोकन और अपना नया पासवर्ड दर्ज करें।';

  @override
  String get uiResetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get uiBackToLogin => 'लॉगिन करने के लिए वापस जाएँ';

  @override
  String get uiResetToken => 'टोकन रीसेट करें';

  @override
  String get uiNewPassword => 'नया पासवर्ड';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'अपने खाते से संबद्ध ईमेल पता दर्ज करें और हम आपको आपका पासवर्ड रीसेट करने के लिए एक लिंक भेजेंगे।';

  @override
  String get uiSendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get uiRevokeSession => 'सत्र निरस्त करें?';

  @override
  String get uiCurrentSession => 'वर्तमान सत्र';

  @override
  String get uiSkip => 'छोड़ें';

  @override
  String get uiChangePassword => 'पासवर्ड बदलें';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'अपना वर्तमान पासवर्ड दर्ज करें और नया चुनें।';

  @override
  String get uiNewPasswordd850ee => 'नया पासवर्ड';

  @override
  String get uiConfirmNewPassword => 'नये पासवर्ड की पुष्टि करें';

  @override
  String get uiGettingThingsReady => 'चीजें तैयार हो रही हैं...';

  @override
  String get uiLinkAccessHistory => 'लिंक एक्सेस इतिहास';

  @override
  String get uiNoAccessEventsYet => 'अभी तक कोई एक्सेस इवेंट नहीं.';

  @override
  String get uiDefaultShareLinkExpiry => 'डिफ़ॉल्ट शेयर लिंक समाप्ति';

  @override
  String get uiSave => 'सहेजें';

  @override
  String get uiReviewSharing => 'साझाकरण की समीक्षा करें';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'व्यक्ति, रिपोर्ट और पहुंच की जाँच करें।';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'चयन या पहुंच सेटिंग संपादित करें';

  @override
  String get uiRevokeShareLink => 'शेयर लिंक निरस्त करें?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'यह लिंक काम करना बंद कर देगा. आप एक नया बना सकते हैं.';

  @override
  String get uiShareLinkReady => 'शेयर लिंक तैयार';

  @override
  String get uiAccessCodeShareSeparately => 'एक्सेस कोड - अलग से साझा करें';

  @override
  String get uiCopyAccessCode => 'एक्सेस कोड कॉपी करें';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'यह कोड इस डिवाइस पर सहेजा नहीं जा सका. बाद में उपयोग के लिए इसे अभी कॉपी करें।';

  @override
  String get uiShareLink => 'लिंक साझा करें';

  @override
  String get uiCopyLink => 'लिंक कॉपी करें';

  @override
  String get uiRevokeLink => 'लिंक निरस्त करें';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'इस डिवाइस पर कोड अनुपलब्ध है. सहेजे गए कोड का उपयोग करें या एक नया लिंक बनाएं।';

  @override
  String get uiActiveSharedLinks => 'सक्रिय साझा लिंक';

  @override
  String get uiShare => 'साझा करें';

  @override
  String get uiCreateANewShareLink => 'एक नया शेयर लिंक बनाएं';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'इस प्रोफ़ाइल के लिए वर्तमान और भविष्य की रिपोर्ट शामिल करें।';

  @override
  String get uiChooseReports => 'रिपोर्ट चुनें';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'केवल नीचे चयनित रिपोर्ट ही साझा करें।';

  @override
  String get uiSelectAll => 'सभी का चयन करें';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'साझा करने के लिए कोई समीक्षात्मक रिपोर्ट उपलब्ध नहीं है।';

  @override
  String get uiSelectedTestResults => 'चयनित परीक्षण परिणाम';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'इन रिपोर्टों में से केवल वही परिणाम शामिल करें जिन्हें आप चुनते हैं।';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'इन रिपोर्टों में कोई सहेजे गए परीक्षण परिणाम उपलब्ध नहीं हैं।';

  @override
  String get uiUpgradeOrManage => 'अपग्रेड करें या प्रबंधित करें';

  @override
  String get uiExpiry => 'समाप्ति:';

  @override
  String get uiRequireAnAccessCode => 'एक एक्सेस कोड की आवश्यकता है';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'कोड को लिंक से अलग से साझा करें.';

  @override
  String get uiTryAgain => 'पुनः प्रयास करें';

  @override
  String get uiClearExpiry => 'स्पष्ट समाप्ति';

  @override
  String get onboardingStoreEyebrow => '01 / सहेजें';

  @override
  String get onboardingStoreTitle => 'प्रत्येक रिपोर्ट,\nएक परिचित स्थान।';

  @override
  String get onboardingStoreBody =>
      'अपने और उन लोगों के लिए जिनकी आप परवाह करते हैं, पीडीएफ और तस्वीरें एक साथ रखें।';

  @override
  String get onboardingUnderstandEyebrow => '02/समझे';

  @override
  String get onboardingUnderstandTitle => 'संख्याओं,\nको पढ़ना आसान हो गया।';

  @override
  String get onboardingUnderstandBody =>
      'अपनी रिपोर्ट से प्रत्येक परीक्षण, उसकी इकाई और अंतराल देखें। किसी भी समय मूल की जांच करें.';

  @override
  String get onboardingTrackEyebrow => '03 / ट्रैक करें और साझा करें';

  @override
  String get onboardingTrackTitle => 'परिवर्तन देखें.\nसंदर्भ साझा करें।';

  @override
  String get onboardingTrackBody =>
      'समय के साथ परिणामों का पालन करें और वही चुनें जो आपका चिकित्सक देख सके।';

  @override
  String get onboardingNext => 'अगला';

  @override
  String get onboardingGetStarted => 'आरंभ करें';

  @override
  String get uiSupportRequestSent => 'सहायता अनुरोध भेजा गया.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'परीक्षण का नाम और परिणाम आवश्यक है.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD प्रारूप में एक वैध संग्रह तिथि का उपयोग करें।';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'इस सुधार को सहेजा नहीं जा सका. पुनः प्रयास करें।';

  @override
  String get uiReportsUnavailable => 'रिपोर्ट उपलब्ध नहीं हैं';

  @override
  String get uiTryAgain042c86 => 'फिर कोशिश करें';

  @override
  String get uiTwoReportsAreNeeded => 'दो रिपोर्ट की जरूरत है';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'परिणामों की तुलना करने के लिए इस प्रोफ़ाइल के लिए एक पुरानी रिपोर्ट जोड़ें।';

  @override
  String get uiCannotCompareYet => 'अभी तुलना नहीं की जा सकती';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'इन रिपोर्टों में तुलना के लिए कोई मिलान परिणाम उपलब्ध नहीं हैं।';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'रिपोर्ट लोड करने में असमर्थ. पुनः प्रयास करें।';

  @override
  String get uiCouldNotOpenPhotosOrCamera => 'फ़ोटो या कैमरा नहीं खुल सका.';

  @override
  String get uiCouldNotOpenCamera => 'कैमरा नहीं खुल सका.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'ये पन्ने तैयार नहीं हो सके. एक अपठनीय पृष्ठ दोबारा लें और पुनः प्रयास करें।';

  @override
  String get uiCouldNotAdjustThisPage =>
      'इस पृष्ठ को समायोजित नहीं किया जा सका.';

  @override
  String get uiNoChartableResultYet => 'अभी तक कोई चार्टेबल परिणाम नहीं';

  @override
  String get uiProfiles => 'प्रोफाइल';

  @override
  String get uiReports => 'रिपोर्ट';

  @override
  String get uiShareLinks => 'लिंक साझा करें';

  @override
  String get uiAIChat => 'एआई चैट';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'पात्रता सारांश लोड करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'बिलिंग स्थिति ताज़ा करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'रसीद डाउनलोड जल्द ही उपलब्ध होगा.';

  @override
  String get uiSubtotal => 'उप योग';

  @override
  String get uiDiscount => 'छूट';

  @override
  String get uiTotal => 'कुल';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'क्रेडिट पैक लोड करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'एक भुगतान पर कब्ज़ा लंबित है. दूसरा चेकआउट शुरू करने से पहले स्थिति ताज़ा करें।';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'क्रेडिट सफलतापूर्वक लागू किए गए.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ऑर्डर बनाने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'भुगतान प्राप्त। क्रेडिट जोड़ने से पहले सर्वर समाधान की प्रतीक्षा की जा रही है।';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'भुगतान विफल रही। तैयार होने पर आप चेकआउट का पुनः प्रयास कर सकते हैं।';

  @override
  String get uiPaymentFailedTryAgain => 'भुगतान विफल रही। पुनः प्रयास करें।';

  @override
  String get uiCreditsAdded => 'क्रेडिट जोड़ा गया!';

  @override
  String get uiPromoCodeApplied => 'प्रोमो कोड लागू किया गया.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'भुगतान प्राप्त हुआ, लेकिन यह आदेश समीक्षा के लिए लंबित है।';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'समाधान के दौरान भुगतान विफल रहा.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'भुगतान की पुष्टि हो गई है। सर्वर समाधान अभी भी लंबित है.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'भुगतान सत्यापित. समाधान लंबित है, कृपया शीघ्र ही ताज़ा करें।';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'भुगतान प्राप्त हुआ लेकिन सत्यापन अभी भी लंबित है। कृपया स्थिति ताज़ा करें.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'योजनाएं लोड करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'सदस्यता बनाने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'सदस्यता विफल रही. पुनः प्रयास करें।';

  @override
  String get uiPlanUpgraded => 'योजना उन्नत!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'भुगतान प्राप्त हुआ लेकिन सत्यापन विफल रहा. शीघ्र ही योजना को उन्नत किया जाएगा।';

  @override
  String get uiNotificationsUnavailable => 'सूचनाएं अनुपलब्ध';

  @override
  String get uiAllQuietForNow => 'फिलहाल सब शांत.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'कुछ नया होने पर रिपोर्ट अपडेट और साझाकरण अनुस्मारक यहां दिखाई देंगे।';

  @override
  String get uiNoUnreadUpdates => 'कोई अपठित अपडेट नहीं';

  @override
  String get uiYouReAllCaughtUp => 'आप सब फंस गये हैं।';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'सूचनाएं लोड करने में असमर्थ. कनेक्ट होने पर पुनः प्रयास करें.';

  @override
  String get uiManageSharedLinks => 'साझा लिंक प्रबंधित करें';

  @override
  String get uiExportYourData => 'अपना डेटा डाउनलोड करें';

  @override
  String get uiReadThePrivacyPolicy => 'गोपनीयता नीति पढ़ें';

  @override
  String get uiTermsOfUse => 'उपयोग की शर्तें';

  @override
  String get uiPrivacyPolicy => 'गोपनीयता नीति';

  @override
  String get uiDateOfBirthOptional => 'जन्मतिथि, वैकल्पिक';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'संबंध 50 वर्ण या उससे कम होना चाहिए.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'प्रोफ़ाइल सहेजने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiReferralsUnavailable => 'रेफ़रल अनुपलब्ध';

  @override
  String get uiYourRewards => 'आपके पुरस्कार';

  @override
  String get uiReferralProgress => 'रेफरल प्रगति';

  @override
  String get uiFriendsReferred => 'दोस्तों का हवाला दिया गया';

  @override
  String get uiCreditsEarned => 'क्रेडिट अर्जित किया';

  @override
  String get uiPendingRewards => 'लंबित पुरस्कार';

  @override
  String get uiBlockedRewards => 'अवरुद्ध पुरस्कार';

  @override
  String get uiInviteeBonus => 'आमंत्रित बोनस';

  @override
  String get uiFirstAnalysis => 'पहला विश्लेषण';

  @override
  String get uiFirstPurchase => 'पहली खरीदारी';

  @override
  String get uiMonthlyCap => 'मासिक सीमा';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'रेफरल लोड करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiReferralCodeCopied => 'रेफरल कोड कॉपी किया गया.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'अपने ईमेल लिंक से रीसेट टोकन दर्ज करें';

  @override
  String get uiEnterYourNewPassword => 'अपना नया पासवर्ड दर्ज करें';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'पासवर्ड रीसेट करने में असमर्थ. कृपया एक नए लिंक का अनुरोध करें.';

  @override
  String get uiEnterYourEmailAddress => 'अपना ईमेल पता दर्ज करें';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'रीसेट लिंक भेजने में असमर्थ. कृपया पुन: प्रयास करें।';

  @override
  String get uiFailedToLoadSessions => 'सत्र लोड करने में विफल.';

  @override
  String get uiFailedToRevokeSession => 'सत्र निरस्त करने में विफल.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'पासवर्ड बदलने में असमर्थ. कृपया पुन: प्रयास करें।';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'डिवाइस सेटिंग खोलें और Doclyzer के लिए नोटिफिकेशन की अनुमति दें।';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'रिपोर्ट लोड नहीं की जा सकीं. पुनः प्रयास करें।';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'परीक्षण के परिणाम लोड नहीं किये जा सके. पुनः प्रयास करें।';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'साझा करने के लिए कम से कम एक रिपोर्ट चुनें.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'साझा करने के लिए कम से कम एक परीक्षा परिणाम चुनें।';

  @override
  String get uiLinkCopiedToClipboard => 'लिंक को क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'एक्सेस कोड क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get uiOnePerson => '1 व्यक्ति';

  @override
  String uiPeopleCount(String count) {
    return '$count लोग';
  }

  @override
  String uiActionsFor(String name) {
    return '$name के लिए क्रियाएँ';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'प्रोफ़ाइल स्विच करने में असमर्थ. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name पर स्विच किया गया';
  }

  @override
  String get uiAnalyzeOnePage => '1 पेज का विश्लेषण करें';

  @override
  String uiAnalyzePages(String count) {
    return '$count पृष्ठों का विश्लेषण करें';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'पृष्ठों को अपनी रिपोर्ट में दिखाए गए क्रम में खींचें';

  @override
  String get uiCheckEveryPage =>
      'विश्लेषण करने से पहले प्रत्येक पृष्ठ की जाँच करें';

  @override
  String get uiOnePageAdded => '1 पेज जोड़ा गया';

  @override
  String uiPagesAdded(String count) {
    return '$count पेज जोड़े गए';
  }

  @override
  String get uiReorder => 'पुन: व्यवस्थित करें';

  @override
  String uiPageNumber(String number) {
    return 'पेज $number';
  }

  @override
  String uiRemovePage(String number) {
    return 'पेज $number हटाएं';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · पेज $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'फसल के किनारे: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count चयनित रिपोर्टें';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count चयनित परीक्षण परिणाम';
  }

  @override
  String get uiAllCurrentFutureReports => 'सभी वर्तमान और भविष्य की रिपोर्टें';

  @override
  String get uiNoExpiry => 'कोई समाप्ति नहीं';

  @override
  String uiExpiresDate(String date) {
    return '$date समाप्त हो रहा है';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'एक्सेस कोड आवश्यक है. इसे लिंक से अलग शेयर करें.';

  @override
  String get uiNoAccessCodeRequired => 'किसी एक्सेस कोड की आवश्यकता नहीं है.';

  @override
  String uiExpiresColonDate(String date) {
    return 'समाप्ति: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name की रिपोर्ट साझा करें';
  }

  @override
  String uiProfileReports(String name) {
    return '$name की रिपोर्ट';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count चयनित परिणाम';
  }

  @override
  String get uiAccessCodeRequiredShort => 'एक्सेस कोड आवश्यक है';

  @override
  String uiPastLinksCount(String count) {
    return 'पिछले लिंक · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return 'समाप्त $date';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'निरस्त किया गया · $date बनाया गया';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum सक्रिय लिंक में से $current का उपयोग करना।';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename और इसकी संग्रहीत फ़ाइल हटाएँ? इसे असंपादित नहीं किया जा सकता है।';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'रिपोर्ट हटाने में असमर्थ: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'सभी $count रिपोर्ट और उनकी संग्रहीत फ़ाइलों को स्थायी रूप से हटा दें? इसे असंपादित नहीं किया जा सकता है।';
  }

  @override
  String get uiRecycleBinEmptied => 'रीसायकल बिन खाली हो गया';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted रिपोर्ट हटाई गईं। $failed को हटाया नहीं जा सका; पुनः प्रयास करें।';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'रीसायकल बिन खाली करने में असमर्थ: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'प्रोफ़ाइल: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'एकत्रित: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'अपलोड किया गया: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'इस दिन हटाया गया: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'स्थायी रूप से हटाएं: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'दिन शेष: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer =>
      'Doclyzer के लिए ऐप लॉक की पुष्टि करें';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'ऐप लॉक बंद करने से पहले पुष्टि करें';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'अपने स्वास्थ्य रिकॉर्ड देखने के लिए डॉक्लिज़र को अनलॉक करें';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'रिपोर्ट अपलोड करने से पहले एक डिफ़ॉल्ट प्रोफ़ाइल बनाएं.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'अपनी टाइमलाइन देखने से पहले एक डिफ़ॉल्ट प्रोफ़ाइल बनाएं।';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'अभी प्रोफ़ाइल लोड करने में असमर्थ.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'अभी अपलोड नहीं किया जा सकता क्योंकि प्रोफ़ाइल डेटा लोड नहीं किया जा सका. कृपया सुनिश्चित करें कि एपीआई सर्वर चल रहा है और पुनः प्रयास करें।';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'प्रोफ़ाइल डेटा लोड नहीं हो पाने के कारण अभी टाइमलाइन नहीं खोली जा सकती. कृपया सुनिश्चित करें कि एपीआई सर्वर चल रहा है और पुनः प्रयास करें।';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'अभी प्रोफ़ाइल लोड करने में असमर्थ. कृपया पुन: प्रयास करें।';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'साझाकरण लिंक लोड करने में असमर्थ. कृपया पुन: प्रयास करें।';

  @override
  String get uiPasswordChanged => 'पासवर्ड बदल गया';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'वह रिपोर्ट खोलने में असमर्थ. रिपोर्ट लाइब्रेरी आज़माएँ.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'जब आपका खाता समीक्षाधीन है तब यह कार्रवाई अस्थायी रूप से अनुपलब्ध है।';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'इस अनुभाग को खोलने में असमर्थ. कृपया पुन: प्रयास करें।';

  @override
  String get uiAppLockIsUnavailable => 'ऐप लॉक अनुपलब्ध है';

  @override
  String get uiDoclyzerIsLocked => 'डॉक्लिज़र बंद है';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'सहेजी गई ऐप लॉक सेटिंग नहीं पढ़ सका। जारी रखने के लिए पुनः प्रयास करें.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'जारी रखने के लिए अपने डिवाइस पासकोड या बायोमेट्रिक्स का उपयोग करें।';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'जब आपका खाता समीक्षाधीन हो तो अपलोड अस्थायी रूप से अनुपलब्ध हैं।';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'अपलोड प्रारंभ करने में असमर्थ. कृपया पुन: प्रयास करें।';

  @override
  String get uiJustNow => 'अभी अभी';

  @override
  String get uiAdditionalDetails => 'अतिरिक्त विवरण:';

  @override
  String get uiSaveCorrection => 'सुधार सहेजें';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'फ़ाइलें नहीं खोली जा सकीं. पहुंच जांचें और पुनः प्रयास करें.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'कैमरा नहीं खुल सका. अनुमति जांचें और पुनः प्रयास करें.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'फ़ोटो नहीं खोली जा सकीं. अनुमति जांचें और पुनः प्रयास करें.';

  @override
  String get uiCouldNotAccessSelectedFile => 'चयनित फ़ाइल तक नहीं पहुंच सका.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'चयनित फ़ाइल तक नहीं पहुंच सका';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'कनेक्शन टूट गया। हो सकता है कि अपलोड सर्वर तक पहुंच गया हो. उसी फ़ाइल को सुरक्षित रूप से पुनः प्रयास करें.';

  @override
  String get uiCouldNotLoadExistingReport =>
      'मौजूदा रिपोर्ट लोड नहीं की जा सकी';

  @override
  String get uiAddingTo => 'जोड़ना';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'कुछ परिणामों की समीक्षा की आवश्यकता है. आपकी मूल रिपोर्ट सहेज ली गई है.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'हम इस प्रारूप को पढ़ नहीं सके. आपकी फ़ाइल सहेजी गई है.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'रिपोर्ट सफलतापूर्वक पार्स की गई. परिणाम और रुझान उपलब्ध हैं.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'आपकी रिपोर्ट का अभी भी विश्लेषण किया जा रहा है. इसकी स्थिति जांचने के लिए इसे खोलें.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'प्रसंस्करण रुक गया. आपकी फ़ाइल सहेजी गई है. आप पुनः प्रयास कर सकते हैं.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'कोई निकाले गए परीक्षण मान नहीं जोड़े गए. आप अभी भी दस्तावेज़ खोल और साझा कर सकते हैं. आपका रुझान अपरिवर्तित है.';

  @override
  String get uiYourOriginalIsSaved => 'आपका मूल सहेजा गया है.';

  @override
  String get uiInitialUpload => 'आरंभिक अपलोड';

  @override
  String get uiParsedSuccessfully => 'सफलतापूर्वक पार्स किया गया';

  @override
  String get uiParsingFailed => 'पार्सिंग विफल';

  @override
  String get uiExtractionIncomplete => 'निकासी अधूरी';

  @override
  String get uiTransientFailure => 'क्षणिक विफलता';

  @override
  String get uiTerminalFailure => 'टर्मिनल विफलता';

  @override
  String get uiFailedToLoadAttemptHistory => 'प्रयास इतिहास लोड करने में विफल';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'इस रिपोर्ट की फ़ाइल अब उपलब्ध नहीं है.';

  @override
  String get uiCompareResults => 'परिणामों की तुलना करें';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'कोई अंतर नहीं गिना गया. अनुकूलता की पुष्टि की आवश्यकता है.';

  @override
  String get uiUnitNotRecorded => 'इकाई रिकार्ड नहीं की गई';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'इन रिपोर्टों के बीच कोई संख्यात्मक परिवर्तन नहीं.';

  @override
  String get uiUnableToRestore => 'पुनर्स्थापित करने में असमर्थ:';

  @override
  String get uiEnterAGiftVoucherCode => 'उपहार वाउचर कोड दर्ज करें.';

  @override
  String get uiApplyVoucher => 'वाउचर लागू करें';

  @override
  String get uiNotAvailable => 'उपलब्ध नहीं है';

  @override
  String get uiViewReceipt => 'रसीद देखें';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'उपहार वाउचर अमान्य है या पहले ही भुनाया जा चुका है।';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'उपहार वाउचर पहले ही भुनाया जा चुका है।';

  @override
  String get uiGiftVoucherHasBeenVoided => 'उपहार वाउचर रद्द कर दिया गया है.';

  @override
  String get uiGiftVoucherHasExpired => 'उपहार वाउचर समाप्त हो गया है.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'इस उपहार वाउचर को भुनाने में असमर्थ.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'इस उपहार वाउचर को भुनाने में असमर्थ. कृपया पुन: प्रयास करें।';

  @override
  String get uiEnterAPromoCodeToApply =>
      'आवेदन करने के लिए प्रोमो कोड दर्ज करें।';

  @override
  String get uiPromoCodeNotFound => 'प्रोमो कोड नहीं मिला.';

  @override
  String get uiPromoCodeIsInactive => 'प्रोमो कोड निष्क्रिय है.';

  @override
  String get uiPromoCodeHasExpired => 'प्रोमो कोड समाप्त हो गया है.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'इस पैक पर प्रोमो कोड लागू नहीं है।';

  @override
  String get uiPromoCodeUsageLimitReached =>
      'प्रोमो कोड उपयोग की सीमा पूरी हो गई.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'आप पहले ही इस प्रोमो कोड का उपयोग कर चुके हैं.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'प्रोमो कोड लागू करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'क्रेडिट जोड़ने से पहले इस आदेश को समीक्षा के लिए फ़्लैग किया गया था।';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'समाधान के दौरान भुगतान विफल रहा. आप सुरक्षित रूप से पुनः प्रयास कर सकते हैं.';

  @override
  String get uiAwaitingCapture => 'पकड़े जाने का इंतजार है';

  @override
  String get uiLastPaymentFailed => 'अंतिम भुगतान विफल रहा';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'आप सुरक्षित रूप से चेकआउट का पुनः प्रयास कर सकते हैं।';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'सदस्यताओं के लिए प्रोमो कोड अभी तक समर्थित नहीं हैं.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'निर्यात डाउनलोड नहीं किया जा सका. पुनः प्रयास करें।';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'मूल रिपोर्ट या परीक्षण परिणाम चुनें.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'निर्यात का अनुरोध किया गया. ताज़ा करने के लिए \"स्थिति जांचें\" पर टैप करें।';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'निर्यात का अनुरोध करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'निर्यात तैयार. डाउनलोड यूआरएल उपलब्ध है.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'निर्यात स्थिति की जाँच करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'खाता बंद करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiPrepareExport => 'निर्यात तैयार करें';

  @override
  String get uiSaveExport => 'निर्यात सहेजें';

  @override
  String get uiPrepareExportAgain => 'निर्यात फिर से तैयार करें';

  @override
  String get uiAllDates => 'सभी तिथियाँ';

  @override
  String get uiPreparingAccountDetails => 'खाता विवरण तैयार किया जा रहा है';

  @override
  String get uiFamilyMemberProfiles => 'परिवार के सदस्य प्रोफाइल';

  @override
  String get uiUploadedReports => 'रिपोर्ट अपलोड की गईं';

  @override
  String get uiDownloadReady => 'डाउनलोड तैयार है';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'इस डिवाइस पर रिपोर्ट सूचनाएं सक्षम की गईं';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'डिवाइस सेटिंग खोली गईं. Doclyzer के लिए सूचनाओं की अनुमति दें, फिर यहां वापस आएं।';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'सूचनाएं अभी भी बंद हैं. उन्हें डिवाइस सेटिंग में रिपोर्ट अपडेट प्राप्त करने की अनुमति दें।';

  @override
  String get uiPreferencesSaved => 'प्राथमिकताएँ सहेजी गईं';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'आपकी खाता पसंद सहेज ली गई थी, लेकिन इस डिवाइस ने मार्केटिंग पुश के लिए पंजीकरण पूरा नहीं किया। इस उपकरण पर विपणन अवरुद्ध रहता है; अधिसूचना अनुमति की जाँच करें और पुनः सहेजने का प्रयास करें।';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'आपकी खाता पसंद सहेज ली गई. यह उपकरण अभी तक अपनी स्थानीय प्राथमिकता की पुष्टि नहीं कर सका है, लेकिन खाता स्तर पर मार्केटिंग अवरुद्ध है।';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'आपके खाते का विकल्प सहेजा गया था, लेकिन यह डिवाइस मार्केटिंग पुश को सक्षम नहीं कर सका। अधिसूचना अनुमति की जाँच करें और पुनः प्रयास करें।';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'बचत करने में बहुत अधिक समय लगा. अपना कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get uiReportReadyForReview => 'रिपोर्ट समीक्षा के लिए तैयार है';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'जानें कि आपके परिणाम कब जांच के लिए तैयार हैं।';

  @override
  String get uiUploadUpdates => 'अद्यतन अपलोड करें';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'यदि किसी अपलोड पर ध्यान देने की आवश्यकता है तो एक संदेश प्राप्त करें।';

  @override
  String get uiSharedLinkReminders => 'साझा लिंक अनुस्मारक';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'जब कोई लिंक समाप्त होने वाला हो तो सुनें.';

  @override
  String get uiSecurityAlerts => 'सुरक्षा अलर्ट';

  @override
  String get uiRequiredForAccountSafety => 'खाता सुरक्षा के लिए आवश्यक.';

  @override
  String get uiComplianceNotices => 'अनुपालन नोटिस';

  @override
  String get uiRequiredAccountInformation => 'आवश्यक खाता जानकारी.';

  @override
  String get uiMarketingPushNotifications => 'विपणन पुश सूचनाएँ';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ऑफ़र और घोषणाएँ। इस विकल्प को सहेजने से यह इस डिवाइस पर भी लागू होता है।';

  @override
  String get uiProductUpdates => 'उत्पाद अद्यतन';

  @override
  String get uiOptionalNewsAboutDoclyzer =>
      'Doclyzer के बारे में वैकल्पिक समाचार.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'सर्वर से जुड़ नहीं सकते। कृपया अपना इंटरनेट या एपीआई सर्वर जांचें।';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'जब आपका खाता समीक्षाधीन हो तो प्रोफ़ाइल अपडेट अस्थायी रूप से अनुपलब्ध हैं।';

  @override
  String get uiUse100CharactersOrFewer =>
      '100 या उससे कम वर्णों का प्रयोग करें';

  @override
  String get uiAddProfile => 'प्रोफ़ाइल जोड़ें';

  @override
  String get uiCreateProfile => 'प्रोफ़ाइल बनाएं';

  @override
  String get uiUpdateTheirDetails => 'उनका विवरण अपडेट करें';

  @override
  String get uiWhoIsThisProfileFor => 'यह प्रोफ़ाइल किसके लिए है?';

  @override
  String get uiNotSelected => 'चयनित नहीं';

  @override
  String get uiEnterAReferralCode => 'एक रेफरल कोड दर्ज करें.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'रेफरल लागू किया गया. ईमेल सत्यापन के बाद बोनस अनलॉक हो जाता है।';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'रेफरल लागू किया गया. बोनस क्रेडिट तैयार हैं.';

  @override
  String get uiApplyCode => 'कोड लागू करें';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'आप अपना स्वयं का रेफरल कोड लागू नहीं कर सकते.';

  @override
  String get uiReferralCodeIsInvalid => 'रेफरल कोड अमान्य है.';

  @override
  String get uiFailedToApplyReferralCode => 'रेफरल कोड लागू करने में विफल.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'रेफरल कोड लागू करने में विफल. कृपया पुन: प्रयास करें।';

  @override
  String get uiThisDevice => 'यह उपकरण';

  @override
  String get uiSignedInDevice => 'साइन-इन डिवाइस';

  @override
  String get uiUnknownDevice => 'अज्ञात उपकरण';

  @override
  String get uiRevokeAndLogOut => 'निरस्त करें और लॉग आउट करें';

  @override
  String get uiRevokeSessionca8440 => 'सत्र निरस्त करें';

  @override
  String get uiEnterYourCurrentPassword => 'अपना वर्तमान पासवर्ड दर्ज करें';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'अपरकेस, लोअरकेस, एक संख्या और एक विशेष वर्ण के साथ कम से कम 8 वर्णों का उपयोग करें';

  @override
  String get uiChooseADifferentPassword => 'कोई भिन्न पासवर्ड चुनें';

  @override
  String get uiNewPasswordsDoNotMatch => 'नये पासवर्ड मेल नहीं खाते';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'आपने सभी उपलब्ध अपलोड क्रेडिट का उपयोग कर लिया है. और अधिक जोड़ने के लिए प्लान एवं क्रेडिट पर जाएँ।';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'Doclyzer के लिए सूचनाएं अक्षम हैं. रिपोर्ट-तैयार और खाता अपडेट की अनुमति देने के लिए डिवाइस सेटिंग्स खोलें। जब तक आप इसे नहीं चुनते, मार्केटिंग बंद रहती है।';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'इस डिवाइस पर रिपोर्ट-तैयार और खाता अपडेट प्राप्त करें। जब तक आप इसे नहीं चुनते, मार्केटिंग बंद रहती है।';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'इस डिवाइस के लिए सूचनाएं बंद हैं. रिपोर्ट-तैयार और खाता अपडेट प्राप्त करने के लिए सेटिंग्स खोलें।';

  @override
  String get uiBlockedExpiredRevoked => 'अवरुद्ध (समाप्त/निरस्त)';

  @override
  String get uiFailedToLoadPolicy => 'नीति लोड करने में विफल';

  @override
  String get uiUploadPaused => 'अपलोड रोका गया';

  @override
  String get uiSevenDays => '7 दिन';

  @override
  String get uiThirtyDays => '30 दिन';

  @override
  String get uiNinetyDays => '90 दिन';

  @override
  String get uiUploadingAClearReport => 'स्पष्ट रिपोर्ट अपलोड करना';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'पीडीएफ़, फ़ोटो और अनेक पृष्ठ';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'एक पीडीएफ चुनें या प्रत्येक पृष्ठ की स्पष्ट तस्वीरें लें। पूरे पृष्ठ को फ़्रेम में रखें, चकाचौंध से बचें और विश्लेषण करने से पहले पृष्ठ क्रम की जाँच करें। आप निकाले गए मानों को मूल के विरुद्ध सही कर सकते हैं।';

  @override
  String get uiCorrectingAResult => 'किसी परिणाम को ठीक करना';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'मूल के विरुद्ध मूल्यों की समीक्षा करें';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'एक रिपोर्ट खोलें, मूल के विरुद्ध प्रत्येक निकाले गए परीक्षण की समीक्षा करें, और गलत तरीके से पढ़े गए किसी भी मूल्य, इकाई या तारीख को सही करें। रुझानों पर भरोसा करने से पहले अपुष्ट परिणामों की जांच कर लेनी चाहिए।';

  @override
  String get uiManagingFamilyRecords => 'पारिवारिक अभिलेखों का प्रबंधन करना';

  @override
  String get uiProfilesAccessAndPermissions => 'प्रोफ़ाइल, पहुंच और अनुमतियाँ';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'प्रोफ़ाइल बनाने और बदलने के लिए परिवार का उपयोग करें। रिपोर्ट अपलोड करने या साझा करने से पहले चयनित व्यक्ति की जाँच करें। केवल उन रिकॉर्ड्स को प्रबंधित करें जिनके उपयोग के लिए आप अधिकृत हैं।';

  @override
  String get uiSharingAndRevokingLinks => 'लिंक साझा करना और निरस्त करना';

  @override
  String get uiControlTheRecordsYouShare =>
      'आपके द्वारा साझा किए गए रिकॉर्ड को नियंत्रित करें';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'उन रिपोर्टों या परिणामों का चयन करें जिन्हें आप साझा करना चाहते हैं, समाप्ति और एक्सेस कोड की समीक्षा करें, फिर लिंक और कोड को अलग से भेजें। जब पहुंच की आवश्यकता न रह जाए तो साझा लिंक से किसी सक्रिय लिंक को निरस्त करें।';

  @override
  String get uiInformationYouProvide => 'आपके द्वारा प्रदान की गई जानकारी';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'खाता विवरण और पारिवारिक प्रोफ़ाइल यह पहचानते हैं कि आप किसके रिकॉर्ड प्रबंधित करते हैं। अपलोड किए गए दस्तावेज़ों में संवेदनशील स्वास्थ्य जानकारी हो सकती है।';

  @override
  String get uiSharingControls => 'नियंत्रण साझा करना';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'प्रत्येक लिंक की सामग्री, समाप्ति और पहुंच सेटिंग्स की समीक्षा करें। अपनी खाता सेटिंग से सक्रिय लिंक प्रबंधित करें।';

  @override
  String get uiExportAndAccountChoices => 'निर्यात और खाता विकल्प';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'रिकॉर्ड निर्यात करने या खाता हटाने का अनुरोध शुरू करने के लिए सेटिंग्स का उपयोग करें। प्रतिधारण विवरण पूरी पॉलिसी में हैं।';

  @override
  String get uiEducationalScope => 'शैक्षिक दायरा';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'Doclyzer रिपोर्ट व्यवस्थित करता है और समय के साथ परिणाम दिखाता है। शैक्षिक स्पष्टीकरण चिकित्सीय सलाह या निदान नहीं हैं।';

  @override
  String get uiReviewYourRecords => 'अपने रिकॉर्ड की समीक्षा करें';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'मूल रिपोर्ट के विरुद्ध निकाले गए मानों, इकाइयों और तिथियों की जाँच करें। अपने परिणामों के बारे में किसी स्वास्थ्य देखभाल पेशेवर से पूछें।';

  @override
  String get uiManageAndShareResponsibly =>
      'जिम्मेदारीपूर्वक प्रबंधित करें और साझा करें';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'केवल उन रिकॉर्ड्स को प्रबंधित करें जिनके उपयोग के लिए आप अधिकृत हैं। साझा करने से पहले चयनित जानकारी और प्राप्तकर्ता की जाँच करें।';

  @override
  String get uiPrivacyPolicy7ceacd => 'गोपनीयता नीति';

  @override
  String get uiTermsOfUse8a069e => 'उपयोग की शर्तें';

  @override
  String get uiOpenPrivacyControls => 'गोपनीयता नियंत्रण खोलें';

  @override
  String get uiGetHelpWithTheApp => 'ऐप से सहायता प्राप्त करें';

  @override
  String get uiExportYourDataInAccountSettings =>
      'खाता सेटिंग में अपना डेटा निर्यात करें';

  @override
  String get uiYOURDATACHOICES => 'आपका डेटा और विकल्प';

  @override
  String get uiUSINGDOCLYZER => 'डॉक्लाइज़र का उपयोग करना';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'डॉकलीज़र में आपके द्वारा रखी गई जानकारी\nको समझें।';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'ऐप की भूमिका की स्पष्ट समझ।';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name से $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · नवीनतम $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'इस लाइब्रेरी को शुरू करने के लिए $name के लिए एक रिपोर्ट अपलोड करें।';
  }

  @override
  String uiIpAddress(String address) {
    return 'आईपी पता: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'साइन इन करें: $date';
  }

  @override
  String get uiUnknown => 'अज्ञात';

  @override
  String uiResultsFor(String name) {
    return '$name के लिए परिणाम';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count लैब पैरामीटर ट्रैक किए गए';
  }

  @override
  String uiSampledDate(String date) {
    return 'नमूना $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'संग्रहण दिनांक: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'लैब रेंज: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI इस रेंज को $range के रूप में पढ़ता है। मुद्रित पाठ: $printed। इस तुलना पर भरोसा करने से पहले मूल रिपोर्ट की जाँच करें।';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount तैयार';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count क्रेडिट';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'इस खाते पर एक रेफरल कोड पहले ही लागू किया जा चुका है।';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ऐप लॉक चालू करने से पहले डिवाइस पासकोड सेट करें।';

  @override
  String get uiLanguagePreferenceNotSaved => 'भाषा प्राथमिकता सहेजी नहीं गई.';

  @override
  String get uiExportUnavailable => 'निर्यात अनुपलब्ध';

  @override
  String get uiUnreadableImage => 'अपठनीय छवि';

  @override
  String uiStatusWithValue(String status) {
    return 'स्थिति: $status';
  }

  @override
  String get uiPending => 'लंबित';

  @override
  String get uiCompleted => 'पूरा हुआ';

  @override
  String get uiFailed => 'असफल';

  @override
  String get uiInactive => 'निष्क्रिय';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'अपनी रिपोर्ट और प्रोफ़ाइल रखने के लिए $date से पहले पुनर्स्थापित करें।';
  }

  @override
  String get uiThirtyDayDeadline => '30 दिन की समयसीमा';

  @override
  String uiWhatsAffected(String details) {
    return 'क्या प्रभावित हुआ: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'अंतिम अद्यतन: $date $time पर';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename वर्तमान प्रोफ़ाइल के बजाय $name के अंतर्गत दिखाई देगा।';
  }

  @override
  String get uiOneVerifiedResult => '1 सत्यापित परिणाम सहेजा गया.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count सत्यापित परिणाम सहेजे गए।';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'प्रोफ़ाइल स्विच करने में असमर्थ. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'एकत्रित: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'अपलोड की तारीख: $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount द्वारा वृद्धि';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount से घटा';
  }

  @override
  String get uiPercentagePoints => 'प्रतिशत अंक';

  @override
  String uiTestValuesCount(String count) {
    return 'परीक्षण मान ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'प्रसंस्करण के दौरान एआई द्वारा मूल्य की जाँच की गई। मूल ओसीआर: $value। रिपोर्ट के आधार पर इसकी पुष्टि करें।';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return 'रिपोर्ट पहले से ही $name में है';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return 'रिपोर्ट $name में जोड़ी गई';
  }

  @override
  String uiAddedOn(String date) {
    return '$date जोड़ा गया';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max रिपोर्ट में से $current का उपयोग करना।';
  }

  @override
  String get uiNeedHelp => 'मदद चाहिए?';

  @override
  String get uiEnabled => 'सक्षम';

  @override
  String get uiEnable => 'सक्षम करें';

  @override
  String get uiSubscribe => 'सदस्यता लें';

  @override
  String get uiApplying => 'आवेदन करना';

  @override
  String get uiCheckStatus => 'स्थिति देखें';

  @override
  String get uiEditProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get uiSaveChanges => 'बदलाव सेव करें';

  @override
  String get uiOptional => 'वैकल्पिक';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'आदेश $orderId समाधान की प्रतीक्षा कर रहा है। स्थिति स्पष्ट होने तक खरीदारी रोक दी गई है।';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'मासिक योजना - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'क्रेडिट पैक - $name';
  }

  @override
  String get uiUnreadable => 'अस्पष्ट';

  @override
  String uiLatestValue(String value) {
    return 'नवीनतम: $value';
  }

  @override
  String get uiEarlier => 'पहले';

  @override
  String get uiLater => 'बाद में';

  @override
  String get uiViewed => 'देखा';

  @override
  String get uiBlocked => 'अवरुद्ध';

  @override
  String get uiCapped => 'छाया हुआ';

  @override
  String uiLastChange(String label) {
    return 'अंतिम परिवर्तन: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'अंतिम परिवर्तन: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'उपहार वाउचर लागू किया गया. $credits क्रेडिट जोड़े गए।';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'मूल को अभी तक सहेजा नहीं जा सका. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'निरस्त करने में विफल: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'मेरे Doclyzer रेफरल कोड $code: $link का उपयोग करें';
  }

  @override
  String get uiAMomentAgo => 'एक क्षण पहले';

  @override
  String uiMinutesAgo(String count) {
    return '$count मिनट पहले';
  }

  @override
  String get uiOneHourAgo => '1 घंटा पहले';

  @override
  String uiHoursAgo(String count) {
    return '$count घंटे पहले';
  }

  @override
  String get uiToday => 'आज';

  @override
  String get uiYesterday => 'कल';

  @override
  String get uiOneDayAgo => '1 दिन पहले';

  @override
  String uiDaysAgo(String count) {
    return '$count दिन पहले';
  }

  @override
  String get uiOneWeekAgo => '1 सप्ताह पहले';

  @override
  String uiWeeksAgo(String count) {
    return '$count सप्ताह पहले';
  }

  @override
  String get uiOneMonthAgo => '1 महीने पहले';

  @override
  String uiMonthsAgo(String count) {
    return '$count महीने पहले';
  }

  @override
  String get uiOneYearAgo => '1 साल पहले';

  @override
  String uiYearsAgo(String count) {
    return '$count साल पहले';
  }

  @override
  String get uiInOneDay => '1 दिन में';

  @override
  String uiInDays(String count) {
    return '$count दिनों में';
  }

  @override
  String uiInMinutes(String count) {
    return '$count मिनट में';
  }

  @override
  String get uiInOneHour => '1 घंटे में';

  @override
  String uiInHours(String count) {
    return '$count घंटे में';
  }

  @override
  String get uiMissingExtractedTestName =>
      'निकाले गए परिणाम से परीक्षण का नाम गायब है।';

  @override
  String get uiMissingCapturedLabRange =>
      'इस परीक्षण के लिए कोई प्रयोगशाला संदर्भ सीमा कैप्चर नहीं की गई।';

  @override
  String get uiNonNumericExtractedValue =>
      'निकाला गया मान कोई सादा संख्या नहीं है. इसे मूल रिपोर्ट में जांचें.';

  @override
  String get uiLabFlagRangeConflict =>
      'लैब ध्वज मुद्रित रेंज के साथ टकराव करता है। मूल रिपोर्ट की जाँच करें.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'निकाले गए मूल्य, मुद्रित रेंज, या प्रयोगशाला ध्वज को मूल रिपोर्ट में जांचने की आवश्यकता है।';

  @override
  String get uiInitialEntitlement => 'प्रारंभिक पात्रता';

  @override
  String get uiCreditPackPurchase => 'क्रेडिट पैक खरीद';

  @override
  String get uiSubscriptionUpgrade => 'सदस्यता उन्नयन';

  @override
  String get uiPlanDowngrade => 'डाउनग्रेड की योजना बनाएं';

  @override
  String get uiAdminAdjustment => 'व्यवस्थापक समायोजन';

  @override
  String get uiSystemReconciliation => 'सिस्टम सामंजस्य';

  @override
  String get uiReferralInviteBonus => 'रेफरल आमंत्रण बोनस';

  @override
  String get uiReferralAnalysisMilestone => 'रेफरल विश्लेषण मील का पत्थर';

  @override
  String get uiReferralPurchaseMilestone => 'रेफरल खरीद मील का पत्थर';

  @override
  String get uiFreePromoCreditPack => 'निःशुल्क प्रोमो क्रेडिट पैक';

  @override
  String get uiGiftVoucherRedeemed => 'उपहार वाउचर भुनाया गया';

  @override
  String get uiNotYetChanged => 'अभी तक नहीं बदला गया';

  @override
  String get uiCannotReachServer =>
      'सर्वर तक पहुंचने में असमर्थ. अपना कनेक्शन जांचें और पुनः प्रयास करें।';

  @override
  String get uiInvalidEmailOrPassword =>
      'अमान्य ईमेल या पासवर्ड. अपना विवरण जांचें और पुनः प्रयास करें।';

  @override
  String get uiTooManyAuthAttempts =>
      'बहुत अधिक प्रयास. कुछ मिनट प्रतीक्षा करें और पुनः प्रयास करें।';

  @override
  String get uiEnterValidEmail => 'कृपया एक मान्य ईमेल पता प्रविष्ट करें।';

  @override
  String get uiPasswordRequirements =>
      'पासवर्ड कम से कम 8 अक्षर का होना चाहिए और इसमें अपरकेस, लोअरकेस, एक संख्या और एक विशेष अक्षर शामिल होना चाहिए।';

  @override
  String get uiAccountWithEmailExists =>
      'इस ईमेल वाला एक खाता पहले से मौजूद है. साइन इन करें या किसी भिन्न ईमेल का उपयोग करें.';

  @override
  String get uiUploadedStatus => 'अपलोड किया गया';

  @override
  String uiSupportAction(String action) {
    return 'क्रिया: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'सहसंबंध आईडी: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'क्लाइंट एक्शन आईडी: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'त्रुटि कोड: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'आपका सत्र समाप्त हो गया. पुनः साइन इन करें.';

  @override
  String get uiProfileLimitReached =>
      'आपकी योजना प्रोफ़ाइल की सीमा पूरी हो गई है. और अधिक जोड़ने के लिए योजना और क्रेडिट की समीक्षा करें।';

  @override
  String get uiCorrectionConflictReload =>
      'यह परिणाम अन्यत्र बदल गया। रिपोर्ट को सही करने से पहले पुनः लोड करें।';

  @override
  String get uiSeePlanCreditsOptions =>
      'उपलब्ध विकल्पों के लिए योजना और क्रेडिट देखें।';

  @override
  String get uiShareLinkLimitHelp =>
      'आप सक्रिय शेयर-लिंक सीमा तक पहुंच गए हैं।';

  @override
  String get uiScopedExportUnavailable =>
      'स्कोप्ड निर्यात अनुपलब्ध है. बाद में पुन: प्रयास।';

  @override
  String get uiRestorationUnavailable =>
      'पुनर्स्थापना अनुपलब्ध है. बाद में पुन: प्रयास।';

  @override
  String get uiExportRequestNotFound =>
      'निर्यात अनुरोध नहीं मिला. नये निर्यात का अनुरोध करें.';

  @override
  String get uiClosureConfirmationRequired =>
      'जारी रखने के लिए खाता बंद होने की पुष्टि करें।';

  @override
  String get uiCurrentPasswordIncorrect => 'मौजूदा पासवर्ड गलत है।';

  @override
  String get uiLaboratories => 'प्रयोगशालाएँ';

  @override
  String get uiUnlock => 'अनलॉक';
}
