import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/presentation/account_screen.dart';
import 'package:study/features/teacher/bloc/classes/teacher_classes_cubit.dart';
import 'package:study/features/teacher/bloc/courses/teacher_courses_cubit.dart';
import 'package:study/features/teacher/bloc/dashboard/teacher_dashboard_cubit.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';
import 'package:study/features/teacher/presentation/screens/teacher_actions_screen.dart';
import 'package:study/features/teacher/presentation/screens/teacher_courses_screen.dart';
import 'package:study/features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import 'package:study/features/teacher/presentation/screens/teacher_revenue_screen.dart';
import 'package:study/features/weather/weather.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  static const int tabDashboard = 0;
  static const int tabCourses = 1;
  static const int tabActions = 2;
  static const int tabRevenue = 3;
  static const int tabProfile = 4;

  /// Switch to a specific tab from anywhere in the widget tree
  static void switchToTab(BuildContext context, int tabIndex) {
    final state = context.findAncestorStateOfType<_TeacherMainScreenState>();
    state?._switchTab(tabIndex);
  }

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 0;
  late final TeacherRepository _repository;

  final _screens = const [
    TeacherDashboardScreen(),
    TeacherCoursesScreen(),
    TeacherActionsScreen(),
    TeacherRevenueScreen(),
    AccountScreen(roleType: AccountRoleType.teacher),
  ];

  @override
  void initState() {
    super.initState();
    _repository = diContainer.get<TeacherRepository>();
  }

  void _switchTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TeacherRepository>.value(value: _repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => TeacherDashboardCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) => TeacherCoursesCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) => TeacherClassesCubit(repository: _repository),
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: WeatherBackgroundWrapper(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: cs.surface,
            indicatorColor: cs.primaryContainer,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Bảng tin',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school),
                label: 'Khóa học',
              ),
              NavigationDestination(
                icon: Icon(Icons.flash_on_outlined),
                selectedIcon: Icon(Icons.flash_on),
                label: 'Hành động',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Doanh số',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Hồ sơ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
