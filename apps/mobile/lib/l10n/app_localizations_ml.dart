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

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'രൂപഭാവം മാറി, പക്ഷേ അടുത്ത തവണ സംരക്ഷിക്കാനായില്ല.';

  @override
  String get uiThisReportIsNoLongerAvailable => 'ഈ റിപ്പോർട്ട് ഇനി ലഭ്യമല്ല.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'അറിയിപ്പ് പ്രിവ്യൂകൾ നിയന്ത്രിക്കാൻ ഉപകരണ ക്രമീകരണങ്ങൾ തുറക്കുക.';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'അപ്‌ലോഡ് സ്വീകരിക്കുന്നത് വരെ ഈ സ്‌ക്രീൻ തുറന്നിടുക.';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'ഒരു അപ്‌ലോഡ് തടസ്സപ്പെട്ടിരിക്കാം';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'റിപ്പോർട്ടുകൾ പരിശോധിക്കുക. അത് നഷ്ടപ്പെട്ടാൽ, അതേ ഫയൽ വീണ്ടും ചേർക്കുക.';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'അറിയിപ്പുകൾ നിരസിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiConnectionUnavailable => 'കണക്ഷൻ ലഭ്യമല്ല';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'നിങ്ങളുടെ സെഷൻ പരിശോധിക്കാനായില്ല. ഇൻ്റർനെറ്റിലേക്ക് കണക്‌റ്റ് ചെയ്‌ത് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiSignInWithAnotherAccount =>
      'മറ്റൊരു അക്കൗണ്ട് ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക';

  @override
  String get uiNoActiveProfile => 'സജീവ പ്രൊഫൈലൊന്നുമില്ല';

  @override
  String get uiDismissUploadNotice => 'അപ്‌ലോഡ് അറിയിപ്പ് നിരസിക്കുക';

  @override
  String get uiDismissReadyNotifications => 'തയ്യാറായ അറിയിപ്പുകൾ നിരസിക്കുക';

  @override
  String get uiRequestSupport => 'പിന്തുണ അഭ്യർത്ഥിക്കുക';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'ഞങ്ങൾ ഡയഗ്നോസ്റ്റിക് ഐഡികൾ ഉൾപ്പെടുത്തും, അതിനാൽ ടീമിന് അന്വേഷിക്കാനാകും.';

  @override
  String get uiSendRequest => 'അഭ്യർത്ഥന അയയ്ക്കുക';

  @override
  String get uiWhatHappenedOptional => 'എന്ത് സംഭവിച്ചു? (ഓപ്ഷണൽ)';

  @override
  String get uiReviewResult => 'ഫലം അവലോകനം ചെയ്യുക';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'സംരക്ഷിക്കുന്നതിന് മുമ്പ് ഈ ഫീൽഡുകൾ യഥാർത്ഥ റിപ്പോർട്ടുമായി താരതമ്യം ചെയ്യുക.';

  @override
  String get uiOriginallyExtracted => 'യഥാർത്ഥത്തിൽ വേർതിരിച്ചെടുത്തത്';

  @override
  String get uiReloadReport => 'റിപ്പോർട്ട് റീലോഡ് ചെയ്യുക';

  @override
  String get uiResultAsPrinted => 'ഫലം അച്ചടിച്ചതുപോലെ';

  @override
  String get uiUnitIfShown => 'യൂണിറ്റ് (കാണിച്ചാൽ)';

  @override
  String get uiLabReferenceRangeIfShown => 'ലാബ് റഫറൻസ് ശ്രേണി (കാണിച്ചാൽ)';

  @override
  String get uiCheckYourReport => 'നിങ്ങളുടെ റിപ്പോർട്ട് പരിശോധിക്കുക';

  @override
  String get uiNoAttemptHistoryAvailable => 'ശ്രമ ചരിത്രമൊന്നും ലഭ്യമല്ല.';

  @override
  String get uiIInspectedTheOriginal => 'ഞാൻ ഒറിജിനൽ പരിശോധിച്ചു';

  @override
  String get uiChooseTwoReports => 'രണ്ട് റിപ്പോർട്ടുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'ഒരേ വ്യക്തിക്കായി റെക്കോർഡുകൾ ഉപയോഗിക്കുക. മാച്ചിംഗ് ടെസ്റ്റുകൾ വശങ്ങളിലായി ദൃശ്യമാകും.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'ആദ്യം പഴയ റിപ്പോർട്ടും രണ്ടാമത്തേത് പുതിയതും തിരഞ്ഞെടുക്കുക.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'പൊരുത്തപ്പെടുമ്പോൾ മാത്രം താരതമ്യം ചെയ്യുക. അനുയോജ്യത സ്ഥിരീകരിക്കുന്നത് വരെ വ്യത്യസ്ത യൂണിറ്റുകൾ അല്ലെങ്കിൽ രീതികൾ പ്രത്യേകം കാണിക്കുന്നു.';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'മാറ്റം ഒരു രോഗനിർണയമല്ല. ഓരോ ഫലവും അതിൻ്റേതായ റിപ്പോർട്ട് ഇടവേളയുമായി താരതമ്യം ചെയ്ത് നിങ്ങളുടെ ക്ലിനിക്കുമായി സന്ദർഭം ചർച്ച ചെയ്യുക.';

  @override
  String get uiChooseDifferentReports =>
      'വ്യത്യസ്ത റിപ്പോർട്ടുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get uiEarlierReport => 'നേരത്തെ റിപ്പോർട്ട്';

  @override
  String get uiLaterReport => 'പിന്നീട് റിപ്പോർട്ട്';

  @override
  String get uiYourReportPages => 'നിങ്ങളുടെ റിപ്പോർട്ട് പേജുകൾ';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'റിപ്പോർട്ടിൻ്റെ അതേ ക്രമത്തിൽ പേജുകൾ സൂക്ഷിക്കുക.';

  @override
  String get uiAddAnotherPage => 'മറ്റൊരു പേജ് ചേർക്കുക';

  @override
  String get uiChoosePagesFromGallery =>
      'ഗാലറിയിൽ നിന്ന് പേജുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get uiAdjustPage => 'പേജ് ക്രമീകരിക്കുക';

  @override
  String get uiRetake => 'വീണ്ടും എടുക്കുക';

  @override
  String get uiUseAdjustedPage => 'ക്രമീകരിച്ച പേജ് ഉപയോഗിക്കുക';

  @override
  String get uiResetChanges => 'മാറ്റങ്ങൾ പുനഃസജ്ജമാക്കുക';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'എല്ലാ ഫലങ്ങളും കോണുകൾക്കുള്ളിൽ സൂക്ഷിക്കുക.';

  @override
  String get uiRotate => 'തിരിക്കുക';

  @override
  String get uiReportRestored => 'റിപ്പോർട്ട് പുനഃസ്ഥാപിച്ചു';

  @override
  String get uiDeleteReportPermanently =>
      'റിപ്പോർട്ട് ശാശ്വതമായി ഇല്ലാതാക്കണോ?';

  @override
  String get uiDeletePermanently => 'ശാശ്വതമായി ഇല്ലാതാക്കുക';

  @override
  String get uiReportPermanentlyDeleted => 'റിപ്പോർട്ട് ശാശ്വതമായി ഇല്ലാതാക്കി';

  @override
  String get uiEmptyRecycleBin => 'ശൂന്യമായ റീസൈക്കിൾ ബിൻ?';

  @override
  String get uiDeleteAll => 'എല്ലാം ഇല്ലാതാക്കുക';

  @override
  String get uiRecycleBinIsEmpty => 'റീസൈക്കിൾ ബിൻ ശൂന്യമാണ്.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'നീക്കം ചെയ്യുന്നതിനുമുമ്പ് ഇല്ലാതാക്കിയ റിപ്പോർട്ടുകൾ ഇവിടെ ദൃശ്യമാകും.';

  @override
  String get uiEmptyRecycleBind657e2 => 'ശൂന്യമായ റീസൈക്കിൾ ബിൻ';

  @override
  String get uiCheckDetectedResult => 'കണ്ടെത്തിയ ഫലം പരിശോധിക്കുക';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'ഈ വരി യഥാർത്ഥ റിപ്പോർട്ടുമായി താരതമ്യം ചെയ്യുക. സംരക്ഷിക്കുന്നതിന് മുമ്പ് ഏതെങ്കിലും OCR തെറ്റുകൾ തിരുത്തുക.';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'യഥാർത്ഥ റിപ്പോർട്ടിന് വിരുദ്ധമായി ഞാൻ ഈ ഫലം പരിശോധിച്ചു';

  @override
  String get uiSaving => 'സംരക്ഷിക്കുന്നു...';

  @override
  String get uiSaveVerifiedResult => 'പരിശോധിച്ച ഫലം സംരക്ഷിക്കുക';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'ഫലങ്ങളൊന്നും കണ്ടെത്തിയില്ല. യഥാർത്ഥ റിപ്പോർട്ട് കാണുക അല്ലെങ്കിൽ പ്രോസസ്സിംഗ് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'കണ്ടെത്തിയ മൂല്യങ്ങൾ സംരക്ഷിച്ച ഫലങ്ങളാകുന്നതിന് മുമ്പ് യഥാർത്ഥ റിപ്പോർട്ടിനെതിരെ പരിശോധിക്കേണ്ടതുണ്ട്.';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'ചില വരികൾ നഷ്ടമായേക്കാം. മുഴുവൻ യഥാർത്ഥ റിപ്പോർട്ടും പരിശോധിക്കുക.';

  @override
  String get uiResult => 'ഫലം';

  @override
  String get uiUnitOptional => 'യൂണിറ്റ് (ഓപ്ഷണൽ)';

  @override
  String get uiReferenceRangeOptional => 'റഫറൻസ് ശ്രേണി (ഓപ്ഷണൽ)';

  @override
  String get uiVerified => 'പരിശോധിച്ചുറപ്പിച്ചു';

  @override
  String get uiGiftVoucher => 'സമ്മാന വൗച്ചർ';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'ഒരു സമ്മാന വൗച്ചർ റിഡീം ചെയ്‌ത് നിങ്ങളുടെ ബാലൻസിലേക്ക് നേരിട്ട് ക്രെഡിറ്റുകൾ ചേർക്കുക.';

  @override
  String get uiCurrentPlan => 'നിലവിലെ പ്ലാൻ';

  @override
  String get uiCreditBalance => 'ക്രെഡിറ്റ് ബാലൻസ്';

  @override
  String get uiPlanLimits => 'പ്ലാൻ പരിധികൾ';

  @override
  String get uiBuyCredits => 'ക്രെഡിറ്റുകൾ വാങ്ങുക';

  @override
  String get uiRecentBillingActivity => 'സമീപകാല ബില്ലിംഗ് പ്രവർത്തനം';

  @override
  String get uiRefreshStatus => 'സ്റ്റാറ്റസ് പുതുക്കുക';

  @override
  String get uiNoRecentOrdersYet => 'ഇതുവരെ സമീപകാല ഓർഡറുകൾ ഒന്നുമില്ല.';

  @override
  String get uiVoucherCode => 'വൗച്ചർ കോഡ്';

  @override
  String get uiCheckout => 'ചെക്ക്ഔട്ട്';

  @override
  String get uiApply => 'അപേക്ഷിക്കുക';

  @override
  String get uiClear => 'ക്ലിയർ';

  @override
  String get uiPay => 'പണം നൽകുക';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'ഈ സമയത്ത് ക്രെഡിറ്റ് പാക്കുകളൊന്നും ലഭ്യമല്ല.';

  @override
  String get uiBuy => 'വാങ്ങുക';

  @override
  String get uiRetryPayment => 'പണമടയ്ക്കാൻ വീണ്ടും ശ്രമിക്കുക';

  @override
  String get uiPromoCode => 'പ്രൊമോ കോഡ്';

  @override
  String get uiEnterPromoCode => 'പ്രൊമോ കോഡ് നൽകുക';

  @override
  String get uiChooseAPlan => 'ഒരു പ്ലാൻ തിരഞ്ഞെടുക്കുക';

  @override
  String get uiNoPlansAvailableAtThisTime => 'ഇപ്പോൾ പ്ലാനുകളൊന്നും ലഭ്യമല്ല.';

  @override
  String get uiHaveAPromoCode => 'ഒരു പ്രൊമോ കോഡ് ഉണ്ടോ?';

  @override
  String get uiCURRENTPLAN => 'നിലവിലെ പ്ലാൻ';

  @override
  String get uiManageNotifications => 'അറിയിപ്പുകൾ നിയന്ത്രിക്കുക';

  @override
  String get uiAll => 'എല്ലാം';

  @override
  String get uiUnread => 'വായിക്കാത്തത്';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'പ്രവേശനം ഉടനടി നിർത്തുന്നു. നിങ്ങൾക്ക് 30 ദിവസത്തിനുള്ളിൽ സൈൻ ഇൻ ചെയ്യാനും പുനഃസ്ഥാപിക്കാനും കഴിയും. അതിനുശേഷം, നിങ്ങളുടെ അക്കൗണ്ടും സംഭരിച്ച ഫയലുകളും സജീവ സ്റ്റോറേജിൽ നിന്ന് ഇല്ലാതാക്കപ്പെടും.';

  @override
  String get uiCloseMyAccount => 'എൻ്റെ അക്കൗണ്ട് ക്ലോസ് ചെയ്യുക';

  @override
  String get uiYourRecordsStayInDoclyzer =>
      'നിങ്ങളുടെ രേഖകൾ ഡോക്ലൈസറിൽ നിലനിൽക്കും.';

  @override
  String get uiTakeACopyOfYourRecords =>
      'നിങ്ങളുടെ രേഖകളുടെ ഒരു പകർപ്പ് എടുക്കുക.';

  @override
  String get uiWhoseRecords => 'ആരുടെ രേഖകൾ?';

  @override
  String get uiCouldNotLoadProfiles => 'പ്രൊഫൈലുകൾ ലോഡ് ചെയ്യാനായില്ല';

  @override
  String get uiLoadingProfiles => 'പ്രൊഫൈലുകൾ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get uiAllProfiles => 'എല്ലാ പ്രൊഫൈലുകളും';

  @override
  String get uiDateRange => 'തീയതി ശ്രേണി';

  @override
  String get uiUseAllDates => 'എല്ലാ തീയതികളും ഉപയോഗിക്കുക';

  @override
  String get uiINCLUDEINTHISEXPORT => 'ഈ കയറ്റുമതിയിൽ ഉൾപ്പെടുത്തുക';

  @override
  String get uiOriginalReports => 'യഥാർത്ഥ റിപ്പോർട്ടുകൾ';

  @override
  String get uiPDFsAndImagesYouUploaded =>
      'നിങ്ങൾ അപ്‌ലോഡ് ചെയ്ത PDF-കളും ചിത്രങ്ങളും';

  @override
  String get uiTestResults => 'പരിശോധനാ ഫലങ്ങൾ';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'CSV ആയി ഫലങ്ങൾ, അവയുടെ അവലോകന നില';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'കയറ്റുമതിയിൽ വ്യക്തിഗത വിവരങ്ങൾ അടങ്ങിയിരിക്കുന്നു. നിങ്ങൾ വിശ്വസിക്കുന്ന എവിടെയെങ്കിലും അവ സൂക്ഷിക്കുക.';

  @override
  String get uiDeleteAccount => 'അക്കൗണ്ട് ഇല്ലാതാക്കുക';

  @override
  String get uiContinueToDeletion => 'ഇല്ലാതാക്കുന്നത് തുടരുക';

  @override
  String get uiKeepMyAccount => 'എൻ്റെ അക്കൗണ്ട് സൂക്ഷിക്കുക';

  @override
  String get uiBeforeYouLeave => 'നിങ്ങൾ പോകുന്നതിനുമുമ്പ്';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'ഇത് എന്ത് നീക്കംചെയ്യുമെന്ന് ദയവായി വായിക്കുക.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'നിങ്ങളുടെ അക്കൗണ്ട് ഇല്ലാതാക്കുന്നത് നിങ്ങൾ നിയന്ത്രിക്കുന്ന എല്ലാ പ്രൊഫൈലുകളെയും ബാധിക്കും.';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'നിങ്ങളുടെ അക്കൗണ്ടും വ്യക്തിഗത പ്രൊഫൈലും';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'നിങ്ങളുടെ പങ്കിട്ട ലിങ്കുകളിലൂടെ ആക്സസ് ചെയ്യുക';

  @override
  String get uiKeepACopyFirst => 'ആദ്യം ഒരു കോപ്പി സൂക്ഷിക്കുക';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'നിങ്ങൾ നിലനിർത്താൻ ആഗ്രഹിക്കുന്ന വിവരങ്ങൾ കയറ്റുമതി ചെയ്യുക.';

  @override
  String get uiExportData => 'ഡാറ്റ കയറ്റുമതി ചെയ്യുക';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'പ്രവേശനം ഉടനടി നിർത്തുന്നു. നിങ്ങൾക്ക് 30 ദിവസത്തിനുള്ളിൽ പുനഃസ്ഥാപിക്കാം. അതിനുശേഷം, നിങ്ങളുടെ ഡാറ്റ സജീവ സംഭരണത്തിൽ നിന്ന് നീക്കം ചെയ്യപ്പെടും.';

  @override
  String get uiAccountPendingDeletion => 'അക്കൗണ്ട് ഇല്ലാതാക്കാൻ ശേഷിക്കുന്നു';

  @override
  String get uiRestoreMyAccount => 'എൻ്റെ അക്കൗണ്ട് പുനഃസ്ഥാപിക്കുക';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'നിങ്ങളുടെ പ്രൊഫൈൽ, പ്രൊഫൈലുകൾ, സമ്മത രേഖകൾ എന്നിവയുൾപ്പെടെ നിങ്ങളുടെ അക്കൗണ്ട് ഡാറ്റയുടെ ഒരു പകർപ്പ് ഡൗൺലോഡ് ചെയ്യുക.';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'നിങ്ങളുടെ അക്കൗണ്ട് ഉടൻ പ്രവർത്തനരഹിതമാക്കി. 30 ദിവസത്തിനുള്ളിൽ നിങ്ങൾക്ക് ഇത് പുനഃസ്ഥാപിക്കാം. അതിനുശേഷം, നിങ്ങളുടെ ഡാറ്റ ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടും.';

  @override
  String get uiCurrentPassword => 'നിലവിലെ പാസ്‌വേഡ്';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'ആപ്പ് ലോക്ക് മാറ്റാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'നിങ്ങളുടെ രേഖകൾ.\nപങ്കിടാനുള്ള നിങ്ങളുടെ ഇഷ്ടം.';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'നിങ്ങൾക്ക് ആവശ്യമുള്ളപ്പോഴെല്ലാം ആക്സസ് അവലോകനം ചെയ്യുക.';

  @override
  String get uiAppLock => 'ആപ്പ് ലോക്ക്';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'നിങ്ങളുടെ ഉപകരണത്തിൻ്റെ ബയോമെട്രിക് അല്ലെങ്കിൽ പാസ്‌കോഡ് ലോക്ക് ഉപയോഗിക്കുക.';

  @override
  String get uiNotificationPreviews => 'അറിയിപ്പ് പ്രിവ്യൂകൾ';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'നിങ്ങളുടെ ഉപകരണ ക്രമീകരണങ്ങളിൽ ലോക്ക് സ്‌ക്രീൻ പ്രിവ്യൂകൾ നിയന്ത്രിക്കുക.';

  @override
  String get uiContactSupport => 'പിന്തുണയുമായി ബന്ധപ്പെടുക';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'നിങ്ങൾ തിരഞ്ഞെടുക്കുകയാണെങ്കിൽ മാത്രം റിപ്പോർട്ടുകൾ അറ്റാച്ചുചെയ്യുക.';

  @override
  String get uiWhatCanWeHelpYouWith =>
      'ഞങ്ങൾക്ക് നിങ്ങളെ എന്ത് സഹായിക്കാനാകും?';

  @override
  String get uiPOPULARQUESTIONS => 'ജനപ്രിയ ചോദ്യങ്ങൾ';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'നിങ്ങളുടെ തിരയലുമായി പൊരുത്തപ്പെടുന്ന സഹായ ലേഖനങ്ങളൊന്നുമില്ല.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'നിങ്ങളുടെ ആരോഗ്യത്തെക്കുറിച്ചോ പരിശോധനാ ഫലങ്ങളെക്കുറിച്ചോ ഉള്ള ചോദ്യങ്ങൾക്ക്, യോഗ്യതയുള്ള ഒരു ഹെൽത്ത് കെയർ പ്രൊഫഷണലുമായി സംസാരിക്കുക.';

  @override
  String get uiYourReportsAClearerPicture =>
      'നിങ്ങളുടെ റിപ്പോർട്ടുകൾ. കൂടുതൽ വ്യക്തമായ ചിത്രം.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'നിങ്ങളുടെ ആരോഗ്യ ചരിത്രം ഒരുമിച്ച് സൂക്ഷിക്കുക.';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'റിപ്പോർട്ടുകൾ സംഭരിക്കുക, ഫലങ്ങൾ അവലോകനം ചെയ്യുക, മാറ്റങ്ങൾ പിന്തുടരുക, നിങ്ങളുടെ ഡോക്ടറുമായി പങ്കിടുക.';

  @override
  String get uiEducationalInformationOnly => 'വിദ്യാഭ്യാസ വിവരങ്ങൾ മാത്രം';

  @override
  String get uiSearchHelpArticles => 'സഹായ ലേഖനങ്ങൾ തിരയുക';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'അറിയിപ്പ് ആക്‌സസ് മാറ്റാൻ ഉപകരണ ക്രമീകരണ ആപ്പ് തുറക്കുക.';

  @override
  String get uiSavePreferences => 'മുൻഗണനകൾ സംരക്ഷിക്കുക';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'ക്രമീകരണങ്ങളിൽ ഉപകരണ അനുമതികൾ മാറ്റാവുന്നതാണ്.';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'ഈ ഉപകരണത്തിൽ റിപ്പോർട്ട് അപ്ഡേറ്റുകൾ നേടുക';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'ഒരു റിപ്പോർട്ട് തയ്യാറാകുമ്പോൾ അറിയാൻ അറിയിപ്പുകളെ അനുവദിക്കുക. മാർക്കറ്റിംഗ് താഴെ ഒരു പ്രത്യേക ചോയ്സ് ആണ്.';

  @override
  String get uiREPORTACTIVITY => 'റിപ്പോർട്ട് പ്രവർത്തനം';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'റിപ്പോർട്ട് പ്രവർത്തന ക്രമീകരണങ്ങൾക്ക് ഏറ്റവും പുതിയ സെർവർ പതിപ്പ് ആവശ്യമാണ്.';

  @override
  String get uiSensitiveLockScreenPreviews =>
      'സെൻസിറ്റീവ് ലോക്ക് സ്‌ക്രീൻ പ്രിവ്യൂകൾ';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'റിപ്പോർട്ടിൻ്റെ പേരുകളും വ്യക്തിഗത വിശദാംശങ്ങളും എല്ലായ്പ്പോഴും മറച്ചിരിക്കുന്നു.';

  @override
  String get uiOTHERMESSAGES => 'മറ്റ് സന്ദേശങ്ങൾ';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'ഓരോ വ്യക്തിയുടെയും റിപ്പോർട്ടുകളും ട്രെൻഡുകളും ഒരുമിച്ച് സൂക്ഷിക്കുക.';

  @override
  String get uiPersonDetails => 'വ്യക്തിയുടെ വിശദാംശങ്ങൾ';

  @override
  String get uiDateOfBirth => 'ജനനത്തീയതി';

  @override
  String get uiRelationship => 'ബന്ധം';

  @override
  String get uiEnterAName => 'ഒരു പേര് നൽകുക';

  @override
  String get uiClearDateOfBirth => 'വ്യക്തമായ ജനനത്തീയതി';

  @override
  String get uiOptionalEGParentOrChild =>
      'ഓപ്ഷണൽ, ഉദാ. മാതാപിതാക്കൾ അല്ലെങ്കിൽ കുട്ടി';

  @override
  String get uiInviteFriendsEarnCredits =>
      'സുഹൃത്തുക്കളെ ക്ഷണിക്കുക, ക്രെഡിറ്റുകൾ നേടുക';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'റിവാർഡ് അൺലോക്ക് ആയി നിങ്ങളുടെ കോഡ് പങ്കിടുകയും ഓരോ ക്ഷണവും പിന്തുടരുകയും ചെയ്യുക.';

  @override
  String get uiYOURREFERRALCODE => 'നിങ്ങളുടെ റഫറൽ കോഡ്';

  @override
  String get uiShareInvite => 'ക്ഷണം പങ്കിടുക';

  @override
  String get uiCopyCode => 'കോഡ് പകർത്തുക';

  @override
  String get uiHaveACode => 'ഒരു കോഡ് ഉണ്ടോ?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'നിങ്ങളുടെ ക്ഷണ റിവാർഡ് ക്ലെയിം ചെയ്യാൻ നിങ്ങളുമായി പങ്കിട്ട ഒരു കോഡ് നൽകുക.';

  @override
  String get uiHowRewardsWork => 'റിവാർഡുകൾ എങ്ങനെ പ്രവർത്തിക്കുന്നു';

  @override
  String get uiNoFriendsReferredYet =>
      'ഇതുവരെ സുഹൃത്തുക്കളൊന്നും റഫർ ചെയ്തിട്ടില്ല';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'അവരുടെ പുരോഗതി കാണുന്നതിന് നിങ്ങളുടെ ക്ഷണം ഇവിടെ പങ്കിടുക.';

  @override
  String get uiReferralCode => 'റഫറൽ കോഡ്';

  @override
  String get uiSetNewPassword => 'പുതിയ പാസ്‌വേഡ് സജ്ജമാക്കുക';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'നിങ്ങളുടെ ഇമെയിലിലെ ലിങ്കിൽ നിന്നും പുതിയ പാസ്‌വേഡിൽ നിന്നും റീസെറ്റ് ടോക്കൺ നൽകുക.';

  @override
  String get uiResetPassword => 'പാസ്‌വേഡ് പുനഃസജ്ജമാക്കുക';

  @override
  String get uiBackToLogin => 'ലോഗിൻ എന്നതിലേക്ക് മടങ്ങുക';

  @override
  String get uiResetToken => 'ടോക്കൺ റീസെറ്റ് ചെയ്യുക';

  @override
  String get uiNewPassword => 'പുതിയ പാസ്‌വേഡ്';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'നിങ്ങളുടെ അക്കൗണ്ടുമായി ബന്ധപ്പെട്ട ഇമെയിൽ വിലാസം നൽകുക, നിങ്ങളുടെ പാസ്‌വേഡ് പുനഃസജ്ജമാക്കാൻ ഞങ്ങൾ ഒരു ലിങ്ക് അയയ്ക്കും.';

  @override
  String get uiSendResetLink => 'റീസെറ്റ് ലിങ്ക് അയയ്ക്കുക';

  @override
  String get uiRevokeSession => 'സെഷൻ പിൻവലിക്കണോ?';

  @override
  String get uiCurrentSession => 'നിലവിലെ സെഷൻ';

  @override
  String get uiSkip => 'ഒഴിവാക്കുക';

  @override
  String get uiChangePassword => 'പാസ്‌വേഡ് മാറ്റുക';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'നിങ്ങളുടെ നിലവിലെ പാസ്‌വേഡ് നൽകി പുതിയൊരെണ്ണം തിരഞ്ഞെടുക്കുക.';

  @override
  String get uiNewPasswordd850ee => 'പുതിയ പാസ്‌വേഡ്';

  @override
  String get uiConfirmNewPassword => 'പുതിയ പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String get uiGettingThingsReady => 'കാര്യങ്ങൾ തയ്യാറാക്കുന്നു...';

  @override
  String get uiLinkAccessHistory => 'ലിങ്ക് ആക്സസ് ചരിത്രം';

  @override
  String get uiNoAccessEventsYet => 'ഇതുവരെ ആക്സസ് ഇവൻ്റുകളൊന്നുമില്ല.';

  @override
  String get uiDefaultShareLinkExpiry =>
      'ഡിഫോൾട്ട് ഷെയർ ലിങ്ക് കാലഹരണപ്പെടുന്നു';

  @override
  String get uiSave => 'സംരക്ഷിക്കുക';

  @override
  String get uiReviewSharing => 'അവലോകനം പങ്കിടൽ';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'വ്യക്തി, റിപ്പോർട്ടുകൾ, ആക്സസ് എന്നിവ പരിശോധിക്കുക.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'തിരഞ്ഞെടുക്കൽ എഡിറ്റ് ചെയ്യുക അല്ലെങ്കിൽ ക്രമീകരണങ്ങൾ ആക്സസ് ചെയ്യുക';

  @override
  String get uiRevokeShareLink => 'പങ്കിടൽ ലിങ്ക് പിൻവലിക്കണോ?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'ഈ ലിങ്ക് പ്രവർത്തിക്കുന്നത് നിർത്തും. നിങ്ങൾക്ക് പുതിയൊരെണ്ണം സൃഷ്ടിക്കാൻ കഴിയും.';

  @override
  String get uiShareLinkReady => 'പങ്കിടൽ ലിങ്ക് തയ്യാറാണ്';

  @override
  String get uiAccessCodeShareSeparately => 'ആക്സസ് കോഡ് - പ്രത്യേകം പങ്കിടുക';

  @override
  String get uiCopyAccessCode => 'ആക്സസ് കോഡ് പകർത്തുക';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'ഈ കോഡ് ഈ ഉപകരണത്തിൽ സംരക്ഷിക്കാനായില്ല. പിന്നീടുള്ള ഉപയോഗത്തിനായി ഇപ്പോൾ പകർത്തുക.';

  @override
  String get uiShareLink => 'ലിങ്ക് പങ്കിടുക';

  @override
  String get uiCopyLink => 'ലിങ്ക് പകർത്തുക';

  @override
  String get uiRevokeLink => 'ലിങ്ക് പിൻവലിക്കുക';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'ഈ ഉപകരണത്തിൽ കോഡ് ലഭ്യമല്ല. സംരക്ഷിച്ച കോഡ് ഉപയോഗിക്കുക അല്ലെങ്കിൽ ഒരു പുതിയ ലിങ്ക് സൃഷ്ടിക്കുക.';

  @override
  String get uiActiveSharedLinks => 'സജീവമായ പങ്കിട്ട ലിങ്കുകൾ';

  @override
  String get uiShare => 'പങ്കിടുക';

  @override
  String get uiCreateANewShareLink => 'ഒരു പുതിയ പങ്കിടൽ ലിങ്ക് സൃഷ്‌ടിക്കുക';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'ഈ പ്രൊഫൈലിനായി നിലവിലുള്ളതും ഭാവിയിലുള്ളതുമായ റിപ്പോർട്ടുകൾ ഉൾപ്പെടുത്തുക.';

  @override
  String get uiChooseReports => 'റിപ്പോർട്ടുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'ചുവടെ തിരഞ്ഞെടുത്ത റിപ്പോർട്ടുകൾ മാത്രം പങ്കിടുക.';

  @override
  String get uiSelectAll => 'എല്ലാം തിരഞ്ഞെടുക്കുക';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'അവലോകനം ചെയ്ത റിപ്പോർട്ടുകളൊന്നും പങ്കിടാൻ ലഭ്യമല്ല.';

  @override
  String get uiSelectedTestResults => 'തിരഞ്ഞെടുത്ത പരിശോധനാ ഫലങ്ങൾ';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'ഈ റിപ്പോർട്ടുകളിൽ നിന്ന് നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന ഫലങ്ങൾ മാത്രം ഉൾപ്പെടുത്തുക.';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'ഈ റിപ്പോർട്ടുകളിൽ സംരക്ഷിച്ച പരിശോധനാ ഫലങ്ങളൊന്നും ലഭ്യമല്ല.';

  @override
  String get uiUpgradeOrManage => 'നവീകരിക്കുക അല്ലെങ്കിൽ നിയന്ത്രിക്കുക';

  @override
  String get uiExpiry => 'കാലഹരണപ്പെടൽ:';

  @override
  String get uiRequireAnAccessCode => 'ഒരു ആക്സസ് കോഡ് ആവശ്യമാണ്';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'ലിങ്കിൽ നിന്ന് പ്രത്യേകമായി കോഡ് പങ്കിടുക.';

  @override
  String get uiTryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get uiClearExpiry => 'കാലഹരണപ്പെടൽ മായ്‌ക്കുക';

  @override
  String get onboardingStoreEyebrow => '01 / സൂക്ഷിക്കുക';

  @override
  String get onboardingStoreTitle =>
      'എല്ലാ റിപ്പോർട്ടുകളും,\nപരിചിതമായ ഒരു സ്ഥലം.';

  @override
  String get onboardingStoreBody =>
      'നിങ്ങൾക്കും നിങ്ങൾ ശ്രദ്ധിക്കുന്ന ആളുകൾക്കുമായി PDF-കളും ഫോട്ടോകളും ഒരുമിച്ച് സൂക്ഷിക്കുക.';

  @override
  String get onboardingUnderstandEyebrow => '02 / മനസ്സിലാക്കുക';

  @override
  String get onboardingUnderstandTitle =>
      'അക്കങ്ങൾ,\nവായിക്കുന്നത് എളുപ്പമാക്കി.';

  @override
  String get onboardingUnderstandBody =>
      'നിങ്ങളുടെ റിപ്പോർട്ടിൽ നിന്ന് ഓരോ ടെസ്റ്റും അതിൻ്റെ യൂണിറ്റും ഇടവേളയും കാണുക. എപ്പോൾ വേണമെങ്കിലും ഒറിജിനൽ പരിശോധിക്കുക.';

  @override
  String get onboardingTrackEyebrow => '03 / ട്രാക്ക് & ഷെയർ ചെയ്യുക';

  @override
  String get onboardingTrackTitle => 'മാറ്റങ്ങൾ കാണുക.\nസന്ദർഭം പങ്കിടുക.';

  @override
  String get onboardingTrackBody =>
      'കാലക്രമേണ ഫലങ്ങൾ പിന്തുടരുക, നിങ്ങളുടെ ഡോക്ടർക്ക് കാണാൻ കഴിയുന്നത് കൃത്യമായി തിരഞ്ഞെടുക്കുക.';

  @override
  String get onboardingNext => 'അടുത്തത്';

  @override
  String get onboardingGetStarted => 'ആരംഭിക്കുക';

  @override
  String get uiSupportRequestSent => 'പിന്തുണ അഭ്യർത്ഥന അയച്ചു.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'ടെസ്റ്റിൻ്റെ പേരും ഫലവും ആവശ്യമാണ്.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD ഫോർമാറ്റിൽ സാധുവായ ഒരു ശേഖരണ തീയതി ഉപയോഗിക്കുക.';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'ഈ തിരുത്തൽ സംരക്ഷിക്കാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiReportsUnavailable => 'റിപ്പോർട്ടുകൾ ലഭ്യമല്ല';

  @override
  String get uiTryAgain042c86 => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get uiTwoReportsAreNeeded => 'രണ്ട് റിപ്പോർട്ടുകൾ ആവശ്യമാണ്';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'ഫലങ്ങൾ താരതമ്യം ചെയ്യാൻ ഈ പ്രൊഫൈലിനായി ഒരു പഴയ റിപ്പോർട്ട് ചേർക്കുക.';

  @override
  String get uiCannotCompareYet => 'ഇതുവരെ താരതമ്യം ചെയ്യാൻ കഴിയില്ല';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'ഈ റിപ്പോർട്ടുകൾക്ക് താരതമ്യത്തിനായി പൊരുത്തപ്പെടുന്ന ഫലങ്ങളൊന്നും ലഭ്യമല്ല.';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'റിപ്പോർട്ടുകൾ ലോഡ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCouldNotOpenPhotosOrCamera =>
      'ഫോട്ടോകളോ ക്യാമറയോ തുറക്കാനായില്ല.';

  @override
  String get uiCouldNotOpenCamera => 'ക്യാമറ തുറക്കാനായില്ല.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'ഈ പേജുകൾ തയ്യാറാക്കാൻ കഴിഞ്ഞില്ല. വായിക്കാൻ കഴിയാത്ത പേജ് വീണ്ടും എടുത്ത് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCouldNotAdjustThisPage => 'ഈ പേജ് ക്രമീകരിക്കാൻ കഴിഞ്ഞില്ല.';

  @override
  String get uiNoChartableResultYet => 'ഇതുവരെ ചാർട്ടബിൾ ഫലങ്ങളൊന്നുമില്ല';

  @override
  String get uiProfiles => 'പ്രൊഫൈലുകൾ';

  @override
  String get uiReports => 'റിപ്പോർട്ടുകൾ';

  @override
  String get uiShareLinks => 'ലിങ്കുകൾ പങ്കിടുക';

  @override
  String get uiAIChat => 'AI ചാറ്റ്';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'അവകാശ സംഗ്രഹം ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'ബില്ലിംഗ് നില പുതുക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'രസീത് ഡൗൺലോഡ് ഉടൻ ലഭ്യമാകും.';

  @override
  String get uiSubtotal => 'ഉപമൊത്തം';

  @override
  String get uiDiscount => 'കിഴിവ്';

  @override
  String get uiTotal => 'ആകെ';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'ക്രെഡിറ്റ് പായ്ക്കുകൾ ലോഡുചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'ഒരു പേയ്‌മെൻ്റ് ക്യാപ്‌ചർ തീർപ്പാക്കിയിട്ടില്ല. മറ്റൊരു ചെക്ക്ഔട്ട് ആരംഭിക്കുന്നതിന് മുമ്പ് സ്റ്റാറ്റസ് പുതുക്കുക.';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'ക്രെഡിറ്റുകൾ വിജയകരമായി പ്രയോഗിച്ചു.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'ഓർഡർ സൃഷ്ടിക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'പേയ്മെൻ്റ് ലഭിച്ചു. ക്രെഡിറ്റുകൾ ചേർക്കുന്നതിന് മുമ്പ് സെർവർ അനുരഞ്ജനത്തിനായി കാത്തിരിക്കുന്നു.';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'പേയ്‌മെൻ്റ് പരാജയപ്പെട്ടു. തയ്യാറാകുമ്പോൾ നിങ്ങൾക്ക് ചെക്ക്ഔട്ട് വീണ്ടും ശ്രമിക്കാവുന്നതാണ്.';

  @override
  String get uiPaymentFailedTryAgain =>
      'പേയ്‌മെൻ്റ് പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCreditsAdded => 'ക്രെഡിറ്റുകൾ ചേർത്തു!';

  @override
  String get uiPromoCodeApplied => 'പ്രമോ കോഡ് പ്രയോഗിച്ചു.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'പേയ്‌മെൻ്റ് ലഭിച്ചു, എന്നാൽ ഈ ഓർഡർ അവലോകനം തീർച്ചപ്പെടുത്തിയിട്ടില്ല.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'അനുരഞ്ജന സമയത്ത് പേയ്‌മെൻ്റ് പരാജയപ്പെട്ടു.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'പേയ്‌മെൻ്റ് സ്ഥിരീകരിച്ചു. സെർവർ അനുരഞ്ജനം ഇപ്പോഴും തീർച്ചപ്പെടുത്തിയിട്ടില്ല.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'പേയ്‌മെൻ്റ് പരിശോധിച്ചു. അനുരഞ്ജനം തീർച്ചപ്പെടുത്തിയിട്ടില്ല, ദയവായി ഉടൻ പുതുക്കുക.';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'പേയ്‌മെൻ്റ് ലഭിച്ചു, പക്ഷേ സ്ഥിരീകരണം ഇപ്പോഴും തീർച്ചപ്പെടുത്തിയിട്ടില്ല. സ്റ്റാറ്റസ് പുതുക്കുക.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'പ്ലാനുകൾ ലോഡുചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'സബ്‌സ്‌ക്രിപ്‌ഷൻ സൃഷ്‌ടിക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'സബ്സ്ക്രിപ്ഷൻ പരാജയപ്പെട്ടു. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiPlanUpgraded => 'പ്ലാൻ നവീകരിച്ചു!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'പേയ്‌മെൻ്റ് ലഭിച്ചു, പക്ഷേ പരിശോധന പരാജയപ്പെട്ടു. പ്ലാൻ ഉടൻ നവീകരിക്കും.';

  @override
  String get uiNotificationsUnavailable => 'അറിയിപ്പുകൾ ലഭ്യമല്ല';

  @override
  String get uiAllQuietForNow => 'തൽക്കാലം എല്ലാം നിശബ്ദം.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'പുതിയതായി എന്തെങ്കിലും ഉണ്ടാകുമ്പോൾ റിപ്പോർട്ട് അപ്‌ഡേറ്റുകളും ഓർമ്മപ്പെടുത്തലുകളും ഇവിടെ ദൃശ്യമാകും.';

  @override
  String get uiNoUnreadUpdates => 'വായിക്കാത്ത അപ്‌ഡേറ്റുകളൊന്നുമില്ല';

  @override
  String get uiYouReAllCaughtUp => 'നിങ്ങൾ എല്ലാവരും പിടിക്കപ്പെട്ടു.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'അറിയിപ്പുകൾ ലോഡ് ചെയ്യാനായില്ല. കണക്റ്റ് ചെയ്യുമ്പോൾ വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiManageSharedLinks => 'പങ്കിട്ട ലിങ്കുകൾ നിയന്ത്രിക്കുക';

  @override
  String get uiExportYourData => 'നിങ്ങളുടെ ഡാറ്റ എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get uiReadThePrivacyPolicy => 'സ്വകാര്യതാ നയം വായിക്കുക';

  @override
  String get uiTermsOfUse => 'ഉപയോഗ നിബന്ധനകൾ';

  @override
  String get uiPrivacyPolicy => 'സ്വകാര്യതാ നയം';

  @override
  String get uiDateOfBirthOptional => 'ജനനത്തീയതി, ഓപ്ഷണൽ';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'ബന്ധം 50 പ്രതീകങ്ങളോ അതിൽ കുറവോ ആയിരിക്കണം.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'പ്രൊഫൈൽ സംരക്ഷിക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiReferralsUnavailable => 'റഫറലുകൾ ലഭ്യമല്ല';

  @override
  String get uiYourRewards => 'നിങ്ങളുടെ പ്രതിഫലം';

  @override
  String get uiReferralProgress => 'റഫറൽ പുരോഗതി';

  @override
  String get uiFriendsReferred => 'സുഹൃത്തുക്കൾ പരാമർശിച്ചു';

  @override
  String get uiCreditsEarned => 'ക്രെഡിറ്റുകൾ നേടി';

  @override
  String get uiPendingRewards => 'ശേഷിക്കുന്ന റിവാർഡുകൾ';

  @override
  String get uiBlockedRewards => 'റിവാർഡുകൾ തടഞ്ഞു';

  @override
  String get uiInviteeBonus => 'ക്ഷണിതാവിൻ്റെ ബോണസ്';

  @override
  String get uiFirstAnalysis => 'ആദ്യ വിശകലനം';

  @override
  String get uiFirstPurchase => 'ആദ്യ വാങ്ങൽ';

  @override
  String get uiMonthlyCap => 'പ്രതിമാസ തൊപ്പി';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'റഫറലുകൾ ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiReferralCodeCopied => 'റഫറൽ കോഡ് പകർത്തി.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'നിങ്ങളുടെ ഇമെയിൽ ലിങ്കിൽ നിന്ന് റീസെറ്റ് ടോക്കൺ നൽകുക';

  @override
  String get uiEnterYourNewPassword => 'നിങ്ങളുടെ പുതിയ പാസ്‌വേഡ് നൽകുക';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'പാസ്‌വേഡ് പുനഃസജ്ജമാക്കാനായില്ല. ദയവായി ഒരു പുതിയ ലിങ്ക് അഭ്യർത്ഥിക്കുക.';

  @override
  String get uiEnterYourEmailAddress => 'നിങ്ങളുടെ ഇമെയിൽ വിലാസം നൽകുക';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'റീസെറ്റ് ലിങ്ക് അയയ്‌ക്കാനായില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiFailedToLoadSessions =>
      'സെഷനുകൾ ലോഡുചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു.';

  @override
  String get uiFailedToRevokeSession => 'സെഷൻ പിൻവലിക്കുന്നതിൽ പരാജയപ്പെട്ടു.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'പാസ്‌വേഡ് മാറ്റാനായില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'ഉപകരണ ക്രമീകരണങ്ങൾ തുറന്ന് ഡോക്ലൈസറിനായി അറിയിപ്പുകൾ അനുവദിക്കുക.';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'റിപ്പോർട്ടുകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'പരിശോധനാ ഫലങ്ങൾ ലോഡ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'പങ്കിടാൻ ഒരു റിപ്പോർട്ടെങ്കിലും തിരഞ്ഞെടുക്കുക.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'പങ്കിടാൻ കുറഞ്ഞത് ഒരു ടെസ്റ്റ് ഫലമെങ്കിലും തിരഞ്ഞെടുക്കുക.';

  @override
  String get uiLinkCopiedToClipboard => 'ലിങ്ക് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തി';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'ആക്സസ് കോഡ് ക്ലിപ്പ്ബോർഡിലേക്ക് പകർത്തി';

  @override
  String get uiOnePerson => '1 വ്യക്തി';

  @override
  String uiPeopleCount(String count) {
    return '$count ആളുകൾ';
  }

  @override
  String uiActionsFor(String name) {
    return '$name-നുള്ള പ്രവർത്തനങ്ങൾ';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'പ്രൊഫൈലുകൾ മാറാൻ കഴിയുന്നില്ല. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name-ലേക്ക് മാറി';
  }

  @override
  String get uiAnalyzeOnePage => '1 പേജ് വിശകലനം ചെയ്യുക';

  @override
  String uiAnalyzePages(String count) {
    return '$count പേജുകൾ വിശകലനം ചെയ്യുക';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'നിങ്ങളുടെ റിപ്പോർട്ടിൽ കാണിച്ചിരിക്കുന്ന ക്രമത്തിലേക്ക് പേജുകൾ വലിച്ചിടുക';

  @override
  String get uiCheckEveryPage =>
      'വിശകലനം ചെയ്യുന്നതിന് മുമ്പ് ഓരോ പേജും പരിശോധിക്കുക';

  @override
  String get uiOnePageAdded => '1 പേജ് ചേർത്തു';

  @override
  String uiPagesAdded(String count) {
    return '$count പേജുകൾ ചേർത്തു';
  }

  @override
  String get uiReorder => 'പുനഃക്രമീകരിക്കുക';

  @override
  String uiPageNumber(String number) {
    return 'പേജ് $number';
  }

  @override
  String uiRemovePage(String number) {
    return '$number പേജ് നീക്കം ചെയ്യുക';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · പേജ് $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'അരികുകൾ മുറിക്കുക: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count തിരഞ്ഞെടുത്ത റിപ്പോർട്ടുകൾ';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count തിരഞ്ഞെടുത്ത ടെസ്റ്റ് ഫലങ്ങൾ';
  }

  @override
  String get uiAllCurrentFutureReports =>
      'നിലവിലുള്ളതും ഭാവിയിലുള്ളതുമായ എല്ലാ റിപ്പോർട്ടുകളും';

  @override
  String get uiNoExpiry => 'കാലഹരണപ്പെടില്ല';

  @override
  String uiExpiresDate(String date) {
    return '$date കാലഹരണപ്പെടുന്നു';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'ആക്സസ് കോഡ് ആവശ്യമാണ്. ലിങ്കിൽ നിന്ന് ഇത് പ്രത്യേകം പങ്കിടുക.';

  @override
  String get uiNoAccessCodeRequired => 'ആക്സസ് കോഡ് ആവശ്യമില്ല.';

  @override
  String uiExpiresColonDate(String date) {
    return 'കാലഹരണപ്പെടുന്നത്: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name-ൻ്റെ റിപ്പോർട്ടുകൾ പങ്കിടുക';
  }

  @override
  String uiProfileReports(String name) {
    return '$name ൻ്റെ റിപ്പോർട്ടുകൾ';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count തിരഞ്ഞെടുത്ത ഫലങ്ങൾ';
  }

  @override
  String get uiAccessCodeRequiredShort => 'ആക്സസ് കോഡ് ആവശ്യമാണ്';

  @override
  String uiPastLinksCount(String count) {
    return 'കഴിഞ്ഞ ലിങ്കുകൾ · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return '$date കാലഹരണപ്പെട്ടു';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'അസാധുവാക്കി · $date സൃഷ്ടിച്ചു';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum സജീവ ലിങ്കുകളുടെ $current ഉപയോഗിക്കുന്നു.';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename ഉം അതിൻ്റെ സംഭരിച്ച ഫയലും ഇല്ലാതാക്കണോ? ഇത് പഴയപടിയാക്കാനാകില്ല.';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'റിപ്പോർട്ട് ഇല്ലാതാക്കാൻ കഴിയുന്നില്ല: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'എല്ലാ $count റിപ്പോർട്ടുകളും അവയുടെ സംഭരിച്ച ഫയലുകളും ശാശ്വതമായി ഇല്ലാതാക്കണോ? ഇത് പഴയപടിയാക്കാനാകില്ല.';
  }

  @override
  String get uiRecycleBinEmptied => 'റീസൈക്കിൾ ബിൻ കാലിയാക്കി';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted റിപ്പോർട്ടുകൾ ഇല്ലാതാക്കി. $failed ഇല്ലാതാക്കാൻ കഴിഞ്ഞില്ല; വീണ്ടും ശ്രമിക്കുക.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'റീസൈക്കിൾ ബിൻ ശൂന്യമാക്കാൻ കഴിയുന്നില്ല: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'പ്രൊഫൈൽ: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'ശേഖരിച്ചത്: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'അപ്‌ലോഡ് ചെയ്‌തത്: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'ഇല്ലാതാക്കിയത്: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'ശാശ്വതമായ ഇല്ലാതാക്കൽ: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'ശേഷിക്കുന്ന ദിവസങ്ങൾ: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer =>
      'ഡോക്ലൈസറിനായുള്ള ആപ്പ് ലോക്ക് സ്ഥിരീകരിക്കുക';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'ആപ്പ് ലോക്ക് ഓഫാക്കുന്നതിന് മുമ്പ് സ്ഥിരീകരിക്കുക';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'നിങ്ങളുടെ ആരോഗ്യ രേഖകൾ കാണുന്നതിന് ഡോക്ലൈസർ അൺലോക്ക് ചെയ്യുക';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'ഒരു റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുന്നതിന് മുമ്പ് ഒരു ഡിഫോൾട്ട് പ്രൊഫൈൽ സൃഷ്‌ടിക്കുക.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'നിങ്ങളുടെ ടൈംലൈൻ കാണുന്നതിന് മുമ്പ് ഒരു ഡിഫോൾട്ട് പ്രൊഫൈൽ സൃഷ്ടിക്കുക.';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'ഇപ്പോൾ പ്രൊഫൈലുകൾ ലോഡ് ചെയ്യാനാവുന്നില്ല.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'പ്രൊഫൈൽ ഡാറ്റ ലോഡുചെയ്യാൻ കഴിയാത്തതിനാൽ ഇപ്പോൾ അപ്‌ലോഡ് ചെയ്യാൻ കഴിയില്ല. API സെർവർ പ്രവർത്തിക്കുന്നുണ്ടെന്ന് ഉറപ്പാക്കി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'പ്രൊഫൈൽ ഡാറ്റ ലോഡുചെയ്യാൻ കഴിയാത്തതിനാൽ ഇപ്പോൾ ടൈംലൈൻ തുറക്കാൻ കഴിയില്ല. API സെർവർ പ്രവർത്തിക്കുന്നുണ്ടെന്ന് ഉറപ്പാക്കി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'ഇപ്പോൾ പ്രൊഫൈലുകൾ ലോഡ് ചെയ്യാനാവുന്നില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'പങ്കിടൽ ലിങ്കുകൾ ലോഡ് ചെയ്യാനായില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiPasswordChanged => 'പാസ്‌വേഡ് മാറ്റി';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'ആ റിപ്പോർട്ട് തുറക്കാനായില്ല. റിപ്പോർട്ട് ലൈബ്രറി പരീക്ഷിക്കുക.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'നിങ്ങളുടെ അക്കൗണ്ട് അവലോകനത്തിലായിരിക്കുമ്പോൾ ഈ പ്രവർത്തനം താൽക്കാലികമായി ലഭ്യമല്ല.';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'ഈ വിഭാഗം തുറക്കാനായില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiAppLockIsUnavailable => 'ആപ്പ് ലോക്ക് ലഭ്യമല്ല';

  @override
  String get uiDoclyzerIsLocked => 'ഡോക്ലൈസർ ലോക്ക് ചെയ്തിരിക്കുന്നു';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'സംരക്ഷിച്ച ആപ്പ് ലോക്ക് ക്രമീകരണം വായിക്കാൻ കഴിഞ്ഞില്ല. തുടരാൻ വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'തുടരാൻ നിങ്ങളുടെ ഉപകരണത്തിൻ്റെ പാസ്‌കോഡോ ബയോമെട്രിക്‌സോ ഉപയോഗിക്കുക.';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'നിങ്ങളുടെ അക്കൗണ്ട് അവലോകനത്തിലായിരിക്കുമ്പോൾ അപ്‌ലോഡുകൾ താൽക്കാലികമായി ലഭ്യമല്ല.';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'ഒരു അപ്‌ലോഡ് ആരംഭിക്കാനായില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiJustNow => 'ഇപ്പോൾ തന്നെ';

  @override
  String get uiAdditionalDetails => 'കൂടുതൽ വിശദാംശങ്ങൾ:';

  @override
  String get uiSaveCorrection => 'തിരുത്തൽ സംരക്ഷിക്കുക';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'ഫയലുകൾ തുറക്കാനായില്ല. ആക്സസ് പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'ക്യാമറ തുറക്കാനായില്ല. അനുമതി പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'ഫോട്ടോകൾ തുറക്കാൻ കഴിഞ്ഞില്ല. അനുമതി പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'തിരഞ്ഞെടുത്ത ഫയൽ ആക്സസ് ചെയ്യാനായില്ല.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'തിരഞ്ഞെടുത്ത ഫയൽ ആക്സസ് ചെയ്യാനായില്ല';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'കണക്ഷൻ നഷ്ടപ്പെട്ടു. അപ്‌ലോഡ് സെർവറിൽ എത്തിയിരിക്കാം. അതേ ഫയൽ സുരക്ഷിതമായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiCouldNotLoadExistingReport =>
      'നിലവിലുള്ള റിപ്പോർട്ട് ലോഡ് ചെയ്യാനായില്ല';

  @override
  String get uiAddingTo => 'ഇതിലേക്ക് ചേർക്കുന്നു';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'ചില ഫലങ്ങൾ അവലോകനം ചെയ്യേണ്ടതുണ്ട്. നിങ്ങളുടെ യഥാർത്ഥ റിപ്പോർട്ട് സംരക്ഷിച്ചു.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'ഞങ്ങൾക്ക് ഈ ഫോർമാറ്റ് വായിക്കാൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ ഫയൽ സംരക്ഷിച്ചു.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'റിപ്പോർട്ട് പാഴ്‌സ് ചെയ്‌തു. ഫലങ്ങളും ട്രെൻഡുകളും ലഭ്യമാണ്.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'നിങ്ങളുടെ റിപ്പോർട്ട് ഇപ്പോഴും വിശകലനം ചെയ്യുന്നു. അതിൻ്റെ സ്റ്റാറ്റസ് പരിശോധിക്കാൻ അത് തുറക്കുക.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'പ്രോസസ്സിംഗ് നിർത്തി. നിങ്ങളുടെ ഫയൽ സംരക്ഷിച്ചു. നിങ്ങൾക്ക് വീണ്ടും ശ്രമിക്കാം.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'എക്‌സ്‌ട്രാക്‌റ്റ് ചെയ്‌ത ടെസ്റ്റ് മൂല്യങ്ങളൊന്നും ചേർത്തിട്ടില്ല. നിങ്ങൾക്ക് തുടർന്നും ഡോക്യുമെൻ്റ് തുറക്കാനും പങ്കിടാനും കഴിയും. നിങ്ങളുടെ ട്രെൻഡുകൾക്ക് മാറ്റമില്ല.';

  @override
  String get uiYourOriginalIsSaved => 'നിങ്ങളുടെ ഒറിജിനൽ സംരക്ഷിച്ചു.';

  @override
  String get uiInitialUpload => 'പ്രാരംഭ അപ്‌ലോഡ്';

  @override
  String get uiParsedSuccessfully => 'പാഴ്‌സ് ചെയ്‌തു';

  @override
  String get uiParsingFailed => 'പാഴ്‌സിംഗ് പരാജയപ്പെട്ടു';

  @override
  String get uiExtractionIncomplete => 'വേർതിരിച്ചെടുക്കൽ അപൂർണ്ണമാണ്';

  @override
  String get uiTransientFailure => 'താൽക്കാലിക പരാജയം';

  @override
  String get uiTerminalFailure => 'ടെർമിനൽ പരാജയം';

  @override
  String get uiFailedToLoadAttemptHistory =>
      'ശ്രമ ചരിത്രം ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'ഈ റിപ്പോർട്ടിൻ്റെ ഫയൽ ഇനി ലഭ്യമല്ല.';

  @override
  String get uiCompareResults => 'ഫലങ്ങൾ താരതമ്യം ചെയ്യുക';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'വ്യത്യാസമൊന്നും കണക്കാക്കിയിട്ടില്ല. അനുയോജ്യതയ്ക്ക് സ്ഥിരീകരണം ആവശ്യമാണ്.';

  @override
  String get uiUnitNotRecorded => 'യൂണിറ്റ് രേഖപ്പെടുത്തിയിട്ടില്ല';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'ഈ റിപ്പോർട്ടുകൾക്കിടയിൽ സംഖ്യാപരമായ മാറ്റമില്ല.';

  @override
  String get uiUnableToRestore => 'പുനഃസ്ഥാപിക്കാനായില്ല:';

  @override
  String get uiEnterAGiftVoucherCode => 'ഒരു സമ്മാന വൗച്ചർ കോഡ് നൽകുക.';

  @override
  String get uiApplyVoucher => 'വൗച്ചർ പ്രയോഗിക്കുക';

  @override
  String get uiNotAvailable => 'ലഭ്യമല്ല';

  @override
  String get uiViewReceipt => 'രസീത് കാണുക';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'സമ്മാന വൗച്ചർ അസാധുവാണ് അല്ലെങ്കിൽ ഇതിനകം റിഡീം ചെയ്‌തതാണ്.';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'സമ്മാന വൗച്ചർ ഇതിനകം റിഡീം ചെയ്തിട്ടുണ്ട്.';

  @override
  String get uiGiftVoucherHasBeenVoided => 'സമ്മാന വൗച്ചർ അസാധുവാക്കി.';

  @override
  String get uiGiftVoucherHasExpired => 'സമ്മാന വൗച്ചർ കാലഹരണപ്പെട്ടു.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'ഈ സമ്മാന വൗച്ചർ റിഡീം ചെയ്യാനായില്ല.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'ഈ സമ്മാന വൗച്ചർ റിഡീം ചെയ്യാനായില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiEnterAPromoCodeToApply => 'അപേക്ഷിക്കാൻ ഒരു പ്രൊമോ കോഡ് നൽകുക.';

  @override
  String get uiPromoCodeNotFound => 'പ്രൊമോ കോഡ് കണ്ടെത്തിയില്ല.';

  @override
  String get uiPromoCodeIsInactive => 'പ്രമോ കോഡ് നിഷ്‌ക്രിയമാണ്.';

  @override
  String get uiPromoCodeHasExpired => 'പ്രമോ കോഡ് കാലഹരണപ്പെട്ടു.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'ഈ പാക്കിന് പ്രൊമോ കോഡ് ബാധകമല്ല.';

  @override
  String get uiPromoCodeUsageLimitReached => 'പ്രമോ കോഡ് ഉപയോഗ പരിധി എത്തി.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'നിങ്ങൾ ഇതിനകം ഈ പ്രൊമോ കോഡ് ഉപയോഗിച്ചു.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'പ്രൊമോ കോഡ് പ്രയോഗിക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'ക്രെഡിറ്റുകൾ ചേർക്കുന്നതിന് മുമ്പ് ഈ ഓർഡർ അവലോകനത്തിനായി ഫ്ലാഗ് ചെയ്തു.';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'അനുരഞ്ജന സമയത്ത് പേയ്‌മെൻ്റ് പരാജയപ്പെട്ടു. നിങ്ങൾക്ക് സുരക്ഷിതമായി വീണ്ടും ശ്രമിക്കാം.';

  @override
  String get uiAwaitingCapture => 'പിടിച്ചെടുക്കലിനായി കാത്തിരിക്കുന്നു';

  @override
  String get uiLastPaymentFailed => 'അവസാന പേയ്മെൻ്റ് പരാജയപ്പെട്ടു';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'നിങ്ങൾക്ക് സുരക്ഷിതമായി ചെക്ക്ഔട്ട് ചെയ്യാൻ വീണ്ടും ശ്രമിക്കാം.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'സബ്‌സ്‌ക്രിപ്‌ഷനുകൾക്കായി പ്രൊമോ കോഡുകൾ ഇതുവരെ പിന്തുണയ്‌ക്കുന്നില്ല.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'കയറ്റുമതി ഡൗൺലോഡ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'യഥാർത്ഥ റിപ്പോർട്ടുകളോ പരിശോധനാ ഫലങ്ങളോ തിരഞ്ഞെടുക്കുക.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'കയറ്റുമതി അഭ്യർത്ഥിച്ചു. പുതുക്കാൻ \"സ്റ്റാറ്റസ് പരിശോധിക്കുക\" ടാപ്പ് ചെയ്യുക.';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'കയറ്റുമതി അഭ്യർത്ഥിക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'കയറ്റുമതി തയ്യാറാണ്. ഡൗൺലോഡ് URL ലഭ്യമാണ്.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'കയറ്റുമതി നില പരിശോധിക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'അക്കൗണ്ട് ക്ലോസ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiPrepareExport => 'കയറ്റുമതി തയ്യാറാക്കുക';

  @override
  String get uiSaveExport => 'കയറ്റുമതി സംരക്ഷിക്കുക';

  @override
  String get uiPrepareExportAgain => 'വീണ്ടും കയറ്റുമതി തയ്യാറാക്കുക';

  @override
  String get uiAllDates => 'എല്ലാ തീയതികളും';

  @override
  String get uiPreparingAccountDetails =>
      'അക്കൗണ്ട് വിശദാംശങ്ങൾ തയ്യാറാക്കുന്നു';

  @override
  String get uiFamilyMemberProfiles => 'കുടുംബാംഗങ്ങളുടെ പ്രൊഫൈലുകൾ';

  @override
  String get uiUploadedReports => 'അപ്‌ലോഡ് ചെയ്ത റിപ്പോർട്ടുകൾ';

  @override
  String get uiDownloadReady => 'ഡൗൺലോഡ് തയ്യാറാണ്';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'ഈ ഉപകരണത്തിൽ അറിയിപ്പുകൾ റിപ്പോർട്ടുചെയ്യുക';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'ഉപകരണ ക്രമീകരണങ്ങൾ തുറന്നു. ഡോക്ലൈസറിനായി അറിയിപ്പുകൾ അനുവദിക്കുക, തുടർന്ന് ഇങ്ങോട്ട് മടങ്ങുക.';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'അറിയിപ്പുകൾ ഇപ്പോഴും ഓഫാണ്. റിപ്പോർട്ട് അപ്‌ഡേറ്റുകൾ സ്വീകരിക്കാൻ ഉപകരണ ക്രമീകരണത്തിൽ അവരെ അനുവദിക്കുക.';

  @override
  String get uiPreferencesSaved => 'മുൻഗണനകൾ സംരക്ഷിച്ചു';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'നിങ്ങളുടെ അക്കൗണ്ട് ചോയ്സ് സംരക്ഷിച്ചു, എന്നാൽ ഈ ഉപകരണം മാർക്കറ്റിംഗ് പുഷിനായി രജിസ്റ്റർ ചെയ്യുന്നത് പൂർത്തിയാക്കിയില്ല. ഈ ഉപകരണത്തിൽ മാർക്കറ്റിംഗ് തടഞ്ഞിരിക്കുന്നു; അറിയിപ്പ് അനുമതി പരിശോധിച്ച് വീണ്ടും സംരക്ഷിക്കാൻ ശ്രമിക്കുക.';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'നിങ്ങളുടെ അക്കൗണ്ട് ചോയ്സ് സംരക്ഷിച്ചു. ഈ ഉപകരണത്തിന് ഇതുവരെ അതിൻ്റെ പ്രാദേശിക മുൻഗണന സ്ഥിരീകരിക്കാൻ കഴിഞ്ഞില്ല, എന്നാൽ അക്കൗണ്ട് തലത്തിൽ മാർക്കറ്റിംഗ് തടഞ്ഞു.';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'നിങ്ങളുടെ അക്കൗണ്ട് ചോയ്സ് സംരക്ഷിച്ചു, എന്നാൽ ഈ ഉപകരണത്തിന് മാർക്കറ്റിംഗ് പുഷ് പ്രവർത്തനക്ഷമമാക്കാൻ കഴിഞ്ഞില്ല. അറിയിപ്പ് അനുമതി പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'സംരക്ഷിക്കുന്നതിന് വളരെയധികം സമയമെടുത്തു. നിങ്ങളുടെ കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiReportReadyForReview => 'റിപ്പോർട്ട് അവലോകനത്തിന് തയ്യാറാണ്';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'നിങ്ങളുടെ ഫലങ്ങൾ പരിശോധിക്കാൻ തയ്യാറാകുമ്പോൾ അറിയുക.';

  @override
  String get uiUploadUpdates => 'അപ്‌ഡേറ്റുകൾ അപ്‌ലോഡ് ചെയ്യുക';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'ഒരു അപ്‌ലോഡിന് ശ്രദ്ധ ആവശ്യമുണ്ടെങ്കിൽ ഒരു സന്ദേശം നേടുക.';

  @override
  String get uiSharedLinkReminders => 'പങ്കിട്ട ലിങ്ക് റിമൈൻഡറുകൾ';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'ഒരു ലിങ്ക് കാലഹരണപ്പെടാൻ പോകുമ്പോൾ കേൾക്കുക.';

  @override
  String get uiSecurityAlerts => 'സുരക്ഷാ അലേർട്ടുകൾ';

  @override
  String get uiRequiredForAccountSafety => 'അക്കൗണ്ട് സുരക്ഷയ്ക്ക് ആവശ്യമാണ്.';

  @override
  String get uiComplianceNotices => 'പാലിക്കൽ അറിയിപ്പുകൾ';

  @override
  String get uiRequiredAccountInformation => 'ആവശ്യമായ അക്കൗണ്ട് വിവരങ്ങൾ.';

  @override
  String get uiMarketingPushNotifications => 'മാർക്കറ്റിംഗ് പുഷ് അറിയിപ്പുകൾ';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'ഓഫറുകളും പ്രഖ്യാപനങ്ങളും. ഈ ചോയ്സ് സംരക്ഷിക്കുന്നത് ഈ ഉപകരണത്തിനും ബാധകമാണ്.';

  @override
  String get uiProductUpdates => 'ഉൽപ്പന്ന അപ്ഡേറ്റുകൾ';

  @override
  String get uiOptionalNewsAboutDoclyzer =>
      'ഡോക്ലൈസറിനെക്കുറിച്ചുള്ള ഓപ്ഷണൽ വാർത്തകൾ.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'സെർവറിലേക്ക് കണക്റ്റുചെയ്യാൻ കഴിയില്ല. നിങ്ങളുടെ ഇൻ്റർനെറ്റ് അല്ലെങ്കിൽ API സെർവർ പരിശോധിക്കുക.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'നിങ്ങളുടെ അക്കൗണ്ട് അവലോകനത്തിലായിരിക്കുമ്പോൾ പ്രൊഫൈൽ അപ്‌ഡേറ്റുകൾ താൽക്കാലികമായി ലഭ്യമല്ല.';

  @override
  String get uiUse100CharactersOrFewer =>
      '100 പ്രതീകങ്ങളോ അതിൽ കുറവോ ഉപയോഗിക്കുക';

  @override
  String get uiAddProfile => 'പ്രൊഫൈൽ ചേർക്കുക';

  @override
  String get uiCreateProfile => 'പ്രൊഫൈൽ സൃഷ്ടിക്കുക';

  @override
  String get uiUpdateTheirDetails => 'അവരുടെ വിശദാംശങ്ങൾ അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get uiWhoIsThisProfileFor => 'ഈ പ്രൊഫൈൽ ആർക്കുവേണ്ടിയാണ്?';

  @override
  String get uiNotSelected => 'തിരഞ്ഞെടുത്തിട്ടില്ല';

  @override
  String get uiEnterAReferralCode => 'ഒരു റഫറൽ കോഡ് നൽകുക.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'റഫറൽ പ്രയോഗിച്ചു. ഇമെയിൽ പരിശോധനയ്ക്ക് ശേഷം ബോണസ് അൺലോക്ക് ചെയ്യുന്നു.';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'റഫറൽ പ്രയോഗിച്ചു. ബോണസ് ക്രെഡിറ്റുകൾ തയ്യാറാണ്.';

  @override
  String get uiApplyCode => 'കോഡ് പ്രയോഗിക്കുക';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'നിങ്ങൾക്ക് നിങ്ങളുടെ സ്വന്തം റഫറൽ കോഡ് പ്രയോഗിക്കാൻ കഴിയില്ല.';

  @override
  String get uiReferralCodeIsInvalid => 'റഫറൽ കോഡ് അസാധുവാണ്.';

  @override
  String get uiFailedToApplyReferralCode =>
      'റഫറൽ കോഡ് പ്രയോഗിക്കുന്നതിൽ പരാജയപ്പെട്ടു.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'റഫറൽ കോഡ് പ്രയോഗിക്കുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiThisDevice => 'ഈ ഉപകരണം';

  @override
  String get uiSignedInDevice => 'സൈൻ ഇൻ ചെയ്‌ത ഉപകരണം';

  @override
  String get uiUnknownDevice => 'അജ്ഞാത ഉപകരണം';

  @override
  String get uiRevokeAndLogOut => 'അസാധുവാക്കി ലോഗ് ഔട്ട് ചെയ്യുക';

  @override
  String get uiRevokeSessionca8440 => 'സെഷൻ പിൻവലിക്കുക';

  @override
  String get uiEnterYourCurrentPassword => 'നിങ്ങളുടെ നിലവിലെ പാസ്‌വേഡ് നൽകുക';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'വലിയക്ഷരം, ചെറിയക്ഷരം, ഒരു സംഖ്യ, ഒരു പ്രത്യേക പ്രതീകം എന്നിവ ഉപയോഗിച്ച് കുറഞ്ഞത് 8 പ്രതീകങ്ങൾ ഉപയോഗിക്കുക';

  @override
  String get uiChooseADifferentPassword => 'മറ്റൊരു പാസ്‌വേഡ് തിരഞ്ഞെടുക്കുക';

  @override
  String get uiNewPasswordsDoNotMatch =>
      'പുതിയ പാസ്‌വേഡുകൾ പൊരുത്തപ്പെടുന്നില്ല';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'ലഭ്യമായ എല്ലാ അപ്‌ലോഡ് ക്രെഡിറ്റുകളും നിങ്ങൾ ഉപയോഗിച്ചു. കൂടുതൽ ചേർക്കാൻ പ്ലാനും ക്രെഡിറ്റും സന്ദർശിക്കുക.';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'ഡോക്ലൈസറിനായി അറിയിപ്പുകൾ പ്രവർത്തനരഹിതമാക്കി. റിപ്പോർട്ട്-റെഡി, അക്കൗണ്ട് അപ്‌ഡേറ്റുകൾ അനുവദിക്കുന്നതിന് ഉപകരണ ക്രമീകരണങ്ങൾ തുറക്കുക. നിങ്ങൾ അത് തിരഞ്ഞെടുക്കുന്നില്ലെങ്കിൽ മാർക്കറ്റിംഗ് ഓഫായിരിക്കും.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'ഈ ഉപകരണത്തിൽ റിപ്പോർട്ട്-റെഡിയും അക്കൗണ്ട് അപ്‌ഡേറ്റുകളും നേടുക. നിങ്ങൾ അത് തിരഞ്ഞെടുക്കുന്നില്ലെങ്കിൽ മാർക്കറ്റിംഗ് ഓഫായിരിക്കും.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'ഈ ഉപകരണത്തിനായുള്ള അറിയിപ്പുകൾ ഓഫാണ്. റിപ്പോർട്ട്-റെഡി, അക്കൗണ്ട് അപ്‌ഡേറ്റുകൾ ലഭിക്കുന്നതിന് ക്രമീകരണം തുറക്കുക.';

  @override
  String get uiBlockedExpiredRevoked =>
      'തടഞ്ഞു (കാലഹരണപ്പെട്ടു/അസാധുവാക്കിയത്)';

  @override
  String get uiFailedToLoadPolicy => 'നയം ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു';

  @override
  String get uiUploadPaused => 'അപ്‌ലോഡ് താൽക്കാലികമായി നിർത്തി';

  @override
  String get uiSevenDays => '7 ദിവസം';

  @override
  String get uiThirtyDays => '30 ദിവസം';

  @override
  String get uiNinetyDays => '90 ദിവസം';

  @override
  String get uiUploadingAClearReport =>
      'വ്യക്തമായ റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുന്നു';

  @override
  String get uiPDFsPhotosAndMultiplePages =>
      'PDF-കളും ഫോട്ടോകളും ഒന്നിലധികം പേജുകളും';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'ഒരു PDF തിരഞ്ഞെടുക്കുക അല്ലെങ്കിൽ എല്ലാ പേജിൻ്റെയും വ്യക്തമായ ഫോട്ടോകൾ എടുക്കുക. മുഴുവൻ പേജും ഫ്രെയിമിൽ സൂക്ഷിക്കുക, തിളക്കം ഒഴിവാക്കുക, വിശകലനം ചെയ്യുന്നതിന് മുമ്പ് പേജ് ക്രമം പരിശോധിക്കുക. എക്‌സ്‌ട്രാക്‌റ്റുചെയ്‌ത മൂല്യങ്ങൾ ഒറിജിനലിനെതിരെ നിങ്ങൾക്ക് ശരിയാക്കാം.';

  @override
  String get uiCorrectingAResult => 'ഒരു ഫലം ശരിയാക്കുന്നു';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'യഥാർത്ഥ മൂല്യത്തിനെതിരായ മൂല്യങ്ങൾ അവലോകനം ചെയ്യുക';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'ഒരു റിപ്പോർട്ട് തുറക്കുക, എക്‌സ്‌ട്രാക്‌റ്റുചെയ്‌ത ഓരോ ടെസ്റ്റും ഒറിജിനലിനെതിരെ അവലോകനം ചെയ്യുക, കൂടാതെ തെറ്റായി വായിച്ച ഏതെങ്കിലും മൂല്യം, യൂണിറ്റ് അല്ലെങ്കിൽ തീയതി എന്നിവ ശരിയാക്കുക. നിങ്ങൾ ട്രെൻഡുകളെ ആശ്രയിക്കുന്നതിന് മുമ്പ് സ്ഥിരീകരിക്കാത്ത ഫലങ്ങൾ പരിശോധിക്കേണ്ടതാണ്.';

  @override
  String get uiManagingFamilyRecords => 'കുടുംബ രേഖകൾ കൈകാര്യം ചെയ്യുന്നു';

  @override
  String get uiProfilesAccessAndPermissions => 'പ്രൊഫൈലുകൾ, ആക്സസ്, അനുമതികൾ';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'പ്രൊഫൈലുകൾ സൃഷ്‌ടിക്കാനും മാറാനും കുടുംബം ഉപയോഗിക്കുക. ഒരു റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുന്നതിനോ പങ്കിടുന്നതിനോ മുമ്പ് തിരഞ്ഞെടുത്ത വ്യക്തിയെ പരിശോധിക്കുക. നിങ്ങൾക്ക് ആക്‌സസ് ചെയ്യാൻ അധികാരമുള്ള രേഖകൾ മാത്രം കൈകാര്യം ചെയ്യുക.';

  @override
  String get uiSharingAndRevokingLinks => 'ലിങ്കുകൾ പങ്കിടലും അസാധുവാക്കലും';

  @override
  String get uiControlTheRecordsYouShare =>
      'നിങ്ങൾ പങ്കിടുന്ന റെക്കോർഡുകൾ നിയന്ത്രിക്കുക';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'നിങ്ങൾ പങ്കിടാൻ ആഗ്രഹിക്കുന്ന റിപ്പോർട്ടുകളോ ഫലങ്ങളോ തിരഞ്ഞെടുക്കുക, കാലഹരണപ്പെട്ടതും ആക്‌സസ് കോഡും അവലോകനം ചെയ്യുക, തുടർന്ന് ലിങ്കും കോഡും വെവ്വേറെ അയയ്ക്കുക. ആക്‌സസ് ആവശ്യമില്ലാത്തപ്പോൾ പങ്കിട്ട ലിങ്കുകളിൽ നിന്ന് ഒരു സജീവ ലിങ്ക് അസാധുവാക്കുക.';

  @override
  String get uiInformationYouProvide => 'നിങ്ങൾ നൽകുന്ന വിവരങ്ങൾ';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'അക്കൗണ്ട് വിശദാംശങ്ങളും കുടുംബ പ്രൊഫൈലുകളും നിങ്ങൾ ആരുടെ രേഖകൾ കൈകാര്യം ചെയ്യുന്നു എന്ന് തിരിച്ചറിയുന്നു. അപ്‌ലോഡ് ചെയ്‌ത ഡോക്യുമെൻ്റുകളിൽ തന്ത്രപ്രധാനമായ ആരോഗ്യ വിവരങ്ങൾ അടങ്ങിയിരിക്കാം.';

  @override
  String get uiSharingControls => 'പങ്കിടൽ നിയന്ത്രണങ്ങൾ';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'ഓരോ ലിങ്കിൻ്റെയും ഉള്ളടക്കങ്ങൾ, കാലഹരണപ്പെടൽ, ആക്സസ് ക്രമീകരണങ്ങൾ എന്നിവ അവലോകനം ചെയ്യുക. നിങ്ങളുടെ അക്കൗണ്ട് ക്രമീകരണങ്ങളിൽ നിന്ന് സജീവമായ ലിങ്കുകൾ നിയന്ത്രിക്കുക.';

  @override
  String get uiExportAndAccountChoices => 'എക്‌സ്‌പോർട്ട്, അക്കൗണ്ട് ചോയ്‌സുകൾ';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'റെക്കോർഡുകൾ എക്‌സ്‌പോർട്ട് ചെയ്യാനോ അക്കൗണ്ട് ഇല്ലാതാക്കൽ അഭ്യർത്ഥന ആരംഭിക്കാനോ ക്രമീകരണങ്ങൾ ഉപയോഗിക്കുക. നിലനിർത്തൽ വിശദാംശങ്ങൾ സമ്പൂർണ്ണ നയത്തിൽ ഉൾപ്പെടുന്നു.';

  @override
  String get uiEducationalScope => 'വിദ്യാഭ്യാസ വ്യാപ്തി';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'ഡോക്ലൈസർ റിപ്പോർട്ടുകൾ സംഘടിപ്പിക്കുകയും കാലക്രമേണ ഫലങ്ങൾ കാണിക്കുകയും ചെയ്യുന്നു. വിദ്യാഭ്യാസപരമായ വിശദീകരണങ്ങൾ വൈദ്യോപദേശമോ രോഗനിർണയമോ അല്ല.';

  @override
  String get uiReviewYourRecords => 'നിങ്ങളുടെ രേഖകൾ അവലോകനം ചെയ്യുക';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'യഥാർത്ഥ റിപ്പോർട്ടിൽ നിന്ന് വേർതിരിച്ചെടുത്ത മൂല്യങ്ങളും യൂണിറ്റുകളും തീയതികളും പരിശോധിക്കുക. നിങ്ങളുടെ ഫലങ്ങളെക്കുറിച്ച് ഒരു ഹെൽത്ത് കെയർ പ്രൊഫഷണലിനോട് ചോദിക്കുക.';

  @override
  String get uiManageAndShareResponsibly =>
      'ഉത്തരവാദിത്തത്തോടെ കൈകാര്യം ചെയ്യുകയും പങ്കിടുകയും ചെയ്യുക';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'നിങ്ങൾക്ക് ആക്‌സസ് ചെയ്യാൻ അധികാരമുള്ള റെക്കോർഡുകൾ മാത്രം മാനേജ് ചെയ്യുക. പങ്കിടുന്നതിന് മുമ്പ് തിരഞ്ഞെടുത്ത വിവരങ്ങളും സ്വീകർത്താവും പരിശോധിക്കുക.';

  @override
  String get uiPrivacyPolicy7ceacd => 'സ്വകാര്യതാ നയം';

  @override
  String get uiTermsOfUse8a069e => 'ഉപയോഗ നിബന്ധനകൾ';

  @override
  String get uiOpenPrivacyControls => 'സ്വകാര്യതാ നിയന്ത്രണങ്ങൾ തുറക്കുക';

  @override
  String get uiGetHelpWithTheApp => 'ആപ്പ് ഉപയോഗിച്ച് സഹായം നേടുക';

  @override
  String get uiExportYourDataInAccountSettings =>
      'അക്കൗണ്ട് ക്രമീകരണങ്ങളിൽ നിങ്ങളുടെ ഡാറ്റ കയറ്റുമതി ചെയ്യുക';

  @override
  String get uiYOURDATACHOICES => 'നിങ്ങളുടെ ഡാറ്റയും തിരഞ്ഞെടുപ്പുകളും';

  @override
  String get uiUSINGDOCLYZER => 'ഡോക്ലൈസർ ഉപയോഗിക്കുന്നു';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'ഡോക്ലൈസറിൽ നിങ്ങൾ സൂക്ഷിക്കുന്ന\nവിവരങ്ങൾ മനസ്സിലാക്കുക.';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'ആപ്പിൻ്റെ റോളിനെക്കുറിച്ചുള്ള വ്യക്തമായ ധാരണ\n.';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name-ൽ നിന്ന് $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · ഏറ്റവും പുതിയ $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'ഈ ലൈബ്രറി ആരംഭിക്കാൻ $name എന്നതിനായി ഒരു റിപ്പോർട്ട് അപ്‌ലോഡ് ചെയ്യുക.';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP വിലാസം: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'സൈൻ ഇൻ ചെയ്‌തു: $date';
  }

  @override
  String get uiUnknown => 'അജ്ഞാതം';

  @override
  String uiResultsFor(String name) {
    return '$name-നുള്ള ഫലങ്ങൾ';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count ലാബ് പാരാമീറ്ററുകൾ ട്രാക്ക് ചെയ്തു';
  }

  @override
  String uiSampledDate(String date) {
    return 'സാമ്പിൾ $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'ശേഖരണ തീയതി: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'ലാബ് ശ്രേണി: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI ഈ ശ്രേണി $range ആയി വായിക്കുന്നു. അച്ചടിച്ച വാചകം: $printed. ഈ താരതമ്യത്തെ ആശ്രയിക്കുന്നതിന് മുമ്പ് യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക.';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount തയ്യാറാണ്';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count ക്രെഡിറ്റുകൾ';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'ഈ അക്കൗണ്ടിലേക്ക് ഒരു റഫറൽ കോഡ് ഇതിനകം പ്രയോഗിച്ചു.';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'ആപ്പ് ലോക്ക് ഓണാക്കുന്നതിന് മുമ്പ് ഉപകരണ പാസ്‌കോഡ് സജ്ജീകരിക്കുക.';

  @override
  String get uiLanguagePreferenceNotSaved => 'ഭാഷാ മുൻഗണന സംരക്ഷിച്ചില്ല.';

  @override
  String get uiExportUnavailable => 'കയറ്റുമതി ലഭ്യമല്ല';

  @override
  String get uiUnreadableImage => 'വായിക്കാൻ പറ്റാത്ത ചിത്രം';

  @override
  String uiStatusWithValue(String status) {
    return 'നില: $status';
  }

  @override
  String get uiPending => 'തീർപ്പാക്കാത്തത്';

  @override
  String get uiCompleted => 'പൂർത്തിയാക്കി';

  @override
  String get uiFailed => 'പരാജയപ്പെട്ടു';

  @override
  String get uiInactive => 'നിഷ്ക്രിയം';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'നിങ്ങളുടെ റിപ്പോർട്ടുകളും പ്രൊഫൈലുകളും സൂക്ഷിക്കാൻ $date-ന് മുമ്പ് പുനഃസ്ഥാപിക്കുക.';
  }

  @override
  String get uiThirtyDayDeadline => '30 ദിവസത്തെ സമയപരിധി';

  @override
  String uiWhatsAffected(String details) {
    return 'എന്താണ് ബാധിച്ചത്: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'അവസാനം അപ്ഡേറ്റ് ചെയ്തത്: $time-ൽ $date';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename നിലവിലെ പ്രൊഫൈലിന് പകരം $name എന്നതിന് കീഴിൽ ദൃശ്യമാകും.';
  }

  @override
  String get uiOneVerifiedResult => '1 പരിശോധിച്ച ഫലം സംരക്ഷിച്ചു.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count പരിശോധിച്ചുറപ്പിച്ച ഫലങ്ങൾ സംരക്ഷിച്ചു.';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'പ്രൊഫൈലുകൾ മാറാൻ കഴിയുന്നില്ല. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'ശേഖരിച്ചത്: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'അപ്‌ലോഡ് ചെയ്തത് $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount വർദ്ധിപ്പിച്ചു';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount കുറഞ്ഞു';
  }

  @override
  String get uiPercentagePoints => 'ശതമാനം പോയിൻ്റുകൾ';

  @override
  String uiTestValuesCount(String count) {
    return 'ടെസ്റ്റ് മൂല്യങ്ങൾ ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'പ്രോസസ്സിംഗ് സമയത്ത് AI പരിശോധിച്ച മൂല്യം. യഥാർത്ഥ OCR: $value. റിപ്പോർട്ടിന് എതിരായി അത് സ്ഥിരീകരിക്കുക.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return '$name-ൽ ഇതിനകം റിപ്പോർട്ട് ചെയ്യുക';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return '$name-ലേക്ക് റിപ്പോർട്ട് ചേർത്തു';
  }

  @override
  String uiAddedOn(String date) {
    return '$date ചേർത്തു';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max റിപ്പോർട്ടുകളുടെ $current ഉപയോഗിക്കുന്നു.';
  }

  @override
  String get uiNeedHelp => 'സഹായം വേണോ?';

  @override
  String get uiEnabled => 'പ്രവർത്തനക്ഷമമാക്കി';

  @override
  String get uiEnable => 'പ്രവർത്തനക്ഷമമാക്കുക';

  @override
  String get uiSubscribe => 'സബ്സ്ക്രൈബ് ചെയ്യുക';

  @override
  String get uiApplying => 'അപേക്ഷിക്കുന്നു';

  @override
  String get uiCheckStatus => 'നില പരിശോധിക്കുക';

  @override
  String get uiEditProfile => 'പ്രൊഫൈൽ തിരുത്തുക';

  @override
  String get uiSaveChanges => 'മാറ്റങ്ങൾ സംരക്ഷിക്കുക';

  @override
  String get uiOptional => 'ഓപ്ഷണൽ';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'ഓർഡർ $orderId അനുരഞ്ജനത്തിനായി കാത്തിരിക്കുന്നു. സ്റ്റാറ്റസ് വ്യക്തമാകുന്നത് വരെ വാങ്ങൽ താൽക്കാലികമായി നിർത്തി.';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'പ്രതിമാസ പദ്ധതി - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'ക്രെഡിറ്റ് പായ്ക്ക് - $name';
  }

  @override
  String get uiUnreadable => 'വായിക്കാൻ പറ്റാത്തത്';

  @override
  String uiLatestValue(String value) {
    return 'ഏറ്റവും പുതിയത്: $value';
  }

  @override
  String get uiEarlier => 'നേരത്തെ';

  @override
  String get uiLater => 'പിന്നീട്';

  @override
  String get uiViewed => 'കണ്ടു';

  @override
  String get uiBlocked => 'തടഞ്ഞു';

  @override
  String get uiCapped => 'തൊപ്പി';

  @override
  String uiLastChange(String label) {
    return 'അവസാന മാറ്റം: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'അവസാന മാറ്റം: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'സമ്മാന വൗച്ചർ പ്രയോഗിച്ചു. $credits ക്രെഡിറ്റുകൾ ചേർത്തു.';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'ഇതുവരെ ഒറിജിനൽ സംരക്ഷിക്കാൻ കഴിഞ്ഞില്ല. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'അസാധുവാക്കുന്നതിൽ പരാജയപ്പെട്ടു: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'എൻ്റെ ഡോക്ലൈസർ റഫറൽ കോഡ് $code ഉപയോഗിക്കുക: $link';
  }

  @override
  String get uiAMomentAgo => 'ഒരു നിമിഷം മുമ്പ്';

  @override
  String uiMinutesAgo(String count) {
    return '$count മിനിറ്റ് മുമ്പ്';
  }

  @override
  String get uiOneHourAgo => '1 മണിക്കൂർ മുമ്പ്';

  @override
  String uiHoursAgo(String count) {
    return '$count മണിക്കൂർ മുമ്പ്';
  }

  @override
  String get uiToday => 'ഇന്ന്';

  @override
  String get uiYesterday => 'ഇന്നലെ';

  @override
  String get uiOneDayAgo => '1 ദിവസം മുമ്പ്';

  @override
  String uiDaysAgo(String count) {
    return '$count ദിവസം മുമ്പ്';
  }

  @override
  String get uiOneWeekAgo => '1 ആഴ്ച മുമ്പ്';

  @override
  String uiWeeksAgo(String count) {
    return '$count ആഴ്ചകൾക്ക് മുമ്പ്';
  }

  @override
  String get uiOneMonthAgo => '1 മാസം മുമ്പ്';

  @override
  String uiMonthsAgo(String count) {
    return '$count മാസങ്ങൾക്ക് മുമ്പ്';
  }

  @override
  String get uiOneYearAgo => '1 വർഷം മുമ്പ്';

  @override
  String uiYearsAgo(String count) {
    return '$count വർഷങ്ങൾക്ക് മുമ്പ്';
  }

  @override
  String get uiInOneDay => '1 ദിവസത്തിനുള്ളിൽ';

  @override
  String uiInDays(String count) {
    return '$count ദിവസങ്ങളിൽ';
  }

  @override
  String uiInMinutes(String count) {
    return '$count മിനിറ്റിൽ';
  }

  @override
  String get uiInOneHour => '1 മണിക്കൂറിനുള്ളിൽ';

  @override
  String uiInHours(String count) {
    return '$count മണിക്കൂറിൽ';
  }

  @override
  String get uiMissingExtractedTestName =>
      'എക്‌സ്‌ട്രാക്‌റ്റുചെയ്‌ത ഫലത്തിൽ നിന്ന് പരിശോധനയുടെ പേര് കാണുന്നില്ല.';

  @override
  String get uiMissingCapturedLabRange =>
      'ഈ പരിശോധനയ്ക്കായി ലാബ് റഫറൻസ് ശ്രേണിയൊന്നും എടുത്തിട്ടില്ല.';

  @override
  String get uiNonNumericExtractedValue =>
      'വേർതിരിച്ചെടുത്ത മൂല്യം ഒരു പ്ലെയിൻ നമ്പറല്ല. യഥാർത്ഥ റിപ്പോർട്ടിൽ അത് പരിശോധിക്കുക.';

  @override
  String get uiLabFlagRangeConflict =>
      'ലാബ് ഫ്ലാഗ് അച്ചടിച്ച ശ്രേണിയുമായി വൈരുദ്ധ്യം കാണിക്കുന്നു. യഥാർത്ഥ റിപ്പോർട്ട് പരിശോധിക്കുക.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'എക്‌സ്‌ട്രാക്‌റ്റുചെയ്‌ത മൂല്യം, അച്ചടിച്ച ശ്രേണി അല്ലെങ്കിൽ ലാബ് ഫ്ലാഗ് എന്നിവ യഥാർത്ഥ റിപ്പോർട്ടിൽ പരിശോധിക്കേണ്ടതുണ്ട്.';

  @override
  String get uiInitialEntitlement => 'പ്രാരംഭ അവകാശം';

  @override
  String get uiCreditPackPurchase => 'ക്രെഡിറ്റ് പായ്ക്ക് വാങ്ങൽ';

  @override
  String get uiSubscriptionUpgrade => 'സബ്സ്ക്രിപ്ഷൻ അപ്ഗ്രേഡ്';

  @override
  String get uiPlanDowngrade => 'ഡൗൺഗ്രേഡ് ആസൂത്രണം ചെയ്യുക';

  @override
  String get uiAdminAdjustment => 'അഡ്മിൻ ക്രമീകരണം';

  @override
  String get uiSystemReconciliation => 'സിസ്റ്റം അനുരഞ്ജനം';

  @override
  String get uiReferralInviteBonus => 'റഫറൽ ക്ഷണ ബോണസ്';

  @override
  String get uiReferralAnalysisMilestone => 'റഫറൽ വിശകലനത്തിൻ്റെ നാഴികക്കല്ല്';

  @override
  String get uiReferralPurchaseMilestone => 'റഫറൽ വാങ്ങൽ നാഴികക്കല്ല്';

  @override
  String get uiFreePromoCreditPack => 'സൗജന്യ പ്രമോ ക്രെഡിറ്റ് പായ്ക്ക്';

  @override
  String get uiGiftVoucherRedeemed => 'സമ്മാന വൗച്ചർ റിഡീം ചെയ്തു';

  @override
  String get uiNotYetChanged => 'ഇതുവരെ മാറിയിട്ടില്ല';

  @override
  String get uiCannotReachServer =>
      'സെർവറിലേക്ക് എത്താൻ കഴിഞ്ഞില്ല. നിങ്ങളുടെ കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiInvalidEmailOrPassword =>
      'അസാധുവായ ഇമെയിൽ അല്ലെങ്കിൽ പാസ്‌വേഡ്. നിങ്ങളുടെ വിശദാംശങ്ങൾ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiTooManyAuthAttempts =>
      'വളരെയധികം ശ്രമങ്ങൾ. കുറച്ച് മിനിറ്റ് കാത്തിരുന്ന് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiEnterValidEmail => 'സാധുവായ ഒരു ഇമെയിൽ വിലാസം നൽകുക.';

  @override
  String get uiPasswordRequirements =>
      'പാസ്‌വേഡിൽ കുറഞ്ഞത് 8 പ്രതീകങ്ങൾ ഉണ്ടായിരിക്കണം, അതിൽ വലിയക്ഷരം, ചെറിയക്ഷരം, ഒരു സംഖ്യ, ഒരു പ്രത്യേക പ്രതീകം എന്നിവ ഉൾപ്പെടുന്നു.';

  @override
  String get uiAccountWithEmailExists =>
      'ഈ ഇമെയിൽ ഉള്ള ഒരു അക്കൗണ്ട് ഇതിനകം നിലവിലുണ്ട്. സൈൻ ഇൻ ചെയ്യുക അല്ലെങ്കിൽ മറ്റൊരു ഇമെയിൽ ഉപയോഗിക്കുക.';

  @override
  String get uiUploadedStatus => 'അപ്‌ലോഡ് ചെയ്തു';

  @override
  String uiSupportAction(String action) {
    return 'പ്രവർത്തനം: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'പരസ്പരബന്ധം ഐഡി: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'ക്ലയൻ്റ് പ്രവർത്തന ഐഡി: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'പിശക് കോഡ്: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'പിശക്: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'നിങ്ങളുടെ സെഷൻ അവസാനിച്ചു. വീണ്ടും സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get uiProfileLimitReached =>
      'നിങ്ങളുടെ പ്ലാൻ പ്രൊഫൈൽ പരിധി എത്തിയിരിക്കുന്നു. കൂടുതൽ ചേർക്കാൻ പ്ലാനും ക്രെഡിറ്റുകളും അവലോകനം ചെയ്യുക.';

  @override
  String get uiCorrectionConflictReload =>
      'ഈ ഫലം മറ്റൊരിടത്ത് മാറി. റിപ്പോർട്ട് ശരിയാക്കുന്നതിന് മുമ്പ് അത് വീണ്ടും ലോഡുചെയ്യുക.';

  @override
  String get uiSeePlanCreditsOptions =>
      'ലഭ്യമായ ഓപ്ഷനുകൾക്കായി പ്ലാനും ക്രെഡിറ്റുകളും കാണുക.';

  @override
  String get uiShareLinkLimitHelp =>
      'നിങ്ങൾ സജീവമായ പങ്കിടൽ-ലിങ്ക് പരിധിയിലെത്തി.';

  @override
  String get uiScopedExportUnavailable =>
      'സ്‌കോപ്ഡ് എക്‌സ്‌പോർട്ട് ലഭ്യമല്ല. പിന്നീട് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiRestorationUnavailable =>
      'പുനഃസ്ഥാപിക്കൽ ലഭ്യമല്ല. പിന്നീട് വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get uiExportRequestNotFound =>
      'കയറ്റുമതി അഭ്യർത്ഥന കണ്ടെത്തിയില്ല. ഒരു പുതിയ കയറ്റുമതി അഭ്യർത്ഥിക്കുക.';

  @override
  String get uiClosureConfirmationRequired =>
      'തുടരുന്നതിന് അക്കൗണ്ട് അടച്ചുപൂട്ടൽ സ്ഥിരീകരിക്കുക.';

  @override
  String get uiCurrentPasswordIncorrect => 'നിലവിലെ പാസ്‌വേഡ് തെറ്റാണ്.';

  @override
  String get uiLaboratories => 'ലബോറട്ടറികൾ';

  @override
  String get uiUnlock => 'അൺലോക്ക് ചെയ്യുക';
}
