# ĐẶC TẢ WIREFRAME — ĐỢT 1: CORE DAILY TEACHING & SHELL
**Tài liệu tham chiếu:** [UI-Teacher-plan.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/UI-Teacher-plan.md) | [WIREFRAME_EXECUTION_PLAN.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/WIREFRAME_EXECUTION_PLAN.md)  
**Phạm vi:** Khung điều hướng Shell 5 Tabs, Tab Hôm nay, Bộ chọn nơi làm việc, Tab Lịch dạy, Chi tiết Buổi học, và Màn hình Điểm danh nhanh.  
**Chuẩn màn hình:** 390dp x 844dp (Base density: MDPI 1dp = 1px, scale ratio 390pt).  
**Hệ thống lưới:** 4-point / 8-point grid. Lề chuẩn: `screenPadding: 24dp` (nội dung danh sách), `cardPadding: 16dp`.

---

## 1. KHUNG ĐIỀU HƯỚNG TỔNG THỂ: TEACHER SHELL & GLOBAL HEADER

### 1.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐ 390dp
│ [Status Bar: 09:41 · 5G · Pin 100%]             h: 44dp │
├─────────────────────────────────────────────────────────┤
│ [RoleAppHeader]                                 h: 64dp │
│  (•) GIÁO VIÊN 40STUDY                     [🔔]  [Avatar]│
│  Tiêu đề Trang Lớn (headlineSmall: 24sp)               │
├─────────────────────────────────────────────────────────┤
│ ╭─────────────────────────────────────────────────────╮ │
│ │ [CurvedSurfaceTray] (Top radius: 24dp)               │ │
│ │                                                     │ │
│ │  >>> NỘI DUNG CUỘN CỦA TAB ĐANG CHỌN (TỪNG SCR) <<<  │ │
│ │                                                     │ │
│ ╰─────────────────────────────────────────────────────╯ │
├─────────────────────────────────────────────────────────┤
│ [TeacherBottomNavigationBar]                    h: 72dp │
│ ┌───────┐   ┌───────┐   ┌───────┐   ┌───────┐   ┌───────┐│
│ │  [■]  │   │  [□]  │   │  [□]  │   │  [□]  │   │  [□]  ││
│ │Hôm nay│   │Lịchdạy│   │Lớp học│   │Khóahọc│   │Tàikhoản│
│ └───────┘   └───────┘   └───────┘   └───────┘   └───────┘│
│ [Home Indicator Pill: w: 134dp, h: 5dp]         h: 16dp │
└─────────────────────────────────────────────────────────┘
```

### 1.2. Bóc tách Component & Design Tokens
| Phân vùng | Tên Widget Flutter | Kích thước / Spacing | Token Màu sắc | Token Typography | Ghi chú |
|:---|:---|:---|:---|:---|:---|
| **Header** | `RoleAppHeader` | `h: 64dp`, `px: 24dp` | `surface` | `labelSmall` (Vai trò) & `headlineSmall` (24sp) | Dùng chung toàn app, avatar chạm mở Tab 5 |
| **Khay bề mặt**| `CurvedSurfaceTray` | `topRadius: 24dp` | `surfaceContainerLowest` / `surface` | - | Tạo độ chuyển tiếp mềm mại từ header xuống content |
| **Thanh Bottom**| `TeacherBottomNav` | `h: 72dp + insets` | `surfaceContainerLow`, border `outlineVariant` | `labelSmall` (11sp, bold khi active) | 5 Tabs; Icon 24dp (Filled khi active, Outlined khi inactive) |

---

## 2. SCR-03: MÀN HÌNH HÔM NAY (TEACHER HOME SCREEN)

### 2.1. Mục tiêu UX & Điểm vào
- **Mục tiêu:** Giúp giáo viên ngay khi mở app trong 3 giây đầu tiên nắm được: *Ca dạy tiếp theo lúc mấy giờ, ở đâu, đếm lùi bao lâu và vào lớp / điểm danh bằng cách nào.*
- **Điểm vào:** Tab 1 trên Bottom Navigation Bar.

### 2.2. Sơ đồ Khung Dựng (Box-Drawing Canvas - Loaded State)
```text
┌─────────────────────────────────────────────────────────┐
│ [Workplace Selector Bar]                        h: 44dp │
│ 🏢 ForteX Academy - Cơ sở 1                    [▾ Đổi]  │
├─────────────────────────────────────────────────────────┤
│ Chào Thầy Nguyễn Văn A,                                 │
│ Thứ Tư, 12/11/2026                            [💬 Inbox]│
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🎯 HERO CARD: BUỔI HỌC TIẾP THEO            h: 176dp│ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ 🟢 SẮP DIỄN RA  ·  Còn 25 phút nữa                  │ │
│ │ LỚP TOÁN NÂNG CAO 10A1                              │ │
│ │ ⏰ 15:00 - 16:30   ·   📍 Phòng P.302 (Cơ sở 1)     │ │
│ │ 📖 Chủ đề: Khảo sát sự biến thiên hàm số bậc ba     │ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ [Nút CTA Chính: VÀO PHÒNG DẠY / ĐIỂM DANH] (h: 44dp)│ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [!] CẢNH BÁO TRÙNG LỊCH (Chỉ hiện khi phát hiện overlap)│
│ ⚠️ Có 2 ca dạy trùng khung giờ 15:00 - 16:30            │
│                                                         │
│ LỊCH HÔM NAY (3 ca dạy)                     [Xem lịch >]│
│ ┌─────────────────────────────────────────────────────┐ │
│ │ • 08:00 - 09:30 | Lớp 10B | P.201       [✓ ĐÃ XONG] │ │
│ │ • 15:00 - 16:30 | Lớp 10A1| P.302       [🟢 SẮP TỚI]│ │
│ │ • 17:30 - 19:00 | Lớp 11A | LiveKit     [⏳ ĐÃ LỊCH]│ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ TÁC VỤ GIẢNG DẠY NHANH                                  │
│ ┌────────────────────────┐   ┌────────────────────────┐ │
│ │ [Icon Lớp] Lớp học     │   │ [Icon Khóa] Khóa học   │ │
│ │ 4 lớp đang phụ trách   │   │ 2 khóa cá nhân         │ │
│ └────────────────────────┘   └────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 2.3. Bóc tách Component & Design Tokens (SCR-03)
| Khối UI | Tên Component | Layout / Spacing | Màu sắc | Typography | Hành vi tương tác |
|:---|:---|:---|:---|:---|:---|
| **Workplace Bar** | `WorkplaceSelectorPill` | `h: 40dp`, `p: 8dp 16dp`, `radius: 20dp` | `surfaceContainerHigh`, viền `outlineVariant` | `labelMedium` (12sp, semibold) | Chạm mở `MOD-04: WorkplaceSelectorSheet` |
| **Hero Next Session**| `TeacherNextSessionCard`| `p: 16dp`, `radius: 16dp`, `gap: 8dp` | Nền `primaryContainer`, chữ `onPrimaryContainer` | `titleMedium` (16sp, bold), `bodySmall` (12sp) | Chạm card mở `SCR-06`; Bấm CTA mở `SCR-08` hoặc `SCR-32` |
| **CTA Button** | `FilledButton` | `h: 44dp`, `w: full`, `radius: 8dp` | Nền `primary`, chữ `onPrimary` | `labelLarge` (14sp, bold) | Vào thẳng điểm danh hoặc phòng Live |
| **Overlap Warning** | `OverlapWarningBanner` | `p: 12dp 16dp`, `radius: 8dp` | Nền `errorContainer`, chữ `onErrorContainer` | `bodySmall` (12sp, medium) | Cảnh báo khi có 2 ca trùng thời gian |
| **Timeline List** | `TeacherDayTimeline` | `gap: 8dp` | Card `surfaceContainerLow` | `bodyMedium` (14sp) | Chạm từng dòng mở `SCR-06` tương ứng |

### 2.4. Ma trận Trạng thái (SCR-03 States)
- **Empty State (Hôm nay không có ca dạy):** Thay thế Hero Card bằng Illustration bo tròn mềm mại + Text: *"Hôm nay Thầy/Cô không có lịch dạy"*, kèm nút viền *"Xem lịch cả tuần"* dẫn sang Tab 2.
- **Loading Skeleton:** Shimmer xám mô phỏng thanh Workplace, Hero Card lớn và 2 dòng timeline.
- **Error State:** Banner xám bo góc kèm nút *"Thử lại"* gọi lại API `GET /api/me/timetable`.

---

## 3. MOD-04: BOTTOM SHEET CHỌN NƠI LÀM VIỆC (WORKPLACE SELECTOR SHEET)

### 3.1. Sơ đồ Khung Dựng (Modal Bottom Sheet - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ ╭─────────────────────────────────────────────────────╮ │
│ │                [Drag Handle: w: 32dp, h: 4dp]       │ │
│ │ CHỌN NƠI LÀM VIỆC                           [✕ Đóng]│ │
│ │ Lớp học và lịch dạy được lọc theo nơi làm việc.     │ │
│ │ Khóa học và thu nhập luôn thuộc quyền cá nhân.      │ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ ┌─────────────────────────────────────────────────┐ │ │
│ │ │ (•) 👤 CÁ NHÂN (ĐỘC LẬP)                        │ │ │
│ │ │     Các lớp học và lịch dạy do bạn tự mở        │ │ │
│ │ └─────────────────────────────────────────────────┘ │ │
│ │                                                     │ │
│ │ ┌─────────────────────────────────────────────────┐ │ │
│ │ │ ( ) 🏢 TRUNG TÂM LUYỆN THI FORTEX (CƠ SỞ 1)     │ │ │
│ │ │     Vai trò: Giáo viên chính  ·  12 lớp phụ trách│ │ │
│ │ └─────────────────────────────────────────────────┘ │ │
│ │                                                     │ │
│ │ ┌─────────────────────────────────────────────────┐ │ │
│ │ │ ( ) 🏢 TRƯỜNG THPT CHUYÊN VIỆT ANH              │ │ │
│ │ │     Vai trò: Trợ giảng  ·  3 lớp phụ trách      │ │ │
│ │ └─────────────────────────────────────────────────┘ │ │
│ │                                                     │ │
│ │ [Nút CTA: XÁC NHẬN CHUYỂN NƠI LÀM VIỆC] (h: 48dp)   │ │
│ ╰─────────────────────────────────────────────────────╯ │
└─────────────────────────────────────────────────────────┘
```

### 3.2. Đặc tả Dữ liệu & Xử lý (MOD-04)
- **API Trigger:** `POST /api/auth/select-org` với body `{ organization_id: UUID | null }`.
- **Cơ chế:** Khi chọn xong và bấm Xác nhận -> Lưu token mới -> Clear cache provider của Tab 1, 2, 3 -> Tải lại danh sách lớp và lịch theo ngữ cảnh mới.
- **Radio Card UI:** Bo góc `12dp`, viền `1.5dp primary` khi chọn, `outlineVariant` khi chưa chọn.

---

## 4. SCR-05: MÀN HÌNH LỊCH DẠY TUẦN / THÁNG (TEACHER SCHEDULE SCREEN)

### 4.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [RoleAppHeader] LỊCH DẠY                       [Avatar] │
├─────────────────────────────────────────────────────────┤
│ [Workplace Selector Bar: Cơ sở 1 ▾]                     │
├─────────────────────────────────────────────────────────┤
│ [Tháng 11/2026]              [Bộ lọc Lớp ▾]  [Tuần/Tháng]│
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ [<]  T2    T3    T4    T5    T6    T7    CN     [>] │ │
│ │      10    11   [12]   13    14    15    16         │ │
│ │       •    ••   (••)    •                 •         │ │
│ └─────────────────────────────────────────────────────┘ │
│ Đang lọc: Tất cả lớp học (4 buổi trong tuần)            │
│ ─────────────────────────────────────────────────────── │
│ LỊCH DẠY THỨ TƯ, 12/11/2026 (2 ca)                      │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ⏰ 08:00 - 09:30                    [✓ ĐÃ KẾT THÚC] │ │
│ │ Lớp: Toán 10A1 - Nâng cao                           │ │
│ │ 📍 Phòng P.301  ·  Chủ đề: Khảo sát hàm số          │ │
│ │ 👥 Sĩ số: 30/30 học sinh đã điểm danh               │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ⏰ 15:00 - 16:30                    [🟢 ĐÃ LÊN LỊCH] │ │
│ │ Lớp: Tin học 11B                                    │ │
│ │ 🌐 Học trực tuyến (LiveKit Room sẵn sàng)           │ │
│ │ 👥 Sĩ số: 28 học sinh                               │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [Floating Action Button: + Tạo buổi mới] (Góc phải đáy) │
└─────────────────────────────────────────────────────────┘
```

### 4.2. Bóc tách Component & Tương tác (SCR-05)
- **Calendar Strip (`TeacherCalendarStrip`):** Cuộn ngang 7 ngày trong tuần. Ngày hôm nay có vòng tròn bao quanh, ngày đang chọn có nền `primary` chữ trắng. Dưới ngày có dot đếm số lượng ca dạy (`•` 1 ca, `••` 2 ca trở lên).
- **Hợp nhất dữ liệu:** Gọi `GET /api/me/timetable?sessions_from=...&sessions_to=...`. Hệ thống tự loại trừ các `cancelled_occurrences` và gộp buổi học thực tế với lịch lặp.
- **FAB Button:** Chỉ hiển thị khi giáo viên có quyền quản lý ít nhất 1 lớp. Chạm mở `SCR-07`.

---

## 5. SCR-06: MÀN HÌNH CHI TIẾT BUỔI HỌC (TEACHER SESSION SCREEN)

### 5.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]        CHI TIẾT BUỔI HỌC         [Menu •••] │
├─────────────────────────────────────────────────────────┤
│ [Huy hiệu Trạng thái: 🟢 ĐANG DIỄN RA / ⏳ CHƯA DẠY]   │
│                                                         │
│ TIÊU ĐỀ CHỦ ĐỀ BUỔI HỌC                                │
│ Khảo sát sự biến thiên và vẽ đồ thị hàm số bậc ba       │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ THÔNG TIN CHUNG                                     │ │
│ │ • Lớp học:    Toán 10A1 - Nâng cao                  │ │
│ │ • Thời gian:  Thứ Tư, 12/11/2026 · 15:00 - 16:30    │ │
│ │ • Địa điểm:   Phòng học P.302 (Cơ sở 1)             │ │
│ │ • Đơn vị:     Trung tâm ForteX                      │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🌐 PHÒNG HỌC TRỰC TUYẾN (Nếu là ca LiveKit)         │ │
│ │ Trạng thái: Phòng học đã mở, 15 học sinh đang chờ   │ │
│ │ [Nút CTA: VÀO PHÒNG DẠY LIVEKIT NGAY]               │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 👥 TÌNH HÌNH ĐIỂM DANH SĨ SỐ                        │ │
│ │ Tổng sĩ số: 30 học sinh                             │ │
│ │ • Có mặt: 26   ·   Vắng: 2   ·   Chưa ghi nhận: 2   │ │
│ │                                                     │ │
│ │ [Nút CTA Viền: TIẾN HÀNH ĐIỂM DANH HỌC VIÊN >]      │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 📝 GHI CHÚ BUỔI HỌC CỦA GIÁO VIÊN                   │ │
│ │ Yêu cầu học sinh làm bài tập số 4 trang 45 trước... │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 5.2. Menu Hành động Phụ (`Menu •••`) & Phân quyền
- **Nếu `can_manage == true` và lớp không bị archived:**
  - *"Chỉnh sửa thông tin buổi học"* -> Chuyển sang `SCR-07` (Edit mode).
  - *"Hủy ca dạy này"* -> Bật Dialog yêu cầu nhập lý do hủy (`cancel_reason`).
- **Nếu `is_archived == true`:** Menu bị ẩn, toàn bộ nút sửa/điểm danh chuyển sang trạng thái disabled (Chỉ đọc).

---

## 6. SCR-08: MÀN HÌNH ĐIỂM DANH BUỔI HỌC (TEACHER ATTENDANCE SCREEN)

### 6.1. Mục tiêu UX
Cung cấp trải nghiệm điểm danh "bắn tỉa" siêu tốc cho 30–50 học sinh: Chạm một chạm là đổi trạng thái, đếm sĩ số thời gian thực, có nút gọi phụ huynh khi học sinh vắng, và bảo vệ bản nháp tuyệt đối không bị mất dữ liệu.

### 6.2. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   ĐIỂM DANH: TOÁN 10A1                      │
│ Thứ Tư, 12/11 · 15:00 - 16:30                           │
├─────────────────────────────────────────────────────────┤
│ [🔍 Tìm kiếm học sinh theo tên hoặc mã...]     h: 40dp │
│                                                         │
│ DẢI CHIP ĐẾM SĨ SỐ THỜI GIAN THỰC (Horizontal scroll):  │
│ [ Tất cả: 30 ] [ Có mặt: 26 ] [ Vắng: 2 ] [ Chưa ghi: 2]│
│                                                         │
│ [⚡ ĐÁNH DẤU TẤT CẢ CHƯA GHI NHẬN LÀ CÓ MẶT]   (Action) │
├─────────────────────────────────────────────────────────┤
│ DANH SÁCH HỌC SINH (Cuộn dọc):                          │
│                                                         │
│ 1. [Avatar] NGUYỄN MINH ANH                             │
│    Mã: HS00124  ·  Đúng giờ       [🟢 CÓ MẶT ▾]        │
│    Ghi chú: Vào lớp đúng giờ      (Chip xanh lá)        │
│ ─────────────────────────────────────────────────────── │
│ 2. [Avatar] TRẦN HOÀNG LAN                              │
│    Mã: HS00125  ·  Vắng          [🔴 VẮNG K.PHÉP ▾]    │
│    [📞 Gọi phụ huynh: 0912•••789] [💬 Nhắn tin SMS]    │
│ ─────────────────────────────────────────────────────── │
│ 3. [Avatar] LÊ THỊ MAI                                  │
│    Mã: HS00130  ·  Có phép       [🟠 VẮNG CÓ PHÉP ▾]   │
│    Ghi chú: Sốt xuất huyết                              │
│ ─────────────────────────────────────────────────────── │
│ 4. [Avatar] HOÀNG VĂN NAM                               │
│    Mã: HS00135  ·  Chưa điểm     [⚪ CHƯA GHI ▾]       │
│    (Chạm trực tiếp để chọn nhanh)                       │
├─────────────────────────────────────────────────────────┤
│ [STICKY BOTTOM ACTION BAR: h: 68dp]                     │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ⚠️ Có 3 thay đổi chưa lưu                           │ │
│ │ [Nút Nổi Bật: LƯU ĐIỂM DANH NGAY (POST BULK)]       │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 6.3. Bóc tách Component & 4 Trạng thái Điểm danh
| Trạng thái | Mã Enum Backend | Màu sắc UI Token | Hành vi khi chạm |
|:---|:---|:---|:---|
| **Có mặt** | `present` | Nền xanh lá `tertiaryContainer`, chữ `onTertiaryContainer` | Chạm chuyển vòng tròn hoặc mở Bottom Sheet chọn nhanh |
| **Vắng không phép**| `absent` | Nền đỏ `errorContainer`, chữ `onErrorContainer` | Hiện icon gọi khẩn cấp `parent_phone` |
| **Vắng có phép** | `excused` | Nền cam `secondaryContainer`, chữ `onSecondaryContainer` | Mở ô nhập ghi chú lý do nghỉ |
| **Đi muộn** | `late` | Nền vàng hổ phách `surfaceContainerHighest` | Ghi nhận thời gian đến muộn |
| **Chưa ghi nhận** | *(UI-only state)* | Nền xám nhạt `surfaceContainerLow` | Trạng thái mặc định khi mới mở danh sách |

### 6.4. Cơ chế Draft & Thoát An Toàn (Draft Protection)
1. Khi giáo viên thay đổi bất kỳ trạng thái nào -> Biến đếm `dirtyCount++` -> Thanh **Sticky Bottom Action Bar** trượt từ dưới lên (Slide-up animation).
2. Khi giáo viên bấm nút `Back` (hoặc vuốt cạnh màn hình để thoát):
   - Nếu `dirtyCount == 0`: Thoát bình thường.
   - Nếu `dirtyCount > 0`: Kích hoạt Dialog xác nhận:
     ```text
     ┌──────────────────────────────────────────────┐
     │ ⚠️ BẠN CÓ THAY ĐỔI CHƯA LƯU                  │
     │ Kết quả điểm danh của 3 học sinh chưa được   │
     │ gửi lên máy chủ. Bạn có muốn lưu ngay không? │
     │                                              │
     │ [Bỏ thay đổi]  [Tiếp tục sửa]  [LƯU & THOÁT] │
     └──────────────────────────────────────────────┘
     ```
3. Khi bấm **Lưu & Thoát**: Gọi `POST /api/sessions/:sessionId/attendances/bulk`, hiện Loading Overlay, lưu thành công -> Hiển thị SnackBar xanh *"Điểm danh thành công"* -> Quay lại `SCR-06`.

---

## 7. CHECKLIST HOÀN THÀNH ĐỢT 1
- [x] Đã bóc tách cấu trúc 5 màn hình cốt lõi của Đợt 1.
- [x] Đã đối soát 100% enum trạng thái điểm danh và API endpoints với Backend.
- [x] Đã chuẩn hóa cơ chế Sticky Bar và Draft Protection cho thao tác di động.
- [x] Sẵn sàng chuyển giao dữ liệu để đưa vào file Visual HTML Mockup.
