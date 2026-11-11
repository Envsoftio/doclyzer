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

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'ଦୃଶ୍ୟ ବଦଳିଗଲା, କିନ୍ତୁ ପରବର୍ତ୍ତୀ ଥର ପାଇଁ ସଞ୍ଚୟ ହୋଇପାରିଲା ନାହିଁ';

  @override
  String get uiThisReportIsNoLongerAvailable => 'ଏହି ରିପୋର୍ଟ ଆଉ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'ବିଜ୍ଞପ୍ତି ପୂର୍ବାବଲୋକନ ପରିଚାଳନା କରିବାକୁ ଉପକରଣ ସେଟିଂସମୂହ ଖୋଲନ୍ତୁ';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'ଅପଲୋଡ୍ ଗ୍ରହଣ ନହେବା ପର୍ଯ୍ୟନ୍ତ ଏହି ପରଦାକୁ ଖୋଲା ରଖନ୍ତୁ';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'ଏକ ଅପଲୋଡ୍ ବାଧାପ୍ରାପ୍ତ ହୋଇଥାଇପାରେ';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'ରିପୋର୍ଟଗୁଡିକ ଯାଞ୍ଚ କରନ୍ତୁ । ଯଦି ଏହା ହଜିଯାଉଛି, ପୁନର୍ବାର ସମାନ ଫାଇଲ୍ ଯୋଡନ୍ତୁ';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'ବିଜ୍ଞପ୍ତିକୁ ଖାରଜ କରିପାରିଲା ନାହିଁ । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiConnectionUnavailable => 'ସଂଯୋଗ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'ଆପଣଙ୍କର ଅଧିବେଶନ ଯାଞ୍ଚ ହୋଇପାରିଲା ନାହିଁ । ଇଣ୍ଟରନେଟ୍ ସହିତ ସଂଯୋଗ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiSignInWithAnotherAccount => 'ଅନ୍ୟ ଏକ ଖାତା ସହିତ ସାଇନ୍ ଇନ୍ କରନ୍ତୁ';

  @override
  String get uiNoActiveProfile => 'କ active ଣସି ସକ୍ରିୟ ପ୍ରୋଫାଇଲ୍ ନାହିଁ';

  @override
  String get uiDismissUploadNotice => 'ଅପଲୋଡ୍ ନୋଟିସ୍ ଖାରଜ କରନ୍ତୁ';

  @override
  String get uiDismissReadyNotifications =>
      'ପ୍ରସ୍ତୁତ ବିଜ୍ଞପ୍ତିକୁ ବରଖାସ୍ତ କରନ୍ତୁ';

  @override
  String get uiRequestSupport => 'ସମର୍ଥନ ଅନୁରୋଧ';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'ଆମେ ଡାଇଗ୍ନୋଷ୍ଟିକ୍ ଆଇଡି ଅନ୍ତର୍ଭୂକ୍ତ କରିବୁ ଯାହା ଦ୍ team ାରା ଦଳ ଅନୁସନ୍ଧାନ କରିପାରିବ।';

  @override
  String get uiSendRequest => 'ଅନୁରୋଧ ପଠାନ୍ତୁ';

  @override
  String get uiWhatHappenedOptional => 'କ’ଣ ହେଲା? (ବ al କଳ୍ପିକ)';

  @override
  String get uiReviewResult => 'ଫଳାଫଳ ସମୀକ୍ଷା କରନ୍ତୁ';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'ସଞ୍ଚୟ କରିବା ପୂର୍ବରୁ ଏହି କ୍ଷେତ୍ରଗୁଡ଼ିକୁ ମୂଳ ରିପୋର୍ଟ ସହିତ ତୁଳନା କରନ୍ତୁ';

  @override
  String get uiOriginallyExtracted => 'ମୂଳତ extr ବାହାର କରାଯାଇଛି';

  @override
  String get uiReloadReport => 'ରିପୋର୍ଟ ପୁନ elo ଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get uiResultAsPrinted => 'ମୁଦ୍ରିତ ପରି ଫଳାଫଳ';

  @override
  String get uiUnitIfShown => 'ୟୁନିଟ୍ (ଯଦି ଦେଖାଯାଏ)';

  @override
  String get uiLabReferenceRangeIfShown =>
      'ଲ୍ୟାବ୍ ରେଫରେନ୍ସ ପରିସର (ଯଦି ଦେଖାଯାଏ)';

  @override
  String get uiCheckYourReport => 'ଆପଣଙ୍କର ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiNoAttemptHistoryAvailable =>
      'କ attempt ଣସି ପ୍ରୟାସ ଇତିହାସ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiIInspectedTheOriginal => 'ମୁଁ ମୂଳ ଯାଞ୍ଚ କଲି';

  @override
  String get uiChooseTwoReports => 'ଦୁଇଟି ରିପୋର୍ଟ ବାଛନ୍ତୁ';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'ସମାନ ବ୍ୟକ୍ତିଙ୍କ ପାଇଁ ରେକର୍ଡ ବ୍ୟବହାର କରନ୍ତୁ । ମେଳ ପରୀକ୍ଷଣଗୁଡ଼ିକ ପାର୍ଶ୍ୱରେ ଦେଖାଯିବ';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'ପ୍ରଥମେ ପୁରୁଣା ରିପୋର୍ଟ ଏବଂ ଦ୍ୱିତୀୟଟି ନୂତନ ରିପୋର୍ଟ ବାଛନ୍ତୁ';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'କେବଳ ସୁସଙ୍ଗତ ହେଲେ ତୁଳନା କରାଯାଏ । ସୁସଙ୍ଗତତା ନିଶ୍ଚିତ ନହେବା ପର୍ଯ୍ୟନ୍ତ ବିଭିନ୍ନ ୟୁନିଟ୍ କିମ୍ବା ପଦ୍ଧତି ପୃଥକ ଭାବରେ ଦେଖାଯାଏ';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'ପରିବର୍ତ୍ତନ ଏକ ନିରାକରଣ ନୁହେଁ । ପ୍ରତ୍ୟେକ ଫଳାଫଳକୁ ନିଜସ୍ୱ ରିପୋର୍ଟ ବ୍ୟବଧାନ ସହିତ ତୁଳନା କରନ୍ତୁ ଏବଂ ଆପଣଙ୍କର କ୍ଲିନିକ୍ ସହିତ ପ୍ରସଙ୍ଗ ବିଷୟରେ ଆଲୋଚନା କରନ୍ତୁ';

  @override
  String get uiChooseDifferentReports => 'ବିଭିନ୍ନ ରିପୋର୍ଟ ବାଛନ୍ତୁ';

  @override
  String get uiEarlierReport => 'ପୂର୍ବରୁ ରିପୋର୍ଟ';

  @override
  String get uiLaterReport => 'ପରେ ରିପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get uiYourReportPages => 'ତୁମର ରିପୋର୍ଟ ପୃଷ୍ଠାଗୁଡ଼ିକ';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'ରିପୋର୍ଟଗୁଡିକ ସହିତ ସମାନ କ୍ରମରେ ପୃଷ୍ଠାଗୁଡିକ ରଖନ୍ତୁ';

  @override
  String get uiAddAnotherPage => 'ଅନ୍ୟ ଏକ ପୃଷ୍ଠା ଯୋଡନ୍ତୁ';

  @override
  String get uiChoosePagesFromGallery => 'ଗ୍ୟାଲେରୀରୁ ପୃଷ୍ଠାଗୁଡିକ ବାଛନ୍ତୁ';

  @override
  String get uiAdjustPage => 'ପୃଷ୍ଠା ଆଡଜଷ୍ଟ କରନ୍ତୁ';

  @override
  String get uiRetake => 'ପୁନ ake ଗ୍ରହଣ କରନ୍ତୁ';

  @override
  String get uiUseAdjustedPage => 'ନିୟନ୍ତ୍ରିତ ପୃଷ୍ଠା ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiResetChanges => 'ପରିବର୍ତ୍ତନଗୁଡିକ ପୁନ Res ସେଟ୍ କରନ୍ତୁ';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'ପ୍ରତ୍ୟେକ ଫଳାଫଳକୁ କୋଣ ଭିତରେ ରଖନ୍ତୁ';

  @override
  String get uiRotate => 'ଘୂର୍ଣ୍ଣନ କରନ୍ତୁ';

  @override
  String get uiReportRestored => 'ରିପୋର୍ଟ ପୁନ restored ସ୍ଥାପିତ ହୋଇଛି';

  @override
  String get uiDeleteReportPermanently =>
      'ସ୍ଥାୟୀ ଭାବରେ ରିପୋର୍ଟ ବିଲୋପ କରିବେ କି?';

  @override
  String get uiDeletePermanently => 'ସ୍ଥାୟୀ ଭାବରେ ବିଲୋପ କରନ୍ତୁ';

  @override
  String get uiReportPermanentlyDeleted =>
      'ସ୍ଥାୟୀ ଭାବରେ ବିଲୋପ ହୋଇଥିବା ରିପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get uiEmptyRecycleBin => 'ଖାଲି ରିସାଇକ୍ଲି ବିନ୍?';

  @override
  String get uiDeleteAll => 'ସମସ୍ତ ବିଲୋପ କରନ୍ତୁ';

  @override
  String get uiRecycleBinIsEmpty => 'ରିସାଇକ୍ଲି ବିନ୍ ଖାଲି ଅଛି';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'ବିଲୋପ ହୋଇଥିବା ରିପୋର୍ଟଗୁଡିକ ଅପସାରଣ ପୂର୍ବରୁ ଏଠାରେ ଦେଖାଯିବ';

  @override
  String get uiEmptyRecycleBind657e2 => 'ଖାଲି ରିସାଇକ୍ଲି ବିନ୍';

  @override
  String get uiCheckDetectedResult => 'ଚିହ୍ନଟ ଫଳାଫଳ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'ଏହି ଧାଡିଟି ମୂଳ ରିପୋର୍ଟ ସହିତ ତୁଳନା କରନ୍ତୁ । ସଞ୍ଚୟ କରିବା ପୂର୍ବରୁ ଯେକ any ଣସି OCR ତ୍ରୁଟି ସଂଶୋଧନ କରନ୍ତୁ';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'ମୁଁ ମୂଳ ରିପୋର୍ଟ ବିରୁଦ୍ଧରେ ଏହି ଫଳାଫଳ ଯାଞ୍ଚ କରିଥିଲି';

  @override
  String get uiSaving => 'ସଞ୍ଚୟ…';

  @override
  String get uiSaveVerifiedResult => 'ଯାଞ୍ଚ ହୋଇଥିବା ଫଳାଫଳ ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'କ results ଣସି ଫଳାଫଳ ଚିହ୍ନଟ ହୋଇନାହିଁ । ମୂଳ ରିପୋର୍ଟ ଦେଖନ୍ତୁ କିମ୍ବା ପୁନ ry ପ୍ରକ୍ରିୟାକରଣ';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'ସଂରକ୍ଷିତ ଫଳାଫଳ ହେବା ପୂର୍ବରୁ ଚିହ୍ନଟ ହୋଇଥିବା ମୂଲ୍ୟଗୁଡିକ ମୂଳ ରିପୋର୍ଟ ବିରୁଦ୍ଧରେ ଯାଞ୍ଚ କରାଯିବା ଆବଶ୍ୟକ';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'କିଛି ଧାଡି ନିଖୋଜ ହୋଇପାରେ । ସମଗ୍ର ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiResult => 'ଫଳାଫଳ';

  @override
  String get uiUnitOptional => 'ଏକକ (ବ al କଳ୍ପିକ)';

  @override
  String get uiReferenceRangeOptional => 'ସନ୍ଦର୍ଭ ପରିସର (ବ al କଳ୍ପିକ)';

  @override
  String get uiVerified => 'ଯାଞ୍ଚ ହୋଇଛି';

  @override
  String get uiGiftVoucher => 'ଉପହାର ଭାଉଚର୍';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'ଏକ ଉପହାର ଭାଉଚରକୁ ମୁକ୍ତ କର ଏବଂ ସିଧାସଳଖ ତୁମର ବାଲାନ୍ସରେ କ୍ରେଡିଟ୍ ଯୋଡ';

  @override
  String get uiCurrentPlan => 'ସାମ୍ପ୍ରତିକ ଯୋଜନା';

  @override
  String get uiCreditBalance => 'କ୍ରେଡିଟ୍ ବାଲାନ୍ସ';

  @override
  String get uiPlanLimits => 'ଯୋଜନା ସୀମା';

  @override
  String get uiBuyCredits => 'କ୍ରେଡିଟ୍ କିଣନ୍ତୁ';

  @override
  String get uiRecentBillingActivity => 'ସମ୍ପ୍ରତି ବିଲିଂ କାର୍ଯ୍ୟକଳାପ';

  @override
  String get uiRefreshStatus => 'ସ୍ଥିତି ସତେଜ କରନ୍ତୁ';

  @override
  String get uiNoRecentOrdersYet =>
      'ବର୍ତ୍ତମାନ ପର୍ଯ୍ୟନ୍ତ କ orders ଣସି ଆଦେଶ ନାହିଁ';

  @override
  String get uiVoucherCode => 'ଭାଉଚର୍ କୋଡ୍';

  @override
  String get uiCheckout => 'ଚେକଆଉଟ୍';

  @override
  String get uiApply => 'ପ୍ରୟୋଗ କରନ୍ତୁ';

  @override
  String get uiClear => 'ସଫା';

  @override
  String get uiPay => 'ଦେୟ ଦିଅ';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'ଏହି ସମୟରେ କ credit ଣସି କ୍ରେଡିଟ୍ ପ୍ୟାକ୍ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiBuy => 'କିଣନ୍ତୁ';

  @override
  String get uiRetryPayment => 'ଦେୟ ପୁନ ry ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiPromoCode => 'ପ୍ରୋମୋ କୋଡ୍';

  @override
  String get uiEnterPromoCode => 'ପ୍ରୋମୋ କୋଡ୍ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiChooseAPlan => 'ଏକ ଯୋଜନା ବାଛନ୍ତୁ';

  @override
  String get uiNoPlansAvailableAtThisTime =>
      'ଏହି ସମୟରେ କ plans ଣସି ଯୋଜନା ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiHaveAPromoCode => 'ଏକ ପ୍ରୋମୋ କୋଡ୍ ଅଛି କି?';

  @override
  String get uiCURRENTPLAN => 'ବର୍ତ୍ତମାନର ଯୋଜନା';

  @override
  String get uiManageNotifications => 'ବିଜ୍ଞପ୍ତିଗୁଡିକ ପରିଚାଳନା କରନ୍ତୁ';

  @override
  String get uiAll => 'ସମସ୍ତ';

  @override
  String get uiUnread => 'ପ read ା ନାହିଁ';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'ପ୍ରବେଶ ତୁରନ୍ତ ବନ୍ଦ ହୋଇଯାଏ । ଆପଣ 30 ଦିନ ମଧ୍ୟରେ ସାଇନ୍ ଇନ୍ ଏବଂ ପୁନ restore ସ୍ଥାପନ କରିପାରିବେ । ଏହା ପରେ, ଆପଣଙ୍କର ଆକାଉଣ୍ଟ୍ ଏବଂ ଗଚ୍ଛିତ ଫାଇଲଗୁଡିକ ସକ୍ରିୟ ଷ୍ଟୋରେଜ୍ ରୁ ଡିଲିଟ୍ ହୋଇଯାଏ';

  @override
  String get uiCloseMyAccount => 'ମୋ ଖାତା ବନ୍ଦ କରନ୍ତୁ';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'ଆପଣଙ୍କର ରେକର୍ଡଗୁଡିକ ଡକ୍ଲିଜରରେ ରହିଥାଏ';

  @override
  String get uiTakeACopyOfYourRecords => 'ତୁମର ରେକର୍ଡଗୁଡ଼ିକର ଏକ କପି ନିଅ';

  @override
  String get uiWhoseRecords => 'କାହାର ରେକର୍ଡ?';

  @override
  String get uiCouldNotLoadProfiles => 'ପ୍ରୋଫାଇଲ୍ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ';

  @override
  String get uiLoadingProfiles => 'ପ୍ରୋଫାଇଲ୍ ଲୋଡ୍ କରୁଛି…';

  @override
  String get uiAllProfiles => 'ସମସ୍ତ ପ୍ରୋଫାଇଲ୍';

  @override
  String get uiDateRange => 'ତାରିଖ ପରିସର';

  @override
  String get uiUseAllDates => 'ସମସ୍ତ ତାରିଖ ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiINCLUDEINTHISEXPORT => 'ଏହି ରପ୍ତାନିରେ ଅନ୍ତର୍ଭୂକ୍ତ କରନ୍ତୁ';

  @override
  String get uiOriginalReports => 'ମୂଳ ରିପୋର୍ଟଗୁଡିକ';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'ଆପଣ ଅପଲୋଡ୍ କରିଥିବା PDF ଏବଂ ପ୍ରତିଛବିଗୁଡିକ';

  @override
  String get uiTestResults => 'ପରୀକ୍ଷା ଫଳାଫଳ';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'ସେମାନଙ୍କର ସମୀକ୍ଷା ସ୍ଥିତି ସହିତ CSV ଭାବରେ ଫଳାଫଳ';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'ରପ୍ତାନିରେ ବ୍ୟକ୍ତିଗତ ସୂଚନା ଥାଏ । ଆପଣ ବିଶ୍ trust ାସ କରୁଥିବା ସ୍ଥାନରେ ସେଗୁଡିକୁ ସଂରକ୍ଷଣ କରନ୍ତୁ';

  @override
  String get uiDeleteAccount => 'ଖାତା ବିଲୋପ କରନ୍ତୁ';

  @override
  String get uiContinueToDeletion => 'ବିଲୋପ ଜାରି ରଖ';

  @override
  String get uiKeepMyAccount => 'ମୋ ଖାତା ରଖ';

  @override
  String get uiBeforeYouLeave => 'ଆପଣ ଯିବା ପୂର୍ବରୁ';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'ଏହା କ’ଣ ଅପସାରଣ କରିବ ଦୟାକରି ପ read ନ୍ତୁ';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'ତୁମର ଖାତା ବିଲୋପ କରିବା ତୁମେ ପରିଚାଳନା କରୁଥିବା ସମସ୍ତ ପ୍ରୋଫାଇଲକୁ ପ୍ରଭାବିତ କରେ';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'ଆପଣଙ୍କର ଖାତା ଏବଂ ବ୍ୟକ୍ତିଗତ ପ୍ରୋଫାଇଲ୍';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'ଆପଣଙ୍କର ଅଂଶୀଦାର ଲିଙ୍କ୍ ମାଧ୍ୟମରେ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiKeepACopyFirst => 'ପ୍ରଥମେ ଏକ କପି ରଖ';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'ଆପଣ ରଖିବାକୁ ଚାହୁଁଥିବା ସୂଚନା ରପ୍ତାନି କରନ୍ତୁ';

  @override
  String get uiExportData => 'ଡାଟା ରପ୍ତାନି କରନ୍ତୁ';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'ପ୍ରବେଶ ତୁରନ୍ତ ବନ୍ଦ ହୋଇଯାଏ । ଆପଣ 30 ଦିନ ମଧ୍ୟରେ ପୁନ restore ସ୍ଥାପନ କରିପାରିବେ । ଏହା ପରେ, ଆପଣଙ୍କର ତଥ୍ୟ ସକ୍ରିୟ ସଂରକ୍ଷଣ ସ୍ଥାନରୁ ଅପସାରିତ ହୋଇଛି';

  @override
  String get uiAccountPendingDeletion => 'ବିଲୋପ ବିଚାରାଧୀନ ଥିବା ଖାତା';

  @override
  String get uiRestoreMyAccount => 'ମୋ ଖାତା ପୁନରୁଦ୍ଧାର କରନ୍ତୁ';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'ଆପଣଙ୍କର ପ୍ରୋଫାଇଲ୍, ପ୍ରୋଫାଇଲ୍ ଏବଂ ସମ୍ମତି ରେକର୍ଡଗୁଡିକ ସହିତ ଆପଣଙ୍କର ଆକାଉଣ୍ଟ୍ ତଥ୍ୟର ଏକ କପି ଡାଉନଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'ତୁମର ଖାତା ତୁରନ୍ତ ଅକ୍ଷମ ହୋଇଛି । ଆପଣ ଏହାକୁ 30 ଦିନ ମଧ୍ୟରେ ପୁନ restore ସ୍ଥାପନ କରିପାରିବେ । ଏହା ପରେ, ଆପଣଙ୍କର ତଥ୍ୟ ସବୁଦିନ ପାଇଁ ବିଲୋପ ହୋଇଯାଏ';

  @override
  String get uiCurrentPassword => 'ସାମ୍ପ୍ରତିକ ପାସୱାର୍ଡ';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'ଆପ୍ ଲକ୍ ପରିବର୍ତ୍ତନ କରିପାରିବ ନାହିଁ । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'ଆପଣଙ୍କର ରେକର୍ଡଗୁଡିକ\nଅଂଶୀଦାର କରିବାକୁ ଆପଣଙ୍କର ପସନ୍ଦ';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'ଯେତେବେଳେ ଆପଣ ଆବଶ୍ୟକ କରନ୍ତି ପ୍ରବେଶ ସମୀକ୍ଷା କରନ୍ତୁ';

  @override
  String get uiAppLock => 'ଆପ୍ ଲକ୍';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'ଆପଣଙ୍କର ଡିଭାଇସର ବାୟୋମେଟ୍ରିକ୍ କିମ୍ବା ପାସକୋଡ୍ ଲକ୍ ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiNotificationPreviews => 'ବିଜ୍ଞପ୍ତି ପୂର୍ବାବଲୋକନ';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'ଆପଣଙ୍କର ଡିଭାଇସ୍ ସେଟିଂସମୂହରେ ଲକ୍-ସ୍କ୍ରିନ୍ ପୂର୍ବାବଲୋକନକୁ ନିୟନ୍ତ୍ରଣ କରନ୍ତୁ';

  @override
  String get uiContactSupport => 'ସମର୍ଥନ ଯୋଗାଯୋଗ କରନ୍ତୁ';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'ଯଦି ଆପଣ ପସନ୍ଦ କରନ୍ତି ତେବେ ରିପୋର୍ଟଗୁଡିକ ସଂଲଗ୍ନ କରନ୍ତୁ';

  @override
  String get uiWhatCanWeHelpYouWith => 'ଆମେ ଆପଣଙ୍କୁ କ’ଣ ସାହାଯ୍ୟ କରିପାରିବା?';

  @override
  String get uiPOPULARQUESTIONS => 'ସାଧାରଣ ପ୍ରଶ୍ନଗୁଡିକ';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'କ search ଣସି ସାହାଯ୍ୟ ପ୍ରବନ୍ଧଗୁଡ଼ିକ ତୁମର ସନ୍ଧାନ ସହିତ ମେଳ ଖାଉ ନାହିଁ';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'ଆପଣଙ୍କର ସ୍ୱାସ୍ଥ୍ୟ କିମ୍ବା ପରୀକ୍ଷା ଫଳାଫଳ ବିଷୟରେ ପ୍ରଶ୍ନ ପାଇଁ, ଜଣେ ଯୋଗ୍ୟ ସ୍ୱାସ୍ଥ୍ୟସେବା ବୃତ୍ତିଗତଙ୍କ ସହିତ କଥା ହୁଅନ୍ତୁ';

  @override
  String get uiYourReportsAClearerPicture =>
      'ତୁମର ରିପୋର୍ଟଗୁଡିକ ଏକ ସ୍ୱଚ୍ଛ ଚିତ୍ର';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'ଆପଣଙ୍କର ସ୍ୱାସ୍ଥ୍ୟ ଇତିହାସକୁ ଏକତ୍ର ରଖନ୍ତୁ';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'ରିପୋର୍ଟ ଗଚ୍ଛିତ କରନ୍ତୁ, ଫଳାଫଳ ସମୀକ୍ଷା କରନ୍ତୁ, ପରିବର୍ତ୍ତନଗୁଡିକ ଅନୁସରଣ କରନ୍ତୁ ଏବଂ ଆପଣଙ୍କର କ୍ଲିନିକ୍ ସହିତ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiEducationalInformationOnly => 'କେବଳ ଶିକ୍ଷାଗତ ସୂଚନା';

  @override
  String get uiSearchHelpArticles => 'ସହାୟତା ପ୍ରବନ୍ଧଗୁଡିକ ସନ୍ଧାନ କରନ୍ତୁ';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'ବିଜ୍ଞପ୍ତି ପ୍ରବେଶ ପରିବର୍ତ୍ତନ କରିବାକୁ ଡିଭାଇସ୍ ସେଟିଂସମୂହ ଆପ୍ ଖୋଲନ୍ତୁ';

  @override
  String get uiSavePreferences => 'ପସନ୍ଦଗୁଡିକ ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'ସେଟିଂସମୂହରେ ଉପକରଣ ଅନୁମତି ପରିବର୍ତ୍ତନ କରାଯାଇପାରିବ';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'ଏହି ଡିଭାଇସରେ ରିପୋର୍ଟ ଅଦ୍ୟତନଗୁଡିକ ପ୍ରାପ୍ତ କରନ୍ତୁ';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'ଏକ ରିପୋର୍ଟ ପ୍ରସ୍ତୁତ ହେଲେ ଜାଣିବାକୁ ବିଜ୍ଞପ୍ତିକୁ ଅନୁମତି ଦିଅନ୍ତୁ । ମାର୍କେଟିଂ ନିମ୍ନରେ ଏକ ଅଲଗା ପସନ୍ଦ';

  @override
  String get uiREPORTACTIVITY => 'ରିପୋର୍ଟ କାର୍ଯ୍ୟକଳାପ';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'ରିପୋର୍ଟ କାର୍ଯ୍ୟକଳାପ ସେଟିଂସମୂହ ସର୍ବଶେଷ ସର୍ଭର ସଂସ୍କରଣ ଆବଶ୍ୟକ କରେ';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'ସମ୍ବେଦନଶୀଳ ଲକ୍-ସ୍କ୍ରିନ୍ ପୂର୍ବାବଲୋକନ';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'ରିପୋର୍ଟ ନାମ ଏବଂ ବ୍ୟକ୍ତିଗତ ବିବରଣୀ ସବୁବେଳେ ଲୁକ୍କାୟିତ';

  @override
  String get uiOTHERMESSAGES => 'ଅନ୍ୟାନ୍ୟ ବାର୍ତ୍ତା';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'ପ୍ରତ୍ୟେକ ବ୍ୟକ୍ତିଙ୍କ ରିପୋର୍ଟ ଏବଂ ଧାରାକୁ ଏକତ୍ର ରଖନ୍ତୁ';

  @override
  String get uiPersonDetails => 'ବ୍ୟକ୍ତି ବିବରଣୀ';

  @override
  String get uiDateOfBirth => 'ଜନ୍ମ ତାରିଖ';

  @override
  String get uiRelationship => 'ସମ୍ପର୍କ';

  @override
  String get uiEnterAName => 'ଏକ ନାମ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiClearDateOfBirth => 'ଜନ୍ମ ତାରିଖ ସଫା କରନ୍ତୁ';

  @override
  String get uiOptionalEGParentOrChild =>
      'ବ tion କଳ୍ପିକ, ଯଥା ପିତାମାତା କିମ୍ବା ପିଲା';

  @override
  String get uiInviteFriendsEarnCredits =>
      'ସାଙ୍ଗମାନଙ୍କୁ ଆମନ୍ତ୍ରଣ କରନ୍ତୁ, କ୍ରେଡିଟ୍ ରୋଜଗାର କରନ୍ତୁ';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'ଆପଣଙ୍କର କୋଡ୍ ଅଂଶୀଦାର କରନ୍ତୁ ଏବଂ ପୁରସ୍କାର ଅନଲକ୍ ଭାବରେ ପ୍ରତ୍ୟେକ ନିମନ୍ତ୍ରଣକୁ ଅନୁସରଣ କରନ୍ତୁ';

  @override
  String get uiYOURREFERRALCODE => 'ଆପଣଙ୍କର ରେଫରାଲ୍ କୋଡ୍';

  @override
  String get uiShareInvite => 'ନିମନ୍ତ୍ରଣ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiCopyCode => 'କୋଡ୍ କପି କରନ୍ତୁ';

  @override
  String get uiHaveACode => 'ଏକ କୋଡ୍ ଅଛି କି?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'ଆପଣଙ୍କର ନିମନ୍ତ୍ରଣ ପୁରସ୍କାର ଦାବି କରିବାକୁ ଆପଣଙ୍କ ସହିତ ଅଂଶୀଦାର ହୋଇଥିବା ଏକ କୋଡ୍ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiHowRewardsWork => 'ପୁରସ୍କାର କିପରି କାମ କରେ';

  @override
  String get uiNoFriendsReferredYet =>
      'କ No ଣସି ସାଙ୍ଗ ଏପର୍ଯ୍ୟନ୍ତ ରେଫର୍ କରିନାହାଁନ୍ତି';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'ସେମାନଙ୍କର ଅଗ୍ରଗତି ଏଠାରେ ଦେଖିବା ପାଇଁ ଆପଣଙ୍କର ନିମନ୍ତ୍ରଣ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiReferralCode => 'ରେଫରାଲ୍ କୋଡ୍';

  @override
  String get uiSetNewPassword => 'ନୂତନ ପାସୱାର୍ଡ ସେଟ୍ କରନ୍ତୁ';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'ଆପଣଙ୍କର ଇମେଲ ଏବଂ ଆପଣଙ୍କର ନୂତନ ପାସୱାର୍ଡରେ ଥିବା ଲିଙ୍କରୁ ପୁନ et ସେଟ୍ ଟୋକନ୍ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiResetPassword => 'ପାସୱାର୍ଡ ପୁନ Res ସେଟ୍ କରନ୍ତୁ';

  @override
  String get uiBackToLogin => 'ଲଗଇନ୍ କୁ ଫେରନ୍ତୁ';

  @override
  String get uiResetToken => 'ଟୋକେନ୍ ପୁନ Res ସେଟ୍ କରନ୍ତୁ';

  @override
  String get uiNewPassword => 'ନୂତନ ପାସୱାର୍ଡ';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'ଆପଣଙ୍କର ଖାତା ସହିତ ଜଡିତ ଇମେଲ୍ ଠିକଣା ପ୍ରବେଶ କରନ୍ତୁ ଏବଂ ଆମେ ଆପଣଙ୍କର ପାସୱାର୍ଡ ପୁନ res ସେଟ୍ କରିବାକୁ ଏକ ଲିଙ୍କ୍ ପଠାଇବୁ';

  @override
  String get uiSendResetLink => 'ପୁନ Res ସେଟ୍ ଲିଙ୍କ୍ ପଠାନ୍ତୁ';

  @override
  String get uiRevokeSession => 'ଅଧିବେଶନ ପ୍ରତ୍ୟାହାର?';

  @override
  String get uiCurrentSession => 'ସାମ୍ପ୍ରତିକ ଅଧିବେଶନ';

  @override
  String get uiSkip => 'ଛାଡିଦିଅ';

  @override
  String get uiChangePassword => 'ପାସୱାର୍ଡ ପରିବର୍ତ୍ତନ କରନ୍ତୁ';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'ଆପଣଙ୍କର ସାମ୍ପ୍ରତିକ ପାସୱାର୍ଡ ପ୍ରବେଶ କରନ୍ତୁ ଏବଂ ଏକ ନୂତନ ବାଛନ୍ତୁ';

  @override
  String get uiNewPasswordd850ee => 'ନୂତନ ପାସୱାର୍ଡ';

  @override
  String get uiConfirmNewPassword => 'ନୂତନ ପାସୱାର୍ଡ ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get uiGettingThingsReady => 'ଜିନିଷ ପ୍ରସ୍ତୁତ କରିବା…';

  @override
  String get uiLinkAccessHistory => 'ଲିଙ୍କ୍ ଆକ୍ସେସ୍ ଇତିହାସ';

  @override
  String get uiNoAccessEventsYet =>
      'ଏପର୍ଯ୍ୟନ୍ତ କ access ଣସି ପ୍ରବେଶ ଇଭେଣ୍ଟ ନାହିଁ';

  @override
  String get uiDefaultShareLinkExpiry => 'ଡିଫଲ୍ଟ ସେୟାର ଲିଙ୍କ୍ ସମାପ୍ତି';

  @override
  String get uiSave => 'ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get uiReviewSharing => 'ଅଂଶୀଦାର ସମୀକ୍ଷା କରନ୍ତୁ';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'ବ୍ୟକ୍ତି, ରିପୋର୍ଟ ଏବଂ ପ୍ରବେଶ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'ଚୟନ କିମ୍ବା ପ୍ରବେଶ ସେଟିଂସମୂହ ସଂପାଦନ କରନ୍ତୁ';

  @override
  String get uiRevokeShareLink => 'ସେୟାର ଲିଙ୍କ୍ ପ୍ରତ୍ୟାହାର କରନ୍ତୁ?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'ଏହି ଲିଙ୍କ୍ କାମ ବନ୍ଦ କରିବ । ଆପଣ ଏକ ନୂତନ ସୃଷ୍ଟି କରିପାରିବେ';

  @override
  String get uiShareLinkReady => 'ଅଂଶୀଦାର ଲିଙ୍କ୍ ପ୍ରସ୍ତୁତ';

  @override
  String get uiAccessCodeShareSeparately =>
      'ଆକ୍ସେସ୍ କୋଡ୍ - ପୃଥକ ଭାବରେ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiCopyAccessCode => 'ଆକସେସ୍ କୋଡ୍ କପି କରନ୍ତୁ';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'ଏହି କୋଡ୍ ଏହି ଡିଭାଇସରେ ସଞ୍ଚୟ ହୋଇପାରିବ ନାହିଁ । ପରବର୍ତ୍ତୀ ବ୍ୟବହାର ପାଇଁ ଏହାକୁ ବର୍ତ୍ତମାନ କପି କରନ୍ତୁ';

  @override
  String get uiShareLink => 'ଲିଙ୍କ୍ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiCopyLink => 'ଲିଙ୍କ୍ କପି କରନ୍ତୁ';

  @override
  String get uiRevokeLink => 'ଲିଙ୍କ୍ ପ୍ରତ୍ୟାହାର କରନ୍ତୁ';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'ଏହି ଡିଭାଇସରେ କୋଡ୍ ଉପଲବ୍ଧ ନାହିଁ । ସଞ୍ଚିତ କୋଡ୍ ବ୍ୟବହାର କରନ୍ତୁ କିମ୍ବା ଏକ ନୂତନ ଲିଙ୍କ୍ ସୃଷ୍ଟି କରନ୍ତୁ';

  @override
  String get uiActiveSharedLinks => 'ସକ୍ରିୟ ଅଂଶୀଦାର ଲିଙ୍କ୍';

  @override
  String get uiShare => 'ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiCreateANewShareLink => 'ଏକ ନୂତନ ଅଂଶୀଦାର ଲିଙ୍କ୍ ସୃଷ୍ଟି କରନ୍ତୁ';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'ଏହି ପ୍ରୋଫାଇଲ୍ ପାଇଁ ସାମ୍ପ୍ରତିକ ଏବଂ ଭବିଷ୍ୟତ ରିପୋର୍ଟଗୁଡିକ ଅନ୍ତର୍ଭୂକ୍ତ କରନ୍ତୁ';

  @override
  String get uiChooseReports => 'ରିପୋର୍ଟଗୁଡିକ ବାଛନ୍ତୁ';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'ନିମ୍ନରେ ମନୋନୀତ ହୋଇଥିବା ରିପୋର୍ଟଗୁଡିକ କେବଳ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiSelectAll => 'ସମସ୍ତ ଚୟନ କରନ୍ତୁ';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'ଅଂଶୀଦାର କରିବାକୁ କ review ଣସି ସମୀକ୍ଷା ହୋଇଥିବା ରିପୋର୍ଟ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiSelectedTestResults => 'ମନୋନୀତ ପରୀକ୍ଷା ଫଳାଫଳ';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'ଏହି ରିପୋର୍ଟଗୁଡିକରୁ ଆପଣ ବାଛିଥିବା ଫଳାଫଳଗୁଡିକ କେବଳ ଅନ୍ତର୍ଭୂକ୍ତ କରନ୍ତୁ';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'ଏହି ରିପୋର୍ଟଗୁଡିକରେ କ saved ଣସି ସଞ୍ଚିତ ପରୀକ୍ଷା ଫଳାଫଳ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiUpgradeOrManage => 'ଅପଗ୍ରେଡ୍ କିମ୍ବା ପରିଚାଳନା କରନ୍ତୁ';

  @override
  String get uiExpiry => 'ସମାପ୍ତି:';

  @override
  String get uiRequireAnAccessCode => 'ଏକ ପ୍ରବେଶ ସଂକେତ ଆବଶ୍ୟକ କରନ୍ତୁ';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'ଲିଙ୍କ୍ ଠାରୁ ପୃଥକ ଭାବରେ କୋଡ୍ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiTryAgain => 'ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiClearExpiry => 'ମିଆଦ ପୂର୍ଣ୍ଣ କରନ୍ତୁ';

  @override
  String get onboardingStoreEyebrow => '01 / ସଂରକ୍ଷଣ କରନ୍ତୁ';

  @override
  String get onboardingStoreTitle => 'ପ୍ରତ୍ୟେକ ରିପୋର୍ଟ,\nଗୋଟିଏ ପରିଚିତ ସ୍ଥାନ';

  @override
  String get onboardingStoreBody =>
      'ଆପଣ ଏବଂ ଆପଣ ଯତ୍ନ ନେଉଥିବା ଲୋକଙ୍କ ପାଇଁ PDF ଏବଂ ଫଟୋ ଏକାଠି ରଖନ୍ତୁ';

  @override
  String get onboardingUnderstandEyebrow => '02 / ବୁଝନ୍ତୁ';

  @override
  String get onboardingUnderstandTitle => 'ସଂଖ୍ୟା,\nପ to ିବା ସହଜ କଲା';

  @override
  String get onboardingUnderstandBody =>
      'ପ୍ରତ୍ୟେକ ରିପୋର୍ଟ, ଏହାର ୟୁନିଟ୍ ଏବଂ ଆପଣଙ୍କର ରିପୋର୍ଟରୁ ବ୍ୟବଧାନ ଦେଖନ୍ତୁ । ଯେକ time ଣସି ସମୟରେ ମୂଳ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get onboardingTrackEyebrow => '03 / ଟ୍ରାକ୍ ଏବଂ ଅଂଶୀଦାର';

  @override
  String get onboardingTrackTitle =>
      'ପରିବର୍ତ୍ତନଗୁଡିକ ଦେଖନ୍ତୁ ।\nପ୍ରସଙ୍ଗ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get onboardingTrackBody =>
      'ସମୟ ସହିତ ଫଳାଫଳ ଅନୁସରଣ କରନ୍ତୁ ଏବଂ ଆପଣଙ୍କର କ୍ଲିନିକ୍ କ’ଣ ଦେଖିପାରିବେ ତାହା ବାଛନ୍ତୁ';

  @override
  String get onboardingNext => 'ପରବର୍ତ୍ତୀ';

  @override
  String get onboardingGetStarted => 'ଆରମ୍ଭ କର';

  @override
  String get uiSupportRequestSent => 'ସମର୍ଥନ ଅନୁରୋଧ ପଠାଯାଇଛି';

  @override
  String get uiTestNameAndResultAreRequired => 'ପରୀକ୍ଷା ନାମ ଏବଂ ଫଳାଫଳ ଆବଶ୍ୟକ';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD ଫର୍ମାଟରେ ଏକ ବ valid ଧ ସଂଗ୍ରହ ତାରିଖ ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'ଏହି ସଂଶୋଧନକୁ ସଞ୍ଚୟ କରିପାରିଲା ନାହିଁ । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiReportsUnavailable => 'ରିପୋର୍ଟ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiTryAgain042c86 => 'ପୁଣି ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiTwoReportsAreNeeded => 'ଦୁଇଟି ରିପୋର୍ଟ ଆବଶ୍ୟକ';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'ଫଳାଫଳ ତୁଳନା କରିବାକୁ ଏହି ପ୍ରୋଫାଇଲ୍ ପାଇଁ ଏକ ପୁରୁଣା ରିପୋର୍ଟ ଯୋଡନ୍ତୁ';

  @override
  String get uiCannotCompareYet => 'ଏପର୍ଯ୍ୟନ୍ତ ତୁଳନା କରିପାରିବ ନାହିଁ';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'ଏହି ରିପୋର୍ଟଗୁଡିକର ତୁଳନା ପାଇଁ କ match ଣସି ମେଳଣ ଫଳାଫଳ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'ରିପୋର୍ଟ ଲୋଡ୍ କରିବାକୁ ଅସମର୍ଥ । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiCouldNotOpenPhotosOrCamera =>
      'ଫଟୋ କିମ୍ବା କ୍ୟାମେରା ଖୋଲିପାରିଲା ନାହିଁ';

  @override
  String get uiCouldNotOpenCamera => 'କ୍ୟାମେରା ଖୋଲିପାରିଲା ନାହିଁ';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'ଏହି ପୃଷ୍ଠାଗୁଡିକ ପ୍ରସ୍ତୁତ କରିପାରିଲା ନାହିଁ । ଏକ ପ read ଼ା ନଥିବା ପୃଷ୍ଠା ପୁନ ake ଚେଷ୍ଟା କର ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କର';

  @override
  String get uiCouldNotAdjustThisPage => 'ଏହି ପୃଷ୍ଠା ସଜାଡି ପାରିଲା ନାହିଁ';

  @override
  String get uiNoChartableResultYet =>
      'ଏପର୍ଯ୍ୟନ୍ତ କ chart ଣସି ଚାର୍ଟେବଲ୍ ଫଳାଫଳ ନାହିଁ';

  @override
  String get uiProfiles => 'ପ୍ରୋଫାଇଲ୍';

  @override
  String get uiReports => 'ରିପୋର୍ଟ';

  @override
  String get uiShareLinks => 'ଲିଙ୍କ୍ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiAIChat => 'AI ଚାଟ୍';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'ଅଧିକାର ସାରାଂଶ ଲୋଡ୍ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'ବିଲିଂ ସ୍ଥିତି ସତେଜ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'ରସିଦ ଡାଉନଲୋଡ୍ ଶୀଘ୍ର ଉପଲବ୍ଧ ହେବ';

  @override
  String get uiSubtotal => 'ସବଟୋଟାଲ୍';

  @override
  String get uiDiscount => 'ରିହାତି';

  @override
  String get uiTotal => 'ସମୁଦାୟ';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'କ୍ରେଡିଟ୍ ପ୍ୟାକ୍ ଲୋଡ୍ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'ଏକ ଦେୟ କ୍ୟାପଚର ବିଚାରାଧୀନ ଅଛି । ଅନ୍ୟ ଏକ ଚେକଆଉଟ୍ ଆରମ୍ଭ କରିବା ପୂର୍ବରୁ ସ୍ଥିତି ସତେଜ କରନ୍ତୁ';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'କ୍ରେଡିଟ୍ ସଫଳତାର ସହିତ ପ୍ରୟୋଗ କରାଯାଇଥିଲା';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'କ୍ରମ ସୃଷ୍ଟି କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'ଦେୟ ଗ୍ରହଣ କରାଯାଇଛି କ୍ରେଡିଟ୍ ଯୋଡିବା ପୂର୍ବରୁ ସର୍ଭର ପୁନ iliation ନିର୍ମାଣକୁ ଅପେକ୍ଷା';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'ଦେୟ ବିଫଳ ହେଲା । ପ୍ରସ୍ତୁତ ହୋଇଗଲେ ଆପଣ ଚେକଆଉଟ୍ ପୁନ ry ଚେଷ୍ଟା କରିପାରିବେ';

  @override
  String get uiPaymentFailedTryAgain =>
      'ଦେୟ ବିଫଳ ହେଲା । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiCreditsAdded => 'କ୍ରେଡିଟ୍ ଯୋଡା ଯାଇଛି!';

  @override
  String get uiPromoCodeApplied => 'ପ୍ରୋମୋ କୋଡ୍ ପ୍ରୟୋଗ ହେଲା';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'ଦେୟ ଗ୍ରହଣ କରାଯାଇଛି, କିନ୍ତୁ ଏହି ଆଦେଶ ସମୀକ୍ଷା ପାଇଁ ବିଚାରାଧୀନ ଅଛି';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'ପୁନ iliation ନିର୍ମାଣ ସମୟରେ ଦେୟ ବିଫଳ ହେଲା';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'ଦେୟ ନିଶ୍ଚିତ ହୋଇଛି । ସର୍ଭର ପୁନ iliation ନିର୍ମାଣ ବିଚାରାଧୀନ ଅଛି';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'ଦେୟ ଯାଞ୍ଚ ହୋଇଛି । ପୁନ on ସମନ୍ୱୟ ବିଚାରାଧୀନ ଅଛି, ଦୟାକରି ଶୀଘ୍ର ସତେଜ କରନ୍ତୁ';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'ଦେୟ ଗ୍ରହଣ କରାଯାଇଛି କିନ୍ତୁ ଯାଞ୍ଚ ବିଚାରାଧୀନ ଅଛି । ଦୟାକରି ସ୍ଥିତି ସତେଜ କରନ୍ତୁ';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'ଯୋଜନା ଲୋଡ୍ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'ସଦସ୍ୟତା ସୃଷ୍ଟି କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'ସଦସ୍ୟତା ବିଫଳ ହେଲା । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiPlanUpgraded => 'ଯୋଜନା ଅପଗ୍ରେଡ୍!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'ଦେୟ ଗ୍ରହଣ କରାଯାଇଥିଲା କିନ୍ତୁ ଯାଞ୍ଚ ବିଫଳ ହେଲା । ଯୋଜନା ଶୀଘ୍ର ଅପଗ୍ରେଡ୍ ହେବ';

  @override
  String get uiNotificationsUnavailable => 'ବିଜ୍ଞପ୍ତିଗୁଡିକ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiAllQuietForNow => 'ବର୍ତ୍ତମାନ ପାଇଁ ସମସ୍ତେ ଚୁପ୍ ଅଛନ୍ତି';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'କିଛି ନୂଆ ଥିବାବେଳେ ରିପୋର୍ଟ୍ ଅପଡେଟ୍ ଏବଂ ସେୟାର୍ ରିମାଇଣ୍ଡର୍ ଏଠାରେ ଦେଖାଯିବ';

  @override
  String get uiNoUnreadUpdates => 'କ un ଣସି ପ read ା ଅପଡେଟ୍ ନାହିଁ';

  @override
  String get uiYouReAllCaughtUp => 'ତୁମେ ସମସ୍ତେ ଧରାପଡିଛ';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'ବିଜ୍ଞପ୍ତି ଲୋଡ୍ କରିବାକୁ ଅସମର୍ଥ । ସଂଯୁକ୍ତ ହେଲେ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiManageSharedLinks => 'ଅଂଶୀଦାର ଲିଙ୍କଗୁଡିକ ପରିଚାଳନା କରନ୍ତୁ';

  @override
  String get uiExportYourData => 'ଆପଣଙ୍କ ତଥ୍ୟ ଏକ୍ସପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get uiReadThePrivacyPolicy => 'ଗୋପନୀୟତା ନୀତି ପ Read ନ୍ତୁ';

  @override
  String get uiTermsOfUse => 'ବ୍ୟବହାର ସର୍ତ୍ତାବଳୀ';

  @override
  String get uiPrivacyPolicy => 'ଗୋପନୀୟତା ନୀତି';

  @override
  String get uiDateOfBirthOptional => 'ଜନ୍ମ ତାରିଖ, ବ al କଳ୍ପିକ';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'ସମ୍ପର୍କ 50 ଅକ୍ଷର କିମ୍ବା କମ୍ ହେବା ଜରୁରୀ';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'ପ୍ରୋଫାଇଲ୍ ସଞ୍ଚୟ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiReferralsUnavailable => 'ରେଫରାଲ୍ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiYourRewards => 'ତୁମର ପୁରସ୍କାର';

  @override
  String get uiReferralProgress => 'ରେଫରାଲ୍ ଅଗ୍ରଗତି';

  @override
  String get uiFriendsReferred => 'ସାଙ୍ଗମାନେ ରେଫର୍ କରିଛନ୍ତି';

  @override
  String get uiCreditsEarned => 'କ୍ରେଡିଟ୍ ଅର୍ଜନ';

  @override
  String get uiPendingRewards => 'ପୁରସ୍କାର ବିଚାରାଧୀନ ଅଛି';

  @override
  String get uiBlockedRewards => 'ଅବରୋଧିତ ପୁରସ୍କାର';

  @override
  String get uiInviteeBonus => 'ନିମନ୍ତ୍ରଣ ବୋନସ୍';

  @override
  String get uiFirstAnalysis => 'ପ୍ରଥମ ବିଶ୍ଳେଷଣ';

  @override
  String get uiFirstPurchase => 'ପ୍ରଥମେ କ୍ରୟ';

  @override
  String get uiMonthlyCap => 'ମାସିକ କ୍ୟାପ୍';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'ରେଫରାଲ୍ ଲୋଡ୍ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiReferralCodeCopied => 'ରେଫରାଲ୍ କୋଡ୍ କପି ହୋଇଛି';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'ଆପଣଙ୍କର ଇମେଲ୍ ଲିଙ୍କରୁ ପୁନ et ସେଟ୍ ଟୋକନ୍ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiEnterYourNewPassword => 'ଆପଣଙ୍କର ନୂତନ ପାସୱାର୍ଡ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'ପାସୱାର୍ଡ ପୁନ res ସେଟ୍ କରିବାକୁ ଅସମର୍ଥ । ଦୟାକରି ଏକ ନୂତନ ଲିଙ୍କ୍ ଅନୁରୋଧ';

  @override
  String get uiEnterYourEmailAddress => 'ଆପଣଙ୍କର ଇମେଲ୍ ଠିକଣା ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'ପୁନ res ସେଟ୍ ଲିଙ୍କ୍ ପଠାଇବାକୁ ଅସମର୍ଥ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiFailedToLoadSessions => 'ଅଧିବେଶନ ଲୋଡ୍ କରିବାରେ ବିଫଳ';

  @override
  String get uiFailedToRevokeSession => 'ଅଧିବେଶନ ପ୍ରତ୍ୟାହାର କରିବାରେ ବିଫଳ';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'ପାସୱାର୍ଡ ପରିବର୍ତ୍ତନ କରିବାକୁ ଅସମର୍ଥ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'ଡିଭାଇସ୍ ସେଟିଂସମୂହ ଖୋଲନ୍ତୁ ଏବଂ ଡକଲିଜର ପାଇଁ ବିଜ୍ଞପ୍ତିକୁ ଅନୁମତି ଦିଅନ୍ତୁ';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'ରିପୋର୍ଟଗୁଡିକ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'ପରୀକ୍ଷା ଫଳାଫଳ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'ଅଂଶୀଦାର କରିବାକୁ ଅତିକମରେ ଗୋଟିଏ ରିପୋର୍ଟ ଚୟନ କରନ୍ତୁ';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'ଅଂଶୀଦାର କରିବାକୁ ଅତିକମରେ ଗୋଟିଏ ପରୀକ୍ଷା ଫଳାଫଳ ଚୟନ କରନ୍ତୁ';

  @override
  String get uiLinkCopiedToClipboard => 'ଲିଙ୍କ୍ କ୍ଲିପବୋର୍ଡରେ କପି ହୋଇଛି';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'ଆକ୍ସେସ୍ କୋଡ୍ କ୍ଲିପବୋର୍ଡରେ କପି ହୋଇଛି';

  @override
  String get uiOnePerson => '1 ଜଣ';

  @override
  String uiPeopleCount(String count) {
    return '$count ଲୋକ';
  }

  @override
  String uiActionsFor(String name) {
    return '$name ପାଇଁ କାର୍ଯ୍ୟ';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'ପ୍ରୋଫାଇଲ୍ ସୁଇଚ୍ କରିବାକୁ ଅସମର୍ଥ । $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name କୁ ସୁଇଚ୍ ହୋଇଛି';
  }

  @override
  String get uiAnalyzeOnePage => '1 ପୃଷ୍ଠା ବିଶ୍ଳେଷଣ କରନ୍ତୁ';

  @override
  String uiAnalyzePages(String count) {
    return '$count ପୃଷ୍ଠାଗୁଡ଼ିକୁ ବିଶ୍ଳେଷଣ କରନ୍ତୁ';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'ଆପଣଙ୍କ ରିପୋର୍ଟରେ ଦେଖାଯାଇଥିବା କ୍ରମରେ ପୃଷ୍ଠାଗୁଡ଼ିକୁ ଡ୍ରାଗ୍ କରନ୍ତୁ';

  @override
  String get uiCheckEveryPage =>
      'ବିଶ୍ଳେଷଣ କରିବା ପୂର୍ବରୁ ପ୍ରତ୍ୟେକ ପୃଷ୍ଠା ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiOnePageAdded => '1 ପୃଷ୍ଠା ଯୋଡା ଯାଇଛି';

  @override
  String uiPagesAdded(String count) {
    return '$count ପୃଷ୍ଠାଗୁଡ଼ିକ ଯୋଗ କରାଯାଇଛି';
  }

  @override
  String get uiReorder => 'ରେକର୍ଡ';

  @override
  String uiPageNumber(String number) {
    return 'ପୃଷ୍ଠା $number';
  }

  @override
  String uiRemovePage(String number) {
    return 'ପୃଷ୍ଠା $number ଅପସାରଣ କରନ୍ତୁ';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · ପୃଷ୍ଠା $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'ଫସଲ ଧାର: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count ମନୋନୀତ ରିପୋର୍ଟଗୁଡିକ';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count ମନୋନୀତ ପରୀକ୍ଷା ଫଳାଫଳ';
  }

  @override
  String get uiAllCurrentFutureReports =>
      'ସମସ୍ତ ସାମ୍ପ୍ରତିକ ଏବଂ ଭବିଷ୍ୟତ ରିପୋର୍ଟଗୁଡିକ';

  @override
  String get uiNoExpiry => 'କ exp ଣସି ସମାପ୍ତି ନାହିଁ';

  @override
  String uiExpiresDate(String date) {
    return '$date ମିଆଦ ପୂର୍ଣ୍ଣ ହୁଏ';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'ଆକ୍ସେସ୍ କୋଡ୍ ଆବଶ୍ୟକ । ଲିଙ୍କ୍ ଠାରୁ ଏହାକୁ ପୃଥକ ଭାବରେ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiNoAccessCodeRequired => 'କ access ଣସି ପ୍ରବେଶ ସଂକେତ ଆବଶ୍ୟକ ନାହିଁ';

  @override
  String uiExpiresColonDate(String date) {
    return 'ମିଆଦ ପୂର୍ଣ୍ଣ: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name ର ରିପୋର୍ଟଗୁଡିକ ଅଂଶୀଦାର କରନ୍ତୁ';
  }

  @override
  String uiProfileReports(String name) {
    return '$name ର ରିପୋର୍ଟଗୁଡିକ';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count ମନୋନୀତ ଫଳାଫଳଗୁଡିକ';
  }

  @override
  String get uiAccessCodeRequiredShort => 'ଆକ୍ସେସ୍ କୋଡ୍ ଆବଶ୍ୟକ';

  @override
  String uiPastLinksCount(String count) {
    return 'ଅତୀତ ଲିଙ୍କ୍ · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return 'ମିଆଦ ପୂର୍ଣ୍ଣ $date';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'ପ୍ରତ୍ୟାହାର · $date ସୃଷ୍ଟି';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum ସକ୍ରିୟ ଲିଙ୍କଗୁଡ଼ିକର $current ବ୍ୟବହାର କରି';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename ଏବଂ ଏହାର ଗଚ୍ଛିତ ଫାଇଲକୁ ବିଲୋପ କରନ୍ତୁ? ଏହାକୁ ପୂର୍ବବତ୍ କରାଯାଇପାରିବ ନାହିଁ';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'ରିପୋର୍ଟ ବିଲୋପ କରିବାରେ ଅସମର୍ଥ: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'ସମସ୍ତ $count ରିପୋର୍ଟ ଏବଂ ସେମାନଙ୍କର ଗଚ୍ଛିତ ଫାଇଲଗୁଡ଼ିକୁ ସ୍ଥାୟୀଭାବେ ବିଲୋପ କରନ୍ତୁ? ଏହାକୁ ପୂର୍ବବତ୍ କରାଯାଇପାରିବ ନାହିଁ';
  }

  @override
  String get uiRecycleBinEmptied => 'ରିସାଇକ୍ଲି ବିନ୍ ଖାଲି ହେଲା';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted ରିପୋର୍ଟ ବିଲୋପ ହୋଇଛି । $failed ବିଲୋପ ହୋଇପାରିବ ନାହିଁ; ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'ରିସାଇକ୍ଲି ବିନ୍ ଖାଲି କରିବାକୁ ଅସମର୍ଥ: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'ପ୍ରୋଫାଇଲ୍: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'ସଂଗୃହିତ: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'ଅପଲୋଡ୍ ହୋଇଛି: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'ବିଲୋପ ହୋଇଛି: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'ସ୍ଥାୟୀ ବିଲୋପ: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'ବାକି ଦିନ: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer =>
      'ଡକଲିଜର ପାଇଁ ଆପ୍ ଲକ୍ ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'ଆପ୍ ଲକ୍ ବନ୍ଦ କରିବା ପୂର୍ବରୁ ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'ଆପଣଙ୍କର ସ୍ୱାସ୍ଥ୍ୟ ରେକର୍ଡଗୁଡିକ ଦେଖିବା ପାଇଁ ଡକଲିଜର ଅନଲକ୍ କରନ୍ତୁ';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'ଏକ ରିପୋର୍ଟ ଅପଲୋଡ୍ କରିବା ପୂର୍ବରୁ ଏକ ଡିଫଲ୍ଟ ପ୍ରୋଫାଇଲ୍ ସୃଷ୍ଟି କରନ୍ତୁ';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'ଆପଣଙ୍କର ଟାଇମଲାଇନ୍ ଦେଖିବା ପୂର୍ବରୁ ଏକ ଡିଫଲ୍ଟ ପ୍ରୋଫାଇଲ୍ ସୃଷ୍ଟି କରନ୍ତୁ';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'ବର୍ତ୍ତମାନ ପ୍ରୋଫାଇଲ୍ ଲୋଡ୍ କରିବାକୁ ଅସମର୍ଥ';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'ବର୍ତ୍ତମାନ ଅପଲୋଡ୍ କରିପାରିବ ନାହିଁ କାରଣ ପ୍ରୋଫାଇଲ୍ ଡାଟା ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ । ଦୟାକରି ନିଶ୍ଚିତ କରନ୍ତୁ ଯେ API ସର୍ଭର ଚାଲୁଛି ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'ବର୍ତ୍ତମାନ ସମୟ ସୀମା ଖୋଲିପାରିବ ନାହିଁ କାରଣ ପ୍ରୋଫାଇଲ୍ ତଥ୍ୟ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ । ଦୟାକରି ନିଶ୍ଚିତ କରନ୍ତୁ ଯେ API ସର୍ଭର ଚାଲୁଛି ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'ବର୍ତ୍ତମାନ ପ୍ରୋଫାଇଲ୍ ଲୋଡ୍ କରିବାକୁ ଅସମର୍ଥ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'ଅଂଶୀଦାର ଲିଙ୍କ୍ ଲୋଡ୍ କରିବାକୁ ଅସମର୍ଥ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiPasswordChanged => 'ପାସୱାର୍ଡ ବଦଳିଲା';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'ସେହି ରିପୋର୍ଟ ଖୋଲିବାକୁ ଅସମର୍ଥ । ରିପୋର୍ଟ ଲାଇବ୍ରେରୀ ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'ଆପଣଙ୍କର ଆକାଉଣ୍ଟ୍ ସମୀକ୍ଷା ଚାଲିଥିବାବେଳେ ଏହି କାର୍ଯ୍ୟ ସାମୟିକ ଭାବରେ ଉପଲବ୍ଧ ନୁହେଁ';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'ଏହି ବିଭାଗ ଖୋଲିବାକୁ ଅସମର୍ଥ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiAppLockIsUnavailable => 'ଆପ୍ ଲକ୍ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiDoclyzerIsLocked => 'ଡକଲିଜର ଲକ୍ ହୋଇଛି';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'ସଞ୍ଚିତ ଆପ୍ ଲକ୍ ସେଟିଂ ପ read ିପାରିଲା ନାହିଁ । ଜାରି ରଖିବାକୁ ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'ଜାରି ରଖିବାକୁ ଆପଣଙ୍କର ଡିଭାଇସ୍ ପାସକୋଡ୍ କିମ୍ବା ବାୟୋମେଟ୍ରିକ୍ସ ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'ଆପଣଙ୍କର ଖାତା ସମୀକ୍ଷା ଚାଲିଥିବାବେଳେ ଅପଲୋଡ୍ ଗୁଡିକ ସାମୟିକ ଭାବରେ ଉପଲବ୍ଧ ନୁହେଁ';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'ଏକ ଅପଲୋଡ୍ ଆରମ୍ଭ କରିବାକୁ ଅସମର୍ଥ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiJustNow => 'ବର୍ତ୍ତମାନ';

  @override
  String get uiAdditionalDetails => 'ଅତିରିକ୍ତ ବିବରଣୀ:';

  @override
  String get uiSaveCorrection => 'ସଂଶୋଧନ ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'ଫାଇଲ୍ ଖୋଲିପାରିଲା ନାହିଁ । ପ୍ରବେଶ ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'କ୍ୟାମେରା ଖୋଲିପାରିଲା ନାହିଁ । ଅନୁମତି ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'ଫଟୋ ଖୋଲିପାରିଲା ନାହିଁ । ଅନୁମତି ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'ମନୋନୀତ ଫାଇଲକୁ ପ୍ରବେଶ କରିପାରିଲା ନାହିଁ';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'ମନୋନୀତ ଫାଇଲକୁ ପ୍ରବେଶ କରିପାରିଲା ନାହିଁ';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'ସଂଯୋଗ ହଜିଗଲା । ଅପଲୋଡ୍ ସର୍ଭରରେ ପହଞ୍ଚିଥାଇପାରେ । ସମାନ ଫାଇଲକୁ ସୁରକ୍ଷିତ ଭାବରେ ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiCouldNotLoadExistingReport =>
      'ବିଦ୍ୟମାନ ରିପୋର୍ଟ ଲୋଡ୍ ହୋଇପାରିଲା ନାହିଁ';

  @override
  String get uiAddingTo => 'ସହିତ ଯୋଗ କରୁଛି';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'କିଛି ଫଳାଫଳ ସମୀକ୍ଷା ଆବଶ୍ୟକ କରେ । ତୁମର ମୂଳ ରିପୋର୍ଟ ସଞ୍ଚୟ ହୋଇଛି';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'ଆମେ ଏହି ଫର୍ମାଟ୍ ପ read ି ପାରିଲୁ ନାହିଁ । ଆପଣଙ୍କର ଫାଇଲ୍ ସେଭ୍ ହୋଇଛି';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'ରିପୋର୍ଟ ସଫଳତାର ସହିତ ବିଶ୍ଳେଷଣ କରାଯାଇଛି । ଫଳାଫଳ ଏବଂ ଧାରା ଉପଲବ୍ଧ';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'ତୁମର ରିପୋର୍ଟ ଏପର୍ଯ୍ୟନ୍ତ ବିଶ୍ଳେଷଣ କରାଯାଉଛି । ଏହାର ସ୍ଥିତି ଯାଞ୍ଚ କରିବାକୁ ଏହାକୁ ଖୋଲ';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'ପ୍ରକ୍ରିୟାକରଣ ବନ୍ଦ ହେଲା । ଆପଣଙ୍କର ଫାଇଲ୍ ସେଭ୍ ହୋଇଛି । ଆପଣ ପୁନ ry ଚେଷ୍ଟା କରିପାରିବେ';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'କ No ଣସି ବାହାର କରାଯାଇଥିବା ପରୀକ୍ଷା ମୂଲ୍ୟ ଯୋଗ କରାଯାଇ ନାହିଁ । ଆପଣ ତଥାପି ଡକ୍ୟୁମେଣ୍ଟ୍ ଖୋଲିପାରିବେ ଏବଂ ଅଂଶୀଦାର କରିପାରିବେ । ତୁମର ଧାରା ଅପରିବର୍ତ୍ତିତ';

  @override
  String get uiYourOriginalIsSaved => 'ତୁମର ମୂଳ ସଞ୍ଚୟ ହୋଇଛି';

  @override
  String get uiInitialUpload => 'ପ୍ରାରମ୍ଭିକ ଅପଲୋଡ୍';

  @override
  String get uiParsedSuccessfully => 'ସଫଳତାର ସହିତ ପାର୍ସ ହୋଇଛି';

  @override
  String get uiParsingFailed => 'ପାର୍ସିଂ ବିଫଳ ହେଲା';

  @override
  String get uiExtractionIncomplete => 'ନିଷ୍କାସନ ଅସମ୍ପୂର୍ଣ୍ଣ';

  @override
  String get uiTransientFailure => 'କ୍ଷଣସ୍ଥାୟୀ ବିଫଳତା';

  @override
  String get uiTerminalFailure => 'ଟର୍ମିନାଲ୍ ବିଫଳତା';

  @override
  String get uiFailedToLoadAttemptHistory => 'ଚେଷ୍ଟା ଇତିହାସ ଲୋଡ୍ କରିବାରେ ବିଫଳ';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'ଏହି ରିପୋର୍ଟର ଫାଇଲ୍ ଆଉ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiCompareResults => 'ଫଳାଫଳ ତୁଳନା କରନ୍ତୁ';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'କ difference ଣସି ପାର୍ଥକ୍ୟ ଗଣନା କରାଯାଇ ନାହିଁ । ସୁସଙ୍ଗତତା ନିଶ୍ଚିତକରଣ ଆବଶ୍ୟକ କରେ';

  @override
  String get uiUnitNotRecorded => 'ୟୁନିଟ୍ ରେକର୍ଡ ହୋଇନାହିଁ';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'ଏହି ରିପୋର୍ଟଗୁଡିକ ମଧ୍ୟରେ କ numer ଣସି ସାଂଖ୍ୟିକ ପରିବର୍ତ୍ତନ ନାହିଁ';

  @override
  String get uiUnableToRestore => 'ପୁନରୁଦ୍ଧାର କରିବାକୁ ଅସମର୍ଥ:';

  @override
  String get uiEnterAGiftVoucherCode => 'ଏକ ଉପହାର ଭାଉଚର କୋଡ୍ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiApplyVoucher => 'ଭାଉଚର୍ ପ୍ରୟୋଗ କରନ୍ତୁ';

  @override
  String get uiNotAvailable => 'ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiViewReceipt => 'ରସିଦ ଦେଖନ୍ତୁ';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'ଉପହାର ଭାଉଚର ଅବ alid ଧ କିମ୍ବା ପୂର୍ବରୁ ମୁକ୍ତ ହୋଇସାରିଛି';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'ଉପହାର ଭାଉଚର୍ ପୂର୍ବରୁ ମୁକ୍ତ ହୋଇସାରିଛି';

  @override
  String get uiGiftVoucherHasBeenVoided => 'ଉପହାର ଭାଉଚରକୁ ବାତିଲ କରାଯାଇଛି';

  @override
  String get uiGiftVoucherHasExpired => 'ଉପହାର ଭାଉଚରର ସମୟ ସମାପ୍ତ ହୋଇଛି';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'ଏହି ଉପହାର ଭାଉଚରକୁ ମୁକ୍ତ କରିବାକୁ ଅସମର୍ଥ';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'ଏହି ଉପହାର ଭାଉଚରକୁ ମୁକ୍ତ କରିବାକୁ ଅସମର୍ଥ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiEnterAPromoCodeToApply =>
      'ଆବେଦନ କରିବାକୁ ଏକ ପ୍ରୋମୋ କୋଡ୍ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiPromoCodeNotFound => 'ପ୍ରୋମୋ କୋଡ୍ ମିଳିଲା ନାହିଁ';

  @override
  String get uiPromoCodeIsInactive => 'ପ୍ରୋମୋ କୋଡ୍ ନିଷ୍କ୍ରିୟ ଅଟେ';

  @override
  String get uiPromoCodeHasExpired => 'ପ୍ରୋମୋ କୋଡ୍ ମିଆଦ ପୂର୍ଣ୍ଣ ହୋଇଛି';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'ଏହି ପ୍ୟାକ୍ ପାଇଁ ପ୍ରୋମୋ କୋଡ୍ ପ୍ରଯୁଜ୍ୟ ନୁହେଁ';

  @override
  String get uiPromoCodeUsageLimitReached =>
      'ପ୍ରୋମୋ କୋଡ୍ ବ୍ୟବହାର ସୀମା ପହଞ୍ଚିଛି';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'ଆପଣ ଏହି ପ୍ରୋମୋ କୋଡ୍ ବ୍ୟବହାର କରିସାରିଛନ୍ତି';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'ପ୍ରୋମୋ କୋଡ୍ ପ୍ରୟୋଗ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'କ୍ରେଡିଟ୍ ଯୋଡିବା ପୂର୍ବରୁ ସମୀକ୍ଷା ପାଇଁ ଏହି କ୍ରମକୁ ଫ୍ଲାଗ୍ କରାଯାଇଥିଲା';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'ପୁନ iliation ନିର୍ମାଣ ସମୟରେ ଦେୟ ବିଫଳ ହେଲା । ଆପଣ ନିରାପଦରେ ପୁନ ry ଚେଷ୍ଟା କରିପାରିବେ';

  @override
  String get uiAwaitingCapture => 'ଧରିବାକୁ ଅପେକ୍ଷା କରିଛି';

  @override
  String get uiLastPaymentFailed => 'ଶେଷ ଦେୟ ବିଫଳ ହେଲା';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'ଆପଣ ସୁରକ୍ଷିତ ଭାବରେ ଚେକଆଉଟ୍ ପୁନ ry ଚେଷ୍ଟା କରିପାରିବେ';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'ସବସ୍କ୍ରିପସନ୍ ପାଇଁ ପ୍ରୋମୋ କୋଡ୍ ଏପର୍ଯ୍ୟନ୍ତ ସମର୍ଥିତ ନୁହେଁ';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'ରପ୍ତାନି ଡାଉନଲୋଡ୍ କରିପାରିଲା ନାହିଁ । ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'ମୂଳ ରିପୋର୍ଟ କିମ୍ବା ପରୀକ୍ଷା ଫଳାଫଳ ଚୟନ କରନ୍ତୁ';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'ରପ୍ତାନି ଅନୁରୋଧ । ସତେଜ କରିବାକୁ \"ସ୍ଥିତି ଯାଞ୍ଚ କରନ୍ତୁ\" ଟ୍ୟାପ୍ କରନ୍ତୁ';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'ରପ୍ତାନି ଅନୁରୋଧ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'ରପ୍ତାନି ପ୍ରସ୍ତୁତ । ଉପଲବ୍ଧ URL ଡାଉନଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'ରପ୍ତାନି ସ୍ଥିତି ଯାଞ୍ଚ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'ଖାତା ବନ୍ଦ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiPrepareExport => 'ରପ୍ତାନି ପ୍ରସ୍ତୁତ କରନ୍ତୁ';

  @override
  String get uiSaveExport => 'ରପ୍ତାନି ସଞ୍ଚୟ କରନ୍ତୁ';

  @override
  String get uiPrepareExportAgain => 'ପୁନର୍ବାର ରପ୍ତାନି ପ୍ରସ୍ତୁତ କରନ୍ତୁ';

  @override
  String get uiAllDates => 'ସମସ୍ତ ତାରିଖ';

  @override
  String get uiPreparingAccountDetails => 'ଖାତା ବିବରଣୀ ପ୍ରସ୍ତୁତ କରୁଛି';

  @override
  String get uiFamilyMemberProfiles => 'ପରିବାର ସଦସ୍ୟ ପ୍ରୋଫାଇଲ୍';

  @override
  String get uiUploadedReports => 'ରିପୋର୍ଟଗୁଡିକ ଅପଲୋଡ୍ ହୋଇଛି';

  @override
  String get uiDownloadReady => 'ଡାଉନଲୋଡ୍ ପ୍ରସ୍ତୁତ';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'ଏହି ଉପକରଣରେ ରିପୋର୍ଟ ବିଜ୍ଞପ୍ତି ସକ୍ଷମ ହୋଇଛି';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'ଉପକରଣ ସେଟିଂସମୂହ ଖୋଲିଲା । ଡକଲିଜର ପାଇଁ ବିଜ୍ଞପ୍ତିକୁ ଅନୁମତି ଦିଅନ୍ତୁ, ତାପରେ ଏଠାରେ ଫେରନ୍ତୁ';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'ବିଜ୍ଞପ୍ତିଗୁଡିକ ଏପର୍ଯ୍ୟନ୍ତ ବନ୍ଦ ଅଛି । ରିପୋର୍ଟ ଅଦ୍ୟତନ ଗ୍ରହଣ କରିବାକୁ ସେମାନଙ୍କୁ ଡିଭାଇସ୍ ସେଟିଂସମୂହରେ ଅନୁମତି ଦିଅନ୍ତୁ';

  @override
  String get uiPreferencesSaved => 'ପସନ୍ଦଗୁଡିକ ସଞ୍ଚୟ ହୋଇଛି';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'ଆପଣଙ୍କର ଆକାଉଣ୍ଟ୍ ପସନ୍ଦ ସଞ୍ଚୟ ହୋଇଛି, କିନ୍ତୁ ଏହି ଡିଭାଇସ୍ ମାର୍କେଟିଂ ପୁସ୍ ପାଇଁ ପଞ୍ଜୀକରଣ ଶେଷ କରିନାହିଁ । ଏହି ଡିଭାଇସରେ ମାର୍କେଟିଂ ଅବରୋଧ ହୋଇ ରହିଛି; ବିଜ୍ଞପ୍ତି ଅନୁମତି ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ସଞ୍ଚୟ କରିବାକୁ ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'ଆପଣଙ୍କର ଖାତା ପସନ୍ଦ ସଞ୍ଚୟ ହୋଇଛି । ଏହି ଡିଭାଇସ୍ ଏପର୍ଯ୍ୟନ୍ତ ଏହାର ସ୍ଥାନୀୟ ପସନ୍ଦ ନିଶ୍ଚିତ କରିପାରିବ ନାହିଁ, କିନ୍ତୁ ମାର୍କେଟିଂ ଆକାଉଣ୍ଟ୍ ସ୍ତରରେ ଅବରୋଧିତ';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'ଆପଣଙ୍କର ଆକାଉଣ୍ଟ୍ ପସନ୍ଦ ସଞ୍ଚୟ ହୋଇଛି, କିନ୍ତୁ ଏହି ଡିଭାଇସ୍ ମାର୍କେଟିଂ ପୁସ୍ ସକ୍ଷମ କରିପାରିବ ନାହିଁ । ବିଜ୍ଞପ୍ତି ଅନୁମତି ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'ସଞ୍ଚୟ ବହୁତ ସମୟ ନେଇଗଲା । ଆପଣଙ୍କର ସଂଯୋଗ ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiReportReadyForReview => 'ସମୀକ୍ଷା ପାଇଁ ପ୍ରସ୍ତୁତ ରିପୋର୍ଟ କରନ୍ତୁ';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'ଯେତେବେଳେ ଆପଣଙ୍କର ଫଳାଫଳ ଯାଞ୍ଚ କରିବାକୁ ପ୍ରସ୍ତୁତ ଅଛି ଜାଣନ୍ତୁ';

  @override
  String get uiUploadUpdates => 'ଅଦ୍ୟତନଗୁଡିକ ଅପଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'ଯଦି ଏକ ଅପଲୋଡ୍ ଧ୍ୟାନ ଆବଶ୍ୟକ କରେ ତେବେ ଏକ ସନ୍ଦେଶ ପାଆନ୍ତୁ';

  @override
  String get uiSharedLinkReminders => 'ଅଂଶୀଦାର ଲିଙ୍କ୍ ସ୍ମାରକଗୁଡିକ';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'ଯେତେବେଳେ ଏକ ଲିଙ୍କ୍ ସମାପ୍ତ ହେବାକୁ ଯାଉଛି ଶୁଣ';

  @override
  String get uiSecurityAlerts => 'ସୁରକ୍ଷା ଆଲର୍ଟ';

  @override
  String get uiRequiredForAccountSafety => 'ଖାତା ସୁରକ୍ଷା ପାଇଁ ଆବଶ୍ୟକ';

  @override
  String get uiComplianceNotices => 'ଅନୁପାଳନ ବିଜ୍ଞପ୍ତିଗୁଡିକ';

  @override
  String get uiRequiredAccountInformation => 'ଆବଶ୍ୟକ ଖାତା ସୂଚନା';

  @override
  String get uiMarketingPushNotifications => 'ମାର୍କେଟିଂ ପୁସ୍ ବିଜ୍ଞପ୍ତିଗୁଡିକ';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ଅଫର୍ ଏବଂ ଘୋଷଣା ଏହି ପସନ୍ଦ ସଞ୍ଚୟ କରିବା ମଧ୍ୟ ଏହାକୁ ଏହି ଉପକରଣରେ ପ୍ରୟୋଗ କରେ';

  @override
  String get uiProductUpdates => 'ଉତ୍ପାଦ ଅଦ୍ୟତନଗୁଡ଼ିକ';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'ଡକଲିଜର ବିଷୟରେ ବ tion କଳ୍ପିକ ଖବର';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'ସର୍ଭର ସହିତ ସଂଯୋଗ ହୋଇପାରିବ ନାହିଁ । ଦୟାକରି ଆପଣଙ୍କର ଇଣ୍ଟରନେଟ୍ କିମ୍ବା API ସର୍ଭର ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'ଆପଣଙ୍କର ଖାତା ସମୀକ୍ଷା ଚାଲିଥିବାବେଳେ ପ୍ରୋଫାଇଲ୍ ଅଦ୍ୟତନଗୁଡିକ ସାମୟିକ ଭାବରେ ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiUse100CharactersOrFewer => '100 ଅକ୍ଷର କିମ୍ବା କମ୍ ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiAddProfile => 'ପ୍ରୋଫାଇଲ୍ ଯୋଡନ୍ତୁ';

  @override
  String get uiCreateProfile => 'ପ୍ରୋଫାଇଲ୍ ସୃଷ୍ଟି କରନ୍ତୁ';

  @override
  String get uiUpdateTheirDetails => 'ସେମାନଙ୍କର ବିବରଣୀ ଅଦ୍ୟତନ କରନ୍ତୁ';

  @override
  String get uiWhoIsThisProfileFor => 'ଏହି ପ୍ରୋଫାଇଲ୍ କାହା ପାଇଁ?';

  @override
  String get uiNotSelected => 'ମନୋନୀତ ହୋଇନାହିଁ';

  @override
  String get uiEnterAReferralCode => 'ଏକ ରେଫରାଲ୍ କୋଡ୍ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'ରେଫରାଲ୍ ପ୍ରୟୋଗ । ଇମେଲ ଯାଞ୍ଚ ପରେ ବୋନସ ଅନଲକ୍ କରେ';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'ରେଫରାଲ୍ ପ୍ରୟୋଗ । ବୋନସ୍ କ୍ରେଡିଟ୍ ପ୍ରସ୍ତୁତ';

  @override
  String get uiApplyCode => 'କୋଡ୍ ପ୍ରୟୋଗ କରନ୍ତୁ';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'ଆପଣ ନିଜର ରେଫରାଲ୍ କୋଡ୍ ପ୍ରୟୋଗ କରିପାରିବେ ନାହିଁ';

  @override
  String get uiReferralCodeIsInvalid => 'ରେଫରାଲ୍ କୋଡ୍ ଅବ alid ଧ ଅଟେ';

  @override
  String get uiFailedToApplyReferralCode => 'ରେଫରାଲ୍ କୋଡ୍ ପ୍ରୟୋଗ କରିବାରେ ବିଫଳ';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'ରେଫରାଲ୍ କୋଡ୍ ପ୍ରୟୋଗ କରିବାରେ ବିଫଳ । ଦୟାକରି ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiThisDevice => 'ଏହି ଉପକରଣ';

  @override
  String get uiSignedInDevice => 'ସାଇନ୍ ଇନ୍ ଡିଭାଇସ୍';

  @override
  String get uiUnknownDevice => 'ଅଜ୍ଞାତ ଉପକରଣ';

  @override
  String get uiRevokeAndLogOut => 'ପ୍ରତ୍ୟାହାର ଏବଂ ଲଗ୍ ଆଉଟ୍ କରନ୍ତୁ';

  @override
  String get uiRevokeSessionca8440 => 'ଅଧିବେଶନ ପ୍ରତ୍ୟାହାର କରନ୍ତୁ';

  @override
  String get uiEnterYourCurrentPassword =>
      'ଆପଣଙ୍କର ସାମ୍ପ୍ରତିକ ପାସୱାର୍ଡ ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'ଅକ୍ଷର, ଛୋଟ ଅକ୍ଷର, ଏକ ସଂଖ୍ୟା ଏବଂ ଏକ ବିଶେଷ ବର୍ଣ୍ଣ ସହିତ ଅତିକମରେ 8 ଅକ୍ଷର ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiChooseADifferentPassword => 'ଏକ ଭିନ୍ନ ପାସୱାର୍ଡ ବାଛନ୍ତୁ';

  @override
  String get uiNewPasswordsDoNotMatch => 'ନୂତନ ପାସୱାର୍ଡଗୁଡ଼ିକ ମେଳ ଖାଉ ନାହିଁ';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'ଆପଣ ସମସ୍ତ ଉପଲବ୍ଧ ଅପଲୋଡ୍ କ୍ରେଡିଟ୍ ବ୍ୟବହାର କରିଛନ୍ତି । ଅଧିକ ଯୋଗ କରିବାକୁ ଯୋଜନା ଏବଂ କ୍ରେଡିଟ୍ ପରିଦର୍ଶନ କରନ୍ତୁ';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'ଡକଲିଜର ପାଇଁ ବିଜ୍ଞପ୍ତିଗୁଡିକ ଅକ୍ଷମ ହୋଇଛି । ରିପୋର୍ଟ-ପ୍ରସ୍ତୁତ ଏବଂ ଖାତା ଅଦ୍ୟତନକୁ ଅନୁମତି ଦେବା ପାଇଁ ଉପକରଣ ସେଟିଂସମୂହ ଖୋଲନ୍ତୁ । ଯଦି ଆପଣ ଏହାକୁ ବାଛି ନାହାଁନ୍ତି ମାର୍କେଟିଂ ବନ୍ଦ ହୋଇଯାଏ';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'ଏହି ଡିଭାଇସରେ ରିପୋର୍ଟ-ପ୍ରସ୍ତୁତ ଏବଂ ଆକାଉଣ୍ଟ୍ ଅପଡେଟ୍ ପାଆନ୍ତୁ । ଯଦି ଆପଣ ଏହାକୁ ବାଛି ନାହାଁନ୍ତି ମାର୍କେଟିଂ ବନ୍ଦ ହୋଇଯାଏ';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'ଏହି ଡିଭାଇସ୍ ପାଇଁ ବିଜ୍ଞପ୍ତିଗୁଡିକ ବନ୍ଦ ଅଛି । ରିପୋର୍ଟ-ପ୍ରସ୍ତୁତ ଏବଂ ଖାତା ଅଦ୍ୟତନ ଗ୍ରହଣ କରିବାକୁ ସେଟିଂସମୂହ ଖୋଲନ୍ତୁ';

  @override
  String get uiBlockedExpiredRevoked => 'ଅବରୋଧିତ (ମିଆଦ ପୂର୍ଣ୍ଣ / ପ୍ରତ୍ୟାହାର)';

  @override
  String get uiFailedToLoadPolicy => 'ନୀତି ଲୋଡ୍ କରିବାରେ ବିଫଳ';

  @override
  String get uiUploadPaused => 'ଅପଲୋଡ୍ ବିରତ';

  @override
  String get uiSevenDays => '7 ଦିନ';

  @override
  String get uiThirtyDays => '30 ଦିନ';

  @override
  String get uiNinetyDays => '90 ଦିନ';

  @override
  String get uiUploadingAClearReport => 'ଏକ ସ୍ପଷ୍ଟ ରିପୋର୍ଟ ଅପଲୋଡ୍ କରୁଛି';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'PDF, ଫଟୋ ଏବଂ ଏକାଧିକ ପୃଷ୍ଠା';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'ଏକ PDF ବାଛନ୍ତୁ କିମ୍ବା ପ୍ରତ୍ୟେକ ପୃଷ୍ଠାର ସ୍ପଷ୍ଟ ଫଟୋ ନିଅନ୍ତୁ । ପୁରା ପୃଷ୍ଠାକୁ ଫ୍ରେମରେ ରଖ, ଚମକରୁ ଦୂରେଇ ରୁହ, ଏବଂ ବିଶ୍ଳେଷଣ କରିବା ପୂର୍ବରୁ ପୃଷ୍ଠା କ୍ରମ ଯାଞ୍ଚ କର । ଆପଣ ମୂଳ ବିରୁଦ୍ଧରେ ବାହାର କରାଯାଇଥିବା ମୂଲ୍ୟଗୁଡ଼ିକୁ ସଂଶୋଧନ କରିପାରିବେ';

  @override
  String get uiCorrectingAResult => 'ଏକ ଫଳାଫଳ ସଂଶୋଧନ କରିବା';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'ମୂଳ ବିରୁଦ୍ଧରେ ମୂଲ୍ୟ ସମୀକ୍ଷା କରନ୍ତୁ';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'ଏକ ରିପୋର୍ଟ ଖୋଲନ୍ତୁ, ମୂଳ ବିରୁଦ୍ଧରେ ପ୍ରତ୍ୟେକ ବାହାର କରାଯାଇଥିବା ପରୀକ୍ଷଣକୁ ସମୀକ୍ଷା କରନ୍ତୁ ଏବଂ ଭୁଲ ଭାବରେ ପ read ଼ାଯାଇଥିବା ଯେକ value ଣସି ମୂଲ୍ୟ, ଏକକ, କିମ୍ବା ତାରିଖ ସଂଶୋଧନ କରନ୍ତୁ । ଆପଣ ଟ୍ରେଣ୍ଡ ଉପରେ ନିର୍ଭର କରିବା ପୂର୍ବରୁ ଅନିଶ୍ଚିତ ଫଳାଫଳଗୁଡିକ ଯାଞ୍ଚ କରାଯିବା ଉଚିତ୍';

  @override
  String get uiManagingFamilyRecords => 'ପାରିବାରିକ ରେକର୍ଡଗୁଡିକ ପରିଚାଳନା';

  @override
  String get uiProfilesAccessAndPermissions => 'ପ୍ରୋଫାଇଲ୍, ପ୍ରବେଶ ଏବଂ ଅନୁମତି';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'ପ୍ରୋଫାଇଲ୍ ସୃଷ୍ଟି ଏବଂ ସୁଇଚ୍ କରିବାକୁ ପରିବାର ବ୍ୟବହାର କରନ୍ତୁ । ଏକ ରିପୋର୍ଟ ଅପଲୋଡ୍ କିମ୍ବା ଅଂଶୀଦାର କରିବା ପୂର୍ବରୁ ମନୋନୀତ ବ୍ୟକ୍ତିଙ୍କୁ ଯାଞ୍ଚ କରନ୍ତୁ । କେବଳ ରେକର୍ଡଗୁଡିକ ପରିଚାଳନା କରନ୍ତୁ ଯାହାକୁ ଆପଣ ପ୍ରବେଶ କରିବାକୁ ଅନୁମତିପ୍ରାପ୍ତ';

  @override
  String get uiSharingAndRevokingLinks => 'ଲିଙ୍କ୍ ଅଂଶୀଦାର ଏବଂ ପ୍ରତ୍ୟାହାର';

  @override
  String get uiControlTheRecordsYouShare =>
      'ଆପଣ ଅଂଶୀଦାର କରୁଥିବା ରେକର୍ଡଗୁଡ଼ିକୁ ନିୟନ୍ତ୍ରଣ କରନ୍ତୁ';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'ଆପଣ ଅଂଶୀଦାର କରିବାକୁ ଚାହୁଁଥିବା ରିପୋର୍ଟ କିମ୍ବା ଫଳାଫଳ ଚୟନ କରନ୍ତୁ, ସମାପ୍ତି ସମୀକ୍ଷା କରନ୍ତୁ ଏବଂ ପ୍ରବେଶ ସଂକେତକୁ ସମୀକ୍ଷା କରନ୍ତୁ, ତାପରେ ଲିଙ୍କ୍ ଏବଂ କୋଡ୍ ପୃଥକ ଭାବରେ ପଠାନ୍ତୁ । ଯେତେବେଳେ ପ୍ରବେଶ ଆଉ ଆବଶ୍ୟକ ହୁଏ ନାହିଁ, ଅଂଶୀଦାର ଲିଙ୍କରୁ ଏକ ସକ୍ରିୟ ଲିଙ୍କ୍ ପ୍ରତ୍ୟାହାର କରନ୍ତୁ';

  @override
  String get uiInformationYouProvide => 'ଆପଣ ପ୍ରଦାନ କରୁଥିବା ସୂଚନା';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'ଖାତା ବିବରଣୀ ଏବଂ ପରିବାର ପ୍ରୋଫାଇଲ୍ ଚିହ୍ନଟ କରେ ଯାହାର ରେକର୍ଡ ଆପଣ ପରିଚାଳନା କରନ୍ତି । ଅପଲୋଡ୍ ହୋଇଥିବା ଦଲିଲଗୁଡ଼ିକ ସମ୍ବେଦନଶୀଳ ସ୍ୱାସ୍ଥ୍ୟ ସୂଚନା ଧାରଣ କରିପାରେ';

  @override
  String get uiSharingControls => 'ନିୟନ୍ତ୍ରଣ ଅଂଶୀଦାର';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'ପ୍ରତ୍ୟେକ ଲିଙ୍କ୍ ର ବିଷୟବସ୍ତୁ, ସମାପ୍ତି ଏବଂ ପ୍ରବେଶ ସେଟିଂସମୂହ ସମୀକ୍ଷା କରନ୍ତୁ । ଆପଣଙ୍କର ଖାତା ସେଟିଂସମୂହରୁ ସକ୍ରିୟ ଲିଙ୍କ୍ ପରିଚାଳନା କରନ୍ତୁ';

  @override
  String get uiExportAndAccountChoices => 'ରପ୍ତାନି ଏବଂ ଖାତା ପସନ୍ଦ';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'ରେକର୍ଡଗୁଡିକ ରପ୍ତାନି କରିବାକୁ କିମ୍ବା ଏକ ଖାତା ବିଲୋପ ଅନୁରୋଧ ଆରମ୍ଭ କରିବାକୁ ସେଟିଂସମୂହ ବ୍ୟବହାର କରନ୍ତୁ । ଧାରଣ ବିବରଣୀଗୁଡିକ ସମ୍ପୂର୍ଣ୍ଣ ନୀତିରେ ଅଛି';

  @override
  String get uiEducationalScope => 'ଶିକ୍ଷାଗତ ପରିସର';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'ଡକଲିଜର ରିପୋର୍ଟଗୁଡିକ ସଂଗଠିତ କରେ ଏବଂ ସମୟ ସହିତ ଫଳାଫଳ ଦେଖାଏ । ଶିକ୍ଷାଗତ ବ୍ୟାଖ୍ୟା ଡାକ୍ତରୀ ପରାମର୍ଶ କିମ୍ବା ନିରାକରଣ ନୁହେଁ';

  @override
  String get uiReviewYourRecords => 'ଆପଣଙ୍କର ରେକର୍ଡଗୁଡିକ ସମୀକ୍ଷା କରନ୍ତୁ';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'ମୂଳ ରିପୋର୍ଟ ବିରୁଦ୍ଧରେ ବାହାର କରାଯାଇଥିବା ମୂଲ୍ୟ, ଏକକ ଏବଂ ତାରିଖ ଯାଞ୍ଚ କରନ୍ତୁ । ତୁମର ଫଳାଫଳ ବିଷୟରେ ଏକ ସ୍ୱାସ୍ଥ୍ୟ ସେବା ବୃତ୍ତିଗତଙ୍କୁ ପଚାର';

  @override
  String get uiManageAndShareResponsibly =>
      'ଦାୟିତ୍ ibly ବୋଧକ ଭାବରେ ପରିଚାଳନା ଏବଂ ଅଂଶୀଦାର କରନ୍ତୁ';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'କେବଳ ରେକର୍ଡଗୁଡିକ ପରିଚାଳନା କରନ୍ତୁ ଯାହାକୁ ଆପଣ ପ୍ରବେଶ କରିବାକୁ ଅନୁମତିପ୍ରାପ୍ତ । ବାଣ୍ଟିବା ପୂର୍ବରୁ ମନୋନୀତ ସୂଚନା ଏବଂ ପ୍ରାପ୍ତକର୍ତ୍ତା ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiPrivacyPolicy7ceacd => 'ଗୋପନୀୟତା ନୀତି';

  @override
  String get uiTermsOfUse8a069e => 'ବ୍ୟବହାର ସର୍ତ୍ତାବଳୀ';

  @override
  String get uiOpenPrivacyControls => 'ଗୋପନୀୟତା ନିୟନ୍ତ୍ରଣ ଖୋଲନ୍ତୁ';

  @override
  String get uiGetHelpWithTheApp => 'ଆପ୍ ସହିତ ସାହାଯ୍ୟ ନିଅନ୍ତୁ';

  @override
  String get uiExportYourDataInAccountSettings =>
      'ଖାତା ସେଟିଂସମୂହରେ ଆପଣଙ୍କର ତଥ୍ୟ ରପ୍ତାନି କରନ୍ତୁ';

  @override
  String get uiYOURDATACHOICES => 'ଆପଣଙ୍କର ତଥ୍ୟ ଏବଂ ଚୟନ';

  @override
  String get uiUSINGDOCLYZER => 'ଡୋକଲାଇଜର ବ୍ୟବହାର';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'ଆପଣ ଡକ୍ଲିଜରରେ ରଖୁଥିବା ସୂଚନା\nବୁ .ନ୍ତୁ';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'ଆପର ଭୂମିକା ବିଷୟରେ ଏକ ସ୍ପଷ୍ଟ ବୁ understanding ାମଣା';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name ରୁ $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · ସର୍ବଶେଷ $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'ଏହି ଲାଇବ୍ରେରୀ ଆରମ୍ଭ କରିବା ପାଇଁ $name ପାଇଁ ଏକ ରିପୋର୍ଟ ଅପଲୋଡ୍ କରନ୍ତୁ';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP ଠିକଣା: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'ସାଇନ୍ ଇନ୍: $date';
  }

  @override
  String get uiUnknown => 'ଅଜ୍ଞାତ';

  @override
  String uiResultsFor(String name) {
    return '$name ପାଇଁ ଫଳାଫଳ';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count ଲ୍ୟାବ ପାରାମିଟରଗୁଡିକ ଟ୍ରାକ୍ ହୋଇଛି';
  }

  @override
  String uiSampledDate(String date) {
    return 'ନମୁନା $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'ସଂଗ୍ରହ ତାରିଖ: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'ଲ୍ୟାବ୍ ପରିସର: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI ଏହି ପରିସରକୁ $range ଭାବରେ ପ read ଼ିଲା । ମୁଦ୍ରିତ ପାଠ: $printed । ଏହି ତୁଳନା ଉପରେ ନିର୍ଭର କରିବା ପୂର୍ବରୁ ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount ପ୍ରସ୍ତୁତ';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count କ୍ରେଡିଟ୍';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'ଏହି ଆକାଉଣ୍ଟରେ ଏକ ରେଫରାଲ୍ କୋଡ୍ ପ୍ରୟୋଗ ହୋଇସାରିଛି';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ଆପ୍ ଲକ୍ ଅନ୍ କରିବା ପୂର୍ବରୁ ଏକ ଡିଭାଇସ୍ ପାସକୋଡ୍ ସେଟ୍ କରନ୍ତୁ';

  @override
  String get uiLanguagePreferenceNotSaved => 'ଭାଷା ପସନ୍ଦ ସଞ୍ଚୟ ହୋଇନାହିଁ';

  @override
  String get uiExportUnavailable => 'ରପ୍ତାନି ଉପଲବ୍ଧ ନାହିଁ';

  @override
  String get uiUnreadableImage => 'ପଠନୀୟ ପ୍ରତିଛବି';

  @override
  String uiStatusWithValue(String status) {
    return 'ସ୍ଥିତି: $status';
  }

  @override
  String get uiPending => 'ବିଚାରାଧୀନ ଅଛି';

  @override
  String get uiCompleted => 'ସମାପ୍ତ';

  @override
  String get uiFailed => 'ବିଫଳ';

  @override
  String get uiInactive => 'ନିଷ୍କ୍ରିୟ';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'ଆପଣଙ୍କର ରିପୋର୍ଟ ଏବଂ ପ୍ରୋଫାଇଲ୍ ରଖିବା ପାଇଁ $date ପୂର୍ବରୁ ପୁନ ore ସ୍ଥାପନ କରନ୍ତୁ';
  }

  @override
  String get uiThirtyDayDeadline => '30 ଦିନର ସମୟସୀମା';

  @override
  String uiWhatsAffected(String details) {
    return 'କ’ଣ ପ୍ରଭାବିତ ହୋଇଛି: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'ଶେଷ ଅଦ୍ୟତନ: $time ରେ $date';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return 'ସାମ୍ପ୍ରତିକ ପ୍ରୋଫାଇଲ୍ ପରିବର୍ତ୍ତେ $filename $name ଅଧୀନରେ ଦେଖାଯିବ';
  }

  @override
  String get uiOneVerifiedResult => '1 ଯାଞ୍ଚ ହୋଇଥିବା ଫଳାଫଳ ସଞ୍ଚୟ ହୋଇଛି';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count ଯାଞ୍ଚ ହୋଇଥିବା ଫଳାଫଳଗୁଡିକ ସଞ୍ଚୟ ହୋଇଛି';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'ପ୍ରୋଫାଇଲ୍ ସୁଇଚ୍ କରିବାକୁ ଅସମର୍ଥ । $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'ସଂଗୃହିତ: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'ଅପଲୋଡ୍ ତାରିଖ $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount ଦ୍ୱାରା ବୃଦ୍ଧି';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount ଦ୍ୱାରା ହ୍ରାସ';
  }

  @override
  String get uiPercentagePoints => 'ଶତକଡ଼ା ପଏଣ୍ଟ';

  @override
  String uiTestValuesCount(String count) {
    return 'ପରୀକ୍ଷା ମୂଲ୍ୟ ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'ପ୍ରକ୍ରିୟାକରଣ ସମୟରେ AI ଦ୍ୱାରା ମୂଲ୍ୟ ଯାଞ୍ଚ କରାଯାଇଥାଏ । ମୂଳ OCR: $value । ରିପୋର୍ଟ ବିରୋଧରେ ଏହାକୁ ନିଶ୍ଚିତ କରନ୍ତୁ';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return '$name ରେ ପୂର୍ବରୁ ରିପୋର୍ଟ କରନ୍ତୁ';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return 'ରିପୋର୍ଟ $name ରେ ଯୋଡା ଯାଇଛି';
  }

  @override
  String uiAddedOn(String date) {
    return '$date ଯୋଗ କରାଯାଇଛି';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max ରିପୋର୍ଟର $current ବ୍ୟବହାର କରି';
  }

  @override
  String get uiNeedHelp => 'ସହାୟତା ଦରକାର କି?';

  @override
  String get uiEnabled => 'ସକ୍ଷମ';

  @override
  String get uiEnable => 'ସକ୍ଷମ କରନ୍ତୁ';

  @override
  String get uiSubscribe => 'ସବସ୍କ୍ରାଇବ କରନ୍ତୁ';

  @override
  String get uiApplying => 'ପ୍ରୟୋଗ';

  @override
  String get uiCheckStatus => 'ସ୍ଥିତି ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiEditProfile => 'ପ୍ରୋଫାଇଲ୍ ସମ୍ପାଦନ କରନ୍ତୁ';

  @override
  String get uiSaveChanges => 'ପରିବର୍ତ୍ତନ ସେଭ୍ କରନ୍ତୁ';

  @override
  String get uiOptional => 'ବ tion କଳ୍ପିକ';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ଅର୍ଡର $orderId ପୁନ iliation ନିର୍ମାଣ ପାଇଁ ଅପେକ୍ଷା କରିଛି । ସ୍ଥିତି ସ୍ପଷ୍ଟ ନହେବା ପର୍ଯ୍ୟନ୍ତ କ୍ରୟ ବନ୍ଦ ହୋଇଯାଏ';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'ମାସିକ ଯୋଜନା - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'କ୍ରେଡିଟ୍ ପ୍ୟାକ୍ - $name';
  }

  @override
  String get uiUnreadable => 'ପଠନୀୟ ନୁହେଁ';

  @override
  String uiLatestValue(String value) {
    return 'ସର୍ବଶେଷ: $value';
  }

  @override
  String get uiEarlier => 'ପୂର୍ବରୁ';

  @override
  String get uiLater => 'ପରେ';

  @override
  String get uiViewed => 'ଦେଖାଯାଇଛି';

  @override
  String get uiBlocked => 'ଅବରୋଧିତ';

  @override
  String get uiCapped => 'କ୍ୟାପଟେଡ୍';

  @override
  String uiLastChange(String label) {
    return 'ଶେଷ ପରିବର୍ତ୍ତନ: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'ଶେଷ ପରିବର୍ତ୍ତନ: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'ଉପହାର ଭାଉଚର ପ୍ରୟୋଗ ହେଲା । $credits କ୍ରେଡିଟ୍ ଯୋଗ କରାଯାଇଛି';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'ମୂଳ ସଞ୍ଚୟ କରିପାରିଲା ନାହିଁ । $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'ପ୍ରତ୍ୟାହାର କରିବାରେ ବିଫଳ: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'ମୋର ଡକଲିଜର ରେଫରାଲ୍ କୋଡ୍ $code: $link ବ୍ୟବହାର କରନ୍ତୁ';
  }

  @override
  String get uiAMomentAgo => 'କିଛି ସମୟ ପୂର୍ବରୁ';

  @override
  String uiMinutesAgo(String count) {
    return '$count ମିନିଟ୍ ପୂର୍ବରୁ';
  }

  @override
  String get uiOneHourAgo => '1 ଘଣ୍ଟା ପୂର୍ବରୁ';

  @override
  String uiHoursAgo(String count) {
    return '$count ଘଣ୍ଟା ପୂର୍ବରୁ';
  }

  @override
  String get uiToday => 'ଆଜି';

  @override
  String get uiYesterday => 'ଗତକାଲି';

  @override
  String get uiOneDayAgo => '1 ଦିନ ପୂର୍ବରୁ';

  @override
  String uiDaysAgo(String count) {
    return '$count ଦିନ ପୂର୍ବରୁ';
  }

  @override
  String get uiOneWeekAgo => '1 ସପ୍ତାହ ପୂର୍ବରୁ';

  @override
  String uiWeeksAgo(String count) {
    return '$count ସପ୍ତାହ ପୂର୍ବରୁ';
  }

  @override
  String get uiOneMonthAgo => '1 ମାସ ପୂର୍ବରୁ';

  @override
  String uiMonthsAgo(String count) {
    return '$count ମାସ ପୂର୍ବରୁ';
  }

  @override
  String get uiOneYearAgo => '1 ବର୍ଷ ପୂର୍ବେ';

  @override
  String uiYearsAgo(String count) {
    return '$count ବର୍ଷ ପୂର୍ବେ';
  }

  @override
  String get uiInOneDay => '1 ଦିନରେ';

  @override
  String uiInDays(String count) {
    return '$count ଦିନରେ';
  }

  @override
  String uiInMinutes(String count) {
    return '$count ମିନିଟ୍ ରେ';
  }

  @override
  String get uiInOneHour => '1 ଘଣ୍ଟାରେ';

  @override
  String uiInHours(String count) {
    return '$count ଘଣ୍ଟାରେ';
  }

  @override
  String get uiMissingExtractedTestName =>
      'ବାହାର କରାଯାଇଥିବା ଫଳାଫଳରୁ ପରୀକ୍ଷା ନାମ ହଜିଯାଇଛି';

  @override
  String get uiMissingCapturedLabRange =>
      'ଏହି ପରୀକ୍ଷା ପାଇଁ କ lab ଣସି ଲ୍ୟାବ ରେଫରେନ୍ସ ପରିସର ଧରାଯାଇ ନାହିଁ';

  @override
  String get uiNonNumericExtractedValue =>
      'ବାହାର କରାଯାଇଥିବା ମୂଲ୍ୟ ଏକ ସାଧା ସଂଖ୍ୟା ନୁହେଁ । ମୂଳ ରିପୋର୍ଟରେ ଏହାକୁ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiLabFlagRangeConflict =>
      'ଲ୍ୟାବ ପତାକା ମୁଦ୍ରିତ ପରିସର ସହିତ ବିବାଦ କରେ । ମୂଳ ରିପୋର୍ଟ ଯାଞ୍ଚ କରନ୍ତୁ';

  @override
  String get uiResultNeedsOriginalCheck =>
      'ବାହାର କରାଯାଇଥିବା ମୂଲ୍ୟ, ମୁଦ୍ରିତ ପରିସର, କିମ୍ବା ଲ୍ୟାବ ପତାକା ମୂଳ ରିପୋର୍ଟରେ ଯାଞ୍ଚ ଆବଶ୍ୟକ କରେ';

  @override
  String get uiInitialEntitlement => 'ପ୍ରାରମ୍ଭିକ ଅଧିକାର';

  @override
  String get uiCreditPackPurchase => 'କ୍ରେଡିଟ୍ ପ୍ୟାକ୍ କ୍ରୟ';

  @override
  String get uiSubscriptionUpgrade => 'ସଦସ୍ୟତା ଉନ୍ନୟନ';

  @override
  String get uiPlanDowngrade => 'ଡାଉନଗ୍ରେଡ୍ ଯୋଜନା କରନ୍ତୁ';

  @override
  String get uiAdminAdjustment => 'ଆଡମିନି ଆଡଜଷ୍ଟମେଣ୍ଟ୍';

  @override
  String get uiSystemReconciliation => 'ସିଷ୍ଟମ୍ ପୁନ iliation ନିର୍ମାଣ';

  @override
  String get uiReferralInviteBonus => 'ରେଫରାଲ୍ ଆମନ୍ତ୍ରଣ ବୋନସ୍';

  @override
  String get uiReferralAnalysisMilestone => 'ରେଫରାଲ୍ ବିଶ୍ଳେଷଣ ମାଇଲଖୁଣ୍ଟ';

  @override
  String get uiReferralPurchaseMilestone => 'ରେଫରାଲ୍ କ୍ରୟ ମାଇଲଖୁଣ୍ଟ';

  @override
  String get uiFreePromoCreditPack => 'ମାଗଣା ପ୍ରୋମୋ କ୍ରେଡିଟ୍ ପ୍ୟାକ୍';

  @override
  String get uiGiftVoucherRedeemed => 'ଉପହାର ଭାଉଚର ମୁକ୍ତ ହୋଇଛି';

  @override
  String get uiNotYetChanged => 'ଏପର୍ଯ୍ୟନ୍ତ ପରିବର୍ତ୍ତନ ହୋଇନାହିଁ';

  @override
  String get uiCannotReachServer =>
      'ସର୍ଭରରେ ପହଞ୍ଚିବାରେ ଅସମର୍ଥ । ଆପଣଙ୍କର ସଂଯୋଗ ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiInvalidEmailOrPassword =>
      'ଅବ val ଧ ଇମେଲ କିମ୍ବା ପାସୱାର୍ଡ । ଆପଣଙ୍କର ବିବରଣୀ ଯାଞ୍ଚ କରନ୍ତୁ ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiTooManyAuthAttempts =>
      'ବହୁତ ଚେଷ୍ଟା । କିଛି ମିନିଟ୍ ଅପେକ୍ଷା କର ଏବଂ ପୁନର୍ବାର ଚେଷ୍ଟା କର';

  @override
  String get uiEnterValidEmail =>
      'ଦୟାକରି ଏକ ବ email ଧ ଇମେଲ୍ ଠିକଣା ପ୍ରବେଶ କରନ୍ତୁ';

  @override
  String get uiPasswordRequirements =>
      'ପାସୱାର୍ଡ ଅତିକମରେ 8 ଅକ୍ଷର ହେବା ଆବଶ୍ୟକ ଏବଂ ଏଥିରେ ବଡ ଅକ୍ଷର, ଲୋୟର କେସ୍, ଏକ ସଂଖ୍ୟା, ଏବଂ ଏକ ସ୍ୱତନ୍ତ୍ର ବର୍ଣ୍ଣ ଅନ୍ତର୍ଭୁକ୍ତ';

  @override
  String get uiAccountWithEmailExists =>
      'ଏହି ଇମେଲ ସହିତ ଏକ ଖାତା ପୂର୍ବରୁ ବିଦ୍ୟମାନ ଅଛି । ସାଇନ୍ ଇନ୍ କରନ୍ତୁ କିମ୍ବା ଏକ ଭିନ୍ନ ଇମେଲ୍ ବ୍ୟବହାର କରନ୍ତୁ';

  @override
  String get uiUploadedStatus => 'ଅପଲୋଡ୍ ହୋଇଛି';

  @override
  String uiSupportAction(String action) {
    return 'କାର୍ଯ୍ୟ: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'ସମ୍ପର୍କ ID: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'କ୍ଲାଏଣ୍ଟ ଆକ୍ସନ୍ ID: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'ତ୍ରୁଟି ସଂକେତ: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'ତ୍ରୁଟି: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'ତୁମର ଅଧିବେଶନ ସମାପ୍ତ ହେଲା । ପୁନର୍ବାର ସାଇନ୍ ଇନ୍ କରନ୍ତୁ';

  @override
  String get uiProfileLimitReached =>
      'ଆପଣଙ୍କର ଯୋଜନା ପ୍ରୋଫାଇଲ୍ ସୀମା ପହଞ୍ଚିସାରିଛି । ଅଧିକ ଯୋଗ କରିବାକୁ ଯୋଜନା ଏବଂ କ୍ରେଡିଟ୍ ସମୀକ୍ଷା କରନ୍ତୁ';

  @override
  String get uiCorrectionConflictReload =>
      'ଏହି ଫଳାଫଳ ଅନ୍ୟତ୍ର ବଦଳିଗଲା । ଏହାକୁ ସଂଶୋଧନ କରିବା ପୂର୍ବରୁ ରିପୋର୍ଟକୁ ପୁନ elo ଲୋଡ୍ କରନ୍ତୁ';

  @override
  String get uiSeePlanCreditsOptions =>
      'ଉପଲବ୍ଧ ବିକଳ୍ପଗୁଡ଼ିକ ପାଇଁ ଯୋଜନା ଏବଂ କ୍ରେଡିଟ୍ ଦେଖନ୍ତୁ';

  @override
  String get uiShareLinkLimitHelp =>
      'ଆପଣ ସକ୍ରିୟ ଅଂଶୀଦାର-ଲିଙ୍କ୍ ସୀମାରେ ପହଞ୍ଚିଛନ୍ତି';

  @override
  String get uiScopedExportUnavailable =>
      'ସ୍କୋପଡ୍ ରପ୍ତାନି ଉପଲବ୍ଧ ନାହିଁ । ପରେ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiRestorationUnavailable =>
      'ପୁନରୁଦ୍ଧାର ଉପଲବ୍ଧ ନାହିଁ । ପରେ ପୁନର୍ବାର ଚେଷ୍ଟା କରନ୍ତୁ';

  @override
  String get uiExportRequestNotFound =>
      'ରପ୍ତାନି ଅନୁରୋଧ ମିଳିଲା ନାହିଁ । ଏକ ନୂତନ ରପ୍ତାନି ପାଇଁ ଅନୁରୋଧ';

  @override
  String get uiClosureConfirmationRequired =>
      'ଜାରି ରଖିବାକୁ ଖାତା ବନ୍ଦକୁ ନିଶ୍ଚିତ କରନ୍ତୁ';

  @override
  String get uiCurrentPasswordIncorrect => 'ସାମ୍ପ୍ରତିକ ପାସୱାର୍ଡ ଭୁଲ୍ ଅଟେ';

  @override
  String get uiLaboratories => 'ଲାବୋରେଟୋରୀଗୁଡିକ';

  @override
  String get uiUnlock => 'ଅନଲକ୍ କରନ୍ତୁ';
}
