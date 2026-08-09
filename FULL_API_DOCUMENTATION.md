# FULL API DOCUMENTATION - Backend Study Platform

> Tài liệu API hoàn chỉnh cho hệ thống học tập trực tuyến
>
> **Base URL:** `/api`
> **Framework:** Go Fiber
> **Last Updated:** 2026-08-06

---

## MUC LUC

1. [Tong Quan He Thong](#1-tong-quan-he-thong)
2. [Authentication & User Management](#2-authentication--user-management)
3. [Course & Learning Management](#3-course--learning-management)
4. [Class & Teaching Management](#4-class--teaching-management)
5. [Quiz & Assessment](#5-quiz--assessment)
6. [Payment & E-commerce](#6-payment--e-commerce)
7. [Realtime & Media](#7-realtime--media)
8. [Gamification](#8-gamification)
9. [Luong Nghiep Vu](#9-luong-nghiep-vu)

---

## 1. TONG QUAN HE THONG

### 1.1 Kien Truc Tong The

```
+------------------+     +------------------+     +------------------+
|   Frontend App   | --> |   API Gateway    | --> |   Backend API    |
+------------------+     +------------------+     +------------------+
                                                          |
                    +-------------------------------------+
                    |                |                    |
              +-----v-----+    +-----v-----+       +------v------+
              | PostgreSQL|    |   Redis   |       |    MinIO    |
              |  Database |    |   Cache   |       |   Storage   |
              +-----------+    +-----------+       +-------------+
                                                          |
                                              +-----------+-----------+
                                              |                       |
                                        +-----v-----+           +-----v-----+
                                        |  FFmpeg   |           |  RabbitMQ |
                                        |  Encoder  |           |   Queue   |
                                        +-----------+           +-----------+
```

### 1.2 Thong Ke API Endpoints

| Module | So Luong Endpoints |
|--------|-------------------|
| Authentication & User | ~50 |
| Course & Learning | ~71 |
| Class & Teaching | ~40 |
| Quiz & Assessment | ~60 |
| Payment & E-commerce | ~34 |
| Realtime & Media | ~111 |
| Gamification | ~6 |
| **Tong Cong** | **~372 endpoints** |

### 1.3 Quy Tac Chung

- **Authentication:** JWT Bearer Token trong header `Authorization: Bearer <token>`
- **Content-Type:** `application/json`
- **Response Format:**
```json
{
  "message": "Success message",
  "data": { ... },
  "error": null
}
```
- **Pagination:**
```json
{
  "data": [...],
  "total": 100,
  "page": 1,
  "page_size": 20,
  "total_pages": 5
}
```

---

## 2. AUTHENTICATION & USER MANAGEMENT

### 2.1 OAuth Routes (Public)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/auth/oauth/:provider` | Redirect toi OAuth provider (github, google, facebook) |
| GET | `/auth/oauth/:provider/callback` | Xu ly callback tu OAuth provider |

### 2.2 Registration (Public - Rate Limited)

#### POST `/auth/register/request` - Yeu Cau OTP Dang Ky
**Request:**
```json
{
  "email": "user@example.com",
  "password": "StrongPass123!",
  "confirm_password": "StrongPass123!",
  "user_name": "johndoe",
  "full_name": "John Doe"
}
```
**Response:** OTP sent to email

#### POST `/auth/register` - Xac Thuc OTP & Tao Tai Khoan
**Request:**
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```
**Response:**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "user_name": "johndoe",
  "full_name": "John Doe"
}
```

### 2.3 Login (Public - Rate Limited)

#### POST `/auth/login` - Dang Nhap
**Request:**
```json
{
  "email": "user@example.com",
  "password": "StrongPass123!",
  "device_info": {
    "device_id": "device-uuid",
    "device_name": "iPhone 15",
    "os": "iOS 17",
    "app_version": "1.0.0",
    "user_agent": "Mozilla/5.0..."
  }
}
```
**Response:**
```json
{
  "completed": true,
  "session_token": "string",
  "roles": ["student", "teacher"],
  "requires_org_selection": false,
  "organizations": [],
  "access_token": "jwt-token",
  "refresh_token": "refresh-token",
  "user": {
    "id": "uuid",
    "username": "johndoe",
    "email": "user@example.com",
    "full_name": "John Doe",
    "avatar_url": "https://..."
  },
  "active_role": {
    "id": "uuid",
    "name": "student",
    "type": "system"
  },
  "current_device": {
    "device_id": "uuid",
    "device_name": "iPhone 15"
  }
}
```

### 2.4 Role Selection (Public)

#### POST `/auth/select-role` - Chon Role Sau Login
**Request:**
```json
{
  "session_token": "string",
  "role_id": "uuid",
  "role_type": "system|organization",
  "organization_id": "uuid"
}
```

#### GET `/auth/system-roles` - Lay Danh Sach System Roles
**Response:**
```json
[
  { "id": "uuid", "name": "student", "description": "Student role" },
  { "id": "uuid", "name": "teacher", "description": "Teacher role" }
]
```

### 2.5 Password Recovery (Public - Rate Limited)

| Method | Path | Request | Mo Ta |
|--------|------|---------|-------|
| POST | `/auth/reset-password/request` | `{ "email": "..." }` | Yeu cau OTP reset password |
| POST | `/auth/reset-password` | `{ "email", "otp", "new_password", "confirm_password" }` | Reset password |

### 2.6 Token Management

| Method | Path | Request | Mo Ta |
|--------|------|---------|-------|
| POST | `/auth/refresh-token` | `{ "refresh_token": "..." }` | Refresh access token |

### 2.7 Protected Routes - Role Management (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/auth/my-roles` | Lay tat ca roles cua user hien tai |
| POST | `/auth/switch-role` | Chuyen doi active role |

### 2.8 Protected Routes - Profile Management (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/auth/me/profiles` | Lay tat ca profiles cua user |
| POST | `/auth/me/profiles` | Tao profile moi (them system role) |
| DELETE | `/auth/me/profiles/:id` | Xoa profile |
| GET | `/auth/me` | Lay thong tin user hien tai |
| PUT | `/auth/me` | Cap nhat thong tin user |

#### PUT `/auth/me` - Cap Nhat Thong Tin
**Request:**
```json
{
  "username": "newusername",
  "full_name": "New Name",
  "phone": "+84123456789",
  "date_of_birth": "1990-01-01",
  "bio": "Developer",
  "avatar_url": "https://..."
}
```

### 2.9 Device & Session Management (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/auth/devices` | Lay danh sach thiet bi dang login |
| POST | `/auth/logout` | Logout thiet bi hien tai |
| POST | `/auth/logout-all` | Logout tat ca thiet bi |
| PUT | `/auth/change-password` | Thay doi password |
| DELETE | `/auth/me` | Soft-delete tai khoan |

### 2.10 OAuth Account Linking (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/auth/linked-accounts` | Lay danh sach OAuth accounts da lien ket |
| DELETE | `/auth/linked-accounts/:provider` | Disconnect OAuth provider |

### 2.11 Organization Role Management (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/org-roles/` | Tao role to chuc moi |
| GET | `/org-roles/` | Lay danh sach tat ca roles |
| GET | `/org-roles/:id` | Lay chi tiet role |
| PUT | `/org-roles/:id` | Cap nhat role |
| DELETE | `/org-roles/:id` | Xoa role (soft delete) |
| PATCH | `/org-roles/:id/restore` | Khoi phuc role |
| GET | `/org-roles/:id/permissions` | Lay permissions cua role |
| POST | `/org-roles/:id/permissions` | Them permissions cho role |
| PUT | `/org-roles/:id/permissions` | Set permissions (replace) |
| DELETE | `/org-roles/:id/permissions` | Xoa permissions |

### 2.12 System Role Management (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/system-roles/` | Lay danh sach system roles (public) |
| POST | `/system-roles/` | Tao system role moi |
| GET | `/system-roles/:id` | Lay chi tiet system role |
| PUT | `/system-roles/:id` | Cap nhat system role |
| DELETE | `/system-roles/:id` | Xoa system role |
| GET | `/system-roles/:id/permissions` | Lay permissions |
| POST | `/system-roles/:id/permissions` | Them permissions |

### 2.13 Permission Management (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/permissions/` | Lay danh sach tat ca permissions |
| GET | `/permissions/:id` | Lay chi tiet permission |
| PUT | `/permissions/:id` | Cap nhat permission |

### 2.14 Organization Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/organizations/` | Tao organization moi |
| GET | `/organizations/` | Lay danh sach organizations |
| GET | `/organizations/:id` | Lay chi tiet organization |
| PUT | `/organizations/:id` | Cap nhat organization |
| DELETE | `/organizations/:id` | Xoa organization |

### 2.15 Parent Invitation (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/invitations/validate/:token` | Validate invitation token (public) |
| POST | `/invitations/invite` | Hoc sinh gui loi moi phu huynh |
| GET | `/invitations/pending` | Lay invitations cho phu huynh respond |
| GET | `/invitations/sent` | Lay invitations da gui |
| POST | `/invitations/:id/respond` | Phu huynh respond (accept/reject) |
| POST | `/invitations/:id/revoke` | Hoc sinh revoke invitation |

### 2.16 Parent Dashboard (Auth Required)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/parent/children/:id/overview` | Lay overview hoc sinh |
| GET | `/parent/children/:id/courses` | Lay khoa hoc cua hoc sinh |
| GET | `/parent/children/:id/grades` | Lay diem so cua hoc sinh |
| GET | `/parent/children/:id/schedule` | Lay lich hoc cua hoc sinh |
| GET | `/parent/children/:id/timetable` | Lay thoi khoa bieu |
| GET | `/parent/children/:id/attendance` | Lay diem danh |
| GET | `/parent/children/:id/assignments` | Lay bai tap |

---

## 3. COURSE & LEARNING MANAGEMENT

### 3.1 Course CRUD

#### GET `/courses` - Lay Danh Sach Khoa Hoc (Public)
**Response:**
```json
{
  "courses": [
    {
      "id": "uuid",
      "title": "JavaScript Fundamentals",
      "slug": "javascript-fundamentals",
      "short_description": "Learn JS basics",
      "thumbnail_url": "https://...",
      "price": 499000,
      "discount_price": 299000,
      "level": "beginner",
      "language": "vi",
      "instructor_name": "John Doe",
      "average_rating": 4.5,
      "total_students": 1250,
      "total_lessons": 45,
      "total_duration_mins": 720,
      "status": "published"
    }
  ],
  "total": 100,
  "page": 1,
  "page_size": 20
}
```

#### POST `/courses` - Tao Khoa Hoc (Auth Required)
**Request:**
```json
{
  "instructor_id": "uuid",
  "category_id": "uuid",
  "title": "JavaScript Fundamentals",
  "short_description": "Learn JS basics",
  "description": "Full description...",
  "thumbnail_url": "https://...",
  "preview_video_url": "https://...",
  "level": "beginner|intermediate|advanced|all_levels",
  "language": "vi",
  "price": 499000,
  "discount_price": 299000,
  "discount_expires_at": "2024-12-31T23:59:59Z",
  "requirements": ["Basic computer skills"],
  "objectives": ["Understand JS fundamentals"],
  "target_audience": ["Beginners"],
  "is_free": false,
  "tag_ids": ["uuid1", "uuid2"]
}
```

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/courses` | Lay danh sach khoa hoc (public) |
| GET | `/courses/slug/:slug` | Lay khoa hoc theo slug (public) |
| GET | `/courses/:id` | Lay chi tiet khoa hoc (auth) |
| POST | `/courses` | Tao khoa hoc moi |
| PUT | `/courses/:id` | Cap nhat khoa hoc |
| DELETE | `/courses/:id` | Xoa khoa hoc |

### 3.2 Section Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/courses/:course_id/sections` | Tao section moi |
| GET | `/courses/:course_id/sections` | Lay tat ca sections |
| GET | `/courses/:course_id/sections/:id` | Lay chi tiet section |
| PUT | `/courses/:course_id/sections/reorder` | Sap xep lai thu tu |
| PUT | `/courses/:course_id/sections/:id` | Cap nhat section |
| DELETE | `/courses/:course_id/sections/:id` | Xoa section |

#### POST `/courses/:course_id/sections` - Tao Section
**Request:**
```json
{
  "title": "Getting Started",
  "description": "Introduction to the course",
  "display_order": 1
}
```

### 3.3 Lesson Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/sections/:section_id/lessons` | Tao lesson moi |
| GET | `/sections/:section_id/lessons` | Lay tat ca lessons |
| PUT | `/sections/:section_id/lessons/reorder` | Sap xep lai thu tu |
| GET | `/lessons/:id` | Lay chi tiet lesson |
| PUT | `/lessons/:id` | Cap nhat lesson |
| DELETE | `/lessons/:id` | Xoa lesson |

#### POST `/sections/:section_id/lessons` - Tao Lesson
**Request:**
```json
{
  "title": "Introduction to Variables",
  "description": "Learn about variables in JS",
  "display_order": 1,
  "duration_minutes": 15,
  "is_preview": true,
  "is_mandatory": true
}
```

### 3.4 Lesson Content Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/lessons/:lesson_id/contents` | Tao noi dung lesson |
| GET | `/lessons/:lesson_id/contents` | Lay noi dung lesson |
| PUT | `/lessons/:lesson_id/contents/reorder` | Sap xep lai thu tu |
| PUT | `/lessons/:lesson_id/contents/:id` | Cap nhat noi dung |
| DELETE | `/lessons/:lesson_id/contents/:id` | Xoa noi dung |

#### POST `/lessons/:lesson_id/contents` - Tao Noi Dung
**Request:**
```json
{
  "type": "video|livestream|exercise",
  "title": "Video Introduction",
  "video_url": "https://...",
  "duration": 900,
  "exercise_id": "uuid",
  "is_mandatory": true,
  "display_order": 1
}
```

### 3.5 Class-Lesson Content Assignment

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/lesson-contents/:id/classes/bulk` | Gan nhieu classes cho noi dung |
| POST | `/lesson-contents/:id/classes` | Gan mot class cho noi dung |
| GET | `/lesson-contents/:id/classes` | Lay danh sach classes |
| PUT | `/lesson-contents/:id/classes/:class_id` | Cap nhat lich |
| DELETE | `/lesson-contents/:id/classes/:class_id` | Loai bo class |

### 3.6 Category & Tag Management

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/categories` | Lay tat ca categories (public) |
| GET | `/categories/:id` | Lay chi tiet category |
| POST | `/categories` | Tao category moi |
| PUT | `/categories/:id` | Cap nhat category |
| DELETE | `/categories/:id` | Xoa category |
| GET | `/tags` | Lay tat ca tags (public) |
| GET | `/tags/:id` | Lay chi tiet tag |
| POST | `/tags` | Tao tag moi |
| PUT | `/tags/:id` | Cap nhat tag |
| DELETE | `/tags/:id` | Xoa tag |

### 3.7 Enrollment Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/courses/:courseId/enroll` | Ghi danh khoa hoc |
| DELETE | `/courses/:courseId/enroll` | Huy ghi danh |
| GET | `/courses/:courseId/enrollments` | Lay danh sach ghi danh |
| GET | `/enrollments` | Lay khoa hoc da ghi danh cua user |
| GET | `/enrollments/:id` | Lay chi tiet ghi danh |
| PUT | `/lessons/:lessonId/progress` | Cap nhat tien do lesson |

#### PUT `/lessons/:lessonId/progress` - Cap Nhat Tien Do
**Request:**
```json
{
  "status": "not_started|in_progress|completed",
  "progress_percentage": 75.5,
  "video_watched_seconds": 450
}
```

### 3.8 Review Management

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/courses/:courseId/reviews` | Lay reviews cua khoa hoc (public) |
| POST | `/courses/:courseId/reviews` | Tao review moi |
| PUT | `/reviews/:id` | Cap nhat review |
| DELETE | `/reviews/:id` | Xoa review |
| POST | `/reviews/:id/reaction` | React to review (helpful/not_helpful) |
| DELETE | `/reviews/:id/reaction` | Loai bo reaction |

### 3.9 Certificate Management

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/certificates/verify/:number` | Xac minh chung chi (public) |
| POST | `/certificates` | Cap chung chi |
| GET | `/certificates` | Lay chung chi cua user |
| GET | `/certificates/:id` | Lay chi tiet chung chi |

---

## 4. CLASS & TEACHING MANAGEMENT

### 4.1 Class CRUD

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/classes/` | Tao lop hoc moi |
| GET | `/classes/` | Lay danh sach lop hoc |
| GET | `/classes/me` | Lay lop hoc cua user hien tai |
| GET | `/classes/:id` | Lay chi tiet lop hoc |
| PUT | `/classes/:id` | Cap nhat lop hoc |
| DELETE | `/classes/:id` | Xoa lop hoc |

#### POST `/classes/` - Tao Lop Hoc
**Request:**
```json
{
  "name": "JS Class A",
  "description": "Morning class",
  "course_id": "uuid",
  "max_students": 30,
  "start_date": "2024-01-15",
  "end_date": "2024-04-15"
}
```

### 4.2 Teacher-Class Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/classes/:id/teachers` | Gan giao vien vao lop |
| DELETE | `/classes/:id/teachers/:teacherId` | Loai bo giao vien |
| GET | `/classes/:id/teachers` | Lay danh sach giao vien |

### 4.3 Student-Class Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/classes/:id/students` | Ghi danh hoc sinh |
| DELETE | `/classes/:id/students/:studentId` | Loai bo hoc sinh |
| GET | `/classes/:id/students` | Lay danh sach hoc sinh |

### 4.4 Attendance Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/classes/:classId/attendances/` | Diem danh |
| GET | `/classes/:classId/attendances/` | Lay danh sach diem danh |
| GET | `/classes/:classId/attendances/:id` | Lay chi tiet diem danh |
| PUT | `/classes/:classId/attendances/:id` | Cap nhat diem danh |
| DELETE | `/classes/:classId/attendances/:id` | Xoa diem danh |

#### POST `/classes/:classId/attendances/` - Diem Danh
**Request:**
```json
{
  "student_id": "uuid",
  "date": "2024-01-15",
  "status": "present|absent|late|excused",
  "note": "Came 10 minutes late"
}
```

### 4.5 Schedule Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/classes/:classId/schedules/` | Tao lich hoc |
| GET | `/classes/:classId/schedules/` | Lay danh sach lich |
| GET | `/classes/:classId/schedules/:id` | Lay chi tiet lich |
| PUT | `/classes/:classId/schedules/:id` | Cap nhat lich |
| DELETE | `/classes/:classId/schedules/:id` | Xoa lich |
| GET | `/classes/:classId/timetable` | Lay thoi khoa bieu |

### 4.6 Session Management

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/classes/:classId/sessions/` | Lay danh sach buoi hoc |
| POST | `/classes/:classId/sessions/` | Tao buoi hoc moi |
| GET | `/classes/:classId/sessions/:id` | Lay chi tiet buoi hoc |
| PUT | `/classes/:classId/sessions/:id` | Cap nhat buoi hoc |
| DELETE | `/classes/:classId/sessions/:id` | Huy buoi hoc |
| POST | `/classes/:classId/sessions/generate` | Tao buoi hoc tu lich |
| POST | `/sessions/:sessionId/check-in` | Check-in buoi hoc |
| POST | `/sessions/:sessionId/check-out` | Check-out buoi hoc |

### 4.7 Teacher Profile Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/teacher-profiles/` | Tao teacher profile |
| GET | `/teacher-profiles/` | Lay tat ca teacher profiles |
| GET | `/teacher-profiles/:id` | Lay chi tiet profile |
| PUT | `/teacher-profiles/:id` | Cap nhat profile |
| DELETE | `/teacher-profiles/:id` | Xoa profile |

#### POST `/teacher-profiles/` - Tao Profile
**Request:**
```json
{
  "user_id": "uuid",
  "specialization": "Web Development",
  "education": "MSc Computer Science",
  "experience_years": 5,
  "certificate_info": "AWS Certified...",
  "department": "IT"
}
```

### 4.8 Personal Events

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/me/events/` | Tao su kien ca nhan |
| GET | `/me/events/` | Lay tat ca su kien |
| PUT | `/me/events/:id` | Cap nhat su kien |
| DELETE | `/me/events/:id` | Xoa su kien |

---

## 5. QUIZ & ASSESSMENT

### 5.1 Quiz CRUD

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/quizzes` | Tao quiz moi |
| GET | `/quizzes` | Lay danh sach quizzes |
| GET | `/quizzes/:id` | Lay chi tiet quiz |
| PUT | `/quizzes/:id` | Cap nhat quiz |
| DELETE | `/quizzes/:id` | Xoa quiz |
| POST | `/quizzes/:id/duplicate` | Tao ban sao quiz |

### 5.2 Question Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/quizzes/:quizId/questions` | Tao cau hoi moi |
| GET | `/quizzes/:quizId/questions` | Lay tat ca cau hoi |
| PUT | `/quizzes/:quizId/questions/:id` | Cap nhat cau hoi |
| DELETE | `/quizzes/:quizId/questions/:id` | Xoa cau hoi |
| PUT | `/quizzes/:quizId/questions/reorder` | Sap xep lai cau hoi |
| POST | `/quizzes/:quizId/questions/bulk` | Tao nhieu cau hoi |

### 5.3 Quiz Attempts

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/quizzes/:id/start` | Bat dau lam quiz |
| POST | `/quizzes/:id/submit` | Nop bai quiz |
| GET | `/quizzes/:id/attempts` | Lay tat ca attempts |
| GET | `/quizzes/:id/attempts/:attemptId` | Lay chi tiet attempt |
| GET | `/quizzes/:id/results` | Lay ket qua tat ca sinh vien |
| GET | `/quizzes/:id/statistics` | Lay thong ke |
| POST | `/attempts/:attemptId/save-answer` | Luu cau tra loi tam |
| GET | `/attempts/:attemptId/progress` | Lay tien do lam bai |

### 5.4 Exercise (Code Execution)

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/exercises` | Tao bai tap moi |
| GET | `/exercises` | Lay danh sach bai tap |
| GET | `/exercises/:id` | Lay chi tiet bai tap |
| PUT | `/exercises/:id` | Cap nhat bai tap |
| DELETE | `/exercises/:id` | Xoa bai tap |
| GET | `/exercises/:id/testcases` | Lay test cases |
| POST | `/exercises/:id/testcases` | Tao test case |
| POST | `/exercises/:id/testcases/import` | Import test cases |
| DELETE | `/exercises/:id/testcases/:testCaseId` | Xoa test case |
| POST | `/exercises/:id/submit` | Nop bai tap |
| GET | `/exercises/:id/submissions` | Lay submissions (admin) |
| GET | `/exercises/:id/my-submissions` | Lay submissions cua user |

### 5.5 Grade Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/classes/:classId/grade-columns` | Tao cot diem |
| GET | `/classes/:classId/grade-columns` | Lay tat ca cot diem |
| PUT | `/classes/:classId/grade-columns/:id` | Cap nhat cot diem |
| DELETE | `/classes/:classId/grade-columns/:id` | Xoa cot diem |
| PUT | `/classes/:classId/grade-columns/reorder` | Sap xep lai cot |
| POST | `/classes/:classId/grades` | Nhap diem |
| GET | `/classes/:classId/grades` | Lay tat ca diem |
| GET | `/classes/:classId/grades/student/:studentId` | Lay diem sinh vien |
| POST | `/classes/:classId/grades/bulk` | Nhap nhieu diem |
| PUT | `/grades/:id` | Cap nhat diem |
| DELETE | `/grades/:id` | Xoa diem |
| POST | `/classes/:classId/final-grades/calculate` | Tinh diem cuoi |
| GET | `/classes/:classId/final-grades` | Lay diem cuoi |
| PUT | `/classes/:classId/final-grades/:id` | Cap nhat diem cuoi |
| POST | `/classes/:classId/final-grades/finalize` | Chot diem |
| GET | `/me/grades` | Lay diem cua user |
| GET | `/me/grades/class/:classId` | Lay diem trong lop cu the |

### 5.6 Contest

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/contests` | Lay danh sach contests (public) |
| GET | `/contests/:slug` | Lay chi tiet contest (public) |
| GET | `/contests/me` | Lay contests cua user |
| POST | `/contests` | Tao contest moi |
| PUT | `/contests/:id` | Cap nhat contest |
| DELETE | `/contests/:id` | Xoa contest |
| POST | `/contests/:id/publish` | Xuat ban contest |
| GET | `/contests/:id/problems` | Lay problems trong contest |
| POST | `/contests/:id/problems` | Tao problem |
| PUT | `/contests/:id/problems/:problemId` | Cap nhat problem |
| DELETE | `/contests/:id/problems/:problemId` | Xoa problem |
| POST | `/contests/:id/join` | Tham gia contest |
| GET | `/contests/:id/leaderboard` | Lay bang xep hang |
| POST | `/contests/:id/problems/:problemId/submit` | Nop bai |
| GET | `/contests/:id/submissions/me` | Lay submissions cua user |

---

## 6. PAYMENT & E-COMMERCE

### 6.1 Cart Management

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/cart` | Lay gio hang |
| POST | `/cart` | Them khoa hoc vao gio |
| DELETE | `/cart` | Xoa khoa hoc khoi gio |
| DELETE | `/cart/clear` | Xoa toan bo gio hang |
| GET | `/cart/check/:courseID` | Kiem tra khoa hoc trong gio |

#### GET `/cart` - Lay Gio Hang
**Response:**
```json
{
  "items": [
    {
      "id": "uuid",
      "course_id": "uuid",
      "course": {
        "id": "uuid",
        "title": "JavaScript Fundamentals",
        "thumbnail_url": "https://...",
        "price": 499000,
        "discount_price": 299000,
        "instructor_name": "John Doe",
        "average_rating": 4.5
      }
    }
  ],
  "total": 299000,
  "total_item": 1
}
```

### 6.2 Order Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/orders` | Tao don hang |
| GET | `/orders/me` | Lay don hang cua user |
| GET | `/orders/:id` | Lay chi tiet don hang |
| POST | `/orders/:id/cancel` | Huy don hang |
| POST | `/orders/:id/payment-intent` | Tao payment intent (QR/Bank) |
| GET | `/orders/:id/payment-status` | Kiem tra trang thai thanh toan |
| POST | `/orders/:id/check-payment` | Kiem tra va xu ly thanh toan |

#### POST `/orders` - Tao Don Hang
**Request:**
```json
{
  "source": "cart|buy_now",
  "course_ids": ["uuid1", "uuid2"],
  "coupon_code": "SALE50",
  "note": "Note",
  "idempotency_key": "unique-key"
}
```
**Response:**
```json
{
  "id": "uuid",
  "order_number": "ORD-20240115-001",
  "subtotal": 998000,
  "discount_amount": 499000,
  "tax_amount": 0,
  "total_amount": 499000,
  "currency": "VND",
  "status": "pending",
  "payment_method": "qr_transfer",
  "items": [...],
  "expires_at": "2024-01-15T12:00:00Z"
}
```

### 6.3 Voucher Management

#### Public Routes
| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/vouchers/public` | Lay voucher cong khai |
| GET | `/vouchers/code/:code` | Lay voucher theo ma |

#### Protected Routes
| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/vouchers/me` | Lay voucher da luu |
| POST | `/vouchers/:id/save` | Luu voucher |
| DELETE | `/vouchers/:id/save` | Xoa voucher da luu |

#### Admin Routes
| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/vouchers` | Tao voucher |
| GET | `/vouchers` | Lay tat ca vouchers |
| GET | `/vouchers/:id` | Lay chi tiet voucher |
| PUT | `/vouchers/:id` | Cap nhat voucher |
| DELETE | `/vouchers/:id` | Xoa voucher |
| POST | `/vouchers/:id/restore` | Khoi phuc voucher |
| POST | `/vouchers/:id/activate` | Kich hoat voucher |
| POST | `/vouchers/:id/deactivate` | Vo hieu hoa voucher |
| GET | `/vouchers/:id/stats` | Lay thong ke voucher |

### 6.4 Wallet Management

#### Student (Buyer)
| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/wallet/me` | Lay thong tin vi |
| GET | `/wallet/transactions` | Lay lich su giao dich |

#### Teacher (Instructor)
| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/wallet/teacher/me` | Lay thong tin vi giao vien |
| GET | `/wallet/teacher/transactions` | Lay lich su thu nhap |
| PUT | `/wallet/teacher/bank-info` | Cap nhat thong tin ngan hang |

### 6.5 Coin System

#### Public Routes
| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/coins/packages` | Lay danh sach goi coin |
| GET | `/coins/packages/:id` | Lay chi tiet goi |

#### Protected Routes
| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/coins/wallet` | Lay vi coin |
| GET | `/coins/wallet/transactions` | Lay lich su coin |
| POST | `/coins/purchases` | Mua coin |
| GET | `/coins/purchases` | Lay don mua coin |
| GET | `/coins/purchases/:id` | Lay chi tiet don |
| POST | `/coins/purchases/:id/verify` | Xac minh don mua |
| POST | `/coins/gift` | Tang coin cho user khac |

#### Admin Routes
| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/coins/admin/packages` | Tao goi coin |
| PUT | `/coins/admin/packages/:id` | Cap nhat goi |
| DELETE | `/coins/admin/packages/:id` | Xoa goi |
| POST | `/coins/admin/adjust` | Dieu chinh so du coin |

---

## 7. REALTIME & MEDIA

### 7.1 Livestream Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/livestream/` | Tao livestream |
| GET | `/livestream/` | Lay danh sach livestreams |
| GET | `/livestream/:id` | Lay chi tiet livestream |
| PUT | `/livestream/:id` | Cap nhat livestream |
| DELETE | `/livestream/:id` | Xoa livestream |
| POST | `/livestream/:id/start` | Bat dau livestream |
| POST | `/livestream/:id/end` | Ket thuc livestream |
| POST | `/livestream/:id/join` | Tham gia livestream |
| POST | `/livestream/:id/leave` | Roi livestream |
| GET | `/livestream/:id/participants` | Lay danh sach nguoi tham gia |
| POST | `/livestream/:id/mute` | Mute nguoi tham gia |
| POST | `/livestream/:id/kick` | Kick nguoi tham gia |
| POST | `/livestream/:id/screenshare/start` | Bat dau chia se man hinh |
| POST | `/livestream/:id/screenshare/stop` | Dung chia se man hinh |

### 7.2 Chat Management

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/chat/send` | Gui tin nhan |
| GET | `/chat/:sessionId/messages` | Lay tin nhan |
| DELETE | `/chat/:id` | Xoa tin nhan |
| POST | `/chat/:id/pin` | Ghim tin nhan |
| POST | `/chat/:id/unpin` | Bo ghim |

### 7.3 Video Upload (Chunked Upload)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/videos/health` | Health check (public) |
| POST | `/videos/upload/init` | Khoi tao upload |
| POST | `/videos/upload/presigned-urls` | Lay presigned URLs |
| POST | `/videos/upload/chunk-complete` | Danh dau chunk hoan thanh |
| POST | `/videos/upload/complete` | Hoan thanh upload |
| GET | `/videos/upload/:upload_id/status` | Lay trang thai upload |
| GET | `/videos/upload/:upload_id/resume` | Lay thong tin resume |
| GET | `/videos/upload/incomplete` | Lay uploads chua hoan thanh |
| DELETE | `/videos/upload/:upload_id` | Huy upload |
| POST | `/videos/upload/:upload_id/reprocess` | Xu ly lai video |
| GET | `/videos/processing/queue` | Lay hang doi xu ly |

#### POST `/videos/upload/init` - Khoi Tao Upload
**Request:**
```json
{
  "resource_id": "uuid",
  "resource_type": "lesson_content",
  "original_file_name": "video.mp4",
  "content_type": "video/mp4",
  "file_size": 104857600,
  "chunk_size": 5242880
}
```
**Response:**
```json
{
  "upload_id": "uuid",
  "upload_key": "string",
  "object_key": "videos/uuid/video.mp4",
  "chunk_size": 5242880,
  "total_chunks": 20,
  "expires_at": "2024-01-15T12:00:00Z"
}
```

### 7.4 HLS Streaming (Public)

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/hls/:upload_id/info` | Lay thong tin video & chat luong |
| GET | `/hls/:upload_id/master.m3u8` | Lay master playlist |
| GET | `/hls/:upload_id/video.mp4` | Stream video goc (fallback) |
| GET | `/hls/:upload_id/:quality/index.m3u8` | Lay playlist theo chat luong |
| GET | `/hls/:upload_id/:quality/:segment` | Lay segment video |

### 7.5 General Upload

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/upload/` | Upload anh |
| POST | `/upload/any` | Upload bat ky file |
| DELETE | `/upload/` | Xoa file |

### 7.6 Discussion Forum

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/discussions/` | Lay danh sach bai dang (public) |
| GET | `/discussions/:slug` | Lay bai dang theo slug (public) |
| POST | `/discussions/` | Tao bai dang moi |
| POST | `/discussions/:slug/comments` | Them comment |
| POST | `/discussions/:id/vote` | Vote (upvote/downvote) |
| DELETE | `/discussions/:id/vote` | Xoa vote |
| DELETE | `/discussions/:id` | Xoa bai dang |

### 7.7 Notification

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/notifications/` | Lay thong bao |
| GET | `/notifications/unread-count` | Lay so thong bao chua doc |
| GET | `/notifications/settings` | Lay cai dat thong bao |
| PUT | `/notifications/settings` | Cap nhat cai dat |
| PATCH | `/notifications/read-all` | Danh dau tat ca da doc |
| PATCH | `/notifications/:id/read` | Danh dau da doc |
| DELETE | `/notifications/:id` | Xoa thong bao |
| POST | `/notifications/send` | Gui thong bao (admin) |

### 7.8 Group Management

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/groups/` | Lay danh sach nhom (public) |
| GET | `/groups/:slug` | Lay chi tiet nhom (public) |
| GET | `/groups/me/joined` | Lay nhom da tham gia |
| GET | `/groups/me/owned` | Lay nhom so huu |
| POST | `/groups/` | Tao nhom moi |
| PUT | `/groups/:id` | Cap nhat nhom |
| DELETE | `/groups/:id` | Xoa nhom |
| POST | `/groups/:id/join` | Tham gia nhom |
| POST | `/groups/:id/leave` | Roi nhom |
| GET | `/groups/:id/members` | Lay thanh vien |
| POST | `/groups/:id/members/invite` | Moi thanh vien |
| PUT | `/groups/:id/members/:userId/role` | Cap nhat role thanh vien |
| DELETE | `/groups/:id/members/:userId` | Xoa thanh vien |
| POST | `/groups/:id/members/:userId/ban` | Chan thanh vien |
| POST | `/groups/:id/members/:userId/unban` | Bo chan |
| GET | `/groups/:id/requests` | Lay yeu cau tham gia |
| POST | `/groups/:id/requests/:requestId/approve` | Duyet yeu cau |
| POST | `/groups/:id/requests/:requestId/reject` | Tu choi yeu cau |

### 7.9 Direct Messaging

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/conversations/` | Lay danh sach hoi thoai |
| POST | `/conversations/direct` | Tao hoi thoai truc tiep |
| GET | `/conversations/:id` | Lay chi tiet hoi thoai |
| POST | `/conversations/:id/read` | Danh dau da doc |
| POST | `/conversations/:id/mute` | Tat thong bao |
| POST | `/conversations/:id/unmute` | Bat thong bao |
| POST | `/conversations/:id/pin` | Ghim hoi thoai |
| POST | `/conversations/:id/unpin` | Bo ghim |
| GET | `/conversations/:id/messages` | Lay tin nhan |
| POST | `/conversations/:id/messages` | Gui tin nhan |
| PUT | `/conversations/:id/messages/:messageId` | Sua tin nhan |
| DELETE | `/conversations/:id/messages/:messageId` | Xoa tin nhan |
| POST | `/conversations/:id/messages/:messageId/pin` | Ghim tin nhan |
| POST | `/conversations/:id/messages/:messageId/reactions` | Them reaction |
| DELETE | `/conversations/:id/messages/:messageId/reactions/:emoji` | Xoa reaction |
| GET | `/messages/search` | Tim kiem tin nhan |
| GET | `/messages/unread` | Lay so tin nhan chua doc |

### 7.10 Report System

| Method | Path | Mo Ta |
|--------|------|-------|
| POST | `/reports/` | Tao bao cao |
| GET | `/reports/` | Lay danh sach bao cao |
| GET | `/reports/my` | Lay bao cao cua user |
| GET | `/reports/:id` | Lay chi tiet bao cao |
| PUT | `/reports/:id/status` | Cap nhat trang thai |
| DELETE | `/reports/:id` | Xoa bao cao |

---

## 8. GAMIFICATION

### 8.1 Achievement

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/achievements` | Lay tat ca achievements (public) |
| GET | `/achievements/me` | Lay achievements cua user |
| POST | `/achievements/:id/unlock` | Unlock achievement |

**Response `/achievements/me`:**
```json
[
  {
    "id": "uuid",
    "name": "First Course Completed",
    "slug": "first-course-completed",
    "description": "Complete your first course",
    "icon_url": "https://...",
    "badge_url": "https://...",
    "category": "learning",
    "points": 100,
    "requirement": "Complete 1 course",
    "threshold": 1,
    "unlocked": true,
    "earned_at": "2024-01-15T10:00:00Z",
    "progress": 100
  }
]
```

### 8.2 Leaderboard

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/leaderboard` | Lay bang xep hang (public) |
| GET | `/leaderboard/me` | Lay ranking cua user |

**Query Parameters:**
- `period`: `weekly | monthly | all_time` (default: all_time)
- `limit`: number (default: 100)

**Response:**
```json
{
  "period_type": "monthly",
  "period": "2024-01",
  "entries": [
    {
      "rank": 1,
      "user_id": "uuid",
      "user_name": "johndoe",
      "full_name": "John Doe",
      "avatar_url": "https://...",
      "points": 5000
    }
  ],
  "total": 1250
}
```

### 8.3 User Public Profile

| Method | Path | Mo Ta |
|--------|------|-------|
| GET | `/users/:id/public-profile` | Lay public profile (public) |

**Response:**
```json
{
  "user_id": "uuid",
  "user_name": "johndoe",
  "full_name": "John Doe",
  "avatar_url": "https://...",
  "bio": "Developer",
  "joined_at": "2023-01-01T00:00:00Z",
  "stats": {
    "total_points": 5000,
    "level": 15,
    "level_progress": 75,
    "current_streak": 30,
    "longest_streak": 45,
    "total_checkins": 180,
    "achievement_count": 25,
    "courses_completed": 10,
    "lessons_completed": 250,
    "total_study_time_minutes": 12000
  },
  "featured_achievements": [...],
  "activity": [...],
  "completed_courses": [...]
}
```

---

## 9. LUONG NGHIEP VU

### 9.1 Luong Dang Ky & Dang Nhap

```
+------------------+     +------------------+     +------------------+
|  1. Nguoi dung   | --> | 2. Yeu cau OTP   | --> |  3. Nhap OTP     |
|  nhap thong tin  |     |    /register/    |     |   /register      |
+------------------+     |    request       |     +------------------+
                         +------------------+              |
                                                          v
+------------------+     +------------------+     +------------------+
|  6. Trang chu    | <-- | 5. Chon role     | <-- |  4. Dang nhap    |
|                  |     |   /select-role   |     |    /login        |
+------------------+     +------------------+     +------------------+
```

**Chi tiet:**
1. User nhap email, password, username
2. He thong gui OTP qua email
3. User xac thuc OTP, tai khoan duoc tao
4. User dang nhap, nhan session_token
5. Neu co nhieu role -> chon role
6. Nhan access_token, refresh_token -> vao trang chu

### 9.2 Luong Mua Khoa Hoc

```
+------------------+     +------------------+     +------------------+
|  1. Them vao     | --> | 2. Xem gio hang  | --> | 3. Ap dung       |
|  gio hang /cart  |     |    GET /cart     |     |    voucher       |
+------------------+     +------------------+     +------------------+
                                                          |
                                                          v
+------------------+     +------------------+     +------------------+
|  6. Hoan thanh   | <-- | 5. Kiem tra      | <-- |  4. Tao don hang |
|  -> Ghi danh     |     |  thanh toan      |     |    POST /orders  |
+------------------+     +------------------+     +------------------+
```

**Chi tiet:**
1. User them khoa hoc vao gio hang
2. Xem lai gio hang, chinh sua neu can
3. Nhap ma giam gia (neu co)
4. Tao don hang -> Nhan QR code hoac thong tin chuyen khoan
5. Thanh toan -> He thong kiem tra tu dong
6. Thanh toan thanh cong -> Tu dong ghi danh khoa hoc

### 9.3 Luong Hoc Tap

```
+------------------+     +------------------+     +------------------+
|  1. Chon khoa    | --> | 2. Xem section   | --> | 3. Chon lesson   |
|  hoc da ghi danh |     |    & lessons     |     |                  |
+------------------+     +------------------+     +------------------+
                                                          |
                         +--------------------------------+
                         |
                         v
+------------------+     +------------------+     +------------------+
|  Video Content   |     | Exercise/Quiz   |     |   Livestream     |
|  - Xem video     |     | - Lam bai tap    |     |   - Tham gia     |
|  - Cap nhat %    |     | - Nop bai        |     |   - Chat         |
+------------------+     +------------------+     +------------------+
          |                      |                       |
          v                      v                       v
+------------------------------------------------------------------+
|                    CAP NHAT TIEN DO                              |
|  PUT /lessons/:lessonId/progress                                 |
|  - status: not_started -> in_progress -> completed               |
|  - progress_percentage: 0% -> 100%                               |
+------------------------------------------------------------------+
          |
          v
+------------------+     +------------------+
|  Hoan thanh      | --> |   Cap chung chi  |
|  100% khoa hoc   |     | POST /certificates|
+------------------+     +------------------+
```

### 9.4 Luong Livestream

```
+------------------+     +------------------+     +------------------+
|  1. Giao vien    | --> | 2. Bat dau       | --> | 3. Hoc sinh      |
|  tao livestream  |     |    livestream    |     |    tham gia      |
+------------------+     +------------------+     +------------------+
         |                       |                        |
         v                       v                        v
+------------------------------------------------------------------+
|                    TRONG PHIEN LIVESTREAM                        |
|  - Chat realtime                                                 |
|  - Chia se man hinh                                              |
|  - Whiteboard                                                    |
|  - Diem danh                                                     |
+------------------------------------------------------------------+
         |
         v
+------------------+     +------------------+
|  4. Ket thuc     | --> | 5. Luu recording |
|    livestream    |     |    (neu co)      |
+------------------+     +------------------+
```

### 9.5 Luong Lam Quiz

```
+------------------+     +------------------+     +------------------+
|  1. Bat dau      | --> | 2. Tra loi       | --> | 3. Auto-save     |
|  POST /quizzes/  |     |    cau hoi       |     |    cau tra loi   |
|  :id/start       |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
                                                          |
                         +--------------------------------+
                         |
                         v
+------------------+     +------------------+     +------------------+
|  6. Xem ket qua  | <-- | 5. Cham diem     | <-- |  4. Nop bai      |
|  /attempts/:id   |     |    tu dong       |     |    /submit       |
+------------------+     +------------------+     +------------------+
```

### 9.6 Luong Bai Tap Lap Trinh

```
+------------------+     +------------------+     +------------------+
|  1. Xem de bai   | --> | 2. Viet code     | --> | 3. Chay thu      |
|  GET /exercises/ |     |    trong editor  |     |    /run-custom   |
|  :id             |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
                                                          |
         +------------------------------------------------+
         |
         v
+------------------+     +------------------+     +------------------+
|  4. Nop bai      | --> | 5. Judge0 chay   | --> | 6. Tra ket qua   |
|  POST /exercises/|     |    test cases    |     |    verdict &     |
|  :id/submit      |     |                  |     |    score         |
+------------------+     +------------------+     +------------------+
```

### 9.7 Luong Phu Huynh - Hoc Sinh

```
+------------------+     +------------------+     +------------------+
|  1. Hoc sinh     | --> | 2. He thong gui  | --> | 3. Phu huynh     |
|  gui loi moi     |     |    email         |     |    click link    |
+------------------+     +------------------+     +------------------+
                                                          |
                         +--------------------------------+
                         |
                         v
+------------------+     +------------------+     +------------------+
|  6. Phu huynh    | <-- | 5. Lien ket      | <-- |  4. Dang ky/     |
|  theo doi con    |     |    thanh cong    |     |    Dang nhap     |
+------------------+     +------------------+     +------------------+
         |
         v
+------------------------------------------------------------------+
|                    PARENT DASHBOARD                              |
|  - Xem tien do hoc tap                                           |
|  - Xem diem so, bai tap                                          |
|  - Xem lich hoc, diem danh                                       |
+------------------------------------------------------------------+
```

### 9.8 Luong Gamification

```
+------------------------------------------------------------------+
|                    HOAT DONG HOC TAP                             |
|  - Hoan thanh lesson -> +10 points                               |
|  - Hoan thanh quiz -> +50 points                                 |
|  - Hoan thanh khoa hoc -> +500 points                            |
|  - Streak hang ngay -> +20 points/ngay                           |
+------------------------------------------------------------------+
         |
         v
+------------------+     +------------------+     +------------------+
|  Tich luy        | --> | Unlock           | --> | Leaderboard      |
|  diem            |     | achievements     |     | ranking          |
+------------------+     +------------------+     +------------------+
         |
         v
+------------------+
|  Level up        |
|  khi du diem     |
+------------------+
```

---

## PHU LUC

### A. HTTP Status Codes

| Code | Mo Ta |
|------|-------|
| 200 | OK - Thanh cong |
| 201 | Created - Tao moi thanh cong |
| 204 | No Content - Xoa thanh cong |
| 400 | Bad Request - Request khong hop le |
| 401 | Unauthorized - Chua xac thuc |
| 403 | Forbidden - Khong co quyen |
| 404 | Not Found - Khong tim thay |
| 409 | Conflict - Xung dot (da ton tai) |
| 422 | Unprocessable Entity - Du lieu khong hop le |
| 429 | Too Many Requests - Qua nhieu request |
| 500 | Internal Server Error - Loi server |

### B. Rate Limiting

| Endpoint Group | Limit |
|----------------|-------|
| Auth (login, register) | 10 requests/minute |
| OTP requests | 3 requests/minute |
| API chung | 100 requests/minute |
| Upload | 5 concurrent uploads |

### C. File Upload Limits

| Loai File | Kich Thuoc Toi Da |
|-----------|-------------------|
| Image | 10 MB |
| Video | 5 GB |
| Document | 50 MB |
| Any file | 100 MB |

### D. Supported Video Formats

- MP4 (H.264/H.265)
- WebM
- MOV
- AVI
- MKV

**Output HLS Qualities:**
- 360p (640x360)
- 480p (854x480)
- 720p (1280x720)
- 1080p (1920x1080)

---

> **Note:** Tai lieu nay duoc tao tu dong dua tren phan tich source code.
> Cap nhat khi co thay doi API.
