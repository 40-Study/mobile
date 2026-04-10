import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';

/// Man hinh Cai dat cho System Admin
class BISettingsScreen extends StatelessWidget {
  const BISettingsScreen({super.key});

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
          'Cai dat he thong',
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
              'Nen tang',
              [
                _SettingItem(
                  icon: Icons.domain,
                  title: 'Thong tin nen tang',
                  subtitle: 'Ten, mo ta, logo nen tang',
                  onTap: () => _showPlatformInfo(context),
                ),
                _SettingItem(
                  icon: Icons.notifications,
                  title: 'Thong bao',
                  subtitle: 'Cau hinh thong bao he thong',
                  onTap: () => _showNotificationSettings(context),
                ),
                _SettingItem(
                  icon: Icons.admin_panel_settings,
                  title: 'Quan ly trung tam',
                  subtitle: 'Cau hinh quy tac cho trung tam',
                  onTap: () => _showCenterSettings(context),
                ),
                _SettingItem(
                  icon: Icons.payment,
                  title: 'Thanh toan & Chia se',
                  subtitle: 'Cau hinh ti le chia se doanh thu',
                  onTap: () => _showPaymentSettings(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Du lieu & Bao cao',
              [
                _SettingItem(
                  icon: Icons.download,
                  title: 'Xuat bao cao',
                  subtitle: 'Tai xuong du lieu Excel, PDF',
                  onTap: () => _showExportOptions(context),
                ),
                _SettingItem(
                  icon: Icons.schedule,
                  title: 'Bao cao tu dong',
                  subtitle: 'Len lich gui bao cao qua email',
                  onTap: () => _showScheduledReports(context),
                ),
                _SettingItem(
                  icon: Icons.sync,
                  title: 'Dong bo du lieu',
                  subtitle: 'Cap nhat lan cuoi: Hom nay, 14:30',
                  onTap: () => _showSyncSettings(context),
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

  void _showPlatformInfo(BuildContext context) {
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
                'Thong tin nen tang',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Ten nen tang',
                  hintText: 'Nhap ten nen tang',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Mo ta',
                  hintText: 'Nhap mo ta nen tang',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email ho tro',
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
                        content: const Text('Da luu thong tin nen tang'),
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
              title: const Text('Trung tam moi'),
              subtitle: const Text('Thong bao khi co trung tam dang ky'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Canh bao hieu suat'),
              subtitle: const Text('Thong bao khi trung tam giam hieu suat'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Bao cao doanh thu'),
              subtitle: const Text('Thong bao doanh thu hang ngay'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Bao cao hang tuan'),
              subtitle: const Text('Nhan email tong hop moi tuan'),
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

  void _showCenterSettings(BuildContext context) {
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
              'Quy tac trung tam',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Tu dong phe duyet'),
              subtitle: const Text('Trung tam moi duoc phe duyet tu dong'),
              value: false,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Yeu cau xac minh'),
              subtitle: const Text('Trung tam phai xac minh tai lieu'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Gioi han khoa hoc'),
              subtitle: const Text('Ap dung gioi han so luong khoa hoc'),
              value: false,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Kiem duyet noi dung'),
              subtitle: const Text('Duyet noi dung truoc khi xuat ban'),
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
                      content: const Text('Da luu quy tac trung tam'),
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
              subtitle: const Text('Vietcombank - ****5678'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.pink),
              title: const Text('VNPay'),
              subtitle: const Text('Da ket noi'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.percent, color: cs.primary),
              title: const Text('Ti le chia se mac dinh'),
              subtitle: const Text('Nen tang: 15% - Trung tam: 85%'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
            ListTile(
              leading: Icon(Icons.timer, color: cs.tertiary),
              title: const Text('Chu ky thanh toan'),
              subtitle: const Text('Hang thang (ngay 15)'),
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

  void _showExportOptions(BuildContext context) {
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
              'Xuat bao cao',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.table_chart, color: Colors.green),
              ),
              title: const Text('Xuat Excel'),
              subtitle: const Text('Bao cao doanh thu, trung tam'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Dang xuat file Excel...'),
                    backgroundColor: cs.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('Xuat PDF'),
              subtitle: const Text('Bao cao tong hop co bieu do'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Dang xuat file PDF...'),
                    backgroundColor: cs.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code, color: Colors.blue),
              ),
              title: const Text('Xuat JSON/CSV'),
              subtitle: const Text('Du lieu tho de xu ly'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Dang xuat du lieu...'),
                    backgroundColor: cs.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduledReports(BuildContext context) {
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
              'Bao cao tu dong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Bao cao hang ngay'),
              subtitle: const Text('Gui luc 8:00 sang'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Bao cao hang tuan'),
              subtitle: const Text('Gui vao thu 2 hang tuan'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              title: const Text('Bao cao hang thang'),
              subtitle: const Text('Gui vao ngay 1 hang thang'),
              value: true,
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email nhan bao cao',
                hintText: 'Nhap email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Da luu cai dat bao cao'),
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

  void _showSyncSettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dong bo du lieu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Trang thai'),
              subtitle: const Text('Da dong bo'),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: cs.primary),
              title: const Text('Lan cuoi'),
              subtitle: const Text('10/04/2026 14:30'),
            ),
            ListTile(
              leading: Icon(Icons.storage, color: cs.tertiary),
              title: const Text('Du lieu'),
              subtitle: const Text('156 trung tam, 2.4M giao dich'),
            ),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Dang dong bo du lieu...'),
                      backgroundColor: cs.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text('Dong bo ngay'),
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
      applicationName: '40Study - System Admin',
      applicationVersion: 'v1.0.0 (Build 100)',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.admin_panel_settings,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: [
        const Text('Quan ly nen tang giao duc 40Study'),
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

  Widget _buildSection(
      BuildContext context, String title, List<_SettingItem> items) {
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
                        color:
                            (item.iconColor ?? cs.primary).withValues(alpha: 0.1),
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
