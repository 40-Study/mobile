import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class MonthSummary extends StatelessWidget {
  const MonthSummary({
    super.key,
    required this.eventCount,
    required this.currentMonth,
  });

  final int eventCount;
  final DateTime currentMonth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: cs.onPrimaryContainer,
            size: 22,
          ),
        ),
        AppSpacing.hGap12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tháng ${currentMonth.month}/${currentMonth.year}',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '$eventCount ngày có lịch',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
