import 'widgets/insights_dialogs.dart';
import 'widgets/insights_bottom_actions.dart';
import 'widgets/insights_child_header.dart';
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
        alpha: Theme.of(context).brightness == Brightness.light ? 0.045 : 0.065,
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
              style: tt.bodySmall?.copyWith(color: cs.slate500, fontSize: 12),
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
      bottomNavigationBar: _insights != null
          ? InsightsBottomActions(
              onContactTeacher: () =>
                  showInsightsTeacherContact(context, _insights!),
              onRecommendations: () {
                if (widget.onNavigateToRecommendations != null) {
                  widget.onNavigateToRecommendations!();
                } else {
                  _openRecommendedCourses(context);
                }
              },
            )
          : null,
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
            InsightsChildHeader(insights: insights),
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 1),
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
              onTapEvidence: () => showInsightsEvidence(context, insights),
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
