// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get trendLatestResult => 'નવીનતમ પરિણામ';

  @override
  String get trendPreviousResult => 'પાછલું પરિણામ';

  @override
  String get trendSourceUnit => 'આ મર્યાદાનું મૂળ એકમ';

  @override
  String get trendNoSavedResults => 'આ તપાસ માટે હજી કોઈ સાચવેલું પરિણામ નથી.';

  @override
  String get trendNoPlottableResults =>
      'નમૂનાની તારીખ સાથેનું ચોક્કસ આંકડાકીય પરિણામ ચાર્ટમાં બતાવી શકાતું નથી.';

  @override
  String get trendOneResultHelp =>
      'એક પરિણામ સાચવેલું છે. ફેરફાર જોવા બીજો રિપોર્ટ ઉમેરો.';

  @override
  String get trendMultipleResultsHelp =>
      'તારીખો વીતેલા સમય પ્રમાણે બતાવવામાં આવી છે. મૂલ્ય જોવા બિંદુ પર ટૅપ કરો.';

  @override
  String trendUnplottedNote(int count) {
    return 'નમૂનાની તારીખ અથવા ચોક્કસ આંકડાકીય મૂલ્ય ન હોવાથી $count પરિણામો ચાર્ટમાં બતાવાયા નથી.';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$count પરિણામો સાથે $testNameના ફેરફારનો ચાર્ટ';
  }

  @override
  String get trendDateReview =>
      'નમૂનાની તારીખ અગાઉ કાઢેલી માહિતીમાંથી છે. મૂળ રિપોર્ટમાં તપાસો.';

  @override
  String get trendNotPlotted => 'ચાર્ટમાં બતાવાયું નથી';

  @override
  String get trendExactNumberUnavailable => 'પરિણામ ચોક્કસ સંખ્યા નથી';

  @override
  String get preferredLanguage => 'પસંદગીની ભાષા';

  @override
  String get descriptionLanguage => 'વર્ણનની ભાષા';

  @override
  String get languageHelp =>
      'ઍપનાં લેબલ અને રિપોર્ટની સમજૂતી માટે વપરાય છે. તમે સમજૂતીની ભાષા કોઈપણ સમયે બદલી શકો છો.';

  @override
  String get languageSaveFailed =>
      'તમારી ભાષાની પસંદગી સાચવી શકાઈ નહીં. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get translationLoading => 'અનુવાદિત વર્ણન તૈયાર થઈ રહ્યું છે…';

  @override
  String get translationFailed =>
      'અનુવાદ ઉપલબ્ધ નથી. ફરી પ્રયાસ કરો અથવા અંગ્રેજી પસંદ કરો.';

  @override
  String get translationNote =>
      'સાચવેલી અંગ્રેજી સમજૂતીનો AI દ્વારા અનુવાદ કરાયો છે. ચોક્કસ પરિણામો માટે મૂળ રિપોર્ટ તપાસો.';

  @override
  String get sourceChanged =>
      'રિપોર્ટ બદલાયો છે. નવીનતમ સમજૂતી જોવા તેને ફરી લોડ કરો.';

  @override
  String get signupTitle => 'વધુ સ્પષ્ટ સમજની\nશરૂઆત અહીંથી.';

  @override
  String get signupIntro =>
      'તમારા રિપોર્ટ અને પરિણામો એકસાથે રાખવા ખાતું બનાવો.';

  @override
  String get loginIntro =>
      'તમારા સ્વાસ્થ્યના રિપોર્ટ જોવા અને સમજવા સાઇન ઇન કરો.';

  @override
  String get emailAddress => 'ઇમેઇલ સરનામું';

  @override
  String get email => 'ઇમેઇલ';

  @override
  String get password => 'પાસવર્ડ';

  @override
  String get referralCode => 'રેફરલ કોડ (વૈકલ્પિક)';

  @override
  String get createAccount => 'ખાતું બનાવો';

  @override
  String get alreadyAccount => 'પહેલેથી ખાતું છે? ';

  @override
  String get noAccount => 'ખાતું નથી? ';

  @override
  String get signIn => 'સાઇન ઇન કરો';

  @override
  String get showPassword => 'પાસવર્ડ બતાવો';

  @override
  String get hidePassword => 'પાસવર્ડ છુપાવો';

  @override
  String get needHelp => 'મદદ જોઈએ છે?';

  @override
  String get forgotPassword => 'પાસવર્ડ ભૂલી ગયા છો?';

  @override
  String get invalidCredentialsInput =>
      'માન્ય ઇમેઇલ સરનામું અને પાસવર્ડ દાખલ કરો';

  @override
  String get signupFailed => 'ખાતું બનાવી શકાયું નહીં';

  @override
  String get loginFailed =>
      'સાઇન ઇન કરી શકાયું નહીં. કૃપા કરીને તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get genericError => 'કંઈક ખોટું થયું. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get profileUpdated => 'પ્રોફાઇલ અપડેટ થઈ';

  @override
  String get changePhoto => 'પ્રોફાઇલનો ફોટો બદલો';

  @override
  String get gallery => 'ગૅલેરીમાંથી પસંદ કરો';

  @override
  String get camera => 'ફોટો લો';

  @override
  String get photoUpdated => 'પ્રોફાઇલનો ફોટો અપડેટ થયો';

  @override
  String get photoFailed =>
      'તમારો ફોટો અપડેટ કરી શકાયો નહીં. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get yourAccount => 'તમારું ખાતું';

  @override
  String get profileLoading => 'પ્રોફાઇલ લોડ થઈ રહી છે…';

  @override
  String get profileLoadAction => 'તમારી પ્રોફાઇલ લોડ કરવા ટૅપ કરો';

  @override
  String get accountData => 'ખાતું અને ડેટા';

  @override
  String get personalInformation => 'વ્યક્તિગત માહિતી';

  @override
  String get notificationPreferences => 'સૂચનાઓની પસંદગીઓ';

  @override
  String get privacySecurity => 'ગોપનીયતા અને સુરક્ષા';

  @override
  String get sharedLinks => 'શેર કરેલી લિંક્સ';

  @override
  String get exportData => 'તમારા ડેટાની નિકાસ કરો';

  @override
  String get additionalAccount => 'ખાતાની વધારાની માહિતી';

  @override
  String get additionalAccountHelp => 'પરિવાર, પ્લાન, રેફરલ, સત્રો અને દેખાવ';

  @override
  String get familyProfiles => 'પરિવારની પ્રોફાઇલો';

  @override
  String get manageProfiles => 'પ્રોફાઇલ બદલો અથવા પ્રોફાઇલોનું સંચાલન કરો';

  @override
  String get planCredits => 'પ્લાન અને ક્રેડિટ્સ';

  @override
  String get viewPlanBalance => 'તમારો પ્લાન અને બાકી ક્રેડિટ્સ જુઓ';

  @override
  String get balanceLoading => 'બાકી ક્રેડિટ્સની માહિતી લોડ થઈ રહી છે…';

  @override
  String get referFriends => 'મિત્રોને આમંત્રિત કરો';

  @override
  String get referralRewards => 'આમંત્રણો અને રેફરલ પુરસ્કારો';

  @override
  String get activeSessions => 'સક્રિય સત્રો';

  @override
  String get appearance => 'દેખાવ';

  @override
  String get system => 'ઉપકરણ મુજબ';

  @override
  String get light => 'આછો';

  @override
  String get dark => 'ઘેરો';

  @override
  String get helpSupport => 'મદદ અને સહાય';

  @override
  String get aboutDoclyzer => 'Doclyzer વિશે';

  @override
  String get aboutCopy =>
      'રિપોર્ટ વ્યક્તિ પ્રમાણે ગોઠવીને રાખો અને તેમાંથી મેળવેલાં પરિણામો મૂળ રિપોર્ટ સાથે સરખાવીને તપાસો.';

  @override
  String get logOut => 'લૉગ આઉટ કરો';

  @override
  String get profile => 'પ્રોફાઇલ';

  @override
  String get saveChanges => 'ફેરફારો સાચવો';

  @override
  String get accountRestricted => 'ખાતાનો ઉપયોગ મર્યાદિત છે';

  @override
  String get photoUploading => 'ફોટો અપલોડ થઈ રહ્યો છે…';

  @override
  String get changePhotoShort => 'ફોટો બદલો';

  @override
  String get accountDetails => 'ખાતાની વિગતો';

  @override
  String get emailHelp =>
      'ખાતામાં પ્રવેશ માટે વપરાય છે. તેને બદલવા સહાય ટીમનો સંપર્ક કરો.';

  @override
  String get accountName => 'ખાતાનું નામ';

  @override
  String get belowLabRange => 'આ લેબની સંદર્ભ મર્યાદાથી નીચે';

  @override
  String get withinLabRange => 'આ લેબની સંદર્ભ મર્યાદામાં';

  @override
  String get aboveLabRange => 'આ લેબની સંદર્ભ મર્યાદાથી ઉપર';

  @override
  String get cannotCompare => 'લેબની મર્યાદા સાથે સરખામણી કરી શકાતી નથી';

  @override
  String get understandResult => 'આ પરિણામ સમજો';

  @override
  String get yourResult => 'તમારું પરિણામ';

  @override
  String get labReferenceRange => 'લેબની સંદર્ભ મર્યાદા';

  @override
  String get resultUnavailable => 'આ પરિણામમાં ઉપલબ્ધ નથી';

  @override
  String get sampleDate => 'નમૂનાની તારીખ';

  @override
  String get resultHistory => 'પરિણામોનો ઇતિહાસ';

  @override
  String get originalReport => 'મૂળ રિપોર્ટ';

  @override
  String get reviewValue => 'મૂલ્ય તપાસો';

  @override
  String get understandYourResult => 'તમારું પરિણામ સમજો';

  @override
  String get educationalContext =>
      'આ પરિણામ વિશે ચર્ચા કરવામાં મદદરૂપ શૈક્ષણિક માહિતી.';

  @override
  String get explanationUnavailable => 'સમજૂતી ઉપલબ્ધ નથી';

  @override
  String get explanationFailed => 'અત્યારે સમજૂતી લોડ કરી શકાઈ નહીં.';

  @override
  String get checkOriginal => 'મૂળ રિપોર્ટ તપાસો';

  @override
  String get tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get aiGuidance => 'AI દ્વારા તૈયાર કરાયેલું માર્ગદર્શન';

  @override
  String get understandingResult => 'આ પરિણામની સમજ';

  @override
  String get possibleMeaning => 'તેનો સંભવિત અર્થ';

  @override
  String get whatTestMeasures => 'આ તપાસ શું માપે છે';

  @override
  String get suggestedNextStep => 'સૂચવેલું આગલું પગલું';

  @override
  String get resultLimitations => 'આ પરિણામ તમને શું જણાવી શકતું નથી';

  @override
  String get oneResultLimit =>
      'માત્ર એક પરિણામથી કોઈ રોગ કે તકલીફનું નિદાન થઈ શકતું નથી કે લક્ષણોનું કારણ જાણી શકાતું નથી.';

  @override
  String get detailsToCheck => 'તપાસવાની વિગતો';

  @override
  String get lifestyleFactors => 'ચર્ચા કરવા માટે જીવનશૈલીને લગતાં પરિબળો';

  @override
  String get insightContext =>
      'આ મૂલ્ય તમારા રિપોર્ટમાંથી મેળવવામાં આવ્યું છે. નામ, મૂલ્ય, એકમ કે મર્યાદા ખોટી લાગે તો મૂળ રિપોર્ટ તપાસો. AIની સમજૂતીઓ શૈક્ષણિક હેતુ માટે છે અને તમને કઈ સારવારની જરૂર છે તે જણાવી શકતી નથી.';

  @override
  String get yourProfile => 'તમારી પ્રોફાઇલ';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get moveReport => 'રિપોર્ટ ખસેડો';

  @override
  String get gotIt => 'સમજાયું';

  @override
  String get reportDetails => 'રિપોર્ટની વિગતો';

  @override
  String get shareReport => 'રિપોર્ટ શેર કરો';

  @override
  String get moreReportActions => 'રિપોર્ટ માટે વધુ વિકલ્પો';

  @override
  String get attemptHistory => 'પ્રયાસોનો ઇતિહાસ';

  @override
  String get compareReports => 'રિપોર્ટની સરખામણી કરો';

  @override
  String get readParsedReport => 'માહિતી અલગ તારવીને ગોઠવેલો રિપોર્ટ વાંચો';

  @override
  String get moveRecycle => 'રિસાઇકલ બિનમાં ખસેડો';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get reportSummary => 'રિપોર્ટનો સારાંશ';

  @override
  String get updateSummary => 'સારાંશ અપડેટ કરો';

  @override
  String get summaryLoading => 'તમારા પરિણામો સરળ ભાષામાં સમજાવાઈ રહ્યા છે…';

  @override
  String get checkSummary => 'સારાંશ તપાસો';

  @override
  String get summaryFailed =>
      'સારાંશ બનાવી શકાયો નહીં. તમે ફરી પ્રયાસ કરી શકો છો.';

  @override
  String get summaryPlaceholder =>
      'મુખ્ય પરિણામોની સરળ ભાષામાં સમજૂતી અહીં દેખાશે.';

  @override
  String get retrySummary => 'સારાંશ માટે ફરી પ્રયાસ કરો';

  @override
  String get generateSummary => 'સારાંશ બનાવો';

  @override
  String get loadingResults => 'રિપોર્ટનાં પરિણામો લોડ થઈ રહ્યાં છે…';

  @override
  String get somethingWrong => 'કંઈક ખોટું થયું';

  @override
  String get viewTrends => 'સમય સાથેના ફેરફારો જુઓ';

  @override
  String get originalFile => 'મૂળ ફાઇલ';

  @override
  String get testValues => 'તપાસનાં મૂલ્યો';

  @override
  String get summary => 'સારાંશ';

  @override
  String get checkStatus => 'સ્થિતિ તપાસો';

  @override
  String get viewOriginal => 'મૂળ જુઓ';

  @override
  String get verifiedResults => 'ચકાસેલાં પરિણામો';

  @override
  String get resultTapHelp => 'તપાસ શું માપે છે તે સમજવા પરિણામ પર ટૅપ કરો.';

  @override
  String get reviewResults => 'ઓળખાયેલાં પરિણામો તપાસો';

  @override
  String get keepFile => 'તેમ છતાં ફાઇલ રાખો';

  @override
  String get patientDetails => 'દર્દીની વિગતો';

  @override
  String get name => 'નામ';

  @override
  String get age => 'ઉંમર';

  @override
  String get gender => 'લિંગ';

  @override
  String get bookingId => 'બુકિંગ ID';

  @override
  String get sampleCollection => 'નમૂનો લેવાની વિગતો';

  @override
  String get labDetails => 'લેબની વિગતો';

  @override
  String get labName => 'લેબનું નામ';

  @override
  String get address => 'સરનામું';

  @override
  String get phone => 'ફોન';

  @override
  String get location => 'સ્થળ';

  @override
  String get belowRange => 'મર્યાદાથી નીચે';

  @override
  String get aboveRange => 'મર્યાદાથી ઉપર';

  @override
  String get withinRange => 'દર્શાવેલી મર્યાદામાં';

  @override
  String get rangeUnclear => 'મર્યાદા અસ્પષ્ટ છે';

  @override
  String get understandResultAction => 'આ પરિણામ સમજો  →';

  @override
  String get parsedReport => 'માહિતી અલગ તારવીને ગોઠવેલો રિપોર્ટ';

  @override
  String get reports => 'રિપોર્ટ';

  @override
  String get trends => 'સમય સાથેના ફેરફારો';

  @override
  String get openingPage => 'પૃષ્ઠ ખૂલી રહ્યું છે';

  @override
  String get home => 'મુખ્ય પૃષ્ઠ';

  @override
  String get family => 'પરિવાર';

  @override
  String get switchProfile => 'પ્રોફાઇલ બદલો';

  @override
  String get currentProfile => 'હાલની પ્રોફાઇલ';

  @override
  String get viewProfile => 'આ પ્રોફાઇલ જુઓ';

  @override
  String get manageFamily => 'પરિવારનું સંચાલન કરો';

  @override
  String get chooseProfile => 'પ્રોફાઇલ પસંદ કરો';

  @override
  String get notifications => 'સૂચનાઓ';

  @override
  String get homeTitle => 'થોડી સ્પષ્ટતા.\nબધું એક જ જગ્યાએ.';

  @override
  String get nextReportTitle =>
      'તમારો આગલો રિપોર્ટ,\nતમે તૈયાર હો ત્યારે તૈયાર.';

  @override
  String get homeSubtitle => 'PDF, ફોટા અને પરિવારના રેકોર્ડ.';

  @override
  String get uploadReport => 'રિપોર્ટ અપલોડ કરો';

  @override
  String get recentReport => 'તાજેતરનો રિપોર્ટ';

  @override
  String get viewAll => 'બધા જુઓ';

  @override
  String get reportsUnavailable =>
      'રિપોર્ટ ઉપલબ્ધ નથી. ઇન્ટરનેટ સાથે જોડાયા પછી ફરી પ્રયાસ કરો.';

  @override
  String get emptyHomeTitle => 'તમારી સફર અહીંથી શરૂ થાય છે';

  @override
  String get emptyHomeHelp =>
      'તમારા રેકોર્ડનો સ્પષ્ટ ઇતિહાસ બનાવવાની શરૂઆત કરવા તમારો પહેલો રિપોર્ટ અપલોડ કરો.';

  @override
  String get uploadFirstReport => 'તમારો પહેલો રિપોર્ટ અપલોડ કરો';

  @override
  String get latestResults => 'નવીનતમ પરિણામો';

  @override
  String get allTrends => 'સમય સાથેના બધા ફેરફારો';

  @override
  String get reviewedResultsHelp =>
      'તપાસેલાં પરિણામો ઉપલબ્ધ થશે ત્યારે અહીં દેખાશે.';

  @override
  String get searchTests => 'તપાસ શોધો';

  @override
  String get noHealthData =>
      'હજી સ્વાસ્થ્યનો કોઈ ડેટા નથી. તમારા સ્વાસ્થ્યનો ઇતિહાસ જોવા રિપોર્ટ અપલોડ કરો.';

  @override
  String get noTestsFound => 'કોઈ તપાસ મળી નથી';

  @override
  String get shorterTestName => 'તપાસનું ટૂંકું નામ લખીને પ્રયાસ કરો.';

  @override
  String get clearSearch => 'શોધ સાફ કરો';

  @override
  String get unitUnavailable => 'એકમ ઉપલબ્ધ નથી';

  @override
  String get uploadingReport => 'રિપોર્ટ અપલોડ થઈ રહ્યો છે…';

  @override
  String get organizingReport => 'તમારો રિપોર્ટ ગોઠવાઈ રહ્યો છે…';

  @override
  String get uploadAReport => 'રિપોર્ટ અપલોડ કરો';

  @override
  String get uploadHelp =>
      'PDF અથવા સ્પષ્ટ ફોટો પસંદ કરો. સાચવતાં પહેલાં તમે વિગતો તપાસી શકો છો.';

  @override
  String get chooseSource => 'સ્રોત પસંદ કરો';

  @override
  String get uploadPdfImage => 'PDF અથવા છબી અપલોડ કરો';

  @override
  String get chooseReportFiles => 'તમારી ફાઇલોમાંથી રિપોર્ટ પસંદ કરો';

  @override
  String get selectReportPages => 'રિપોર્ટનાં એક અથવા વધુ પાનાં પસંદ કરો';

  @override
  String get capturePage => 'આખા પાનાનો ફોટો લો';

  @override
  String get supportedFormats => 'સમર્થિત ફોર્મેટ: PDF, JPG, PNG';

  @override
  String get confirmFile => 'ખાતરી કરો કે તમે આ જ ફાઇલ ઉમેરવા માંગો છો.';

  @override
  String get addReport => 'રિપોર્ટ ઉમેરો';

  @override
  String get chooseDifferentFile => 'અલગ ફાઇલ પસંદ કરો';

  @override
  String get uploadWait =>
      'આમાં થોડો સમય લાગી શકે છે. કૃપા કરીને ઍપ ખુલ્લી રાખો.';

  @override
  String get reportNeedsAttention => 'રિપોર્ટ પર ધ્યાન આપવાની જરૂર છે';

  @override
  String get verifyBeforeSaving =>
      'ઓળખાયેલાં પરિણામો સાચવતાં પહેલાં મૂળ રિપોર્ટ સાથે સરખાવીને તપાસો.';

  @override
  String get viewVerifiedResults => 'ચકાસેલાં પરિણામો જુઓ';

  @override
  String get viewOriginalReport => 'મૂળ રિપોર્ટ જુઓ';

  @override
  String get viewReportStatus => 'રિપોર્ટની સ્થિતિ જુઓ';

  @override
  String get viewResults => 'પરિણામો જુઓ';

  @override
  String get viewOriginalFile => 'મૂળ ફાઇલ જુઓ';

  @override
  String get retryExtraction => 'પરિણામો મેળવવાનો ફરી પ્રયાસ કરો';

  @override
  String get done => 'પૂર્ણ';

  @override
  String get duplicateReport => 'આ રિપોર્ટની નકલ પહેલેથી હોય એવું લાગે છે';

  @override
  String get duplicateHelp => 'આ ફાઇલ તમારા રિપોર્ટમાં પહેલેથી હોઈ શકે છે.';

  @override
  String get keepExisting => 'હાલનો રિપોર્ટ રાખો';

  @override
  String get processAgain => 'PDF પર ફરી પ્રક્રિયા કરો';

  @override
  String get uploadNewCopy => 'નવી નકલ તરીકે અપલોડ કરો';

  @override
  String get reportLimitReached => 'રિપોર્ટની સંખ્યાની મર્યાદા પૂરી થઈ છે';

  @override
  String get reportLimitHelp =>
      'તમે રિપોર્ટની સંખ્યાની મર્યાદા સુધી પહોંચી ગયા છો.';

  @override
  String get upgrade => 'અપગ્રેડ કરો';

  @override
  String get back => 'પાછા';

  @override
  String get uploadFailedTitle => 'રિપોર્ટ અપલોડ કરી શકાયો નહીં';

  @override
  String get uploadFailed => 'અપલોડ નિષ્ફળ થયું';

  @override
  String get retrySameFile => 'એ જ ફાઇલ સાથે ફરી પ્રયાસ કરો';

  @override
  String get chooseAnotherFile => 'બીજી ફાઇલ પસંદ કરો';

  @override
  String get aiDisclaimer =>
      'Doclyzer તમને તમારા સ્વાસ્થ્યના રિપોર્ટ ગોઠવવામાં અને વધુ સારી રીતે સમજવામાં મદદ કરે છે. આપેલી માહિતી માત્ર શૈક્ષણિક હેતુ માટે છે અને તે તબીબી સલાહ, નિદાન કે સારવાર નથી. તબીબી માર્ગદર્શન માટે હંમેશાં લાયકાત ધરાવતા આરોગ્યસંભાળ વ્યાવસાયિકની સલાહ લો.';

  @override
  String collectedOn(String date) {
    return 'નમૂનો લેવાયો: $date';
  }

  @override
  String uploadedOn(String date) {
    return 'અપલોડ કરાયો: $date';
  }

  @override
  String labRangeValue(String range) {
    return 'લેબની મર્યાદા $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits ક્રેડિટ્સ';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count રિપોર્ટ',
      one: '1 રિપોર્ટ',
      zero: 'કોઈ રિપોર્ટ નથી',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'રિપોર્ટ લોડ થવામાં અપેક્ષા કરતાં વધુ સમય લાગી રહ્યો છે. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get summaryUpdateFailed =>
      'અત્યારે સારાંશ અપડેટ કરી શકાયો નહીં. સાચવેલો સારાંશ હજી ઉપલબ્ધ છે.';

  @override
  String get summaryCreateFailed =>
      'અત્યારે સારાંશ બનાવી શકાયો નહીં. તમારાં પરિણામો હજી નીચે ઉપલબ્ધ છે.';

  @override
  String get reassignFailed =>
      'રિપોર્ટ બીજી પ્રોફાઇલને સોંપી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get confirmRecycle => 'રિસાઇકલ બિનમાં ખસેડવો છે?';

  @override
  String get recycleHelp =>
      'તમે 30 દિવસ સુધી રિપોર્ટ > રિસાઇકલ બિનમાંથી આ રિપોર્ટ પુનઃસ્થાપિત કરી શકો છો. ત્યાર પછી તે કાયમી ધોરણે કાઢી નાખવામાં આવશે.';

  @override
  String get reportRecycled => 'રિપોર્ટ રિસાઇકલ બિનમાં ખસેડાયો';

  @override
  String get reportDeleteFailed =>
      'રિપોર્ટ કાઢી નાખી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get addProfileBeforeMove =>
      'આ રિપોર્ટ ખસેડતાં પહેલાં પરિવારની બીજી પ્રોફાઇલ ઉમેરો.';

  @override
  String get moveReportHelp =>
      'જો આ રિપોર્ટ ખોટી પ્રોફાઇલમાં ઉમેરાયો હોય તો પરિવારના બીજા સભ્યને પસંદ કરો.';

  @override
  String get confirmMoveReport => 'આ રિપોર્ટ ખસેડવો છે?';

  @override
  String get aboutSampleDates => 'નમૂનાની તારીખો વિશે';

  @override
  String get multipleDatesHelp =>
      'આ રિપોર્ટમાં અલગ અલગ તારીખે લીધેલા નમૂનાઓનાં પરિણામો છે. કોઈ પરિણામ ખોલીને તેની તારીખ મૂળ રિપોર્ટ સાથે સરખાવીને તપાસો.';

  @override
  String get missingDateHelp =>
      'નમૂનાની તારીખ એટલે નમૂનો લેવામાં આવ્યો તે તારીખ. આ રિપોર્ટમાં અમને વિશ્વસનીય તારીખ મળી નથી. નમૂનાની તારીખ અપલોડની તારીખથી અલગ છે. કોઈ પરિણામ ખોલીને તેની તારીખ તપાસો અથવા સુધારો.';

  @override
  String get uploading => 'અપલોડ થઈ રહ્યું છે';

  @override
  String get waitingToProcess => 'પ્રક્રિયાની રાહમાં';

  @override
  String get readingReport => 'રિપોર્ટ વંચાઈ રહ્યો છે';

  @override
  String get readyToReview => 'તપાસવા માટે તૈયાર';

  @override
  String get someResultsNeedReview => 'કેટલાંક પરિણામો તપાસવાની જરૂર છે';

  @override
  String get couldNotReadReport => 'રિપોર્ટ વાંચી શકાયો નહીં';

  @override
  String get processingStopped => 'પ્રક્રિયા અટકી ગઈ';

  @override
  String get couldNotProcessReport => 'રિપોર્ટ પર પ્રક્રિયા કરી શકાઈ નહીં';

  @override
  String get reportRefreshFailed =>
      'આ રિપોર્ટ ફરી લોડ કરી શકાયો નહીં. છેલ્લે લોડ કરેલું પરિણામ બતાવાઈ રહ્યું છે.';

  @override
  String get multipleSampleDates => 'નમૂનાની એકથી વધુ તારીખો ';

  @override
  String get missingSampleDate => 'નમૂનાની તારીખ મળી નથી ';

  @override
  String get reportAnalyzing =>
      'અમે આ રિપોર્ટનું વિશ્લેષણ કરી રહ્યા છીએ. તમે આ સ્ક્રીન છોડી શકો છો; પરિણામો તૈયાર થશે ત્યારે દેખાશે.';

  @override
  String get extractionIncompleteTitle =>
      'બધાં પરિણામો વિશ્વસનીય રીતે મેળવી શકાયાં નહીં';

  @override
  String get extractionIncompleteHelp =>
      'આપમેળે પરિણામો મેળવવાની પ્રક્રિયા અધૂરી રહી. ઓળખાયેલી પંક્તિઓ સાચવતાં પહેલાં મૂળ રિપોર્ટ સાથે સરખાવીને તપાસો.';

  @override
  String get verifiedRowsHelp =>
      'આ પંક્તિઓ મૂળ રિપોર્ટ સાથે સરખાવીને તપાસવામાં આવી છે. બીજી પંક્તિઓ હજી તપાસવાની જરૂર હોઈ શકે છે.';

  @override
  String get noTestValues =>
      'આ રિપોર્ટમાં તપાસનાં કોઈ મૂલ્યો મળ્યાં નથી. તેની સામગ્રી તપાસવા મૂળ ફાઇલ ખોલો.';

  @override
  String get processingRetryHelp =>
      'પ્રક્રિયા પૂરી થાય તે પહેલાં અટકી ગઈ. તમારી ફાઇલ સાચવેલી છે. ફરી પ્રયાસ કરવા ‘ફરી પ્રયાસ કરો’ પર ટૅપ કરો.';

  @override
  String get resultsNeedCheck =>
      'કેટલાંક પરિણામો મૂળ રિપોર્ટ સાથે સરખાવીને તપાસવાની જરૂર છે. તમે નીચે ઓળખાયેલી પંક્તિઓ તપાસી શકો છો.';

  @override
  String get readerModeHelp =>
      'માહિતી અલગ તારવીને ગોઠવેલો રિપોર્ટ સરળતાથી જોવા અને વાંચવા માટે વાંચન મોડમાં ઉપલબ્ધ છે.';

  @override
  String get aiRangeHelp =>
      'પ્રક્રિયા દરમિયાન AIએ મર્યાદાનું અર્થઘટન કર્યું છે. મૂળ રિપોર્ટ તપાસો.';

  @override
  String get checkResultHelp =>
      'આ પરિણામ પર આધાર રાખતાં પહેલાં તેને મૂળ રિપોર્ટ સાથે સરખાવીને તપાસો.';

  @override
  String get preferredRangeHelp =>
      'લેબે છાપેલી ઇચ્છનીય શ્રેણી સાથે સરખામણી કરવામાં આવી છે; તે તમને લાગુ પડે છે તેની ખાતરી કરો.';

  @override
  String get categoryComparisonHelp =>
      'આ સરખામણીમાં લેબે છાપેલી ઇચ્છનીય શ્રેણી વપરાય છે. આ શ્રેણી તમને લાગુ પડે છે કે નહીં તે તપાસો.';

  @override
  String get missingSavedResult =>
      'આ મૂલ્યને કોઈ સાચવેલા પરિણામ સાથે જોડી શકાયું નહીં. મૂળ રિપોર્ટ તપાસો અથવા આ રિપોર્ટ ફરી લોડ કરો.';

  @override
  String get unreviewedTest =>
      'AI સમજૂતી માટે આ તપાસની હજી સમીક્ષા થઈ નથી. મૂળ રિપોર્ટ તપાસો અને તમારા તબીબ સાથે પરિણામની ચર્ચા કરો.';

  @override
  String get unsafeResult =>
      'મેળવેલું પરિણામ અસ્પષ્ટ છે, તેથી તેની સલામત રીતે સમજૂતી આપી શકાતી નથી. મૂળ રિપોર્ટ તપાસો.';

  @override
  String get filterReports => 'રિપોર્ટ ફિલ્ટર કરો';

  @override
  String get sortReports => 'રિપોર્ટ ક્રમમાં ગોઠવો';

  @override
  String get recycleBin => 'રિસાઇકલ બિન';

  @override
  String get healthHistory => 'સ્વાસ્થ્યનો ઇતિહાસ';

  @override
  String get shareProfile => 'પ્રોફાઇલ શેર કરો';

  @override
  String get reportsUnavailableTitle => 'રિપોર્ટ ઉપલબ્ધ નથી';

  @override
  String get reportsLoadFailed =>
      'રિપોર્ટ લોડ કરી શકાયા નહીં. ઇન્ટરનેટ સાથે જોડાયા પછી ફરી પ્રયાસ કરો.';

  @override
  String get upload => 'અપલોડ કરો';

  @override
  String get reportsFor => 'આ વ્યક્તિના રિપોર્ટ';

  @override
  String get searchReports => 'રિપોર્ટ અથવા લેબ શોધો';

  @override
  String get filters => 'ફિલ્ટર્સ';

  @override
  String get noReportsYet => 'હજી કોઈ રિપોર્ટ નથી';

  @override
  String get noMatchingReports => 'તમારી શોધને મેળ ખાતા કોઈ રિપોર્ટ નથી.';

  @override
  String get differentSearch => 'અલગ તપાસ, લેબ અથવા ફિલ્ટર સાથે પ્રયાસ કરો.';

  @override
  String get clearFilters => 'શોધ અને ફિલ્ટર્સ સાફ કરો';

  @override
  String get original => 'મૂળ';

  @override
  String get switchActiveProfile => 'સક્રિય પ્રોફાઇલ બદલો';

  @override
  String get switchProfileHelp =>
      'બીજી વ્યક્તિના રિપોર્ટ જુઓ. અપલોડ અને સમય સાથેના ફેરફારો માટેની તમારી સક્રિય પ્રોફાઇલ પણ બદલાશે.';

  @override
  String get multipleCollectionDates => 'નમૂનો લીધાની એકથી વધુ તારીખો';

  @override
  String get unknownCollectionDate => 'નમૂનો લીધાની તારીખ અજ્ઞાત છે';

  @override
  String get profileLoadFailed =>
      'પ્રોફાઇલો લોડ થઈ શકી નહીં. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get pleaseTryAgain => 'કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get deleteProfileConfirm => 'પ્રોફાઇલ કાઢી નાખવી છે?';

  @override
  String get deleteProfileHelp =>
      'આ પ્રોફાઇલ દૂર કરવામાં આવશે. તેની સાથે જોડાયેલા તમામ ડેટાને અસર થશે.';

  @override
  String get profileDeleteFailed =>
      'પ્રોફાઇલ કાઢી નાખી શકાઈ નહીં. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get addFamilyMember => 'પરિવારના સભ્યને ઉમેરો';

  @override
  String get familyUnavailable => 'પરિવારની પ્રોફાઇલો ઉપલબ્ધ નથી';

  @override
  String get familyIntro =>
      'વ્યક્તિ પ્રમાણે ગોઠવેલા રિપોર્ટ અને સમય સાથેના ફેરફારો';

  @override
  String get noProfilesYet => 'હજી કોઈ પ્રોફાઇલ નથી';

  @override
  String get noProfilesHelp =>
      'તમારા અથવા પરિવારના સભ્યોના રિપોર્ટ ગોઠવવા પ્રોફાઇલ ઉમેરો.';

  @override
  String get yourFamily => 'તમારો પરિવાર';

  @override
  String get upgradeProfiles => 'વધુ પ્રોફાઇલો ઉમેરવા અપગ્રેડ કરો';

  @override
  String get editProfile => 'પ્રોફાઇલમાં ફેરફાર કરો';

  @override
  String get deleteProfile => 'પ્રોફાઇલ કાઢી નાખો';

  @override
  String get active => 'સક્રિય';

  @override
  String get setActive => 'સક્રિય કરો';

  @override
  String get viewReports => 'રિપોર્ટ જુઓ';

  @override
  String get notNow => 'અત્યારે નહીં';

  @override
  String get openSettings => 'સેટિંગ્સ ખોલો';

  @override
  String get enableNotifications => 'સૂચનાઓ ચાલુ કરો';

  @override
  String get enableNotificationsConfirm => 'સૂચનાઓ ચાલુ કરવી છે?';

  @override
  String get notificationsEnabled => 'રિપોર્ટની સૂચનાઓ ચાલુ થઈ';

  @override
  String get notificationsStayOff =>
      'સૂચનાઓ બંધ જ છે. તમે પછીથી ઉપકરણનાં સેટિંગ્સમાં તેને ચાલુ કરી શકો છો.';

  @override
  String get notificationsFailed =>
      'સૂચનાઓ ચાલુ કરી શકાઈ નહીં. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get switchProfileFailed =>
      'પ્રોફાઇલ બદલી શકાઈ નહીં. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get sourceReportFailed => 'મૂળ રિપોર્ટ ખોલી શકાયો નહીં.';

  @override
  String get partialRefreshFailed =>
      'કેટલીક માહિતી ફરી લોડ કરી શકાઈ નહીં. ફરી પ્રયાસ કરવા નીચે ખેંચો.';

  @override
  String get knowReportReady => 'તમારો રિપોર્ટ તૈયાર થાય ત્યારે જાણો';

  @override
  String get oneResult => 'એક પરિણામ';

  @override
  String get sameDayResults => 'એક જ દિવસનાં પરિણામો';

  @override
  String get verificationRequired => 'ચકાસણી જરૂરી છે';

  @override
  String get accountCreatedLogin =>
      'તમારું ખાતું સફળતાપૂર્વક બની ગયું છે. લૉગ ઇન કરવા આગળ વધો.';

  @override
  String get continueLogin => 'લૉગ ઇન કરવા આગળ વધો';

  @override
  String get allReports => 'બધા રિપોર્ટ';

  @override
  String get filterReviewed => 'તપાસેલાં';

  @override
  String get filterNeedsReview => 'તપાસવાની જરૂર છે';

  @override
  String get filterProcessing => 'પ્રક્રિયા ચાલુ છે';

  @override
  String get filterOriginalOnly => 'માત્ર મૂળ';

  @override
  String get reportDateNewest => 'રિપોર્ટની તારીખ · સૌથી નવા પહેલાં';

  @override
  String get reportDateOldest => 'રિપોર્ટની તારીખ · સૌથી જૂના પહેલાં';

  @override
  String get uploadDateNewest => 'અપલોડની તારીખ · સૌથી નવા પહેલાં';

  @override
  String get uploadDateOldest => 'અપલોડની તારીખ · સૌથી જૂના પહેલાં';

  @override
  String get switchAction => 'બદલો';

  @override
  String get collectionDate => 'નમૂનો લીધાની તારીખ';

  @override
  String get copy => 'કૉપિ કરો';

  @override
  String get history => 'ઇતિહાસ';

  @override
  String get loadingReport => 'રિપોર્ટ લોડ થઈ રહ્યો છે…';

  @override
  String get restore => 'પુનઃસ્થાપિત કરો';

  @override
  String get revoke => 'લિંક રદ કરો';

  @override
  String get testName => 'તપાસનું નામ';

  @override
  String get viewReport => 'રિપોર્ટ જુઓ';

  @override
  String get closeAccount => 'ખાતું બંધ કરો';

  @override
  String get createShareLink => 'શેર કરવા માટે લિંક બનાવો';
}
