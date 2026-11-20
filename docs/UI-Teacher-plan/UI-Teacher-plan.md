# BẢN PHÂN TÍCH THIẾT KẾ UI/UX MOBILE CHO ROLE TEACHER (GIÁO VIÊN)
**Dự án:** 40Study Mobile App (Flutter)  
**Tài liệu:** Kế hoạch cấu trúc màn hình, luồng nghiệp vụ & đặc tả dữ liệu phục vụ dựng Wireframe  
**Nhánh đối chiếu:** `Thu/UI_Teacher` (Mobile) & `main` (Backend)  
**Thời gian lập:** Tháng 11/2026  
**Mục tiêu:** Định nghĩa chi tiết kiến trúc thông tin, luồng người dùng (User Flows), cấu trúc từng màn hình (Screen Layout Blueprint) và hợp đồng dữ liệu (Data Contracts) làm đầu vào trực tiếp cho bước dựng Wireframe và Prototype. Không thực hiện code ở bước này.

---

## MỤC LỤC TỔNG THỂ
1. [TỔNG QUAN HỆ THỐNG VÀ ĐỊNH VỊ VAI TRÒ TEACHER](#1-tổng-quan-hệ-thống-và-định-vị-vai-trò-teacher)
2. [KIẾN TRÚC ĐIỀU HƯỚNG TỔNG THỂ (GLOBAL NAVIGATION ARCHITECTURE)](#2-kiến-trúc-điều-hướng-tổng-thể-global-navigation-architecture)
3. [PHÂN TÍCH CÁC LUỒNG NGƯỜI DÙNG CỐT LÕI (CORE USER FLOWS)](#3-phân-tích-các-luồng-người-dùng-cốt-lõi-core-user-flows)
4. [ĐẶC TẢ CHI TIẾT CẤU TRÚC TỪNG MÀN HÌNH (SCREEN BLUEPRINTS)](#4-đặc-tả-chi-tiết-cấu-trúc-từng-màn-hình-screen-blueprints)
   - [Nhóm 0: Onboarding & Xét duyệt Ứng viên Giáo viên](#nhóm-0-onboarding--xét-duyệt-ứng-viên-giáo-viên)
   - [Nhóm 1: Tab Hôm nay (Today Dashboard)](#nhóm-1-tab-hôm-nay-today-dashboard)
   - [Nhóm 2: Tab Lịch dạy & Buổi học (Schedule & Timetable)](#nhóm-2-tab-lịch-dạy--buổi-học-schedule--timetable)
   - [Nhóm 3: Tab Lớp học & Quản trị Lớp (Classes & Academic Management)](#nhóm-3-tab-lớp-học--quản-trị-lớp-classes--academic-management)
   - [Nhóm 4: Tab Khóa học Cá nhân & Giáo trình (Curriculum & Course Studio)](#nhóm-4-tab-khóa-học-cá-nhân--giáo-trình-curriculum--course-studio)
   - [Nhóm 5: Thu nhập Cá nhân & Ví Giảng viên (Earnings & Payouts)](#nhóm-5-thu-nhập-cá-nhân--ví-giảng-viên-earnings--payouts)
   - [Nhóm 6: Công cụ Giảng dạy Mở rộng & Realtime (Advanced Teaching Tools)](#nhóm-6-công-cụ-giảng-dạy-mở-rộng--realtime-advanced-teaching-tools)
   - [Nhóm 7: Tab Tài khoản & Thiết lập Vai trò (Shared Account & Identity)](#nhóm-7-tab-tài-khoản--thiết-lập-vai-trò-shared-account--identity)
5. [QUY CHUẨN THIẾT KẾ ĐỂ PHỤC VỤ DỰNG WIREFRAME (WIREFRAME GUIDELINES)](#5-quy-chuẩn-thiết-kế-để-phục-vụ-dựng-wireframe-wireframe-guidelines)
6. [KẾ HOẠCH BÀN GIAO & CÁC BƯỚC TIẾP THEO (NEXT STEPS)](#6-kế-hoạch-bàn-giao--các-bước-tiếp-theo-next-steps)

---

## 1. TỔNG QUAN HỆ THỐNG VÀ ĐỊNH VỊ VAI TRÒ TEACHER

### 1.1. Bối cảnh sản phẩm & Đặc trưng người dùng Teacher
Trong hệ sinh thái giáo dục trực tuyến **40Study**, vai trò **Teacher (Giáo viên / Giảng viên)** mang tính chất kép (*dual persona*):
1. **Giáo viên Tự do (Independent Instructor / Creator):** Trực tiếp biên soạn giáo trình khóa học số (Video, Quiz, Coding Exercise, Article), xuất bản khóa học kiếm doanh thu, sở hữu ví thu nhập cá nhân và quản lý các lớp học độc lập của riêng mình.
2. **Giáo viên thuộc Tổ chức (Organization-affiliated Teacher):** Được các trường học, trung tâm đào tạo (`Organization`) phân công đứng lớp (với tư cách Giáo viên chính - *Primary Instructor* hoặc Trợ giảng - *Assistant Teacher*), quản lý buổi học, điểm danh và chấm bảng điểm theo chỉ tiêu học thuật của tổ chức đó.

### 1.2. Phân định ranh giới Quyền hạn & Ngữ cảnh Làm việc (Workplace Scope)
Backend áp dụng mô hình phân quyền ma trận giữa **Vai trò hệ thống (System Role)**, **Tổ chức kích hoạt (`active_org_id`)** và **Quyền hạn trên từng tài nguyên (Resource Capabilities)**:
- **Ngữ cảnh Làm việc (Workplace Scope):** Người dùng có thể chuyển đổi giữa ngữ cảnh **"Cá nhân"** (`active_org_id = null`) và các **"Tổ chức"** tham gia (`active_org_id = UUID`) qua API `POST /api/auth/select-org`.
  * *Tài nguyên lọc theo Scope:* **Lớp học (Classes)** và **Lịch dạy (Timetable)** được phân tách nghiêm ngặt theo nơi làm việc. Lớp thuộc tổ chức A sẽ không hiển thị khi đang chọn Cá nhân hoặc tổ chức B.
  * *Tài nguyên luôn thuộc Cá nhân:* **Khóa học (Courses)** và **Ví thu nhập (Wallet / Payout)** luôn thuộc về cá nhân giảng viên, không bao giờ bị đổi quyền sở hữu sang tổ chức dù đang kích hoạt bất kỳ tổ chức nào.
- **Quyền hạn động trên Lớp học (Class Capabilities):**
  * `can_manage`: Quyền quản lý lớp (chỉnh sửa thông tin, tạo lịch, sinh buổi học, quản lý học viên, thêm bài tập, nhập điểm).
  * `can_assign_teachers`: Quyền gán/gỡ giáo viên và trợ giảng vào lớp.
  * `is_archived`: Khi lớp ở trạng thái Lưu trữ (`archived`), toàn bộ giao diện chuyển sang **Chỉ đọc (Read-only)**, vô hiệu hóa mọi nút tạo/sửa/xóa/điểm danh/nhập điểm.

### 1.3. Vòng đời tài khoản & Phân luồng vai trò (Onboarding Lifecycle)
```text
[Người dùng / Học viên]
       │
       ▼  POST /api/teacher-profiles (Nộp hồ sơ chuyên môn)
[TEACHER_APPLICANT]  ── (Chờ xét duyệt: pending)
       │
       ├─────────────────────────────────┐
       ▼ (Admin từ chối: rejected)        ▼ (Admin duyệt: approved)
[Sửa & Nộp lại: resubmit]         [Cấp System Role: TEACHER]
(Tối đa 3 lần nộp lại)                   │
                                         ▼
                                  [TEACHER SHELL]
                           (5 Tabs - Không gian giảng dạy)
```

### 1.4. Bộ nguyên tắc thiết kế UI/UX trên nền tảng Mobile
1. **Ưu tiên tác vụ trước mắt (Action-Oriented Dashboard):** Giáo viên mở app để làm việc nhanh (vào dạy, điểm danh, chấm bài). Buổi sắp dạy tiếp theo và việc cần làm ngay phải nằm ở vị trí dễ chạm nhất (Top 1/3 màn hình).
2. **Bảo toàn dữ liệu cục bộ (Draft State Protection):** Các thao tác sư phạm (điểm danh 40 học viên, nhập điểm cả lớp) không được phép tự động hủy khi người dùng vô tình chạm nhầm hoặc mất mạng. Cần cơ chế **Local Draft State** và thanh **Sticky Action Bar** xác nhận lưu rõ ràng.
3. **Phản ánh trung thực trạng thái hệ thống (Semantic State Clarity):**
   * Phân biệt rõ giữa *Chưa điểm danh* (chưa có dữ liệu) và *Vắng mặt*.
   * Phân biệt rõ giữa *Ô điểm trống* và *Điểm 0*.
   * Phân biệt rõ giữa *Khóa học chờ duyệt* (bị khóa sửa) và *Khóa bị từ chối* (cần nộp lại).
4. **Kế thừa Thiết kế Hệ thống 40Study (Material 3 & System Theme):**
   * Tương thích hoàn toàn chế độ Sáng/Tối (Light/Dark mode) qua các token màu ngữ nghĩa (`surface`, `surfaceContainerLow`, `primary`, `secondary`, `tertiary`, `error`).
   * Sử dụng component chuẩn: `RoleAppHeader` chung cho cả app, `CurvedSurfaceTray` mềm mại, các card bề mặt phẳng phân tách rõ nét.

---

## 2. KIẾN TRÚC ĐIỀU HƯỚNG TỔNG THỂ (GLOBAL NAVIGATION ARCHITECTURE)

### 2.1. Cấu trúc Shell 5 Tabs cố định
Ứng dụng duy trì thanh điều hướng cố định 5 Tabs ở đáy màn hình (Bottom Navigation Bar) đối với điện thoại di động và Navigation Rail đối với màn hình rộng (Tablet/Foldable):
- **Tab 1: Hôm nay (Today)** — Điểm chạm trung tâm hàng ngày: Chào buổi, buổi học tiếp theo, timeline các buổi trong ngày, cảnh báo trùng lịch, lối tắt tác vụ.
- **Tab 2: Lịch dạy (Schedule)** — Lịch tuần/tháng, lọc theo lớp, quản lý buổi cụ thể và lịch lặp dự kiến, cấu hình nhắc lịch.
- **Tab 3: Lớp học (Classes)** — Danh sách lớp được phân công / lớp quản lý, 5 phân hệ chuyên sâu của từng lớp: Tổng quan, Buổi học, Học viên, Bài tập, Bảng điểm.
- **Tab 4: Khóa học (Courses)** — Xưởng sáng tạo nội dung cá nhân: Soạn giáo trình, biên tập video/quiz/code, quy trình nộp duyệt khóa học, truy cập ví thu nhập cá nhân.
- **Tab 5: Tài khoản (Account)** — Hệ thống hồ sơ chung: Đổi vai trò (Teacher/Student/Parent), thông tin cá nhân, cài đặt bảo mật và trợ giúp.

### 2.2. Sơ đồ cây màn hình phân cấp (Hierarchical Screen Tree)
```text
MainScreen (Role Router)
├── [Role = TEACHER_APPLICANT] ── SCR-01: TeacherApplicantScreen
│                                  └── SCR-02: TeacherProfessionalScreen (Soạn / Sửa CV)
│
└── [Role = TEACHER] ── TeacherShell (5 Tabs cố định)
    │
    ├── TAB 1: HÔM NAY (SCR-03: TeacherHomeScreen)
    │   ├── MOD-04: WorkplaceSelectorSheet (Chọn Cá nhân / Tổ chức)
    │   ├── SCR-06: TeacherSessionScreen (Chi tiết buổi học)
    │   │   ├── SCR-08: TeacherAttendanceScreen (Điểm danh học viên)
    │   │   └── SCR-32: TeacherLiveRoomScreen (Phòng dạy LiveKit)
    │   ├── SCR-33: TeacherMessagesScreen (Hộp thư trao đổi)
    │   └── SCR-30: TeacherAdvancedScreen (Trung tâm công cụ giảng dạy)
    │
    ├── TAB 2: LỊCH DẠY (SCR-05: TeacherScheduleScreen)
    │   ├── MOD-05B: ClassFilterSheet (Bộ lọc lớp học)
    │   ├── SCR-07: TeacherScheduleEditor (Tạo / Sửa buổi lẻ hoặc lịch lặp)
    │   ├── SCR-06: TeacherSessionScreen (Chi tiết buổi)
    │   └── SCR-09: TeacherRemindersScreen (Cài đặt nhắc lịch)
    │
    ├── TAB 3: LỚP HỌC (SCR-10: TeacherClassesScreen)
    │   ├── SCR-11: TeacherClassEditor (Tạo lớp cá nhân / Sửa thông tin lớp)
    │   └── SCR-12: TeacherClassScreen (Chi tiết lớp - 5 Sub-tabs)
    │       ├── Sub-tab 1: Tổng quan (Overview) ── SCR-13A: TeacherAssignmentScreen (Phân công GV)
    │       ├── Sub-tab 2: Buổi học (Sessions) ── SCR-07: Sinh buổi / Tạo buổi
    │       ├── Sub-tab 3: Học viên (Students) ── SCR-13B: StudentEnrollmentScreen (Ghi danh & Học viên)
    │       ├── Sub-tab 4: Bài tập (Assignments)
    │       │   ├── SCR-15: TeacherAssignmentEditor (Tạo / Sửa đề bài)
    │       │   └── SCR-14: TeacherAssignmentDetail (Danh sách nộp bài & Chấm code)
    │       └── Sub-tab 5: Bảng điểm (Gradebook)
    │           ├── SCR-16A: TeacherGradeColumnsScreen (Quản lý cột & trọng số)
    │           └── SCR-16B: FinalGradesConfirmation (Tính & Chốt điểm tổng kết)
    │
    ├── TAB 4: KHÓA HỌC (SCR-17: TeacherCoursesScreen)
    │   ├── SCR-18: CourseMetadataEditor (Thông tin cơ bản & Học phí, tích hợp)
    │   ├── SCR-26: TeacherEarningsScreen (Ví thu nhập & Quản lý rút tiền)
    │   │   ├── SCR-27: TeacherWalletHistory (Lịch sử giao dịch & Rút tiền)
    │   │   ├── MOD-28: TeacherWithdrawalModal (Rút tiền về ngân hàng)
    │   │   └── MOD-29: TeacherBankInfoModal (Cập nhật số tài khoản ngân hàng)
    │   └── SCR-20: CourseDetailScreen (Trung tâm điều hành khóa học)
    │       ├── SCR-21: CourseOutlineScreen (Biên soạn cây Chương - Bài)
    │       │   ├── SCR-22: LessonContentsScreen (Danh mục nội dung bài học)
    │       │   └── SCR-23: LessonContentEditor (Biên tập: Video, Article, Quiz, Exercise)
    │       ├── SCR-24: CourseReviewReadinessScreen (Checklist & Gửi duyệt)
    │       └── SCR-25: CourseEnrollmentsScreen (Học viên đã mua khóa)
    │
    └── TAB 5: TÀI KHOẢN (SCR-37: TeacherProfileScreen - SharedAccountContent)
        ├── SCR-02: TeacherProfessionalScreen (Hồ sơ chuyên môn)
        ├── MOD-38: TeacherRoleSwitcher (Chuyển đổi vai trò)
        └── Cài đặt chung / Bảo mật / Đăng xuất
```

---

## 3. PHÂN TÍCH CÁC LUỒNG NGƯỜI DÙNG CỐT LÕI (CORE USER FLOWS)

### 3.1. Luồng 1: Quy trình Giảng dạy Hàng ngày (Daily Teaching Routine)
```text
[Mở App] ──> [Tab Hôm nay]
                 │
                 ├─ Có buổi sắp tới (Next Session Card)
                 │         │
                 │         ▼ Bấm "Xem buổi dạy"
                 │    [Màn hình Chi tiết Buổi học]
                 │         │
                 │         ├─ Giờ dạy trực tuyến ──> Bấm "Vào phòng dạy" ──> [Phòng LiveKit]
                 │         │
                 │         └─ Đến giờ điểm danh ──> Bấm "Điểm danh"
                 │                                        │
                 │                                        ▼
                 │                               [Màn hình Điểm danh]
                 │                                        │
                 │                                        ├─ Chạm đổi trạng thái (Có mặt/Vắng/Muộn)
                 │                                        ├─ Nhập ghi chú cho từng học sinh
                 │                                        ├─ Bấm "Đánh dấu tất cả chưa ghi nhận"
                 │                                        │
                 │                                        ▼ Bấm "Lưu điểm danh" (Sticky bar)
                 │                               [API Bulk Update: 200 OK]
                 │                                        │
                 └────────────────────────────────────────┴──> Trở về Hôm nay (Cập nhật tiến độ)
```

### 3.2. Luồng 2: Quản trị Lớp học & Đánh giá Học tập (Class Academic Management)
```text
[Tab Lớp học] ──> [Chọn Lớp đang dạy] ──> [Chi tiết Lớp: 5 Sub-tabs]
                                                  │
   ┌──────────────────────┬───────────────────────┼───────────────────────────┐
   ▼                      ▼                       ▼                           ▼
[Buổi học]             [Học viên]              [Bài tập]                   [Bảng điểm]
   │                      │                       │                           │
   ├─ Tạo buổi lẻ         ├─ Tìm học viên mới     ├─ Tạo bài tập mới          ├─ Cấu hình Cột điểm
   ├─ Sinh tự động        │  (enrollable)         │  (Assignment / Quiz)      ├─ Nhập điểm từng ô
   └─ Hủy buổi có lý do   └─ Xóa khỏi lớp         ├─ Đóng/Mở nộp (Publish)   ├─ Nhập điểm hàng loạt
                                                  └─ Xem bài nộp & Chấm code  └─ Tính & Chốt tổng kết
```

### 3.3. Luồng 3: Biên soạn & Xuất bản Giáo trình Khóa học (Curriculum Authoring & Review)
```text
[Tab Khóa học] ──> Bấm "+" Tạo khóa mới
                         │
                         ▼
             [Soạn thông tin: Metadata & Giá] ──> Lưu bản nháp (Draft)
                         │
                         ▼
             [Biên soạn Giáo trình (Outline)]
                         │
                         ├─ Thêm Chương (Section)
                         ├─ Thêm Bài học (Lesson)
                         └─ Thêm Nội dung (Lesson Content)
                                  │
                                  ├─ Video (Tải lên qua chunk presigned URL)
                                  ├─ Article (Văn bản / Hướng dẫn)
                                  ├─ Quiz (Tạo câu hỏi trắc nghiệm, điểm đạt)
                                  └─ Coding Exercise (Cấu hình compiler, Testcase ẩn/hiển thị)
                         │
                         ▼
             [Kiểm tra Điều kiện Sẵn sàng (Review Readiness)]
                         │
                         ├─ Thiếu thông tin bắt buộc / Có bài học rỗng? ──> Báo lỗi, chỉ định link sửa
                         │
                         ▼ Đạt tiêu chuẩn
             [Xác nhận Gửi Duyệt (Submit Review)]
                         │
                         ▼
             [Trạng thái: PENDING_REVIEW] (Khóa sửa đổi toàn bộ thông tin & nội dung)
                         │
                         ├─ Giảng viên cần sửa gấp? ──> Bấm "Rút yêu cầu" (Withdraw) ──> Về Draft
                         │
                         ├─ Admin Phê duyệt ──────────> Trạng thái: PUBLISHED (Công khai)
                         └─ Admin Từ chối ───────────> Trạng thái: REJECTED (Hiện lý do từ chối, cho phép sửa & nộp lại)
```

### 3.4. Luồng 4: Quản lý Thu nhập & Rút tiền An toàn (Instructor Earnings & Payout)
```text
[Tab Khóa học] ──> Bấm "Ví thu nhập cá nhân" (Góc phải trên)
                         │
                         ▼
             [Màn hình Tổng quan Ví Giảng viên]
             (Số dư khả dụng · Tổng tích lũy · Đang chờ xử lý)
                         │
                         ├─ Chưa có ngân hàng? ──> [Modal Cập nhật Tài khoản Ngân hàng]
                         │
                         ▼ Đã có thông tin ngân hàng & Số dư >= Tối thiểu
             Bấm "Rút tiền"
                         │
                         ▼
             [Modal Nhập Số tiền Rút]
                         │
                         ▼ Bấm "Tiếp tục"
             [Dialog Xác nhận Cuối cùng]
             (Hiển thị: Số tiền, Tên ngân hàng, Số tài khoản che ••••1234, Tên chủ tài khoản)
                         │
                         ▼ Xác nhận gửi
             [Khóa giao diện (Sending state) & Ngăn Double-click]
                         │
                         ├─ Phản hồi Thành công (201 Created) ──> Cập nhật số dư, thêm vào Lịch sử
                         └─ Lỗi Mạng / Timeout (>= 500) ────────> Bật trạng thái Uncertain Guard:
                                                                 "Chưa rõ kết quả. Kiểm tra lịch sử;
                                                                  không gửi lại yêu cầu trong phiên này."
```

---

## 4. ĐẶC TẢ CHI TIẾT CẤU TRÚC TỪNG MÀN HÌNH (SCREEN BLUEPRINTS)

---

### Nhóm 0: Onboarding & Xét duyệt Ứng viên Giáo viên

#### SCR-01: Màn hình Trạng thái Đăng ký Giảng dạy (`TeacherApplicantScreen`)
- **Mục tiêu UX:** Thông báo minh bạch tiến trình xét duyệt hồ sơ giáo viên; dẫn dắt người dùng hoàn thiện thông tin hoặc sửa đổi hồ sơ khi bị từ chối; ngăn truy cập trái phép vào các công cụ giảng dạy.
- **Điểm vào:** `MainScreen` tự động điều hướng tới đây khi người dùng sở hữu System Role `TEACHER_APPLICANT`.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [AppBar] Đăng ký giảng dạy         [Reload]  │
  ├──────────────────────────────────────────────┤
  │                                              │
  │               [Icon Trạng thái]              │
  │        (Học viện / Đồng hồ / Cảnh báo)       │
  │                                              │
  │   [Tiêu đề Trạng thái lớn - headlineSmall]   │
  │   (Chờ duyệt / Cần bổ sung / Bị từ chối)     │
  │                                              │
  │ ┌──────────────────────────────────────────┐ │
  │ │ [Thẻ Thông tin Chi tiết]                 │ │
  │ │ • Ngày nộp hồ sơ                         │ │
  │ │ • Số lượt nộp lại còn lại: 2/3           │ │
  │ │ • [Lý do từ chối nếu có - Nền ErrorLow]  │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Action CTA Chính: Hoàn thiện / Sửa hồ sơ]   │
  │ [Action CTA Phụ: Kiểm tra kết quả phê duyệt] │
  │ [Action Text: Chuyển sang vai trò Học viên]  │
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Endpoint: `GET /api/teacher-profiles/me`
  * Model dữ liệu:
    - `approval_status`: Enum (`draft`, `pending`, `approved`, `rejected`).
    - `rejection_reason`: Chuỗi mô tả lý do từ chối từ Admin.
    - `resubmission_count`: Số lần đã nộp lại (int).
    - `max_resubmissions`: Số lần tối đa cho phép nộp lại (mặc định: 3).
    - `can_resubmit`: Boolean (true nếu `resubmission_count < max_resubmissions` và status == `rejected`).
- **Quy tắc hiển thị & Xử lý trạng thái:**
  * *Chưa có hồ sơ (`draft` / rỗng):* Hiển thị nút "Bắt đầu tạo hồ sơ chuyên môn" -> Chuyển sang `SCR-02`.
  * *Đang chờ duyệt (`pending`):* Hiển thị huy hiệu vàng "Đang chờ Admin phê duyệt". Nút "Xem hồ sơ đã nộp" (chỉ đọc). Nút "Kiểm tra cập nhật" (gọi lại API).
  * *Bị từ chối còn lượt (`rejected` & `can_resubmit = true`):* Hộp màu đỏ cảnh báo kèm `rejection_reason`. Nút chính: "Chỉnh sửa hồ sơ và nộp lại" (chuyển sang `SCR-02` với chế độ edit). Nút "Nộp lại hồ sơ" (`POST /api/teacher-profiles/me/resubmit`).
  * *Hết lượt nộp lại (`rejected` & `can_resubmit = false`):* Thông báo đã hết lượt xét duyệt. Cho phép quay về vai trò Học viên (`Student`).
  * *Đã được duyệt (`approved`):* Hiện banner xanh chúc mừng -> Kèm nút "Bắt đầu giảng dạy" (kích hoạt reload profile, chuyển sang `TeacherShell`).

---

#### SCR-02: Màn hình Hồ sơ Chuyên môn Giảng viên (`TeacherProfessionalScreen`)
- **Mục tiêu UX:** Thu thập thông tin năng lực sư phạm, bằng cấp, chuyên môn và chứng chỉ để Admin kiểm định chất lượng duyệt hồ sơ giáo viên.
- **Điểm vào:** Kích hoạt từ `SCR-01` (đối với ứng viên) hoặc từ Menu Quản lý giảng dạy tại `SCR-03` / `SCR-17` (đối với giáo viên đã duyệt cần xem/sửa hồ sơ).
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [<- Back] Hồ sơ năng lực sư phạm             │
  ├──────────────────────────────────────────────┤
  │ [Ảnh đại diện & Họ tên từ tài khoản User]    │
  │ [Text] Thông tin chuyên môn do Admin xét duyệt│
  │                                              │
  │ [Section 1: Chuyên môn & Đơn vị công tác]   │
  │ • Chuyên ngành giảng dạy (specialization) *  │
  │   (VD: Lập trình di động, Toán giải tích)   │
  │ • Trình độ đào tạo / Bằng cấp (education) *  │
  │   (VD: Cử nhân CNTT, ThS. Khoa học Máy tính) │
  │ • Khoa / Bộ môn công tác (department)        │
  │   (VD: Khoa Công nghệ Thông tin)             │
  │                                              │
  │ [Section 2: Kinh nghiệm & Chứng chỉ]         │
  │ • Số năm kinh nghiệm giảng dạy (Number) *    │
  │ • Thông tin chứng chỉ / Khen thưởng          │
  │   (certificate_info - Textarea mô tả chi tiết)│
  │                                              │
  │ [Sticky Bottom Bar: Hủy | Lưu hồ sơ]         │
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Tạo mới: `POST /api/teacher-profiles`
  * Cập nhật: `PUT /api/teacher-profiles/:id`
  * Payload DTO: `{ specialization, education, experience_years, certificate_info, department }` (chuẩn theo `CreateTeacherProfileDTO` / `UpdateTeacherProfileDTO`).
  * *Lưu ý dữ liệu:* `full_name`, `avatar` và `bio` nằm ở thực thể User/Profile chung của tài khoản, không gửi trong payload tạo `TeacherProfile`.
- **Validation quy chuẩn:** Bắt buộc `specialization` (max 255), `education` (max 255), `experience_years >= 0`. `department` (max 255).

---

### Nhóm 1: Tab Hôm nay (Today Dashboard)

#### SCR-03: Màn hình Hôm nay (`TeacherHomeScreen`)
- **Mục tiêu UX:** Màn hình chào đón khi mở app, giải quyết câu hỏi: *"Hôm nay tôi phải dạy lớp nào tiếp theo, lúc mấy giờ, ở đâu và cần chuẩn bị gì?"*.
- **Điểm vào:** Tab thứ nhất trên BottomNavigationBar của `TeacherShell`.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [RoleAppHeader] GIÁO VIÊN 40STUDY  [Avatar]  │
  ├──────────────────────────────────────────────┤
  │ [Selector Nơi làm việc: Trung tâm A ▾]       │
  │ (Chỉ xuất hiện khi thuộc >= 1 tổ chức)       │
  ├──────────────────────────────────────────────┤
  │ Chào Thầy/Cô Nguyễn Văn A                    │
  │ Thứ Tư, 12/11/2026                 [Hộp thư] │
  ├──────────────────────────────────────────────┤
  │ [Tóm tắt trong ngày: 3 buổi dạy · 1 hoàn tất]│
  │                                              │
  │ [HERO CARD: BUỔI TIẾP THEO]                  │
  │ ┌──────────────────────────────────────────┐ │
  │ │ 15:00 - 16:30 (Còn 25 phút)  [Đang tới]  │ │
  │ │ Lớp: Toán 10A1 - Nâng cao                │ │
  │ │ Đơn vị: Cơ sở 1 · Phòng: P.302 (hoặc Live│ │
  │ │ Chủ đề: Khảo sát hàm số bậc 3            │ │
  │ │                                          │ │
  │ │ [Nút CTA Chính: VÀO PHÒNG DẠY / ĐIỂM DANH]│
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Cảnh báo trùng giờ - Nếu có]               │
  │                                              │
  │ [Section Header: Lịch hôm nay]   [Xem lịch >]│
  │ • 08:00 - 09:30 | Lớp 10B | Hoàn thành    [✓]│
  │ • 15:00 - 16:30 | Lớp 10A1| Sắp diễn ra   [›]│
  │ • 17:30 - 19:00 | Lớp 11A | Đã lên lịch   [›]│
  │                                              │
  │ [Section Header: Công việc giảng dạy]        │
  │ ┌──────────────────┐   ┌───────────────────┐ │
  │ │ [Icon] Lớp học   │   │ [Icon] Khóa học   │ │
  │ │ 5 lớp phụ trách  │   │ 3 khóa cá nhân    │ │
  │ └──────────────────┘   └───────────────────┘ │
  │ ┌──────────────────────────────────────────┐ │
  │ │ [Tile] Hồ sơ giảng dạy & Chuyên môn  [›] │ │
  │ │ [Tile] Công cụ giảng dạy mở rộng     [›] │ │
  │ └──────────────────────────────────────────┘ │
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Lấy lịch hôm nay: `GET /api/me/timetable?sessions_from=YYYY-MM-DD&sessions_to=YYYY-MM-DD`
  * Model dữ liệu `TeacherOccurrence`:
    - `class_id`, `class_name`, `session_id`, `start` ("HH:mm"), `end` ("HH:mm"), `topic`, `room`, `status` (`scheduled`, `in_progress`, `completed`, `cancelled`), `livestream_session_id`, `organization_id`.
- **Trạng thái đặc thù:**
  * *Không có buổi dạy hôm nay:* Card Empty State dạng bo tròn "Hôm nay bạn không có lịch dạy" kèm nút "Xem lịch tuần tới".
  * *Trùng lịch (Overlap):* Xuất hiện cảnh báo màu hổ phách cảnh báo có 2 buổi dạy giao thoa khung giờ.

---

#### MOD-04: Bottom Sheet Chọn Nơi Làm Việc (`WorkplaceSelectorSheet`)
- **Mục tiêu UX:** Cho phép giáo viên chuyển đổi linh hoạt giữa phạm vi giảng dạy độc lập ("Cá nhân") và các trường học/tổ chức mà họ trực thuộc mà không gây nhầm lẫn dữ liệu.
- **Điểm vào:** Chạm vào thanh chọn Nơi làm việc trên Header của Tab Hôm nay, Lịch dạy hoặc Lớp học.
- **Phân vùng bố cục:**
  * Thanh Drag handle.
  * Tiêu đề: "Chọn nơi làm việc".
  * Ghi chú ngắn: *"Lớp học và lịch dạy được lọc theo nơi làm việc. Khóa học và thu nhập luôn thuộc quyền sở hữu cá nhân."*
  * Ô tìm kiếm tổ chức (hiển thị khi danh sách > 5 đơn vị).
  * Danh sách lựa chọn dạng radio card:
    - Mục 1: **Cá nhân (Độc lập)** — Icon cá nhân, có dấu check nếu đang chọn.
    - Mục 2..N: **Tên các Tổ chức** — Icon doanh nghiệp, nhãn vai trò tại tổ chức đó.
- **Luồng xử lý chuyển đổi:**
  1. Người dùng chọn 1 mục -> Gửi request `POST /api/auth/select-org` với `{ organization_id }` (hoặc null nếu chọn cá nhân).
  2. Backend cấp lại Token có claim `active_org_id` mới.
  3. Client cập nhật Interceptor, hủy toàn bộ cache giao diện của phạm vi cũ, tải lại danh sách lớp và lịch của phạm vi mới.

---

### Nhóm 2: Tab Lịch dạy & Buổi học (Schedule & Timetable)

#### SCR-05: Màn hình Lịch dạy Tuần / Tháng (`TeacherScheduleScreen`)
- **Mục tiêu UX:** Giúp giáo viên quản lý thời gian biểu tổng quan, chuyển đổi giữa chế độ xem tuần (nhanh, chi tiết) và tháng (dài hạn), tìm kiếm buổi học theo lớp.
- **Điểm vào:** Tab thứ hai trên BottomNavigationBar.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [RoleAppHeader] LỊCH DẠY           [Avatar]  │
  ├──────────────────────────────────────────────┤
  │ [Selector Nơi làm việc]                      │
  ├──────────────────────────────────────────────┤
  │ [Toolbar: Tháng 11/2026] [Tuần/Tháng] [Lọc]  │
  │ [<]  T2   T3   T4   T5   T6   T7   CN   [>]  │
  │      10   11  [12]  13   14   15   16        │
  │       •   ••  (••)   •             •         │
  ├──────────────────────────────────────────────┤
  │ [Bộ lọc đang áp dụng: Tất cả lớp / Lớp 10A1] │
  ├──────────────────────────────────────────────┤
  │ Danh sách buổi học ngày 12/11/2026 (2 buổi)  │
  │                                              │
  │ ┌──────────────────────────────────────────┐ │
  │ │ 08:00 - 09:30 · Lớp 10A1     [Hoàn thành]│ │
  │ │ Cơ sở 1 - P.301                          │ │
  │ │ Chủ đề: Hàm số bậc hai                   │ │
  │ │ Điểm danh: 28/30 học sinh đã có mặt      │ │
  │ └──────────────────────────────────────────┘ │
  │ ┌──────────────────────────────────────────┐ │
  │ │ 15:00 - 16:30 · Lớp 11B      [Đã lên lịch]│ │
  │ │ Phòng học trực tuyến LiveKit             │ │
  │ │ Chủ đề: Giới hạn dãy số                  │ │
  │ │ [Lịch dự kiến từ lịch lặp]               │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Floating Action Button: + Tạo buổi mới]     │
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Endpoint: `GET /api/me/timetable?sessions_from=YYYY-MM-DD&sessions_to=YYYY-MM-DD`
  * Hợp nhất dữ liệu: Kết hợp giữa Buổi học thực tế (`sessions`) và Lịch định kỳ lặp tuần (`schedules`). Nếu một ngày đã có buổi thực tế hoặc buổi đã bị hủy (`cancelled_occurrences`), hệ thống không vẽ đè lịch lặp dự kiến.
- **Hành động & Điều hướng:**
  * Chạm vào ngày: Load danh sách buổi của ngày đó ở danh sách dưới.
  * Chạm vào buổi học: Chuyển sang `SCR-06` (Chi tiết buổi học).
  * Chạm icon Lọc: Mở sheet danh sách lớp để lọc riêng lịch của một lớp cụ thể.
  * Chạm FAB "+": Mở `SCR-07` (Tạo buổi học lẻ).

---

#### SCR-06: Màn hình Chi tiết Buổi học (`TeacherSessionScreen`)
- **Mục tiêu UX:** Trung tâm thao tác cho một buổi dạy duy nhất: Nắm bắt sĩ số, nội dung giảng dạy, điểm danh, mở phòng live hoặc hủy/dời lịch khi có sự cố.
- **Điểm vào:** Từ `SCR-03` (Next Session Card / Timeline) hoặc `SCR-05` (Lịch dạy) hoặc `SCR-12` (Tab Buổi học của lớp).
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [<- Back] Chi tiết buổi học        [Menu •••]│
  ├──────────────────────────────────────────────┤
  │ [Huy hiệu Trạng thái: Đang diễn ra / Đã xong]│
  │                                              │
  │ [Tiêu đề Buổi học / Chủ đề]                  │
  │ Khảo sát sự biến thiên hàm số bậc ba         │
  │                                              │
  │ ┌──────────────────────────────────────────┐ │
  │ │ Thông tin tổng quan                      │ │
  │ │ • Lớp: Toán Nâng cao 10A1                │ │
  │ │ • Thời gian: Thứ Tư, 12/11 · 15:00–16:30 │ │
  │ │ • Địa điểm: Phòng học số 302             │ │
  │ │ • Đơn vị quản lý: Trung tâm ForteX       │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Thẻ hành động Trực tuyến - Nếu có LiveLink] │
  │ ┌──────────────────────────────────────────┐ │
  │ │ [Icon Live] Buổi học trực tuyến sẵn sàng │ │
  │ │ [Nút CTA: VÀO PHÒNG DẠY TRỰC TUYẾN]      │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Section: Điểm danh học viên]                │
  │ ┌──────────────────────────────────────────┐ │
  │ │ Sĩ số: 30 · Đã có mặt: 26 · Vắng: 2      │ │
  │ │ Chưa điểm danh: 2                        │ │
  │ │ [Nút: TIẾN HÀNH ĐIỂM DANH]               │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Section: Học liệu & Bài tập buổi]           │
  │ • Bài giảng: Khảo sát hàm số (PDF)         │
  │ • Bài tập về nhà: 5 câu trắc nghiệm        │
  │                                              │
  │ [Ghi chú nội bộ giáo viên]                   │
  └──────────────────────────────────────────────┘
  ```
- **Quy tắc phân quyền & Menu hành động (`Menu •••`):**
  * Nếu người dùng có quyền `can_manage` trên lớp:
    - "Chỉnh sửa buổi học" -> Mở `SCR-07` ở chế độ Edit.
    - "Hủy buổi học" -> Hiện dialog yêu cầu nhập lý do hủy (`cancel_reason`).
  * Nếu lớp bị `is_archived = true`: Ẩn toàn bộ nút sửa, chỉ cho xem.

---

#### SCR-07: Màn hình Soạn thảo Lịch dạy / Buổi học (`TeacherScheduleEditor`)
- **Mục tiêu UX:** Tạo mới hoặc dời lịch/chỉnh sửa một buổi học cụ thể hoặc cấu hình lịch lặp định kỳ cho cả tuần.
- **Điểm vào:** Từ nút "+" trên Lịch dạy hoặc Tab Buổi học của lớp.
- **Phân vùng bố cục:**
  * Chế độ tạo (Segmented Control): **Buổi học cụ thể (Single Session)** vs. **Lịch lặp định kỳ (Recurring Schedule)**.
  * Form nhập liệu:
    - *Chọn Lớp học (Dropdown).*
    - *Ngày học (Date Picker) & Giờ học (Time Picker bắt đầu - kết thúc).*
    - *Chủ đề buổi học (Text Field).*
    - *Hình thức học: Trực tiếp (Phòng học) vs. Trực tuyến (Tích hợp Live).*
    - *Ghi chú chuẩn bị cho học sinh.*
  * Sticky Footer: Nút "Hủy" và "Lưu lịch dạy".
- **Hợp đồng dữ liệu & Nguồn API:**
  * Tạo buổi lẻ: `POST /api/classes/:classId/sessions`
  * Sửa buổi lẻ: `PUT /api/classes/:classId/sessions/:id`
  * Tạo lịch lặp: `POST /api/classes/:classId/schedules`

---

#### SCR-08: Màn hình Điểm danh Buổi học (`TeacherAttendanceScreen`)
- **Mục tiêu UX:** Cung cấp trải nghiệm điểm danh siêu tốc trên di động cho lớp học đông người (30–50 học sinh), chống nhầm lẫn, bảo vệ bản nháp khi mất mạng.
- **Điểm vào:** Nút "Điểm danh" từ `SCR-03` hoặc `SCR-06`.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [<- Back] Điểm danh · Lớp 10A1               │
  │ Thứ Tư, 12/11/2026 · 15:00 - 16:30           │
  ├──────────────────────────────────────────────┤
  │ [Thanh tìm kiếm học sinh theo tên]           │
  │ [Thanh thống kê nhanh dạng Chip đếm số lượng]│
  │ [Tất cả 30] [Có mặt 26] [Vắng 2] [Chưa ghi 2]│
  ├──────────────────────────────────────────────┤
  │ [Hành động nhanh]:                           │
  │ [⚡ Đánh dấu tất cả chưa ghi nhận là Có mặt] │
  ├──────────────────────────────────────────────┤
  │ Danh sách học sinh:                          │
  │                                              │
  │ 1. Nguyễn Minh Anh                           │
  │    Mã: HS00124        [ CÓ MẶT ▾ ] (Xanh lá) │
  │    Ghi chú: Vào đúng giờ                     │
  │ ──────────────────────────────────────────── │
  │ 2. Trần Hoàng Lan                            │
  │    Mã: HS00125        [ VẮNG CÓ PHÉP ▾ ]     │
  │    Ghi chú: Phụ huynh xin nghỉ qua tin nhắn  │
  │ ──────────────────────────────────────────── │
  │ 3. Lê Minh Khang                             │
  │    Mã: HS00129        [ CHƯA ĐIỂM DANH ▾ ]   │
  │    [Chạm để chọn trạng thái]                 │
  ├──────────────────────────────────────────────┤
  │ [STICKY FOOTER: CÓ 3 THAY ĐỔI CHƯA LƯU]      │
  │ [Button Nổi bật: LƯU ĐIỂM DANH NGAY]         │
  └──────────────────────────────────────────────┘
  ```
- **Bộ trạng thái điểm danh (Attendance Statuses):**
  * `present` (Có mặt) — Màu xanh lá.
  * `absent` (Vắng không phép) — Màu đỏ.
  * `excused` (Vắng có phép) — Màu cam.
  * `late` (Đi muộn) — Màu vàng hổ phách.
  * `unmarked` (Chưa điểm danh) — Màu xám nhạt (trạng thái trung tính, tách biệt với vắng).
- **Hợp đồng dữ liệu & Nguồn API:**
  * Lấy danh sách điểm danh: `GET /api/sessions/:sessionId/attendances`
  * Lưu hàng loạt: `POST /api/sessions/:sessionId/attendances/bulk`
  * Payload: `{ attendances: [ { student_id, status, notes } ] }`
- **Cơ chế Draft & Thoát an toàn:** Nếu giáo viên bấm Back khi có thay đổi chưa lưu, hệ thống bật Dialog: *"Bạn có thay đổi chưa lưu. Bạn muốn Lưu ngay, Bỏ thay đổi hay Tiếp tục điểm danh?"*.

---

### Nhóm 3: Tab Lớp học & Quản trị Lớp (Classes & Academic Management)

#### SCR-10: Màn hình Danh sách Lớp học (`TeacherClassesScreen`)
- **Mục tiêu UX:** Quản lý tập trung toàn bộ các lớp học mà giáo viên được phân công giảng dạy hoặc làm chủ nhiệm.
- **Điểm vào:** Tab thứ ba trên BottomNavigationBar.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [RoleAppHeader] LỚP HỌC             [Avatar] │
  ├──────────────────────────────────────────────┤
  │ [Selector Nơi làm việc: ForteX School ▾]     │
  ├──────────────────────────────────────────────┤
  │ [Thanh tìm kiếm theo tên lớp]                │
  │                                              │
  │ [Filter Tabs]:                               │
  │ [ ĐƯỢC PHÂN CÔNG (4) ]  [ TÔI QUẢN LÝ (2) ]  │
  │                                              │
  │ [Bộ lọc trạng thái: Đang mở | Đã lưu trữ]    │
  ├──────────────────────────────────────────────┤
  │ ┌──────────────────────────────────────────┐ │
  │ │ CARD LỚP HỌC                             │ │
  │ │ Tên lớp: TOÁN 10A1 - NÂNG CAO            │ │
  │ │ Khóa học: Đại số & Hình học 10           │ │
  │ │ [Badge: Đang hoạt động] [Badge: GV Chính]│ │
  │ │ ---------------------------------------- │ │
  │ │ • Sĩ số: 30/35 học sinh                  │ │
  │ │ • Lịch học: Thứ 2, 4, 6 (15:00 - 16:30)  │ │
  │ │ • Tiến độ: Đã học 12/36 buổi             │ │
  │ │ [Nút: VÀO QUẢN LÝ LỚP >]                 │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Nút Floating: + Tạo lớp mới]                │
  │ (Chỉ sáng khi ở phạm vi Cá nhân / có quyền)  │
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Lớp được phân công: `GET /api/classes/me`
  * Lớp quản lý: `GET /api/classes`
  * Bộ lọc phạm vi: Lọc các lớp có `organization_id == activeOrg.id`.

---

#### SCR-12: Màn hình Chi tiết Lớp học (`TeacherClassScreen`)
- **Mục tiêu UX:** Không gian làm việc toàn diện cho một lớp học cụ thể với thanh 5 Tab chuyên trách.
- **Điểm vào:** Chạm vào card lớp học từ `SCR-10`.
- **Cấu trúc Header & 5 Phân hệ Tab (Tabs Architecture):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [<- Back] Lớp Toán 10A1             [Edit/••]│
  │ Thuộc: ForteX School · Trạng thái: Active    │
  ├──────────────────────────────────────────────┤
  │ [TabBar cuộn ngang]:                         │
  │ [Tổng quan] [Buổi học] [Học viên] [Bài tập] [Bảng điểm] │
  ├──────────────────────────────────────────────┤
  │ >>> NỘI DUNG TỪNG SUB-TAB BÊN DƯỚI <<<      │
  └──────────────────────────────────────────────┘
  ```

##### 12.1. Sub-tab 1: Tổng quan (Overview)
- **Nội dung:** Thông tin cơ bản của lớp, khóa học gốc liên kết, danh sách các giáo viên phụ trách (Giáo viên chính & Trợ giảng), tóm tắt lịch lặp tuần, các chỉ số sĩ số và tiến độ.
- **Hành động:** Nút "Phân công giáo viên" (nếu có `can_assign_teachers`) -> Mở `SCR-13A: TeacherAssignmentScreen` (sử dụng widget chung `TeacherClassPeopleScreen(teachers: true)`), nút "Sửa thông tin lớp".

##### 12.2. Sub-tab 2: Buổi học (Sessions)
- **Nội dung:** Danh sách toàn bộ các buổi học của lớp theo thứ tự thời gian. Mỗi dòng hiển thị: Thứ/Ngày, giờ học, chủ đề, phòng học, trạng thái (Chưa học / Đang học / Đã kết thúc / Đã hủy).
- **Hành động:** Nút "Tạo buổi lẻ" và "Sinh buổi tự động theo lịch lặp" (`POST /api/classes/:id/sessions/generate`). Bấm vào buổi mở `SCR-06`.

##### 12.3. Sub-tab 3: Học viên (Students)
- **Nội dung:** Danh sách học sinh trong lớp kèm ảnh đại diện, họ tên, mã học sinh, ngày ghi danh, tỷ lệ chuyên cần (%).
- **Hành động:** Nút "Quản lý & Thêm học viên" -> Mở `SCR-13B: StudentEnrollmentScreen` (sử dụng widget chung `TeacherClassPeopleScreen(teachers: false)`): Tra cứu danh sách học viên có thể thêm (`GET /api/classes/:id/enrollable-students?keyword=`) và gửi yêu cầu ghi danh `POST /api/classes/:id/students`. Có nút liên lạc nhanh (Call/SMS) với phụ huynh qua trường `parent_phone`.

##### 12.4. Sub-tab 4: Bài tập & Kiểm tra (Assignments)
- **Nội dung:** Danh sách các bài tập lập trình (`live_coding`, `homework`, `project`) hoặc bài kiểm tra được giao cho lớp.
- **Hiển thị từng card bài tập:** Tiêu đề, hạn nộp (Deadline), trạng thái phát hành (Draft / Published), số học sinh đã nộp bài (VD: 24/30 đã nộp).
- **Hành động:** Nút "+ Giao bài tập mới" -> Chuyển sang `SCR-15`. Bấm vào bài tập mở `SCR-14` (Xem danh sách nộp và chấm điểm).

##### 12.5. Sub-tab 5: Bảng điểm (Gradebook)
- **Nội dung:** Bảng điểm trực quan của lớp học.
- **Hai chế độ xem:**
  1. *Chế độ theo Học viên (Mobile-friendly):* Danh sách học sinh, chạm vào tên ai sẽ mở rộng danh sách các cột điểm của người đó để xem và nhập điểm.
  2. *Chế độ Bảng cuộn ngang (Table mode):* Cột tên học sinh cố định bên trái, các cột điểm (Điểm 15p, Giữa kỳ, Cuối kỳ) cuộn ngang.
- **Hành động:**
  - Nút "Quản lý cột điểm" -> Mở `SCR-16A`.
  - Nút "Tính điểm tổng kết" (`POST /api/classes/:id/final-grades/calculate`).
  - Nút "Chốt sổ điểm" (`POST /api/classes/:id/final-grades/finalize`).

---

#### SCR-14: Màn hình Chi tiết Bài tập & Chấm nộp (`TeacherAssignmentDetail`)
- **Mục tiêu UX:** Giúp giáo viên xem đề bài, cấu hình testcase, duyệt danh sách bài nộp của học sinh và xem kết quả chạy code tự động.
- **Điểm vào:** Từ Sub-tab Bài tập của lớp.
- **Phân vùng bố cục:**
  * Header: Tên bài tập, loại (`Homework`/`Live Coding`), hạn nộp, nút Publish/Unpublish.
  * Tab 1: **Đề bài & Testcase:** Xem nội dung yêu cầu, giới hạn thời gian (Time Limit), giới hạn bộ nhớ (Memory Limit), danh sách testcase mẫu và testcase ẩn.
  * Tab 2: **Danh sách bài nộp (Submissions):**
    - Tìm kiếm học sinh.
    - Danh sách lần nộp: Tên học sinh, thời điểm nộp, số lần thử, kết quả chấm tự động (`Accepted` - Xanh lá, `Wrong Answer` - Đỏ, `Compile Error` - Cam).
    - Chạm vào bài nộp: Mở trình xem mã nguồn của học sinh (Read-only Code Viewer kèm highlight cú pháp) và chi tiết kết quả từng testcase.

---

### Nhóm 4: Tab Khóa học Cá nhân & Giáo trình (Curriculum & Course Studio)

#### SCR-17: Màn hình Danh sách Khóa học Cá nhân (`TeacherCoursesScreen`)
- **Mục tiêu UX:** Quản lý kho khóa học số của riêng giảng viên, theo dõi tiến độ phê duyệt từ Admin và doanh số bán khóa lẻ.
- **Điểm vào:** Tab thứ tư trên BottomNavigationBar.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [RoleAppHeader] KHÓA HỌC CÁ NHÂN    [Avatar] │
  ├──────────────────────────────────────────────┤
  │ [Dòng phạm vi: Khóa học luôn thuộc Cá nhân]  │
  ├──────────────────────────────────────────────┤
  │ [Thanh tìm kiếm khóa học]         [Lọc phễu] │
  │                                              │
  │ [Tabs trạng thái duyệt]:                     │
  │ [ Tất cả ] [ Nháp ] [ Chờ duyệt ] [ Đã duyệt]│
  ├──────────────────────────────────────────────┤
  │ ┌──────────────────────────────────────────┐ │
  │ │ CARD KHÓA HỌC                            │ │
  │ │ [Ảnh Thumbnail khóa học]                 │ │
  │ │ LẬP TRÌNH FLUTTER CHO NGƯỜI MỚI BẮT ĐẦU   │ │
  │ │ [Badge: PENDING_REVIEW (Vàng)]           │ │
  │ │ • 10 Chương · 45 Bài học                 │ │
  │ │ • Học phí: 599.000 đ                     │ │
  │ │ • 120 Học viên đăng ký                   │ │
  │ │ [Hành động: Tiếp tục soạn giáo trình >]   │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [Nút Icon góc phải trên: Ví thu nhập cá nhân]│
  │ [Floating Action Button: + Tạo khóa mới]     │
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Endpoint: `GET /api/courses/mine?status=&keyword=&page=&page_size=`
  * Enum trạng thái: `draft`, `pending_review`, `published`, `rejected`, `archived`.

---

#### SCR-20: Màn hình Quản lý Khóa học Chi tiết (`CourseDetailScreen`)
- **Mục tiêu UX:** Trung tâm chỉ huy cho một khóa học: Theo dõi tình trạng phê duyệt, quản lý thông tin, học phí, học viên và đi vào biên soạn giáo trình.
- **Điểm vào:** Chạm vào card khóa học từ `SCR-17`.
- **Phân vùng bố cục:**
  * **Banner Trạng thái Phê duyệt nổi bật:**
    - Nếu `draft`: Nền xám/xanh "Bản nháp chưa gửi duyệt" kèm nút "Kiểm tra & Gửi duyệt" (`SCR-24`).
    - Nếu `pending_review`: Nền vàng "Đang chờ Admin phê duyệt. Khóa học tạm thời bị khóa chỉnh sửa" kèm nút "Rút yêu cầu duyệt" (`POST /api/courses/:id/withdraw-review`).
    - Nếu `rejected`: Nền đỏ "Bị từ chối phê duyệt. Lý do: [Nội dung từ Admin]" kèm nút "Chỉnh sửa & Nộp lại".
    - Nếu `published`: Nền xanh lá "Khóa học đang phát hành công khai".
  * **Thông tin tóm tắt:** Ảnh bìa, Tên khóa, Mã định danh (slug), Danh mục, Cấp độ, Số bài học, Số học viên.
  * **Danh mục tác vụ chính:**
    - *Biên soạn Giáo trình (Curriculum Outline)* -> Mở `SCR-21` (Tác vụ trọng tâm nhất).
    - *Chỉnh sửa Thông tin khóa & Học phí (Metadata & Pricing)* -> Mở `SCR-18` (đã tích hợp cấu hình học phí & khuyến mãi).
    - *Danh sách học viên đăng ký* -> Mở `SCR-25`.

---

#### SCR-21: Màn hình Biên soạn Giáo trình (`CourseOutlineScreen`)
- **Mục tiêu UX:** Xây dựng cấu trúc cây Chương - Bài học phân cấp, hỗ trợ kéo thả sắp xếp thứ tự dễ dàng trên di động.
- **Điểm vào:** Từ `SCR-20`.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [<- Back] Giáo trình: Flutter Cơ bản         │
  ├──────────────────────────────────────────────┤
  │ [Thanh công cụ: + Thêm Chương] [Sắp xếp ⇅]   │
  ├──────────────────────────────────────────────┤
  │ ▼ CHƯƠNG 1: TỔNG QUAN & CÀI ĐẶT    [⋮ Menu]  │
  │   (3 bài học · Thời lượng ~ 45 phút)         │
  │                                              │
  │   ├── Bài 1: Cài đặt Flutter & Android Studio│
  │   │   [Icon Video] Video · 15 phút       [›] │
  │   │                                          │
  │   ├── Bài 2: Cấu trúc thư mục dự án          │
  │   │   [Icon Article] Bài đọc · 5 phút    [›] │
  │   │                                          │
  │   └── Bài 3: Kiểm tra kiến thức chương 1     │
  │       [Icon Quiz] Trắc nghiệm 10 câu     [›] │
  │                                              │
  │   [+ Thêm bài học vào Chương 1]              │
  ├──────────────────────────────────────────────┤
  │ ▶ CHƯƠNG 2: DART CƠ BẢN            [⋮ Menu]  │
  │   (Đang thu gọn - 5 bài học)                 │
  ├──────────────────────────────────────────────┤
  │ ▶ CHƯƠNG 3: WIDGET TRONG FLUTTER   [⋮ Menu]  │
  │   (Chưa có bài học nào)                      │
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Lấy danh sách chương: `GET /api/courses/:course_id/sections`
  * Thêm chương: `POST /api/courses/:course_id/sections`
  * Sắp xếp chương: `PUT /api/courses/:course_id/sections/reorder`
  * Lấy danh sách bài: `GET /api/sections/:section_id/lessons`
  * Thêm bài học: `POST /api/sections/:section_id/lessons`
  * Sắp xếp bài: `PUT /api/sections/:section_id/lessons/reorder`

---

#### SCR-23: Màn hình Biên tập Nội dung Bài học (`LessonContentEditor`)
- **Mục tiêu UX:** Trình soạn thảo chuyên biệt tùy theo loại nội dung học tập được chọn (`video`, `article`, `quiz`, `exercise`).
- **Điểm vào:** Chạm vào một bài học trong giáo trình `SCR-21`.
- **Chi tiết từng phân loại nội dung:**
  1. **Video (`video`):**
     * Chọn file video từ thiết bị -> Tải lên theo cơ chế chia nhỏ (Multipart Chunk Presigned URL).
     * Hiển thị thanh tiến trình tải lên (Progress %), tốc độ tải, nút Tạm dừng / Tiếp tục (Pause / Resume).
     * Trạng thái sau khi upload: *"Đang xử lý nén & chuyển mã HLS trên máy chủ"*.
  2. **Bài đọc (`article`):**
     * Tiêu đề bài đọc, ô nhập nội dung định dạng Markdown/HTML, chế độ xem trước (Preview) trực quan.
  3. **Trắc nghiệm (`quiz`):**
     * Cài đặt chung: Thời gian làm bài (phút), Điểm đạt (%), Số lần làm bài tối đa, Đảo câu hỏi/đáp án.
     * Ngân hàng câu hỏi: Thêm câu hỏi loại Single choice, Multiple choice, True/False, Điền khuyết.
     * Cấu hình đáp án đúng và lời giải thích chi tiết.
  4. **Bài tập lập trình (`exercise`):**
     * Chọn ngôn ngữ hỗ trợ (Python, Java, C++, JavaScript, Go).
     * Khung nhập mã mẫu khởi đầu (Starter code) và mã giải mẫu (Solution).
     * Cấu hình giới hạn CPU Time Limit (giây) và Memory Limit (MB).
     * Trình quản lý bộ Testcase: Nhập thủ công hoặc tải file zip import testcase. Phân loại rõ testcase công khai (Sample test) và testcase chấm ẩn (Hidden test).

---

#### SCR-24: Màn hình Kiểm tra Sẵn sàng & Nộp duyệt (`CourseReviewReadinessScreen`)
- **Mục tiêu UX:** Đảm bảo khóa học hoàn thiện 100% trước khi gửi Admin, loại bỏ nguy cơ bị từ chối do lỗi sơ đẳng (bài học rỗng, chưa có giá, thiếu mô tả).
- **Điểm vào:** Nút "Kiểm tra & Gửi duyệt" từ `SCR-20`.
- **Phân vùng bố cục:**
  * Checklist điều kiện tự động:
    - [✓] Đã điền đầy đủ tiêu đề, mô tả và ảnh bìa.
    - [✓] Đã cấu hình học phí hoặc chọn miễn phí.
    - [✓] Khóa học có ít nhất 1 Chương và 1 Bài học.
    - [!] Bài học chưa có nội dung: Liệt kê chi tiết tên các bài còn rỗng (kèm link chạm để mở thẳng trang thêm nội dung).
  * Khung cảnh báo quy định: *"Sau khi gửi duyệt, khóa học sẽ bị khóa chỉnh sửa tạm thời cho đến khi Admin có kết quả phê duyệt. Bạn có thể rút yêu cầu bất kỳ lúc nào."*
  * Nút CTA Chính: **"GỬI YÊU CẦU PHÊ DUYỆT"** (`POST /api/courses/:id/submit-review`) — Chỉ sáng khi toàn bộ checklist đạt yêu cầu.

---

### Nhóm 5: Thu nhập Cá nhân & Ví Giảng viên (Earnings & Payouts)

#### SCR-26: Màn hình Tổng quan Thu nhập & Ví Cá nhân (`TeacherEarningsScreen`)
- **Mục tiêu UX:** Minh bạch tài chính, giúp giảng viên theo dõi doanh thu tích lũy, số dư khả dụng và thực hiện yêu cầu rút tiền về tài khoản ngân hàng.
- **Điểm vào:** Icon Ví tiền từ Tab Khóa học (`SCR-17`) hoặc lối tắt tại Tab Hôm nay (`SCR-03`).
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [<- Back] Thu nhập cá nhân         [Lịch sử] │
  ├──────────────────────────────────────────────┤
  │ ┌──────────────────────────────────────────┐ │
  │ │ CARD SỐ DƯ KHẢ DỤNG                      │ │
  │ │ 18.450.000 đ                             │ │
  │ │ (Có thể rút ngay về tài khoản)           │ │
  │ │ ──────────────────────────────────────── │ │
  │ │ • Tổng tích lũy: 45.000.000 đ            │ │
  │ │ • Đã chi trả:    25.000.000 đ            │ │
  │ │ • Đang chờ duyệt: 1.550.000 đ            │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ ┌──────────────────────────────────────────┐ │
  │ │ TÀI KHOẢN NGÂN HÀNG NHẬN TIỀN            │ │
  │ │ [Icon Ngân hàng] Vietcombank             │ │
  │ │ Số tài khoản: •••••••• 5678              │ │
  │ │ Chủ tài khoản: NGUYEN VAN A              │ │
  │ │ [Nút text: Thay đổi tài khoản ngân hàng] │ │
  │ └──────────────────────────────────────────┘ │
  │                                              │
  │ [NÚT CTA CHÍNH: YÊU CẦU RÚT TIỀN]            │
  │ (Điều kiện: available_balance >= min_amount  │
  │  và has_open_withdrawal == false)           │
  │ (min_amount hiển thị động từ API, k hardcode)│
  │                                              │
  │ [Section: Biến động gần đây]                 │
  │ • + 599.000 đ | Bán khóa học Flutter  | Hôm qua
  │ • + 399.000 đ | Bán khóa học Python   | 10/11│
  │ • - 5.000.000 đ | Rút tiền thành công | 05/11│
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Nguồn API:**
  * Thông tin ví: `GET /api/wallet/teacher/me`
  * Model (`TeacherWalletResponse` chuẩn `walletDTO.go`): `total_earnings`, `total_paid_out`, `available_balance`, `pending_withdrawal`, `min_withdrawal_amount` (giá trị động do server cấu hình, fallback 100.000 đ, tuyệt đối không hardcode trên mobile), `has_open_withdrawal` (boolean), `bank_name`, `bank_account_number`, `bank_account_name`.
- **Modal Rút tiền (`MOD-28`):**
  * Nhập số tiền muốn rút (ràng buộc validation động: `value >= min_withdrawal_amount` và `value <= available_balance`).
  * Preview thông tin: Số tiền rút, số tài khoản che số, tên ngân hàng nhận.
  * Trạng thái chặn rút: Nếu `has_open_withdrawal == true`, nút rút tiền bị vô hiệu hóa kèm nhãn cảnh báo: *"Bạn đang có một yêu cầu rút tiền chưa xử lý xong"*.
  * Nút "Xác nhận gửi": Có cơ chế Optimistic Guard chống bấm lặp; nếu server timeout hoặc trả về >= 500, hệ thống cảnh báo kiểm tra lại lịch sử thay vì cho gửi tiếp.

---

#### SCR-27: Màn hình Lịch sử Giao dịch & Rút tiền (`TeacherWalletHistory`)
- **Mục tiêu UX:** Cho phép tra cứu chi tiết dòng tiền (Doanh thu bán khóa học, Hoàn tiền học viên) và quản lý tiến độ các lệnh rút tiền.
- **Điểm vào:** Nút "Lịch sử" góc phải trên tại `SCR-26`.
- **Cấu trúc 2 Tab:**
  1. **Tab 1: Lịch sử Giao dịch (Transactions):**
     * Bộ lọc: Tất cả, Doanh thu (`income`), Hoàn tiền (`refund`).
     * Dòng giao dịch: Tên khóa học phát sinh, mã đơn hàng, số tiền (+/-), ngày giờ, trạng thái.
  2. **Tab 2: Lịch sử Yêu cầu Rút tiền (Withdrawals):**
     * Danh sách các đợt rút: Mã yêu cầu, số tiền, ngân hàng nhận, ngày gửi yêu cầu, trạng thái (`pending`, `approved`, `completed`, `rejected`, `cancelled`).
     * **Tính năng Hủy yêu cầu rút:** Nếu trạng thái đang là `pending`, hiển thị nút "Hủy yêu cầu" (`POST /api/wallet/teacher/withdrawals/:id/cancel`). Khi đã `approved` hoặc `completed`, nút hủy tự động ẩn.

---

### Nhóm 6: Công cụ Giảng dạy Mở rộng & Realtime (Advanced Teaching Tools)

#### SCR-30: Màn hình Trung tâm Công cụ Mở rộng (`TeacherAdvancedScreen`)
- **Mục tiêu UX:** Cung cấp menu tập trung cho các tính năng thời gian thực và học liệu nâng cao mà không làm quá tải thanh điều hướng chính.
- **Điểm vào:** Từ tile "Công cụ giảng dạy" tại Tab Hôm nay (`SCR-03`).
- **Danh mục công cụ:**
  1. *Phòng học trực tuyến (Live Sessions):* Lên lịch phát trực tiếp và mở phòng dạy LiveKit (`SCR-31`, `SCR-32`).
  2. *Hộp thư & Tin nhắn (Messages):* Trò chuyện 1-1 với học viên và phụ huynh (`SCR-33`).
  3. *Thảo luận & Hỏi đáp (Discussions):* Trả lời câu hỏi thắc mắc của học viên theo từng bài học (`SCR-34`).
  4. *Quản lý tải video (Video Upload Studio):* Quản lý các file video bài giảng đang tải lên dở dang (`SCR-35`).
  5. *Cuộc thi trắc nghiệm (Contests):* Tổ chức các kỳ thi thử thách quiz có xếp hạng (`SCR-36`).

---

#### SCR-32: Màn hình Phòng Dạy Trực tuyến LiveKit (`TeacherLiveRoomScreen`)
- **Mục tiêu UX:** Lớp học ảo tương tác hai chiều thời gian thực giữa giáo viên và học sinh với đầy đủ công cụ kiểm soát lớp học.
- **Điểm vào:** Kích hoạt khi bấm "Vào phòng dạy" từ `SCR-03` hoặc `SCR-06`.
- **Phân vùng bố cục (Layout Blueprint):**
  ```text
  ┌──────────────────────────────────────────────┐
  │ [Phòng Live: Lớp 10A1] [00:45:12] [Rời phòng]│
  ├──────────────────────────────────────────────┤
  │                                              │
  │           KHUNG HÌNH CHÍNH (CAMERA /         │
  │             CHIA SẺ MÀN HÌNH /               │
  │             BẢNG TRẮNG WHITEBOARD)           │
  │                                              │
  ├──────────────────────────────────────────────┤
  │ [Dải video thumbnail của các học viên]       │
  │ [Avatar HS 1] [Avatar HS 2] [Avatar HS 3]    │
  ├──────────────────────────────────────────────┤
  │ [Cửa sổ Chat phòng học nổi / Thu gọn được]  │
  ├──────────────────────────────────────────────┤
  │ THANH ĐIỀU KHIỂN CỦA GIÁO VIÊN (HOST TOOLS)  │
  │ [Bật/Tắt Mic] [Bật/Tắt Cam] [Bảng trắng]     │
  │ [Danh sách học viên (30)] [Khóa Mic cả lớp] │
  │ [NÚT ĐỎ NỔI BẬT: KẾT THÚC BUỔI HỌC CHO TẤT CẢ]│
  └──────────────────────────────────────────────┘
  ```
- **Hợp đồng dữ liệu & Tích hợp SDK:**
  * Lấy LiveKit Token: `POST /api/livestream/:id/join`
  * Quản lý quyền: Mute học sinh (`POST /api/livestream/:id/mute`), mời học sinh ra khỏi phòng (`POST /api/livestream/:id/kick`), khóa/mở bảng vẽ (`POST /api/livestream/:id/lock-whiteboard`).
  * Kết thúc buổi dạy: `POST /api/livestream/:id/end` (chỉ dành cho giáo viên chủ trì).

---

#### SCR-33: Màn hình Hộp thư & Trao đổi (`TeacherMessagesScreen` & `TeacherConversationScreen`)
- **Mục tiêu UX:** Kênh liên lạc trực tiếp an toàn, gắn với ngữ cảnh giáo dục giữa giáo viên với từng học viên hoặc phụ huynh.
- **Phân vùng bố cục:**
  * Danh sách hội thoại gần nhất: Avatar, tên người gửi (kèm badge: Học viên lớp X / Phụ huynh em Y), tin nhắn mới nhất, thời gian, số tin chưa đọc.
  * Nút "Soạn tin nhắn mới" -> Cho phép chọn người nhận từ danh bạ lớp học hoặc danh sách học viên khóa học (`TeacherContactPickerScreen`).
  * Khung chat chi tiết: Bong bóng tin nhắn, gửi văn bản, hình ảnh, file tài liệu, hỗ trợ realtime qua WebSocket.

---

### Nhóm 7: Tab Tài khoản & Thiết lập Vai trò (Shared Account & Identity)

#### SCR-37: Màn hình Tài khoản Chung (`TeacherProfileScreen` / `SharedAccountContent`)
- **Mục tiêu UX:** Kế thừa thành phần tài khoản dùng chung của cả hệ thống 40Study, tạo sự đồng nhất tuyệt đối về nhận diện tài khoản giữa các vai trò Học viên, Phụ huynh và Giáo viên.
- **Điểm vào:** Tab thứ năm trên BottomNavigationBar.
- **Phân vùng bố cục:**
  * Thẻ Hồ sơ cá nhân (`ProfileCard`): Avatar, Họ tên, Email/Số điện thoại, System Role badge: `GIÁO VIÊN`.
  * Mục Chuyển đổi Vai trò (`SwitchProfileSection`): Nút "Đổi vai trò đang hoạt động" -> Kích hoạt `MOD-38`.
  * Mục Giảng dạy & Chuyên môn: Lối tắt vào "Hồ sơ năng lực giảng viên" (`SCR-02`).
  * Mục Cài đặt Ứng dụng: Ngôn ngữ, Giao diện (Sáng / Tối / Hệ thống), Cài đặt thông báo.
  * Mục Hỗ trợ & Thông tin: Điều khoản sử dụng, Chính sách bảo mật, Phiên bản ứng dụng.
  * Nút Đăng xuất (`LogoutTile`): Xác nhận đăng xuất và xóa phiên làm việc an toàn.

---

## 5. QUY CHUẨN THIẾT KẾ ĐỂ PHỤC VỤ DỰNG WIREFRAME (WIREFRAME GUIDELINES)

Để bước dựng Wireframe tiếp theo (trên Figma hoặc UI kit) diễn ra nhanh chóng, chuẩn xác và không phải chỉnh sửa lại layout, các quy chuẩn sau đây được áp dụng đồng bộ:

### 5.1. Hệ thống Lưới & Khoảng cách (Spacing Scale)
- Toàn bộ khoảng cách tuân thủ thang chuẩn 4-point/8-point grid của 40Study:
  * `xs` = 4dp (Khoảng cách giữa icon và label nhỏ).
  * `sm` = 8dp (Khoảng cách giữa các chip, badge, padding trong list item).
  * `md` = 12dp (Khoảng cách giữa các dòng thông tin trong card).
  * `lg` = 16dp (Padding chuẩn trong card, khoảng cách giữa các khối nhỏ).
  * `screenPadding` = 24dp (Lề trái/phải mặc định của toàn màn hình).
  * `xl` = 32dp (Khoảng cách phân cách giữa các Section lớn).

### 5.2. Nguyên tắc Typography & Phân cấp Thị giác
- Sử dụng font hệ thống (Inter / Roboto) với các cấp bậc:
  * `headlineSmall` (24sp, bold): Dùng cho tiêu đề trang chính, con số thống kê lớn trong ví tiền.
  * `titleLarge` (20sp, bold): Dùng cho tên màn hình con trên AppBar, tiêu đề các Section chính.
  * `titleMedium` (16sp, semi-bold): Dùng cho tên lớp học, tên khóa học, tên học sinh trên danh sách.
  * `bodyMedium` (14sp, regular): Dùng cho nội dung mô tả, nhãn trường nhập liệu.
  * `labelSmall` / `bodySmall` (12sp, regular/medium): Dùng cho ngày giờ, sĩ số, phụ chú metadata.

### 5.3. Bố cục Component Wireframe Chuẩn
- **Thẻ Card Bề mặt (`TeacherSurface`):** Bo góc `borderRadius: 12dp`, nền `surfaceContainerLow`, viền mảnh `outlineVariant` (1px), không đổ bóng gắt (elevation = 0 hoặc 1).
- **Thẻ Buổi học Tiếp theo (`TeacherNextSessionCard`):** Đặt ở vị trí nổi bật nhất, nền nhấn thương hiệu (`primaryContainer`), chữ màu tương phản cao, nút CTA dạng `FilledButton` bo góc `8dp`.
- **Thanh Tác vụ Dính Đáy (`Sticky Bottom Action Bar`):** Luôn có độ cao cố định 64–72dp, nổi phía trên bàn phím hoặc danh sách cuộn, chứa thông tin số bản nháp thay đổi kèm 1 nút hành động chính chiếm trọn chiều ngang hoặc cặp nút "Hủy / Lưu".

---

## 6. KẾ HOẠCH BÀN GIAO & CÁC BƯỚC TIẾP THEO (NEXT STEPS)

### 6.1. Trình tự Dựng Wireframe Đề xuất
- **Đợt 1 (Core Daily Teaching - P0):**
  1. Dựng Wireframe `SCR-03` (Hôm nay) & `MOD-04` (Chọn nơi làm việc).
  2. Dựng Wireframe `SCR-05` (Lịch dạy) & `SCR-06` (Chi tiết buổi học).
  3. Dựng Wireframe `SCR-08` (Màn hình Điểm danh & Xử lý bản nháp).
- **Đợt 2 (Class & Academic Management - P1):**
  4. Dựng Wireframe `SCR-10` (Danh sách lớp) & `SCR-12` (Chi tiết lớp 5 Sub-tabs kèm `SCR-13A` Phân công GV & `SCR-13B` Ghi danh học viên).
  5. Dựng Wireframe `SCR-14` (Chi tiết bài tập / Xem code nộp) & `SCR-16` (Bảng điểm).
- **Đợt 3 (Course Studio & Finance - P1):**
  6. Dựng Wireframe `SCR-17` (Danh sách khóa học), `SCR-18` (Metadata & Học phí gộp) & `SCR-20` (Chi tiết quản lý khóa).
  7. Dựng Wireframe `SCR-21` (Biên soạn giáo trình cây Chương-Bài), `SCR-22` (Danh mục bài) & `SCR-24` (Checklist nộp duyệt).
  8. Dựng Wireframe `SCR-26` (Ví thu nhập) & `MOD-28` (Modal rút tiền an toàn).
- **Đợt 4 (Realtime & Onboarding - P2):**
  9. Dựng Wireframe `SCR-01` (Trạng thái ứng viên) & `SCR-02` (Hồ sơ chuyên môn 5 trường chuẩn DTO).
  10. Dựng Wireframe `SCR-32` (Phòng dạy LiveKit) & `SCR-33` (Hộp thư tin nhắn).

### 6.2. Checklist Đánh giá Wireframe trước khi chuyển sang UI Visual Design
- [ ] Mọi màn hình đều có trạng thái **Loading (Skeleton)**, **Empty State (Chưa có dữ liệu)** và **Error State (Lỗi kết nối/Quyền)**.
- [ ] Không có nút bấm hoặc hành động nào "mồ côi" không có đích đến hoặc không có phản hồi hệ thống.
- [ ] Toàn bộ các quy tắc phân quyền (`can_manage`, `can_assign_teachers`, `is_archived`) đều có giải pháp thị giác tương ứng (ẩn nút hoặc hiển thị nhãn giải thích).
- [ ] Kiểm tra khả năng hiển thị trên màn hình nhỏ (bề rộng 360dp) không bị tràn chữ (*overflow*).


---

## 7. ĐỐI SOÁT & TỐI ƯU HÓA PHẠM VI (REVIEW MOBILE VS. WEB & DESIGN COMPARISON)

### 7.1. Rà soát Thừa & Thiếu: Bản Mobile là sự cô đọng của Bản Web

#### A. Những điểm BỊ THỪA trên Mobile (Cần tinh giản / Chuyển trọng tâm sang Web)
Bản Web của 40Study dành cho Teacher có không gian màn hình lớn (Desktop 1920x1080), chuột và bàn phím vật lý nên chứa nhiều luồng quản trị phức tạp. Việc đưa nguyên vẹn các luồng này lên Mobile sẽ dẫn đến trải nghiệm nặng nề và kém hiệu quả:
1. **Soạn thảo Khóa học chuyên sâu từ con số 0 (Heavy Course Authoring):**
   * *Trên Web:* Trình wizard tạo khóa nhiều bước, tải video 4K dung lượng lớn, trình soạn thảo rich-text HTML/Markdown bài giảng dài, tạo bài tập lập trình kèm cấu hình compiler/memory limit, import bộ testcase từ file zip, soạn đề quiz 50 câu trắc nghiệm.
   * *Trên Mobile:* Màn hình cảm ứng 360–430dp không phù hợp để gõ code, zip testcase hay viết bài luận sư phạm.
   * *Giải pháp tinh gọn:* Mobile chỉ nên là công cụ **"Review, Toggling & Quick Edits"**: Xem nhanh trạng thái duyệt của Admin (`pending`, `approved`, `rejected`), rút yêu cầu duyệt khi cần, bật/tắt Publish, xem trước bài giảng, và chỉnh sửa nhanh các trường ngắn (giá bán, hạn giảm giá, mô tả tóm tắt). Luồng tạo mới toàn bộ khóa học đồ sộ nên được khuyến nghị thực hiện trên Web Dashboard.
2. **Bảng điểm Ma trận 2 Chiều (2D Grade Matrix):**
   * *Trên Web:* Bảng 15 cột điểm x 40 học sinh trải rộng trên màn hình ngang rất trực quan.
   * *Trên Mobile:* Cố gắng dựng một bảng 15 cột cuộn ngang - cuộn dọc trên điện thoại sẽ gây lag, dễ chạm nhầm và bàn phím ảo sẽ che khuất dữ liệu.
   * *Giải pháp tinh gọn:* Mobile cần ưu tiên luồng **"Chấm điểm theo từng cột" (Single-column Batch Entry)** hoặc **"Chấm theo hồ sơ học viên" (Student-centric Card)**: Giáo viên chọn cột "Kiểm tra 15p" rồi vuốt dọc danh sách học sinh để gõ 1 hàng điểm từ trên xuống dưới.
3. **Module Quản lý Cuộc thi (Contests) & Upload Video ngầm:**
   * *Trên Web:* Quản trị cuộc thi quy mô lớn với hàng ngàn thí sinh, bảng xếp hạng realtime.
   * *Trên Mobile:* Giáo viên chỉ cần xem danh sách thí sinh và kết quả thay vì ngồi tạo đề thi cuộc thi. Cơ chế tải video đa phần (Chunked multipart) trên di động khi không có foreground service chạy ngầm rất dễ bị hệ điều hành tắt khi khóa màn hình, chỉ nên giữ ở mức xem danh sách tiến độ upload dở dang.
4. **Dashboard Phân tích Chuyên sâu (`analytics`) & Danh bạ Học viên Xuyên lớp (`students`):**
   * *Trên Web:* Web có trang `/teacher/analytics` (biểu đồ doanh thu, hiệu suất học tập) và trang `/teacher/students` (danh bạ học sinh tổng hợp với bộ lọc đa lớp).
   * *Trên Mobile:* Màn hình nhỏ không phù hợp để hiển thị dashboard biểu đồ đa chiều. Về mặt sư phạm di động, giáo viên tương tác với học sinh theo từng Lớp học cụ thể (`SCR-12` Sub-tab 3: Học viên & `SCR-13B`) thay vì duyệt một danh bạ phẳng hàng trăm em. Do đó, Mobile MVP chủ động bỏ qua trang Analytics và danh bạ xuyên lớp, tập trung vào quản lý học viên theo lớp để tối ưu không gian hiển thị (dù Backend có sẵn API `GET /api/teachers/me/students`).

#### B. Những điểm BỊ THIẾU trên Mobile (Phân loại theo tính khả thi kỹ thuật)
Giáo viên sử dụng điện thoại khi đang di chuyển, đứng trên bục giảng hoặc xử lý nhanh các tình huống phát sinh:
1. **Liên lạc khẩn cấp một chạm (One-tap Parent Call) — [Sẵn sàng Triển khai]:**
   * Trong lúc điểm danh (`SCR-08`) hoặc xem danh sách lớp (`SCR-13B`), nếu học sinh vắng không phép hoặc có dấu hiệu bất thường, giáo viên có icon **"Gọi điện cho Phụ huynh"** trực tiếp. 
   * *Khả thi kỹ thuật:* Backend `TeacherStudentDTO` đã có sẵn trường `parent_phone` và `parent_name`. Mobile chỉ cần kích hoạt `url_launcher: tel:<parent_phone>` để gọi ngay qua native dialer của điện thoại.
2. **Tiếp nhận & Phê duyệt Đơn xin nghỉ phép (Leave Requests) — [Chờ Backend / Phase 2]:**
   * *Ý tưởng:* Phụ huynh nộp đơn xin nghỉ, giáo viên thấy badge báo để duyệt thẳng thành "Vắng có phép".
   * *Ràng buộc thiết kế:* Hiện tại Backend **chưa có** router & service quản lý đơn nghỉ phép. Tuân thủ nguyên tắc *"Không dựng nút hoạt động giả"*, Mobile **chưa dựng** UI cho tính năng này ở Đợt 1, giữ trong backlog chờ Backend.
3. **Chế độ Điểm danh Ngoại tuyến (Offline-first Attendance) — [Chờ Nâng cấp Cục bộ / Phase 2]:**
   * *Ý tưởng:* Lưu tạm dữ liệu điểm danh vào SQLite khi mất sóng phòng học và tự động sync ngầm.
   * *Ràng buộc thiết kế:* Hiện tại tầng Data của Mobile đang giao tiếp trực tiếp qua REST API Dio (`POST /attendances/bulk`). Ở Đợt 1, áp dụng cơ chế **Local Memory Draft State & Retry Dialog** khi có lỗi mạng; chưa tích hợp database ngầm phức tạp.
4. **Trung tâm Thông báo Học vụ Đẩy (Push Notifications Center) — [Tích hợp FCM]:**
   * Cảnh báo đẩy thời gian thực: *"Còn 15 phút nữa đến ca dạy lớp 10A1"*, *"Học sinh nộp bài muộn"*, *"Admin đã duyệt khóa học của bạn"*, *"Lệnh rút tiền đã được xử lý"*. Sẵn sàng kết nối khi kích hoạt Firebase Messaging.

---

### 7.2. Ngôn ngữ Thiết kế: So sánh Giáo viên (Teacher) vs. Phụ huynh (Parent) & Học viên (Student)

#### A. Những ĐIỂM KHÁC BIỆT (Divergence by Role & Persona)

| Khía cạnh UI/UX | Học viên (Student) | Phụ huynh (Parent) | Giáo viên (Teacher) |
| :--- | :--- | :--- | :--- |
| **Mục tiêu sử dụng** | Học tập, giải trí, thi đua, làm bài, tương tác bạn bè. | Giám sát, bảo bọc, kiểm tra tiến độ, đóng học phí. | **Làm việc tác nghiệp, quản lý học vụ, đánh giá, kiểm soát tài chính.** |
| **Tâm thế người dùng** | Hào hứng, khám phá, thụ hưởng nội dung (*Consumer*). | Lo lắng, cẩn trọng, quan sát từ xa (*Monitor*). | **Nghiêm túc, hiệu quả, tiết kiệm thời gian (*Operator/Producer*).** |
| **Mật độ thông tin (Density)** | **Thoáng đãng, thị giác cao:** Ảnh bìa lớn, thẻ khóa học bo góc to, avatar rực rỡ, chuỗi ngày học (*streak* ngọn lửa). | **Rõ ràng, chỉ số minh bạch:** Biểu đồ điểm số, thẻ chuyên cần, lịch học của con, ví coin. | **Mật độ dữ liệu cao, cấu trúc bảng/danh sách dày:** Dòng học sinh gọn gàng, mã học sinh, tỷ lệ phần trăm, bộ đếm sĩ số, danh sách buổi học. Ít yếu tố trang trí rườm rà. |
| **Tone & Mood thị giác** | Trẻ trung, rực rỡ, khuyến khích qua game hóa (*Gamification badges, level*). | Đĩnh đạc, ấm áp, tin cậy, nhẹ nhàng. | **Chuyên nghiệp, tinh gọn, tập trung cao độ (Workspace Tool).** Bề mặt phẳng, không đổ bóng màu mè, đường ngăn dứt khoát. |
| **Hành động chính (CTA)** | "Vào học ngay", "Làm quiz", "Khám phá khóa học". | "Nạp tiền", "Nhắc nhở con", "Xem chi tiết học tập". | **"Bắt đầu dạy", "Điểm danh ngay", "Lưu sổ điểm", "Gửi duyệt", "Rút tiền".** |
| **Phương thức Tương tác** | Chạm chọn trắc nghiệm, vuốt xem video, gõ comment ngắn. | Đọc báo cáo, chọn ngày xem lịch, quét mã chuyển khoản. | **Thao tác hàng loạt (Bulk actions):** Đánh dấu có mặt tất cả, nhập một cột điểm, lọc nơi làm việc, kéo thả sắp xếp bài học. |

#### B. Những ĐIỂM CỐT LÕI BẮT BUỘC GIỮ NGUYÊN (Design Consistency & Foundations)

Mặc dù có sự khác biệt rõ rệt về công năng, nhưng vì cùng nằm trong **một ứng dụng di động 40Study duy nhất**, các thành phần nền tảng sau **bắt buộc phải đồng nhất 100%**:
1. **Hệ thống Design Tokens & Material 3:**
   - Bảng màu chủ đạo: Sử dụng cùng màu xanh thương hiệu (`primary`), cùng màu nền `surface`, `surfaceContainerLow` cho cả 3 vai trò. Không tự ý đổi sang bảng màu riêng cho Teacher.
   - Thang đo khoảng cách (`AppSpacing`): Giữ nguyên chuẩn 4, 8, 12, 16, 24, 32dp.
   - Bo góc (`AppRadius`): Button và input bo góc 8dp; Dialog bo góc 12dp; Card bo góc 12dp/16dp.
   - Typography: Dùng chung bộ font (Inter / Roboto) với các cấp bậc hiển thị chuẩn (`headlineSmall`, `titleLarge`, `titleMedium`, `bodyMedium`, `labelSmall`).
2. **Khung Header Hệ thống (`RoleAppHeader`):**
   - Cả 3 vai trò đều sử dụng chung widget `RoleAppHeader`: Vòng tròn icon bên trái, nhãn vai trò in hoa ("GIÁO VIÊN 40STUDY", "HỌC VIÊN 40STUDY", "PHỤ HUYNH 40STUDY"), tiêu đề màn hình lớn và Avatar góc phải dẫn đến Tab Tài khoản.
3. **Tab Tài khoản Dùng Chung (`SharedAccountContent`):**
   - Tab thứ 5 của Teacher tái sử dụng hoàn toàn thành phần tài khoản của hệ thống: Đổi vai trò linh hoạt (`RoleSwitcher`), xem thông tin cá nhân, cài đặt giao diện Sáng/Tối, cài đặt bảo mật và Đăng xuất. Giáo viên có thể đổi vai trò sang Phụ huynh hoặc Học viên ngay lập tức mà không phải đăng nhập lại.
4. **Cấu trúc Khay Bề mặt (`CurvedSurfaceTray`):**
   - Phần nội dung cuộn bên dưới Header của Teacher tiếp tục sử dụng khay bề mặt bo cong mềm mại ở đỉnh (`CurvedSurfaceTray`), tạo sự chuyển tiếp thị giác mượt mà và đồng bộ với giao diện của Học viên.
5. **Thanh Điều hướng Đáy (Bottom Navigation Bar):**
   - Duy trì chuẩn NavigationBar 5 tab với icon có 2 trạng thái: Biểu tượng nét mảnh (*outlined*) khi chưa chọn và biểu tượng đặc (*filled*) khi đang kích hoạt.
