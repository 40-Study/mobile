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
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: cs.blue600,
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
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.slate900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$eventCount ngày có lịch học',
                style: tt.bodySmall?.copyWith(
                  color: cs.slate500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
