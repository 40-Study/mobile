import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Base card component cho Teacher UI với design system nhất quán.
///
/// Variants:
/// - [TeacherCard.elevated] - shadow + border cho clickable items
/// - [TeacherCard.hero] - gradient background cho priority content
/// - [TeacherCard.flat] - no shadow cho inline content
class TeacherCard extends StatelessWidget {
  const TeacherCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.color,
    this.borderRadius,
  })  : _variant = _TeacherCardVariant.elevated,
        gradient = null;

  const TeacherCard.elevated({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.color,
    this.borderRadius,
  })  : _variant = _TeacherCardVariant.elevated,
        gradient = null;

  const TeacherCard.flat({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.color,
    this.borderRadius,
  })  : _variant = _TeacherCardVariant.flat,
        gradient = null;

  const TeacherCard.hero({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin,
    this.gradient,
    this.borderRadius,
  })  : _variant = _TeacherCardVariant.hero,
        color = null;

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final _TeacherCardVariant _variant;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final effectiveRadius = borderRadius ?? AppRadius.borderLg;

    final BoxDecoration decoration;
    switch (_variant) {
      case _TeacherCardVariant.elevated:
        decoration = BoxDecoration(
          color: color ?? cs.surfaceContainerLowest,
          borderRadius: effectiveRadius,
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
        );
      case _TeacherCardVariant.flat:
        decoration = BoxDecoration(
          color: color ?? cs.surfaceContainerLowest,
          borderRadius: effectiveRadius,
          border: Border.all(color: cs.outlineVariant),
        );
      case _TeacherCardVariant.hero:
        decoration = BoxDecoration(
          gradient: gradient ?? cs.gradientBluePrimary,
          borderRadius: effectiveRadius,
          boxShadow: AppShadows.layeredCard,
        );
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: decoration,
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

enum _TeacherCardVariant { elevated, flat, hero }
