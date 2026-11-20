const teacherGradeTypes = [
  'assignment',
  'quiz',
  'midterm',
  'final',
  'attendance',
  'participation',
  'project',
  'other',
];
String? teacherScoreError(String score, dynamic maxScore) {
  final value = num.tryParse(score.trim());
  final max = num.tryParse('$maxScore');
  if (value == null ||
      !value.isFinite ||
      max == null ||
      !max.isFinite ||
      max <= 0 ||
      value < 0 ||
      value > max) {
    return 'Điểm phải từ 0 đến $maxScore.';
  }
  return null;
}

List<Map<String, dynamic>> teacherDraftGrades(
  Map<String, String> scores,
  Map<String, dynamic> column,
) {
  return [
    for (final entry in scores.entries)
      if (entry.value.trim().isNotEmpty)
        {
          'student_id': entry.key,
          'title': column['name'],
          'grade_type': column['grade_type'],
          'score': num.parse(entry.value),
          'max_score': num.parse('${column['max_score']}'),
          'weight': num.parse('${column['weight']}'),
        },
  ];
}
