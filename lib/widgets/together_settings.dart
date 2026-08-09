import 'package:flutter/material.dart';

/// Together AI Design - Unified Settings Components
/// Sharp radius (4px, 8px), dark-blue shadows, clean typography

/// Settings section with title and grouped items
class TogetherSettingsSection extends StatelessWidget {
  const TogetherSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8), // Together AI comfortable radius
            border: Border.all(
              color: cs.outline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF010120).withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _buildChildren(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren() {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Builder(
          builder: (context) {
            final cs = Theme.of(context).colorScheme;
            return Divider(
              height: 1,
              indent: 56,
              color: cs.outline.withValues(alpha: 0.5),
            );
          },
        ));
      }
    }
    return result;
  }
}

/// Settings item tile
class TogetherSettingsTile extends StatelessWidget {
  const TogetherSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveIconColor = iconColor ?? cs.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? cs.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Toggle settings tile with switch
class TogetherSettingsToggle extends StatelessWidget {
  const TogetherSettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final effectiveIconColor = iconColor ?? cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: cs.primary,
          ),
        ],
      ),
    );
  }
}

/// User profile header for settings
class TogetherProfileHeader extends StatelessWidget {
  const TogetherProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role,
    this.onEditTap,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final String? role;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF010120).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(cs),
                    ),
                  )
                : _buildDefaultAvatar(cs),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (role != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      role!,
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onEditTap != null)
            IconButton(
              onPressed: onEditTap,
              icon: Icon(
                Icons.edit_outlined,
                color: cs.primary,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: cs.primaryContainer.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ColorScheme cs) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: cs.primary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Danger zone section (logout, delete account)
class TogetherDangerSection extends StatelessWidget {
  const TogetherDangerSection({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cs.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: _buildChildren(),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Builder(
          builder: (context) {
            final cs = Theme.of(context).colorScheme;
            return Divider(
              height: 1,
              indent: 56,
              color: cs.error.withValues(alpha: 0.15),
            );
          },
        ));
      }
    }
    return result;
  }
}
