# Role Teacher: backend hiện có và phạm vi giao diện mobile

Ngày khảo sát: 14/10/2026.
Backend: `/Users/duongwthuj/develop/backend`, nhánh `main`, commit `97c29a8`.
Mobile: `/Users/duongwthuj/develop/mobile/40Study`, nhánh `UI/Refactor`.

Đây là đối chiếu mã nguồn local: router → handler → service → repository/DTO của các luồng liên quan Teacher. Chưa chạy backend, migration hoặc kiểm thử API trên dữ liệu thật; có route và logic chưa đồng nghĩa mọi môi trường triển khai đã cấu hình đủ. Không thay đổi backend hoặc code ứng dụng trong lượt khảo sát này.

## 1. Kết luận để bắt đầu

Backend đã có các luồng chính cho role Giáo viên: hồ sơ và xét duyệt, quản lý khóa học/giáo trình, lớp học/học viên, lịch/buổi học/điểm danh, quiz, bài tập lập trình, bảng điểm, livestream, trao đổi và thu nhập/rút tiền. Có thêm công cụ tổ chức cuộc thi.

Mobile chưa có `features/teacher` hoặc `TeacherShell`. `MainScreen` chỉ xử lý Student và Parent; Teacher hiện đi vào nhánh mặc định Student. Đây là điểm tích hợp phải xử lý trước khi mở các màn Teacher.

Phân quyền phải theo từng tài nguyên, không suy tất cả quyền từ chuỗi TEACHER. Giáo viên sở hữu khóa học, giáo viên được phân công lớp và chủ lớp có phạm vi thao tác khác nhau.

## 2. Hồ sơ và quyền

### 2.1. Người đăng ký dạy

- Backend cho tự đăng ký role `TEACHER_APPLICANT`; không cho tự cấp role `TEACHER`.
- Tạo hồ sơ năng lực qua `POST /api/teacher-profiles`.
- Xem hồ sơ và trạng thái qua `GET /api/teacher-profiles/me`.
- Cập nhật hồ sơ bằng `PUT /api/teacher-profiles/:id`.
- Trạng thái hồ sơ: `pending`, `approved`, `rejected`.
- Khi từ chối có lý do; có `resubmission_count`, `max_resubmissions`, `can_resubmit` để dựng UI nộp lại.
- Nộp lại qua `POST /api/teacher-profiles/me/resubmit`; tối đa 3 lần nộp lại, không tính lần đầu.
- Admin duyệt mới cấp role Teacher. Có cơ chế báo thay đổi role/token; ứng dụng cần tải lại hồ sơ/quyền, không giữ trạng thái Applicant cũ.
- Tạo hồ sơ cho người đã có Teacher được xử lý như hồ sơ approved; không ép giáo viên cũ quay lại hàng chờ.
- Applicant cần màn riêng: bổ sung hồ sơ / đang chờ / bị từ chối / hết lượt nộp lại. Không cho truy cập trình tạo khóa học chỉ vì tên role có chữ TEACHER.

Nguồn: [auth_service.go](/Users/duongwthuj/develop/backend/internal/service/auth_service.go:1585), [teacher_application_service.go](/Users/duongwthuj/develop/backend/internal/service/teacher_application_service.go:129), [teacher_profile_service.go](/Users/duongwthuj/develop/backend/internal/service/teacher_profile_service.go:45), [approval_router.go](/Users/duongwthuj/develop/backend/internal/router/approval_router.go:65).

### 2.2. Quyền theo khóa/lớp

- Teacher có các quyền hệ thống như `COURSES_CREATE`, `COURSES_UPDATE_OWN`, `COURSES_DELETE_OWN`, `LESSONS_MANAGE`, `CONTESTS_MANAGE_OWN` trong dữ liệu seed.
- Handler/service còn kiểm chủ khóa, quan hệ với lớp và phạm vi tổ chức. File seed chỉ là một phần của luật quyền.
- Giáo viên lớp, người tạo lớp hoặc instructor của khóa có thể có quyền quản lý lớp; gán/gỡ giáo viên đòi quyền chủ lớp hoặc quản trị phù hợp.
- Chi tiết lớp có `can_manage` và `can_assign_teachers`; dùng trực tiếp, vắng coi là false. Các cờ này chưa thay thế kiểm trạng thái archived.
- Lớp `archived` chỉ đọc; phải mở lại trước khi ghi danh, sửa lịch, điểm danh, sửa bài tập hoặc chấm điểm.
- Giáo viên không duyệt khóa học, duyệt ứng viên, duyệt cuộc thi hoặc duyệt rút tiền của mình; đó là thao tác Admin.

Nguồn: [class_access.go](/Users/duongwthuj/develop/backend/internal/service/class_access.go:48), [class_service.go](/Users/duongwthuj/develop/backend/internal/service/class_service.go:337), [classDTO.go](/Users/duongwthuj/develop/backend/internal/dto/classDTO.go:46).

## 3. Tính năng và API cho từng nhóm màn hình

Tất cả đường dẫn dưới đây có tiền tố `/api`. Đây là các endpoint chính để dựng UI; các router nguồn còn chứa thao tác phụ và endpoint cho Student/Admin.

### 3.1. Khóa học và trình soạn giáo trình

- Danh sách khóa của chính mình, lọc trạng thái/từ khóa và phân trang: `GET /courses/mine?status=&keyword=&page=&page_size=`.
- Không dùng `GET /courses?mine=true`: route công khai chỉ trả published, không phải danh sách quản lý của Teacher.
- Tạo/chi tiết/sửa/xóa: `POST /courses`, `GET|PUT|DELETE /courses/:id` theo quyền chủ khóa.
- Chương: `/courses/:course_id/sections`; bài: `/sections/:section_id/lessons`; nội dung: `/lessons/:lesson_id/contents`.
- Có tạo/sửa/xóa và sắp xếp chương, bài, nội dung bằng các route `/reorder`.
- Loại nội dung thực tế: `video`, `livestream`, `exercise`, `article`, `quiz`. Không có loại nội dung `document` độc lập trong enum hiện tại.
- Thông tin khóa gồm tên, mô tả, ảnh/video giới thiệu, cấp độ, ngôn ngữ, danh mục/tag, giá/giảm giá, yêu cầu, mục tiêu, đối tượng học.
- Có cấu hình học tuần tự và ngưỡng phần trăm video để hoàn thành bài (`sequential`, `min_video_pct`).
- Giá giảm phải dương và nhỏ hơn giá gốc; muốn bỏ giảm giá gửi null.

Luồng duyệt:

```text
draft / rejected → gửi duyệt → pending_review → Admin duyệt → published
                                           → Admin từ chối → rejected
pending_review → rút yêu cầu → draft
```

- `POST /courses/:id/submit-review`; `POST /courses/:id/withdraw-review`.
- Khi pending_review khóa chỉnh sửa thông tin và nội dung; UI cần hiện nút rút yêu cầu trước khi sửa.
- Nộp duyệt cần ít nhất một bài, mọi bài phải có nội dung hoặc quiz gắn vào bài. Backend có lỗi kèm các bài còn rỗng.
- Teacher không tự đổi sang published bằng form sửa khóa.

Màn hình: danh sách khóa; tổng quan quản lý khóa; form thông tin/giá; cây chương–bài; trình sửa nội dung theo loại; kiểm tra sẵn sàng gửi duyệt và xem lý do từ chối.

Nguồn: [course_router.go](/Users/duongwthuj/develop/backend/internal/router/course_router.go:21), [course_handler.go](/Users/duongwthuj/develop/backend/internal/handler/course_handler.go:163), [course_service.go](/Users/duongwthuj/develop/backend/internal/service/course_service.go:40), [course_review_repository.go](/Users/duongwthuj/develop/backend/internal/repository/course_review_repository.go:64), [lesson_contentDTO.go](/Users/duongwthuj/develop/backend/internal/dto/lesson_contentDTO.go:10).

### 3.2. Lớp học và học viên

- `GET /classes/me`: lớp được phân công qua `teacher_classes`.
- `GET /classes`: danh sách có kiểm quan hệ với người gọi, hỗ trợ tìm kiếm/lọc/phân trang; dùng khi cần các lớp xem được, không mặc định coi mọi dòng đều có quyền sửa.
- `GET|PUT /classes/:id`, `POST /classes`; lớp mới ở trạng thái draft, có cập nhật active/archived.
- `GET /classes/:id/students`, `GET /classes/:id/teachers`.
- Tìm học viên để thêm: `GET /classes/:id/enrollable-students?keyword=`; ghi danh/gỡ qua POST/DELETE student routes.
- Tìm giáo viên để phân công: `GET /classes/:id/assignable-teachers?keyword=`; gán/gỡ qua teacher routes, có vai primary/assistant.
- Lớp gắn tổ chức có kiểm thành viên tổ chức; không lấy quyền quản lý một tổ chức để quản lý lớp cá nhân ngoài tổ chức đó.
- `GET /teachers/me/students`: học viên dựa trên enrollment các khóa của instructor; có tiến độ, khóa/lớp, trạng thái suy ra active/hoàn thành và thông tin phụ huynh chính nếu có.
- `GET /courses/:courseId/enrollments`: học viên trong khóa.
- Một học viên có thể có nhiều enrollment; không coi số dòng enrollment là số học viên duy nhất.

Điểm cần giữ rõ: học viên mua khóa không nhất thiết đã được xếp lớp. `classes/me` và lịch dạy lấy lớp đã có bản ghi phân công; chỉ tạo lớp hoặc sở hữu khóa chưa chắc làm lớp xuất hiện trong hai danh sách này.

Màn hình: lớp được phân công; các lớp quản lý; chi tiết lớp; danh sách học viên; phân công giáo viên theo quyền; danh sách học viên khóa học độc lập với danh sách lớp.

Nguồn: [class_router.go](/Users/duongwthuj/develop/backend/internal/router/class_router.go:28), [class_service.go](/Users/duongwthuj/develop/backend/internal/service/class_service.go:165), [teacher_service.go](/Users/duongwthuj/develop/backend/internal/service/teacher_service.go:68), [class_repository.go](/Users/duongwthuj/develop/backend/internal/repository/class_repository.go:387).

### 3.3. Lịch dạy, buổi học và điểm danh

- Lịch cá nhân: `GET /me/timetable?sessions_from=YYYY-MM-DD&sessions_to=YYYY-MM-DD`.
- Nếu bỏ khoảng ngày, API trả lịch lặp; gửi đủ cả hai ngày để có thêm buổi cụ thể. Nhánh Teacher dùng active_role từ token.
- Lịch lặp của lớp: GET/POST `/classes/:classId/schedules`; PUT/DELETE từng lịch.
- Buổi cụ thể: GET/POST `/classes/:classId/sessions`; PUT sửa buổi, DELETE hủy; POST `/generate` sinh buổi từ lịch lặp.
- Buổi có chủ đề, ghi chú, thời gian, trạng thái scheduled/in_progress/completed/cancelled, lý do hủy, liên kết livestream khi có.
- Có kiểm trùng lịch của lớp/giáo viên, thứ tự giờ và khoảng sinh buổi; không chỉ kiểm ở client.
- Điểm danh: GET/POST `/sessions/:sessionId/attendances`, POST `/bulk`, PUT từng bản ghi.
- Trạng thái: present, absent, late, excused; có ghi chú và thông tin check-in/out.
- Có reminder settings; lịch riêng CRUD qua `/me/events`.

Màn hình: lịch tuần/tháng; danh sách buổi; chi tiết buổi; tạo/đổi/hủy lịch; điểm danh hàng loạt; cài đặt nhắc lịch.

Nguồn: [schedule_router.go](/Users/duongwthuj/develop/backend/internal/router/schedule_router.go:21), [schedule_handler.go](/Users/duongwthuj/develop/backend/internal/handler/schedule_handler.go:720), [schedule_service.go](/Users/duongwthuj/develop/backend/internal/service/schedule_service.go:1094), [scheduleDTO.go](/Users/duongwthuj/develop/backend/internal/dto/scheduleDTO.go:102).

### 3.4. Quiz và bài tập: ba nhóm khác nhau

1. **Quiz:** `/quizzes`, `/quizzes/:quizId/questions`, `/me/quizzes`; có nhân bản quiz, thêm hàng loạt/sắp xếp câu hỏi, số lần làm, thời gian, điểm đạt, đảo câu/đáp án và tùy chọn xem đáp án. Xem kết quả/thống kê qua `/quizzes/:id/results|statistics`. Các loại câu: single_choice, multiple_choice, true_false, fill_blank, essay.
2. **Bài tập lớp/phiên live:** `/assignments`, `/classes/:classId/assignments`, `/assignments?session_id=...`; tạo/sửa/xóa, publish/unpublish, testcase và import testcase. Type gồm live_coding/homework/project nhưng DTO hiện là bài tập có ngôn ngữ/code mẫu/time limit/memory limit, không mặc định hiểu là form giao bài nộp PDF tự luận.
3. **Bài tập lập trình trong khóa:** `/exercises`, testcase/import, xem submissions. Đây là mô hình khác Assignment của lớp/phiên live; cần DTO và màn chỉnh sửa đúng loại.

- Xem bài nộp Assignment qua `GET /submissions/assignment/:assignmentId`; xem chi tiết bài nộp qua `/submissions/:id`.
- Assignment có cấu hình cho nộp muộn, mức phạt và thời gian ân hạn ở DTO tạo.
- Có thống kê tỷ lệ accepted và thời gian/bộ nhớ chạy bài; chấm code qua cơ chế xử lý backend.
- Quiz essay được nhận trong schema, nhưng nhánh chấm hiện trả false với comment cần manual grading; chưa thấy route chấm từng câu essay để hoàn thiện luồng đó. Không đưa nút chấm tự luận quiz hoạt động vào phạm vi đầu tiên.

Màn hình: hub bài tập/kiểm tra theo lớp hoặc khóa; danh sách và editor từng loại; danh sách bài nộp; chi tiết kết quả; thống kê bài/quiz.

Nguồn: [quiz_router.go](/Users/duongwthuj/develop/backend/internal/router/quiz_router.go:23), [livestream_router.go](/Users/duongwthuj/develop/backend/internal/router/livestream_router.go:58), [exercise_router.go](/Users/duongwthuj/develop/backend/internal/router/exercise_router.go:22), [assignmentDTO.go](/Users/duongwthuj/develop/backend/internal/dto/assignmentDTO.go:5), [quiz_service.go](/Users/duongwthuj/develop/backend/internal/service/quiz_service.go:1446).

### 3.5. Bảng điểm và tổng kết lớp

- Cột điểm: `/classes/:classId/grade-columns`, có sắp xếp.
- Bảng điểm/điểm học viên: `/classes/:classId/grades`, `/grades/:id`; nhập hàng loạt `/classes/:classId/grades/bulk`.
- Điểm có loại, tiêu đề, điểm tối đa, trọng số, feedback; có thể liên kết assignment/quiz/session.
- Tổng kết: `/classes/:classId/final-grades`, `/calculate`, `/finalize`, PUT từng điểm tổng kết.
- Service có tính điểm chuẩn hóa về thang 10 và trung bình có trọng số.
- Phân quyền chấm theo lớp và trạng thái archived; không mở bảng điểm của lớp bất kỳ chỉ vì user có Teacher.

Màn hình: bảng điểm lớp cuộn ngang; nhập/sửa điểm; nhận xét; cấu hình cột; xem và chốt tổng kết.

Nguồn: [grade_router.go](/Users/duongwthuj/develop/backend/internal/router/grade_router.go:24), [grade_service.go](/Users/duongwthuj/develop/backend/internal/service/grade_service.go:515), [gradeDTO.go](/Users/duongwthuj/develop/backend/internal/dto/gradeDTO.go:13).

### 3.6. Lớp trực tuyến và thống kê

- Tạo/liệt kê/chi tiết/sửa/xóa `/livestream`; start/end/join/leave, xem người tham gia.
- Có mute/kick, khóa/mở bảng trắng, bật/tắt screenshare theo quyền.
- Chat trong phiên: `/chat`; bảng trắng snapshot/event: `/whiteboard`.
- Thống kê: `/analytics/livestream/:sessionId`, `/analytics/assignment/:assignmentId`, `/analytics/participants/:sessionId`.
- Dữ liệu có số người xem, peak, tin nhắn, thời gian xem trung bình và kết quả bài tập. Không suy ra phân tích AI sư phạm chỉ từ tên analytics.
- LiveKit nằm trong service backend; mobile hiện chưa có dependency LiveKit. Màn phòng dạy thực tế cần tích hợp media/realtime và quyền camera/mic riêng, không phải chỉ một REST screen.
- Có cờ recording/polls trong model/settings, nhưng chưa xác nhận luồng API quản lý bản ghi hoặc poll hoàn chỉnh; chưa xếp thành tính năng sẵn dùng.

Nguồn: [livestream_router.go](/Users/duongwthuj/develop/backend/internal/router/livestream_router.go:11), [livestream_service.go](/Users/duongwthuj/develop/backend/internal/service/livestream_service.go:264), [analytics_service.go](/Users/duongwthuj/develop/backend/internal/service/analytics_service.go:88).

### 3.7. Upload video và học liệu

- Upload ảnh/file: `POST /upload`, `POST /upload/any`.
- Video có init → presigned URLs → upload chunk → complete, status/resume, danh sách upload dở, abort và reprocess.
- Có route HLS phát video và xem thông tin xử lý.
- UI cần tiến trình upload và trạng thái xử lý server; không coi complete upload là video đã phát được ngay.

Nguồn: [video_upload_router.go](/Users/duongwthuj/develop/backend/internal/router/video_upload_router.go:28), [upload_router.go](/Users/duongwthuj/develop/backend/internal/router/upload_router.go:13).

### 3.8. Thu nhập, tài khoản nhận tiền và rút tiền

- `GET /wallet/teacher/me`: total_earnings, total_paid_out, available_balance, pending_withdrawal, min_withdrawal_amount, has_open_withdrawal, bank info.
- `GET /wallet/teacher/transactions?type=income|refund&page=&limit=`.
- `PUT /wallet/teacher/bank-info`.
- `GET|POST /wallet/teacher/withdrawals`; `POST /wallet/teacher/withdrawals/:id/cancel`.
- Cần hồ sơ và đủ thông tin ngân hàng; tiền rút đạt tối thiểu backend trả về, không vượt số dư, không tạo thêm khi còn yêu cầu pending/approved. Số dư có thể âm sau hoàn tiền.
- Teacher chỉ hủy yêu cầu pending của chính mình. Admin xử lý approve/reject/completed.
- Số dư khả dụng do backend tính, đã trừ các khoản rút đang giữ chỗ; không tự trừ lần nữa ở client.

Màn hình: tổng quan thu nhập; giao dịch; thông tin ngân hàng; tạo yêu cầu rút; lịch sử/trạng thái và hủy yêu cầu.

Nguồn: [wallet_router.go](/Users/duongwthuj/develop/backend/internal/router/wallet_router.go:25), [withdrawal_router.go](/Users/duongwthuj/develop/backend/internal/router/withdrawal_router.go:32), [wallet_service.go](/Users/duongwthuj/develop/backend/internal/service/wallet_service.go:109), [withdrawal_service.go](/Users/duongwthuj/develop/backend/internal/service/withdrawal_service.go:98).

### 3.9. Trao đổi, thông báo và hồ sơ công khai

- Tin nhắn trực tiếp: `/conversations`, `/conversations/direct`, messages trong conversation, read/mute/pin/reaction/search/unread.
- Group và discussion có router riêng, không đồng nghĩa mọi nhóm là lớp học; thảo luận theo bài qua `/lessons/:lessonId/discussions`.
- Nhận thông báo, đọc/đọc tất cả và cài đặt qua `/notifications`.
- `/notifications/send` là quyền quản trị hệ thống. Không dùng endpoint này để dựng nút Teacher gửi nhắc hàng loạt học viên.
- Hồ sơ giảng viên công khai: `GET /teachers/:id/public-profile`; có hồ sơ chuyên môn, thống kê và khóa published, có thể ẩn hồ sơ theo privacy.
- Reviews khóa có route đọc và reaction; chưa thấy endpoint riêng cho instructor trả lời review.

Nguồn: [message_routes.go](/Users/duongwthuj/develop/backend/internal/router/message_routes.go:18), [notification_router.go](/Users/duongwthuj/develop/backend/internal/router/notification_router.go:16), [public_teacher_page_dto.go](/Users/duongwthuj/develop/backend/internal/dto/public_teacher_page_dto.go:40).

### 3.10. Cuộc thi

- Có quyền `CONTESTS_MANAGE_OWN`, danh sách quản lý `/contests/manage`, quiz options, chi tiết/người tham gia, tạo/sửa/xóa và gửi duyệt.
- Các thao tác approve/reject/cancel/finalize/giải thưởng là nhánh Admin.
- Đây là MVP thi quiz; router ghi rõ không có CRUD problems kiểu cuộc thi lập trình nhiều bài.
- Đưa vào công cụ mở rộng sau khi lớp/lịch/khóa ổn định; không cần thêm một bottom tab riêng.

Nguồn: [contest_routes.go](/Users/duongwthuj/develop/backend/internal/router/contest_routes.go:25).

## 4. Khung giao diện đề xuất

Đây là đề xuất bố cục mobile dựa trên nghiệp vụ đã đọc, không phải cấu trúc sẵn có trong backend.

| Bottom tab | Nội dung chính | Màn con |
|---|---|---|
| Tổng quan | Buổi dạy hôm nay, lớp được phân công, tình trạng khóa và truy cập nhanh | Chi tiết buổi, thông báo, hộp thư |
| Lịch dạy | Tuần/tháng, danh sách buổi, lọc lớp | Chi tiết buổi, điểm danh, tạo/đổi/hủy buổi |
| Lớp học | Lớp được phân công và lớp quản lý | Học viên, giáo viên, lịch lớp, bài tập, bảng điểm, thống kê |
| Khóa học | Khóa của tôi, trạng thái duyệt, tạo khóa | Giáo trình, editor nội dung, upload, học viên khóa, quiz/exercise, cuộc thi mở rộng |
| Tài khoản | Hồ sơ, trạng thái xét duyệt, thu nhập và cài đặt | Ngân hàng, rút tiền, lịch sử, đổi role, bảo mật |

Học viên là hai danh sách có phạm vi khác nhau: học viên lớp ở tab Lớp học; người mua/ghi danh khóa ở chi tiết khóa hoặc hub Học viên. Tránh một bộ đếm gộp không khử trùng.

Tổng quan chưa có API tổng hợp riêng. Giai đoạn đầu ghép các endpoint đã có, mỗi khối có loading/error/empty riêng; chưa hiển thị số bài cần chấm hoặc đồ thị doanh thu theo tháng nếu chưa có dữ liệu tương ứng. Không lấy tổng số trang đang tải làm tổng toàn hệ thống.

Cấu trúc dự kiến, chỉ tạo khi có màn/luồng cần dùng:

```text
lib/features/teacher/
  presentation/
    teacher_shell.dart
    home/
    schedule/
    classes/       # học viên, bài tập, bảng điểm trong ngữ cảnh lớp
    courses/       # giáo trình và editor nội dung theo loại
    profile/
    earnings/
  bloc/            # state cho luồng có nhiều thao tác, dùng lại pattern hiện có
  data/            # API client và model theo contract thực tế
  repository/
```

Tái sử dụng AuthBloc/ProfileCubit, DI GetIt, theme/spacing/radius, avatar, component trạng thái và các phần calendar phù hợp. Không tái sử dụng trực tiếp màn Student đọc nội dung để làm editor Teacher.

## 5. Thứ tự implement và các điều kiện cần giữ

1. Shell và role routing: tách chính xác Teacher/TeacherApplicant, đồng bộ hồ sơ sau xét duyệt/đổi role; thêm DI và test khởi tạo.
2. Đường đi hoàn chỉnh đầu tiên: Tổng quan → lịch → chi tiết buổi → danh sách học viên → điểm danh; xử lý lớp chỉ đọc và thiếu phân công.
3. Khóa học: danh sách/chi tiết, form thông tin/giá, giáo trình, trạng thái duyệt và gửi/rút yêu cầu.
4. Lớp: quản lý học viên/phân công theo capability, bài tập/quiz, bảng điểm và tổng kết; thu nhập/ngân hàng/rút tiền.
5. Sau đó làm phòng dạy LiveKit, upload video có resume, công cụ quiz/exercise nâng cao, cuộc thi và nhắn tin đầy đủ.

Những phần chưa nên hứa là có sẵn:

- Dashboard Teacher tổng hợp, KPI chờ chấm toàn bộ lớp và biểu đồ doanh thu theo thời gian: chưa thấy contract riêng.
- Chấm thủ công từng câu essay trong quiz: schema có essay, nhưng chưa thấy API hoàn thiện; bảng điểm lớp là luồng khác.
- Gia hạn deadline: `extension_router.go` đang bị comment, không được đăng ký.
- Calendar tổng hợp/kiểm tra availability/conflicts: `calendar_router.go` đang bị comment; dùng lịch/buổi trong `schedule_router.go`.
- Gửi thông báo hàng loạt cho lớp bằng `/notifications/send`: Teacher không có quyền endpoint này.
- Bài tập nộp tài liệu tổng quát, AI chấm/nhận xét, quản lý bản ghi livestream và poll: cần xác nhận/bổ sung contract trước.

Các điểm kỹ thuật khi nối API:

- Phản hồi phân trang không đồng nhất: có `page_size`/`page`, có `limit`, mảng `classes`, `courses`, `items`, `transactions` hoặc `data`. Map theo từng DTO, không dùng một parser đoán chung.
- Phân biệt `ClassSession` với `LivestreamSession`; chỉ mở phòng live khi có đúng liên kết ID.
- Tiền và một số điểm số là decimal; không giả định tất cả JSON là int hoặc double.
- Xử lý 403/404/409 và mã khóa tài nguyên như `COURSE_PENDING_REVIEW`, `CLASS_ARCHIVED`; cập nhật UI sau khi nhận trạng thái mới.
- Nút thao tác dựa trên capability + trạng thái của tài nguyên. Backend vẫn là nơi quyết định cuối cùng.

Nguồn mobile cần sửa đầu tiên: [MainScreen](/Users/duongwthuj/develop/mobile/40Study/lib/features/main_screen.dart:23), [RoleUtils](/Users/duongwthuj/develop/mobile/40Study/lib/features/auth/presentation/utils/role_utils.dart:7), [ProfileModel](/Users/duongwthuj/develop/mobile/40Study/lib/features/auth/data/models/profile_model.dart:22).
