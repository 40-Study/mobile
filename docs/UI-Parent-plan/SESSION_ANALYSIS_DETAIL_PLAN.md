# KẾ HOẠCH TRIỂN KHAI MÀN HÌNH PHÂN TÍCH KẾT QUẢ BUỔI HỌC DÀNH CHO PHỤ HUYNH
## (PARENT SESSION LEARNING ANALYSIS & FEEDBACK)

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/`)  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả UX Deliverable A–H, Locked child context, Lesson Detail #9)  
> - Ảnh thiết kế: `uploaded_media_1790610728113.png` (Chi tiết phân tích kết quả buổi học & nhận xét)  
> - Hệ thống backend hiện tại: `backend/internal/` (Go / Fiber / GORM / PostgreSQL)  
> **Ngày lập kế hoạch:** 28/09/2026  
> **Phiên bản:** 1.0  

---

## MỤC LỤC
1. [TỔNG QUAN & BỐI CẢNH DỰ ÁN](#1-tổng-quan--bối-cảnh-dự-án)
2. [PHÂN TÍCH ĐỐI CHIẾU THIẾT KẾ VỚI DELIVERABLE.MD](#2-phân-tích-đối-chiếu-thiết-kế-với-deliverablemd)
3. [CÁC ĐIỂM CHƯA HỢP LÝ TRONG THIẾT KẾ & ĐỀ XUẤT GIẢI PHÁP](#3-các-điểm-chưa-hợp-lý-trong-thiết-kế--đề-xuất-giải-pháp)
4. [ĐẶC TẢ API BACKEND CẦN BỔ SUNG (BACKEND API SPECIFICATION)](#4-đặc-tả-api-backend-cần-bổ-sung)
5. [THIẾT KẾ KIẾN TRÚC UI/UX TRÊN MOBILE APP](#5-thiết-kế-kiến-trúc-uiux-trên-mobile-app)
6. [MA TRẬN DỮ LIỆU & EMPTY / EDGE STATES](#6-ma-trận-dữ-liệu--empty--edge-states)
7. [LỘ TRÌNH TRIỂN KHAI TỪNG BƯỚC (STEP-BY-STEP ROADMAP)](#7-lộ-trình-triển-khai-từng-bước)
8. [TIÊU CHÍ NGHIỆM THU (ACCEPTANCE CRITERIA)](#8-tiêu-chí-nghiệm-thu)

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

## 4. ĐẶC TẢ API BACKEND CẦN BỔ SUNG

Hiện tại Backend đã có bảng `grades`, `session_attendances`, `assignments`. Backend cần xây dựng thêm Endpoint tổng hợp (aggregation) để cung cấp toàn bộ dữ liệu phân tích buổi học cho phụ huynh.

### 4.1. Thông tin Endpoint
- **Method:** `GET`
- **URL:** `/api/parent/children/:childId/sessions/:sessionId/analysis`
- **Quyền truy cập:** `AuthMiddleware` + Kiểm tra quan hệ Phụ huynh - Con (`verifyParentChildRelation`).

### 4.2. Response DTO (Go struct)

```go
package dto

import "time"

// ChildSessionAnalysisResponseDto - Dữ liệu chi tiết phân tích buổi học của con
type ChildSessionAnalysisResponseDto struct {
    SessionID     string `json:"session_id"`
    SessionCode   string `json:"session_code"`   // VD: "TOAN10-B08"
    SessionNumber int    `json:"session_number"` // 8
    LessonTitle   string `json:"lesson_title"`   // "Phân số cơ bản"
    ClassName     string `json:"class_name"`     // "Toán nâng cao 10"
    SessionDate   string `json:"session_date"`   // "2024-10-24"
    Status        string `json:"status"`         // "completed", "in_progress", "upcoming"
    StatusLabel   string `json:"status_label"`   // "Hoàn thành hôm nay"

    // 1. Kết quả kiểm tra / Quiz trên lớp
    QuizResult *SessionQuizAnalysisDto `json:"quiz_result,omitempty"`

    // 2. Nhận xét của giáo viên
    TeacherFeedback *SessionTeacherFeedbackDto `json:"teacher_feedback,omitempty"`

    // 3. Bài tập về nhà được giao
    Homework *SessionHomeworkTaskDto `json:"homework,omitempty"`

    // 4. Video xem lại & tài liệu (nếu có)
    Recording *SessionRecordingDto `json:"recording,omitempty"`
}

type SessionQuizAnalysisDto struct {
    Title          string                  `json:"title"`           // "Quiz & Thực hành tính toán nhanh"
    ScoreLabel     string                  `json:"score_label"`     // "Cần rèn luyện thêm" | "Xuất sắc" | "Đạt yêu cầu"
    CorrectCount   int                     `json:"correct_count"`   // 3
    TotalQuestions int                     `json:"total_questions"` // 5
    Percentage     float64                 `json:"percentage"`      // 60.0
    TimeSpentMins  int                     `json:"time_spent_mins"` // 18
    TimeLimitMins  int                     `json:"time_limit_mins"` // 25
    Breakdown      []QuizQuestionResultDto `json:"breakdown"`
    CanViewDetail  bool                    `json:"can_view_detail"` // Cho phép xem chi tiết bài làm
    SubmissionID   *string                 `json:"submission_id,omitempty"`
}

type QuizQuestionResultDto struct {
    QuestionGroup string  `json:"question_group"` // "Câu 1, 2 & 4: Rút gọn biểu thức"
    IsCorrect     bool    `json:"is_correct"`
    StatusText    string  `json:"status_text"`    // "Chính xác" | "Chưa đạt"
    ErrorNote     *string `json:"error_note,omitempty"` // "Lỗi đổi dấu tử số..."
}

type SessionTeacherFeedbackDto struct {
    TeacherID       string     `json:"teacher_id"`
    TeacherName     string     `json:"teacher_name"`     // "Cô Phạm Hồng Lan"
    TeacherTitle    *string    `json:"teacher_title"`    // "ThS. Toán"
    Subject         string     `json:"subject"`          // "Bộ môn Toán"
    AvatarURL       *string    `json:"avatar_url"`
    Comment         string     `json:"comment"`          // Nội dung nhận xét
    CommentedAt     *time.Time `json:"commented_at"`     // Thời gian gửi nhận xét
    AttendanceLabel string     `json:"attendance_label"` // "Chuyên cần: Đúng giờ (58/60 phút)"
    CanChat         bool       `json:"can_chat"`
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

### 4.3. Logic tổng hợp dữ liệu Backend (`ParentDashboardService`)
1. **Kiểm tra quyền:** Xác thực `parentID` có quan hệ `active` với `childID` qua `parent_student_relations`.
2. **Lấy thông tin Session:** Truy vấn bảng `class_sessions` theo `sessionID` để lấy tên môn, ngày học, thứ tự buổi học.
3. **Lấy điểm danh:** Truy vấn bảng `session_attendances` theo `session_id` và `student_id` -> tính ra số phút tham gia, trạng thái đúng giờ/muộn.
4. **Lấy kết quả Quiz:** Truy vấn bảng `grades` (hoặc `quiz_submissions`) có `session_id` tương ứng -> lấy điểm số, số câu đúng/sai.
5. **Lấy nhận xét của giáo viên:** Lấy từ cột `feedback` trong bảng `grades` hoặc bảng nhận xét chuyên cần.
6. **Lấy bài tập về nhà:** Truy vấn bảng `assignments` có `session_id` hoặc được giao trong ngày của buổi học đó.

---

## 5. THIẾT KẾ KIẾN TRÚC UI/UX TRÊN MOBILE APP

### 5.1. Tổ chức Màn hình & Tích hợp Tab
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

### 5.2. Cấu trúc Tab "Kết quả & nhận xét" (Từ trên xuống dưới)

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

## 6. MA TRẬN DỮ LIỆU & EMPTY / EDGE STATES

| Tình huống thực tế | Dữ liệu API trả về | Cách hiển thị trên giao diện (Mobile UI) |
|---|---|---|
| **Ca học sắp tới (`upcoming`)** | Chưa có kết quả, `status == "upcoming"` | Tab Kết quả hiển thị Empty State lịch sự: Icon đồng hồ + Text: *"Buổi học chưa diễn ra. Kết quả và nhận xét của giáo viên sẽ hiển thị sau khi buổi học kết thúc."* |
| **Buổi học vừa xong, giáo viên chưa chấm/nhận xét** | `quiz_result == null`, `teacher_feedback == null` | Card Nhận xét hiển thị: Icon ghi chú + Text: *"Giáo viên đang hoàn thiện đánh giá buổi học. Phụ huynh vui lòng quay lại sau ít phút."* |
| **Buổi học không có Quiz trên lớp** | `quiz_result == null` | Card Quiz tự động ẩn, chỉ hiển thị nhận xét buổi học và bài tập về nhà. |
| **Con vắng mặt có phép / không phép** | `attendance_status == "absent"` | Hiển thị Banner cảnh báo: *"Con vắng mặt trong buổi học này. Phụ huynh nên nhắc con xem lại Video bài giảng ở tab Tổng quan để theo kịp tiến độ."* |
| **Không có bài tập về nhà** | `homework == null` | Card bài tập hiển thị: Icon check xanh + Text: *"Không có bài tập về nhà cho buổi học này. Con đã hoàn thành tốt nội dung trên lớp."* |

---

## 7. LỘ TRÌNH TRIỂN KHAI TỪNG BƯỚC

### Giai đoạn 1: Chuẩn hóa Model & Mock Data trên Mobile
- **Bước 1.1:** Cập nhật file [`parent_session_detail_model.dart`](file:///C:/ForteX/mobile/lib/features/parent/data/models/parent_session_detail_model.dart) để bổ sung đầy đủ các DTO theo thiết kế mới: `SessionQuizAnalysis`, `QuizQuestionBreakdown`, `SessionTeacherFeedback`, `SessionHomeworkTask`.
- **Bước 1.2:** Cung cấp mock data đầy đủ cho tài khoản mẫu `Minh` (buổi học hoàn thành có quiz 3/5, nhận xét chi tiết, bài tập về nhà) và giữ rỗng cho tài khoản thật `Mai Hoàng Tùng` (để test Empty State).

### Giai đoạn 2: Xây dựng Giao diện Tab "Kết quả & nhận xét"
- **Bước 2.1:** Thêm `TabController` vào [`parent_session_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/parent/presentation/schedule/parent_session_detail_screen.dart) gồm 2 tab: `Tổng quan` và `Kết quả & nhận xét`.
- **Bước 2.2:** Xây dựng Widget `_buildQuizResultCard` hiển thị điểm số, vòng tròn tỷ lệ, danh sách câu đúng/chưa đạt.
- **Bước 2.3:** Xây dựng Widget `_buildTeacherFeedbackCard` hiển thị nhận xét giáo viên và tag chuyên cần chuẩn.
- **Bước 2.4:** Xây dựng Widget `_buildHomeworkNextStepCard` hiển thị bài tập về nhà cần làm và link xem Insights.
- **Bước 2.5:** Điều chỉnh Bottom Action Bar: Đổi nút thành `[Nhắc con ôn tập]` / `[Xem bài tập về nhà]`.

### Giai đoạn 3: Kiểm thử Linter, Trạng thái & Tài liệu
- **Bước 3.1:** Chạy `flutter analyze` đảm bảo không có lỗi linter.
- **Bước 3.2:** Test hiển thị trên cả 2 theme (Sáng / Tối) và kiểm tra Empty State cho tài khoản thật.
- **Bước 3.3:** Cập nhật tài liệu [`mobile/docs/api-requirements.md`](file:///C:/ForteX/mobile/docs/api-requirements.md) và commit code với message tiếng Việt rõ ràng.

---

## 8. TIÊU CHÍ NGHIỆM THU (ACCEPTANCE CRITERIA)

1. **Khóa ngữ cảnh chuẩn:** AppBar hiển thị đúng tên con và thông tin buổi học, không có child selector.
2. **Chuyển Tab mượt mà:** Chuyển đổi giữa `Tổng quan` và `Kết quả & nhận xét` mượt mà, lưu giữ vị trí cuộn.
3. **Phân cấp thị giác rõ nét:** Nền `surfaceBg`, các Card trắng nổi bật, điểm số và câu hỏi trực quan.
4. **Không vi phạm Privacy Gate:** Không hiển thị focus/engagement score giả định.
5. **Đúng vai trò phụ huynh:** Nút hành động ở đáy màn hình phù hợp với phụ huynh (nhắc con / xem bài tập), không phải nút làm bài thi của học sinh.
6. **Xử lý Empty State mượt mà:** Tài khoản con thật không bị crash, hiển thị thông báo rỗng chuẩn mực khi chưa có dữ liệu từ backend.
7. **Linter & Clean Code:** `flutter analyze` đạt 0 issues, comment giải thích rõ ràng bằng tiếng Việt.
