import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';

/// White card with entrance animation (once only via AnimationCubit).
class AuthFormCard extends StatefulWidget {
  const AuthFormCard({super.key, required this.child, this.showLogo = false});

  final Widget child;
  final bool showLogo;

  @override
  State<AuthFormCard> createState() => _AuthFormCardState();
}

class _AuthFormCardState extends State<AuthFormCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _opacity;
  late Animation<double> _offsetY;
  late Animation<double> _scale;
  bool _didAnimate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didAnimate || _controller != null) return;

    final cubit = context.read<AuthAnimationCubit>();
    if (!cubit.state.shouldAnimate) {
      _didAnimate = true;
      return;
    }

    _controller = AnimationController(
      vsync: this,
      duration: AuthAnimConst.entranceDuration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: AuthAnimConst.entranceCurve),
    );
    _offsetY = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller!, curve: AuthAnimConst.entranceCurve),
    );
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: AuthAnimConst.entranceCurve),
    );

    _controller!.forward().then((_) => _didAnimate = true);
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

    final cardContent = Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLogo) ...[
            Text(
              '40Study',
              style: tt.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 32),
          ],
          widget.child,
        ],
      ),
    );

    if (_controller == null) return cardContent;

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _offsetY.value),
            child: Transform.scale(scale: _scale.value, child: child),
          ),
        );
      },
      child: cardContent,
    );
  }
}
