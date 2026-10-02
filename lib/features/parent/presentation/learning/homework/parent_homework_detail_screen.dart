import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';

/// Màn hình Chi tiết bài tập về nhà dành cho phụ huynh (View-only)
/// Tuân thủ quy tắc phụ huynh chỉ theo dõi, hỗ trợ nhắc nhở,
/// tuyệt đối không có tính năng làm bài hay nộp thay con.
class ParentHomeworkDetailScreen extends StatefulWidget {
  const ParentHomeworkDetailScreen({
    super.key,
    required this.homeworkId,
    this.childId,
    this.repository,
  });

  final String homeworkId;
  final String? childId;
  final ParentLearningRepository? repository;

  @override
  State<ParentHomeworkDetailScreen> createState() =>
      _ParentHomeworkDetailScreenState();
}

class _ParentHomeworkDetailScreenState
    extends State<ParentHomeworkDetailScreen> {
  late final ParentLearningRepository _repo;
  bool _isLoading = true;
  ParentHomeworkDetailModel? _detail;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ParentLearningRepositoryImpl();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await _repo.getHomeworkDetail(
        widget.homeworkId,
        childId: widget.childId,
      );
      if (!mounted) return;
      setState(() => _detail = detail);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleRemindChild() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Đã gửi thông báo nhắc con nộp bài tập đúng hạn!'),
            ),
          ],
        ),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleContactTeacher() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final teacherName = _detail?.teacherName ?? 'Giáo viên';
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Liên hệ $teacherName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Phụ huynh có thể gửi tin nhắn trao đổi về tình hình làm '
                'bài tập của con với giáo viên bộ môn qua hòm thư hỗ trợ.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.chat_bubble_outline,
                      color: Color(0xFF2563EB)),
                ),
                title: const Text('Gửi tin nhắn nội bộ'),
                subtitle: const Text('Phản hồi trong vòng 24 giờ'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng nhắn tin đang kết nối GV...'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF0FDF4),
                  child: Icon(Icons.phone_outlined,
                      color: Color(0xFF16A34A)),
                ),
                title: const Text('Đặt lịch trao đổi trực tiếp'),
                subtitle: const Text('15 phút qua Google Meet'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã mở form đặt lịch trao đổi.'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final detail = _detail;
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết bài tập')),
        body: const Center(
          child: Text('Không tìm thấy thông tin bài tập'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Chi tiết bài tập',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Nút nhắc con nộp bài (nếu chưa nộp hoặc cần nộp gấp)
              if (detail.status == ParentHomeworkStatus.urgent ||
                  detail.status == ParentHomeworkStatus.inProgress)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleRemindChild,
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    label: const Text(
                      'Nhắc con nộp',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (detail.status == ParentHomeworkStatus.urgent ||
                  detail.status == ParentHomeworkStatus.inProgress)
                const SizedBox(width: 12),

              // Nút nhắn tin giáo viên
              Expanded(
                flex: detail.status == ParentHomeworkStatus.graded ? 2 : 1,
                child: ElevatedButton.icon(
                  onPressed: _handleContactTeacher,
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text(
                    'Nhắn giáo viên',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ tổng quan bài tập
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBgColor(detail.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        detail.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getStatusTextColor(detail.status),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          detail.timeRemainingText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  detail.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Môn: ${detail.subjectName} · GV: ${detail.teacherName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hạn nộp: ${detail.dueDateText}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Khối điểm số và nhận xét của giáo viên (nếu đã chấm điểm)
          if (detail.status == ParentHomeworkStatus.graded &&
              detail.score != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: Color(0xFF16A34A),
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'KẾT QUẢ ĐÃ CHẤM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${detail.score!.toStringAsFixed(1)} / ${detail.maxScore.toInt()}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  if (detail.teacherFeedback != null) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFDCFCE7)),
                    const SizedBox(height: 10),
                    const Text(
                      'Lời phê của giáo viên:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.teacherFeedback!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF166534),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Mô tả đề bài
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YÊU CẦU ĐỀ BÀI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  detail.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
                if (detail.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Tài liệu đính kèm từ giáo viên:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...detail.attachments.map((file) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 20,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.download_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bài nộp của con (nếu có)
          if (detail.submittedFiles.isNotEmpty ||
              detail.studentSubmissionNote != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BÀI NỘP CỦA CON',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (detail.submittedAtText != null)
                        Text(
                          detail.submittedAtText!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                  if (detail.studentSubmissionNote != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      detail.studentSubmissionNote!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (detail.submittedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...detail.submittedFiles.map((file) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.task_rounded,
                              size: 20,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                file,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Color _getStatusBgColor(ParentHomeworkStatus status) {
    switch (status) {
      case ParentHomeworkStatus.urgent:
        return const Color(0xFFFEE2E2);
      case ParentHomeworkStatus.inProgress:
        return const Color(0xFFFEF3C7);
      case ParentHomeworkStatus.graded:
        return const Color(0xFFDCFCE7);
      case ParentHomeworkStatus.submitted:
        return const Color(0xFFEFF6FF);
      case ParentHomeworkStatus.overdue:
        return const Color(0xFFFEE2E2);
    }
  }

  Color _getStatusTextColor(ParentHomeworkStatus status) {
    switch (status) {
      case ParentHomeworkStatus.urgent:
        return const Color(0xFFDC2626);
      case ParentHomeworkStatus.inProgress:
        return const Color(0xFFD97706);
      case ParentHomeworkStatus.graded:
        return const Color(0xFF15803D);
      case ParentHomeworkStatus.submitted:
        return const Color(0xFF2563EB);
      case ParentHomeworkStatus.overdue:
        return const Color(0xFFDC2626);
    }
  }
}
