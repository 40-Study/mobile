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

String? teacherAssignmentDateError(String start, String end) {
  final startDate = DateTime.tryParse(start);
  final endDate = DateTime.tryParse(end);
  if ((start.isNotEmpty && startDate == null) ||
      (end.isNotEmpty && endDate == null)) {
    return 'Vui lòng chọn lại thời gian bắt đầu và hạn nộp.';
  }
  if (startDate != null && endDate != null && !endDate.isAfter(startDate)) {
    return 'Hạn nộp phải sau thời điểm bắt đầu.';
  }
  return null;
}

String teacherAssignmentLocalTime(dynamic value) {
  final date = DateTime.tryParse('$value');
  return date == null
      ? 'Chưa đặt'
      : DateFormat('dd/MM/yyyy · HH:mm').format(date.toLocal());
}

String teacherAssignmentVerdict(dynamic value) => switch (value) {
  'pending' => 'Đang chờ chấm',
  'accepted' => 'Đạt',
  'wrong_answer' => 'Sai kết quả',
  'compilation_error' => 'Lỗi biên dịch',
  'runtime_error' => 'Lỗi khi chạy',
  'time_limit_exceeded' => 'Quá thời gian',
  'memory_limit_exceeded' => 'Vượt giới hạn bộ nhớ',
  _ => 'Chưa rõ kết quả',
};
