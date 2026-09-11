# Parent Role UI/UX Design Spec

## Overview

Design for PARENT role in 40Study app - allows parents to monitor their children's learning progress, attendance, schedule, and expenses.

## Requirements Summary

| Aspect | Decision |
|--------|----------|
| Multi-children | Yes, 1 parent can have multiple children |
| Child linking | Via email invitation from student, app shows linked children only |
| Tracking detail | Detailed - class comparison, trend charts, alerts |
| Attendance | Livestream classes only (teacher takes attendance) |
| Notifications | In-app only (push + inbox) |
| Expenses | Track course purchases per child |

## Navigation Structure

```
Parent App Navigation
├── Dashboard (default)
│   ├── Alert cards (missed class, low scores, expiring courses)
│   ├── Children overview cards
│   ├── Quick stats (all children)
│   └── Total expenses this month
│
├── Tien do hoc tap (Progress)
│   ├── [Child Switcher - top bar]
│   ├── Course progress list
│   ├── Quiz/Assignment scores
│   ├── Study time charts
│   └── Class comparison
│
├── Diem danh (Attendance)
│   ├── [Child Switcher]
│   ├── Calendar view
│   └── Attendance history (livestream only)
│
├── Lich hoc (Schedule)
│   ├── [Child Switcher or "All"]
│   ├── Weekly timetable
│   └── Upcoming livestreams
│
├── Chi phi (Expenses)
│   ├── [Child Switcher or "All"]
│   ├── Monthly/yearly totals
│   ├── Course purchase history
│   └── Expiring courses alerts
│
├── Notifications (inbox icon top-right)
│
└── Settings
    ├── Profile
    ├── Notification preferences
    └── App settings
```

## Screen Designs

### Dashboard

- Header: Avatar, greeting, notification bell with badge
- Alert section: Critical (red) and warning (yellow) cards
  - Critical: 2+ missed classes, score < 5
  - Warning: 1 missed class, declining score, expiring course
- Children cards: Avatar, name, class, progress %, course count, tap to navigate
- Monthly stats: Total courses, study hours, attendance %, expenses
- Today's schedule: Upcoming livestreams for all children

### Tien do hoc tap (Progress)

- Child switcher: Horizontal chips at top, persists across detail screens
- Overview stats: Completion %, average quiz score, study hours this week
- Study chart: 7-day bar chart comparing child vs class average
- Course list: Each course shows:
  - Progress bar
  - Quiz average
  - Study hours
  - Comparison with class (+/- %)

### Diem danh (Attendance)

- Child switcher
- Calendar: Month view with attendance markers
  - Filled dot: Present
  - Half dot: Absent
  - Empty: No class scheduled
- Monthly stats: Present count, absent count, attendance rate %
- Recent sessions list: Date, course name, status

### Lich hoc (Schedule)

- Child switcher with "All" option
- View toggle: Today / This week / Month
- Schedule cards:
  - Time slot
  - Course name, session number
  - Child avatar + name
  - Teacher name
  - Livestream indicator

### Chi phi (Expenses)

- Child switcher with "All" option
- Annual total with monthly bar chart
- Per-child breakdown: Amount, course count
- Purchase history:
  - Course name
  - Child
  - Price
  - Purchase date
  - Status (active, expiring soon, expired)

## Child Switcher Component

Shared component used across Progress, Attendance, Schedule, Expenses screens.

```dart
class ChildSwitcher extends StatelessWidget {
  // Horizontal scrollable chips
  // Shows all children from ChildrenBloc
  // Updates ChildSelectorCubit on tap
  // Highlights selected child
}
```

Behavior:
- Selection persists when navigating between screens
- Dashboard card tap auto-selects child and navigates
- "All" option available on Schedule and Expenses screens

## Alert System

### Alert Types

| Level | Color | Triggers |
|-------|-------|----------|
| Critical | Red | 2+ missed livestream, quiz score < 5 |
| Warning | Yellow | 1 missed class, score declining, course expiring in 15 days |
| Info | Blue | New course enrolled, certificate earned |

### Alert Card Actions

- Tap alert navigates to relevant detail screen
- Auto-selects relevant child

## API Endpoints Used

Existing endpoints from backend:

```
GET /me/children                           # List linked children
GET /parent/children/:id/overview          # Child overview stats
GET /parent/children/:id/courses           # Course progress
GET /parent/children/:id/grades            # Quiz/assignment scores
GET /parent/children/:id/schedule          # Weekly schedule
GET /parent/children/:id/timetable         # Timetable
GET /parent/children/:id/attendance        # Attendance records
GET /parent/children/:id/assignments       # Assignment status
```

New endpoints needed:

```
GET /parent/children/:id/expenses          # Course purchases for child
GET /parent/expenses/summary               # Total expenses summary
GET /parent/alerts                         # Aggregated alerts
```

## State Management (BLoC)

### Directory Structure

```
lib/features/parent/
├── data/
│   ├── parent_api_client.dart
│   ├── parent_repository.dart
│   └── models/
│       ├── child_model.dart
│       ├── child_overview_model.dart
│       ├── child_progress_model.dart
│       ├── attendance_model.dart
│       ├── schedule_model.dart
│       └── expense_model.dart
│
├── bloc/
│   ├── children/
│   │   ├── children_bloc.dart
│   │   ├── children_event.dart
│   │   └── children_state.dart
│   ├── child_selector/
│   │   └── child_selector_cubit.dart
│   ├── dashboard/
│   │   ├── parent_dashboard_bloc.dart
│   │   ├── parent_dashboard_event.dart
│   │   └── parent_dashboard_state.dart
│   ├── progress/
│   │   ├── progress_bloc.dart
│   │   ├── progress_event.dart
│   │   └── progress_state.dart
│   ├── attendance/
│   │   ├── attendance_bloc.dart
│   │   ├── attendance_event.dart
│   │   └── attendance_state.dart
│   ├── schedule/
│   │   ├── parent_schedule_bloc.dart
│   │   ├── parent_schedule_event.dart
│   │   └── parent_schedule_state.dart
│   └── expenses/
│       ├── expenses_bloc.dart
│       ├── expenses_event.dart
│       └── expenses_state.dart
│
└── presentation/
    ├── parent_shell.dart
    ├── widgets/
    │   ├── child_switcher.dart
    │   ├── alert_card.dart
    │   ├── child_overview_card.dart
    │   └── stat_card.dart
    ├── dashboard/
    │   ├── parent_dashboard_screen.dart
    │   └── widgets/
    ├── progress/
    │   ├── progress_screen.dart
    │   └── widgets/
    ├── attendance/
    │   ├── attendance_screen.dart
    │   └── widgets/
    ├── schedule/
    │   ├── parent_schedule_screen.dart
    │   └── widgets/
    └── expenses/
        ├── expenses_screen.dart
        └── widgets/
```

### BLoC Patterns

1. `ChildrenBloc` - Loads list of linked children on app start
2. `ChildSelectorCubit` - Tracks currently selected child, shared across screens
3. Detail BLoCs (Progress, Attendance, Schedule, Expenses):
   - Listen to `ChildSelectorCubit` changes
   - Reload data when selected child changes
   - Support loading state, error state, loaded state

### Data Flow

```
ChildrenBloc.load()
    ↓
ChildSelectorCubit.select(firstChild)
    ↓
ProgressBloc / AttendanceBloc / etc listen
    ↓
On selection change → reload respective data
```

## Bottom Navigation

5 tabs:
1. Home (Dashboard)
2. Tien do (Progress)
3. Diem danh (Attendance)
4. Lich hoc (Schedule) - or move to separate section
5. Chi phi (Expenses)

Alternative: 4 tabs + Lich hoc accessible from Dashboard

## Charts Library

Use `fl_chart` package (already in project or add):
- Bar chart: Study time per day, expenses per month
- Line chart: Score trend over time

## Notifications

In-app only:
- Push notifications for alerts
- Inbox screen accessible from header bell icon
- Notification types:
  - Child missed class
  - Child completed course
  - Low quiz score
  - Course expiring soon

## Out of Scope

- Parent cannot enroll child in courses (child does this)
- Parent cannot link/unlink children in app (via email invitation)
- No email/SMS notifications (in-app only)
- No chat with teachers (separate feature)

## Implementation Phases

### Phase 1: Core Structure
- Parent shell with bottom navigation
- Children loading and child switcher
- Dashboard with overview cards

### Phase 2: Progress & Attendance
- Progress screen with charts
- Attendance screen with calendar

### Phase 3: Schedule & Expenses
- Schedule screen
- Expenses screen with purchase history

### Phase 4: Alerts & Notifications
- Alert system
- Push notifications
- Notification inbox
