/// Shared storage for daily goals across screens
class DailyGoalsStorage {
  DailyGoalsStorage._();
  static final instance = DailyGoalsStorage._();

  final _goalsByDate = <String, List<DailyGoalItem>>{};

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
  }

  void toggleGoal(DateTime date, String id) {
    final key = _dateKey(date);
    final goals = List<DailyGoalItem>.from(_goalsByDate[key] ?? []);
    final index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      goals[index] = goals[index].copyWith(isCompleted: !goals[index].isCompleted);
      _goalsByDate[key] = goals;
    }
  }

  void deleteGoal(DateTime date, String id) {
    final key = _dateKey(date);
    final goals = List<DailyGoalItem>.from(_goalsByDate[key] ?? []);
    goals.removeWhere((g) => g.id == id);
    _goalsByDate[key] = goals;
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

  DailyGoalItem copyWith({String? id, String? title, bool? isCompleted}) =>
      DailyGoalItem(
        id: id ?? this.id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}
