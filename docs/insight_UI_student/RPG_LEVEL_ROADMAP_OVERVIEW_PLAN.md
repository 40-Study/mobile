# KẾ HOẠCH TÁI THIẾT KẾ PHẦN TỔNG QUAN: BẢN ĐỒ TIẾN HÓA CẤP BẬC
## (THE RPG LEVEL ROADMAP - ZERO-CARD PROGRESSION CANVAS)

> **Tài liệu tham chiếu:** `mobile/docs/insight_UI_student/`  
> **Áp dụng cho:** `mobile/lib/features/student/presentation/achievement/`  
> **Trọng tâm module:** `academic_level_roadmap.dart`, `overview_statistics.dart` & `achievement_screen.dart`  
> **Trạng thái:** Đã triển khai thành công 100% (Hoàn thành code component, tích hợp screen, test suite PASS 100%)  
> **Mục tiêu then chốt:**  
> 1. **Khắc phục triệt để cảm giác "chưa tới":** Xóa bỏ hoàn toàn định dạng "Form stepper / checklist tracking vận đơn" khô cứng và hành chính.  
> 2. **Kiến tạo Bản đồ Tiến hóa Cấp bậc (RPG Level Roadmap):** Tái hiện hành trình thăng cấp liên tục `Lv.1` -> `Lv.2` -> `Lv.3` -> `⭐ LV.4 (HERO ZENITH)` -> `🔒 LV.5 (NEXT HORIZON)` sống động, trực quan như một game nhập vai học thuật đỉnh cao.  
> 3. **Hero Spotlight áp đảo thị giác:** Tôn vinh Cấp độ hiện tại thành điểm rơi thị giác quyền năng (Visual Anchor), không bị khối "Huy hiệu gần đây" bên dưới lấn át.  
> 4. **Tối giản văn xuôi - Tôn vinh con số vàng:** Cắt giảm 80% câu chữ mô tả lê thê, đưa con số `1,850 XP`, `12 Ngày Streak`, `2 Giờ Tích Lũy` thành những khối số liệu xúc giác sắc bén.  
> 5. **Triệt tiêu lỗi logic 100%:** Xử lý triệt để thuật toán chia điểm XP nội cấp, hiển thị chính xác tiến độ `350 / 500 XP (70%)` và số XP còn lại để thăng hạng Cấp 5.

---

## 1. BỐI CẢNH & PHÂN TÍCH THỰC NGHIỆM TỪ ẢNH CHỤP THỰC TẾ

Dựa trên hình ảnh chụp màn hình thực tế từ thiết bị của người dùng và nhận xét: *"Nhìn thì khác biệt rồi, tuy nhiên tôi cảm giác vẫn chưa tới. Bạn thử phân tích xem."*

```
┌─────────────────────────────────────────────────────────────┐
│ ẢNH CHỤP THỰC TẾ TRÊN THIẾT BỊ (Uploaded Media)             │
│                                                             │
│  [BẢNG VÀNG THÀNH TÍCH]                                     │
│  🏆 Thành tích & Điểm thưởng                                │
│                                                             │
│  HÀNH TRÌNH HỌC THUẬT                                       │
│  Tiến Trình & Cột Mốc Năng Lực              ● Đang diễn ra  │
│                                                             │
│  (⚑) Khởi Nguyên Tri Thức                                   │
│   │  Khởi đầu hành trình học thuật                          │
│   │  [⏱ 2 giờ tích lũy]  [📚 10 bài hoàn tất]               │
│   │                                                         │
│  (🔥) Chuỗi Kỷ Luật  [12 ngày liên tục]                     │
│   │  Duy trì học tập bền bỉ, thắp sáng động lực mỗi ngày.   │
│   │                                                         │
│  (⭐) Học Giả Vững Vàng  [CẤP ĐỘ 4]                         │
│   │  1850 XP tích lũy • 4 huy hiệu vinh danh                │
│   │  Tiến trình thăng cấp                              100% │
│   │  [====================================================] │
│   ┊                                                         │
│  (✦) Mục Tiêu Kế Tiếp: Học Giả Tinh Hoa (Cấp 5)             │
│      Đã hoàn thành mốc mục tiêu của cấp độ hiện tại!        │
│                                                             │
│  Huy hiệu gần đây                                  Xem tất  │
│  [ (📖+) ]       [ (★) ]        [ (🌀) ]        [ (🔥) ]   │
│  Bước chân đầu.. Về đích lần..  Người góp ý     Chuỗi học.. │
│  (4 HUY HIỆU TRÒN TO RỰC RỠ NUỐT CHỬNG HOÀN TOÀN TRỤC TRÊN) │
└─────────────────────────────────────────────────────────────┘
```

### 1.1. Năm (05) điểm nghẽn thị giác khiến UI "chưa tới"

#### Điểm nghẽn 1: Hội chứng "Form Stepper Hành chính / Vận đơn Giao hàng"
- Bố cục 4 node tròn nhỏ `28×28px` xếp dọc bên trái nối bởi đường kẻ dọc là mô hình kinh điển của các ứng dụng tracking bưu phẩm ("Đã tiếp nhận" → "Đang trung chuyển" → "Đang giao" → "Đã nhận").
- Khi áp dụng vào phân hệ Thành tích (Achievement & Gamification), kiểu dáng này tạo cảm giác **hành chính, thủ tục, kiểm tra giấy tờ**, hoàn toàn triệt tiêu cảm giác hứng khởi, phiêu lưu và tự hào của học sinh.

#### Điểm nghẽn 2: Bội thực văn xuôi tự sự (Fluff Narrative Prose)
- Các câu chữ như:
  - *"Khởi đầu hành trình học thuật"*
  - *"Duy trì học tập bền bỉ, thắp sáng động lực mỗi ngày."*
  - *"Đã hoàn thành mốc mục tiêu của cấp độ hiện tại!"*
- Những đoạn văn này chiếm hơn 50% diện tích chiều dọc của component nhưng mang lại giá trị thông tin bằng 0. Trong trải nghiệm game vinh danh, người học lướt mắt tìm con số, cấp bậc và huy hiệu, không ai dừng lại đọc các câu khẩu hiệu chung chung.

#### Điểm nghẽn 3: Điểm rơi thị giác Hero bị chìm, bị khối Huy hiệu bên dưới nuốt chửng
- Mốc quan trọng nhất của học sinh là **"Học Giả Vững Vàng - Cấp độ 4"** chỉ là một dòng chữ nhỏ `16.5px` và icon huân chương bé `24px` nằm lọt thỏm giữa các dòng text.
- Ngay bên dưới là khối **"Huy hiệu gần đây"** với 4 vòng tròn huy hiệu to bản `64×64px`, viền dày và màu sắc cực rực (tím, cam, lục, đỏ).
- **Hệ quả thị giác:** Mắt người dùng bị hút tuột xuống 4 quả cầu huy hiệu bên dưới, trong khi phần Tổng quan (đáng lẽ phải là vua của màn hình) lại chìm nghỉm như một đoạn phụ lục giải trình.

#### Điểm nghẽn 4: Gộp thập cẩm thông tin thay vì Bản đồ Cấp bậc thực thụ
- Trục thời gian hiện tại bị gom cọc cạch 3 loại dữ liệu không tương đương:
  - Trạm 1: Giờ học + Bài học (Chỉ số thời gian/khối lượng)
  - Trạm 2: Streak (Chỉ số kỷ luật chuỗi ngày)
  - Trạm 3: Cấp độ 4 (Cột mốc level hiện tại)
  - Trạm 4: Cấp độ 5 (Cột mốc tương lai)
- Người dùng không nhìn thấy được **Con đường tiến hóa cấp bậc** (`Lv. 1 Tân Khoa` -> `Lv. 2 Tinh Thông` -> `Lv. 3 Tiến Bộ` -> `Lv. 4 Vững Vàng` -> `Lv. 5 Tinh Hoa`). Họ chỉ thấy một mớ chỉ số được dàn hàng dọc.

#### Điểm nghẽn 5: Nghịch lý logic "Tiến trình thăng cấp 100%"
- Nhìn vào ảnh chụp thực tế: Thanh tiến độ báo **100%**, màu xanh dương chạy hết cỡ, nhưng cấp độ vẫn dừng ở Cấp độ 4, và dòng mô tả dưới ghi: *"Đã hoàn thành mốc mục tiêu của cấp độ hiện tại!"*.
- Người học sẽ lập tức thắc mắc: *"Ủa 100% rồi sao tôi chưa lên Cấp 5? Còn cần bao nhiêu điểm nữa để lên cấp?"*.
- **Nguyên nhân kỹ thuật:**
  - Backend quy ước: `500 XP / Level`. Với `1850 XP`, học sinh đang ở Level 4 (`1500 XP -> 2000 XP`). Trong Level 4, học sinh đã tích lũy được `350 XP`, chỉ còn thiếu `150 XP` nữa là thăng cấp Level 5!
  - Nhưng do mobile model `StudentStatsModel.nextLevelXp` lấy nhầm giá trị tĩnh hoặc phép chia `currentXp / nextLevelXp` bị tràn trên 1.0 nên `.clamp(0.0, 1.0)` đã ép về `100%`.
  - Phép tính đúng phải là: Tiến độ trong cấp = `350 / 500 = 70%`, còn lại `150 XP`.

---

## 2. Ý TƯỞNG THIẾT KẾ ĐỘT PHÁ: "THE RPG LEVEL ROADMAP" (HƯỚNG 1)

### 2.1. Triết lý thiết kế: *Ascension & Prestigious Mastery*
Chuyển hóa toàn bộ phần Tổng quan thành một **Vũ đài Tiến hóa Cấp bậc Học thuật**:
1. **Zero-Card Canvas:** Không dùng khung hộp bao bọc nặng nề. Toàn bộ thông tin đứng tự do trên bề mặt phẳng, tạo không gian thở tối đa.
2. **Hero Center of Gravity (Điểm hội tụ Hero tối cao):** Cấp độ hiện tại đứng sừng sững ở vị trí trung tâm với Huy chương 3D mạ vàng, vầng hào quang thở ánh kim (`Breathing Golden Aura`), con số vàng `1,850 XP` to bản sắc nét, và thanh năng lượng thăng cấp chính xác.
3. **The Waypoint Progression Path (Bản đồ Cấp độ Ngang/Bậc thang):**
   Mô phỏng chân thực chuỗi cấp bậc học thuật:
   - `[✓ Lv. 1 Tân Khoa]` (Đã vượt qua - Golden Seal)
   - `[✓ Lv. 2 Tinh Thông]` (Đã vượt qua - Golden Seal)
   - `[✓ Lv. 3 Tiến Bộ]` (Đã vượt qua - Golden Seal)
   - `[⭐ LV. 4 VỮNG VÀNG]` (Vị thế hiện tại - HERO RỰC RỠ)
   - `[🔒 LV. 5 TINH HOA]` (Mục tiêu kế tiếp - Ổ khóa hé mở ánh vàng, còn 150 XP)
4. **Satellite Metric Orbits (Vành đai Chỉ số Vệ tinh):**
   Tách rời Streak, Giờ học, Bài học ra khỏi trục level; đưa chúng thành 3 Capsule Pill xúc giác thanh nhã, bổ trợ ngay dưới chân Hero Stage.

---

## 3. BẢN ĐỒ BỐ CỤC ASCII WIREFRAME CHI TIẾT

```
┌─────────────────────────────────────────────────────────────────────────┐
│ HÀNH TRÌNH HỌC THUẬT                                      ● Đang diễn ra│
│ Con Đường Tiến Hóa Cấp Bậc                                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   [Lv.1] ═══════ [Lv.2] ═══════ [Lv.3] ═══════ [⭐ Lv.4] ┄ ┄ ┄ ┄ [🔒 Lv.5]│
│   Tân Khoa     Tinh Thông      Tiến Bộ       VỮNG VÀNG        Tinh Hoa  │
│      ✓              ✓              ✓          (ĐANG Ở ĐÂY)    (Còn 150XP│
│                                                                         │
│ ─────────────────────────────────────────────────────────────────────── │
│                                                                         │
│                     ┌───────────────────────┐                           │
│                     │   ((( 🌟 64×64 🌟 ))) │  <-- Breathing Glow       │
│                     │   [ 🏆 HUY CHƯƠNG 3D ]│      Aura Pulse (2.4s)    │
│                     │      MẠ VÀNG SỐNG     │                           │
│                     └───────────────────────┘                           │
│                                                                         │
│                      HỌC GIẢ VỮNG VÀNG                                  │
│                 [ ⭐ CẤP BẬC HỌC THUẬT 4 ⭐ ]                           │
│                                                                         │
│                          1,850 XP                                       │
│                       TỔNG TÍN CHỈ TÍCH LŨY                             │
│                                                                         │
│    Tiến độ thăng cấp Lv.5 (350 / 500 XP)                           70%  │
│    [██████████████████████████████████████░░░░░░░░░░░░░░░]              │
│    ⚡ Còn 150 XP nữa để mở khóa danh hiệu Học Giả Tinh Hoa (Cấp 5)      │
│                                                                         │
│ ─────────────────────────────────────────────────────────────────────── │
│                                                                         │
│    ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
│    │ 🔥 12 NGÀY       │  │ ⏱️ 2.5 GIỜ       │  │ 📚 10 BÀI        │     │
│    │ Chuỗi kỷ luật    │  │ Thời gian tích lũ│  │ Hoàn thành       │     │
│    └──────────────────┘  └──────────────────┘  └──────────────────┘     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. MA TRẬN ĐỐI CHIẾU THIẾT KẾ: TRƯỚC VÀ SAU CẢI TIẾN

| Tiêu chí | Bản Hiện Tại (Stepper Dọc) | Bản Mới (RPG Level Roadmap) |
| :--- | :--- | :--- |
| **Bố cục tổng quan** | Stepper dọc 4 node giống phiếu theo dõi giao hàng | Bản đồ tiến hóa cấp độ 3 tầng (Roadmap Track + Hero Center + Satellites) |
| **Tính RPG / Vinh danh** | Yếu ớt, khô cứng, cảm giác form hành chính | Cực mạnh, đậm chất game học thuật, kích thích khao khát thăng hạng |
| **Điểm rơi thị giác Hero** | Node tròn 44px bị chìm trước 4 huy hiệu to bên dưới | Hero Core khổng lồ 64px mạ vàng, hào quang thở, typography số 28px áp đảo |
| **Mật độ câu chữ** | 4 đoạn văn xuôi tự sự lê thê gây rối mắt | Cắt giảm 80% chữ thừa; chỉ giữ lại mốc cấp độ, XP, và callout thôi thúc |
| **Logic tiến trình XP** | Lỗi hiển thị 100% nhưng chưa lên cấp tiếp theo | Thuật toán chuẩn `350 / 500 XP (70%)`, hiển thị rõ `Còn 150 XP` để lên Lv.5 |
| **Chỉ số phụ (Streak, Time)** | Bị ép giả cầy thành trạm dừng chân trên trục | Tách thành 3 Satellite Pods xúc giác độc lập, cân đối và thẩm mỹ |
| **Độ thích ứng màn hình** | Dễ bị co ép chiều ngang nếu tên dài | Tự động thích ứng co dãn (Responsive Flex/Scrollable Track), chống tràn 100% |

---

## 5. CÔNG THỨC TOÁN HỌC & CHUẨN HÓA LOGIC XP / LEVEL

### 5.1. Bóc tách nguyên lý Backend Go & Database Seeds
Trong `backend/internal/database/seeds/demo_gamification.go`:
```go
// Quy ước chuẩn của hệ thống:
// 500 XP tương ứng với 1 Level
// Level = (total_points / 500) + 1
```

### 5.2. Thuật toán phân rã XP trên Mobile Client (Client Mathematical Engine)
Để hiển thị chính xác bản đồ cấp độ và thanh tiến trình mà **hoàn toàn không cần sửa Backend**, Mobile Client sẽ thực hiện tính toán nội suy:

```dart
class LevelProgressData {
  final int currentLevel;
  final int totalXp;
  final int levelBaseXp;     // XP khởi đầu của level hiện tại (ví dụ Lv.4: 1500)
  final int nextLevelBaseXp; // XP để đạt level tiếp theo (ví dụ Lv.5: 2000)
  final int currentLevelXp;  // XP đã đạt được trong level này (ví dụ: 350)
  final int xpNeededForNext; // XP còn thiếu để lên cấp (ví dụ: 150)
  final double progressRatio;// Tỉ lệ tiến độ 0.0 -> 1.0 (ví dụ: 0.70)
  final int progressPercent; // Phần trăm nguyên (ví dụ: 70)

  factory LevelProgressData.fromStats(StudentStatsModel stats) {
    const int xpPerLevel = 500;
    final totalXp = stats.currentXp.clamp(0, 9999999);
    
    // Tính level thực dựa trên total points nếu stats.level chưa đồng bộ
    final computedLevel = (totalXp ~/ xpPerLevel) + 1;
    final currentLevel = stats.level > 0 ? stats.level : computedLevel;

    final levelBaseXp = (currentLevel - 1) * xpPerLevel;
    final nextLevelBaseXp = currentLevel * xpPerLevel;
    final currentLevelXp = (totalXp - levelBaseXp).clamp(0, xpPerLevel);
    final xpNeededForNext = (xpPerLevel - currentLevelXp).clamp(0, xpPerLevel);
    final progressRatio = (currentLevelXp / xpPerLevel).clamp(0.0, 1.0);
    final progressPercent = (progressRatio * 100).toInt();

    return LevelProgressData._(
      currentLevel: currentLevel,
      totalXp: totalXp,
      levelBaseXp: levelBaseXp,
      nextLevelBaseXp: nextLevelBaseXp,
      currentLevelXp: currentLevelXp,
      xpNeededForNext: xpNeededForNext,
      progressRatio: progressRatio,
      progressPercent: progressPercent,
    );
  }
}
```

### 5.3. Bảng Ánh Xạ Danh Hiệu Học Thuật Chuẩn (Academic Ranks)
- **Level 1:** `Tân Khoa Nhập Môn` (0 - 500 XP)
- **Level 2:** `Tân Khoa Tinh Thông` (501 - 1,000 XP)
- **Level 3:** `Học Giả Tiến Bộ` (1,001 - 1,500 XP)
- **Level 4:** `Học Giả Vững Vàng` (1,501 - 2,000 XP)
- **Level 5:** `Học Giả Tinh Hoa` (2,001 - 2,500 XP)
- **Level 6:** `Học Viện Danh Dự` (2,501 - 3,000 XP)
- **Level 7:** `Học Sĩ Uyên Bác` (3,001 - 3,500 XP)
- **Level 8+:** `Đại Học Sĩ ForteX` (> 3,500 XP)

---

## 6. CHI TIẾT 3 TẦNG THIẾT KẾ CỦA "THE RPG LEVEL ROADMAP"

### 6.1. Tầng 1: The Level Progression Track (Dải Bản đồ Cấp độ Ngang)
- **Đặc điểm:** Một đường ray ngang nằm phía trên, hiển thị các mốc level: `Lv.1` -> `Lv.2` -> `Lv.3` -> `⭐ Lv.4` -> `🔒 Lv.5`.
- **Mốc đã qua (Lv.1, Lv.2, Lv.3):**
  - Node tròn `26×26px` nền vàng kim nhạt (`Color(0xFFFEF3C7)`), viền vàng `Color(0xFFF59E0B)`.
  - Icon: Dấu tích vinh quang `Icons.check_rounded` màu hổ phách `Color(0xFFB45309)`.
  - Đường nối giữa các mốc đã qua: Nét liền màu vàng kim rực rỡ `Color(0xFFF59E0B)` dày 2.5px.
- **Mốc hiện tại (Lv.4):**
  - Node hình Squircle `32×32px` phát sáng nhẹ, icon ngôi sao danh dự `Icons.star_rounded` màu vàng cam.
  - Nhãn bên dưới: `VỮNG VÀNG` (in hoa, đậm).
- **Mốc tương lai (Lv.5):**
  - Node tròn `26×26px` màu xám nhạt (`Color(0xFFF1F5F9)`), viền nét đứt.
  - Icon: Ổ khóa hé mở `Icons.lock_outline_rounded` màu `slate400`.
  - Đường nối từ hiện tại tới tương lai: Nét đứt (Dashed line) thanh lịch.

### 6.2. Tầng 2: The Hero Zenith Core (Trọng tâm Vinh danh Quyền năng)
- **Huy chương Hero Squircle 3D:**
  - Kích thước `64×64px`, bo góc cong 20px (Squircle).
  - Nền gradient ánh vàng hoàng kim: từ `Color(0xFFFDE68A)` sang `Color(0xFFF59E0B)`.
  - Viền mạ vàng kép `1.8px`, đổ bóng 3D khuếch tán mềm (`BoxShadow` với màu `Color(0xFFD97706)` alpha 0.25, blur 16px).
  - Icon đại diện: `Icons.military_tech_rounded` hoặc `Icons.workspace_premium_rounded` kích thước `36px` màu trắng ngà ánh kim.
  - Hiệu ứng thở hào quang: Vòng sáng thở `Breathing Glow Pulse` (Animation chu kỳ 2.4s) tỏa rộng xung quanh tạo cảm giác huy chương đang tỏa sáng sống động.
- **Danh hiệu & Cấp bậc:**
  - Tiêu đề danh xưng: `Học Giả Vững Vàng` (Font size 19px, bold 900, màu `slate900` / `white` trong dark mode).
  - Badge Cấp bậc: `⭐ CẤP ĐỘ 4` nền vàng kim sang trọng, viền hairline sắc sảo.
- **Typography số vàng:**
  - Điểm XP: `1,850 XP` với kích cỡ to bản `26px`, số dạng Tabular Figures uy quyền.
  - Phụ đề: `TỔNG ĐIỂM KINH NGHIỆM TÍCH LŨY` (11px, bold 700, màu `brandBlueDark`).
- **Thanh năng lượng thăng cấp (Ascension Energy Bar):**
  - Chiều cao `7px`, bo tròn 3.5px.
  - Nền ray: `slate200` (hoặc `slate800` trong dark mode).
  - Thanh năng lượng: Gradient từ `Color(0xFF2563EB)` (Royal Blue) sang `Color(0xFF4F46E5)` (Indigo) hoặc Gradient Vàng Kim `Amber`.
  - Hiệu ứng: Tia sáng lướt qua khi render.
  - Dòng thôi thúc hành động: `⚡ Còn 150 XP nữa để mở khóa Học Giả Tinh Hoa (Cấp 5)`.

### 6.3. Tầng 3: The Satellite Metric Pods (Vành đai Chỉ số Vệ tinh)
Bố trí 3 Capsule Pod độc lập, dàn đều 3 cột với tỉ lệ cân đối:
1. **Pod 1: Chuỗi Kỷ Luật (Streak)**
   - Icon: `Icons.local_fire_department_rounded` màu cam lửa rực rỡ (`Color(0xFFEA580C)`).
   - Số liệu: `12 Ngày` (Font size 15px, w800).
   - Nhãn: `Chuỗi kỷ luật`.
2. **Pod 2: Thời Lượng Học (Study Time)**
   - Icon: `Icons.schedule_rounded` màu xanh dương (`Color(0xFF2563EB)`).
   - Số liệu: `2.0 Giờ` (Font size 15px, w800).
   - Nhãn: `Tích lũy học`.
3. **Pod 3: Bài Học Hoàn Tất (Lessons Completed)**
   - Icon: `Icons.menu_book_rounded` màu xanh ngọc (`Color(0xFF059669)`).
   - Số liệu: `10 Bài` (Font size 15px, w800).
   - Nhãn: `Đã hoàn thành`.

Toàn bộ 3 Pod được thiết kế dạng **Ultra-thin Surface Pill**: nền bán trong suốt `withValues(alpha: 0.04)`, viền hairline siêu mỏng `0.8px`, padding `10px 12px`, tuyệt đối không gây cảm giác hộp dày hay card nặng nề.

---

## 7. HỆ THỐNG ANIMATION ÁNH SÁNG & DÒNG CHẢY NĂNG LƯỢNG (THE RADIANT LIGHT & FLOWING ENERGY ENGINE)

Để biến phần Tổng quan thành một vũ đài sống động, đậm chất ma thuật học thuật (Academic Mysticism & RPG Energy), hệ thống animation bao gồm **6 hiệu ứng ánh sáng và dòng chảy đồng bộ**:

```
           ══════════════════════════════════════════════════════════════
           HIỆU ỨNG 1: DÒNG CHẢY NĂNG LƯỢNG TRÊN ĐƯỜNG RAY (CONDUIT TRAIL)
           [Lv.1] ───>>>─── [Lv.2] ───>>>─── [Lv.3] ───>>>─── [⭐ Lv.4] ┄┄┄ [🔒 Lv.5]
                       (Xung sóng ánh sáng vàng kim trôi liên tục)
           ──────────────────────────────────────────────────────────────
           HIỆU ỨNG 2: VẦNG HÀO QUANG THỞ ĐA TẦNG (BREATHING SOLAR CORONA)
                             (((   )))   <-- Tầng 3: Khuếch tán mềm 92px
                            ((  🌟  ))   <-- Tầng 2: Vầng nhật hoa 76px
                           ┌───────────┐ <-- Tầng 1: Lõi Squircle 64px
                           │ 🏆 HUY CH │     Mạ vàng 3D ánh kim
                           └───────────┘
           HIỆU ỨNG 3: HẠT LẤP LÁNH VINH DANH (TWINKLE STARLIGHT GLINTS)
                         ✦  (Sparkle ngẫu nhiên xoay góc 0-360°)
           ──────────────────────────────────────────────────────────────
           HIỆU ỨNG 4: DÒNG CHẢY THỦY DỊCH XP (LIQUID SHIMMER FLOW GAUGE)
           [████████████████████████████████████▒▒▒░░░░░░░░░░░░░] 70%
           └────── Dải Shimmer trôi ngang ─────┘ ✦ Leading Energy Orb
                                                    (Hạt ngọc dẫn đường)
           ──────────────────────────────────────────────────────────────
           HIỆU ỨNG 5: HÀO QUANG HÉ MỞ Ổ KHÓA TƯƠNG LAI (LOCK AURORA PULSE)
           [🔒 Lv.5] <-- Ánh sáng tím hổ phách hé mở mờ ảo, kích thích mở khóa
           ══════════════════════════════════════════════════════════════
```

### 7.1. Chi tiết 6 Hiệu ứng Ánh sáng & Dòng chảy

#### 1. Dòng chảy Năng lượng trên Đường ray (The Flowing Energy Conduit)
- **Cơ chế:** Trên đoạn đường ray vàng rực nối từ `Lv.1` -> `Lv.2` -> `Lv.3` -> `⭐ Lv.4`, một vệt sóng ánh sáng (Energy Wave Tracer) liên tục trôi từ trái qua phải, như dòng điện/dòng mana tinh khiết đang rót năng lượng vào Hero Core.
- **Kỹ thuật Flutter:**
  - Sử dụng `AnimatedBuilder` với `ShaderMask` hoặc `GradientTransform` trên `LinearGradient`.
  - Gradient 3 pha: `[Color(0xFFF59E0B), Color(0xFFFEF3C7), Color(0xFFF59E0B)]`.
  - Tham số dịch chuyển `transform: GradientRotation` hoặc `Alignment(lerp(-1.0, 2.0, t), 0)` chu kỳ `2.4s` lặp vô tận.

#### 2. Vầng hào quang thở đa tầng (Multi-Layer Solar Corona)
- **Cơ chế:** Huy chương Hero trung tâm không đơn điệu với 1 lớp mờ, mà sở hữu **3 tầng hào quang đồng tâm**:
  - **Lõi trong (Core Emblem):** Khối Squircle `64×64px` vàng kim óng ánh, đổ bóng xúc giác 3D.
  - **Tầng giữa (Inner Corona):** Vầng sáng vàng mật ong `Color(0xFFF59E0B).withValues(alpha: 0.35)`, biên độ co giãn hình sin `64px → 78px`.
  - **Tầng ngoài (Outer Ambient Aura):** Vầng sáng khuếch tán mềm màu ngọc bích ánh vàng `Color(0xFFFEF3C7).withValues(alpha: 0.15)`, biên độ co giãn `78px → 94px`.
- **Nhịp thở:** Chu kỳ `2.6s` với đường cong `Curves.easeInOutSine`, tạo cảm giác nhịp đập sinh mệnh của một học giả đang ở đỉnh cao phong độ.

#### 3. Dòng chảy Thủy dịch XP & Hạt Ngọc Dẫn Đường (Liquid Shimmer XP Gauge & Leading Orb)
- **Cơ chế:**
  - Thanh tiến trình 70% không phải vạch màu tĩnh! Bên trong thanh năng lượng là một **dòng chất lỏng ma thuật (Liquid Mana Fluid)** với dải sáng ánh bạc/vàng lướt qua liên tục chu kỳ `1.8s` (Shimmer Sweep).
  - Ngay tại điểm mút 70% có một **Hạt ngọc dẫn đường (Leading Energy Orb)** đường kính `9px` phát sáng nhấp nháy (`BoxShadow blur 6px Color(0xFF3B82F6)`), đánh dấu trực quan ranh giới đã chinh phục.
- **Kỹ thuật Flutter:**
  - `LinearGradient` với `ShaderMask` chạy ngang trên `FractionallySizedBox(widthFactor: progressRatio)`.
  - Đầu mút bọc `Stack` căn chỉnh `Alignment.centerRight` đặt viên ngọc phát sáng.

#### 4. Hạt lấp lánh ánh kim vinh danh (Twinkle Starlight Glints)
- **Cơ chế:** 2 đến 3 hạt sáng nhỏ hình ngôi sao 4 cánh (`✦`) kích thước `10-14px` đặt tại các góc của Hero Emblem, nhấp nháy phát sáng và xoay nhẹ (Scale 0.0 -> 1.0 -> 0.0 kết hợp Rotation 0° -> 45°), mô phỏng bề mặt kim loại quý bắt sáng tự nhiên dưới ánh đèn danh vọng.

#### 5. Hào quang hé mở ở Ổ khóa Tương lai (Pulsing Lock Aurora)
- **Cơ chế:** Tại mốc `🔒 Lv.5 (Học Giả Tinh Hoa)`, icon ổ khóa không mang màu xám chết, mà có một vầng sáng tím hổ phách huyền bí nhấp nháy nhẹ nhàng (Pulsing Lock Silhouette, alpha `0.2 -> 0.5`).
- **Ý nghĩa tâm lý:** Gợi mở cảm giác tò mò và thôi thúc người học: *"Chỉ còn một chút năng lượng nữa là cánh cổng Lv.5 sẽ được giải phóng!"*.

#### 6. Phản hồi Xung kích Xúc giác (Tactile Shockwave Ripple)
- **Cơ chế:** Khi người dùng chạm ngón tay vào Hero Emblem hoặc các trạm cấp bậc:
  - Một vòng sóng xung kích hình elip bung nở từ tâm ra ngoài bán kính `40px` và mờ dần trong `350ms`.
  - Đồng thời kích hoạt rung phản hồi xúc giác nhẹ nhàng `HapticFeedback.lightImpact()`.

---

### 7.2. Tối ưu Hiệu năng & An toàn Năng lượng (Performance & Battery Efficiency)

1. **Master Single Controller (Đồng bộ 1 Controller duy nhất):**
   - Thay vì tạo 5-6 `AnimationController` gây ngốn CPU và hao pin, toàn bộ hệ thống Ánh sáng & Dòng chảy dùng chung **1 `AnimationController` master** (chu kỳ `2.4s` - `2.6s`).
   - Các hiệu ứng khác nhau sẽ phân chia thời gian thông qua `CurvedAnimation` với `Interval(begin, end, curve)`.
2. **Cờ An toàn Testing (`enableAnimation = false`):**
   - Khi chạy Widget Test hoặc môi trường tự động hóa, cờ `enableAnimation` sẽ cố định toàn bộ giá trị ở trạng thái tĩnh đẹp nhất, đảm bảo `tester.pumpAndSettle()` không bao giờ bị timeout và test suite luôn đạt tốc độ thực thi miligiây.
3. **Tự động ngắt khi ẩn (Viewport Culling):**
   - Sử dụng `TickerMode` hoặc tự động dừng ticker khi component cuộn ra khỏi tầm nhìn, bảo toàn 100% thời lượng pin cho học sinh.

---

## 8. ĐẶC TẢ DESIGN TOKENS & TYPOGRAPHY

### 8.1. Bảng màu Semantic Tokens (Ánh xạ 100% từ TogetherColorsX)
```dart
// Bảng màu Hoàng kim Vinh danh (Prestige Gold)
static const Color prestigeGoldStart = Color(0xFFFEF3C7);
static const Color prestigeGoldMid   = Color(0xFFF59E0B);
static const Color prestigeGoldDark  = Color(0xFFD97706);
static const Color prestigeGoldDeep  = Color(0xFFB45309);

// Bảng màu Năng lượng Kỷ luật (Streak Flame)
static const Color flameOrange = Color(0xFFEA580C);
static const Color flameBg     = Color(0xFFFFF7ED);

// Bảng màu Tích lũy Tri thức (Knowledge Blue)
static const Color royalBlue   = Color(0xFF2563EB);
static const Color royalBlueBg = Color(0xFFEFF6FF);

// Bảng màu Thành quả (Mastery Green)
static const Color emeraldText = Color(0xFF059669);
static const Color emeraldBg   = Color(0xFFECFDF5);
```

### 8.2. Tương thích Toàn diện Dark Mode
- Bề mặt Canvas: Hòa nhập tự nhiên vào `context.surfaceBg`.
- Text tự động đảo màu từ `cs.slate900` sang `cs.slate100` nhờ extension `TogetherColorsX`.
- Nền các Satellite Pods tự động chuyển sang `withValues(alpha: 0.2)` trên nền tối, không bị chói mắt.
- Viền hairline chuyển sang `cs.slate800` chống lộ viền thô.

---

## 9. LỘ TRÌNH TRIỂN KHAI 4 GIAI ĐOẠN (IMPLEMENTATION ROADMAP)

> **Lưu ý:** Đây là kế hoạch chuẩn bị, KHÔNG chỉnh sửa code trong bước này. Chỉ thực hiện khi người dùng phê duyệt kế hoạch.

### Giai đoạn 1: Xây dựng Bộ công cụ Toán học Level & Data Model Helper
- Tạo class `LevelProgressCalculator` (hoặc method nội bộ trong widget) thực hiện chính xác các phép toán nội suy:
  - Phân rã `total_points` thành Level, Base XP, Current Level XP, Remaining XP, và Progress Ratio.
  - Test case toán học:
    - `0 XP` -> Level 1, 0/500 (0%), còn 500 XP.
    - `250 XP` -> Level 1, 250/500 (50%), còn 250 XP.
    - `500 XP` -> Level 2, 0/500 (0%), còn 500 XP.
    - `1850 XP` -> Level 4, 350/500 (70%), còn 150 XP.

### Giai đoạn 2: Hiện thực hóa Component `AcademicLevelRoadmap` tích hợp Hệ thống Animation Ánh sáng & Dòng chảy
- Tạo file component mới: `mobile/lib/features/student/presentation/achievement/widgets/academic_level_roadmap.dart`.
- Tích hợp Master Single AnimationController điều phối mượt mà:
  1. `_RoadmapPathBar`: Vẽ đường ray cấp bậc với sóng ánh sáng năng lượng chảy (Flowing Conduit Wave).
  2. `_HeroZenithEmblem`: Khối vinh danh trung tâm với vầng hào quang thở đa tầng (Multi-Layer Solar Corona), hạt sao lấp lánh (Twinkle Glints), và thanh năng lượng thủy dịch (Liquid XP Shimmer Gauge + Leading Orb).
  3. `_SatellitePodsRow`: Hàng 3 viên Capsule Pods hiển thị Chuỗi kỷ luật, Giờ học, và Bài học hoàn tất với micro-ripple khi chạm.

### Giai đoạn 3: Tích hợp vào `AchievementScreen` & Dọn dẹp Widget cũ
- Export `academic_level_roadmap.dart` trong `widgets.dart`.
- Thay thế `AcademicJourneyTimeline` trong `achievement_screen.dart` bằng `AcademicLevelRoadmap`.
- Đảm bảo tham số nhận vào đầy đủ `stats`, `earnedBadgesCount`, `totalBadgesCount`.
- Giữ cờ `enableAnimation` cho môi trường Test.

### Giai đoạn 4: Kiểm thử Widget Test, Analyzer & Verify trên Thiết bị Thực tế
- Chạy `flutter analyze` đảm bảo 0 warning, 0 error.
- Cập nhật và bổ sung Widget Test chuyên sâu:
  - Test hiển thị đúng Level 4 và danh hiệu "Học Giả Vững Vàng".
  - Test thanh tiến trình đạt đúng 70% (không còn bị 100% sai lệch).
  - Test hiển thị đúng text "Còn 150 XP nữa để mở khóa Học Giả Tinh Hoa".
  - Test hiển thị đúng 3 chỉ số vệ tinh (Streak, Giờ học, Bài học).
  - Test animation an toàn khi `enableAnimation = false` không gây timeout test.
  - Test an toàn Dark Mode và màn hình hẹp 360px không overflow.

---

## 10. TIÊU CHÍ NGHIỆM THU AN TOÀN (ACCEPTANCE CRITERIA)

1. [ ] **Triệt tiêu cảm giác hành chính:** Không còn bất kỳ node stepper dọc hay đường kẻ vận đơn bưu chính nào.
2. [ ] **Điểm rơi thị giác Hero áp đảo:** Khi mở tab Thành tích, mắt người dùng lập tức bị cuốn hút vào Huy chương mạ vàng và con số `1,850 XP` ở trung tâm, không còn bị 4 huy hiệu bên dưới nuốt chửng.
3. [ ] **Bản đồ Cấp độ chân thực:** Hiển thị rõ hành trình `Lv.1` -> `Lv.2` -> `Lv.3` -> `⭐ Lv.4` -> `🔒 Lv.5`.
4. [ ] **Toán học chính xác 100%:** Với `1,850 XP`, thanh tiến độ hiển thị đúng `70%`, không còn hiện tượng 100% nghịch lý.
5. [ ] **Tối giản văn xuôi:** Không còn các đoạn text slogan tự sự dài dòng; giao diện tinh gọn, sắc sảo và hiện đại.
6. [ ] **0 Thay đổi Backend:** Giữ nguyên 100% API `/api/users/{userId}/public-profile` và BLoC state.
7. [ ] **Mã nguồn sạch:** `flutter analyze` không có lỗi; Widget tests PASS 100%.
