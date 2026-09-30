import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_session_detail_model.dart';
import 'package:study/theme/theme.dart';

/// Bottom Sheet chi tiết bài Quiz trên lớp
void showQuizAnswersSheet(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CHI TIẾT BÀI QUIZ TRÊN LỚP',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Học sinh làm đúng 3 / 5 câu trắc nghiệm (60%)',
            style: TextStyle(color: cs.slate600, fontSize: 13),
          ),
          const Divider(height: 24),
          _QuizAnswerTile(questionNum: 1, topic: 'Xác định tập nghiệm phương trình bậc nhất', isCorrect: true, detail: 'Đúng · Hoàn thành trong 2.5 phút'),
          _QuizAnswerTile(questionNum: 2, topic: 'Biến đổi phân thức đại số cơ bản', isCorrect: true, detail: 'Đúng · Hoàn thành trong 3 phút'),
          _QuizAnswerTile(questionNum: 3, topic: 'Quy đồng mẫu thức chứa tham số', isCorrect: false, detail: 'Chưa chính xác · Chọn B (Đáp án đúng: C)'),
          _QuizAnswerTile(questionNum: 4, topic: 'Rút gọn biểu thức điều kiện xác định', isCorrect: true, detail: 'Đúng · Hoàn thành trong 4 phút'),
          _QuizAnswerTile(questionNum: 5, topic: 'Tìm giá trị nguyên để biểu thức đạt cực đại', isCorrect: false, detail: 'Chưa chính xác · Chọn A (Đáp án đúng: D)'),
        ],
      ),
    ),
  );
}

class _QuizAnswerTile extends StatelessWidget {
  const _QuizAnswerTile({
    required this.questionNum,
    required this.topic,
    required this.isCorrect,
    required this.detail,
  });

  final int questionNum;
  final String topic;
  final bool isCorrect;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              size: 15,
              color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu $questionNum: $topic',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isCorrect ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet nhắc con ôn luyện bài học
void showReminderActionSheet(BuildContext context, {required String childName, String? homeworkTitle}) {
  final cs = Theme.of(context).colorScheme;
  final homework = homeworkTitle ?? 'Bài luyện tập sau buổi học';

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: cs.slate300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('NHẮC CON ÔN LUYỆN BÀI HỌC', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, size: 20)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Gửi nhắc nhở học tập đến $childName để con hoàn thành bài tập đúng hạn.',
            style: TextStyle(color: cs.slate600, fontSize: 13, height: 1.4),
          ),
          const Divider(height: 24),
          _ReminderOption(
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFDBEAFE),
            title: 'Gửi thông báo vào máy của con',
            subtitle: 'Con sẽ nhận được pop-up nhắc làm bài tập ngay lập tức.',
            titleColor: const Color(0xFF1E3A8A),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã gửi thông báo nhắc học đến máy của $childName.'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          const SizedBox(height: 12),
          _ReminderOption(
            icon: Icons.copy_rounded,
            iconColor: const Color(0xFF475569),
            bgColor: const Color(0xFFF8FAFC),
            borderColor: const Color(0xFFE2E8F0),
            title: 'Sao chép lời nhắn gửi qua Zalo / SMS',
            subtitle: 'Mẫu: "$childName ơi, con nhớ hoàn thành $homework..."',
            titleColor: const Color(0xFF0F172A),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép lời nhắn! Phụ huynh có thể dán vào Zalo/SMS để gửi cho con.'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _ReminderOption extends StatelessWidget {
  const _ReminderOption({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final String title;
  final String subtitle;
  final Color titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.paddingSm,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: titleColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11.5, color: cs.slate600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet xin phép vắng hoặc đến muộn
class AbsenceRequestBottomSheet extends StatefulWidget {
  const AbsenceRequestBottomSheet({
    super.key,
    required this.childName,
    required this.sessionTime,
  });

  final String childName;
  final String sessionTime;

  @override
  State<AbsenceRequestBottomSheet> createState() => _AbsenceRequestBottomSheetState();
}

class _AbsenceRequestBottomSheetState extends State<AbsenceRequestBottomSheet> {
  int _requestType = 0;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: cs.slate300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XIN PHÉP VẮNG / ĐẾN MUỘN', style: TextStyle(color: cs.slate900, fontWeight: FontWeight.w800, fontSize: 14)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, size: 20), visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 8),
          Text('Học sinh: ${widget.childName} • Ca học: ${widget.sessionTime}', style: TextStyle(color: cs.slate600, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ChoiceChip(label: const Text('Xin vắng cả buổi'), selected: _requestType == 0, onSelected: (val) => setState(() => _requestType = 0))),
              const SizedBox(width: 8),
              Expanded(child: ChoiceChip(label: const Text('Báo đến muộn'), selected: _requestType == 1, onSelected: (val) => setState(() => _requestType = 1))),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập lý do gửi giáo viên (bị ốm, bận việc...)',
              hintStyle: TextStyle(color: cs.slate400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi thông báo xin phép tới giáo viên.'), behavior: SnackBarBehavior.floating));
              },
              style: FilledButton.styleFrom(backgroundColor: cs.slate900, shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd)),
              child: const Text('Gửi thông báo'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet thông tin và nhắn tin cho Giáo viên
class TeacherChatBottomSheet extends StatelessWidget {
  const TeacherChatBottomSheet({super.key, required this.teacher});

  final TeacherDetailInfo teacher;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: cs.slate300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  teacher.fullName.isNotEmpty ? teacher.fullName[0].toUpperCase() : 'G',
                  style: TextStyle(color: cs.blue700, fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teacher.displayTitleWithName, style: TextStyle(color: cs.slate900, fontWeight: FontWeight.w700, fontSize: 16)),
                    if (teacher.school != null) ...[
                      const SizedBox(height: 2),
                      Text(teacher.school!, style: TextStyle(color: cs.slate500, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, size: 20)),
            ],
          ),
          const Divider(height: 24),
          const Text('Gửi tin nhắn trực tiếp cho giáo viên phụ trách ca học.', style: TextStyle(fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang mở hộp thoại chat với ${teacher.fullName}...'), behavior: SnackBarBehavior.floating),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Bắt đầu trò chuyện'),
              style: FilledButton.styleFrom(backgroundColor: cs.blue600, shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet đánh giá buổi học sau khi ca học đã kết thúc
class SessionFeedbackBottomSheet extends StatefulWidget {
  const SessionFeedbackBottomSheet({
    super.key,
    required this.subjectName,
    required this.instructorName,
  });

  final String subjectName;
  final String instructorName;

  @override
  State<SessionFeedbackBottomSheet> createState() => _SessionFeedbackBottomSheetState();
}

class _SessionFeedbackBottomSheetState extends State<SessionFeedbackBottomSheet> {
  int _rating = 5;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: cs.slate300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ĐÁNH GIÁ BUỔI HỌC', style: TextStyle(color: cs.slate900, fontWeight: FontWeight.w800, fontSize: 14)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, size: 20), visualDensity: VisualDensity.compact),
            ],
          ),
          const SizedBox(height: 6),
          Text('Môn: ${widget.subjectName} • GV: ${widget.instructorName}', style: TextStyle(color: cs.slate600, fontSize: 13)),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: const Color(0xFFD97706),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ý kiến góp ý của phụ huynh (tùy chọn)...',
              hintStyle: TextStyle(color: cs.slate400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cảm ơn phụ huynh đã gửi đánh giá buổi học!'), behavior: SnackBarBehavior.floating));
              },
              style: FilledButton.styleFrom(backgroundColor: cs.slate900, shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd)),
              child: const Text('Gửi đánh giá'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet chia sẻ thông tin ca học
void showShareSessionSheet(BuildContext context, {
  required String childName,
  required String subjectName,
  required String timeRangeText,
  required DateTime startTime,
  required String? roomOrPlatform,
  required String instructorName,
}) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CHIA SẺ THÔNG TIN CA HỌC', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'Lịch học của $childName:\n'
              '• Môn: $subjectName\n'
              '• Giờ: $timeRangeText ngày ${_formatDateFull(startTime)}\n'
              '• Phòng: ${roomOrPlatform ?? "Trực tuyến"}\n'
              '• Giáo viên: $instructorName',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép tóm tắt vào bộ nhớ tạm.'), behavior: SnackBarBehavior.floating));
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Sao chép tóm tắt'),
            ),
          ),
        ],
      ),
    ),
  );
}

String _formatDateFull(DateTime date) {
  const weekdays = ['', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
  final wd = weekdays[date.weekday];
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year;
  return '$wd, $d/$m/$y';
}
