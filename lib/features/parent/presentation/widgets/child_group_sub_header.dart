import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Sub-header phân chia nhóm theo từng con khi ở chế độ "Tất cả các con":
/// Avatar chữ cái tròn + Tên con + Tên lớp + Badge số lượng item.
class ChildGroupSubHeader extends StatelessWidget {
  const ChildGroupSubHeader({
    super.key,
    required this.child,
    required this.countLabel,
    this.badgeColor,
    this.textColor,
  });

  final FamilyScopeChild child;
  final String countLabel;
  final Color? badgeColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: AppSpacing.paddingVerticalSm,
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: child.badgeColor,
            child: Text(
              child.initialLetter,
              style: tt.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          AppSpacing.hGap8,
          Text(
            child.className != null
                ? '${child.name} • ${child.className}'
                : child.name,
            style: tt.titleSmall?.copyWith(
              color: cs.slate800,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor ?? cs.slate100,
              borderRadius: AppRadius.borderFull,
            ),
            child: Text(
              countLabel,
              style: tt.labelSmall?.copyWith(
                color: textColor ?? cs.slate600,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
