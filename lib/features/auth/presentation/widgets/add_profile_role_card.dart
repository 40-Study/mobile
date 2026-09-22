import 'package:flutter/material.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';

class AddProfileRoleCard extends StatelessWidget {
  const AddProfileRoleCard({super.key, required this.role, required this.onTap});

  final RoleModel role;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primaryContainer,
                      cs.primaryContainer.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  RoleUtils.getIcon(role.name),
                  color: cs.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      RoleUtils.getLabel(role.name),
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRoleDescription(role.name),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleDescription(String roleName) {
    switch (roleName.toUpperCase()) {
      case 'STUDENT':
        return 'Hoc vien - Tham gia khoa hoc va lam bai tap';
      case 'TEACHER':
        return 'Giang vien - Tao va quan ly khoa hoc';
      case 'PARENT':
        return 'Phu huynh - Theo doi tien do hoc tap';
      case 'ORG_OWNER':
        return 'Chu to chuc - Quan ly to chuc giao duc';
      default:
        return 'Vai tro he thong';
    }
  }
}
