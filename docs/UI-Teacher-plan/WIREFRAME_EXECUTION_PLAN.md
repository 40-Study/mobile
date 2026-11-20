# KẾ HOẠCH TRIỂN KHAI DỰNG WIREFRAME CHO ROLE TEACHER
**Dự án:** 40Study Mobile App (Flutter)  
**Tài liệu tham chiếu gốc:** [UI-Teacher-plan.md](file:///C:/ForteX/mobile/docs/UI-Teacher-plan/UI-Teacher-plan.md)  
**Thời gian lập:** Tháng 11/2026  
**Mục tiêu:** Định nghĩa chi tiết phương pháp, tiêu chuẩn kỹ thuật, định dạng bàn giao, ma trận màn hình và lộ trình triển khai từng đợt để dựng toàn bộ Wireframe cho vai trò Teacher (Giáo viên). Không viết mã nguồn (code Flutter) ở giai đoạn này.

---

## 1. MỤC TIÊU & NGUYÊN TẮC THIẾT KẾ WIREFRAME

### 1.1. Mục tiêu cốt lõi
1. **Trực quan hóa 100% tài liệu phân tích:** Biến mọi đặc tả cấu trúc, luồng người dùng và hợp đồng dữ liệu trong `UI-Teacher-plan.md` thành bản vẽ layout cụ thể, trực quan.
2. **Khóa chặt cấu trúc (Layout Freeze):** Định hình rõ ràng tỷ lệ bố cục, hệ thống lưới, phân cấp thị giác và vị trí nút bấm trước khi bước vào khâu UI Visual Design hoặc viết code Flutter, hạn chế tối đa việc chỉnh sửa lại layout sau này.
3. **Thẩm định trải nghiệm thực tế (Ergonomics & Thumb Zone):** Đảm bảo các tác vụ sư phạm thường xuyên (vào ca dạy, điểm danh, xem sĩ số, lưu sổ điểm) nằm trọn trong vùng ngón tay cái dễ chạm tới trên thiết bị di động (nửa dưới màn hình).

### 1.2. Bộ nguyên tắc bất biến (Guiding Principles)
1. **Tuân thủ Hệ thống Design Tokens Material 3 có sẵn:**
   - Lưới khoảng cách 4-point/8-point (`4dp`, `8dp`, `12dp`, `16dp`, `24dp`, `32dp`).
   - Tái sử dụng các thành phần nền tảng: `RoleAppHeader`, `CurvedSurfaceTray`, `TeacherSurface`, `BottomNavigationBar` 5 tabs.
2. **Bắt buộc thể hiện đủ 4 Trạng thái (The 4-State Matrix):**
   Mỗi màn hình/component chính không chỉ vẽ trạng thái lý tưởng (Happy path), mà bắt buộc phải có quy chuẩn cho:
   - **Default / Loaded State:** Có đầy đủ dữ liệu tiêu chuẩn.
   - **Empty State:** Chưa có dữ liệu (kèm minh họa trực quan & nút hành động dẫn dắt).
   - **Loading / Skeleton State:** Trạng thái chờ tải dữ liệu (shimmer placeholder).
   - **Error / Offline / Conflict State:** Trạng thái lỗi kết nối, trùng lịch hoặc thiếu quyền.
3. **Bảo toàn dữ liệu tác nghiệp (Draft State & Sticky Bar):**
   Mọi màn hình có tác vụ nhập liệu hàng loạt (Điểm danh `SCR-08`, Nhập điểm `SCR-16`) phải có bản vẽ **Sticky Bottom Action Bar** hiển thị số lượng thay đổi chưa lưu và nút xác nhận nổi bật.
4. **Không vẽ tính năng "ảo" (No Speculative Features):**
   Chỉ dựng wireframe cho các tính năng đã có backend contract hoặc base code mobile hỗ trợ. Các tính năng chưa có API (như Đơn xin nghỉ phép, Offline sync ngầm) được gắn nhãn `[Phase 2 / Chờ Backend]` và không dựng nút bấm tương tác giả.

---

## 2. TIÊU CHUẨN ĐỊNH DẠNG & CẤU TRÚC BÀN GIAO (DELIVERABLES SPEC)

Toàn bộ wireframe sẽ được tổ chức trong thư mục mới:
`C:\ForteX\mobile\docs\UI-Teacher-plan\wireframes/`

Wireframe được bàn giao theo **2 tầng bổ trợ nhau**:

### Tầng 1: Structural Layout Diagrams (Tài liệu Markdown Spec chi tiết)
Mỗi đợt sẽ có tài liệu markdown chi tiết chứa:
- **Khung Box-Drawing chuẩn tỷ lệ:** Sử dụng bộ ký tự Unicode (`┌─┐`, `│`, `└─┘`, `├─┤`) mô phỏng màn hình chuẩn tỉ lệ chiều ngang 360–390dp.
- **Bóc tách thành phần (Component Breakdown Table):**
  - Tên component Flutter tương ứng (hoặc component cần tạo mới).
  - Thuộc tính Auto-Layout, Padding, Margin, Border Radius.
  - Token màu (`surfaceContainerLow`, `primary`, `outlineVariant`, `error`).
  - Token Typography (`headlineSmall`, `titleLarge`, `titleMedium`, `bodyMedium`, `labelSmall`).
- **Chú thích Tương tác (Interaction Notes):** Hành vi khi Chạm (Tap), Vuốt (Scroll/Swipe), Kéo để tải lại (Pull-to-refresh), và Hiệu ứng mở Modal / Bottom Sheet.

### Tầng 2: Visual Interactive Prototype (HTML/CSS Mobile Canvas)
Một file HTML/CSS độc lập (ví dụ `teacher_wireframes_preview.html`) dựng sẵn khung điện thoại (390 x 844 px) có thể **mở trực tiếp trên bất kỳ trình duyệt nào**:
- Cho phép người xem bấm chuyển đổi giữa các Tab (`Hôm nay`, `Lịch dạy`, `Lớp học`, `Khóa học`, `Tài khoản`).
- Cho phép bấm mở/đóng Bottom Sheet (`MOD-04: WorkplaceSelectorSheet`).
- Cho phép chạm thử đổi trạng thái điểm danh (Có mặt / Vắng / Muộn / Chưa ghi) trên `SCR-08`.
- Cho phép chuyển đổi xem giữa các State (Loaded / Empty / Error).

---

## 3. LỘ TRÌNH TRIỂN KHAI THEO TỪNG ĐỢT (EXECUTION BATCHES)

Kế hoạch chia thành **4 Đợt (Batches)** theo thứ tự ưu tiên nghiệp vụ từ P0 (Tác nghiệp hàng ngày) đến P2 (Hồ sơ & Công cụ nâng cao):

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       LỘ TRÌNH DỰNG WIREFRAME TEACHER                       │
├───────────────────┬───────────────────┬───────────────────┬─────────────────┤
│   ĐỢT 1 (P0)      │   ĐỢT 2 (P1)      │   ĐỢT 3 (P1)      │   ĐỢT 4 (P2)    │
│  DAILY TEACHING   │ CLASS MANAGEMENT  │ COURSE & FINANCE  │ LIVE & ACCOUNT  │
├───────────────────┼───────────────────┼───────────────────┼─────────────────┤
│ • TeacherShell    │ • SCR-10 Lớp học  │ • SCR-17 Khóa học │ • SCR-01 Status │
│ • SCR-03 Hôm nay  │ • SCR-12 Chi tiết │ • SCR-18 Metadata │ • SCR-02 Profile│
│ • MOD-04 Workplace│   (5 Sub-tabs)    │   & Pricing gộp   │ • SCR-32 LiveKit│
│ • SCR-05 Lịch dạy │ • SCR-13A Phân GV │ • SCR-20 CourseHub│ • SCR-30 Tools  │
│ • SCR-06 Chi tiết │ • SCR-13B Học viên│ • SCR-21 Outline  │ • SCR-33 Inbox  │
│   buổi học        │ • SCR-07 Lịch lặp │ • SCR-22 Contents │ • SCR-37 Account│
│ • SCR-08 Điểm     │ • SCR-14 Bài tập  │ • SCR-23 Editors  │   dùng chung    │
│   danh nhanh      │ • SCR-15 Giao bài │ • SCR-24 Checklist│                 │
│                   │ • SCR-16 Bảng điểm│ • SCR-26 Ví tiền  │                 │
│                   │                   │ • MOD-28 Rút tiền │                 │
│                   │                   │ • SCR-27 Lịch sử  │                 │
└───────────────────┴───────────────────┴───────────────────┴─────────────────┘
```

---

### ĐỢT 1 (P0): Khung Xương Cốt Lõi & Giảng Dạy Hàng Ngày (Core Daily Teaching)
> **Mục tiêu:** Hoàn thiện toàn bộ các điểm chạm quan trọng nhất mà giáo viên thao tác mỗi ngày khi mở app.

1. **Khung Shell & Điều hướng chung:**
   - `TeacherShell`: Bottom Navigation Bar 5 Tabs (Outlined vs Filled icons).
   - `RoleAppHeader`: Nhãn vai trò "GIÁO VIÊN 40STUDY", avatar, chuông báo.
   - `CurvedSurfaceTray`: Khay cuộn bo cong mềm mại tiếp nối Header.
2. **`SCR-03`: Màn hình Hôm nay (`TeacherHomeScreen`)**
   - Bộ chọn nơi làm việc thu gọn (Cá nhân vs Tên tổ chức).
   - Hero Card "Buổi học tiếp theo" (Đếm lùi giờ, phòng học, nút CTA Vào dạy / Điểm danh).
   - Dải Timeline các ca dạy trong ngày.
   - Cảnh báo trùng lịch (Overlap Alert Banner) khi 2 buổi giao thoa khung giờ.
   - Empty State khi hôm nay không có ca dạy nào.
3. **`MOD-04`: Bottom Sheet Chọn Nơi Làm Việc (`WorkplaceSelectorSheet`)**
   - Danh sách Radio Cards: Cá nhân vs Các tổ chức trường/trung tâm.
   - Ghi chú phân định rõ quyền tài nguyên (Lớp/Lịch theo nơi làm việc; Khóa/Ví luôn cá nhân).
4. **`SCR-05`: Màn hình Lịch Dạy (`TeacherScheduleScreen`)**
   - Thanh trượt xem Tuần (Calendar Strip) & Chế độ xem Tháng.
   - Chip lọc theo từng Lớp học.
   - Danh sách ca dạy của ngày được chọn kèm trạng thái (Chưa học, Đã học, Đã hủy).
5. **`SCR-06`: Màn hình Chi tiết Buổi Học (`TeacherSessionScreen`)**
   - Thẻ thông tin phòng học, thời gian, chủ đề bài học.
   - Khối trạng thái LiveKit (Nút "Vào phòng dạy trực tuyến").
   - Khối tóm tắt điểm danh sĩ số & Nút dẫn vào màn hình Điểm danh.
   - Menu hành động phụ: Chỉnh sửa buổi / Hủy ca dạy kèm lý do hủy.
6. **`SCR-08`: Màn hình Điểm Danh Buổi Học (`TeacherAttendanceScreen`)**
   - Thanh tìm kiếm học sinh nhanh theo tên/mã số.
   - Dải Chip đếm sĩ số thời gian thực: `Tất cả (30)`, `Có mặt (26)`, `Vắng (2)`, `Chưa ghi (2)`.
   - Nút hành động nhanh: *"Đánh dấu tất cả chưa ghi nhận là Có mặt"*.
   - Danh sách thẻ học sinh với Selector 4 trạng thái (Có mặt - Xanh, Vắng - Đỏ, Vắng có phép - Cam, Muộn - Vàng).
   - Nút gọi khẩn cấp cho phụ huynh (`parent_phone`) ngay trên dòng học sinh vắng.
   - **Sticky Bottom Action Bar:** Hiển thị số lượng thay đổi chưa lưu và nút *"Lưu điểm danh ngay"*.
   - Hộp thoại cảnh báo rời trang khi có bản nháp chưa lưu (Draft Protection Dialog).

---

### ĐỢT 2 (P1): Quản Trị Lớp Học & Học Vụ Sư Phạm (Class Academic Management)
> **Mục tiêu:** Cung cấp đầy đủ công cụ để giáo viên quản lý lớp, điều phối giảng dạy, giao bài tập và chấm bảng điểm.

1. **`SCR-10`: Danh sách Lớp học (`TeacherClassesScreen`)**
   - Tab chuyển đổi: *"Được phân công giảng dạy"* vs *"Tôi quản lý"*.
   - Card lớp học hiển thị: Khóa học liên kết, Sĩ số, Lịch học trong tuần, Tiến độ số buổi đã dạy.
   - Bộ lọc trạng thái: Đang hoạt động vs Đã lưu trữ (`archived`).
2. **`SCR-12`: Chi tiết Lớp học Đa Phân hệ (5 Sub-tabs Workspace)**
   - **Sub-tab 1: Tổng quan (Overview):** Thông tin lớp, giáo viên phụ trách, lịch lặp tuần, nút mở phân công giáo viên.
   - **Sub-tab 2: Buổi học (Sessions):** Danh sách toàn bộ các buổi theo thời gian, nút *"Tạo buổi lẻ"* và nút *"Sinh buổi tự động theo lịch lặp"*.
   - **Sub-tab 3: Học viên (Students):** Danh sách học sinh, tỷ lệ chuyên cần %, nút mở ghi danh học viên mới.
   - **Sub-tab 4: Bài tập (Assignments):** Danh sách bài tập, hạn nộp, tỷ lệ nộp bài, nút giao bài tập mới.
   - **Sub-tab 5: Bảng điểm (Gradebook):** Bảng điểm sư phạm, chuyển đổi chế độ xem theo học sinh vs cuộn cột.
3. **`SCR-13A`: Màn hình Phân công Giáo viên (`TeacherAssignmentScreen`)**
   - Gán/gỡ Giáo viên chính và Trợ giảng cho lớp (Chỉ kích hoạt khi có quyền `can_assign_teachers`).
4. **`SCR-13B`: Màn hình Quản lý & Ghi danh Học viên (`StudentEnrollmentScreen`)**
   - Tra cứu học sinh có thể ghi danh (`enrollable-students`) và thêm vào lớp.
5. **`SCR-07`: Màn hình Soạn Lịch dạy / Buổi học (`TeacherScheduleEditor`)**
   - Chế độ tạo buổi học lẻ (Single Session) vs Thiết lập lịch lặp định kỳ (Recurring Schedule).
6. **`SCR-14`: Màn hình Chi tiết Bài tập & Chấm nộp (`TeacherAssignmentDetail`)**
   - Tab Đề bài & Testcase cấu hình.
   - Tab Danh sách bài nộp: Lọc trạng thái chấm tự động (`Accepted`, `Wrong Answer`, `Compile Error`), trình xem mã nguồn nộp bài (Code Viewer).
7. **`SCR-15`: Màn hình Soạn thảo / Giao bài tập mới (`TeacherAssignmentEditor`)**
   - Tiêu đề, hạn nộp, loại bài (`Homework` / `Live Coding`), cấu hình testcase.
8. **`SCR-16`: Màn hình Bảng điểm & Tổng kết (`TeacherGradebookScreen`)**
   - Quản lý cột điểm & trọng số (`SCR-16A`).
   - Giao diện nhập điểm theo cột (Single-column Batch Entry).
   - Dialog tính điểm tổng kết & Xác nhận chốt sổ điểm (`SCR-16B`).

---

### ĐỢT 3 (P1): Xưởng Khóa Học Cá Nhân & Ví Thu Nhập (Course Studio & Finance)
> **Mục tiêu:** Không gian sáng tạo giáo trình số của cá nhân giảng viên và quản lý dòng tiền thu nhập an toàn.

1. **`SCR-17`: Danh sách Khóa học Cá nhân (`TeacherCoursesScreen`)**
   - Tabs lọc trạng thái duyệt: `Tất cả`, `Bản nháp`, `Chờ duyệt`, `Đã xuất bản`, `Bị từ chối`.
   - Card khóa học tóm tắt: Ảnh bìa, Tên khóa, Số bài học, Học phí, Lượt học viên mua.
   - Lối tắt truy cập Ví thu nhập cá nhân.
2. **`SCR-18`: Biên tập Thông tin Khóa học & Học phí (`CourseMetadataEditor` - Gộp)**
   - Form thông tin cơ bản: Tiêu đề, Mô tả, Danh mục, Cấp độ, Thumbnail.
   - Form cấu hình giá bán: Miễn phí (`is_free`), Giá niêm yết, Giá khuyến mãi, Hạn khuyến mãi.
3. **`SCR-20`: Trung tâm Điều hành Khóa học (`CourseDetailScreen`)**
   - Banner nổi bật trạng thái phê duyệt:
     * `draft`: Hướng dẫn kiểm tra & gửi duyệt.
     * `pending_review`: Thông báo bị khóa sửa, nút Rút yêu cầu duyệt (`withdraw-review`).
     * `rejected`: Hộp màu đỏ hiển thị lý do từ chối từ Admin, nút chỉnh sửa để nộp lại.
     * `published`: Huy hiệu phát hành công khai.
   - Danh mục tác vụ: Biên soạn giáo trình, Học viên đã mua (`SCR-25`).
4. **`SCR-21`: Biên soạn Cây Giáo trình (`CourseOutlineScreen`)**
   - Cấu trúc Chương (Section) -> Bài học (Lesson).
   - Thao tác kéo thả sắp xếp thứ tự (Reorder mode).
   - Nút thêm nhanh Chương và Bài học.
5. **`SCR-22`: Danh mục Nội dung Bài học (`TeacherLessonContentsScreen`)**
   - Danh sách các item nội dung bên trong một bài học.
6. **`SCR-23`: Trình Biên tập Nội dung Chuyên biệt (`LessonContentEditor`)**
   - Editor Video: Chọn file, thanh tiến trình upload chunk multipart, trạng thái nén máy chủ.
   - Editor Article: Soạn thảo Markdown/HTML, chế độ xem trước (Preview).
   - Editor Quiz: Cài đặt thời gian, điểm đạt, thêm câu hỏi trắc nghiệm, đáp án giải thích.
   - Editor Coding Exercise: Starter code, compiler limits, bộ testcase công khai & testcase ẩn.
7. **`SCR-24`: Checklist Kiểm tra Sẵn sàng & Nộp duyệt (`CourseReviewReadinessScreen`)**
   - Checklist tự động: Kiểm tra bài rỗng, thiếu giá, thiếu mô tả.
   - Nút CTA Gửi duyệt (`submit-review`) chỉ sáng khi đạt 100% điều kiện.
8. **`SCR-26`: Màn hình Thu nhập & Ví Cá nhân (`TeacherEarningsScreen`)**
   - Thẻ số dư khả dụng (Available Balance) rút được ngay.
   - Thẻ thông tin ngân hàng nhận tiền (`MOD-29`).
   - Nút CTA "Yêu cầu rút tiền": Ràng buộc `min_withdrawal_amount` động từ backend, kiểm tra `has_open_withdrawal`.
9. **`MOD-28`: Modal Rút tiền An Toàn (`TeacherWithdrawalModal`)**
   - Ô nhập số tiền kèm gợi ý số dư khả dụng và hạn mức tối thiểu động.
   - Dialog xác nhận bảo mật che số tài khoản (`••••5678`).
   - Optimistic Guard chống bấm lặp và màn hình xử lý timeout.
10. **`SCR-27`: Màn hình Lịch sử Giao dịch & Rút tiền (`TeacherWalletHistory`)**
    - Tab Giao dịch doanh thu bán khóa.
    - Tab Lệnh rút tiền: Nút "Hủy yêu cầu rút" đối với lệnh ở trạng thái `pending`.

---

### ĐỢT 4 (P2): Realtime LiveKit, Xét Duyệt & Tài Khoản Dùng Chung
> **Mục tiêu:** Hoàn thiện các luồng kết nối thời gian thực, vòng đời ứng viên và hồ sơ tài khoản.

1. **`SCR-01`: Màn hình Trạng thái Ứng viên (`TeacherApplicantScreen`)**
   - Các trạng thái: Chờ duyệt (`pending`), Bị từ chối (`rejected` kèm lý do & số lượt còn lại 1/3, 2/3), Đã duyệt (`approved`).
   - Nút nộp lại hồ sơ (`resubmit`).
2. **`SCR-02`: Màn hình Hồ sơ Năng lực Sư phạm (`TeacherProfessionalScreen`)**
   - Form 5 trường chuẩn Backend DTO: Chuyên ngành (`specialization`), Học vấn (`education`), Kinh nghiệm (`experience_years`), Khoa/Bộ môn (`department`), Chứng chỉ (`certificate_info`).
3. **`SCR-32`: Phòng Dạy Trực tuyến LiveKit (`TeacherLiveRoomScreen`)**
   - Khung video chính (Camera giáo viên / Chia sẻ màn hình / Bảng trắng Whiteboard).
   - Dải video thumbnail các học sinh trong lớp.
   - Thanh công cụ điều khiển của Host: Bật/tắt Mic/Cam, Khóa mic cả lớp, Nút đỏ "Kết thúc buổi học cho tất cả".
4. **`SCR-30`: Trung tâm Công cụ Giảng dạy Mở rộng (`TeacherAdvancedScreen`)**
   - Menu các tiện ích phụ trợ: Lên lịch phát trực tiếp, Hộp thư tin nhắn, Thảo luận hỏi đáp.
5. **`SCR-33`: Hộp thư Trao đổi Giảng dạy (`TeacherMessagesScreen`)**
   - Danh sách hội thoại theo lớp học và phụ huynh.
6. **`SCR-37`: Tab Tài khoản Dùng Chung (`TeacherProfileScreen` / `SharedAccountContent`)**
   - ProfileCard hiển thị vai trò Giáo viên.
   - Section Chuyển đổi vai trò (`MOD-38: TeacherRoleSwitcher` sang Student/Parent).
   - Cài đặt Theme Sáng/Tối, Ngôn ngữ, Đăng xuất.

---

## 4. TIÊU CHUẨN CẤU TRÚC CHO MỖI BẢN VẼ WIREFRAME (FRAME BLUEPRINT ANATOMY)

Mỗi file đặc tả wireframe (cả dạng Markdown Spec lẫn HTML Visual Mockup) phải tuân thủ cấu trúc chuẩn mực gồm 5 khối thông tin:

```text
┌────────────────────────────────────────────────────────────────────────┐
│ 1. HEADER & METADATA                                                   │
│    • Mã MH: SCR-XX | Tên MH | Mục tiêu UX | Quyền truy cập required     │
├────────────────────────────────────────────────────────────────────────┤
│ 2. SƠ ĐỒ KHUNG DỰNG (BOX-DRAWING CANVAS - 390dp)                       │
│    • Tỷ lệ phân vùng, vị trí các nút CTA, khoảng cách padding cụ thể   │
├────────────────────────────────────────────────────────────────────────┤
│ 3. BẢNG BÓC TÁCH COMPONENT & DESIGN TOKENS                             │
│    • Tên widget Flutter dự kiến | Token màu | Token Typography | Spacing│
├────────────────────────────────────────────────────────────────────────┤
│ 4. MA TRẬN TRẠNG THÁI (STATE MATRIX)                                   │
│    • Default (Có data) | Empty | Loading Shimmer | Error/Conflict/Draft │
├────────────────────────────────────────────────────────────────────────┤
│ 5. ĐẶC TẢ TƯƠNG TÁC & GESTURES                                         │
│    • Tap action | Scroll behavior | Sticky action bar | Back guard     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 5. CHECKLIST ĐÁNH GIÁ CHẤT LƯỢNG WIREFRAME (ACCEPTANCE CRITERIA)

Trước khi ký duyệt hoàn thành một đợt wireframe để chuyển giao sang bước vẽ UI High-Fidelity hoặc code Flutter, từng màn hình phải vượt qua bộ checklist 8 điểm:

- [ ] **1. Thumb Zone Ergonomics:** Các nút bấm thao tác nhiều (CTA chính, nút Lưu, chuyển trạng thái điểm danh) nằm ở nửa dưới màn hình; nút nguy hiểm (Xóa lớp, Hủy buổi, Đóng phòng) có dialog xác nhận 2 bước.
- [ ] **2. Padding & Spacing Consistency:** 100% khoảng cách tuân thủ đúng bội số 4/8dp (`4`, `8`, `12`, `16`, `24`, `32dp`). Lề hai bên màn hình luôn là `24dp` (hoặc `16dp` trên màn hình nhỏ).
- [ ] **3. Data Feasibility:** Mọi trường hiển thị trên wireframe đều có trường dữ liệu tương ứng trong API response DTO của Backend. Không có trường dữ liệu "bịa đặt".
- [ ] **4. Full State Coverage:** Đã vẽ hoặc mô tả đầy đủ: Default State, Empty State, Loading Skeleton, và Error/Draft State.
- [ ] **5. Dynamic Currency & Number:** Không hardcode số tiền tối thiểu hay giới hạn rút tiền; hiển thị định dạng tiền tệ Việt Nam chuẩn (`###.### đ`).
- [ ] **6. Sticky Bar Protection:** Các màn hình chỉnh sửa danh sách đông người đều có Sticky Bar neo đáy màn hình để không bị cuộn mất nút Lưu.
- [ ] **7. Touch Target Size:** Mọi khu vực chạm (Button, Icon Button, Radio Card, Chip) có kích thước tối thiểu đạt chuẩn tiếp cận: `48 x 48 dp` (hoặc tối thiểu `44 x 44 dp`).
- [ ] **8. Screen Width Adaptability:** Đã kiểm tra bố cục hiển thị an toàn trên màn hình nhỏ có bề rộng `360dp` (không bị tràn chữ - Text Overflow / RenderFlex overflow).

---

## 6. PHÂN CÔNG BƯỚC THỰC HIỆN TIẾP THEO

| Bước | Nội dung công việc | Đầu ra dự kiến | Trạng thái |
|:---:|:---|:---|:---:|
| **B-1** | Duyệt Kế hoạch triển khai dựng Wireframe | Tài liệu `WIREFRAME_EXECUTION_PLAN.md` | **Hoàn thành** |
| **B-2** | Dựng Wireframe **Đợt 1 (P0: Core Daily Teaching)** | File Markdown Spec `wireframes/BATCH_1_DAILY_TEACHING.md` + File Visual HTML Mockup | **Sẵn sàng bắt đầu** |
| **B-3** | Rà soát & Tinh chỉnh Đợt 1 theo phản hồi của User | Biên bản rà soát Đợt 1 | Chờ B-2 |
| **B-4** | Dựng Wireframe **Đợt 2 (P1: Class Management)** | File Markdown Spec `wireframes/BATCH_2_CLASS_MANAGEMENT.md` | Chờ B-3 |
| **B-5** | Dựng Wireframe **Đợt 3 (P1: Course & Finance)** | File Markdown Spec `wireframes/BATCH_3_COURSE_STUDIO_FINANCE.md` | Chờ B-4 |
| **B-6** | Dựng Wireframe **Đợt 4 (P2: LiveKit & Account)** | File Markdown Spec `wireframes/BATCH_4_REALTIME_ACCOUNT.md` | Chờ B-5 |
| **B-7** | Tổng nghiệm thu toàn bộ Wireframe bộ Teacher | Chuyển sang giai đoạn UI Implementation (Coding) | Chờ B-6 |
