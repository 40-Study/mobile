import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
import 'package:study/features/parent/data/models/parent_session_detail_model.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Chi tiết ca học dành cho Phụ huynh (ParentSessionDetailScreen).
///
/// Tuân thủ nghiêm ngặt nguyên tắc:
/// 1. Khóa ngữ cảnh con (Locked Child Context): AppBar hiển thị tên con.
/// 2. Vai trò Phụ huynh: Chỉ xem thông tin, tuyệt đối KHÔNG có nút vào Meet.
/// 3. Back navigation: Nút Back quay lại màn hình trước và bảo toàn trạng thái.
/// 4. Dữ liệu thật: Hiển thị Empty State trang nhã khi API chưa trả về dữ liệu.
/// 5. Phân tích kết quả: Hiển thị đánh giá giáo viên và bài tập khi đã xong.
class ParentSessionDetailScreen extends StatefulWidget {
  const ParentSessionDetailScreen({
    super.key,
    required this.session,
    this.child,
  });

  final ParentScheduleSession session;
  final FamilyScopeChild? child;

  /// Helper mở màn hình chi tiết ca học từ bất kỳ đâu
  static Future<void> open(
    BuildContext context, {
    required ParentScheduleSession session,
    FamilyScopeChild? child,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ParentSessionDetailScreen(
          session: session,
          child: child,
        ),
      ),
    );
  }

  @override
  State<ParentSessionDetailScreen> createState() =>
      _ParentSessionDetailScreenState();
}

class _ParentSessionDetailScreenState extends State<ParentSessionDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ParentSessionDetail _detail;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo model chi tiết từ session và child truyền vào
    _detail = ParentSessionDetail.fromSession(
      widget.session,
      child: widget.child,
    );
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _detail.isCompleted ? 1 : 0,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
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

    // Tính toán surfaceBg đồng bộ với Trang chủ và Tab Lịch học
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
      appBar: _buildAppBar(context, cs),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(cs),
          _buildAnalysisTab(cs),
        ],
      ),
      // Thanh hành động cố định ở đáy màn hình an toàn với Safe Area
      bottomNavigationBar: _buildStickyBottomActionBar(context, cs),
    );
  }

  /// AppBar chuẩn Locked Child Context với TabBar 2 Tab
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
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: cs.slate800,
          size: 20,
        ),
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
            style: tt.titleMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            '${_detail.studentMajor ?? _detail.session.subjectName} · $dateStr',
            style: tt.labelSmall?.copyWith(
              color: cs.slate500,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: cs.slate700, size: 22),
          onSelected: (val) {
            if (val == 'calendar') _handleAddToCalendar(context);
            if (val == 'share') _handleShareSession(context);
            if (val == 'lesson') _handleOpenLessonDetail(context);
            if (val == 'feedback') _openFeedbackSheet(context);
            if (val == 'report') _handleReportIssue(context);
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'calendar',
              child: Row(
                children: [
                  Icon(Icons.event_note_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Thêm vào lịch'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Chia sẻ buổi học'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'lesson',
              child: Row(
                children: [
                  Icon(Icons.menu_book_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Chi tiết giáo trình'),
                ],
              ),
            ),
            if (isDone)
              const PopupMenuItem(
                value: 'feedback',
                child: Row(
                  children: [
                    Icon(Icons.star_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Đánh giá buổi học'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Báo cáo thắc mắc'),
                ],
              ),
            ),
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
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13.5,
        ),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 1: Tổng quan buổi học (thông tin, chuẩn bị, video bài giảng)
  Widget _buildOverviewTab(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thẻ định danh con (tinh gọn)
          _buildChildIdentityCard(cs),
          const SizedBox(height: 12),

          // 2. Banner cảnh báo đổi lịch hoặc hủy ca học (nếu có)
          if (_detail.hasRescheduleInfo) ...[
            _buildRescheduleBanner(cs),
            const SizedBox(height: 12),
          ],

          // 3. Khối thông tin cốt lõi của ca học (môn, giờ, phòng, giáo viên)
          _buildSessionHeroCard(cs),
          const SizedBox(height: 16),

          // 4. Nếu ca học đã kết thúc -> Hiển thị Tài liệu & Video ghi hình
          if (_detail.isCompleted) ...[
            _buildPreparationSection(cs),
            const SizedBox(height: 16),
            _buildRecordingVideoSection(cs),
            const SizedBox(height: 16),
          ] else ...[
            // Nếu ca học sắp tới -> Hiển thị Chuẩn bị & Lời khuyên đồng hành
            _buildPreparationSection(cs),
            const SizedBox(height: 16),
            _buildParentGuidanceCard(cs),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  /// Tab 2: Kết quả & nhận xét buổi học (Quiz, Nhận xét GV, Bài tập về nhà)
  Widget _buildAnalysisTab(ColorScheme cs) {
    if (!_detail.isCompleted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: 36,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Buổi học chưa diễn ra',
                style: TextStyle(
                  color: cs.slate900,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kết quả bài tập trên lớp và nhận xét của giáo viên '
                'sẽ hiển thị sau khi buổi học kết thúc.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.slate500,
                  fontSize: 13,
                  height: 1.4,
                ),
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
          // 1. Kết quả bài tập trên lớp (Quiz, Điểm, Segment Bar)
          _buildQuizResultCard(cs),
          const SizedBox(height: 14),

          // 2. Đánh giá & nhận xét của giáo viên (Trích dẫn, Tag chuyên cần)
          _buildTeacherFeedbackCard(cs),
          const SizedBox(height: 14),

          // 3. Bước tiếp theo cho Phụ huynh & Con (Bài tập + Link Insights)
          _buildHomeworkNextStepCard(cs),
        ],
      ),
    );
  }

  /// Card định danh con tinh giản, loại bỏ lặp lại tên lớp 3 lần
  Widget _buildChildIdentityCard(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar con với chữ cái đầu nền pastel (không có chấm xanh online)
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _detail.session.childBadgeColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              _detail.session.childInitial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: cs.slate800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Cột thông tin con
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _detail.session.childName,
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _detail.studentMajor ??
                      (_detail.studentCode != null
                          ? 'Mã HS: ${_detail.studentCode}'
                          : 'Học sinh'),
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Badge trạng thái ca học đặt đúng phân cấp
          _buildSessionStatusBadge(cs),
        ],
      ),
    );
  }

  /// Badge trạng thái ca học (Sắp diễn ra, Đang diễn ra, Đã xong, ...)
  Widget _buildSessionStatusBadge(ColorScheme cs) {
    final status = _detail.session.status;
    Color bgColor;
    Color textColor;
    var label = _detail.session.statusLabel;

    switch (status) {
      case ParentSessionStatus.upcoming:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        label = '• Sắp diễn ra';
        break;
      case ParentSessionStatus.inProgress:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = '• Đang học';
        break;
      case ParentSessionStatus.completed:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'Đã kết thúc';
        break;
      case ParentSessionStatus.rescheduled:
        bgColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        label = 'Đã đổi lịch';
        break;
      case ParentSessionStatus.cancelled:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFB91C1C);
        label = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  /// Banner thông báo khi ca học bị dời lịch hoặc hủy
  Widget _buildRescheduleBanner(ColorScheme cs) {
    final isCancelled = _detail.session.status == ParentSessionStatus.cancelled;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCancelled ? const Color(0xFFFECACA) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCancelled
                ? Icons.cancel_outlined
                : Icons.info_outline_rounded,
            color: isCancelled
                ? const Color(0xFFDC2626)
                : const Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _detail.rescheduleReason ??
                  (isCancelled
                      ? 'Buổi học đã được hủy theo kế hoạch của trung tâm.'
                      : 'Buổi học đã được dời lịch giảng dạy.'),
              style: TextStyle(
                color: isCancelled
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF92400E),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Khối thông tin buổi học cốt lõi (Môn, Khung giờ to, Bài học, Meta)
  Widget _buildSessionHeroCard(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng badge môn học và mã buổi học
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _detail.session.subjectName.toUpperCase(),
                  style: TextStyle(
                    color: cs.blue700,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              if (_detail.sessionCode != null)
                Text(
                  _detail.sessionCode!,
                  style: tt.labelSmall?.copyWith(
                    color: cs.slate400,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Khung giờ học to rõ chuẩn Visual Impact
          Text(
            _detail.session.timeRangeText,
            style: tt.headlineMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle ngày học
          Text(
            _formatDateFull(_detail.session.startTime),
            style: tt.bodySmall?.copyWith(
              color: cs.slate500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),

          // Tên bài học
          Text(
            _detail.session.lessonTopic.isNotEmpty
                ? _detail.session.lessonTopic
                : 'Chưa cập nhật nội dung bài học',
            style: tt.titleMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _detail.session.subjectName,
            style: tt.bodySmall?.copyWith(
              color: cs.slate500,
              fontSize: 13,
            ),
          ),
          const Divider(height: 24),

          // Meta item: Hình thức học
          _buildMetaRow(
            icon: Icons.computer_rounded,
            label: 'Hình thức',
            cs: cs,
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _detail.session.roomOrPlatform ??
                        'Trực tuyến (Google Meet)',
                    style: TextStyle(
                      color: cs.slate800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Meta item: Giáo viên giảng dạy
          _buildMetaRow(
            icon: Icons.person_outline_rounded,
            label: 'Giáo viên',
            cs: cs,
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _detail.teacherInfo?.displayTitleWithName ??
                            _detail.session.instructorName,
                        style: TextStyle(
                          color: cs.slate900,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_detail.teacherInfo?.school != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          _detail.teacherInfo!.school!,
                          style: TextStyle(
                            color: cs.slate500,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openTeacherChatSheet(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 15,
                      color: cs.blue600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Meta item: Điểm danh buổi học
          _buildMetaRow(
            icon: Icons.access_time_rounded,
            label: 'Điểm danh',
            cs: cs,
            valueWidget: Text(
              _detail.attendanceInfo?.statusLabel ??
                  'Chưa có thông tin điểm danh',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: _getAttendanceColor(_detail.attendanceInfo?.status),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget dòng meta thông tin chung
  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required ColorScheme cs,
    required Widget valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.slate400),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: cs.slate500,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: valueWidget,
          ),
        ),
      ],
    );
  }

  Color _getAttendanceColor(String? status) {
    switch (status) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'late':
        return const Color(0xFFD97706);
      case 'absent_excused':
      case 'absent_unexcused':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF475569);
    }
  }

  // ===========================================================================
  // SECTION: VIDEO BÀI GIẢNG XEM LẠI (RECORDING)
  // ===========================================================================

  Widget _buildRecordingVideoSection(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final analysis = _detail.completedAnalysis;
    final hasRecording = analysis?.hasRecording ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.videocam_outlined,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'VIDEO BÀI GIẢNG XEM LẠI',
                style: tt.labelSmall?.copyWith(
                  color: cs.slate400,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasRecording) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        analysis?.recordingDuration ?? '48 phút',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _detail.session.lessonTopic.isNotEmpty
                  ? _detail.session.lessonTopic
                  : 'Ghi hình buổi học',
              style: TextStyle(
                color: cs.slate900,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Video chất lượng 1080p · Lưu trữ 30 ngày trong hồ sơ',
              style: TextStyle(
                color: cs.slate500,
                fontSize: 11.5,
              ),
            ),
          ] else ...[
            _buildEmptyStateBox(
              icon: Icons.videocam_off_outlined,
              message: 'Chưa có video ghi hình cho buổi học này.',
              cs: cs,
            ),
          ],
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION: TAB KẾT QUẢ & NHẬN XÉT (THEO THIẾT KẾ V2)
  // ===========================================================================

  Widget _buildQuizResultCard(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final analysis = _detail.completedAnalysis;
    final correct = analysis?.quizCorrectAnswers ?? 3;
    final total = analysis?.quizTotalQuestions ?? 5;
    final percentage = analysis?.quizPercentage ?? 60;
    final scoreLabel = analysis?.scoreLabel ?? 'Cần rèn luyện thêm';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tiêu đề + Badge đánh giá
          Row(
            children: [
              Text(
                'KẾT QUẢ BÀI TẬP TRÊN LỚP',
                style: tt.labelSmall?.copyWith(
                  color: cs.slate400,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  scoreLabel,
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tên bài quiz
          Text(
            analysis?.quizTitle ?? 'Quiz & Thực hành tính toán nhanh',
            style: TextStyle(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),

          // Khối thống kê kết quả: Vòng tròn + Điểm + Thời gian
          Row(
            children: [
              // Vòng tròn tỷ lệ Donut
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 5.5,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF2563EB),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$correct/$total',
                        style: TextStyle(
                          color: cs.slate900,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Cột thông tin điểm số
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$correct / $total đúng',
                          style: TextStyle(
                            color: cs.slate900,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Thời gian làm: ${analysis?.timeSpentMins ?? 18} phút / '
                      '${analysis?.timeLimitMins ?? 25} phút',
                      style: TextStyle(
                        color: cs.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Progress Segment Bar lấp đầy khoảng trống thừa
          Row(
            children: List.generate(total, (index) {
              final isCorrect = index < correct;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index < total - 1 ? 4 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // Tóm tắt kết quả bài làm
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: cs.slate400,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Đúng $correct/$total câu trắc nghiệm • '
                  'Cần ôn lại dạng quy đồng mẫu',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: cs.slate600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Nút xem chi tiết bài làm
          InkWell(
            onTap: () => _showQuizAnswersSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Xem chi tiết bài làm của con',
                    style: TextStyle(
                      color: cs.blue600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: cs.blue600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherFeedbackCard(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    final analysis = _detail.completedAnalysis;
    final teacher = _detail.teacherInfo;
    final comment = analysis?.teacherComment ??
        'Giáo viên đang hoàn thiện nhận xét buổi học.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ĐÁNH GIÁ & NHẬN XÉT CỦA GIÁO VIÊN',
            style: tt.labelSmall?.copyWith(
              color: cs.slate400,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),

          // Thông tin giáo viên
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  teacher?.fullName.isNotEmpty == true
                      ? teacher!.fullName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher?.displayTitleWithName ??
                          _detail.session.instructorName,
                      style: TextStyle(
                        color: cs.slate900,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${analysis?.teacherSubject ?? "Bộ môn Toán"} · '
                      '${analysis?.teacherCommentTime ?? "Hôm nay"}',
                      style: TextStyle(
                        color: cs.slate500,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hộp trích dẫn lời nhận xét
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: Color(0xFF2563EB), width: 3.5),
                top: BorderSide(color: Color(0xFFE2E8F0)),
                right: BorderSide(color: Color(0xFFE2E8F0)),
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Text(
              '“$comment”',
              style: TextStyle(
                color: cs.slate800,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tag chuyên cần chuẩn (tuân thủ privacy gate)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: Color(0xFF059669),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Chuyên cần: • '
                      '${analysis?.attendanceStatus ?? "Có mặt đúng giờ"}',
                      style: const TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Học ${analysis?.attendedMinutes ?? 58}/${analysis?.totalMinutes ?? 60} phút',
                  style: TextStyle(
                    color: cs.slate700,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkNextStepCard(ColorScheme cs) {
    final analysis = _detail.completedAnalysis;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BƯỚC TIẾP THEO CHO PHỤ HUYNH & CON',
                style: TextStyle(
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bài tập về nhà:',
            style: TextStyle(
              color: cs.slate600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            analysis?.homeworkTitle ??
                'Toán 10 — Bài luyện tập 5: Rút gọn phân số có ẩn',
            style: TextStyle(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis?.homeworkDueDate ?? 'Hạn chót: 20:00 tối nay',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  analysis?.homeworkStatus ?? 'Chưa nộp',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFFDE68A)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Đang chuyển sang màn hình Báo cáo phân tích chuyên sâu '
                    '(Insights)...',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    size: 16,
                    color: Color(0xFFB45309),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Xem phân tích xu hướng học tập (Insights) ->',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuizAnswersSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CHI TIẾT BÀI QUIZ TRÊN LỚP',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Học sinh làm đúng 3 / 5 câu trắc nghiệm (60%)',
              style: TextStyle(color: cs.slate600, fontSize: 13),
            ),
            const Divider(height: 24),
            _buildQuizAnswerTile(
              questionNum: 1,
              topic: 'Xác định tập nghiệm phương trình bậc nhất',
              isCorrect: true,
              detail: 'Đúng · Hoàn thành trong 2.5 phút',
            ),
            _buildQuizAnswerTile(
              questionNum: 2,
              topic: 'Biến đổi phân thức đại số cơ bản',
              isCorrect: true,
              detail: 'Đúng · Hoàn thành trong 3 phút',
            ),
            _buildQuizAnswerTile(
              questionNum: 3,
              topic: 'Quy đồng mẫu thức chứa tham số',
              isCorrect: false,
              detail: 'Chưa chính xác · Chọn B (Đáp án đúng: C)',
            ),
            _buildQuizAnswerTile(
              questionNum: 4,
              topic: 'Rút gọn biểu thức điều kiện xác định',
              isCorrect: true,
              detail: 'Đúng · Hoàn thành trong 4 phút',
            ),
            _buildQuizAnswerTile(
              questionNum: 5,
              topic: 'Tìm giá trị nguyên để biểu thức đạt cực đại',
              isCorrect: false,
              detail: 'Chưa chính xác · Chọn A (Đáp án đúng: D)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizAnswerTile({
    required int questionNum,
    required String topic,
    required bool isCorrect,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCorrect
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              size: 15,
              color: isCorrect
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu $questionNum: $topic',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isCorrect
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReminderActionSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final childName = _detail.session.childName;
    final homeworkTitle = _detail.completedAnalysis?.homeworkTitle ??
        'Bài luyện tập sau buổi học';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.slate300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'NHẮC CON ÔN LUYỆN BÀI HỌC',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Gửi nhắc nhở học tập đến $childName để con hoàn thành '
              'bài tập đúng hạn.',
              style: TextStyle(color: cs.slate600, fontSize: 13, height: 1.4),
            ),
            const Divider(height: 24),
            // Tùy chọn 1: Gửi thông báo app
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã gửi thông báo nhắc học đến máy của $childName.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gửi thông báo vào máy của con',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Con sẽ nhận được pop-up nhắc làm bài '
                            'tập ngay lập tức.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: cs.slate600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tùy chọn 2: Sao chép lời nhắn Zalo/SMS
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Đã sao chép lời nhắn! Phụ huynh có thể dán vào '
                      'Zalo/SMS để gửi cho con.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.copy_rounded,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sao chép lời nhắn gửi qua Zalo / SMS',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mẫu: "$childName ơi, con nhớ hoàn thành '
                            '$homeworkTitle..."',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: cs.slate500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION: CHUẨN BỊ TRƯỚC BUỔI HỌC (KHI CA HỌC SẮP DIỄN RA)
  // ===========================================================================

  Widget _buildPreparationSection(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHUẨN BỊ TRƯỚC BUỔI HỌC',
            style: tt.labelSmall?.copyWith(
              color: cs.slate400,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Tài liệu đính kèm
          if (_detail.hasMaterials)
            ..._detail.materials.map((mat) => _buildMaterialItem(mat, cs))
          else
            _buildEmptyStateBox(
              icon: Icons.folder_open_outlined,
              message:
                  'Tài liệu đính kèm: Chưa có tài liệu nào cho buổi học này.',
              cs: cs,
            ),
          const SizedBox(height: 14),

          // 2. Checklist chuẩn bị
          if (_detail.hasChecklist)
            ..._detail.checklist.map((item) => _buildChecklistItem(item, cs))
          else
            _buildEmptyStateBox(
              icon: Icons.assignment_outlined,
              message:
                  'Nhiệm vụ chuẩn bị: Chưa có yêu cầu riêng cho buổi này.',
              cs: cs,
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialItem(SessionMaterial mat, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'PDF',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mat.fileName,
                  style: TextStyle(
                    color: cs.slate900,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${mat.fileSize} • ${mat.uploadTime}',
                  style: TextStyle(
                    color: cs.slate500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.download_rounded,
              color: cs.blue600,
              size: 20,
            ),
            tooltip: 'Tải về',
            onPressed: () => _handleDownloadMaterial(mat),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(SessionChecklistItem item, ColorScheme cs) {
    final isTask = item.type == ChecklistItemType.task;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTask)
            item.isCompleted
                ? const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF16A34A),
                  )
                : const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: Color(0xFFD97706),
                  )
          else
            const Icon(
              Icons.backpack_outlined,
              size: 18,
              color: Color(0xFF2563EB),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                color: cs.slate700,
                fontSize: 13,
                height: 1.4,
                fontWeight:
                    item.isCompleted ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentGuidanceCard(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

    if (!_detail.hasGuidance) {
      return _buildEmptyStateBox(
        icon: Icons.lightbulb_outline,
        message:
            'Gợi ý đồng hành: Chưa có lưu ý đặc biệt từ giáo viên.',
        cs: cs,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF16A34A),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Gợi ý đồng hành cùng con',
                style: tt.titleSmall?.copyWith(
                  color: const Color(0xFF14532D),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _detail.parentGuidance!,
            style: const TextStyle(
              color: Color(0xFF166534),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateBox({
    required IconData icon,
    required String message,
    required ColorScheme cs,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.slate400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cs.slate500,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Action Bar với Safe Area chuẩn thiết kế V2
  Widget _buildStickyBottomActionBar(BuildContext context, ColorScheme cs) {
    final isDone = _detail.isCompleted;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: isDone
            ? Row(
                children: [
                  // Nút phụ bên trái: Nhắn tin cho giáo viên
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () => _openTeacherChatSheet(context),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Nhắn tin',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.slate700,
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nút chính bên phải: Nhắc con ôn luyện bài học
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: () => _showReminderActionSheet(context),
                        icon: const Icon(
                          Icons.notifications_active_rounded,
                          size: 17,
                        ),
                        label: const Text(
                          'Nhắc con ôn luyện',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  // Khi buổi học chưa diễn ra: Xin vắng / muộn
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () => _openAbsenceRequestSheet(context),
                        icon: const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Color(0xFFD97706),
                        ),
                        label: const Text(
                          'Xin vắng / Muộn',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.slate700,
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nhắn tin giáo viên
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: () => _openTeacherChatSheet(context),
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Nhắn tin giáo viên',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ===========================================================================
  // CÁC HÀNH ĐỘNG TƯƠNG TÁC (ACTIONS & MODALS)
  // ===========================================================================

  void _handleAddToCalendar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm ca học (${_detail.session.timeRangeText}) vào lịch.',
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShareSession(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHIA SẺ THÔNG TIN CA HỌC',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Lịch học của ${_detail.session.childName}:\n'
                '• Môn: ${_detail.session.subjectName}\n'
                '• Giờ: ${_detail.session.timeRangeText} '
                'ngày ${_formatDateFull(_detail.session.startTime)}\n'
                '• Phòng: ${_detail.session.roomOrPlatform ?? "Trực tuyến"}\n'
                '• Giáo viên: ${_detail.session.instructorName}',
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép tóm tắt vào bộ nhớ tạm.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Sao chép tóm tắt'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDownloadMaterial(SessionMaterial mat) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang tải xuống: ${mat.fileName} (${mat.fileSize})'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleOpenLessonDetail(BuildContext context) {
    if (_detail.lessonId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mở giáo trình: ${_detail.session.lessonTopic}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chưa có thông tin giáo trình chi tiết cho buổi học này.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openAbsenceRequestSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AbsenceRequestBottomSheet(
        childName: _detail.session.childName,
        sessionTime: _detail.session.timeRangeText,
      ),
    );
  }

  void _openTeacherChatSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeacherChatBottomSheet(
        teacher: _detail.teacherInfo ??
            TeacherDetailInfo(fullName: _detail.session.instructorName),
      ),
    );
  }

  void _openFeedbackSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionFeedbackBottomSheet(
        subjectName: _detail.session.subjectName,
        instructorName: _detail.session.instructorName,
      ),
    );
  }

  void _handleReportIssue(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã gửi thông tin thắc mắc tới ban quản trị lớp học.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDayOfWeekAndDate(DateTime date) {
    final weekdays = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final wd = weekdays[date.weekday];
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$wd, $d/$m';
  }

  String _formatDateFull(DateTime date) {
    final weekdays = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final wd = weekdays[date.weekday];
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$wd, $d/$m/$y';
  }
}

/// Modal Bottom Sheet gửi đơn xin phép vắng hoặc đến muộn
class _AbsenceRequestBottomSheet extends StatefulWidget {
  const _AbsenceRequestBottomSheet({
    required this.childName,
    required this.sessionTime,
  });

  final String childName;
  final String sessionTime;

  @override
  State<_AbsenceRequestBottomSheet> createState() =>
      _AbsenceRequestBottomSheetState();
}

class _AbsenceRequestBottomSheetState
    extends State<_AbsenceRequestBottomSheet> {
  int _requestType = 0; // 0: Xin vắng cả buổi, 1: Báo đến muộn
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XIN PHÉP VẮNG / ĐẾN MUỘN',
                style: TextStyle(
                  color: cs.slate900,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Học sinh: ${widget.childName} • Ca học: ${widget.sessionTime}',
            style: TextStyle(color: cs.slate600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Lựa chọn hình thức
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Xin vắng cả buổi'),
                  selected: _requestType == 0,
                  onSelected: (val) => setState(() => _requestType = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Báo đến muộn'),
                  selected: _requestType == 1,
                  onSelected: (val) => setState(() => _requestType = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Nhập lý do
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập lý do gửi giáo viên (bị ốm, bận việc...)',
              hintStyle: TextStyle(color: cs.slate400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nút gửi đơn
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi thông báo xin phép tới giáo viên.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.slate900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Gửi thông báo'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet thông tin và nhắn tin cho Giáo viên
class _TeacherChatBottomSheet extends StatelessWidget {
  const _TeacherChatBottomSheet({required this.teacher});

  final TeacherDetailInfo teacher;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  teacher.fullName.isNotEmpty
                      ? teacher.fullName[0].toUpperCase()
                      : 'G',
                  style: TextStyle(
                    color: cs.blue700,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.displayTitleWithName,
                      style: TextStyle(
                        color: cs.slate900,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (teacher.school != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        teacher.school!,
                        style: TextStyle(color: cs.slate500, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text(
            'Gửi tin nhắn trực tiếp cho giáo viên phụ trách ca học.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đang mở hộp thoại chat với ${teacher.fullName}...',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Bắt đầu trò chuyện'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.blue600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet Đánh giá buổi học sau khi ca học đã kết thúc
class _SessionFeedbackBottomSheet extends StatefulWidget {
  const _SessionFeedbackBottomSheet({
    required this.subjectName,
    required this.instructorName,
  });

  final String subjectName;
  final String instructorName;

  @override
  State<_SessionFeedbackBottomSheet> createState() =>
      _SessionFeedbackBottomSheetState();
}

class _SessionFeedbackBottomSheetState
    extends State<_SessionFeedbackBottomSheet> {
  int _rating = 5;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ĐÁNH GIÁ BUỔI HỌC',
                style: TextStyle(
                  color: cs.slate900,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Môn: ${widget.subjectName} • GV: ${widget.instructorName}',
            style: TextStyle(color: cs.slate600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Hàng chọn số sao
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: const Color(0xFFD97706),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Khung nhập góp ý
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ý kiến góp ý của phụ huynh (tùy chọn)...',
              hintStyle: TextStyle(color: cs.slate400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nút gửi đánh giá
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cảm ơn phụ huynh đã gửi đánh giá buổi học!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.slate900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Gửi đánh giá'),
            ),
          ),
        ],
      ),
    );
  }
}
