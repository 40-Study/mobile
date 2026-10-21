# Teacher UI — trạng thái triển khai

Cập nhật: 21/10/2026. Nhánh: `Thu/UI_Teacher`.

Tài liệu này phân biệt code đã triển khai và kiểm chứng với phạm vi còn lại trong [kế hoạch UI/UX](TEACHER_UI_UX_DESIGN_PLAN.md). Không xem toàn bộ kế hoạch là hoàn tất chỉ vì màn hình đã render được.

## Phân công và kết quả

| Phần | Phạm vi đã có code |
| --- | --- |
| Phase B — lõi giáo viên | Shell 5 tab; điều hướng đúng Teacher/TeacherApplicant; hồ sơ xét duyệt; chọn nơi làm việc cá nhân/tổ chức bằng phiên đăng nhập thật; hôm nay, lịch tuần/tháng; lớp, lịch định kỳ, buổi học; tạo buổi thật từ lịch dự kiến; điểm danh với bản nháp và trạng thái chưa đánh dấu. |
| Phase C — khóa học | Khóa học cá nhân, lọc/tìm kiếm/phân trang; tạo/sửa metadata, danh mục/tag; chương/bài/nội dung, sắp xếp; bài viết, video, quiz, bài lập trình và testcase; học viên; kiểm tra sẵn sàng, gửi/rút duyệt; khóa sửa khi chờ duyệt. |
| Phase D — lớp và thu nhập | Học viên/giáo viên lớp, quyền quản lý và phân công độc lập; bài tập, testcase, bài nộp; cột điểm, nhập/sửa điểm và feedback, tính/chốt tổng kết; ví cá nhân, giao dịch, ngân hàng, rút/hủy yêu cầu. Timeout rút tiền chặn gửi lặp. |
| Phase E — tích hợp bước đầu | Danh sách/tạo/bắt đầu/kết thúc phòng học; join bằng token LiveKit từ backend, camera/micro bật chủ động; thành viên, tắt micro/mời rời; chat buổi học, bảng nét vẽ tay và lưu snapshot; video upload theo chunk, tạm dừng/tiếp tục/xử lý; tin nhắn có WebSocket và chặn hội thoại; danh bạ học viên theo lớp hoặc khóa học cá nhân; thảo luận/hỏi đáp; cuộc thi quiz tạo/sửa/gửi duyệt và danh sách thí sinh. |

Code nằm trong `lib/features/teacher/`; các phase dùng chung Dio có xác thực và refresh token của ứng dụng. Request PUT đến presigned storage URL dùng Dio riêng, không gắn bearer của ứng dụng.

## Đợt UI/UX sau khi chia agent

Triển khai theo [kế hoạch xây dựng UI/UX](TEACHER_UI_UX_BUILD_PLAN.md), dùng ColorScheme, typography và spacing hiện có; hỗ trợ giao diện sáng/tối.

Đối chiếu bổ sung Student/Parent ngày 18/10: tách header Student hiện hữu thành `RoleAppHeader`; wrapper Student/Parent và shell Teacher cùng dùng component này. Giữ các callback/avatar/nhãn role, thay nền icon cố định của Parent bằng màu theme. Teacher dùng `SectionHeader` chung, có icon tab selected dạng filled; bộ chọn nơi làm việc nằm dưới header của 3 tab nghiệp vụ theo phạm vi. Header tự giãn theo cỡ chữ, không ép chiều cao toolbar.

Lượt đối chiếu native phát hiện tiêu đề dùng màu slate cố định khó đọc trong dark mode. Header chung đã chuyển sang `onSurface`/`onSurfaceVariant`, avatar dùng `primaryContainer`; Teacher khai báo màu status bar theo brightness và bỏ tiêu đề Hôm nay lặp. Đã xác nhận bố cục cuối bằng ảnh widget sáng/tối và test chữ gấp đôi, sau đó chụp lại native với các sửa tương phản và nội dung mới.

Đợt hoàn thiện nội dung theo phản hồi giao diện còn thô: Hôm nay tái sử dụng `CurvedSurfaceTray` của Student, tách `TeacherNextSessionCard`, bổ sung `TeacherSurface` và hàng tác vụ có icon/mô tả. Bộ chọn nơi làm việc có nền, chevron và vùng chạm toàn hàng; nhóm công cụ dùng cùng surface và typography. Giữ nguyên API, dữ liệu thật, quyền và bản nháp nghiệp vụ.

- Lịch/buổi học: ô ngày có trạng thái chọn rõ, lịch tháng nằm trong surface; agenda có số buổi; hàng buổi học có cột giờ, timeline và nhãn trạng thái. Bố cục tự chuyển dọc ở chữ lớn. Chi tiết buổi và điểm danh có các nhóm thông tin/học viên tách rõ.
- Lớp/bảng điểm: card lớp có icon, thông tin phụ và trạng thái; chi tiết lớp phân cấp tên/phạm vi/trạng thái. Khu vực chọn cột điểm và hàng học viên nằm trong surface, footer lưu dùng toàn chiều ngang; giữ phân biệt điểm 0 và chưa nhập, giữ các guard bản nháp.
- Khóa học/thu nhập: card khóa học có ảnh hoặc placeholder, badge semantic và số bài/học viên chỉ khi API trả dữ liệu. Ví có card số dư, nhóm ngân hàng, tổng quan và lịch sử; giữ khóa gửi lặp khi timeout.
- Harness visual có thêm chế độ chụp Student/Parent làm ảnh đối chiếu khi bật `TEACHER_CAPTURE=true`, không đưa dữ liệu fixture vào ứng dụng thật.
- Review native theo hai lượt có giới hạn: lượt đầu phát hiện tiêu đề Lịch dạy và bộ chuyển tháng bị lặp; đã gọn lại và hoàn thiện surface bảng điểm. Lượt xác nhận cuối chụp lại đủ 9 trạng thái, integration test đạt; không mở rộng thành nghiệm thu API/media/thanh toán thật.

## Bản thị giác và mock preview bổ sung

Theo yêu cầu làm đẹp hơn và cho phép mock data: thẻ buổi dạy dùng `primary/onPrimary`, giờ học nổi bật, nút hành động tương phản; thêm tóm tắt buổi dạy/hoàn thành từ dữ liệu lịch và hai shortcut Lớp/Soạn khóa học. Greeting dùng tên tài khoản hiện tại. Khóa học hỗ trợ ảnh asset cho preview; ảnh Python lấy từ asset có sẵn, các chủ đề khác giữ placeholder.

[Hướng dẫn bật mock preview](TEACHER_UI_PREVIEW.md): tạm thời bật sẵn ở dev để review giao diện đủ dữ liệu; `TEACHER_UI_PREVIEW=false` tắt mock, release luôn dùng API thật. Có nhãn dữ liệu mẫu; API mock có dữ liệu lớp/lịch/khóa học/điểm/ví và chặn mọi request ghi, endpoint chưa hỗ trợ không fallback API thật. Tab Tài khoản vẫn dùng tài khoản đăng nhập chung.

Đã chạy lại native harness với `TEACHER_UI_PREVIEW=true` trên iPhone 16 Plus Simulator: 1 integration test đạt, chụp đủ 9 trạng thái. Đã xem ảnh Hôm nay sáng/tối và khóa học có ảnh asset; các ảnh tại `/private/tmp/teacher-ui-native/` hiện phản ánh bản mock preview này. Đây là kiểm tra bố cục với dữ liệu mẫu, không phải nghiệm thu API thật.

## Làm lại card và nội dung bên trong lớp/khóa học

- Tăng độ tách nền: `TeacherSurface` dùng `surfaceContainerLowest` và viền `outlineVariant`; tên và số liệu dùng `onSurface`, giữ ý nghĩa màu sáng/tối.
- Card lớp có tên nổi bật, mô tả, trạng thái và metadata thật; footer “Xem lớp”. Card khóa học tách phần trạng thái, ảnh/tên/mô tả, số bài/học viên và footer giá/hành động; không dồn tất cả vào một hàng.
- Chi tiết lớp: header gọn, tab có nền chọn, panel tổng quan/giáo viên/lịch rõ ràng; hàng buổi học và học viên có cấu trúc riêng. Số liệu chưa có dùng dấu “—”, không diễn giải thành 0.
- Chi tiết khóa: cover và thông tin tổng quan, Giáo trình là tác vụ chính; quản lý thông tin/học viên và trạng thái xét duyệt thành các nhóm rõ. Giáo trình có card chương, số bài và thông tin từng bài; giữ nguyên quyền chỉ đọc và thao tác sắp xếp/xóa có xác nhận.
- Mock bổ sung giáo viên chính, lịch lặp, bài tập và 3 chương/7 bài để xem bố cục có dữ liệu. Harness native bổ sung danh sách lớp, chi tiết khóa và giáo trình; visual test thêm chi tiết sáng/tối, chữ gấp đôi.
- Lượt native mới nhất: 1 integration test đạt, chụp 12 trạng thái trên iPhone 16 Plus Simulator; đã xem trực tiếp card lớp, chi tiết lớp, chi tiết khóa và giáo trình. Các ảnh hiện tại trong `/private/tmp/teacher-ui-native/` phản ánh đợt làm lại card/chi tiết này. Giới hạn API thật/media/Android ở phần dưới vẫn giữ nguyên.

| Phần | Kết quả tích hợp |
| --- | --- |
| UI01 — tài khoản và shell | Tab cuối dùng `SharedAccountContent` chung với Student/Parent; giữ các mục riêng của từng role. Tài khoản vẫn mở được khi tải nơi làm việc lỗi, không mất trạng thái khi đổi nơi làm việc. Các tab nghiệp vụ chỉ khởi tạo khi truy cập. |
| UI02 — hôm nay và lịch | Ưu tiên buổi học kế tiếp, timeline gọn; lịch tuần/tháng, bộ lọc và menu nhắc lịch; điểm danh có footer lưu, xác nhận trước khi ghi đè hàng loạt và lựa chọn lưu/bỏ bản nháp khi rời màn hình. |
| UI03 — lớp | Chi tiết lớp có 5 tab trực tiếp: tổng quan, buổi học, học viên, bài tập, bảng điểm. Quản lý cột điểm có thêm/sửa/xóa/sắp xếp; giữ bản nháp điểm khi đổi tab. Quyền quản lý học viên và phân công giáo viên tách riêng. |
| UI04 — khóa học và thu nhập | Tìm kiếm/lọc, trạng thái trống có hướng xử lý, thumbnail; form có footer lưu và cảnh báo chưa lưu; chọn ngày giờ giảm giá bằng picker. Ví ưu tiên số dư, ngân hàng và rút tiền; truy cập từ khóa học. |
| UI05 — công cụ | Nhóm công cụ theo mục đích; CTA và trạng thái trống cho tin nhắn/thảo luận; refresh giữ focus và bản nháp hội thoại; ngày giờ dễ đọc và trạng thái reconnect phòng học. |
| UI06 — kiểm chứng | Có test chữ lớn/chiều rộng điện thoại và tablet, kiểm tra native iOS sáng/tối. Android và các luồng API thật còn các giới hạn bên dưới. |

## Quy tắc phạm vi và quyền

- Lớp/lịch được lọc theo nơi làm việc. Đổi nơi làm việc chỉ cập nhật giao diện sau khi API trả và lưu phiên mới; lỗi giữ phạm vi cũ. Danh sách tổ chức lấy đủ trang và chỉ nhận membership active.
- Khóa học và ví vẫn thuộc tài khoản cá nhân. Không diễn giải số dư ví thành lương/công dạy tổ chức.
- `can_manage`, `can_assign_teachers`, quyền sở hữu assignment và trạng thái lớp được kiểm tra riêng. Lớp lưu trữ chỉ đọc.
- Role trong phòng học do backend trả từ `/livestream/:id/join`; client không gửi role hoặc user_id để tự cấp quyền.
- Video đang xử lý chưa được dùng như video đã sẵn sàng. Resume yêu cầu chọn lại tệp gốc có tên và dung lượng tương ứng.

## Kiểm chứng

- Lượt chốt card/chi tiết: `flutter test --no-pub --dart-define=TEACHER_CAPTURE=true` **350/350 đạt** (348 test hồi quy và 2 lượt chụp đối chiếu Student/Parent). `flutter analyze --no-pub --no-fatal-infos` exit 0, không có error/warning, còn 1.189 lint mức info trong toàn dự án. Sau đó bổ sung kiểm tra contract mock buổi học trong lớp: 2/2 test preview đạt. `git diff --check` đạt.
- Có test theo phase và hồi quy cho phân trang/phạm vi, lịch dự kiến → buổi thật, điểm danh, trạng thái duyệt, quyền lớp, nhập điểm 0, timeout rút tiền, bearer chọn tổ chức, upload chunk/resume và lifecycle gửi tin.
- Bộ test mọi màn hình bổ sung fixture Teacher, kiểm tra render và dispose ở chiều rộng 360/390px; giữ nguyên kiểm tra mọi concrete Screen/Shell phải có fixture.
- Kiểm tra riêng Teacher sáng/tối, chữ lớn và ảnh render bằng font/icon ứng dụng. Ảnh fixture là bằng chứng bố cục, không thay thế kiểm thử với dữ liệu production.
- Build iOS Simulator flavor dev đã thành công. Lockfile giữ `connectivity_plus 7.0.0` và `device_info_plus 12.3.0`: các bản mới hơn kéo theo API Apple SDK mà Xcode trên máy chưa có. Không sửa mã package trong cache.
- Android debug đã thử với JDK hiện có, nhưng Gradle dừng ở `LicenceNotAcceptedException` cho `ndk;28.2.13676358`. Cần hoàn tất cấu hình/license Android SDK trên máy trước khi xác nhận APK.
- Integration test `integration_test/teacher_ui_review_test.dart` chạy đạt trên iPhone 16 Plus Simulator iOS 18.6. Chụp 9 trạng thái native: hôm nay sáng/tối, lịch, chi tiết lớp, bảng điểm có dữ liệu, khóa học, thu nhập, tài khoản sáng/tối. Ảnh tại `/private/tmp/teacher-ui-native/` chỉ là bằng chứng với fixture, có thể bị dọn khỏi máy.
- Đã sửa và kiểm tra lại bố cục email/nút sửa hồ sơ, tương phản đăng xuất tối và nhãn thông tin ứng dụng sau lượt xem ảnh đầu. Review cuối thực hiện trực tiếp; chưa có review độc lập vì giới hạn số agent. Tablet được kiểm tra bằng widget ở chiều rộng 1024px/chữ lớn, chưa chạy native iPad.
- Kết quả chạy cuối và hạn chế môi trường được báo cùng bàn giao; không cam kết các luồng thanh toán, media hay realtime đã được kiểm thử end-to-end với máy chủ thật.

## Còn lại trước khi nghiệm thu đầy đủ kế hoạch

- Chia sẻ màn hình từ điện thoại: cần foreground service/MediaProjection trên Android và quyết định broadcast extension trên iOS. Hiện nhận được video track do phía khác chia sẻ; chưa có nút phát chia sẻ màn hình.
- Bảng trắng mobile hiển thị nét vẽ tay và giữ các element khác khi lưu; chưa có đủ bộ công cụ Excalidraw. Backend chưa có thao tác compare-and-swap nguyên tử cho snapshot; kiểm tra version trước khi ghi chỉ giảm xung đột, không bảo đảm đồng bộ đồng thời tuyệt đối.
- Soạn bài viết dùng văn bản/HTML, chưa có trình soạn rich text. Video upload chạy khi màn hình còn mở; rời màn hình sẽ dừng, có thể chọn lại phiên để tiếp tục; chưa có background upload service.
- Bảng điểm tablet chưa cố định cột tên. Assignment testcase có thêm/xóa, chưa có import hàng loạt ở luồng công cụ lớp.
- Chưa có dashboard phân tích livestream chuyên biệt, lịch sử hoạt động đầy đủ hoặc mọi công cụ moderation của web.
- Cần nghiệm thu API thật: hai ngữ cảnh giáo viên, quyền trợ giảng/chủ lớp, dữ liệu nhiều trang, LiveKit hai thiết bị, mất mạng/reconnect, quyền camera/micro và upload video lớn; ví/rút tiền dùng môi trường thử nghiệm.


## Tách component và màn hình theo trách nhiệm — 21/10/2026

Tách card/header/panel lớp, card/header/action/review/giáo trình khóa học; chuyển các form editor nội dung/quiz/testcase và tổng kết điểm sang component độc lập. Màn chính giữ API, quyền, điều hướng và trạng thái bản nháp; component nhận dữ liệu/callback. Ví tách số dư/ngân hàng/tổng quan/lịch sử; tin nhắn, cuộc thi và bài tập tách màn con, giữ export tương thích đường import cũ. Không dùng `part` hay bổ sung dependency.

| File trong presentation | Trước | Sau format |
| --- | ---: | ---: |
| `classes/teacher_class_screen.dart` | 847 | 287 |
| `classes/teacher_classes_screen.dart` | 414 | 225 |
| `courses/teacher_courses_screen.dart` | 512 | 313 |
| `courses/course_detail_screen.dart` | 578 | 200 |
| `courses/course_outline_screen.dart` | 538 | 338 |
| `classes/tools/teacher_gradebook_screen.dart` | 541 | 292 |
| `courses/lesson_contents_screen.dart` | 576 | 218 |
| `courses/quiz_editor_screen.dart` | 555 | 246 |
| `courses/exercise_editor_screen.dart` | 432 | 209 |
| `earnings/teacher_earnings_screen.dart` | 521 | 220 |
| `advanced/teacher_messages_screen.dart` | 514 | 130 |
| `advanced/teacher_contests_screen.dart` | 514 | 100 |
| `classes/tools/teacher_assignment_screen.dart` | 506 | 193 |

Kiểm chứng: baseline 350/350 và sau refactor 350/350 test đạt với cùng lệnh `flutter test --no-pub --dart-define=TEACHER_CAPTURE=true`. Analyzer không error/warning; còn 1.189 info. 6 ảnh PNG gồm ví, bảng điểm, card khóa, chi tiết lớp/khóa và giáo trình giống hệt byte so với baseline. Không còn file presentation Teacher trên 500 dòng. Bốn file benchmark/fixture có thay đổi sẵn trước refactor được giữ nguyên hash.
