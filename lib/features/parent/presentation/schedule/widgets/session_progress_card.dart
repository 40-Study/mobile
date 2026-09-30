import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_session_detail_model.dart';
import 'package:study/theme/theme.dart';

/// Card kết quả bài tập trên lớp (Quiz)
class SessionQuizResultCard extends StatelessWidget {
  const SessionQuizResultCard({
    super.key,
    required this.detail,
    required this.onViewDetailsTap,
  });

  final ParentSessionDetail detail;
  final VoidCallback onViewDetailsTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final analysis = detail.completedAnalysis;
    final correct = analysis?.quizCorrectAnswers ?? 3;
    final total = analysis?.quizTotalQuestions ?? 5;
    final percentage = analysis?.quizPercentage ?? 60;
    final scoreLabel = analysis?.scoreLabel ?? 'Cần rèn luyện thêm';

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x050F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'KẾT QUẢ BÀI TẬP TRÊN LỚP',
                style: tt.labelSmall?.copyWith(
                  color: cs.slate400,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  scoreLabel,
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            analysis?.quizTitle ?? 'Quiz & Thực hành tính toán nhanh',
            style: TextStyle(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),

          // Khối thống kê
          Row(
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 5.5,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
                    ),
                    Center(
                      child: Text(
                        '$correct/$total',
                        style: TextStyle(
                          color: cs.slate900,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$correct / $total đúng',
                          style: TextStyle(
                            color: cs.slate900,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Thời gian làm: ${analysis?.timeSpentMins ?? 18} phút / '
                      '${analysis?.timeLimitMins ?? 25} phút',
                      style: TextStyle(
                        color: cs.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segment Bar
          Row(
            children: List.generate(total, (index) {
              final isCorrect = index < correct;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index < total - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: cs.slate400),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Đúng $correct/$total câu trắc nghiệm • Cần ôn lại dạng quy đồng mẫu',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: cs.slate600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          InkWell(
            onTap: onViewDetailsTap,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Xem chi tiết bài làm của con',
                    style: TextStyle(
                      color: cs.blue600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 15, color: cs.blue600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card đánh giá và nhận xét của giáo viên
class SessionTeacherFeedbackCard extends StatelessWidget {
  const SessionTeacherFeedbackCard({
    super.key,
    required this.detail,
  });

  final ParentSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final analysis = detail.completedAnalysis;
    final teacher = detail.teacherInfo;
    final comment = analysis?.teacherComment ?? 'Giáo viên đang hoàn thiện nhận xét buổi học.';

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x050F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ĐÁNH GIÁ & NHẬN XÉT CỦA GIÁO VIÊN',
            style: tt.labelSmall?.copyWith(
              color: cs.slate400,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),

          // Thông tin giáo viên
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  teacher?.fullName.isNotEmpty == true
                      ? teacher!.fullName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher?.displayTitleWithName ?? detail.session.instructorName,
                      style: TextStyle(
                        color: cs.slate900,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${analysis?.teacherSubject ?? "Bộ môn Toán"} · '
                      '${analysis?.teacherCommentTime ?? "Hôm nay"}',
                      style: TextStyle(color: cs.slate500, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hộp trích dẫn
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: AppRadius.borderMd,
              border: const Border(
                left: BorderSide(color: Color(0xFF2563EB), width: 3.5),
                top: BorderSide(color: Color(0xFFE2E8F0)),
                right: BorderSide(color: Color(0xFFE2E8F0)),
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Text(
              '"$comment"',
              style: TextStyle(color: cs.slate800, fontSize: 12.5, height: 1.45),
            ),
          ),
          const SizedBox(height: 12),

          // Tag chuyên cần
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
                    const SizedBox(width: 5),
                    Text(
                      'Chuyên cần: • ${analysis?.attendanceStatus ?? "Có mặt đúng giờ"}',
                      style: const TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  'Học ${analysis?.attendedMinutes ?? 58}/${analysis?.totalMinutes ?? 60} phút',
                  style: TextStyle(
                    color: cs.slate700,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card bước tiếp theo: Bài tập về nhà + Link Insights
class SessionHomeworkNextStepCard extends StatelessWidget {
  const SessionHomeworkNextStepCard({
    super.key,
    required this.detail,
    required this.onInsightsTap,
  });

  final ParentSessionDetail detail;
  final VoidCallback onInsightsTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final analysis = detail.completedAnalysis;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BƯỚC TIẾP THEO CHO PHỤ HUYNH & CON',
                style: TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bài tập về nhà:',
            style: TextStyle(
              color: cs.slate600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            analysis?.homeworkTitle ?? 'Toán 10 — Bài luyện tập 5: Rút gọn phân số có ẩn',
            style: TextStyle(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis?.homeworkDueDate ?? 'Hạn chót: 20:00 tối nay',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis?.homeworkStatus ?? 'Chưa nộp',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFFDE68A)),
          const SizedBox(height: 10),
          InkWell(
            onTap: onInsightsTap,
            borderRadius: AppRadius.borderSm,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.insights_rounded, size: 16, color: Color(0xFFB45309)),
                  SizedBox(width: 6),
                  Text(
                    'Xem phân tích xu hướng học tập (Insights) ->',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
