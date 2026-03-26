import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/widgets/schedule/schedule_card.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.schedules,
    required this.onTap,
  });

  final List<StudentScheduleModel> schedules;
  final void Function(StudentScheduleModel) onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        0,
        AppLayout.screenMargin,
        AppSpacing.massive,
      ),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final isLast = index == schedules.length - 1;
        final isLive = schedule.isLive;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isLive
                            ? cs.primary
                            : cs.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLive
                              ? cs.primary
                              : cs.outline,
                          width: 2.5,
                        ),
                        boxShadow: isLive
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: cs.outline,
                            borderRadius: AppRadius.borderXs,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: ScheduleCard(
                    schedule: schedule,
                    onTap: () => onTap(schedule),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
