import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/features/student/presentation/search/search_screen.dart';
import 'package:study/theme/theme.dart';

class TabScreenHeader extends StatelessWidget {
  const TabScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showSearch = true,
    this.showNotification = true,
    this.onMenuTap,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showSearch;
  final bool showNotification;
  final VoidCallback? onMenuTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onMenuTap != null) ...[
            _HeaderIconButton(
              icon: Icons.menu_rounded,
              onPressed: onMenuTap!,
            ),
            AppSpacing.hGap12,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showSearch) ...[
            _HeaderIconButton(
              icon: Icons.search_rounded,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
              ),
            ),
            AppSpacing.hGap8,
          ],
          if (showNotification) ...[
            _HeaderIconButton(
              icon: Icons.notifications_outlined,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => const NotificationScreen()),
              ),
              showBadge: true,
            ),
            if (trailing != null) AppSpacing.hGap8,
          ],
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: showBadge
            ? Badge(
                smallSize: 8,
                backgroundColor: cs.error,
                child: Icon(icon, color: cs.onSurfaceVariant, size: 22),
              )
            : Icon(icon, color: cs.onSurfaceVariant, size: 22),
        constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      ),
    );
  }
}
