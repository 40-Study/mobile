# ĐẶC TẢ WIREFRAME — ĐỢT 4: REALTIME LIVEKIT, ONBOARDING & SHARED ACCOUNT
**Tài liệu tham chiếu:** [UI-Teacher-plan.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/UI-Teacher-plan.md) | [WIREFRAME_EXECUTION_PLAN.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/WIREFRAME_EXECUTION_PLAN.md)  
**Phạm vi:** Trạng thái Đăng ký Ứng viên (`SCR-01`), Hồ sơ Chuyên môn (`SCR-02`), Phòng Dạy LiveKit (`SCR-32`), Trung tâm Công cụ Mở rộng (`SCR-30`), Hộp thư Trao đổi (`SCR-33`), và Tab Tài khoản Dùng chung (`SCR-37`).  
**Chuẩn màn hình:** 390dp x 844dp. Lưới 4-point / 8-point grid.

---

## 1. SCR-01: MÀN HÌNH TRẠNG THÁI ỨNG VIÊN GIÁO VIÊN (TEACHER APPLICANT SCREEN)

### 1.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [AppBar] ĐĂNG KÝ GIẢNG DẠY                     [Reload] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│                    [ICON ĐỒNG HỒ CÁT]                   │
│               (Huy hiệu vàng: PENDING_REVIEW)           │
│                                                         │
│              HỒ SƠ ĐANG CHỜ XÉT DUYỆT                   │
│   Ban Quản Trị đang kiểm định năng lực sư phạm của bạn  │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ THÔNG TIN TIẾN TRÌNH XÉT DUYỆT              h: 140dp│ │
│ │ • Ngày nộp hồ sơ:          10/11/2026               │ │
│ │ • Trạng thái:              Đang thẩm định           │ │
│ │ • Số lượt nộp lại còn lại: 3 / 3 lượt               │ │
│ │ • Thời gian phản hồi:      Trong vòng 24 - 48 giờ   │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [Nút CTA Viền: XEM HỒ SƠ ĐÃ NỘP (CHỈ ĐỌC)]    (h: 44dp) │
│                                                         │
│ [Nút CTA Chính: KIỂM TRA KẾT QUẢ DUYỆT]       (h: 44dp) │
│                                                         │
│ [Text Button: Quay lại trải nghiệm vai trò Học viên]    │
└─────────────────────────────────────────────────────────┘
```

### 1.2. Biến thể Trạng thái Khi Bị Từ Chối (Rejected State)
Khi `approval_status == rejected`:
- Icon chuyển sang Cảnh báo đỏ `⚠️`.
- Tiêu đề: *"Hồ sơ chưa đạt yêu cầu xét duyệt"*.
- Thẻ thông tin nền `errorContainer`:
  ```text
  ┌─────────────────────────────────────────────────────┐
  │ 🔴 LÝ DO TỪ CHỐI TỪ BAN QUẢN TRỊ:                   │
  │ "Thông tin chứng chỉ giảng dạy chưa rõ ràng.        │
  │  Vui lòng bổ sung giấy chứng nhận nghiệp vụ sư phạm."│
  │ • Số lượt nộp lại còn: 2 / 3 lượt                   │
  └─────────────────────────────────────────────────────┘
  ```
- Nút CTA Chính chuyển thành: **"CHỈNH SỬA HỒ SƠ & NỘP LẠI"** (Mở `SCR-02` ở chế độ Edit).

---

## 2. SCR-02: HỒ SƠ NĂNG LỰC SƯ PHẠM (TEACHER PROFESSIONAL SCREEN)

### 2.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   HỒ SƠ CHUYÊN MÔN GIẢNG VIÊN       [LƯU]   │
├─────────────────────────────────────────────────────────┤
│ [THÔNG TIN TÀI KHOẢN CHUNG (USER)]                      │
│ [Avatar lớn 72dp]  Nguyễn Văn A                         │
│ Email: nguyenvana@fortex.edu.vn  ·  SĐT: 0912•••789     │
│ (Thông tin cá nhân chỉnh sửa tại Tab Tài khoản chung)   │
│ ─────────────────────────────────────────────────────── │
│ [THÔNG TIN NĂNG LỰC SƯ PHẠM (TEACHER PROFILE)]          │
│ • Chuyên ngành giảng dạy (specialization) *             │
│   [ Lập trình Di động & Khoa học Máy tính            ]  │
│                                                         │
│ • Trình độ đào tạo / Học vị (education) *               │
│   [ Thạc sĩ Khoa học Máy tính - ĐH Bách Khoa          ] │
│                                                         │
│ • Số năm kinh nghiệm giảng dạy (experience_years) *     │
│   [ 5                                              năm] │
│                                                         │
│ • Khoa / Bộ môn công tác (department)                   │
│   [ Bộ môn Công nghệ Phần mềm                         ] │
│                                                         │
│ • Thông tin chứng chỉ / Khen thưởng (certificate_info)  │
│   ┌─────────────────────────────────────────────────┐   │
│   │ Chứng chỉ Sư phạm Đại học loại Giỏi năm 2021;   │   │
│   │ Chứng chỉ Google Associate Android Developer... │   │
│   └─────────────────────────────────────────────────┘   │
│                                                         │
│ [STICKY FOOTER: HỦY BỎ | LƯU HỒ SƠ NĂNG LỰC]  h: 64dp   │
└─────────────────────────────────────────────────────────┘
```
- **Hợp đồng API chuẩn xác 100%:** `POST /api/teacher-profiles` hoặc `PUT /api/teacher-profiles/:id` với body: `{ specialization, education, experience_years, certificate_info, department }`.

---

## 3. SCR-32: PHÒNG DẠY TRỰC TUYẾN LIVEKIT (TEACHER LIVE ROOM SCREEN)

### 3.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [🔴 LIVE: 00:45:12]  Toán 10A1 (30 HS)     [🚪 Rời phòng│
├─────────────────────────────────────────────────────────┤
│                                                         │
│                                                         │
│               KHUNG HÌNH TRÌNH CHIẾU CHÍNH              │
│                 (CAMERA GIÁO VIÊN /                     │
│                  CHIA SẺ MÀN HÌNH /                     │
│                  BẢNG TRẮNG WHITEBOARD)                 │
│                                                         │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ DẢI VIDEO THUMBNAIL HỌC SINH (Cuộn ngang):              │
│ ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐      │
│ │[HS Minh]│  │[HS Lan ]│  │[HS Mai ]│  │[HS Nam ]│      │
│ │ 🎤 Mic  │  │ 🔇 Muted│  │ 🎤 Mic  │  │ ✋ Giơtay│      │
│ └─────────┘  └─────────┘  └─────────┘  └─────────┘      │
├─────────────────────────────────────────────────────────┤
│ [Cửa sổ Chat lớp học thu nhỏ: 3 tin nhắn mới]           │
├─────────────────────────────────────────────────────────┤
│ THANH CÔNG CỤ ĐIỀU KHIỂN CỦA GIÁO VIÊN (HOST TOOLS):    │
│ ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐  ┌──────────┐│
│ │  🎤   │  │  📹   │  │  🖥️   │  │  👥   │  │  🔇 TẤT  ││
│ │Bật Mic│  │Tắt Cam│  │Chia sẻ│  │Lớp(30)│  │ KHÓA MIC ││
│ └───────┘  └───────┘  └───────┘  └───────┘  └──────────┘│
│                                                         │
│ [NÚT ĐỎ NỔI BẬT: KẾT THÚC BUỔI DẠY CHO TẤT CẢ MỌI NGƯỜI]│
└─────────────────────────────────────────────────────────┘
```

### 3.2. Đặc tả Tương tác Host (SCR-32)
- **Quản lý học sinh:** Bấm vào avatar học sinh trong dải thumbnail -> Mở popover: *"Tắt Mic học sinh"*, *"Mời ra khỏi phòng (Kick)"*.
- **Nút "Khóa Mic Tất cả":** Gọi `POST /api/livestream/:id/mute-all`.
- **Nút "Kết thúc buổi dạy":** Dialog xác nhận 2 bước: *"Bạn có chắc chắn muốn kết thúc buổi dạy và đóng phòng Live cho toàn bộ 30 học sinh?"* -> Khi đồng ý, gọi `POST /api/livestream/:id/end`.

---

## 4. SCR-30: TRUNG TÂM CÔNG CỤ GIẢNG DẠY MỞ RỘNG (TEACHER ADVANCED SCREEN)

### 4.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   CÔNG CỤ GIẢNG DẠY MỞ RỘNG                 │
├─────────────────────────────────────────────────────────┤
│ DANH MỤC TIỆN ÍCH TRỢ GIẢNG:                            │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🌐 PHÒNG HỌC TRỰC TUYẾN (LIVE SESSIONS)       [ > ] │ │
│ │ Quản lý lịch phát trực tiếp và mở phòng dạy LiveKit │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 💬 HỘP THƯ & TIN NHẮN (MESSAGES)             [ > ] │ │
│ │ Trao đổi trực tiếp 1-1 với học sinh và phụ huynh    │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ ❓ THẢO LUẬN & HỎI ĐÁP (DISCUSSIONS)          [ > ] │ │
│ │ Giải đáp thắc mắc của học viên theo từng bài giảng  │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 📤 TIẾN ĐỘ TẢI VIDEO (UPLOAD STUDIO)          [ > ] │ │
│ │ Theo dõi các file video bài giảng đang tải dở dang  │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🏆 CUỘC THI THỬ THÁCH (CONTESTS)             [ > ] │ │
│ │ Bảng xếp hạng và kết quả các kỳ thi quiz thử thách  │ │
│ └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 5. SCR-33: HỘP THƯ TRAO ĐỔI GIẢNG DẠY (TEACHER MESSAGES SCREEN)

### 5.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [<- Trở về]   TIN NHẮN & TRAO ĐỔI             [✏️ Soạn]  │
├─────────────────────────────────────────────────────────┤
│ [🔍 Tìm kiếm hội thoại theo tên học sinh/phụ huynh...]  │
├─────────────────────────────────────────────────────────┤
│ DANH SÁCH HỘI THOẠI GẦN NHẤT:                           │
│                                                         │
│ 1. [Avatar] NGUYỄN MINH ANH                 [ 10:15 ]   │
│    [Badge: Học sinh Lớp 10A1]                           │
│    "Thưa Thầy, bài tập số 3 em làm theo cách..."        │
│    [🔴 2 tin mới chưa đọc]                              │
│ ─────────────────────────────────────────────────────── │
│ 2. [Avatar] PHỤ HUYNH EM TRẦN HOÀNG LAN     [ Hôm qua ] │
│    [Badge: Phụ huynh Lớp 10A1]                          │
│    "Chào Thầy, hôm nay cháu Lan bị ốm nên xin..."       │
│ ─────────────────────────────────────────────────────── │
│ 3. [Avatar] LÊ THỊ MAI                      [ 08/11 ]   │
│    [Badge: Học viên Khóa Flutter]                       │
│    "Thầy cho em hỏi video bài 4 sao không xem được..."  │
└─────────────────────────────────────────────────────────┘
```

---

## 6. SCR-37: TAB TÀI KHOẢN DÙNG CHUNG (TEACHER PROFILE SCREEN)

### 6.1. Sơ đồ Khung Dựng (Box-Drawing Canvas - 390dp)
```text
┌─────────────────────────────────────────────────────────┐
│ [RoleAppHeader] TÀI KHOẢN                      [Cài đặt]│
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │ THẺ HỒ SƠ TÀI KHOẢN (PROFILE CARD)          h: 120dp│ │
│ │ [Avatar lớn 64dp]  NGUYỄN VĂN A                     │ │
│ │ nguyenvana@fortex.edu.vn  ·  0912•••789             │ │
│ │ [Badge Tím Nổi Bật: VAI TRÒ GIÁO VIÊN 40STUDY]      │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🔄 CHUYỂN ĐỔI VAI TRÒ HOẠT ĐỘNG (ROLE SWITCHER)     │ │
│ │ Đang hoạt động: [ Giáo viên ▾]                      │ │
│ │ [Chạm để chuyển nhanh sang: Phụ huynh / Học viên]   │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ DANH MỤC THIẾT LẬP:                                     │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ 🎓 Hồ sơ năng lực sư phạm chuyên môn (SCR-02) [ > ] │ │
│ │ 💳 Ví thu nhập & Thông tin ngân hàng (SCR-26) [ > ] │ │
│ │ 🌓 Giao diện ứng dụng: [ Sáng / Tối / Hệ thống ]    │ │
│ │ 🌐 Ngôn ngữ: [ Tiếng Việt ▾]                        │ │
│ │ 🔔 Cài đặt thông báo & Nhắc lịch dạy                │ │
│ │ 🔒 Bảo mật, đổi mật khẩu & Sinh trắc học            │ │
│ │ 📄 Điều khoản sử dụng & Chính sách bảo mật          │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [NÚT ĐỎ VIỀN: ĐĂNG XUẤT TÀI KHOẢN KHỎI THIẾT BỊ] (h:44dp│
└─────────────────────────────────────────────────────────┘
```
- **Kế thừa 100%:** Sử dụng trực tiếp `SharedAccountContent` của hệ thống, giúp người dùng chuyển đổi linh hoạt vai trò sang Học viên hoặc Phụ huynh ngay lập tức mà không cần đăng xuất.

---

## 7. CHECKLIST HOÀN THÀNH ĐỢT 4
- [x] Đã hoàn thành sơ đồ Khung Dựng cho toàn bộ luồng Ứng viên (`SCR-01`) và Hồ sơ chuẩn 5 trường (`SCR-02`).
- [x] Đã đặc tả phòng LiveKit với Host Controls và nút End Room 2 bước.
- [x] Đã tích hợp Tab Tài khoản chung kế thừa `SharedAccountContent`.
