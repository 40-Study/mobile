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

class _ParentSessionDetailScreenState extends State<ParentSessionDetailScreen> {
  late final ParentSessionDetail _detail;

  @override
  void initState() {
    super.initState();
    // Khởi tạo model chi tiết từ session và child truyền vào
    _detail = ParentSessionDetail.fromSession(
      widget.session,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, cs),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ định danh con (tinh gọn, không lặp lại tên lớp)
            _buildChildIdentityCard(cs),
            const SizedBox(height: 12),

            // 2. Banner cảnh báo đổi lịch hoặc hủy ca học (nếu có)
            if (_detail.hasRescheduleInfo) ...[
              _buildRescheduleBanner(cs),
              const SizedBox(height: 12),
            ],

            // 3. Khối thông tin cốt lõi của ca học
            _buildSessionHeroCard(cs),
            const SizedBox(height: 16),

            // 4. Section Chuẩn bị trước buổi học (Tài liệu & Checklist)
            _buildPreparationSection(cs),
            const SizedBox(height: 16),

            // 5. Card Gợi ý đồng hành cùng con (hoặc Empty state nếu chưa có)
            _buildParentGuidanceCard(cs),
            const SizedBox(height: 16),
          ],
        ),
      ),
      // 6. Thanh hành động cố định ở đáy màn hình an toàn với Safe Area
      bottomNavigationBar: _buildStickyBottomActionBar(context, cs),
    );
  }

  /// AppBar chuẩn Locked Child Context với nút Back và 2 icon phụ
  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

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
        children: [
          Text(
            'Buổi học • ${_detail.session.childName}',
            style: tt.titleMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _detail.schoolYear ?? 'Niên khóa 2024–2025',
            style: tt.labelSmall?.copyWith(
              color: cs.slate500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        // Nút thêm lịch nhắc nhở vào Calendar thiết bị
        IconButton(
          icon: Icon(
            Icons.event_note_outlined,
            color: cs.slate700,
            size: 22,
          ),
          tooltip: 'Thêm vào lịch',
          onPressed: () => _handleAddToCalendar(context),
        ),
        // Nút chia sẻ thông tin ca học
        IconButton(
          icon: Icon(
            Icons.share_outlined,
            color: cs.slate700,
            size: 20,
          ),
          tooltip: 'Chia sẻ',
          onPressed: () => _handleShareSession(context),
        ),
        const SizedBox(width: 4),
      ],
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

  /// Section Chuẩn bị trước buổi học (Tài liệu đính kèm & Checklist)
  Widget _buildPreparationSection(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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

  /// Thẻ hiển thị file đính kèm
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
          // Icon PDF đỏ bo góc
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
          // Tên file và dung lượng
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
          // Nút tải file
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

  /// Một mục checklist chuẩn bị
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

  /// Card Gợi ý đồng hành cùng con (hoặc Empty state khi không có)
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

  /// Hộp hiển thị rỗng thanh lịch (Empty state) cho tài liệu / checklist
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

  /// Sticky Bottom Action Bar với Safe Area
  Widget _buildStickyBottomActionBar(BuildContext context, ColorScheme cs) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary Button: Xem chi tiết bài học
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _handleOpenLessonDetail(context),
                icon: const Icon(Icons.menu_book_rounded, size: 20),
                label: const Text(
                  'Xem chi tiết bài học & giáo trình',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.blue600,
                  side: BorderSide(color: cs.blue200, width: 1.2),
                  backgroundColor: const Color(0xFFEFF6FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Hàng tác vụ phụ: Xin vắng & Nhắn tin giáo viên
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openAbsenceRequestSheet(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Xin phép vắng / Muộn',
                            style: TextStyle(
                              color: cs.slate700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 16,
                  width: 1,
                  color: const Color(0xFFCBD5E1),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _openTeacherChatSheet(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline_rounded,
                            size: 16,
                            color: cs.blue600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Nhắn tin giáo viên',
                            style: TextStyle(
                              color: cs.blue600,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
