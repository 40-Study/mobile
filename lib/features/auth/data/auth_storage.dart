import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Future<void> saveActiveProfile(ProfileModel profile);
  Future<ProfileModel?> getActiveProfile();

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
  SharedPreferencesAuthStorage(
    this._prefs, {
    FlutterSecureStorage secure = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  }) : _secure = secure;

  final SharedPreferences _prefs;
  // Token nằm trong Keystore/Keychain, phần còn lại ở prefs
  final FlutterSecureStorage _secure;
  Future<void>? _migration;
  // true khi migrate fail → tạm đọc cặp token cũ từ prefs
  bool _useLegacy = false;

  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUser = 'auth_user';
  static const _keyActiveRole = 'auth_active_role';
  static const _keyActiveProfile = 'auth_active_profile';
  static const _keyActiveOrg = 'auth_active_org';
  static const _keyEntryContext = 'auth_entry_context';
  static const _keyDeviceId = 'auth_device_id';

  // Migrate token cũ từ prefs 1 lần; chỉ xoá prefs khi ghi secure thành công cả cặp
  Future<void> _migrateLegacyTokens() => _migration ??= () async {
    final access = _prefs.getString(_keyAccessToken);
    final refresh = _prefs.getString(_keyRefreshToken);
    if (access == null && refresh == null) return;
    try {
      // Secure đã có đủ cặp token (mới hơn) → không ghi đè bằng token legacy
      final hasSecurePair =
          await _secure.read(key: _keyAccessToken) != null &&
          await _secure.read(key: _keyRefreshToken) != null;
      if (!hasSecurePair) {
        if (access != null) {
          await _secure.write(key: _keyAccessToken, value: access);
        }
        if (refresh != null) {
          await _secure.write(key: _keyRefreshToken, value: refresh);
        }
      }
      _useLegacy = false;
    } catch (_) {
      // Giữ prefs làm fallback, lần sau thử lại
      _useLegacy = true;
      _migration = null;
      return;
    }
    // Dọn prefs best-effort; lỗi thì lần sau dọn tiếp, không ảnh hưởng đọc token
    try {
      await _prefs.remove(_keyAccessToken);
      await _prefs.remove(_keyRefreshToken);
    } catch (_) {
      _migration = null;
    }
  }();

  Future<String?> _readToken(String key) async {
    await _migrateLegacyTokens();
    // Migrate fail → đọc fallback từ prefs để user không bị logout
    if (_useLegacy) return _prefs.getString(key);
    try {
      return await _secure.read(key: key);
    } catch (_) {
      // Keystore hỏng (vd restore backup) → buộc login lại, không crash
      try {
        await _secure.deleteAll();
      } catch (_) {}
      return null;
    }
  }

  Future<void> _deleteSecureTokens() async {
    await _secure.delete(key: _keyAccessToken);
    await _secure.delete(key: _keyRefreshToken);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _migration;
    await _secure.write(key: _keyAccessToken, value: accessToken);
    try {
      await _secure.write(key: _keyRefreshToken, value: refreshToken);
    } catch (_) {
      // Không để cặp token lệch nhau
      await _deleteSecureTokens();
      rethrow;
    }
    _useLegacy = false;
    // Bỏ token legacy, best-effort
    try {
      await _prefs.remove(_keyAccessToken);
      await _prefs.remove(_keyRefreshToken);
    } catch (_) {}
  }

  @override
  Future<String?> getAccessToken() => _readToken(_keyAccessToken);

  @override
  Future<String?> getRefreshToken() => _readToken(_keyRefreshToken);

  @override
  Future<void> clearTokens() async {
    // Chờ migration đang chạy xong để nó không ghi lại token sau khi xoá
    await _migration;
    _useLegacy = false;
    // Xoá legacy trước để logout không bị migrate ngược token cũ
    try {
      await _prefs.remove(_keyAccessToken);
      await _prefs.remove(_keyRefreshToken);
    } finally {
      await _deleteSecureTokens();
    }
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
  Future<void> saveActiveProfile(ProfileModel profile) async {
    await _prefs.setString(_keyActiveProfile, jsonEncode(profile.toJson()));
  }

  @override
  Future<ProfileModel?> getActiveProfile() async {
    final raw = _prefs.getString(_keyActiveProfile);
    if (raw == null) return null;
    return ProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
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
    return OrganizationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveEntryContext(EntryContextModel context) async {
    await _prefs.setString(_keyEntryContext, jsonEncode(context.toJson()));
  }

  @override
  Future<EntryContextModel?> getEntryContext() async {
    final raw = _prefs.getString(_keyEntryContext);
    if (raw == null) return null;
    return EntryContextModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveDeviceId(String deviceId) async {
    await _prefs.setString(_keyDeviceId, deviceId);
  }

  @override
  Future<String?> getDeviceId() async => _prefs.getString(_keyDeviceId);

  @override
  Future<bool> hasToken() async => await getAccessToken() != null;

  @override
  Future<void> clearAll() async {
    await clearTokens();
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyActiveRole);
    await _prefs.remove(_keyActiveProfile);
    await _prefs.remove(_keyActiveOrg);
    await _prefs.remove(_keyEntryContext);
  }
}
