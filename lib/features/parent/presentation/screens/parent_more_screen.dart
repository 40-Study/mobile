import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';
import 'package:study/widgets/together_settings.dart';

/// Parent Settings Screen - Together AI Design
class ParentMoreScreen extends StatelessWidget {
  const ParentMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppLayout.screenMargin),
          children: [
            // Header
            Text(
              'Cai dat',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Profile Header
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return TogetherProfileHeader(
                    name: state.user.fullName ?? state.user.username ?? 'User',
                    email: state.user.email,
                    avatarUrl: state.user.avatarUrl,
                    role: 'Phu huynh',
                    onEditTap: () => _navigateTo(context, const EditProfileScreen()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Account Section
            TogetherSettingsSection(
              title: 'Tai khoan',
              children: [
                TogetherSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Thong tin ca nhan',
                  subtitle: 'Chinh sua ten, email, avatar',
                  onTap: () => _navigateTo(context, const EditProfileScreen()),
                ),
                TogetherSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Bao mat',
                  subtitle: 'Mat khau, xac thuc 2 lop',
                  onTap: () => _navigateTo(context, const SecurityScreen()),
                ),
                TogetherSettingsTile(
                  icon: Icons.swap_horiz,
                  title: 'Chuyen doi vai tro',
                  subtitle: 'Chuyen sang vai tro khac',
                  onTap: () => _navigateTo(context, const SwitchRoleScreen()),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Notifications Section
            TogetherSettingsSection(
              title: 'Thong bao',
              children: [
                TogetherSettingsToggle(
                  icon: Icons.notifications_outlined,
                  title: 'Thong bao push',
                  subtitle: 'Nhan thong bao tren dien thoai',
                  value: true,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.email_outlined,
                  title: 'Email thong bao',
                  subtitle: 'Nhan thong bao qua email',
                  value: false,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.school_outlined,
                  title: 'Ket qua hoc tap',
                  subtitle: 'Thong bao khi con co diem moi',
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Support Section
            TogetherSettingsSection(
              title: 'Ho tro',
              children: [
                TogetherSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Trung tam tro giup',
                  subtitle: 'Cau hoi thuong gap',
                  onTap: () {},
                ),
                TogetherSettingsTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Lien he ho tro',
                  subtitle: 'Chat voi doi ngu ho tro',
                  onTap: () {},
                ),
                TogetherSettingsTile(
                  icon: Icons.info_outline,
                  title: 'Phien ban',
                  subtitle: 'v1.0.0 (Build 100)',
                  showChevron: false,
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Danger Zone
            TogetherDangerSection(
              children: [
                TogetherSettingsTile(
                  icon: Icons.logout,
                  title: 'Dang xuat',
                  iconColor: cs.error,
                  titleColor: cs.error,
                  showChevron: false,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '40Study',
      applicationVersion: 'v1.0.0 (Build 100)',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.school,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: const [
        Text('Ung dung ho tro phu huynh theo doi viec hoc cua con.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text('Dang xuat'),
        content: const Text('Ban co chac chan muon dang xuat khoi tai khoan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              authBloc.add(AuthLoggedOut());
            },
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
  }
}
