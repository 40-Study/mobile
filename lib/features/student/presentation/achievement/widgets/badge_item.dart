import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/badge_model.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class BadgeItem extends StatelessWidget {
  const BadgeItem({
    super.key,
    required this.badge,
    this.isNew = false,
    required this.colorIndex,
  });

  final BadgeModel badge;
  final bool isNew;
  final int colorIndex;

  static const badgeConfigs = [
    (color: AchievementColors.purple, icon: Icons.menu_book_rounded),
    (color: AchievementColors.deepOrange, icon: Icons.star_rounded),
    (color: AchievementColors.teal, icon: Icons.track_changes_rounded),
    (color: AchievementColors.red, icon: Icons.local_fire_department_rounded),
    (color: AchievementColors.blue, icon: Icons.workspace_premium_rounded),
    (color: AchievementColors.green, icon: Icons.emoji_events_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final config = badgeConfigs[colorIndex % badgeConfigs.length];

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, config.color, config.icon),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: config.color, width: 2),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: config.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(config.icon, size: 28, color: Colors.white),
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: cs.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 2),
                      ),
                      child: const Icon(Icons.add, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            AppSpacing.vGap8,
            Text(badge.name,
                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(badge.description ?? '',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (badge.earnedAt != null)
              Text(_formatDate(badge.earnedAt!),
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, Color color, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 44, color: Colors.white),
                ),
              ),
              AppSpacing.vGap16,
              Text(badge.name,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center),
              AppSpacing.vGap8,
              Text(badge.description ?? 'Chưa có mô tả',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center),
              if (badge.earnedAt != null) ...[
                AppSpacing.vGap16,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text('${l10n.earned}: ${_formatDate(badge.earnedAt!)}',
                      style: tt.labelMedium?.copyWith(color: cs.primary)),
                ),
              ],
              AppSpacing.vGap24,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
