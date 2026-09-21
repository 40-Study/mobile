import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/badge_model.dart';
import 'package:study/features/student/presentation/achievement/all_achievements_screen.dart';
import 'package:study/features/student/presentation/achievement/widgets/badge_item.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class RecentBadges extends StatelessWidget {
  const RecentBadges({super.key, required this.badges});

  final List<BadgeModel> badges;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.recentBadges,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AllAchievementsScreen(badges: badges)),
              ),
              child: Text(l10n.viewAll,
                  style: tt.labelLarge
                      ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        AppSpacing.vGap16,
        if (badges.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                'Chưa có huy hiệu nào. Học tập để nhận huy hiệu!',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: badges.take(4).length,
              separatorBuilder: (_, _) => AppSpacing.hGap12,
              itemBuilder: (context, i) => BadgeItem(
                badge: badges[i],
                isNew: i == 0,
                colorIndex: i,
              ),
            ),
          ),
      ],
    );
  }
}
