import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class EmptyGoals extends StatelessWidget {
  const EmptyGoals({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Color(0xFF3D5FC4),
                  size: 22,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chưa có mục tiêu cho ngày này',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.slate900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đặt mục tiêu giúp bạn tập trung và học tập hiệu quả hơn!',
                      style: tt.bodySmall?.copyWith(color: cs.slate500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Material(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: Color(0xFF3D5FC4)),
                    SizedBox(width: 6),
                    Text(
                      'Thêm mục tiêu đầu tiên',
                      style: TextStyle(
                        color: Color(0xFF3D5FC4),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
