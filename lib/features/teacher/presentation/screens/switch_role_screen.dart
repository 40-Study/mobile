import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/profile/profile_cubit.dart';
import 'package:study/features/auth/bloc/profile/profile_state.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/add_profile_screen.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/weather/presentation/widgets/weather_background_wrapper.dart';

class SwitchRoleScreen extends StatefulWidget {
  const SwitchRoleScreen({super.key});

  @override
  State<SwitchRoleScreen> createState() => _SwitchRoleScreenState();
}

class _SwitchRoleScreenState extends State<SwitchRoleScreen> {
  late final ProfileCubit _profileCubit;
  List<RoleModel> _availableRoles = [];
  bool _loadingRoles = false;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit(
      authRepository: diContainer.get<AuthRepository>(),
    )..loadProfiles();
    _loadAvailableRoles();
  }

  Future<void> _loadAvailableRoles() async {
    setState(() => _loadingRoles = true);
    try {
      final authRepo = diContainer.get<AuthRepository>();
      final roles = await authRepo.getSystemRoles();
      setState(() {
        _availableRoles = roles;
        _loadingRoles = false;
      });
    } catch (e) {
      setState(() => _loadingRoles = false);
    }
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return WeatherBackgroundWrapper(
      child: BlocProvider.value(
        value: _profileCubit,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Chuyển đổi vai trò'),
          ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            debugPrint('🔄 ProfileState changed: $state');
            if (state is ProfileSwitched && state.newProfile != null) {
              debugPrint('🔄 Switching to profile: ${state.newProfile!.roleName}');
              debugPrint('🔄 AuthResponse: ${state.authResponse?.activeProfile?.toJson()}');
              context.read<AuthBloc>().add(
                    AuthProfileSwitched(state.authResponse!),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã chuyển sang ${RoleUtils.getLabel(state.newProfile!.roleName)}',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
              Navigator.pop(context);
            }
            if (state is ProfileSwitchFailure) {
              debugPrint('❌ Switch failed: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: cs.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _profileCubit.loadProfiles(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            List<ProfileModel> profiles = [];
            String? switchingId;

            if (state is ProfileLoaded) {
              profiles = state.profiles;
            } else if (state is ProfileSwitching) {
              profiles = state.profiles;
              switchingId = state.switchingProfileId;
            } else if (state is ProfileSwitched) {
              profiles = state.profiles;
            } else if (state is ProfileSwitchFailure) {
              profiles = state.profiles;
            }

            final authState = context.read<AuthBloc>().state;
            String? currentProfileId;
            if (authState is AuthAuthenticated) {
              currentProfileId = authState.activeProfile?.id;
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header illustration
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primaryContainer,
                        cs.primaryContainer.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.swap_horizontal_circle_outlined,
                        size: 64,
                        color: cs.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chọn vai trò của bạn',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current roles section
                Text(
                  'VAI TRÒ CỦA BẠN',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                if (profiles.isEmpty)
                  _EmptyRolesCard()
                else
                  ...profiles.map((profile) {
                    final isCurrentProfile = profile.id == currentProfileId;
                    final isSwitching = switchingId == profile.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoleCard(
                        profile: profile,
                        isSelected: isCurrentProfile,
                        isLoading: isSwitching,
                        onTap: isCurrentProfile || isSwitching
                            ? null
                            : () async {
                                await _profileCubit.switchProfile(
                                  profileType: profile.type,
                                  profileId: profile.id,
                                );
                              },
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Add new role section
                Text(
                  'THÊM VAI TRÒ MỚI',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _AddRoleCard(
                  availableRoles: _availableRoles,
                  existingProfiles: profiles,
                  isLoading: _loadingRoles,
                  onAddRole: _navigateToAddProfile,
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => const AddProfileScreen(),
      ),
    );

    if (result == true && mounted) {
      await _profileCubit.loadProfiles();
      await _loadAvailableRoles();
    }
  }
}

class _EmptyRolesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 48,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có vai trò nào',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm vai trò mới để bắt đầu',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.profile,
    required this.isSelected,
    required this.isLoading,
    this.onTap,
  });

  final ProfileModel profile;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [cs.primary, cs.primary.withValues(alpha: 0.7)]
                        : [cs.surfaceContainerHighest, cs.surfaceContainerHigh],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isSelected ? Colors.white : cs.primary,
                          ),
                        ),
                      )
                    : Icon(
                        RoleUtils.getIcon(profile.roleName),
                        color: isSelected ? Colors.white : cs.onSurfaceVariant,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      RoleUtils.getLabel(profile.roleName),
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? cs.primary : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.organizationName ?? 'Vai trò hệ thống',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Status
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
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

class _AddRoleCard extends StatelessWidget {
  const _AddRoleCard({
    required this.availableRoles,
    required this.existingProfiles,
    required this.isLoading,
    required this.onAddRole,
  });

  final List<RoleModel> availableRoles;
  final List<ProfileModel> existingProfiles;
  final bool isLoading;
  final VoidCallback onAddRole;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Check if there are roles to add
    final existingRoleNames = existingProfiles
        .map((p) => p.roleName.toUpperCase())
        .toSet();
    final canAddMore = availableRoles.any(
      (r) => !existingRoleNames.contains(r.name.toUpperCase()),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canAddMore && !isLoading ? onAddRole : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: cs.outlineVariant,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.add,
                        color: cs.primary,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canAddMore ? 'Thêm vai trò mới' : 'Đã có tất cả vai trò',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: canAddMore ? cs.primary : cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canAddMore
                          ? 'Mở rộng quyền truy cập của bạn'
                          : 'Bạn đã sở hữu tất cả các vai trò',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (canAddMore)
                Icon(
                  Icons.chevron_right,
                  color: cs.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

