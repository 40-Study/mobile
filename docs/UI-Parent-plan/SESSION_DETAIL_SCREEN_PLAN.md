# KẾ HOẠCH XÂY DỰNG MÀN HÌNH CHI TIẾT CA HỌC (PARENT SESSION DETAIL SCREEN) - V1.0

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/`)  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả vai trò Phụ huynh, Locked child context, Schedule Detail)  
> - Ảnh thiết kế mới: `uploaded_media_1790607531042.png` (Màn hình Chi tiết buổi học)  
> - Mô hình dữ liệu backend: `backend/internal/dto/parent_dashboard_dto.go` (`ChildUpcomingSessionDto`)  
> - Hiện trạng Mobile: `ParentScheduleSession` & `ParentSessionDetailSheet`  
> **Ngày lập kế hoạch:** 28/09/2026  
> **Phiên bản:** 1.0 (Chuyển đổi từ Bottom Sheet sang Full Screen chuyên sâu, hoàn thiện UX Phụ huynh)

---

## MỤC LỤC
1. [BỐI CẢNH & MỤC TIÊU DỰ ÁN](#1-bối-cảnh--mục-tiêu-dự-án)
2. [ĐỐI CHIẾU VỚI TÀI LIỆU ĐẶC TẢ DELIVERABLE.MD](#2-đối-chiếu-với-tài-liệu-đặc-tả-deliverablemd)
3. [PHÂN TÍCH ẢNH THIẾT KẾ & CÁC ĐIỂM CHƯA HỢP LÝ / CẦN CẢI TIẾN](#3-phân-tích-ảnh-thiết-kế--các-điểm-chưa-hợp-lý--cần-cải-tiến)
4. [KHẢO SÁT & ĐÁNH GIÁ API CHI TIẾT CA HỌC HIỆN TẠI](#4-khảo-sát--đánh-giá-api-chi-tiết-ca-học-hiện-tại)
5. [KIẾN TRÚC GIAO DIỆN & CẤU TRÚC COMPONENT CHUẨN HOÁ](#5-kiến-trúc-giao-diện--cấu-trúc-component-chuẩn-hoá)
6. [THIẾT KẾ DỮ LIỆU (DATA MODEL & MOCK ENRICHMENT)](#6-thiết-kế-dữ-liệu-data-model--mock-enrichment)
7. [MA TRẬN TRẠNG THÁI & XỬ LÝ EDGE CASES](#7-ma-trận-trạng-thái--xử-lý-edge-cases)
8. [KẾ HOẠCH TRIỂN KHAI TỪNG BƯỚC (STEP-BY-STEP ROADMAP)](#8-kế-hoạch-triển-khai-từng-bước)
9. [CHECKLIST NGHIỆM THU CHẤT LƯỢNG (QUALITY GATES)](#9-checklist-nghiệm-thu-chất-lượng)

---

## 1. BỐI CẢNH & MỤC TIÊU DỰ ÁN

### 1.1. Hiện trạng
- Hiện tại, chức năng xem chi tiết ca học dành cho phụ huynh đang được hiển thị dưới dạng một modal popup trượt lên từ đáy màn hình (`ParentSessionDetailSheet`).
- **Hạn chế của giải pháp cũ:**
  1. Không gian hiển thị của Bottom Sheet bị giới hạn, chỉ đủ chỗ chứa thông tin tóm tắt cơ bản (giờ học, tên môn, giáo viên, phòng).
  2. Không đủ diện tích để phụ huynh xem tài liệu học tập chuẩn bị trước buổi học, checklist bài tập/dụng cụ, gợi ý đồng hành của chuyên gia giáo dục, và các hành động hỗ trợ quan trọng (xin nghỉ, nhắn tin giáo viên).
  3. Chiếm dụng cử chỉ vuốt, dễ bị đóng vô tình khi phụ huynh cuộn trang để xem nội dung dài.

### 1.2. Mục tiêu giải pháp mới
- **Chuyển đổi hoàn toàn sang Screen riêng biệt (`ParentSessionDetailScreen`):**
  - Có AppBar chuẩn với nút Back tường minh `<`.
  - Khóa ngữ cảnh con rõ ràng (*Locked child context*).
  - Tận dụng toàn bộ chiều cao màn hình để tổ chức thông tin theo tầng thứ bậc trực quan (Visual Hierarchy), hỗ trợ cuộn mượt mà (`SingleChildScrollView`).
  - Tích hợp khu vực hành động cố định ở đáy (*Sticky Bottom Actions*) an toàn với Safe Area.
  - Đồng bộ hóa entry point: Cả Card ca học tại **Trang chủ (`ParentHomeScreen`)** và tại **Tab Lịch học (`ParentScheduleScreen`)** đều điều hướng vào cùng một màn hình chi tiết chuẩn này.

---

## 2. ĐỐI CHIẾU VỚI TÀI LIỆU ĐẶC TẢ DELIVERABLE.MD

Dựa trên tài liệu đặc tả UX chuẩn `C:\Users\tungm\Downloads\deliverable.md`, các yêu cầu bắt buộc đối với màn hình chi tiết buổi học của Phụ huynh gồm:

| Tiêu chí | Quy định trong `deliverable.md` | Áp dụng vào `ParentSessionDetailScreen` |
|---|---|---|
| **Context Scope** | *Locked child context* (Dòng 254): Header có back + title/subtitle ghi rõ tên con (VD: `Buổi học • Minh`). **Tuyệt đối không có Child Selector** — đổi con không có ý nghĩa ở tầng detail này. | AppBar hiển thị: Title `Buổi học • [Tên con]`, Subtitle `[Lớp học] — Niên khóa 2024–2025`. Ẩn thanh chọn con. |
| **Quyền hạn vai trò Phụ huynh** | Phụ huynh đóng vai trò **đồng hành & giám sát**, **KHÔNG CÓ NÚT VÀO HỌC (Join Meeting / Enter Class)**. | Chỉ hiển thị hình thức (Google Meet / Tại cơ sở) và phòng học để phụ huynh biết, không tạo CTA cho phụ huynh vào lớp học của con. |
| **Back Navigation** | Dòng 265: Luôn có nút back tường minh trong header (không chỉ dựa vào gesture OS). Khi Back phải bảo toàn child đang chọn, ngày đang chọn trên lịch, và vị trí cuộn. | Nút Back trên AppBar thực hiện `Navigator.of(context).pop()`, trả lại nguyên vẹn trạng thái của màn hình gọi trước đó. |
| **Primary Action** | Dòng 341-342: Xem giờ, hình thức, phòng học, giáo viên; chuyển tiếp sang `Lesson Detail` nếu buổi học đã/đang diễn ra. | Cung cấp Primary Button `[📖 Xem chi tiết bài học & giáo trình]` chuyển tiếp tới nội dung học tập chuyên sâu. |
| **Future Components** | Dòng 728 & 741: Nút "Thêm nhắc lịch" / "Add to Calendar" tại Schedule Detail. | Đặt icon Lịch trên AppBar để thêm sự kiện vào ứng dụng Calendar mặc định của máy thông qua intent/url_launcher. |
| **Lý do thay đổi lịch** | Dòng 294: Nếu buổi học bị hủy (`Cancelled`) hoặc dời lịch (`Rescheduled`), Schedule Detail phải hiện box lý do nếu trung tâm cung cấp. | Bổ sung Banner cảnh báo màu cam/đỏ hiển thị lý do thay đổi và thời gian dời lịch mới. |

---

## 3. PHÂN TÍCH ẢNH THIẾT KẾ & CÁC ĐIỂM CHƯA HỢP LÝ / CẦN CẢI TIẾN

Dựa trên việc đối chiếu từng pixel từ ảnh thiết kế `uploaded_media_1790607531042.png`:

```
┌─────────────────────────────────────────────────────────────────┐
│ 08:15                                                📶 🔋       │
│ <   Buổi học • Minh                            📅   🔗          │
│     Lớp 10A1 — Niên khóa 2024–2025                             │
├─────────────────────────────────────────────────────────────────┤
│ (M)  Nguyễn Nhật Minh · 10A1               • Sắp diễn ra · 45p   │
│  🟢  Khối chuyên Toán Tin                                       │
├─────────────────────────────────────────────────────────────────┤
│ [TOÁN HỌC (ĐẠI SỐ 10)]                               #MAT10-B24 │
│ 09:00 — 10:00                                                   │
│ Hôm nay (Thứ Sáu, 24/10/2024)                                   │
│ Phương trình bậc hai & Ứng dụng parabol thực tế                 │
│ Chương trình chuyên sâu Đại số & Giải tích 10                   │
│                                                                 │
│ 🖥  Hình thức:             • Trực tuyến (Google Meet)           │
│ 👤  Giáo viên:             Cô Lan (ThS. Toán) [💬]              │
│                           THPT Chuyên Hà Nội - Amsterdam        │
│ ⏱  Điểm danh:             Chưa mở điểm danh (Mở trước 10p)     │
├─────────────────────────────────────────────────────────────────┤
│ CHUẨN BỊ TRƯỚC BUỔI HỌC                                         │
│ [PDF] Bai_tap_chuyen_de_Parabol_T10.pdf (2.4 MB)            ⬇️   │
│ ✓  Mang theo máy tính Casio fx-580VNX hoặc tương đương.          │
│ ✓  Đã hoàn thành 5 câu hỏi trắc nghiệm khởi động trên app.      │
├─────────────────────────────────────────────────────────────────┤
│ 💡 Gợi ý đồng hành cùng con                                     │
│    Phụ huynh nên nhắc Minh kiểm tra tai nghe, Internet...       │
├─────────────────────────────────────────────────────────────────┤
│ [📖 Xem chi tiết bài học & giáo trình]                          │
│ ⚠️ Xin phép vắng / Đến muộn              ✉️ Nhắn tin cô Lan    │
└─────────────────────────────────────────────────────────────────┘
```

### 3.1. Các điểm xuất sắc trong thiết kế
1. **Header chuẩn Locked Child Context:** Thể hiện rõ tên con và lớp học, mang lại cảm giác an tâm và chính xác cho phụ huynh có nhiều con.
2. **Khung giờ to rõ (High Visual Impact):** Giờ học `09:00 — 10:00` in đậm nổi bật, giúp phụ huynh nắm bắt thời gian trong tích tắc.
3. **Card "Gợi ý đồng hành cùng con":** Lời khuyên thiết thực, định hướng phụ huynh cách hỗ trợ con trước buổi học (kiểm tra thiết bị, tạo không gian yên tĩnh) mà không can thiệp sâu vào chuyên môn học tập.
4. **Section "Chuẩn bị trước buổi học":** Giúp phụ huynh kiểm tra được dụng cụ học tập và tài liệu con cần có.

### 3.2. Bốn (4) điểm CHƯA HỢP LÝ trong thiết kế cần cải tiến:

#### ❌ Điểm chưa hợp lý 1: Thông tin bị lặp lại 3 lần (Redundancy)
- **Hiện tượng:** Cụm từ `10A1` xuất hiện tại:
  1. Subtitle AppBar: `Lớp 10A1 — Niên khóa 2024–2025`
  2. Tên con: `Nguyễn Nhật Minh · 10A1`
  3. Badge môn: `TOÁN HỌC (ĐẠI SỐ 10)`
- **Giải pháp tối ưu:** 
  - Subtitle AppBar giữ `Lớp 10A1 — Niên khóa 2024–2025`.
  - Card định danh con chỉ cần hiển thị: Họ và tên đầy đủ `Nguyễn Nhật Minh`, dòng phụ là `Khối chuyên Toán Tin` hoặc mã học sinh `MSHS: HS-10294`. Không lặp lại `· 10A1` ngay cạnh tên.

#### ❌ Điểm chưa hợp lý 2: Chấm trạng thái và Badge đặt sai phân cấp (Hierarchy Mismatch)
- **Hiện tượng:**
  1. Avatar con có **chấm xanh lá online 🟢**: Phụ huynh dễ hiểu lầm là con đang trong phòng học Meet hoặc đang mở app, trong khi ca học còn 45 phút nữa mới bắt đầu!
  2. Badge trạng thái `• Sắp diễn ra · 45p` lại nằm chung hàng với Card thông tin con: Trạng thái "Sắp diễn ra" là trạng thái của **Ca học**, không phải trạng thái của học sinh.
- **Giải pháp tối ưu:**
  - Bỏ chấm xanh online trên avatar nếu không có tính năng real-time presence thực sự.
  - Di chuyển Badge trạng thái ca học xuống khối **Session Core Card** (ngay cạnh Mã buổi học `#MAT10-B24` hoặc đặt cạnh khung giờ), đảm bảo tính liên kết thông tin chặt chẽ.

#### ❌ Điểm chưa hợp lý 3: Dấu tích xanh `✓` trong Checklist gây hiểu nhầm
- **Hiện tượng:** Cả 2 mục trong checklist đều có dấu tích xanh `✓` kèm text:
  - `✓ Mang theo máy tính Casio...` (Việc cần làm)
  - `✓ Đã hoàn thành 5 câu trắc nghiệm...` (Việc đã làm?)
  - Dấu `✓` xanh lá tạo cảm giác mục đó **ĐÃ ĐƯỢC HOÀN THÀNH**, phụ huynh nhìn lướt sẽ nghĩ con đã chuẩn bị xong máy tính và bài tập, dẫn đến việc bỏ qua không nhắc con.
- **Giải pháp tối ưu:**
  - Với đồ dùng cần mang theo: Dùng icon bullet tròn nhỏ hoặc icon vật dụng `[🎒] Mang theo máy tính...`.
  - Với nhiệm vụ học tập: Thể hiện trạng thái rõ ràng:
    - Nếu đã hoàn thành: Icon tích xanh `✓ Đã làm 5/5 câu trắc nghiệm khởi động`.
    - Nếu chưa làm: Icon cảnh báo cam `⏱ Chưa làm bài trắc nghiệm khởi động` kèm text link nhắc con làm.

#### ❌ Điểm chưa hợp lý 4: Khu vực nút bấm sát đáy vi phạm Safe Area (UX Hazard)
- **Hiện tượng:** Hai liên kết text `⚠️ Xin phép vắng / Đến muộn` và `✉️ Nhắn tin cô Lan` nằm sát mép dưới cùng màn hình. Trên các dòng điện thoại hiện đại (iOS Home Indicator, Android Gesture Navigation Bar), thao tác chạm vào 2 link này cực kỳ dễ bị vướng hoặc kích hoạt nhầm thanh điều hướng hệ thống.
- **Giải pháp tối ưu:**
  - Đóng gói toàn bộ cụm hành động đáy vào một **Sticky Bottom Action Bar**:
    - Nền trắng `Colors.white`, viền trên mờ `Border(top: BorderSide(color: Color(0xFFF1F5F9)))`, đổ bóng nhẹ `AppShadows.card`.
    - Tự động cộng thêm `MediaQuery.paddingOf(context).bottom`.
    - Bố cục 2 tầng rõ ràng:
      - Tầng trên (Quick Actions): 2 nút Tonal/Outlined Button nhỏ gọn cạnh nhau: `[⚠️ Báo vắng/Muộn]` và `[💬 Nhắn giáo viên]`.
      - Tầng dưới (Primary CTA): Nút bấm lớn nổi bật `[📖 Xem chi tiết bài học & giáo trình]`.

#### ❌ Điểm chưa hợp lý 5: Chưa bao quát các trạng thái vòng đời khác của ca học
- **Hiện tượng:** Mockup chỉ vẽ cho trường hợp ca học `Sắp diễn ra` (Upcoming).
- **Giải pháp tối ưu:** Cần thiết kế giao diện thích ứng động theo 4 trạng thái:
  1. **Đang diễn ra (In Progress):** Badge chuyển màu xanh lá pulsing `• Đang học · Còn 35p`, Điểm danh hiển thị `Đã vào lớp lúc 09:02`, Card đồng hành gợi ý `Giữ không gian yên tĩnh cho con tập trung`.
  2. **Đã kết thúc (Completed):** Ẩn checklist chuẩn bị, thay bằng Section `KẾT QUẢ BUỔI HỌC` (Điểm danh: Có mặt, Đánh giá của giáo viên: "Minh hăng hái phát biểu, nắm vững định lý Vi-ét", Bài tập về nhà được giao: 1 bài tập hạn nộp 2 ngày tới). Primary CTA đổi thành `Xem chi tiết buổi học & kết quả`.
  3. **Đã đổi lịch (Rescheduled):** Badge màu cam `Đã đổi lịch`, hiển thị Banner cảnh báo màu cam với lý do đổi lịch và thời gian học mới.
  4. **Đã hủy (Cancelled):** Badge màu đỏ `Đã hủy`, hiển thị Banner màu đỏ thông báo nguyên nhân hủy và thông tin học bù nếu có.

---

## 4. KHẢO SÁT & ĐÁNH GIÁ API CHI TIẾT CA HỌC HIỆN TẠI

### 4.1. Backend API hiện tại (`GetChildSchedule`)
Endpoint: `GET /parent/children/:id/schedule`  
DTO: `ChildScheduleResponseDto` chứa danh sách `UpcomingSessions` kiểu `ChildUpcomingSessionDto`:
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

### 4.2. Bảng so sánh trường dữ liệu UI cần vs. API hiện có:

| Trường thông tin trên UI | Backend API hiện có | Đánh giá | Giải pháp xử lý trên Mobile |
|---|---|---|---|
| ID buổi học | `id` | ✅ Đầy đủ | Map trực tiếp vào Model |
| Tên môn học / Lớp | `class_name` | ✅ Đầy đủ | Map trực tiếp |
| Thứ tự buổi học | `session_number` | ✅ Đầy đủ | Tự sinh mã buổi `#MAT10-B{session_number}` |
| Tên bài học | `topic` | ✅ Đầy đủ | Map trực tiếp |
| Ngày & Giờ học | `date`, `start_time`, `end_time` | ✅ Đầy đủ | Parse thành `DateTime` chính xác |
| Phòng học / Nền tảng | `room` | ✅ Đầy đủ | Phân loại: Nếu chứa "Meet"/"Zoom" là Online, còn lại là Cơ sở |
| Học vị & Nơi công tác của GV | ❌ Chưa có | Thiếu | Mock enrich theo môn học (VD: "Cô Lan (ThS. Toán) - THPT Chuyên HN") |
| Trạng thái điểm danh tức thời | ❌ Chưa có | Thiếu | Dựa vào thời gian thực: Nếu chưa đến giờ -> "Chưa mở điểm danh"; nếu đã qua -> "Có mặt" |
| Danh sách file đính kèm | ❌ Chưa có | Thiếu | Tạo Model `SessionMaterial`, mock enrich file PDF bài tập theo chủ đề môn |
| Checklist chuẩn bị | ❌ Chưa có | Thiếu | Tạo Model `SessionChecklistItem`, mock enrich các yêu cầu phù hợp với môn học |
| Gợi ý đồng hành cùng con | ❌ Chưa có | Thiếu | Thuật toán sinh câu gợi ý thông minh dựa trên môn học và hình thức (Online/Offline) |

---

## 5. KIẾN TRÚC GIAO DIỆN & CẤU TRÚC COMPONENT CHUẨN HOÁ

### 5.1. Tổ chức thư mục & File
```text
mobile/lib/features/parent/
├── data/
│   └── models/
│       ├── parent_schedule_session.dart        <-- Cập nhật thêm các getter & helper
│       └── parent_session_detail_model.dart    <-- Model mở rộng chứa Material, Checklist, Guidance
├── presentation/
│   ├── schedule/
│   │   ├── parent_schedule_screen.dart         <-- Cập nhật tap card mở Full Screen
│   │   └── parent_session_detail_screen.dart   <-- MÀN HÌNH MỚI (Full Screen)
│   ├── home/
│   │   └── widgets/
│   │       └── upcoming_schedule_section.dart  <-- Cập nhật tap card mở Full Screen
│   └── widgets/
│       └── parent_session_detail_sheet.dart    <-- Giữ lại làm fallback hoặc redirect sang screen
```

### 5.2. Cấu trúc Component trong `ParentSessionDetailScreen`
Màn hình được phân rã thành các sub-widgets độc lập để code sạch sẽ, dễ bảo trì:

1. **`_DetailAppBar` (Custom PreferredSizeWidget):**
   - Nút Back `<` với `Navigator.of(context).pop()`.
   - Title: `Buổi học • [Tên con]`.
   - Subtitle: `[Tên lớp] — Niên khóa 2024–2025`.
   - Action 1: Icon Lịch 📅 (`Icons.calendar_today_outlined`) -> Mở hộp thoại xác nhận thêm vào Lịch thiết bị.
   - Action 2: Icon Chia sẻ 🔗 (`Icons.share_outlined`) -> Mở hộp thoại tóm tắt thông tin ca học để gửi qua tin nhắn.

2. **`_ChildIdentityCard`:**
   - Card nền trắng bo góc, viền nhẹ.
   - Avatar chữ cái đầu với màu pastel đại diện cho con (Minh: `#DBEAFE`, Lan: `#FCE7F3`, Tùng: `#E0E7FF`).
   - Cột thông tin: Họ và tên đầy đủ (bold `w700`) + Dòng phụ (Khối chuyên / Mã học sinh).
   - Tag môn học phụ.

3. **`_SessionHeroCard`:**
   - Badge môn học nền xanh nhạt: `TOÁN HỌC (ĐẠI SỐ 10)`.
   - Badge mã buổi học & Trạng thái: `#MAT10-B24` + Badge `• Sắp diễn ra · 45p`.
   - Khung giờ cực lớn: **`09:00 — 10:00`** (font size 28px, deep slate 900).
   - Subtitle thứ & ngày: `Hôm nay (Thứ Sáu, 24/10/2024)`.
   - Tiêu đề bài học: `Phương trình bậc hai & Ứng dụng parabol thực tế` (font size 16px, `w700`).
   - Mô tả bài học: `Chương trình chuyên sâu Đại số & Giải tích 10`.

4. **`_SessionMetaSection`:**
   - Hàng Hình thức: Icon `Icons.computer_rounded` + Label "Hình thức" + Value `Trực tuyến (Google Meet)` hoặc `Phòng 401, Cơ sở Phan Xích Long`.
   - Hàng Giáo viên: Icon `Icons.person_outline_rounded` + Label "Giáo viên" + Value `Cô Lan (ThS. Toán)` + Nút icon chat nhắn tin nhanh.
   - Hàng Điểm danh: Icon `Icons.access_time_rounded` + Label "Điểm danh" + Value `Chưa mở điểm danh (Mở trước giờ học 10p)`.

5. **`_PreparationSection`:**
   - Tiêu đề in hoa `CHUẨN BỊ TRƯỚC BUỔI HỌC` (slate 500, font 12px, `w700`).
   - Thẻ File đính kèm:
     - Icon file PDF đỏ bo góc vuông nhỏ `PDF`.
     - Tên file: `Bai_tap_chuyen_de_Parabol_T10.pdf`.
     - Dung lượng & thời gian: `2.4 MB • Giáo viên gửi hôm qua`.
     - Nút icon Tải về `Icons.download_rounded` -> Hiển thị SnackBar giả lập tải thành công.
   - Danh sách Checklist chuẩn bị:
     - Mục 1: `🎒 Mang theo máy tính Casio fx-580VNX hoặc tương đương.`
     - Mục 2: `📝 Đã hoàn thành 5 câu hỏi trắc nghiệm khởi động trên ứng dụng.`

6. **`_ParentGuidanceCard`:**
   - Container bo góc 14px, nền xanh pastel mượt mà (`#F0FDF4` hoặc `#F0F7FF`), viền nhẹ.
   - Icon bóng đèn xanh dương / vàng `Icons.lightbulb_outline_rounded`.
   - Tiêu đề: **Gợi ý đồng hành cùng con**.
   - Nội dung: Lời khuyên thiết thực nhắc phụ huynh kiểm tra đường truyền, tai nghe và nhắc con vào bàn học trước 5-10 phút.

7. **`_StickyBottomActionBar`:**
   - Bọc trong `SafeArea(top: false)`.
   - Container trắng cố định dưới cùng với bóng đổ nhẹ.
   - Hàng nút phụ:
     - Nút `[⚠️ Xin phép vắng / Đến muộn]`: Outlined Button viền màu xám, icon tam giác cảnh báo cam -> Mở Bottom Sheet xin phép nghỉ học.
     - Nút `[💬 Nhắn tin giáo viên]`: Outlined Button viền xanh dương, icon chat -> Mở hộp thoại liên hệ giáo viên.
   - Hàng nút chính:
     - Nút `[📖 Xem chi tiết bài học & giáo trình]`: Filled Button hoặc Tinted Button với icon quyển sách -> Thông báo mở chi tiết giáo trình.

---

## 6. THIẾT KẾ DỮ LIỆU (DATA MODEL & MOCK ENRICHMENT)

### 6.1. Định nghĩa Data Models
```dart
/// Model mở rộng cho chi tiết buổi học của Phụ huynh
class ParentSessionDetail {
  final ParentScheduleSession session;
  final String? studentCode;
  final String? studentMajor; // vd: "Khối chuyên Toán Tin"
  final String? schoolYear;   // vd: "Lớp 10A1 — Niên khóa 2024–2025"
  final String? teacherTitle; // vd: "Cô Lan (ThS. Toán)"
  final String? teacherSchool;// vd: "THPT Chuyên Hà Nội - Amsterdam"
  final String? attendanceNote; // vd: "Chưa mở điểm danh (Mở trước 10p)"
  final List<SessionMaterial> materials;
  final List<SessionChecklistItem> checklist;
  final String? parentGuidance;
  final String? sessionCode;  // vd: "#MAT10-B24"
  final String? rescheduleReason;

  const ParentSessionDetail({
    required this.session,
    this.studentCode,
    this.studentMajor,
    this.schoolYear,
    this.teacherTitle,
    this.teacherSchool,
    this.attendanceNote,
    this.materials = const [],
    this.checklist = const [],
    this.parentGuidance,
    this.sessionCode,
    this.rescheduleReason,
  });
}

class SessionMaterial {
  final String fileName;
  final String fileSize;
  final String uploadTime;
  final String fileType; // "pdf", "docx", etc.
  final String? downloadUrl;

  const SessionMaterial({
    required this.fileName,
    required this.fileSize,
    required this.uploadTime,
    this.fileType = 'pdf',
    this.downloadUrl,
  });
}

class SessionChecklistItem {
  final String text;
  final bool isCompleted;
  final String? actionHint;

  const SessionChecklistItem({
    required this.text,
    this.isCompleted = false,
    this.actionHint,
  });
}
```

### 6.2. Nguyên tắc hiển thị dữ liệu & Xử lý trạng thái rỗng (Empty States)

Tuân thủ nghiêm ngặt chỉ đạo sản phẩm: **Tuyệt đối không bịa đặt mock data cho tài khoản thật. Những trường thông tin API chưa trả về thì hiển thị rỗng một cách thẩm mỹ và minh bạch trên giao diện:**

1. **Đối với tài khoản thật (hoặc bất kỳ ca học nào từ API):**
   - **Tài liệu đính kèm (`materials` rỗng / `null`):**
     - Hiển thị card trạng thái rỗng thanh lịch: Icon `Icons.folder_open_outlined` màu xám + Text `Tài liệu đính kèm: Chưa có tài liệu nào cho buổi học này.`
   - **Checklist chuẩn bị (`checklist` rỗng / `null`):**
     - Hiển thị card trạng thái rỗng: Icon `Icons.assignment_outlined` màu xám + Text `Nhiệm vụ chuẩn bị: Chưa có nhiệm vụ hoặc dụng cụ yêu cầu riêng.`
   - **Gợi ý đồng hành cùng con (`parentGuidance` rỗng / `null`):**
     - Hiển thị card thông báo nhẹ: Icon `Icons.lightbulb_outline` màu vàng nhạt + Text `Gợi ý đồng hành: Chưa có gợi ý đặc biệt từ giáo viên cho buổi học này.`
   - **Thông tin giáo viên (`teacherTitle`, `teacherSchool` là `null`):**
     - Chỉ hiển thị tên giáo viên (`Cô Lan`) lấy từ API, không tự bịa học vị hay trường công tác.
   - **Trạng thái điểm danh (`attendanceNote` là `null`):**
     - Hiển thị text: `Chưa có thông tin điểm danh` (hoặc `Chưa mở điểm danh` nếu ca học sắp diễn ra).
   - **Lý do dời/hủy lịch (`rescheduleReason` là `null`):**
     - Ẩn hoàn toàn khối banner cảnh báo đổi lịch.

2. **Đối với 2 tài khoản mẫu phục vụ demo Family Scope (Minh & Lan):**
   - Gắn dữ liệu mẫu phong phú (file PDF, checklist, gợi ý đồng hành) bám sát 100% hình ảnh thiết kế `uploaded_media_1790607531042.png` để phục vụ review giao diện và trải nghiệm mockup trực quan.

---

## 7. MA TRẬN TRẠNG THÁI & XỬ LÝ EDGE CASES

| Trường hợp (Case) | Giao diện thích ứng (UI Adaptation) |
|---|---|
| **Ca học Online (Google Meet/Zoom)** | - Icon màn hình 🖥 + Text `Trực tuyến (Google Meet)`<br>- Gợi ý đồng hành: Nhắc phụ huynh kiểm tra tai nghe, mạng Internet và góc học tập yên tĩnh.<br>- **Tuyệt đối KHÔNG có nút Vào Meet** cho phụ huynh. |
| **Ca học Trực tiếp (Tại cơ sở)** | - Icon vị trí 📍 + Text `Phòng 401, Cơ sở Phan Xích Long`<br>- Gợi ý đồng hành: Nhắc phụ huynh đưa con đến lớp trước 10 phút, kiểm tra mũ bảo hiểm và bình nước cá nhân. |
| **Ca học Đang diễn ra (In Progress)** | - Badge xanh lá `• Đang diễn ra`<br>- Điểm danh: `Đã vào lớp lúc 09:02` (hoặc `Chưa ghi nhận vào lớp`)<br>- Card đồng hành nhắc giữ không gian học tập yên tĩnh cho con. |
| **Ca học Đã kết thúc (Completed)** | - Badge xám `Đã kết thúc`<br>- Điểm danh: `Có mặt`<br>- Ẩn checklist chuẩn bị, hiển thị Section `KẾT QUẢ BUỔI HỌC` (Nhận xét của giáo viên & Bài tập về nhà được giao).<br>- CTA chính: `Xem kết quả buổi học & bài tập`. |
| **Ca học Đã dời lịch (Rescheduled)** | - Badge cam `Đã đổi lịch`<br>- Hiển thị Banner cam thông báo: `Buổi học được chuyển sang 09:00 Thứ Bảy 25/10 do giáo viên tham gia tập huấn chuyên môn.` |
| **Ca học Đã hủy (Cancelled)** | - Badge đỏ `Đã hủy`<br>- Hiển thị Banner đỏ: `Buổi học được hủy theo lịch nghỉ lễ của trung tâm. Lịch học bù sẽ được gửi thông báo sau.`<br>- Vô hiệu hóa nút Báo vắng. |
| **Tên bài học quá dài** | Cho phép hiển thị tối đa 3 dòng kèm `maxLines: 3`, không bị vỡ giao diện (overflow). |
| **Mất kết nối mạng (Offline)** | Vẫn mở xem được chi tiết từ bộ nhớ đệm (Cache) của buổi học đã tải trước đó; các nút tải file hoặc nhắn tin hiển thị cảnh báo offline. |

---

## 8. KẾ HOẠCH TRIỂN KHAI TỪNG BƯỚC

### Giai đoạn 1: Chuẩn bị Dữ liệu & Routing (Bước 1 - 2)
- **Bước 1:** Định nghĩa `ParentSessionDetail` model và các sub-models (`SessionMaterial`, `SessionChecklistItem`) kèm logic Mock Enrichment trong `lib/features/parent/data/models/parent_session_detail_model.dart`.
- **Bước 2:** Bổ sung helper mapping từ `ParentScheduleSession` sang `ParentSessionDetail`.

### Giai đoạn 2: Xây dựng Giao diện Màn hình Mới (Bước 3 - 4)
- **Bước 3:** Tạo file màn hình `lib/features/parent/presentation/schedule/parent_session_detail_screen.dart`:
  - Xây dựng `_DetailAppBar` với Back button, title tên con, subtitle lớp học, icon Lịch và Chia sẻ.
  - Xây dựng `_ChildIdentityCard` tinh giản, loại bỏ lặp thông tin lớp.
  - Xây dựng `_SessionHeroCard` với giờ học cực đại `09:00 — 10:00`, mã buổi học, ngày học, tên bài học.
  - Xây dựng `_SessionMetaSection` (Hình thức, Giáo viên, Điểm danh).
  - Xây dựng `_PreparationSection` (Tài liệu PDF & Checklist).
  - Xây dựng `_ParentGuidanceCard` (Lời khuyên đồng hành cùng con).
  - Xây dựng `_StickyBottomActionBar` (Nút báo vắng, nhắn tin GV và Primary CTA bài học) bọc trong Safe Area.
- **Bước 4:** Xử lý các Bottom Sheet tương tác phụ:
  - Sheet `Xin phép vắng / Đến muộn` (Modal nhập lý do và gửi cho GV).
  - Sheet `Thông tin giáo viên & Nhắn tin`.
  - Hộp thoại `Thêm vào Lịch thiết bị` & `Chia sẻ buổi học`.

### Giai đoạn 3: Kết nối Điều hướng & Kiểm thử (Bước 5 - 6)
- **Bước 5:** Cập nhật điều hướng tại:
  - `upcoming_schedule_section.dart` (Trang chủ): Thay vì gọi `showParentSessionDetailSheet`, gọi `Navigator.of(context).push(...)` mở `ParentSessionDetailScreen`.
  - `parent_schedule_screen.dart` (Tab Lịch học): Chuyển sang mở `ParentSessionDetailScreen`.
- **Bước 6:** Chạy `flutter analyze`, kiểm tra toàn bộ màn hình trên các kích thước thiết bị khác nhau, đảm bảo không có cảnh báo hay lỗi layout.

---

## 9. CHECKLIST NGHIỆM THU CHẤT LƯỢNG (QUALITY GATES)

| STT | Hạng mục kiểm tra | Tiêu chuẩn đạt |
|:---:|---|---|
| 1 | **Locked Child Context** | AppBar hiển thị đúng `Buổi học • [Tên con]`, subtitle `[Lớp] — Niên khóa...`. Hoàn toàn không có Child Selector. |
| 2 | **Nút Quay lại (Back)** | Nút Back góc trên bên trái hoạt động mượt mà, trở về đúng vị trí tab và ngày đang chọn của màn trước. |
| 3 | **Phân quyền Phụ huynh** | Không có nút vào học Meet / Join Class. Chỉ có thông tin hình thức và lời khuyên phụ huynh. |
| 4 | **Tính tinh gọn thị giác** | Đã loại bỏ lặp lại tên lớp 3 lần; Avatar con không có chấm xanh gây hiểu lầm; Badge ca học đặt đúng vị trí. |
| 5 | **Độ an toàn Safe Area** | Thanh hành động đáy (`_StickyBottomActionBar`) nằm phía trên Home Indicator của thiết bị, không bị che khuất hay cấn cảm ứng. |
| 6 | **Tài liệu & Checklist** | Hiển thị rõ file PDF đính kèm với dung lượng và checklist đồ dùng/nhiệm vụ rõ ràng. |
| 7 | **Card Lời khuyên Phụ huynh** | Có card xanh pastel với icon bóng đèn, hiển thị thông điệp tích cực đồng hành cùng con. |
| 8 | **Đồng bộ Home & Lịch** | Bấm vào card ca học ở cả Trang chủ và Lịch học đều mở ra cùng một màn hình chi tiết mới này. |
| 9 | **Chất lượng Code** | `flutter analyze` 0 warnings, code có comment tiếng Việt rõ ràng, tuân thủ Clean Architecture. |
