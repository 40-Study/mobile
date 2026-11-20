# EdTech Mobile — Đặc tả app giáo viên (bản chốt)

| | |
|---|---|
| Phiên bản | 1.0 — chốt mốc 1a |
| Ngày | 19/11/2026 |
| Thay thế | `EDTECH_TEACHER_MOBILE_FUNCTIONAL_SPEC.md` (giữ làm tham chiếu lịch sử) |
| Wireframe | https://claude.ai/artifact/NT599NWxg2MZhWwxDyNTym — gồm **sơ đồ luồng toàn bộ màn** (artboard `Flow`, trên cùng canvas), từng màn bấm được (tên artboard ở mục 6), bảng 12 trạng thái (`States`) |
| Phạm vi tài liệu | UI/UX + bảo mật phía mobile. Backend chỉ xuất hiện ở mục 11 dưới dạng điều app cần. |
| Cách chốt | Viết lại từ spec gốc, qua 8 vòng review chéo Claude ↔ Codex và xác nhận nghiệp vụ của product owner. Lý do từng quyết định: mục 14. |

**Cách đọc.** Mục 1–13 là yêu cầu để code mốc 1a. Mục 14 giải thích vì sao, để không ai "sửa cho hợp lý" một chỗ đã cân nhắc. Mục 15 là phần của mốc 1b và Đợt 2, giữ từ spec gốc, chưa chi tiết hóa. Khi tài liệu này và spec gốc khác nhau, **tài liệu này đúng**.

---

## 1. Phạm vi và mô hình tài khoản

Hệ thống có **một role Giáo viên**. Cùng một tài khoản có thể được phân công dạy tại một hoặc nhiều trung tâm và tự vận hành lớp cá nhân (Dạy riêng — Đợt 2). Quyền phụ thuộc **không gian đang làm việc**, **phân công** (lớp hoặc buổi) và **trạng thái dữ liệu**.

| Không gian | Giáo viên chịu trách nhiệm | Kết quả cần theo dõi |
|---|---|---|
| Trung tâm | Dạy lớp được giao, xem học liệu, điểm danh, hoàn tất buổi | Số buổi và giờ dạy theo tháng, trạng thái xác nhận |
| Dạy riêng (Đợt 2) | Tổ chức lớp, quản lý khóa học, ghi danh, giảng dạy | Buổi, giờ, lượt bán, doanh thu, tiền được hưởng, tiền đã nhận |

Dùng tên **Dạy riêng** cho không gian và **Hồ sơ** cho tài khoản. Tài khoản chỉ có một nơi làm việc: vào thẳng, ẩn bộ chuyển. Trung tâm đã rời không nằm trong bộ chuyển, chỉ xem lại lịch sử ở chế độ chỉ đọc trong Báo cáo.

### 1.1 Quyết định đã chốt

| Hạng mục | Yêu cầu |
|---|---|
| Nguồn dữ liệu trung tâm | Trung tâm tạo sẵn lớp, buổi, phân công giáo viên, danh sách học viên. App giáo viên chỉ **xem, điểm danh, hoàn tất**. |
| Giờ dạy | **= thời lượng cố định của buổi**, ghi nhận khi buổi hoàn tất. Dạy thêm hay dạy thiếu đều tính đủ thời lượng. Không dùng nhật ký lớp live để tính giờ. Giáo viên không nhập giờ. *(Thay quy tắc "tính theo thời lượng thực dạy" của spec gốc.)* |
| Hình thức học | Dạy online. Lớp live có lịch và phòng online. Phòng online là **link web**; app mở bằng trình duyệt hệ thống. |
| Điểm danh | Thực hiện **trong buổi học**, song song với lớp live đang mở trên web. Trạng thái: Chưa đánh dấu / Có mặt / Đi muộn / Vắng. Không thêm trạng thái khác. |
| Danh sách điểm danh | Danh sách trung tâm cấp cho từng buổi (gồm học viên học bù nếu có). |
| Người dạy trên buổi | Mỗi buổi **1 giáo viên chính**, **trợ giảng tùy chọn**. Trợ giảng là tài khoản giáo viên, **được điểm danh và tính giờ bình thường**. |
| Kỳ báo cáo | Buổi diễn ra tháng nào tính vào tháng đó (theo múi giờ trung tâm). Buổi qua nửa đêm tính theo ngày bắt đầu. |
| Nhiều trung tâm | Một giáo viên tham gia nhiều trung tâm, xem lại lịch sử dạy theo từng nơi, kể cả sau khi rời. |
| Xin nghỉ, Bài tập | Có trong Đợt 1, thuộc **mốc 1b** (mục 15). |
| Dạy riêng | Học sinh mua khóa và thanh toán qua app, nền tảng giữ phí phần trăm. **Đợt 2** (mục 15). |

### 1.2 Đối tượng cần phân biệt

| Đối tượng | Ý nghĩa | Ví dụ |
|---|---|---|
| Khóa học | Nội dung giảng dạy và cấu hình bán/tuyển sinh | Scratch cơ bản |
| Lớp học | Nhóm ghi danh học một khóa theo đợt | Scratch tối thứ Hai, tháng 11 |
| Buổi học | Một lần dạy có khung giờ, **thời lượng cố định**, người dạy và điểm danh riêng | Buổi 3, 23/11, 18:30–20:00 (90 phút) |
| Ghi danh | Quan hệ học viên – lớp | An ghi danh lớp Scratch tối thứ Hai |
| Đơn hàng (Đợt 2) | Giao dịch mua có trạng thái, số tiền, hoàn tiền | Đơn mua gói Scratch 8 buổi |
| Khoản chi trả (Đợt 2) | Khoản chuyển cho giáo viên | Một lần chuyển gồm nhiều đơn |

Báo cáo giờ đi từ **buổi học**. Báo cáo bán khóa đi từ **đơn hàng**. Tiền đã nhận đi từ **khoản chi trả**.

---

## 2. Phạm vi phát hành

| Đợt | Nội dung | Trạng thái tài liệu |
|---|---|---|
| **Mốc 1a** | Một vòng dạy: lịch → vào lớp → điểm danh → hoàn tất → báo cáo giờ; nhiều trung tâm; trung tâm đã rời; dạy thay; trợ giảng | **Chi tiết đầy đủ (mục 3–13)** |
| Mốc 1b | Xin nghỉ (T24–T25), Bài tập (T21–T23), Thông báo (T11), tiến độ + nhận xét học viên | Giữ từ spec gốc (mục 15), cần plan riêng |
| Đợt 2 | Dạy riêng: khóa học, mở lớp, ghi danh, doanh thu, chi trả (T13–T19, T27) | Giữ từ spec gốc (mục 15) |

**Không làm ở 1a:** màn chi tiết học viên riêng (T09 — thay bằng lịch sử điểm danh trong chi tiết lớp), luồng điều chỉnh T20 (buổi đã chốt do trung tâm sửa/mở lại), offline đầy đủ, lọc "Tất cả" để phát hiện trùng giờ giữa các nơi, đồng giảng, thao tác điểm danh hàng loạt.

Phát hành riêng 1a hay chờ xong 1b: **chưa quyết** (mục 16).

---

## 3. Quy tắc nghiệp vụ mốc 1a

1. **Giờ được tính** của mỗi người dạy trên buổi (chính, dạy thay, trợ giảng) = thời lượng **hiện hành** của buổi. Trung tâm đổi thời lượng thì giờ được tính theo thời lượng mới, ở mọi màn (Hoàn tất, Cần bổ sung, Báo cáo). Hiển thị chỉ đọc. Không sửa trong app.
2. **Hoàn tất**: chỉ người dạy chính của buổi (giáo viên chính hoặc người dạy thay) bấm. Trợ giảng không có nút Hoàn tất. Giáo viên chính quên hoàn tất: trung tâm chốt hộ ở phía quản trị.
3. **Điểm danh**: giáo viên chính, người dạy thay và trợ giảng đều điểm danh được. Lưu gửi trong **một lần** trạng thái của mọi học viên đã được đánh dấu; học viên chưa đánh dấu không gửi và vẫn là Chưa đánh dấu (số còn thiếu = danh sách buổi − số đã lưu). Nháp tự lưu trên máy sau từng lựa chọn.
4. **Còn học viên chưa đánh dấu** vẫn được hoàn tất; màn Hoàn tất cảnh báo số còn thiếu.
5. **Sau hoàn tất** (do người dạy chính hoặc trung tâm chốt hộ): buổi chỉ đọc. Máy nào còn nháp chưa gửi của buổi đó (ví dụ trợ giảng) thì app bỏ nháp và báo "Buổi đã được chốt, nháp chưa gửi không còn hiệu lực". Trung tâm có quy trình duyệt → giờ của từng người chuyển **Chờ xác nhận**. Trung tâm không duyệt → giờ vào báo cáo ngay.
6. **Cần bổ sung**: trung tâm trả về kèm lý do. Người dạy chính sửa **nội dung đã dạy** + nhập lý do sửa bắt buộc, gửi lại → Chờ xác nhận. Không sửa giờ, không sửa điểm danh. Trợ giảng bị trả về: chỉ xem lý do, liên hệ trung tâm.
7. **Buổi hủy**: giữ trong lịch với nhãn Đã hủy, không tính giờ, tắt nút Vào lớp.
8. **Đổi lịch / dạy thay**: do trung tâm thực hiện. Thay đổi hiện trong "Lịch sử thay đổi" của buổi (trước/sau, lý do, người, thời điểm). Giờ tính cho người dạy thực tế của buổi.
9. **Mốc mở/khóa** điểm danh và hoàn tất do BE trả về theo cấu hình từng trung tâm; app không tự tính.
10. **Trạng thái xác nhận giờ theo từng người**, không theo buổi. Mọi màn và nhãn liên quan đến xác nhận (Cần bổ sung, Chờ xác nhận, đã chốt) áp theo trạng thái giờ **của người đang xem**. Ví dụ: giờ của giáo viên chính Đã xác nhận còn giờ trợ giảng Cần bổ sung → giáo viên chính thấy buổi đã chốt; trợ giảng thấy Cần bổ sung, chỉ xem lý do.

---

## 4. Vai trò trên một buổi

| Quyền | Giáo viên chính | Dạy thay | Trợ giảng |
|---|---|---|---|
| Thấy buổi trong Lịch | Có, nhãn "Chính" | Có, nhãn "Dạy thay" | Có, nhãn "Trợ giảng" |
| Mở chi tiết lớp | Có | **Không** (chỉ buổi được giao) | Theo phân công lớp |
| Vào lớp, xem học liệu | Có | Có | Có |
| Điểm danh | Có | Có | Có |
| Hoàn tất | Có | Có | **Không** |
| Giờ được tính | Thời lượng buổi | Thời lượng buổi | Thời lượng buổi |
| Cần bổ sung | Sửa nội dung + gửi lại | Sửa nội dung + gửi lại | Chỉ xem lý do, liên hệ trung tâm |
| "Cần xử lý" gồm | Buổi quá giờ chưa hoàn tất, buổi Cần bổ sung | Như chính | Chỉ buổi đang diễn ra chưa điểm danh |

Giáo viên gốc bị chuyển buổi cho người khác: buổi vẫn hiện dạng mờ "Đã chuyển người dạy", không mở được (chỉ khi còn quyền xem buổi).

---

## 5. Điều hướng

- Tab dưới: **Lịch · Lớp · Báo cáo · Hồ sơ**.
- Header **mọi tab** hiện tên trung tâm đang làm việc. Chạm để mở bộ chuyển. Huy hiệu trên tên = số "Cần xử lý" ở các nơi khác, để không bỏ sót buổi bị trả về.
- Báo cáo luôn theo nơi hiện tại. Trung tâm đã rời xem ở mục riêng "Trung tâm đã rời" trong Báo cáo.
- Giáo viên đã rời **mọi** trung tâm (không còn nơi làm việc): Lịch hiện trạng thái 01 "Chưa được giao lớp"; header không có bộ chuyển; tab Báo cáo chỉ còn mục "Trung tâm đã rời".

---

## 6. Màn hình mốc 1a

Tên trong ngoặc là artboard tương ứng trong wireframe.

### T01+T03 Lịch — trang chủ (`Main`)
- **Hiển thị:** mục **Cần xử lý** (theo vai trò, mục 4); thẻ **Buổi tiếp theo** (giờ, lớp, sĩ số, trợ giảng, nút Vào lớp, Chi tiết); dải tuần chọn ngày; danh sách buổi của ngày với nhãn Chính / Dạy thay / Trợ giảng / Đã hủy / Đã chuyển người dạy / Chờ giáo viên chính hoàn tất; dòng tổng tháng "12 buổi · 18 giờ".
- **Hành động:** mở buổi, Vào lớp, đổi ngày/tuần, chạm dòng tháng → Báo cáo.
- Gộp Tổng quan (T01) vào Lịch; dòng tổng tháng giữ nội dung T01.

### T02 Chuyển nơi làm việc (`Switcher`)
- **Hiển thị:** các trung tâm đang tham gia, nơi đang chọn, số "Cần xử lý" từng nơi, ghi chú nếu còn nháp chưa gửi.
- **Hành động:** chọn nơi → xóa cache truy vấn của nơi cũ, tải lại theo nơi mới. **Nháp chưa gửi giữ riêng theo từng nơi**, không cảnh báo khi chuyển.

### T04 Chi tiết buổi (`Session`)
- **Hiển thị:** ngày giờ, thời lượng tính giờ, giáo viên, trợ giảng, sĩ số, vai trò của người xem, ghi chú (nội dung đã dạy) của buổi trước cùng lớp, học liệu, trạng thái điểm danh / hoàn tất / xác nhận, lý do trung tâm trả về (nếu Cần bổ sung), lịch sử thay đổi.
- **Hành động:** **Vào lớp** — mở link web bằng trình duyệt hệ thống; bật khi còn quyền + có link + buổi không Đã hủy; nổi bật gần giờ học. Mở học liệu. Điểm danh. Hoàn tất (ẩn với trợ giảng).

### T05 Điểm danh (`Attendance`)
- **Hiển thị:** tên học viên (không hiện liên hệ cá nhân), trạng thái từng người, số **còn chưa đánh dấu**, nhãn "Chưa lưu" khi có nháp.
- **Hành động:** chọn Có mặt / Muộn / Vắng cho từng người (nháp tự lưu trên máy sau mỗi lựa chọn); **Lưu** gửi một lần mọi học viên đã đánh dấu (người chưa đánh dấu không gửi, quy tắc 3); hiện rõ kết quả lưu.
- Mở lại khi còn nháp (kể cả sau khi chuyển sang trình duyệt lớp live rồi quay lại): khôi phục lựa chọn.

### T06 Hoàn tất buổi (`Complete`)
- **Hiển thị:** tóm tắt điểm danh đã lưu (Có mặt / Muộn / Vắng / Chưa đánh dấu) kèm cảnh báo nếu còn chưa đánh dấu; **giờ được tính = thời lượng buổi** (chỉ đọc); ô **Nội dung đã dạy** (nháp tự lưu, hiện "Đã lưu nháp").
- **Hành động:** điểm danh còn nháp chưa lưu → đưa về T05 lưu trước; **Xác nhận hoàn tất**.

### T06 — Cần bổ sung (`NeedsInfo`)
- Áp khi **giờ của người đang xem** ở Cần bổ sung (quy tắc 10). Người dạy chính: sửa được nội dung. Trợ giảng: chỉ thấy lý do + "Liên hệ trung tâm", không có ô sửa.
- **Hiển thị:** lý do trung tâm trả về và ngày trả; giờ (không sửa); nội dung đã dạy (sửa được); **lý do sửa (bắt buộc)**.
- **Hành động:** Gửi lại → Chờ xác nhận. Giá trị trước/sau và lý do vào lịch sử buổi.

### T07 Danh sách lớp (`Classes`)
- **Hiển thị:** Đang dạy / Đã kết thúc, ô tìm lớp, kỳ học, sĩ số, buổi tiếp theo, vai trò nếu là trợ giảng.
- Lớp chỉ có một buổi dạy thay không xuất hiện ở đây (mở từ Lịch).

### T08 Chi tiết lớp + T09 tối thiểu (`ClassDetail`)
- **Hiển thị:** học viên kèm tỷ lệ có mặt; chạm một học viên → lịch sử điểm danh của học viên đó tại lớp này; lịch sử buổi kèm trạng thái.
- **Hành động:** mở học viên, mở buổi.

### T10 Báo cáo giờ (`Report`)
- **Hiển thị:** tháng (chuyển trước/sau), lọc lớp; tổng **buổi hoàn tất · giờ**; nhóm **Đã xác nhận / Chờ xác nhận / Cần bổ sung** (trung tâm không duyệt: chỉ tổng); thống kê theo vai trò; lối vào "Trung tâm đã rời".
- **Hành động:** chạm nhóm → danh sách buổi cấu thành. Trung tâm không duyệt: chạm tổng → danh sách buổi cấu thành.

### T10 Buổi cấu thành + T26 Trung tâm đã rời (`ReportList`)
- **Hiển thị:** danh sách buổi khớp đúng tổng của nhóm (ngày, lớp, phút, vai trò). Trung tâm đã rời: chọn trung tâm, dòng **chỉ đọc** gồm ngày, tên lớp, phút, trạng thái xác nhận.
- **Hành động:** mở buổi (chỉ nơi còn quyền). Dòng trung tâm đã rời không mở được chi tiết, không có dữ liệu học viên.

### T12 Hồ sơ (`Profile`)
- **Hiển thị:** thông tin tài khoản, các trung tâm được cấp quyền.
- **Hành động:** Đăng xuất (xóa phiên, cache, nháp trên máy).

---

## 7. Luồng nghiệp vụ mốc 1a

### 7.1 Dạy một buổi (luồng chính)
1. Giáo viên mở buổi từ Lịch (thẻ Buổi tiếp theo hoặc danh sách ngày).
2. Bấm **Vào lớp** → trình duyệt mở lớp live trên web.
3. Trong buổi, quay lại app → **Điểm danh** → chọn trạng thái từng học viên → **Lưu**. Trợ giảng có thể điểm danh cùng lúc (xung đột: mục 8.2, trạng thái 05).
4. Hết buổi → **Hoàn tất**: xem tóm tắt điểm danh, giờ được tính, nhập nội dung đã dạy → **Xác nhận hoàn tất**.
5. Trung tâm có duyệt → **Chờ xác nhận**; không duyệt → vào báo cáo ngay.
6. **Báo cáo giờ** tháng → chạm nhóm → thấy đúng buổi vừa dạy.

### 7.2 Buổi bị trả về (Cần bổ sung)
Lịch → Cần xử lý (hoặc huy hiệu trên bộ chuyển nếu ở nơi khác) → buổi Cần bổ sung → đọc lý do → sửa nội dung + lý do sửa → **Gửi lại** → Chờ xác nhận.

### 7.3 Dạy thay
Trung tâm chuyển buổi cho giáo viên khác. Người dạy thay thấy buổi với nhãn "Dạy thay", điểm danh và hoàn tất được, không mở được chi tiết lớp. Giáo viên gốc thấy dòng mờ "Đã chuyển người dạy". Lịch sử thay đổi của buổi ghi lần chuyển. Giờ tính cho người dạy thay.

### 7.4 Trợ giảng
Trợ giảng thấy buổi với nhãn "Trợ giảng", vào lớp, điểm danh; không hoàn tất. Giờ trợ giảng ghi nhận khi buổi hoàn tất. Quá giờ mà giáo viên chính chưa hoàn tất: nhãn "Chờ giáo viên chính hoàn tất · liên hệ trung tâm nếu cần"; trung tâm chốt hộ.

### 7.5 Đổi lịch, hủy buổi
Trung tâm đổi giờ/thời lượng/hủy. App hiện lịch mới, nhãn Đã hủy; giữ buổi trong lịch sử. Đổi thời lượng → giờ được tính theo thời lượng mới (quy tắc 1). Buổi đổi khi giáo viên đang mở: trạng thái 06 (mục 8.2).

### 7.6 Chuyển nơi làm việc và trung tâm đã rời
Chuyển nơi: tải lại toàn bộ dữ liệu theo nơi mới, nháp giữ theo nơi. Sau khi rời trung tâm: không còn trong bộ chuyển; Báo cáo → Trung tâm đã rời hiện lịch sử chỉ đọc.

---

## 8. Trạng thái

### 8.1 Trạng thái dữ liệu (theo dõi riêng từng loại)

| Loại | Giá trị |
|---|---|
| Buổi | Đã lên lịch / Đã hoàn tất / Đã hủy |
| Điểm danh của buổi | Chưa lưu / Đã lưu (kèm số còn chưa đánh dấu) |
| Điểm danh từng học viên | Chưa đánh dấu (chưa có bản ghi đã lưu) / Có mặt / Đi muộn / Vắng |
| Xác nhận giờ (theo từng người, chỉ khi trung tâm có duyệt) | Chờ xác nhận / Đã xác nhận / Cần bổ sung |

"Buổi đã chốt" **với người đang xem** = buổi Đã hoàn tất **và** giờ của người đó không ở Cần bổ sung → chỉ đọc.

### 8.2 Trạng thái màn bắt buộc (mock: artboard `States`)

| # | Tình huống | Hành vi |
|---|---|---|
| 01 | Chưa được giao lớp | Lịch trống, giải thích lịch sẽ hiện khi được phân công, nơi liên hệ |
| 02 | Hôm nay không có lịch | Hiện buổi gần nhất + đường vào lịch tuần |
| 03 | Báo cáo kỳ đã chọn không có dữ liệu | Hiện bộ lọc đang chọn, cho đổi tháng / bỏ lọc |
| 04 | Lưu lỗi / mất mạng | Giữ dữ liệu đang nhập, báo lỗi, nút Thử lại; không tạo bản ghi trùng |
| 05 | Người khác (chính/trợ giảng) vừa lưu điểm danh | "Điểm danh đã thay đổi", tải bản mới, giữ lựa chọn chưa lưu để đối chiếu trước khi lưu |
| 06 | Buổi đổi khi đang mở | Hiện bản mới, giữ nháp, hỏi xác nhận lại trước khi gửi |
| 07 | Buổi chuyển người dạy / mất quyền khi đang nhập | Màn mất quyền, xóa nháp buổi đó, không cho gửi |
| 08 | Ngoài thời gian cho phép | Nút Điểm danh / Hoàn tất khóa, ghi lý do |
| 09 | Buổi đã chốt | Chỉ đọc, "Liên hệ trung tâm để điều chỉnh" |
| 10 | Link cũ / mất quyền | "Bạn không còn quyền xem buổi này", về Lịch; không hiện dữ liệu cache |
| 11 | Offline, mở màn cần dữ liệu học viên | "Không thể tải khi ngoại tuyến" + Thử lại; không hiện danh sách |
| 12 | Trợ giảng, giáo viên chính chưa hoàn tất | "Chờ giáo viên chính hoàn tất · liên hệ trung tâm" |

---

## 9. Báo cáo giờ

| Chỉ số | Định nghĩa | Đối chiếu được |
|---|---|---|
| Buổi đã hoàn tất | Số buổi Đã hoàn tất mà người xem là người dạy (chính, dạy thay hoặc trợ giảng), trong kỳ, tại nơi hiện tại | Danh sách buổi và lớp |
| Giờ dạy | Tổng thời lượng cố định của các buổi trên | Thời lượng từng buổi |
| Giờ đã xác nhận | Tổng từ các buổi có giờ của người xem Đã xác nhận | Buổi nào đã xác nhận |
| Giờ chờ xác nhận | Tổng từ các buổi đang Chờ xác nhận | Buổi nào đang chờ |
| Giờ cần bổ sung | Tổng từ các buổi bị trả về | Buổi nào bị trả về, lý do |

Tổng = tất cả buổi Đã hoàn tất của người xem trong kỳ. Trung tâm có duyệt: tổng bằng cộng 3 nhóm. Trung tâm không duyệt: không chia nhóm, tổng tính trực tiếp. Tổng luôn khớp danh sách chi tiết. Mỗi dòng ghi vai trò Chính / Dạy thay / Trợ giảng; mỗi người chỉ tính một lần cho một buổi.

**Ví dụ:** 12 buổi hoàn tất × 90 phút = **18 giờ**, gồm 10 buổi / 15 giờ đã xác nhận và 2 buổi / 3 giờ chờ xác nhận. Một buổi 90 phút mà giáo viên dạy 110 phút vẫn tính 90 phút; dạy 75 phút cũng tính 90 phút.

---

## 10. Quyền và bảo mật mobile

### 10.1 Quyền
- Mọi đọc và ghi kiểm ở API theo phân công lớp hoặc buổi trong nơi làm việc (mục 11). App áp cùng quy tắc cho danh sách, bộ đếm, tìm kiếm, link mở trực tiếp và dữ liệu trên máy.
- Ngoại lệ duy nhất: giáo viên luôn xem được lịch sử buổi Đã hoàn tất của chính mình (ngày, tên lớp, phút, trạng thái xác nhận), kể cả sau khi rời trung tâm; không kèm dữ liệu học viên.
- Quyền bị thu hồi khi màn đang mở: báo thay đổi quyền, đưa về màn hợp lệ, xóa cache và nháp của phạm vi đó.

### 10.2 Bảo mật phía mobile
1. Token trong Keychain (iOS) / Keystore (Android). Đăng xuất: xóa token, cache, nháp.
2. **Không lưu danh sách học viên vào bộ nhớ lâu dài.** Chỉ cache lâu dài lịch của nơi hiện tại. Dữ liệu học viên chỉ nằm trong bộ nhớ khi app đang mở.
3. Ngoại lệ: nháp điểm danh / hoàn tất chưa gửi, lưu trong sandbox app, gắn với (nơi, buổi); xóa khi gửi xong, khi buổi đã được chốt (kể cả trung tâm chốt hộ), khi đăng xuất, hoặc khi BE báo mất quyền buổi đó.
4. Chuyển nơi: xóa cache truy vấn nơi cũ, tải lại; nháp giữ theo nơi.
5. Link mở trực tiếp: luôn hỏi BE trước khi hiển thị, không dựng màn từ cache.
6. Mở app từ nền: tải lại buổi đang mở, áp quyền mới nhất.
7. Lớp live mở bằng Custom Tabs / SFSafariViewController. **Không gắn token của app vào URL.** Web tự xác thực.
8. Học liệu, link phòng chỉ lấy từ BE sau khi kiểm quyền. Ẩn URL không phải biện pháp bảo mật; quyền vào phòng kiểm ở dịch vụ phòng.
9. Log / crash report không chứa dữ liệu học viên. Chỉ hiển thị tên học viên, không liên hệ cá nhân.
10. **Rủi ro chấp nhận:** dữ liệu học viên đang hiện trên màn đúng lúc bị thu hồi quyền khi máy offline còn tới khi app tải lại.

---

## 11. Điều app cần từ BE

BE tự thiết kế; app phụ thuộc các hành vi sau.

1. Kiểm quyền đối tượng ở mọi API theo membership + phân công (lớp hoặc buổi), kể cả truy vấn theo `student_id`; không tin `workspace_id` gửi từ app.
2. Báo cáo / lịch sử luôn trả buổi Đã hoàn tất của chính giáo viên (ngày, tên lớp, phút, trạng thái xác nhận), kể cả trung tâm đã rời; không trả dữ liệu học viên.
3. Trả mã xung đột + bản mới khi buổi hoặc điểm danh đã đổi so với bản app đang giữ.
4. Lưu điểm danh trong một lần (mọi học viên đã đánh dấu; người chưa đánh dấu không gửi); retry không tạo trùng. Hoàn tất retry an toàn.
5. Danh sách học viên của buổi đã chốt không đổi theo chỉnh sửa ghi danh về sau.
6. Trả trạng thái được / không được điểm danh, hoàn tất cho từng buổi.
7. Học liệu, link phòng chỉ trả khi còn quyền.
8. Số "Cần xử lý" theo từng trung tâm của giáo viên.
9. Lý do trung tâm trả về khi chuyển giờ sang Cần bổ sung.
10. Vai trò của người xem trên buổi (chính / dạy thay / trợ giảng); điểm danh cho người dạy chính + trợ giảng, hoàn tất chỉ người dạy chính.
11. Giờ mỗi người = thời lượng buổi; trạng thái xác nhận theo từng người; báo cáo theo người + vai trò.
12. Trung tâm chốt hộ buổi khi giáo viên chính không hoàn tất.
13. Lịch sử thay đổi của buổi (đổi giờ, đổi người dạy, sửa khi Cần bổ sung): trước/sau, lý do, người, thời điểm.

---

## 12. Kịch bản nghiệm thu mốc 1a

| # | Given | When | Then |
|---|---|---|---|
| K1 | Giáo viên có trung tâm A, B | Mở app | Header mọi tab hiện nơi hiện tại; bộ chuyển có số Cần xử lý từng nơi |
| K2 | Buổi 18:30–20:00 (90 phút) có link | Lịch → buổi → Vào lớp → điểm danh 20 học viên → Lưu → Hoàn tất | Buổi Chờ xác nhận; báo cáo tháng +1 buổi / 90 phút ở nhóm Chờ |
| K3 | Mất mạng khi Lưu điểm danh | Thử lại | Lựa chọn còn nguyên, không tạo bản ghi trùng |
| K4 | Buổi bị trả về Cần bổ sung, giáo viên đang ở B | Thấy số ở bộ chuyển → chuyển A → Cần xử lý → buổi | Thấy lý do; sửa nội dung + lý do; Gửi lại → Chờ xác nhận |
| K5 | Giáo viên dạy thay 1 buổi lớp X | Mở buổi | Nhãn Dạy thay; điểm danh, hoàn tất được; không mở được lớp X; giáo viên gốc thấy "Đã chuyển người dạy"; lịch sử buổi ghi lần chuyển |
| K6 | 12 buổi hoàn tất, mỗi buổi 90 phút: 10 đã xác nhận + 2 chờ | Báo cáo → chạm từng nhóm | Danh sách 10 và 2 buổi; tổng 18 giờ = 15 + 3, khớp chi tiết |
| K7 | Giáo viên đã rời trung tâm C | Báo cáo → Trung tâm đã rời → C | Dòng chỉ đọc, không mở chi tiết, không có tên học viên |
| K8 | Quyền lớp bị thu hồi | Mở link cũ | Màn "không còn quyền", về Lịch, không hiện dữ liệu cache |
| K9 | Máy offline sau khi bị thu hồi quyền | Mở lớp | "Không thể tải khi ngoại tuyến", không hiện danh sách |
| K10 | Đang nhập Hoàn tất, trung tâm đổi giờ buổi | Xác nhận | Hiện bản mới, nháp giữ, hỏi xác nhận lại |
| K11 | Nháp điểm danh ở A chưa lưu | Chuyển B rồi về A, mở Điểm danh | Lựa chọn được khôi phục, nhãn "Chưa lưu" |
| K12 | Buổi đã hủy còn link phòng | Mở chi tiết buổi | Nút Vào lớp tắt |
| K13 | Đang nhập Hoàn tất, buổi chuyển cho giáo viên khác | Bấm Xác nhận | Màn mất quyền, nháp buổi đó bị xóa, không gửi |
| K14 | Chính và trợ giảng cùng mở Điểm danh | Chính lưu trước, trợ giảng lưu bản cũ | Trợ giảng thấy "Điểm danh đã thay đổi", bản mới + lựa chọn chưa lưu để đối chiếu |
| K15 | Lớp đã kết thúc, chính quên hoàn tất | Trợ giảng mở Lịch | Nhãn "Chờ giáo viên chính hoàn tất · liên hệ trung tâm"; trung tâm chốt hộ thì giờ vào báo cáo của cả hai |

Ngoài ra, thử tác vụ trên một tài khoản có 2 trung tâm: người dùng nhận biết đúng nơi làm việc, vào buổi nhanh, hiểu trạng thái lưu, tìm được nguồn số liệu.

---

## 13. Thứ tự build đề xuất

| # | Việc | Xong khi |
|---|---|---|
| 1 | Khung app: đăng nhập bằng auth sẵn có, lưu token an toàn, tab bar, header nơi làm việc, bộ chuyển | Đăng nhập / đăng xuất xóa sạch; chuyển nơi tải lại dữ liệu |
| 2 | Lịch + Chi tiết buổi + Vào lớp | K1; nhãn vai trò đúng; mở trình duyệt không kèm token |
| 3 | Điểm danh: nháp từng lựa chọn, lưu cả danh sách, xung đột | K3, K11, K14 |
| 4 | Hoàn tất + Cần bổ sung + mục Cần xử lý | K2, K4, K10, K13, K15 |
| 5 | Lớp + chi tiết lớp | K5 (không mở được lớp khi dạy thay) |
| 6 | Báo cáo + buổi cấu thành + trung tâm đã rời | K6, K7 |
| 7 | Trạng thái màn + rà bảo mật (link trực tiếp, offline, cache) | K8, K9, K12; đủ 12 trạng thái mục 8.2 |

---

## 14. Quyết định và lý do

Chỉ ghi quyết định đang có hiệu lực. "Codex", "Claude" là bên đề xuất trong quá trình review chéo; "PO" là product owner xác nhận.

| Quyết định | Lý do |
|---|---|
| Giờ = thời lượng cố định, dạy thêm/thiếu đều tính đủ | PO chốt. Bỏ được phụ thuộc vào nhật ký live, ô nhập giờ và trạng thái chờ dữ liệu. |
| Đợt 1 giữ phạm vi spec gốc nhưng chia mốc 1a / 1b | Spec gốc yêu cầu xin nghỉ, bài tập ở Đợt 1 (Codex); tách mốc để vòng dạy chính chạy trước (Claude). |
| Không bắt buộc đánh dấu đủ mới hoàn tất, chỉ cảnh báo | Danh sách trung tâm cấp có thể sai hoặc đổi sát giờ; bắt buộc sẽ khóa buổi dạy (Codex bác đề xuất của Claude). |
| "Chưa đánh dấu" là trạng thái hiển thị, không lưu | Chưa có bản ghi đã lưu là đủ biểu diễn; không thêm trạng thái dữ liệu (Claude, Codex đồng ý). |
| Lưu điểm danh cả danh sách một lần | Lưu từng người dễ lưu một nửa khi lỗi mạng; ghi đè muộn có thể đè lựa chọn mới hơn (Codex bác last-write-wins của Claude). |
| Nháp điểm danh tự lưu sau từng lựa chọn | Giáo viên chuyển qua lại giữa app và trình duyệt lớp live suốt buổi (Claude). |
| Nháp giữ theo từng nơi khi chuyển trung tâm | Xóa nháp khi chuyển nơi làm mất điểm danh chưa gửi (Codex bác Claude). |
| Cần bổ sung chỉ sửa nội dung | Giờ cố định; sửa điểm danh sau chốt mở quyền quá rộng (Codex). |
| Xác nhận giờ theo từng người | Một trạng thái chung không cho biết giờ của ai bị trả về (Codex bác Claude). |
| Trung tâm chốt hộ khi giáo viên chính quên hoàn tất | Nếu không, trợ giảng mất giờ (Codex bác "chấp nhận rủi ro" của Claude). |
| Trợ giảng thấy buổi, không bị ẩn | Ẩn đi thì trợ giảng không tìm được lớp để vào (Codex). |
| Người dạy thay chỉ thấy buổi được giao, không thấy cả lớp | Giới hạn dữ liệu học viên ở mức cần cho buổi đó (Claude, Codex đơn giản hóa). |
| Không lưu danh sách học viên lâu dài trên máy | Giáo viên bị thu hồi quyền lúc offline không mở lại được danh sách cũ; riêng danh sách đang hiện trên màn lúc đó còn tới khi app tải lại — rủi ro chấp nhận ở 10.2 (Claude, trả lời rủi ro Codex nêu). |
| Link trực tiếp luôn hỏi BE trước khi hiển thị | Link thông báo cũ sau khi mất quyền không được lộ dữ liệu lớp (spec gốc, Codex kiểm). |
| Lịch sử trung tâm đã rời chỉ gồm ngày, lớp, phút, trạng thái | Spec gốc chỉ đề xuất các trường này; dữ liệu học viên cũ chưa được phép xem (Codex thu hẹp đề xuất của Claude). |
| Tên trung tâm ở header mọi tab, Báo cáo theo nơi hiện tại | Tránh nhầm nơi làm việc và hai nguồn lọc mâu thuẫn (Claude, Codex đồng ý). |
| Số Cần xử lý theo từng nơi trên bộ chuyển | Chưa có thông báo ở 1a; không có số này thì sót buổi bị trả về ở nơi khác (Codex). |
| Hoàn tất khi còn nháp điểm danh → về Điểm danh lưu trước | Không tự ghi dữ liệu khi người dùng bấm nút khác (Codex đơn giản hóa Claude). |
| Bỏ "Còn lại: Có mặt" | Thao tác hàng loạt ngoài spec, dễ đánh dấu nhầm (Codex). |
| Không cảnh báo khi chuyển nơi, không ẩn URL phòng | Cảnh báo thừa vì nháp đã giữ; ẩn URL không phải kiểm soát thật (Claude, Codex đồng ý). |
| Nút Vào lớp tắt khi buổi Đã hủy | Link phòng có thể còn tồn tại sau khi hủy (Codex). |

---

## 15. Mốc 1b và Đợt 2 — giữ từ spec gốc, chưa chi tiết hóa

Phần này cần plan và review riêng trước khi code. Nội dung dưới là yêu cầu của spec gốc.

### 15.1 Mốc 1b

| ID | Màn | Dữ liệu | Hành động |
|---|---|---|---|
| T11 | Thông báo | Buổi sắp dạy, lịch đổi, kết quả xin nghỉ, việc cần hoàn tất, phản hồi xác nhận | Mở đúng đối tượng, đánh dấu đã đọc |
| T21 | Danh sách bài tập | Lớp/khóa, hạn nộp, số bài cần chấm | Lọc, tạo bài, mở bài nộp |
| T22 | Soạn và giao bài | Yêu cầu, tệp, lớp/bài học, hạn nộp | Lưu nháp, giao, cập nhật |
| T23 | Bài nộp và chấm | Học viên, bài nộp, thời điểm, điểm, phản hồi | Lưu nháp chấm, trả kết quả |
| T24 | Gửi đơn xin nghỉ | Trung tâm, buổi/khoảng thời gian, lý do, lớp ảnh hưởng | Xem lại và gửi |
| T25 | Theo dõi đơn xin nghỉ | Chờ duyệt, đã duyệt, từ chối, đã rút, phản hồi | Mở chi tiết, rút đơn nếu có quyền |

**Xin nghỉ:** mở từ lịch hoặc chi tiết buổi → chọn trung tâm, buổi/khoảng thời gian → xem lớp ảnh hưởng → nhập lý do, gửi → Chờ duyệt (lịch hiện tại vẫn hiệu lực) → trung tâm duyệt/từ chối, giáo viên nhận thông báo → trung tâm cập nhật người dạy thay / lịch mới / hủy. Giờ tính cho người dạy thực tế.

**Bài tập:** chọn lớp/khóa → tạo bài, yêu cầu, tệp, hạn → trạng thái Chưa nộp / Đã nộp / Đã trả kết quả, nhãn Nộp muộn → mở bài nộp, lưu nháp điểm/nhận xét, trả kết quả → học viên xem phản hồi. Hàng chờ chấm mở từ Lịch hoặc Chi tiết lớp.

**Câu hỏi cần chốt trước 1b:** ai duyệt đơn nghỉ, báo trước bao lâu, khi nào được rút; chấm bằng điểm, nhận xét hay cả hai; có cho nộp lại / chấm lại không; tiến độ và nhận xét học viên hiển thị gì.

### 15.2 Đợt 2 — Dạy riêng

| ID | Màn | Dữ liệu | Hành động |
|---|---|---|---|
| T13 | Khóa học của tôi | Danh sách khóa, nháp/đang hiển thị, lớp đang mở, lượt bán | Tạo, tìm, mở khóa |
| T14 | Chi tiết và chỉnh sửa khóa | Mô tả, nội dung, mô hình giá, lớp liên quan, hiển thị | Lưu nháp, cập nhật, mở lớp, ngừng tuyển |
| T15 | Mở hoặc chỉnh lớp riêng | Khóa nguồn, lịch, hình thức, sĩ số tối đa, thời gian tuyển | Lưu nháp, mở tuyển, đổi/đóng lớp |
| T16 | Ghi danh | Học viên, ngày ghi danh, trạng thái, đơn liên quan | Xem, thêm thủ công, xử lý theo chính sách |
| T17 | Báo cáo doanh thu | Kỳ, khóa/lớp, lượt bán, tiền bán, giảm giá, hoàn tiền, phí, được hưởng | Lọc, mở giao dịch cấu thành |
| T18 | Giao dịch bán khóa | Khoản thu, trạng thái, thời điểm thanh toán, hoàn tiền, nguồn chi trả | Tra cứu, mở chi tiết |
| T19 | Chi trả | Chờ chuyển, đang xử lý, đã chuyển, thất bại, khoản cấu thành | Đối chiếu, mở chi tiết, phương thức nhận tiền ở Hồ sơ |
| T27 | Nội dung khóa học | Phần, bài học, học liệu, bài tập, trạng thái công bố | Xem hoặc chỉnh khóa của mình |

**Luồng:** tạo khóa nháp (tên, mô tả, hình thức, giá) → tạo lớp từ khóa (ngày bắt đầu, lịch, sức chứa, tuyển sinh) → kiểm tra điều kiện mở tuyển → ghi danh xuất hiện trong lớp, đơn hàng hiện theo quyền → đủ chỗ/ngừng tuyển vẫn giữ lớp và ghi danh. Lưu giá và tỷ lệ phí tại thời điểm giao dịch.

**Tài chính:** báo cáo bán theo **ngày giao dịch**, giờ dạy theo **ngày buổi học**, tiền về theo **ngày chuyển/nhận**. Tiền được hưởng = tiền khách thanh toán − hoàn tiền − phí do giáo viên chịu (+ khoản trả theo buổi nếu hợp đồng có). Ví dụ spec gốc: giá 5.200.000 ₫, giảm 200.000 ₫, khách trả 5.000.000 ₫, hoàn 300.000 ₫, phí 300.000 ₫ → được hưởng 4.400.000 ₫. Khóa 8 buổi bán trọn gói tạo 8 bản ghi giảng dạy, không cộng thu nhập lần hai.

**Câu hỏi cần chốt trước Đợt 2:** tỷ lệ phí và tính trên số tiền nào; lịch chi trả, điều kiện chi trả, hoàn tiền sau khi đã chuyển; lớp live bán độc lập hay nằm trong khóa; lịch sử trung tâm giữ bao lâu.

---

## 16. Còn mở

1. Phát hành riêng mốc 1a hay chờ xong 1b.
2. Mốc mở/khóa điểm danh cụ thể của từng trung tâm (BE trả về; trung tâm cần cấu hình).
3. Các câu hỏi trước 1b và Đợt 2 ở mục 15.
