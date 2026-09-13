import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/children/children_bloc.dart';
import 'package:study/features/parent/bloc/children/children_event.dart';
import 'package:study/features/parent/bloc/children/children_state.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_bloc.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_event.dart';
import 'package:study/features/parent/presentation/dashboard/parent_dashboard_screen.dart';
import 'package:study/features/parent/repository/parent_repository.dart';
import 'package:study/theme/theme.dart';

enum ParentTab { dashboard, progress, attendance, schedule, expenses }

class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  ParentTab _currentTab = ParentTab.dashboard;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChildrenBloc(diContainer<ParentRepository>())
            ..add(ChildrenStarted()),
        ),
        BlocProvider(create: (_) => ChildSelectorCubit()),
      ],
      child: BlocConsumer<ChildrenBloc, ChildrenState>(
        listener: (context, state) {
          if (state is ChildrenSuccess) {
            context.read<ChildSelectorCubit>().setChildren(state.children);
          }
        },
        builder: (context, childrenState) {
          // Loading
          if (childrenState is ChildrenInitial ||
              childrenState is ChildrenLoading) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: Center(
                child: CircularProgressIndicator(color: cs.primary),
              ),
            );
          }

          // Error
          if (childrenState is ChildrenFailure) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: cs.error,
                        size: 28,
                      ),
                    ),
                    AppSpacing.vGap16,
                    Text(
                      childrenState.message,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vGap24,
                    FilledButton.icon(
                      onPressed: () {
                        context.read<ChildrenBloc>().add(ChildrenRefreshed());
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Success
          final children = (childrenState as ChildrenSuccess).children;
          if (children.isEmpty) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: _buildEmptyState(context),
            );
          }

          return BlocProvider(
            create: (ctx) => ParentDashboardBloc(
              diContainer<ParentRepository>(),
              ctx.read<ChildSelectorCubit>(),
            )..add(ParentDashboardStarted()),
            child: Scaffold(
              appBar: _buildAppBar(context),
              body: _buildBody(),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentTab.index,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentTab = ParentTab.values[index];
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Trang chủ',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.trending_up_outlined),
                    selectedIcon: Icon(Icons.trending_up_rounded),
                    label: 'Tiến độ',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today_rounded),
                    label: 'Điểm danh',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.schedule_outlined),
                    selectedIcon: Icon(Icons.schedule_rounded),
                    label: 'Lịch học',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.payments_outlined),
                    selectedIcon: Icon(Icons.payments_rounded),
                    label: 'Chi phí',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppBar(
      title: Text(
        'Phụ huynh',
        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      actions: [
        IconButton(
          icon: Badge(
            backgroundColor: cs.primary,
            label: Text(
              '3',
              style: tt.labelSmall?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: cs.onSurface,
            ),
          ),
          onPressed: () {},
        ),
        AppSpacing.hGap8,
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom_rounded,
                color: cs.primary,
                size: 40,
              ),
            ),
            AppSpacing.vGap24,
            Text(
              'Chưa có thông tin con',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap8,
            Text(
              'Vui lòng liên kết tài khoản con để theo dõi tiến độ học tập',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap24,
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.link_rounded, size: 18),
              label: const Text('Liên kết con'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_currentTab) {
      ParentTab.dashboard => const ParentDashboardScreen(parentName: null),
      ParentTab.progress => _buildComingSoon('Tiến độ', Icons.trending_up_rounded),
      ParentTab.attendance => _buildComingSoon('Điểm danh', Icons.calendar_today_rounded),
      ParentTab.schedule => _buildComingSoon('Lịch học', Icons.schedule_rounded),
      ParentTab.expenses => _buildComingSoon('Chi phí', Icons.payments_rounded),
    };
  }

  Widget _buildComingSoon(String title, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.onSurfaceVariant, size: 32),
          ),
          AppSpacing.vGap16,
          Text(
            title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.vGap8,
          Text(
            'Đang phát triển',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
