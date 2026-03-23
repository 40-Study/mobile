import 'package:study/features/auth/data/models/models.dart';

abstract class AuthRepository {
  // ==========================================================================
  // PUBLIC APIs
  // ==========================================================================

  /// Lấy danh sách system roles.
  Future<List<RoleModel>> getSystemRoles();

  /// Đăng nhập.
  Future<AuthResponse> login({
    required String email,
    required String password,
    required DeviceInfoModel deviceInfo,
  });

  /// Bước 1 đăng ký: Gửi form, server gửi OTP qua email.
  Future<void> registerRequest({
    required String email,
    required String password,
    required String confirmPassword,
    required String userName,
    required String roleId,
    String? fullName,
  });

  /// Bước 2 đăng ký: Xác thực OTP.
  Future<RegisterResponse> registerVerify({
    required String email,
    required String otp,
  });

  /// Bước 1 reset password: Gửi OTP qua email.
  Future<void> resetPasswordRequest({required String email});

  /// Bước 2 reset password: Xác thực OTP + đặt mật khẩu mới.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  /// Refresh token.
  Future<TokenPair> refreshToken();

  // ==========================================================================
  // PROTECTED APIs (cần đăng nhập)
  // ==========================================================================

  /// Lấy thông tin user hiện tại từ server.
  Future<UserModel> getMe();

  /// Cập nhật thông tin user.
  Future<UserModel> updateMe({
    String? username,
    String? phone,
    String? dateOfBirth,
  });

  /// Đổi mật khẩu.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required DeviceInfoModel deviceInfo,
    bool revokeOthers = false,
  });

  /// Lấy danh sách profiles (multi-role).
  Future<List<ProfileModel>> getProfiles();

  /// Thêm system profile mới.
  Future<ProfileModel> addSystemProfile({required String systemRoleId});

  /// Chuyển đổi profile.
  Future<AuthResponse> switchProfile({
    required String profileType,
    required String profileId,
  });

  /// Lấy danh sách thiết bị đăng nhập.
  Future<List<DeviceModel>> getDevices();

  /// Đăng xuất thiết bị hiện tại.
  Future<void> logout();

  /// Đăng xuất tất cả thiết bị.
  Future<void> logoutAll();

  // ==========================================================================
  // LOCAL STORAGE
  // ==========================================================================

  /// Lưu session (token + user) vào local.
  Future<void> saveSession(AuthResponse response);

  /// Kiểm tra đã đăng nhập chưa (có token local).
  Future<bool> isLoggedIn();

  /// Lấy user đã lưu trong local.
  Future<UserModel?> getSavedUser();

  /// Xoá toàn bộ session local.
  Future<void> clearSession();
}
