import 'package:flutter/material.dart';

abstract final class AuthAnimConst {
  static const Duration entranceDuration = Duration(milliseconds: 450);
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Curve entranceCurve = Curves.easeOutCubic;

  static const Duration interactiveDuration = Duration(milliseconds: 120);
  static const Duration focusDuration = Duration(milliseconds: 200);
  static const Duration successDuration = Duration(milliseconds: 300);

  static const double entranceSlideOffset = 30.0;
  static const double pressScale = 0.96;
}

class StaggeredColumn extends StatefulWidget {
  const StaggeredColumn({
    super.key,
    required this.children,
    this.animate = true,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.min,
    this.onComplete,
  });

  final List<Widget> children;
  final bool animate;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final VoidCallback? onComplete;

  @override
  State<StaggeredColumn> createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<StaggeredColumn>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  List<Animation<double>>? _opacities;
  List<Animation<double>>? _offsets;

  @override
  void initState() {
    super.initState();
    if (widget.animate && widget.children.isNotEmpty) {
      _initAnimations();
    }
  }

  void _initAnimations() {
    final count = widget.children.length;
    final staggerMs = AuthAnimConst.staggerDelay.inMilliseconds;
    final entranceMs = AuthAnimConst.entranceDuration.inMilliseconds;
    final totalMs = entranceMs + staggerMs * (count - 1);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    _opacities = List.generate(count, (i) {
      final start = (staggerMs * i) / totalMs;
      final end = (staggerMs * i + entranceMs) / totalMs;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: Interval(
            start,
            end.clamp(0.0, 1.0),
            curve: AuthAnimConst.entranceCurve,
          ),
        ),
      );
    });

    _offsets = List.generate(count, (i) {
      final start = (staggerMs * i) / totalMs;
      final end = (staggerMs * i + entranceMs) / totalMs;
      return Tween<double>(
        begin: AuthAnimConst.entranceSlideOffset,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controller!,
          curve: Interval(
            start,
            end.clamp(0.0, 1.0),
            curve: AuthAnimConst.entranceCurve,
          ),
        ),
      );
    });

    _controller!.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  List<Widget> _buildChildren({
    required List<Widget> children,
    required bool wrapAnimated,
  }) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && widget.spacing > 0) {
        result.add(SizedBox(height: widget.spacing));
      }

      final child = children[i];
      if (wrapAnimated && _controller != null) {
        result.add(
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller!,
              builder: (context, c) {
                return Opacity(
                  opacity: _opacities![i].value,
                  child: Transform.translate(
                    offset: Offset(0, _offsets![i].value),
                    child: c,
                  ),
                );
              },
              child: child,
            ),
          ),
        );
      } else {
        result.add(RepaintBoundary(child: child));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isAnimated = widget.animate && _controller != null;

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      children: _buildChildren(
        children: widget.children,
        wrapAnimated: isAnimated,
      ),
    );
  }
}
