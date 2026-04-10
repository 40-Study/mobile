import 'package:study/features/auth/data/models/models.dart';

/// Auth Repository Interface - theo API Documentation v1.0
abstract class AuthRepository {
  // ============================================================================
  // PUBLIC APIs (không cần token)
  // ============================================================================

  /// 2.1 Đăng ký - Bước 1: Request OTP
  Future<void> registerRequest({
    required String email,
    required String password,
    required String confirmPassword,
    required String userName,
    String? fullName,
  });

  /// 2.2 Đăng ký - Bước 2: Verify OTP
  Future<RegisterResponse> registerVerify({
    required String email,
    required String otp,
  });

  /// 2.3 Đăng nhập
  /// Returns LoginResponse với 3 trường hợp:
  /// - 1 role: completed=true, có access_token, user
  /// - 2+ roles: completed=true, có session_token, roles[]
  /// - 0 roles: completed=false, needs_role_registration=true
  Future<LoginResponse> login({
    required String email,
    required String password,
    required DeviceInfoModel deviceInfo,
  });

  /// 2.4 Chọn Role (sau login nếu có nhiều roles)
  Future<AuthResponse> selectRole({
    required String sessionToken,
    required String roleId,
    required String roleType,
    String? organizationId,
  });

  /// 2.5 Lấy danh sách System Roles
  Future<List<RoleModel>> getSystemRoles();

  /// 2.6 Refresh Token
  Future<TokenPair> refreshToken();

  /// 2.7 Quên mật khẩu - Bước 1: Request OTP
  Future<void> resetPasswordRequest({required String email});

  /// 2.8 Quên mật khẩu - Bước 2: Reset Password
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  // ============================================================================
  // PROTECTED APIs (cần token)
  // ============================================================================

  /// 3.1 Lấy thông tin user hiện tại
  Future<UserModel> getMe();

  /// 3.2 Cập nhật thông tin user
  Future<UserModel> updateMe({
    String? username,
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? bio,
    String? avatarUrl,
  });

  /// 3.3 Lấy roles của user
  Future<List<RoleModel>> getMyRoles();

  /// 3.4 Chuyển role (đã đăng nhập)
  Future<AuthResponse> switchRole({
    required String roleId,
    required String roleType,
    String? organizationId,
  });

  /// 3.5 Lấy danh sách profiles
  Future<List<ProfileModel>> getProfiles();

  /// 3.6 Tạo profile mới
  Future<ProfileModel> createProfile({required String systemRoleId});

  /// 3.7 Xóa profile
  Future<void> deleteProfile({required String profileId});

  /// 3.8 Lấy danh sách thiết bị đăng nhập
  Future<List<DeviceModel>> getDevices();

  /// 2.10 Logout (thiết bị hiện tại)
  Future<void> logout();

  /// 2.11 Logout tất cả thiết bị
  Future<void> logoutAll();

  /// 2.12 Đổi mật khẩu
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required DeviceInfoModel deviceInfo,
    bool revokeOthers = false,
  });

  // ============================================================================
  // LOCAL STORAGE
  // ============================================================================

  /// Lưu session (token + user + role) vào local
  Future<void> saveSession(AuthResponse response);

  /// Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn();

  /// Lấy user đã lưu trong local
  Future<UserModel?> getSavedUser();

  /// Lấy profile đang active từ local
  Future<ProfileModel?> getSavedProfile();

  /// Lấy role đang active từ local
  Future<RoleModel?> getSavedRole();

  /// Xoá toàn bộ session local
  Future<void> clearSession();
}
