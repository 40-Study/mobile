import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/insights_inbox/family_insights_inbox_bloc.dart';
import 'package:study/features/parent/bloc/insights_inbox/family_insights_inbox_event.dart';
import 'package:study/features/parent/bloc/insights_inbox/family_insights_inbox_state.dart';
import 'package:study/features/parent/presentation/insights_inbox/widgets/widgets.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/features/parent/repository/family_insights_repository.dart';
import 'package:study/features/parent/repository/family_insights_repository_impl.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Family Insights Inbox - Hộp thư phân tích học tập định kỳ
/// cho mọi con trong gia đình (Family Scope).
/// Hỗ trợ ghim thanh chọn con đồng bộ (Sticky Header) khi cuộn.
class FamilyInsightsInboxScreen extends StatelessWidget {
  const FamilyInsightsInboxScreen({super.key, this.initialChildId});

  final String? initialChildId;

  /// Phương thức mở màn hình thuận tiện
  static Future<void> open(BuildContext context, {String? initialChildId}) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FamilyInsightsInboxScreen(
          initialChildId: initialChildId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final insightsRepo =
            diContainer.isRegistered<FamilyInsightsRepository>()
                ? diContainer<FamilyInsightsRepository>()
                : FamilyInsightsRepositoryImpl();
        final homeRepo = diContainer<ParentHomeRepository>();

        return FamilyInsightsInboxBloc(
          insightsRepository: insightsRepo,
          homeRepository: homeRepo,
        )..add(FamilyInsightsInboxStarted(initialChildId: initialChildId));
      },
      child: const _FamilyInsightsInboxContent(),
    );
  }
}


class _FamilyInsightsInboxContent extends StatelessWidget {
  const _FamilyInsightsInboxContent();

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
      body: SafeArea(
        child: BlocConsumer<FamilyInsightsInboxBloc, FamilyInsightsInboxState>(
          listener: (context, state) {},
          builder: (context, state) {
            return switch (state) {
              FamilyInsightsInboxInitial() ||
              FamilyInsightsInboxLoading() =>
                _buildLoadingState(context),
              FamilyInsightsInboxFailure(:final message) =>
                _buildErrorState(context, message),
              FamilyInsightsInboxSuccess() =>
                _buildSuccessState(context, state, surfaceBg),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        InsightsInboxAppBar(
          totalChildrenCount: 2,
          unreadCount: 0,
          onBack: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),
        const InsightsInboxSkeleton(),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            AppSpacing.vGap12,
            Text(
              'Không thể tải phân tích học tập',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.vGap8,
            Text(
              message,
              style: tt.bodySmall?.copyWith(color: cs.slate500),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: () => context
                  .read<FamilyInsightsInboxBloc>()
                  .add(const FamilyInsightsInboxRefreshed()),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    FamilyInsightsInboxSuccess state,
    Color surfaceBg,
  ) {
    final bloc = context.read<FamilyInsightsInboxBloc>();

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(const FamilyInsightsInboxRefreshed());
        await bloc.stream.firstWhere(
          (s) =>
              s is FamilyInsightsInboxSuccess ||
              s is FamilyInsightsInboxFailure,
        );
      },
      child: CustomScrollView(
        slivers: [
          // 1. Header trên nền trắng (cuộn trôi theo trang)
          SliverToBoxAdapter(
            child: InsightsInboxAppBar(
              totalChildrenCount: state.children.length,
              unreadCount: state.unreadCount,
              onBack: () => Navigator.pop(context),
            ),
          ),


          // 2. GHIM THANH CHỌN CON (Sticky Header đồng bộ FamilyScopeSelector)
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedFamilyScopeHeaderDelegate(
              backgroundColor: surfaceBg,
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: FamilyScopeSelector(
                  children: state.children,
                  selectedChildId: state.selectedChildId,
                  onSelected: (childId) {
                    bloc.add(FamilyInsightsInboxChildFilterChanged(childId));
                  },
                ),
              ),
            ),
          ),

          // 3. Nội dung danh sách các thẻ Insight
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Weekly summary banner
                InsightsWeeklySummaryCard(
                  weekNumber: 42,
                  needAttentionCount: 2,
                  positiveMilestoneCount: 1,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang mở chi tiết báo cáo tuần 42...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                if (state.insights.isEmpty)
                  _buildEmptyState(context)
                else
                  for (var i = 0; i < state.insights.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    InsightCardItem(
                      item: state.insights[i],
                      onActionTap: () {
                        final item = state.insights[i];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Mở: ${item.actionLabel ?? item.title}',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onEncourageTap: () {
                        final item = state.insights[i];
                        bloc.add(FamilyInsightsInboxSendEncouraged(item.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF16A34A),
                            content: Text(
                              'Đã gửi lời khen & khích lệ đến '
                              '${item.childName}! 🎉',
                            ),

                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],

                const SizedBox(height: 16),

                // Thẻ gợi ý phương pháp giáo dục ở cuối danh sách
                const InsightsCoachTipCard(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: cs.slate300),
            AppSpacing.vGap12,
            Text(
              'Chưa có phân tích mới cho con',
              style: tt.titleSmall?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vGap8,
            Text(
              'Dữ liệu phân tích học tập sẽ được cập nhật định kỳ '
              'khi có kết quả từ giáo viên hoặc hệ thống.',
              style: tt.bodySmall?.copyWith(color: cs.slate500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
