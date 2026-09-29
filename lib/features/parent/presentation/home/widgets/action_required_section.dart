import 'package:flutter/material.dart';
import 'package:study/features/parent/bloc/home/parent_home_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/home/widgets/home_section_skeletons.dart';
import 'package:study/features/parent/presentation/home/widgets/section_error_card.dart';
import 'package:study/theme/theme.dart';

/// Mục "Cần xử lý": phân loại theo 4 mức ưu tiên (Tier 1 -> Tier 4).
/// Hỗ trợ Partial Failure (tự có skeleton và error retry riêng) và Collapse.
class ActionRequiredSection extends StatefulWidget {
  const ActionRequiredSection({
    super.key,
    required this.alerts,
    required this.childrenNames,
    this.status = HomeSectionStatus.success,
    this.errorMessage,
    this.onRetry,
    this.onAlertTap,
  });

  final List<ParentAlertItem> alerts;
  final String childrenNames;
  final HomeSectionStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final ValueChanged<ParentAlertItem>? onAlertTap;

  @override
  State<ActionRequiredSection> createState() => _ActionRequiredSectionState();
}

class _ActionRequiredSectionState extends State<ActionRequiredSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEmpty = widget.alerts.isEmpty;
    final hasEmergency = widget.alerts.any(
      (a) => a.tier == ParentAlertTier.emergency,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, isEmpty, hasEmergency),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildContent(context, cs, isEmpty),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme cs, bool isEmpty) {
    if (widget.status == HomeSectionStatus.loading) {
      return const ActionRequiredSkeleton();
    }

    if (widget.status == HomeSectionStatus.failure) {
      return SectionErrorCard(
        message: widget.errorMessage ?? 'Không thể tải danh sách cần xử lý',
        onRetry: widget.onRetry ?? () {},
      );
    }

    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: const Color(0xFFA7F3D0),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _EmptyAlertCard(
            childrenNames: widget.childrenNames,
          ),
        ),
      );
    }

    // Đảm bảo sắp xếp đúng 4 Tiers: Tier 1 -> Tier 4
    final sortedAlerts = List<ParentAlertItem>.from(widget.alerts)
      ..sort((a, b) => a.tier.index.compareTo(b.tier.index));

    return Column(
      children: [
        for (var i = 0; i < sortedAlerts.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: _AlertItemCard(
              alert: sortedAlerts[i],
              onTap: widget.onAlertTap != null
                  ? () => widget.onAlertTap!(sortedAlerts[i])
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isEmpty, bool hasEmergency) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final dotColor = isEmpty
        ? AchievementColors.green
        : (hasEmergency ? AchievementColors.red : const Color(0xFFD97706));

    final countLabel = isEmpty
        ? '0 việc tồn đọng'
        : '${widget.alerts.length} nhắc nhở';

    final badgeBg = isEmpty
        ? const Color(0xFFECFDF5)
        : (hasEmergency ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7));

    final badgeTextColor = isEmpty
        ? const Color(0xFF059669)
        : (hasEmergency ? AchievementColors.red : const Color(0xFFB45309));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: AppRadius.borderMd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: Container(
                    width: 8.5,
                    height: 8.5,
                    decoration:
                        BoxDecoration(color: dotColor, shape: BoxShape.circle),
                  ),
                ),
              ),
              AppSpacing.hGap8,
              Text(
                'CẦN XỬ LÝ',
                style: tt.labelLarge?.copyWith(
                  color: cs.slate900,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (widget.status == HomeSectionStatus.success)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: AppRadius.borderFull,
                    border: isEmpty
                        ? Border.all(color: const Color(0xFFA7F3D0))
                        : null,
                  ),
                  child: Text(
                    countLabel,
                    style: tt.labelSmall?.copyWith(
                      color: badgeTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              AppSpacing.hGap8,
              AnimatedRotation(
                turns: _isExpanded ? 0 : 0.5,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: cs.slate500,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
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

class _AlertItemCard extends StatelessWidget {
  const _AlertItemCard({required this.alert, this.onTap});

  final ParentAlertItem alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Màu sắc và Icon trực quan theo 4 Tiers
    final (Color accent, Color bg, IconData iconData) = switch (alert.tier) {
      ParentAlertTier.emergency => (
          AchievementColors.red,
          const Color(0xFFFEE2E2),
          alert.type == ParentAlertType.overdue
              ? Icons.assignment_late_outlined
              : Icons.update_rounded,
        ),
      ParentAlertTier.dueToday => (
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
          Icons.alarm_rounded,
        ),
      ParentAlertTier.nextEvent => (
          const Color(0xFF2563EB),
          const Color(0xFFEFF6FF),
          Icons.event_note_rounded,
        ),
      ParentAlertTier.generalInfo => (
          const Color(0xFF475569),
          const Color(0xFFF1F5F9),
          Icons.info_outline_rounded,
        ),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLg,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(
                    iconData,
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
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.detail,
                        style: tt.bodySmall?.copyWith(
                          color: cs.slate600,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: accent,
                          ),
                          AppSpacing.hGap4,
                          Expanded(
                            child: Text(
                              alert.metaText,
                              style: tt.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGap8,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Text(
                        alert.tagLabel,
                        style: tt.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    AppSpacing.hGap4,
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.slate400,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
