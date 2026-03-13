import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApiClient apiClient,
    required AuthStorage authStorage,
  })  : _api = apiClient,
        _storage = authStorage;

  final AuthApiClient _api;
  final AuthStorage _storage;

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
    required DeviceInfoModel deviceInfo,
  }) async {
    final response = await _api.login({
      'email': email,
      'password': password,
      'device_info': deviceInfo.toJson(),
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final authResponse = AuthResponse.fromJson(data);

    if (authResponse.completed) {
      await saveSession(authResponse);
    }

    return authResponse;
  }

  @override
  Future<AuthResponse> selectProfile({
    required String sessionToken,
    required String systemRoleId,
  }) async {
    final response = await _api.selectProfile({
      'session_token': sessionToken,
      'system_role_id': systemRoleId,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final authResponse = AuthResponse.fromJson(data);

    if (authResponse.completed) {
      await saveSession(authResponse);
    }

    return authResponse;
  }

  @override
  Future<AuthResponse> selectOrg({
    required String sessionToken,
    String? organizationId,
  }) async {
    final body = <String, dynamic>{
      'session_token': sessionToken,
    };
    if (organizationId != null && organizationId.isNotEmpty) {
      body['organization_id'] = organizationId;
    }

    final response = await _api.selectOrg(body);
    final data = response.data['data'] as Map<String, dynamic>;
    final authResponse = AuthResponse.fromJson(data);

    if (authResponse.completed) {
      await saveSession(authResponse);
    }

    return authResponse;
  }

  @override
  Future<List<RoleModel>> getSystemRoles() async {
    final response =
        await _api.getSystemRoles(1, 20);
    final data =
        response.data['data'] as List<dynamic>? ?? [];
    return data
        .map(
          (e) => RoleModel.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<void> registerRequest({
    required String email,
    required String password,
    required String confirmPassword,
    required String userName,
    String? fullName,
    List<String>? roleIds,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'user_name': userName,
    };
    if (fullName != null) body['full_name'] = fullName;
    if (roleIds != null) body['role_ids'] = roleIds;

    await _api.registerRequest(body);
  }

  @override
  Future<RegisterResponse> registerVerify({
    required String email,
    required String otp,
  }) async {
    final response = await _api.registerVerify({
      'email': email,
      'otp': otp,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return RegisterResponse.fromJson(data);
  }

  @override
  Future<void> resetPasswordRequest({required String email}) async {
    await _api.resetPasswordRequest({'email': email});
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.resetPassword({
      'email': email,
      'otp': otp,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });
  }

  @override
  Future<TokenPair> refreshToken() async {
    final rt = await _storage.getRefreshToken();
    final response = await _api.refreshToken({
      'refresh_token': rt ?? '',
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final pair = TokenPair.fromJson(data);

    await _storage.saveTokens(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );

    return pair;
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await _storage.clearAll();
    }
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _api.getMe();
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> saveSession(AuthResponse response) async {
    if (response.accessToken != null &&
        response.refreshToken != null) {
      await _storage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
      );
    }
    if (response.user != null) {
      await _storage.saveUser(response.user!);
    }
    if (response.activeRole != null) {
      await _storage.saveActiveRole(response.activeRole!);
    }
    await _storage.saveActiveOrg(response.activeOrg);
    if (response.entryContext != null) {
      await _storage.saveEntryContext(response.entryContext!);
    }
  }

  @override
  Future<bool> isLoggedIn() => _storage.hasToken();

  @override
  Future<UserModel?> getSavedUser() => _storage.getUser();

  @override
  Future<void> clearSession() => _storage.clearAll();
}
