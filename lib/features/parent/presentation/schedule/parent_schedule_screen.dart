import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_bloc.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_event.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_state.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/home/widgets/parent_no_child_view.dart';
import 'package:study/features/parent/presentation/schedule/parent_session_detail_screen.dart';
import 'package:study/features/parent/presentation/schedule/widgets/date_group_header.dart';
import 'package:study/features/parent/presentation/schedule/widgets/parent_expandable_calendar.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';
import 'package:study/features/parent/repository/parent_schedule_repository_impl.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Tab Lịch học dành cho Phụ huynh.
///
/// Các tính năng chính:
/// - Header chuẩn đồng bộ với Trang chủ (ParentAppHeader)
/// - Thanh chọn phạm vi con dùng chung (FamilyScopeSelector)
/// - Quyển lịch thông minh (ParentExpandableCalendar) hỗ trợ thu gọn 1 tuần và
///   mở rộng full tháng, multi-color dots theo từng con
/// - Body chỉ hiển thị các ca học của ngày được chọn trên lịch
/// - Khi chọn "Tất cả con": Tự động phân chia thành các Section theo từng con
/// - Xem chi tiết buổi học (ParentSessionDetailSheet) - chỉ xem, không vào học
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
    ParentScheduleSession session, {
    FamilyScopeChild? child,
  }) {
    ParentSessionDetailScreen.open(
      context,
      session: session,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                          // 2.1. Thanh chọn phạm vi con dùng chung
                          FamilyScopeSelector(
                            children: state.children,
                            selectedChildId: state.selectedChildId,
                            onSelected: (id) => context
                                .read<ParentScheduleBloc>()
                                .add(ParentScheduleChildChanged(id)),
                            onLinkChild: () => _openManageChildren(context),
                          ),
                          const SizedBox(height: 16),

                          // 2.2. Quyển lịch thông minh (Thu gọn 1 tuần / Mở rộng full tháng)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: ParentExpandableCalendar(
                              selectedDate: state.selectedDate,
                              currentMonth: state.currentMonth,
                              isExpanded: state.isCalendarExpanded,
                              eventsMap: state.eventsMap,
                              children: state.children,
                              selectedChildId: state.selectedChildId,
                              totalSessionsInWeek: state.totalSessionsInWeek,
                              onDateSelected: (date) => context
                                  .read<ParentScheduleBloc>()
                                  .add(ParentScheduleDateSelected(date)),
                              onMonthChanged: (month) => context
                                  .read<ParentScheduleBloc>()
                                  .add(ParentScheduleMonthChanged(month)),
                              onToggleExpand: () => context
                                  .read<ParentScheduleBloc>()
                                  .add(
                                    const ParentScheduleCalendarModeToggled(),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2.3. Danh sách các ca học của ngày được chọn
                          _buildSelectedDateSessions(context, state, cs),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedDateSessions(
    BuildContext context,
    ParentScheduleState state,
    ColorScheme cs,
  ) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    // Nếu ngày được chọn không có ca học nào
    if (state.sessions.isEmpty) {
      return _buildEmptySessionsCard(context, state.selectedDate, cs);
    }

    // Nếu Phụ huynh đang chọn "Tất cả các con" (selectedChildId == null)
    // -> Phân chia danh sách thành các Section theo từng con
    if (state.selectedChildId == null) {
      return _buildGroupedChildSections(context, state, cs);
    }

    // Nếu đang chọn 1 con cụ thể -> Chỉ hiển thị danh sách của con đó
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateGroupHeader(
            date: state.selectedDate,
            sessionCount: state.sessions.length,
          ),
          const SizedBox(height: 6),
          ...state.sessions.map((session) {
            final child = state.children
                .where((c) => c.id == session.childId)
                .firstOrNull;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ParentScheduleCard(
                session: session,
                onTap: () => _showSessionDetails(
                  context,
                  session,
                  child: child,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Hiển thị các Section ca học theo từng con khi chọn "Tất cả các con"
  Widget _buildGroupedChildSections(
    BuildContext context,
    ParentScheduleState state,
    ColorScheme cs,
  ) {
    final sessionsByChild = state.sessionsByChild;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề ngày tổng quát
          DateGroupHeader(
            date: state.selectedDate,
            sessionCount: state.sessions.length,
          ),
          const SizedBox(height: 8),

          // Duyệt qua từng con để render section riêng
          ...state.children.map((child) {
            final childSessions = sessionsByChild[child.id] ?? [];
            if (childSessions.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChildSectionHeader(
                    context,
                    child,
                    childSessions.length,
                    cs,
                  ),
                  ...childSessions.map((session) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ParentScheduleCard(
                        session: session,
                        onTap: () => _showSessionDetails(
                          context,
                          session,
                          child: child,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Header phân biệt section từng con: Avatar tròn + Tên con + Số lượng ca
  Widget _buildChildSectionHeader(
    BuildContext context,
    FamilyScopeChild child,
    int sessionCount,
    ColorScheme cs,
  ) {
    final tt = Theme.of(context).textTheme;
    final className = child.className != null ? ' · ${child.className}' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: child.badgeColor.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: child.badgeColor,
            child: Text(
              child.initialLetter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'CON: ${child.name.toUpperCase()}$className',
            style: tt.labelSmall?.copyWith(
              color: cs.slate800,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            '$sessionCount ca học',
            style: tt.labelSmall?.copyWith(
              color: cs.slate600,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySessionsCard(
    BuildContext context,
    DateTime date,
    ColorScheme cs,
  ) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        width: double.infinity,
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
                Icons.event_available_outlined,
                color: cs.blue600,
                size: 24,
              ),
            ),
            AppSpacing.vGap12,
            Text(
              'Không có ca học nào trong ngày',
              style: tt.titleSmall?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vGap4,
            Text(
              'Con không có lịch học nào vào ngày ${date.day}/${date.month}. '
              'Thời gian dành cho nghỉ ngơi hoặc tự ôn tập.',
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
