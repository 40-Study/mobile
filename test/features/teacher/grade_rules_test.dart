import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/teacher/data/grade_rules.dart';

void main() {
  test('ungraded blanks stay absent while genuine zero is submitted', () {
    final grades = teacherDraftGrades(
      {'a': '', 'b': '0', 'c': '8.5'},
      {
        'name': 'Giữa kỳ',
        'grade_type': 'midterm',
        'max_score': '10',
        'weight': '0.3',
      },
    );
    expect(grades.length, 2);
    expect(grades.first['student_id'], 'b');
    expect(grades.first['score'], 0);
    expect(grades.last['score'], 8.5);
    expect(grades.last['weight'], 0.3);
    expect(grades.last.containsKey('column_id'), false);
  });
  test('scores reject out of range and nonfinite numbers', () {
    expect(teacherScoreError('0', 10), isNull);
    expect(teacherScoreError('10', '10'), isNull);
    for (final score in ['-1', '11', 'NaN', 'Infinity', '']) {
      expect(teacherScoreError(score, 10), isNotNull);
    }
  });
}
