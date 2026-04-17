import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/organization/presentation/screens/organization_main_screen.dart';
import 'package:study/features/parent/presentation/screens/parent_main_screen.dart';
import 'package:study/features/student/presentation/screens/student_main_screen.dart';
import 'package:study/features/system_admin/presentation/screens/bi_main_screen.dart';
import 'package:study/features/teacher/presentation/screens/teacher_main_screen.dart';
import 'package:study/generated/l10n.dart';
import 'package:study/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        debugPrint('🏠 HomeScreen buildWhen: previous=$previous, current=$current');
        return true;
      },
      builder: (context, authState) {
        debugPrint('🏠 HomeScreen building with state: $authState');
        if (authState is AuthAuthenticated) {
          return _buildRoleBasedScreen(authState);
        }
        return const _DefaultHomeScreen();
      },
    );
  }

  Widget _buildRoleBasedScreen(AuthAuthenticated authState) {
    // Debug: Print current role
    debugPrint('🔐 Current role: ${authState.roleName}');
    debugPrint('🔐 isTeacher: ${authState.isTeacher}');
    debugPrint('🔐 isStudent: ${authState.isStudent}');
    debugPrint('🔐 isParent: ${authState.isParent}');
    debugPrint('🔐 isOrganizationOwner: ${authState.isOrganizationOwner}');
    debugPrint('🔐 isAdmin: ${authState.isAdmin}');

    if (authState.isAdmin) {
      return const BIMainScreen();
    }
    if (authState.isOrganizationOwner) {
      return const OrganizationMainScreen();
    }
    if (authState.isTeacher) {
      return const TeacherMainScreen();
    }
    if (authState.isStudent) {
      return const StudentMainScreen();
    }
    if (authState.isParent) {
      return const ParentMainScreen();
    }
    // Default to teacher screen if role is unknown
    return const TeacherMainScreen();
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
