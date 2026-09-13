# Parent APIs - Backend Request

## 1. GET /api/me/children

Lấy danh sách con của phụ huynh đang đăng nhập.

**Request:**
```
GET /api/me/children
Authorization: Bearer <token>
```

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "fullName": "Nguyễn Minh Anh",
      "avatarUrl": "https://...",
      "className": "Lớp 7",
      "age": 12,
      "enrolledCourses": 2
    }
  ]
}
```

---

## 2. GET /api/parent/children/{id}/tuition

Lấy thông tin học phí của con.

**Request:**
```
GET /api/parent/children/{id}/tuition
Authorization: Bearer <token>
```

**Response:**
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

**Notes:**
- `status`: `paid` | `unpaid` | `partial`
- `dueDate`: deadline thanh toán gần nhất

---

## 3. GET /api/parent/children/{id}/suggestions

Gợi ý khoá học phù hợp cho con (dựa trên khoá đang học).

**Request:**
```
GET /api/parent/children/{id}/suggestions
Authorization: Bearer <token>
```

**Response:**
```json
{
  "data": [
    {
      "courseId": "uuid",
      "courseName": "Python nâng cao",
      "description": "Tiếp nối Python cơ bản, giúp con phát triển kỹ năng lập trình chuyên sâu hơn.",
      "imageUrl": "https://...",
      "totalLessons": 24,
      "price": 3600000,
      "matchScore": 95,
      "reason": "Phù hợp nhất"
    }
  ]
}
```

**Notes:**
- `matchScore`: 0-100, độ phù hợp
- `reason`: text hiển thị badge (VD: "Phù hợp nhất", "Đang giảm giá")
- Sort by `matchScore` DESC

---

## APIs đã có (confirm lại)

| Endpoint | Status |
|----------|--------|
| GET /api/parent/children/{id}/overview | OK |
| GET /api/parent/children/{id}/schedule | OK |
| GET /api/parent/children/{id}/courses | OK |
| GET /api/parent/children/{id}/assignments | OK |
| GET /api/parent/alerts | OK |

---

## Cải thiện API (nice to have)

### Schedule API - thêm course_id

Hiện `upcoming_sessions` chỉ có `class_id`, không có `course_id`. Khó link với courses API.

**Request:** Thêm `course_id` vào `upcoming_sessions`:
```json
{
  "upcoming_sessions": [{
    "id": "...",
    "class_id": "...",
    "class_name": "Lop React K1",
    "course_id": "...",        // <-- THÊM
    "course_name": "React...", // <-- THÊM (optional)
    ...
  }]
}
```
