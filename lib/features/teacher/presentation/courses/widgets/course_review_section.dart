import 'package:flutter/material.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/theme.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class CourseReviewSection extends StatelessWidget {
  const CourseReviewSection({
    super.key,
    required this.course,
    required this.busy,
    required this.error,
    required this.onReview,
    required this.onRetry,
  });
  final Map<String, dynamic> course;
  final bool busy;
  final Object? error;
  final VoidCallback onReview;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), cs = Theme.of(context).colorScheme;
    final status = '${course['status'] ?? ''}';
    return TeacherSurface(
      padding: AppSpacing.paddingXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                status == 'rejected'
                    ? Icons.feedback_outlined
                    : Icons.fact_check_outlined,
                color: status == 'rejected' ? cs.error : cs.primary,
              ),
              AppSpacing.hGap8,
              Expanded(
                child: Text(
                  'Trạng thái xét duyệt',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          if (course['rejection_reason'] != null) ...[
            Text(
              'Lý do từ chối: ${course['rejection_reason']}',
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
            ),
            AppSpacing.vGap8,
          ],
          Text(
            status == 'pending_review'
                ? 'Khóa đang chờ duyệt. Rút yêu cầu nếu bạn cần chỉnh sửa.'
                : status == 'archived'
                ? 'Khóa đã lưu trữ; nội dung chỉ đọc.'
                : 'Hoàn thiện thông tin và giáo trình trước khi gửi duyệt. Khóa chỉ được xuất bản sau khi được duyệt.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          if (error != null) TeacherErrorView(error: error!, onRetry: onRetry),
          if (['draft', 'rejected', 'pending_review'].contains(status)) ...[
            AppSpacing.vGap16,
            OutlinedButton.icon(
              onPressed: busy ? null : onReview,
              icon: Icon(
                status == 'pending_review' ? Icons.undo : Icons.send_outlined,
              ),
              label: Text(
                busy
                    ? 'Đang xử lý…'
                    : status == 'pending_review'
                    ? 'Rút yêu cầu duyệt'
                    : 'Kiểm tra và gửi duyệt',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
