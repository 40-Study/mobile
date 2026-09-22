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
