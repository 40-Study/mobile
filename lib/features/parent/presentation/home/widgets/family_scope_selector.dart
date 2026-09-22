import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Thanh chọn phạm vi giám sát: "Tất cả các con" + từng con.
class FamilyScopeSelector extends StatelessWidget {
  const FamilyScopeSelector({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
  });

  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
            itemCount: children.length + 1,
            separatorBuilder: (_, _) => AppSpacing.hGap8,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _AllChildrenChip(
                  selected: selectedChildId == null,
                  onTap: () => onSelected(null),
                );
              }
              final child = children[index - 1];
              return _ChildChip(
                child: child,
                selected: selectedChildId == child.id,
                onTap: () => onSelected(child.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AllChildrenChip extends StatelessWidget {
  const _AllChildrenChip({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.slate900,
          borderRadius: AppRadius.borderFull,
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            const Icon(Icons.groups_rounded, color: Colors.white, size: 18),
            AppSpacing.hGap8,
            Text(
              'Tất cả các con',
              style: tt.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.slate100,
          borderRadius: AppRadius.borderFull,
          border: selected
              ? Border.all(color: cs.blue600, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: child.badgeColor,
              child: Text(
                child.initialLetter,
                style: tt.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AppSpacing.hGap8,
            Text(
              child.className != null
                  ? '${child.name} (${child.className})'
                  : child.name,
              style: tt.labelLarge?.copyWith(
                color: cs.slate800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
