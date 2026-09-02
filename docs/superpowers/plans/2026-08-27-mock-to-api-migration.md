# Mock Data to API Migration Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all hardcoded mock data with real API calls using existing Retrofit pattern.

**Architecture:** Create `StudentApiClient` (Retrofit) for student-specific endpoints. Update `StudentRepositoryImpl` to call real APIs. Blocs remain unchanged - they already consume repository.

**Tech Stack:** Retrofit, Dio, Injectable, json_serializable

**Spec:** Based on `FULL_API_DOCUMENTATION.md` endpoints

## Global Constraints

- Pattern: Retrofit `@RestApi()` + Dio (see `auth_api_client.dart`)
- DI: Injectable `@module` registration (see `di_repository_module.dart`)
- Response: `HttpResponse<dynamic>` -> parse in repository impl
- Error: Wrap in `ApiResult<T>` (existing pattern)
- Models: Use `json_serializable` with `@JsonSerializable()`
- No breaking changes to Bloc layer - repository interface stays same

---

## File Structure

```
lib/
├── features/student/
│   ├── data/
│   │   ├── student_api_client.dart      # NEW - Retrofit client
│   │   ├── student_api_client.g.dart    # GENERATED
│   │   └── models/
│   │       ├── notification_model.dart  # UPDATE - add fromJson
│   │       ├── bookmark_model.dart      # UPDATE - add fromJson
│   │       ├── schedule_item_model.dart # UPDATE - add fromJson
│   │       ├── achievement_response.dart # NEW - API response model
│   │       └── quiz_question_model.dart # NEW - API model
│   ├── repository/
│   │   ├── student_repository.dart      # UPDATE - add missing methods
│   │   └── student_repository_impl.dart # UPDATE - real API calls
│   └── bloc/
│       ├── notification/notification_bloc.dart  # UPDATE - use repository
│       ├── bookmark/bookmark_bloc.dart          # UPDATE - use local storage
│       ├── schedule/schedule_bloc.dart          # UPDATE - use repository
│       ├── achievement/achievement_bloc.dart    # UPDATE - use repository
│       └── search/search_bloc.dart              # UPDATE - use repository
├── di/
│   └── di_repository_module.dart        # UPDATE - register StudentApiClient
└── data/
    └── bookmark_storage.dart            # NEW - local storage for bookmarks
```

---

### Task 1: Create StudentApiClient

**Files:**
- Create: `lib/features/student/data/student_api_client.dart`

**Interfaces:**
- Produces: `StudentApiClient` with methods for schedule, notifications, achievements, quiz

- [ ] **Step 1: Create student_api_client.dart**

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'student_api_client.g.dart';

@RestApi()
abstract class StudentApiClient {
  factory StudentApiClient(Dio dio, {String baseUrl}) = _StudentApiClient;

  // Schedule - need classId from enrollment
  @GET('/api/classes/{classId}/schedules/')
  Future<HttpResponse<dynamic>> getSchedules(
    @Path('classId') String classId, {
    @Query('date') String? date,
  });

  // Notifications
  @GET('/api/notifications/')
  Future<HttpResponse<dynamic>> getNotifications({
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  @GET('/api/notifications/unread-count')
  Future<HttpResponse<dynamic>> getUnreadCount();

  @PATCH('/api/notifications/read-all')
  Future<HttpResponse<dynamic>> markAllRead();

  @PATCH('/api/notifications/{id}/read')
  Future<HttpResponse<dynamic>> markRead(@Path('id') String id);

  // Achievements
  @GET('/api/achievements/me')
  Future<HttpResponse<dynamic>> getMyAchievements();

  // Quiz
  @GET('/api/quizzes/{quizId}/questions')
  Future<HttpResponse<dynamic>> getQuizQuestions(@Path('quizId') String quizId);

  @POST('/api/quizzes/{quizId}/start')
  Future<HttpResponse<dynamic>> startQuiz(@Path('quizId') String quizId);

  @POST('/api/quizzes/{quizId}/submit')
  Future<HttpResponse<dynamic>> submitQuiz(
    @Path('quizId') String quizId,
    @Body() Map<String, dynamic> answers,
  );

  // Search courses
  @GET('/api/courses')
  Future<HttpResponse<dynamic>> searchCourses({
    @Query('search') String? query,
    @Query('page') int page = 1,
    @Query('page_size') int pageSize = 20,
  });

  // Calendar events
  @GET('/api/me/events/')
  Future<HttpResponse<dynamic>> getMyEvents({
    @Query('start_date') String? startDate,
    @Query('end_date') String? endDate,
  });
}
```

- [ ] **Step 2: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `student_api_client.g.dart` generated

- [ ] **Step 3: Commit**

```bash
git add lib/features/student/data/student_api_client.dart
git add lib/features/student/data/student_api_client.g.dart
git commit -m "feat: add StudentApiClient for student endpoints"
```

---

### Task 2: Register StudentApiClient in DI

**Files:**
- Modify: `lib/di/di_repository_module.dart`

**Interfaces:**
- Consumes: `StudentApiClient`, `Dio`
- Produces: DI registration for `StudentApiClient`

- [ ] **Step 1: Update di_repository_module.dart**

Add import and factory method:

```dart
import 'package:study/features/student/data/student_api_client.dart';

@module
abstract class RepositoryModule {
  // ... existing providers ...

  @factoryMethod
  StudentApiClient provideStudentApiClient(Dio dio) => StudentApiClient(dio);
}
```

- [ ] **Step 2: Regenerate DI**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add lib/di/di_repository_module.dart
git commit -m "feat: register StudentApiClient in DI module"
```

---

### Task 3: Update Models with fromJson

**Files:**
- Modify: `lib/features/student/data/models/notification_model.dart`
- Modify: `lib/features/student/data/models/schedule_item_model.dart`
- Modify: `lib/features/student/data/models/badge_model.dart`

**Interfaces:**
- Produces: `fromJson` factory constructors for API parsing

- [ ] **Step 1: Update notification_model.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

enum NotificationType {
  @JsonValue('course') course,
  @JsonValue('assignment') assignment,
  @JsonValue('livestream') livestream,
  @JsonValue('system') system,
  @JsonValue('achievement') achievement,
}

@JsonSerializable()
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
```

- [ ] **Step 2: Update schedule_item_model.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'schedule_item_model.g.dart';

@JsonSerializable()
class ScheduleItemModel {
  const ScheduleItemModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.instructorName,
    this.type = ScheduleType.lesson,
  });

  final String id;
  final String title;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  final String? location;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  final ScheduleType type;

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemModelFromJson(json);
}

enum ScheduleType {
  @JsonValue('lesson') lesson,
  @JsonValue('livestream') livestream,
  @JsonValue('exam') exam,
  @JsonValue('assignment') assignment,
}
```

- [ ] **Step 3: Update badge_model.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'badge_model.g.dart';

@JsonSerializable()
class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.isUnlocked,
    this.unlockedAt,
    this.progress = 0,
  });

  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'icon_url')
  final String iconUrl;
  @JsonKey(name: 'is_unlocked')
  final bool isUnlocked;
  @JsonKey(name: 'unlocked_at')
  final DateTime? unlockedAt;
  final int progress;

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeModelFromJson(json);
}
```

- [ ] **Step 4: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/student/data/models/
git commit -m "feat: add json_serializable to student models"
```

---

### Task 4: Create QuizQuestionModel

**Files:**
- Create: `lib/features/student/data/models/quiz_question_model.dart`

**Interfaces:**
- Produces: `QuizQuestionModel` for quiz API response

- [ ] **Step 1: Create quiz_question_model.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'quiz_question_model.g.dart';

@JsonSerializable()
class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  @JsonKey(name: 'correct_answer')
  final int correctAnswer;
  final String? explanation;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);
}
```

- [ ] **Step 2: Export in models.dart barrel**

Add to `lib/features/student/data/models/models.dart`:

```dart
export 'quiz_question_model.dart';
```

- [ ] **Step 3: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/student/data/models/quiz_question_model.dart
git add lib/features/student/data/models/quiz_question_model.g.dart
git add lib/features/student/data/models/models.dart
git commit -m "feat: add QuizQuestionModel"
```

---

### Task 5: Create BookmarkStorage (Local)

**Files:**
- Create: `lib/data/bookmark_storage.dart`

**Interfaces:**
- Produces: `BookmarkStorage` for local bookmark persistence (no API available)

- [ ] **Step 1: Create bookmark_storage.dart**

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study/features/student/data/models/bookmark_model.dart';

class BookmarkStorage {
  BookmarkStorage(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'bookmarks';

  Future<List<BookmarkModel>> getAll() async {
    final json = _prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => BookmarkModel.fromJson(e)).toList();
  }

  Future<void> save(BookmarkModel bookmark) async {
    final all = await getAll();
    all.add(bookmark);
    await _prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> remove(String id) async {
    final all = await getAll();
    all.removeWhere((b) => b.id == id);
    await _prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }
}
```

- [ ] **Step 2: Update bookmark_model.dart for serialization**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'bookmark_model.g.dart';

enum BookmarkType {
  @JsonValue('course') course,
  @JsonValue('lesson') lesson,
  @JsonValue('document') document,
}

@JsonSerializable()
class BookmarkModel {
  const BookmarkModel({
    required this.id,
    required this.title,
    required this.type,
    required this.savedAt,
    this.subtitle,
    this.targetId,
  });

  final String id;
  final String title;
  final BookmarkType type;
  @JsonKey(name: 'saved_at')
  final DateTime savedAt;
  final String? subtitle;
  @JsonKey(name: 'target_id')
  final String? targetId;

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$BookmarkModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkModelToJson(this);
}
```

- [ ] **Step 3: Run build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/data/bookmark_storage.dart
git add lib/features/student/data/models/bookmark_model.dart
git add lib/features/student/data/models/bookmark_model.g.dart
git commit -m "feat: add BookmarkStorage for local persistence"
```

---

### Task 6: Update StudentRepository Interface

**Files:**
- Modify: `lib/features/student/repository/student_repository.dart`

**Interfaces:**
- Produces: Extended interface with notification, achievement, quiz, search methods

- [ ] **Step 1: Update student_repository.dart**

```dart
import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';

abstract class StudentRepository {
  // Schedule
  Future<ApiResult<List<ScheduleItemModel>>> getTodaySchedule();
  Future<ApiResult<List<ScheduleItemModel>>> getScheduleByDate(DateTime date);
  Future<ApiResult<Set<DateTime>>> getEventDates(DateTime month);

  // Assignments
  Future<ApiResult<List<AssignmentModel>>> getPendingAssignments();

  // Enrollments
  Future<ApiResult<List<EnrollmentModel>>> getActiveEnrollments();
  Future<ApiResult<EnrollmentModel?>> getContinueLearning();
  Future<ApiResult<EnrollmentModel>> getCourseDetail(String enrollmentId);

  // Lesson
  Future<ApiResult<LessonModel>> getLessonDetail(String lessonId);
  Future<ApiResult<void>> markLessonComplete(String lessonId);

  // Notifications
  Future<ApiResult<List<NotificationModel>>> getNotifications();
  Future<ApiResult<int>> getUnreadNotificationCount();
  Future<ApiResult<void>> markNotificationRead(String id);
  Future<ApiResult<void>> markAllNotificationsRead();

  // Achievements
  Future<ApiResult<List<BadgeModel>>> getBadges();
  Future<ApiResult<List<CertificateModel>>> getCertificates();
  Future<ApiResult<StudentStatsModel>> getStats();

  // Quiz
  Future<ApiResult<List<QuizQuestionModel>>> getQuizQuestions(String quizId);

  // Search
  Future<ApiResult<List<CourseModel>>> searchCourses(String query);
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/student/repository/student_repository.dart
git commit -m "feat: extend StudentRepository interface"
```

---

### Task 7: Update StudentRepositoryImpl with Real API Calls

**Files:**
- Modify: `lib/features/student/repository/student_repository_impl.dart`

**Interfaces:**
- Consumes: `StudentApiClient`, `CourseApiClient`
- Produces: Real API implementations

- [ ] **Step 1: Update student_repository_impl.dart**

```dart
import 'package:injectable/injectable.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/course_api_client.dart';
import 'package:study/features/course/data/models/course_model.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/student_api_client.dart';
import 'package:study/features/student/repository/student_repository.dart';

@Injectable(as: StudentRepository)
class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._studentApi, this._courseApi);

  final StudentApiClient _studentApi;
  final CourseApiClient _courseApi;

  String? _currentClassId; // Cache from enrollment

  @override
  Future<ApiResult<List<ScheduleItemModel>>> getTodaySchedule() {
    return getScheduleByDate(DateTime.now());
  }

  @override
  Future<ApiResult<List<ScheduleItemModel>>> getScheduleByDate(DateTime date) async {
    try {
      if (_currentClassId == null) {
        // Get classId from active enrollment
        final enrollments = await _courseApi.getMyEnrollments(status: 'active');
        final data = enrollments.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          _currentClassId = data.first['class_id'] as String?;
        }
      }

      if (_currentClassId == null) {
        return ApiResult.success([]);
      }

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _studentApi.getSchedules(_currentClassId!, date: dateStr);
      final list = (response.data['data'] as List?) ?? [];
      return ApiResult.success(
        list.map((e) => ScheduleItemModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<Set<DateTime>>> getEventDates(DateTime month) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);
      final response = await _studentApi.getMyEvents(
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
      );
      final list = (response.data['data'] as List?) ?? [];
      final dates = list.map((e) => DateTime.parse(e['date'] as String)).toSet();
      return ApiResult.success(dates);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _studentApi.getNotifications();
      final list = (response.data['data'] as List?) ?? [];
      return ApiResult.success(
        list.map((e) => NotificationModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<int>> getUnreadNotificationCount() async {
    try {
      final response = await _studentApi.getUnreadCount();
      final count = response.data['data']['count'] as int? ?? 0;
      return ApiResult.success(count);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<void>> markNotificationRead(String id) async {
    try {
      await _studentApi.markRead(id);
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<void>> markAllNotificationsRead() async {
    try {
      await _studentApi.markAllRead();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<BadgeModel>>> getBadges() async {
    try {
      final response = await _studentApi.getMyAchievements();
      final list = (response.data['data']['badges'] as List?) ?? [];
      return ApiResult.success(
        list.map((e) => BadgeModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<CertificateModel>>> getCertificates() async {
    try {
      final response = await _courseApi.getMyCertificates();
      final list = (response.data['data'] as List?) ?? [];
      return ApiResult.success(
        list.map((e) => CertificateModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<QuizQuestionModel>>> getQuizQuestions(String quizId) async {
    try {
      final response = await _studentApi.getQuizQuestions(quizId);
      final list = (response.data['data'] as List?) ?? [];
      return ApiResult.success(
        list.map((e) => QuizQuestionModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<List<CourseModel>>> searchCourses(String query) async {
    try {
      final response = await _studentApi.searchCourses(query: query);
      final list = (response.data['data'] as List?) ?? [];
      return ApiResult.success(
        list.map((e) => CourseModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  // ... keep existing implementations for other methods ...
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/student/repository/student_repository_impl.dart
git commit -m "feat: implement real API calls in StudentRepositoryImpl"
```

---

### Task 8: Update NotificationBloc to Use Repository

**Files:**
- Modify: `lib/features/student/bloc/notification/notification_bloc.dart`

**Interfaces:**
- Consumes: `StudentRepository`

- [ ] **Step 1: Update notification_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';
import 'package:study/features/student/bloc/notification/notification_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._repository) : super(const NotificationInitial()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationMarkedAllRead>(_onMarkedAllRead);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationInProgress());

    final result = await _repository.getNotifications();

    result.when(
      success: (notifications) {
        emit(NotificationSuccess(notifications: notifications));
      },
      failure: (message) {
        emit(NotificationFailure(message));
      },
    );
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationState> emit,
  ) async {
    await _repository.markNotificationRead(event.id);
    // Refresh list
    add(const NotificationStarted());
  }

  Future<void> _onMarkedAllRead(
    NotificationMarkedAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    await _repository.markAllNotificationsRead();
    add(const NotificationStarted());
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/student/bloc/notification/notification_bloc.dart
git commit -m "refactor: NotificationBloc uses repository instead of mock"
```

---

### Task 9: Update BookmarkBloc to Use Local Storage

**Files:**
- Modify: `lib/features/student/bloc/bookmark/bookmark_bloc.dart`

**Interfaces:**
- Consumes: `BookmarkStorage`

- [ ] **Step 1: Update bookmark_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  BookmarkBloc(this._storage) : super(const BookmarkInitial()) {
    on<BookmarkStarted>(_onStarted);
    on<BookmarkRemoved>(_onRemoved);
    on<BookmarkFilterChanged>(_onFilterChanged);
  }

  final BookmarkStorage _storage;

  Future<void> _onStarted(
    BookmarkStarted event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(const BookmarkInProgress());

    try {
      final bookmarks = await _storage.getAll();
      emit(BookmarkSuccess(bookmarks: bookmarks));
    } catch (e) {
      emit(BookmarkFailure(e.toString()));
    }
  }

  Future<void> _onRemoved(
    BookmarkRemoved event,
    Emitter<BookmarkState> emit,
  ) async {
    await _storage.remove(event.id);
    add(const BookmarkStarted());
  }

  void _onFilterChanged(
    BookmarkFilterChanged event,
    Emitter<BookmarkState> emit,
  ) {
    final current = state;
    if (current is BookmarkSuccess) {
      emit(current.copyWith(filter: event.filter));
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/student/bloc/bookmark/bookmark_bloc.dart
git commit -m "refactor: BookmarkBloc uses local storage"
```

---

### Task 10: Update ScheduleBloc to Use Repository

**Files:**
- Modify: `lib/features/student/bloc/schedule/schedule_bloc.dart`

**Interfaces:**
- Consumes: `StudentRepository`

- [ ] **Step 1: Update schedule_bloc.dart - remove _generateMockEventDates**

Replace mock event generation with repository call:

```dart
// In _onMonthChanged handler:
Future<void> _onMonthChanged(
  ScheduleMonthChanged event,
  Emitter<ScheduleState> emit,
) async {
  final newMonth = DateTime(event.year, event.month);

  // Fetch event dates from API
  final result = await _repository.getEventDates(newMonth);
  final eventDates = result.when(
    success: (dates) => dates,
    failure: (_) => <DateTime>{},
  );

  emit(state.copyWith(
    currentMonth: newMonth,
    eventDates: eventDates,
  ));
}
```

- [ ] **Step 2: Remove _generateMockEventDates method entirely**

- [ ] **Step 3: Commit**

```bash
git add lib/features/student/bloc/schedule/schedule_bloc.dart
git commit -m "refactor: ScheduleBloc uses repository for event dates"
```

---

### Task 11: Update AchievementBloc to Use Repository

**Files:**
- Modify: `lib/features/student/bloc/achievement/achievement_bloc.dart`

**Interfaces:**
- Consumes: `StudentRepository`

- [ ] **Step 1: Update achievement_bloc.dart - remove _mockCertificates**

```dart
Future<void> _onStarted(
  AchievementStarted event,
  Emitter<AchievementState> emit,
) async {
  emit(const AchievementInProgress());

  final badgesResult = await _repository.getBadges();
  final certsResult = await _repository.getCertificates();
  final statsResult = await _repository.getStats();

  // Combine results
  if (badgesResult.isSuccess && certsResult.isSuccess && statsResult.isSuccess) {
    emit(AchievementSuccess(
      badges: badgesResult.data!,
      certificates: certsResult.data!,
      stats: statsResult.data!,
    ));
  } else {
    emit(AchievementFailure(
      badgesResult.error ?? certsResult.error ?? statsResult.error ?? 'Unknown error',
    ));
  }
}
```

- [ ] **Step 2: Remove _mockCertificates method**

- [ ] **Step 3: Commit**

```bash
git add lib/features/student/bloc/achievement/achievement_bloc.dart
git commit -m "refactor: AchievementBloc uses repository"
```

---

### Task 12: Update SearchBloc to Use Repository

**Files:**
- Modify: `lib/features/student/bloc/search/search_bloc.dart`

**Interfaces:**
- Consumes: `StudentRepository`

- [ ] **Step 1: Update search_bloc.dart**

Replace mock search with real API:

```dart
Future<void> _onQueryChanged(
  SearchQueryChanged event,
  Emitter<SearchState> emit,
) async {
  final query = event.query.trim();
  if (query.isEmpty) {
    emit(SearchInitial(recentSearches: state.recentSearches));
    return;
  }

  emit(SearchInProgress(query: query, filter: state.filter));

  final result = await _repository.searchCourses(query);

  result.when(
    success: (courses) {
      emit(SearchSuccess(
        query: query,
        filter: state.filter,
        results: courses,
      ));
    },
    failure: (message) {
      emit(SearchFailure(query: query));
    },
  );
}
```

- [ ] **Step 2: Remove mock delay and hardcoded results**

- [ ] **Step 3: Commit**

```bash
git add lib/features/student/bloc/search/search_bloc.dart
git commit -m "refactor: SearchBloc uses repository for course search"
```

---

### Task 13: Update QuizScreen to Use Repository

**Files:**
- Modify: `lib/features/student/presentation/learning/quiz_screen.dart`

**Interfaces:**
- Consumes: `StudentRepository` via BlocProvider

- [ ] **Step 1: Create QuizBloc**

Create `lib/features/student/bloc/quiz/quiz_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

class QuizStarted extends QuizEvent {
  const QuizStarted(this.quizId);
  final String quizId;
  @override
  List<Object?> get props => [quizId];
}

class QuizAnswerSelected extends QuizEvent {
  const QuizAnswerSelected(this.questionIndex, this.answerIndex);
  final int questionIndex;
  final int answerIndex;
  @override
  List<Object?> get props => [questionIndex, answerIndex];
}

// States
abstract class QuizState extends Equatable {
  const QuizState();
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizReady extends QuizState {
  const QuizReady({
    required this.questions,
    required this.currentIndex,
    required this.answers,
  });
  final List<QuizQuestionModel> questions;
  final int currentIndex;
  final Map<int, int> answers;

  @override
  List<Object?> get props => [questions, currentIndex, answers];

  QuizReady copyWith({int? currentIndex, Map<int, int>? answers}) {
    return QuizReady(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
    );
  }
}

class QuizFailure extends QuizState {
  const QuizFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// Bloc
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc(this._repository) : super(const QuizInitial()) {
    on<QuizStarted>(_onStarted);
    on<QuizAnswerSelected>(_onAnswerSelected);
  }

  final StudentRepository _repository;

  Future<void> _onStarted(QuizStarted event, Emitter<QuizState> emit) async {
    emit(const QuizLoading());

    final result = await _repository.getQuizQuestions(event.quizId);

    result.when(
      success: (questions) {
        emit(QuizReady(questions: questions, currentIndex: 0, answers: {}));
      },
      failure: (message) {
        emit(QuizFailure(message));
      },
    );
  }

  void _onAnswerSelected(QuizAnswerSelected event, Emitter<QuizState> emit) {
    final current = state;
    if (current is QuizReady) {
      final newAnswers = Map<int, int>.from(current.answers);
      newAnswers[event.questionIndex] = event.answerIndex;
      emit(current.copyWith(answers: newAnswers));
    }
  }
}
```

- [ ] **Step 2: Update quiz_screen.dart to use QuizBloc**

Remove hardcoded `_questions` list and use `BlocBuilder<QuizBloc, QuizState>`.

- [ ] **Step 3: Commit**

```bash
git add lib/features/student/bloc/quiz/
git add lib/features/student/presentation/learning/quiz_screen.dart
git commit -m "refactor: QuizScreen uses QuizBloc with repository"
```

---

### Task 14: Update All Achievements Screen

**Files:**
- Modify: `lib/features/student/presentation/achievement/all_achievements_screen.dart`

**Interfaces:**
- Consumes: `AchievementBloc` state instead of local mock

- [ ] **Step 1: Remove _generateMockBadges and use bloc state**

Replace local `_allBadges` with `BlocBuilder` consuming `AchievementBloc`.

- [ ] **Step 2: Commit**

```bash
git add lib/features/student/presentation/achievement/all_achievements_screen.dart
git commit -m "refactor: AllAchievementsScreen uses bloc instead of mock"
```

---

### Task 15: Update All Certificates Screen

**Files:**
- Modify: `lib/features/student/presentation/achievement/all_certificates_screen.dart`

**Interfaces:**
- Consumes: `AchievementBloc` state

- [ ] **Step 1: Remove _generateMockData and use bloc state**

- [ ] **Step 2: Commit**

```bash
git add lib/features/student/presentation/achievement/all_certificates_screen.dart
git commit -m "refactor: AllCertificatesScreen uses bloc instead of mock"
```

---

### Task 16: Clean Up - Remove Fake Delays

**Files:**
- Modify: `lib/features/student/repository/student_repository_impl.dart`
- Modify: `lib/features/student/bloc/profile/profile_bloc.dart`

**Interfaces:**
- Remove all `Future.delayed` mock delays

- [ ] **Step 1: Search and remove all Future.delayed in student feature**

```bash
grep -r "Future.delayed" lib/features/student/
```

Remove each occurrence.

- [ ] **Step 2: Commit**

```bash
git add lib/features/student/
git commit -m "chore: remove mock delays from student feature"
```

---

### Task 17: Final Integration Test

**Files:**
- Run app and verify each screen

- [ ] **Step 1: Run app in dev mode**

```bash
flutter run --dart-define=ENV=dev
```

- [ ] **Step 2: Verify each migrated screen:**

| Screen | Expected |
|--------|----------|
| Notifications | Loads from API, mark read works |
| Bookmarks | Persists locally, survives app restart |
| Schedule | Shows real class schedule |
| Achievements | Loads badges/certs from API |
| Search | Real course search results |
| Quiz | Questions from API |

- [ ] **Step 3: Final commit**

```bash
git add .
git commit -m "feat: complete mock to API migration"
```

---

## Summary

| Task | Component | Migration Type |
|------|-----------|----------------|
| 1-2 | StudentApiClient | New Retrofit client |
| 3-4 | Models | Add fromJson |
| 5 | BookmarkStorage | Local storage (no API) |
| 6-7 | StudentRepository | Interface + impl |
| 8 | NotificationBloc | Use repository |
| 9 | BookmarkBloc | Use local storage |
| 10 | ScheduleBloc | Use repository |
| 11 | AchievementBloc | Use repository |
| 12 | SearchBloc | Use repository |
| 13 | QuizScreen | New QuizBloc + repository |
| 14-15 | Achievement screens | Use bloc state |
| 16 | Cleanup | Remove delays |
| 17 | Integration | Verify all |

**Not migrated (no API available):**
- `portfolio_screen.dart` - needs portfolio API
- `stats_view.dart` contribution grid - needs activity API
- `daily_goals_screen.dart` - suggest local storage similar to bookmarks
