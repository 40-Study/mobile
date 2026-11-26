import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/data/daily_goals_storage.dart';

void main() {
  group('DailyGoalsStorage', () {
    test('clear should drop in-memory and persisted goals', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = DailyGoalsStorage.instance;
      await storage.init(prefs);
      storage.addGoal(DateTime.now(), 'Đọc bài 1');
      expect(storage.getGoals(DateTime.now()), isNotEmpty);

      await storage.clear();

      expect(storage.getGoals(DateTime.now()), isEmpty);
      expect(prefs.containsKey('daily_goals'), isFalse);
    });
  });
}
