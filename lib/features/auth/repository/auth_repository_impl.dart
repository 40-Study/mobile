import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApiClient apiClient,
    required AuthStorage authStorage,
  }) : _api = apiClient,
       _storage = authStorage;

  final AuthApiClient _api;
  final AuthStorage _storage;

  // ==========================================================================
  // PUBLIC APIs
  // ==========================================================================

  @override
  Future<List<RoleModel>> getSystemRoles() async {
    final response = await _api.getSystemRoles();
    final data = response.data['data'];

    // Handle both List and Map structures
    if (data is List<dynamic>) {
      return data
          .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // If data is a Map, try to find roles inside
    if (data is Map<String, dynamic>) {
      final roles = data['roles'] ?? data['items'] ?? data['system_roles'];
      if (roles is List<dynamic>) {
        return roles
            .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

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

    // Debug: Print raw API response
    // ignore: avoid_print
    print('🔑 Login API response data: $data');
    // ignore: avoid_print
    print('🔑 active_profile in response: ${data['active_profile']}');

    final authResponse = AuthResponse.fromJson(data);

    // Debug: Print parsed response
    // ignore: avoid_print
    print('🔑 Parsed activeProfile: ${authResponse.activeProfile}');

    await saveSession(authResponse);
    return authResponse;
  }

  @override
  Future<void> registerRequest({
    required String email,
    required String password,
    required String confirmPassword,
    required String userName,
    required String roleId,
    String? fullName,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'user_name': userName,
      'role_id': roleId,
    };
    if (fullName != null && fullName.isNotEmpty) {
      body['full_name'] = fullName;
    }

    await _api.registerRequest(body);
  }

  @override
  Future<RegisterResponse> registerVerify({
    required String email,
    required String otp,
  }) async {
    final response = await _api.registerVerify({'email': email, 'otp': otp});
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
    final response = await _api.refreshToken({'refresh_token': rt ?? ''});
    final data = response.data['data'] as Map<String, dynamic>;
    final pair = TokenPair.fromJson(data);

    await _storage.saveTokens(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );

    return pair;
  }

  // ==========================================================================
  // PROTECTED APIs
  // ==========================================================================

  @override
  Future<UserModel> getMe() async {
    final response = await _api.getMe();
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> updateMe({
    String? username,
    String? phone,
    String? dateOfBirth,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (phone != null) body['phone'] = phone;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;

    final response = await _api.updateMe(body);
    final data = response.data['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data);

    await _storage.saveUser(user);
    return user;
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
    required DeviceInfoModel deviceInfo,
    bool revokeOthers = false,
  }) async {
    await _api.changePassword({
      'old_password': oldPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
      'device_info': deviceInfo.toJson(),
      'revoke_others': revokeOthers,
    });
  }

  @override
  Future<List<ProfileModel>> getProfiles() async {
    final response = await _api.getProfiles();
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProfileModel> addSystemProfile({required String systemRoleId}) async {
    final response = await _api.addSystemProfile({
      'system_role_id': systemRoleId,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final profile = data['profile'] as Map<String, dynamic>;
    return ProfileModel.fromJson(profile);
  }

  @override
  Future<AuthResponse> switchProfile({
    required String profileType,
    required String profileId,
  }) async {
    final response = await _api.switchProfile({
      'profile_type': profileType,
      'profile_id': profileId,
    });
    final data = response.data['data'] as Map<String, dynamic>;

    // Debug: Print raw API response
    // ignore: avoid_print
    print('🔄 Switch profile API response: $data');
    // ignore: avoid_print
    print('🔄 active_profile in response: ${data['active_profile']}');

    final authResponse = AuthResponse.fromJson(data);

    // Debug: Print parsed response
    // ignore: avoid_print
    print('🔄 Parsed activeProfile: ${authResponse.activeProfile}');

    await saveSession(authResponse);
    return authResponse;
  }

  @override
  Future<List<DeviceModel>> getDevices() async {
    final response = await _api.getDevices();
    final data = response.data['data'] as Map<String, dynamic>;
    final devices = data['devices'] as List<dynamic>;
    return devices
        .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
  Future<void> logoutAll() async {
    try {
      await _api.logoutAll();
    } finally {
      await _storage.clearAll();
    }
  }

  // ==========================================================================
  // LOCAL STORAGE
  // ==========================================================================

  @override
  Future<void> saveSession(AuthResponse response) async {
    if (response.accessToken != null && response.refreshToken != null) {
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
    if (response.activeProfile != null) {
      await _storage.saveActiveProfile(response.activeProfile!);
    }
  }

  @override
  Future<bool> isLoggedIn() => _storage.hasToken();

  @override
  Future<UserModel?> getSavedUser() => _storage.getUser();

  @override
  Future<ProfileModel?> getSavedProfile() => _storage.getActiveProfile();

  @override
  Future<void> clearSession() => _storage.clearAll();
}
