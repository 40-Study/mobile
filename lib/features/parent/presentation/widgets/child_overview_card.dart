import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

class ChildOverviewCard extends StatelessWidget {
  const ChildOverviewCard({
    super.key,
    required this.child,
    this.overview,
    this.onTap,
  });

  final ChildModel child;
  final ChildOverviewModel? overview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = overview?.progressPercent ?? child.progressPercent;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderCard,
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(name: child.fullName, avatarUrl: child.avatarUrl),
                    AppSpacing.hGap12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.fullName,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (child.className != null)
                            Text(
                              child.className!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap16,
                // Progress
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 6,
                          backgroundColor: cs.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    AppSpacing.hGap12,
                    Text(
                      '${progress.toStringAsFixed(0)}%',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vGap12,
                // Stats row
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.school_outlined,
                      label: '${child.enrolledCourses} khóa',
                    ),
                    AppSpacing.hGap8,
                    _StatChip(
                      icon: Icons.check_circle_outline,
                      label: 'Hoàn thành',
                      color: progress >= 80 ? TogetherSemanticColors.success : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        shape: BoxShape.circle,
        boxShadow: AppShadows.sm,
      ),
      child: avatarUrl != null
          ? ClipOval(
              child: Image.network(avatarUrl!, fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: tt.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final chipColor = color ?? cs.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          AppSpacing.hGap4,
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: chipColor),
          ),
        ],
      ),
    );
  }
}
