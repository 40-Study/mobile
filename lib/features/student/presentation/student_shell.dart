import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/presentation/achievement/achievement_screen.dart';
import 'package:study/features/student/presentation/bookmark/bookmark_screen.dart';
import 'package:study/features/student/presentation/home/home_screen.dart';
import 'package:study/features/student/presentation/learning/learning_screen.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/features/student/presentation/profile/profile_screen.dart';
import 'package:study/features/student/presentation/schedule/schedule_screen.dart';
import 'package:study/features/student/presentation/search/search_screen.dart';
import 'package:study/features/student/presentation/settings/settings_screen.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';
import 'package:study/widgets/app_drawer.dart';

enum StudentTab { home, learning, schedule, achievement, profile }

class StudentShell extends StatefulWidget {
  const StudentShell({super.key, this.initialTab = StudentTab.home});

  final StudentTab initialTab;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late StudentTab _currentTab;
  late Set<int> _visitedTabs;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _visitedTabs = {_currentTab.index};
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.fullName ?? authState.user.username ?? 'Bạn'
        : 'Bạn';
    final userEmail = authState is AuthAuthenticated
        ? authState.user.email
        : '';

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        userName: userName,
        userEmail: userEmail,
        userAvatar: authState is AuthAuthenticated
            ? authState.user.avatarUrl
            : null,
        notificationCount: 2,
        onNotificationsTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
          );
        },
        onBookmarksTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const BookmarkScreen()),
          );
        },
        onSearchTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
          );
        },
        onSettingsTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          );
        },
        onHelpTap: () {
          Navigator.pop(context);
          // TODO: Help screen
        },
        onLogoutTap: () {
          Navigator.pop(context);
          context.read<AuthBloc>().add(AuthLoggedOut());
        },
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomeBloc(StudentRepositoryImpl())),
          BlocProvider(create: (_) => LearningBloc(StudentRepositoryImpl())),
          BlocProvider(create: (_) => ScheduleBloc(StudentRepositoryImpl())),
          BlocProvider(create: (_) => AchievementBloc(StudentRepositoryImpl())),
        ],
        child: IndexedStack(
          index: _currentTab.index,
          children: List.generate(
            StudentTab.values.length,
            (index) => _visitedTabs.contains(index)
                ? _buildTab(index, userName)
                : const SizedBox.shrink(),
          ),
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentTab.index,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Học tập',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Lịch học',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Thành tích',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    final nextTab = StudentTab.values[index];
    if (nextTab == _currentTab) return;
    setState(() {
      _currentTab = nextTab;
      _visitedTabs.add(index);
    });
  }

  Widget _buildTab(int index, String userName) {
    return switch (StudentTab.values[index]) {
      StudentTab.home => HomeScreen(
        userName: userName,
        onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
        onNavigateToTab: _selectTab,
      ),
      StudentTab.learning => const LearningScreen(),
      StudentTab.schedule => const ScheduleScreen(),
      StudentTab.achievement => const AchievementScreen(),
      StudentTab.profile => const ProfileScreen(),
    };
  }
}
