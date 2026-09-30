import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/parent_course_recommendation_models.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';

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
        : ParentLearningRepositoryImpl();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      bottomNavigationBar:
          _course != null ? _buildBottomStickyBar(context) : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _course == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
            // 1. Tag trên cùng
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    course.subjectTag,
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gợi ý riêng cho ${widget.childName}',
                        style: const TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Tên khóa học & mô tả phụ
            Text(
              course.courseName,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 22,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              course.subtitle,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),

            // 3. Đánh giá sao & số học viên
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  course.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  ' (${course.reviewCount} đánh giá) • ',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.people_outline_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  '${course.studentCount} học viên đang theo học',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Callout VÌ SAO GỢI Ý CHO CON? (Khối giá trị cốt lõi)
            _buildWhyRecommendedCallout(course),
            const SizedBox(height: 24),

            // 5. Khối Học phí & Hỗ trợ đóng phí
            _buildTuitionSection(course),
            const SizedBox(height: 28),

            // 6. Thông số chi tiết lớp học
            _buildSpecificationsSection(course),
            const SizedBox(height: 28),

            // 7. Đề cương học tập cốt lõi
            _buildSyllabusSection(course),
            const SizedBox(height: 24),

            // 8. Cam kết 40Study
            _buildGuaranteeCard(course),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Khối Callout: VÌ SAO GỢI Ý CHO MINH?
  Widget _buildWhyRecommendedCallout(
    ParentRecommendedCourseDetailModel course,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 18,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'VÌ SAO GỢI Ý CHO '
                              '${widget.childName.toUpperCase()}?',
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFBFDBFE),
                            ),
                          ),
                          child: const Text(
                            'AI Sư phạm',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 13,
                          height: 1.45,
                        ),
                        children: [
                          TextSpan(
                            text: 'Khóa học này tập trung vào dạng bài mà '
                                '${widget.childName} đang có tỷ lệ làm đúng ',
                          ),
                          const TextSpan(
                            text: '60%',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text: ' ở 2 buổi học gần nhất. Giúp củng cố phương '
                                'pháp giải và tăng tốc độ làm bài thi.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Khối hiển thị học phí, giảm giá và cam kết hoàn tiền
  Widget _buildTuitionSection(ParentRecommendedCourseDetailModel course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HỌC PHÍ TRỌN GÓI KỲ HỌC',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatCurrency(course.tuitionFee),
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatCurrency(course.originalFee),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                course.discountLabel,
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              size: 16,
              color: Color(0xFF16A34A),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                course.feeSupportText,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Khối danh sách 6 thông số chi tiết lớp học
  Widget _buildSpecificationsSection(
    ParentRecommendedCourseDetailModel course,
  ) {
    final specs = [
      {
        'icon': Icons.school_outlined,
        'label': 'Độ tuổi & Trình độ',
        'value': course.targetGrade,
        'isHighlight': false,
      },
      {
        'icon': Icons.hourglass_empty_rounded,
        'label': 'Thời lượng',
        'value': course.durationText,
        'isHighlight': false,
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Lịch học cố định',
        'value': course.scheduleFixed,
        'isHighlight': true,
      },
      {
        'icon': Icons.laptop_chromebook_rounded,
        'label': 'Hình thức học',
        'value': course.formatText,
        'isHighlight': false,
      },
      {
        'icon': Icons.menu_book_rounded,
        'label': 'Giáo trình & Hỗ trợ',
        'value': course.materialsText,
        'isHighlight': false,
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Giảng viên phụ trách',
        'value': course.teacherName,
        'isHighlight': false,
        'isTeacher': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THÔNG SỐ CHI TIẾT LỚP HỌC',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: specs.map((item) {
              final isHighlight = item['isHighlight'] as bool;
              final isTeacher = item['isTeacher'] as bool? ?? false;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Text(
                        item['label'] as String,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              item['value'] as String,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: isHighlight
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF0F172A),
                                fontWeight: isHighlight
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isTeacher) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Khối Đề cương học tập cốt lõi 4 chuyên đề
  Widget _buildSyllabusSection(ParentRecommendedCourseDetailModel course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ĐỀ CƯƠNG HỌC TẬP CỐT LÕI',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${course.syllabusModules.length} Chuyên đề · 8 Buổi',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: course.syllabusModules.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final mod = course.syllabusModules[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${mod.order}',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                mod.title,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mod.sessionCountLabel,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mod.description,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Khối Cam kết bảo vệ quyền lợi phụ huynh của 40Study
  Widget _buildGuaranteeCard(ParentRecommendedCourseDetailModel course) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 20,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Color(0xFF166534),
                  fontSize: 12.5,
                  height: 1.45,
                ),
                children: [
                  const TextSpan(
                    text: 'Cam kết 40Study: ',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: course.guaranteeNote),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Khối Sticky Button ở đáy màn hình
  Widget _buildBottomStickyBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleEnrollCourse(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đăng ký khóa học ngay',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Đảm bảo hoàn học phí',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  '  •  ',
                  style: TextStyle(color: Color(0xFFCBD5E1)),
                ),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Mở yêu cầu tư vấn 1-1 cho khóa học của '
                          '${widget.childName}.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Tư vấn miễn phí 1-1',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Xác nhận đăng ký khóa học'),
          content: Text(
            'Bạn đang đăng ký khóa học "${_course?.courseName}" cho '
            '${widget.childName}.\n\n'
            'Học phí: ${_formatCurrency(_course?.tuitionFee ?? 0)}\n'
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

  static String _formatCurrency(int amount) {
    final buffer = StringBuffer();
    final str = amount.toString();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join()}đ';
  }
}
