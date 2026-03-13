import 'package:study/data/onboarding_storage.dart';

/// Repository cho trạng thái onboarding (chỉ hiển thị lần đầu).
/// Tách interface để dễ test và tái sử dụng.
abstract class OnboardingRepository {
  Future<bool> hasSeenOnboarding();

  Future<void> setSeenOnboarding();
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._storage);

  final OnboardingStorage _storage;

  @override
  Future<bool> hasSeenOnboarding() => _storage.hasSeenOnboarding();

  @override
  Future<void> setSeenOnboarding() => _storage.setSeenOnboarding();
}
