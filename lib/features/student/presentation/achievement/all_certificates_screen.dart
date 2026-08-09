import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/certificate_model.dart';
import 'package:study/features/student/presentation/achievement/certificate_detail_screen.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

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
  const AllCertificatesScreen({super.key});

  @override
  State<AllCertificatesScreen> createState() => _AllCertificatesScreenState();
}

class _AllCertificatesScreenState extends State<AllCertificatesScreen> {
  CertificateCategory _selectedCategory = CertificateCategory.all;

  late final List<CertificateData> _allCertificates = _generateMockData();

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
                        _BackButton(onTap: () => Navigator.pop(context)),
                        const Spacer(),
                        _FilterButton(onTap: () => _showFilterSheet(context)),
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
                child: _OverviewCard(
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
                      _CategoryChip(
                        icon: Icons.grid_view_rounded,
                        label: l10n.all,
                        count: _countByCategory(CertificateCategory.all),
                        isSelected: _selectedCategory == CertificateCategory.all,
                        onTap: () => setState(
                            () => _selectedCategory = CertificateCategory.all),
                      ),
                      AppSpacing.hGap8,
                      _CategoryChip(
                        icon: Icons.palette_rounded,
                        label: l10n.design,
                        count: _countByCategory(CertificateCategory.design),
                        isSelected: _selectedCategory == CertificateCategory.design,
                        onTap: () => setState(
                            () => _selectedCategory = CertificateCategory.design),
                      ),
                      AppSpacing.hGap8,
                      _CategoryChip(
                        icon: Icons.code_rounded,
                        label: l10n.programming,
                        count: _countByCategory(CertificateCategory.programming),
                        isSelected:
                            _selectedCategory == CertificateCategory.programming,
                        onTap: () => setState(() =>
                            _selectedCategory = CertificateCategory.programming),
                      ),
                      AppSpacing.hGap8,
                      _CategoryChip(
                        icon: Icons.business_center_rounded,
                        label: l10n.business,
                        count: _countByCategory(CertificateCategory.business),
                        isSelected:
                            _selectedCategory == CertificateCategory.business,
                        onTap: () => setState(
                            () => _selectedCategory = CertificateCategory.business),
                      ),
                      AppSpacing.hGap8,
                      _CategoryChip(
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

            SliverToBoxAdapter(child: AppSpacing.vGap24),

            // Completed Certificates
            if (_completedCertificates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
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
                      child: _CertificateCard(
                        certificate: _completedCertificates[index],
                        onTap: () => _showCertificateDetail(
                            context, _completedCertificates[index]),
                      ),
                    ),
                    childCount: _completedCertificates.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: AppSpacing.vGap16),
            ],

            // In Progress Certificates
            if (_inProgressCertificates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
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
                      child: _CertificateCard(
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
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  void _showCertificateDetail(BuildContext context, CertificateData cert) {
    if (cert.isCompleted) {
      // Navigate to full detail screen for completed certificates
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
      // Show bottom sheet for in-progress
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        builder: (context) => _CertificateDetailSheet(certificate: cert),
      );
    }
  }

  List<CertificateData> _generateMockData() {
    return [
      // Completed
      CertificateData(
        id: '1',
        courseTitle: 'UI/UX Design Fundamentals',
        instructorName: 'Alex Johnson',
        status: CertificateStatus.completed,
        category: CertificateCategory.design,
        color: AchievementColors.purple,
        certificateNumber: 'CERT-2024-001',
        issueDate: DateTime(2024, 4, 20),
        duration: '24 giờ',
      ),
      CertificateData(
        id: '2',
        courseTitle: 'Design Thinking for Designers',
        instructorName: 'David Chen',
        status: CertificateStatus.completed,
        category: CertificateCategory.design,
        color: AchievementColors.lightBlue,
        certificateNumber: 'CERT-2024-002',
        issueDate: DateTime(2024, 4, 5),
        duration: '18 giờ',
      ),
      CertificateData(
        id: '3',
        courseTitle: 'Python từ cơ bản đến nâng cao',
        instructorName: 'Nguyễn Minh Anh',
        status: CertificateStatus.completed,
        category: CertificateCategory.programming,
        color: AchievementColors.blue,
        certificateNumber: 'CERT-2024-003',
        issueDate: DateTime(2024, 3, 15),
        duration: '40 giờ',
      ),
      CertificateData(
        id: '4',
        courseTitle: 'Lập trình Web với React',
        instructorName: 'Trần Hoàng Nam',
        status: CertificateStatus.completed,
        category: CertificateCategory.programming,
        color: AchievementColors.green,
        certificateNumber: 'CERT-2024-004',
        issueDate: DateTime(2024, 2, 28),
        duration: '36 giờ',
      ),

      // In Progress
      CertificateData(
        id: '5',
        courseTitle: 'Flutter & Dart Complete Course',
        instructorName: 'Sarah Wilson',
        status: CertificateStatus.inProgress,
        category: CertificateCategory.programming,
        color: AchievementColors.violet,
        progress: 0.72,
        totalLessons: 120,
        completedLessons: 86,
        duration: '48 giờ',
      ),
      CertificateData(
        id: '6',
        courseTitle: 'Digital Marketing Masterclass',
        instructorName: 'Michael Brown',
        status: CertificateStatus.inProgress,
        category: CertificateCategory.business,
        color: AchievementColors.orange,
        progress: 0.45,
        totalLessons: 80,
        completedLessons: 36,
        duration: '32 giờ',
      ),
      CertificateData(
        id: '7',
        courseTitle: 'Figma UI Design Essential',
        instructorName: 'Emma Davis',
        status: CertificateStatus.inProgress,
        category: CertificateCategory.design,
        color: AchievementColors.pink,
        progress: 0.28,
        totalLessons: 60,
        completedLessons: 17,
        duration: '20 giờ',
      ),
      CertificateData(
        id: '8',
        courseTitle: 'English for Business Communication',
        instructorName: 'John Smith',
        status: CertificateStatus.inProgress,
        category: CertificateCategory.language,
        color: AchievementColors.red,
        progress: 0.60,
        totalLessons: 50,
        completedLessons: 30,
        duration: '25 giờ',
      ),
    ];
  }
}

// ============================================================
// BACK BUTTON
// ============================================================
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(Icons.arrow_back_rounded, size: 20, color: cs.onSurface),
      ),
    );
  }
}

// ============================================================
// FILTER BUTTON
// ============================================================
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 16, color: cs.onSurface),
            AppSpacing.hGap4,
            Text(AppLocalizations.of(context)!.filter, style: tt.labelMedium),
            AppSpacing.hGap4,
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// OVERVIEW CARD
// ============================================================
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.completedCount,
    required this.inProgressCount,
    required this.totalCount,
  });

  final int completedCount;
  final int inProgressCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          _CircularProgress(
            percent: totalCount > 0 ? completedCount / totalCount : 0,
            size: 72,
            strokeWidth: 6,
          ),
          AppSpacing.hGap16,
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.overview,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                AppSpacing.vGap12,
                Builder(builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Row(
                    children: [
                      _StatItem(
                        count: completedCount,
                        label: l10n.completed,
                        color: cs.primary,
                      ),
                      AppSpacing.hGap24,
                      _StatItem(
                        count: inProgressCount,
                        label: l10n.studying,
                        color: AchievementColors.blue,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  const _CircularProgress({
    required this.percent,
    required this.size,
    required this.strokeWidth,
  });

  final double percent;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              percent: percent,
              strokeWidth: strokeWidth,
              backgroundColor: cs.surfaceContainerHighest,
              progressColor: cs.primary,
            ),
          ),
          Text('${(percent * 100).round()}%',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.percent,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double percent;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        AppSpacing.hGap8,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$count',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(label,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// CATEGORY CHIP
// ============================================================
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? cs.primary : cs.onSurfaceVariant),
            AppSpacing.hGap8,
            Text(label,
                style: tt.labelMedium?.copyWith(
                    color: isSelected ? cs.primary : cs.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
            AppSpacing.hGap4,
            Text('$count',
                style: tt.labelSmall?.copyWith(
                    color: isSelected ? cs.primary : cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Text('$title ($count)',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

// ============================================================
// CERTIFICATE CARD
// ============================================================
class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate, required this.onTap});

  final CertificateData certificate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted = certificate.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Certificate icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: certificate.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isCompleted
                    ? Icons.workspace_premium_rounded
                    : Icons.school_rounded,
                color: certificate.color,
                size: 28,
              ),
            ),
            AppSpacing.hGap16,
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCompleted)
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.certificate.toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                                color: certificate.color,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Icon(Icons.verified_rounded,
                            size: 16, color: certificate.color),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.studying.toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('${(certificate.progress * 100).round()}%',
                            style: tt.labelMedium?.copyWith(
                                color: certificate.color,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  AppSpacing.vGap4,
                  Text(certificate.courseTitle,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  AppSpacing.vGap4,
                  Text(certificate.instructorName,
                      style:
                          tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  if (!isCompleted) ...[
                    AppSpacing.vGap8,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: certificate.progress,
                        minHeight: 4,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation(certificate.color),
                      ),
                    ),
                    AppSpacing.vGap4,
                    Text(
                        '${certificate.completedLessons}/${certificate.totalLessons} ${AppLocalizations.of(context)!.lessons}',
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                  if (isCompleted && certificate.issueDate != null) ...[
                    AppSpacing.vGap4,
                    Text(_formatDate(certificate.issueDate!),
                        style:
                            tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            AppSpacing.hGap8,
            Icon(Icons.chevron_right_rounded,
                size: 20, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }
}

// ============================================================
// FILTER BOTTOM SHEET
// ============================================================
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGap16,
          Text(l10n.filter,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          AppSpacing.vGap24,
          Text(l10n.status, style: tt.titleSmall),
          AppSpacing.vGap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterOption(
                  label: l10n.all,
                  isSelected: _selectedStatus == 'all',
                  onTap: () => setState(() => _selectedStatus = 'all')),
              _FilterOption(
                  label: l10n.completed,
                  isSelected: _selectedStatus == 'completed',
                  onTap: () => setState(() => _selectedStatus = 'completed')),
              _FilterOption(
                  label: l10n.studying,
                  isSelected: _selectedStatus == 'inProgress',
                  onTap: () => setState(() => _selectedStatus = 'inProgress')),
            ],
          ),
          AppSpacing.vGap24,
          Text(l10n.category, style: tt.titleSmall),
          AppSpacing.vGap12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterOption(
                  label: l10n.all,
                  isSelected: _selectedCategory == 'all',
                  onTap: () => setState(() => _selectedCategory = 'all')),
              _FilterOption(
                  label: l10n.design,
                  isSelected: _selectedCategory == 'design',
                  onTap: () => setState(() => _selectedCategory = 'design')),
              _FilterOption(
                  label: l10n.programming,
                  isSelected: _selectedCategory == 'programming',
                  onTap: () =>
                      setState(() => _selectedCategory = 'programming')),
              _FilterOption(
                  label: l10n.business,
                  isSelected: _selectedCategory == 'business',
                  onTap: () => setState(() => _selectedCategory = 'business')),
              _FilterOption(
                  label: l10n.language,
                  isSelected: _selectedCategory == 'language',
                  onTap: () => setState(() => _selectedCategory = 'language')),
            ],
          ),
          AppSpacing.vGap32,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.apply),
            ),
          ),
          AppSpacing.vGap16,
        ],
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 16, color: cs.onPrimary),
              AppSpacing.hGap4,
            ],
            Text(label,
                style: tt.labelMedium?.copyWith(
                    color: isSelected ? cs.onPrimary : cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CERTIFICATE DETAIL SHEET
// ============================================================
class _CertificateDetailSheet extends StatelessWidget {
  const _CertificateDetailSheet({required this.certificate});

  final CertificateData certificate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = certificate.isCompleted;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vGap24,
          // Certificate preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: certificate.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: certificate.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  isCompleted
                      ? Icons.workspace_premium_rounded
                      : Icons.school_rounded,
                  size: 48,
                  color: certificate.color,
                ),
                AppSpacing.vGap12,
                if (isCompleted)
                  Text(l10n.certificate.toUpperCase(),
                      style: tt.labelMedium?.copyWith(
                          color: certificate.color,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700))
                else
                  Text(l10n.studying.toUpperCase(),
                      style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600)),
                AppSpacing.vGap8,
                Text(certificate.courseTitle,
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                AppSpacing.vGap4,
                Text(certificate.instructorName,
                    style: tt.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          AppSpacing.vGap16,
          // Details
          _DetailRow(label: l10n.duration, value: certificate.duration ?? '-'),
          if (isCompleted && certificate.certificateNumber != null)
            _DetailRow(label: l10n.certificate, value: certificate.certificateNumber!),
          if (isCompleted && certificate.issueDate != null)
            _DetailRow(
                label: l10n.completionDate,
                value:
                    '${certificate.issueDate!.day}/${certificate.issueDate!.month}/${certificate.issueDate!.year}'),
          if (!isCompleted) ...[
            _DetailRow(
                label: l10n.inProgress,
                value: '${(certificate.progress * 100).round()}%'),
            _DetailRow(
                label: l10n.lessons,
                value:
                    '${certificate.completedLessons}/${certificate.totalLessons}'),
          ],
          AppSpacing.vGap24,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isCompleted ? l10n.viewCertificate : l10n.continueLearning),
            ),
          ),
          AppSpacing.vGap8,
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ),
          AppSpacing.vGap8,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
