import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Thanh chọn phạm vi giám sát: "Tất cả các con" + từng con.
/// Khi chưa liên kết con hiển thị nút liên kết.
class FamilyScopeSelector extends StatelessWidget {
  const FamilyScopeSelector({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
    this.onLinkChild,
  });

  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final ValueChanged<String?> onSelected;
  final VoidCallback? onLinkChild;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (children.isEmpty) {
      return _buildEmptyState(context);
    }

    final showAllChildren = children.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Text(
                '• FAMILY SCOPE • CHẾ ĐỘ GIÁM SÁT',
                style: tt.labelSmall?.copyWith(
                  color: cs.blue600,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                'Cập nhật 2 phút trước',
                style: tt.labelSmall?.copyWith(color: cs.slate400),
              ),
            ],
          ),
        ),
        AppSpacing.vGap12,
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            itemCount: showAllChildren ? children.length + 1 : children.length,
            separatorBuilder: (_, _) => AppSpacing.hGap8,
            itemBuilder: (context, index) {
              if (showAllChildren && index == 0) {
                return _AllChildrenChip(
                  count: children.length,
                  selected: selectedChildId == null,
                  onTap: () => onSelected(null),
                );
              }
              final child =
                  showAllChildren ? children[index - 1] : children[index];
              return _ChildChip(
                child: child,
                selected: showAllChildren ? selectedChildId == child.id : true,
                onTap: () => onSelected(child.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(Icons.family_restroom_outlined, size: 32, color: cs.slate400),
            AppSpacing.vGap8,
            Text(
              'Chưa có tài khoản con nào được liên kết',
              style: tt.titleSmall?.copyWith(
                color: cs.slate900,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vGap4,
            Text(
              'Chưa có tài khoản con nào được liên kết với số điện thoại/email '
              'này.',
              style: tt.bodySmall?.copyWith(color: cs.slate500),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap12,
            OutlinedButton.icon(
              onPressed: onLinkChild,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Liên kết tài khoản con'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllChildrenChip extends StatelessWidget {
  const _AllChildrenChip({
    required this.selected,
    required this.count,
    required this.onTap,
  });

  final bool selected;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? cs.blue600 : cs.slate100,
          borderRadius: AppRadius.borderFull,
          border: selected
              ? null
              : Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_rounded,
              color: selected ? Colors.white : cs.slate600,
              size: 20,
            ),
            AppSpacing.hGap8,
            Text(
              'Tất cả các con',
              style: tt.labelLarge?.copyWith(
                color: selected ? Colors.white : cs.slate700,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : cs.slate200,
                borderRadius: AppRadius.borderFull,
              ),
              child: Text(
                '$count',
                style: tt.labelSmall?.copyWith(
                  color: selected ? Colors.white : cs.slate700,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final FamilyScopeChild child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : cs.slate100,
          borderRadius: AppRadius.borderFull,
          border: selected
              ? Border.all(color: cs.blue600, width: 1.5)
              : Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: child.badgeColor,
              child: Text(
                child.initialLetter,
                style: tt.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ),
            AppSpacing.hGap8,
            Text(
              child.className != null
                  ? '${child.name} (${child.className})'
                  : child.name,
              style: tt.labelLarge?.copyWith(
                color: selected ? cs.blue700 : cs.slate800,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
