import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/profile/teacher_professional_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_role_switcher.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherApplicantScreen extends StatefulWidget {
  const TeacherApplicantScreen({super.key, this.api});
  final TeacherApi? api;
  @override
  State<TeacherApplicantScreen> createState() => _TeacherApplicantScreenState();
}

class _TeacherApplicantScreenState extends State<TeacherApplicantScreen> {
  late final TeacherApi _api = widget.api ?? TeacherApi();
  int _revision = 0;
  bool _saving = false;
  Object? _error;
  void _reload() => setState(() => _revision++);
  Future<void> _resubmit() async {
    if (_saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nộp lại hồ sơ?'),
        content: const Text('Hồ sơ hiện tại sẽ được gửi để xét duyệt lại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Xem lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nộp lại hồ sơ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _api.post('/teacher-profiles/me/resubmit');
      if (mounted) _reload();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _activate() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = context.read<AuthRepository>();
      final profiles = await repository.getProfiles();
      final teachers = profiles
          .where(
            (p) =>
                p.roleName.toUpperCase() == 'TEACHER' && p.systemRoleId != null,
          )
          .toList();
      if (teachers.isEmpty) {
        throw const FormatException(
          'Quyền giáo viên chưa được cập nhật. Vui lòng thử lại hoặc đăng nhập lại.',
        );
      }
      final profile = teachers.first;
      final response = await repository.switchRole(
        roleId: profile.systemRoleId!,
        roleType: profile.type,
        organizationId: profile.organizationId,
      );
      if (mounted) context.read<AuthBloc>().add(AuthProfileSwitched(response));
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openProfile(Map<String, dynamic> application) async {
    final changed = await teacherPush<bool>(
      context,
      TeacherProfessionalScreen(api: _api, application: application),
    );
    if (changed == true && mounted) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Đăng ký giảng dạy'),
      actions: [
        IconButton(
          onPressed: _saving ? null : _reload,
          tooltip: 'Kiểm tra cập nhật',
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: TeacherAsyncView<Map<String, dynamic>>(
      refreshToken: _revision,
      load: () => teacherLoadApplication(_api),
      builder: (context, application) {
        final status = application['approval_status'];
        final reason = '${application['rejection_reason'] ?? ''}'.trim();
        final canResubmit =
            status == 'rejected' && application['can_resubmit'] == true;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final (icon, iconColor) = switch (status) {
          'approved' => (Icons.check_circle_outline, colors.secondary),
          'rejected' => (Icons.info_outline, colors.error),
          'pending' => (Icons.schedule_outlined, colors.primary),
          _ => (Icons.school_outlined, colors.primary),
        };
        final title = switch (status) {
          'approved' => 'Hồ sơ đã được duyệt',
          'rejected' => 'Hồ sơ chưa được duyệt',
          'pending' => 'Hồ sơ đang được xét duyệt',
          _ => 'Hoàn thiện hồ sơ giáo viên',
        };
        final message = switch (status) {
          'pending' => 'Bạn có thể xem thông tin đã gửi và kiểm tra cập nhật.',
          'rejected' =>
            canResubmit
                ? 'Cập nhật hồ sơ theo phản hồi rồi gửi xét duyệt lại.'
                : 'Bạn đã dùng hết số lượt nộp lại. '
                      'Thông tin đã gửi vẫn có thể xem bên dưới.',
          'approved' =>
            'Chuyển sang vai trò Giáo viên để mở không gian giảng dạy.',
          _ =>
            'Điền thông tin chuyên môn, học vấn và kinh nghiệm '
                'để gửi xét duyệt.',
        };
        final facts = <(String, Object?)>[
          ('Chuyên môn', application['specialization']),
          ('Học vấn', application['education']),
          ('Số năm kinh nghiệm', application['experience_years']),
          ('Bộ môn', application['department']),
          ('Chứng chỉ', application['certificate_info']),
        ].where((fact) => '${fact.$2 ?? ''}'.trim().isNotEmpty).toList();
        return ListView(
          padding: AppSpacing.paddingScreenAll,
          children: [
            TeacherSurface(
              showShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: iconColor, size: AppIconSize.xl),
                  AppSpacing.vGap12,
                  Text(title, style: theme.textTheme.titleLarge),
                  AppSpacing.vGap8,
                  Text(message),
                  if (status == 'rejected' && reason.isNotEmpty) ...[
                    AppSpacing.vGap16,
                    Text(
                      'Phản hồi xét duyệt',
                      style: theme.textTheme.titleSmall,
                    ),
                    AppSpacing.vGap4,
                    Text(
                      reason,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                  if (status == 'rejected' &&
                      application['resubmission_count'] != null &&
                      application['max_resubmissions'] != null) ...[
                    AppSpacing.vGap8,
                    Text(
                      'Đã nộp lại ${application['resubmission_count']}/${application['max_resubmissions']} lần',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (application.isEmpty || canResubmit || status == 'approved')
              AppSpacing.vGap16,
            if (application.isEmpty || canResubmit)
              FilledButton(
                onPressed: _saving ? null : () => _openProfile(application),
                child: Text(
                  application.isEmpty ? 'Hoàn thiện hồ sơ' : 'Sửa hồ sơ',
                ),
              ),
            if (canResubmit)
              OutlinedButton(
                onPressed: _saving ? null : _resubmit,
                child: Text(_saving ? 'Đang gửi…' : 'Nộp lại hồ sơ'),
              ),
            if (status == 'approved')
              FilledButton(
                onPressed: _saving ? null : _activate,
                child: Text(_saving ? 'Đang cập nhật…' : 'Bắt đầu giảng dạy'),
              ),
            if (_error != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  teacherErrorMessage(_error!),
                  style: TextStyle(color: colors.error),
                ),
              ),
            if (facts.isNotEmpty) ...[
              const TeacherSectionTitle(title: 'Hồ sơ đã gửi'),
              TeacherSurface(
                showShadow: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (label, value) in facts)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(label),
                        subtitle: Text('$value'),
                      ),
                  ],
                ),
              ),
            ],
            const TeacherSectionTitle(title: 'Vai trò khác'),
            const TeacherRoleSwitcher(),
          ],
        );
      },
    ),
  );
}
