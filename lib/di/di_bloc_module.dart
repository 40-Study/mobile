import 'package:injectable/injectable.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/course/repository/course_repository.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/search/search_bloc.dart';
import 'package:study/features/student/repository/student_repository.dart';

/// Bloc factory module - widget dùng factory thay vì lookup DI trực tiếp
@module
abstract class BlocModule {
  @factoryMethod
  HomeBloc homeBloc(StudentRepository repo) => HomeBloc(repo);

  @factoryMethod
  LearningBloc learningBloc(StudentRepository repo) => LearningBloc(repo);

  @factoryMethod
  ScheduleBloc scheduleBloc(StudentRepository repo) => ScheduleBloc(repo);

  @factoryMethod
  AchievementBloc achievementBloc(
    StudentRepository studentRepo,
    AuthRepository authRepo,
  ) => AchievementBloc(studentRepo, authRepo);

  @factoryMethod
  LessonBloc lessonBloc(StudentRepository repo) => LessonBloc(repo);

  @factoryMethod
  CourseDetailBloc courseDetailBloc(
    StudentRepository repo,
    CourseRepository courseRepo,
    BookmarkStorage bookmarkStorage,
  ) => CourseDetailBloc(repo, courseRepo, bookmarkStorage);

  @factoryMethod
  BookmarkBloc bookmarkBloc(BookmarkStorage storage) => BookmarkBloc(storage);

  @factoryMethod
  SearchBloc searchBloc(StudentRepository repo) => SearchBloc(repo);

  @factoryMethod
  QuizBloc quizBloc(StudentRepository repo) => QuizBloc(repo);

  @factoryMethod
  NotificationBloc notificationBloc(StudentRepository repo) =>
      NotificationBloc(repo);
}
