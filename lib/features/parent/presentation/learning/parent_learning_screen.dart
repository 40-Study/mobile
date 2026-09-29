import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_bloc.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_event.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_state.dart';
import 'package:study/features/parent/data/models/parent_learning_hub_data.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/learning/class_detail/parent_class_detail_screen.dart';
import 'package:study/features/parent/presentation/learning/insights/parent_learning_insights_screen.dart';
import 'package:study/features/parent/presentation/learning/recommended_courses/parent_recommended_courses_screen.dart';
import 'package:study/features/parent/presentation/learning/widgets/learning_hub_header.dart';
import 'package:study/features/parent/presentation/learning/widgets/learning_hub_navigation_card.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';
import 'package:study/theme/theme.dart';

/// Màn hình chính của Tab Học tập dành cho Phụ huynh (Learning Root Hub).
///
/// Phân hệ điều hướng trung tâm dẫn vào 5 khối chức năng cốt lõi:
/// 1. Insights / Phân tích (Báo cáo sư phạm 3 bước, xu hướng học tập)
/// 2. Lớp học (Tiến độ lớp, giáo viên, lộ trình buổi học)
/// 3. Bài tập về nhà (Danh sách bài tập nộp đúng hạn, cảnh báo quá hạn)
/// 4. Tiến độ khóa học (% hoàn thành học phần theo thời gian)
/// 5. Gợi ý cho con (Khóa học và chuyên đề bổ trợ cá nhân hoá do AI đề xuất)
class ParentLearningScreen extends StatelessWidget {
  const ParentLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentLearningBloc(
        diContainer.isRegistered<ParentLearningRepository>()
            ? diContainer<ParentLearningRepository>()
            : ParentLearningRepositoryImpl(),
      )..add(const ParentLearningStarted()),
      child: const _LearningView(),
    );
  }
}

class _LearningView extends StatelessWidget {
  const _LearningView();

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
      body: SafeArea(
        child: BlocBuilder<ParentLearningBloc, ParentLearningState>(
          builder: (context, state) {
            if (state.isLoading && state.children.isEmpty) {
              return const _LearningLoading();
            }

            if (state.isFailure && state.children.isEmpty) {
              return _LearningError(
                message: state.errorMessage ?? 'Không thể tải dữ liệu học tập',
                onRetry: () => context.read<ParentLearningBloc>().add(
                      const ParentLearningRefreshed(),
                    ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<ParentLearningBloc>()
                    .add(const ParentLearningRefreshed());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Header trên nền trắng
                  const SliverToBoxAdapter(
                    child: LearningHubHeader(),
                  ),

                  // 2. GHIM THANH CHỌN CON (Sticky Pinned Header)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: PinnedFamilyScopeHeaderDelegate(
                      backgroundColor: surfaceBg,
                      height: 64,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: FamilyScopeSelector(
                          children: state.children,
                          selectedChildId: state.selectedChildId,
                          showAllOption: false,
                          compactEmpty: true,
                          onSelected: (childId) {
                            if (childId != null) {
                              context.read<ParentLearningBloc>().add(
                                    ParentLearningChildSelected(childId),
                                  );
                            }
                          },
                          onLinkChild: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ManageChildrenScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 3. Nội dung 5 Navigation Cards (cho con đang chọn)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                      child: _buildSingleChildSections(
                        context,
                        state.hubData ??
                            ParentLearningHubData(
                              childId: state.selectedChildId ?? '',
                              childName:
                                  state.activeChild?.name ?? 'Con',
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Hiển thị 5 thẻ điều hướng cho một con cụ thể
  Widget _buildSingleChildSections(
    BuildContext context,
    ParentLearningHubData data,
  ) {
    return Column(
      children: [
        // Card 1: Insights / Phân tích
        LearningHubNavigationCard(
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
          title: 'Insights / Phân tích',
          subtitle: 'Xu hướng học tập, năng lực & điểm nổi bật',
          extraContent: data.newInsightsCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${data.newInsightsCount} nhận xét mới tuần này',
                        style: const TextStyle(
                          color: Color(0xFF15803D),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          onTap: () => _openLearningInsights(context, data),
        ),
        const SizedBox(height: 14),

        // Card 2: Lớp học
        LearningHubNavigationCard(
          icon: Icons.menu_book_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBgColor: const Color(0xFFE0F2FE),
          title: 'Lớp học',
          inlineBadgeText: '${data.activeClassCount} lớp đang học',
          inlineBadgeBgColor: const Color(0xFFE0F2FE),
          inlineBadgeTextColor: const Color(0xFF0369A1),
          subtitle: '${data.activeClassCount} lớp đang tham gia học tập',
          extraContent: data.activeClassNames.isNotEmpty
              ? Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0284C7),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        data.activeClassNames.join(', '),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : null,
          onTap: () => _openClassDetail(context, data),
        ),
        const SizedBox(height: 14),

        // Card 3: Bài tập về nhà
        LearningHubNavigationCard(
          icon: Icons.assignment_outlined,
          iconColor: const Color(0xFFD97706),
          iconBgColor: const Color(0xFFFFFBEB),
          title: 'Bài tập về nhà',
          subtitle: '${data.pendingHomeworkCount} bài cần chú ý nộp đúng hạn',
          extraContent: data.overdueHomeworkCount > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${data.overdueHomeworkCount} bài sắp quá hạn',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          onTap: () => _openHomeworkList(context, data),
        ),
        const SizedBox(height: 14),

        // Card 4: Tiến độ khóa học
        LearningHubNavigationCard(
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFF7C3AED),
          iconBgColor: const Color(0xFFF5F3FF),
          title: 'Tiến độ khóa học',
          subtitle: 'Đã hoàn thành '
              '${(data.courseProgressPercent * 100).toInt()}% '
              'khối lượng học phần',
          extraContent: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: data.courseProgressPercent,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(data.courseProgressPercent * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          onTap: () => _openProgressOverview(context, data),
        ),
        const SizedBox(height: 14),

        // Card 5: Gợi ý cho con
        LearningHubNavigationCard(
          icon: Icons.auto_awesome_rounded,
          iconColor: const Color(0xFFDB2777),
          iconBgColor: const Color(0xFFFDF2F8),
          title: 'Gợi ý cho ${data.childName}',
          inlineBadgeText: 'AI đề xuất',
          inlineBadgeBgColor: const Color(0xFFFCE7F3),
          inlineBadgeTextColor: const Color(0xFFBE185D),
          subtitle:
              data.recommendedTopic ?? 'Chuyên đề bổ trợ phát triển năng lực',
          onTap: () => _openRecommendedCourses(context, data),
        ),
      ],
    );
  }

  // ===================== NAVIGATION HELPERS =====================

  void _openLearningInsights(BuildContext context, ParentLearningHubData data) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ParentLearningInsightsScreen(
          childId: data.childId,
          childName: data.childName,
          onNavigateToRecommendations: () {
            Navigator.pop(context);
            _openRecommendedCourses(context, data);
          },
        ),
      ),
    );
  }

  void _openClassDetail(BuildContext context, ParentLearningHubData data) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ParentClassDetailScreen(
          childId: data.childId,
          childName: data.childName,
        ),
      ),
    );
  }

  void _openHomeworkList(BuildContext context, ParentLearningHubData data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mở Bài tập về nhà của ${data.childName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openProgressOverview(
      BuildContext context, ParentLearningHubData data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mở Tiến độ học tập của ${data.childName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openRecommendedCourses(
      BuildContext context, ParentLearningHubData data) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ParentRecommendedCoursesScreen(
          childId: data.childId,
          childName: data.childName,
          className: data.className ?? '10A1',
        ),
      ),
    );
  }
}

class _LearningLoading extends StatelessWidget {
  const _LearningLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _LearningError extends StatelessWidget {
  const _LearningError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
