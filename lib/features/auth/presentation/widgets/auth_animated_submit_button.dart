import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth_animation_cubit.dart';
import 'package:study/features/auth/presentation/widgets/auth_button.dart';

class AuthAnimatedSubmitButton<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const AuthAnimatedSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool Function(S state) isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final loading = context.select<B, bool>((bloc) => isLoading(bloc.state));
    final success = context.select<AuthAnimationCubit, bool>(
      (cubit) => cubit.state.status == AuthScreenAnimStatus.success,
    );

    return AuthButton(
      label: label,
      isLoading: loading,
      isSuccess: success,
      onPressed: onPressed,
    );
  }
}
