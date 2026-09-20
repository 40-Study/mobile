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
