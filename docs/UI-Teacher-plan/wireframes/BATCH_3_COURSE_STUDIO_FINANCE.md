# ĐẶC TẢ WIREFRAME — ĐỢT 3: COURSE STUDIO & FINANCE
**Tài liệu tham chiếu:** [UI-Teacher-plan.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/UI-Teacher-plan.md) | [WIREFRAME_EXECUTION_PLAN.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/WIREFRAME_EXECUTION_PLAN.md)  
**Phạm vi:** Tab Khóa học (`SCR-17`), Biên tập Khóa & Giá gộp (`SCR-18`), Trung tâm Điều hành Khóa (`SCR-20`), Biên soạn Cây Giáo trình (`SCR-21`), Danh mục Nội dung Bài (`SCR-22`), Trình Biên tập Nội dung (`SCR-23`), Checklist Nộp duyệt (`SCR-24`), Ví Giảng viên (`SCR-26`), Modal Rút tiền An toàn (`MOD-28`), Cập nhật Ngân hàng (`MOD-29`), và Lịch sử Giao dịch/Rút tiền (`SCR-27`).  
**Chuẩn màn hình:** 390dp x 844dp. Lưới 4-point / 8-point grid.

---

## 1. SCR-17: DANH SÁCH KHÓA HỌC CÁ NHÂN (TEACHER COURSES SCREEN)

### 1.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [RoleAppHeader] KHÓA HỌC CÁ NHÂN               [Avatar] │
├─────────────────────────────────────────────────────────┤
│ [Dòng thông tin phạm vi: 👤 Khóa học luôn thuộc Cá nhân]│
├─────────────────────────────────────────────────────────┤
│ [🔍 Tìm kiếm khóa học...]            [💳 VÍ THU NHẬP >] │
│                                             (Mở SCR-26) │
│ TABS TRẠNG THÁI DUYỆT (Cuộn ngang):                     │
│ [ Tất cả (5) ] [ Nháp (2) ] [ Chờ duyệt (1) ] [ Đã duyệt]│
├─────────────────────────────────────────────────────────┤
│ DANH SÁCH KHÓA HỌC (Cuộn dọc):                          │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ CARD KHÓA HỌC                               h: 196dp│ │
│ │ ┌─────────────────────────────────────────────────┐ │ │
│ │ │ [ẢNH THUMBNAIL KHÓA HỌC: h: 90dp]               │ │ │
│ │ │ Badge trạng thái nổi: [🟡 CHỜ ADMIN PHÊ DUYỆT]  │ │ │
│ │ └─────────────────────────────────────────────────┘ │ │
│ │ LẬP TRÌNH FLUTTER CHO NGƯỜI MỚI BẮT ĐẦU             │ │
│ │ 📚 10 Chương · 45 Bài học  ·  Cấp độ: Cơ bản        │ │
│ │ 💰 Học phí: 599.000 đ      ·  👥 120 Học viên       │ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ [Nút CTA Viền: VÀO QUẢN TRỊ KHÓA HỌC >]     (SCR-20)│ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ CARD KHÓA HỌC                                       │ │
│ │ ┌─────────────────────────────────────────────────┐ │ │
│ │ │ [ẢNH THUMBNAIL KHÓA HỌC]                        │ │ │
│ │ │ Badge trạng thái: [🔴 CẦN CHỈNH SỬA LẠI]        │ │ │
│ │ └─────────────────────────────────────────────────┘ │ │
│ │ CẤU TRÚC DỮ LIỆU & GIẢI THUẬT NÂNG CAO              │ │
│ │ ⚠️ Lý do từ chối: "Có 3 bài học chưa có nội dung"  │ │
│ │ [Nút CTA Viền: XEM CHI TIẾT & SỬA LẠI >]            │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [Floating Action Button: + Tạo khóa mới]                │
└─────────────────────────────────────────────────────────┘
```

---

## 2. SCR-18: BIÊN TẬP THÔNG TIN CƠ BẢN & HỌC PHÍ (COURSE METADATA & PRICING EDITOR)

### 2.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]    THÔNG TIN & HỌC PHÍ KHÓA HỌC     [LƯU]   │
├─────────────────────────────────────────────────────────┤
│ [PHẦN 1: THÔNG TIN CƠ BẢN]                              │
│ • Ảnh Thumbnail khóa học:                               │
│   ┌─────────────────────────────────────────────────┐   │
│   │ [Icon Upload] Chạm để tải ảnh bìa (Tỷ lệ 16:9)  │   │
│   └─────────────────────────────────────────────────┘   │
│                                                         │
│ • Tiêu đề khóa học *                                    │
│   [ Lập trình Flutter từ Cơ bản đến Nâng cao         ]  │
│                                                         │
│ • Danh mục & Cấp độ *                                   │
│   Danh mục: [ Lập trình di động ▾]  Cấp độ: [ Cơ bản ▾] │
│                                                         │
│ • Mô tả ngắn gọn (Subtitle)                             │
│   [ Nắm vững ngôn ngữ Dart và xây dựng app cross-pla ]  │
│                                                         │
│ • Mô tả chi tiết (Description Markdown)                 │
│   [ Soạn thảo nội dung giới thiệu khóa học...        ]  │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│ [PHẦN 2: THIẾT LẬP HỌC PHÍ & KHUYẾN MÃI]                │
│ • Khóa học miễn phí (is_free):                 [Switch:○]│
│                                                         │
│ • Giá niêm yết (price) *                                │
│   [ 599.000                                          đ] │
│                                                         │
│ • Giá khuyến mãi (discount_price)                       │
│   [ 399.000                                          đ] │
│                                                         │
│ • Hạn khuyến mãi (discount_expires_at)                  │
│   [ 30/11/2026 · 23:59                               📅]│
│                                                         │
│ [STICKY FOOTER: HỦY BỎ | LƯU THAY ĐỔI]         h: 64dp  │
└─────────────────────────────────────────────────────────┘
```
- **Hợp nhất kỹ thuật:** Đã gộp cả thông tin cơ bản và học phí vào cùng màn hình `SCR-18`, khớp 100% với file `course_metadata_editor.dart` trong code mobile.

---

## 3. SCR-20: TRUNG TÂM ĐIỀU HÀNH KHÓA HỌC (COURSE DETAIL SCREEN)

### 3.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   FLUTTER CHO NGƯỜI MỚI          [Menu •••] │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🟡 BANNER TRẠNG THÁI PHÊ DUYỆT (PENDING_REVIEW)     │ │
│ │ Khóa học đang được Ban Quản Trị thẩm định chất lượng│ │
│ │ Trong thời gian này, nội dung giáo trình bị khóa    │ │
│ │ chỉnh sửa để đảm bảo tính nhất quán.                │ │
│ │                                                     │ │
│ │ [Nút Viền Nhỏ: RÚT YÊU CẦU DUYỆT ĐỂ CHỈNH SỬA]      │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ THÔNG TIN TỔNG QUAN                                 │ │
│ │ [Thumbnail 16:9 nhỏ] Mã khóa: CR-FLUTTER-01         │ │
│ │ • 10 Chương · 45 Bài học · Thời lượng: 12 giờ       │ │
│ │ • Học phí: 399.000 đ (Đang giảm từ 599.000 đ)       │ │
│ │ • Số học viên đã mua: 120 học viên                  │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ DANH MỤC TÁC VỤ KHÓA HỌC:                               │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 📖 BIÊN SOẠN CÂY GIÁO TRÌNH (OUTLINE)        [ > ]  │ │
│ │ Quản lý Chương, Bài học, Video, Quiz, Bài tập lập   │ │
│ │ trình (Tác vụ trọng tâm nhất - Mở SCR-21)           │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ⚙️ THÔNG TIN KHÓA HỌC & HỌC PHÍ              [ > ]  │ │
│ │ Sửa tiêu đề, mô tả, ảnh bìa, giá bán (Mở SCR-18)    │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 👥 DANH SÁCH HỌC VIÊN ĐÃ MUA KHÓA            [ > ]  │ │
│ │ 120 học viên đăng ký · Xem tiến độ học tập (SCR-25) │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [NÚT CTA CHÍNH: KIỂM TRA SẴN SÀNG & NỘP DUYỆT >] (SCR-24│
│ (Chỉ hiển thị khi khóa ở trạng thái DRAFT hoặc REJECTED)│
└─────────────────────────────────────────────────────────┘
```

---

## 4. SCR-21: BIÊN SOẠN CÂY GIÁO TRÌNH (COURSE OUTLINE SCREEN)

### 4.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   GIÁO TRÌNH: FLUTTER CƠ BẢN                │
├─────────────────────────────────────────────────────────┤
│ [Thanh công cụ]: [+ Thêm Chương mới]    [⇅ Sắp xếp lại] │
├─────────────────────────────────────────────────────────┤
│ ▼ CHƯƠNG 1: TỔNG QUAN & CÀI ĐẶT MÔI TRƯỜNG     [⋮ Menu] │
│   (3 bài học · Thời lượng ~ 45 phút)                    │
│                                                         │
│   ├── [Icon Video] Bài 1: Cài đặt Flutter SDK           │
│   │   Thời lượng: 15 phút · Trạng thái: Sẵn sàng   [ > ]│
│   │                                                     │
│   ├── [Icon Article] Bài 2: Cấu trúc thư mục dự án      │
│   │   Bài đọc · 5 phút · Markdown                  [ > ]│
│   │                                                     │
│   └── [Icon Quiz] Bài 3: Trắc nghiệm kiến thức C1       │
│       10 câu hỏi · Điểm đạt: 80%                   [ > ]│
│                                                         │
│   [+ Thêm bài học mới vào Chương 1]                     │
│ ─────────────────────────────────────────────────────── │
│ ▶ CHƯƠNG 2: NGÔN NGỮ DART TỪ CON SỐ 0          [⋮ Menu] │
│   (Đang thu gọn - 5 bài học)                            │
│ ─────────────────────────────────────────────────────── │
│ ▼ CHƯƠNG 3: WIDGET CƠ BẢN TRONG FLUTTER        [⋮ Menu] │
│   (⚠️ Chưa có bài học nào - Cần bổ sung)                │
│                                                         │
│   [+ Thêm bài học mới vào Chương 3]                     │
└─────────────────────────────────────────────────────────┘
```
- **Tương tác Sắp xếp lại (`ReorderMode`):** Khi chạm `[⇅ Sắp xếp lại]`, hiển thị drag handle icon `≡` ở bên phải từng chương và từng bài học, cho phép kéo thả reorder trực tiếp và gọi API `PUT /sections/reorder` hoặc `PUT /lessons/reorder`.

---

## 5. SCR-23: TRÌNH BIÊN TẬP NỘI DUNG BÀI HỌC (LESSON CONTENT EDITOR)

### 5.1. Bóc tách 4 Trình Biên Tập Chuyên Biệt
1. **Editor Video (`video`):**
   - Nút chọn video từ bộ nhớ máy -> Hiển thị dung lượng file và độ phân giải.
   - Thanh tiến trình tải lên theo khối (Chunked Upload Progress Bar): `65% (45MB / 70MB) · 2.5 MB/s`.
   - Nút Tạm dừng (Pause) / Tiếp tục (Resume).
   - Trạng thái xử lý sau upload: *"Đang chuyển mã HLS sang các định dạng 360p, 720p, 1080p trên server"*.
2. **Editor Bài đọc (`article`):**
   - Ô nhập tiêu đề và nội dung Markdown.
   - Thanh công cụ định dạng nhanh: Bold, Italic, Code block, Image link, Bullets.
   - Tab chuyển đổi: Soạn thảo (Edit) vs Xem trước (Preview).
3. **Editor Trắc nghiệm (`quiz`):**
   - Cài đặt chung: Thời gian (phút), Số lần làm lại, Điểm đạt (%).
   - Danh sách câu hỏi: Thêm câu trắc nghiệm đơn (Single choice), nhiều đáp án (Multiple choice), câu Đúng/Sai.
   - Nhập lời giải thích chi tiết cho từng câu hỏi khi học sinh nộp bài.
4. **Editor Bài tập Lập trình (`exercise`):**
   - Chọn ngôn ngữ hỗ trợ: C++, Python, Java, Dart.
   - Khung Starter Code (code mẫu cho học sinh).
   - Giới hạn hệ thống: CPU Time Limit (giây), Memory Limit (MB).
   - Quản lý Bộ Testcase: Tab Testcase công khai (Sample Test) vs Tab Testcase ẩn (Hidden Test). Có nút nhập tay hoặc import file zip.

---

## 6. SCR-24: CHECKLIST KIỂM TRA SẴN SÀNG & NỘP DUYỆT (COURSE REVIEW READINESS)

### 6.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   ĐIỀU KIỆN GỬI DUYỆT KHÓA HỌC              │
├─────────────────────────────────────────────────────────┤
│ TIÊU CHUẨN XÉT DUYỆT CỦA HỆ THỐNG:                      │
│ Hệ thống tự động kiểm tra tính hoàn thiện của giáo      │
│ trình trước khi gửi hồ sơ lên Ban Quản Trị xét duyệt.   │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ CHECKLIST TỰ ĐỘNG                                   │ │
│ │ • [✓] Tiêu đề, mô tả và ảnh bìa hợp lệ              │ │
│ │ • [✓] Đã cấu hình học phí (599.000 đ)               │ │
│ │ • [✓] Khóa học có ít nhất 1 Chương (Hiện có 10)     │ │
│ │ • [✓] Có ít nhất 5 bài học (Hiện có 45 bài)         │ │
│ │ • [!] BÀI HỌC CHƯA CÓ NỘI DUNG (CÒN 1 BÀI RỖNG):    │ │
│ │       - Chương 3: Bài 1 "Giới thiệu Widget"         │ │
│ │         [Chạm để thêm nội dung ngay >]              │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ℹ️ LƯU Ý KHI GỬI DUYỆT                               │ │
│ │ Sau khi bấm gửi duyệt, khóa học sẽ chuyển sang trạng│ │
│ │ thái Chờ Duyệt (Pending) và tạm khóa chỉnh sửa.     │ │
│ │ Bạn có thể rút yêu cầu bất kỳ lúc nào nếu cần sửa.  │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [NÚT CTA CHÍNH: GỬI YÊU CẦU PHÊ DUYỆT KHÓA HỌC]         │
│ (Bị DISABLED màu xám cho đến khi giải quyết hết bài rỗng│
└─────────────────────────────────────────────────────────┘
```

---

## 7. SCR-26: VÍ GIẢNG VIÊN & QUẢN LÝ THU NHẬP (TEACHER EARNINGS SCREEN)

### 7.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]      THU NHẬP CÁ NHÂN          [Lịch sử ▾]  │
│                                             (Mở SCR-27) │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │ THẺ SỐ DƯ KHẢ DỤNG                         h: 160dp │ │
│ │ 💵 SỐ DƯ CÓ THỂ RÚT                                 │ │
│ │ 18.450.000 đ                                        │ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ • Tổng tích lũy:   45.000.000 đ                     │ │
│ │ • Đã thanh toán:   25.000.000 đ                     │ │
│ │ • Đang xử lý rút:   1.550.000 đ                     │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🏦 TÀI KHOẢN NGÂN HÀNG NHẬN TIỀN                    │ │
│ │ [Icon Ngân hàng] Ngân hàng Ngoại Thương (Vietcombank)│ │
│ │ Số tài khoản: •••••••• 5678                         │ │
│ │ Chủ tài khoản: NGUYEN VAN A                         │ │
│ │ [Nút text: Thay đổi thông tin ngân hàng >] (MOD-29) │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [NÚT CTA CHÍNH: YÊU CẦU RÚT TIỀN VỀ NGÂN HÀNG] (MOD-28) │
│ (Điều kiện: available_balance >= min_withdrawal_amount│
│  và has_open_withdrawal == false)                     │
│                                                         │
│ BIẾN ĐỘNG THU NHẬP GẦN ĐÂY                 [Xem tất cả >│
│ ┌─────────────────────────────────────────────────────┐ │
│ │ • + 599.000 đ | Bán khóa Flutter       | Hôm qua    │ │
│ │ • + 399.000 đ | Bán khóa Python        | 10/11      │ │
│ │ • - 5.000.000 đ | Rút tiền thành công  | 05/11      │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 8. MOD-28: MODAL RÚT TIỀN AN TOÀN (TEACHER WITHDRAWAL MODAL)

### 8.1. Sơ đồ Khung Dựng (Modal Bottom Sheet - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ ╭─────────────────────────────────────────────────────╮ │
│ │                [Drag Handle: w: 32dp, h: 4dp]       │ │
│ │ YÊU CẦU RÚT TIỀN VỀ TÀI KHOẢN               [✕ Đóng]│ │
│ │ ─────────────────────────────────────────────────── │ │
│ │ Số dư khả dụng: 18.450.000 đ                        │ │
│ │ Mức rút tối thiểu: 100.000 đ (Lấy động từ API)      │ │
│ │                                                     │ │
│ │ NHẬP SỐ TIỀN MUỐN RÚT:                              │ │
│ │ ┌─────────────────────────────────────────────────┐ │ │
│ │ │ 5.000.000                                     đ │ │ │
│ │ └─────────────────────────────────────────────────┘ │ │
│ │ [Gợi ý nhanh]: [ 1.000.000 ]  [ 5.000.000 ]  [ TẤT CẢ ]│
│ │                                                     │ │
│ │ CHUYỂN VỀ TÀI KHOẢN:                                │ │
│ │ Vietcombank · ••••••••5678 · NGUYEN VAN A           │ │
│ │                                                     │ │
│ │ [Nút CTA: TIẾP TỤC XÁC NHẬN RÚT TIỀN]       (h: 48dp│ │
│ ╰─────────────────────────────────────────────────────╯ │
└─────────────────────────────────────────────────────────┘
```

### 8.2. Dialog Xác Nhận Bảo Mật & Cơ Chế Optimistic Guard
Khi bấm "Tiếp tục xác nhận rút tiền", mở Dialog lớp 2:
```text
┌──────────────────────────────────────────────┐
│ 🔒 XÁC NHẬN GỬI YÊU CẦU RÚT TIỀN             │
│ • Số tiền rút:       5.000.000 đ             │
│ • Ngân hàng:         Vietcombank             │
│ • Số tài khoản:      •••••••• 5678           │
│ • Chủ tài khoản:     NGUYEN VAN A            │
│                                              │
│ [Hủy bỏ]           [XÁC NHẬN GỬI LỆNH RÚT]   │
└──────────────────────────────────────────────┘
```
- **Optimistic Guard:** Khi bấm xác nhận, vô hiệu hóa ngay nút bấm (tránh double-click). Nếu server trả về mã lỗi >= 500 hoặc Timeout: Hệ thống không cho phép gửi lại ngay, mà hiển thị thông báo: *"Yêu cầu đang được kiểm tra. Vui lòng mở Lịch sử rút tiền để tra cứu trạng thái, không gửi lệnh lặp lại."*

---

## 9. CHECKLIST HOÀN THÀNH ĐỢT 3
- [x] Đã hoàn thành sơ đồ Khóa học và gộp gọn màn hình `SCR-18` (Metadata & Học phí).
- [x] Đã đặc tả cây giáo trình `SCR-21` và 4 trình soạn thảo chuyên biệt `SCR-23`.
- [x] Đã chuẩn hóa cơ chế Ví giảng viên `SCR-26` và Modal rút tiền `MOD-28` với `min_withdrawal_amount` động và Optimistic Guard.
