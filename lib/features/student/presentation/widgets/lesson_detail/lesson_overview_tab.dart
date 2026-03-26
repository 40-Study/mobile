import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/widgets/empty_state_card.dart';
import 'package:study/theme/app_colors.dart';

class LessonOverviewTab extends StatelessWidget {
  const LessonOverviewTab({super.key, required this.detail});
  final LessonDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasDescription = detail.description != null &&
        detail.description!.isNotEmpty;
    final hasObjectives = detail.objectives.isNotEmpty;
    final hasSections = detail.contentSections.isNotEmpty;

    if (!hasDescription && !hasObjectives && !hasSections) {
      return EmptyStateCard(
        icon: Icons.info_outline_rounded,
        message: 'Chua co thong tin tong quan cho bai hoc nay',
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.xxl,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      children: [
        if (hasDescription) ...[
          Text(
            'Gioi thieu',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: AppLayout.cardPadding,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              detail.description!,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xxl),
        ],

        if (hasObjectives) ...[
          Text(
            'Muc tieu bai hoc',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.md),
          ObjectivesGrid(objectives: detail.objectives),
          SizedBox(height: AppSpacing.xxl),
        ],

        if (hasSections) ...[
          Text(
            'Noi dung chinh',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.md),
          ...detail.contentSections.map(
            (section) => ContentSectionTile(section: section),
          ),
        ],
      ],
    );
  }
}

class ObjectivesGrid extends StatelessWidget {
  const ObjectivesGrid({super.key, required this.objectives});
  final List<LessonObjective> objectives;

  IconData _iconFor(String? icon) {
    switch (icon) {
      case 'cloud':
        return Icons.cloud_outlined;
      case 'compare':
        return Icons.compare_arrows_rounded;
      case 'pattern':
        return Icons.hub_rounded;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (objectives.length <= 2) {
      return Row(
        children: objectives
            .map((o) => Expanded(
                  child: _objectiveCard(cs, tt, o),
                ))
            .toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _objectiveCard(cs, tt, objectives[0])),
            SizedBox(width: AppSpacing.md),
            Expanded(child: _objectiveCard(cs, tt, objectives[1])),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        ...objectives.skip(2).map(
              (o) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _objectiveCard(cs, tt, o),
              ),
            ),
      ],
    );
  }

  Widget _objectiveCard(
      ColorScheme cs, TextTheme tt, LessonObjective obj) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceTintedPrimary,
        borderRadius: AppRadius.borderMd,
      ),
      child: Column(
        children: [
          Container(
            width: AppSpacing.xxxl + AppSpacing.xs,
            height: AppSpacing.xxxl + AppSpacing.xs,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(obj.icon),
              size: AppIconSize.md,
              color: cs.primary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            obj.title,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ContentSectionTile extends StatelessWidget {
  const ContentSectionTile({super.key, required this.section});
  final LessonContentSection section;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppIconSize.xl,
              height: AppIconSize.xl,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderXs,
              ),
              alignment: Alignment.center,
              child: Text(
                '${section.order}'.padLeft(2, '0'),
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (section.subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      section.subtitle!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
