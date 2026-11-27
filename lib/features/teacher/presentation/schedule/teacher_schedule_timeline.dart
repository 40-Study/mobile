import 'package:flutter/material.dart';

import '../../data/teacher_core.dart';
import '../widgets/teacher_expandable_calendar.dart';
import 'teacher_session_row.dart';

DateTime? teacherScheduleTime(TeacherOccurrence session, String time) {
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(time);
  if (match == null) return null;
  final hour = int.parse(match[1]!);
  final minute = int.parse(match[2]!);
  if (hour > 23 || minute > 59) return null;
  return DateTime(
    session.date.year,
    session.date.month,
    session.date.day,
    hour,
    minute,
  );
}

String _durationLabel(int minutes) {
  final hours = minutes ~/ 60;
  final remainder = minutes % 60;
  if (hours == 0) return '$minutes phút';
  if (remainder == 0) return '$hours giờ';
  return '$hours giờ $remainder phút';
}

class TeacherScheduleTimeline extends StatelessWidget {
  const TeacherScheduleTimeline({
    super.key,
    required this.rows,
    required this.daySessions,
    required this.dotFor,
    required this.buildCard,
  });

  final List<TeacherOccurrence> rows;
  final List<TeacherOccurrence> daySessions;
  final TeacherCalendarDot Function(TeacherOccurrence) dotFor;
  final Widget Function(TeacherOccurrence session) buildCard;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFCBD5E1)
        : Theme.of(context).colorScheme.outlineVariant;
    final visible = rows.toSet();
    final hidden = daySessions
        .where((session) => !visible.contains(session))
        .toList();
    DateTime? latestEnd;
    final children = <Widget>[];

    for (var index = 0; index < rows.length; index++) {
      final session = rows[index];
      final start = teacherScheduleTime(session, session.start);
      final end = teacherScheduleTime(session, session.end);
      final previousEnd = latestEnd;
      if (start != null && previousEnd != null) {
        final gap = start.difference(previousEnd).inMinutes;
        if (gap >= 30 &&
            !hidden.any((row) {
              final hiddenStart = teacherScheduleTime(row, row.start);
              final hiddenEnd = teacherScheduleTime(row, row.end);
              return hiddenStart != null &&
                  hiddenEnd != null &&
                  hiddenStart.isBefore(start) &&
                  hiddenEnd.isAfter(previousEnd);
            })) {
          children.add(
            Stack(
              children: [
                Positioned(
                  left: 47.25,
                  top: 0,
                  bottom: 0,
                  width: 1.5,
                  child: ColoredBox(color: lineColor),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 2, 0, 8),
                  child: Text(
                    '··· Nghỉ ${_durationLabel(gap)} ···',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF94A3B8)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
      if (end != null && (previousEnd == null || end.isAfter(previousEnd))) {
        latestEnd = end;
      }

      final dot = dotFor(session);
      final hollow = dot == TeacherCalendarDot.upcoming;
      children.add(
        Stack(
          children: [
            if (rows.length > 1)
              Positioned(
                left: 47.25,
                width: 1.5,
                top: index == 0 ? 20 : 0,
                bottom: index == rows.length - 1 ? null : 0,
                height: index == rows.length - 1 ? 20 : null,
                child: ColoredBox(color: lineColor),
              ),
            Positioned(
              left: 44,
              top: 16,
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: hollow ? teacherScheduleCardColor(context) : dot.color,
                  border: hollow
                      ? Border.all(color: dot.color, width: 1.5)
                      : null,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 9, right: 3),
                      child: Column(
                        children: [
                          _TimeLabel(session.start, bold: true),
                          _TimeLabel(session.end),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: buildCard(session)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel(this.value, {this.bold = false});

  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        value.isEmpty ? '—' : value,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: bold ? null : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: bold ? FontWeight.w700 : null,
        ),
      ),
    ),
  );
}

class TeacherTimelineCard extends StatelessWidget {
  const TeacherTimelineCard({
    super.key,
    required this.session,
    required this.now,
    required this.dot,
    required this.onDetails,
    required this.onPreview,
    this.onAttendance,
    this.onJoin,
    this.heroLabel,
  });

  final TeacherOccurrence session;
  final DateTime now;
  final TeacherCalendarDot dot;
  final String? heroLabel;
  final VoidCallback onDetails;
  final VoidCallback onPreview;
  final VoidCallback? onAttendance;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hero = heroLabel != null;
    final completed = dot == TeacherCalendarDot.completed;
    final topic = session.topic.trim();
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: hero ? teacherScheduleBlue : teacherScheduleBorder(context),
        width: hero ? 1.5 : 1,
      ),
    );
    return Card(
      margin: EdgeInsets.zero,
      elevation: hero ? 2 : 0,
      color: teacherScheduleCardColor(context),
      surfaceTintColor: Colors.transparent,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetails,
        onLongPress: onPreview,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hero) ...[
                Text(
                  '● $heroLabel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.brightness == Brightness.light
                        ? teacherScheduleBlue
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (completed)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _className(theme)),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: TeacherSessionStatusLabel(
                        label: 'Hoàn thành',
                        status: 'completed',
                      ),
                    ),
                  ],
                )
              else
                _className(theme),
              if (topic.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  topic,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if ((!hero && !completed && dot != TeacherCalendarDot.upcoming) ||
                  session.projected ||
                  dot == TeacherCalendarDot.unmarked ||
                  session.json['hour_confirmation_status'] == 'needs_info') ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (!completed &&
                            !hero &&
                            dot != TeacherCalendarDot.upcoming ||
                        session.projected)
                      TeacherSessionStatusLabel(
                        label: teacherSessionStateLabel(session, now: now),
                        status: session.status,
                      ),
                    if (dot == TeacherCalendarDot.unmarked)
                      const TeacherSessionStatusLabel(
                        label: 'Chưa điểm danh',
                        status: 'unmarked',
                      ),
                    if (session.json['hour_confirmation_status'] ==
                        'needs_info')
                      const TeacherSessionStatusLabel(
                        label: 'Cần bổ sung',
                        status: 'needs_info',
                      ),
                  ],
                ),
              ],
              if (hero)
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (onAttendance != null)
                      FilledButton(
                        onPressed: onAttendance,
                        style: FilledButton.styleFrom(
                          backgroundColor: teacherScheduleBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Điểm danh ngay'),
                      ),
                    TextButton(
                      onPressed: onDetails,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Chi tiết'),
                          Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                    if (onJoin != null)
                      TextButton(
                        onPressed: onJoin,
                        child: const Text('Vào phòng'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _className(ThemeData theme) => Text(
    session.classData.name,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
  );
}
