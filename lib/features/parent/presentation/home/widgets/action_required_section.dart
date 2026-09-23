import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

/// Mục "Cần xử lý": bài tập quá hạn + thay đổi lịch học.
/// Khi rỗng hiển thị trạng thái "0 việc tồn đọng" (All-Clear).
/// Tiêu đề nằm ngoài card, hỗ trợ thu gọn/mở rộng (mặc định: mở toàn bộ).
class ActionRequiredSection extends StatefulWidget {
  const ActionRequiredSection({
    super.key,
    required this.alerts,
    required this.childrenNames,
    this.onAlertTap,
  });

  final List<ParentAlertItem> alerts;

  /// Tên con để render câu giải thích, VD "Minh & Lan" / "Minh" / "các con".
  final String childrenNames;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, isEmpty),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: isEmpty
              ? Padding(
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
                )
              : Column(
                  children: [
                    for (var i = 0; i < widget.alerts.length; i++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          0,
                        ),
                        child: _AlertItemCard(
                          alert: widget.alerts[i],
                          onTap: widget.onAlertTap != null
                              ? () => widget.onAlertTap!(widget.alerts[i])
                              : null,
                        ),
                      ),
                  ],
                ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isEmpty) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dotColor = isEmpty ? AchievementColors.green : AchievementColors.red;

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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  isEmpty
                      ? '0 việc tồn đọng'
                      : '${widget.alerts.length} nhắc nhở',
                  style: tt.labelSmall?.copyWith(
                    color: isEmpty
                        ? const Color(0xFF059669)
                        : AchievementColors.red,
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
    final isOverdue = alert.type == ParentAlertType.overdue;
    final accent = isOverdue ? AchievementColors.red : const Color(0xFFD97706);
    final iconBg = isOverdue
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFEF3C7);
    final tagBg = isOverdue ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);

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
                            isOverdue
                                ? Icons.schedule_rounded
                                : Icons.info_outline_rounded,
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
                        color: tagBg,
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
