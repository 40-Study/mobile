import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Thẻ thông báo ngày không có lịch học tích cực, thanh nhã
class FreeDay extends StatelessWidget {
  const FreeDay({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_rounded,
              size: 26,
              color: cs.primary,
            ),
          ),
          AppSpacing.vGap12,
          Text(
            'Không có ca học nào',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.slate900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Hôm nay bạn không có lịch học. Hãy tự ôn tập hoặc nghỉ ngơi nhé!',
            style: tt.bodySmall?.copyWith(
              color: cs.slate500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
