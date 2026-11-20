# Plan xây dựng UI/UX Teacher trên base hiện tại

Ngày cập nhật: 18/10/2026 · Nhánh: `Thu/UI_Teacher` · Trạng thái: đã triển khai đợt đầu; kết quả và giới hạn nghiệm thu trong `IMPLEMENTATION_STATUS.md`.

Đọc cùng [phạm vi backend](BACKEND_CAPABILITIES_AND_UI_SCOPE.md), [đặc tả nghiệp vụ](TEACHER_UI_UX_DESIGN_PLAN.md) và [trạng thái code base](IMPLEMENTATION_STATUS.md). Khi có khác biệt về tab cuối, vị trí chức năng và cách dùng theme, quyết định trong tài liệu này được ưu tiên.

## 1. Hướng thiết kế đã chốt

**Không gian giảng dạy gọn, sáng rõ và có nhịp điệu; mở app là thấy việc tiếp theo.** Sự trẻ trung đến từ phân cấp chữ, khoảng thở, nhịp timeline, ảnh học liệu thật và phản hồi nhanh. Màu thương hiệu và component vẫn thuộc system theme của 40Study.

- Hiện đại: màn hình ít tầng, hành động chính rõ, điều hướng theo tác vụ.
- Trẻ trung: tiêu đề gần gũi, bố cục thoáng, trạng thái chọn rõ; tránh cảm giác bảng quản trị thu nhỏ.
- Năng động: đưa buổi sắp dạy và việc đang làm lên trước; chuyển trạng thái nhanh, có phản hồi sau mỗi thao tác.
- Nhất quán: dùng cùng màu, font, input, button, sheet và thanh điều hướng với các role khác.
- Format chuẩn lấy từ giao diện Student/Parent hiện có: header icon tròn, nhãn role, tiêu đề và avatar; các role dùng chung `RoleAppHeader`. Teacher dùng `SectionHeader` chung cho các section và icon outlined/filled tương ứng trạng thái tab. Bộ chọn nơi làm việc nằm dưới header, chỉ xuất hiện ở Hôm nay/Lịch dạy/Lớp học; khóa học và ví thuộc cá nhân.
- Nội dung bên dưới cũng theo format hiện có: khay nội dung `CurvedSurfaceTray` của Student, card tác vụ bo góc 16, surface tách khỏi nền, hàng có icon/thông tin phụ và chevron, lịch dạng timeline và trạng thái gọn. Dùng màu semantic để giữ tương phản sáng/tối; không sao chép các màu slate cố định gây lỗi dark mode. Không tạo số liệu minh họa vào UI thật.
- Tab cuối dùng phần tài khoản chung; không tiếp tục phát triển một màn tài khoản Teacher độc lập.

Đây là trải nghiệm làm việc trên điện thoại. Không dùng banner quảng cáo, gradient trang trí, nền nhiều màu cho mọi icon, card lồng nhau hay animation tải trang nối tiếp để tạo cảm giác năng động.

## 2. Những gì đã có và cần đổi

| Hiện trạng đọc từ code | Hướng xử lý |
| --- | --- |
| Teacher đã có shell, màn nghiệp vụ và nhiều API thật | Phát triển UI từ base này, giữ contract/quyền/trạng thái đã kiểm tra |
| Student re-export widget tài khoản của Parent qua `student/presentation/profile/widgets/widgets.dart` | Tái sử dụng `ProfileCard`, `SwitchProfileSection`, `SettingsSection`, `GeneralSection`, `LogoutTile` và luồng auth sẵn có |
| Hai role đã chung widget nhưng vẫn có wrapper/layout và mục riêng | Chia sẻ phần tài khoản thực sự; giữ Portfolio của Student và Quản lý con của Parent trong wrapper của từng role |
| Teacher dùng `TeacherProfileScreen` và `TeacherRoleSwitcher` riêng | Thay bằng phần tài khoản chung; chỉ gỡ phần trùng sau khi các đường dẫn còn lại đã được chuyển và kiểm thử |
| Shell Teacher hiện chặn toàn giao diện nếu nơi làm việc tải lỗi | Giữ tab Tài khoản sử dụng được khi auth còn hợp lệ; lỗi nơi làm việc chỉ chặn các tác vụ phụ thuộc phạm vi |
| Một số tài liệu cũ và token radius không khớp component theme hiện chạy | Ưu tiên theme component và code hiện tại; không lấy bảng màu/bo góc lịch sử làm bộ thiết kế mới |

Nguồn đối chiếu: `lib/theme/style.dart`, `util.dart`, `app_spacing.dart`, `app_radius.dart`; shell/profile của Student, Parent và Teacher. Phạm vi Teacher mới là yêu cầu hiện tại; các mô tả giới hạn Student trong tài liệu thiết kế cũ không giới hạn plan này. Không tự sửa nhận diện toàn app.

## 3. Điều hướng và vị trí chức năng

Giữ 5 tab ổn định: **Hôm nay · Lịch dạy · Lớp học · Khóa học · Tài khoản**. Chuyển Cá nhân/Tổ chức không đổi thứ tự tab.

| Tab/điểm vào | Nội dung chính | Hành động ưu tiên |
| --- | --- | --- |
| Hôm nay | Buổi tiếp theo, lịch hôm nay, công việc cần chú ý có dữ liệu thật | Mở buổi / điểm danh |
| Lịch dạy | Tuần/tháng, danh sách buổi theo ngày | Xem và điều chỉnh buổi theo quyền |
| Lớp học | Lớp được phân công, học viên, bài tập, sổ điểm | Vào lớp đang dạy |
| Khóa học | Khóa cá nhân, giáo trình, duyệt, học viên, thu nhập | Tiếp tục soạn / tạo khóa |
| Tài khoản chung | Danh tính, đổi role, thông tin cá nhân, bảo mật, cài đặt, hỗ trợ, đăng xuất | Quản lý tài khoản bằng luồng chung |

### 3.1. Chuyển các mục đang nằm ở tài khoản Teacher

| Mục hiện có | Điểm vào chính sau điều chỉnh | Điểm vào phụ |
| --- | --- | --- |
| Nơi làm việc | Bộ chọn ở header các tab giảng dạy | Màn khôi phục khi membership/phạm vi lỗi |
| Hồ sơ nghề nghiệp | Hôm nay → Công việc giảng dạy → Hồ sơ giảng dạy | Khóa học → menu quản lý |
| Thu nhập, giao dịch, ngân hàng, rút tiền | Khóa học → Thu nhập cá nhân | Hôm nay → truy cập nhanh, khi có nhu cầu xem |
| Nhắc lịch dạy | Lịch dạy → menu → Nhắc lịch | Chi tiết buổi nếu contract cho phép cấu hình phù hợp |
| Phòng học trực tuyến | Chi tiết buổi/lớp | Hôm nay → Công cụ giảng dạy |
| Upload video | Soạn nội dung video trong bài học | Khóa học → quản lý phiên tải |
| Tin nhắn | Hôm nay → Hộp thư | Học viên trong lớp → Nhắn tin |
| Hỏi đáp | Bài học hoặc công cụ giảng dạy | Danh sách thảo luận chung, ghi rõ phạm vi |
| Cuộc thi | Khóa học → menu → Cuộc thi của tôi | Công cụ giảng dạy |

Không biến Hôm nay thành lưới icon. Truy cập nhanh hiển thị tối đa 3 tác vụ có ích; các mục còn lại vào một danh sách công cụ. Khóa học và ví luôn ghi rõ thuộc cá nhân dù đang chọn tổ chức.

### 3.2. Tab cuối dùng chung như thế nào

Thứ tự nội dung: thông tin người dùng → đổi vai trò → thông tin cá nhân/bảo mật → cài đặt/hỗ trợ/giới thiệu → đăng xuất. Giữ hành vi tải lại, lỗi, xác nhận và cập nhật dữ liệu như các role đang dùng.

Kế hoạch tái sử dụng:

1. Dùng lại widget profile đang chung giữa Student/Parent và `ProfileCubit`, `AccountCubit`, `AuthBloc`, `AuthRepository` hiện có.
2. Rút phần nội dung tài khoản chung thành một `SharedAccountContent` hoặc màn tương đương trong vùng dùng chung. Chốt tên theo cấu trúc repo khi implement, không dựng registry/provider mới.
3. Wrapper Student giữ phần riêng của Student; wrapper Parent giữ phần riêng của Parent; Teacher dùng phần chung với nhãn role trung tính phù hợp.
4. Phần chung không import Teacher API, nơi làm việc, ví hoặc bloc học tập của Student/Parent. Provider tài khoản đặt ở ranh giới phần tài khoản; không khởi tạo lại theo revision của tổ chức.
5. Không chép nguyên `ProfileScreen` Student sang Teacher: màn này còn header “TÀI KHOẢN HỌC VIÊN” và Portfolio. Không chép nguyên Parent vì có Quản lý con.
6. Tạm giữ đường import cũ qua export nếu chuyển vị trí widget; không đổi giao diện Student/Parent ngoài phần bắt buộc để dùng chung.

Đổi role và đổi nơi làm việc là hai tác vụ khác nhau. Chỉ đổi shell khi phiên mới đã lưu thành công. Không tạo một flow đổi role thứ ba riêng cho Teacher.

## 4. Dùng đúng system theme

### 4.1. Màu và bề mặt

| Vai trò thị giác | Token sử dụng | Cách dùng |
| --- | --- | --- |
| Nền trang | `colorScheme.surface` | Nền sáng/tối theo app |
| Khối cần phân biệt | `surfaceContainerLowest` / `surfaceContainerLow` | Buổi tiếp theo, vùng biên tập; dùng có chọn lọc |
| Chữ chính/phụ | `onSurface` / `onSurfaceVariant` | Chữ phụ vẫn phải đủ tương phản ở cỡ sử dụng |
| Hành động và lựa chọn | `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer` | CTA, ngày chọn, tab đang hoạt động |
| Thành công/đang diễn ra | Cặp semantic phù hợp từ theme, ưu tiên `secondary` và container tương ứng | Luôn kèm nhãn chữ; không suy “đang diễn ra” thành xanh lá cho mọi màn |
| Cần chú ý | `tertiary` và container tương ứng | Quá giờ/chờ xử lý có căn cứ |
| Lỗi/nguy hiểm | `error`, `errorContainer`, màu chữ tương ứng | Lỗi form, hủy/xóa có xác nhận |
| Đường ngăn | `outlineVariant` / `outline` | Nhóm danh sách, input và focus theo theme |

`style.dart` hiện dùng primary sáng `#3D5FC4`, primary tối `#BAC8FF`; đây chỉ là giá trị tham chiếu, **UI đọc token, không chép hex**. Không bật Dynamic Color riêng cho Teacher khi toàn app chưa có quyết định đó.

### 4.2. Chữ, khoảng cách, hình dạng

- Giữ font đã khai báo của app; lấy từ `Theme.of(context).textTheme`.
- Tên trang dùng `headlineMedium` hoặc app bar `titleLarge`; tên buổi/lớp dùng `titleMedium`; mô tả dùng `bodyMedium`; metadata dùng `bodySmall` khi vẫn đọc được. Không đặt cỡ chữ riêng cho từng screen để ép vừa.
- Lề trang chuẩn `AppSpacing.screenPadding` = 24; hàng dữ liệu dày có thể dùng `lg` = 16 trong phạm vi đã quy định. Khoảng trong nhóm 8/12/16; giữa nhóm 24/32.
- Dùng `FilledButton`, `OutlinedButton`, `TextButton`, `TextFormField`, `NavigationBar`, `NavigationRail` theo component theme. Không override shape của button/input tại từng màn.
- Component theme đang có card 8, button/input 8, dialog 12; `AppRadius.button/input` cũ còn 4. Khi dùng component Material thì theme của component là chuẩn. Không sửa token toàn app trong đợt Teacher để “đồng bộ” bằng mọi giá.
- Card chỉ cho một nhóm có lý do; danh sách dùng hàng + khoảng cách/đường ngăn. Không bọc từng đoạn text thành card.
- Icon cùng họ Material hiện tại: outlined ở trạng thái thường, selected/filled nếu theme hỗ trợ. Không trộn emoji hoặc thư viện icon mới.

### 4.3. Chuyển động và cảm giác thao tác

- Push/back, sheet và chọn ngày theo chuyển động native/Material hiện có.
- Chuyển trạng thái cục bộ khoảng 150–250ms là mục tiêu thiết kế, không rải `Duration` mới vào mọi widget; reuse hằng hiện có khi phù hợp.
- Chọn tab/scroll không chờ animation hoàn tất mới cho thao tác kế tiếp; chặn riêng thao tác đang ghi dữ liệu.
- Tôn trọng Reduce Motion/Remove Animations. Không confetti, rung, pulsing badge hay thanh tiến độ giả.

## 5. Đặc tả từng nhóm màn hình

### 5.1. Hôm nay — có một điểm tập trung

Thứ tự: header nơi làm việc + hộp thư → ngày/lời chào ngắn → buổi tiếp theo → lịch hôm nay → việc cần chú ý → truy cập nhanh/công cụ.

Buổi tiếp theo là khối nổi bật duy nhất: giờ lớn vừa đủ, tên lớp, chủ đề, nhãn trạng thái và CTA “Xem buổi học”. Sau khi mở buổi, điểm danh/phòng học xuất hiện theo trạng thái và quyền. Khối nổi bật dùng surface/viền nhẹ; không thêm hero gradient.

Để giảm lặp, cùng một buổi trong timeline là hàng ngắn; không lặp toàn bộ mô tả và CTA như khối nổi bật. “Việc cần chú ý” chỉ có số lượng được API xác nhận; thiếu API tổng hợp thì hiện các tác vụ đã biết hoặc bỏ mục, không tự dựng số.

```text
[Cá nhân / Tên tổ chức ▾]                    [Hộp thư]
Chào Thu                       Thứ ..., ngày ...
Hôm nay

Buổi tiếp theo
14:00–15:00 · Tên lớp
Chủ đề · Trạng thái
[Xem buổi học]

Lịch hôm nay                                  Xem lịch
14:00  Tên lớp                        Đã lên lịch
16:00  Tên lớp                        Đã lên lịch

Truy cập nhanh / Công cụ giảng dạy
...
[Hôm nay] [Lịch dạy] [Lớp học] [Khóa học] [Tài khoản]
```

Wireframe minh họa cấu trúc, giờ/tên không phải dữ liệu sẽ gắn cứng vào sản phẩm.

### 5.2. Lịch dạy và buổi học

- Mở mặc định tuần hiện tại; hàng ngày có hôm nay được nhận biết riêng với ngày đang chọn. Tháng là chế độ phụ.
- Giữ ngày chọn khi xem buổi rồi quay lại. Nút “Hôm nay” khôi phục nhanh; filter lớp dùng sheet khi danh sách dài.
- Agenda bên dưới ưu tiên giờ → lớp → chủ đề → trạng thái. Lịch dày không biến thành nhiều card cao.
- Lịch trống ghi đúng “Không có buổi trong ngày này”; có quyền thì đề xuất tạo, không có quyền thì gợi ý xem ngày khác.
- Buổi dự kiến phải tạo/nhận ID thật trước tác vụ cần session. Ghi rõ buổi quá giờ chưa bắt đầu; không tự coi là đã kết thúc.
- Chi tiết buổi: thông tin chính trên đầu, sau đó điểm danh/phòng học/học viên. Sửa/hủy vào menu; kết thúc/hủy có xác nhận hệ quả.
- Nhắc lịch mở từ menu Lịch dạy; không đặt một công tắc có vẻ áp dụng cho mọi role trong tài khoản chung.

### 5.3. Điểm danh — nhanh nhưng không ghi nhầm

- Header lớp/ngày, số đã đánh dấu trên tổng số, danh sách học viên có tìm kiếm.
- Một hàng gồm avatar fallback, tên và control trạng thái có nhãn. Trạng thái mặc định là “Chưa đánh dấu”.
- “Đánh dấu tất cả có mặt” là thao tác phụ, xác nhận khi ghi đè các lựa chọn đã có; không tự lưu khi chọn.
- Thanh lưu gắn đáy, nằm trên safe area/bàn phím khi cần; thể hiện số thay đổi và trạng thái đang lưu.
- Lưu lỗi giữ toàn bộ lựa chọn; rời màn/đổi nơi làm việc có bản sửa thì cho Lưu / Bỏ thay đổi / Ở lại.

### 5.4. Lớp học và chi tiết lớp

- Danh sách ưu tiên lớp đang phụ trách: tên, nguồn Cá nhân/Tổ chức, vai trò Chính/Trợ giảng và thông tin đã có từ server. Không giả số học viên.
- Search phía trên, bộ lọc trạng thái thu gọn; tên dài được xuống dòng. Nút tạo chỉ xuất hiện khi có quyền đã xác nhận.
- Chi tiết lớp gom tác vụ thành **Tổng quan · Buổi học · Học viên · Bài tập · Bảng điểm**. Điện thoại dùng tab cuộn có nhãn, tránh lồng nhiều tầng navigation.
- Tổng quan đưa buổi gần nhất và thao tác liên quan lên trước; thông tin hành chính xuống dưới.
- Quản lý học viên và phân công giáo viên nằm đúng mục; tách quyền `can_manage` và `can_assign_teachers`.
- Lớp lưu trữ có nhãn cố định và giải thích chỉ đọc. Không để nút cho phép sửa rồi mới báo 403 nếu UI đã biết không có quyền.

### 5.5. Bài tập, bài nộp và sổ điểm

- Danh sách bài tập: tên → hạn nộp → trạng thái xuất bản. Hạn nộp không chỉ dùng màu; ghi ngày/giờ cụ thể.
- Chi tiết bài tách đề, testcase và bài nộp. Khi soạn đề dùng form theo nhóm, có preview trước xuất bản.
- Màn bài nộp ưu tiên học viên/trạng thái/kết quả; mở một bài mới thấy code và chi tiết chấm, không nhồi tất cả vào danh sách.
- Điện thoại: sổ điểm theo từng học viên, chọn cột để nhập nhanh, bàn phím số và next-field hợp lý. Ô trống khác điểm 0.
- Tablet: bảng có tên học viên cố định, cuộn cột và header rõ; không thu nhỏ bảng desktop để nhét vào điện thoại.
- Cột điểm cần luồng thêm/sửa/xóa/sắp xếp có quyền và xác nhận hệ quả; verify contract trước khi bổ sung phần base chưa có.
- Lưu nháp, tính tổng kết, chốt tổng kết là các trạng thái riêng. Không khiến nút “Tính” trông như “Đã chốt”.

### 5.6. Khóa học, giáo trình và hồ sơ giảng dạy

- Màn danh sách có nhãn “Khóa học cá nhân”, tìm kiếm, trạng thái và entry “Thu nhập cá nhân” dễ thấy. Bộ lọc trên màn hẹp phải cuộn được hoặc mở sheet có lựa chọn đang dùng.
- Hàng khóa: thumbnail từ học liệu thật nếu có, tên, trạng thái, thông tin ngắn; fallback trung tính nếu chưa có ảnh. Không thêm ảnh trang trí không liên quan.
- Một CTA chính: “Tạo khóa học”. Từng khóa có “Tiếp tục soạn” khi phù hợp; không tạo thêm FAB thứ hai.
- Chi tiết khóa gom Thông tin / Giáo trình / Học viên; trạng thái duyệt và hành động tiếp theo xuất hiện trước nội dung dài.
- Giáo trình thể hiện Chương → Bài → Nội dung rõ bằng indent, tên và loại nội dung; thao tác ít dùng trong menu. Có nút lên/xuống để thay thế kéo thả cho accessibility.
- Soạn thảo là màn đầy đủ; chia nhóm Tên/nội dung, Cấu hình, Xem trước. Rich text là việc cần phát triển thêm trên base HTML, không mô tả là đã có.
- Video: chọn tệp → tiến độ thật → máy chủ xử lý → sẵn sàng. Chỉ bật “Dùng video” khi ready; phiên lỗi có tiếp tục/xử lý lại đúng trạng thái API.
- Gửi duyệt có checklist và link đưa tới chỗ thiếu. Chờ duyệt khóa sửa có lý do; bị từ chối hiển thị phản hồi và cách sửa.
- Hồ sơ giảng dạy dùng form nghề nghiệp riêng từ Công việc giảng dạy, không nhập chung vào form sửa danh tính của tài khoản.

### 5.7. Thu nhập và nhận tiền

- Màn độc lập mở từ Khóa học, tiêu đề “Thu nhập cá nhân”. Số dư khả dụng là thông tin chính; các số khác là hàng dữ liệu.
- Ngân hàng hiển thị số đã che, có sửa thông tin và xác nhận đúng người nhận; không lộ dữ liệu nhạy cảm khi xem hồ sơ công khai.
- Rút tiền: nhập → rà lại số tiền/ngân hàng → xác nhận → trạng thái thật. Không báo thành công trước phản hồi server.
- Khi timeout: giữ trạng thái chưa rõ kết quả, hướng dẫn xem lịch sử, chặn gửi lặp. Không dùng snackbar biến mất làm thông tin duy nhất.
- Không gọi doanh thu khóa học là lương tại tổ chức.

### 5.8. Công cụ nâng cao và ứng viên

- Hộp thư, hỏi đáp, cuộc thi nằm ở các điểm vào mục 3; có tiêu đề nguồn lớp/bài học khi thực sự gắn nguồn đó.
- Phòng học: trạng thái kết nối rõ; camera/micro mặc định tắt, mỗi control có nhãn truy cập. Rời phòng và kết thúc cho cả lớp là hai hành động riêng.
- Chia sẻ màn hình, background upload và bộ công cụ bảng trắng đầy đủ phải tách thành task native/contract riêng; không bật control giả để hoàn thiện hình thức.
- Teacher Applicant có màn theo dõi xét duyệt, CTA sửa/nộp lại đúng trạng thái và lối vào tài khoản chung để đổi role/đăng xuất. Không hiển thị như Teacher đã được duyệt.

## 6. Trạng thái và dữ liệu thực tế

| Trạng thái | Cách thể hiện và hành động |
| --- | --- |
| Lần đầu tải | Placeholder theo bố cục; không nháy empty state trước khi có kết quả |
| Tải thêm/refresh | Giữ nội dung hiện có, báo tiến độ cục bộ; không khóa toàn trang |
| Empty thật | Giải thích ngắn + hành động phù hợp quyền |
| Không khớp filter | Cho xóa filter; không gợi ý tạo dữ liệu như chưa từng có |
| Lỗi một vùng | Retry tại vùng đó; tài khoản và điều hướng còn dùng được khi auth hợp lệ |
| Đang lưu | Khóa đúng thao tác ghi, giữ nội dung, chặn submit lặp |
| Lưu thành công | Cập nhật dữ liệu + phản hồi ngắn; không reset form trước khi xác nhận |
| Chưa lưu | Hiển thị rõ; có guard khi back, đổi scope, đổi role hoặc đăng xuất |
| Quyền bị thu hồi/dữ liệu bị xóa | Dừng sửa, thông báo và tải lại/đi về danh sách; không biến thành danh sách rỗng vô cớ |
| Phiên hết hạn | Dùng auth flow chung; không dựng màn đăng nhập riêng trong Teacher |

Data thiết kế phải có tên tiếng Việt dài, không có avatar, 0/1/nhiều mục, nhiều tổ chức, lớp trùng tên, số dư lớn, đề dài và lỗi API. Badge/số lượng chỉ xuất hiện khi đã có nguồn dữ liệu xác nhận; trạng thái privacy và quyền lấy từ backend.

## 7. Component và trách nhiệm

| Phần | Nên dùng chung | Giữ riêng Teacher |
| --- | --- | --- |
| Tài khoản | Cụm profile hiện có, đổi role và luồng auth | Không giữ màn tài khoản nghiệp vụ riêng |
| Theme/layout | ColorScheme, TextTheme, AppSpacing, component theme, input/button/sheet | Header có context nơi làm việc |
| Nội dung | Primitive loading/error/empty, hàng danh sách nếu có component phù hợp | Session row, lớp, điểm danh, curriculum item, grade editor |
| Trạng thái | Auth/account theo hệ thống hiện tại | Scope, ngày/bộ lọc, bản nháp theo tài nguyên |

Không tạo `TeacherButton`, `TeacherTextField` hay `TeacherColors` để bọc lại Material. Chỉ tách component khi có trách nhiệm rõ, nhiều chỗ dùng hoặc cần quản lý lifecycle riêng; không chia mỗi hàng text thành một file.

## 8. Responsive, accessibility và hiệu năng

- Điện thoại 360/390/430dp: một cột, 5 destination có label; tối đa một vùng cuộn chính và một thanh hành động đáy.
- 600–839dp: giới hạn chiều rộng form, tăng khoảng thở; không tự kéo mọi đoạn text phủ cả màn.
- Từ 840dp: rail; list-detail cho lớp/lịch khi có lợi; form tối đa khoảng 760dp theo base. Account chung dùng layout của hệ thống.
- Tối thiểu 48dp vùng chạm trên Android; bảo đảm tối thiểu 44pt trên iOS. Nếu global icon theme mới có 44 thì tăng vùng hit ở component Teacher cần thiết, không thu nhỏ theo icon.
- Kiểm font scale 1.0/1.3/2.0, TalkBack/VoiceOver, thứ tự focus và đọc nhãn trạng thái. Tương phản mục tiêu WCAG AA: text thường 4.5:1, text lớn/control quan trọng 3:1; đo cả hai theme.
- Bàn phím không che lỗi hoặc nút lưu; ngày/giờ native, nội dung số không bắt gõ định dạng kỹ thuật.
- Giữ tab/scroll/bộ lọc khi đi sâu rồi quay lại. Scope mới vô hiệu hóa dữ liệu đúng phạm vi; phần account không bị reset theo org.
- Danh sách dài render lazy, phân trang thật; request không lặp chỉ vì rebuild. Không tải cả 5 tab nặng trước khi người dùng mở nếu chưa cần.
- Ảnh tối ưu kích thước; skeleton không nhấp nháy kéo dài. Đánh giá jank trên thiết bị; không suy hiệu năng từ test widget.

## 9. Lộ trình triển khai UI trên base

Không dùng lại tên B/C/D/E của đợt dựng base để tránh hiểu lầm các đợt đó đã hoàn tất thiết kế.

| Đợt | Công việc cụ thể | Điều kiện hoàn tất |
| --- | --- | --- |
| UI-01 · Tài khoản chung + shell | Chốt shared account content/provider, wrapper role; chuyển các entry nghiệp vụ; Account vẫn mở khi scope lỗi; header/nav đúng theme | Teacher dùng được luồng account chung; Student/Parent không hồi quy; không còn entry bị mất sau di chuyển |
| UI-02 · Hôm nay + lịch + điểm danh | Bố cục focus/timeline, tuần-tháng, session action, sticky save, guard dữ liệu chưa lưu | Hành trình vào điểm danh ≤3 lần chạm từ Hôm nay; failure không mất bản nháp |
| UI-03 · Lớp + bài tập + điểm | Danh sách/chi tiết theo nhóm, roster/quyền, bài nộp, nhập điểm mobile; bổ sung quản lý cột theo contract | Phân biệt trống/0; thao tác có quyền đúng; lớp archive chỉ đọc; thử dữ liệu dài |
| UI-04 · Khóa + học liệu + thu nhập | List khóa, curriculum/editor/preview/review, video processing, hồ sơ giảng dạy, wallet entry mới | Soạn → gửi duyệt và mở ví có đường đi rõ; trạng thái chờ/lỗi/timeout đúng |
| UI-05 · Công cụ nâng cao | Tin nhắn/hỏi đáp/contest và room theo style thống nhất; task native cho screenshare/thiết bị | Nghiệm thu phần đã tích hợp trên backend thật; tính năng chưa sẵn sàng không có CTA giả |
| UI-06 · Hoàn thiện và nghiệm thu | Responsive, dark/light, chữ lớn, a11y, giảm request/rebuild, đo trên thiết bị | Ma trận kiểm tra dưới đây đạt và có bằng chứng; ghi rõ phần chưa đạt |

Mỗi đợt làm trọn một hành trình: layout → component reuse → state → API/quyền → test → ảnh thiết bị → review. Không thay backend contract để làm vừa bản vẽ. Không đổi theme toàn app như một tác dụng phụ của đợt Teacher.

## 10. Checklist bàn giao

- [ ] Tab cuối Teacher dùng phần tài khoản chung; không có Portfolio học viên hoặc Quản lý con.
- [ ] Account vẫn mở khi org discovery lỗi; auth hết hạn đi luồng chung.
- [ ] Đổi role/scope có loading, xử lý lỗi, guard bản nháp và session thực; không chỉ đổi nhãn.
- [ ] Các công cụ Teacher sau khi chuyển vị trí đều có đường vào rõ; không link chết.
- [ ] Hôm nay cho biết buổi tiếp theo và không lặp nguyên hai khối nội dung.
- [ ] Mọi màn có loading/empty/error/readonly/saving phù hợp, không dùng data mẫu trong production.
- [ ] Theme sáng/tối dùng đúng token, chữ lớn không tràn, không có màu Teacher riêng.
- [ ] Nút chính, chip, input, sheet và bottom navigation nhất quán với hệ thống.
- [ ] Các kiểm thử auth/role của Student/Parent và 317 test baseline được chạy lại; số test hiện tại không thay cho nghiệm thu UI.
- [ ] Bổ sung test account dùng chung, scope lỗi vẫn vào account, di chuyển entry, giữ draft, permission và filter/pagination.
- [ ] Ảnh nghiệm thu từ iOS Simulator/Android emulator hoặc thiết bị: phone compact, phone thường, tablet nếu phát hành; light/dark, font lớn, bàn phím. Widget capture chỉ bổ trợ.
- [ ] Kiểm API thật bằng Teacher cá nhân và Teacher tổ chức, ít nhất một tài khoản nhiều scope và một tài khoản quyền hạn chế.
- [ ] Media/realtime và tài chính có kiểm thử riêng với môi trường phù hợp; ghi rõ Android NDK/license và các blocker môi trường nếu chưa giải quyết.

Ưu tiên bắt đầu bằng **UI-01**, tiếp đến **UI-02** để chốt tài khoản chung và một hành trình dạy học hoàn chỉnh trước khi mở rộng toàn bộ bề mặt.
