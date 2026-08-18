import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/utils/role_utils.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen({super.key});

  @override
  State<AddProfileScreen> createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  List<RoleModel> _allRoles = [];
  List<ProfileModel> _existingProfiles = [];
  bool _isLoading = true;
  bool _isAdding = false;
  String? _error;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = context.read<AuthRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load system roles and user profiles in parallel
      final results = await Future.wait([
        _authRepository.getSystemRoles(),
        _authRepository.getProfiles(),
      ]);

      setState(() {
        _allRoles = results[0] as List<RoleModel>;
        _existingProfiles = results[1] as List<ProfileModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải dữ liệu. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  List<RoleModel> get _availableRoles {
    final existingRoleNames = _existingProfiles
        .map((p) => p.roleName.toUpperCase())
        .toSet();

    return _allRoles
        .where((r) => !existingRoleNames.contains(r.name.toUpperCase()))
        .toList();
  }

  Future<void> _addRole(RoleModel role) async {
    setState(() => _isAdding = true);

    try {
      await _authRepository.createProfile(systemRoleId: role.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm vai trò ${RoleUtils.getLabel(role.name)}'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lỗi: Không thể thêm vai trò'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        title: Text(l10n.selectRoleTitle),
      ),
      body: _buildBody(cs, tt, l10n),
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: cs.error),
            AppSpacing.vGap16,
            Text(_error!, style: tt.bodyLarge),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgainButton),
            ),
          ],
        ),
      );
    }

    if (_availableRoles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bạn đã có tất cả vai trò',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Không có vai trò nào khác để thêm vào tài khoản của bạn',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer,
                    cs.primaryContainer.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.person_add_outlined, size: 48, color: cs.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Chọn vai trò muốn thêm',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vai trò mới sẽ được thêm vào tài khoản của bạn',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Available roles
            Text(
              'CÁC VAI TRÒ CÓ SẴN',
              style: tt.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            ..._availableRoles.map(
              (role) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RoleCard(
                  role: role,
                  onTap: _isAdding ? null : () => _addRole(role),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Already have section
            if (_existingProfiles.isNotEmpty) ...[
              Text(
                'VAI TRÒ ĐÃ CÓ',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              ..._existingProfiles.map(
                (profile) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ExistingProfileCard(profile: profile),
                ),
              ),
            ],
          ],
        ),

        // Loading overlay
        if (_isAdding)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.onTap});

  final RoleModel role;
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
            border: Border.all(color: cs.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primaryContainer,
                      cs.primaryContainer.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  RoleUtils.getIcon(role.name),
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
                      RoleUtils.getLabel(role.name),
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRoleDescription(role.name),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleDescription(String roleName) {
    switch (roleName.toUpperCase()) {
      case 'STUDENT':
        return 'Học viên - Tham gia khóa học và làm bài tập';
      case 'TEACHER':
        return 'Giảng viên - Tạo và quản lý khóa học';
      case 'PARENT':
        return 'Phụ huynh - Theo dõi tiến độ học tập';
      case 'ORG_OWNER':
        return 'Chủ tổ chức - Quản lý tổ chức giáo dục';
      default:
        return 'Vai trò hệ thống';
    }
  }
}

class _ExistingProfileCard extends StatelessWidget {
  const _ExistingProfileCard({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              RoleUtils.getIcon(profile.roleName),
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              RoleUtils.getLabel(profile.roleName),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.tertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
