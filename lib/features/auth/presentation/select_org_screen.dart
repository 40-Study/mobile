import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/login/login_bloc.dart';
import 'package:study/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:study/features/auth/presentation/widgets/auth_gradient_header.dart';
import 'package:study/routes/router.dart';

class SelectOrgScreen extends StatelessWidget {
  const SelectOrgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final navigator = NavigationService.of(context);
    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is! LoginNeedOrg) {
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
            case LoginFailure(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            case LoginInitial():
            case LoginInProgress():
            case LoginNeedRole():
            case LoginNeedOrg():
              break;
          }
        },
        child: Column(
          children: [
            const AuthGradientHeader(
              title: 'Chọn tổ chức',
              subtitle:
                  'Chọn tổ chức bạn muốn hoạt động',
              height: 220,
              showBackButton: true,
            ),
            Expanded(
              child: AuthFormCard(
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final isLoading =
                        state is LoginInProgress;
                    final total =
                        args.organizations.length + 1;

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        24, 28, 24, 24,
                      ),
                      itemCount: total,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index ==
                            args.organizations.length) {
                          return _OrgTile(
                            icon: Icons.person_outline,
                            label: 'Độc lập',
                            subtitle:
                                'Không thuộc tổ chức nào',
                            color: cs.secondary,
                            isLoading: isLoading,
                            onTap: () {
                              context
                                  .read<LoginBloc>()
                                  .add(LoginOrgSelected(
                                    sessionToken: args
                                        .sessionToken,
                                  ));
                            },
                          );
                        }

                        final org =
                            args.organizations[index];
                        return _OrgTile(
                          icon: Icons.business_outlined,
                          label: org.name,
                          color: cs.primary,
                          isLoading: isLoading,
                          onTap: () {
                            context
                                .read<LoginBloc>()
                                .add(LoginOrgSelected(
                                  sessionToken:
                                      args.sessionToken,
                                  organizationId: org.id,
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
}

class _OrgTile extends StatelessWidget {
  const _OrgTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
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
