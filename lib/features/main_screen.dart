import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/student/presentation/student_shell.dart';

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

        final roleName = state.activeProfile?.roleName ?? 'student';

        // Route theo role
        switch (roleName.toLowerCase()) {
          case 'student':
            return const StudentShell();
          // TODO: Add other role shells
          // case 'teacher':
          //   return const TeacherShell();
          // case 'parent':
          //   return const ParentShell();
          default:
            return const StudentShell();
        }
      },
    );
  }
}
