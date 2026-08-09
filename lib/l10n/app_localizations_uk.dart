// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => '40Study';

  @override
  String get itemsTitle => 'Приклади елементів';

  @override
  String get emailsTitle => 'Електронні листи';

  @override
  String get launchesTitle => 'Запуски';

  @override
  String itemTitle(Object id) {
    return 'Приклад елементу $id';
  }

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get appearanceTitle => 'Зовнішній вигляд';

  @override
  String get dynamicColorSettingsItemTitle =>
      'Використовувати динамічні кольори';

  @override
  String get dynamicColorSettingsItemDescription =>
      'Адаптувати кольори додатку до шпалер';

  @override
  String get darkThemeSettingsItemTitle => 'Режим теми';

  @override
  String get darkThemeOnSettingsItemTitle => 'Темна';

  @override
  String get darkThemeOffSettingsItemTitle => 'Світла';

  @override
  String get darkThemeFollowSystemSettingsItemTitle =>
      'Системна за замовчуванням';

  @override
  String get tryAgainButton => 'Спробувати ще раз';

  @override
  String get appearanceSettingsItem => 'Зовнішній вигляд';

  @override
  String get appearanceSettingsItemDescription =>
      'Темна тема, динамічні кольори, мови';

  @override
  String get aboutSettingsItem => 'Про додаток';

  @override
  String get aboutSettingsItemDescription => 'Версія, посилання, відгуки';

  @override
  String missionTitle(Object mission) {
    return 'Місія: $mission';
  }

  @override
  String launchedAt(Object launchedAt) {
    return 'Запущено: $launchedAt';
  }

  @override
  String rocket(Object rocketName, Object rocketType) {
    return 'Ракета: $rocketName ($rocketType)';
  }

  @override
  String daysSinceTodayTitle(Object days) {
    return '$days днів тому';
  }

  @override
  String daysFromTodayTitle(Object days) {
    return 'Через $days днів';
  }

  @override
  String get themeTitle => 'Тема';

  @override
  String get systemThemeTitle => 'Системна тема';

  @override
  String get lightThemeTitle => 'Світла тема';

  @override
  String get darkThemeTitle => 'Темна тема';

  @override
  String get lightGoldThemeTitle => 'Світле золото';

  @override
  String get darkGoldThemeTitle => 'Темне золото';

  @override
  String get lightMintThemeTitle => 'Світла м’ята';

  @override
  String get darkMintThemeTitle => 'Темна м’ята';

  @override
  String get experimentalThemeTitle => 'Експериментальна тема';

  @override
  String get itemDetailsTitle => 'Деталі елементу';

  @override
  String get error => 'Помилка';

  @override
  String get emptyList => 'Список порожній';

  @override
  String get tabHome => 'Головна';

  @override
  String get tabSettings => 'Налаштування';

  @override
  String get newsScreen => 'Новини';

  @override
  String get disabledButtonTitle => 'Вимкнено';

  @override
  String get disabledRoundedButtonTitle => 'Вимкнено (кругла)';

  @override
  String get disabledWithIconButtonTitle => 'Вимкнено з іконкою';

  @override
  String get enabledButtonTitle => 'Увімкнено';

  @override
  String get borderRadiusButtonTitle => 'Радіус кордону';

  @override
  String get borderSideButtonTitle => 'Кордона сторона';

  @override
  String get iconButtonTitle => 'З іконкою';

  @override
  String get iconAndPaddingButtonTitle => 'З іконкою та відступом';

  @override
  String get transparentButtonTitle => 'Прозора';

  @override
  String get missionTimeline => 'Хронологія місії';

  @override
  String get staticFireTest => 'Статичний вогневий тест';

  @override
  String get launch => 'Запуск';

  @override
  String get missionSuccess => 'Місія успішна';

  @override
  String get objectivesCompleted => 'Цілі досягнуті';

  @override
  String get missionSuccessful => 'Місія успішна';

  @override
  String get missionFailed => 'Місія не вдалася';

  @override
  String get allObjectivesCompleted => 'Всі цілі досягнуті';

  @override
  String get objectivesNotMet => 'Цілі місії не досягнуті';

  @override
  String get rocketTitle => 'Ракета';

  @override
  String get payload => 'Корисне навантаження';

  @override
  String get orbit => 'Орбіта';

  @override
  String get rocketDetails => 'Деталі ракети';

  @override
  String get rocketName => 'Назва ракети';

  @override
  String get rocketType => 'Тип';

  @override
  String get rocketBlock => 'Блок';

  @override
  String get firstStage => '🚀 Перша ступінь';

  @override
  String get coreSerial => 'Серійний номер ядра';

  @override
  String get flight => 'Політ';

  @override
  String get landing => 'Приземлення';

  @override
  String get landingSuccess => 'Приземлення успішне';

  @override
  String get gridFins => 'Сітчасті кермові';

  @override
  String get landingLegs => 'Ноги приземлення';

  @override
  String get reused => 'Повторне використання';

  @override
  String get notAvailable => 'Н/Д';

  @override
  String get recoveryShips => 'Судна порятунку';

  @override
  String get payloadTitle => 'Корисне навантаження';

  @override
  String get id => 'ID';

  @override
  String get type => 'Тип';

  @override
  String get mass => 'Маса';

  @override
  String get manufacturer => 'Виробник';

  @override
  String get nationality => 'Національність';

  @override
  String get customers => 'Клієнти';

  @override
  String get missionOverview => 'Огляд місії';

  @override
  String get noDetails => 'Деталі відсутні';

  @override
  String get linksResources => 'Посилання та ресурси';

  @override
  String get watchVideo => 'Дивитися відео';

  @override
  String get wikipedia => 'Вікіпедія';

  @override
  String get article => 'Стаття';

  @override
  String get reddit => 'Reddit';

  @override
  String get pressKit => 'Прес-кит';

  @override
  String get launchSite => 'Місце запуску';

  @override
  String get siteIdLabel => 'ID сайту:';

  @override
  String flightNumber(Object number) {
    return 'Політ #$number';
  }

  @override
  String get rocketsTab => 'Ракети';

  @override
  String get activeStatus => 'Активна';

  @override
  String get retiredStatus => 'Знято з експлуатації';

  @override
  String successRate(Object percentage) {
    return '$percentage% успішних запусків';
  }

  @override
  String get rocketsTitle => 'Ракети';

  @override
  String get overview => 'Огляд';

  @override
  String get specifications => 'Технічні характеристики';

  @override
  String get payloadCapacity => 'Корисне навантаження';

  @override
  String get engineDetails => 'Деталі двигуна';

  @override
  String get heightLabel => 'Висота';

  @override
  String get diameterLabel => 'Діаметр';

  @override
  String get massLabel => 'Маса';

  @override
  String get stagesLabel => 'Стадії';

  @override
  String get typeLabel => 'Тип';

  @override
  String get versionLabel => 'Версія';

  @override
  String get numberLabel => 'Кількість';

  @override
  String get propellant1Label => 'Паливо 1';

  @override
  String get propellant2Label => 'Паливо 2';

  @override
  String get thrustSeaLevelLabel => 'Тяга (на рівні моря)';

  @override
  String get tons => 'тонн';

  @override
  String get learnMore => 'Дізнатися більше';

  @override
  String get launchInformation => 'Інформація про запуск';

  @override
  String get launchMass => 'Маса запуску';

  @override
  String get launchVehicle => 'Ракета-носій';

  @override
  String get orbitalParameters => 'Орбітальні параметри';

  @override
  String get millionKm => 'мільйон км';

  @override
  String get missionDetails => 'Деталі місії';

  @override
  String get trackLive => 'Слідкувати онлайн';

  @override
  String get marsDistance => 'Відстань до Марса';

  @override
  String get earthDistance => 'Відстань до Землі';

  @override
  String get currentSpeed => 'Поточна швидкість';

  @override
  String get orbitalPeriod => 'Орбітальний період';

  @override
  String get unitDays => 'днів';

  @override
  String get unitKph => 'км/год';

  @override
  String launched(Object date) {
    return 'Запуск: $date';
  }

  @override
  String get roadsterTitle => 'Роадстер';

  @override
  String get roadsterDescription => 'Tesla Roadster Ілона Маска';

  @override
  String get apoapsis => 'Апоцентр';

  @override
  String get periapsis => 'Перицентр';

  @override
  String get semiMajorAxis => 'Велика піввісь';

  @override
  String get eccentricity => 'Ексцентриситет';

  @override
  String get inclination => 'Нахил';

  @override
  String get longitude => 'Довгота';

  @override
  String get core_status_active => 'активний';

  @override
  String get core_status_lost => 'втрачений';

  @override
  String get core_status_inactive => 'неактивний';

  @override
  String get core_status_unknown => 'невідомий';

  @override
  String get errorLoadingCores => 'Помилка завантаження ядер';

  @override
  String get retry => 'Повторити';

  @override
  String get firstLaunch => 'Перший запуск';

  @override
  String missions(Object count) {
    return '$count місій';
  }

  @override
  String reuses(Object count) {
    return '$count повторів';
  }

  @override
  String get unknown => 'Невідомо';

  @override
  String get na => 'Н/Д';

  @override
  String get core_filter_status_all => 'Усі';

  @override
  String get core_filter_status_active => 'Активний';

  @override
  String get core_filter_status_lost => 'Втрачений';

  @override
  String get core_filter_status_inactive => 'Неактивний';

  @override
  String get core_filter_status_unknown => 'Невідомо';

  @override
  String get core_filter_search_hint => 'Пошук ядер або місій...';

  @override
  String noCoresFound(Object query) {
    return 'Ядра за запитом \"$query\" не знайдено';
  }

  @override
  String blockLabel(Object blockNumber) {
    return 'Блок $blockNumber';
  }

  @override
  String get spaceXCoresTitle => 'Супутникові ядра Falcon від SpaceX';

  @override
  String get coresLabel => 'Ядра';

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
