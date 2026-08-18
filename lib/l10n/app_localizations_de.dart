// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => '40Study';

  @override
  String get itemsTitle => 'Beispielartikel';

  @override
  String get emailsTitle => 'E-Mails';

  @override
  String get launchesTitle => 'Starts';

  @override
  String itemTitle(Object id) {
    return 'Beispielartikel $id';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get appearanceTitle => 'Darstellung';

  @override
  String get dynamicColorSettingsItemTitle => 'Dynamische Farben verwenden';

  @override
  String get dynamicColorSettingsItemDescription =>
      'App-Farben an das Hintergrundbild anpassen';

  @override
  String get darkThemeSettingsItemTitle => 'Designmodus';

  @override
  String get darkThemeOnSettingsItemTitle => 'Dunkel';

  @override
  String get darkThemeOffSettingsItemTitle => 'Hell';

  @override
  String get darkThemeFollowSystemSettingsItemTitle => 'Systemstandard';

  @override
  String get tryAgainButton => 'Erneut versuchen';

  @override
  String get appearanceSettingsItem => 'Appearance';

  @override
  String get appearanceSettingsItemDescription =>
      'Dark theme dynamic color, languages';

  @override
  String get aboutSettingsItem => 'About';

  @override
  String get aboutSettingsItemDescription => 'Version, links, feedback';

  @override
  String missionTitle(Object mission) {
    return 'Mission: $mission';
  }

  @override
  String launchedAt(Object launchedAt) {
    return 'Gestartet am: $launchedAt';
  }

  @override
  String rocket(Object rocketName, Object rocketType) {
    return 'Rakete: $rocketName ($rocketType)';
  }

  @override
  String daysSinceTodayTitle(Object days) {
    return 'Vor $days Tagen';
  }

  @override
  String daysFromTodayTitle(Object days) {
    return 'In $days Tagen';
  }

  @override
  String get themeTitle => 'Design';

  @override
  String get systemThemeTitle => 'Systemdesign';

  @override
  String get lightThemeTitle => 'Helles Design';

  @override
  String get darkThemeTitle => 'Dunkles Design';

  @override
  String get lightGoldThemeTitle => 'Helles Gold-Design';

  @override
  String get darkGoldThemeTitle => 'Dunkles Gold-Design';

  @override
  String get lightMintThemeTitle => 'Helles Mint-Design';

  @override
  String get darkMintThemeTitle => 'Dunkles Mint-Design';

  @override
  String get experimentalThemeTitle => 'Experimental Theme';

  @override
  String get itemDetailsTitle => 'Artikeldetails';

  @override
  String get error => 'Fehler';

  @override
  String get emptyList => 'Leere Liste';

  @override
  String get tabHome => 'Startseite';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get newsScreen => 'Nachrichten';

  @override
  String get disabledButtonTitle => 'Deaktiviert';

  @override
  String get disabledRoundedButtonTitle => 'Deaktiviert (abgerundet)';

  @override
  String get disabledWithIconButtonTitle => 'Deaktiviert mit Icon';

  @override
  String get enabledButtonTitle => 'Aktiviert';

  @override
  String get borderRadiusButtonTitle => 'Abgerundete Ecken';

  @override
  String get borderSideButtonTitle => 'Rahmenlinie';

  @override
  String get iconButtonTitle => 'Mit Icon';

  @override
  String get iconAndPaddingButtonTitle => 'Mit Icon & Abstand';

  @override
  String get transparentButtonTitle => 'Transparent';

  @override
  String get missionTimeline => 'Missionszeitplan';

  @override
  String get staticFireTest => 'Statischer Feuertest';

  @override
  String get launch => 'Start';

  @override
  String get missionSuccess => 'Missionserfolg';

  @override
  String get objectivesCompleted => 'Ziele erreicht';

  @override
  String get missionSuccessful => 'Mission erfolgreich';

  @override
  String get missionFailed => 'Mission fehlgeschlagen';

  @override
  String get allObjectivesCompleted => 'Alle Ziele erreicht';

  @override
  String get objectivesNotMet => 'Missionsziele nicht erreicht';

  @override
  String get rocketTitle => 'Rakete';

  @override
  String get payload => 'Nutzlast';

  @override
  String get orbit => 'Umlaufbahn';

  @override
  String get rocketDetails => 'Raketendetails';

  @override
  String get rocketName => 'Raketenname';

  @override
  String get rocketType => 'Typ';

  @override
  String get rocketBlock => 'Block';

  @override
  String get firstStage => '🚀 Erste Stufe';

  @override
  String get coreSerial => 'Kernseriennummer';

  @override
  String get flight => 'Flug';

  @override
  String get landing => 'Landung';

  @override
  String get landingSuccess => 'Landung erfolgreich';

  @override
  String get gridFins => 'Steuergitter';

  @override
  String get landingLegs => 'Landebeine';

  @override
  String get reused => 'Wiederverwendet';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get recoveryShips => 'Bergungsschiffe';

  @override
  String get payloadTitle => 'Nutzlast';

  @override
  String get id => 'Kennung';

  @override
  String get type => 'Typ';

  @override
  String get mass => 'Masse';

  @override
  String get manufacturer => 'Hersteller';

  @override
  String get nationality => 'Nationalität';

  @override
  String get customers => 'Kunden';

  @override
  String get missionOverview => 'Missionsübersicht';

  @override
  String get noDetails => 'Keine Details verfügbar';

  @override
  String get linksResources => 'Links & Ressourcen';

  @override
  String get watchVideo => 'Video ansehen';

  @override
  String get wikipedia => 'Wikipedia';

  @override
  String get article => 'Artikel';

  @override
  String get reddit => 'Reddit';

  @override
  String get pressKit => 'Pressemappe';

  @override
  String get launchSite => 'Startplatz';

  @override
  String get siteIdLabel => 'Standort-ID:';

  @override
  String flightNumber(Object number) {
    return 'Flug #$number';
  }

  @override
  String get rocketsTab => 'Raketen';

  @override
  String get activeStatus => 'Aktiv';

  @override
  String get retiredStatus => 'Außer Dienst';

  @override
  String successRate(Object percentage) {
    return '$percentage% Erfolg';
  }

  @override
  String get rocketsTitle => 'Raketen';

  @override
  String get overview => 'Übersicht';

  @override
  String get specifications => 'Spezifikationen';

  @override
  String get payloadCapacity => 'Nutzlastkapazität';

  @override
  String get engineDetails => 'Motordetails';

  @override
  String get heightLabel => 'Höhe';

  @override
  String get diameterLabel => 'Durchmesser';

  @override
  String get massLabel => 'Masse';

  @override
  String get stagesLabel => 'Stufen';

  @override
  String get typeLabel => 'Typ';

  @override
  String get versionLabel => 'Version';

  @override
  String get numberLabel => 'Anzahl';

  @override
  String get propellant1Label => 'Treibstoff 1';

  @override
  String get propellant2Label => 'Treibstoff 2';

  @override
  String get thrustSeaLevelLabel => 'Schub (Bodenniveau)';

  @override
  String get tons => 'Tonnen';

  @override
  String get learnMore => 'Mehr erfahren';

  @override
  String get launchInformation => 'Startinformationen';

  @override
  String get launchMass => 'Startmasse';

  @override
  String get launchVehicle => 'Startfahrzeug';

  @override
  String get orbitalParameters => 'Orbitale Parameter';

  @override
  String get millionKm => 'Millionen km';

  @override
  String get missionDetails => 'Missionsdetails';

  @override
  String get trackLive => 'Live verfolgen';

  @override
  String get marsDistance => 'Abstand zum Mars';

  @override
  String get earthDistance => 'Abstand zur Erde';

  @override
  String get currentSpeed => 'Aktuelle Geschwindigkeit';

  @override
  String get orbitalPeriod => 'Orbitale Periode';

  @override
  String get unitDays => 'Tage';

  @override
  String get unitKph => 'km/h';

  @override
  String launched(Object date) {
    return 'Gestartet: $date';
  }

  @override
  String get roadsterTitle => 'Roadster';

  @override
  String get roadsterDescription => 'Elon Musks Tesla Roadster';

  @override
  String get apoapsis => 'Aphel';

  @override
  String get periapsis => 'Perihel';

  @override
  String get semiMajorAxis => 'Große Halbachse';

  @override
  String get eccentricity => 'Exzentrizität';

  @override
  String get inclination => 'Inklination';

  @override
  String get longitude => 'Längengrad';

  @override
  String get core_status_active => 'active';

  @override
  String get core_status_lost => 'lost';

  @override
  String get core_status_inactive => 'inactive';

  @override
  String get core_status_unknown => 'unknown';

  @override
  String get errorLoadingCores => 'Error loading cores';

  @override
  String get retry => 'Retry';

  @override
  String get firstLaunch => 'First Launch';

  @override
  String missions(Object count) {
    return '$count missions';
  }

  @override
  String reuses(Object count) {
    return '$count reuses';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get na => 'N/A';

  @override
  String get core_filter_status_all => 'All';

  @override
  String get core_filter_status_active => 'Active';

  @override
  String get core_filter_status_lost => 'Lost';

  @override
  String get core_filter_status_inactive => 'Inactive';

  @override
  String get core_filter_status_unknown => 'Unknown';

  @override
  String get core_filter_search_hint => 'Search cores or missions...';

  @override
  String noCoresFound(Object query) {
    return 'No cores found for \"$query\"';
  }

  @override
  String blockLabel(Object blockNumber) {
    return 'Block $blockNumber';
  }

  @override
  String get spaceXCoresTitle => 'SpaceX Falcon Cores';

  @override
  String get coresLabel => 'Cores';

  @override
  String get selectRoleTitle => 'Select Role';

  @override
  String get selectRoleSubtitle => 'Swipe to explore';

  @override
  String continueWithRole(Object role) {
    return 'Continue with $role';
  }

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleOrganization => 'Organization';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSubtitle => 'Welcome back';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Login';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Start your learning journey';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter username';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get registerButton => 'Register';

  @override
  String get agreeToTerms => 'I agree to the';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get otpTitle => 'OTP Verification';

  @override
  String otpSubtitle(Object email) {
    return 'Enter the OTP sent to $email';
  }

  @override
  String get resendOtp => 'Resend code';

  @override
  String resendOtpIn(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verifyButton => 'Verify';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle => 'Enter email to receive recovery code';

  @override
  String get sendResetCode => 'Send Recovery Code';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get newPasswordHint => 'Enter new password';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get bioLabel => 'Bio';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get securityTitle => 'Security';

  @override
  String get linkedAccounts => 'Linked Accounts';

  @override
  String get devices => 'Logged In Devices';

  @override
  String get logoutAllDevices => 'Logout All Devices';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get errorInvalidOtp => 'Invalid OTP code';

  @override
  String get errorNetworkError => 'Network connection error';

  @override
  String get errorUnknown => 'An error occurred';

  @override
  String get languageTitle => 'Language';

  @override
  String get students => 'Students';

  @override
  String get courses => 'Courses';

  @override
  String get rating => 'Rating';

  @override
  String get viewAll => 'View All';

  @override
  String get featuredCourses => 'Featured Courses';

  @override
  String get editCover => 'Edit Cover';

  @override
  String get xpPoints => 'XP Points';

  @override
  String get streak => 'Streak';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabAchievements => 'Achievements';

  @override
  String get tabChildren => 'Children';

  @override
  String get tabNotifications => 'Notifications';

  @override
  String joinedOn(Object date) {
    return 'Joined $date';
  }

  @override
  String get accountInfo => 'Account Information';

  @override
  String get notUpdated => 'Not updated';

  @override
  String get joinedDate => 'Joined Date';

  @override
  String get options => 'Options';

  @override
  String get switchRole => 'Switch Role';

  @override
  String get skills => 'Skills';

  @override
  String get interests => 'Interests';

  @override
  String get achievements => 'Achievements';

  @override
  String get contact => 'Contact';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get thisMonth => 'this month';

  @override
  String get parentOverview => 'Parent Overview';

  @override
  String get children => 'Children';

  @override
  String get notifications => 'Notifications';

  @override
  String get classes => 'Classes';

  @override
  String get passwordAndSecurity => 'Password & Security';

  @override
  String get loginSection => 'Login';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordHint =>
      'Use a strong password you don\'t use elsewhere';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get loggedOutAllDevices => 'Logged out all devices';

  @override
  String unlinkedAccount(Object provider) {
    return 'Unlinked $provider';
  }

  @override
  String get whereYouLoggedIn => 'Where you\'re logged in';

  @override
  String get logoutAll => 'Logout All';

  @override
  String get advanced => 'Advanced';

  @override
  String get securityEmails => 'Security notification emails';

  @override
  String get securityEmailsHint => 'View official emails from us';

  @override
  String get activityHistory => 'Activity history';

  @override
  String get activityHistoryHint => 'View all account-related actions';

  @override
  String accountId(Object id) {
    return 'Account ID: $id';
  }

  @override
  String get logoutAllDevicesTitle => 'Logout all devices';

  @override
  String get logoutAllDevicesContent =>
      'You will be logged out of all devices, including this one. You will need to log in again.';

  @override
  String unlinkAccount(Object provider) {
    return 'Unlink $provider';
  }

  @override
  String unlinkAccountContent(Object provider) {
    return 'You will not be able to log in with $provider after unlinking. Are you sure?';
  }

  @override
  String get unlink => 'Unlink';

  @override
  String linkOnlyProduction(Object provider) {
    return 'Linking $provider is only available in production';
  }

  @override
  String get serverNotConfigured => 'Server not configured';

  @override
  String get cannotOpenBrowser => 'Cannot open browser';

  @override
  String cannotLink(Object provider) {
    return 'Cannot link with $provider';
  }

  @override
  String get noDevices => 'No devices found';

  @override
  String get reload => 'Reload';

  @override
  String get thisDevice => 'This device';

  @override
  String get unknownDevice => 'Unknown device';

  @override
  String linkWith(Object provider) {
    return 'Link with $provider';
  }

  @override
  String get loginWithThisProfile => 'Login with this profile';

  @override
  String get swipeToChangeProfile => 'Swipe to change profile';

  @override
  String get organizationProfile => 'Organization profile';

  @override
  String get systemProfile => 'System profile';

  @override
  String get chooseProfileTitle => 'Choose profile';

  @override
  String get chooseProfileSubtitle =>
      'You have multiple profiles. Choose one to continue.';

  @override
  String get achievementTitle => 'Achievement';

  @override
  String get allBadges => 'All Badges';

  @override
  String badgesEarned(Object earned, Object total) {
    return '$earned / $total badges earned';
  }

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get earned => 'Earned';

  @override
  String get inProgress => 'In Progress';

  @override
  String get notEarned => 'Not Earned';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get learning => 'Learning';

  @override
  String get habit => 'Habit';

  @override
  String get achievement => 'Achievement';

  @override
  String get status => 'Status';

  @override
  String get category => 'Category';

  @override
  String get apply => 'Apply';

  @override
  String get close => 'Close';

  @override
  String get newBadge => 'NEW';

  @override
  String get certificate => 'Certificate';

  @override
  String get yourCertificates => 'Your Certificates';

  @override
  String certificatesEarned(Object count) {
    return '$count certificates earned';
  }

  @override
  String get completed => 'Completed';

  @override
  String get studying => 'Studying';

  @override
  String get design => 'Design';

  @override
  String get programming => 'Programming';

  @override
  String get business => 'Business';

  @override
  String get language => 'Language';

  @override
  String get lessons => 'lessons';

  @override
  String get certificateDetail => 'Certificate Detail';

  @override
  String get certificateConfirm =>
      'This certificate confirms you have completed the course and mastered the fundamentals.';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String get addToLinkedIn => 'Add to\nLinkedIn';

  @override
  String get printCertificate => 'Print';

  @override
  String get courseInfo => 'Course Information';

  @override
  String get course => 'Course';

  @override
  String get completionDate => 'Completion Date';

  @override
  String get duration => 'Duration';

  @override
  String get instructor => 'Instructor';

  @override
  String get level => 'Level';

  @override
  String get basic => 'Basic';

  @override
  String get skillsEarned => 'Skills Earned';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get showQrCode => 'Show QR Code';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get viewCertificate => 'View Certificate';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get recentBadges => 'Recent Badges';

  @override
  String get learningActivity => 'Learning Activity';

  @override
  String daysLearned(Object count) {
    return '$count days learned';
  }

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get learningTrend => 'Learning Trend';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get minutes => 'min';

  @override
  String get studyHours => 'Study Hours';

  @override
  String get completedLessons => 'Completed Lessons';

  @override
  String get badges => 'Badges';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get yourAccount => 'Your account';

  @override
  String get switchProfile => 'Switch profile';

  @override
  String get addProfile => 'Add profile';

  @override
  String get updatePersonalDetails => 'Update your personal details';

  @override
  String get passwordSecurityHint => 'Password, 2FA, login devices';

  @override
  String get subscription => 'Subscription';

  @override
  String get managePlanBilling => 'Manage your plan and billing';

  @override
  String get customizeNotifications => 'Customize your notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get managePrivacySettings => 'Manage your privacy settings';

  @override
  String get general => 'General';

  @override
  String get helpCenter => 'Help center';

  @override
  String get faqAndSupport => 'FAQ and support';

  @override
  String version(Object version) {
    return 'Version $version';
  }

  @override
  String get signOutHint => 'Sign out from your current account';

  @override
  String get premium => 'Premium';

  @override
  String get student => 'Student';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get bioHint => 'Tell us about yourself...';

  @override
  String get verified => 'Verified';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get myPortfolio => 'My Portfolio';

  @override
  String get editPortfolio => 'Edit';

  @override
  String get previewPortfolio => 'Preview';

  @override
  String get introduction => 'Introduction';

  @override
  String get featuredProjects => 'Featured Projects';

  @override
  String get experience => 'Experience';

  @override
  String get education => 'Education';

  @override
  String get yearsExperience => 'Years experience';

  @override
  String get projectsCompleted => 'Projects completed';

  @override
  String get followers => 'Followers';

  @override
  String get addProject => 'Add project';

  @override
  String get addExperience => 'Add experience';

  @override
  String get addEducation => 'Add education';

  @override
  String get addSkill => 'Add skill';

  @override
  String get present => 'Present';

  @override
  String get customizePortfolio => 'Customize portfolio';

  @override
  String get manageLayout => 'Manage layout';

  @override
  String get toggleVisibility => 'Toggle section visibility';

  @override
  String get publicPortfolio => 'Public';

  @override
  String get privatePortfolio => 'Only me';

  @override
  String get linkOnlyPortfolio => 'People with link';

  @override
  String get saved => 'Saved';

  @override
  String get saving => 'Saving...';

  @override
  String get viewPortfolio => 'View Portfolio';

  @override
  String get projectName => 'Project name';

  @override
  String get projectNameHint => 'E.g: EduFlow';

  @override
  String get shortDescription => 'Short description';

  @override
  String get shortDescriptionHint => 'E.g: Learning management system';

  @override
  String get details => 'Details';

  @override
  String get categoryLabel => 'Category';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get skillName => 'Skill name';

  @override
  String get skillNameHint => 'E.g: UI Design, Figma, React...';

  @override
  String get proficiencyLevel => 'Proficiency level';

  @override
  String get position => 'Position';

  @override
  String get positionHint => 'E.g: UI/UX Designer';

  @override
  String get company => 'Company';

  @override
  String get companyHint => 'E.g: Google, Vela Studio...';

  @override
  String get jobDescription => 'Job description';

  @override
  String get editIntroduction => 'Edit introduction';

  @override
  String get fullName => 'Full name';

  @override
  String get jobTitle => 'Job title';

  @override
  String get jobTitleHint => 'E.g: UI/UX Designer';

  @override
  String get locationLabel => 'Location';

  @override
  String get locationHint => 'E.g: Hanoi, Vietnam';

  @override
  String get websiteLabel => 'Website';

  @override
  String get websiteHint => 'E.g: yourname.design';

  @override
  String get aboutYourself => 'About yourself';

  @override
  String get aboutYourselfHint => 'Write a few lines about you...';

  @override
  String get dragToReorder => 'Drag to reorder sections';

  @override
  String get privacySettings => 'Privacy';

  @override
  String get everyoneCanView => 'Everyone can view';

  @override
  String get onlyYouCanView => 'Only you can view';

  @override
  String get onlyWithLink => 'Only people with link can view';

  @override
  String get linkCopiedToShare => 'Link copied for sharing';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get creatingPdf => 'Creating PDF...';

  @override
  String get viewAsOthers => 'View portfolio as others see it';

  @override
  String get shareOnSocial => 'Share portfolio on social media';

  @override
  String get copyPortfolioLink => 'Copy portfolio link';

  @override
  String get downloadPortfolioPdf => 'Download portfolio as PDF';

  @override
  String get addItem => 'Add item';
}
