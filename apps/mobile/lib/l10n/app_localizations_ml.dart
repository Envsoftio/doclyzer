// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get trendLatestResult => 'ഏറ്റവും പുതിയ ഫലം';

  @override
  String get trendPreviousResult => 'മുമ്പത്തെ ഫലം';

  @override
  String get trendSourceUnit => 'ഈ പരിധിയുടെ യഥാർത്ഥ യൂണിറ്റ്';

  @override
  String get trendNoSavedResults =>
      'ഈ പരിശോധനയ്ക്ക് ഇതുവരെ സൂക്ഷിച്ച ഫലങ്ങളില്ല.';

  @override
  String get trendNoPlottableResults =>
      'സാമ്പിൾ എടുത്ത തീയതിയുള്ള കൃത്യമായ സംഖ്യാ ഫലങ്ങൾ ചാർട്ടിൽ കാണിക്കാനാകില്ല.';

  @override
  String get trendOneResultHelp =>
      'ഒരു ഫലം സൂക്ഷിച്ചിട്ടുണ്ട്. മാറ്റം കാണാൻ മറ്റൊരു റിപ്പോർട്ട് ചേർക്കുക.';

  @override
  String get trendMultipleResultsHelp =>
      'തീയതികൾ കടന്നുപോയ സമയമനുസരിച്ചാണ് കാണിക്കുന്നത്. മൂല്യം കാണാൻ ഒരു പോയിന്റിൽ തട്ടുക.';

  @override
  String trendUnplottedNote(int count) {
    return 'സാമ്പിൾ എടുത്ത തീയതിയോ കൃത്യമായ സംഖ്യാ മൂല്യമോ ഇല്ലാത്തതിനാൽ $count ഫലങ്ങൾ ചാർട്ടിൽ കാണിച്ചിട്ടില്ല.';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$count ഫലങ്ങളുള്ള $testName മാറ്റങ്ങളുടെ ചാർട്ട്';
  }

  @override
  String get trendDateReview =>
      'സാമ്പിൾ എടുത്ത തീയതി മുമ്പത്തെ വിവരശേഖരണത്തിൽ നിന്നുള്ളതാണ്. യഥാർത്ഥ റിപ്പോർട്ടിൽ പരിശോധിക്കുക.';

  @override
  String get trendNotPlotted => 'ചാർട്ടിൽ കാണിച്ചിട്ടില്ല';

  @override
  String get trendExactNumberUnavailable => 'ഫലം കൃത്യമായ സംഖ്യയല്ല';

  @override
  String get preferredLanguage => 'മുൻഗണനാ ഭാഷ';

  @override
  String get descriptionLanguage => 'വിശദീകരണത്തിന്റെ ഭാഷ';

  @override
  String get languageHelp =>
      'ആപ്പിലെ ലേബലുകൾക്കും റിപ്പോർട്ട് വിശദീകരണങ്ങൾക്കും ഉപയോഗിക്കുന്നു. വിശദീകരണത്തിന്റെ ഭാഷ എപ്പോൾ വേണമെങ്കിലും മാറ്റാം.';

  @override
  String get languageSaveFailed =>
      'നിങ്ങളുടെ ഭാഷ സംരക്ഷിക്കാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get translationLoading =>
      'പരിഭാഷപ്പെടുത്തിയ വിശദീകരണം തയ്യാറാക്കുന്നു…';

  @override
  String get translationFailed =>
      'പരിഭാഷ ലഭ്യമല്ല. വീണ്ടും ശ്രമിക്കുക അല്ലെങ്കിൽ ഇംഗ്ലീഷ് തിരഞ്ഞെടുക്കുക.';

  @override
  String get translationNote =>
      'സംരക്ഷിച്ച ഇംഗ്ലീഷ് വിശദീകരണത്തിൽ നിന്ന് AI പരിഭാഷപ്പെടുത്തിയത്. കൃത്യമായ ഫലങ്ങൾക്കായി യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക.';

  @override
  String get sourceChanged =>
      'റിപ്പോർട്ട് മാറിയിട്ടുണ്ട്. ഏറ്റവും പുതിയ വിശദീകരണം കാണാൻ അത് വീണ്ടും ലോഡ് ചെയ്യുക.';

  @override
  String get signupTitle => 'കൂടുതൽ വ്യക്തത\nഇവിടെ തുടങ്ങുന്നു.';

  @override
  String get signupIntro =>
      'നിങ്ങളുടെ റിപ്പോർട്ടുകളും ഫലങ്ങളും ഒരുമിച്ച് സൂക്ഷിക്കാൻ ഒരു അക്കൗണ്ട് സൃഷ്ടിക്കുക.';

  @override
  String get loginIntro =>
      'നിങ്ങളുടെ ആരോഗ്യ റിപ്പോർട്ടുകൾ കാണാനും മനസ്സിലാക്കാനും സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get emailAddress => 'ഇമെയിൽ വിലാസം';

  @override
  String get email => 'ഇമെയിൽ';

  @override
  String get password => 'പാസ്‌വേഡ്';

  @override
  String get referralCode => 'റഫറൽ കോഡ് (നിർബന്ധമില്ല)';

  @override
  String get createAccount => 'അക്കൗണ്ട് സൃഷ്ടിക്കുക';

  @override
  String get alreadyAccount => 'ഇതിനകം അക്കൗണ്ടുണ്ടോ? ';

  @override
  String get noAccount => 'അക്കൗണ്ടില്ലേ? ';

  @override
  String get signIn => 'സൈൻ ഇൻ ചെയ്യുക';

  @override
  String get showPassword => 'പാസ്‌വേഡ് കാണിക്കുക';

  @override
  String get hidePassword => 'പാസ്‌വേഡ് മറയ്ക്കുക';

  @override
  String get needHelp => 'സഹായം വേണോ?';

  @override
  String get forgotPassword => 'പാസ്‌വേഡ് മറന്നോ?';

  @override
  String get invalidCredentialsInput =>
      'സാധുവായ ഇമെയിൽ വിലാസവും പാസ്‌വേഡും നൽകുക';

  @override
  String get signupFailed => 'അക്കൗണ്ട് സൃഷ്ടിക്കാനായില്ല';

  @override
  String get loginFailed =>
      'സൈൻ ഇൻ ചെയ്യാനായില്ല. നിങ്ങളുടെ കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get genericError => 'എന്തോ പിശക് സംഭവിച്ചു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get profileUpdated => 'പ്രൊഫൈൽ പുതുക്കി';

  @override
  String get changePhoto => 'പ്രൊഫൈൽ ഫോട്ടോ മാറ്റുക';

  @override
  String get gallery => 'ഗാലറിയിൽ നിന്ന് തിരഞ്ഞെടുക്കുക';

  @override
  String get camera => 'ഫോട്ടോ എടുക്കുക';

  @override
  String get photoUpdated => 'പ്രൊഫൈൽ ഫോട്ടോ പുതുക്കി';

  @override
  String get photoFailed =>
      'നിങ്ങളുടെ ഫോട്ടോ പുതുക്കാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get yourAccount => 'നിങ്ങളുടെ അക്കൗണ്ട്';

  @override
  String get profileLoading => 'പ്രൊഫൈൽ ലോഡ് ചെയ്യുന്നു…';

  @override
  String get profileLoadAction =>
      'നിങ്ങളുടെ പ്രൊഫൈൽ ലോഡ് ചെയ്യാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get accountData => 'അക്കൗണ്ടും ഡാറ്റയും';

  @override
  String get personalInformation => 'വ്യക്തിഗത വിവരങ്ങൾ';

  @override
  String get notificationPreferences => 'അറിയിപ്പ് മുൻഗണനകൾ';

  @override
  String get privacySecurity => 'സ്വകാര്യതയും സുരക്ഷയും';

  @override
  String get sharedLinks => 'പങ്കിട്ട ലിങ്കുകൾ';

  @override
  String get exportData => 'നിങ്ങളുടെ ഡാറ്റ എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get additionalAccount => 'കൂടുതൽ അക്കൗണ്ട് വിവരങ്ങൾ';

  @override
  String get additionalAccountHelp =>
      'കുടുംബം, പ്ലാൻ, റഫറലുകൾ, സെഷനുകൾ, ദൃശ്യരൂപം';

  @override
  String get familyProfiles => 'കുടുംബ പ്രൊഫൈലുകൾ';

  @override
  String get manageProfiles =>
      'മറ്റൊരു പ്രൊഫൈലിലേക്ക് മാറുകയോ പ്രൊഫൈലുകൾ നിയന്ത്രിക്കുകയോ ചെയ്യുക';

  @override
  String get planCredits => 'പ്ലാനും ക്രെഡിറ്റുകളും';

  @override
  String get viewPlanBalance => 'നിങ്ങളുടെ പ്ലാനും ബാലൻസും കാണുക';

  @override
  String get balanceLoading => 'ബാലൻസ് ലോഡ് ചെയ്യുന്നു…';

  @override
  String get referFriends => 'സുഹൃത്തുക്കളെ ക്ഷണിക്കുക';

  @override
  String get referralRewards => 'ക്ഷണങ്ങളും റഫറൽ പ്രതിഫലങ്ങളും';

  @override
  String get activeSessions => 'സജീവ സെഷനുകൾ';

  @override
  String get appearance => 'ദൃശ്യരൂപം';

  @override
  String get system => 'സിസ്റ്റം';

  @override
  String get light => 'ഇളം നിറം';

  @override
  String get dark => 'ഇരുണ്ട നിറം';

  @override
  String get helpSupport => 'സഹായവും പിന്തുണയും';

  @override
  String get aboutDoclyzer => 'Doclyzer-നെക്കുറിച്ച്';

  @override
  String get aboutCopy =>
      'ഓരോ വ്യക്തിയുടെയും റിപ്പോർട്ടുകൾ ക്രമപ്പെടുത്തി സൂക്ഷിക്കുക, വേർതിരിച്ചെടുത്ത ഫലങ്ങൾ യഥാർത്ഥ റിപ്പോർട്ടുമായി ഒത്തുനോക്കുക.';

  @override
  String get logOut => 'ലോഗ് ഔട്ട് ചെയ്യുക';

  @override
  String get profile => 'പ്രൊഫൈൽ';

  @override
  String get saveChanges => 'മാറ്റങ്ങൾ സംരക്ഷിക്കുക';

  @override
  String get accountRestricted => 'അക്കൗണ്ടിന് നിയന്ത്രണമുണ്ട്';

  @override
  String get photoUploading => 'ഫോട്ടോ അപ്‌ലോഡ് ചെയ്യുന്നു…';

  @override
  String get changePhotoShort => 'ഫോട്ടോ മാറ്റുക';

  @override
  String get accountDetails => 'അക്കൗണ്ട് വിവരങ്ങൾ';

  @override
  String get emailHelp =>
      'അക്കൗണ്ടിൽ പ്രവേശിക്കാൻ ഉപയോഗിക്കുന്നു. ഇത് മാറ്റാൻ പിന്തുണാ വിഭാഗവുമായി ബന്ധപ്പെടുക.';

  @override
  String get accountName => 'അക്കൗണ്ടിന്റെ പേര്';

  @override
  String get belowLabRange => 'ഈ ലാബിന്റെ റഫറൻസ് പരിധിക്ക് താഴെ';

  @override
  String get withinLabRange => 'ഈ ലാബിന്റെ റഫറൻസ് പരിധിക്കുള്ളിൽ';

  @override
  String get aboveLabRange => 'ഈ ലാബിന്റെ റഫറൻസ് പരിധിക്ക് മുകളിൽ';

  @override
  String get cannotCompare => 'ലാബിന്റെ പരിധിയുമായി താരതമ്യം ചെയ്യാനാവില്ല';

  @override
  String get understandResult => 'ഈ ഫലം മനസ്സിലാക്കുക';

  @override
  String get yourResult => 'നിങ്ങളുടെ ഫലം';

  @override
  String get labReferenceRange => 'ലാബിന്റെ റഫറൻസ് പരിധി';

  @override
  String get resultUnavailable => 'ഈ ഫലത്തിൽ ലഭ്യമല്ല';

  @override
  String get sampleDate => 'സാമ്പിൾ എടുത്ത തീയതി';

  @override
  String get resultHistory => 'ഫലങ്ങളുടെ ചരിത്രം';

  @override
  String get originalReport => 'യഥാർത്ഥ റിപ്പോർട്ട്';

  @override
  String get reviewValue => 'മൂല്യം പരിശോധിക്കുക';

  @override
  String get understandYourResult => 'നിങ്ങളുടെ ഫലം മനസ്സിലാക്കുക';

  @override
  String get educationalContext =>
      'ഈ ഫലത്തെക്കുറിച്ച് ചർച്ച ചെയ്യാൻ സഹായിക്കുന്ന പഠനവിവരങ്ങൾ.';

  @override
  String get explanationUnavailable => 'വിശദീകരണം ലഭ്യമല്ല';

  @override
  String get explanationFailed => 'ഇപ്പോൾ വിശദീകരണം ലോഡ് ചെയ്യാനായില്ല.';

  @override
  String get checkOriginal => 'യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക';

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get aiGuidance => 'AI തയ്യാറാക്കിയ മാർഗനിർദേശം';

  @override
  String get understandingResult => 'ഈ ഫലം മനസ്സിലാക്കാം';

  @override
  String get possibleMeaning => 'ഇത് സൂചിപ്പിച്ചേക്കാവുന്നത്';

  @override
  String get whatTestMeasures => 'ഈ പരിശോധന അളക്കുന്നത് എന്താണ്';

  @override
  String get suggestedNextStep => 'നിർദേശിക്കുന്ന അടുത്ത നടപടി';

  @override
  String get resultLimitations => 'ഈ ഫലത്തിൽ നിന്ന് അറിയാനാകാത്ത കാര്യങ്ങൾ';

  @override
  String get oneResultLimit =>
      'ഒരൊറ്റ ഫലം മാത്രം ഉപയോഗിച്ച് ഒരു രോഗാവസ്ഥ നിർണയിക്കാനോ ലക്ഷണങ്ങൾ വിശദീകരിക്കാനോ കഴിയില്ല.';

  @override
  String get detailsToCheck => 'പരിശോധിക്കേണ്ട വിവരങ്ങൾ';

  @override
  String get lifestyleFactors => 'ചർച്ച ചെയ്യേണ്ട ജീവിതശൈലി ഘടകങ്ങൾ';

  @override
  String get insightContext =>
      'ഈ മൂല്യം നിങ്ങളുടെ റിപ്പോർട്ടിൽ നിന്ന് വേർതിരിച്ചെടുത്തതാണ്. പേര്, മൂല്യം, യൂണിറ്റ് അല്ലെങ്കിൽ പരിധി തെറ്റായി തോന്നുന്നെങ്കിൽ യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക. AI വിശദീകരണങ്ങൾ പഠനാവശ്യത്തിനുള്ളവയാണ്; നിങ്ങൾക്ക് ഏത് ചികിത്സയാണ് വേണ്ടതെന്ന് അവയ്ക്ക് പറയാനാവില്ല.';

  @override
  String get yourProfile => 'നിങ്ങളുടെ പ്രൊഫൈൽ';

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get delete => 'ഇല്ലാതാക്കുക';

  @override
  String get moveReport => 'റിപ്പോർട്ട് മറ്റൊരു പ്രൊഫൈലിലേക്ക് മാറ്റുക';

  @override
  String get gotIt => 'മനസ്സിലായി';

  @override
  String get reportDetails => 'റിപ്പോർട്ട് വിവരങ്ങൾ';

  @override
  String get shareReport => 'റിപ്പോർട്ട് പങ്കിടുക';

  @override
  String get moreReportActions => 'റിപ്പോർട്ടിനുള്ള കൂടുതൽ പ്രവർത്തനങ്ങൾ';

  @override
  String get attemptHistory => 'ശ്രമങ്ങളുടെ ചരിത്രം';

  @override
  String get compareReports => 'റിപ്പോർട്ടുകൾ താരതമ്യം ചെയ്യുക';

  @override
  String get readParsedReport =>
      'വിവരങ്ങൾ വേർതിരിച്ചെടുത്ത റിപ്പോർട്ട് വായിക്കുക';

  @override
  String get moveRecycle => 'റീസൈക്കിൾ ബിന്നിലേക്ക് മാറ്റുക';

  @override
  String get retry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get reportSummary => 'റിപ്പോർട്ട് സംഗ്രഹം';

  @override
  String get updateSummary => 'സംഗ്രഹം പുതുക്കുക';

  @override
  String get summaryLoading =>
      'നിങ്ങളുടെ ഫലങ്ങൾ ലളിതമായ ഭാഷയിൽ വിശദീകരിക്കുന്നു…';

  @override
  String get checkSummary => 'സംഗ്രഹം പരിശോധിക്കുക';

  @override
  String get summaryFailed =>
      'സംഗ്രഹം തയ്യാറാക്കാനായില്ല. നിങ്ങൾക്ക് വീണ്ടും ശ്രമിക്കാം.';

  @override
  String get summaryPlaceholder =>
      'പ്രധാന ഫലങ്ങളുടെ ലളിതമായ ഭാഷയിലുള്ള വിശദീകരണം ഇവിടെ കാണാം.';

  @override
  String get retrySummary => 'സംഗ്രഹത്തിനായി വീണ്ടും ശ്രമിക്കുക';

  @override
  String get generateSummary => 'സംഗ്രഹം തയ്യാറാക്കുക';

  @override
  String get loadingResults => 'റിപ്പോർട്ടിലെ ഫലങ്ങൾ ലോഡ് ചെയ്യുന്നു…';

  @override
  String get somethingWrong => 'എന്തോ പിശക് സംഭവിച്ചു';

  @override
  String get viewTrends => 'കാലക്രമത്തിലുള്ള മാറ്റങ്ങൾ കാണുക';

  @override
  String get originalFile => 'യഥാർത്ഥ ഫയൽ';

  @override
  String get testValues => 'പരിശോധനാ മൂല്യങ്ങൾ';

  @override
  String get summary => 'സംഗ്രഹം';

  @override
  String get checkStatus => 'നില പരിശോധിക്കുക';

  @override
  String get viewOriginal => 'യഥാർത്ഥ റിപ്പോർട്ട് കാണുക';

  @override
  String get verifiedResults => 'സ്ഥിരീകരിച്ച ഫലങ്ങൾ';

  @override
  String get resultTapHelp =>
      'പരിശോധന എന്താണ് അളക്കുന്നതെന്ന് മനസ്സിലാക്കാൻ ഒരു ഫലത്തിൽ ടാപ്പ് ചെയ്യുക.';

  @override
  String get reviewResults => 'കണ്ടെത്തിയ ഫലങ്ങൾ പരിശോധിക്കുക';

  @override
  String get keepFile => 'എങ്കിലും ഫയൽ സൂക്ഷിക്കുക';

  @override
  String get patientDetails => 'രോഗിയുടെ വിവരങ്ങൾ';

  @override
  String get name => 'പേര്';

  @override
  String get age => 'പ്രായം';

  @override
  String get gender => 'ലിംഗം';

  @override
  String get bookingId => 'ബുക്കിംഗ് ID';

  @override
  String get sampleCollection => 'സാമ്പിൾ ശേഖരണം';

  @override
  String get labDetails => 'ലാബ് വിവരങ്ങൾ';

  @override
  String get labName => 'ലാബിന്റെ പേര്';

  @override
  String get address => 'വിലാസം';

  @override
  String get phone => 'ഫോൺ';

  @override
  String get location => 'സ്ഥലം';

  @override
  String get belowRange => 'പരിധിക്ക് താഴെ';

  @override
  String get aboveRange => 'പരിധിക്ക് മുകളിൽ';

  @override
  String get withinRange => 'നൽകിയ പരിധിക്കുള്ളിൽ';

  @override
  String get rangeUnclear => 'പരിധി വ്യക്തമല്ല';

  @override
  String get understandResultAction => 'ഈ ഫലം മനസ്സിലാക്കുക  →';

  @override
  String get parsedReport => 'വിവരങ്ങൾ വേർതിരിച്ചെടുത്ത റിപ്പോർട്ട്';

  @override
  String get reports => 'റിപ്പോർട്ടുകൾ';

  @override
  String get trends => 'കാലക്രമത്തിലുള്ള മാറ്റങ്ങൾ';

  @override
  String get openingPage => 'ആരംഭ പേജ്';

  @override
  String get home => 'ഹോം';

  @override
  String get family => 'കുടുംബം';

  @override
  String get switchProfile => 'മറ്റൊരു പ്രൊഫൈലിലേക്ക് മാറുക';

  @override
  String get currentProfile => 'നിലവിലെ പ്രൊഫൈൽ';

  @override
  String get viewProfile => 'ഈ പ്രൊഫൈൽ കാണുക';

  @override
  String get manageFamily => 'കുടുംബ പ്രൊഫൈലുകൾ നിയന്ത്രിക്കുക';

  @override
  String get chooseProfile => 'ഒരു പ്രൊഫൈൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get notifications => 'അറിയിപ്പുകൾ';

  @override
  String get homeTitle => 'കുറച്ചുകൂടി വ്യക്തത.\nഎല്ലാം ഒരിടത്ത്.';

  @override
  String get nextReportTitle =>
      'നിങ്ങളുടെ അടുത്ത റിപ്പോർട്ട്,\nനിങ്ങൾ തയ്യാറാകുമ്പോഴേക്കും സജ്ജം.';

  @override
  String get homeSubtitle => 'PDF-കളും ഫോട്ടോകളും കുടുംബ രേഖകളും.';

  @override
  String get uploadReport => 'റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get recentReport => 'സമീപകാല റിപ്പോർട്ട്';

  @override
  String get viewAll => 'എല്ലാം കാണുക';

  @override
  String get reportsUnavailable =>
      'റിപ്പോർട്ടുകൾ ലഭ്യമല്ല. കണക്ഷൻ ലഭിക്കുമ്പോൾ വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get emptyHomeTitle => 'നിങ്ങളുടെ കഥ ഇവിടെ തുടങ്ങുന്നു';

  @override
  String get emptyHomeHelp =>
      'നിങ്ങളുടെ രേഖകളുടെ വ്യക്തമായ ചരിത്രം തുടങ്ങാൻ ആദ്യ റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുക.';

  @override
  String get uploadFirstReport => 'നിങ്ങളുടെ ആദ്യ റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get latestResults => 'ഏറ്റവും പുതിയ ഫലങ്ങൾ';

  @override
  String get allTrends => 'കാലക്രമത്തിലുള്ള എല്ലാ മാറ്റങ്ങളും';

  @override
  String get reviewedResultsHelp =>
      'പരിശോധിച്ച ഫലങ്ങൾ ലഭ്യമാകുമ്പോൾ ഇവിടെ കാണാം.';

  @override
  String get searchTests => 'പരിശോധനകൾ തിരയുക';

  @override
  String get noHealthData =>
      'ഇതുവരെ ആരോഗ്യ ഡാറ്റയില്ല. നിങ്ങളുടെ ആരോഗ്യ ചരിത്രം കാണാൻ ഒരു റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുക.';

  @override
  String get noTestsFound => 'പരിശോധനകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get shorterTestName => 'പരിശോധനയുടെ പേര് ചുരുക്കി തിരയുക.';

  @override
  String get clearSearch => 'തിരച്ചിൽ മായ്ക്കുക';

  @override
  String get unitUnavailable => 'യൂണിറ്റ് ലഭ്യമല്ല';

  @override
  String get uploadingReport => 'റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുന്നു…';

  @override
  String get organizingReport => 'നിങ്ങളുടെ റിപ്പോർട്ട് ക്രമപ്പെടുത്തുന്നു…';

  @override
  String get uploadAReport => 'ഒരു റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get uploadHelp =>
      'ഒരു PDF അല്ലെങ്കിൽ വ്യക്തമായ ഫോട്ടോ തിരഞ്ഞെടുക്കുക. സംരക്ഷിക്കുന്നതിന് മുമ്പ് വിവരങ്ങൾ പരിശോധിക്കാം.';

  @override
  String get chooseSource => 'ഉറവിടം തിരഞ്ഞെടുക്കുക';

  @override
  String get uploadPdfImage => 'PDF അല്ലെങ്കിൽ ചിത്രം അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get chooseReportFiles =>
      'നിങ്ങളുടെ ഫയലുകളിൽ നിന്ന് ഒരു റിപ്പോർട്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get selectReportPages =>
      'ഒന്നോ അതിലധികമോ റിപ്പോർട്ട് പേജുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get capturePage => 'ഒരു പേജ് മുഴുവനായി പകർത്തുക';

  @override
  String get supportedFormats => 'പിന്തുണയ്ക്കുന്ന ഫോർമാറ്റുകൾ: PDF, JPG, PNG';

  @override
  String get confirmFile =>
      'നിങ്ങൾ ചേർക്കാൻ ഉദ്ദേശിക്കുന്ന ഫയൽ ഇതുതന്നെയാണെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get addReport => 'റിപ്പോർട്ട് ചേർക്കുക';

  @override
  String get chooseDifferentFile => 'മറ്റൊരു ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get uploadWait => 'ഇതിന് അൽപസമയം എടുത്തേക്കാം. ആപ്പ് തുറന്നുവയ്ക്കുക.';

  @override
  String get reportNeedsAttention =>
      'റിപ്പോർട്ടിൽ ശ്രദ്ധിക്കേണ്ട കാര്യങ്ങളുണ്ട്';

  @override
  String get verifyBeforeSaving =>
      'കണ്ടെത്തിയ ഫലങ്ങൾ സംരക്ഷിക്കുന്നതിന് മുമ്പ് യഥാർത്ഥ റിപ്പോർട്ടുമായി ഒത്തുനോക്കുക.';

  @override
  String get viewVerifiedResults => 'സ്ഥിരീകരിച്ച ഫലങ്ങൾ കാണുക';

  @override
  String get viewOriginalReport => 'യഥാർത്ഥ റിപ്പോർട്ട് കാണുക';

  @override
  String get viewReportStatus => 'റിപ്പോർട്ടിന്റെ നില കാണുക';

  @override
  String get viewResults => 'ഫലങ്ങൾ കാണുക';

  @override
  String get viewOriginalFile => 'യഥാർത്ഥ ഫയൽ കാണുക';

  @override
  String get retryExtraction =>
      'വിവരങ്ങൾ വേർതിരിച്ചെടുക്കാൻ വീണ്ടും ശ്രമിക്കുക';

  @override
  String get done => 'പൂർത്തിയായി';

  @override
  String get duplicateReport =>
      'ഈ റിപ്പോർട്ട് ഇതിനകം ഉള്ളതിന്റെ പകർപ്പാണെന്ന് തോന്നുന്നു';

  @override
  String get duplicateHelp =>
      'ഈ ഫയൽ നിങ്ങളുടെ റിപ്പോർട്ടുകളിൽ ഇതിനകം ഉണ്ടായേക്കാം.';

  @override
  String get keepExisting => 'നിലവിലുള്ളത് സൂക്ഷിക്കുക';

  @override
  String get processAgain => 'PDF വീണ്ടും പ്രോസസ് ചെയ്യുക';

  @override
  String get uploadNewCopy => 'പുതിയ പകർപ്പായി അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get reportLimitReached => 'റിപ്പോർട്ടുകളുടെ പരിധിയിലെത്തി';

  @override
  String get reportLimitHelp => 'നിങ്ങളുടെ റിപ്പോർട്ടുകളുടെ പരിധിയിലെത്തി.';

  @override
  String get upgrade => 'അപ്‌ഗ്രേഡ് ചെയ്യുക';

  @override
  String get back => 'തിരികെ';

  @override
  String get uploadFailedTitle => 'റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യാനായില്ല';

  @override
  String get uploadFailed => 'അപ്‌ലോഡ് പരാജയപ്പെട്ടു';

  @override
  String get retrySameFile => 'അതേ ഫയൽ വീണ്ടും അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get chooseAnotherFile => 'മറ്റൊരു ഫയൽ തിരഞ്ഞെടുക്കുക';

  @override
  String get aiDisclaimer =>
      'നിങ്ങളുടെ ആരോഗ്യ റിപ്പോർട്ടുകൾ ക്രമപ്പെടുത്താനും കൂടുതൽ നന്നായി മനസ്സിലാക്കാനും Doclyzer സഹായിക്കുന്നു. നൽകുന്ന വിവരങ്ങൾ പഠനാവശ്യങ്ങൾക്ക് മാത്രമുള്ളതാണ്; അവ വൈദ്യോപദേശമോ രോഗനിർണയമോ ചികിത്സയോ അല്ല. വൈദ്യ മാർഗനിർദേശത്തിനായി എല്ലായ്പ്പോഴും യോഗ്യതയുള്ള ആരോഗ്യവിദഗ്ധനെ സമീപിക്കുക.';

  @override
  String collectedOn(String date) {
    return 'ശേഖരിച്ചത് $date';
  }

  @override
  String uploadedOn(String date) {
    return 'അപ്‌ലോഡ് ചെയ്തത് $date';
  }

  @override
  String labRangeValue(String range) {
    return 'ലാബ് പരിധി $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits ക്രെഡിറ്റുകൾ';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count റിപ്പോർട്ടുകൾ',
      one: '1 റിപ്പോർട്ട്',
      zero: 'റിപ്പോർട്ടുകളില്ല',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'റിപ്പോർട്ട് ലോഡ് ചെയ്യാൻ പ്രതീക്ഷിച്ചതിലും കൂടുതൽ സമയമെടുക്കുന്നു. നിങ്ങളുടെ കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get summaryUpdateFailed =>
      'ഇപ്പോൾ സംഗ്രഹം പുതുക്കാനായില്ല. സംരക്ഷിച്ച സംഗ്രഹം ഇപ്പോഴും ലഭ്യമാണ്.';

  @override
  String get summaryCreateFailed =>
      'ഇപ്പോൾ സംഗ്രഹം തയ്യാറാക്കാനായില്ല. നിങ്ങളുടെ ഫലങ്ങൾ താഴെ ഇപ്പോഴും ലഭ്യമാണ്.';

  @override
  String get reassignFailed =>
      'റിപ്പോർട്ട് മറ്റൊരു പ്രൊഫൈലിലേക്ക് മാറ്റാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get confirmRecycle => 'റീസൈക്കിൾ ബിന്നിലേക്ക് മാറ്റണോ?';

  @override
  String get recycleHelp =>
      '30 ദിവസത്തേക്ക് റിപ്പോർട്ടുകൾ > റീസൈക്കിൾ ബിൻ എന്നതിൽ നിന്ന് ഈ റിപ്പോർട്ട് പുനഃസ്ഥാപിക്കാം. അതിനുശേഷം ഇത് ശാശ്വതമായി ഇല്ലാതാക്കും.';

  @override
  String get reportRecycled => 'റിപ്പോർട്ട് റീസൈക്കിൾ ബിന്നിലേക്ക് മാറ്റി';

  @override
  String get reportDeleteFailed =>
      'റിപ്പോർട്ട് ഇല്ലാതാക്കാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get addProfileBeforeMove =>
      'ഈ റിപ്പോർട്ട് മാറ്റുന്നതിന് മുമ്പ് മറ്റൊരു കുടുംബ പ്രൊഫൈൽ ചേർക്കുക.';

  @override
  String get moveReportHelp =>
      'ഈ റിപ്പോർട്ട് തെറ്റായ പ്രൊഫൈലിലാണ് ചേർത്തതെങ്കിൽ മറ്റൊരു കുടുംബാംഗത്തെ തിരഞ്ഞെടുക്കുക.';

  @override
  String get confirmMoveReport =>
      'ഈ റിപ്പോർട്ട് മറ്റൊരു പ്രൊഫൈലിലേക്ക് മാറ്റണോ?';

  @override
  String get aboutSampleDates => 'സാമ്പിൾ തീയതികളെക്കുറിച്ച്';

  @override
  String get multipleDatesHelp =>
      'ഈ റിപ്പോർട്ടിൽ ഒന്നിലധികം സാമ്പിൾ തീയതികളിലെ ഫലങ്ങളുണ്ട്. ഒരു ഫലം തുറന്ന് അതിന്റെ തീയതി യഥാർത്ഥ റിപ്പോർട്ടുമായി ഒത്തുനോക്കുക.';

  @override
  String get missingDateHelp =>
      'സാമ്പിൾ എടുത്ത ദിവസമാണ് സാമ്പിൾ തീയതി. ഈ റിപ്പോർട്ടിൽ വിശ്വസനീയമായ ഒരു തീയതി കണ്ടെത്താനായില്ല. സാമ്പിൾ തീയതിയും അപ്‌ലോഡ് ചെയ്ത തീയതിയും വ്യത്യസ്തമാണ്. തീയതി പരിശോധിക്കാനോ തിരുത്താനോ ഒരു ഫലം തുറക്കുക.';

  @override
  String get uploading => 'അപ്‌ലോഡ് ചെയ്യുന്നു';

  @override
  String get waitingToProcess => 'പ്രോസസ് ചെയ്യാൻ കാത്തിരിക്കുന്നു';

  @override
  String get readingReport => 'റിപ്പോർട്ട് വായിക്കുന്നു';

  @override
  String get readyToReview => 'പരിശോധിക്കാൻ തയ്യാറാണ്';

  @override
  String get someResultsNeedReview => 'ചില ഫലങ്ങൾ പരിശോധിക്കേണ്ടതുണ്ട്';

  @override
  String get couldNotReadReport => 'റിപ്പോർട്ട് വായിക്കാനായില്ല';

  @override
  String get processingStopped => 'പ്രോസസിംഗ് നിർത്തി';

  @override
  String get couldNotProcessReport => 'റിപ്പോർട്ട് പ്രോസസ് ചെയ്യാനായില്ല';

  @override
  String get reportRefreshFailed =>
      'ഈ റിപ്പോർട്ട് പുതുക്കാനായില്ല. അവസാനം ലോഡ് ചെയ്ത ഫലം കാണിക്കുന്നു.';

  @override
  String get multipleSampleDates => 'ഒന്നിലധികം സാമ്പിൾ തീയതികൾ ';

  @override
  String get missingSampleDate => 'സാമ്പിൾ തീയതി കണ്ടെത്തിയില്ല ';

  @override
  String get reportAnalyzing =>
      'ഈ റിപ്പോർട്ട് വിശകലനം ചെയ്യുന്നു. നിങ്ങൾക്ക് ഈ സ്ക്രീനിൽ നിന്ന് പോകാം; ഫലങ്ങൾ തയ്യാറാകുമ്പോൾ കാണാം.';

  @override
  String get extractionIncompleteTitle =>
      'എല്ലാ ഫലങ്ങളും വിശ്വസനീയമായി വേർതിരിച്ചെടുക്കാനായില്ല';

  @override
  String get extractionIncompleteHelp =>
      'സ്വയമേവ വിവരങ്ങൾ വേർതിരിച്ചെടുക്കുന്ന പ്രക്രിയ പൂർത്തിയായില്ല. കണ്ടെത്തിയ വരികൾ സംരക്ഷിക്കുന്നതിന് മുമ്പ് യഥാർത്ഥ റിപ്പോർട്ടുമായി ഒത്തുനോക്കുക.';

  @override
  String get verifiedRowsHelp =>
      'ഈ വരികൾ യഥാർത്ഥ റിപ്പോർട്ടുമായി ഒത്തുനോക്കിയിട്ടുണ്ട്. മറ്റ് വരികൾ ഇനിയും പരിശോധിക്കേണ്ടതുണ്ടാകാം.';

  @override
  String get noTestValues =>
      'ഈ റിപ്പോർട്ടിൽ പരിശോധനാ മൂല്യങ്ങളൊന്നും കണ്ടെത്തിയില്ല. ഉള്ളടക്കം പരിശോധിക്കാൻ യഥാർത്ഥ ഫയൽ തുറക്കുക.';

  @override
  String get processingRetryHelp =>
      'പൂർത്തിയാകുന്നതിന് മുമ്പ് പ്രോസസിംഗ് നിർത്തി. നിങ്ങളുടെ ഫയൽ സംരക്ഷിച്ചിട്ടുണ്ട്. വീണ്ടും ശ്രമിക്കാൻ \'വീണ്ടും ശ്രമിക്കുക\' ടാപ്പ് ചെയ്യുക.';

  @override
  String get resultsNeedCheck =>
      'ചില ഫലങ്ങൾ യഥാർത്ഥ റിപ്പോർട്ടുമായി ഒത്തുനോക്കേണ്ടതുണ്ട്. താഴെ കണ്ടെത്തിയ വരികൾ നിങ്ങൾക്ക് പരിശോധിക്കാം.';

  @override
  String get readerModeHelp =>
      'എളുപ്പത്തിൽ കാണാനും വായിക്കാനുമായി വിവരങ്ങൾ വേർതിരിച്ചെടുത്ത റിപ്പോർട്ട് വായനാ മോഡിൽ ലഭ്യമാണ്.';

  @override
  String get aiRangeHelp =>
      'പ്രോസസിംഗിനിടെ AI വ്യാഖ്യാനിച്ച പരിധി. യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക.';

  @override
  String get checkResultHelp =>
      'ഈ ഫലത്തെ ആശ്രയിക്കുന്നതിന് മുമ്പ് യഥാർത്ഥ റിപ്പോർട്ടുമായി ഒത്തുനോക്കുക.';

  @override
  String get preferredRangeHelp =>
      'ലാബ് അച്ചടിച്ചിട്ടുള്ള അഭികാമ്യ വിഭാഗവുമായി താരതമ്യം ചെയ്തിരിക്കുന്നു; അത് നിങ്ങൾക്ക് ബാധകമാണെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get categoryComparisonHelp =>
      'ഈ താരതമ്യത്തിന് ലാബ് അച്ചടിച്ചിട്ടുള്ള അഭികാമ്യ വിഭാഗമാണ് ഉപയോഗിക്കുന്നത്. ആ വിഭാഗം നിങ്ങൾക്ക് ബാധകമാണെന്ന് പരിശോധിക്കുക.';

  @override
  String get missingSavedResult =>
      'ഈ മൂല്യവുമായി പൊരുത്തപ്പെടുന്ന സംരക്ഷിച്ച ഫലം കണ്ടെത്താനായില്ല. യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക അല്ലെങ്കിൽ ഈ റിപ്പോർട്ട് പുതുക്കുക.';

  @override
  String get unreviewedTest =>
      'AI വിശദീകരണങ്ങൾക്കായി ഈ പരിശോധന ഇതുവരെ അവലോകനം ചെയ്തിട്ടില്ല. യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിച്ച് ഫലത്തെക്കുറിച്ച് നിങ്ങളുടെ ഡോക്ടറുമായി ചർച്ച ചെയ്യുക.';

  @override
  String get unsafeResult =>
      'വേർതിരിച്ചെടുത്ത ഫലം വ്യക്തമല്ലാത്തതിനാൽ അത് സുരക്ഷിതമായി വിശദീകരിക്കാനാവില്ല. യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക.';

  @override
  String get filterReports => 'റിപ്പോർട്ടുകൾ ഫിൽട്ടർ ചെയ്യുക';

  @override
  String get sortReports => 'റിപ്പോർട്ടുകൾ ക്രമത്തിൽ അടുക്കുക';

  @override
  String get recycleBin => 'റീസൈക്കിൾ ബിൻ';

  @override
  String get healthHistory => 'ആരോഗ്യ ചരിത്രം';

  @override
  String get shareProfile => 'പ്രൊഫൈൽ പങ്കിടുക';

  @override
  String get reportsUnavailableTitle => 'റിപ്പോർട്ടുകൾ ലഭ്യമല്ല';

  @override
  String get reportsLoadFailed =>
      'റിപ്പോർട്ടുകൾ ലോഡ് ചെയ്യാനായില്ല. കണക്ഷൻ ലഭിക്കുമ്പോൾ വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get upload => 'അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get reportsFor => 'റിപ്പോർട്ടുകൾ കാണുന്നത്';

  @override
  String get searchReports => 'റിപ്പോർട്ടുകളോ ലാബുകളോ തിരയുക';

  @override
  String get filters => 'ഫിൽട്ടറുകൾ';

  @override
  String get noReportsYet => 'ഇതുവരെ റിപ്പോർട്ടുകളില്ല';

  @override
  String get noMatchingReports =>
      'നിങ്ങളുടെ തിരച്ചിലുമായി പൊരുത്തപ്പെടുന്ന റിപ്പോർട്ടുകളില്ല.';

  @override
  String get differentSearch =>
      'മറ്റൊരു പരിശോധനയോ ലബോറട്ടറിയോ ഫിൽട്ടറോ ഉപയോഗിച്ച് ശ്രമിക്കുക.';

  @override
  String get clearFilters => 'തിരച്ചിലും ഫിൽട്ടറുകളും മായ്ക്കുക';

  @override
  String get original => 'യഥാർത്ഥ റിപ്പോർട്ട്';

  @override
  String get switchActiveProfile => 'മറ്റൊരു സജീവ പ്രൊഫൈലിലേക്ക് മാറുക';

  @override
  String get switchProfileHelp =>
      'മറ്റൊരാളുടെ റിപ്പോർട്ടുകൾ കാണുക. അപ്‌ലോഡുകൾക്കും കാലക്രമത്തിലുള്ള മാറ്റങ്ങൾക്കും ഉപയോഗിക്കുന്ന നിങ്ങളുടെ സജീവ പ്രൊഫൈലും മാറും.';

  @override
  String get multipleCollectionDates => 'ഒന്നിലധികം സാമ്പിൾ ശേഖരണ തീയതികൾ';

  @override
  String get unknownCollectionDate => 'സാമ്പിൾ ശേഖരിച്ച തീയതി അറിയില്ല';

  @override
  String get profileLoadFailed =>
      'പ്രൊഫൈലുകൾ ലോഡ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get pleaseTryAgain => 'വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get deleteProfileConfirm => 'പ്രൊഫൈൽ ഇല്ലാതാക്കണോ?';

  @override
  String get deleteProfileHelp =>
      'ഈ പ്രൊഫൈൽ നീക്കം ചെയ്യും. ഇതുമായി ബന്ധിപ്പിച്ചിട്ടുള്ള എല്ലാ ഡാറ്റയെയും ഇത് ബാധിക്കും.';

  @override
  String get profileDeleteFailed =>
      'പ്രൊഫൈൽ ഇല്ലാതാക്കാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get addFamilyMember => 'കുടുംബാംഗത്തെ ചേർക്കുക';

  @override
  String get familyUnavailable => 'കുടുംബ പ്രൊഫൈലുകൾ ലഭ്യമല്ല';

  @override
  String get familyIntro =>
      'ഓരോ വ്യക്തിക്കും അനുസരിച്ച് ക്രമപ്പെടുത്തിയ റിപ്പോർട്ടുകളും കാലക്രമത്തിലുള്ള മാറ്റങ്ങളും';

  @override
  String get noProfilesYet => 'ഇതുവരെ പ്രൊഫൈലുകളില്ല';

  @override
  String get noProfilesHelp =>
      'നിങ്ങളുടെയോ കുടുംബാംഗങ്ങളുടെയോ റിപ്പോർട്ടുകൾ ക്രമപ്പെടുത്താൻ ഒരു പ്രൊഫൈൽ ചേർക്കുക.';

  @override
  String get yourFamily => 'നിങ്ങളുടെ കുടുംബം';

  @override
  String get upgradeProfiles => 'കൂടുതൽ പ്രൊഫൈലുകൾ ചേർക്കാൻ അപ്‌ഗ്രേഡ് ചെയ്യുക';

  @override
  String get editProfile => 'പ്രൊഫൈൽ തിരുത്തുക';

  @override
  String get deleteProfile => 'പ്രൊഫൈൽ ഇല്ലാതാക്കുക';

  @override
  String get active => 'സജീവം';

  @override
  String get setActive => 'സജീവമാക്കുക';

  @override
  String get viewReports => 'റിപ്പോർട്ടുകൾ കാണുക';

  @override
  String get notNow => 'ഇപ്പോൾ വേണ്ട';

  @override
  String get openSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get enableNotifications => 'അറിയിപ്പുകൾ പ്രവർത്തനക്ഷമമാക്കുക';

  @override
  String get enableNotificationsConfirm => 'അറിയിപ്പുകൾ പ്രവർത്തനക്ഷമമാക്കണോ?';

  @override
  String get notificationsEnabled =>
      'റിപ്പോർട്ട് അറിയിപ്പുകൾ പ്രവർത്തനക്ഷമമാക്കി';

  @override
  String get notificationsStayOff =>
      'അറിയിപ്പുകൾ പ്രവർത്തനരഹിതമായി തുടരുന്നു. ഉപകരണത്തിന്റെ ക്രമീകരണങ്ങളിൽ പിന്നീട് അവ പ്രവർത്തനക്ഷമമാക്കാം.';

  @override
  String get notificationsFailed =>
      'അറിയിപ്പുകൾ പ്രവർത്തനക്ഷമമാക്കാനായില്ല. നിങ്ങളുടെ കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get switchProfileFailed =>
      'മറ്റൊരു പ്രൊഫൈലിലേക്ക് മാറാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get sourceReportFailed => 'ഉറവിട റിപ്പോർട്ട് തുറക്കാനായില്ല.';

  @override
  String get partialRefreshFailed =>
      'ചില വിവരങ്ങൾ പുതുക്കാനായില്ല. വീണ്ടും ശ്രമിക്കാൻ താഴേക്ക് വലിക്കുക.';

  @override
  String get knowReportReady => 'നിങ്ങളുടെ റിപ്പോർട്ട് തയ്യാറാകുമ്പോൾ അറിയുക';

  @override
  String get oneResult => 'ഒരു ഫലം';

  @override
  String get sameDayResults => 'ഒരേ ദിവസത്തെ ഫലങ്ങൾ';

  @override
  String get verificationRequired => 'സ്ഥിരീകരണം ആവശ്യമാണ്';

  @override
  String get accountCreatedLogin =>
      'നിങ്ങളുടെ അക്കൗണ്ട് വിജയകരമായി സൃഷ്ടിച്ചു. ലോഗിൻ ചെയ്യാൻ തുടരുക.';

  @override
  String get continueLogin => 'ലോഗിൻ ചെയ്യാൻ തുടരുക';

  @override
  String get allReports => 'എല്ലാ റിപ്പോർട്ടുകളും';

  @override
  String get filterReviewed => 'പരിശോധിച്ചത്';

  @override
  String get filterNeedsReview => 'പരിശോധിക്കേണ്ടത്';

  @override
  String get filterProcessing => 'പ്രോസസ് ചെയ്യുന്നു';

  @override
  String get filterOriginalOnly => 'യഥാർത്ഥ റിപ്പോർട്ട് മാത്രം';

  @override
  String get reportDateNewest => 'റിപ്പോർട്ട് തീയതി · പുതിയത് ആദ്യം';

  @override
  String get reportDateOldest => 'റിപ്പോർട്ട് തീയതി · പഴയത് ആദ്യം';

  @override
  String get uploadDateNewest => 'അപ്‌ലോഡ് തീയതി · പുതിയത് ആദ്യം';

  @override
  String get uploadDateOldest => 'അപ്‌ലോഡ് തീയതി · പഴയത് ആദ്യം';

  @override
  String get switchAction => 'മാറുക';

  @override
  String get collectionDate => 'സാമ്പിൾ ശേഖരിച്ച തീയതി';

  @override
  String get copy => 'പകർത്തുക';

  @override
  String get history => 'ചരിത്രം';

  @override
  String get loadingReport => 'റിപ്പോർട്ട് ലോഡ് ചെയ്യുന്നു…';

  @override
  String get restore => 'പുനഃസ്ഥാപിക്കുക';

  @override
  String get revoke => 'അസാധുവാക്കുക';

  @override
  String get testName => 'പരിശോധനയുടെ പേര്';

  @override
  String get viewReport => 'റിപ്പോർട്ട് കാണുക';

  @override
  String get closeAccount => 'അക്കൗണ്ട് അടയ്ക്കുക';

  @override
  String get createShareLink => 'പങ്കിടാനുള്ള ലിങ്ക് സൃഷ്ടിക്കുക';
}
