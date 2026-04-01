import 'package:flutter/material.dart';
import 'package:study/features/weather/presentation/widgets/weather_content_overlay.dart';

class TeacherAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TeacherAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.showSearch = false,
    this.showNotification = true,
    this.actions,
    this.onNotificationTap,
  });

  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final bool showSearch;
  final bool showNotification;
  final List<Widget>? actions;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = context.weatherTextColor;
    final secondaryColor = context.weatherTextColorSecondary;
    final iconBgColor = context.weatherIconBackgroundColor;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: iconBgColor,
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Icon(Icons.person, color: textColor, size: 20)
              : null,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              children: [
                const TextSpan(text: 'Chào '),
                TextSpan(
                  text: title,
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: secondaryColor,
              ),
            ),
        ],
      ),
      actions: [
        if (showSearch)
          IconButton(
            icon: Icon(Icons.search, color: textColor),
            onPressed: () {},
          ),
        if (showNotification)
          IconButton(
            icon: Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_outlined, color: textColor),
            ),
            onPressed: onNotificationTap,
          ),
        ...?actions,
        const SizedBox(width: 8),
      ],
    );
  }
}
