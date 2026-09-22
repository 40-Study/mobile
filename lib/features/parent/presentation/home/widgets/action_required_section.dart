import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Mục "Cần xử lý": bài tập quá hạn + thay đổi lịch học.
/// Khi rỗng hiển thị trạng thái "0 việc tồn đọng" (All-Clear).
class ActionRequiredSection extends StatelessWidget {
  const ActionRequiredSection({
    super.key,
    required this.alerts,
    required this.childrenNames,
  });

  final List<ParentAlertItem> alerts;

  /// Tên con để render câu giải thích, VD "Minh & Lan" / "Minh" / "các con".
  final String childrenNames;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEmpty = alerts.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: isEmpty
              ? const Color(0xFFA7F3D0)
              : cs.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isEmpty),
          AppSpacing.vGap12,
          if (isEmpty)
            _EmptyAlertCard(childrenNames: childrenNames)
          else
            ...alerts.map((alert) => _AlertItem(alert: alert)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isEmpty) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dotColor = isEmpty ? AchievementColors.green : AchievementColors.red;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        AppSpacing.hGap8,
        Text(
          'CẦN XỬ LÝ',
          style: tt.labelLarge?.copyWith(
            color: cs.slate900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isEmpty
                ? const Color(0xFFECFDF5)
                : const Color(0xFFFEE2E2),
            borderRadius: AppRadius.borderFull,
            border: isEmpty
                ? Border.all(color: const Color(0xFFA7F3D0))
                : null,
          ),
          child: Text(
            isEmpty ? '0 việc tồn đọng' : '${alerts.length} nhắc nhở',
            style: tt.labelSmall?.copyWith(
              color: isEmpty
                  ? const Color(0xFF059669)
                  : AchievementColors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyAlertCard extends StatelessWidget {
  const _EmptyAlertCard({required this.childrenNames});

  final String childrenNames;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: AppRadius.borderMd,
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: Color(0xFF10B981),
            size: 22,
          ),
        ),
        AppSpacing.hGap12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Không có việc cần xử lý hôm nay',
                style: tt.titleSmall?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Không có bài tập quá hạn hay ca học bị thay đổi giờ của '
                '$childrenNames',
                style: tt.bodySmall?.copyWith(color: cs.slate500),
              ),
            ],
          ),
        ),
        AppSpacing.hGap8,
        Text(
          'Tất cả ổn định',
          style: tt.labelSmall?.copyWith(
            color: const Color(0xFF059669),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({required this.alert});

  final ParentAlertItem alert;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOverdue = alert.type == ParentAlertType.overdue;
    final accent = isOverdue ? AchievementColors.red : const Color(0xFFF59E0B);
    final iconBg =
        isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);
    final tagBg =
        isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.borderMd,
            ),
            child: Icon(
              isOverdue
                  ? Icons.assignment_late_outlined
                  : Icons.update_rounded,
              color: accent,
              size: 22,
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alert.childName} • ${alert.subjectName}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.detail,
                  style: tt.bodySmall?.copyWith(color: cs.slate500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isOverdue
                          ? Icons.schedule_rounded
                          : Icons.info_outline_rounded,
                      size: 14,
                      color: accent,
                    ),
                    AppSpacing.hGap4,
                    Expanded(
                      child: Text(
                        alert.metaText,
                        style: tt.labelSmall?.copyWith(color: accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.hGap8,
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  alert.tagLabel,
                  style: tt.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppSpacing.vGap8,
              Icon(Icons.chevron_right_rounded, color: cs.slate400, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
