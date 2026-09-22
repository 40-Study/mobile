import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/account/account_state.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/widgets/cached_avatar.dart';

/// Avatar section với camera button và change photo
class EditProfileAvatar extends StatelessWidget {
  const EditProfileAvatar({
    super.key,
    required this.pickedImagePath,
    required this.onPickImage,
  });

  final String? pickedImagePath;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String? avatarUrl;
        var initials = '?';

        if (authState is AuthAuthenticated) {
          avatarUrl = authState.user.avatarUrl;
          final name = authState.user.fullName ?? authState.user.username ?? 'U';
          initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
        }

        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accountState) {
            final isUploading = accountState is AccountUpdating;

            return Column(
              children: [
                GestureDetector(
                  onTap: isUploading ? null : onPickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.primary, width: 3),
                        ),
                        child: ClipOval(
                          child: pickedImagePath != null
                              ? Image.file(
                                  File(pickedImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : CachedAvatar(
                                  url: avatarUrl,
                                  radius: 47,
                                  backgroundColor: cs.primaryContainer,
                                  placeholder: Text(
                                    initials,
                                    style: tt.headlineMedium?.copyWith(
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black38,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isUploading ? null : onPickImage,
                  child: Text(
                    AppLocalizations.of(context)!.changePhoto,
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
