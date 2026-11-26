# Kế hoạch đồng bộ luồng Web – Mobile

> Cập nhật: 26/11/2026  
> Phạm vi: các luồng cùng vai trò/chức năng đã đối chiếu từ mã nguồn tại `D:\đồ án\mobile`, `D:\đồ án\web` và `D:\đồ án\backend`.  
> Trạng thái: kế hoạch; **chưa triển khai hoặc kiểm thử chạy ứng dụng**.

## 1. Mục tiêu và cách dùng

Mục tiêu là để một thao tác có cùng ý nghĩa trên hai nền tảng dẫn đến cùng kết quả nghiệp vụ, dùng dữ liệu thật của đúng tài khoản và báo đúng trạng thái thành công/thất bại. Không ép hai nền tảng có giao diện hoặc toàn bộ tính năng giống nhau. Luồng học phí phụ huynh trên mobile và luồng mua khóa học trên web là hai nghiệp vụ khác nhau.

Mỗi hạng mục dưới đây là một đơn vị có thể sửa và nghiệm thu riêng. Chỉ đánh dấu hoàn tất sau khi kiểm tra mã nguồn, test phù hợp và chạy thử trên môi trường có backend. Các đường dẫn là mốc khảo sát ngày 26/11/2026; cần kiểm tra lại trước khi sửa vì mobile đang có nhiều thay đổi chưa commit.

**Trùng lặp đã có kế hoạch:** `docs/superpowers/plans/2026-11-26-security-logic-hardening.md` xử lý cờ preview, chặn thành công thanh toán giả, dữ liệu giả ở một số màn hình và logout xóa dữ liệu cục bộ. Khi thực hiện các mục liên quan bên dưới, dùng kết quả của kế hoạch đó; không triển khai hai bản sửa độc lập cho cùng một chỗ.

**Giới hạn bằng chứng:** Đã kiểm tra route, DTO, service và một số test trong backend; chưa gọi API đang chạy, kiểm tra dữ liệu DB, log mạng hoặc chạy app. Mã nguồn xác nhận hợp đồng triển khai hiện tại, chưa chứng minh môi trường triển khai dùng đúng revision này. Không có Flutter/Dart trong PATH tại lúc khảo sát. Các trường hợp cần quyết định sản phẩm/API được ghi rõ là điểm chặn.

### Kết luận hợp đồng backend đã xác nhận từ mã

| Nghiệp vụ | Hợp đồng backend | Hệ quả cho kế hoạch |
|---|---|---|
| Bài tập của con | `GET /api/parent/children/:id/assignments` trả danh sách phân trang, `status`/`due_date`/`stats`; không có route chi tiết dưới `/parent/children/:id`. `GET /api/assignments/:id` có nhưng quyền dựa trên chính user xem là thành viên lớp/phiên hoặc chủ/admin, không tự chấp nhận quan hệ phụ huynh – con. Xem `internal/router/parent_dashboard_router.go`, `internal/dto/parent_dashboard_dto.go`, `internal/service/assignment_service.go:551-587`. | Có thể làm danh sách thật ngay; chi tiết đầy đủ cần route phụ huynh có kiểm quyền hoặc chỉ hiện các trường của danh sách. Không gọi route bài tập chung để vượt quyền. |
| Tiến độ của con | `GET /api/parent/children/:id/courses` trả `progress_percent` từng khóa, `total/page/page_size`, `instructor_id`; `overview` trả số khóa ghi danh/hoàn thành. Xem `internal/dto/parent_dashboard_dto.go:6-48`, `internal/service/parent_dashboard_service.go:151-205`. | Có nguồn thật cho tiến độ từng khóa; cần phân trang và phân biệt tỷ lệ hoàn thành khóa với tiến độ trung bình. |
| Thông báo | DTO backend trả `content`, `notification_type`, `reference_type`, `reference_id`; danh sách có `notifications`, `unread_count`; endpoint đếm trả `data.unread_count`, có DELETE theo ID. Xem `internal/dto/notificationDTO.go:9-28`, `internal/handler/notification_handler.go:20-50`, `internal/router/notification_router.go`. | Sai khác DTO và badge ở mobile là lỗi hợp đồng chắc chắn theo mã hiện tại, không chỉ là nghi vấn giữa hai client. |
| Ghi danh và mua khóa | `POST /api/courses/:courseId/enroll` chỉ ghi danh trực tiếp nếu `course.price == 0`; khóa trả phí trả 402, archived trả 409, chưa xuất bản trả 404. `POST /api/orders` và các route payment-intent/status/check có sẵn; vai trò phụ huynh bị chặn mua. Xem `internal/service/enrollment_service.go:99-130`, `internal/handler/enrollment_handler.go:28-65`, `internal/router/order_router.go:38-44`. | Phân nhánh theo giá backend, không chỉ `is_free`; khóa trả phí phải dùng đơn hàng. |
| Liên kết con | Backend dùng email: POST/GET/cancel/respond dưới `/api/family/link-requests`, có quyền phụ huynh/học sinh, rate limit và kiểm tra quan hệ. Xem `internal/router/parent_link_router.go`, `internal/dto/parent_link_dto.go`. | Chọn luồng email là quyết định dựa trên backend hiện có; không có API mã liên kết trong các route đã rà. |
| Quiz, chứng chỉ, wishlist | Backend có lịch sử attempt với `mode`, `completed_at`; API chứng chỉ; API wishlist khóa học. Xem `internal/router/quiz_router.go`, `internal/dto/quizDTO.go`, `internal/router/certificate_router.go`, `internal/router/wishlist_router.go`. | Chủ yếu nối/đổi nguồn dữ liệu mobile; không cần thiết kế endpoint mới cho các mục này. |
| Học phí phụ huynh và tài liệu | Chưa thấy route hóa đơn/học phí phụ huynh trong router hiện tại; các route payment là **đơn mua khóa học**. Model có `lesson_attachments`, nhưng DTO và route lesson content hiện chỉ trả video/livestream/exercise/article/quiz, chưa có API tài liệu theo bài học. | Không tái sử dụng order của khóa học làm học phí. Tài liệu thật cần hợp đồng API riêng hoặc bỏ phần giả ở client. |

### Dấu vết chính để review

| Luồng | Mobile hiện tại | Web/đối chiếu | Mức chắc chắn |
|---|---|---|---|
| Bài tập của con | `lib/features/parent/repository/parent_learning_repository_impl.dart:675-825` | `src/services/parent-dashboard.service.ts:126-153,219-225`; backend `internal/router/parent_dashboard_router.go` | Chắc chắn từ code: chi tiết trả mẫu; backend chưa có route chi tiết cho phụ huynh |
| Phân tích và tiến độ | `parent_home_repository_impl.dart:328-353`; `parent_learning_repository_impl.dart:1000-1047` | `src/services/parent-dashboard.service.ts:183-199` | Chắc chắn từ code: một số trường cố định và lỗi bị đổi thành rỗng |
| Đăng ký/mua khóa | `course_progress_card.dart:68-86`; `course_api_client.dart:164-165` | `src/app/(main)/courses/[slug]/page.tsx:110-127`; `src/components/course/course-detail-sidebar.tsx:156-195` | Chắc chắn nút mobile chưa gọi API; thanh toán cần xác minh backend |
| Liên kết con | `add_child_screen.dart:159-174` | `src/services/parent-link.service.ts:53-71` | Chắc chắn mobile chưa gửi; hợp đồng backend chưa xác minh |
| Thông báo | `student_repository_impl.dart:320-339`; `notification_model.dart:6-18` | `src/types/notification.ts:5-40`; backend `internal/dto/notificationDTO.go` | Chắc chắn mobile dùng sai schema backend hiện tại; runtime chưa chạy |
| Quiz | `student_api_client.dart:53-60`; `quiz_result_storage.dart:6-47` | `src/services/quiz.service.ts:266-275` | Chắc chắn API có sẵn nhưng trạng thái UI mobile đọc local |
| Chứng chỉ | `lesson_detail_screen.dart:62-82`; `course_detail_bloc.dart:193-225` | `src/services/certificate.service.ts:67-85` | Chắc chắn có sẵn luồng cấp/xem chứng chỉ khác trên mobile |

## 2. Bản đồ ưu tiên

| Đợt | Mã | Luồng | Ưu tiên | Phụ thuộc |
|---|---|---|---|---|
| 1 – Độ tin cậy dữ liệu | P0-1 | Chi tiết bài tập của con | P0 | Chọn danh sách thật tối thiểu hoặc thêm route chi tiết có quyền phụ huynh |
| 1 – Độ tin cậy dữ liệu | P0-2 | Phân tích học tập phụ huynh | P0 | Xác nhận dữ liệu backend hiện có |
| 1 – Độ tin cậy dữ liệu | P0-3 | Học phí và trạng thái giao dịch | P0 | Kế hoạch security/logic; backend hiện chưa có API học phí phụ huynh |
| 1 – Độ tin cậy dữ liệu | P0-4 | Thông báo thành công của hành động chưa thực hiện | P0 | Hợp đồng API tương ứng nếu giữ hành động |
| 2 – Hoàn tất luồng chính | P1-1 | Đăng ký khóa miễn phí và mua khóa trả phí | P1 | Hợp đồng enroll/order/payment; trạng thái đăng nhập |
| 2 – Hoàn tất luồng chính | P1-2 | Liên kết phụ huynh – học sinh | P1 | API `/family/link-requests` đã có; cần cả hai phía mobile |
| 2 – Hoàn tất luồng chính | P1-3 | Đăng ký vai trò sau đăng nhập | P1 | API system roles/select role |
| 2 – Hoàn tất luồng chính | P1-4 | Hợp đồng dữ liệu và điều hướng thông báo | P1 | DTO backend đã rõ; quy tắc route theo vai trò |
| 3 – Đồng bộ trạng thái | P2-1 | Lịch sử quiz và tiến độ giữa thiết bị | P2 | API lịch sử attempt |
| 3 – Đồng bộ trạng thái | P2-2 | Danh sách lưu/wishlist | P2 | API wishlist; xử lý dữ liệu cục bộ cũ |
| 3 – Đồng bộ trạng thái | P2-3 | Nút xem chứng chỉ sau hoàn thành | P2 | Luồng chứng chỉ mobile đã có |
| 3 – Đồng bộ trạng thái | P2-4 | Tài liệu bài học/khóa học thật | P2 | Nguồn tài liệu và quy tắc tải/lưu |
| 3 – Đồng bộ trạng thái | P2-5 | Xác nhận luồng giáo viên với API thật | P2 | Build QA không dùng preview; tài khoản giáo viên |

## 3. Đợt 1 – Bảo đảm dữ liệu và thông báo trung thực

### P0-1. Chi tiết bài tập của con

**Hiện trạng:** `parent_learning_repository_impl.dart:getHomeworkList` lấy danh sách thật từ `/parent/children/{childId}/assignments`, nhưng `getHomeworkDetail` chỉ trả các bài mẫu và mặc định trả bài Vật lý cố định với ID `hw-generic`. `parent_homework_screen.dart` truyền ID thật sang màn chi tiết. Web hiển thị danh sách bài tập theo dữ liệu API của con. Backend hiện không có route chi tiết trong namespace phụ huynh; route chung `/assignments/:id` kiểm quyền người gọi là chủ/thành viên lớp hoặc phiên/admin, không kiểm quan hệ phụ huynh – con.

Trong danh sách mobile, trạng thái `not_started` đang được đổi thành `urgent`, nhãn hạn chung là “CẦN HOÀN THÀNH”, thời gian chung là “Sắp đến hạn”; `due_date` từ hợp đồng web chưa được dùng. `class_name` trên web là tùy chọn, nên không được tự tạo tên lớp/giáo viên như thể API đã cung cấp.

**Việc làm:**

- Sửa ngay: với bài thật, chỉ hiển thị các trường thật đã có từ endpoint danh sách; phần thiếu hiển thị “chưa có dữ liệu” hoặc ẩn, không dựng bài mẫu. Nếu cần trang chi tiết đầy đủ, thêm endpoint parent-scoped theo `childId` + `assignmentId`, dùng `verifyParentChildRelation` và `CanViewProgress`; lọc trường nhạy cảm như test ẩn/đáp án. Không cho client gọi `/assignments/:id` bằng quyền của con.
- Ánh xạ đầy đủ `status`, `due_date`, `class_name` theo dữ liệu trả về; phân biệt `not_started`, `in_progress`, `completed`, `overdue`. Chỉ hiện “gấp/quá hạn” khi có điều kiện thật tương ứng; không tự thêm tên giáo viên chung.
- Giữ bài mẫu chỉ trong preview có nhãn rõ ràng. Không cho ID bài thật rơi vào nhánh `hw-generic`.
- Test với hai bài thật có ID/nội dung khác nhau, bài không tồn tại, lỗi API, con không thuộc phụ huynh, bài chưa bắt đầu/chưa quá hạn và danh sách phân trang.

**Xong khi:** Chạm mỗi bài trong danh sách mở đúng ID và nội dung của bài đó; nhãn trạng thái/hạn đúng response; API lỗi không biến thành một bài Vật lý mẫu.

### P0-2. Phân tích học tập phụ huynh

**Hiện trạng:** `parent_home_repository_impl.dart:_fetchAnalytics` lấy điểm trung bình thật nhưng gắn nhãn “Báo cáo tuần 4 • Môn Ngữ Văn”, tiến độ `15%`, biểu đồ và insight cố định. Những màn hình học tập khác cũng cần rà lại `getClassDetail`, `getLearningInsights`, `getRecommendedCourses`, `getProgressOverview` cho con thật. Backend hiện có điểm từng lớp và tiến độ từng khóa, nhưng không thấy route riêng cho “insight tuần” hay gợi ý khóa học theo con.

`getProgressOverview` hiện suy `averageProgressPercent = completed_courses / enrolled_courses`, dù đây là tỷ lệ khóa đã hoàn thành, rồi trả `courses: []`; khi API lỗi lại trả tổng quan toàn 0 như không có dữ liệu. Web có endpoint `/parent/children/{id}/courses` cho danh sách khóa học.

**Việc làm:**

- Lập bảng từng trường UI ↔ trường API thực có; chỉ tính chỉ số khi có đủ dữ liệu và định nghĩa phép tính.
- Phân biệt tỷ lệ khóa hoàn thành với tiến độ học trung bình; lấy `progress_percent` thật từ `/parent/children/{id}/courses` và xử lý `total/page/page_size`. Không gọi một tỷ lệ bằng tên của chỉ số khác.
- Với chỉ số chưa có nguồn, hiển thị trạng thái chưa có dữ liệu; không ghép số thật với nhãn/biểu đồ mẫu.
- Tách trạng thái API lỗi, chưa liên kết con, chưa có dữ liệu và kết quả 0 hợp lệ. Kiểm tra con có điểm/chưa có điểm, nhiều môn, nhiều khóa, lỗi và đổi con; đối chiếu giá trị hiển thị với response.

**Xong khi:** Mọi con số, tên môn, tuần báo cáo, xu hướng và nhận xét của tài khoản thật đều truy được về dữ liệu hoặc phép tính có định nghĩa.

### P0-3. Học phí và trạng thái thanh toán

**Hiện trạng:** `parent_payment_repository_impl.dart` trả hóa đơn/giao dịch mẫu khi bật preview và `PaymentUnavailableException` khi tắt preview. `submitPayment` và `checkPaymentStatus` có thể trả trạng thái thành công giả trong preview. Backend hiện có thanh toán **đơn mua khóa học** (`/orders`) nhưng chưa có route hóa đơn/học phí phụ huynh; đây là hai nghiệp vụ riêng.

**Việc làm:**

- Hoàn tất phần chặn dữ liệu/giao dịch giả theo Task 2–3 của `2026-11-26-security-logic-hardening.md`; môi trường thật không được hiện hóa đơn mẫu hay biên lai giả.
- Khi chưa có API học phí thật: màn hình nói rõ “chưa khả dụng” và vô hiệu hóa nút thanh toán; preview phải có nhãn demo rõ ràng.
- Nếu sau này triển khai backend học phí: thiết kế hợp đồng hóa đơn theo con, tạo giao dịch, idempotency, pending/unknown/failed/success và đối soát trạng thái từ server trước khi hiện thành công. Không nối màn học phí vào `/orders` của khóa học.
- Kiểm tra cả khi tải hóa đơn lỗi, hết hạn phiên thanh toán, quay lại màn hình sau khi app bị đóng, kiểm tra lại trạng thái và bấm thanh toán hai lần. Không dùng `success` giả để hoàn tất luồng QA.

**Xong khi:** Không có giao dịch thành công chỉ do mobile tự tạo; trạng thái thanh toán cuối cùng khớp server. Trường hợp API lỗi không được hiện “đã thanh toán” hoặc “không còn khoản phải đóng”.

### P0-4. Các hành động báo đã làm nhưng chưa làm

**Hiện trạng:** `parent_homework_screen.dart:_showRemindNotification` báo “Đã gửi thông báo nhắc con” dù chỉ hiện SnackBar; `parent_homework_detail_screen.dart` có hành động liên hệ giáo viên/đặt lịch chưa nối API. Backend **đã có** nhắn tin trực tiếp (`POST /conversations/direct`, `POST /conversations/:id/messages`) và cho phép phụ huynh nhắn giảng viên đang dạy con khi quan hệ còn hiệu lực. Web dùng `instructor_id` từ danh sách khóa học của con để mở hội thoại. Chưa thấy endpoint gửi lời nhắc bài tập hoặc đặt lịch trao đổi. `lesson_documents_section.dart` có thể báo tải xong khi chỉ đổi `Set` trong bộ nhớ; thanh tải tài liệu khóa học có callback rỗng.

**Việc làm:**

- Với “Nhắn giảng viên”, chỉ nối API direct conversation khi có `instructor_id` thật liên hệ được từ khóa/lớp của con; màn bài tập hiện chỉ có tên giáo viên nên không đoán ID từ tên. Xử lý 403 khi quan hệ/quyền liên hệ thay đổi. Với “Nhắc con”/“Đặt lịch”, ẩn hoặc ghi đúng “chưa khả dụng” cho đến khi có backend. Không hiện câu xác nhận thành công trước response thành công.
- Phân biệt “đã gửi yêu cầu”, “đã tải tệp vào máy” và “chỉ xem trước”; kiểm tra tệp thực sự tồn tại/mở được nếu báo tải xong.
- Đối chiếu riêng tài liệu bài học: web hiện chưa cung cấp tài nguyên bài học (`resources: []`), nên chỉ triển khai tải thật khi có nguồn tài liệu thật.

**Xong khi:** Không còn nút bấm im lặng hoặc thông báo hoàn tất cho thao tác chưa diễn ra.

## 4. Đợt 2 – Hoàn tất các luồng nghiệp vụ chính

### P1-1. Khóa học: đăng ký miễn phí và mua trả phí

**Hiện trạng:** `course_progress_card.dart` chỉ báo “Chức năng đăng ký đang phát triển”. Mobile đã có `CourseRepository.enrollCourse` nhưng chưa thấy màn hình gọi. Web dùng `useEnrollCourse` cho khóa miễn phí, và `course-detail-sidebar.tsx` → order/payment cho khóa trả phí.

Đây là hai nhánh triển khai riêng: API `POST /api/courses/{id}/enroll` đã khai báo ở mobile; chưa tìm thấy order/payment client cho việc mua khóa học trong mobile. Backend chỉ cho enroll trực tiếp khi `course.price == 0`, **không dựa vào `is_free`**; khóa trả phí trả 402. Khóa archived trả 409 `COURSE_NOT_FOR_SALE`, khóa nháp/ẩn trả 404. Backend có `/orders`, payment-intent, payment-status và check-payment; phụ huynh bị chặn tạo đơn/thanh toán mua khóa.

**Việc làm:**

- Tách rõ trạng thái: khách chưa đăng nhập, khóa miễn phí, khóa trả phí, đã đăng ký, không được bán/không đủ điều kiện; kiểm tra quyền mua theo vai trò giống web.
- Khóa miễn phí: quyết định theo `price == 0` từ backend, gọi enroll thật, chống bấm lặp, xử lý 402/404/409, tải lại trạng thái khóa và chuyển vào học khi server xác nhận. Nếu `is_free` và `price` lệch, không dùng `is_free` để mở khóa.
- Khóa trả phí: dùng hợp đồng `/orders` đang có, tính tổng theo response server (bao gồm giảm giá/voucher), idempotency, payment-intent, trạng thái pending/failed/success, quay lại khóa sau đăng nhập. Đơn 0đ do voucher giảm 100% được backend hoàn tất/ghi danh trong transaction tạo đơn; không chờ giao dịch ngân hàng và không tự đánh dấu thành công trước response.
- Với khách chưa đăng nhập, lưu đích quay lại đúng khóa. Với phụ huynh, đối chiếu quy tắc web hiện chặn mua khóa; không mở checkout chỉ vì có nút trên mobile.
- Viết test cho nhánh miễn phí/trả phí/đã đăng ký/lỗi, khóa 0đ sau giảm giá, payment pending, đóng app rồi mở lại và bấm lặp; chạy thử từng nhánh với backend.

**Xong khi:** Cùng một tài khoản và khóa học có cùng trạng thái đăng ký trên web/mobile sau khi tải lại; khóa trả phí chỉ mở học khi server xác nhận quyền học.

### P1-2. Liên kết con

**Hiện trạng:** `add_child_screen.dart` yêu cầu “mã liên kết do trung tâm cung cấp”, chờ `Future.delayed` rồi báo đang phát triển. Backend và web đều dùng email học sinh, gửi `/family/link-requests`, học sinh chấp nhận/từ chối, phụ huynh có thể xem/hủy yêu cầu. Backend kiểm `relationship` thuộc `parent|guardian|grandparent`, lời nhắn tối đa 500 ký tự; có rate limit theo IP và theo tài khoản.

Web có cả danh sách yêu cầu đã gửi, yêu cầu tới học sinh, phản hồi, hủy yêu cầu và hủy liên kết (`parent-link.service.ts`). Chưa thấy bằng chứng có endpoint “mã liên kết” trong hai client.

**Việc làm:**

- Đổi form mobile sang email + quan hệ + lời nhắn tùy chọn theo DTO backend; không hiển thị mã liên kết vì route đó không tồn tại trong backend hiện tại.
- Thêm trạng thái đã gửi/đang chờ/được chấp nhận/bị từ chối/hủy; bảo đảm học sinh có nơi phản hồi trên mobile hoặc điều hướng rõ đến web.
- Sau khi gửi, không hiển thị tên/tài khoản học sinh đang chờ nếu backend che thông tin này (đúng quy tắc web). Chỉ cập nhật danh sách con sau khi học sinh chấp nhận.
- Kiểm tra email sai, email không tồn tại, trùng yêu cầu, rate limit, rút yêu cầu, hai phụ huynh cùng liên kết và cập nhật danh sách con sau khi được chấp nhận.

**Xong khi:** Yêu cầu tạo từ mobile xuất hiện trên web; học sinh xác nhận trên một nền tảng thì cả hai nền tảng cùng thấy liên kết mới.

### P1-3. Tài khoản chưa có vai trò

**Hiện trạng:** `login_bloc.dart` phát `LoginNeedsRoleRegistration`, nhưng `login_screen.dart` chỉ hiện SnackBar. Web tải system roles và gọi select role.

**Việc làm:** Tạo nhánh chọn vai trò từ `sessionToken` của login. Tận dụng phần tải/lọc vai trò của `SelectRoleCubit` và phần gửi chọn vai trò của `LoginRolePickerScreen` nếu phù hợp; `SelectRoleScreen` hiện chuyển tới form đăng ký, nên không tái sử dụng nguyên luồng. Backend chỉ cho người dùng tự cấp `STUDENT`, `PARENT`, `TEACHER_APPLICANT`; `TEACHER` cần được duyệt, admin/owner không được tự cấp. Chỉ hiện các vai trò backend trả từ `/auth/system-roles`, xử lý lỗi/hết phiên và đưa vào shell đúng vai trò sau khi chọn. Kiểm tra một vai trò, nhiều vai trò và vai trò không hỗ trợ trên mobile.

**Xong khi:** Tài khoản mới chưa có vai trò đăng nhập và hoàn tất chọn vai trò được trên mobile; thoát/mở lại ứng dụng vẫn vào đúng vai trò.

### P1-4. Hợp đồng dữ liệu và điều hướng thông báo

**Hiện trạng:** Backend **thực sự trả** mỗi thông báo có `content`, `notification_type`, `reference_type`, `reference_id`; response danh sách có `notifications`, `unread_count`, endpoint đếm trả `data.unread_count`. Mobile lại giải mã trực tiếp thành `NotificationModel` có `body`, enum `type` chỉ gồm năm giá trị và `action_url`; hàm đếm tìm `count`, còn badge trong `student_shell.dart` luôn là 0. Với backend revision hiện tại, DTO mobile không khớp và hàm đếm trả 0; cần test chạy để xác nhận biểu hiện cụ thể trên màn hình.

**Việc làm:**

- Cập nhật DTO/parser mobile theo `internal/dto/notificationDTO.go` và các loại trong `internal/model/notification.go`, giữ fallback an toàn cho loại mới. Chụp một response thật ở môi trường thử để xác nhận backend đang chạy đúng revision và kiểm parser với payload đó.
- Lấy `unread_count` từ response server; đồng bộ badge khi đọc một/đọc tất cả/xóa và khi app trở lại foreground.
- Xây bảng `notification_type` + `reference_type` + `reference_id` + vai trò → đích mobile. Không mở tùy ý `action_url` từ payload nếu chưa kiểm tra scheme/host/route. Thông báo không có đích vẫn có thể đọc nội dung.
- Web có `DELETE /notifications/{id}`; thêm API xóa cho mobile hoặc bỏ thao tác vuốt xóa. Chỉ xóa item khỏi UI sau khi server nhận, có hoàn tác hoặc phục hồi khi API lỗi.
- Test parser với response web hiện hành, loại chưa biết, thiếu `reference_id`, đã đọc/chưa đọc, lỗi 401/403 và xóa thất bại.

**Xong khi:** Danh sách/badge phản ánh response thật; chạm loại có đích mở đúng màn theo vai trò; vuốt xóa không làm mất item chỉ trên thiết bị.

## 5. Đợt 3 – Đồng bộ trạng thái và điều hướng

### P2-1. Quiz

**Hiện trạng:** Mobile làm/nộp quiz qua API nhưng `QuizResultStorage` lưu theo `quizId` trong `SharedPreferences`; `lesson_detail_screen.dart` và `lesson_exercise_section.dart` dùng bản lưu cục bộ để hiển thị đã hoàn thành. Web đọc attempts từ server. Mobile **đã có** `StudentApiClient.getMyAttempts` và dùng trong `getQuizReviewDetails` khi chưa có `attemptId`; backend trả `mode`, `completed_at`, `is_passed` theo từng lượt, nên cần mở rộng repository/trạng thái UI, không thêm endpoint mới. Màn mobile lấy quiz của bài qua `GET /quizzes?lesson_id=...` với trang mặc định 20; web dùng route riêng `GET /lessons/:lessonId/quizzes` trả mảng tối đa 50, nên bài có nhiều quiz có thể hiện số lượng khác nhau.

**Việc làm:** Lấy lịch sử attempt từ API làm nguồn quyết định hoàn thành; chỉ tính attempt thật đã hoàn thành, phân biệt lần luyện tập/chính thức theo `mode` backend. Chọn route quiz theo bài hoặc phân trang hết để không bỏ quá trang mặc định. Cache cục bộ chỉ tăng tốc và phải gắn với user ID; không dùng kết quả cũ chưa xác thực để mở khóa tiến độ. Xử lý dữ liệu cũ, logout/đổi tài khoản, đổi thiết bị và trạng thái offline. Test API rỗng, nhiều attempts, hơn 20 quiz trong bài, submit xong tải lại, lỗi mạng và user B trên máy của user A.

**Xong khi:** Làm quiz trên web rồi mở mobile (và ngược lại) cho cùng trạng thái/lượt làm; tài khoản khác trên cùng máy không thấy kết quả cũ.

### P2-2. Danh sách lưu/wishlist

**Hiện trạng:** Mobile lưu bookmark khóa học ở `SharedPreferences` (`bookmark_storage.dart`), web dùng API `/wishlist`. Nút tim ở thanh dưới của màn chi tiết khóa học mobile còn callback rỗng; danh sách bookmark có item chưa mở khóa khi chạm.

**Việc làm:** Chuẩn hóa bookmark **khóa học** sang `GET /wishlist`, `GET /wishlist/ids`, `POST /wishlist`, `DELETE /wishlist/{courseId}`. Quyết định riêng cách xử lý bookmark các loại khác nếu mobile có; không ép chúng vào API wishlist khóa học. Đồng bộ mọi vị trí nút tim, điều hướng item đến khóa học, xử lý 401/lỗi mạng và rollback nếu optimistic update thất bại. Với dữ liệu cục bộ cũ, chỉ di chuyển khi xác định đúng chủ tài khoản; nếu không xác định được, không tự upload vào tài khoản đang đăng nhập.

**Xong khi:** Lưu/bỏ lưu khóa trên một nền tảng phản ánh trên nền tảng kia sau refresh; chạm item mở đúng khóa; đổi tài khoản không lẫn danh sách.

### P2-3. Nút xem chứng chỉ sau hoàn thành

**Hiện trạng:** `lesson_detail_screen.dart` hiện nút “Xem chứng chỉ” nhưng chỉ pop màn hình. Mobile đã có `CourseDetailCertificateRequested`, `CertificateDetailScreen` và API cấp/lấy chứng chỉ ở màn chi tiết khóa học. Web đưa người dùng sang `/certificates`.

**Việc làm:** Nối CTA tới luồng chứng chỉ mobile đã có; chờ server xác nhận rồi mở đúng chứng chỉ. Kiểm tra chứng chỉ chưa sẵn sàng, API lỗi, mở lại sau khi đóng app. Rà `course_detail_screen.dart`: listener hiện chạy khi bookmark đổi và mở màn chứng chỉ nếu `certificate` đang có trong state, cần chỉ điều hướng khi có sự kiện chứng chỉ phù hợp.

**Xong khi:** Nút mở đúng chứng chỉ của khóa vừa hoàn thành và không mở chứng chỉ ngoài ý muốn khi bấm bookmark.

### P2-4. Tài liệu thật và nút tải

**Hiện trạng:** `lesson_documents_section.dart` chứa bốn tài liệu cố định không gắn bài học, có nút báo tải xong dù không lưu tệp; `course_enrollment_bar.dart` có nút tải callback rỗng. Web player hiện truyền `resources: []`. Backend có model `lesson_attachments` nhưng DTO và route nội dung bài học hiện không trả attachment/tệp; chưa có API tài liệu hoàn chỉnh cho hai client.

**Việc làm:** Đợt 1 (P0-4) loại bỏ thông báo tải thành công sai và affordance không hoạt động. Nếu muốn triển khai thật, thiết kế route/DTO đọc attachment theo bài/khóa và quyền học viên trước; sau đó làm URL truy cập, tải/lưu/mở tệp và xử lý lỗi. Không hiển thị danh sách cố định cho bài thật.

**Xong khi:** Mỗi tài liệu hiện ra thuộc đúng bài/khóa, tải tạo tệp mở được trên thiết bị; trường hợp chưa có tài nguyên hiển thị rỗng trung thực.

### P2-5. Luồng giáo viên với API thật

**Hiện trạng:** `TeacherPreviewApi.enabled` bật mặc định trong bản dev không phải release; thao tác ghi ở preview bị từ chối. `TeacherShell` dùng `TeacherApi` khi preview tắt.

**Việc làm:** Xác nhận banner demo đã có dễ nhận biết ở các màn; chạy build QA với `TEACHER_UI_PREVIEW=false`, kiểm tra tạo/sửa khóa, lớp, bài tập, điểm, lịch và lỗi quyền theo cùng tài khoản trên web. Ghi rõ endpoint nào có/không có ở mobile; chỉ thêm việc sửa khi chứng minh được lệch cụ thể.

**Xong khi:** Có bảng kết quả chạy trên API thật; không lấy trạng thái preview làm bằng chứng cho nghiệp vụ giáo viên.

## 6. Điểm sửa dự kiến và kiểm tra tự động

Đây là bản đồ bắt đầu, không phải danh sách file được phép sửa cố định. Trước mỗi hạng mục cần rà các caller và test hiện có, nhất là những file đã thay đổi chưa commit.

| Mã | Điểm sửa mobile chính | Test cần có hoặc mở rộng |
|---|---|---|
| P0-1 | `parent_learning_repository_impl.dart`, `parent_homework_screen.dart`, `parent_homework_detail_screen.dart`, model bài tập | Repository mapping trạng thái/hạn; widget mở đúng ID; lỗi/không có quyền |
| P0-2 | `parent_home_repository_impl.dart`, `parent_learning_repository_impl.dart`, màn phân tích/tiến độ | Dữ liệu thật so với response; 0 hợp lệ khác lỗi; nhiều khóa/môn |
| P0-3 | `parent_payment_repository_impl.dart`, các màn payment; phối hợp security/logic plan | Preview bật/tắt; không success giả; idempotency/pending nếu có API |
| P0-4 | `parent_homework_screen.dart`, `parent_homework_detail_screen.dart`, `lesson_documents_section.dart`, `course_enrollment_bar.dart` | Nhấn CTA không báo thành công khi chưa có side effect; lỗi tải tệp |
| P1-1 | `course_progress_card.dart`, bloc/repository chi tiết khóa, course/order/payment client cần thêm cho nhánh trả phí | Free/paid/enrolled/guest/parent; bấm lặp; refresh sau thành công |
| P1-2 | `add_child_screen.dart`, client/repository liên kết và màn yêu cầu của phụ huynh/học sinh | Gửi/chờ/chấp nhận/từ chối/hủy; quyền và rate limit |
| P1-3 | `login_screen.dart`, `login_bloc.dart`, picker chọn vai trò hoặc màn mới | Không có vai trò, một/nhiều vai trò, hết session token, mở lại app |
| P1-4 | `notification_model.dart`, `student_repository_impl.dart`, `student_api_client.dart`, `notification_tile.dart`, `student_shell.dart` | Parse payload thật; unread badge; route theo vai trò; xóa thất bại |
| P2-1 | `quiz_result_storage.dart`, `student_repository_impl.dart`, màn quiz/lesson | Attempts từ server; đổi thiết bị/tài khoản; offline; mode quiz |
| P2-2 | `bookmark_storage.dart`, `course_detail_bloc.dart`, màn bookmark và các nút tim | Wishlist API, đồng bộ hai nền tảng, rollback, dữ liệu cũ |
| P2-3 | `lesson_detail_screen.dart`, `course_detail_bloc.dart`, `course_detail_screen.dart` | Cấp/xem chứng chỉ đúng khóa; không tự mở khi đổi bookmark |
| P2-4 | `lesson_documents_section.dart`, `course_enrollment_bar.dart`, model/API tài liệu nếu có | Tài nguyên đúng bài, tải/mở tệp, URL hết hạn, không có tài liệu |
| P2-5 | `teacher_shell.dart`, các flow giáo viên đang có | Smoke test API thật theo vai trò; preview có nhãn và chặn ghi |

## 7. Cách nghiệm thu từng đợt

1. Ghi lại phiên bản mobile/web/backend, môi trường (`ENV`, `PREVIEW_DATA`, `TEACHER_UI_PREVIEW`) và tài khoản thử theo vai trò. Không dùng dữ liệu demo để xác nhận parity của dữ liệu thật.
2. Với mỗi mục, kiểm tra bốn trạng thái tối thiểu: có dữ liệu, dữ liệu rỗng, API lỗi, hết phiên/không có quyền. Các thao tác ghi kiểm tra thêm bấm lặp và tải lại ứng dụng.
3. So sánh cùng tài khoản/cùng đối tượng trên web và mobile sau khi tải lại; lưu request/response hoặc log đã ẩn token để xác nhận thay đổi đến từ server.
4. Chạy test tập trung cho repository/bloc/widget vừa sửa, `flutter analyze`, sau đó smoke test trên thiết bị. Tại thời điểm lập kế hoạch máy chưa nhận diện lệnh `flutter`/`dart`, nên chưa có bằng chứng chạy các bước này.
5. Cập nhật bảng ưu tiên: đánh dấu `[x]` cho mục đã nghiệm thu, ghi commit/PR, môi trường và bằng chứng; giữ `[ ]` nếu chỉ sửa code hoặc chỉ chạy test giả lập.

### Bộ ca kiểm tra chung khi review PR

| Ca | Dữ liệu/thao tác | Kết quả phải chứng minh |
|---|---|---|
| C1 | Cùng user, cùng đối tượng, thao tác trên web rồi mở mobile và ngược lại | Trạng thái trên hai bên khớp sau refresh |
| C2 | User A đăng xuất, user B đăng nhập trên cùng thiết bị | Không hiện bookmark, quiz hoặc thông tin con của A |
| C3 | API trả danh sách rỗng hợp lệ | Hiện trạng thái rỗng, không hiện dữ liệu mẫu |
| C4 | API 401/403/404/5xx hoặc mất mạng | Có lỗi/khả năng thử lại đúng; không hiện thành công hoặc số 0 giả |
| C5 | Bấm thao tác ghi hai lần, đóng app và mở lại | Không tạo yêu cầu/đơn/giao dịch trùng; trạng thái lấy lại từ server |
| C6 | Dev preview và QA/prod preview tắt | Demo có nhãn; QA/prod không rơi vào mock khi API lỗi |

### Điểm cần chốt trước khi code từng luồng

| Mục | Điều cần xác nhận | Phương án mặc định của kế hoạch |
|---|---|---|
| P0-1 | Có cần chi tiết bài tập đầy đủ cho phụ huynh ở đợt này không? | Backend chưa có route parent-scoped: trước hết chỉ hiện trường thật từ danh sách; làm route mới nếu chi tiết đầy đủ là yêu cầu |
| P0-2 | Có nguồn cho insight/xu hướng không? | Tiến độ từng khóa dùng API đã có; không hiện insight/xu hướng chưa có nguồn; API lỗi không đổi thành rỗng |
| P0-3 | Có đưa học phí phụ huynh vào sản phẩm thật không? | Backend chưa có nghiệp vụ này: giữ trạng thái chưa khả dụng ở môi trường thật đến khi có hợp đồng riêng |
| P0-4 | Có cần nhắc con/đặt lịch/nhắn GV từ màn bài tập không? | Nhắn GV dùng API có sẵn khi xác định được `instructor_id` thật; hai hành động còn lại chưa có route nên không báo đã thực hiện |
| P1-1 | Mua khóa trả phí có thuộc phạm vi mobile đợt này không? | Hoàn tất enroll miễn phí trước; khóa trả phí không hiện CTA mua giả |
| P1-2 | Quy trình liên kết dùng email hay mã? | Backend hiện chỉ hỗ trợ email; dùng hợp đồng đó và bỏ form mã |
| P1-4 | Backend đang chạy có cùng revision DTO thông báo đã đọc không? | Sửa theo DTO backend trong repo; dùng response môi trường thử để xác nhận trước nghiệm thu |
| P2-4 | Có triển khai API tài liệu bài/khóa không? | Ẩn dữ liệu mẫu và nút tải giả trước; nếu triển khai, thiết kế route/DTO và quyền đọc |

## 8. Bảng theo dõi

| Mã | Trạng thái | Chủ sở hữu/PR | Bằng chứng nghiệm thu |
|---|---|---|---|
| P0-1 | [ ] | — | — |
| P0-2 | [ ] | — | — |
| P0-3 | [ ] | — | — |
| P0-4 | [ ] | — | — |
| P1-1 | [ ] | — | — |
| P1-2 | [ ] | — | — |
| P1-3 | [ ] | — | — |
| P1-4 | [ ] | — | — |
| P2-1 | [ ] | — | — |
| P2-2 | [ ] | — | — |
| P2-3 | [ ] | — | — |
| P2-4 | [ ] | — | — |
| P2-5 | [ ] | — | — |
