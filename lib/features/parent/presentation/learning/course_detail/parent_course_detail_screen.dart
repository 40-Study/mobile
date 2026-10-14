import 'widgets/parent_course_overview.dart';
import 'widgets/parent_course_enrollment_bar.dart';
import 'widgets/parent_course_currency.dart';
import 'widgets/parent_course_guarantee.dart';
import 'widgets/parent_course_syllabus.dart';
import 'widgets/parent_course_specifications.dart';
import 'widgets/parent_course_tuition.dart';
import 'widgets/course_recommendation_callout.dart';
import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Chi tiết Khóa học Gợi ý (Course Detail) dành cho Phụ huynh.
///
/// Thể hiện đầy đủ lý do sư phạm gợi ý cho con, thông số lớp học,
/// đề cương 4 chuyên đề cốt lõi và chính sách hoàn phí bảo vệ phụ huynh.
class ParentCourseDetailScreen extends StatefulWidget {
  const ParentCourseDetailScreen({
    super.key,
    required this.courseId,
    required this.childName,
  });

  final String courseId;
  final String childName;

  @override
  State<ParentCourseDetailScreen> createState() =>
      _ParentCourseDetailScreenState();
}

class _ParentCourseDetailScreenState extends State<ParentCourseDetailScreen> {
  late final ParentLearningRepository _repo;
  ParentRecommendedCourseDetailModel? _course;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repo = diContainer.isRegistered<ParentLearningRepository>()
        ? diContainer<ParentLearningRepository>()
        : ParentLearningRepositoryImpl(
            apiClient: diContainer.isRegistered<ParentHomeApiClient>()
                ? diContainer<ParentHomeApiClient>()
                : null,
            enablePreviewFallback: true,
          );
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _repo.getRecommendedCourseDetail(
        widget.courseId,
        childId: widget.childName,
      );
      if (mounted) {
        setState(() {
          _course = detail;
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
        alpha: Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065,
      ),
      cs.surfaceContainer,
    );

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Chi tiết khóa học',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 21),
            color: const Color(0xFF0F172A),
            tooltip: 'Chia sẻ khóa học',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép liên kết thông tin khóa học.'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, size: 23),
            color: const Color(0xFF0F172A),
            tooltip: 'Lưu khóa học',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu khóa học vào danh sách quan tâm.'),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context),
      bottomNavigationBar: _course != null
          ? ParentCourseEnrollmentBar(
              childName: widget.childName,
              onEnroll: () => _handleEnrollCourse(context),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _course == null) {
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
                _errorMessage ?? 'Không tìm thấy thông tin khóa học.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final course = _course!;

    return RefreshIndicator(
      onRefresh: _fetchDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ParentCourseOverview(course: course, childName: widget.childName),
            const SizedBox(height: 20),

            // 4. Callout VÌ SAO GỢI Ý CHO CON? (Khối giá trị cốt lõi)
            CourseRecommendationCallout(
              course: course,
              childName: widget.childName,
            ),
            const SizedBox(height: 24),

            // 5. Khối Học phí & Hỗ trợ đóng phí
            ParentCourseTuition(course: course),
            const SizedBox(height: 28),

            // 6. Thông số chi tiết lớp học
            ParentCourseSpecifications(course: course),
            const SizedBox(height: 28),

            // 7. Đề cương học tập cốt lõi
            ParentCourseSyllabus(course: course),
            const SizedBox(height: 24),

            // 8. Cam kết 40Study
            ParentCourseGuarantee(course: course),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _handleEnrollCourse(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          title: const Text('Xác nhận đăng ký khóa học'),
          content: Text(
            'Bạn đang đăng ký khóa học "${_course?.courseName}" cho '
            '${widget.childName}.\n\n'
            'Học phí: ${formatParentCourseCurrency(_course?.tuitionFee ?? 0)}\n'
            'Lịch học: ${_course?.scheduleFixed}\n\n'
            'Ban tư vấn 40Study sẽ liên hệ xác nhận và hướng dẫn thanh toán.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Để sau'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đăng ký thành công khóa học cho ${widget.childName}!',
                    ),
                  ),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}
