import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/teacher/presentation/screens/switch_role_screen.dart';
import 'package:study/widgets/together_settings.dart';

/// System Admin Settings Screen - Together AI Design
class BISettingsScreen extends StatelessWidget {
  const BISettingsScreen({super.key});

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
                    role: 'Quan tri he thong',
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

            // Platform Section
            TogetherSettingsSection(
              title: 'Nen tang',
              children: [
                TogetherSettingsTile(
                  icon: Icons.domain,
                  title: 'Thong tin nen tang',
                  subtitle: 'Ten, mo ta, logo nen tang',
                  onTap: () => _showPlatformInfo(context),
                ),
                TogetherSettingsTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Quan ly trung tam',
                  subtitle: 'Cau hinh quy tac cho trung tam',
                  onTap: () => _showCenterSettings(context),
                ),
                TogetherSettingsTile(
                  icon: Icons.payment_outlined,
                  title: 'Thanh toan & Chia se',
                  subtitle: 'Ti le chia se doanh thu',
                  onTap: () => _showPaymentSettings(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Data & Reports Section
            TogetherSettingsSection(
              title: 'Du lieu & Bao cao',
              children: [
                TogetherSettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Xuat bao cao',
                  subtitle: 'Tai xuong du lieu Excel, PDF',
                  onTap: () => _showExportOptions(context),
                ),
                TogetherSettingsTile(
                  icon: Icons.schedule_outlined,
                  title: 'Bao cao tu dong',
                  subtitle: 'Len lich gui bao cao qua email',
                  onTap: () => _showScheduledReports(context),
                ),
                TogetherSettingsTile(
                  icon: Icons.sync,
                  title: 'Dong bo du lieu',
                  subtitle: 'Cap nhat lan cuoi: Hom nay, 14:30',
                  onTap: () => _showSyncSettings(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Notifications Section
            TogetherSettingsSection(
              title: 'Thong bao',
              children: [
                TogetherSettingsToggle(
                  icon: Icons.domain_add_outlined,
                  title: 'Trung tam moi',
                  subtitle: 'Thong bao khi co trung tam dang ky',
                  value: true,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.warning_amber_outlined,
                  title: 'Canh bao hieu suat',
                  subtitle: 'Thong bao khi trung tam giam hieu suat',
                  value: true,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.attach_money,
                  title: 'Bao cao doanh thu',
                  subtitle: 'Thong bao doanh thu hang ngay',
                  value: true,
                  onChanged: (_) {},
                ),
                TogetherSettingsToggle(
                  icon: Icons.summarize_outlined,
                  title: 'Bao cao hang tuan',
                  subtitle: 'Nhan email tong hop moi tuan',
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
                  onTap: () => _showHelp(context),
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

  void _showPlatformInfo(BuildContext context) {
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
              'Thong tin nen tang',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Ten nen tang',
                hintText: 'Nhap ten nen tang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Mo ta',
                hintText: 'Nhap mo ta nen tang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
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
                      content: const Text('Da luu thong tin nen tang'),
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

  void _showCenterSettings(BuildContext context) {
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
              'Quy tac trung tam',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
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
              leading: Icon(Icons.percent, color: Theme.of(context).colorScheme.primary),
              title: const Text('Ti le chia se mac dinh'),
              subtitle: const Text('Nen tang: 15% - Trung tam: 85%'),
            ),
            ListTile(
              leading: Icon(Icons.timer, color: Theme.of(context).colorScheme.tertiary),
              title: const Text('Chu ky thanh toan'),
              subtitle: const Text('Hang thang (ngay 15)'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xuat bao cao',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bao cao tu dong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
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
                  borderRadius: BorderRadius.circular(4),
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

  void _showSyncSettings(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text('Dong bo du lieu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Trang thai'),
              subtitle: const Text('Da dong bo'),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: cs.primary),
              title: const Text('Lan cuoi'),
              subtitle: const Text('17/04/2026 14:30'),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: const Text('Tro giup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Huong dan su dung'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Video huong dan'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic_outlined),
              title: const Text('Lien he ho tro'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.admin_panel_settings,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: const [
        Text('Quan ly nen tang giao duc 40Study'),
        SizedBox(height: 8),
        Text('(c) 2026 40Study. All rights reserved.'),
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
