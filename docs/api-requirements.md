# API Requirements cho Student Feature

## 1. Courses

### GET /api/courses
Lấy danh sách khóa học (public)

Query params: `page`, `page_size`, `category_id`, `level`, `search`, `sort_by`, `is_free`

```json
{
  "data": [
    {
      "id": "course-1",
      "title": "Flutter từ cơ bản đến nâng cao",
      "slug": "flutter-co-ban-nang-cao",
      "description": "Khóa học Flutter...",
      "thumbnail_url": "https://...",
      "instructor_name": "Nguyễn Văn A",
      "level": "beginner",
      "price": 500000,
      "is_free": false,
      "duration_hours": 40,
      "total_lessons": 120
    }
  ],
  "meta": {
    "page": 1,
    "page_size": 20,
    "total": 100
  }
}
```

### GET /api/courses/{id}
Chi tiết khóa học (public view)

**⚠️ SECURITY REQUIREMENT:**

API này cần phân biệt response cho enrolled vs non-enrolled users:

**Non-enrolled users** chỉ được xem:
- Course info (title, description, price, instructor, etc.)
- Section/lesson structure (titles only)
- Preview lessons (`is_preview: true`)

**KHÔNG được trả về:**
- `video_url` của lessons (trừ preview)
- Quiz content/questions
- Full lesson content

**Enrolled users** (qua `/api/enrollments/{id}`) mới được xem full content.

```json
// Non-enrolled response
{
  "data": {
    "id": "course-1",
    "title": "Flutter từ cơ bản",
    "price": 500000,
    "sections": [
      {
        "id": "section-1",
        "title": "Giới thiệu",
        "lessons": [
          {
            "id": "lesson-1",
            "title": "Bài 1: Setup",
            "is_preview": true,
            "video_url": "https://..." // chỉ preview lessons có URL
          },
          {
            "id": "lesson-2",
            "title": "Bài 2: Widgets",
            "is_preview": false,
            "video_url": null // non-preview không có URL
          }
        ]
      }
    ]
  }
}
```

---

## 2. Enrollments

### GET /api/enrollments
Lấy khóa học đã ghi danh

Query params: `status` (active|completed)

```json
{
  "data": [
    {
      "id": "enrollment-1",
      "course_id": "course-1",
      "class_id": "class-1",
      "status": "active",
      "progress_percentage": 65,
      "last_accessed_at": "2024-01-15T10:30:00Z",
      "enrolled_at": "2024-01-01T00:00:00Z",
      "course": {
        "id": "course-1",
        "title": "Flutter từ cơ bản",
        "thumbnail_url": "https://...",
        "instructor_name": "Nguyễn Văn A"
      },
      "pending_assignments": [
        {
          "id": "assignment-1",
          "title": "Bài tập Widget",
          "due_date": "2024-01-20T23:59:59Z"
        }
      ]
    }
  ]
}
```

### GET /api/enrollments/{id}
Chi tiết enrollment

---

## 3. Schedules

### GET /api/classes/{classId}/schedules
Lấy lịch học theo class

Query params: `date` (YYYY-MM-DD)

```json
{
  "data": [
    {
      "id": "schedule-1",
      "title": "Bài 5: State Management",
      "start_time": "2024-01-15T09:00:00Z",
      "end_time": "2024-01-15T10:30:00Z",
      "type": "lesson",
      "lesson_id": "lesson-5",
      "course_id": "course-1",
      "location": "Online"
    }
  ]
}
```

### GET /api/students/me/events
Lấy các ngày có sự kiện (cho calendar)

Query params: `start_date`, `end_date`

```json
{
  "data": [
    { "date": "2024-01-15" },
    { "date": "2024-01-17" },
    { "date": "2024-01-20" }
  ]
}
```

---

## 4. Lessons

### GET /api/lessons/{id}
Chi tiết bài học

```json
{
  "data": {
    "id": "lesson-1",
    "title": "Giới thiệu Flutter",
    "description": "...",
    "video_url": "https://...",
    "duration_minutes": 45,
    "order": 1,
    "section_id": "section-1",
    "resources": [],
    "is_completed": false
  }
}
```

### PUT /api/lessons/{id}/progress
Cập nhật tiến độ

```json
{
  "status": "completed",
  "progress_percentage": 100
}
```

---

## 5. Notifications

### GET /api/notifications
Lấy thông báo

```json
{
  "data": [
    {
      "id": "notif-1",
      "title": "Bài học mới",
      "message": "Bài học mới đã được thêm vào khóa Flutter",
      "type": "course_update",
      "is_read": false,
      "created_at": "2024-01-15T08:00:00Z",
      "data": {
        "course_id": "course-1"
      }
    }
  ]
}
```

### GET /api/notifications/unread-count

```json
{
  "data": {
    "count": 5
  }
}
```

### PUT /api/notifications/{id}/read
Đánh dấu đã đọc

### PUT /api/notifications/read-all
Đánh dấu tất cả đã đọc

---

## 6. Achievements

### GET /api/students/me/achievements
Lấy badges, stats

```json
{
  "data": {
    "badges": [
      {
        "id": "badge-1",
        "name": "Học viên chăm chỉ",
        "description": "Hoàn thành 10 bài học",
        "icon_url": "https://...",
        "category": "learning",
        "is_earned": true,
        "earned_at": "2024-01-10T00:00:00Z"
      }
    ],
    "stats": {
      "level": 5,
      "current_xp": 450,
      "next_level_xp": 500,
      "streak_days": 7,
      "total_courses": 5,
      "completed_courses": 2,
      "total_lessons": 100,
      "completed_lessons": 45,
      "total_quiz_score": 85.5,
      "total_study_hours": 24.5,
      "weekly_study_hours": [30, 45, 60, 50, 80, 90, 40]
    }
  }
}
```

---

## 7. Certificates

### GET /api/certificates
Lấy chứng chỉ của user

```json
{
  "data": [
    {
      "id": "cert-1",
      "course_title": "Flutter từ cơ bản",
      "instructor_name": "Nguyễn Văn A",
      "issue_date": "2024-01-15T00:00:00Z",
      "certificate_number": "CERT-2024-001",
      "certificate_url": "https://..."
    }
  ]
}
```

---

## 8. Quiz

### GET /api/quizzes/{id}/questions
Lấy câu hỏi quiz

```json
{
  "data": [
    {
      "id": "q-1",
      "question": "Widget nào dùng để hiển thị text?",
      "options": ["Container", "Text", "Column", "Row"],
      "correct_answer": 1,
      "explanation": "Text widget dùng để hiển thị văn bản",
      "question_type": "single_choice"
    }
  ]
}
```

---

## 9. Search

### GET /api/courses/search
Tìm kiếm khóa học

Query params: `query`

```json
{
  "data": [
    {
      "id": "course-1",
      "title": "Flutter...",
      "thumbnail_url": "...",
      "instructor_name": "...",
      "level": "beginner",
      "price": 0
    }
  ]
}
```

---

## Chưa có API (đang mock)

| Feature | Mô tả | FE Location |
|---------|-------|-------------|
| Instructor Stats | Stats: course_count, student_count, average_rating | `instructor_detail_screen.dart:252-258` |
| Instructor Bio | Tiểu sử giảng viên | `instructor_detail_screen.dart:277-279` |
| Instructor Skills | Danh sách chuyên môn | `instructor_detail_screen.dart:310-315` |
| Instructor Courses | Danh sách khóa học của giảng viên | `instructor_detail_screen.dart:375-402` |
| Course Reviews | Đánh giá từ học viên | `instructor_detail_screen.dart:448+` |
| Rating Distribution | Phân bố đánh giá 5/4/3/2/1 sao | `instructor_detail_screen.dart:850-854` |
| Lesson Code Exercises | Bài tập code trong lesson (quiz đã có API) | `lesson_detail_screen.dart:362-460` |
| Lesson Attachments | Tài liệu, file đính kèm lesson | `lesson_detail_screen.dart:300-350` |
| Exercise Progress | Tiến độ bài tập (completed/total) | `lesson_detail_screen.dart:372` |
| Quiz Attempt Status | Trạng thái hoàn thành quiz per user | |
| Contribution Grid | Daily learning activity (level 0-4 per day) | |
| Bookmarks | CRUD bookmarks - đang dùng local storage | |
| Weekly Study Hours | Study hours per day trong tuần | |
| In-Progress Certificates | Courses đang học với progress | |
| Badge Progress | Progress toward next badge | |
| Sparkline Data | Trend data cho mỗi stat | |
| Pending Assignments | `pending_assignments` trong enrollment response | `home_screen.dart` - section "Bài tập cần hoàn thành" |

---

## ⚠️ Hardcoded Data trong Frontend

Các giá trị đang hardcode trong code, cần backend trả về:

### 1. `course_detail_screen.dart` - Tab Giảng viên

| Line | Hardcoded Value | Cần field |
|------|-----------------|-----------|
| 729 | `'4.9'` (rating) | `instructor.average_rating` |
| 731 | `'12 khóa học • 15k học viên'` | `instructor.course_count`, `instructor.student_count` |
| 748 | `'12'` (courses) | `instructor.course_count` |
| 750 | `'4.8'` (rating) | `instructor.average_rating` |
| 752 | `'15k'` (students) | `instructor.student_count` |

### 2. `instructor_detail_screen.dart` - Trang giảng viên

| Line | Hardcoded Value | Cần field |
|------|-----------------|-----------|
| 204 | `'UI/UX Design Instructor'` | `instructor.title` |
| 214 | `'Chuyên gia thiết kế...'` | `instructor.short_bio` |
| 252 | `'12'` (courses) | `instructor.course_count` |
| 254 | `'2.4K'` (students) | `instructor.student_count` |
| 256 | `'128'` (lessons) | `instructor.lesson_count` |
| 258 | `'4.9'` (rating) | `instructor.average_rating` |
| 277-279 | Bio dài `'Cô Minh Anh...'` | `instructor.bio` |
| 310-315 | Skills array | `instructor.skills[]` |
| 376 | Course title | API `/instructors/:id/courses` |
| 455 | Review text | API `/instructors/:id/reviews` |
| 827 | `'4.9'` (rating) | `instructor.average_rating` |
| 839 | `'(128 đánh giá)'` | `instructor.total_reviews` |
| 850-854 | Rating breakdown | `instructor.rating_distribution` |

### 3. `learning_screen.dart`

| Line | Hardcoded Value | Cần field |
|------|-----------------|-----------|
| 683 | `'Video'` content type | `lesson.content_type` hoặc detect từ `lesson.type` |

### 4. `home/widgets/continue_learning_card.dart`

| Line | Hardcoded Value | Cần field |
|------|-----------------|-----------|
| 170-173 | `'assets/images/python-course-cover.png'` | Dùng `course.thumbnailUrl` thay vì ảnh cố định |

### 5. `achievement_screen.dart`

| Line | Hardcoded Value | Cần field |
|------|-----------------|-----------|
| 561 | `'18'` (badge count) | FE cần pass `earnedBadges.length` hoặc API trả `total_badges` trong stats |
| 652 | `[0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75]` | Sparkline trend data - cần API `/me/stats/trends` |
| 892 | `[30, 45, 60, 50, 80, 105, 70]` fallback | API cần trả `weekly_study_hours` trong stats response |

### 6. API fields trả 0/null

| Field | Vị trí FE | Note |
|-------|-----------|------|
| `total_duration_mins` | learning_cards.dart:132, course_detail_screen.dart:372,531 | API cần tính tổng duration từ lessons |
| `total_students` | course_detail_screen.dart:319 | Aggregate từ enrollments |
| `average_rating` | course_detail_screen.dart:307,792 | Aggregate từ reviews |

### Fix Priority

1. **High**: `total_duration_mins` - hiển thị "0 phút" gây confuse
2. **High**: Instructor stats trong course detail - user thấy ngay
3. **High**: `ContinueLearningCard` thumbnail - home screen, user thấy đầu tiên
4. **Medium**: Instructor detail screen - chỉ khi click vào
5. **Low**: Content type "Video" - đúng hầu hết trường hợp

---

## API Specs cần thêm

### 1. Instructor Detail (mở rộng)

**GET /api/teachers/:id**

Cần trả thêm stats, bio, skills, courses:

```json
{
  "data": {
    "id": "teacher-1",
    "name": "Nguyễn Văn A",
    "avatar_url": "...",
    "bio": "Giảng viên với 10 năm kinh nghiệm...",
    "skills": ["Flutter", "Dart", "Mobile Development"],
    "stats": {
      "course_count": 3,
      "student_count": 150,
      "lesson_count": 45,
      "average_rating": 4.8,
      "total_reviews": 128
    },
    "courses": [
      {
        "id": "course-1",
        "title": "Flutter cơ bản",
        "thumbnail_url": "...",
        "lesson_count": 12,
        "duration": "6h 40m",
        "progress": 0.65
      }
    ]
  }
}
```

### 2. Course Reviews

**GET /api/courses/:id/reviews**

```json
{
  "data": {
    "summary": {
      "average_rating": 4.8,
      "total_reviews": 128,
      "distribution": {
        "5": 110,
        "4": 14,
        "3": 3,
        "2": 1,
        "1": 0
      }
    },
    "reviews": [
      {
        "id": "review-1",
        "user_name": "Nguyễn Hoàng Nam",
        "user_avatar": "...",
        "rating": 5,
        "content": "Giảng viên giải thích rất dễ hiểu...",
        "created_at": "2024-01-15T10:30:00Z",
        "is_verified": true
      }
    ]
  },
  "meta": { "page": 1, "total": 128 }
}
```

### 3. Lesson Exercises

**GET /api/lessons/:id/exercises**

```json
{
  "data": {
    "progress": {
      "completed": 2,
      "total": 5,
      "percentage": 40
    },
    "code_exercises": [
      {
        "id": "ex-1",
        "title": "In dòng chữ đầu tiên",
        "difficulty": "easy",
        "description": "Viết chương trình in ra...",
        "duration_minutes": 10,
        "points": 10,
        "completion_rate": 80,
        "status": "completed"
      }
    ],
    "quizzes": [
      {
        "id": "quiz-1",
        "title": "Kiểm tra kiến thức",
        "difficulty": "easy",
        "question_count": 5,
        "duration_minutes": 5,
        "points": 10,
        "status": "not_started"
      }
    ],
    "essays": [
      {
        "id": "essay-1",
        "title": "Giải thích ngắn",
        "difficulty": "easy",
        "description": "Giải thích sự khác nhau...",
        "points": 10,
        "status": "not_started"
      }
    ],
    "challenges": [
      {
        "id": "challenge-1",
        "title": "Tính tổng các số",
        "difficulty": "medium",
        "description": "Viết chương trình tính...",
        "duration_minutes": 20,
        "points": 20,
        "is_optional": true
      }
    ]
  }
}
```

### 4. Lesson Attachments

**GET /api/lessons/:id/attachments**

```json
{
  "data": {
    "documents": [
      {
        "id": "doc-1",
        "title": "Slide bài giảng",
        "type": "pdf",
        "size_bytes": 2400000,
        "page_count": 15,
        "url": "..."
      }
    ],
    "resources": [
      {
        "id": "res-1",
        "title": "source_code.zip",
        "type": "zip",
        "size_bytes": 156000,
        "file_count": 5,
        "url": "..."
      }
    ],
    "download_all_url": "..."
  }
}
```

### 5. Weekly Study Hours

**GET /api/students/me/study-hours**

Query params: `start_date`, `end_date`

```json
{
  "data": {
    "weekly_hours": [30, 45, 60, 50, 80, 90, 40],
    "total_hours": 395,
    "average_daily": 56.4
  }
}
```

### 6. Bookmarks CRUD

**GET /api/bookmarks**

```json
{
  "data": [
    {
      "id": "bookmark-1",
      "course_id": "course-1",
      "lesson_id": "lesson-1",
      "created_at": "2024-01-15T10:30:00Z",
      "course": {
        "id": "course-1",
        "title": "Flutter cơ bản",
        "thumbnail_url": "..."
      },
      "lesson": {
        "id": "lesson-1",
        "title": "Giới thiệu Flutter"
      }
    }
  ]
}
```

**POST /api/bookmarks**

```json
{
  "course_id": "course-1",
  "lesson_id": "lesson-1"
}
```

**DELETE /api/bookmarks/:id**

### 7. Badge Progress

**GET /api/students/me/badge-progress**

```json
{
  "data": [
    {
      "badge_id": "badge-1",
      "name": "Học viên chăm chỉ",
      "description": "Hoàn thành 10 bài học",
      "icon_url": "...",
      "current_progress": 7,
      "target": 10,
      "percentage": 70,
      "is_earned": false
    }
  ]
}
```

### 8. Quiz Attempt Status

**GET /api/quizzes/:id/my-attempts**

```json
{
  "data": {
    "total_attempts": 2,
    "best_score": 85,
    "last_attempt_at": "2024-01-15T10:30:00Z",
    "status": "passed",
    "attempts": [
      {
        "id": "attempt-1",
        "score": 85,
        "percentage": 85,
        "is_passed": true,
        "completed_at": "2024-01-15T10:30:00Z"
      }
    ]
  }
}
```

### 9. Contribution Grid (Activity Heatmap)

**GET /api/students/me/contributions**

Query params: `year` (default: current year)

```json
{
  "data": [
    {
      "date": "2024-01-15",
      "level": 3,
      "count": 5
    },
    {
      "date": "2024-01-16",
      "level": 1,
      "count": 1
    }
  ]
}
```

Level: 0 = no activity, 1-4 = activity intensity

### 10. Stats Sparkline Data

**GET /api/students/me/stats/trends**

Query params: `period` (7d|30d|90d)

```json
{
  "data": {
    "study_hours": [2, 3, 1, 4, 2, 3, 5],
    "lessons_completed": [1, 0, 2, 1, 0, 1, 2],
    "quiz_scores": [80, 85, 90, 75, 88, 92, 85]
  }
}
```

---

## Notes

- Data cho instructor stats có trong DB (aggregate từ courses + enrollments)
- Reviews cần tạo bảng mới hoặc dùng existing feedback system
- Lesson exercises có thể link với existing quizzes + assignments tables
- Attachments có thể dùng existing lesson_attachments table
- Bookmarks hiện dùng local storage, cần migrate sang server
- Contribution grid cần track daily activity (lessons, quizzes, study time)
- Badge progress cần định nghĩa badge criteria trong DB

### Hardcode Issues

- **total_duration_mins**: Backend cần tính `SUM(lessons.duration)` cho mỗi course/section
- **Instructor stats**: Aggregate `COUNT(courses)`, `COUNT(enrollments)`, `AVG(reviews.rating)`
- **Rating distribution**: `GROUP BY rating` từ reviews table
- FE đang show placeholder data, gây misleading cho user

### Missing API Fields

- **pending_assignments**: FE cần API lấy bài tập chưa hoàn thành. Options:
  1. `GET /me/assignments?status=pending` - API riêng cho user's assignments
  2. `GET /assignments?enrolled=true&status=pending` - Filter theo enrolled courses
  3. Thêm `pending_assignments` vào enrollment response (hiện tại FE đang expect field này nhưng API không trả)

- **timetable course/lesson IDs**: `GET /me/timetable` cần trả thêm:
  - `course_id` - để navigate đến course detail
  - `lesson_id` - để navigate đến lesson detail
  - `instructor_name` - hiển thị tên giảng viên
  - FE đã sẵn sàng nhận các field này

- **timetable cho tất cả courses**: Hiện `/me/timetable` chỉ trả schedule từ classes user join. Nhưng enrollment không link đến class → user enroll nhiều course nhưng chỉ thấy lịch 1 course.
  - Option 1: Auto-add user vào class khi enroll course
  - Option 2: Generate timetable từ course lessons (không qua class)
  - Option 3: Thêm `class_id` vào enrollment và link khi enroll

  **Backend Root Cause** (`schedule_repository.go:301-307`):
  ```go
  func GetStudentClassIDs(studentID uuid.UUID) ([]uuid.UUID, error) {
      // Query từ bảng student_classes
      Table("student_classes").Where("student_id = ?", studentID)
  }
  ```
  - Timetable lấy từ `student_classes` table
  - Enrollment lưu ở `enrollments` table
  - 2 bảng KHÔNG liên kết → enroll course không tự động join class

  **Fix suggestions:**
  1. Enrollment service: khi enroll → insert vào `student_classes`
  2. Hoặc modify `GetStudentClassIDs` để JOIN với enrollments:
     ```go
     // Lấy classes từ courses đã enroll
     SELECT c.id FROM classes c
     JOIN courses ON courses.id = c.course_id
     JOIN enrollments e ON e.course_id = courses.id
     WHERE e.user_id = ? AND e.status = 'active'
     ```

---

## 10. Profile Tab - Hardcodes & Missing APIs

### `settings_screen.dart`

| Line | Hardcoded Value | Cần |
|------|-----------------|-----|
| 118 | `'24 MB'` cache size | Tính động từ system |
| 129 | `'1.0.0'` version | Dùng `package_info` hoặc API `/app/version` |

### `security_screen.dart` - Missing l10n

| Line | Hardcoded Value | Cần |
|------|-----------------|-----|
| 642 | `'Không có thông tin'` | `l10n.noInfo` |
| 652 | `'Vừa xong'` | `l10n.justNow` |
| 653 | `'phút trước'` | `l10n.minutesAgo` |
| 654 | `'giờ trước'` | `l10n.hoursAgo` |
| 655 | `'Hôm qua'` | `l10n.yesterday` |
| 656 | `'ngày trước'` | `l10n.daysAgo` |
| 787 | `'Đã liên kết'` / `'Chưa liên kết'` | `l10n.linked` / `l10n.notLinked` |
| 805 | `'Hủy'` / `'Liên kết'` | `l10n.unlink` / `l10n.link` |

### `portfolio_screen.dart` - **Toàn bộ mock data**

| Lines | Mock Data | Cần API |
|-------|-----------|---------|
| 20-33 | Profile info (name, title, location, bio...) | `GET /me/portfolio` |
| 35-40 | Stats (years, projects, certificates) | Portfolio stats |
| 69-94 | Projects array | `GET /me/portfolio/projects` |
| 96-105 | Skills array | `GET /me/portfolio/skills` |
| 107-116 | Experiences array | `GET /me/portfolio/experiences` |

### Cần API mới: Portfolio

**GET /api/me/portfolio**

```json
{
  "data": {
    "profile": {
      "title": "UI/UX Designer",
      "location": "Hà Nội, Việt Nam",
      "website": "example.com",
      "bio": "Mô tả về bản thân...",
      "social_links": [
        { "type": "linkedin", "url": "..." },
        { "type": "github", "url": "..." }
      ]
    },
    "stats": {
      "years_experience": 3,
      "projects_count": 18,
      "certificates_count": 12,
      "followers_count": 120
    },
    "projects": [
      {
        "id": "project-1",
        "title": "EduFlow",
        "subtitle": "Hệ thống quản lý học tập",
        "description": "...",
        "category": "UI/UX DESIGN",
        "tool": "Figma",
        "year": "2024",
        "thumbnail_url": "..."
      }
    ],
    "skills": [
      { "name": "UI Design", "level": 5 },
      { "name": "Figma", "level": 5 }
    ],
    "experiences": [
      {
        "id": "exp-1",
        "position": "Senior UI/UX Designer",
        "company": "Vela Creative Studio",
        "start_date": "2022-03",
        "end_date": null,
        "description": "..."
      }
    ]
  }
}
```

**PUT /api/me/portfolio** - Update portfolio

**POST /api/me/portfolio/projects** - Add project

**DELETE /api/me/portfolio/projects/:id** - Delete project

---

## 11. Parent Feature - Session Detail (Chi tiết ca học)

### 11.1. Bối cảnh & Mục tiêu nghiệp vụ
Màn hình **Chi tiết ca học của con dành cho Phụ huynh** (`ParentSessionDetailScreen`) yêu cầu hiển thị không gian thông tin chuyên sâu theo chuẩn *Locked Child Context* (không có Child Selector, có nút Back bảo toàn state, phụ huynh chỉ giám sát/đồng hành, tuyệt đối không có nút Vào học Meet).

Các nhóm thông tin cần thể hiện trên giao diện:
1. **Thông tin ca học cốt lõi:** Tên môn, lớp học, mã buổi học (`#MAT10-B24`), khung giờ to rõ (`09:00 — 10:00`), ngày học, chủ đề bài học và mô tả tóm tắt.
2. **Hình thức & Địa điểm:** Phân biệt rõ ràng giữa Online (`Google Meet`) và Trực tiếp tại cơ sở (`Phòng 401, Cơ sở Phan Xích Long`). Phụ huynh chỉ xem để phối hợp đưa đón hoặc nhắc nhở con.
3. **Giáo viên phụ trách:** Tên, học vị/chuyên môn (VD: `ThS. Toán`), trường công tác (`THPT Chuyên Hà Nội - Amsterdam`), kèm nút liên hệ/nhắn tin nhanh.
4. **Trạng thái điểm danh tức thời:** Chưa mở điểm danh, Đã vào lớp lúc HH:mm, Có mặt, Đi muộn (X phút), hoặc Vắng mặt.
5. **Tài liệu chuẩn bị trước buổi học:** Danh sách file tài liệu đính kèm (giáo trình, file PDF phiếu bài tập do giáo viên tải lên) kèm dung lượng và link tải an toàn.
6. **Checklist chuẩn bị:** Phân loại rõ ràng giữa (a) Đồ dùng/dụng cụ cần mang theo (máy tính cầm tay, sách bài tập...) và (b) Nhiệm vụ học tập cần hoàn thành trước buổi học (câu hỏi trắc nghiệm khởi động...).
7. **Gợi ý đồng hành cùng con (Parent Guidance):** Lời khuyên thiết thực từ giáo viên/hệ thống giúp phụ huynh biết cách hỗ trợ con tốt nhất trước buổi học.
8. **Thông tin dời lịch / Hủy lịch (Rescheduled / Cancelled):** Banner cảnh báo kèm lý do cụ thể từ trung tâm/giáo viên.

---

### 11.2. Đánh giá hiện trạng Backend API
Hiện tại, backend cung cấp endpoint:
`GET /parent/children/:id/schedule`
trả về danh sách `upcoming_sessions` kiểu `ChildUpcomingSessionDto`:
```go
type ChildUpcomingSessionDto struct {
	ID            string    `json:"id"`
	ClassID       string    `json:"class_id"`
	ClassName     string    `json:"class_name"`
	SessionNumber int       `json:"session_number"`
	Topic         string    `json:"topic,omitempty"`
	Date          time.Time `json:"date"`
	StartTime     string    `json:"start_time"`
	EndTime       string    `json:"end_time"`
	Room          string    `json:"room,omitempty"`
}
```

**Nhận xét:**
- Dữ liệu hiện tại chỉ đáp ứng đủ việc hiển thị thẻ tóm tắt trên Lịch học và Trang chủ.
- Còn **thiếu 6 nhóm dữ liệu quan trọng**:
  1. ❌ Chưa có danh sách tài liệu đính kèm (`materials`).
  2. ❌ Chưa có checklist chuẩn bị (`preparation_checklist`).
  3. ❌ Chưa có lời khuyên gợi ý phụ huynh (`parent_guidance`).
  4. ❌ Chưa có thông tin chi tiết giáo viên (học vị, trường công tác, avatar, khả năng nhắn tin).
  5. ❌ Chưa có trạng thái điểm danh tức thời theo ca học (`attendance`).
  6. ❌ Chưa có thông tin lý do khi đổi/hủy lịch (`change_info`).

---

### 11.3. Đề xuất đặc tả Backend API mới

#### Endpoint khuyến nghị
`GET /parent/children/:childId/sessions/:sessionId`

> **Xác thực & Phân quyền:**  
> - Bắt buộc Bearer Token của tài khoản Phụ huynh.  
> - Backend kiểm tra quan hệ `parent_student_relations` để đảm bảo Phụ huynh có quyền xem thông tin của `childId`.

#### 1. DTO Go đề xuất (`backend/internal/dto/parent_session_detail_dto.go`)

```go
package dto

import "time"

// ParentSessionDetailDto - DTO chi tiết buổi học dành cho Phụ huynh
type ParentSessionDetailDto struct {
	ID            string    `json:"id"`             // ID ca học
	ClassID       string    `json:"class_id"`       // ID lớp học
	ClassName     string    `json:"class_name"`     // Tên lớp / môn học (VD: "Toán học (Đại số 10)")
	SessionNumber int       `json:"session_number"` // Thứ tự buổi học (VD: 24)
	SessionCode   string    `json:"session_code"`   // Mã buổi học định danh (VD: "#MAT10-B24")
	Topic         string    `json:"topic"`          // Tên chủ đề bài học
	Description   *string   `json:"description"`    // Mô tả chi tiết chương/bài học
	Date          time.Time `json:"date"`           // Ngày học
	StartTime     string    `json:"start_time"`     // Giờ bắt đầu (HH:MM, VD: "09:00")
	EndTime       string    `json:"end_time"`       // Giờ kết thúc (HH:MM, VD: "10:00")
	Room          string    `json:"room"`           // Phòng học ("P.401, CS Phan Xích Long" hoặc "Google Meet")
	IsOnline      bool      `json:"is_online"`      // true nếu học trực tuyến, false nếu học tại cơ sở
	MeetingURL    *string   `json:"meeting_url,omitempty"` // URL phòng học nếu online (không gửi cho phụ huynh)

	// Trạng thái buổi học: upcoming, in_progress, completed, rescheduled, cancelled
	Status string `json:"status"`

	// Thông tin dời lịch / hủy lịch nếu có
	ChangeInfo *SessionChangeInfoDto `json:"change_info,omitempty"`

	// Thông tin chi tiết giáo viên
	Teacher TeacherDetailDto `json:"teacher"`

	// Trạng thái điểm danh buổi học
	Attendance SessionAttendanceDto `json:"attendance"`

	// Danh sách file tài liệu đính kèm
	Materials []SessionMaterialDto `json:"materials"`

	// Danh sách việc / dụng cụ cần chuẩn bị
	PreparationChecklist []SessionChecklistItemDto `json:"preparation_checklist"`

	// Lời khuyên đồng hành dành cho phụ huynh
	ParentGuidance *string `json:"parent_guidance,omitempty"`

	// Dữ liệu phân tích và kết quả sau khi buổi học kết thúc (chỉ có khi status == completed)
	CompletedAnalysis *SessionCompletedAnalysisDto `json:"completed_analysis,omitempty"`

	// ID bài học để chuyển tiếp sang xem chi tiết bài giảng
	LessonID *string `json:"lesson_id,omitempty"`
}

// SessionCompletedAnalysisDto - Phân tích dữ liệu học tập khi ca học đã kết thúc
type SessionCompletedAnalysisDto struct {
	AttendanceStatus   string   `json:"attendance_status"`              // "present", "late", "absent"
	CheckInTime        *string  `json:"check_in_time,omitempty"`        // "09:02"
	AttendedMinutes    int      `json:"attended_minutes"`               // 58
	TotalMinutes       int      `json:"total_minutes"`                  // 60
	QuizScore          *float64 `json:"quiz_score,omitempty"`           // 9.0
	MaxQuizScore       float64  `json:"max_quiz_score"`                 // 10.0
	QuizCorrectAnswers *int     `json:"quiz_correct_answers,omitempty"` // 9
	QuizTotalQuestions *int     `json:"quiz_total_questions,omitempty"` // 10
	TeacherComment     *string  `json:"teacher_comment,omitempty"`      // Nhận xét của GV
	HomeworkTitle      *string  `json:"homework_title,omitempty"`       // Tên bài tập về nhà
	HomeworkDueDate    *string  `json:"homework_due_date,omitempty"`    // Hạn nộp bài
	HomeworkStatus     *string  `json:"homework_status,omitempty"`      // "not_submitted", "submitted", "graded"
}

// SessionChangeInfoDto - Thông tin khi buổi học bị hủy hoặc dời lịch
type SessionChangeInfoDto struct {
	OriginalDate      *time.Time `json:"original_date,omitempty"`
	RescheduledToDate *time.Time `json:"rescheduled_to_date,omitempty"`
	Reason            string     `json:"reason"` // Lý do đổi lịch từ trung tâm/giáo viên
}

// TeacherDetailDto - Thông tin giáo viên
type TeacherDetailDto struct {
	ID        string  `json:"id"`
	FullName  string  `json:"full_name"`
	Title     *string `json:"title,omitempty"`      // Học vị: "ThS. Toán", "Thầy/Cô"
	School    *string `json:"school,omitempty"`     // Nơi công tác: "THPT Chuyên Hà Nội - Amsterdam"
	AvatarURL *string `json:"avatar_url,omitempty"` // Ảnh đại diện
	CanChat   bool    `json:"can_chat"`             // Cho phép phụ huynh gửi tin nhắn trực tiếp
}

// SessionAttendanceDto - Điểm danh buổi học
type SessionAttendanceDto struct {
	Status      string     `json:"status"` // not_opened, present, late, absent_excused, absent_unexcused
	StatusLabel string     `json:"status_label"` // Label: "Chưa mở điểm danh", "Có mặt", "Vắng mặt"
	CheckInTime *time.Time `json:"check_in_time,omitempty"`
	LateMinutes int        `json:"late_minutes,omitempty"`
	Note        *string    `json:"note,omitempty"` // Ghi chú của giáo viên điểm danh
}

// SessionMaterialDto - File tài liệu học tập
type SessionMaterialDto struct {
	ID          string    `json:"id"`
	FileName    string    `json:"file_name"`    // VD: "Bai_tap_chuyen_de_Parabol_T10.pdf"
	FileSize    string    `json:"file_size"`    // VD: "2.4 MB"
	FileType    string    `json:"file_type"`    // "pdf", "docx", "pptx", "zip"
	DownloadURL string    `json:"download_url"` // Đường dẫn tải file an toàn
	UploadedAt  time.Time `json:"uploaded_at"`  // Thời gian giáo viên tải lên
}

// SessionChecklistItemDto - Mục cần chuẩn bị trước buổi học
type SessionChecklistItemDto struct {
	ID          string  `json:"id"`
	Title       string  `json:"title"`        // VD: "Mang theo máy tính Casio fx-580VNX hoặc tương đương"
	Type        string  `json:"type"`         // "tool" (dụng cụ mang theo) | "task" (nhiệm vụ học tập cần làm)
	IsCompleted bool    `json:"is_completed"` // true nếu học sinh đã hoàn thành trên hệ thống
	ActionHint  *string `json:"action_hint,omitempty"` // Gợi ý phụ huynh cách nhắc nhở con
}
```

#### 2. Response JSON mẫu thành công (`200 OK`)

```json
{
  "message": "success",
  "data": {
    "id": "sess-mat10-b24",
    "class_id": "cls-toan-10a1",
    "class_name": "Toán học (Đại số 10)",
    "session_number": 24,
    "session_code": "#MAT10-B24",
    "topic": "Phương trình bậc hai & Ứng dụng parabol thực tế",
    "description": "Chương trình chuyên sâu Đại số & Giải tích 10",
    "date": "2024-10-24T00:00:00Z",
    "start_time": "09:00",
    "end_time": "10:00",
    "room": "Google Meet",
    "is_online": true,
    "meeting_url": null,
    "status": "upcoming",
    "change_info": null,
    "teacher": {
      "id": "tch-lan-01",
      "full_name": "Cô Lan",
      "title": "ThS. Toán",
      "school": "THPT Chuyên Hà Nội - Amsterdam",
      "avatar_url": "https://cdn.40study.com/teachers/lan.jpg",
      "can_chat": true
    },
    "attendance": {
      "status": "not_opened",
      "status_label": "Chưa mở điểm danh (Mở trước giờ học 10p)",
      "check_in_time": null,
      "late_minutes": 0,
      "note": null
    },
    "materials": [
      {
        "id": "mat-01",
        "file_name": "Bai_tap_chuyen_de_Parabol_T10.pdf",
        "file_size": "2.4 MB",
        "file_type": "pdf",
        "download_url": "https://storage.40study.com/materials/Bai_tap_chuyen_de_Parabol_T10.pdf",
        "uploaded_at": "2024-10-23T15:30:00Z"
      }
    ],
    "preparation_checklist": [
      {
        "id": "chk-01",
        "title": "Mang theo máy tính Casio fx-580VNX hoặc tương đương.",
        "type": "tool",
        "is_completed": false,
        "action_hint": "Nhắc con sạc pin hoặc kiểm tra máy tính trước khi vào bàn học"
      },
      {
        "id": "chk-02",
        "title": "Hoàn thành 5 câu hỏi trắc nghiệm khởi động trên ứng dụng.",
        "type": "task",
        "is_completed": true,
        "action_hint": "Con đã hoàn thành câu hỏi khởi động"
      }
    ],
    "parent_guidance": "Phụ huynh nên nhắc con kiểm tra tai nghe, đường truyền Internet và vào bàn học trước 5–10 phút để bài học đạt kết quả tốt nhất.",
    "lesson_id": "lsn-parabol-10"
  }
}
```

---

### 11.4. Quy tắc hiển thị Empty State trên Mobile khi API chưa trả về dữ liệu

Theo chỉ đạo sản phẩm, **tuyệt đối không bịa fake mock data cho tài khoản thật**. Khi các trường thông tin chưa được backend cung cấp, Mobile sẽ hiển thị trạng thái rỗng tường minh và thẩm mỹ:

| Trường dữ liệu | Giá trị từ API | Quy tắc hiển thị trên giao diện Mobile (`ParentSessionDetailScreen`) |
|---|---|---|
| `materials` | `[]` hoặc `null` | Hiển thị card trạng thái rỗng sạch sẽ: Icon folder mở `Icons.folder_open_outlined` + text: `"Chưa có tài liệu đính kèm cho buổi học này."` |
| `preparation_checklist` | `[]` hoặc `null` | Hiển thị card trạng thái rỗng: Icon checklist `Icons.assignment_outlined` + text: `"Chưa có nhiệm vụ hoặc dụng cụ yêu cầu riêng."` |
| `parent_guidance` | `null` hoặc rỗng `""` | Hiển thị card thông báo nhẹ nhàng: Icon bóng đèn `Icons.lightbulb_outline` + text: `"Chưa có gợi ý đặc biệt từ giáo viên cho buổi học này."` |
| `teacher.title` / `school` | `null` | Chỉ hiển thị tên giáo viên (`Cô Lan`), không tự sinh học vị giả. |
| `attendance` | `null` | Hiển thị trạng thái an toàn: `"Chưa có thông tin điểm danh"` (hoặc tự động tính `"Chưa mở điểm danh"` nếu ca học trong tương lai). |
| `change_info` | `null` | Ẩn hoàn toàn khối cảnh báo dời/hủy lịch. |
| `completed_analysis` | `null` | Hiển thị card trạng thái rỗng cho kết quả buổi học: Nhận xét: "Chưa có đánh giá từ giáo viên cho buổi học này", Bài tập về nhà: "Chưa có bài tập được giao cho buổi học này." |
| `lesson_id` | `null` | Vô hiệu hóa nút CTA `[📖 Xem chi tiết bài học & giáo trình]` kèm SnackBar báo: `"Chưa có thông tin giáo trình chi tiết cho buổi học này."` |

---

## 12. Parent Feature - Family Insights & Encouragement (Phân tích học tập gia đình & Gửi lời khích lệ)

### 12.1. Bối cảnh & Mục tiêu nghiệp vụ
Trong hệ thống Parent Portal, khối **Phân tích học tập** trên trang Home và màn hình chuyên biệt **Family Insights** (`FamilyInsightsInboxScreen`) đóng vai trò:
1. **Thông tin phân tích đa chiều:** Tổng hợp các dấu mốc bứt phá học tập (*Breakthrough*), các điểm kiến thức con đang yếu cần gia đình hỗ trợ (*Attention*), và thói quen rèn luyện kỷ luật / chuỗi chuyên cần (*Reward & Streak*).
2. **Hỗ trợ đa đối tượng (Family Scope):**
   - Chế độ *"Tất cả các con"*: gom và hiển thị dòng thời gian phân tích của toàn bộ các con trong gia đình, phân nhóm rõ ràng theo từng con.
   - Chế độ lọc theo từng con (`child_id`): chỉ hiển thị những phân tích thuộc về con được chọn.
3. **Tương tác 2 chiều (Parent-Child Encouragement Loop):**
   - Khi xem thẻ Khen thưởng / Chuyên cần, phụ huynh có thể bấm `[ 💙 Gửi lời khen & khích lệ con ]`.
   - Hệ thống ghi nhận trạng thái đã khích lệ, đồng thời tạo thông báo (Notification) đẩy về ứng dụng của con, giúp thắt chặt sợi dây đồng hành giữa cha mẹ và con cái.

---

### 12.2. Đánh giá hiện trạng Backend API
Hiện tại, backend đã có các API chi tiết cho từng con:
- `GET /parent/children/:id/overview` (XP, tỷ lệ hoàn thành, chuỗi ngày)
- `GET /parent/children/:id/assignments` (Bài tập đã nộp, đang làm, quá hạn)
- `GET /parent/children/:id/grades` (Bảng điểm các bài kiểm tra)
- `GET /parent/children/:id/sessions/:sessionId/analysis` (Nhận xét buổi học của giáo viên)

**Nhược điểm & Khoảng trống:**
1. ❌ **Chưa có API tổng hợp Insights:** Chưa có endpoint gom các sự kiện phân tích thành dòng thời gian chuẩn hóa để Mobile hiển thị thẻ thông minh.
2. ❌ **Chưa có API gửi lời khích lệ:** Chưa có endpoint tiếp nhận hành động gửi lời khen của phụ huynh và đẩy notification sang tài khoản học sinh.

---

### 12.3. Đặc tả Backend API đề xuất

#### 1. Lấy danh sách phân tích học tập (Family Insights)
- **Endpoint:** `GET /api/parent/insights`
- **Auth Middleware:** Yêu cầu JWT token của Phụ huynh (`user_id`).
- **Query Parameters:**
  - `child_id` *(tùy chọn, string UUID)*: ID của con. Nếu không truyền, backend trả về insights của tất cả các con thuộc phụ huynh này.
  - `page` *(tùy chọn, int, mặc định 1)*
  - `page_size` *(tùy chọn, int, mặc định 20)*

##### Go DTOs đề xuất (`backend/internal/dto/parent_insights_dto.go`):
```go
package dto

import "time"

// FamilyInsightCategory phân loại thẻ phân tích
type FamilyInsightCategory string

const (
	InsightCategoryBreakthrough FamilyInsightCategory = "breakthrough" // Tiến bộ vượt bậc
	InsightCategoryAttention    FamilyInsightCategory = "attention"    // Cần chú ý
	InsightCategoryReward       FamilyInsightCategory = "reward"       // Khen thưởng & Thói quen tự học
)

// InsightMetricDto số liệu định lượng làm bằng chứng
type InsightMetricDto struct {
	Label      string `json:"label"`       // VD: "TỶ LỆ CHÍNH XÁC", "THỜI GIAN ĐỌC"
	Value      string `json:"value"`       // VD: "90%", "14 phút"
	Delta      string `json:"delta,omitempty"` // VD: "+15%", "-3.5m"
	IsPositive bool   `json:"is_positive"` // true = màu xanh tích cực, false = cảnh báo
}

// InsightStreakInfoDto thông tin chuỗi ngày chuyên cần
type InsightStreakInfoDto struct {
	CurrentDays      int      `json:"current_days"`       // VD: 5
	ActiveDayLabels  []string `json:"active_day_labels"`  // VD: ["T2", "T3", "T4", "T5", "T6"]
}

// FamilyInsightItemDto thẻ phân tích chi tiết
type FamilyInsightItemDto struct {
	ID             string                `json:"id"`
	ChildID        string                `json:"child_id"`
	ChildName      string                `json:"child_name"`
	ClassName      string                `json:"class_name"`
	SubjectOrSkill string                `json:"subject_or_skill"`
	Category       FamilyInsightCategory `json:"category"` // breakthrough, attention, reward
	TimeAgoText    string                `json:"time_ago_text"`
	Title          string                `json:"title"`
	Description    string                `json:"description"`
	HighlightText  *string               `json:"highlight_text,omitempty"`
	Metrics        []InsightMetricDto    `json:"metrics"`
	TeacherQuote   *string               `json:"teacher_quote,omitempty"`
	StreakInfo     *InsightStreakInfoDto `json:"streak_info,omitempty"`
	HasEncouraged  bool                  `json:"has_encouraged"`
	ActionLabel    *string               `json:"action_label,omitempty"`
	ActionRoute    *string               `json:"action_route,omitempty"`
	IsRead         bool                  `json:"is_read"`
	CreatedAt      time.Time             `json:"created_at"`
}

// FamilyInsightsResponseDto response trả về danh sách phân tích
type FamilyInsightsResponseDto struct {
	Insights    []FamilyInsightItemDto `json:"insights"`
	Total       int64                  `json:"total"`
	UnreadCount int                    `json:"unread_count"`
	Page        int                    `json:"page"`
	PageSize    int                    `json:"page_size"`
}
```

##### Response Mẫu (200 OK):
```json
{
  "message": "success",
  "data": {
    "insights": [
      {
        "id": "ins-breakthrough-minh-01",
        "child_id": "a055e1b3-bbfe-46b1-8e01-df7aac8c2732",
        "child_name": "Minh",
        "class_name": "10A1",
        "subject_or_skill": "Đọc hiểu Tiếng Anh & Ngữ liệu",
        "category": "breakthrough",
        "time_ago_text": "2 giờ trước",
        "title": "Tiến bộ vượt bậc",
        "description": "Cải thiện rõ rệt ở dạng bài Đọc hiểu so với 3 buổi trước. Em hoàn thành nhanh hơn 20% thời lượng và suy luận chính xác 9/10 câu mức độ vận dụng cao.",
        "highlight_text": "Đọc hiểu",
        "metrics": [
          {
            "label": "TỶ LỆ CHÍNH XÁC",
            "value": "90%",
            "delta": "+15%",
            "is_positive": true
          },
          {
            "label": "THỜI GIAN ĐỌC",
            "value": "14 phút",
            "delta": "-3.5m",
            "is_positive": true
          }
        ],
        "teacher_quote": null,
        "streak_info": null,
        "has_encouraged": false,
        "action_label": "Xem chi tiết bài thi & gợi ý luyện tập →",
        "action_route": "/exam-detail",
        "is_read": false,
        "created_at": "2026-09-29T14:30:00Z"
      },
      {
        "id": "ins-attention-lan-01",
        "child_id": "a0f88b81-94ca-4328-b46a-b61a1a53a9ad",
        "child_name": "Lan",
        "class_name": "7B",
        "subject_or_skill": "Viết luận / Ngữ văn chuyên sâu",
        "category": "attention",
        "time_ago_text": "Hôm qua",
        "title": "Cần chú ý",
        "description": "Kết quả dạng viết luận nghị luận xã hội đang thấp hơn mức kỳ vọng. Lan cần củng cố lại phương pháp phân tách luận điểm và liên kết các đoạn mở - kết để tránh lan man.",
        "highlight_text": "viết luận nghị luận xã hội",
        "metrics": [],
        "teacher_quote": "GV bộ môn đã gửi dàn ý mẫu cho Lan ôn tập cuối tuần. Gia đình nên nhắc bé dành 20 phút viết thử 1 đoạn văn.",
        "streak_info": null,
        "has_encouraged": false,
        "action_label": "Xem lộ trình bổ trợ kỹ năng viết →",
        "action_route": "/curriculum-detail",
        "is_read": false,
        "created_at": "2026-09-28T10:15:00Z"
      },
      {
        "id": "ins-reward-minh-01",
        "child_id": "a055e1b3-bbfe-46b1-8e01-df7aac8c2732",
        "child_name": "Minh",
        "class_name": "10A1",
        "subject_or_skill": "Kỷ luật & Thói quen tự học",
        "category": "reward",
        "time_ago_text": "3 ngày trước",
        "title": "Khen thưởng",
        "description": "Minh đã duy trì xuất sắc chuỗi chuyên cần 5 ngày liên tiếp trên ứng dụng 40Study. Hoàn thành 100% nhiệm vụ bài tập về nhà đúng hạn.",
        "highlight_text": "chuyên cần 5 ngày liên tiếp",
        "metrics": [],
        "teacher_quote": null,
        "streak_info": {
          "current_days": 5,
          "active_day_labels": ["T2", "T3", "T4", "T5", "T6"]
        },
        "has_encouraged": false,
        "action_label": null,
        "action_route": null,
        "is_read": true,
        "created_at": "2026-09-26T08:00:00Z"
      }
    ],
    "total": 3,
    "unread_count": 2,
    "page": 1,
    "page_size": 20
  }
}
```

---

#### 2. Gửi lời khen & khích lệ con (Send Encouragement)
- **Endpoint:** `POST /api/parent/insights/:id/encourage`
- **Auth Middleware:** Yêu cầu JWT token của Phụ huynh (`user_id`).
- **Path Parameter:** `id` (string - ID của thẻ insight cần gửi khích lệ).
- **Request Body (JSON):**
```json
{
  "child_id": "a055e1b3-bbfe-46b1-8e01-df7aac8c2732",
  "message": "Bố mẹ rất tự hào về thành tích tự học chăm chỉ của con!"
}
```

##### Response Mẫu (200 OK):
```json
{
  "message": "success",
  "data": {
    "insight_id": "ins-reward-minh-01",
    "child_id": "a055e1b3-bbfe-46b1-8e01-df7aac8c2732",
    "has_encouraged": true,
    "encouraged_at": "2026-09-29T22:45:00Z"
  }
}
```

##### Quy tắc xử lý nghiệp vụ Backend:
1. **Xác thực quan hệ:** Backend kiểm tra `parent_student_relations` để bảo đảm `parent_id` có quyền tương tác với `child_id`.
2. **Ghi nhận trạng thái:** Đánh dấu đã gửi khích lệ cho insight (lưu vào Redis key `parent:encouraged:{parent_id}:{insight_id}` với TTL 30 ngày hoặc lưu trường `has_encouraged` trong DB).
3. **Đẩy thông báo cho học sinh (Notification Loop):** Tự động thêm 1 bản ghi vào bảng `notifications` của con (`user_id = child_id`):
   - `notification_type`: `"streak"` hoặc `"achievement"`.
   - `title`: `"Lời khen từ phụ huynh!"`.
   - `content`: `"Bố/Mẹ vừa gửi lời khích lệ và tự hào về thành tích học tập chăm chỉ của bạn!"`.

---

#### 3. Đánh dấu tất cả phân tích là đã đọc (Mark All As Read)
- **Endpoint:** `POST /api/parent/insights/read-all`
- **Auth Middleware:** Yêu cầu JWT token của Phụ huynh (`user_id`).
- **Request Body (tùy chọn):**
```json
{
  "child_id": "a055e1b3-bbfe-46b1-8e01-df7aac8c2732"
}
```
*(Nếu không truyền `child_id`, backend sẽ đánh dấu đã đọc cho tất cả insights của phụ huynh).*

##### Response Mẫu (200 OK):
```json
{
  "message": "success",
  "data": {
    "updated_count": 2
  }
}
```

---

### 12.4. Quy tắc Fallback & Hiển thị trên Mobile (`FamilyInsightsRepositoryImpl`)

| Trường dữ liệu | Giá trị từ API | Quy tắc hiển thị trên giao diện Mobile |
|---|---|---|
| `insights` | Danh sách rỗng `[]` và không bật preview | Hiển thị Empty State với icon `Icons.insights_outlined` + text: `"Chưa có phân tích học tập mới cho giai đoạn này."` |
| `metrics` | Rỗng `[]` hoặc `null` | Ẩn hoàn toàn khối 2 pill số liệu định lượng, thẻ co giãn tự nhiên. |
| `teacher_quote` | `null` hoặc rỗng `""` | Ẩn khối trích dẫn của giáo viên (Callout card viền cam). |
| `streak_info` | `null` | Ẩn khối hiển thị chuỗi chuyên cần T2–T6. |
| `has_encouraged` | `true` | Nút khích lệ tự động đổi thành `[ ✓ Đã gửi lời khích lệ ]` với style nền xám nhạt, viền mờ, không bấm lại được. |
| `action_label` | `null` hoặc rỗng `""` | Ẩn liên kết điều hướng chân thẻ. |
| Lỗi kết nối / Backend chưa có DB | Mạng lỗi hoặc timeout | Tự động kích hoạt **Preview Fallback** (`enablePreviewFallback = true`) nạp 3 thẻ mẫu tiêu chuẩn (Minh Đọc hiểu, Lan Viết luận, Minh Chuyên cần) để đảm bảo UI không bao giờ bị gãy trong giai đoạn trải nghiệm. |

