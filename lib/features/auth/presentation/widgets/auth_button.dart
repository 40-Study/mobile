import 'package:flutter/material.dart';
import 'package:study/features/auth/presentation/widgets/auth_animations.dart';

/// Primary button with press scale, loading crossfade, and success checkmark.
/// Press scale + loading/success transitions are always active (interactive).
class AuthButton extends StatefulWidget {
  const AuthButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isSuccess = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool isSuccess;

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  AnimationController? _successController;
  Animation<double>? _checkProgress;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: AuthAnimConst.successDuration,
    );
    _checkProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController!, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(covariant AuthButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSuccess && !oldWidget.isSuccess) {
      _successController!.forward();
    } else if (!widget.isSuccess && oldWidget.isSuccess) {
      _successController!.reset();
    }
  }

  @override
  void dispose() {
    _successController?.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = AuthAnimConst.pressScale);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = widget.isSuccess ? cs.tertiary : cs.primary;
    final fgColor = widget.isSuccess ? cs.onTertiary : cs.onPrimary;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _scale,
          duration: AuthAnimConst.interactiveDuration,
          curve: Curves.easeOut,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: AnimatedContainer(
              duration: AuthAnimConst.successDuration,
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: widget.onPressed == null && !widget.isLoading
                    ? bgColor.withValues(alpha: 0.6)
                    : bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.isLoading || widget.isSuccess
                      ? null
                      : widget.onPressed,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: AuthAnimConst.focusDuration,
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: widget.isSuccess
                          ? AnimatedBuilder(
                              key: const ValueKey('success'),
                              animation: _checkProgress!,
                              builder: (context, _) {
                                return CustomPaint(
                                  size: const Size(24, 24),
                                  painter: _CheckPainter(
                                    progress: _checkProgress!.value,
                                    color: fgColor,
                                  ),
                                );
                              },
                            )
                          : widget.isLoading
                          ? SizedBox(
                              key: const ValueKey('loading'),
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: fgColor,
                              ),
                            )
                          : Text(
                              widget.label,
                              key: ValueKey(widget.label),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: fgColor,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.5)
      ..lineTo(size.width * 0.42, size.height * 0.73)
      ..lineTo(size.width * 0.82, size.height * 0.28);

    final metrics = path.computeMetrics().first;
    final drawn = metrics.extractPath(0, metrics.length * progress);
    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
