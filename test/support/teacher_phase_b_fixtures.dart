import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_workplace_controller.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_editor.dart';
import 'package:study/features/teacher/presentation/classes/teacher_class_screen.dart';
import 'package:study/features/teacher/presentation/classes/teacher_classes_screen.dart';
import 'package:study/features/teacher/presentation/home/teacher_home_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_applicant_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_professional_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_profile_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_reminders_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_attendance_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_editor.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_session_screen.dart';
import 'package:study/features/teacher/presentation/teacher_shell.dart';

List<Widget> createTeacherPhaseBFixtures(
  TeacherApi api,
  TeacherWorkplaceController workplace,
) => [
  TeacherShell(api: api, workplace: workplace),
  TeacherHomeScreen(
    api: api,
    organizationId: null,
    workplaceLabel: 'Cá nhân',
    onSchedule: () {},
    onClasses: () {},
    onCourses: () {},
  ),
  TeacherScheduleScreen(
    api: api,
    organizationId: null,
    workplaceLabel: 'Cá nhân',
  ),
  TeacherClassesScreen(
    api: api,
    organizationId: null,
    workplaceLabel: 'Cá nhân',
  ),
  TeacherClassScreen(
    api: api,
    classId: 'teacher-class',
    workplaceLabel: 'Cá nhân',
  ),
  TeacherClassEditor(api: api),
  TeacherSessionScreen(
    api: api,
    classId: 'teacher-class',
    sessionId: 'teacher-session',
    workplaceLabel: 'Cá nhân',
  ),
  TeacherAttendanceScreen(
    api: api,
    classId: 'teacher-class',
    sessionId: 'teacher-session',
    title: 'Toán · 14/10',
  ),
  TeacherScheduleEditor(api: api, classId: 'teacher-class'),
  TeacherApplicantScreen(api: api),
  TeacherProfessionalScreen(api: api),
  TeacherProfileScreen(
    api: api,
    workplaceLabel: 'Cá nhân',
    onWorkplace: () {},
    onAdvanced: () {},
  ),
  TeacherRemindersScreen(api: api),
];
