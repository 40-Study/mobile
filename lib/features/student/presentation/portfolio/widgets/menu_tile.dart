import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
    );
  }
}
