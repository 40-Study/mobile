import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _storageKey = 'daily_goals';

/// Shared storage for daily goals across screens - persisted to SharedPreferences
class DailyGoalsStorage {
  DailyGoalsStorage._();
  static final instance = DailyGoalsStorage._();

  SharedPreferences? _prefs;
  final _goalsByDate = <String, List<DailyGoalItem>>{};

  /// Init storage - call once at app start
  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final json = _prefs?.getString(_storageKey);
    if (json == null) return;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      _goalsByDate.clear();
      map.forEach((key, value) {
        final list = (value as List)
            .map((e) => DailyGoalItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _goalsByDate[key] = list;
      });
    } catch (_) {
      // Ignore parse errors
    }
  }

  void _saveToPrefs() {
    if (_prefs == null) return;

    final map = <String, dynamic>{};
    _goalsByDate.forEach((key, value) {
      map[key] = value.map((e) => e.toJson()).toList();
    });
    _prefs!.setString(_storageKey, jsonEncode(map));
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  List<DailyGoalItem> getGoals(DateTime date) =>
      List.unmodifiable(_goalsByDate[_dateKey(date)] ?? []);

  void addGoal(DateTime date, String title) {
    final key = _dateKey(date);
    final goals = List<DailyGoalItem>.from(_goalsByDate[key] ?? []);
    goals.add(DailyGoalItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    ));
    _goalsByDate[key] = goals;
    _saveToPrefs();
  }

  void toggleGoal(DateTime date, String id) {
    final key = _dateKey(date);
    final goals = List<DailyGoalItem>.from(_goalsByDate[key] ?? []);
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      goals[index] = goals[index].copyWith(isCompleted: !goals[index].isCompleted);
      _goalsByDate[key] = goals;
      _saveToPrefs();
    }
  }

  void deleteGoal(DateTime date, String id) {
    final key = _dateKey(date);
    final goals = List<DailyGoalItem>.from(_goalsByDate[key] ?? []);
    goals.removeWhere((g) => g.id == id);
    _goalsByDate[key] = goals;
    _saveToPrefs();
  }

  /// Get today's progress (completed / total)
  (int completed, int total) getTodayProgress() {
    final goals = getGoals(DateTime.now());
    return (goals.where((g) => g.isCompleted).length, goals.length);
  }
}

class DailyGoalItem {
  const DailyGoalItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  factory DailyGoalItem.fromJson(Map<String, dynamic> json) => DailyGoalItem(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  DailyGoalItem copyWith({String? id, String? title, bool? isCompleted}) =>
      DailyGoalItem(
        id: id ?? this.id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}
