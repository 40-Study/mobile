import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/presentation/account_screen.dart';
import 'package:study/features/parent/bloc/parent_dashboard/parent_dashboard_cubit.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';
import 'package:study/features/parent/presentation/screens/parent_dashboard_screen.dart';
import 'package:study/features/parent/presentation/screens/parent_notifications_screen.dart';
import 'package:study/features/weather/weather.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _currentIndex = 0;
  late final ParentRepository _repository;

  final _screens = const [
    ParentDashboardScreen(),
    ParentNotificationsScreen(),
    AccountScreen(roleType: AccountRoleType.parent),
  ];

  @override
  void initState() {
    super.initState();
    _repository = diContainer.get<ParentRepository>();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ParentRepository>.value(value: _repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ParentDashboardCubit(repository: _repository),
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
                label: 'Trang chu',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Thong bao',
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
