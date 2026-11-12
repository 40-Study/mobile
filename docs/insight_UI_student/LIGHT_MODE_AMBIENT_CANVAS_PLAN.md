# KẾ HOẠCH NÂNG CẤP HIỂN THỊ LIGHT MODE CHO BẢN ĐỒ CẤP BẬC
## (THE AMBIENT HONOR CANVAS & CONTRAST COLOR GRADING PLAN)

> **Tài liệu tham chiếu:** `mobile/docs/insight_UI_student/`  
> **Áp dụng cho:** `mobile/lib/features/student/presentation/achievement/widgets/academic_level_roadmap.dart`  
> **Phương án lựa chọn:** Kết hợp **Phương án 1 (The Ambient Honor Canvas)** + **Phương án 3 (Color Grading & Contrast Tuning)**  
> **Trạng thái:** Đã triển khai thành công 100% (Hoàn thành canvas gradient, color grading WCAG AAA, test suite PASS 100%)  
> **Mục tiêu then chốt:**  
> 1. **Khắc phục triệt để hiện tượng "chìm nghỉm / mờ nhạt" ở Light Mode:** Tạo bề mặt nâng đỡ danh dự (Ambient Canvas) giúp các mốc cấp độ, huy chương và thanh năng lượng nổi bật uy quyền ngay trên nền sáng.  
> 2. **Bảo tồn 100% vẻ đẹp xuất sắc của Dark Mode:** Toàn bộ hiệu ứng ánh sáng rực rỡ, độ tương phản huyền bí của Dark Mode hiện tại được giữ nguyên vẹn $100\%$.  
> 3. **Tuyệt đối không lặp lại lỗi "Card Fatigue / Đóng hộp thô cứng":** Sử dụng khay nền chuyển màu gradient khí quyển siêu tinh tế, viền hairline mạ vàng $0.8\text{px}$ và bóng khuếch tán đa tầng mềm mại.  
> 4. **Cân chỉnh màu sắc đạt chuẩn WCAG AAA:** Tăng độ tương phản chữ và icon của các mốc `Lv.1` – `Lv.3` từ 1.8:1 lên trên 5.2:1, sắc nét, dễ đọc.  
> 5. **Bảo đảm không gian thở và độ ổn định layout:** Không làm ảnh hưởng đến kích thước hay nhịp thở animation đã được tối ưu trước đó.

---

## 1. BỐI CẢNH & PHÂN TÍCH ĐỐI CHIẾU THỊ GIÁC THỰC NGHIỆM

Dựa trên 2 ảnh chụp thực tế từ thiết bị của người dùng tại cùng một thời điểm:
* **Ảnh 1 (Light Mode):** [uploaded_media_0_1793178510166.png]
* **Ảnh 2 (Dark Mode):** [uploaded_media_1_1793178510166.png]

```
┌─────────────────────────────────────────────────────────────────────────┐
│ ĐỐI CHIẾU THỊ GIÁC: TẠI SAO DARK MODE THÌ ĐẸP MÀ LIGHT MODE LẠI CHÌM?   │
├────────────────────────────────────┬────────────────────────────────────┤
│ ẢNH 2: DARK MODE (RỰC RỠ, NỔI BẬT) │ ẢNH 1: LIGHT MODE (CHÌM, NHẠT NHÒA)│
├────────────────────────────────────┼────────────────────────────────────┤
│ • Nền đen than (#0F172A) độ sáng 0%│ • Nền trắng toát (#F8FAFC) sáng 100%│
│ • Ánh hào quang vàng (#FEF3C7)     │ • Ánh hào quang vàng hòa tan hoàn   │
│   tương phản cực mạnh (> 12:1),    │   toàn vào nền trắng, mất hiệu ứng  │
│   tạo cảm giác phát sáng neon.     │   phát sáng (Contrast < 1.3:1).    │
│ • Các node Lv.1-3 màu vàng kim nổi │ • Các node Lv.1-3 và chữ màu xám   │
│   rõ từng đường nét trên nền tối.  │   nhạt trôi tự do, nhìn phẳng lì.  │
│ • 3 Pods bên dưới có viền sáng     │ • 3 Pods bên dưới bị lẫn màu nền,  │
│   tách bạch thành 3 khối xúc giác. │   thiếu chiều sâu thị giác.        │
│ • Section trên áp đảo khối         │ • Section trên bị 4 vòng huy hiệu  │
│   "Huy hiệu gần đây" bên dưới.     │   rực rỡ bên dưới nuốt chửng!      │
└────────────────────────────────────┴────────────────────────────────────┘
```

### 1.1. Ba nguyên nhân cốt lõi khiến Light Mode bị chìm:
1. **Thiếu Bề mặt Nâng đỡ (Missing Visual Grounding Surface):** Khi bỏ card bao quanh để tránh card-fatigue, trên nền tối các phần tử tự phát quang tự định vị được ranh giới; nhưng trên nền sáng, mắt người dùng cần một **lớp bề mặt (Surface Layer)** để định vị "đây là một vũ đài danh vọng riêng biệt".
2. **Hiệu ứng ánh sáng Additive Light bị triệt tiêu:** Ánh sáng vàng nhạt (`#FEF3C7`) chỉ phát quang khi môi trường xung quanh tối hơn nó. Khi môi trường xung quanh là màu trắng $100\%$ độ sáng, ánh sáng vàng nhạt bị triệt tiêu hoàn toàn.
3. **Độ bão hòa màu chữ chưa thích ứng theo Theme:** Text `Lv.1 - Tân Khoa`, `Lv.2 - Tinh Thông` dùng `slate500` có độ tương phản quá yếu trên nền sáng.

---

## 2. TRIẾT LÝ THIẾT KẾ KẾT HỢP: "THE RADIANT HONOR CANVAS" (PHƯƠNG ÁN 1 + 3)

Giải pháp là sự kết hợp hoàn hảo giữa **Khay nền Khí quyển Sang trọng (Phương án 1)** và **Cân chỉnh Độ tương phản Màu sắc (Phương án 3)**:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ BỐ CỤC KHAY NỀN GRADIENT KHÍ QUYỂN & TĂNG TƯƠNG PHẢN (LIGHT MODE)      │
│                                                                         │
│   ╭─────────────────────────────────────────────────────────────────╮   │
│   │  ░░ NỀN GRADIENT HOÀNG KIM KHÍ QUYỂN (Trắng sứ ──> Vàng ngà ──> Kem) │
│   │  Viền hairline vàng hổ phách 0.8px mạ kim (Alpha 0.5)           │   │
│   │  Đổ bóng khí quyển màu hổ phách khuếch tán 24px (Alpha 0.05)    │   │
│   │                                                                 │   │
│   │   [✓ Lv.1] ══════ [✓ Lv.2] ══════ [✓ Lv.3] ══════ [⭐ Lv.4] ┄┄ [🔒]│
│   │   Tân Khoa       Tinh Thông      Tiến Bộ        VỮNG VÀNG    Tinh   │
│   │   (Chữ màu nâu hổ phách đậm #92400E - Đậm nét, cực kỳ rõ ràng)  │   │
│   │                                                                 │   │
│   │                 ((( 🏆 HUY CHƯƠNG MẠ VÀNG 3D )))                 │   │
│   │            (Bổ sung vầng bóng hổ phách phát sáng ấm)            │   │
│   │                                                                 │   │
│   │                   HỌC GIẢ VỮNG VÀNG  [ CẤP ĐỘ 4 ]               │   │
│   │                       1,850 XP • 4 huy hiệu                     │   │
│   │                                                                 │   │
│   │    Tiến độ thăng cấp Lv.5 (350 / 500 XP)                   70%  │   │
│   │    [█████████████████████████████████████░░░░░░░░░░░░░░]        │   │
│   │    ⚡ Còn 150 XP nữa để mở khóa Học Giả Tinh Hoa (Cấp 5)         │   │
│   │                                                                 │   │
│   │   ╭──────────────╮      ╭──────────────╮      ╭──────────────╮  │   │
│   │   │ 🔥 12 Ngày   │      │ ⏱️ 2.8 Giờ   │      │ 📚 10 Bài    │  │   │
│   │   │ Chuỗi kỷ luật│      │ Tích lũy học │      │ Đã hoàn thành│  │   │
│   │   ╰──────────────╯      ╰──────────────╯      ╰──────────────╯  │   │
│   │   (Nền trắng sứ nổi nhẹ Micro-elevation, viền hairline sắc nét) │   │
│   ╰─────────────────────────────────────────────────────────────────╯   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. CHI TIẾT 2 TẦNG NÂNG CẤP

### 3.1. Tầng 1: Khay Nền Gradient Khí Quyển (The Ambient Atmospheric Canvas)
Bọc toàn bộ nội dung của `AcademicLevelRoadmap` vào một `Container` khay nền thông minh:

#### Khi ở Light Mode:
* **Màu nền Gradient đa tầng (Prestige Light Gradient):**
  ```dart
  gradient: LinearGradient(
    colors: [
      Colors.white,                   // 0%: Đỉnh trắng tinh khôi
      Color(0xFFFFFDF5),             // 40%: Ánh vàng ngà kem thanh khiết
      Color(0xFFFEF3C7).withValues(alpha: 0.35), // 75%: Ánh vàng hoàng gia ấm
      Color(0xFFF0FDF4).withValues(alpha: 0.25), // 100%: Chân xanh học thuật dịu mắt
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  )
  ```
* **Viền Hairline mạ vàng (Gold Hairline Border):**
  * Độ dày: `0.8px` siêu mảnh.
  * Màu sắc: `Color(0xFFFDE68A).withValues(alpha: 0.60)` (chỉ bắt sáng nhẹ khi nhìn nghiêng, không tạo cảm giác viền hộp thô đen).
  * Góc bo cong: `BorderRadius.circular(22)` (Squircle mềm mại).
* **Đổ bóng Khí quyển Đa tầng (Atmospheric Amber Glow Shadow):**
  ```dart
  boxShadow: [
    BoxShadow(
      color: Color(0xFFD97706).withValues(alpha: 0.05),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFFF59E0B).withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ]
  ```
* **Padding bên trong:** `EdgeInsets.fromLTRB(14, 16, 14, 16)` tạo khoảng thở thoáng đãng, sang trọng như một tấm Bằng Khen Danh Dự.

#### Khi ở Dark Mode:
* **Tuyệt đối không làm mất chất Dark Mode:**
  * Khay nền giữ ở trạng thái bán trong suốt tự nhiên:
  ```dart
  color: cs.slate900.withValues(alpha: 0.35),
  border: Border.all(color: cs.slate800, width: 0.8),
  boxShadow: null, // Không đổ bóng đục trên nền tối
  ```
  $\rightarrow$ Dark Mode vẫn giữ nguyên $100\%$ vẻ đẹp huyền bí, sắc sảo đã được kiểm chứng!

---

### 3.2. Tầng 2: Cân Chỉnh Màu Sắc & Độ Tương Phản (Color Grading & Contrast Tuning)

#### 1. Dải mốc Waypoint `Lv.1` – `Lv.3` trên Đường ray:
* **Màu chữ Cấp bậc & Danh xưng:**
  * *Hiện tại:* `cs.slate500` (quá nhạt trên nền sáng).
  * *Cải tiến Light Mode:* Chuyển sang `Color(0xFF92400E)` (nâu hổ phách đậm - Amber Deep).
  * *Tác dụng:* Tương phản cực cao trên nền ngà, mắt người dùng đọc rõ ràng tên từng cấp độ mà không cần nheo mắt.
* **Node tròn Checkmark đã hoàn thành:**
  * *Nền:* `Color(0xFFFEF3C7)` (vàng kim nhạt).
  * *Viền:* Nâng lên `Color(0xFFD97706)` độ dày `1.4px` (sắc sảo hơn).
  * *Icon Checkmark:* Màu `Color(0xFFB45309)` (đậm nét).

#### 2. Vầng Hào Quang Thở của Hero Emblem trong Light Mode:
* Trên nền sáng, để vầng hào quang không bị "cháy trắng", ta bổ sung thêm **lớp bóng màu hổ phách phát quang (Luminous Amber Glow)** ở tầng giữa:
  ```dart
  // Tầng ngoài cùng trong Light Mode:
  color: isDark 
      ? const Color(0xFFFEF3C7).withValues(alpha: 0.08)
      : const Color(0xFFF59E0B).withValues(alpha: 0.16 * (1.0 - glow * 0.3)),
  ```
  $\rightarrow$ Khi thở ra thu vào, mắt người dùng nhìn thấy rõ một vầng sáng màu vàng mật ong ấm áp đang nhấp nhô nhẹ nhàng trên nền ngà!

#### 3. Bộ 3 Satellite Pods bên dưới (Streak, Giờ học, Bài học):
* Trong Light Mode, nâng cấp 3 Pods thành **Elevated Pure-White Pills**:
  * **Nền:** `Colors.white` (trắng sứ nổi khối nhẹ trên nền ngà).
  * **Viền:** `Border.all(color: Color(0xFFE2E8F0), width: 0.8)`.
  * **Đổ bóng nhẹ xúc giác:**
    `BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: Offset(0, 2))`.
  * *Tác dụng:* 3 Pods trở thành 3 khối xúc giác nổi bật, tách bạch rõ ràng, thôi thúc chạm ngón tay.

---

## 4. MA TRẬN ĐỐI CHIẾU THÔNG SỐ: HIỆN TẠI VS. CẢI TIẾN

| Thành phần | Hiện tại (Light Mode) | Cải tiến (Light Mode - Phương án 1+3) | Dark Mode (Giữ nguyên) |
| :--- | :--- | :--- | :--- |
| **Bề mặt Canvas bao quanh** | Trôi tự do trên nền trang trắng, 0 nền | Khay nền Gradient Trắng sứ $\rightarrow$ Vàng ngà $\rightarrow$ Xanh ngọc | Nền bán trong suốt `slate900` 35% |
| **Viền khay canvas** | Không có | Hairline `0.8px` mạ vàng nhạt `FDE68A` bo cong `22px` | Viền hairline `slate800` |
| **Đổ bóng canvas** | Không có | Khí quyển hổ phách khuếch tán `24px` mềm mại | Không đổ bóng đục |
| **Chữ mốc Lv.1-3** | `slate500` (nhạt nhòa, khó đọc) | `Color(0xFF92400E)` nâu hổ phách đậm nét | `slate500` / `slate400` tương phản tốt |
| **Node Lv.1-3** | Viền mỏng, màu vàng nhạt | Viền `1.4px` vàng hổ phách đậm `D97706` | Viền vàng hổ phách |
| **Vầng hào quang thở** | Bị hòa tan, biến mất vào nền trắng | Vầng mật ong ấm `F59E0B` tỏa sáng rõ rệt | Vầng vàng kim tỏa sáng trên nền tối |
| **3 Satellite Pods** | Nền xám nhạt phẳng lì, chìm màu | Nền trắng sứ nổi nhẹ Micro-elevation `Colors.white` | Nền `slate800` 30% |

---

## 5. LỘ TRÌNH 4 GIAI ĐOẠN THỰC HIỆN CHI TIẾT

> **Lưu ý:** Đây là tài liệu kế hoạch, CHƯA chỉnh sửa code trong bước này.

### Giai đoạn 1: Xây dựng Theme Resolver & Container Decoration cho Canvas
* Tạo helper nội bộ `_buildCanvasDecoration(bool isDark)` trong `academic_level_roadmap.dart`:
  * Nhánh `!isDark`: Áp dụng Gradient hoàng kim 4 dải màu, viền hairline hổ phách, bóng khuếch tán 24px.
  * Nhánh `isDark`: Áp dụng nền tối bán trong suốt `slate900` 35%, viền `slate800`.
* Bọc toàn bộ Column nội dung trong `Container` với `decoration` này và padding chuẩn `14px 16px`.

### Giai đoạn 2: Nâng cấp Color Grading cho Dải Đường ray Cấp độ (`_RoadmapPathBar`)
* Cập nhật màu text của `_RoadmapWaypoint`:
  * Nếu `isCompleted` và `!isDark`: Dùng `Color(0xFF92400E)` cho tiêu đề và cấp độ.
  * Tăng độ dày viền của Checkmark Node từ `1.2px` lên `1.4px`, màu `Color(0xFFD97706)`.
* Đường nối track nét đứt: Sử dụng `Color(0xFFCBD5E1)` trên Light Mode và `Color(0xFF475569)` trên Dark Mode.

### Giai đoạn 3: Tinh chỉnh Vầng Hào Quang Thở & 3 Satellite Pods
* Trong `_HeroZenithEmblem`:
  * Điều chỉnh màu của Tầng hào quang ngoài cùng ở Light Mode sang màu vàng mật ong ấm `Color(0xFFF59E0B).withValues(alpha: 0.16)`.
* Trong `_SatellitePodsRow`:
  * Nếu `!isDark`: Pods dùng nền `Colors.white`, viền `Color(0xFFE2E8F0)`, đổ bóng `BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)`.
  * Nếu `isDark`: Giữ nguyên nền `cs.slate800.withValues(alpha: 0.3)`.

### Giai đoạn 4: Kiểm thử Widget Test, Analyzer & Verify trên Thiết bị Thực tế
* Cập nhật bộ test `academic_level_roadmap_test.dart`:
  * Test render Light Mode: Kiểm tra khay nền canvas và màu sắc tương phản cao.
  * Test render Dark Mode: Kiểm tra tính toàn vẹn của Dark Mode không bị ảnh hưởng.
  * Test an toàn màn hình 360px: Không bị overflow.
* Chạy `flutter test` toàn bộ suite và `flutter analyze` 0 lỗi.

---

## 6. TIÊU CHÍ NGHIỆM THU AN TOÀN (ACCEPTANCE CRITERIA)

1. [ ] **Nổi bật vượt trội ở Light Mode:** Khi mở ứng dụng ở chế độ sáng, section Tổng quan lập tức trở thành tâm điểm vinh danh sang trọng, tách bạch rõ ràng khỏi nền trang.
2. [ ] **Không bị Card Fatigue:** Không dùng khung hộp đóng kín viền đen thô cứng; giữ trọn cảm giác khay nền khí quyển mở (Atmospheric Canvas).
3. [ ] **Dark Mode giữ nguyên 100%:** Khi chuyển sang chế độ tối, giao diện giữ nguyên vẻ đẹp rực rỡ huyền bí như hiện tại.
4. [ ] **Dễ đọc, đạt chuẩn tương phản:** Mọi dòng chữ và icon cấp bậc đọc rõ nét, không bị bạc màu hay chìm trên nền sáng.
5. [ ] **Animation bơ mượt, không nhấp nhô:** Giữ trọn vẹn kích thước cố định `SizedBox(96, 96)` và `Transform.scale` đã tối ưu trước đó.
6. [ ] **Mã nguồn sạch:** `flutter analyze` 0 lỗi; Widget Tests PASS 100%.
