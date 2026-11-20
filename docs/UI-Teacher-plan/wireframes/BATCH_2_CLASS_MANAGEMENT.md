# ĐẶC TẢ WIREFRAME — ĐỢT 2: CLASS ACADEMIC MANAGEMENT
**Tài liệu tham chiếu:** [UI-Teacher-plan.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/UI-Teacher-plan.md) | [WIREFRAME_EXECUTION_PLAN.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/WIREFRAME_EXECUTION_PLAN.md)  
**Phạm vi:** Tab Lớp học (`SCR-10`), Chi tiết Lớp học 5 Sub-tabs (`SCR-12`), Phân công Giáo viên (`SCR-13A`), Quản lý Học viên (`SCR-13B`), Soạn lịch học (`SCR-07`), Chi tiết & Chấm bài tập (`SCR-14`), Giao bài mới (`SCR-15`), và Bảng điểm Sư phạm (`SCR-16`).  
**Chuẩn màn hình:** 390dp x 844dp. Hệ thống lưới 4-point / 8-point grid.

---

## 1. SCR-10: DANH SÁCH LỚP HỌC (TEACHER CLASSES SCREEN)

### 1.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [RoleAppHeader] LỚP HỌC                        [Avatar] │
├─────────────────────────────────────────────────────────┤
│ [Workplace Selector Bar: 🏢 ForteX Academy ▾]           │
├─────────────────────────────────────────────────────────┤
│ [🔍 Tìm kiếm lớp theo tên hoặc mã...]          h: 40dp │
│                                                         │
│ TABS PHÂN LOẠI QUẢN TRỊ (Segmented Button):             │
│ ┌──────────────────────────┬──────────────────────────┐ │
│ │  ĐƯỢC PHÂN CÔNG (4)      │  TÔI QUẢN LÝ (2)         │ │
│ └──────────────────────────┴──────────────────────────┘ │
│                                                         │
│ BỘ LỌC TRẠNG THÁI: [ Tất cả ] [ Đang mở ] [ Đã lưu trữ ]│
├─────────────────────────────────────────────────────────┤
│ DANH SÁCH LỚP HỌC (Cuộn dọc):                           │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ CARD LỚP HỌC                                h: 168dp│ │
│ │ TOÁN NÂNG CAO 10A1                                  │ │
│ │ Khóa học: Đại số & Giải tích 10                     │ │
│ │ [Badge: ĐANG MỞ (Xanh)]   [Badge: GV CHÍNH (Tím)]   │ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ 👥 Sĩ số: 30/35 học sinh  ·  Lịch: T2, T4, T6       │ │
│ │ ⏰ Giờ học: 15:00 - 16:30 ·  Phòng: P.302          │ │
│ │ 📊 Tiến độ: Đã dạy 12/36 buổi (33%)                 │ │
│ │                                                     │ │
│ │ [Nút CTA Viền: VÀO QUẢN LÝ LỚP HỌC >]       (h: 36dp)│ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ CARD LỚP HỌC                                        │ │
│ │ TIN HỌC CƠ BẢN 11B                                  │ │
│ │ Khóa học: Lập trình Python ứng dụng                 │ │
│ │ [Badge: ĐANG MỞ]          [Badge: TRỢ GIẢNG]        │ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ 👥 Sĩ số: 25 học sinh     ·  Lịch: T3, T5 (Online)  │ │
│ │ 📊 Tiến độ: Đã dạy 4/24 buổi                        │ │
│ │ [Nút CTA Viền: VÀO QUẢN LÝ LỚP HỌC >]               │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [Floating Action Button: + Tạo lớp mới]                 │
│ (Chỉ hiển thị khi có quyền hoặc đang ở phạm vi Cá nhân) │
└─────────────────────────────────────────────────────────┘
```

### 1.2. Hợp đồng API & Quy tắc Hiển thị (SCR-10)
- **Tab "Được phân công":** Gọi `GET /api/classes/me` (Lớp người dùng được gán dạy).
- **Tab "Tôi quản lý":** Gọi `GET /api/classes` (Lớp người dùng có quyền quản trị/chủ nhiệm).
- **Phạm vi Workplace:** Tự động lọc theo `organization_id == active_org_id`.
- **Lớp đã lưu trữ (`is_archived = true`):** Hiện badge xám `ĐÃ LƯU TRỮ`, toàn bộ các hành động sửa bên trong lớp sẽ tự động chuyển sang chế độ Chỉ đọc.

---

## 2. SCR-12: MÀN HÌNH CHI TIẾT LỚP HỌC ĐA PHÂN HỆ (5 SUB-TABS)

### 2.1. Cấu trúc Khung Dựng Chung & Thanh 5 Sub-Tabs
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   TOÁN NÂNG CAO 10A1             [Edit/••]  │
│ Mã lớp: CLS-10A1 · Trạng thái: Đang hoạt động           │
├─────────────────────────────────────────────────────────┤
│ THANH 5 SUB-TABS (Cuộn ngang linh hoạt):                │
│ [Tổng quan]  [Buổi học]  [Học viên]  [Bài tập]  [Bảng điểm]│
├─────────────────────────────────────────────────────────┤
│ >>> NỘI DUNG TỪNG SUB-TAB HIỂN THỊ BÊN DƯỚI <<<         │
└─────────────────────────────────────────────────────────┘
```

---

### 2.2. Sub-tab 1: Tổng quan Lớp học (Class Overview)
```text
┌─────────────────────────────────────────────────────────┐
│ THÔNG TIN KHÓA HỌC LIÊN KẾT                             │
│ Khóa: Đại số & Giải tích 10 Nâng cao                    │
│ Niên khóa: 2026 - 2027  ·  Phòng học mặc định: P.302    │
│                                                         │
│ ĐỘI NGŨ GIẢNG DẠY PHỤ TRÁCH                             │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ • GV Chính: ThS. Nguyễn Văn A (Bạn)                 │ │
│ │ • Trợ giảng: Lê Hoàng Nam                           │ │
│ │                                                     │ │
│ │ [Nút Viền: PHÂN CÔNG GIÁO VIÊN & TRỢ GIẢNG >] (SCR-13A│ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ LỊCH HỌC LẶP TRONG TUẦN                                 │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ • Thứ Hai:   15:00 - 16:30 (P.302)                  │ │
│ │ • Thứ Tư:    15:00 - 16:30 (P.302)                  │ │
│ │ • Thứ Sáu:   15:00 - 16:30 (P.302)                  │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ CHỈ SỐ LỚP HỌC TỔNG QUAN                                │
│ ┌──────────────────────┐     ┌────────────────────────┐ │
│ │ 👥 SĨ SỐ HỌC SINH    │     │ 📊 CHUYÊN CẦN TB       │ │
│ │ 30 / 35 học sinh     │     │ 94.5% có mặt           │ │
│ └──────────────────────┘     └────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

### 2.3. Sub-tab 2: Buổi học & Lịch ca dạy (Class Sessions)
```text
┌─────────────────────────────────────────────────────────┐
│ [Thanh công cụ]: [+ Tạo buổi lẻ]  [⚡ Sinh buổi tự động]│
├─────────────────────────────────────────────────────────┤
│ DANH SÁCH TOÀN BỘ CÁC BUỔI HỌC (Cuộn dọc):              │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ BUỔI 13: KHẢO SÁT HÀM SỐ BẬC BA      [🟢 SẮP DIỄN RA]│ │
│ │ Thứ Tư, 12/11/2026 · 15:00 - 16:30 · P.302          │ │
│ │ [Điểm danh: 26/30]  ·  [Học liệu: 1 bài giảng PDF]  │ │
│ │ [Nút text: Vào chi tiết buổi >] (Mở SCR-06)         │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ BUỔI 12: ĐỒ THỊ VÀ CỰC TRỊ           [✓ ĐÃ HOÀN THÀNH│ │
│ │ Thứ Hai, 10/11/2026 · 15:00 - 16:30 · P.302          │ │
│ │ [Điểm danh: 30/30 đã có mặt]                         │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ BUỔI 14: BÀI TẬP ÔN TẬP CHƯƠNG       [⏳ ĐÃ LÊN LỊCH]│ │
│ │ Thứ Sáu, 14/11/2026 · 15:00 - 16:30 · P.302          │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```
- **Hành động "Sinh buổi tự động":** Gọi `POST /api/classes/:id/sessions/generate` -> Sinh toàn bộ các buổi học lẻ dựa trên lịch lặp của lớp.

---

### 2.4. Sub-tab 3: Học viên & Ghi danh (Class Students & SCR-13B)
```text
┌─────────────────────────────────────────────────────────┐
│ Sĩ số: 30 học sinh                    [+ GHI DANH MỚI]  │
│ [🔍 Tìm kiếm học sinh trong lớp...]                     │
├─────────────────────────────────────────────────────────┤
│ 1. [Avatar] NGUYỄN MINH ANH                             │
│    Mã: HS00124 · Ngày vào: 01/09/2026                   │
│    📊 Chuyên cần: 98% (12/12 buổi có mặt)               │
│    [📞 Gọi PH: 0912•••789]  [⋮ Menu: Xóa khỏi lớp]      │
│ ─────────────────────────────────────────────────────── │
│ 2. [Avatar] TRẦN HOÀNG LAN                              │
│    Mã: HS00125 · Ngày vào: 01/09/2026                   │
│    📊 Chuyên cần: 75% (Vắng 3 buổi)                     │
│    [📞 Gọi PH: 0988•••123]  [⋮ Menu: Xóa khỏi lớp]      │
│ ─────────────────────────────────────────────────────── │
│ 3. [Avatar] LÊ THỊ MAI                                  │
│    Mã: HS00130 · Ngày vào: 15/09/2026                   │
│    📊 Chuyên cần: 92%                                   │
│    [📞 Gọi PH: 0905•••456]  [⋮ Menu: Xóa khỏi lớp]      │
└─────────────────────────────────────────────────────────┘
```
- **Modal Ghi danh mới (`SCR-13B`):** Mở danh sách học sinh chưa có lớp (`GET /api/classes/:id/enrollable-students?keyword=`) -> Chọn checkbox -> Bấm *"Thêm vào lớp"* (`POST /api/classes/:id/students`).

---

### 2.5. Sub-tab 4: Bài tập & Kiểm tra (Assignments & SCR-14/SCR-15)
```text
┌─────────────────────────────────────────────────────────┐
│ Danh sách bài tập đã giao             [+ GIAO BÀI TẬP]  │
│                                           (Mở SCR-15)   │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 💻 BÀI TẬP LẬP TRÌNH 01: TÍNH TỔNG DÃY SỐ           │ │
│ │ Loại: Homework · Ngôn ngữ: C++, Python              │ │
│ │ [Badge: ĐANG MỞ NỘP]      [Hạn nộp: 15/11 · 23:59]  │ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ 📥 Tiến độ nộp bài: 24 / 30 học sinh đã nộp bài     │ │
│ │ 🟢 Đạt chuẩn (Accepted): 18 em                      │ │
│ │ 🔴 Chưa đạt (Wrong Answer/Compile Error): 6 em      │ │
│ │                                                     │ │
│ │ [Nút CTA Viền: XEM BÀI NỘP & CHẤM CODE >] (Mở SCR-14│ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 📝 BÀI KIỂM TRA 15 PHÚT: ĐẠI SỐ CHƯƠNG 1           │ │
│ │ Loại: Quiz · Trắc nghiệm 10 câu                     │ │
│ │ [Badge: ĐÃ ĐÓNG NỘP]                                │ │
│ │ 📥 Đã nộp: 30 / 30 học sinh  ·  Điểm TB: 8.2 / 10   │ │
│ │ [Nút CTA Viền: XEM KẾT QUẢ KIỂM TRA >]              │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

### 2.6. Sub-tab 5: Bảng điểm Sư phạm (Class Gradebook & SCR-16)
```text
┌─────────────────────────────────────────────────────────┐
│ BẢNG ĐIỂM TỔNG HỢP                 [⚙️ Cấu hình cột điểm│
│ Chế độ xem: [• Theo học viên]  [ Theo bảng cuộn ngang]  │
├─────────────────────────────────────────────────────────┤
│ 1. [Avatar] NGUYỄN MINH ANH                             │
│    Mã: HS00124                                          │
│    ┌──────────────────────────────────────────────────┐ │
│    │ • Điểm 15 phút (HS 1):      [ 9.0 ]              │ │
│    │ • Giữa kỳ (HS 2):           [ 8.5 ]              │ │
│    │ • Cuối kỳ (HS 3):           [ --- ] (Chưa nhập)  │ │
│    │ • ĐIỂM TỔNG KẾT TẠM TÍNH:   8.7 / 10             │ │
│    └──────────────────────────────────────────────────┘ │
│ ─────────────────────────────────────────────────────── │
│ 2. [Avatar] TRẦN HOÀNG LAN                              │
│    Mã: HS00125                                          │
│    ┌──────────────────────────────────────────────────┐ │
│    │ • Điểm 15 phút (HS 1):      [ 7.0 ]              │ │
│    │ • Giữa kỳ (HS 2):           [ 6.5 ]              │ │
│    │ • Cuối kỳ (HS 3):           [ --- ]              │ │
│    │ • ĐIỂM TỔNG KẾT TẠM TÍNH:   6.7 / 10             │ │
│    └──────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────┤
│ [STICKY BOTTOM BAR: h: 64dp]                            │
│ [Nút Viền: TÍNH ĐIỂM TỔNG KẾT]   [NÚT ĐỎ: CHỐT SỔ ĐIỂM] │
└─────────────────────────────────────────────────────────┘
```
- **Hành động Chốt sổ điểm (`SCR-16B`):** Bật Dialog cảnh báo: *"Sau khi chốt sổ, toàn bộ điểm số sẽ bị khóa vĩnh viễn và gửi về hệ thống học vụ của trường. Bạn có chắc chắn muốn chốt điểm?"*. Khi xác nhận -> Gọi `POST /api/classes/:id/final-grades/finalize`.

---

## 3. SCR-14: CHI TIẾT BÀI TẬP & TRÌNH CHẤM CODE NỘP BÀI

### 3.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   BÀI TẬP: TÍNH TỔNG DÃY SỐ     [Publish ▾] │
│ Hạn nộp: 15/11/2026 · 23:59                             │
├─────────────────────────────────────────────────────────┤
│ TABS CHUYÊN MÔN:                                        │
│ [ Đề bài & Testcase ]      [ Danh sách bài nộp (24) ]   │
├─────────────────────────────────────────────────────────┤
│ DANH SÁCH BÀI NỘP CỦA HỌC SINH:                         │
│ [🔍 Tìm học sinh...]       [Lọc: Tất cả / Đạt / Chưa đạt]│
│                                                         │
│ 1. [Avatar] NGUYỄN MINH ANH                             │
│    Nộp lúc: 14/11 · 20:15  ·  Lần nộp thứ: 2            │
│    Kết quả chấm: [🟢 ACCEPTED 10/10 TESTCASES]          │
│    Thời gian: 0.05s  ·  Bộ nhớ: 12MB                    │
│    [Nút: XEM CODE HỌC SINH NỘP >]                       │
│ ─────────────────────────────────────────────────────── │
│ 2. [Avatar] LÊ THỊ MAI                                  │
│    Nộp lúc: 14/11 · 21:30  ·  Lần nộp thứ: 1            │
│    Kết quả chấm: [🔴 WRONG ANSWER (Testcase 4 failed)]  │
│    [Nút: XEM CODE HỌC SINH NỘP >]                       │
│ ─────────────────────────────────────────────────────── │
│ 3. [Avatar] HOÀNG VĂN NAM                               │
│    Nộp lúc: 15/11 · 10:00  ·  Lần nộp thứ: 1            │
│    Kết quả chấm: [🟠 COMPILE ERROR]                     │
│    [Nút: XEM CHI TIẾT LỖI BIÊN DỊCH >]                  │
└─────────────────────────────────────────────────────────┘
```

### 3.2. Modal Trình Xem Mã Nguồn (Code Viewer Sheet)
Khi bấm "Xem code học sinh nộp", mở Bottom Sheet toàn màn hình:
- Tên học sinh, ngôn ngữ code (`C++` / `Python`).
- Khung hiển thị code với nền tối (`surfaceContainerHighest`), có số dòng (Line numbers), highlight cú pháp (Syntax highlighting), ở chế độ **Read-only**.
- Bảng chi tiết kết quả từng Testcase: Input, Output thực tế, Output kỳ vọng (đối với testcase công khai), và thời gian thực thi.

---

## 4. SCR-07: SOẠN LỊCH HỌC & BUỔI HỌC (SCHEDULE EDITOR)

### 4.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Hủy]         THIẾT LẬP LỊCH DẠY             [LƯU]   │
├─────────────────────────────────────────────────────────┤
│ LOẠI LỊCH (Segmented Control):                          │
│ ┌──────────────────────────┬──────────────────────────┐ │
│ │  BUỔI HỌC LẺ (Session)   │  LỊCH LẶP TUẦN (Schedule)│ │
│ └──────────────────────────┴──────────────────────────┘ │
│                                                         │
│ FORM THÔNG TIN:                                         │
│ • Chọn lớp học *                                        │
│   [ Toán 10A1 - Nâng cao                             ▾] │
│                                                         │
│ • Ngày học (Date Picker) *                              │
│   [ 12/11/2026                                       📅]│
│                                                         │
│ • Khung giờ (Time Pickers) *                            │
│   Bắt đầu: [ 15 : 00 ]    Kết thúc: [ 16 : 30 ]         │
│                                                         │
│ • Chủ đề buổi học                                       │
│   [ Khảo sát sự biến thiên hàm số bậc ba              ] │
│                                                         │
│ • Hình thức giảng dạy:                                  │
│   (•) Trực tiếp tại phòng  -> Phòng học: [ P.302     ]  │
│   ( ) Trực tuyến           -> [Tự động tạo phòng Live]  │
│                                                         │
│ • Ghi chú chuẩn bị cho học sinh                         │
│   [ Mang theo máy tính bỏ túi và thước kẻ...         ] │
│                                                         │
│ [STICKY FOOTER: HỦY BỎ | XÁC NHẬN TẠO BUỔI HỌC]         │
└─────────────────────────────────────────────────────────┘
```

---

## 5. CHECKLIST HOÀN THÀNH ĐỢT 2
- [x] Đã thiết kế hoàn chỉnh luồng Quản trị Lớp học đa phân hệ 5 Sub-tabs.
- [x] Đã bóc tách rõ ràng giữa `SCR-13A` (Phân công GV) và `SCR-13B` (Ghi danh học viên).
- [x] Đã tối ưu hóa trải nghiệm bảng điểm di động sang dạng "Single-column Batch Entry" thay vì ép ma trận 2D.
- [x] Đã bổ sung trình xem code nộp bài và chi tiết kết quả testcase cho bài tập lập trình.
