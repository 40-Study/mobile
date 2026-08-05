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
import 'package:study/theme/app_colors.dart';
import 'package:study/theme/app_spacing.dart';
import 'package:study/widgets/app_drawer.dart';

// Enum tab cho student shell
enum StudentTab { home, learning, schedule, achievement, profile }

class StudentShell extends StatefulWidget {
  const StudentShell({
    super.key,
    this.initialTab = StudentTab.home,
  });

  final StudentTab initialTab;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late StudentTab _currentTab;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is AuthAuthenticated
        ? authState.user.fullName ?? authState.user.username ?? 'Ban'
        : 'Ban';
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
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab.index,
        onDestinationSelected: (index) {
          setState(() {
            _currentTab = StudentTab.values[index];
          });
        },
        // Chieu cao bottom nav bar
        height: AppSpacing.section,
        indicatorColor: cs.brandBlue.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Hoc tap',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Lich hoc',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Thanh tich',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tai khoan',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Mock repository — replace với DI sau
    final repository = StudentRepositoryImpl();

    switch (_currentTab) {
      case StudentTab.home:
        return BlocProvider(
          create: (_) => HomeBloc(repository),
          child: HomeScreen(
            onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
            onNavigateToTab: (index) {
              setState(() {
                _currentTab = StudentTab.values[index];
              });
            },
          ),
        );
      case StudentTab.learning:
        return BlocProvider(
          create: (_) => LearningBloc(repository),
          child: const LearningScreen(),
        );
      case StudentTab.schedule:
        return BlocProvider(
          create: (_) => ScheduleBloc(repository),
          child: const ScheduleScreen(),
        );
      case StudentTab.achievement:
        return BlocProvider(
          create: (_) => AchievementBloc(repository),
          child: const AchievementScreen(),
        );
      case StudentTab.profile:
        return const ProfileScreen();
    }
  }
}
