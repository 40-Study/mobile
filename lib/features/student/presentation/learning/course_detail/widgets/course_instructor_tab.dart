import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_state.dart';
import 'package:study/features/student/presentation/learning/instructor_detail_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/course_detail/course_detail_widgets.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class CourseInstructorTab extends StatelessWidget {
  const CourseInstructorTab({super.key, required this.state});

  final CourseDetailSuccess state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final course = state.course;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        InkWell(
          onTap: () => _navigateToInstructor(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
            child: Row(
              children: [
                CachedAvatar(
                  url: course?.instructorAvatar,
                  radius: 34,
                  backgroundColor: const Color(0xFFEFF6FF),
                  name: course?.instructorName ?? 'T',
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course?.instructorName ?? 'Giảng viên',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                      Text(
                        'Giảng viên chuyên môn',
                        style: tt.bodyMedium?.copyWith(color: cs.slate500),
                      ),
                      AppSpacing.vGap4,
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('4.9', style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          Text(
                            '• 12 khóa học • 15k học viên',
                            style: tt.labelSmall?.copyWith(color: cs.slate500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.slate400),
              ],
            ),
          ),
        ),
        AppSpacing.vGap24,

        const Row(
          children: [
            InstructorStat(icon: Icons.menu_book_outlined, value: '12', label: 'Khóa học'),
            AppSpacing.hGap16,
            InstructorStat(icon: Icons.star_rounded, value: '4.8', label: 'Đánh giá'),
            AppSpacing.hGap16,
            InstructorStat(icon: Icons.people_outline, value: '15k', label: 'Học viên'),
          ],
        ),

        AppSpacing.vGap24,
        FilledButton.tonal(
          onPressed: () => _navigateToInstructor(context),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          child: const Text('Xem trang giảng viên'),
        ),
      ],
    );
  }

  void _navigateToInstructor(BuildContext context) {
    final course = state.course;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InstructorDetailScreen(
          instructorId: course?.instructorId ?? '',
          instructorName: course?.instructorName ?? 'Giảng viên',
          instructorAvatar: course?.instructorAvatar,
        ),
      ),
    );
  }
}
