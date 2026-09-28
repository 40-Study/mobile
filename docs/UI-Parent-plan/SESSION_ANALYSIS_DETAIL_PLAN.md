# KẾ HOẠCH TRIỂN KHAI MÀN HÌNH PHÂN TÍCH KẾT QUẢ BUỔI HỌC DÀNH CHO PHỤ HUYNH
## (PARENT SESSION LEARNING ANALYSIS & FEEDBACK)

> **Dự án:** 40Study Mobile & Backend Platform  
> **Module Mobile:** Parent Experience (`mobile/lib/features/parent/`) - Nhánh `UI/Parent`  
> **Module Backend:** Parent Dashboard Service (`backend/internal/`) - Nhánh `tung/parent_role`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả UX Deliverable A–H, Locked child context, Lesson Detail #9)  
> - Ảnh thiết kế: `uploaded_media_1790610728113.png` (Chi tiết phân tích kết quả buổi học & nhận xét)  
> - Hệ thống backend hiện tại: `backend/internal/` (Go / Fiber / GORM / PostgreSQL)  
> **Ngày cập nhật:** 28/09/2026  
> **Phiên bản:** 2.0 (Bổ sung thiết kế & quy chuẩn cách ly tuyệt đối cho Backend API mới)  

---

## MỤC LỤC
1. [TỔNG QUAN & BỐI CẢNH DỰ ÁN](#1-tổng-quan--bối-cảnh-dự-án)
2. [PHÂN TÍCH ĐỐI CHIẾU THIẾT KẾ VỚI DELIVERABLE.MD](#2-phân-tích-đối-chiếu-thiết-kế-với-deliverablemd)
3. [CÁC ĐIỂM CHƯA HỢP LÝ TRONG THIẾT KẾ & ĐỀ XUẤT GIẢI PHÁP](#3-các-điểm-chưa-hợp-lý-trong-thiết-kế--đề-xuất-giải-pháp)
4. [QUY TẮC CÁCH LY PHẠM VI TUYỆT ĐỐI CHO BACKEND (STRICT SCOPE ISOLATION)](#4-quy-tắc-cách-ly-phạm-vi-tuyệt-đối-cho-backend)
5. [ĐẶC TẢ CHI TIẾT API BACKEND MỚI (BACKEND API SPECIFICATION)](#5-đặc-tả-chi-tiết-api-backend-mới)
6. [THIẾT KẾ KIẾN TRÚC UI/UX TRÊN MOBILE APP](#6-thiết-kế-kiến-trúc-uiux-trên-mobile-app)
7. [MA TRẬN DỮ LIỆU & EMPTY / EDGE STATES](#7-ma-trận-dữ-liệu--empty--edge-states)
8. [LỘ TRÌNH TRIỂN KHAI TỪNG BƯỚC (ROADMAP)](#8-lộ-trình-triển-khai-từng-bước)
9. [TIÊU CHÍ NGHIỆM THU & BẢO ĐẢM CHẤT LƯỢNG (QUALITY GATES)](#9-tiêu-chí-nghiệm-thu--bảo-đảm-chất-lượng)

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

## 2. PHÂN TÍCH ĐỐI CHIẾU THIẾT KẾ VỚI DELIVERABLE.MD

| Tiêu chí | Quy định trong `deliverable.md` | Thiết kế trong Ảnh 1 | Đánh giá đối chiếu |
|---|---|---|---|
| **Context Scope** | *Locked child context* (Dòng 71, 254): Header có nút Back + tiêu đề ghi rõ tên con (VD: `Bài học: Phân số cơ bản · Minh`). Không có child selector. | Header có `<` Back, tiêu đề `Bài học: Phân số cơ bản · Minh`, phụ đề `Toán nâng cao 10 · Buổi 8`. | **Rất tốt, tuân thủ 100% chuẩn scope**. |
| **Tab Navigation** | Dòng 386: Gồm 2 tab: `Tổng quan` (nội dung/hoạt động) và `Kết quả & nhận xét` (kết quả bài tập, nhận xét giáo viên). | Có 2 Tab: `Tổng quan` và `Kết quả & nhận xét` với dot notification màu xanh. | **Rất tốt, chuẩn cấu trúc phân tầng**. |
| **Vai trò Phụ huynh (Parent Role)** | Dòng 408: *Phụ huynh chỉ theo dõi, không nộp bài hay làm bài thay con*. Nút hành động phải phản ánh vai trò đồng hành/nhắc nhở. | Nút CTA đáy màn hình: `[Luyện tập bổ trợ ngay ->]`. | **CHƯA PHÙ HỢP:** Tạo cảm giác phụ huynh là người bấm vào làm bài tập của học sinh. |
| **Privacy & Metric Gate** | Dòng 35, Dòng 109 (Mục H.2): *Tạm hoãn và KHÔNG hiển thị focus/engagement score* cho đến khi có cơ chế và chính sách dữ liệu hợp pháp. | Có chip `Tương tác: • Tích cực` và `Chuyên cần: ★★★★★ 5/5`. | **CẦN ĐIỀU CHỈNH:** Vi phạm gate privacy / đo lường chưa có căn cứ dữ liệu chuẩn xác. |
| **Tài liệu & Video** | Dòng 386: Tab Tổng quan quản lý nội dung tài liệu/bài học, Tab Kết quả tập trung vào năng lực của con. | Tab "Kết quả & nhận xét" chứa cả khối `TÀI LIỆU BÀI GIẢNG & VIDEO XEM LẠI`. | **BỊ TRÙNG LẶP / QUÁ TẢI:** Làm loãng trọng tâm kết quả của con và redundancy với Tab Tổng quan. |
| **Khả năng tiếp cận (Accessibility)** | Dòng 137: Không truyền đạt xu hướng hay kết quả chỉ bằng màu sắc. | Điểm số `3/5`, `60%`, có nhãn `Cần rèn luyện thêm`, badge `Chính xác` / `Chưa đạt`. | **Tốt:** Đạt chuẩn WCAG về nhãn text đi kèm màu sắc. |

---

## 3. CÁC ĐIỂM CHƯA HỢP LÝ TRONG THIẾT KẾ & ĐỀ XUẤT GIẢI PHÁP

### 3.1. Điểm chưa hợp lý #1: Nút CTA chính `[Luyện tập bổ trợ ngay ->]` gây nhầm lẫn vai trò người dùng
- **Phân tích:** Phụ huynh sử dụng app để đồng hành, theo dõi con. Nút kêu gọi hành động `[Luyện tập bổ trợ ngay ->]` là CTA điển hình của ứng dụng Học sinh (Student App). Khi phụ huynh bấm vào, họ không phải là người trực tiếp làm bài tập trắc nghiệm hay giải toán.
- **Đề xuất giải pháp:**
  - **Phương án A (Khuyên dùng):** Đổi nhãn thành `[Nhắc con luyện tập]` hoặc `[Cùng con ôn luyện (Xem đề)]`. Khi bấm vào sẽ mở bản xem trước của bài tập kèm nút nhắc nhở con hoặc gợi ý cách phụ huynh hướng dẫn con giải.
  - **Phương án B:** Điều hướng sang màn hình chi tiết bài tập về nhà `Homework Detail Screen` (đã quy định ở Screen #11 trong deliverable) để phụ huynh theo dõi tiến độ nộp bài của con.

### 3.2. Điểm chưa hợp lý #2: Hiển thị chỉ số "Tương tác: Tích cực" và "Chuyên cần: 5/5 sao"
- **Phân tích:**
  - `deliverable.md` đã ghi rất rõ tại Dòng 3 và Dòng 109: Chỉ số tập trung/tương tác (`focus/engagement score`) **bị tạm dừng triển khai** do chưa có chính sách pháp lý về quyền riêng tư dữ liệu của trẻ em (Privacy & Lawful basis) và cơ chế đo lường đáng tin cậy.
  - Đánh giá chuyên cần bằng `5/5 sao` mang tính chất xếp hạng dịch vụ, không phù hợp với nghiệp vụ học vụ (điểm danh thường là: *Có mặt đúng giờ*, *Đi muộn X phút*, *Vắng có phép*).
- **Đề xuất giải pháp:**
  - Tạm ẩn chip `Tương tác: • Tích cực` để tuân thủ Gate bảo mật của dự án.
  - Chuyển `Chuyên cần: ★★★★★ 5/5` thành số liệu điểm danh chuẩn xác:
    `Chuyên cần: Có mặt đúng giờ (Học 58/60 phút)`.

### 3.3. Điểm chưa hợp lý #3: Khối Tài liệu & Video xem lại đặt trong Tab Kết quả
- **Phân tích:**
  - Đưa cả Slide PDF và Video Record buổi học dài 48 phút vào Tab "Kết quả & nhận xét" khiến màn hình bị dài quá mức và gây trùng lặp với Tab "Tổng quan".
  - Phụ huynh vào tab này với mục đích chính là xem: *Con học thế nào? Điểm mấy? Thầy cô nhận xét gì? Có bài tập về nhà không?*
- **Đề xuất giải pháp:**
  - Đưa toàn bộ File tài liệu và Trình phát video bài giảng sang **Tab "Tổng quan"**.
  - Tại Tab "Kết quả & nhận xét", nếu muốn dẫn chứng bài giảng, chỉ để một liên kết tinh gọn:
    `[🎬 Xem lại video bài giảng tại Tab Tổng quan ->]`.

### 3.4. Điểm chưa hợp lý #4: Phân tích lỗi chi tiết từng câu vượt quá khả năng của Backend hiện tại
- **Phân tích:**
  - Thiết kế có ghi: `Câu 3 & 5: Quy đồng mẫu thức - Lỗi đổi dấu tử số khi nhân lượng liên hợp`.
  - Backend hiện tại chưa có hệ thống AI Diagnostic hay Knowledge Concept Tree gắn theo từng câu hỏi trắc nghiệm để tự động phát hiện loại lỗi ngữ nghĩa này.
- **Đề xuất giải pháp:**
  - **Giai đoạn hiện tại:** Hiển thị kết quả dạng danh sách câu:
    - `[✓] Câu 1: Rút gọn biểu thức — Chính xác`
    - `[✗] Câu 3: Quy đồng mẫu thức — Chưa chính xác`
    - Text link: `[Xem chi tiết bài làm của con ->]` mở xem đáp án con đã chọn vs đáp án đúng.
  - **Giai đoạn nâng cao:** Cung cấp trường `error_note` (optional) trong API để nếu giáo viên chủ động nhập ghi chú hoặc AI có chẩn đoán thì hiển thị thêm.

### 3.5. Điểm chưa hợp lý #5: Chưa có kịch bản cho các trạng thái thiếu dữ liệu (Empty States)
- **Phân tích:**
  - Thiết kế chỉ có duy nhất trường hợp lý tưởng. Nếu buổi học vừa kết thúc giáo viên chưa chấm, hoặc buổi học không có quiz, hoặc học sinh vắng mặt thì giao diện sẽ hiển thị thế nào?
- **Đề xuất giải pháp:**
  - Xây dựng ma trận Empty State tinh tế cho từng Card: khi không có Quiz, khi giáo viên chưa gửi nhận xét, khi không giao bài tập về nhà.

---

## 4. QUY TẮC CÁCH LY PHẠM VI TUYỆT ĐỐI CHO BACKEND (STRICT SCOPE ISOLATION)

> **CHỈ ĐẠO BẮT BUỘC TỪ NGƯỜI DÙNG:**  
> *"Bạn có quyền thêm api trong backend, tuy nhiên không được động tới các api khác, chỉ được hoạt động trong phạm vi api này thôi."*

Để tuân thủ 100% nguyên tắc không làm ảnh hưởng đến bất kỳ API nào khác đang hoạt động ổn định trên hệ thống, toàn bộ thay đổi Backend được thiết kế theo cơ chế **Non-breaking Additive Only** (Chỉ thêm mới, không sửa đổi logic cũ):

### 4.1. Ma trận phân bổ file Backend được phép can thiệp

| File Backend | Hành động | Phạm vi can thiệp chi tiết | Đảm bảo an toàn |
|---|---|---|---|
| `backend/internal/dto/child_session_analysis_dto.go` | **TẠO MỚI HOÀN TOÀN** | Định nghĩa toàn bộ DTO Response chuyên biệt cho endpoint này. | Không chạm vào `parent_dashboard_dto.go` hay các DTO dùng chung khác. |
| `backend/internal/router/parent_dashboard_router.go` | **CHỈ THÊM 1 DÒNG** | Thêm duy nhất 1 route: `children.Get("/sessions/:sessionId/analysis", h.GetChildSessionAnalysis)`. | Giữ nguyên 100% 7 routes hiện có (`overview`, `courses`, `grades`, `schedule`, `timetable`, `attendance`, `assignments`). |
| `backend/internal/handler/parent_dashboard_handler.go` | **CHỈ THÊM METHOD MỚI** | Thêm hàm `GetChildSessionAnalysis(c *fiber.Ctx) error`. | Không sửa đổi một dòng code nào trong 7 handler functions hiện tại. |
| `backend/internal/service/parent_dashboard_service.go` | **CHỈ THÊM METHOD MỚI** | 1. Bổ sung signature `GetChildSessionAnalysis(...)` vào interface `ParentDashboardServiceInterface`.<br>2. Cài đặt hàm `GetChildSessionAnalysis` ở cuối file. | Không đụng đến logic của `GetChildOverview`, `GetChildCourses`, `GetChildGrades`, `GetChildSchedule`, `GetChildAttendance`, `GetChildAssignments`. |
| `backend/internal/service/parent_dashboard_session_analysis_test.go` | **TẠO MỚI HOÀN TOÀN** | Viết unit test riêng cho service method mới. | Không sửa các file test hiện có. |

### 4.2. Nguyên tắc tái sử dụng dữ liệu an toàn (Zero DB Migration)
- **Không thay đổi Schema DB:** Tận dụng 100% các bảng sẵn có trong PostgreSQL:
  - Bảng `parent_student_relations`: Xác thực quyền xem con.
  - Bảng `class_sessions`: Lấy thông tin môn học, ca học, ngày giờ.
  - Bảng `session_attendances`: Lấy thời gian vào lớp, số phút tham gia, trạng thái đúng giờ.
  - Bảng `grades`: Lấy điểm quiz trên lớp (`score`, `max_score`) và nhận xét của giáo viên (`feedback`).
  - Bảng `assignments`: Lấy bài tập về nhà liên quan đến buổi học.
  - Bảng `users`: Lấy thông tin họ tên, avatar của giáo viên giảng dạy.
- **Xử lý Graceful Failure:** Nếu một trong các dữ liệu phụ (quiz, nhận xét, bài tập) chưa có trong DB, API tự động trả về `nil` cho trường đó thay vì trả về lỗi 500.

---

## 5. ĐẶC TẢ CHI TIẾT API BACKEND MỚI

### 5.1. Thông tin Endpoint
- **HTTP Method:** `GET`
- **Route Path:** `/api/parent/children/:id/sessions/:sessionId/analysis`
  - `:id`: UUID của học sinh (con).
  - `:sessionId`: UUID của ca học cụ thể.
- **Middlewares:** `middleware.AuthMiddleware` (yêu cầu JWT token của phụ huynh).
- **Authorization:** Gọi `verifyParentChildRelation(parentID, childID)` đảm bảo quan hệ `active` và phụ huynh có quyền xem học tập (`can_view_grades` hoặc `can_view_progress`).

### 5.2. File DTO mới: `backend/internal/dto/child_session_analysis_dto.go`

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
	Breakdown      []QuizQuestionResultDto `json:"breakdown"`
	CanViewDetail  bool                    `json:"can_view_detail"`
}

type QuizQuestionResultDto struct {
	QuestionGroup string  `json:"question_group"` // "Câu 1, 2 & 4: Rút gọn biểu thức"
	IsCorrect     bool    `json:"is_correct"`
	StatusText    string  `json:"status_text"`    // "Chính xác" | "Chưa đạt"
	ErrorNote     *string `json:"error_note,omitempty"` // "Lỗi đổi dấu tử số..."
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

### 5.3. Logic tổng hợp trong Service (`GetChildSessionAnalysis`)
```go
func (s *ParentDashboardService) GetChildSessionAnalysis(
	ctx context.Context,
	parentID, childID, sessionID uuid.UUID,
) (*dto.ChildSessionAnalysisResponseDto, error) {
	// 1. Xác thực quan hệ Phụ huynh - Con
	relation, err := s.verifyParentChildRelation(ctx, parentID, childID)
	if err != nil {
		return nil, err
	}
	if !relation.CanViewGrades && !relation.CanViewProgress {
		return nil, errors.New("không có quyền xem kết quả học tập")
	}

	// 2. Lấy thông tin ClassSession
	session, err := s.scheduleRepo.GetSessionByID(ctx, sessionID)
	if err != nil || session == nil {
		return nil, errors.New("không tìm thấy thông tin ca học")
	}

	// 3. Lấy điểm danh của học sinh trong ca học này
	att, _ := s.scheduleRepo.GetAttendanceBySessionAndStudent(ctx, sessionID, childID)

	// 4. Lấy điểm số & nhận xét giáo viên từ bảng grades
	grades, _ := s.gradeRepo.GetGradesByStudentID(ctx, childID)
	// Tìm grade có session_id trùng với sessionID

	// 5. Lấy thông tin bài tập về nhà được giao
	// 6. Tổng hợp dữ liệu thành ChildSessionAnalysisResponseDto
	...
}
```

---

## 6. THIẾT KẾ KIẾN TRÚC UI/UX TRÊN MOBILE APP

### 6.1. Tổ chức Màn hình & Tích hợp Tab
Màn hình được triển khai trong file:  
[`mobile/lib/features/parent/presentation/schedule/parent_session_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/parent/presentation/schedule/parent_session_detail_screen.dart)

Sử dụng cấu trúc `DefaultTabController(length: 2, ...)`:
- **AppBar:**
  - Nút Back `<` (bảo toàn state).
  - Status Tag & ID ca học: `• HOÀN THÀNH HÔM NAY` | `ID: TOAN10-B08`.
  - Title: `Bài học: Phân số cơ bản · Minh` (Locked child context).
  - Subtitle: `Toán nâng cao 10 · Buổi 8 (Thứ Năm, 24/10)`.
  - Nút `⋮` mở Action Sheet (Chia sẻ báo cáo điểm, Báo cáo thắc mắc).
  - **TabBar:** `[ Tổng quan ]` | `[ Kết quả & nhận xét (•) ]`.

### 6.2. Cấu trúc Tab "Kết quả & nhận xét" (Từ trên xuống dưới)

1. **Card 1: Kết quả bài tập trên lớp (`SessionQuizResultCard`)**
   - Tiêu đề phụ: `Quiz & Thực hành tính toán nhanh`.
   - Badge đánh giá: `Cần rèn luyện thêm` (cam) / `Xuất sắc` (xanh) / `Đạt yêu cầu` (xanh lá).
   - Chỉ số điểm: `3 / 5 đúng` kèm badge `60%`.
   - Vòng tròn tiến độ tròn `CircularProgressIndicator` với tỷ lệ 3/5.
   - Thời gian làm: `18 phút / 25 phút`.
   - Danh sách câu hỏi: Phân nhóm câu đúng (màu xanh kèm checkmark) và câu chưa đạt (màu đỏ kèm icon cảnh báo và ghi chú lỗi nếu có).
   - Nút hành động phụ: TextButton `[Xem chi tiết bài làm của con ->]` mở dialog/sheet xem câu trả lời.

2. **Card 2: Đánh giá & nhận xét của giáo viên (`SessionTeacherFeedbackCard`)**
   - Header giáo viên: Avatar tròn, Họ tên, Học vị (`ThS. Toán`), Phân môn (`Bộ môn Toán`).
   - Thời gian nhận xét: `Đã nhận xét lúc 11:30 hôm nay`.
   - Hộp trích dẫn (Quote container) với viền dọc màu xanh thương hiệu chứa toàn bộ lời khuyên, nhận xét của giáo viên dành riêng cho con.
   - Tag học vụ chuẩn xác: `Chuyên cần: Đúng giờ (58/60 phút)`. *(Không hiển thị focus score theo Gate UX).*

3. **Card 3: Bài tập về nhà & Bước tiếp theo (`SessionHomeworkNextStepCard`)**
   - Card nền kem viền cam nhạt cảnh báo bài tập cần hoàn thành.
   - Icon cảnh báo màu cam.
   - Tên bài tập: `Toán 10 — Bài luyện tập 5: Rút gọn phân số có ẩn`.
   - Hạn chót nộp bài: `Hạn chót: 20:00 tối nay` (chữ đỏ nổi bật).
   - Link điều hướng mở rộng: `[📊 Xem phân tích chi tiết tiến độ (Insights) ->]` mở màn hình Insights được filter sẵn môn Toán.

4. **Sticky Bottom Action Bar (Cố định ở đáy)**
   - Nút phụ (Trái): `[ 💬 Nhắn tin cô Lan ]` (Outline Button).
   - Nút chính (Phải): `[ Nhắc con ôn luyện -> ]` hoặc `[ Xem bài tập về nhà -> ]` (Elevated Button màu xanh primary).

---

## 7. MA TRẬN DỮ LIỆU & EMPTY / EDGE STATES

| Tình huống thực tế | Dữ liệu API trả về | Cách hiển thị trên giao diện (Mobile UI) |
|---|---|---|
| **Ca học sắp tới (`upcoming`)** | Chưa có kết quả, `status == "upcoming"` | Tab Kết quả hiển thị Empty State lịch sự: Icon đồng hồ + Text: *"Buổi học chưa diễn ra. Kết quả và nhận xét của giáo viên sẽ hiển thị sau khi buổi học kết thúc."* |
| **Buổi học vừa xong, giáo viên chưa chấm/nhận xét** | `quiz_result == null`, `teacher_feedback == null` | Card Nhận xét hiển thị: Icon ghi chú + Text: *"Giáo viên đang hoàn thiện đánh giá buổi học. Phụ huynh vui lòng quay lại sau ít phút."* |
| **Buổi học không có Quiz trên lớp** | `quiz_result == null` | Card Quiz tự động ẩn, chỉ hiển thị nhận xét buổi học và bài tập về nhà. |
| **Con vắng mặt có phép / không phép** | `attendance.status == "absent"` | Hiển thị Banner cảnh báo: *"Con vắng mặt trong buổi học này. Phụ huynh nên nhắc con xem lại Video bài giảng ở tab Tổng quan để theo kịp tiến độ."* |
| **Không có bài tập về nhà** | `homework == null` | Card bài tập hiển thị: Icon check xanh + Text: *"Không có bài tập về nhà cho buổi học này. Con đã hoàn thành tốt nội dung trên lớp."* |

---

## 8. LỘ TRÌNH TRIỂN KHAI TỪNG BƯỚC

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
- **Bước 3.1:** Tích hợp `DefaultTabController(length: 2)` vào `parent_session_detail_screen.dart`.
- **Bước 3.2:** Xây dựng Widget `_buildQuizResultCard` (điểm số, tỷ lệ, danh sách câu đúng/sai).
- **Bước 3.3:** Xây dựng Widget `_buildTeacherFeedbackCard` (hộp thoại trích dẫn, tag chuyên cần chuẩn).
- **Bước 3.4:** Xây dựng Widget `_buildHomeworkNextStepCard` và liên kết sang Insights.
- **Bước 3.5:** Tối ưu Sticky Bottom Bar cho phụ huynh.
- **Bước 3.6:** Chạy `flutter analyze` đạt 0 issues, commit ngắn gọn bằng tiếng Việt và push lên `UI/Parent`.

---

## 9. TIÊU CHÍ NGHIỆM THU & BẢO ĐẢM CHẤT LƯỢNG (QUALITY GATES)

1. **Không hồi quy Backend (Zero Regressions):** Toàn bộ 7 API phụ huynh hiện có và các API hệ thống khác hoạt động bình thường 100%, không bị ảnh hưởng.
2. **Khóa ngữ cảnh chuẩn:** AppBar hiển thị đúng tên con và thông tin buổi học, không có child selector.
3. **Chuyển Tab mượt mà:** Chuyển đổi giữa `Tổng quan` và `Kết quả & nhận xét` mượt mà, lưu giữ vị trí cuộn.
4. **Phân cấp thị giác rõ nét:** Nền `surfaceBg`, các Card trắng nổi bật, điểm số và câu hỏi trực quan.
5. **Không vi phạm Privacy Gate:** Không hiển thị focus/engagement score giả định.
6. **Đúng vai trò phụ huynh:** Nút hành động ở đáy màn hình phù hợp với phụ huynh (nhắc con / xem bài tập), không phải nút làm bài thi của học sinh.
7. **Xử lý Empty State mượt mà:** Tài khoản con thật không bị crash, hiển thị thông báo rỗng chuẩn mực khi chưa có dữ liệu từ backend.
8. **Linter & Clean Code:** `flutter analyze` đạt 0 issues, comment giải thích rõ ràng bằng tiếng Việt.
