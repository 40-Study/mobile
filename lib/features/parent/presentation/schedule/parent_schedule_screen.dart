import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_bloc.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_event.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_state.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/home/widgets/family_scope_selector.dart';
import 'package:study/features/parent/presentation/home/widgets/parent_no_child_view.dart';
import 'package:study/features/parent/presentation/schedule/widgets/date_group_header.dart';
import 'package:study/features/parent/presentation/schedule/widgets/schedule_segmented_control.dart';
import 'package:study/features/parent/presentation/schedule/widgets/week_calendar_card.dart';
import 'package:study/features/parent/presentation/widgets/parent_schedule_card.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';
import 'package:study/features/parent/repository/parent_schedule_repository_impl.dart';
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
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

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

            return _ScheduleContent(surfaceBg: surfaceBg);
          },
        ),
      ),
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  const _ScheduleContent({required this.surfaceBg});

  final Color surfaceBg;

  void _openManageChildren(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManageChildrenScreen(),
      ),
    );
  }

  void _showSessionDetails(
    BuildContext context,
    ParentScheduleSession session,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionDetailSheet(session: session),
    );
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
              // 1. Header trên nền trắng tinh khiết
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LỊCH HỌC',
                            style: tt.headlineSmall?.copyWith(
                              color: cs.slate900,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Theo dõi thời khóa biểu và ca học của con.',
                            style: tt.bodySmall?.copyWith(
                              color: cs.slate500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: cs.blue600,
                        size: 22,
                      ),
                    ),
                  ],
                ),
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

/// Modal xem chi tiết buổi học (chỉ xem, tuyệt đối không có nút vào học).
class _SessionDetailSheet extends StatelessWidget {
  const _SessionDetailSheet({required this.session});

  final ParentScheduleSession session;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.slate300,
                borderRadius: AppRadius.borderFull,
              ),
            ),
          ),
          // Tiêu đề & Nút đóng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHI TIẾT BUỔI HỌC',
                style: tt.labelLarge?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const Divider(height: 20),
          // Header con + môn học
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: session.childBadgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  session.childInitial,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: cs.slate800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${session.childName} — ${session.subjectName}',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.slate900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Giờ học to rõ
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: cs.blue600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  session.timeRangeText,
                  style: tt.titleMedium?.copyWith(
                    color: cs.blue700,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  session.statusLabel,
                  style: tt.labelMedium?.copyWith(
                    color: cs.blue700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Khối nội dung bài học
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NỘI DUNG BÀI HỌC',
                  style: tt.labelSmall?.copyWith(
                    color: cs.slate500,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.lessonTopic.isNotEmpty
                      ? session.lessonTopic
                      : 'Chưa cập nhật nội dung bài học',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Giáo viên & Phòng học
          Row(
            children: [
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Giáo viên',
                  value: session.instructorName,
                  cs: cs,
                  tt: tt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDetailTile(
                  icon: Icons.meeting_room_outlined,
                  label: 'Hình thức / Phòng',
                  value: session.roomOrPlatform ?? 'Trực tuyến',
                  cs: cs,
                  tt: tt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Thông báo lưu ý cho phụ huynh (giữ đúng vai trò quan sát)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phụ huynh lưu ý nhắc con chuẩn bị tài liệu trước giờ học.',
                    style: tt.bodySmall?.copyWith(
                      color: const Color(0xFF92400E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nút đóng
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: cs.slate900,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: cs.slate500),
              const SizedBox(width: 4),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.slate500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: tt.bodySmall?.copyWith(
              color: cs.slate800,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
