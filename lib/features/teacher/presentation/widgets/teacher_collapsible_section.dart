import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Section có thể thu gọn/mở rộng với animation.
/// Dùng cho các nhóm content như "Cần xử lý", session groups, report sections.
class TeacherCollapsibleSection extends StatefulWidget {
  const TeacherCollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.initiallyExpanded = true,
    this.onExpansionChanged,
    this.headerPadding,
    this.childPadding,
    this.headerColor,
    this.icon,
    this.iconColor,
    this.badge,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? childPadding;
  final Color? headerColor;
  final IconData? icon;
  final Color? iconColor;
  final Widget? badge;

  @override
  State<TeacherCollapsibleSection> createState() =>
      _TeacherCollapsibleSectionState();
}

class _TeacherCollapsibleSectionState extends State<TeacherCollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header - tap để toggle
        Material(
          color: widget.headerColor ?? Colors.transparent,
          borderRadius: AppRadius.borderMd,
          child: InkWell(
            onTap: _toggle,
            borderRadius: AppRadius.borderMd,
            child: Padding(
              padding: widget.headerPadding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.iconColor ?? cs.primary,
                    ),
                    AppSpacing.hGap8,
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.badge != null) ...[
                              AppSpacing.hGap8,
                              widget.badge!,
                            ],
                          ],
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    widget.trailing!,
                    AppSpacing.hGap8,
                  ],
                  RotationTransition(
                    turns: _iconTurns,
                    child: Icon(
                      Icons.expand_more,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Content với animation
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
              _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: widget.childPadding ?? EdgeInsets.zero,
            child: widget.child,
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Card collapsible với styling sẵn - dùng cho NeedsAttention, status groups
class TeacherCollapsibleCard extends StatelessWidget {
  const TeacherCollapsibleCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.badgeCount,
    this.badgeColor,
    this.initiallyExpanded = true,
    this.onExpansionChanged,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;
  final int? badgeCount;
  final Color? badgeColor;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF010120).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TeacherCollapsibleSection(
        title: title,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        initiallyExpanded: initiallyExpanded,
        onExpansionChanged: onExpansionChanged,
        headerPadding: AppSpacing.paddingMd,
        childPadding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        badge: badgeCount != null && badgeCount! > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AchievementColors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: tt.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
        child: child,
      ),
    );
  }
}
