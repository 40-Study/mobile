import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';
import 'package:study/features/parent/data/parent_home_api_client.dart';
import 'package:study/features/parent/presentation/learning/insights/widgets/focus_trend_chart_widget.dart';
import 'package:study/features/parent/presentation/learning/insights/widgets/insights_kpi_row_widget.dart';
import 'package:study/features/parent/presentation/learning/insights/widgets/pedagogical_analysis_card.dart';
import 'package:study/features/parent/presentation/learning/insights/widgets/strength_highlight_card.dart';
import 'package:study/features/parent/presentation/learning/recommended_courses/parent_recommended_courses_screen.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';
import 'package:study/theme/theme.dart';

/// Màn hình Báo cáo Phân tích Sư phạm (Learning Insights) dành cho Phụ huynh.
///
/// Phân tích đào sâu theo chuẩn 3 bước:
/// Observation -> Interpretation -> Action, kèm chỉ số trọng yếu,
/// biểu đồ biến thiên độ tập trung và thế mạnh vượt trội của con.
class ParentLearningInsightsScreen extends StatefulWidget {
  const ParentLearningInsightsScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.onNavigateToRecommendations,
  });

  final String childId;
  final String childName;
  final VoidCallback? onNavigateToRecommendations;

  @override
  State<ParentLearningInsightsScreen> createState() =>
      _ParentLearningInsightsScreenState();
}

class _ParentLearningInsightsScreenState
    extends State<ParentLearningInsightsScreen> {
  late final ParentLearningRepository _repo;
  ParentLearningInsightsModel? _insights;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repo = diContainer.isRegistered<ParentLearningRepository>()
        ? diContainer<ParentLearningRepository>()
        : ParentLearningRepositoryImpl(
            apiClient: diContainer.isRegistered<ParentHomeApiClient>()
                ? diContainer<ParentHomeApiClient>()
                : null,
            enablePreviewFallback: true,
          );
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repo.getLearningInsights(widget.childId);
      if (mounted) {
        setState(() {
          _insights = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final surfaceBg = Color.alphaBlend(
      cs.primary.withValues(
        alpha:
            Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065,
      ),
      cs.surfaceContainer,
    );

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: cs.slate800,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights / Phân tích · ${widget.childName}',
              style: tt.titleMedium?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
            ),
            Text(
              _insights?.semester ?? 'Chưa có dữ liệu kỳ học',
              style: tt.bodySmall?.copyWith(
                color: cs.slate500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          if (_insights != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 21),
              color: cs.slate700,
              tooltip: 'Chia sẻ báo cáo',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép liên kết báo cáo học tập.'),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.file_download_outlined, size: 23),
              color: cs.slate700,
              tooltip: 'Tải báo cáo PDF',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang xuất báo cáo sư phạm định dạng PDF...'),
                  ),
                );
              },
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context),
      bottomNavigationBar:
          _insights != null ? _buildBottomActions(context) : null,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchInsights,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_insights == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 36,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có báo cáo phân tích cho ${widget.childName}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hệ thống sẽ tự động cập nhật báo cáo sư phạm và phân tích '
                'chuyên sâu khi ${widget.childName} tham gia các buổi học và '
                'làm bài kiểm tra.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final insights = _insights!;
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: _fetchInsights,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Subheader: Danh tính học sinh + Badge cập nhật
            _buildChildSubHeader(insights, cs),
            const SizedBox(height: 16),
            Divider(
              color: cs.outlineVariant.withValues(alpha: 0.3),
              height: 1,
            ),
            const SizedBox(height: 20),

            // 2. CHỈ SỐ HỌC TẬP TRỌNG YẾU
            InsightsKpiRowWidget(insights: insights),
            const SizedBox(height: 28),

            // 3. THEO DÕI NĂNG LỰC — Biểu đồ độ tập trung
            FocusTrendChartWidget(insights: insights),
            const SizedBox(height: 28),

            // 4. PHÂN TÍCH SƯ PHẠM CHUYÊN SÂU (3 bước)
            PedagogicalAnalysisCard(
              insights: insights,
              onTapEvidence: () => _showEvidenceModal(context, insights),
            ),
            const SizedBox(height: 28),

            // 5. NĂNG KHIẾU VƯỢT TRỘI
            StrengthHighlightCard(insights: insights),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Subheader hiển thị danh tính con đang xem báo cáo
  Widget _buildChildSubHeader(
    ParentLearningInsightsModel insights,
    ColorScheme cs,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF2563EB),
          child: Text(
            insights.childInitials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          insights.childName,
          style: TextStyle(
            color: cs.slate900,
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            insights.className,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF86EFAC).withValues(alpha: 0.5),
            ),
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
              const SizedBox(width: 5),
              Text(
                insights.updateStatus,
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Khối nút bấm sticky ở mép đáy màn hình
  Widget _buildBottomActions(BuildContext context) {
    final insights = _insights!;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Nút 1: Nhắn GVCN (Chiếm ~40%)
            Expanded(
              flex: 4,
              child: OutlinedButton.icon(
                onPressed: () => _handleContactTeacher(context, insights),
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: Color(0xFF0F172A),
                ),
                label: const Text(
                  'Nhắn GVCN',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Nút 2: Xem lộ trình cải thiện → (Chiếm ~60%)
            Expanded(
              flex: 6,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.onNavigateToRecommendations != null) {
                    widget.onNavigateToRecommendations!();
                  } else {
                    _openRecommendedCourses(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderMd,
                  ),
                ),
                child: const Text(
                  'Xem lộ trình cải thiện →',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContactTeacher(
    BuildContext context,
    ParentLearningInsightsModel insights,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        insights.teacherName.substring(
                          insights.teacherName.lastIndexOf(' ') + 1,
                          insights.teacherName.lastIndexOf(' ') + 2,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${insights.teacherName} '
                          '(${insights.teacherSubject})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Giáo viên phụ trách môn học',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bạn muốn trao đổi cùng giáo viên về vấn đề:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(
                    Icons.assignment_outlined,
                    color: Color(0xFF2563EB),
                  ),
                  title: const Text('Xin bài tập củng cố cá nhân hoá'),
                  subtitle: const Text(
                    'Theo khuyến nghị phân tích sư phạm tuần 12',
                  ),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã gửi yêu cầu nhận 3 bài tập củng cố tới '
                          '${insights.teacherName}.',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF16A34A),
                  ),
                  title: const Text('Hẹn trao đổi trực tiếp 15 phút'),
                  subtitle: const Text('Qua Google Meet vào cuối tuần'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã tạo lịch hẹn trao đổi với '
                          '${insights.teacherName}.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEvidenceModal(
    BuildContext context,
    ParentLearningInsightsModel insights,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bằng chứng định lượng (Evidence)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Bài tập về nhà Buổi 8 — Rút gọn phân thức đại số',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Kết quả: Đúng 3/5 bài (Sai câu 2 và 4 do nhầm dấu)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '2. Mini-quiz kiểm tra nhanh đầu giờ Buổi 8',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Kết quả: 3/5 điểm • Thời gian làm bài: 8p 15s',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openRecommendedCourses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ParentRecommendedCoursesScreen(
          childId: widget.childId,
          childName: widget.childName,
          className: _insights?.className ?? '10A1',
        ),
      ),
    );
  }
}
