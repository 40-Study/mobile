import 'parent_flow_fixtures.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/app/localization.dart';
import 'package:study/bloc/theme/theme_cubit.dart';
import 'package:study/core/error/result.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/data/theme_storage.dart';
import 'package:study/features/auth/bloc/account/account_cubit.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/presentation/add_profile_screen.dart';
import 'package:study/features/auth/presentation/change_password_screen.dart';
import 'package:study/features/auth/presentation/edit_profile_screen.dart';
import 'package:study/features/auth/presentation/forgot_password_otp_screen.dart';
import 'package:study/features/auth/presentation/forgot_password_screen.dart';
import 'package:study/features/auth/presentation/login_role_picker_screen.dart';
import 'package:study/features/auth/presentation/login_screen.dart';
import 'package:study/features/auth/presentation/register_form_screen.dart';
import 'package:study/features/auth/presentation/register_otp_screen.dart';
import 'package:study/features/auth/presentation/reset_password_screen.dart';
import 'package:study/features/auth/presentation/security_screen.dart';
import 'package:study/features/auth/presentation/select_role_screen.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/course/data/models/models.dart';
import 'package:study/features/course/repository/course_repository.dart';
import 'package:study/features/main_screen.dart';
import 'package:study/features/onboarding/onboarding_screen.dart';
import 'package:study/features/parent/bloc/home/parent_home_bloc.dart';
import 'package:study/features/parent/bloc/learning/parent_learning_bloc.dart';
import 'package:study/features/parent/bloc/schedule/parent_schedule_bloc.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/children/add_child_screen.dart';
import 'package:study/features/parent/presentation/children/child_detail_screen.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/home/parent_home_screen.dart';
import 'package:study/features/parent/presentation/insights_inbox/family_insights_inbox_screen.dart';
import 'package:study/features/parent/presentation/learning/class_detail/parent_class_detail_screen.dart';
import 'package:study/features/parent/presentation/learning/course_detail/parent_course_detail_screen.dart';
import 'package:study/features/parent/presentation/learning/insights/parent_learning_insights_screen.dart';
import 'package:study/features/parent/presentation/learning/parent_learning_screen.dart';
import 'package:study/features/parent/presentation/learning/recommended_courses/parent_recommended_courses_screen.dart';
import 'package:study/features/parent/presentation/parent_shell.dart';
import 'package:study/features/parent/presentation/payment/parent_payment_screen.dart';
import 'package:study/features/parent/presentation/profile/parent_profile_screen.dart';
import 'package:study/features/parent/presentation/schedule/parent_schedule_screen.dart';
import 'package:study/features/parent/presentation/schedule/parent_session_detail_screen.dart';
import 'package:study/features/parent/repository/family_insights_repository.dart';
import 'package:study/features/parent/repository/parent_home_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_schedule_repository.dart';
import 'package:study/features/splash_view.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_bloc.dart';
import 'package:study/features/student/bloc/course_detail/course_detail_event.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/lesson/lesson_bloc.dart';
import 'package:study/features/student/bloc/lesson/lesson_event.dart';
import 'package:study/features/student/bloc/notification/notification_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/schedule/schedule_bloc.dart';
import 'package:study/features/student/bloc/search/search_bloc.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/achievement/achievement_screen.dart';
import 'package:study/features/student/presentation/achievement/all_achievements_screen.dart';
import 'package:study/features/student/presentation/achievement/all_certificates_screen.dart';
import 'package:study/features/student/presentation/achievement/certificate_detail_screen.dart';
import 'package:study/features/student/presentation/bookmark/bookmark_screen.dart';
import 'package:study/features/student/presentation/home/home_screen.dart';
import 'package:study/features/student/presentation/learning/all_courses_screen.dart';
import 'package:study/features/student/presentation/learning/course_detail/course_detail_screen.dart';
import 'package:study/features/student/presentation/learning/explore_courses_screen.dart';
import 'package:study/features/student/presentation/learning/instructor_detail_screen.dart';
import 'package:study/features/student/presentation/learning/learning_screen.dart';
import 'package:study/features/student/presentation/learning/lesson_detail_screen.dart';
import 'package:study/features/student/presentation/learning/quiz_result_screen.dart';
import 'package:study/features/student/presentation/learning/quiz_screen.dart';
import 'package:study/features/student/presentation/notification/notification_screen.dart';
import 'package:study/features/student/presentation/portfolio/mock_portfolio_data.dart';
import 'package:study/features/student/presentation/portfolio/portfolio_screen.dart';
import 'package:study/features/student/presentation/portfolio/widgets/portfolio_preview_screen.dart';
import 'package:study/features/student/presentation/profile/profile_screen.dart';
import 'package:study/features/student/presentation/schedule/daily_goals_screen.dart';
import 'package:study/features/student/presentation/schedule/schedule_screen.dart';
import 'package:study/features/student/presentation/search/search_screen.dart';
import 'package:study/features/student/presentation/settings/help_center_screen.dart';
import 'package:study/features/student/presentation/settings/settings_screen.dart';
import 'package:study/features/student/presentation/student_shell.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/repository/theme_repository.dart';
import 'package:study/routes/router.dart';
import 'package:study/theme/style.dart';
import 'package:study/theme/util.dart';

class _AuthRepository extends Mock implements AuthRepository {}

class _StudentRepository extends Mock implements StudentRepository {}

class _CourseRepository extends Mock implements CourseRepository {}

class _ParentLearningRepository extends Mock
    implements ParentLearningRepository {}

class _FamilyInsightsRepository extends Mock
    implements FamilyInsightsRepository {}

class _ParentHomeRepository extends Mock implements ParentHomeRepository {}

class _ParentScheduleRepository extends Mock
    implements ParentScheduleRepository {}

const _user = UserModel(
  id: 'user',
  email: 'student@example.com',
  fullName: 'Test Student',
);
const _role = RoleModel(id: 'student', name: 'STUDENT', type: 'system');
const _course = CourseModel(
  id: 'course',
  title: 'Test Course',
  instructorName: 'Test Teacher',
);
const _lesson = LessonModel(id: 'lesson', title: 'Test Lesson');
const _enrollment = EnrollmentModel(
  id: 'enrollment',
  courseId: 'course',
  course: _course,
);
const _certificate = CertificateModel(
  id: 'certificate',
  courseTitle: 'Test Course',
  userName: 'Test Student',
);
final _parentSession = ParentScheduleSession(
  id: 'session',
  childId: 'child',
  childName: 'Minh',
  childInitial: 'M',
  childBadgeColor: Colors.blue,
  subjectName: 'Toán',
  lessonTopic: 'Hàm số',
  startTime: DateTime.utc(2026, 9, 27, 9),
  endTime: DateTime.utc(2026, 9, 27, 10),
  instructorName: 'Cô Lan',
  status: ParentSessionStatus.upcoming,
);

// Each concrete screen has an explicit fixture. The inventory test below makes
// adding a screen without adding its fixture a test failure.
List<Widget> createScreenFixtures({int itemCount = 0}) => <Widget>[
  const SplashView(),
  const MainScreen(),
  const OnboardingScreen(),
  const LoginScreen(),
  const LoginRolePickerScreen(sessionToken: 'session', roles: [_role]),
  const SelectRoleScreen(),
  const RegisterFormScreen(),
  const RegisterOtpScreen(),
  const ForgotPasswordScreen(),
  const ForgotPasswordOtpScreen(),
  const ResetPasswordScreen(),
  const AddProfileScreen(),
  const ChangePasswordScreen(),
  const EditProfileScreen(),
  const SecurityScreen(),
  const ParentShell(),
  const ParentHomeScreen(),
  const ParentLearningScreen(),
  const ParentScheduleScreen(),
  const ParentPaymentScreen(),
  ...createParentFlowFixtures(),
  const ParentProfileScreen(),
  const ParentClassDetailScreen(),
  const ParentCourseDetailScreen(courseId: 'course', childName: 'Minh'),
  const ParentLearningInsightsScreen(childId: 'child', childName: 'Minh'),
  const ParentRecommendedCoursesScreen(childId: 'child', childName: 'Minh'),
  ParentSessionDetailScreen(session: _parentSession),
  const FamilyInsightsInboxScreen(),
  const ManageChildrenScreen(),
  const AddChildScreen(),
  const ChildDetailScreen(child: _user),
  const StudentShell(),
  const HomeScreen(),
  const LearningScreen(),
  const ScheduleScreen(),
  const AchievementScreen(),
  const ProfileScreen(),
  const BookmarkScreen(),
  const SearchScreen(),
  const NotificationScreen(),
  const AllCoursesScreen(),
  const ExploreCoursesScreen(),
  const CourseDetailScreen(),
  const LessonDetailScreen(),
  const InstructorDetailScreen(
    instructorId: 'teacher',
    instructorName: 'Test Teacher',
  ),
  const QuizScreen(quizId: 'quiz', title: 'Test Quiz'),
  const QuizResultScreen(title: 'Test Quiz', correct: 1, total: 1, score: 100),
  AllAchievementsScreen(badges: _badges(itemCount)),
  AllCertificatesScreen(certificates: _certificates(itemCount)),
  const CertificateDetailScreen(certificate: _certificate),
  DailyGoalsScreen(date: DateTime(2026, 9, 27)),
  const SettingsScreen(),
  const HelpCenterScreen(),
  const PortfolioScreen(),
  const PortfolioPreviewScreen(
    profile: kMockProfile,
    stats: kMockStats,
    sections: [],
    projects: kMockProjects,
    skills: kMockSkills,
    experiences: kMockExperiences,
  ),
];

late AuthRepository auth;
late StudentRepository student;
late SharedPreferences prefs;

Future<void> setUpScreenFixtures({int itemCount = 0}) async {
  SharedPreferences.setMockInitialValues({});
  prefs = await SharedPreferences.getInstance();
  auth = _AuthRepository();
  student = _StudentRepository();
  when(() => auth.getSavedUser()).thenAnswer((_) async => _user);
  when(() => auth.getSavedProfile()).thenAnswer((_) async => null);
  when(() => auth.getMe()).thenAnswer((_) async => _user);
  when(() => auth.getProfiles()).thenAnswer((_) async => []);
  when(() => auth.getSystemRoles()).thenAnswer((_) async => [_role]);
  when(() => auth.getChildren()).thenAnswer((_) async => []);
  when(() => auth.getDevices()).thenAnswer((_) async => []);
  when(() => auth.getLinkedAccounts()).thenAnswer((_) async => []);
  when(
    () => student.getContinueLearning(),
  ).thenAnswer((_) async => const Result.success(null));
  when(
    () => student.getTodaySchedule(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getScheduleByDate(any()),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getEventDates(any()),
  ).thenAnswer((_) async => const Result.success(<DateTime>{}));
  when(
    () => student.getPendingAssignments(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getActiveEnrollments(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getAllCourses(page: any(named: 'page')),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getStats(),
  ).thenAnswer((_) async => const Result.success(StudentStatsModel()));
  when(
    () => student.getBadges(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getCertificates(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getContributions(any()),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getNotifications(),
  ).thenAnswer((_) async => const Result.success([]));
  when(
    () => student.getCourseDetail(any()),
  ).thenAnswer((_) async => const Result.success(_enrollment));
  when(() => student.setLastAccessedCourse(any())).thenAnswer((_) async {});
  when(
    () => student.getLessonDetail(any()),
  ).thenAnswer((_) async => const Result.success(_lesson));
  when(
    () => student.getQuizzesByLesson(any()),
  ).thenAnswer((_) async => const Result.success([]));
  when(() => student.startQuiz(any())).thenAnswer(
    (_) async => const Result.success((
      attemptId: 'attempt',
      timeLimitMinutes: 5,
      questions: [
        QuizQuestionModel(
          id: 'question',
          question: 'What is 1 + 1?',
          answers: [
            QuizAnswerModel(id: 'a', answerText: '2', isCorrect: true),
            QuizAnswerModel(id: 'b', answerText: '3'),
          ],
        ),
      ],
    )),
  );
  final di = GetIt.instance;
  final parentLearning = _ParentLearningRepository();
  final familyInsights = _FamilyInsightsRepository();
  final parentHome = _ParentHomeRepository();
  final parentSchedule = _ParentScheduleRepository();
  when(
    () => parentLearning.getClassDetail(any(), childId: any(named: 'childId')),
  ).thenAnswer((_) async => null);
  when(
    () => parentLearning.getLearningInsights(any()),
  ).thenAnswer((_) async => null);
  when(parentLearning.getChildren).thenAnswer((_) async => []);
  when(
    parentLearning.getAllLearningHubData,
  ).thenAnswer((_) async => {});
  when(
    () => parentLearning.getRecommendedCourses(any()),
  ).thenAnswer((_) async => []);
  when(
    () => parentLearning.getRecommendedCourseDetail(
      any(),
      childId: any(named: 'childId'),
    ),
  ).thenAnswer((_) async => null);
  when(familyInsights.getInsights).thenAnswer((_) async => []);
  when(parentHome.getChildren).thenAnswer((_) async => []);
  when(parentHome.getAlerts).thenAnswer((_) async => []);
  when(parentHome.getSchedules).thenAnswer((_) async => []);
  when(parentHome.getAnalyticsList).thenAnswer((_) async => []);
  when(parentSchedule.getChildren).thenAnswer((_) async => []);
  when(
    () => parentSchedule.getSessionsForDate(date: any(named: 'date')),
  ).thenAnswer((_) async => []);
  when(
    () => parentSchedule.getEventsMapByMonth(month: any(named: 'month')),
  ).thenAnswer((_) async => {});
  when(
    () => parentSchedule.getSessionCountForWeek(
      anchorDate: any(named: 'anchorDate'),
    ),
  ).thenAnswer((_) async => 0);
  when(parentSchedule.getScheduleSessions).thenAnswer((_) async => []);
  when(
    () => parentSchedule.getEventDates(anchorDate: any(named: 'anchorDate')),
  ).thenAnswer((_) async => []);
  di.registerSingleton<ParentLearningRepository>(parentLearning);
  di.registerSingleton<FamilyInsightsRepository>(familyInsights);
  di.registerSingleton<ParentHomeRepository>(parentHome);
  di.registerSingleton<ParentScheduleRepository>(parentSchedule);
  final bookmarks = SharedPreferencesBookmarkStorage(prefs);
  di.registerFactory<HomeBloc>(() => HomeBloc(student));
  di.registerFactory<LearningBloc>(() => LearningBloc(student));
  di.registerFactory<ScheduleBloc>(() => ScheduleBloc(student));
  di.registerFactory<AchievementBloc>(() => AchievementBloc(student, auth));
  di.registerFactory<BookmarkBloc>(() => BookmarkBloc(bookmarks));
  di.registerFactory<SearchBloc>(() => SearchBloc(student));
  di.registerFactory<NotificationBloc>(() => NotificationBloc(student));
  di.registerFactory<QuizBloc>(() => QuizBloc(student));
  di.registerFactory<LessonBloc>(() => LessonBloc(student));
  di.registerFactory<ParentHomeBloc>(() => ParentHomeBloc(parentHome));
  di.registerFactory<ParentLearningBloc>(
    () => ParentLearningBloc(parentLearning),
  );
  di.registerFactory<ParentScheduleBloc>(
    () => ParentScheduleBloc(parentSchedule),
  );
  di.registerFactory<CourseDetailBloc>(
    () => CourseDetailBloc(student, _CourseRepository(), bookmarks),
  );
  if (itemCount > 0) await _populateData(itemCount);
}

Future<void> pumpScreenFixture(
  WidgetTester tester,
  Widget screen, {
  Size? size = const Size(390, 844),
  bool disableAnimations = true,
  bool deferScreen = false,
  int pumpCount = 15,
  Duration pumpDuration = const Duration(milliseconds: 100),
}) async {
  if (size != null) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  final key = GlobalKey<NavigatorState>();
  final navigation = NavigationService(navigatorKey: key);
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: auth),
        RepositoryProvider<AuthStorage>.value(
          value: SharedPreferencesAuthStorage(prefs),
        ),
        RepositoryProvider<NavigationService>.value(value: navigation),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AuthBloc(auth)..emit(const AuthAuthenticated(user: _user)),
          ),
          BlocProvider(
            create: (_) => ThemeCubit(
              ThemeRepositoryImpl(SharedPreferencesThemeStorage(prefs)),
            ),
          ),
          BlocProvider(
            create: (_) => AccountCubit(authRepository: auth)..loadAccount(),
          ),
          BlocProvider(create: (_) => HomeBloc(student)),
          BlocProvider(
            create: (_) {
              final bloc = LearningBloc(student);
              // These list routes inherit already-loaded data in the real app.
              if (screen is AllCoursesScreen ||
                  screen is ExploreCoursesScreen) {
                bloc.add(const LearningStarted());
              }
              return bloc;
            },
          ),
          BlocProvider(create: (_) => ScheduleBloc(student)),
          BlocProvider(create: (_) => AchievementBloc(student, auth)),
          BlocProvider(
            create: (_) =>
                GetIt.instance<CourseDetailBloc>()
                  ..add(const CourseDetailStarted('enrollment')),
          ),
          BlocProvider(
            create: (_) =>
                LessonBloc(student)..add(const LessonStarted('lesson')),
          ),
          BlocProvider(
            create: (_) =>
                ParentHomeBloc(GetIt.instance<ParentHomeRepository>()),
          ),
          BlocProvider(
            create: (_) =>
                ParentLearningBloc(GetIt.instance<ParentLearningRepository>()),
          ),
          BlocProvider(
            create: (_) =>
                ParentScheduleBloc(GetIt.instance<ParentScheduleRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            theme: MaterialTheme(createTextTheme(context: context)).light(),
            navigatorKey: key,
            locale: const Locale('vi'),
            supportedLocales: appSupportedLocales,
            localizationsDelegates: appLocalizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(disableAnimations: disableAnimations),
              child: child!,
            ),
            onGenerateRoute: (settings) =>
                settings.name == '/' || settings.name == '/fixture'
                ? MaterialPageRoute<void>(
                    settings: RouteSettings(
                      arguments: screen is ForgotPasswordOtpScreen
                          ? 'student@example.com'
                          : screen is ResetPasswordScreen
                          ? {'email': 'student@example.com', 'otp': '123456'}
                          : null,
                    ),
                    builder: (_) => deferScreen && settings.name == '/'
                        ? const Scaffold(body: SizedBox.shrink())
                        : screen,
                  )
                : navigation.onGenerateRoute(settings),
          ),
        ),
      ),
    ),
  );
  // Bounded pumps also work with OTP/quiz timers and looping illustrations.
  for (var i = 0; i < pumpCount; i++) {
    await tester.pump(pumpDuration);
  }
}

Future<void> disposeScreenFixture(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  expect(tester.takeException(), isNull);
}

// Only these screens consume the variable repository/argument lists below.
// Fixed forms and demo-only screens are measured once rather than pretending
// that changing repository data changes their contents.
const variableDataScreens = <String>{
  'MainScreen',
  'ParentShell',
  'ParentHomeScreen',
  'ParentLearningScreen',
  'ParentScheduleScreen',
  'ParentProfileScreen',
  'ManageChildrenScreen',
  'ParentClassDetailScreen',
  'ParentCourseDetailScreen',
  'ParentLearningInsightsScreen',
  'ParentRecommendedCoursesScreen',
  'FamilyInsightsInboxScreen',
  'SecurityScreen',
  'StudentShell',
  'HomeScreen',
  'LearningScreen',
  'ScheduleScreen',
  'AchievementScreen',
  'ProfileScreen',
  'BookmarkScreen',
  'SearchScreen',
  'NotificationScreen',
  'AllCoursesScreen',
  'ExploreCoursesScreen',
  'CourseDetailScreen',
  'LessonDetailScreen',
  'AllAchievementsScreen',
  'AllCertificatesScreen',
};

List<BadgeModel> _badges(int count) => List.generate(
  count,
  (i) => BadgeModel(
    id: 'badge-$i',
    name: 'Huy hiệu học tập $i',
    description: 'Hoàn thành bài học',
    isEarned: i.isEven,
    category: 'learning',
  ),
);

List<CertificateModel> _certificates(int count) => List.generate(
  count,
  (i) =>
      _certificate.copyWith(id: 'certificate-$i', courseTitle: 'Khóa học $i'),
);

Future<void> _populateData(int count) async {
  final now = DateTime.now();
  final day = DateTime(now.year, now.month, now.day);
  final children = List.generate(
    count > 5 ? 5 : count,
    (i) => UserModel(
      id: 'child-$i',
      email: 'child$i@example.com',
      fullName: 'Học sinh $i',
    ),
  );
  final scopes = children
      .map(FamilyScopeChild.fromUserModel)
      .toList();
  final lessons = List.generate(
    count,
    (i) => LessonModel(
      id: 'lesson-$i',
      title: 'Bài học $i: Đại số và ứng dụng',
      durationMinutes: 20,
    ),
  );
  final courses = List.generate(
    count,
    (i) => _course.copyWith(
      id: 'course-$i',
      title: 'Khóa học $i: Toán nâng cao',
      categoryName: 'Toán',
      totalLessons: count,
      averageRating: 4.8,
      totalStudents: 120,
      sections: [
        SectionModel(
          id: 'section-$i',
          title: 'Chương trình học',
          totalLessons: count,
          lessons: lessons,
        ),
      ],
    ),
  );
  final enrollments = List.generate(
    count,
    (i) => _enrollment.copyWith(
      id: 'enrollment-$i',
      courseId: courses[i].id,
      course: courses[i],
      status: 'active',
      totalLessons: count,
      progressPercentage: 35,
    ),
  );
  final schedule = List.generate(
    count,
    (i) => ScheduleItemModel(
      id: 'schedule-$i',
      title: 'Buổi học $i',
      type: 'livestream',
      startTime: day.add(Duration(hours: 8, minutes: i * 5)),
      endTime: day.add(Duration(hours: 9, minutes: i * 5)),
      courseName: 'Toán nâng cao',
      instructorName: 'Cô Lan',
    ),
  );
  final assignments = List.generate(
    count,
    (i) => AssignmentModel(
      id: 'assignment-$i',
      title: 'Bài tập $i',
      courseName: 'Toán nâng cao',
      dueDate: day.add(const Duration(days: 1)),
      questionCount: 10,
    ),
  );
  when(() => auth.getChildren()).thenAnswer((_) async => children);
  when(() => auth.getProfiles()).thenAnswer(
    (_) async => List.generate(
      count > 3 ? 3 : count,
      (i) => ProfileModel(
        id: 'profile-$i',
        roleName: 'STUDENT',
        displayName: 'Hồ sơ $i',
      ),
    ),
  );
  when(() => auth.getDevices()).thenAnswer(
    (_) async => List.generate(
      count,
      (i) => DeviceModel(
        deviceId: 'device-$i',
        deviceName: 'Thiết bị $i',
        os: 'iOS',
      ),
    ),
  );
  when(
    () => student.getContinueLearning(),
  ).thenAnswer((_) async => Result.success(enrollments.first));
  when(
    () => student.getTodaySchedule(),
  ).thenAnswer((_) async => Result.success(schedule));
  when(
    () => student.getScheduleByDate(any()),
  ).thenAnswer((_) async => Result.success(schedule));
  when(
    () => student.getEventDates(any()),
  ).thenAnswer((_) async => Result.success({day}));
  when(
    () => student.getPendingAssignments(),
  ).thenAnswer((_) async => Result.success(assignments));
  when(
    () => student.getActiveEnrollments(),
  ).thenAnswer((_) async => Result.success(enrollments));
  when(() => student.getAllCourses(page: any(named: 'page'))).thenAnswer(
    (call) async => Result.success(
      call.namedArguments[#page] == 1 ? courses : <CourseModel>[],
    ),
  );
  when(
    () => student.searchCourses(any()),
  ).thenAnswer((_) async => Result.success(courses));
  when(
    () => student.getCourseDetail(any()),
  ).thenAnswer((_) async => Result.success(enrollments.first));
  when(
    () => student.getCourseById(any()),
  ).thenAnswer((_) async => Result.success(courses.first));
  when(() => student.getLessonDetail(any())).thenAnswer(
    (_) async => Result.success(
      lessons.first.copyWith(
        description: 'Nội dung bài học',
        contents: List.generate(
          count,
          (i) => LessonContentModel(
            id: 'content-$i',
            type: 'text',
            title: 'Nội dung $i',
          ),
        ),
      ),
    ),
  );
  when(() => student.getStats()).thenAnswer(
    (_) async => const Result.success(
      StudentStatsModel(totalCourses: 10, completedCourses: 3),
    ),
  );
  when(
    () => student.getBadges(),
  ).thenAnswer((_) async => Result.success(_badges(count)));
  when(
    () => student.getCertificates(),
  ).thenAnswer((_) async => Result.success(_certificates(count)));
  when(() => student.getContributions(any())).thenAnswer(
    (_) async => Result.success(
      List.generate(
        count,
        (i) => ContributionModel(
          date: day.subtract(Duration(days: i)).toIso8601String(),
          count: i % 5,
        ),
      ),
    ),
  );
  when(() => student.getNotifications()).thenAnswer(
    (_) async => Result.success(
      List.generate(
        count,
        (i) => NotificationModel(
          id: 'notification-$i',
          title: 'Thông báo $i',
          body: 'Lịch học và bài tập mới đã được cập nhật',
          type: NotificationType.course,
          createdAt: now.subtract(Duration(hours: i)),
          isRead: i.isEven,
        ),
      ),
    ),
  );
  await prefs.setString(
    'bookmarks',
    jsonEncode(
      List.generate(
        count,
        (i) => BookmarkModel(
          id: 'bookmark-$i',
          itemId: courses[i].id,
          type: BookmarkType.course,
          title: courses[i].title,
          savedAt: now,
        ).toJson(),
      ),
    ),
  );

  final di = GetIt.instance;
  final home = di<ParentHomeRepository>();
  final learning = di<ParentLearningRepository>();
  final parentSchedule = di<ParentScheduleRepository>();
  final insights = di<FamilyInsightsRepository>();
  final alerts = List.generate(
    count,
    (i) => ParentAlertItem(
      type: ParentAlertType.dueToday,
      childId: children[i % children.length].id,
      childName: children[i % children.length].fullName!,
      subjectName: 'Toán',
      detail: 'Bài tập $i cần hoàn thành',
      metaText: 'Hạn nộp hôm nay',
      tagLabel: 'Hôm nay',
    ),
  );
  final sessions = List.generate(
    count,
    (i) => ParentScheduleSession(
      id: 'session-$i',
      childId: children[i % children.length].id,
      childName: children[i % children.length].fullName!,
      childInitial: 'H',
      childBadgeColor: Colors.blue,
      subjectName: 'Toán',
      lessonTopic: 'Đại số $i',
      startTime: day.add(Duration(hours: 8, minutes: i * 5)),
      endTime: day.add(Duration(hours: 9, minutes: i * 5)),
      instructorName: 'Cô Lan',
      status: ParentSessionStatus.upcoming,
    ),
  );
  final analytics = scopes
      .map(
        (c) => ParentAnalyticsData(
          childId: c.id,
          childName: c.name,
          className: '10A1',
          reportLabel: 'Báo cáo tuần',
          subjectName: 'Toán',
          progressPercent: 15,
          averageScore: 8.5,
          weeklyTrend: const [0.5, 0.6, 0.7, 0.85],
          insightText: 'Con có tiến bộ trong học tập',
        ),
      )
      .toList();
  when(home.getChildren).thenAnswer((_) async => scopes);
  when(
    () => home.getAlerts(childId: any(named: 'childId')),
  ).thenAnswer((_) async => alerts);
  when(() => home.getSchedules(childId: any(named: 'childId'))).thenAnswer(
    (_) async => sessions
        .map(
          (s) => ParentScheduleItem(
            id: s.id,
            childId: s.childId,
            startTime: '09:00',
            childName: s.childName,
            subjectName: s.subjectName,
            lessonTopic: s.lessonTopic,
            locationOrLink: 'Phòng 302',
            teacherOrRoom: s.instructorName,
            mode: ParentScheduleMode.offline,
            statusLabel: 'Sắp diễn ra',
          ),
        )
        .toList(),
  );
  when(
    () => home.getAnalyticsList(childId: any(named: 'childId')),
  ).thenAnswer((_) async => analytics);
  when(parentSchedule.getChildren).thenAnswer((_) async => scopes);
  when(
    () => parentSchedule.getSessionsForDate(
      childId: any(named: 'childId'),
      date: any(named: 'date'),
    ),
  ).thenAnswer((_) async => sessions);
  when(
    () => parentSchedule.getEventsMapByMonth(
      childId: any(named: 'childId'),
      month: any(named: 'month'),
    ),
  ).thenAnswer((_) async => {day: children.map((c) => c.id).toList()});
  when(
    () => parentSchedule.getSessionCountForWeek(
      childId: any(named: 'childId'),
      anchorDate: any(named: 'anchorDate'),
    ),
  ).thenAnswer((_) async => count);
  when(learning.getChildren).thenAnswer((_) async => scopes);
  final hubs = {
    for (final c in scopes)
      c.id: ParentLearningHubData(
        childId: c.id,
        childName: c.name,
        className: '10A1',
        activeClassCount: count,
        activeClassNames: List.generate(count, (i) => 'Lớp Toán $i'),
        newInsightsCount: count,
        pendingHomeworkCount: count,
        courseProgressPercent: 0.65,
      ),
  };
  when(learning.getAllLearningHubData).thenAnswer((_) async => hubs);
  when(() => learning.getLearningHubData(any())).thenAnswer(
    (call) async => hubs[call.positionalArguments.first] ?? hubs.values.first,
  );
  when(
    () => learning.getClassDetail(any(), childId: any(named: 'childId')),
  ).thenAnswer(
    (_) async => ParentClassDetailModel(
      classId: 'class',
      className: 'Toán nâng cao',
      childName: children.first.fullName!,
      childId: children.first.id,
      semester: 'Học kỳ I',
      teacherName: 'Cô Lan',
      teacherTitle: 'Giáo viên Toán',
      teacherInitials: 'CL',
      scheduleFixed: 'Thứ 2 · 09:00',
      roomOrPlatform: 'Phòng 302',
      completedSessions: 1,
      totalSessions: count,
      attendanceRatePercent: 95,
      averageGrade: 8.5,
      lessons: List.generate(
        count,
        (i) => ClassLessonItem(
          sessionNumber: i + 1,
          title: 'Buổi học $i',
          timeSubtitle: '09:00',
          status: ClassLessonStatus.upcoming,
          statusLabel: 'Sắp diễn ra',
        ),
      ),
    ),
  );
  when(() => learning.getLearningInsights(any())).thenAnswer(
    (_) async => ParentLearningInsightsModel(
      childId: children.first.id,
      childName: children.first.fullName!,
      className: '10A1',
      focusTrendPoints: List.generate(
        count > 12 ? 12 : count,
        (i) => FocusTrendDataPoint(
          week: i + 1,
          score: 70 + i.toDouble(),
          label: 'T${i + 1}',
        ),
      ),
      focusTrendNote: 'Tiến bộ theo tuần',
      observationContent: 'Tập trung tốt hơn',
      interpretationContent: 'Con đã chủ động học tập',
      actionContent: 'Tiếp tục luyện tập',
      strengthTitle: 'Tư duy logic',
      strengthContent: 'Áp dụng kiến thức vào bài tập',
    ),
  );
  when(() => learning.getRecommendedCourses(any())).thenAnswer(
    (_) async => List.generate(
      count,
      (i) => ParentRecommendedCourseItem(
        id: 'course-$i',
        title: 'Khóa Toán $i',
        reasonDescription: 'Phù hợp với tiến độ học tập của con',
        tagLabel: 'Gợi ý',
        tagTextColor: Colors.blue,
        tagBgColor: const Color(0xFFEFF6FF),
        matchPercent: 95,
        sessionInfo: '12 buổi',
        teacherName: 'Cô Lan',
        tuitionFee: 1600000,
        categoryFilter: 'toan',
      ),
    ),
  );
  when(
    () => learning.getRecommendedCourseDetail(
      any(),
      childId: any(named: 'childId'),
    ),
  ).thenAnswer(
    (_) async => ParentRecommendedCourseDetailModel(
      courseId: 'course',
      courseName: 'Toán nâng cao',
      subtitle: 'Đại số',
      childName: children.first.fullName!,
      whyRecommendedReason: 'Phù hợp với nhu cầu học tập',
      syllabusModules: List.generate(
        count,
        (i) => CourseSyllabusModule(
          order: i + 1,
          title: 'Chuyên đề $i',
          description: 'Lý thuyết và bài tập',
        ),
      ),
    ),
  );
  when(() => insights.getInsights(childId: any(named: 'childId'))).thenAnswer(
    (_) async => List.generate(
      count,
      (i) => FamilyInsightItem(
        id: 'insight-$i',
        childId: children[i % children.length].id,
        childName: children[i % children.length].fullName!,
        className: '10A1',
        subjectOrSkill: 'Toán',
        category: FamilyInsightCategory.values[i % 3],
        timeAgoText: 'Hôm nay',
        title: 'Tiến bộ học tập $i',
        description: 'Con đã hoàn thành tốt bài học',
        metrics: const [InsightMetric(label: 'Điểm', value: '8.5')],
      ),
    ),
  );
}
