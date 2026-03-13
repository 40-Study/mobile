import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/features/auth/data/models/models.dart';

/// Lưu trữ token, user, role, org, device_id vào local.
abstract class AuthStorage {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();

  Future<void> saveActiveRole(RoleModel role);
  Future<RoleModel?> getActiveRole();

  Future<void> saveActiveOrg(OrganizationModel? org);
  Future<OrganizationModel?> getActiveOrg();

  Future<void> saveEntryContext(EntryContextModel context);
  Future<EntryContextModel?> getEntryContext();

  /// device_id chỉ tạo 1 lần, dùng lại mãi.
  Future<void> saveDeviceId(String deviceId);
  Future<String?> getDeviceId();

  Future<bool> hasToken();

  /// Xoá toàn bộ dữ liệu auth (logout).
  Future<void> clearAll();
}

class SharedPreferencesAuthStorage implements AuthStorage {
  SharedPreferencesAuthStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUser = 'auth_user';
  static const _keyActiveRole = 'auth_active_role';
  static const _keyActiveOrg = 'auth_active_org';
  static const _keyEntryContext = 'auth_entry_context';
  static const _keyDeviceId = 'auth_device_id';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_keyAccessToken, accessToken);
    await _prefs.setString(_keyRefreshToken, refreshToken);
  }

  @override
  Future<String?> getAccessToken() async =>
      _prefs.getString(_keyAccessToken);

  @override
  Future<String?> getRefreshToken() async =>
      _prefs.getString(_keyRefreshToken);

  @override
  Future<void> clearTokens() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveActiveRole(RoleModel role) async {
    await _prefs.setString(_keyActiveRole, jsonEncode(role.toJson()));
  }

  @override
  Future<RoleModel?> getActiveRole() async {
    final raw = _prefs.getString(_keyActiveRole);
    if (raw == null) return null;
    return RoleModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveActiveOrg(OrganizationModel? org) async {
    if (org == null) {
      await _prefs.remove(_keyActiveOrg);
      return;
    }
    await _prefs.setString(_keyActiveOrg, jsonEncode(org.toJson()));
  }

  @override
  Future<OrganizationModel?> getActiveOrg() async {
    final raw = _prefs.getString(_keyActiveOrg);
    if (raw == null) return null;
    return OrganizationModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveEntryContext(EntryContextModel context) async {
    await _prefs.setString(_keyEntryContext, jsonEncode(context.toJson()));
  }

  @override
  Future<EntryContextModel?> getEntryContext() async {
    final raw = _prefs.getString(_keyEntryContext);
    if (raw == null) return null;
    return EntryContextModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveDeviceId(String deviceId) async {
    await _prefs.setString(_keyDeviceId, deviceId);
  }

  @override
  Future<String?> getDeviceId() async => _prefs.getString(_keyDeviceId);

  @override
  Future<bool> hasToken() async => _prefs.containsKey(_keyAccessToken);

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyActiveRole);
    await _prefs.remove(_keyActiveOrg);
    await _prefs.remove(_keyEntryContext);
  }
}
