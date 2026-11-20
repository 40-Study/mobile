import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/theme/theme.dart';

class TeacherNextSessionCard extends StatelessWidget {
  const TeacherNextSessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  final TeacherOccurrence session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final date =
        '${session.date.day.toString().padLeft(2, '0')}/'
        '${session.date.month.toString().padLeft(2, '0')}/${session.date.year}';
    return Material(
      color: cs.primary,
      borderRadius: AppRadius.borderLg,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: cs.onPrimary,
                ),
                AppSpacing.hGap8,
                Expanded(
                  child: Text(
                    date,
                    style: tt.labelLarge?.copyWith(color: cs.onPrimary),
                  ),
                ),
              ],
            ),
            AppSpacing.vGap16,
            LayoutBuilder(
              builder: (context, constraints) {
                final largeText =
                    MediaQuery.textScalerOf(context).scale(14) > 20;
                return Text(
                  '${session.start}–${session.end}',
                  style: (largeText ? tt.headlineSmall : tt.headlineLarge)
                      ?.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                );
              },
            ),
            AppSpacing.vGap8,
            Text(
              session.classData.name,
              style: tt.titleLarge?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (session.topic.isNotEmpty) ...[
              AppSpacing.vGap8,
              Text(
                session.topic,
                style: tt.bodyMedium?.copyWith(color: cs.onPrimary),
              ),
            ],
            AppSpacing.vGap16,
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withValues(alpha: .12),
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(
                    color: cs.onPrimary.withValues(alpha: .28),
                  ),
                ),
                child: Text(
                  session.projected
                      ? 'Dự kiến · chưa tạo buổi học'
                      : teacherStatus(session.status),
                  style: tt.labelMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            AppSpacing.vGap24,
            FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: cs.surface,
                foregroundColor: cs.onSurface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              iconAlignment: IconAlignment.end,
              label: const Text('Xem buổi học'),
            ),
          ],
        ),
      ),
    );
  }
}
