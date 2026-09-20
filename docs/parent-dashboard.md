# Parent Dashboard - Tài liệu kỹ thuật

## Tổng quan

Màn hình dashboard cho phụ huynh theo dõi tiến độ học tập của con.

## UI Components

| Component | Mô tả | Data source |
|-----------|-------|-------------|
| Greeting | "Xin chào, anh X 👋" | `parentName` prop |
| Child Card | Avatar, tên, lớp con đang chọn | `ChildModel` |
| Next Lesson | Buổi học tiếp theo + countdown | `ChildScheduleModel` ✅ |
| Progress Card | Tiến độ khoá học (%) | `ChildCourseModel` ✅ |
| Attendance Card | Tỷ lệ điểm danh (%) | `ChildOverviewModel.attendanceRate` |
| Tuition Card | Học phí chưa thanh toán | **Chưa có API** |
| Suggestion Card | Gợi ý khoá học | **Chưa có API** |

## APIs hiện có

### 1. GET /api/parent/children/{id}/overview
Lấy thông tin tổng quan của 1 con.

**Response:**
```json
{
  "data": {
    "childId": "uuid",
    "progressPercent": 72.0,
    "avgQuizScore": 85.0,
    "studyHoursWeek": 10.5,
    "attendanceRate": 86.0,
    "totalCourses": 2
  }
}
```

### 2. GET /api/parent/alerts
Lấy danh sách cảnh báo.

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "childId": "uuid",
      "childName": "Nguyễn Minh Anh",
      "message": "Chưa hoàn thành bài tập",
      "severity": "warning",
      "createdAt": "2024-09-17T10:00:00Z"
    }
  ]
}
```

### 3. GET /api/parent/children/{id}/schedule ✅
Lấy lịch học của con.

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Bài 10: Vòng lặp for",
      "startTime": "2024-09-17T18:00:00Z",
      "endTime": "2024-09-17T19:30:00Z",
      "courseId": "uuid",
      "courseName": "Python cơ bản",
      "instructorName": "Nguyễn Văn A",
      "type": "video"
    }
  ]
}
```

### 4. GET /api/parent/children/{id}/courses ✅
Lấy danh sách khóa học của con.

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Python cơ bản",
      "imageUrl": "https://...",
      "instructorName": "Nguyễn Văn A",
      "totalLessons": 25,
      "completedLessons": 18,
      "progressPercent": 72.0
    }
  ]
}
```

### 5. GET /api/parent/children/{id}/assignments ✅
Lấy danh sách bài tập của con.

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "title": "Bài tập: Vòng lặp while",
      "courseName": "Python cơ bản",
      "dueDate": "2024-09-20T23:59:59Z",
      "status": "pending",
      "score": null
    }
  ]
}
```

## APIs cần bổ sung

### 1. GET /api/me/children ⚠️ THIẾU
Lấy danh sách con của phụ huynh đang đăng nhập.

**Expected Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "fullName": "Nguyễn Minh Anh",
      "avatarUrl": "https://...",
      "className": "Lớp 7",
      "age": 12,
      "enrolledCourses": 2,
      "progressPercent": 72.0
    }
  ]
}
```

**Workaround hiện tại:** Mock hardcode 2 children IDs trong `ParentRepositoryMock`.

---

### 2. GET /api/parent/children/{id}/tuition ⚠️ THIẾU
Lấy thông tin học phí của con.

**Expected Response:**
```json
{
  "data": {
    "totalAmount": 3600000,
    "paidAmount": 3000000,
    "remainingAmount": 600000,
    "dueDate": "2024-09-30",
    "courses": [
      {
        "courseId": "uuid",
        "courseName": "Python cơ bản",
        "amount": 600000,
        "status": "unpaid"
      }
    ]
  }
}
```

**Workaround hiện tại:** Hardcode 600.000đ trong `_TuitionCard`.

---

### 3. GET /api/parent/children/{id}/suggestions ⚠️ THIẾU
Lấy gợi ý khoá học cho con (có thể dựa trên khoá đang học).

**Expected Response:**
```json
{
  "data": [
    {
      "courseId": "uuid",
      "courseName": "Python nâng cao",
      "description": "Tiếp nối Python cơ bản...",
      "totalLessons": 24,
      "price": 3600000,
      "matchScore": 95,
      "reason": "Phù hợp nhất"
    }
  ]
}
```

**Workaround hiện tại:** Hardcode trong `_SuggestionCard`.

---

## Data Models

### ChildModel
```dart
class ChildModel {
  String id;
  String fullName;
  String? avatarUrl;
  String? className;
  int enrolledCourses;
  double progressPercent;
}
```

### ChildOverviewModel
```dart
class ChildOverviewModel {
  String childId;
  double progressPercent;
  double avgQuizScore;
  double studyHoursWeek;
  double attendanceRate;
  int totalCourses;
}
```

### ChildScheduleModel ✅
```dart
class ChildScheduleModel {
  String id;
  String title;
  DateTime startTime;
  DateTime endTime;
  String? courseId;
  String? courseName;
  String? instructorName;
  String type; // "video", "live", etc.
}
```

### ChildCourseModel ✅
```dart
class ChildCourseModel {
  String id;
  String title;
  String? imageUrl;
  String? instructorName;
  int totalLessons;
  int completedLessons;
  double progressPercent;
}
```

### ChildAssignmentModel ✅
```dart
class ChildAssignmentModel {
  String id;
  String title;
  String? courseName;
  DateTime? dueDate;
  String status; // "pending", "submitted", "graded"
  double? score;
}
```

### ParentAlertModel
```dart
class ParentAlertModel {
  String id;
  String childId;
  String childName;
  String message;
  AlertSeverity severity; // critical, warning, info
  DateTime createdAt;
}
```

## File Structure

```
lib/features/parent/
├── bloc/
│   ├── child_selector/
│   │   ├── child_selector_cubit.dart
│   │   └── child_selector_state.dart
│   ├── children/
│   │   ├── children_bloc.dart
│   │   ├── children_event.dart
│   │   └── children_state.dart
│   └── dashboard/
│       ├── parent_dashboard_bloc.dart
│       ├── parent_dashboard_event.dart
│       └── parent_dashboard_state.dart
├── data/
│   ├── models/
│   │   ├── child_assignment_model.dart ← NEW
│   │   ├── child_course_model.dart     ← NEW
│   │   ├── child_model.dart
│   │   ├── child_overview_model.dart
│   │   ├── child_schedule_model.dart   ← NEW
│   │   ├── parent_alert_model.dart
│   │   └── models.dart
│   └── parent_api_client.dart
├── presentation/
│   ├── dashboard/
│   │   └── parent_dashboard_screen.dart
│   ├── widgets/
│   │   ├── alert_card.dart
│   │   ├── child_overview_card.dart
│   │   ├── child_switcher.dart
│   │   ├── stat_card.dart
│   │   └── widgets.dart
│   └── parent_shell.dart
└── repository/
    ├── parent_repository.dart
    ├── parent_repository_impl.dart
    └── parent_repository_mock.dart  ← Đang dùng
```

## TODO khi có API

### Đã hoàn thành ✅
- [x] Integrate schedule API → `_NextLessonCard`
- [x] Integrate courses API → `_ProgressCard`
- [x] Tạo `ChildScheduleModel`, `ChildCourseModel`, `ChildAssignmentModel`

### Cần làm
1. [ ] Backend implement `GET /api/me/children`
2. [ ] Đổi DI từ `ParentRepositoryMock` → `ParentRepositoryImpl`
3. [ ] Backend implement `GET /api/parent/children/{id}/tuition`
4. [ ] Tạo `TuitionModel` và update `_TuitionCard`
5. [ ] Backend implement `GET /api/parent/children/{id}/suggestions`
6. [ ] Tạo `CourseSuggestionModel` và update `_SuggestionCard`

## Mock Children IDs (tạm thời)

```dart
// student1@demo.com
'a055e1b3-bbfe-46b1-8e01-df7aac8c2732'

// student2@demo.com
'a0f88b81-94ca-4328-b46a-b61a1a53a9ad'
```
