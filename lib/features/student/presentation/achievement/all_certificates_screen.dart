import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/student/presentation/achievement/certificate_detail_screen.dart';
import 'package:study/features/student/presentation/achievement/widgets/widgets.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

// Certificate types for UI only
enum CertificateStatus { completed, inProgress }

enum CertificateCategory { all, design, programming, business, language }

class CertificateData {
  const CertificateData({
    required this.id,
    required this.courseTitle,
    required this.instructorName,
    required this.status,
    required this.category,
    required this.color,
    this.certificateNumber,
    this.issueDate,
    this.progress = 0,
    this.totalLessons = 0,
    this.completedLessons = 0,
    this.duration,
  });

  final String id;
  final String courseTitle;
  final String instructorName;
  final CertificateStatus status;
  final CertificateCategory category;
  final Color color;
  final String? certificateNumber;
  final DateTime? issueDate;
  final double progress;
  final int totalLessons;
  final int completedLessons;
  final String? duration;

  bool get isCompleted => status == CertificateStatus.completed;
}

class AllCertificatesScreen extends StatefulWidget {
  const AllCertificatesScreen({super.key, required this.certificates});

  final List<CertificateModel> certificates;

  @override
  State<AllCertificatesScreen> createState() => _AllCertificatesScreenState();
}

class _AllCertificatesScreenState extends State<AllCertificatesScreen> {
  CertificateCategory _selectedCategory = CertificateCategory.all;

  late final List<CertificateData> _allCertificates = _mapCertificates(widget.certificates);

  List<CertificateData> get _filteredCertificates {
    if (_selectedCategory == CertificateCategory.all) return _allCertificates;
    return _allCertificates
        .where((c) => c.category == _selectedCategory)
        .toList();
  }

  List<CertificateData> get _completedCertificates => _filteredCertificates
      .where((c) => c.status == CertificateStatus.completed)
      .toList();

  List<CertificateData> get _inProgressCertificates => _filteredCertificates
      .where((c) => c.status == CertificateStatus.inProgress)
      .toList();

  int _countByCategory(CertificateCategory cat) {
    if (cat == CertificateCategory.all) return _allCertificates.length;
    return _allCertificates.where((c) => c.category == cat).length;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final completedCount = _allCertificates
        .where((c) => c.status == CertificateStatus.completed)
        .length;
    final inProgressCount = _allCertificates
        .where((c) => c.status == CertificateStatus.inProgress)
        .length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    AchievementBackButton(onTap: () => Navigator.pop(context)),
                    const Spacer(),
                    FilterButton(onTap: () => _showFilterSheet(context)),
                  ],
                ),
              ),
            ),

            // Academic Credentials Hero Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D5FC4), Color(0xFF2E4899), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3D5FC4).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          AppSpacing.hGap12,
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HỒ SƠ NĂNG LỰC HỌC THUẬT',
                                  style: TextStyle(
                                    color: Color(0xFFBFDBFE),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Chứng Chỉ & Văn Bằng ForteX',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$completedCount đã cấp • $inProgressCount đang học',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Xác thực mã định danh điện tử trên hệ thống',
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: const Color(0xFF34D399), width: 0.8),
                              ),
                              child: const Text(
                                'Đã xác thực',
                                style: TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Category Tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    CategoryChip(
                      icon: Icons.grid_view_rounded,
                      label: l10n.all,
                      count: _countByCategory(CertificateCategory.all),
                      isSelected: _selectedCategory == CertificateCategory.all,
                      onTap: () => setState(
                          () => _selectedCategory = CertificateCategory.all),
                    ),
                    AppSpacing.hGap8,
                    CategoryChip(
                      icon: Icons.palette_rounded,
                      label: l10n.design,
                      count: _countByCategory(CertificateCategory.design),
                      isSelected: _selectedCategory == CertificateCategory.design,
                      onTap: () => setState(
                          () => _selectedCategory = CertificateCategory.design),
                    ),
                    AppSpacing.hGap8,
                    CategoryChip(
                      icon: Icons.code_rounded,
                      label: l10n.programming,
                      count: _countByCategory(CertificateCategory.programming),
                      isSelected:
                          _selectedCategory == CertificateCategory.programming,
                      onTap: () => setState(() =>
                          _selectedCategory = CertificateCategory.programming),
                    ),
                    AppSpacing.hGap8,
                    CategoryChip(
                      icon: Icons.business_center_rounded,
                      label: l10n.business,
                      count: _countByCategory(CertificateCategory.business),
                      isSelected:
                          _selectedCategory == CertificateCategory.business,
                      onTap: () => setState(
                          () => _selectedCategory = CertificateCategory.business),
                    ),
                    AppSpacing.hGap8,
                    CategoryChip(
                      icon: Icons.translate_rounded,
                      label: l10n.language,
                      count: _countByCategory(CertificateCategory.language),
                      isSelected:
                          _selectedCategory == CertificateCategory.language,
                      onTap: () => setState(
                          () => _selectedCategory = CertificateCategory.language),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Completed Certificates
            if (_completedCertificates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Chứng chỉ đã cấp',
                  count: _completedCertificates.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CertificateListCard(
                      certificate: _completedCertificates[index],
                      onTap: () => _showCertificateDetail(
                          context, _completedCertificates[index]),
                    ),
                    childCount: _completedCertificates.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],

            // In Progress Certificates
            if (_inProgressCertificates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Chứng chỉ đang theo học',
                  count: _inProgressCertificates.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CertificateListCard(
                      certificate: _inProgressCertificates[index],
                      onTap: () => _showCertificateDetail(
                          context, _inProgressCertificates[index]),
                    ),
                    childCount: _inProgressCertificates.length,
                  ),
                ),
              ),
            ],

            if (_completedCertificates.isEmpty && _inProgressCertificates.isEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.workspace_premium_outlined, size: 48, color: cs.slate400),
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có chứng chỉ nào trong danh mục này',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => const CertificateFilterSheet(),
    );
  }

  void _showCertificateDetail(BuildContext context, CertificateData cert) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CertificateDetailScreen(
          certificate: CertificateModel(
            id: cert.id,
            courseTitle: cert.courseTitle,
            instructorName: cert.instructorName,
            issueDate: cert.issueDate,
            certificateNumber: cert.certificateNumber,
          ),
        ),
      ),
    );
  }

  List<CertificateData> _mapCertificates(List<CertificateModel> certs) {
    final colors = [
      const Color(0xFF3D5FC4),
      AchievementColors.orange,
      AchievementColors.green,
      AchievementColors.purple,
    ];

    return certs.asMap().entries.map((entry) {
      final i = entry.key;
      final c = entry.value;

      final isCompleted = c.issueDate != null;
      final status = isCompleted
          ? CertificateStatus.completed
          : CertificateStatus.inProgress;

      final category = _mapCategory(c.courseTitle);

      return CertificateData(
        id: c.id,
        courseTitle: c.courseTitle ?? 'Khóa học',
        instructorName: c.instructorName ?? 'Giảng viên ForteX',
        status: status,
        category: category,
        color: colors[i % colors.length],
        certificateNumber: c.certificateNumber ?? 'FTX-2026-${8800 + i}',
        issueDate: c.issueDate,
        progress: isCompleted ? 1.0 : 0.65,
        totalLessons: 24,
        completedLessons: isCompleted ? 24 : 16,
      );
    }).toList();
  }

  CertificateCategory _mapCategory(String? title) {
    if (title == null) return CertificateCategory.programming;
    final lower = title.toLowerCase();
    if (lower.contains('ui') || lower.contains('ux') || lower.contains('thiết kế')) {
      return CertificateCategory.design;
    }
    if (lower.contains('kinh doanh') || lower.contains('business')) {
      return CertificateCategory.business;
    }
    if (lower.contains('anh') || lower.contains('tiếng') || lower.contains('nhật')) {
      return CertificateCategory.language;
    }
    return CertificateCategory.programming;
  }
}
