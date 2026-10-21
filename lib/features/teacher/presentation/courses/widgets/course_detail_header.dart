import 'package:flutter/material.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/theme/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../course_status_badge.dart';

class CourseDetailHeader extends StatelessWidget {
  const CourseDetailHeader({super.key, required this.course});
  final Map<String, dynamic> course;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), cs = Theme.of(context).colorScheme;
    final status = '${course['status'] ?? ''}';
    final description =
        '${course['short_description'] ?? course['description'] ?? ''}'.trim();
    final price = num.tryParse('${course['price']}');
    final facts = <(IconData, String)>[
      if (course['total_lessons'] != null)
        (Icons.menu_book_outlined, '${course['total_lessons']} bài học'),
      if (course['total_students'] != null)
        (Icons.people_outline, '${course['total_students']} học viên'),
      if (course['is_free'] == true)
        (Icons.sell_outlined, 'Miễn phí')
      else if (price != null && price.isFinite)
        (
          Icons.sell_outlined,
          '${NumberFormat.decimalPattern('vi').format(price)} ₫',
        ),
    ];
    return TeacherSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CourseCover(course: course),
          Padding(
            padding: AppSpacing.paddingXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CourseStatusBadge(status: status),
                AppSpacing.vGap12,
                Text(
                  '${course['title'] ?? 'Khóa học'}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  AppSpacing.vGap8,
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                if (facts.isNotEmpty) ...[
                  const Divider(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.md,
                    children: [
                      for (final fact in facts)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(fact.$1, size: 18, color: cs.primary),
                            AppSpacing.hGap4,
                            Flexible(
                              child: Text(
                                fact.$2,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCover extends StatelessWidget {
  const _CourseCover({required this.course});
  final Map<String, dynamic> course;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget fallback() => ColoredBox(
      color: cs.primaryContainer,
      child: Center(
        child: Icon(
          Icons.auto_stories_outlined,
          color: cs.onPrimaryContainer,
          size: 48,
        ),
      ),
    );
    final asset = course['thumbnail_asset']?.toString();
    final url = course['thumbnail_url']?.toString();
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: asset != null && asset.isNotEmpty
          ? Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback(),
            )
          : url != null && url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => fallback(),
              placeholder: (_, _) => fallback(),
            )
          : fallback(),
    );
  }
}
