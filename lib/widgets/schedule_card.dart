import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/theme/app_colors.dart';

enum ScheduleCardStyle { agenda, compact }

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.timeLabel,
    required this.title,
    this.timeSuffix,
    this.subtitle,
    this.location,
    this.footer,
    this.trailing,
    this.accentColor,
    this.isLive = false,
    this.isUpcoming = false,
    this.style = ScheduleCardStyle.agenda,
    this.onTap,
  });

  final String timeLabel;
  final String title;
  final String? timeSuffix;
  final String? subtitle;
  final String? location;
  final Widget? footer;
  final Widget? trailing;
  final Color? accentColor;
  final bool isLive;
  final bool isUpcoming;
  final ScheduleCardStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final borderColor =
        accentColor ??
        (isLive
            ? cs.primary
            : isUpcoming
            ? cs.primary
            : cs.outlineVariant);

    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: borderColor.withValues(
            alpha: isLive || isUpcoming ? 0.5 : 0.3,
          ),
          width: isLive || isUpcoming ? 1.5 : 1,
        ),
        boxShadow: cs.shadowCard,
      ),
      child: style == ScheduleCardStyle.compact
          ? _CompactLayout(
              timeLabel: timeLabel,
              title: title,
              subtitle: subtitle,
              location: location,
              footer: footer,
              trailing: trailing,
              accentColor: accentColor ?? cs.primary,
              isLive: isLive,
              isUpcoming: isUpcoming,
              tt: tt,
            )
          : _AgendaLayout(
              timeLabel: timeLabel,
              timeSuffix: timeSuffix,
              title: title,
              subtitle: subtitle,
              location: location,
              footer: footer,
              trailing: trailing,
              accentColor: accentColor ?? cs.primary,
              isLive: isLive,
              isUpcoming: isUpcoming,
              tt: tt,
            ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class _AgendaLayout extends StatelessWidget {
  const _AgendaLayout({
    required this.timeLabel,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.footer,
    required this.trailing,
    required this.accentColor,
    required this.isLive,
    required this.isUpcoming,
    required this.tt,
    this.timeSuffix,
  });

  final String timeLabel;
  final String? timeSuffix;
  final String title;
  final String? subtitle;
  final String? location;
  final Widget? footer;
  final Widget? trailing;
  final Color accentColor;
  final bool isLive;
  final bool isUpcoming;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = isLive
        ? cs.error
        : isUpcoming
        ? cs.primary
        : cs.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              timeLabel,
              style: tt.titleMedium?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (timeSuffix != null)
              Text(
                timeSuffix!,
                style: tt.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (isLive) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LIVE',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onError,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        Container(
          width: 1,
          height: 40,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: tt.bodyMedium?.copyWith(
                    color: statusColor.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (location != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location!,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (footer != null) ...[const SizedBox(height: 8), footer!],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.lg),
          trailing!,
        ],
      ],
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.timeLabel,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.footer,
    required this.trailing,
    required this.accentColor,
    required this.isLive,
    required this.isUpcoming,
    required this.tt,
  });

  final String timeLabel;
  final String title;
  final String? subtitle;
  final String? location;
  final Widget? footer;
  final Widget? trailing;
  final Color accentColor;
  final bool isLive;
  final bool isUpcoming;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColor = isLive
        ? cs.error
        : isUpcoming
        ? cs.primary
        : cs.onSurfaceVariant;

    return Row(
      children: [
        Container(
          width: 4,
          height: 54,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeLabel,
                style: tt.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (location != null) ...[
                const SizedBox(height: 2),
                Text(
                  location!,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (footer != null) ...[const SizedBox(height: 6), footer!],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}
