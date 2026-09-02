# Mock to API Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace mock data with real API calls across student features

**Spec:** `docs/superpowers/specs/2026-09-03-mock-to-api-migration-spec.md`

**Tech Stack:** Flutter, Bloc, Retrofit, Freezed

## Global Constraints

- Run `flutter pub run build_runner build` after model changes
- No commit/push without user permission
- Bookmark uses localStorage (not API)
- FE-only fixes — backend extensions documented separately

---

## Task 1: Fix ProfileBloc to Use Auth Service

**Files:**
- Modify: `lib/features/student/bloc/profile/profile_bloc.dart`
- Modify: `lib/di/di_initializer.config.dart` (if needed)

**Interfaces:**
- Consumes: `AuthRepository.getCurrentUser()` or stored user from auth state
- Produces: `ProfileSuccess(user: UserModel)` from real data

- [ ] **Step 1: Check AuthRepository interface**

```bash
grep -n "getCurrentUser\|getUser\|me" lib/features/auth/repository/*.dart
```

- [ ] **Step 2: Add AuthRepository dependency to ProfileBloc**

```dart
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._authRepository) : super(const ProfileInitial()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;
```

- [ ] **Step 3: Replace mock with real API call**

```dart
Future<void> _onStarted(
  ProfileStarted event,
  Emitter<ProfileState> emit,
) async {
  emit(const ProfileInProgress());

  final result = await _authRepository.getCurrentUser();

  result.when(
    success: (user) => emit(ProfileSuccess(user: user)),
    failure: (f) => emit(ProfileFailure(f.message ?? 'Lỗi tải profile')),
  );
}
```

- [ ] **Step 4: Update DI registration**

Check `di_initializer.config.dart` — ensure ProfileBloc receives AuthRepository.

- [ ] **Step 5: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Test manually**

Verify profile screen loads real user data.

- [ ] **Step 7: Commit**

```bash
git add lib/features/student/bloc/profile/
git commit -m "feat(profile): replace mock with auth repository"
```

---

## Task 2: Create ContributionModel for Activity Data

**Files:**
- Create: `lib/features/student/data/models/contribution_model.dart`
- Modify: `lib/features/student/data/models/models.dart`

**Interfaces:**
- Consumes: Backend `activity[]` from `/api/users/:id/public-profile`
- Produces: `ContributionModel` with `date`, `count` fields

- [ ] **Step 1: Create ContributionModel**

```dart
// lib/features/student/data/models/contribution_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contribution_model.freezed.dart';
part 'contribution_model.g.dart';

@freezed
abstract class ContributionModel with _$ContributionModel {
  const factory ContributionModel({
    required String date,
    @Default(0) int count,
  }) = _ContributionModel;

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionModelFromJson(json);
}
```

- [ ] **Step 2: Export from models.dart**

```dart
// Add to lib/features/student/data/models/models.dart
export 'contribution_model.dart';
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/student/data/models/
git commit -m "feat(models): add ContributionModel for activity grid"
```

---

## Task 3: Add Public Profile API to StudentApiClient

**Files:**
- Modify: `lib/features/student/data/student_api_client.dart`

**Interfaces:**
- Consumes: Nothing
- Produces: `getPublicProfile(userId)` method returning activity data

- [ ] **Step 1: Add endpoint to StudentApiClient**

```dart
// Add to student_api_client.dart

// Public Profile with contribution activity
@GET('/api/users/{userId}/public-profile')
Future<HttpResponse<dynamic>> getPublicProfile(
  @Path('userId') String userId,
);
```

- [ ] **Step 2: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/student/data/student_api_client.dart
git commit -m "feat(api): add public profile endpoint"
```

---

## Task 4: Add getContributions to StudentRepository

**Files:**
- Modify: `lib/features/student/repository/student_repository.dart`
- Modify: `lib/features/student/repository/student_repository_impl.dart`

**Interfaces:**
- Consumes: `StudentApiClient.getPublicProfile()`
- Produces: `Future<ApiResult<List<ContributionModel>>> getContributions(String userId)`

- [ ] **Step 1: Add method to abstract repository**

```dart
// Add to student_repository.dart
Future<ApiResult<List<ContributionModel>>> getContributions(String userId);
```

- [ ] **Step 2: Implement in repository_impl**

```dart
// Add to student_repository_impl.dart
@override
Future<ApiResult<List<ContributionModel>>> getContributions(String userId) async {
  try {
    final response = await _apiClient.getPublicProfile(userId);
    final data = response.data['data'] as Map<String, dynamic>?;
    if (data == null) return const ApiResult.success([]);

    final activityList = data['activity'] as List<dynamic>? ?? [];
    final contributions = activityList
        .map((e) => ContributionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ApiResult.success(contributions);
  } on DioException catch (e) {
    return ApiResult.failure(ApiFailure.fromDioException(e));
  } catch (e) {
    return ApiResult.failure(ApiFailure(message: e.toString()));
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/student/repository/
git commit -m "feat(repository): add getContributions method"
```

---

## Task 5: Create ContributionCubit

**Files:**
- Create: `lib/features/student/bloc/contribution/contribution_cubit.dart`
- Create: `lib/features/student/bloc/contribution/contribution_state.dart`

**Interfaces:**
- Consumes: `StudentRepository.getContributions()`
- Produces: `ContributionState` with `List<ContributionModel>`

- [ ] **Step 1: Create state**

```dart
// lib/features/student/bloc/contribution/contribution_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/student/data/models/models.dart';

part 'contribution_state.freezed.dart';

@freezed
sealed class ContributionState with _$ContributionState {
  const factory ContributionState.initial() = ContributionInitial;
  const factory ContributionState.loading() = ContributionLoading;
  const factory ContributionState.success(List<ContributionModel> contributions) = ContributionSuccess;
  const factory ContributionState.failure(String message) = ContributionFailure;
}
```

- [ ] **Step 2: Create cubit**

```dart
// lib/features/student/bloc/contribution/contribution_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/contribution/contribution_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class ContributionCubit extends Cubit<ContributionState> {
  ContributionCubit(this._repository) : super(const ContributionInitial());

  final StudentRepository _repository;

  Future<void> load(String userId) async {
    emit(const ContributionLoading());

    final result = await _repository.getContributions(userId);

    result.when(
      success: (data) => emit(ContributionSuccess(data)),
      failure: (f) => emit(ContributionFailure(f.message ?? 'Lỗi tải dữ liệu')),
    );
  }
}
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/student/bloc/contribution/
git commit -m "feat(bloc): add ContributionCubit for activity grid"
```

---

## Task 6: Update StatsView to Use Real Data

**Files:**
- Modify: `lib/features/student/presentation/achievement/widgets/stats_view.dart`

**Interfaces:**
- Consumes: `ContributionCubit` state
- Produces: Real contribution grid instead of mock

- [ ] **Step 1: Remove mock generator method**

Delete `_generateMockContributions()` method (lines ~182-193).

- [ ] **Step 2: Add BlocProvider and consume state**

```dart
// In parent widget or at StatsView level, wrap with:
BlocProvider(
  create: (_) => ContributionCubit(diContainer<StudentRepository>())
    ..load(userId),
  child: StatsView(...),
)
```

- [ ] **Step 3: Replace mock data with BlocBuilder**

```dart
BlocBuilder<ContributionCubit, ContributionState>(
  builder: (context, state) {
    final contributions = switch (state) {
      ContributionSuccess(:final contributions) =>
        contributions.map((c) => c.count).toList(),
      _ => List.filled(84, 0),
    };

    return _ContributionGrid(contributions: contributions);
  },
)
```

- [ ] **Step 4: Test manually**

Verify grid shows real data (or zeros if no activity).

- [ ] **Step 5: Commit**

```bash
git add lib/features/student/presentation/achievement/widgets/stats_view.dart
git commit -m "feat(stats): replace mock contribution with real API data"
```

---

## Task 7: Update AchievementScreen Contribution Grid

**Files:**
- Modify: `lib/features/student/presentation/achievement/achievement_screen.dart`

**Interfaces:**
- Consumes: Same `ContributionCubit` as Task 6
- Produces: Real contribution grid in achievement screen

- [ ] **Step 1: Remove mock contribution code**

Delete mock data generation around lines 820-828.

- [ ] **Step 2: Share ContributionCubit or create new instance**

```dart
BlocProvider(
  create: (_) => ContributionCubit(diContainer<StudentRepository>())
    ..load(userId),
  child: _ContributionSection(),
)
```

- [ ] **Step 3: Update UI to use state**

Same pattern as Task 6.

- [ ] **Step 4: Test manually**

Verify achievement screen shows real contribution data.

- [ ] **Step 5: Commit**

```bash
git add lib/features/student/presentation/achievement/achievement_screen.dart
git commit -m "feat(achievement): replace mock contribution with real data"
```

---

## Task 8: Document Backend Requirements

**Files:**
- Create: `docs/backend-api-requirements.md`

**Interfaces:**
- Consumes: Findings from spec
- Produces: Clear documentation for backend team

- [ ] **Step 1: Create backend requirements doc**

```markdown
# Backend API Requirements for Mobile

## 1. Teacher Stats Endpoint (NEW)
GET /api/teachers/:id/stats
Response: { total_courses, total_students, total_lessons, average_rating }

## 2. Teacher Courses Endpoint (NEW)
GET /api/teachers/:id/courses?page=1
Response: paginated course list

## 3. TeacherProfileDTO Extensions
Add fields: short_bio, about, skills[], location

## 4. CertificateDTO Extensions
Add fields: skills[], duration, level
```

- [ ] **Step 2: Commit**

```bash
git add docs/backend-api-requirements.md
git commit -m "docs: add backend API requirements for mobile"
```

---

## Summary

| Task | Description | Priority |
|------|-------------|----------|
| 1 | ProfileBloc auth integration | High |
| 2 | ContributionModel | High |
| 3 | Public profile API | High |
| 4 | Repository method | High |
| 5 | ContributionCubit | High |
| 6 | StatsView real data | High |
| 7 | AchievementScreen real data | High |
| 8 | Backend docs | Medium |

**Total estimated tasks:** 8
**Dependencies:** Tasks 2-5 sequential, then 6-7 parallel
