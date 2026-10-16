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
  static const _categories = [
    CertificateCategory.all,
    CertificateCategory.design,
    CertificateCategory.programming,
    CertificateCategory.business,
    CertificateCategory.language,
  ];

  late final List<CertificateData> _allCertificates =
      _mapCertificates(widget.certificates);
  late final PageController _pageController;
  late final ScrollController _categoryScrollController;
  final List<GlobalKey> _chipKeys = List.generate(5, (_) => GlobalKey());

  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedCategoryIndex);
    _categoryScrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  int _countByCategory(CertificateCategory cat) {
    if (cat == CertificateCategory.all) return _allCertificates.length;
    return _allCertificates.where((c) => c.category == cat).length;
  }

  void _onCategoryTapped(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    _scrollToSelectedChip(index);
  }

  void _onPageChanged(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _scrollToSelectedChip(index);
  }

  void _scrollToSelectedChip(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _chipKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    });
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
        child: Column(
          children: [
            // Top App Bar (Always visible)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
              child: Row(
                children: [
                  AchievementBackButton(onTap: () => Navigator.pop(context)),
                  const Spacer(),
                  FilterButton(onTap: () => _showFilterSheet(context)),
                ],
              ),
            ),

            // NestedScrollView: Hero Banner scrolls away,
            // Category Tabs stay pinned, PageView swipes horizontally
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // Academic Credentials Hero Banner (Flat Light, No Gradient)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        bottom: AppSpacing.md,
                      ),
                      child: CertificatesHeroBanner(
                        completedCount: completedCount,
                        inProgressCount: inProgressCount,
                      ),
                    ),
                  ),

                  // Sticky Category Tabs
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: CategoryTabsHeaderDelegate(
                      height: 52,
                      child: _buildCategoryTabs(l10n),
                    ),
                  ),
                ],
                body: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCertificateView(
                      _categories[index],
                      cs,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(AppLocalizations l10n) {
    final categoryIcons = [
      Icons.grid_view_rounded,
      Icons.palette_rounded,
      Icons.code_rounded,
      Icons.business_center_rounded,
      Icons.translate_rounded,
    ];

    final categoryLabels = [
      l10n.all,
      l10n.design,
      l10n.programming,
      l10n.business,
      l10n.language,
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => AppSpacing.hGap8,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          return CategoryChip(
            key: _chipKeys[i],
            icon: categoryIcons[i],
            label: categoryLabels[i],
            count: _countByCategory(cat),
            isSelected: _selectedCategoryIndex == i,
            onTap: () => _onCategoryTapped(i),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCertificateView(
    CertificateCategory cat,
    ColorScheme cs,
  ) {
    final certificates = cat == CertificateCategory.all
        ? _allCertificates
        : _allCertificates.where((c) => c.category == cat).toList();

    final completed = certificates
        .where((c) => c.status == CertificateStatus.completed)
        .toList();
    final inProgress = certificates
        .where((c) => c.status == CertificateStatus.inProgress)
        .toList();

    if (completed.isEmpty && inProgress.isEmpty) {
      return _buildEmptyState(cs);
    }

    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: PageStorageKey<String>('certificates_page_${cat.name}'),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Completed Certificates
            if (completed.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Chứng chỉ đã cấp',
                  count: completed.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CertificateListCard(
                      certificate: completed[index],
                      onTap: () => _showCertificateDetail(
                          context, completed[index]),
                    ),
                    childCount: completed.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],

            // In Progress Certificates
            if (inProgress.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Chứng chỉ đang theo học',
                  count: inProgress.length,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CertificateListCard(
                      certificate: inProgress[index],
                      onTap: () => _showCertificateDetail(
                          context, inProgress[index]),
                    ),
                    childCount: inProgress.length,
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
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
              Icon(
                Icons.workspace_premium_outlined,
                size: 48,
                color: cs.slate400,
              ),
              const SizedBox(height: 12),
              const Text(
                'Chưa có chứng chỉ nào trong danh mục này',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
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
    if (lower.contains('ui') ||
        lower.contains('ux') ||
        lower.contains('thiết kế')) {
      return CertificateCategory.design;
    }
    if (lower.contains('kinh doanh') || lower.contains('business')) {
      return CertificateCategory.business;
    }
    if (lower.contains('anh') ||
        lower.contains('tiếng') ||
        lower.contains('nhật')) {
      return CertificateCategory.language;
    }
    return CertificateCategory.programming;
  }
}
