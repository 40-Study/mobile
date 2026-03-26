import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: cs.gradientSurfacePrimary,
              shape: BoxShape.circle,
              border: Border.all(color: cs.outline, width: 1.5),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: AppIconSize.hero,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Khong co buoi hoc nao',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hay tan huong ngay nghi cua ban!',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
