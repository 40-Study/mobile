# Kế hoạch chi tiết: Xử lý Trạng thái Empty Data & Dữ liệu Thực tế trên Parent Home Screen

> **Dự án:** 40Study Mobile App  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu thiết kế tham chiếu:** `uploaded_media_0_1790070149272.png` (Trạng thái Empty Data "Cần xử lý") & `uploaded_media_1790066608691.png` (Trạng thái đầy đủ dữ liệu)  
> **Ngày tạo kế hoạch:** 22/09/2026  

---

## I. TỔNG QUAN VẤN ĐỀ & MỤC TIÊU

### 1. Hiện trạng hiện tại
- Màn hình Parent Home Screen sơ bộ đã được dựng xong với cấu trúc widget và BLoC.
- Tuy nhiên, trong `ParentHomeRepositoryImpl`, khi các API backend trả về danh sách rỗng (`[]`), repository đang tự động gán dữ liệu mẫu (`_fallbackAlerts()`, `_fallbackSchedules()`, `_fallbackAnalytics()`, `_fallbackChildren()`).
- Do đó, ứng dụng luôn hiển thị dữ liệu giả định (con Minh, Lan, bài tập Hình học quá hạn...) và **chưa bao giờ hiển thị trạng thái Empty Data thật sự** từ database backend.
- Mặt khác, trong `ActionRequiredSection`, khi danh sách rỗng thì widget đang bị ẩn hoàn toàn (`if (alerts.isNotEmpty)` trong screen), trong khi thiết kế yêu cầu hiển thị thẻ **"0 việc tồn đọng - Không có việc cần xử lý hôm nay - Tất cả ổn định"**.

### 2. Mục tiêu kế hoạch
1. **Chuẩn hóa trạng thái Empty Data (All-Clear State) của mục "Cần xử lý"** theo đúng 100% thiết kế tại ảnh `uploaded_media_0_1790070149272.png`.
2. **Xây dựng đồng bộ các trạng thái Empty Data cho các mục còn lại** (Lịch học hôm nay, Phân tích học tập, Family Scope khi chưa liên kết con) để ứng dụng không bị vỡ hoặc trống trơn khi học sinh chưa có lịch/chưa có bài thi.
3. **Loại bỏ việc ép buộc fake data trong Repository**, ưu tiên 100% dữ liệu thực tế từ Backend API, đồng thời cung cấp cơ chế chuyển đổi thông minh (Preview Toggle) khi cần demo.

---

## II. PHÂN TÍCH THIẾT KẾ TRẠNG THÁI EMPTY DATA

### 1. Mục "CẦN XỬ LÝ" (Action Required)

So sánh trực quan giữa 2 trạng thái:

| Đặc điểm | Trạng thái Có dữ liệu (`uploaded_media_1790066608691.png`) | Trạng thái Empty Data (`uploaded_media_0_1790070149272.png`) |
| :--- | :--- | :--- |
| **Dấu chấm trạng thái** | Tròn đỏ `#EF4444` | Tròn xanh lá `#10B981` (Emerald) |
| **Tiêu đề** | `CẦN XỬ LÝ` | `CẦN XỬ LÝ` |
| **Pill Badge bên phải** | Nền đỏ `#FEE2E2`, chữ đỏ `#EF4444`: `2 nhắc nhở` | Nền xanh lá nhạt `#ECFDF5`, chữ xanh lá `#059669`: `0 việc tồn đọng` |
| **Khung Card** | Viền xám mờ `#E2E8F0`, chứa danh sách các item cảnh báo | Viền xanh bạc hà nhạt `#A7F3D0`, nền trắng `#FFFFFF` |
| **Icon bên trái** | Từng icon cảnh báo bài tập trễ / đổi lịch | Ô vuông bo góc `12px`, nền `#ECFDF5`, icon khiên check xanh `#10B981` (`Icons.verified_user_outlined` / `Icons.gpp_good_outlined`) |
| **Tiêu đề chính** | Tên con • Tên môn | **Không có việc cần xử lý hôm nay** (Bold `#111827`, 15-16sp) |
| **Nội dung phụ** | Chi tiết hạn chót hoặc nội dung đổi lịch | **Không có bài tập quá hạn hay ca học bị thay đổi giờ của [Tên con]** (Màu `#6B7280`, 13sp) |
| **Trạng thái bên phải** | Tag `Quá hạn` / `Thay đổi` + mũi tên chevron | Text **Tất cả ổn định** (Xanh lá `#059669`, 13-14sp, bold 600) |

> 💡 **Quy tắc hiển thị tên con tự động (Dynamic Child Naming):**
> - Khi chọn **"Tất cả các con"**: Ghép tên danh sách con, ví dụ: `"của Minh & Lan"` hoặc `"của Tung Mai"`.
> - Khi chọn **một con cụ thể**: Hiển thị `"của [Tên con]"`, ví dụ: `"của Minh"`.
> - Khi phụ huynh chưa có con nào liên kết: Hiển thị `"của các con"`.

---

### 2. Mục "HÔM NAY / TIẾP THEO" (Upcoming Schedule) khi không có ca học

Khi API `GET /api/parent/children/:id/schedule` trả về `upcoming_sessions: []`:
- Header: Giữ nguyên Icon lịch + `HÔM NAY / TIẾP THEO` + Thứ, Ngày hiện tại.
- Card Empty State:
  - Khung viền bo tròn bo nhẹ (`#E2E8F0`), nền trắng hoặc `#F8FAFC`.
  - Icon: Icon lịch tích xanh hoặc icon thư giãn (`Icons.event_available_outlined` hoặc `Icons.calendar_today_outlined`).
  - Tiêu đề: **Hôm nay không có ca học nào** (Bold `#111827`, 15sp).
  - Nội dung phụ: "Con không có lịch học trực tuyến hoặc tại cơ sở hôm nay. Thời gian dành cho nghỉ ngơi hoặc tự ôn tập." (Slate 500, 13sp).
  - Nút liên kết: "Xem thời khóa biểu đầy đủ ->" (mở màn hình Lịch).

---

### 3. Mục "PHÂN TÍCH HỌC TẬP" (Learning Analytics) khi chưa có điểm/báo cáo

Khi API `GET /api/parent/children/:id/grades` trả về `final_grades: []` và chưa có điểm tuần:
- Header: Icon trending + `PHÂN TÍCH HỌC TẬP` + Pill xám `Chưa có báo cáo`.
- Card Empty State:
  - Khung card trắng, viền `#E2E8F0`.
  - Icon: Biểu đồ phân tích rỗng (`Icons.auto_graph_rounded` hoặc `Icons.analytics_outlined` màu xám nhạt).
  - Tiêu đề: **Chưa có dữ liệu phân tích tuần này**
  - Nội dung phụ: "Dữ liệu học tập, điểm số trung bình và nhận xét chi tiết sẽ tự động hiển thị sau khi con nộp bài tập và hoàn thành các bài kiểm tra đầu tiên."
  - Nút liên kết: "Xem bảng điểm các kỳ trước >" (chuyển sang tab Học tập).

---

### 4. Mục "FAMILY SCOPE" khi phụ huynh chưa liên kết tài khoản con

Khi API `GET /api/me/children` trả về `children: []`:
- Thanh Family Scope:
  - Hiển thị thông báo nhẹ: "Chưa có tài khoản con nào được liên kết với số điện thoại/email này."
  - Chip hoặc Nút bấm nổi bật: `+ Liên kết tài khoản con` (dẫn tới màn hình Quản lý con / Thêm con).

---

## III. CHIẾN LƯỢC KẾT NỐI API THẬT & GIẢI PHÁP THAY THẾ FAKE DATA

### 1. Hiện trạng trả về của Backend DB thật (Tài khoản `hoangtungaccphugpt1@gmail.com`)
- `GET /api/me/children` -> Trả về `1` con: `Tung Mai` (`id: 4020a672-ff7b-4029-8fe8-baad45aa7051`).
- `GET /api/parent/children/:id/assignments` -> Trả về `assignments: []`, `stats.overdue: 0`.
- `GET /api/parent/children/:id/schedule` -> Trả về `upcoming_sessions: []`.
- `GET /api/parent/children/:id/grades` -> Trả về `grades: []`, `final_grades: []`.

=> **Thực tế tài khoản test này đang nằm ở trạng thái EMPTY DATA ở toàn bộ các phần!**  
Vì vậy, việc loại bỏ fake fallback data trong Repository sẽ làm ứng dụng phản ánh chính xác 100% dữ liệu thật từ hệ thống backend.

### 2. Cơ chế Fallback / Preview Mode thông minh
- Thêm cờ `useMockFallback` (mặc định = `false`).
- Khi `useMockFallback = false`:
  - `alerts`: Trả về danh sách thật từ API (nếu rỗng -> trả về `[]`).
  - `schedules`: Trả về danh sách thật từ API (nếu rỗng -> trả về `[]`).
  - `analytics`: Trả về điểm thật từ API (nếu chưa có điểm -> trả về `null`).
  - `children`: Trả về danh sách con thật từ API.
- Khi `useMockFallback = true` (khi cần demo mockup giao diện đầy đủ):
  - Kích hoạt khi có tham số hoặc khi cần xem preview trong quá trình phát triển UI.

---

## IV. CÁC BƯỚC TRIỂN KHAI CHI TIẾT

### GIAI ĐOẠN 1: CẬP NHẬT TẦNG DỮ LIỆU & REPOSITORY (DATA & REPOSITORY LAYER)

#### 1.1. File `lib/features/parent/repository/parent_home_repository_impl.dart`:
- Sửa hàm `getHomeDashboard`:
  - Không ép `_fallbackAlerts()` khi `alerts.isEmpty`. Giữ nguyên `alerts: alerts` (danh sách rỗng).
  - Không ép `_fallbackSchedules()` khi `schedules.isEmpty`. Giữ nguyên `schedules: schedules` (danh sách rỗng).
  - Không ép `_fallbackAnalytics()` khi `analytics == null`. Giữ nguyên `analytics: analytics` (null).
  - Không ép `_fallbackChildren()` khi API trả về danh sách rỗng (trừ khi có lỗi mạng hoàn toàn).
- Thêm tham số hoặc property `bool enablePreviewFallback = false` để kiểm soát linh hoạt.

#### 1.2. Kết quả cần đạt:
- Repository trả về đúng đối tượng `ParentHomeData` với `alerts = []`, `schedules = []`, `analytics = null` khi backend chưa có dữ liệu nộp bài/lịch học.

---

### GIAI ĐOẠN 2: NÂNG CẤP WIDGET "CẦN XỬ LÝ" HỖ TRỢ EMPTY STATE

#### 2.1. File `lib/features/parent/presentation/home/widgets/action_required_section.dart`:
- Cập nhật hàm `build`:
  - Kiểm tra `final isEmpty = alerts.isEmpty;`
  - Nếu `isEmpty == false`:
    - Dấu chấm đỏ, pill `X nhắc nhở` (màu đỏ).
    - Render danh sách `_AlertItem`.
  - Nếu `isEmpty == true`:
    - **Header:**
      - Dấu chấm xanh lá `#10B981`.
      - Tiêu đề `CẦN XỬ LÝ`.
      - Pill bên phải: `0 việc tồn đọng` (nền `#ECFDF5`, chữ xanh lá đậm `#059669`, viền `#A7F3D0`).
    - **Body Card:**
      - Tạo widget con `_EmptyAlertCard(childrenNames: childrenNames)`.
      - Icon khiên tích xanh (`Icons.verified_user_outlined` / `Icons.shield_outlined`, màu `#10B981`, nền `#ECFDF5`).
      - Text: **Không có việc cần xử lý hôm nay** (Bold, 15sp).
      - Subtitle: `"Không có bài tập quá hạn hay ca học bị thay đổi giờ của $targetNames"` (Slate 500, 13sp).
      - Trạng thái: **Tất cả ổn định** (Màu `#059669`, bold 600, 13sp).
- Thêm tham số `final String? targetChildName;` hoặc danh sách con vào `ActionRequiredSection` để render câu giải thích linh hoạt theo ngữ cảnh chọn con.

#### 2.2. Kết quả cần đạt:
- Khi `alerts.isEmpty`, widget hiển thị giao diện xanh lá "0 việc tồn đọng" chuẩn xác từng pixel theo `uploaded_media_0_1790070149272.png`.

---

### GIAI ĐOẠN 3: NÂNG CẤP CÁC WIDGET CÒN LẠI VỚI EMPTY STATE

#### 3.1. File `lib/features/parent/presentation/home/widgets/upcoming_schedule_section.dart`:
- Thêm trạng thái rỗng `_EmptyScheduleCard`:
  - Khi `schedules.isEmpty`, thay vì ẩn đi hoặc lỗi, hiển thị card rỗng:
    - Icon calendar check (`Icons.event_available_outlined` màu xanh dương `#2563EB`).
    - Tiêu đề: **Hôm nay không có ca học nào**.
    - Phụ đề: "Con không có lịch học trực tuyến hoặc tại cơ sở hôm nay."
    - Nút bấm xem toàn bộ lịch tuần.

#### 3.2. File `lib/features/parent/presentation/home/widgets/learning_analytics_card.dart`:
- Cho phép `ParentAnalyticsData?` nhận giá trị nullable hoặc tạo `EmptyAnalyticsCard`:
  - Khi `analytics == null`:
    - Hiển thị card trạng thái chờ báo cáo tuần đầu tiên.
    - Icon biểu đồ rỗng (`Icons.auto_graph_outlined` màu xám).
    - Tiêu đề: **Chưa có báo cáo học tập tuần này**.
    - Phụ đề giải thích rõ ràng và nút điều hướng tới tab Học tập.

#### 3.3. File `lib/features/parent/presentation/home/parent_home_screen.dart`:
- Cập nhật `_HomeSuccess`:
  - Luôn luôn hiển thị `ActionRequiredSection(alerts: alerts, ...)` (không dùng điều kiện `if (alerts.isNotEmpty)` nữa, vì khi rỗng phải render Empty State).
  - Render `UpcomingScheduleSection(schedules: schedules)` (luôn hiển thị, kể cả rỗng).
  - Render `LearningAnalyticsCard(analytics: analytics)` (hỗ trợ hiển thị khi null).

---

### GIAI ĐOẠN 4: KIỂM THỬ THỰC TẾ TRÊN MÁY ẢO & ĐỐI SOÁT

#### 4.1. Các bước kiểm thử:
1. Chạy `flutter analyze --no-pub` đảm bảo **0 lỗi linter / 0 cảnh báo biên dịch**.
2. Chạy ứng dụng trên máy ảo Android (`emulator-5554`), đăng nhập tài khoản phụ huynh `hoangtungaccphugpt1@gmail.com`.
3. Kiểm tra hiển thị:
   - Chip con hiển thị đúng con thật trong database: `Tung Mai`.
   - Thẻ "CẦN XỬ LÝ" hiển thị đúng trạng thái xanh lá **"0 việc tồn đọng - Không có việc cần xử lý hôm nay - Tất cả ổn định"**.
   - Thẻ lịch học hiển thị thông báo hôm nay không có lịch một cách thân thiện.
   - Thẻ phân tích hiển thị trạng thái chờ dữ liệu.
4. Chụp ảnh màn hình máy ảo và đối chiếu với `uploaded_media_0_1790070149272.png`.

---

## V. BẢNG TỔNG KẾT CÁC FILE SẼ SỬA ĐỔI

| STT | File cần sửa đổi | Thay đổi chính |
| :---: | :--- | :--- |
| 1 | `lib/features/parent/repository/parent_home_repository_impl.dart` | Bỏ ép buộc dữ liệu fake khi danh sách rỗng; ưu tiên dữ liệu thật từ backend API. |
| 2 | `lib/features/parent/presentation/home/widgets/action_required_section.dart` | Thêm giao diện All-Clear Empty State: icon khiên xanh, pill 0 việc tồn đọng, text "Tất cả ổn định". |
| 3 | `lib/features/parent/presentation/home/widgets/upcoming_schedule_section.dart` | Thêm thẻ Empty State khi ngày hôm nay không có lịch học. |
| 4 | `lib/features/parent/presentation/home/widgets/learning_analytics_card.dart` | Thêm thẻ Empty State khi chưa có dữ liệu báo cáo/điểm số tuần. |
| 5 | `lib/features/parent/presentation/home/parent_home_screen.dart` | Bỏ điều kiện ẩn widget `if (alerts.isNotEmpty)` để luôn render section kèm empty state. |
| 6 | `lib/features/parent/presentation/home/widgets/family_scope_selector.dart` | Tối ưu hiển thị chip khi có 1 con hoặc nhiều con từ database thật. |
