import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_explore_data.dart';
import 'package:study/features/student/presentation/screens/course_preview_screen.dart';
import 'package:study/features/weather/weather.dart';

class ExploreTrendingCourseCard extends StatelessWidget {
  const ExploreTrendingCourseCard({
    super.key,
    required this.course,
  });
  final MockTrendingCourse course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CoursePreviewScreen(
            title: course.title,
            price: course.price,
            rating: course.rating,
            gradient: course.gradient,
            icon: course.icon,
            instructorName: course.instructorName,
          ),
        ),
      ),
      child: SizedBox(
        width: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderLg,
                gradient: LinearGradient(
                  colors: course.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: course.gradient.last
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: Icon(
                      course.icon,
                      size: 80,
                      color: Colors.white
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  Padding(
                    padding: AppLayout.cardPaddingCompact,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Text(
                          course.title,
                          style: tt.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
              builder: (context, state) {
                return Row(
                  children: [
                    Text(
                      course.price,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.star_rounded,
                        size: AppIconSize.sm,
                        color: cs.tertiary),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '${course.rating}',
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.weatherTextColorThemed,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
