import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_bloc.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_event.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_state.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/home/widgets/parent_no_child_view.dart';
import 'package:study/features/parent/presentation/schedule/widgets/date_group_header.dart';
import 'package:study/features/parent/presentation/schedule/widgets/schedule_segmented_control.dart';
import 'package:study/features/parent/presentation/schedule/widgets/week_calendar_card.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';
import 'package:study/features/parent/repository/parent_schedule_repository_impl.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Tab Lịch học dành cho Phụ huynh.
///
/// Phụ huynh có thể:
/// - Chọn xem theo từng con hoặc tất cả con
/// - Lọc theo Hôm nay / Tuần này / Tháng này
/// - Tương tác trên dải lịch tuần 7 ngày
/// - Xem danh sách ca học với cấu trúc chuẩn ParentScheduleCard
/// - Mở modal xem chi tiết buổi học (chỉ xem, không vào lớp học)
class ParentScheduleScreen extends StatelessWidget {
  const ParentScheduleScreen({
    super.key,
    this.onNavigateToProfile,
  });

  final VoidCallback? onNavigateToProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParentScheduleBloc(
        diContainer.isRegistered<ParentScheduleRepository>()
            ? diContainer<ParentScheduleRepository>()
            : ParentScheduleRepositoryImpl(),
      )..add(const ParentScheduleStarted()),
      child: _ScheduleView(onNavigateToProfile: onNavigateToProfile),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView({this.onNavigateToProfile});

  final VoidCallback? onNavigateToProfile;

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
        child: BlocBuilder<ParentScheduleBloc, ParentScheduleState>(
          builder: (context, state) {
            if (state.isLoading && state.children.isEmpty) {
              return const _ScheduleLoading();
            }

            if (state.isFailure && state.children.isEmpty) {
              return _ScheduleError(
                message: state.errorMessage ?? 'Không thể tải lịch học',
                onRetry: () => context.read<ParentScheduleBloc>().add(
                      const ParentScheduleRefreshed(),
                    ),
              );
            }

            return _ScheduleContent(
              surfaceBg: surfaceBg,
              onNavigateToProfile: onNavigateToProfile,
            );
          },
        ),
      ),
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  const _ScheduleContent({
    required this.surfaceBg,
    this.onNavigateToProfile,
  });

  final Color surfaceBg;
  final VoidCallback? onNavigateToProfile;

  void _openManageChildren(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManageChildrenScreen(),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

  void _showSessionDetails(
    BuildContext context,
    ParentScheduleSession session,
  ) {
    showParentSessionDetailSheet(context, session: session);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<ParentScheduleBloc, ParentScheduleState>(
      builder: (context, state) {
        final hasChildren = state.children.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<ParentScheduleBloc>()
              ..add(const ParentScheduleRefreshed());
            await bloc.stream.firstWhere(
              (s) => s.isSuccess || s.isFailure,
            );
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 1. Header chuẩn đồng bộ với Trang chủ
              ParentAppHeader(
                icon: Icons.calendar_month_rounded,
                categoryLabel: 'THỜI KHÓA BIỂU',
                title: 'Lịch học của con',
                onNotificationTap: () => _openNotifications(context),
                onAvatarTap: onNavigateToProfile,
              ),

              // 2. Khối Body bo cong 24px trên nền surfaceBg
              Container(
                decoration: BoxDecoration(
                  color: surfaceBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: cs.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 100,
                ),
                child: !hasChildren
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: ParentNoChildView(
                          onLinkChild: () => _openManageChildren(context),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thanh chọn con
                          FamilyScopeSelector(
                            children: state.children,
                            selectedChildId: state.selectedChildId,
                            onSelected: (id) => context
                                .read<ParentScheduleBloc>()
                                .add(ParentScheduleChildChanged(id)),
                            onLinkChild: () => _openManageChildren(context),
                          ),
                          const SizedBox(height: 14),

                          // Bộ chọn tab Hôm nay / Tuần này / Tháng này
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: ScheduleSegmentedControl(
                              selectedTab: state.selectedTab,
                              onTabChanged: (tab) => context
                                  .read<ParentScheduleBloc>()
                                  .add(ParentScheduleTabChanged(tab)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Thẻ dải lịch tuần 7 ngày
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: WeekCalendarCard(
                              anchorWeekDate: state.anchorWeekDate,
                              selectedDate: state.selectedDate,
                              eventDates: state.eventDates,
                              totalSessionsInWeek: state.sessions.length,
                              onDateSelected: (date) => context
                                  .read<ParentScheduleBloc>()
                                  .add(ParentScheduleDateSelected(date)),
                              onWeekChanged: (anchor) => context
                                  .read<ParentScheduleBloc>()
                                  .add(ParentScheduleWeekChanged(anchor)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Danh sách ca học phân nhóm theo ngày
                          _buildSessionsList(context, state, cs, tt),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionsList(
    BuildContext context,
    ParentScheduleState state,
    ColorScheme cs,
    TextTheme tt,
  ) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy_outlined,
                  color: cs.blue600,
                  size: 24,
                ),
              ),
              AppSpacing.vGap12,
              Text(
                'Không có ca học nào',
                style: tt.titleSmall?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppSpacing.vGap4,
              Text(
                'Con không có lịch học trong ngày hoặc tuần được chọn. '
                'Chọn ngày khác trên thanh lịch tuần để xem.',
                style: tt.bodySmall?.copyWith(
                  color: cs.slate500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Nhóm ca học theo ngày
    final grouped = state.sessionsByDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          final date = entry.key;
          final daySessions = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateGroupHeader(
                date: date,
                sessionCount: daySessions.length,
              ),
              const SizedBox(height: 6),
              ...daySessions.map((session) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ParentScheduleCard(
                    session: session,
                    onTap: () => _showSessionDetails(context, session),
                  ),
                );
              }),
              const SizedBox(height: 6),
            ],
          );
        }).toList(),
      ),
    );
  }
}


class _ScheduleLoading extends StatelessWidget {
  const _ScheduleLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );
  }
}

class _ScheduleError extends StatelessWidget {
  const _ScheduleError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            AppSpacing.vGap16,
            Text(
              'Không thể tải lịch học',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap4,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
