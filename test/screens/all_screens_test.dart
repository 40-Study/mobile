import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
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
import 'package:study/features/parent/data/models/parent_schedule_session.dart';
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
class _ParentLearningRepository extends Mock implements ParentLearningRepository {}
class _FamilyInsightsRepository extends Mock implements FamilyInsightsRepository {}
class _ParentHomeRepository extends Mock implements ParentHomeRepository {}
class _ParentScheduleRepository extends Mock implements ParentScheduleRepository {}

const _user = UserModel(id: 'user', email: 'student@example.com', fullName: 'Test Student');
const _role = RoleModel(id: 'student', name: 'STUDENT', type: 'system');
const _course = CourseModel(id: 'course', title: 'Test Course', instructorName: 'Test Teacher');
const _lesson = LessonModel(id: 'lesson', title: 'Test Lesson');
const _enrollment = EnrollmentModel(id: 'enrollment', courseId: 'course', course: _course);
const _certificate = CertificateModel(id: 'certificate', courseTitle: 'Test Course', userName: 'Test Student');
final _parentSession = ParentScheduleSession(
  id: 'session', childId: 'child', childName: 'Minh', childInitial: 'M',
  childBadgeColor: Colors.blue, subjectName: 'Toán', lessonTopic: 'Hàm số',
  startTime: DateTime.utc(2026, 9, 27, 9), endTime: DateTime.utc(2026, 9, 27, 10),
  instructorName: 'Cô Lan', status: ParentSessionStatus.upcoming,
);

// Each concrete screen has an explicit fixture. The inventory test below makes
// adding a screen without adding its fixture a test failure.
final _screens = <Widget>[
  const SplashView(), const MainScreen(), const OnboardingScreen(),
  const LoginScreen(), const LoginRolePickerScreen(sessionToken: 'session', roles: [_role]),
  const SelectRoleScreen(), const RegisterFormScreen(), const RegisterOtpScreen(),
  const ForgotPasswordScreen(), const ForgotPasswordOtpScreen(), const ResetPasswordScreen(),
  const AddProfileScreen(), const ChangePasswordScreen(), const EditProfileScreen(), const SecurityScreen(),
  const ParentShell(), const ParentHomeScreen(), const ParentLearningScreen(),
  const ParentScheduleScreen(), const ParentPaymentScreen(), const ParentProfileScreen(),
  const ParentClassDetailScreen(),
  const ParentCourseDetailScreen(courseId: 'course', childName: 'Minh'),
  const ParentLearningInsightsScreen(childId: 'child', childName: 'Minh'),
  const ParentRecommendedCoursesScreen(childId: 'child', childName: 'Minh'),
  ParentSessionDetailScreen(session: _parentSession),
  const FamilyInsightsInboxScreen(),
  const ManageChildrenScreen(), const AddChildScreen(), const ChildDetailScreen(child: _user),
  const StudentShell(), const HomeScreen(), const LearningScreen(), const ScheduleScreen(),
  const AchievementScreen(), const ProfileScreen(), const BookmarkScreen(), const SearchScreen(),
  const NotificationScreen(), const AllCoursesScreen(), const ExploreCoursesScreen(),
  const CourseDetailScreen(), const LessonDetailScreen(),
  const InstructorDetailScreen(instructorId: 'teacher', instructorName: 'Test Teacher'),
  const QuizScreen(quizId: 'quiz', title: 'Test Quiz'),
  const QuizResultScreen(title: 'Test Quiz', correct: 1, total: 1, score: 100),
  const AllAchievementsScreen(badges: []), const AllCertificatesScreen(certificates: [_certificate]),
  const CertificateDetailScreen(certificate: _certificate),
  DailyGoalsScreen(date: DateTime(2026, 9, 27)),
  const SettingsScreen(), const HelpCenterScreen(), const PortfolioScreen(),
  PortfolioPreviewScreen(profile: kMockProfile, stats: kMockStats, sections: const [],
    projects: kMockProjects, skills: kMockSkills, experiences: kMockExperiences),
];

late _AuthRepository auth;
late _StudentRepository student;
late SharedPreferences prefs;

Future<void> _setUp() async {
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
  when(() => student.getContinueLearning()).thenAnswer((_) async => const Result.success(null));
  when(() => student.getTodaySchedule()).thenAnswer((_) async => const Result.success([]));
  when(() => student.getScheduleByDate(any())).thenAnswer((_) async => const Result.success([]));
  when(() => student.getEventDates(any())).thenAnswer((_) async => const Result.success(<DateTime>{}));
  when(() => student.getPendingAssignments()).thenAnswer((_) async => const Result.success([]));
  when(() => student.getActiveEnrollments()).thenAnswer((_) async => const Result.success([]));
  when(() => student.getAllCourses(page: any(named: 'page'))).thenAnswer((_) async => const Result.success([]));
  when(() => student.getStats()).thenAnswer((_) async => const Result.success(StudentStatsModel()));
  when(() => student.getBadges()).thenAnswer((_) async => const Result.success([]));
  when(() => student.getCertificates()).thenAnswer((_) async => const Result.success([]));
  when(() => student.getContributions(any())).thenAnswer((_) async => const Result.success([]));
  when(() => student.getNotifications()).thenAnswer((_) async => const Result.success([]));
  when(() => student.getCourseDetail(any())).thenAnswer((_) async => const Result.success(_enrollment));
  when(() => student.setLastAccessedCourse(any())).thenAnswer((_) async {});
  when(() => student.getLessonDetail(any())).thenAnswer((_) async => const Result.success(_lesson));
  when(() => student.getQuizzesByLesson(any())).thenAnswer((_) async => const Result.success([]));
  when(() => student.startQuiz(any())).thenAnswer((_) async => const Result.success((
    attemptId: 'attempt', timeLimitMinutes: 5,
    questions: [QuizQuestionModel(id: 'question', question: 'What is 1 + 1?', answers: [
      QuizAnswerModel(id: 'a', answerText: '2', isCorrect: true),
      QuizAnswerModel(id: 'b', answerText: '3'),
    ])],
  )));
  final di = GetIt.instance;
  final parentLearning = _ParentLearningRepository();
  final familyInsights = _FamilyInsightsRepository();
  final parentHome = _ParentHomeRepository();
  final parentSchedule = _ParentScheduleRepository();
  when(() => parentLearning.getClassDetail(any(), childId: any(named: 'childId')))
      .thenAnswer((_) async => null);
  when(() => parentLearning.getLearningInsights(any())).thenAnswer((_) async => null);
  when(() => parentLearning.getChildren()).thenAnswer((_) async => []);
  when(() => parentLearning.getAllLearningHubData()).thenAnswer((_) async => {});
  when(() => parentLearning.getRecommendedCourses(any())).thenAnswer((_) async => []);
  when(() => parentLearning.getRecommendedCourseDetail(any(), childId: any(named: 'childId')))
      .thenAnswer((_) async => null);
  when(() => familyInsights.getInsights()).thenAnswer((_) async => []);
  when(() => parentHome.getChildren()).thenAnswer((_) async => []);
  when(() => parentHome.getAlerts()).thenAnswer((_) async => []);
  when(() => parentHome.getSchedules()).thenAnswer((_) async => []);
  when(() => parentHome.getAnalyticsList()).thenAnswer((_) async => []);
  when(() => parentSchedule.getChildren()).thenAnswer((_) async => []);
  when(() => parentSchedule.getSessionsForDate(date: any(named: 'date')))
      .thenAnswer((_) async => []);
  when(() => parentSchedule.getEventsMapByMonth(month: any(named: 'month')))
      .thenAnswer((_) async => {});
  when(() => parentSchedule.getSessionCountForWeek(anchorDate: any(named: 'anchorDate')))
      .thenAnswer((_) async => 0);
  when(() => parentSchedule.getScheduleSessions()).thenAnswer((_) async => []);
  when(() => parentSchedule.getEventDates(anchorDate: any(named: 'anchorDate')))
      .thenAnswer((_) async => []);
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
  di.registerFactory<ParentLearningBloc>(() => ParentLearningBloc(parentLearning));
  di.registerFactory<ParentScheduleBloc>(() => ParentScheduleBloc(parentSchedule));
  di.registerFactory<CourseDetailBloc>(() => CourseDetailBloc(student, _CourseRepository(), bookmarks));
}

Future<void> _pump(WidgetTester tester, Widget screen, {Size size = const Size(390, 844)}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey<NavigatorState>();
  final navigation = NavigationService(navigatorKey: key);
  await tester.pumpWidget(MultiRepositoryProvider(
    providers: [
      RepositoryProvider<AuthRepository>.value(value: auth),
      RepositoryProvider<AuthStorage>.value(value: SharedPreferencesAuthStorage(prefs)),
      RepositoryProvider<NavigationService>.value(value: navigation),
    ],
    child: MultiBlocProvider(providers: [
      BlocProvider(create: (_) => AuthBloc(auth)..emit(const AuthAuthenticated(user: _user))),
      BlocProvider(create: (_) => ThemeCubit(ThemeRepositoryImpl(SharedPreferencesThemeStorage(prefs)))),
      BlocProvider(create: (_) => AccountCubit(authRepository: auth)..loadAccount()),
      BlocProvider(create: (_) => HomeBloc(student)),
      BlocProvider(create: (_) => LearningBloc(student)),
      BlocProvider(create: (_) => ScheduleBloc(student)),
      BlocProvider(create: (_) => AchievementBloc(student, auth)),
      BlocProvider(create: (_) => GetIt.instance<CourseDetailBloc>()..add(const CourseDetailStarted('enrollment'))),
      BlocProvider(create: (_) => LessonBloc(student)..add(const LessonStarted('lesson'))),
    ], child: Builder(builder: (context) => MaterialApp(
      theme: MaterialTheme(createTextTheme(context: context)).light(),
      navigatorKey: key, locale: const Locale('vi'),
      supportedLocales: appSupportedLocales, localizationsDelegates: appLocalizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      onGenerateRoute: (settings) => settings.name == '/'
        ? MaterialPageRoute<void>(settings: RouteSettings(arguments:
            screen is ForgotPasswordOtpScreen ? 'student@example.com' :
            screen is ResetPasswordScreen ? {'email': 'student@example.com', 'otp': '123456'} : null), builder: (_) => screen)
        : navigation.onGenerateRoute(settings),
    ))),
  ));
  // Bounded pumps also work with OTP/quiz timers and looping illustrations.
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto')..addFont(rootBundle.load('google_fonts/Roboto-Medium.ttf'));
    await font.load();
  });
  setUp(_setUp);
  tearDown(() async => GetIt.instance.reset());

  test('every concrete screen has a fixture', () {
    final classes = Directory('lib/features').listSync(recursive: true)
      .whereType<File>().where((f) => f.path.endsWith('.dart'))
      .expand((f) => RegExp(r'class (\w+(?:Screen|Shell)|SplashView) extends (?:StatefulWidget|StatelessWidget)')
        .allMatches(f.readAsStringSync()).map((m) => m.group(1)!)).toSet();
    expect(_screens.map((w) => w.runtimeType.toString()).toSet(), containsAll(classes));
  });

  for (final screen in _screens) {
    for (final size in [const Size(390, 844), const Size(360, 800)]) {
      testWidgets('${screen.runtimeType} renders and disposes at ${size.width.toInt()}px', (tester) async {
        await mockNetworkImagesFor(() async {
          await _pump(tester, screen, size: size);
          expect(find.byType(screen.runtimeType), findsOneWidget);
          expect(find.byType(Scaffold), findsWidgets);
          final exception = tester.takeException();
          expect(
            exception,
            isNull,
            reason: exception is FlutterError
                ? exception.diagnostics.map((node) => node.toString()).join('\n')
                : exception?.toString(),
          );
          await _dispose(tester);
        });
      });
    }
  }

  testWidgets('daily goals rejects blank input, adds, completes and deletes a goal', (tester) async {
    await _pump(tester, DailyGoalsScreen(date: DateTime(2026, 9, 27)));
    await tester.enterText(find.byType(TextField), '   ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.byType(Dismissible), findsNothing);
    await tester.enterText(find.byType(TextField), 'Read one lesson');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Read one lesson'), findsOneWidget);
    expect(find.text('Hoàn thành 0/1'), findsOneWidget);
    await tester.tap(find.text('Read one lesson'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hoàn thành 1/1'), findsOneWidget);
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Read one lesson'), findsNothing);
    expect(find.text('Hoàn thành 0/0'), findsOneWidget);
    await _dispose(tester);
  });
}
