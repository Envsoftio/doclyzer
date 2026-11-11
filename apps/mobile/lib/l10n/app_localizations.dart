import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @trendLatestResult.
  ///
  /// In en, this message translates to:
  /// **'Latest result'**
  String get trendLatestResult;

  /// No description provided for @trendPreviousResult.
  ///
  /// In en, this message translates to:
  /// **'Previous result'**
  String get trendPreviousResult;

  /// No description provided for @trendSourceUnit.
  ///
  /// In en, this message translates to:
  /// **'Source unit for this range'**
  String get trendSourceUnit;

  /// No description provided for @trendNoSavedResults.
  ///
  /// In en, this message translates to:
  /// **'No saved results are available for this test yet.'**
  String get trendNoSavedResults;

  /// No description provided for @trendNoPlottableResults.
  ///
  /// In en, this message translates to:
  /// **'No exact numeric results with a collection date can be plotted.'**
  String get trendNoPlottableResults;

  /// No description provided for @trendOneResultHelp.
  ///
  /// In en, this message translates to:
  /// **'One saved result. Add another report to see a trend.'**
  String get trendOneResultHelp;

  /// No description provided for @trendMultipleResultsHelp.
  ///
  /// In en, this message translates to:
  /// **'Dates are spaced by elapsed time. Tap a point for its value.'**
  String get trendMultipleResultsHelp;

  /// No description provided for @trendUnplottedNote.
  ///
  /// In en, this message translates to:
  /// **'{count} results could not be plotted because the collection date or exact numeric value is unavailable.'**
  String trendUnplottedNote(int count);

  /// No description provided for @trendChartLabel.
  ///
  /// In en, this message translates to:
  /// **'{testName} trend chart with {count} results'**
  String trendChartLabel(String testName, int count);

  /// No description provided for @trendDateReview.
  ///
  /// In en, this message translates to:
  /// **'Collection date from an earlier extraction. Check the source report.'**
  String get trendDateReview;

  /// No description provided for @trendNotPlotted.
  ///
  /// In en, this message translates to:
  /// **'Not plotted'**
  String get trendNotPlotted;

  /// No description provided for @trendExactNumberUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Result is not an exact number'**
  String get trendExactNumberUnavailable;

  /// No description provided for @preferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get preferredLanguage;

  /// No description provided for @descriptionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Description language'**
  String get descriptionLanguage;

  /// No description provided for @languageHelp.
  ///
  /// In en, this message translates to:
  /// **'Used for app labels and report explanations. You can switch the language of an explanation at any time.'**
  String get languageHelp;

  /// No description provided for @languageSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your language. Please try again.'**
  String get languageSaveFailed;

  /// No description provided for @translationLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing the translated description…'**
  String get translationLoading;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation is unavailable. Try again or choose English.'**
  String get translationFailed;

  /// No description provided for @translationNote.
  ///
  /// In en, this message translates to:
  /// **'AI-translated from the saved English explanation. Check the original report for exact results.'**
  String get translationNote;

  /// No description provided for @sourceChanged.
  ///
  /// In en, this message translates to:
  /// **'The report changed. Reload it to see the latest explanation.'**
  String get sourceChanged;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'A clearer view\nstarts here.'**
  String get signupTitle;

  /// No description provided for @signupIntro.
  ///
  /// In en, this message translates to:
  /// **'Create an account to keep your reports and results together.'**
  String get signupIntro;

  /// No description provided for @loginIntro.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access and understand your health reports.'**
  String get loginIntro;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral code (optional)'**
  String get referralCode;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @invalidCredentialsInput.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address and password'**
  String get invalidCredentialsInput;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create account'**
  String get signupFailed;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Please check your connection and try again.'**
  String get loginFailed;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get camera;

  /// No description provided for @photoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get photoUpdated;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update your photo. Please try again.'**
  String get photoFailed;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get profileLoading;

  /// No description provided for @profileLoadAction.
  ///
  /// In en, this message translates to:
  /// **'Tap to load your profile'**
  String get profileLoadAction;

  /// No description provided for @accountData.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT & DATA'**
  String get accountData;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get privacySecurity;

  /// No description provided for @sharedLinks.
  ///
  /// In en, this message translates to:
  /// **'Shared links'**
  String get sharedLinks;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get exportData;

  /// No description provided for @additionalAccount.
  ///
  /// In en, this message translates to:
  /// **'Additional account information'**
  String get additionalAccount;

  /// No description provided for @additionalAccountHelp.
  ///
  /// In en, this message translates to:
  /// **'Family, plan, referrals, sessions and appearance'**
  String get additionalAccountHelp;

  /// No description provided for @familyProfiles.
  ///
  /// In en, this message translates to:
  /// **'Family profiles'**
  String get familyProfiles;

  /// No description provided for @manageProfiles.
  ///
  /// In en, this message translates to:
  /// **'Switch or manage profiles'**
  String get manageProfiles;

  /// No description provided for @planCredits.
  ///
  /// In en, this message translates to:
  /// **'Plan & credits'**
  String get planCredits;

  /// No description provided for @viewPlanBalance.
  ///
  /// In en, this message translates to:
  /// **'View your plan and balance'**
  String get viewPlanBalance;

  /// No description provided for @balanceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading balance…'**
  String get balanceLoading;

  /// No description provided for @referFriends.
  ///
  /// In en, this message translates to:
  /// **'Refer friends'**
  String get referFriends;

  /// No description provided for @referralRewards.
  ///
  /// In en, this message translates to:
  /// **'Invites and referral rewards'**
  String get referralRewards;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get activeSessions;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @aboutDoclyzer.
  ///
  /// In en, this message translates to:
  /// **'About Doclyzer'**
  String get aboutDoclyzer;

  /// No description provided for @aboutCopy.
  ///
  /// In en, this message translates to:
  /// **'Keep reports organized by person and review extracted results against the original.'**
  String get aboutCopy;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @accountRestricted.
  ///
  /// In en, this message translates to:
  /// **'Account Restricted'**
  String get accountRestricted;

  /// No description provided for @photoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo…'**
  String get photoUploading;

  /// No description provided for @changePhotoShort.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhotoShort;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @emailHelp.
  ///
  /// In en, this message translates to:
  /// **'Used for account access. Contact support to change it.'**
  String get emailHelp;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @belowLabRange.
  ///
  /// In en, this message translates to:
  /// **'Below this lab\'s reference range'**
  String get belowLabRange;

  /// No description provided for @withinLabRange.
  ///
  /// In en, this message translates to:
  /// **'Within this lab\'s reference range'**
  String get withinLabRange;

  /// No description provided for @aboveLabRange.
  ///
  /// In en, this message translates to:
  /// **'Above this lab\'s reference range'**
  String get aboveLabRange;

  /// No description provided for @cannotCompare.
  ///
  /// In en, this message translates to:
  /// **'Cannot compare with the lab range'**
  String get cannotCompare;

  /// No description provided for @understandResult.
  ///
  /// In en, this message translates to:
  /// **'Understand this result'**
  String get understandResult;

  /// No description provided for @yourResult.
  ///
  /// In en, this message translates to:
  /// **'YOUR RESULT'**
  String get yourResult;

  /// No description provided for @labReferenceRange.
  ///
  /// In en, this message translates to:
  /// **'Lab reference range'**
  String get labReferenceRange;

  /// No description provided for @resultUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available in this result'**
  String get resultUnavailable;

  /// No description provided for @sampleDate.
  ///
  /// In en, this message translates to:
  /// **'Sample date'**
  String get sampleDate;

  /// No description provided for @resultHistory.
  ///
  /// In en, this message translates to:
  /// **'Result history'**
  String get resultHistory;

  /// No description provided for @originalReport.
  ///
  /// In en, this message translates to:
  /// **'Original report'**
  String get originalReport;

  /// No description provided for @reviewValue.
  ///
  /// In en, this message translates to:
  /// **'Review value'**
  String get reviewValue;

  /// No description provided for @understandYourResult.
  ///
  /// In en, this message translates to:
  /// **'Understand your result'**
  String get understandYourResult;

  /// No description provided for @educationalContext.
  ///
  /// In en, this message translates to:
  /// **'Educational context to help you discuss this result.'**
  String get educationalContext;

  /// No description provided for @explanationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Explanation unavailable'**
  String get explanationUnavailable;

  /// No description provided for @explanationFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not load an explanation right now.'**
  String get explanationFailed;

  /// No description provided for @checkOriginal.
  ///
  /// In en, this message translates to:
  /// **'Check original report'**
  String get checkOriginal;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @aiGuidance.
  ///
  /// In en, this message translates to:
  /// **'AI-GENERATED GUIDANCE'**
  String get aiGuidance;

  /// No description provided for @understandingResult.
  ///
  /// In en, this message translates to:
  /// **'Understanding this result'**
  String get understandingResult;

  /// No description provided for @possibleMeaning.
  ///
  /// In en, this message translates to:
  /// **'What it could mean'**
  String get possibleMeaning;

  /// No description provided for @whatTestMeasures.
  ///
  /// In en, this message translates to:
  /// **'What this test measures'**
  String get whatTestMeasures;

  /// No description provided for @suggestedNextStep.
  ///
  /// In en, this message translates to:
  /// **'Suggested next step'**
  String get suggestedNextStep;

  /// No description provided for @resultLimitations.
  ///
  /// In en, this message translates to:
  /// **'What this result cannot tell you'**
  String get resultLimitations;

  /// No description provided for @oneResultLimit.
  ///
  /// In en, this message translates to:
  /// **'One result alone cannot diagnose a condition or explain symptoms.'**
  String get oneResultLimit;

  /// No description provided for @detailsToCheck.
  ///
  /// In en, this message translates to:
  /// **'Details to check'**
  String get detailsToCheck;

  /// No description provided for @lifestyleFactors.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle factors to discuss'**
  String get lifestyleFactors;

  /// No description provided for @insightContext.
  ///
  /// In en, this message translates to:
  /// **'This value was extracted from your report. Check the original if the name, value, unit or range looks wrong. AI explanations are educational and cannot tell you which treatment you need.'**
  String get insightContext;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @moveReport.
  ///
  /// In en, this message translates to:
  /// **'Move report'**
  String get moveReport;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Report details'**
  String get reportDetails;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share report'**
  String get shareReport;

  /// No description provided for @moreReportActions.
  ///
  /// In en, this message translates to:
  /// **'More report actions'**
  String get moreReportActions;

  /// No description provided for @attemptHistory.
  ///
  /// In en, this message translates to:
  /// **'Attempt history'**
  String get attemptHistory;

  /// No description provided for @compareReports.
  ///
  /// In en, this message translates to:
  /// **'Compare reports'**
  String get compareReports;

  /// No description provided for @readParsedReport.
  ///
  /// In en, this message translates to:
  /// **'Read parsed report'**
  String get readParsedReport;

  /// No description provided for @moveRecycle.
  ///
  /// In en, this message translates to:
  /// **'Move to recycle bin'**
  String get moveRecycle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'Report summary'**
  String get reportSummary;

  /// No description provided for @updateSummary.
  ///
  /// In en, this message translates to:
  /// **'Update summary'**
  String get updateSummary;

  /// No description provided for @summaryLoading.
  ///
  /// In en, this message translates to:
  /// **'Putting your results into plain language…'**
  String get summaryLoading;

  /// No description provided for @checkSummary.
  ///
  /// In en, this message translates to:
  /// **'Check summary'**
  String get checkSummary;

  /// No description provided for @summaryFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not create the summary. You can try again.'**
  String get summaryFailed;

  /// No description provided for @summaryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'A plain language explanation of the key results will appear here.'**
  String get summaryPlaceholder;

  /// No description provided for @retrySummary.
  ///
  /// In en, this message translates to:
  /// **'Try summary again'**
  String get retrySummary;

  /// No description provided for @generateSummary.
  ///
  /// In en, this message translates to:
  /// **'Generate summary'**
  String get generateSummary;

  /// No description provided for @loadingResults.
  ///
  /// In en, this message translates to:
  /// **'Loading report results…'**
  String get loadingResults;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWrong;

  /// No description provided for @viewTrends.
  ///
  /// In en, this message translates to:
  /// **'View trends'**
  String get viewTrends;

  /// No description provided for @originalFile.
  ///
  /// In en, this message translates to:
  /// **'Original file'**
  String get originalFile;

  /// No description provided for @testValues.
  ///
  /// In en, this message translates to:
  /// **'Test values'**
  String get testValues;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @checkStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get checkStatus;

  /// No description provided for @viewOriginal.
  ///
  /// In en, this message translates to:
  /// **'View original'**
  String get viewOriginal;

  /// No description provided for @verifiedResults.
  ///
  /// In en, this message translates to:
  /// **'Verified results'**
  String get verifiedResults;

  /// No description provided for @resultTapHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a result to understand what the test measures.'**
  String get resultTapHelp;

  /// No description provided for @reviewResults.
  ///
  /// In en, this message translates to:
  /// **'Review detected results'**
  String get reviewResults;

  /// No description provided for @keepFile.
  ///
  /// In en, this message translates to:
  /// **'Keep file anyway'**
  String get keepFile;

  /// No description provided for @patientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient details'**
  String get patientDetails;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @bookingId.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingId;

  /// No description provided for @sampleCollection.
  ///
  /// In en, this message translates to:
  /// **'Sample Collection'**
  String get sampleCollection;

  /// No description provided for @labDetails.
  ///
  /// In en, this message translates to:
  /// **'Lab details'**
  String get labDetails;

  /// No description provided for @labName.
  ///
  /// In en, this message translates to:
  /// **'Lab Name'**
  String get labName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @belowRange.
  ///
  /// In en, this message translates to:
  /// **'Below range'**
  String get belowRange;

  /// No description provided for @aboveRange.
  ///
  /// In en, this message translates to:
  /// **'Above range'**
  String get aboveRange;

  /// No description provided for @withinRange.
  ///
  /// In en, this message translates to:
  /// **'In listed range'**
  String get withinRange;

  /// No description provided for @rangeUnclear.
  ///
  /// In en, this message translates to:
  /// **'Range unclear'**
  String get rangeUnclear;

  /// No description provided for @understandResultAction.
  ///
  /// In en, this message translates to:
  /// **'Understand this result  →'**
  String get understandResultAction;

  /// No description provided for @parsedReport.
  ///
  /// In en, this message translates to:
  /// **'Parsed Report'**
  String get parsedReport;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @openingPage.
  ///
  /// In en, this message translates to:
  /// **'Opening page'**
  String get openingPage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @switchProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch profile'**
  String get switchProfile;

  /// No description provided for @currentProfile.
  ///
  /// In en, this message translates to:
  /// **'Current profile'**
  String get currentProfile;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View this profile'**
  String get viewProfile;

  /// No description provided for @manageFamily.
  ///
  /// In en, this message translates to:
  /// **'Manage family'**
  String get manageFamily;

  /// No description provided for @chooseProfile.
  ///
  /// In en, this message translates to:
  /// **'Choose a profile'**
  String get chooseProfile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'A little clarity.\nAll in one place.'**
  String get homeTitle;

  /// No description provided for @nextReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next report,\nready when you are.'**
  String get nextReportTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PDFs, photos and family records.'**
  String get homeSubtitle;

  /// No description provided for @uploadReport.
  ///
  /// In en, this message translates to:
  /// **'Upload report'**
  String get uploadReport;

  /// No description provided for @recentReport.
  ///
  /// In en, this message translates to:
  /// **'Recent report'**
  String get recentReport;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @reportsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Reports are unavailable. Try again when connected.'**
  String get reportsUnavailable;

  /// No description provided for @emptyHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your story starts here'**
  String get emptyHomeTitle;

  /// No description provided for @emptyHomeHelp.
  ///
  /// In en, this message translates to:
  /// **'Upload your first report to begin a clear history of your records.'**
  String get emptyHomeHelp;

  /// No description provided for @uploadFirstReport.
  ///
  /// In en, this message translates to:
  /// **'Upload your first report'**
  String get uploadFirstReport;

  /// No description provided for @latestResults.
  ///
  /// In en, this message translates to:
  /// **'Latest results'**
  String get latestResults;

  /// No description provided for @allTrends.
  ///
  /// In en, this message translates to:
  /// **'All trends'**
  String get allTrends;

  /// No description provided for @reviewedResultsHelp.
  ///
  /// In en, this message translates to:
  /// **'Reviewed results will appear here when available.'**
  String get reviewedResultsHelp;

  /// No description provided for @searchTests.
  ///
  /// In en, this message translates to:
  /// **'Search tests'**
  String get searchTests;

  /// No description provided for @noHealthData.
  ///
  /// In en, this message translates to:
  /// **'No health data yet. Upload a report to see your health history.'**
  String get noHealthData;

  /// No description provided for @noTestsFound.
  ///
  /// In en, this message translates to:
  /// **'No tests found'**
  String get noTestsFound;

  /// No description provided for @shorterTestName.
  ///
  /// In en, this message translates to:
  /// **'Try a shorter test name.'**
  String get shorterTestName;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @unitUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unit unavailable'**
  String get unitUnavailable;

  /// No description provided for @uploadingReport.
  ///
  /// In en, this message translates to:
  /// **'Uploading report…'**
  String get uploadingReport;

  /// No description provided for @organizingReport.
  ///
  /// In en, this message translates to:
  /// **'Organizing your report…'**
  String get organizingReport;

  /// No description provided for @uploadAReport.
  ///
  /// In en, this message translates to:
  /// **'Upload a report'**
  String get uploadAReport;

  /// No description provided for @uploadHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF or a clear photo. You can check details before saving.'**
  String get uploadHelp;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE A SOURCE'**
  String get chooseSource;

  /// No description provided for @uploadPdfImage.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF or image'**
  String get uploadPdfImage;

  /// No description provided for @chooseReportFiles.
  ///
  /// In en, this message translates to:
  /// **'Choose a report from your files'**
  String get chooseReportFiles;

  /// No description provided for @selectReportPages.
  ///
  /// In en, this message translates to:
  /// **'Select one or more report pages'**
  String get selectReportPages;

  /// No description provided for @capturePage.
  ///
  /// In en, this message translates to:
  /// **'Capture a complete page'**
  String get capturePage;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: PDF, JPG, PNG'**
  String get supportedFormats;

  /// No description provided for @confirmFile.
  ///
  /// In en, this message translates to:
  /// **'Make sure this is the file you want to add.'**
  String get confirmFile;

  /// No description provided for @addReport.
  ///
  /// In en, this message translates to:
  /// **'Add report'**
  String get addReport;

  /// No description provided for @chooseDifferentFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a different file'**
  String get chooseDifferentFile;

  /// No description provided for @uploadWait.
  ///
  /// In en, this message translates to:
  /// **'This may take a moment. Please keep the app open.'**
  String get uploadWait;

  /// No description provided for @reportNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Report needs attention'**
  String get reportNeedsAttention;

  /// No description provided for @verifyBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Check detected results against the original report before saving them.'**
  String get verifyBeforeSaving;

  /// No description provided for @viewVerifiedResults.
  ///
  /// In en, this message translates to:
  /// **'View verified results'**
  String get viewVerifiedResults;

  /// No description provided for @viewOriginalReport.
  ///
  /// In en, this message translates to:
  /// **'View original report'**
  String get viewOriginalReport;

  /// No description provided for @viewReportStatus.
  ///
  /// In en, this message translates to:
  /// **'View report status'**
  String get viewReportStatus;

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View results'**
  String get viewResults;

  /// No description provided for @viewOriginalFile.
  ///
  /// In en, this message translates to:
  /// **'View original file'**
  String get viewOriginalFile;

  /// No description provided for @retryExtraction.
  ///
  /// In en, this message translates to:
  /// **'Retry extraction'**
  String get retryExtraction;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @duplicateReport.
  ///
  /// In en, this message translates to:
  /// **'This report looks like a duplicate'**
  String get duplicateReport;

  /// No description provided for @duplicateHelp.
  ///
  /// In en, this message translates to:
  /// **'This file may already be in your reports.'**
  String get duplicateHelp;

  /// No description provided for @keepExisting.
  ///
  /// In en, this message translates to:
  /// **'Keep existing'**
  String get keepExisting;

  /// No description provided for @processAgain.
  ///
  /// In en, this message translates to:
  /// **'Process PDF again'**
  String get processAgain;

  /// No description provided for @uploadNewCopy.
  ///
  /// In en, this message translates to:
  /// **'Upload as new copy'**
  String get uploadNewCopy;

  /// No description provided for @reportLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Report limit reached'**
  String get reportLimitReached;

  /// No description provided for @reportLimitHelp.
  ///
  /// In en, this message translates to:
  /// **'You have reached your report limit.'**
  String get reportLimitHelp;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @uploadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not upload report'**
  String get uploadFailedTitle;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @retrySameFile.
  ///
  /// In en, this message translates to:
  /// **'Retry same file'**
  String get retrySameFile;

  /// No description provided for @chooseAnotherFile.
  ///
  /// In en, this message translates to:
  /// **'Choose another file'**
  String get chooseAnotherFile;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Doclyzer helps you organize and better understand your health reports. The information provided is for educational purposes only and is not medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional for medical guidance.'**
  String get aiDisclaimer;

  /// No description provided for @collectedOn.
  ///
  /// In en, this message translates to:
  /// **'Collected {date}'**
  String collectedOn(String date);

  /// No description provided for @uploadedOn.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {date}'**
  String uploadedOn(String date);

  /// No description provided for @labRangeValue.
  ///
  /// In en, this message translates to:
  /// **'Lab range {range}'**
  String labRangeValue(String range);

  /// No description provided for @planBalance.
  ///
  /// In en, this message translates to:
  /// **'{plan} · {credits} credits'**
  String planBalance(String plan, String credits);

  /// No description provided for @reportCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reports} =1{1 report} other{{count} reports}}'**
  String reportCount(int count);

  /// No description provided for @reportLoadSlow.
  ///
  /// In en, this message translates to:
  /// **'The report is taking longer than expected to load. Check your connection and try again.'**
  String get reportLoadSlow;

  /// No description provided for @summaryUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not update the summary right now. The saved summary is still available.'**
  String get summaryUpdateFailed;

  /// No description provided for @summaryCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not create the summary right now. Your results are still available below.'**
  String get summaryCreateFailed;

  /// No description provided for @reassignFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not reassign report. Try again.'**
  String get reassignFailed;

  /// No description provided for @confirmRecycle.
  ///
  /// In en, this message translates to:
  /// **'Move to recycle bin?'**
  String get confirmRecycle;

  /// No description provided for @recycleHelp.
  ///
  /// In en, this message translates to:
  /// **'You can restore this report from Reports > Recycle Bin for 30 days. After that, it will be permanently deleted.'**
  String get recycleHelp;

  /// No description provided for @reportRecycled.
  ///
  /// In en, this message translates to:
  /// **'Report moved to recycle bin'**
  String get reportRecycled;

  /// No description provided for @reportDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete report. Try again.'**
  String get reportDeleteFailed;

  /// No description provided for @addProfileBeforeMove.
  ///
  /// In en, this message translates to:
  /// **'Add another family profile before moving this report.'**
  String get addProfileBeforeMove;

  /// No description provided for @moveReportHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose another family member if this report was added to the wrong profile.'**
  String get moveReportHelp;

  /// No description provided for @confirmMoveReport.
  ///
  /// In en, this message translates to:
  /// **'Move this report?'**
  String get confirmMoveReport;

  /// No description provided for @aboutSampleDates.
  ///
  /// In en, this message translates to:
  /// **'About sample dates'**
  String get aboutSampleDates;

  /// No description provided for @multipleDatesHelp.
  ///
  /// In en, this message translates to:
  /// **'This report has results from more than one sample date. Open a result to check its date against the original report.'**
  String get multipleDatesHelp;

  /// No description provided for @missingDateHelp.
  ///
  /// In en, this message translates to:
  /// **'The sample date is when the sample was taken. We could not find a reliable date in this report. It is different from the upload date. Open a result to check or correct its date.'**
  String get missingDateHelp;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @waitingToProcess.
  ///
  /// In en, this message translates to:
  /// **'Waiting to process'**
  String get waitingToProcess;

  /// No description provided for @readingReport.
  ///
  /// In en, this message translates to:
  /// **'Reading report'**
  String get readingReport;

  /// No description provided for @readyToReview.
  ///
  /// In en, this message translates to:
  /// **'Ready to review'**
  String get readyToReview;

  /// No description provided for @someResultsNeedReview.
  ///
  /// In en, this message translates to:
  /// **'Some results need review'**
  String get someResultsNeedReview;

  /// No description provided for @couldNotReadReport.
  ///
  /// In en, this message translates to:
  /// **'Could not read report'**
  String get couldNotReadReport;

  /// No description provided for @processingStopped.
  ///
  /// In en, this message translates to:
  /// **'Processing stopped'**
  String get processingStopped;

  /// No description provided for @couldNotProcessReport.
  ///
  /// In en, this message translates to:
  /// **'Could not process report'**
  String get couldNotProcessReport;

  /// No description provided for @reportRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh this report. Showing the last loaded result.'**
  String get reportRefreshFailed;

  /// No description provided for @multipleSampleDates.
  ///
  /// In en, this message translates to:
  /// **'Multiple sample dates '**
  String get multipleSampleDates;

  /// No description provided for @missingSampleDate.
  ///
  /// In en, this message translates to:
  /// **'Sample date not found '**
  String get missingSampleDate;

  /// No description provided for @reportAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'We are analyzing this report. You can leave this screen; results will appear when ready.'**
  String get reportAnalyzing;

  /// No description provided for @extractionIncompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not extract all results reliably'**
  String get extractionIncompleteTitle;

  /// No description provided for @extractionIncompleteHelp.
  ///
  /// In en, this message translates to:
  /// **'Automatic extraction was incomplete. Check detected rows against the original report before saving them.'**
  String get extractionIncompleteHelp;

  /// No description provided for @verifiedRowsHelp.
  ///
  /// In en, this message translates to:
  /// **'These rows were checked against the original. Other rows may still need review.'**
  String get verifiedRowsHelp;

  /// No description provided for @noTestValues.
  ///
  /// In en, this message translates to:
  /// **'No test values were found in this report. Open the original file to check its contents.'**
  String get noTestValues;

  /// No description provided for @processingRetryHelp.
  ///
  /// In en, this message translates to:
  /// **'Processing stopped before it finished. Your file is saved. Tap Retry to try again.'**
  String get processingRetryHelp;

  /// No description provided for @resultsNeedCheck.
  ///
  /// In en, this message translates to:
  /// **'Some results need a check against the original report. You can review the detected rows below.'**
  String get resultsNeedCheck;

  /// No description provided for @readerModeHelp.
  ///
  /// In en, this message translates to:
  /// **'Parsed report is available in Reader mode for easier access and better readability.'**
  String get readerModeHelp;

  /// No description provided for @aiRangeHelp.
  ///
  /// In en, this message translates to:
  /// **'Range interpreted by AI during processing. Check the original report.'**
  String get aiRangeHelp;

  /// No description provided for @checkResultHelp.
  ///
  /// In en, this message translates to:
  /// **'Check this result against the original report before relying on it.'**
  String get checkResultHelp;

  /// No description provided for @preferredRangeHelp.
  ///
  /// In en, this message translates to:
  /// **'Compared with the preferred category printed by the lab; confirm it applies to you.'**
  String get preferredRangeHelp;

  /// No description provided for @categoryComparisonHelp.
  ///
  /// In en, this message translates to:
  /// **'This comparison uses the preferred category printed by the lab. Check that the category applies to you.'**
  String get categoryComparisonHelp;

  /// No description provided for @missingSavedResult.
  ///
  /// In en, this message translates to:
  /// **'This value could not be matched to a saved result. Check the original report or refresh this report.'**
  String get missingSavedResult;

  /// No description provided for @unreviewedTest.
  ///
  /// In en, this message translates to:
  /// **'This test has not been reviewed for AI explanations yet. Check the original report and discuss the result with your clinician.'**
  String get unreviewedTest;

  /// No description provided for @unsafeResult.
  ///
  /// In en, this message translates to:
  /// **'The extracted result is unclear, so it cannot be safely explained. Check the original report.'**
  String get unsafeResult;

  /// No description provided for @filterReports.
  ///
  /// In en, this message translates to:
  /// **'Filter reports'**
  String get filterReports;

  /// No description provided for @sortReports.
  ///
  /// In en, this message translates to:
  /// **'Sort reports'**
  String get sortReports;

  /// No description provided for @recycleBin.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin'**
  String get recycleBin;

  /// No description provided for @healthHistory.
  ///
  /// In en, this message translates to:
  /// **'Health History'**
  String get healthHistory;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @reportsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports unavailable'**
  String get reportsUnavailableTitle;

  /// No description provided for @reportsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reports. Try again when connected.'**
  String get reportsLoadFailed;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @reportsFor.
  ///
  /// In en, this message translates to:
  /// **'REPORTS FOR'**
  String get reportsFor;

  /// No description provided for @searchReports.
  ///
  /// In en, this message translates to:
  /// **'Search reports or labs'**
  String get searchReports;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @noMatchingReports.
  ///
  /// In en, this message translates to:
  /// **'No reports match your search.'**
  String get noMatchingReports;

  /// No description provided for @differentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different test, laboratory or filter.'**
  String get differentSearch;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get clearFilters;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @switchActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'Switch active profile'**
  String get switchActiveProfile;

  /// No description provided for @switchProfileHelp.
  ///
  /// In en, this message translates to:
  /// **'View another person’s reports. Your active profile for uploads and trends will change too.'**
  String get switchProfileHelp;

  /// No description provided for @multipleCollectionDates.
  ///
  /// In en, this message translates to:
  /// **'Multiple collection dates'**
  String get multipleCollectionDates;

  /// No description provided for @unknownCollectionDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown collection date'**
  String get unknownCollectionDate;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profiles. Please try again.'**
  String get profileLoadFailed;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete profile?'**
  String get deleteProfileConfirm;

  /// No description provided for @deleteProfileHelp.
  ///
  /// In en, this message translates to:
  /// **'This profile will be removed. Any data linked to it will be affected.'**
  String get deleteProfileHelp;

  /// No description provided for @profileDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete profile. Please try again.'**
  String get profileDeleteFailed;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add family member'**
  String get addFamilyMember;

  /// No description provided for @familyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Family profiles unavailable'**
  String get familyUnavailable;

  /// No description provided for @familyIntro.
  ///
  /// In en, this message translates to:
  /// **'Reports and trends, organized by person'**
  String get familyIntro;

  /// No description provided for @noProfilesYet.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet'**
  String get noProfilesYet;

  /// No description provided for @noProfilesHelp.
  ///
  /// In en, this message translates to:
  /// **'Add a profile to organize reports for yourself or family members.'**
  String get noProfilesHelp;

  /// No description provided for @yourFamily.
  ///
  /// In en, this message translates to:
  /// **'Your family'**
  String get yourFamily;

  /// No description provided for @upgradeProfiles.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to add more profiles'**
  String get upgradeProfiles;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get deleteProfile;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @setActive.
  ///
  /// In en, this message translates to:
  /// **'Set active'**
  String get setActive;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View reports'**
  String get viewReports;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications?'**
  String get enableNotificationsConfirm;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Report notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsStayOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications remain off. You can enable them later in device settings.'**
  String get notificationsStayOff;

  /// No description provided for @notificationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not enable notifications. Check your connection and try again.'**
  String get notificationsFailed;

  /// No description provided for @switchProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to switch profiles. Please try again.'**
  String get switchProfileFailed;

  /// No description provided for @sourceReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open source report.'**
  String get sourceReportFailed;

  /// No description provided for @partialRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Some information could not be refreshed. Pull down to try again.'**
  String get partialRefreshFailed;

  /// No description provided for @knowReportReady.
  ///
  /// In en, this message translates to:
  /// **'Know when your report is ready'**
  String get knowReportReady;

  /// No description provided for @oneResult.
  ///
  /// In en, this message translates to:
  /// **'One result'**
  String get oneResult;

  /// No description provided for @sameDayResults.
  ///
  /// In en, this message translates to:
  /// **'Same-day results'**
  String get sameDayResults;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// No description provided for @accountCreatedLogin.
  ///
  /// In en, this message translates to:
  /// **'Your account was created successfully. Continue to login.'**
  String get accountCreatedLogin;

  /// No description provided for @continueLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue to login'**
  String get continueLogin;

  /// No description provided for @allReports.
  ///
  /// In en, this message translates to:
  /// **'All reports'**
  String get allReports;

  /// No description provided for @filterReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get filterReviewed;

  /// No description provided for @filterNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get filterNeedsReview;

  /// No description provided for @filterProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get filterProcessing;

  /// No description provided for @filterOriginalOnly.
  ///
  /// In en, this message translates to:
  /// **'Original only'**
  String get filterOriginalOnly;

  /// No description provided for @reportDateNewest.
  ///
  /// In en, this message translates to:
  /// **'Report date · newest'**
  String get reportDateNewest;

  /// No description provided for @reportDateOldest.
  ///
  /// In en, this message translates to:
  /// **'Report date · oldest'**
  String get reportDateOldest;

  /// No description provided for @uploadDateNewest.
  ///
  /// In en, this message translates to:
  /// **'Upload date · newest'**
  String get uploadDateNewest;

  /// No description provided for @uploadDateOldest.
  ///
  /// In en, this message translates to:
  /// **'Upload date · oldest'**
  String get uploadDateOldest;

  /// No description provided for @switchAction.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchAction;

  /// No description provided for @collectionDate.
  ///
  /// In en, this message translates to:
  /// **'Collection date'**
  String get collectionDate;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @loadingReport.
  ///
  /// In en, this message translates to:
  /// **'Loading report…'**
  String get loadingReport;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// No description provided for @testName.
  ///
  /// In en, this message translates to:
  /// **'Test name'**
  String get testName;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View report'**
  String get viewReport;

  /// No description provided for @closeAccount.
  ///
  /// In en, this message translates to:
  /// **'Close account'**
  String get closeAccount;

  /// No description provided for @createShareLink.
  ///
  /// In en, this message translates to:
  /// **'Create link'**
  String get createShareLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Appearance changed, but could not be saved for next time.'**
  String get uiAppearanceChangedButCouldNotBeSaved;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This report is no longer available.'**
  String get uiThisReportIsNoLongerAvailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Open device Settings to manage notification previews.'**
  String get uiOpenDeviceSettingsToManageNotificationPreviews;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep this screen open until the upload is accepted.'**
  String get uiKeepThisScreenOpenUntilTheUpload;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'An upload may have been interrupted'**
  String get uiAnUploadMayHaveBeenInterrupted;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Check Reports. If it is missing, add the same file again.'**
  String get uiCheckReportsIfItIsMissingAdd;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not dismiss notifications. Try again.'**
  String get uiCouldNotDismissNotificationsTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Connection unavailable'**
  String get uiConnectionUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your session could not be checked. Connect to the internet and try again.'**
  String get uiYourSessionCouldNotBeCheckedConnect;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Sign in with another account'**
  String get uiSignInWithAnotherAccount;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No active profile'**
  String get uiNoActiveProfile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Dismiss upload notice'**
  String get uiDismissUploadNotice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Dismiss ready notifications'**
  String get uiDismissReadyNotifications;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Request support'**
  String get uiRequestSupport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'We will include diagnostic IDs so the team can investigate.'**
  String get uiWeWillIncludeDiagnosticIDsSoThe;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get uiSendRequest;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'What happened? (optional)'**
  String get uiWhatHappenedOptional;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Review result'**
  String get uiReviewResult;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Compare these fields with the original report before saving.'**
  String get uiCompareTheseFieldsWithTheOriginalReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Originally extracted'**
  String get uiOriginallyExtracted;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reload report'**
  String get uiReloadReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Result as printed'**
  String get uiResultAsPrinted;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unit (if shown)'**
  String get uiUnitIfShown;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Lab reference range (if shown)'**
  String get uiLabReferenceRangeIfShown;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Check your report'**
  String get uiCheckYourReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No attempt history available.'**
  String get uiNoAttemptHistoryAvailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'I inspected the original'**
  String get uiIInspectedTheOriginal;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose two reports'**
  String get uiChooseTwoReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use records for the same person. Matching tests will appear side by side.'**
  String get uiUseRecordsForTheSamePersonMatching;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose the older report first and the newer report second.'**
  String get uiChooseTheOlderReportFirstAndThe;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Compared only when compatible. Different units or methods are shown separately until compatibility is confirmed.'**
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'A change is not a diagnosis. Compare each result with its own report interval and discuss the context with your clinician.'**
  String get uiAChangeIsNotADiagnosisCompare;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose different reports'**
  String get uiChooseDifferentReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Earlier report'**
  String get uiEarlierReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Later report'**
  String get uiLaterReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your report pages'**
  String get uiYourReportPages;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep pages in the same order as the report.'**
  String get uiKeepPagesInTheSameOrderAs;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Add another page'**
  String get uiAddAnotherPage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose pages from gallery'**
  String get uiChoosePagesFromGallery;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Adjust page'**
  String get uiAdjustPage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get uiRetake;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use adjusted page'**
  String get uiUseAdjustedPage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reset changes'**
  String get uiResetChanges;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep every result inside the corners.'**
  String get uiKeepEveryResultInsideTheCorners;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get uiRotate;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report restored'**
  String get uiReportRestored;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Delete report permanently?'**
  String get uiDeleteReportPermanently;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get uiDeletePermanently;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report permanently deleted'**
  String get uiReportPermanentlyDeleted;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Empty Recycle Bin?'**
  String get uiEmptyRecycleBin;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get uiDeleteAll;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Recycle bin is empty.'**
  String get uiRecycleBinIsEmpty;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Deleted reports will appear here before removal.'**
  String get uiDeletedReportsWillAppearHereBeforeRemoval;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Empty recycle bin'**
  String get uiEmptyRecycleBind657e2;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Check detected result'**
  String get uiCheckDetectedResult;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Compare this row with the original report. Correct any OCR mistakes before saving.'**
  String get uiCompareThisRowWithTheOriginalReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'I checked this result against the original report'**
  String get uiICheckedThisResultAgainstTheOriginal;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get uiSaving;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Save verified result'**
  String get uiSaveVerifiedResult;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No results were detected. View the original report or retry processing.'**
  String get uiNoResultsWereDetectedViewTheOriginal;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Detected values need to be checked against the original report before they become saved results.'**
  String get uiDetectedValuesNeedToBeCheckedAgainst;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Some rows may be missing. Inspect the entire original report.'**
  String get uiSomeRowsMayBeMissingInspectThe;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get uiResult;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unit (optional)'**
  String get uiUnitOptional;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reference range (optional)'**
  String get uiReferenceRangeOptional;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get uiVerified;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Gift Voucher'**
  String get uiGiftVoucher;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Redeem a gift voucher and add credits directly to your balance.'**
  String get uiRedeemAGiftVoucherAndAddCredits;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get uiCurrentPlan;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String get uiCreditBalance;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Plan Limits'**
  String get uiPlanLimits;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get uiBuyCredits;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Recent Billing Activity'**
  String get uiRecentBillingActivity;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get uiRefreshStatus;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No recent orders yet.'**
  String get uiNoRecentOrdersYet;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Voucher code'**
  String get uiVoucherCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get uiCheckout;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get uiApply;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get uiClear;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get uiPay;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No credit packs available at this time.'**
  String get uiNoCreditPacksAvailableAtThisTime;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get uiBuy;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Retry payment'**
  String get uiRetryPayment;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get uiPromoCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get uiEnterPromoCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get uiChooseAPlan;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No plans available at this time.'**
  String get uiNoPlansAvailableAtThisTime;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Have a promo code?'**
  String get uiHaveAPromoCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PLAN'**
  String get uiCURRENTPLAN;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get uiManageNotifications;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get uiAll;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get uiUnread;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Access stops immediately. You can sign in and restore within 30 days. After that, your account and stored files are deleted from active storage.'**
  String get uiAccessStopsImmediatelyYouCanSignIn;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Close My Account'**
  String get uiCloseMyAccount;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your records stay in Doclyzer.'**
  String get uiYourRecordsStayInDoclyzer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Take a copy of your records.'**
  String get uiTakeACopyOfYourRecords;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Whose records?'**
  String get uiWhoseRecords;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not load profiles'**
  String get uiCouldNotLoadProfiles;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Loading profiles…'**
  String get uiLoadingProfiles;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'All profiles'**
  String get uiAllProfiles;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get uiDateRange;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use all dates'**
  String get uiUseAllDates;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'INCLUDE IN THIS EXPORT'**
  String get uiINCLUDEINTHISEXPORT;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Original reports'**
  String get uiOriginalReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'PDFs and images you uploaded'**
  String get uiPDFsAndImagesYouUploaded;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Test results'**
  String get uiTestResults;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Results as CSV, with their review state'**
  String get uiResultsAsCSVWithTheirReviewState;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Exports contain personal information. Store them somewhere you trust.'**
  String get uiExportsContainPersonalInformationStoreThemSomewhere;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get uiDeleteAccount;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Continue to deletion'**
  String get uiContinueToDeletion;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get uiKeepMyAccount;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Before you leave'**
  String get uiBeforeYouLeave;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Please read what this will remove.'**
  String get uiPleaseReadWhatThisWillRemove;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account affects all profiles you manage.'**
  String get uiDeletingYourAccountAffectsAllProfilesYou;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your account and personal profile'**
  String get uiYourAccountAndPersonalProfile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Access through your shared links'**
  String get uiAccessThroughYourSharedLinks;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep a copy first'**
  String get uiKeepACopyFirst;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export the information you want to retain.'**
  String get uiExportTheInformationYouWantToRetain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get uiExportData;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Access stops immediately. You can restore within 30 days. After that, your data is removed from active storage.'**
  String get uiAccessStopsImmediatelyYouCanRestoreWithin;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Account pending deletion'**
  String get uiAccountPendingDeletion;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Restore my account'**
  String get uiRestoreMyAccount;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Download a copy of your account data including your profile, profiles, and consent records.'**
  String get uiDownloadACopyOfYourAccountData;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your account is disabled immediately. You can restore it within 30 days. After that, your data is permanently deleted.'**
  String get uiYourAccountIsDisabledImmediatelyYouCan;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get uiCurrentPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not change App lock. Try again.'**
  String get uiCouldNotChangeAppLockTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your records.\nYour choice to share.'**
  String get uiYourRecordsYourChoiceToShare;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Review access whenever you need.'**
  String get uiReviewAccessWheneverYouNeed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get uiAppLock;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use your device’s biometric or passcode lock.'**
  String get uiUseYourDeviceSBiometricOrPasscode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Notification previews'**
  String get uiNotificationPreviews;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Control lock-screen previews in your device settings.'**
  String get uiControlLockScreenPreviewsInYourDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get uiContactSupport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Attach reports only if you choose to.'**
  String get uiAttachReportsOnlyIfYouChooseTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'What can we help you with?'**
  String get uiWhatCanWeHelpYouWith;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'POPULAR QUESTIONS'**
  String get uiPOPULARQUESTIONS;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No help articles match your search.'**
  String get uiNoHelpArticlesMatchYourSearch;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'For questions about your health or test results, speak with a qualified healthcare professional.'**
  String get uiForQuestionsAboutYourHealthOrTest;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your reports. A clearer picture.'**
  String get uiYourReportsAClearerPicture;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep your health history together.'**
  String get uiKeepYourHealthHistoryTogether;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Store reports, review results, follow changes and share with your clinician.'**
  String get uiStoreReportsReviewResultsFollowChangesAnd;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Educational information only'**
  String get uiEducationalInformationOnly;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Search help articles'**
  String get uiSearchHelpArticles;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Open the device Settings app to change notification access.'**
  String get uiOpenTheDeviceSettingsAppToChange;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get uiSavePreferences;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Device permissions can be changed in Settings.'**
  String get uiDevicePermissionsCanBeChangedInSettings;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Get report updates on this device'**
  String get uiGetReportUpdatesOnThisDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to know when a report is ready. Marketing is a separate choice below.'**
  String get uiAllowNotificationsToKnowWhenAReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'REPORT ACTIVITY'**
  String get uiREPORTACTIVITY;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report activity settings require the latest server version.'**
  String get uiReportActivitySettingsRequireTheLatestServer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Sensitive lock-screen previews'**
  String get uiSensitiveLockScreenPreviews;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report names and personal details are always hidden.'**
  String get uiReportNamesAndPersonalDetailsAreAlways;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'OTHER MESSAGES'**
  String get uiOTHERMESSAGES;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep each person’s reports and trends together.'**
  String get uiKeepEachPersonSReportsAndTrends;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Person details'**
  String get uiPersonDetails;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get uiDateOfBirth;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get uiRelationship;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get uiEnterAName;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Clear date of birth'**
  String get uiClearDateOfBirth;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. parent or child'**
  String get uiOptionalEGParentOrChild;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Invite friends, earn credits'**
  String get uiInviteFriendsEarnCredits;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share your code and follow each invite as rewards unlock.'**
  String get uiShareYourCodeAndFollowEachInvite;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'YOUR REFERRAL CODE'**
  String get uiYOURREFERRALCODE;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share invite'**
  String get uiShareInvite;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get uiCopyCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Have a code?'**
  String get uiHaveACode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter a code shared with you to claim your invite reward.'**
  String get uiEnterACodeSharedWithYouTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'How rewards work'**
  String get uiHowRewardsWork;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No friends referred yet'**
  String get uiNoFriendsReferredYet;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share your invite to see their progress here.'**
  String get uiShareYourInviteToSeeTheirProgress;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral code'**
  String get uiReferralCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get uiSetNewPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter the reset token from the link in your email and your new password.'**
  String get uiEnterTheResetTokenFromTheLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get uiResetPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get uiBackToLogin;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reset Token'**
  String get uiResetToken;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get uiNewPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address associated with your account and we\'ll send you a link to reset your password.'**
  String get uiEnterTheEmailAddressAssociatedWithYour;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get uiSendResetLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Revoke session?'**
  String get uiRevokeSession;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get uiCurrentSession;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get uiSkip;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get uiChangePassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new one.'**
  String get uiEnterYourCurrentPasswordAndChooseA;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get uiNewPasswordd850ee;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get uiConfirmNewPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready…'**
  String get uiGettingThingsReady;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Link Access History'**
  String get uiLinkAccessHistory;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No access events yet.'**
  String get uiNoAccessEventsYet;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Default Share Link Expiry'**
  String get uiDefaultShareLinkExpiry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get uiSave;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Review sharing'**
  String get uiReviewSharing;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Check the person, reports and access.'**
  String get uiCheckThePersonReportsAndAccess;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Edit selection or access settings'**
  String get uiEditSelectionOrAccessSettings;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Revoke share link?'**
  String get uiRevokeShareLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This link will stop working. You can create a new one.'**
  String get uiThisLinkWillStopWorkingYouCan;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share link ready'**
  String get uiShareLinkReady;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Access code — share separately'**
  String get uiAccessCodeShareSeparately;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Copy access code'**
  String get uiCopyAccessCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This code could not be saved on this device. Copy it now for later use.'**
  String get uiThisCodeCouldNotBeSavedOn;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get uiShareLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get uiCopyLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Revoke link'**
  String get uiRevokeLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Code unavailable on this device. Use the saved code or create a new link.'**
  String get uiCodeUnavailableOnThisDeviceUseThe;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Active shared links'**
  String get uiActiveSharedLinks;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get uiShare;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Create a new share link'**
  String get uiCreateANewShareLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Include current and future reports for this profile.'**
  String get uiIncludeCurrentAndFutureReportsForThis;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose reports'**
  String get uiChooseReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share only the reports selected below.'**
  String get uiShareOnlyTheReportsSelectedBelow;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get uiSelectAll;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No reviewed reports are available to share.'**
  String get uiNoReviewedReportsAreAvailableToShare;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Selected test results'**
  String get uiSelectedTestResults;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Include only the results you choose from these reports.'**
  String get uiIncludeOnlyTheResultsYouChooseFrom;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No saved test results are available in these reports.'**
  String get uiNoSavedTestResultsAreAvailableIn;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Upgrade or Manage'**
  String get uiUpgradeOrManage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Expiry:'**
  String get uiExpiry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Require an access code'**
  String get uiRequireAnAccessCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share the code separately from the link.'**
  String get uiShareTheCodeSeparatelyFromTheLink;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get uiTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Clear expiry'**
  String get uiClearExpiry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'01 / STORE'**
  String get onboardingStoreEyebrow;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Every report,\none familiar place.'**
  String get onboardingStoreTitle;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Keep PDFs and photos together, for you and the people you care for.'**
  String get onboardingStoreBody;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'02 / UNDERSTAND'**
  String get onboardingUnderstandEyebrow;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'The numbers,\nmade easier to read.'**
  String get onboardingUnderstandTitle;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'See each test, its unit and the interval from your report. Check the original anytime.'**
  String get onboardingUnderstandBody;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'03 / TRACK & SHARE'**
  String get onboardingTrackEyebrow;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'See the changes.\nShare the context.'**
  String get onboardingTrackTitle;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Follow results over time and choose exactly what your clinician can see.'**
  String get onboardingTrackBody;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Support request sent.'**
  String get uiSupportRequestSent;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Test name and result are required.'**
  String get uiTestNameAndResultAreRequired;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use a valid collection date in YYYY-MM-DD format.'**
  String get uiUseAValidCollectionDateInYYYY;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not save this correction. Try again.'**
  String get uiCouldNotSaveThisCorrectionTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reports unavailable'**
  String get uiReportsUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get uiTryAgain042c86;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Two reports are needed'**
  String get uiTwoReportsAreNeeded;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Add an older report for this profile to compare results.'**
  String get uiAddAnOlderReportForThisProfile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Cannot compare yet'**
  String get uiCannotCompareYet;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'These reports have no matching results available for comparison.'**
  String get uiTheseReportsHaveNoMatchingResultsAvailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reports. Try again.'**
  String get uiUnableToLoadReportsTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not open photos or camera.'**
  String get uiCouldNotOpenPhotosOrCamera;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not open camera.'**
  String get uiCouldNotOpenCamera;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare these pages. Retake an unreadable page and try again.'**
  String get uiCouldNotPrepareThesePagesRetakeAn;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not adjust this page.'**
  String get uiCouldNotAdjustThisPage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No chartable result yet'**
  String get uiNoChartableResultYet;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get uiProfiles;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get uiReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share links'**
  String get uiShareLinks;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get uiAIChat;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to load entitlement summary. Please try again.'**
  String get uiFailedToLoadEntitlementSummaryPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh billing status. Please try again.'**
  String get uiFailedToRefreshBillingStatusPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Receipt download will be available soon.'**
  String get uiReceiptDownloadWillBeAvailableSoon;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get uiSubtotal;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get uiDiscount;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get uiTotal;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to load credit packs. Please try again.'**
  String get uiFailedToLoadCreditPacksPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'A payment is pending capture. Refresh status before starting another checkout.'**
  String get uiAPaymentIsPendingCaptureRefreshStatus;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Credits were applied successfully.'**
  String get uiCreditsWereAppliedSuccessfully;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to create order. Please try again.'**
  String get uiFailedToCreateOrderPleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment received. Awaiting server reconciliation before credits are added.'**
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. You can retry checkout when ready.'**
  String get uiPaymentFailedYouCanRetryCheckoutWhen;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Try again.'**
  String get uiPaymentFailedTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Credits added!'**
  String get uiCreditsAdded;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied.'**
  String get uiPromoCodeApplied;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment received, but this order is pending review.'**
  String get uiPaymentReceivedButThisOrderIsPending;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment failed during reconciliation.'**
  String get uiPaymentFailedDuringReconciliation;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed. Server reconciliation is still pending.'**
  String get uiPaymentConfirmedServerReconciliationIsStillPending;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment verified. Reconciliation is pending, please refresh shortly.'**
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment received but verification is still pending. Please refresh status.'**
  String get uiPaymentReceivedButVerificationIsStillPending;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans. Please try again.'**
  String get uiFailedToLoadPlansPleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to create subscription. Please try again.'**
  String get uiFailedToCreateSubscriptionPleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Subscription failed. Try again.'**
  String get uiSubscriptionFailedTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Plan upgraded!'**
  String get uiPlanUpgraded;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment received but verification failed. Plan will be upgraded shortly.'**
  String get uiPaymentReceivedButVerificationFailedPlanWill;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Notifications unavailable'**
  String get uiNotificationsUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'All quiet for now.'**
  String get uiAllQuietForNow;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report updates and sharing reminders will appear here when there’s something new.'**
  String get uiReportUpdatesAndSharingRemindersWillAppear;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No unread updates'**
  String get uiNoUnreadUpdates;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'You’re all caught up.'**
  String get uiYouReAllCaughtUp;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications. Try again when connected.'**
  String get uiUnableToLoadNotificationsTryAgainWhen;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Manage shared links'**
  String get uiManageSharedLinks;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export your data'**
  String get uiExportYourData;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Read the Privacy Policy'**
  String get uiReadThePrivacyPolicy;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get uiTermsOfUse;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get uiPrivacyPolicy;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Date of birth, optional'**
  String get uiDateOfBirthOptional;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Relationship must be 50 characters or fewer.'**
  String get uiRelationshipMustBe50CharactersOrFewer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile. Please try again.'**
  String get uiFailedToSaveProfilePleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referrals unavailable'**
  String get uiReferralsUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your rewards'**
  String get uiYourRewards;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral progress'**
  String get uiReferralProgress;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Friends referred'**
  String get uiFriendsReferred;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Credits earned'**
  String get uiCreditsEarned;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Pending rewards'**
  String get uiPendingRewards;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Blocked rewards'**
  String get uiBlockedRewards;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Invitee bonus'**
  String get uiInviteeBonus;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'First analysis'**
  String get uiFirstAnalysis;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'First purchase'**
  String get uiFirstPurchase;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Monthly cap'**
  String get uiMonthlyCap;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to load referrals. Please try again.'**
  String get uiFailedToLoadReferralsPleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied.'**
  String get uiReferralCodeCopied;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter the reset token from your email link'**
  String get uiEnterTheResetTokenFromYourEmail;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get uiEnterYourNewPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset password. Please request a new link.'**
  String get uiUnableToResetPasswordPleaseRequestA;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get uiEnterYourEmailAddress;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset link. Please try again.'**
  String get uiUnableToSendResetLinkPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to load sessions.'**
  String get uiFailedToLoadSessions;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke session.'**
  String get uiFailedToRevokeSession;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to change password. Please try again.'**
  String get uiUnableToChangePasswordPleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Open device Settings and allow notifications for Doclyzer.'**
  String get uiOpenDeviceSettingsAndAllowNotificationsFor;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reports could not be loaded. Try again.'**
  String get uiReportsCouldNotBeLoadedTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Test results could not be loaded. Try again.'**
  String get uiTestResultsCouldNotBeLoadedTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Select at least one report to share.'**
  String get uiSelectAtLeastOneReportToShare;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Select at least one test result to share.'**
  String get uiSelectAtLeastOneTestResultTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get uiLinkCopiedToClipboard;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Access code copied to clipboard'**
  String get uiAccessCodeCopiedToClipboard;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 person'**
  String get uiOnePerson;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String uiPeopleCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Actions for {name}'**
  String uiActionsFor(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to switch profiles. {message}'**
  String uiUnableToSwitchProfilesDetail(String message);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String uiSwitchedTo(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Analyze 1 page'**
  String get uiAnalyzeOnePage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Analyze {count} pages'**
  String uiAnalyzePages(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Drag pages into the order shown in your report'**
  String get uiDragPagesIntoOrder;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Check every page before analyzing'**
  String get uiCheckEveryPage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 page added'**
  String get uiOnePageAdded;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} pages added'**
  String uiPagesAdded(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get uiReorder;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String uiPageNumber(String number);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Remove page {number}'**
  String uiRemovePage(String number);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{name} · Page {number}'**
  String uiProfilePage(String name, String number);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Crop edges: {percent}%'**
  String uiCropEdges(String percent);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} selected reports'**
  String uiSelectedReportsCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} selected test results'**
  String uiSelectedTestResultsCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'All current and future reports'**
  String get uiAllCurrentFutureReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get uiNoExpiry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String uiExpiresDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Access code required. Share it separately from the link.'**
  String get uiAccessCodeRequiredSeparate;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No access code required.'**
  String get uiNoAccessCodeRequired;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String uiExpiresColonDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Share {name}’s reports'**
  String uiShareProfileReports(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{name}’s reports'**
  String uiProfileReports(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} selected results'**
  String uiSelectedResultsCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Access code required'**
  String get uiAccessCodeRequiredShort;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Past links · {count}'**
  String uiPastLinksCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Expired {date}'**
  String uiExpiredDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Revoked · Created {date}'**
  String uiRevokedCreatedDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Using {current} of {maximum} active links.'**
  String uiUsingActiveLinks(String current, String maximum);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Delete {filename} and its stored file? This cannot be undone.'**
  String uiDeleteReportAndStoredFile(String filename);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete report: {error}'**
  String uiUnableDeleteReportDetail(String error);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all {count} reports and their stored files? This cannot be undone.'**
  String uiDeleteAllReportsAndFiles(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin emptied'**
  String get uiRecycleBinEmptied;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Deleted {deleted} reports. {failed} could not be deleted; try again.'**
  String uiSomeReportsDeleteFailed(String deleted, String failed);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to empty Recycle Bin: {error}'**
  String uiUnableEmptyRecycleBinDetail(String error);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Profile: {name}'**
  String uiProfileName(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Collected: {date}'**
  String uiCollectedDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Uploaded: {date}'**
  String uiUploadedDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Deleted on: {date}'**
  String uiDeletedOn(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Permanent delete on: {date}'**
  String uiPermanentDeleteOn(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Days left: {count}'**
  String uiDaysLeft(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Confirm App lock for Doclyzer'**
  String get uiConfirmAppLockForDoclyzer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Confirm before turning off App lock'**
  String get uiConfirmBeforeTurningOffAppLock;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unlock Doclyzer to view your health records'**
  String get uiUnlockDoclyzerToViewYourHealthRecords;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Create a default profile before uploading a report.'**
  String get uiCreateADefaultProfileBeforeUploadingA;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Create a default profile before viewing your timeline.'**
  String get uiCreateADefaultProfileBeforeViewingYour;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profiles right now.'**
  String get uiUnableToLoadProfilesRightNow;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Cannot upload right now because profile data could not be loaded. Please ensure API server is running and try again.'**
  String get uiCannotUploadRightNowBecauseProfileData;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Cannot open timeline right now because profile data could not be loaded. Please ensure API server is running and try again.'**
  String get uiCannotOpenTimelineRightNowBecauseProfile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profiles right now. Please try again.'**
  String get uiUnableToLoadProfilesRightNowPlease;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sharing links. Please try again.'**
  String get uiUnableToLoadSharingLinksPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get uiPasswordChanged;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to open that report. Try the report library.'**
  String get uiUnableToOpenThatReportTryThe;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This action is temporarily unavailable while your account is under review.'**
  String get uiThisActionIsTemporarilyUnavailableWhileYour;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this section. Please try again.'**
  String get uiUnableToOpenThisSectionPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'App lock is unavailable'**
  String get uiAppLockIsUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Doclyzer is locked'**
  String get uiDoclyzerIsLocked;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not read the saved App lock setting. Retry to continue.'**
  String get uiCouldNotReadTheSavedAppLock;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use your device passcode or biometrics to continue.'**
  String get uiUseYourDevicePasscodeOrBiometricsTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Uploads are temporarily unavailable while your account is under review.'**
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to start an upload. Please try again.'**
  String get uiUnableToStartAnUploadPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get uiJustNow;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Additional details: '**
  String get uiAdditionalDetails;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Save correction'**
  String get uiSaveCorrection;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not open files. Check access and try again.'**
  String get uiCouldNotOpenFilesCheckAccessAnd;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not open camera. Check permission and try again.'**
  String get uiCouldNotOpenCameraCheckPermissionAnd;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not open photos. Check permission and try again.'**
  String get uiCouldNotOpenPhotosCheckPermissionAnd;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not access selected file.'**
  String get uiCouldNotAccessSelectedFile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not access selected file'**
  String get uiCouldNotAccessSelectedFile45effa;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. The upload may have reached the server. Retry the same file safely.'**
  String get uiConnectionLostTheUploadMayHaveReached;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not load existing report'**
  String get uiCouldNotLoadExistingReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Adding to  '**
  String get uiAddingTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Some results need review. Your original report is saved.'**
  String get uiSomeResultsNeedReviewYourOriginalReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read this format. Your file is saved.'**
  String get uiWeCouldnTReadThisFormatYour;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report parsed successfully. Results and trends are available.'**
  String get uiReportParsedSuccessfullyResultsAndTrendsAre;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your report is still being analyzed. Open it to check its status.'**
  String get uiYourReportIsStillBeingAnalyzedOpen;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Processing stopped. Your file is saved. You can retry.'**
  String get uiProcessingStoppedYourFileIsSavedYou;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No extracted test values were added. You can still open and share the document. Your trends are unchanged.'**
  String get uiNoExtractedTestValuesWereAddedYou;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your original is saved.'**
  String get uiYourOriginalIsSaved;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Initial upload'**
  String get uiInitialUpload;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Parsed successfully'**
  String get uiParsedSuccessfully;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Parsing failed'**
  String get uiParsingFailed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Extraction incomplete'**
  String get uiExtractionIncomplete;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Transient failure'**
  String get uiTransientFailure;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Terminal failure'**
  String get uiTerminalFailure;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to load attempt history'**
  String get uiFailedToLoadAttemptHistory;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This report\'s file is no longer available.'**
  String get uiThisReportSFileIsNoLonger;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Compare results'**
  String get uiCompareResults;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No difference calculated. Compatibility needs confirmation.'**
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unit not recorded'**
  String get uiUnitNotRecorded;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No numeric change between these reports.'**
  String get uiNoNumericChangeBetweenTheseReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to restore: '**
  String get uiUnableToRestore;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter a gift voucher code.'**
  String get uiEnterAGiftVoucherCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Apply Voucher'**
  String get uiApplyVoucher;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get uiNotAvailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get uiViewReceipt;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Gift voucher is invalid or already redeemed.'**
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Gift voucher has already been redeemed.'**
  String get uiGiftVoucherHasAlreadyBeenRedeemed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Gift voucher has been voided.'**
  String get uiGiftVoucherHasBeenVoided;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Gift voucher has expired.'**
  String get uiGiftVoucherHasExpired;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to redeem this gift voucher.'**
  String get uiUnableToRedeemThisGiftVoucher;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to redeem this gift voucher. Please try again.'**
  String get uiUnableToRedeemThisGiftVoucherPlease;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter a promo code to apply.'**
  String get uiEnterAPromoCodeToApply;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo code not found.'**
  String get uiPromoCodeNotFound;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo code is inactive.'**
  String get uiPromoCodeIsInactive;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo code has expired.'**
  String get uiPromoCodeHasExpired;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo code is not applicable to this pack.'**
  String get uiPromoCodeIsNotApplicableToThis;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo code usage limit reached.'**
  String get uiPromoCodeUsageLimitReached;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'You have already used this promo code.'**
  String get uiYouHaveAlreadyUsedThisPromoCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply promo code. Please try again.'**
  String get uiFailedToApplyPromoCodePleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This order was flagged for review before credits could be added.'**
  String get uiThisOrderWasFlaggedForReviewBefore;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Payment failed during reconciliation. You can retry safely.'**
  String get uiPaymentFailedDuringReconciliationYouCanRetry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Awaiting capture'**
  String get uiAwaitingCapture;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Last payment failed'**
  String get uiLastPaymentFailed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'You can retry checkout safely.'**
  String get uiYouCanRetryCheckoutSafely;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Promo codes not supported for subscriptions yet.'**
  String get uiPromoCodesNotSupportedForSubscriptionsYet;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not download the export. Try again.'**
  String get uiCouldNotDownloadTheExportTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Select original reports or test results.'**
  String get uiSelectOriginalReportsOrTestResults;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export requested. Tap \"Check Status\" to refresh.'**
  String get uiExportRequestedTapCheckStatusToRefresh;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to request export. Please try again.'**
  String get uiFailedToRequestExportPleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export ready. Download URL available.'**
  String get uiExportReadyDownloadURLAvailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to check export status. Please try again.'**
  String get uiFailedToCheckExportStatusPleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to close account. Please try again.'**
  String get uiFailedToCloseAccountPleaseTryAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Prepare export'**
  String get uiPrepareExport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Save export'**
  String get uiSaveExport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Prepare export again'**
  String get uiPrepareExportAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get uiAllDates;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Preparing account details'**
  String get uiPreparingAccountDetails;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Family member profiles'**
  String get uiFamilyMemberProfiles;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Uploaded reports'**
  String get uiUploadedReports;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Download ready'**
  String get uiDownloadReady;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report notifications enabled on this device'**
  String get uiReportNotificationsEnabledOnThisDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Device settings opened. Allow notifications for Doclyzer, then return here.'**
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Notifications are still off. Allow them in device settings to receive report updates.'**
  String get uiNotificationsAreStillOffAllowThemIn;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get uiPreferencesSaved;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your account choice was saved, but this device did not finish registering for marketing push. Marketing remains blocked on this device; check notification permission and try saving again.'**
  String get uiYourAccountChoiceWasSavedButThis;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your account choice was saved. This device could not confirm its local preference yet, but marketing remains blocked at account level.'**
  String get uiYourAccountChoiceWasSavedThisDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your account choice was saved, but this device could not enable marketing push. Check notification permission and try again.'**
  String get uiYourAccountChoiceWasSavedButThisaf7de6;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Saving took too long. Check your connection and try again.'**
  String get uiSavingTookTooLongCheckYourConnection;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report ready for review'**
  String get uiReportReadyForReview;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Know when your results are ready to check.'**
  String get uiKnowWhenYourResultsAreReadyTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Upload updates'**
  String get uiUploadUpdates;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Get a message if an upload needs attention.'**
  String get uiGetAMessageIfAnUploadNeeds;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Shared link reminders'**
  String get uiSharedLinkReminders;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Hear when a link is about to expire.'**
  String get uiHearWhenALinkIsAboutTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Security alerts'**
  String get uiSecurityAlerts;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Required for account safety.'**
  String get uiRequiredForAccountSafety;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Compliance notices'**
  String get uiComplianceNotices;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Required account information.'**
  String get uiRequiredAccountInformation;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Marketing push notifications'**
  String get uiMarketingPushNotifications;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Offers and announcements. Saving this choice also applies it to this device.'**
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Product updates'**
  String get uiProductUpdates;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Optional news about Doclyzer.'**
  String get uiOptionalNewsAboutDoclyzer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Please check your internet or API server.'**
  String get uiCannotConnectToServerPleaseCheckYour;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Profile updates are temporarily unavailable while your account is under review.'**
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use 100 characters or fewer'**
  String get uiUse100CharactersOrFewer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Add profile'**
  String get uiAddProfile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get uiCreateProfile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Update their details'**
  String get uiUpdateTheirDetails;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Who is this profile for?'**
  String get uiWhoIsThisProfileFor;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get uiNotSelected;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter a referral code.'**
  String get uiEnterAReferralCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral applied. Bonus unlocks after email verification.'**
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral applied. Bonus credits are ready.'**
  String get uiReferralAppliedBonusCreditsAreReady;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Apply code'**
  String get uiApplyCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'You cannot apply your own referral code.'**
  String get uiYouCannotApplyYourOwnReferralCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral code is invalid.'**
  String get uiReferralCodeIsInvalid;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply referral code.'**
  String get uiFailedToApplyReferralCode;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to apply referral code. Please try again.'**
  String get uiFailedToApplyReferralCodePleaseTry;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get uiThisDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Signed-in device'**
  String get uiSignedInDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get uiUnknownDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Revoke and log out'**
  String get uiRevokeAndLogOut;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Revoke session'**
  String get uiRevokeSessionca8440;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get uiEnterYourCurrentPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters with uppercase, lowercase, a number, and a special character'**
  String get uiUseAtLeast8CharactersWithUppercase;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose a different password'**
  String get uiChooseADifferentPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get uiNewPasswordsDoNotMatch;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'You have used all available upload credits. Visit Plan & Credits to add more.'**
  String get uiYouHaveUsedAllAvailableUploadCredits;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled for Doclyzer. Open device Settings to allow report-ready and account updates. Marketing stays off unless you choose it.'**
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Get report-ready and account updates on this device. Marketing stays off unless you choose it.'**
  String get uiGetReportReadyAndAccountUpdatesOn;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for this device. Open Settings to receive report-ready and account updates.'**
  String get uiNotificationsAreOffForThisDeviceOpen;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Blocked (expired/revoked)'**
  String get uiBlockedExpiredRevoked;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to load policy'**
  String get uiFailedToLoadPolicy;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Upload paused'**
  String get uiUploadPaused;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get uiSevenDays;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get uiThirtyDays;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get uiNinetyDays;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Uploading a clear report'**
  String get uiUploadingAClearReport;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'PDFs, photos and multiple pages'**
  String get uiPDFsPhotosAndMultiplePages;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Choose a PDF or take clear photos of every page. Keep the whole page in frame, avoid glare, and check the page order before analyzing. You can correct extracted values against the original.'**
  String get uiChooseAPDFOrTakeClearPhotos;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Correcting a result'**
  String get uiCorrectingAResult;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Review values against the original'**
  String get uiReviewValuesAgainstTheOriginal;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Open a report, review each extracted test against the original, and correct any value, unit, or date that was read incorrectly. Unconfirmed results should be checked before you rely on trends.'**
  String get uiOpenAReportReviewEachExtractedTest;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Managing family records'**
  String get uiManagingFamilyRecords;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Profiles, access and permissions'**
  String get uiProfilesAccessAndPermissions;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use Family to create and switch profiles. Check the selected person before uploading or sharing a report. Manage only records you are authorized to access.'**
  String get uiUseFamilyToCreateAndSwitchProfiles;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Sharing and revoking links'**
  String get uiSharingAndRevokingLinks;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Control the records you share'**
  String get uiControlTheRecordsYouShare;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Select the reports or results you want to share, review the expiry and access code, then send the link and code separately. Revoke an active link from Shared links when access is no longer needed.'**
  String get uiSelectTheReportsOrResultsYouWant;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Information you provide'**
  String get uiInformationYouProvide;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Account details and family profiles identify whose records you manage. Uploaded documents may contain sensitive health information.'**
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Sharing controls'**
  String get uiSharingControls;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Review the contents, expiry and access settings of each link. Manage active links from your account settings.'**
  String get uiReviewTheContentsExpiryAndAccessSettings;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export and account choices'**
  String get uiExportAndAccountChoices;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use settings to export records or start an account deletion request. Retention details belong in the complete policy.'**
  String get uiUseSettingsToExportRecordsOrStart;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Educational scope'**
  String get uiEducationalScope;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Doclyzer organizes reports and shows results over time. Educational explanations are not medical advice or a diagnosis.'**
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Review your records'**
  String get uiReviewYourRecords;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Check extracted values, units and dates against the original report. Ask a healthcare professional about your results.'**
  String get uiCheckExtractedValuesUnitsAndDatesAgainst;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Manage and share responsibly'**
  String get uiManageAndShareResponsibly;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Only manage records you are authorized to access. Check the selected information and recipient before sharing.'**
  String get uiOnlyManageRecordsYouAreAuthorizedTo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get uiPrivacyPolicy7ceacd;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get uiTermsOfUse8a069e;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Open privacy controls'**
  String get uiOpenPrivacyControls;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Get help with the app'**
  String get uiGetHelpWithTheApp;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export your data in account settings'**
  String get uiExportYourDataInAccountSettings;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'YOUR DATA & CHOICES'**
  String get uiYOURDATACHOICES;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'USING DOCLYZER'**
  String get uiUSINGDOCLYZER;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Understand the information\nyou keep in Doclyzer.'**
  String get uiUnderstandTheInformationYouKeepInDoclyzer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'A clear understanding\nof the app’s role.'**
  String get uiAClearUnderstandingOfTheAppsRole;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{reportCount} from {name}'**
  String uiReportsFromLab(String reportCount, String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{reportCount} · Latest {date}'**
  String uiReportsLatestDate(String reportCount, String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Upload a report for {name} to start this library.'**
  String uiUploadReportForProfile(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'IP address: {address}'**
  String uiIpAddress(String address);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Signed in: {date}'**
  String uiSignedInAt(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get uiUnknown;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Results for {name}'**
  String uiResultsFor(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} lab parameters tracked'**
  String uiLabParametersTracked(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Sampled {date}'**
  String uiSampledDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Collection date: {date}'**
  String uiCollectionDateValue(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Lab range: {range}'**
  String uiLabRangeValue(String range);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'AI read this range as {range}. Printed text: {printed}. Check the original report before relying on this comparison.'**
  String uiAiSuggestedRange(String range, String printed);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{reportCount} ready'**
  String uiReportsReady(String reportCount);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} credits'**
  String uiCreditsCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'A referral code has already been applied to this account.'**
  String get uiReferralCodeAlreadyApplied;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Set a device passcode before turning on App lock.'**
  String get uiSetDevicePasscodeForAppLock;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Language preference was not saved.'**
  String get uiLanguagePreferenceNotSaved;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export unavailable'**
  String get uiExportUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unreadable image'**
  String get uiUnreadableImage;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String uiStatusWithValue(String status);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get uiPending;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get uiCompleted;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get uiFailed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get uiInactive;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Restore before {date} to keep your reports and profiles.'**
  String uiRestoreBeforeDate(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'the 30-day deadline'**
  String get uiThirtyDayDeadline;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'What’s affected: {details}'**
  String uiWhatsAffected(String details);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date} at {time}'**
  String uiLastUpdatedAt(String date, String time);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{filename} will appear under {name} instead of the current profile.'**
  String uiMoveReportToProfile(String filename, String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 verified result saved.'**
  String get uiOneVerifiedResult;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} verified results saved.'**
  String uiVerifiedResultsCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to switch profiles. {reason}'**
  String uiUnableToSwitchProfilesWithReason(String reason);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Collected: {date}'**
  String uiCollectedOn(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {date}'**
  String uiUploadedPrefix(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{filename} · {date}'**
  String uiReportComparisonLabel(String filename, String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Increased by {amount}'**
  String uiIncreasedBy(String amount);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Decreased by {amount}'**
  String uiDecreasedBy(String amount);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **' percentage points'**
  String get uiPercentagePoints;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Test values ({count})'**
  String uiTestValuesCount(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Value checked by AI during processing. Original OCR: {value}. Confirm it against the report.'**
  String uiAiValueReviewNotice(String value);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report already in {name}'**
  String uiReportAlreadyInProfile(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Report added to {name}'**
  String uiReportAddedToProfile(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String uiAddedOn(String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Using {current} of {max} reports.'**
  String uiUsingReportsLimit(String current, String max);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get uiNeedHelp;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get uiEnabled;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get uiEnable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get uiSubscribe;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Applying'**
  String get uiApplying;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get uiCheckStatus;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get uiEditProfile;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get uiSaveChanges;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get uiOptional;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Order {orderId} is waiting for reconciliation. Buying is paused until status is clear.'**
  String uiPendingOrderReconciliation(String orderId);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan - {name}'**
  String uiMonthlyPlanDescription(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Credit Pack - {name}'**
  String uiCreditPackDescription(String name);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unreadable'**
  String get uiUnreadable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Latest: {value}'**
  String uiLatestValue(String value);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get uiEarlier;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get uiLater;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get uiViewed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get uiBlocked;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Capped'**
  String get uiCapped;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Last change: {label}'**
  String uiLastChange(String label);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Last change: {label} · {date}'**
  String uiLastChangeAt(String label, String date);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Gift voucher applied. {credits} credits added.'**
  String uiGiftVoucherApplied(String credits);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Could not save the original yet. {reason}'**
  String uiCouldNotSaveOriginal(String reason);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke: {reason}'**
  String uiFailedToRevoke(String reason);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Use my Doclyzer referral code {code}: {link}'**
  String uiReferralShareMessage(String code, String link);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'A moment ago'**
  String get uiAMomentAgo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String uiMinutesAgo(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get uiOneHourAgo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String uiHoursAgo(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get uiToday;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get uiYesterday;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get uiOneDayAgo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String uiDaysAgo(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get uiOneWeekAgo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String uiWeeksAgo(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 month ago'**
  String get uiOneMonthAgo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String uiMonthsAgo(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'1 year ago'**
  String get uiOneYearAgo;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'{count} years ago'**
  String uiYearsAgo(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'In 1 day'**
  String get uiInOneDay;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'In {count} days'**
  String uiInDays(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'In {count} min'**
  String uiInMinutes(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'In 1 hour'**
  String get uiInOneHour;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'In {count} hours'**
  String uiInHours(String count);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'The test name is missing from the extracted result.'**
  String get uiMissingExtractedTestName;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'No lab reference range was captured for this test.'**
  String get uiMissingCapturedLabRange;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'The extracted value is not a plain number. Check it in the original report.'**
  String get uiNonNumericExtractedValue;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'The lab flag conflicts with the printed range. Check the original report.'**
  String get uiLabFlagRangeConflict;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'The extracted value, printed range, or lab flag needs checking in the original report.'**
  String get uiResultNeedsOriginalCheck;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Initial entitlement'**
  String get uiInitialEntitlement;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Credit pack purchase'**
  String get uiCreditPackPurchase;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Subscription upgrade'**
  String get uiSubscriptionUpgrade;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Plan downgrade'**
  String get uiPlanDowngrade;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Admin adjustment'**
  String get uiAdminAdjustment;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'System reconciliation'**
  String get uiSystemReconciliation;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral invite bonus'**
  String get uiReferralInviteBonus;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral analysis milestone'**
  String get uiReferralAnalysisMilestone;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Referral purchase milestone'**
  String get uiReferralPurchaseMilestone;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Free promo credit pack'**
  String get uiFreePromoCreditPack;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Gift voucher redeemed'**
  String get uiGiftVoucherRedeemed;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Not yet changed'**
  String get uiNotYetChanged;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach the server. Check your connection and try again.'**
  String get uiCannotReachServer;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Check your details and try again.'**
  String get uiInvalidEmailOrPassword;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a few minutes and try again.'**
  String get uiTooManyAuthAttempts;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get uiEnterValidEmail;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character.'**
  String get uiPasswordRequirements;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Sign in or use a different email.'**
  String get uiAccountWithEmailExists;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uiUploadedStatus;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Action: {action}'**
  String uiSupportAction(String action);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Correlation ID: {id}'**
  String uiSupportCorrelationId(String id);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Client Action ID: {id}'**
  String uiSupportClientActionId(String id);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Error Code: {code}'**
  String uiSupportErrorCode(String code);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String uiSupportError(String error);

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Sign in again.'**
  String get uiSessionExpiredSignInAgain;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Your plan profile limit has been reached. Review Plan & Credits to add more.'**
  String get uiProfileLimitReached;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'This result changed elsewhere. Reload the report before correcting it.'**
  String get uiCorrectionConflictReload;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'See Plan & Credits for available options.'**
  String get uiSeePlanCreditsOptions;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'You have reached the active share-link limit.'**
  String get uiShareLinkLimitHelp;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Scoped export is unavailable. Try again later.'**
  String get uiScopedExportUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Restoration is unavailable. Try again later.'**
  String get uiRestorationUnavailable;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Export request not found. Request a new export.'**
  String get uiExportRequestNotFound;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Confirm account closure to continue.'**
  String get uiClosureConfirmationRequired;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get uiCurrentPasswordIncorrect;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Laboratories'**
  String get uiLaboratories;

  /// Draft mobile UI translation; native-language review required before release.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get uiUnlock;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'or',
    'pa',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
