import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

class LessonBottomTabBar extends StatelessWidget {
  const LessonBottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.hasQuiz,
    this.quizCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasQuiz;
  final int quizCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: cs.primaryContainer,
          height: AppSpacing.massive + AppSpacing.lg,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.info_outline_rounded),
              selectedIcon: Icon(Icons.info_rounded),
              label: 'Tong quan',
            ),
            const NavigationDestination(
              icon: Icon(Icons.description_outlined),
              selectedIcon: Icon(Icons.description_rounded),
              label: 'Tai lieu',
            ),
            const NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment_rounded),
              label: 'Bai tap',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: quizCount > 0,
                label: Text('$quizCount'),
                child: const Icon(Icons.quiz_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: quizCount > 0,
                label: Text('$quizCount'),
                child: const Icon(Icons.quiz_rounded),
              ),
              label: 'Quiz',
            ),
          ],
        ),
      ),
    );
  }
}
