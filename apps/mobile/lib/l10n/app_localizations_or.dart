// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oriya (`or`).
class AppLocalizationsOr extends AppLocalizations {
  AppLocalizationsOr([String locale = 'or']) : super(locale);

  @override
  String get trendLatestResult => 'ସଦ୍ୟତମ ଫଳାଫଳ';

  @override
  String get trendPreviousResult => 'ପୂର୍ବ ଫଳାଫଳ';

  @override
  String get trendSourceUnit => 'ଏହି ସୀମାର ମୂଳ ଏକକ';

  @override
  String get trendNoSavedResults =>
      'ଏହି ପରୀକ୍ଷା ପାଇଁ ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ସଞ୍ଚିତ ଫଳାଫଳ ନାହିଁ।';

  @override
  String get trendNoPlottableResults =>
      'ନମୁନା ସଂଗ୍ରହ ତାରିଖ ଥିବା ସଠିକ୍ ସଂଖ୍ୟାତ୍ମକ ଫଳାଫଳ ଚାର୍ଟରେ ଦେଖାଇ ହେଉନାହିଁ।';

  @override
  String get trendOneResultHelp =>
      'ଗୋଟିଏ ଫଳାଫଳ ସଞ୍ଚିତ ଅଛି। ପରିବର୍ତ୍ତନ ଦେଖିବାକୁ ଆଉ ଗୋଟିଏ ରିପୋର୍ଟ ଯୋଡ଼ନ୍ତୁ।';

  @override
  String get trendMultipleResultsHelp =>
      'ତାରିଖଗୁଡ଼ିକ ବିତିଥିବା ସମୟ ଅନୁସାରେ ଦେଖାଯାଇଛି। ମୂଲ୍ୟ ପାଇଁ ବିନ୍ଦୁରେ ଟ୍ୟାପ୍ କରନ୍ତୁ।';

  @override
  String trendUnplottedNote(int count) {
    return 'ନମୁନା ସଂଗ୍ରହ ତାରିଖ କିମ୍ବା ସଠିକ୍ ସଂଖ୍ୟାତ୍ମକ ମୂଲ୍ୟ ନଥିବାରୁ $countଟି ଫଳାଫଳ ଚାର୍ଟରେ ଦେଖାଯାଇନାହିଁ।';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$countଟି ଫଳାଫଳ ସହ $testName ପରିବର୍ତ୍ତନ ଚାର୍ଟ';
  }

  @override
  String get trendDateReview =>
      'ନମୁନା ସଂଗ୍ରହ ତାରିଖ ପୂର୍ବ ସୂଚନା ନିଷ୍କାସନରୁ ଆସିଛି। ମୂଳ ରିପୋର୍ଟରେ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get trendNotPlotted => 'ଚାର୍ଟରେ ଦେଖାଯାଇନାହିଁ';

  @override
  String get trendExactNumberUnavailable => 'ଫଳାଫଳଟି ସଠିକ୍ ସଂଖ୍ୟା ନୁହେଁ';

  @override
  String get preferredLanguage => 'ପସନ୍ଦର ଭାଷା';

  @override
  String get descriptionLanguage => 'ବିବରଣୀର ଭାଷା';

  @override
  String get languageHelp =>
      'ଆପ୍‌ର ଲେବେଲ୍ ଓ ରିପୋର୍ଟର ବ୍ୟାଖ୍ୟା ପାଇଁ ବ୍ୟବହୃତ ହୁଏ। ଆପଣ ଯେକୌଣସି ସମୟରେ ବ୍ୟାଖ୍ୟାର ଭାଷା ବଦଳାଇପାରିବେ।';

  @override
  String get languageSaveFailed =>
      'ଆପଣଙ୍କ ଭାଷା ପସନ୍ଦ ସେଭ୍ କରିହେଲା ନାହିଁ। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get translationLoading => 'ଅନୁବାଦିତ ବିବରଣୀ ପ୍ରସ୍ତୁତ କରାଯାଉଛି…';

  @override
  String get translationFailed =>
      'ଅନୁବାଦ ଉପଲବ୍ଧ ନାହିଁ। ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ କିମ୍ବା ଇଂରାଜୀ ବାଛନ୍ତୁ।';

  @override
  String get translationNote =>
      'ସେଭ୍ ହୋଇଥିବା ଇଂରାଜୀ ବ୍ୟାଖ୍ୟାରୁ AI ଦ୍ୱାରା ଅନୁବାଦିତ। ସଠିକ୍ ଫଳାଫଳ ପାଇଁ ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get sourceChanged =>
      'ରିପୋର୍ଟ ବଦଳିଛି। ସଦ୍ୟତମ ବ୍ୟାଖ୍ୟା ଦେଖିବାକୁ ଏହାକୁ ପୁଣି ଲୋଡ୍ କରନ୍ତୁ।';

  @override
  String get signupTitle => 'ଅଧିକ ସ୍ପଷ୍ଟ ବୁଝାମଣା\nଏଠାରୁ ଆରମ୍ଭ ହୁଏ।';

  @override
  String get signupIntro =>
      'ଆପଣଙ୍କ ରିପୋର୍ଟ ଓ ଫଳାଫଳ ଏକାଠି ରଖିବାକୁ ଏକ ଆକାଉଣ୍ଟ ଖୋଲନ୍ତୁ।';

  @override
  String get loginIntro =>
      'ଆପଣଙ୍କ ସ୍ୱାସ୍ଥ୍ୟ ରିପୋର୍ଟ ଦେଖିବା ଓ ବୁଝିବାକୁ ସାଇନ୍ ଇନ୍ କରନ୍ତୁ।';

  @override
  String get emailAddress => 'ଇମେଲ୍ ଠିକଣା';

  @override
  String get email => 'ଇମେଲ୍';

  @override
  String get password => 'ପାସୱାର୍ଡ';

  @override
  String get referralCode => 'ରେଫରାଲ୍ କୋଡ୍ (ଇଚ୍ଛାଧୀନ)';

  @override
  String get createAccount => 'ଆକାଉଣ୍ଟ ଖୋଲନ୍ତୁ';

  @override
  String get alreadyAccount => 'ପୂର୍ବରୁ ଆକାଉଣ୍ଟ ଅଛି କି? ';

  @override
  String get noAccount => 'ଆକାଉଣ୍ଟ ନାହିଁ କି? ';

  @override
  String get signIn => 'ସାଇନ୍ ଇନ୍ କରନ୍ତୁ';

  @override
  String get showPassword => 'ପାସୱାର୍ଡ ଦେଖାନ୍ତୁ';

  @override
  String get hidePassword => 'ପାସୱାର୍ଡ ଲୁଚାନ୍ତୁ';

  @override
  String get needHelp => 'ସହାୟତା ଦରକାର କି?';

  @override
  String get forgotPassword => 'ପାସୱାର୍ଡ ଭୁଲିଗଲେ କି?';

  @override
  String get invalidCredentialsInput => 'ଏକ ବୈଧ ଇମେଲ୍ ଠିକଣା ଓ ପାସୱାର୍ଡ ଦିଅନ୍ତୁ';

  @override
  String get signupFailed => 'ଆକାଉଣ୍ଟ ଖୋଲିହେଲା ନାହିଁ';

  @override
  String get loginFailed =>
      'ସାଇନ୍ ଇନ୍ କରିହେଲା ନାହିଁ। ଦୟାକରି ଆପଣଙ୍କ ଇଣ୍ଟରନେଟ୍ ସଂଯୋଗ ଯାଞ୍ଚ କରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get genericError => 'କିଛି ତ୍ରୁଟି ଘଟିଛି। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get profileUpdated => 'ପ୍ରୋଫାଇଲ୍ ଅପଡେଟ୍ ହୋଇଛି';

  @override
  String get changePhoto => 'ପ୍ରୋଫାଇଲ୍ ଫଟୋ ବଦଳାନ୍ତୁ';

  @override
  String get gallery => 'ଗ୍ୟାଲେରୀରୁ ବାଛନ୍ତୁ';

  @override
  String get camera => 'ଫଟୋ ଉଠାନ୍ତୁ';

  @override
  String get photoUpdated => 'ପ୍ରୋଫାଇଲ୍ ଫଟୋ ଅପଡେଟ୍ ହୋଇଛି';

  @override
  String get photoFailed =>
      'ଆପଣଙ୍କ ଫଟୋ ଅପଡେଟ୍ କରିହେଲା ନାହିଁ। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get yourAccount => 'ଆପଣଙ୍କ ଆକାଉଣ୍ଟ';

  @override
  String get profileLoading => 'ପ୍ରୋଫାଇଲ୍ ଲୋଡ୍ ହେଉଛି…';

  @override
  String get profileLoadAction => 'ଆପଣଙ୍କ ପ୍ରୋଫାଇଲ୍ ଲୋଡ୍ କରିବାକୁ ଟ୍ୟାପ୍ କରନ୍ତୁ';

  @override
  String get accountData => 'ଆକାଉଣ୍ଟ ଓ ତଥ୍ୟ';

  @override
  String get personalInformation => 'ବ୍ୟକ୍ତିଗତ ସୂଚନା';

  @override
  String get notificationPreferences => 'ବିଜ୍ଞପ୍ତି ସମ୍ବନ୍ଧୀୟ ପସନ୍ଦ';

  @override
  String get privacySecurity => 'ଗୋପନୀୟତା ଓ ସୁରକ୍ଷା';

  @override
  String get sharedLinks => 'ସେୟାର୍ କରାଯାଇଥିବା ଲିଙ୍କ୍';

  @override
  String get exportData => 'ଆପଣଙ୍କ ତଥ୍ୟ ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get additionalAccount => 'ଆକାଉଣ୍ଟର ଅତିରିକ୍ତ ସୂଚନା';

  @override
  String get additionalAccountHelp =>
      'ପରିବାର, ପ୍ଲାନ୍, ରେଫରାଲ୍, ସେସନ୍ ଓ ଦୃଶ୍ୟରୂପ';

  @override
  String get familyProfiles => 'ପରିବାରର ପ୍ରୋଫାଇଲ୍';

  @override
  String get manageProfiles => 'ପ୍ରୋଫାଇଲ୍ ବଦଳାନ୍ତୁ କିମ୍ବା ପରିଚାଳନା କରନ୍ତୁ';

  @override
  String get planCredits => 'ପ୍ଲାନ୍ ଓ କ୍ରେଡିଟ୍';

  @override
  String get viewPlanBalance => 'ଆପଣଙ୍କ ପ୍ଲାନ୍ ଓ ଅବଶିଷ୍ଟ କ୍ରେଡିଟ୍ ଦେଖନ୍ତୁ';

  @override
  String get balanceLoading => 'ଅବଶିଷ୍ଟ କ୍ରେଡିଟ୍ ଲୋଡ୍ ହେଉଛି…';

  @override
  String get referFriends => 'ବନ୍ଧୁମାନଙ୍କୁ ଆମନ୍ତ୍ରଣ କରନ୍ତୁ';

  @override
  String get referralRewards => 'ଆମନ୍ତ୍ରଣ ଓ ରେଫରାଲ୍ ପୁରସ୍କାର';

  @override
  String get activeSessions => 'ସକ୍ରିୟ ସେସନ୍';

  @override
  String get appearance => 'ଦୃଶ୍ୟରୂପ';

  @override
  String get system => 'ସିଷ୍ଟମ୍ ଅନୁଯାୟୀ';

  @override
  String get light => 'ହାଲୁକା';

  @override
  String get dark => 'ଗାଢ଼';

  @override
  String get helpSupport => 'ସହାୟତା ଓ ସମର୍ଥନ';

  @override
  String get aboutDoclyzer => 'Doclyzer ବିଷୟରେ';

  @override
  String get aboutCopy =>
      'ବ୍ୟକ୍ତି ଅନୁଯାୟୀ ରିପୋର୍ଟଗୁଡ଼ିକୁ ସଜାଇ ରଖନ୍ତୁ ଏବଂ ବାହାର କରାଯାଇଥିବା ଫଳାଫଳକୁ ମୂଳ ରିପୋର୍ଟ ସହ ମିଳାଇ ସମୀକ୍ଷା କରନ୍ତୁ।';

  @override
  String get logOut => 'ଲଗ୍ ଆଉଟ୍ କରନ୍ତୁ';

  @override
  String get profile => 'ପ୍ରୋଫାଇଲ୍';

  @override
  String get saveChanges => 'ପରିବର୍ତ୍ତନ ସେଭ୍ କରନ୍ତୁ';

  @override
  String get accountRestricted => 'ଆକାଉଣ୍ଟରେ ପ୍ରତିବନ୍ଧକ ଲାଗିଛି';

  @override
  String get photoUploading => 'ଫଟୋ ଅପଲୋଡ୍ ହେଉଛି…';

  @override
  String get changePhotoShort => 'ଫଟୋ ବଦଳାନ୍ତୁ';

  @override
  String get accountDetails => 'ଆକାଉଣ୍ଟ ବିବରଣୀ';

  @override
  String get emailHelp =>
      'ଆକାଉଣ୍ଟରେ ପ୍ରବେଶ ପାଇଁ ବ୍ୟବହୃତ ହୁଏ। ଏହା ବଦଳାଇବାକୁ ସହାୟତା ଦଳ ସହ ଯୋଗାଯୋଗ କରନ୍ତୁ।';

  @override
  String get accountName => 'ଆକାଉଣ୍ଟ ନାମ';

  @override
  String get belowLabRange => 'ଏହି ଲ୍ୟାବ୍‌ର ସନ୍ଦର୍ଭ ସୀମାଠାରୁ କମ୍';

  @override
  String get withinLabRange => 'ଏହି ଲ୍ୟାବ୍‌ର ସନ୍ଦର୍ଭ ସୀମା ମଧ୍ୟରେ';

  @override
  String get aboveLabRange => 'ଏହି ଲ୍ୟାବ୍‌ର ସନ୍ଦର୍ଭ ସୀମାଠାରୁ ଅଧିକ';

  @override
  String get cannotCompare => 'ଲ୍ୟାବ୍‌ର ସୀମା ସହ ତୁଳନା କରିହେଉ ନାହିଁ';

  @override
  String get understandResult => 'ଏହି ଫଳାଫଳ ବୁଝନ୍ତୁ';

  @override
  String get yourResult => 'ଆପଣଙ୍କ ଫଳାଫଳ';

  @override
  String get labReferenceRange => 'ଲ୍ୟାବ୍‌ର ସନ୍ଦର୍ଭ ସୀମା';

  @override
  String get resultUnavailable => 'ଏହି ଫଳାଫଳରେ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get sampleDate => 'ନମୁନା ସଂଗ୍ରହ ତାରିଖ';

  @override
  String get resultHistory => 'ଫଳାଫଳର ଇତିହାସ';

  @override
  String get originalReport => 'ମୂଳ ରିପୋର୍ଟ';

  @override
  String get reviewValue => 'ମାନ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get understandYourResult => 'ଆପଣଙ୍କ ଫଳାଫଳ ବୁଝନ୍ତୁ';

  @override
  String get educationalContext =>
      'ଏହି ଫଳାଫଳ ବିଷୟରେ ଆଲୋଚନା କରିବାରେ ସାହାଯ୍ୟ କରିବା ପାଇଁ ଶିକ୍ଷାମୂଳକ ସୂଚନା।';

  @override
  String get explanationUnavailable => 'ବ୍ୟାଖ୍ୟା ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get explanationFailed => 'ଏବେ ବ୍ୟାଖ୍ୟା ଲୋଡ୍ କରିହେଲା ନାହିଁ।';

  @override
  String get checkOriginal => 'ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get tryAgain => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get aiGuidance => 'AI ଦ୍ୱାରା ପ୍ରସ୍ତୁତ ମାର୍ଗଦର୍ଶନ';

  @override
  String get understandingResult => 'ଏହି ଫଳାଫଳକୁ ବୁଝିବା';

  @override
  String get possibleMeaning => 'ଏହାର କ’ଣ ଅର୍ଥ ହୋଇପାରେ';

  @override
  String get whatTestMeasures => 'ଏହି ପରୀକ୍ଷା କ’ଣ ମାପେ';

  @override
  String get suggestedNextStep => 'ପରାମର୍ଶିତ ପରବର୍ତ୍ତୀ ପଦକ୍ଷେପ';

  @override
  String get resultLimitations => 'ଏହି ଫଳାଫଳ ଆପଣଙ୍କୁ କ’ଣ କହିପାରିବ ନାହିଁ';

  @override
  String get oneResultLimit =>
      'କେବଳ ଗୋଟିଏ ଫଳାଫଳରୁ କୌଣସି ରୋଗ ନିର୍ଣ୍ଣୟ କରିହେବ ନାହିଁ କିମ୍ବା ଲକ୍ଷଣର କାରଣ ଜାଣିହେବ ନାହିଁ।';

  @override
  String get detailsToCheck => 'ଯାଞ୍ଚ କରିବାକୁ ଥିବା ବିବରଣୀ';

  @override
  String get lifestyleFactors => 'ଆଲୋଚନା କରିବାକୁ ଥିବା ଜୀବନଶୈଳୀ ସମ୍ବନ୍ଧୀୟ ବିଷୟ';

  @override
  String get insightContext =>
      'ଏହି ମାନ ଆପଣଙ୍କ ରିପୋର୍ଟରୁ ବାହାର କରାଯାଇଛି। ନାମ, ମାନ, ଏକକ କିମ୍ବା ସୀମା ଭୁଲ୍ ଲାଗିଲେ ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ। AI ବ୍ୟାଖ୍ୟାଗୁଡ଼ିକ ଶିକ୍ଷାମୂଳକ ଏବଂ ଆପଣଙ୍କୁ କେଉଁ ଚିକିତ୍ସା ଦରକାର ତାହା କହିପାରିବ ନାହିଁ।';

  @override
  String get yourProfile => 'ଆପଣଙ୍କ ପ୍ରୋଫାଇଲ୍';

  @override
  String get cancel => 'ବାତିଲ୍ କରନ୍ତୁ';

  @override
  String get delete => 'ଡିଲିଟ୍ କରନ୍ତୁ';

  @override
  String get moveReport => 'ରିପୋର୍ଟ ସ୍ଥାନାନ୍ତର କରନ୍ତୁ';

  @override
  String get gotIt => 'ବୁଝିଗଲି';

  @override
  String get reportDetails => 'ରିପୋର୍ଟ ବିବରଣୀ';

  @override
  String get shareReport => 'ରିପୋର୍ଟ ସେୟାର୍ କରନ୍ତୁ';

  @override
  String get moreReportActions => 'ରିପୋର୍ଟ ପାଇଁ ଅଧିକ କାର୍ଯ୍ୟ';

  @override
  String get attemptHistory => 'ପ୍ରୟାସର ଇତିହାସ';

  @override
  String get compareReports => 'ରିପୋର୍ଟଗୁଡ଼ିକ ତୁଳନା କରନ୍ତୁ';

  @override
  String get readParsedReport => 'ପଢ଼ିବା ପାଇଁ ସଜାଯାଇଥିବା ରିପୋର୍ଟ ପଢ଼ନ୍ତୁ';

  @override
  String get moveRecycle => 'ରିସାଇକଲ୍ ବିନ୍‌କୁ ପଠାନ୍ତୁ';

  @override
  String get retry => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get reportSummary => 'ରିପୋର୍ଟ ସାରାଂଶ';

  @override
  String get updateSummary => 'ସାରାଂଶ ଅପଡେଟ୍ କରନ୍ତୁ';

  @override
  String get summaryLoading => 'ଆପଣଙ୍କ ଫଳାଫଳକୁ ସରଳ ଭାଷାରେ ପ୍ରସ୍ତୁତ କରାଯାଉଛି…';

  @override
  String get checkSummary => 'ସାରାଂଶ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get summaryFailed =>
      'ସାରାଂଶ ପ୍ରସ୍ତୁତ କରିହେଲା ନାହିଁ। ଆପଣ ପୁଣି ଚେଷ୍ଟା କରିପାରିବେ।';

  @override
  String get summaryPlaceholder =>
      'ମୁଖ୍ୟ ଫଳାଫଳର ସରଳ ଭାଷାରେ ବ୍ୟାଖ୍ୟା ଏଠାରେ ଦେଖାଯିବ।';

  @override
  String get retrySummary => 'ସାରାଂଶ ପାଇଁ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get generateSummary => 'ସାରାଂଶ ପ୍ରସ୍ତୁତ କରନ୍ତୁ';

  @override
  String get loadingResults => 'ରିପୋର୍ଟର ଫଳାଫଳ ଲୋଡ୍ ହେଉଛି…';

  @override
  String get somethingWrong => 'କିଛି ତ୍ରୁଟି ଘଟିଛି';

  @override
  String get viewTrends => 'ସମୟ ସହ ପରିବର୍ତ୍ତନ ଦେଖନ୍ତୁ';

  @override
  String get originalFile => 'ମୂଳ ଫାଇଲ୍';

  @override
  String get testValues => 'ପରୀକ୍ଷାର ମାନ';

  @override
  String get summary => 'ସାରାଂଶ';

  @override
  String get checkStatus => 'ସ୍ଥିତି ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get viewOriginal => 'ମୂଳ ଦେଖନ୍ତୁ';

  @override
  String get verifiedResults => 'ଯାଞ୍ଚ ହୋଇଥିବା ଫଳାଫଳ';

  @override
  String get resultTapHelp =>
      'ପରୀକ୍ଷା କ’ଣ ମାପେ ତାହା ବୁଝିବାକୁ ଏକ ଫଳାଫଳରେ ଟ୍ୟାପ୍ କରନ୍ତୁ।';

  @override
  String get reviewResults => 'ଚିହ୍ନଟ ହୋଇଥିବା ଫଳାଫଳ ସମୀକ୍ଷା କରନ୍ତୁ';

  @override
  String get keepFile => 'ତଥାପି ଫାଇଲ୍ ରଖନ୍ତୁ';

  @override
  String get patientDetails => 'ରୋଗୀଙ୍କ ବିବରଣୀ';

  @override
  String get name => 'ନାମ';

  @override
  String get age => 'ବୟସ';

  @override
  String get gender => 'ଲିଙ୍ଗ';

  @override
  String get bookingId => 'ବୁକିଂ ID';

  @override
  String get sampleCollection => 'ନମୁନା ସଂଗ୍ରହ';

  @override
  String get labDetails => 'ଲ୍ୟାବ୍ ବିବରଣୀ';

  @override
  String get labName => 'ଲ୍ୟାବ୍‌ର ନାମ';

  @override
  String get address => 'ଠିକଣା';

  @override
  String get phone => 'ଫୋନ୍';

  @override
  String get location => 'ସ୍ଥାନ';

  @override
  String get belowRange => 'ସୀମାଠାରୁ କମ୍';

  @override
  String get aboveRange => 'ସୀମାଠାରୁ ଅଧିକ';

  @override
  String get withinRange => 'ଉଲ୍ଲେଖିତ ସୀମା ମଧ୍ୟରେ';

  @override
  String get rangeUnclear => 'ସୀମା ଅସ୍ପଷ୍ଟ';

  @override
  String get understandResultAction => 'ଏହି ଫଳାଫଳ ବୁଝନ୍ତୁ  →';

  @override
  String get parsedReport => 'ପଢ଼ିବା ପାଇଁ ସଜାଯାଇଥିବା ରିପୋର୍ଟ';

  @override
  String get reports => 'ରିପୋର୍ଟ';

  @override
  String get trends => 'ସମୟ ସହ ପରିବର୍ତ୍ତନ';

  @override
  String get openingPage => 'ପ୍ରାରମ୍ଭିକ ପୃଷ୍ଠା';

  @override
  String get home => 'ମୁଖ୍ୟ ପୃଷ୍ଠା';

  @override
  String get family => 'ପରିବାର';

  @override
  String get switchProfile => 'ପ୍ରୋଫାଇଲ୍ ବଦଳାନ୍ତୁ';

  @override
  String get currentProfile => 'ବର୍ତ୍ତମାନର ପ୍ରୋଫାଇଲ୍';

  @override
  String get viewProfile => 'ଏହି ପ୍ରୋଫାଇଲ୍ ଦେଖନ୍ତୁ';

  @override
  String get manageFamily => 'ପରିବାର ପରିଚାଳନା କରନ୍ତୁ';

  @override
  String get chooseProfile => 'ଏକ ପ୍ରୋଫାଇଲ୍ ବାଛନ୍ତୁ';

  @override
  String get notifications => 'ବିଜ୍ଞପ୍ତି';

  @override
  String get homeTitle => 'ଟିକିଏ ସ୍ପଷ୍ଟତା।\nସବୁକିଛି ଗୋଟିଏ ସ୍ଥାନରେ।';

  @override
  String get nextReportTitle =>
      'ଆପଣଙ୍କ ପରବର୍ତ୍ତୀ ରିପୋର୍ଟ,\nଆପଣ ପ୍ରସ୍ତୁତ ହେଲେ ଏହା ବି ପ୍ରସ୍ତୁତ।';

  @override
  String get homeSubtitle => 'PDF, ଫଟୋ ଓ ପରିବାରର ରେକର୍ଡ।';

  @override
  String get uploadReport => 'ରିପୋର୍ଟ ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get recentReport => 'ସାମ୍ପ୍ରତିକ ରିପୋର୍ଟ';

  @override
  String get viewAll => 'ସବୁ ଦେଖନ୍ତୁ';

  @override
  String get reportsUnavailable =>
      'ରିପୋର୍ଟ ଉପଲବ୍ଧ ନାହିଁ। ଇଣ୍ଟରନେଟ୍ ସଂଯୋଗ ହେଲେ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get emptyHomeTitle => 'ଆପଣଙ୍କ କାହାଣୀ ଏଠାରୁ ଆରମ୍ଭ ହୁଏ';

  @override
  String get emptyHomeHelp =>
      'ଆପଣଙ୍କ ରେକର୍ଡର ଏକ ସ୍ପଷ୍ଟ ଇତିହାସ ଆରମ୍ଭ କରିବାକୁ ପ୍ରଥମ ରିପୋର୍ଟ ଅପଲୋଡ୍ କରନ୍ତୁ।';

  @override
  String get uploadFirstReport => 'ଆପଣଙ୍କ ପ୍ରଥମ ରିପୋର୍ଟ ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get latestResults => 'ସଦ୍ୟତମ ଫଳାଫଳ';

  @override
  String get allTrends => 'ସମୟ ସହ ସବୁ ପରିବର୍ତ୍ତନ';

  @override
  String get reviewedResultsHelp =>
      'ସମୀକ୍ଷା ହୋଇଥିବା ଫଳାଫଳ ଉପଲବ୍ଧ ହେଲେ ଏଠାରେ ଦେଖାଯିବ।';

  @override
  String get searchTests => 'ପରୀକ୍ଷା ଖୋଜନ୍ତୁ';

  @override
  String get noHealthData =>
      'ଏପର୍ଯ୍ୟନ୍ତ ସ୍ୱାସ୍ଥ୍ୟ ତଥ୍ୟ ନାହିଁ। ଆପଣଙ୍କ ସ୍ୱାସ୍ଥ୍ୟ ଇତିହାସ ଦେଖିବାକୁ ଏକ ରିପୋର୍ଟ ଅପଲୋଡ୍ କରନ୍ତୁ।';

  @override
  String get noTestsFound => 'କୌଣସି ପରୀକ୍ଷା ମିଳିଲା ନାହିଁ';

  @override
  String get shorterTestName => 'ପରୀକ୍ଷାର ନାମକୁ ଅଧିକ ଛୋଟ କରି ଖୋଜନ୍ତୁ।';

  @override
  String get clearSearch => 'ଖୋଜିବା ପାଇଁ ଲେଖିଥିବା ପାଠ୍ୟ ହଟାନ୍ତୁ';

  @override
  String get unitUnavailable => 'ଏକକ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uploadingReport => 'ରିପୋର୍ଟ ଅପଲୋଡ୍ ହେଉଛି…';

  @override
  String get organizingReport => 'ଆପଣଙ୍କ ରିପୋର୍ଟ ସଜାଯାଉଛି…';

  @override
  String get uploadAReport => 'ଏକ ରିପୋର୍ଟ ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get uploadHelp =>
      'ଏକ PDF କିମ୍ବା ସ୍ପଷ୍ଟ ଫଟୋ ବାଛନ୍ତୁ। ସେଭ୍ କରିବା ପୂର୍ବରୁ ଆପଣ ବିବରଣୀ ଯାଞ୍ଚ କରିପାରିବେ।';

  @override
  String get chooseSource => 'ଏକ ଉତ୍ସ ବାଛନ୍ତୁ';

  @override
  String get uploadPdfImage => 'PDF କିମ୍ବା ଛବି ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get chooseReportFiles => 'ଆପଣଙ୍କ ଫାଇଲ୍‌ରୁ ଏକ ରିପୋର୍ଟ ବାଛନ୍ତୁ';

  @override
  String get selectReportPages => 'ରିପୋର୍ଟର ଗୋଟିଏ କିମ୍ବା ଅଧିକ ପୃଷ୍ଠା ବାଛନ୍ତୁ';

  @override
  String get capturePage => 'ପୂରା ପୃଷ୍ଠାର ଫଟୋ ଉଠାନ୍ତୁ';

  @override
  String get supportedFormats => 'ସମର୍ଥିତ ଫର୍ମାଟ୍: PDF, JPG, PNG';

  @override
  String get confirmFile =>
      'ଆପଣ ଯୋଡ଼ିବାକୁ ଚାହୁଁଥିବା ଫାଇଲ୍ ଏହା ହିଁ ବୋଲି ନିଶ୍ଚିତ କରନ୍ତୁ।';

  @override
  String get addReport => 'ରିପୋର୍ଟ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get chooseDifferentFile => 'ଅନ୍ୟ ଏକ ଫାଇଲ୍ ବାଛନ୍ତୁ';

  @override
  String get uploadWait => 'ଏଥିପାଇଁ କିଛି ସମୟ ଲାଗିପାରେ। ଦୟାକରି ଆପ୍ ଖୋଲା ରଖନ୍ତୁ।';

  @override
  String get reportNeedsAttention => 'ରିପୋର୍ଟ ପ୍ରତି ଧ୍ୟାନ ଦେବା ଆବଶ୍ୟକ';

  @override
  String get verifyBeforeSaving =>
      'ଚିହ୍ନଟ ହୋଇଥିବା ଫଳାଫଳ ସେଭ୍ କରିବା ପୂର୍ବରୁ ମୂଳ ରିପୋର୍ଟ ସହ ମିଳାଇ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get viewVerifiedResults => 'ଯାଞ୍ଚ ହୋଇଥିବା ଫଳାଫଳ ଦେଖନ୍ତୁ';

  @override
  String get viewOriginalReport => 'ମୂଳ ରିପୋର୍ଟ ଦେଖନ୍ତୁ';

  @override
  String get viewReportStatus => 'ରିପୋର୍ଟର ସ୍ଥିତି ଦେଖନ୍ତୁ';

  @override
  String get viewResults => 'ଫଳାଫଳ ଦେଖନ୍ତୁ';

  @override
  String get viewOriginalFile => 'ମୂଳ ଫାଇଲ୍ ଦେଖନ୍ତୁ';

  @override
  String get retryExtraction => 'ତଥ୍ୟ ବାହାର କରିବାକୁ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get done => 'ସମାପ୍ତ';

  @override
  String get duplicateReport =>
      'ଏହି ରିପୋର୍ଟ ପୂର୍ବରୁ ଥିବା ରିପୋର୍ଟର ନକଲ ପରି ଲାଗୁଛି';

  @override
  String get duplicateHelp =>
      'ଏହି ଫାଇଲ୍ ପୂର୍ବରୁ ଆପଣଙ୍କ ରିପୋର୍ଟଗୁଡ଼ିକ ମଧ୍ୟରେ ଥାଇପାରେ।';

  @override
  String get keepExisting => 'ପୂର୍ବରୁ ଥିବାଟି ରଖନ୍ତୁ';

  @override
  String get processAgain => 'PDF ପୁଣି ପ୍ରକ୍ରିୟାକରଣ କରନ୍ତୁ';

  @override
  String get uploadNewCopy => 'ନୂଆ ପ୍ରତିଲିପି ଭାବେ ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get reportLimitReached => 'ରିପୋର୍ଟ ସଂଖ୍ୟାର ସୀମାରେ ପହଞ୍ଚିଛନ୍ତି';

  @override
  String get reportLimitHelp => 'ଆପଣ ରିପୋର୍ଟ ସଂଖ୍ୟାର ସୀମାରେ ପହଞ୍ଚିଛନ୍ତି।';

  @override
  String get upgrade => 'ଅପଗ୍ରେଡ୍ କରନ୍ତୁ';

  @override
  String get back => 'ପଛକୁ';

  @override
  String get uploadFailedTitle => 'ରିପୋର୍ଟ ଅପଲୋଡ୍ କରିହେଲା ନାହିଁ';

  @override
  String get uploadFailed => 'ଅପଲୋଡ୍ ବିଫଳ ହୋଇଛି';

  @override
  String get retrySameFile => 'ସେହି ଫାଇଲ୍ ପାଇଁ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get chooseAnotherFile => 'ଅନ୍ୟ ଏକ ଫାଇଲ୍ ବାଛନ୍ତୁ';

  @override
  String get aiDisclaimer =>
      'Doclyzer ଆପଣଙ୍କ ସ୍ୱାସ୍ଥ୍ୟ ରିପୋର୍ଟ ସଜାଇ ରଖିବାରେ ଓ ଭଲ ଭାବେ ବୁଝିବାରେ ସାହାଯ୍ୟ କରେ। ଦିଆଯାଇଥିବା ସୂଚନା କେବଳ ଶିକ୍ଷାମୂଳକ ଉଦ୍ଦେଶ୍ୟ ପାଇଁ ଏବଂ ଏହା ଡାକ୍ତରୀ ପରାମର୍ଶ, ରୋଗ ନିର୍ଣ୍ଣୟ କିମ୍ବା ଚିକିତ୍ସା ନୁହେଁ। ଡାକ୍ତରୀ ମାର୍ଗଦର୍ଶନ ପାଇଁ ସର୍ବଦା ଜଣେ ଯୋଗ୍ୟ ସ୍ୱାସ୍ଥ୍ୟସେବା ପେସାଦାରଙ୍କ ପରାମର୍ଶ ନିଅନ୍ତୁ।';

  @override
  String collectedOn(String date) {
    return 'ସଂଗ୍ରହ ତାରିଖ $date';
  }

  @override
  String uploadedOn(String date) {
    return 'ଅପଲୋଡ୍ ତାରିଖ $date';
  }

  @override
  String labRangeValue(String range) {
    return 'ଲ୍ୟାବ୍‌ର ସୀମା $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits କ୍ରେଡିଟ୍';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ରିପୋର୍ଟ',
      one: '1 ରିପୋର୍ଟ',
      zero: 'କୌଣସି ରିପୋର୍ଟ ନାହିଁ',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'ରିପୋର୍ଟ ଲୋଡ୍ ହେବାରେ ଆଶାଠାରୁ ଅଧିକ ସମୟ ଲାଗୁଛି। ଆପଣଙ୍କ ଇଣ୍ଟରନେଟ୍ ସଂଯୋଗ ଯାଞ୍ଚ କରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get summaryUpdateFailed =>
      'ଏବେ ସାରାଂଶ ଅପଡେଟ୍ କରିହେଲା ନାହିଁ। ସେଭ୍ ହୋଇଥିବା ସାରାଂଶ ଏବେ ମଧ୍ୟ ଉପଲବ୍ଧ ଅଛି।';

  @override
  String get summaryCreateFailed =>
      'ଏବେ ସାରାଂଶ ପ୍ରସ୍ତୁତ କରିହେଲା ନାହିଁ। ଆପଣଙ୍କ ଫଳାଫଳ ଏବେ ମଧ୍ୟ ତଳେ ଉପଲବ୍ଧ ଅଛି।';

  @override
  String get reassignFailed =>
      'ରିପୋର୍ଟ ଅନ୍ୟ ପ୍ରୋଫାଇଲ୍‌କୁ ସ୍ଥାନାନ୍ତର କରିହେଲା ନାହିଁ। ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get confirmRecycle => 'ରିସାଇକଲ୍ ବିନ୍‌କୁ ପଠାଇବେ କି?';

  @override
  String get recycleHelp =>
      'ଆପଣ 30 ଦିନ ପର୍ଯ୍ୟନ୍ତ ରିପୋର୍ଟ > ରିସାଇକଲ୍ ବିନ୍‌ରୁ ଏହି ରିପୋର୍ଟ ପୁନରୁଦ୍ଧାର କରିପାରିବେ। ତା’ପରେ ଏହା ସ୍ଥାୟୀ ଭାବେ ଡିଲିଟ୍ ହୋଇଯିବ।';

  @override
  String get reportRecycled => 'ରିପୋର୍ଟ ରିସାଇକଲ୍ ବିନ୍‌କୁ ପଠାଯାଇଛି';

  @override
  String get reportDeleteFailed =>
      'ରିପୋର୍ଟ ଡିଲିଟ୍ କରିହେଲା ନାହିଁ। ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get addProfileBeforeMove =>
      'ଏହି ରିପୋର୍ଟ ସ୍ଥାନାନ୍ତର କରିବା ପୂର୍ବରୁ ପରିବାରର ଆଉ ଏକ ପ୍ରୋଫାଇଲ୍ ଯୋଡ଼ନ୍ତୁ।';

  @override
  String get moveReportHelp =>
      'ଏହି ରିପୋର୍ଟ ଭୁଲ୍ ପ୍ରୋଫାଇଲ୍‌ରେ ଯୋଡ଼ାଯାଇଥିଲେ ପରିବାରର ଅନ୍ୟ ଜଣେ ସଦସ୍ୟଙ୍କୁ ବାଛନ୍ତୁ।';

  @override
  String get confirmMoveReport => 'ଏହି ରିପୋର୍ଟ ସ୍ଥାନାନ୍ତର କରିବେ କି?';

  @override
  String get aboutSampleDates => 'ନମୁନା ସଂଗ୍ରହ ତାରିଖ ବିଷୟରେ';

  @override
  String get multipleDatesHelp =>
      'ଏହି ରିପୋର୍ଟରେ ଏକାଧିକ ନମୁନା ସଂଗ୍ରହ ତାରିଖର ଫଳାଫଳ ଅଛି। ଏକ ଫଳାଫଳ ଖୋଲି ତାହାର ତାରିଖ ମୂଳ ରିପୋର୍ଟ ସହ ମିଳାଇ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get missingDateHelp =>
      'ନମୁନା ନିଆଯାଇଥିବା ଦିନ ହେଉଛି ନମୁନା ସଂଗ୍ରହ ତାରିଖ। ଏହି ରିପୋର୍ଟରେ ଏକ ନିର୍ଭରଯୋଗ୍ୟ ତାରିଖ ମିଳିଲା ନାହିଁ। ନମୁନା ସଂଗ୍ରହ ତାରିଖ ଅପଲୋଡ୍ ତାରିଖଠାରୁ ଭିନ୍ନ। ଏକ ଫଳାଫଳ ଖୋଲି ତାହାର ତାରିଖ ଯାଞ୍ଚ କିମ୍ବା ସଂଶୋଧନ କରନ୍ତୁ।';

  @override
  String get uploading => 'ଅପଲୋଡ୍ ହେଉଛି';

  @override
  String get waitingToProcess => 'ପ୍ରକ୍ରିୟାକରଣ ପାଇଁ ଅପେକ୍ଷାରେ';

  @override
  String get readingReport => 'ରିପୋର୍ଟ ପଢ଼ାଯାଉଛି';

  @override
  String get readyToReview => 'ସମୀକ୍ଷା ପାଇଁ ପ୍ରସ୍ତୁତ';

  @override
  String get someResultsNeedReview => 'କିଛି ଫଳାଫଳର ସମୀକ୍ଷା ଆବଶ୍ୟକ';

  @override
  String get couldNotReadReport => 'ରିପୋର୍ଟ ପଢ଼ିହେଲା ନାହିଁ';

  @override
  String get processingStopped => 'ପ୍ରକ୍ରିୟାକରଣ ବନ୍ଦ ହୋଇଛି';

  @override
  String get couldNotProcessReport => 'ରିପୋର୍ଟ ପ୍ରକ୍ରିୟାକରଣ କରିହେଲା ନାହିଁ';

  @override
  String get reportRefreshFailed =>
      'ଏହି ରିପୋର୍ଟ ପୁଣି ଲୋଡ୍ କରିହେଲା ନାହିଁ। ଶେଷ ଥର ଲୋଡ୍ ହୋଇଥିବା ଫଳାଫଳ ଦେଖାଯାଉଛି।';

  @override
  String get multipleSampleDates => 'ଏକାଧିକ ନମୁନା ସଂଗ୍ରହ ତାରିଖ ';

  @override
  String get missingSampleDate => 'ନମୁନା ସଂଗ୍ରହ ତାରିଖ ମିଳିଲା ନାହିଁ ';

  @override
  String get reportAnalyzing =>
      'ଆମେ ଏହି ରିପୋର୍ଟ ବିଶ୍ଳେଷଣ କରୁଛୁ। ଆପଣ ଏହି ସ୍କ୍ରିନ୍‌ରୁ ବାହାରିପାରିବେ; ଫଳାଫଳ ପ୍ରସ୍ତୁତ ହେଲେ ଦେଖାଯିବ।';

  @override
  String get extractionIncompleteTitle =>
      'ସମସ୍ତ ଫଳାଫଳ ନିର୍ଭରଯୋଗ୍ୟ ଭାବେ ବାହାର କରିହେଲା ନାହିଁ';

  @override
  String get extractionIncompleteHelp =>
      'ସ୍ୱୟଂଚାଳିତ ଭାବେ ତଥ୍ୟ ବାହାର କରିବା ପ୍ରକ୍ରିୟା ଅସମ୍ପୂର୍ଣ୍ଣ ରହିଲା। ଚିହ୍ନଟ ହୋଇଥିବା ଧାଡ଼ିଗୁଡ଼ିକ ସେଭ୍ କରିବା ପୂର୍ବରୁ ମୂଳ ରିପୋର୍ଟ ସହ ମିଳାଇ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get verifiedRowsHelp =>
      'ଏହି ଧାଡ଼ିଗୁଡ଼ିକୁ ମୂଳ ରିପୋର୍ଟ ସହ ମିଳାଇ ଯାଞ୍ଚ କରାଯାଇଛି। ଅନ୍ୟ ଧାଡ଼ିଗୁଡ଼ିକର ସମୀକ୍ଷା ଏବେ ମଧ୍ୟ ଆବଶ୍ୟକ ହୋଇପାରେ।';

  @override
  String get noTestValues =>
      'ଏହି ରିପୋର୍ଟରେ କୌଣସି ପରୀକ୍ଷାର ମାନ ମିଳିଲା ନାହିଁ। ଏଥିରେ କ’ଣ ଅଛି ଯାଞ୍ଚ କରିବାକୁ ମୂଳ ଫାଇଲ୍ ଖୋଲନ୍ତୁ।';

  @override
  String get processingRetryHelp =>
      'ସମାପ୍ତ ହେବା ପୂର୍ବରୁ ପ୍ରକ୍ରିୟାକରଣ ବନ୍ଦ ହୋଇଛି। ଆପଣଙ୍କ ଫାଇଲ୍ ସେଭ୍ ହୋଇଛି। ପୁଣି ଚେଷ୍ଟା କରିବାକୁ ‘ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ’ରେ ଟ୍ୟାପ୍ କରନ୍ତୁ।';

  @override
  String get resultsNeedCheck =>
      'କିଛି ଫଳାଫଳକୁ ମୂଳ ରିପୋର୍ଟ ସହ ମିଳାଇ ଯାଞ୍ଚ କରିବା ଆବଶ୍ୟକ। ଆପଣ ତଳେ ଚିହ୍ନଟ ହୋଇଥିବା ଧାଡ଼ିଗୁଡ଼ିକର ସମୀକ୍ଷା କରିପାରିବେ।';

  @override
  String get readerModeHelp =>
      'ସହଜରେ ଦେଖିବା ଓ ଭଲ ଭାବେ ପଢ଼ିବା ପାଇଁ ସଜାଯାଇଥିବା ରିପୋର୍ଟ ପଠନ ମୋଡ୍‌ରେ ଉପଲବ୍ଧ।';

  @override
  String get aiRangeHelp =>
      'ପ୍ରକ୍ରିୟାକରଣ ସମୟରେ AI ଦ୍ୱାରା ସୀମାର ଅର୍ଥ ନିରୂପଣ କରାଯାଇଛି। ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get checkResultHelp =>
      'ଏହି ଫଳାଫଳ ଉପରେ ନିର୍ଭର କରିବା ପୂର୍ବରୁ ଏହାକୁ ମୂଳ ରିପୋର୍ଟ ସହ ମିଳାଇ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get preferredRangeHelp =>
      'ଲ୍ୟାବ୍ ଦ୍ୱାରା ଛପାଯାଇଥିବା ବାଞ୍ଛନୀୟ ଶ୍ରେଣୀ ସହ ତୁଳନା କରାଯାଇଛି; ଏହା ଆପଣଙ୍କ ପାଇଁ ପ୍ରଯୁଜ୍ୟ କି ନାହିଁ ନିଶ୍ଚିତ କରନ୍ତୁ।';

  @override
  String get categoryComparisonHelp =>
      'ଏହି ତୁଳନାରେ ଲ୍ୟାବ୍ ଦ୍ୱାରା ଛପାଯାଇଥିବା ବାଞ୍ଛନୀୟ ଶ୍ରେଣୀ ବ୍ୟବହୃତ ହୋଇଛି। ଏହି ଶ୍ରେଣୀ ଆପଣଙ୍କ ପାଇଁ ପ୍ରଯୁଜ୍ୟ କି ନାହିଁ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get missingSavedResult =>
      'ଏହି ମାନକୁ କୌଣସି ସେଭ୍ ହୋଇଥିବା ଫଳାଫଳ ସହ ମିଳାଇହେଲା ନାହିଁ। ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ କିମ୍ବା ଏହି ରିପୋର୍ଟ ପୁଣି ଲୋଡ୍ କରନ୍ତୁ।';

  @override
  String get unreviewedTest =>
      'AI ବ୍ୟାଖ୍ୟା ପାଇଁ ଏହି ପରୀକ୍ଷାର ସମୀକ୍ଷା ଏପର୍ଯ୍ୟନ୍ତ ହୋଇନାହିଁ। ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ଆପଣଙ୍କ ଚିକିତ୍ସକଙ୍କ ସହ ଫଳାଫଳ ବିଷୟରେ ଆଲୋଚନା କରନ୍ତୁ।';

  @override
  String get unsafeResult =>
      'ବାହାର କରାଯାଇଥିବା ଫଳାଫଳ ଅସ୍ପଷ୍ଟ, ତେଣୁ ଏହାକୁ ନିରାପଦ ଭାବେ ବ୍ୟାଖ୍ୟା କରିହେବ ନାହିଁ। ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ।';

  @override
  String get filterReports => 'ରିପୋର୍ଟ ଫିଲ୍ଟର୍ କରନ୍ତୁ';

  @override
  String get sortReports => 'ରିପୋର୍ଟ କ୍ରମରେ ସଜାନ୍ତୁ';

  @override
  String get recycleBin => 'ରିସାଇକଲ୍ ବିନ୍';

  @override
  String get healthHistory => 'ସ୍ୱାସ୍ଥ୍ୟ ଇତିହାସ';

  @override
  String get shareProfile => 'ପ୍ରୋଫାଇଲ୍ ସେୟାର୍ କରନ୍ତୁ';

  @override
  String get reportsUnavailableTitle => 'ରିପୋର୍ଟ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get reportsLoadFailed =>
      'ରିପୋର୍ଟ ଲୋଡ୍ କରିହେଲା ନାହିଁ। ଇଣ୍ଟରନେଟ୍ ସଂଯୋଗ ହେଲେ ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get upload => 'ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get reportsFor => 'ଏହାଙ୍କ ପାଇଁ ରିପୋର୍ଟ';

  @override
  String get searchReports => 'ରିପୋର୍ଟ କିମ୍ବା ଲ୍ୟାବ୍ ଖୋଜନ୍ତୁ';

  @override
  String get filters => 'ଫିଲ୍ଟର୍';

  @override
  String get noReportsYet => 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ରିପୋର୍ଟ ନାହିଁ';

  @override
  String get noMatchingReports => 'ଆପଣଙ୍କ ଖୋଜା ସହ କୌଣସି ରିପୋର୍ଟ ମେଳ ଖାଉନାହିଁ।';

  @override
  String get differentSearch =>
      'ଅନ୍ୟ ଏକ ପରୀକ୍ଷା, ଲ୍ୟାବ୍ କିମ୍ବା ଫିଲ୍ଟର୍ ବ୍ୟବହାର କରି ଦେଖନ୍ତୁ।';

  @override
  String get clearFilters => 'ଖୋଜିବା ପାଇଁ ଲେଖିଥିବା ପାଠ୍ୟ ଓ ଫିଲ୍ଟର୍ ହଟାନ୍ତୁ';

  @override
  String get original => 'ମୂଳ';

  @override
  String get switchActiveProfile => 'ସକ୍ରିୟ ପ୍ରୋଫାଇଲ୍ ବଦଳାନ୍ତୁ';

  @override
  String get switchProfileHelp =>
      'ଅନ୍ୟ ଜଣଙ୍କ ରିପୋର୍ଟ ଦେଖନ୍ତୁ। ଅପଲୋଡ୍ ଓ ସମୟ ସହ ପରିବର୍ତ୍ତନ ଦେଖିବା ପାଇଁ ବ୍ୟବହୃତ ଆପଣଙ୍କ ସକ୍ରିୟ ପ୍ରୋଫାଇଲ୍ ମଧ୍ୟ ବଦଳିଯିବ।';

  @override
  String get multipleCollectionDates => 'ଏକାଧିକ ନମୁନା ସଂଗ୍ରହ ତାରିଖ';

  @override
  String get unknownCollectionDate => 'ନମୁନା ସଂଗ୍ରହ ତାରିଖ ଅଜଣା';

  @override
  String get profileLoadFailed =>
      'ପ୍ରୋଫାଇଲ୍ ଲୋଡ୍ କରିହେଲା ନାହିଁ। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get pleaseTryAgain => 'ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get deleteProfileConfirm => 'ପ୍ରୋଫାଇଲ୍ ଡିଲିଟ୍ କରିବେ କି?';

  @override
  String get deleteProfileHelp =>
      'ଏହି ପ୍ରୋଫାଇଲ୍ ହଟାଯିବ। ଏହା ସହ ଜଡ଼ିତ ଯେକୌଣସି ତଥ୍ୟ ପ୍ରଭାବିତ ହେବ।';

  @override
  String get profileDeleteFailed =>
      'ପ୍ରୋଫାଇଲ୍ ଡିଲିଟ୍ କରିହେଲା ନାହିଁ। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get addFamilyMember => 'ପରିବାର ସଦସ୍ୟ ଯୋଡ଼ନ୍ତୁ';

  @override
  String get familyUnavailable => 'ପରିବାରର ପ୍ରୋଫାଇଲ୍ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get familyIntro =>
      'ବ୍ୟକ୍ତି ଅନୁଯାୟୀ ସଜାଯାଇଥିବା ରିପୋର୍ଟ ଓ ସମୟ ସହ ପରିବର୍ତ୍ତନ';

  @override
  String get noProfilesYet => 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ପ୍ରୋଫାଇଲ୍ ନାହିଁ';

  @override
  String get noProfilesHelp =>
      'ନିଜର କିମ୍ବା ପରିବାର ସଦସ୍ୟଙ୍କ ରିପୋର୍ଟ ସଜାଇ ରଖିବାକୁ ଏକ ପ୍ରୋଫାଇଲ୍ ଯୋଡ଼ନ୍ତୁ।';

  @override
  String get yourFamily => 'ଆପଣଙ୍କ ପରିବାର';

  @override
  String get upgradeProfiles => 'ଅଧିକ ପ୍ରୋଫାଇଲ୍ ଯୋଡ଼ିବାକୁ ଅପଗ୍ରେଡ୍ କରନ୍ତୁ';

  @override
  String get editProfile => 'ପ୍ରୋଫାଇଲ୍ ସମ୍ପାଦନ କରନ୍ତୁ';

  @override
  String get deleteProfile => 'ପ୍ରୋଫାଇଲ୍ ଡିଲିଟ୍ କରନ୍ତୁ';

  @override
  String get active => 'ସକ୍ରିୟ';

  @override
  String get setActive => 'ସକ୍ରିୟ କରନ୍ତୁ';

  @override
  String get viewReports => 'ରିପୋର୍ଟ ଦେଖନ୍ତୁ';

  @override
  String get notNow => 'ଏବେ ନୁହେଁ';

  @override
  String get openSettings => 'ସେଟିଂସ୍ ଖୋଲନ୍ତୁ';

  @override
  String get enableNotifications => 'ବିଜ୍ଞପ୍ତି ଚାଲୁ କରନ୍ତୁ';

  @override
  String get enableNotificationsConfirm => 'ବିଜ୍ଞପ୍ତି ଚାଲୁ କରିବେ କି?';

  @override
  String get notificationsEnabled => 'ରିପୋର୍ଟ ବିଜ୍ଞପ୍ତି ଚାଲୁ ହୋଇଛି';

  @override
  String get notificationsStayOff =>
      'ବିଜ୍ଞପ୍ତି ବନ୍ଦ ରହିଛି। ଆପଣ ପରେ ଡିଭାଇସ୍ ସେଟିଂସ୍‌ରେ ଏହା ଚାଲୁ କରିପାରିବେ।';

  @override
  String get notificationsFailed =>
      'ବିଜ୍ଞପ୍ତି ଚାଲୁ କରିହେଲା ନାହିଁ। ଆପଣଙ୍କ ଇଣ୍ଟରନେଟ୍ ସଂଯୋଗ ଯାଞ୍ଚ କରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get switchProfileFailed =>
      'ପ୍ରୋଫାଇଲ୍ ବଦଳାଇହେଲା ନାହିଁ। ଦୟାକରି ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ।';

  @override
  String get sourceReportFailed => 'ମୂଳ ରିପୋର୍ଟ ଖୋଲିହେଲା ନାହିଁ।';

  @override
  String get partialRefreshFailed =>
      'କିଛି ସୂଚନା ପୁଣି ଲୋଡ୍ କରିହେଲା ନାହିଁ। ପୁଣି ଚେଷ୍ଟା କରିବାକୁ ତଳକୁ ଟାଣନ୍ତୁ।';

  @override
  String get knowReportReady => 'ଆପଣଙ୍କ ରିପୋର୍ଟ ପ୍ରସ୍ତୁତ ହେଲେ ଜାଣନ୍ତୁ';

  @override
  String get oneResult => 'ଗୋଟିଏ ଫଳାଫଳ';

  @override
  String get sameDayResults => 'ସମାନ ଦିନର ଫଳାଫଳ';

  @override
  String get verificationRequired => 'ଯାଞ୍ଚ ଆବଶ୍ୟକ';

  @override
  String get accountCreatedLogin =>
      'ଆପଣଙ୍କ ଆକାଉଣ୍ଟ ସଫଳତାର ସହ ଖୋଲାଯାଇଛି। ଲଗ୍ ଇନ୍ କରିବାକୁ ଆଗକୁ ବଢ଼ନ୍ତୁ।';

  @override
  String get continueLogin => 'ଲଗ୍ ଇନ୍ କରିବାକୁ ଆଗକୁ ବଢ଼ନ୍ତୁ';

  @override
  String get allReports => 'ସବୁ ରିପୋର୍ଟ';

  @override
  String get filterReviewed => 'ସମୀକ୍ଷା ହୋଇଛି';

  @override
  String get filterNeedsReview => 'ସମୀକ୍ଷା ଆବଶ୍ୟକ';

  @override
  String get filterProcessing => 'ପ୍ରକ୍ରିୟାକରଣ ଚାଲିଛି';

  @override
  String get filterOriginalOnly => 'କେବଳ ମୂଳ';

  @override
  String get reportDateNewest => 'ରିପୋର୍ଟ ତାରିଖ · ନୂଆ ପ୍ରଥମେ';

  @override
  String get reportDateOldest => 'ରିପୋର୍ଟ ତାରିଖ · ପୁରୁଣା ପ୍ରଥମେ';

  @override
  String get uploadDateNewest => 'ଅପଲୋଡ୍ ତାରିଖ · ନୂଆ ପ୍ରଥମେ';

  @override
  String get uploadDateOldest => 'ଅପଲୋଡ୍ ତାରିଖ · ପୁରୁଣା ପ୍ରଥମେ';

  @override
  String get switchAction => 'ବଦଳାନ୍ତୁ';

  @override
  String get collectionDate => 'ନମୁନା ସଂଗ୍ରହ ତାରିଖ';

  @override
  String get copy => 'କପି କରନ୍ତୁ';

  @override
  String get history => 'ଇତିହାସ';

  @override
  String get loadingReport => 'ରିପୋର୍ଟ ଲୋଡ୍ ହେଉଛି…';

  @override
  String get restore => 'ପୁନରୁଦ୍ଧାର କରନ୍ତୁ';

  @override
  String get revoke => 'ରଦ୍ଦ କରନ୍ତୁ';

  @override
  String get testName => 'ପରୀକ୍ଷାର ନାମ';

  @override
  String get viewReport => 'ରିପୋର୍ଟ ଦେଖନ୍ତୁ';

  @override
  String get closeAccount => 'ଆକାଉଣ୍ଟ ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get createShareLink => 'ସେୟାର୍ ଲିଙ୍କ୍ ତିଆରି କରନ୍ତୁ';
}
