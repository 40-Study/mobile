# KẾ HOẠCH NÂNG CẤP TOÀN DIỆN GIAO DIỆN TRANG CHỦ PHỤ HUYNH (PARENT HOME SCREEN)

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/`)  
> **Nhánh:** `UI/Parent`  
> **Tài liệu đối chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Deliverable đặc tả kỹ thuật role Parent)  
> - 3 ảnh thiết kế thực tế:  
>   + `uploaded_media_0`: Home Dashboard đầy đủ dữ liệu (Family Scope, Cần xử lý, Lịch học, Phân tích học tập)  
>   + `uploaded_media_1` & `uploaded_media_2`: Home Dashboard trạng thái Chưa liên kết con (No-child Onboarding / Empty State)  
> - Quy chuẩn Design System của role Student (`mobile/lib/theme/*`, `features/student/*`)  
> **Ngày lập kế hoạch:** 23/09/2026  
> **Trạng thái:** DRAFT PLAN - CHUẨN BỊ TRIỂN KHAI (Chưa thực hiện code)

---

## MỤC LỤC
1. [TỔNG QUAN & MỤC TIÊU](#1-tổng-quan--mục-tiêu)
2. [ĐỐI CHIẾU QUY CHUẨN THIẾT KẾ ROLE STUDENT (DESIGN SYSTEM COMPARISON)](#2-đối-chiếu-quy-chuẩn-thiết-kế-role-student)
3. [GAP ANALYSIS: HIỆN TRẠNG CODE VS. MOCKUPS VS. DELIVERABLE](#3-gap-analysis-hiện-trạng-code-vs-mockups-vs-deliverable)
4. [KIẾN TRÚC GIAO DIỆN & STATE MACHINE CHI TIẾT](#4-kiến-trúc-giao-diện--state-machine-chi-tiết)
5. [QUY CHUẨN DESIGN TOKENS CHO PARENT HOME](#5-quy-chuẩn-design-tokens-cho-parent-home)
6. [KẾ HOẠCH TRIỂN KHAI THEO GIAI ĐOẠN (IMPLEMENTATION ROADMAP)](#6-kế-hoạch-triển-khai-theo-giai-đoạn)
7. [CHECKLIST NGHIỆM THU (VERIFICATION & DEFINITION OF DONE)](#7-checklist-nghiệm-thu)

---

## 1. TỔNG QUAN & MỤC TIÊU

### 1.1. Bối cảnh
Màn hình **Trang chủ Phụ huynh (Parent Home Screen)** đóng vai trò là "Tổng hành dinh" (Family Cockpit) cho phụ huynh theo dõi toàn bộ hành trình học tập của con cái tại trung tâm 40Study. 

Theo đặc tả `deliverable.md`:
- Phụ huynh có thể có 0 con (vừa tạo tài khoản, chưa nhập mã học sinh), 1 con hoặc nhiều con học tại trung tâm.
- Ở Trang chủ, phụ huynh xem được bức tranh tổng hợp toàn gia đình (**Family Scope**), nhận diện tức thì các vấn đề khẩn cấp (**Action Required**), nắm bắt lịch trình kế tiếp (**Upcoming Schedule**) và quan sát nhịp tiến bộ học tập (**Learning Analytics**).

### 1.2. Mục tiêu nâng cấp
1. **Khớp 100% Pixel-Perfect với Mockups:** Tái hiện chính xác bố cục, màu sắc, khoảng cách, phân cấp thị giác từ 3 ảnh thiết kế đã cung cấp (`uploaded_media_0` cho Active State và `uploaded_media_1` & `_2` cho No-child State).
2. **Đạt đẳng cấp chất lượng như Role Student UI:** Áp dụng toàn bộ hệ thống Design Tokens (`TogetherColorsX`, `AppRadius`, `AppShadows`, `AppSpacing`, `AppTypography`), kỹ thuật layer surfaces và micro-interactions mượt mà của Student vào Parent.
3. **Thỏa mãn 100% Deliverable Role Parent:**
   - Xử lý triệt để 2 trạng thái màn hình lớn: **No-Child Onboarding View** (khi `children.isEmpty`) và **Active Family Dashboard View** (khi `children.isNotEmpty`).
   - Xử lý các trạng thái rỗng thành phần (All-Clear 0 việc tồn đọng, Không có lịch học hôm nay, Chưa có dữ liệu phân tích).
   - Tối ưu hóa Family Scope Filter tương tác mượt mà giữa "Tất cả các con" và từng con cụ thể.

---

## 2. ĐỐI CHIẾU QUY CHUẨN THIẾT KẾ ROLE STUDENT

Hệ thống giao diện Student trong codebase đã đạt mức hoàn thiện rất cao nhờ áp dụng nghiêm ngặt các nguyên lý sau. Parent UI cần áp dụng đồng bộ:

| Tiêu chí | Quy chuẩn Role Student | Đánh giá áp dụng cho Parent Home |
| :--- | :--- | :--- |
| **Color Tokens** | Sử dụng triệt để `TogetherColorsX` (`blue600`, `blue700`, `slate900`, `slate800`, `slate500`, `slate100`, `achievementGreen`, `achievementRed`, `achievementAmber`, v.v.). Tuyệt đối không hardcode mã Hex lặp lại. | Thay thế toàn bộ mã `Color(0xFF...)` hardcode trong `parent/presentation/home/widgets` bằng token từ `cs.*` và `TogetherColorsX`. |
| **Layered Surfaces** | Nền màn hình `surfaceContainerLowest` hoặc `slate50` (`#F8FAFC`), các Card nội dung màu trắng `surface` (`#FFFFFF`), viền border mảnh `outlineVariant.withValues(alpha: 0.4)` kết hợp `AppShadows.card` tạo độ nổi tinh tế (Z-index ảo). | Loại bỏ viền thô và shadow đơn điệu hiện tại; áp dụng border mảnh + shadow phân tầng mềm mại cho toàn bộ card: Action Required, Schedule, Analytics. |
| **Corner Radius** | Sử dụng hằng số từ `AppRadius`: `borderSm` (8px), `borderMd` (12px), `borderLg` (16px), `borderFull` (999px). Không dùng `BorderRadius.circular(random)` tùy tiện. | Chuẩn hóa: Thẻ lớn = `AppRadius.borderLg` (16px), Icon box = `AppRadius.borderMd` (12px), Badges & Chips = `AppRadius.borderFull`. |
| **Typography Hierarchy** | Tuân thủ nghiêm ngặt `AppTypography`: <br>- Eyebrow / Overline: `labelSmall` bold, tracking `1.0 - 1.2`, uppercase.<br>- Card Header: `titleSmall` / `labelLarge` bold 700.<br>- Primary Stats: `displaySmall` / `headlineMedium` bold 800.<br>- Body / Meta: `bodySmall` regular, line-height 1.4 - 1.5. | Áp dụng đúng cỡ chữ và letter-spacing cho các nhãn `PHỤ HUYNH 40STUDY`, `FAMILY SCOPE • CHẾ ĐỘ GIÁM SÁT`, `CẦN XỬ LÝ`, `HÔM NAY / TIẾP THEO`, `PHÂN TÍCH HỌC TẬP`. |
| **Visual Indicators** | Dùng chấm trạng thái (Status Dot 8px) kết hợp Pill Badge để tăng cường khả năng quét thông tin (scannability). Màu sắc ngữ nghĩa: Đỏ = Overdue/Urgent, Vàng cam = Warning/Change, Xanh lá = Success/Good, Xanh dương = Informational. | Áp dụng chuẩn cho Action Required (chấm đỏ/xanh lá), Schedule tags (xanh dương/xám), và Analytics progress (+15% xanh lá). |
| **Empty States** | Không bao giờ để màn hình trống rỗng hoặc card xám xịt. Empty state phải có: Icon minh họa đặc thù -> Tiêu đề rõ ràng -> Mô tả nguyên nhân thân thiện -> CTA hành động giải quyết. | Xây dựng màn hình No-child Onboarding chuẩn mực theo ảnh 2 & 3 và các empty card con (All-Clear, No Schedule, No Report). |

---

## 3. GAP ANALYSIS: HIỆN TRẠNG CODE VS. MOCKUPS VS. DELIVERABLE

Qua rà soát từng dòng code trong `mobile/lib/features/parent/presentation/home/`, nhóm phát triển ghi nhận các khoảng cách (gaps) cần khắc phục:

### 3.1. Thiếu sót nghiêm trọng nhất: Trạng thái Chưa liên kết con (No-child State)
- **Hiện trạng code:** Khi `data.children.isEmpty`, trong `parent_home_screen.dart` vẫn render lần lượt `FamilyScopeSelector`, `ActionRequiredSection`, `UpcomingScheduleSection`, `LearningAnalyticsCard`. Điều này làm người dùng mới thấy hàng loạt card "0 việc tồn đọng", "Không có ca học nào", "Chưa có dữ liệu" một cách vô nghĩa và rối mắt.
- **Yêu cầu theo ảnh `uploaded_media_1` & `_2`:** Toàn bộ trang Home phải chuyển đổi thành màn hình **No-Child Onboarding Screen**:
  1. Header: Icon gia đình + `PHỤ HUYNH 40STUDY` + Tiêu đề `Trang chủ Phụ huynh` + Avatar `PH`.
  2. Hero Card lớn:
     - Vòng tròn xanh dương pastel lớn (`#EFF6FF`) với icon gia đình xanh đậm (`#2563EB`) và badge tròn nhỏ mang icon dấu cộng `+`.
     - Tiêu đề: **"Chưa có hồ sơ con được liên kết"**.
     - Mô tả: "Liên kết tài khoản của con bằng mã học viên do trung tâm cung cấp để bắt đầu theo dõi tiến độ, lịch học và kết quả."
     - Nút CTA chính: **"+ Liên kết hồ sơ con ngay"** (FilledButton xanh dương lớn).
     - Link phụ trợ: Icon `?` + **"Chưa có mã học viên? Liên hệ Giáo vụ hỗ trợ"**.
  3. Khối giải thích giá trị tính năng (**Feature Highlights Section**):
     - Section Eyebrow: `SAU KHI LIÊN KẾT BẠN SẼ THEO DÕI ĐƯỢC` kèm divider mảnh.
     - 3 Feature Item Rows tinh xảo với icon bo tròn màu sắc:
       + *Lịch học & Điểm danh thời gian thực* (Icon lịch xanh/tím).
       + *Bài tập về nhà, Hạn nộp & Chấm điểm* (Icon bài tập cam/vàng).
       + *Live Tracking & Báo cáo phân tích học tập* (Icon biểu đồ xanh lá).

### 3.2. Rà soát Header (`parent_home_header.dart`)
- **Khoảng cách:**
  - Chưa hỗ trợ dynamic title theo state: Khi chưa có con hiển thị `"Trang chủ Phụ huynh"`, khi đã có con hiển thị `"Chào buổi sáng, Gia đình!"` (hoặc chào theo buổi).
  - Khoảng cách padding top/bottom đang cố định, cần bọc `SafeArea` hoặc tính toán padding cân đối với status bar.
  - Avatar phụ huynh: Cần hiển thị chuẩn initials chữ "PH" hoặc ảnh đại diện từ session.

### 3.3. Rà soát Family Scope Selector (`family_scope_selector.dart`)
- **Khoảng cách:**
  - Tiêu đề phụ: Đang để chữ `• FAMILY SCOPE • CHẾ ĐỘ GIÁM SÁT` cứng, cần đồng bộ letterSpacing `1.2`, font size `11sp`.
  - Chip "Tất cả các con": Khi unselected thì style thế nào? Hiện tại chip này luôn nhận màu đen `slate900`. Cần có logic đổi sang style unselected khi phụ huynh chọn 1 con cụ thể.
  - Chip con: Khi được chọn (selected), cần có viền xanh `blue600`, nền xanh nhạt hoặc trắng nổi bật, avatar chữ cái sắc nét.

### 3.4. Rà soát Section "Cần xử lý" (`action_required_section.dart`)
- **Khoảng cách:**
  - Card chưa có hiệu ứng bo góc và viền chuẩn M3 / Student Design System.
  - Mỗi item trong danh sách:
    + Cần có chevron phải (`Icons.chevron_right_rounded`) màu xám để báo hiệu có thể bấm xem chi tiết bài tập / thông báo đổi lịch.
    + Icon container vuông bo góc 12px (`AppRadius.borderMd`), nền pastel dịu mắt (`0xFFFEE2E2` cho bài tập quá hạn, `0xFFFEF3C7` cho đổi lịch).
    + Dòng phụ: Icon đồng hồ nhỏ màu đỏ + `Hạn chót: 23:59 hôm qua` hoặc icon thông tin nhỏ màu cam + `Giáo viên vừa xác nhận`.
  - Trạng thái Empty (All-Clear): Giữ nguyên giao diện viền xanh lá nhạt + khiên xanh tích hợp sẵn từ plan trước nhưng tinh chỉnh typography chuẩn theo `AppTypography`.

### 3.5. Rà soát Section "Hôm nay / Tiếp theo" (`upcoming_schedule_section.dart`)
- **Khoảng cách:**
  - Đường kẻ phân cách giữa cột Giờ và cột Nội dung: Đang dùng `Container(width: 1, height: 56)` cứng. Nếu text nội dung dài làm thẻ cao lên thì vạch kẻ sẽ bị hụt. Cần dùng `IntrinsicHeight` kết hợp `VerticalDivider`.
  - Badge trạng thái bên phải (`Sắp bắt đầu`, `Trực tiếp`): Thiếu icon chevron điều hướng bên cạnh.
  - Toàn bộ item cần bọc trong InkWell để phụ huynh bấm vào mở chi tiết buổi học (phòng học, link Meet).
  - Phân loại rõ ràng 2 dạng ca học theo mockup:
    + **ONLINE**: Giờ và tag màu xanh dương (`14:00`, `ONLINE`, `Trực tuyến trên Google Meet`, badge `Sắp bắt đầu`).
    + **TẠI CƠ SỞ**: Giờ và tag màu xám đậm (`16:30`, `TẠI CƠ SỞ`, `Cơ sở Phan Xích Long`, `Phòng 302`, badge `Trực tiếp`).

### 3.6. Rà soát Section "Phân tích học tập" (`learning_analytics_card.dart`)
- **Khoảng cách:**
  - Biểu đồ mini chart: Code hiện tại đang render 5 thanh container thủ công. Cần tinh chỉnh tỷ lệ cột, bo góc 3px, màu sắc gradient mượt mà hoặc tùy biến bằng `CustomPainter` / widget chuẩn để thể hiện xu hướng tăng dần trực quan.
  - Badge tiến bộ: `+15%` với mũi tên hướng lên màu xanh lá (`AchievementColors.green` hoặc `TogetherColorsX.achievementGreen`).
  - Hộp Callout AI Insight: Nền xanh nhạt `#F0F7FF`, viền trái dày 3.5px màu `blue700`, chữ có highlight từ khóa quan trọng `"Cải thiện rõ ở dạng Đọc hiểu"`.
  - Footer Links: 2 link `"Xem phân tích của [Tên con] ->"` và `"Tất cả báo cáo >"` cần padding chạm cảm ứng chuẩn (ít nhất 44px height tap-target).

---

## 4. KIẾN TRÚC GIAO DIỆN & STATE MACHINE CHI TIẾT

### 4.1. Sơ đồ cây Widget (Widget Hierarchy)

```
ParentHomeScreen
└── BlocBuilder<ParentHomeBloc, ParentHomeState>
    ├── ParentHomeLoading -> _HomeLoading (Shimmer Skeleton)
    ├── ParentHomeFailure -> _HomeError (Error Screen + Retry Button)
    └── ParentHomeSuccess(data, selectedChildId)
        └── Scaffold (backgroundColor: slate50 / surfaceContainerLowest)
            └── SafeArea
                └── RefreshIndicator
                    └── ListView (bọc toàn trang cuộn mượt)
                        ├── ParentHomeHeader (Greeting + Notification Badge + Profile Avatar)
                        │
                        └── IF data.children.isEmpty (NO-CHILD ONBOARDING STATE):
                        │   └── ParentNoChildView
                        │       ├── _HeroLinkChildCard (Icon minh họa + Tiêu đề + CTA + Hotline hỗ trợ)
                        │       └── _FeatureHighlightsSection (3 giá trị cốt lõi: Lịch học, Bài tập, Live tracking)
                        │
                        └── IF data.children.isNotEmpty (ACTIVE FAMILY DASHBOARD STATE):
                            ├── FamilyScopeSelector (Tất cả các con + Chip từng con)
                            ├── AppSpacing.vGap16
                            ├── ActionRequiredSection (Cảnh báo bài tập quá hạn / Đổi lịch học HOẶC 0 việc tồn đọng)
                            ├── AppSpacing.vGap16
                            ├── UpcomingScheduleSection (Lịch học Online / Offline hôm nay HOẶC Không có ca học)
                            ├── AppSpacing.vGap16
                            └── LearningAnalyticsCard (Điểm số TB + Mini chart + AI Insight HOẶC Chưa có dữ liệu)
```

### 4.2. Sơ đồ trạng thái hiển thị (Display State Matrix)

| Thành phần Widget | Trạng thái Chưa liên kết con (`children.isEmpty`) | Trạng thái Có con & Có dữ liệu đầy đủ | Trạng thái Có con & Dữ liệu rỗng cục bộ |
| :--- | :--- | :--- | :--- |
| **ParentHomeHeader** | Title: `"Trang chủ Phụ huynh"` | Title: `"Chào buổi sáng, Gia đình!"` | Title: `"Chào buổi sáng, Gia đình!"` |
| **FamilyScopeSelector** | Ẩn hoàn toàn (hoặc tích hợp trong No-child Hero) | Hiển thị: Tất cả các con + Chip từng con | Hiển thị: Chip con hiện có |
| **ActionRequiredSection** | Ẩn (được thay thế bởi No-child Hero) | Hiển thị: Danh sách item bài tập quá hạn / đổi giờ | Hiển thị: Card xanh All-Clear `"0 việc tồn đọng - Tất cả ổn định"` |
| **UpcomingScheduleSection**| Ẩn (được thay thế bởi No-child Hero) | Hiển thị: Danh sách ca học Online / Offline hôm nay | Hiển thị: Card `"Hôm nay không có ca học nào"` + Link TKB |
| **LearningAnalyticsCard** | Ẩn (được thay thế bởi No-child Hero) | Hiển thị: Điểm TB `8.4`, biểu đồ cột mini, AI insight | Hiển thị: Card `"Chưa có dữ liệu phân tích tuần này"` + Link Bảng điểm |
| **No-Child Onboarding View** | **HIỂN THỊ CHÍNH TÂM** (Hero Card + 3 Feature Highlights) | Ẩn hoàn toàn | Ẩn hoàn toàn |

---

## 5. QUY CHUẨN DESIGN TOKENS CHO PARENT HOME

Để đảm bảo đồng bộ 100% với giao diện Student, Parent Home tuân thủ bảng ánh xạ token:

### 5.1. Màu sắc (Color Tokens via `TogetherColorsX`)

```dart
// Nền & Phân tầng Surface
final surfaceBackground = cs.surfaceContainerLowest; // hoặc cs.slate50 (#F8FAFC)
final cardBackground    = cs.surface;                 // #FFFFFF
final cardBorder        = cs.outlineVariant.withValues(alpha: 0.4);

// Thương hiệu & Điểm nhấn chính
final primaryBlue       = cs.blue600;                // #2563EB
final primaryDarkBlue   = cs.blue700;                // #1D4ED8
final bluePastelBg      = Color(0xFFEFF6FF);         // Xanh dương rất nhạt cho icon box/callout

// Ngữ nghĩa cảnh báo (Alerts & Badges)
final overdueRed        = AchievementColors.red;      // #EF4444
final overdueRedBg      = Color(0xFFFEE2E2);         // Nền tag quá hạn
final warningAmber      = Color(0xFFF59E0B);         // Vàng cam cho đổi lịch
final warningAmberBg    = Color(0xFFFEF3C7);         // Nền tag thay đổi
final successGreen      = AchievementColors.green;    // #10B981
final successGreenBg    = Color(0xFFECFDF5);         // Nền All-Clear & +15% badge
final successGreenBorder= Color(0xFFA7F3D0);

// Text & Monochromes
final textPrimary       = cs.slate900;                // #0F172A
final textSecondary     = cs.slate600;                // #475569
final textMuted         = cs.slate400;                // #94A3B8
final textCapsEyebrow   = cs.slate500;                // #64748B
```

### 5.2. Typography (Ánh xạ `AppTypography`)

- **Header Super-Title:** `tt.labelSmall?.copyWith(color: cs.slate500, fontWeight: FontWeight.w700, letterSpacing: 1.2)`
- **Header Main Title:** `tt.titleMedium?.copyWith(color: cs.slate900, fontWeight: FontWeight.w700, fontSize: 18)`
- **Section Eyebrow:** `tt.labelSmall?.copyWith(color: cs.blue600, fontWeight: FontWeight.w700, letterSpacing: 1.0)`
- **Card Title / Child Name:** `tt.titleSmall?.copyWith(color: cs.slate900, fontWeight: FontWeight.w700, fontSize: 15)`
- **Schedule Time Big:** `tt.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 20)`
- **Big Score Stat:** `tt.displaySmall?.copyWith(color: cs.slate900, fontWeight: FontWeight.w800, fontSize: 38, height: 1.0)`
- **Body & Captions:** `tt.bodySmall?.copyWith(color: cs.slate500, height: 1.45)`
- **Badges:** `tt.labelSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 11)`

### 5.3. Spacing & Radius

- **Padding ngang toàn trang:** `AppSpacing.lg` (16px)
- **Khoảng cách dọc giữa các Card:** `AppSpacing.vGap16` (16px)
- **Padding trong Card:** `EdgeInsets.all(AppSpacing.lg)` (16px)
- **Bo góc Card:** `AppRadius.borderLg` (16px)
- **Bo góc Icon Square:** `AppRadius.borderMd` (12px)
- **Bo góc Chips & Badges:** `AppRadius.borderFull` (999px)
- **Độ nổi Card (BoxShadow):**
  ```dart
  boxShadow: [
    BoxShadow(
      color: cs.shadow.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ]
  ```

---

## 6. KẾ HOẠCH TRIỂN KHAI THEO GIAI ĐOẠN (IMPLEMENTATION ROADMAP)

> ⚠️ **LƯU Ý:** Giai đoạn này chỉ lập kế hoạch, KHÔNG viết code mã nguồn thực tế. Việc coding sẽ thực hiện ở bước tiếp theo sau khi kế hoạch được phê duyệt.

### Giai đoạn 1: Xây dựng Component No-Child Onboarding Screen
- **Mục tiêu:** Tạo mới widget hiển thị trạng thái khi phụ huynh chưa liên kết con theo đúng 100% ảnh `uploaded_media_1` & `_2`.
- **File tạo mới:**
  - `mobile/lib/features/parent/presentation/home/widgets/parent_no_child_view.dart`
- **Nội dung widget:**
  1. `_HeroLinkChildCard`:
     - Avatar minh họa gia đình + huy hiệu `+`.
     - Tiêu đề "Chưa có hồ sơ con được liên kết".
     - Đoạn văn bản hướng dẫn sử dụng mã học viên.
     - Nút bấm `FilledButton` "+ Liên kết hồ sơ con ngay" (kết nối điều hướng sang `AddChildScreen` hoặc `ManageChildrenScreen`).
     - Hàng trợ giúp "Chưa có mã học viên? Liên hệ Giáo vụ hỗ trợ" (có thể bấm để mở modal hỗ trợ hoặc gọi hotline).
  2. `_FeatureHighlightsSection`:
     - Tiêu đề "SAU KHI LIÊN KẾT BẠN SẼ THEO DÕI ĐƯỢC".
     - Danh sách 3 item giải thích 3 giá trị: Lịch học realtime, Bài tập & Điểm số, Báo cáo & Live tracking.
- **Export widget:** Cập nhật `widgets.dart`.

### Giai đoạn 2: Cập nhật Điều kiện Điều hướng tại `parent_home_screen.dart`
- **Mục tiêu:** Điều phối hiển thị mượt mà giữa `ParentNoChildView` và Active Dashboard.
- **File cập nhật:**
  - `mobile/lib/features/parent/presentation/home/parent_home_screen.dart`
- **Nội dung sửa đổi:**
  - Kiểm tra điều kiện:
    ```dart
    final hasChildren = data.children.isNotEmpty;
    if (!hasChildren) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          children: [
            ParentHomeHeader(
              titleOverride: 'Trang chủ Phụ huynh',
              onNotificationTap: () => _openNotifications(context),
              onAvatarTap: onNavigateToProfile,
            ),
            ParentNoChildView(
              onLinkChild: () => _openManageChildren(context),
            ),
          ],
        ),
      );
    }
    ```
  - Khi đã có con: Render đầy đủ `ParentHomeHeader` -> `FamilyScopeSelector` -> `ActionRequiredSection` -> `UpcomingScheduleSection` -> `LearningAnalyticsCard`.

### Giai đoạn 3: Nâng cấp Toàn diện các Widget Thành phần trên Active Dashboard
1. **`parent_home_header.dart`:**
   - Thêm tham số `titleOverride` để linh hoạt thay đổi giữa "Trang chủ Phụ huynh" và "Chào buổi sáng, Gia đình!".
   - Chuẩn hóa typography, icon gia đình bo tròn và badge thông báo đỏ.
2. **`family_scope_selector.dart`:**
   - Hoàn thiện style tương tác giữa chip "Tất cả các con" (nền đen khi chọn, nền xám khi bỏ chọn) và từng chip con (nền xanh viền nổi khi chọn).
   - Đảm bảo hiển thị đúng avatar chữ cái, tên con và lớp học.
3. **`action_required_section.dart`:**
   - Thêm icon chevron bên phải mỗi alert item.
   - Thêm dòng phụ hiển thị hạn chót / thời gian xác nhận có icon nhỏ đi kèm.
   - Hoàn thiện micro-animation và padding pixel-perfect theo `uploaded_media_0`.
4. **`upcoming_schedule_section.dart`:**
   - Dùng `IntrinsicHeight` và `VerticalDivider` thay cho `Container(width: 1, height: 56)`.
   - Bổ sung style phân biệt rõ ràng giữa ca học ONLINE (xanh) và TẠI CƠ SỞ (xám đậm).
   - Thêm chevron điều hướng và bọc toàn bộ item trong `InkWell` với `AppRadius.borderMd`.
5. **`learning_analytics_card.dart`:**
   - Vẽ lại biểu đồ cột mini 5 thanh mượt mà, bo góc trên 3px, chiều cao cân đối với điểm số 38sp.
   - Căn chỉnh box Callout AI Insight với viền trái 3.5px và highlight từ khóa.
   - Tối ưu hóa 2 nút liên kết: "Xem phân tích của [Tên con] ->" và "Tất cả báo cáo >".

### Giai đoạn 4: Kiểm thử Tích hợp & Tối ưu Responsive
- Kiểm tra trên các kích thước màn hình phổ biến (màn hình nhỏ 360dp, màn hình tiêu chuẩn 390dp-412dp, màn hình lớn).
- Đảm bảo Dark Mode / Light Mode tương thích (ưu tiên hiển thị sáng rực rỡ theo đúng mockup).
- Kiểm tra khả năng xử lý dữ liệu thực từ Backend vs Fallback demo data:
  - Khi backend trả về `children: []` -> Hiện đúng No-child Onboarding Screen.
  - Khi backend trả về có con nhưng chưa có lịch -> Hiện đúng Empty Schedule Card.
  - Khi backend trả về có đầy đủ con và lịch -> Hiện đúng Active Dashboard sống động.

---

## 7. CHECKLIST NGHIỆM THU (VERIFICATION & DEFINITION OF DONE)

Khi bước vào giai đoạn code, sản phẩm chỉ được nghiệm thu khi đạt đủ các tiêu chí:

- [ ] **No-Child State:** Khi `children.isEmpty`, hiển thị giao diện Onboarding chuẩn xác theo ảnh `uploaded_media_1` & `_2`, có nút bấm dẫn sang màn hình liên kết con.
- [ ] **Header:** Hiển thị icon gia đình, lời chào theo ngữ cảnh, chuông thông báo có badge đỏ, avatar phụ huynh chuẩn xác.
- [ ] **Family Scope Selector:** Chuyển đổi qua lại giữa "Tất cả các con" và từng con mượt mà, phản ánh đúng filter trên các section con.
- [ ] **Action Required:** Có badge đỏ `X nhắc nhở` khi có việc tồn đọng; chuyển sang card xanh lá `0 việc tồn đọng - Tất cả ổn định` khi không có cảnh báo.
- [ ] **Upcoming Schedule:** Hiển thị phân biệt rõ ca học ONLINE vs TẠI CƠ SỞ, có đầy đủ thời gian, link Meet/phòng học, badge trạng thái và chevron điều hướng.
- [ ] **Learning Analytics:** Điểm số to rõ ràng 38sp, mini chart 5 cột cân xứng, AI insight callout box nổi bật, các link điều hướng hoạt động tốt.
- [ ] **Design Tokens:** 100% màu sắc, bo góc, bóng đổ và typography kế thừa từ Design System của Student (`TogetherColorsX`, `AppRadius`, `AppSpacing`, `AppTypography`).
- [ ] **Flutter Analyze:** Không phát sinh bất kỳ warning hay lint error nào (`flutter analyze` sạch 100%).
- [ ] **Clean Architecture:** Tách biệt rõ ràng Data -> Bloc -> Presentation Widgets, code dễ đọc, dễ bảo trì.
