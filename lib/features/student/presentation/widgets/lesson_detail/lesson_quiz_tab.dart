import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/features/student/presentation/widgets/empty_state_card.dart';

class LessonQuizTab extends StatelessWidget {
  const LessonQuizTab({super.key, required this.detail});
  final LessonDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (!detail.hasQuiz) {
      return EmptyStateCard(
        icon: Icons.quiz_outlined,
        message: 'Bai hoc nay khong co quiz',
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
        Text(
          detail.title,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: Text(
                'LICH SU LAM BAI',
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: cs.gradientPrimary,
                borderRadius: AppRadius.borderXxl,
                boxShadow: cs.shadowPrimary,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: AppRadius.borderXxl,
                child: InkWell(
                  onTap: () {},
                  borderRadius: AppRadius.borderXxl,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded,
                            size: AppIconSize.sm, color: cs.onPrimary),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Lam Quiz moi',
                          style: tt.labelMedium?.copyWith(
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
          ],
        ),

        SizedBox(height: AppSpacing.lg),

        if (detail.quizAttempts.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
            child: EmptyStateCard(
              icon: Icons.quiz_outlined,
              message: 'Ban chua lam quiz nao',
            ),
          )
        else
          ...detail.quizAttempts.map(
            (attempt) => QuizAttemptCard(attempt: attempt),
          ),
      ],
    );
  }
}

class QuizAttemptCard extends StatelessWidget {
  const QuizAttemptCard({super.key, required this.attempt});
  final QuizAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted = attempt.status == QuizStatus.completed;
    final cardColor = isCompleted
        ? cs.surfaceTintedPrimary
        : cs.surfaceTintedTertiary;
    final statusColor = isCompleted ? cs.primary : cs.tertiary;
    final statusLabel = isCompleted ? 'HOAN THANH' : 'DA LUU';

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: AppLayout.cardPadding,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: statusColor.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: AppRadius.borderXs,
              ),
              child: Text(
                statusLabel,
                style: tt.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lan lam bai #${attempt.attemptNumber}',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: AppIconSize.xs,
                              color: cs.onSurfaceVariant),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            attempt.date ?? '',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${attempt.score}',
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: '/${attempt.totalScore}',
                            style: tt.titleSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Diem so',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem chi tiet',
                    style: tt.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xxs),
                  Icon(Icons.arrow_forward_rounded,
                      size: AppIconSize.sm, color: cs.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
