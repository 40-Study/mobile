import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/home/parent_home_bloc.dart';
import 'package:study/features/parent/bloc/home/parent_home_event.dart';
import 'package:study/features/parent/bloc/home/parent_home_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/home/widgets/widgets.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/theme/theme.dart';

/// Trang chủ Phụ huynh - dashboard giám sát học tập của con.
class ParentHomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ParentHomeBloc(diContainer<ParentHomeRepository>())
            ..add(const ParentHomeStarted()),
      child: _HomeContent(
        onNavigateToProfile: onNavigateToProfile,
        onNavigateToSchedule: onNavigateToSchedule,
        onNavigateToLearning: onNavigateToLearning,
      ),
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
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
              ParentHomeSuccess(:final data, :final selectedChildId) =>
                _HomeSuccess(
                  data: data,
                  selectedChildId: selectedChildId,
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
    required this.data,
    required this.selectedChildId,
    required this.onChildSelected,
    required this.onRefresh,
    this.onNavigateToProfile,
    this.onNavigateToSchedule,
    this.onNavigateToLearning,
  });

  final ParentHomeData data;
  final String? selectedChildId;
  final ValueChanged<String?> onChildSelected;
  final Future<void> Function() onRefresh;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToLearning;

  @override
  Widget build(BuildContext context) {
    final hasChildren = data.children.isNotEmpty;

    if (!hasChildren) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            ParentHomeHeader(
              titleOverride: 'Trang chủ Phụ huynh',
              onNotificationTap: () => _openNotifications(context),
              onAvatarTap: onNavigateToProfile,
            ),
            AppSpacing.vGap12,
            ParentNoChildView(onLinkChild: () => _openManageChildren(context)),
          ],
        ),
      );
    }

    final alerts = data.alerts;
    final schedules = data.schedules;
    final analytics = data.analytics;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          ParentHomeHeader(
            onNotificationTap: () => _openNotifications(context),
            onAvatarTap: onNavigateToProfile,
          ),
          AppSpacing.vGap8,
          FamilyScopeSelector(
            children: data.children,
            selectedChildId: selectedChildId,
            onSelected: onChildSelected,
            onLinkChild: () => _openManageChildren(context),
          ),
          AppSpacing.vGap16,
          ActionRequiredSection(
            alerts: alerts,
            childrenNames: _childrenNamesText(),
          ),
          AppSpacing.vGap16,
          UpcomingScheduleSection(
            schedules: schedules,
            onViewFullSchedule: onNavigateToSchedule,
          ),
          AppSpacing.vGap16,
          LearningAnalyticsCard(
            analytics: analytics,
            onViewLearning: onNavigateToLearning,
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
    final children = data.children;
    if (children.isEmpty) return 'các con';
    if (selectedChildId != null) {
      for (final c in children) {
        if (c.id == selectedChildId) return c.name;
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
