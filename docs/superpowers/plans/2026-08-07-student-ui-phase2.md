# Student UI Phase 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement Course Detail and Lesson Detail screens for Student Learning flow.

**Dependencies:** Phase 1 completed (Student Shell, Home, Learning screens)

**Tech Stack:** Flutter, flutter_bloc, freezed, go_router

---

## File Structure

```
lib/
  features/
    student/
      bloc/
        course_detail/
          course_detail_bloc.dart
          course_detail_event.dart
          course_detail_state.dart
        lesson/
          lesson_bloc.dart
          lesson_event.dart
          lesson_state.dart
      presentation/
        learning/
          course_detail_screen.dart
          lesson_detail_screen.dart
          widgets/
            section_list.dart
            section_item.dart
            lesson_item.dart
            lesson_content_tabs.dart
            lesson_nav_bar.dart
```

---

### Task 1: Course Detail Bloc

**Files:**
- Create: `lib/features/student/bloc/course_detail/course_detail_event.dart`
- Create: `lib/features/student/bloc/course_detail/course_detail_state.dart`
- Create: `lib/features/student/bloc/course_detail/course_detail_bloc.dart`

**Interfaces:**
- Consumes: `StudentRepository` (add getCourseDetail method)
- Produces: `CourseDetailBloc` with course info, sections, lessons tree

- [ ] **Step 1: Add getCourseDetail to repository**

```dart
// In student_repository.dart, add:
Future<ApiResult<EnrollmentModel>> getCourseDetail(String enrollmentId);
```

- [ ] **Step 2: Write course detail events**

```dart
// course_detail_event.dart
sealed class CourseDetailEvent extends Equatable {
  const CourseDetailEvent();
  @override
  List<Object?> get props => [];
}

final class CourseDetailStarted extends CourseDetailEvent {
  const CourseDetailStarted(this.enrollmentId);
  final String enrollmentId;
  @override
  List<Object?> get props => [enrollmentId];
}

final class CourseDetailSectionToggled extends CourseDetailEvent {
  const CourseDetailSectionToggled(this.sectionId);
  final String sectionId;
  @override
  List<Object?> get props => [sectionId];
}
```

- [ ] **Step 3: Write course detail state**

```dart
// course_detail_state.dart
sealed class CourseDetailState extends Equatable {
  const CourseDetailState();
  @override
  List<Object?> get props => [];
}

final class CourseDetailInitial extends CourseDetailState {
  const CourseDetailInitial();
}

final class CourseDetailInProgress extends CourseDetailState {
  const CourseDetailInProgress();
}

final class CourseDetailSuccess extends CourseDetailState {
  const CourseDetailSuccess({
    required this.enrollment,
    this.expandedSections = const {},
  });

  final EnrollmentModel enrollment;
  final Set<String> expandedSections;

  CourseModel? get course => enrollment.course;
  List<SectionModel> get sections => course?.sections ?? [];

  @override
  List<Object?> get props => [enrollment, expandedSections];

  CourseDetailSuccess copyWith({
    EnrollmentModel? enrollment,
    Set<String>? expandedSections,
  }) {
    return CourseDetailSuccess(
      enrollment: enrollment ?? this.enrollment,
      expandedSections: expandedSections ?? this.expandedSections,
    );
  }
}

final class CourseDetailFailure extends CourseDetailState {
  const CourseDetailFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 4: Write course detail bloc**

- [ ] **Step 5: Commit**

---

### Task 2: Course Detail Screen UI

**Files:**
- Create: `lib/features/student/presentation/learning/widgets/section_item.dart`
- Create: `lib/features/student/presentation/learning/widgets/lesson_item.dart`
- Create: `lib/features/student/presentation/learning/widgets/section_list.dart`
- Create: `lib/features/student/presentation/learning/course_detail_screen.dart`

**Interfaces:**
- Consumes: `CourseDetailBloc`
- Produces: Course detail screen with hero, info, progress, sections tree

- [ ] **Step 1: Write lesson item widget**

```dart
// lesson_item.dart
class LessonItem extends StatelessWidget {
  const LessonItem({
    super.key,
    required this.lesson,
    required this.status,
    this.onTap,
  });

  final LessonModel lesson;
  final LessonStatus status; // completed, current, locked
  final VoidCallback? onTap;
}
```

- [ ] **Step 2: Write section item widget**

```dart
// section_item.dart
class SectionItem extends StatelessWidget {
  const SectionItem({
    super.key,
    required this.section,
    required this.isExpanded,
    required this.completedCount,
    this.onToggle,
    this.onLessonTap,
  });
}
```

- [ ] **Step 3: Write section list widget**

- [ ] **Step 4: Write course detail screen**

```dart
// course_detail_screen.dart
// Layout:
// 1. Hero: Course thumbnail with gradient overlay
// 2. Info card: Title, instructor, duration, lesson count
// 3. Progress bar with percentage
// 4. Section list (collapsible)
```

- [ ] **Step 5: Update CourseCard to navigate**

- [ ] **Step 6: Commit**

---

### Task 3: Lesson Bloc

**Files:**
- Create: `lib/features/student/bloc/lesson/lesson_event.dart`
- Create: `lib/features/student/bloc/lesson/lesson_state.dart`
- Create: `lib/features/student/bloc/lesson/lesson_bloc.dart`

**Interfaces:**
- Consumes: Repository (add getLessonDetail, markLessonComplete)
- Produces: `LessonBloc` with lesson content, progress tracking

- [ ] **Step 1: Add lesson methods to repository**

- [ ] **Step 2: Write lesson events**

```dart
// lesson_event.dart
sealed class LessonEvent extends Equatable {...}

final class LessonStarted extends LessonEvent {
  const LessonStarted(this.lessonId);
  final String lessonId;
}

final class LessonContentTabChanged extends LessonEvent {
  const LessonContentTabChanged(this.tab);
  final LessonContentTab tab; // video, documents, quiz, notes
}

final class LessonCompleted extends LessonEvent {
  const LessonCompleted();
}

final class LessonNavigated extends LessonEvent {
  const LessonNavigated(this.direction); // prev, next
  final LessonNavDirection direction;
}
```

- [ ] **Step 3: Write lesson state**

- [ ] **Step 4: Write lesson bloc**

- [ ] **Step 5: Commit**

---

### Task 4: Lesson Detail Screen UI

**Files:**
- Create: `lib/features/student/presentation/learning/widgets/lesson_content_tabs.dart`
- Create: `lib/features/student/presentation/learning/widgets/lesson_nav_bar.dart`
- Create: `lib/features/student/presentation/learning/lesson_detail_screen.dart`

**Interfaces:**
- Consumes: `LessonBloc`
- Produces: Lesson detail screen with video player, tabs, nav

- [ ] **Step 1: Write lesson content tabs**

```dart
// lesson_content_tabs.dart
// Tabs: Video | Tai lieu | Bai tap | Ghi chu
class LessonContentTabs extends StatelessWidget {
  const LessonContentTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.lesson,
  });
}
```

- [ ] **Step 2: Write lesson nav bar**

```dart
// lesson_nav_bar.dart
// Bottom bar: Prev | Progress indicator | Next | Complete button
class LessonNavBar extends StatelessWidget {
  const LessonNavBar({
    super.key,
    required this.currentIndex,
    required this.totalLessons,
    required this.isCompleted,
    this.onPrev,
    this.onNext,
    this.onComplete,
  });
}
```

- [ ] **Step 3: Write lesson detail screen**

```dart
// lesson_detail_screen.dart
// Layout:
// 1. Video player (16:9 aspect ratio)
// 2. Lesson title + info
// 3. Content tabs
// 4. Tab content (scrollable)
// 5. Bottom nav bar (fixed)
```

- [ ] **Step 4: Wire up navigation from course detail**

- [ ] **Step 5: Commit**

---

### Task 5: Video Player Integration

**Files:**
- Create: `lib/features/student/presentation/learning/widgets/lesson_video_player.dart`

**Interfaces:**
- Consumes: Video URL from lesson content
- Produces: Video player widget with controls, progress tracking

- [ ] **Step 1: Add video_player dependency (if not exists)**

- [ ] **Step 2: Create video player widget**

```dart
// lesson_video_player.dart
class LessonVideoPlayer extends StatefulWidget {
  const LessonVideoPlayer({
    super.key,
    required this.videoUrl,
    this.initialPosition,
    this.onProgressChanged,
    this.onCompleted,
  });
}
```

- [ ] **Step 3: Handle video progress tracking**

- [ ] **Step 4: Commit**

---

### Task 6: Routing Integration

**Files:**
- Modify: `lib/routes/` (add student routes)

- [ ] **Step 1: Add course detail route**

```dart
// /student/course/:enrollmentId
GoRoute(
  path: 'course/:enrollmentId',
  builder: (context, state) => BlocProvider(
    create: (_) => CourseDetailBloc(repository)
      ..add(CourseDetailStarted(state.pathParameters['enrollmentId']!)),
    child: const CourseDetailScreen(),
  ),
)
```

- [ ] **Step 2: Add lesson detail route**

```dart
// /student/lesson/:lessonId
GoRoute(
  path: 'lesson/:lessonId',
  builder: (context, state) => BlocProvider(
    create: (_) => LessonBloc(repository)
      ..add(LessonStarted(state.pathParameters['lessonId']!)),
    child: const LessonDetailScreen(),
  ),
)
```

- [ ] **Step 3: Update navigation in screens**

- [ ] **Step 4: Commit**

---

## Summary

**Tasks in Phase 2:**
1. Course Detail Bloc
2. Course Detail Screen UI
3. Lesson Bloc
4. Lesson Detail Screen UI
5. Video Player Integration
6. Routing Integration

**Next phases:**
- Phase 3: Schedule Tab (Calendar view)
- Phase 4: Achievement Tab
- Phase 5: Profile Tab
- Phase 6: Additional screens (Notifications, Search, Bookmarks)
