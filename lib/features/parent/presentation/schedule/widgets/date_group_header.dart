import 'package:flutter/material.dart';

import 'package:study/theme/theme.dart';

/// Tiêu đề phân nhóm ngày cho danh sách ca học
/// (vd: • HÔM NAY, 21 THÁNG 9, 2026).
class DateGroupHeader extends StatelessWidget {
  const DateGroupHeader({
    super.key,
    required this.date,
    required this.sessionCount,
  });

  final DateTime date;
  final int sessionCount;

  static const _weekdayNames = [
    'THỨ HAI',
    'THỨ BA',
    'THỨ TƯ',
    'THỨ NĂM',
    'THỨ SÁU',
    'THỨ BẢY',
    'CHỦ NHẬT',
  ];

  String _formatHeaderTitle() {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow = _isSameDay(date, tomorrow);

    final String dayPrefix;
    if (isToday) {
      dayPrefix = 'HÔM NAY';
    } else if (isTomorrow) {
      dayPrefix = 'NGÀY MAI';
    } else {
      dayPrefix = _weekdayNames[date.weekday - 1];
    }

    return '• $dayPrefix, ${date.day} THÁNG ${date.month}, ${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tiêu đề ngày in hoa
          Expanded(
            child: Text(
              _formatHeaderTitle(),
              style: tt.labelLarge?.copyWith(
                color: cs.slate700,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Số ca học trong ngày
          Text(
            '$sessionCount ca học',
            style: tt.labelMedium?.copyWith(
              color: cs.slate500,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
