import 'package:flutter/material.dart';
import 'package:study/features/parent/presentation/home/parent_home_screen.dart';
import 'package:study/features/parent/presentation/learning/parent_learning_screen.dart';
import 'package:study/features/parent/presentation/payment/parent_payment_screen.dart';
import 'package:study/features/parent/presentation/profile/parent_profile_screen.dart';
import 'package:study/features/parent/presentation/schedule/parent_schedule_screen.dart';
class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  late final PageController _pageController;
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    ParentHomeScreen(
      onNavigateToProfile: () => _onNavTap(4),
      onNavigateToSchedule: () => _onNavTap(1),
      onNavigateToLearning: () => _onNavTap(2),
    ),
    const ParentScheduleScreen(),
    const ParentLearningScreen(),
    const ParentPaymentScreen(),
    const ParentProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Lịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Học tập',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card_rounded),
            label: 'Học phí',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
