import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/data/models/parent_session_detail_model.dart';
import 'package:study/features/parent/presentation/schedule/widgets/widgets.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Chi tiết ca học dành cho Phụ huynh.
/// Tuân thủ: Locked Child Context, View-only, Back navigation, Real data.
class ParentSessionDetailScreen extends StatefulWidget {
  const ParentSessionDetailScreen({
    super.key,
    required this.session,
    this.child,
  });

  final ParentScheduleSession session;
  final FamilyScopeChild? child;

  static Future<void> open(
    BuildContext context, {
    required ParentScheduleSession session,
    FamilyScopeChild? child,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ParentSessionDetailScreen(session: session, child: child),
      ),
    );
  }

  @override
  State<ParentSessionDetailScreen> createState() => _ParentSessionDetailScreenState();
}

class _ParentSessionDetailScreenState extends State<ParentSessionDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ParentSessionDetail _detail;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _detail = ParentSessionDetail.fromSession(widget.session, child: widget.child);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _detail.isCompleted ? 1 : 0,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surfaceBg = Color.alphaBlend(
      cs.primary.withValues(alpha: Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065),
      cs.surfaceContainer,
    );

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: _buildAppBar(context, cs),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverviewTab(cs), _buildAnalysisTab(cs)],
      ),
      bottomNavigationBar: SessionDetailBottomBar(
        isCompleted: _detail.isCompleted,
        onTeacherChat: () => _openTeacherChatSheet(context),
        onReminder: () => _showReminderActionSheet(context),
        onAbsenceRequest: () => _openAbsenceRequestSheet(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final isDone = _detail.isCompleted;
    final lessonTitle = _detail.session.lessonTopic.isNotEmpty
        ? _detail.session.lessonTopic
        : _detail.session.subjectName;
    final dateStr = _formatDayOfWeekAndDate(_detail.session.startTime);

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.slate800, size: 20),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Quay lại',
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bài học: $lessonTitle · ${_detail.session.childName}',
            style: tt.titleMedium?.copyWith(color: cs.slate900, fontWeight: FontWeight.w700, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            '${_detail.studentMajor ?? _detail.session.subjectName} · $dateStr',
            style: tt.labelSmall?.copyWith(color: cs.slate500, fontSize: 11.5, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: cs.slate700, size: 22),
          onSelected: (val) => _handleMenuAction(context, val),
          itemBuilder: (ctx) => [
            _buildMenuItem('calendar', Icons.event_note_outlined, 'Thêm vào lịch'),
            _buildMenuItem('share', Icons.share_outlined, 'Chia sẻ buổi học'),
            _buildMenuItem('lesson', Icons.menu_book_outlined, 'Chi tiết giáo trình'),
            if (isDone) _buildMenuItem('feedback', Icons.star_outline_rounded, 'Đánh giá buổi học'),
            _buildMenuItem('report', Icons.flag_outlined, 'Báo cáo thắc mắc'),
          ],
        ),
        const SizedBox(width: 4),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: cs.primary,
        unselectedLabelColor: cs.slate500,
        indicatorColor: cs.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5),
        tabs: [
          const Tab(text: 'Tổng quan'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Kết quả & nhận xét'),
                if (isDone) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)]),
    );
  }

  Widget _buildOverviewTab(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SessionChildIdentityCard(detail: _detail),
          const SizedBox(height: 12),
          if (_detail.hasRescheduleInfo) ...[
            SessionRescheduleBanner(detail: _detail),
            const SizedBox(height: 12),
          ],
          SessionHeroCard(detail: _detail, onTeacherChatTap: () => _openTeacherChatSheet(context)),
          const SizedBox(height: 16),
          if (_detail.isCompleted) ...[
            SessionPreparationSection(detail: _detail, onDownloadMaterial: _handleDownloadMaterial),
            const SizedBox(height: 16),
            SessionRecordingVideoSection(detail: _detail),
            const SizedBox(height: 16),
          ] else ...[
            SessionPreparationSection(detail: _detail, onDownloadMaterial: _handleDownloadMaterial),
            const SizedBox(height: 16),
            SessionParentGuidanceCard(detail: _detail),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(ColorScheme cs) {
    if (!_detail.isCompleted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: AppSpacing.paddingLg,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: Icon(Icons.access_time_rounded, size: 36, color: cs.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Buổi học chưa diễn ra',
                style: TextStyle(color: cs.slate900, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Kết quả bài tập trên lớp và nhận xét của giáo viên sẽ hiển thị sau khi buổi học kết thúc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.slate500, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SessionQuizResultCard(detail: _detail, onViewDetailsTap: () => showQuizAnswersSheet(context)),
          const SizedBox(height: 14),
          SessionTeacherFeedbackCard(detail: _detail),
          const SizedBox(height: 14),
          SessionHomeworkNextStepCard(detail: _detail, onInsightsTap: _handleInsightsTap),
        ],
      ),
    );
  }

  // =========================================================================
  // ACTIONS
  // =========================================================================

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'calendar':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ca học (${_detail.session.timeRangeText}) vào lịch.'),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case 'share':
        showShareSessionSheet(
          context,
          childName: _detail.session.childName,
          subjectName: _detail.session.subjectName,
          timeRangeText: _detail.session.timeRangeText,
          startTime: _detail.session.startTime,
          roomOrPlatform: _detail.session.roomOrPlatform,
          instructorName: _detail.session.instructorName,
        );
      case 'lesson':
        if (_detail.lessonId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mở giáo trình: ${_detail.session.lessonTopic}'), behavior: SnackBarBehavior.floating),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chưa có thông tin giáo trình chi tiết cho buổi học này.'), behavior: SnackBarBehavior.floating),
          );
        }
      case 'feedback':
        _openFeedbackSheet(context);
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi thông tin thắc mắc tới ban quản trị lớp học.'), behavior: SnackBarBehavior.floating),
        );
    }
  }

  void _handleDownloadMaterial(SessionMaterial mat) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang tải xuống: ${mat.fileName} (${mat.fileSize})'), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleInsightsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang chuyển sang màn hình Báo cáo phân tích chuyên sâu (Insights)...'), behavior: SnackBarBehavior.floating),
    );
  }

  void _openAbsenceRequestSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AbsenceRequestBottomSheet(
        childName: _detail.session.childName,
        sessionTime: _detail.session.timeRangeText,
      ),
    );
  }

  void _openTeacherChatSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => TeacherChatBottomSheet(
        teacher: _detail.teacherInfo ?? TeacherDetailInfo(fullName: _detail.session.instructorName),
      ),
    );
  }

  void _openFeedbackSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SessionFeedbackBottomSheet(
        subjectName: _detail.session.subjectName,
        instructorName: _detail.session.instructorName,
      ),
    );
  }

  void _showReminderActionSheet(BuildContext context) {
    showReminderActionSheet(
      context,
      childName: _detail.session.childName,
      homeworkTitle: _detail.completedAnalysis?.homeworkTitle,
    );
  }

  String _formatDayOfWeekAndDate(DateTime date) {
    const weekdays = ['', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    final wd = weekdays[date.weekday];
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$wd, $d/$m';
  }
}
