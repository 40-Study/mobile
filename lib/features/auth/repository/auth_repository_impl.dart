import 'package:study/core/logger/app_logger.dart';
import 'package:study/features/auth/data/auth_api_client.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/dto/dto.dart';
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

  // API có thể trả về { data: {...} } hoặc trực tiếp {...}

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson, {
    List<String> possibleKeys = const [],
  }) {
    // Nếu data là List trực tiếp
    if (data is List<dynamic>) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    // Nếu data là Map, tìm list bên trong
    if (data is Map<String, dynamic>) {
      for (final key in possibleKeys) {
        if (data[key] is List<dynamic>) {
          return (data[key] as List<dynamic>)
              .map((e) => fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    }

    return [];
  }

  // PUBLIC APIs (không cần token)

  @override
  Future<void> registerRequest({
    required String email,
    required String password,
    required String confirmPassword,
    required String userName,
    String? fullName,
  }) async {
    final body = RegisterRequestDto(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      userName: userName,
      fullName: fullName,
    );
    await _api.registerRequest(body.toJson());
  }

  @override
  Future<RegisterResponse> registerVerify({
    required String email,
    required String otp,
  }) async {
    final response = await _api.registerVerify(
      RegisterVerifyDto(email: email, otp: otp).toJson(),
    );
    final data = _extractData(response.data);

    // API có thể trả về { user: {...} } hoặc trực tiếp user data
    final userData = data is Map && data.containsKey('user')
        ? data['user']
        : data;
    return RegisterResponse.fromJson(userData as Map<String, dynamic>);
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
    required DeviceInfoModel deviceInfo,
  }) async {
    final response = await _api.login(
      LoginRequestDto(
        email: email,
        password: password,
        deviceInfo: deviceInfo,
      ).toJson(),
    );

    final data = _extractData(response.data) as Map<String, dynamic>;
    final loginResponse = LoginResponse.fromJson(data);

    // Nếu login hoàn tất (1 role), lưu session
    if (loginResponse.completed && loginResponse.accessToken != null) {
      await saveSession(
        AuthResponse(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          user: loginResponse.user,
          activeRole: loginResponse.activeRole,
          entryContext: loginResponse.entryContext,
          currentDevice: loginResponse.currentDevice,
        ),
      );
    }

    return loginResponse;
  }

  @override
  Future<AuthResponse> selectRole({
    required String sessionToken,
    required String roleId,
    required String roleType,
    String? organizationId,
  }) async {
    final response = await _api.selectRole(
      SelectRoleDto(
        sessionToken: sessionToken,
        roleId: roleId,
        roleType: roleType,
        organizationId: organizationId,
      ).toJson(),
    );
    final data = _extractData(response.data) as Map<String, dynamic>;
    var authResponse = AuthResponse.fromJson(data);

    // Lưu session trước
    await saveSession(authResponse);

    // Nếu không có user trong response, fetch từ /auth/me
    if (authResponse.user == null && authResponse.accessToken != null) {
      try {
        final user = await getMe();
        authResponse = authResponse.copyWith(user: user);
      } catch (e, stackTrace) {
        AppLogger.w('selectRole: failed to fetch user', e);
        AppLogger.d('selectRole user fetch stackTrace', stackTrace);
      }
    }

    // Fetch full profile data để có role_name
    try {
      final profiles = await getProfiles();
      AppLogger.auth('selectRole: fetched ${profiles.length} profiles');
      // Tìm profile khớp với roleId
      final activeProfile = profiles.firstWhere(
        (p) => p.systemRoleId == roleId || p.id == roleId,
        orElse: () =>
            profiles.isNotEmpty ? profiles.first : authResponse.activeProfile!,
      );
      AppLogger.auth(
        'selectRole: selected profile with roleName=${activeProfile.roleName}',
      );
      authResponse = authResponse.copyWith(activeProfile: activeProfile);
    } catch (e, stackTrace) {
      AppLogger.w('selectRole: failed to fetch profiles', e);
      AppLogger.d('selectRole profiles fetch stackTrace', stackTrace);
    }

    await saveSession(authResponse);
    return authResponse;
  }

  @override
  Future<List<RoleModel>> getSystemRoles() async {
    final response = await _api.getSystemRoles();
    final data = _extractData(response.data);

    return _parseList<RoleModel>(
      data,
      RoleModel.fromJson,
      possibleKeys: ['system_roles', 'roles', 'items'],
    );
  }

  @override
  Future<TokenPair> refreshToken() async {
    final rt = await _storage.getRefreshToken();
    final response = await _api.refreshToken(
      RefreshTokenDto(refreshToken: rt ?? '').toJson(),
    );
    final data = _extractData(response.data) as Map<String, dynamic>;
    final pair = TokenPair.fromJson(data);

    await _storage.saveTokens(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );

    return pair;
  }

  @override
  Future<void> resetPasswordRequest({required String email}) async {
    await _api.resetPasswordRequest(
      ResetPasswordRequestDto(email: email).toJson(),
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.resetPassword(
      ResetPasswordDto(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ).toJson(),
    );
  }

  // PROTECTED APIs (cần token)

  @override
  Future<UserModel> getMe() async {
    final response = await _api.getMe();
    final data = _extractData(response.data) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> updateMe({
    String? username,
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? bio,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (fullName != null) body['full_name'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
    if (bio != null) body['bio'] = bio;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final response = await _api.updateMe(body);
    final data = _extractData(response.data) as Map<String, dynamic>;
    final user = UserModel.fromJson(data);

    await _storage.saveUser(user);
    return user;
  }

  @override
  Future<List<RoleModel>> getMyRoles() async {
    final response = await _api.getMyRoles();
    final data = _extractData(response.data);

    return _parseList<RoleModel>(
      data,
      RoleModel.fromJson,
      possibleKeys: ['roles', 'items'],
    );
  }

  @override
  Future<AuthResponse> switchRole({
    required String roleId,
    required String roleType,
    String? organizationId,
  }) async {
    final response = await _api.switchRole(
      SwitchRoleDto(
        roleId: roleId,
        roleType: roleType,
        organizationId: organizationId,
      ).toJson(),
    );
    final data = _extractData(response.data) as Map<String, dynamic>;
    var authResponse = AuthResponse.fromJson(data);

    // Lưu tokens trước
    await saveSession(authResponse);

    // API switch-role không trả về user, cần fetch
    if (authResponse.user == null && authResponse.accessToken != null) {
      try {
        final user = await getMe();
        authResponse = authResponse.copyWith(user: user);
      } catch (e, stackTrace) {
        AppLogger.w('switchRole: failed to fetch user', e);
        AppLogger.d('switchRole user fetch stackTrace', stackTrace);
      }
    }

    // Fetch full profile data để có role_name
    // API switch-role có thể trả về active_profile không đầy đủ
    try {
      final profiles = await getProfiles();
      AppLogger.auth('switchRole: fetched ${profiles.length} profiles');
      for (final p in profiles) {
        AppLogger.auth(
          'Profile: id=${p.id}, systemRoleId=${p.systemRoleId}, '
          'roleName=${p.roleName}',
        );
      }
      // Tìm profile đang active (match với roleId hoặc systemRoleId)
      final activeProfile = profiles.firstWhere(
        (p) => p.systemRoleId == roleId || p.id == roleId,
        orElse: () =>
            profiles.isNotEmpty ? profiles.first : authResponse.activeProfile!,
      );
      AppLogger.auth(
        'Selected activeProfile: roleName=${activeProfile.roleName}',
      );
      authResponse = authResponse.copyWith(activeProfile: activeProfile);
    } catch (e) {
      AppLogger.w('Error fetching profiles during switchRole', e);
    }

    await saveSession(authResponse);
    return authResponse;
  }

  @override
  Future<List<ProfileModel>> getProfiles() async {
    final response = await _api.getProfiles();
    final data = _extractData(response.data);

    return _parseList<ProfileModel>(
      data,
      ProfileModel.fromJson,
      possibleKeys: ['profiles', 'items'],
    );
  }

  @override
  Future<ProfileModel> createProfile({required String systemRoleId}) async {
    final response = await _api.createProfile(
      CreateProfileDto(systemRoleId: systemRoleId).toJson(),
    );
    final data = _extractData(response.data) as Map<String, dynamic>;

    // API trả về { profile: {...}, profiles: [...] }
    if (data.containsKey('profile')) {
      return ProfileModel.fromJson(data['profile'] as Map<String, dynamic>);
    }
    return ProfileModel.fromJson(data);
  }

  @override
  Future<void> deleteProfile({required String profileId}) async {
    await _api.deleteProfile(profileId);
  }

  @override
  Future<List<DeviceModel>> getDevices() async {
    final response = await _api.getDevices();
    final data = _extractData(response.data);

    return _parseList<DeviceModel>(
      data,
      DeviceModel.fromJson,
      possibleKeys: ['devices', 'items'],
    );
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
  Future<void> deleteAccount({required String password}) async {
    await _api.deleteAccount({'password': password});
    await _storage.clearAll();
  }

  @override
  Future<List<LinkedAccountModel>> getLinkedAccounts() async {
    final response = await _api.getLinkedAccounts();
    final data = _extractData(response.data);

    return _parseList<LinkedAccountModel>(
      data,
      LinkedAccountModel.fromJson,
      possibleKeys: ['accounts', 'linked_accounts', 'items'],
    );
  }

  @override
  Future<void> unlinkAccount({required String provider}) async {
    await _api.unlinkAccount(provider);
  }

  @override
  Future<List<UserModel>> getChildren({int page = 1, int pageSize = 10}) async {
    final response = await _api.getChildren(page: page, pageSize: pageSize);
    final data = _extractData(response.data);

    return _parseList<UserModel>(
      data,
      UserModel.fromJson,
      possibleKeys: ['children', 'items'],
    );
  }

  @override
  Future<List<OrganizationModel>> getMyOrganizations({
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _api.getMyOrganizations(
      page: page,
      pageSize: pageSize,
    );
    final data = _extractData(response.data);

    return _parseList<OrganizationModel>(
      data,
      OrganizationModel.fromJson,
      possibleKeys: ['organizations', 'items'],
    );
  }

  // OAuth APIs

  @override
  Future<String> getOAuthUrl({required String provider}) async {
    final response = await _api.getOAuthUrl(provider);
    final data = _extractData(response.data);

    // Backend trả về URL redirect hoặc thông tin để build URL
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      return data['url'] as String? ??
          data['redirect_url'] as String? ??
          data['oauth_url'] as String? ??
          '';
    }
    throw Exception('Invalid OAuth URL response');
  }

  @override
  Future<LoginResponse> handleOAuthCallback({
    required String provider,
    required String code,
    String? state,
  }) async {
    final response = await _api.oauthCallback(provider, code, state);
    final data = _extractData(response.data);

    // Parse response giống như login thường
    return LoginResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> linkOAuthAccount({
    required String provider,
    required String code,
  }) async {
    await _api.linkAccount(provider, {'code': code});
  }

  // LOCAL STORAGE

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
  Future<RoleModel?> getSavedRole() => _storage.getActiveRole();

  @override
  Future<void> clearSession() => _storage.clearAll();
}
