import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/models/teacher_course_item.dart';
import 'package:study/features/student/presentation/screens/teacher_profile_screen.dart';
import 'package:study/theme/app_colors.dart';

class CourseOverviewTab extends StatelessWidget {
  const CourseOverviewTab({super.key, required this.detail});
  final CourseDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.xxl,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        Text(
          'Gioi thieu khoa hoc',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          detail.description ?? '',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.6,
          ),
        ),

        SizedBox(height: AppSpacing.xxxl),

        Text(
          'Ban se hoc duoc gi',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.lg),
        ...detail.learningOutcomes.map(
          (outcome) => OutcomeItem(text: outcome),
        ),

        SizedBox(height: AppSpacing.xxxl),

        Text(
          'Thong tin giang vien',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: AppSpacing.lg),
        InstructorCard(detail: detail),
      ],
    );
  }
}

class OutcomeItem extends StatelessWidget {
  const OutcomeItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.15),
          ),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: AppIconSize.sm,
                color: cs.primary,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructorCard extends StatelessWidget {
  const InstructorCard({super.key, required this.detail});
  final CourseDetailModel detail;

  void _openTeacherProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeacherProfileScreen(
          instructorName: detail.instructorName ?? '',
          instructorAvatar: detail.instructorAvatar,
          instructorTitle: detail.instructorTitle,
          instructorBio: detail.instructorBio,
          instructorStudentCount: detail.instructorStudentCount,
          instructorRating: detail.instructorRating,
          instructorCourseCount: 14,
          skills: const ['Product Design', 'Figma Pro', 'User Research'],
          featuredCourses: const [
            TeacherCourseItem(
              id: 'tc1',
              title: 'Mastering Figma: From Beginner to Pro 2024',
              duration: '12h 45m',
              price: '\$49.99',
              rating: 4.9,
            ),
            TeacherCourseItem(
              id: 'tc2',
              title: 'User Research Methods for Fast-Paced Startups',
              duration: '8h 20m',
              price: '\$34.00',
              rating: 4.8,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _openTeacherProfile(context),
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.15),
          ),
          boxShadow: cs.shadowCard,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: cs.surfaceTintedPrimary,
              child: Icon(Icons.person_rounded,
                  size: AppIconSize.xxl, color: cs.primary),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              detail.instructorName ?? '',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              detail.instructorTitle ?? '',
              style: tt.labelSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline_rounded,
                    size: AppIconSize.xs, color: cs.onSurfaceVariant),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  '${(detail.instructorStudentCount / 1000).toStringAsFixed(1)}k+'
                  ' Hoc vien',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(width: AppSpacing.lg),
                Icon(Icons.star_rounded,
                    size: AppIconSize.xs, color: cs.tertiary),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  '${detail.instructorRating}/5 Danh gia',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Xem ho so giang vien',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: AppSpacing.xs),
                Icon(Icons.arrow_forward_rounded,
                    size: AppIconSize.sm, color: cs.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
