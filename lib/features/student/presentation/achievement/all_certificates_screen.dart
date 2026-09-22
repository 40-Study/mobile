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
    final tt = Theme.of(context).textTheme;

    final totalCount = _allCertificates.length;
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
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AchievementBackButton(onTap: () => Navigator.pop(context)),
                        const Spacer(),
                        FilterButton(onTap: () => _showFilterSheet(context)),
                      ],
                    ),
                    AppSpacing.vGap16,
                    Builder(builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: tt.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                              children: [
                                TextSpan(text: l10n.yourCertificates),
                                TextSpan(text: '.', style: TextStyle(color: cs.primary)),
                              ],
                            ),
                          ),
                          AppSpacing.vGap4,
                          Row(
                            children: [
                              Icon(Icons.workspace_premium_rounded,
                                  size: 14, color: cs.onSurfaceVariant),
                              AppSpacing.hGap4,
                              Text(
                                l10n.certificatesEarned(completedCount),
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Overview Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: CertificateOverviewCard(
                  completedCount: completedCount,
                  inProgressCount: inProgressCount,
                  totalCount: totalCount,
                ),
              ),
            ),

            // Category Tabs
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return ListView(
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
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(child: AppSpacing.vGap24),

            // Completed Certificates
            if (_completedCertificates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: AppLocalizations.of(context)!.completed,
                  count: _completedCertificates.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CertificateListCard(
                        certificate: _completedCertificates[index],
                        onTap: () => _showCertificateDetail(
                            context, _completedCertificates[index]),
                      ),
                    ),
                    childCount: _completedCertificates.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.vGap16),
            ],

            // In Progress Certificates
            if (_inProgressCertificates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: AppLocalizations.of(context)!.studying,
                  count: _inProgressCertificates.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: CertificateListCard(
                        certificate: _inProgressCertificates[index],
                        onTap: () => _showCertificateDetail(
                            context, _inProgressCertificates[index]),
                      ),
                    ),
                    childCount: _inProgressCertificates.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => const CertificateFilterSheet(),
    );
  }

  void _showCertificateDetail(BuildContext context, CertificateData cert) {
    if (cert.isCompleted) {
      Navigator.push(
        context,
        MaterialPageRoute(
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
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        builder: (context) => CertificateDetailSheet(certificate: cert),
      );
    }
  }

  List<CertificateData> _mapCertificates(List<CertificateModel> certificates) {
    final colors = [
      AchievementColors.purple,
      AchievementColors.lightBlue,
      AchievementColors.blue,
      AchievementColors.green,
      AchievementColors.violet,
      AchievementColors.orange,
      AchievementColors.pink,
      AchievementColors.red,
    ];

    return certificates.asMap().entries.map((entry) {
      final i = entry.key;
      final cert = entry.value;
      final category = _mapCategory(cert.courseTitle ?? '');

      return CertificateData(
        id: cert.id,
        courseTitle: cert.courseTitle ?? '',
        instructorName: cert.instructorName ?? '',
        status: CertificateStatus.completed,
        category: category,
        color: colors[i % colors.length],
        certificateNumber: cert.certificateNumber,
        issueDate: cert.issueDate,
      );
    }).toList();
  }

  CertificateCategory _mapCategory(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('design') || lower.contains('ui') || lower.contains('ux') || lower.contains('figma')) {
      return CertificateCategory.design;
    }
    if (lower.contains('python') || lower.contains('react') || lower.contains('flutter') ||
        lower.contains('dart') || lower.contains('web') || lower.contains('programming')) {
      return CertificateCategory.programming;
    }
    if (lower.contains('business') || lower.contains('marketing') || lower.contains('kinh doanh')) {
      return CertificateCategory.business;
    }
    if (lower.contains('english') || lower.contains('tiếng') || lower.contains('language')) {
      return CertificateCategory.language;
    }
    return CertificateCategory.programming;
  }
}
