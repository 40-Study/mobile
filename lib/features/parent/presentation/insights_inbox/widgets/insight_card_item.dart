import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Thẻ hiển thị một phân tích học tập chi tiết trong Family Insights Inbox
class InsightCardItem extends StatelessWidget {
  const InsightCardItem({
    super.key,
    required this.item,
    this.onActionTap,
    this.onEncourageTap,
  });

  final FamilyInsightItem item;
  final VoidCallback? onActionTap;
  final VoidCallback? onEncourageTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 14),
            _buildDescription(context),
            if (item.metrics.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildMetricsRow(context),
            ],
            if (item.teacherQuote != null) ...[
              const SizedBox(height: 14),
              _buildTeacherQuote(context, item.teacherQuote!),
            ],
            if (item.streakInfo != null) ...[
              const SizedBox(height: 16),
              _buildStreakSection(context, item.streakInfo!),
            ],
            if (item.actionLabel != null) ...[
              const SizedBox(height: 14),
              _buildActionLink(context, item.actionLabel!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isMinh = item.childName.toLowerCase().contains('minh');
    final avatarBg = isMinh ? const Color(0xFFDBEAFE) : const Color(0xFFFEF3C7);
    final avatarTextColor =
        isMinh ? const Color(0xFF1D4ED8) : const Color(0xFFB45309);
    final dotColor = isMinh ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    final (
      String tagText,
      Color tagBg,
      Color tagTextColor,
      IconData tagIcon,
    ) = switch (item.category) {
      FamilyInsightCategory.breakthrough => (
          'Tiến bộ vượt bậc',
          const Color(0xFFECFDF5),
          const Color(0xFF059669),
          Icons.trending_up_rounded,
        ),
      FamilyInsightCategory.attention => (
          'Cần chú ý',
          const Color(0xFFFEF3C7),
          const Color(0xFFB45309),
          Icons.priority_high_rounded,
        ),
      FamilyInsightCategory.reward => (
          'Khen thưởng',
          const Color(0xFFEFF6FF),
          const Color(0xFF1D4ED8),
          Icons.emoji_events_rounded,
        ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar tròn có chấm trạng thái
        Stack(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarBg,
              child: Text(
                item.childName.isNotEmpty ? item.childName[0] : 'C',
                style: tt.titleMedium?.copyWith(
                  color: avatarTextColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        AppSpacing.hGap12,
        // Tên con, Lớp & Phân môn
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.childName} • ${item.className}',
                style: tt.titleSmall?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subjectOrSkill,
                style: tt.bodySmall?.copyWith(
                  color: cs.slate500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Badge phân loại và Thời gian
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3.5,
              ),
              decoration: BoxDecoration(
                color: tagBg,
                borderRadius: AppRadius.borderFull,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tagIcon, size: 12.5, color: tagTextColor),
                  const SizedBox(width: 4),
                  Text(
                    tagText,
                    style: tt.labelSmall?.copyWith(
                      color: tagTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: cs.slate400,
                ),
                const SizedBox(width: 3),
                Text(
                  item.timeAgoText,
                  style: tt.labelSmall?.copyWith(
                    color: cs.slate400,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final text = item.description;
    final highlight = item.highlightText;

    if (highlight == null || !text.contains(highlight)) {
      return Text(
        text,
        style: tt.bodyMedium?.copyWith(
          color: cs.slate700,
          height: 1.45,
          fontSize: 13,
        ),
      );
    }

    final start = text.indexOf(highlight);
    final end = start + highlight.length;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: highlight,
            style: TextStyle(
              color: cs.slate900,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      style: tt.bodyMedium?.copyWith(
        color: cs.slate700,
        height: 1.45,
        fontSize: 13,
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        for (var i = 0; i < item.metrics.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        i == 0
                            ? Icons.check_circle_outline_rounded
                            : Icons.speed_rounded,
                        size: 13.5,
                        color: const Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.metrics[i].label,
                          style: tt.labelSmall?.copyWith(
                            color: cs.slate500,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        item.metrics[i].value,
                        style: tt.titleMedium?.copyWith(
                          color: cs.slate900,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      if (item.metrics[i].delta != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          item.metrics[i].delta!,
                          style: tt.labelSmall?.copyWith(
                            color: item.metrics[i].isPositive
                                ? const Color(0xFF16A34A)
                                : AchievementColors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTeacherQuote(BuildContext context, String quote) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: AppRadius.borderMd,
        border: const Border(
          left: BorderSide(
            color: Color(0xFFF59E0B),
            width: 3.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.edit_note_rounded,
            color: Color(0xFFD97706),
            size: 18,
          ),
          AppSpacing.hGap8,
          Expanded(
            child: Text(
              '"$quote"',
              style: tt.bodySmall?.copyWith(
                color: cs.slate800,
                fontStyle: FontStyle.italic,
                height: 1.4,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(
    BuildContext context,
    InsightStreakInfo streakInfo,
  ) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual Days & Badge ngọn lửa
        Row(
          children: [
            for (final day in streakInfo.activeDayLabels) ...[
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day,
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: AppRadius.borderFull,
                border: Border.all(
                  color: const Color(0xFFFFEDD5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    'Chuỗi ${streakInfo.currentDays} ngày',
                    style: tt.labelSmall?.copyWith(
                      color: const Color(0xFFC2410C),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Nút Primary: Gửi lời khen & khích lệ
        SizedBox(
          width: double.infinity,
          height: 44,
          child: item.hasEncouraged
              ? OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                  label: const Text('Đã gửi lời khích lệ'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed: onEncourageTap,
                  icon: const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text('Gửi lời khen & khích lệ ${item.childName}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionLink(BuildContext context, String label) {
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onActionTap,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
