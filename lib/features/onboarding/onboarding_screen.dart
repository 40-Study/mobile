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
    NavigationService.of(context).pushAndRemoveAll(Routes.login);
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header: Skip button only (top right)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Skip button (hide on last page)
                    AnimatedOpacity(
                      opacity: _currentPage < _pageCount - 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: _currentPage < _pageCount - 1
                            ? () => _pageController.animateToPage(
                                _pageCount - 1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutCubic,
                              )
                            : null,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      AnimatedOnboardingPageContent(
                        data: pages[index],
                        isActive: index == _currentPage,
                      ),
                ),
              ),

              // Bottom: Indicator + CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Page indicator
                    _AnimatedPageIndicator(
                      count: _pageCount,
                      current: _currentPage,
                    ),
                    const SizedBox(height: 24),
                    // Full-width CTA button
                    _OnboardingCtaButton(
                      label: pages[_currentPage].buttonLabel ?? 'Next',
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
  const _OnboardingCtaButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: _indicatorAnimationDuration,
          curve: Curves.easeInOutCubic,
          width: index == current ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == current
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
