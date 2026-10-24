import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

import 'widgets/category_tabs_header_delegate.dart';

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

class _RatingFilterTab {
  const _RatingFilterTab({
    required this.starValue,
    required this.label,
    required this.count,
  });

  final int starValue; // 0 = Tất cả
  final String label;
  final int count;
}

class _InstructorReviewsScreenState extends State<InstructorReviewsScreen> {
  late final PageController _pageController;
  late final List<GlobalKey> _chipKeys;
  int _selectedTabIndex = 0;

  static const List<_RatingFilterTab> _tabs = [
    _RatingFilterTab(starValue: 0, label: 'Tất cả', count: 1248),
    _RatingFilterTab(starValue: 5, label: '5 Sao', count: 1050),
    _RatingFilterTab(starValue: 4, label: '4 Sao', count: 145),
    _RatingFilterTab(starValue: 3, label: '3 Sao', count: 35),
    _RatingFilterTab(starValue: 2, label: '2 Sao', count: 12),
    _RatingFilterTab(starValue: 1, label: '1 Sao', count: 6),
  ];

  late final List<_ReviewItemData> _reviews = [
    _ReviewItemData(
      id: 'rev_1',
      studentName: 'Trần Thị Bích',
      studentAvatar: 'B',
      rating: 5,
      date: '2 ngày trước',
      courseName: 'UI/UX Design Fundamentals',
      comment:
          'Thầy giảng rất dễ hiểu và tận tâm. Các ví dụ minh họa sát với '
          'thực tế dự án, đặc biệt phần hướng dẫn làm Wireframe và '
          'Prototype bằng Figma cực kỳ chi tiết!',
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
          'Khóa học vượt quá kỳ vọng của mình. Lượng kiến thức thực chiến '
          'dày dặn, các tài liệu đính kèm và template design system '
          'dùng được ngay cho công việc.',
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
          'Nội dung rất hay và logic. Phần bài tập tình huống thực tế khá '
          'thử thách nhưng giúp hiểu sâu bài học hơn. Mong thầy ra thêm các '
          'buổi workshop giải đáp trực tuyến.',
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
          'Giảng viên phản hồi thắc mắc ở phần hỏi đáp rất nhanh và chi '
          'tiết. Rất khuyến khích các bạn mới bắt đầu học theo lộ trình '
          'của thầy.',
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
          'Phương pháp nghiên cứu người dùng được hệ thống hóa rõ ràng, '
          'dễ áp dụng vào dự án thực tế.',
      helpfulCount: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _chipKeys = List.generate(_tabs.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    _scrollToSelectedChip(index);
  }

  void _onPageChanged(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
    _scrollToSelectedChip(index);
  }

  void _scrollToSelectedChip(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _chipKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });
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
        elevation: 0,
        backgroundColor: cs.surface,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Rating breakdown header card (cuộn lên trên tự nhiên)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: _buildRatingSummary(cs, tt),
            ),
          ),

          // Sticky Rating Star Filter Chips (ghim khi cuộn)
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryTabsHeaderDelegate(
              height: 52,
              child: _buildFilterChipsRow(cs),
            ),
          ),
        ],
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: _tabs.length,
          itemBuilder: (context, index) {
            final tab = _tabs[index];
            final filtered = tab.starValue == 0
                ? _reviews
                : _reviews.where((r) => r.rating == tab.starValue).toList();
            return _buildReviewsListForTab(tab, filtered, cs, tt);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow(ColorScheme cs) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 7,
        ),
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => AppSpacing.hGap8,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = index == _selectedTabIndex;

          return KeyedSubtree(
            key: _chipKeys[index],
            child: ChoiceChip(
              label: Text('${tab.label} (${tab.count})'),
              selected: isSelected,
              onSelected: (_) => _onTabTapped(index),
              selectedColor: cs.primary,
              backgroundColor: cs.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: isSelected ? cs.onPrimary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
                side: BorderSide(
                  color: isSelected
                      ? cs.primary
                      : cs.outlineVariant.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsListForTab(
    _RatingFilterTab tab,
    List<_ReviewItemData> reviews,
    ColorScheme cs,
    TextTheme tt,
  ) {
    if (reviews.isEmpty) {
      return _buildEmptyState(tab, cs, tt);
    }

    return ListView.separated(
      key: PageStorageKey<String>('instructor_reviews_tab_${tab.starValue}'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        32,
      ),
      itemCount: reviews.length,
      separatorBuilder: (_, _) => AppSpacing.vGap12,
      itemBuilder: (context, index) {
        return _buildReviewCard(reviews[index], cs, tt);
      },
    );
  }

  Widget _buildEmptyState(_RatingFilterTab tab, ColorScheme cs, TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: 36,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.vGap16,
            Text(
              'Chưa có đánh giá nào',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            AppSpacing.vGap8,
            Text(
              'Hiện tại chưa có đánh giá nào thuộc mức ${tab.label}.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
          color: cs.outlineVariant.withValues(alpha: 0.45),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.symmetric(vertical: 2.5),
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
              borderRadius: BorderRadius.circular(2.5),
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
                fontWeight: FontWeight.w500,
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
          color: cs.outlineVariant.withValues(alpha: 0.45),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author info row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFDBEAFE),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    review.studentAvatar,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
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
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.slate900,
                      ),
                    ),
                    Text(
                      review.date,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
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
                        : Icons.star_border_rounded,
                    color: i < review.rating
                        ? const Color(0xFFF59E0B)
                        : cs.outlineVariant,
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
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.xs),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: Text(
              review.courseName,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
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
          AppSpacing.vGap12,

          // Helpful button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.full),
                onTap: () {
                  setState(() {
                    review.isHelpful = !review.isHelpful;
                    review.helpfulCount += review.isHelpful ? 1 : -1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        review.isHelpful
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_up_outlined,
                        size: 15,
                        color: review.isHelpful
                            ? cs.primary
                            : cs.onSurfaceVariant,
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
            ],
          ),
        ],
      ),
    );
  }
}
