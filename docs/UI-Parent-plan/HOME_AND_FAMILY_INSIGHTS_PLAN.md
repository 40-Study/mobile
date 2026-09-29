# Kế hoạch Nâng cấp Tab Home & Xây dựng Màn hình Family Insights Inbox

> **Tài liệu tham chiếu chuẩn:**
> - UX Spec & User Journeys: `C:\Users\tungm\Downloads\deliverable.md` (Screens #1 Home, #2 Family Insights Inbox, #6 Learning Insights)
> - Ảnh thiết kế do Người dùng cung cấp: `Family Insights Inbox` (Artifact: `uploaded_media_1790691408545.png`)
> - Quyết định định hướng sản phẩm: **Giữ nguyên thanh chọn con (`FamilyScopeSelector`) ở Tab Home** để tối ưu hóa trải nghiệm lọc nhanh thông tin theo con của phụ huynh.

---

## Mục lục
1. [Bối cảnh & Mục tiêu tổng quát](#1-bối-cảnh--mục-tiêu-tổng-quát)
2. [Phần I: Kế hoạch Nâng cấp Tab Home](#phần-i-kế-hoạch-nâng-cấp-tab-home)
   - [1. Phân loại "Cần xử lý" theo 4 mức ưu tiên (4 Tiers)](#1-phân-loại-cần-xử-lý-theo-4-mức-ưu-tiên-4-tiers)
   - [2. Kiến trúc Khắc phục Lỗi Cục bộ (Partial Failure) & Skeleton Từng Khối](#2-kiến-trúc-khắc-phục-lỗi-cục-bộ-partial-failure--skeleton-từng-khối)
   - [3. Tinh chỉnh Presentation & Tích hợp Entry Point sang Family Insights Inbox](#3-tinh-chỉnh-presentation--tích-hợp-entry-point-sang-family-insights-inbox)
3. [Phần II: Phân tích Thiết kế & Kế hoạch Màn hình Family Insights Inbox](#phần-ii-phân-tích-thiết-kế--kế-hoạch-màn-hình-family-insights-inbox)
   - [1. Phân tích Chi tiết Bản thiết kế (Ảnh 1)](#1-phân-tích-chi-tiết-bản-thiết-kế-ảnh-1)
     - [1.1. Cấu trúc giao diện & Yếu tố thị giác](#11-cấu-trúc-giao-diện--yếu-tố-thị-giác)
     - [1.2. Ưu điểm nổi bật (Sức mạnh UX)](#12-ưu-điểm-nổi-bật-sức-mạnh-ux)
     - [1.3. Nhược điểm & Đề xuất Cải tiến Hoàn thiện](#13-nhược-điểm--đề-xuất-cải-tiến-hoàn-thiện)
   - [2. Thiết kế Kiến trúc Dữ liệu (Data Models)](#2-thiết-kế-kiến-trúc-dữ-liệu-data-models)
   - [3. Thiết kế Quản lý Trạng thái (BLoC State Management)](#3-thiết-kế-quản-lý-trạng-thái-bloc-state-management)
   - [4. Thiết kế Giao diện (Presentation Layer & Component Specs)](#4-thiết-kế-giao-diện-presentation-layer--component-specs)
   - [5. Tương tác Người dùng & Điều hướng (Navigation & Interactions)](#5-tương-tác-người-dùng--điều-hướng-navigation--interactions)
4. [Lộ trình Triển khai Chi tiết (Phased Execution Plan)](#4-lộ-trình-triển-khai-chi-tiết-phased-execution-plan)
5. [Kế hoạch Kiểm thử & Tiêu chuẩn Nghiệm thu (Acceptance Criteria)](#5-kế-hoạch-kiểm-thử--tiêu-chuẩn-nghiệm-thu-acceptance-criteria)

---

## 1. Bối cảnh & Mục tiêu tổng quát

Trong hệ sinh thái ứng dụng dành cho Phụ huynh học sinh (Parent Portal), **Home** là màn hình thường nhật giải đáp 3 câu hỏi cốt lõi: *"Hôm nay có việc gì khẩn cấp của con cần tôi giải quyết?", "Lịch học tiếp theo diễn ra lúc nào?", "Tình hình học tập gần đây ra sao?"*. 

Khi số lượng con tăng lên hoặc khối lượng dữ liệu phân tích học tập nhiều lên, **Family Insights Inbox** (Màn hình #2 trong Spec `deliverable.md`) là không gian chuyên sâu để phụ huynh theo dõi toàn bộ các phân tích định kỳ, lời nhận xét của giáo viên và thói quen học tập của mọi con trong gia đình trên một dòng thời gian duy nhất mà không bị giới hạn không gian như ở Home.

### Mục tiêu chính của Plan:
1. **Hoàn thiện Tab Home đạt chuẩn Spec 100%:**
   - Giữ nguyên `FamilyScopeSelector` để phụ huynh có thể xem tổng quan mọi con hoặc lọc nhanh theo từng con.
   - Chuẩn hóa phân loại "Cần xử lý" theo đúng 4 mức ưu tiên (Tier 1: Khẩn cấp/Đổi lịch/Quá hạn $\rightarrow$ Tier 2: Đến hạn hôm nay $\rightarrow$ Tier 3: Sự kiện tiếp theo $\rightarrow$ Tier 4: Thông tin chung).
   - Triển khai kiến trúc **Partial Failure** và **Skeleton per-section**: Từng khối (`ActionRequired`, `UpcomingSchedule`, `LearningAnalytics`) tải độc lập, có skeleton loading riêng và lỗi ở khối này không làm hỏng dữ liệu của các khối khác.
2. **Xây dựng Màn hình Family Insights Inbox:**
   - Phân tích ưu/nhược điểm bản thiết kế do người dùng cung cấp.
   - Xây dựng trọn vẹn màn hình với nền `surfaceBg` cao cấp, hỗ trợ lọc theo con, thẻ insight đa dạng (Tiến bộ vượt bậc, Cần chú ý, Khen thưởng/Kỷ luật), bằng chứng định lượng, lời dặn giáo viên và nút hành động khích lệ con.

---

## Phần I: Kế hoạch Nâng cấp Tab Home

### 1. Phân loại "Cần xử lý" theo 4 mức ưu tiên (4 Tiers)

Theo quy định tại **Dòng 311 của `deliverable.md`**:
> *"Quy tắc sắp xếp 'Cần xử lý': sắp theo 4 mức, không theo loại cố định: (1) khẩn cấp/thay đổi bất thường (lớp đổi giờ/hủy trong ngày, bài quá hạn), (2) đến hạn trong hôm nay, (3) sự kiện tiếp theo, (4) tổng quan không cần hành động. Notification không phải 1 mục riêng - nội dung quan trọng của nó đã nằm ở mức 1-2."*

#### 1.1. Cập nhật Model `ParentAlertItem`
Mở rộng enum và cấu trúc dữ liệu:
```dart
/// 4 Mức độ ưu tiên của cảnh báo theo Spec
enum ParentAlertTier {
  /// Tier 1: Khẩn cấp / Thay đổi bất thường (Lớp đổi giờ, hủy trong ngày, bài quá hạn)
  tier1Emergency,
  /// Tier 2: Đến hạn trong hôm nay (Bài tập hạn chót hôm nay, ca học sắp diễn ra)
  tier2DueToday,
  /// Tier 3: Sự kiện tiếp theo (Lịch học ngày mai, bài kiểm tra sắp tới trong tuần)
  tier3NextEvent,
  /// Tier 4: Tổng quan / Thông tin chung không cần hành động gấp (Nhận xét mới, thông báo học vụ)
  tier4GeneralInfo,
}

enum ParentAlertType {
  overdue,          // Quá hạn
  scheduleChange,   // Thay đổi lịch học
  dueToday,         // Đến hạn hôm nay
  upcomingExam,     // Bài kiểm tra sắp tới
  announcement,     // Thông báo giáo viên/học vụ
}
```

Bổ sung các trường dữ liệu:
- `tier`: Mức ưu tiên (dùng để sắp xếp tăng dần từ Tier 1 $\rightarrow$ Tier 4).
- `childId`: ID của học sinh để hỗ trợ Deep-link.
- `targetId`: ID bài tập hoặc ID buổi học để điều hướng trực tiếp đến màn hình chi tiết tương ứng (`ParentSessionDetailScreen` hoặc `ParentHomeworkDetailScreen`).
- `timestamp`: Thời điểm tạo hoặc hạn chót để sắp xếp thứ cấp trong cùng 1 tier.

#### 1.2. Logic sắp xếp tự động (Sorting Engine)
Trong Repository hoặc Bloc:
```dart
alerts.sort((a, b) {
  // 1. So sánh Tier ưu tiên trước
  final tierCompare = a.tier.index.compareTo(b.tier.index);
  if (tierCompare != 0) return tierCompare;
  // 2. Trong cùng 1 tier, ưu tiên theo thời gian mới nhất / gần nhất
  return b.timestamp.compareTo(a.timestamp);
});
```

#### 1.3. Nâng cấp Widget `ActionRequiredSection`
- Hiển thị badge màu và icon phù hợp với từng Tier:
  - **Tier 1 (Emergency):** Accent đỏ `AchievementColors.red` / nền đỏ nhạt `0xFFFEE2E2`, icon `Icons.error_outline_rounded` hoặc `Icons.assignment_late_outlined`, tag: "Khẩn cấp" / "Quá hạn" / "Đổi lịch".
  - **Tier 2 (Due Today):** Accent cam/vàng `0xFFD97706` / nền cam nhạt `0xFFFEF3C7`, icon `Icons.alarm_rounded`, tag: "Hôm nay".
  - **Tier 3 (Next Event):** Accent xanh dương `0xFF2563EB` / nền xanh nhạt `0xFFEFF6FF`, icon `Icons.event_note_rounded`, tag: "Sắp tới".
  - **Tier 4 (General):** Accent xanh xám `0xFF64748B` / nền xám nhạt `0xFFF1F5F9`, icon `Icons.info_outline_rounded`, tag: "Thông tin".
- Nhóm thông minh: Nếu có nhiều cảnh báo, vẫn giữ summary badge ở header (ví dụ: `2 việc khẩn cấp • 1 đến hạn`).

---

### 2. Kiến trúc Khắc phục Lỗi Cục bộ (Partial Failure) & Skeleton Từng Khối

Theo quy định tại **Dòng 315–316 của `deliverable.md`**:
> *"Loading: skeleton cho từng khối, không phải toàn màn trắng.*
> *Error: mỗi khối có retry riêng - lỗi tải 'Hôm nay/Tiếp theo' không làm mất khối 'Cần xử lý' đang có sẵn."*

#### 2.1. Nâng cấp State của `ParentHomeBloc`
Thay vì chia tách toàn màn hình thành `ParentHomeLoading`, `ParentHomeSuccess`, `ParentHomeFailure`, ta chuyển sang mô hình **Compound State (Trạng thái hỗn hợp)** quản lý status độc lập cho từng phân vùng dữ liệu:

```dart
enum SectionStatus { initial, loading, success, failure }

class ParentHomeState extends Equatable {
  const ParentHomeState({
    this.children = const [],
    this.selectedChildId,
    this.childrenStatus = SectionStatus.initial,
    this.childrenErrorMessage,
    
    this.alerts = const [],
    this.alertsStatus = SectionStatus.initial,
    this.alertsErrorMessage,
    
    this.schedules = const [],
    this.schedulesStatus = SectionStatus.initial,
    this.schedulesErrorMessage,
    
    this.analytics,
    this.analyticsStatus = SectionStatus.initial,
    this.analyticsErrorMessage,
  });

  final List<FamilyScopeChild> children;
  final String? selectedChildId;
  final SectionStatus childrenStatus;
  final String? childrenErrorMessage;

  final List<ParentAlertItem> alerts;
  final SectionStatus alertsStatus;
  final String? alertsErrorMessage;

  final List<ParentScheduleItem> schedules;
  final SectionStatus schedulesStatus;
  final String? schedulesErrorMessage;

  final ParentAnalyticsData? analytics;
  final SectionStatus analyticsStatus;
  final String? analyticsErrorMessage;
  
  // copyWith helper...
}
```

#### 2.2. Sự kiện BLoC tương ứng (Granular Events)
- `ParentHomeStarted`: Khởi tạo tải danh sách trẻ và kích hoạt tải đồng thời 3 section.
- `ParentHomeChildSelected(String? childId)`: Đổi con được chọn, cập nhật lại 3 section theo con đó.
- `ParentHomeRefreshed`: Kéo xuống để làm mới (Pull-to-refresh) cả 3 section.
- `ParentHomeSectionRetried(HomeSection section)`: **Thử lại riêng từng section khi bị lỗi**, không reload toàn bộ màn hình.

#### 2.3. Thiết kế Skeleton Loading cho từng khối
1. **`ActionRequiredSkeleton`**: Khung tiêu đề mờ + 1-2 thẻ xám bo góc hiệu ứng Shimmering mờ (không làm giật trang).
2. **`UpcomingScheduleSkeleton`**: Khung tiêu đề mờ + 1 thẻ ca học mẫu với các vạch xám tượng trưng cho giờ học, tên môn, địa điểm.
3. **`LearningAnalyticsSkeleton`**: Card xám mô phỏng thanh điểm trung bình và biểu đồ tuần.

#### 2.4. Thiết kế Error Card cục bộ có nút Thử lại (Inline Error Retry)
Khi một section bị lỗi (ví dụ API Lịch học bị timeout 504):
- Header của section vẫn hiển thị bình thường.
- Nội dung bên dưới hiển thị 1 thẻ thông báo lỗi nhỏ gọn:
  ```text
  ┌─────────────────────────────────────────────────────────┐
  │ ⚠️ Không thể tải lịch học lúc này.                       │
  │    [ Thử lại 🔄 ]                                       │
  └─────────────────────────────────────────────────────────┘
  ```
- Khối "CẦN XỬ LÝ" và "PHÂN TÍCH HỌC TẬP" vẫn hiển thị trọn vẹn dữ liệu thực tế, phụ huynh vẫn xem được bài tập quá hạn của con.

---

### 3. Tinh chỉnh Presentation & Tích hợp Entry Point sang Family Insights Inbox

1. **Header Tab Home:** Giữ màu nền trắng tinh tế, logo, chuông thông báo, avatar phụ huynh.
2. **FamilyScopeSelector:** Giữ nguyên vị trí ngay dưới header trên nền `surfaceBg` để phụ huynh lọc nhanh "Tất cả các con", "Minh", "Lan".
3. **Kết nối Entry Point sang Family Insights Inbox:**
   - Trong `LearningAnalyticsCard`: Cập nhật nút text ở góc dưới bên phải card:
     - Nút cũ: `Tất cả báo cáo >`
     - Nút mới: `Xem hộp thư phân tích (${count}) >` hoặc `Xem tất cả phân tích >`
   - Khi tap vào nút này: Mở màn hình `FamilyInsightsInboxScreen`.

---

## Phần II: Phân tích Thiết kế & Kế hoạch Màn hình Family Insights Inbox

### 1. Phân tích Chi tiết Bản thiết kế (Ảnh 1)

#### 1.1. Cấu trúc giao diện & Yếu tố thị giác
Bản thiết kế `uploaded_media_1790691408545.png` bao gồm các thành phần từ trên xuống dưới:
1. **Top Bar & App Identity:** Logo 40Study, tiêu đề `PHỤ HUYNH 40STUDY / Home`, icon chuông thông báo có badge, avatar phụ huynh.
2. **Family Scope Banner:** Badge `[⭐ FAMILY SCOPE • Theo dõi 2 học sinh]` bên trái và nút tác vụ `✓✓ Đọc tất cả` bên phải.
3. **Mục Tiêu đề Màn hình:** Nút quay lại `←`, Tiêu đề lớn `Family Insights Inbox`, dòng mô tả phụ: `Phân tích học tập định kỳ từ giáo viên & hệ thống`, cùng nút icon bộ lọc `⊶`.
4. **Thanh Filter Chips (Lọc nhanh theo con):**
   - Chip 1 (Active): `Tất cả thông báo 3` (nền đen đậm bo tròn `AppRadius.borderFull`, chữ trắng).
   - Chip 2: `• Minh (Lớp 10A1) 2` (nền trắng viền xám, chấm xanh dương đại diện cho Minh).
   - Chip 3: `• Lan (Lớp 7B)` (nền trắng viền xám, chấm vàng cam đại diện cho Lan).
5. **Banner Báo cáo Tuần Tổng quan (Weekly Summary Banner):**
   - Hộp bo tròn góc mềm mại với icon biểu đồ xu hướng.
   - Tiêu đề: `Báo cáo tuần 42 hoàn tất`, phụ đề: `2 chủ đề cần chú ý • 1 cột mốc tích cực`, kèm chevron `>`.
6. **Danh sách Insight Cards (3 Card điển hình):**
   - **Thẻ 1 - Minh (Tiến bộ vượt bậc - Growth):**
     - Avatar 'M' xanh dương có chấm trạng thái xanh lá.
     - Tên con & Lớp: `Minh • 10A1`, Kỹ năng: `Đọc hiểu Tiếng Anh & Ngữ liệu`.
     - Tag: `📈 Tiến bộ vượt bậc` (màu xanh lá emerald), thời gian: `2 giờ trước`.
     - Đoạn nhận định (Observation & Interpretation): Nêu bật cải thiện ở dạng bài Đọc hiểu, nhanh hơn 20% thời lượng, suy luận chính xác 9/10 câu.
     - 2 Hộp số liệu bằng chứng (Quantitative Evidence):
       - `TỶ LỆ CHÍNH XÁC`: `90%` (+15%)
       - `THỜI GIAN ĐỌC`: `14 phút` (-3.5m)
     - Link CTA: `Xem chi tiết bài thi & gợi ý luyện tập →`
   - **Thẻ 2 - Lan (Cần chú ý - Area for Improvement):**
     - Avatar 'L' cam có chấm cam.
     - Tên con & Lớp: `Lan • 7B`, Kỹ năng: `Viết luận / Ngữ văn chuyên sâu`.
     - Tag: `⚠️ Cần chú ý` (màu vàng cam amber), thời gian: `Hôm qua`.
     - Nhận định: Điểm viết luận xã hội thấp hơn kỳ vọng, cần củng cố phương pháp phân tách luận điểm.
     - **Callout Box (Lời nhắn của Giáo viên bộ môn):** Viền trái màu cam, nền vàng kem, icon ghi chú kèm trích dẫn nguyên văn lời dặn của giáo viên dặn gia đình nhắc bé dành 20 phút viết thử.
     - Link CTA: `Xem lộ trình bổ trợ kỹ năng viết →`
   - **Thẻ 3 - Minh (Khen thưởng / Thói quen học tập - Discipline & Habit):**
     - Tag: `🏆 Khen thưởng` (màu xanh dương cobalt), thời gian: `3 ngày trước`.
     - Nhận định: Duy trì xuất sắc chuỗi chuyên cần 5 ngày liên tiếp, 100% bài tập đúng hạn.
     - Khối biểu diễn chuỗi ngày học: Các nút tròn T2, T3, T4, T5, T6 màu xanh nổi bật kèm badge ngọn lửa `🔥 Chuỗi 5 ngày`.
     - Nút hành động tương tác chính (Primary Action Button): `[ 💙 Gửi lời khen & khích lệ Minh ]` màu xanh dương đậm rực rỡ.
7. **Footer / Micro-Coaching Tip:**
   - Thẻ gợi ý với icon bóng đèn: `Gợi ý đồng hành cùng con - Khen ngợi nỗ lực cụ thể thay vì chỉ tập trung vào điểm số giúp con tự tin hơn trong các bài luận...`

---

#### 1.2. Ưu điểm nổi bật (Sức mạnh UX)
1. **Đúng chuẩn tinh thần Family Scope:** Không bắt phụ huynh phải chuyển đổi qua lại giữa các màn hình để xem tình hình từng con. Mọi thông tin được tổng hợp trên một feed, nhưng vẫn lọc nhanh được theo con khi cần.
2. **Cấu trúc 3 nhóm Insight chuẩn khoa học sư phạm:**
   - *Tiến bộ vượt bậc*: Tôn vinh điểm mạnh.
   - *Cần chú ý*: Cảnh báo kịp thời trước khi hổng kiến thức.
   - *Khen thưởng/Thói quen*: Nuôi dưỡng tính kỷ luật học tập.
3. **Bằng chứng số liệu định lượng (Quantitative Evidence):** Thay vì chỉ nói cảm tính "Minh học tốt hơn", thiết kế đưa ra số liệu rõ ràng: 90% (+15%), 14 phút (-3.5m). Phụ huynh hoàn toàn tin tưởng vào hệ thống đánh giá.
4. **Tính nhân văn và gắn kết gia đình:** Nút `[ Gửi lời khen & khích lệ Minh ]` và lời dặn giáo viên giúp phụ huynh trở thành người bạn đồng hành tích cực cùng con, không can thiệp thô bạo vào việc học của con.

---

#### 1.3. Nhược điểm & Đề xuất Cải tiến Hoàn thiện

| Điểm hiện tại trong ảnh | Vấn đề UX / Kỹ thuật | Đề xuất giải pháp cải tiến |
|---|---|---|
| **Nền màn hình trắng tuyền (`Colors.white`)** | Các card nội dung cũng có màu trắng, khiến giao diện bị phẳng, ranh giới giữa các card kém rõ nét, lạm dụng viền border xám. | Đưa nền về `surfaceBg` (pha nhẹ primary `0.045`) tương tự Home và Schedule. Các thẻ Card màu trắng tinh khiết đổ bóng nhẹ sẽ nổi bật, sang trọng và đồng bộ hệ thống. |
| **Quá nhiều tầng Header (Header Overload)** | Chiếm gần 40% chiều cao màn hình: App bar $\rightarrow$ Banner Family Scope $\rightarrow$ Sub-header $\rightarrow$ Filter Chips $\rightarrow$ Weekly Banner khiến người dùng phải cuộn mới thấy card đầu tiên. | Tinh giản App Bar khi mở Inbox: Dùng một Top Header gọn gàng với nút Back `←`, Tiêu đề `Family Insights Inbox`, icon lọc & đánh dấu đã đọc. Banner tuần thu gọn vừa vặn. |
| **Hành vi nút "Gửi lời khen & khích lệ"** | Chưa định nghĩa trạng thái sau khi bấm (State feedback). Nếu bấm nhiều lần có bị spam không? | Khi bấm nút, hiển thị bottom sheet/dialog chọn lời khen ngắn (hoặc gửi ngay kèm Haptic feedback), sau đó nút chuyển sang trạng thái: `✓ Đã gửi lời khích lệ` (disabled/secondary style). |
| **Điều hướng CTA Links** | Chưa làm rõ `Xem chi tiết bài thi...` hoặc `Xem lộ trình...` sẽ mở màn hình nào. | Áp dụng quy tắc **Deep Link Override** trong `deliverable.md`: Chuyển active child trong App Scope sang con tương ứng và mở màn hình chi tiết bài kiểm tra / Tab Học tập (Learning). |
| **Trạng thái rỗng & Tải dữ liệu** | Chưa có layout khi danh sách trống hoặc khi mất kết nối mạng. | Thiết kế Skeleton list shimmer và Empty State "Chưa có phân tích mới cho các con". |

---

### 2. Thiết kế Kiến trúc Dữ liệu (Data Models)

Tạo file model mới tại: `mobile/lib/features/parent/data/models/family_insight_item.dart`

```dart
/// Phân loại insight định kỳ
enum FamilyInsightCategory {
  breakthrough,  // Tiến bộ vượt bậc (Xanh lá)
  attention,     // Cần chú ý (Vàng/Cam)
  reward,        // Khen thưởng / Thói quen (Xanh dương)
}

/// Dữ liệu số liệu định lượng (Metrics Evidence)
class InsightMetric {
  const InsightMetric({
    required this.label,
    required this.value,
    this.delta,
    this.isPositive = true,
  });

  final String label;      // Ví dụ: TỶ LỆ CHÍNH XÁC
  final String value;      // Ví dụ: 90%
  final String? delta;     // Ví dụ: +15%
  final bool isPositive;
}

/// Thông tin chuỗi ngày học tập (Streak)
class InsightStreakInfo {
  const InsightStreakInfo({
    required this.currentDays,
    required this.activeWeekdays, // [2, 3, 4, 5, 6] tương ứng T2 - T6
  });

  final int currentDays;
  final List<int> activeWeekdays;
}

/// Model đầy đủ cho 1 thẻ Insight trong Family Insights Inbox
class FamilyInsightItem {
  const FamilyInsightItem({
    required this.id,
    required this.childId,
    required this.childName,
    required this.className,
    required this.subjectOrSkill,
    required this.category,
    required this.timeAgoText,
    required this.title,
    required this.description,
    this.highlightText,
    this.metrics = const [],
    this.teacherQuote,
    this.streakInfo,
    this.hasEncouraged = false,
    this.actionLabel,
    this.actionRoute,
    this.isRead = false,
  });

  final String id;
  final String childId;
  final String childName;
  final String className;
  final String subjectOrSkill;
  final FamilyInsightCategory category;
  final String timeAgoText;
  final String title;
  final String description;
  final String? highlightText;
  
  // Dữ liệu cho các khối đặc thù:
  final List<InsightMetric> metrics;     // Dùng cho Category.breakthrough
  final String? teacherQuote;             // Dùng cho Category.attention
  final InsightStreakInfo? streakInfo;   // Dùng cho Category.reward
  final bool hasEncouraged;              // Trạng thái đã bấm nút gửi lời khen chưa
  
  // Điều hướng:
  final String? actionLabel;             // Ví dụ: "Xem chi tiết bài thi & gợi ý luyện tập →"
  final String? actionRoute;
  final bool isRead;

  FamilyInsightItem copyWith({
    bool? hasEncouraged,
    bool? isRead,
  }) {
    return FamilyInsightItem(
      id: id,
      childId: childId,
      childName: childName,
      className: className,
      subjectOrSkill: subjectOrSkill,
      category: category,
      timeAgoText: timeAgoText,
      title: title,
      description: description,
      highlightText: highlightText,
      metrics: metrics,
      teacherQuote: teacherQuote,
      streakInfo: streakInfo,
      hasEncouraged: hasEncouraged ?? this.hasEncouraged,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
      isRead: isRead ?? this.isRead,
    );
  }
}
```

---

### 3. Thiết kế Quản lý Trạng thái (BLoC State Management)

Tạo BLoC mới tại: `mobile/lib/features/parent/bloc/insights_inbox/`
- `family_insights_inbox_bloc.dart`
- `family_insights_inbox_event.dart`
- `family_insights_inbox_state.dart`

#### Events:
- `FamilyInsightsInboxStarted()`: Tải dữ liệu ban đầu.
- `FamilyInsightsFilterChanged(String? childId)`: Đổi bộ lọc con (null = Tất cả, hoặc `childId` cụ thể).
- `FamilyInsightsMarkAllAsRead()`: Đánh dấu tất cả là đã đọc.
- `FamilyInsightsSendEncouragement(String insightId)`: Gửi lời khen ngợi cho học sinh.
- `FamilyInsightsInboxRefreshed()`: Kéo xuống để refresh.

#### States:
- `FamilyInsightsInboxInitial`
- `FamilyInsightsInboxLoading`
- `FamilyInsightsInboxSuccess`:
  - `insights`: Danh sách insight đã lọc theo `selectedChildId`.
  - `allInsights`: Danh sách gốc để tính số lượng badge cho từng filter chip.
  - `children`: Danh sách con để render filter chips.
  - `selectedChildId`: Con đang được lọc (null = tất cả).
  - `unreadCount`: Số lượng insight chưa đọc.
  - `encouragedIds`: Tập các ID đã được phụ huynh gửi lời khích lệ.
- `FamilyInsightsInboxFailure(String message)`

---

### 4. Thiết kế Giao diện (Presentation Layer & Component Specs)

Thư mục: `mobile/lib/features/parent/presentation/insights_inbox/`
- `family_insights_inbox_screen.dart`: Màn hình chính.
- `widgets/insights_inbox_app_bar.dart`: Header với Back, Tiêu đề, Badge đếm và nút "Đọc tất cả".
- `widgets/insights_child_filter_bar.dart`: Thanh filter chips nằm ngang (Nền đen cho Tất cả, Chấm xanh cho Minh, Chấm cam cho Lan).
- `widgets/insights_weekly_summary_card.dart`: Thẻ tóm tắt tuần (Tuần 42, 2 chú ý, 1 tích cực).
- `widgets/insight_card_item.dart`: Thẻ card insight thông minh tự render theo category:
  - Header: Avatar con + Tên/Lớp + Kỹ năng + Tag + Thời gian.
  - Body: Đoạn văn phân tích với TextSpan highlight đậm.
  - Conditional Section 1: 2 Stats pills tỷ lệ chính xác & thời gian.
  - Conditional Section 2: Callout quote của giáo viên (icon ghi chú, viền cam).
  - Conditional Section 3: Visual streak tuần (T2-T6) + Nút `Gửi lời khen & khích lệ`.
  - Footer Link: Text link màu primary có mũi tên `→`.
- `widgets/insights_coach_tip_card.dart`: Thẻ gợi ý phương pháp đồng hành cùng con ở cuối danh sách.
- `widgets/insights_inbox_skeleton.dart`: Hiệu ứng shimmer khi đang tải dữ liệu.

---

### 5. Tương tác Người dùng & Điều hướng (Navigation & Interactions)

1. **Từ Tab Home vào Inbox:**
   - Phụ huynh ấn vào `Tất cả báo cáo >` trong thẻ Phân tích học tập ở Home $\rightarrow$ `Navigator.push` mở `FamilyInsightsInboxScreen`.
2. **Gửi lời khen & khích lệ:**
   - Khi phụ huynh nhấn `[ 💙 Gửi lời khen & khích lệ Minh ]`:
     - Bắn event `FamilyInsightsSendEncouragement`.
     - Hiển thị SnackBar chúc mừng: *"Đã gửi lời khen ngợi tới Minh! Con sẽ nhận được thông báo khích lệ trên ứng dụng."*
     - Nút tự động chuyển thành: `[ ✓ Đã gửi lời khích lệ ]` với style nền xám nhạt, viền mờ.
3. **Deep Link Override:**
   - Khi phụ huynh nhấn `Xem chi tiết bài thi & gợi ý luyện tập →`:
     - Nếu chuyển sang Tab Học tập hoặc bài thi của Minh, hệ thống tự động gán active child là `Minh` để bảo đảm không bị xung đột dữ liệu.

---

## 4. Lộ trình Triển khai Chi tiết (Phased Execution Plan)

### Giai đoạn 1: Nâng cấp Tab Home (4 Tiers Priority & Partial Failure)
- [x] **Bước 1.1:** Cập nhật `ParentAlertItem` bổ sung `ParentAlertTier` và mở rộng `ParentAlertType` (dueToday, upcomingExam, announcement). Cập nhật mapper và mock fallback trong `ParentHomeRepositoryImpl`.
- [x] **Bước 1.2:** Cải tiến `ParentHomeState` và `ParentHomeBloc` sang kiến trúc Partial Failure (quản lý riêng `alertsStatus`, `schedulesStatus`, `analyticsStatus`) và hỗ trợ `ParentHomeSectionRetried`.
- [x] **Bước 1.3:** Xây dựng Skeleton loading và Inline Error Card cho từng section (`ActionRequiredSection`, `UpcomingScheduleSection`, `LearningAnalyticsCard`).
- [x] **Bước 1.4:** Cập nhật UI `ActionRequiredSection` hiển thị chính xác 4 Tiers với màu sắc và tag tương ứng. Đảm bảo giữ nguyên `FamilyScopeSelector`.
- [x] **Bước 1.5:** Chạy kiểm thử linter (`flutter analyze`) và commit: `feat(parent-home): nang cap 4 muc uu tien can xu ly va partial failure per-section`.

### Giai đoạn 2: Xây dựng Core & Data cho Family Insights Inbox
- [x] **Bước 2.1:** Tạo các Data Models (`FamilyInsightItem`, `FamilyInsightCategory`, `InsightMetric`, `InsightStreakInfo`).
- [x] **Bước 2.2:** Xây dựng `FamilyInsightsRepository` & `FamilyInsightsRepositoryImpl` (hỗ trợ preview fallback theo đúng dữ liệu trong ảnh thiết kế: Minh đọc hiểu, Lan viết luận, Minh chuyên cần).
- [x] **Bước 2.3:** Xây dựng `FamilyInsightsInboxBloc`, Events và States.
- [x] **Bước 2.4:** Đăng ký Repository & BLoC vào `di_container.dart` / `di_repository_module.dart`.

### Giai đoạn 3: Xây dựng Giao diện Family Insights Inbox (UI/UX)
- [x] **Bước 3.1:** Xây dựng Header (`insights_inbox_app_bar.dart`) và Thanh Filter con (`insights_child_filter_bar.dart`).
- [x] **Bước 3.2:** Xây dựng `insights_weekly_summary_card.dart` và `insights_coach_tip_card.dart`.
- [x] **Bước 3.3:** Xây dựng `insight_card_item.dart` với đầy đủ 3 phong cách (Tiến bộ vượt bậc, Cần chú ý với quote giáo viên, Khen thưởng với streak & nút tương tác).
- [x] **Bước 3.4:** Hoàn thiện màn hình chính `FamilyInsightsInboxScreen`, tích hợp Pull-to-refresh, Skeleton loading và Empty state. Áp dụng nền `surfaceBg` cao cấp.
- [x] **Bước 3.5:** Kết nối nút mở màn hình từ `LearningAnalyticsCard` trên Tab Home.

### Giai đoạn 4: Kiểm thử, Tối ưu & Hoàn thiện
- [x] **Bước 4.1:** Kiểm tra responsive kích thước chữ, khoảng cách padding, độ mượt khi filter theo con.
- [x] **Bước 4.2:** Chạy `flutter analyze` bảo đảm 0 lỗi trong module tính năng.
- [x] **Bước 4.3:** Commit bằng tiếng Việt theo từng bước hoàn thành.

### Giai đoạn 5: Ghim thanh chọn con (Pinned Header) & Chia nhóm thông tin từng con ở Home & Inbox
- [x] **Bước 5.1:** Xây dựng `PinnedFamilyScopeHeaderDelegate` và ghim `FamilyScopeSelector` (`SliverPersistentHeader(pinned: true)`) trên Tab Home, Tab Lịch học và Family Insights Inbox giúp phụ huynh đổi con tức thì khi cuộn trang.
- [x] **Bước 5.2:** Đồng bộ thanh chọn con ở Family Insights Inbox từ chip đen trắng sang `FamilyScopeSelector` chuẩn dùng chung.
- [x] **Bước 5.3:** Xây dựng component `ChildGroupSubHeader` (Avatar tròn + Tên con + Lớp + Badge số lượng item) dùng chung cho các màn hình.
- [x] **Bước 5.4:** Cập nhật khối "Cần xử lý" (`ActionRequiredSection`) ở Tab Home: chia nhóm theo từng con khi ở chế độ "Tất cả các con", duy trì 4 Tiers ưu tiên trong từng con.
- [x] **Bước 5.5:** Cập nhật khối "Hôm nay / Tiếp theo" (`UpcomingScheduleSection`) ở Tab Home: chia nhóm các ca học theo từng con khi ở chế độ "Tất cả các con".
- [x] **Bước 5.6:** Nâng cấp thẻ "Phân tích học tập" (`LearningAnalyticsCard`): hiển thị tổng quan của cả Minh & Lan song song khi chọn "Tất cả các con", kích hoạt nút *"Xem phân tích của [Tên con] ->"* mở trực tiếp Family Insights Inbox tương ứng của con đó.
- [x] **Bước 5.7:** Kiểm thử linter (`flutter analyze`), hoàn thành và commit code: `feat(parent): ghim thanh chon con va chia nhom thong tin tung con o Home va Inbox`.

---

## 5. Kế hoạch Kiểm thử & Tiêu chuẩn Nghiệm thu (Acceptance Criteria)

| Thành phần | Tiêu chuẩn Nghiệm thu (Pass / Fail) |
|---|---|
| **Tab Home - 4 Tiers** | - Các mục khẩn cấp/quá hạn (Tier 1) luôn hiển thị đầu tiên.<br>- Mục đến hạn hôm nay (Tier 2) hiển thị kế tiếp với tag màu cam.<br>- Các mục sắp tới (Tier 3) và thông tin (Tier 4) xếp phía sau.<br>- Thanh chọn con `FamilyScopeSelector` vẫn hoạt động ổn định. |
| **Tab Home - Partial Failure** | - Giả lập lỗi API lịch học: Khối lịch hiển thị thẻ lỗi kèm nút "Thử lại", khối "Cần xử lý" và "Phân tích học tập" vẫn tải và hiển thị bình thường.<br>- Ấn "Thử lại" ở khối lịch: Chỉ reload lịch học, không giật màn hình. |
| **Tab Home - Chia nhóm con** | - Chọn "Tất cả các con": Khối Cần xử lý, Lịch học và Phân tích học tập đều tự động nhóm thông tin dưới subheader của từng con.<br>- Chọn 1 con cụ thể: Ẩn subheader, hiển thị trực diện danh sách của con đó.<br>- Nút "Xem phân tích của con" mở Inbox đã lọc đúng con được chọn. |
| **Thanh chọn con Ghim (Pinned)** | - Khi cuộn xuống ở Home, Lịch học hoặc Inbox: Header chính cuộn trôi đi, chỉ ghim duy nhất thanh chọn con ở mép trên cùng kèm shadow nhẹ.<br>- Chuyển đổi con tức thì mà không cần cuộn ngược lên đỉnh. |
| **Family Insights Inbox - Filter** | - Dùng thanh chọn con đồng bộ `FamilyScopeSelector`.<br>- Chọn "Tất cả": Hiển thị cả 3 thông báo (Minh & Lan).<br>- Chọn "Minh": Chỉ hiển thị 2 thông báo của Minh.<br>- Chọn "Lan": Chỉ hiển thị 1 thông báo của Lan. |
| **Family Insights Inbox - Thẻ Card** | - Thẻ Tiến bộ: Hiển thị 2 pill số liệu 90% (+15%) và 14 phút (-3.5m).<br>- Thẻ Cần chú ý: Hiển thị quote lời dặn giáo viên có viền cam nổi bật.<br>- Thẻ Khen thưởng: Hiển thị dãy T2-T6 và badge chuỗi 5 ngày.<br>- Bấm "Gửi lời khen": SnackBar xuất hiện, nút đổi trạng thái thành "Đã gửi". |
| **Giao diện & Thẩm mỹ** | - Nền màn hình sử dụng `surfaceBg` đồng bộ, các card màu trắng nổi bật rõ ràng, không bị chìm như nền trắng tuyền.<br>- Không có lỗi tràn màn hình (overflow) trên mọi kích thước. |

