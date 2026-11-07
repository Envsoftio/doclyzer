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
