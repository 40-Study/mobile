# KẾ HOẠCH NÂNG CẤP TOÀN DIỆN GIAO DIỆN TRANG CHỦ PHỤ HUYNH (PARENT HOME SCREEN) - V2.0

> **Dự án:** 40Study Mobile App  
> **Module:** Parent Experience (`mobile/lib/features/parent/`)  
> **Nhánh thực hiện:** `UI/Parent`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Đặc tả chi tiết vai trò Phụ huynh)  
> - 3 ảnh thiết kế mới nhất:  
>   + `uploaded_media_0` & `uploaded_media_1`: Home Dashboard trạng thái Có cảnh báo cần xử lý  
>   + `uploaded_media_2`: Home Dashboard chuẩn mực (Tách Section Header ra ngoài Card, Card ca học độc lập, Badge số lượng con, All-Clear Card)  
> - Chuẩn Design System Role Student (`mobile/lib/theme/*`, `features/student/*`)  
> **Ngày cập nhật:** 23/09/2026  
> **Phiên bản:** 2.0 (Tối ưu trải nghiệm phụ huynh, tách khối section, hỗ trợ collapse, màu sắc phân tầng, typography lớn thoáng)

---

## MỤC LỤC
1. [TỔNG HỢP YÊU CẦU NÂNG CẤP MỚI TỪ NGƯỜI DÙNG](#1-tổng-hợp-yêu-cầu-nâng-cấp-mới-từ-người-dùng)
2. [GAP ANALYSIS CHI TIẾT & ĐỐI CHIẾU ẢNH THIẾT KẾ MOCKUP 2](#2-gap-analysis-chi-tiết--đối-chiếu-ảnh-thiết-kế-mockup-2)
3. [NGUYÊN TẮC VÀNG: CAM KẾT 100% DYNAMIC DATA BINDING (NÓI KHÔNG VỚI HARDCODE)](#3-nguyên-tắc-vàng-cam-kết-100-dynamic-data-binding-nói-không-với-hardcode)
4. [NGUYÊN TẮC THIẾT KẾ CHO NGƯỜI LỚN TUỔI (PARENT-FRIENDLY UX)](#4-nguyên-tắc-thiết-kế-cho-người-lớn-tuổi-parent-friendly-ux)
5. [KIẾN TRÚC GIAO DIỆN & THÀNH PHẦN CHI TIẾT](#5-kiến-trúc-giao-diện--thành-phần-chi-tiết)
   - [5.1. Header: Dynamic Greeting & Real Profile Data](#51-header-dynamic-greeting--real-profile-data)
   - [5.2. Body: Phân tầng màu nền (Contrast Surface Layering)](#52-body-phân-tầng-màu-nền-contrast-surface-layering)
   - [5.3. Thanh chọn con: Điều kiện hiển thị & Badge số lượng](#53-thanh-chọn-con-điều-kiện-hiển-thị--badge-số-lượng)
   - [5.4. Cấu trúc Section Header Tách rời & Cơ chế Collapse](#54-cấu-trúc-section-header-tách-rời--cơ-chế-collapse)
   - [5.5. Section "Cần xử lý" (Action Required)](#55-section-cần-xử-lý-action-required)
   - [5.6. Section "Hôm nay / Tiếp theo" (Upcoming Schedule)](#56-section-hôm-nay--tiếp-theo-upcoming-schedule)
   - [5.7. Section "Phân tích học tập" (Learning Analytics)](#57-section-phân-tích-học-tập-learning-analytics)
6. [QUY CHUẨN DESIGN TOKENS (V2.0)](#6-quy-chuẩn-design-tokens-v20)
7. [KẾ HOẠCH TRIỂN KHAI THEO TỪNG BƯỚC (STEP-BY-STEP IMPLEMENTATION)](#7-kế-hoạch-triển-khai-theo-từng-bước)
8. [CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)](#8-checklist-nghiệm-thu)

---

## 1. TỔNG HỢP YÊU CẦU NÂNG CẤP MỚI TỪ NGƯỜI DÙNG

Dựa trên phản hồi trực tiếp và 3 ảnh thiết kế mới nhất của người dùng, các định hướng cải tiến trọng tâm bao gồm:

1. **Tổng thể thẩm mỹ & Khả năng tiếp cận (Accessibility):** Điều chỉnh khoảng cách thoáng đãng hơn, tăng kích cỡ font chữ rõ ràng, độ tương phản cao, vùng chạm tối thiểu 48px, tối ưu hoàn hảo cho mắt người lớn tuổi.
2. **Header thông minh (Dynamic Greeting):** Không dùng chuỗi cứng `"Chào buổi sáng, Gia đình!"`. Phải lấy data chuẩn theo thời gian thực (Sáng/Chiều/Tối) kết hợp tên thật của phụ huynh từ `AuthBloc` tương tự cách làm của Student UI.
3. **Thanh chọn hồ sơ con (Family Scope Selector):**
   - **Nếu chỉ có 1 con:** Ẩn hoàn toàn nút "Tất cả các con" (vì thừa thãi), chỉ hiển thị duy nhất chip của con đó.
   - **Nếu có từ 2 con trở lên:** Hiển thị nút "Tất cả các con" với **màu xanh thương hiệu hệ thống (`TogetherColorsX.blue600`)** khi được chọn, đồng thời **hiển thị số lượng con ngay trong nút** (ví dụ: `Tất cả các con  2`).
4. **Phân tầng màu nền (Surface Contrast):** Phần Header mang nền trắng sáng (`#FFFFFF`), trong khi toàn bộ Body bên dưới mang nền xám dịu nhẹ (`#F8FAFC` / `surfaceContainerLowest`) để làm nổi bật các Card trắng tinh khiết bên trong.
5. **Tách tiêu đề Section ra khỏi Card:** Tiêu đề của từng section (`CẦN XỬ LÝ`, `HÔM NAY / TIẾP THEO`, `PHÂN TÍCH HỌC TẬP`) nằm **hoàn toàn bên ngoài card**, không gộp chung vào một card lớn nguyên khối.
6. **Thẻ ca học độc lập (Independent Schedule Cards):** Mỗi ca học trong mục "Hôm nay / Tiếp theo" là một Card trắng độc lập, có khối thời gian bo góc riêng (`14:00 60p` màu xanh pastel cho Online; `16:30 90p` màu xám cho Offline), badge tên con (`[Minh]`, `[Lan]`) và thông tin địa điểm rõ ràng.
7. **Cơ chế Thu gọn / Mở rộng toàn diện (Collapsible Sections for All):** Tích hợp cơ chế thu gọn / mở rộng cho **tất cả các section** (`CẦN XỬ LÝ`, `HÔM NAY / TIẾP THEO`, `PHÂN TÍCH HỌC TẬP`). **QUY TẮC MẶC ĐỊNH: Luôn ở trạng thái MỞ TOÀN BỘ (`_isExpanded = true`)** khi phụ huynh truy cập ứng dụng để nắm bắt ngay mọi thông tin trọng yếu mà không bị gián đoạn; phụ huynh có thể chủ động chạm vào header để thu gọn bất kỳ section nào theo ý muốn.

---

## 2. GAP ANALYSIS CHI TIẾT & ĐỐI CHIẾU ẢNH THIẾT KẾ MOCKUP 2

| Thành phần UI | Code hiện tại | Ảnh thiết kế thực tế (`uploaded_media_2`) | Giải pháp kỹ thuật cần điều chỉnh |
| :--- | :--- | :--- | :--- |
| **Màu nền toàn trang (Background)** | Cả Header và Body đều dùng chung 1 màu nền `Theme.of(context).colorScheme.surface` phẳng lì. | Header nền trắng tinh (`#FFFFFF`), Body bên dưới nền xám dịu (`#F8FAFC` / `slate50`), các Card nội dung màu trắng nổi bật với viền mảnh và shadow mềm. | Thiết lập `Scaffold.backgroundColor = cs.slate50`; bọc Header trong Container màu trắng hoặc `AppBar` surface riêng; Body cuộn trên nền `slate50`. |
| **Header Greeting** | Hardcode text `'Chào buổi sáng, Gia đình!'`. | Lấy dữ liệu thật: Lời chào tự động theo giờ hệ thống + Tên thật của phụ huynh. | Sử dụng hàm `_greeting()`: <br>- Trước 11h: *"Chào buổi sáng"*<br>- 11h - 18h: *"Chào buổi chiều"*<br>- Sau 18h: *"Chào buổi tối"*<br>Kết hợp `user.fullName` từ `AuthBloc`. |
| **Nút "Tất cả các con"** | Luôn hiển thị dù có 1 con hay nhiều con; Nút mang màu đen `slate900` đơn điệu; Không hiển thị số lượng con. | - Khi chỉ có 1 con: Ẩn nút "Tất cả các con".<br>- Khi ≥ 2 con: Nút màu xanh thương hiệu (`blue600`), có pill badge nhỏ hiển thị số lượng con (ví dụ: `Tất cả các con  2`). | Kiểm tra `children.length > 1` mới render nút Tất cả các con; Thiết kế chip xanh `blue600` với badge tròn hiển thị `children.length`. |
| **Tiêu đề Section CẦN XỬ LÝ** | Đang bị nhét bên trong Card trắng lớn cùng với nội dung item. | Nằm **BÊN NGOÀI CARD**: Gồm chấm trạng thái tròn, Text `CẦN XỬ LÝ` và Pill badge (`2 nhắc nhở` / `0 việc tồn đọng`) cùng hàng với icon thu gọn. | Bóc tách hàng tiêu đề ra khỏi Card; Card chỉ bọc phần nội dung cảnh báo; Thêm State `isExpanded` để collapse. |
| **Tiêu đề Section LỊCH HỌC** | Đang bị nhét bên trong Card trắng lớn. | Nằm **BÊN NGOÀI CARD**: Icon lịch xanh + Text `HÔM NAY / TIẾP THEO` + Thứ, Ngày tháng + Nút collapse. | Đưa Header ra ngoài; Bên dưới render danh sách các Card độc lập. |
| **Thẻ Ca học Lịch trình** | Dùng vạch kẻ `VerticalDivider` trong cùng 1 card lớn; không hiển thị thời lượng (60p, 90p) hay tag con riêng biệt. | **Mỗi ca học là 1 CARD TRẮNG ĐỘC LẬP**:<br>- Khối giờ có nền riêng (xanh pastel cho Online; xám cho Offline) hiển thị giờ + thời lượng (`60p`, `90p`).<br>- Có badge con riêng (`Minh`, `Lan`).<br>- Badge trạng thái bên phải (`Sắp bắt đầu`, `Trực tiếp`). | Tách mỗi `ParentScheduleItem` thành 1 Container card riêng biệt có bo góc `AppRadius.borderLg`, viền mỏng và shadow nhẹ. |
| **Tiêu đề Section PHÂN TÍCH** | Đang bị gộp tiêu đề vào chung 1 khối. | Tiêu đề nằm **BÊN NGOÀI CARD**: Icon xu hướng + `PHÂN TÍCH HỌC TẬP` + Badge `Tiến bộ tốt` + Nút collapse. | Tách hàng tiêu đề ra ngoài card; Card chỉ chứa thông tin học tập, điểm TB 8.4, box nhận xét AI và navigation links. |
| **Typography & Spacing** | Font chữ còn nhỏ (11-13sp), khoảng cách chật chội, khó đọc với mắt người lớn tuổi. | Font chữ lớn, nét chữ đậm rõ, line-height 1.5, khoảng cách giữa các phần rộng rãi (16-20px). | Nâng cỡ chữ cơ sở lên tối thiểu 13-16sp, tiêu đề 16-18sp, thời gian 19-20sp bold; Tăng khoảng cách `vGap20`. |

---

## 3. NGUYÊN TẮC VÀNG: CAM KẾT 100% DYNAMIC DATA BINDING (NÓI KHÔNG VỚI HARDCODE)

Để đảm bảo toàn bộ giao diện và hiệu ứng tương tác vận hành chính xác, mượt mà khi kết nối cơ sở dữ liệu thật từ Backend API (không bị phụ thuộc vào dữ liệu giả định):

### 3.1. Bản đồ Ràng buộc Dữ liệu Động (Dynamic Data Binding Matrix)

| Thành phần UI | Nguồn dữ liệu thật (Backend API & Runtime) | Biểu thức Logic Data Binding | Trạng thái Fallback / Rỗng |
| :--- | :--- | :--- | :--- |
| **Lời chào Header** | `DateTime.now().hour` | Giờ < 11: `"Chào buổi sáng"`<br>Giờ < 18: `"Chào buổi chiều"`<br>Giờ ≥ 18: `"Chào buổi tối"` | Luôn tính theo đồng hồ thiết bị thật |
| **Tên phụ huynh** | `AuthBloc -> state.user.fullName` | `user?.fullName ?? user?.username ?? 'Gia đình!'` | Tự động cập nhật khi đổi tài khoản |
| **Chuông thông báo** | Unread notifications count | Hiển thị badge đỏ khi `unreadCount > 0` | Ẩn badge đỏ khi `unreadCount == 0` |
| **Thanh chọn con** | `GET /api/me/children` | - `children.length <= 1`: Ẩn nút "Tất cả các con"<br>- `children.length > 1`: Hiện nút xanh `Tất cả các con` kèm badge `${children.length}` | Khi `children.isEmpty`: Chuyển sang No-Child View |
| **Lọc theo con** | Event `ParentHomeChildSelected(id)` | Khi chọn con: Gọi API theo `child.id` thật từ DB; UI lọc danh sách cảnh báo, lịch học, điểm số của con đó | Khi `childId == null`: Xem tổng hợp cả gia đình |
| **Section Cần xử lý** | `GET /api/parent/children/:id/assignments` | Danh sách `ParentAlertItem` được parse từ các bài tập có `status == 'overdue'` và thông báo đổi lịch thật | Khi rỗng: Thẻ All-Clear `"0 việc tồn đọng - Tất cả ổn định"` ghép tên con thật |
| **Ngày tháng Lịch học** | `DateTime.now()` | Format động bằng tiếng Việt: `Thứ [2-CN], [Ngày] Th[Tháng]` (ví dụ: `Thứ Tư, 23 Th9`), **tuyệt đối không fix cứng ngày** | Luôn chuẩn xác theo ngày thực tế |
| **Thẻ Ca học hôm nay** | `GET /api/parent/children/:id/schedule` | Parse từ `upcoming_sessions`: Giờ bắt đầu (`startTime`), Thời lượng (`${durationMinutes}p`), Tên môn, Link Google Meet/Zoom hoặc Phòng học offline | Khi rỗng: Thẻ `"Hôm nay không có ca học nào"` |
| **Section Phân tích** | `GET /api/parent/children/:id/grades` | - Điểm TB tuần: `averageScore.toStringAsFixed(1)`<br>- Tiến độ: `+${progressPercent}%`<br>- Cột biểu đồ: Lặp qua mảng điểm thật `weeklyTrend` để vẽ chiều cao động | Khi null: Thẻ `"Chưa có dữ liệu phân tích tuần này"` |
| **Hiệu ứng Collapse (Tất cả Section)** | Local Widget State (`bool _isExpanded = true;`) | Quản lý độc lập bằng `StatefulWidget` + `AnimatedCrossFade`, **MẶC ĐỊNH LUÔN MỞ TOÀN BỘ** khi khởi tạo. Hoạt động mượt mà với dữ liệu thật | Cho phép bấm Header để toggle đóng/mở độc lập từng section |

### 3.2. Đảm bảo tính thích ứng (Graceful Degradation)
- **Khi Backend trả về dữ liệu thật:** UI tự động tiêu thụ 100% dữ liệu từ models mà không cần sửa bất kỳ dòng code giao diện nào.
- **Khi Backend tạm thời chưa có dữ liệu nộp bài:** Hệ thống hiển thị các Card Empty State tinh xảo (All-Clear, Không có lịch học, Chưa có báo cáo), tuyệt đối không bị vỡ layout hay lỗi null exception.

---

## 4. NGUYÊN TẮC THIẾT KẾ CHO NGƯỜI LỚN TUỔI (PARENT-FRIENDLY UX)

Để phụ huynh (độ tuổi 35 - 55+) sử dụng ứng dụng một cách dễ chịu, thoải mái và không mỏi mắt, giao diện phải tuân thủ 4 nguyên lý:

1. **High Visual Scannability (Dễ quét thông tin):**
   - Tiêu đề từng khu vực phải nổi bật bên ngoài, có icon nhận diện và màu sắc ngữ nghĩa rõ ràng (Đỏ = Cần xử lý gấp, Xanh dương = Lịch trình sắp tới, Xanh lá = Tiến bộ học tập).
   - Người lớn tuổi chỉ cần nhìn lướt qua trong 3 giây là biết con có bài tập trễ không, mấy giờ học và tuần này học tốt không.
2. **Generous Spacing & Visual Breathing (Khoảng thở thị giác):**
   - Khoảng cách giữa các Section là `AppSpacing.vGap20` (20px).
   - Khoảng cách giữa các Card ca học là `AppSpacing.vGap12` (12px).
   - Padding bên trong Card là `AppSpacing.lg` (16px), tạo cảm giác nhẹ nhàng, không bị ngộp thông tin.
3. **Enhanced Typography (Chữ to, Nét đậm, Rõ ràng):**
   - Cấm dùng text dưới 12sp.
   - Text phụ (mô tả, địa điểm): Tối thiểu 13sp, màu `cs.slate600` (đủ tương phản, không dùng màu xám quá nhạt).
   - Text chính (tên bài, tên môn, tên con): 15-16sp, font weight 700.
   - Giờ học & Điểm số: 18-20sp font weight 800.
4. **Touch Target Accessibility (Dễ bấm, Không chạm nhầm):**
   - Chiều cao các nút CTA, Chip và Item bấm được phải đạt chuẩn **tối thiểu 44 - 48px**.
   - Thêm hiệu ứng gợn sóng (`InkWell`) và bo góc mềm mại.

---

## 5. KIẾN TRÚC GIAO DIỆN & THÀNH PHẦN CHI TIẾT

### 5.1. Header: Dynamic Greeting & Real Profile Data
- **Vị trí:** Đặt ở đỉnh màn hình, nằm trên nền trắng sáng (`#FFFFFF`) hoặc `surface`.
- **Thành phần:**
  - Bên trái:
    + Icon gia đình xanh pastel (`#EFF6FF`, icon `Icons.family_restroom_rounded` màu `blue600`, size 44x44px).
    + Dòng 1 (Eyebrow): `PHỤ HUYNH 40STUDY` (caps, `slate500`, tracking 1.1, bold 700, 11sp).
    + Dòng 2 (Tiêu đề chính): Lời chào động:
      ```dart
      String getDynamicGreeting(String? fullName) {
        final hour = DateTime.now().hour;
        String timeGreeting;
        if (hour < 11) {
          timeGreeting = 'Chào buổi sáng';
        } else if (hour < 18) {
          timeGreeting = 'Chào buổi chiều';
        } else {
          timeGreeting = 'Chào buổi tối';
        }
        
        if (fullName == null || fullName.trim().isEmpty) {
          return '$timeGreeting, Gia đình!';
        }
        // Lấy tên gọi thân mật (ví dụ "Hoàng Tùng" -> "Hoàng Tùng" hoặc tên cuối)
        final name = fullName.trim();
        return '$timeGreeting, $name!';
      }
      ```
  - Bên phải:
    + Chuông thông báo có chấm đỏ (`Badge` 7px màu đỏ, icon `Icons.notifications_outlined`).
    + Avatar phụ huynh: Chữ cái viết tắt từ tên phụ huynh (ví dụ `HT` hoặc `PH`), nền xanh nhạt hoặc `slate900`, radius 20px.

---

### 5.2. Body: Phân tầng màu nền (Contrast Surface Layering)
- **Cấu trúc Scaffold:**
  ```dart
  Scaffold(
    backgroundColor: const Color(0xFFF8FAFC), // cs.slate50
    body: SafeArea(
      child: Column(
        children: [
          // Header nằm trên nền trắng tinh khiết
          Container(
            color: cs.surface, // #FFFFFF
            child: ParentHomeHeader(...),
          ),
          // Toàn bộ Body cuộn trên nền xám dịu slate50
          Expanded(
            child: ListView(...),
          ),
        ],
      ),
    ),
  );
  ```
- **Tác dụng:** Giúp người xem phân biệt rạch ròi giữa khu vực Điều hướng (Header) và khu vực Dữ liệu (Dashboard Cards). Các Card trắng nổi lên trên nền xám nhẹ tạo độ sâu phân tầng tuyệt đẹp.

---

### 5.3. Thanh chọn con: Điều kiện hiển thị & Badge số lượng
- **Dòng tiêu đề phụ:** `• FAMILY SCOPE • CHẾ ĐỘ GIÁM SÁT` (`blue600`, 11sp, bold 700, tracking 1.0) và `Cập nhật 2 phút trước` (`slate400`, 11sp).
- **Quy tắc hiển thị Chip:**
  ```dart
  final isMultiChildren = children.length > 1;
  ```
  - **Trường hợp 1 con (`children.length == 1`):**
    + **ẨN NÚT "TẤT CẢ CÁC CON"**.
    + Chỉ hiển thị duy nhất 1 Chip của con đó (tự động kích hoạt trạng thái selected).
  - **Trường hợp nhiều con (`children.length > 1`):**
    + **Nút "Tất cả các con":**
      - Khi Selected: Nền màu **xanh hệ thống (`cs.blue600` / `#2563EB`)**, icon nhóm màu trắng, text trắng bold 700.
      - Bên cạnh chữ có **Pill Badge tròn nhỏ** (nền trắng hoặc xanh đậm hơn) hiển thị số lượng: `${children.length}` (ví dụ: `2`).
      - Khi Unselected: Nền xám nhạt `slate100`, viền mỏng `slate200`, text `slate700`, badge số xám.
    + **Các Chip từng con bên cạnh:**
      - Avatar chữ cái tròn (`M` xanh, `L` hồng/cam).
      - Text: `${child.name} (${child.className})` (ví dụ `Minh (10A1)`, `Lan (7B)`).
      - Khi Selected: Nền trắng/xanh nhạt, viền xanh `blue600` dày 1.5px, chữ `blue700` bold.
      - Khi Unselected: Nền `slate100`, viền transparent, chữ `slate700`.

---

### 5.4. Cấu trúc Section Header Tách rời & Cơ chế Collapse Toàn diện

Mỗi Section (`ActionRequiredSection`, `UpcomingScheduleSection`, `LearningAnalyticsCard`) sẽ tuân thủ mô hình widget chuẩn:
```
SectionContainer (StatefulWidget)
├── SectionHeaderBar (NẰM HOÀN TOÀN BÊN NGOÀI CARD - Bấm vào để Toggle)
│   ├── Trái: Chấm trạng thái / Icon + Tiêu đề section (caps, bold 700, 14.5sp)
│   ├── Giữa: Badge trạng thái (Số việc, Ngày tháng, Đánh giá tiến bộ)
│   └── Phải: Icon Chevron xoay mượt mà (AnimatedRotation)
│
└── AnimatedCrossFade (CƠ CHẾ THU GỌN / MỞ RỘNG MƯỢT MÀ)
    ├── State MỞ (_isExpanded == true): HIỂN THỊ MẶC ĐỊNH TOÀN BỘ CARD NỘI DUNG
    └── State ĐÓNG (_isExpanded == false): Thu gọn hoàn toàn (SizedBox.shrink), chỉ giữ thanh Header bar tóm tắt
```

**Quy tắc vận hành Collapse:**
1. **Trạng thái khởi tạo mặc định:** `bool _isExpanded = true;` cho **TẤT CẢ** các section. Phụ huynh khi vào ứng dụng sẽ nhìn thấy đầy đủ 100% nội dung ngay lập tức mà không cần bấm thêm thao tác nào.
2. **Tương tác chạm:** Phụ huynh có thể bấm vào bất kỳ vị trí nào trên thanh tiêu đề `SectionHeaderBar` hoặc bấm nút mũi tên chevron để thu gọn / mở rộng.
3. **Hiệu ứng chuyển cảnh:**
   - Dùng `AnimatedCrossFade(duration: const Duration(milliseconds: 250), crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond)`.
   - Nút mũi tên dùng `AnimatedRotation(turns: _isExpanded ? 0 : 0.5, duration: const Duration(milliseconds: 250))` trỏ lên/xuống nhịp nhàng.

---

### 5.5. Section "Cần xử lý" (Action Required)
- **Header ngoài card:**
  + Chấm tròn trạng thái: Đỏ (nếu có việc) hoặc Xanh lá (nếu All-Clear).
  + Text: `CẦN XỬ LÝ` (bold 700, 14.5sp, `slate900`).
  + Badge bên phải: `2 nhắc nhở` (nền đỏ nhạt, chữ đỏ) hoặc `0 việc tồn đọng` (nền xanh lá nhạt, chữ xanh lá).
  + Nút mũi tên thu gọn/mở rộng (Mặc định: MỞ TOÀN BỘ với `_isExpanded = true`, bấm vào header hoặc chevron để toggle).
- **Card nội dung bên dưới:**
  - **Khi All-Clear (0 việc tồn đọng):**
    + 1 Card trắng viền xanh mint nhạt (`#A7F3D0`), bo góc 16px.
    + Icon khiên tích xanh bo góc 12px, nền `#ECFDF5`.
    + Tiêu đề: **"Không có việc cần xử lý hôm nay"** (bold, 15sp, `slate900`).
    + Mô tả: *"Không có bài tập quá hạn hay ca học bị thay đổi giờ của [Tên con]"* (`slate500`, 13sp).
    + Text: **"Tất cả ổn định"** (`#059669`, bold 600, 13sp).
  - **Khi có việc tồn đọng (Active Alerts):**
    + 1 Card trắng bo góc 16px, viền `outlineVariant.withValues(alpha: 0.4)`.
    + Danh sách các Item cảnh báo:
      - Item 1: Icon bài tập đỏ, `Minh • Hình học 10`, `1 bài tập trắc nghiệm đã quá hạn nộp`, `Hạn chót: 23:59 hôm qua`, Badge đỏ `Quá hạn` + Chevron phải.
      - Item 2: Icon đồng hồ cam, `Lan • Anh văn giao tiếp`, `Lớp đổi giờ bắt đầu sang 17:00 (lùi 30 phút)`, `Giáo viên vừa xác nhận`, Badge cam `Thay đổi` + Chevron phải.

---

### 5.6. Section "Hôm nay / Tiếp theo" (Upcoming Schedule)
- **Header ngoài card:**
  + Icon lịch xanh `Icons.calendar_today_rounded` (size 19px, màu `blue600`).
  + Text: `HÔM NAY / TIẾP THEO` (bold 700, 14.5sp, `slate900`).
  + Phía bên phải: `Thứ Sáu, 24 Th10` (`slate500`, 13sp) + Nút mũi tên collapse (Mặc định: MỞ TOÀN BỘ với `_isExpanded = true`).
- **Nội dung bên dưới (CÁC THẺ CARD ĐỘC LẬP THEO ẢNH 2):**
  - **Card Ca học 1 (Online):**
    + Thẻ trắng độc lập, bo góc 16px, viền mỏng, padding 14px.
    + Khối giờ bên trái (SizedBox 64x54px): Nền xanh pastel `#EFF6FF`, bo góc 10px:
      - Dòng 1: `14:00` (bold 800, `blue600`, 16.5sp).
      - Dòng 2: `60p` (`blue600`, bold 600, 12sp).
    + Ở giữa:
      - Hàng 1: Badge con `[Minh]` (nền `#DBEAFE`, chữ `blue700`, bold 700, 11sp) + Tên môn `Đại số 10` (bold 700, `slate900`, 15sp).
      - Hàng 2: Icon camera video + `Trực tuyến Google Meet · Thầy Hoàng Long` (`slate600`, 13sp).
    + Phía bên phải: Badge `Sắp bắt đầu` (nền `#EFF6FF`, chữ `blue600`, bo góc full pill).
  - **Card Ca học 2 (Tại cơ sở):**
    + Thẻ trắng độc lập, bo góc 16px, viền mỏng, padding 14px.
    + Khối giờ bên trái (SizedBox 64x54px): Nền xám `#F1F5F9`, bo góc 10px:
      - Dòng 1: `16:30` (bold 800, `slate900`, 16.5sp).
      - Dòng 2: `90p` (`slate500`, bold 600, 12sp).
    + Ở giữa:
      - Hàng 1: Badge con `[Lan]` (nền `#FEF3C7`, chữ `#D97706`, bold 700, 11sp) + Tên môn `Tiếng Anh` (bold 700, `slate900`, 15sp).
      - Hàng 2: Icon tòa nhà + `Cơ sở Phan Xích Long · Phòng 302` (`slate600`, 13sp).
    + Phía bên phải: Badge `Trực tiếp` (nền `#F1F5F9`, chữ `slate700`, bo góc full pill).

---

### 5.7. Section "Phân tích học tập" (Learning Analytics)
- **Header ngoài card:**
  + Icon xu hướng `Icons.insights_rounded` (màu `blue600`).
  + Text: `PHÂN TÍCH HỌC TẬP` (bold 700, 14.5sp, `slate900`).
  + Phía bên phải: Chấm xanh lá + Text `Tiến bộ tốt` (nền xanh lá nhạt, chữ xanh) + Nút collapse (Mặc định: MỞ TOÀN BỘ với `_isExpanded = true`).
- **Card nội dung bên dưới (Theo ảnh 2):**
  + Card trắng bo góc 16px, viền mỏng, padding 16px.
  + **Hàng 1 (Thông tin học sinh & Điểm số):**
    - Trái: Avatar tròn chữ `M` xanh dương (radius 18px), Tên `Minh · Lớp 10A1` (bold 700, 15sp), dưới là `Báo cáo tuần 42` (`slate500`, 13sp).
    - Phải: Text `Điểm TB: 8.4` (bold 800, 16sp, `slate900`), dưới là `(+15%)` màu xanh lá bold 700.
  + **Hàng 2 (AI Insight Box):**
    - Container nền xám nhạt `#F8FAFC`, bo góc 12px, padding 14px, viền mỏng `slate200`:
      "Minh duy trì mức độ hiểu bài tốt trong tuần qua, tiến độ đọc hiểu cải thiện **22%** ở môn Toán và Ngữ văn."
      (Từ khóa **22%** in đậm nổi bật).
  + **Hàng 3 (Action Navigation Links):**
    - Trái: `Xem phân tích của Minh ->` (`blue600`, bold 600, 13.5sp).
    - Phải: `Tất cả báo cáo >` (`slate500`, 13sp).

---

## 6. QUY CHUẨN DESIGN TOKENS (V2.0)

```dart
// Backgrounds & Surface Hierarchy
final bgScreen       = const Color(0xFFF8FAFC); // cs.slate50 (Toàn bộ body cuộn)
final bgHeader       = cs.surface;              // #FFFFFF (Header trắng sáng)
final bgCard         = cs.surface;              // #FFFFFF (Các thẻ Card)
final cardBorder     = cs.outlineVariant.withValues(alpha: 0.35);

// Primary Brand Blues
final brandBlue      = cs.blue600;              // #2563EB (Nút chọn tất cả con, link chính)
final brandBluePastel= const Color(0xFFEFF6FF); // Nền khối giờ Online, avatar header
final brandDarkBlue  = cs.blue700;              // #1D4ED8 (Text active)

// Status & Semantic Colors
final redAlert       = AchievementColors.red;   // #EF4444
final redAlertBg     = const Color(0xFFFEE2E2);
final amberChange    = const Color(0xFFD97706);
final amberChangeBg  = const Color(0xFFFEF3C7);
final greenSuccess   = AchievementColors.green; // #10B981
final greenSuccessBg = const Color(0xFFECFDF5);
final greenMintBorder= const Color(0xFFA7F3D0);

// Elderly-Friendly Typography Scale
final styleEyebrow   = tt.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0);
final styleSectionHdr= tt.titleSmall?.copyWith(fontSize: 14.5, fontWeight: FontWeight.w700, color: cs.slate900);
final styleCardTitle = tt.titleMedium?.copyWith(fontSize: 15.5, fontWeight: FontWeight.w700, color: cs.slate900);
final styleBodyDesc  = tt.bodySmall?.copyWith(fontSize: 13.5, height: 1.45, color: cs.slate600);
final styleMetaTime  = tt.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w800);
```

---

## 7. KẾ HOẠCH TRIỂN KHAI THEO TỪNG BƯỚC (STEP-BY-STEP IMPLEMENTATION)

> ⚠️ **Quy tắc:** Chỉ code khi có lệnh yêu cầu. Sau mỗi bước chuyển đổi hoàn thành, thực hiện commit ngắn gọn và chạy `dart analyze`.

### Bước 1: Nâng cấp Header với Dynamic Greeting & Auth Data
- **File:** `mobile/lib/features/parent/presentation/home/widgets/parent_home_header.dart`
- **Nội dung:**
  + Tạo hàm `_getDynamicGreeting(DateTime.now().hour, user?.fullName)`.
  + Phân biệt buổi: Sáng (< 11h), Chiều (< 18h), Tối (>= 18h).
  + Lấy tên thật của phụ huynh từ `AuthBloc`, nếu chưa có fallback `"Gia đình!"`.
  + Đảm bảo nền Header màu trắng tinh (`#FFFFFF`), tách biệt với nền body xám.
- **Commit:** `feat(parent): add dynamic greeting and auth profile to header`

### Bước 2: Nâng cấp Thanh chọn con (Family Scope Selector)
- **File:** `mobile/lib/features/parent/presentation/home/widgets/family_scope_selector.dart`
- **Nội dung:**
  + Kiểm tra điều kiện: Nếu `children.length <= 1`, **ẩn nút "Tất cả các con"**, chỉ hiện duy nhất chip con đó.
  + Nếu `children.length > 1`: Hiển thị nút "Tất cả các con" với màu xanh hệ thống (`blue600`) khi selected, kèm Pill badge tròn nhỏ hiển thị số lượng con `${children.length}`.
  + Nâng cỡ chữ tên con lên 14sp, avatar 14px, chiều cao chip 44px dễ bấm cho người lớn tuổi.
- **Commit:** `feat(parent): support single-child hide and brand blue all-children button with count badge`

### Bước 3: Tách Tiêu đề Section & Thêm Cơ chế Collapse cho "Cần xử lý"
- **File:** `mobile/lib/features/parent/presentation/home/widgets/action_required_section.dart`
- **Nội dung:**
  + Tách hàng tiêu đề `• CẦN XỬ LÝ` + Badge (`2 nhắc nhở` / `0 việc tồn đọng`) ra ngoài Card.
  + Thêm icon chevron xoay (animated rotation) và state `bool _isExpanded = true` (mặc định mở toàn bộ) để thu gọn / mở rộng.
  + Card bên dưới bọc trong `AnimatedCrossFade`.
  + Khi All-Clear: Card trắng viền xanh mint mint border `#A7F3D0`, không có tiêu đề trùng lặp bên trong.
- **Commit:** `refactor(parent): extract action required header outside card and add collapse toggle`

### Bước 4: Tách Tiêu đề Section & Tách Thẻ Ca học Độc lập cho "Lịch học hôm nay"
- **File:** `mobile/lib/features/parent/presentation/home/widgets/upcoming_schedule_section.dart`
- **Nội dung:**
  + Tách hàng tiêu đề `📅 HÔM NAY / TIẾP THEO` + `Thứ Sáu, 24 Th10` ra ngoài Card kèm nút thu gọn / mở rộng (state `bool _isExpanded = true`, mặc định mở toàn bộ).
  + Tách mỗi ca học thành **MỘT CARD TRẮNG ĐỘC LẬP** (theo đúng ảnh mockup 2):
    - Box thời gian có màu nền riêng (`14:00 60p` màu xanh pastel; `16:30 90p` màu xám).
    - Có badge con riêng biệt `[Minh]`, `[Lan]`.
    - Badge trạng thái `Sắp bắt đầu` / `Trực tiếp` bên phải.
  + Tăng kích cỡ chữ giờ học lên 17sp bold 800, tên môn 15sp.
- **Commit:** `refactor(parent): convert schedule items into independent cards with time boxes`

### Bước 5: Tách Tiêu đề Section & Tinh chỉnh Card "Phân tích học tập"
- **File:** `mobile/lib/features/parent/presentation/home/widgets/learning_analytics_card.dart`
- **Nội dung:**
  + Tách hàng tiêu đề `📈 PHÂN TÍCH HỌC TẬP` + Badge `Tiến bộ tốt` ra ngoài Card kèm nút thu gọn / mở rộng (state `bool _isExpanded = true`, mặc định mở toàn bộ).
  + Cấu trúc Card nội dung bên trong theo ảnh 2:
    - Hàng 1: Avatar con + `Minh · Lớp 10A1` + `Báo cáo tuần 42` bên trái; `Điểm TB: 8.4` + `(+15%)` bên phải.
    - Hàng 2: Box nhận xét AI màu nền xám `#F8FAFC`, bo góc 12px, highlight từ khóa **22%**.
    - Hàng 3: Link `Xem phân tích của Minh ->` và `Tất cả báo cáo >` với tap-target thoáng 44px.
- **Commit:** `refactor(parent): polish learning analytics card layout and external section header`

### Bước 6: Hoàn thiện Phân tầng Nền Body & Kiểm thử Toàn diện
- **File:** `mobile/lib/features/parent/presentation/home/parent_home_screen.dart`
- **Nội dung:**
  + Đặt `Scaffold.backgroundColor = const Color(0xFFF8FAFC)`.
  + Header bọc trong container trắng `cs.surface`.
  + Khoảng cách dọc giữa các Section nâng lên `const SizedBox(height: 20)`.
  + Chạy `dart format` và `dart analyze` đảm bảo 0 error, 0 warning.
- **Commit:** `fix(parent): contrast surface layering between header and body`

---

## 8. CHECKLIST NGHIỆM THU (VERIFICATION CHECKLIST)

- [ ] **Header:** Lời chào thay đổi đúng buổi (Sáng/Chiều/Tối) + hiển thị tên thật phụ huynh từ Auth state; nền header trắng tinh khiết.
- [ ] **Background Contrast:** Body bên dưới cuộn trên nền xám dịu `#F8FAFC`, các Card trắng nổi bật rõ nét.
- [ ] **Thanh chọn con:** 
  + Khi tài khoản chỉ có 1 con: Ẩn nút "Tất cả các con".
  + Khi tài khoản có ≥ 2 con: Nút "Tất cả các con" mang màu xanh hệ thống (`blue600`), hiển thị số lượng con (ví dụ `2`).
- [ ] **Section Headers:** 100% tiêu đề section (`CẦN XỬ LÝ`, `HÔM NAY / TIẾP THEO`, `PHÂN TÍCH HỌC TẬP`) nằm **hoàn toàn bên ngoài card**.
- [ ] **Cơ chế Collapse toàn diện:** Tất cả các section (`CẦN XỬ LÝ`, `HÔM NAY / TIẾP THEO`, `PHÂN TÍCH HỌC TẬP`) đều tích hợp collapse, **mặc định hiển thị MỞ TOÀN BỘ (`_isExpanded = true`)** khi vào trang, bấm vào Header bar hoặc chevron để thu gọn/mở rộng mượt mà.
- [ ] **Thẻ Ca học:** Mỗi buổi học là một Card trắng độc lập, có khối thời gian bo góc riêng (`14:00 60p` xanh; `16:30 90p` xám), badge con `[Minh]`, `[Lan]` rõ ràng.
- [ ] **Thẻ Phân tích:** Bố cục đúng ảnh 2 với Điểm TB 8.4 (+15%) góc phải, box nhận xét xám nhạt, link điều hướng thoáng đãng.
- [ ] **Người lớn tuổi:** Cỡ chữ từ 13 - 18sp, vùng chạm ≥ 44px, không chói mắt, dễ đọc dễ dùng.
- [ ] **Chất lượng Code:** `dart analyze` sạch 100%, không ảnh hưởng đến bất kỳ role nào khác.
