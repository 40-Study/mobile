import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/parent/presentation/parent_shell.dart';
import 'package:study/features/student/presentation/student_shell.dart';
import 'package:study/features/teacher/presentation/profile/teacher_applicant_screen.dart';
import 'package:study/features/teacher/presentation/teacher_shell.dart';

/// Main screen sau khi login - route đến shell theo role
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = state.activeProfile;
        if (profile == null) return const _InvalidSessionView();

        // Route theo role, role lạ → không default về StudentShell
        switch (profile.roleName.toLowerCase()) {
          case 'student':
            return const StudentShell();
          case 'parent':
            return const ParentShell();
          case 'teacher':
            return TeacherShell(
              key: ValueKey(
                '${state.user.id}/${state.activeProfile?.id}/teacher',
              ),
            );
          case 'teacherapplicant':
          case 'teacher_applicant':
            return TeacherApplicantScreen(
              key: ValueKey(
                '${state.user.id}/${state.activeProfile?.id}/applicant',
              ),
            );
          default:
            return const _InvalidSessionView();
        }
      },
    );
  }
}

/// Session không xác định được role → cho user đăng xuất để login lại
class _InvalidSessionView extends StatelessWidget {
  const _InvalidSessionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Không xác định được vai trò của tài khoản.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.read<AuthBloc>().add(AuthLoggedOut()),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
