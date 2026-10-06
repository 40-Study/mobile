import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/parent_class_detail_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/presentation/learning/class_detail/widgets/class_lesson_timeline_widget.dart';
import 'package:study/features/parent/presentation/learning/class_detail/widgets/class_progress_result_card.dart';
import 'package:study/features/parent/presentation/learning/class_detail/widgets/class_teacher_card.dart';
import 'package:study/features/parent/presentation/learning/homework/parent_homework_screen.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Chi tiết Lớp học của con dành cho Phụ huynh (Locked Child Context).
///
/// Thể hiện:
/// - Tiêu đề môn học và con được khóa ngữ cảnh (không có child selector)
/// - Thông tin Giáo viên, lịch học cố định, hình thức học & nút nhắn tin
/// - 3 Chỉ số lớn: Tiến độ hoàn thành buổi, % chuyên cần, Điểm trung bình
/// - Timeline dọc các buổi học với trạng thái, điểm quiz và video xem lại
/// - Sticky CTA Button đáy chuyển sang xem danh sách bài tập của lớp
class ParentClassDetailScreen extends StatefulWidget {
  const ParentClassDetailScreen({
    super.key,
    this.classId = 'class-toan-10',
    this.childId,
    this.childName = 'Minh',
  });

  final String classId;
  final String? childId;
  final String childName;

  @override
  State<ParentClassDetailScreen> createState() =>
      _ParentClassDetailScreenState();
}

class _ParentClassDetailScreenState extends State<ParentClassDetailScreen> {
  ParentClassDetailModel? _classDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClassDetail();
  }

  Future<void> _loadClassDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = diContainer.isRegistered<ParentLearningRepository>()
          ? diContainer<ParentLearningRepository>()
          : ParentLearningRepositoryImpl(
              apiClient: diContainer.isRegistered<ParentHomeApiClient>()
                  ? diContainer<ParentHomeApiClient>()
                  : null,
              enablePreviewFallback: true,
            );

      final detail = await repo.getClassDetail(
        widget.classId,
        childId: widget.childId,
      );

      if (mounted) {
        setState(() {
          _classDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surfaceBg = Color.alphaBlend(
      cs.primary.withValues(
        alpha:
            Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065,
      ),
      cs.surfaceContainer,
    );

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: const BackButton(color: Color(0xFF0F172A)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _classDetail != null
                  ? '${_classDetail!.className} · ${_classDetail!.childName}'
                  : 'Lớp học · ${widget.childName}',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 16.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _classDetail?.semester ?? 'Chưa tham gia lớp học',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          if (_classDetail != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xFF64748B)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chia sẻ thông tin lớp học của con'),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF64748B),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Thông tin quy chế đào tạo và đánh giá lớp học',
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _classDetail != null
          ? _buildBottomStickyButton(context)
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingXl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadClassDetail,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_classDetail == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_outlined,
                  size: 36,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có thông tin lớp học',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.childName} hiện chưa được ghi danh vào lớp học này '
                'trên hệ thống.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _classDetail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Khối Giáo viên & Lịch học
          ClassTeacherCard(classDetail: detail),
          const SizedBox(height: 16),

          // 2. Khối Tiến độ & Kết quả học tập
          ClassProgressResultCard(classDetail: detail),
          const SizedBox(height: 16),

          // 3. Khối Lộ trình & Danh sách buổi học
          ClassLessonTimelineWidget(
            lessons: detail.lessons,
            onTapLesson: (lesson) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Mở chi tiết ${lesson.title} '
                    '(Quiz: ${lesson.quizScoreText ?? 'N/A'})',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStickyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ParentHomeworkScreen(
                    initialChildId: widget.childId,
                  ),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Xem bài tập của lớp này',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
