import 'package:flutter/widgets.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/courses/course_detail_screen.dart';
import 'package:study/features/teacher/presentation/courses/course_metadata_editor.dart';
import 'package:study/features/teacher/presentation/courses/course_outline_screen.dart';
import 'package:study/features/teacher/presentation/courses/course_tag_picker.dart';
import 'package:study/features/teacher/presentation/courses/exercise_editor_screen.dart';
import 'package:study/features/teacher/presentation/courses/lesson_contents_screen.dart';
import 'package:study/features/teacher/presentation/courses/quiz_editor_screen.dart';
import 'package:study/features/teacher/presentation/courses/teacher_courses_screen.dart';

List<Widget> createTeacherPhaseCFixtures(TeacherApi api) => [
  TeacherCoursesScreen(api: api),
  TeacherCourseDetailScreen(api: api, courseId: 'course'),
  CourseMetadataEditor(api: api),
  CourseTagPicker(api: api, initial: const []),
  TeacherCourseOutlineScreen(api: api, courseId: 'course', writable: true),
  TeacherLessonContentsScreen(
    api: api,
    courseId: 'course',
    lessonId: 'lesson',
    title: 'Bài học',
    writable: true,
  ),
  TeacherQuizEditorScreen(api: api, courseId: 'course', lessonId: 'lesson'),
  TeacherExerciseEditorScreen(api: api),
];
