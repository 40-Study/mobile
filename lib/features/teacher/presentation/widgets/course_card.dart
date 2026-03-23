import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/models/models.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.onEditTap,
    this.onMoreTap,
  });

  final CourseModel course;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: course.thumbnailUrl != null
                        ? DecorationImage(
                            image: NetworkImage(course.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: course.thumbnailUrl == null
                      ? Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: cs.onSurfaceVariant,
                        )
                      : null,
                ),
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: _StatusBadge(status: course.status),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.displayTitle,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        course.studentCount > 0
                            ? '${course.studentCount} học viên'
                            : 'Chưa có học viên',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      if (course.rating > 0) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toStringAsFixed(1),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (course.isPublished)
                        TextButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Quản lý khóa học'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      else
                        TextButton.icon(
                          onPressed: onEditTap,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Tiếp tục chỉnh sửa'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      const Spacer(),
                      if (course.isPublished)
                        IconButton(
                          onPressed: onEditTap,
                          icon: const Icon(Icons.edit_outlined),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                        ),
                      IconButton(
                        onPressed: onMoreTap,
                        icon: const Icon(Icons.more_horiz),
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'published':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'ĐANG BÁN';
      case 'archived':
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = 'LƯU TRỮ';
      default:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'BẢN NHÁP';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
