import 'package:flutter/widgets.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_assignment_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_class_tools_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_gradebook_screen.dart';
import 'package:study/features/teacher/presentation/classes/tools/teacher_grade_columns_screen.dart';
import 'package:study/features/teacher/presentation/earnings/teacher_earnings_screen.dart';

/// Uses the shared teacher fixture API, never production DI or network.
List<Widget> createTeacherPhaseDFixtures(TeacherApi api) => [
  TeacherClassToolsScreen(classId: 'teacher-class', canManage: true, api: api),
  TeacherAssignmentScreen(api: api, classId: 'teacher-class', canWrite: true),
  TeacherGradebookScreen(api: api, classId: 'teacher-class', canWrite: true),
  TeacherGradeColumnsScreen(api: api, classId: 'teacher-class', canWrite: true),
  TeacherClassPeopleScreen(
    api: api,
    classId: 'teacher-class',
    teachers: false,
    canWrite: true,
  ),
  TeacherEarningsScreen(api: api),
];
