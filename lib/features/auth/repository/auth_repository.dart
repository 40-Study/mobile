import 'package:study/features/auth/data/models/models.dart';

abstract class AuthRepository {
  /// Đăng nhập, trả về AuthResponse (có thể multi-step).
  Future<AuthResponse> login({
    required String email,
    required String password,
    required DeviceInfoModel deviceInfo,
  });

  /// Chọn role (khi login trả completed=false + system_roles).
  Future<AuthResponse> selectProfile({
    required String sessionToken,
    required String systemRoleId,
  });

  /// Chọn tổ chức (khi cần chọn org). orgId rỗng = độc lập.
  Future<AuthResponse> selectOrg({
    required String sessionToken,
    String? organizationId,
  });

  /// Lấy danh sách system roles từ server.
  Future<List<RoleModel>> getSystemRoles();

  /// Gửi form đăng ký, server gửi OTP qua email.
  Future<void> registerRequest({
    required String email,
    required String password,
    required String confirmPassword,
    required String userName,
    String? fullName,
    List<String>? roleIds,
  });

  /// Xác thực OTP đăng ký.
  Future<RegisterResponse> registerVerify({
    required String email,
    required String otp,
  });

  /// Gửi OTP reset mật khẩu qua email.
  Future<void> resetPasswordRequest({required String email});

  /// Xác thực OTP + đặt mật khẩu mới.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  });

  /// Refresh token.
  Future<TokenPair> refreshToken();

  /// Đăng xuất thiết bị hiện tại.
  Future<void> logout();

  /// Lấy thông tin user hiện tại từ server.
  Future<UserModel> getMe();

  /// Lưu session (token + user + role + org) vào local.
  Future<void> saveSession(AuthResponse response);

  /// Kiểm tra đã đăng nhập chưa (có token local).
  Future<bool> isLoggedIn();

  /// Lấy user đã lưu trong local.
  Future<UserModel?> getSavedUser();

  /// Xoá toàn bộ session local.
  Future<void> clearSession();
}
