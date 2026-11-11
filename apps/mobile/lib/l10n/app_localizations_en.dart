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

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'Appearance changed, but could not be saved for next time.';

  @override
  String get uiThisReportIsNoLongerAvailable =>
      'This report is no longer available.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'Open device Settings to manage notification previews.';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'Keep this screen open until the upload is accepted.';

  @override
  String get uiAnUploadMayHaveBeenInterrupted =>
      'An upload may have been interrupted';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'Check Reports. If it is missing, add the same file again.';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'Could not dismiss notifications. Try again.';

  @override
  String get uiConnectionUnavailable => 'Connection unavailable';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'Your session could not be checked. Connect to the internet and try again.';

  @override
  String get uiSignInWithAnotherAccount => 'Sign in with another account';

  @override
  String get uiNoActiveProfile => 'No active profile';

  @override
  String get uiDismissUploadNotice => 'Dismiss upload notice';

  @override
  String get uiDismissReadyNotifications => 'Dismiss ready notifications';

  @override
  String get uiRequestSupport => 'Request support';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'We will include diagnostic IDs so the team can investigate.';

  @override
  String get uiSendRequest => 'Send request';

  @override
  String get uiWhatHappenedOptional => 'What happened? (optional)';

  @override
  String get uiReviewResult => 'Review result';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'Compare these fields with the original report before saving.';

  @override
  String get uiOriginallyExtracted => 'Originally extracted';

  @override
  String get uiReloadReport => 'Reload report';

  @override
  String get uiResultAsPrinted => 'Result as printed';

  @override
  String get uiUnitIfShown => 'Unit (if shown)';

  @override
  String get uiLabReferenceRangeIfShown => 'Lab reference range (if shown)';

  @override
  String get uiCheckYourReport => 'Check your report';

  @override
  String get uiNoAttemptHistoryAvailable => 'No attempt history available.';

  @override
  String get uiIInspectedTheOriginal => 'I inspected the original';

  @override
  String get uiChooseTwoReports => 'Choose two reports';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'Use records for the same person. Matching tests will appear side by side.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'Choose the older report first and the newer report second.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'Compared only when compatible. Different units or methods are shown separately until compatibility is confirmed.';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'A change is not a diagnosis. Compare each result with its own report interval and discuss the context with your clinician.';

  @override
  String get uiChooseDifferentReports => 'Choose different reports';

  @override
  String get uiEarlierReport => 'Earlier report';

  @override
  String get uiLaterReport => 'Later report';

  @override
  String get uiYourReportPages => 'Your report pages';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'Keep pages in the same order as the report.';

  @override
  String get uiAddAnotherPage => 'Add another page';

  @override
  String get uiChoosePagesFromGallery => 'Choose pages from gallery';

  @override
  String get uiAdjustPage => 'Adjust page';

  @override
  String get uiRetake => 'Retake';

  @override
  String get uiUseAdjustedPage => 'Use adjusted page';

  @override
  String get uiResetChanges => 'Reset changes';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'Keep every result inside the corners.';

  @override
  String get uiRotate => 'Rotate';

  @override
  String get uiReportRestored => 'Report restored';

  @override
  String get uiDeleteReportPermanently => 'Delete report permanently?';

  @override
  String get uiDeletePermanently => 'Delete permanently';

  @override
  String get uiReportPermanentlyDeleted => 'Report permanently deleted';

  @override
  String get uiEmptyRecycleBin => 'Empty Recycle Bin?';

  @override
  String get uiDeleteAll => 'Delete all';

  @override
  String get uiRecycleBinIsEmpty => 'Recycle bin is empty.';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'Deleted reports will appear here before removal.';

  @override
  String get uiEmptyRecycleBind657e2 => 'Empty recycle bin';

  @override
  String get uiCheckDetectedResult => 'Check detected result';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'Compare this row with the original report. Correct any OCR mistakes before saving.';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'I checked this result against the original report';

  @override
  String get uiSaving => 'Saving…';

  @override
  String get uiSaveVerifiedResult => 'Save verified result';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'No results were detected. View the original report or retry processing.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'Detected values need to be checked against the original report before they become saved results.';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'Some rows may be missing. Inspect the entire original report.';

  @override
  String get uiResult => 'Result';

  @override
  String get uiUnitOptional => 'Unit (optional)';

  @override
  String get uiReferenceRangeOptional => 'Reference range (optional)';

  @override
  String get uiVerified => 'Verified';

  @override
  String get uiGiftVoucher => 'Gift Voucher';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'Redeem a gift voucher and add credits directly to your balance.';

  @override
  String get uiCurrentPlan => 'Current Plan';

  @override
  String get uiCreditBalance => 'Credit Balance';

  @override
  String get uiPlanLimits => 'Plan Limits';

  @override
  String get uiBuyCredits => 'Buy Credits';

  @override
  String get uiRecentBillingActivity => 'Recent Billing Activity';

  @override
  String get uiRefreshStatus => 'Refresh status';

  @override
  String get uiNoRecentOrdersYet => 'No recent orders yet.';

  @override
  String get uiVoucherCode => 'Voucher code';

  @override
  String get uiCheckout => 'Checkout';

  @override
  String get uiApply => 'Apply';

  @override
  String get uiClear => 'Clear';

  @override
  String get uiPay => 'Pay';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'No credit packs available at this time.';

  @override
  String get uiBuy => 'Buy';

  @override
  String get uiRetryPayment => 'Retry payment';

  @override
  String get uiPromoCode => 'Promo code';

  @override
  String get uiEnterPromoCode => 'Enter promo code';

  @override
  String get uiChooseAPlan => 'Choose a Plan';

  @override
  String get uiNoPlansAvailableAtThisTime => 'No plans available at this time.';

  @override
  String get uiHaveAPromoCode => 'Have a promo code?';

  @override
  String get uiCURRENTPLAN => 'CURRENT PLAN';

  @override
  String get uiManageNotifications => 'Manage notifications';

  @override
  String get uiAll => 'All';

  @override
  String get uiUnread => 'Unread';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'Access stops immediately. You can sign in and restore within 30 days. After that, your account and stored files are deleted from active storage.';

  @override
  String get uiCloseMyAccount => 'Close My Account';

  @override
  String get uiYourRecordsStayInDoclyzer => 'Your records stay in Doclyzer.';

  @override
  String get uiTakeACopyOfYourRecords => 'Take a copy of your records.';

  @override
  String get uiWhoseRecords => 'Whose records?';

  @override
  String get uiCouldNotLoadProfiles => 'Could not load profiles';

  @override
  String get uiLoadingProfiles => 'Loading profiles…';

  @override
  String get uiAllProfiles => 'All profiles';

  @override
  String get uiDateRange => 'Date range';

  @override
  String get uiUseAllDates => 'Use all dates';

  @override
  String get uiINCLUDEINTHISEXPORT => 'INCLUDE IN THIS EXPORT';

  @override
  String get uiOriginalReports => 'Original reports';

  @override
  String get uiPDFsAndImagesYouUploaded => 'PDFs and images you uploaded';

  @override
  String get uiTestResults => 'Test results';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'Results as CSV, with their review state';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'Exports contain personal information. Store them somewhere you trust.';

  @override
  String get uiDeleteAccount => 'Delete account';

  @override
  String get uiContinueToDeletion => 'Continue to deletion';

  @override
  String get uiKeepMyAccount => 'Keep my account';

  @override
  String get uiBeforeYouLeave => 'Before you leave';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'Please read what this will remove.';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'Deleting your account affects all profiles you manage.';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'Your account and personal profile';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'Access through your shared links';

  @override
  String get uiKeepACopyFirst => 'Keep a copy first';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'Export the information you want to retain.';

  @override
  String get uiExportData => 'Export data';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'Access stops immediately. You can restore within 30 days. After that, your data is removed from active storage.';

  @override
  String get uiAccountPendingDeletion => 'Account pending deletion';

  @override
  String get uiRestoreMyAccount => 'Restore my account';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'Download a copy of your account data including your profile, profiles, and consent records.';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'Your account is disabled immediately. You can restore it within 30 days. After that, your data is permanently deleted.';

  @override
  String get uiCurrentPassword => 'Current password';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'Could not change App lock. Try again.';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'Your records.\nYour choice to share.';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'Review access whenever you need.';

  @override
  String get uiAppLock => 'App lock';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'Use your device’s biometric or passcode lock.';

  @override
  String get uiNotificationPreviews => 'Notification previews';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'Control lock-screen previews in your device settings.';

  @override
  String get uiContactSupport => 'Contact support';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'Attach reports only if you choose to.';

  @override
  String get uiWhatCanWeHelpYouWith => 'What can we help you with?';

  @override
  String get uiPOPULARQUESTIONS => 'POPULAR QUESTIONS';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'No help articles match your search.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'For questions about your health or test results, speak with a qualified healthcare professional.';

  @override
  String get uiYourReportsAClearerPicture => 'Your reports. A clearer picture.';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'Keep your health history together.';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'Store reports, review results, follow changes and share with your clinician.';

  @override
  String get uiEducationalInformationOnly => 'Educational information only';

  @override
  String get uiSearchHelpArticles => 'Search help articles';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'Open the device Settings app to change notification access.';

  @override
  String get uiSavePreferences => 'Save preferences';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'Device permissions can be changed in Settings.';

  @override
  String get uiGetReportUpdatesOnThisDevice =>
      'Get report updates on this device';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'Allow notifications to know when a report is ready. Marketing is a separate choice below.';

  @override
  String get uiREPORTACTIVITY => 'REPORT ACTIVITY';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'Report activity settings require the latest server version.';

  @override
  String get uiSensitiveLockScreenPreviews => 'Sensitive lock-screen previews';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'Report names and personal details are always hidden.';

  @override
  String get uiOTHERMESSAGES => 'OTHER MESSAGES';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'Keep each person’s reports and trends together.';

  @override
  String get uiPersonDetails => 'Person details';

  @override
  String get uiDateOfBirth => 'Date of birth';

  @override
  String get uiRelationship => 'Relationship';

  @override
  String get uiEnterAName => 'Enter a name';

  @override
  String get uiClearDateOfBirth => 'Clear date of birth';

  @override
  String get uiOptionalEGParentOrChild => 'Optional, e.g. parent or child';

  @override
  String get uiInviteFriendsEarnCredits => 'Invite friends, earn credits';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'Share your code and follow each invite as rewards unlock.';

  @override
  String get uiYOURREFERRALCODE => 'YOUR REFERRAL CODE';

  @override
  String get uiShareInvite => 'Share invite';

  @override
  String get uiCopyCode => 'Copy code';

  @override
  String get uiHaveACode => 'Have a code?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'Enter a code shared with you to claim your invite reward.';

  @override
  String get uiHowRewardsWork => 'How rewards work';

  @override
  String get uiNoFriendsReferredYet => 'No friends referred yet';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'Share your invite to see their progress here.';

  @override
  String get uiReferralCode => 'Referral code';

  @override
  String get uiSetNewPassword => 'Set New Password';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'Enter the reset token from the link in your email and your new password.';

  @override
  String get uiResetPassword => 'Reset Password';

  @override
  String get uiBackToLogin => 'Back to login';

  @override
  String get uiResetToken => 'Reset Token';

  @override
  String get uiNewPassword => 'New Password';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'Enter the email address associated with your account and we\'ll send you a link to reset your password.';

  @override
  String get uiSendResetLink => 'Send Reset Link';

  @override
  String get uiRevokeSession => 'Revoke session?';

  @override
  String get uiCurrentSession => 'Current session';

  @override
  String get uiSkip => 'Skip';

  @override
  String get uiChangePassword => 'Change password';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'Enter your current password and choose a new one.';

  @override
  String get uiNewPasswordd850ee => 'New password';

  @override
  String get uiConfirmNewPassword => 'Confirm new password';

  @override
  String get uiGettingThingsReady => 'Getting things ready…';

  @override
  String get uiLinkAccessHistory => 'Link Access History';

  @override
  String get uiNoAccessEventsYet => 'No access events yet.';

  @override
  String get uiDefaultShareLinkExpiry => 'Default Share Link Expiry';

  @override
  String get uiSave => 'Save';

  @override
  String get uiReviewSharing => 'Review sharing';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'Check the person, reports and access.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'Edit selection or access settings';

  @override
  String get uiRevokeShareLink => 'Revoke share link?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'This link will stop working. You can create a new one.';

  @override
  String get uiShareLinkReady => 'Share link ready';

  @override
  String get uiAccessCodeShareSeparately => 'Access code — share separately';

  @override
  String get uiCopyAccessCode => 'Copy access code';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'This code could not be saved on this device. Copy it now for later use.';

  @override
  String get uiShareLink => 'Share link';

  @override
  String get uiCopyLink => 'Copy link';

  @override
  String get uiRevokeLink => 'Revoke link';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'Code unavailable on this device. Use the saved code or create a new link.';

  @override
  String get uiActiveSharedLinks => 'Active shared links';

  @override
  String get uiShare => 'Share';

  @override
  String get uiCreateANewShareLink => 'Create a new share link';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'Include current and future reports for this profile.';

  @override
  String get uiChooseReports => 'Choose reports';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'Share only the reports selected below.';

  @override
  String get uiSelectAll => 'Select all';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'No reviewed reports are available to share.';

  @override
  String get uiSelectedTestResults => 'Selected test results';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'Include only the results you choose from these reports.';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'No saved test results are available in these reports.';

  @override
  String get uiUpgradeOrManage => 'Upgrade or Manage';

  @override
  String get uiExpiry => 'Expiry:';

  @override
  String get uiRequireAnAccessCode => 'Require an access code';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'Share the code separately from the link.';

  @override
  String get uiTryAgain => 'Try Again';

  @override
  String get uiClearExpiry => 'Clear expiry';

  @override
  String get onboardingStoreEyebrow => '01 / STORE';

  @override
  String get onboardingStoreTitle => 'Every report,\none familiar place.';

  @override
  String get onboardingStoreBody =>
      'Keep PDFs and photos together, for you and the people you care for.';

  @override
  String get onboardingUnderstandEyebrow => '02 / UNDERSTAND';

  @override
  String get onboardingUnderstandTitle => 'The numbers,\nmade easier to read.';

  @override
  String get onboardingUnderstandBody =>
      'See each test, its unit and the interval from your report. Check the original anytime.';

  @override
  String get onboardingTrackEyebrow => '03 / TRACK & SHARE';

  @override
  String get onboardingTrackTitle => 'See the changes.\nShare the context.';

  @override
  String get onboardingTrackBody =>
      'Follow results over time and choose exactly what your clinician can see.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get uiSupportRequestSent => 'Support request sent.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'Test name and result are required.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'Use a valid collection date in YYYY-MM-DD format.';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'Could not save this correction. Try again.';

  @override
  String get uiReportsUnavailable => 'Reports unavailable';

  @override
  String get uiTryAgain042c86 => 'Try again';

  @override
  String get uiTwoReportsAreNeeded => 'Two reports are needed';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'Add an older report for this profile to compare results.';

  @override
  String get uiCannotCompareYet => 'Cannot compare yet';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'These reports have no matching results available for comparison.';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'Unable to load reports. Try again.';

  @override
  String get uiCouldNotOpenPhotosOrCamera => 'Could not open photos or camera.';

  @override
  String get uiCouldNotOpenCamera => 'Could not open camera.';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'Could not prepare these pages. Retake an unreadable page and try again.';

  @override
  String get uiCouldNotAdjustThisPage => 'Could not adjust this page.';

  @override
  String get uiNoChartableResultYet => 'No chartable result yet';

  @override
  String get uiProfiles => 'Profiles';

  @override
  String get uiReports => 'Reports';

  @override
  String get uiShareLinks => 'Share links';

  @override
  String get uiAIChat => 'AI Chat';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'Failed to load entitlement summary. Please try again.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'Failed to refresh billing status. Please try again.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'Receipt download will be available soon.';

  @override
  String get uiSubtotal => 'Subtotal';

  @override
  String get uiDiscount => 'Discount';

  @override
  String get uiTotal => 'Total';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'Failed to load credit packs. Please try again.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'A payment is pending capture. Refresh status before starting another checkout.';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'Credits were applied successfully.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'Failed to create order. Please try again.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'Payment received. Awaiting server reconciliation before credits are added.';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'Payment failed. You can retry checkout when ready.';

  @override
  String get uiPaymentFailedTryAgain => 'Payment failed. Try again.';

  @override
  String get uiCreditsAdded => 'Credits added!';

  @override
  String get uiPromoCodeApplied => 'Promo code applied.';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'Payment received, but this order is pending review.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'Payment failed during reconciliation.';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'Payment confirmed. Server reconciliation is still pending.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'Payment verified. Reconciliation is pending, please refresh shortly.';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'Payment received but verification is still pending. Please refresh status.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'Failed to load plans. Please try again.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'Failed to create subscription. Please try again.';

  @override
  String get uiSubscriptionFailedTryAgain => 'Subscription failed. Try again.';

  @override
  String get uiPlanUpgraded => 'Plan upgraded!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'Payment received but verification failed. Plan will be upgraded shortly.';

  @override
  String get uiNotificationsUnavailable => 'Notifications unavailable';

  @override
  String get uiAllQuietForNow => 'All quiet for now.';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'Report updates and sharing reminders will appear here when there’s something new.';

  @override
  String get uiNoUnreadUpdates => 'No unread updates';

  @override
  String get uiYouReAllCaughtUp => 'You’re all caught up.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'Unable to load notifications. Try again when connected.';

  @override
  String get uiManageSharedLinks => 'Manage shared links';

  @override
  String get uiExportYourData => 'Export your data';

  @override
  String get uiReadThePrivacyPolicy => 'Read the Privacy Policy';

  @override
  String get uiTermsOfUse => 'Terms of Use';

  @override
  String get uiPrivacyPolicy => 'Privacy Policy';

  @override
  String get uiDateOfBirthOptional => 'Date of birth, optional';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'Relationship must be 50 characters or fewer.';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'Failed to save profile. Please try again.';

  @override
  String get uiReferralsUnavailable => 'Referrals unavailable';

  @override
  String get uiYourRewards => 'Your rewards';

  @override
  String get uiReferralProgress => 'Referral progress';

  @override
  String get uiFriendsReferred => 'Friends referred';

  @override
  String get uiCreditsEarned => 'Credits earned';

  @override
  String get uiPendingRewards => 'Pending rewards';

  @override
  String get uiBlockedRewards => 'Blocked rewards';

  @override
  String get uiInviteeBonus => 'Invitee bonus';

  @override
  String get uiFirstAnalysis => 'First analysis';

  @override
  String get uiFirstPurchase => 'First purchase';

  @override
  String get uiMonthlyCap => 'Monthly cap';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'Failed to load referrals. Please try again.';

  @override
  String get uiReferralCodeCopied => 'Referral code copied.';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'Enter the reset token from your email link';

  @override
  String get uiEnterYourNewPassword => 'Enter your new password';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'Unable to reset password. Please request a new link.';

  @override
  String get uiEnterYourEmailAddress => 'Enter your email address';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'Unable to send reset link. Please try again.';

  @override
  String get uiFailedToLoadSessions => 'Failed to load sessions.';

  @override
  String get uiFailedToRevokeSession => 'Failed to revoke session.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'Unable to change password. Please try again.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'Open device Settings and allow notifications for Doclyzer.';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'Reports could not be loaded. Try again.';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'Test results could not be loaded. Try again.';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'Select at least one report to share.';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'Select at least one test result to share.';

  @override
  String get uiLinkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get uiAccessCodeCopiedToClipboard => 'Access code copied to clipboard';

  @override
  String get uiOnePerson => '1 person';

  @override
  String uiPeopleCount(String count) {
    return '$count people';
  }

  @override
  String uiActionsFor(String name) {
    return 'Actions for $name';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'Unable to switch profiles. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return 'Switched to $name';
  }

  @override
  String get uiAnalyzeOnePage => 'Analyze 1 page';

  @override
  String uiAnalyzePages(String count) {
    return 'Analyze $count pages';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'Drag pages into the order shown in your report';

  @override
  String get uiCheckEveryPage => 'Check every page before analyzing';

  @override
  String get uiOnePageAdded => '1 page added';

  @override
  String uiPagesAdded(String count) {
    return '$count pages added';
  }

  @override
  String get uiReorder => 'Reorder';

  @override
  String uiPageNumber(String number) {
    return 'Page $number';
  }

  @override
  String uiRemovePage(String number) {
    return 'Remove page $number';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · Page $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'Crop edges: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count selected reports';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count selected test results';
  }

  @override
  String get uiAllCurrentFutureReports => 'All current and future reports';

  @override
  String get uiNoExpiry => 'No expiry';

  @override
  String uiExpiresDate(String date) {
    return 'Expires $date';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'Access code required. Share it separately from the link.';

  @override
  String get uiNoAccessCodeRequired => 'No access code required.';

  @override
  String uiExpiresColonDate(String date) {
    return 'Expires: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return 'Share $name’s reports';
  }

  @override
  String uiProfileReports(String name) {
    return '$name’s reports';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count selected results';
  }

  @override
  String get uiAccessCodeRequiredShort => 'Access code required';

  @override
  String uiPastLinksCount(String count) {
    return 'Past links · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return 'Expired $date';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'Revoked · Created $date';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return 'Using $current of $maximum active links.';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return 'Delete $filename and its stored file? This cannot be undone.';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'Unable to delete report: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'Permanently delete all $count reports and their stored files? This cannot be undone.';
  }

  @override
  String get uiRecycleBinEmptied => 'Recycle Bin emptied';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return 'Deleted $deleted reports. $failed could not be deleted; try again.';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'Unable to empty Recycle Bin: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'Profile: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'Collected: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'Uploaded: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'Deleted on: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'Permanent delete on: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'Days left: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer => 'Confirm App lock for Doclyzer';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'Confirm before turning off App lock';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'Unlock Doclyzer to view your health records';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'Create a default profile before uploading a report.';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'Create a default profile before viewing your timeline.';

  @override
  String get uiUnableToLoadProfilesRightNow =>
      'Unable to load profiles right now.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'Cannot upload right now because profile data could not be loaded. Please ensure API server is running and try again.';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'Cannot open timeline right now because profile data could not be loaded. Please ensure API server is running and try again.';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'Unable to load profiles right now. Please try again.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'Unable to load sharing links. Please try again.';

  @override
  String get uiPasswordChanged => 'Password changed';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'Unable to open that report. Try the report library.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'This action is temporarily unavailable while your account is under review.';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'Unable to open this section. Please try again.';

  @override
  String get uiAppLockIsUnavailable => 'App lock is unavailable';

  @override
  String get uiDoclyzerIsLocked => 'Doclyzer is locked';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'Could not read the saved App lock setting. Retry to continue.';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'Use your device passcode or biometrics to continue.';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'Uploads are temporarily unavailable while your account is under review.';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'Unable to start an upload. Please try again.';

  @override
  String get uiJustNow => 'Just now';

  @override
  String get uiAdditionalDetails => 'Additional details: ';

  @override
  String get uiSaveCorrection => 'Save correction';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'Could not open files. Check access and try again.';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'Could not open camera. Check permission and try again.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'Could not open photos. Check permission and try again.';

  @override
  String get uiCouldNotAccessSelectedFile => 'Could not access selected file.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'Could not access selected file';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'Connection lost. The upload may have reached the server. Retry the same file safely.';

  @override
  String get uiCouldNotLoadExistingReport => 'Could not load existing report';

  @override
  String get uiAddingTo => 'Adding to  ';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'Some results need review. Your original report is saved.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'We couldn\'t read this format. Your file is saved.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'Report parsed successfully. Results and trends are available.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'Your report is still being analyzed. Open it to check its status.';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'Processing stopped. Your file is saved. You can retry.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'No extracted test values were added. You can still open and share the document. Your trends are unchanged.';

  @override
  String get uiYourOriginalIsSaved => 'Your original is saved.';

  @override
  String get uiInitialUpload => 'Initial upload';

  @override
  String get uiParsedSuccessfully => 'Parsed successfully';

  @override
  String get uiParsingFailed => 'Parsing failed';

  @override
  String get uiExtractionIncomplete => 'Extraction incomplete';

  @override
  String get uiTransientFailure => 'Transient failure';

  @override
  String get uiTerminalFailure => 'Terminal failure';

  @override
  String get uiFailedToLoadAttemptHistory => 'Failed to load attempt history';

  @override
  String get uiThisReportSFileIsNoLonger =>
      'This report\'s file is no longer available.';

  @override
  String get uiCompareResults => 'Compare results';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'No difference calculated. Compatibility needs confirmation.';

  @override
  String get uiUnitNotRecorded => 'Unit not recorded';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'No numeric change between these reports.';

  @override
  String get uiUnableToRestore => 'Unable to restore: ';

  @override
  String get uiEnterAGiftVoucherCode => 'Enter a gift voucher code.';

  @override
  String get uiApplyVoucher => 'Apply Voucher';

  @override
  String get uiNotAvailable => 'Not available';

  @override
  String get uiViewReceipt => 'View receipt';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'Gift voucher is invalid or already redeemed.';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'Gift voucher has already been redeemed.';

  @override
  String get uiGiftVoucherHasBeenVoided => 'Gift voucher has been voided.';

  @override
  String get uiGiftVoucherHasExpired => 'Gift voucher has expired.';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'Unable to redeem this gift voucher.';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'Unable to redeem this gift voucher. Please try again.';

  @override
  String get uiEnterAPromoCodeToApply => 'Enter a promo code to apply.';

  @override
  String get uiPromoCodeNotFound => 'Promo code not found.';

  @override
  String get uiPromoCodeIsInactive => 'Promo code is inactive.';

  @override
  String get uiPromoCodeHasExpired => 'Promo code has expired.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'Promo code is not applicable to this pack.';

  @override
  String get uiPromoCodeUsageLimitReached => 'Promo code usage limit reached.';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'You have already used this promo code.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'Failed to apply promo code. Please try again.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'This order was flagged for review before credits could be added.';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'Payment failed during reconciliation. You can retry safely.';

  @override
  String get uiAwaitingCapture => 'Awaiting capture';

  @override
  String get uiLastPaymentFailed => 'Last payment failed';

  @override
  String get uiYouCanRetryCheckoutSafely => 'You can retry checkout safely.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'Promo codes not supported for subscriptions yet.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'Could not download the export. Try again.';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'Select original reports or test results.';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'Export requested. Tap \"Check Status\" to refresh.';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'Failed to request export. Please try again.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'Export ready. Download URL available.';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'Failed to check export status. Please try again.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'Failed to close account. Please try again.';

  @override
  String get uiPrepareExport => 'Prepare export';

  @override
  String get uiSaveExport => 'Save export';

  @override
  String get uiPrepareExportAgain => 'Prepare export again';

  @override
  String get uiAllDates => 'All dates';

  @override
  String get uiPreparingAccountDetails => 'Preparing account details';

  @override
  String get uiFamilyMemberProfiles => 'Family member profiles';

  @override
  String get uiUploadedReports => 'Uploaded reports';

  @override
  String get uiDownloadReady => 'Download ready';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'Report notifications enabled on this device';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'Device settings opened. Allow notifications for Doclyzer, then return here.';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'Notifications are still off. Allow them in device settings to receive report updates.';

  @override
  String get uiPreferencesSaved => 'Preferences saved';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'Your account choice was saved, but this device did not finish registering for marketing push. Marketing remains blocked on this device; check notification permission and try saving again.';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'Your account choice was saved. This device could not confirm its local preference yet, but marketing remains blocked at account level.';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'Your account choice was saved, but this device could not enable marketing push. Check notification permission and try again.';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'Saving took too long. Check your connection and try again.';

  @override
  String get uiReportReadyForReview => 'Report ready for review';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'Know when your results are ready to check.';

  @override
  String get uiUploadUpdates => 'Upload updates';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'Get a message if an upload needs attention.';

  @override
  String get uiSharedLinkReminders => 'Shared link reminders';

  @override
  String get uiHearWhenALinkIsAboutTo => 'Hear when a link is about to expire.';

  @override
  String get uiSecurityAlerts => 'Security alerts';

  @override
  String get uiRequiredForAccountSafety => 'Required for account safety.';

  @override
  String get uiComplianceNotices => 'Compliance notices';

  @override
  String get uiRequiredAccountInformation => 'Required account information.';

  @override
  String get uiMarketingPushNotifications => 'Marketing push notifications';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'Offers and announcements. Saving this choice also applies it to this device.';

  @override
  String get uiProductUpdates => 'Product updates';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'Optional news about Doclyzer.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'Cannot connect to server. Please check your internet or API server.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'Profile updates are temporarily unavailable while your account is under review.';

  @override
  String get uiUse100CharactersOrFewer => 'Use 100 characters or fewer';

  @override
  String get uiAddProfile => 'Add profile';

  @override
  String get uiCreateProfile => 'Create profile';

  @override
  String get uiUpdateTheirDetails => 'Update their details';

  @override
  String get uiWhoIsThisProfileFor => 'Who is this profile for?';

  @override
  String get uiNotSelected => 'Not selected';

  @override
  String get uiEnterAReferralCode => 'Enter a referral code.';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'Referral applied. Bonus unlocks after email verification.';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'Referral applied. Bonus credits are ready.';

  @override
  String get uiApplyCode => 'Apply code';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'You cannot apply your own referral code.';

  @override
  String get uiReferralCodeIsInvalid => 'Referral code is invalid.';

  @override
  String get uiFailedToApplyReferralCode => 'Failed to apply referral code.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'Failed to apply referral code. Please try again.';

  @override
  String get uiThisDevice => 'This device';

  @override
  String get uiSignedInDevice => 'Signed-in device';

  @override
  String get uiUnknownDevice => 'Unknown device';

  @override
  String get uiRevokeAndLogOut => 'Revoke and log out';

  @override
  String get uiRevokeSessionca8440 => 'Revoke session';

  @override
  String get uiEnterYourCurrentPassword => 'Enter your current password';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'Use at least 8 characters with uppercase, lowercase, a number, and a special character';

  @override
  String get uiChooseADifferentPassword => 'Choose a different password';

  @override
  String get uiNewPasswordsDoNotMatch => 'New passwords do not match';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'You have used all available upload credits. Visit Plan & Credits to add more.';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'Notifications are disabled for Doclyzer. Open device Settings to allow report-ready and account updates. Marketing stays off unless you choose it.';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'Get report-ready and account updates on this device. Marketing stays off unless you choose it.';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'Notifications are off for this device. Open Settings to receive report-ready and account updates.';

  @override
  String get uiBlockedExpiredRevoked => 'Blocked (expired/revoked)';

  @override
  String get uiFailedToLoadPolicy => 'Failed to load policy';

  @override
  String get uiUploadPaused => 'Upload paused';

  @override
  String get uiSevenDays => '7 days';

  @override
  String get uiThirtyDays => '30 days';

  @override
  String get uiNinetyDays => '90 days';

  @override
  String get uiUploadingAClearReport => 'Uploading a clear report';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'PDFs, photos and multiple pages';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'Choose a PDF or take clear photos of every page. Keep the whole page in frame, avoid glare, and check the page order before analyzing. You can correct extracted values against the original.';

  @override
  String get uiCorrectingAResult => 'Correcting a result';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'Review values against the original';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'Open a report, review each extracted test against the original, and correct any value, unit, or date that was read incorrectly. Unconfirmed results should be checked before you rely on trends.';

  @override
  String get uiManagingFamilyRecords => 'Managing family records';

  @override
  String get uiProfilesAccessAndPermissions =>
      'Profiles, access and permissions';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'Use Family to create and switch profiles. Check the selected person before uploading or sharing a report. Manage only records you are authorized to access.';

  @override
  String get uiSharingAndRevokingLinks => 'Sharing and revoking links';

  @override
  String get uiControlTheRecordsYouShare => 'Control the records you share';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'Select the reports or results you want to share, review the expiry and access code, then send the link and code separately. Revoke an active link from Shared links when access is no longer needed.';

  @override
  String get uiInformationYouProvide => 'Information you provide';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'Account details and family profiles identify whose records you manage. Uploaded documents may contain sensitive health information.';

  @override
  String get uiSharingControls => 'Sharing controls';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'Review the contents, expiry and access settings of each link. Manage active links from your account settings.';

  @override
  String get uiExportAndAccountChoices => 'Export and account choices';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'Use settings to export records or start an account deletion request. Retention details belong in the complete policy.';

  @override
  String get uiEducationalScope => 'Educational scope';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'Doclyzer organizes reports and shows results over time. Educational explanations are not medical advice or a diagnosis.';

  @override
  String get uiReviewYourRecords => 'Review your records';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'Check extracted values, units and dates against the original report. Ask a healthcare professional about your results.';

  @override
  String get uiManageAndShareResponsibly => 'Manage and share responsibly';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'Only manage records you are authorized to access. Check the selected information and recipient before sharing.';

  @override
  String get uiPrivacyPolicy7ceacd => 'Privacy policy';

  @override
  String get uiTermsOfUse8a069e => 'Terms of use';

  @override
  String get uiOpenPrivacyControls => 'Open privacy controls';

  @override
  String get uiGetHelpWithTheApp => 'Get help with the app';

  @override
  String get uiExportYourDataInAccountSettings =>
      'Export your data in account settings';

  @override
  String get uiYOURDATACHOICES => 'YOUR DATA & CHOICES';

  @override
  String get uiUSINGDOCLYZER => 'USING DOCLYZER';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'Understand the information\nyou keep in Doclyzer.';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'A clear understanding\nof the app’s role.';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$reportCount from $name';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · Latest $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'Upload a report for $name to start this library.';
  }

  @override
  String uiIpAddress(String address) {
    return 'IP address: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'Signed in: $date';
  }

  @override
  String get uiUnknown => 'Unknown';

  @override
  String uiResultsFor(String name) {
    return 'Results for $name';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count lab parameters tracked';
  }

  @override
  String uiSampledDate(String date) {
    return 'Sampled $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'Collection date: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'Lab range: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI read this range as $range. Printed text: $printed. Check the original report before relying on this comparison.';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount ready';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count credits';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'A referral code has already been applied to this account.';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'Set a device passcode before turning on App lock.';

  @override
  String get uiLanguagePreferenceNotSaved =>
      'Language preference was not saved.';

  @override
  String get uiExportUnavailable => 'Export unavailable';

  @override
  String get uiUnreadableImage => 'Unreadable image';

  @override
  String uiStatusWithValue(String status) {
    return 'Status: $status';
  }

  @override
  String get uiPending => 'Pending';

  @override
  String get uiCompleted => 'Completed';

  @override
  String get uiFailed => 'Failed';

  @override
  String get uiInactive => 'Inactive';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'Restore before $date to keep your reports and profiles.';
  }

  @override
  String get uiThirtyDayDeadline => 'the 30-day deadline';

  @override
  String uiWhatsAffected(String details) {
    return 'What’s affected: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'Last updated: $date at $time';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename will appear under $name instead of the current profile.';
  }

  @override
  String get uiOneVerifiedResult => '1 verified result saved.';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count verified results saved.';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'Unable to switch profiles. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'Collected: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'Uploaded $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return 'Increased by $amount';
  }

  @override
  String uiDecreasedBy(String amount) {
    return 'Decreased by $amount';
  }

  @override
  String get uiPercentagePoints => ' percentage points';

  @override
  String uiTestValuesCount(String count) {
    return 'Test values ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'Value checked by AI during processing. Original OCR: $value. Confirm it against the report.';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return 'Report already in $name';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return 'Report added to $name';
  }

  @override
  String uiAddedOn(String date) {
    return 'Added $date';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return 'Using $current of $max reports.';
  }

  @override
  String get uiNeedHelp => 'Need help?';

  @override
  String get uiEnabled => 'Enabled';

  @override
  String get uiEnable => 'Enable';

  @override
  String get uiSubscribe => 'Subscribe';

  @override
  String get uiApplying => 'Applying';

  @override
  String get uiCheckStatus => 'Check status';

  @override
  String get uiEditProfile => 'Edit profile';

  @override
  String get uiSaveChanges => 'Save changes';

  @override
  String get uiOptional => 'Optional';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'Order $orderId is waiting for reconciliation. Buying is paused until status is clear.';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'Monthly Plan - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'Credit Pack - $name';
  }

  @override
  String get uiUnreadable => 'Unreadable';

  @override
  String uiLatestValue(String value) {
    return 'Latest: $value';
  }

  @override
  String get uiEarlier => 'Earlier';

  @override
  String get uiLater => 'Later';

  @override
  String get uiViewed => 'Viewed';

  @override
  String get uiBlocked => 'Blocked';

  @override
  String get uiCapped => 'Capped';

  @override
  String uiLastChange(String label) {
    return 'Last change: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'Last change: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'Gift voucher applied. $credits credits added.';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'Could not save the original yet. $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'Failed to revoke: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'Use my Doclyzer referral code $code: $link';
  }

  @override
  String get uiAMomentAgo => 'A moment ago';

  @override
  String uiMinutesAgo(String count) {
    return '$count min ago';
  }

  @override
  String get uiOneHourAgo => '1 hour ago';

  @override
  String uiHoursAgo(String count) {
    return '$count hours ago';
  }

  @override
  String get uiToday => 'Today';

  @override
  String get uiYesterday => 'Yesterday';

  @override
  String get uiOneDayAgo => '1 day ago';

  @override
  String uiDaysAgo(String count) {
    return '$count days ago';
  }

  @override
  String get uiOneWeekAgo => '1 week ago';

  @override
  String uiWeeksAgo(String count) {
    return '$count weeks ago';
  }

  @override
  String get uiOneMonthAgo => '1 month ago';

  @override
  String uiMonthsAgo(String count) {
    return '$count months ago';
  }

  @override
  String get uiOneYearAgo => '1 year ago';

  @override
  String uiYearsAgo(String count) {
    return '$count years ago';
  }

  @override
  String get uiInOneDay => 'In 1 day';

  @override
  String uiInDays(String count) {
    return 'In $count days';
  }

  @override
  String uiInMinutes(String count) {
    return 'In $count min';
  }

  @override
  String get uiInOneHour => 'In 1 hour';

  @override
  String uiInHours(String count) {
    return 'In $count hours';
  }

  @override
  String get uiMissingExtractedTestName =>
      'The test name is missing from the extracted result.';

  @override
  String get uiMissingCapturedLabRange =>
      'No lab reference range was captured for this test.';

  @override
  String get uiNonNumericExtractedValue =>
      'The extracted value is not a plain number. Check it in the original report.';

  @override
  String get uiLabFlagRangeConflict =>
      'The lab flag conflicts with the printed range. Check the original report.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'The extracted value, printed range, or lab flag needs checking in the original report.';

  @override
  String get uiInitialEntitlement => 'Initial entitlement';

  @override
  String get uiCreditPackPurchase => 'Credit pack purchase';

  @override
  String get uiSubscriptionUpgrade => 'Subscription upgrade';

  @override
  String get uiPlanDowngrade => 'Plan downgrade';

  @override
  String get uiAdminAdjustment => 'Admin adjustment';

  @override
  String get uiSystemReconciliation => 'System reconciliation';

  @override
  String get uiReferralInviteBonus => 'Referral invite bonus';

  @override
  String get uiReferralAnalysisMilestone => 'Referral analysis milestone';

  @override
  String get uiReferralPurchaseMilestone => 'Referral purchase milestone';

  @override
  String get uiFreePromoCreditPack => 'Free promo credit pack';

  @override
  String get uiGiftVoucherRedeemed => 'Gift voucher redeemed';

  @override
  String get uiNotYetChanged => 'Not yet changed';

  @override
  String get uiCannotReachServer =>
      'Unable to reach the server. Check your connection and try again.';

  @override
  String get uiInvalidEmailOrPassword =>
      'Invalid email or password. Check your details and try again.';

  @override
  String get uiTooManyAuthAttempts =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get uiEnterValidEmail => 'Please enter a valid email address.';

  @override
  String get uiPasswordRequirements =>
      'Password must be at least 8 characters and include uppercase, lowercase, a number, and a special character.';

  @override
  String get uiAccountWithEmailExists =>
      'An account with this email already exists. Sign in or use a different email.';

  @override
  String get uiUploadedStatus => 'Uploaded';

  @override
  String uiSupportAction(String action) {
    return 'Action: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'Correlation ID: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'Client Action ID: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'Error Code: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'Error: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'Your session ended. Sign in again.';

  @override
  String get uiProfileLimitReached =>
      'Your plan profile limit has been reached. Review Plan & Credits to add more.';

  @override
  String get uiCorrectionConflictReload =>
      'This result changed elsewhere. Reload the report before correcting it.';

  @override
  String get uiSeePlanCreditsOptions =>
      'See Plan & Credits for available options.';

  @override
  String get uiShareLinkLimitHelp =>
      'You have reached the active share-link limit.';

  @override
  String get uiScopedExportUnavailable =>
      'Scoped export is unavailable. Try again later.';

  @override
  String get uiRestorationUnavailable =>
      'Restoration is unavailable. Try again later.';

  @override
  String get uiExportRequestNotFound =>
      'Export request not found. Request a new export.';

  @override
  String get uiClosureConfirmationRequired =>
      'Confirm account closure to continue.';

  @override
  String get uiCurrentPasswordIncorrect => 'Current password is incorrect.';

  @override
  String get uiLaboratories => 'Laboratories';

  @override
  String get uiUnlock => 'Unlock';
}
