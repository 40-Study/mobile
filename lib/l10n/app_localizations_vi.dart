// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

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
  String get settingsTitle => 'Cài đặt';

  @override
  String get appearanceTitle => 'Giao diện';

  @override
  String get dynamicColorSettingsItemTitle => 'Use dynamic colors';

  @override
  String get dynamicColorSettingsItemDescription =>
      'Adapt app colors to your wallpaper';

  @override
  String get darkThemeSettingsItemTitle => 'Chế độ tối';

  @override
  String get darkThemeOnSettingsItemTitle => 'Tối';

  @override
  String get darkThemeOffSettingsItemTitle => 'Sáng';

  @override
  String get darkThemeFollowSystemSettingsItemTitle => 'Theo hệ thống';

  @override
  String get tryAgainButton => 'Thử lại';

  @override
  String get appearanceSettingsItem => 'Appearance';

  @override
  String get appearanceSettingsItemDescription =>
      'Dark theme dynamic color, languages';

  @override
  String get aboutSettingsItem => 'Thông tin';

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
  String get error => 'Lỗi';

  @override
  String get emptyList => 'Danh sách trống';

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
  String get overview => 'Tổng quan';

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
  String get selectRoleTitle => 'Chọn vai trò';

  @override
  String get selectRoleSubtitle => 'Vuốt để khám phá';

  @override
  String continueWithRole(Object role) {
    return 'Tiếp tục với $role';
  }

  @override
  String get tapToSelect => 'Nhấn để chọn';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản?';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get roleStudent => 'Học sinh';

  @override
  String get roleTeacher => 'Giáo viên';

  @override
  String get roleParent => 'Phụ huynh';

  @override
  String get roleOrganization => 'Tổ chức';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get loginSubtitle => 'Chào mừng bạn quay lại';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Nhập email của bạn';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get passwordHint => 'Nhập mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get orContinueWith => 'Hoặc tiếp tục với';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản?';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get registerSubtitle => 'Bắt đầu hành trình học tập';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get fullNameHint => 'Nhập họ và tên';

  @override
  String get usernameLabel => 'Tên đăng nhập';

  @override
  String get usernameHint => 'Nhập tên đăng nhập';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get confirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get agreeToTerms => 'Tôi đồng ý với';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get and => 'và';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get otpTitle => 'Xác thực OTP';

  @override
  String otpSubtitle(Object email) {
    return 'Nhập mã OTP đã gửi đến $email';
  }

  @override
  String get resendOtp => 'Gửi lại mã';

  @override
  String resendOtpIn(Object seconds) {
    return 'Gửi lại sau ${seconds}s';
  }

  @override
  String get verifyButton => 'Xác nhận';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordSubtitle => 'Nhập email để nhận mã khôi phục';

  @override
  String get sendResetCode => 'Gửi mã khôi phục';

  @override
  String get resetPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get newPasswordLabel => 'Mật khẩu mới';

  @override
  String get newPasswordHint => 'Nhập mật khẩu mới';

  @override
  String get resetPasswordButton => 'Đặt lại mật khẩu';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get editProfile => 'Chỉnh sửa hồ sơ';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get dateOfBirthLabel => 'Ngày sinh';

  @override
  String get bioLabel => 'Giới thiệu';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get changePasswordTitle => 'Đổi mật khẩu';

  @override
  String get currentPasswordLabel => 'Mật khẩu hiện tại';

  @override
  String get changePasswordButton => 'Đổi mật khẩu';

  @override
  String get securityTitle => 'Bảo mật';

  @override
  String get linkedAccounts => 'Tài khoản liên kết';

  @override
  String get devices => 'Thiết bị đăng nhập';

  @override
  String get logoutAllDevices => 'Đăng xuất tất cả thiết bị';

  @override
  String get deleteAccount => 'Xóa tài khoản';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutConfirm => 'Bạn có chắc muốn đăng xuất?';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get errorRequired => 'Trường này là bắt buộc';

  @override
  String get errorInvalidEmail => 'Email không hợp lệ';

  @override
  String get errorPasswordTooShort => 'Mật khẩu phải có ít nhất 8 ký tự';

  @override
  String get errorPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get errorInvalidOtp => 'Mã OTP không hợp lệ';

  @override
  String get errorNetworkError => 'Lỗi kết nối mạng';

  @override
  String get errorUnknown => 'Đã có lỗi xảy ra';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String get students => 'Học viên';

  @override
  String get courses => 'Khóa học';

  @override
  String get rating => 'Đánh giá';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get featuredCourses => 'Khóa học nổi bật';

  @override
  String get editCover => 'Sửa ảnh bìa';

  @override
  String get xpPoints => 'Điểm XP';

  @override
  String get streak => 'Streak';

  @override
  String get tabOverview => 'Tổng quan';

  @override
  String get tabAchievements => 'Thành tích';

  @override
  String get tabChildren => 'Con em';

  @override
  String get tabNotifications => 'Thông báo';

  @override
  String joinedOn(Object date) {
    return 'Tham gia từ $date';
  }

  @override
  String get accountInfo => 'Thông tin tài khoản';

  @override
  String get notUpdated => 'Chưa cập nhật';

  @override
  String get joinedDate => 'Ngày tham gia';

  @override
  String get options => 'Tùy chọn';

  @override
  String get switchRole => 'Chuyển đổi vai trò';

  @override
  String get skills => 'Kỹ năng';

  @override
  String get interests => 'Đang quan tâm';

  @override
  String get achievements => 'Thành tựu nổi bật';

  @override
  String get contact => 'Liên hệ';

  @override
  String get totalEarnings => 'Tổng thu nhập';

  @override
  String get thisMonth => 'tháng này';

  @override
  String get parentOverview => 'Tổng quan phụ huynh';

  @override
  String get children => 'Con em';

  @override
  String get notifications => 'Thông báo';

  @override
  String get classes => 'Lớp học';

  @override
  String get passwordAndSecurity => 'Mật khẩu & Bảo mật';

  @override
  String get loginSection => 'Đăng nhập';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get changePasswordHint =>
      'Nên sử dụng mật khẩu mạnh mà bạn không dùng ở nơi khác';

  @override
  String get passwordChangedSuccess => 'Đổi mật khẩu thành công';

  @override
  String get loggedOutAllDevices => 'Đã đăng xuất tất cả thiết bị';

  @override
  String unlinkedAccount(Object provider) {
    return 'Đã hủy liên kết $provider';
  }

  @override
  String get whereYouLoggedIn => 'Nơi bạn đã đăng nhập';

  @override
  String get logoutAll => 'Đăng xuất tất cả';

  @override
  String get advanced => 'Nâng cao';

  @override
  String get securityEmails => 'Email thông báo bảo mật';

  @override
  String get securityEmailsHint =>
      'Xem danh sách các email chính thức từ chúng tôi';

  @override
  String get activityHistory => 'Lịch sử hoạt động';

  @override
  String get activityHistoryHint =>
      'Xem tất cả các hành động liên quan đến tài khoản';

  @override
  String accountId(Object id) {
    return 'ID tài khoản: $id';
  }

  @override
  String get logoutAllDevicesTitle => 'Đăng xuất tất cả thiết bị';

  @override
  String get logoutAllDevicesContent =>
      'Bạn sẽ bị đăng xuất khỏi tất cả thiết bị, bao gồm cả thiết bị hiện tại. Bạn sẽ cần đăng nhập lại.';

  @override
  String unlinkAccount(Object provider) {
    return 'Hủy liên kết $provider';
  }

  @override
  String unlinkAccountContent(Object provider) {
    return 'Bạn sẽ không thể đăng nhập bằng $provider sau khi hủy liên kết. Bạn có chắc chắn?';
  }

  @override
  String get unlink => 'Hủy liên kết';

  @override
  String linkOnlyProduction(Object provider) {
    return 'Liên kết $provider chỉ khả dụng trên môi trường production';
  }

  @override
  String get serverNotConfigured => 'Server chưa được cấu hình';

  @override
  String get cannotOpenBrowser => 'Không thể mở trình duyệt';

  @override
  String cannotLink(Object provider) {
    return 'Không thể liên kết với $provider';
  }

  @override
  String get noDevices => 'Không có thiết bị nào';

  @override
  String get reload => 'Tải lại';

  @override
  String get thisDevice => 'Thiết bị này';

  @override
  String get unknownDevice => 'Thiết bị không xác định';

  @override
  String linkWith(Object provider) {
    return 'Liên kết với $provider';
  }

  @override
  String get loginWithThisProfile => 'Đăng nhập với profile này';

  @override
  String get swipeToChangeProfile => 'Lướt để đổi profile';

  @override
  String get organizationProfile => 'Profile tổ chức';

  @override
  String get systemProfile => 'Profile hệ thống';

  @override
  String get chooseProfileTitle => 'Chọn profile';

  @override
  String get chooseProfileSubtitle =>
      'Bạn có nhiều profile. Chọn một để tiếp tục.';

  @override
  String get achievementTitle => 'Thành tích';

  @override
  String get allBadges => 'Tất cả huy hiệu';

  @override
  String badgesEarned(Object earned, Object total) {
    return '$earned / $total huy hiệu đã đạt được';
  }

  @override
  String get overallProgress => 'Tiến độ chung';

  @override
  String get earned => 'Đã đạt được';

  @override
  String get inProgress => 'Đang tiến hành';

  @override
  String get notEarned => 'Chưa đạt';

  @override
  String get filter => 'Bộ lọc';

  @override
  String get all => 'Tất cả';

  @override
  String get learning => 'Học tập';

  @override
  String get habit => 'Thói quen';

  @override
  String get achievement => 'Thành tích';

  @override
  String get status => 'Trạng thái';

  @override
  String get category => 'Danh mục';

  @override
  String get apply => 'Áp dụng';

  @override
  String get close => 'Đóng';

  @override
  String get newBadge => 'MỚI';

  @override
  String get certificate => 'Chứng chỉ';

  @override
  String get yourCertificates => 'Chứng chỉ của bạn';

  @override
  String certificatesEarned(Object count) {
    return '$count chứng chỉ đã đạt được';
  }

  @override
  String get completed => 'Đã hoàn thành';

  @override
  String get studying => 'Đang học';

  @override
  String get design => 'Thiết kế';

  @override
  String get programming => 'Lập trình';

  @override
  String get business => 'Kinh doanh';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get lessons => 'bài học';

  @override
  String get certificateDetail => 'Chi tiết chứng chỉ';

  @override
  String get certificateConfirm =>
      'Chứng chỉ xác nhận bạn đã hoàn thành khóa học và nắm vững các kiến thức nền tảng.';

  @override
  String get download => 'Tải xuống';

  @override
  String get share => 'Chia sẻ';

  @override
  String get addToLinkedIn => 'Thêm vào\nLinkedIn';

  @override
  String get printCertificate => 'In chứng chỉ';

  @override
  String get courseInfo => 'Thông tin khóa học';

  @override
  String get course => 'Khóa học';

  @override
  String get completionDate => 'Ngày hoàn thành';

  @override
  String get duration => 'Thời lượng';

  @override
  String get instructor => 'Giảng viên';

  @override
  String get level => 'Trình độ';

  @override
  String get basic => 'Cơ bản';

  @override
  String get skillsEarned => 'Kỹ năng đạt được';

  @override
  String get downloadPdf => 'Tải xuống PDF';

  @override
  String get copyLink => 'Sao chép liên kết';

  @override
  String get showQrCode => 'Hiển thị mã QR';

  @override
  String get reportIssue => 'Báo cáo vấn đề';

  @override
  String get viewCertificate => 'Xem chứng chỉ';

  @override
  String get continueLearning => 'Tiếp tục học';

  @override
  String get recentBadges => 'Huy hiệu gần đây';

  @override
  String get learningActivity => 'Hoạt động học tập';

  @override
  String daysLearned(Object count) {
    return '$count ngày học';
  }

  @override
  String get less => 'Ít';

  @override
  String get more => 'Nhiều';

  @override
  String get learningTrend => 'Xu hướng học tập';

  @override
  String get last7Days => '7 ngày qua';

  @override
  String get minutes => 'phút';

  @override
  String get studyHours => 'Giờ học';

  @override
  String get completedLessons => 'Bài học hoàn thành';

  @override
  String get badges => 'Huy hiệu';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String get yourAccount => 'Tài khoản của bạn';

  @override
  String get switchProfile => 'Chuyển hồ sơ';

  @override
  String get addProfile => 'Thêm hồ sơ';

  @override
  String get updatePersonalDetails => 'Cập nhật thông tin cá nhân';

  @override
  String get passwordSecurityHint => 'Mật khẩu, 2FA, thiết bị đăng nhập';

  @override
  String get subscription => 'Gói đăng ký';

  @override
  String get managePlanBilling => 'Quản lý gói và thanh toán';

  @override
  String get customizeNotifications => 'Tùy chỉnh thông báo';

  @override
  String get privacy => 'Quyền riêng tư';

  @override
  String get managePrivacySettings => 'Quản lý cài đặt quyền riêng tư';

  @override
  String get general => 'Chung';

  @override
  String get helpCenter => 'Trung tâm hỗ trợ';

  @override
  String get faqAndSupport => 'Câu hỏi thường gặp và hỗ trợ';

  @override
  String version(Object version) {
    return 'Phiên bản $version';
  }

  @override
  String get signOutHint => 'Đăng xuất khỏi tài khoản hiện tại';

  @override
  String get premium => 'Cao cấp';

  @override
  String get student => 'Học sinh';

  @override
  String get changePhoto => 'Đổi ảnh';

  @override
  String get bioHint => 'Giới thiệu về bản thân...';

  @override
  String get verified => 'Đã xác minh';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get myPortfolio => 'Portfolio của tôi';

  @override
  String get editPortfolio => 'Chỉnh sửa';

  @override
  String get previewPortfolio => 'Xem trước';

  @override
  String get introduction => 'Giới thiệu';

  @override
  String get featuredProjects => 'Dự án nổi bật';

  @override
  String get experience => 'Kinh nghiệm';

  @override
  String get education => 'Học vấn';

  @override
  String get yearsExperience => 'Năm kinh nghiệm';

  @override
  String get projectsCompleted => 'Dự án hoàn thành';

  @override
  String get followers => 'Người theo dõi';

  @override
  String get addProject => 'Thêm dự án';

  @override
  String get addExperience => 'Thêm kinh nghiệm';

  @override
  String get addEducation => 'Thêm học vấn';

  @override
  String get addSkill => 'Thêm kỹ năng';

  @override
  String get present => 'Hiện tại';

  @override
  String get customizePortfolio => 'Tùy chỉnh portfolio';

  @override
  String get manageLayout => 'Quản lý bố cục';

  @override
  String get toggleVisibility => 'Bật/tắt hiển thị';

  @override
  String get publicPortfolio => 'Công khai';

  @override
  String get privatePortfolio => 'Chỉ mình tôi';

  @override
  String get linkOnlyPortfolio => 'Người có liên kết';

  @override
  String get saved => 'Đã lưu';

  @override
  String get saving => 'Đang lưu...';

  @override
  String get viewPortfolio => 'Xem Portfolio';

  @override
  String get projectName => 'Tên dự án';

  @override
  String get projectNameHint => 'VD: EduFlow';

  @override
  String get shortDescription => 'Mô tả ngắn';

  @override
  String get shortDescriptionHint => 'VD: Hệ thống quản lý học tập';

  @override
  String get details => 'Chi tiết';

  @override
  String get categoryLabel => 'Danh mục';

  @override
  String get add => 'Thêm';

  @override
  String get save => 'Lưu';

  @override
  String get done => 'Xong';

  @override
  String get skillName => 'Tên kỹ năng';

  @override
  String get skillNameHint => 'VD: UI Design, Figma, React...';

  @override
  String get proficiencyLevel => 'Mức độ thành thạo';

  @override
  String get position => 'Vị trí';

  @override
  String get positionHint => 'VD: UI/UX Designer';

  @override
  String get company => 'Công ty';

  @override
  String get companyHint => 'VD: Google, Vela Studio...';

  @override
  String get jobDescription => 'Mô tả công việc';

  @override
  String get editIntroduction => 'Chỉnh sửa giới thiệu';

  @override
  String get fullName => 'Họ tên';

  @override
  String get jobTitle => 'Chức danh';

  @override
  String get jobTitleHint => 'VD: UI/UX Designer';

  @override
  String get locationLabel => 'Vị trí';

  @override
  String get locationHint => 'VD: Hà Nội, Việt Nam';

  @override
  String get websiteLabel => 'Website';

  @override
  String get websiteHint => 'VD: yourname.design';

  @override
  String get aboutYourself => 'Giới thiệu bản thân';

  @override
  String get aboutYourselfHint => 'Viết vài dòng về bạn...';

  @override
  String get dragToReorder => 'Kéo để sắp xếp thứ tự hiển thị';

  @override
  String get privacySettings => 'Quyền riêng tư';

  @override
  String get everyoneCanView => 'Mọi người có thể xem';

  @override
  String get onlyYouCanView => 'Chỉ mình bạn xem được';

  @override
  String get onlyWithLink => 'Chỉ người có liên kết mới xem được';

  @override
  String get linkCopiedToShare => 'Đã sao chép liên kết để chia sẻ';

  @override
  String get linkCopied => 'Đã sao chép liên kết';

  @override
  String get creatingPdf => 'Đang tạo PDF...';

  @override
  String get viewAsOthers => 'Xem portfolio như người khác nhìn thấy';

  @override
  String get shareOnSocial => 'Chia sẻ portfolio qua mạng xã hội';

  @override
  String get copyPortfolioLink => 'Sao chép liên kết portfolio';

  @override
  String get downloadPortfolioPdf => 'Tải portfolio dạng PDF';

  @override
  String get addItem => 'Thêm mục';
}
