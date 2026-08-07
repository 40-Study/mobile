// lib/features/student/presentation/student_shell.dart
import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/theme/app_spacing.dart';

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

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
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

  // Placeholder cho tung tab cho den khi co screen rieng
  Widget _buildBody() {
    switch (_currentTab) {
      case StudentTab.home:
        return const Center(child: Text('Trang chu'));
      case StudentTab.learning:
        return const Center(child: Text('Hoc tap'));
      case StudentTab.schedule:
        return const Center(child: Text('Lich hoc'));
      case StudentTab.achievement:
        return const Center(child: Text('Thanh tich'));
      case StudentTab.profile:
        return const Center(child: Text('Tai khoan'));
    }
  }
}
