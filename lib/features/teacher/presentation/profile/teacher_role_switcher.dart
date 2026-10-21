import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/profile/profile_cubit.dart';
import 'package:study/features/auth/bloc/profile/profile_state.dart';
import 'package:study/features/auth/data/models/profile_model.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class TeacherRoleSwitcher extends StatelessWidget {
  const TeacherRoleSwitcher({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        ProfileCubit(authRepository: context.read<AuthRepository>())
          ..loadProfiles(),
    child: BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSwitched && state.authResponse != null) {
          context.read<AuthBloc>().add(
            AuthProfileSwitched(state.authResponse!),
          );
        }
        if (state is ProfileSwitchFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final profiles = switch (state) {
          ProfileLoaded(:final profiles) => profiles,
          ProfileSwitching(:final profiles) => profiles,
          ProfileSwitched(:final profiles) => profiles,
          ProfileSwitchFailure(:final profiles) => profiles,
          _ => <ProfileModel>[],
        };
        if (state is ProfileLoading) return const LinearProgressIndicator();
        if (state is ProfileFailure) {
          return TextButton(
            onPressed: () => context.read<ProfileCubit>().loadProfiles(),
            child: Text('${state.message} · Thử lại'),
          );
        }
        final auth = context.watch<AuthBloc>().state;
        final currentId = auth is AuthAuthenticated
            ? auth.activeProfile?.id
            : null;
        return Column(
          children: profiles
              .map(
                (profile) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(RoleUtils.getLabel(profile.roleName)),
                  subtitle: profile.organizationName == null
                      ? null
                      : Text(profile.organizationName!),
                  leading: Icon(RoleUtils.getIcon(profile.roleName)),
                  trailing: profile.id == currentId
                      ? const Icon(Icons.check)
                      : const Icon(Icons.chevron_right),
                  onTap: profile.id == currentId || state is ProfileSwitching
                      ? null
                      : () =>
                            context.read<ProfileCubit>().switchProfile(profile),
                ),
              )
              .toList(),
        );
      },
    ),
  );
}
