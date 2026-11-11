// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get trendLatestResult => 'সর্বশেষ ফলাফল';

  @override
  String get trendPreviousResult => 'আগের ফলাফল';

  @override
  String get trendSourceUnit => 'এই সীমার মূল একক';

  @override
  String get trendNoSavedResults =>
      'এই পরীক্ষার জন্য এখনও কোনো সংরক্ষিত ফলাফল নেই।';

  @override
  String get trendNoPlottableResults =>
      'নমুনা সংগ্রহের তারিখসহ নির্ভুল সংখ্যাগত ফলাফল চার্টে দেখানো যাচ্ছে না।';

  @override
  String get trendOneResultHelp =>
      'একটি ফলাফল সংরক্ষিত আছে। পরিবর্তন দেখতে আরেকটি রিপোর্ট যোগ করুন।';

  @override
  String get trendMultipleResultsHelp =>
      'তারিখগুলি অতিবাহিত সময় অনুযায়ী দেখানো হয়েছে। মান দেখতে বিন্দুতে ট্যাপ করুন।';

  @override
  String trendUnplottedNote(int count) {
    return 'নমুনা সংগ্রহের তারিখ বা নির্ভুল সংখ্যাগত মান না থাকায় $countটি ফলাফল চার্টে দেখানো যায়নি।';
  }

  @override
  String trendChartLabel(String testName, int count) {
    return '$countটি ফলাফলসহ $testName-এর পরিবর্তনের চার্ট';
  }

  @override
  String get trendDateReview =>
      'নমুনা সংগ্রহের তারিখ আগের তথ্য নিষ্কাশন থেকে এসেছে। মূল রিপোর্টে যাচাই করুন।';

  @override
  String get trendNotPlotted => 'চার্টে দেখানো হয়নি';

  @override
  String get trendExactNumberUnavailable => 'ফলাফলটি নির্ভুল সংখ্যা নয়';

  @override
  String get preferredLanguage => 'পছন্দের ভাষা';

  @override
  String get descriptionLanguage => 'বিবরণের ভাষা';

  @override
  String get languageHelp =>
      'অ্যাপের লেবেল ও রিপোর্টের ব্যাখ্যার জন্য ব্যবহৃত হয়। আপনি যেকোনো সময় ব্যাখ্যার ভাষা বদলাতে পারেন।';

  @override
  String get languageSaveFailed =>
      'আপনার ভাষার পছন্দ সংরক্ষণ করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get translationLoading => 'অনূদিত বিবরণ প্রস্তুত হচ্ছে…';

  @override
  String get translationFailed =>
      'অনুবাদ পাওয়া যাচ্ছে না। আবার চেষ্টা করুন বা ইংরেজি বেছে নিন।';

  @override
  String get translationNote =>
      'সংরক্ষিত ইংরেজি ব্যাখ্যা থেকে AI দিয়ে অনুবাদ করা হয়েছে। ফলাফলের সঠিক তথ্যের জন্য মূল রিপোর্ট দেখুন।';

  @override
  String get sourceChanged =>
      'রিপোর্টটি বদলেছে। সর্বশেষ ব্যাখ্যা দেখতে এটি আবার লোড করুন।';

  @override
  String get signupTitle => 'আরও স্পষ্ট ধারণার\nশুরু এখানেই।';

  @override
  String get signupIntro =>
      'আপনার রিপোর্ট ও ফলাফল একসঙ্গে রাখতে একটি অ্যাকাউন্ট তৈরি করুন।';

  @override
  String get loginIntro =>
      'আপনার স্বাস্থ্য রিপোর্ট দেখতে ও বুঝতে সাইন ইন করুন।';

  @override
  String get emailAddress => 'ইমেল ঠিকানা';

  @override
  String get email => 'ইমেল';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get referralCode => 'রেফারেল কোড (ঐচ্ছিক)';

  @override
  String get createAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get alreadyAccount => 'আগেই অ্যাকাউন্ট আছে? ';

  @override
  String get noAccount => 'অ্যাকাউন্ট নেই? ';

  @override
  String get signIn => 'সাইন ইন করুন';

  @override
  String get showPassword => 'পাসওয়ার্ড দেখান';

  @override
  String get hidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get needHelp => 'সাহায্য দরকার?';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get invalidCredentialsInput =>
      'একটি বৈধ ইমেল ঠিকানা ও পাসওয়ার্ড লিখুন';

  @override
  String get signupFailed => 'অ্যাকাউন্ট তৈরি করা যাচ্ছে না';

  @override
  String get loginFailed =>
      'সাইন ইন করা যাচ্ছে না। আপনার সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get genericError =>
      'কোনো সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get profileUpdated => 'প্রোফাইল আপডেট হয়েছে';

  @override
  String get changePhoto => 'প্রোফাইলের ছবি বদলান';

  @override
  String get gallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get camera => 'ছবি তুলুন';

  @override
  String get photoUpdated => 'প্রোফাইলের ছবি আপডেট হয়েছে';

  @override
  String get photoFailed =>
      'আপনার ছবি আপডেট করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get yourAccount => 'আপনার অ্যাকাউন্ট';

  @override
  String get profileLoading => 'প্রোফাইল লোড হচ্ছে…';

  @override
  String get profileLoadAction => 'আপনার প্রোফাইল লোড করতে ট্যাপ করুন';

  @override
  String get accountData => 'অ্যাকাউন্ট ও ডেটা';

  @override
  String get personalInformation => 'ব্যক্তিগত তথ্য';

  @override
  String get notificationPreferences => 'বিজ্ঞপ্তির পছন্দ';

  @override
  String get privacySecurity => 'গোপনীয়তা ও নিরাপত্তা';

  @override
  String get sharedLinks => 'শেয়ার করা লিঙ্ক';

  @override
  String get exportData => 'আপনার ডেটা রপ্তানি করুন';

  @override
  String get additionalAccount => 'অ্যাকাউন্টের অতিরিক্ত তথ্য';

  @override
  String get additionalAccountHelp =>
      'পরিবার, প্ল্যান, রেফারেল, সেশন ও প্রদর্শনরীতি';

  @override
  String get familyProfiles => 'পরিবারের সদস্যদের প্রোফাইল';

  @override
  String get manageProfiles => 'প্রোফাইল বদলান বা পরিচালনা করুন';

  @override
  String get planCredits => 'প্ল্যান ও ক্রেডিট';

  @override
  String get viewPlanBalance => 'আপনার প্ল্যান ও ব্যালেন্স দেখুন';

  @override
  String get balanceLoading => 'ব্যালেন্স লোড হচ্ছে…';

  @override
  String get referFriends => 'বন্ধুদের রেফার করুন';

  @override
  String get referralRewards => 'আমন্ত্রণ ও রেফারেলের পুরস্কার';

  @override
  String get activeSessions => 'সক্রিয় সেশন';

  @override
  String get appearance => 'প্রদর্শনরীতি';

  @override
  String get system => 'সিস্টেম অনুযায়ী';

  @override
  String get light => 'হালকা';

  @override
  String get dark => 'গাঢ়';

  @override
  String get helpSupport => 'সাহায্য ও সহায়তা';

  @override
  String get aboutDoclyzer => 'Doclyzer সম্পর্কে';

  @override
  String get aboutCopy =>
      'ব্যক্তি অনুযায়ী রিপোর্ট গুছিয়ে রাখুন এবং রিপোর্ট থেকে নেওয়া ফলাফল মূল রিপোর্টের সঙ্গে মিলিয়ে দেখুন।';

  @override
  String get logOut => 'লগ আউট করুন';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get accountRestricted => 'অ্যাকাউন্টের ব্যবহার সীমিত';

  @override
  String get photoUploading => 'ছবি আপলোড হচ্ছে…';

  @override
  String get changePhotoShort => 'ছবি বদলান';

  @override
  String get accountDetails => 'অ্যাকাউন্টের বিবরণ';

  @override
  String get emailHelp =>
      'অ্যাকাউন্টে প্রবেশের জন্য ব্যবহৃত হয়। এটি বদলাতে সহায়তা বিভাগের সঙ্গে যোগাযোগ করুন।';

  @override
  String get accountName => 'অ্যাকাউন্টের নাম';

  @override
  String get belowLabRange => 'এই ল্যাবের রেফারেন্স সীমার নিচে';

  @override
  String get withinLabRange => 'এই ল্যাবের রেফারেন্স সীমার মধ্যে';

  @override
  String get aboveLabRange => 'এই ল্যাবের রেফারেন্স সীমার উপরে';

  @override
  String get cannotCompare => 'ল্যাবের সীমার সঙ্গে তুলনা করা যাচ্ছে না';

  @override
  String get understandResult => 'এই ফলাফলটি বুঝুন';

  @override
  String get yourResult => 'আপনার ফলাফল';

  @override
  String get labReferenceRange => 'ল্যাবের রেফারেন্স সীমা';

  @override
  String get resultUnavailable => 'এই ফলাফলে দেওয়া নেই';

  @override
  String get sampleDate => 'নমুনা সংগ্রহের তারিখ';

  @override
  String get resultHistory => 'ফলাফলের ইতিহাস';

  @override
  String get originalReport => 'মূল রিপোর্ট';

  @override
  String get reviewValue => 'মান যাচাই করুন';

  @override
  String get understandYourResult => 'আপনার ফলাফল বুঝুন';

  @override
  String get educationalContext =>
      'এই ফলাফল নিয়ে আলোচনা করতে সহায়ক শিক্ষামূলক তথ্য।';

  @override
  String get explanationUnavailable => 'ব্যাখ্যা পাওয়া যাচ্ছে না';

  @override
  String get explanationFailed => 'এই মুহূর্তে ব্যাখ্যা লোড করা যায়নি।';

  @override
  String get checkOriginal => 'মূল রিপোর্ট যাচাই করুন';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get aiGuidance => 'AI-এর তৈরি পরামর্শ';

  @override
  String get understandingResult => 'এই ফলাফল বোঝার জন্য';

  @override
  String get possibleMeaning => 'এর অর্থ কী হতে পারে';

  @override
  String get whatTestMeasures => 'এই পরীক্ষায় কী পরিমাপ করা হয়';

  @override
  String get suggestedNextStep => 'পরবর্তী পদক্ষেপের প্রস্তাব';

  @override
  String get resultLimitations => 'এই ফলাফল থেকে কী জানা যায় না';

  @override
  String get oneResultLimit =>
      'শুধু একটি ফলাফল দিয়ে কোনো রোগ নির্ণয় করা বা উপসর্গের কারণ ব্যাখ্যা করা যায় না।';

  @override
  String get detailsToCheck => 'যেসব বিবরণ যাচাই করবেন';

  @override
  String get lifestyleFactors =>
      'জীবনযাপনের যেসব বিষয় নিয়ে আলোচনা করতে পারেন';

  @override
  String get insightContext =>
      'এই মানটি আপনার রিপোর্ট থেকে নেওয়া হয়েছে। নাম, মান, একক বা সীমা ভুল মনে হলে মূল রিপোর্ট দেখুন। AI-এর ব্যাখ্যাগুলি শিক্ষামূলক এবং আপনার কোন চিকিৎসা দরকার তা বলতে পারে না।';

  @override
  String get yourProfile => 'আপনার প্রোফাইল';

  @override
  String get cancel => 'বাতিল করুন';

  @override
  String get delete => 'মুছে ফেলুন';

  @override
  String get moveReport => 'রিপোর্ট স্থানান্তর করুন';

  @override
  String get gotIt => 'বুঝেছি';

  @override
  String get reportDetails => 'রিপোর্টের বিবরণ';

  @override
  String get shareReport => 'রিপোর্ট শেয়ার করুন';

  @override
  String get moreReportActions => 'রিপোর্টের আরও বিকল্প';

  @override
  String get attemptHistory => 'চেষ্টার ইতিহাস';

  @override
  String get compareReports => 'রিপোর্ট তুলনা করুন';

  @override
  String get readParsedReport => 'তথ্য আলাদা করে সাজানো রিপোর্ট পড়ুন';

  @override
  String get moveRecycle => 'রিসাইকেল বিনে সরান';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get reportSummary => 'রিপোর্টের সারাংশ';

  @override
  String get updateSummary => 'সারাংশ আপডেট করুন';

  @override
  String get summaryLoading => 'আপনার ফলাফল সহজ ভাষায় বোঝানো হচ্ছে…';

  @override
  String get checkSummary => 'সারাংশ যাচাই করুন';

  @override
  String get summaryFailed =>
      'সারাংশ তৈরি করা যায়নি। আপনি আবার চেষ্টা করতে পারেন।';

  @override
  String get summaryPlaceholder =>
      'মূল ফলাফলগুলির সহজ ভাষায় ব্যাখ্যা এখানে দেখা যাবে।';

  @override
  String get retrySummary => 'সারাংশের জন্য আবার চেষ্টা করুন';

  @override
  String get generateSummary => 'সারাংশ তৈরি করুন';

  @override
  String get loadingResults => 'রিপোর্টের ফলাফল লোড হচ্ছে…';

  @override
  String get somethingWrong => 'কোনো সমস্যা হয়েছে';

  @override
  String get viewTrends => 'সময়ের সঙ্গে পরিবর্তন দেখুন';

  @override
  String get originalFile => 'মূল ফাইল';

  @override
  String get testValues => 'পরীক্ষার মান';

  @override
  String get summary => 'সারাংশ';

  @override
  String get checkStatus => 'অবস্থা দেখুন';

  @override
  String get viewOriginal => 'মূলটি দেখুন';

  @override
  String get verifiedResults => 'যাচাইকৃত ফলাফল';

  @override
  String get resultTapHelp =>
      'পরীক্ষায় কী পরিমাপ করা হয় তা বুঝতে কোনো ফলাফলে ট্যাপ করুন।';

  @override
  String get reviewResults => 'শনাক্ত করা ফলাফল যাচাই করুন';

  @override
  String get keepFile => 'তবুও ফাইল রাখুন';

  @override
  String get patientDetails => 'রোগীর বিবরণ';

  @override
  String get name => 'নাম';

  @override
  String get age => 'বয়স';

  @override
  String get gender => 'লিঙ্গ';

  @override
  String get bookingId => 'বুকিং ID';

  @override
  String get sampleCollection => 'নমুনা সংগ্রহ';

  @override
  String get labDetails => 'ল্যাবের বিবরণ';

  @override
  String get labName => 'ল্যাবের নাম';

  @override
  String get address => 'ঠিকানা';

  @override
  String get phone => 'ফোন';

  @override
  String get location => 'অবস্থান';

  @override
  String get belowRange => 'সীমার নিচে';

  @override
  String get aboveRange => 'সীমার উপরে';

  @override
  String get withinRange => 'উল্লিখিত সীমার মধ্যে';

  @override
  String get rangeUnclear => 'সীমা অস্পষ্ট';

  @override
  String get understandResultAction => 'এই ফলাফলটি বুঝুন  →';

  @override
  String get parsedReport => 'তথ্য আলাদা করে সাজানো রিপোর্ট';

  @override
  String get reports => 'রিপোর্ট';

  @override
  String get trends => 'সময়ের সঙ্গে পরিবর্তন';

  @override
  String get openingPage => 'শুরুর পৃষ্ঠা';

  @override
  String get home => 'হোম';

  @override
  String get family => 'পরিবার';

  @override
  String get switchProfile => 'প্রোফাইল বদলান';

  @override
  String get currentProfile => 'বর্তমান প্রোফাইল';

  @override
  String get viewProfile => 'এই প্রোফাইল দেখুন';

  @override
  String get manageFamily => 'পরিবারের সদস্যদের তথ্য পরিচালনা করুন';

  @override
  String get chooseProfile => 'একটি প্রোফাইল বেছে নিন';

  @override
  String get notifications => 'বিজ্ঞপ্তি';

  @override
  String get homeTitle => 'আরও একটু স্পষ্টতা।\nসব এক জায়গায়।';

  @override
  String get nextReportTitle =>
      'আপনার পরের রিপোর্ট,\nআপনি প্রস্তুত হলেই হাতের কাছে।';

  @override
  String get homeSubtitle => 'PDF, ছবি ও পরিবারের রেকর্ড।';

  @override
  String get uploadReport => 'রিপোর্ট আপলোড করুন';

  @override
  String get recentReport => 'সাম্প্রতিক রিপোর্ট';

  @override
  String get viewAll => 'সব দেখুন';

  @override
  String get reportsUnavailable =>
      'রিপোর্ট পাওয়া যাচ্ছে না। ইন্টারনেট সংযোগ হলে আবার চেষ্টা করুন।';

  @override
  String get emptyHomeTitle => 'আপনার গল্পের শুরু এখানেই';

  @override
  String get emptyHomeHelp =>
      'আপনার রেকর্ডের সুস্পষ্ট ইতিহাস তৈরি শুরু করতে প্রথম রিপোর্ট আপলোড করুন।';

  @override
  String get uploadFirstReport => 'আপনার প্রথম রিপোর্ট আপলোড করুন';

  @override
  String get latestResults => 'সর্বশেষ ফলাফল';

  @override
  String get allTrends => 'সময়ের সঙ্গে সব পরিবর্তন';

  @override
  String get reviewedResultsHelp =>
      'পর্যালোচনা করা ফলাফল পাওয়া গেলে এখানে দেখা যাবে।';

  @override
  String get searchTests => 'পরীক্ষা খুঁজুন';

  @override
  String get noHealthData =>
      'এখনও স্বাস্থ্যের কোনো তথ্য নেই। আপনার স্বাস্থ্যের ইতিহাস দেখতে একটি রিপোর্ট আপলোড করুন।';

  @override
  String get noTestsFound => 'কোনো পরীক্ষা পাওয়া যায়নি';

  @override
  String get shorterTestName => 'পরীক্ষার নামের আরও ছোট অংশ লিখে চেষ্টা করুন।';

  @override
  String get clearSearch => 'অনুসন্ধান মুছুন';

  @override
  String get unitUnavailable => 'একক পাওয়া যাচ্ছে না';

  @override
  String get uploadingReport => 'রিপোর্ট আপলোড হচ্ছে…';

  @override
  String get organizingReport => 'আপনার রিপোর্ট গুছিয়ে নেওয়া হচ্ছে…';

  @override
  String get uploadAReport => 'একটি রিপোর্ট আপলোড করুন';

  @override
  String get uploadHelp =>
      'একটি PDF বা স্পষ্ট ছবি বেছে নিন। সংরক্ষণের আগে বিবরণ যাচাই করতে পারবেন।';

  @override
  String get chooseSource => 'একটি উৎস বেছে নিন';

  @override
  String get uploadPdfImage => 'PDF বা ছবি আপলোড করুন';

  @override
  String get chooseReportFiles => 'আপনার ফাইল থেকে একটি রিপোর্ট বেছে নিন';

  @override
  String get selectReportPages => 'রিপোর্টের এক বা একাধিক পৃষ্ঠা বেছে নিন';

  @override
  String get capturePage => 'পুরো পৃষ্ঠার ছবি তুলুন';

  @override
  String get supportedFormats => 'সমর্থিত ফরম্যাট: PDF, JPG, PNG';

  @override
  String get confirmFile => 'আপনি এই ফাইলটিই যোগ করতে চান কি না নিশ্চিত করুন।';

  @override
  String get addReport => 'রিপোর্ট যোগ করুন';

  @override
  String get chooseDifferentFile => 'অন্য একটি ফাইল বেছে নিন';

  @override
  String get uploadWait =>
      'কিছুটা সময় লাগতে পারে। অনুগ্রহ করে অ্যাপটি খোলা রাখুন।';

  @override
  String get reportNeedsAttention => 'রিপোর্টটি খেয়াল করে দেখা দরকার';

  @override
  String get verifyBeforeSaving =>
      'শনাক্ত করা ফলাফল সংরক্ষণের আগে মূল রিপোর্টের সঙ্গে মিলিয়ে দেখুন।';

  @override
  String get viewVerifiedResults => 'যাচাইকৃত ফলাফল দেখুন';

  @override
  String get viewOriginalReport => 'মূল রিপোর্ট দেখুন';

  @override
  String get viewReportStatus => 'রিপোর্টের অবস্থা দেখুন';

  @override
  String get viewResults => 'ফলাফল দেখুন';

  @override
  String get viewOriginalFile => 'মূল ফাইল দেখুন';

  @override
  String get retryExtraction => 'রিপোর্ট থেকে তথ্য নেওয়ার চেষ্টা আবার করুন';

  @override
  String get done => 'হয়ে গেছে';

  @override
  String get duplicateReport =>
      'এই রিপোর্টটি একই রিপোর্টের আরেকটি কপি বলে মনে হচ্ছে';

  @override
  String get duplicateHelp =>
      'এই ফাইলটি হয়তো ইতিমধ্যেই আপনার রিপোর্টগুলির মধ্যে আছে।';

  @override
  String get keepExisting => 'আগেরটি রাখুন';

  @override
  String get processAgain => 'PDF আবার প্রক্রিয়া করুন';

  @override
  String get uploadNewCopy => 'নতুন কপি হিসেবে আপলোড করুন';

  @override
  String get reportLimitReached => 'রিপোর্টের সংখ্যার সীমায় পৌঁছেছেন';

  @override
  String get reportLimitHelp => 'আপনি আপনার রিপোর্টের সংখ্যার সীমায় পৌঁছেছেন।';

  @override
  String get upgrade => 'আপগ্রেড করুন';

  @override
  String get back => 'ফিরে যান';

  @override
  String get uploadFailedTitle => 'রিপোর্ট আপলোড করা যায়নি';

  @override
  String get uploadFailed => 'আপলোড ব্যর্থ হয়েছে';

  @override
  String get retrySameFile => 'একই ফাইল দিয়ে আবার চেষ্টা করুন';

  @override
  String get chooseAnotherFile => 'অন্য ফাইল বেছে নিন';

  @override
  String get aiDisclaimer =>
      'Doclyzer আপনার স্বাস্থ্য রিপোর্ট গুছিয়ে রাখতে এবং আরও ভালোভাবে বুঝতে সাহায্য করে। দেওয়া তথ্য শুধুমাত্র শিক্ষামূলক উদ্দেশ্যে এবং তা চিকিৎসা-পরামর্শ, রোগ নির্ণয় বা চিকিৎসা নয়। চিকিৎসা সংক্রান্ত পরামর্শের জন্য সবসময় একজন যোগ্য স্বাস্থ্যসেবা পেশাজীবীর সঙ্গে আলোচনা করুন।';

  @override
  String collectedOn(String date) {
    return 'সংগ্রহের তারিখ $date';
  }

  @override
  String uploadedOn(String date) {
    return 'আপলোডের তারিখ $date';
  }

  @override
  String labRangeValue(String range) {
    return 'ল্যাবের সীমা $range';
  }

  @override
  String planBalance(String plan, String credits) {
    return '$plan · $credits ক্রেডিট';
  }

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি রিপোর্ট',
      one: '1টি রিপোর্ট',
      zero: 'কোনো রিপোর্ট নেই',
    );
    return '$_temp0';
  }

  @override
  String get reportLoadSlow =>
      'রিপোর্ট লোড হতে প্রত্যাশার চেয়ে বেশি সময় লাগছে। আপনার সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get summaryUpdateFailed =>
      'এই মুহূর্তে সারাংশ আপডেট করা যায়নি। সংরক্ষিত সারাংশ এখনও দেখা যাবে।';

  @override
  String get summaryCreateFailed =>
      'এই মুহূর্তে সারাংশ তৈরি করা যায়নি। আপনার ফলাফল এখনও নিচে দেখা যাবে।';

  @override
  String get reassignFailed =>
      'রিপোর্টটি অন্য প্রোফাইলে স্থানান্তর করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get confirmRecycle => 'রিসাইকেল বিনে সরাবেন?';

  @override
  String get recycleHelp =>
      'আপনি 30 দিন পর্যন্ত রিপোর্ট > রিসাইকেল বিন থেকে এই রিপোর্ট ফিরিয়ে আনতে পারবেন। তারপর এটি স্থায়ীভাবে মুছে ফেলা হবে।';

  @override
  String get reportRecycled => 'রিপোর্ট রিসাইকেল বিনে সরানো হয়েছে';

  @override
  String get reportDeleteFailed =>
      'রিপোর্ট মুছে ফেলা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get addProfileBeforeMove =>
      'এই রিপোর্ট স্থানান্তর করার আগে পরিবারের আরেকটি প্রোফাইল যোগ করুন।';

  @override
  String get moveReportHelp =>
      'এই রিপোর্ট ভুল প্রোফাইলে যোগ হয়ে থাকলে পরিবারের অন্য সদস্যকে বেছে নিন।';

  @override
  String get confirmMoveReport => 'এই রিপোর্ট স্থানান্তর করবেন?';

  @override
  String get aboutSampleDates => 'নমুনা সংগ্রহের তারিখ সম্পর্কে';

  @override
  String get multipleDatesHelp =>
      'এই রিপোর্টে একাধিক নমুনা সংগ্রহের তারিখের ফলাফল রয়েছে। কোনো ফলাফল খুলে তার তারিখ মূল রিপোর্টের সঙ্গে মিলিয়ে দেখুন।';

  @override
  String get missingDateHelp =>
      'নমুনা সংগ্রহের তারিখ হল যেদিন নমুনাটি নেওয়া হয়েছিল। এই রিপোর্টে নির্ভরযোগ্য কোনো তারিখ পাওয়া যায়নি। এটি আপলোডের তারিখের থেকে আলাদা। তারিখ যাচাই বা সংশোধন করতে কোনো ফলাফল খুলুন।';

  @override
  String get uploading => 'আপলোড হচ্ছে';

  @override
  String get waitingToProcess => 'প্রক্রিয়াকরণের অপেক্ষায়';

  @override
  String get readingReport => 'রিপোর্ট পড়া হচ্ছে';

  @override
  String get readyToReview => 'পর্যালোচনার জন্য প্রস্তুত';

  @override
  String get someResultsNeedReview => 'কিছু ফলাফল পর্যালোচনা করা দরকার';

  @override
  String get couldNotReadReport => 'রিপোর্ট পড়া যায়নি';

  @override
  String get processingStopped => 'প্রক্রিয়াকরণ থেমে গেছে';

  @override
  String get couldNotProcessReport => 'রিপোর্ট প্রক্রিয়া করা যায়নি';

  @override
  String get reportRefreshFailed =>
      'এই রিপোর্ট নতুন করে লোড করা যায়নি। শেষবার লোড হওয়া ফলাফল দেখানো হচ্ছে।';

  @override
  String get multipleSampleDates => 'নমুনা সংগ্রহের একাধিক তারিখ ';

  @override
  String get missingSampleDate => 'নমুনা সংগ্রহের তারিখ পাওয়া যায়নি ';

  @override
  String get reportAnalyzing =>
      'আমরা এই রিপোর্ট বিশ্লেষণ করছি। আপনি এই স্ক্রিন থেকে বেরিয়ে যেতে পারেন; ফলাফল প্রস্তুত হলে দেখা যাবে।';

  @override
  String get extractionIncompleteTitle =>
      'সব ফলাফল নির্ভরযোগ্যভাবে রিপোর্ট থেকে নেওয়া যায়নি';

  @override
  String get extractionIncompleteHelp =>
      'স্বয়ংক্রিয়ভাবে তথ্য নেওয়া সম্পূর্ণ হয়নি। শনাক্ত করা সারিগুলি সংরক্ষণের আগে মূল রিপোর্টের সঙ্গে মিলিয়ে দেখুন।';

  @override
  String get verifiedRowsHelp =>
      'এই সারিগুলি মূল রিপোর্টের সঙ্গে মিলিয়ে দেখা হয়েছে। অন্য সারিগুলি এখনও পর্যালোচনা করা দরকার হতে পারে।';

  @override
  String get noTestValues =>
      'এই রিপোর্টে পরীক্ষার কোনো মান পাওয়া যায়নি। কী আছে তা দেখতে মূল ফাইল খুলুন।';

  @override
  String get processingRetryHelp =>
      'শেষ হওয়ার আগেই প্রক্রিয়াকরণ থেমে গেছে। আপনার ফাইল সংরক্ষিত আছে। আবার চেষ্টা করতে ‘আবার চেষ্টা করুন’-এ ট্যাপ করুন।';

  @override
  String get resultsNeedCheck =>
      'কিছু ফলাফল মূল রিপোর্টের সঙ্গে মিলিয়ে দেখা দরকার। নিচে শনাক্ত করা সারিগুলি পর্যালোচনা করতে পারেন।';

  @override
  String get readerModeHelp =>
      'সহজে দেখতে ও আরও ভালোভাবে পড়তে তথ্য আলাদা করে সাজানো রিপোর্ট পড়ার মোডে পাওয়া যাচ্ছে।';

  @override
  String get aiRangeHelp =>
      'প্রক্রিয়াকরণের সময় AI সীমাটি ব্যাখ্যা করেছে। মূল রিপোর্ট দেখুন।';

  @override
  String get checkResultHelp =>
      'এই ফলাফলের উপর নির্ভর করার আগে মূল রিপোর্টের সঙ্গে মিলিয়ে দেখুন।';

  @override
  String get preferredRangeHelp =>
      'ল্যাবের রিপোর্টে ছাপা কাঙ্ক্ষিত শ্রেণির সঙ্গে তুলনা করা হয়েছে; এটি আপনার ক্ষেত্রে প্রযোজ্য কি না নিশ্চিত করুন।';

  @override
  String get categoryComparisonHelp =>
      'এই তুলনায় ল্যাবের রিপোর্টে ছাপা কাঙ্ক্ষিত শ্রেণি ব্যবহার করা হয়েছে। শ্রেণিটি আপনার ক্ষেত্রে প্রযোজ্য কি না যাচাই করুন।';

  @override
  String get missingSavedResult =>
      'এই মানটি কোনো সংরক্ষিত ফলাফলের সঙ্গে মেলানো যায়নি। মূল রিপোর্ট দেখুন বা এই রিপোর্ট নতুন করে লোড করুন।';

  @override
  String get unreviewedTest =>
      'AI ব্যাখ্যার জন্য এই পরীক্ষাটি এখনও পর্যালোচনা করা হয়নি। মূল রিপোর্ট দেখুন এবং আপনার চিকিৎসকের সঙ্গে ফলাফল নিয়ে আলোচনা করুন।';

  @override
  String get unsafeResult =>
      'রিপোর্ট থেকে নেওয়া ফলাফলটি অস্পষ্ট, তাই নিরাপদভাবে এর ব্যাখ্যা দেওয়া যায় না। মূল রিপোর্ট দেখুন।';

  @override
  String get filterReports => 'রিপোর্ট ফিল্টার করুন';

  @override
  String get sortReports => 'রিপোর্ট সাজান';

  @override
  String get recycleBin => 'রিসাইকেল বিন';

  @override
  String get healthHistory => 'স্বাস্থ্যের ইতিহাস';

  @override
  String get shareProfile => 'প্রোফাইল শেয়ার করুন';

  @override
  String get reportsUnavailableTitle => 'রিপোর্ট পাওয়া যাচ্ছে না';

  @override
  String get reportsLoadFailed =>
      'রিপোর্ট লোড করা যাচ্ছে না। ইন্টারনেট সংযোগ হলে আবার চেষ্টা করুন।';

  @override
  String get upload => 'আপলোড করুন';

  @override
  String get reportsFor => 'যাঁর রিপোর্ট';

  @override
  String get searchReports => 'রিপোর্ট বা ল্যাব খুঁজুন';

  @override
  String get filters => 'ফিল্টার';

  @override
  String get noReportsYet => 'এখনও কোনো রিপোর্ট নেই';

  @override
  String get noMatchingReports =>
      'আপনার অনুসন্ধানের সঙ্গে কোনো রিপোর্ট মেলেনি।';

  @override
  String get differentSearch =>
      'অন্য পরীক্ষা, ল্যাব বা ফিল্টার দিয়ে চেষ্টা করুন।';

  @override
  String get clearFilters => 'অনুসন্ধান ও ফিল্টার মুছুন';

  @override
  String get original => 'মূল';

  @override
  String get switchActiveProfile => 'সক্রিয় প্রোফাইল বদলান';

  @override
  String get switchProfileHelp =>
      'অন্য ব্যক্তির রিপোর্ট দেখুন। আপলোড ও সময়ের সঙ্গে পরিবর্তন দেখার জন্য আপনার সক্রিয় প্রোফাইলও বদলে যাবে।';

  @override
  String get multipleCollectionDates => 'নমুনা সংগ্রহের একাধিক তারিখ';

  @override
  String get unknownCollectionDate => 'নমুনা সংগ্রহের তারিখ অজানা';

  @override
  String get profileLoadFailed =>
      'প্রোফাইল লোড করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get pleaseTryAgain => 'অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get deleteProfileConfirm => 'প্রোফাইল মুছে ফেলবেন?';

  @override
  String get deleteProfileHelp =>
      'এই প্রোফাইল সরিয়ে দেওয়া হবে। এর সঙ্গে যুক্ত সব ডেটার উপর এর প্রভাব পড়বে।';

  @override
  String get profileDeleteFailed =>
      'প্রোফাইল মুছে ফেলা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get addFamilyMember => 'পরিবারের সদস্য যোগ করুন';

  @override
  String get familyUnavailable => 'পরিবারের সদস্যদের প্রোফাইল পাওয়া যাচ্ছে না';

  @override
  String get familyIntro =>
      'ব্যক্তি অনুযায়ী সাজানো রিপোর্ট ও সময়ের সঙ্গে পরিবর্তনের তথ্য';

  @override
  String get noProfilesYet => 'এখনও কোনো প্রোফাইল নেই';

  @override
  String get noProfilesHelp =>
      'নিজের বা পরিবারের সদস্যদের রিপোর্ট গুছিয়ে রাখতে একটি প্রোফাইল যোগ করুন।';

  @override
  String get yourFamily => 'আপনার পরিবার';

  @override
  String get upgradeProfiles => 'আরও প্রোফাইল যোগ করতে আপগ্রেড করুন';

  @override
  String get editProfile => 'প্রোফাইল সম্পাদনা করুন';

  @override
  String get deleteProfile => 'প্রোফাইল মুছে ফেলুন';

  @override
  String get active => 'সক্রিয়';

  @override
  String get setActive => 'সক্রিয় করুন';

  @override
  String get viewReports => 'রিপোর্ট দেখুন';

  @override
  String get notNow => 'এখন নয়';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String get enableNotifications => 'বিজ্ঞপ্তি চালু করুন';

  @override
  String get enableNotificationsConfirm => 'বিজ্ঞপ্তি চালু করবেন?';

  @override
  String get notificationsEnabled => 'রিপোর্টের বিজ্ঞপ্তি চালু হয়েছে';

  @override
  String get notificationsStayOff =>
      'বিজ্ঞপ্তি বন্ধই রয়েছে। পরে ডিভাইসের সেটিংসে গিয়ে চালু করতে পারবেন।';

  @override
  String get notificationsFailed =>
      'বিজ্ঞপ্তি চালু করা যায়নি। আপনার সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get switchProfileFailed =>
      'প্রোফাইল বদলানো যাচ্ছে না। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get sourceReportFailed => 'মূল রিপোর্ট খোলা যাচ্ছে না।';

  @override
  String get partialRefreshFailed =>
      'কিছু তথ্য নতুন করে লোড করা যায়নি। আবার চেষ্টা করতে নিচের দিকে টানুন।';

  @override
  String get knowReportReady => 'আপনার রিপোর্ট প্রস্তুত হলে জেনে নিন';

  @override
  String get oneResult => 'একটি ফলাফল';

  @override
  String get sameDayResults => 'একই দিনের ফলাফল';

  @override
  String get verificationRequired => 'যাচাইকরণ প্রয়োজন';

  @override
  String get accountCreatedLogin =>
      'আপনার অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে। লগ ইন করতে এগিয়ে যান।';

  @override
  String get continueLogin => 'লগ ইন করতে এগিয়ে যান';

  @override
  String get allReports => 'সব রিপোর্ট';

  @override
  String get filterReviewed => 'পর্যালোচনা করা হয়েছে';

  @override
  String get filterNeedsReview => 'পর্যালোচনা করা দরকার';

  @override
  String get filterProcessing => 'প্রক্রিয়াকরণ চলছে';

  @override
  String get filterOriginalOnly => 'শুধু মূলটি';

  @override
  String get reportDateNewest => 'রিপোর্টের তারিখ · নতুন আগে';

  @override
  String get reportDateOldest => 'রিপোর্টের তারিখ · পুরোনো আগে';

  @override
  String get uploadDateNewest => 'আপলোডের তারিখ · নতুন আগে';

  @override
  String get uploadDateOldest => 'আপলোডের তারিখ · পুরোনো আগে';

  @override
  String get switchAction => 'বদলান';

  @override
  String get collectionDate => 'নমুনা সংগ্রহের তারিখ';

  @override
  String get copy => 'কপি করুন';

  @override
  String get history => 'ইতিহাস';

  @override
  String get loadingReport => 'রিপোর্ট লোড হচ্ছে…';

  @override
  String get restore => 'ফিরিয়ে আনুন';

  @override
  String get revoke => 'বাতিল করুন';

  @override
  String get testName => 'পরীক্ষার নাম';

  @override
  String get viewReport => 'রিপোর্ট দেখুন';

  @override
  String get closeAccount => 'অ্যাকাউন্ট বন্ধ করুন';

  @override
  String get createShareLink => 'শেয়ার করার লিঙ্ক তৈরি করুন';

  @override
  String get uiAppearanceChangedButCouldNotBeSaved =>
      'চেহারা পরিবর্তিত হয়েছে, কিন্তু পরবর্তী সময়ের জন্য সংরক্ষণ করা যাবে না।';

  @override
  String get uiThisReportIsNoLongerAvailable => 'এই রিপোর্ট আর উপলব্ধ নেই.';

  @override
  String get uiOpenDeviceSettingsToManageNotificationPreviews =>
      'বিজ্ঞপ্তির পূর্বরূপ পরিচালনা করতে ডিভাইস সেটিংস খুলুন।';

  @override
  String get uiKeepThisScreenOpenUntilTheUpload =>
      'আপলোড গৃহীত না হওয়া পর্যন্ত এই স্ক্রিনটি খোলা রাখুন।';

  @override
  String get uiAnUploadMayHaveBeenInterrupted => 'একটি আপলোড বিঘ্নিত হতে পারে';

  @override
  String get uiCheckReportsIfItIsMissingAdd =>
      'রিপোর্ট চেক করুন. এটি অনুপস্থিত থাকলে, একই ফাইল আবার যোগ করুন।';

  @override
  String get uiCouldNotDismissNotificationsTryAgain =>
      'বিজ্ঞপ্তি খারিজ করা যায়নি. আবার চেষ্টা করুন';

  @override
  String get uiConnectionUnavailable => 'সংযোগ অনুপলব্ধ';

  @override
  String get uiYourSessionCouldNotBeCheckedConnect =>
      'আপনার সেশন চেক করা যায়নি. ইন্টারনেটে কানেক্ট করুন এবং আবার চেষ্টা করুন।';

  @override
  String get uiSignInWithAnotherAccount => 'অন্য অ্যাকাউন্ট দিয়ে সাইন ইন করুন';

  @override
  String get uiNoActiveProfile => 'কোনো সক্রিয় প্রোফাইল নেই';

  @override
  String get uiDismissUploadNotice => 'আপলোড বিজ্ঞপ্তি খারিজ';

  @override
  String get uiDismissReadyNotifications => 'প্রস্তুত বিজ্ঞপ্তি খারিজ';

  @override
  String get uiRequestSupport => 'সমর্থন অনুরোধ';

  @override
  String get uiWeWillIncludeDiagnosticIDsSoThe =>
      'আমরা ডায়াগনস্টিক আইডি অন্তর্ভুক্ত করব যাতে দল তদন্ত করতে পারে।';

  @override
  String get uiSendRequest => 'অনুরোধ পাঠান';

  @override
  String get uiWhatHappenedOptional => 'কি হয়েছে? (ঐচ্ছিক)';

  @override
  String get uiReviewResult => 'পর্যালোচনা ফলাফল';

  @override
  String get uiCompareTheseFieldsWithTheOriginalReport =>
      'সংরক্ষণ করার আগে মূল প্রতিবেদনের সাথে এই ক্ষেত্রগুলির তুলনা করুন।';

  @override
  String get uiOriginallyExtracted => 'মূলত নিষ্কাশিত';

  @override
  String get uiReloadReport => 'রিপোর্ট পুনরায় লোড করুন';

  @override
  String get uiResultAsPrinted => 'মুদ্রিত হিসাবে ফলাফল';

  @override
  String get uiUnitIfShown => 'ইউনিট (যদি দেখানো হয়)';

  @override
  String get uiLabReferenceRangeIfShown =>
      'ল্যাব রেফারেন্স পরিসীমা (যদি দেখানো হয়)';

  @override
  String get uiCheckYourReport => 'আপনার রিপোর্ট চেক করুন';

  @override
  String get uiNoAttemptHistoryAvailable =>
      'কোনো প্রচেষ্টার ইতিহাস উপলব্ধ নেই৷';

  @override
  String get uiIInspectedTheOriginal => 'আমি মূল পরিদর্শন';

  @override
  String get uiChooseTwoReports => 'দুটি প্রতিবেদন নির্বাচন করুন';

  @override
  String get uiUseRecordsForTheSamePersonMatching =>
      'একই ব্যক্তির জন্য রেকর্ড ব্যবহার করুন. ম্যাচিং পরীক্ষা পাশাপাশি প্রদর্শিত হবে.';

  @override
  String get uiChooseTheOlderReportFirstAndThe =>
      'আগে পুরানো রিপোর্ট এবং নতুন রিপোর্ট দ্বিতীয় নির্বাচন করুন.';

  @override
  String get uiComparedOnlyWhenCompatibleDifferentUnitsOr =>
      'তুলনা শুধুমাত্র যখন সামঞ্জস্যপূর্ণ. সামঞ্জস্য নিশ্চিত না হওয়া পর্যন্ত বিভিন্ন ইউনিট বা পদ্ধতি আলাদাভাবে দেখানো হয়।';

  @override
  String get uiAChangeIsNotADiagnosisCompare =>
      'একটি পরিবর্তন একটি রোগ নির্ণয় নয়. প্রতিটি ফলাফলের নিজস্ব প্রতিবেদনের ব্যবধানের সাথে তুলনা করুন এবং আপনার চিকিত্সকের সাথে প্রসঙ্গটি নিয়ে আলোচনা করুন।';

  @override
  String get uiChooseDifferentReports => 'বিভিন্ন রিপোর্ট চয়ন করুন';

  @override
  String get uiEarlierReport => 'আগের রিপোর্ট';

  @override
  String get uiLaterReport => 'পরে রিপোর্ট';

  @override
  String get uiYourReportPages => 'আপনার রিপোর্ট পাতা';

  @override
  String get uiKeepPagesInTheSameOrderAs =>
      'প্রতিবেদনের মতো একই ক্রমে পৃষ্ঠাগুলি রাখুন।';

  @override
  String get uiAddAnotherPage => 'অন্য পৃষ্ঠা যোগ করুন';

  @override
  String get uiChoosePagesFromGallery => 'গ্যালারি থেকে পৃষ্ঠাগুলি চয়ন করুন';

  @override
  String get uiAdjustPage => 'পৃষ্ঠা সামঞ্জস্য করুন';

  @override
  String get uiRetake => 'পুনরায় গ্রহণ করুন';

  @override
  String get uiUseAdjustedPage => 'সমন্বয় পৃষ্ঠা ব্যবহার করুন';

  @override
  String get uiResetChanges => 'পরিবর্তন রিসেট করুন';

  @override
  String get uiKeepEveryResultInsideTheCorners =>
      'প্রতিটি ফলাফল কোণার ভিতরে রাখুন।';

  @override
  String get uiRotate => 'ঘোরান';

  @override
  String get uiReportRestored => 'রিপোর্ট পুনরুদ্ধার করা হয়েছে';

  @override
  String get uiDeleteReportPermanently => 'স্থায়ীভাবে রিপোর্ট মুছে ফেলবেন?';

  @override
  String get uiDeletePermanently => 'স্থায়ীভাবে মুছে ফেলুন';

  @override
  String get uiReportPermanentlyDeleted =>
      'রিপোর্ট স্থায়ীভাবে মুছে ফেলা হয়েছে';

  @override
  String get uiEmptyRecycleBin => 'খালি রিসাইকেল বিন?';

  @override
  String get uiDeleteAll => 'সব মুছে দিন';

  @override
  String get uiRecycleBinIsEmpty => 'রিসাইকেল বিন খালি।';

  @override
  String get uiDeletedReportsWillAppearHereBeforeRemoval =>
      'মুছে ফেলা রিপোর্ট অপসারণের আগে এখানে প্রদর্শিত হবে.';

  @override
  String get uiEmptyRecycleBind657e2 => 'খালি রিসাইকেল বিন';

  @override
  String get uiCheckDetectedResult => 'শনাক্ত ফলাফল পরীক্ষা করুন';

  @override
  String get uiCompareThisRowWithTheOriginalReport =>
      'মূল প্রতিবেদনের সাথে এই সারির তুলনা করুন। সংরক্ষণ করার আগে কোনো OCR ভুল সংশোধন করুন।';

  @override
  String get uiICheckedThisResultAgainstTheOriginal =>
      'আমি মূল প্রতিবেদনের বিপরীতে এই ফলাফলটি পরীক্ষা করেছি';

  @override
  String get uiSaving => 'সংরক্ষণ করা হচ্ছে...';

  @override
  String get uiSaveVerifiedResult => 'যাচাইকৃত ফলাফল সংরক্ষণ করুন';

  @override
  String get uiNoResultsWereDetectedViewTheOriginal =>
      'কোন ফলাফল সনাক্ত করা হয়নি. মূল রিপোর্ট দেখুন বা প্রক্রিয়াকরণ পুনরায় চেষ্টা করুন.';

  @override
  String get uiDetectedValuesNeedToBeCheckedAgainst =>
      'সংরক্ষিত ফলাফল হওয়ার আগে সনাক্ত করা মানগুলি মূল রিপোর্টের বিরুদ্ধে পরীক্ষা করা দরকার।';

  @override
  String get uiSomeRowsMayBeMissingInspectThe =>
      'কিছু সারি অনুপস্থিত হতে পারে. সম্পূর্ণ মূল রিপোর্ট পরিদর্শন করুন.';

  @override
  String get uiResult => 'ফলাফল';

  @override
  String get uiUnitOptional => 'ইউনিট (ঐচ্ছিক)';

  @override
  String get uiReferenceRangeOptional => 'রেফারেন্স পরিসীমা (ঐচ্ছিক)';

  @override
  String get uiVerified => 'যাচাই করা হয়েছে';

  @override
  String get uiGiftVoucher => 'গিফট ভাউচার';

  @override
  String get uiRedeemAGiftVoucherAndAddCredits =>
      'একটি উপহার ভাউচার রিডিম করুন এবং সরাসরি আপনার ব্যালেন্সে ক্রেডিট যোগ করুন।';

  @override
  String get uiCurrentPlan => 'বর্তমান পরিকল্পনা';

  @override
  String get uiCreditBalance => 'ক্রেডিট ব্যালেন্স';

  @override
  String get uiPlanLimits => 'পরিকল্পনা সীমা';

  @override
  String get uiBuyCredits => 'ক্রেডিট কিনুন';

  @override
  String get uiRecentBillingActivity => 'সাম্প্রতিক বিলিং কার্যকলাপ';

  @override
  String get uiRefreshStatus => 'স্থিতি রিফ্রেশ করুন';

  @override
  String get uiNoRecentOrdersYet => 'কোন সাম্প্রতিক আদেশ এখনো.';

  @override
  String get uiVoucherCode => 'ভাউচার কোড';

  @override
  String get uiCheckout => 'চেকআউট';

  @override
  String get uiApply => 'আবেদন করুন';

  @override
  String get uiClear => 'পরিষ্কার';

  @override
  String get uiPay => 'বেতন';

  @override
  String get uiNoCreditPacksAvailableAtThisTime =>
      'এই সময়ে কোন ক্রেডিট প্যাক উপলব্ধ.';

  @override
  String get uiBuy => 'কিনুন';

  @override
  String get uiRetryPayment => 'আবার পেমেন্ট করার চেষ্টা করুন';

  @override
  String get uiPromoCode => 'প্রচার কোড';

  @override
  String get uiEnterPromoCode => 'প্রচার কোড লিখুন';

  @override
  String get uiChooseAPlan => 'একটি পরিকল্পনা চয়ন করুন';

  @override
  String get uiNoPlansAvailableAtThisTime => 'এই সময়ে উপলব্ধ কোন পরিকল্পনা.';

  @override
  String get uiHaveAPromoCode => 'একটি প্রচার কোড আছে?';

  @override
  String get uiCURRENTPLAN => 'বর্তমান পরিকল্পনা';

  @override
  String get uiManageNotifications => 'বিজ্ঞপ্তিগুলি পরিচালনা করুন';

  @override
  String get uiAll => 'সব';

  @override
  String get uiUnread => 'অপঠিত';

  @override
  String get uiAccessStopsImmediatelyYouCanSignIn =>
      'অ্যাক্সেস অবিলম্বে বন্ধ. আপনি 30 দিনের মধ্যে সাইন ইন এবং পুনরুদ্ধার করতে পারেন। এর পরে, আপনার অ্যাকাউন্ট এবং সঞ্চিত ফাইলগুলি সক্রিয় সঞ্চয়স্থান থেকে মুছে ফেলা হয়।';

  @override
  String get uiCloseMyAccount => 'আমার অ্যাকাউন্ট বন্ধ করুন';

  @override
  String get uiYourRecordsStayInDoclyzer => 'আপনার রেকর্ড ডকলাইজারে থাকে।';

  @override
  String get uiTakeACopyOfYourRecords => 'আপনার রেকর্ডের একটি কপি নিন।';

  @override
  String get uiWhoseRecords => 'কার রেকর্ড?';

  @override
  String get uiCouldNotLoadProfiles => 'প্রোফাইল লোড করা যায়নি';

  @override
  String get uiLoadingProfiles => 'প্রোফাইল লোড হচ্ছে...';

  @override
  String get uiAllProfiles => 'সমস্ত প্রোফাইল';

  @override
  String get uiDateRange => 'তারিখ পরিসীমা';

  @override
  String get uiUseAllDates => 'সব তারিখ ব্যবহার করুন';

  @override
  String get uiINCLUDEINTHISEXPORT => 'এই রপ্তানি অন্তর্ভুক্ত';

  @override
  String get uiOriginalReports => 'মূল প্রতিবেদন';

  @override
  String get uiPDFsAndImagesYouUploaded => 'আপনার আপলোড করা PDF এবং ছবি';

  @override
  String get uiTestResults => 'পরীক্ষার ফলাফল';

  @override
  String get uiResultsAsCSVWithTheirReviewState =>
      'CSV হিসাবে ফলাফল, তাদের পর্যালোচনা অবস্থা সহ';

  @override
  String get uiExportsContainPersonalInformationStoreThemSomewhere =>
      'রপ্তানিতে ব্যক্তিগত তথ্য থাকে। আপনার বিশ্বাসের জায়গায় সেগুলি সংরক্ষণ করুন।';

  @override
  String get uiDeleteAccount => 'অ্যাকাউন্ট মুছুন';

  @override
  String get uiContinueToDeletion => 'মুছে ফেলা অবিরত';

  @override
  String get uiKeepMyAccount => 'আমার হিসাব রাখুন';

  @override
  String get uiBeforeYouLeave => 'যাওয়ার আগে';

  @override
  String get uiPleaseReadWhatThisWillRemove =>
      'এটি কি অপসারণ করবে অনুগ্রহ করে পড়ুন।';

  @override
  String get uiDeletingYourAccountAffectsAllProfilesYou =>
      'আপনার অ্যাকাউন্ট মুছে ফেলা আপনার পরিচালনা করা সমস্ত প্রোফাইলকে প্রভাবিত করে৷';

  @override
  String get uiYourAccountAndPersonalProfile =>
      'আপনার অ্যাকাউন্ট এবং ব্যক্তিগত প্রোফাইল';

  @override
  String get uiAccessThroughYourSharedLinks =>
      'আপনার শেয়ার করা লিঙ্কের মাধ্যমে অ্যাক্সেস করুন';

  @override
  String get uiKeepACopyFirst => 'প্রথমে একটি কপি রাখুন';

  @override
  String get uiExportTheInformationYouWantToRetain =>
      'আপনি যে তথ্য রাখতে চান তা রপ্তানি করুন।';

  @override
  String get uiExportData => 'ডেটা রপ্তানি করুন';

  @override
  String get uiAccessStopsImmediatelyYouCanRestoreWithin =>
      'অ্যাক্সেস অবিলম্বে বন্ধ. আপনি 30 দিনের মধ্যে পুনরুদ্ধার করতে পারেন। এর পরে, আপনার ডেটা সক্রিয় স্টোরেজ থেকে সরানো হয়।';

  @override
  String get uiAccountPendingDeletion => 'অ্যাকাউন্ট মুলতুবি মোছা';

  @override
  String get uiRestoreMyAccount => 'আমার অ্যাকাউন্ট পুনরুদ্ধার করুন';

  @override
  String get uiDownloadACopyOfYourAccountData =>
      'আপনার প্রোফাইল, প্রোফাইল এবং সম্মতি রেকর্ড সহ আপনার অ্যাকাউন্ট ডেটার একটি অনুলিপি ডাউনলোড করুন।';

  @override
  String get uiYourAccountIsDisabledImmediatelyYouCan =>
      'আপনার অ্যাকাউন্ট অবিলম্বে নিষ্ক্রিয় করা হয়. আপনি 30 দিনের মধ্যে এটি পুনরুদ্ধার করতে পারেন। এর পরে, আপনার ডেটা স্থায়ীভাবে মুছে ফেলা হয়।';

  @override
  String get uiCurrentPassword => 'বর্তমান পাসওয়ার্ড';

  @override
  String get uiCouldNotChangeAppLockTryAgain =>
      'অ্যাপ লক পরিবর্তন করা যায়নি। আবার চেষ্টা করুন';

  @override
  String get uiYourRecordsYourChoiceToShare =>
      'আপনার রেকর্ড.\nশেয়ার করার জন্য আপনার পছন্দ।';

  @override
  String get uiReviewAccessWheneverYouNeed =>
      'আপনি যখনই প্রয়োজন অ্যাক্সেস পর্যালোচনা করুন.';

  @override
  String get uiAppLock => 'অ্যাপ লক';

  @override
  String get uiUseYourDeviceSBiometricOrPasscode =>
      'আপনার ডিভাইসের বায়োমেট্রিক বা পাসকোড লক ব্যবহার করুন।';

  @override
  String get uiNotificationPreviews => 'বিজ্ঞপ্তির পূর্বরূপ';

  @override
  String get uiControlLockScreenPreviewsInYourDevice =>
      'আপনার ডিভাইস সেটিংসে লক-স্ক্রিন প্রিভিউ নিয়ন্ত্রণ করুন।';

  @override
  String get uiContactSupport => 'সহায়তার সাথে যোগাযোগ করুন';

  @override
  String get uiAttachReportsOnlyIfYouChooseTo =>
      'আপনি যদি চয়ন করেন শুধুমাত্র রিপোর্ট সংযুক্ত করুন.';

  @override
  String get uiWhatCanWeHelpYouWith => 'আমরা আপনাকে কি সাহায্য করতে পারি?';

  @override
  String get uiPOPULARQUESTIONS => 'জনপ্রিয় প্রশ্ন';

  @override
  String get uiNoHelpArticlesMatchYourSearch =>
      'কোনো সাহায্য নিবন্ধ আপনার অনুসন্ধান মেলে না.';

  @override
  String get uiForQuestionsAboutYourHealthOrTest =>
      'আপনার স্বাস্থ্য বা পরীক্ষার ফলাফল সম্পর্কে প্রশ্নগুলির জন্য, একজন যোগ্যতাসম্পন্ন স্বাস্থ্যসেবা পেশাদারের সাথে কথা বলুন।';

  @override
  String get uiYourReportsAClearerPicture => 'আপনার রিপোর্ট. আরও পরিষ্কার ছবি।';

  @override
  String get uiKeepYourHealthHistoryTogether =>
      'আপনার স্বাস্থ্যের ইতিহাস একসাথে রাখুন।';

  @override
  String get uiStoreReportsReviewResultsFollowChangesAnd =>
      'প্রতিবেদন সংরক্ষণ করুন, ফলাফল পর্যালোচনা করুন, পরিবর্তনগুলি অনুসরণ করুন এবং আপনার চিকিত্সকের সাথে ভাগ করুন।';

  @override
  String get uiEducationalInformationOnly => 'শুধুমাত্র শিক্ষাগত তথ্য';

  @override
  String get uiSearchHelpArticles => 'সাহায্য নিবন্ধ অনুসন্ধান করুন';

  @override
  String get uiOpenTheDeviceSettingsAppToChange =>
      'বিজ্ঞপ্তি অ্যাক্সেস পরিবর্তন করতে ডিভাইস সেটিংস অ্যাপ খুলুন।';

  @override
  String get uiSavePreferences => 'পছন্দগুলি সংরক্ষণ করুন';

  @override
  String get uiDevicePermissionsCanBeChangedInSettings =>
      'সেটিংসে গিয়ে ডিভাইসের অনুমতি পরিবর্তন করা যেতে পারে।';

  @override
  String get uiGetReportUpdatesOnThisDevice => 'এই ডিভাইসে রিপোর্ট আপডেট পান';

  @override
  String get uiAllowNotificationsToKnowWhenAReport =>
      'একটি প্রতিবেদন প্রস্তুত হলে বিজ্ঞপ্তিগুলিকে জানার অনুমতি দিন৷ বিপণন নীচে একটি পৃথক পছন্দ.';

  @override
  String get uiREPORTACTIVITY => 'রিপোর্ট কার্যকলাপ';

  @override
  String get uiReportActivitySettingsRequireTheLatestServer =>
      'রিপোর্ট কার্যকলাপ সেটিংস সর্বশেষ সার্ভার সংস্করণ প্রয়োজন.';

  @override
  String get uiSensitiveLockScreenPreviews => 'সংবেদনশীল লক-স্ক্রিন পূর্বরূপ';

  @override
  String get uiReportNamesAndPersonalDetailsAreAlways =>
      'রিপোর্টের নাম এবং ব্যক্তিগত বিবরণ সবসময় লুকানো হয়.';

  @override
  String get uiOTHERMESSAGES => 'অন্যান্য বার্তা';

  @override
  String get uiKeepEachPersonSReportsAndTrends =>
      'প্রতিটি ব্যক্তির রিপোর্ট এবং প্রবণতা একসাথে রাখুন।';

  @override
  String get uiPersonDetails => 'ব্যক্তির বিবরণ';

  @override
  String get uiDateOfBirth => 'জন্ম তারিখ';

  @override
  String get uiRelationship => 'সম্পর্ক';

  @override
  String get uiEnterAName => 'একটি নাম লিখুন';

  @override
  String get uiClearDateOfBirth => 'জন্ম তারিখ পরিষ্কার করুন';

  @override
  String get uiOptionalEGParentOrChild => 'ঐচ্ছিক, যেমন পিতামাতা বা সন্তান';

  @override
  String get uiInviteFriendsEarnCredits =>
      'বন্ধুদের আমন্ত্রণ জানান, ক্রেডিট উপার্জন করুন';

  @override
  String get uiShareYourCodeAndFollowEachInvite =>
      'আপনার কোড শেয়ার করুন এবং পুরস্কার আনলক হিসাবে প্রতিটি আমন্ত্রণ অনুসরণ করুন।';

  @override
  String get uiYOURREFERRALCODE => 'আপনার রেফারেল কোড';

  @override
  String get uiShareInvite => 'আমন্ত্রণ শেয়ার করুন';

  @override
  String get uiCopyCode => 'কোড কপি করুন';

  @override
  String get uiHaveACode => 'একটি কোড আছে?';

  @override
  String get uiEnterACodeSharedWithYouTo =>
      'আপনার আমন্ত্রণ পুরষ্কার দাবি করতে আপনার সাথে শেয়ার করা একটি কোড লিখুন৷';

  @override
  String get uiHowRewardsWork => 'পুরস্কার কিভাবে কাজ করে';

  @override
  String get uiNoFriendsReferredYet => 'এখনো কোন বন্ধু উল্লেখ করা হয়নি';

  @override
  String get uiShareYourInviteToSeeTheirProgress =>
      'এখানে তাদের অগ্রগতি দেখতে আপনার আমন্ত্রণ ভাগ করুন.';

  @override
  String get uiReferralCode => 'রেফারেল কোড';

  @override
  String get uiSetNewPassword => 'নতুন পাসওয়ার্ড সেট করুন';

  @override
  String get uiEnterTheResetTokenFromTheLink =>
      'আপনার ইমেলের লিঙ্ক থেকে রিসেট টোকেন এবং আপনার নতুন পাসওয়ার্ড লিখুন।';

  @override
  String get uiResetPassword => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get uiBackToLogin => 'লগইন এ ফিরে যান';

  @override
  String get uiResetToken => 'টোকেন রিসেট করুন';

  @override
  String get uiNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get uiEnterTheEmailAddressAssociatedWithYour =>
      'আপনার অ্যাকাউন্টের সাথে যুক্ত ইমেল ঠিকানা লিখুন এবং আমরা আপনার পাসওয়ার্ড পুনরায় সেট করার জন্য আপনাকে একটি লিঙ্ক পাঠাব।';

  @override
  String get uiSendResetLink => 'রিসেট লিঙ্ক পাঠান';

  @override
  String get uiRevokeSession => 'সেশন প্রত্যাহার করবেন?';

  @override
  String get uiCurrentSession => 'বর্তমান অধিবেশন';

  @override
  String get uiSkip => 'এড়িয়ে যান';

  @override
  String get uiChangePassword => 'পাসওয়ার্ড পরিবর্তন করুন';

  @override
  String get uiEnterYourCurrentPasswordAndChooseA =>
      'আপনার বর্তমান পাসওয়ার্ড লিখুন এবং একটি নতুন একটি চয়ন করুন.';

  @override
  String get uiNewPasswordd850ee => 'নতুন পাসওয়ার্ড';

  @override
  String get uiConfirmNewPassword => 'নতুন পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get uiGettingThingsReady => 'জিনিস প্রস্তুত করা হচ্ছে...';

  @override
  String get uiLinkAccessHistory => 'লিঙ্ক অ্যাক্সেস ইতিহাস';

  @override
  String get uiNoAccessEventsYet => 'এখনও কোনো অ্যাক্সেস ইভেন্ট.';

  @override
  String get uiDefaultShareLinkExpiry => 'ডিফল্ট শেয়ার লিঙ্ক মেয়াদ শেষ';

  @override
  String get uiSave => 'সংরক্ষণ করুন';

  @override
  String get uiReviewSharing => 'শেয়ারিং পর্যালোচনা করুন';

  @override
  String get uiCheckThePersonReportsAndAccess =>
      'ব্যক্তি, রিপোর্ট এবং অ্যাক্সেস পরীক্ষা করুন.';

  @override
  String get uiEditSelectionOrAccessSettings =>
      'নির্বাচন বা অ্যাক্সেস সেটিংস সম্পাদনা করুন';

  @override
  String get uiRevokeShareLink => 'শেয়ার লিঙ্ক প্রত্যাহার করবেন?';

  @override
  String get uiThisLinkWillStopWorkingYouCan =>
      'এই লিঙ্কটি কাজ করা বন্ধ করবে। আপনি একটি নতুন তৈরি করতে পারেন.';

  @override
  String get uiShareLinkReady => 'শেয়ার লিঙ্ক প্রস্তুত';

  @override
  String get uiAccessCodeShareSeparately =>
      'অ্যাক্সেস কোড - আলাদাভাবে ভাগ করুন';

  @override
  String get uiCopyAccessCode => 'অ্যাক্সেস কোড কপি করুন';

  @override
  String get uiThisCodeCouldNotBeSavedOn =>
      'এই কোড এই ডিভাইসে সংরক্ষণ করা যাবে না. পরে ব্যবহারের জন্য এটি এখন কপি করুন।';

  @override
  String get uiShareLink => 'লিঙ্ক শেয়ার করুন';

  @override
  String get uiCopyLink => 'লিঙ্ক কপি করুন';

  @override
  String get uiRevokeLink => 'লিঙ্ক প্রত্যাহার করুন';

  @override
  String get uiCodeUnavailableOnThisDeviceUseThe =>
      'এই ডিভাইসে কোড অনুপলব্ধ. সংরক্ষিত কোড ব্যবহার করুন বা একটি নতুন লিঙ্ক তৈরি করুন।';

  @override
  String get uiActiveSharedLinks => 'সক্রিয় শেয়ার করা লিঙ্ক';

  @override
  String get uiShare => 'শেয়ার করুন';

  @override
  String get uiCreateANewShareLink => 'একটি নতুন শেয়ার লিঙ্ক তৈরি করুন';

  @override
  String get uiIncludeCurrentAndFutureReportsForThis =>
      'এই প্রোফাইলের জন্য বর্তমান এবং ভবিষ্যতের প্রতিবেদন অন্তর্ভুক্ত করুন।';

  @override
  String get uiChooseReports => 'রিপোর্ট নির্বাচন করুন';

  @override
  String get uiShareOnlyTheReportsSelectedBelow =>
      'শুধুমাত্র নীচে নির্বাচিত রিপোর্ট শেয়ার করুন.';

  @override
  String get uiSelectAll => 'সব নির্বাচন করুন';

  @override
  String get uiNoReviewedReportsAreAvailableToShare =>
      'শেয়ার করার জন্য কোনো পর্যালোচনা করা প্রতিবেদন পাওয়া যায় না।';

  @override
  String get uiSelectedTestResults => 'নির্বাচিত পরীক্ষার ফলাফল';

  @override
  String get uiIncludeOnlyTheResultsYouChooseFrom =>
      'শুধুমাত্র এই রিপোর্ট থেকে আপনি যে ফলাফলগুলি বেছে নিন তা অন্তর্ভুক্ত করুন।';

  @override
  String get uiNoSavedTestResultsAreAvailableIn =>
      'এই রিপোর্টগুলিতে কোনও সংরক্ষিত পরীক্ষার ফলাফল পাওয়া যায় না।';

  @override
  String get uiUpgradeOrManage => 'আপগ্রেড বা পরিচালনা করুন';

  @override
  String get uiExpiry => 'মেয়াদ শেষ:';

  @override
  String get uiRequireAnAccessCode => 'একটি অ্যাক্সেস কোড প্রয়োজন';

  @override
  String get uiShareTheCodeSeparatelyFromTheLink =>
      'লিঙ্ক থেকে আলাদাভাবে কোড শেয়ার করুন.';

  @override
  String get uiTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get uiClearExpiry => 'সাফ মেয়াদ শেষ';

  @override
  String get onboardingStoreEyebrow => '01 / সংরক্ষণ করুন';

  @override
  String get onboardingStoreTitle => 'প্রতিটি রিপোর্ট,\nএকটি পরিচিত জায়গা।';

  @override
  String get onboardingStoreBody =>
      'পিডিএফ এবং ফটো একসাথে রাখুন, আপনার জন্য এবং আপনি যাদের যত্ন নেন তাদের জন্য।';

  @override
  String get onboardingUnderstandEyebrow => '02/ বুঝুন';

  @override
  String get onboardingUnderstandTitle => 'সংখ্যা,\nপড়া সহজ করে তোলে.';

  @override
  String get onboardingUnderstandBody =>
      'আপনার রিপোর্ট থেকে প্রতিটি পরীক্ষা, এর ইউনিট এবং ব্যবধান দেখুন। যে কোনো সময় মূল চেক করুন.';

  @override
  String get onboardingTrackEyebrow => '03 / ট্র্যাক এবং শেয়ার করুন';

  @override
  String get onboardingTrackTitle =>
      'পরিবর্তনগুলি দেখুন।\nপ্রসঙ্গটি শেয়ার করুন।';

  @override
  String get onboardingTrackBody =>
      'সময়ের সাথে ফলাফলগুলি অনুসরণ করুন এবং আপনার চিকিত্সক ঠিক কী দেখতে পাবেন তা চয়ন করুন।';

  @override
  String get onboardingNext => 'পরবর্তী';

  @override
  String get onboardingGetStarted => 'শুরু করুন';

  @override
  String get uiSupportRequestSent => 'সমর্থন অনুরোধ পাঠানো হয়েছে.';

  @override
  String get uiTestNameAndResultAreRequired =>
      'পরীক্ষার নাম এবং ফলাফল প্রয়োজন.';

  @override
  String get uiUseAValidCollectionDateInYYYY =>
      'YYYY-MM-DD ফর্ম্যাটে একটি বৈধ সংগ্রহের তারিখ ব্যবহার করুন৷';

  @override
  String get uiCouldNotSaveThisCorrectionTryAgain =>
      'এই সংশোধন সংরক্ষণ করা যায়নি. আবার চেষ্টা করুন';

  @override
  String get uiReportsUnavailable => 'রিপোর্ট পাওয়া যাচ্ছে না';

  @override
  String get uiTryAgain042c86 => 'আবার চেষ্টা করুন';

  @override
  String get uiTwoReportsAreNeeded => 'দুটি রিপোর্ট দরকার';

  @override
  String get uiAddAnOlderReportForThisProfile =>
      'ফলাফল তুলনা করতে এই প্রোফাইলের জন্য একটি পুরানো প্রতিবেদন যোগ করুন।';

  @override
  String get uiCannotCompareYet => 'এখনো তুলনা করা যায় না';

  @override
  String get uiTheseReportsHaveNoMatchingResultsAvailable =>
      'তুলনা করার জন্য এই রিপোর্টগুলির কোন মিল পাওয়া ফলাফল নেই।';

  @override
  String get uiUnableToLoadReportsTryAgain =>
      'রিপোর্ট লোড করতে অক্ষম. আবার চেষ্টা করুন';

  @override
  String get uiCouldNotOpenPhotosOrCamera => 'ফটো বা ক্যামেরা খুলতে পারেনি।';

  @override
  String get uiCouldNotOpenCamera => 'ক্যামেরা খুলতে পারেনি।';

  @override
  String get uiCouldNotPrepareThesePagesRetakeAn =>
      'এই পৃষ্ঠাগুলি প্রস্তুত করা যায়নি। একটি অপঠিত পৃষ্ঠা আবার নিন এবং আবার চেষ্টা করুন৷';

  @override
  String get uiCouldNotAdjustThisPage => 'এই পৃষ্ঠাটি সামঞ্জস্য করা যায়নি৷';

  @override
  String get uiNoChartableResultYet => 'এখনো কোনো চার্টেবল ফলাফল নেই';

  @override
  String get uiProfiles => 'প্রোফাইল';

  @override
  String get uiReports => 'রিপোর্ট';

  @override
  String get uiShareLinks => 'লিঙ্ক শেয়ার করুন';

  @override
  String get uiAIChat => 'এআই চ্যাট';

  @override
  String get uiFailedToLoadEntitlementSummaryPleaseTry =>
      'এনটাইটেলমেন্টের সারাংশ লোড করা যায়নি। আবার চেষ্টা করুন.';

  @override
  String get uiFailedToRefreshBillingStatusPleaseTry =>
      'বিলিং স্থিতি রিফ্রেশ করতে ব্যর্থ হয়েছে৷ আবার চেষ্টা করুন.';

  @override
  String get uiReceiptDownloadWillBeAvailableSoon =>
      'রসিদ ডাউনলোড শীঘ্রই উপলব্ধ হবে.';

  @override
  String get uiSubtotal => 'সাবটোটাল';

  @override
  String get uiDiscount => 'ছাড়';

  @override
  String get uiTotal => 'মোট';

  @override
  String get uiFailedToLoadCreditPacksPleaseTry =>
      'ক্রেডিট প্যাকগুলি লোড করতে ব্যর্থ হয়েছে৷ আবার চেষ্টা করুন.';

  @override
  String get uiAPaymentIsPendingCaptureRefreshStatus =>
      'একটি পেমেন্ট ক্যাপচার মুলতুবি আছে. অন্য চেকআউট শুরু করার আগে স্থিতি রিফ্রেশ করুন।';

  @override
  String get uiCreditsWereAppliedSuccessfully =>
      'ক্রেডিট সফলভাবে প্রয়োগ করা হয়েছে.';

  @override
  String get uiFailedToCreateOrderPleaseTryAgain =>
      'অর্ডার তৈরি করতে ব্যর্থ হয়েছে৷ আবার চেষ্টা করুন.';

  @override
  String get uiPaymentReceivedAwaitingServerReconciliationBeforeCredits =>
      'পেমেন্ট প্রাপ্ত. ক্রেডিট যোগ করার আগে সার্ভার পুনর্মিলনের জন্য অপেক্ষা করা হচ্ছে।';

  @override
  String get uiPaymentFailedYouCanRetryCheckoutWhen =>
      'পেমেন্ট ব্যর্থ হয়েছে. প্রস্তুত হলে আপনি চেকআউট পুনরায় চেষ্টা করতে পারেন।';

  @override
  String get uiPaymentFailedTryAgain =>
      'পেমেন্ট ব্যর্থ হয়েছে. আবার চেষ্টা করুন';

  @override
  String get uiCreditsAdded => 'ক্রেডিট যোগ করা হয়েছে!';

  @override
  String get uiPromoCodeApplied => 'প্রচার কোড প্রয়োগ করা হয়েছে।';

  @override
  String get uiPaymentReceivedButThisOrderIsPending =>
      'পেমেন্ট প্রাপ্ত হয়েছে, কিন্তু এই আদেশ পর্যালোচনা মুলতুবি আছে.';

  @override
  String get uiPaymentFailedDuringReconciliation =>
      'পুনর্মিলনের সময় পেমেন্ট ব্যর্থ হয়েছে।';

  @override
  String get uiPaymentConfirmedServerReconciliationIsStillPending =>
      'পেমেন্ট নিশ্চিত করা হয়েছে. সার্ভার পুনর্মিলন এখনও মুলতুবি আছে.';

  @override
  String get uiPaymentVerifiedReconciliationIsPendingPleaseRefresh =>
      'পেমেন্ট যাচাই করা হয়েছে। পুনর্মিলন মুলতুবি আছে, দয়া করে শীঘ্রই রিফ্রেশ করুন।';

  @override
  String get uiPaymentReceivedButVerificationIsStillPending =>
      'অর্থপ্রদান গৃহীত হয়েছে কিন্তু যাচাইকরণ এখনও বাকি আছে। অবস্থা রিফ্রেশ করুন.';

  @override
  String get uiFailedToLoadPlansPleaseTryAgain =>
      'প্ল্যান লোড করতে ব্যর্থ হয়েছে৷ আবার চেষ্টা করুন.';

  @override
  String get uiFailedToCreateSubscriptionPleaseTryAgain =>
      'সদস্যতা তৈরি করতে ব্যর্থ হয়েছে৷ আবার চেষ্টা করুন.';

  @override
  String get uiSubscriptionFailedTryAgain =>
      'সদস্যতা ব্যর্থ হয়েছে. আবার চেষ্টা করুন';

  @override
  String get uiPlanUpgraded => 'পরিকল্পনা আপগ্রেড!';

  @override
  String get uiPaymentReceivedButVerificationFailedPlanWill =>
      'পেমেন্ট গৃহীত কিন্তু যাচাই ব্যর্থ হয়েছে. পরিকল্পনা শীঘ্রই আপগ্রেড করা হবে.';

  @override
  String get uiNotificationsUnavailable => 'বিজ্ঞপ্তি অনুপলব্ধ';

  @override
  String get uiAllQuietForNow => 'আপাতত সব চুপচাপ।';

  @override
  String get uiReportUpdatesAndSharingRemindersWillAppear =>
      'নতুন কিছু হলে রিপোর্ট আপডেট এবং শেয়ার করার অনুস্মারক এখানে উপস্থিত হবে।';

  @override
  String get uiNoUnreadUpdates => 'কোন অপঠিত আপডেট';

  @override
  String get uiYouReAllCaughtUp => 'আপনি সব ধরা আছে.';

  @override
  String get uiUnableToLoadNotificationsTryAgainWhen =>
      'বিজ্ঞপ্তি লোড করতে অক্ষম। সংযুক্ত হলে আবার চেষ্টা করুন।';

  @override
  String get uiManageSharedLinks => 'শেয়ার করা লিঙ্কগুলি পরিচালনা করুন';

  @override
  String get uiExportYourData => 'আপনার ডেটা রপ্তানি করুন';

  @override
  String get uiReadThePrivacyPolicy => 'গোপনীয়তা নীতি পড়ুন';

  @override
  String get uiTermsOfUse => 'ব্যবহারের শর্তাবলী';

  @override
  String get uiPrivacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get uiDateOfBirthOptional => 'জন্ম তারিখ, ঐচ্ছিক';

  @override
  String get uiRelationshipMustBe50CharactersOrFewer =>
      'সম্পর্ক অবশ্যই 50 অক্ষর বা তার কম হতে হবে।';

  @override
  String get uiFailedToSaveProfilePleaseTryAgain =>
      'প্রোফাইল সংরক্ষণ করতে ব্যর্থ হয়েছে. আবার চেষ্টা করুন.';

  @override
  String get uiReferralsUnavailable => 'রেফারেল অনুপলব্ধ';

  @override
  String get uiYourRewards => 'আপনার পুরস্কার';

  @override
  String get uiReferralProgress => 'রেফারেল অগ্রগতি';

  @override
  String get uiFriendsReferred => 'বন্ধুদের উল্লেখ';

  @override
  String get uiCreditsEarned => 'ক্রেডিট অর্জিত';

  @override
  String get uiPendingRewards => 'মুলতুবি পুরস্কার';

  @override
  String get uiBlockedRewards => 'ব্লক করা পুরস্কার';

  @override
  String get uiInviteeBonus => 'আমন্ত্রিত বোনাস';

  @override
  String get uiFirstAnalysis => 'প্রথম বিশ্লেষণ';

  @override
  String get uiFirstPurchase => 'প্রথম ক্রয়';

  @override
  String get uiMonthlyCap => 'মাসিক ক্যাপ';

  @override
  String get uiFailedToLoadReferralsPleaseTryAgain =>
      'রেফারেল লোড করতে ব্যর্থ হয়েছে. আবার চেষ্টা করুন.';

  @override
  String get uiReferralCodeCopied => 'রেফারেল কোড কপি করা হয়েছে।';

  @override
  String get uiEnterTheResetTokenFromYourEmail =>
      'আপনার ইমেল লিঙ্ক থেকে রিসেট টোকেন লিখুন';

  @override
  String get uiEnterYourNewPassword => 'আপনার নতুন পাসওয়ার্ড লিখুন';

  @override
  String get uiUnableToResetPasswordPleaseRequestA =>
      'পাসওয়ার্ড রিসেট করতে অক্ষম। একটি নতুন লিঙ্ক অনুরোধ করুন.';

  @override
  String get uiEnterYourEmailAddress => 'আপনার ইমেইল ঠিকানা লিখুন';

  @override
  String get uiUnableToSendResetLinkPleaseTry =>
      'রিসেট লিঙ্ক পাঠাতে অক্ষম. আবার চেষ্টা করুন.';

  @override
  String get uiFailedToLoadSessions => 'সেশনগুলি লোড করতে ব্যর্থ হয়েছে৷';

  @override
  String get uiFailedToRevokeSession =>
      'অধিবেশন প্রত্যাহার করতে ব্যর্থ হয়েছে.';

  @override
  String get uiUnableToChangePasswordPleaseTryAgain =>
      'পাসওয়ার্ড পরিবর্তন করতে অক্ষম. আবার চেষ্টা করুন.';

  @override
  String get uiOpenDeviceSettingsAndAllowNotificationsFor =>
      'ডিভাইস সেটিংস খুলুন এবং Doclyzer-এর জন্য বিজ্ঞপ্তির অনুমতি দিন।';

  @override
  String get uiReportsCouldNotBeLoadedTryAgain =>
      'রিপোর্ট লোড করা যায়নি. আবার চেষ্টা করুন';

  @override
  String get uiTestResultsCouldNotBeLoadedTry =>
      'পরীক্ষার ফলাফল লোড করা যায়নি. আবার চেষ্টা করুন';

  @override
  String get uiSelectAtLeastOneReportToShare =>
      'শেয়ার করার জন্য অন্তত একটি রিপোর্ট নির্বাচন করুন।';

  @override
  String get uiSelectAtLeastOneTestResultTo =>
      'শেয়ার করার জন্য কমপক্ষে একটি পরীক্ষার ফলাফল নির্বাচন করুন।';

  @override
  String get uiLinkCopiedToClipboard => 'ক্লিপবোর্ডে লিঙ্ক কপি করা হয়েছে';

  @override
  String get uiAccessCodeCopiedToClipboard =>
      'অ্যাক্সেস কোড ক্লিপবোর্ডে অনুলিপি করা হয়েছে৷';

  @override
  String get uiOnePerson => '1 জন';

  @override
  String uiPeopleCount(String count) {
    return '$count মানুষ';
  }

  @override
  String uiActionsFor(String name) {
    return '$name এর জন্য অ্যাকশন';
  }

  @override
  String uiUnableToSwitchProfilesDetail(String message) {
    return 'প্রোফাইল স্যুইচ করতে অক্ষম. $message';
  }

  @override
  String uiSwitchedTo(String name) {
    return '$name এ স্যুইচ করা হয়েছে';
  }

  @override
  String get uiAnalyzeOnePage => '1 পৃষ্ঠা বিশ্লেষণ করুন';

  @override
  String uiAnalyzePages(String count) {
    return '$count পৃষ্ঠাগুলি বিশ্লেষণ করুন';
  }

  @override
  String get uiDragPagesIntoOrder =>
      'আপনার প্রতিবেদনে দেখানো ক্রমটিতে পৃষ্ঠাগুলি টেনে আনুন';

  @override
  String get uiCheckEveryPage =>
      'বিশ্লেষণ করার আগে প্রতিটি পৃষ্ঠা পরীক্ষা করুন';

  @override
  String get uiOnePageAdded => '1 পৃষ্ঠা যোগ করা হয়েছে';

  @override
  String uiPagesAdded(String count) {
    return '$count পৃষ্ঠাগুলি যোগ করা হয়েছে৷';
  }

  @override
  String get uiReorder => 'পুনরায় সাজান';

  @override
  String uiPageNumber(String number) {
    return 'পৃষ্ঠা $number';
  }

  @override
  String uiRemovePage(String number) {
    return '$number পৃষ্ঠা সরান';
  }

  @override
  String uiProfilePage(String name, String number) {
    return '$name · পৃষ্ঠা $number';
  }

  @override
  String uiCropEdges(String percent) {
    return 'ক্রপ প্রান্ত: $percent%';
  }

  @override
  String uiSelectedReportsCount(String count) {
    return '$count নির্বাচিত প্রতিবেদন';
  }

  @override
  String uiSelectedTestResultsCount(String count) {
    return '$count নির্বাচিত পরীক্ষার ফলাফল';
  }

  @override
  String get uiAllCurrentFutureReports => 'সমস্ত বর্তমান এবং ভবিষ্যতের রিপোর্ট';

  @override
  String get uiNoExpiry => 'কোন মেয়াদ নেই';

  @override
  String uiExpiresDate(String date) {
    return 'মেয়াদ শেষ হবে $date';
  }

  @override
  String get uiAccessCodeRequiredSeparate =>
      'অ্যাক্সেস কোড প্রয়োজন. লিঙ্ক থেকে আলাদা করে শেয়ার করুন।';

  @override
  String get uiNoAccessCodeRequired => 'কোন অ্যাক্সেস কোড প্রয়োজন.';

  @override
  String uiExpiresColonDate(String date) {
    return 'মেয়াদ শেষ: $date';
  }

  @override
  String uiShareProfileReports(String name) {
    return '$name এর রিপোর্ট শেয়ার করুন';
  }

  @override
  String uiProfileReports(String name) {
    return '$name এর রিপোর্ট';
  }

  @override
  String uiSelectedResultsCount(String count) {
    return '$count নির্বাচিত ফলাফল';
  }

  @override
  String get uiAccessCodeRequiredShort => 'অ্যাক্সেস কোড প্রয়োজন';

  @override
  String uiPastLinksCount(String count) {
    return 'অতীত লিঙ্ক · $count';
  }

  @override
  String uiExpiredDate(String date) {
    return 'মেয়াদ শেষ হয়ে গেছে $date';
  }

  @override
  String uiRevokedCreatedDate(String date) {
    return 'প্রত্যাহার করা হয়েছে · $date তৈরি করা হয়েছে৷';
  }

  @override
  String uiUsingActiveLinks(String current, String maximum) {
    return '$maximum সক্রিয় লিঙ্কগুলির $current ব্যবহার করা হচ্ছে।';
  }

  @override
  String uiDeleteReportAndStoredFile(String filename) {
    return '$filename এবং এর সংরক্ষিত ফাইল মুছবেন? এটি পূর্বাবস্থায় ফেরানো যাবে না।';
  }

  @override
  String uiUnableDeleteReportDetail(String error) {
    return 'রিপোর্ট মুছতে অক্ষম: $error';
  }

  @override
  String uiDeleteAllReportsAndFiles(String count) {
    return 'স্থায়ীভাবে সব $count রিপোর্ট এবং তাদের সঞ্চিত ফাইল মুছে ফেলবেন? এটি পূর্বাবস্থায় ফেরানো যাবে না।';
  }

  @override
  String get uiRecycleBinEmptied => 'রিসাইকেল বিন খালি করা হয়েছে';

  @override
  String uiSomeReportsDeleteFailed(String deleted, String failed) {
    return '$deleted রিপোর্ট মুছে ফেলা হয়েছে। $failed মোছা যাবে না; আবার চেষ্টা করুন';
  }

  @override
  String uiUnableEmptyRecycleBinDetail(String error) {
    return 'রিসাইকেল বিন খালি করতে অক্ষম: $error';
  }

  @override
  String uiProfileName(String name) {
    return 'প্রোফাইল: $name';
  }

  @override
  String uiCollectedDate(String date) {
    return 'সংগৃহীত: $date';
  }

  @override
  String uiUploadedDate(String date) {
    return 'আপলোড করা হয়েছে: $date';
  }

  @override
  String uiDeletedOn(String date) {
    return 'মুছে ফেলা হয়েছে: $date';
  }

  @override
  String uiPermanentDeleteOn(String date) {
    return 'স্থায়ী মুছে ফেলার উপর: $date';
  }

  @override
  String uiDaysLeft(String count) {
    return 'দিন বাকি: $count';
  }

  @override
  String get uiConfirmAppLockForDoclyzer =>
      'ডকলাইজারের জন্য অ্যাপ লক নিশ্চিত করুন';

  @override
  String get uiConfirmBeforeTurningOffAppLock =>
      'অ্যাপ লক বন্ধ করার আগে নিশ্চিত করুন';

  @override
  String get uiUnlockDoclyzerToViewYourHealthRecords =>
      'আপনার স্বাস্থ্য রেকর্ড দেখতে Doclyzer আনলক করুন';

  @override
  String get uiCreateADefaultProfileBeforeUploadingA =>
      'একটি রিপোর্ট আপলোড করার আগে একটি ডিফল্ট প্রোফাইল তৈরি করুন৷';

  @override
  String get uiCreateADefaultProfileBeforeViewingYour =>
      'আপনার টাইমলাইন দেখার আগে একটি ডিফল্ট প্রোফাইল তৈরি করুন।';

  @override
  String get uiUnableToLoadProfilesRightNow => 'এখন প্রোফাইল লোড করতে অক্ষম.';

  @override
  String get uiCannotUploadRightNowBecauseProfileData =>
      'এখনই আপলোড করা যাবে না কারণ প্রোফাইল ডেটা লোড করা যায়নি৷ অনুগ্রহ করে নিশ্চিত করুন যে API সার্ভার চলছে এবং আবার চেষ্টা করুন।';

  @override
  String get uiCannotOpenTimelineRightNowBecauseProfile =>
      'এই মুহূর্তে টাইমলাইন খোলা যাবে না কারণ প্রোফাইল ডেটা লোড করা যায়নি৷ অনুগ্রহ করে নিশ্চিত করুন যে API সার্ভার চলছে এবং আবার চেষ্টা করুন।';

  @override
  String get uiUnableToLoadProfilesRightNowPlease =>
      'এখন প্রোফাইল লোড করতে অক্ষম. আবার চেষ্টা করুন.';

  @override
  String get uiUnableToLoadSharingLinksPleaseTry =>
      'শেয়ারিং লিঙ্ক লোড করতে অক্ষম. আবার চেষ্টা করুন.';

  @override
  String get uiPasswordChanged => 'পাসওয়ার্ড পরিবর্তন করা হয়েছে';

  @override
  String get uiUnableToOpenThatReportTryThe =>
      'সেই রিপোর্ট খুলতে অক্ষম। রিপোর্ট লাইব্রেরি চেষ্টা করুন.';

  @override
  String get uiThisActionIsTemporarilyUnavailableWhileYour =>
      'আপনার অ্যাকাউন্ট পর্যালোচনার অধীনে থাকাকালীন এই ক্রিয়াটি সাময়িকভাবে অনুপলব্ধ।';

  @override
  String get uiUnableToOpenThisSectionPleaseTry =>
      'এই বিভাগটি খুলতে অক্ষম৷ আবার চেষ্টা করুন.';

  @override
  String get uiAppLockIsUnavailable => 'অ্যাপ লক অনুপলব্ধ৷';

  @override
  String get uiDoclyzerIsLocked => 'ডকলাইজার তালাবদ্ধ';

  @override
  String get uiCouldNotReadTheSavedAppLock =>
      'সংরক্ষিত অ্যাপ লক সেটিং পড়া যায়নি। চালিয়ে যাওয়ার জন্য আবার চেষ্টা করুন।';

  @override
  String get uiUseYourDevicePasscodeOrBiometricsTo =>
      'চালিয়ে যেতে আপনার ডিভাইসের পাসকোড বা বায়োমেট্রিক্স ব্যবহার করুন।';

  @override
  String get uiUploadsAreTemporarilyUnavailableWhileYourAccount =>
      'আপনার অ্যাকাউন্ট পর্যালোচনার অধীনে আপলোডগুলি সাময়িকভাবে অনুপলব্ধ।';

  @override
  String get uiUnableToStartAnUploadPleaseTry =>
      'একটি আপলোড শুরু করতে অক্ষম৷ আবার চেষ্টা করুন.';

  @override
  String get uiJustNow => 'এইমাত্র';

  @override
  String get uiAdditionalDetails => 'অতিরিক্ত বিবরণ:';

  @override
  String get uiSaveCorrection => 'সংশোধন সংরক্ষণ করুন';

  @override
  String get uiCouldNotOpenFilesCheckAccessAnd =>
      'ফাইল খুলতে পারেনি. অ্যাক্সেস চেক করুন এবং আবার চেষ্টা করুন।';

  @override
  String get uiCouldNotOpenCameraCheckPermissionAnd =>
      'ক্যামেরা খুলতে পারেনি। অনুমতি পরীক্ষা করুন এবং আবার চেষ্টা করুন.';

  @override
  String get uiCouldNotOpenPhotosCheckPermissionAnd =>
      'ফটো খুলতে পারেনি। অনুমতি পরীক্ষা করুন এবং আবার চেষ্টা করুন.';

  @override
  String get uiCouldNotAccessSelectedFile =>
      'নির্বাচিত ফাইল অ্যাক্সেস করা যায়নি.';

  @override
  String get uiCouldNotAccessSelectedFile45effa =>
      'নির্বাচিত ফাইল অ্যাক্সেস করা যায়নি';

  @override
  String get uiConnectionLostTheUploadMayHaveReached =>
      'সংযোগ বিচ্ছিন্ন। আপলোড সার্ভারে পৌঁছেছে। নিরাপদে একই ফাইল পুনরায় চেষ্টা করুন.';

  @override
  String get uiCouldNotLoadExistingReport =>
      'বিদ্যমান প্রতিবেদন লোড করা যায়নি';

  @override
  String get uiAddingTo => 'যোগ করা হচ্ছে';

  @override
  String get uiSomeResultsNeedReviewYourOriginalReport =>
      'কিছু ফলাফল পর্যালোচনা প্রয়োজন. আপনার মূল রিপোর্ট সংরক্ষিত হয়.';

  @override
  String get uiWeCouldnTReadThisFormatYour =>
      'আমরা এই বিন্যাস পড়তে পারিনি. আপনার ফাইল সংরক্ষিত হয়.';

  @override
  String get uiReportParsedSuccessfullyResultsAndTrendsAre =>
      'রিপোর্ট সফলভাবে পার্স করা হয়েছে. ফলাফল এবং প্রবণতা উপলব্ধ.';

  @override
  String get uiYourReportIsStillBeingAnalyzedOpen =>
      'আপনার রিপোর্ট এখনও বিশ্লেষণ করা হচ্ছে. এর স্থিতি পরীক্ষা করতে এটি খুলুন।';

  @override
  String get uiProcessingStoppedYourFileIsSavedYou =>
      'প্রক্রিয়াকরণ বন্ধ হয়ে গেছে। আপনার ফাইল সংরক্ষিত হয়. আপনি আবার চেষ্টা করতে পারেন.';

  @override
  String get uiNoExtractedTestValuesWereAddedYou =>
      'কোনো নিষ্কাশিত পরীক্ষার মান যোগ করা হয়নি। আপনি এখনও নথিটি খুলতে এবং ভাগ করতে পারেন৷ আপনার প্রবণতা অপরিবর্তিত.';

  @override
  String get uiYourOriginalIsSaved => 'আপনার মূল সংরক্ষিত হয়.';

  @override
  String get uiInitialUpload => 'প্রাথমিক আপলোড';

  @override
  String get uiParsedSuccessfully => 'সফলভাবে পার্স করা হয়েছে৷';

  @override
  String get uiParsingFailed => 'পার্সিং ব্যর্থ হয়েছে৷';

  @override
  String get uiExtractionIncomplete => 'নিষ্কাশন অসম্পূর্ণ';

  @override
  String get uiTransientFailure => 'ক্ষণস্থায়ী ব্যর্থতা';

  @override
  String get uiTerminalFailure => 'টার্মিনাল ব্যর্থতা';

  @override
  String get uiFailedToLoadAttemptHistory =>
      'প্রচেষ্টার ইতিহাস লোড করতে ব্যর্থ হয়েছে৷';

  @override
  String get uiThisReportSFileIsNoLonger => 'এই রিপোর্টের ফাইল আর উপলব্ধ নেই.';

  @override
  String get uiCompareResults => 'ফলাফল তুলনা করুন';

  @override
  String get uiNoDifferenceCalculatedCompatibilityNeedsConfirmation =>
      'কোন পার্থক্য গণনা. সামঞ্জস্য নিশ্চিতকরণ প্রয়োজন.';

  @override
  String get uiUnitNotRecorded => 'ইউনিট রেকর্ড করা হয়নি';

  @override
  String get uiNoNumericChangeBetweenTheseReports =>
      'এই রিপোর্টগুলির মধ্যে কোন সংখ্যাগত পরিবর্তন নেই।';

  @override
  String get uiUnableToRestore => 'পুনরুদ্ধার করতে অক্ষম:';

  @override
  String get uiEnterAGiftVoucherCode => 'একটি উপহার ভাউচার কোড লিখুন.';

  @override
  String get uiApplyVoucher => 'ভাউচার প্রয়োগ করুন';

  @override
  String get uiNotAvailable => 'পাওয়া যায় না';

  @override
  String get uiViewReceipt => 'রসিদ দেখুন';

  @override
  String get uiGiftVoucherIsInvalidOrAlreadyRedeemed =>
      'উপহার ভাউচারটি অবৈধ বা ইতিমধ্যেই ভাঙানো হয়েছে৷';

  @override
  String get uiGiftVoucherHasAlreadyBeenRedeemed =>
      'গিফট ভাউচার ইতিমধ্যেই রিডিম করা হয়েছে।';

  @override
  String get uiGiftVoucherHasBeenVoided => 'উপহার ভাউচার বাতিল করা হয়েছে.';

  @override
  String get uiGiftVoucherHasExpired => 'উপহার ভাউচারের মেয়াদ শেষ হয়ে গেছে।';

  @override
  String get uiUnableToRedeemThisGiftVoucher =>
      'এই উপহার ভাউচার রিডিম করতে অক্ষম।';

  @override
  String get uiUnableToRedeemThisGiftVoucherPlease =>
      'এই উপহার ভাউচার রিডিম করতে অক্ষম। আবার চেষ্টা করুন.';

  @override
  String get uiEnterAPromoCodeToApply =>
      'আবেদন করার জন্য একটি প্রচার কোড লিখুন।';

  @override
  String get uiPromoCodeNotFound => 'প্রচার কোড পাওয়া যায়নি.';

  @override
  String get uiPromoCodeIsInactive => 'প্রচার কোড নিষ্ক্রিয়.';

  @override
  String get uiPromoCodeHasExpired => 'প্রচার কোড মেয়াদ শেষ হয়েছে.';

  @override
  String get uiPromoCodeIsNotApplicableToThis =>
      'প্রোমো কোড এই প্যাকের জন্য প্রযোজ্য নয়।';

  @override
  String get uiPromoCodeUsageLimitReached =>
      'প্রচার কোড ব্যবহারের সীমা পৌঁছেছে।';

  @override
  String get uiYouHaveAlreadyUsedThisPromoCode =>
      'আপনি ইতিমধ্যে এই প্রচার কোড ব্যবহার করেছেন.';

  @override
  String get uiFailedToApplyPromoCodePleaseTry =>
      'প্রচার কোড প্রয়োগ করতে ব্যর্থ হয়েছে. আবার চেষ্টা করুন.';

  @override
  String get uiThisOrderWasFlaggedForReviewBefore =>
      'ক্রেডিট যোগ করার আগে এই অর্ডারটি পর্যালোচনার জন্য পতাকাঙ্কিত করা হয়েছিল।';

  @override
  String get uiPaymentFailedDuringReconciliationYouCanRetry =>
      'পুনর্মিলনের সময় পেমেন্ট ব্যর্থ হয়েছে। আপনি নিরাপদে আবার চেষ্টা করতে পারেন.';

  @override
  String get uiAwaitingCapture => 'ক্যাপচারের অপেক্ষায়';

  @override
  String get uiLastPaymentFailed => 'শেষ পেমেন্ট ব্যর্থ হয়েছে';

  @override
  String get uiYouCanRetryCheckoutSafely =>
      'আপনি নিরাপদে চেকআউট পুনরায় চেষ্টা করতে পারেন.';

  @override
  String get uiPromoCodesNotSupportedForSubscriptionsYet =>
      'প্রচার কোড এখনও সদস্যতা জন্য সমর্থিত নয়.';

  @override
  String get uiCouldNotDownloadTheExportTryAgain =>
      'রপ্তানি ডাউনলোড করা যায়নি. আবার চেষ্টা করুন';

  @override
  String get uiSelectOriginalReportsOrTestResults =>
      'আসল রিপোর্ট বা পরীক্ষার ফলাফল নির্বাচন করুন।';

  @override
  String get uiExportRequestedTapCheckStatusToRefresh =>
      'রপ্তানি অনুরোধ করা হয়েছে. রিফ্রেশ করতে \"স্থিতি পরীক্ষা করুন\" এ আলতো চাপুন৷';

  @override
  String get uiFailedToRequestExportPleaseTryAgain =>
      'এক্সপোর্টের অনুরোধ করা যায়নি। আবার চেষ্টা করুন.';

  @override
  String get uiExportReadyDownloadURLAvailable =>
      'রপ্তানি প্রস্তুত। ডাউনলোড URL উপলব্ধ।';

  @override
  String get uiFailedToCheckExportStatusPleaseTry =>
      'এক্সপোর্ট স্ট্যাটাস চেক করতে ব্যর্থ হয়েছে. আবার চেষ্টা করুন.';

  @override
  String get uiFailedToCloseAccountPleaseTryAgain =>
      'অ্যাকাউন্ট বন্ধ করতে ব্যর্থ হয়েছে. আবার চেষ্টা করুন.';

  @override
  String get uiPrepareExport => 'রপ্তানি প্রস্তুত করুন';

  @override
  String get uiSaveExport => 'রপ্তানি সংরক্ষণ করুন';

  @override
  String get uiPrepareExportAgain => 'আবার রপ্তানি প্রস্তুত করুন';

  @override
  String get uiAllDates => 'সব তারিখ';

  @override
  String get uiPreparingAccountDetails =>
      'অ্যাকাউন্টের বিবরণ প্রস্তুত করা হচ্ছে';

  @override
  String get uiFamilyMemberProfiles => 'পরিবারের সদস্যদের প্রোফাইল';

  @override
  String get uiUploadedReports => 'আপলোড রিপোর্ট';

  @override
  String get uiDownloadReady => 'ডাউনলোড রেডি';

  @override
  String get uiReportNotificationsEnabledOnThisDevice =>
      'এই ডিভাইসে রিপোর্ট বিজ্ঞপ্তি সক্রিয় করা হয়েছে';

  @override
  String get uiDeviceSettingsOpenedAllowNotificationsForDoclyzer =>
      'ডিভাইস সেটিংস খোলা হয়েছে। Doclyzer-এর জন্য বিজ্ঞপ্তির অনুমতি দিন, তারপর এখানে ফিরে আসুন।';

  @override
  String get uiNotificationsAreStillOffAllowThemIn =>
      'বিজ্ঞপ্তি এখনও বন্ধ আছে. তাদের ডিভাইস সেটিংসে রিপোর্ট আপডেট পেতে অনুমতি দিন।';

  @override
  String get uiPreferencesSaved => 'পছন্দ সংরক্ষিত';

  @override
  String get uiYourAccountChoiceWasSavedButThis =>
      'আপনার অ্যাকাউন্ট পছন্দ সংরক্ষিত হয়েছে, কিন্তু এই ডিভাইসটি মার্কেটিং পুশের জন্য নিবন্ধন করা শেষ করেনি। এই ডিভাইসে মার্কেটিং অবরুদ্ধ থাকে; বিজ্ঞপ্তির অনুমতি পরীক্ষা করুন এবং আবার সংরক্ষণ করার চেষ্টা করুন।';

  @override
  String get uiYourAccountChoiceWasSavedThisDevice =>
      'আপনার অ্যাকাউন্ট পছন্দ সংরক্ষিত হয়েছে. এই ডিভাইসটি এখনও তার স্থানীয় পছন্দ নিশ্চিত করতে পারেনি, তবে অ্যাকাউন্ট লেভেলে মার্কেটিং অবরুদ্ধ রয়েছে।';

  @override
  String get uiYourAccountChoiceWasSavedButThisaf7de6 =>
      'আপনার অ্যাকাউন্ট পছন্দ সংরক্ষিত হয়েছে, কিন্তু এই ডিভাইসটি মার্কেটিং পুশ সক্ষম করতে পারেনি৷ বিজ্ঞপ্তির অনুমতি পরীক্ষা করুন এবং আবার চেষ্টা করুন।';

  @override
  String get uiSavingTookTooLongCheckYourConnection =>
      'সংরক্ষণ করতে অনেক সময় লেগেছে। আপনার সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন.';

  @override
  String get uiReportReadyForReview => 'প্রতিবেদন পর্যালোচনার জন্য প্রস্তুত';

  @override
  String get uiKnowWhenYourResultsAreReadyTo =>
      'আপনার ফলাফল পরীক্ষা করার জন্য প্রস্তুত হলে জানুন।';

  @override
  String get uiUploadUpdates => 'আপডেট আপলোড করুন';

  @override
  String get uiGetAMessageIfAnUploadNeeds =>
      'একটি আপলোড মনোযোগ প্রয়োজন হলে একটি বার্তা পান.';

  @override
  String get uiSharedLinkReminders => 'শেয়ার করা লিঙ্ক অনুস্মারক';

  @override
  String get uiHearWhenALinkIsAboutTo =>
      'একটি লিঙ্কের মেয়াদ শেষ হতে চলেছে তা শুনুন৷';

  @override
  String get uiSecurityAlerts => 'নিরাপত্তা সতর্কতা';

  @override
  String get uiRequiredForAccountSafety =>
      'অ্যাকাউন্ট নিরাপত্তার জন্য প্রয়োজন.';

  @override
  String get uiComplianceNotices => 'সম্মতি বিজ্ঞপ্তি';

  @override
  String get uiRequiredAccountInformation => 'প্রয়োজনীয় অ্যাকাউন্ট তথ্য।';

  @override
  String get uiMarketingPushNotifications => 'মার্কেটিং পুশ বিজ্ঞপ্তি';

  @override
  String get uiOffersAndAnnouncementsSavingThisChoiceAlso =>
      'অফার এবং ঘোষণা. এই পছন্দটি সংরক্ষণ করা এই ডিভাইসেও এটি প্রযোজ্য।';

  @override
  String get uiProductUpdates => 'পণ্য আপডেট';

  @override
  String get uiOptionalNewsAboutDoclyzer => 'Doclyzer সম্পর্কে ঐচ্ছিক খবর.';

  @override
  String get uiCannotConnectToServerPleaseCheckYour =>
      'সার্ভারের সাথে সংযোগ করা যাচ্ছে না। আপনার ইন্টারনেট বা API সার্ভার চেক করুন.';

  @override
  String get uiProfileUpdatesAreTemporarilyUnavailableWhileYour =>
      'আপনার অ্যাকাউন্ট পর্যালোচনার অধীনে থাকাকালীন প্রোফাইল আপডেটগুলি সাময়িকভাবে অনুপলব্ধ।';

  @override
  String get uiUse100CharactersOrFewer => '100 বা তার কম অক্ষর ব্যবহার করুন';

  @override
  String get uiAddProfile => 'প্রোফাইল যোগ করুন';

  @override
  String get uiCreateProfile => 'প্রোফাইল তৈরি করুন';

  @override
  String get uiUpdateTheirDetails => 'তাদের বিবরণ আপডেট';

  @override
  String get uiWhoIsThisProfileFor => 'এই প্রোফাইল কার জন্য?';

  @override
  String get uiNotSelected => 'নির্বাচিত হয়নি';

  @override
  String get uiEnterAReferralCode => 'একটি রেফারেল কোড লিখুন।';

  @override
  String get uiReferralAppliedBonusUnlocksAfterEmailVerification =>
      'রেফারেল প্রয়োগ করা হয়েছে। ইমেল যাচাইকরণের পরে বোনাস আনলক হয়।';

  @override
  String get uiReferralAppliedBonusCreditsAreReady =>
      'রেফারেল প্রয়োগ করা হয়েছে। বোনাস ক্রেডিট প্রস্তুত.';

  @override
  String get uiApplyCode => 'কোড প্রয়োগ করুন';

  @override
  String get uiYouCannotApplyYourOwnReferralCode =>
      'আপনি নিজের রেফারেল কোড প্রয়োগ করতে পারবেন না।';

  @override
  String get uiReferralCodeIsInvalid => 'রেফারেল কোড অবৈধ।';

  @override
  String get uiFailedToApplyReferralCode =>
      'রেফারেল কোড প্রয়োগ করতে ব্যর্থ হয়েছে.';

  @override
  String get uiFailedToApplyReferralCodePleaseTry =>
      'রেফারেল কোড প্রয়োগ করতে ব্যর্থ হয়েছে. আবার চেষ্টা করুন.';

  @override
  String get uiThisDevice => 'এই ডিভাইস';

  @override
  String get uiSignedInDevice => 'সাইন-ইন করা ডিভাইস';

  @override
  String get uiUnknownDevice => 'অজানা ডিভাইস';

  @override
  String get uiRevokeAndLogOut => 'প্রত্যাহার করুন এবং লগ আউট করুন';

  @override
  String get uiRevokeSessionca8440 => 'সেশন প্রত্যাহার করুন';

  @override
  String get uiEnterYourCurrentPassword => 'আপনার বর্তমান পাসওয়ার্ড লিখুন';

  @override
  String get uiUseAtLeast8CharactersWithUppercase =>
      'বড় হাতের অক্ষর, ছোট হাতের অক্ষর, একটি সংখ্যা এবং একটি বিশেষ অক্ষর সহ কমপক্ষে 8টি অক্ষর ব্যবহার করুন৷';

  @override
  String get uiChooseADifferentPassword => 'একটি ভিন্ন পাসওয়ার্ড চয়ন করুন';

  @override
  String get uiNewPasswordsDoNotMatch => 'নতুন পাসওয়ার্ড মেলে না';

  @override
  String get uiYouHaveUsedAllAvailableUploadCredits =>
      'আপনি সমস্ত উপলব্ধ আপলোড ক্রেডিট ব্যবহার করেছেন৷ আরও যোগ করতে পরিকল্পনা এবং ক্রেডিট দেখুন।';

  @override
  String get uiNotificationsAreDisabledForDoclyzerOpenDevice =>
      'Doclyzer-এর জন্য বিজ্ঞপ্তি অক্ষম করা হয়েছে। রিপোর্ট প্রস্তুত এবং অ্যাকাউন্ট আপডেটের অনুমতি দিতে ডিভাইস সেটিংস খুলুন। আপনি এটি চয়ন না করা পর্যন্ত বিপণন বন্ধ থাকে।';

  @override
  String get uiGetReportReadyAndAccountUpdatesOn =>
      'এই ডিভাইসে রিপোর্ট প্রস্তুত এবং অ্যাকাউন্ট আপডেট পান। আপনি এটি চয়ন না করা পর্যন্ত বিপণন বন্ধ থাকে।';

  @override
  String get uiNotificationsAreOffForThisDeviceOpen =>
      'এই ডিভাইসের জন্য বিজ্ঞপ্তি বন্ধ আছে. রিপোর্ট-রেডি এবং অ্যাকাউন্ট আপডেট পেতে সেটিংস খুলুন।';

  @override
  String get uiBlockedExpiredRevoked => 'অবরুদ্ধ (মেয়াদ শেষ/প্রত্যাহার)';

  @override
  String get uiFailedToLoadPolicy => 'নীতি লোড করতে ব্যর্থ হয়েছে৷';

  @override
  String get uiUploadPaused => 'আপলোড বিরাম দেওয়া হয়েছে৷';

  @override
  String get uiSevenDays => '7 দিন';

  @override
  String get uiThirtyDays => '30 দিন';

  @override
  String get uiNinetyDays => '90 দিন';

  @override
  String get uiUploadingAClearReport =>
      'একটি পরিষ্কার প্রতিবেদন আপলোড করা হচ্ছে';

  @override
  String get uiPDFsPhotosAndMultiplePages => 'পিডিএফ, ফটো এবং একাধিক পৃষ্ঠা';

  @override
  String get uiChooseAPDFOrTakeClearPhotos =>
      'একটি পিডিএফ চয়ন করুন বা প্রতিটি পৃষ্ঠার পরিষ্কার ফটো নিন। পুরো পৃষ্ঠাটি ফ্রেমে রাখুন, একদৃষ্টি এড়ান এবং বিশ্লেষণ করার আগে পৃষ্ঠার ক্রমটি পরীক্ষা করুন। আপনি মূলের বিপরীতে নিষ্কাশিত মান সংশোধন করতে পারেন।';

  @override
  String get uiCorrectingAResult => 'একটি ফলাফল সংশোধন';

  @override
  String get uiReviewValuesAgainstTheOriginal =>
      'মূলের বিপরীতে মান পর্যালোচনা করুন';

  @override
  String get uiOpenAReportReviewEachExtractedTest =>
      'একটি প্রতিবেদন খুলুন, প্রতিটি নিষ্কাশিত পরীক্ষাটি মূলের বিপরীতে পর্যালোচনা করুন এবং যে কোনো মান, ইউনিট বা তারিখ ভুলভাবে পড়া হয়েছে তা সংশোধন করুন। আপনি প্রবণতা উপর নির্ভর করার আগে অপ্রমাণিত ফলাফল চেক করা উচিত.';

  @override
  String get uiManagingFamilyRecords => 'পারিবারিক রেকর্ড পরিচালনা করা';

  @override
  String get uiProfilesAccessAndPermissions => 'প্রোফাইল, অ্যাক্সেস এবং অনুমতি';

  @override
  String get uiUseFamilyToCreateAndSwitchProfiles =>
      'প্রোফাইল তৈরি এবং পরিবর্তন করতে পরিবার ব্যবহার করুন। একটি প্রতিবেদন আপলোড বা শেয়ার করার আগে নির্বাচিত ব্যক্তিকে পরীক্ষা করুন। আপনি অ্যাক্সেস করার জন্য অনুমোদিত শুধুমাত্র রেকর্ড পরিচালনা করুন.';

  @override
  String get uiSharingAndRevokingLinks => 'শেয়ারিং এবং প্রত্যাহার লিঙ্ক';

  @override
  String get uiControlTheRecordsYouShare =>
      'আপনার শেয়ার করা রেকর্ড নিয়ন্ত্রণ করুন';

  @override
  String get uiSelectTheReportsOrResultsYouWant =>
      'আপনি যে রিপোর্ট বা ফলাফলগুলি ভাগ করতে চান তা নির্বাচন করুন, মেয়াদ শেষ হওয়া এবং অ্যাক্সেস কোড পর্যালোচনা করুন, তারপর লিঙ্ক এবং কোড আলাদাভাবে পাঠান। অ্যাক্সেসের আর প্রয়োজন না থাকলে শেয়ার করা লিঙ্ক থেকে একটি সক্রিয় লিঙ্ক প্রত্যাহার করুন।';

  @override
  String get uiInformationYouProvide => 'তথ্য আপনি প্রদান';

  @override
  String get uiAccountDetailsAndFamilyProfilesIdentifyWhose =>
      'অ্যাকাউন্টের বিশদ বিবরণ এবং পারিবারিক প্রোফাইল শনাক্ত করে যে আপনি কার রেকর্ড পরিচালনা করেন। আপলোড করা নথিতে সংবেদনশীল স্বাস্থ্য তথ্য থাকতে পারে।';

  @override
  String get uiSharingControls => 'শেয়ারিং নিয়ন্ত্রণ';

  @override
  String get uiReviewTheContentsExpiryAndAccessSettings =>
      'প্রতিটি লিঙ্কের বিষয়বস্তু, মেয়াদ শেষ এবং অ্যাক্সেস সেটিংস পর্যালোচনা করুন। আপনার অ্যাকাউন্ট সেটিংস থেকে সক্রিয় লিঙ্ক পরিচালনা করুন.';

  @override
  String get uiExportAndAccountChoices => 'রপ্তানি এবং অ্যাকাউন্ট পছন্দ';

  @override
  String get uiUseSettingsToExportRecordsOrStart =>
      'রেকর্ড রপ্তানি করতে বা অ্যাকাউন্ট মুছে ফেলার অনুরোধ শুরু করতে সেটিংস ব্যবহার করুন। ধরে রাখার বিবরণ সম্পূর্ণ নীতির অন্তর্গত।';

  @override
  String get uiEducationalScope => 'শিক্ষাগত সুযোগ';

  @override
  String get uiDoclyzerOrganizesReportsAndShowsResultsOver =>
      'ডকলাইজার রিপোর্ট সংগঠিত করে এবং সময়ের সাথে ফলাফল দেখায়। শিক্ষাগত ব্যাখ্যাগুলি চিকিৎসা পরামর্শ বা রোগ নির্ণয় নয়।';

  @override
  String get uiReviewYourRecords => 'আপনার রেকর্ড পর্যালোচনা করুন';

  @override
  String get uiCheckExtractedValuesUnitsAndDatesAgainst =>
      'মূল প্রতিবেদনের বিপরীতে নিষ্কাশিত মান, ইউনিট এবং তারিখগুলি পরীক্ষা করুন। আপনার ফলাফল সম্পর্কে একজন স্বাস্থ্যসেবা পেশাদারকে জিজ্ঞাসা করুন।';

  @override
  String get uiManageAndShareResponsibly =>
      'পরিচালনা করুন এবং দায়িত্বের সাথে ভাগ করুন';

  @override
  String get uiOnlyManageRecordsYouAreAuthorizedTo =>
      'শুধুমাত্র আপনি অ্যাক্সেস করার জন্য অনুমোদিত রেকর্ড পরিচালনা করুন. শেয়ার করার আগে নির্বাচিত তথ্য এবং প্রাপক পরীক্ষা করুন।';

  @override
  String get uiPrivacyPolicy7ceacd => 'গোপনীয়তা নীতি';

  @override
  String get uiTermsOfUse8a069e => 'ব্যবহারের শর্তাবলী';

  @override
  String get uiOpenPrivacyControls => 'গোপনীয়তা নিয়ন্ত্রণ খুলুন';

  @override
  String get uiGetHelpWithTheApp => 'অ্যাপটির সাহায্য নিন';

  @override
  String get uiExportYourDataInAccountSettings =>
      'অ্যাকাউন্ট সেটিংসে আপনার ডেটা রপ্তানি করুন';

  @override
  String get uiYOURDATACHOICES => 'আপনার ডেটা এবং পছন্দ';

  @override
  String get uiUSINGDOCLYZER => 'ডকলাইজার ব্যবহার করা';

  @override
  String get uiUnderstandTheInformationYouKeepInDoclyzer =>
      'আপনি ডকলাইজারে যে তথ্য\nরাখেন তা বুঝুন।';

  @override
  String get uiAClearUnderstandingOfTheAppsRole =>
      'অ্যাপের ভূমিকার একটি স্পষ্ট বোঝা\n।';

  @override
  String uiReportsFromLab(String reportCount, String name) {
    return '$name থেকে $reportCount';
  }

  @override
  String uiReportsLatestDate(String reportCount, String date) {
    return '$reportCount · সর্বশেষ $date';
  }

  @override
  String uiUploadReportForProfile(String name) {
    return 'এই লাইব্রেরি শুরু করতে $name এর জন্য একটি প্রতিবেদন আপলোড করুন৷';
  }

  @override
  String uiIpAddress(String address) {
    return 'আইপি ঠিকানা: $address';
  }

  @override
  String uiSignedInAt(String date) {
    return 'সাইন ইন করেছেন: $date';
  }

  @override
  String get uiUnknown => 'অজানা';

  @override
  String uiResultsFor(String name) {
    return '$name এর জন্য ফলাফল';
  }

  @override
  String uiLabParametersTracked(String count) {
    return '$count ল্যাব প্যারামিটার ট্র্যাক করা হয়েছে৷';
  }

  @override
  String uiSampledDate(String date) {
    return 'নমুনা $date';
  }

  @override
  String uiCollectionDateValue(String date) {
    return 'সংগ্রহের তারিখ: $date';
  }

  @override
  String uiLabRangeValue(String range) {
    return 'ল্যাব পরিসীমা: $range';
  }

  @override
  String uiAiSuggestedRange(String range, String printed) {
    return 'AI এই পরিসরটিকে $range হিসাবে পড়ে। মুদ্রিত পাঠ্য: $printed। এই তুলনার উপর নির্ভর করার আগে মূল প্রতিবেদনটি দেখুন।';
  }

  @override
  String uiReportsReady(String reportCount) {
    return '$reportCount প্রস্তুত';
  }

  @override
  String uiCreditsCount(String count) {
    return '$count ক্রেডিট';
  }

  @override
  String get uiReferralCodeAlreadyApplied =>
      'একটি রেফারেল কোড ইতিমধ্যেই এই অ্যাকাউন্টে প্রয়োগ করা হয়েছে৷';

  @override
  String get uiSetDevicePasscodeForAppLock =>
      'অ্যাপ লক চালু করার আগে একটি ডিভাইস পাসকোড সেট করুন।';

  @override
  String get uiLanguagePreferenceNotSaved => 'ভাষা পছন্দ সংরক্ষণ করা হয়নি.';

  @override
  String get uiExportUnavailable => 'রপ্তানি অনুপলব্ধ';

  @override
  String get uiUnreadableImage => 'অপঠিত ছবি';

  @override
  String uiStatusWithValue(String status) {
    return 'স্থিতি: $status';
  }

  @override
  String get uiPending => 'মুলতুবি';

  @override
  String get uiCompleted => 'সম্পন্ন';

  @override
  String get uiFailed => 'ব্যর্থ হয়েছে';

  @override
  String get uiInactive => 'নিষ্ক্রিয়';

  @override
  String uiRestoreBeforeDate(String date) {
    return 'আপনার রিপোর্ট এবং প্রোফাইল রাখতে $date এর আগে পুনরুদ্ধার করুন।';
  }

  @override
  String get uiThirtyDayDeadline => '30 দিনের সময়সীমা';

  @override
  String uiWhatsAffected(String details) {
    return 'কি প্রভাবিত হয়: $details';
  }

  @override
  String uiLastUpdatedAt(String date, String time) {
    return 'সর্বশেষ আপডেট: $date এ $time';
  }

  @override
  String uiMoveReportToProfile(String filename, String name) {
    return '$filename বর্তমান প্রোফাইলের পরিবর্তে $name এর অধীনে প্রদর্শিত হবে৷';
  }

  @override
  String get uiOneVerifiedResult => '1টি যাচাইকৃত ফলাফল সংরক্ষিত।';

  @override
  String uiVerifiedResultsCount(String count) {
    return '$count যাচাইকৃত ফলাফল সংরক্ষিত।';
  }

  @override
  String uiUnableToSwitchProfilesWithReason(String reason) {
    return 'প্রোফাইল স্যুইচ করতে অক্ষম. $reason';
  }

  @override
  String uiCollectedOn(String date) {
    return 'সংগৃহীত: $date';
  }

  @override
  String uiUploadedPrefix(String date) {
    return 'আপলোডের তারিখ $date';
  }

  @override
  String uiReportComparisonLabel(String filename, String date) {
    return '$filename · $date';
  }

  @override
  String uiIncreasedBy(String amount) {
    return '$amount দ্বারা বৃদ্ধি';
  }

  @override
  String uiDecreasedBy(String amount) {
    return '$amount কমেছে';
  }

  @override
  String get uiPercentagePoints => 'শতাংশ পয়েন্ট';

  @override
  String uiTestValuesCount(String count) {
    return 'পরীক্ষার মান ($count)';
  }

  @override
  String uiAiValueReviewNotice(String value) {
    return 'প্রক্রিয়াকরণের সময় AI দ্বারা চেক করা মান। আসল OCR: $value। রিপোর্টের বিরুদ্ধে এটি নিশ্চিত করুন।';
  }

  @override
  String uiReportAlreadyInProfile(String name) {
    return 'ইতিমধ্যেই $name-এ রিপোর্ট করুন৷';
  }

  @override
  String uiReportAddedToProfile(String name) {
    return '$name এ রিপোর্ট যোগ করা হয়েছে';
  }

  @override
  String uiAddedOn(String date) {
    return '$date যোগ করা হয়েছে৷';
  }

  @override
  String uiUsingReportsLimit(String current, String max) {
    return '$max রিপোর্টের $current ব্যবহার করে।';
  }

  @override
  String get uiNeedHelp => 'সাহায্য দরকার?';

  @override
  String get uiEnabled => 'সক্রিয়';

  @override
  String get uiEnable => 'সক্ষম করুন';

  @override
  String get uiSubscribe => 'সদস্যতা';

  @override
  String get uiApplying => 'আবেদন করা হচ্ছে';

  @override
  String get uiCheckStatus => 'অবস্থা দেখুন';

  @override
  String get uiEditProfile => 'প্রোফাইল সম্পাদনা করুন';

  @override
  String get uiSaveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get uiOptional => 'ঐচ্ছিক';

  @override
  String uiPendingOrderReconciliation(String orderId) {
    return 'অর্ডার $orderId পুনর্মিলনের জন্য অপেক্ষা করছে। স্ট্যাটাস পরিষ্কার না হওয়া পর্যন্ত কেনাকাটা স্থগিত করা হয়েছে।';
  }

  @override
  String uiMonthlyPlanDescription(String name) {
    return 'মাসিক পরিকল্পনা - $name';
  }

  @override
  String uiCreditPackDescription(String name) {
    return 'ক্রেডিট প্যাক - $name';
  }

  @override
  String get uiUnreadable => 'অপঠিত';

  @override
  String uiLatestValue(String value) {
    return 'সর্বশেষ: $value';
  }

  @override
  String get uiEarlier => 'এর আগে';

  @override
  String get uiLater => 'পরে';

  @override
  String get uiViewed => 'দেখা হয়েছে';

  @override
  String get uiBlocked => 'অবরুদ্ধ';

  @override
  String get uiCapped => 'ক্যাপড';

  @override
  String uiLastChange(String label) {
    return 'শেষ পরিবর্তন: $label';
  }

  @override
  String uiLastChangeAt(String label, String date) {
    return 'শেষ পরিবর্তন: $label · $date';
  }

  @override
  String uiGiftVoucherApplied(String credits) {
    return 'উপহার ভাউচার প্রয়োগ করা হয়েছে। $credits ক্রেডিট যোগ করা হয়েছে।';
  }

  @override
  String uiCouldNotSaveOriginal(String reason) {
    return 'আসলটি এখনও সংরক্ষণ করা যায়নি। $reason';
  }

  @override
  String uiFailedToRevoke(String reason) {
    return 'প্রত্যাহার করতে ব্যর্থ হয়েছে: $reason';
  }

  @override
  String uiReferralShareMessage(String code, String link) {
    return 'আমার ডকলাইজার রেফারেল কোড $code: $link ব্যবহার করুন';
  }

  @override
  String get uiAMomentAgo => 'কিছুক্ষণ আগে';

  @override
  String uiMinutesAgo(String count) {
    return '$count মিনিট আগে';
  }

  @override
  String get uiOneHourAgo => '1 ঘণ্টা আগে';

  @override
  String uiHoursAgo(String count) {
    return '$count ঘন্টা আগে';
  }

  @override
  String get uiToday => 'আজ';

  @override
  String get uiYesterday => 'গতকাল';

  @override
  String get uiOneDayAgo => '1 দিন আগে';

  @override
  String uiDaysAgo(String count) {
    return '$count দিন আগে';
  }

  @override
  String get uiOneWeekAgo => '1 সপ্তাহ আগে';

  @override
  String uiWeeksAgo(String count) {
    return '$count সপ্তাহ আগে';
  }

  @override
  String get uiOneMonthAgo => '1 মাস আগে';

  @override
  String uiMonthsAgo(String count) {
    return '$count মাস আগে';
  }

  @override
  String get uiOneYearAgo => '1 বছর আগে';

  @override
  String uiYearsAgo(String count) {
    return '$count বছর আগে';
  }

  @override
  String get uiInOneDay => '1 দিনে';

  @override
  String uiInDays(String count) {
    return '$count দিনে';
  }

  @override
  String uiInMinutes(String count) {
    return '$count মিনিটে';
  }

  @override
  String get uiInOneHour => '1 ঘণ্টার মধ্যে';

  @override
  String uiInHours(String count) {
    return '$count ঘন্টায়';
  }

  @override
  String get uiMissingExtractedTestName =>
      'নিষ্কাশিত ফলাফল থেকে পরীক্ষার নাম অনুপস্থিত।';

  @override
  String get uiMissingCapturedLabRange =>
      'এই পরীক্ষার জন্য কোনো ল্যাব রেফারেন্স পরিসীমা ক্যাপচার করা হয়নি।';

  @override
  String get uiNonNumericExtractedValue =>
      'নিষ্কাশিত মান একটি সাধারণ সংখ্যা নয়। মূল প্রতিবেদনে এটি পরীক্ষা করুন।';

  @override
  String get uiLabFlagRangeConflict =>
      'ল্যাব পতাকা মুদ্রিত পরিসরের সাথে দ্বন্দ্ব। মূল রিপোর্ট চেক করুন.';

  @override
  String get uiResultNeedsOriginalCheck =>
      'নিষ্কাশিত মান, মুদ্রিত পরিসর বা ল্যাব পতাকা মূল প্রতিবেদনে পরীক্ষা করা প্রয়োজন।';

  @override
  String get uiInitialEntitlement => 'প্রাথমিক এনটাইটেলমেন্ট';

  @override
  String get uiCreditPackPurchase => 'ক্রেডিট প্যাক ক্রয়';

  @override
  String get uiSubscriptionUpgrade => 'সদস্যতা আপগ্রেড';

  @override
  String get uiPlanDowngrade => 'প্ল্যান ডাউনগ্রেড';

  @override
  String get uiAdminAdjustment => 'অ্যাডমিন সমন্বয়';

  @override
  String get uiSystemReconciliation => 'সিস্টেম পুনর্মিলন';

  @override
  String get uiReferralInviteBonus => 'রেফারেল আমন্ত্রণ বোনাস';

  @override
  String get uiReferralAnalysisMilestone => 'রেফারেল বিশ্লেষণ মাইলফলক';

  @override
  String get uiReferralPurchaseMilestone => 'রেফারেল ক্রয় মাইলফলক';

  @override
  String get uiFreePromoCreditPack => 'বিনামূল্যে প্রচার ক্রেডিট প্যাক';

  @override
  String get uiGiftVoucherRedeemed => 'উপহার ভাউচার রিডিম করা হয়েছে';

  @override
  String get uiNotYetChanged => 'এখনো পরিবর্তন হয়নি';

  @override
  String get uiCannotReachServer =>
      'সার্ভারে পৌঁছাতে অক্ষম। আপনার সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন.';

  @override
  String get uiInvalidEmailOrPassword =>
      'অবৈধ ইমেল বা পাসওয়ার্ড। আপনার বিবরণ পরীক্ষা করুন এবং আবার চেষ্টা করুন.';

  @override
  String get uiTooManyAuthAttempts =>
      'অনেক চেষ্টা. কয়েক মিনিট অপেক্ষা করুন এবং আবার চেষ্টা করুন।';

  @override
  String get uiEnterValidEmail => 'একটি বৈধ ইমেল ঠিকানা লিখুন.';

  @override
  String get uiPasswordRequirements =>
      'পাসওয়ার্ড কমপক্ষে 8 অক্ষরের হতে হবে এবং এতে বড় হাতের, ছোট হাতের অক্ষর, একটি সংখ্যা এবং একটি বিশেষ অক্ষর অন্তর্ভুক্ত থাকতে হবে।';

  @override
  String get uiAccountWithEmailExists =>
      'এই ইমেল সহ একটি অ্যাকাউন্ট ইতিমধ্যেই বিদ্যমান৷ সাইন ইন করুন বা একটি ভিন্ন ইমেল ব্যবহার করুন।';

  @override
  String get uiUploadedStatus => 'আপলোড করা হয়েছে';

  @override
  String uiSupportAction(String action) {
    return 'অ্যাকশন: $action';
  }

  @override
  String uiSupportCorrelationId(String id) {
    return 'পারস্পরিক সম্পর্ক আইডি: $id';
  }

  @override
  String uiSupportClientActionId(String id) {
    return 'ক্লায়েন্ট অ্যাকশন আইডি: $id';
  }

  @override
  String uiSupportErrorCode(String code) {
    return 'ত্রুটি কোড: $code';
  }

  @override
  String uiSupportError(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get uiSessionExpiredSignInAgain =>
      'আপনার অধিবেশন শেষ. আবার সাইন ইন করুন.';

  @override
  String get uiProfileLimitReached =>
      'আপনার প্ল্যান প্রোফাইল সীমা পৌঁছে গেছে। আরও যোগ করতে পরিকল্পনা এবং ক্রেডিট পর্যালোচনা করুন।';

  @override
  String get uiCorrectionConflictReload =>
      'এই ফলাফল অন্যত্র পরিবর্তিত হয়েছে। এটি সংশোধন করার আগে প্রতিবেদনটি পুনরায় লোড করুন।';

  @override
  String get uiSeePlanCreditsOptions =>
      'উপলব্ধ বিকল্পের জন্য পরিকল্পনা এবং ক্রেডিট দেখুন।';

  @override
  String get uiShareLinkLimitHelp =>
      'আপনি সক্রিয় শেয়ার-লিঙ্ক সীমাতে পৌঁছেছেন৷';

  @override
  String get uiScopedExportUnavailable =>
      'স্কোপড এক্সপোর্ট অনুপলব্ধ. পরে আবার চেষ্টা করুন.';

  @override
  String get uiRestorationUnavailable =>
      'পুনরুদ্ধার অনুপলব্ধ. পরে আবার চেষ্টা করুন.';

  @override
  String get uiExportRequestNotFound =>
      'রপ্তানি অনুরোধ পাওয়া যায়নি. একটি নতুন রপ্তানি অনুরোধ.';

  @override
  String get uiClosureConfirmationRequired =>
      'অবিরত করতে অ্যাকাউন্ট বন্ধ নিশ্চিত করুন.';

  @override
  String get uiCurrentPasswordIncorrect => 'বর্তমান পাসওয়ার্ডটি ভুল।';

  @override
  String get uiLaboratories => 'গবেষণাগার';

  @override
  String get uiUnlock => 'আনলক করুন';
}
