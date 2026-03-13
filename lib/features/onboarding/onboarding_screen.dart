import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/onboarding/onboarding_content.dart';
import 'package:study/features/onboarding/widgets/animated_onboarding_page_content.dart';
import 'package:study/repository/repository.dart';
import 'package:study/routes/router.dart';

/// Màn 3 trang onboarding. Gradient nền, chuyển trang mượt, CTA nổi bật.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  static const int _pageCount = 3;
  int _currentPage = 0;

  OnboardingRepository get _onboardingRepo =>
      diContainer.get<OnboardingRepository>();

  Future<void> _onGetStarted() async {
    await _onboardingRepo.setSeenOnboarding();
    if (!mounted) return;
    NavigationService.of(context).pushAndRemoveAll(Routes.app);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pages = onboardingPages;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.25),
              colorScheme.secondaryContainer.withValues(alpha: 0.15),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (_currentPage < _pageCount - 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 8),
                    child: TextButton(
                      onPressed: () => _pageController.animateToPage(
                        _pageCount - 1,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                      ),
                      child: Text(
                        'Bỏ qua',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) => AnimatedOnboardingPageContent(
                    data: pages[index],
                    isActive: index == _currentPage,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AnimatedPageIndicator(
                      count: _pageCount,
                      current: _currentPage,
                    ),
                    _OnboardingCtaButton(
                      isLastPage: _currentPage >= _pageCount - 1,
                      onPressed: () {
                        if (_currentPage < _pageCount - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _onGetStarted();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCtaButton extends StatelessWidget {
  const _OnboardingCtaButton({
    required this.isLastPage,
    required this.onPressed,
  });

  final bool isLastPage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Material(
        key: ValueKey<bool>(isLastPage),
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: isLastPage
                  ? LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isLastPage ? null : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isLastPage
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              isLastPage ? 'Bắt đầu' : 'Tiếp',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isLastPage
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const Duration _indicatorAnimationDuration = Duration(milliseconds: 280);

class _AnimatedPageIndicator extends StatelessWidget {
  const _AnimatedPageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: _indicatorAnimationDuration,
          curve: Curves.easeInOutCubic,
          width: index == current ? 28 : 10,
          height: 10,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: index == current
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
