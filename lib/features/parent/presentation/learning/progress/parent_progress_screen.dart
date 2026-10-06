import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_course_progress_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/presentation/home/widgets/family_scope_selector.dart';
import 'package:study/features/parent/presentation/learning/class_detail/parent_class_detail_screen.dart';
import 'package:study/features/parent/presentation/learning/homework/parent_homework_screen.dart';
import 'package:study/features/parent/presentation/learning/progress/widgets/course_progress_card.dart';
import 'package:study/features/parent/presentation/learning/progress/widgets/progress_kpi_header.dart';
import 'package:study/features/parent/presentation/learning/progress/widgets/teacher_homeroom_note_card.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';

/// Màn hình Tiến độ học tập của con dành cho phụ huynh
class ParentProgressScreen extends StatefulWidget {
  const ParentProgressScreen({
    super.key,
    this.initialChildId,
    this.repository,
  });

  final String? initialChildId;
  final ParentLearningRepository? repository;

  @override
  State<ParentProgressScreen> createState() => _ParentProgressScreenState();
}

class _ParentProgressScreenState extends State<ParentProgressScreen> {
  late final ParentLearningRepository _repo;

  bool _isLoading = true;
  List<FamilyScopeChild> _children = [];
  String? _selectedChildId;
  ParentProgressScreenData? _progressData;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ??
        (diContainer.isRegistered<ParentLearningRepository>()
            ? diContainer<ParentLearningRepository>()
            : ParentLearningRepositoryImpl(
                apiClient: diContainer.isRegistered<ParentHomeApiClient>()
                    ? diContainer<ParentHomeApiClient>()
                    : null,
                enablePreviewFallback: true,
              ));
    _selectedChildId = widget.initialChildId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _repo.getChildren();
      if (!mounted) return;

      _children = children;
      if (_selectedChildId == null && children.isNotEmpty) {
        _selectedChildId = children.first.id;
      }

      await _fetchProgressData();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchProgressData() async {
    final childId = _selectedChildId ?? '';
    final data = await _repo.getProgressOverview(childId);

    if (!mounted) return;
    setState(() {
      _progressData = data;
    });
  }

  void _onChildChanged(String? childId) {
    if (childId == null || childId == _selectedChildId) return;
    setState(() {
      _selectedChildId = childId;
      _isLoading = true;
    });
    _fetchProgressData().whenComplete(() {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _navigateToClassDetail(String classId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ParentClassDetailScreen(
          classId: classId,
          childId: _selectedChildId,
        ),
      ),
    );
  }

  void _navigateToHomeworkScreen() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ParentHomeworkScreen(
          initialChildId: _selectedChildId,
          initialFilterKey: 'all',
          repository: _repo,
        ),
      ),
    );
  }

  void _showCertificateBottomSheet(ParentCourseProgressItem course) {
    final currentChild = _children.firstWhere(
      (c) => c.id == _selectedChildId,
      orElse: () => FamilyScopeChild.sample(
        id: 'sample',
        name: 'Minh',
        className: '10A1',
      ),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: Color(0xFFD97706),
                  size: 40,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'CHỨNG NHẬN HOÀN THÀNH KHÓA HỌC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                course.courseName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Chứng nhận học sinh ${currentChild.name} đã hoàn thành '
                'xuất sắc toàn bộ 12/12 buổi học với điểm đánh giá tổng '
                'kết 9.2/10.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Column(
                      children: [
                        Text(
                          'XẾP LOẠI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Xuất sắc',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const Column(
                      children: [
                        Text(
                          'NGÀY CẤP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '28/09/2024',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Đang tải bản chứng nhận điện tử (PDF)...',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'Tải chứng nhận PDF',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
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
        alpha:
            Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065,
      ),
      cs.surfaceContainer,
    );

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        title: const Text(
          'Tiến độ học tập',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: surfaceBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FamilyScopeSelector(
              children: _children,
              selectedChildId: _selectedChildId,
              onSelected: _onChildChanged,
              showAllOption: false,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProgressData,
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                children: [
                  if (_progressData != null) ...[
                    // Khối 2 KPI Cards
                    ProgressKpiHeader(overview: _progressData!.overview),
                    const SizedBox(height: 12),

                    // Tiêu đề danh sách khóa học
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        'CÁC KHÓA HỌC THEO DÕI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Danh sách các thẻ tiến độ khóa học
                    ..._progressData!.courses.map((course) {
                      return CourseProgressCard(
                        item: course,
                        onTapCard: () =>
                            _navigateToClassDetail(course.courseId),
                        onTapWarningAction: _navigateToHomeworkScreen,
                        onTapViewCertificate: () =>
                            _showCertificateBottomSheet(course),
                      );
                    }),
                    const SizedBox(height: 12),

                    // Khối ghi chú từ giáo viên chủ nhiệm
                    TeacherHomeroomNoteCard(
                      note: _progressData!.homeroomNote,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
