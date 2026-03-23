import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/teacher/presentation/screens/teacher_main_screen.dart';
import 'package:study/generated/l10n.dart';
import 'package:study/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Show TeacherMainScreen for any authenticated user (temporarily)
        // TODO: Add role-based routing when other dashboards are ready
        if (authState is AuthAuthenticated) {
          return const TeacherMainScreen();
        }

        // Default home screen for unauthenticated
        return const _DefaultHomeScreen();
      },
    );
  }
}

class _DefaultHomeScreen extends StatelessWidget {
  const _DefaultHomeScreen();

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Đăng xuất',
            onPressed: () {
              context.read<AuthBloc>().add(AuthLoggedOut());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => navigator.navigateTo(Routes.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => navigator.navigateTo(Routes.appearance),
              icon: const Icon(Icons.palette_outlined),
              label: Text(S.of(context).themeTitle),
            ),
          ],
        ),
      ),
    );
  }
}
