import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/presentation/account_screen.dart';
import 'package:study/features/parent/bloc/children/children_selector_cubit.dart';
import 'package:study/features/parent/bloc/finance/parent_finance_cubit.dart';
import 'package:study/features/parent/bloc/parent_dashboard/parent_dashboard_cubit.dart';
import 'package:study/features/parent/bloc/tracking/parent_tracking_cubit.dart';
import 'package:study/features/parent/data/repository/parent_repository.dart';
import 'package:study/features/parent/presentation/screens/parent_dashboard_screen.dart';
import 'package:study/features/parent/presentation/screens/parent_finance_screen.dart';
import 'package:study/features/parent/presentation/screens/parent_more_screen.dart';
import 'package:study/features/parent/presentation/screens/parent_notifications_screen.dart';
import 'package:study/features/parent/presentation/screens/parent_tracking_screen.dart';
import 'package:study/widgets/simple_gradient_background.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  static const int tabHome = 0;
  static const int tabTracking = 1;
  static const int tabFinance = 2;
  static const int tabNotifications = 3;
  static const int tabMore = 4;

  /// Switch to a specific tab from anywhere in the widget tree
  static void switchToTab(BuildContext context, int tabIndex) {
    final state = context.findAncestorStateOfType<_ParentMainScreenState>();
    state?._switchTab(tabIndex);
  }

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _currentIndex = 0;
  late final ParentRepository _repository;

  final _screens = const [
    ParentDashboardScreen(),
    ParentTrackingScreen(),
    ParentFinanceScreen(),
    ParentNotificationsScreen(),
    ParentMoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _repository = diContainer.get<ParentRepository>();
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
        RepositoryProvider<ParentRepository>.value(value: _repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ChildrenSelectorCubit(repository: _repository)
              ..loadChildren(),
          ),
          BlocProvider(
            create: (_) => ParentDashboardCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) => ParentTrackingCubit(repository: _repository),
          ),
          BlocProvider(
            create: (_) => ParentFinanceCubit(repository: _repository),
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SimpleGradientBackground(
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
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: 'Theo dõi',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: 'Tài chính',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Thông báo',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                selectedIcon: Icon(Icons.more_horiz),
                label: 'Thêm',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
