import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class InstructorReviewsScreen extends StatefulWidget {
  const InstructorReviewsScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
    this.instructorAvatar,
    this.instructorTitle,
  });

  final String instructorId;
  final String instructorName;
  final String? instructorAvatar;
  final String? instructorTitle;

  @override
  State<InstructorReviewsScreen> createState() =>
      _InstructorReviewsScreenState();
}

class _ReviewItemData {
  _ReviewItemData({
    required this.id,
    required this.studentName,
    required this.studentAvatar,
    required this.rating,
    required this.date,
    required this.courseName,
    required this.comment,
    required this.helpfulCount,
  });

  final String id;
  final String studentName;
  final String studentAvatar;
  final int rating;
  final String date;
  final String courseName;
  final String comment;
  int helpfulCount;
  bool isHelpful = false;
}

class _InstructorReviewsScreenState extends State<InstructorReviewsScreen> {
  int _selectedRatingFilter = 0; // 0 = Tất cả

  late final List<_ReviewItemData> _reviews = [
    _ReviewItemData(
      id: 'rev_1',
      studentName: 'Trần Thị Bích',
      studentAvatar: 'B',
      rating: 5,
      date: '2 ngày trước',
      courseName: 'UI/UX Design Fundamentals',
      comment:
          'Thầy giảng rất dễ hiểu và tận tâm. Các ví dụ minh họa sát với thực tế dự án, đặc biệt phần hướng dẫn làm Wireframe và Prototype bằng Figma cực kỳ chi tiết!',
      helpfulCount: 24,
    ),
    _ReviewItemData(
      id: 'rev_2',
      studentName: 'Lê Hoàng Nam',
      studentAvatar: 'N',
      rating: 5,
      date: '5 ngày trước',
      courseName: 'Product Design Masterclass',
      comment:
          'Khóa học vượt quá kỳ vọng của mình. Lượng kiến thức thực chiến dày dặn, các tài liệu đính kèm và template design system dùng được ngay cho công việc.',
      helpfulCount: 18,
    ),
    _ReviewItemData(
      id: 'rev_3',
      studentName: 'Phạm Minh Anh',
      studentAvatar: 'A',
      rating: 4,
      date: '1 tuần trước',
      courseName: 'Design Thinking for UX',
      comment:
          'Nội dung rất hay và logic. Phần bài tập tình huống thực tế khá thử thách nhưng giúp hiểu sâu bài học hơn. Mong thầy ra thêm các buổi workshop giải đáp trực tuyến.',
      helpfulCount: 12,
    ),
    _ReviewItemData(
      id: 'rev_4',
      studentName: 'Vũ Đức Trọng',
      studentAvatar: 'T',
      rating: 5,
      date: '2 tuần trước',
      courseName: 'UI/UX Design Fundamentals',
      comment:
          'Giảng viên phản hồi thắc mắc ở phần hỏi đáp rất nhanh và chi tiết. Rất khuyến khích các bạn mới bắt đầu học theo lộ trình của thầy.',
      helpfulCount: 9,
    ),
    _ReviewItemData(
      id: 'rev_5',
      studentName: 'Nguyễn Thảo My',
      studentAvatar: 'M',
      rating: 4,
      date: '3 tuần trước',
      courseName: 'User Research Methods',
      comment:
          'Phương pháp nghiên cứu người dùng được hệ thống hóa rõ ràng, dễ áp dụng vào dự án thực tế.',
      helpfulCount: 5,
    ),
  ];

  List<_ReviewItemData> get _filteredReviews {
    if (_selectedRatingFilter == 0) return _reviews;
    return _reviews.where((r) => r.rating == _selectedRatingFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Đánh giá từ học viên'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Rating breakdown header card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: _buildRatingSummary(cs, tt),
            ),
          ),

          // Rating filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                children: [
                  _buildFilterChip('Tất cả (1,248)', 0, cs),
                  AppSpacing.hGap8,
                  _buildFilterChip('5 Sao (1,050)', 5, cs),
                  AppSpacing.hGap8,
                  _buildFilterChip('4 Sao (145)', 4, cs),
                  AppSpacing.hGap8,
                  _buildFilterChip('3 Sao (35)', 3, cs),
                  AppSpacing.hGap8,
                  _buildFilterChip('2 Sao (12)', 2, cs),
                  AppSpacing.hGap8,
                  _buildFilterChip('1 Sao (6)', 1, cs),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: AppSpacing.vGap16),

          // Reviews list
          if (_filteredReviews.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                      AppSpacing.vGap12,
                      Text(
                        'Chưa có đánh giá nào cho bộ lọc này',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                32,
              ),
              sliver: SliverList.separated(
                itemCount: _filteredReviews.length,
                separatorBuilder: (_, _) => AppSpacing.vGap12,
                itemBuilder: (context, index) {
                  final review = _filteredReviews[index];
                  return _buildReviewCard(review, cs, tt);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int filterValue, ColorScheme cs) {
    final isSelected = _selectedRatingFilter == filterValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) =>
          setState(() => _selectedRatingFilter = filterValue),
      selectedColor: cs.primary,
      backgroundColor: cs.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isSelected ? cs.onPrimary : cs.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    );
  }

  Widget _buildRatingSummary(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Left side: score
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '4.8',
                style: tt.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.slate900,
                  fontSize: 42,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                ),
              ),
              AppSpacing.vGap4,
              Text(
                '1,248 đánh giá',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              width: 1,
              height: 80,
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
          ),

          // Right side: breakdown bars
          Expanded(
            child: Column(
              children: [
                _buildBarRow('5★', 0.85, cs),
                _buildBarRow('4★', 0.10, cs),
                _buildBarRow('3★', 0.03, cs),
                _buildBarRow('2★', 0.01, cs),
                _buildBarRow('1★', 0.01, cs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarRow(String star, double ratio, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              star,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: cs.outlineVariant.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${(ratio * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    _ReviewItemData review,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Student info & rating
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.studentAvatar,
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      review.date,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGap8,

          // Course tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Text(
              review.courseName,
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AppSpacing.vGap8,

          // Comment
          Text(
            review.comment,
            style: tt.bodyMedium?.copyWith(
              color: cs.slate900,
              height: 1.45,
            ),
          ),
          AppSpacing.vGap8,

          // Helpful button
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                setState(() {
                  review.isHelpful = !review.isHelpful;
                  review.helpfulCount += review.isHelpful ? 1 : -1;
                });
              },
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      review.isHelpful
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_outlined,
                      size: 14,
                      color: review.isHelpful ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hữu ích (${review.helpfulCount})',
                      style: TextStyle(
                        fontSize: 12,
                        color: review.isHelpful
                            ? cs.primary
                            : cs.onSurfaceVariant,
                        fontWeight: review.isHelpful
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
