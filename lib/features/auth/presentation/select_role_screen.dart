import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/routes/router.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final navigator = NavigationService.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is! LoginNeedRole) {
      return const Scaffold(
        body: Center(
          child: Text('Dữ liệu không hợp lệ'),
        ),
      );
    }

    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          switch (state) {
            case LoginSuccess(:final response):
              context
                  .read<AuthBloc>()
                  .add(AuthLoggedIn(response));
              navigator.pushAndRemoveAll(Routes.app);
            case LoginNeedOrg():
              navigator.navigateTo(
                Routes.selectOrg,
                state,
                true,
              );
            case LoginFailure(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            case LoginInitial():
            case LoginInProgress():
            case LoginNeedRole():
              break;
          }
        },
        child: Column(
          children: [
            const AuthGradientHeader(
              title: 'Chọn vai trò',
              subtitle:
                  'Bạn có nhiều vai trò, hãy chọn một',
              height: 220,
              showBackButton: true,
            ),
            Expanded(
              child: AuthFormCard(
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final isLoading =
                        state is LoginInProgress;

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        24, 28, 24, 24,
                      ),
                      itemCount: args.roles.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final role = args.roles[index];
                        return _RoleTile(
                          icon: _roleIcon(role.name),
                          label: _roleLabel(role.name),
                          color: cs.primary,
                          isLoading: isLoading,
                          onTap: () {
                            context
                                .read<LoginBloc>()
                                .add(LoginRoleSelected(
                                  sessionToken:
                                      args.sessionToken,
                                  systemRoleId: role.id,
                                ));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _roleIcon(String name) {
    switch (name.toUpperCase()) {
      case 'STUDENT':
        return Icons.school_outlined;
      case 'TEACHER':
        return Icons.person_outlined;
      case 'PARENT':
        return Icons.family_restroom_outlined;
      case 'ORG_OWNER':
        return Icons.business_outlined;
      default:
        return Icons.person_outlined;
    }
  }

  String _roleLabel(String name) {
    switch (name.toUpperCase()) {
      case 'STUDENT':
        return 'Học sinh';
      case 'TEACHER':
        return 'Giáo viên';
      case 'PARENT':
        return 'Phụ huynh';
      case 'ORG_OWNER':
        return 'Chủ tổ chức';
      default:
        return name;
    }
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: cs.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
