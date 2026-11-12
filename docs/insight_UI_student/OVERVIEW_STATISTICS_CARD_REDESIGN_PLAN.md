# KẾ HOẠCH TÁI THIẾT KẾ CARD TỔNG QUAN TAB THÀNH TÍCH: THE ACADEMIC HONOR DECK
## (OVERVIEW STATISTICS CARD REDESIGN & ACADEMIC PRESTIGE PROPOSAL)

> **Tài liệu tham chiếu:** `mobile/docs/insight_UI_student/`  
> **Áp dụng cho:** `mobile/lib/features/student/presentation/achievement/`  
> **Trọng tâm module:** `overview_statistics.dart` & `achievement_screen.dart`  
> **Trạng thái:** Đã triển khai thành công 100% (Hoàn thành test suite & analyze)  
> **Mục tiêu cốt lõi:** Nâng cấp card Tổng quan từ một khối số liệu con mờ nhạt thành **"Trái tim Danh dự" (The Crown Jewel)** của Bảng Vàng Thành Tích, nổi bật cuốn hút, tôn vinh vị thế học thuật của học sinh, nói không với card-fatigue và gradient tối nặng nề.

---

## 1. BỐI CẢNH & PHÂN TÍCH HIỆN TRẠNG (CURRENT STATE AUDIT)

### 1.1. Hiện trạng thực tế của `OverviewStatistics`
Trong màn hình Thành tích (`AchievementScreen`), phần tử đầu tiên hiển thị ngay dưới thanh Header là `OverviewStatistics(stats: state.stats)`.

```dart
// Cấu trúc hiện tại trong overview_statistics.dart
Container(
  padding: const EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    color: isLight ? Colors.white : cs.surface,
    borderRadius: BorderRadius.circular(AppRadius.lg), // 16px
    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 0.8),
    boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.03), blurRadius: 10, offset: Offset(0, 2))],
  ),
  child: Column(
    children: [
      Text(l10n.overview), // "Tổng quan"
      Row(
        children: [
          AchievementStatItem(icon: access_time, value: '48', label: 'Giờ học'),
          _divider(),
          AchievementStatItem(icon: menu_book, value: '24', label: 'Bài học'),
          _divider(),
          AchievementStatItem(icon: emoji_events, value: '18', label: 'Huy hiệu'), // HARDCODE '18'
          _divider(),
          AchievementStatItem(icon: local_fire_department, value: '5', label: 'Chuỗi ngày'),
        ],
      ),
    ],
  ),
);
```

### 1.2. Bốn điểm hạn chế cốt lõi khiến Card "không đủ nổi bật"

#### 1. Thiếu tính chủ đạo và điểm rơi thị giác (No Visual Anchor / Lack of Dominance)
- Card có chiều cao khiêm tốn (~110-120px), màu nền trắng tiệp với nền canvas xám nhạt (`slate50`), bóng đổ mờ nhạt (opacity 3%).
- Khi học sinh mở tab Thành tích, mắt bị phân tán và ngay lập tức trôi tuột xuống phần `RecentBadges` (với các huy hiệu màu sắc rực rỡ) và `CertificateCarousel` (với hình ảnh chứng chỉ khổ lớn).
- Card Tổng quan vô tình biến thành một "tiểu mục kỹ thuật" (sub-widget) đơn điệu thay vì là tấm huân chương ghi nhận thành quả học tập.

#### 2. Dàn trải 4 cột cơ học và chật chội (Cramped 4-Column Layout)
- 4 cột bị ép vào 1 hàng ngang trên bề rộng màn hình di động chuẩn 360-390px (mỗi cột chỉ được ~75-80px).
- Nhãn mô tả (`l10n.completedLessons` = "Bài học hoàn thành", `l10n.studyHours` = "Giờ học") bị co ép, rớt dòng vụn vặt, cỡ chữ bé (`labelSmall`).
- Icon đường kính nhỏ (`32x32px`, icon size `16px`) không tạo được sự tự hào hay ấn tượng thị giác.
- Mỗi cột vẽ một đường `MiniSparkline` với mảng tọa độ cố định giả tạo (`[0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75]`), giống hệt nhau ở cả 4 cột, hoàn toàn vô nghĩa và gây nhiễu giao diện.

#### 3. Bỏ quên yếu tố vinh danh cốt lõi: Cấp bậc học thuật & Tiến trình XP
- Đây là màn hình **"BẢNG VÀNG THÀNH TÍCH"** - nơi học sinh tìm kiếm cảm giác được công nhận (Recognition), động lực phấn đấu (Motivation) và sự kiêu hãnh (Pride).
- Tuy nhiên, card Tổng quan lại **hoàn toàn giấu kín Cấp độ học sinh (`stats.level`)** và **Tổng điểm kinh nghiệm tích lũy (`stats.currentXp` / `stats.nextLevelXp`)**.
- Học sinh không biết mình đang đứng ở vị thế nào (Tân Khoa, Học Giả Tiên Phong hay Học Sĩ Tinh Hoa), còn thiếu bao nhiêu nỗ lực để thăng cấp danh dự.

#### 4. Lỗi dữ liệu cứng (Technical Defect: Hardcoded Badges)
- Giá trị số lượng huy hiệu đang bị gán tĩnh: `value: '18'` trong `overview_statistics.dart:60`, không hề phản ánh số lượng huy hiệu thực tế `state.earnedBadges.length`. Học sinh mới chưa có huy hiệu nào vẫn bị hiển thị `18`.

---

## 2. Ý TƯỞNG THIẾT KẾ ĐỘT PHÁ: "THE ACADEMIC HONOR DECK" V2.0

### 2.1. Triết lý thiết kế: "Flat Light Academic Luxury"
Card Tổng quan mới được định vị là **"Viên ngọc Vương miện" (The Crown Jewel)** của màn hình Thành tích:
1. **Không sử dụng Gradient đen/tối nặng nề:** Giữ vững triết lý thiết kế phẳng sáng chuẩn mực của ForteX (`BANNER_REDESIGN_BADGES_AND_CERTIFICATES_PLAN.md`).
2. **Sử dụng tương phản bề mặt phân tầng (Layered Micro-Surfaces):** Khối thẻ trắng tinh khôi kết hợp viền hairline siêu mảnh `0.8px` màu xanh học thuật (`blue100` / `blue200`), bóng đổ khuếch tán đa tầng mềm mại (`TogetherColorsX.shadowElevated`).
3. **Chi tiết danh dự mạ vàng kim & xanh Royal Navy:** Squircle Emblem Huân chương, con dấu Cấp độ `[ ⭐ CẤP ĐỘ X ]`, và thanh tiến trình kinh nghiệm công nghệ siêu mỏng (`Slim Tech XP Bar`).

---

### 2.2. Kiến trúc Bố cục Mới: Mô hình 2 Tầng Tương Phản (Bi-Level Prestige Canvas)

```
┌────────────────────────────────────────────────────────────────────────┐
│ [🏆 CREST 48x48]   HỌC GIẢ TINH HOA                    [ ⭐ CẤP ĐỘ 5 ] │  <- TẦNG 1: TÔN VINH VỊ THẾ
│                    Tín chỉ tích lũy: 1,450 XP                           │     (Honor & Level Spotlight)
│                                                                        │
│  Tiến trình thăng cấp Level 6                     350 XP nữa để thăng cấp│
│  ████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░  (75%) │
├────────────────────────────────────────────────────────────────────────┤  <- Hairline Divider 0.8px
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  <- TẦNG 2: 4 CHỈ SỐ VÀNG
│  │ 🔥 STREAK    │  │ ⏱️ GIỜ HỌC   │  │ 📚 BÀI HỌC   │  │ 🏅 HUY HIỆU │ │     (Micro Stat Pods nền
│  │     12       │  │     48       │  │     36       │  │     14      │ │      pastel nhẹ, số lớn,
│  │  ngày liên tục│  │  giờ tích lũy│  │  bài hoàn tất│  │  đã mở khóa │ │      nhãn rõ ràng)
│  └──────────────┘  └──────────────┘  └──────────────┘  └─────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

#### Tầng 1: Khối Tôn vinh Vị thế & Tiến trình Cấp bậc (Upper Deck: Honor & Level Hero)
- **Squircle Emblem Huân chương (48×48px):** Nền vàng pastel ấm áp (`amber50`), viền vàng kim sắc sảo (`amber200`), icon Cúp/Huân chương vàng óng ánh (`Icons.workspace_premium_rounded` hoặc `Icons.military_tech_rounded`).
- **Danh hiệu học thuật tự động (Dynamic Academic Standing Title):**
  Hệ thống ánh xạ tự động theo `stats.level`:
  - `Level 1 - 2`: **Tân Khoa Nhập Môn** *(Novice Scholar)*
  - `Level 3 - 4`: **Học Giả Tiến Bộ** *(Rising Scholar)*
  - `Level 5 - 6`: **Học Giả Tinh Hoa** *(Elite Scholar)*
  - `Level 7 - 8`: **Học Viện Danh Dự** *(Honor Laureate)*
  - `Level 9+`  : **Đại Học Sĩ ForteX** *(Grandmaster Scholar)*
- **Chip Cấp độ danh dự (Prestige Tier Badge):**
  - Đặt trang trọng ở góc trên bên phải: `[ ⭐ CẤP ĐỘ 5 ]` với nền `amber50`, viền `amber300`, chữ in hoa đậm `amber800`.
- **Thanh tiến trình kinh nghiệm Slim Tech Bar (6px):**
  - Rãnh trượt `slate100`, thanh chạy màu xanh công nghệ `cs.brandBlue` (hoặc gradient xanh dương nhẹ nhàng `[#2563EB, #3B82F6]`).
  - Đi kèm nhãn động thông minh: `Còn 350 XP để thăng cấp Học Giả Danh Dự` và tỉ lệ phần trăm `75%`.

#### Tầng 2: Cụm 4 Chỉ số Vàng dạng Thẻ Vi mô (Lower Deck: Quad Micro-Stat Pods)
Thay vì xếp 4 cột chữ đen trơ trọi, tầng 2 sử dụng **4 thẻ con vi mô (Micro Pods)** với nền màu pastel cực nhẹ, giúp các chỉ số nổi bật độc lập và cực kỳ bắt mắt:
1. **🔥 Chuỗi học tập (Streak Pod):**
   - Nền `orange50` (hoặc `rose50`), icon lửa `Icons.local_fire_department_rounded` màu cam rực rỡ (`AchievementColors.orange`).
   - Con số to bản, chữ đậm (`titleLarge` 20sp, rolling counter), nhãn phụ: `ngày liên tục`.
2. **⏱️ Thời lượng học tập (Study Hours Pod):**
   - Nền `blue50`, icon đồng hồ `Icons.schedule_rounded` màu xanh học thuật (`cs.brandBlue`).
   - Con số: `${stats.totalStudyHours.toInt()}`, nhãn phụ: `giờ tích lũy`.
3. **📚 Bài học hoàn tất (Lessons Pod):**
   - Nền `emerald50`, icon sách vở `Icons.menu_book_rounded` màu xanh ngọc (`AchievementColors.green`).
   - Con số: `${stats.completedLessons}`, nhãn phụ: `bài đã học`.
4. **🏅 Huy hiệu vinh danh (Badges Pod):**
   - Nền `purple50` (hoặc `amber50`), icon cúp huy hiệu `Icons.emoji_events_rounded` màu tím huân chương (`AchievementColors.purple`).
   - Con số: **Dữ liệu thực tế** `${earnedBadgesCount}` (triệt tiêu hoàn toàn hardcode `18`), nhãn phụ: `đã mở khóa`.

---

## 3. BẢNG SO SÁNH TRỰC QUAN (BEFORE VS AFTER MATRIX)

| Tiêu chí | Card Hiện tại (Before) | Đề xuất Mới (The Academic Honor Deck V2.0) |
| :--- | :--- | :--- |
| **Vai trò & Cảm xúc** | Một hàng số liệu phụ trợ mờ nhạt, tĩnh lặng, thiếu điểm nhấn | **"Viên ngọc Vương miện" (The Crown Jewel)** - Tôn vinh vị thế, tạo động lực phấn đấu mạnh mẽ |
| **Cấp bậc & Danh hiệu** | ❌ Hoàn toàn KHÔNG có | ✅ **Danh xưng học thuật động** (`Học Giả Tinh Hoa`), Chip Cấp độ `[ ⭐ CẤP ĐỘ X ]` |
| **Tiến trình XP** | ❌ Hoàn toàn KHÔNG có | ✅ **Slim Tech XP Bar** kèm thông điệp khích lệ `Còn X XP để thăng hạng` |
| **Bố cục** | 1 hàng ngang ép 4 cột hẹp, rớt dòng chữ | **2 tầng tương phản (Bi-Level)**: Tầng trên Vinh danh, Tầng dưới 4 Micro Pods |
| **Trình bày Chỉ số** | Icon nhỏ 16px, sparkline giả lập vô nghĩa | 4 Micro Pods nền pastel thanh khiết, icon 22px rực rỡ, số lớn có Rolling Counter |
| **Tính chính xác dữ liệu**| ⚠️ Lỗi gán cứng `value: '18'` | ✅ Đồng bộ 100% với `state.earnedBadges.length` và `stats` |
| **Độ nổi bật (Visual Standout)**| Mờ nhạt (Elevation 0.03, không viền nhấn) | Vượt trội với viền Hairline xanh hoàng gia, bóng phân lớp `shadowElevated` |
| **Tương thích Mobile** | Dễ tràn hoặc co quắp trên màn nhỏ 360px | Co giãn đàn hồi tự nhiên (Responsive Flex & Grid Pods) |

---

## 4. CHI TIẾT ĐẶC TẢ KỸ THUẬT & DESIGN TOKENS

### 4.1. Bảng ánh xạ Danh hiệu Học thuật Động (Academic Standing Engine)

```dart
String resolveAcademicTitle(int level) {
  return switch (level) {
    <= 2 => 'Tân Khoa Nhập Môn',
    <= 4 => 'Học Giả Tiến Bộ',
    <= 6 => 'Học Giả Tinh Hoa',
    <= 8 => 'Học Viện Danh Dự',
    _    => 'Đại Học Sĩ ForteX',
  };
}
```

### 4.2. Bảng Design Tokens sử dụng

| Thành phần | Light Mode Token | Dark Mode Token | Ghi chú |
| :--- | :--- | :--- | :--- |
| **Nền Card chính** | `Colors.white` | `cs.surfaceContainer` | Bề mặt phẳng sạch sẽ |
| **Viền Card chính** | `cs.blue100` (`#DBEAFE`) | `cs.slate700` | Hairline border `0.8px` sắc sảo |
| **Bóng Card chính** | `TogetherColorsX.shadowElevated` | `BoxShadow(color: Colors.black26, blurRadius: 12)` | Tạo chiều sâu nổi bật |
| **Huân chương Emblem**| Nền `amber50` (`#FEF3C7`), viền `amber200` | Nền `amber950.withValues(alpha: 0.3)`, viền `amber700` | Squircle 48×48px, bo góc 14px |
| **Chip Cấp độ** | Nền `amber50`, viền `amber300`, text `amber800` | Nền `amber900.withValues(alpha: 0.4)`, text `amber300` | Bo góc 6px tinh tế |
| **Thanh chạy XP** | `cs.brandBlue` (`#2563EB`) | `cs.brandBlueLight` (`#3B82F6`) | Chiều cao 6px, bo tròn hoàn toàn |
| **Rãnh trượt XP** | `cs.slate100` (`#F1F5F9`) | `cs.slate800` | Rãnh xám nhạt |
| **Pod Streak** | Nền `Color(0xFFFFF7ED)`, icon `Color(0xFFEA580C)` | Nền `Color(0xFF431407).withValues(alpha: 0.4)` | Cam ấm rực cháy |
| **Pod Giờ học** | Nền `Color(0xFFEFF6FF)`, icon `Color(0xFF2563EB)` | Nền `Color(0xFF172554).withValues(alpha: 0.4)` | Xanh học thuật |
| **Pod Bài học** | Nền `Color(0xFFECFDF5)`, icon `Color(0xFF059669)` | Nền `Color(0xFF064E3B).withValues(alpha: 0.4)` | Xanh ngọc lục bảo |
| **Pod Huy hiệu** | Nền `Color(0xFFFAF5FF)`, icon `Color(0xFF7C3AED)` | Nền `Color(0xFF3B0764).withValues(alpha: 0.4)` | Tím hoàng gia |

---

## 5. KẾ HOẠCH TRIỂN KHAI CHI TIẾT (IMPLEMENTATION ROADMAP)

> **LƯU Ý:** Giai đoạn này chỉ lên plan, chưa thực hiện code. Khi người dùng phê duyệt sẽ tiến hành theo 4 bước chuẩn xác:

### Giai đoạn 1: Chuẩn hóa Dữ liệu & Interface Binding
- Cập nhật tham số của `OverviewStatistics` (hoặc widget mới):
  - Nhận `StudentStatsModel stats`.
  - Nhận `int earnedBadgesCount` (lấy từ `state.earnedBadges.length`).
  - Nhận `int totalBadgesCount` (lấy từ `state.badges.length`).
- Loại bỏ hoàn toàn chuỗi hardcode `value: '18'`.
- Tích hợp engine tính toán danh hiệu học thuật (`resolveAcademicTitle`).

### Giai đoạn 2: Xây dựng UI Component `AcademicHonorOverviewCard`
- Tạo widget hoàn toàn mới `academic_honor_overview_card.dart` trong thư mục `mobile/lib/features/student/presentation/achievement/widgets/`.
- Xây dựng cấu trúc **Bi-Level Prestige Canvas**:
  - Tầng 1: Emblem Squircle + Title + Level Chip + Slim Tech XP Bar (kèm animation chạy đầy 800ms).
  - Tầng 2: Cụm 4 Micro Stat Pods (Streak, Giờ học, Bài học, Huy hiệu) với hiệu ứng số cuộn `TweenAnimationBuilder`.
- Hỗ trợ đầy đủ Light/Dark Mode thông qua tokens chuẩn từ `app_colors.dart`.
- Giữ `overview_statistics.dart` làm wrapper tương thích ngược (hoặc refactor trực tiếp để đảm bảo không gãy imports).

### Giai đoạn 3: Tích hợp vào `AchievementScreen` & Tinh chỉnh Responsive
- Cập nhật `achievement_screen.dart:125`: Truyền thêm `earnedBadgesCount: state.earnedBadges.length`.
- Kiểm tra tính co giãn linh hoạt trên các kích thước màn hình phổ biến:
  - Màn hình nhỏ: `360×800` (Android phổ thông).
  - Màn hình chuẩn: `390×844` (iPhone 14/15/16).
  - Màn hình lớn: `430×932` (iPhone Pro Max).
- Đảm bảo không xảy ra hiện tượng tràn chữ (Overflow) hay cắt chữ.

### Giai đoạn 4: Viết Widget Tests & Xác minh Chất lượng
- Viết mới test suite `test/features/student/presentation/achievement/widgets/academic_honor_overview_card_test.dart`:
  1. Kiểm tra render đầy đủ Cấp độ, Danh hiệu học thuật theo từng mốc Level.
  2. Kiểm tra thanh tiến trình XP tính toán đúng phần trăm `currentXp / nextLevelXp`.
  3. Kiểm tra 4 Micro Pods hiển thị đúng giá trị thực (đặc biệt số huy hiệu không bị hardcode).
  4. Kiểm tra khả năng render mượt mà tại cả 2 kích thước `360px` và `390px`.
- Chạy `flutter analyze` để đảm bảo 0 Errors, 0 Warnings.

---

## 6. KẾT LUẬN & ĐỀ NGHỊ PHÊ DUYỆT

Bản thiết kế **"The Academic Honor Deck" V2.0** giải quyết trọn vẹn yêu cầu của người dùng:
1. **Nổi bật vượt trội:** Trở thành tâm điểm thị giác số 1 của tab Thành tích, khiến học sinh ấn tượng ngay khi mở màn hình.
2. **Đậm chất học thuật & Danh dự:** Đưa Cấp độ và Danh hiệu vào vị trí trung tâm, khơi dậy niềm tự hào học tập.
3. **Thoáng đãng & Tinh tế:** Xóa bỏ cảm giác chật chội của 4 cột đơn điệu, thay bằng cấu trúc 2 tầng thoáng đãng với 4 Micro Pods màu pastel thanh nhã.
4. **Chuẩn xác kỹ thuật:** Sửa triệt để lỗi hardcode dữ liệu và loại bỏ sparkline giả.

*Kính chuyển Người dùng (USER) xem xét và cho ý kiến chỉ đạo để bắt đầu triển khai code.*
