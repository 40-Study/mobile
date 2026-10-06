import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Thanh lọc phân loại theo con cho Family Insights Inbox
class InsightsChildFilterBar extends StatelessWidget {
  const InsightsChildFilterBar({
    super.key,
    required this.children,
    required this.selectedChildId,
    required this.onChildSelected,
    required this.countGetter,
  });

  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final ValueChanged<String?> onChildSelected;
  final int Function(String? childId) countGetter;

  @override
  Widget build(BuildContext context) {
    final allCount = countGetter(null);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Chip: Tất cả thông báo
          _buildFilterChip(
            context: context,
            label: 'Tất cả thông báo',
            count: allCount,
            isSelected: selectedChildId == null,
            onTap: () => onChildSelected(null),
            dotColor: null,
          ),
          for (final child in children) ...[
            const SizedBox(width: 8),
            _buildFilterChip(
              context: context,
              label: child.className != null
                  ? '${child.name} (Lớp ${child.className})'
                  : child.name,
              count: countGetter(child.id),
              isSelected: selectedChildId == child.id,
              onTap: () => onChildSelected(child.id),
              dotColor: child.badgeColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color? dotColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Phong cách chip theo ảnh thiết kế:
    // Khi được chọn: Nền đen sang trọng (slate900), chữ trắng
    // Khi không chọn: Nền trắng, viền mờ, chữ slate700
    final bgColor = isSelected ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isSelected ? Colors.white : cs.slate700;
    final countBgColor = isSelected
        ? Colors.white.withValues(alpha: 0.2)
        : cs.slate100;
    final countTextColor = isSelected ? Colors.white : cs.slate600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderFull,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.borderFull,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : cs.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 7.5,
                  height: 7.5,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: tt.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: countBgColor,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    '$count',
                    style: tt.labelSmall?.copyWith(
                      color: countTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
