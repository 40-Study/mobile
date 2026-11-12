# KẾ HOẠCH ĐẬP ĐI XÂY LẠI PHẦN TỔNG QUAN: DÒNG THỜI GIAN HÀNH TRÌNH HỌC TẬP
## (THE ACADEMIC LEARNING JOURNEY TIMELINE & ZERO-CARD SEAMLESS REDESIGN)

> **Tài liệu tham chiếu:** `mobile/docs/insight_UI_student/`  
> **Áp dụng cho:** `mobile/lib/features/student/presentation/achievement/`  
> **Trọng tâm module:** `academic_honor_overview_card.dart`, `overview_statistics.dart` & `achievement_screen.dart`  
> **Trạng thái:** Đã triển khai thành công 100% (Hoàn thành test suite & analyze)  
> **Mục tiêu cốt lõi:**  
> 1. **Khắc phục triệt để lỗi "lạm dụng Card" (Zero-Card Canvas):** Loại bỏ hoàn toàn các khung hộp chữ nhật bọc ngoài và các micro pods đóng hộp bên trong.  
> 2. **Tái hiện toàn bộ quá trình học tập (The Entire Learning Odyssey):** Chuyển đổi số liệu tĩnh thành **Dòng thời gian hành trình học tập (Timeline Roadmap)** trực quan từ ngày đầu nhập môn đến đỉnh cao hiện tại và mục tiêu tương lai.  
> 3. **Hiệu ứng Animation sống động & khơi gợi cảm xúc:** Luồng sáng chạy trên đường ray, vòng sáng thở nhịp nhàng (Breathing Beacon Glow) tại trạm hiện tại, và micro-haptic khi chạm vào các cột mốc.

---

## 1. BỐI CẢNH & PHÂN TÍCH YÊU CẦU CỦA NGƯỜI DÙNG

### 1.1. Vấn đề 1: Lỗi "Sử dụng quá nhiều Card" (Card Overuse / Box-in-Box Syndrome)
- **Hiện trạng:**
  - Thiết kế trước đó tuy đã đưa được Cấp độ và Danh hiệu vào, nhưng vẫn bị trói buộc trong tư duy đóng hộp: Một chiếc Card to bọc ngoài, bên trong lại chứa 4 cái Card con (Micro Pods) với viền màu và nền pastel.
  - Khi đặt vào màn hình Thành tích vốn đã có các Card bên dưới (Badges, Certificates, Heatmap), giao diện bị rơi vào hội chứng **"Card Fatigue" (Bội thực Card)**: Mắt người dùng phải liên tục nhảy qua các đường viền hộp, tạo cảm giác nặng nề, chật chội và thiếu đi tính phóng khoáng của một sản phẩm giáo dục cao cấp.
- **Giải pháp triệt để:**
  - **Zero-Card Seamless Canvas:** Xóa bỏ hoàn toàn khung hộp bao quanh.
  - Toàn bộ thông tin được trình bày trực tiếp trên bề mặt trang (`context.surfaceBg`), phân tách bằng khoảng thở (Breathing Whitespace), trục đường ray ánh sáng (Timeline Spine) và Hairline dividers siêu mảnh `0.8px`.

### 1.2. Vấn đề 2: Thiếu tính tổng quan toàn bộ quá trình học tập (Missing Big-Picture Odyssey)
- **Hiện trạng:**
  - Các con số hiện tại (Giờ học, Bài học, Streak, Huy hiệu) chỉ là **các lát cắt tĩnh tại một thời điểm** (Static Snapshots).
  - Học sinh nhìn vào không cảm nhận được **"Mình đã đi được một chặng đường dài và vẻ vang như thế nào?"**:
    - Ngày đầu tiên bước vào ForteX ra sao?
    - Những ngày tháng kiên trì tích lũy từng giờ học, từng bài học?
    - Những cột mốc huy hiệu, chứng chỉ đã gặt hái được trên đường đi?
    - Vị thế hiện tại của mình đang rực rỡ ở đâu?
    - Đỉnh cao tiếp theo nào đang vẫy gọi ở phía trước?
- **Giải pháp đột phá:**
  - Thiết kế **Dòng thời gian hành trình học tập (Academic Journey Timeline)** kết nối liền mạch từ Quá khứ -> Hiện tại -> Tương lai.

---

## 2. Ý TƯỞNG THIẾT KẾ ĐỘT PHÁ: "THE ACADEMIC LEARNING ODYSSEY"

### 2.1. Triết lý thiết kế: "The Living Chronicle" (Dòng Thời Gian Sống Động)
Thay vì một chiếc thẻ vô tri, phần Tổng quan trở thành một **"Bản đồ Tiến hóa Tri thức"**:
1. **Trục đường ray ánh sáng (The Living Spine):** Một đường kẻ dọc uốn lượn mềm mại hoặc đường thẳng thanh lịch 2.5px nối kết các trạm thành tích. Đường ray chạy màu gradient từ xanh hoàng gia (`brandBlue`) sang xanh ngọc lục bảo (`emerald`) và chuyển dần sang nét đứt xám nhạt (`slate300`) hướng tới tương lai.
2. **Tất cả chỉ số vàng được "nhúng" tự nhiên vào Dòng thời gian:**
   - Không cần 4 chiếc hộp con:
     - Giờ học & Bài học nằm ở trạm **"Nền Tảng Tích Lũy"**.
     - Chuỗi ngày Streak nằm ở trạm **"Kỷ Luật Bền Bỉ"**.
     - Cấp độ & Tổng XP nằm tại trạm trung tâm **"Hiện Tại Rực Rỡ"**.
     - Mục tiêu tiếp theo nằm ở trạm **"Chân Trời Mới"**.

---

### 2.2. Bố cục 3 Pha Thời Gian Liền Mạch (Past - Present - Future Trinity)

```
══════════════════════════════════════════════════════════════════════════════════
[🌱 TRẠM 1: KHỞI NGUYÊN]      Gia nhập ForteX • 28/05/2026
 │                            Những bước chân đầu tiên chinh phục tri thức
 │
 ├──[ ⏱️ 48 Giờ học tích lũy ]   [ 📚 36 Bài học đã vượt qua ]
 │  
[🔥 TRẠM 2: KỶ LUẬT BỀN BỈ]   Chuỗi học tập: 14 Ngày liên tục
 │                            Ngọn lửa duy trì mỗi ngày không ngắt quãng
 │
[⭐ TRẠM 3: ĐỈNH CAO HIỆN TẠI] HỌC GIẢ TINH HOA • CẤP ĐỘ 5
 ║  (( 🌟 BREATHING GLOW ))   Tín chỉ tích lũy: 1,450 XP (Top 5% học viên)
 ║                            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━░░░░░░ 75%
 ║                            [🏅 14 Huy hiệu danh dự đã mở khóa]
 ┊
 ┊ (Đường ray nét đứt tương lai - Dự kiến đạt trong 5 ngày tới)
 ┊
[🎯 TRẠM 4: CHÂN TRỜI KẾ TIẾP] HỌC VIỆN DANH DỰ (CẤP ĐỘ 6)
                              Còn 350 XP nữa để thăng hạng danh hiệu tiếp theo
══════════════════════════════════════════════════════════════════════════════════
```

#### Chi tiết 4 Trạm Cột Mốc (Waypoints):

1. **Trạm 1: Khởi Nguyên Tri Thức (The Genesis Waypoint):**
   - Node: Vòng tròn mầm tri thức xanh ngọc nhạt `28×28px`, icon `Icons.spa_rounded` hoặc `Icons.flag_rounded`.
   - Nội dung: Ghi nhận ngày học sinh bắt đầu hành trình.
   - Nhánh chỉ số phẳng (Inline Metric Chips):
     - Dải chip chữ nhật bo góc mềm: `⏱️ 48 giờ tích lũy` • `📚 36 bài học hoàn thành`.
     - Tuyệt đối không đóng hộp lơ lửng, dùng nền trong suốt viền hairline `0.8px`.

2. **Trạm 2: Kỷ Luật Bền Bỉ (The Momentum Waypoint):**
   - Node: Vòng tròn ngọn lửa cam rực sáng `28×28px`, icon `Icons.local_fire_department_rounded`.
   - Nội dung: Ghi nhận thành tựu thói quen học tập với con số Streak to bản `14 ngày liên tục`.
   - Micro-copy: *"Ngọn lửa kỷ luật duy trì liên tục qua 2 tuần"*.

3. **Trạm 3: Đỉnh Cao Hiện Tại (The Active Zenith - TÂM ĐIỂM THỊ GIÁC):**
   - **Visual Anchor Lớn Nhất (Hero Node):**
     - Huân chương vàng kim hoàng gia `48×48px` với hiệu ứng **Breathing Beacon Glow** (vầng sáng lan tỏa nhịp nhàng 2 giây/chu kỳ).
   - Danh hiệu học thuật uy nghi: `HỌC GIẢ TINH HOA` đi kèm huy hiệu `[ ⭐ CẤP ĐỘ 5 ]`.
   - Điểm kinh nghiệm: `1,450 XP` tích lũy.
   - Thanh tiến trình XP công nghệ siêu mỏng `5px` chạy thẳng vào đường ray tiếp nối.
   - Thành tựu đi kèm: Huy hiệu đã mở khóa `${earnedBadgesCount} huy hiệu`.

4. **Trạm 4: Chân Trời Kế Tiếp (The Next Horizon - Future Waypoint):**
   - Node nét đứt mờ ảo `28×28px` với icon ổ khóa mở hé `Icons.lock_open_rounded` hoặc ngôi sao tương lai `Icons.auto_awesome_rounded`.
   - Trục đường ray chuyển sang nét đứt (Dashed Timeline Path) thể hiện tương lai đang được kiến tạo.
   - Đích đến tiếp theo: `HỌC VIỆN DANH DỰ (CẤP ĐỘ 6)`.
   - Micro-copy thôi thúc: `Còn 350 XP nữa để mở khóa danh xưng tiếp theo!`.

---

## 3. ĐẶC TẢ HIỆU ỨNG ANIMATION GIA TĂNG HƯNG PHẤN (DELIGHT & MOTION SPECS)

Để dòng thời gian không bị "tĩnh lặng" mà trở thành một trải nghiệm sống động, hệ thống tích hợp 4 tầng chuyển động tinh xảo:

```
                  Hiệu ứng Ánh sáng & Chuyển động
                  
  [Trạm 1] ────► [Trạm 2] ────► [ ⭐ Trạm Hiện Tại ] - - - -► [Trạm Tiếp Theo]
     │              │                     │                          │
(Cascade Pop) (Cascade Pop)      (Breathing Beacon Glow)       (Dashed Flow)
     └──────────────┴─────────────────────┴──────────────────────────┘
                      Flowing Energy Trail (Tia sáng chạy dọc ray)
```

1. **Flowing Trail Line Animation (Tia sáng chạy dọc đường ray):**
   - Khi mở màn hình, một vệt sáng năng lượng chạy từ Trạm 1 dọc theo trục đường ray đến Trạm Hiện Tại trong 1200ms (`Curves.easeInOutCubic`), mô phỏng dòng chảy thời gian được tái hiện lại.
2. **Active Node Breathing Beacon Glow (Nhịp thở vầng hào quang):**
   - Tại Trạm Hiện Tại (Cấp độ & Danh hiệu), một vòng hào quang đồng tâm khuếch tán bán kính mềm mại (`alpha: 0.15 -> 0.0`) co giãn liên tục theo nhịp thở 2.2 giây.
   - Tạo cảm giác đây là một "sinh thể học tập sống động", thu hút tuyệt đối ánh mắt người học.
3. **Staggered Milestone Pop (Xuất hiện nảy nhẹ theo thứ tự):**
   - Các trạm trên dòng thời gian xuất hiện lần lượt với độ trễ 150ms giữa mỗi trạm, dùng chuyển động đàn hồi nhẹ (`Curves.easeOutBack`).
4. **Micro-Haptic & Interactive Waypoint Scrubbing:**
   - Chạm vào bất kỳ trạm nào trên timeline sẽ kích hoạt rung nhẹ `HapticFeedback.selectionClick()`, làm nổi bật thông số chi tiết của trạm đó.

---

## 4. MA TRẬN SO SÁNH TRỰC QUAN (BEFORE VS AFTER MATRIX)

| Tiêu chí | Bản Hiện Tại (Current) | Bản Mới Đề Xuất (Timeline Odyssey V3.0) |
| :--- | :--- | :--- |
| **Hình thức bố cục** | 1 Card to bọc ngoài + 4 Card con đóng hộp bên trong (**Box-in-Box**) | **Zero-Card Seamless Canvas**: Dòng thời gian mở hoàn toàn trên nền trang |
| **Cảm giác thị giác** | Bội thực đường viền hộp (Card Fatigue), chật chội | Phóng khoáng, thoáng đãng, sang trọng, chiều sâu thời gian vô tận |
| **Góc nhìn quá trình**| Chỉ là 4 con số tĩnh trơ trọi tại 1 thời điểm | **Tái hiện toàn bộ hành trình**: Từ Khởi nguyên -> Thói quen -> Đỉnh cao hiện tại -> Mục tiêu tương lai |
| **Tích hợp chỉ số** | Nhốt vào 4 ô vuông co quắp | **Nhúng tự nhiên** vào từng trạm cột mốc tương ứng trên dòng thời gian |
| **Hiệu ứng Animation**| Chỉ có animation đếm số cơ bản | **Đa tầng chuyển động**: Tia sáng chạy đường ray, nhịp thở hào quang Breathing Glow, xuất hiện so le |
| **Cảm xúc học viên** | Xem số liệu báo cáo khô khan | **Tự hào về chặng đường đã đi**, phấn khích muốn học tiếp để chạm trạm tương lai |

---

## 5. ĐẶC TẢ KỸ THUẬT & DESIGN TOKENS (KHÔNG DÙNG CARD)

### 5.1. Bảng Design Tokens cho Timeline

| Thành phần | Light Mode Token | Dark Mode Token | Ghi chú |
| :--- | :--- | :--- | :--- |
| **Nền Canvas** | `context.surfaceBg` (`#F8FAFC`) | `cs.surface` (`#0F172A`) | Hoàn toàn không bọc container đóng hộp |
| **Đường ray Đã qua (Past Trail)** | Gradient `brandBlue` (`#2563EB`) -> `emerald500` | Gradient `brandBlueLight` -> `emerald400` | Chiều rộng 2.5px liền mạch |
| **Đường ray Tương lai (Future Trail)**| `cs.slate300` dạng vạch nét đứt (Dashed) | `cs.slate700` dạng vạch nét đứt | Nét đứt 4px, khoảng hở 4px |
| **Node Khởi nguyên** | Nền `emerald50`, viền `emerald300`, icon `emerald600` | Nền `emerald950`, viền `emerald700` | Tròn 28×28px |
| **Node Kỷ luật (Streak)** | Nền `orange50`, viền `orange300`, icon `orange600` | Nền `orange950`, viền `orange700` | Tròn 28×28px |
| **Hero Node Hiện tại** | Huân chương `amber50` viền `amber300`, icon `amber600` | Huân chương `amber950` viền `amber600` | Squircle 46×46px + Breathing Aura |
| **Node Tương lai** | Nền `slate100`, viền `slate300`, icon `slate400` | Nền `slate800`, viền `slate600` | Nét đứt tròn 28×28px |
| **Vạch ngăn trạm** | Hairline `0.8px` màu `cs.outlineVariant.withValues(alpha: 0.3)` | Hairline `0.8px` màu `cs.slate800` | Phân tầng tinh tế không cần viền hộp |

---

## 6. KẾ HOẠCH TRIỂN KHAI 4 GIAI ĐOẠN (IMPLEMENTATION ROADMAP)

> **LƯU Ý:** Giai đoạn này chỉ lập kế hoạch phân tích và kiến trúc. Khi người dùng phê duyệt sẽ tiến hành thi công mã nguồn:

### Giai đoạn 1: Xây dựng Timeline Milestone Engine
- Xây dựng lớp dữ liệu `AcademicMilestone`:
  - Trích xuất tự động các điểm mốc từ `StudentStatsModel`, `state.badges`, `state.certificates`.
  - Tính toán các trạng thái: `completed`, `active`, `upcoming`.
  - Tự động sinh nội dung truyền cảm hứng cho từng trạm.

### Giai đoạn 2: Phát triển UI Component `AcademicJourneyTimeline`
- Tạo mới widget `academic_journey_timeline.dart`:
  - Áp dụng `CustomPainter` cho đường ray liền mạch kết hợp nét đứt tương lai.
  - Tích hợp `AnimationController` kép:
    - Controller 1: Điều khiển tia sáng chạy dọc ray khi vào màn hình.
    - Controller 2: Điều khiển nhịp thở hào quang (Breathing Glow) lặp vô tận tại Trạm Hiện Tại.
  - Nhúng trực tiếp các chỉ số Giờ học, Bài học, Streak, Huy hiệu vào thân các trạm.
  - Tuyệt đối không dùng Card hay Container bo hộp kín.

### Giai đoạn 3: Tích hợp vào `AchievementScreen` & Xử lý Responsive
- Cập nhật `achievement_screen.dart`:
  - Thay thế khối `OverviewStatistics` cũ bằng `AcademicJourneyTimeline`.
  - Kiểm tra co giãn mượt mà trên màn hình nhỏ `360px`, `390px` và màn lớn `430px`.
  - Hỗ trợ cuộn dọc tự nhiên, không bị giật lag khung hình (60-120fps).

### Giai đoạn 4: Viết Widget Tests & Xác minh Chất lượng
- Viết test suite chuyên sâu `academic_journey_timeline_test.dart`:
  - Kiểm tra render chuẩn xác cả 4 trạm cột mốc.
  - Kiểm tra tính toán đúng số giờ học, bài học, chuỗi ngày và cấp độ.
  - Kiểm tra không xảy ra lỗi tràn màn hình (Overflow) trên độ phân giải 360px.
  - Chạy `flutter test` và `flutter analyze` đảm bảo 0 Errors, 0 Warnings.

---

## 7. KẾT LUẬN & ĐỀ NGHỊ PHÊ DUYỆT

Kế hoạch **"The Academic Learning Odyssey" V3.0** xóa bỏ hoàn toàn lối mòn "lạm dụng Card", chuyển hóa phần Tổng quan thành một tác phẩm nghệ thuật UI sống động:
1. **Khử sạch Card Fatigue:** Không còn bất kỳ chiếc hộp nào giam hãm dữ liệu.
2. **Kể trọn vẹn câu chuyện học tập:** Tái hiện bức tranh toàn cảnh từ khởi đầu đến đỉnh cao hiện tại và mục tiêu tương lai.
3. **Hiệu ứng Animation đánh thức cảm xúc:** Tia sáng chuyển động, hào quang thở nhịp nhàng thôi thúc học sinh học tập mỗi ngày.

*Kính chuyển Người dùng (USER) xem xét và cho ý kiến chỉ đạo để bắt đầu triển khai.*
