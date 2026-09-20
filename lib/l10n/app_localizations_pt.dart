// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => '40Study';

  @override
  String get itemsTitle => 'Artigos de Exemplo';

  @override
  String get emailsTitle => 'E-mails';

  @override
  String get launchesTitle => 'Lançamentos';

  @override
  String itemTitle(Object id) {
    return 'Artigo de Exemplo $id';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearanceTitle => 'Aparência';

  @override
  String get dynamicColorSettingsItemTitle => 'Usar cores dinâmicas';

  @override
  String get dynamicColorSettingsItemDescription =>
      'Adaptar as cores do app ao papel de parede';

  @override
  String get darkThemeSettingsItemTitle => 'Modo de tema';

  @override
  String get darkThemeOnSettingsItemTitle => 'Escuro';

  @override
  String get darkThemeOffSettingsItemTitle => 'Claro';

  @override
  String get darkThemeFollowSystemSettingsItemTitle => 'Padrão do sistema';

  @override
  String get tryAgainButton => 'Tentar novamente';

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
    return 'Missão: $mission';
  }

  @override
  String launchedAt(Object launchedAt) {
    return 'Lançado em: $launchedAt';
  }

  @override
  String rocket(Object rocketName, Object rocketType) {
    return 'Foguete: $rocketName ($rocketType)';
  }

  @override
  String daysSinceTodayTitle(Object days) {
    return 'Há $days dias';
  }

  @override
  String daysFromTodayTitle(Object days) {
    return 'Em $days dias';
  }

  @override
  String get themeTitle => 'Tema';

  @override
  String get systemThemeTitle => 'Tema do Sistema';

  @override
  String get lightThemeTitle => 'Tema Claro';

  @override
  String get darkThemeTitle => 'Tema Escuro';

  @override
  String get lightGoldThemeTitle => 'Tema Dourado Claro';

  @override
  String get darkGoldThemeTitle => 'Tema Dourado Escuro';

  @override
  String get lightMintThemeTitle => 'Tema Menta Claro';

  @override
  String get darkMintThemeTitle => 'Tema Menta Escuro';

  @override
  String get experimentalThemeTitle => 'Experimental Theme';

  @override
  String get itemDetailsTitle => 'Detalhes do Artigo';

  @override
  String get error => 'Erro';

  @override
  String get emptyList => 'Lista Vazia';

  @override
  String get tabHome => 'Início';

  @override
  String get tabSettings => 'Configurações';

  @override
  String get newsScreen => 'Notícias';

  @override
  String get disabledButtonTitle => 'Desativado';

  @override
  String get disabledRoundedButtonTitle => 'Desativado com Bordas Arredondadas';

  @override
  String get disabledWithIconButtonTitle => 'Desativado com Ícone';

  @override
  String get enabledButtonTitle => 'Ativado';

  @override
  String get borderRadiusButtonTitle => 'Raio da Borda';

  @override
  String get borderSideButtonTitle => 'Lado da Borda';

  @override
  String get iconButtonTitle => 'Com Ícone';

  @override
  String get iconAndPaddingButtonTitle => 'Com Ícone e Espaçamento';

  @override
  String get transparentButtonTitle => 'Transparente';

  @override
  String get missionTimeline => 'Cronograma da Missão';

  @override
  String get staticFireTest => 'Teste de Fogo Estático';

  @override
  String get launch => 'Lançamento';

  @override
  String get missionSuccess => 'Sucesso da Missão';

  @override
  String get objectivesCompleted => 'Objetivos Concluídos';

  @override
  String get missionSuccessful => 'Missão bem-sucedida';

  @override
  String get missionFailed => 'Missão falhou';

  @override
  String get allObjectivesCompleted => 'Todos os objetivos concluídos';

  @override
  String get objectivesNotMet => 'Objetivos da missão não alcançados';

  @override
  String get rocketTitle => 'Foguete';

  @override
  String get payload => 'Carga útil';

  @override
  String get orbit => 'Órbita';

  @override
  String get rocketDetails => 'Detalhes do Foguete';

  @override
  String get rocketName => 'Nome do Foguete';

  @override
  String get rocketType => 'Tipo';

  @override
  String get rocketBlock => 'Bloco';

  @override
  String get firstStage => '🚀 Primeiro Estágio';

  @override
  String get coreSerial => 'Número de Série do Núcleo';

  @override
  String get flight => 'Voo';

  @override
  String get landing => 'Pouso';

  @override
  String get landingSuccess => 'Pouso bem-sucedido';

  @override
  String get gridFins => 'Aletas de grade';

  @override
  String get landingLegs => 'Pernas de pouso';

  @override
  String get reused => 'Reutilizado';

  @override
  String get notAvailable => 'N/D';

  @override
  String get recoveryShips => 'Navios de Recuperação';

  @override
  String get payloadTitle => 'Carga útil';

  @override
  String get id => 'ID';

  @override
  String get type => 'Tipo';

  @override
  String get mass => 'Massa';

  @override
  String get manufacturer => 'Fabricante';

  @override
  String get nationality => 'Nacionalidade';

  @override
  String get customers => 'Clientes';

  @override
  String get missionOverview => 'Visão geral da missão';

  @override
  String get noDetails => 'Nenhum detalhe disponível';

  @override
  String get linksResources => 'Links e Recursos';

  @override
  String get watchVideo => 'Assistir Vídeo';

  @override
  String get wikipedia => 'Wikipédia';

  @override
  String get article => 'Artigo';

  @override
  String get reddit => 'Reddit';

  @override
  String get pressKit => 'Kit de Imprensa';

  @override
  String get launchSite => 'Local de Lançamento';

  @override
  String get siteIdLabel => 'ID do Local:';

  @override
  String flightNumber(Object number) {
    return 'Voo #$number';
  }

  @override
  String get rocketsTab => 'Foguetes';

  @override
  String get activeStatus => 'Ativa';

  @override
  String get retiredStatus => 'Aposentada';

  @override
  String successRate(Object percentage) {
    return '$percentage% de sucesso';
  }

  @override
  String get rocketsTitle => 'Foguetes';

  @override
  String get overview => 'Visão Geral';

  @override
  String get specifications => 'Especificações';

  @override
  String get payloadCapacity => 'Capacidade de Carga';

  @override
  String get engineDetails => 'Detalhes do Motor';

  @override
  String get heightLabel => 'Altura';

  @override
  String get diameterLabel => 'Diâmetro';

  @override
  String get massLabel => 'Massa';

  @override
  String get stagesLabel => 'Estágios';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get versionLabel => 'Versão';

  @override
  String get numberLabel => 'Número';

  @override
  String get propellant1Label => 'Propelente 1';

  @override
  String get propellant2Label => 'Propelente 2';

  @override
  String get thrustSeaLevelLabel => 'Empuxo (nível do mar)';

  @override
  String get tons => 'toneladas';

  @override
  String get learnMore => 'Saiba mais';

  @override
  String get launchInformation => 'Informações do lançamento';

  @override
  String get launchMass => 'Massa do lançamento';

  @override
  String get launchVehicle => 'Veículo de lançamento';

  @override
  String get orbitalParameters => 'Parâmetros orbitais';

  @override
  String get millionKm => 'milhões km';

  @override
  String get missionDetails => 'Detalhes da missão';

  @override
  String get trackLive => 'Acompanhar ao vivo';

  @override
  String get marsDistance => 'Distância a Marte';

  @override
  String get earthDistance => 'Distância à Terra';

  @override
  String get currentSpeed => 'Velocidade Atual';

  @override
  String get orbitalPeriod => 'Período Orbital';

  @override
  String get unitDays => 'dias';

  @override
  String get unitKph => 'km/h';

  @override
  String launched(Object date) {
    return 'Lançado: $date';
  }

  @override
  String get roadsterTitle => 'Roadster';

  @override
  String get roadsterDescription => 'Tesla Roadster de Elon Musk';

  @override
  String get apoapsis => 'Apoápse';

  @override
  String get periapsis => 'Periápse';

  @override
  String get semiMajorAxis => 'Eixo semi-maior';

  @override
  String get eccentricity => 'Excentricidade';

  @override
  String get inclination => 'Inclinação';

  @override
  String get longitude => 'Longitude';

  @override
  String get core_status_active => 'ativo';

  @override
  String get core_status_lost => 'perdido';

  @override
  String get core_status_inactive => 'inativo';

  @override
  String get core_status_unknown => 'desconhecido';

  @override
  String get errorLoadingCores => 'Erro ao carregar núcleos';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get firstLaunch => 'Primeiro lançamento';

  @override
  String missions(Object count) {
    return '$count missões';
  }

  @override
  String reuses(Object count) {
    return '$count reutilizações';
  }

  @override
  String get unknown => 'Desconhecido';

  @override
  String get na => 'N/D';

  @override
  String get core_filter_status_all => 'Todos';

  @override
  String get core_filter_status_active => 'Ativo';

  @override
  String get core_filter_status_lost => 'Perdido';

  @override
  String get core_filter_status_inactive => 'Inativo';

  @override
  String get core_filter_status_unknown => 'Desconhecido';

  @override
  String get core_filter_search_hint => 'Pesquisar núcleos ou missões...';

  @override
  String noCoresFound(Object query) {
    return 'Nenhum núcleo encontrado para \"$query\"';
  }

  @override
  String blockLabel(Object blockNumber) {
    return 'Bloco $blockNumber';
  }

  @override
  String get spaceXCoresTitle => 'Núcleos Falcon da SpaceX';

  @override
  String get coresLabel => 'Núcleos';

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
