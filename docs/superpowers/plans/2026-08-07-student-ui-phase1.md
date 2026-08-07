# Student UI Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement core Student UI - navigation shell, home tab, and learning tab for MVP.

**Architecture:** Feature-based structure with Bloc state management. Reuse existing widgets (EnrollmentCard, SectionHeader). New student feature folder with data/bloc/presentation layers.

**Tech Stack:** Flutter, flutter_bloc, freezed, retrofit, go_router

## Global Constraints

- Flutter SDK: >=3.0.0
- Use existing theme from `lib/theme/` (AppSpacing, AppTypography, TogetherColorsX)
- Follow bloc rules from `.claude/rules/bloc.md`
- Models use freezed with JSON serialization
- API client uses retrofit
- All text in Vietnamese (no diacritics in code identifiers)

---

## File Structure

```
lib/
  features/
    student/
      data/
        models/
          schedule_item_model.dart      # Lich hoc item
          assignment_model.dart         # Bai tap
        dto/
          dto.dart                      # Export all DTOs
        student_api_client.dart         # Retrofit client
      repository/
        student_repository.dart         # Abstract repo
        student_repository_impl.dart    # Implementation
      bloc/
        home/
          home_bloc.dart
          home_event.dart
          home_state.dart
        learning/
          learning_bloc.dart
          learning_event.dart
          learning_state.dart
        course_detail/
          course_detail_bloc.dart
          course_detail_event.dart
          course_detail_state.dart
        lesson/
          lesson_bloc.dart
          lesson_event.dart
          lesson_state.dart
      presentation/
        student_shell.dart              # Bottom nav + drawer shell
        home/
          home_screen.dart
          widgets/
            continue_learning_card.dart
            schedule_timeline.dart
            schedule_timeline_item.dart
            assignment_list.dart
            assignment_item.dart
        learning/
          learning_screen.dart
          course_detail_screen.dart
          lesson_detail_screen.dart
          widgets/
            course_card.dart
            course_filter_chips.dart
            section_list.dart
            section_item.dart
            lesson_item.dart
            lesson_content_tabs.dart
  widgets/
    app_drawer.dart                     # Drawer menu
    timeline_dot.dart                   # Timeline dot component
```

---

### Task 1: Student Shell - Bottom Navigation

**Files:**
- Create: `lib/features/student/presentation/student_shell.dart`
- Test: `test/features/student/presentation/student_shell_test.dart`

**Interfaces:**
- Consumes: none
- Produces: `StudentShell` widget with 5 tabs, `StudentTab` enum

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/presentation/student_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/presentation/student_shell.dart';

void main() {
  group('StudentShell', () {
    testWidgets('should display 5 bottom navigation items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentShell(initialTab: StudentTab.home),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('should show Home tab content when Home is selected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudentShell(initialTab: StudentTab.home),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/presentation/student_shell_test.dart`
Expected: FAIL with "Target of URI hasn't been generated"

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/features/student/presentation/student_shell.dart
import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';

enum StudentTab { home, learning, schedule, achievement, profile }

class StudentShell extends StatefulWidget {
  const StudentShell({
    super.key,
    this.initialTab = StudentTab.home,
  });

  final StudentTab initialTab;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late StudentTab _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab.index,
        onDestinationSelected: (index) {
          setState(() {
            _currentTab = StudentTab.values[index];
          });
        },
        height: 64,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Hoc tap',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Lich hoc',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Thanh tich',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tai khoan',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case StudentTab.home:
        return const Center(child: Text('Home'));
      case StudentTab.learning:
        return const Center(child: Text('Learning'));
      case StudentTab.schedule:
        return const Center(child: Text('Schedule'));
      case StudentTab.achievement:
        return const Center(child: Text('Achievement'));
      case StudentTab.profile:
        return const Center(child: Text('Profile'));
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/student/presentation/student_shell_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/student/presentation/student_shell.dart test/features/student/presentation/student_shell_test.dart
git commit -m "feat(student): add student shell with bottom navigation"
```

---

### Task 2: App Drawer Component

**Files:**
- Create: `lib/widgets/app_drawer.dart`
- Test: `test/widgets/app_drawer_test.dart`

**Interfaces:**
- Consumes: User data from AuthBloc
- Produces: `AppDrawer` widget with menu items

- [ ] **Step 1: Write the failing test**

```dart
// test/widgets/app_drawer_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/widgets/app_drawer.dart';

void main() {
  group('AppDrawer', () {
    testWidgets('should display user header with name and email', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              userName: 'Nguyen Van A',
              userEmail: 'test@email.com',
              onNotificationsTap: () {},
              onBookmarksTap: () {},
              onSearchTap: () {},
              onSettingsTap: () {},
              onHelpTap: () {},
              onLogoutTap: () {},
            ),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('test@email.com'), findsOneWidget);
    });

    testWidgets('should display all menu items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: AppDrawer(
              userName: 'Test',
              userEmail: 'test@email.com',
              onNotificationsTap: () {},
              onBookmarksTap: () {},
              onSearchTap: () {},
              onSettingsTap: () {},
              onHelpTap: () {},
              onLogoutTap: () {},
            ),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Thong bao'), findsOneWidget);
      expect(find.text('Da luu'), findsOneWidget);
      expect(find.text('Tim kiem'), findsOneWidget);
      expect(find.text('Cai dat'), findsOneWidget);
      expect(find.text('Tro giup'), findsOneWidget);
      expect(find.text('Dang xuat'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/app_drawer_test.dart`
Expected: FAIL with "Target of URI hasn't been generated"

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    this.notificationCount = 0,
    required this.onNotificationsTap,
    required this.onBookmarksTap,
    required this.onSearchTap,
    required this.onSettingsTap,
    required this.onHelpTap,
    required this.onLogoutTap,
  });

  final String userName;
  final String userEmail;
  final String? userAvatar;
  final int notificationCount;
  final VoidCallback onNotificationsTap;
  final VoidCallback onBookmarksTap;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onHelpTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: cs.primary.withValues(alpha: 0.1),
                    backgroundImage: userAvatar != null
                        ? NetworkImage(userAvatar!)
                        : null,
                    child: userAvatar == null
                        ? Icon(Icons.person, color: cs.primary)
                        : null,
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Thong bao',
                    badge: notificationCount > 0 ? notificationCount : null,
                    onTap: onNotificationsTap,
                  ),
                  _DrawerItem(
                    icon: Icons.bookmark_outline,
                    label: 'Da luu',
                    onTap: onBookmarksTap,
                  ),
                  _DrawerItem(
                    icon: Icons.search,
                    label: 'Tim kiem',
                    onTap: onSearchTap,
                  ),
                  const Divider(height: 16, indent: 16, endIndent: 16),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Cai dat',
                    onTap: onSettingsTap,
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    label: 'Tro giup',
                    onTap: onHelpTap,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Dang xuat',
              iconColor: cs.error,
              labelColor: cs.error,
              onTap: onLogoutTap,
            ),
            AppSpacing.vGap8,
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badge;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: iconColor ?? cs.onSurface.withValues(alpha: 0.7)),
      title: Text(
        label,
        style: tt.bodyLarge?.copyWith(color: labelColor),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.toString(),
                style: tt.labelSmall?.copyWith(color: cs.onError),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/app_drawer_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/widgets/app_drawer.dart test/widgets/app_drawer_test.dart
git commit -m "feat(widgets): add app drawer component"
```

---

### Task 3: Schedule Timeline Components

**Files:**
- Create: `lib/widgets/timeline_dot.dart`
- Create: `lib/features/student/presentation/home/widgets/schedule_timeline_item.dart`
- Create: `lib/features/student/presentation/home/widgets/schedule_timeline.dart`
- Test: `test/features/student/presentation/home/widgets/schedule_timeline_test.dart`

**Interfaces:**
- Consumes: `ScheduleItemModel` (from Task 4)
- Produces: `ScheduleTimeline`, `ScheduleTimelineItem`, `TimelineDot` widgets

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/presentation/home/widgets/schedule_timeline_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';

void main() {
  group('ScheduleTimeline', () {
    testWidgets('should display timeline items', (tester) async {
      final items = [
        ScheduleTimelineItemData(
          time: '09:00 - 10:30',
          title: 'Toan cao cap',
          subtitle: 'Livestream - Phong A101',
          type: ScheduleItemType.livestream,
          isActive: true,
        ),
        ScheduleTimelineItemData(
          time: '14:00 - 15:30',
          title: 'Python Co ban',
          subtitle: 'Video - Bai 2.3 Functions',
          type: ScheduleItemType.video,
          isActive: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleTimeline(items: items),
          ),
        ),
      );

      expect(find.text('09:00 - 10:30'), findsOneWidget);
      expect(find.text('Toan cao cap'), findsOneWidget);
      expect(find.text('14:00 - 15:30'), findsOneWidget);
      expect(find.text('Python Co ban'), findsOneWidget);
    });

    testWidgets('should show empty state when no items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleTimeline(items: const []),
          ),
        ),
      );

      expect(find.text('Khong co lich hoc hom nay'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/presentation/home/widgets/schedule_timeline_test.dart`
Expected: FAIL

- [ ] **Step 3: Write timeline dot widget**

```dart
// lib/widgets/timeline_dot.dart
import 'package:flutter/material.dart';

class TimelineDot extends StatelessWidget {
  const TimelineDot({
    super.key,
    this.isActive = false,
    this.size = 12,
    this.activeColor,
    this.inactiveColor,
  });

  final bool isActive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = activeColor ?? cs.primary;
    final inactive = inactiveColor ?? cs.outline;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? active : Colors.transparent,
        border: Border.all(
          color: isActive ? active : inactive,
          width: 2,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Write timeline item widget**

```dart
// lib/features/student/presentation/home/widgets/schedule_timeline_item.dart
import 'package:flutter/material.dart';
import 'package:study/theme/app_spacing.dart';
import 'package:study/widgets/timeline_dot.dart';

enum ScheduleItemType { livestream, video, quiz, deadline }

class ScheduleTimelineItemData {
  const ScheduleTimelineItemData({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isActive = false,
    this.onTap,
    this.actionLabel,
  });

  final String time;
  final String title;
  final String subtitle;
  final ScheduleItemType type;
  final bool isActive;
  final VoidCallback? onTap;
  final String? actionLabel;
}

class ScheduleTimelineItem extends StatelessWidget {
  const ScheduleTimelineItem({
    super.key,
    required this.data,
    this.isLast = false,
  });

  final ScheduleTimelineItemData data;
  final bool isLast;

  IconData get _icon {
    switch (data.type) {
      case ScheduleItemType.livestream:
        return Icons.videocam;
      case ScheduleItemType.video:
        return Icons.play_circle_outline;
      case ScheduleItemType.quiz:
        return Icons.quiz_outlined;
      case ScheduleItemType.deadline:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 24,
            child: Column(
              children: [
                TimelineDot(isActive: data.isActive),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.hGap12,
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.time,
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Text(
                    data.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.vGap4,
                  Row(
                    children: [
                      Icon(_icon, size: 16, color: cs.onSurface.withValues(alpha: 0.6)),
                      AppSpacing.hGap4,
                      Expanded(
                        child: Text(
                          data.subtitle,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (data.actionLabel != null && data.onTap != null) ...[
                    AppSpacing.vGap8,
                    TextButton(
                      onPressed: data.onTap,
                      child: Text(data.actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Write timeline list widget**

```dart
// lib/features/student/presentation/home/widgets/schedule_timeline.dart
import 'package:flutter/material.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline_item.dart';
import 'package:study/theme/app_spacing.dart';

export 'schedule_timeline_item.dart';

class ScheduleTimeline extends StatelessWidget {
  const ScheduleTimeline({
    super.key,
    required this.items,
    this.emptyMessage = 'Khong co lich hoc hom nay',
  });

  final List<ScheduleTimelineItemData> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
              AppSpacing.vGap8,
              Text(
                emptyMessage,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return ScheduleTimelineItem(
            data: items[index],
            isLast: index == items.length - 1,
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/student/presentation/home/widgets/schedule_timeline_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/widgets/timeline_dot.dart \
  lib/features/student/presentation/home/widgets/schedule_timeline_item.dart \
  lib/features/student/presentation/home/widgets/schedule_timeline.dart \
  test/features/student/presentation/home/widgets/schedule_timeline_test.dart
git commit -m "feat(student): add schedule timeline components"
```

---

### Task 4: Student Data Models

**Files:**
- Create: `lib/features/student/data/models/schedule_item_model.dart`
- Create: `lib/features/student/data/models/assignment_model.dart`
- Create: `lib/features/student/data/models/models.dart`
- Test: `test/features/student/data/models/models_test.dart`

**Interfaces:**
- Consumes: none
- Produces: `ScheduleItemModel`, `AssignmentModel` with JSON serialization

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/data/models/models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/models.dart';

void main() {
  group('ScheduleItemModel', () {
    test('should parse from JSON', () {
      final json = {
        'id': '123',
        'title': 'Toan cao cap',
        'type': 'livestream',
        'start_time': '2026-08-07T09:00:00Z',
        'end_time': '2026-08-07T10:30:00Z',
        'course_name': 'Toan 10',
        'instructor_name': 'Nguyen Van A',
        'location': 'Phong A101',
      };

      final model = ScheduleItemModel.fromJson(json);

      expect(model.id, '123');
      expect(model.title, 'Toan cao cap');
      expect(model.type, 'livestream');
    });
  });

  group('AssignmentModel', () {
    test('should parse from JSON', () {
      final json = {
        'id': '456',
        'title': 'Quiz: Bien va kieu du lieu',
        'type': 'quiz',
        'course_name': 'Python Co ban',
        'due_date': '2026-08-09T23:59:59Z',
        'question_count': 10,
        'is_completed': false,
      };

      final model = AssignmentModel.fromJson(json);

      expect(model.id, '456');
      expect(model.title, 'Quiz: Bien va kieu du lieu');
      expect(model.type, 'quiz');
      expect(model.questionCount, 10);
      expect(model.isCompleted, false);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/data/models/models_test.dart`
Expected: FAIL

- [ ] **Step 3: Write ScheduleItemModel**

```dart
// lib/features/student/data/models/schedule_item_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_item_model.freezed.dart';
part 'schedule_item_model.g.dart';

@freezed
abstract class ScheduleItemModel with _$ScheduleItemModel {
  const factory ScheduleItemModel({
    required String id,
    required String title,
    required String type,
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'lesson_id') String? lessonId,
    @JsonKey(name: 'instructor_name') String? instructorName,
    String? location,
    @JsonKey(name: 'livestream_id') String? livestreamId,
  }) = _ScheduleItemModel;

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemModelFromJson(json);
}
```

- [ ] **Step 4: Write AssignmentModel**

```dart
// lib/features/student/data/models/assignment_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_model.freezed.dart';
part 'assignment_model.g.dart';

@freezed
abstract class AssignmentModel with _$AssignmentModel {
  const factory AssignmentModel({
    required String id,
    required String title,
    required String type,
    @JsonKey(name: 'course_name') String? courseName,
    @JsonKey(name: 'course_id') String? courseId,
    @JsonKey(name: 'lesson_id') String? lessonId,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'question_count') @Default(0) int questionCount,
    @JsonKey(name: 'is_completed') @Default(false) bool isCompleted,
    @JsonKey(name: 'submitted_at') DateTime? submittedAt,
    double? score,
  }) = _AssignmentModel;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);
}
```

- [ ] **Step 5: Create models barrel file**

```dart
// lib/features/student/data/models/models.dart
export 'schedule_item_model.dart';
export 'assignment_model.dart';
```

- [ ] **Step 6: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generated .freezed.dart and .g.dart files

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/features/student/data/models/models_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/features/student/data/models/
git commit -m "feat(student): add schedule and assignment data models"
```

---

### Task 5: Student API Client

**Files:**
- Create: `lib/features/student/data/student_api_client.dart`
- Test: `test/features/student/data/student_api_client_test.dart`

**Interfaces:**
- Consumes: Dio instance
- Produces: `StudentApiClient` with methods: `getSchedule()`, `getAssignments()`, `getEnrollments()`

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/data/student_api_client_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:study/features/student/data/student_api_client.dart';

@GenerateMocks([Dio])
import 'student_api_client_test.mocks.dart';

void main() {
  group('StudentApiClient', () {
    late MockDio mockDio;
    late StudentApiClient client;

    setUp(() {
      mockDio = MockDio();
      client = StudentApiClient(mockDio);
    });

    test('getSchedule should call correct endpoint', () async {
      when(mockDio.get('/me/schedule', queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                data: {'data': []},
                statusCode: 200,
                requestOptions: RequestOptions(path: '/me/schedule'),
              ));

      await client.getSchedule(date: '2026-08-07');

      verify(mockDio.get('/me/schedule', queryParameters: {'date': '2026-08-07'}));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/data/student_api_client_test.dart`
Expected: FAIL

- [ ] **Step 3: Write API client**

```dart
// lib/features/student/data/student_api_client.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:study/core/network/api_response.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';

part 'student_api_client.g.dart';

@RestApi()
abstract class StudentApiClient {
  factory StudentApiClient(Dio dio, {String? baseUrl}) = _StudentApiClient;

  @GET('/me/schedule')
  Future<ApiResponse<List<ScheduleItemModel>>> getSchedule({
    @Query('date') String? date,
  });

  @GET('/me/assignments')
  Future<ApiResponse<List<AssignmentModel>>> getAssignments({
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/enrollments')
  Future<ApiResponse<List<EnrollmentModel>>> getEnrollments({
    @Query('status') String? status,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });
}
```

- [ ] **Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Generated student_api_client.g.dart

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/student/data/student_api_client_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/student/data/student_api_client.dart
git commit -m "feat(student): add student API client"
```

---

### Task 6: Student Repository

**Files:**
- Create: `lib/features/student/repository/student_repository.dart`
- Create: `lib/features/student/repository/student_repository_impl.dart`
- Test: `test/features/student/repository/student_repository_test.dart`

**Interfaces:**
- Consumes: `StudentApiClient`, `CourseRepository`
- Produces: `StudentRepository` interface, `StudentRepositoryImpl`

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/repository/student_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:study/core/error/result.dart';
import 'package:study/core/network/api_response.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/student_api_client.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/features/student/repository/student_repository_impl.dart';

@GenerateMocks([StudentApiClient])
import 'student_repository_test.mocks.dart';

void main() {
  group('StudentRepository', () {
    late MockStudentApiClient mockApiClient;
    late StudentRepository repository;

    setUp(() {
      mockApiClient = MockStudentApiClient();
      repository = StudentRepositoryImpl(mockApiClient);
    });

    test('getTodaySchedule should return schedule items', () async {
      final items = [
        ScheduleItemModel(
          id: '1',
          title: 'Toan',
          type: 'livestream',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
        ),
      ];

      when(mockApiClient.getSchedule(date: anyNamed('date')))
          .thenAnswer((_) async => ApiResponse(data: items));

      final result = await repository.getTodaySchedule();

      expect(result.isSuccess, true);
      expect(result.data?.length, 1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/repository/student_repository_test.dart`
Expected: FAIL

- [ ] **Step 3: Write repository interface**

```dart
// lib/features/student/repository/student_repository.dart
import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';

abstract class StudentRepository {
  Future<Result<List<ScheduleItemModel>>> getTodaySchedule();
  Future<Result<List<ScheduleItemModel>>> getScheduleByDate(DateTime date);
  Future<Result<List<AssignmentModel>>> getPendingAssignments();
  Future<Result<List<EnrollmentModel>>> getActiveEnrollments();
  Future<Result<EnrollmentModel?>> getContinueLearning();
}
```

- [ ] **Step 4: Write repository implementation**

```dart
// lib/features/student/repository/student_repository_impl.dart
import 'package:intl/intl.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/student_api_client.dart';
import 'package:study/features/student/repository/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._apiClient);

  final StudentApiClient _apiClient;
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Future<Result<List<ScheduleItemModel>>> getTodaySchedule() async {
    return getScheduleByDate(DateTime.now());
  }

  @override
  Future<Result<List<ScheduleItemModel>>> getScheduleByDate(DateTime date) async {
    try {
      final response = await _apiClient.getSchedule(date: _dateFormat.format(date));
      return Result.success(response.data ?? []);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AssignmentModel>>> getPendingAssignments() async {
    try {
      final response = await _apiClient.getAssignments(status: 'pending');
      return Result.success(response.data ?? []);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<EnrollmentModel>>> getActiveEnrollments() async {
    try {
      final response = await _apiClient.getEnrollments(status: 'active');
      return Result.success(response.data ?? []);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<EnrollmentModel?>> getContinueLearning() async {
    try {
      final response = await _apiClient.getEnrollments(
        status: 'active',
        pageSize: 1,
      );
      final enrollments = response.data ?? [];
      if (enrollments.isEmpty) return Result.success(null);

      // Sort by last accessed, get most recent
      enrollments.sort((a, b) {
        final aTime = a.lastAccessedAt ?? DateTime(1970);
        final bTime = b.lastAccessedAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      return Result.success(enrollments.first);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/features/student/repository/student_repository_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/student/repository/
git commit -m "feat(student): add student repository"
```

---

### Task 7: Home Bloc

**Files:**
- Create: `lib/features/student/bloc/home/home_event.dart`
- Create: `lib/features/student/bloc/home/home_state.dart`
- Create: `lib/features/student/bloc/home/home_bloc.dart`
- Test: `test/features/student/bloc/home/home_bloc_test.dart`

**Interfaces:**
- Consumes: `StudentRepository`, `AuthBloc` (for user info)
- Produces: `HomeBloc` with `HomeLoaded` event, `HomeState` with continue learning, schedule, assignments

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/bloc/home/home_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/repository/student_repository.dart';

@GenerateMocks([StudentRepository])
import 'home_bloc_test.mocks.dart';

void main() {
  group('HomeBloc', () {
    late MockStudentRepository mockRepository;
    late HomeBloc bloc;

    setUp(() {
      mockRepository = MockStudentRepository();
      bloc = HomeBloc(mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be HomeInitial', () {
      expect(bloc.state, isA<HomeInitial>());
    });

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeSuccess] when HomeLoaded is added',
      build: () {
        when(mockRepository.getContinueLearning())
            .thenAnswer((_) async => Result.success(null));
        when(mockRepository.getTodaySchedule())
            .thenAnswer((_) async => Result.success([]));
        when(mockRepository.getPendingAssignments())
            .thenAnswer((_) async => Result.success([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const HomeLoaded()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeSuccess>(),
      ],
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/bloc/home/home_bloc_test.dart`
Expected: FAIL

- [ ] **Step 3: Write home events**

```dart
// lib/features/student/bloc/home/home_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoaded extends HomeEvent {
  const HomeLoaded();
}

class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}
```

- [ ] **Step 4: Write home state**

```dart
// lib/features/student/bloc/home/home_state.dart
import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/features/student/data/models/models.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeSuccess extends HomeState {
  const HomeSuccess({
    this.continueLearning,
    this.scheduleItems = const [],
    this.assignments = const [],
  });

  final EnrollmentModel? continueLearning;
  final List<ScheduleItemModel> scheduleItems;
  final List<AssignmentModel> assignments;

  @override
  List<Object?> get props => [continueLearning, scheduleItems, assignments];

  HomeSuccess copyWith({
    EnrollmentModel? continueLearning,
    List<ScheduleItemModel>? scheduleItems,
    List<AssignmentModel>? assignments,
  }) {
    return HomeSuccess(
      continueLearning: continueLearning ?? this.continueLearning,
      scheduleItems: scheduleItems ?? this.scheduleItems,
      assignments: assignments ?? this.assignments,
    );
  }
}

class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 5: Write home bloc**

```dart
// lib/features/student/bloc/home/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeInitial()) {
    on<HomeLoaded>(_onLoaded);
    on<HomeRefreshed>(_onRefreshed);
  }

  final StudentRepository _repository;

  Future<void> _onLoaded(HomeLoaded event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    final results = await Future.wait([
      _repository.getContinueLearning(),
      _repository.getTodaySchedule(),
      _repository.getPendingAssignments(),
    ]);

    final continueLearningResult = results[0];
    final scheduleResult = results[1];
    final assignmentsResult = results[2];

    if (continueLearningResult.isFailure ||
        scheduleResult.isFailure ||
        assignmentsResult.isFailure) {
      final message = continueLearningResult.failure?.message ??
          scheduleResult.failure?.message ??
          assignmentsResult.failure?.message ??
          'Unknown error';
      emit(HomeFailure(message));
      return;
    }

    emit(HomeSuccess(
      continueLearning: continueLearningResult.data,
      scheduleItems: scheduleResult.data ?? [],
      assignments: assignmentsResult.data ?? [],
    ));
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/student/bloc/home/home_bloc_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/features/student/bloc/home/
git commit -m "feat(student): add home bloc"
```

---

### Task 8: Home Screen UI

**Files:**
- Create: `lib/features/student/presentation/home/widgets/continue_learning_card.dart`
- Create: `lib/features/student/presentation/home/widgets/assignment_item.dart`
- Create: `lib/features/student/presentation/home/widgets/assignment_list.dart`
- Create: `lib/features/student/presentation/home/home_screen.dart`
- Modify: `lib/features/student/presentation/student_shell.dart`
- Test: `test/features/student/presentation/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `HomeBloc`, `AuthBloc`
- Produces: `HomeScreen` widget

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/presentation/home/home_screen_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/presentation/home/home_screen.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  group('HomeScreen', () {
    late MockHomeBloc mockBloc;

    setUp(() {
      mockBloc = MockHomeBloc();
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      whenListen(
        mockBloc,
        Stream.value(const HomeLoading()),
        initialState: const HomeLoading(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: mockBloc,
            child: const HomeScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show greeting when loaded', (tester) async {
      whenListen(
        mockBloc,
        Stream.value(const HomeSuccess()),
        initialState: const HomeSuccess(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<HomeBloc>.value(
            value: mockBloc,
            child: const HomeScreen(userName: 'Test User'),
          ),
        ),
      );

      expect(find.textContaining('Test User'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/presentation/home/home_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Write continue learning card**

```dart
// lib/features/student/presentation/home/widgets/continue_learning_card.dart
import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/theme/app_colors.dart';
import 'package:study/theme/app_spacing.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.enrollment,
    this.onContinueTap,
  });

  final EnrollmentModel enrollment;
  final VoidCallback? onContinueTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: cs.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle, size: 20, color: cs.primary),
              AppSpacing.hGap8,
              Text(
                'Tiep tuc hoc',
                style: tt.titleSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, color: cs.primary),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.course?.title ?? 'Khoa hoc',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGap4,
                    Text(
                      '${enrollment.completedLessons}/${enrollment.totalLessons} bai',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: cs.primary,
                    minHeight: 6,
                  ),
                ),
              ),
              AppSpacing.hGap12,
              Text(
                '${enrollment.progressPercentage.toStringAsFixed(0)}%',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onContinueTap,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Tiep tuc'),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Write assignment item and list**

```dart
// lib/features/student/presentation/home/widgets/assignment_item.dart
import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/theme/app_spacing.dart';

class AssignmentItem extends StatelessWidget {
  const AssignmentItem({
    super.key,
    required this.assignment,
    this.onTap,
  });

  final AssignmentModel assignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final daysLeft = assignment.dueDate != null
        ? assignment.dueDate!.difference(DateTime.now()).inDays
        : null;
    final isUrgent = daysLeft != null && daysLeft < 3;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isUrgent ? cs.error : cs.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          assignment.type == 'quiz' ? Icons.quiz : Icons.assignment,
          color: isUrgent ? cs.error : cs.primary,
          size: 20,
        ),
      ),
      title: Text(
        assignment.title,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${assignment.courseName ?? "Khoa hoc"} • ${assignment.questionCount} cau hoi',
        style: tt.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (daysLeft != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isUrgent ? cs.error : cs.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Con $daysLeft ngay',
                style: tt.labelSmall?.copyWith(
                  color: isUrgent ? cs.error : cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          AppSpacing.hGap8,
          TextButton(
            onPressed: onTap,
            child: const Text('Lam'),
          ),
        ],
      ),
    );
  }
}
```

```dart
// lib/features/student/presentation/home/widgets/assignment_list.dart
import 'package:flutter/material.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/home/widgets/assignment_item.dart';
import 'package:study/theme/app_spacing.dart';

class AssignmentList extends StatelessWidget {
  const AssignmentList({
    super.key,
    required this.assignments,
    this.onItemTap,
  });

  final List<AssignmentModel> assignments;
  final void Function(AssignmentModel)? onItemTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (assignments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.withValues(alpha: 0.5),
              ),
              AppSpacing.vGap8,
              Text(
                'Hoan thanh tat ca bai tap!',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: assignments.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return AssignmentItem(
            assignment: assignment,
            onTap: () => onItemTap?.call(assignment),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 5: Write home screen**

```dart
// lib/features/student/presentation/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/home/home_bloc.dart';
import 'package:study/features/student/bloc/home/home_event.dart';
import 'package:study/features/student/bloc/home/home_state.dart';
import 'package:study/features/student/presentation/home/widgets/assignment_list.dart';
import 'package:study/features/student/presentation/home/widgets/continue_learning_card.dart';
import 'package:study/features/student/presentation/home/widgets/schedule_timeline.dart';
import 'package:study/theme/app_spacing.dart';
import 'package:study/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.userName,
  });

  final String? userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Xin chao, ${widget.userName ?? "Ban"}',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.hGap4,
            const Text('👋'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary.withValues(alpha: 0.1),
              child: Icon(Icons.person, size: 18, color: cs.primary),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  AppSpacing.vGap16,
                  Text(state.message),
                  AppSpacing.vGap16,
                  FilledButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const HomeLoaded());
                    },
                    child: const Text('Thu lai'),
                  ),
                ],
              ),
            );
          }

          if (state is HomeSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshed());
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  // Continue learning
                  if (state.continueLearning != null) ...[
                    ContinueLearningCard(
                      enrollment: state.continueLearning!,
                      onContinueTap: () {
                        // Navigate to lesson
                      },
                    ),
                    AppSpacing.vGap24,
                  ],

                  // Today's schedule
                  SectionHeader(
                    title: 'Lich hoc hom nay',
                    icon: Icons.calendar_today,
                    actionLabel: 'Xem tat ca',
                    onActionTap: () {
                      // Navigate to schedule
                    },
                  ),
                  AppSpacing.vGap12,
                  ScheduleTimeline(
                    items: state.scheduleItems.map((item) {
                      return ScheduleTimelineItemData(
                        time: '${item.startTime.hour}:${item.startTime.minute.toString().padLeft(2, '0')} - ${item.endTime.hour}:${item.endTime.minute.toString().padLeft(2, '0')}',
                        title: item.title,
                        subtitle: '${item.type} • ${item.instructorName ?? ""}',
                        type: _mapScheduleType(item.type),
                        isActive: _isCurrentOrNext(item),
                      );
                    }).toList(),
                  ),
                  AppSpacing.vGap24,

                  // Assignments
                  SectionHeader(
                    title: 'Bai tap can hoan thanh',
                    icon: Icons.assignment,
                    actionLabel: 'Xem tat ca',
                    onActionTap: () {
                      // Navigate to assignments
                    },
                  ),
                  AppSpacing.vGap12,
                  AssignmentList(
                    assignments: state.assignments,
                    onItemTap: (assignment) {
                      // Navigate to assignment
                    },
                  ),
                  AppSpacing.vGap32,
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  ScheduleItemType _mapScheduleType(String type) {
    switch (type.toLowerCase()) {
      case 'livestream':
        return ScheduleItemType.livestream;
      case 'quiz':
        return ScheduleItemType.quiz;
      case 'deadline':
        return ScheduleItemType.deadline;
      default:
        return ScheduleItemType.video;
    }
  }

  bool _isCurrentOrNext(dynamic item) {
    final now = DateTime.now();
    return item.startTime.isAfter(now) ||
           (item.startTime.isBefore(now) && item.endTime.isAfter(now));
  }
}
```

- [ ] **Step 6: Update student shell to use home screen**

```dart
// In lib/features/student/presentation/student_shell.dart
// Update _buildBody() method:

Widget _buildBody() {
  switch (_currentTab) {
    case StudentTab.home:
      return const HomeScreen();
    case StudentTab.learning:
      return const Center(child: Text('Learning'));
    case StudentTab.schedule:
      return const Center(child: Text('Schedule'));
    case StudentTab.achievement:
      return const Center(child: Text('Achievement'));
    case StudentTab.profile:
      return const Center(child: Text('Profile'));
  }
}
```

Add import at top:
```dart
import 'package:study/features/student/presentation/home/home_screen.dart';
```

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/features/student/presentation/home/home_screen_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/features/student/presentation/home/
git commit -m "feat(student): add home screen with continue learning, schedule, and assignments"
```

---

### Task 9: Learning Bloc

**Files:**
- Create: `lib/features/student/bloc/learning/learning_event.dart`
- Create: `lib/features/student/bloc/learning/learning_state.dart`
- Create: `lib/features/student/bloc/learning/learning_bloc.dart`
- Test: `test/features/student/bloc/learning/learning_bloc_test.dart`

**Interfaces:**
- Consumes: `StudentRepository`
- Produces: `LearningBloc` with filtered enrollments by status

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/bloc/learning/learning_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

@GenerateMocks([StudentRepository])
import 'learning_bloc_test.mocks.dart';

void main() {
  group('LearningBloc', () {
    late MockStudentRepository mockRepository;
    late LearningBloc bloc;

    setUp(() {
      mockRepository = MockStudentRepository();
      bloc = LearningBloc(mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be LearningInitial', () {
      expect(bloc.state, isA<LearningInitial>());
    });

    blocTest<LearningBloc, LearningState>(
      'emits [LearningLoading, LearningSuccess] when LearningLoaded is added',
      build: () {
        when(mockRepository.getActiveEnrollments())
            .thenAnswer((_) async => Result.success([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LearningLoaded()),
      expect: () => [
        isA<LearningLoading>(),
        isA<LearningSuccess>(),
      ],
    );

    blocTest<LearningBloc, LearningState>(
      'filters enrollments when LearningFilterChanged is added',
      build: () {
        when(mockRepository.getActiveEnrollments())
            .thenAnswer((_) async => Result.success([]));
        return bloc;
      },
      seed: () => const LearningSuccess(enrollments: [], filter: EnrollmentFilter.inProgress),
      act: (bloc) => bloc.add(const LearningFilterChanged(EnrollmentFilter.completed)),
      expect: () => [
        isA<LearningSuccess>(),
      ],
      verify: (bloc) {
        expect((bloc.state as LearningSuccess).filter, EnrollmentFilter.completed);
      },
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/bloc/learning/learning_bloc_test.dart`
Expected: FAIL

- [ ] **Step 3: Write learning events**

```dart
// lib/features/student/bloc/learning/learning_event.dart
import 'package:equatable/equatable.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';

abstract class LearningEvent extends Equatable {
  const LearningEvent();

  @override
  List<Object?> get props => [];
}

class LearningLoaded extends LearningEvent {
  const LearningLoaded();
}

class LearningRefreshed extends LearningEvent {
  const LearningRefreshed();
}

class LearningFilterChanged extends LearningEvent {
  const LearningFilterChanged(this.filter);

  final EnrollmentFilter filter;

  @override
  List<Object?> get props => [filter];
}

class LearningSearchChanged extends LearningEvent {
  const LearningSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
```

- [ ] **Step 4: Write learning state**

```dart
// lib/features/student/bloc/learning/learning_state.dart
import 'package:equatable/equatable.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';

enum EnrollmentFilter { inProgress, completed, upcoming }

abstract class LearningState extends Equatable {
  const LearningState();

  @override
  List<Object?> get props => [];
}

class LearningInitial extends LearningState {
  const LearningInitial();
}

class LearningLoading extends LearningState {
  const LearningLoading();
}

class LearningSuccess extends LearningState {
  const LearningSuccess({
    this.enrollments = const [],
    this.filter = EnrollmentFilter.inProgress,
    this.searchQuery = '',
  });

  final List<EnrollmentModel> enrollments;
  final EnrollmentFilter filter;
  final String searchQuery;

  List<EnrollmentModel> get filteredEnrollments {
    var result = enrollments.where((e) {
      switch (filter) {
        case EnrollmentFilter.inProgress:
          return e.status == 'active' && (e.progressPercentage) < 100;
        case EnrollmentFilter.completed:
          return e.completedAt != null || (e.progressPercentage) >= 100;
        case EnrollmentFilter.upcoming:
          return e.status == 'pending';
      }
    }).toList();

    if (searchQuery.isNotEmpty) {
      result = result.where((e) {
        final title = e.course?.title?.toLowerCase() ?? '';
        return title.contains(searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  @override
  List<Object?> get props => [enrollments, filter, searchQuery];

  LearningSuccess copyWith({
    List<EnrollmentModel>? enrollments,
    EnrollmentFilter? filter,
    String? searchQuery,
  }) {
    return LearningSuccess(
      enrollments: enrollments ?? this.enrollments,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class LearningFailure extends LearningState {
  const LearningFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 5: Write learning bloc**

```dart
// lib/features/student/bloc/learning/learning_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/repository/student_repository.dart';

class LearningBloc extends Bloc<LearningEvent, LearningState> {
  LearningBloc(this._repository) : super(const LearningInitial()) {
    on<LearningLoaded>(_onLoaded);
    on<LearningRefreshed>(_onRefreshed);
    on<LearningFilterChanged>(_onFilterChanged);
    on<LearningSearchChanged>(_onSearchChanged);
  }

  final StudentRepository _repository;

  Future<void> _onLoaded(LearningLoaded event, Emitter<LearningState> emit) async {
    emit(const LearningLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(LearningRefreshed event, Emitter<LearningState> emit) async {
    final currentState = state;
    await _loadData(emit, preserveFilter: currentState is LearningSuccess ? currentState : null);
  }

  Future<void> _loadData(Emitter<LearningState> emit, {LearningSuccess? preserveFilter}) async {
    final result = await _repository.getActiveEnrollments();

    if (result.isFailure) {
      emit(LearningFailure(result.failure?.message ?? 'Unknown error'));
      return;
    }

    emit(LearningSuccess(
      enrollments: result.data ?? [],
      filter: preserveFilter?.filter ?? EnrollmentFilter.inProgress,
      searchQuery: preserveFilter?.searchQuery ?? '',
    ));
  }

  void _onFilterChanged(LearningFilterChanged event, Emitter<LearningState> emit) {
    final currentState = state;
    if (currentState is LearningSuccess) {
      emit(currentState.copyWith(filter: event.filter));
    }
  }

  void _onSearchChanged(LearningSearchChanged event, Emitter<LearningState> emit) {
    final currentState = state;
    if (currentState is LearningSuccess) {
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/student/bloc/learning/learning_bloc_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/features/student/bloc/learning/
git commit -m "feat(student): add learning bloc with filters"
```

---

### Task 10: Learning Screen UI

**Files:**
- Create: `lib/features/student/presentation/learning/widgets/course_card.dart`
- Create: `lib/features/student/presentation/learning/widgets/course_filter_chips.dart`
- Create: `lib/features/student/presentation/learning/learning_screen.dart`
- Modify: `lib/features/student/presentation/student_shell.dart`
- Test: `test/features/student/presentation/learning/learning_screen_test.dart`

**Interfaces:**
- Consumes: `LearningBloc`
- Produces: `LearningScreen` widget with course list and filters

- [ ] **Step 1: Write the failing test**

```dart
// test/features/student/presentation/learning/learning_screen_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/learning_screen.dart';

class MockLearningBloc extends MockBloc<LearningEvent, LearningState> implements LearningBloc {}

void main() {
  group('LearningScreen', () {
    late MockLearningBloc mockBloc;

    setUp(() {
      mockBloc = MockLearningBloc();
    });

    testWidgets('should show filter chips', (tester) async {
      whenListen(
        mockBloc,
        Stream.value(const LearningSuccess()),
        initialState: const LearningSuccess(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<LearningBloc>.value(
            value: mockBloc,
            child: const LearningScreen(),
          ),
        ),
      );

      expect(find.text('Dang hoc'), findsOneWidget);
      expect(find.text('Hoan thanh'), findsOneWidget);
      expect(find.text('Cho khai giang'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/student/presentation/learning/learning_screen_test.dart`
Expected: FAIL

- [ ] **Step 3: Write course card**

```dart
// lib/features/student/presentation/learning/widgets/course_card.dart
import 'package:flutter/material.dart';
import 'package:study/features/course/data/models/enrollment_model.dart';
import 'package:study/theme/app_spacing.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.enrollment,
    this.onTap,
  });

  final EnrollmentModel enrollment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final course = enrollment.course;
    final progress = (enrollment.progressPercentage / 100).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  image: course?.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(course!.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: course?.thumbnailUrl == null
                    ? Icon(Icons.school, color: cs.primary, size: 32)
                    : null,
              ),
              AppSpacing.hGap16,
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course?.title ?? 'Khoa hoc',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGap4,
                    Text(
                      '${enrollment.completedLessons}/${enrollment.totalLessons} bai • ${enrollment.progressPercentage.toStringAsFixed(0)}%',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    AppSpacing.vGap8,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: cs.surfaceContainerHighest,
                        color: cs.primary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hGap8,
              Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Write filter chips**

```dart
// lib/features/student/presentation/learning/widgets/course_filter_chips.dart
import 'package:flutter/material.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/theme/app_spacing.dart';

class CourseFilterChips extends StatelessWidget {
  const CourseFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final EnrollmentFilter selectedFilter;
  final ValueChanged<EnrollmentFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          _FilterChip(
            label: 'Dang hoc',
            isSelected: selectedFilter == EnrollmentFilter.inProgress,
            onTap: () => onFilterChanged(EnrollmentFilter.inProgress),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Hoan thanh',
            isSelected: selectedFilter == EnrollmentFilter.completed,
            onTap: () => onFilterChanged(EnrollmentFilter.completed),
          ),
          AppSpacing.hGap8,
          _FilterChip(
            label: 'Cho khai giang',
            isSelected: selectedFilter == EnrollmentFilter.upcoming,
            onTap: () => onFilterChanged(EnrollmentFilter.upcoming),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: isSelected ? cs.onPrimary : cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Write learning screen**

```dart
// lib/features/student/presentation/learning/learning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_bloc.dart';
import 'package:study/features/student/bloc/learning/learning_event.dart';
import 'package:study/features/student/bloc/learning/learning_state.dart';
import 'package:study/features/student/presentation/learning/widgets/course_card.dart';
import 'package:study/features/student/presentation/learning/widgets/course_filter_chips.dart';
import 'package:study/theme/app_spacing.dart';
import 'package:study/widgets/empty_state.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<LearningBloc>().add(const LearningLoaded());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoc tap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<LearningBloc, LearningState>(
        builder: (context, state) {
          if (state is LearningLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LearningFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  AppSpacing.vGap16,
                  Text(state.message),
                  AppSpacing.vGap16,
                  FilledButton(
                    onPressed: () {
                      context.read<LearningBloc>().add(const LearningLoaded());
                    },
                    child: const Text('Thu lai'),
                  ),
                ],
              ),
            );
          }

          if (state is LearningSuccess) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LearningBloc>().add(const LearningRefreshed());
              },
              child: CustomScrollView(
                slivers: [
                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tim kiem khoa hoc...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                        ),
                        onChanged: (query) {
                          context.read<LearningBloc>().add(LearningSearchChanged(query));
                        },
                      ),
                    ),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: CourseFilterChips(
                      selectedFilter: state.filter,
                      onFilterChanged: (filter) {
                        context.read<LearningBloc>().add(LearningFilterChanged(filter));
                      },
                    ),
                  ),

                  SliverToBoxAdapter(child: AppSpacing.vGap16),

                  // Course list
                  if (state.filteredEnrollments.isEmpty)
                    SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.school_outlined,
                        title: 'Chua co khoa hoc nao',
                        description: 'Bat dau hoc khoa hoc dau tien cua ban',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final enrollment = state.filteredEnrollments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: CourseCard(
                                enrollment: enrollment,
                                onTap: () {
                                  // Navigate to course detail
                                },
                              ),
                            );
                          },
                          childCount: state.filteredEnrollments.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

- [ ] **Step 6: Update student shell**

```dart
// In lib/features/student/presentation/student_shell.dart
// Add import:
import 'package:study/features/student/presentation/learning/learning_screen.dart';

// Update _buildBody():
Widget _buildBody() {
  switch (_currentTab) {
    case StudentTab.home:
      return const HomeScreen();
    case StudentTab.learning:
      return const LearningScreen();
    case StudentTab.schedule:
      return const Center(child: Text('Schedule'));
    case StudentTab.achievement:
      return const Center(child: Text('Achievement'));
    case StudentTab.profile:
      return const Center(child: Text('Profile'));
  }
}
```

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/features/student/presentation/learning/learning_screen_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/features/student/presentation/learning/
git commit -m "feat(student): add learning screen with course list and filters"
```

---

## Summary

**Tasks completed in Phase 1:**
1. Student Shell - Bottom Navigation
2. App Drawer Component
3. Schedule Timeline Components
4. Student Data Models
5. Student API Client
6. Student Repository
7. Home Bloc
8. Home Screen UI
9. Learning Bloc
10. Learning Screen UI

**Next phases:**
- Phase 2: Course Detail + Lesson Detail screens
- Phase 3: Schedule Tab (Calendar view)
- Phase 4: Achievement Tab
- Phase 5: Profile Tab
- Phase 6: Additional screens (Notifications, Search, Bookmarks)
