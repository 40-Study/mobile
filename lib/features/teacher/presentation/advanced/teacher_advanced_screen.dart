import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_contests_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_discussions_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_live_sessions_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_messages_screen.dart';
import 'package:study/features/teacher/presentation/advanced/teacher_video_upload_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_surface.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherAdvancedScreen extends StatelessWidget {
  const TeacherAdvancedScreen({super.key, this.api, this.classId});
  final TeacherApi? api;
  final String? classId;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Công cụ giảng dạy')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        AppSpacing.xl,
      ),
      children: [
        Text(
          classId == null
              ? 'Chọn công cụ cho buổi dạy và nội dung của bạn.'
              : 'Công cụ dành cho lớp đang xem.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const TeacherSectionTitle(title: 'Dạy học và trao đổi'),
        TeacherSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              TeacherActionTile(
                icon: Icons.videocam_outlined,
                title: 'Phòng học trực tuyến',
                subtitle: 'Lịch phát trực tiếp và phòng học',
                onTap: () => teacherPush<void>(
                  context,
                  TeacherLiveSessionsScreen(api: api, classId: classId),
                ),
              ),
              TeacherActionTile(
                icon: Icons.chat_bubble_outline,
                title: 'Tin nhắn',
                subtitle: 'Trao đổi với học viên',
                onTap: () =>
                    teacherPush<void>(context, TeacherMessagesScreen(api: api)),
              ),
              TeacherActionTile(
                icon: Icons.question_answer_outlined,
                title: 'Thảo luận & hỏi đáp',
                subtitle: 'Câu hỏi và trao đổi học tập',
                onTap: () => teacherPush<void>(
                  context,
                  TeacherDiscussionsScreen(api: api),
                ),
              ),
            ],
          ),
        ),
        const TeacherSectionTitle(title: 'Học liệu cá nhân'),
        TeacherSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              TeacherActionTile(
                icon: Icons.upload_file_outlined,
                title: 'Video bài giảng',
                subtitle: 'Tải video và tiếp tục phiên dang dở',
                onTap: () => teacherPush<void>(
                  context,
                  TeacherVideoUploadScreen(api: api),
                ),
              ),
              TeacherActionTile(
                icon: Icons.emoji_events_outlined,
                title: 'Cuộc thi của tôi',
                subtitle: 'Tạo cuộc thi từ bộ câu hỏi và gửi duyệt',
                onTap: () =>
                    teacherPush<void>(context, TeacherContestsScreen(api: api)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
