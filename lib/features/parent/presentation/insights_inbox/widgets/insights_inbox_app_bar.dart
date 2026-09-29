import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Top bar và Header cho màn hình Family Insights Inbox
class InsightsInboxAppBar extends StatelessWidget {
  const InsightsInboxAppBar({
    super.key,
    this.totalChildrenCount = 0,
    required this.unreadCount,
    required this.onBack,
    required this.onMarkAllAsRead,
    this.onFilterTap,
  });

  final int totalChildrenCount;
  final int unreadCount;
  final VoidCallback onBack;
  final VoidCallback onMarkAllAsRead;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nút quay lại
          InkWell(
            onTap: onBack,
            borderRadius: AppRadius.borderFull,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cs.slate100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: cs.slate800,
                size: 20,
              ),
            ),
          ),
          AppSpacing.hGap12,

          // Tiêu đề & phụ đề
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Family Insights Inbox',
                      style: tt.titleLarge?.copyWith(
                        color: cs.slate900,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: AppRadius.borderFull,
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: tt.labelSmall?.copyWith(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Phân tích học tập định kỳ từ giáo viên & hệ thống',
                  style: tt.bodySmall?.copyWith(
                    color: cs.slate500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Nút "Đọc tất cả"
          InkWell(
            onTap: onMarkAllAsRead,
            borderRadius: AppRadius.borderSm,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.done_all_rounded,
                    size: 15,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đọc tất cả',
                    style: tt.labelSmall?.copyWith(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onFilterTap != null)
            IconButton(
              onPressed: onFilterTap,
              icon: Icon(
                Icons.tune_rounded,
                color: cs.slate700,
                size: 22,
              ),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

