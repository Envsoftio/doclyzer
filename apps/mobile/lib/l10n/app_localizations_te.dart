// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get trendLatestResult => 'తాజా ఫలితం';

  @override
  String get trendPreviousResult => 'మునుపటి ఫలితం';

  @override
  String get trendSourceUnit => 'ఈ పరిధి యొక్క అసలు యూనిట్';

  @override
  String get trendNoSavedResults => 'ఈ పరీక్షకు ఇంకా సేవ్ చేసిన ఫలితాలు లేవు.';

  @override
  String get trendNoPlottableResults =>
      'సేకరణ తేదీ ఉన్న ఖచ్చితమైన సంఖ్యా ఫలితాలను చార్ట్‌లో చూపలేము.';

  @override
  String get trendOneResultHelp =>
      'ఒక ఫలితం సేవ్ చేయబడింది. మార్పును చూడటానికి మరొక నివేదికను జోడించండి.';

  @override
  String get trendMultipleResultsHelp =>
      'తేదీలు గడిచిన సమయానికి అనుగుణంగా చూపబడ్డాయి. విలువ కోసం బిందువును నొక్కండి.';

  @override
  String trendUnplottedNote(int count) {
    return 'సేకరణ తేదీ లేదా ఖచ్చితమైన సంఖ్యా విలువ లేకపోవడంతో $count ఫలితాలను చార్ట్‌లో చూపలేదు.';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$count ఫలితాలతో $testName మార్పుల చార్ట్';
  }

  @override
  String get trendDateReview =>
      'సేకరణ తేదీ మునుపటి వెలికితీత నుంచి వచ్చింది. అసలు నివేదికలో తనిఖీ చేయండి.';

  @override
  String get trendNotPlotted => 'చార్ట్‌లో చూపలేదు';

  @override
  String get trendExactNumberUnavailable => 'ఫలితం ఖచ్చితమైన సంఖ్య కాదు';

  @override
  String get preferredLanguage => 'ప్రాధాన్య భాష';

  @override
  String get descriptionLanguage => 'వివరణ భాష';

  @override
  String get languageHelp =>
      'యాప్‌లోని పేర్లు, సూచనలు, నివేదిక వివరణల కోసం ఉపయోగించే భాష. వివరణ భాషను మీరు ఎప్పుడైనా మార్చవచ్చు.';

  @override
  String get languageSaveFailed =>
      'మీ భాష ఎంపికను సేవ్ చేయలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get translationLoading => 'అనువదించిన వివరణను సిద్ధం చేస్తున్నాము…';

  @override
  String get translationFailed =>
      'అనువాదం అందుబాటులో లేదు. మళ్లీ ప్రయత్నించండి లేదా ఆంగ్లాన్ని ఎంచుకోండి.';

  @override
  String get translationNote =>
      'సేవ్ చేసిన ఆంగ్ల వివరణ నుంచి AI ద్వారా అనువదించబడింది. ఖచ్చితమైన ఫలితాల కోసం అసలు నివేదికను తనిఖీ చేయండి.';

  @override
  String get sourceChanged =>
      'నివేదిక మారింది. తాజా వివరణను చూడటానికి దాన్ని మళ్లీ లోడ్ చేయండి.';

  @override
  String get signupTitle => 'మరింత స్పష్టమైన అవగాహన\nఇక్కడే మొదలవుతుంది.';

  @override
  String get signupIntro =>
      'మీ నివేదికలు, ఫలితాలను ఒకే చోట ఉంచడానికి ఖాతాను సృష్టించండి.';

  @override
  String get loginIntro =>
      'మీ ఆరోగ్య నివేదికలను చూడటానికి, అర్థం చేసుకోవడానికి సైన్ ఇన్ చేయండి.';

  @override
  String get emailAddress => 'ఇమెయిల్ చిరునామా';

  @override
  String get email => 'ఇమెయిల్';

  @override
  String get password => 'పాస్‌వర్డ్';

  @override
  String get referralCode => 'రెఫరల్ కోడ్ (ఐచ్ఛికం)';

  @override
  String get createAccount => 'ఖాతాను సృష్టించండి';

  @override
  String get alreadyAccount => 'ఇప్పటికే ఖాతా ఉందా? ';

  @override
  String get noAccount => 'ఖాతా లేదా? ';

  @override
  String get signIn => 'సైన్ ఇన్ చేయండి';

  @override
  String get showPassword => 'పాస్‌వర్డ్‌ను చూపించండి';

  @override
  String get hidePassword => 'పాస్‌వర్డ్‌ను దాచండి';

  @override
  String get needHelp => 'సహాయం కావాలా?';

  @override
  String get forgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get invalidCredentialsInput =>
      'చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామా, పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String get signupFailed => 'ఖాతాను సృష్టించలేకపోయాము';

  @override
  String get loginFailed =>
      'సైన్ ఇన్ చేయలేకపోయాము. దయచేసి మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get genericError =>
      'ఏదో సమస్య తలెత్తింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get profileUpdated => 'ప్రొఫైల్ నవీకరించబడింది';

  @override
  String get changePhoto => 'ప్రొఫైల్ ఫోటోను మార్చండి';

  @override
  String get gallery => 'గ్యాలరీ నుంచి ఎంచుకోండి';

  @override
  String get camera => 'ఫోటో తీయండి';

  @override
  String get photoUpdated => 'ప్రొఫైల్ ఫోటో నవీకరించబడింది';

  @override
  String get photoFailed =>
      'మీ ఫోటోను నవీకరించలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get yourAccount => 'మీ ఖాతా';

  @override
  String get profileLoading => 'ప్రొఫైల్‌ను లోడ్ చేస్తున్నాము…';

  @override
  String get profileLoadAction => 'మీ ప్రొఫైల్‌ను లోడ్ చేయడానికి నొక్కండి';

  @override
  String get accountData => 'ఖాతా మరియు డేటా';

  @override
  String get personalInformation => 'వ్యక్తిగత సమాచారం';

  @override
  String get notificationPreferences => 'నోటిఫికేషన్ ప్రాధాన్యతలు';

  @override
  String get privacySecurity => 'గోప్యత మరియు భద్రత';

  @override
  String get sharedLinks => 'పంచుకున్న లింక్‌లు';

  @override
  String get exportData => 'మీ డేటాను ఎగుమతి చేయండి';

  @override
  String get additionalAccount => 'అదనపు ఖాతా సమాచారం';

  @override
  String get additionalAccountHelp =>
      'కుటుంబం, ప్లాన్, రెఫరల్‌లు, సెషన్‌లు మరియు ప్రదర్శన తీరు';

  @override
  String get familyProfiles => 'కుటుంబ ప్రొఫైళ్లు';

  @override
  String get manageProfiles => 'ప్రొఫైళ్లను మార్చండి లేదా నిర్వహించండి';

  @override
  String get planCredits => 'ప్లాన్ మరియు క్రెడిట్‌లు';

  @override
  String get viewPlanBalance => 'మీ ప్లాన్, మిగిలిన క్రెడిట్‌లను చూడండి';

  @override
  String get balanceLoading => 'మిగిలిన క్రెడిట్‌లను లోడ్ చేస్తున్నాము…';

  @override
  String get referFriends => 'స్నేహితులను ఆహ్వానించండి';

  @override
  String get referralRewards => 'ఆహ్వానాలు, రెఫరల్ బహుమతులు';

  @override
  String get activeSessions => 'ప్రస్తుతం కొనసాగుతున్న సెషన్‌లు';

  @override
  String get appearance => 'ప్రదర్శన తీరు';

  @override
  String get system => 'పరికర సెట్టింగ్ ప్రకారం';

  @override
  String get light => 'లేత రంగులు';

  @override
  String get dark => 'ముదురు రంగులు';

  @override
  String get helpSupport => 'సహాయం మరియు మద్దతు';

  @override
  String get aboutDoclyzer => 'Doclyzer గురించి';

  @override
  String get aboutCopy =>
      'నివేదికలను వ్యక్తులవారీగా క్రమబద్ధంగా ఉంచండి. వెలికితీసిన ఫలితాలను అసలు నివేదికతో సరిపోల్చి సమీక్షించండి.';

  @override
  String get logOut => 'లాగ్ అవుట్ చేయండి';

  @override
  String get profile => 'ప్రొఫైల్';

  @override
  String get saveChanges => 'మార్పులను సేవ్ చేయండి';

  @override
  String get accountRestricted => 'ఖాతాపై పరిమితులు విధించబడ్డాయి';

  @override
  String get photoUploading => 'ఫోటోను అప్‌లోడ్ చేస్తున్నాము…';

  @override
  String get changePhotoShort => 'ఫోటోను మార్చండి';

  @override
  String get accountDetails => 'ఖాతా వివరాలు';

  @override
  String get emailHelp =>
      'ఖాతాలోకి ప్రవేశించడానికి ఉపయోగిస్తారు. దీన్ని మార్చడానికి సహాయ బృందాన్ని సంప్రదించండి.';

  @override
  String get accountName => 'ఖాతా పేరు';

  @override
  String get belowLabRange => 'ఈ ల్యాబ్ సూచన పరిధి కంటే తక్కువ';

  @override
  String get withinLabRange => 'ఈ ల్యాబ్ సూచన పరిధిలో ఉంది';

  @override
  String get aboveLabRange => 'ఈ ల్యాబ్ సూచన పరిధి కంటే ఎక్కువ';

  @override
  String get cannotCompare => 'ల్యాబ్ పరిధితో పోల్చలేము';

  @override
  String get understandResult => 'ఈ ఫలితాన్ని అర్థం చేసుకోండి';

  @override
  String get yourResult => 'మీ ఫలితం';

  @override
  String get labReferenceRange => 'ల్యాబ్ సూచన పరిధి';

  @override
  String get resultUnavailable => 'ఈ ఫలితంలో అందుబాటులో లేదు';

  @override
  String get sampleDate => 'నమూనా తేదీ';

  @override
  String get resultHistory => 'గత ఫలితాలు';

  @override
  String get originalReport => 'అసలు నివేదిక';

  @override
  String get reviewValue => 'విలువను సమీక్షించండి';

  @override
  String get understandYourResult => 'మీ ఫలితాన్ని అర్థం చేసుకోండి';

  @override
  String get educationalContext =>
      'ఈ ఫలితం గురించి చర్చించడానికి మీకు తోడ్పడే అవగాహన సమాచారం.';

  @override
  String get explanationUnavailable => 'వివరణ అందుబాటులో లేదు';

  @override
  String get explanationFailed => 'ప్రస్తుతం వివరణను లోడ్ చేయలేకపోయాము.';

  @override
  String get checkOriginal => 'అసలు నివేదికను తనిఖీ చేయండి';

  @override
  String get tryAgain => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get aiGuidance => 'AI రూపొందించిన మార్గదర్శక సమాచారం';

  @override
  String get understandingResult => 'ఈ ఫలితాన్ని అర్థం చేసుకోవడం';

  @override
  String get possibleMeaning => 'దీని అర్థం ఏమై ఉండవచ్చు';

  @override
  String get whatTestMeasures => 'ఈ పరీక్ష దేనిని కొలుస్తుంది';

  @override
  String get suggestedNextStep => 'సూచించిన తదుపరి చర్య';

  @override
  String get resultLimitations => 'ఈ ఫలితం ద్వారా తెలుసుకోలేనివి';

  @override
  String get oneResultLimit =>
      'ఒక్క ఫలితంతోనే వ్యాధిని నిర్ధారించడం లేదా లక్షణాలకు కారణాన్ని వివరించడం సాధ్యం కాదు.';

  @override
  String get detailsToCheck => 'తనిఖీ చేయాల్సిన వివరాలు';

  @override
  String get lifestyleFactors => 'చర్చించాల్సిన జీవనశైలి అంశాలు';

  @override
  String get insightContext =>
      'ఈ విలువ మీ నివేదిక నుంచి వెలికితీయబడింది. పేరు, విలువ, యూనిట్ లేదా పరిధి తప్పుగా కనిపిస్తే అసలు నివేదికను తనిఖీ చేయండి. AI వివరణలు అవగాహన కోసం మాత్రమే; మీకు ఏ చికిత్స అవసరమో అవి చెప్పలేవు.';

  @override
  String get yourProfile => 'మీ ప్రొఫైల్';

  @override
  String get cancel => 'రద్దు చేయండి';

  @override
  String get delete => 'తొలగించండి';

  @override
  String get moveReport => 'నివేదికను తరలించండి';

  @override
  String get gotIt => 'అర్థమైంది';

  @override
  String get reportDetails => 'నివేదిక వివరాలు';

  @override
  String get shareReport => 'నివేదికను పంచుకోండి';

  @override
  String get moreReportActions => 'నివేదిక కోసం మరిన్ని చర్యలు';

  @override
  String get attemptHistory => 'గత ప్రయత్నాలు';

  @override
  String get compareReports => 'నివేదికలను పోల్చండి';

  @override
  String get readParsedReport => 'వివరాలను సంగ్రహించిన నివేదికను చదవండి';

  @override
  String get moveRecycle => 'రీసైకిల్ బిన్‌కు తరలించండి';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get reportSummary => 'నివేదిక సారాంశం';

  @override
  String get updateSummary => 'సారాంశాన్ని నవీకరించండి';

  @override
  String get summaryLoading => 'మీ ఫలితాలను సరళమైన భాషలో వివరిస్తున్నాము…';

  @override
  String get checkSummary => 'సారాంశాన్ని తనిఖీ చేయండి';

  @override
  String get summaryFailed =>
      'సారాంశాన్ని రూపొందించలేకపోయాము. మీరు మళ్లీ ప్రయత్నించవచ్చు.';

  @override
  String get summaryPlaceholder =>
      'ముఖ్యమైన ఫలితాల గురించి సరళమైన భాషలో వివరణ ఇక్కడ కనిపిస్తుంది.';

  @override
  String get retrySummary => 'సారాంశం కోసం మళ్లీ ప్రయత్నించండి';

  @override
  String get generateSummary => 'సారాంశాన్ని రూపొందించండి';

  @override
  String get loadingResults => 'నివేదిక ఫలితాలను లోడ్ చేస్తున్నాము…';

  @override
  String get somethingWrong => 'ఏదో సమస్య తలెత్తింది';

  @override
  String get viewTrends => 'కాలక్రమ మార్పులను చూడండి';

  @override
  String get originalFile => 'అసలు ఫైల్';

  @override
  String get testValues => 'పరీక్ష విలువలు';

  @override
  String get summary => 'సారాంశం';

  @override
  String get checkStatus => 'స్థితిని తనిఖీ చేయండి';

  @override
  String get viewOriginal => 'అసలుదాన్ని చూడండి';

  @override
  String get verifiedResults => 'ధృవీకరించిన ఫలితాలు';

  @override
  String get resultTapHelp =>
      'పరీక్ష దేనిని కొలుస్తుందో అర్థం చేసుకోవడానికి ఫలితాన్ని నొక్కండి.';

  @override
  String get reviewResults => 'గుర్తించిన ఫలితాలను సమీక్షించండి';

  @override
  String get keepFile => 'అయినా ఫైల్‌ను ఉంచండి';

  @override
  String get patientDetails => 'రోగి వివరాలు';

  @override
  String get name => 'పేరు';

  @override
  String get age => 'వయస్సు';

  @override
  String get gender => 'లింగం';

  @override
  String get bookingId => 'బుకింగ్ ID';

  @override
  String get sampleCollection => 'నమూనా సేకరణ';

  @override
  String get labDetails => 'ల్యాబ్ వివరాలు';

  @override
  String get labName => 'ల్యాబ్ పేరు';

  @override
  String get address => 'చిరునామా';

  @override
  String get phone => 'ఫోన్';

  @override
  String get location => 'ప్రదేశం';

  @override
  String get belowRange => 'పరిధి కంటే తక్కువ';

  @override
  String get aboveRange => 'పరిధి కంటే ఎక్కువ';

  @override
  String get withinRange => 'పేర్కొన్న పరిధిలో ఉంది';

  @override
  String get rangeUnclear => 'పరిధి స్పష్టంగా లేదు';

  @override
  String get understandResultAction => 'ఈ ఫలితాన్ని అర్థం చేసుకోండి  →';

  @override
  String get parsedReport => 'వివరాలను సంగ్రహించిన నివేదిక';

  @override
  String get reports => 'నివేదికలు';

  @override
  String get trends => 'కాలక్రమ మార్పులు';

  @override
  String get openingPage => 'ప్రారంభ పేజీ';

  @override
  String get home => 'హోమ్';

  @override
  String get family => 'కుటుంబం';

  @override
  String get switchProfile => 'ప్రొఫైల్‌ను మార్చండి';

  @override
  String get currentProfile => 'ప్రస్తుత ప్రొఫైల్';

  @override
  String get viewProfile => 'ఈ ప్రొఫైల్‌ను చూడండి';

  @override
  String get manageFamily => 'కుటుంబ ప్రొఫైళ్లను నిర్వహించండి';

  @override
  String get chooseProfile => 'ప్రొఫైల్‌ను ఎంచుకోండి';

  @override
  String get notifications => 'నోటిఫికేషన్‌లు';

  @override
  String get homeTitle => 'కొంత స్పష్టత.\nఅన్నీ ఒకే చోట.';

  @override
  String get nextReportTitle =>
      'మీ తదుపరి నివేదిక,\nమీరు సిద్ధమైనప్పుడు మీ కోసం సిద్ధంగా.';

  @override
  String get homeSubtitle => 'PDFలు, ఫోటోలు, కుటుంబ రికార్డులు.';

  @override
  String get uploadReport => 'నివేదికను అప్‌లోడ్ చేయండి';

  @override
  String get recentReport => 'ఇటీవలి నివేదిక';

  @override
  String get viewAll => 'అన్నీ చూడండి';

  @override
  String get reportsUnavailable =>
      'నివేదికలు అందుబాటులో లేవు. ఇంటర్నెట్ కనెక్షన్ ఉన్నప్పుడు మళ్లీ ప్రయత్నించండి.';

  @override
  String get emptyHomeTitle => 'మీ కథ ఇక్కడే మొదలవుతుంది';

  @override
  String get emptyHomeHelp =>
      'మీ రికార్డుల చరిత్రను స్పష్టంగా నమోదు చేసుకోవడం ప్రారంభించడానికి మీ మొదటి నివేదికను అప్‌లోడ్ చేయండి.';

  @override
  String get uploadFirstReport => 'మీ మొదటి నివేదికను అప్‌లోడ్ చేయండి';

  @override
  String get latestResults => 'తాజా ఫలితాలు';

  @override
  String get allTrends => 'అన్ని కాలక్రమ మార్పులు';

  @override
  String get reviewedResultsHelp =>
      'సమీక్షించిన ఫలితాలు అందుబాటులోకి వచ్చినప్పుడు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get searchTests => 'పరీక్షలను వెతకండి';

  @override
  String get noHealthData =>
      'ఇంకా ఆరోగ్య డేటా లేదు. మీ ఆరోగ్య చరిత్రను చూడటానికి నివేదికను అప్‌లోడ్ చేయండి.';

  @override
  String get noTestsFound => 'పరీక్షలు ఏవీ దొరకలేదు';

  @override
  String get shorterTestName =>
      'పరీక్ష పేరును మరింత సంక్షిప్తంగా నమోదు చేసి ప్రయత్నించండి.';

  @override
  String get clearSearch => 'శోధనను క్లియర్ చేయండి';

  @override
  String get unitUnavailable => 'యూనిట్ అందుబాటులో లేదు';

  @override
  String get uploadingReport => 'నివేదికను అప్‌లోడ్ చేస్తున్నాము…';

  @override
  String get organizingReport => 'మీ నివేదికను క్రమబద్ధీకరిస్తున్నాము…';

  @override
  String get uploadAReport => 'ఒక నివేదికను అప్‌లోడ్ చేయండి';

  @override
  String get uploadHelp =>
      'PDF లేదా స్పష్టమైన ఫోటోను ఎంచుకోండి. సేవ్ చేసే ముందు వివరాలను తనిఖీ చేయవచ్చు.';

  @override
  String get chooseSource => 'మూలాన్ని ఎంచుకోండి';

  @override
  String get uploadPdfImage => 'PDF లేదా చిత్రాన్ని అప్‌లోడ్ చేయండి';

  @override
  String get chooseReportFiles => 'మీ ఫైళ్ల నుంచి నివేదికను ఎంచుకోండి';

  @override
  String get selectReportPages =>
      'ఒకటి లేదా అంతకంటే ఎక్కువ నివేదిక పేజీలను ఎంచుకోండి';

  @override
  String get capturePage => 'పేజీ మొత్తం కనిపించేలా ఫోటో తీయండి';

  @override
  String get supportedFormats => 'అనుమతించే ఫైల్ రకాలు: PDF, JPG, PNG';

  @override
  String get confirmFile =>
      'మీరు జోడించాలనుకుంటున్న ఫైల్ ఇదేనని నిర్ధారించుకోండి.';

  @override
  String get addReport => 'నివేదికను జోడించండి';

  @override
  String get chooseDifferentFile => 'వేరే ఫైల్‌ను ఎంచుకోండి';

  @override
  String get uploadWait =>
      'దీనికి కొంత సమయం పట్టవచ్చు. దయచేసి యాప్‌ను తెరిచి ఉంచండి.';

  @override
  String get reportNeedsAttention => 'నివేదికను పరిశీలించాలి';

  @override
  String get verifyBeforeSaving =>
      'గుర్తించిన ఫలితాలను సేవ్ చేసే ముందు అసలు నివేదికతో సరిపోల్చి తనిఖీ చేయండి.';

  @override
  String get viewVerifiedResults => 'ధృవీకరించిన ఫలితాలను చూడండి';

  @override
  String get viewOriginalReport => 'అసలు నివేదికను చూడండి';

  @override
  String get viewReportStatus => 'నివేదిక స్థితిని చూడండి';

  @override
  String get viewResults => 'ఫలితాలను చూడండి';

  @override
  String get viewOriginalFile => 'అసలు ఫైల్‌ను చూడండి';

  @override
  String get retryExtraction => 'ఫలితాలను వెలికితీయడానికి మళ్లీ ప్రయత్నించండి';

  @override
  String get done => 'పూర్తయింది';

  @override
  String get duplicateReport =>
      'ఈ నివేదిక ఇప్పటికే ఉన్నదాని నకలులా కనిపిస్తోంది';

  @override
  String get duplicateHelp => 'ఈ ఫైల్ ఇప్పటికే మీ నివేదికల్లో ఉండవచ్చు.';

  @override
  String get keepExisting => 'ఇప్పటికే ఉన్నదాన్ని ఉంచండి';

  @override
  String get processAgain => 'PDFను మళ్లీ ప్రాసెస్ చేయండి';

  @override
  String get uploadNewCopy => 'కొత్త కాపీగా అప్‌లోడ్ చేయండి';

  @override
  String get reportLimitReached => 'నివేదికల పరిమితిని చేరుకున్నారు';

  @override
  String get reportLimitHelp => 'మీరు మీ నివేదికల పరిమితిని చేరుకున్నారు.';

  @override
  String get upgrade => 'అప్‌గ్రేడ్ చేయండి';

  @override
  String get back => 'వెనుకకు';

  @override
  String get uploadFailedTitle => 'నివేదికను అప్‌లోడ్ చేయలేకపోయాము';

  @override
  String get uploadFailed => 'అప్‌లోడ్ విఫలమైంది';

  @override
  String get retrySameFile => 'అదే ఫైల్‌తో మళ్లీ ప్రయత్నించండి';

  @override
  String get chooseAnotherFile => 'మరో ఫైల్‌ను ఎంచుకోండి';

  @override
  String get aiDisclaimer =>
      'మీ ఆరోగ్య నివేదికలను క్రమబద్ధంగా ఉంచుకోవడానికి, మరింత బాగా అర్థం చేసుకోవడానికి Doclyzer తోడ్పడుతుంది. అందించిన సమాచారం అవగాహన కోసం మాత్రమే; ఇది వైద్య సలహా, రోగ నిర్ధారణ లేదా చికిత్స కాదు. వైద్య మార్గదర్శకత్వం కోసం ఎల్లప్పుడూ అర్హత కలిగిన ఆరోగ్య సంరక్షణ నిపుణులను సంప్రదించండి.';

  @override
  String collectedOn(String date) {
    return 'సేకరించిన తేదీ $date';
  }

  @override
  String uploadedOn(String date) {
    return 'అప్‌లోడ్ చేసిన తేదీ $date';
  }

  @override
  String labRangeValue(String range) {
    return 'ల్యాబ్ పరిధి $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits క్రెడిట్‌లు';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count నివేదికలు',
      one: '1 నివేదిక',
      zero: 'నివేదికలు లేవు',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'నివేదిక లోడ్ కావడానికి ఊహించిన దానికంటే ఎక్కువ సమయం పడుతోంది. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get summaryUpdateFailed =>
      'ప్రస్తుతం సారాంశాన్ని నవీకరించలేకపోయాము. సేవ్ చేసిన సారాంశం ఇంకా అందుబాటులో ఉంది.';

  @override
  String get summaryCreateFailed =>
      'ప్రస్తుతం సారాంశాన్ని రూపొందించలేకపోయాము. మీ ఫలితాలు కింద ఇంకా అందుబాటులో ఉన్నాయి.';

  @override
  String get reassignFailed =>
      'నివేదికను వేరే ప్రొఫైల్‌కు కేటాయించలేకపోయాము. మళ్లీ ప్రయత్నించండి.';

  @override
  String get confirmRecycle => 'రీసైకిల్ బిన్‌కు తరలించాలా?';

  @override
  String get recycleHelp =>
      '30 రోజుల వరకు నివేదికలు > రీసైకిల్ బిన్ నుంచి ఈ నివేదికను పునరుద్ధరించవచ్చు. ఆ తర్వాత ఇది శాశ్వతంగా తొలగించబడుతుంది.';

  @override
  String get reportRecycled => 'నివేదిక రీసైకిల్ బిన్‌కు తరలించబడింది';

  @override
  String get reportDeleteFailed =>
      'నివేదికను తొలగించలేకపోయాము. మళ్లీ ప్రయత్నించండి.';

  @override
  String get addProfileBeforeMove =>
      'ఈ నివేదికను తరలించే ముందు మరో కుటుంబ ప్రొఫైల్‌ను జోడించండి.';

  @override
  String get moveReportHelp =>
      'ఈ నివేదికను తప్పు ప్రొఫైల్‌కు జోడించి ఉంటే, మరో కుటుంబ సభ్యుడిని ఎంచుకోండి.';

  @override
  String get confirmMoveReport => 'ఈ నివేదికను తరలించాలా?';

  @override
  String get aboutSampleDates => 'నమూనా తేదీల గురించి';

  @override
  String get multipleDatesHelp =>
      'ఈ నివేదికలో ఒకటి కంటే ఎక్కువ నమూనా తేదీలకు చెందిన ఫలితాలు ఉన్నాయి. ఫలితాన్ని తెరిచి, దాని తేదీని అసలు నివేదికతో సరిపోల్చి తనిఖీ చేయండి.';

  @override
  String get missingDateHelp =>
      'నమూనా తేదీ అంటే నమూనా తీసుకున్న తేదీ. ఈ నివేదికలో విశ్వసనీయమైన తేదీని కనుగొనలేకపోయాము. నమూనా తేదీ అప్‌లోడ్ తేదీకి భిన్నమైనది. ఫలితం తేదీని తనిఖీ చేయడానికి లేదా సరిదిద్దడానికి ఆ ఫలితాన్ని తెరవండి.';

  @override
  String get uploading => 'అప్‌లోడ్ అవుతోంది';

  @override
  String get waitingToProcess => 'ప్రాసెస్ చేయడానికి వేచి ఉంది';

  @override
  String get readingReport => 'నివేదికను చదువుతున్నాము';

  @override
  String get readyToReview => 'సమీక్షకు సిద్ధంగా ఉంది';

  @override
  String get someResultsNeedReview => 'కొన్ని ఫలితాలను సమీక్షించాలి';

  @override
  String get couldNotReadReport => 'నివేదికను చదవలేకపోయాము';

  @override
  String get processingStopped => 'ప్రాసెసింగ్ ఆగిపోయింది';

  @override
  String get couldNotProcessReport => 'నివేదికను ప్రాసెస్ చేయలేకపోయాము';

  @override
  String get reportRefreshFailed =>
      'ఈ నివేదికను మళ్లీ లోడ్ చేయలేకపోయాము. చివరిగా లోడ్ చేసిన ఫలితాన్ని చూపిస్తున్నాము.';

  @override
  String get multipleSampleDates => 'ఒకటి కంటే ఎక్కువ నమూనా తేదీలు ';

  @override
  String get missingSampleDate => 'నమూనా తేదీ కనుగొనబడలేదు ';

  @override
  String get reportAnalyzing =>
      'మేము ఈ నివేదికను విశ్లేషిస్తున్నాము. మీరు ఈ తెర నుంచి వెళ్లవచ్చు; ఫలితాలు సిద్ధమైనప్పుడు కనిపిస్తాయి.';

  @override
  String get extractionIncompleteTitle =>
      'అన్ని ఫలితాలను విశ్వసనీయంగా వెలికితీయలేకపోయాము';

  @override
  String get extractionIncompleteHelp =>
      'స్వయంచాలకంగా ఫలితాలను వెలికితీసే ప్రక్రియ పూర్తికాలేదు. గుర్తించిన వరుసలను సేవ్ చేసే ముందు అసలు నివేదికతో సరిపోల్చి తనిఖీ చేయండి.';

  @override
  String get verifiedRowsHelp =>
      'ఈ వరుసలను అసలు నివేదికతో సరిపోల్చి తనిఖీ చేశారు. ఇతర వరుసలను ఇంకా సమీక్షించాల్సి ఉండవచ్చు.';

  @override
  String get noTestValues =>
      'ఈ నివేదికలో పరీక్ష విలువలు ఏవీ దొరకలేదు. అందులోని సమాచారాన్ని తనిఖీ చేయడానికి అసలు ఫైల్‌ను తెరవండి.';

  @override
  String get processingRetryHelp =>
      'ప్రాసెసింగ్ పూర్తికాకముందే ఆగిపోయింది. మీ ఫైల్ సేవ్ చేయబడింది. మళ్లీ ప్రయత్నించడానికి ‘మళ్లీ ప్రయత్నించండి’ నొక్కండి.';

  @override
  String get resultsNeedCheck =>
      'కొన్ని ఫలితాలను అసలు నివేదికతో సరిపోల్చి తనిఖీ చేయాలి. కింద గుర్తించిన వరుసలను మీరు సమీక్షించవచ్చు.';

  @override
  String get readerModeHelp =>
      'సులభంగా చూడటానికి, మరింత స్పష్టంగా చదవడానికి వివరాలను సంగ్రహించిన నివేదిక పఠన విధానంలో అందుబాటులో ఉంది.';

  @override
  String get aiRangeHelp =>
      'ప్రాసెసింగ్ సమయంలో AI పరిధిని అర్థం చేసుకుని నమోదు చేసింది. అసలు నివేదికను తనిఖీ చేయండి.';

  @override
  String get checkResultHelp =>
      'ఈ ఫలితంపై ఆధారపడే ముందు అసలు నివేదికతో సరిపోల్చి తనిఖీ చేయండి.';

  @override
  String get preferredRangeHelp =>
      'ల్యాబ్ ముద్రించిన ప్రాధాన్య వర్గంతో పోల్చబడింది; అది మీకు వర్తిస్తుందో నిర్ధారించుకోండి.';

  @override
  String get categoryComparisonHelp =>
      'ఈ పోలికలో ల్యాబ్ ముద్రించిన ప్రాధాన్య వర్గాన్ని ఉపయోగించారు. ఆ వర్గం మీకు వర్తిస్తుందో తనిఖీ చేయండి.';

  @override
  String get missingSavedResult =>
      'ఈ విలువకు సరిపోలే సేవ్ చేసిన ఫలితాన్ని గుర్తించలేకపోయాము. అసలు నివేదికను తనిఖీ చేయండి లేదా ఈ నివేదికను మళ్లీ లోడ్ చేయండి.';

  @override
  String get unreviewedTest =>
      'AI వివరణల కోసం ఈ పరీక్షను ఇంకా సమీక్షించలేదు. అసలు నివేదికను తనిఖీ చేసి, ఫలితం గురించి మీ వైద్యులతో చర్చించండి.';

  @override
  String get unsafeResult =>
      'వెలికితీసిన ఫలితం స్పష్టంగా లేదు, కాబట్టి దాన్ని సురక్షితంగా వివరించలేము. అసలు నివేదికను తనిఖీ చేయండి.';

  @override
  String get filterReports => 'నివేదికలను వడపోయండి';

  @override
  String get sortReports => 'నివేదికలను క్రమబద్ధీకరించండి';

  @override
  String get recycleBin => 'రీసైకిల్ బిన్';

  @override
  String get healthHistory => 'ఆరోగ్య చరిత్ర';

  @override
  String get shareProfile => 'ప్రొఫైల్‌ను పంచుకోండి';

  @override
  String get reportsUnavailableTitle => 'నివేదికలు అందుబాటులో లేవు';

  @override
  String get reportsLoadFailed =>
      'నివేదికలను లోడ్ చేయలేకపోయాము. ఇంటర్నెట్ కనెక్షన్ ఉన్నప్పుడు మళ్లీ ప్రయత్నించండి.';

  @override
  String get upload => 'అప్‌లోడ్ చేయండి';

  @override
  String get reportsFor => 'వీరి నివేదికలు';

  @override
  String get searchReports => 'నివేదికలు లేదా ల్యాబ్‌లను వెతకండి';

  @override
  String get filters => 'వడపోతలు';

  @override
  String get noReportsYet => 'ఇంకా నివేదికలు లేవు';

  @override
  String get noMatchingReports => 'మీ శోధనకు సరిపోలే నివేదికలు లేవు.';

  @override
  String get differentSearch =>
      'వేరే పరీక్ష, ప్రయోగశాల లేదా వడపోతతో ప్రయత్నించండి.';

  @override
  String get clearFilters => 'శోధన, వడపోతలను తీసివేయండి';

  @override
  String get original => 'అసలుది';

  @override
  String get switchActiveProfile =>
      'ప్రస్తుతం ఉపయోగిస్తున్న ప్రొఫైల్‌ను మార్చండి';

  @override
  String get switchProfileHelp =>
      'మరొకరి నివేదికలను చూడండి. అప్‌లోడ్‌లు, కాలక్రమ మార్పుల కోసం ప్రస్తుతం ఉపయోగిస్తున్న ప్రొఫైల్ కూడా మారుతుంది.';

  @override
  String get multipleCollectionDates => 'ఒకటి కంటే ఎక్కువ సేకరణ తేదీలు';

  @override
  String get unknownCollectionDate => 'సేకరణ తేదీ తెలియదు';

  @override
  String get profileLoadFailed =>
      'ప్రొఫైళ్లను లోడ్ చేయలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get pleaseTryAgain => 'దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get deleteProfileConfirm => 'ప్రొఫైల్‌ను తొలగించాలా?';

  @override
  String get deleteProfileHelp =>
      'ఈ ప్రొఫైల్ తీసివేయబడుతుంది. దీనికి అనుసంధానమైన డేటాపై ప్రభావం ఉంటుంది.';

  @override
  String get profileDeleteFailed =>
      'ప్రొఫైల్‌ను తొలగించలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get addFamilyMember => 'కుటుంబ సభ్యుడిని జోడించండి';

  @override
  String get familyUnavailable => 'కుటుంబ ప్రొఫైళ్లు అందుబాటులో లేవు';

  @override
  String get familyIntro =>
      'వ్యక్తులవారీగా క్రమబద్ధీకరించిన నివేదికలు, కాలక్రమ మార్పులు';

  @override
  String get noProfilesYet => 'ఇంకా ప్రొఫైళ్లు లేవు';

  @override
  String get noProfilesHelp =>
      'మీ లేదా కుటుంబ సభ్యుల నివేదికలను క్రమబద్ధంగా ఉంచడానికి ప్రొఫైల్‌ను జోడించండి.';

  @override
  String get yourFamily => 'మీ కుటుంబం';

  @override
  String get upgradeProfiles =>
      'మరిన్ని ప్రొఫైళ్లను జోడించడానికి అప్‌గ్రేడ్ చేయండి';

  @override
  String get editProfile => 'ప్రొఫైల్‌ను సవరించండి';

  @override
  String get deleteProfile => 'ప్రొఫైల్‌ను తొలగించండి';

  @override
  String get active => 'ప్రస్తుతం ఉపయోగంలో ఉంది';

  @override
  String get setActive => 'ప్రస్తుత ప్రొఫైల్‌గా ఎంచుకోండి';

  @override
  String get viewReports => 'నివేదికలను చూడండి';

  @override
  String get notNow => 'ఇప్పుడు వద్దు';

  @override
  String get openSettings => 'సెట్టింగ్‌లను తెరవండి';

  @override
  String get enableNotifications => 'నోటిఫికేషన్‌లను ఆన్ చేయండి';

  @override
  String get enableNotificationsConfirm => 'నోటిఫికేషన్‌లను ఆన్ చేయాలా?';

  @override
  String get notificationsEnabled => 'నివేదిక నోటిఫికేషన్‌లు ఆన్ చేయబడ్డాయి';

  @override
  String get notificationsStayOff =>
      'నోటిఫికేషన్‌లు ఆఫ్‌లోనే ఉన్నాయి. తర్వాత పరికర సెట్టింగ్‌లలో వాటిని ఆన్ చేయవచ్చు.';

  @override
  String get notificationsFailed =>
      'నోటిఫికేషన్‌లను ఆన్ చేయలేకపోయాము. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get switchProfileFailed =>
      'ప్రొఫైళ్లను మార్చలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get sourceReportFailed => 'మూల నివేదికను తెరవలేకపోయాము.';

  @override
  String get partialRefreshFailed =>
      'కొంత సమాచారాన్ని మళ్లీ లోడ్ చేయలేకపోయాము. మళ్లీ ప్రయత్నించడానికి కిందికి లాగండి.';

  @override
  String get knowReportReady => 'మీ నివేదిక సిద్ధమైనప్పుడు తెలుసుకోండి';

  @override
  String get oneResult => 'ఒక ఫలితం';

  @override
  String get sameDayResults => 'ఒకే రోజుకు చెందిన ఫలితాలు';

  @override
  String get verificationRequired => 'ధృవీకరణ అవసరం';

  @override
  String get accountCreatedLogin =>
      'మీ ఖాతా విజయవంతంగా సృష్టించబడింది. లాగిన్ చేయడానికి కొనసాగండి.';

  @override
  String get continueLogin => 'లాగిన్ చేయడానికి కొనసాగండి';

  @override
  String get allReports => 'అన్ని నివేదికలు';

  @override
  String get filterReviewed => 'సమీక్షించినవి';

  @override
  String get filterNeedsReview => 'సమీక్ష అవసరం';

  @override
  String get filterProcessing => 'ప్రాసెస్ అవుతోంది';

  @override
  String get filterOriginalOnly => 'అసలుది మాత్రమే';

  @override
  String get reportDateNewest => 'నివేదిక తేదీ · కొత్తవి ముందు';

  @override
  String get reportDateOldest => 'నివేదిక తేదీ · పాతవి ముందు';

  @override
  String get uploadDateNewest => 'అప్‌లోడ్ తేదీ · కొత్తవి ముందు';

  @override
  String get uploadDateOldest => 'అప్‌లోడ్ తేదీ · పాతవి ముందు';

  @override
  String get switchAction => 'మార్చండి';

  @override
  String get collectionDate => 'సేకరణ తేదీ';

  @override
  String get copy => 'కాపీ చేయండి';

  @override
  String get history => 'చరిత్ర';

  @override
  String get loadingReport => 'నివేదికను లోడ్ చేస్తున్నాము…';

  @override
  String get restore => 'పునరుద్ధరించండి';

  @override
  String get revoke => 'రద్దు చేయండి';

  @override
  String get testName => 'పరీక్ష పేరు';

  @override
  String get viewReport => 'నివేదికను చూడండి';

  @override
  String get closeAccount => 'ఖాతాను మూసివేయండి';

  @override
  String get createShareLink => 'పంచుకోవడానికి లింక్‌ను సృష్టించండి';

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'స్వరూపం మార్చబడింది, కానీ తదుపరిసారి సేవ్ చేయడం సాధ్యపడలేదు.';

  @override
  String get uiThisReportIsNoLongerAvailable =>
      'ఈ నివేదిక ఇప్పుడు అందుబాటులో లేదు.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'నోటిఫికేషన్ ప్రివ్యూలను నిర్వహించడానికి పరికర సెట్టింగ్‌లను తెరవండి.';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'అప్‌లోడ్ ఆమోదించబడే వరకు ఈ స్క్రీన్‌ని తెరిచి ఉంచండి.';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'అప్‌లోడ్‌కు అంతరాయం ఏర్పడి ఉండవచ్చు';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'నివేదికలను తనిఖీ చేయండి. అది తప్పిపోయినట్లయితే, అదే ఫైల్‌ను మళ్లీ జోడించండి.';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'నోటిఫికేషన్‌లను తీసివేయడం సాధ్యపడలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiConnectionUnavailable => 'కనెక్షన్ అందుబాటులో లేదు';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'మీ సెషన్‌ని తనిఖీ చేయడం సాధ్యపడలేదు. ఇంటర్నెట్‌కి కనెక్ట్ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiSignInWithAnotherAccount => 'మరొక ఖాతాతో సైన్ ఇన్ చేయండి';

  @override
  String get uiNoActiveProfile => 'సక్రియ ప్రొఫైల్ లేదు';

  @override
  String get uiDismissUploadNotice => 'అప్‌లోడ్ నోటీసును తీసివేయండి';

  @override
  String get uiDismissReadyNotifications =>
      'సిద్ధంగా ఉన్న నోటిఫికేషన్‌లను తీసివేయండి';

  @override
  String get uiRequestSupport => 'మద్దతు అభ్యర్థించండి';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'మేము డయాగ్నొస్టిక్ IDలను చేర్చుతాము, తద్వారా బృందం దర్యాప్తు చేయవచ్చు.';

  @override
  String get uiSendRequest => 'అభ్యర్థనను పంపండి';

  @override
  String get uiWhatHappenedOptional => 'ఏం జరిగింది? (ఐచ్ఛికం)';

  @override
  String get uiReviewResult => 'రివ్యూ ఫలితం';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'సేవ్ చేయడానికి ముందు ఈ ఫీల్డ్‌లను అసలు నివేదికతో సరిపోల్చండి.';

  @override
  String get uiOriginallyExtracted => 'వాస్తవానికి సంగ్రహించబడింది';

  @override
  String get uiReloadReport => 'నివేదికను మళ్లీ లోడ్ చేయండి';

  @override
  String get uiResultAsPrinted => 'ముద్రించినట్లుగా ఫలితం';

  @override
  String get uiUnitIfShown => 'యూనిట్ (చూపినట్లయితే)';

  @override
  String get uiLabReferenceRangeIfShown => 'ల్యాబ్ సూచన పరిధి (చూపినట్లయితే)';

  @override
  String get uiCheckYourReport => 'మీ నివేదికను తనిఖీ చేయండి';

  @override
  String get uiNoAttemptHistoryAvailable => 'ప్రయత్న చరిత్ర అందుబాటులో లేదు.';

  @override
  String get uiIInspectedTheOriginal => 'నేను అసలైనదాన్ని పరిశీలించాను';

  @override
  String get uiChooseTwoReports => 'రెండు నివేదికలను ఎంచుకోండి';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'ఒకే వ్యక్తి కోసం రికార్డులను ఉపయోగించండి. సరిపోలిక పరీక్షలు పక్కపక్కనే కనిపిస్తాయి.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'ముందుగా పాత నివేదికను మరియు రెండవ నివేదికను ఎంచుకోండి.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'అనుకూలమైనప్పుడు మాత్రమే పోల్చబడుతుంది. అనుకూలత నిర్ధారించబడే వరకు వేర్వేరు యూనిట్లు లేదా పద్ధతులు విడిగా చూపబడతాయి.';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'మార్పు అనేది రోగనిర్ధారణ కాదు. ప్రతి ఫలితాన్ని దాని స్వంత నివేదిక విరామంతో సరిపోల్చండి మరియు మీ వైద్యునితో సందర్భాన్ని చర్చించండి.';

  @override
  String get uiChooseDifferentReports => 'విభిన్న నివేదికలను ఎంచుకోండి';

  @override
  String get uiEarlierReport => 'మునుపటి నివేదిక';

  @override
  String get uiLaterReport => 'తరువాత నివేదిక';

  @override
  String get uiYourReportPages => 'మీ నివేదిక పేజీలు';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'నివేదిక వలె పేజీలను అదే క్రమంలో ఉంచండి.';

  @override
  String get uiAddAnotherPage => 'మరొక పేజీని జోడించండి';

  @override
  String get uiChoosePagesFromGallery => 'గ్యాలరీ నుండి పేజీలను ఎంచుకోండి';

  @override
  String get uiAdjustPage => 'పేజీని సర్దుబాటు చేయండి';

  @override
  String get uiRetake => 'తిరిగి తీసుకోండి';

  @override
  String get uiUseAdjustedPage => 'సర్దుబాటు చేసిన పేజీని ఉపయోగించండి';

  @override
  String get uiResetChanges => 'మార్పులను రీసెట్ చేయండి';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'ప్రతి ఫలితాన్ని మూలల లోపల ఉంచండి.';

  @override
  String get uiRotate => 'తిప్పండి';

  @override
  String get uiReportRestored => 'నివేదిక పునరుద్ధరించబడింది';

  @override
  String get uiDeleteReportPermanently => 'నివేదికను శాశ్వతంగా తొలగించాలా?';

  @override
  String get uiDeletePermanently => 'శాశ్వతంగా తొలగించండి';

  @override
  String get uiReportPermanentlyDeleted => 'నివేదిక శాశ్వతంగా తొలగించబడింది';

  @override
  String get uiEmptyRecycleBin => 'రీసైకిల్ బిన్ ఖాళీ చేయాలా?';

  @override
  String get uiDeleteAll => 'అన్నింటినీ తొలగించండి';

  @override
  String get uiRecycleBinIsEmpty => 'రీసైకిల్ బిన్ ఖాళీగా ఉంది.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'తీసివేయడానికి ముందు తొలగించబడిన నివేదికలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get uiEmptyRecycleBind657e2 => 'ఖాళీ రీసైకిల్ బిన్';

  @override
  String get uiCheckDetectedResult => 'గుర్తించిన ఫలితాన్ని తనిఖీ చేయండి';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'ఈ అడ్డు వరుసను అసలు నివేదికతో సరిపోల్చండి. సేవ్ చేయడానికి ముందు ఏవైనా OCR తప్పులను సరిదిద్దండి.';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'నేను ఈ ఫలితాన్ని అసలు నివేదికకు విరుద్ధంగా తనిఖీ చేసాను';

  @override
  String get uiSaving => 'సేవ్ చేస్తోంది...';

  @override
  String get uiSaveVerifiedResult => 'ధృవీకరించబడిన ఫలితాన్ని సేవ్ చేయండి';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'ఫలితాలు ఏవీ కనుగొనబడలేదు. అసలు నివేదికను వీక్షించండి లేదా ప్రాసెసింగ్‌ని మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'కనుగొనబడిన విలువలు సేవ్ చేయబడిన ఫలితాలు కావడానికి ముందు అసలు నివేదికకు వ్యతిరేకంగా తనిఖీ చేయాలి.';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'కొన్ని అడ్డు వరుసలు లేకపోవచ్చు. మొత్తం అసలు నివేదికను పరిశీలించండి.';

  @override
  String get uiResult => 'ఫలితం';

  @override
  String get uiUnitOptional => 'యూనిట్ (ఐచ్ఛికం)';

  @override
  String get uiReferenceRangeOptional => 'సూచన పరిధి (ఐచ్ఛికం)';

  @override
  String get uiVerified => 'ధృవీకరించబడింది';

  @override
  String get uiGiftVoucher => 'బహుమతి వోచర్';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'బహుమతి వోచర్‌ను రీడీమ్ చేయండి మరియు క్రెడిట్‌లను నేరుగా మీ బ్యాలెన్స్‌కు జోడించండి.';

  @override
  String get uiCurrentPlan => 'ప్రస్తుత ప్రణాళిక';

  @override
  String get uiCreditBalance => 'క్రెడిట్ బ్యాలెన్స్';

  @override
  String get uiPlanLimits => 'ప్రణాళిక పరిమితులు';

  @override
  String get uiBuyCredits => 'క్రెడిట్‌లను కొనుగోలు చేయండి';

  @override
  String get uiRecentBillingActivity => 'ఇటీవలి బిల్లింగ్ కార్యాచరణ';

  @override
  String get uiRefreshStatus => 'స్థితిని రిఫ్రెష్ చేయండి';

  @override
  String get uiNoRecentOrdersYet => 'ఇంకా ఇటీవలి ఆర్డర్‌లు లేవు.';

  @override
  String get uiVoucherCode => 'వోచర్ కోడ్';

  @override
  String get uiCheckout => 'చెక్అవుట్';

  @override
  String get uiApply => 'దరఖాస్తు చేసుకోండి';

  @override
  String get uiClear => 'క్లియర్';

  @override
  String get uiPay => 'చెల్లించండి';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'ఈ సమయంలో క్రెడిట్ ప్యాక్‌లు అందుబాటులో లేవు.';

  @override
  String get uiBuy => 'కొనండి';

  @override
  String get uiRetryPayment => 'చెల్లింపును మళ్లీ ప్రయత్నించండి';

  @override
  String get uiPromoCode => 'ప్రోమో కోడ్';

  @override
  String get uiEnterPromoCode => 'ప్రోమో కోడ్‌ని నమోదు చేయండి';

  @override
  String get uiChooseAPlan => 'ఒక ప్రణాళికను ఎంచుకోండి';

  @override
  String get uiNoPlansAvailableAtThisTime =>
      'ఈ సమయంలో ప్లాన్‌లు ఏవీ అందుబాటులో లేవు.';

  @override
  String get uiHaveAPromoCode => 'ప్రోమో కోడ్ ఉందా?';

  @override
  String get uiCURRENTPLAN => 'ప్రస్తుత ప్రణాళిక';

  @override
  String get uiManageNotifications => 'నోటిఫికేషన్‌లను నిర్వహించండి';

  @override
  String get uiAll => 'అన్నీ';

  @override
  String get uiUnread => 'చదవలేదు';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'యాక్సెస్ వెంటనే ఆగిపోతుంది. మీరు 30 రోజుల్లో సైన్ ఇన్ చేసి పునరుద్ధరించవచ్చు. ఆ తర్వాత, మీ ఖాతా మరియు నిల్వ చేయబడిన ఫైల్‌లు సక్రియ నిల్వ నుండి తొలగించబడతాయి.';

  @override
  String get uiCloseMyAccount => 'నా ఖాతాను మూసివేయండి';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'మీ రికార్డులు డాక్లైజర్‌లో ఉంటాయి.';

  @override
  String get uiTakeACopyOfYourRecords => 'మీ రికార్డుల కాపీని తీసుకోండి.';

  @override
  String get uiWhoseRecords => 'ఎవరి రికార్డులు?';

  @override
  String get uiCouldNotLoadProfiles => 'ప్రొఫైల్‌లను లోడ్ చేయడం సాధ్యపడలేదు';

  @override
  String get uiLoadingProfiles => 'ప్రొఫైల్‌లను లోడ్ చేస్తోంది...';

  @override
  String get uiAllProfiles => 'అన్ని ప్రొఫైల్‌లు';

  @override
  String get uiDateRange => 'తేదీ పరిధి';

  @override
  String get uiUseAllDates => 'అన్ని తేదీలను ఉపయోగించండి';

  @override
  String get uiINCLUDEINTHISEXPORT => 'ఈ ఎగుమతిలో చేర్చండి';

  @override
  String get uiOriginalReports => 'అసలు నివేదికలు';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'మీరు అప్‌లోడ్ చేసిన PDFలు మరియు చిత్రాలు';

  @override
  String get uiTestResults => 'పరీక్ష ఫలితాలు';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'వాటి సమీక్ష స్థితితో CSVగా ఫలితాలు';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'ఎగుమతులు వ్యక్తిగత సమాచారాన్ని కలిగి ఉంటాయి. మీరు విశ్వసించే చోట వాటిని నిల్వ చేయండి.';

  @override
  String get uiDeleteAccount => 'ఖాతాను తొలగించండి';

  @override
  String get uiContinueToDeletion => 'తొలగింపును కొనసాగించండి';

  @override
  String get uiKeepMyAccount => 'నా ఖాతాను ఉంచండి';

  @override
  String get uiBeforeYouLeave => 'మీరు బయలుదేరే ముందు';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'దయచేసి ఇది ఏమి తీసివేస్తుందో చదవండి.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'మీ ఖాతాను తొలగించడం వలన మీరు నిర్వహించే అన్ని ప్రొఫైల్‌లపై ప్రభావం పడుతుంది.';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'మీ ఖాతా మరియు వ్యక్తిగత ప్రొఫైల్';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'మీ భాగస్వామ్య లింక్‌ల ద్వారా యాక్సెస్ చేయండి';

  @override
  String get uiKeepACopyFirst => 'ముందుగా ఒక కాపీని ఉంచండి';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'మీరు ఉంచాలనుకుంటున్న సమాచారాన్ని ఎగుమతి చేయండి.';

  @override
  String get uiExportData => 'డేటాను ఎగుమతి చేయండి';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'యాక్సెస్ వెంటనే ఆగిపోతుంది. మీరు 30 రోజులలోపు పునరుద్ధరించవచ్చు. ఆ తర్వాత, మీ డేటా సక్రియ నిల్వ నుండి తీసివేయబడుతుంది.';

  @override
  String get uiAccountPendingDeletion => 'ఖాతా తొలగింపు పెండింగ్‌లో ఉంది';

  @override
  String get uiRestoreMyAccount => 'నా ఖాతాను పునరుద్ధరించు';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'మీ ప్రొఫైల్, ప్రొఫైల్‌లు మరియు సమ్మతి రికార్డులతో సహా మీ ఖాతా డేటా కాపీని డౌన్‌లోడ్ చేసుకోండి.';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'మీ ఖాతా వెంటనే నిలిపివేయబడింది. మీరు దీన్ని 30 రోజుల్లోపు పునరుద్ధరించవచ్చు. ఆ తర్వాత, మీ డేటా శాశ్వతంగా తొలగించబడుతుంది.';

  @override
  String get uiCurrentPassword => 'ప్రస్తుత పాస్వర్డ్';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'యాప్ లాక్‌ని మార్చడం సాధ్యపడలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'మీ రికార్డులు.\nభాగస్వామ్యం చేయడానికి మీ ఎంపిక.';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'మీకు అవసరమైనప్పుడు యాక్సెస్‌ని సమీక్షించండి.';

  @override
  String get uiAppLock => 'యాప్ లాక్';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'మీ పరికరం యొక్క బయోమెట్రిక్ లేదా పాస్‌కోడ్ లాక్‌ని ఉపయోగించండి.';

  @override
  String get uiNotificationPreviews => 'నోటిఫికేషన్ ప్రివ్యూలు';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'మీ పరికర సెట్టింగ్‌లలో లాక్-స్క్రీన్ ప్రివ్యూలను నియంత్రించండి.';

  @override
  String get uiContactSupport => 'మద్దతును సంప్రదించండి';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'మీరు ఎంచుకుంటే మాత్రమే నివేదికలను అటాచ్ చేయండి.';

  @override
  String get uiWhatCanWeHelpYouWith => 'మేము మీకు ఏమి సహాయం చేయగలము?';

  @override
  String get uiPOPULARQUESTIONS => 'జనాదరణ పొందిన ప్రశ్నలు';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'మీ శోధనకు సరిపోలే సహాయ కథనాలు ఏవీ లేవు.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'మీ ఆరోగ్యం లేదా పరీక్ష ఫలితాల గురించిన సందేహాల కోసం, అర్హత కలిగిన ఆరోగ్య సంరక్షణ నిపుణులతో మాట్లాడండి.';

  @override
  String get uiYourReportsAClearerPicture =>
      'మీ నివేదికలు. ఒక స్పష్టమైన చిత్రం.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'మీ ఆరోగ్య చరిత్రను కలిసి ఉంచండి.';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'నివేదికలను నిల్వ చేయండి, ఫలితాలను సమీక్షించండి, మార్పులను అనుసరించండి మరియు మీ వైద్యునితో భాగస్వామ్యం చేయండి.';

  @override
  String get uiEducationalInformationOnly => 'విద్యా సమాచారం మాత్రమే';

  @override
  String get uiSearchHelpArticles => 'సహాయ కథనాలను శోధించండి';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'నోటిఫికేషన్ యాక్సెస్‌ని మార్చడానికి పరికర సెట్టింగ్‌ల యాప్‌ను తెరవండి.';

  @override
  String get uiSavePreferences => 'ప్రాధాన్యతలను సేవ్ చేయండి';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'పరికర అనుమతులను సెట్టింగ్‌లలో మార్చవచ్చు.';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'ఈ పరికరంలో రిపోర్ట్ అప్‌డేట్‌లను పొందండి';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'నివేదిక ఎప్పుడు సిద్ధంగా ఉందో తెలుసుకోవడానికి నోటిఫికేషన్‌లను అనుమతించండి. క్రింద మార్కెటింగ్ అనేది ఒక ప్రత్యేక ఎంపిక.';

  @override
  String get uiREPORTACTIVITY => 'రిపోర్ట్ కార్యాచరణ';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'రిపోర్ట్ కార్యాచరణ సెట్టింగ్‌లకు తాజా సర్వర్ వెర్షన్ అవసరం.';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'సున్నితమైన లాక్-స్క్రీన్ ప్రివ్యూలు';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'నివేదిక పేర్లు మరియు వ్యక్తిగత వివరాలు ఎల్లప్పుడూ దాచబడతాయి.';

  @override
  String get uiOTHERMESSAGES => 'ఇతర సందేశాలు';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'ప్రతి వ్యక్తి యొక్క నివేదికలు మరియు ట్రెండ్‌లను కలిసి ఉంచండి.';

  @override
  String get uiPersonDetails => 'వ్యక్తి వివరాలు';

  @override
  String get uiDateOfBirth => 'పుట్టిన తేదీ';

  @override
  String get uiRelationship => 'సంబంధం';

  @override
  String get uiEnterAName => 'పేరును నమోదు చేయండి';

  @override
  String get uiClearDateOfBirth => 'పుట్టిన తేదీని క్లియర్ చేయండి';

  @override
  String get uiOptionalEGParentOrChild =>
      'ఐచ్ఛికం, ఉదా. తల్లిదండ్రులు లేదా బిడ్డ';

  @override
  String get uiInviteFriendsEarnCredits =>
      'స్నేహితులను ఆహ్వానించండి, క్రెడిట్‌లను సంపాదించండి';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'మీ కోడ్‌ను షేర్ చేయండి మరియు రివార్డ్‌ల అన్‌లాక్‌గా ప్రతి ఆహ్వానాన్ని అనుసరించండి.';

  @override
  String get uiYOURREFERRALCODE => 'మీ రెఫరల్ కోడ్';

  @override
  String get uiShareInvite => 'ఆహ్వానాన్ని షేర్ చేయండి';

  @override
  String get uiCopyCode => 'కాపీ కోడ్';

  @override
  String get uiHaveACode => 'కోడ్ ఉందా?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'మీ ఆహ్వాన రివార్డ్‌ను క్లెయిమ్ చేయడానికి మీతో షేర్ చేసిన కోడ్‌ని నమోదు చేయండి.';

  @override
  String get uiHowRewardsWork => 'రివార్డులు ఎలా పని చేస్తాయి';

  @override
  String get uiNoFriendsReferredYet => 'ఇంకా స్నేహితులు ఎవరూ సూచించబడలేదు';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'వారి పురోగతిని చూడటానికి మీ ఆహ్వానాన్ని ఇక్కడ షేర్ చేయండి.';

  @override
  String get uiReferralCode => 'రెఫరల్ కోడ్';

  @override
  String get uiSetNewPassword => 'కొత్త పాస్‌వర్డ్‌ని సెట్ చేయండి';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'మీ ఇమెయిల్ మరియు మీ కొత్త పాస్‌వర్డ్‌లోని లింక్ నుండి రీసెట్ టోకెన్‌ను నమోదు చేయండి.';

  @override
  String get uiResetPassword => 'పాస్‌వర్డ్‌ని రీసెట్ చేయండి';

  @override
  String get uiBackToLogin => 'తిరిగి లాగిన్‌కి';

  @override
  String get uiResetToken => 'టోకెన్‌ని రీసెట్ చేయండి';

  @override
  String get uiNewPassword => 'కొత్త పాస్‌వర్డ్';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'మీ ఖాతాతో అనుబంధించబడిన ఇమెయిల్ చిరునామాను నమోదు చేయండి మరియు మీ పాస్‌వర్డ్‌ని రీసెట్ చేయడానికి మేము మీకు లింక్‌ను పంపుతాము.';

  @override
  String get uiSendResetLink => 'రీసెట్ లింక్‌ని పంపండి';

  @override
  String get uiRevokeSession => 'సెషన్‌ను ఉపసంహరించాలా?';

  @override
  String get uiCurrentSession => 'ప్రస్తుత సెషన్';

  @override
  String get uiSkip => 'దాటవేయి';

  @override
  String get uiChangePassword => 'పాస్వర్డ్ మార్చండి';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'మీ ప్రస్తుత పాస్‌వర్డ్‌ను నమోదు చేసి, కొత్తదాన్ని ఎంచుకోండి.';

  @override
  String get uiNewPasswordd850ee => 'కొత్త పాస్‌వర్డ్';

  @override
  String get uiConfirmNewPassword => 'కొత్త పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get uiGettingThingsReady => 'విషయాలను సిద్ధం చేస్తోంది…';

  @override
  String get uiLinkAccessHistory => 'లింక్ యాక్సెస్ చరిత్ర';

  @override
  String get uiNoAccessEventsYet => 'ఇంకా యాక్సెస్ ఈవెంట్‌లు లేవు.';

  @override
  String get uiDefaultShareLinkExpiry => 'డిఫాల్ట్ షేర్ లింక్ గడువు ముగిసింది';

  @override
  String get uiSave => 'సేవ్ చేయండి';

  @override
  String get uiReviewSharing => 'సమీక్ష భాగస్వామ్యం';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'వ్యక్తి, నివేదికలు మరియు యాక్సెస్‌ని తనిఖీ చేయండి.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'ఎంపికను సవరించండి లేదా సెట్టింగ్‌లను యాక్సెస్ చేయండి';

  @override
  String get uiRevokeShareLink => 'షేర్ లింక్‌ని ఉపసంహరించాలా?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'ఈ లింక్ పని చేయడం ఆగిపోతుంది. మీరు కొత్తదాన్ని సృష్టించవచ్చు.';

  @override
  String get uiShareLinkReady => 'షేర్ లింక్ సిద్ధంగా ఉంది';

  @override
  String get uiAccessCodeShareSeparately =>
      'యాక్సెస్ కోడ్ - విడిగా భాగస్వామ్యం చేయండి';

  @override
  String get uiCopyAccessCode => 'యాక్సెస్ కోడ్‌ను కాపీ చేయండి';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'ఈ కోడ్‌ని ఈ పరికరంలో సేవ్ చేయడం సాధ్యపడలేదు. తర్వాత ఉపయోగం కోసం ఇప్పుడే కాపీ చేయండి.';

  @override
  String get uiShareLink => 'లింక్‌ను భాగస్వామ్యం చేయండి';

  @override
  String get uiCopyLink => 'లింక్‌ని కాపీ చేయండి';

  @override
  String get uiRevokeLink => 'లింక్‌ని ఉపసంహరించుకోండి';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'ఈ పరికరంలో కోడ్ అందుబాటులో లేదు. సేవ్ చేసిన కోడ్‌ని ఉపయోగించండి లేదా కొత్త లింక్‌ని సృష్టించండి.';

  @override
  String get uiActiveSharedLinks => 'సక్రియ భాగస్వామ్య లింక్‌లు';

  @override
  String get uiShare => 'షేర్ చేయండి';

  @override
  String get uiCreateANewShareLink => 'కొత్త భాగస్వామ్య లింక్‌ను సృష్టించండి';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'ఈ ప్రొఫైల్ కోసం ప్రస్తుత మరియు భవిష్యత్తు నివేదికలను చేర్చండి.';

  @override
  String get uiChooseReports => 'నివేదికలను ఎంచుకోండి';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'దిగువ ఎంచుకున్న నివేదికలను మాత్రమే భాగస్వామ్యం చేయండి.';

  @override
  String get uiSelectAll => 'అన్నింటినీ ఎంచుకోండి';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'భాగస్వామ్యం చేయడానికి సమీక్షించిన నివేదికలు అందుబాటులో లేవు.';

  @override
  String get uiSelectedTestResults => 'ఎంచుకున్న పరీక్ష ఫలితాలు';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'ఈ నివేదికల నుండి మీరు ఎంచుకున్న ఫలితాలను మాత్రమే చేర్చండి.';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'ఈ నివేదికలలో సేవ్ చేయబడిన పరీక్ష ఫలితాలు ఏవీ అందుబాటులో లేవు.';

  @override
  String get uiUpgradeOrManage => 'అప్‌గ్రేడ్ చేయండి లేదా నిర్వహించండి';

  @override
  String get uiExpiry => 'గడువు:';

  @override
  String get uiRequireAnAccessCode => 'యాక్సెస్ కోడ్ అవసరం';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'లింక్ నుండి విడిగా కోడ్‌ను భాగస్వామ్యం చేయండి.';

  @override
  String get uiTryAgain => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get uiClearExpiry => 'క్లియర్ గడువు';

  @override
  String get onboardingStoreEyebrow => '01 / భద్రపరచండి';

  @override
  String get onboardingStoreTitle => 'ప్రతి నివేదిక,\nఒక సుపరిచితమైన స్థలం.';

  @override
  String get onboardingStoreBody =>
      'మీ కోసం మరియు మీరు శ్రద్ధ వహించే వ్యక్తుల కోసం PDFలు మరియు ఫోటోలను కలిసి ఉంచండి.';

  @override
  String get onboardingUnderstandEyebrow => '02 / అర్థం చేసుకోండి';

  @override
  String get onboardingUnderstandTitle => 'సంఖ్యలు,\nచదవడం సులభతరం చేసింది.';

  @override
  String get onboardingUnderstandBody =>
      'మీ నివేదిక నుండి ప్రతి పరీక్ష, దాని యూనిట్ మరియు విరామాన్ని చూడండి. అసలైనదాన్ని ఎప్పుడైనా తనిఖీ చేయండి.';

  @override
  String get onboardingTrackEyebrow => '03 / ట్రాక్ & షేర్ చేయండి';

  @override
  String get onboardingTrackTitle =>
      'మార్పులను చూడండి.\nసందర్భాన్ని భాగస్వామ్యం చేయండి.';

  @override
  String get onboardingTrackBody =>
      'కాలక్రమేణా ఫలితాలను అనుసరించండి మరియు మీ వైద్యుడు చూడగలిగే వాటిని ఖచ్చితంగా ఎంచుకోండి.';

  @override
  String get onboardingNext => 'తదుపరి';

  @override
  String get onboardingGetStarted => 'ప్రారంభించండి';

  @override
  String get uiSupportRequestSent => 'మద్దతు అభ్యర్థన పంపబడింది.';

  @override
  String get uiTestNameAndResultAreRequired => 'పరీక్ష పేరు మరియు ఫలితం అవసరం.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD ఆకృతిలో చెల్లుబాటు అయ్యే సేకరణ తేదీని ఉపయోగించండి.';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'ఈ దిద్దుబాటును సేవ్ చేయడం సాధ్యపడలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiReportsUnavailable => 'నివేదికలు అందుబాటులో లేవు';

  @override
  String get uiTryAgain042c86 => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get uiTwoReportsAreNeeded => 'రెండు నివేదికలు కావాలి';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'ఫలితాలను సరిపోల్చడానికి ఈ ప్రొఫైల్ కోసం పాత నివేదికను జోడించండి.';

  @override
  String get uiCannotCompareYet => 'ఇంకా పోల్చలేము';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'ఈ నివేదికలను పోల్చడానికి సరిపోలే ఫలితాలు అందుబాటులో లేవు.';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'నివేదికలను లోడ్ చేయడం సాధ్యపడలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCouldNotOpenPhotosOrCamera =>
      'ఫోటోలు లేదా కెమెరా తెరవడం సాధ్యపడలేదు.';

  @override
  String get uiCouldNotOpenCamera => 'కెమెరాను తెరవడం సాధ్యపడలేదు.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'ఈ పేజీలను సిద్ధం చేయడం సాధ్యపడలేదు. చదవలేని పేజీని మళ్లీ తీసుకుని, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCouldNotAdjustThisPage =>
      'ఈ పేజీని సర్దుబాటు చేయడం సాధ్యపడలేదు.';

  @override
  String get uiNoChartableResultYet => 'ఇంకా చార్ట్ చేయదగిన ఫలితం లేదు';

  @override
  String get uiProfiles => 'ప్రొఫైల్స్';

  @override
  String get uiReports => 'నివేదికలు';

  @override
  String get uiShareLinks => 'లింక్‌లను భాగస్వామ్యం చేయండి';

  @override
  String get uiAIChat => 'AI చాట్';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'అర్హత సారాంశాన్ని లోడ్ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'బిల్లింగ్ స్థితిని రిఫ్రెష్ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'రసీదు డౌన్‌లోడ్ త్వరలో అందుబాటులోకి వస్తుంది.';

  @override
  String get uiSubtotal => 'ఉపమొత్తం';

  @override
  String get uiDiscount => 'తగ్గింపు';

  @override
  String get uiTotal => 'మొత్తం';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'క్రెడిట్ ప్యాక్‌లను లోడ్ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'చెల్లింపు క్యాప్చర్ పెండింగ్‌లో ఉంది. మరొక చెక్అవుట్ ప్రారంభించే ముందు స్థితిని రిఫ్రెష్ చేయండి.';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'క్రెడిట్‌లు విజయవంతంగా వర్తించబడ్డాయి.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ఆర్డర్‌ని సృష్టించడం విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'చెల్లింపు స్వీకరించబడింది. క్రెడిట్‌లు జోడించబడటానికి ముందు సర్వర్ సయోధ్య కోసం వేచి ఉంది.';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'చెల్లింపు విఫలమైంది. మీరు సిద్ధంగా ఉన్నప్పుడు చెక్అవుట్‌ని మళ్లీ ప్రయత్నించవచ్చు.';

  @override
  String get uiPaymentFailedTryAgain =>
      'చెల్లింపు విఫలమైంది. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCreditsAdded => 'క్రెడిట్‌లు జోడించబడ్డాయి!';

  @override
  String get uiPromoCodeApplied => 'ప్రోమో కోడ్ వర్తింపజేయబడింది.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'చెల్లింపు స్వీకరించబడింది, కానీ ఈ ఆర్డర్ సమీక్ష పెండింగ్‌లో ఉంది.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'సయోధ్య సమయంలో చెల్లింపు విఫలమైంది.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'చెల్లింపు నిర్ధారించబడింది. సర్వర్ సయోధ్య ఇంకా పెండింగ్‌లో ఉంది.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'చెల్లింపు ధృవీకరించబడింది. సయోధ్య పెండింగ్‌లో ఉంది, దయచేసి త్వరలో రిఫ్రెష్ చేయండి.';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'చెల్లింపు స్వీకరించబడింది కానీ ధృవీకరణ ఇంకా పెండింగ్‌లో ఉంది. దయచేసి స్థితిని రిఫ్రెష్ చేయండి.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'ప్లాన్‌లను లోడ్ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'సభ్యత్వాన్ని సృష్టించడం విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'సభ్యత్వం విఫలమైంది. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiPlanUpgraded => 'ప్లాన్ అప్‌గ్రేడ్ చేయబడింది!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'చెల్లింపు స్వీకరించబడింది కానీ ధృవీకరణ విఫలమైంది. ప్లాన్ త్వరలో అప్‌గ్రేడ్ చేయబడుతుంది.';

  @override
  String get uiNotificationsUnavailable => 'నోటిఫికేషన్‌లు అందుబాటులో లేవు';

  @override
  String get uiAllQuietForNow => 'ప్రస్తుతానికి అంతా నిశ్శబ్దం.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'ఏదైనా కొత్తది ఉన్నప్పుడు రిపోర్ట్ అప్‌డేట్‌లు మరియు షేరింగ్ రిమైండర్‌లు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get uiNoUnreadUpdates => 'చదవని నవీకరణలు లేవు';

  @override
  String get uiYouReAllCaughtUp => 'మీరంతా పట్టుకున్నారు.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'నోటిఫికేషన్‌లను లోడ్ చేయడం సాధ్యపడలేదు. కనెక్ట్ అయినప్పుడు మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiManageSharedLinks => 'భాగస్వామ్య లింక్‌లను నిర్వహించండి';

  @override
  String get uiExportYourData => 'మీ డేటాను ఎగుమతి చేయండి';

  @override
  String get uiReadThePrivacyPolicy => 'గోప్యతా విధానాన్ని చదవండి';

  @override
  String get uiTermsOfUse => 'ఉపయోగ నిబంధనలు';

  @override
  String get uiPrivacyPolicy => 'గోప్యతా విధానం';

  @override
  String get uiDateOfBirthOptional => 'పుట్టిన తేదీ, ఐచ్ఛికం';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'సంబంధం తప్పనిసరిగా 50 అక్షరాలు లేదా అంతకంటే తక్కువ ఉండాలి.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'ప్రొఫైల్‌ను సేవ్ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiReferralsUnavailable => 'సిఫార్సులు అందుబాటులో లేవు';

  @override
  String get uiYourRewards => 'మీ రివార్డులు';

  @override
  String get uiReferralProgress => 'రెఫరల్ పురోగతి';

  @override
  String get uiFriendsReferred => 'స్నేహితులు సూచించారు';

  @override
  String get uiCreditsEarned => 'క్రెడిట్‌లు సంపాదించారు';

  @override
  String get uiPendingRewards => 'పెండింగ్‌లో ఉన్న రివార్డ్‌లు';

  @override
  String get uiBlockedRewards => 'రివార్డ్‌లను నిరోధించారు';

  @override
  String get uiInviteeBonus => 'ఆహ్వానితుల బోనస్';

  @override
  String get uiFirstAnalysis => 'మొదటి విశ్లేషణ';

  @override
  String get uiFirstPurchase => 'మొదటి కొనుగోలు';

  @override
  String get uiMonthlyCap => 'నెలవారీ టోపీ';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'సిఫార్సులను లోడ్ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiReferralCodeCopied => 'రెఫరల్ కోడ్ కాపీ చేయబడింది.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'మీ ఇమెయిల్ లింక్ నుండి రీసెట్ టోకెన్‌ని నమోదు చేయండి';

  @override
  String get uiEnterYourNewPassword => 'మీ కొత్త పాస్‌వర్డ్‌ని నమోదు చేయండి';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'పాస్‌వర్డ్‌ని రీసెట్ చేయడం సాధ్యపడలేదు. దయచేసి కొత్త లింక్‌ను అభ్యర్థించండి.';

  @override
  String get uiEnterYourEmailAddress => 'మీ ఇమెయిల్ చిరునామాను నమోదు చేయండి';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'రీసెట్ లింక్‌ని పంపడం సాధ్యపడలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiFailedToLoadSessions => 'సెషన్‌లను లోడ్ చేయడంలో విఫలమైంది.';

  @override
  String get uiFailedToRevokeSession => 'సెషన్‌ను ఉపసంహరించుకోవడంలో విఫలమైంది.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'పాస్‌వర్డ్ మార్చడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'పరికర సెట్టింగ్‌లను తెరిచి, డాక్లైజర్ కోసం నోటిఫికేషన్‌లను అనుమతించండి.';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'నివేదికలను లోడ్ చేయడం సాధ్యపడలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'పరీక్ష ఫలితాలను లోడ్ చేయడం సాధ్యపడలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'భాగస్వామ్యం చేయడానికి కనీసం ఒక నివేదికను ఎంచుకోండి.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'భాగస్వామ్యం చేయడానికి కనీసం ఒక పరీక్ష ఫలితాన్ని ఎంచుకోండి.';

  @override
  String get uiLinkCopiedToClipboard => 'లింక్ క్లిప్‌బోర్డ్‌కి కాపీ చేయబడింది';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'యాక్సెస్ కోడ్ క్లిప్‌బోర్డ్‌కి కాపీ చేయబడింది';

  @override
  String get uiOnePerson => '1 వ్యక్తి';

  @override
  String uiPeopleCount(String count) {
    return '$count వ్యక్తులు';
  }

  @override
  String uiActionsFor(String name) {
    return '$name కోసం చర్యలు';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'ప్రొఫైల్‌లను మార్చడం సాధ్యం కాలేదు. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$nameకి మార్చబడింది';
  }

  @override
  String get uiAnalyzeOnePage => '1 పేజీని విశ్లేషించండి';

  @override
  String uiAnalyzePages(String count) {
    return '$count పేజీలను విశ్లేషించండి';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'మీ నివేదికలో చూపిన క్రమంలో పేజీలను లాగండి';

  @override
  String get uiCheckEveryPage => 'విశ్లేషించే ముందు ప్రతి పేజీని తనిఖీ చేయండి';

  @override
  String get uiOnePageAdded => '1 పేజీ జోడించబడింది';

  @override
  String uiPagesAdded(String count) {
    return '$count పేజీలు జోడించబడ్డాయి';
  }

  @override
  String get uiReorder => 'క్రమాన్ని మార్చండి';

  @override
  String uiPageNumber(String number) {
    return 'పేజీ $number';
  }

  @override
  String uiRemovePage(String number) {
    return '$number పేజీని తీసివేయండి';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · పేజీ $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'క్రాప్ అంచులు: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count ఎంచుకున్న నివేదికలు';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count ఎంచుకున్న పరీక్ష ఫలితాలు';
  }

  @override
  String get uiAllCurrentFutureReports =>
      'అన్ని ప్రస్తుత మరియు భవిష్యత్తు నివేదికలు';

  @override
  String get uiNoExpiry => 'గడువు లేదు';

  @override
  String uiExpiresDate(String date) {
    return '$date గడువు ముగుస్తుంది';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'యాక్సెస్ కోడ్ అవసరం. లింక్ నుండి విడిగా భాగస్వామ్యం చేయండి.';

  @override
  String get uiNoAccessCodeRequired => 'యాక్సెస్ కోడ్ అవసరం లేదు.';

  @override
  String uiExpiresColonDate(String date) {
    return 'గడువు ముగుస్తుంది: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name యొక్క నివేదికలను భాగస్వామ్యం చేయండి';
  }

  @override
  String uiProfileReports(String name) {
    return '$name యొక్క నివేదికలు';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count ఎంచుకున్న ఫలితాలు';
  }

  @override
  String get uiAccessCodeRequiredShort => 'యాక్సెస్ కోడ్ అవసరం';

  @override
  String uiPastLinksCount(String count) {
    return 'గత లింక్‌లు · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return '$date గడువు ముగిసింది';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'రద్దు చేయబడింది · $date సృష్టించబడింది';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum సక్రియ లింక్‌ల $currentని ఉపయోగించడం.';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename మరియు దాని నిల్వ చేయబడిన ఫైల్‌ను తొలగించాలా? ఇది రద్దు చేయబడదు.';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'నివేదికను తొలగించడం సాధ్యం కాలేదు: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'అన్ని $count నివేదికలు మరియు వాటి నిల్వ చేసిన ఫైల్‌లను శాశ్వతంగా తొలగించాలా? ఇది రద్దు చేయబడదు.';
  }

  @override
  String get uiRecycleBinEmptied => 'రీసైకిల్ బిన్ ఖాళీ చేయబడింది';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return 'తొలగించబడిన $deleted నివేదికలు. $failed తొలగించబడలేదు; మళ్ళీ ప్రయత్నించండి.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'రీసైకిల్ బిన్‌ను ఖాళీ చేయడం సాధ్యపడలేదు: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'ప్రొఫైల్: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'సేకరించినది: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'అప్‌లోడ్ చేయబడింది: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'తొలగించబడినది: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'శాశ్వత తొలగింపు ఆన్: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'మిగిలి ఉన్న రోజులు: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer =>
      'డాక్లైజర్ కోసం యాప్ లాక్‌ని నిర్ధారించండి';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'యాప్ లాక్‌ని ఆఫ్ చేసే ముందు నిర్ధారించండి';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'మీ ఆరోగ్య రికార్డులను వీక్షించడానికి డాక్లైజర్‌ని అన్‌లాక్ చేయండి';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'నివేదికను అప్‌లోడ్ చేయడానికి ముందు డిఫాల్ట్ ప్రొఫైల్‌ను సృష్టించండి.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'మీ టైమ్‌లైన్‌ని చూసే ముందు డిఫాల్ట్ ప్రొఫైల్‌ను సృష్టించండి.';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'ప్రస్తుతం ప్రొఫైల్‌లను లోడ్ చేయడం సాధ్యపడలేదు.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'ప్రొఫైల్ డేటా లోడ్ కానందున ప్రస్తుతం అప్‌లోడ్ చేయడం సాధ్యపడదు. దయచేసి API సర్వర్ రన్ అవుతుందని నిర్ధారించుకుని, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'ప్రొఫైల్ డేటా లోడ్ కానందున ప్రస్తుతం టైమ్‌లైన్‌ని తెరవడం సాధ్యం కాదు. దయచేసి API సర్వర్ రన్ అవుతుందని నిర్ధారించుకుని, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'ప్రస్తుతం ప్రొఫైల్‌లను లోడ్ చేయడం సాధ్యపడలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'భాగస్వామ్య లింక్‌లను లోడ్ చేయడం సాధ్యపడలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiPasswordChanged => 'పాస్‌వర్డ్ మార్చబడింది';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'ఆ నివేదికను తెరవడం సాధ్యం కాలేదు. నివేదిక లైబ్రరీని ప్రయత్నించండి.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'మీ ఖాతా సమీక్షలో ఉన్నప్పుడు ఈ చర్య తాత్కాలికంగా అందుబాటులో ఉండదు.';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'ఈ విభాగాన్ని తెరవడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiAppLockIsUnavailable => 'యాప్ లాక్ అందుబాటులో లేదు';

  @override
  String get uiDoclyzerIsLocked => 'డాక్లైజర్ లాక్ చేయబడింది';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'సేవ్ చేసిన యాప్ లాక్ సెట్టింగ్‌ని చదవడం సాధ్యపడలేదు. కొనసాగించడానికి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'కొనసాగించడానికి మీ పరికర పాస్‌కోడ్ లేదా బయోమెట్రిక్‌లను ఉపయోగించండి.';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'మీ ఖాతా సమీక్షలో ఉన్నప్పుడు అప్‌లోడ్‌లు తాత్కాలికంగా అందుబాటులో ఉండవు.';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'అప్‌లోడ్‌ను ప్రారంభించడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiJustNow => 'ఇప్పుడే';

  @override
  String get uiAdditionalDetails => 'అదనపు వివరాలు:';

  @override
  String get uiSaveCorrection => 'దిద్దుబాటును సేవ్ చేయండి';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'ఫైల్‌లను తెరవడం సాధ్యపడలేదు. యాక్సెస్‌ని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'కెమెరాను తెరవడం సాధ్యపడలేదు. అనుమతిని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'ఫోటోలను తెరవడం సాధ్యపడలేదు. అనుమతిని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'ఎంచుకున్న ఫైల్‌ని యాక్సెస్ చేయడం సాధ్యపడలేదు.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'ఎంచుకున్న ఫైల్‌ని యాక్సెస్ చేయడం సాధ్యపడలేదు';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'కనెక్షన్ పోయింది. అప్‌లోడ్ సర్వర్‌కు చేరి ఉండవచ్చు. అదే ఫైల్‌ను సురక్షితంగా మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiCouldNotLoadExistingReport =>
      'ఇప్పటికే ఉన్న నివేదికను లోడ్ చేయడం సాధ్యపడలేదు';

  @override
  String get uiAddingTo => 'జోడించడం';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'కొన్ని ఫలితాలు సమీక్ష అవసరం. మీ అసలు నివేదిక సేవ్ చేయబడింది.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'మేము ఈ ఆకృతిని చదవలేకపోయాము. మీ ఫైల్ సేవ్ చేయబడింది.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'నివేదిక విజయవంతంగా అన్వయించబడింది. ఫలితాలు మరియు ట్రెండ్‌లు అందుబాటులో ఉన్నాయి.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'మీ నివేదిక ఇంకా విశ్లేషించబడుతోంది. దాని స్థితిని తనిఖీ చేయడానికి దాన్ని తెరవండి.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'ప్రాసెసింగ్ ఆగిపోయింది. మీ ఫైల్ సేవ్ చేయబడింది. మీరు మళ్లీ ప్రయత్నించవచ్చు.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'సంగ్రహించిన పరీక్ష విలువలు జోడించబడలేదు. మీరు ఇప్పటికీ పత్రాన్ని తెరవవచ్చు మరియు భాగస్వామ్యం చేయవచ్చు. మీ ట్రెండ్‌లు మారవు.';

  @override
  String get uiYourOriginalIsSaved => 'మీ ఒరిజినల్ సేవ్ చేయబడింది.';

  @override
  String get uiInitialUpload => 'ప్రారంభ అప్‌లోడ్';

  @override
  String get uiParsedSuccessfully => 'విజయవంతంగా అన్వయించబడింది';

  @override
  String get uiParsingFailed => 'అన్వయించడం విఫలమైంది';

  @override
  String get uiExtractionIncomplete => 'సంగ్రహణ అసంపూర్తిగా ఉంది';

  @override
  String get uiTransientFailure => 'తాత్కాలిక వైఫల్యం';

  @override
  String get uiTerminalFailure => 'టెర్మినల్ వైఫల్యం';

  @override
  String get uiFailedToLoadAttemptHistory =>
      'ప్రయత్న చరిత్రను లోడ్ చేయడంలో విఫలమైంది';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'ఈ నివేదిక యొక్క ఫైల్ ఇప్పుడు అందుబాటులో లేదు.';

  @override
  String get uiCompareResults => 'ఫలితాలను సరిపోల్చండి';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'తేడా లెక్కించబడలేదు. అనుకూలతకు నిర్ధారణ అవసరం.';

  @override
  String get uiUnitNotRecorded => 'యూనిట్ రికార్డ్ చేయబడలేదు';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'ఈ నివేదికల మధ్య సంఖ్యాపరమైన మార్పు లేదు.';

  @override
  String get uiUnableToRestore => 'పునరుద్ధరించడం సాధ్యం కాలేదు:';

  @override
  String get uiEnterAGiftVoucherCode => 'బహుమతి వోచర్ కోడ్‌ను నమోదు చేయండి.';

  @override
  String get uiApplyVoucher => 'వోచర్‌ను వర్తింపజేయండి';

  @override
  String get uiNotAvailable => 'అందుబాటులో లేదు';

  @override
  String get uiViewReceipt => 'రసీదుని వీక్షించండి';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'బహుమతి వోచర్ చెల్లదు లేదా ఇప్పటికే రీడీమ్ చేయబడింది.';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'బహుమతి వోచర్ ఇప్పటికే రీడీమ్ చేయబడింది.';

  @override
  String get uiGiftVoucherHasBeenVoided => 'బహుమతి వోచర్ రద్దు చేయబడింది.';

  @override
  String get uiGiftVoucherHasExpired => 'బహుమతి వోచర్ గడువు ముగిసింది.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'ఈ బహుమతి వోచర్‌ని రీడీమ్ చేయడం సాధ్యపడలేదు.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'ఈ బహుమతి వోచర్‌ని రీడీమ్ చేయడం సాధ్యపడలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiEnterAPromoCodeToApply =>
      'దరఖాస్తు చేయడానికి ప్రోమో కోడ్‌ను నమోదు చేయండి.';

  @override
  String get uiPromoCodeNotFound => 'ప్రోమో కోడ్ కనుగొనబడలేదు.';

  @override
  String get uiPromoCodeIsInactive => 'ప్రోమో కోడ్ నిష్క్రియంగా ఉంది.';

  @override
  String get uiPromoCodeHasExpired => 'ప్రోమో కోడ్ గడువు ముగిసింది.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'ఈ ప్యాక్‌కి ప్రోమో కోడ్ వర్తించదు.';

  @override
  String get uiPromoCodeUsageLimitReached =>
      'ప్రోమో కోడ్ వినియోగ పరిమితిని చేరుకున్నారు.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'మీరు ఇప్పటికే ఈ ప్రోమో కోడ్‌ని ఉపయోగించారు.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'ప్రోమో కోడ్‌ని వర్తింపజేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'క్రెడిట్‌లను జోడించే ముందు ఈ ఆర్డర్ సమీక్ష కోసం ఫ్లాగ్ చేయబడింది.';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'సయోధ్య సమయంలో చెల్లింపు విఫలమైంది. మీరు సురక్షితంగా మళ్లీ ప్రయత్నించవచ్చు.';

  @override
  String get uiAwaitingCapture => 'క్యాప్చర్ కోసం వేచి ఉంది';

  @override
  String get uiLastPaymentFailed => 'చివరి చెల్లింపు విఫలమైంది';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'మీరు సురక్షితంగా చెక్అవుట్‌ని మళ్లీ ప్రయత్నించవచ్చు.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'ప్రోమో కోడ్‌లు సభ్యత్వాలకు ఇంకా మద్దతు ఇవ్వలేదు.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'ఎగుమతి డౌన్‌లోడ్ చేయడం సాధ్యపడలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'అసలైన నివేదికలు లేదా పరీక్ష ఫలితాలను ఎంచుకోండి.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'ఎగుమతి అభ్యర్థించబడింది. రిఫ్రెష్ చేయడానికి \"స్థితిని తనిఖీ చేయి\" నొక్కండి.';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'ఎగుమతిని అభ్యర్థించడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'ఎగుమతి సిద్ధంగా ఉంది. డౌన్‌లోడ్ URL అందుబాటులో ఉంది.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'ఎగుమతి స్థితిని తనిఖీ చేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'ఖాతాను మూసివేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiPrepareExport => 'ఎగుమతిని సిద్ధం చేయండి';

  @override
  String get uiSaveExport => 'ఎగుమతిని ఆదా చేయండి';

  @override
  String get uiPrepareExportAgain => 'మళ్లీ ఎగుమతిని సిద్ధం చేయండి';

  @override
  String get uiAllDates => 'అన్ని తేదీలు';

  @override
  String get uiPreparingAccountDetails => 'ఖాతా వివరాలను సిద్ధం చేస్తోంది';

  @override
  String get uiFamilyMemberProfiles => 'కుటుంబ సభ్యుల ప్రొఫైల్‌లు';

  @override
  String get uiUploadedReports => 'అప్‌లోడ్ చేసిన నివేదికలు';

  @override
  String get uiDownloadReady => 'డౌన్‌లోడ్ సిద్ధంగా ఉంది';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'ఈ పరికరంలో నోటిఫికేషన్‌లను నివేదించండి';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'పరికర సెట్టింగ్‌లు తెరవబడ్డాయి. డాక్లైజర్ కోసం నోటిఫికేషన్‌లను అనుమతించండి, ఆపై ఇక్కడకు తిరిగి వెళ్లండి.';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'నోటిఫికేషన్‌లు ఇప్పటికీ ఆఫ్‌లో ఉన్నాయి. నివేదిక అప్‌డేట్‌లను స్వీకరించడానికి పరికర సెట్టింగ్‌లలో వారిని అనుమతించండి.';

  @override
  String get uiPreferencesSaved => 'ప్రాధాన్యతలు సేవ్ చేయబడ్డాయి';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'మీ ఖాతా ఎంపిక సేవ్ చేయబడింది, కానీ ఈ పరికరం మార్కెటింగ్ పుష్ కోసం నమోదు చేయడం పూర్తి కాలేదు. ఈ పరికరంలో మార్కెటింగ్ బ్లాక్ చేయబడింది; నోటిఫికేషన్ అనుమతిని తనిఖీ చేసి, మళ్లీ సేవ్ చేయడానికి ప్రయత్నించండి.';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'మీ ఖాతా ఎంపిక సేవ్ చేయబడింది. ఈ పరికరం దాని స్థానిక ప్రాధాన్యతను ఇంకా నిర్ధారించలేకపోయింది, అయితే ఖాతా స్థాయిలో మార్కెటింగ్ బ్లాక్ చేయబడి ఉంది.';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'మీ ఖాతా ఎంపిక సేవ్ చేయబడింది, కానీ ఈ పరికరం మార్కెటింగ్ పుష్‌ని ప్రారంభించలేకపోయింది. నోటిఫికేషన్ అనుమతిని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'సేవ్ చేయడానికి చాలా సమయం పట్టింది. మీ కనెక్షన్‌ని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiReportReadyForReview => 'సమీక్ష కోసం నివేదిక సిద్ధంగా ఉంది';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'మీ ఫలితాలు ఎప్పుడు తనిఖీకి సిద్ధంగా ఉన్నాయో తెలుసుకోండి.';

  @override
  String get uiUploadUpdates => 'నవీకరణలను అప్‌లోడ్ చేయండి';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'అప్‌లోడ్‌కు శ్రద్ధ అవసరమైతే సందేశాన్ని పొందండి.';

  @override
  String get uiSharedLinkReminders => 'షేర్ చేసిన లింక్ రిమైండర్‌లు';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'లింక్ గడువు ముగియబోతున్నప్పుడు వినండి.';

  @override
  String get uiSecurityAlerts => 'భద్రతా హెచ్చరికలు';

  @override
  String get uiRequiredForAccountSafety => 'ఖాతా భద్రత కోసం అవసరం.';

  @override
  String get uiComplianceNotices => 'వర్తింపు నోటీసులు';

  @override
  String get uiRequiredAccountInformation => 'అవసరమైన ఖాతా సమాచారం.';

  @override
  String get uiMarketingPushNotifications => 'మార్కెటింగ్ పుష్ నోటిఫికేషన్‌లు';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ఆఫర్‌లు మరియు ప్రకటనలు. ఈ ఎంపికను సేవ్ చేయడం ఈ పరికరానికి కూడా వర్తిస్తుంది.';

  @override
  String get uiProductUpdates => 'ఉత్పత్తి నవీకరణలు';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'డాక్లైజర్ గురించి ఐచ్ఛిక వార్తలు.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'సర్వర్‌కి కనెక్ట్ చేయడం సాధ్యపడదు. దయచేసి మీ ఇంటర్నెట్ లేదా API సర్వర్‌ని తనిఖీ చేయండి.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'మీ ఖాతా సమీక్షలో ఉన్నప్పుడు ప్రొఫైల్ అప్‌డేట్‌లు తాత్కాలికంగా అందుబాటులో ఉండవు.';

  @override
  String get uiUse100CharactersOrFewer =>
      '100 అక్షరాలు లేదా అంతకంటే తక్కువ ఉపయోగించండి';

  @override
  String get uiAddProfile => 'ప్రొఫైల్ జోడించండి';

  @override
  String get uiCreateProfile => 'ప్రొఫైల్ సృష్టించండి';

  @override
  String get uiUpdateTheirDetails => 'వారి వివరాలను అప్‌డేట్ చేయండి';

  @override
  String get uiWhoIsThisProfileFor => 'ఈ ప్రొఫైల్ ఎవరి కోసం?';

  @override
  String get uiNotSelected => 'ఎంపిక కాలేదు';

  @override
  String get uiEnterAReferralCode => 'రెఫరల్ కోడ్‌ను నమోదు చేయండి.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'రెఫరల్ వర్తింపజేయబడింది. ఇమెయిల్ ధృవీకరణ తర్వాత బోనస్ అన్‌లాక్ అవుతుంది.';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'రెఫరల్ వర్తింపజేయబడింది. బోనస్ క్రెడిట్‌లు సిద్ధంగా ఉన్నాయి.';

  @override
  String get uiApplyCode => 'కోడ్‌ని వర్తింపజేయండి';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'మీరు మీ స్వంత రిఫరల్ కోడ్‌ని వర్తింపజేయలేరు.';

  @override
  String get uiReferralCodeIsInvalid => 'రెఫరల్ కోడ్ చెల్లదు.';

  @override
  String get uiFailedToApplyReferralCode =>
      'రెఫరల్ కోడ్‌ని వర్తింపజేయడంలో విఫలమైంది.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'రెఫరల్ కోడ్‌ని వర్తింపజేయడంలో విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiThisDevice => 'ఈ పరికరం';

  @override
  String get uiSignedInDevice => 'సైన్ ఇన్ చేసిన పరికరం';

  @override
  String get uiUnknownDevice => 'తెలియని పరికరం';

  @override
  String get uiRevokeAndLogOut => 'ఉపసంహరించుకోండి మరియు లాగ్ అవుట్ చేయండి';

  @override
  String get uiRevokeSessionca8440 => 'సెషన్‌ని ఉపసంహరించుకోండి';

  @override
  String get uiEnterYourCurrentPassword =>
      'మీ ప్రస్తుత పాస్‌వర్డ్‌ను నమోదు చేయండి';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'పెద్ద అక్షరం, చిన్న అక్షరం, సంఖ్య మరియు ప్రత్యేక అక్షరంతో కనీసం 8 అక్షరాలను ఉపయోగించండి';

  @override
  String get uiChooseADifferentPassword => 'వేరే పాస్‌వర్డ్‌ని ఎంచుకోండి';

  @override
  String get uiNewPasswordsDoNotMatch => 'కొత్త పాస్‌వర్డ్‌లు సరిపోలడం లేదు';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'మీరు అందుబాటులో ఉన్న అన్ని అప్‌లోడ్ క్రెడిట్‌లను ఉపయోగించారు. మరిన్ని జోడించడానికి ప్లాన్ & క్రెడిట్‌లను సందర్శించండి.';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'డాక్లైజర్ కోసం నోటిఫికేషన్‌లు నిలిపివేయబడ్డాయి. రిపోర్ట్-సిద్ధంగా మరియు ఖాతా నవీకరణలను అనుమతించడానికి పరికర సెట్టింగ్‌లను తెరవండి. మీరు దానిని ఎంచుకుంటే తప్ప మార్కెటింగ్ నిలిపివేయబడుతుంది.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'ఈ పరికరంలో రిపోర్ట్-సిద్ధంగా మరియు ఖాతా అప్‌డేట్‌లను పొందండి. మీరు దానిని ఎంచుకుంటే తప్ప మార్కెటింగ్ నిలిపివేయబడుతుంది.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'ఈ పరికరానికి నోటిఫికేషన్‌లు ఆఫ్ చేయబడ్డాయి. నివేదిక-సిద్ధంగా మరియు ఖాతా నవీకరణలను స్వీకరించడానికి సెట్టింగ్‌లను తెరవండి.';

  @override
  String get uiBlockedExpiredRevoked =>
      'బ్లాక్ చేయబడింది (గడువు ముగిసింది/రద్దు చేయబడింది)';

  @override
  String get uiFailedToLoadPolicy => 'విధానాన్ని లోడ్ చేయడంలో విఫలమైంది';

  @override
  String get uiUploadPaused => 'అప్‌లోడ్ పాజ్ చేయబడింది';

  @override
  String get uiSevenDays => '7 రోజులు';

  @override
  String get uiThirtyDays => '30 రోజులు';

  @override
  String get uiNinetyDays => '90 రోజులు';

  @override
  String get uiUploadingAClearReport =>
      'స్పష్టమైన నివేదికను అప్‌లోడ్ చేస్తోంది';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'PDFలు, ఫోటోలు మరియు బహుళ పేజీలు';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'PDFని ఎంచుకోండి లేదా ప్రతి పేజీ యొక్క స్పష్టమైన ఫోటోలను తీయండి. మొత్తం పేజీని ఫ్రేమ్‌లో ఉంచండి, కాంతిని నివారించండి మరియు విశ్లేషించడానికి ముందు పేజీ క్రమాన్ని తనిఖీ చేయండి. మీరు సంగ్రహించిన విలువలను అసలైన దానికి వ్యతిరేకంగా సరి చేయవచ్చు.';

  @override
  String get uiCorrectingAResult => 'ఫలితాన్ని సరిదిద్దడం';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'అసలు విలువలకు వ్యతిరేకంగా సమీక్షించండి';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'ఒక నివేదికను తెరవండి, సేకరించిన ప్రతి పరీక్షను అసలైనదానికి వ్యతిరేకంగా సమీక్షించండి మరియు తప్పుగా చదివిన ఏదైనా విలువ, యూనిట్ లేదా తేదీని సరి చేయండి. మీరు ట్రెండ్‌లపై ఆధారపడే ముందు ధృవీకరించని ఫలితాలను తనిఖీ చేయాలి.';

  @override
  String get uiManagingFamilyRecords => 'కుటుంబ రికార్డులను నిర్వహించడం';

  @override
  String get uiProfilesAccessAndPermissions =>
      'ప్రొఫైల్‌లు, యాక్సెస్ మరియు అనుమతులు';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'ప్రొఫైల్‌లను సృష్టించడానికి మరియు మార్చడానికి కుటుంబాన్ని ఉపయోగించండి. నివేదికను అప్‌లోడ్ చేయడానికి లేదా షేర్ చేయడానికి ముందు ఎంచుకున్న వ్యక్తిని తనిఖీ చేయండి. మీరు యాక్సెస్ చేయడానికి అధికారం ఉన్న రికార్డులను మాత్రమే నిర్వహించండి.';

  @override
  String get uiSharingAndRevokingLinks =>
      'లింక్‌లను భాగస్వామ్యం చేయడం మరియు ఉపసంహరించుకోవడం';

  @override
  String get uiControlTheRecordsYouShare =>
      'మీరు పంచుకునే రికార్డులను నియంత్రించండి';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'మీరు భాగస్వామ్యం చేయాలనుకుంటున్న నివేదికలు లేదా ఫలితాలను ఎంచుకోండి, గడువు ముగింపు మరియు యాక్సెస్ కోడ్‌ను సమీక్షించండి, ఆపై లింక్ మరియు కోడ్‌ను విడిగా పంపండి. యాక్సెస్ అవసరం లేనప్పుడు షేర్ చేసిన లింక్‌ల నుండి సక్రియ లింక్‌ను ఉపసంహరించుకోండి.';

  @override
  String get uiInformationYouProvide => 'మీరు అందించే సమాచారం';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'ఖాతా వివరాలు మరియు కుటుంబ ప్రొఫైల్‌లు మీరు ఎవరి రికార్డ్‌లను నిర్వహిస్తున్నారో గుర్తిస్తాయి. అప్‌లోడ్ చేసిన డాక్యుమెంట్‌లలో గోప్యమైన ఆరోగ్య సమాచారం ఉండవచ్చు.';

  @override
  String get uiSharingControls => 'భాగస్వామ్యం నియంత్రణలు';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'ప్రతి లింక్ యొక్క కంటెంట్‌లు, గడువు ముగింపు మరియు యాక్సెస్ సెట్టింగ్‌లను సమీక్షించండి. మీ ఖాతా సెట్టింగ్‌ల నుండి క్రియాశీల లింక్‌లను నిర్వహించండి.';

  @override
  String get uiExportAndAccountChoices => 'ఎగుమతి మరియు ఖాతా ఎంపికలు';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'రికార్డులను ఎగుమతి చేయడానికి లేదా ఖాతా తొలగింపు అభ్యర్థనను ప్రారంభించడానికి సెట్టింగ్‌లను ఉపయోగించండి. నిలుపుదల వివరాలు పూర్తి పాలసీలో ఉంటాయి.';

  @override
  String get uiEducationalScope => 'విద్యా పరిధి';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'డాక్లైజర్ నివేదికలను నిర్వహిస్తుంది మరియు కాలక్రమేణా ఫలితాలను చూపుతుంది. విద్యాపరమైన వివరణలు వైద్య సలహా లేదా రోగనిర్ధారణ కాదు.';

  @override
  String get uiReviewYourRecords => 'మీ రికార్డులను సమీక్షించండి';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'అసలైన నివేదికకు వ్యతిరేకంగా సేకరించిన విలువలు, యూనిట్లు మరియు తేదీలను తనిఖీ చేయండి. మీ ఫలితాల గురించి ఆరోగ్య సంరక్షణ నిపుణులను అడగండి.';

  @override
  String get uiManageAndShareResponsibly =>
      'నిర్వహించండి మరియు బాధ్యతాయుతంగా భాగస్వామ్యం చేయండి';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'మీరు యాక్సెస్ చేయడానికి అధికారం ఉన్న రికార్డులను మాత్రమే నిర్వహించండి. భాగస్వామ్యం చేయడానికి ముందు ఎంచుకున్న సమాచారాన్ని మరియు గ్రహీతను తనిఖీ చేయండి.';

  @override
  String get uiPrivacyPolicy7ceacd => 'గోప్యతా విధానం';

  @override
  String get uiTermsOfUse8a069e => 'ఉపయోగ నిబంధనలు';

  @override
  String get uiOpenPrivacyControls => 'గోప్యతా నియంత్రణలను తెరవండి';

  @override
  String get uiGetHelpWithTheApp => 'యాప్‌తో సహాయం పొందండి';

  @override
  String get uiExportYourDataInAccountSettings =>
      'ఖాతా సెట్టింగ్‌లలో మీ డేటాను ఎగుమతి చేయండి';

  @override
  String get uiYOURDATACHOICES => 'మీ డేటా & ఎంపికలు';

  @override
  String get uiUSINGDOCLYZER => 'డాక్లైజర్ ఉపయోగించడం';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'మీరు డాక్లైజర్‌లో ఉంచే\nసమాచారాన్ని అర్థం చేసుకోండి.';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'యాప్ పాత్రపై స్పష్టమైన అవగాహన\n.';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name నుండి $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · తాజా $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'ఈ లైబ్రరీని ప్రారంభించడానికి $name కోసం నివేదికను అప్‌లోడ్ చేయండి.';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP చిరునామా: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'సైన్ ఇన్ చేసారు: $date';
  }

  @override
  String get uiUnknown => 'తెలియదు';

  @override
  String uiResultsFor(String name) {
    return '$name కోసం ఫలితాలు';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count ల్యాబ్ పారామితులు ట్రాక్ చేయబడ్డాయి';
  }

  @override
  String uiSampledDate(String date) {
    return 'నమూనా $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'సేకరణ తేదీ: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'ల్యాబ్ పరిధి: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI ఈ పరిధిని $rangeగా చదివింది. ముద్రిత వచనం: $printed. ఈ పోలికపై ఆధారపడే ముందు అసలు నివేదికను తనిఖీ చేయండి.';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount సిద్ధంగా ఉంది';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count క్రెడిట్‌లు';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'ఈ ఖాతాకు రిఫరల్ కోడ్ ఇప్పటికే వర్తింపజేయబడింది.';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'యాప్ లాక్‌ని ఆన్ చేయడానికి ముందు పరికర పాస్‌కోడ్‌ని సెట్ చేయండి.';

  @override
  String get uiLanguagePreferenceNotSaved => 'భాష ప్రాధాన్యత సేవ్ చేయబడలేదు.';

  @override
  String get uiExportUnavailable => 'ఎగుమతి అందుబాటులో లేదు';

  @override
  String get uiUnreadableImage => 'చదవలేని చిత్రం';

  @override
  String uiStatusWithValue(String status) {
    return 'స్థితి: $status';
  }

  @override
  String get uiPending => 'పెండింగ్‌లో ఉంది';

  @override
  String get uiCompleted => 'పూర్తయింది';

  @override
  String get uiFailed => 'విఫలమైంది';

  @override
  String get uiInactive => 'నిష్క్రియ';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'మీ నివేదికలు మరియు ప్రొఫైల్‌లను ఉంచడానికి $date కంటే ముందు పునరుద్ధరించండి.';
  }

  @override
  String get uiThirtyDayDeadline => '30 రోజుల గడువు';

  @override
  String uiWhatsAffected(String details) {
    return 'ఏమి ప్రభావితం చేయబడింది: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'చివరిగా నవీకరించబడింది: $time వద్ద $date';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename ప్రస్తుత ప్రొఫైల్‌కు బదులుగా $name క్రింద కనిపిస్తుంది.';
  }

  @override
  String get uiOneVerifiedResult => '1 ధృవీకరించబడిన ఫలితం సేవ్ చేయబడింది.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count ధృవీకరించబడిన ఫలితాలు సేవ్ చేయబడ్డాయి.';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'ప్రొఫైల్‌లను మార్చడం సాధ్యం కాలేదు. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'సేకరించినది: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'అప్‌లోడ్ చేసిన తేదీ $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount ద్వారా పెంచబడింది';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount తగ్గింది';
  }

  @override
  String get uiPercentagePoints => 'శాతం పాయింట్లు';

  @override
  String uiTestValuesCount(String count) {
    return 'పరీక్ష విలువలు ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'ప్రాసెసింగ్ సమయంలో AI ద్వారా విలువ తనిఖీ చేయబడింది. అసలు OCR: $value. నివేదికకు వ్యతిరేకంగా దాన్ని నిర్ధారించండి.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return 'ఇప్పటికే $nameలో నివేదించండి';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return 'నివేదిక $nameకి జోడించబడింది';
  }

  @override
  String uiAddedOn(String date) {
    return '$date జోడించబడింది';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max నివేదికల యొక్క $currentని ఉపయోగించడం.';
  }

  @override
  String get uiNeedHelp => 'సహాయం కావాలా?';

  @override
  String get uiEnabled => 'ప్రారంభించబడింది';

  @override
  String get uiEnable => 'ప్రారంభించు';

  @override
  String get uiSubscribe => 'సభ్యత్వం పొందండి';

  @override
  String get uiApplying => 'దరఖాస్తు చేస్తోంది';

  @override
  String get uiCheckStatus => 'స్థితిని తనిఖీ చేయండి';

  @override
  String get uiEditProfile => 'ప్రొఫైల్‌ను సవరించండి';

  @override
  String get uiSaveChanges => 'మార్పులను సేవ్ చేయండి';

  @override
  String get uiOptional => 'ఐచ్ఛికం';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ఆర్డర్ $orderId సయోధ్య కోసం వేచి ఉంది. స్థితి స్పష్టంగా కనిపించే వరకు కొనుగోలు పాజ్ చేయబడుతుంది.';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'నెలవారీ ప్రణాళిక - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'క్రెడిట్ ప్యాక్ - $name';
  }

  @override
  String get uiUnreadable => 'చదవలేనిది';

  @override
  String uiLatestValue(String value) {
    return 'తాజాది: $value';
  }

  @override
  String get uiEarlier => 'అంతకుముందు';

  @override
  String get uiLater => 'తరువాత';

  @override
  String get uiViewed => 'వీక్షించారు';

  @override
  String get uiBlocked => 'నిరోధించబడింది';

  @override
  String get uiCapped => 'క్యాప్డ్';

  @override
  String uiLastChange(String label) {
    return 'చివరి మార్పు: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'చివరి మార్పు: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'బహుమతి వోచర్ వర్తింపజేయబడింది. $credits క్రెడిట్‌లు జోడించబడ్డాయి.';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'అసలైనదాన్ని ఇంకా సేవ్ చేయడం సాధ్యపడలేదు. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'ఉపసంహరించుకోవడంలో విఫలమైంది: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'నా డాక్లైజర్ రిఫరల్ కోడ్ $code: $linkని ఉపయోగించండి';
  }

  @override
  String get uiAMomentAgo => 'క్షణం క్రితం';

  @override
  String uiMinutesAgo(String count) {
    return '$count నిమి క్రితం';
  }

  @override
  String get uiOneHourAgo => '1 గంట క్రితం';

  @override
  String uiHoursAgo(String count) {
    return '$count గంటల క్రితం';
  }

  @override
  String get uiToday => 'ఈరోజు';

  @override
  String get uiYesterday => 'నిన్న';

  @override
  String get uiOneDayAgo => '1 రోజు క్రితం';

  @override
  String uiDaysAgo(String count) {
    return '$count రోజుల క్రితం';
  }

  @override
  String get uiOneWeekAgo => '1 వారం క్రితం';

  @override
  String uiWeeksAgo(String count) {
    return '$count వారాల క్రితం';
  }

  @override
  String get uiOneMonthAgo => '1 నెల క్రితం';

  @override
  String uiMonthsAgo(String count) {
    return '$count నెలల క్రితం';
  }

  @override
  String get uiOneYearAgo => '1 సంవత్సరం క్రితం';

  @override
  String uiYearsAgo(String count) {
    return '$count సంవత్సరాల క్రితం';
  }

  @override
  String get uiInOneDay => '1 రోజులో';

  @override
  String uiInDays(String count) {
    return '$count రోజుల్లో';
  }

  @override
  String uiInMinutes(String count) {
    return '$count నిమిషంలో';
  }

  @override
  String get uiInOneHour => '1 గంటలో';

  @override
  String uiInHours(String count) {
    return '$count గంటలలో';
  }

  @override
  String get uiMissingExtractedTestName =>
      'సంగ్రహించిన ఫలితం నుండి పరీక్ష పేరు లేదు.';

  @override
  String get uiMissingCapturedLabRange =>
      'ఈ పరీక్ష కోసం ల్యాబ్ రిఫరెన్స్ రేంజ్ ఏదీ క్యాప్చర్ చేయబడలేదు.';

  @override
  String get uiNonNumericExtractedValue =>
      'సంగ్రహించిన విలువ సాదా సంఖ్య కాదు. అసలు నివేదికలో దాన్ని తనిఖీ చేయండి.';

  @override
  String get uiLabFlagRangeConflict =>
      'ల్యాబ్ ఫ్లాగ్ ముద్రిత పరిధితో విభేదిస్తుంది. అసలు నివేదికను తనిఖీ చేయండి.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'సంగ్రహించిన విలువ, ముద్రించిన పరిధి లేదా ల్యాబ్ ఫ్లాగ్‌ని అసలు నివేదికలో తనిఖీ చేయాలి.';

  @override
  String get uiInitialEntitlement => 'ప్రారంభ హక్కు';

  @override
  String get uiCreditPackPurchase => 'క్రెడిట్ ప్యాక్ కొనుగోలు';

  @override
  String get uiSubscriptionUpgrade => 'సబ్‌స్క్రిప్షన్ అప్‌గ్రేడ్';

  @override
  String get uiPlanDowngrade => 'డౌన్‌గ్రేడ్‌ని ప్లాన్ చేయండి';

  @override
  String get uiAdminAdjustment => 'అడ్మిన్ సర్దుబాటు';

  @override
  String get uiSystemReconciliation => 'సిస్టమ్ సయోధ్య';

  @override
  String get uiReferralInviteBonus => 'రెఫరల్ ఆహ్వాన బోనస్';

  @override
  String get uiReferralAnalysisMilestone => 'రెఫరల్ విశ్లేషణ మైలురాయి';

  @override
  String get uiReferralPurchaseMilestone => 'రెఫరల్ కొనుగోలు మైలురాయి';

  @override
  String get uiFreePromoCreditPack => 'ఉచిత ప్రోమో క్రెడిట్ ప్యాక్';

  @override
  String get uiGiftVoucherRedeemed => 'బహుమతి వోచర్ రిడీమ్ చేయబడింది';

  @override
  String get uiNotYetChanged => 'ఇంకా మారలేదు';

  @override
  String get uiCannotReachServer =>
      'సర్వర్‌ని చేరుకోవడం సాధ్యం కాలేదు. మీ కనెక్షన్‌ని తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiInvalidEmailOrPassword =>
      'చెల్లని ఇమెయిల్ లేదా పాస్‌వర్డ్. మీ వివరాలను తనిఖీ చేసి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiTooManyAuthAttempts =>
      'చాలా ప్రయత్నాలు. కొన్ని నిమిషాలు వేచి ఉండి, మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiEnterValidEmail =>
      'దయచేసి చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామాను నమోదు చేయండి.';

  @override
  String get uiPasswordRequirements =>
      'పాస్‌వర్డ్ తప్పనిసరిగా కనీసం 8 అక్షరాలు ఉండాలి మరియు పెద్ద అక్షరం, చిన్న అక్షరం, సంఖ్య మరియు ప్రత్యేక అక్షరాన్ని కలిగి ఉండాలి.';

  @override
  String get uiAccountWithEmailExists =>
      'ఈ ఇమెయిల్‌తో ఖాతా ఇప్పటికే ఉంది. సైన్ ఇన్ చేయండి లేదా వేరే ఇమెయిల్‌ని ఉపయోగించండి.';

  @override
  String get uiUploadedStatus => 'అప్‌లోడ్ చేయబడింది';

  @override
  String uiSupportAction(String action) {
    return 'చర్య: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'సహసంబంధ ID: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'క్లయింట్ చర్య ID: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'లోపం కోడ్: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'లోపం: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'మీ సెషన్ ముగిసింది. మళ్లీ సైన్ ఇన్ చేయండి.';

  @override
  String get uiProfileLimitReached =>
      'మీ ప్లాన్ ప్రొఫైల్ పరిమితిని చేరుకున్నారు. మరిన్ని జోడించడానికి ప్లాన్ & క్రెడిట్‌లను సమీక్షించండి.';

  @override
  String get uiCorrectionConflictReload =>
      'ఈ ఫలితం మరోచోట మారింది. నివేదికను సరిదిద్దడానికి ముందు దాన్ని మళ్లీ లోడ్ చేయండి.';

  @override
  String get uiSeePlanCreditsOptions =>
      'అందుబాటులో ఉన్న ఎంపికల కోసం ప్లాన్ & క్రెడిట్‌లను చూడండి.';

  @override
  String get uiShareLinkLimitHelp =>
      'మీరు యాక్టివ్ షేర్-లింక్ పరిమితిని చేరుకున్నారు.';

  @override
  String get uiScopedExportUnavailable =>
      'స్కోప్డ్ ఎగుమతి అందుబాటులో లేదు. తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiRestorationUnavailable =>
      'పునరుద్ధరణ అందుబాటులో లేదు. తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String get uiExportRequestNotFound =>
      'ఎగుమతి అభ్యర్థన కనుగొనబడలేదు. కొత్త ఎగుమతిని అభ్యర్థించండి.';

  @override
  String get uiClosureConfirmationRequired =>
      'కొనసాగించడానికి ఖాతా మూసివేతను నిర్ధారించండి.';

  @override
  String get uiCurrentPasswordIncorrect => 'ప్రస్తుత పాస్‌వర్డ్ తప్పు.';

  @override
  String get uiLaboratories => 'ప్రయోగశాలలు';

  @override
  String get uiUnlock => 'అన్‌లాక్ చేయండి';
}
