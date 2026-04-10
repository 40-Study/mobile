import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/bloc/children/children_selector_cubit.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';
import 'package:study/theme/app_colors.dart';

class ParentPortfolioScreen extends StatefulWidget {
  const ParentPortfolioScreen({super.key});

  @override
  State<ParentPortfolioScreen> createState() => _ParentPortfolioScreenState();
}

class _ParentPortfolioScreenState extends State<ParentPortfolioScreen> {
  PortfolioItemType? _selectedFilter;

  // Mock data - replace with actual data from repository
  List<PortfolioItemModel> get _mockItems => [
        PortfolioItemModel(
          id: '1',
          title: 'Bài tập Toán - Chương 3',
          type: PortfolioItemType.assignment,
          score: 9.5,
          maxScore: 10,
          teacherFeedback: 'Làm bài rất tốt, trình bày rõ ràng',
          className: 'Toán 10A1',
          createdAt: '2024-03-20',
          isHighlighted: true,
        ),
        PortfolioItemModel(
          id: '2',
          title: 'Dự án Web App',
          type: PortfolioItemType.project,
          score: 95,
          maxScore: 100,
          teacherFeedback: 'Dự án sáng tạo, code sạch',
          className: 'Lập trình Web',
          createdAt: '2024-03-15',
          isHighlighted: true,
        ),
        PortfolioItemModel(
          id: '3',
          title: 'Bài kiểm tra giữa kỳ',
          type: PortfolioItemType.test,
          score: 8.5,
          maxScore: 10,
          teacherFeedback: 'Cần cải thiện phần lý thuyết',
          className: 'Vật lý 10',
          createdAt: '2024-03-10',
        ),
        PortfolioItemModel(
          id: '4',
          title: 'Chứng chỉ tiếng Anh',
          type: PortfolioItemType.certificate,
          className: 'English Club',
          createdAt: '2024-02-28',
          isHighlighted: true,
        ),
      ];

  List<PortfolioItemModel> get _filteredItems {
    if (_selectedFilter == null) return _mockItems;
    return _mockItems.where((item) => item.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedChild = context.watch<ChildrenSelectorCubit>().selectedChild;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Portfolio học tập'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Child info card
          if (selectedChild != null)
            Padding(
              padding: const EdgeInsets.all(AppLayout.screenMargin),
              child: _ChildInfoCard(child: selectedChild),
            ),

          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  isSelected: _selectedFilter == null,
                  onSelected: () => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Bài tập',
                  isSelected: _selectedFilter == PortfolioItemType.assignment,
                  onSelected: () =>
                      setState(() => _selectedFilter = PortfolioItemType.assignment),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Dự án',
                  isSelected: _selectedFilter == PortfolioItemType.project,
                  onSelected: () =>
                      setState(() => _selectedFilter = PortfolioItemType.project),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Bài kiểm tra',
                  isSelected: _selectedFilter == PortfolioItemType.test,
                  onSelected: () =>
                      setState(() => _selectedFilter = PortfolioItemType.test),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Chứng chỉ',
                  isSelected: _selectedFilter == PortfolioItemType.certificate,
                  onSelected: () =>
                      setState(() => _selectedFilter = PortfolioItemType.certificate),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Portfolio items
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text('Chưa có thành quả nào'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppLayout.screenMargin),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _PortfolioItemCard(item: _filteredItems[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChildInfoCard extends StatelessWidget {
  const _ChildInfoCard({required this.child});

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: cs.gradientPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
            backgroundImage:
                child.avatarUrl != null ? NetworkImage(child.avatarUrl!) : null,
            child: child.avatarUrl == null
                ? Icon(Icons.person, color: cs.onPrimary, size: 28)
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${child.displayGrade} • ${child.displaySchool}',
                  style: TextStyle(
                    color: cs.onPrimary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: cs.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${child.averageScoreDisplay} TB',
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? cs.onPrimary : cs.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PortfolioItemCard extends StatelessWidget {
  const _PortfolioItemCard({required this.item});

  final PortfolioItemModel item;

  IconData get _typeIcon {
    switch (item.type) {
      case PortfolioItemType.assignment:
        return Icons.assignment;
      case PortfolioItemType.project:
        return Icons.folder_special;
      case PortfolioItemType.test:
        return Icons.quiz;
      case PortfolioItemType.certificate:
        return Icons.workspace_premium;
      case PortfolioItemType.achievement:
        return Icons.emoji_events;
    }
  }

  Color _typeColor(ColorScheme cs) {
    switch (item.type) {
      case PortfolioItemType.assignment:
        return cs.primary;
      case PortfolioItemType.project:
        return Colors.purple;
      case PortfolioItemType.test:
        return Colors.orange;
      case PortfolioItemType.certificate:
        return Colors.amber;
      case PortfolioItemType.achievement:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _typeColor(cs);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isHighlighted
              ? color.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
          width: item.isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_typeIcon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                        if (item.isHighlighted)
                          Icon(Icons.star, color: Colors.amber, size: 20),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.type.displayName} • ${item.className ?? ''}',
                      style: TextStyle(
                        color: cs.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.score}/${item.maxScore}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (item.teacherFeedback != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: cs.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item.teacherFeedback!,
                      style: TextStyle(
                        color: cs.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.createdAt,
            style: TextStyle(
              color: cs.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
