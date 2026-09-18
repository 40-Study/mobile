import 'package:shared_preferences/shared_preferences.dart';

const String _keyLastEnrollmentId = 'last_accessed_enrollment_id';
const String _keyLastAccessedAt = 'last_accessed_at';

/// Lưu enrollment ID cuối cùng user mở
class LastAccessedCourseStorage {
  LastAccessedCourseStorage(this._prefs);

  final SharedPreferences _prefs;

  String? getLastEnrollmentId() => _prefs.getString(_keyLastEnrollmentId);

  DateTime? getLastAccessedAt() {
    final ms = _prefs.getInt(_keyLastAccessedAt);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<void> setLastAccessed(String enrollmentId) async {
    await _prefs.setString(_keyLastEnrollmentId, enrollmentId);
    await _prefs.setInt(_keyLastAccessedAt, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    await _prefs.remove(_keyLastEnrollmentId);
    await _prefs.remove(_keyLastAccessedAt);
  }
}
