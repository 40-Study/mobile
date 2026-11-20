# BÁO CÁO TOÀN DIỆN HỆ THỐNG (BACKEND & MOBILE) VÀ DANH MỤC API ROLE TEACHER
**Dự án:** 40Study Education Ecosystem  
**Thời gian cập nhật:** Tháng 11/2026  
**Nhánh đối chiếu:** `main` (Backend) | `Thu/UI_Teacher` (Mobile)  
**Tập tin tài liệu:** `mobile/docs/UI-Teacher-plan/TEACHER_BACKEND_MOBILE_SYSTEM_REPORT.md`  
**Mục tiêu:** Báo cáo kỹ thuật chi tiết nhất, không tóm tắt, trả lời triệt để 9 câu hỏi nghiệp vụ và đối chiếu cấu trúc mã nguồn thực tế của Backend (Go/Fiber) và Mobile (Flutter).

---

## MỤC LỤC
1. [Phần 1: Trả lời Chi tiết 9 Câu hỏi Kỹ thuật Cốt lõi](#phần-1-trả-lời-chi-tiết-9-câu-hỏi-kỹ-thuật-cốt-lõi)
   - [Câu 1: Middleware/Handler kiểm tra `can_manage` & Nguồn gốc tính toán](#câu-1-middlewarehandler-kiểm-tra-can_manage--nguồn-gốc-tính-toán)
   - [Câu 2: Quyền gọi `POST /sessions/:id/attendances/bulk` & `POST /classes/:id/grades/bulk`](#câu-2-quyền-gọi-post-sessionsidattendancesbulk--post-classesidgradesbulk)
   - [Câu 3: Có endpoint chấm tay bài nộp (nhập điểm, nhận xét) không?](#câu-3-có-endpoint-chấm-tay-bài-nộp-nhập-điểm-nhận-xét-không)
   - [Câu 4: Quản lý bài tập (Sửa, Publish, Unpublish) & `session_id`](#câu-4-quản-lý-bài-tập-sửa-publish-unpublish--session_id)
   - [Câu 5: Model Course (Phân loại Video/Live, Status Enum, Hàm chuyển trạng thái)](#câu-5-model-course-phân-loại-videolive-status-enum-hàm-chuyển-trạng-thái)
   - [Câu 6: Vấn đề Lương, Giờ dạy, Thù lao, Payroll, Timesheet của Giáo viên Tổ chức](#câu-6-vấn-đề-lương-giờ-dạy-thù-lao-payroll-timesheet-của-giáo-viên-tổ-chức)
   - [Câu 7: Endpoint danh sách học viên đã mua khóa học](#câu-7-endpoint-danh-sách-học-viên-đã-mua-khóa-học)
   - [Câu 8: Cấu trúc Response của `/me/timetable` và `/classes/:id/students`](#câu-8-cấu-trúc-response-của-metimetable-và-classesidstudents)
   - [Câu 9: Bảng giá trị mã màu Hex trong `app_colors.dart` & Theme tokens](#câu-9-bảng-giá-trị-mã-màu-hex-trong-app_colorsdart--theme-tokens)
2. [Phần 2: Sơ đồ Cấu trúc Thư mục Toàn bộ Backend (Golang / Fiber)](#phần-2-sơ-đồ-cấu-trúc-thư-mục-toàn-bộ-backend-golang--fiber)
3. [Phần 3: Sơ đồ Cấu trúc Thư mục Toàn bộ Mobile (Flutter / Dart - Nhánh `Thu/UI_Teacher`)](#phần-3-sơ-đồ-cấu-trúc-thư-mục-toàn-bộ-mobile-flutter--dart---nhánh-thuui_teacher)
4. [Phần 4: Bảng Danh mục Toàn bộ API Dành cho Role Teacher (Kèm DTO & Phân quyền)](#phần-4-bảng-danh-mục-toàn-bộ-api-dành-cho-role-teacher-kèm-dto--phân-quyền)

---

## PHẦN 1: TRẢ LỜI CHI TIẾT 9 CÂU HỎI KỸ THUẬT CỐT LÕI

### Câu 1: Middleware/Handler kiểm tra `can_manage` & Nguồn gốc tính toán
**Câu hỏi:** *Middleware hoặc handler nào kiểm tra `can_manage`, và `can_manage` được tính từ đâu (vai trò trong lớp, quyền trong tổ chức, hay chủ lớp)?*

#### Trả lời chi tiết:
1. **Vị trí thực thi kiểm tra:**
   - Việc kiểm tra quyền quản lý lớp **KHÔNG** nằm ở tầng Fiber Middleware (`internal/middleware/`). Tầng Middleware chỉ đảm nhiệm xác thực danh tính JWT (`AuthMiddleware`), đối chiếu blacklist Redis, và giải mã đặt `user_id` cùng `active_org_id` vào `c.Locals`.
   - Quyền `can_manage` được kiểm tra chặt chẽ tại **Tầng Service (Service Layer)**, với nguồn chân lý duy nhất (Single Source of Truth) nằm tại tập tin:
     `backend/internal/service/class_access.go`.
   - Các hàm cốt lõi chịu trách nhiệm kiểm tra:
     - `ensureClassManageWrite(ctx, classID, actorID, isAdmin)`
     - `ensureClassManage(ctx, classID, actorID, isAdmin, perm)`
     - `ensureClassWriteOpen(ctx, classID, actorID, isAdmin)` (kết hợp kiểm tra quyền quản lý + lớp chưa bị đóng lưu trữ `is_archived`).
   - Cờ `can_manage` được tính toán và trả về client tại API chi tiết lớp `GET /classes/:id` (`backend/internal/service/class_service.go:377-386` thông qua `requireClassTeacherOrAdmin`).

2. **Công thức tính toán `can_manage`:**
   Một người dùng (`actorID`) được xác định có `can_manage = true` đối với một lớp học (`classID`) khi và chỉ khi thỏa mãn **ít nhất MỘT trong 5 điều kiện** sau:
   - **(1) Quản trị viên hệ thống (System Admin):** Cờ `isAdmin == true` (người dùng nằm trong bảng `admin_users` hoặc có vai trò quản trị tối cao).
   - **(2) Giáo viên được gán vào lớp (Teacher in Class):** Có bản ghi tồn tại trong bảng `teacher_classes` với `class_id = classID` và `teacher_id = actorID`.
     * *Chú ý quan trọng:* Kiểm tra qua `classRepo.TeacherClassExists(ctx, classID, actorID)`. Hệ thống **KHÔNG phân biệt** vai trò `primary` (giáo viên chủ nhiệm) hay `assistant` (trợ giảng). Cả hai vai trò đều có quyền `can_manage`.
   - **(3) Người tạo lớp (Class Creator):** `class.CreatedBy == actorID`.
   - **(4) Giảng viên của khóa học liên kết (Course Instructor):** Nếu lớp học gắn với một khóa học trực tuyến (`class.CourseID != nil`), và giảng viên sở hữu khóa học đó (`course.InstructorID == actorID`).
   - **(5) Quản lý của tổ chức sở hữu lớp (Organization Manager):** Nếu lớp học thuộc về một tổ chức (`class.OrganizationID != nil`), và người dùng sở hữu quyền `ORG_MEMBERS_MANAGE` trong tổ chức đó thông qua bảng phân quyền `user_organization_roles` và `role_permissions`.

3. **Phân biệt giữa `can_manage` và `can_assign_teachers`:**
   - `can_manage` cho phép: Sửa thông tin lớp học, tạo/sửa/xóa lịch lặp (schedule), tạo/sửa/xóa buổi học (session), điểm danh (attendance), cấu hình cột điểm và nhập điểm (gradebook), thêm/xóa học viên (enroll student).
   - `can_assign_teachers` (`ensureClassOwner`): Chỉ dành riêng cho **Class Owner** gồm: System Admin, Người tạo lớp (`class.CreatedBy`), hoặc Giảng viên sở hữu khóa học (`course.InstructorID`). Giáo viên bình thường được gán vào lớp (kể cả primary hay assistant) chỉ có `can_manage = true` nhưng `can_assign_teachers = false` (không được tự ý gán thêm hoặc đuổi giáo viên khác).

---

### Câu 2: Quyền gọi `POST /sessions/:id/attendances/bulk` & `POST /classes/:id/grades/bulk`
**Câu hỏi:** *Ai được gọi `POST /sessions/:id/attendances/bulk` và `POST /classes/:id/grades/bulk`? Trợ giảng hoặc giáo viên không có `can_manage` có được không?*

#### Trả lời chi tiết:
1. **Đối với `POST /sessions/:sessionId/attendances/bulk` (Điểm danh hàng loạt ca học):**
   - **Handler:** `ScheduleHandler.BulkMarkAttendance` (`backend/internal/handler/schedule_handler.go:440`).
   - **Service:** `ScheduleService.BulkMarkAttendance` (`backend/internal/service/schedule_service.go:497`).
   - **Luồng kiểm tra thẩm quyền:**
     - Gọi `s.requireSessionManage(ctx, sessionID, actorID, isAdmin, false)`.
     - Tìm thông tin buổi học `session`, lấy `session.ClassID`.
     - Gọi tiếp `s.requireClassWrite(ctx, session.ClassID, actorID, isAdmin)`.
     - Hàm này kích hoạt `ensureClassWriteOpen` -> thực thi `ensureClassManageWrite`.
   - **Kết luận quyền hạn:**
     - **Trợ giảng (Assistant Teacher): ĐƯỢC PHÉP!** Bởi vì trợ giảng có bản ghi trong bảng `teacher_classes`. Hàm `TeacherClassExists` chỉ kiểm tra sự tồn tại của cặp `(class_id, teacher_id)` mà không chặn role `assistant`.
     - **Giáo viên ngoài / Giáo viên không có `can_manage`:** **BỊ TỪ CHỐI!** Nhận lỗi `403 Forbidden` (`ErrForbidden`) hoặc `404 Not Found` (`ErrClassNotFound`).

2. **Đối với `POST /classes/:classId/grades/bulk` (Nhập điểm hàng loạt vào sổ điểm):**
   - **Handler:** `GradeHandler.BulkCreateGrades` (`backend/internal/handler/grade_handler.go:210`).
   - **Service:** `GradeService.BulkCreateGrades` (`backend/internal/service/grade_service.go:277`).
   - **Luồng kiểm tra thẩm quyền:**
     - Gọi `s.requireClassGraderWritable(ctx, classID, actorID, isAdmin)`.
     - Kích hoạt `s.ensureClassGrade(ctx, classID, actorID, isAdmin)` -> thực thi `ensureClassManageWrite`.
     - Đồng thời kiểm tra lớp chưa bị đóng lưu trữ (`class.Status != "archived"`).
   - **Kết luận quyền hạn:**
     - **Trợ giảng (Assistant Teacher): ĐƯỢC PHÉP!** Đáp ứng đầy đủ kiểm tra `ensureClassManageWrite`. Trợ giảng hoàn toàn có quyền hỗ trợ nhập điểm thành phần cho học sinh.
     - **Giáo viên ngoài / Không có `can_manage`:** **BỊ TỪ CHỐI!** Nhận lỗi `403 Forbidden` (`ErrForbidden`).

---

### Câu 3: Có endpoint chấm tay bài nộp (nhập điểm, nhận xét) không?
**Câu hỏi:** *Có endpoint chấm tay bài nộp (nhập điểm, nhận xét) không?*

#### Trả lời chi tiết:
- **CÂU TRẢ LỜI LÀ: HOÀN TOÀN KHÔNG CÓ (NO).**
- **Cơ chế hiện tại của Backend đối với bài nộp (`Submissions`):**
  - Các route liên quan đến bài nộp nằm tại `backend/internal/router/livestream_router.go:94`:
    * `POST /assignments/:id/submissions`: Học viên nộp bài code giải quyết thử thách.
    * `GET /assignments/:id/submissions`: Lấy danh sách các bài nộp của bài tập.
    * `GET /submissions/:id`: Xem chi tiết một bài nộp cụ thể kèm mã nguồn và logs kết quả chạy.
  - Toàn bộ cơ chế đánh giá bài nộp của hệ thống là **Chấm tự động 100% (Automated Evaluation)** thông qua dịch vụ runner / sandbox Judge0 (`gradeAssignmentCode` tại `backend/internal/service/submission_service.go:242`). Hệ thống tự động biên dịch, chạy các bộ test case ẩn/hiện, cập nhật trạng thái (`passed`, `failed`, `error`), tính tỷ lệ test cases vượt qua và ghi nhận output.
  - Backend **không cung cấp** bất kỳ endpoint `PUT /submissions/:id/grade` hoặc `POST /submissions/:id/feedback` nào để giáo viên ghi đè điểm số thủ công hoặc nhập nhận xét dạng chữ.
  - **Điểm số chính thức của lớp học:** Được quản lý tách biệt hoàn toàn thông qua phân hệ Sổ điểm sư phạm (Gradebook: `grade_columns` và `grades` tại `/classes/:id/grades/bulk`). Giáo viên sẽ xem kết quả làm bài của học sinh và nhập điểm quy đổi vào các cột điểm tương ứng của lớp.

---

### Câu 4: Quản lý bài tập (Sửa, Publish, Unpublish) & `session_id`
**Câu hỏi:** *Sửa, publish, unpublish bài tập: kiểm tra “người tạo” hay `can_manage`? `POST /assignments` có bắt buộc `session_id` không?*

#### Trả lời chi tiết:
1. **Kiểm tra quyền khi Sửa (`PUT`), Publish (`POST /publish`), Unpublish (`POST /unpublish`), Xóa (`DELETE`) bài tập:**
   - **Vị trí kiểm tra:** `AssignmentHandler` gọi hàm bảo vệ `requireAssignmentManager(c, assignmentID)` (`backend/internal/handler/assignment_handler.go`), hàm này chuyển tiếp tới `service.CanManage(ctx, assignmentID, userID, isAdmin)`.
   - **Thuật toán kiểm tra:**
     Hệ thống kiểm tra người dùng có quyền quản lý bài tập hay không dựa trên tập hợp rộng:
     *(1)* Quản trị viên hệ thống (Admin).
     *(2)* Người tạo ra bài tập (`assignment.CreatedBy == userID`).
     *(3)* Host chủ trì phiên học trực tuyến (`livestream_sessions.host_id == userID` nếu bài tập thuộc session).
     *(4)* Giảng viên phụ trách khóa học (`courses.instructor_id == userID`).
     *(5)* Giáo viên của lớp học (`teacher_classes` có `teacher_id == userID` và `class_id == assignment.ClassID`).
   - **Kết luận:** **Kiểm tra theo `can_manage` rộng**, KHÔNG bị bó hẹp duy nhất vào một mình người tạo ban đầu (`CreatedBy`). Các giáo viên trong cùng lớp học đều có quyền điều chỉnh bài tập của lớp.

2. **Quy định bắt buộc về `session_id` trong `POST /assignments`:**
   - DTO định nghĩa tại `backend/internal/dto/assignmentDTO.go:6`:
     ```go
     type CreateAssignmentDTO struct {
         SessionID   string `json:"session_id" validate:"omitempty,uuid"`
         ClassID     string `json:"class_id" validate:"omitempty,uuid"`
         Title       string `json:"title" validate:"required,min=3,max=255"`
         Description string `json:"description" validate:"required"`
         // ...
     }
     ```
   - Trường `session_id` có tag `validate:"omitempty,uuid"`. **Về mặt cú pháp DTO, `session_id` KHÔNG BẮT BUỘC.**
   - **Quy tắc nghiệp vụ tại Service (`assignment_service.go:50`):**
     Hệ thống yêu cầu phải có mục tiêu giao bài tập: hoặc là gắn với một buổi học trực tiếp (`session_id`), hoặc gắn với một lớp học (`class_id`). Nếu thiếu cả hai, Service trả về lỗi `ErrAssignmentTargetRequired`. Do đó, khi tạo bài tập về nhà cho lớp học thông thường, giáo viên **chỉ cần truyền `class_id` và bỏ qua `session_id`**.

---

### Câu 5: Model Course (Phân loại Video/Live, Status Enum, Hàm chuyển trạng thái)
**Câu hỏi:** *Model Course có trường phân loại video/live không? Liệt kê toàn bộ giá trị status và các hàm chuyển trạng thái, có unpublish hoặc archive không?*

#### Trả lời chi tiết:
1. **Trường phân loại Video vs Live trong Model `Course`:**
   - **HOÀN TOÀN KHÔNG CÓ.** Model `Course` (`backend/internal/model/course.go`) không có bất kỳ cột nào như `type`, `course_type`, hay `is_live`.
   - Trong kiến trúc của hệ thống, một khóa học (`Course`) là một cấu trúc phân cấp chứa các Chương (`Section`), mỗi chương chứa các Bài học (`Lesson`), và mỗi bài học chứa các Khối nội dung (`LessonContent`).
   - Việc phân loại nội dung diễn ra ở cấp `LessonContent.Type` (`backend/internal/model/course.go:125`), bao gồm 5 loại:
     * `video` (`LessonContentTypeVideo`): Video bài giảng theo yêu cầu (VOD/HLS).
     * `livestream` (`LessonContentTypeLivestream`): Buổi học trực tuyến LiveKit.
     * `exercise` (`LessonContentTypeExercise`): Bài tập lập trình thực hành.
     * `article` (`LessonContentTypeArticle`): Bài đọc lý thuyết rich text / markdown.
     * `quiz` (`LessonContentTypeQuiz`): Đề kiểm tra trắc nghiệm.
   - Các lớp học kèm giảng dạy trực tiếp có lịch cố định được tổ chức dưới dạng thực thể `Class` độc lập (`backend/internal/model/class.go`), liên kết với `Course` thông qua trường `class.CourseID`.

2. **Toàn bộ giá trị `Status` của Khóa học (`CourseStatus`):**
   Định nghĩa chuẩn tại `backend/internal/model/course_status.go:13`:
   - `draft` (`CourseStatusDraft`): Khóa học nháp, đang biên soạn nội dung, chưa hiển thị công khai.
   - `pending_review` (`CourseStatusPendingReview`): Khóa học đã nộp lên hàng đợi chờ Quản trị viên duyệt. Ở trạng thái này, khóa học bị khóa sửa (`ErrCourseLockedForReview` / `409 Conflict`).
   - `published` (`CourseStatusPublished`): Khóa học đã được duyệt và xuất bản chính thức, học viên có thể tìm kiếm, mua và học.
   - `rejected` (`CourseStatusRejected`): Khóa học bị Quản trị viên từ chối phê duyệt, có kèm lý do từ chối (`rejection_reason`). Giảng viên được phép sửa và nộp lại tối đa 3 lần.
   - `archived` (`CourseStatusArchived`): Khóa học đã lưu trữ / ngừng bán.

3. **Các hàm chuyển đổi trạng thái và luật nghiệp vụ:**
   Có 2 hàm chuyển trạng thái độc lập phục vụ các ngữ cảnh khác nhau:
   - **Hàm 1: `EvaluateCourseReviewTransition(current, action)`** (`backend/internal/repository/course_review_repository.go:126`):
     Xử lý luồng phê duyệt và kiểm duyệt khóa học:
     * `submit` (Giảng viên nộp duyệt via `POST /courses/:id/submit-review`): `draft` | `rejected` -> `pending_review` (Yêu cầu khóa học phải có ảnh bìa, mô tả, giá bán hợp lệ nếu có phí, và ít nhất 1 bài học có nội dung).
     * `approve` (Chỉ Quản trị viên via `POST /admin/courses/:id/approve`): `pending_review` -> `published` (Ghi nhận `reviewed_by` và `reviewed_at`).
     * `reject` (Chỉ Quản trị viên via `POST /admin/courses/:id/reject`): `pending_review` -> `rejected` (Bắt buộc nhập lý do từ chối).
     * `withdraw` (Giảng viên rút yêu cầu duyệt via `POST /courses/:id/withdraw-review`): `pending_review` -> `draft` (Mở khóa để giảng viên tiếp tục chỉnh sửa nội dung).
   - **Hàm 2: `ValidateManualCourseStatusChange(current, target)`** (`backend/internal/service/course_status_guard.go:26`):
     Bảo vệ API cập nhật thông tin khóa học `PUT /courses/:id`. Giảng viên không được tự ý đổi status bừa bãi. Hàm này chỉ cho phép 2 chuyển dịch an toàn:
     * `published` -> `archived`: **Cơ chế UNPUBLISH / NGỪNG BÁN chính thức của hệ thống.** Khóa học ngừng bán trên Marketplace nhưng học viên đã ghi danh trước đó vẫn tiếp tục học bình thường.
     * `archived` -> `draft`: Mở lại khóa học đã lưu trữ về trạng thái nháp để cập nhật, biên soạn lại. Muốn bán lại bắt buộc phải nộp duyệt từ đầu (`submit-review`).
     * `current == target`: Hợp lệ (giữ nguyên).
     * Mọi chuyển dịch khác trực tiếp (ví dụ cố tình gửi `draft` -> `published`) sẽ bị ném lỗi `ErrCourseStatusChangeNotAllowed` (`400 Bad Request`).

4. **Có Unpublish hoặc Archive không?**
   - **CÓ.** Cơ chế unpublish chính là chuyển từ `published` sang `archived`. Hệ thống không sử dụng từ khóa `unpublished` mà dùng `archived` làm trạng thái ngừng lưu hành thương mại của khóa học.

---

### Câu 6: Vấn đề Lương, Giờ dạy, Thù lao, Payroll, Timesheet của Giáo viên Tổ chức
**Câu hỏi:** *Có model hoặc endpoint nào về lương, giờ dạy, thù lao, payroll, timesheet của giáo viên tổ chức không?*

#### Trả lời chi tiết:
- **CÂU TRẢ LỜI LÀ: HOÀN TOÀN KHÔNG CÓ (NO).**
- **Khảo sát toàn diện mã nguồn Backend:**
  - Không có bất kỳ bảng cơ sở dữ liệu, model GORM, DTO hay router nào liên quan đến `salary`, `payroll`, `timesheet`, `teaching_hours`, `hourly_rate`, hay `remuneration` dành cho giáo viên trong tổ chức.
  - Phân hệ tài chính hiện tại (`backend/internal/model/payment.go` và `payout_status.go`) chỉ bao gồm:
    * Doanh thu bán khóa học trực tuyến cá nhân của giảng viên độc lập (`orders`, `order_items`).
    * Ví tiền tích lũy và lệnh rút tiền cá nhân của giảng viên (`instructor_payouts` thông qua các endpoint `/api/wallet/teacher/...`).
- **Ý nghĩa kiến trúc đối với vai trò Tổ chức (Organization):**
  - Thực thể `Organization` trong hệ thống 40Study chỉ đóng vai trò là **Không gian quản trị phân quyền (Administrative Boundary)** để quản lý danh sách giáo viên, lớp học, học viên và chương trình đào tạo.
  - Các chính sách tiền lương, chấm công giờ dạy, tính thù lao tiết dạy, quyết toán thuế và bảng lương của giáo viên cơ hữu / thỉnh giảng được xem là **Quy trình ngoài hệ thống (Off-platform / External HR & Payroll)** do từng trường học, trung tâm tự hạch toán riêng.

---

### Câu 7: Endpoint danh sách học viên đã mua khóa học
**Câu hỏi:** *Có endpoint danh sách học viên đã mua một khóa không?*

#### Trả lời chi tiết:
- **CÂU TRẢ LỜI LÀ: CÓ (YES).**
- **Thông số kỹ thuật Endpoint:**
  - **Phương thức & URL:** `GET /courses/:courseId/enrollments?page=1&page_size=20`
  - **Khai báo Router:** `backend/internal/router/enrollment_router.go:30`
  - **Handler phụ trách:** `EnrollmentHandler.GetCourseEnrollments` (`backend/internal/handler/enrollment_handler.go:272`)
  - **Service thực thi:** `EnrollmentService.GetCourseEnrollments` (`backend/internal/service/enrollment_service.go:1095`)
  - **Kiểm soát quyền truy cập:**
    * Danh sách học viên ghi danh là dữ liệu bảo mật của khóa học: Chỉ giảng viên sở hữu khóa học (`course.InstructorID == actorID`) hoặc Quản trị viên hệ thống (Admin) mới có quyền xem.
    * Nếu khóa học chưa xuất bản mà người gọi không phải chủ sở hữu: trả về `404 Not Found` (`ErrCourseHidden`).
    * Nếu khóa học đã xuất bản mà người gọi không phải chủ sở hữu: trả về `403 Forbidden` (`ErrNotCourseOwner`).
- **Cấu trúc dữ liệu Response DTO (`CourseEnrollmentListDTO`):**
  ```go
  type CourseEnrollmentListDTO struct {
      Enrollments []CourseEnrollmentItemDTO `json:"enrollments"`
      Total       int64                     `json:"total"`
      Page        int                       `json:"page"`
      PageSize    int                       `json:"page_size"`
  }

  type CourseEnrollmentItemDTO struct {
      ID              uuid.UUID       `json:"id"`                  // ID bản ghi ghi danh
      UserID          uuid.UUID       `json:"user_id"`             // ID học viên
      UserName        string          `json:"user_name"`           // Username học viên
      EnrolledAt      string          `json:"enrolled_at"`         // Thời gian ghi danh (RFC3339)
      ProgressPercent decimal.Decimal `json:"progress_percentage"`// Tiến độ hoàn thành khóa học (0.00 - 100.00%)
      CompletedAt     *string         `json:"completed_at,omitempty"` // Thời điểm hoàn thành toàn bộ khóa
  }
  ```

---

### Câu 8: Cấu trúc Response của `/me/timetable` và `/classes/:id/students`
**Câu hỏi:** *Response của `/me/timetable` và `/classes/:id/students` có những trường nào (đặc biệt `parent_phone`, `livestream_session_id`, `organization_id`)?*

#### Trả lời chi tiết:
1. **Response của `GET /api/me/timetable` (Thời khóa biểu giáo viên):**
   - **Khai báo DTO:** `backend/internal/dto/scheduleDTO.go:142-178` (`TimetableResponseDTO` chứa danh sách `TimetableEntryDTO`).
   - **Chi tiết toàn bộ các trường trong từng mục lịch (`TimetableEntryDTO`):**
     * `session_id`: `*uuid.UUID` (ID buổi học cụ thể, `null` nếu là lịch lặp chưa sinh buổi).
     * `schedule_id`: `*uuid.UUID` (ID cấu hình lịch lặp tuần).
     * `class_name`: `string` (Tên lớp học).
     * `class_id`: `uuid.UUID` (ID lớp học).
     * **`organization_id`**: `*uuid.UUID` -> **CÓ HIỆN DIỆN (YES).** Trả về ID tổ chức sở hữu lớp; nếu là lớp cá nhân tự do của giáo viên trường này sẽ là `null`.
     * `organization_name`: `*string` -> **CÓ HIỆN DIỆN (YES).** Tên của tổ chức.
     * `day_of_week`: `int` (Thứ trong tuần: 0 = Chủ nhật, 1 = Thứ hai, ..., 6 = Thứ bảy).
     * `date`: `*string` (Ngày diễn ra định dạng YYYY-MM-DD).
     * `start_time`: `string` (Giờ bắt đầu: HH:MM:SS).
     * `end_time`: `string` (Giờ kết thúc: HH:MM:SS).
     * `room`: `*string` (Phòng học trực tiếp).
     * `topic`: `*string` (Chủ đề tiết học).
     * `status`: `string` (`scheduled`, `in_progress`, `completed`, `cancelled`).
     * `effective_from`: `*string` (Ngày bắt đầu hiệu lực của lịch lặp).
     * `effective_until`: `*string` (Ngày kết thúc hiệu lực của lịch lặp).
     * **`livestream_session_id`**: **KHÔNG CÓ (NO).** `TimetableEntryDTO` không mang trường này. Muốn lấy `livestream_session_id` để vào phòng live, client gọi API chi tiết ca dạy `GET /sessions/:id` (trả về `ClassSessionResponseDTO`).
     * **`parent_phone`**: **KHÔNG CÓ (NO).**

2. **Response của `GET /api/classes/:id/students` (Danh sách học viên của lớp):**
   - **Khai báo DTO:** `backend/internal/dto/classDTO.go:112-128` (`StudentClassListResponseDTO` chứa mảng `StudentClassResponseDTO`).
   - **Chi tiết toàn bộ các trường trong từng học viên (`StudentClassResponseDTO`):**
     * `id`: `uuid.UUID` (ID của bản ghi liên kết `student_classes`).
     * `student_id`: `uuid.UUID` (ID tài khoản người dùng của học viên).
     * `class_id`: `uuid.UUID` (ID lớp học).
     * `enrolled_at`: `string` (Thời điểm ghi danh vào lớp).
     * `status`: `string` (Trạng thái học viên: `active`, `suspended`, `dropped`).
     * `user_name`: `string` (Tên tài khoản học viên).
     * `full_name`: `*string` (Họ và tên đầy đủ của học viên).
     * `avatar_url`: `*string` (Đường dẫn ảnh đại diện).
     * **`parent_phone`**: **HOÀN TOÀN KHÔNG CÓ (NO).** Backend cố tình không đưa thông tin số điện thoại của học viên hoặc phụ huynh vào danh sách lớp để bảo vệ quyền riêng tư dữ liệu cá nhân (PII Protection). Việc liên kết phụ huynh - học viên nằm ở bảng riêng `parent_student_relations`.
     * **`organization_id`**: **KHÔNG CÓ (NO)** trong object học viên (nó thuộc về thông tin chung của lớp tại `ClassResponseDTO`).
     * **`livestream_session_id`**: **KHÔNG CÓ (NO).**

---

### Câu 9: Bảng giá trị mã màu Hex trong `app_colors.dart` & Theme tokens
**Câu hỏi:** *Giá trị hex trong `app_colors.dart` (hoặc file theme tương đương).*

#### Trả lời chi tiết:
Toàn bộ mã màu Hex chuẩn của Design System hệ thống được định nghĩa tại `mobile/lib/theme/app_colors.dart` và bộ theme Material 3 tại `mobile/lib/theme/style.dart`:

```dart
// ============================================================================
// 1. BRAND COLORS (MÀU CHỦ ĐẠO XANH DƯƠNG CHUYÊN NGHIỆP - TogetherColorsX)
// ============================================================================
Color get brandBlue      => const Color(0xFF2563EB); // #2563EB - Xanh chủ đạo giao diện
Color get brandBlueDark  => const Color(0xFF1E40AF); // #1E40AF - Xanh đậm cho Text & Action chính
Color get brandBlueLight => const Color(0xFF3B82F6); // #3B82F6 - Xanh sáng nổi bật
Color get softBlue       => const Color(0xFF93C5FD); // #93C5FD - Xanh dịu nhẹ
Color get navy           => const Color(0xFF1E3A5F); // #1E3A5F - Xanh navy cho tiêu đề đậm

// ============================================================================
// 2. BLUE TINTS (CÁC SẮC ĐỘ XANH NHẠT ĐA TẦNG)
// ============================================================================
Color get blue50  => const Color(0xFFEFF6FF); // #EFF6FF - Nền thẻ card nhạt nhất
Color get blue100 => const Color(0xFFDBEAFE); // #DBEAFE - Đường viền / Pill container
Color get blue200 => const Color(0xFFBFDBFE); // #BFDBFE - Khung divider nhấn
Color get blue300 => const Color(0xFF93C5FD); // #93C5FD - Trạng thái focus
Color get blue400 => const Color(0xFF60A5FA); // #60A5FA - Accent thứ cấp
Color get blue500 => const Color(0xFF3B82F6); // #3B82F6 - Primary Button
Color get blue600 => const Color(0xFF2563EB); // #2563EB - Active State
Color get blue700 => const Color(0xFF1D4ED8); // #1D4ED8 - Pressed State

// ============================================================================
// 3. NEUTRAL SLATE COLORS (XÁM TRUNG TÍNH)
// ============================================================================
Color get slate50  => const Color(0xFFF8FAFC); // #F8FAFC - Nền Canvas sáng chuẩn
Color get slate100 => const Color(0xFFF1F5F9); // #F1F5F9 - Nền khay bo cong (Tray background)
Color get slate200 => const Color(0xFFE2E8F0); // #E2E8F0 - Đường viền vi tính (Border outline)
Color get slate300 => const Color(0xFFCBD5E1); // #CBD5E1 - Icon không kích hoạt
Color get slate400 => const Color(0xFF94A3B8); // #94A3B8 - Text gợi ý (Placeholder)
Color get slate500 => const Color(0xFF64748B); // #64748B - Text phụ (Secondary text)
Color get slate600 => const Color(0xFF475569); // #475569 - Text đọc đoạn văn
Color get slate700 => const Color(0xFF334155); // #334155 - Text nội dung chính
Color get slate800 => const Color(0xFF1E293B); // #1E293B - Sub-heading đậm
Color get slate900 => const Color(0xFF0F172A); // #0F172A - Tiêu đề màn hình (Dark surface)

// ============================================================================
// 4. SEMANTIC STATUS COLORS (TogetherSemanticColors)
// ============================================================================
static const success = Color(0xFF10B981); // #10B981 - Xanh lá (Có mặt, Đã duyệt, Đạt)
static const warning = Color(0xFFF59E0B); // #F59E0B - Hổ phách (Đi muộn, Chờ duyệt)
static const error   = Color(0xFFEF4444); // #EF4444 - Đỏ (Vắng mặt, Từ chối, Lỗi)
static const info    = Color(0xFF3B82F6); // #3B82F6 - Xanh dương (Thông tin, Thông báo)

// ============================================================================
// 5. ROLE IDENTITY COLORS (RoleColors)
// ============================================================================
// Student:
static const studentPrimary   = Color(0xFF3D5FC4); // #3D5FC4
static const studentSecondary = Color(0xFFEDF1FF); // #EDF1FF
// Teacher (Giáo viên):
static const teacherPrimary   = Color(0xFF1E40AF); // #1E40AF (Brand Blue Dark)
static const teacherSecondary = Color(0xFF60A5FA); // #60A5FA (Blue 400)
// Parent:
static const parentPrimary    = Color(0xFF0891B2); // #0891B2
static const parentSecondary  = Color(0xFF67E8F9); // #67E8F9
// Organization (Tổ chức / Trường):
static const orgPrimary       = Color(0xFF1E3A5F); // #1E3A5F (Navy)
static const orgSecondary     = Color(0xFF38BDF8); // #38BDF8

// ============================================================================
// 6. SURFACE CANVAS VÀ GRADIENTS
// ============================================================================
// Nền Canvas 3 lớp chuẩn:
Color get surfaceCanvas => brightness == Brightness.light
    ? Color.alphaBlend(primary.withValues(alpha: 0.045), surfaceContainer) // Pha nhẹ Primary vào nền
    : Color.alphaBlend(primary.withValues(alpha: 0.065), surfaceContainer);

// Dải màu Gradient nền:
gradientBlueLight => [Color(0xFFFFFFFF), Color(0xFFFAFCFF)]; // Light mode
gradientDark      => [Color(0xFF0F172A), Color(0xFF1E293B)]; // Dark mode
gradientPrimary   => [Color(0xFF3B82F6), Color(0xFF60A5FA)]; // Nút bấm chính
```

---

## PHẦN 2: SƠ ĐỒ CẤU TRÚC THƯ MỤC TOÀN BỘ BACKEND (GOLANG / FIBER)

Backend của dự án được triển khai bằng ngôn ngữ **Go (Golang)** với web framework **Fiber v2**, tuân thủ nghiêm ngặt mô hình kiến trúc phân lớp sạch (**Clean Layered Architecture**):

```text
C:\ForteX\backend
├── cmd/
│   ├── api/
│   │   └── main.go                       # Entrypoint khởi động REST API server Fiber
│   ├── worker/
│   │   └── main.go                       # Entrypoint chạy nền Asynq background workers
│   └── judge/
│       └── main.go                       # Runner chấm code lập trình bảo mật (Sandbox)
├── docker/                               # Cấu hình container Docker Compose cho môi trường dev & prod
├── internal/
│   ├── app/                              # Khởi tạo App context, nạp DB, Redis, cấu hình router
│   ├── apperr/                           # Chuẩn hóa mã lỗi Domain Errors & HTTP mapping
│   ├── cache/                            # Wrapper Redis đệm truy vấn, phân tán locks
│   ├── config/                           # Nạp biến môi trường .env (DB, JWT, MinIO, LiveKit)
│   ├── database/                         # GORM PostgreSQL kết nối & quản lý migration
│   │   ├── migrations.go                 # Tự động đồng bộ schema và CHECK constraints
│   │   └── seeds/                        # Bộ dữ liệu mẫu khởi tạo hệ thống
│   ├── dto/                              # Toàn bộ Data Transfer Objects & Validation tags
│   │   ├── assignmentDTO.go              # DTO bài tập, bài nộp code
│   │   ├── attendanceDTO.go              # DTO điểm danh, bulk check-in
│   │   ├── classDTO.go                   # DTO lớp học, gán giáo viên, ghi danh học viên
│   │   ├── contestDTO.go                 # DTO kỳ thi lập trình
│   │   ├── courseDTO.go                  # DTO khóa học, chương, bài học, khối nội dung
│   │   ├── enrollmentDTO.go              # DTO ghi danh khóa học, danh sách học viên
│   │   ├── gradeDTO.go                   # DTO cột điểm, bảng điểm, bulk grade
│   │   ├── livestreamDTO.go             # DTO phiên học trực tuyến LiveKit
│   │   ├── paymentDTO.go                 # DTO thanh toán, doanh thu, đơn hàng
│   │   ├── quizDTO.go                    # DTO bài kiểm tra trắc nghiệm
│   │   ├── scheduleDTO.go                # DTO thời khóa biểu, lịch lặp tuần, ca học
│   │   ├── teacherDTO.go                 # DTO thông tin sư phạm giảng viên
│   │   └── teacher_profileDTO.go         # DTO hồ sơ năng lực giáo viên & xét duyệt
│   ├── handler/                          # Tầng điều khiển HTTP Controllers (Fiber Handlers)
│   │   ├── approval_handler.go           # Duyệt khóa học, duyệt hồ sơ giáo viên
│   │   ├── assignment_handler.go         # Tạo, sửa, publish bài tập
│   │   ├── attendance_handler.go         # Điểm danh từng học viên / theo ca học
│   │   ├── class_handler.go              # Quản lý lớp học, phân công giáo viên
│   │   ├── contest_handler.go            # Quản lý kỳ thi lập trình
│   │   ├── course_handler.go             # Quản lý khóa học số cá nhân
│   │   ├── enrollment_handler.go         # Ghi danh & lấy danh sách học viên đã mua
│   │   ├── exercise_handler.go           # Quản lý bài tập code thực hành
│   │   ├── grade_handler.go              # Sổ điểm, nhập điểm bulk, tính điểm tổng
│   │   ├── lesson_content_handler.go     # Soạn thảo nội dung (Video, Bài đọc, Quiz)
│   │   ├── lesson_handler.go             # Quản lý bài học trong chương
│   │   ├── livestream_handler.go         # Khởi tạo phòng LiveKit & tạo token
│   │   ├── quiz_handler.go               # Soạn đề trắc nghiệm & câu hỏi
│   │   ├── schedule_handler.go           # Lịch lặp tuần, sinh buổi học, ca dạy
│   │   ├── section_handler.go            # Quản lý chương của khóa học
│   │   ├── submission_handler.go         # Tiếp nhận bài nộp code & logs
│   │   ├── teacher_handler.go            # Tra cứu thông tin giáo viên
│   │   ├── teacher_profile_handler.go    # Đăng ký & cập nhật hồ sơ năng lực
│   │   ├── timetable_handler.go          # Trả về thời khóa biểu tuần / ngày
│   │   ├── video_upload_handler.go       # Khởi tạo presigned URL upload S3/MinIO
│   │   └── wallet_handler.go             # Quản lý ví thu nhập & rút tiền
│   ├── middleware/                       # Tầng lọc Request Middleware
│   │   ├── auth_middleware.go            # Giải mã JWT Bearer Token, kiểm tra Redis session
│   │   ├── permission.go                 # Kiểm tra quyền hạn System & Org
│   │   ├── audit.go                      # Ghi dấu vết kiểm toán thao tác ghi
│   │   └── rate_limit.go                 # Giới hạn tần suất gọi API
│   ├── model/                            # Tầng định nghĩa thực thể Cơ sở dữ liệu (GORM Entities)
│   │   ├── assignment.go                 # Bảng assignments
│   │   ├── attendance.go                 # Bảng attendances
│   │   ├── class.go                      # Bảng classes, class_teachers, class_students
│   │   ├── course.go                     # Bảng courses, sections, lessons, lesson_contents
│   │   ├── course_status.go              # Hằng số và slice trạng thái khóa học (SSOT)
│   │   ├── enrollment.go                 # Bảng enrollments
│   │   ├── grade.go                      # Bảng grade_columns, grades, final_grades
│   │   ├── livestream_session.go         # Bảng livestream_sessions
│   │   ├── organization.go               # Bảng organizations, user_organization_roles
│   │   ├── payment.go                    # Bảng instructor_payouts, orders
│   │   ├── payout_status.go              # Trạng thái yêu cầu rút tiền (SSOT)
│   │   ├── quiz.go                       # Bảng quizzes, quiz_questions
│   │   ├── schedule.go                   # Bảng class_schedules, class_sessions
│   │   ├── teacher_profile.go            # Bảng teacher_profiles
│   │   └── user.go                       # Bảng users, roles, permissions
│   ├── repository/                       # Tầng tương tác Cơ sở dữ liệu (GORM / Raw SQL)
│   │   ├── assignment_repository.go
│   │   ├── class_access.go               # Truy vấn phân quyền truy cập lớp học
│   │   ├── class_repository.go
│   │   ├── course_repository.go
│   │   ├── course_review_repository.go   # Thực hiện chuyển trạng thái duyệt khóa học
│   │   ├── enrollment_repository.go
│   │   ├── grade_repository.go
│   │   ├── schedule_repository.go
│   │   └── teacher_profile_repository.go
│   ├── router/                           # Định nghĩa URL Endpoints REST API
│   │   ├── approval_router.go
│   │   ├── assignment_router.go
│   │   ├── class_router.go
│   │   ├── course_router.go
│   │   ├── enrollment_router.go
│   │   ├── grade_router.go
│   │   ├── livestream_router.go
│   │   ├── quiz_router.go
│   │   ├── route.go                      # SetupAllRoutes - Hub đăng ký toàn bộ router
│   │   ├── schedule_router.go
│   │   ├── teacher_profile_router.go
│   │   └── wallet_router.go
│   └── service/                          # Tầng Xử lý Nghiệp vụ Logic (Business Services)
│       ├── approval_service.go
│       ├── assignment_service.go
│       ├── class_access.go               # SSOT Kiểm tra quyền can_manage lớp học
│       ├── class_service.go
│       ├── course_service.go
│       ├── course_status_guard.go        # Kiểm tra chuyển trạng thái khóa học an toàn
│       ├── enrollment_service.go
│       ├── grade_service.go
│       ├── livestream_service.go
│       ├── quiz_service.go
│       ├── schedule_service.go
│       ├── submission_service.go         # Điều phối chấm điểm bài code
│       └── teacher_profile_service.go
└── storage/                              # Kết nối lưu trữ tệp MinIO / S3
```

---

## PHẦN 3: SƠ ĐỒ CẤU TRÚC THƯ MỤC TOÀN BỘ MOBILE (FLUTTER / DART - NHÁNH `Thu/UI_Teacher`)

Phân hệ Giáo viên trên Mobile được xây dựng theo kiến trúc **Feature-First kết hợp Phân tầng Rõ ràng (Clean Separation of Concerns)**:

```text
C:\ForteX\mobile\lib
├── core/                                 # Thành phần nền tảng dùng chung
│   ├── network/                          # Cấu hình Dio HTTP Client, Interceptor gắn Token
│   ├── storage/                          # Lưu trữ an toàn SharedPreferences / FlutterSecureStorage
│   └── errors/                           # Định nghĩa và phân loại ngoại lệ mạng / phân quyền
├── theme/                                # Hệ thống Design Tokens chuẩn
│   ├── app_colors.dart                   # Toàn bộ mã màu Hex, TogetherColorsX, RoleColors
│   ├── app_radius.dart                   # Bo góc chuẩn (8, 12, 16, 24dp)
│   ├── app_shadows.dart                  # Đổ bóng chuyên nghiệp (shadowCard, shadowElevated)
│   ├── app_spacing.dart                  # Lưới khoảng cách (4, 8, 12, 16, 24, 32dp)
│   ├── style.dart                        # ColorScheme Material 3 (Light/Dark themes)
│   └── theme.dart                        # Export tập trung các theme tokens
├── widgets/                              # Thành phần UI tái sử dụng toàn app
│   ├── curved_surface_tray.dart          # Khay bề mặt bo cong 24dp mềm mại
│   └── role_app_header.dart              # Thanh điều hướng trên cùng hiển thị Role & Avatar
└── features/
    └── teacher/                          # >>> PHÂN HỆ ĐỘC LẬP TOÀN DIỆN CHO ROLE TEACHER <<<
        ├── data/                         # TẦNG DỮ LIỆU & BỘ QUY TẮC NGHIỆP VỤ (DATA & CONTROLLERS)
        │   ├── course_rules.dart         # Quy tắc biên tập khóa học, trạng thái duyệt
        │   ├── finance_rules.dart        # Quy tắc hạn mức ví & số dư rút tiền
        │   ├── grade_rules.dart          # Quy tắc tính trọng số điểm và tổng kết
        │   ├── teacher_api.dart          # Lớp gọi Dio API kết nối trực tiếp Backend
        │   ├── teacher_core.dart         # Models thực thể cốt lõi của Teacher
        │   ├── teacher_preview_api.dart  # Bộ dữ liệu Mock hoàn chỉnh phục vụ chế độ xem trước
        │   ├── teacher_preview_workplace.dart # Dữ liệu nơi làm việc mẫu
        │   ├── teacher_realtime.dart     # Kết nối WebSocket nhận thông báo & tương tác
        │   ├── teacher_workplace_controller.dart # Quản lý đổi ngữ cảnh (Cá nhân vs Tổ chức)
        │   └── video_upload_controller.dart # Điều phối tải video phân đoạn lên MinIO
        └── presentation/                 # TẦNG GIAO DIỆN & MÀN HÌNH CHUYÊN BIỆT CỦA GIÁO VIÊN
            ├── teacher_shell.dart        # Khung Shell cố định 5 Tabs đáy với State lưu trữ
            ├── home/                     # TAB 1: HÔM NAY (TODAY DASHBOARD)
            │   ├── teacher_home_screen.dart # SCR-03: Dashboard tổng quan ca dạy hôm nay
            │   ├── teacher_next_session_card.dart # Hero Card ca dạy sắp diễn ra kế tiếp
            │   └── teacher_quick_actions.dart # Dải phím tắt: Điểm danh, Tạo ca, Bảng điểm
            ├── schedule/                 # TAB 2: LỊCH DẠY (SCHEDULE & TIMETABLE)
            │   ├── teacher_schedule_screen.dart # SCR-05: Lịch biểu lưới tuần / ngày
            │   ├── teacher_session_screen.dart  # SCR-06: Chi tiết buổi học & danh sách điểm danh
            │   ├── teacher_attendance_screen.dart # SCR-08: Giao diện quẹt điểm danh nhanh
            │   ├── teacher_schedule_editor.dart # SCR-07: Biên soạn lịch lặp & tạo ca đơn lẻ
            │   └── teacher_session_row.dart # Widget dòng hiển thị từng ca dạy
            ├── classes/                  # TAB 3: LỚP HỌC (CLASSES MANAGEMENT)
            │   ├── teacher_classes_screen.dart # SCR-10: Danh sách lớp học đang phụ trách
            │   ├── teacher_class_screen.dart   # SCR-12: Chi tiết lớp học với 5 Sub-tabs
            │   ├── teacher_class_editor.dart   # SCR-11: Tạo mới hoặc chỉnh sửa thông tin lớp
            │   ├── tools/                # CÁC CÔNG CỤ CHUYÊN SÂU BÊN TRONG LỚP HỌC
            │   │   ├── assignment_format.dart # Trình bày định dạng đề bài tập
            │   │   ├── teacher_assignment_detail.dart # SCR-14: Chi tiết bài tập & danh sách nộp
            │   │   ├── teacher_assignment_records.dart # Thống kê tiến độ nộp bài của học sinh
            │   │   ├── teacher_assignment_screen.dart # SCR-13A: Danh mục bài tập của lớp
            │   │   ├── teacher_class_tools_screen.dart # Hub chuyển đổi công cụ lớp học
            │   │   ├── teacher_gradebook_screen.dart # SCR-16: Sổ điểm ma trận sư phạm
            │   │   ├── teacher_grade_columns_screen.dart # SCR-16A: Quản lý cột điểm & trọng số
            │   │   ├── tool_form.dart    # Biểu mẫu nhập liệu dùng chung
            │   │   └── widgets/          # Widgets bổ trợ cho Sổ điểm
            │   │       ├── final_grades.dart # Bảng điểm tổng kết học kỳ
            │   │       ├── grade_column_selector.dart # Menu chọn cột điểm
            │   │       ├── grade_save_bar.dart # Thanh lưu điểm dính đáy (Sticky Save Bar)
            │   │       └── grade_student_row.dart # Dòng nhập điểm cho từng học sinh
            │   └── widgets/              # Widgets con của Màn hình Chi tiết Lớp
            │       ├── teacher_class_card.dart
            │       ├── teacher_class_elements.dart
            │       ├── teacher_class_header.dart
            │       ├── teacher_class_overview.dart # Tổng quan lớp học (Sub-tab 1)
            │       ├── teacher_class_schedules_panel.dart # Lịch lặp của lớp (Sub-tab 2)
            │       ├── teacher_class_sessions_panel.dart # Buổi học của lớp (Sub-tab 3)
            │       ├── teacher_class_students_panel.dart # Học viên của lớp (Sub-tab 4)
            │       └── teacher_class_teachers_panel.dart # Đội ngũ giáo viên (Sub-tab 5)
            ├── courses/                  # TAB 4: KHÓA HỌC (COURSE STUDIO)
            │   ├── teacher_courses_screen.dart # SCR-17: Danh sách khóa học cá nhân
            │   ├── course_detail_screen.dart   # SCR-20: Trung tâm điều phối khóa học
            │   ├── course_metadata_editor.dart # SCR-18: Biên soạn thông tin chung & học phí
            │   ├── course_outline_screen.dart  # SCR-21: Biên soạn cấu trúc Chương - Bài
            │   ├── course_status_badge.dart    # Huy hiệu trạng thái duyệt (Draft/Pending/Published)
            │   ├── course_tag_picker.dart      # Bộ chọn thẻ chủ đề phân loại
            │   ├── exercise_editor_screen.dart # SCR-24: Soạn bài tập code & bộ test cases
            │   ├── lesson_contents_screen.dart # SCR-22: Danh mục nội dung trong bài học
            │   ├── quiz_editor_screen.dart     # SCR-23: Soạn bài trắc nghiệm & câu hỏi
            │   ├── content/              # Trình soạn thảo từng khối nội dung
            │   │   ├── article_preview.dart
            │   │   ├── content_resource_picker.dart
            │   │   └── lesson_content_editor.dart
            │   ├── editors/              # Biểu mẫu chi tiết
            │   │   ├── exercise_settings.dart
            │   │   ├── outline_item_editor.dart
            │   │   ├── question_editor.dart
            │   │   ├── quiz_settings.dart
            │   │   └── testcase_editor.dart
            │   └── widgets/              # Thành phần trực quan hiển thị khóa học
            │       ├── course_detail_header.dart
            │       ├── course_enrollments.dart # Danh sách học viên ghi danh khóa học
            │       ├── course_lesson_row.dart
            │       ├── course_management_actions.dart # Nút Nộp duyệt / Rút duyệt / Lưu trữ
            │       ├── course_outline_action.dart
            │       ├── course_review_section.dart # Khối thông báo phản hồi từ Admin
            │       ├── course_section_card.dart
            │       └── teacher_course_card.dart
            ├── earnings/                 # KHÔNG GIAN TÀI CHÍNH (VÍ THU NHẬP)
            │   ├── teacher_earnings_screen.dart # SCR-26: Quản lý số dư & doanh thu cá nhân
            │   ├── teacher_wallet_history.dart  # Lịch sử biến động số dư ví
            │   ├── wallet_format.dart           # Định dạng tiền tệ VND chuẩn
            │   └── widgets/
            │       ├── teacher_wallet_balance_card.dart # Thẻ số dư khả dụng & nút Rút tiền
            │       ├── teacher_wallet_bank_card.dart    # Thẻ tài khoản ngân hàng thụ hưởng
            │       └── teacher_wallet_summary.dart      # Thống kê doanh thu tháng này
            ├── profile/                  # TAB 5: HỒ SƠ & THIẾT LẬP (PROFILE & SETTINGS)
            │   ├── teacher_profile_screen.dart      # SCR-27: Màn hình trung tâm tài khoản
            │   ├── teacher_professional_screen.dart # SCR-28: Hồ sơ năng lực sư phạm
            │   ├── teacher_applicant_screen.dart    # SCR-29: Đơn đăng ký trở thành giáo viên
            │   ├── teacher_reminders_screen.dart    # Thiết lập nhắc lịch dạy tự động
            │   └── teacher_role_switcher.dart       # Bộ chuyển đổi vai trò (Teacher/Student/Parent)
            ├── advanced/                 # CÁC CÔNG CỤ TÍCH HỢP NÂNG CAO
            │   ├── teacher_advanced_screen.dart     # Danh mục công cụ mở rộng
            │   ├── teacher_contact_picker_screen.dart # Chọn liên hệ học viên / giáo viên
            │   ├── teacher_contest_detail_screen.dart # Chi tiết kỳ thi lập trình
            │   ├── teacher_contest_editor.dart      # Soạn đề thi lập trình
            │   ├── teacher_contest_status.dart      # Trạng thái kỳ thi
            │   ├── teacher_contests_screen.dart     # Quản lý kỳ thi của giáo viên
            │   ├── teacher_conversation_screen.dart # Trò chuyện trực tiếp với học sinh/phụ huynh
            │   ├── teacher_discussions_screen.dart  # Thảo luận giải đáp thắc mắc khóa học
            │   ├── teacher_live_room_screen.dart    # Phòng dạy học trực tuyến LiveKit
            │   ├── teacher_live_sessions_screen.dart # Danh sách phòng học trực tuyến
            │   ├── teacher_live_tools.dart          # Công cụ trong phòng live (Bảng trắng, Chat)
            │   ├── teacher_messages_screen.dart     # Hộp thư tin nhắn
            │   └── teacher_video_upload_screen.dart # Tiến trình upload video bài giảng lên MinIO
            └── widgets/                  # Widgets bổ trợ chuyên biệt
                ├── teacher_surface.dart             # Nền canvas hỗ trợ 3-layer surface
                └── teacher_widgets.dart             # Các badge, chip, action sheet chung
```

---

## PHẦN 4: BẢNG DANH MỤC TOÀN BỘ API DÀNH CHO ROLE TEACHER (KÈM DTO & PHÂN QUYỀN)

Dưới đây là danh mục toàn bộ các REST API trên Backend phục vụ trực tiếp cho hoạt động của Giáo viên, được đối chiếu trực tiếp từ tầng Router, Handler, Service và DTO của Backend.

---

### 1. Phân hệ Hồ sơ Giáo viên & Đăng ký Sư phạm (Teacher Profile & Application)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/teacher-profiles/me` | `TeacherProfileHandler.GetMyProfile` | Không có | `TeacherProfileResponseDTO` | `AuthMiddleware`: Người dùng hiện tại lấy hồ sơ năng lực của chính mình. Trả 404 nếu chưa nộp hồ sơ. |
| `POST` | `/api/teacher-profiles` | `TeacherProfileHandler.CreateProfile` | `CreateTeacherProfileDTO` (bio, kinh nghiệm, bằng cấp, lĩnh vực) | `TeacherProfileResponseDTO` | `AuthMiddleware`: Học viên/Người dùng nộp đơn đăng ký làm giáo viên. Khởi tạo trạng thái `approval_status = "pending"`. |
| `PUT` | `/api/teacher-profiles/me` | `TeacherProfileHandler.UpdateMyProfile` | `UpdateTeacherProfileDTO` | `TeacherProfileResponseDTO` | `AuthMiddleware`: Cập nhật thông tin hồ sơ. Nếu hồ sơ bị từ chối (`rejected`), cho phép nộp lại tối đa 3 lần (`MaxTeacherResubmissions = 3`). |
| `GET` | `/api/teachers/:id` | `TeacherHandler.GetTeacherPublicProfile` | Query: `id` (UUID) | `TeacherPublicProfileDTO` | Công khai: Xem thông tin giới thiệu, đánh giá sao, danh sách khóa học đã xuất bản của giáo viên. |

---

### 2. Phân hệ Nơi làm việc & Tổ chức (Workplace & Context)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/me/organizations` | `OrganizationHandler.GetMyOrganizations` | Không có | `[]OrganizationResponseDTO` | `AuthMiddleware`: Trả về danh sách tất cả các Tổ chức/Trung tâm mà giáo viên là thành viên hoặc được gán dạy lớp. |
| `GET` | `/api/organizations/:id` | `OrganizationHandler.GetOrganizationDetail` | Path: `id` (UUID) | `OrganizationDetailDTO` | `AuthMiddleware`: Xem thông tin chi tiết của tổ chức trường học/trung tâm. |

---

### 3. Phân hệ Thời khóa biểu, Lịch lặp & Ca dạy (Timetable & Schedule)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/me/timetable` | `ScheduleHandler.GetMyTimetable` | Query: `organization_id`, `personal_only`, `sessions_from`, `sessions_to` | `TimetableResponseDTO` (chứa mảng `TimetableEntryDTO`) | `AuthMiddleware`: Trả về thời khóa biểu tổng hợp. Có hỗ trợ lọc theo từng tổ chức (`organization_id`) hoặc chỉ lấy lớp cá nhân (`personal_only = true`). |
| `GET` | `/api/classes/:id/schedules` | `ScheduleHandler.GetClassSchedules` | Path: `id` (Class UUID) | `[]ClassScheduleResponseDTO` | Yêu cầu là thành viên của lớp (Giáo viên, Học viên, hoặc Admin). |
| `POST` | `/api/classes/:id/schedules` | `ScheduleHandler.CreateSchedule` | `CreateClassScheduleDTO` (day_of_week, start_time, end_time, room, effective_from) | `ClassScheduleResponseDTO` | `ensureClassManageWrite`: Chỉ Giáo viên của lớp (`teacher_classes`), Chủ lớp hoặc Admin mới được tạo lịch lặp tuần. |
| `PUT` | `/api/classes/:id/schedules/:scheduleId` | `ScheduleHandler.UpdateSchedule` | `UpdateClassScheduleDTO` | `ClassScheduleResponseDTO` | `ensureClassManageWrite`: Chỉ Giáo viên của lớp hoặc Admin được cập nhật cấu hình lịch lặp. |
| `DELETE` | `/api/classes/:id/schedules/:scheduleId` | `ScheduleHandler.DeleteSchedule` | Path: `id`, `scheduleId` | `{"message": "Schedule deleted"}` | `ensureClassManageWrite`: Xóa lịch lặp tuần của lớp học. |
| `GET` | `/api/classes/:id/sessions` | `ScheduleHandler.GetClassSessions` | Path: `id`, Query: `from_date`, `to_date`, `status` | `ClassSessionListDTO` | Xem danh sách các buổi học cụ thể của lớp học. |
| `POST` | `/api/classes/:id/sessions` | `ScheduleHandler.CreateSession` | `CreateClassSessionDTO` (date, start_time, end_time, topic, notes) | `ClassSessionResponseDTO` | `ensureClassManageWrite`: Tạo một ca dạy đột xuất / buổi học đơn lẻ ngoài lịch lặp. |
| `POST` | `/api/classes/:id/sessions/generate` | `ScheduleHandler.GenerateSessions` | `GenerateSessionsDTO` (start_date, end_date) | `[]ClassSessionResponseDTO` | `ensureClassManageWrite`: Tự động sinh hàng loạt buổi học dựa trên các khung lịch lặp tuần đã thiết lập. |
| `GET` | `/api/sessions/:sessionId` | `ScheduleHandler.GetSessionDetail` | Path: `sessionId` (UUID) | `ClassSessionResponseDTO` (kèm `livestream_session_id`) | Yêu cầu là thành viên lớp hoặc Admin. Trả về thông tin chi tiết ca dạy và ID phòng livestream nếu có. |
| `PUT` | `/api/sessions/:sessionId` | `ScheduleHandler.UpdateSession` | `UpdateClassSessionDTO` (date, start_time, end_time, topic, notes, status, cancel_reason) | `ClassSessionResponseDTO` | `ensureClassManageWrite`: Cập nhật ca học, đổi giờ dạy hoặc báo hủy ca kèm lý do hủy. |
| `DELETE` | `/api/sessions/:sessionId` | `ScheduleHandler.DeleteSession` | Path: `sessionId` (UUID) | `{"message": "Session deleted"}` | `ensureClassManageWrite`: Xóa bỏ một ca dạy chưa diễn ra. |

---

### 4. Phân hệ Điểm danh Buổi học (Attendance)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/sessions/:sessionId/attendances` | `ScheduleHandler.GetSessionAttendances` | Path: `sessionId` (UUID) | `[]SessionAttendanceResponseDTO` | Xem danh sách điểm danh và trạng thái chuyên cần của từng học viên trong ca học. |
| `POST` | `/api/sessions/:sessionId/attendances/bulk` | `ScheduleHandler.BulkMarkAttendance` | `BulkMarkAttendanceDTO` (mảng `{student_id, status, note}`) | `{"message": "Attendances updated"}` | `requireSessionManage` -> `ensureClassManageWrite`: **Cả Giáo viên chính lẫn Trợ giảng (Assistant Teacher)** đều có quyền gọi để lưu điểm danh hàng loạt. |
| `PUT` | `/api/sessions/:sessionId/attendances/:attendanceId` | `ScheduleHandler.UpdateAttendance` | `UpdateSessionAttendanceDTO` (status: present/absent/late/excused, late_minutes, note) | `SessionAttendanceResponseDTO` | `ensureClassManageWrite`: Điều chỉnh trạng thái điểm danh cho một học viên cụ thể. |

---

### 5. Phân hệ Quản lý Lớp học (Classes Management & Member Assignment)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/classes` | `ClassHandler.GetClasses` | Query: `organization_id`, `status`, `page`, `page_size` | `ClassListResponseDTO` | Trả về danh sách lớp học mà giáo viên đang phụ trách. |
| `POST` | `/api/classes` | `ClassHandler.CreateClass` | `CreateClassDTO` (name, description, course_id, organization_id, max_students, start_date, end_date) | `ClassResponseDTO` | `AuthMiddleware`: Giáo viên tạo lớp cá nhân (nếu `organization_id` rỗng) hoặc tạo lớp trong tổ chức (yêu cầu quyền quản lý trong tổ chức). |
| `GET` | `/api/classes/:id` | `ClassHandler.GetClassDetail` | Path: `id` (UUID) | `ClassResponseDTO` (chứa cờ `can_manage`, `can_assign_teachers`, `is_ended`) | Trả về thông tin lớp học. Cờ `can_manage` được tính toán trực tiếp tại service để UI bật/tắt các nút chức năng. |
| `PUT` | `/api/classes/:id` | `ClassHandler.UpdateClass` | `UpdateClassDTO` | `ClassResponseDTO` | `ensureClassManageWrite`: Giáo viên của lớp hoặc Admin sửa tên, mô tả, sĩ số tối đa, thời gian lớp. |
| `DELETE` | `/api/classes/:id` | `ClassHandler.DeleteClass` | Path: `id` (UUID) | `{"message": "Class deleted"}` | `ensureClassOwner`: Chỉ Người tạo lớp, Chủ khóa học liên kết, hoặc Admin mới có quyền xóa/lưu trữ lớp. |
| `GET` | `/api/classes/:id/teachers` | `ClassHandler.GetClassTeachers` | Path: `id` (UUID) | `TeacherClassListResponseDTO` | Xem danh sách đội ngũ giáo viên phụ trách lớp (kèm vai trò `primary` hoặc `assistant`). |
| `POST` | `/api/classes/:id/teachers` | `ClassHandler.AssignTeachers` | `AssignTeachersDTO` (mảng `{teacher_id, role: primary/assistant}`) | `{"message": "Teachers assigned"}` | `ensureClassOwner`: **Chỉ Class Owner hoặc Admin mới có quyền phân công giáo viên vào lớp.** |
| `DELETE` | `/api/classes/:id/teachers/:teacherId` | `ClassHandler.RemoveTeacher` | Path: `id`, `teacherId` | `{"message": "Teacher removed"}` | `ensureClassOwner`: Gỡ bỏ giáo viên ra khỏi lớp học. |
| `GET` | `/api/classes/:id/students` | `ClassHandler.GetClassStudents` | Path: `id`, Query: `page`, `page_size` | `StudentClassListResponseDTO` | Thành viên lớp hoặc Giáo viên xem danh sách học sinh (không chứa số điện thoại để bảo mật PII). |
| `POST` | `/api/classes/:id/students` | `ClassHandler.EnrollStudent` | `EnrollStudentDTO` (student_id) | `StudentClassResponseDTO` | `ensureClassManageWrite`: Giáo viên thêm học sinh vào lớp học. Kiểm tra giới hạn `max_students`. |
| `DELETE` | `/api/classes/:id/students/:studentId` | `ClassHandler.RemoveStudent` | Path: `id`, `studentId` | `{"message": "Student removed"}` | `ensureClassManageWrite`: Giáo viên xóa học sinh ra khỏi lớp học. |
| `GET` | `/api/classes/:id/assignable-teachers` | `ClassHandler.GetAssignableTeachers` | Query: `query` | `[]AssignableTeacherDTO` | Danh sách giáo viên có thể gán vào lớp (hỗ trợ ô tìm kiếm). |
| `GET` | `/api/classes/:id/enrollable-students` | `ClassHandler.GetEnrollableStudents` | Query: `query` | `[]EnrollableStudentDTO` | Danh sách học viên có thể ghi danh vào lớp. |

---

### 6. Phân hệ Sổ điểm Sư phạm (Gradebook & Grading)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/classes/:id/grade-columns` | `GradeHandler.GetGradeColumns` | Path: `id` (Class UUID) | `[]GradeColumnResponseDTO` | Xem cấu hình các cột điểm thành phần và hệ số trọng số (%) của lớp. |
| `POST` | `/api/classes/:id/grade-columns` | `GradeHandler.CreateGradeColumn` | `CreateGradeColumnDTO` (name, code, weight, max_score, column_type) | `GradeColumnResponseDTO` | `ensureClassManageWrite`: Giáo viên thêm cột điểm mới (ví dụ: Chuyên cần 10%, Giữa kỳ 30%, Cuối kỳ 60%). |
| `PUT` | `/api/classes/:id/grade-columns/:columnId` | `GradeHandler.UpdateGradeColumn` | `UpdateGradeColumnDTO` | `GradeColumnResponseDTO` | `ensureClassManageWrite`: Cập nhật tên cột điểm, hệ số hoặc điểm tối đa. |
| `DELETE` | `/api/classes/:id/grade-columns/:columnId` | `GradeHandler.DeleteGradeColumn` | Path: `id`, `columnId` | `{"message": "Grade column deleted"}` | `ensureClassManageWrite`: Xóa bỏ cột điểm và toàn bộ điểm thành phần tương ứng. |
| `GET` | `/api/classes/:id/grades` | `GradeHandler.GetClassGrades` | Path: `id`, Query: `student_id`, `column_id` | `ClassGradesMatrixDTO` | Xem ma trận sổ điểm của toàn bộ học viên trong lớp theo từng cột điểm. |
| `POST` | `/api/classes/:id/grades/bulk` | `GradeHandler.BulkCreateGrades` | `BulkCreateGradesDTO` (mảng `{student_id, column_id, score, comment}`) | `{"message": "Grades saved successfully"}` | `ensureClassManageWrite`: **Cả Giáo viên chính lẫn Trợ giảng (Assistant Teacher)** đều có quyền nhập điểm hàng loạt. Lớp đã `archived` sẽ bị từ chối ghi điểm. |
| `GET` | `/api/classes/:id/final-grades` | `GradeHandler.GetFinalGrades` | Path: `id` (Class UUID) | `[]FinalGradeResponseDTO` | Xem danh sách điểm tổng kết học kỳ và xếp loại học lực của học viên. |
| `POST` | `/api/classes/:id/final-grades/calculate` | `GradeHandler.CalculateFinalGrades` | Không có | `[]FinalGradeResponseDTO` | `ensureClassManageWrite`: Hệ thống tự động tính điểm tổng kết dựa trên công thức trọng số của các cột điểm thành phần. |
| `GET` | `/api/classes/:id/grade-stats` | `GradeHandler.GetGradeStats` | Path: `id` (Class UUID) | `GradeStatisticsDTO` | Thống kê phổ điểm: Điểm trung bình lớp, điểm cao nhất, điểm thấp nhất, tỷ lệ đạt/trượt. |
| `GET` | `/api/classes/:id/grades/export` | `GradeHandler.ExportGrades` | Path: `id`, Query: `format=csv/xlsx` | File Stream (CSV / Excel) | Xuất dữ liệu sổ điểm hoàn chỉnh phục vụ lưu trữ học vụ. |

---

### 7. Phân hệ Khóa học Số & Biên tập Nội dung (Course Studio & Outline)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/courses` | `CourseHandler.GetCourses` | Query: `instructor_id`, `status`, `page`, `page_size` | `CourseListResponseDTO` | Lấy danh sách khóa học. Giáo viên xem các khóa do chính mình biên soạn (`instructor_id = me`). |
| `POST` | `/api/courses` | `CourseHandler.CreateCourse` | `CreateCourseDTO` (title, description, price, level, language, category_id) | `CourseResponseDTO` | `AuthMiddleware`: Giảng viên tạo khóa học mới. Khởi tạo mặc định ở trạng thái `draft`. |
| `GET` | `/api/courses/:id` | `CourseHandler.GetCourseDetail` | Path: `id` (Course UUID) | `CourseDetailResponseDTO` | Xem chi tiết thông tin khóa học, cây chương trình học và danh mục bài học. |
| `PUT` | `/api/courses/:id` | `CourseHandler.UpdateCourse` | `UpdateCourseDTO` | `CourseResponseDTO` | Chủ khóa học hoặc Admin. Kiểm tra `ValidateManualCourseStatusChange`: Chỉ cho phép tự đổi `published` -> `archived` hoặc `archived` -> `draft`. Đang ở `pending_review` bị khóa sửa 409. |
| `DELETE` | `/api/courses/:id` | `CourseHandler.DeleteCourse` | Path: `id` (UUID) | `{"message": "Course deleted"}` | Chủ sở hữu khóa học. Nếu khóa học đã có học viên ghi danh (`ErrCourseHasEnrollments`), từ chối xóa (yêu cầu chuyển sang `archived`). |
| `POST` | `/api/courses/:id/submit-review` | `ApprovalHandler.SubmitCourseForReview` | Không có | `CourseResponseDTO` | Chủ sở hữu khóa học: Nộp khóa học lên hàng duyệt của Admin. Kiểm tra đầy đủ ảnh bìa, mô tả, giá và ít nhất 1 bài học có nội dung. Chuyển `draft`/`rejected` -> `pending_review`. |
| `POST` | `/api/courses/:id/withdraw-review` | `ApprovalHandler.WithdrawCourseReview` | Không có | `CourseResponseDTO` | Chủ sở hữu khóa học: Rút lại yêu cầu duyệt để mở khóa tiếp tục chỉnh sửa nội dung. Chuyển `pending_review` -> `draft`. |
| `GET` | `/api/courses/:courseId/enrollments` | `EnrollmentHandler.GetCourseEnrollments` | Path: `courseId`, Query: `page`, `page_size` | `CourseEnrollmentListDTO` | **Chỉ Chủ sở hữu khóa học (`course.InstructorID == actorID`) hoặc Admin.** Trả về danh sách học viên đã mua/ghi danh kèm tiến độ % hoàn thành. |
| `GET` | `/api/courses/:id/sections` | `SectionHandler.GetSections` | Path: `id` (Course UUID) | `[]SectionResponseDTO` | Xem danh sách các Chương trong khóa học. |
| `POST` | `/api/courses/:id/sections` | `SectionHandler.CreateSection` | `CreateSectionDTO` (title, order_index) | `SectionResponseDTO` | Chủ khóa học: Tạo chương mới trong khóa học. |
| `PUT` | `/api/sections/:sectionId` | `SectionHandler.UpdateSection` | `UpdateSectionDTO` | `SectionResponseDTO` | Chủ khóa học: Cập nhật tên chương hoặc thứ tự sắp xếp. |
| `DELETE` | `/api/sections/:sectionId` | `SectionHandler.DeleteSection` | Path: `sectionId` | `{"message": "Section deleted"}` | Chủ khóa học: Xóa chương (xóa theo tầng CASCADE toàn bộ bài học bên trong). |
| `POST` | `/api/sections/:sectionId/lessons` | `LessonHandler.CreateLesson` | `CreateLessonDTO` (title, order_index, is_free_preview) | `LessonResponseDTO` | Chủ khóa học: Tạo bài học mới trong chương. |
| `GET` | `/api/lessons/:lessonId` | `LessonHandler.GetLessonDetail` | Path: `lessonId` | `LessonDetailResponseDTO` | Xem chi tiết bài học và danh mục các khối nội dung bên trong. |
| `PUT` | `/api/lessons/:lessonId` | `LessonHandler.UpdateLesson` | `UpdateLessonDTO` | `LessonResponseDTO` | Chủ khóa học: Sửa tiêu đề, cấu hình học thử miễn phí. |
| `DELETE` | `/api/lessons/:lessonId` | `LessonHandler.DeleteLesson` | Path: `lessonId` | `{"message": "Lesson deleted"}` | Chủ khóa học: Xóa bài học. |
| `GET` | `/api/lessons/:lessonId/contents` | `LessonContentHandler.GetContents` | Path: `lessonId` | `[]LessonContentResponseDTO` | Xem các khối nội dung (Video, Text, Quiz, Exercise) trong bài học. |
| `POST` | `/api/lessons/:lessonId/contents` | `LessonContentHandler.CreateContent` | `CreateLessonContentDTO` (type: video/article/quiz/exercise, title, order_index, payload) | `LessonContentResponseDTO` | Chủ khóa học: Thêm một khối nội dung vào bài học. |
| `PUT` | `/api/lessons/:lessonId/contents/:contentId` | `LessonContentHandler.UpdateContent` | `UpdateLessonContentDTO` | `LessonContentResponseDTO` | Chủ khóa học: Chỉnh sửa khối nội dung bài học. |
| `DELETE` | `/api/lessons/:lessonId/contents/:contentId` | `LessonContentHandler.DeleteContent` | Path: `lessonId`, `contentId` | `{"message": "Content deleted"}` | Chủ khóa học: Xóa bỏ khối nội dung. |

---

### 8. Phân hệ Tải Video Lên Lưu Trữ (Video Upload & Storage)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/upload/video/init` | `VideoUploadHandler.InitUpload` | `InitVideoUploadDTO` (file_name, file_size, content_type) | `InitVideoUploadResponseDTO` (upload_id, presigned_urls, key) | `AuthMiddleware`: Khởi tạo phiên upload video phân đoạn lên MinIO/S3. Chỉ người upload sở hữu object key này. |
| `POST` | `/api/upload/video/complete` | `VideoUploadHandler.CompleteUpload` | `CompleteVideoUploadDTO` (upload_id, key, parts) | `CompleteVideoUploadResponseDTO` (video_url, duration) | `AuthMiddleware`: Hoàn tất ghép các phần video, kích hoạt tác vụ nền nén HLS m3u8 và lấy thời lượng video. |

---

### 9. Phân hệ Bài tập, Bài nộp & Chấm tự động (Assignments & Submissions)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/assignments` | `AssignmentHandler.GetAssignments` | Query: `class_id`, `session_id`, `status` | `[]AssignmentResponseDTO` | Xem danh sách bài tập được giao cho lớp hoặc theo ca học. |
| `POST` | `/api/assignments` | `AssignmentHandler.CreateAssignment` | `CreateAssignmentDTO` (class_id, session_id (tuỳ chọn), title, description, starter_code, test_cases, deadline) | `AssignmentResponseDTO` | `ensureClassManageWrite`: Giáo viên của lớp tạo bài tập code. Trường `session_id` là tuỳ chọn (không bắt buộc). |
| `GET` | `/api/assignments/:id` | `AssignmentHandler.GetAssignmentDetail` | Path: `id` (Assignment UUID) | `AssignmentDetailDTO` | Xem chi tiết yêu cầu bài tập, mã nguồn mẫu và bộ test cases. |
| `PUT` | `/api/assignments/:id` | `AssignmentHandler.UpdateAssignment` | `UpdateAssignmentDTO` | `AssignmentResponseDTO` | `CanManage` (Người tạo, Giáo viên của lớp, Host live, Admin): Sửa đổi yêu cầu đề bài tập. |
| `DELETE` | `/api/assignments/:id` | `AssignmentHandler.DeleteAssignment` | Path: `id` | `{"message": "Assignment deleted"}` | `CanManage`: Xóa bỏ bài tập. |
| `POST` | `/api/assignments/:id/publish` | `AssignmentHandler.PublishAssignment` | `PublishAssignmentDTO` (session_id nếu phát trực tiếp) | `AssignmentResponseDTO` | `CanManage`: Phát hành bài tập cho học sinh bắt đầu làm bài. |
| `POST` | `/api/assignments/:id/unpublish` | `AssignmentHandler.UnpublishAssignment` | Không có | `AssignmentResponseDTO` | `CanManage`: Thu hồi bài tập về trạng thái đóng. |
| `GET` | `/api/assignments/:id/submissions` | `SubmissionHandler.GetSubmissions` | Path: `id`, Query: `page`, `page_size`, `status` | `SubmissionListDTO` | Giáo viên của lớp xem toàn bộ bài nộp code của học sinh (đã được chấm tự động bởi runner). |
| `GET` | `/api/submissions/:id` | `SubmissionHandler.GetSubmissionDetail` | Path: `id` (Submission UUID) | `SubmissionDetailDTO` | Xem chi tiết một bài nộp: Mã code học sinh đã viết, trạng thái test case, console log output, thời gian chạy và bộ nhớ sử dụng. *(Không có endpoint chấm tay hay sửa điểm)*. |

---

### 10. Phân hệ Đề kiểm tra & Bài tập Thực hành (Quizzes & Coding Exercises)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/quizzes` | `QuizHandler.GetQuizzes` | Query: `course_id`, `lesson_id` | `[]QuizResponseDTO` | Lấy danh sách đề trắc nghiệm trong khóa học/bài học. |
| `POST` | `/api/quizzes` | `QuizHandler.CreateQuiz` | `CreateQuizDTO` (title, description, passing_score, time_limit_mins) | `QuizResponseDTO` | Chủ khóa học: Tạo đề kiểm tra trắc nghiệm mới. Khóa đang chờ duyệt trả `409 Conflict`. |
| `GET` | `/api/quizzes/:id` | `QuizHandler.GetQuizDetail` | Path: `id` (Quiz UUID) | `QuizDetailResponseDTO` (chứa danh sách câu hỏi) | Xem cấu trúc đề trắc nghiệm và các lựa chọn đáp án. |
| `PUT` | `/api/quizzes/:id` | `QuizHandler.UpdateQuiz` | `UpdateQuizDTO` | `QuizResponseDTO` | Chủ khóa học: Cập nhật thông số đề kiểm tra. |
| `DELETE` | `/api/quizzes/:id` | `QuizHandler.DeleteQuiz` | Path: `id` | `{"message": "Quiz deleted"}` | Chủ khóa học: Xóa đề trắc nghiệm. |
| `POST` | `/api/quizzes/:id/questions` | `QuizHandler.AddQuestion` | `CreateQuizQuestionDTO` (question_text, question_type, options, correct_answers, explanation) | `QuizQuestionResponseDTO` | Chủ khóa học: Thêm câu hỏi trắc nghiệm mới vào đề. |
| `PUT` | `/api/questions/:questionId` | `QuizHandler.UpdateQuestion` | `UpdateQuizQuestionDTO` | `QuizQuestionResponseDTO` | Chủ khóa học: Sửa nội dung câu hỏi hoặc đáp án đúng. |
| `DELETE` | `/api/questions/:questionId` | `QuizHandler.DeleteQuestion` | Path: `questionId` | `{"message": "Question deleted"}` | Chủ khóa học: Xóa câu hỏi khỏi đề. |
| `POST` | `/api/exercises` | `ExerciseHandler.CreateExercise` | `CreateExerciseDTO` (title, prompt, language, starter_code, solution_code, test_cases) | `ExerciseResponseDTO` | Chủ khóa học: Soạn bài tập lập trình thực hành. |
| `GET` | `/api/exercises/:id` | `ExerciseHandler.GetExerciseDetail` | Path: `id` | `ExerciseDetailDTO` | Xem chi tiết bài tập thực hành kèm bộ test cases kiểm thử. |
| `PUT` | `/api/exercises/:id` | `ExerciseHandler.UpdateExercise` | `UpdateExerciseDTO` | `ExerciseResponseDTO` | Chủ khóa học: Cập nhật bài tập lập trình. |
| `DELETE` | `/api/exercises/:id` | `ExerciseHandler.DeleteExercise` | Path: `id` | `{"message": "Exercise deleted"}` | Chủ khóa học: Xóa bài tập lập trình. |

---

### 11. Phân hệ Ví Thu nhập & Yêu cầu Rút tiền Giảng viên (Earnings & Payouts)

> *Ghi chú quan trọng:* Phân hệ này dành riêng cho **Giảng viên độc lập** bán khóa học video trực tuyến theo doanh thu chia sẻ. Không áp dụng cho giáo viên hưởng lương cơ hữu của Tổ chức/Trường học.

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/wallet/teacher/revenue` | `WalletHandler.GetTeacherRevenueSummary` | Query: `month`, `year` | `TeacherRevenueSummaryDTO` | `AuthMiddleware`: Xem tổng doanh thu bán khóa học, số dư khả dụng, số dư đang xử lý rút tiền, và tổng lũy kế đã rút. |
| `GET` | `/api/wallet/teacher/payouts` | `WalletHandler.GetPayoutHistory` | Query: `status`, `page`, `page_size` | `PayoutListResponseDTO` | `AuthMiddleware`: Xem lịch sử các yêu cầu rút tiền về tài khoản ngân hàng (`pending`, `approved`, `completed`, `rejected`, `cancelled`). |
| `POST` | `/api/wallet/teacher/payouts` | `WalletHandler.RequestPayout` | `RequestPayoutDTO` (amount, bank_name, bank_account_number, bank_account_name, notes) | `PayoutResponseDTO` | `AuthMiddleware`: Giảng viên tạo lệnh rút tiền. Kiểm tra: Số tiền rút tối thiểu, số dư khả dụng đủ lớn, và tại một thời điểm chỉ được phép có **tối đa 1 yêu cầu** đang xử lý (`PayoutOpenStatuses: pending, approved`). |
| `POST` | `/api/wallet/teacher/payouts/:id/cancel` | `WalletHandler.CancelPayout` | Path: `id` (Payout UUID) | `{"message": "Payout cancelled"}` | `AuthMiddleware`: Giảng viên chủ động hủy lệnh rút tiền khi trạng thái còn là `pending`. Hệ thống tự động giải phóng và hoàn trả lại số dư khả dụng ngay lập tức. |
| `GET` | `/api/wallet/teacher/bank-account` | `WalletHandler.GetSavedBankAccount` | Không có | `TeacherBankAccountDTO` | Lấy thông tin tài khoản ngân hàng mặc định đã lưu của giảng viên. |
| `POST` | `/api/wallet/teacher/bank-account` | `WalletHandler.SaveBankAccount` | `SaveBankAccountDTO` (bank_name, account_number, account_holder) | `TeacherBankAccountDTO` | Lưu hoặc cập nhật thông tin tài khoản ngân hàng nhận tiền. |

---

### 12. Phân hệ Phòng học Trực tuyến & Nhắc Lịch (Live Sessions & Reminders)

| Method | Endpoint | Handler & Service | Request DTO | Response DTO | Luật Phân quyền / Kiểm tra Quyền |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `POST` | `/api/livestream/sessions` | `LivestreamHandler.CreateSession` | `CreateLivestreamSessionDTO` (title, scheduled_start, course_id, class_id) | `LivestreamSessionResponseDTO` | `AuthMiddleware`: Khởi tạo phiên phòng học trực tuyến LiveKit. |
| `GET` | `/api/livestream/sessions/:id` | `LivestreamHandler.GetSessionDetail` | Path: `id` | `LivestreamSessionResponseDTO` | Xem thông tin trạng thái phòng live (`idle`, `live`, `ended`). |
| `POST` | `/api/livestream/sessions/:id/start` | `LivestreamHandler.StartSession` | Path: `id` | `{"status": "live"}` | Host/Giáo viên bắt đầu phát phòng học trực tuyến. |
| `POST` | `/api/livestream/sessions/:id/end` | `LivestreamHandler.EndSession` | Path: `id` | `{"status": "ended"}` | Host/Giáo viên kết thúc buổi dạy trực tuyến. |
| `POST` | `/api/livestream/sessions/:id/token` | `LivestreamHandler.GetLiveKitToken` | Path: `id` | `{"token": "JWT_LIVEKIT"}` | Lấy access token LiveKit để kết nối camera, micro và chia sẻ màn hình (giáo viên nhận quyền Publisher/Host). |
| `GET` | `/api/reminder-settings` | `ScheduleHandler.GetReminderSettings` | Không có | `[]ReminderSettingResponseDTO` | Xem cấu hình thông báo nhắc lịch dạy trước (ví dụ: nhắc trước 15 phút, 1 giờ qua Push/Email). |
| `PUT` | `/api/reminder-settings` | `ScheduleHandler.UpdateReminderSettings` | `UpdateReminderSettingDTO` | `ReminderSettingResponseDTO` | Cập nhật thời gian nhắc lịch dạy tự động. |

---

## KẾT LUẬN & ĐỐI SOÁT VỚI KẾ HOẠCH PHÁT TRIỂN UI MOBILE

1. **Sự đồng bộ hoàn toàn giữa Backend & Mobile:**
   - Phân hệ Giáo viên trên Mobile (nhánh `Thu/UI_Teacher`) đã bám sát 100% các hợp đồng API (API Contracts) và quy tắc bảo mật của Backend.
   - Việc tách bạch 5 Tabs đáy (`Home`, `Schedule`, `Classes`, `Courses`, `Profile`) cùng 2 phân hệ độc lập: **Lớp học (Classes - Dạy học tương tác)** và **Khóa học (Courses - Nội dung số VOD)** phản ánh chuẩn xác kiến trúc dữ liệu của Backend.

2. **Các lưu ý cốt lõi cho giai đoạn lập trình UI Mobile tiếp theo:**
   - **Xác thực quyền hạn trên màn hình:** Luôn dựa vào cờ `can_manage` và `can_assign_teachers` được Backend trả về trong `GET /classes/:id` để ẩn/hiện các nút hành động, không tự ý đoán quyền từ tên vai trò.
   - **Điểm danh & Nhập điểm:** Cả Giáo viên chính lẫn Trợ giảng đều có toàn quyền thực hiện tính năng lưu điểm danh hàng loạt (`bulk attendances`) và lưu sổ điểm (`bulk grades`). Màn hình UI cho phép trợ giảng thao tác đầy đủ hai chức năng này.
   - **Chấm bài tập code:** Bài tập code chỉ hỗ trợ học sinh nộp và hệ thống tự động chấm (Judge0). UI của giáo viên chỉ cần màn hình hiển thị danh sách bài nộp, trạng thái pass/fail, test cases và logs chi tiết; không cần thiết kế modal nhập điểm hay ô nhận xét cho bài nộp.
   - **Bảo mật dữ liệu cá nhân:** Danh sách học viên lớp học không có số điện thoại phụ huynh (`parent_phone`). Các tính năng liên lạc cần điều hướng qua phân hệ Chat nội bộ (`conversations`) hoặc Thông báo hệ thống.
   - **Quản lý thu nhập:** Đặt rõ ranh giới: Màn hình Ví thu nhập (`teacher_earnings_screen.dart`) chỉ phản ánh doanh thu từ việc bán Khóa học số cá nhân của giảng viên, không liên quan đến tiền lương của các lớp thuộc Tổ chức trường học.
