import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/theme/theme.dart';
import '../course_status_badge.dart';

class TeacherCourseCard extends StatelessWidget {
  const TeacherCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });
  final Map<String, dynamic> course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme, tt = Theme.of(context).textTheme;
    final status = '${course['status'] ?? ''}';
    final price = num.tryParse('${course['price']}');
    final description =
        '${course['short_description'] ?? course['description'] ?? ''}'.trim();
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 20;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Material(
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CourseStatusBadge(status: status),
                    AppSpacing.vGap16,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.borderMd,
                          child: SizedBox(
                            width: largeText ? 56 : 88,
                            height: largeText ? 72 : 104,
                            child: _cover(cs),
                          ),
                        ),
                        AppSpacing.hGap16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${course['title'] ?? 'Khóa học'}',
                                style: tt.titleLarge?.copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                  height: 1.25,
                                ),
                              ),
                              if (description.isNotEmpty) ...[
                                AppSpacing.vGap8,
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGap16,
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.sm,
                      children: [
                        if (course['total_lessons'] != null)
                          _fact(
                            context,
                            Icons.menu_book_outlined,
                            '${course['total_lessons']} bài học',
                          ),
                        if (course['total_students'] != null)
                          _fact(
                            context,
                            Icons.people_outline,
                            '${course['total_students']} học viên',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (course['is_free'] == true || price != null)
                      Text(
                        course['is_free'] == true || price == 0
                            ? 'Miễn phí'
                            : '${NumberFormat.decimalPattern('vi').format(price)} ₫',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            ['draft', 'rejected'].contains(status)
                                ? 'Tiếp tục soạn'
                                : 'Quản lý khóa học',
                            style: tt.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AppSpacing.hGap8,
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: cs.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cover(ColorScheme cs) {
    final asset = course['thumbnail_asset']?.toString(),
        image = course['thumbnail_url']?.toString();
    if (asset != null && asset.startsWith('assets/'))
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(cs),
      );
    if (image != null && image.isNotEmpty)
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => _placeholder(cs),
      );
    return _placeholder(cs);
  }

  Widget _fact(BuildContext context, IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 17,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      AppSpacing.hGap8,
      Flexible(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );

  Widget _placeholder(ColorScheme cs) => ColoredBox(
    color: cs.primaryContainer,
    child: Icon(
      Icons.auto_stories_rounded,
      color: cs.onPrimaryContainer,
      size: 32,
    ),
  );
}
