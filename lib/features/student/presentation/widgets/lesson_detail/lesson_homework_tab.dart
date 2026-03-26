import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/features/student/presentation/widgets/empty_state_card.dart';
import 'package:study/features/student/presentation/widgets/material_tile.dart';

class LessonHomeworkTab extends StatelessWidget {
  const LessonHomeworkTab({super.key, required this.detail});
  final LessonDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hw = detail.homework;

    if (hw == null) {
      return EmptyStateCard(
        icon: Icons.assignment_outlined,
        message: 'Chua co bai tap cho bai hoc nay',
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: AppSpacing.xxxl + AppSpacing.xs,
              height: AppSpacing.xxxl + AppSpacing.xs,
              decoration: BoxDecoration(
                gradient: cs.gradientPrimary,
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(Icons.assignment_rounded,
                  color: cs.onPrimary, size: AppIconSize.md),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hw.title,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hw.deadline != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Han chot: ${hw.deadline}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.xl),

        Container(
          padding: AppLayout.cardPadding,
          decoration: BoxDecoration(
            color: cs.surfaceTintedPrimary,
            borderRadius: AppRadius.borderMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MO TA NHIEM VU',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              if (hw.description != null) ...[
                Text(
                  hw.description!,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],
              ...hw.requirements.map(
                (req) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ',
                          style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700)),
                      Expanded(
                        child: Text(
                          req,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hw.note != null) ...[
                SizedBox(height: AppSpacing.md),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer.withValues(alpha: 0.2),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    hw.note!,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        if (hw.attachments.isNotEmpty) ...[
          SizedBox(height: AppSpacing.xxl),
          Text(
            'File dinh kem (${hw.attachments.length})',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: AppSpacing.md),
          ...hw.attachments.map(
            (att) => MaterialTile(material: att),
          ),
        ],

        SizedBox(height: AppSpacing.xxl),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: cs.gradientPrimary,
            borderRadius: AppRadius.borderMd,
            boxShadow: cs.shadowPrimary,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.borderMd,
            child: InkWell(
              onTap: () {},
              borderRadius: AppRadius.borderMd,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_rounded,
                        color: cs.onPrimary, size: AppIconSize.lg),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Nop bai tap ngay',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Bang cach nhan nop bai, ban xac nhan rang day la san '
          'pham tri tue cua rieng ban.',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
