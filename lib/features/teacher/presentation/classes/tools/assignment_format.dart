import 'package:intl/intl.dart';

String teacherAssignmentDeadline(dynamic value) {
  final date = DateTime.tryParse('$value');
  return date == null
      ? 'Chưa đặt hạn nộp'
      : 'Hạn nộp ${DateFormat('dd/MM/yyyy · HH:mm').format(date.toLocal())}';
}

String teacherAssignmentDifficulty(dynamic value) => switch (value) {
  'easy' => 'Dễ',
  'medium' => 'Trung bình',
  'hard' => 'Khó',
  _ => '$value',
};
