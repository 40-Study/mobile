# Parent Mobile App — UX Deliverable (A–H)

**Gate còn mở, ngoài phạm vi UX**: chính sách dữ liệu/privacy cho Analytics & Recommendation (lawful basis, retention, quyền xóa, audit trail — mục H) và điều kiện dữ liệu cho focus/engagement score. Thiết kế không phụ thuộc kết quả cụ thể của các gate này.

Auth (đăng nhập, đăng ký, khôi phục mật khẩu, OTP...) và Security (đổi mật khẩu) nằm ngoài phạm vi tài liệu này — app được coi như đã đăng nhập, bắt đầu từ Home.

---

## A. Information Architecture

```text
App
├── Home (family scope — không có child selector)
│   ├── Above the fold
│   │   ├── Cần xử lý — mỗi item tự mang tên con; stable summary row nếu rỗng
│   │   └── Hôm nay / Tiếp theo — mọi con, sắp theo thời gian
│   └── Below the fold
│       └── Learning insight được cập nhật gần nhất
│           ├── CTA từng item: "Xem phân tích của [con]" → Learning/Insights (đúng child)
│           └── CTA "Xem tất cả phân tích" (khi nhiều hơn số hiện) → Family Insights Inbox
│
├── Schedule (child scope — child selector ở root)
│   ├── Today / This week / Upcoming
│   └── Schedule Detail (locked child context)
│
├── Learning (child scope — child selector ở root)
│   ├── Insights / Phân tích
│   │   ├── Tổng quan kỳ hiện tại
│   │   ├── Xu hướng qua nhiều buổi
│   │   ├── Phân tích theo lớp/kỹ năng/dạng hoạt động
│   │   └── Điểm nổi bật / cần cải thiện → Evidence (lesson/activity liên quan)
│   ├── Classes → Class Detail → Lesson Detail (locked child context)
│   │     ├── tab Tổng quan
│   │     └── tab Kết quả & nhận xét → Phân tích chi tiết theo buổi
│   │           (KHÔNG gồm focus/engagement score — tạm hoãn)
│   ├── Homework → Homework Detail
│   ├── Progress → Progress Detail (theo khóa/lớp)
│   └── Recommended Courses → Course Detail
│
├── Payment (family scope — tab riêng)
│   ├── Overview (tổng hợp tất cả con, breakdown theo con)
│   ├── Invoice/Payment Detail
│   ├── Checkout → Payment Result
│   └── History
│
├── Profile (parent scope)
│   ├── Quản lý con
│   │     ├── Add/Link Child
│   │     └── Child Detail → Child Edit
│   ├── Parent Profile Edit
│   ├── Notification Settings
│   ├── Settings (ngôn ngữ...)
│   └── Help/Support
│
└── Notifications (family scope — icon ở Home, không lặp lại trên mọi screen)
      → deep-link trực tiếp tới màn đích, hoặc Notification Detail (chỉ khi thông báo không có đích cụ thể, ví dụ thông báo hệ thống)

[Ngoài cây IA, truy cập từ Home]
Family Insights Inbox (family scope — liệt kê insight mọi con)

[Ngoài cây IA, truy cập từ Profile → Quản lý con khi chưa có/muốn thêm con]
Add/Link Child — nhập mã liên kết do trung tâm cấp → xác nhận → Quản lý con (đã có con mới)
```

### Thuật ngữ scope (áp dụng xuyên suốt toàn bộ tài liệu)

| Scope | Đặc điểm | Áp dụng cho |
|---|---|---|
| **Family scope** | Không có child selector; mỗi item tự mang tên/avatar con | Home, Payment, Notifications, Family Insights Inbox |
| **Child scope** | Child selector chỉ ở root, đổi con cập nhật toàn bộ nội dung tại chỗ | Schedule, Learning |
| **Locked child context** | Không có selector; title/subtitle ghi rõ tên con | Class/Lesson/Homework/Schedule Detail |
| **Parent scope** | Không liên quan đến con cụ thể nào | Profile |

5 bottom tab: **Home, Schedule, Learning, Payment, Profile**. Notification là icon (không phải tab). Children không phải tab — là child selector theo scope ở trên.

---

## B. Screen Inventory

Priority = mức độ cần thiết của chức năng UX (không phải xếp hạng phương án): **Must** = không thể thiếu để trả lời câu hỏi cốt lõi; **Should** = tăng giá trị rõ rệt nhưng app vẫn dùng được nếu thiếu; **Could** = cân nhắc theo nguồn lực.

| # | Screen | Purpose | Entry point | Primary action | Priority |
|---|---|---|---|---|---|
| 1 | Home | Trả lời câu hỏi hằng ngày cho mọi con | Tab Home (mặc định khi mở app) | Tap item "Cần xử lý" | Must |
| 2 | Family Insights Inbox | Liệt kê insight mọi con khi Home không đủ chỗ | CTA "Xem tất cả phân tích" ở Home | Chọn insight để drill-down | Should |
| 3 | Schedule | Xem lịch theo con đã chọn | Tab Schedule | Chọn buổi học | Must |
| 4 | Schedule Detail | Chi tiết 1 buổi/lịch | Schedule list, Home, notification | Xem giờ/hình thức học; vào Lesson nếu có | Must |
| 5 | Learning (root) | Điều hướng Insights/Classes/Homework/Progress/Courses | Tab Learning | Chọn section | Must |
| 6 | Insights / Phân tích | Xu hướng nhiều buổi, diễn giải có bằng chứng | Learning root, Home insight, Family Insights Inbox | Xem Observation/Interpretation, tap Evidence | Must (core) |
| 7 | Classes (list) | Danh sách lớp đang học | Learning root | Chọn lớp | Must |
| 8 | Class Detail | Thông tin lớp, danh sách buổi học | Classes list | Chọn buổi học (lesson) | Must |
| 9 | Lesson Detail | Tổng quan + kết quả/phân tích 1 buổi | Class Detail, Schedule Detail, notification | Xem kết quả; mở phân tích chi tiết | Must |
| 10 | Homework (list) | Toàn bộ bài tập, lọc trạng thái | Learning root, Home (bản rút gọn) | Lọc + chọn bài | Must |
| 11 | Homework Detail | Chi tiết 1 bài tập — chỉ theo dõi, không nộp thay con | Homework list, notification, Home | Xem deadline/trạng thái/kết quả | Must |
| 12 | Progress | Completion/tiến độ theo khóa | Learning root | Chọn khóa để xem chi tiết | Must |
| 13 | Progress Detail | Chi tiết tiến độ 1 khóa/lớp | Progress list | Xem breakdown theo mốc | Should |
| 14 | Recommended Courses (list) | Gợi ý khóa học | Learning root | Chọn khóa | Should |
| 15 | Course Detail | Thông tin khóa học gợi ý | Recommended Courses list | Xem lý do gợi ý → bắt đầu Enrollment | Should |
| 16 | Enrollment / Đăng ký khóa học | Xác nhận đăng ký (lịch học, hình thức) trước khi tính phí | Course Detail "Đăng ký" | Xác nhận đăng ký → Checkout (nếu có phí) hoặc Enrollment Result | Should |
| 17 | Enrollment Result | Xác nhận kết quả đăng ký/yêu cầu tư vấn | Sau Enrollment (hoặc sau Checkout nếu có phí) | Xem trạng thái, quay về Course Detail/Learning | Should |
| 18 | Payment Overview | Tổng khoản cần đóng và đã đóng của mọi con | Tab Payment, Home alert | Chọn khoản để xem/thanh toán | Must |
| 19 | Payment/Invoice Detail | Chi tiết 1 khoản | Payment Overview, notification | Pay now | Must |
| 20 | Checkout | Nhập/xác nhận thanh toán | Payment Detail "Pay now", Enrollment (nếu khóa có phí) | Xác nhận thanh toán | Must |
| 21 | Payment Result | Kết quả giao dịch, gồm cả trạng thái đang xử lý/không rõ | Sau Checkout | Xem trạng thái, kiểm tra lại nếu chưa rõ, quay về Overview | Must |
| 22 | Payment History | Lịch sử đã đóng | Payment Overview "Xem lịch sử" | Xem/tải hóa đơn cũ | Should |
| 23 | Notification Center | Danh sách thông báo | Icon ở Home | Tap để deep-link | Must |
| 24 | Notification Detail (generic) | Cho thông báo không có đích cụ thể (system) | Notification Center | Đọc nội dung | Could |
| 25 | Profile (root) | Điều hướng tài khoản | Tab Profile | Chọn mục | Must |
| 26 | Quản lý con (list) | Danh sách con, hoặc empty state để liên kết con đầu tiên | Profile | Chọn con để xem, hoặc "Liên kết hồ sơ con" | Must |
| 27 | Add/Link Child | Liên kết hồ sơ con bằng mã do trung tâm cấp | Quản lý con (CTA khi rỗng hoặc thêm mới) | Nhập mã liên kết → xác nhận | Must |
| 28 | Child Detail | Xem thông tin 1 con (không sửa) | Quản lý con | Xem thông tin; vào Child Edit nếu cần sửa | Must |
| 29 | Child Edit | Sửa thông tin liên hệ cơ bản của con, trong quyền hạn phụ huynh | Child Detail "Sửa" | Lưu thay đổi | Should |
| 30 | Parent Profile Edit | Sửa thông tin phụ huynh | Profile | Lưu | Should |
| 31 | Notification Settings | Bật/tắt loại thông báo | Profile | Toggle theo loại | Should |
| 32 | Settings | Ngôn ngữ, cấu hình chung | Profile | Chọn ngôn ngữ | Could |
| 33 | Help/Support | Liên hệ hỗ trợ | Profile | Gửi yêu cầu hỗ trợ | Should |

---

## C. User Flows

### Flow 1 — Kiểm tra hôm nay

```text
Open App
→ Home (family scope — "Cần xử lý" + "Hôm nay/Tiếp theo" của mọi con cùng lúc)
→ Tap sự kiện của con X
→ Schedule Detail / Lesson Detail (locked child context = con X)
```

### Flow 2 — Kiểm tra bài tập

```text
Home ("Cần xử lý" đã liệt kê bài quá hạn/sắp hết hạn của từng con)
→ Tap thẳng vào Homework Detail (nếu mở từ Home)

Hoặc, xem toàn bộ:
Learning (chọn child ở root) → Homework (list đầy đủ) → filter trạng thái → Homework Detail
```

### Flow 3 — Xem kết quả một buổi học

```text
Home → Learning (child đã chọn sẵn ở root, không hỏi lại)
→ Classes → Class Detail → Lesson Detail
   (tab Tổng quan | tab Kết quả & nhận xét → Phân tích chi tiết nếu cần đào sâu)
```

4 bước điều hướng — bỏ bước "Select Child" thừa vì child scope đã chọn ở root Learning. "Đã chọn sẵn" dựa trên quy tắc **child selection state**:

- **1 state dùng chung** cho toàn bộ child scope (Schedule và Learning dùng chung 1 "active child", không phải mỗi tab tự nhớ riêng) — tránh phụ huynh mở Schedule đang xem con A rồi sang Learning lại thấy con B.
- **Lần đầu mở child scope** (chưa từng chọn): mặc định là con đầu tiên theo thứ tự tạo hồ sơ (hoặc thứ tự trung tâm trả về) — không mặc định ngẫu nhiên.
- **Lưu qua phiên đăng nhập**: active child được lưu theo parent account (không phải theo thiết bị/session tạm), để lần mở app sau vẫn giữ đúng con đã xem gần nhất.
- **Deep link override**: khi vào child scope qua deep link (từ Home insight, notification, Family Insights Inbox), active child bị **ghi đè** bằng đúng `child_id` trong link — không giữ nguyên active child cũ rồi hiển thị sai nội dung.
- Nếu tài khoản chỉ có 1 con: không có khái niệm "chọn" — active child luôn là con duy nhất đó, child selector có thể ẩn hoặc hiện dạng tĩnh không cho tap (xem thêm chiến lược no-child ở mục D).

### Flow 4 — Xem tiến độ / xu hướng tổng thể

```text
Learning (child đã chọn ở root)
├── Progress → chọn khóa → Progress Detail          (trả lời "đã học đến đâu")
└── Insights → xem Observation/Interpretation
              → tap Evidence → Lesson liên quan       (trả lời "học thế nào, thay đổi ra sao")
```

Tách 2 nhánh vì Progress và Insights trả lời 2 câu hỏi khác nhau (xem mục A/E).

### Flow 5 — Xem khóa học được đề xuất

**2 khái niệm khác nhau** — cần để CTA "Đăng ký" không hiển thị "đã đăng ký" khi thanh toán chưa được xác nhận:

```text
Enrollment request/reservation
→ tạo trước hoặc trong Checkout (giữ chỗ/khóa lịch tạm thời)
→ trạng thái: pending_payment

Confirmed enrollment
→ chỉ được tạo/kích hoạt khi Payment Success
→ đây mới là "đã đăng ký" theo đúng nghĩa (có hiệu lực, xuất hiện trong Learning/Classes)
```

```text
Learning → Recommended Courses → Course Detail
→ Đọc lý do gợi ý ("Gợi ý cho [con]" hoặc "Phổ biến với [độ tuổi]")
→ Xem lịch học / học phí
→ Enrollment (xác nhận lịch học/hình thức) → tạo Enrollment request/reservation (pending_payment)
   → nếu khóa miễn phí hoặc quy trình là tư vấn: không qua Payment, request được xác nhận ngay
      → Enrollment Result trực tiếp ("Yêu cầu đã gửi, trung tâm sẽ liên hệ" — nếu hệ thống chưa hỗ trợ đăng ký tự động)
   → nếu khóa có phí: Checkout → Payment Result, rẽ nhánh theo kết quả thanh toán:
        Payment Success  → reservation chuyển thành Confirmed enrollment → Enrollment Result: "Đã đăng ký"
        Payment Failed   → reservation bị hủy/hết hạn, KHÔNG có confirmed enrollment; quay lại Checkout/Enrollment để thử lại
        Payment Pending/
        Unknown          → reservation vẫn ở pending_payment, CHƯA có confirmed enrollment
                            → Enrollment Result: "Đang chờ xác nhận thanh toán"
                            (tự chuyển thành Confirmed enrollment khi có kết quả đối soát cuối cùng)
```

CTA ở Course Detail đổi nhãn theo đúng nhánh hệ thống hỗ trợ ("Đăng ký ngay" vs "Yêu cầu tư vấn"), không hardcode 1 nhãn cố định.

### Flow 6 — Thanh toán học phí

```text
Home (payment alert nếu có khoản quá hạn) hoặc Tab Payment
→ Payment Overview → chọn khoản → Payment/Invoice Detail
→ Checkout (chọn phương thức, xác nhận)
→ Payment Result
```

### Flow 7 — Notification

```text
Notification (push hoặc mở từ Notification Center)
→ Deep-link thẳng tới màn đích, mang sẵn context (child/class/lesson/khoản phí)
→ Back trả về Notification Center (nếu mở từ đó) hoặc Home (nếu mở app từ push)
```

### Flow 8 — Family Insights Inbox

```text
Home → Learning insight (below-the-fold)
→ CTA "Xem tất cả phân tích" (chỉ hiện khi có nhiều insight hơn số hiện trên Home)
→ Family Insights Inbox (family scope — mọi con, mỗi item tự mang tên con)
→ Chọn 1 item → Learning/Insights (đúng child, deep-link — child selector tự khóa theo item đã chọn)
```

### Flow 9 — Liên kết hồ sơ con lần đầu

```text
Đăng nhập lần đầu, chưa có hồ sơ con nào
→ Home/Schedule/Learning hiện no-child empty state (xem mục D)
→ CTA "Liên kết hồ sơ con" (từ Home hoặc Profile → Quản lý con)
→ Add/Link Child — nhập mã liên kết do trung tâm cấp (thường trùng với "mã học viên" đã có trong hồ sơ)
→ Xác nhận → Quản lý con (đã có con) → Home/Schedule/Learning chuyển sang trạng thái bình thường
```

Chọn mô hình "trung tâm quản lý hồ sơ, phụ huynh liên kết bằng mã" thay vì "phụ huynh tự tạo hồ sơ con" — vì hệ thống đã có "mã học viên", cho thấy hồ sơ học viên được trung tâm khởi tạo trước, phụ huynh chỉ cần liên kết vào. Không hỗ trợ tự tạo hồ sơ con để tránh dữ liệu học vụ (lớp, mã học viên) bị nhập sai/trùng lặp từ phía phụ huynh. Nếu phụ huynh không có mã: CTA phụ "Liên hệ hỗ trợ" dẫn sang Help/Support.

---

## D. Navigation Proposal

### Bottom navigation

5 tab, luôn hiện icon + label (không icon-only — audience lớn tuổi hơn trung bình, ưu tiên rõ ràng hơn tối giản):

```text
[Home] [Schedule] [Learning] [Payment] [Profile]
```

### Top navigation (theo scope)

- **Family scope** (Home, Payment, Notifications, Family Insights Inbox): header chỉ có tiêu đề. Icon Notification (badge số chưa đọc) chỉ đặt ở Home — không lặp lại trên mọi screen.
- **Child scope root** (Schedule, Learning): header có child selector (avatar + tên + chevron) cạnh tiêu đề. Tap mở bottom sheet chọn con, chọn xong cập nhật nội dung tại chỗ, không chuyển màn.
- **Locked child context** (Class/Lesson/Homework/Schedule Detail): header có back + title/subtitle ghi rõ tên con (ví dụ "Bài tập Toán · Minh"). Không có child selector — đổi con không có ý nghĩa ở tầng này.
- **Parent scope** (Profile và các màn con): header chuẩn back + title.

### Child selector

- Chỉ tồn tại ở root của child scope (Schedule, Learning) — không xuất hiện ở Home (family scope) hay ở màn detail sâu.
- Component dạng bottom sheet: avatar + tên mỗi con, con đang chọn có dấu tick.
- Đổi con tại root sẽ refresh nội dung ngay trong màn đó, không điều hướng sang màn khác.

### Back navigation

- Luôn có nút back tường minh trong header (không dựa vào gesture OS làm cách duy nhất — phụ huynh lớn tuổi thường không quen swipe-back).
- Back bảo toàn: child đang chọn, filter đang áp dụng, tab con đang mở (ví dụ tab "Kết quả & nhận xét" ở Lesson Detail), vị trí cuộn.
- Back từ Lesson Detail → về đúng Class Detail (không nhảy về Learning root).
- Back từ Family Insights Inbox sau khi drill-down → quay về đúng Family Insights Inbox, không quay thẳng về Home.

### Deep link

- Mọi entry point gián tiếp (push notification, tap insight trên Home, tap item ở Family Insights Inbox) phải mount đúng destination kèm đủ context (child_id, class_id, lesson_id...) — không bao giờ bắt phụ huynh chọn lại child/class từ đầu nếu deep link đã biết.
- Deep link vào locked child context tự động "khóa" child selector của cha (Learning/Schedule) theo đúng con trong link, để back ra ngoài vẫn nhất quán.
- Deep link tới màn không tồn tại/đã hết hạn (ví dụ bài tập đã bị giáo viên xóa): hiển thị màn lỗi rõ ràng + CTA quay về màn danh sách tương ứng, không hiện màn trắng.

### Chiến lược khi tài khoản chưa có hồ sơ con (no-child)

- **Home** (family scope, không phụ thuộc child selector): vẫn hiển thị được, nhưng "Cần xử lý" và "Hôm nay/Tiếp theo" thay bằng 1 empty state duy nhất: "Chưa có hồ sơ con nào được liên kết" + CTA "Liên kết hồ sơ con" → Flow 9.
- **Schedule, Learning** (child scope — cần active child để hoạt động): thay toàn bộ nội dung màn bằng cùng 1 empty state như trên, không hiển thị child selector rỗng hay danh sách trống gây hiểu lầm là lỗi tải dữ liệu.
- **Payment, Notifications** (family scope): vẫn hoạt động bình thường ở trạng thái rỗng thông thường ("Không có khoản cần thanh toán", "Không có thông báo") — không bị chặn bởi no-child vì bản thân chưa có gì để hiển thị.
- Sau khi liên kết con đầu tiên thành công (Flow 9): Home/Schedule/Learning tự chuyển sang trạng thái bình thường mà không cần khởi động lại app.

### System states — chính sách toàn ứng dụng

Áp dụng cho **mọi** family/child-scoped screen:

| Tình huống | Hành vi |
|---|---|
| **Offline — màn đọc dữ liệu** (Home, Schedule, Homework, Progress, Insights, Notification Center) | Hiển thị dữ liệu cache kèm nhãn "Cập nhật lúc ..." rõ ràng; không chặn hoàn toàn màn hình; banner nhỏ báo "Đang ngoại tuyến — dữ liệu có thể chưa mới nhất". |
| **Offline — Payment** | **Vô hiệu hóa** mọi hành động thanh toán (nút "Pay now"/"Xác nhận thanh toán" disabled), vẫn cho xem Overview/History từ cache. Không bao giờ cho phép khởi tạo giao dịch khi offline. |
| **Partial failure** (1 phần dữ liệu lỗi, phần khác tải được) | Mỗi section/khối tự có loading/error/retry riêng — lỗi 1 khối không kéo sập toàn màn. Áp dụng chung cho mọi list/dashboard, không riêng Analytics. |
| **No child** | Xem mục "Chiến lược no-child" ở trên. |
| **No class / con chưa vào lớp nào** | Empty state riêng ở Classes/Schedule: "Con chưa tham gia lớp nào" — khác thông báo no-child (đã có con, chỉ là chưa có lớp). |
| **Schedule cancelled/rescheduled** | Status badge riêng ("Đã hủy", "Đã đổi lịch") trên Schedule Item + Schedule Detail hiện lý do nếu trung tâm cung cấp; không xóa khỏi danh sách để phụ huynh biết đã có thay đổi. |
| **Expired/invalid deep link** | Đã có ở mục Deep link phía trên — màn lỗi rõ ràng + CTA quay về danh sách. |

Mọi cache nêu trong bảng trên (Home/Schedule/Homework/Progress/Notifications/Payment) phải tuân yêu cầu bảo mật ở mục H (encrypted, gắn account+child, xóa khi logout) — không riêng Analytics.

---

## E. Screen-by-screen UX

Format mỗi màn: Goal — User context — Content hierarchy (trên→dưới) — Primary action — Secondary actions — Empty — Loading — Error.

### Home & Family Insights Inbox

**Home**
- Goal: trả lời nhanh câu hỏi hằng ngày cho mọi con.
- Context: family scope, có thể vừa mở app sau thời gian dài không dùng.
- Hierarchy: header (tiêu đề + icon Notification) → "Cần xử lý" (stable summary row) → "Hôm nay/Tiếp theo" → below-the-fold: Learning insight gần nhất.
- **Quy tắc sắp xếp "Cần xử lý"**: sắp theo 4 mức, không theo loại cố định — (1) khẩn cấp/thay đổi bất thường (lớp đổi giờ/hủy trong ngày, bài quá hạn), (2) đến hạn trong hôm nay, (3) sự kiện tiếp theo, (4) tổng quan không cần hành động. Notification không phải 1 mức riêng — nội dung quan trọng của nó đã nằm ở mức 1-2.
- Primary: tap 1 item "Cần xử lý" để xử lý việc gấp nhất theo đúng thứ tự trên.
- Secondary: tap sự kiện lịch, tap insight, tap icon Notification.
- Empty: "Cần xử lý" hiện "Không có việc cần xử lý hôm nay"; insight hiện "Chưa có phân tích mới trong kỳ này" hoặc "Chưa đủ dữ liệu để tạo phân tích kỳ này" (2 thông báo khác nhau). Nếu chưa có hồ sơ con nào: thay toàn bộ nội dung bằng no-child empty state (xem mục D).
- Loading: skeleton cho từng khối, không phải toàn màn trắng.
- Error: mỗi khối có retry riêng — lỗi tải "Hôm nay/Tiếp theo" không làm mất khối "Cần xử lý" đang có sẵn. Offline: hiện dữ liệu cache kèm "Cập nhật lúc..." (xem system states, mục D).

**Family Insights Inbox**
- Goal: xem insight của mọi con khi Home không đủ chỗ hiển thị hết.
- Context: family scope, phụ huynh chủ động muốn xem thêm.
- Hierarchy: header (tiêu đề, back về Home) → danh sách insight, mỗi item có avatar/tên con + insight rút gọn + thời gian.
- Primary: chọn 1 item để drill-down.
- Secondary: —.
- Empty: "Chưa có phân tích mới cho các con." Loading: skeleton list. Error: retry toàn danh sách.

### Schedule

**Schedule**
- Goal: xem lịch học của con đã chọn.
- Context: child scope, phụ huynh muốn biết lịch hôm nay/tuần này/sắp tới.
- Hierarchy: header (child selector + tiêu đề) → segmented control Today/Week/Upcoming → danh sách buổi học (giờ, lớp, hình thức, trạng thái).
- Primary: chọn 1 buổi để xem chi tiết.
- Secondary: chuyển segment, đổi con.
- Empty: "Con chưa có lịch học nào" (nếu child chưa có lớp) hoặc "Không có buổi học trong khoảng này".
- Loading: skeleton list theo segment đang chọn.
- Error: banner lỗi + retry, giữ nguyên segment đang xem.

**Schedule Detail**
- Goal: chi tiết 1 buổi/lịch.
- Context: locked child context.
- Hierarchy: header (back + tên con) → thông tin buổi (giờ, hình thức online/offline, giáo viên) → trạng thái (Upcoming/In progress/Completed/Cancelled/Rescheduled) → CTA vào Lesson Detail nếu buổi đã/đang diễn ra.
- Primary: xem giờ/hình thức; vào Lesson nếu có.
- Secondary: — (xem Future/Conditional Components, mục G, cho tính năng nhắc lịch).
- Empty: n/a (luôn có dữ liệu vì đến từ item cụ thể).
- Loading: skeleton block. Error: retry, giữ nguyên vị trí đến từ Schedule list.

### Learning

**Learning (root)**
- Goal: điều hướng tới các section học tập của con đã chọn.
- Context: child scope.
- Hierarchy: header (child selector) → Insights (entry point nổi bật) → Classes → Homework → Progress → Recommended Courses.
- Primary: chọn 1 section.
- Secondary: đổi con.
- Empty/Loading/Error: áp dụng riêng cho từng section con (không phải 1 trạng thái chung cho cả root).

**Insights / Phân tích**
- Goal: xu hướng học tập nhiều buổi, diễn giải có bằng chứng — core differentiator.
- Context: child scope, phụ huynh chủ động tìm hiểu sâu, hoặc đến từ deep-link (Home, Family Insights Inbox).
- Hierarchy: header → Tổng quan kỳ hiện tại → Xu hướng qua nhiều buổi → Phân tích theo kỹ năng/dạng hoạt động → mỗi insight: Observation → Interpretation → Suggested action (optional) → Evidence link.
- Primary: tap Evidence để xem lesson/hoạt động liên quan.
- Secondary: đổi khoảng thời gian/filter theo lớp-kỹ năng.
- Empty: "Chưa đủ dữ liệu để tạo phân tích kỳ này" — không suy diễn, không dùng 0%.
- Loading: tải summary/metadata trước, mỗi section lazy-load riêng.
- Error: lỗi 1 section không làm hỏng section khác; mỗi section có retry riêng.

**Classes (list)**
- Goal: danh sách lớp đang học của con.
- Context: child scope.
- Hierarchy: header (child selector) → danh sách lớp (tên lớp, giáo viên, tiến độ, trạng thái đang học/kết thúc).
- Primary: chọn 1 lớp.
- Secondary: lọc theo trạng thái (đang học/đã kết thúc).
- Empty: "Con chưa tham gia lớp nào." Loading: skeleton list. Error: retry.

**Class Detail**
- Goal: thông tin lớp + danh sách buổi học.
- Context: locked child context.
- Hierarchy: header (back + tên con) → thông tin lớp (giáo viên, lịch, tiến độ) → danh sách buổi học (lesson).
- Primary: chọn 1 buổi học.
- Secondary: xem bài tập/phân tích liên quan lớp (link sang Homework/Insights có filter theo lớp).
- Empty: "Lớp chưa có buổi học nào được lên lịch." Loading: skeleton. Error: retry.

**Lesson Detail**
- Goal: tổng quan + kết quả 1 buổi học cụ thể.
- Context: locked child context.
- Hierarchy: header (back + tên con) → tab "Tổng quan" (nội dung/hoạt động buổi học) | tab "Kết quả & nhận xét" (kết quả bài tập/quiz, nhận xét giáo viên → "Xem phân tích chi tiết" progressive disclosure, không gồm focus score).
- Primary: xem kết quả buổi học; mở phân tích chi tiết nếu cần.
- Secondary: chuyển tab.
- Empty: buổi chưa diễn ra → tab "Kết quả" hiện "Buổi học chưa diễn ra, chưa có kết quả."
- Loading: skeleton theo từng tab. Error: retry riêng từng tab.

**Homework (list)**
- Goal: toàn bộ bài tập, lọc theo trạng thái.
- Context: child scope.
- Hierarchy: header (child selector) → filter trạng thái (Not started/In progress/Submitted/Completed/Overdue) → danh sách bài tập (môn/lớp, deadline, trạng thái).
- Primary: chọn 1 bài để xem chi tiết.
- Secondary: đổi filter, đổi con.
- Empty: "Không có bài tập nào" (theo filter đang chọn — phân biệt "không có bài tập" chung vs "không có bài nào khớp filter").
- Loading: skeleton list. Error: retry, giữ nguyên filter.

**Homework Detail**
- Goal: chi tiết 1 bài tập, để theo dõi — không phải để nộp bài thay con.
- Context: locked child context.
- Hierarchy: header (back + tên con) → môn/lớp, deadline, trạng thái submission, điểm (nếu có) → nội dung bài tập.
- Primary: xem trạng thái/deadline/kết quả.
- Secondary: xem lớp liên quan (link Class Detail).
- Empty: n/a. Loading: skeleton. Error: retry.
- Phụ huynh chỉ theo dõi, không nộp bài thay con — đúng vai trò phụ huynh trong đề bài. Nếu sau này có yêu cầu cho phụ huynh nộp thay (ví dụ học sinh nhỏ tuổi không tự thao tác được), đây phải là 1 quyết định phân quyền riêng có xác nhận rõ từ business, không mặc định bật.

**Progress**
- Goal: completion/tiến độ theo khóa — "con đã học đến đâu".
- Context: child scope.
- Hierarchy: header (child selector) → danh sách khóa/lớp với thanh tiến độ (X/Y buổi, % completion).
- Primary: chọn 1 khóa để xem chi tiết.
- Secondary: đổi con.
- Empty: "Con chưa có khóa học nào để theo dõi tiến độ." Loading: skeleton. Error: retry.

**Progress Detail**
- Goal: chi tiết tiến độ 1 khóa/lớp cụ thể.
- Context: locked child context.
- Hierarchy: header (back) → mốc nội dung đã đạt → bài tập đã nộp/chưa nộp → tiến độ theo kế hoạch.
- Primary: xem breakdown; link sang Homework nếu có bài chưa nộp.
- Secondary: —.
- Empty: không áp dụng — mở từ 1 khóa/lớp đã tồn tại trong Progress list.
- Loading: skeleton theo đúng content hierarchy (mốc nội dung → bài tập → tiến độ kế hoạch).
- Error: banner lỗi + retry, giữ nguyên vị trí đến từ Progress list.

**Recommended Courses (list)**
- Goal: gợi ý khóa học phù hợp.
- Context: child scope, không phải nhu cầu hằng ngày.
- Hierarchy: header (child selector) → danh sách khóa gợi ý, mỗi item có nhãn "Gợi ý cho [con]" hoặc "Phổ biến với [độ tuổi]" + 1 dòng lý do.
- Primary: chọn khóa để xem chi tiết.
- Secondary: đổi con.
- Empty: "Hiện chưa có khóa học phù hợp để gợi ý." (không hiện gợi ý gượng ép khi không đủ căn cứ).
- Loading: skeleton. Error: retry.

**Course Detail**
- Goal: thông tin khóa học gợi ý, quyết định đăng ký.
- Context: đến từ Recommended Courses.
- Hierarchy: header (back) → lý do gợi ý (đầy đủ, không rút gọn) → mô tả khóa, độ tuổi/lớp, thời lượng, lịch học, học phí → CTA.
- Primary: CTA nhãn động theo quy trình hệ thống hỗ trợ — "Đăng ký ngay" (nếu đăng ký tự động) hoặc "Yêu cầu tư vấn" (nếu cần nhân viên trung tâm xử lý) → mở Enrollment. Không dùng nhãn "Đăng ký" chung chung không rõ hệ quả.
- Secondary: xem lịch học chi tiết, xem học phí trước khi đăng ký.
- Empty: n/a. Loading: skeleton. Error: retry.

**Enrollment / Đăng ký khóa học**
- Goal: xác nhận lựa chọn (lịch học, hình thức) để tạo **enrollment request/reservation** — chưa phải đăng ký chính thức nếu khóa có phí.
- Context: đến từ Course Detail, đã biết con nào đăng ký (locked child context).
- Hierarchy: header (back + tên con) → khóa học đã chọn → chọn lịch/hình thức nếu có nhiều lựa chọn → tóm tắt học phí (nếu có) → CTA xác nhận.
- Primary: Xác nhận → tạo reservation (trạng thái `pending_payment` nếu có phí) → nếu có phí: sang Checkout; nếu không/là yêu cầu tư vấn: thẳng Enrollment Result (reservation được xác nhận ngay, không qua bước chờ thanh toán).
- Secondary: Hủy, quay lại Course Detail (hủy reservation nếu đã tạo).
- Empty: n/a. Loading: disable khi đang xử lý. Error: lịch đã đầy chỗ/khóa ngừng nhận — thông báo rõ, gợi ý khóa/lịch thay thế nếu có.

**Enrollment Result**
- Goal: xác nhận kết quả — chỉ gọi là "đã đăng ký" khi có **Confirmed enrollment**, không nhầm với reservation đang chờ.
- Context: sau Enrollment (khóa miễn phí/tư vấn — reservation được xác nhận ngay), hoặc sau Payment Result (khóa có phí) — chỉ tới đây khi Payment **Success hoặc Pending/Unknown**; Payment Failed không tạo màn này (xem dưới).
- Hierarchy: header → trạng thái theo đúng nhánh:
  - **Đã đăng ký** (Confirmed enrollment — do Payment Success, hoặc khóa miễn phí/tư vấn không cần thanh toán) → thông tin lịch học/liên hệ tiếp theo.
  - **Đang chờ xác nhận thanh toán** (reservation vẫn ở `pending_payment`, CHƯA có Confirmed enrollment) → "Yêu cầu đăng ký đang chờ xác nhận thanh toán, sẽ tự cập nhật khi có kết quả cuối cùng" + mã giao dịch để tra cứu — không dùng chữ "đã đăng ký" ở trạng thái này.
  → CTA quay về.
- Primary: Quay về Learning hoặc Course Detail.
- Secondary: (khi đang chờ) "Kiểm tra lại trạng thái" — dùng chung cơ chế với Payment Result, không tạo giao dịch mới (xem quy tắc idempotency ở Payment Result).
- Empty: không áp dụng — luôn có trạng thái cụ thể để hiển thị khi vào màn này. Loading: spinner khi đang chờ xác nhận backend. Error: gửi yêu cầu thất bại (nhánh miễn phí/tư vấn) — CTA thử lại, giữ nguyên lựa chọn đã nhập ở Enrollment.
- Khi Payment Failed, flow **không đi tới màn này** — reservation bị hủy/hết hạn, quay thẳng lại Checkout/Enrollment để phụ huynh thử lại (xem Flow 5), tránh tạo cảm giác "đã có kết quả" khi thực ra chưa có Confirmed enrollment nào.

### Payment

**Payment Overview**
- Goal: tổng khoản cần đóng **và** đã đóng của mọi con.
- Context: family scope.
- Hierarchy: header → tổng số tiền cần đóng (mọi con, nổi bật nhất vì actionable) → tổng đã đóng kỳ này (thông tin tham khảo, ít nổi bật hơn) → breakdown theo từng con (line item có tên con, cho cả 2 nhóm) → CTA "Xem lịch sử" (cho lịch sử đầy đủ hơn phạm vi "kỳ này").
- Primary: chọn 1 khoản cần đóng để thanh toán.
- Secondary: xem lịch sử, filter theo con (tùy chọn phụ, không mặc định).
- Empty: "Không có khoản nào cần thanh toán." (không hiện số 0 gây hiểu lầm, ghi rõ bằng chữ).
- Loading: skeleton. Error: retry. Offline: xem cache, mọi CTA thanh toán disabled (xem system states, mục D).

**Payment/Invoice Detail**
- Goal: chi tiết 1 khoản, dẫn tới thanh toán.
- Context: family scope, nhưng nội dung gắn với 1 con cụ thể (tên con lặp lại trong từng dòng — ngoại lệ redundancy có lý do, xem mục A).
- Hierarchy: header (back) → tên con, khóa/lớp liên quan, số tiền, deadline, trạng thái → chi tiết line item → CTA Pay now.
- Primary: Pay now.
- Secondary: xem hóa đơn PDF (nếu có).
- Empty: n/a. Loading: skeleton. Error: retry.

**Checkout**
- Goal: nhập/xác nhận thanh toán.
- Context: hành động tài chính, cần rõ ràng từng bước.
- Hierarchy: header (back) → tóm tắt khoản thanh toán (lặp lại tên con) → chọn phương thức thanh toán → xác nhận.
- Primary: Xác nhận thanh toán.
- Secondary: đổi phương thức, hủy quay lại Invoice Detail.
- Empty: n/a.
- Loading: disable nút khi đang xử lý, không cho tap đúp.
- Error: giao dịch thất bại — thông báo rõ lý do (nếu biết) + CTA thử lại, không mất dữ liệu đã nhập.

**Payment Result**
- Goal: xác nhận kết quả giao dịch — kể cả khi cổng thanh toán chưa trả kết quả rõ ràng.
- Context: ngay sau Checkout.
- Hierarchy: header → trạng thái → chi tiết giao dịch (kèm mã giao dịch để liên hệ hỗ trợ) → CTA theo đúng trạng thái.
- Primary: theo trạng thái —
  - **Thành công**: CTA "Quay về Payment Overview".
  - **Thất bại** (cổng xác nhận thất bại): CTA "Thử lại" (tạo giao dịch mới) hoặc "Chọn phương thức khác".
  - **Đang xử lý/Pending** (cổng chưa trả kết quả cuối): hiện rõ "Giao dịch đang được xử lý, có thể mất vài phút" — KHÔNG cho tap "Thử lại" ngay (tránh tạo giao dịch trùng), chỉ có CTA "Kiểm tra lại trạng thái".
  - **Không rõ kết quả/Timeout**: hiện "Chưa xác nhận được kết quả giao dịch" + mã giao dịch + CTA "Kiểm tra lại" và "Liên hệ hỗ trợ" — không tự động coi là thất bại để tránh phụ huynh thanh toán lần 2 cho cùng 1 khoản.
- Secondary: xem/tải biên lai (khi đã có kết quả cuối).
- Empty: n/a. Loading: spinner khi đang chờ xác nhận cổng thanh toán.
- Error: xem nhánh Thất bại/Pending/Không rõ kết quả ở trên — không gộp chung 1 thông báo lỗi cho mọi trường hợp.
- **Quy tắc idempotency**:
  - Checkout chống double-submit: disable nút ngay khi tap đầu tiên, không cho gửi lần 2 trong lúc đang xử lý.
  - **Cùng 1 payment attempt** (từ lúc bấm "Xác nhận thanh toán" tới khi có kết quả cuối) dùng **chung 1 idempotency key** — dù app có gọi lại API do mất kết nối tạm thời, backend vẫn nhận diện là cùng 1 giao dịch, không tạo bản ghi mới.
  - CTA **"Kiểm tra lại trạng thái"** (ở nhánh Pending/Unknown) chỉ **đọc** trạng thái giao dịch hiện có — không bao giờ tạo giao dịch mới.
  - Chỉ tạo **payment attempt mới** (idempotency key mới) khi giao dịch cũ đã được xác nhận **thất bại** và phụ huynh **chủ động** bấm "Thử lại" — không tự động retry ngầm.
  - Attempt mới phải **liên kết với attempt cũ** (ví dụ `previous_attempt_id`) để phục vụ đối soát — tránh trường hợp 2 giao dịch của cùng 1 khoản phí trông như không liên quan nhau khi tra soát sau này.

**Payment History**
- Goal: tra cứu lịch sử đã đóng.
- Context: family scope, không khẩn cấp.
- Hierarchy: header (back) → filter theo con/thời gian (tùy chọn) → danh sách giao dịch đã hoàn thành.
- Primary: chọn giao dịch để xem chi tiết/tải hóa đơn.
- Secondary: filter.
- Empty: "Chưa có lịch sử giao dịch." Loading: skeleton. Error: retry.

### Notifications

**Notification Center**
- Goal: xem danh sách thông báo.
- Context: family scope, mở từ icon Home hoặc push.
- Hierarchy: header → nhóm theo thời gian/loại → mỗi item: icon theo loại, tên con (nếu liên quan), nội dung rút gọn, trạng thái đọc/chưa đọc.
- Primary: tap để deep-link tới màn liên quan.
- Secondary: đánh dấu đã đọc tất cả.
- Empty: "Không có thông báo nào." Loading: skeleton list. Error: retry.

**Notification Detail (generic)**
- Goal: hiển thị nội dung thông báo không có đích deep-link cụ thể (ví dụ thông báo hệ thống).
- Context: family scope.
- Hierarchy: header (back) → nội dung đầy đủ.
- Primary: đọc nội dung, không có hành động tiếp theo bắt buộc.
- Secondary: —.
- Empty: không áp dụng — nội dung đã có sẵn từ notification đã tap, không cần fetch thêm.
- Loading: không áp dụng cùng lý do trên (hiển thị ngay từ payload notification).
- Error: chỉ xảy ra nếu cần fetch thêm chi tiết từ server — banner lỗi + retry, vẫn giữ nội dung rút gọn đã có từ notification.

### Profile

**Profile (root)**
- Goal: điều hướng các mục tài khoản.
- Context: parent scope.
- Hierarchy: header → thông tin phụ huynh rút gọn (tên, avatar) → Quản lý con → Parent Profile Edit → Notification Settings → Settings → Help/Support → Đăng xuất.
- Primary: chọn mục.
- Secondary: đăng xuất.
- Empty: không áp dụng — menu tĩnh, luôn có đủ mục.
- Loading: skeleton ngắn chỉ cho dòng tên/avatar phụ huynh (phần còn lại là menu tĩnh, không cần chờ tải).
- Error: nếu tải tên/avatar lỗi — vẫn hiện menu đầy đủ, chỉ dòng thông tin phụ huynh hiện placeholder + retry nhỏ.

**Quản lý con (list)**
- Goal: danh sách con để xem thông tin, hoặc liên kết con đầu tiên nếu chưa có.
- Context: parent scope — đây là tác vụ quản lý hồ sơ, không phải context selector (khác child selector ở Schedule/Learning).
- Hierarchy: header (back) → danh sách con (avatar, tên, tuổi/lớp) → CTA "Liên kết hồ sơ con".
- Primary: chọn 1 con để xem (→ Child Detail).
- Secondary: liên kết thêm con (→ Add/Link Child).
- Empty: "Chưa có hồ sơ con nào được liên kết." + CTA chính "Liên kết hồ sơ con" → Add/Link Child (xem Flow 9). Loading: skeleton. Error: retry.

**Add/Link Child**
- Goal: liên kết hồ sơ con đã được trung tâm khởi tạo sẵn (không tự tạo hồ sơ mới).
- Context: parent scope, từ Quản lý con hoặc từ no-child empty state ở Home.
- Hierarchy: header (back) → hướng dẫn ngắn ("Nhập mã liên kết trung tâm đã cung cấp") → ô nhập mã → CTA xác nhận → link "Không có mã? Liên hệ hỗ trợ".
- Primary: Xác nhận mã → thành công: về Quản lý con với con mới xuất hiện trong danh sách.
- Secondary: Liên hệ hỗ trợ (→ Help/Support) nếu không có mã.
- Empty: n/a. Loading: disable khi đang xác thực mã. Error: mã sai/đã được liên kết bởi tài khoản khác — thông báo rõ, không tiết lộ thông tin con thuộc về tài khoản nào (bảo mật).

**Child Detail**
- Goal: xem thông tin 1 con.
- Context: parent scope.
- Hierarchy: header (back) → avatar, họ tên, tuổi/lớp, trường/lớp hiện tại, mã học viên → CTA "Sửa thông tin liên hệ".
- Primary: mở Child Edit nếu cần sửa.
- Secondary: —.
- Empty: n/a. Loading: skeleton. Error: retry.

**Child Edit**
- Goal: sửa thông tin liên hệ cơ bản của con, trong phạm vi quyền phụ huynh.
- Context: parent scope, đến từ Child Detail.
- Hierarchy: header (back) → các trường có thể sửa (thông tin liên hệ cơ bản) — KHÔNG bao gồm trường/lớp, mã học viên hay dữ liệu học vụ chính thức (chỉnh sửa các trường này qua trung tâm, không qua mobile — xem mục H).
- Primary: Lưu thay đổi.
- Secondary: Hủy, quay lại Child Detail.
- Empty: n/a. Loading: skeleton. Error: validation lỗi hiện ngay dưới field, lỗi lưu hiện banner + giữ nguyên dữ liệu đã nhập.

**Parent Profile Edit**
- Goal: sửa thông tin phụ huynh.
- Context: parent scope.
- Hierarchy: header (back) → tên, email, phone, ngôn ngữ.
- Primary: Lưu.
- Secondary: —.
- Empty: không áp dụng — form luôn có dữ liệu hiện tại của phụ huynh khi mở.
- Loading: disable form + spinner trên nút Lưu khi đang gửi.
- Error: validation lỗi hiện ngay dưới field (email sai định dạng, phone trùng...); lỗi lưu (mất mạng) hiện banner + giữ nguyên dữ liệu đã nhập, không mất thay đổi.

**Notification Settings**
- Goal: bật/tắt loại thông báo.
- Context: parent scope.
- Hierarchy: header (back) → toggle theo nhóm (Learning, Teacher, Payment, System).
- Primary: toggle.
- Secondary: —.
- Empty: không áp dụng — danh sách nhóm cố định, luôn đủ.
- Loading: skeleton toggle khi đang tải trạng thái đã lưu trước đó.
- Error: nếu lưu toggle thất bại — tự động trả toggle về trạng thái trước đó + thông báo ngắn, không để UI hiện sai trạng thái thật.

**Settings**
- Goal: cấu hình chung (ngôn ngữ...).
- Context: parent scope.
- Hierarchy: header (back) → chọn ngôn ngữ → (các cấu hình khác nếu có).
- Primary: chọn/lưu.
- Secondary: —.
- Empty: không áp dụng — luôn có danh sách ngôn ngữ hỗ trợ sẵn.
- Loading: disable lựa chọn khi đang lưu.
- Error: lưu thất bại — thông báo ngắn + giữ lựa chọn cũ cho đến khi lưu thành công.

**Help/Support**
- Goal: liên hệ hỗ trợ.
- Context: parent scope.
- Hierarchy: header (back) → FAQ (nếu có) → CTA liên hệ (chat/hotline/email).
- Primary: gửi yêu cầu hỗ trợ.
- Secondary: xem FAQ.
- Empty: nếu chưa có nội dung FAQ — ẩn hẳn khối FAQ, chỉ còn CTA liên hệ (không hiện khối rỗng).
- Loading: skeleton cho danh sách FAQ (nếu tải từ server).
- Error: gửi yêu cầu hỗ trợ thất bại — thông báo rõ + CTA thử lại, giữ nguyên nội dung đã nhập.

---

## F. Mobile Layout Patterns

Thay vì lặp lại layout cho từng màn, dùng 5 pattern theo loại màn — mỗi màn ở mục E map vào đúng 1 pattern:

### 1. Dashboard (Home)

```text
Header (tiêu đề + icon Notification)
↓
Above-the-fold: Cần xử lý (stable summary row)
↓
Above-the-fold: Hôm nay / Tiếp theo
↓
Below-the-fold: Learning insight
↓
Bottom nav
```

### 2. List (Schedule, Classes, Homework, Progress, Recommended Courses, Payment Overview/History, Notification Center, Quản lý con, Family Insights Inbox)

Empty state của pattern này còn 1 biến thể: **no-child empty state** (Home/Schedule/Learning khi chưa có hồ sơ con) thay toàn bộ danh sách bằng thông báo + CTA "Liên kết hồ sơ con" (xem mục D, Flow 9) — không phải empty state thông thường kiểu "chưa có dữ liệu trong danh sách này".

```text
Header (child selector nếu child scope + tiêu đề)
↓
Filter/segmented control (nếu có)
↓
Danh sách item (status badge, time, metric chính, tên con nếu family scope)
↓
Empty/Loading/Error state thay thế danh sách khi cần
↓
Bottom nav (nếu là root tab) hoặc back (nếu là màn con)
```

### 3. Detail (Schedule/Class/Lesson/Homework/Payment Detail, Course Detail, Child Detail, Enrollment Result, Payment Result)

```text
Header (back + locked context title, ví dụ "Bài tập Toán · Minh")
↓
Context banner (thông tin định danh: lớp, buổi, khoản phí...)
↓
Primary info block
↓
Secondary info / tabs (nếu có, ví dụ Lesson Detail)
↓
Sticky CTA dưới cùng (nếu có primary action, ví dụ "Pay now", "Lưu thay đổi")
```

### 4. Form/Checkout (Checkout, Enrollment, Add/Link Child, Edit Profile, Child Edit)

```text
Header (back + tiêu đề)
↓
Form fields theo nhóm, validation inline ngay dưới field lỗi
↓
Sticky CTA submit dưới cùng
↓
(Checkout riêng) Bước xác nhận trước khi submit — không submit ngay ở bước nhập
```

### 5. Insight/Analytics (Insights, Lesson Analytics tab, Progress Detail)

```text
Header (child selector hoặc back)
↓
Summary & key changes (tầng 1 — executive summary)
↓
Section theo nhóm: Participation → Performance → Timeline → Teacher context → Evidence
   (mỗi section: lazy-load độc lập, loading/error/retry riêng)
```

---

## G. Component System

| Component | Mô tả | States |
|---|---|---|
| Child Selector | Avatar + tên + chevron, chỉ ở root child scope, mở bottom sheet khi tap | default, mở, đã chọn |
| Status Badge | Nhãn text (không chỉ màu — accessibility) | theo từng loại trạng thái nghiệp vụ (Upcoming/Overdue/Paid...) |
| Schedule Item | Giờ, tên lớp, giáo viên, hình thức, status badge | default, đã qua, đang diễn ra |
| Homework Item | Môn/lớp, deadline, status badge | default, quá hạn (nhấn mạnh thị giác) |
| Progress Indicator | Thanh/vòng tiến độ + nhãn X/Y | 0%, đang tiến hành, hoàn thành, no-data (khác 0%) |
| Insight Card | Observation + Interpretation + Suggested action (optional) + Evidence link, tên con | đủ dữ liệu, chưa đủ dữ liệu, đang tải, lỗi |
| Analytics Section | Khối gộp theo nhóm (Tham gia/Kết quả/Nhận xét...), tự lazy-load | loading, loaded, error, empty |
| Course Recommendation Card | Ảnh/tiêu đề khóa + nhãn lý do ("Gợi ý cho X" / "Phổ biến với Y") + CTA | default |
| Notification Item | Icon theo loại, tên con (nếu có), nội dung rút gọn, thời gian | đã đọc, chưa đọc |
| Payment Item | Tên con, số tiền, deadline, status badge | Paid/Pending/Failed/Overdue |
| Stable Summary Row | Dùng ở Home "Cần xử lý" — không ẩn/hiện tùy trạng thái | có việc, không có việc (trấn an), đang tải, lỗi |
| Empty State | Icon/minh họa tối giản + message + CTA tùy chọn | theo ngữ cảnh cụ thể (không dùng 1 empty state chung cho mọi nơi) |
| Bottom Sheet | Dùng cho child selector, filter | mở, đóng |
| Modal | Xác nhận hành động quan trọng (ví dụ trước khi thanh toán) | mở, đóng, đang xử lý |
| Sticky CTA Bar | Nút hành động chính cố định cuối màn Detail/Form | default, disabled (khi đang xử lý), loading |
| No-child Empty State | Biến thể riêng của Empty State cho Home/Schedule/Learning khi chưa liên kết con nào | mặc định (luôn có CTA "Liên kết hồ sơ con") |

### Future / Conditional Components

Chưa có xác nhận cơ chế backend/notification — tách riêng khỏi bảng chính để tránh wireframe implement nhầm tính năng chưa được duyệt. Chỉ đưa trở lại bảng chính khi các câu hỏi mở tương ứng ở mục H được trả lời.

| Component (điều kiện) | Mô tả dự kiến | Điều kiện để kích hoạt |
|---|---|---|
| Reminder CTA ("Nhắc con") | Nút ở Homework Detail — gửi nhắc nhở tới con, không phải nộp bài thay | Cần xác nhận: con nhận qua kênh nào (push/in-app của con), có cooldown chống spam không, fallback khi hệ thống chưa hỗ trợ |
| Reminder CTA ("Thêm nhắc lịch") | Nút ở Schedule Detail — nhắc phụ huynh trước giờ học | Cần xác nhận: cơ chế nhắc là local notification trên máy phụ huynh hay push từ server, có giới hạn số lượng nhắc được đặt không |

---

## H. UX Risks & Open Questions

### Cần xác nhận trước khi phát triển (không phải quyết định UX)

1. **Chính sách dữ liệu/privacy cho Analytics & Recommendation**: lawful basis, purpose limitation (phân biệt rõ dùng cho theo dõi học tập vs dùng cho gợi ý thương mại), data minimization, retention period, quyền truy cập/sửa/xóa, audit trail. Chưa có xác nhận — cần product/legal trả lời trước khi implement các tính năng liên quan tới dữ liệu hành vi học tập của trẻ.
2. **Điều kiện mở lại focus/engagement score**: nguồn đo xác định, consent, ngưỡng dữ liệu tối thiểu, phân biệt no-data/low-score. Hiện tại: không thiết kế/hiển thị.
3. **Cache bảo mật cho toàn bộ dữ liệu trẻ em và tài chính**: yêu cầu encrypted storage, gắn theo account+child, xóa khi logout, không lộ chéo trên thiết bị dùng chung, áp dụng cho **mọi** loại cache — Home/Schedule/Homework/Progress, Notification content, Payment Overview/History, Analytics/Insights. Nên tách thành 1 checklist bảo mật riêng cho đội dev, không chỉ nằm trong tài liệu UX này.
4. **Quy trình đăng ký khóa học thật (Enrollment) là gì**: tự động xác nhận ngay hay chuyển thành yêu cầu tư vấn do nhân viên xử lý — quyết định vận hành/backend, ảnh hưởng trực tiếp nhãn CTA ở Course Detail (mục E). Thiết kế hiện hỗ trợ cả 2 nhánh, nhưng cần chốt trước khi build. Backend cần hỗ trợ đúng 2 trạng thái **reservation** (`pending_payment`) và **Confirmed enrollment** (chỉ khi Payment Success) ở mục C Flow 5 — không gộp chung thành 1 bản ghi "enrollment" duy nhất.
5. **Cơ chế cấp mã liên kết con**: mã liên kết có trùng "mã học viên" đã có hay là mã riêng, ai cấp (trung tâm/giáo viên/hệ thống tự sinh), thời hạn mã — cần xác nhận với vận hành trung tâm trước khi thiết kế màn Add/Link Child chi tiết hơn.
6. **Cơ chế các CTA "nhắc nhở"** (Homework Detail "Nhắc con", Schedule Detail "Thêm nhắc lịch"): con nhận nhắc nhở qua kênh nào (push notification riêng cho học sinh, hay thông báo trong app của con — nếu có app riêng), có cooldown/chống spam khi phụ huynh bấm nhiều lần không, "nhắc lịch" là local notification trên máy phụ huynh hay push từ server, và CTA nên làm gì nếu hệ thống chưa hỗ trợ. Hiện tại: cả 2 CTA đã bỏ khỏi spec màn hình hiện hành, chuyển thành Future/Conditional Components (mục G) — chỉ đưa lại vào wireframe sau khi có câu trả lời.

### Rủi ro triển khai — cần lưu ý khi dev/QA, không phải quyết định UX

7. **Assumption về tần suất dùng app** (vài lần/ngày, session ngắn) chưa kiểm chứng bằng dữ liệu thật — ảnh hưởng trực tiếp tới việc có nên giữ Payment là tab riêng hay không về lâu dài.
8. **Payment là tab thứ 5 dù tần suất thấp** — quyết định do business, không phải do dữ liệu sử dụng thật; nên theo dõi usage sau khi launch để đánh giá lại, không coi đây là quyết định vĩnh viễn.
9. **Nested navigation Learning → Class → Lesson (3 cấp)**: chỉ chấp nhận được nếu deep-link + state preservation (child, filter, tab, scroll) được implement đúng như mục D — nếu dev bỏ qua yêu cầu bảo toàn state, trải nghiệm sẽ tệ hơn cả giới hạn 2 cấp cứng nhắc.
10. **Tải dữ liệu Analytics tầng chi tiết trên mạng chậm**: đã có nguyên tắc (lazy-load theo section, cache, 4 trạng thái) ở mục F/component Analytics Section — cần đảm bảo backend trả dữ liệu theo đúng cấu trúc phân section để lazy-load per-section khả thi, không phải 1 API trả toàn bộ.
11. **Multi-child confusion nếu implementation sai scope model**: đây là rủi ro cao nhất nếu đội dev không đọc kỹ phần A/D — cần review riêng phần này trong quá trình build, không chỉ dựa vào design QA thông thường.
12. **Recommendation tái sử dụng dữ liệu Analytics cho mục đích thương mại**: cần tách rõ trong tracking/data pipeline nội bộ (không chỉ ở UI) để không vi phạm purpose limitation đã nêu ở rủi ro #1.
13. **Idempotency cho Checkout/Payment Result**: yêu cầu backend hỗ trợ idempotency key theo từng payment attempt (không phải theo từng lần gọi API) + liên kết attempt mới với attempt cũ để đối soát — nếu backend chưa có cơ chế này, phần "Đang xử lý/Kiểm tra lại trạng thái" ở Payment Result (mục E) không thực thi được đúng như thiết kế, và Enrollment (mục C Flow 5) có nguy cơ hiển thị sai trạng thái đăng ký.

---

## Phụ lục — Accessibility Requirements

Áp dụng cho toàn bộ app, không riêng 1 màn:

- **Cỡ chữ & Dynamic Type**: hỗ trợ scale theo cài đặt hệ điều hành (iOS Dynamic Type / Android font scale); layout không được vỡ khi cỡ chữ tăng 1-2 bậc — ưu tiên component co giãn được (không cắt chữ, không đè chồng).
- **Contrast**: text và icon mang thông tin đạt tối thiểu WCAG AA (4.5:1 cho text thường, 3:1 cho text lớn/icon) — áp dụng cả 2 theme sáng/tối nếu có.
- **Touch target**: tối thiểu 44×44pt (iOS) / 48×48dp (Android) cho mọi phần tử tap được, kể cả trong Status Badge, Bottom Sheet item, icon header — quan trọng hơn bình thường vì audience lớn tuổi hơn trung bình.
- **Screen-reader label & reading order**: mọi component ở mục G cần label rõ nghĩa (không chỉ đọc icon), thứ tự đọc theo đúng content hierarchy đã định nghĩa ở mục E — đặc biệt Insight Card (đọc theo thứ tự Observation → Interpretation → Suggested action → Evidence, không đọc lẫn lộn).
- **Text/table thay thế cho chart**: mọi sparkline/line chart trong Insights/Lesson Analytics (mục F, pattern 5) phải có phương án thay thế dạng text/bảng số liệu cho screen reader — không truyền đạt xu hướng chỉ bằng hình dạng đường hoặc màu sắc.
- **Focus management**: sau khi deep-link vào 1 màn, sau khi mở/đóng Modal hoặc Bottom Sheet, và sau khi form báo lỗi — focus phải chuyển tới đúng vị trí liên quan (tiêu đề màn mới, nội dung modal, field lỗi đầu tiên), không giữ nguyên focus cũ gây mất định hướng.
- **Không truyền đạt xu hướng chỉ bằng màu/hình chart**: mọi "tăng/giảm" trong Insights phải có label chữ đi kèm (đã có ở Interpretation, mục E) — màu/mũi tên chỉ là hỗ trợ thị giác thêm.
- **Giảm chuyển động & zoom/reflow**: tôn trọng cài đặt "reduce motion" của hệ điều hành cho animation chuyển màn/skeleton loading; layout hỗ trợ zoom/reflow tới ít nhất 200% không mất chức năng (theo WCAG reflow).
