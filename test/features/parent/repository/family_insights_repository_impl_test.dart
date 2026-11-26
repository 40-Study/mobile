import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/parent/repository/family_insights_repository_impl.dart';

void main() {
  group('FamilyInsightsRepositoryImpl', () {
    test('getInsights should return empty list when preview disabled', () async {
      final repo = FamilyInsightsRepositoryImpl(enablePreviewFallback: false);
      expect(await repo.getInsights(), isEmpty);
    });

    test('getInsights should return samples when preview enabled', () async {
      final repo = FamilyInsightsRepositoryImpl(enablePreviewFallback: true);
      expect(await repo.getInsights(), isNotEmpty);
    });

    test('sendEncouragement should throw when preview disabled', () {
      final repo = FamilyInsightsRepositoryImpl(enablePreviewFallback: false);
      expect(repo.sendEncouragement('insight-1'), throwsUnsupportedError);
    });

    // Chạy với --dart-define=ENV=prod để check default theo ENV
    test(
      'default should disable preview for prod',
      () async {
        expect(await FamilyInsightsRepositoryImpl().getInsights(), isEmpty);
      },
      skip: const String.fromEnvironment('ENV') != 'prod',
    );
  });
}
