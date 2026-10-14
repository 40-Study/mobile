import 'widgets/homework_submission_card.dart';
import 'widgets/homework_description_card.dart';
import 'widgets/homework_result_card.dart';
import 'widgets/homework_overview_card.dart';
import 'widgets/homework_detail_actions.dart';
import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
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
    _repo =
        widget.repository ??
        (diContainer.isRegistered<ParentLearningRepository>()
            ? diContainer<ParentLearningRepository>()
            : ParentLearningRepositoryImpl(
                apiClient: diContainer.isRegistered<ParentHomeApiClient>()
                    ? diContainer<ParentHomeApiClient>()
                    : null,
                enablePreviewFallback: true,
              ));
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
                  child: Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF2563EB),
                  ),
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
                  child: Icon(Icons.phone_outlined, color: Color(0xFF16A34A)),
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
    final cs = Theme.of(context).colorScheme;
    final surfaceBg = Color.alphaBlend(
      cs.primary.withValues(
        alpha: Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065,
      ),
      cs.surfaceContainer,
    );

    if (_isLoading) {
      return Scaffold(
        backgroundColor: surfaceBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final detail = _detail;
    if (detail == null) {
      return Scaffold(
        backgroundColor: surfaceBg,
        appBar: AppBar(
          backgroundColor: surfaceBg,
          title: const Text('Chi tiết bài tập'),
        ),
        body: const Center(child: Text('Không tìm thấy thông tin bài tập')),
      );
    }

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        title: const Text(
          'Chi tiết bài tập',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: surfaceBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      bottomNavigationBar: HomeworkDetailActions(
        detail: detail,
        onRemind: _handleRemindChild,
        onContactTeacher: _handleContactTeacher,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thẻ tổng quan bài tập
          HomeworkOverviewCard(detail: detail),
          const SizedBox(height: 16),

          // Khối điểm số và nhận xét của giáo viên (nếu đã chấm điểm)
          if (detail.status == ParentHomeworkStatus.graded &&
              detail.score != null) ...[
            HomeworkResultCard(detail: detail),
            const SizedBox(height: 16),
          ],

          // Mô tả đề bài
          HomeworkDescriptionCard(detail: detail),
          const SizedBox(height: 16),

          // Bài nộp của con (nếu có)
          if (detail.submittedFiles.isNotEmpty ||
              detail.studentSubmissionNote != null) ...[
            HomeworkSubmissionCard(detail: detail),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
