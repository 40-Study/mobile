import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/bloc/security/security_cubit.dart';
import 'package:study/features/auth/bloc/security/security_state.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/change_password_screen.dart';
import 'package:study/features/auth/repository/auth_repository.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  late final SecurityCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SecurityCubit(
      authRepository: diContainer.get<AuthRepository>(),
    )..loadDevices();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: cs.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: cs.surfaceContainerLowest,
          title: const Text('Mật khẩu & Bảo mật'),
        ),
        body: BlocConsumer<SecurityCubit, SecurityState>(
          listener: (context, state) {
            if (state is SecurityPasswordChanged) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đổi mật khẩu thành công')),
              );
            }
            if (state is SecurityLoggedOutAll) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đăng xuất tất cả thiết bị'),
                ),
              );
              context.read<AuthBloc>().add(AuthLoggedOut());
            }
            if (state is SecurityFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            List<DeviceModel> devices = _getDevices(state);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Login section
                _SectionHeader(title: 'Đăng nhập'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsItem(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      subtitle: 'Nên sử dụng mật khẩu mạnh mà bạn không dùng ở nơi khác',
                      onTap: () => _showChangePasswordDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Devices section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionHeader(title: 'Nơi bạn đã đăng nhập'),
                    if (devices.length > 1)
                      TextButton(
                        onPressed: () => _showLogoutAllDialog(),
                        child: Text(
                          'Đăng xuất tất cả',
                          style: TextStyle(color: cs.error),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _DevicesList(
                  devices: devices,
                  isLoading: state is SecurityLoading,
                  onRefresh: () => _cubit.loadDevices(),
                ),
                const SizedBox(height: 24),

                // Advanced section
                _SectionHeader(title: 'Nâng cao'),
                const SizedBox(height: 12),
                _SettingsCard(
                  children: [
                    _SettingsItem(
                      icon: Icons.email_outlined,
                      title: 'Email thông báo bảo mật',
                      subtitle: 'Xem danh sách các email chính thức từ chúng tôi',
                      onTap: () {},
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                    _SettingsItem(
                      icon: Icons.history,
                      title: 'Lịch sử hoạt động',
                      subtitle: 'Xem tất cả các hành động liên quan đến tài khoản',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Column(
                    children: [
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          String accountId = 'N/A';
                          if (authState is AuthAuthenticated) {
                            final id = authState.user.id;
                            accountId = 'ID-${id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase()}';
                          }
                          return Text(
                            'ID tài khoản: $accountId',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '40STUDY SECURITY HUB',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  List<DeviceModel> _getDevices(SecurityState state) {
    return switch (state) {
      SecurityLoaded(:final devices) => devices,
      SecurityChangingPassword(:final devices) => devices,
      SecurityPasswordChanged(:final devices) => devices,
      SecurityLoggingOutAll(:final devices) => devices,
      SecurityFailure(:final devices) => devices,
      _ => [],
    };
  }

  void _showChangePasswordDialog() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
  }

  void _showLogoutAllDialog() {
    final cs = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất tất cả thiết bị'),
        content: const Text(
          'Bạn sẽ bị đăng xuất khỏi tất cả thiết bị, bao gồm cả thiết bị hiện tại. '
          'Bạn sẽ cần đăng nhập lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cubit.logoutAllDevices();
            },
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
            ),
            child: const Text('Đăng xuất tất cả'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Text(
      title,
      style: tt.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(
        title,
        style: tt.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: tt.bodySmall?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}

class _DevicesList extends StatelessWidget {
  const _DevicesList({
    required this.devices,
    required this.isLoading,
    required this.onRefresh,
  });

  final List<DeviceModel> devices;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.devices, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Không có thiết bị nào',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: devices.asMap().entries.map((entry) {
          final index = entry.key;
          final device = entry.value;
          return Column(
            children: [
              _DeviceItem(device: device),
              if (index < devices.length - 1)
                Divider(
                  height: 1,
                  indent: 72,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DeviceItem extends StatelessWidget {
  const _DeviceItem({required this.device});

  final DeviceModel device;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: device.isCurrent
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(device.os ?? ''),
              color: device.isCurrent ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName ?? 'Thiết bị không xác định',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Thiết bị này',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _buildDeviceInfo(),
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String os) {
    final osLower = os.toLowerCase();
    if (osLower.contains('ios') || osLower.contains('iphone')) {
      return Icons.phone_iphone;
    }
    if (osLower.contains('android')) {
      return Icons.phone_android;
    }
    if (osLower.contains('windows')) {
      return Icons.desktop_windows;
    }
    if (osLower.contains('mac')) {
      return Icons.laptop_mac;
    }
    if (osLower.contains('ipad')) {
      return Icons.tablet_mac;
    }
    return Icons.devices;
  }

  String _buildDeviceInfo() {
    final parts = <String>[];
    if (device.os != null && device.os!.isNotEmpty) {
      parts.add(device.os!);
    }
    if (device.loggedInAt != null) {
      parts.add(_formatTime(device.loggedInAt!));
    }
    return parts.isNotEmpty ? parts.join(' • ') : 'Không có thông tin';
  }

  String _formatTime(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    return '${date.day}/${date.month}/${date.year}';
  }
}

