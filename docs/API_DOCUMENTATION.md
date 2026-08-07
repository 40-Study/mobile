# API DOCUMENTATION - Backend Study Platform

**Base URL:** `http://localhost:3000/api`
**Version:** v1
**Content-Type:** `application/json`
**Authorization:** `Bearer <access_token>` (cho các endpoint yêu cầu xác thực)

---

## Mục Lục

1. [Authentication](#1-authentication)
2. [User Management](#2-user-management)
3. [Course & Learning](#3-course--learning)
4. [Class Management](#4-class-management)
5. [Quiz & Assessment](#5-quiz--assessment)
6. [Exercise & Coding](#6-exercise--coding)
7. [Grade Management](#7-grade-management)
8. [Cart & Order](#8-cart--order)
9. [Voucher](#9-voucher)
10. [Wallet & Coins](#10-wallet--coins)
11. [Notification](#11-notification)
12. [Messaging](#12-messaging)
13. [Livestream](#13-livestream)
14. [Video Upload & HLS](#14-video-upload--hls)
15. [Groups & Community](#15-groups--community)
16. [Gamification](#16-gamification)
17. [Schedule & Attendance](#17-schedule--attendance)
18. [Certificate](#18-certificate)
19. [Parent Dashboard](#19-parent-dashboard)
20. [Reports](#20-reports)
21. [Organization & Roles](#21-organization--roles)

---

## Response Format

### Success Response
```json
{
  "message": "Success",
  "data": { ... }
}
```

### Error Response
```json
{
  "code": "ERR_CODE",
  "message": "Error description",
  "errors": [
    {"field": "email", "message": "Invalid email format"}
  ]
}
```

### Pagination Response
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

## 1. Authentication

### 1.1 Register
```
POST /auth/register
```
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "full_name": "Nguyen Van A",
  "phone": "0912345678"
}
```

### 1.2 Login
```
POST /auth/login
```
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```
**Response:**
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJSUzI1NiIs...",
  "expires_in": 900,
  "user": { ... }
}
```

### 1.3 Refresh Token
```
POST /auth/refresh
```
**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJSUzI1NiIs..."
}
```

### 1.4 Logout
```
POST /auth/logout
```
🔒 **Auth Required**

### 1.5 Logout All Devices
```
POST /auth/logout/all
```
🔒 **Auth Required**

### 1.6 Get Profile
```
GET /auth/profile
```
🔒 **Auth Required**

### 1.7 Update Profile
```
PUT /auth/profile
```
🔒 **Auth Required**

**Request Body:**
```json
{
  "full_name": "Nguyen Van B",
  "avatar_url": "https://...",
  "phone": "0987654321"
}
```

### 1.8 Change Password
```
POST /auth/change-password
```
🔒 **Auth Required**

**Request Body:**
```json
{
  "old_password": "oldPassword123",
  "new_password": "newPassword456"
}
```

### 1.9 Forgot Password
```
POST /auth/forgot-password
```
**Request Body:**
```json
{
  "email": "user@example.com"
}
```

### 1.10 Reset Password
```
POST /auth/reset-password
```
**Request Body:**
```json
{
  "token": "reset_token_from_email",
  "new_password": "newPassword123"
}
```

### 1.11 Verify Email
```
POST /auth/verify-email
```
**Request Body:**
```json
{
  "token": "verification_token"
}
```

### 1.12 OAuth - Google
```
GET /auth/google
POST /auth/google/callback
```

### 1.13 OAuth - GitHub
```
GET /auth/github
POST /auth/github/callback
```

### 1.14 OAuth - Facebook
```
GET /auth/facebook
POST /auth/facebook/callback
```

### 1.15 Link OAuth
```
GET /auth/link/:provider
POST /auth/link/:provider/callback
```
🔒 **Auth Required**

### 1.16 Get Active Sessions
```
GET /auth/sessions
```
🔒 **Auth Required**

### 1.17 Revoke Session
```
DELETE /auth/sessions/:id
```
🔒 **Auth Required**

---

## 2. User Management

### 2.1 Get My System Roles
```
GET /me/system-roles
```
🔒 **Auth Required**

### 2.2 Get My Organization Roles
```
GET /me/org-roles
```
🔒 **Auth Required**

### 2.3 Get My Children (Parent)
```
GET /me/children
```
🔒 **Auth Required**

### 2.4 Get My Organizations
```
GET /me/organizations
```
🔒 **Auth Required**

### 2.5 Get User Public Profile
```
GET /users/:id/public-profile
```

### 2.6 Get User System Roles (Admin)
```
GET /users/:user_id/system-roles
POST /users/:user_id/system-roles
DELETE /users/:user_id/system-roles/:system_role_id
```
🔒 **Auth Required**

### 2.7 Privacy Settings
```
GET /preferences/privacy
PUT /preferences/privacy
```
🔒 **Auth Required**

---

## 3. Course & Learning

### 3.1 Categories

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/categories` | ❌ | Lấy danh sách categories |
| GET | `/categories/:id` | ❌ | Lấy category theo ID |
| POST | `/categories` | ✅ | Tạo category mới |
| PUT | `/categories/:id` | ✅ | Cập nhật category |
| DELETE | `/categories/:id` | ✅ | Xóa category |

### 3.2 Tags

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/tags` | ❌ | Lấy danh sách tags |
| GET | `/tags/:id` | ❌ | Lấy tag theo ID |
| POST | `/tags` | ✅ | Tạo tag mới |
| PUT | `/tags/:id` | ✅ | Cập nhật tag |
| DELETE | `/tags/:id` | ✅ | Xóa tag |

### 3.3 Courses

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/courses` | ❌ | Lấy danh sách khóa học |
| GET | `/courses/:slug` | ❌ | Lấy khóa học theo slug |
| POST | `/courses` | ✅ | Tạo khóa học mới |
| PUT | `/courses/:id` | ✅ | Cập nhật khóa học |
| DELETE | `/courses/:id` | ✅ | Xóa khóa học |
| GET | `/courses/me` | ✅ | Khóa học của tôi (teacher) |

**Query Parameters cho GET /courses:**
- `page` (int): Trang hiện tại
- `page_size` (int): Số lượng mỗi trang
- `category_id` (uuid): Lọc theo category
- `keyword` (string): Tìm kiếm
- `sort_by` (string): created_at, price, rating
- `sort_order` (string): asc, desc

### 3.4 Sections

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/courses/:courseId/sections` | ❌ | Lấy sections của khóa học |
| POST | `/courses/:courseId/sections` | ✅ | Tạo section mới |
| PUT | `/courses/:courseId/sections/:id` | ✅ | Cập nhật section |
| DELETE | `/courses/:courseId/sections/:id` | ✅ | Xóa section |
| PUT | `/courses/:courseId/sections/reorder` | ✅ | Sắp xếp lại sections |

### 3.5 Lessons

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/sections/:sectionId/lessons` | ❌ | Lấy lessons của section |
| GET | `/lessons/:id` | ❌ | Lấy lesson theo ID |
| POST | `/sections/:sectionId/lessons` | ✅ | Tạo lesson mới |
| PUT | `/lessons/:id` | ✅ | Cập nhật lesson |
| DELETE | `/lessons/:id` | ✅ | Xóa lesson |
| PUT | `/sections/:sectionId/lessons/reorder` | ✅ | Sắp xếp lại lessons |

### 3.6 Lesson Contents

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/lessons/:lessonId/contents` | ❌ | Lấy nội dung lesson |
| POST | `/lessons/:lessonId/contents` | ✅ | Thêm nội dung |
| PUT | `/lessons/:lessonId/contents/:id` | ✅ | Cập nhật nội dung |
| DELETE | `/lessons/:lessonId/contents/:id` | ✅ | Xóa nội dung |
| PUT | `/lessons/:lessonId/contents/reorder` | ✅ | Sắp xếp lại |

### 3.7 Enrollments

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/courses/:courseId/enroll` | ✅ | Ghi danh khóa học |
| POST | `/courses/:courseId/unenroll` | ✅ | Hủy ghi danh |
| GET | `/enrollments/me` | ✅ | Khóa học đã ghi danh |
| GET | `/enrollments/me/:courseId` | ✅ | Chi tiết enrollment |
| POST | `/lessons/:lessonId/progress` | ✅ | Cập nhật tiến độ |
| GET | `/lessons/:lessonId/progress` | ✅ | Lấy tiến độ lesson |

### 3.8 Reviews

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/courses/:courseId/reviews` | ❌ | Lấy reviews khóa học |
| POST | `/courses/:courseId/reviews` | ✅ | Viết review |
| PUT | `/reviews/:id` | ✅ | Cập nhật review |
| DELETE | `/reviews/:id` | ✅ | Xóa review |
| POST | `/reviews/:id/reaction` | ✅ | React review (helpful) |
| DELETE | `/reviews/:id/reaction` | ✅ | Bỏ reaction |

---

## 4. Class Management

### 4.1 Classes

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes` | ❌ | Danh sách lớp học |
| GET | `/classes/:id` | ❌ | Chi tiết lớp học |
| GET | `/classes/me` | ✅ | Lớp học của tôi |
| POST | `/classes` | ✅ | Tạo lớp học |
| PUT | `/classes/:id` | ✅ | Cập nhật lớp |
| DELETE | `/classes/:id` | ✅ | Xóa lớp |

### 4.2 Class Teachers

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:id/teachers` | ❌ | Danh sách GV của lớp |
| POST | `/classes/:id/teachers` | ✅ | Thêm GV vào lớp |
| DELETE | `/classes/:id/teachers/:teacherId` | ✅ | Xóa GV khỏi lớp |

### 4.3 Class Students

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:id/students` | ❌ | Danh sách HS của lớp |
| POST | `/classes/:id/students` | ✅ | Thêm HS vào lớp |
| DELETE | `/classes/:id/students/:studentId` | ✅ | Xóa HS khỏi lớp |

### 4.4 Class Attendances

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:classId/attendances` | ✅ | Danh sách điểm danh |
| GET | `/classes/:classId/attendances/:id` | ✅ | Chi tiết điểm danh |
| POST | `/classes/:classId/attendances` | ✅ | Điểm danh |
| PUT | `/classes/:classId/attendances/:id` | ✅ | Cập nhật điểm danh |
| DELETE | `/classes/:classId/attendances/:id` | ✅ | Xóa điểm danh |

---

## 5. Quiz & Assessment

### 5.1 Quiz CRUD

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/quizzes` | ✅ | Danh sách quiz |
| GET | `/quizzes/:id` | ✅ | Chi tiết quiz |
| POST | `/quizzes` | ✅ | Tạo quiz |
| PUT | `/quizzes/:id` | ✅ | Cập nhật quiz |
| DELETE | `/quizzes/:id` | ✅ | Xóa quiz |
| POST | `/quizzes/:id/duplicate` | ✅ | Nhân bản quiz |

### 5.2 Questions

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/quizzes/:quizId/questions` | ✅ | Danh sách câu hỏi |
| POST | `/quizzes/:quizId/questions` | ✅ | Tạo câu hỏi |
| PUT | `/quizzes/:quizId/questions/:id` | ✅ | Cập nhật câu hỏi |
| DELETE | `/quizzes/:quizId/questions/:id` | ✅ | Xóa câu hỏi |
| PUT | `/quizzes/:quizId/questions/reorder` | ✅ | Sắp xếp câu hỏi |
| POST | `/quizzes/:quizId/questions/bulk` | ✅ | Tạo nhiều câu hỏi |

### 5.3 Quiz Attempts

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/quizzes/:id/start` | ✅ | Bắt đầu làm quiz |
| POST | `/quizzes/:id/submit` | ✅ | Nộp bài quiz |
| GET | `/quizzes/:id/attempts` | ✅ | Lịch sử làm bài |
| GET | `/quizzes/:id/attempts/:attemptId` | ✅ | Chi tiết attempt |
| GET | `/quizzes/:id/results` | ✅ | Kết quả quiz |
| GET | `/quizzes/:id/statistics` | ✅ | Thống kê quiz |

### 5.4 Quiz In Progress

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/attempts/:attemptId/save-answer` | ✅ | Lưu câu trả lời |
| GET | `/attempts/:attemptId/progress` | ✅ | Tiến độ làm bài |

### 5.5 My Quizzes

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/me/quizzes` | ✅ | Quiz tôi tạo |
| GET | `/me/quiz-history` | ✅ | Lịch sử làm quiz |

---

## 6. Exercise & Coding

### 6.1 Exercise CRUD

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/exercises` | ✅ | Danh sách bài tập |
| GET | `/exercises/:id` | ✅ | Chi tiết bài tập |
| POST | `/exercises` | ✅ | Tạo bài tập |
| PUT | `/exercises/:id` | ✅ | Cập nhật bài tập |
| DELETE | `/exercises/:id` | ✅ | Xóa bài tập |

### 6.2 Test Cases

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/exercises/:id/testcases` | ✅ | Danh sách test cases |
| POST | `/exercises/:id/testcases` | ✅ | Tạo test case |
| POST | `/exercises/:id/testcases/import` | ✅ | Import test cases |
| DELETE | `/exercises/:id/testcases/:testCaseId` | ✅ | Xóa test case |

### 6.3 Submissions

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/exercises/:id/submit` | ✅ | Nộp bài |
| GET | `/exercises/:id/submissions` | ✅ | Tất cả submissions |
| GET | `/exercises/:id/my-submissions` | ✅ | Submissions của tôi |
| GET | `/submissions/:submissionId` | ✅ | Chi tiết submission |

### 6.4 Content Progress

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/content-progress` | ✅ | Cập nhật tiến độ |
| GET | `/content-progress/:lessonContentId` | ✅ | Lấy tiến độ |

---

## 7. Grade Management

### 7.1 Grade Columns

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:classId/grade-columns` | ✅ | Danh sách cột điểm |
| POST | `/classes/:classId/grade-columns` | ✅ | Tạo cột điểm |
| PUT | `/classes/:classId/grade-columns/:id` | ✅ | Cập nhật cột điểm |
| DELETE | `/classes/:classId/grade-columns/:id` | ✅ | Xóa cột điểm |
| PUT | `/classes/:classId/grade-columns/reorder` | ✅ | Sắp xếp cột điểm |

### 7.2 Grades

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:classId/grades` | ✅ | Bảng điểm lớp |
| GET | `/classes/:classId/grades/student/:studentId` | ✅ | Điểm của HS |
| POST | `/classes/:classId/grades` | ✅ | Nhập điểm |
| POST | `/classes/:classId/grades/bulk` | ✅ | Nhập điểm hàng loạt |
| PUT | `/grades/:id` | ✅ | Cập nhật điểm |
| DELETE | `/grades/:id` | ✅ | Xóa điểm |

### 7.3 Final Grades

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:classId/final-grades` | ✅ | Điểm tổng kết |
| POST | `/classes/:classId/final-grades/calculate` | ✅ | Tính điểm TK |
| PUT | `/classes/:classId/final-grades/:id` | ✅ | Cập nhật điểm TK |
| POST | `/classes/:classId/final-grades/finalize` | ✅ | Chốt điểm |

### 7.4 My Grades

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/me/grades` | ✅ | Tất cả điểm của tôi |
| GET | `/me/grades/class/:classId` | ✅ | Điểm theo lớp |

---

## 8. Cart & Order

### 8.1 Cart

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/cart` | ✅ | Lấy giỏ hàng |
| POST | `/cart/items` | ✅ | Thêm vào giỏ |
| DELETE | `/cart/items/:courseId` | ✅ | Xóa khỏi giỏ |
| DELETE | `/cart` | ✅ | Xóa toàn bộ giỏ |

**Request Body - Thêm vào giỏ:**
```json
{
  "course_id": "uuid",
  "voucher_code": "DISCOUNT10"
}
```

### 8.2 Orders

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/orders` | ✅ | Danh sách đơn hàng |
| GET | `/orders/:id` | ✅ | Chi tiết đơn hàng |
| POST | `/orders` | ✅ | Tạo đơn hàng |
| POST | `/orders/:id/cancel` | ✅ | Hủy đơn hàng |
| POST | `/orders/:id/retry` | ✅ | Thử lại thanh toán |

**Request Body - Tạo đơn hàng:**
```json
{
  "items": [
    {"course_id": "uuid", "voucher_code": "DISCOUNT10"}
  ],
  "payment_method": "banking"
}
```

### 8.3 Payments

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/orders/:id/payments` | ✅ | Tạo thanh toán |
| GET | `/orders/:id/payments/:paymentId` | ✅ | Chi tiết payment |
| POST | `/orders/:id/payments/:paymentId/verify` | ✅ | Xác nhận TT |

---

## 9. Voucher

### 9.1 Voucher CRUD (Admin)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/vouchers` | ✅ | Danh sách voucher |
| GET | `/vouchers/:id` | ✅ | Chi tiết voucher |
| POST | `/vouchers` | ✅ | Tạo voucher |
| PUT | `/vouchers/:id` | ✅ | Cập nhật voucher |
| DELETE | `/vouchers/:id` | ✅ | Xóa voucher |
| POST | `/vouchers/:id/restore` | ✅ | Khôi phục voucher |
| POST | `/vouchers/:id/activate` | ✅ | Kích hoạt |
| POST | `/vouchers/:id/deactivate` | ✅ | Vô hiệu hóa |

### 9.2 User Vouchers

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/vouchers/public` | ❌ | Voucher công khai |
| GET | `/vouchers/code/:code` | ✅ | Tìm theo code |
| GET | `/vouchers/me` | ✅ | Voucher đã lưu |
| POST | `/vouchers/:id/save` | ✅ | Lưu voucher |
| DELETE | `/vouchers/:id/save` | ✅ | Bỏ lưu voucher |
| GET | `/vouchers/:id/stats` | ✅ | Thống kê voucher |

---

## 10. Wallet & Coins

### 10.1 Student Wallet

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/wallet` | ✅ | Thông tin ví |
| GET | `/wallet/transactions` | ✅ | Lịch sử GD |
| POST | `/wallet/deposit` | ✅ | Nạp tiền |
| POST | `/wallet/withdraw` | ✅ | Rút tiền |
| POST | `/wallet/transfer` | ✅ | Chuyển tiền |

### 10.2 Teacher Earnings

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/earnings` | ✅ | Thu nhập |
| GET | `/earnings/summary` | ✅ | Tổng quan TN |
| POST | `/earnings/withdraw` | ✅ | Rút tiền |

### 10.3 Coins

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/coins/packages` | ❌ | Gói xu |
| GET | `/coins/packages/:id` | ❌ | Chi tiết gói |
| GET | `/coins/wallet` | ✅ | Ví xu |
| GET | `/coins/wallet/transactions` | ✅ | Lịch sử xu |
| POST | `/coins/purchases` | ✅ | Mua xu |
| GET | `/coins/purchases` | ✅ | Lịch sử mua |
| GET | `/coins/purchases/:id` | ✅ | Chi tiết mua |
| POST | `/coins/purchases/:id/verify` | ✅ | Xác nhận mua |
| POST | `/coins/gift` | ✅ | Tặng xu |

### 10.4 Coins Admin

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/coins/admin/packages` | ✅ | Tạo gói xu |
| PUT | `/coins/admin/packages/:id` | ✅ | Cập nhật gói |
| DELETE | `/coins/admin/packages/:id` | ✅ | Xóa gói |
| POST | `/coins/admin/adjust` | ✅ | Điều chỉnh xu |

---

## 11. Notification

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/notifications` | ✅ | Danh sách thông báo |
| GET | `/notifications/:id` | ✅ | Chi tiết thông báo |
| POST | `/notifications/:id/read` | ✅ | Đánh dấu đã đọc |
| POST | `/notifications/read-all` | ✅ | Đọc tất cả |
| DELETE | `/notifications/:id` | ✅ | Xóa thông báo |
| GET | `/notifications/unread-count` | ✅ | Số chưa đọc |
| GET | `/notifications/settings` | ✅ | Cài đặt TB |
| PUT | `/notifications/settings` | ✅ | Cập nhật cài đặt |

**WebSocket:** `ws://localhost:3000/ws/notifications`

---

## 12. Messaging

### 12.1 Conversations

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/conversations` | ✅ | Danh sách hội thoại |
| GET | `/conversations/:id` | ✅ | Chi tiết hội thoại |
| POST | `/conversations/direct` | ✅ | Tạo chat trực tiếp |
| POST | `/conversations/:id/read` | ✅ | Đánh dấu đã đọc |
| POST | `/conversations/:id/mute` | ✅ | Tắt thông báo |
| POST | `/conversations/:id/unmute` | ✅ | Bật thông báo |
| POST | `/conversations/:id/pin` | ✅ | Ghim hội thoại |
| POST | `/conversations/:id/unpin` | ✅ | Bỏ ghim |

### 12.2 Messages

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/conversations/:id/messages` | ✅ | Tin nhắn trong HT |
| POST | `/conversations/:id/messages` | ✅ | Gửi tin nhắn |
| PUT | `/conversations/:id/messages/:messageId` | ✅ | Sửa tin nhắn |
| DELETE | `/conversations/:id/messages/:messageId` | ✅ | Xóa tin nhắn |
| POST | `/conversations/:id/messages/:messageId/pin` | ✅ | Ghim tin |
| POST | `/conversations/:id/messages/:messageId/unpin` | ✅ | Bỏ ghim tin |

### 12.3 Reactions

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/conversations/:id/messages/:messageId/reactions` | ✅ | Thêm reaction |
| DELETE | `/conversations/:id/messages/:messageId/reactions/:emoji` | ✅ | Bỏ reaction |

### 12.4 Global Messages

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/messages/search` | ✅ | Tìm kiếm tin nhắn |
| GET | `/messages/unread` | ✅ | Số tin chưa đọc |

---

## 13. Livestream

### 13.1 Livestream Session

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/livestream` | ✅ | Danh sách phiên |
| GET | `/livestream/:id` | ✅ | Chi tiết phiên |
| POST | `/livestream` | ✅ | Tạo phiên |
| PUT | `/livestream/:id` | ✅ | Cập nhật phiên |
| DELETE | `/livestream/:id` | ✅ | Xóa phiên |
| POST | `/livestream/:id/start` | ✅ | Bắt đầu live |
| POST | `/livestream/:id/end` | ✅ | Kết thúc live |
| POST | `/livestream/:id/join` | ✅ | Tham gia |
| POST | `/livestream/:id/leave` | ✅ | Rời khỏi |
| GET | `/livestream/:id/participants` | ✅ | DS người tham gia |
| POST | `/livestream/:id/mute` | ✅ | Tắt mic người |
| POST | `/livestream/:id/kick` | ✅ | Đuổi người |

### 13.2 Whiteboard

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/livestream/:id/lock-whiteboard` | ✅ | Khóa whiteboard |
| POST | `/livestream/:id/unlock-whiteboard` | ✅ | Mở khóa |
| GET | `/whiteboard/:sessionId/snapshot` | ✅ | Lấy snapshot |
| POST | `/whiteboard/:sessionId/snapshot` | ✅ | Lưu snapshot |
| POST | `/whiteboard/:sessionId/event` | ✅ | Broadcast event |

### 13.3 Screen Share

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/livestream/:id/screenshare/start` | ✅ | Bắt đầu share |
| POST | `/livestream/:id/screenshare/stop` | ✅ | Dừng share |

### 13.4 Livestream Chat

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/chat/send` | ✅ | Gửi tin nhắn |
| GET | `/chat/:sessionId/messages` | ✅ | Lịch sử chat |
| DELETE | `/chat/:id` | ✅ | Xóa tin nhắn |
| POST | `/chat/:id/pin` | ✅ | Ghim tin |
| POST | `/chat/:id/unpin` | ✅ | Bỏ ghim |

### 13.5 Analytics

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/analytics/livestream/:sessionId` | ✅ | Thống kê phiên |
| GET | `/analytics/assignment/:assignmentId` | ✅ | Thống kê bài tập |
| GET | `/analytics/participants/:sessionId` | ✅ | Thống kê người |

---

## 14. Video Upload & HLS

### 14.1 Video Upload

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/videos/upload/init` | ✅ | Khởi tạo upload |
| POST | `/videos/upload/presigned-urls` | ✅ | Lấy URLs cho chunks |
| POST | `/videos/upload/chunk-complete` | ✅ | Đánh dấu chunk xong |
| POST | `/videos/upload/complete` | ✅ | Hoàn tất upload |
| GET | `/videos/upload/:upload_id/status` | ✅ | Trạng thái upload |
| GET | `/videos/upload/:upload_id/resume` | ✅ | Thông tin resume |
| GET | `/videos/upload/incomplete` | ✅ | DS upload dở |
| DELETE | `/videos/upload/:upload_id` | ✅ | Hủy upload |
| POST | `/videos/upload/:upload_id/reprocess` | ✅ | Xử lý lại video |
| GET | `/videos/processing/queue` | ✅ | Hàng đợi xử lý |
| GET | `/videos/health` | ❌ | Health check |

### 14.2 HLS Streaming (Public)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/hls/:upload_id/info` | ❌ | Thông tin video |
| GET | `/hls/:upload_id/master.m3u8` | ❌ | Master playlist |
| GET | `/hls/:upload_id/video.mp4` | ❌ | Video gốc |
| GET | `/hls/:upload_id/:quality/index.m3u8` | ❌ | Quality playlist |
| GET | `/hls/:upload_id/:quality/:segment` | ❌ | Video segment |

---

## 15. Groups & Community

### 15.1 Groups

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/groups` | ❌ | Danh sách nhóm |
| GET | `/groups/:slug` | ❌ | Chi tiết nhóm |
| GET | `/groups/me/joined` | ✅ | Nhóm đã tham gia |
| GET | `/groups/me/owned` | ✅ | Nhóm tôi quản lý |
| POST | `/groups` | ✅ | Tạo nhóm |
| PUT | `/groups/:id` | ✅ | Cập nhật nhóm |
| DELETE | `/groups/:id` | ✅ | Xóa nhóm |
| POST | `/groups/:id/join` | ✅ | Tham gia nhóm |
| POST | `/groups/:id/leave` | ✅ | Rời nhóm |

### 15.2 Group Members

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/groups/:id/members` | ✅ | DS thành viên |
| POST | `/groups/:id/members/invite` | ✅ | Mời thành viên |
| PUT | `/groups/:id/members/:userId/role` | ✅ | Đổi role |
| DELETE | `/groups/:id/members/:userId` | ✅ | Xóa thành viên |
| POST | `/groups/:id/members/:userId/ban` | ✅ | Cấm thành viên |
| POST | `/groups/:id/members/:userId/unban` | ✅ | Bỏ cấm |

### 15.3 Join Requests

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/groups/:id/requests` | ✅ | DS yêu cầu tham gia |
| POST | `/groups/:id/requests/:requestId/approve` | ✅ | Duyệt yêu cầu |
| POST | `/groups/:id/requests/:requestId/reject` | ✅ | Từ chối |

### 15.4 Discussions

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/discussions` | ❌ | Danh sách bài viết |
| GET | `/discussions/:slug` | ❌ | Chi tiết bài viết |
| POST | `/discussions` | ✅ | Tạo bài viết |
| POST | `/discussions/:slug/comments` | ✅ | Bình luận |
| POST | `/discussions/:id/vote` | ✅ | Vote bài viết |
| DELETE | `/discussions/:id/vote` | ✅ | Bỏ vote |
| DELETE | `/discussions/:id` | ✅ | Xóa bài viết |

---

## 16. Gamification

### 16.1 Achievements

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/achievements` | ❌ | DS thành tích |
| GET | `/achievements/me` | ✅ | Thành tích của tôi |
| POST | `/achievements/:id/unlock` | ✅ | Mở khóa (internal) |

### 16.2 Leaderboard

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/leaderboard` | ❌ | Bảng xếp hạng |
| GET | `/leaderboard/me` | ✅ | Thứ hạng của tôi |

---

## 17. Schedule & Attendance

### 17.1 Class Schedules

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:classId/schedules` | ✅ | Lịch học định kỳ |
| GET | `/classes/:classId/schedules/:id` | ✅ | Chi tiết lịch |
| POST | `/classes/:classId/schedules` | ✅ | Tạo lịch học |
| PUT | `/classes/:classId/schedules/:id` | ✅ | Cập nhật lịch |
| DELETE | `/classes/:classId/schedules/:id` | ✅ | Xóa lịch |
| GET | `/classes/:classId/timetable` | ✅ | Thời khóa biểu |

### 17.2 Class Sessions

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/classes/:classId/sessions` | ✅ | DS buổi học |
| GET | `/classes/:classId/sessions/:id` | ✅ | Chi tiết buổi |
| POST | `/classes/:classId/sessions` | ✅ | Tạo buổi học |
| PUT | `/classes/:classId/sessions/:id` | ✅ | Cập nhật buổi |
| DELETE | `/classes/:classId/sessions/:id` | ✅ | Hủy buổi |
| POST | `/classes/:classId/sessions/generate` | ✅ | Tạo tự động |

### 17.3 Session Attendance

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/sessions/:sessionId/attendances` | ✅ | DS điểm danh |
| POST | `/sessions/:sessionId/attendances` | ✅ | Điểm danh |
| POST | `/sessions/:sessionId/attendances/bulk` | ✅ | Điểm danh hàng loạt |
| PUT | `/sessions/:sessionId/attendances/:id` | ✅ | Cập nhật |
| POST | `/sessions/:sessionId/check-in` | ✅ | HS tự check-in |
| POST | `/sessions/:sessionId/check-out` | ✅ | HS check-out |

### 17.4 My Schedule

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/me/timetable` | ✅ | TKB của tôi |
| GET | `/me/attendances` | ✅ | Lịch sử điểm danh |

### 17.5 Reminder Settings

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/reminders/settings` | ✅ | Cài đặt nhắc nhở |
| PUT | `/reminders/settings` | ✅ | Cập nhật cài đặt |

---

## 18. Certificate

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/certificates/verify/:number` | ❌ | Xác minh chứng chỉ |
| GET | `/certificates` | ✅ | Chứng chỉ của tôi |
| GET | `/certificates/:id` | ✅ | Chi tiết chứng chỉ |
| POST | `/certificates` | ✅ | Cấp chứng chỉ |

---

## 19. Parent Dashboard

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/parent/children/:id/overview` | ✅ | Tổng quan con |
| GET | `/parent/children/:id/courses` | ✅ | Khóa học con |
| GET | `/parent/children/:id/grades` | ✅ | Điểm con |
| GET | `/parent/children/:id/schedule` | ✅ | Lịch học con |
| GET | `/parent/children/:id/timetable` | ✅ | TKB con |
| GET | `/parent/children/:id/attendance` | ✅ | Điểm danh con |
| GET | `/parent/children/:id/assignments` | ✅ | Bài tập con |

### Parent Invitations

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/invitations/validate/:token` | ❌ | Validate token |
| POST | `/invitations/invite` | ✅ | Mời phụ huynh |
| GET | `/invitations/pending` | ✅ | Lời mời đang chờ |
| GET | `/invitations/sent` | ✅ | Lời mời đã gửi |
| POST | `/invitations/:id/respond` | ✅ | Phản hồi lời mời |
| POST | `/invitations/:id/revoke` | ✅ | Hủy lời mời |

---

## 20. Reports

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/reports` | ✅ | DS báo cáo |
| GET | `/reports/my` | ✅ | Báo cáo của tôi |
| GET | `/reports/:id` | ✅ | Chi tiết báo cáo |
| POST | `/reports` | ✅ | Tạo báo cáo |
| PUT | `/reports/:id/status` | ✅ | Cập nhật trạng thái |
| DELETE | `/reports/:id` | ✅ | Xóa báo cáo |

---

## 21. Organization & Roles

### 21.1 Organizations

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/organizations` | ❌ | DS tổ chức |
| GET | `/organizations/:id` | ❌ | Chi tiết tổ chức |
| POST | `/organizations` | ✅ | Tạo tổ chức |
| PUT | `/organizations/:id` | ✅ | Cập nhật |
| DELETE | `/organizations/:id` | ✅ | Xóa tổ chức |
| GET | `/organizations/:organization_id/members` | ✅ | Thành viên |
| GET | `/organizations/:organization_id/roles/:role_id/users` | ✅ | Users theo role |

### 21.2 System Roles

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/system-roles` | ❌ | DS system roles |
| GET | `/system-roles/:id` | ✅ | Chi tiết role |
| POST | `/system-roles` | ✅ | Tạo role |
| PUT | `/system-roles/:id` | ✅ | Cập nhật role |
| DELETE | `/system-roles/:id` | ✅ | Xóa role |
| PATCH | `/system-roles/:id/restore` | ✅ | Khôi phục |
| GET | `/system-roles/:id/permissions` | ✅ | Permissions của role |
| POST | `/system-roles/:id/permissions` | ✅ | Thêm permissions |
| PUT | `/system-roles/:id/permissions` | ✅ | Set permissions |
| DELETE | `/system-roles/:id/permissions` | ✅ | Xóa permissions |
| GET | `/system-roles/:system_role_id/users` | ✅ | Users có role |

### 21.3 Organization Roles

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/org-roles` | ✅ | DS org roles |
| GET | `/org-roles/:id` | ✅ | Chi tiết role |
| POST | `/org-roles` | ✅ | Tạo role |
| PUT | `/org-roles/:id` | ✅ | Cập nhật |
| DELETE | `/org-roles/:id` | ✅ | Xóa role |
| PATCH | `/org-roles/:id/restore` | ✅ | Khôi phục |
| GET | `/org-roles/:id/permissions` | ✅ | Permissions |
| POST | `/org-roles/:id/permissions` | ✅ | Thêm |
| PUT | `/org-roles/:id/permissions` | ✅ | Set |
| DELETE | `/org-roles/:id/permissions` | ✅ | Xóa |
| GET | `/org-roles/:role_id/users` | ✅ | Users có role |

### 21.4 Permissions

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/permissions` | ✅ | DS permissions |
| GET | `/permissions/:id` | ✅ | Chi tiết |
| PUT | `/permissions/:id` | ✅ | Cập nhật |

### 21.5 User Roles

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/users/:user_id/org-roles` | ✅ | Org roles của user |
| POST | `/users/:user_id/org-roles` | ✅ | Gán org role |
| DELETE | `/users/:user_id/org-roles/:org_role_id` | ✅ | Gỡ org role |

### 21.6 Teachers

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/teachers` | ❌ | DS giáo viên |
| GET | `/teachers/:id` | ❌ | Chi tiết GV |
| GET | `/teachers/me/students` | ✅ | Học sinh của tôi |
| DELETE | `/teachers/:id` | ✅ | Xóa GV |

### 21.7 Teacher Profiles

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/teacher-profiles` | ❌ | DS hồ sơ GV |
| GET | `/teacher-profiles/:id` | ❌ | Chi tiết hồ sơ |
| POST | `/teacher-profiles` | ✅ | Tạo hồ sơ |
| PUT | `/teacher-profiles/:id` | ✅ | Cập nhật |
| DELETE | `/teacher-profiles/:id` | ✅ | Xóa hồ sơ |

---

## 22. File Upload

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/upload` | ✅ | Upload ảnh |
| POST | `/upload/any` | ✅ | Upload file bất kỳ |
| DELETE | `/upload?url=...` | ✅ | Xóa file |

---

## 23. Assignments (Livestream Coding)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/assignments` | ✅ | DS bài tập |
| GET | `/assignments/:id` | ✅ | Chi tiết bài tập |
| GET | `/assignments/:id/sandbox` | ✅ | Sandbox code |
| POST | `/assignments` | ✅ | Tạo bài tập |
| PUT | `/assignments/:id` | ✅ | Cập nhật |
| DELETE | `/assignments/:id` | ✅ | Xóa |
| POST | `/assignments/:id/publish` | ✅ | Publish |
| POST | `/assignments/:id/unpublish` | ✅ | Unpublish |
| GET | `/assignments/:id/testcases` | ✅ | Test cases |
| POST | `/assignments/:id/testcases` | ✅ | Thêm test case |
| POST | `/assignments/:id/testcases/import` | ✅ | Import test cases |
| DELETE | `/assignments/:id/testcases/:tcId` | ✅ | Xóa test case |

---

## 24. Submissions (Code Execution)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/submissions` | ✅ | Nộp bài |
| POST | `/submissions/run` | ✅ | Chạy code |
| POST | `/submissions/run-custom` | ✅ | Chạy với input custom |
| POST | `/submissions/execute` | ✅ | Free sandbox |
| GET | `/submissions/:id` | ✅ | Chi tiết submission |
| GET | `/submissions/assignment/:assignmentId` | ✅ | Submissions của bài |
| GET | `/submissions/my/:assignmentId` | ✅ | Submissions của tôi |
| GET | `/submissions/user/:userId` | ✅ | Submissions của user |

---

## 25. Contests

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/contests` | ❌ | DS cuộc thi |
| GET | `/contests/:slug` | ❌ | Chi tiết cuộc thi |
| GET | `/contests/me` | ✅ | Cuộc thi của tôi |
| POST | `/contests` | ✅ | Tạo cuộc thi |
| PUT | `/contests/:id` | ✅ | Cập nhật |
| DELETE | `/contests/:id` | ✅ | Xóa |
| POST | `/contests/:id/publish` | ✅ | Publish |
| GET | `/contests/:id/problems` | ✅ | Danh sách đề |
| POST | `/contests/:id/problems` | ✅ | Thêm đề |
| PUT | `/contests/:id/problems/:problemId` | ✅ | Cập nhật đề |
| DELETE | `/contests/:id/problems/:problemId` | ✅ | Xóa đề |
| POST | `/contests/:id/join` | ✅ | Tham gia |
| GET | `/contests/:id/leaderboard` | ✅ | Bảng xếp hạng |
| POST | `/contests/:id/problems/:problemId/submit` | ✅ | Nộp bài |
| GET | `/contests/:id/submissions/me` | ✅ | Bài nộp của tôi |

---

## 26. Personal Events

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/me/events` | ✅ | Sự kiện cá nhân |
| POST | `/me/events` | ✅ | Tạo sự kiện |
| PUT | `/me/events/:id` | ✅ | Cập nhật |
| DELETE | `/me/events/:id` | ✅ | Xóa |

---

## WebSocket Endpoints

| Endpoint | Purpose |
|----------|---------|
| `ws://localhost:3000/ws/notifications` | Real-time notifications |
| `ws://localhost:3000/ws/messages` | Real-time messaging |
| `ws://localhost:3000/ws/livestream/:sessionId` | Livestream events |

---

## Common Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | int | Trang hiện tại (default: 1) |
| `page_size` | int | Số lượng/trang (default: 20, max: 100) |
| `limit` | int | Alias của page_size |
| `offset` | int | Bỏ qua N records đầu |
| `sort_by` | string | Field để sort |
| `sort_order` | string | asc / desc |
| `keyword` | string | Từ khóa tìm kiếm |
| `status` | string | Lọc theo trạng thái |

---

## Error Codes

| Code | Description |
|------|-------------|
| `ERR_INVALID_REQUEST` | Request body không hợp lệ |
| `ERR_VALIDATION` | Validation failed |
| `ERR_UNAUTHORIZED` | Chưa đăng nhập |
| `ERR_FORBIDDEN` | Không có quyền |
| `ERR_NOT_FOUND` | Không tìm thấy resource |
| `ERR_CONFLICT` | Dữ liệu xung đột |
| `ERR_RATE_LIMIT` | Vượt quá giới hạn request |
| `ERR_INTERNAL` | Lỗi server |

---

*Cập nhật: 2026-04-17*
*Generated by Claude Code*
