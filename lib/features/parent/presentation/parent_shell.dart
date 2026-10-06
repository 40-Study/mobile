import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/home/parent_home_bloc.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_bloc.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_bloc.dart';
import 'package:study/features/parent/presentation/home/parent_home_screen.dart';
import 'package:study/features/parent/presentation/learning/parent_learning_screen.dart';
import 'package:study/features/parent/presentation/payment/parent_payment_screen.dart';
import 'package:study/features/parent/presentation/profile/parent_profile_screen.dart';
import 'package:study/features/parent/presentation/schedule/parent_schedule_screen.dart';

enum ParentTab { home, schedule, learning, payment, profile }

class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  late final PageController _pageController;
  ParentTab _currentTab = ParentTab.home;

  late final List<Widget> _screens = [
    ParentHomeScreen(
      onNavigateToProfile: () => _onNavTap(4),
      onNavigateToSchedule: () => _onNavTap(1),
      onNavigateToLearning: () => _onNavTap(2),
    ),
    ParentScheduleScreen(
      onNavigateToProfile: () => _onNavTap(4),
    ),
    ParentLearningScreen(
      onNavigateToProfile: () => _onNavTap(4),
    ),
    ParentPaymentScreen(
      onNavigateToProfile: () => _onNavTap(4),
    ),
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
    setState(() => _currentTab = ParentTab.values[index]);
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => diContainer<ParentHomeBloc>()),
        BlocProvider(create: (_) => diContainer<ParentScheduleBloc>()),
        BlocProvider(create: (_) => diContainer<ParentLearningBloc>()),
      ],
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTab.index,
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
      ),
    );
  }
}
