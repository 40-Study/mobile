# KẾ HOẠCH NÂNG CẤP GIAO DIỆN TAB LỊCH HỌC (PARENT SCHEDULE SCREEN) - V3.0

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/`)  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả vai trò Phụ huynh)  
> - 3 ảnh thiết kế thực tế mới:  
>   - `uploaded_media_0_1790240021078.png`: Phân tích loại bỏ option Hôm nay / Tuần này / Tháng này  
>   - `uploaded_media_1_1790240021078.png`: Thiết kế Quyển lịch ở trạng thái Thu gọn (1 tuần)  
>   - `uploaded_media_2_1790240021078.png`: Thiết kế Quyển lịch ở trạng thái Mở rộng (full tháng, multi-color dots theo từng con)  
> - Trang chủ Phụ huynh (`ParentHomeScreen`) làm chuẩn thiết kế  
> **Ngày cập nhật:** 24/09/2026  
> **Phiên bản:** 3.0 (Quyển lịch thu gọn/mở rộng, đồng bộ Header & Thanh chọn con, lọc ca học theo ngày được chọn, xem chi tiết ca học trên cả Home và Schedule)

---

## MỤC LỤC
1. [TỔNG HỢP VÀ PHÂN TÍCH 5 Ý KIẾN CHỈ ĐẠO CỦA USER](#1-tổng-hợp-và-phân-tích-5-ý-kiến-chỉ-đạo-của-user)
2. [PHÂN TÍCH 3 ẢNH THIẾT KẾ MỚI CHO QUYỂN LỊCH](#2-phân-tích-3-ảnh-thiết-kế-mới-cho-quyển-lịch)
3. [KIẾN TRÚC GIAO DIỆN & CẤU TRÚC COMPONENT CHUẨN HOÁ](#3-kiến-trúc-giao-diện--cấu-trúc-component-chuẩn-hoá)
   - [3.1. Đồng bộ Header với Trang chủ (ParentAppHeader)](#31-đồng-bộ-header-với-trang-chủ-parentappheader)
   - [3.2. Chuẩn hoá Thanh chọn con dùng chung (Shared FamilyScopeSelector)](#32-chuẩn-hoá-thanh-chọn-con-dùng-chung-shared-familyscopeselector)
   - [3.3. Quyển lịch thông minh Thu gọn / Mở rộng (ParentExpandableCalendar)](#33-quyển-lịch-thông-minh-thu-gọn--mở-rộng-parentexpandablecalendar)
   - [3.4. Body hiển thị Card ca học theo ngày được chọn (Date-Filtered Session List)](#34-body-hiển-thị-card-ca-học-theo-ngày-được-chọn)
   - [3.5. Đồng bộ chức năng Xem chi tiết ca học trên cả Home và Schedule](#35-đồng-bộ-chức-năng-xem-chi-tiết-ca-học-trên-cả-home-và-schedule)
4. [THIẾT KẾ DATA MODEL, REPOSITORY & BLOC NÂNG CẤP](#4-thiết-kế-data-model-repository--bloc-nâng-cấp)
5. [MA TRẬN TRẠNG THÁI & EDGE CASES](#5-ma-trận-trạng-thái--edge-cases)
6. [KẾ HOẠCH TRIỂN KHAI CHI TIẾT THEO TỪNG BƯỚC (STEP-BY-STEP COMMIT PLAN)](#6-kế-hoạch-triển-khai-chi-tiết-theo-từng-bước)
7. [CHECKLIST NGHIỆM THU CHẤT LƯỢNG (QUALITY GATES)](#7-checklist-nghiệm-thu-chất-lượng)

---

## 1. TỔNG HỢP VÀ PHÂN TÍCH 5 Ý KIẾN CHỈ ĐẠO CỦA USER

### Ý kiến 1: Đồng bộ Header Tab Lịch học theo chuẩn Header Tab Home
- **Vấn đề hiện tại:** Tab Lịch học đang tự cấu hình Header riêng (tiêu đề text đơn giản + icon vuông nhỏ), gây lệch tông về chiều cao, padding, font chữ và trải nghiệm chuyển tab.
- **Yêu cầu giải pháp:**
  - Lấy Header trang Home (`ParentHomeHeader`) làm chuẩn tuyệt đối:
    - Container nền trắng `cs.surface`.
    - Icon tròn `44x44` bên trái với icon đại diện màn hình (lịch học), nền xanh nhạt `#EFF6FF`, icon xanh `cs.blue600` (24px).
    - Cột thông tin:
      - Label trên: in hoa `THỜI KHÓA BIỂU` / `LỊCH HỌC CỦA CON`, font `11px`, `w700`, `letterSpacing: 1.1`, màu `cs.slate500`.
      - Tiêu đề chính dưới: `Lịch học`, font `18px`, `w700`, màu `cs.slate900`.
    - Cụm bên phải: Nút chuông thông báo (kèm badge đỏ khi có thông báo) + Avatar tròn của phụ huynh (radius 20) tap để mở Profile.
  - Chuẩn hoá thành widget dùng chung hoặc kế thừa layout thống nhất.

### Ý kiến 2: Tách Thanh chọn con thành Shared Component trong role Parent
- **Vấn đề hiện tại:** `FamilyScopeSelector` đang nằm riêng trong `presentation/home/widgets/` và các tham số padding, layout dễ bị phân mảnh khi tab Lịch học sử dụng.
- **Yêu cầu giải pháp:**
  - Di chuyển `FamilyScopeSelector` ra thư mục dùng chung: `lib/features/parent/presentation/widgets/family_scope_selector.dart`.
  - Cả `ParentHomeScreen` và `ParentScheduleScreen` đều import và sử dụng chung 1 component duy nhất.
  - Giữ nguyên trạng thái: Chiều cao `44px`, không có background trắng bao quanh, chip "Tất cả các con" xanh dương đậm có badge đếm số con, các chip con với avatar chữ cái đầu nền pastel.

### Ý kiến 3: Thay thế bộ lọc thời gian bằng Quyển lịch Thu gọn / Mở rộng
- **Vấn đề hiện tại:** Đang có bộ chọn 3 tab `Hôm nay / Tuần này / Tháng này` và dải lịch 1 tuần cố định không xem được tháng.
- **Yêu cầu giải pháp:**
  - **Loại bỏ hoàn toàn** option tab `Hôm nay / Tuần này / Tháng này` (`ScheduleSegmentedControl`).
  - Xây dựng widget **Quyển lịch (Expandable Calendar)**:
    - Mặc định ngày được chọn luôn là **ngày hôm nay theo thời gian thực** (`DateTime.now()`).
    - **Trạng thái Thu gọn (Collapsed - Weekly View):** Hiển thị 1 tuần (chứa ngày đang chọn) gồm 7 ngày (T2 -> CN). Header hiển thị `Tuần [số tuần] · [ngày bắt đầu] - [ngày kết thúc] Tháng [tháng]` + badge `• X buổi học trong tuần`.
    - **Trạng thái Mở rộng (Expanded - Monthly View):** Hiển thị full lưới ngày trong tháng (Grid 7 cột), có 2 nút `<` và `>` để chuyển tháng trước/sau.
    - **Multi-color event dots:** Mỗi con có 1 màu chấm đại diện (vd: Minh màu xanh dương `•`, Lan màu hồng tím `•`). Ngày nào có lịch của con nào thì hiển thị chấm màu của con đó. Nếu cả 2 con cùng có lịch thì hiện 2 chấm cạnh nhau `• •`.
    - Dưới cùng của lịch tháng có thanh **Chú thích (Legend):** `• Minh (Toán, Tin, Lý)   • Lan (Anh, Văn)`.
    - Hỗ trợ thao tác chạm header hoặc icon để toggle Thu gọn / Mở rộng mượt mà.

### Ý kiến 4: Body chỉ hiển thị ca học của ngày được chọn
- **Vấn đề hiện tại:** Danh sách bên dưới gom tất cả các ca học trong tuần thành nhiều nhóm ngày, khiến phụ huynh khó tập trung vào ngày đang chọn.
- **Yêu cầu giải pháp:**
  - **Chỉ hiển thị các ca học của đúng ngày đang được chọn** trên lịch.
  - **Khi chọn "Tất cả các con" (`selectedChildId == null`):**
    - Chia làm các Section theo từng con trong ngày hôm đó:
      - Section Con 1 (vd: Minh): Header con (Avatar tròn + Tên con Minh · Lớp 10A1 + Số ca học) ➔ Danh sách các thẻ `ParentScheduleCard` của Minh trong ngày.
      - Section Con 2 (vd: Lan): Header con (Avatar tròn + Tên con Lan · Lớp 7B + Số ca học) ➔ Danh sách các thẻ `ParentScheduleCard` của Lan trong ngày.
  - **Khi chọn 1 con cụ thể (`selectedChildId != null`):**
    - Chỉ hiển thị danh sách các ca học của con đó trong ngày đã chọn.
  - **Quy tắc sắp xếp:** Mặc định tăng dần theo thời gian bắt đầu ca học (`startTime`).
  - Nếu ngày đó không có ca học: Hiển thị Thẻ Empty State "Không có ca học nào" với icon calendar và thông điệp nghỉ ngơi/tự học.

### Ý kiến 5: Chức năng Xem chi tiết buổi học hoạt động trên cả Home và Schedule
- **Vấn đề hiện tại:** Modal xem chi tiết ca học chỉ mới gắn trên tab Lịch học, ở màn hình Home nhấn vào card chưa hiển thị modal.
- **Yêu cầu giải pháp:**
  - Tách `_SessionDetailSheet` thành component dùng chung: `ParentSessionDetailSheet` (hoặc helper function `showParentSessionDetailSheet(BuildContext context, ParentScheduleSession session)`).
  - Cả Card ca học ở màn hình Trang chủ (`upcoming_schedule_section.dart`) và màn hình Lịch học (`parent_schedule_screen.dart`) đều kích hoạt cùng một modal chi tiết này khi nhấn vào card hoặc nút `Xem chi tiết buổi học >`.
  - **Đảm bảo tuyệt đối:** Phụ huynh chỉ xem (xem giáo viên, bài học, hình thức/phòng, lưu ý), **KHÔNG có nút vào lớp học**.

---

## 2. PHÂN TÍCH 3 ẢNH THIẾT KẾ MỚI CHO QUYỂN LỊCH

```
┌────────────────────────────────────────────────────────────────────────┐
│ ẢNH 1: HIỆN TRẠNG CẦN THAY THẾ                                          │
│ [ Hôm nay ] [ Tuần này ] [ Tháng này ]  <-- BỎ HOÀN TOÀN                │
│ [ Thẻ lịch tuần 7 ngày cố định ]                                       │
└────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ ẢNH 2: QUYỂN LỊCH Ở TRẠNG THÁI THU GỌN (WEEKLY VIEW)                   │
│ ┌────────────────────────────────────────────────────────────────────┐ │
│ │ 📅 Tuần 42 · 20 - 26 Tháng 10          [ • 14 buổi học trong tuần ]│ │
│ │                                                                    │ │
│ │    T2      T3      T4      T5      T6      T7      CN              │ │
│ │    20      21      22      23     ┌──┐     25      26              │ │
│ │     •       •       •       •     │24│      •       •              │ │
│ │                                   └──┘                             │ │
│ │                                    (chọn: capsule xanh nhạt)       │ │
│ └────────────────────────────────────────────────────────────────────┘ │
│ (Chạm vào hoặc bấm toggle để MỞ RỘNG sang xem toàn bộ tháng)           │
└────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ ẢNH 3: QUYỂN LỊCH Ở TRẠNG THÁI MỞ RỘNG (MONTHLY VIEW)                  │
│ ┌────────────────────────────────────────────────────────────────────┐ │
│ │ Tháng 10, 2026 📅                                  [ < ]   [ > ]   │ │
│ │                                                                    │ │
│ │    T2      T3      T4      T5      T6      T7      CN              │ │
│ │    28      29      30       1       2       3       4              │ │
│ │                             •       •              ••              │ │
│ │     5       6       7       8       9      10      11              │ │
│ │     •       •       •               •      ••                      │ │
│ │    12      13      14      15      16      17      18              │ │
│ │     •              ••       •       •              ••              │ │
│ │    19      20      21      22      23     (24)     25              │ │
│ │     •       •       •               •      ••                      │ │
│ │    26      27      28      29      30      31       1              │ │
│ │     •       •      ••               •       •                      │ │
│ │                                                                    │ │
│ │ ┌────────────────────────────────────────────────────────────────┐ │ │
│ │ │   🔵 Minh (Toán, Tin, Lý)        🟣 Lan (Anh, Văn)             │ │ │
│ │ └────────────────────────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

### Các quy tắc thiết kế cốt lõi rút ra từ ảnh:
1. **Multi-color Dots:**
   - Mỗi con tương ứng 1 màu dot cố định:
     - Minh: Xanh dương `Color(0xFF2563EB)`.
     - Lan: Hồng tím `Color(0xFFEC4899)`.
   - Nếu trong ngày cả 2 con đều có ca học: Hiển thị 2 chấm dot liền kề `• •` dưới ngày đó.
   - Nếu chọn 1 con cụ thể: Chỉ hiển thị chấm dot của con đó để giao diện tinh gọn, không gây rối mắt.
2. **Trạng thái ngày được chọn:**
   - Dạng tuần (Collapsed): Capsule xanh nhạt bo góc mềm mại, chữ số và thứ màu xanh dương đậm.
   - Dạng tháng (Expanded): Vòng tròn xanh dương đậm `Color(0xFF2563EB)`, chữ số màu trắng nổi bật.
3. **Thanh Chú thích (Legend) của Lịch tháng:**
   - Bo góc tròn mềm mại, nền xám nhạt `Color(0xFFF8FAFC)`.
   - Hiển thị chấm màu + Tên con + Tên các môn con đang học trong tháng (vd: `🔵 Minh (Toán, Tin, Lý)` và `🟣 Lan (Anh, Văn)`).
4. **Header tháng tương tác:**
   - Có 2 nút tròn `<` và `>` để duyệt tháng tiếp theo hoặc lùi lại tháng trước.
   - Khi chọn một ngày trong tháng, lịch có thể tự động thu gọn lại hoặc người dùng nhấn nút thu gọn để dành trọn vẹn không gian cho danh sách ca học.

---

## 3. KIẾN TRÚC GIAO DIỆN & CẤU TRÚC COMPONENT CHUẨN HOÁ

### 3.1. Đồng bộ Header với Trang chủ (`ParentAppHeader`)
- **Tập tin:** `lib/features/parent/presentation/widgets/parent_app_header.dart` (hoặc tái sử dụng cấu trúc `ParentHomeHeader` và mở rộng).
- **Thuộc tính:**
  - `leadingIcon`: Icon `Icons.calendar_month_rounded` (màu `cs.blue600`, nền `#EFF6FF`, shape circle 44x44).
  - `categoryLabel`: Text in hoa `THỜI KHÓA BIỂU` (`11px, w700, cs.slate500, letterSpacing: 1.1`).
  - `title`: `Lịch học của con` hoặc `Lịch học` (`18px, w700, cs.slate900`).
  - `trailingActions`: Nút chuông thông báo (kèm badge đỏ) + Avatar tròn phụ huynh (`radius: 20`).
- **Đảm bảo:** 100% kích thước, padding dọc/ngang, kiểu font, hiệu ứng tap trùng khớp hoàn toàn với Header trang Home.

### 3.2. Chuẩn hoá Thanh chọn con dùng chung (`Shared FamilyScopeSelector`)
- **Tập tin:** `lib/features/parent/presentation/widgets/family_scope_selector.dart`
- **Di chuyển & Gom cụm:**
  - Đưa từ `home/widgets/family_scope_selector.dart` ra `presentation/widgets/family_scope_selector.dart`.
  - Re-export trong `presentation/widgets/widgets.dart` và `home/widgets/widgets.dart`.
  - Cả Home và Schedule dùng cùng 1 file, không có sự sai lệch nào về padding hay giao diện.

### 3.3. Quyển lịch thông minh Thu gọn / Mở rộng (`ParentExpandableCalendar`)
- **Tập tin:** `lib/features/parent/presentation/schedule/widgets/parent_expandable_calendar.dart`
- **Trạng thái:**
  - `bool isExpanded` (mặc định: `false` - thu gọn 1 tuần để ưu tiên không gian cho ca học; khi bấm toggle hoặc icon lịch thì mở rộng full tháng).
- **Thuộc tính:**
  - `DateTime selectedDate`: Ngày được chọn (mặc định: `DateTime.now()`).
  - `DateTime currentMonth`: Tháng đang hiển thị (khi ở chế độ tháng).
  - `Map<DateTime, List<String>> childIdsWithEventsByDate`: Bản đồ lưu ngày -> danh sách `childId` có ca học vào ngày đó để hiển thị dot theo đúng màu con.
  - `List<FamilyScopeChild> children`: Danh sách con để lấy màu dot và tên con hiển thị legend.
  - `String? selectedChildId`: Con đang chọn (nếu null là chọn tất cả).
  - `ValueChanged<DateTime> onDateSelected`: Callback khi tap chọn ngày.
  - `ValueChanged<DateTime> onMonthChanged`: Callback khi next/prev tháng.
  - `VoidCallback onToggleExpand`: Callback chuyển đổi thu gọn / mở rộng.

### 3.4. Body hiển thị Card ca học theo ngày được chọn
- **Tập tin:** Trong `parent_schedule_screen.dart`
- **Logic hiển thị:**
  1. Lọc tất cả ca học có `startTime` cùng ngày với `selectedDate`.
  2. Sắp xếp danh sách ca học tăng dần theo `startTime`.
  3. **Nếu `selectedChildId == null` (Tất cả con):**
     - Nhóm theo con: `Map<String, List<ParentScheduleSession>>`.
     - Duyệt từng con trong `children`:
       - Nếu con đó có ca học trong ngày:
         - Render Header con: Avatar tròn con + Tên con (vd: `MINH · LỚP 10A1`) + Badge số lượng ca học (`2 ca học`).
         - Render danh sách các thẻ `ParentScheduleCard(session: session, onTap: ...)`.
       - Khoảng cách giữa các section con là `16px`.
     - Nếu không con nào có ca học: Hiển thị Thẻ Empty State "Không có ca học nào hôm nay".
  4. **Nếu `selectedChildId != null` (1 con cụ thể):**
     - Lọc các ca học của con đó trong ngày.
     - Nếu có: Render danh sách các thẻ `ParentScheduleCard`.
     - Nếu không: Render Empty State cho con đó.

### 3.5. Đồng bộ chức năng Xem chi tiết ca học trên cả Home và Schedule
- **Tập tin:** `lib/features/parent/presentation/widgets/parent_session_detail_sheet.dart`
- **Hàm gọi tiện ích:**
  ```dart
  void showParentSessionDetailSheet(
    BuildContext context, {
    required ParentScheduleSession session,
  });
  ```
- **Tích hợp:**
  - **Trên tab Lịch học (`parent_schedule_screen.dart`):** Gọi khi tap vào card hoặc tap nút `Xem chi tiết buổi học >`.
  - **Trên tab Trang chủ (`upcoming_schedule_section.dart` & `parent_home_screen.dart`):** Khi tap vào card ca học hôm nay hoặc `Xem chi tiết buổi học >` ➔ Mở cùng một BottomSheet chi tiết này.
- **Nội dung BottomSheet chuẩn:**
  - Tiêu đề: "CHI TIẾT BUỔI HỌC" + Nút `X` đóng.
  - Avatar con + `[Tên con] — [Tên môn]` + Status badge (`• Đang diễn ra`, `Sắp diễn ra`, `Đã kết thúc`).
  - Giờ học to rõ + ngày học (`Thứ X, ngày dd/MM/yyyy`).
  - Khối nội dung bài học bo góc xám nhạt (`Bài học: ...`).
  - Hàng thông tin: Giáo viên giảng dạy + Hình thức / Phòng học.
  - Box ghi chú vàng dịu: Lưu ý phụ huynh chuẩn bị sách vở/tài liệu cho con.
  - Nút "Đóng" ở đáy màn hình. Tuyệt đối **KHÔNG có nút "Vào lớp học ngay"**.

---

## 4. THIẾT KẾ DATA MODEL, REPOSITORY & BLOC NÂNG CẤP

### 4.1. Nâng cấp Repository Interface & Implementation
- Cập nhật `ParentScheduleRepository`:
  - `Future<List<ParentScheduleSession>> getScheduleSessions({String? childId, DateTime? date, DateTime? month});`
  - `Future<Map<DateTime, List<String>>> getEventsMapByMonth({String? childId, required DateTime month});`
    - Trả về `Map<DateTime, List<String>>` trong đó `key` là ngày, `value` là danh sách `childId` có ca học ngày đó. Nhờ vậy UI dễ dàng render multi-color dots (chấm xanh cho Minh, chấm hồng cho Lan).

### 4.2. Nâng cấp `ParentScheduleBloc`
- **Events:**
  - `ParentScheduleStarted({String? childId, DateTime? initialDate})`: Khởi tạo tải danh sách con, lấy ca học ngày hôm nay theo thời gian thực và lấy map events tháng hiện tại.
  - `ParentScheduleChildChanged(String? childId)`: Chọn con khác hoặc chọn tất cả con.
  - `ParentScheduleDateSelected(DateTime date)`: Chọn ngày trên lịch. Tự động load sessions của ngày đó.
  - `ParentScheduleMonthChanged(DateTime month)`: Chuyển tháng trên lịch mở rộng.
  - `ParentScheduleCalendarModeToggled()`: Chuyển đổi giữa Thu gọn (Week) và Mở rộng (Month).
  - `ParentScheduleRefreshed()`: Kéo để tải lại dữ liệu.
- **State (`ParentScheduleState`):**
  - `selectedDate`: Ngày đang chọn (mặc định: `DateTime.now()`).
  - `currentMonth`: Tháng đang hiển thị trên lịch.
  - `isCalendarExpanded`: `bool` (thu gọn / mở rộng).
  - `eventsMap`: `Map<DateTime, List<String>>` (ngày -> danh sách con có ca học).
  - `sessions`: Danh sách ca học của ngày được chọn.
  - Helper getter `sessionsByChild`: Nhóm ca học theo từng con trong ngày được chọn.
  - Helper getter `sessionsCountForWeek`: Đếm tổng số buổi học trong tuần chứa `selectedDate` để hiển thị trên badge của lịch thu gọn (vd: `• 14 buổi học trong tuần`).

---

## 5. MA TRẬN TRẠNG THÁI & EDGE CASES

| Trường hợp (Edge Case) | Hành vi giao diện (Expected UI Behavior) |
| :--- | :--- |
| **Hôm nay theo thời gian thực** | Khi mở tab Lịch học, ngày được chọn tự động là `DateTime.now()`. Lịch thu gọn tự động căn tuần chứa ngày hôm nay. |
| **Ngày có ca học của cả Minh & Lan** | Trên lịch tháng hiển thị 2 chấm tròn kế nhau: `•` (xanh) và `•` (hồng). Khi ở chế độ "Tất cả con", body chia 2 section: Section Minh và Section Lan. |
| **Ngày chỉ có ca học của 1 con** | Trên lịch tháng chỉ hiển thị 1 chấm màu của con đó. Khi ở chế độ "Tất cả con", body chỉ hiển thị section của con có ca học. |
| **Ngày không có ca học nào (Ngày nghỉ)** | Lịch không có chấm dot. Body hiển thị Card Empty State thân thiện: "Hôm nay không có ca học nào. Thời gian dành cho nghỉ ngơi hoặc tự ôn tập." |
| **Đang lọc 1 con cụ thể (vd: Minh)** | Lịch chỉ hiển thị chấm xanh của Minh. Body chỉ hiển thị các ca học của Minh. Không hiển thị Section phân chia con nữa. |
| **Chưa liên kết tài khoản con nào** | Hiển thị `ParentNoChildView` chuẩn với nút liên kết tài khoản con. |
| **Kéo xuống làm mới (Pull-to-refresh)** | Reload đồng thời danh sách con, map events tháng và ca học ngày được chọn. |

---

## 6. KẾ HOẠCH TRIỂN KHAI CHI TIẾT THEO TỪNG BƯỚC

Sau mỗi bước hoàn thành, chạy `flutter analyze` kiểm tra sạch lỗi và thực hiện git commit ngắn gọn theo quy chuẩn Conventional Commits.

### 📌 Bước 1: Chuẩn hoá Shared Components (`FamilyScopeSelector` & `ParentSessionDetailSheet`)
1. Di chuyển `family_scope_selector.dart` sang `lib/features/parent/presentation/widgets/family_scope_selector.dart`.
2. Tạo component modal chi tiết buổi học dùng chung: `lib/features/parent/presentation/widgets/parent_session_detail_sheet.dart` với hàm tiện ích `showParentSessionDetailSheet`.
3. Cập nhật `upcoming_schedule_section.dart` trên trang Home: Khi tap vào card hoặc nút xem chi tiết thì mở `showParentSessionDetailSheet`.
4. Export các widget trong `lib/features/parent/presentation/widgets/widgets.dart`.
5. **Git Commit:** `feat(parent): extract shared FamilyScopeSelector and ParentSessionDetailSheet for home and schedule`

### 📌 Bước 2: Nâng cấp Header đồng bộ với Home (`ParentAppHeader`)
1. Xây dựng component `ParentAppHeader` tại `lib/features/parent/presentation/widgets/parent_app_header.dart` với cấu trúc chuẩn Home (Icon tròn 44x44, category in hoa, tiêu đề 18px w700, chuông thông báo có badge, avatar phụ huynh).
2. Tích hợp `ParentAppHeader` vào `ParentScheduleScreen`, đồng bộ 100% kích thước, khoảng cách và thẩm mỹ.
3. **Git Commit:** `feat(parent): standardize ParentAppHeader matching home screen design`

### 📌 Bước 3: Nâng cấp Repository & Data Model hỗ trợ Multi-color Dots & Lịch tháng
1. Bổ sung phương thức `getEventsMapByMonth` trong `ParentScheduleRepository` và `ParentScheduleRepositoryImpl` trả về `Map<DateTime, List<String>>`.
2. Tạo mock data ca học phong phú theo cả tháng cho Minh (xanh) và Lan (hồng) để thể hiện rõ multi-color dots trên lịch.
3. Xoá bỏ enum `ParentScheduleTab` (Hôm nay / Tuần này / Tháng này) không còn dùng.
4. **Git Commit:** `feat(parent): enhance schedule repository with month events map and multi-child support`

### 📌 Bước 4: Xây dựng Quyển lịch Thu gọn / Mở rộng (`ParentExpandableCalendar`)
1. Tạo widget `lib/features/parent/presentation/schedule/widgets/parent_expandable_calendar.dart`:
   - Trạng thái Thu gọn: Dải 7 ngày của tuần, badge tổng số buổi học trong tuần, highlight capsule ngày chọn.
   - Trạng thái Mở rộng: Lưới ngày trong tháng, 2 nút `< >` chuyển tháng, vòng tròn xanh highlight ngày chọn, multi-color dots theo từng con, thanh chú thích (Legend) môn học của con ở chân card.
   - Nút / thao tác toggle thu gọn - mở rộng mượt mà.
2. Xoá bỏ các widget cũ không còn dùng (`schedule_segmented_control.dart`, `week_calendar_card.dart`).
3. **Git Commit:** `feat(parent): build ParentExpandableCalendar supporting week and month views with multi-color dots`

### 📌 Bước 5: Cập nhật `ParentScheduleBloc` quản lý trạng thái lịch và lọc theo ngày
1. Cập nhật `parent_schedule_event.dart`: Xoá event tabChanged, thêm event `ParentScheduleCalendarModeToggled`, `ParentScheduleMonthChanged`.
2. Cập nhật `parent_schedule_state.dart`: Quản lý `isCalendarExpanded`, `eventsMap`, `currentMonth`, helper `sessionsByChild`.
3. Cập nhật `parent_schedule_bloc.dart`: Xử lý logic tải ca học của ngày được chọn và map chấm sự kiện của tháng.
4. **Git Commit:** `feat(parent): update ParentScheduleBloc for expandable calendar and date-filtered sessions`

### 📌 Bước 6: Ráp nối hoàn chỉnh `ParentScheduleScreen` theo 5 yêu cầu
1. Cập nhật `parent_schedule_screen.dart`:
   - Header chuẩn `ParentAppHeader`.
   - `FamilyScopeSelector` dùng chung.
   - `ParentExpandableCalendar` (thu gọn/mở rộng, multi-color dots).
   - Body: Chỉ hiển thị các ca học trong ngày được chọn.
     - Khi chọn tất cả con: Phân chia theo Section từng con kèm avatar và số lượng ca.
     - Khi chọn 1 con: Hiển thị các ca của con đó.
     - Sắp xếp tăng dần theo `startTime`.
   - Tap card mở `showParentSessionDetailSheet`.
2. **Git Commit:** `feat(parent): assemble updated ParentScheduleScreen with date filtering and grouped child sections`

### 📌 Bước 7: Nghiệm thu toàn diện (Verification & Quality Gates)
1. Chạy `flutter analyze` cho toàn bộ dự án và `lib/features/parent/`.
2. Kiểm tra không còn bất kỳ lỗi compile hay warning linter nào.
3. Rà soát lại toàn bộ 5 yêu cầu của User:
   - Header đồng bộ với Home? -> Đạt.
   - Thanh chọn con dùng chung 1 component duy nhất? -> Đạt.
   - Quyển lịch có thu gọn/mở rộng, chuyển tháng, multi-color dots, bỏ option tab? -> Đạt.
   - Body chỉ hiển thị ca học ngày chọn, gom theo con khi chọn tất cả? -> Đạt.
   - Xem chi tiết hoạt động trên cả Home và Schedule? -> Đạt.

---

## 7. CHECKLIST NGHIỆM THU CHẤT LƯỢNG

- [ ] **Đồng bộ Header:** Kích thước, padding, icon 44x44, font chữ, chuông thông báo, avatar phụ huynh giữa Home và Schedule hoàn toàn nhất quán.
- [ ] **Thanh chọn con:** Dùng chung duy nhất một component `FamilyScopeSelector` trong `lib/features/parent/presentation/widgets/`.
- [ ] **Quyển lịch thu gọn/mở rộng:**
  - [ ] Mặc định ngày chọn là hôm nay theo thời gian thực (`DateTime.now()`).
  - [ ] Thu gọn: Hiển thị 1 tuần, badge số ca học trong tuần.
  - [ ] Mở rộng: Hiển thị toàn bộ tháng, chuyển tháng bằng nút `< >`.
  - [ ] Multi-color dots: Minh chấm xanh, Lan chấm hồng; 2 con cùng có lịch thì hiện 2 chấm cạnh nhau.
  - [ ] Chú thích (Legend) hiển thị ở cuối lịch tháng: `• Minh (Toán, Tin, Lý)   • Lan (Anh, Văn)`.
  - [ ] Đã loại bỏ hoàn toàn bộ chọn 3 tab `Hôm nay / Tuần này / Tháng này`.
- [ ] **Body danh sách ca học:**
  - [ ] Chỉ hiển thị các buổi học của ngày đang chọn.
  - [ ] Chọn "Tất cả con" ➔ Tách thành các Section theo từng con với header con riêng biệt.
  - [ ] Chọn 1 con ➔ Chỉ hiển thị các ca học của con đó.
  - [ ] Sắp xếp tăng dần theo giờ bắt đầu (`startTime`).
  - [ ] Empty state khi ngày chọn không có ca học.
- [ ] **Xem chi tiết ca học:**
  - [ ] Hoạt động mượt mà trên cả card ở Home và card ở Schedule.
  - [ ] Phụ huynh chỉ xem, không có nút vào học.
- [ ] **Code Quality:** Không lỗi linter, không compile error (`flutter analyze` pass 100%).
