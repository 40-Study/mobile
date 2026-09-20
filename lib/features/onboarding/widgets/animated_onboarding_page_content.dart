import 'package:flutter/material.dart';
import 'package:study/features/onboarding/models/onboarding_page_data.dart';

/// Duration và delay cho animation từng phần (tái sử dụng / dễ chỉnh).
const Duration _illustrationDuration = Duration(milliseconds: 500);
const Duration _titleDuration = Duration(milliseconds: 380);
const Duration _subtitleDuration = Duration(milliseconds: 380);
const Duration _titleDelay = Duration(milliseconds: 80);
const Duration _subtitleDelay = Duration(milliseconds: 120);

/// Wrapper thêm animation xuất hiện lần lượt (staggered) khi trang được chọn.
/// Chỉ chạy animation khi [isActive] chuyển sang true.
class AnimatedOnboardingPageContent extends StatefulWidget {
  const AnimatedOnboardingPageContent({
    super.key,
    required this.data,
    required this.isActive,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  final OnboardingPageData data;
  final bool isActive;
  final EdgeInsetsGeometry padding;

  @override
  State<AnimatedOnboardingPageContent> createState() =>
      _AnimatedOnboardingPageContentState();
}

class _AnimatedOnboardingPageContentState
    extends State<AnimatedOnboardingPageContent>
    with TickerProviderStateMixin {
  late AnimationController _illustrationController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;
  late AnimationController _pulseController;

  late Animation<double> _illustrationScale;
  late Animation<double> _illustrationOpacity;
  late Animation<double> _titleOffset;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOffset;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _pulseScale;

  bool _hasAnimated = false;

  // Interactive rotation/tilt state
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  Offset _lastPanPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _illustrationController = AnimationController(
      vsync: this,
      duration: _illustrationDuration,
    );
    _titleController = AnimationController(
      vsync: this,
      duration: _titleDuration,
    );
    _subtitleController = AnimationController(
      vsync: this,
      duration: _subtitleDuration,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _illustrationScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _illustrationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _illustrationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _illustrationController, curve: Curves.easeOut),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _titleOffset = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _subtitleOffset = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOutCubic),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut),
    );

    // Trang đầu build với isActive = true nhưng didUpdateWidget không chạy lần đầu.
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isActive && !_hasAnimated) _runAnimation();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedOnboardingPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_hasAnimated) {
      _runAnimation();
    }
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
      // Reset rotation when page becomes active
      setState(() {
        _rotationX = 0.0;
        _rotationY = 0.0;
      });
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop(canceled: true);
      _pulseController.reset();
      _hasAnimated = false;
      _illustrationController.reset();
      _titleController.reset();
      _subtitleController.reset();
      // Reset rotation
      _rotationX = 0.0;
      _rotationY = 0.0;
    }
  }

  void _onPanStart(DragStartDetails details) {
    _lastPanPosition = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final delta = details.localPosition - _lastPanPosition;
    _lastPanPosition = details.localPosition;

    setState(() {
      // Rotate based on drag direction (limited range)
      _rotationY = (_rotationY + delta.dx * 0.002).clamp(-0.08, 0.08);
      _rotationX = (_rotationX - delta.dy * 0.002).clamp(-0.08, 0.08);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Animate back to neutral position
    _animateRotationReset();
  }

  void _animateRotationReset() {
    // Simple spring-back animation using setState
    Future.doWhile(() async {
      if (!mounted) return false;

      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) return false;

      final newX = _rotationX * 0.85;
      final newY = _rotationY * 0.85;

      if (newX.abs() < 0.001 && newY.abs() < 0.001) {
        setState(() {
          _rotationX = 0.0;
          _rotationY = 0.0;
        });
        return false;
      }

      setState(() {
        _rotationX = newX;
        _rotationY = newY;
      });
      return true;
    });
  }

  Future<void> _runAnimation() async {
    if (!mounted || !widget.isActive) return;
    _hasAnimated = true;
    _illustrationController.forward();
    await Future<void>.delayed(_titleDelay);
    if (!mounted) return;
    _titleController.forward();
    await Future<void>.delayed(_subtitleDelay - _titleDelay);
    if (!mounted) return;
    _subtitleController.forward();
    if (mounted && widget.isActive) _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _illustrationController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!widget.isActive) {
      return Padding(
        padding: widget.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(colorScheme),
            const SizedBox(height: 28),
            _buildTitle(theme, colorScheme),
            const SizedBox(height: 10),
            _buildSubtitle(theme, colorScheme),
          ],
        ),
      );
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([
              _illustrationController,
              _pulseController,
            ]),
            builder: (context, child) {
              final entranceScale = _illustrationScale.value;
              final pulse = _pulseScale.value;
              return Opacity(
                opacity: _illustrationOpacity.value,
                child: Transform.scale(
                  scale: entranceScale * pulse,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateX(_rotationX)
                        ..rotateY(_rotationY),
                      child: _buildIllustration(colorScheme),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: _titleController,
            builder: (context, child) {
              return Opacity(
                opacity: _titleOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _titleOffset.value),
                  child: _buildTitle(theme, colorScheme),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _subtitleController,
            builder: (context, child) {
              return Opacity(
                opacity: _subtitleOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _subtitleOffset.value),
                  child: _buildSubtitle(theme, colorScheme),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, ColorScheme colorScheme) {
    final data = widget.data;
    final baseStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      height: 1.2,
      color: colorScheme.onSurface,
    );

    // If there's a highlight segment, use RichText
    if (data.highlightText != null && data.highlightText!.isNotEmpty) {
      final title = data.title;
      final highlight = data.highlightText!;
      final highlightIndex = title.indexOf(highlight);

      if (highlightIndex >= 0) {
        final before = title.substring(0, highlightIndex);
        final after = title.substring(highlightIndex + highlight.length);

        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: baseStyle,
            children: [
              if (before.isNotEmpty) TextSpan(text: before),
              TextSpan(
                text: highlight,
                style: baseStyle?.copyWith(color: colorScheme.primary),
              ),
              if (after.isNotEmpty) TextSpan(text: after),
            ],
          ),
        );
      }
    }

    return Text(data.title, style: baseStyle, textAlign: TextAlign.center);
  }

  Widget _buildSubtitle(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      widget.data.subtitle,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildIllustration(ColorScheme colorScheme) {
    final data = widget.data;

    // Use custom illustration builder if available
    if (data.hasCustomIllustration) {
      return data.illustrationBuilder!(context, isActive: widget.isActive);
    }

    if (data.imagePath != null && data.imagePath!.isNotEmpty) {
      return Image.asset(
        data.imagePath!,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildIconFallback(colorScheme),
      );
    }
    return _buildIconFallback(colorScheme);
  }

  Widget _buildIconFallback(ColorScheme colorScheme) {
    final icon = widget.data.icon ?? Icons.lightbulb_outline;
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      child: Icon(icon, size: 64, color: colorScheme.primary),
    );
  }
}
