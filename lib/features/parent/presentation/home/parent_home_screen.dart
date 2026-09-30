import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/home/parent_home_bloc.dart';
import 'package:study/features/parent/bloc/home/parent_home_event.dart';
import 'package:study/features/parent/bloc/home/parent_home_state.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/home/widgets/widgets.dart';
import 'package:study/features/parent/presentation/insights_inbox/family_insights_inbox_screen.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/theme/theme.dart';

/// Trang chủ Phụ huynh - dashboard giám sát học tập của con.
class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({
    super.key,
    this.onNavigateToProfile,
    this.onNavigateToSchedule,
    this.onNavigateToLearning,
  });

  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToLearning;

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ParentHomeBloc>().add(const ParentHomeStarted());
  }

  @override
  Widget build(BuildContext context) {
    return _HomeContent(
      onNavigateToProfile: widget.onNavigateToProfile,
      onNavigateToSchedule: widget.onNavigateToSchedule,
      onNavigateToLearning: widget.onNavigateToLearning,
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    this.onNavigateToProfile,
    this.onNavigateToSchedule,
    this.onNavigateToLearning,
  });

  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToLearning;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentHomeBloc, ParentHomeState>(
      builder: (context, state) {
        final cs = Theme.of(context).colorScheme;
        final surfaceBg = Color.alphaBlend(
          cs.primary.withValues(
            alpha: Theme.of(context).brightness == Brightness.light
                ? 0.045
                : 0.065,
          ),
          cs.surfaceContainer,
        );

        return Scaffold(
          backgroundColor: surfaceBg,
          body: SafeArea(
            child: switch (state) {
              ParentHomeInitial() ||
              ParentHomeLoading() => const _HomeLoading(),
              ParentHomeFailure(:final message) => _HomeError(
                message: message,
                onRetry: () => context.read<ParentHomeBloc>().add(
                  const ParentHomeRefreshed(),
                ),
              ),
              final ParentHomeSuccess successState => _HomeSuccess(
                  state: successState,
                  surfaceBg: surfaceBg,
                  onNavigateToProfile: onNavigateToProfile,
                  onNavigateToSchedule: onNavigateToSchedule,
                  onNavigateToLearning: onNavigateToLearning,
                  onChildSelected: (id) => context.read<ParentHomeBloc>().add(
                    ParentHomeChildSelected(id),
                  ),
                  onRefresh: () async {
                    final bloc = context.read<ParentHomeBloc>()
                      ..add(const ParentHomeRefreshed());
                    await bloc.stream.firstWhere(
                      (s) => s is ParentHomeSuccess || s is ParentHomeFailure,
                    );
                  },
                  onRetryAlerts: () => context.read<ParentHomeBloc>().add(
                    const ParentHomeSectionRetried(ParentHomeSection.alerts),
                  ),
                  onRetrySchedules: () => context.read<ParentHomeBloc>().add(
                    const ParentHomeSectionRetried(ParentHomeSection.schedules),
                  ),
                  onRetryAnalytics: () => context.read<ParentHomeBloc>().add(
                    const ParentHomeSectionRetried(ParentHomeSection.analytics),
                  ),
                ),
            },
          ),
        );
      },
    );
  }
}

class _HomeSuccess extends StatelessWidget {
  const _HomeSuccess({
    required this.state,
    required this.surfaceBg,
    required this.onChildSelected,
    required this.onRefresh,
    required this.onRetryAlerts,
    required this.onRetrySchedules,
    required this.onRetryAnalytics,
    this.onNavigateToProfile,
    this.onNavigateToSchedule,
    this.onNavigateToLearning,
  });

  final ParentHomeSuccess state;
  final Color surfaceBg;
  final ValueChanged<String?> onChildSelected;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetryAlerts;
  final VoidCallback onRetrySchedules;
  final VoidCallback onRetryAnalytics;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToLearning;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasChildren = state.children.isNotEmpty;

    if (!hasChildren) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Colors.white,
              child: ParentHomeHeader(
                titleOverride: 'Trang chủ Phụ huynh',
                onNotificationTap: () => _openNotifications(context),
                onAvatarTap: onNavigateToProfile,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: cs.primary.withValues(alpha: 0.08)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                24,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: ParentNoChildView(
                onLinkChild: () => _openManageChildren(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          // 1. Header trên nền trắng tinh khiết (cuộn trôi theo trang)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ParentHomeHeader(
                onNotificationTap: () => _openNotifications(context),
                onAvatarTap: onNavigateToProfile,
              ),
            ),
          ),

          // 2. GHIM THANH CHỌN CON (Sticky Header đồng bộ)
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
                  onSelected: onChildSelected,
                  onLinkChild: () => _openManageChildren(context),
                ),
              ),
            ),
          ),

          // 3. Khối nội dung chính
          SliverToBoxAdapter(
            child: Container(
              color: surfaceBg,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  ActionRequiredSection(
                    alerts: state.alerts,
                    children: state.children,
                    selectedChildId: state.selectedChildId,
                    status: state.alertsStatus,
                    errorMessage: state.alertsErrorMessage,
                    onRetry: onRetryAlerts,
                    childrenNames: _childrenNamesText(),
                  ),
                  const SizedBox(height: 20),
                  UpcomingScheduleSection(
                    schedules: state.schedules,
                    children: state.children,
                    selectedChildId: state.selectedChildId,
                    status: state.schedulesStatus,
                    errorMessage: state.schedulesErrorMessage,
                    onRetry: onRetrySchedules,
                    onViewFullSchedule: onNavigateToSchedule,
                  ),
                  const SizedBox(height: 20),
                  LearningAnalyticsCard(
                    analytics: state.analytics,
                    analyticsList: state.analyticsList,
                    selectedChildId: state.selectedChildId,
                    status: state.analyticsStatus,
                    errorMessage: state.analyticsErrorMessage,
                    onRetry: onRetryAnalytics,
                    onViewLearning: onNavigateToLearning,
                    onViewDetailForChild: (childId) =>
                        FamilyInsightsInboxScreen.open(
                      context,
                      initialChildId: childId,
                    ),
                    onViewAllReports: () =>
                        FamilyInsightsInboxScreen.open(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
    );
  }

  void _openManageChildren(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ManageChildrenScreen()),
    );
  }

  // Tên con để render câu giải thích empty state, VD "Minh & Lan" / "các con".
  String _childrenNamesText() {
    final children = state.children;
    if (children.isEmpty) return 'các con';
    if (state.selectedChildId != null) {
      for (final c in children) {
        if (c.id == state.selectedChildId) return c.name;
      }
      return children.first.name;
    }
    return children.map((c) => c.name).join(' & ');
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            height: 96,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.slate100,
              borderRadius: AppRadius.borderLg,
            ),
          ),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            AppSpacing.vGap16,
            Text(
              'Không thể tải dữ liệu',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap8,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
