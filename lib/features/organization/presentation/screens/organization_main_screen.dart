import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/organization/bloc/dashboard/org_dashboard_cubit.dart';
import 'package:study/features/organization/bloc/finance/org_finance_cubit.dart';
import 'package:study/features/organization/bloc/students/org_students_cubit.dart';
import 'package:study/features/organization/bloc/teachers/org_teachers_cubit.dart';
import 'package:study/features/organization/data/repository/organization_repository_impl.dart';
import 'package:study/features/organization/presentation/screens/org_dashboard_screen.dart';
import 'package:study/features/organization/presentation/screens/org_finance_screen.dart';
import 'package:study/features/organization/presentation/screens/org_settings_screen.dart';
import 'package:study/features/organization/presentation/screens/org_students_screen.dart';
import 'package:study/features/organization/presentation/screens/org_teachers_screen.dart';
import 'package:study/widgets/simple_gradient_background.dart';

class OrganizationMainScreen extends StatefulWidget {
  const OrganizationMainScreen({super.key});

  static const int tabDashboard = 0;
  static const int tabTeachers = 1;
  static const int tabStudents = 2;
  static const int tabFinance = 3;
  static const int tabSettings = 4;

  /// Switch to a specific tab from anywhere in the widget tree
  static void switchToTab(BuildContext context, int tabIndex) {
    final state = context.findAncestorStateOfType<_OrganizationMainScreenState>();
    state?._switchTab(tabIndex);
  }

  @override
  State<OrganizationMainScreen> createState() => _OrganizationMainScreenState();
}

class _OrganizationMainScreenState extends State<OrganizationMainScreen> {
  int _currentIndex = 0;
  late final OrganizationRepositoryImpl _repository;

  @override
  void initState() {
    super.initState();
    _repository = OrganizationRepositoryImpl();
  }

  void _switchTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<OrganizationRepositoryImpl>.value(value: _repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => OrgDashboardCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) => OrgTeachersCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) => OrgStudentsCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) => OrgFinanceCubit(repository: _repository),
          ),
        ],
        child: SimpleGradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: IndexedStack(
              index: _currentIndex,
              children: const [
                OrgDashboardScreen(),
                OrgTeachersScreen(),
                OrgStudentsScreen(),
                OrgFinanceScreen(),
                OrgSettingsScreen(),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _switchTab,
                backgroundColor: Colors.transparent,
                indicatorColor: cs.primaryContainer,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Tong quan',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: 'Giao vien',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outlined),
                    selectedIcon: Icon(Icons.people),
                    label: 'Hoc vien',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet),
                    label: 'Tai chinh',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Cai dat',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
