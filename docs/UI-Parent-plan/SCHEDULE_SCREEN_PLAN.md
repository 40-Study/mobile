# KẾ HOẠCH XÂY DỰNG GIAO DIỆN TAB LỊCH HỌC (PARENT SCHEDULE SCREEN) - V1.0

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/presentation/schedule/`)  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả chi tiết vai trò Phụ huynh - Section A, B, C, D, E, G, H)  
> - 3 ảnh thiết kế thực tế mới nhất: `uploaded_media_0_1790156299357.png`, `uploaded_media_1`, `uploaded_media_2` (Giao diện chuẩn Tab Lịch học)  
> - Chuẩn Design System Role Student (`mobile/lib/theme/*`, `features/student/presentation/schedule/*`)  
> - Chuẩn Trang chủ Phụ huynh mới cập nhật (`mobile/lib/features/parent/presentation/home/*`)  
> **Ngày lập kế hoạch:** 23/09/2026  
> **Tác giả:** Antigravity Team  

---

## MỤC LỤC
1. [TỔNG QUAN & MỤC TIÊU](#1-tổng-quan--mục-tiêu)
2. [ĐỐI CHIẾU SPEC DELIVERABLE & PHÂN TÍCH ẢNH THIẾT KẾ](#2-đối-chiếu-spec-deliverable--phân-tích-ảnh-thiết-kế)
3. [ĐỀ XUẤT CẢI TIẾN & NÂNG CẤP THIẾT KẾ SO VỚI MOCKUP](#3-đề-xuất-cải-tiến--nâng-cấp-thiết-kế-so-với-mockup)
4. [KIẾN TRÚC GIAO DIỆN & CẤU TRÚC THÀNH PHẦN (UI COMPONENT HIERARCHY)](#4-kiến-trúc-giao-diện--cấu-trúc-thành-phần)
   - [4.1. Header: Đồng bộ chuẩn Parent Header](#41-header-đồng-bộ-chuẩn-parent-header)
   - [4.2. Thanh chọn con (Family Scope Selector)](#42-thanh-chọn-con-family-scope-selector)
   - [4.3. Bộ lọc thời gian (Segmented Control: Hôm nay / Tuần này / Sắp tới)](#43-bộ-lọc-thời-gian-segmented-control)
   - [4.4. Dải lịch tuần tương tác (Interactive Week Calendar Strip)](#44-dải-lịch-tuần-tương-tác-week-calendar-strip)
   - [4.5. Section Header & Thẻ đếm số buổi học](#45-section-header--thẻ-đếm-số-buổi-học)
   - [4.6. Thẻ Ca học Online (Trực tuyến)](#46-thẻ-ca-học-online-trực-tuyến)
   - [4.7. Thẻ Ca học Offline (Tại lớp & Hộp nhắc đưa đón)](#47-thẻ-ca-học-offline-tại-lớp--hộp-nhắc-đưa-đón)
   - [4.8. Thẻ Ca học Bị hủy hoặc Đổi lịch](#48-thẻ-ca-học-bị-hủy-hoặc-đổi-lịch)
5. [TÁI SỬ DỤNG TỪ STUDENT ROLE & HOME PARENT](#5-tái-sử-dụng-từ-student-role--home-parent)
6. [MA TRẬN TRẠNG THÁI HỆ THỐNG & CÁC TRƯỜNG HỢP NGOẠI LỆ (EDGE CASES)](#6-ma-trận-trạng-thái-hệ-thống--các-trường-hợp-ngoại-lệ)
7. [THIẾT KẾ DATA MODELS, BLOC & REPOSITORY](#7-thiết-kế-data-models-bloc--repository)
8. [KẾ HOẠCH TRIỂN KHAI THEO TỪNG BƯỚC (STEP-BY-STEP IMPLEMENTATION)](#8-kế-hoạch-triển-khai-theo-từng-bước)
9. [CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)](#9-checklist-nghiệm-thu)

---

## 1. TỔNG QUAN & MỤC TIÊU

Tab **Lịch học (Schedule)** là một trong hai trụ cột cốt lõi phục vụ hành vi hằng ngày của phụ huynh (cùng với Home). Mục tiêu chính:
1. **Trả lời tức thì 3 câu hỏi lớn của phụ huynh trong ngày:**
   - Hôm nay con có học không? Mấy giờ?
   - Học ở đâu (Trực tuyến qua Meet/Zoom hay Tại cơ sở nào)?
   - Cần đưa đón lúc mấy giờ (đối với lớp offline) hoặc con cần vào phòng học lúc nào (đối với lớp online)?
2. **Hỗ trợ quan sát toàn diện cả gia đình (Family Scope):** Phụ huynh có 2-3 con có thể nhìn thấy lịch tổng thể của tất cả các con trong ngày/tuần để tiện sắp xếp công việc và đưa đón.
3. **Đồng bộ nhận diện với Home Screen Parent và Student UI:** Nền màu `surfaceBg` phân tầng, Header nền trắng tinh tế, các Card trắng độc lập nổi bật, font chữ to rõ, tương phản cao, tối ưu tuyệt đối cho mắt người lớn tuổi.

---

## 2. ĐỐI CHIẾU SPEC DELIVERABLE & PHÂN TÍCH ẢNH THIẾT KẾ

### 2.1. Đối chiếu tài liệu `deliverable.md`
- **Mục A & B:** Schedule là `child scope` (child selector ở root), gồm các góc nhìn: Today / This week / Upcoming; và điều hướng sang `Schedule Detail` (locked child context).
- **Mục C (Flow 1 & Flow 3):**
  - Tap sự kiện lịch → mở `Schedule Detail` (mang theo context con, lớp, buổi học).
  - Child selection state đồng bộ: nếu phụ huynh đã chọn con A ở Home hoặc Learning thì khi qua Schedule sẽ giữ nguyên con A; hoặc nếu bấm từ deep-link thì tự động khóa đúng con trong link.
- **Mục D & E (Navigation & System States):**
  - Hỗ trợ đầy đủ các trạng thái hệ thống: `No-child` (chưa có con), `No-class` (con chưa vào lớp), `Offline` (xem cache có nhãn cập nhật), `Cancelled/Rescheduled` (buổi học bị hủy/đổi lịch vẫn hiển thị kèm badge cảnh báo, không xóa ngầm).

### 2.2. Phân tích ảnh thiết kế thực tế (`uploaded_media_0_1790156299357.png`)
Ảnh thiết kế thể hiện bố cục từ trên xuống dưới:
1. **Header:** Nhãn `PHỤ HUYNH 40STUDY` + Tiêu đề lớn `Lịch học` + Icon chuông thông báo (kèm chấm đỏ) + Avatar tròn `PH`.
2. **Family Scope Bar:** Dòng text `• FAMILY SCOPE • CHẾ ĐỘ GIÁM SÁT 09:15 hôm nay` + Dải chip `[Tất cả các con] [Minh (10A1)] [Lan (7B)]`.
3. **Segmented Control:** `[Hôm nay]` `[Tuần này]` `[Sắp tới]`.
4. **Dải lịch tuần (Week Calendar Strip):** 7 ngày trong tuần `T2 20`, `T3 21`, `T4 22`, `T5 23`, `T6 24` (vòng tròn xanh active), `T7 25`, `CN 26`.
5. **Dòng ngày & Thống kê:** `Thứ Sáu, 24 Tháng 10` + Pill badge `3 buổi học hôm nay`.
6. **Section Header:** `TIẾN TRÌNH LỚP HỌC HÔM NAY` (chữ in hoa) + `3 ca học`.
7. **Card ca học Online (Toán của Minh):**
   - Badge tròn chữ `M` + Tên con & Lớp: `Minh — Toán (Đại số 10)` + Badge `• Sắp diễn ra`.
   - Giờ to đậm: `09:00 — 10:00`.
   - Tên chuyên đề: `Chuyên đề: Phương trình bậc hai & Định lý Vi-ét`.
   - Thông tin: `Giáo viên: Cô Lan` | `Trực tuyến: Google Meet` (icon video).
   - Nút hành động: `Vào lớp học ngay` (màu xanh thương hiệu có icon play) + Nút `Chi tiết`.
8. **Card ca học Offline (Tiếng Anh của Lan):**
   - Badge tròn chữ `L` + Tên con & Lớp: `Lan — Tiếng Anh giao tiếp` + Badge `Chiều nay`.
   - Giờ to đậm: `14:00 — 15:30`.
   - Tên bài: `Bài thực hành: Speaking Fluency & Unit 4 Presentation`.
   - Thông tin: `Giáo viên: Thầy Nam` | `Tại lớp: Phòng 302, CS Phan Xích Long` (icon map pin).
   - **Hộp nhắc nhở đưa đón (Reminder Banner):** Nền vàng pastel, text đỏ/cam `Nhắc nhở: Đưa đón con trước 13:50` + Nút xanh `Bản đồ`.

---

## 3. ĐỀ XUẤT CẢI TIẾN & NÂNG CẤP THIẾT KẾ SO VỚI MOCKUP

Theo chỉ dẫn của người dùng: *"các hình ảnh có thể có sai lệch một chút, bạn có thể đưa ra ý kiến sửa đổi và nâng cấp cho phù hợp thay vì follow 100% ảnh thiết kế"*. Antigravity đề xuất 5 cải tiến vượt trội sau:

| Điểm trên Mockup | Nhược điểm thực tế | Giải pháp cải tiến & Nâng cấp (Chuẩn Home Parent & Student UI) |
| :--- | :--- | :--- |
| **Dòng chữ phụ `• FAMILY SCOPE • CHẾ ĐỘ GIÁM SÁT 09:15 hôm nay`** | Rườm rà, rối mắt, làm chật chội không gian trên màn hình nhỏ. Người dùng vừa yêu cầu loại bỏ dòng này ở Home Screen. | **LOẠI BỎ HOÀN TOÀN dòng text này.** Ngay dưới Header là thanh chọn con hiển thị sạch sẽ, thoáng mắt. |
| **Nền trắng phẳng lì xuyên suốt cả màn hình trong mockup** | Mọi thành phần (Header, Selector, Calendar, Cards) đều nằm trên 1 nền trắng làm các Card bị chìm, thiếu chiều sâu. | **ÁP DỤNG PHÂN TẦNG MÀU NỀN NHƯ STUDENT UI & HOME PARENT:**<br>- Header nền trắng tinh khiết (`#FFFFFF`).<br>- Toàn bộ Body bên dưới nằm trong container bo góc trên (`Radius.circular(24)`) với màu nền `surfaceBg` (xám xanh dịu nhẹ).<br>- Các Card ca học màu trắng tinh khôi nổi bật hoàn hảo trên nền `surfaceBg`. |
| **Nút "Tất cả các con" luôn hiện dù chỉ có 1 con** | Khi tài khoản chỉ có 1 con, nút "Tất cả các con" bị thừa và vô nghĩa. | **Áp dụng rule thông minh từ Home:** Nếu chỉ có 1 con, chỉ hiển thị đúng chip con đó. Nếu có từ 2 con trở lên mới hiển thị nút `Tất cả các con` kèm badge đếm số lượng con. |
| **Dải lịch tuần tĩnh (Static Week Strip)** | Trong ảnh mockup dải tuần chỉ hiển thị 7 ngày cố định, không rõ cơ chế sang tuần khác. | **Nâng cấp thành Interactive Week Calendar Strip:**<br>- Cho phép vuốt ngang (Swipe gesture) hoặc bấm mũi tên để chuyển tuần trước / tuần kế tiếp.<br>- Dưới mỗi ngày có **Chấm sự kiện (Event dots)** màu xanh báo hiệu ngày nào có lịch học (kế thừa logic từ Student Calendar). |
| **Nút "Vào lớp học ngay" và "Bản đồ"** | Trong ảnh mockup chỉ là UI tĩnh. | **Tích hợp Dynamic Action Binding:**<br>- Nút `Vào lớp học ngay`: Mở trực tiếp URL Google Meet/Zoom thật hoặc deep link vào phòng học.<br>- Nút `Bản đồ`: Tích hợp mở ứng dụng bản đồ thiết bị (Google Maps / Apple Maps) với tọa độ cơ sở thực tế. |

---

## 4. KIẾN TRÚC GIAO DIỆN & CẤU TRÚC THÀNH PHẦN

```text
ParentScheduleScreen (Scaffold: backgroundColor = surfaceBg)
├── Header (Container trắng: ParentScheduleHeader)
│   ├── Label: "PHỤ HUYNH 40STUDY"
│   ├── Title: "Lịch học"
│   └── Actions: [Notification Bell Badge, Avatar Circle]
│
└── Body Container (surfaceBg, borderRadius top: 24, shadow upward)
    ├── 1. FamilyScopeSelector (Kế thừa từ Home: [Tất cả con] [Minh] [Lan])
    ├── vGap16
    ├── 2. ScheduleSegmentedControl ([Hôm nay] [Tuần này] [Sắp tới])
    ├── vGap16
    ├── 3. WeekCalendarStrip (T2 20 ... CN 26 với event dots & active circle)
    ├── vGap12
    ├── 4. DateSummaryRow (Thứ Sáu, 24 Tháng 10 + Pill badge "3 buổi học hôm nay")
    ├── vGap16
    ├── 5. SectionHeader ("TIẾN TRÌNH LỚP HỌC HÔM NAY" + "3 ca học")
    ├── vGap12
    └── 6. ScheduleCardsList (Danh sách các thẻ ca học độc lập)
        ├── OnlineScheduleCard (09:00 - 10:00, Meet, nút "Vào lớp ngay", "Chi tiết")
        ├── OfflineScheduleCard (14:00 - 15:30, Phòng 302, Box nhắc đón con + "Bản đồ")
        └── RescheduledOrCancelledCard (nếu có ca bị đổi lịch/hủy)
```

### 4.1. Header: Đồng bộ chuẩn Parent Header
- **Vị trí:** Cố định trên cùng, nền trắng (`Colors.white`).
- **Nội dung:**
  - Nhãn trên: `PHỤ HUYNH 40STUDY` (font 11sp, bold 700, màu `slate500`, tracking 1.1).
  - Tiêu đề: `Lịch học` (font 24sp, bold 700, màu `slate900`).
  - Phía bên phải: Icon chuông thông báo (kèm badge đỏ khi có thông báo mới) + Avatar viết tắt tên phụ huynh (lấy data từ `AuthBloc`).
- **Padding:** `fromLTRB(16, 8, 16, 16)`.

### 4.2. Thanh chọn con (Family Scope Selector)
- **Tái sử dụng trực tiếp:** `FamilyScopeSelector` đã chuẩn hóa ở Home Screen.
- **Nằm trên nền:** `surfaceBg`.
- **Logic:**
  - Khi chọn `Tất cả các con`: Danh sách lịch hiển thị tổng hợp tất cả các con, sắp xếp theo thứ tự thời gian trong ngày. Mỗi Card ca học tự hiển thị badge tên con (`Minh`, `Lan`).
  - Khi chọn từng con cụ thể (`Minh`): Tự động lọc danh sách chỉ hiển thị ca học của `Minh`.
  - Nếu chỉ có 1 con: Ẩn nút "Tất cả các con", tự động chọn con duy nhất.

### 4.3. Bộ lọc thời gian (Segmented Control: Hôm nay / Tuần này / Sắp tới)
- **Thiết kế:** Thanh chuyển tab 3 nút nền xám mờ bo tròn (`AppRadius.borderFull` hoặc `borderLg`), nút đang chọn có nền trắng tinh khiết nổi lên với shadow nhẹ.
- **3 Tab:**
  1. `Hôm nay`: Tự động cuộn đến ngày hiện tại, hiển thị các ca học trong ngày.
  2. `Tuần này`: Hiển thị toàn bộ dải tuần hiện tại, mặc định chọn ngày hôm nay; phụ huynh có thể chạm vào bất kỳ ngày nào trong tuần để xem lịch ngày đó.
  3. `Sắp tới`: Danh sách các ca học sắp diễn ra từ ngày mai trở đi, nhóm theo từng ngày.

### 4.4. Dải lịch tuần tương tác (Interactive Week Calendar Strip)
- **Hiển thị:** 7 cột tương ứng 7 ngày (T2, T3, T4, T5, T6, T7, CN).
- **Cấu trúc mỗi ngày:**
  - Tên thứ: `T2` ... `CN` (font 12sp, màu xám `slate500`).
  - Ngày trong tháng: `20` ... `26` (font 16sp bold).
  - Khi được chọn: Bọc trong vòng tròn xanh thương hiệu `cs.blue600` (đường kính 40px), chữ số màu trắng, thứ đổi sang màu xanh đậm bold.
  - **Dấu chấm sự kiện (Event Indicator Dot):** Chấm tròn 4px màu xanh `blue600` bên dưới số ngày nếu ngày đó có ít nhất 1 ca học (kế thừa logic từ Student Calendar).
- **Tính năng vuốt tuần:** Hỗ trợ vuốt sang trái/phải để chuyển tuần trước / tuần sau, có nút nhảy nhanh về `Hôm nay`.

### 4.5. Section Header & Thẻ đếm số buổi học
- **Hàng 1 (Ngày & Pill count):**
  - Trái: Text ngày tháng tiếng Việt to rõ: `Thứ Sáu, 24 Tháng 10` (font 16sp, bold 700, màu `slate900`).
  - Phải: Pill badge bo tròn nền xanh nhạt `Color(0xFFEFF6FF)`: `3 buổi học hôm nay` (font 12sp, bold 600, màu `blue600`).
- **Hàng 2 (Section Title in hoa):**
  - Trái: `TIẾN TRÌNH LỚP HỌC HÔM NAY` (font 14sp, bold 700, letter-spacing 0.5, màu `slate700`).
  - Phải: `3 ca học` (font 13sp, màu `slate500`).

### 4.6. Thẻ Ca học Online (Trực tuyến)
- **Card nền trắng:** Bo góc `AppRadius.borderLg`, viền mờ `outlineVariant.withValues(alpha: 0.5)`, shadow mềm mại.
- **Header Card:**
  - Trái: Avatar tròn nhỏ mang chữ cái đầu của con (`M`) nền xanh dương + Text `Minh — Toán (Đại số 10)`.
  - Phải: Badge trạng thái `• Sắp diễn ra` (nền `Color(0xFFEFF6FF)`, text `blue600`).
- **Thời gian:** `09:00 — 10:00` (font 22sp, bold 800, màu `slate900`).
- **Chuyên đề:** `Chuyên đề: Phương trình bậc hai & Định lý Vi-ét` (font 14sp, màu `slate600`).
- **Meta Info:**
  - Icon người: `Giáo viên: Cô Lan`.
  - Icon video camera xanh: `Trực tuyến: Google Meet`.
- **Hàng nút hành động:**
  - Nút chính: `Vào lớp học ngay` (màu xanh `blue600`, icon play trắng, bo góc 12px, chiếm 65% chiều ngang).
  - Nút phụ: `Chi tiết` (màu xám `slate100`, text `slate700`, chiếm 35% còn lại) → mở màn hình chi tiết buổi học.

### 4.7. Thẻ Ca học Offline (Tại lớp & Hộp nhắc đưa đón)
- **Card nền trắng:** Tương tự ca online.
- **Header Card:**
  - Trái: Avatar chữ cái `L` nền hồng/tím + `Lan — Tiếng Anh giao tiếp`.
  - Phải: Badge trạng thái `Chiều nay` (nền `slate100`, text `slate600`).
- **Thời gian:** `14:00 — 15:30` (font 22sp bold).
- **Chuyên đề:** `Bài thực hành: Speaking Fluency & Unit 4 Presentation`.
- **Meta Info:**
  - `Giáo viên: Thầy Nam`.
  - Icon địa điểm đỏ/cam: `Tại lớp: Phòng 302, CS Phan Xích Long`.
- **Hộp nhắc nhở đưa đón (Pick-up Reminder Box):**
  - Đặt dưới phần meta info, nền vàng be nhạt `Color(0xFFFEF3C7)`, bo góc `AppRadius.borderMd`.
  - Trái: `Nhắc nhở: Đưa đón con trước 13:50` (font 13sp, bold 600, màu `Color(0xFFB45309)`).
  - Phải: Link `Bản đồ` (màu xanh `blue600`, bold 700) → chạm để mở ứng dụng Google Maps dẫn đường đến cơ sở.
- **Nút hành động:** Nút `Chi tiết` xem toàn bộ giáo trình và tài liệu buổi học.

### 4.8. Thẻ Ca học Bị hủy hoặc Đổi lịch
- **Khi ca học bị đổi lịch (Rescheduled):** Badge màu hổ phách `Đã đổi lịch`, ghi rõ giờ cũ và giờ mới kèm lý do.
- **Khi ca học bị hủy (Cancelled):** Badge màu đỏ `Đã hủy`, nền card hơi mờ nhẹ, ghi rõ lý do hủy và thông tin học bù nếu trung tâm đã xếp lịch.

---

## 5. TÁI SỬ DỤNG TỪ STUDENT ROLE & HOME PARENT

| Thành phần | Nguồn tái sử dụng | Mức độ tái sử dụng & Điều chỉnh cho Parent |
| :--- | :--- | :--- |
| **Thanh chọn con (Family Scope)** | `features/parent/presentation/home/widgets/family_scope_selector.dart` | **Tái sử dụng 100%**: Dùng chung logic chọn con, ẩn nút tất cả khi có 1 con, chip trắng nổi trên nền `surfaceBg`. |
| **Logic tính lịch tuần & Event Dates** | `features/student/presentation/schedule/widgets/calendar_widget.dart` | **Kế thừa 80% logic tính ngày**: Kế thừa thuật toán tính ngày bắt đầu tuần (Monday), danh sách `DateTime` 7 ngày, thuật toán so khớp `isSameDay(d1, d2)`. |
| **Model Ca học (Schedule Item)** | `features/student/data/models/schedule_item_model.dart` kết hợp `parent_schedule_item.dart` | **Mở rộng**: Kết hợp trường học sinh `childId`, `childName`, `childBadgeColor` vào model buổi học của Parent để phục vụ hiển thị đa con. |
| **Design Tokens & Theme** | `theme/app_colors.dart`, `app_spacing.dart`, `app_radius.dart` | **Tái sử dụng 100%**: Bảng màu `TogetherColorsX.blue600`, `slate900`, `slate500`, radius chuẩn, shadow mềm. |
| **Header Notification & Profile Navigation** | `features/parent/presentation/home/widgets/parent_home_header.dart` | **Kế thừa cấu trúc**: Đồng bộ layout nhãn thương hiệu, icon chuông và avatar profile. |

---

## 6. MA TRẬN TRẠNG THÁI HỆ THỐNG & CÁC TRƯỜNG HỢP NGOẠI LỆ (EDGE CASES)

| Tình huống / Ngữ cảnh | Giao diện hiển thị (UI Behavior) | Hành động của người dùng (Action) |
| :--- | :--- | :--- |
| **1. Chưa liên kết con (No-Child)** | Toàn bộ màn hình thay bằng `ParentNoChildView` chuẩn đã xây dựng ở Home. | Bấm nút "Liên kết hồ sơ con" để nhập mã. |
| **2. Con chưa tham gia lớp nào (No-Class)** | Card Empty State: Icon lớp học mờ, tiêu đề *"Con chưa tham gia lớp học nào"*, giải thích *"Khi con được xếp vào lớp, thời khóa biểu sẽ xuất hiện tại đây"*. | Nút "Liên hệ trung tâm / Tư vấn khóa học". |
| **3. Ngày chọn không có ca học (Empty Date)** | Thẻ All-Clear giữa màn hình: Icon lịch xanh lá `verified_rounded`, *"Không có buổi học nào trong ngày này"*, *"Hôm nay là thời gian nghỉ ngơi hoặc tự ôn tập của con"*. | Bấm "Xem ngày tiếp theo có ca học" hoặc bấm sang tab "Tuần này". |
| **4. Đang tải dữ liệu (Loading State)** | Skeleton Shimmer: Hiệu ứng nhấp nháy cho dải tuần và 2 thẻ ca học giả lập. | Tránh giật màn hình khi tải mạng chậm. |
| **5. Lỗi kết nối / Lỗi server (Error State)** | Banner báo lỗi màu đỏ nhạt + Nút "Thử lại", giữ nguyên ngày và tab đang chọn. | Bấm "Thử lại" hoặc kéo xuống để Refresh (`RefreshIndicator`). |
| **6. Ngoại tuyến (Offline Mode)** | Hiển thị dữ liệu lịch đã lưu trong Local Cache kèm banner nhỏ màu vàng: *"Đang ngoại tuyến — Lịch học cập nhật lúc 08:30"*. | Các nút mở link Meet hoặc Map nếu không có mạng sẽ có dialog thông báo rõ. |
| **7. Ca học đang diễn ra (In-Progress)** | Badge xanh lá chuyển động nhẹ `• Đang diễn ra`, Card ca học có viền xanh nổi bật. | Phụ huynh có thể bấm "Vào lớp ngay" để kiểm tra con đã vào học chưa. |

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
  final ParentScheduleMode mode; // online | offline
  final String instructorName;
  final String? roomOrPlatform; // "Phòng 302, CS Phan Xích Long" hoặc "Google Meet"
  final String? meetingUrl;     // URL phòng Meet/Zoom
  final String? mapUrl;         // Tọa độ/Link Google Map cơ sở
  final DateTime? pickupTime;   // Giờ đưa đón khuyến nghị (13:50)
  final ParentSessionStatus status; // upcoming | inProgress | completed | cancelled | rescheduled
  final String? statusNote;     // Lý do hủy/đổi lịch nếu có
}
```

### 7.2. State Management: `ParentScheduleBloc`
- **Events:**
  - `ParentScheduleStarted`: Tải lịch ban đầu (lấy con đang active từ `ParentHomeBloc` hoặc mặc định Tất cả các con).
  - `ParentScheduleChildFilterChanged(String? childId)`: Lọc theo con.
  - `ParentScheduleTabChanged(ParentScheduleTab tab)`: Chuyển tab Hôm nay / Tuần này / Sắp tới.
  - `ParentScheduleDateSelected(DateTime date)`: Chọn ngày trên dải tuần.
  - `ParentScheduleWeekChanged(DateTime weekStart)`: Vuốt sang tuần trước/sau.
  - `ParentScheduleRefreshed`: Kéo để tải lại dữ liệu mới nhất.
- **States:**
  - `ParentScheduleInitial`: Khởi tạo.
  - `ParentScheduleLoading`: Đang fetch dữ liệu.
  - `ParentScheduleSuccess`: Chứa danh sách `children`, `selectedChildId`, `currentWeekStart`, `selectedDate`, `activeTab`, danh sách `sessions`, `eventDates`.
  - `ParentScheduleFailure`: Chứa thông báo lỗi.

---

## 8. KẾ HOẠCH TRIỂN KHAI THEO TỪNG BƯỚC

### Giai đoạn 1: Chuẩn bị Models & Mock Repository Data Service (Bước 1)
- Tạo model chi tiết `ParentScheduleSession` và các enum (`ParentScheduleMode`, `ParentSessionStatus`, `ParentScheduleTab`).
- Bổ sung mock data phong phú cho đầy đủ các trường hợp: Ca Online của Minh, Ca Offline của Lan có nhắc đưa đón, Ca học ngày mai, Ca học bị đổi giờ.
- **Commit:** `feat(parent): define parent schedule models and mock repository data`

### Giai đoạn 2: Xây dựng BLoC Quản lý State Lịch học (Bước 2)
- Tạo `ParentScheduleBloc`, `ParentScheduleEvent`, `ParentScheduleState`.
- Hỗ trợ đầy đủ logic chuyển tab, chọn ngày, lọc theo con, chuyển tuần và load dữ liệu theo ngày.
- **Commit:** `feat(parent): implement ParentScheduleBloc with filtering and date logic`

### Giai đoạn 3: Xây dựng UI Components Dải lịch tuần & Bộ lọc (Bước 3)
- Tạo `ScheduleSegmentedControl` (Hôm nay / Tuần này / Sắp tới).
- Tạo `WeekCalendarStrip` tương tác 7 ngày với chấm event indicator và active circle.
- Tạo `DateSummaryHeader` hiển thị Thứ, Ngày Tháng và Pill badge đếm số buổi học.
- **Commit:** `feat(parent): build week calendar strip and segmented control widgets`

### Giai đoạn 4: Xây dựng Hệ thống Card Ca học Độc lập (Bước 4)
- Tạo `ScheduleSessionCard` hỗ trợ 2 dạng: Online (với nút "Vào lớp học ngay", "Chi tiết") và Offline (với Hộp nhắc nhở đưa đón và nút "Bản đồ").
- Hỗ trợ trạng thái Hủy/Đổi lịch rõ ràng.
- Đảm bảo font chữ to, tương phản cao, bo góc và đổ bóng đồng bộ Home Screen.
- **Commit:** `feat(parent): create independent schedule session cards with reminder box`

### Giai đoạn 5: Tích hợp Toàn diện Màn hình `ParentScheduleScreen` (Bước 5)
- Ráp nối Header, `FamilyScopeSelector`, `ScheduleSegmentedControl`, `WeekCalendarStrip`, `DateSummaryHeader`, và danh sách các thẻ ca học vào `ParentScheduleScreen`.
- Áp dụng phân tầng màu nền: Header nền trắng, Body container bo góc trên mang màu `surfaceBg`.
- Xử lý mượt mà tất cả các Empty State (No-child, No-class, Empty date), Loading Skeleton và Error Retry.
- **Commit:** `feat(parent): assemble ParentScheduleScreen with full state handling`

### Giai đoạn 6: Kiểm thử & Nghiệm thu (Verification) (Bước 6)
- Chạy `flutter analyze` đảm bảo không có lỗi linter/cú pháp.
- Kiểm tra tính tương thích khi hot reload và chuyển đổi qua lại giữa các tab Bottom Navigation Bar.
- **Commit:** `docs(parent): update schedule screen documentation and verification evidence`

---

## 9. CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)

- [ ] **Header:** Hiển thị chuẩn nhãn `PHỤ HUYNH 40STUDY`, tiêu đề `Lịch học`, chuông thông báo và avatar phụ huynh.
- [ ] **Thanh chọn con:** Nằm trên nền `surfaceBg`, ẩn nút Tất cả nếu chỉ có 1 con, lọc chuẩn xác dữ liệu lịch khi bấm đổi con.
- [ ] **Bộ lọc 3 Tab:** Chuyển đổi trơn tru giữa `Hôm nay`, `Tuần này`, `Sắp tới`.
- [ ] **Dải lịch tuần:** Hiển thị 7 ngày, highlight ngày đang chọn bằng hình tròn xanh, có chấm sự kiện dưới các ngày có ca học, bấm chọn ngày nào lọc đúng ca học ngày đó.
- [ ] **Card Ca học Online:** Hiển thị đầy đủ giờ, tên con + môn, chuyên đề, giáo viên, Meet link, nút "Vào lớp ngay" và "Chi tiết".
- [ ] **Card Ca học Offline:** Hiển thị cơ sở phòng học, giáo viên, hộp nhắc đưa đón màu vàng pastel `Nhắc nhở: Đưa đón con trước 13:50` kèm nút `Bản đồ`.
- [ ] **Phân tầng màu nền:** Header trắng, Body nền xám xanh nhạt `surfaceBg`, các Card trắng nổi bật với viền và shadow nhẹ.
- [ ] **Trường hợp ngoại lệ (Edge Cases):** Empty date hiển thị thẻ All-clear trấn an phụ huynh; No-child hiển thị nút liên kết con; Loading hiển thị shimmer.
- [ ] **Không hardcode:** Toàn bộ ngày tháng, giờ học, tên con, chuyên đề đều bind từ data động.
- [ ] **Chất lượng code:** `flutter analyze` đạt **No issues found!**
