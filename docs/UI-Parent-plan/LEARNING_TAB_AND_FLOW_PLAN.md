# Kế hoạch Thiết kế & Triển khai UI Flow Tab Học tập (Parent Learning Flow)

> **Tài liệu tham chiếu chuẩn:**
> - UX Spec & Phân tích Nghiệp vụ: `C:\Users\tungm\Downloads\deliverable.md` (Mục *Learning*, *Screen #5 Learning Root*, *Screen #6 Learning Insights*, *Screen #7 Class Detail*, *Screen #8 Lesson Detail*, *Screen #10 Homework*, *Screen #12 Recommended Courses*, *Screen #13 Course Detail*).
> - Thiết kế UI đính kèm của Người dùng: 13 ảnh bao gồm 5 màn hình then chốt:
>   1. `Learning (Root Hub)` — Trung tâm điều hướng học tập của con.
>   2. `Class Detail` — Chi tiết lớp học & lộ trình từng buổi học (`Toán nâng cao 10 · Minh`).
>   3. `Learning Insights` — Báo cáo phân tích sư phạm chuyên sâu 3 bước (Observation $\rightarrow$ Interpretation $\rightarrow$ Action).
>   4. `Recommended Courses` — Danh sách khóa học đề xuất cá nhân hoá cho con.
>   5. `Course Detail` — Chi tiết khóa học đề xuất & cam kết quyền lợi phụ huynh.

---

## Mục lục
1. [Tổng quan & Phân tích Kiến trúc Flow Học tập](#1-tổng-quan--phân-tích-kiến-trúc-flow-học-tập)
2. [Phân tích Chi tiết 5 Màn hình Thiết kế (Ưu/Nhược điểm & Giải pháp)](#2-phân-tích-chi-tiết-5-màn-hình-thiết-kế-ưunhược-điểm--giải-pháp)
   - [Màn hình 1: Learning Root Hub](#màn-hình-1-learning-root-hub)
   - [Màn hình 2: Class Detail](#màn-hình-2-class-detail)
   - [Màn hình 3: Learning Insights (Phân tích sư phạm chuyên sâu)](#màn-hình-3-learning-insights-phân-tích-sư-phạm-chuyên-sâu)
   - [Màn hình 4: Recommended Courses (Gợi ý khóa học)](#màn-hình-4-recommended-courses-gợi-ý-khóa-học)
   - [Màn hình 5: Course Detail (Chi tiết khóa học gợi ý)](#màn-hình-5-course-detail-chi-tiết-khóa-học-gợi-ý)
3. [Thiết kế Kiến trúc Dữ liệu & Quản lý Trạng thái (Architecture & BLoC)](#3-thiết-kế-kiến-trúc-dữ-liệu--quản-lý-trạng-thái-architecture--bloc)
4. [Bản đồ Điều hướng & Luồng Chuyển màn hình (Navigation Map & Deep Links)](#4-bản-đồ-điều-hướng--luồng-chuyển-màn-hình-navigation-map--deep-links)
5. [Lộ trình Triển khai Chi tiết theo từng Giai đoạn (Phased Execution Plan)](#5-lộ-trình-triển-khai-chi-tiết-theo-từng-giai-đoạn-phased-execution-plan)
6. [Quy tắc Xử lý Dữ liệu Thực tế, Empty States & Lỗi Cục bộ (Partial Failure)](#6-quy-tắc-xử-lý-dữ-liệu-thực-tế-empty-states--lỗi-cục-bộ-partial-failure)
7. [Tiêu chí Nghiệm thu (Acceptance Criteria)](#7-tiêu-chí-nghiệm-thu-acceptance-criteria)

---

## 1. Tổng quan & Phân tích Kiến trúc Flow Học tập

Theo quy định tại **Dòng 349–450 của `deliverable.md`**, tab **Học tập** đóng vai trò là phân hệ giám sát tiến độ và năng lực học tập toàn diện của con. Khác với tab Home (trọng tâm là xử lý khẩn cấp và xem lịch trong ngày), tab Học tập là không gian đào sâu (Deep-dive Hub):

```
                               ┌────────────────────────────────────────────────┐
                               │             LEARNING ROOT (Screen 1)           │
                               │  - Pinned FamilyScopeSelector (Child Scope)    │
                               │  - 5 Section Entry Point Cards                 │
                               └───────────────────────┬────────────────────────┘
                                                       │
         ┌───────────────────┬─────────────────────────┼─────────────────────────┬───────────────────┐
         ▼                   ▼                         ▼                         ▼                   ▼
┌──────────────────┐ ┌───────────────┐        ┌──────────────────┐      ┌─────────────────┐ ┌───────────────────┐
│ LEARNING         │ │ CLASSES       │        │ HOMEWORK         │      │ PROGRESS        │ │ RECOMMENDED       │
│ INSIGHTS         │ │ LIST          │        │ LIST             │      │ OVERVIEW        │ │ COURSES           │
│ (Screen 3)       │ └───────┬───────┘        └────────┬─────────┘      └────────┬────────┘ │ (Screen 4)        │
│ - 3 Chỉ số kỳ    │         ▼                         ▼                         ▼          └─────────┬─────────┘
│ - Trend Chart    │ ┌───────────────┐        ┌──────────────────┐      ┌─────────────────┐           ▼
│ - Phân tích SP   │ │ CLASS DETAIL  │        │ HOMEWORK DETAIL  │      │ PROGRESS DETAIL │ ┌───────────────────┐
│   (Observation   │ │ (Screen 2)    │        │ (Locked Child    │      │ (Locked Child   │ │ COURSE DETAIL     │
│   → Interp       │ │ - Info GV     │        │  View-only)      │      │  Milestones)    │ │ (Screen 5)        │
│   → Action)      │ │ - Tiến độ/quiz│        └──────────────────┘      └─────────────────┘ │ - Lý do gợi ý     │
│ - Thế mạnh       │ │ - Timeline    │                                                      │ - Đề cương/Học phí│
└────────┬─────────┘ └───────┬───────┘                                                      │ - Sticky CTA      │
         │                   ▼                                                              └─────────┬─────────┘
         │           ┌───────────────┐                                                                ▼
         │           │ LESSON DETAIL │                                                      ┌───────────────────┐
         │           │ - Tổng quan   │                                                      │ ENROLLMENT /      │
         │           │ - Kết quả     │                                                      │ TƯ VẤN 1-1        │
         │           └───────────────┘                                                      └───────────────────┘
         └────────────────────────────────────── (Deep link "Xem lộ trình cải thiện") ────────────────┘
```

### Các nguyên tắc UX bắt buộc:
1. **Child Scope & Locked Child Context:**
   - Tại `Learning Root`, phụ huynh sử dụng thanh chọn con `FamilyScopeSelector` để đổi ngữ cảnh học tập giữa các con.
   - Khi đã nhấn vào xem chi tiết một màn hình (Class Detail, Learning Insights, Course Detail), context con được **khóa chặt (Locked Child Context)**: tiêu đề hiển thị rõ tên con (VD: `Toán nâng cao 10 · Minh`), ẩn selector dropdown để tránh nhầm lẫn dữ liệu giữa các con, và luôn có nút Back quay về root bảo toàn state.
2. **Vai trò Phụ huynh (View-only & Companion):**
   - Phụ huynh theo dõi, khích lệ và đồng hành; **tuyệt đối không có nút làm bài tập thay con, nộp bài thay con, hay vào lớp học Google Meet thay con**.
3. **Phân tích Sư phạm có Bằng chứng (Evidence-based Insights - Core Differentiator):**
   - Mọi nhận định cần cải thiện phải tuân thủ chuẩn 3 bước: **Observation (Quan sát định lượng)** $\rightarrow$ **Interpretation (Nguyên nhân sư phạm)** $\rightarrow$ **Action (Hành động cụ thể)** $\rightarrow$ **Evidence Link** dẫn tới bài thi/buổi học thực tế.

---

## 2. Phân tích Chi tiết 5 Màn hình Thiết kế (Ưu/Nhược điểm & Giải pháp)

---

### Màn hình 1: Learning Root Hub (Ảnh `uploaded_media_0` & `uploaded_media_1`)

#### Cấu trúc UI:
- **Header:**
  - Nhãn `PHỤ HUYNH 40STUDY` + Badge trạng thái xanh lá `• CHẾ ĐỘ GIÁM SÁT` (`0xFFDCFCE7`, text `0xFF15803D`).
  - Tiêu đề `Học tập` cỡ lớn (32px, bold).
  - Bộ chọn con dropdown: `[ M ] Minh (10A1) ∨`.
- **5 Thẻ Navigation Card lớn** (Nền trắng, bo góc 16px, viền mờ `0xFFF1F5F9`, chevron `>` bên phải):
  1. **Insights / Phân tích:** Icon line-chart xanh dương (`0xFF2563EB`) trên nền pastel `0xFFEFF6FF`. Subtitle: *"Xu hướng học tập, năng lực & điểm nổi bật"*. Badge: `• 2 nhận xét mới tuần này` (xanh nhạt).
  2. **Lớp học:** Badge inline tiêu đề `3 lớp đang học`. Icon sách mở. Subtitle: *"3 lớp đang tham gia học tập"*. Dot text: `• Toán nâng cao, Tiếng Anh, Vật Lý`.
  3. **Bài tập về nhà:** Icon clipboard cam (`0xFFD97706`). Subtitle: *"2 bài cần chú ý nộp đúng hạn"*. Badge cảnh báo: `⚠️ 1 bài sắp quá hạn` (nền đỏ nhạt `0xFFFEE2E2`, chữ đỏ `0xFFDC2626`).
  4. **Tiến độ khóa học:** Icon bar-chart tím (`0xFF7C3AED`). Subtitle: *"Đã hoàn thành 68% khối lượng học phần"*. Progress bar tím + số `68%`.
  5. **Gợi ý cho Minh:** Badge inline `AI đề xuất` (hồng pastel). Icon ngôi sao sparkles. Subtitle: *"Chuyên đề bổ trợ hình học không gian"*.

#### Đánh giá Ưu & Nhược điểm:
- **Ưu điểm:**
  - Thiết kế dạng thẻ danh mục cực kỳ rõ ràng, phân định mạch lạc 5 nhu cầu tra cứu thường nhật của phụ huynh.
  - Tích hợp **Micro-data tóm tắt** ngay trên mặt thẻ (số lớp, bài sắp quá hạn, % tiến độ, số nhận xét mới), giúp phụ huynh không cần bấm vào sâu vẫn nắm được tình trạng tổng thể.
  - Phân màu icon theo từng nhóm chức năng (Xanh dương - Phân tích, Xanh cyan - Lớp học, Cam - Bài tập, Tím - Tiến độ, Hồng - Gợi ý AI) tạo điểm nhấn thị giác phong phú nhưng hài hòa.
- **Nhược điểm & Vấn đề cần khắc phục:**
  - Thanh chọn con trên ảnh đang dùng chip dạng dropdown `[ M ] Minh (10A1) ∨` riêng lẻ, **chưa đồng bộ với `FamilyScopeSelector`** (dạng chip ngang có avatar, chấm màu và đã được ghim `pinned: true` trên Home, Lịch học và Family Insights Inbox).
  - Nếu phụ huynh chọn *"Tất cả các con"*, thiết kế hiện tại chưa mô tả cách hiển thị (do mỗi con có số lớp, tiến độ và bài tập khác nhau).
- **Đề xuất giải pháp cải tiến:**
  1. Thay thế dropdown bằng component **`FamilyScopeSelector` chuẩn dùng chung** và bọc trong `SliverPersistentHeader(pinned: true)` để khi cuộn trang, thanh chọn con luôn ghim ở mép trên.
  2. Khi chọn con cụ thể (`Minh` hoặc `Lan`): Hiển thị đúng 5 card với dữ liệu riêng của con đó như trong ảnh.
  3. Khi chọn *"Tất cả các con"*: Hiển thị danh sách chia nhóm theo từng con (với component `ChildGroupSubHeader`), mỗi con gồm các card tóm tắt ngắn gọn để phụ huynh so sánh nhanh giữa các con.

---

### Màn hình 2: Class Detail — Chi tiết Lớp học (Ảnh `uploaded_media_2` đến `uploaded_media_7`)

#### Cấu trúc UI:
- **Header:** Nút Back `<` + Tiêu đề 2 dòng: `Toán nâng cao 10 · Minh` (bold) / `Lớp 10A1 — Học kỳ I (2024–2025)` (text phụ). Nút Share & Info ở góc phải.
- **Khối 1: Thông tin Giáo viên & Lịch học:**
  - Avatar tròn chữ cái `CL`, tên giáo viên `Cô Lan` + Tag `Đang giảng dạy` (xanh lá).
  - Chức danh / Đơn vị: `ThS. Toán học - THPT Hà Nội Amsterdam`.
  - Nút hành động nhanh: `[ Nhắn tin ]` (Pill màu xanh nhạt).
  - 2 Cột thông tin: Lịch học cố định `T2 · T4 · T6 (09:00 - 10:00)` | Hình thức & Phòng `Google Meet / Phòng 302`.
- **Khối 2: TIẾN ĐỘ & KẾT QUẢ HỌC TẬP:**
  - 3 Chỉ số lớn: `8/12` (Buổi - 67% xong), `100%` (Chuyên cần), `8.6` (Điểm trung bình).
  - Thanh tiến độ màu xanh dương (67%).
- **Khối 3: LỘ TRÌNH & DANH SÁCH BUỔI HỌC (12 buổi):**
  - Timeline dọc với các nút tròn liên kết:
    - *Buổi 8 (Hôm nay, 09:00):* `Phân số cơ bản & Rút gọn` — Dot xanh lá nổi bật, Điểm quiz `3/5`, Tag `Vừa hoàn thành`, link `Xem bài học →`.
    - *Buổi 7:* `Số thập phân & Định lý Vi-ét` — Dot xám, Điểm quiz `5/5`, Tag `Có video xem lại`, trạng thái `Đã học`.
    - *Buổi 6:* `Phương trình bậc hai` — Trạng thái `Đã học`, Hoàn thành bài tập về nhà.
    - *Buổi 9:* `Hệ phương trình bậc nhất hai ẩn` — Dot viền rỗng, `Thứ 2 tuần tới, 09:00`, Tag `Sắp diễn ra`.
- **Bottom Sticky Button:**
  - Nút bấm to full-width: `[ Xem bài tập của lớp này → ]` (Primary blue `0xFF2563EB`).

#### Đánh giá Ưu & Nhược điểm:
- **Ưu điểm:**
  - Thiết kế Timeline dọc cực kỳ xuất sắc, thể hiện trực quan quá trình học tập theo thời gian thực (đã học $\rightarrow$ vừa hoàn thành hôm nay $\rightarrow$ sắp tới).
  - Tích hợp kết quả vi mô (Điểm quiz 3/5, 5/5, có video xem lại) ngay trên từng dòng buổi học, giúp phụ huynh nắm bắt tức thì chất lượng tiếp thu của con.
  - Khối giáo viên uy tín, cung cấp nút "Nhắn tin" tạo kênh liên lạc tức thời giữa gia đình và nhà trường.
  - Nút đáy *"Xem bài tập của lớp này"* giải quyết triệt để bài toán liên kết nghiệp vụ giữa Lớp học và Bài tập.
- **Nhược điểm & Đề xuất cải tiến:**
  - Khi bấm vào từng buổi học hoặc bấm `Xem bài học →`, cần điều hướng trực tiếp sang màn hình `Lesson Detail` (Màn hình #8 trong spec) với 2 tab: *Tổng quan* và *Kết quả & nhận xét*.
  - Đối với các buổi có `Có video xem lại`, cần cung cấp liên kết xem phát lại an toàn cho phụ huynh.

---

### Màn hình 3: Learning Insights — Báo cáo Phân tích Sư phạm (Ảnh `uploaded_media_8`)

#### Cấu trúc UI:
- **Header:** Back `<` + Tiêu đề: `Insights / Phân tích · Minh` / `Lớp 10A1 · Học kỳ I 2024–2025` + Nút Share & Tải báo cáo.
- **Subheader:** Avatar con `[ M ] Nguyễn Nhật Minh` `10A1` | Badge `• Đang cập nhật tuần 12`.
- **Khối 1: CHỈ SỐ HỌC TẬP TRỌNG YẾU (Tổng quan kỳ I - 12 tuần):**
  - Tham dự lớp: `92%` (delta: `+4% (23/25 buổi)`).
  - Hoàn thành bài: `85%` (delta: `Đúng hạn (17/20)`).
  - Điểm trung bình: `8.6` (delta: `+0.8 với đầu kỳ`).
  - Điểm tập trung & tương tác: `88% (Rất tích cực)`.
- **Khối 2: THEO DÕI NĂNG LỰC — Mức độ tập trung theo thời gian:**
  - Badge: `+12% trung bình`.
  - Biểu đồ vùng/xu hướng (Area Trend Chart) hiển thị biến thiên độ tập trung qua các tuần.
  - Đoạn phân tích định tính: *"Minh duy trì độ tập trung trên 85% vào các buổi cuối tuần (T6–CN)..."*
- **Khối 3: PHÂN TÍCH SƯ PHẠM CHUYÊN SÂU — Điểm cần cải thiện (1 trọng tâm):**
  - **1. QUAN SÁT THỰC TẾ (OBSERVATION):** Số liệu định lượng: Hoàn thành 3/5 bài phân số & rút gọn (đúng 60%).
  - **2. ĐÁNH GIÁ NGUYÊN NHÂN (INTERPRETATION):** Nhận định chuyên môn: Thấp hơn mức trung bình 85%+, hay nhầm dấu khi quy đồng đa thức phức tạp.
  - **3. KHUYẾN NGHỊ HÀNH ĐỘNG (ACTION):** Lời khuyên cụ thể: Nhắc Minh xem lại Buổi 8; kết nối Cô Lan xin 3 bài củng cố cá nhân hoá.
  - Liên kết bằng chứng: `Xem bài tập và bài kiểm tra chi tiết (Evidence) →`.
- **Khối 4: NĂNG KHIẾU VƯỢT TRỘI — Thế mạnh nổi bật:**
  - Callout viền xanh lá: Tư duy không gian & Ứng dụng thực tế (đạt 95% điểm tuyệt đối kiểm tra 15 phút).
- **Bottom Sticky Actions (2 nút song song):**
  - `[ 💬 Nhắn GVCN ]` (Secondary button).
  - `[ Xem lộ trình cải thiện → ]` (Primary blue button).

#### Đánh giá Ưu & Nhược điểm:
- **Ưu điểm:**
  - **Màn hình ấn tượng nhất và là "Core Differentiator" của sản phẩm.** Khắc phục hoàn toàn điểm yếu của các ứng dụng EdTech thông thường (chỉ show điểm số vô hồn).
  - Cấu trúc 3 bước **Observation $\rightarrow$ Interpretation $\rightarrow$ Action** đem lại giá trị sư phạm vượt bậc, giúp cha mẹ hiểu rõ *vì sao con bị điểm thấp* và *cần làm gì để giúp con*.
  - Có bằng chứng định lượng (`Evidence Link`) bảo đảm tính minh bạch, không phỏng đoán mơ hồ.
  - Thế mạnh nổi bật cân bằng lại tâm lý của phụ huynh, tránh cảm giác tiêu cực khi chỉ nhìn vào lỗi sai của con.
- **Đề xuất giải pháp cải tiến:**
  - Nút `[ Xem lộ trình cải thiện → ]` deep-link trực tiếp sang tab `Recommended Courses` của chính môn/kỹ năng đó.
  - Khi chưa đủ dữ liệu (học sinh mới nhập học dưới 3 buổi), hiển thị Empty State theo đúng quy tắc tại dòng 363 `deliverable.md`: *"Chưa đủ dữ liệu để tạo phân tích kỳ này — không suy diễn, không tự bịa 0%"*.

---

### Màn hình 4: Recommended Courses — Gợi ý Khóa học (Ảnh `uploaded_media_9`, `10`, `11`)

#### Cấu trúc UI:
- **Header:** Back `<` + Tiêu đề: `Gợi ý khóa học · Minh` `10A1` / Subtitle: *"Dựa trên phân tích năng lực học tập"* + Nút Filter.
- **Banner CỐ VẤN AI & GIÁO VIÊN:** Hộp thông báo màu xanh dương: *"Hệ thống đã phân tích 14 bài kiểm tra gần nhất của Minh và đề xuất lộ trình tối ưu năng lực tiếp thu."*
- **Filter Chips ngang:** `Tất cả` (Active), `Phù hợp nhất với Minh`, `Bổ trợ môn Toán`, `Tiếng Anh...`.
- **Danh sách 3 Thẻ Khóa học Đề xuất:**
  - Thẻ 1: `Algebra & Hàm số cơ bản đến nâng cao` — Tag: `★ Gợi ý cho Minh · Bổ trợ phương trình` + `• 98% Phù hợp`. Lý do: *"Phù hợp vì Minh đã hoàn thành Đại số căn bản và cần bổ trợ tư duy phương trình bậc hai & định lý Vi-ét..."*. Học phí: 1.600.000đ.
  - Thẻ 2: `Tiếng Anh giao tiếp & IELTS Junior Foundation` — Tag: `🔥 Phổ biến cho học sinh Lớp 10` + `• 92% Phù hợp`. Học phí: 2.200.000đ.
  - Thẻ 3: `Hình học không gian & Ứng dụng thực tế` — Tag: `⚡ Bổ trợ thế mạnh tư duy không gian` + `• 88% Phù hợp`. Học phí: 1.200.000đ.
- **Khối Tư vấn Cuối Trang:**
  - Tiêu đề: *"Cần định hướng lộ trình học cho Minh?"* + Đặt lịch tư vấn 1-1.
  - 2 Nút: `[ 📅 Tư vấn lộ trình học cho con ]` (Nút đen) + `[ 📞 ]` (Nút gọi điện).

#### Đánh giá Ưu & Nhược điểm:
- **Ưu điểm:**
  - Cách tiếp cận tư vấn khóa học rất tự nhiên và thuyết phục vì gắn chặt với **kết quả học tập thực tế và lỗ hổng kiến thức** của chính con (không tạo cảm giác "quảng cáo/bán hàng ép buộc").
  - Phân loại rõ ràng giữa khóa *bổ trợ điểm yếu* (Phương trình bậc 2) và khóa *phát huy thế mạnh* (Hình học không gian).
  - Có kênh tư vấn 1-1 và gọi điện trực tiếp đáp ứng đúng tâm lý phụ huynh muốn được trao đổi với người thật trước khi ra quyết định đóng học phí.
- **Đề xuất giải pháp cải tiến:**
  - Thêm trạng thái Empty State trung thực: Nếu học sinh đang học rất tốt và không có lỗ hổng kiến thức, hiển thị: *"Hiện tại con đang theo sát tiến độ rất tốt, chưa có khóa học bổ trợ nào cần thiết."*

---

### Màn hình 5: Course Detail — Chi tiết Khóa học Gợi ý (Ảnh `uploaded_media_12`)

#### Cấu trúc UI:
- **Header:** Back `<` + Tiêu đề `Chi tiết khóa học` + Nút Share & Bookmark.
- **Badges:** `TOÁN HỌC NÂNG CAO` + `✨ Gợi ý riêng cho Minh`.
- **Tên khóa & Đánh giá:** `Algebra & Đại số nâng cao` — `★ 4.9 (128 đánh giá) • 👥 340 học viên đang theo học`.
- **Callout VÌ SAO GỢI Ý CHO MINH? (Khối quan trọng nhất):**
  - Viền xanh dương, nền xanh pastel `0xFFEFF6FF`.
  - Icon bóng đèn + Badge `AI Sư phạm`.
  - Lời giải thích: *"Khóa học này tập trung vào dạng bài mà Minh đang có tỷ lệ làm đúng 60% ở 2 buổi học gần nhất. Giúp củng cố phương pháp giải và tăng tốc độ làm bài thi."*
- **Khối Học phí & Ưu đãi:** `1.600.000đ` (gạch ngang 2.200.000đ, tiết kiệm 27%). Hỗ trợ chia kỳ đóng phí + Hoàn 100% nếu không hài lòng.
- **Thông số lớp học:** Lớp 10 (Nâng cao), 8 buổi (90 phút), Thứ 3 & Thứ 5 (15:00 - 16:30), Online tương tác sĩ số $\le 12$, GV ThS. Hoàng Minh Tuấn.
- **Đề cương 4 chuyên đề (8 buổi):** Rút gọn mẫu thức $\rightarrow$ Vi-ét bậc cao $\rightarrow$ Bất đẳng thức $\rightarrow$ Kiểm tra sát hạch.
- **Cam kết 40Study:** Hoàn 100% học phí sau 2 buổi nếu không phù hợp.
- **Bottom Sticky Bar:**
  - Nút CTA lớn: `[ Đăng ký khóa học ngay → ]`
  - Cam kết phụ: `✓ Đảm bảo hoàn học phí • Tư vấn miễn phí 1-1`.

#### Đánh giá Ưu & Nhược điểm:
- **Ưu điểm:**
  - Tính minh bạch thông tin ở mức độ xuất sắc: từ lý do đề xuất, thông số sĩ số, giáo trình, giảng viên đến đề cương chi tiết từng buổi.
  - Chính sách "Hoàn 100% sau 2 buổi đầu" giải tỏa triệt để rào cản tâm lý của phụ huynh khi mua khóa học trực tuyến.
- **Đề xuất giải pháp cải tiến:**
  - Nút CTA nhãn động theo quy định dòng 441 `deliverable.md`: Nếu khóa cho phép ghi danh tự động thì hiện `Đăng ký khóa học ngay →`, nếu cần xếp lớp/phỏng vấn thì hiện `Yêu cầu tư vấn 1-1 →`.

---

## 3. Thiết kế Kiến trúc Dữ liệu & Quản lý Trạng thái (Architecture & BLoC)

### 3.1. Phân tầng Kiến trúc (Layered Architecture)
```
lib/features/parent/
├── data/
│   ├── models/
│   │   ├── parent_learning_hub_data.dart    // Dữ liệu tổng hợp cho Learning Root
│   │   ├── parent_class_detail_model.dart   // Thông tin lớp, giáo viên, timeline buổi học
│   │   ├── parent_learning_insights_model.dart // Chỉ số kỳ, trend tập trung, phân tích 3 bước
│   │   └── parent_recommended_course_model.dart // Khóa học gợi ý, đề cương, lý do AI
│   └── parent_learning_api_client.dart      // Retrofit client cho phân hệ học tập
├── repository/
│   ├── parent_learning_repository.dart      // Interface
│   └── parent_learning_repository_impl.dart // Implementation với Smart Preview Fallback
├── bloc/
│   ├── learning_hub/                        // BLoC cho Learning Root
│   ├── class_detail/                        // BLoC cho Class Detail & Timeline
│   ├── learning_insights/                   // BLoC cho Báo cáo phân tích chuyên sâu
│   └── recommended_courses/                 // BLoC cho Gợi ý & Chi tiết khóa học
└── presentation/learning/
    ├── parent_learning_screen.dart          // Màn hình Root Hub (Screen 1)
    ├── class_detail/                        // Màn hình Class Detail (Screen 2)
    ├── insights/                            // Màn hình Learning Insights (Screen 3)
    ├── recommended/                         // Màn hình Gợi ý khóa học (Screen 4)
    ├── course_detail/                       // Màn hình Chi tiết khóa học (Screen 5)
    └── widgets/                             // Các reusable components dùng chung
```

### 3.2. Data Models Chi tiết

#### Model 1: `ParentLearningHubData` (Dùng cho Screen 1)
```dart
class ParentLearningHubData {
  final String childId;
  final String childName;
  final int activeClassCount;
  final List<String> activeClassNames;
  final int pendingHomeworkCount;
  final int overdueHomeworkCount;
  final double overallProgressPercent;
  final int newInsightsCount;
  final String? recommendedTopic;
}
```

#### Model 2: `ParentClassDetail` & `ClassLessonTimelineItem` (Dùng cho Screen 2)
```dart
class ParentClassDetail {
  final String classId;
  final String className;
  final String semester;
  final TeacherProfile teacher;
  final String scheduleText;
  final String roomOrPlatform;
  final int completedSessions;
  final int totalSessions;
  final double attendanceRate;
  final double averageGrade;
  final List<ClassLessonTimelineItem> lessons;
}

class ClassLessonTimelineItem {
  final int sessionNumber;
  final String title;
  final String timeLabel;
  final LessonSessionStatus status; // completed, inProgress, upcoming
  final String? quizScoreText;       // "3/5"
  final bool hasRecording;
  final String? statusLabel;         // "Vừa hoàn thành", "Đã học", "Sắp diễn ra"
}
```

#### Model 3: `LearningInsightsReport` (Dùng cho Screen 3)
```dart
class LearningInsightsReport {
  final String childId;
  final String childName;
  final String semesterText;
  final int currentWeek;
  
  // 1. Chỉ số trọng yếu
  final double attendanceRate;
  final String attendanceSessionsText; // "23/25 buổi"
  final double homeworkRate;
  final String homeworkOnTimeText;     // "17/20 đúng hạn"
  final double averageGrade;
  final String gradeDeltaText;         // "+0.8 với đầu kỳ"
  final int focusScore;                // 88%
  
  // 2. Xu hướng tập trung
  final List<FocusTrendPoint> focusTrend;
  final String focusTrendNote;
  
  // 3. Phân tích sư phạm 3 bước
  final PedagogicalAnalysis focusAnalysis;
  
  // 4. Thế mạnh nổi bật
  final StrengthHighlight strength;
}

class PedagogicalAnalysis {
  final String areaTitle;
  final String observation;   // 1. QUAN SÁT THỰC TẾ
  final String interpretation;// 2. ĐÁNH GIÁ NGUYÊN NHÂN
  final String action;        // 3. KHUYẾN NGHỊ HÀNH ĐỘNG
  final String evidenceLabel;
  final String? evidenceTargetId;
}
```

#### Model 4: `RecommendedCourseItem` & `CourseDetailInfo` (Dùng cho Screen 4 & 5)
```dart
class RecommendedCourseItem {
  final String id;
  final String title;
  final String tag;             // "★ Gợi ý cho Minh · Bổ trợ phương trình"
  final int matchPercent;       // 98
  final String reason;          // Lý do đề xuất cá nhân hóa
  final int totalSessions;
  final String scheduleTime;
  final String teacherName;
  final int tuitionFee;
  final int? originalFee;
}

class CourseDetailInfo {
  final String id;
  final String title;
  final String categoryName;
  final String personalizedTag;
  final String subtitle;
  final double rating;
  final int ratingCount;
  final int studentCount;
  final String aiReason;        // "VÌ SAO GỢI Ý CHO MINH?"
  final int tuitionFee;
  final int originalFee;
  final int discountPercent;
  final CourseClassSpecs specs; // Độ tuổi, lịch học, hình thức, giáo trình, GV
  final List<CourseCurriculumModule> syllabus; // 4 Chuyên đề
}
```

---

## 4. Bản đồ Điều hướng & Luồng Chuyển màn hình (Navigation Map & Deep Links)

```
[ Tab Bar: Học tập ]
        │
        ▼
ParentLearningScreen (Root Hub)
        │
        ├── Card 1: "Insights / Phân tích" ─────────► ParentLearningInsightsScreen
        │                                                     │
        │                                                     └── "Xem lộ trình cải thiện →" ──┐
        │                                                                                      │
        ├── Card 2: "Lớp học" ──────────────────────► ParentClassesListScreen                  │
        │                                                     │                                │
        │                                                     └── Chọn 1 lớp ──► ClassDetail   │
        │                                                                             │        │
        │                                                                             └── "Xem bài tập" ──┐
        ├── Card 3: "Bài tập về nhà" ───────────────► ParentHomeworkListScreen ◄──────────────────────────┘
        │                                                     │
        │                                                     └── Chọn 1 bài ──► ParentHomeworkDetailScreen
        │
        ├── Card 4: "Tiến độ khóa học" ─────────────► ParentProgressOverviewScreen
        │
        └── Card 5: "Gợi ý cho Minh" ───────────────► ParentRecommendedCoursesScreen ◄────────────────┘
                                                              │
                                                              └── Chọn 1 khóa ──► ParentCourseDetailScreen
                                                                                          │
                                                                                          └── "Đăng ký ngay" ──► Enrollment / Tư vấn 1-1
```

---

## 5. Lộ trình Triển khai Chi tiết theo từng Giai đoạn (Phased Execution Plan)

### Giai đoạn 1: Chuẩn hóa Root Hub (`ParentLearningScreen`)
- [ ] **Bước 1.1:** Tích hợp `FamilyScopeSelector` ghim trên đỉnh với `SliverPersistentHeader(pinned: true)`.
- [ ] **Bước 1.2:** Xây dựng widget `LearningHubNavigationCard` tái sử dụng, hỗ trợ icon pastel, subtitle, badge màu linh hoạt, progress bar và chevron.
- [ ] **Bước 1.3:** Kết nối 5 cards theo đúng thiết kế Ảnh 1.
- [ ] **Bước 1.4:** Tạo `LearningHubBloc` quản lý trạng thái tải tóm tắt micro-data của con đang chọn.

### Giai đoạn 2: Xây dựng Màn hình Chi tiết Lớp học (`ParentClassDetailScreen`)
- [ ] **Bước 2.1:** Header chuẩn Locked Child Context (`Toán nâng cao 10 · Minh`, không có selector, nút Back).
- [ ] **Bước 2.2:** Xây dựng khối Giáo viên (`TeacherInfoCard`) với nút "Nhắn tin", thông tin ca học cố định và hình thức học.
- [ ] **Bước 2.3:** Xây dựng khối 3 chỉ số lớn `TIẾN ĐỘ & KẾT QUẢ HỌC TẬP` (Buổi, Chuyên cần, Điểm TB) kèm progress bar.
- [ ] **Bước 2.4:** Xây dựng danh sách Timeline dọc `ClassLessonTimelineWidget` phân biệt rõ trạng thái (vừa hoàn thành hôm nay, đã học kèm điểm quiz/video xem lại, sắp diễn ra).
- [ ] **Bước 2.5:** Thêm sticky button `[ Xem bài tập của lớp này → ]` điều hướng sang Homework.

### Giai đoạn 3: Xây dựng Báo cáo Phân tích Sư phạm (`ParentLearningInsightsScreen`)
- [ ] **Bước 3.1:** Header Locked Child Context + Subheader tên con & tuần học.
- [ ] **Bước 3.2:** Khối chỉ số học tập trọng yếu (Tham dự, Hoàn thành, Điểm TB, Mức độ tập trung).
- [ ] **Bước 3.3:** Biểu đồ xu hướng mức độ tập trung theo thời gian (`FocusTrendChartWidget`) kèm nhận xét định tính.
- [ ] **Bước 3.4:** Khối phân tích sư phạm 3 bước (`PedagogicalAnalysisCard`):
  - 1. QUAN SÁT THỰC TẾ (Observation)
  - 2. ĐÁNH GIÁ NGUYÊN NHÂN (Interpretation)
  - 3. KHUYẾN NGHỊ HÀNH ĐỘNG (Action)
  - Liên kết bằng chứng `Evidence Link →`.
- [ ] **Bước 3.5:** Khối thế mạnh nổi bật (`StrengthHighlightCard`) viền xanh lá.
- [ ] **Bước 3.6:** Bottom actions: `[ Nhắn GVCN ]` và `[ Xem lộ trình cải thiện → ]`.

### Giai đoạn 4: Xây dựng Gợi ý Khóa học (`ParentRecommendedCoursesScreen`)
- [ ] **Bước 4.1:** Header kèm subtitle *"Dựa trên phân tích năng lực học tập"*.
- [ ] **Bước 4.2:** Banner Cố vấn AI & Giáo viên giải thích căn cứ phân tích.
- [ ] **Bước 4.3:** Thanh filter chips ngang (Tất cả, Phù hợp nhất, Bổ trợ Toán...).
- [ ] **Bước 4.4:** Danh sách thẻ khóa học đề xuất (`RecommendedCourseCardItem`) hiển thị lý do cá nhân hóa, tỷ lệ phù hợp (98%), học phí và thông tin GV.
- [ ] **Bước 4.5:** Khối chốt cuối trang: Đặt lịch tư vấn 1-1 + Hotline trực tiếp.

### Giai đoạn 5: Xây dựng Chi tiết Khóa học Gợi ý (`ParentCourseDetailScreen`)
- [ ] **Bước 5.1:** Header có Share và Bookmark.
- [ ] **Bước 5.2:** Callout *"VÌ SAO GỢI Ý CHO MINH?"* (AI Sư phạm) làm rõ căn cứ dựa trên lịch sử làm bài.
- [ ] **Bước 5.3:** Khối Học phí, ưu đãi tiết kiệm 27% và chính sách hỗ trợ đóng linh hoạt.
- [ ] **Bước 5.4:** Khối Thông số lớp học (Độ tuổi, Thời lượng, Sĩ số, Giáo trình, GV phụ trách).
- [ ] **Bước 5.5:** Đề cương 4 chuyên đề cốt lõi (8 buổi học).
- [ ] **Bước 5.6:** Cam kết hoàn tiền 100% của 40Study sau 2 buổi đầu.
- [ ] **Bước 5.7:** Sticky CTA bar `[ Đăng ký khóa học ngay → ]` kèm bảo hiểm quyền lợi phụ huynh.

### Giai đoạn 6: Kiểm thử, Tối ưu & Tích hợp Hoàn chỉnh
- [ ] **Bước 6.1:** Kiểm tra responsive, không tràn chữ (overflow) trên mọi kích thước màn hình.
- [ ] **Bước 6.2:** Kiểm thử chuyển đổi con mượt mà qua `FamilyScopeSelector`.
- [ ] **Bước 6.3:** Chạy `flutter analyze` đảm bảo 0 lỗi linting.
- [ ] **Bước 6.4:** Cập nhật tài liệu tiến độ và commit bằng tiếng Việt.

---

## 6. Quy tắc Xử lý Dữ liệu Thực tế, Empty States & Lỗi Cục bộ (Partial Failure)

Theo đúng định hướng sản phẩm: **Tuyệt đối không bịa fake mock data cho tài khoản thật, không suy diễn 0% khi thiếu dữ liệu**:

| Màn hình / Khối | Tình huống dữ liệu | Quy tắc hiển thị UI |
|---|---|---|
| **Learning Root** | Con mới tạo tài khoản, chưa có lớp | Thẻ Lớp học: *"Con chưa tham gia lớp nào"*; Thẻ Bài tập: *"Chưa có bài tập"* (ẩn badge cảnh báo đỏ); Thẻ Tiến độ: Ẩn thanh progress bar, hiện *"Chưa có dữ liệu tiến độ"*. |
| **Learning Insights** | Học sinh học dưới 3 buổi | Thay vì hiện biểu đồ dốc 0%, hiển thị card thông báo sư phạm: *"Chưa đủ dữ liệu để tạo phân tích kỳ này (cần tối thiểu 3 buổi học để hình thành xu hướng năng lực)."* |
| **Class Detail** | Lớp vừa mở chưa có buổi nào diễn ra | Timeline hiển thị các buổi dạng `Sắp diễn ra`, khối tiến độ hiển thị `0/12 Buổi (0%)`, ẩn điểm trung bình. |
| **Recommended Courses** | Không có khóa học phù hợp với học sinh | Hiển thị: *"Hiện tại con đang học tập rất ổn định, chưa có chuyên đề bổ trợ nào cần khuyến nghị thêm."* (Tuyệt đối không nhồi nhét gợi ý gượng ép). |
| **Partial Failure** | Lỗi tải 1 khối (ví dụ: lỗi tải Insights) | Chỉ hiển thị nút "Thử lại" tại khối Insights; các khối Lớp học, Bài tập và Khóa học gợi ý vẫn hiển thị bình thường. |

---

## 7. Tiêu chí Nghiệm thu (Acceptance Criteria)

| Tiêu chí | Điều kiện Đạt (PASS) |
|---|---|
| **Root Hub Navigation** | - 5 Card điều hướng chính xác vào 5 phân hệ tương ứng.<br>- Thanh chọn con `FamilyScopeSelector` ghim cố định ở đỉnh khi cuộn trang.<br>- Micro-data hiển thị chính xác theo con đang chọn. |
| **Class Detail Timeline** | - Hiển thị đúng 3 trạng thái: Vừa hoàn thành, Đã học (có quiz/video), Sắp diễn ra.<br>- Bấm "Xem bài học" mở đúng chi tiết buổi học; Bấm "Xem bài tập" mở đúng danh sách bài tập của lớp. |
| **Learning Insights 3 Bước** | - Cấu trúc 3 bước phân tích sư phạm rõ ràng: Quan sát thực tế $\rightarrow$ Đánh giá nguyên nhân $\rightarrow$ Khuyến nghị hành động.<br>- Có link xem Evidence trực tiếp; Có khối thế mạnh cân bằng tâm lý phụ huynh. |
| **Recommended Courses** | - Mỗi khóa học đều có lý do gợi ý cá nhân hóa gắn với kết quả học tập của con.<br>- Khối tư vấn 1-1 và hotline hoạt động mượt mà. |
| **Course Detail & CTA** | - Khối "VÌ SAO GỢI Ý CHO CON" giải thích thuyết phục.<br>- Đề cương 4 chuyên đề rõ ràng; Cam kết hoàn 100% hiển thị nổi bật. |
| **Chất lượng Mã nguồn** | - `flutter analyze` 0 lỗi.<br>- Không crash, không overflow pixel.<br>- Quản lý state độc lập theo chuẩn BLoC/Clean Architecture. |
