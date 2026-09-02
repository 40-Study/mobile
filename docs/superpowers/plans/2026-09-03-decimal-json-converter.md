# Decimal JSON Converter Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix JSON parsing error khi backend trả `decimal.Decimal` dưới dạng String thay vì num

**Architecture:** Tạo JsonConverter classes để handle cả String và num từ API. Apply converter vào các model fields bị ảnh hưởng.

**Tech Stack:** Flutter, Freezed, json_annotation

**Spec:** Backend dùng `github.com/shopspring/decimal` serialize thành String (e.g., `"65.5"` thay vì `65.5`)

## Global Constraints

- Không thay đổi backend
- Sử dụng `@JsonKey` và custom `JsonConverter`
- Chạy `dart run build_runner build --delete-conflicting-outputs` sau mỗi thay đổi model
- Test bằng cách chạy app và verify HomeBloc load thành công

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `lib/core/utils/json_converters.dart` | Chứa các JsonConverter cho String/num |
| Modify | `lib/features/course/data/models/course_model.dart` | Apply converter cho price, discount_price, average_rating |
| Modify | `lib/features/course/data/models/enrollment_model.dart` | Apply converter cho progress_percentage |
| Modify | `lib/features/student/data/models/student_stats_model.dart` | Apply converter cho totalQuizScore, totalStudyHours |

---

### Task 1: Tạo JSON Converters

**Files:**
- Create: `lib/core/utils/json_converters.dart`

**Interfaces:**
- Produces: `StringToDoubleConverter`, `StringToNullableDoubleConverter`, `StringToIntConverter`

- [ ] **Step 1: Tạo file json_converters.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

/// Handle decimal.Decimal từ backend (serialize thành String)
class StringToDoubleConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleConverter();

  @override
  double fromJson(dynamic json) {
    if (json == null) return 0;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0;
    return 0;
  }

  @override
  dynamic toJson(double object) => object;
}

class StringToNullableDoubleConverter implements JsonConverter<double?, dynamic> {
  const StringToNullableDoubleConverter();

  @override
  double? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is num) return json.toDouble();
    if (json is String) return double.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(double? object) => object;
}

class StringToIntConverter implements JsonConverter<int, dynamic> {
  const StringToIntConverter();

  @override
  int fromJson(dynamic json) {
    if (json == null) return 0;
    if (json is num) return json.toInt();
    if (json is String) return int.tryParse(json) ?? 0;
    return 0;
  }

  @override
  dynamic toJson(int object) => object;
}
```

- [ ] **Step 2: Verify file được tạo**

Run: `cat lib/core/utils/json_converters.dart`

---

### Task 2: Apply Converter vào CourseModel

**Files:**
- Modify: `lib/features/course/data/models/course_model.dart`

**Interfaces:**
- Consumes: `StringToDoubleConverter`, `StringToNullableDoubleConverter` từ Task 1
- Produces: CourseModel parse được cả String và num cho price, discountPrice, averageRating

- [ ] **Step 1: Thêm import**

Thêm vào đầu file:
```dart
import 'package:study/core/utils/json_converters.dart';
```

- [ ] **Step 2: Apply converter cho CourseModel fields**

Thay đổi các fields sau trong `CourseModel`:
```dart
@StringToDoubleConverter() @Default(0) double price,
@StringToNullableDoubleConverter() @JsonKey(name: 'discount_price') double? discountPrice,
@StringToDoubleConverter() @JsonKey(name: 'average_rating') @Default(0) double averageRating,
@StringToNullableDoubleConverter() @JsonKey(name: 'enrollment_progress') double? enrollmentProgress,
```

- [ ] **Step 3: Apply converter cho LessonProgressModel**

Trong cùng file, thay đổi `LessonProgressModel`:
```dart
@StringToDoubleConverter() @JsonKey(name: 'progress_percentage') @Default(0) double progressPercentage,
```

- [ ] **Step 4: Regenerate code**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Verify no compile errors**

Run: `dart analyze lib/features/course/data/models/course_model.dart`

---

### Task 3: Apply Converter vào EnrollmentModel

**Files:**
- Modify: `lib/features/course/data/models/enrollment_model.dart`

**Interfaces:**
- Consumes: `StringToDoubleConverter` từ Task 1
- Produces: EnrollmentModel parse được String cho progress_percentage

- [ ] **Step 1: Thêm import**

```dart
import 'package:study/core/utils/json_converters.dart';
```

- [ ] **Step 2: Apply converter cho progressPercentage**

```dart
@StringToDoubleConverter() @JsonKey(name: 'progress_percentage') @Default(0) double progressPercentage,
```

- [ ] **Step 3: Regenerate và verify**

Run: `dart run build_runner build --delete-conflicting-outputs`

---

### Task 4: Apply Converter vào StudentStatsModel

**Files:**
- Modify: `lib/features/student/data/models/student_stats_model.dart`

**Interfaces:**
- Consumes: `StringToDoubleConverter`, `StringToIntConverter` từ Task 1
- Produces: StudentStatsModel parse được String cho các numeric fields

- [ ] **Step 1: Thêm import**

```dart
import 'package:study/core/utils/json_converters.dart';
```

- [ ] **Step 2: Apply converter cho các fields**

```dart
@StringToIntConverter() @Default(0) int level,
@StringToIntConverter() @JsonKey(name: 'current_xp') @Default(0) int currentXp,
@StringToIntConverter() @JsonKey(name: 'next_level_xp') @Default(100) int nextLevelXp,
@StringToIntConverter() @JsonKey(name: 'streak_days') @Default(0) int streakDays,
@StringToIntConverter() @JsonKey(name: 'total_courses') @Default(0) int totalCourses,
@StringToIntConverter() @JsonKey(name: 'completed_courses') @Default(0) int completedCourses,
@StringToIntConverter() @JsonKey(name: 'total_lessons') @Default(0) int totalLessons,
@StringToIntConverter() @JsonKey(name: 'completed_lessons') @Default(0) int completedLessons,
@StringToDoubleConverter() @JsonKey(name: 'total_quiz_score') @Default(0) double totalQuizScore,
@StringToDoubleConverter() @JsonKey(name: 'total_study_hours') @Default(0) double totalStudyHours,
```

- [ ] **Step 3: Regenerate và verify**

Run: `dart run build_runner build --delete-conflicting-outputs`

---

### Task 5: Test Integration

**Files:**
- None (manual testing)

- [ ] **Step 1: Chạy app**

Run: `flutter run`

- [ ] **Step 2: Verify HomeBloc load thành công**

Xem console log, expect:
```
HomeBloc with event HomeStarted
CURRENT state: HomeInProgress()
NEXT state: HomeSuccess(...)
```

Không còn error: `type 'String' is not a subtype of type 'num?'`

- [ ] **Step 3: Commit changes**

```bash
git add lib/core/utils/json_converters.dart \
        lib/features/course/data/models/course_model.dart \
        lib/features/course/data/models/enrollment_model.dart \
        lib/features/student/data/models/student_stats_model.dart \
        lib/features/course/data/models/*.g.dart \
        lib/features/student/data/models/*.g.dart
git commit -m "fix: add JsonConverters to handle decimal.Decimal from backend"
```

---

## Lưu ý bảo trì

Khi thêm model mới có numeric fields từ backend decimal.Decimal:
1. Import `json_converters.dart`
2. Apply `@StringToDoubleConverter()` hoặc `@StringToIntConverter()` cho field
3. Regenerate code

Backend fields dùng `decimal.Decimal`:
- `price`, `discount_price`, `average_rating` (courses)
- `progress_percentage` (enrollments, lessons)
- `points`, `score`, `percentage` (quizzes)
- `amount`, `subtotal`, `total_amount` (orders)
