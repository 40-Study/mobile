import 'package:flutter/material.dart';
import 'package:study/features/onboarding/models/onboarding_page_data.dart';
import 'package:study/features/onboarding/widgets/onboarding_page_content.dart';

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

    _illustrationScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _illustrationController,
        curve: Curves.easeOutBack,
      ),
    );
    _illustrationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _illustrationController,
        curve: Curves.easeOut,
      ),
    );
    _pulseScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _titleOffset = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeOutCubic,
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeOut,
      ),
    );

    _subtitleOffset = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.easeOutCubic,
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.easeOut,
      ),
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
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop(canceled: true);
      _pulseController.reset();
      _hasAnimated = false;
      _illustrationController.reset();
      _titleController.reset();
      _subtitleController.reset();
    }
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
    if (!widget.isActive) {
      return Padding(
        padding: widget.padding,
        child: OnboardingPageContent(
          data: widget.data,
          padding: EdgeInsets.zero,
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  child: _buildIllustration(colorScheme),
                ),
              );
            },
          ),
          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: _titleController,
            builder: (context, child) {
              return Opacity(
                opacity: _titleOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _titleOffset.value),
                  child: Text(
                    widget.data.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _subtitleController,
            builder: (context, child) {
              return Opacity(
                opacity: _subtitleOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _subtitleOffset.value),
                  child: Text(
                    widget.data.subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(ColorScheme colorScheme) {
    final data = widget.data;
    if (data.imagePath != null && data.imagePath!.isNotEmpty) {
      return Image.asset(
        data.imagePath!,
        height: 200,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildIconFallback(colorScheme),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: colorScheme.secondary.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Icon(icon, size: 64, color: colorScheme.primary),
    );
  }
}
