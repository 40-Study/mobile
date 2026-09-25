import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/theme/theme.dart';

class CourseReviewsTab extends StatelessWidget {
  const CourseReviewsTab({super.key, required this.state});

  final CourseDetailSuccess state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = state.course;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Row(
          children: [
            Text(
              course?.averageRating.toStringAsFixed(1) ?? '0.0',
              style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.hGap16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < (course?.averageRating.round() ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    )),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    '${_formatCount(course?.totalRatings ?? 0)} đánh giá',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vGap32,
        Center(
          child: Text(
            'Chưa có đánh giá nào.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
