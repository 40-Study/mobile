# KẾ HOẠCH TRIỂN KHAI MÀN HÌNH PHÂN TÍCH KẾT QUẢ BUỔI HỌC DÀNH CHO PHỤ HUYNH
## (PARENT SESSION LEARNING ANALYSIS & FEEDBACK) - PHIÊN BẢN 2.1

> **Dự án:** 40Study Mobile & Backend Platform  
> **Module Mobile:** Parent Experience (`mobile/lib/features/parent/`) - Nhánh `UI/Parent`  
> **Module Backend:** Parent Dashboard Service (`backend/internal/`) - Nhánh `tung/parent_role`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả UX Deliverable A–H, Locked child context, Lesson Detail #9)  
> - Bản thiết kế V1: `uploaded_media_1790610728113.png`  
> - Bản thiết kế V2 (Mới nhất): `uploaded_media_1790611681012.png`  
> - Hệ thống backend hiện tại: `backend/internal/` (Go / Fiber / GORM / PostgreSQL)  
> **Ngày cập nhật:** 28/09/2026  
> **Phiên bản:** 2.1 (Phân tích thiết kế V2, quy chuẩn màu nền surfaceBg & cách ly Backend)  

---

## MỤC LỤC
1. [TỔNG QUAN & BỐI CẢNH DỰ ÁN](#1-tổng-quan--bối-cảnh-dự-án)
2. [PHÂN TÍCH ĐỐI CHIẾU BẢN THIẾT KẾ V2 VỚI DELIVERABLE.MD](#2-phân-tích-đối-chiếu-bản-thiết-kế-v2-với-deliverablemd)
3. [CÁC ĐIỂM CẢI TIẾN TRONG THIẾT KẾ V2 & CÁC ĐIỂM CHƯA HỢP LÝ CẦN KHẮC PHỤC](#3-các-điểm-cải-tiến-trong-thiết-kế-v2--các-điểm-chưa-hợp-lý-cần-khắc-phục)
4. [QUY CHUẨN MÀU NỀN SURFACEBG & HỆ THỐNG PHÂN TẦNG THỊ GIÁC (VISUAL ELEVATION)](#4-quy-chuẩn-màu-nền-surfacebg--hệ-thống-phân-tầng-thị-giác)
5. [QUY TẮC CÁCH LY PHẠM VI TUYỆT ĐỐI CHO BACKEND (STRICT SCOPE ISOLATION)](#5-quy-tắc-cách-ly-phạm-vi-tuyệt-đối-cho-backend)
6. [ĐẶC TẢ CHI TIẾT API BACKEND MỚI (BACKEND API SPECIFICATION)](#6-đặc-tả-chi-tiết-api-backend-mới)
7. [THIẾT KẾ KIẾN TRÚC UI/UX TRÊN MOBILE APP](#7-thiết-kế-kiến-trúc-uiux-trên-mobile-app)
8. [MA TRẬN DỮ LIỆU & EMPTY / EDGE STATES](#8-ma-trận-dữ-liệu--empty--edge-states)
9. [LỘ TRÌNH TRIỂN KHAI TỪNG BƯỚC (ROADMAP)](#9-lộ-trình-triển-khai-từng-bước)
10. [TIÊU CHÍ NGHIỆM THU & BẢO ĐẢM CHẤT LƯỢNG (QUALITY GATES)](#10-tiêu-chí-nghiệm-thu--bảo-đảm-chất-lượng)

---

## 1. TỔNG QUAN & BỐI CẢNH DỰ ÁN

Màn hình chi tiết phân tích kết quả buổi học là điểm chạm (touchpoint) cốt lõi nhất giúp phụ huynh nắm bắt được con học như thế nào sau mỗi buổi học:
- Con có vào học đầy đủ, đúng giờ không?
- Mức độ tiếp thu bài học trên lớp ra sao (thông qua mini-quiz / bài thực hành trắc nghiệm)?
- Con đang gặp khó khăn ở dạng bài nào?
- Giáo viên trực tiếp dạy con có đánh giá, lưu ý gì?
- Phụ huynh cần làm gì tiếp theo để đồng hành cùng con?

Dựa trên tài liệu UX chuẩn (`deliverable.md` - Màn hình #9 **Lesson Detail**), màn hình này nằm trong ngữ cảnh **Locked Child Context** và được tổ chức thành 2 Tab chính:
1. **Tab Tổng quan:** Thông tin buổi học, mục tiêu bài học, slide giáo trình, video xem lại (record).
2. **Tab Kết quả & nhận xét:** Báo cáo chi tiết kết quả bài tập trên lớp, nhận xét của giáo viên, bài tập về nhà và đề xuất bước tiếp theo.

---

## 2. PHÂN TÍCH ĐỐI CHIẾU BẢN THIẾT KẾ V2 VỚI DELIVERABLE.MD

| Tiêu chí | Quy định trong `deliverable.md` | Bản thiết kế V2 (`uploaded_media_1790611681012.png`) | Đánh giá đối chiếu |
|---|---|---|---|
| **Context Scope** | *Locked child context* (Dòng 71, 254): Header có nút Back + tiêu đề ghi rõ tên con (VD: `Bài học: Phân số cơ bản · Minh`). Không có child selector. | Header có `<` Back, tiêu đề `Bài học: Phân số cơ bản · Minh`, phụ đề `Toán nâng cao 10 · Buổi 8`. | **Rất tốt, tuân thủ 100% chuẩn scope**. |
| **Tab Navigation** | Dòng 386: Gồm 2 tab: `Tổng quan` (nội dung/hoạt động) và `Kết quả & nhận xét` (kết quả bài tập, nhận xét giáo viên). | Có 2 Tab: `Tổng quan` và `Kết quả & nhận xét` với dot notification màu xanh. | **Rất tốt, chuẩn cấu trúc phân tầng**. |
| **Vai trò Phụ huynh (Parent Role)** | Dòng 408 & Dòng 99 (Mục G): *Phụ huynh chỉ theo dõi, không làm bài thay con*. Nút hành động phải phản ánh vai trò đồng hành/nhắc nhở. | Đã đổi nút chính thành `[ 🔔 Nhắc con ôn luyện ]`. | **XUẤT SẮC:** Đã sửa đúng vai trò phụ huynh, loại bỏ nút "Luyện tập bổ trợ ngay" của học sinh. |
| **Privacy & Metric Gate** | Dòng 35, Dòng 109 (Mục H.2): *Tạm hoãn và KHÔNG hiển thị focus/engagement score* cho đến khi có cơ chế và chính sách dữ liệu hợp pháp. | Đã thay thế bằng `Chuyên cần: • Có mặt đúng giờ` và `Học 58/60 phút`. | **XUẤT SẮC:** Đã gỡ bỏ chip rating 5 sao và focus score vi phạm gate, chuyển sang số liệu học vụ chuẩn xác. |
| **Tài liệu & Video** | Dòng 386: Tab Tổng quan quản lý nội dung tài liệu/bài học, Tab Kết quả tập trung vào năng lực của con. | Đã nén khối này thành banner nhỏ dẫn sang: `Xem tại Tổng quan >`. | **CẢI THIỆN ĐÁNG KỂ:** Không còn chiếm diện tích lớn, nhưng cần tinh chỉnh lỗi cắt cụt chữ (ellipsis). |
| **Màu nền (Background)** | Deliverable & UI System: Nền màn hình phải dùng `surfaceBg` đồng bộ với Trang chủ và Lịch học để làm nổi bật các thẻ Card màu trắng. | Nền màn hình hiện tại vẫn là màu trắng tuyền (`#FFFFFF`). | **CHƯA ĐẠT:** Thiếu tương phản phân tầng thị giác (flat elevation), các card trắng bị chìm. |

---

## 3. CÁC ĐIỂM CẢI TIẾN TRONG THIẾT KẾ V2 & CÁC ĐIỂM CHƯA HỢP LÝ CẦN KHẮC PHỤC

### 3.1. Những điểm đã cải tiến xuất sắc trong Thiết kế V2:
1. **Nút Primary CTA chuyển đúng vai trò phụ huynh:** Nút `[ 🔔 Nhắc con ôn luyện ]` đã khắc phục hoàn toàn sự nhầm lẫn với app học sinh.
2. **Tuân thủ Gate quyền riêng tư & đo lường:** Loại bỏ chip `Tương tác: • Tích cực` và `Chuyên cần 5 sao`, thay bằng thông số học vụ chuẩn: `Có mặt đúng giờ` & `Học 58/60 phút`.
3. **Giảm tải tab Kết quả:** Đã chuyển phần lớn tải trọng tài liệu & video sang Tab Tổng quan qua banner điều hướng.

---

### 3.2. Các điểm CHƯA HỢP LÝ trong Bản V2 cần xử lý:

#### 🔴 Điểm #1: Background toàn màn hình vẫn để màu trắng tuyền (`#FFFFFF`)
- **Vấn đề:** Cả nền màn hình và nền của các khối Card đều dùng màu trắng `#FFFFFF`.
- **Hậu quả:** Giao diện bị phẳng lì (flat design thiếu chiều sâu), không có độ phân tầng thị giác giữa nền và Card chứa nội dung, viền mỏng không đủ làm nổi bật khối thông tin.
- **Giải pháp:** Sử dụng màu nền `surfaceBg` chuẩn (pha nhẹ giữa `cs.primary` và `cs.surfaceContainer`) đồng bộ với `ParentHomeScreen` và `ParentScheduleScreen`. Khi đó các Card nội dung màu trắng bo góc 16px sẽ nổi bật rõ rệt.

#### 🔴 Điểm #2: Khoảng trống lớn bất thường (Empty Gap) trong Card Kết quả bài tập
- **Vấn đề:** Sau khi bỏ danh sách chẩn đoán lỗi câu hỏi, giữa dòng `Thời gian làm: 18 phút / 25 phút` và dòng link `Xem chi tiết bài làm của con ->` xuất hiện một khoảng trống lớn không có nội dung, trông như lỗi layout.
- **Giải pháp:**
  - Bổ sung **Visual Progress Segment Bar** nhỏ gọn thể hiện trực quan tỷ lệ làm bài: 3 vạch xanh lá (Đúng) và 2 vạch đỏ cam (Sai).
  - Kèm dòng tóm tắt súc tích: `Đúng 3/5 câu trắc nghiệm • Cần ôn lại phần rút gọn mẫu thức`.
  - Hoặc co gọn padding hợp lý để card cân đối, không để khoảng trống vô nghĩa.

#### 🔴 Điểm #3: Bị cắt chữ (Text Truncation / Ellipsis `...`) ở các thành phần chính
- **Vấn đề trên thiết kế V2:**
  - Banner tài liệu ghi: `Tài liệu bài giảng & Video...` bị cắt cụt từ.
  - Nút bấm bên trái ở Bottom Bar: `💬 Nhắn tin cô ...` bị cắt mất tên cô giáo do chiều rộng cố định quá hẹp.
- **Giải pháp:**
  - Với Banner tài liệu: Viết gọn lại thành 2 dòng rõ nghĩa:  
    Dòng 1: `Tài liệu & Video bài giảng`  
    Dòng 2: `Đã lưu trữ trong tab Tổng quan`
  - Với Nút Bottom Bar: Đổi nhãn nút phụ thành `[ 💬 Nhắn tin ]` (ngắn gọn, xúc tích, không bị cắt chữ trên màn hình hẹp), dành đủ không gian cho nút chính `[ 🔔 Nhắc con ôn luyện ]`.

#### 🔴 Điểm #4: Chưa đặc tả luồng hành động khi bấm `[ 🔔 Nhắc con ôn luyện ]`
- **Vấn đề:** Khi phụ huynh bấm vào nút chuông nhắc nhở này, hệ thống sẽ thực hiện hành động gì?
- **Giải pháp:** Mở một `ReminderActionSheet` với 2 lựa chọn tiện lợi cho phụ huynh:
  1. *Gửi thông báo nhắc nhở vào app học tập của con* (kèm cơ chế chống spam/cooldown 15 phút theo chuẩn `deliverable.md` mục G.99).
  2. *Chia sẻ nhắc nhở qua Zalo / Tin nhắn SMS* (tự động tạo sẵn lời nhắn: *"Minh ơi, cô Lan nhắc con ôn lại Bài luyện tập 5 môn Toán tối nay nhé!"*).

---

## 4. QUY CHUẨN MÀU NỀN SURFACEBG & HỆ THỐNG PHÂN TẦNG THỊ GIÁC

Để màn hình có độ sâu và nổi bật các thẻ Card thông tin giống hệt Trang chủ và Tab Lịch học, toàn bộ cấu trúc màu sắc được chuẩn hóa theo quy tắc sau:

### 4.1. Công thức tính màu nền `surfaceBg`
```dart
// Áp dụng cho Scaffold.backgroundColor:
final isLight = Theme.of(context).brightness == Brightness.light;
final surfaceBg = Color.alphaBlend(
  cs.primary.withValues(alpha: isLight ? 0.045 : 0.065),
  cs.surfaceContainer,
);
```
- **Hiệu ứng thị giác:** Tạo ra nền xám-xanh nhẹ tinh tế (`#F8FAFC` - `#F1F5F9`), giúp mắt thư giãn khi đọc văn bản dài.

### 4.2. Quy cách tạo khối Card nội dung trên nền `surfaceBg`
Mỗi khối thông tin (`SessionQuizResultCard`, `SessionTeacherFeedbackCard`, `SessionHomeworkCard`) được đóng gói trong một Container:
- **Màu nền Card:** `Colors.white` (ở Dark mode dùng `cs.surface`).
- **Bo góc:** `BorderRadius.circular(16)`.
- **Viền:** `Border.all(color: const Color(0xFFE2E8F0), width: 1)`.
- **Đổ bóng (Elevation):**
  ```dart
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
  ```

---

## 5. QUY TẮC CÁCH LY PHẠM VI TUYỆT ĐỐI CHO BACKEND (STRICT SCOPE ISOLATION)

> **CHỈ ĐẠO BẮT BUỘC TỪ NGƯỜI DÙNG:**  
> *"Bạn có quyền thêm api trong backend, tuy nhiên không được động tới các api khác, chỉ được hoạt động trong phạm vi api này thôi."*

Toàn bộ thay đổi Backend tuân thủ nguyên tắc **Non-breaking Additive Only** (Chỉ thêm mới, không sửa đổi logic cũ):

### 5.1. Ma trận phân bổ file Backend được phép can thiệp

| File Backend | Hành động | Phạm vi can thiệp chi tiết | Đảm bảo an toàn |
|---|---|---|---|
| `backend/internal/dto/child_session_analysis_dto.go` | **TẠO MỚI HOÀN TOÀN** | Định nghĩa toàn bộ DTO Response chuyên biệt cho endpoint này. | Không chạm vào `parent_dashboard_dto.go` hay các DTO dùng chung khác. |
| `backend/internal/router/parent_dashboard_router.go` | **CHỈ THÊM 1 DÒNG** | Thêm duy nhất 1 route: `children.Get("/sessions/:sessionId/analysis", h.GetChildSessionAnalysis)`. | Giữ nguyên 100% 7 routes hiện có (`overview`, `courses`, `grades`, `schedule`, `timetable`, `attendance`, `assignments`). |
| `backend/internal/handler/parent_dashboard_handler.go` | **CHỈ THÊM METHOD MỚI** | Thêm hàm `GetChildSessionAnalysis(c *fiber.Ctx) error`. | Không sửa đổi một dòng code nào trong 7 handler functions hiện tại. |
| `backend/internal/service/parent_dashboard_service.go` | **CHỈ THÊM METHOD MỚI** | 1. Bổ sung signature `GetChildSessionAnalysis(...)` vào interface `ParentDashboardServiceInterface`.<br>2. Cài đặt hàm `GetChildSessionAnalysis` ở cuối file. | Không đụng đến logic của `GetChildOverview`, `GetChildCourses`, `GetChildGrades`, `GetChildSchedule`, `GetChildAttendance`, `GetChildAssignments`. |
| `backend/internal/service/parent_dashboard_session_analysis_test.go` | **TẠO MỚI HOÀN TOÀN** | Viết unit test riêng cho service method mới. | Không sửa các file test hiện có. |

### 5.2. Nguyên tắc tái sử dụng dữ liệu an toàn (Zero DB Migration)
- **Không thay đổi Schema DB:** Tận dụng 100% các bảng sẵn có trong PostgreSQL:
  - Bảng `parent_student_relations`: Xác thực quyền xem con.
  - Bảng `class_sessions`: Lấy thông tin môn học, ca học, ngày giờ.
  - Bảng `session_attendances`: Lấy thời gian vào lớp, số phút tham gia, trạng thái đúng giờ.
  - Bảng `grades`: Lấy điểm quiz trên lớp (`score`, `max_score`) và nhận xét của giáo viên (`feedback`).
  - Bảng `assignments`: Lấy bài tập về nhà liên quan đến buổi học.
  - Bảng `users`: Lấy thông tin họ tên, avatar của giáo viên giảng dạy.
- **Xử lý Graceful Failure:** Nếu một trong các dữ liệu phụ (quiz, nhận xét, bài tập) chưa có trong DB, API tự động trả về `nil` cho trường đó thay vì trả về lỗi 500.

---

## 6. ĐẶC TẢ CHI TIẾT API BACKEND MỚI

### 6.1. Thông tin Endpoint
- **HTTP Method:** `GET`
- **Route Path:** `/api/parent/children/:id/sessions/:sessionId/analysis`
  - `:id`: UUID của học sinh (con).
  - `:sessionId`: UUID của ca học cụ thể.
- **Middlewares:** `middleware.AuthMiddleware` (yêu cầu JWT token của phụ huynh).
- **Authorization:** Gọi `verifyParentChildRelation(parentID, childID)` đảm bảo quan hệ `active` và phụ huynh có quyền xem học tập (`can_view_grades` hoặc `can_view_progress`).

### 6.2. File DTO mới: `backend/internal/dto/child_session_analysis_dto.go`

```go
package dto

import "time"

// ChildSessionAnalysisResponseDto - Phân tích chi tiết buổi học của con
type ChildSessionAnalysisResponseDto struct {
	SessionID     string `json:"session_id"`
	SessionCode   string `json:"session_code"`   // VD: "TOAN10-B08"
	SessionNumber int    `json:"session_number"` // 8
	LessonTitle   string `json:"lesson_title"`   // "Phân số cơ bản"
	ClassName     string `json:"class_name"`     // "Toán nâng cao 10"
	SessionDate   string `json:"session_date"`   // "2024-10-24"
	Status        string `json:"status"`         // "completed", "in_progress", "upcoming"
	StatusLabel   string `json:"status_label"`   // "Hoàn thành hôm nay"

	// 1. Điểm danh & Chuyên cần
	Attendance *SessionAttendanceSummaryDto `json:"attendance,omitempty"`

	// 2. Kết quả kiểm tra / Quiz trên lớp
	QuizResult *SessionQuizAnalysisDto `json:"quiz_result,omitempty"`

	// 3. Nhận xét của giáo viên
	TeacherFeedback *SessionTeacherFeedbackDto `json:"teacher_feedback,omitempty"`

	// 4. Bài tập về nhà được giao
	Homework *SessionHomeworkTaskDto `json:"homework,omitempty"`

	// 5. Video xem lại bài giảng (nếu có)
	Recording *SessionRecordingDto `json:"recording,omitempty"`
}

type SessionAttendanceSummaryDto struct {
	Status          string  `json:"status"`           // "present", "late", "absent"
	CheckInTime     *string `json:"check_in_time"`    // "08:58"
	AttendedMinutes int     `json:"attended_minutes"` // 58
	TotalMinutes    int     `json:"total_minutes"`    // 60
	AttendanceLabel string  `json:"attendance_label"` // "Chuyên cần: Đúng giờ (58/60 phút)"
}

type SessionQuizAnalysisDto struct {
	Title          string                  `json:"title"`           // "Quiz & Thực hành tính toán nhanh"
	ScoreLabel     string                  `json:"score_label"`     // "Cần rèn luyện thêm" | "Xuất sắc" | "Đạt yêu cầu"
	Score          float64                 `json:"score"`           // 6.0
	MaxScore       float64                 `json:"max_score"`       // 10.0
	CorrectCount   int                     `json:"correct_count"`   // 3
	TotalQuestions int                     `json:"total_questions"` // 5
	Percentage     float64                 `json:"percentage"`      // 60.0
	TimeSpentMins  int                     `json:"time_spent_mins"` // 18
	TimeLimitMins  int                     `json:"time_limit_mins"` // 25
	CanViewDetail  bool                    `json:"can_view_detail"`
}

type SessionTeacherFeedbackDto struct {
	TeacherID   string     `json:"teacher_id"`
	TeacherName string     `json:"teacher_name"`     // "Cô Phạm Hồng Lan"
	TeacherRole *string    `json:"teacher_role"`     // "ThS. Toán"
	Subject     string     `json:"subject"`          // "Bộ môn Toán"
	AvatarURL   *string    `json:"avatar_url"`
	Comment     string     `json:"comment"`          // Lời nhận xét
	CommentedAt *time.Time `json:"commented_at"`     // Thời gian gửi nhận xét
	CanChat     bool       `json:"can_chat"`
}

type SessionHomeworkTaskDto struct {
	AssignmentID string     `json:"assignment_id"`
	Title        string     `json:"title"`         // "Toán 10 — Bài luyện tập 5: Rút gọn phân số có ẩn"
	DueDate      *time.Time `json:"due_date"`      // 2024-10-24T20:00:00Z
	DueDateText  string     `json:"due_date_text"` // "20:00 tối nay"
	Status       string     `json:"status"`        // "pending", "submitted", "graded", "overdue"
}

type SessionRecordingDto struct {
	DurationMins int    `json:"duration_mins"` // 48
	Quality      string `json:"quality"`       // "1080p"
	VideoURL     string `json:"video_url"`     // URL video phát lại
}
```

---

## 7. THIẾT KẾ KIẾN TRÚC UI/UX TRÊN MOBILE APP

### 7.1. Cấu trúc Màn hình & Tích hợp Tab
Màn hình được triển khai trong file:  
[`mobile/lib/features/parent/presentation/schedule/parent_session_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/parent/presentation/schedule/parent_session_detail_screen.dart)

- **Scaffold Background:** Sử dụng màu `surfaceBg`.
- **Top Bar (AppBar):**
  - Nút Back `<` (bảo toàn state).
  - Status Tag & ID ca học: `• HOÀN THÀNH HÔM NAY` | `ID: TOAN10-B08`.
  - Title: `Bài học: Phân số cơ bản · Minh` (Locked child context).
  - Subtitle: `Toán nâng cao 10 · Buổi 8 (Thứ Năm, 24/10)`.
  - Nút `⋮` mở Action Sheet.
  - **TabBar:** `[ Tổng quan ]` | `[ Kết quả & nhận xét (•) ]`.

### 7.2. Cấu trúc Tab "Kết quả & nhận xét" (Từ trên xuống dưới)

1. **Card 1: Kết quả bài tập trên lớp (`SessionQuizResultCard`)**
   - Tiêu đề phụ: `Quiz & Thực hành tính toán nhanh`.
   - Badge đánh giá: `Cần rèn luyện thêm` (màu cam).
   - Điểm số: `3 / 5 đúng` kèm badge `60%`, vòng tròn donut `3/5`.
   - Thời gian làm: `18 phút / 25 phút`.
   - **Thanh Progress Bar tỷ lệ:** 3 vạch xanh lá (Đúng) + 2 vạch đỏ cam (Chưa đạt) lấp đầy khoảng trống thừa một cách tinh tế.
   - Text link: `[Xem chi tiết bài làm của con ->]`.

2. **Card 2: Đánh giá & nhận xét của giáo viên (`SessionTeacherFeedbackCard`)**
   - Header giáo viên: Avatar tròn, Họ tên, Học vị (`ThS. Toán`), Phân môn (`Bộ môn Toán`).
   - Thời gian nhận xét: `Đã nhận xét lúc 11:30 hôm nay`.
   - Hộp trích dẫn (Quote container) với viền dọc màu xanh thương hiệu chứa toàn bộ lời khuyên của cô giáo.
   - Tag học vụ chuẩn: `Chuyên cần: • Có mặt đúng giờ` | `Học 58/60 phút`.

3. **Banner Điều hướng Tài liệu & Video bài giảng**
   - Container bo góc 14px, viền xanh nhạt, icon máy quay video.
   - Text không bị cắt cụt: `Tài liệu & Video bài giảng` • `Đã lưu trữ trong tab Tổng quan`.
   - Action link: `Xem tại Tổng quan >` (khi bấm sẽ tự động chuyển sang Tab 1 `Tổng quan`).

4. **Card 3: Bước tiếp theo cho Phụ huynh & Con (`SessionHomeworkNextStepCard`)**
   - Card nền kem viền cam nhạt.
   - Icon cảnh báo màu cam.
   - Tên bài tập: `Toán 10 — Bài luyện tập 5: Rút gọn phân số có ẩn`.
   - Hạn chót nộp bài: `Hạn chót: 20:00 tối nay` (chữ đỏ nổi bật).
   - Link điều hướng mở rộng: `[📊 Xem phân tích chi tiết (Insights) ->]` mở màn hình Insights được filter sẵn môn Toán.

5. **Sticky Bottom Action Bar (Cố định ở đáy)**
   - Nút phụ (Trái): `[ 💬 Nhắn tin ]` (Outline Button không bị cụt chữ).
   - Nút chính (Phải): `[ 🔔 Nhắc con ôn luyện ]` (Elevated Button màu xanh primary).

---

## 8. MA TRẬN DỮ LIỆU & EMPTY / EDGE STATES

| Tình huống thực tế | Dữ liệu API trả về | Cách hiển thị trên giao diện (Mobile UI) |
|---|---|---|
| **Ca học sắp tới (`upcoming`)** | Chưa có kết quả, `status == "upcoming"` | Tab Kết quả hiển thị Empty State lịch sự: Icon đồng hồ + Text: *"Buổi học chưa diễn ra. Kết quả và nhận xét của giáo viên sẽ hiển thị sau khi buổi học kết thúc."* |
| **Buổi học vừa xong, giáo viên chưa chấm/nhận xét** | `quiz_result == null`, `teacher_feedback == null` | Card Nhận xét hiển thị: Icon ghi chú + Text: *"Giáo viên đang hoàn thiện đánh giá buổi học. Phụ huynh vui lòng quay lại sau ít phút."* |
| **Buổi học không có Quiz trên lớp** | `quiz_result == null` | Card Quiz tự động ẩn, chỉ hiển thị nhận xét buổi học và bài tập về nhà. |
| **Con vắng mặt có phép / không phép** | `attendance.status == "absent"` | Hiển thị Banner cảnh báo: *"Con vắng mặt trong buổi học này. Phụ huynh nên nhắc con xem lại Video bài giảng ở tab Tổng quan để theo kịp tiến độ."* |
| **Không có bài tập về nhà** | `homework == null` | Card bài tập hiển thị: Icon check xanh + Text: *"Không có bài tập về nhà cho buổi học này. Con đã hoàn thành tốt nội dung trên lớp."* |

---

## 9. LỘ TRÌNH TRIỂN KHAI TỪNG BƯỚC

### Giai đoạn 1: Bổ sung Backend API (Nhánh `tung/parent_role`, cách ly tuyệt đối)
- **Bước 1.1:** Tạo file DTO mới `backend/internal/dto/child_session_analysis_dto.go`.
- **Bước 1.2:** Thêm signature vào interface và viết hàm `GetChildSessionAnalysis` trong `backend/internal/service/parent_dashboard_service.go`.
- **Bước 1.3:** Thêm method `GetChildSessionAnalysis` trong `backend/internal/handler/parent_dashboard_handler.go`.
- **Bước 1.4:** Thêm duy nhất 1 route vào `backend/internal/router/parent_dashboard_router.go`.
- **Bước 1.5:** Chạy `go build ./...` và unit test để đảm bảo biên dịch 100% không lỗi. Commit ngắn gọn bằng tiếng Việt và push lên nhánh `tung/parent_role`.

### Giai đoạn 2: Cập nhật Mobile Data Model & Repository (Nhánh `UI/Parent`)
- **Bước 2.1:** Cập nhật [`parent_session_detail_model.dart`](file:///C:/ForteX/mobile/lib/features/parent/data/models/parent_session_detail_model.dart) map theo cấu trúc DTO mới.
- **Bước 2.2:** Cung cấp mock data đầy đủ cho học sinh mẫu `Minh` và cơ chế fallback Empty State chuẩn cho tài khoản thật `Mai Hoàng Tùng`.

### Giai đoạn 3: Hoàn thiện Giao diện Mobile Tab "Kết quả & nhận xét" (Nhánh `UI/Parent`)
- **Bước 3.1:** Đảm bảo `Scaffold.backgroundColor` sử dụng `surfaceBg` chuẩn, các Card trắng nổi bật.
- **Bước 3.2:** Tích hợp `DefaultTabController(length: 2)` vào `parent_session_detail_screen.dart`.
- **Bước 3.3:** Xây dựng Widget `_buildQuizResultCard` (điểm số, progress bar tỷ lệ đúng/sai, không bị khoảng trống thừa).
- **Bước 3.4:** Xây dựng Widget `_buildTeacherFeedbackCard` (hộp thoại trích dẫn, tag chuyên cần chuẩn).
- **Bước 3.5:** Bổ sung banner chuyển tab tài liệu & video không bị cắt chữ.
- **Bước 3.6:** Xây dựng Widget `_buildHomeworkNextStepCard` và liên kết sang Insights.
- **Bước 3.7:** Tối ưu Sticky Bottom Bar cho phụ huynh: `[💬 Nhắn tin]` và `[🔔 Nhắc con ôn luyện]`.
- **Bước 3.8:** Chạy `flutter analyze` đạt 0 issues, commit ngắn gọn bằng tiếng Việt và push lên `UI/Parent`.

---

## 10. TIÊU CHÍ NGHIỆM THU & BẢO ĐẢM CHẤT LƯỢNG (QUALITY GATES)

1. **Không hồi quy Backend (Zero Regressions):** Toàn bộ 7 API phụ huynh hiện có và các API hệ thống khác hoạt động bình thường 100%, không bị ảnh hưởng.
2. **Khóa ngữ cảnh chuẩn:** AppBar hiển thị đúng tên con và thông tin buổi học, không có child selector.
3. **Màu nền surfaceBg đạt chuẩn:** Không dùng background trắng tuyền, các card nội dung màu trắng nổi bật rõ nét.
4. **Không bị cắt cụt chữ:** Toàn bộ text trên banner và nút bấm hiển thị đầy đủ, co giãn responsive tốt.
5. **Chuyển Tab mượt mà:** Chuyển đổi giữa `Tổng quan` và `Kết quả & nhận xét` mượt mà, lưu giữ vị trí cuộn.
6. **Không vi phạm Privacy Gate:** Không hiển thị focus/engagement score giả định.
7. **Đúng vai trò phụ huynh:** Nút hành động ở đáy màn hình là `[🔔 Nhắc con ôn luyện]`, phản ánh đúng vai trò đồng hành.
8. **Xử lý Empty State mượt mà:** Tài khoản con thật không bị crash, hiển thị thông báo rỗng chuẩn mực khi chưa có dữ liệu từ backend.
9. **Linter & Clean Code:** `flutter analyze` đạt 0 issues, comment giải thích rõ ràng bằng tiếng Việt.
