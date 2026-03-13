import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  // --- Public APIs (không cần token) ---

  /// Gửi thông tin đăng ký, nhận OTP qua email.
  @POST('/api/auth/register/request')
  Future<HttpResponse<dynamic>> registerRequest(
    @Body() Map<String, dynamic> body,
  );

  /// Xác thực OTP và tạo tài khoản.
  @POST('/api/auth/register')
  Future<HttpResponse<dynamic>> registerVerify(
    @Body() Map<String, dynamic> body,
  );

  /// Đăng nhập (multi-step).
  @POST('/api/auth/login')
  Future<HttpResponse<dynamic>> login(
    @Body() Map<String, dynamic> body,
  );

  /// Chọn role sau khi login.
  @POST('/api/auth/select-profile')
  Future<HttpResponse<dynamic>> selectProfile(
    @Body() Map<String, dynamic> body,
  );

  /// Chọn tổ chức sau khi chọn role.
  @POST('/api/auth/select-org')
  Future<HttpResponse<dynamic>> selectOrg(
    @Body() Map<String, dynamic> body,
  );

  /// Refresh token.
  @POST('/api/auth/refresh-token')
  Future<HttpResponse<dynamic>> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  /// Gửi OTP reset mật khẩu.
  @POST('/api/auth/reset-password/request')
  Future<HttpResponse<dynamic>> resetPasswordRequest(
    @Body() Map<String, dynamic> body,
  );

  /// Xác thực OTP và đặt lại mật khẩu.
  @POST('/api/auth/reset-password')
  Future<HttpResponse<dynamic>> resetPassword(
    @Body() Map<String, dynamic> body,
  );

  /// Lấy danh sách system roles.
  @GET('/api/system-roles/')
  Future<HttpResponse<dynamic>> getSystemRoles(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );

  // --- Protected APIs (cần token) ---

  /// Đăng xuất thiết bị hiện tại.
  @POST('/api/auth/logout')
  Future<HttpResponse<dynamic>> logout();

  /// Đăng xuất tất cả thiết bị.
  @POST('/api/auth/logout-all')
  Future<HttpResponse<dynamic>> logoutAll();

  /// Lấy thông tin user hiện tại.
  @GET('/api/auth/me')
  Future<HttpResponse<dynamic>> getMe();

  /// Cập nhật profile.
  @PUT('/api/auth/me')
  Future<HttpResponse<dynamic>> updateMe(
    @Body() Map<String, dynamic> body,
  );

  /// Đổi mật khẩu.
  @PUT('/api/auth/change-password')
  Future<HttpResponse<dynamic>> changePassword(
    @Body() Map<String, dynamic> body,
  );

  /// Đổi role (đã đăng nhập).
  @POST('/api/auth/switch-profile')
  Future<HttpResponse<dynamic>> switchProfile(
    @Body() Map<String, dynamic> body,
  );

  /// Đổi tổ chức (đã đăng nhập).
  @POST('/api/auth/switch-org')
  Future<HttpResponse<dynamic>> switchOrg(
    @Body() Map<String, dynamic> body,
  );

  /// Danh sách thiết bị đã đăng nhập.
  @GET('/api/auth/devices')
  Future<HttpResponse<dynamic>> getDevices();
}
