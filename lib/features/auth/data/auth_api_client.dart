import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

/// Auth API Client - theo API Documentation v1.0
/// Base URL: /api
@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  // ============================================================================
  // PUBLIC APIs (không cần token)
  // ============================================================================

  /// 2.1 Đăng ký - Bước 1: Request OTP
  /// POST /auth/register/request
  @POST('/api/auth/register/request')
  Future<HttpResponse<dynamic>> registerRequest(
    @Body() Map<String, dynamic> body,
  );

  /// 2.2 Đăng ký - Bước 2: Verify OTP
  /// POST /auth/register
  @POST('/api/auth/register')
  Future<HttpResponse<dynamic>> registerVerify(
    @Body() Map<String, dynamic> body,
  );

  /// 2.3 Đăng nhập
  /// POST /auth/login
  /// Returns different responses based on user's roles count
  @POST('/api/auth/login')
  Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

  /// 2.4 Chọn Role (sau login nếu có nhiều roles)
  /// POST /auth/select-role
  @POST('/api/auth/select-role')
  Future<HttpResponse<dynamic>> selectRole(@Body() Map<String, dynamic> body);

  /// 2.5 Lấy danh sách System Roles
  /// GET /auth/system-roles
  @GET('/api/auth/system-roles')
  Future<HttpResponse<dynamic>> getSystemRoles();

  /// 2.6 Refresh Token
  /// POST /auth/refresh-token
  @POST('/api/auth/refresh-token')
  Future<HttpResponse<dynamic>> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  /// 2.7 Quên mật khẩu - Bước 1: Request OTP
  /// POST /auth/reset-password/request
  @POST('/api/auth/reset-password/request')
  Future<HttpResponse<dynamic>> resetPasswordRequest(
    @Body() Map<String, dynamic> body,
  );

  /// 2.8 Quên mật khẩu - Bước 2: Reset Password
  /// POST /auth/reset-password
  @POST('/api/auth/reset-password')
  Future<HttpResponse<dynamic>> resetPassword(
    @Body() Map<String, dynamic> body,
  );

  // ============================================================================
  // PROTECTED APIs (cần token)
  // ============================================================================

  /// 3.1 Lấy thông tin user hiện tại
  /// GET /auth/me
  @GET('/api/auth/me')
  Future<HttpResponse<dynamic>> getMe();

  /// 3.2 Cập nhật thông tin user
  /// PUT /auth/me
  @PUT('/api/auth/me')
  Future<HttpResponse<dynamic>> updateMe(@Body() Map<String, dynamic> body);

  /// 3.3 Lấy roles của user
  /// GET /auth/my-roles
  @GET('/api/auth/my-roles')
  Future<HttpResponse<dynamic>> getMyRoles();

  /// 3.4 Chuyển role (đã đăng nhập)
  /// POST /auth/switch-role
  @POST('/api/auth/switch-role')
  Future<HttpResponse<dynamic>> switchRole(@Body() Map<String, dynamic> body);

  /// 3.5 Lấy danh sách profiles
  /// GET /auth/me/profiles
  @GET('/api/auth/me/profiles')
  Future<HttpResponse<dynamic>> getProfiles();

  /// 3.6 Tạo profile mới
  /// POST /auth/me/profiles
  @POST('/api/auth/me/profiles')
  Future<HttpResponse<dynamic>> createProfile(
    @Body() Map<String, dynamic> body,
  );

  /// 3.7 Xóa profile
  /// DELETE /auth/me/profiles/:id
  @DELETE('/api/auth/me/profiles/{id}')
  Future<HttpResponse<dynamic>> deleteProfile(@Path('id') String profileId);

  /// 3.8 Lấy danh sách thiết bị đăng nhập
  /// GET /auth/devices
  @GET('/api/auth/devices')
  Future<HttpResponse<dynamic>> getDevices();

  /// 2.10 Logout (thiết bị hiện tại)
  /// POST /auth/logout
  @POST('/api/auth/logout')
  Future<HttpResponse<dynamic>> logout();

  /// 2.11 Logout tất cả thiết bị
  /// POST /auth/logout-all
  @POST('/api/auth/logout-all')
  Future<HttpResponse<dynamic>> logoutAll();

  /// 2.12 Đổi mật khẩu
  /// PUT /auth/change-password
  @PUT('/api/auth/change-password')
  Future<HttpResponse<dynamic>> changePassword(
    @Body() Map<String, dynamic> body,
  );

  /// 2.13 Xóa tài khoản
  /// DELETE /auth/me
  @DELETE('/api/auth/me')
  Future<HttpResponse<dynamic>> deleteAccount(
    @Body() Map<String, dynamic> body,
  );

  /// 2.14 Lấy danh sách tài khoản OAuth đã liên kết
  /// GET /auth/linked-accounts
  @GET('/api/auth/linked-accounts')
  Future<HttpResponse<dynamic>> getLinkedAccounts();

  /// 2.15 Hủy liên kết tài khoản OAuth
  /// DELETE /auth/linked-accounts/:provider
  @DELETE('/api/auth/linked-accounts/{provider}')
  Future<HttpResponse<dynamic>> unlinkAccount(@Path('provider') String provider);

  // ============================================================================
  // OAuth APIs
  // ============================================================================

  /// 2.16 OAuth Login - Get redirect URL
  /// GET /auth/oauth/:provider
  /// Providers: google, facebook, github
  /// Returns redirect URL to OAuth provider
  @GET('/api/auth/oauth/{provider}')
  Future<HttpResponse<dynamic>> getOAuthUrl(@Path('provider') String provider);

  /// 2.17 OAuth Callback - Exchange code for tokens
  /// GET /auth/oauth/:provider/callback
  @GET('/api/auth/oauth/{provider}/callback')
  Future<HttpResponse<dynamic>> oauthCallback(
    @Path('provider') String provider,
    @Query('code') String code,
    @Query('state') String? state,
  );

  /// 2.18 Link OAuth account (for logged-in users)
  /// POST /auth/link-account/:provider
  @POST('/api/auth/link-account/{provider}')
  Future<HttpResponse<dynamic>> linkAccount(
    @Path('provider') String provider,
    @Body() Map<String, dynamic> body,
  );

  // ============================================================================
  // CHILDREN APIs (for parent role)
  // ============================================================================

  /// Lấy danh sách con của phụ huynh
  /// GET /me/children
  @GET('/api/me/children')
  Future<HttpResponse<dynamic>> getChildren({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 10,
  });

  /// Lấy danh sách organizations của user
  /// GET /me/organizations
  @GET('/api/me/organizations')
  Future<HttpResponse<dynamic>> getMyOrganizations({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 10,
  });
}
