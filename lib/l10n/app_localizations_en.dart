// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '40Study';

  @override
  String get itemsTitle => 'Sample Items';

  @override
  String get emailsTitle => 'Emails';

  @override
  String get launchesTitle => 'Launches';

  @override
  String itemTitle(Object id) {
    return 'Sample Item $id';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get dynamicColorSettingsItemTitle => 'Use dynamic colors';

  @override
  String get dynamicColorSettingsItemDescription =>
      'Adapt app colors to your wallpaper';

  @override
  String get darkThemeSettingsItemTitle => 'Theme mode';

  @override
  String get darkThemeOnSettingsItemTitle => 'Dark';

  @override
  String get darkThemeOffSettingsItemTitle => 'Light';

  @override
  String get darkThemeFollowSystemSettingsItemTitle => 'System default';

  @override
  String get tryAgainButton => 'Try Again';

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
    return 'Launched at: $launchedAt';
  }

  @override
  String rocket(Object rocketName, Object rocketType) {
    return 'Rocket: $rocketName ($rocketType)';
  }

  @override
  String daysSinceTodayTitle(Object days) {
    return '$days days ago';
  }

  @override
  String daysFromTodayTitle(Object days) {
    return 'In $days days';
  }

  @override
  String get themeTitle => 'Theme';

  @override
  String get systemThemeTitle => 'System Theme';

  @override
  String get lightThemeTitle => 'Light Theme';

  @override
  String get darkThemeTitle => 'Dark Theme';

  @override
  String get lightGoldThemeTitle => 'Light Gold';

  @override
  String get darkGoldThemeTitle => 'Dark Gold';

  @override
  String get lightMintThemeTitle => 'Light Mint';

  @override
  String get darkMintThemeTitle => 'Dark Mint';

  @override
  String get experimentalThemeTitle => 'Experimental Theme';

  @override
  String get itemDetailsTitle => 'Item Details';

  @override
  String get error => 'Error';

  @override
  String get emptyList => 'Empty list';

  @override
  String get tabHome => 'Home';

  @override
  String get tabSettings => 'Settings';

  @override
  String get newsScreen => 'News';

  @override
  String get disabledButtonTitle => 'Disabled';

  @override
  String get disabledRoundedButtonTitle => 'Disabled Rounded';

  @override
  String get disabledWithIconButtonTitle => 'Disabled With Icon';

  @override
  String get enabledButtonTitle => 'Enabled';

  @override
  String get borderRadiusButtonTitle => 'BorderRadius';

  @override
  String get borderSideButtonTitle => 'BorderSide';

  @override
  String get iconButtonTitle => 'With Icon';

  @override
  String get iconAndPaddingButtonTitle => 'With Icon Padding';

  @override
  String get transparentButtonTitle => 'Transparent';

  @override
  String get missionTimeline => 'Mission Timeline';

  @override
  String get staticFireTest => 'Static Fire Test';

  @override
  String get launch => 'Launch';

  @override
  String get missionSuccess => 'Mission Success';

  @override
  String get objectivesCompleted => 'Objectives Completed';

  @override
  String get missionSuccessful => 'Mission Successful';

  @override
  String get missionFailed => 'Mission Failed';

  @override
  String get allObjectivesCompleted => 'All objectives completed';

  @override
  String get objectivesNotMet => 'Mission objectives not met';

  @override
  String get rocketTitle => 'Rocket';

  @override
  String get payload => 'Payload';

  @override
  String get orbit => 'Orbit';

  @override
  String get rocketDetails => 'Rocket Details';

  @override
  String get rocketName => 'Rocket Name';

  @override
  String get rocketType => 'Type';

  @override
  String get rocketBlock => 'Block';

  @override
  String get firstStage => '🚀 First Stage';

  @override
  String get coreSerial => 'Core Serial';

  @override
  String get flight => 'Flight';

  @override
  String get landing => 'Landing';

  @override
  String get landingSuccess => 'Landing Success';

  @override
  String get gridFins => 'Grid Fins';

  @override
  String get landingLegs => 'Landing Legs';

  @override
  String get reused => 'Reused';

  @override
  String get notAvailable => 'N/A';

  @override
  String get recoveryShips => 'Recovery Ships';

  @override
  String get payloadTitle => 'Payload';

  @override
  String get id => 'ID';

  @override
  String get type => 'Type';

  @override
  String get mass => 'Mass';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get nationality => 'Nationality';

  @override
  String get customers => 'Customers';

  @override
  String get missionOverview => 'Mission Overview';

  @override
  String get noDetails => 'No details available';

  @override
  String get linksResources => 'Links & Resources';

  @override
  String get watchVideo => 'Watch Video';

  @override
  String get wikipedia => 'Wikipedia';

  @override
  String get article => 'Article';

  @override
  String get reddit => 'Reddit';

  @override
  String get pressKit => 'Press Kit';

  @override
  String get launchSite => 'Launch Site';

  @override
  String get siteIdLabel => 'Site ID:';

  @override
  String flightNumber(Object number) {
    return 'Flight #$number';
  }

  @override
  String get rocketsTab => 'Rockets';

  @override
  String get activeStatus => 'Active';

  @override
  String get retiredStatus => 'Retired';

  @override
  String successRate(Object percentage) {
    return '$percentage% success';
  }

  @override
  String get rocketsTitle => 'Rockets';

  @override
  String get overview => 'Overview';

  @override
  String get specifications => 'Specifications';

  @override
  String get payloadCapacity => 'Payload Capacity';

  @override
  String get engineDetails => 'Engine Details';

  @override
  String get heightLabel => 'Height';

  @override
  String get diameterLabel => 'Diameter';

  @override
  String get massLabel => 'Mass';

  @override
  String get stagesLabel => 'Stages';

  @override
  String get typeLabel => 'Type';

  @override
  String get versionLabel => 'Version';

  @override
  String get numberLabel => 'Number';

  @override
  String get propellant1Label => 'Propellant 1';

  @override
  String get propellant2Label => 'Propellant 2';

  @override
  String get thrustSeaLevelLabel => 'Thrust (Sea Level)';

  @override
  String get tons => 'tons';

  @override
  String get learnMore => 'Learn More';

  @override
  String get launchInformation => 'Launch Information';

  @override
  String get launchMass => 'Launch Mass';

  @override
  String get launchVehicle => 'Launch Vehicle';

  @override
  String get orbitalParameters => 'Orbital Parameters';

  @override
  String get millionKm => 'million km';

  @override
  String get missionDetails => 'Mission Details';

  @override
  String get trackLive => 'Track Live';

  @override
  String get marsDistance => 'Mars Distance';

  @override
  String get earthDistance => 'Earth Distance';

  @override
  String get currentSpeed => 'Current Speed';

  @override
  String get orbitalPeriod => 'Orbital Period';

  @override
  String get unitDays => 'days';

  @override
  String get unitKph => 'km/h';

  @override
  String launched(Object date) {
    return 'Launched: $date';
  }

  @override
  String get roadsterTitle => 'Roadster';

  @override
  String get roadsterDescription => 'Elon Musk\'s Tesla Roadster';

  @override
  String get apoapsis => 'Apoapsis';

  @override
  String get periapsis => 'Periapsis';

  @override
  String get semiMajorAxis => 'Semi-major axis';

  @override
  String get eccentricity => 'Eccentricity';

  @override
  String get inclination => 'Inclination';

  @override
  String get longitude => 'Longitude';

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
}
