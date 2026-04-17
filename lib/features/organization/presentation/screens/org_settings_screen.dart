import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';
import 'package:study/widgets/together_settings.dart';

/// Organization Settings Screen - Together AI Design
class OrgSettingsScreen extends StatelessWidget {
  const OrgSettingsScreen({super.key});

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
                    role: 'Quan ly to chuc',
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

            // Organization Section
            TogetherSettingsSection(
              title: 'To chuc',
              children: [
                TogetherSettingsTile(
                  icon: Icons.domain,
                  title: 'Thong tin to chuc',
                  subtitle: 'Ten, dia chi, logo to chuc',
                  onTap: () => _showOrganizationInfo(context),
                ),
                TogetherSettingsTile(
                  icon: Icons.people_outline,
                  title: 'Phan quyen',
                  subtitle: 'Quan ly quyen giao vien',
                  onTap: () => _showPermissionSettings(context),
                ),
                TogetherSettingsTile(
                  icon: Icons.payment_outlined,
                  title: 'Thanh toan',
                  subtitle: 'Cau hinh nhan thanh toan',
                  onTap: () => _showPaymentSettings(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Notifications Section
            TogetherSettingsSection(
              title: 'Thong bao',
              children: [
                TogetherSettingsToggle(
                  icon: Icons.person_add_outlined,
                  title: 'Hoc vien moi',
                  subtitle: 'Thong bao khi co hoc vien dang ky',
                  value: true,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.request_quote_outlined,
                  title: 'Yeu cau giao vien',
                  subtitle: 'Thong bao yeu cau tu giao vien',
                  value: true,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.attach_money,
                  title: 'Thanh toan',
                  subtitle: 'Thong bao khi co thanh toan moi',
                  value: true,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.summarize_outlined,
                  title: 'Bao cao hang tuan',
                  subtitle: 'Nhan email bao cao moi tuan',
                  value: false,
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
                  title: 'Tai lieu huong dan',
                  subtitle: 'Huong dan su dung he thong',
                  onTap: () {},
                ),
                TogetherSettingsTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Lien he ho tro',
                  subtitle: 'Hotline: 1900-xxxx',
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

  void _showOrganizationInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thong tin to chuc',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Ten to chuc',
                hintText: 'Nhap ten to chuc',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Dia chi',
                hintText: 'Nhap dia chi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email lien he',
                hintText: 'Nhap email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Da luu thong tin to chuc'),
                      backgroundColor: cs.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
                child: const Text('Luu thay doi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionSettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phan quyen giao vien',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tao khoa hoc'),
              subtitle: const Text('Giao vien co the tao khoa hoc moi'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Chinh sua gia'),
              subtitle: const Text('Giao vien co the thay doi gia'),
              value: false,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Xem bao cao'),
              subtitle: const Text('Giao vien co the xem bao cao tai chinh'),
              value: true,
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Da luu phan quyen'),
                      backgroundColor: cs.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
                child: const Text('Luu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSettings(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text('Cau hinh thanh toan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue),
              title: const Text('Tai khoan ngan hang'),
              subtitle: const Text('Vietcombank - ****1234'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.pink),
              title: const Text('MoMo'),
              subtitle: const Text('Chua ket noi'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Ket noi'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.percent, color: Theme.of(context).colorScheme.primary),
              title: const Text('Ti le chia se'),
              subtitle: const Text('To chuc: 30% - Giao vien: 70%'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dong'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '40Study - To chuc',
      applicationVersion: 'v1.0.0 (Build 100)',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.domain,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: const [
        Text('Quan ly to chuc giao duc 40Study'),
        SizedBox(height: 8),
        Text('© 2026 40Study. All rights reserved.'),
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              authBloc.add(AuthLoggedOut());
            },
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
  }
}
