# KẾ HOẠCH TÁI THIẾT KẾ HERO BANNER & BỔ SUNG CƠ CHẾ LƯỚT NGANG BỘ LỌC DANH MỤC
## (HERO BANNER REDESIGN & SWIPEABLE CATEGORY FILTER VIEW)

> **Tài liệu tham chiếu:** `mobile/docs/insight_UI_student/`  
> **Phiên bản:** 2.0 (Cập nhật chuẩn hóa cơ chế lướt ngang chuyển bộ lọc)  
> **Trạng thái:** Kế hoạch đề xuất (Chờ phê duyệt - Chưa code)  
> **Phạm vi áp dụng:** 2 màn hình:  
> 1. `mobile/lib/features/student/presentation/achievement/all_achievements_screen.dart`  
> 2. `mobile/lib/features/student/presentation/achievement/all_certificates_screen.dart`  

---

## 1. BỐI CẢNH & PHÂN TÍCH YÊU CẦU CỐT LÕI (AUDIT & SCOPE)

### 1.1. Vấn đề 1: Hero Banner dùng Gradient xanh quá nặng, đi ngược triết lý hệ thống
- **Hiện trạng:**
  - Banner Badges và Banner Certificates hiện đang bọc trong khối `Container` dùng `LinearGradient` 3 dải màu xanh tối/đen gắt (`[0xFF1E293B, 0xFF1E3A8A, 0xFF3D5FC4]`) cùng bóng đổ xanh đậm.
  - Khối này tạo ra một mảng tối dày đặc, đứt gãy thị giác hoàn toàn so với nền sáng (`cs.surface` / `slate50`), mang lại cảm giác app game giải trí thông thường thay vì một nền tảng giáo dục học thuật, công nghệ cao cấp.
- **Mong muốn:**
  - **Tuyệt đối KHÔNG sử dụng màu gradient**.
  - Thiết kế nhẹ nhàng nhưng nổi bật, bề mặt phẳng sáng (**Flat Light Surface**), viền bo siêu mỏng, bóng đổ khuếch tán cực nhẹ, mang phong cách công nghệ, học thuật, đơn giản và tinh tế.

### 1.2. Vấn đề 2: Thiếu cơ chế lướt ngang đặc trưng của Mobile giữa các bộ lọc danh mục
- **Hiện trạng:**
  - Ngay dưới Hero Banner có thanh bộ lọc danh mục (Category Chips):
    - Màn hình Chứng chỉ gồm: `Tất cả (All)`, `Thiết kế (Design)`, `Lập trình (Programming)`, `Kinh doanh (Business)`, `Ngoại ngữ (Language)`.
    - Màn hình Huy hiệu gồm: `Tất cả (All)`, `Học tập (Learning)`, `Thói quen (Habit)`, `Kỳ tích (Achievement)`.
  - Hiện tại, người dùng **bắt buộc phải dùng ngón tay nhấn (tap) vào từng chip** nếu muốn đổi danh mục. Không thể vuốt ngón tay sang trái/phải trên màn hình để chuyển qua lại giữa các danh mục này.
  - Điều này đi ngược lại thói quen tương tác tự nhiên của người dùng di động (Gesture-driven Navigation / Swipe Affordance).
- **Mong muốn:**
  - Bổ sung cơ chế **lướt ngang (horizontal swipe)** trên toàn bộ vùng nội dung danh sách.
  - Người dùng đang ở tab `Tất cả` chỉ cần vuốt nhẹ sang trái là trượt sang `Thiết kế`, vuốt tiếp sang `Lập trình`...
  - Thanh chip bộ lọc bên trên tự động đồng bộ (highlight chip được chọn và tự động cuộn chip vào giữa màn hình). Ngược lại, khi nhấn vào chip thì danh sách trượt mượt mà đến trang tương ứng.

---

## 2. TRIẾT LÝ THIẾT KẾ MỚI CHO HERO BANNER (NO GRADIENT, TECH & ACADEMIC)

### 2.1. Ngôn ngữ thiết kế: "Flat Light - Minimalist - Academic Standing"
- **Không Gradient (Flat Surface):** Nền trắng tinh khôi (`Colors.white`), viền bo mảnh siêu nét `0.8px` với màu `cs.outlineVariant.withValues(alpha: 0.5)` hoặc `cs.blue100`.
- **Độ nổi vi mô (Soft Elevation):** Bóng đổ khuếch tán siêu nhẹ `BoxShadow(color: cs.shadow.withValues(alpha: 0.035), blurRadius: 10, offset: Offset(0, 3))` giúp khối banner tách bạch nhẹ nhàng khỏi nền `cs.surface` mà không gây nặng mắt.
- **Điểm nhấn Tonal Pastel:** Các khối biểu tượng (Squircle icon) và chip trạng thái sử dụng nền pastel thanh khiết:
  - Cúp thành tích: squircle nền `amber50` với icon cúp vàng ấm áp.
  - Nón cử nhân: squircle nền `blue50` với icon xanh dương công nghệ `cs.brandBlue`.
  - Chip xác thực điện tử: nền ngọc lục bảo `emerald50` với viền `emerald200` và text `emerald700`.
- **Thanh tiến độ Slim Tech Bar:** Cao 6px, bo tròn hoàn toàn, chạy màu `cs.brandBlue` trên nền rãnh xám nhạt `slate100`.

### 2.2. Chi tiết bố cục 2 Hero Banner mới (ASCII Wireframes)

#### A. Banner Tất cả Huy hiệu (`AllAchievementsScreen`)
```
┌──────────────────────────────────────────────────────────────────┐
│ [🏆 Squircle 42x42]   PHÒNG TRUYỀN THỐNG         [ ⭐ Hạng Vàng ] │
│                       Bảng Vàng Danh Dự Học Viên                 │
│                                                                  │
│  Đã mở khóa 12/24 huy hiệu                       50% hoàn thành  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                                                  │
│  [📚 Học tập: 6]       [⚡ Thói quen: 4]       [⭐ Kỳ tích: 2]   │
└──────────────────────────────────────────────────────────────────┘
```
* **Cấp bậc học thuật (Academic Standing):** Chip `Hạng Vàng` (tự động tính dựa trên số huy hiệu đạt được: Đồng < 6, Bạc < 12, Vàng < 18, Bạch Kim >= 18).
* **Mini Category Summary:** 3 pill tóm tắt số huy hiệu đã đạt theo từng nhóm chuyên biệt, tăng tính học thuật và thôi thúc học viên.

#### B. Banner Tất cả Chứng chỉ (`AllCertificatesScreen`)
```
┌──────────────────────────────────────────────────────────────────┐
│ [🎓 Squircle 42x42]   HỒ SƠ NĂNG LỰC HỌC THUẬT   [ ✓ Đã Xác Thực ]│
│                       Chứng Chỉ & Văn Bằng ForteX                │
│                                                                  │
│  4 chứng chỉ chính quy đã cấp   •   2 khóa học đang theo học     │
│ ──────────────────────────────────────────────────────────────── │
│  🛡️ Mã định danh bảo mật điện tử tích hợp trên toàn hệ thống      │
└──────────────────────────────────────────────────────────────────┘
```
* **Dấu ấn số hóa (Digital Credentials):** Chip `[✓ Đã Xác Thực]` công nghệ với biểu tượng xác thực số.
* **Chỉ số năng lực:** Số lượng chứng chỉ đã hoàn thành và số khóa học đang tích lũy tín chỉ.

---

## 3. KIẾN TRÚC CƠ CHẾ LƯỚT NGANG BỘ LỌC (HORIZONTAL CATEGORY SWIPE ARCHITECTURE)

### 3.1. Thách thức kỹ thuật & Giải pháp
- **Thách thức:** Màn hình vừa có phần Header (Top App Bar, Hero Banner, Category Tabs) cần cuộn mượt mà theo chiều dọc, vừa có vùng nội dung danh sách cần lướt ngang qua lại giữa các danh mục mà không bị xung đột cử chỉ (gesture conflict).
- **Giải pháp tối ưu: `NestedScrollView` + `SliverPersistentHeader` + `PageView`:**
  - `NestedScrollView`:
    - `headerSliverBuilder`: Chứa Top App Bar, Hero Banner và Category Tabs.
    - `body`: Chứa `PageView.builder` quản lý các danh mục.
  - **Category Tabs dạng `SliverPersistentHeader(pinned: true)`:** Khi học viên cuộn danh sách xuống dưới, Hero Banner cuộn gọn lên trên, trong khi thanh Category Chips ghim nhẹ nhàng sát dưới App Bar. Học viên có thể lướt ngang đổi danh mục ở bất kỳ vị trí cuộn nào!

```
┌────────────────────────────────────────────────────────┐
│ Top App Bar (Back button, Tiêu đề, Filter icon)        │
├────────────────────────────────────────────────────────┤
│ Hero Banner (Flat Light, Không Gradient, Công nghệ)    │
├────────────────────────────────────────────────────────┤  ▲ Cuộn dọc
│ [Tất cả (24)]  [Thiết kế (8)]  [Lập trình (10)] ...    │  │ (Ghim sticky)
├────────────────────────────────────────────────────────┤
│                                                        │
│   ◄─────── LƯỚT NGANG QUA LẠI GIỮA CÁC TAB ───────►    │
│                                                        │
│   Danh sách chứng chỉ / huy hiệu tương ứng với tab     │
│   (Mỗi tab lưu giữ vị trí cuộn độc lập PageStorageKey) │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 3.2. Cơ chế Đồng bộ 2 chiều (Bi-directional Sync)
1. **Khi người dùng Vuốt ngang (Swipe Gesture):**
   - Sự kiện `onPageChanged(int index)` của `PageView` được kích hoạt.
   - Cập nhật state `_selectedCategoryIndex`.
   - Gọi `Scrollable.ensureVisible` hoặc `_categoryScrollController.animateTo(...)` để thanh Category Chips tự động trượt, đảm bảo chip đang chọn luôn nằm trọn vẹn ở vị trí dễ nhìn nhất trên màn hình.
2. **Khi người dùng Chạm vào Chip (Tap Gesture):**
   - Gọi `_pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeInOutCubic)`.
   - Danh sách bên dưới trượt mượt mà sang danh mục được chọn.
3. **Duy trì trạng thái cuộn độc lập (Scroll Position Retention):**
   - Mỗi danh mục trong `PageView` được gán một `PageStorageKey('category_${category.name}')`, giúp giữ nguyên vị trí cuộn khi người dùng lướt qua lại giữa các tab mà không bị nhảy lên đầu trang.

---

## 4. CHI TIẾT TỪNG MÀN HÌNH

### 4.1. Màn hình Tất cả Huy hiệu (`AllAchievementsScreen`)
- **Danh sách Tab (4 Danh mục):**
  1. `BadgeCategory.all` (Tất cả)
  2. `BadgeCategory.learning` (Học tập)
  3. `BadgeCategory.habit` (Thói quen)
  4. `BadgeCategory.achievement` (Kỳ tích)
- **Nội dung từng Page:**
  - Lọc danh sách `_allBadges` theo danh mục của Page đó: `earnedBadges`, `inProgressBadges`, `lockedBadges`.
  - Hiển thị theo dạng Grid 3 cột với tiêu đề phân nhóm: Đã đạt (`Earned`), Đang tiến hành (`In Progress`), Chưa mở khóa (`Locked`).
  - Nếu một danh mục rỗng (ví dụ học viên chưa có huy hiệu nào ở nhóm đó), hiển thị **Positive Empty State** tinh tế khích lệ học tập.

### 4.2. Màn hình Tất cả Chứng chỉ (`AllCertificatesScreen`)
- **Danh sách Tab (5 Danh mục):**
  1. `CertificateCategory.all` (Tất cả)
  2. `CertificateCategory.design` (Thiết kế)
  3. `CertificateCategory.programming` (Lập trình)
  4. `CertificateCategory.business` (Kinh doanh)
  5. `CertificateCategory.language` (Ngoại ngữ)
- **Nội dung từng Page:**
  - Lọc danh sách `_allCertificates` theo danh mục: `completedCertificates`, `inProgressCertificates`.
  - Hiển thị theo dạng thẻ danh sách (`CertificateListCard`).
  - Nếu danh mục rỗng, hiển thị Empty State với icon chứng chỉ màu xám bạc thanh nhã và text thông báo rõ ràng.

---

## 5. KẾ HOẠCH MODULE HÓA & KIẾN TRÚC MÃ NGUỒN

Để giữ mã nguồn tinh gọn, tuân thủ nguyên tắc Single Responsibility:
1. **Tạo 2 Widget Banner Độc lập:**
   - `mobile/lib/features/student/presentation/achievement/widgets/achievements_hero_banner.dart`: Quản lý hiển thị Banner phòng truyền thống phẳng sáng, không gradient.
   - `mobile/lib/features/student/presentation/achievement/widgets/certificates_hero_banner.dart`: Quản lý hiển thị Banner hồ sơ năng lực học thuật phẳng sáng, không gradient.
2. **Tạo Category Tabs Sticky Header Delegate:**
   - `category_tabs_header_delegate.dart`: Delegate cho `SliverPersistentHeader`, hỗ trợ ghim thanh chip và tự động scroll chip theo tab active.
3. **Cập nhật 2 màn hình chính:**
   - Tích hợp `NestedScrollView` + `PageView` vào `AllAchievementsScreen` và `AllCertificatesScreen`.
   - Kết nối controller đồng bộ giữa chip và page view.

---

## 6. LỘ TRÌNH THỰC THI (ROADMAP)

> **Lưu ý:** Hiện tại chỉ dừng lại ở bước lập và thống nhất kế hoạch. Chưa can thiệp code cho đến khi có xác nhận tiếp theo từ bạn.

- [ ] **Giai đoạn 1: Xây dựng 2 Hero Banner mới (Flat Light & Tech-Academic)**
  - Viết `AchievementsHeroBanner` loại bỏ hoàn toàn gradient, dùng nền trắng, viền mảnh `0.8px`, icon squircle pastel.
  - Viết `CertificatesHeroBanner` chuẩn hóa phong cách công nghệ học thuật, bổ sung chip `[✓ Đã xác thực]`.
  - Export vào `widgets.dart`.

- [ ] **Giai đoạn 2: Xây dựng cơ chế Swipeable Category Filter View**
  - Xây dựng widget điều hướng vuốt ngang với `PageView` và bộ đồng bộ `PageController` <-> `ScrollController`.
  - Thiết lập `PageStorageKey` bảo toàn trạng thái cuộn cho từng tab.
  - Xử lý mượt mà chuyển động lướt ngón tay và hiệu ứng chạm chip.

- [ ] **Giai đoạn 3: Tích hợp & Hoàn thiện trên 2 màn hình**
  - Refactor `AllAchievementsScreen`: Thay `CustomScrollView` đơn tầng bằng kiến trúc `NestedScrollView` + `PageView` 4 danh mục.
  - Refactor `AllCertificatesScreen`: Thay thế tương tự với `PageView` 5 danh mục.

- [ ] **Giai đoạn 4: Kiểm thử trải nghiệm & Thẩm mỹ (QA & Verification)**
  - Chạy `flutter analyze` đảm bảo sạch sẽ không lỗi cú pháp hoặc cảnh báo lint.
  - Kiểm thử trực quan trên Emulator: thao tác vuốt ngang qua lại giữa các filter, chạm chip chuyển tab, cuộn dọc ghim header.
  - Chụp ảnh màn hình đối chiếu nghiệm thu.

---

## 7. TIÊU CHÍ NGHIỆM THU (ACCEPTANCE CRITERIA)

1. **Về Thẩm Mỹ Banner:**
   - [x] 100% không còn dải màu `LinearGradient` xanh đậm/gắt.
   - [x] Banner mang phong cách sáng sủa, công nghệ, học thuật, viền mỏng thanh thoát, bóng mờ tự nhiên.
2. **Về Cơ Chế Lướt Ngang:**
   - [x] Người dùng có thể vuốt ngang trái/phải trên danh sách để chuyển đổi tức thì giữa các bộ lọc (`All` <-> `Design` <-> `Programming`...).
   - [x] Thanh chip bộ lọc bên trên tự động đồng bộ highlight và cuộn theo tab đang hiển thị.
   - [x] Chạm vào chip bộ lọc kích hoạt hiệu ứng trượt mượt mà sang tab đó.
   - [x] Giữ nguyên vị trí cuộn của từng danh mục khi vuốt qua lại.
3. **Về Phạm Vi & Tính Ổn Định:**
   - [x] Giữ nguyên toàn bộ logic dữ liệu, bottom sheet xem chi tiết và bộ lọc nâng cao.
