# Kế hoạch chi tiết: Xây dựng Giao diện Trang chủ Phụ huynh (Parent Home Screen)

> **Dự án:** 40Study Mobile App  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu thiết kế tham chiếu:** `uploaded_media_1790066608691.png`  
> **Ngày tạo kế hoạch:** 22/09/2026  

---

## I. MỤC TIÊU TỔNG THỂ

Xây dựng toàn diện giao diện màn hình **Trang chủ Phụ huynh (Parent Home Screen)** đạt độ chuẩn xác cao (pixel-perfect) theo ảnh thiết kế, đúng chuẩn kiến trúc Clean Code / BLoC pattern của dự án, đồng bộ với các module `student` và `auth`, đồng thời tích hợp mượt mà với các API backend hiện có.

---

## II. BẢNG KIỂM TRA HIỆN TRẠNG API BACKEND (API STATUS MATRIX)

Quá trình kiểm tra thực tế trên Backend (chạy trên port `5000`) với tài khoản phụ huynh `hoangtungaccphugpt1@gmail.com` cho kết quả:

| Chức năng trên UI | API Endpoint Backend | Trạng thái API | Dữ liệu trả về thực tế | Giải pháp trên Mobile |
| :--- | :--- | :---: | :--- | :--- |
| **1. Header (Thông tin PH & Avatar)** | `GET /api/me` hoặc từ Auth state | **ĐÃ CÓ** (200 OK) | `username`, `full_name`, `avatar_url` | Lấy từ `AuthBloc` (đã có sẵn trong session) |
| **2. Family Scope (Bộ chọn con)** | `GET /api/me/children` | **ĐÃ CÓ** (200 OK) | Trả về mảng `children: [{id, username, full_name, avatar_url, relationship}]` | Gọi API thật, render động các Chip "Tất cả các con" + Chip từng con |
| **3. Cần xử lý - Bài tập quá hạn** | `GET /api/parent/children/:id/assignments` | **ĐÃ CÓ** (200 OK) | `stats.overdue`, danh sách assignments với `status: "overdue"`, `due_date`, `title` | Lấy danh sách bài tập quá hạn từ API thật; fallback dữ liệu mẫu nếu rỗng |
| **4. Cần xử lý - Đổi lịch học** | *Chưa có endpoint riêng cho Schedule Change Alerts* | **CHƯA CÓ** | Hiện tại thông báo đổi lịch nằm trong RabbitMQ/Socket chung, chưa tổng hợp thành endpoint REST `alerts` cho PH | Cung cấp fallback data mẫu trong Repository để UI hiển thị đầy đủ theo thiết kế |
| **5. Hôm nay / Tiếp theo (Lịch học)** | `GET /api/parent/children/:id/schedule` | **ĐÃ CÓ** (200 OK) | `upcoming_sessions`: `[{id, class_name, start_time, end_time, room, date}]` | Map trực tiếp từ `upcoming_sessions` sang timeline card; phân loại Online vs Tại cơ sở |
| **6. Phân tích học tập - Điểm số** | `GET /api/parent/children/:id/grades` & `/overview` | **ĐÃ CÓ** (200 OK) | `final_grades[].weighted_average`, `total_study_minutes`, `total_xp` | Hiển thị điểm TB tuần `8.4`, thống kê học tập |
| **7. Phân tích học tập - Biểu đồ cột & AI Insight** | *Chưa có API AI Text Generator* | **CHƯA CÓ** | Backend trả về điểm số thô, chưa có API sinh câu phân tích AI (`"Cải thiện rõ ở dạng Đọc hiểu..."`) | Chuẩn bị trường dữ liệu `insight` và `weeklyTrend` trong Model; cung cấp fallback dữ liệu mẫu |

> **Chiến lược dữ liệu thông minh (Smart Data Strategy):**  
> Repository sẽ gọi API thật. Khi API trả về dữ liệu thật từ DB, UI sẽ ưu tiên hiển thị. Nếu dữ liệu trên database đang trống (do tài khoản test chưa có bài nộp/lịch học thật), Repository tự động bổ sung dữ liệu giả lập (preview/fallback data) để giao diện luôn hiển thị đầy đủ, sống động và đẹp mắt đúng như thiết kế mà không bị crash hoặc trắng trang.

---

## III. QUY CHUẨN ĐẶT TÊN & KIẾN TRÚC THƯ MỤC

Mọi file tạo mới tuân thủ nghiêm ngặt quy ước của dự án:
- **Tên thư mục & file:** `snake_case` (ví dụ: `parent_home_header.dart`, `parent_home_repository.dart`).
- **Tên Class, Interface, Enum:** `PascalCase` (ví dụ: `ParentHomeHeader`, `ParentHomeBloc`).
- **Tên biến, hàm:** `camelCase`.
- **Cấu trúc thư mục:**
  ```
  lib/features/parent/
  ├── data/
  │   ├── models/
  │   │   ├── family_scope_child.dart
  │   │   ├── parent_alert_item.dart
  │   │   ├── parent_schedule_item.dart
  │   │   ├── parent_analytics_data.dart
  │   │   └── parent_home_data.dart
  │   └── parent_home_api_client.dart
  ├── repository/
  │   ├── parent_home_repository.dart
  │   └── parent_home_repository_impl.dart
  ├── bloc/
  │   └── home/
  │       ├── parent_home_bloc.dart
  │       ├── parent_home_event.dart
  │       └── parent_home_state.dart
  └── presentation/
      └── home/
          ├── parent_home_screen.dart
          └── widgets/
              ├── parent_home_header.dart
              ├── family_scope_selector.dart
              ├── action_required_section.dart
              ├── upcoming_schedule_section.dart
              ├── learning_analytics_card.dart
              └── widgets.dart
  ```

---

## IV. CÁC BƯỚC TRIỂN KHAI CHI TIẾT (PHASE-BY-PHASE PLAN)

### GIAI ĐOẠN 1: XÂY DỰNG TẦNG DỮ LIỆU (DATA LAYER)

#### 1.1. Các file tạo mới:
1. `lib/features/parent/data/models/family_scope_child.dart`
   - Chứa model thông tin con cho thanh chọn Scope (`id`, `name`, `className`, `avatarUrl`, `initialLetter`, `badgeColor`).
2. `lib/features/parent/data/models/parent_alert_item.dart`
   - Chứa model cảnh báo "Cần xử lý": loại cảnh báo (`overdue`, `scheduleChange`), tên con, tên môn, tiêu đề, thời gian hạn chót/xác nhận, tag label.
3. `lib/features/parent/data/models/parent_schedule_item.dart`
   - Chứa model buổi học hôm nay: giờ bắt đầu (`14:00`, `16:30`), hình thức (`online`, `offline`), tên con, tên môn, địa điểm/link học, giáo viên/phòng học, tag trạng thái (`Sắp bắt đầu`, `Trực tiếp`).
4. `lib/features/parent/data/models/parent_analytics_data.dart`
   - Chứa model phân tích: tên con, lớp, tuần báo cáo, môn học, tỷ lệ tiến bộ (`+15%`), điểm TB (`8.4 / 10`), 4 mức cột mini chart, nội dung AI insight (`text`, `highlightText`), link hành động.
5. `lib/features/parent/data/models/parent_home_data.dart`
   - Aggregate Model gộp toàn bộ dữ liệu cần thiết cho trang Home: `children`, `selectedChildId`, `alerts`, `schedules`, `analytics`.
6. `lib/features/parent/data/parent_home_api_client.dart`
   - Retrofit client giao tiếp với các endpoint:
     - `GET /api/me/children`
     - `GET /api/parent/children/{id}/overview`
     - `GET /api/parent/children/{id}/schedule`
     - `GET /api/parent/children/{id}/assignments`
     - `GET /api/parent/children/{id}/grades`
7. `lib/features/parent/repository/parent_home_repository.dart`
   - Interface định nghĩa hàm `Future<ParentHomeData> getHomeDashboard({String? childId})`.
8. `lib/features/parent/repository/parent_home_repository_impl.dart`
   - Triển khai logic gọi API thật song song (`Future.wait`), sau đó tổng hợp data và áp dụng smart fallback khi database chưa có đủ mock test.

#### 1.2. Các file chỉnh sửa:
- `lib/di/di_repository_module.dart`: Đăng ký `ParentHomeApiClient` và `ParentHomeRepository` vào GetIt DI container.

#### 1.3. Kết quả cần đạt sau Giai đoạn 1:
- Chạy `dart run build_runner build` thành công.
- Gọi thử Repository lấy được đối tượng `ParentHomeData` đầy đủ, không lỗi null, sẵn sàng cấp cho UI.

---

### GIAI ĐOẠN 2: QUẢN LÝ TRẠNG THÁI (STATE MANAGEMENT - BLOC)

#### 2.1. Các file tạo mới:
1. `lib/features/parent/bloc/home/parent_home_event.dart`
   - `ParentHomeStarted`: Khởi tạo tải dữ liệu lần đầu.
   - `ParentHomeChildSelected(String? childId)`: Khi phụ huynh bấm đổi chip con (hoặc chọn "Tất cả các con" với `childId = null`).
   - `ParentHomeRefreshed`: Kéo xuống để refresh (`RefreshIndicator`).
2. `lib/features/parent/bloc/home/parent_home_state.dart`
   - `ParentHomeInitial`
   - `ParentHomeLoading`
   - `ParentHomeSuccess(ParentHomeData data, String? selectedChildId)`
   - `ParentHomeFailure(String message)`
3. `lib/features/parent/bloc/home/parent_home_bloc.dart`
   - Nhận `ParentHomeRepository`, xử lý chuyển đổi dữ liệu khi chọn con, emit state mượt mà.

#### 2.2. Kết quả cần đạt sau Giai đoạn 2:
- Unit test hoặc test logic BLoC hoạt động chính xác: khi bấm chọn con khác thì state cập nhật lại đúng `selectedChildId` và danh sách tương ứng.

---

### GIAI ĐOẠN 3: XÂY DỰNG CÁC WIDGET THÀNH PHẦN (PRESENTATION - WIDGETS)

Tách nhỏ thành 5 widget độc lập trong thư mục `lib/features/parent/presentation/home/widgets/`:

#### 3.1. `parent_home_header.dart`
- **Chi tiết giao diện:**
  - Icon tròn gia đình bên trái (nền xanh pastel `#EBF3FF`, icon xanh `#2563EB`).
  - Text: `PHỤ HUYNH 40STUDY` (caps, grey `#6B7280`) + `Chào buổi sáng, Gia đình!` (bold, `#111827`).
  - Phải: Nút chuông thông báo có chấm đỏ (`Badge`) + CircleAvatar phụ huynh (`PH`).
- **Tương tác:** Bấm chuông mở màn hình Thông báo, bấm avatar mở tab Hồ sơ.

#### 3.2. `family_scope_selector.dart`
- **Chi tiết giao diện:**
  - Dòng tiêu đề phụ: `• FAMILY SCOPE • CHẾ ĐỘ GIÁM SÁT` (xanh `#2563EB`) & `Cập nhật 2 phút trước`.
  - Hàng cuộn ngang (`ListView.separated`):
    - Chip "Tất cả các con": Nền đen `#0F172A`, icon nhóm màu trắng, text trắng.
    - Chip từng con: Nền `#F1F5F9`, avatar chữ cái (`M`, `L`), tên + lớp trong ngoặc đơn.
- **Tương tác:** Bấm chip kích hoạt event `ParentHomeChildSelected(childId)`.

#### 3.3. `action_required_section.dart`
- **Chi tiết giao diện:**
  - Header: Chấm đỏ + chữ `CẦN XỬ LÝ` + pill badge `2 nhắc nhở` (nền hồng đỏ `#FEE2E2`, chữ đỏ `#EF4444`).
  - Item 1: Icon cảnh báo bài tập, tên con `Minh • Hình học 10`, text `1 bài tập trắc nghiệm đã quá hạn nộp`, icon đồng hồ đỏ `Hạn chót: 23:59 hôm qua`, pill đỏ `Quá hạn` + chevron.
  - Item 2: Icon cập nhật lịch học, tên con `Lan • Anh văn giao tiếp`, text `Lớp đổi giờ bắt đầu sang 17:00 (lùi 30 phút)`, icon info vàng `Giáo viên vừa xác nhận`, pill vàng `Thay đổi` + chevron.

#### 3.4. `upcoming_schedule_section.dart`
- **Chi tiết giao diện:**
  - Header: Icon lịch xanh + chữ `HÔM NAY / TIẾP THEO` + text ngày `Thứ Sáu, 24 Th10`.
  - Item 1 (Online):
    - Cột giờ: `14:00` (xanh dương `#2563EB`, bold 20sp), tag `ONLINE`.
    - Thông tin: `Minh — Đại số 10`, subtitle xanh `Trực tuyến trên Google Meet`, giáo viên `Thầy Hoàng Long`.
    - Tag trạng thái: `Sắp bắt đầu` (nền xanh pastel).
  - Item 2 (Tại cơ sở):
    - Cột giờ: `16:30` (xám đen `#111827`, bold 20sp), tag `TẠI CƠ SỞ`.
    - Thông tin: `Lan — Tiếng Anh`, `Cơ sở Phan Xích Long`, `Phòng học 302`.
    - Tag trạng thái: `Trực tiếp` (nền xám nhạt).

#### 3.5. `learning_analytics_card.dart`
- **Chi tiết giao diện:**
  - Header: Icon trending + `PHÂN TÍCH HỌC TẬP` + chấm xanh lá `Tiến bộ tốt`.
  - Khung Card trắng viền bo tròn:
    - Hàng 1: Avatar tròn `M` + `Minh (Lớp 10A1)` + `Báo cáo tuần 4 • Môn Ngữ Văn` + badge xanh lá `+15%` kèm mũi tên lên.
    - Hàng 2: Điểm số `8.4` (font size ~38sp bold) + `/ 10 điểm TB tuần` + Biểu đồ 4 cột mini tăng dần màu xanh.
    - Hàng 3 (AI Insight Box): Hộp nền xanh tuyết `#F0F7FF`, viền trái xanh đậm 3.5px: *"Cải thiện rõ ở dạng **Đọc hiểu** so với 3 buổi gần đây. Tốc độ làm bài trắc nghiệm nhanh hơn 22%."*
    - Hàng 4: 2 nút điều hướng: `Xem phân tích của Minh ->` và `Tất cả báo cáo >`.

#### 3.6. `widgets.dart`
- File export toàn bộ các widget con ở trên để import gọn gàng.

#### 3.7. Kết quả cần đạt sau Giai đoạn 3:
- Từng widget được xây dựng độc lập, giao diện chuẩn từng màu sắc, font chữ, icon và khoảng cách (padding/margin) so với ảnh mẫu.

---

### GIAI ĐOẠN 4: GHÉP NỐI TOÀN DIỆN MÀN HÌNH HOME & SHELL

#### 4.1. Chỉnh sửa `lib/features/parent/presentation/home/parent_home_screen.dart`:
- Thay thế mã nguồn placeholder hiện tại ("Coming soon").
- Bọc bằng `BlocProvider` cung cấp `ParentHomeBloc` (khởi tạo với event `ParentHomeStarted`).
- Sử dụng `BlocBuilder<ParentHomeBloc, ParentHomeState>` để render:
  - Khi loading: Shimmer skeleton loading effect đẹp mắt.
  - Khi lỗi: Màn hình báo lỗi kèm nút "Thử lại".
  - Khi thành công: `RefreshIndicator` + `CustomScrollView` (hoặc `ListView`) cuộn mượt mà chứa 5 phần:
    1. `ParentHomeHeader`
    2. `FamilyScopeSelector`
    3. `ActionRequiredSection`
    4. `UpcomingScheduleSection`
    5. `LearningAnalyticsCard`

#### 4.2. Chỉnh sửa `lib/features/parent/presentation/parent_shell.dart`:
- Đồng bộ hóa 5 nhãn và icon trên thanh `NavigationBar` ở đáy màn hình theo đúng ảnh thiết kế:
  1. `Home` (`Icons.home_rounded` / `Icons.home_outlined`)
  2. `Lịch` (`Icons.calendar_today_rounded` / `Icons.calendar_today_outlined`)
  3. `Học tập` (`Icons.school_rounded` / `Icons.school_outlined`)
  4. `Học phí` (`Icons.credit_card_rounded` / `Icons.credit_card_outlined`)
  5. `Hồ sơ` (`Icons.person_rounded` / `Icons.person_outline`)

#### 4.3. Kết quả cần đạt sau Giai đoạn 4:
- Màn hình Home hiển thị đầy đủ trên ứng dụng khi đăng nhập bằng role Phụ huynh.
- Tương tác chuyển đổi giữa các con hoạt động trơn tru.

---

### GIAI ĐOẠN 5: KIỂM THỬ, PHÂN TÍCH & HOÀN THIỆN (TESTING & VERIFICATION)

#### 5.1. Các bước thực hiện:
1. Chạy `dart run build_runner build --delete-conflicting-outputs` để sinh code tự động cho các model mới.
2. Chạy `flutter analyze --no-pub` để bảo đảm **0 lỗi cú pháp / 0 lỗi biên dịch**.
3. Chạy `flutter run` trên Android Emulator, đăng nhập tài khoản phụ huynh `hoangtungaccphugpt1@gmail.com`.
4. Chụp ảnh màn hình thực tế từ máy ảo Android và so sánh song song với ảnh thiết kế `uploaded_media_1790066608691.png`.

---

## V. TỔNG KẾT DANH SÁCH FILE THAY ĐỔI

| STT | Đường dẫn File | Hành động | Mục đích |
| :---: | :--- | :---: | :--- |
| 1 | `lib/features/parent/data/models/family_scope_child.dart` | **Tạo mới** | Model cho chip chọn con |
| 2 | `lib/features/parent/data/models/parent_alert_item.dart` | **Tạo mới** | Model cho mục Cần xử lý |
| 3 | `lib/features/parent/data/models/parent_schedule_item.dart` | **Tạo mới** | Model cho mục Hôm nay/Tiếp theo |
| 4 | `lib/features/parent/data/models/parent_analytics_data.dart` | **Tạo mới** | Model cho mục Phân tích học tập |
| 5 | `lib/features/parent/data/models/parent_home_data.dart` | **Tạo mới** | Aggregate model chứa toàn bộ data Home |
| 6 | `lib/features/parent/data/parent_home_api_client.dart` | **Tạo mới** | API Client giao tiếp backend |
| 7 | `lib/features/parent/repository/parent_home_repository.dart` | **Tạo mới** | Interface Repository |
| 8 | `lib/features/parent/repository/parent_home_repository_impl.dart` | **Tạo mới** | Implementation kết hợp API thật + Smart fallback |
| 9 | `lib/di/di_repository_module.dart` | **Sửa** | Đăng ký DI cho ParentHomeRepository |
| 10 | `lib/features/parent/bloc/home/parent_home_event.dart` | **Tạo mới** | Events của Home BLoC |
| 11 | `lib/features/parent/bloc/home/parent_home_state.dart` | **Tạo mới** | States của Home BLoC |
| 12 | `lib/features/parent/bloc/home/parent_home_bloc.dart` | **Tạo mới** | BLoC điều khiển logic Home |
| 13 | `lib/features/parent/presentation/home/widgets/parent_home_header.dart` | **Tạo mới** | Widget Top App Bar |
| 14 | `lib/features/parent/presentation/home/widgets/family_scope_selector.dart` | **Tạo mới** | Widget Family Scope Chips |
| 15 | `lib/features/parent/presentation/home/widgets/action_required_section.dart` | **Tạo mới** | Widget Cần xử lý |
| 16 | `lib/features/parent/presentation/home/widgets/upcoming_schedule_section.dart` | **Tạo mới** | Widget Lịch học hôm nay |
| 17 | `lib/features/parent/presentation/home/widgets/learning_analytics_card.dart` | **Tạo mới** | Widget Phân tích học tập |
| 18 | `lib/features/parent/presentation/home/widgets/widgets.dart` | **Tạo mới** | Barrel export |
| 19 | `lib/features/parent/presentation/home/parent_home_screen.dart` | **Sửa** | Màn hình Home chính tích hợp 5 widget |
| 20 | `lib/features/parent/presentation/parent_shell.dart` | **Sửa** | Cập nhật nhãn & icon NavigationBar |
