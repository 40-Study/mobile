import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/theme/theme.dart';

class AddProfileExistingCard extends StatelessWidget {
  const AddProfileExistingCard({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              RoleUtils.getIcon(profile.roleName),
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ),
          AppSpacing.hGap12,
          Expanded(
            child: Text(
              RoleUtils.getLabel(profile.roleName),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: cs.tertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
