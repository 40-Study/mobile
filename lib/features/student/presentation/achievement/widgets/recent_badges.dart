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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.recentBadges,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.slate900,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AllAchievementsScreen(badges: badges),
                ),
              ),
              child: Text(
                l10n.viewAll,
                style: tt.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vGap12,
        if (badges.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : cs.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.military_tech_rounded,
                    color: Color(0xFFD97706),
                    size: 24,
                  ),
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chưa mở khóa huy hiệu nào',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hoàn thành bài học để rinh về huy hiệu đầu tiên!',
                        style: tt.bodySmall?.copyWith(
                          color: cs.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
