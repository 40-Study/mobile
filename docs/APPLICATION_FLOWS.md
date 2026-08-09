# APPLICATION FLOWS - Hướng Dẫn Tích Hợp API

Tài liệu này mô tả các luồng chính của ứng dụng để FE dễ dàng tích hợp.

---

## 1. Authentication Flow

### 1.1 Đăng ký tài khoản
```
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "Password123!",
  "full_name": "Nguyen Van A"
}

→ Response: { user, access_token, refresh_token }
→ FE: Lưu tokens vào localStorage/cookie
```

### 1.2 Đăng nhập
```
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "Password123!"
}

→ Response: { user, access_token, refresh_token, expires_in }
→ FE: Lưu tokens, set Authorization header
```

### 1.3 Refresh Token (khi access_token hết hạn)
```
POST /api/auth/refresh
{
  "refresh_token": "..."
}

→ Response: { access_token, refresh_token, expires_in }
→ FE: Cập nhật tokens
```

### 1.4 OAuth Login (Google/GitHub/Facebook)
```
1. GET /api/auth/google
   → FE mở popup/redirect đến Google

2. POST /api/auth/google/callback
   { code: "oauth_code_from_google" }

   → Response: { user, access_token, refresh_token }
```

---

## 2. Course Browsing Flow

### 2.1 Trang chủ - Hiển thị khóa học
```
# Lấy categories cho sidebar/filter
GET /api/categories

# Lấy danh sách khóa học
GET /api/courses?page=1&page_size=12&category_id=xxx&sort_by=rating

# Response
{
  "data": [...courses],
  "total": 100,
  "page": 1,
  "total_pages": 9
}
```

### 2.2 Chi tiết khóa học
```
# Lấy thông tin khóa học (bao gồm sections, lessons)
GET /api/courses/khoa-hoc-lap-trinh-go

# Lấy reviews
GET /api/courses/:courseId/reviews?page=1&page_size=10

# Response course
{
  "id": "uuid",
  "title": "Khóa học Lập trình Go",
  "slug": "khoa-hoc-lap-trinh-go",
  "price": 599000,
  "sections": [
    {
      "id": "...",
      "title": "Giới thiệu",
      "lessons": [
        { "id": "...", "title": "Bài 1", "duration": 600, "is_free": true }
      ]
    }
  ]
}
```

### 2.3 Mua khóa học
```
# 1. Thêm vào giỏ hàng
POST /api/cart/items
{ "course_id": "uuid" }

# 2. Xem giỏ hàng
GET /api/cart

# 3. Áp dụng voucher (optional)
# Voucher được áp dụng khi thêm vào cart hoặc tạo order

# 4. Tạo đơn hàng
POST /api/orders
{
  "items": [
    { "course_id": "uuid", "voucher_code": "SALE20" }
  ],
  "payment_method": "banking"
}

# 5. Tạo thanh toán
POST /api/orders/:orderId/payments
{ "payment_method": "banking" }

# 6. Xác nhận thanh toán (sau khi user chuyển tiền)
POST /api/orders/:orderId/payments/:paymentId/verify
{ "transaction_id": "..." }

→ Sau khi verify thành công, user tự động được enroll
```

---

## 3. Learning Flow

### 3.1 Vào học khóa học
```
# Kiểm tra enrollment
GET /api/enrollments/me/:courseId

# Response
{
  "enrolled": true,
  "progress_percentage": 25,
  "last_lesson_id": "uuid"
}
```

### 3.2 Xem bài học
```
# Lấy nội dung lesson (video, text, quiz, exercise)
GET /api/lessons/:lessonId/contents

# Response
{
  "contents": [
    {
      "type": "video",
      "video_url": "/api/hls/:upload_id/master.m3u8"
    },
    {
      "type": "quiz",
      "quiz_id": "uuid"
    }
  ]
}
```

### 3.3 Cập nhật tiến độ
```
# Khi user xem xong video/hoàn thành nội dung
POST /api/lessons/:lessonId/progress
{
  "completed": true,
  "time_spent": 600
}
```

### 3.4 Làm quiz
```
# Bắt đầu quiz
POST /api/quizzes/:id/start

# Response
{
  "attempt_id": "uuid",
  "questions": [...],
  "time_limit": 1800
}

# Lưu câu trả lời (real-time)
POST /api/attempts/:attemptId/save-answer
{
  "question_id": "uuid",
  "answer_ids": ["uuid"]
}

# Nộp bài
POST /api/quizzes/:id/submit
{
  "attempt_id": "uuid"
}

# Response
{
  "score": 8,
  "total": 10,
  "passed": true
}
```

### 3.5 Làm bài tập code
```
# Lấy bài tập
GET /api/exercises/:id

# Chạy thử code
POST /api/exercises/:id/submit
{
  "code": "package main...",
  "language_id": 62
}

# Response (polling hoặc WebSocket)
{
  "status": "accepted",
  "passed_tests": 5,
  "total_tests": 5,
  "execution_time": 0.05
}
```

---

## 4. Video Streaming Flow

### 4.1 Xem video bài học
```
# FE sử dụng HLS.js hoặc Video.js

# 1. Lấy thông tin video
GET /api/hls/:upload_id/info
→ { qualities: ["720p", "480p", "360p"], duration: 600 }

# 2. Load master playlist
GET /api/hls/:upload_id/master.m3u8

# 3. Player tự động chọn quality phù hợp
```

### 4.2 Upload video (cho teacher)
```
# 1. Khởi tạo upload
POST /api/videos/upload/init
{
  "filename": "bai-1.mp4",
  "file_size": 104857600,
  "content_type": "video/mp4"
}

→ { upload_id, chunk_size, total_chunks }

# 2. Lấy presigned URLs
POST /api/videos/upload/presigned-urls
{
  "upload_id": "...",
  "part_numbers": [1, 2, 3, 4, 5]
}

→ { urls: ["https://minio/...?X-Amz-Signature=..."] }

# 3. Upload từng chunk trực tiếp lên MinIO
PUT https://minio/.../part1?... (chunk 1)
PUT https://minio/.../part2?... (chunk 2)
...

# 4. Đánh dấu chunk hoàn thành
POST /api/videos/upload/chunk-complete
{ "upload_id": "...", "part_number": 1, "etag": "..." }

# 5. Hoàn tất upload
POST /api/videos/upload/complete
{ "upload_id": "..." }

→ Video được đưa vào queue xử lý HLS

# 6. Kiểm tra trạng thái
GET /api/videos/upload/:upload_id/status
→ { status: "processing" | "completed" | "failed" }
```

---

## 5. Livestream Flow

### 5.1 Teacher bắt đầu livestream
```
# 1. Tạo phiên livestream
POST /api/livestream
{
  "title": "Buổi học số 1",
  "class_id": "uuid",
  "scheduled_at": "2024-01-15T19:00:00Z"
}

# 2. Bắt đầu phát
POST /api/livestream/:id/start

→ { livekit_token, room_name }

# 3. FE sử dụng LiveKit SDK để kết nối
import { Room } from 'livekit-client';
const room = new Room();
await room.connect(wsUrl, token);
```

### 5.2 Student tham gia
```
# 1. Join phiên
POST /api/livestream/:id/join

→ { livekit_token, room_name }

# 2. Kết nối LiveKit
const room = new Room();
await room.connect(wsUrl, token);

# 3. Nhận video stream từ teacher
room.on('trackSubscribed', (track) => {
  videoElement.srcObject = track.mediaStream;
});
```

### 5.3 Chat trong livestream
```
# Gửi tin nhắn (qua LiveKit Data Channel)
POST /api/chat/send
{
  "session_id": "...",
  "content": "Thầy ơi, em không hiểu phần này"
}

# Lấy lịch sử chat
GET /api/chat/:sessionId/messages?limit=50
```

---

## 6. Notification Flow

### 6.1 Real-time notifications
```
# WebSocket connection
const ws = new WebSocket('ws://localhost:3000/ws/notifications');
ws.onmessage = (event) => {
  const notification = JSON.parse(event.data);
  showNotification(notification);
};
```

### 6.2 REST API
```
# Lấy danh sách thông báo
GET /api/notifications?page=1&page_size=20

# Số thông báo chưa đọc
GET /api/notifications/unread-count
→ { count: 5 }

# Đánh dấu đã đọc
POST /api/notifications/:id/read

# Đọc tất cả
POST /api/notifications/read-all
```

---

## 7. Messaging Flow

### 7.1 Chat 1-1
```
# Tạo/mở conversation với user
POST /api/conversations/direct
{ "user_id": "uuid" }

# Gửi tin nhắn
POST /api/conversations/:id/messages
{ "content": "Xin chào!" }

# Lấy tin nhắn
GET /api/conversations/:id/messages?limit=50&before=timestamp

# React tin nhắn
POST /api/conversations/:id/messages/:messageId/reactions
{ "emoji": "👍" }
```

### 7.2 Real-time messaging
```
# WebSocket
const ws = new WebSocket('ws://localhost:3000/ws/messages');

# Nhận tin nhắn mới
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  if (message.type === 'new_message') {
    addMessageToUI(message.data);
  }
};
```

---

## 8. Payment Integration

### 8.1 Thanh toán Banking
```
# 1. Tạo order
POST /api/orders
{ items: [...], payment_method: "banking" }

→ {
  order_id: "...",
  total: 599000,
  bank_info: {
    bank: "VietComBank",
    account: "1234567890",
    name: "CONG TY ABC",
    content: "STUDY ORDER123"
  }
}

# 2. User chuyển tiền manual

# 3. FE poll hoặc webhook để check
GET /api/orders/:id
→ { status: "processing" | "completed" }
```

### 8.2 Thanh toán Wallet
```
# 1. Check balance
GET /api/wallet
→ { balance: 1000000 }

# 2. Tạo order với wallet
POST /api/orders
{
  items: [...],
  payment_method: "wallet"
}

→ Tự động trừ tiền từ ví
```

---

## 9. Teacher Dashboard Flow

### 9.1 Quản lý khóa học
```
# Lấy khóa học của tôi
GET /api/courses/me

# Tạo khóa học mới
POST /api/courses
{
  "title": "Khóa học ABC",
  "description": "...",
  "price": 599000,
  "category_id": "uuid"
}

# Thêm section
POST /api/courses/:courseId/sections
{ "title": "Chương 1: Giới thiệu" }

# Thêm lesson
POST /api/sections/:sectionId/lessons
{
  "title": "Bài 1: Hello World",
  "content_type": "video"
}

# Upload video cho lesson
→ Xem Video Upload Flow
```

### 9.2 Quản lý lớp học
```
# Tạo lớp từ khóa học
POST /api/classes
{
  "course_id": "uuid",
  "name": "Lớp Go K1",
  "start_date": "2024-01-15",
  "end_date": "2024-04-15"
}

# Thêm học sinh
POST /api/classes/:id/students
{ "student_id": "uuid" }

# Xem bảng điểm
GET /api/classes/:classId/grades
```

---

## 10. Parent Dashboard Flow

```
# Lấy danh sách con
GET /api/me/children

# Xem tổng quan của con
GET /api/parent/children/:childId/overview

# Xem tiến độ học
GET /api/parent/children/:childId/courses

# Xem điểm
GET /api/parent/children/:childId/grades

# Xem lịch học
GET /api/parent/children/:childId/timetable
```

---

## Headers Required

```javascript
// Tất cả request authenticated
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer <access_token>'
}
```

---

## Error Handling

```javascript
try {
  const response = await fetch('/api/courses', {
    headers: { 'Authorization': `Bearer ${token}` }
  });

  if (response.status === 401) {
    // Token expired, refresh
    const newTokens = await refreshToken();
    // Retry request
  }

  if (!response.ok) {
    const error = await response.json();
    // { code: "ERR_NOT_FOUND", message: "..." }
    handleError(error);
  }
} catch (e) {
  handleNetworkError(e);
}
```

---

*Cập nhật: 2026-04-17*
