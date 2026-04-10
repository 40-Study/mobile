import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';

class OrgSettingsScreen extends StatelessWidget {
  const OrgSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Cai dat to chuc',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Tai khoan',
              [
                _SettingItem(
                  icon: Icons.person,
                  title: 'Thong tin ca nhan',
                  subtitle: 'Chinh sua ten, email, avatar',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _SettingItem(
                  icon: Icons.lock,
                  title: 'Bao mat',
                  subtitle: 'Mat khau, xac thuc 2 lop',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SecurityScreen(),
                      ),
                    );
                  },
                ),
                _SettingItem(
                  icon: Icons.swap_horiz,
                  title: 'Chuyen doi vai tro',
                  subtitle: 'Chuyen sang vai tro khac',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SwitchRoleScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'To chuc',
              [
                _SettingItem(
                  icon: Icons.domain,
                  title: 'Thong tin to chuc',
                  subtitle: 'Ten, dia chi, logo to chuc',
                  onTap: () => _showOrganizationInfo(context),
                ),
                _SettingItem(
                  icon: Icons.notifications,
                  title: 'Thong bao',
                  subtitle: 'Cau hinh thong bao',
                  onTap: () => _showNotificationSettings(context),
                ),
                _SettingItem(
                  icon: Icons.people,
                  title: 'Phan quyen',
                  subtitle: 'Quan ly quyen giao vien',
                  onTap: () => _showPermissionSettings(context),
                ),
                _SettingItem(
                  icon: Icons.payment,
                  title: 'Thanh toan',
                  subtitle: 'Cau hinh nhan thanh toan',
                  onTap: () => _showPaymentSettings(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Khac',
              [
                _SettingItem(
                  icon: Icons.help,
                  title: 'Tro giup',
                  subtitle: 'Tai lieu huong dan',
                  onTap: () => _showHelp(context),
                ),
                _SettingItem(
                  icon: Icons.info,
                  title: 'Phien ban',
                  subtitle: 'v1.0.0 (Build 100)',
                  onTap: () => _showAbout(context),
                ),
                _SettingItem(
                  icon: Icons.logout,
                  title: 'Dang xuat',
                  subtitle: '',
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showOrganizationInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thong tin to chuc',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Ten to chuc',
                  hintText: 'Nhap ten to chuc',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Dia chi',
                  hintText: 'Nhap dia chi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'So dien thoai',
                  hintText: 'Nhap so dien thoai',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhap email lien he',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                      ),
                    );
                  },
                  child: const Text('Luu thay doi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cai dat thong bao',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Hoc vien moi dang ky'),
              subtitle: const Text('Nhan thong bao khi co hoc vien moi'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Giao vien yeu cau'),
              subtitle: const Text('Nhan thong bao yeu cau tu giao vien'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Thanh toan'),
              subtitle: const Text('Nhan thong bao khi co thanh toan moi'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Bao cao hang tuan'),
              subtitle: const Text('Nhan email bao cao moi tuan'),
              value: false,
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
                      content: const Text('Da luu cai dat thong bao'),
                      backgroundColor: cs.primary,
                      behavior: SnackBarBehavior.floating,
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

  void _showPermissionSettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phan quyen giao vien',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Tao khoa hoc'),
              subtitle: const Text('Giao vien co the tao khoa hoc moi'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Chinh sua gia'),
              subtitle: const Text('Giao vien co the thay doi gia khoa hoc'),
              value: false,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Xem bao cao tai chinh'),
              subtitle: const Text('Giao vien co the xem bao cao'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Quan ly hoc vien'),
              subtitle: const Text('Giao vien co the them/xoa hoc vien'),
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
                      content: const Text('Da luu cai dat phan quyen'),
                      backgroundColor: cs.primary,
                      behavior: SnackBarBehavior.floating,
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
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cau hinh thanh toan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.blue),
              title: const Text('Tai khoan ngan hang'),
              subtitle: const Text('Vietcombank - ****1234'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
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
              leading: Icon(Icons.percent, color: cs.primary),
              title: const Text('Ti le chia se'),
              subtitle: const Text('To chuc: 30% - Giao vien: 70%'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
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

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tro giup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Huong dan su dung'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video huong dan'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('Lien he ho tro'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat voi ho tro'),
              onTap: () {},
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
      applicationName: '40Study - Chu to chuc',
      applicationVersion: 'v1.0.0 (Build 100)',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.domain,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: [
        const Text('Quan ly to chuc giao duc 40Study'),
        const SizedBox(height: 8),
        const Text('© 2026 40Study. All rights reserved.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dang xuat'),
        content: const Text('Ban co chac chan muon dang xuat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLoggedOut());
            },
            child: const Text('Dang xuat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_SettingItem> items) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (item.iconColor ?? cs.primary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor ?? cs.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: item.titleColor,
                      ),
                    ),
                    subtitle: item.subtitle.isNotEmpty
                        ? Text(
                            item.subtitle,
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          )
                        : null,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: cs.onSurface.withValues(alpha: 0.3),
                    ),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: cs.outline.withValues(alpha: 0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
}
