# KẾ HOẠCH XÂY DỰNG GIAO DIỆN TAB LỊCH HỌC (PARENT SCHEDULE SCREEN) - V2.1

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/presentation/schedule/` & `home/`)  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả chi tiết vai trò Phụ huynh - Section A, B, C, D, E, G, H)  
> - 2 ảnh thiết kế thực tế mới nhất: `uploaded_media_0_1790232695935.png` và `uploaded_media_1` (Giao diện chuẩn Tab Lịch học v2)  
> - Chuẩn Trang chủ Phụ huynh mới cập nhật (`mobile/lib/features/parent/presentation/home/*`)  
> - Chuẩn Design System Role Student (`mobile/lib/theme/*`, `features/student/presentation/schedule/*`)  
> **Ngày cập nhật:** 24/09/2026  
> **Phiên bản:** 2.1 (Chiến lược đồng bộ 1 cấu trúc Card ca học duy nhất cho cả Home và Schedule, Phụ huynh chỉ xem - không vào lớp)  

---

## MỤC LỤC
1. [TỔNG QUAN & PHÂN TÍCH 2 ẢNH THIẾT KẾ MỚI](#1-tổng-quan--phân-tích-2-ảnh-thiết-kế-mới)
2. [ĐẶC TẢ QUAN TRỌNG: PHỤ HUYNH CHỈ XEM, KHÔNG VÀO LỚP HỌC](#2-đặc-tả-quan-trọng-phụ-huynh-chỉ-xem-không-vào-lớp-học)
3. [CHIẾN LƯỢC ĐỒNG BỘ 1 CẤU TRÚC CARD CA HỌC DUY NHẤT (SINGLE UNIFIED CARD STRATEGY)](#3-chiến-lược-đồng-bộ-1-cấu-trúc-card-ca-học-duy-nhất)
   - [3.1. Phân tích bối cảnh & Lý do loại bỏ 2 kiểu card riêng rẽ](#31-phân-tích-bối-cảnh--lý-do-loại-bỏ-2-kiểu-card-riêng-rẽ)
   - [3.2. Lợi ích vượt trội cho Phụ huynh & Hệ thống](#32-lợi-ích-vượt-trội-cho-phụ-huynh--hệ-thống)
   - [3.3. Tác động đến màn hình Trang chủ (Home) & Giải pháp tối ưu](#33-tác-động-đến-màn-hình-trang-chủ-home--giải-pháp-tối-ưu)
   - [3.4. Thiết kế chi tiết Cấu trúc Card chuẩn duy nhất (Card Anatomy 4 tầng)](#34-thiết-kế-chi-tiết-cấu-trúc-card-chuẩn-duy-nhất)
   - [3.5. Quy chuẩn 3 trạng thái Status Badge](#35-quy-chuẩn-3-trạng-thái-status-badge)
4. [KIẾN TRÚC GIAO DIỆN & CẤU TRÚC THÀNH PHẦN TOÀN MÀN HÌNH LỊCH HỌC](#4-kiến-trúc-giao-diện--cấu-trúc-thành-phần-toàn-màn-hình-lịch-học)
   - [4.1. Header: Nhận diện Tab Lịch học](#41-header-nhận-diện-tab-lịch-học)
   - [4.2. Thanh chọn con (Family Scope Selector)](#42-thanh-chọn-con-family-scope-selector)
   - [4.3. Bộ lọc thời gian (Segmented Control: Hôm nay / Tuần này / Tháng này)](#43-bộ-lọc-thời-gian-segmented-control)
   - [4.4. Thẻ Lịch tuần thông minh (Week Calendar Card)](#44-thẻ-lịch-tuần-thông-minh-week-calendar-card)
   - [4.5. Phân nhóm ca học theo ngày (Timeline Group Header)](#45-phân-nhóm-ca-học-theo-ngày)
5. [TÁI SỬ DỤNG TỪ STUDENT ROLE & HOME PARENT](#5-tái-sử-dụng-từ-student-role--home-parent)
6. [MA TRẬN TRẠNG THÁI HỆ THỐNG & CÁC TRƯỜNG HỢP NGOẠI LỆ (EDGE CASES)](#6-ma-trận-trạng-thái-hệ-thống--các-trường-hợp-ngoại-lệ)
7. [THIẾT KẾ DATA MODELS, BLOC & REPOSITORY](#7-thiết-kế-data-models-bloc--repository)
8. [KẾ HOẠCH TRIỂN KHAI THEO TỪNG BƯỚC (STEP-BY-STEP IMPLEMENTATION)](#8-kế-hoạch-triển-khai-theo-từng-bước)
9. [CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)](#9-checklist-nghiệm-thu)

---

## 1. TỔNG QUAN & PHÂN TÍCH 2 ẢNH THIẾT KẾ MỚI

Qua việc đối chiếu 2 ảnh chụp thiết kế thực tế mới nhất (`uploaded_media_0_1790232695935.png` và `uploaded_media_1`), giao diện Tab Lịch học được nâng cấp với các đặc trưng cốt lõi:

1. **Header tinh gọn, rõ ràng:**
   - Góc trái: Biểu tượng lịch vuông bo góc xanh dương + Tiêu đề **`Lịch Học`** (font lớn, đậm).
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
6. **Hệ thống Card Ca học độc lập:**
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

## 3. CHIẾN LƯỢC ĐỒNG BỘ 1 CẤU TRÚC CARD CA HỌC DUY NHẤT

### 3.1. Phân tích bối cảnh & Lý do loại bỏ 2 kiểu card riêng rẽ
Trước đây, ứng dụng tồn tại 2 dạng card ca học khác nhau:
1. **Ở Trang chủ (Home):** Dùng dạng card ngang tóm tắt (`_ScheduleItemCard`): Khối thời gian `64x52` bên trái, tên môn & con ở giữa, badge trạng thái bên phải.
2. **Ở Tab Lịch học (Schedule):** Dùng dạng card dọc 4 tầng chi tiết (Avatar con & Status -> Giờ to rõ -> Box tên bài học -> Giáo viên & Link xem chi tiết).

**Quyết định chuẩn hóa:** Loại bỏ dạng card ngang cũ của Trang chủ, **chỉ sử dụng DUY NHẤT 1 cấu trúc Card ca học chuẩn (chuẩn tab Lịch học)** cho toàn bộ ứng dụng Phụ huynh.

### 3.2. Lợi ích vượt trội cho Phụ huynh & Hệ thống
- **Tính nhất quán nhận thức (Cognitive Consistency):** Phụ huynh không bị bỡ ngỡ giữa 2 cách thể hiện. Bất kể ở Home hay Lịch học, thông tin được quét theo cùng một nhịp thị giác quen thuộc.
- **Biết ngay hôm nay con học bài gì ngay tại Trang chủ:** Card cũ ở Home chỉ hiện môn học và giờ, không có bài học. Card mới hiển thị khối `Bài học: [Tên chuyên đề]` giúp phụ huynh nắm ngay nội dung con đang học mà không cần bấm vào trang con.
- **Đồng bộ triệt để quyền hạn Phụ huynh:** Cả Home và Schedule đều không có nút vào lớp học, chỉ có link `Xem chi tiết buổi học >`.
- **Tối ưu mã nguồn (DRY):** Tạo một component dùng chung duy nhất: `ParentScheduleCard` phục vụ cho cả `upcoming_schedule_section.dart` (Home) và `parent_schedule_screen.dart` (Schedule).

### 3.3. Tác động đến màn hình Trang chủ (Home) & Giải pháp tối ưu
- **Chiều cao card tăng từ ~76px lên ~145-155px:** 
  - *Đánh giá:* Mục "Hôm nay / Tiếp theo" ở Home thường chỉ hiển thị 1-2 ca học sắp tới. Chiều cao lớn hơn giúp thẻ card thoáng hơn, chữ to rõ hơn, rất thích hợp cho mắt người lớn tuổi.
  - *Giải pháp an toàn:* Section "Hôm nay / Tiếp theo" trên Home đã được trang bị cơ chế **Collapse (Thu gọn / Mở rộng)** toàn diện, phụ huynh hoàn toàn chủ động đóng/mở khi cần.

### 3.4. Thiết kế chi tiết Cấu trúc Card chuẩn duy nhất

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

#### Chi tiết 4 tầng thông tin:
| Tầng | Thành phần UI | Quy cách thiết kế (Typography & Color Tokens) |
| :--- | :--- | :--- |
| **1. Header Card** | - Avatar tròn con (Minh: `#DBEAFE`/`M` xanh; Lan: `#FCE7F3`/`L` hồng).<br>- Tên con — Môn học: `${childName} — ${subjectName}`<br>- Status Badge góc phải | - Avatar radius 13px (đường kính 26px).<br>- Tên con — môn: font 15sp, bold 700, màu `slate900`.<br>- Badge trạng thái bo tròn `AppRadius.borderFull`. |
| **2. Khối Giờ học** | - Icon thời gian (trái): `access_time_rounded` hoặc `history_rounded`.<br>- Dải giờ: `09:00 — 10:00` | - Icon size 18px.<br>- Dải giờ: font 20sp, bold 800, màu `slate900`, khoảng cách letter-spacing nhẹ. |
| **3. Box Bài học (Topic Container)** | - Container bo góc bo tròn mềm mại `AppRadius.borderMd` (10px).<br>- Nền xám/xanh rất nhạt `Color(0xFFF8FAFC)`.<br>- Text: `Bài học: ${lessonTopic}` | - Padding `10px 14px`.<br>- Tiền tố `Bài học:` font 13.5sp, semi-bold 600, màu `slate500`.<br>- Tên bài học: font 13.5sp, regular/medium 500, màu `slate800`. |
| **4. Footer Card** | - Bên trái: Icon người `Icons.person_outline_rounded` (16px) + `Giáo viên: ${instructorName}`.<br>- Bên phải: Link text `Xem chi tiết buổi học` + icon `chevron_right_rounded` (18px). | - Giáo viên: font 13.5sp, màu `slate600`.<br>- Link: font 13.5sp, bold 600, màu xanh thương hiệu `TogetherColorsX.blue600`. |

### 3.5. Quy chuẩn 3 trạng thái Status Badge
1. **`• Đang diễn ra` (In-Progress):** Nền `Color(0xFFECFDF5)`, chữ & chấm tròn `Color(0xFF10B981)` xanh lá, font 12sp bold 700.
2. **`Sắp diễn ra` (Upcoming):** Nền `Color(0xFFEFF6FF)`, chữ `Color(0xFF2563EB)` xanh dương, font 12sp bold 700.
3. **`Đã kết thúc` (Completed):** Nền `Color(0xFFF1F5F9)`, chữ `Color(0xFF64748B)` xám, font 12sp bold 600.
4. **Ngoại lệ: `Đã đổi lịch` / `Đã hủy`:** Đổi lịch nền vàng cam `#FEF3C7`/`#D97706`; Đã hủy nền đỏ nhạt `#FEE2E2`/`#DC2626`.

---

## 4. KIẾN TRÚC GIAO DIỆN & CẤU TRÚC THÀNH PHẦN TOÀN MÀN HÌNH LỊCH HỌC

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
    │   ├── ParentScheduleCard 1: Minh — Toán (09:00 - 10:00) [• Đang diễn ra]
    │   ├── ParentScheduleCard 2: Lan — Tiếng Anh (14:00 - 15:30) [Sắp diễn ra]
    │   └── ParentScheduleCard 3: Minh — Khoa học tự nhiên (07:30 - 08:45) [Đã kết thúc]
    ├── vGap20
    └── 5. DateGroupSection (Ngày mai — Thứ Bảy, 25 Tháng 10  •  2 ca học)
        ├── ParentScheduleCard 4: Lan — Toán tư duy (08:30 - 10:00) [Sắp diễn ra]
        └── ParentScheduleCard 5: Minh — Vật lý 10 (14:30 - 16:00) [Sắp diễn ra]
```

### 4.1. Header: Nhận diện Tab Lịch học
- Nền trắng tinh khiết (`Colors.white`), padding `fromLTRB(16, 8, 16, 16)`.
- Icon bên trái: Box xanh dương `36x36px` bo góc chứa icon `Icons.calendar_month_rounded`.
- Tiêu đề: `Lịch Học` (font 20-22sp, bold 700, màu `slate900`).
- Nút chuông thông báo (kèm badge đỏ khi có tin mới) và avatar phụ huynh bên phải.

### 4.2. Thanh chọn con (Family Scope Selector)
- Nằm trên nền `surfaceBg` ngay sau phần cong bo góc của Body.
- Nút xanh `Tất cả các con  2` khi được chọn; các chip con màu trắng nổi bật trên nền `surfaceBg`.
- Ẩn nút "Tất cả các con" nếu tài khoản chỉ có 1 con.

### 4.3. Bộ lọc thời gian (Segmented Control: Hôm nay / Tuần này / Tháng này)
- Container nền xám nhạt `Color(0xFFF1F5F9)`, bo góc tròn 12px, padding 4px.
- 3 Lựa chọn: `[Hôm nay]` | `[Tuần này]` (mặc định) | `[Tháng này]`.
- Nút đang chọn: Nền trắng `Colors.white`, bo góc tròn 8px, chữ đậm, đổ bóng mềm nhẹ.

### 4.4. Thẻ Lịch tuần thông minh (Week Calendar Card)
- Container thẻ trắng bo góc `16px`, viền mờ và shadow nhẹ.
- Header: Icon calendar xanh + `Tuần 42 · 20 - 26 Tháng 10` + Pill badge `• 14 buổi học trong tuần`.
- Dải 7 ngày: Cột Thứ (`T2`..`CN`) và Ngày (`20`..`26`). Ngày chọn (`T6 24`) được highlight bằng viên thuốc capsule xanh pastel có chấm xanh đậm. Các ngày có ca học có chấm tròn sự kiện bên dưới.

### 4.5. Phân nhóm ca học theo ngày (Timeline Group Header)
- Dưới dải tuần là các nhóm ca học theo ngày:
  - Header nhóm: Chấm tròn `•` + Text in hoa `HÔM NAY — THỨ SÁU, 24 THÁNG 10` + Pill badge `3 ca học`.
  - Nhóm kế tiếp: `• NGÀY MAI — THỨ BẢY, 25 THÁNG 10` + Pill badge `2 ca học`.

---

## 5. TÁI SỬ DỤNG TỪ STUDENT ROLE & HOME PARENT

| Thành phần | Nguồn tái sử dụng | Mức độ tái sử dụng & Điều chỉnh cho Parent |
| :--- | :--- | :--- |
| **Card Ca học dùng chung (`ParentScheduleCard`)** | Component mới chuẩn hóa | **Dùng chung 100%** cho cả Home (`upcoming_schedule_section.dart`) và Schedule (`parent_schedule_screen.dart`). |
| **Thanh chọn con (Family Scope)** | `features/parent/presentation/home/widgets/family_scope_selector.dart` | **Tái sử dụng 100%**: Dùng chung logic chọn con, ẩn nút tất cả khi có 1 con, chip trắng nổi trên nền `surfaceBg`. |
| **Logic tính lịch tuần & Event Dates** | `features/student/presentation/schedule/widgets/calendar_widget.dart` | **Kế thừa 80% logic tính ngày**: Kế thừa thuật toán tính ngày bắt đầu tuần, danh sách `DateTime` 7 ngày, so khớp `isSameDay`. |
| **Design Tokens & Theme** | `theme/app_colors.dart`, `app_spacing.dart`, `app_radius.dart` | **Tái sử dụng 100%**: Bảng màu `TogetherColorsX.blue600`, `slate900`, `slate500`, radius chuẩn, shadow mềm. |

---

## 6. MA TRẬN TRẠNG THÁI HỆ THỐNG & CÁC TRƯỜNG HỢP NGOẠI LỆ (EDGE CASES)

| Tình huống / Ngữ cảnh | Giao diện hiển thị (UI Behavior) | Hành động của người dùng (Action) |
| :--- | :--- | :--- |
| **1. Chưa liên kết con (No-Child)** | Toàn bộ màn hình thay bằng `ParentNoChildView` chuẩn đã xây dựng ở Home. | Bấm nút "Liên kết hồ sơ con" để nhập mã. |
| **2. Con chưa tham gia lớp nào (No-Class)** | Card Empty State: Icon lớp học mờ, tiêu đề *"Con chưa tham gia lớp học nào"*, giải thích rõ. | Nút "Liên hệ trung tâm / Tư vấn khóa học". |
| **3. Ngày chọn không có ca học (Empty Date)** | Thẻ All-Clear giữa màn hình: Icon lịch xanh lá `verified_rounded`, *"Không có buổi học nào trong ngày này"*. | Bấm "Xem ngày tiếp theo có ca học" hoặc chuyển tab "Tuần này". |
| **4. Đang tải dữ liệu (Loading State)** | Skeleton Shimmer: Hiệu ứng nhấp nháy cho dải tuần và 2 thẻ ca học giả lập. | Tránh giật màn hình khi tải mạng chậm. |
| **5. Lỗi kết nối / Lỗi server (Error State)** | Banner báo lỗi màu đỏ nhạt + Nút "Thử lại", giữ nguyên ngày và tab đang chọn. | Bấm "Thử lại" hoặc kéo xuống để Refresh (`RefreshIndicator`). |
| **6. Ngoại tuyến (Offline Mode)** | Hiển thị dữ liệu lịch đã lưu trong Local Cache kèm banner nhỏ màu vàng: *"Đang ngoại tuyến — Lịch học cập nhật lúc 08:30"*. | Link xem chi tiết vẫn mở được thông tin offline từ cache. |

---

## 7. THIẾT KẾ DATA MODELS, BLOC & REPOSITORY

### 7.1. Data Model: `ParentScheduleSession` (Dùng chung cho cả Home & Schedule)
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

### Bước 2: Xây dựng Component Card Dùng Chung (`ParentScheduleCard`)
- Xây dựng widget `ParentScheduleCard` theo đúng thiết kế 4 tầng:
  1. Avatar con + Tên con — Môn học + Badge trạng thái (Đang diễn ra / Sắp diễn ra / Đã kết thúc).
  2. Icon đồng hồ + Thời gian to rõ (`09:00 — 10:00`).
  3. Box `Bài học: ${lessonTopic}` nền xám nhạt.
  4. Footer: `Giáo viên: ${instructorName}` (trái) và link `Xem chi tiết buổi học >` (phải).
- **Tuyệt đối không có nút "Vào lớp học ngay" hay nút "Bản đồ".**

### Bước 3: Đồng bộ Card sang Màn hình Trang chủ (`ParentHomeScreen`)
- Cập nhật [`upcoming_schedule_section.dart`](file:///C:/ForteX/mobile/lib/features/parent/presentation/home/widgets/upcoming_schedule_section.dart) ở Trang chủ: Thay thế card ngang cũ `_ScheduleItemCard` bằng card mới `ParentScheduleCard`.
- Bổ sung data binding trường `lessonTopic` để card hiển thị đầy đủ tên bài học trên Trang chủ.

### Bước 4: Xây dựng BLoC Quản lý State Lịch học
- Tạo `ParentScheduleBloc`, `ParentScheduleEvent`, `ParentScheduleState`.
- Hỗ trợ lọc theo con, chọn ngày tuần, chuyển tab (Hôm nay / Tuần này / Tháng này) và nhóm ca học theo ngày.

### Bước 5: Xây dựng UI Components Dải lịch tuần & Bộ lọc
- Tạo `ScheduleSegmentedControl` (Hôm nay / Tuần này / Tháng này).
- Tạo `WeekCalendarCard` bọc trong thẻ trắng: header tuần + badge số buổi trong tuần + dải 7 ngày với capsule highlight và chấm event dot.
- Tạo `DateGroupHeader` hiển thị `• HÔM NAY — THỨ SÁU, 24 THÁNG 10` kèm pill badge `3 ca học`.

### Bước 6: Ráp nối Toàn diện Màn hình `ParentScheduleScreen` & Xử lý Ngoại lệ
- Tích hợp Header, `FamilyScopeSelector`, `ScheduleSegmentedControl`, `WeekCalendarCard`, danh sách `DateGroupSection` và các `ParentScheduleCard`.
- Áp dụng phân tầng màu nền: Header trắng, Body `surfaceBg`.
- Xử lý No-Child, No-Class, Empty Date, Loading Skeleton và Error Retry.

### Bước 7: Kiểm thử & Phân tích Tĩnh
- Chạy `flutter analyze` đảm bảo không có bất kỳ lỗi linter nào.
- Kiểm tra tính tương thích và mượt mà trên ứng dụng.

---

## 9. CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)

- [ ] **Đồng bộ Card duy nhất:** Cả Trang chủ (Home) và Tab Lịch học (Schedule) đều hiển thị cùng 1 cấu trúc card `ParentScheduleCard`.
- [ ] **Header Tab Lịch học:** Icon lịch vuông xanh + tiêu đề `Lịch Học` + chuông thông báo và avatar.
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
