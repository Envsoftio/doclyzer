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

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'દેખાવ બદલાયો, પરંતુ આગલી વખત માટે સાચવી શકાયો નથી.';

  @override
  String get uiThisReportIsNoLongerAvailable => 'આ રિપોર્ટ હવે ઉપલબ્ધ નથી.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'સૂચના પૂર્વાવલોકનોનું સંચાલન કરવા માટે ઉપકરણ સેટિંગ્સ ખોલો.';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'જ્યાં સુધી અપલોડ સ્વીકારવામાં ન આવે ત્યાં સુધી આ સ્ક્રીનને ખુલ્લી રાખો.';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'અપલોડમાં વિક્ષેપ આવ્યો હોઈ શકે છે';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'રિપોર્ટ્સ તપાસો. જો તે ખૂટે છે, તો તે જ ફાઇલ ફરીથી ઉમેરો.';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'સૂચનાઓ કાઢી શકાઈ નથી. ફરી પ્રયાસ કરો.';

  @override
  String get uiConnectionUnavailable => 'કનેક્શન અનુપલબ્ધ';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'તમારું સત્ર તપાસી શકાયું નથી. ઇન્ટરનેટથી કનેક્ટ કરો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiSignInWithAnotherAccount => 'બીજા એકાઉન્ટ વડે સાઇન ઇન કરો';

  @override
  String get uiNoActiveProfile => 'કોઈ સક્રિય પ્રોફાઇલ નથી';

  @override
  String get uiDismissUploadNotice => 'અપલોડ નોટિસ કાઢી નાખો';

  @override
  String get uiDismissReadyNotifications => 'તૈયાર સૂચનાઓ કાઢી નાખો';

  @override
  String get uiRequestSupport => 'સમર્થનની વિનંતી કરો';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'અમે ડાયગ્નોસ્ટિક ID નો સમાવેશ કરીશું જેથી ટીમ તપાસ કરી શકે.';

  @override
  String get uiSendRequest => 'વિનંતી મોકલો';

  @override
  String get uiWhatHappenedOptional => 'શું થયું? (વૈકલ્પિક)';

  @override
  String get uiReviewResult => 'પરિણામની સમીક્ષા કરો';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'સાચવતા પહેલા મૂળ રિપોર્ટ સાથે આ ફીલ્ડ્સની સરખામણી કરો.';

  @override
  String get uiOriginallyExtracted => 'મૂળ રીતે કાઢવામાં આવે છે';

  @override
  String get uiReloadReport => 'રિપોર્ટ ફરીથી લોડ કરો';

  @override
  String get uiResultAsPrinted => 'મુદ્રિત તરીકે પરિણામ';

  @override
  String get uiUnitIfShown => 'એકમ (જો બતાવેલ હોય તો)';

  @override
  String get uiLabReferenceRangeIfShown =>
      'લેબ સંદર્ભ શ્રેણી (જો બતાવવામાં આવે તો)';

  @override
  String get uiCheckYourReport => 'તમારો રિપોર્ટ તપાસો';

  @override
  String get uiNoAttemptHistoryAvailable => 'કોઈ પ્રયાસ ઇતિહાસ ઉપલબ્ધ નથી.';

  @override
  String get uiIInspectedTheOriginal => 'મેં મૂળનું નિરીક્ષણ કર્યું';

  @override
  String get uiChooseTwoReports => 'બે અહેવાલો પસંદ કરો';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'એક જ વ્યક્તિ માટે રેકોર્ડ્સનો ઉપયોગ કરો. મેચિંગ પરીક્ષણો સાથે-સાથે દેખાશે.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'પહેલા જૂનો રિપોર્ટ પસંદ કરો અને બીજો નવો રિપોર્ટ પસંદ કરો.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'જ્યારે સુસંગત હોય ત્યારે જ સરખામણી. સુસંગતતાની પુષ્ટિ ન થાય ત્યાં સુધી વિવિધ એકમો અથવા પદ્ધતિઓ અલગથી બતાવવામાં આવે છે.';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'ફેરફાર એ નિદાન નથી. દરેક પરિણામની તેના પોતાના રિપોર્ટ અંતરાલ સાથે સરખામણી કરો અને તમારા ક્લિનિશિયન સાથે સંદર્ભની ચર્ચા કરો.';

  @override
  String get uiChooseDifferentReports => 'વિવિધ અહેવાલો પસંદ કરો';

  @override
  String get uiEarlierReport => 'અગાઉનો અહેવાલ';

  @override
  String get uiLaterReport => 'બાદમાં રિપોર્ટ';

  @override
  String get uiYourReportPages => 'તમારા રિપોર્ટ પૃષ્ઠો';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'રિપોર્ટની જેમ પૃષ્ઠોને સમાન ક્રમમાં રાખો.';

  @override
  String get uiAddAnotherPage => 'બીજું પૃષ્ઠ ઉમેરો';

  @override
  String get uiChoosePagesFromGallery => 'ગેલેરીમાંથી પૃષ્ઠો પસંદ કરો';

  @override
  String get uiAdjustPage => 'પૃષ્ઠ સમાયોજિત કરો';

  @override
  String get uiRetake => 'ફરીથી લો';

  @override
  String get uiUseAdjustedPage => 'સમાયોજિત પૃષ્ઠનો ઉપયોગ કરો';

  @override
  String get uiResetChanges => 'ફેરફારો રીસેટ કરો';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'દરેક પરિણામ ખૂણાની અંદર રાખો.';

  @override
  String get uiRotate => 'ફેરવો';

  @override
  String get uiReportRestored => 'રિપોર્ટ પુનઃસ્થાપિત';

  @override
  String get uiDeleteReportPermanently => 'રિપોર્ટ કાયમ માટે ડિલીટ કરીએ?';

  @override
  String get uiDeletePermanently => 'કાયમ માટે કાઢી નાખો';

  @override
  String get uiReportPermanentlyDeleted => 'રિપોર્ટ કાયમ માટે કાઢી નાખ્યો';

  @override
  String get uiEmptyRecycleBin => 'ખાલી રિસાયકલ બિન?';

  @override
  String get uiDeleteAll => 'બધા કાઢી નાખો';

  @override
  String get uiRecycleBinIsEmpty => 'રિસાયકલ બિન ખાલી છે.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'કાઢી નાખેલ અહેવાલો દૂર કરતા પહેલા અહીં દેખાશે.';

  @override
  String get uiEmptyRecycleBind657e2 => 'ખાલી રિસાયકલ બિન';

  @override
  String get uiCheckDetectedResult => 'શોધાયેલ પરિણામ તપાસો';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'મૂળ અહેવાલ સાથે આ પંક્તિની સરખામણી કરો. સાચવતા પહેલા કોઈપણ OCR ભૂલો સુધારી લો.';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'મેં મૂળ રિપોર્ટ સામે આ પરિણામ તપાસ્યું';

  @override
  String get uiSaving => 'સાચવી રહ્યું છે...';

  @override
  String get uiSaveVerifiedResult => 'ચકાસાયેલ પરિણામ સાચવો';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'કોઈ પરિણામો મળ્યાં નથી. મૂળ અહેવાલ જુઓ અથવા ફરીથી પ્રક્રિયા કરવાનો પ્રયાસ કરો.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'શોધાયેલ મૂલ્યો સાચવેલ પરિણામો બને તે પહેલા મૂળ રિપોર્ટ સામે તપાસવાની જરૂર છે.';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'કેટલીક પંક્તિઓ ખૂટે છે. સમગ્ર મૂળ અહેવાલની તપાસ કરો.';

  @override
  String get uiResult => 'પરિણામ';

  @override
  String get uiUnitOptional => 'એકમ (વૈકલ્પિક)';

  @override
  String get uiReferenceRangeOptional => 'સંદર્ભ શ્રેણી (વૈકલ્પિક)';

  @override
  String get uiVerified => 'ચકાસાયેલ';

  @override
  String get uiGiftVoucher => 'ભેટ વાઉચર';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'ગિફ્ટ વાઉચર રિડીમ કરો અને સીધા તમારા બેલેન્સમાં ક્રેડિટ ઉમેરો.';

  @override
  String get uiCurrentPlan => 'વર્તમાન યોજના';

  @override
  String get uiCreditBalance => 'ક્રેડિટ બેલેન્સ';

  @override
  String get uiPlanLimits => 'યોજના મર્યાદાઓ';

  @override
  String get uiBuyCredits => 'ક્રેડિટ્સ ખરીદો';

  @override
  String get uiRecentBillingActivity => 'તાજેતરની બિલિંગ પ્રવૃત્તિ';

  @override
  String get uiRefreshStatus => 'સ્થિતિ તાજું કરો';

  @override
  String get uiNoRecentOrdersYet => 'હજુ સુધી કોઈ તાજેતરના ઓર્ડર નથી.';

  @override
  String get uiVoucherCode => 'વાઉચર કોડ';

  @override
  String get uiCheckout => 'ચેકઆઉટ';

  @override
  String get uiApply => 'અરજી કરો';

  @override
  String get uiClear => 'સાફ કરો';

  @override
  String get uiPay => 'પે';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'આ સમયે કોઈ ક્રેડિટ પેક ઉપલબ્ધ નથી.';

  @override
  String get uiBuy => 'ખરીદો';

  @override
  String get uiRetryPayment => 'ચુકવણીનો ફરી પ્રયાસ કરો';

  @override
  String get uiPromoCode => 'પ્રોમો કોડ';

  @override
  String get uiEnterPromoCode => 'પ્રોમો કોડ દાખલ કરો';

  @override
  String get uiChooseAPlan => 'એક યોજના પસંદ કરો';

  @override
  String get uiNoPlansAvailableAtThisTime => 'આ સમયે કોઈ પ્લાન ઉપલબ્ધ નથી.';

  @override
  String get uiHaveAPromoCode => 'પ્રોમો કોડ છે?';

  @override
  String get uiCURRENTPLAN => 'વર્તમાન યોજના';

  @override
  String get uiManageNotifications => 'સૂચનાઓનું સંચાલન કરો';

  @override
  String get uiAll => 'બધા';

  @override
  String get uiUnread => 'ન વાંચેલ';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'ઍક્સેસ તરત જ અટકી જાય છે. તમે સાઇન ઇન કરી શકો છો અને 30 દિવસની અંદર પુનઃસ્થાપિત કરી શકો છો. તે પછી, તમારું એકાઉન્ટ અને સંગ્રહિત ફાઇલો સક્રિય સ્ટોરેજમાંથી કાઢી નાખવામાં આવે છે.';

  @override
  String get uiCloseMyAccount => 'મારું એકાઉન્ટ બંધ કરો';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'તમારા રેકોર્ડ્સ ડોકલાઈઝરમાં રહે છે.';

  @override
  String get uiTakeACopyOfYourRecords => 'તમારા રેકોર્ડની નકલ લો.';

  @override
  String get uiWhoseRecords => 'કોનો રેકોર્ડ?';

  @override
  String get uiCouldNotLoadProfiles => 'પ્રોફાઇલ લોડ કરી શકાઈ નથી';

  @override
  String get uiLoadingProfiles => 'પ્રોફાઇલ્સ લોડ કરી રહ્યું છે...';

  @override
  String get uiAllProfiles => 'બધી પ્રોફાઇલ';

  @override
  String get uiDateRange => 'તારીખ શ્રેણી';

  @override
  String get uiUseAllDates => 'બધી તારીખોનો ઉપયોગ કરો';

  @override
  String get uiINCLUDEINTHISEXPORT => 'આ નિકાસમાં સમાવેશ કરો';

  @override
  String get uiOriginalReports => 'મૂળ અહેવાલો';

  @override
  String get uiPDFsAndImagesYouUploaded => 'તમે અપલોડ કરેલી PDF અને છબીઓ';

  @override
  String get uiTestResults => 'પરીક્ષણ પરિણામો';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'CSV તરીકે પરિણામો, તેમની સમીક્ષા સ્થિતિ સાથે';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'નિકાસમાં વ્યક્તિગત માહિતી હોય છે. જ્યાં તમે વિશ્વાસ કરો છો ત્યાં તેમને સ્ટોર કરો.';

  @override
  String get uiDeleteAccount => 'એકાઉન્ટ કાઢી નાખો';

  @override
  String get uiContinueToDeletion => 'કાઢી નાખવાનું ચાલુ રાખો';

  @override
  String get uiKeepMyAccount => 'મારું એકાઉન્ટ રાખો';

  @override
  String get uiBeforeYouLeave => 'તમે જતા પહેલા';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'કૃપા કરીને વાંચો કે આ શું દૂર કરશે.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'તમારું એકાઉન્ટ કાઢી નાખવાથી તમે મેનેજ કરો છો તે બધી પ્રોફાઇલને અસર કરે છે.';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'તમારું એકાઉન્ટ અને વ્યક્તિગત પ્રોફાઇલ';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'તમારી શેર કરેલી લિંક્સ દ્વારા ઍક્સેસ કરો';

  @override
  String get uiKeepACopyFirst => 'પહેલા એક નકલ રાખો';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'તમે જે માહિતી જાળવી રાખવા માંગો છો તે નિકાસ કરો.';

  @override
  String get uiExportData => 'ડેટા નિકાસ કરો';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'ઍક્સેસ તરત જ અટકી જાય છે. તમે 30 દિવસની અંદર પુનઃસ્થાપિત કરી શકો છો. તે પછી, તમારો ડેટા સક્રિય સ્ટોરેજમાંથી દૂર કરવામાં આવે છે.';

  @override
  String get uiAccountPendingDeletion => 'એકાઉન્ટ ડિલીટ કરવાનું બાકી છે';

  @override
  String get uiRestoreMyAccount => 'મારું એકાઉન્ટ પુનઃસ્થાપિત કરો';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'તમારી પ્રોફાઇલ, પ્રોફાઇલ્સ અને સંમતિ રેકોર્ડ સહિત તમારા એકાઉન્ટ ડેટાની એક નકલ ડાઉનલોડ કરો.';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'તમારું એકાઉન્ટ તરત જ અક્ષમ કરવામાં આવે છે. તમે તેને 30 દિવસની અંદર પુનઃસ્થાપિત કરી શકો છો. તે પછી, તમારો ડેટા કાયમ માટે કાઢી નાખવામાં આવે છે.';

  @override
  String get uiCurrentPassword => 'વર્તમાન પાસવર્ડ';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'એપ લોક બદલી શકાયું નથી. ફરી પ્રયાસ કરો.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'તમારા રેકોર્ડ્સ.\nશેર કરવાની તમારી પસંદગી.';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'જ્યારે પણ તમને જરૂર હોય ત્યારે ઍક્સેસની સમીક્ષા કરો.';

  @override
  String get uiAppLock => 'એપ લોક';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'તમારા ઉપકરણના બાયોમેટ્રિક અથવા પાસકોડ લોકનો ઉપયોગ કરો.';

  @override
  String get uiNotificationPreviews => 'સૂચના પૂર્વાવલોકનો';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'તમારા ઉપકરણ સેટિંગ્સમાં લોક-સ્ક્રીન પૂર્વાવલોકનોને નિયંત્રિત કરો.';

  @override
  String get uiContactSupport => 'સપોર્ટનો સંપર્ક કરો';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'જો તમે પસંદ કરો તો જ રિપોર્ટ્સ જોડો.';

  @override
  String get uiWhatCanWeHelpYouWith => 'અમે તમને શું મદદ કરી શકીએ?';

  @override
  String get uiPOPULARQUESTIONS => 'લોકપ્રિય પ્રશ્નો';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'તમારી શોધ સાથે કોઈ મદદ લેખો મેળ ખાતા નથી.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'તમારા સ્વાસ્થ્ય અથવા પરીક્ષણ પરિણામો વિશેના પ્રશ્નો માટે, લાયકાત ધરાવતા હેલ્થકેર પ્રોફેશનલ સાથે વાત કરો.';

  @override
  String get uiYourReportsAClearerPicture => 'તમારા અહેવાલો. વધુ સ્પષ્ટ ચિત્ર.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'તમારા સ્વાસ્થ્યનો ઇતિહાસ સાથે રાખો.';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'રિપોર્ટ સ્ટોર કરો, પરિણામોની સમીક્ષા કરો, ફેરફારોને અનુસરો અને તમારા ક્લિનિશિયન સાથે શેર કરો.';

  @override
  String get uiEducationalInformationOnly => 'માત્ર શૈક્ષણિક માહિતી';

  @override
  String get uiSearchHelpArticles => 'મદદ લેખો શોધો';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'સૂચના ઍક્સેસ બદલવા માટે ઉપકરણ સેટિંગ્સ એપ્લિકેશન ખોલો.';

  @override
  String get uiSavePreferences => 'પસંદગીઓ સાચવો';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'સેટિંગ્સમાં ઉપકરણની પરવાનગીઓ બદલી શકાય છે.';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'આ ઉપકરણ પર રિપોર્ટ અપડેટ્સ મેળવો';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'જ્યારે રિપોર્ટ તૈયાર થાય ત્યારે સૂચનાઓને જાણવાની મંજૂરી આપો. માર્કેટિંગ નીચે એક અલગ પસંદગી છે.';

  @override
  String get uiREPORTACTIVITY => 'પ્રવૃત્તિની જાણ કરો';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'રિપોર્ટ પ્રવૃત્તિ સેટિંગ્સને નવીનતમ સર્વર સંસ્કરણની જરૂર છે.';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'સંવેદનશીલ લોક-સ્ક્રીન પૂર્વાવલોકનો';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'રિપોર્ટના નામ અને વ્યક્તિગત વિગતો હંમેશા છુપાવવામાં આવે છે.';

  @override
  String get uiOTHERMESSAGES => 'અન્ય સંદેશા';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'દરેક વ્યક્તિના અહેવાલો અને વલણો સાથે રાખો.';

  @override
  String get uiPersonDetails => 'વ્યક્તિની વિગતો';

  @override
  String get uiDateOfBirth => 'જન્મ તારીખ';

  @override
  String get uiRelationship => 'સંબંધ';

  @override
  String get uiEnterAName => 'નામ દાખલ કરો';

  @override
  String get uiClearDateOfBirth => 'જન્મ તારીખ સ્પષ્ટ કરો';

  @override
  String get uiOptionalEGParentOrChild => 'વૈકલ્પિક, દા.ત. માતાપિતા અથવા બાળક';

  @override
  String get uiInviteFriendsEarnCredits =>
      'મિત્રોને આમંત્રિત કરો, ક્રેડિટ કમાઓ';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'તમારો કોડ શેર કરો અને ઇનામ અનલૉક તરીકે દરેક આમંત્રણને અનુસરો.';

  @override
  String get uiYOURREFERRALCODE => 'તમારો રેફરલ કોડ';

  @override
  String get uiShareInvite => 'આમંત્રણ શેર કરો';

  @override
  String get uiCopyCode => 'કોડ કૉપિ કરો';

  @override
  String get uiHaveACode => 'કોડ છે?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'તમારા આમંત્રણ પુરસ્કારનો દાવો કરવા માટે તમારી સાથે શેર કરેલ કોડ દાખલ કરો.';

  @override
  String get uiHowRewardsWork => 'પુરસ્કારો કેવી રીતે કાર્ય કરે છે';

  @override
  String get uiNoFriendsReferredYet => 'હજુ સુધી કોઈ મિત્રોનો ઉલ્લેખ કર્યો નથી';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'તેમની પ્રગતિ જોવા માટે તમારું આમંત્રણ અહીં શેર કરો.';

  @override
  String get uiReferralCode => 'રેફરલ કોડ';

  @override
  String get uiSetNewPassword => 'નવો પાસવર્ડ સેટ કરો';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'તમારા ઇમેઇલ અને તમારા નવા પાસવર્ડની લિંકમાંથી રીસેટ ટોકન દાખલ કરો.';

  @override
  String get uiResetPassword => 'પાસવર્ડ રીસેટ કરો';

  @override
  String get uiBackToLogin => 'લૉગિન પર પાછા જાઓ';

  @override
  String get uiResetToken => 'ટોકન રીસેટ કરો';

  @override
  String get uiNewPassword => 'નવો પાસવર્ડ';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'તમારા એકાઉન્ટ સાથે સંકળાયેલ ઇમેઇલ સરનામું દાખલ કરો અને અમે તમને તમારો પાસવર્ડ રીસેટ કરવા માટે એક લિંક મોકલીશું.';

  @override
  String get uiSendResetLink => 'રીસેટ લિંક મોકલો';

  @override
  String get uiRevokeSession => 'સત્ર રદ કરીએ?';

  @override
  String get uiCurrentSession => 'વર્તમાન સત્ર';

  @override
  String get uiSkip => 'છોડો';

  @override
  String get uiChangePassword => 'પાસવર્ડ બદલો';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'તમારો વર્તમાન પાસવર્ડ દાખલ કરો અને નવો પસંદ કરો.';

  @override
  String get uiNewPasswordd850ee => 'નવો પાસવર્ડ';

  @override
  String get uiConfirmNewPassword => 'નવા પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get uiGettingThingsReady => 'વસ્તુઓ તૈયાર કરી રહ્યાં છીએ...';

  @override
  String get uiLinkAccessHistory => 'લિંક ઍક્સેસ ઇતિહાસ';

  @override
  String get uiNoAccessEventsYet => 'હજી સુધી કોઈ ઍક્સેસ ઇવેન્ટ નથી.';

  @override
  String get uiDefaultShareLinkExpiry => 'ડિફોલ્ટ શેર લિંક એક્સપાયરી';

  @override
  String get uiSave => 'સાચવો';

  @override
  String get uiReviewSharing => 'શેરિંગની સમીક્ષા કરો';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'વ્યક્તિ, રિપોર્ટ્સ અને એક્સેસ તપાસો.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'પસંદગી અથવા ઍક્સેસ સેટિંગ્સમાં ફેરફાર કરો';

  @override
  String get uiRevokeShareLink => 'શેર કરેલી લિંકને રદ કરીએ?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'આ લિંક કામ કરવાનું બંધ કરશે. તમે એક નવું બનાવી શકો છો.';

  @override
  String get uiShareLinkReady => 'શેર લિંક તૈયાર છે';

  @override
  String get uiAccessCodeShareSeparately => 'એક્સેસ કોડ - અલગથી શેર કરો';

  @override
  String get uiCopyAccessCode => 'એક્સેસ કોડ કૉપિ કરો';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'આ કોડ આ ઉપકરણ પર સાચવી શકાયો નથી. હવે પછીના ઉપયોગ માટે તેની નકલ કરો.';

  @override
  String get uiShareLink => 'લિંક શેર કરો';

  @override
  String get uiCopyLink => 'લિંક કૉપિ કરો';

  @override
  String get uiRevokeLink => 'લિંક રદબાતલ કરો';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'આ ઉપકરણ પર કોડ અનુપલબ્ધ છે. સાચવેલા કોડનો ઉપયોગ કરો અથવા નવી લિંક બનાવો.';

  @override
  String get uiActiveSharedLinks => 'સક્રિય શેર કરેલી લિંક્સ';

  @override
  String get uiShare => 'શેર કરો';

  @override
  String get uiCreateANewShareLink => 'નવી શેર લિંક બનાવો';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'આ પ્રોફાઇલ માટે વર્તમાન અને ભાવિ અહેવાલો શામેલ કરો.';

  @override
  String get uiChooseReports => 'અહેવાલો પસંદ કરો';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'નીચે પસંદ કરેલા અહેવાલો જ શેર કરો.';

  @override
  String get uiSelectAll => 'બધા પસંદ કરો';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'શેર કરવા માટે કોઈ સમીક્ષા કરેલ અહેવાલો ઉપલબ્ધ નથી.';

  @override
  String get uiSelectedTestResults => 'પસંદ કરેલ પરીક્ષણ પરિણામો';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'આ રિપોર્ટ્સમાંથી તમે પસંદ કરેલા પરિણામોને જ શામેલ કરો.';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'આ અહેવાલોમાં કોઈ સાચવેલા પરીક્ષણ પરિણામો ઉપલબ્ધ નથી.';

  @override
  String get uiUpgradeOrManage => 'અપગ્રેડ કરો અથવા મેનેજ કરો';

  @override
  String get uiExpiry => 'સમાપ્તિ:';

  @override
  String get uiRequireAnAccessCode => 'ઍક્સેસ કોડની જરૂર છે';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink => 'લિંકથી અલગથી કોડ શેર કરો.';

  @override
  String get uiTryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get uiClearExpiry => 'ક્લિયર એક્સપાયરી';

  @override
  String get onboardingStoreEyebrow => '01 / સાચવો';

  @override
  String get onboardingStoreTitle => 'દરેક રિપોર્ટ,\nએક પરિચિત સ્થળ.';

  @override
  String get onboardingStoreBody =>
      'તમારા અને તમે જેની કાળજી લો છો તે લોકો માટે PDF અને ફોટા સાથે રાખો.';

  @override
  String get onboardingUnderstandEyebrow => '02 / સમજો';

  @override
  String get onboardingUnderstandTitle => 'નંબરો,\nવાંચવાનું સરળ બનાવ્યું.';

  @override
  String get onboardingUnderstandBody =>
      'તમારા રિપોર્ટમાંથી દરેક ટેસ્ટ, તેનું યુનિટ અને અંતરાલ જુઓ. કોઈપણ સમયે મૂળ તપાસો.';

  @override
  String get onboardingTrackEyebrow => '03 / ટ્રેક અને શેર કરો';

  @override
  String get onboardingTrackTitle => 'ફેરફારો જુઓ.\nસંદર્ભ શેર કરો.';

  @override
  String get onboardingTrackBody =>
      'સમય જતાં પરિણામોને અનુસરો અને તમારા ક્લિનિશિયન શું જોઈ શકે તે બરાબર પસંદ કરો.';

  @override
  String get onboardingNext => 'આગળ';

  @override
  String get onboardingGetStarted => 'પ્રારંભ કરો';

  @override
  String get uiSupportRequestSent => 'આધાર વિનંતી મોકલી.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'ટેસ્ટનું નામ અને પરિણામ આવશ્યક છે.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD ફોર્મેટમાં માન્ય સંગ્રહ તારીખનો ઉપયોગ કરો.';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'આ કરેક્શન સાચવી શકાયું નથી. ફરી પ્રયાસ કરો.';

  @override
  String get uiReportsUnavailable => 'રિપોર્ટ ઉપલબ્ધ નથી';

  @override
  String get uiTryAgain042c86 => 'ફરી પ્રયાસ કરો';

  @override
  String get uiTwoReportsAreNeeded => 'બે રિપોર્ટની જરૂર છે';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'પરિણામોની સરખામણી કરવા માટે આ પ્રોફાઇલ માટે જૂની રિપોર્ટ ઉમેરો.';

  @override
  String get uiCannotCompareYet => 'હજી સરખામણી કરી શકાતી નથી';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'આ રિપોર્ટ્સમાં સરખામણી માટે કોઈ મેળ ખાતા પરિણામો ઉપલબ્ધ નથી.';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'રિપોર્ટ્સ લોડ કરવામાં અસમર્થ. ફરી પ્રયાસ કરો.';

  @override
  String get uiCouldNotOpenPhotosOrCamera => 'ફોટા કે કેમેરા ખોલી શકાયા નથી.';

  @override
  String get uiCouldNotOpenCamera => 'કૅમેરો ખોલી શકાયો નથી.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'આ પૃષ્ઠો તૈયાર કરી શક્યા નથી. વાંચી ન શકાય તેવું પેજ ફરી લો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiCouldNotAdjustThisPage => 'આ પૃષ્ઠ સમાયોજિત કરી શકાયું નથી.';

  @override
  String get uiNoChartableResultYet => 'હજુ સુધી કોઈ ચાર્ટેબલ પરિણામ નથી';

  @override
  String get uiProfiles => 'પ્રોફાઇલ્સ';

  @override
  String get uiReports => 'રિપોર્ટ';

  @override
  String get uiShareLinks => 'લિંક્સ શેર કરો';

  @override
  String get uiAIChat => 'AI ચેટ';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'ઉમેદવારી સારાંશ લોડ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'બિલિંગ સ્ટેટસ રિફ્રેશ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'રસીદ ડાઉનલોડ ટૂંક સમયમાં ઉપલબ્ધ થશે.';

  @override
  String get uiSubtotal => 'પેટાટોટલ';

  @override
  String get uiDiscount => 'ડિસ્કાઉન્ટ';

  @override
  String get uiTotal => 'કુલ';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'ક્રેડિટ પેક લોડ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'એક ચુકવણી કેપ્ચર બાકી છે. અન્ય ચેકઆઉટ શરૂ કરતા પહેલા સ્થિતિ તાજું કરો.';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'ક્રેડિટ સફળતાપૂર્વક લાગુ કરવામાં આવી હતી.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ઓર્ડર બનાવવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'ચુકવણી પ્રાપ્ત થઈ. ક્રેડિટ ઉમેરવામાં આવે તે પહેલાં સર્વર સમાધાનની રાહ જોઈ રહ્યું છે.';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'ચુકવણી નિષ્ફળ. તૈયાર થવા પર તમે ચેકઆઉટનો ફરી પ્રયાસ કરી શકો છો.';

  @override
  String get uiPaymentFailedTryAgain => 'ચુકવણી નિષ્ફળ. ફરી પ્રયાસ કરો.';

  @override
  String get uiCreditsAdded => 'ક્રેડિટ ઉમેરી!';

  @override
  String get uiPromoCodeApplied => 'પ્રોમો કોડ લાગુ કર્યો.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'ચુકવણી પ્રાપ્ત થઈ છે, પરંતુ આ ઓર્ડરની સમીક્ષા બાકી છે.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'સમાધાન દરમિયાન ચુકવણી નિષ્ફળ થઈ.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'ચુકવણીની પુષ્ટિ થઈ. સર્વર સમાધાન હજુ બાકી છે.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'ચુકવણીની ચકાસણી થઈ. સમાધાન બાકી છે, કૃપા કરીને ટૂંક સમયમાં તાજું કરો.';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'ચુકવણી પ્રાપ્ત થઈ છે પરંતુ ચકાસણી હજુ બાકી છે. કૃપા કરીને સ્થિતિ તાજી કરો.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'પ્લાન લોડ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'સબ્સ્ક્રિપ્શન બનાવવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'સબ્સ્ક્રિપ્શન નિષ્ફળ થયું. ફરી પ્રયાસ કરો.';

  @override
  String get uiPlanUpgraded => 'પ્લાન અપગ્રેડ કર્યો!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'ચુકવણી પ્રાપ્ત થઈ પરંતુ ચકાસણી નિષ્ફળ થઈ. યોજના ટૂંક સમયમાં અપગ્રેડ કરવામાં આવશે.';

  @override
  String get uiNotificationsUnavailable => 'સૂચનાઓ અનુપલબ્ધ';

  @override
  String get uiAllQuietForNow => 'અત્યારે બધા શાંત.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'જ્યારે કંઈક નવું હશે ત્યારે રિપોર્ટ અપડેટ્સ અને શેરિંગ રિમાઇન્ડર્સ અહીં દેખાશે.';

  @override
  String get uiNoUnreadUpdates => 'કોઈ વાંચ્યા વગરના અપડેટ્સ નથી';

  @override
  String get uiYouReAllCaughtUp => 'તમે બધા પકડાઈ ગયા છો.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'સૂચનાઓ લોડ કરવામાં અસમર્થ. કનેક્ટ થવા પર ફરી પ્રયાસ કરો.';

  @override
  String get uiManageSharedLinks => 'શેર કરેલી લિંક્સ મેનેજ કરો';

  @override
  String get uiExportYourData => 'તમારા ડેટાની નિકાસ કરો';

  @override
  String get uiReadThePrivacyPolicy => 'ગોપનીયતા નીતિ વાંચો';

  @override
  String get uiTermsOfUse => 'ઉપયોગની શરતો';

  @override
  String get uiPrivacyPolicy => 'ગોપનીયતા નીતિ';

  @override
  String get uiDateOfBirthOptional => 'જન્મ તારીખ, વૈકલ્પિક';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'સંબંધ 50 કે તેથી ઓછા અક્ષરોનો હોવો જોઈએ.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'પ્રોફાઇલ સાચવવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiReferralsUnavailable => 'રેફરલ્સ અનુપલબ્ધ';

  @override
  String get uiYourRewards => 'તમારા પુરસ્કારો';

  @override
  String get uiReferralProgress => 'રેફરલ પ્રગતિ';

  @override
  String get uiFriendsReferred => 'મિત્રોનો ઉલ્લેખ કર્યો';

  @override
  String get uiCreditsEarned => 'ક્રેડિટ મેળવી';

  @override
  String get uiPendingRewards => 'બાકી પુરસ્કારો';

  @override
  String get uiBlockedRewards => 'અવરોધિત પુરસ્કારો';

  @override
  String get uiInviteeBonus => 'આમંત્રિત બોનસ';

  @override
  String get uiFirstAnalysis => 'પ્રથમ વિશ્લેષણ';

  @override
  String get uiFirstPurchase => 'પ્રથમ ખરીદી';

  @override
  String get uiMonthlyCap => 'માસિક કેપ';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'રેફરલ્સ લોડ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiReferralCodeCopied => 'રેફરલ કોડ કૉપિ કર્યો.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'તમારી ઇમેઇલ લિંક પરથી રીસેટ ટોકન દાખલ કરો';

  @override
  String get uiEnterYourNewPassword => 'તમારો નવો પાસવર્ડ દાખલ કરો';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'પાસવર્ડ રીસેટ કરવામાં અસમર્થ. કૃપા કરીને નવી લિંકની વિનંતી કરો.';

  @override
  String get uiEnterYourEmailAddress => 'તમારું ઇમેઇલ સરનામું દાખલ કરો';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'રીસેટ લિંક મોકલવામાં અસમર્થ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiFailedToLoadSessions => 'સત્રો લોડ કરવામાં નિષ્ફળ.';

  @override
  String get uiFailedToRevokeSession => 'સત્ર રદ કરવામાં નિષ્ફળ.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'પાસવર્ડ બદલવામાં અસમર્થ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'ઉપકરણ સેટિંગ્સ ખોલો અને Doclyzer માટે સૂચનાઓને મંજૂરી આપો.';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'રિપોર્ટ્સ લોડ કરી શકાયા નથી. ફરી પ્રયાસ કરો.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'પરીક્ષણ પરિણામો લોડ કરી શકાયા નથી. ફરી પ્રયાસ કરો.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'શેર કરવા માટે ઓછામાં ઓછો એક રિપોર્ટ પસંદ કરો.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'શેર કરવા માટે ઓછામાં ઓછું એક પરીક્ષણ પરિણામ પસંદ કરો.';

  @override
  String get uiLinkCopiedToClipboard => 'લિંક ક્લિપબોર્ડ પર કૉપિ કરી';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'ઍક્સેસ કોડ ક્લિપબોર્ડ પર કૉપિ કર્યો';

  @override
  String get uiOnePerson => '1 વ્યક્તિ';

  @override
  String uiPeopleCount(String count) {
    return '$count લોકો';
  }

  @override
  String uiActionsFor(String name) {
    return '$name માટે ક્રિયાઓ';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'પ્રોફાઇલ સ્વિચ કરવામાં અસમર્થ. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name પર સ્વિચ કર્યું';
  }

  @override
  String get uiAnalyzeOnePage => '1 પૃષ્ઠનું વિશ્લેષણ કરો';

  @override
  String uiAnalyzePages(String count) {
    return '$count પૃષ્ઠોનું વિશ્લેષણ કરો';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'તમારા રિપોર્ટમાં દર્શાવેલ ક્રમમાં પૃષ્ઠોને ખેંચો';

  @override
  String get uiCheckEveryPage => 'વિશ્લેષણ કરતા પહેલા દરેક પૃષ્ઠ તપાસો';

  @override
  String get uiOnePageAdded => '1 પૃષ્ઠ ઉમેર્યું';

  @override
  String uiPagesAdded(String count) {
    return '$count પૃષ્ઠો ઉમેર્યા';
  }

  @override
  String get uiReorder => 'ફરીથી ગોઠવો';

  @override
  String uiPageNumber(String number) {
    return 'પૃષ્ઠ $number';
  }

  @override
  String uiRemovePage(String number) {
    return '$number પૃષ્ઠ દૂર કરો';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · પૃષ્ઠ $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'કિનારી કાપો: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count પસંદ કરેલા અહેવાલો';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count પસંદ કરેલ પરીક્ષણ પરિણામો';
  }

  @override
  String get uiAllCurrentFutureReports => 'તમામ વર્તમાન અને ભાવિ અહેવાલો';

  @override
  String get uiNoExpiry => 'કોઈ એક્સપાયરી નથી';

  @override
  String uiExpiresDate(String date) {
    return '$date સમાપ્ત થાય છે';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'ઍક્સેસ કોડ આવશ્યક છે. તેને લિંકથી અલગથી શેર કરો.';

  @override
  String get uiNoAccessCodeRequired => 'કોઈ ઍક્સેસ કોડ જરૂરી નથી.';

  @override
  String uiExpiresColonDate(String date) {
    return 'સમાપ્તિ: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name ના અહેવાલો શેર કરો';
  }

  @override
  String uiProfileReports(String name) {
    return '$name ના અહેવાલો';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count પસંદ કરેલા પરિણામો';
  }

  @override
  String get uiAccessCodeRequiredShort => 'ઍક્સેસ કોડ આવશ્યક છે';

  @override
  String uiPastLinksCount(String count) {
    return 'ભૂતકાળની લિંક્સ · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return '$date સમાપ્ત';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'રદ કર્યું · $date બનાવ્યું';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum સક્રિય લિંક્સમાંથી $current નો ઉપયોગ કરવો.';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename અને તેની સંગ્રહિત ફાઇલ કાઢી નાખીએ? આ પૂર્વવત્ કરી શકાતું નથી.';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'રિપોર્ટ ડિલીટ કરવામાં અસમર્થ: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'બધા $count રિપોર્ટ્સ અને તેમની સંગ્રહિત ફાઇલોને કાયમ માટે કાઢી નાખીએ? આ પૂર્વવત્ કરી શકાતું નથી.';
  }

  @override
  String get uiRecycleBinEmptied => 'રિસાયકલ બિન ખાલી કર્યું';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted રિપોર્ટ્સ કાઢી નાખ્યા. $failed કાઢી શકાયું નથી; ફરી પ્રયાસ કરો.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'રિસાયકલ બિન ખાલી કરવામાં અસમર્થ: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'પ્રોફાઇલ: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'એકત્રિત: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'અપલોડ કરેલ: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'આના રોજ કાઢી નાખ્યું: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'આના પર કાયમી કાઢી નાખો: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'દિવસો બાકી: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer => 'Doclyzer માટે એપ લોકની પુષ્ટિ કરો';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'એપ લોક બંધ કરતા પહેલા કન્ફર્મ કરો';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'તમારા સ્વાસ્થ્ય રેકોર્ડ્સ જોવા માટે ડોકલાઈઝરને અનલોક કરો';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'રિપોર્ટ અપલોડ કરતા પહેલા ડિફૉલ્ટ પ્રોફાઇલ બનાવો.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'તમારી સમયરેખા જોતા પહેલા ડિફોલ્ટ પ્રોફાઇલ બનાવો.';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'અત્યારે પ્રોફાઇલ લોડ કરવામાં અસમર્થ.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'અત્યારે અપલોડ કરી શકાતું નથી કારણ કે પ્રોફાઇલ ડેટા લોડ કરી શકાયો નથી. કૃપા કરીને ખાતરી કરો કે API સર્વર ચાલી રહ્યું છે અને ફરી પ્રયાસ કરો.';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'અત્યારે સમયરેખા ખોલી શકાતી નથી કારણ કે પ્રોફાઇલ ડેટા લોડ કરી શકાયો નથી. કૃપા કરીને ખાતરી કરો કે API સર્વર ચાલી રહ્યું છે અને ફરી પ્રયાસ કરો.';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'અત્યારે પ્રોફાઇલ લોડ કરવામાં અસમર્થ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'શેરિંગ લિંક્સ લોડ કરવામાં અસમર્થ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiPasswordChanged => 'પાસવર્ડ બદલ્યો';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'તે રિપોર્ટ ખોલવામાં અસમર્થ. રિપોર્ટ લાઇબ્રેરીનો પ્રયાસ કરો.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'જ્યારે તમારું એકાઉન્ટ સમીક્ષા હેઠળ હોય ત્યારે આ ક્રિયા અસ્થાયી રૂપે અનુપલબ્ધ છે.';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'આ વિભાગ ખોલવામાં અસમર્થ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiAppLockIsUnavailable => 'એપ્લિકેશન લૉક અનુપલબ્ધ છે';

  @override
  String get uiDoclyzerIsLocked => 'ડોકલાઈઝર લોક છે';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'સાચવેલ એપ લોક સેટિંગ વાંચી શકાયું નથી. ચાલુ રાખવા માટે ફરી પ્રયાસ કરો.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'ચાલુ રાખવા માટે તમારા ઉપકરણ પાસકોડ અથવા બાયોમેટ્રિક્સનો ઉપયોગ કરો.';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'જ્યારે તમારું એકાઉન્ટ સમીક્ષા હેઠળ હોય ત્યારે અપલોડ્સ અસ્થાયી રૂપે અનુપલબ્ધ હોય છે.';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'અપલોડ શરૂ કરવામાં અસમર્થ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiJustNow => 'હમણાં જ';

  @override
  String get uiAdditionalDetails => 'વધારાની વિગતો:';

  @override
  String get uiSaveCorrection => 'કરેક્શન સાચવો';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'ફાઇલો ખોલી શકાઈ નથી. ઍક્સેસ તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'કૅમેરો ખોલી શકાયો નથી. પરવાનગી તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'ફોટા ખોલી શકાયા નથી. પરવાનગી તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'પસંદ કરેલી ફાઇલને ઍક્સેસ કરી શકાઈ નથી.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'પસંદ કરેલી ફાઇલને ઍક્સેસ કરી શકાઈ નથી';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'કનેક્શન તૂટી ગયું. અપલોડ સર્વર સુધી પહોંચી ગયું હશે. એ જ ફાઇલને સુરક્ષિત રીતે ફરીથી પ્રયાસ કરો.';

  @override
  String get uiCouldNotLoadExistingReport =>
      'વર્તમાન રિપોર્ટ લોડ કરી શકાયો નથી';

  @override
  String get uiAddingTo => 'માં ઉમેરી રહ્યા છે';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'કેટલાક પરિણામોની સમીક્ષા કરવાની જરૂર છે. તમારો મૂળ અહેવાલ સાચવવામાં આવ્યો છે.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'અમે આ ફોર્મેટ વાંચી શક્યા નથી. તમારી ફાઈલ સેવ થઈ ગઈ છે.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'રિપોર્ટ સફળતાપૂર્વક વિશ્લેષિત થયો. પરિણામો અને વલણો ઉપલબ્ધ છે.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'તમારા રિપોર્ટનું હજુ પણ વિશ્લેષણ કરવામાં આવી રહ્યું છે. તેની સ્થિતિ તપાસવા માટે તેને ખોલો.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'પ્રક્રિયા બંધ થઈ ગઈ. તમારી ફાઈલ સેવ થઈ ગઈ છે. તમે ફરી પ્રયાસ કરી શકો છો.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'કોઈ કાઢવામાં આવેલ પરીક્ષણ મૂલ્યો ઉમેરવામાં આવ્યાં નથી. તમે હજુ પણ દસ્તાવેજ ખોલી અને શેર કરી શકો છો. તમારા વલણો અપરિવર્તિત છે.';

  @override
  String get uiYourOriginalIsSaved => 'તમારું મૂળ સાચવવામાં આવ્યું છે.';

  @override
  String get uiInitialUpload => 'પ્રારંભિક અપલોડ';

  @override
  String get uiParsedSuccessfully => 'સફળતાપૂર્વક વિશ્લેષણ કર્યું';

  @override
  String get uiParsingFailed => 'પદચ્છેદન નિષ્ફળ થયું';

  @override
  String get uiExtractionIncomplete => 'નિષ્કર્ષણ અધૂરું';

  @override
  String get uiTransientFailure => 'ક્ષણિક નિષ્ફળતા';

  @override
  String get uiTerminalFailure => 'ટર્મિનલ નિષ્ફળતા';

  @override
  String get uiFailedToLoadAttemptHistory => 'પ્રયાસ ઇતિહાસ લોડ કરવામાં નિષ્ફળ';

  @override
  String get uiThisReportSFileIsNoLonger => 'આ રિપોર્ટની ફાઇલ હવે ઉપલબ્ધ નથી.';

  @override
  String get uiCompareResults => 'પરિણામોની સરખામણી કરો';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'કોઈ તફાવતની ગણતરી નથી. સુસંગતતાને પુષ્ટિની જરૂર છે.';

  @override
  String get uiUnitNotRecorded => 'એકમ નોંધાયેલ નથી';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'આ અહેવાલો વચ્ચે કોઈ આંકડાકીય ફેરફાર નથી.';

  @override
  String get uiUnableToRestore => 'પુનઃસ્થાપિત કરવામાં અસમર્થ:';

  @override
  String get uiEnterAGiftVoucherCode => 'ભેટ વાઉચર કોડ દાખલ કરો.';

  @override
  String get uiApplyVoucher => 'વાઉચર લાગુ કરો';

  @override
  String get uiNotAvailable => 'ઉપલબ્ધ નથી';

  @override
  String get uiViewReceipt => 'રસીદ જુઓ';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'ગિફ્ટ વાઉચર અમાન્ય છે અથવા પહેલેથી રિડીમ કરેલ છે.';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'ગિફ્ટ વાઉચર પહેલેથી જ રિડીમ કરવામાં આવ્યું છે.';

  @override
  String get uiGiftVoucherHasBeenVoided => 'ગિફ્ટ વાઉચર રદ કરવામાં આવ્યું છે.';

  @override
  String get uiGiftVoucherHasExpired =>
      'ગિફ્ટ વાઉચરની સમયસીમા સમાપ્ત થઈ ગઈ છે.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'આ ગિફ્ટ વાઉચર રિડીમ કરવામાં અસમર્થ.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'આ ગિફ્ટ વાઉચર રિડીમ કરવામાં અસમર્થ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiEnterAPromoCodeToApply => 'અરજી કરવા માટે પ્રોમો કોડ દાખલ કરો.';

  @override
  String get uiPromoCodeNotFound => 'પ્રોમો કોડ મળ્યો નથી.';

  @override
  String get uiPromoCodeIsInactive => 'પ્રોમો કોડ નિષ્ક્રિય છે.';

  @override
  String get uiPromoCodeHasExpired => 'પ્રોમો કોડ સમાપ્ત થઈ ગયો છે.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'આ પેક પર પ્રોમો કોડ લાગુ પડતો નથી.';

  @override
  String get uiPromoCodeUsageLimitReached => 'પ્રોમો કોડ વપરાશ મર્યાદા પહોંચી.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'તમે પહેલાથી જ આ પ્રોમો કોડનો ઉપયોગ કર્યો છે.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'પ્રોમો કોડ લાગુ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'ક્રેડિટ ઉમેરી શકાય તે પહેલા આ ઓર્ડરને સમીક્ષા માટે ફ્લેગ કરવામાં આવ્યો હતો.';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'સમાધાન દરમિયાન ચુકવણી નિષ્ફળ થઈ. તમે સુરક્ષિત રીતે ફરી પ્રયાસ કરી શકો છો.';

  @override
  String get uiAwaitingCapture => 'કેપ્ચરની રાહ જોઈ રહ્યું છે';

  @override
  String get uiLastPaymentFailed => 'છેલ્લી ચુકવણી નિષ્ફળ';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'તમે સુરક્ષિત રીતે ચેકઆઉટનો ફરી પ્રયાસ કરી શકો છો.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'પ્રોમો કોડ હજુ સુધી સબ્સ્ક્રિપ્શન્સ માટે સમર્થિત નથી.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'નિકાસ ડાઉનલોડ કરી શકાયું નથી. ફરી પ્રયાસ કરો.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'મૂળ અહેવાલો અથવા પરીક્ષણ પરિણામો પસંદ કરો.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'નિકાસની વિનંતી કરી. તાજું કરવા માટે \"સ્ટેટસ તપાસો\" પર ટૅપ કરો.';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'નિકાસની વિનંતી કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'નિકાસ તૈયાર છે. ડાઉનલોડ URL ઉપલબ્ધ છે.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'નિકાસ સ્થિતિ તપાસવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'એકાઉન્ટ બંધ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiPrepareExport => 'નિકાસ તૈયાર કરો';

  @override
  String get uiSaveExport => 'નિકાસ બચાવો';

  @override
  String get uiPrepareExportAgain => 'ફરીથી નિકાસ તૈયાર કરો';

  @override
  String get uiAllDates => 'બધી તારીખો';

  @override
  String get uiPreparingAccountDetails => 'ખાતાની વિગતો તૈયાર કરી રહ્યાં છીએ';

  @override
  String get uiFamilyMemberProfiles => 'કૌટુંબિક સભ્ય પ્રોફાઇલ્સ';

  @override
  String get uiUploadedReports => 'અપલોડ કરેલા અહેવાલો';

  @override
  String get uiDownloadReady => 'ડાઉનલોડ તૈયાર';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'આ ઉપકરણ પર સક્ષમ કરેલ સૂચનાઓની જાણ કરો';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'ઉપકરણ સેટિંગ્સ ખોલી. Doclyzer માટે સૂચનાઓને મંજૂરી આપો, પછી અહીં પાછા ફરો.';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'સૂચનાઓ હજુ પણ બંધ છે. તેમને ઉપકરણ સેટિંગ્સમાં રિપોર્ટ અપડેટ્સ પ્રાપ્ત કરવાની મંજૂરી આપો.';

  @override
  String get uiPreferencesSaved => 'પસંદગીઓ સાચવી';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'તમારી એકાઉન્ટ પસંદગી સાચવવામાં આવી હતી, પરંતુ આ ઉપકરણએ માર્કેટિંગ પુશ માટે નોંધણી કરવાનું સમાપ્ત કર્યું નથી. આ ઉપકરણ પર માર્કેટિંગ અવરોધિત રહે છે; સૂચના પરવાનગી તપાસો અને ફરીથી સાચવવાનો પ્રયાસ કરો.';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'તમારી એકાઉન્ટ પસંદગી સાચવવામાં આવી હતી. આ ઉપકરણ હજી સુધી તેની સ્થાનિક પસંદગીની પુષ્ટિ કરી શક્યું નથી, પરંતુ એકાઉન્ટ સ્તરે માર્કેટિંગ અવરોધિત રહે છે.';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'તમારી એકાઉન્ટ પસંદગી સાચવવામાં આવી હતી, પરંતુ આ ઉપકરણ માર્કેટિંગ પુશને સક્ષમ કરી શક્યું નથી. સૂચના પરવાનગી તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'સાચવવામાં ઘણો સમય લાગ્યો. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiReportReadyForReview => 'રિપોર્ટ સમીક્ષા માટે તૈયાર છે';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'જ્યારે તમારા પરિણામો તપાસવા માટે તૈયાર હોય ત્યારે જાણો.';

  @override
  String get uiUploadUpdates => 'અપડેટ્સ અપલોડ કરો';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'જો અપલોડ પર ધ્યાન આપવાની જરૂર હોય તો સંદેશ મેળવો.';

  @override
  String get uiSharedLinkReminders => 'શેર કરેલ લિંક રીમાઇન્ડર્સ';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'જ્યારે લિંકની સમયસીમા સમાપ્ત થવાની હોય ત્યારે સાંભળો.';

  @override
  String get uiSecurityAlerts => 'સુરક્ષા ચેતવણીઓ';

  @override
  String get uiRequiredForAccountSafety => 'ખાતાની સલામતી માટે જરૂરી છે.';

  @override
  String get uiComplianceNotices => 'પાલન સૂચનાઓ';

  @override
  String get uiRequiredAccountInformation => 'જરૂરી એકાઉન્ટ માહિતી.';

  @override
  String get uiMarketingPushNotifications => 'માર્કેટિંગ પુશ સૂચનાઓ';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ઑફર્સ અને જાહેરાતો. આ પસંદગીને સાચવવાથી તે આ ઉપકરણ પર પણ લાગુ થાય છે.';

  @override
  String get uiProductUpdates => 'ઉત્પાદન અપડેટ્સ';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'Doclyzer વિશે વૈકલ્પિક સમાચાર.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'સર્વર સાથે કનેક્ટ કરી શકાતું નથી. કૃપા કરીને તમારું ઇન્ટરનેટ અથવા API સર્વર તપાસો.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'જ્યારે તમારું એકાઉન્ટ સમીક્ષા હેઠળ હોય ત્યારે પ્રોફાઇલ અપડેટ્સ અસ્થાયી રૂપે અનુપલબ્ધ હોય છે.';

  @override
  String get uiUse100CharactersOrFewer => '100 કે તેથી ઓછા અક્ષરોનો ઉપયોગ કરો';

  @override
  String get uiAddProfile => 'પ્રોફાઇલ ઉમેરો';

  @override
  String get uiCreateProfile => 'પ્રોફાઇલ બનાવો';

  @override
  String get uiUpdateTheirDetails => 'તેમની વિગતો અપડેટ કરો';

  @override
  String get uiWhoIsThisProfileFor => 'આ પ્રોફાઇલ કોની છે?';

  @override
  String get uiNotSelected => 'પસંદ કરેલ નથી';

  @override
  String get uiEnterAReferralCode => 'રેફરલ કોડ દાખલ કરો.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'રેફરલ લાગુ. ઇમેઇલ ચકાસણી પછી બોનસ અનલૉક થાય છે.';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'રેફરલ લાગુ. બોનસ ક્રેડિટ તૈયાર છે.';

  @override
  String get uiApplyCode => 'કોડ લાગુ કરો';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'તમે તમારો પોતાનો રેફરલ કોડ લાગુ કરી શકતા નથી.';

  @override
  String get uiReferralCodeIsInvalid => 'રેફરલ કોડ અમાન્ય છે.';

  @override
  String get uiFailedToApplyReferralCode => 'રેફરલ કોડ લાગુ કરવામાં નિષ્ફળ.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'રેફરલ કોડ લાગુ કરવામાં નિષ્ફળ. કૃપા કરીને ફરી પ્રયાસ કરો.';

  @override
  String get uiThisDevice => 'આ ઉપકરણ';

  @override
  String get uiSignedInDevice => 'સાઇન ઇન કરેલ ઉપકરણ';

  @override
  String get uiUnknownDevice => 'અજ્ઞાત ઉપકરણ';

  @override
  String get uiRevokeAndLogOut => 'રદ કરો અને લૉગ આઉટ કરો';

  @override
  String get uiRevokeSessionca8440 => 'સત્ર રદબાતલ કરો';

  @override
  String get uiEnterYourCurrentPassword => 'તમારો વર્તમાન પાસવર્ડ દાખલ કરો';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'અપરકેસ, લોઅરકેસ, સંખ્યા અને વિશેષ અક્ષર સાથે ઓછામાં ઓછા 8 અક્ષરોનો ઉપયોગ કરો';

  @override
  String get uiChooseADifferentPassword => 'એક અલગ પાસવર્ડ પસંદ કરો';

  @override
  String get uiNewPasswordsDoNotMatch => 'નવા પાસવર્ડ મેળ ખાતા નથી';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'તમે બધી ઉપલબ્ધ અપલોડ ક્રેડિટ્સનો ઉપયોગ કર્યો છે. વધુ ઉમેરવા માટે પ્લાન અને ક્રેડિટ્સની મુલાકાત લો.';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'Doclyzer માટે સૂચનાઓ અક્ષમ છે. રિપોર્ટ-તૈયાર અને એકાઉન્ટ અપડેટ્સને મંજૂરી આપવા માટે ઉપકરણ સેટિંગ્સ ખોલો. જ્યાં સુધી તમે તેને પસંદ ન કરો ત્યાં સુધી માર્કેટિંગ બંધ રહે છે.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'આ ઉપકરણ પર રિપોર્ટ-તૈયાર અને એકાઉન્ટ અપડેટ્સ મેળવો. જ્યાં સુધી તમે તેને પસંદ ન કરો ત્યાં સુધી માર્કેટિંગ બંધ રહે છે.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'આ ઉપકરણ માટે સૂચનાઓ બંધ છે. રિપોર્ટ-તૈયાર અને એકાઉન્ટ અપડેટ્સ મેળવવા માટે સેટિંગ્સ ખોલો.';

  @override
  String get uiBlockedExpiredRevoked => 'અવરોધિત (સમાપ્ત / રદબાતલ)';

  @override
  String get uiFailedToLoadPolicy => 'નીતિ લોડ કરવામાં નિષ્ફળ';

  @override
  String get uiUploadPaused => 'અપલોડ થોભાવ્યું';

  @override
  String get uiSevenDays => '7 દિવસ';

  @override
  String get uiThirtyDays => '30 દિવસ';

  @override
  String get uiNinetyDays => '90 દિવસ';

  @override
  String get uiUploadingAClearReport => 'સ્પષ્ટ અહેવાલ અપલોડ કરી રહ્યા છીએ';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'પીડીએફ, ફોટા અને બહુવિધ પૃષ્ઠો';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'પીડીએફ પસંદ કરો અથવા દરેક પૃષ્ઠના સ્પષ્ટ ફોટા લો. સમગ્ર પૃષ્ઠને ફ્રેમમાં રાખો, ઝગઝગાટ ટાળો અને વિશ્લેષણ કરતા પહેલા પૃષ્ઠ ક્રમ તપાસો. તમે મૂળ સામે એક્સટ્રેક્ટેડ મૂલ્યોને સુધારી શકો છો.';

  @override
  String get uiCorrectingAResult => 'પરિણામ સુધારી રહ્યું છે';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'મૂળ વિરુદ્ધ મૂલ્યોની સમીક્ષા કરો';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'રિપોર્ટ ખોલો, દરેક એક્સટ્રેક્ટેડ ટેસ્ટની મૂળ વિરુદ્ધ સમીક્ષા કરો અને કોઈપણ મૂલ્ય, એકમ અથવા તારીખ જે ખોટી રીતે વાંચવામાં આવી હતી તેને સુધારો. તમે વલણો પર આધાર રાખતા પહેલા અપ્રમાણિત પરિણામો તપાસવા જોઈએ.';

  @override
  String get uiManagingFamilyRecords => 'કુટુંબના રેકોર્ડનું સંચાલન';

  @override
  String get uiProfilesAccessAndPermissions =>
      'પ્રોફાઇલ્સ, ઍક્સેસ અને પરવાનગીઓ';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'પ્રોફાઇલ બનાવવા અને સ્વિચ કરવા માટે કુટુંબનો ઉપયોગ કરો. રિપોર્ટ અપલોડ કરતા અથવા શેર કરતા પહેલા પસંદ કરેલ વ્યક્તિને તપાસો. તમે ઍક્સેસ કરવા માટે અધિકૃત છો તે જ રેકોર્ડ્સનું સંચાલન કરો.';

  @override
  String get uiSharingAndRevokingLinks => 'લિંક્સ શેર કરવી અને રદ કરવી';

  @override
  String get uiControlTheRecordsYouShare =>
      'તમે શેર કરો છો તે રેકોર્ડને નિયંત્રિત કરો';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'તમે શેર કરવા માંગો છો તે રિપોર્ટ્સ અથવા પરિણામો પસંદ કરો, એક્સપાયરી અને એક્સેસ કોડની સમીક્ષા કરો, પછી લિંક અને કોડ અલગથી મોકલો. જ્યારે ઍક્સેસની જરૂર ન હોય ત્યારે શેર કરેલી લિંક્સમાંથી સક્રિય લિંકને રદબાતલ કરો.';

  @override
  String get uiInformationYouProvide => 'તમે પ્રદાન કરો છો તે માહિતી';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'એકાઉન્ટ વિગતો અને કૌટુંબિક પ્રોફાઇલ ઓળખે છે કે તમે કોના રેકોર્ડનું સંચાલન કરો છો. અપલોડ કરેલા દસ્તાવેજોમાં આરોગ્યની સંવેદનશીલ માહિતી હોઈ શકે છે.';

  @override
  String get uiSharingControls => 'શેરિંગ નિયંત્રણો';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'દરેક લિંકની સામગ્રી, સમાપ્તિ અને ઍક્સેસ સેટિંગ્સની સમીક્ષા કરો. તમારા એકાઉન્ટ સેટિંગ્સમાંથી સક્રિય લિંક્સનું સંચાલન કરો.';

  @override
  String get uiExportAndAccountChoices => 'નિકાસ અને એકાઉન્ટ પસંદગીઓ';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'રેકોર્ડ્સ નિકાસ કરવા અથવા એકાઉન્ટ કાઢી નાખવાની વિનંતી શરૂ કરવા માટે સેટિંગ્સનો ઉપયોગ કરો. રીટેન્શન વિગતો સંપૂર્ણ નીતિમાં છે.';

  @override
  String get uiEducationalScope => 'શૈક્ષણિક અવકાશ';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'Doclyzer અહેવાલોનું આયોજન કરે છે અને સમય જતાં પરિણામો દર્શાવે છે. શૈક્ષણિક સ્પષ્ટતા એ તબીબી સલાહ અથવા નિદાન નથી.';

  @override
  String get uiReviewYourRecords => 'તમારા રેકોર્ડની સમીક્ષા કરો';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'મૂળ રિપોર્ટ સામે એક્સટ્રેક્ટેડ મૂલ્યો, એકમો અને તારીખો તપાસો. તમારા પરિણામો વિશે હેલ્થકેર પ્રોફેશનલને પૂછો.';

  @override
  String get uiManageAndShareResponsibly =>
      'મેનેજ કરો અને જવાબદારીપૂર્વક શેર કરો';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'તમે ઍક્સેસ કરવા માટે અધિકૃત છો તે જ રેકોર્ડનું સંચાલન કરો. શેર કરતા પહેલા પસંદ કરેલી માહિતી અને પ્રાપ્તકર્તાને તપાસો.';

  @override
  String get uiPrivacyPolicy7ceacd => 'ગોપનીયતા નીતિ';

  @override
  String get uiTermsOfUse8a069e => 'ઉપયોગની શરતો';

  @override
  String get uiOpenPrivacyControls => 'ગોપનીયતા નિયંત્રણો ખોલો';

  @override
  String get uiGetHelpWithTheApp => 'એપ્લિકેશન સાથે મદદ મેળવો';

  @override
  String get uiExportYourDataInAccountSettings =>
      'એકાઉન્ટ સેટિંગ્સમાં તમારો ડેટા નિકાસ કરો';

  @override
  String get uiYOURDATACHOICES => 'તમારો ડેટા અને પસંદગીઓ';

  @override
  String get uiUSINGDOCLYZER => 'ડોકલાઈઝરનો ઉપયોગ';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'તમે ડોક્લાઇઝરમાં રાખો છો તે માહિતી\nને સમજો.';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'એપ્લિકેશનની ભૂમિકાની સ્પષ્ટ સમજ\n.';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name માંથી $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · નવીનતમ $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'આ લાઇબ્રેરી શરૂ કરવા માટે $name માટે રિપોર્ટ અપલોડ કરો.';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP સરનામું: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'સાઇન ઇન કરેલ છે: $date';
  }

  @override
  String get uiUnknown => 'અજ્ઞાત';

  @override
  String uiResultsFor(String name) {
    return '$name માટે પરિણામો';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count લેબ પેરામીટર ટ્રૅક કર્યા';
  }

  @override
  String uiSampledDate(String date) {
    return 'નમૂના $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'સંગ્રહ તારીખ: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'લેબ શ્રેણી: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI આ શ્રેણીને $range તરીકે વાંચે છે. મુદ્રિત ટેક્સ્ટ: $printed. આ સરખામણી પર આધાર રાખતા પહેલા મૂળ રિપોર્ટ તપાસો.';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount તૈયાર';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count ક્રેડિટ્સ';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'આ એકાઉન્ટ પર રેફરલ કોડ પહેલેથી જ લાગુ કરવામાં આવ્યો છે.';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ઍપ લૉક ચાલુ કરતાં પહેલાં ડિવાઇસનો પાસકોડ સેટ કરો.';

  @override
  String get uiLanguagePreferenceNotSaved => 'ભાષા પસંદગી સાચવવામાં આવી ન હતી.';

  @override
  String get uiExportUnavailable => 'નિકાસ અનુપલબ્ધ';

  @override
  String get uiUnreadableImage => 'વાંચી ન શકાય તેવી છબી';

  @override
  String uiStatusWithValue(String status) {
    return 'સ્થિતિ: $status';
  }

  @override
  String get uiPending => 'બાકી છે';

  @override
  String get uiCompleted => 'પૂર્ણ થયું';

  @override
  String get uiFailed => 'નિષ્ફળ';

  @override
  String get uiInactive => 'નિષ્ક્રિય';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'તમારા રિપોર્ટ્સ અને પ્રોફાઇલ્સ રાખવા માટે $date પહેલાં પુનઃસ્થાપિત કરો.';
  }

  @override
  String get uiThirtyDayDeadline => '30 દિવસની સમયમર્યાદા';

  @override
  String uiWhatsAffected(String details) {
    return 'શું અસર થાય છે: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'છેલ્લે અપડેટ કર્યું: $time પર $date';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename વર્તમાન પ્રોફાઇલને બદલે $name હેઠળ દેખાશે.';
  }

  @override
  String get uiOneVerifiedResult => '1 ચકાસાયેલ પરિણામ સાચવ્યું.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count ચકાસાયેલ પરિણામો સાચવવામાં આવ્યા.';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'પ્રોફાઇલ સ્વિચ કરવામાં અસમર્થ. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'એકત્રિત: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'અપલોડ કરાયો: $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount દ્વારા વધારો';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount નો ઘટાડો';
  }

  @override
  String get uiPercentagePoints => 'ટકાવારી પોઈન્ટ';

  @override
  String uiTestValuesCount(String count) {
    return 'પરીક્ષણ મૂલ્યો ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'પ્રક્રિયા દરમિયાન AI દ્વારા ચકાસાયેલ મૂલ્ય. મૂળ OCR: $value. રિપોર્ટ સામે તેની પુષ્ટિ કરો.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return '$name માં પહેલેથી જ રિપોર્ટ કરો';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return 'રિપોર્ટ $name માં ઉમેરવામાં આવ્યો';
  }

  @override
  String uiAddedOn(String date) {
    return '$date ઉમેર્યું';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max રિપોર્ટના $current નો ઉપયોગ કરવો.';
  }

  @override
  String get uiNeedHelp => 'મદદ જોઈએ છે?';

  @override
  String get uiEnabled => 'સક્ષમ';

  @override
  String get uiEnable => 'સક્ષમ કરો';

  @override
  String get uiSubscribe => 'સબ્સ્ક્રાઇબ કરો';

  @override
  String get uiApplying => 'અરજી કરી રહ્યા છે';

  @override
  String get uiCheckStatus => 'સ્થિતિ તપાસો';

  @override
  String get uiEditProfile => 'પ્રોફાઇલમાં ફેરફાર કરો';

  @override
  String get uiSaveChanges => 'ફેરફારો સાચવો';

  @override
  String get uiOptional => 'વૈકલ્પિક';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ઓર્ડર $orderId સમાધાનની રાહ જોઈ રહ્યો છે. સ્થિતિ સ્પષ્ટ ન થાય ત્યાં સુધી ખરીદી થોભાવવામાં આવે છે.';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'માસિક યોજના - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'ક્રેડિટ પેક - $name';
  }

  @override
  String get uiUnreadable => 'વાંચી ન શકાય તેવું';

  @override
  String uiLatestValue(String value) {
    return 'નવીનતમ: $value';
  }

  @override
  String get uiEarlier => 'અગાઉ';

  @override
  String get uiLater => 'બાદમાં';

  @override
  String get uiViewed => 'જોયુ';

  @override
  String get uiBlocked => 'અવરોધિત';

  @override
  String get uiCapped => 'કેપ્ડ';

  @override
  String uiLastChange(String label) {
    return 'છેલ્લો ફેરફાર: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'છેલ્લો ફેરફાર: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'ગિફ્ટ વાઉચર લાગુ કર્યું. $credits ક્રેડિટ ઉમેરી.';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'મૂળ હજી સાચવી શકાયું નથી. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'રદબાતલ કરવામાં નિષ્ફળ: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'મારા ડોકલાઈઝર રેફરલ કોડ $code: $link નો ઉપયોગ કરો';
  }

  @override
  String get uiAMomentAgo => 'એક ક્ષણ પહેલા';

  @override
  String uiMinutesAgo(String count) {
    return '$count મિનિટ પહેલા';
  }

  @override
  String get uiOneHourAgo => '1 કલાક પહેલા';

  @override
  String uiHoursAgo(String count) {
    return '$count કલાક પહેલા';
  }

  @override
  String get uiToday => 'આજે';

  @override
  String get uiYesterday => 'ગઈકાલે';

  @override
  String get uiOneDayAgo => '1 દિવસ પહેલા';

  @override
  String uiDaysAgo(String count) {
    return '$count દિવસો પહેલા';
  }

  @override
  String get uiOneWeekAgo => '1 અઠવાડિયા પહેલા';

  @override
  String uiWeeksAgo(String count) {
    return '$count અઠવાડિયા પહેલા';
  }

  @override
  String get uiOneMonthAgo => '1 મહિના પહેલા';

  @override
  String uiMonthsAgo(String count) {
    return '$count મહિના પહેલા';
  }

  @override
  String get uiOneYearAgo => '1 વર્ષ પહેલા';

  @override
  String uiYearsAgo(String count) {
    return '$count વર્ષો પહેલા';
  }

  @override
  String get uiInOneDay => '1 દિવસમાં';

  @override
  String uiInDays(String count) {
    return '$count દિવસમાં';
  }

  @override
  String uiInMinutes(String count) {
    return '$count મિનિટમાં';
  }

  @override
  String get uiInOneHour => '1 કલાકમાં';

  @override
  String uiInHours(String count) {
    return '$count કલાકમાં';
  }

  @override
  String get uiMissingExtractedTestName =>
      'એક્સટ્રેક્ટેડ રિઝલ્ટમાંથી ટેસ્ટનું નામ ખૂટે છે.';

  @override
  String get uiMissingCapturedLabRange =>
      'આ પરીક્ષણ માટે કોઈ લેબ સંદર્ભ શ્રેણી કેપ્ચર કરવામાં આવી નથી.';

  @override
  String get uiNonNumericExtractedValue =>
      'કાઢવામાં આવેલ મૂલ્ય એ સાદી સંખ્યા નથી. તેને મૂળ અહેવાલમાં તપાસો.';

  @override
  String get uiLabFlagRangeConflict =>
      'લેબ ધ્વજ મુદ્રિત શ્રેણી સાથે વિરોધાભાસી છે. મૂળ અહેવાલ તપાસો.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'એક્સટ્રેક્ટેડ વેલ્યુ, પ્રિન્ટેડ રેન્જ અથવા લેબ ફ્લેગને મૂળ રિપોર્ટમાં તપાસવાની જરૂર છે.';

  @override
  String get uiInitialEntitlement => 'પ્રારંભિક હક';

  @override
  String get uiCreditPackPurchase => 'ક્રેડિટ પેક ખરીદી';

  @override
  String get uiSubscriptionUpgrade => 'સબ્સ્ક્રિપ્શન અપગ્રેડ';

  @override
  String get uiPlanDowngrade => 'ડાઉનગ્રેડ કરવાની યોજના';

  @override
  String get uiAdminAdjustment => 'એડમિન ગોઠવણ';

  @override
  String get uiSystemReconciliation => 'સિસ્ટમ સમાધાન';

  @override
  String get uiReferralInviteBonus => 'રેફરલ આમંત્રણ બોનસ';

  @override
  String get uiReferralAnalysisMilestone => 'રેફરલ વિશ્લેષણ સીમાચિહ્નરૂપ';

  @override
  String get uiReferralPurchaseMilestone => 'રેફરલ ખરીદી સીમાચિહ્નરૂપ';

  @override
  String get uiFreePromoCreditPack => 'મફત પ્રોમો ક્રેડિટ પેક';

  @override
  String get uiGiftVoucherRedeemed => 'ગિફ્ટ વાઉચર રિડીમ કર્યું';

  @override
  String get uiNotYetChanged => 'હજુ બદલાયો નથી';

  @override
  String get uiCannotReachServer =>
      'સર્વર સુધી પહોંચવામાં અસમર્થ. તમારું કનેક્શન તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiInvalidEmailOrPassword =>
      'અમાન્ય ઇમેઇલ અથવા પાસવર્ડ. તમારી વિગતો તપાસો અને ફરી પ્રયાસ કરો.';

  @override
  String get uiTooManyAuthAttempts =>
      'ઘણા બધા પ્રયત્નો. થોડીવાર રાહ જુઓ અને ફરી પ્રયાસ કરો.';

  @override
  String get uiEnterValidEmail => 'કૃપા કરીને માન્ય ઇમેઇલ સરનામું દાખલ કરો.';

  @override
  String get uiPasswordRequirements =>
      'પાસવર્ડ ઓછામાં ઓછો 8 અક્ષરનો હોવો જોઈએ અને તેમાં અપરકેસ, લોઅરકેસ, નંબર અને સ્પેશિયલ કેરેક્ટર શામેલ હોવા જોઈએ.';

  @override
  String get uiAccountWithEmailExists =>
      'આ ઇમેઇલ સાથેનું એકાઉન્ટ પહેલેથી જ અસ્તિત્વમાં છે. સાઇન ઇન કરો અથવા અલગ ઇમેઇલનો ઉપયોગ કરો.';

  @override
  String get uiUploadedStatus => 'અપલોડ કરેલ';

  @override
  String uiSupportAction(String action) {
    return 'ક્રિયા: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'સહસંબંધ ID: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'ક્લાયન્ટ એક્શન ID: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'ભૂલ કોડ: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'ભૂલ: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'તમારું સત્ર સમાપ્ત થયું. ફરીથી સાઇન ઇન કરો.';

  @override
  String get uiProfileLimitReached =>
      'તમારી યોજના પ્રોફાઇલ મર્યાદા પહોંચી ગઈ છે. વધુ ઉમેરવા માટે પ્લાન અને ક્રેડિટ્સની સમીક્ષા કરો.';

  @override
  String get uiCorrectionConflictReload =>
      'આ પરિણામ અન્યત્ર બદલાયું. રિપોર્ટને સુધારતા પહેલા તેને ફરીથી લોડ કરો.';

  @override
  String get uiSeePlanCreditsOptions =>
      'ઉપલબ્ધ વિકલ્પો માટે પ્લાન અને ક્રેડિટ્સ જુઓ.';

  @override
  String get uiShareLinkLimitHelp =>
      'તમે સક્રિય શેર-લિંક મર્યાદા સુધી પહોંચી ગયા છો.';

  @override
  String get uiScopedExportUnavailable =>
      'સ્કોપેડ નિકાસ અનુપલબ્ધ છે. પછીથી ફરી પ્રયાસ કરો.';

  @override
  String get uiRestorationUnavailable =>
      'પુનઃસ્થાપન અનુપલબ્ધ છે. પછીથી ફરી પ્રયાસ કરો.';

  @override
  String get uiExportRequestNotFound =>
      'નિકાસ વિનંતી મળી નથી. નવી નિકાસની વિનંતી કરો.';

  @override
  String get uiClosureConfirmationRequired =>
      'ચાલુ રાખવા માટે એકાઉન્ટ બંધ કરવાની પુષ્ટિ કરો.';

  @override
  String get uiCurrentPasswordIncorrect => 'વર્તમાન પાસવર્ડ ખોટો છે.';

  @override
  String get uiLaboratories => 'પ્રયોગશાળાઓ';

  @override
  String get uiUnlock => 'અનલોક કરો';
}
