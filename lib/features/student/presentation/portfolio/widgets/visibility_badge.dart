import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class VisibilityBadge extends StatelessWidget {
  const VisibilityBadge({super.key, required this.visibility});

  final String visibility;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    IconData icon;
    Color color;
    String text;

    switch (visibility) {
      case 'public':
        icon = Icons.public;
        color = AchievementColors.green;
        text = l10n.publicPortfolio;
        break;
      case 'link':
        icon = Icons.link;
        color = AchievementColors.blue;
        text = l10n.linkOnlyPortfolio;
        break;
      case 'private':
        icon = Icons.lock;
        color = cs.onSurfaceVariant;
        text = l10n.privatePortfolio;
        break;
      default:
        icon = Icons.public;
        color = AchievementColors.green;
        text = l10n.publicPortfolio;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
