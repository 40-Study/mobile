import 'package:shared_preferences/shared_preferences.dart';

/// Storage for onboarding / first-launch state.
/// Tách riêng để có thể tái sử dụng hoặc thay implementation (e.g. remote config).
abstract class OnboardingStorage {
  Future<bool> hasSeenOnboarding();

  Future<void> setSeenOnboarding();
}

const String _keyHasSeenOnboarding = 'has_seen_onboarding';

class SharedPreferencesOnboardingStorage implements OnboardingStorage {
  SharedPreferencesOnboardingStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> hasSeenOnboarding() async {
    return _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  @override
  Future<void> setSeenOnboarding() async {
    await _prefs.setBool(_keyHasSeenOnboarding, true);
  }
}
