import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/presentation/learning/course_detail/parent_course_detail_screen.dart';
import 'package:study/features/parent/presentation/learning/recommended_courses/widgets/ai_advisor_banner.dart';
import 'package:study/features/parent/presentation/learning/recommended_courses/widgets/course_consultation_card.dart';
import 'package:study/features/parent/presentation/learning/recommended_courses/widgets/course_filter_chips.dart';
import 'package:study/features/parent/presentation/learning/recommended_courses/widgets/recommended_course_card.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Gợi ý Khóa học (Recommended Courses) dành cho Phụ huynh.
///
/// Danh sách các chuyên đề và khóa học đề xuất cá nhân hoá dựa trên
/// phân tích sư phạm và lỗ hổng kiến thức thực tế của học sinh.
class ParentRecommendedCoursesScreen extends StatefulWidget {
  const ParentRecommendedCoursesScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.className = '10A1',
  });

  final String childId;
  final String childName;
  final String className;

  @override
  State<ParentRecommendedCoursesScreen> createState() =>
      _ParentRecommendedCoursesScreenState();
}

class _ParentRecommendedCoursesScreenState
    extends State<ParentRecommendedCoursesScreen> {
  late final ParentLearningRepository _repo;
  List<ParentRecommendedCourseItem> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';

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
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _repo.getRecommendedCourses(widget.childId);
      if (mounted) {
        setState(() {
          _courses = items;
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

  List<ParentRecommendedCourseItem> get _filteredCourses {
    if (_selectedFilter == 'all') return _courses;
    if (_selectedFilter == 'best_match') {
      return _courses.where((c) => c.matchPercent >= 90).toList();
    }
    return _courses.where((c) => c.categoryFilter == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Gợi ý khóa học · ${widget.childName}',
                  style: tt.titleMedium?.copyWith(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.className,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Dựa trên phân tích năng lực học tập',
              style: tt.bodySmall?.copyWith(
                color: cs.slate500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 22),
            color: const Color(0xFF0F172A),
            tooltip: 'Bộ lọc nâng cao',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng lọc theo học phí và lịch học.'),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCourses,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final courses = _filteredCourses;

    return RefreshIndicator(
      onRefresh: _fetchCourses,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Cố vấn AI & Giáo viên
            AiAdvisorBanner(childName: widget.childName),
            const SizedBox(height: 16),

            // 2. Filter chips cuộn ngang
            CourseFilterChips(
              selectedFilter: _selectedFilter,
              childName: widget.childName,
              onSelected: (key) {
                setState(() {
                  _selectedFilter = key;
                });
              },
            ),
            const SizedBox(height: 20),

            // 3. Tiêu đề danh sách đề xuất
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KHÓA HỌC ĐỀ XUẤT CHO ${widget.childName.toUpperCase()} '
                  '(${courses.length})',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Học kỳ II · 2024',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. Danh sách Course Cards
            if (courses.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return RecommendedCourseCard(
                    course: course,
                    onTap: () => _openCourseDetail(context, course.id),
                  );
                },
              ),

            const SizedBox(height: 24),

            // 5. Khối tư vấn 1-1 + Gọi Hotline
            CourseConsultationCard(
              childName: widget.childName,
              onBookConsultation: () => _handleBookConsultation(context),
              onCallHotline: () => _handleCallHotline(context),
            ),
            const SizedBox(height: 28),

            // 6. Footer thương hiệu
            const Center(
              child: Text(
                '© 40Study Mobile · Học tập chủ động & Cá nhân hóa',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 40,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(height: 10),
          Text(
            'Hiện tại ${widget.childName} đang theo sát tiến độ rất tốt!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chưa có chuyên đề bổ trợ nào cần thiết trong danh mục này.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _openCourseDetail(BuildContext context, String courseId) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ParentCourseDetailScreen(
          courseId: courseId,
          childName: widget.childName,
        ),
      ),
    );
  }

  void _handleBookConsultation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã đặt lịch tư vấn 1-1 cho ${widget.childName}. '
          'Cố vấn sẽ liên hệ trong 24h.',
        ),
      ),
    );
  }

  void _handleCallHotline(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang kết nối Hotline tư vấn 40Study: 1900 6868...'),
      ),
    );
  }
}
