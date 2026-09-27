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
import 'package:study/di/di_container.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController? _pageController;

  PageController get _controller => _pageController ??= PageController(initialPage: _currentTab.index);

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Select chỉ user data cần cho drawer, tránh rebuild khi AuthBloc emit state khác
    final userData = context.select<AuthBloc, ({String name, String email, String? avatar})>(
      (bloc) {
        final state = bloc.state;
        if (state is AuthAuthenticated) {
          return (
            name: state.user.fullName ?? state.user.username ?? 'Bạn',
            email: state.user.email,
            avatar: state.user.avatarUrl,
          );
        }
        return (name: 'Bạn', email: '', avatar: null);
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        userName: userData.name,
        userEmail: userData.email,
        userAvatar: userData.avatar,
        notificationCount: 0, // TODO: Replace with real notification count from API
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
          // TODO(MOCK-01): Help screen not implemented - needs HelpScreen widget
        },
        onLogoutTap: () {
          Navigator.pop(context);
          context.read<AuthBloc>().add(AuthLoggedOut());
        },
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => diContainer<HomeBloc>()),
          BlocProvider(create: (_) => diContainer<LearningBloc>()),
          BlocProvider(create: (_) => diContainer<ScheduleBloc>()),
          BlocProvider(create: (_) => diContainer<AchievementBloc>()),
        ],
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              _currentTab = StudentTab.values[index];
            });
          },
          children: List.generate(
            StudentTab.values.length,
            (index) => _buildTab(index, userData.name),
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
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
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
