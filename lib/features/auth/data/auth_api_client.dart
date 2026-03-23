import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  // ==========================================================================
  // PUBLIC APIs (không cần token)
  // ==========================================================================

  /// Lấy danh sách system roles.
  @GET('/api/system-roles')
  Future<HttpResponse<dynamic>> getSystemRoles();

  /// Bước 1 đăng ký: Gửi thông tin, server gửi OTP qua email.
  @POST('/api/auth/register/request')
  Future<HttpResponse<dynamic>> registerRequest(
    @Body() Map<String, dynamic> body,
  );

  /// Bước 2 đăng ký: Xác thực OTP và tạo tài khoản.
  @POST('/api/auth/register')
  Future<HttpResponse<dynamic>> registerVerify(
    @Body() Map<String, dynamic> body,
  );

  /// Đăng nhập.
  @POST('/api/auth/login')
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  /// Refresh token.
  @POST('/api/auth/refresh-token')
  Future<HttpResponse<dynamic>> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  /// Bước 1 reset password: Gửi OTP qua email.
  @POST('/api/auth/reset-password/request')
  Future<HttpResponse<dynamic>> resetPasswordRequest(
    @Body() Map<String, dynamic> body,
  );

  /// Bước 2 reset password: Xác thực OTP + đặt mật khẩu mới.
  @POST('/api/auth/reset-password')
  Future<HttpResponse<dynamic>> resetPassword(
    @Body() Map<String, dynamic> body,
  );

  // ==========================================================================
  // PROTECTED APIs (cần token)
  // ==========================================================================

  /// Lấy thông tin user hiện tại.
  @GET('/api/auth/me')
  Future<HttpResponse<dynamic>> getMe();

  /// Cập nhật thông tin user.
  @PUT('/api/auth/me')
  Future<HttpResponse<dynamic>> updateMe(@Body() Map<String, dynamic> body);

  /// Đổi mật khẩu.
  @PUT('/api/auth/change-password')
  Future<HttpResponse<dynamic>> changePassword(
    @Body() Map<String, dynamic> body,
  );

  /// Lấy danh sách profiles (multi-role).
  @GET('/api/auth/profiles')
  Future<HttpResponse<dynamic>> getProfiles();

  /// Thêm system profile mới.
  @POST('/api/auth/profiles/system')
  Future<HttpResponse<dynamic>> addSystemProfile(
    @Body() Map<String, dynamic> body,
  );

  /// Chuyển đổi profile.
  @POST('/api/auth/switch-profile')
  Future<HttpResponse<dynamic>> switchProfile(
    @Body() Map<String, dynamic> body,
  );

  /// Lấy danh sách thiết bị đăng nhập.
  @GET('/api/auth/devices')
  Future<HttpResponse<dynamic>> getDevices();

  /// Đăng xuất thiết bị hiện tại.
  @POST('/api/auth/logout')
  Future<HttpResponse<dynamic>> logout();

  /// Đăng xuất tất cả thiết bị.
  @POST('/api/auth/logout-all')
  Future<HttpResponse<dynamic>> logoutAll();
}
