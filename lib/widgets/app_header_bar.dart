import 'package:flutter/material.dart';

class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingAvatarUrl,
    this.showLeadingAvatar = false,
    this.showBackButton = false,
    this.showSearch = false,
    this.showNotification = true,
    this.actions,
    this.onNotificationTap,
    this.backgroundColor,
    this.leadingBackgroundColor,
  });

  final String title;
  final String? subtitle;
  final String? leadingAvatarUrl;
  final bool showLeadingAvatar;
  final bool showBackButton;
  final bool showSearch;
  final bool showNotification;
  final List<Widget>? actions;
  final VoidCallback? onNotificationTap;
  final Color? backgroundColor;
  final Color? leadingBackgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final titleColor = cs.onSurface;
    final subtitleColor = cs.onSurface.withValues(alpha: 0.6);
    final leadingBg = leadingBackgroundColor ?? cs.surfaceContainerHighest;

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: showBackButton || showLeadingAvatar ? 56 : null,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: titleColor),
              onPressed: () => Navigator.of(context).pop(),
            )
          : showLeadingAvatar
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: leadingBg,
                backgroundImage: leadingAvatarUrl != null
                    ? NetworkImage(leadingAvatarUrl!)
                    : null,
                child: leadingAvatarUrl == null
                    ? Icon(Icons.person, color: titleColor, size: 20)
                    : null,
              ),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: tt.bodySmall?.copyWith(color: subtitleColor),
            ),
        ],
      ),
      actions: [
        if (showSearch)
          IconButton(
            icon: Icon(Icons.search, color: titleColor),
            onPressed: () {},
          ),
        if (showNotification)
          IconButton(
            icon: Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_outlined, color: titleColor),
            ),
            onPressed: onNotificationTap,
          ),
        ...?actions,
        const SizedBox(width: 8),
      ],
    );
  }
}
