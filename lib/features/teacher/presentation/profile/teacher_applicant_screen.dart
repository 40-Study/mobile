import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_core.dart';
import 'package:study/features/teacher/presentation/profile/teacher_professional_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_role_switcher.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

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
      key: ValueKey(_revision),
      load: () => teacherLoadApplication(_api),
      builder: (context, application) {
        final status = application['approval_status'];
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.school_outlined, size: 48),
            const SizedBox(height: 24),
            Text(
              application.isEmpty
                  ? 'Hoàn thiện hồ sơ giáo viên'
                  : teacherStatus(status),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(switch (status) {
              'pending' =>
                'Hồ sơ đang được xét duyệt. Bạn có thể xem thông tin đã gửi và kiểm tra cập nhật.',
              'rejected' =>
                application['can_resubmit'] == true
                    ? 'Bổ sung thông tin theo phản hồi, lưu hồ sơ rồi nộp lại.'
                    : 'Hồ sơ đã hết lượt nộp lại. Bạn vẫn có thể xem thông tin và sử dụng vai trò khác.',
              'approved' =>
                'Hồ sơ đã được duyệt. Cập nhật phiên đăng nhập để bắt đầu giảng dạy.',
              _ =>
                'Cung cấp chuyên môn, học vấn, kinh nghiệm và chứng chỉ để gửi xét duyệt.',
            }),
            if (application['rejection_reason'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Lý do: ${application['rejection_reason']}'),
              ),
            if (application['resubmission_count'] != null)
              Text(
                'Đã nộp lại ${application['resubmission_count']}/${application['max_resubmissions']} lần',
              ),
            if (application['specialization'] != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Chuyên môn'),
                subtitle: Text('${application['specialization']}'),
              ),
            if (application['education'] != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Học vấn'),
                subtitle: Text('${application['education']}'),
              ),
            if (application['certificate_info'] != null)
              Text('Chứng chỉ: ${application['certificate_info']}'),
            const SizedBox(height: 24),
            if (application.isEmpty ||
                (status == 'rejected' && application['can_resubmit'] == true))
              FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        await teacherPush<Object?>(
                          context,
                          TeacherProfessionalScreen(
                            api: _api,
                            application: application,
                          ),
                        );
                        if (mounted) _reload();
                      },
                child: Text(
                  application.isEmpty ? 'Hoàn thiện hồ sơ' : 'Sửa hồ sơ',
                ),
              ),
            if (status == 'rejected' && application['can_resubmit'] == true)
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
              Text(
                teacherErrorMessage(_error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const TeacherSectionTitle(title: 'Vai trò khác'),
            const TeacherRoleSwitcher(),
          ],
        );
      },
    ),
  );
}
