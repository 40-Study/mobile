import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/widgets/filter_sheet.dart';

// Re-export FilterSheet cho backward compatibility
export 'package:study/widgets/filter_sheet.dart';

/// Achievement filter - dùng FilterSheet
Future<({String status, String category})?> showAchievementFilterSheet(
  BuildContext context, {
  String initialStatus = 'all',
  String initialCategory = 'all',
}) {
  final l10n = AppLocalizations.of(context)!;
  return FilterSheet.show(
    context,
    statusOptions: {
      'all': l10n.all,
      'earned': l10n.earned,
      'inProgress': l10n.inProgress,
      'locked': l10n.notEarned,
    },
    categoryOptions: {
      'all': l10n.all,
      'learning': l10n.learning,
      'habit': l10n.habit,
      'achievement': l10n.achievement,
    },
    initialStatus: initialStatus,
    initialCategory: initialCategory,
  );
}

// ponytail: giữ FilterOption export cho code cũ dùng, remove khi cleanup xong
/// @Deprecated('Use FilterSheet instead')
class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FilterSheet(
      statusOptions: {
        'all': l10n.all,
        'earned': l10n.earned,
        'inProgress': l10n.inProgress,
        'locked': l10n.notEarned,
      },
      categoryOptions: {
        'all': l10n.all,
        'learning': l10n.learning,
        'habit': l10n.habit,
        'achievement': l10n.achievement,
      },
    );
  }
}

// Giữ FilterOption cho CertificateFilterSheet import
class FilterOption extends StatelessWidget {
  const FilterOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // ponytail: delegate to _FilterChip in filter_sheet.dart when cleanup
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 16, color: cs.onPrimary),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: tt.labelMedium
                    ?.copyWith(color: isSelected ? cs.onPrimary : cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
