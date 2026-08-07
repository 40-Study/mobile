import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/durations.dart';
import 'package:study/features/onboarding/onboarding_content.dart';
import 'package:study/features/onboarding/widgets/animated_onboarding_page_content.dart';
import 'package:study/repository/repository.dart';
import 'package:study/routes/router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  static const int _pageCount = 3;
  int _currentPage = 0;

  Future<void> _onGetStarted() async {
    await context.read<OnboardingRepository>().setSeenOnboarding();
    if (!mounted) return;
    unawaited(NavigationService.of(context).pushAndRemoveAll(Routes.login));
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
      body: ColoredBox(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                child: Row(
                  children: [
                    Text(
                      '40Study',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: _currentPage < _pageCount - 1 ? 1.0 : 0.0,
                      duration: AppDurations.fadeIn,
                      child: TextButton(
                        onPressed: _currentPage < _pageCount - 1
                            ? () => _pageController.animateToPage(
                                _pageCount - 1,
                                duration: AppDurations.pageTransition,
                                curve: Curves.easeInOutCubic,
                              )
                            : null,
                        child: Text(
                          'Bỏ qua',
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

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    _AnimatedPageIndicator(
                      count: _pageCount,
                      current: _currentPage,
                    ),
                    const SizedBox(height: 24),
                    _OnboardingCtaButton(
                      label: pages[_currentPage].buttonLabel ?? 'Tiếp tục',
                      onPressed: () {
                        if (_currentPage < _pageCount - 1) {
                          _pageController.nextPage(
                            duration: AppDurations.pageTransition,
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
        label: Text(label),
      ),
    );
  }
}

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
          duration: AppDurations.pageIndicator,
          curve: Curves.easeInOutCubic,
          width: index == current ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == current ? colorScheme.primary : colorScheme.outline,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
