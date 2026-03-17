import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';

/// Auth header with staggered entrance: icon scale, then title fade+slide,
/// then subtitle fade+slide. Entrance plays once only via AnimationCubit.
class AuthHeader extends StatefulWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconBackgroundColor,
    this.showBackButton = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _iconScale;
  Animation<double>? _titleOpacity;
  Animation<double>? _titleOffset;
  Animation<double>? _subtitleOpacity;
  Animation<double>? _subtitleOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;

    final cubit = context.read<AuthAnimationCubit>();
    if (!cubit.state.shouldAnimate) return;

    const staggerMs = 60;
    const entranceMs = 350;
    const totalMs = entranceMs + staggerMs * 2;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: totalMs),
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(
          0.0,
          entranceMs / totalMs,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    final titleStart = staggerMs / totalMs;
    final titleEnd = (staggerMs + entranceMs) / totalMs;
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Interval(
          titleStart,
          titleEnd,
          curve: AuthAnimConst.entranceCurve,
        ),
      ),
    );
    _titleOffset =
        Tween<double>(
          begin: AuthAnimConst.entranceSlideOffset,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _controller!,
            curve: Interval(
              titleStart,
              titleEnd,
              curve: AuthAnimConst.entranceCurve,
            ),
          ),
        );

    final subtitleStart = (staggerMs * 2) / totalMs;
    final subtitleEnd = ((staggerMs * 2) + entranceMs) / totalMs;
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Interval(
          subtitleStart,
          subtitleEnd.clamp(0.0, 1.0),
          curve: AuthAnimConst.entranceCurve,
        ),
      ),
    );
    _subtitleOffset =
        Tween<double>(
          begin: AuthAnimConst.entranceSlideOffset * 0.6,
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _controller!,
            curve: Interval(
              subtitleStart,
              subtitleEnd.clamp(0.0, 1.0),
              curve: AuthAnimConst.entranceCurve,
            ),
          ),
        );

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final backButton = widget.showBackButton
        ? Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
              onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
            ),
          )
        : const SizedBox.shrink();

    final titleWidget = Text(
      widget.title,
      style: tt.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      textAlign: TextAlign.center,
    );

    final subtitleWidget = widget.subtitle != null
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              widget.subtitle!,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          )
        : const SizedBox.shrink();

    if (_controller == null) {
      return Column(
        children: [
          backButton,
          if (widget.icon != null) ...[
            const SizedBox(height: 8),
            _buildIconCircle(cs),
            const SizedBox(height: 16),
          ],
          titleWidget,
          subtitleWidget,
        ],
      );
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) {
        return Column(
          children: [
            backButton,
            if (widget.icon != null) ...[
              const SizedBox(height: 8),
              RepaintBoundary(
                child: Transform.scale(
                  scale: _iconScale!.value,
                  child: _buildIconCircle(cs),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Opacity(
              opacity: _titleOpacity!.value,
              child: Transform.translate(
                offset: Offset(0, _titleOffset!.value),
                child: titleWidget,
              ),
            ),
            Opacity(
              opacity: _subtitleOpacity!.value,
              child: Transform.translate(
                offset: Offset(0, _subtitleOffset!.value),
                child: subtitleWidget,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconCircle(ColorScheme cs) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: widget.iconBackgroundColor ?? cs.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(widget.icon, size: 32, color: cs.primary),
    );
  }
}
