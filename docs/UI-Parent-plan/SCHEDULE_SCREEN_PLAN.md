# KẾ HOẠCH XÂY DỰNG GIAO DIỆN TAB LỊCH HỌC (PARENT SCHEDULE SCREEN) - V2.0

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/presentation/schedule/`)  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả chi tiết vai trò Phụ huynh - Section A, B, C, D, E, G, H)  
> - 2 ảnh thiết kế thực tế mới nhất: `uploaded_media_0_1790232695935.png` và `uploaded_media_1` (Giao diện chuẩn Tab Lịch học v2)  
> - Chuẩn Trang chủ Phụ huynh mới cập nhật (`mobile/lib/features/parent/presentation/home/*`)  
> - Chuẩn Design System Role Student (`mobile/lib/theme/*`, `features/student/presentation/schedule/*`)  
> **Ngày cập nhật:** 24/09/2026  
> **Phiên bản:** 2.0 (Chuẩn hóa thiết kế Card: Phụ huynh chỉ xem - không vào lớp, cập nhật bộ lọc Tuần/Tháng, Card Lịch tuần)  

---

## MỤC LỤC
1. [TỔNG QUAN & PHÂN TÍCH 2 ẢNH THIẾT KẾ MỚI](#1-tổng-quan--phân-tích-2-ảnh-thiết-kế-mới)
2. [ĐẶC TẢ QUAN TRỌNG: PHỤ HUYNH CHỈ XEM, KHÔNG VÀO LỚP HỌC](#2-đặc-tả-quan-trọng-phụ-huynh-chỉ-xem-không-vào-lớp-học)
3. [THIẾT KẾ LẠI HỆ THỐNG CARD CA HỌC (SCHEDULE CARD ANATOMY)](#3-thiết-kế-lại-hệ-thống-card-ca-học)
4. [KIẾN TRÚC GIAO DIỆN & CẤU TRÚC THÀNH PHẦN TOÀN MÀN HÌNH](#4-kiến-trúc-giao-diện--cấu-trúc-thành-phần)
   - [4.1. Header: Nhận diện Tab Lịch học](#41-header-nhận-diện-tab-lịch-học)
   - [4.2. Thanh chọn con (Family Scope Selector)](#42-thanh-chọn-con-family-scope-selector)
   - [4.3. Bộ lọc thời gian (Segmented Control: Hôm nay / Tuần này / Tháng này)](#43-bộ-lọc-thời-gian-segmented-control)
   - [4.4. Thẻ Lịch tuần thông minh (Week Calendar Card)](#44-thẻ-lịch-tuần-thông-minh-week-calendar-card)
   - [4.5. Phân nhóm ca học theo ngày (Timeline Group Header)](#45-phân-nhóm-ca-học-theo-ngày)
   - [4.6. Trạng thái các ca học (Đang diễn ra / Sắp diễn ra / Đã kết thúc)](#46-trạng-thái-các-ca-học)
5. [TÁI SỬ DỤNG TỪ STUDENT ROLE & HOME PARENT](#5-tái-sử-dụng-từ-student-role--home-parent)
6. [MA TRẬN TRẠNG THÁI HỆ THỐNG & CÁC TRƯỜNG HỢP NGOẠI LỆ (EDGE CASES)](#6-ma-trận-trạng-thái-hệ-thống--các-trường-hợp-ngoại-lệ)
7. [THIẾT KẾ DATA MODELS, BLOC & REPOSITORY](#7-thiết-kế-data-models-bloc--repository)
8. [KẾ HOẠCH TRIỂN KHAI THEO TỪNG BƯỚC (STEP-BY-STEP IMPLEMENTATION)](#8-kế-hoạch-triển-khai-theo-từng-bước)
9. [CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)](#9-checklist-nghiệm-thu)

---

## 1. TỔNG QUAN & PHÂN TÍCH 2 ẢNH THIẾT KẾ MỚI

Qua việc đối chiếu 2 ảnh chụp thiết kế thực tế mới nhất (`uploaded_media_0_1790232695935.png` và `uploaded_media_1`), giao diện Tab Lịch học được nâng cấp với các đặc trưng cốt lõi:

1. **Header tinh gọn, rõ ràng:**
   - Góc trái: Biểu tượng lịch vuông bo góc xanh dương + Tiêu đề `Lịch Học` (font lớn, đậm).
   - Góc phải: Icon chuông thông báo (kèm badge đỏ khi có thông báo chưa đọc) + Avatar cá nhân phụ huynh.
2. **Thanh chọn con (Family Scope Selector):**
   - Đã loại bỏ hoàn toàn các dòng text thừa.
   - Nút xanh nổi bật: `Tất cả các con  2` (màu xanh thương hiệu `cs.blue600`, có badge đếm số lượng con `2`).
   - Các chip con: `M  Minh (10A1)` (avatar chữ M nền xanh pastel), `L  Lan (7B)` (avatar chữ L nền hồng pastel).
3. **Bộ lọc thời gian (Segmented Control 3 Tab):**
   - Chuyển thành: `[Hôm nay]` | `[Tuần này]` | `[Tháng này]` (thay vì `Sắp tới` như bản thảo cũ).
   - Trạng thái active (`Tuần này`) có nền trắng tinh khôi bo tròn nổi bật trên nền pill xám mờ.
4. **Thẻ Lịch tuần thông minh (Week Calendar Card):**
   - Đặt trong một Card trắng bo tròn mềm mại:
     - Dòng trên: Icon lịch xanh + `Tuần 42 · 20 - 26 Tháng 10`, bên phải là pill badge `• 14 buổi học trong tuần`.
     - Dải 7 ngày: `T2 20 ·`, `T3 21 ·`, `T4 22 ·`, `T5 23 ·`, `T6 24 •` (active capsule xanh dương), `T7 25 ·`, `CN 26 ·`.
     - Ngày có ca học có chấm tròn sự kiện (event dot) phía dưới.
5. **Timeline nhóm theo ngày (Date Grouping):**
   - `• HÔM NAY — THỨ SÁU, 24 THÁNG 10` (bên phải: `3 ca học`).
   - `• NGÀY MAI — THỨ BẢY, 25 THÁNG 10` (bên phải: `2 ca học`).
6. **Hệ thống Card Ca học độc lập tái thiết kế:**
   - Đồng bộ cấu trúc card cho cả ca Online, Offline, Đang diễn ra, Sắp diễn ra và Đã kết thúc.
   - **Tuyệt đối không có nút "Vào lớp học ngay"** (phù hợp với vai trò của Phụ huynh).

---

## 2. ĐẶC TẢ QUAN TRỌNG: PHỤ HUYNH CHỈ XEM, KHÔNG VÀO LỚP HỌC

### 2.1. Phân định vai trò Phụ huynh vs Học sinh (Deliverable Spec Alignment)
- **Học sinh (Student Role):** Là người trực tiếp tham gia lớp học trực tuyến, có nút CTA *"Vào lớp ngay"* / *"Tham gia phòng học"*.
- **Phụ huynh (Parent Role):**
  - Đóng vai trò **giám sát, đồng hành, nhắc nhở và quản lý học vụ**.
  - Phụ huynh **KHÔNG** tham gia vào phòng học của con (Google Meet/Zoom) vì lý do quy chế lớp học, tính tập trung của học sinh và bảo mật sư phạm.
  - Phụ huynh chỉ cần biết: Con học môn gì, bài nào, mấy giờ, ai dạy, và có đang trong giờ học hay không.
  - Khi cần tìm hiểu sâu, phụ huynh nhấn **`Xem chi tiết buổi học >`** để xem đề cương, tài liệu, kết quả làm bài và nhận xét của giáo viên.

### 2.2. Quyết định thiết kế Card
- **LOẠI BỎ HOÀN TOÀN** nút `Vào lớp học ngay` trên tất cả các Card ca học của Phụ huynh.
- **LOẠI BỎ** hộp nhắc đưa đón cồng kềnh và nút `Bản đồ` rời rạc ở bản thảo cũ. Thông tin địa điểm cơ sở/phòng học được tích hợp tinh tế bên trong trang chi tiết buổi học nếu cần.
- **THỐNG NHẤT HÀNH ĐỘNG DUY NHẤT:** Ở góc phải dưới mỗi card là link điều hướng:
  `Xem chi tiết buổi học >` (font 13.5sp, bold 600, màu xanh `cs.blue600`).
  Chạm vào sẽ mở `ScheduleDetailScreen` (hoặc `LessonDetailScreen` theo locked child context).

---

## 3. THIẾT KẾ LẠI HỆ THỐNG CARD CA HỌC (SCHEDULE CARD ANATOMY)

Mỗi buổi học được thể hiện bằng **1 Card trắng độc lập** với cấu trúc 4 tầng thông tin rõ ràng:

```text
┌─────────────────────────────────────────────────────────────┐
│ (Avatar M) Minh — Toán (Đại số 10)         [• Đang diễn ra] │ <- Tầng 1: Chủ thể & Trạng thái
│                                                             │
│ (Icon Clock) 09:00 — 10:00                                  │ <- Tầng 2: Thời gian to rõ
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Bài học: Phương trình bậc hai & Định lý Vi-ét           │ │ <- Tầng 3: Box đề tài bài học
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ (Icon Person) Giáo viên: Cô Lan      Xem chi tiết buổi học >│ <- Tầng 4: Giáo viên & Navigation
└─────────────────────────────────────────────────────────────┘
```

### 3.1. Chi tiết 4 tầng thông tin của Card

| Tầng | Thành phần UI | Quy cách thiết kế (Typography & Color Tokens) |
| :--- | :--- | :--- |
| **1. Header Card** | - Avatar tròn con:<br>  + Minh: Nền xanh pastel `#DBEAFE`, chữ `M` xanh đậm `#1D4ED8`.<br>  + Lan: Nền hồng pastel `#FCE7F3`, chữ `L` hồng đậm `#BE185D`.<br>- Tên con — Môn học: `${childName} — ${subjectName}`<br>- Status Badge góc phải | - Avatar radius 13px (đường kính 26px).<br>- Tên con — môn: font 15sp, bold 700, màu `slate900`.<br>- Badge trạng thái: Xem mục 3.2. |
| **2. Khối Giờ học** | - Icon thời gian (trái):<br>  + Đang diễn ra: `Icons.access_time_rounded` màu xanh dương `blue600`.<br>  + Sắp diễn ra: `Icons.access_time_rounded` màu xám `slate400`.<br>  + Đã kết thúc: `Icons.history_rounded` màu xám `slate400`.<br>- Dải giờ: `09:00 — 10:00` | - Icon size 18px.<br>- Dải giờ: font 20sp, bold 800, màu `slate900`, khoảng cách letter-spacing nhẹ. |
| **3. Box Bài học (Topic Container)** | - Container bo góc bo tròn mềm mại `AppRadius.borderMd` (10px).<br>- Nền xám/xanh rất nhạt `Color(0xFFF8FAFC)`.<br>- Text kết hợp:<br>  + Tiền tố `Bài học:`<br>  + Nội dung: `${lessonTopic}` | - Padding `10px 14px`.<br>- Tiền tố `Bài học:` font 13.5sp, semi-bold 600, màu `slate500`.<br>- Tên bài học: font 13.5sp, regular/medium 500, màu `slate800`, line-height 1.4. |
| **4. Footer Card** | - Bên trái: Icon người `Icons.person_outline_rounded` (16px) + `Giáo viên: ${instructorName}`.<br>- Bên phải: Link text `Xem chi tiết buổi học` + icon `Icons.chevron_right_rounded` (18px). | - Giáo viên: font 13.5sp, màu `slate600`.<br>- Link: font 13.5sp, bold 600, màu xanh thương hiệu `TogetherColorsX.blue600`. |

### 3.2. Quy chuẩn 3 trạng thái Status Badge trên Card

1. **`• Đang diễn ra` (In-Progress):**
   - Nền: `Color(0xFFECFDF5)` (xanh ngọc nhạt).
   - Chữ & Chấm tròn: `Color(0xFF10B981)` (xanh lá).
   - Font: 12sp, bold 700. Có chấm tròn 6px ở đầu.
2. **`Sắp diễn ra` (Upcoming):**
   - Nền: `Color(0xFFEFF6FF)` (xanh dương nhạt).
   - Chữ: `Color(0xFF2563EB)` (xanh dương `blue600`).
   - Font: 12sp, bold 700.
3. **`Đã kết thúc` (Completed):**
   - Nền: `Color(0xFFF1F5F9)` (xám nhạt `slate100`).
   - Chữ: `Color(0xFF64748B)` (xám `slate500`).
   - Font: 12sp, bold 600.
4. **Ngoại lệ: `Đã đổi lịch` / `Đã hủy`:**
   - Đổi lịch: Nền `Color(0xFFFEF3C7)`, chữ `Color(0xFFD97706)`.
   - Đã hủy: Nền `Color(0xFFFEE2E2)`, chữ `Color(0xFFDC2626)`.

---

## 4. KIẾN TRÚC GIAO DIỆN & CẤU TRÚC THÀNH PHẦN TOÀN MÀN HÌNH

```text
ParentScheduleScreen (Scaffold: backgroundColor = surfaceBg)
├── Header (Container trắng: ParentScheduleHeader)
│   ├── Icon lịch bo góc xanh + Tiêu đề "Lịch Học"
│   └── Actions: [Notification Bell Badge, Avatar Circle]
│
└── Body Container (surfaceBg, borderRadius top: 24, shadow upward)
    ├── 1. FamilyScopeSelector ([Tất cả con  2] [Minh] [Lan])
    ├── vGap16
    ├── 2. ScheduleSegmentedControl ([Hôm nay] [Tuần này] [Tháng này])
    ├── vGap16
    ├── 3. WeekCalendarCard
    │   ├── Top row: Tuần 42 · 20 - 26 Tháng 10 + [• 14 buổi học trong tuần]
    │   └── Week strip: T2 20 ... T6 24 (active capsule) ... CN 26 với event dots
    ├── vGap20
    ├── 4. DateGroupSection (Hôm nay — Thứ Sáu, 24 Tháng 10  •  3 ca học)
    │   ├── ScheduleCard 1: Minh — Toán (09:00 - 10:00) [• Đang diễn ra]
    │   ├── ScheduleCard 2: Lan — Tiếng Anh (14:00 - 15:30) [Sắp diễn ra]
    │   └── ScheduleCard 3: Minh — Khoa học tự nhiên (07:30 - 08:45) [Đã kết thúc]
    ├── vGap20
    └── 5. DateGroupSection (Ngày mai — Thứ Bảy, 25 Tháng 10  •  2 ca học)
        ├── ScheduleCard 4: Lan — Toán tư duy (08:30 - 10:00) [Sắp diễn ra]
        └── ScheduleCard 5: Minh — Vật lý 10 (14:30 - 16:00) [Sắp diễn ra]
```

### 4.1. Header: Nhận diện Tab Lịch học
- **Cấu trúc:**
  - Nền trắng tinh khiết (`Colors.white`), padding `fromLTRB(16, 8, 16, 16)`.
  - Icon bên trái: `Container(width: 36, height: 36, decoration: BoxDecoration(color: cs.blue600, borderRadius: AppRadius.borderMd), child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20))`.
  - Tiêu đề: `Lịch Học` (font 20-22sp, bold 700, màu `slate900`).
  - Nút chuông thông báo (kèm badge đỏ khi có tin chưa đọc) và avatar phụ huynh bên phải.

### 4.2. Thanh chọn con (Family Scope Selector)
- Nằm trên nền `surfaceBg` ngay sau phần cong của Body.
- **Nút "Tất cả các con":** Khi được chọn mang màu xanh `cs.blue600`, chữ trắng, kèm badge tròn đếm số con (`2`).
- **Nút từng con:** Dạng viên thuốc nền trắng tinh khiết (`Colors.white`), viền mờ `outlineVariant`, có avatar chữ cái con (`M`, `L`).
- **Logic:**
  - Khi chọn `Tất cả các con`: Hiển thị lịch tổng hợp của mọi con, sắp xếp theo thời gian (Minh 9h, Lan 14h...).
  - Khi chọn con cụ thể (`Minh`): Lọc danh sách chỉ còn các ca học của `Minh`.
  - Khi chỉ có 1 con: Ẩn nút "Tất cả các con", tự động chọn con duy nhất đó.

### 4.3. Bộ lọc thời gian (Segmented Control: Hôm nay / Tuần này / Tháng này)
- **Container nền xám nhạt:** `Color(0xFFF1F5F9)`, bo góc tròn `AppRadius.borderLg` (12px), padding 4px.
- **3 Lựa chọn:**
  1. `Hôm nay`: Tập trung hiển thị các ca học trong ngày hiện tại.
  2. `Tuần này` (mặc định): Hiển thị thẻ lịch tuần và danh sách ca học nhóm theo từng ngày trong tuần.
  3. `Tháng này`: Chế độ xem tổng quan lịch học cả tháng.
- Nút đang chọn: Nền trắng `Colors.white`, bo góc tròn 8px, chữ đậm màu `slate900`, đổ bóng mềm (`boxShadow`).

### 4.4. Thẻ Lịch tuần thông minh (Week Calendar Card)
- **Container thẻ trắng:** Bo góc `AppRadius.borderLg` (16px), nền `Colors.white`, viền mờ và shadow nhẹ.
- **Hàng tiêu đề:**
  - Icon calendar nhỏ màu xanh `blue600` + `Tuần 42 · 20 - 26 Tháng 10` (font 14sp, bold 700, màu `slate900`).
  - Phía bên phải: Pill badge màu xanh pastel `Color(0xFFEFF6FF)`: `• 14 buổi học trong tuần` (font 11.5sp, bold 600, màu `blue600`).
- **Dải 7 ngày trong tuần:**
  - Cột gồm Thứ (`T2`..`CN`) và Ngày (`20`..`26`).
  - Ngày được chọn (`T6 24`): Được bọc trong viên thuốc capsule màu xanh pastel `Color(0xFFEFF6FF)`, thứ và ngày màu xanh `blue600` bold, có chấm tròn xanh đậm bên dưới.
  - Các ngày khác: Có dấu chấm nhỏ `·` (event dot) bên dưới số ngày nếu ngày đó có ít nhất 1 ca học.
  - Chạm vào ngày nào trên dải lịch sẽ cuộn/lọc đến các ca học của ngày đó.

### 4.5. Phân nhóm ca học theo ngày (Timeline Group Header)
- Dưới dải tuần là các nhóm ca học theo ngày:
  - Header nhóm: Dấu chấm tròn màu xanh thương hiệu `•` (hoặc xám đối với ngày khác) + Text in hoa `HÔM NAY — THỨ SÁU, 24 THÁNG 10` (font 13.5sp, bold 700, màu `slate900`, letter-spacing 0.3).
  - Phía bên phải: Pill badge nền xám nhạt `Color(0xFFF1F5F9)`: `3 ca học` (font 11.5sp, màu `slate600`).
  - Nhóm kế tiếp: `• NGÀY MAI — THỨ BẢY, 25 THÁNG 10` (bên phải: `2 ca học`).

---

## 5. TÁI SỬ DỤNG TỪ STUDENT ROLE & HOME PARENT

| Thành phần | Nguồn tái sử dụng | Mức độ tái sử dụng & Điều chỉnh cho Parent |
| :--- | :--- | :--- |
| **Thanh chọn con (Family Scope)** | `features/parent/presentation/home/widgets/family_scope_selector.dart` | **Tái sử dụng 100%**: Dùng chung logic chọn con, ẩn nút tất cả khi có 1 con, chip trắng nổi trên nền `surfaceBg`. |
| **Logic tính lịch tuần & Event Dates** | `features/student/presentation/schedule/widgets/calendar_widget.dart` | **Kế thừa 80% logic tính ngày**: Kế thừa thuật toán tính ngày bắt đầu tuần (Monday), danh sách `DateTime` 7 ngày, thuật toán so khớp `isSameDay(d1, d2)`. |
| **Design Tokens & Theme** | `theme/app_colors.dart`, `app_spacing.dart`, `app_radius.dart` | **Tái sử dụng 100%**: Bảng màu `TogetherColorsX.blue600`, `slate900`, `slate500`, radius chuẩn, shadow mềm. |
| **Header Notification & Profile** | `features/parent/presentation/home/widgets/parent_home_header.dart` | **Kế thừa cấu trúc**: Đồng bộ icon chuông và avatar profile. |

---

## 6. MA TRẬN TRẠNG THÁI HỆ THỐNG & CÁC TRƯỜNG HỢP NGOẠI LỆ (EDGE CASES)

| Tình huống / Ngữ cảnh | Giao diện hiển thị (UI Behavior) | Hành động của người dùng (Action) |
| :--- | :--- | :--- |
| **1. Chưa liên kết con (No-Child)** | Toàn bộ màn hình thay bằng `ParentNoChildView` chuẩn đã xây dựng ở Home. | Bấm nút "Liên kết hồ sơ con" để nhập mã. |
| **2. Con chưa tham gia lớp nào (No-Class)** | Card Empty State: Icon lớp học mờ, tiêu đề *"Con chưa tham gia lớp học nào"*, giải thích *"Khi con được xếp vào lớp, thời khóa biểu sẽ xuất hiện tại đây"*. | Nút "Liên hệ trung tâm / Tư vấn khóa học". |
| **3. Ngày chọn không có ca học (Empty Date)** | Thẻ All-Clear giữa màn hình: Icon lịch xanh lá `verified_rounded`, *"Không có buổi học nào trong ngày này"*, *"Hôm nay là thời gian nghỉ ngơi hoặc tự ôn tập của con"*. | Bấm "Xem ngày tiếp theo có ca học" hoặc bấm sang tab "Tuần này". |
| **4. Đang tải dữ liệu (Loading State)** | Skeleton Shimmer: Hiệu ứng nhấp nháy cho dải tuần và 2 thẻ ca học giả lập. | Tránh giật màn hình khi tải mạng chậm. |
| **5. Lỗi kết nối / Lỗi server (Error State)** | Banner báo lỗi màu đỏ nhạt + Nút "Thử lại", giữ nguyên ngày và tab đang chọn. | Bấm "Thử lại" hoặc kéo xuống để Refresh (`RefreshIndicator`). |
| **6. Ngoại tuyến (Offline Mode)** | Hiển thị dữ liệu lịch đã lưu trong Local Cache kèm banner nhỏ màu vàng: *"Đang ngoại tuyến — Lịch học cập nhật lúc 08:30"*. | Link xem chi tiết vẫn mở được thông tin offline từ cache. |

---

## 7. THIẾT KẾ DATA MODELS, BLOC & REPOSITORY

### 7.1. Data Model: `ParentScheduleSession`
```dart
class ParentScheduleSession {
  final String id;
  final String childId;
  final String childName;
  final String childInitial;
  final Color childBadgeColor;
  final String subjectName;
  final String lessonTopic;
  final DateTime startTime;
  final DateTime endTime;
  final String instructorName;
  final ParentSessionStatus status; // inProgress | upcoming | completed | cancelled | rescheduled
  final String? statusNote;         // Lý do hủy/đổi lịch nếu có
}
```

### 7.2. State Management: `ParentScheduleBloc`
- **Events:**
  - `ParentScheduleStarted`: Tải lịch ban đầu.
  - `ParentScheduleChildFilterChanged(String? childId)`: Lọc theo con (null = Tất cả các con).
  - `ParentScheduleTabChanged(ParentScheduleTab tab)`: Chuyển tab Hôm nay / Tuần này / Tháng này.
  - `ParentScheduleDateSelected(DateTime date)`: Chọn ngày trên dải tuần.
  - `ParentScheduleWeekChanged(DateTime weekStart)`: Chuyển tuần.
  - `ParentScheduleRefreshed`: Kéo làm mới dữ liệu.
- **States:**
  - `ParentScheduleInitial`: Khởi tạo.
  - `ParentScheduleLoading`: Đang fetch dữ liệu.
  - `ParentScheduleSuccess`: Chứa danh sách `children`, `selectedChildId`, `currentWeekStart`, `selectedDate`, `activeTab`, danh sách `sessions`, `eventDates`.
  - `ParentScheduleFailure`: Chứa thông báo lỗi.

---

## 8. KẾ HOẠCH TRIỂN KHAI THEO TỪNG BƯỚC

> **LƯU Ý:** Giai đoạn này chỉ lập và hoàn thiện tài liệu kế hoạch. KHÔNG viết code sản phẩm ở bước này.

### Bước 1: Chuẩn bị Models & Repository Mock Data
- Tạo model `ParentScheduleSession` và enum `ParentSessionStatus`, `ParentScheduleTab` (`today`, `week`, `month`).
- Tạo mock data chuẩn khớp hoàn toàn với ảnh thiết kế:
  - Minh: Toán (09:00 - 10:00, Đang diễn ra, Cô Lan, Phương trình bậc hai & Định lý Vi-ét).
  - Lan: Tiếng Anh (14:00 - 15:30, Sắp diễn ra, Thầy Nam, Speaking Fluency & Unit 4 Presentation).
  - Minh: Khoa học tự nhiên (07:30 - 08:45, Đã kết thúc, Thầy Hùng, Cấu tạo phân tử).
  - Lan: Toán tư duy ngày mai (08:30 - 10:00, Sắp diễn ra, Cô Hương).
  - Minh: Vật lý 10 ngày mai (14:30 - 16:00, Sắp diễn ra, Thầy Dũng).

### Bước 2: Xây dựng BLoC Quản lý State Lịch học
- Tạo `ParentScheduleBloc`, `ParentScheduleEvent`, `ParentScheduleState`.
- Hỗ trợ lọc theo con, chọn ngày tuần, chuyển tab (Hôm nay / Tuần này / Tháng này) và nhóm ca học theo ngày.

### Bước 3: Xây dựng UI Components Dải lịch tuần & Bộ lọc
- Tạo `ScheduleSegmentedControl` (Hôm nay / Tuần này / Tháng này).
- Tạo `WeekCalendarCard` bọc trong thẻ trắng: header tuần + badge số buổi trong tuần + dải 7 ngày với capsule highlight và chấm event dot.
- Tạo `DateGroupHeader` hiển thị `• HÔM NAY — THỨ SÁU, 24 THÁNG 10` kèm pill badge `3 ca học`.

### Bước 4: Xây dựng Hệ thống Card Ca học Độc lập (Không có nút vào lớp)
- Tạo `ParentScheduleCard` theo đúng thiết kế 4 tầng:
  1. Avatar con + Tên con — Môn học + Badge trạng thái (Đang diễn ra / Sắp diễn ra / Đã kết thúc).
  2. Icon đồng hồ + Thời gian to rõ (`09:00 — 10:00`).
  3. Box `Bài học: ${lessonTopic}` nền xám nhạt.
  4. Footer: `Giáo viên: ${instructorName}` (trái) và link `Xem chi tiết buổi học >` (phải).
- **Tuyệt đối không có nút "Vào lớp học ngay" hay nút "Bản đồ".**

### Bước 5: Ráp nối Màn hình `ParentScheduleScreen` & Xử lý Ngoại lệ
- Tích hợp Header, `FamilyScopeSelector`, `ScheduleSegmentedControl`, `WeekCalendarCard`, danh sách `DateGroupSection` và các `ParentScheduleCard`.
- Áp dụng phân tầng màu nền: Header trắng, Body `surfaceBg`.
- Xử lý No-Child, No-Class, Empty Date, Loading Skeleton và Error Retry.

### Bước 6: Kiểm thử & Phân tích Tĩnh
- Chạy `flutter analyze` đảm bảo không có bất kỳ lỗi linter nào.
- Kiểm tra tính tương thích và mượt mà trên ứng dụng.

---

## 9. CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)

- [ ] **Header:** Icon lịch vuông xanh + tiêu đề `Lịch Học` + chuông thông báo và avatar.
- [ ] **Thanh chọn con:** Chip `Tất cả các con  2` màu xanh, chip con nền trắng; ẩn Tất cả khi chỉ có 1 con.
- [ ] **Bộ lọc 3 Tab:** `Hôm nay` | `Tuần này` | `Tháng này`.
- [ ] **Thẻ Lịch tuần:** Nằm trong card trắng, có dòng `Tuần 42 · 20 - 26 Tháng 10` + pill `• 14 buổi học trong tuần`; dải 7 ngày có capsule highlight và chấm event dot.
- [ ] **Phân nhóm ngày:** Dấu chấm tròn + Text in hoa `HÔM NAY — THỨ SÁU, 24 THÁNG 10` + badge `3 ca học`.
- [ ] **Card Ca học chuẩn:**
  - [ ] Hiển thị avatar tròn con + Tên con — Môn học.
  - [ ] Status badge: `• Đang diễn ra` (xanh lá), `Sắp diễn ra` (xanh dương), `Đã kết thúc` (xám).
  - [ ] Thời gian to rõ (`09:00 — 10:00`, `14:00 — 15:30`...).
  - [ ] Khối bo góc `Bài học: [Tên bài học]`.
  - [ ] Footer hiển thị tên giáo viên và link `Xem chi tiết buổi học >`.
  - [ ] **KHÔNG CÓ nút "Vào lớp học ngay" và KHÔNG CÓ nút "Bản đồ".**
- [ ] **Ngoại lệ (Edge cases):** Empty date hiển thị thẻ All-clear; No-child hiển thị `ParentNoChildView`.
- [ ] **Chất lượng mã nguồn:** `flutter analyze` đạt **No issues found!**
