import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/presentation/account_screen.dart';
import 'package:study/features/student/bloc/student_courses/student_courses_cubit.dart';
import 'package:study/features/student/bloc/student_dashboard/student_dashboard_cubit.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/student_achievement_screen.dart';
import 'package:study/features/student/presentation/screens/student_dashboard_screen.dart';
import 'package:study/features/student/presentation/screens/student_explore_screen.dart';
import 'package:study/features/student/presentation/screens/student_learning_screen.dart';
import 'package:study/widgets/simple_gradient_background.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  static const int tabDashboard = 0;
  static const int tabExplore = 1;
  static const int tabLearning = 2;
  static const int tabAchievement = 3;
  static const int tabProfile = 4;

  static void switchToTab(BuildContext context, int tabIndex,
      {int? segment}) {
    final state =
        context.findAncestorStateOfType<_StudentMainScreenState>();
    state?._switchTab(tabIndex, segment: segment);
  }

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;
  late final StudentRepository _repository;

  final _learningKey = GlobalKey<StudentLearningScreenState>();

  @override
  void initState() {
    super.initState();
    _repository = diContainer.get<StudentRepository>();
  }

  void _switchTab(int index, {int? segment}) {
    if (index >= 0 && index <= 4) {
      setState(() => _currentIndex = index);
      if (index == StudentMainScreen.tabLearning && segment != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _learningKey.currentState?.switchSegment(segment);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StudentRepository>.value(value: _repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => StudentDashboardCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) =>
                StudentCoursesCubit(repository: _repository)..loadCourses(),
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SimpleGradientBackground(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const StudentDashboardScreen(),
                const StudentExploreScreen(),
                StudentLearningScreen(key: _learningKey),
                const StudentAchievementScreen(),
                const AccountScreen(roleType: AccountRoleType.student),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => _switchTab(i),
            backgroundColor: cs.surface,
            indicatorColor: cs.primaryContainer,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Trang chu',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Hoc tap',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events),
                label: 'Thanh tich',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Ho so',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
