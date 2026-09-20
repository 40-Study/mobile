import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/theme.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, this.onTap});

  final ParentAlertModel alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (icon, color) = switch (alert.severity) {
      AlertSeverity.critical => (Icons.error_rounded, TogetherSemanticColors.error),
      AlertSeverity.warning => (Icons.warning_rounded, TogetherSemanticColors.warning),
      AlertSeverity.info => (Icons.info_rounded, TogetherSemanticColors.info),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderCard,
          boxShadow: AppShadows.sm,
        ),
        child: Material(
          color: cs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderCard,
            side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, size: 20, color: color),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.message,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGap4,
                        Text(
                          alert.childName,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hGap8,
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
