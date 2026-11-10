// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get trendLatestResult => 'Latest result';

  @override
  String get trendPreviousResult => 'Previous result';

  @override
  String get trendSourceUnit => 'Source unit for this range';

  @override
  String get trendNoSavedResults =>
      'No saved results are available for this test yet.';

  @override
  String get trendNoPlottableResults =>
      'No exact numeric results with a collection date can be plotted.';

  @override
  String get trendOneResultHelp =>
      'One saved result. Add another report to see a trend.';

  @override
  String get trendMultipleResultsHelp =>
      'Dates are spaced by elapsed time. Tap a point for its value.';

  @override
  String trendUnplottedNote(int count) {
    return '$count results could not be plotted because the collection date or exact numeric value is unavailable.';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$testName trend chart with $count results';
  }

  @override
  String get trendDateReview =>
      'Collection date from an earlier extraction. Check the source report.';

  @override
  String get trendNotPlotted => 'Not plotted';

  @override
  String get trendExactNumberUnavailable => 'Result is not an exact number';

  @override
  String get preferredLanguage => 'Preferred language';

  @override
  String get descriptionLanguage => 'Description language';

  @override
  String get languageHelp =>
      'Used for app labels and report explanations. You can switch the language of an explanation at any time.';

  @override
  String get languageSaveFailed =>
      'Could not save your language. Please try again.';

  @override
  String get translationLoading => 'Preparing the translated description…';

  @override
  String get translationFailed =>
      'Translation is unavailable. Try again or choose English.';

  @override
  String get translationNote =>
      'AI-translated from the saved English explanation. Check the original report for exact results.';

  @override
  String get sourceChanged =>
      'The report changed. Reload it to see the latest explanation.';

  @override
  String get signupTitle => 'A clearer view\nstarts here.';

  @override
  String get signupIntro =>
      'Create an account to keep your reports and results together.';

  @override
  String get loginIntro =>
      'Sign in to access and understand your health reports.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get referralCode => 'Referral code (optional)';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyAccount => 'Already have an account? ';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signIn => 'Sign in';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get needHelp => 'Need help?';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get invalidCredentialsInput =>
      'Enter a valid email address and password';

  @override
  String get signupFailed => 'Unable to create account';

  @override
  String get loginFailed =>
      'Unable to sign in. Please check your connection and try again.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get changePhoto => 'Change profile photo';

  @override
  String get gallery => 'Choose from gallery';

  @override
  String get camera => 'Take a photo';

  @override
  String get photoUpdated => 'Profile photo updated';

  @override
  String get photoFailed => 'Could not update your photo. Please try again.';

  @override
  String get yourAccount => 'Your account';

  @override
  String get profileLoading => 'Loading profile…';

  @override
  String get profileLoadAction => 'Tap to load your profile';

  @override
  String get accountData => 'ACCOUNT & DATA';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get privacySecurity => 'Privacy & security';

  @override
  String get sharedLinks => 'Shared links';

  @override
  String get exportData => 'Export your data';

  @override
  String get additionalAccount => 'Additional account information';

  @override
  String get additionalAccountHelp =>
      'Family, plan, referrals, sessions and appearance';

  @override
  String get familyProfiles => 'Family profiles';

  @override
  String get manageProfiles => 'Switch or manage profiles';

  @override
  String get planCredits => 'Plan & credits';

  @override
  String get viewPlanBalance => 'View your plan and balance';

  @override
  String get balanceLoading => 'Loading balance…';

  @override
  String get referFriends => 'Refer friends';

  @override
  String get referralRewards => 'Invites and referral rewards';

  @override
  String get activeSessions => 'Active sessions';

  @override
  String get appearance => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get helpSupport => 'Help & support';

  @override
  String get aboutDoclyzer => 'About Doclyzer';

  @override
  String get aboutCopy =>
      'Keep reports organized by person and review extracted results against the original.';

  @override
  String get logOut => 'Log out';

  @override
  String get profile => 'Profile';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get accountRestricted => 'Account Restricted';

  @override
  String get photoUploading => 'Uploading photo…';

  @override
  String get changePhotoShort => 'Change photo';

  @override
  String get accountDetails => 'Account details';

  @override
  String get emailHelp =>
      'Used for account access. Contact support to change it.';

  @override
  String get accountName => 'Account name';

  @override
  String get belowLabRange => 'Below this lab\'s reference range';

  @override
  String get withinLabRange => 'Within this lab\'s reference range';

  @override
  String get aboveLabRange => 'Above this lab\'s reference range';

  @override
  String get cannotCompare => 'Cannot compare with the lab range';

  @override
  String get understandResult => 'Understand this result';

  @override
  String get yourResult => 'YOUR RESULT';

  @override
  String get labReferenceRange => 'Lab reference range';

  @override
  String get resultUnavailable => 'Not available in this result';

  @override
  String get sampleDate => 'Sample date';

  @override
  String get resultHistory => 'Result history';

  @override
  String get originalReport => 'Original report';

  @override
  String get reviewValue => 'Review value';

  @override
  String get understandYourResult => 'Understand your result';

  @override
  String get educationalContext =>
      'Educational context to help you discuss this result.';

  @override
  String get explanationUnavailable => 'Explanation unavailable';

  @override
  String get explanationFailed => 'We could not load an explanation right now.';

  @override
  String get checkOriginal => 'Check original report';

  @override
  String get tryAgain => 'Try again';

  @override
  String get aiGuidance => 'AI-GENERATED GUIDANCE';

  @override
  String get understandingResult => 'Understanding this result';

  @override
  String get possibleMeaning => 'What it could mean';

  @override
  String get whatTestMeasures => 'What this test measures';

  @override
  String get suggestedNextStep => 'Suggested next step';

  @override
  String get resultLimitations => 'What this result cannot tell you';

  @override
  String get oneResultLimit =>
      'One result alone cannot diagnose a condition or explain symptoms.';

  @override
  String get detailsToCheck => 'Details to check';

  @override
  String get lifestyleFactors => 'Lifestyle factors to discuss';

  @override
  String get insightContext =>
      'This value was extracted from your report. Check the original if the name, value, unit or range looks wrong. AI explanations are educational and cannot tell you which treatment you need.';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get moveReport => 'Move report';

  @override
  String get gotIt => 'Got it';

  @override
  String get reportDetails => 'Report details';

  @override
  String get shareReport => 'Share report';

  @override
  String get moreReportActions => 'More report actions';

  @override
  String get attemptHistory => 'Attempt history';

  @override
  String get compareReports => 'Compare reports';

  @override
  String get readParsedReport => 'Read parsed report';

  @override
  String get moveRecycle => 'Move to recycle bin';

  @override
  String get retry => 'Retry';

  @override
  String get reportSummary => 'Report summary';

  @override
  String get updateSummary => 'Update summary';

  @override
  String get summaryLoading => 'Putting your results into plain language…';

  @override
  String get checkSummary => 'Check summary';

  @override
  String get summaryFailed =>
      'We could not create the summary. You can try again.';

  @override
  String get summaryPlaceholder =>
      'A plain language explanation of the key results will appear here.';

  @override
  String get retrySummary => 'Try summary again';

  @override
  String get generateSummary => 'Generate summary';

  @override
  String get loadingResults => 'Loading report results…';

  @override
  String get somethingWrong => 'Something went wrong';

  @override
  String get viewTrends => 'View trends';

  @override
  String get originalFile => 'Original file';

  @override
  String get testValues => 'Test values';

  @override
  String get summary => 'Summary';

  @override
  String get checkStatus => 'Check status';

  @override
  String get viewOriginal => 'View original';

  @override
  String get verifiedResults => 'Verified results';

  @override
  String get resultTapHelp =>
      'Tap a result to understand what the test measures.';

  @override
  String get reviewResults => 'Review detected results';

  @override
  String get keepFile => 'Keep file anyway';

  @override
  String get patientDetails => 'Patient details';

  @override
  String get name => 'Name';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get bookingId => 'Booking ID';

  @override
  String get sampleCollection => 'Sample Collection';

  @override
  String get labDetails => 'Lab details';

  @override
  String get labName => 'Lab Name';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get location => 'Location';

  @override
  String get belowRange => 'Below range';

  @override
  String get aboveRange => 'Above range';

  @override
  String get withinRange => 'In listed range';

  @override
  String get rangeUnclear => 'Range unclear';

  @override
  String get understandResultAction => 'Understand this result  →';

  @override
  String get parsedReport => 'Parsed Report';

  @override
  String get reports => 'Reports';

  @override
  String get trends => 'Trends';

  @override
  String get openingPage => 'Opening page';

  @override
  String get home => 'Home';

  @override
  String get family => 'Family';

  @override
  String get switchProfile => 'Switch profile';

  @override
  String get currentProfile => 'Current profile';

  @override
  String get viewProfile => 'View this profile';

  @override
  String get manageFamily => 'Manage family';

  @override
  String get chooseProfile => 'Choose a profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get homeTitle => 'A little clarity.\nAll in one place.';

  @override
  String get nextReportTitle => 'Your next report,\nready when you are.';

  @override
  String get homeSubtitle => 'PDFs, photos and family records.';

  @override
  String get uploadReport => 'Upload report';

  @override
  String get recentReport => 'Recent report';

  @override
  String get viewAll => 'View all';

  @override
  String get reportsUnavailable =>
      'Reports are unavailable. Try again when connected.';

  @override
  String get emptyHomeTitle => 'Your story starts here';

  @override
  String get emptyHomeHelp =>
      'Upload your first report to begin a clear history of your records.';

  @override
  String get uploadFirstReport => 'Upload your first report';

  @override
  String get latestResults => 'Latest results';

  @override
  String get allTrends => 'All trends';

  @override
  String get reviewedResultsHelp =>
      'Reviewed results will appear here when available.';

  @override
  String get searchTests => 'Search tests';

  @override
  String get noHealthData =>
      'No health data yet. Upload a report to see your health history.';

  @override
  String get noTestsFound => 'No tests found';

  @override
  String get shorterTestName => 'Try a shorter test name.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get unitUnavailable => 'Unit unavailable';

  @override
  String get uploadingReport => 'Uploading report…';

  @override
  String get organizingReport => 'Organizing your report…';

  @override
  String get uploadAReport => 'Upload a report';

  @override
  String get uploadHelp =>
      'Choose a PDF or a clear photo. You can check details before saving.';

  @override
  String get chooseSource => 'CHOOSE A SOURCE';

  @override
  String get uploadPdfImage => 'Upload PDF or image';

  @override
  String get chooseReportFiles => 'Choose a report from your files';

  @override
  String get selectReportPages => 'Select one or more report pages';

  @override
  String get capturePage => 'Capture a complete page';

  @override
  String get supportedFormats => 'Supported formats: PDF, JPG, PNG';

  @override
  String get confirmFile => 'Make sure this is the file you want to add.';

  @override
  String get addReport => 'Add report';

  @override
  String get chooseDifferentFile => 'Choose a different file';

  @override
  String get uploadWait => 'This may take a moment. Please keep the app open.';

  @override
  String get reportNeedsAttention => 'Report needs attention';

  @override
  String get verifyBeforeSaving =>
      'Check detected results against the original report before saving them.';

  @override
  String get viewVerifiedResults => 'View verified results';

  @override
  String get viewOriginalReport => 'View original report';

  @override
  String get viewReportStatus => 'View report status';

  @override
  String get viewResults => 'View results';

  @override
  String get viewOriginalFile => 'View original file';

  @override
  String get retryExtraction => 'Retry extraction';

  @override
  String get done => 'Done';

  @override
  String get duplicateReport => 'This report looks like a duplicate';

  @override
  String get duplicateHelp => 'This file may already be in your reports.';

  @override
  String get keepExisting => 'Keep existing';

  @override
  String get processAgain => 'Process PDF again';

  @override
  String get uploadNewCopy => 'Upload as new copy';

  @override
  String get reportLimitReached => 'Report limit reached';

  @override
  String get reportLimitHelp => 'You have reached your report limit.';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get back => 'Back';

  @override
  String get uploadFailedTitle => 'Could not upload report';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get retrySameFile => 'Retry same file';

  @override
  String get chooseAnotherFile => 'Choose another file';

  @override
  String get aiDisclaimer =>
      'Doclyzer helps you organize and better understand your health reports. The information provided is for educational purposes only and is not medical advice, diagnosis, or treatment. Always consult a qualified healthcare professional for medical guidance.';

  @override
  String collectedOn(String date) {
    return 'Collected $date';
  }

  @override
  String uploadedOn(String date) {
    return 'Uploaded $date';
  }

  @override
  String labRangeValue(String range) {
    return 'Lab range $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits credits';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
      zero: 'No reports',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'The report is taking longer than expected to load. Check your connection and try again.';

  @override
  String get summaryUpdateFailed =>
      'We could not update the summary right now. The saved summary is still available.';

  @override
  String get summaryCreateFailed =>
      'We could not create the summary right now. Your results are still available below.';

  @override
  String get reassignFailed => 'Could not reassign report. Try again.';

  @override
  String get confirmRecycle => 'Move to recycle bin?';

  @override
  String get recycleHelp =>
      'You can restore this report from Reports > Recycle Bin for 30 days. After that, it will be permanently deleted.';

  @override
  String get reportRecycled => 'Report moved to recycle bin';

  @override
  String get reportDeleteFailed => 'Could not delete report. Try again.';

  @override
  String get addProfileBeforeMove =>
      'Add another family profile before moving this report.';

  @override
  String get moveReportHelp =>
      'Choose another family member if this report was added to the wrong profile.';

  @override
  String get confirmMoveReport => 'Move this report?';

  @override
  String get aboutSampleDates => 'About sample dates';

  @override
  String get multipleDatesHelp =>
      'This report has results from more than one sample date. Open a result to check its date against the original report.';

  @override
  String get missingDateHelp =>
      'The sample date is when the sample was taken. We could not find a reliable date in this report. It is different from the upload date. Open a result to check or correct its date.';

  @override
  String get uploading => 'Uploading';

  @override
  String get waitingToProcess => 'Waiting to process';

  @override
  String get readingReport => 'Reading report';

  @override
  String get readyToReview => 'Ready to review';

  @override
  String get someResultsNeedReview => 'Some results need review';

  @override
  String get couldNotReadReport => 'Could not read report';

  @override
  String get processingStopped => 'Processing stopped';

  @override
  String get couldNotProcessReport => 'Could not process report';

  @override
  String get reportRefreshFailed =>
      'Could not refresh this report. Showing the last loaded result.';

  @override
  String get multipleSampleDates => 'Multiple sample dates ';

  @override
  String get missingSampleDate => 'Sample date not found ';

  @override
  String get reportAnalyzing =>
      'We are analyzing this report. You can leave this screen; results will appear when ready.';

  @override
  String get extractionIncompleteTitle =>
      'We could not extract all results reliably';

  @override
  String get extractionIncompleteHelp =>
      'Automatic extraction was incomplete. Check detected rows against the original report before saving them.';

  @override
  String get verifiedRowsHelp =>
      'These rows were checked against the original. Other rows may still need review.';

  @override
  String get noTestValues =>
      'No test values were found in this report. Open the original file to check its contents.';

  @override
  String get processingRetryHelp =>
      'Processing stopped before it finished. Your file is saved. Tap Retry to try again.';

  @override
  String get resultsNeedCheck =>
      'Some results need a check against the original report. You can review the detected rows below.';

  @override
  String get readerModeHelp =>
      'Parsed report is available in Reader mode for easier access and better readability.';

  @override
  String get aiRangeHelp =>
      'Range interpreted by AI during processing. Check the original report.';

  @override
  String get checkResultHelp =>
      'Check this result against the original report before relying on it.';

  @override
  String get preferredRangeHelp =>
      'Compared with the preferred category printed by the lab; confirm it applies to you.';

  @override
  String get categoryComparisonHelp =>
      'This comparison uses the preferred category printed by the lab. Check that the category applies to you.';

  @override
  String get missingSavedResult =>
      'This value could not be matched to a saved result. Check the original report or refresh this report.';

  @override
  String get unreviewedTest =>
      'This test has not been reviewed for AI explanations yet. Check the original report and discuss the result with your clinician.';

  @override
  String get unsafeResult =>
      'The extracted result is unclear, so it cannot be safely explained. Check the original report.';

  @override
  String get filterReports => 'Filter reports';

  @override
  String get sortReports => 'Sort reports';

  @override
  String get recycleBin => 'Recycle bin';

  @override
  String get healthHistory => 'Health History';

  @override
  String get shareProfile => 'Share Profile';

  @override
  String get reportsUnavailableTitle => 'Reports unavailable';

  @override
  String get reportsLoadFailed =>
      'Unable to load reports. Try again when connected.';

  @override
  String get upload => 'Upload';

  @override
  String get reportsFor => 'REPORTS FOR';

  @override
  String get searchReports => 'Search reports or labs';

  @override
  String get filters => 'Filters';

  @override
  String get noReportsYet => 'No reports yet';

  @override
  String get noMatchingReports => 'No reports match your search.';

  @override
  String get differentSearch => 'Try a different test, laboratory or filter.';

  @override
  String get clearFilters => 'Clear search and filters';

  @override
  String get original => 'Original';

  @override
  String get switchActiveProfile => 'Switch active profile';

  @override
  String get switchProfileHelp =>
      'View another person’s reports. Your active profile for uploads and trends will change too.';

  @override
  String get multipleCollectionDates => 'Multiple collection dates';

  @override
  String get unknownCollectionDate => 'Unknown collection date';

  @override
  String get profileLoadFailed => 'Failed to load profiles. Please try again.';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get deleteProfileConfirm => 'Delete profile?';

  @override
  String get deleteProfileHelp =>
      'This profile will be removed. Any data linked to it will be affected.';

  @override
  String get profileDeleteFailed =>
      'Failed to delete profile. Please try again.';

  @override
  String get addFamilyMember => 'Add family member';

  @override
  String get familyUnavailable => 'Family profiles unavailable';

  @override
  String get familyIntro => 'Reports and trends, organized by person';

  @override
  String get noProfilesYet => 'No profiles yet';

  @override
  String get noProfilesHelp =>
      'Add a profile to organize reports for yourself or family members.';

  @override
  String get yourFamily => 'Your family';

  @override
  String get upgradeProfiles => 'Upgrade to add more profiles';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String get active => 'Active';

  @override
  String get setActive => 'Set active';

  @override
  String get viewReports => 'View reports';

  @override
  String get notNow => 'Not now';

  @override
  String get openSettings => 'Open settings';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get enableNotificationsConfirm => 'Enable notifications?';

  @override
  String get notificationsEnabled => 'Report notifications enabled';

  @override
  String get notificationsStayOff =>
      'Notifications remain off. You can enable them later in device settings.';

  @override
  String get notificationsFailed =>
      'Could not enable notifications. Check your connection and try again.';

  @override
  String get switchProfileFailed =>
      'Unable to switch profiles. Please try again.';

  @override
  String get sourceReportFailed => 'Unable to open source report.';

  @override
  String get partialRefreshFailed =>
      'Some information could not be refreshed. Pull down to try again.';

  @override
  String get knowReportReady => 'Know when your report is ready';

  @override
  String get oneResult => 'One result';

  @override
  String get sameDayResults => 'Same-day results';

  @override
  String get verificationRequired => 'Verification Required';

  @override
  String get accountCreatedLogin =>
      'Your account was created successfully. Continue to login.';

  @override
  String get continueLogin => 'Continue to login';

  @override
  String get allReports => 'All reports';

  @override
  String get filterReviewed => 'Reviewed';

  @override
  String get filterNeedsReview => 'Needs review';

  @override
  String get filterProcessing => 'Processing';

  @override
  String get filterOriginalOnly => 'Original only';

  @override
  String get reportDateNewest => 'Report date · newest';

  @override
  String get reportDateOldest => 'Report date · oldest';

  @override
  String get uploadDateNewest => 'Upload date · newest';

  @override
  String get uploadDateOldest => 'Upload date · oldest';

  @override
  String get switchAction => 'Switch';

  @override
  String get collectionDate => 'Collection date';

  @override
  String get copy => 'Copy';

  @override
  String get history => 'History';

  @override
  String get loadingReport => 'Loading report…';

  @override
  String get restore => 'Restore';

  @override
  String get revoke => 'Revoke';

  @override
  String get testName => 'Test name';

  @override
  String get viewReport => 'View report';

  @override
  String get closeAccount => 'Close account';

  @override
  String get createShareLink => 'Create link';
}
