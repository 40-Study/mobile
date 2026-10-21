# Kế hoạch thiết kế UI/UX — Role Giáo viên

- Dự án: 40Study Mobile, Flutter trên iOS/Android.
- Ngày lập: 14/10/2026.
- Trạng thái: đề xuất chi tiết để thiết kế và triển khai; chưa phải giao diện đã nghiệm thu.
- Cập nhật 17/10/2026: dùng [plan xây dựng UI trên base hiện tại](TEACHER_UI_UX_BUILD_PLAN.md) cho các quyết định mới về tài khoản chung, vị trí công cụ, system theme và thứ tự triển khai UI.
- Phạm vi: toàn bộ Teacher, cân bằng dạy lớp hằng ngày và quản lý khóa học cá nhân; phân biệt rõ Cá nhân/Tổ chức.
- Đầu vào: [Đối chiếu backend và phạm vi giao diện](BACKEND_CAPABILITIES_AND_UI_SCOPE.md).
- Mã nguồn đối chiếu: backend local `main`, commit `97c29a8`; mobile đang ở `tung/refactor_UI_Student` khi lập tài liệu. Khảo sát tĩnh, chưa kiểm thử API đang chạy.
- Tài liệu này đặc tả thiết kế và điều kiện triển khai, không thay đổi backend, code UI hoặc nhánh Git.

## 1. Mục tiêu trải nghiệm

Giáo viên mở app và biết ngay buổi sắp dạy, lớp mình phụ trách và thao tác cần làm. Người dạy tự do còn cần quản lý giáo trình, tình trạng duyệt khóa và thu nhập cá nhân mà không bị lẫn với hoạt động của tổ chức.

Ba hành trình phải trơn tru từ đầu:

1. Hôm nay → buổi sắp dạy → danh sách học viên → điểm danh → lưu kết quả.
2. Lớp học → bài tập/kiểm tra → bài nộp/kết quả → bảng điểm.
3. Khóa của tôi → giáo trình → soạn nội dung → kiểm tra điều kiện → gửi duyệt.

Các mục tiêu kiểm thử UX, chưa phải số liệu đo được:

- Từ Hôm nay tới màn điểm danh của buổi kế tiếp trong tối đa 3 lần chạm, khi đã đăng nhập và có dữ liệu.
- Nhận ra lớp thuộc cá nhân hay tổ chức ngay ở danh sách và màn chi tiết.
- Biết dữ liệu đã lưu hay chưa; không mất bản sửa chỉ vì đổi tab hoặc đổi nơi làm việc.
- Hiểu vì sao khóa đang chờ duyệt/lớp lưu trữ không sửa được và có hành động tiếp theo rõ ràng.
- Các tác vụ chính sử dụng được ở màn 360dp và khi tăng cỡ chữ.

## 2. Người dùng và hai phạm vi làm việc

| Tình huống | Nhu cầu chính | Điều cần tránh |
|---|---|---|
| Giáo viên tự do | Soạn khóa, quản lý lớp cá nhân, dạy học, theo dõi doanh thu khóa | Đưa toàn bộ màn quản trị tổ chức vào app |
| Giáo viên trong tổ chức | Biết lớp được phân công, lịch dạy, học viên, bài tập, điểm danh và bảng điểm | Coi thành viên tổ chức là người có toàn quyền quản trị |
| Vừa tự do vừa thuộc tổ chức | Chuyển phạm vi dễ nhận biết; giữ tách dữ liệu | Gộp lớp và thu nhập mà không ghi nguồn |
| Tham gia nhiều tổ chức | Chọn đúng đơn vị, không sửa nhầm lớp | Chỉ phân biệt bằng màu hoặc logo |
| Ứng viên giáo viên | Hoàn thiện hồ sơ, theo dõi duyệt, sửa và nộp lại | Hiển thị dashboard dạy học như đã được duyệt |

### 2.1. Không tạo hai ứng dụng Teacher riêng

Dùng chung shell và hệ thống component. Sự khác nhau nằm ở dữ liệu, quyền trên tài nguyên, nội dung ưu tiên và thao tác được phép. Không nhân đôi cả màn lịch, điểm danh hoặc bảng điểm chỉ để đổi tên tổ chức.

Phải phân biệt ba khái niệm:

- **Vai trò:** Teacher / Teacher Applicant / Student / Parent. Đổi vai trò ở Tài khoản.
- **Ngữ cảnh đăng nhập:** Cá nhân hoặc tổ chức đang hoạt động; đổi qua luồng backend cấp lại token.
- **Bộ lọc màn hình:** lớp/ngày/trạng thái. Chọn bộ lọc không tự thay đổi quyền hoặc token.

### 2.2. Quy tắc Cá nhân/Tổ chức theo dữ liệu backend thực tế

| Miền dữ liệu | Phạm vi thực tế | Quy tắc UX |
|---|---|---|
| Lớp | Có `organization_id`, nullable | Lớp cá nhân có nhãn Cá nhân; lớp tổ chức có tên tổ chức |
| Lịch dạy | Trả lớp được phân công; mỗi mục có `class_id` | Ánh xạ lớp để xác định phạm vi; không tự đoán tổ chức từ tên lớp |
| Quyền lớp | Có capability ở chi tiết lớp | Dùng `can_manage`, `can_assign_teachers` cùng trạng thái lớp |
| Khóa học | Gắn instructor, chưa có ownership tổ chức trong contract đã đọc | Ghi rõ Khóa cá nhân/Khóa của tôi; không tự đổi thành kho khóa tổ chức |
| Ví Teacher | Thu nhập của instructor cá nhân | Luôn ghi Thu nhập cá nhân; không gọi là lương tổ chức |
| Bài tập/điểm | Theo lớp, phiên hoặc khóa tương ứng | Hiện lớp/khóa nguồn trên màn chi tiết |

**Bộ chọn nơi làm việc không phải cơ chế tự động tách tất cả API.** Backend có `POST /auth/select-org`, nhưng `classes/me`, timetable và courses/mine chưa đồng nhất bộ lọc tổ chức. Không triển khai bộ chọn toàn app chỉ bằng thay nhãn header.

Quyết định triển khai:

1. Giữ lựa chọn Cá nhân/Tổ chức là ngữ cảnh thật của đăng nhập, không phải cờ quyền lưu riêng trên client.
2. Ở Lớp/Lịch/Hôm nay, lọc theo tập lớp đã xác định được `organization_id` và có dữ liệu đầy đủ. `classes/me` hiện trả lớp được phân công, có thể làm nguồn cho tập đó.
3. Không lọc một trang kết quả rồi dùng số dòng còn lại làm tổng. Với danh sách phân trang cần thêm filter backend hoặc cách nạp đầy đủ được thống nhất trước.
4. Khóa học và Thu nhập giữ nhãn Cá nhân kể cả khi đang ở tổ chức. Hiện một dòng phạm vi ngắn; thao tác cá nhân không được gửi thêm `organization_id` để giả lập sở hữu tổ chức.
5. Nếu thiếu ánh xạ lớp/tổ chức, hiển thị trạng thái chưa tải được phạm vi và thử lại; không mặc định lớp đó là Cá nhân.
6. Nếu chưa nối được hợp đồng dữ liệu phân phạm vi, bản UI đó phải giữ ở prototype; không phát hành trạng thái đã lọc giả.

### 2.3. Quyền sở hữu và quyền được phân công

- Chủ khóa có thể chỉnh khóa của mình theo trạng thái duyệt.
- Giáo viên lớp có thể quản lý nghiệp vụ lớp trong phạm vi backend cho phép.
- Gán/gỡ giáo viên là quyền khác với quản lý lớp. Không suy từ `can_manage` sang `can_assign_teachers`.
- Nhãn Giáo viên chính/Trợ giảng mô tả phân công; không dùng nhãn này làm luật phân quyền độc lập.
- Lớp archived có thể đọc; các thao tác ghi bị khóa theo trạng thái.
- Ẩn hành động không có quyền. Với hành động bị khóa tạm do trạng thái, giải thích nguyên nhân và đưa đường xử lý khi có quyền.
- Backend là nơi quyết định cuối. Xử lý 403/404/409 ngay cả khi nút đã được kiểm ở client.

## 3. Phong cách giao diện

### 3.1. Kế thừa nhận diện hiện tại

Dùng giao diện phẳng, tiết chế của nhánh Student hiện tại: bề mặt sáng/tối theo theme, chữ rõ, xanh thương hiệu cho hành động và lựa chọn đang hoạt động. Không lấy nguyên các trang Parent cũ nhiều thẻ làm mẫu cho Teacher.

- Dùng typography, spacing, radius và color role hiện có; không dựng một bộ màu Teacher riêng.
- Không gradient trang trí, bóng đổ nặng, nền màu cho mọi icon hoặc thẻ lồng nhiều tầng.
- Danh sách, timeline và khối có đường ngăn là cấu trúc chính. Một khối nổi bật cho buổi sắp dạy là đủ ở Hôm nay.
- Badge luôn có chữ: Chờ duyệt, Đã lưu trữ, Trợ giảng… Màu chỉ bổ trợ.
- Một hành động chính trên mỗi màn. Menu ba chấm cho thao tác ít dùng.
- Trạng thái học vụ không dùng màu như thành tích trò chơi. Chưa điểm danh là trạng thái thiếu dữ liệu, không tự biểu diễn thành vắng.

### 3.2. Kích thước và bố cục

| Hạng mục | Quy tắc dự kiến |
|---|---|
| Khoảng cách | Dùng thang 4/8/12/16/24/32 của `AppSpacing` |
| Lề điện thoại | Theo `AppSpacing.screenPadding` 24dp; hàng dữ liệu dày có thể dùng `lg` 16dp theo layout đã chốt |
| Bo góc | Dùng component theme hiện chạy: card 8, button/input 8, dialog 12; không override bằng token button/input cũ 4 hoặc gán số riêng từng màn |
| Chữ | Theo `ThemeData.textTheme`; nội dung quan trọng không dùng chữ nhỏ để ép vừa |
| Vùng chạm | Tối thiểu 48dp trên Android, 44pt trên iOS; icon nhỏ vẫn có vùng chạm đầy đủ |
| Nhấn chính | Filled button cho thao tác chính; outlined/text cho thao tác phụ |
| Điều hướng | Bottom navigation trên điện thoại; rail và vùng nội dung thích nghi trên màn rộng |
| Chuyển động | Khoảng 150–250ms cho đổi trạng thái; tôn trọng Reduce Motion |

Mọi kích thước là quy tắc thiết kế, cần kiểm trực quan trên thiết bị ở bước implementation; chưa coi là đã đạt tương phản hoặc accessibility.

## 4. Kiến trúc thông tin

### 4.1. Năm tab cố định

| Tab | Mục đích | Hành động nổi bật |
|---|---|---|
| Hôm nay | Quyết định việc cần làm ngay | Mở buổi sắp dạy / điểm danh |
| Lịch dạy | Lên kế hoạch và điều chỉnh lịch | Xem buổi; tạo khi có quyền |
| Lớp học | Quản lý việc giảng dạy theo lớp | Mở lớp, học viên, bài tập, bảng điểm |
| Khóa học | Soạn và quản lý khóa cá nhân | Tạo khóa / tiếp tục soạn |
| Tài khoản | Phần tài khoản chung với các role: danh tính, đổi role, bảo mật, cài đặt, hỗ trợ | Quản lý tài khoản bằng luồng chung |

Không đổi thứ tự hoặc biến mất tab khi chuyển phạm vi. Tab Khóa học luôn giữ nhãn phạm vi cá nhân trong nội dung. Người không có dữ liệu thấy empty state đúng nguyên nhân, không thấy danh sách mẫu trộn vào dữ liệu thật.

### 4.2. Cây màn hình

```text
Teacher entry
├── Hồ sơ ứng viên: chưa có / chờ / bị từ chối / hết lượt
└── TeacherShell
    ├── Hôm nay
    │   ├── Bộ chọn nơi làm việc
    │   ├── Chi tiết buổi → điểm danh / phòng dạy
    │   └── Thông báo / hộp thư
    ├── Lịch dạy → chi tiết buổi → sửa / hủy
    ├── Lớp học → chi tiết lớp
    │   ├── Tổng quan và giáo viên được phân công
    │   ├── Buổi học và lịch lặp
    │   ├── Học viên → chi tiết trong lớp
    │   ├── Bài tập/quiz → đề → bài nộp/kết quả
    │   └── Bảng điểm → nhập điểm → tổng kết
    ├── Khóa học → quản lý khóa cá nhân
    │   ├── Thông tin / giá / học viên khóa
    │   ├── Giáo trình → chương → bài → nội dung
    │   └── Kiểm tra sẵn sàng / gửi duyệt / lý do từ chối
    └── Tài khoản chung
        ├── Thông tin người dùng / đổi vai trò
        ├── Chỉnh sửa thông tin cá nhân / bảo mật
        └── Cài đặt / hỗ trợ / giới thiệu / đăng xuất
```

Hộp thư, thông báo và công cụ mở rộng không chiếm thêm bottom tab. Khi mở màn sâu, ẩn bottom navigation để có đủ không gian và tránh thoát nhầm tác vụ.

Theo cập nhật 17/10: hồ sơ nghề nghiệp mở từ Công việc giảng dạy ở Hôm nay; thu nhập/ngân hàng mở từ Khóa học; nhắc lịch mở từ Lịch dạy. Nơi làm việc ở header các tab giảng dạy. Bảng di chuyển đầy đủ nằm trong plan UI mới; không bỏ các tính năng này khi thay tab cuối bằng phần chung.

### 4.3. Danh mục màn hình và ưu tiên

- P0: nền tảng bắt buộc để Teacher vào đúng giao diện và dạy lớp.
- P1: phạm vi đầy đủ cần thiết cho đợt Teacher đầu, xây sau nền tảng.
- P2: mở rộng; chưa làm nút hoạt động giả khi chưa tích hợp.

| ID | Màn hình/luồng | Ưu tiên |
|---|---|---|
| T01 | Teacher entry và trạng thái ứng viên | P0 |
| T02 | Teacher shell, bộ chọn nơi làm việc | P0 |
| T03 | Hôm nay | P0 |
| T04 | Lịch dạy tuần/tháng | P0 |
| T05 | Chi tiết buổi học | P0 |
| T06 | Điểm danh | P0 |
| T07 | Danh sách lớp | P0 |
| T08 | Chi tiết lớp | P0 |
| T09 | Học viên trong lớp và chi tiết | P0 |
| T10 | Tạo/sửa lớp, phân công giáo viên, ghi danh | P1 |
| T11 | Lịch lặp, tạo/đổi/hủy/sinh buổi | P1 |
| T12 | Khóa cá nhân | P1 |
| T13 | Tổng quan quản lý khóa | P1 |
| T14 | Form thông tin và học phí khóa | P1 |
| T15 | Cây giáo trình và sắp xếp | P1 |
| T16 | Editor article/quiz/exercise và học liệu theo loại | P1 |
| T17 | Kiểm tra sẵn sàng, gửi/rút yêu cầu duyệt | P1 |
| T18 | Học viên theo enrollment khóa | P1 |
| T19 | Hub bài tập/kiểm tra và editor đúng loại | P1 |
| T20 | Bài nộp, chi tiết kết quả, thống kê | P1 |
| T21 | Bảng điểm và nhập hàng loạt | P1 |
| T22 | Tổng kết và chốt điểm | P1 |
| T23 | Tài khoản chung; hồ sơ nghề nghiệp có điểm vào riêng ở Công việc giảng dạy | P0/P1 |
| T24 | Thu nhập cá nhân và giao dịch | P1 |
| T25 | Ngân hàng, yêu cầu rút, lịch sử rút | P1 |
| T26 | Thông báo và cài đặt nhắc lịch | P1 |
| T27 | Danh sách phiên live và phòng dạy | P2 |
| T28 | Upload video multipart/resume, trạng thái xử lý | P2 |
| T29 | Hộp thư, trao đổi theo lớp/bài | P2 |
| T30 | Cuộc thi quiz | P2 |

P0/P1 của editor video chỉ hoàn tất nếu có đường upload/nguồn video thật đã tích hợp. Không coi màn chọn file chưa upload được là nội dung video hoàn chỉnh.

## 5. Đặc tả T01–T02: vào role và chọn nơi làm việc

### 5.1. Trạng thái ứng viên

T01 nằm trước TeacherShell, dùng cùng hệ thống theme nhưng không hiển thị tab dạy học chưa được cấp quyền.

| Trạng thái | Nội dung | Hành động chính |
|---|---|---|
| Chưa có hồ sơ | Giải thích cần hồ sơ nghề nghiệp; danh sách thông tin còn thiếu | Hoàn thiện hồ sơ |
| Pending | Ngày gửi nếu có, nội dung đã gửi, trạng thái đang xét | Xem hồ sơ / kiểm tra cập nhật |
| Rejected, còn lượt | Lý do từ chối từ backend, số lượt còn lại, nội dung cần sửa | Sửa hồ sơ rồi nộp lại |
| Rejected, hết lượt | Giải thích không thể nộp lại; giữ hồ sơ đọc được | Quay lại vai trò khác; hỗ trợ nếu có kênh thật |
| Approved | Làm mới hồ sơ/token; chuyển vào TeacherShell khi có role thật | Bắt đầu sử dụng |

Không hiển thị thời gian duyệt cam kết nếu sản phẩm chưa có SLA. Không tự chuyển thành approved bằng thời gian chờ trên client.

### 5.2. Bộ chọn nơi làm việc

- Header hiển thị tên nơi làm việc dưới nhãn Giáo viên; tên dài được xuống tối đa hai dòng hoặc rút gọn có thể xem đầy đủ trong sheet.
- Sheet gồm Cá nhân và các tổ chức người dùng thực sự tham gia, lựa chọn hiện tại có dấu chọn.
- Danh sách dài có tìm kiếm; không tạo dropdown lồng trong vùng cuộn bị cắt.
- Mỗi lựa chọn có tên, thông tin phụ hợp lệ; logo chỉ là bổ trợ. Không bắt buộc tổ chức phải có logo.
- Khi chọn: nếu đang có form chưa lưu, giải quyết Lưu/tiếp tục chỉnh hoặc Bỏ thay đổi trước; không im lặng đóng form.
- Khi đổi thành công: cập nhật token/ngữ cảnh, bỏ dữ liệu Teacher cũ khỏi màn, tải lại scope mới; giữ vị trí tab nhưng reset lựa chọn lớp không thuộc scope.
- Khi lỗi: giữ ngữ cảnh cũ; thông báo không đổi được và cho thử lại.
- Nếu mất membership: dừng thao tác ghi, báo không còn quyền truy cập, yêu cầu chọn lại nơi làm việc hợp lệ.

## 6. Đặc tả T03: Hôm nay

### 6.1. Thứ tự nội dung

1. Header: tên nơi làm việc, thông báo; avatar dẫn tới Tài khoản.
2. Tiêu đề Hôm nay + ngày; lời chào ngắn, không chiếm cả màn.
3. **Buổi sắp dạy:** thời gian lớn dễ đọc, tên lớp, đơn vị, chủ đề, hình thức/phòng khi có, trạng thái và một CTA chính.
4. Lịch còn lại trong ngày theo thời gian; mỗi dòng có nhãn đơn vị và trạng thái.
5. Việc cần chú ý có dữ liệu xác thực: khóa bị từ chối, hồ sơ cần sửa hoặc thao tác liên quan từ notification.
6. Truy cập nhanh: lớp của tôi, khóa đang soạn, thu nhập cá nhân. Không dựng lưới icon 8–12 mục.

### 6.2. Khác biệt theo phạm vi

- Cá nhân: có đường tiếp tục soạn khóa và xem tình trạng duyệt, bên cạnh lịch dạy cá nhân.
- Tổ chức: ưu tiên lớp/buổi được phân công của tổ chức đó. Các liên kết khóa/thu nhập vẫn ghi rõ Cá nhân.
- Có nhiều buổi trùng giờ: hiện cảnh báo và danh sách liên quan; không âm thầm chọn một buổi rồi giấu buổi còn lại.
- Không còn lịch hôm nay: “Hôm nay bạn không có buổi dạy.” + Xem lịch tuần; không dùng thông báo lỗi.
- Chưa được phân công lớp trong tổ chức: “Bạn chưa được phân công lớp tại [tên].” + Đổi nơi làm việc; không mặc định cho quyền tự tạo lớp.

### 6.3. Wireframe điện thoại

```text
Giáo viên · [Trung tâm A ▾]                       Chuông
Hôm nay                              Thứ Tư, 14/10
────────────────────────────────────────────────────
BUỔI SẮP DẠY
15:00–16:30   Toán 10A1
Trung tâm A · Chủ đề: Hàm số
[ Xem buổi dạy ]
────────────────────────────────────────────────────
Lịch hôm nay                              Xem lịch
17:00  Lớp 10A2              Đã lên lịch           ›
19:00  Lớp 11A1              Đã lên lịch           ›
────────────────────────────────────────────────────
Cần chú ý
Khóa cá nhân có phản hồi xét duyệt                 ›
────────────────────────────────────────────────────
Hôm nay | Lịch dạy | Lớp học | Khóa học | Tài khoản
```

Dữ liệu trong wireframe chỉ minh họa bố cục; không phải dữ liệu thật hoặc mặc định để seed vào bản production.

## 7. Đặc tả T04–T06: Lịch, buổi học, điểm danh

### 7.1. Lịch dạy

- Mặc định tuần hiện tại: hàng ngày trong tuần + danh sách buổi của ngày chọn. Tháng là chế độ mở rộng để chọn ngày, không ép lịch chi tiết vào ô tháng nhỏ.
- Toolbar: Hôm nay, tên tuần/tháng, chuyển kỳ; bộ lọc lớp trong sheet riêng.
- Số/chấm dưới ngày chỉ báo số buổi, không dùng nhiều màu mà thiếu chú giải.
- Dòng buổi: giờ, lớp, đơn vị, chủ đề, trạng thái; bấm vào toàn dòng để mở chi tiết.
- Lịch lặp chưa có buổi cụ thể ghi rõ “Lịch dự kiến”. Không cho điểm danh bằng `schedule_id` thay cho `session_id`.
- Khi đã có buổi cụ thể, nó thay occurrence lịch lặp tương ứng; occurrence đã hủy không được vẽ lại từ lịch lặp. Dùng `schedule_id` + ngày và `cancelled_occurrences` để hợp nhất.
- Buổi bị đổi/hủy có nhãn chữ; thay đổi cập nhật lại Hôm nay và Chi tiết lớp.
- “Tạo buổi” xuất hiện khi đã có lớp hợp lệ và quyền; nếu cần chọn lớp, bước chọn lớp đi trước form.

### 7.2. Chi tiết buổi

Thứ tự: ngày/giờ và trạng thái → lớp/đơn vị → chủ đề/phòng → hành động chính → điểm danh → nội dung/bài tập → ghi chú.

| Trạng thái | CTA dự kiến |
|---|---|
| Có buổi cụ thể, chưa bắt đầu | Xem/chuẩn bị buổi; điểm danh theo quyền và luật backend |
| Có liên kết live và có quyền | Vào phòng dạy hoặc bắt đầu phiên theo quyền/trạng thái thật |
| Đang diễn ra | Vào phòng / điểm danh |
| Đã kết thúc | Xem điểm danh và kết quả; chỉnh khi backend còn cho phép |
| Đã hủy | Xem lý do; không hiện nút bắt đầu |
| Lớp lưu trữ | Chỉ xem; giải thích lớp đã lưu trữ |

Không đồng nhất trạng thái ClassSession và LivestreamSession. Nút phòng dạy chỉ dùng ID livestream hợp lệ; trạng thái hiển thị phải được map theo đúng nguồn.

Sửa/đổi giờ là màn form. Hủy buổi dùng xác nhận có tên lớp, thời gian và trường lý do theo contract; không đặt cạnh nút Điểm danh với trọng lượng thị giác bằng nhau.

### 7.3. Điểm danh

- Header cố định: lớp, ngày/giờ, số học viên, số chưa ghi nhận.
- Danh sách: avatar/initial, tên, mã nếu API có, trạng thái và ghi chú.
- Bộ chọn: Có mặt / Vắng / Muộn / Có phép; tách Chưa ghi nhận khỏi các trạng thái này.
- Mobile: chạm trạng thái mở sheet chọn, không ép bốn nút nhỏ trên một dòng tên dài.
- Có tìm kiếm và lọc trạng thái; bộ đếm chỉ dựa trên danh sách đầy đủ hoặc total phù hợp.
- Hành động hàng loạt “Đánh dấu các học viên chưa ghi nhận là có mặt”; không ghi đè những người đã được đánh dấu vắng/muộn nếu chưa xác nhận.
- Thay đổi là bản nháp đến khi bấm Lưu. Sticky footer hiển thị “Có N thay đổi” và Lưu điểm danh.
- Khi lưu giữ dữ liệu đang nhập; lỗi hiện tại dòng hoặc banner, không reset toàn bộ trạng thái.
- Timeout chưa rõ server đã lưu hay chưa: tải lại/đối chiếu trước khi báo thành công hoặc gửi lặp mù.
- Khi rời màn có bản nháp: Lưu / Bỏ thay đổi / Tiếp tục chỉnh.

```text
Điểm danh · Toán 10A1
14/10 · 15:00–16:30
[Tìm học viên]          [Lọc trạng thái]
Có mặt 20 · Vắng 1 · Chưa ghi nhận 3
──────────────────────────────────────
Nguyễn Minh Anh         [Có mặt ▾]
Trần Hoàng Lan          [Chưa ghi nhận ▾]
Lê Minh Khang           [Muộn ▾]   Ghi chú
──────────────────────────────────────
Có 3 thay đổi             [Lưu điểm danh]
```

Các con số chỉ là ví dụ bố cục. Với dữ liệu dài không cố giữ toàn bộ bộ đếm trên một dòng.

## 8. Đặc tả T07–T11: Lớp học và học viên

### 8.1. Danh sách lớp

- Tiêu đề và nơi làm việc; tìm kiếm theo contract; lọc Đang hoạt động / Nháp / Lưu trữ.
- Phân biệt Lớp được phân công và Lớp tôi quản lý khi có dữ liệu/quyền tương ứng. Không gọi tất cả là Lớp của tôi rồi suy quyền sở hữu.
- Dòng lớp: tên, đơn vị, trạng thái, số học viên, vai trò của mình nếu đã có; không tự tạo thông tin chưa được API trả.
- CTA Tạo lớp theo quyền thực tế; không hiện mặc định cho mọi giáo viên thuộc tổ chức.
- Empty state khác nhau giữa chưa có lớp, không khớp tìm kiếm, chưa được phân công và lỗi tải.

### 8.2. Chi tiết lớp

Header gọn: tên lớp, đơn vị, trạng thái, vai trò của mình; menu thao tác theo capability.

Năm mục: Tổng quan / Buổi học / Học viên / Bài tập / Bảng điểm. Trên điện thoại dùng thanh mục có thể cuộn ngang với chữ rõ, bảo đảm mục đang chọn luôn nhìn thấy; ở cỡ chữ lớn chuyển sang danh sách điều hướng thay vì ép nhãn.

- Tổng quan: thông tin khóa liên quan, giáo viên chính/trợ giảng, lịch lặp, số học viên và truy cập nhanh.
- Buổi học: danh sách theo thời gian; đi tới chi tiết/điểm danh.
- Học viên: danh sách đang học; trạng thái dropped/completed theo dữ liệu.
- Bài tập: nhóm Assignment/Quiz/Exercise đúng nơi được gắn; không trộn các ID và trạng thái thành một loại đề.
- Bảng điểm: mở màn chuyên biệt đủ không gian.

Lớp archived: banner “Lớp đã lưu trữ, hiện chỉ được xem.”; thao tác mở lại chỉ xuất hiện nếu người dùng có quyền.

### 8.3. Học viên và phân công

- Học viên lớp: họ tên, avatar, trạng thái; thông tin phụ hiển thị đúng quyền và đúng nguồn.
- Chi tiết học viên luôn có ngữ cảnh lớp/khóa: điểm danh, điểm, bài tập và tiến độ được hỗ trợ. Không ghép dữ liệu của người đó từ lớp khác.
- Thông tin phụ huynh chỉ hiển thị khi endpoint và quyền cung cấp; hành động gọi điện/nhắn tin phải có dữ liệu và chức năng thật.
- Ghi danh: tìm bằng endpoint enrollable-students; chọn → xem lại lớp/học viên → xác nhận. Không yêu cầu giáo viên nhập UUID.
- Phân công: tìm qua assignable-teachers; chọn vai trò Chính/Trợ giảng; dùng `can_assign_teachers` để mở chức năng.
- Gỡ học viên/giáo viên có xác nhận theo người/lớp cụ thể, sau đó tải lại nguồn. Không biến swipe thành xóa ngay.
- Tạo lớp: tên, mô tả, khóa tùy chọn, đơn vị theo ngữ cảnh, ngày bắt đầu/kết thúc, sức chứa. Không cho kéo lớp sang khóa người khác nếu thiếu quyền.
- Sau tạo lớp phải làm rõ bước phân công để lớp xuất hiện trong lịch cá nhân. Chưa có luật auto-assign đã chốt thì không âm thầm tự gán giáo viên.

## 9. Đặc tả T12–T18: Khóa cá nhân và giáo trình

### 9.1. Danh sách và quản lý khóa

- Dòng phạm vi cố định “Khóa học cá nhân” nếu đang ở tổ chức; không đổi tiêu đề thành “Khóa của [tổ chức]”.
- Tìm kiếm, bộ lọc Nháp / Chờ duyệt / Đã xuất bản / Bị từ chối / Lưu trữ.
- Dòng khóa: thumbnail nhỏ, tên, trạng thái, số bài/học viên nếu có, cập nhật gần nhất nếu API có. Không dựng poster lớn làm giảm tốc độ quét danh sách.
- Nháp: Tiếp tục soạn; Chờ duyệt: Xem trạng thái/Rút yêu cầu; Bị từ chối: Xem lý do/Sửa; Xuất bản: Quản lý khóa.
- Quản lý khóa chia ba mục: Thông tin / Giáo trình / Học viên; tình trạng duyệt là banner và hành động riêng, không thêm quá nhiều tab.

### 9.2. Form thông tin và giá

- Nhóm Nội dung: tên, mô tả ngắn/đầy đủ, mục tiêu, yêu cầu, đối tượng, cấp độ, ngôn ngữ, danh mục/tag.
- Nhóm Hình ảnh: thumbnail và video giới thiệu; ghi rõ định dạng/dung lượng thực tế khi contract đã có, không bịa giới hạn.
- Nhóm Giá: Miễn phí/Trả phí, giá gốc, giá giảm tùy chọn, hạn giảm nếu hỗ trợ.
- Giá giảm sai: hiện lỗi cạnh trường; gỡ giảm giá là thao tác rõ ràng, map sang null, không gửi 0 thay thế.
- Nhóm Học tập: học tuần tự và ngưỡng xem video; có mô tả tác động đối với học viên.
- Lưu nháp tách biệt Gửi duyệt. Không tự gửi duyệt sau lần lưu thông tin.
- Form dài chia nhóm có tiêu đề; bàn phím đúng loại, focus chuyển tới trường lỗi đầu tiên.

### 9.3. Giáo trình

- Chương có thể mở/thu; bên dưới là bài và loại nội dung.
- Một nút Thêm chương ở cấp khóa; Thêm bài ở từng chương. Không dùng cùng dấu cộng mà không rõ thêm vào đâu.
- Bài rỗng có nhãn “Chưa có nội dung”; bấm đi thẳng tới editor.
- Sắp xếp: nút Sắp xếp vào chế độ riêng, kéo bằng handle; có phương án Di chuyển lên/xuống cho accessibility.
- Không cho thao tác kéo kích hoạt khi người dùng chỉ đang cuộn.
- Xóa bài/chương nêu rõ phạm vi bị ảnh hưởng, đòi xác nhận; không tự hứa Undo khi backend chưa hỗ trợ khôi phục.

### 9.4. Editor theo loại nội dung

| Loại | Nội dung editor | Phản hồi cần có |
|---|---|---|
| Article | Tiêu đề, nội dung và định dạng được contract hỗ trợ | Xem trước, validation, trạng thái bản nháp |
| Video | Chọn nguồn/upload, thông tin video và tiến trình xử lý | Đang tải / tải dở / xử lý / sẵn sàng / lỗi |
| Quiz | Cấu hình, câu hỏi, đáp án, điểm và giải thích | Lưu cấu hình, sắp xếp câu, xem trước |
| Exercise | Đề lập trình, giới hạn, ngôn ngữ, testcase | Phân biệt testcase mẫu/ẩn, validation import |
| Livestream | Liên kết/tạo phiên và lịch đúng lớp | Không nhầm nội dung giáo trình với buổi lớp |

Không dùng một form khổng lồ thay đổi vài trường theo type. Mỗi editor dùng component chung cho tiêu đề/validation/footer và phần nhập riêng theo loại.

### 9.5. Gửi duyệt

Màn kiểm tra sẵn sàng hiển thị:

- Thông tin bắt buộc còn thiếu theo validation thật.
- Khóa có ít nhất một bài.
- Bài chưa có nội dung, liệt kê tên và link tới editor.
- Trạng thái hiện tại có cho gửi hay không.

Nút Gửi duyệt có xác nhận ngắn: nội dung sẽ khóa sửa khi chờ duyệt. Sau gửi: banner Chờ duyệt, thời điểm nếu có, nút Rút yêu cầu khi được phép.

Bị từ chối: lý do từ backend đặt trước phần chỉnh sửa. Rút yêu cầu/đổi trạng thái cần cập nhật tất cả màn đang giữ khóa này. Lỗi 409 tải lại trạng thái mới và giải thích; không hiển thị lưu thành công trước phản hồi server.

### 9.6. Học viên khóa

Hiển thị enrollment theo khóa, tiến độ và trạng thái backend cung cấp. Người mua khóa chưa xếp lớp vẫn được thấy ở đây. Không dùng danh sách lớp làm nguồn thay thế, không nhân số học viên nếu một người có nhiều enrollment.

## 10. Đặc tả T19–T22: Bài tập, kết quả và bảng điểm

### 10.1. Hub bài tập/kiểm tra

- Mở từ lớp hoặc khóa, luôn giữ breadcrumb/ngữ cảnh nguồn.
- Phân nhóm theo mô hình thật: Assignment lớp/phiên, Quiz, Exercise khóa. Mỗi dòng có nhãn loại.
- Lọc trạng thái phù hợp từng loại; không áp một trạng thái chung Bản nháp/Đã giao/Đã chấm khi backend không định nghĩa như vậy.
- Tạo Assignment: lớp/phiên nguồn, đề, ngôn ngữ, code mẫu, testcase, deadline và cấu hình nộp muộn theo contract.
- Tạo Quiz: câu hỏi, thời gian, điểm đạt, lượt làm, đảo câu/đáp án và thời điểm hiển thị đáp án.
- Publish/unpublish Assignment là hành động rõ, tách khỏi lưu nội dung.
- Essay có trong schema nhưng thiếu luồng chấm hoàn chỉnh: chưa đưa vào tác vụ hoạt động của bản đầu; không cho lưu một đề tự luận với lời hứa chấm đầy đủ.

### 10.2. Bài nộp và kết quả

- Mỗi dòng: học viên, lần nộp, thời gian, kết quả, điểm/verdict theo loại.
- Một học viên có nhiều lần nộp: nhóm hoặc cho lọc, không gọi số lần nộp là số người đã nộp.
- Code: xem code dạng chỉ đọc, ngôn ngữ, kết quả testcase, thời gian/bộ nhớ, lỗi biên dịch/chạy khi API có.
- Quiz: xem lượt làm, tỷ lệ đạt, kết quả và thống kê hỗ trợ.
- Điểm và feedback ở bảng điểm lớp là nghiệp vụ riêng; không dùng việc tạo grade để giả vờ đã chấm câu essay trong quiz.
- Testcase ẩn chỉ hiển thị khi backend trả và người dùng có quyền; không gửi toàn bộ đáp án về rồi chỉ che bằng UI.

### 10.3. Bảng điểm mobile

- Mặc định chế độ Theo học viên: danh sách tên + tóm tắt điểm; bấm mở các cột của người đó.
- Chế độ Bảng cho người cần quét nhiều học viên: tên học viên cố định, cột điểm cuộn ngang; header cột giữ khi cuộn dọc.
- Không ép 8–12 cột vào màn 360dp bằng cách giảm cỡ chữ.
- Tên cột, thang điểm, trọng số có thể xem rõ; ô chưa có điểm hiển thị dấu trống, không mặc định 0.
- Vào chế độ chỉnh sửa mới hiện bàn phím/ô nhập. Enter/Next chuyển ô có dự đoán; footer không che ô đang focus.
- Nhập nhiều điểm giữ bản nháp và số ô thay đổi, có kiểm giá trị so với max score.
- Lỗi từng ô nêu rõ học viên/cột; lỗi request giữ bản sửa để thử lại.
- Tablet ưu tiên bảng hai chiều; điện thoại giữ lựa chọn Theo học viên dễ thao tác một tay.

### 10.4. Tổng kết

Hiển thị điểm trung bình, xếp loại/rank nếu API có, người chấm/thời gian và feedback. Nút Tính tổng kết tách Chốt kết quả. Trước chốt có màn xem lại và xác nhận theo lớp; không hứa khóa bất biến hoặc mở khóa nếu backend chưa có contract tương ứng.

## 11. Đặc tả T23–T26: Tài khoản, thu nhập, thông báo

### 11.1. Tài khoản

Tab cuối tái sử dụng phần tài khoản chung đang được Student/Parent sử dụng: thông tin người dùng, đổi vai trò, chỉnh sửa thông tin cá nhân, bảo mật, cài đặt, hỗ trợ, giới thiệu và đăng xuất. Giữ các phần riêng của từng role trong wrapper tương ứng; Teacher không hiện Portfolio học viên hoặc Quản lý con.

Không tiếp tục phát triển bản sao `TeacherProfileScreen`/flow đổi role riêng. Dùng widget profile và luồng `ProfileCubit`/`AuthBloc` hiện có, tách phần nội dung chung khi triển khai. Hồ sơ nghề nghiệp chuyển sang Công việc giảng dạy; thu nhập/ngân hàng sang Khóa học; nhắc lịch sang Lịch dạy; nơi làm việc nằm ở header. Chi tiết di chuyển và điều kiện hồi quy trong [plan UI mới](TEACHER_UI_UX_BUILD_PLAN.md).

Xem hồ sơ công khai dùng dữ liệu public/privacy đúng nguồn; không lấy nội dung từ màn quản trị rồi lộ thêm ngân hàng hoặc trạng thái xét duyệt.

### 11.2. Thu nhập cá nhân

- Tiêu đề luôn là Thu nhập cá nhân. Có thể mở ở bất kỳ ngữ cảnh làm việc nhưng ghi rõ nguồn là khóa của mình.
- Số dư khả dụng là trọng tâm; bên dưới là tổng thu nhập, đã chi trả, đang xử lý theo backend.
- Không dùng ví này làm bảng lương, công dạy hoặc thanh toán của tổ chức.
- Lịch sử giao dịch có lọc thu nhập/hoàn tiền; cho xem khóa, số tiền, thời gian và trạng thái.
- Không vẽ biểu đồ theo tháng bằng cách suy từ một trang giao dịch. Chỉ thêm sau khi có nguồn tổng hợp đúng khoảng.
- Tiền dùng định dạng VND nhất quán, số dễ đọc; giữ số âm khi backend trả âm.

### 11.3. Ngân hàng và rút tiền

Luồng: số dư → thông tin ngân hàng → nhập tiền → xem lại → gửi → chi tiết yêu cầu.

- Điều kiện rút dựa trên `min_withdrawal_amount`, `available_balance`, `has_open_withdrawal` và bank info; không hard-code ngưỡng tiền.
- Xem lại hiển thị ngân hàng, số tài khoản đã che một phần, tên người nhận và số tiền; dữ liệu lấy từ snapshot/nguồn hợp lệ.
- Sửa ngân hàng không làm người dùng tưởng yêu cầu cũ cũng đổi thông tin nhận tiền.
- Gửi request chỉ một lần khi đang loading; timeout hiển thị cần kiểm tra lịch sử trước khi gửi lại.
- Yêu cầu pending có thể hủy nếu backend cho phép; approved/completed không hiện Hủy.
- Trạng thái giữ chữ rõ: Chờ xử lý / Đã duyệt / Đã chuyển / Bị từ chối / Đã hủy theo giá trị thật.
- Số dư âm hoặc có yêu cầu mở: giải thích cạnh nút rút thay vì chỉ làm nút mờ.

### 11.4. Thông báo

- Danh sách theo thời gian, đọc/chưa đọc, mở đúng khóa/lớp/phiên theo reference type.
- Thông báo duyệt khóa bị từ chối mở trang quản lý khóa, không đi tới trang công khai không tồn tại.
- Reference không còn truy cập được: màn giải thích và đường quay lại, không crash.
- Badge dùng unread-count thật. Chưa có endpoint cho Teacher gửi thông báo lớp hàng loạt; không thêm nút đó như đã hoạt động.

## 12. P2: Phòng dạy, video, hộp thư, cuộc thi

### 12.1. Phòng dạy trực tuyến

- Trước vào phòng: kiểm quyền, trạng thái buổi, camera/mic, mạng; preview và chọn thiết bị nếu nền tảng hỗ trợ.
- Vào phòng: ưu tiên nội dung đang chia sẻ; thanh điều khiển gọn gồm mic, camera, người tham gia, chat, bảng trắng và rời phòng.
- Chọn người tham gia mở tác vụ theo quyền; mute/kick cần phản hồi và xác nhận khi ảnh hưởng người khác.
- Phân biệt Rời phòng và Kết thúc buổi cho mọi người; không dùng cùng một nút hoặc cùng màu với thao tác thường.
- Khi mất mạng: trạng thái kết nối lại, giữ ngữ cảnh lớp; không tự kết thúc buổi chỉ vì app tạm background.
- Quyền camera/mic bị từ chối: hướng dẫn thao tác cài đặt thật; vẫn cho quay lại màn buổi.
- Khi chia sẻ màn hình/tắt mic phải có trạng thái liên tục dễ thấy, không chỉ snackbar thoáng qua.
- Ghi hình/poll chỉ thêm khi đã xác nhận luồng backend và client hoàn chỉnh.

### 12.2. Upload video

- Hiện phần trăm upload tách khỏi bước server xử lý video.
- Gián đoạn có Resume khi backend còn phiên upload hợp lệ; Hủy cần giải thích tác động với nội dung chưa lưu.
- Phân biệt file đang chọn, đang upload, đã upload, đang xử lý, sẵn sàng và lỗi xử lý.
- Không cho gửi duyệt với trạng thái video chưa đạt điều kiện thật; kiểm lại contract trước khi chốt luật này ở backend.

### 12.3. Hộp thư và cuộc thi

Hộp thư giữ participant/quyền/mute/block của backend, không coi có thông tin phụ huynh là được gửi tin tùy ý. Cuộc thi là module quiz riêng, có trạng thái quản lý/gửi duyệt; không dựng trang thi lập trình nhiều problem dựa vào tên Contest.

## 13. Các quy tắc tương tác dùng chung

### 13.1. Điều hướng và lưu trạng thái

- Đổi bottom tab giữ scroll/filter/tab con khi còn cùng tài khoản và phạm vi.
- Quay lại từ chi tiết trở về đúng ngày/lớp/bộ lọc trước đó.
- Đổi user/role/phạm vi loại bỏ dữ liệu không thuộc ngữ cảnh mới; không để request cũ hoàn tất rồi ghi đè màn mới.
- Deep link/notification đi vào màn sâu vẫn có Back hợp lệ và kiểm quyền lại.
- Form có bản sửa hiển thị trạng thái Chưa lưu; không dùng auto-save giả. Nếu làm lưu nháp local, phải có thiết kế dữ liệu/vòng đời riêng trước khi cam kết.
- Lưu, gửi duyệt, publish, chốt điểm là các hành động khác nhau; copy không dùng chung một chữ Xong.

### 13.2. Sheet, dialog và form

- Sheet: lọc, chọn phạm vi, chọn trạng thái điểm danh và thao tác ngắn.
- Màn riêng: form nhiều trường, giáo trình, nhập điểm, ngân hàng và xem lại yêu cầu rút.
- Dialog: xác nhận hủy/xóa/kết thúc hoặc quyết định không thể tiếp tục mà chưa chọn.
- Không lồng nhiều sheet; khi nội dung dài, chuyển màn thay vì ép sheet gần toàn màn nhưng vẫn chật.
- Bàn phím không che nút lưu hay ô lỗi; dùng system picker cho ngày/giờ theo nền tảng.

### 13.3. Copy và phản hồi

| Tình huống | Copy mẫu |
|---|---|
| Chưa được phân công | Bạn chưa được phân công lớp tại Trung tâm A. |
| Không có buổi hôm nay | Hôm nay bạn không có buổi dạy. |
| Khóa đang chờ | Khóa học đang chờ duyệt. Rút yêu cầu nếu bạn cần chỉnh sửa. |
| Lớp lưu trữ | Lớp đã lưu trữ, hiện chỉ được xem. |
| Lưu điểm danh thành công | Đã lưu điểm danh. |
| Lưu thất bại | Chưa lưu được thay đổi. Nội dung bạn nhập vẫn được giữ. |
| Lỗi đổi phạm vi | Chưa chuyển được nơi làm việc. Bạn vẫn đang ở Cá nhân. |
| Mất quyền | Bạn không còn quyền thực hiện thao tác này. |
| Timeout rút tiền | Chưa xác định được kết quả. Kiểm tra lịch sử yêu cầu trước khi gửi lại. |

Không dùng copy khẳng định đã gửi nhắc, đã liên hệ hay đã tải PDF khi mới chỉ mở snackbar.

## 14. Ma trận trạng thái bắt buộc

| Trạng thái | Cách thể hiện | Hành động |
|---|---|---|
| Tải lần đầu | Skeleton đúng bố cục; không nhảy số giả | Chờ / quay lại |
| Refresh | Giữ dữ liệu cũ có đánh dấu đang cập nhật | Không khóa toàn màn vô lý |
| Thành công | Nội dung thật, phạm vi rõ | Thao tác theo quyền |
| Rỗng lần đầu | Giải thích thiếu gì và bước tiếp theo | Tạo khi có quyền / đổi scope |
| Rỗng do lọc | Hiện bộ lọc đang áp dụng | Xóa bộ lọc |
| Lỗi một khối Home | Lỗi ngay khối đó, khối khác vẫn dùng được | Thử lại khối |
| Offline | Dữ liệu cũ chỉ khi có cache thật; ghi chưa kết nối | Đọc/quay lại, thử lại |
| Không có quyền | Màn phù hợp, không lộ dữ liệu | Quay lại / tải lại quyền |
| 404/tài nguyên bị xóa | Tài nguyên không còn khả dụng | Về danh sách |
| 409 trạng thái đổi | Nêu trạng thái mới, giữ bản sửa phù hợp | Tải lại và đối chiếu |
| Form đang lưu | Chặn gửi lặp; giữ ô và trạng thái | Chờ phản hồi |
| Văn bản dài | Xuống dòng/ellipsis có chỗ xem đầy đủ | Mở chi tiết |
| Kết quả phân trang | Có loading thêm trang và lỗi riêng | Thử lại trang, không xóa dữ liệu cũ |

Skeleton và offline cache phải phản ánh tính năng thực sự triển khai; không gọi dữ liệu mẫu là cache.

## 15. Nội dung, accessibility và responsive

### 15.1. Bộ dữ liệu dùng khi thiết kế

Dùng fixture, không sửa dữ liệu thật:

- Người dùng chỉ có Cá nhân; người có một tổ chức; người có ba tổ chức; tên tổ chức dài.
- 0/1/12 lớp; lớp trùng tên khác tổ chức; lớp chưa có giáo viên chính; lớp archived.
- 0/1/6 buổi trong ngày; đổi giờ, hủy, trùng lịch, chỉ có lịch dự kiến, có liên kết live.
- Lớp 0/1/30/100 học viên; tên dài có dấu; không có avatar; thiếu thông tin phụ huynh.
- Khóa có 0/1/20 chương, bài rỗng, tên dài, đủ 5 trạng thái duyệt.
- Bảng điểm 3/8/20 cột, ô trống, số thập phân, feedback dài.
- Ví 0/dương/âm, chưa có ngân hàng, có yêu cầu rút pending/approved/rejected.

Các con số là trường hợp kiểm tra, không phải giới hạn nghiệp vụ. Chỉ đặt max khi backend có quy định.

### 15.2. Accessibility

- Nhãn Semantics mô tả học viên, trạng thái và hành động; icon-only có tooltip/label.
- Thứ tự đọc theo thứ tự thị giác; focus không bị mắc trong sheet hoặc vùng bảng cuộn.
- Không chỉ dùng màu để phân biệt lớp, trạng thái hay ô lỗi.
- Kiểm tương phản khi implement, mục tiêu WCAG AA: chữ thường 4.5:1, chữ lớn 3:1, điều khiển/biên quan trọng 3:1.
- Nội dung thông thường cho tăng cỡ chữ; không tắt text scaling toàn app để giữ layout.
- Cỡ chữ lớn: button label xuống dòng phù hợp, action nhóm xếp dọc, thông tin phụ không đè thông tin chính.
- Có cách chọn/sắp xếp bằng nút thay cho chỉ kéo; TalkBack/VoiceOver thao tác được điểm danh và nhập điểm.

### 15.3. Ma trận màn hình

| Bề rộng logic | Hành vi |
|---|---|
| 360/390/430dp | Một cột, bottom navigation, sheet theo tác vụ |
| 600–839dp | Tăng vùng đọc, cân nhắc rail; không kéo form thành dòng quá dài |
| Từ 840dp | Navigation rail, list-detail cho lớp/lịch; form có max width; bảng điểm có không gian lớn hơn |

Kiểm light/dark, cỡ chữ 1.0/1.3/2.0, bàn phím mở, safe area, xoay màn khi có hỗ trợ. Chọn breakpoint cuối sau khi xem thực tế; không giả định chỉ cần scale điện thoại lên tablet.

## 16. Component và ranh giới trách nhiệm

| Component đề xuất | Trách nhiệm |
|---|---|
| TeacherAppHeader | Tiêu đề, phạm vi, notification và avatar; không tự gọi API |
| WorkplaceSelectorSheet | Danh sách nơi làm việc và trạng thái chọn; giao việc đổi context cho state layer |
| TeacherSessionRow | Thời gian, lớp, tổ chức, trạng thái và callback mở buổi |
| NextTeachingSession | Khối buổi sắp dạy, một CTA phù hợp |
| TeacherClassRow / ClassIdentityHeader | Nhận diện lớp và phạm vi |
| ResourceStatusLabel | Nhãn chữ + màu theo loại/trạng thái đã map |
| AttendanceStudentRow / AttendanceSummary | Hiển thị điểm danh và thay đổi; không tự lưu mạng |
| CourseOutline / LessonContentRow | Cây giáo trình và thao tác theo quyền |
| ReviewStatusBanner / ReviewReadinessList | Lý do/trạng thái duyệt và lỗi còn thiếu |
| GradeStudentList / GradeTable / GradeEditor | Tách đọc dữ liệu khỏi bản chỉnh điểm |
| TeacherBalanceSummary / WithdrawalStatusRow | Số dư và lịch sử rút cá nhân |
| AsyncSection / ScopeEmptyState | Tải/lỗi/rỗng có scope; chỉ tạo dùng chung khi đủ trường hợp thực tế |

Tái sử dụng `AuthBloc`, `ProfileCubit`, DI GetIt, theme, avatar và các widget trạng thái phù hợp. Không copy nguyên màn Student đọc khóa thành editor Teacher; không import lớp private hoặc repository implementation vào widget trình bày.

Chỉ tạo component theo khối có ý nghĩa, state hoặc chỗ tái sử dụng. File lớn là tín hiệu rà soát; không tách mọi Container thành file để đạt số dòng. Widget nhận dữ liệu/callback; API, permission mapping và cache thuộc lớp state/repository.

## 17. Hợp đồng dữ liệu và các điểm cần hoàn thiện

| Hạng mục | Hiện có | Cách triển khai / việc cần chốt |
|---|---|---|
| Vào Teacher | Auth/profile và MainScreen hiện có | Thêm routing Teacher/Applicant, không rơi về Student |
| Đổi tổ chức | `/auth/select-org` có ở backend | Nối API mobile, cập nhật token và ngữ cảnh đúng thứ tự |
| Lớp được phân công | `/classes/me` có org ID | Phạm vi lọc dựa trên tập đầy đủ; không bao gồm mặc định mọi lớp sở hữu |
| Lớp quản lý phân trang | `/classes` có kiểm quan hệ | Cần contract filter organization nếu yêu cầu tổng/lọc chính xác theo scope |
| Lịch dạy | `/me/timetable` + khoảng ngày | Ghép lớp/org, hợp nhất lịch lặp/buổi và hủy occurrence |
| Chi tiết/quyền lớp | `/classes/:id` có capability | Không dùng cờ trên list nếu chưa được trả; trạng thái archived kiểm riêng |
| Điểm danh | `/sessions/:id/attendances` và bulk | Bản nháp, lưu/đối chiếu và refresh các màn liên quan |
| Khóa cá nhân | `/courses/mine`, giáo trình và review routes | Không giả lập khóa thuộc tổ chức |
| Quiz/Assignment/Exercise | Ba bộ endpoint riêng | Model/editor/ID khác nhau, UI có nhãn loại |
| Bảng điểm | Grade columns, grades, final grades | Bản nháp ô điểm, thang điểm/trọng số và xem lại trước chốt |
| Ví/rút tiền | Wallet teacher và withdrawals | Cá nhân, decimal, điều kiện rút từ server |
| Dashboard Teacher | Chưa có endpoint tổng hợp riêng | Ghép khối nhỏ có nguồn; chỉ bổ sung aggregate endpoint khi KPI cần nó |
| AI nhận xét/essay manual grading | Chưa có luồng hoàn chỉnh đã xác nhận | Ngoài bản hoạt động đầu, không dùng dữ liệu giả |
| Gia hạn deadline/calendar tổng hợp | Router tương ứng đang comment | Không dựng nút hoạt động; dùng schedule routes hiện hành |
| Thông báo hàng loạt Teacher | Send endpoint là quyền Admin | Cần contract riêng trước khi đưa vào UI Teacher |
| Lương tổ chức/kho khóa tổ chức | Chưa thấy contract tương ứng | Ngoài phạm vi, không suy từ ngữ cảnh tổ chức |

Luật kỹ thuật có tác động UX:

- Phân trang/response envelope không đồng nhất; map theo DTO, không tự đoán mọi mảng là `data`.
- Tiền/điểm decimal cần parser/formatter đúng; không lấy chuỗi hiển thị làm giá trị request.
- Thời gian lịch buổi và timestamp livestream cần xử lý timezone đúng contract. Đổi ngày hiển thị không được làm lệch ngày điểm danh.
- Cache/request key cần phân biệt user, role, active org, filter và tài nguyên. Bỏ response cũ nếu ngữ cảnh đã thay đổi.
- Chuyển scope cần xóa dữ liệu nhạy cảm đang hiển thị từ scope trước; bộ lọc giao diện không thay thế quyền backend.

## 18. Thứ tự thực hiện và đầu ra từng đợt

### Đợt A — Chốt bản thiết kế

- [ ] Chốt năm tab, tên nhãn và quy tắc phạm vi.
- [ ] Chốt matrix Teacher tự do / Teacher tổ chức / người có cả hai / Applicant.
- [ ] Wireframe T01–T09 và đường đi điểm danh.
- [ ] Wireframe khóa/giáo trình, bảng điểm và thu nhập.
- [ ] Prototype luồng đổi phạm vi, bản nháp chưa lưu, gửi duyệt và rút tiền.
- [ ] Review light/dark và 360dp/cỡ chữ lớn trên các màn có nhiều dữ liệu.

Đầu ra: sơ đồ màn hình, wireframe và bảng trạng thái có thể đối chiếu với phần đặc tả trong file này. Không yêu cầu dựng hết backend để review wireframe.

### Đợt B — Shell và một hành trình dạy hoàn chỉnh

- [ ] Model role/context, API select-org, route Teacher/Applicant.
- [ ] DI/state Teacher, shell và nơi làm việc.
- [ ] Hôm nay, lịch, lớp được phân công, chi tiết buổi và học viên.
- [ ] Điểm danh với bản nháp, lưu và xử lý lỗi.
- [ ] State loading/empty/error/permission đủ cho các màn P0.

Điều kiện xong: Teacher được phân công có thể từ Hôm nay lưu điểm danh thật; đổi tổ chức không thấy dữ liệu cũ; Applicant không vào editor Teacher.

### Đợt C — Khóa cá nhân và giáo trình

- [ ] Danh sách/chi tiết khóa, thông tin/giá và học viên enrollment.
- [ ] Cây giáo trình, editor theo loại đã tích hợp.
- [ ] Kiểm tra sẵn sàng, gửi/rút yêu cầu, lý do từ chối.
- [ ] Kiểm pending_review khóa chỉnh sửa và refresh đồng bộ.

Điều kiện xong: một khóa có nội dung thật được lưu, gửi duyệt, rút yêu cầu và tiếp tục chỉnh; không có thao tác xuất bản tự cấp.

### Đợt D — Nghiệp vụ lớp và thu nhập

- [ ] Tạo/sửa lớp, phân công và ghi danh theo capability.
- [ ] Quản lịch lặp, tạo/đổi/hủy/sinh buổi.
- [ ] Assignment/quiz/exercise, bài nộp và thống kê theo đúng loại.
- [ ] Bảng điểm/nhập điểm/tổng kết với bản nháp và validation.
- [ ] Thu nhập cá nhân, ngân hàng, rút và lịch sử yêu cầu.

Điều kiện xong: quyền và trạng thái đã được kiểm cả trên UI và phản hồi backend; không lẫn ví cá nhân với tiền tổ chức.

### Đợt E — Nâng cao

- [ ] LiveKit và phòng dạy, camera/mic/reconnect.
- [ ] Upload video resume và xử lý server đầy đủ.
- [ ] Hộp thư, thảo luận và cuộc thi quiz.
- [ ] Các aggregate endpoint/KPI bổ sung chỉ sau khi thống nhất định nghĩa dữ liệu.

Không đặt thời lượng ngày công cố định trong tài liệu này; cần chia ticket theo endpoint và mức hoàn thiện thực tế của từng đợt.

## 19. Tiêu chí nghiệm thu UI/UX

### 19.1. Hành trình và tính đúng dữ liệu

- [ ] Teacher/Applicant/Student/Parent vào đúng shell/trạng thái.
- [ ] Cá nhân, một org, nhiều org, mất membership đều có luồng rõ.
- [ ] Lớp cùng tên khác đơn vị không thể bị nhầm trong thao tác.
- [ ] Đổi org không khiến khóa/thu nhập cá nhân được gắn nhãn tổ chức.
- [ ] Không lọc một trang rồi báo tổng như đã tải đủ dữ liệu.
- [ ] Lịch lặp + buổi cụ thể không nhân đôi, buổi hủy không hiện lại.
- [ ] Chưa điểm danh khác Vắng; ô điểm trống khác 0.
- [ ] Mọi nút chính gọi luồng thật; chưa có integration thì không báo thành công giả.

### 19.2. Giao diện và tương tác

- [ ] Không overflow ở 360/390/430dp; tên dài và font lớn vẫn đọc/thao tác được.
- [ ] Dark mode không có mảng trắng cứng hoặc chữ mất tương phản.
- [ ] CTA chính rõ; nội dung quan trọng xuất hiện trước lưới tiện ích/KPI.
- [ ] Sheet/form/bàn phím/safe area không che điều khiển.
- [ ] Back giữ đúng vị trí; bản sửa chưa lưu được bảo vệ.
- [ ] Quyền bị thiếu và trạng thái tạm khóa được giải thích khác nhau.
- [ ] Feedback có trạng thái đang gửi/thành công/thất bại, không chấp nhận nhấn lặp vô ý.
- [ ] TalkBack/VoiceOver đọc được tên, scope, trạng thái và hành động.

### 19.3. Bằng chứng kiểm tra khi implement

- Test role routing và DI, scope switch thành công/thất bại và response cũ về muộn.
- Widget test các màn mới ở trạng thái rỗng/có dữ liệu/lỗi và các callback chính.
- Integration test đường điểm danh, lưu form khóa/gửi-rút duyệt và tạo-hủy yêu cầu rút tiền theo môi trường kiểm thử.
- Capture trên Simulator/emulator hoặc thiết bị thật; tối thiểu phone light/dark, một cỡ chữ lớn; thêm tablet nếu phát hành tablet.
- Review trực quan một lượt theo ma trận, sửa lỗi phát hiện thành một nhóm và xác nhận lại; không tuyên bố đạt UI chỉ từ analyzer/test.
- Chạy analyzer và regression suite phù hợp, ghi rõ kiểm tra nào đã chạy và kiểm tra nào còn thiếu.

## 20. Quyết định còn mở trước khi bắt đầu từng module

| Quyết định | Mặc định đề xuất | Phụ thuộc |
|---|---|---|
| Hôm nay ưu tiên gì? | Buổi dạy tiếp theo trước, khóa đang soạn sau | Có thể điều chỉnh sau kiểm thử với giáo viên |
| Có tách Teacher tự do thành shell khác? | Không; dùng scope + quyền + nhãn dữ liệu | Không nhân đôi luồng lớp/lịch |
| Khóa/thu nhập khi chọn tổ chức? | Giữ rõ Cá nhân | Chỉ đổi khi backend có contract tổ chức thật |
| Teacher vừa tạo lớp có tự được gán vào lớp? | Hiển thị bước phân công rõ; chưa tự gán ngầm | Cần chốt luật với backend trước khi đổi hành vi |
| Thống kê cần chấm toàn bộ lớp? | Chưa hiển thị tổng nếu thiếu nguồn | Định nghĩa pending grading và endpoint aggregate |
| Học liệu tổ chức dùng chung? | Chưa giả định là đã có | Ownership và quyền xem/sửa khóa của org |
| Lưu nháp offline? | Giữ bản sửa trong phiên màn hình, chưa hứa sync offline | Thiết kế lưu trữ, khôi phục và xung đột riêng |
| Editor video và phòng live ở đợt đầu? | Thiết kế đầy đủ, triển khai sau các luồng P0/P1 nền tảng | SDK, quyền thiết bị, upload và kiểm thử môi trường |

Các mục mở là phụ thuộc được ghi rõ để người triển khai không tự bịa nghiệp vụ. Chúng không cản việc bắt đầu wireframe và shell theo các quyết định đã mô tả.
