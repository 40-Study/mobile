import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class AddSectionTile extends StatelessWidget {
  const AddSectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.borderSm,
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(title, style: tt.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
    );
  }
}
