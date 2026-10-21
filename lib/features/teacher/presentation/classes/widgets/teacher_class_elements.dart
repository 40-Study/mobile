import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/theme/theme.dart';

class TeacherClassPanel extends StatelessWidget {
  const TeacherClassPanel(
    this.child, {
    super.key,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.borderLg,
      side: BorderSide(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: .8),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class TeacherClassStatus extends StatelessWidget {
  const TeacherClassStatus(this.text, {super.key, this.muted = false});
  final String text;
  final bool muted;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: muted
          ? Theme.of(context).colorScheme.surfaceContainerHigh
          : Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: AppRadius.borderFull,
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: muted
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    ),
  );
}

class TeacherClassEmpty extends StatelessWidget {
  const TeacherClassEmpty(this.icon, this.text, {super.key});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      AppSpacing.hGap12,
      Expanded(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

class TeacherClassAvatar extends StatelessWidget {
  const TeacherClassAvatar(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    child: Text(
      name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

String teacherClassDate(dynamic value) {
  final date = DateTime.tryParse('$value');
  return date == null
      ? '$value'
      : DateFormat('dd/MM/yyyy').format(date.toLocal());
}
