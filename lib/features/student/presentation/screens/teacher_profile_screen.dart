import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_cubit.dart';
import 'package:study/features/student/data/models/teacher_course_item.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/course_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({
    super.key,
    required this.instructorName,
    this.instructorAvatar,
    this.instructorTitle,
    this.instructorBio,
    this.instructorStudentCount = 0,
    this.instructorRating = 0.0,
    this.instructorCourseCount = 0,
    this.skills = const [],
    this.featuredCourses = const [],
  });

  final String instructorName;
  final String? instructorAvatar;
  final String? instructorTitle;
  final String? instructorBio;
  final int instructorStudentCount;
  final double instructorRating;
  final int instructorCourseCount;
  final List<String> skills;
  final List<TeacherCourseItem> featuredCourses;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Teacher Profile',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: cs.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.lg,
          AppLayout.screenMargin,
          AppSpacing.massive,
        ),
        children: [
          _AvatarSection(
            name: instructorName,
            avatar: instructorAvatar,
            title: instructorTitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (skills.isNotEmpty) ...[
            _SkillChips(skills: skills),
            const SizedBox(height: AppSpacing.xxl),
          ],
          _StatsRow(
            studentCount: instructorStudentCount,
            courseCount: instructorCourseCount,
            rating: instructorRating,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          if (instructorBio != null &&
              instructorBio!.isNotEmpty) ...[
            _AboutSection(bio: instructorBio!),
            const SizedBox(height: AppSpacing.xxxl),
          ],
          if (featuredCourses.isNotEmpty)
            _FeaturedCoursesSection(
                courses: featuredCourses),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.name,
    this.avatar,
    this.title,
  });

  final String name;
  final String? avatar;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: cs.primary, width: 3),
            boxShadow: cs.shadowPrimary,
          ),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: cs.surfaceTintedPrimary,
            backgroundImage: avatar != null
                ? NetworkImage(avatar!)
                : null,
            child: avatar == null
                ? Icon(Icons.person_rounded,
                    size: AppIconSize.hero,
                    color: cs.primary)
                : null,
          ),
        ),
        Icon(Icons.verified, size: 22, color: cs.primary),
        const SizedBox(height: AppSpacing.md),
        Text(
          name,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        if (title != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            title!,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _SkillChips extends StatelessWidget {
  const _SkillChips({required this.skills});
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: AppRadius.borderXxl,
            border: Border.all(color: cs.outline),
          ),
          child: Text(
            skill,
            style: tt.labelMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.studentCount,
    required this.courseCount,
    required this.rating,
  });

  final int studentCount;
  final int courseCount;
  final double rating;

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: cs.outline),
        boxShadow: cs.shadowCard,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              value: _formatCount(studentCount),
              label: 'STUDENTS',
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: cs.outlineVariant,
          ),
          Expanded(
            child: _StatColumn(
              value: '$courseCount',
              label: 'COURSES',
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: cs.outlineVariant,
          ),
          Expanded(
            child: _StatColumn(
              value: '$rating',
              label: 'RATING',
              trailing: Icon(Icons.star_rounded,
                  size: AppIconSize.sm,
                  color: cs.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    this.trailing,
  });

  final String value;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.xxs),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.bio});
  final String bio;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: AppRadius.borderXs,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'About Me',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          bio,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _FeaturedCoursesSection extends StatelessWidget {
  const _FeaturedCoursesSection({required this.courses});
  final List<TeacherCourseItem> courses;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: AppRadius.borderXs,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Featured Courses',
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'View All',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ...courses.map((course) => Padding(
              padding: const EdgeInsets.only(
                  bottom: AppSpacing.md),
              child:
                  _FeaturedCourseCard(course: course),
            )),
      ],
    );
  }
}

class _FeaturedCourseCard extends StatelessWidget {
  const _FeaturedCourseCard({required this.course});
  final TeacherCourseItem course;

  void _openCourseDetail(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: BlocProvider(
            create: (_) => CourseDetailCubit(
              repository: repository,
              enrollmentId: course.id,
              courseId: course.id,
            ),
            child: CourseDetailScreen(
              enrollmentId: course.id,
              courseId: course.id,
              courseTitle: course.title,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _openCourseDetail(context),
      child: Container(
        padding: AppLayout.cardPaddingCompact,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: cs.outline),
          boxShadow: cs.shadowCard,
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceTintedPrimary,
                borderRadius: AppRadius.borderMd,
                image: course.thumbnail != null
                    ? DecorationImage(
                        image: NetworkImage(
                            course.thumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: course.thumbnail == null
                  ? Icon(
                      Icons
                          .play_circle_filled_rounded,
                      size: AppIconSize.xxl,
                      color: cs.primary,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (course.duration != null) ...[
                    const SizedBox(
                        height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: AppIconSize.xs,
                          color:
                              cs.onSurfaceVariant,
                        ),
                        const SizedBox(
                            width: AppSpacing.xs),
                        Text(
                          course.duration!,
                          style: tt.labelSmall
                              ?.copyWith(
                            color:
                                cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(
                      height: AppSpacing.sm),
                  Row(
                    children: [
                      if (course.price != null)
                        Text(
                          course.price!,
                          style:
                              tt.titleSmall?.copyWith(
                            fontWeight:
                                FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color:
                              cs.surfaceTintedPrimary,
                          borderRadius:
                              AppRadius.borderSm,
                        ),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: AppIconSize.xs,
                              color: cs.tertiary,
                            ),
                            const SizedBox(
                              width: AppSpacing.xxs,
                            ),
                            Text(
                              '${course.rating}',
                              style: tt.labelSmall
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
