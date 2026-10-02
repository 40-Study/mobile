# KẾ HOẠCH CHI TIẾT GIAO DIỆN BÀI TẬP VỀ NHÀ & TIẾN ĐỘ HỌC TẬP (HOMEWORK & PROGRESS FLOW PLAN)

> **Dự án:** 40Study Mobile App  
> **Module:** Phân hệ Học tập cho Phụ huynh (`mobile/lib/features/parent/presentation/learning/`)  
> **Nhánh git:** `UI/Parent`  
> **Tài liệu tham chiếu:**  
> - `C:\Users\tungm\Downloads\deliverable.md` (Dòng 68–69, 131–139, 392–427: Quy chuẩn Homework & Progress)  
> - 6 Ảnh thiết kế người dùng đính kèm:  
>   + `uploaded_media_0` & `1`: Màn hình Danh sách Bài tập về nhà (Trạng thái có bài tập cần nộp gấp & đang làm)  
>   + `uploaded_media_2` & `3`: Màn hình Tiến độ học tập (KPI tổng quan, tiến độ từng khóa & ghi chú GVCN)  
>   + `uploaded_media_4` & `5`: Màn hình Bài tập về nhà (Trạng thái Empty State không có bài quá hạn + Báo cáo kết quả tuần gần nhất)  
> - Master Plan đã hoàn thành: `mobile/docs/UI-Parent-plan/LEARNING_TAB_AND_FLOW_PLAN.md`  
> **Ngày lập:** 02/10/2026  
> **Trạng thái:** Sẵn sàng triển khai  

---

## MỤC LỤC
1. [Kiến trúc Thông tin & Định vị Phân hệ (Information Architecture)](#1-kiến-trúc-thông-tin--định-vị-phân-hệ)
2. [Phân tích Chi tiết 3 Màn hình Thiết kế (Ưu/Nhược điểm & Giải pháp)](#2-phân-tích-chi-tiết-3-màn-hình-thiết-kế-ưunhược-điểm--giải-pháp)
   - [2.1. Màn hình 1: Danh sách Bài tập — Trạng thái Đang học & Cần nộp gấp (Ảnh 0 & 1)](#21-màn-hình-1-danh-sách-bài-tập--trạng-thái-đang-học--cần-nộp-gấp-ảnh-0--1)
   - [2.2. Màn hình 2: Danh sách Bài tập — Empty State Quá hạn & Điểm đã chấm (Ảnh 4 & 5)](#22-màn-hình-2-danh-sách-bài-tập--empty-state-quá-hạn--điểm-đã-chấm-ảnh-4--5)
   - [2.3. Màn hình 3: Tiến độ học tập — Khóa học, Buổi học & Lộ trình (Ảnh 2 & 3)](#23-màn-hình-3-tiến-độ-học-tập--khóa-học-buổi-học--lộ-trình-ảnh-2--3)
   - [2.4. Màn hình 4 (Bổ trợ cốt lõi): Chi tiết Bài tập về nhà (Homework Detail — View-only)](#24-màn-hình-4-bổ-trợ-cốt-lõi-chi-tiết-bài-tập-về-nhà-homework-detail--view-only)
3. [Đối chiếu Nghiêm ngặt với deliverable.md (Gap Analysis & UX Guardrails)](#3-đối-chiếu-nghiêm-ngặt-với-deliverablemd-gap-analysis--ux-guardrails)
4. [Kiến trúc Mã nguồn & Clean Architecture](#4-kiến-trúc-mã-nguồn--clean-architecture)
5. [Lộ trình Triển khai Chi tiết theo từng Giai đoạn (Phased Plan)](#5-lộ-trình-triển-khai-chi-tiết-theo-từng-giai-đoạn-phased-plan)
6. [Tiêu chí Nghiệm thu (Acceptance Criteria)](#6-tiêu-chí-nghiệm-thu-acceptance-criteria)

---

## 1. Kiến trúc Thông tin & Định vị Phân hệ

Theo cấu trúc cây điều hướng phân hệ Học tập tại `deliverable.md` và `LEARNING_TAB_AND_FLOW_PLAN.md`:

```text
ParentLearningScreen (Root Hub)
├── [Thẻ 1] Insights / Phân tích ──────► ParentLearningInsightsScreen (ĐÃ HOÀN THÀNH)
├── [Thẻ 2] Lớp học ──────────────────► ParentClassDetailScreen (ĐÃ HOÀN THÀNH)
│
├── [Thẻ 3] Bài tập về nhà ───────────► ParentHomeworkScreen (TRIỂN KHAI ĐỢT NÀY)
│                                            ├── Tab/Filter "Tất cả" & "Cần nộp gấp" (Ảnh 0)
│                                            ├── Tab/Filter "Quá hạn" -> Empty State + Điểm đã chấm (Ảnh 4)
│                                            └── Tap 1 bài ──► ParentHomeworkDetailScreen (View-only)
│
├── [Thẻ 4] Tiến độ khóa học ─────────► ParentProgressScreen (TRIỂN KHAI ĐỢT NÀY - Ảnh 2)
│                                            ├── 2 KPI Card (Số khóa & % Tiến độ trung bình)
│                                            ├── Danh sách Card tiến độ từng khóa (Đang học, Chú ý, Đã xong)
│                                            ├── Lời nhắn/Ghi chú từ GVCN
│                                            └── Tap "Chi tiết tiến độ" ──► Modal / Mốc học phần
│
└── [Thẻ 5] Gợi ý cho con ────────────► ParentRecommendedCoursesScreen ──► ParentCourseDetailScreen (ĐÃ HOÀN THÀNH)
```

---

## 2. Phân tích Chi tiết 3 Màn hình Thiết kế (Ưu/Nhược điểm & Giải pháp)

---

### 2.1. Màn hình 1: Danh sách Bài tập — Trạng thái Đang học & Cần nộp gấp (Ảnh `uploaded_media_0` & `1`)

#### Cấu trúc UI trong thiết kế:
- **Header:**
  - Nút Back `<`
  - Tiêu đề: `Bài tập về nhà · Minh` (Bold 18px)
  - Phụ đề: `Lớp 10A1 · Niên khóa 2024–2025`
  - Góc phải: Icon phễu lọc (Filter).
- **Thanh Filter Chips ngang:**
  - `Tất cả (3)` (Active: nền đen `0xFF0F172A`, chữ trắng).
  - `• Cần nộp gấp (1)` (Nền hồng pastel `0xFFFEE2E2`, chữ đỏ `0xFFDC2626`, chấm đỏ nổi bật).
  - `Đang làm (1)` (Nền vàng nhạt `0xFFFEF3C7`, chữ vàng nâu `0xFFB45309`).
  - `Đã nộp` (Nền xanh lá pastel).
- **Banner nhắc nhở khẩn cấp (Urgent Remind Banner):**
  - Khối nền xanh pastel `0xFFEFF6FF`, bo góc 16px.
  - Icon chuông xanh trong khung tròn `0xFF2563EB`.
  - Tiêu đề: `Nhắc nhở nộp bài hôm nay`.
  - Nội dung: `Minh còn 1 bài tập Toán cần nộp trước 20:00 tối nay.` (Chữ đỏ đậm cho mốc thời gian).
- **Danh sách 3 Thẻ bài tập:**
  - **Card 1 (Môn Toán):** Tag `• Hạn: Hôm nay 20:00` (đỏ). Tiêu đề: `Bài tập 5: Rút gọn phân số có ẩn`. Thông tin GV: `Cô Lan • Còn khoảng 2 giờ`. Action: `Chi tiết bài tập >`.
  - **Card 2 (Tiếng Anh):** Tag `Hạn chót: Mai 20:00` (cam). Tiêu đề: `Viết đoạn văn nghị luận xã hội`. Thông tin GV: `Thầy Nam • Đang làm (tiến độ 1/2 bài)`. Action trong ảnh: `Làm tiếp >`.
  - **Card 3 (Khoa học):** Tag `✓ Đã nộp · 8/10 điểm` (xanh lá). Tiêu đề: `Trắc nghiệm sinh thái`. Thông tin: `Đã nộp lúc 15:30 hôm qua • Đánh giá: Giỏi`. Action: `Xem lại >`.
- **Footer:** `Dữ liệu bài tập được đồng bộ trực tiếp từ hệ thống lớp học 40Study`.

#### Đánh giá Ưu điểm:
1. **Phân cấp thị giác khẩn cấp xuất sắc:** Dùng màu đỏ cảnh báo (`Hạn: Hôm nay 20:00`, `Còn khoảng 2 giờ`, banner chuông nhắc nhở) giúp phụ huynh nắm bắt ngay lập tức bài tập nào con có nguy cơ trễ hạn.
2. **Ký hiệu môn học tinh gọn:** Các icon chữ cái/ký hiệu (`Σ` Toán, `En` Tiếng Anh, `Sc` Khoa học) kết hợp màu nền nhận diện thương hiệu giúp giao diện thoáng đãng, hiện đại.
3. **Tính toán thời gian tương đối thông minh:** `Còn khoảng 2 giờ`, `Hạn chót: Mai 20:00` thân thiện và dễ hiểu hơn nhiều so với việc chỉ hiển thị một chuỗi ngày giờ tĩnh.

#### Nhược điểm & Điểm xung đột NGHIÊM NGẶT với `deliverable.md`:
- ⚠️ **XUNG ĐỘT CỐT LÕI TẠI CARD 2:** Nút bấm ghi nhãn là **`Làm tiếp >`**.
  - Theo **Dòng 68–69 và Dòng 408 của `deliverable.md`**: *"Phụ huynh chỉ theo dõi, không nộp bài thay con — đúng vai trò phụ huynh trong đề bài. Tuyệt đối không có nút làm bài tập thay con, nộp bài thay con."*
  - Nút `Làm tiếp >` là hành động của Học sinh. Nếu để trên app Phụ huynh sẽ gây hiểu nhầm rằng phụ huynh có thể vào giải bài hoặc nộp bài thay con.
- **Đề xuất giải pháp cải tiến:**
  1. Thay toàn bộ nút hành động bằng **`Chi tiết bài tập >`** hoặc **`Xem chi tiết >`** (đối với bài đang làm/chưa nộp) và **`Xem bài đã chấm >`** (đối với bài đã nộp).
  2. Cung cấp tùy chọn hữu ích cho phụ huynh: Bấm vào bài sắp trễ hạn cho phép gửi thông báo/lời nhắc nhanh: `[ 🔔 Nhắc con làm bài ]` thay vì nút làm bài.

---

### 2.2. Màn hình 2: Danh sách Bài tập — Empty State Quá hạn & Điểm đã chấm (Ảnh `uploaded_media_4` & `5`)

#### Cấu trúc UI trong thiết kế:
- **Header:** Giữ nguyên header chuẩn với nhãn lớp `Lớp 10A1`.
- **Thanh Filter:** Đang chọn filter `! Quá hạn (0)`.
- **Khối Empty State tích cực (All-clear State):**
  - Minh họa vòng tròn mềm mại với icon Clipboard tích xanh lá và ngôi sao vàng.
  - Tiêu đề: `Không có bài tập nào quá hạn` (Bold 18px).
  - Lời khen ngợi: `Tuyệt vời! Minh đã hoàn thành tất cả bài tập đúng hạn hoặc chưa có bài tập nào bị quá hạn nộp.`
  - Nút bấm chính: `[ ❖ Xem tất cả bài tập ]` (Full-width, màu xanh dương).
  - Dòng liên kết phụ: `Đổi sang trạng thái khác • Lịch sử đã chấm →`.
- **Khối Tóm tắt Kết quả Tuần gần nhất (`Graded Summary Card`):**
  - Header: Icon khiên tích xanh `Kết quả tuần gần nhất` | Badge `Xuất sắc` (nền xanh lá).
  - 2 Chỉ số lớn: `3/3 bài nộp` (*Tất cả đều đạt loại Giỏi*) | `8.8 /10` (*Điểm trung bình*).
  - Progress bar xanh lá đạt 100%.
  - 3 Dòng bài đã chấm:
    - `Toán hình học: Vectơ không gian` (Chấm ngày 18/10) — **9.5 điểm**.
    - `Ngữ văn: Phân tích hình tượng` (Chấm ngày 16/10) — **8.5 điểm**.
    - `Tiếng Anh: Reading Unit 4` (Chấm ngày 15/10) — **8.5 điểm**.
- **Ghi chú tự động đồng bộ:** Khối ghi chú thông báo hệ thống tự đồng bộ với GV lúc 18:00 hàng ngày.

#### Đánh giá Ưu điểm:
1. **Thiết kế Empty State kiểu mẫu trong ngành EdTech:** Tránh hoàn toàn cảm giác "màn hình chết" (dead-end screen). Khi con không có bài quá hạn, phụ huynh được tưởng thưởng bằng thông điệp chúc mừng an tâm và được xem ngay kết quả làm bài xuất sắc trong tuần.
2. **Hiển thị điểm số minh bạch:** Điểm số của từng môn kèm ngày chấm giúp phụ huynh theo dõi sát sao tiến độ học tập mà không cần hỏi giáo viên.
3. **Nút CTA chuyển đổi ngữ cảnh nhanh:** Nút `Xem tất cả bài tập` giúp người dùng nhanh chóng thoát khỏi filter rỗng để xem toàn bộ danh mục bài tập.

#### Đề xuất giải pháp cải tiến:
1. Chuẩn hóa năm học: Sửa text `NĂM HỌC 2023 - 2024` thành `NĂM HỌC 2024 - 2025` cho đồng bộ với toàn bộ các màn hình khác trong flow.
2. Tương tác chạm: Cho phép bấm vào từng dòng bài đã chấm (Toán 9.5, Văn 8.5) để mở màn hình chi tiết bài nộp và xem lời phê của giáo viên.

---

### 2.3. Màn hình 3: Tiến độ học tập — Khóa học, Buổi học & Lộ trình (Ảnh `uploaded_media_2` & `3`)

#### Cấu trúc UI trong thiết kế:
- **Header:**
  - Back button `<`
  - Tiêu đề: `Tiến độ học tập · Minh` kèm Pill `10A1` (màu xanh dương).
  - Phụ đề: `Học kỳ I · 2024-2025`.
  - 2 Action icons: Tải báo cáo PDF và Chia sẻ.
- **2 Card Thống kê trên cùng (Top KPI Cards):**
  - **Card 1: KHÓA ĐANG HỌC:** Số to `3` *khóa* | Chân card: Icon mũ tốt nghiệp `2 đang học · 1 hoàn thành`.
  - **Card 2: TIẾN ĐỘ TRUNG BÌNH:** Số to `65%` *học kỳ* | Chân card: Icon mũi tên xanh lá `↗ Đúng lộ trình đề ra`.
- **Danh sách 3 Thẻ tiến độ khóa học:**
  - **Khóa 1 (Toán nâng cao):**
    - Tag: `Đang học`. GV Cô Nguyễn Mai Lan · Phòng 302.
    - Tiến độ buổi: `8 / 12 buổi (67%)` | Còn 4 buổi.
    - Progress bar: Xanh dương 67%.
    - Chân thẻ: Chấm xanh `• Đúng tiến độ · Buổi tiếp theo thứ 2 (18:00)` | Link: `Chi tiết tiến độ →`.
  - **Khóa 2 (Tiếng Anh giao tiếp IELTS Junior):**
    - Tag: `Đang học`. Thầy David Nam · Trực tuyến Zoom.
    - Tiến độ buổi: `5 / 10 buổi (50%)` | Còn 5 buổi.
    - Progress bar: Màu tím 50%.
    - Chân thẻ: Cảnh báo `! Cần chú ý bài tập viết luận` (màu cam) | Link: `Chi tiết tiến độ →`.
  - **Khóa 3 (Khoa học vui & Thực nghiệm STEM):**
    - Tag: `✓ Xong` (xanh lá). Cô Trần Thục Hoa · Lab STEM A2.
    - Tiến độ buổi: `12 / 12 buổi (100%)` | `Hoàn thành khóa học`.
    - Progress bar: Xanh lá 100%.
    - Chân thẻ: Icon huân chương `Đã hoàn thành · Đạt chứng nhận Xuất sắc` | Link: `Xem chứng nhận →`.
- **Khối Ghi chú từ Giáo viên chủ nhiệm:**
  - Icon bóng đèn xanh.
  - Nội dung: `Minh hoàn thành 100% chuyên cần và giữ nhịp học tập tốt. Phụ huynh lưu ý nhắc con nộp bài luận Tiếng Anh trước 22:00 Chủ nhật.`

#### Đánh giá Ưu điểm:
1. **Trực quan hóa tiến độ hai lớp (Số buổi + Phần trăm):** Thể hiện rõ cả `8/12 buổi` lẫn `67%`, giúp phụ huynh dễ dàng tính nhẩm số buổi còn lại mà không cần suy đoán.
2. **Cảnh báo sư phạm tích hợp ngay trong thẻ tiến độ:** Dòng chữ `! Cần chú ý bài tập viết luận` (màu cam) tạo sự liên kết tự nhiên sang phân hệ Bài tập về nhà.
3. **Phân biệt rạch ròi khóa đang học và khóa đã hoàn thành:** Khóa 100% có huân chương và nút `Xem chứng nhận` tạo động lực và sự yên tâm cho gia đình.
4. **Kênh trao đổi một chiều từ GVCN:** Box ghi chú ở chân trang cung cấp bối cảnh thực tế từ giáo viên chủ nhiệm.

#### Đề xuất giải pháp cải tiến:
1. Bấm `Chi tiết tiến độ →` mở **Modal / Screen phân rã mốc tiến độ (Milestone Breakdown)** thể hiện các chặng đã qua và chặng sắp tới.
2. Bấm `! Cần chú ý bài tập viết luận` điều hướng trực tiếp sang đúng bài tập Tiếng Anh cần nộp ở màn hình `Homework Screen`.
3. Bấm `Xem chứng nhận →` hiển thị BottomSheet giấy chứng nhận hoàn thành khóa học của con.

---

### 2.4. Màn hình 4 (Bổ trợ cốt lõi): Chi tiết Bài tập về nhà (`ParentHomeworkDetailScreen` — View-only)

Để hoàn thiện trọn vẹn luồng trải nghiệm khi phụ huynh bấm `Chi tiết bài tập >` từ danh sách bài tập, chúng ta cần màn hình này theo đúng quy định tại dòng 401–409 của `deliverable.md`:
- **Context:** Locked Child Context (`Bài tập · Minh` / `Môn Toán nâng cao 10`).
- **Nội dung:**
  - Tiêu đề bài tập + Trạng thái nộp (`Đã nộp` / `Chưa nộp` / `Sắp quá hạn`).
  - Hạn nộp cụ thể và đếm ngược thời gian.
  - Điểm số & Nhận xét của giáo viên (nếu bài đã chấm).
  - Đề bài và tài liệu đính kèm (dạng PDF/file xem trước).
  - Lịch sử bài làm con đã nộp (file đính kèm con nộp, thời gian nộp).
- **Hành động dành riêng cho phụ huynh:**
  - Nút `[ 🔔 Nhắc con nộp bài ]` (gửi thông báo sang app con).
  - Nút `[ 💬 Nhắn giáo viên bộ môn ]` để trao đổi khi bài tập bị điểm kém hoặc khó hiểu.
  - **TUYỆT ĐỐI KHÔNG có nút "Nộp bài" hoặc "Làm bài".**

---

## 3. Đối chiếu Nghiêm ngặt với deliverable.md (Gap Analysis & UX Guardrails)

| Tiêu chuẩn UX tại `deliverable.md` | Hiện trạng thiết kế trong ảnh | Giải pháp kỹ thuật chuẩn hóa |
|---|---|---|
| **Vai trò Phụ huynh (View-only, không nộp thay)** | Ảnh 0 có nút `Làm tiếp >` tại bài Tiếng Anh. | **Sửa ngay:** Đổi thành `Xem chi tiết >` hoặc `Chi tiết bài tập >`. Không có bất kỳ logic cho phép upload bài nộp thay con. |
| **Child Scope & Locked Context** | Cả 3 ảnh đều có tiêu đề `... · Minh`, badge `10A1`. | Duy trì chuẩn Locked Child Context, hiển thị rõ tên con và lớp, có nút Back quay về `ParentLearningScreen`. |
| **Empty State trung thực** | Ảnh 4 có Empty State xuất sắc cho filter "Quá hạn (0)". | Khi filter khác rỗng (VD: "Đang làm" mà không có bài), hiển thị Empty message phù hợp: *"Con không có bài tập nào đang làm"*. |
| **Liên kết chéo giữa Tiến độ và Bài tập** | Ảnh 2 có cảnh báo `! Cần chú ý bài tập viết luận`. | Bấm vào cảnh báo này sẽ `Navigator.push` sang màn hình `ParentHomeworkScreen` với filter được chọn sẵn. |
| **Không suy diễn, không bịa fake data** | Dữ liệu tiến độ, điểm số, buổi học. | Định nghĩa Model có đầy đủ các trường nullable; nếu con chưa có bài tập hoặc chưa học buổi nào, UI tự động hiển thị Empty State chuẩn mực. |

---

## 4. Kiến trúc Mã nguồn & Clean Architecture

### 4.1. Cấu trúc thư mục mới:
```text
lib/features/parent/
├── data/models/
│   ├── parent_homework_model.dart            <-- Model bài tập, filter, chi tiết bài nộp & điểm
│   └── parent_course_progress_model.dart     <-- Model tiến độ khóa học, KPI, ghi chú GVCN & mốc học phần
├── repository/
│   ├── parent_learning_repository.dart       <-- Bổ sung getHomeworkList, getHomeworkDetail, getProgressOverview
│   └── parent_learning_repository_impl.dart  <-- Mock data chuẩn mực cho Minh & Lan
└── presentation/learning/
    ├── homework/
    │   ├── parent_homework_screen.dart       <-- Màn hình danh sách bài tập (hỗ trợ cả 2 trạng thái Ảnh 0 & Ảnh 4)
    │   ├── parent_homework_detail_screen.dart<-- Màn hình chi tiết bài tập (View-only)
    │   └── widgets/
    │       ├── homework_filter_bar.dart      <-- Chips Tất cả, Cần nộp gấp, Đang làm, Quá hạn, Đã nộp
    │       ├── urgent_homework_banner.dart   <-- Banner nhắc nhở khẩn cấp
    │       ├── homework_item_card.dart       <-- Thẻ bài tập với icon môn (Σ, En, Sc), badge hạn nộp
    │       ├── homework_empty_all_clear_card.dart <-- Khối chúc mừng không có bài quá hạn (Ảnh 4)
    │       └── graded_homework_summary_card.dart  <-- Khối kết quả tuần gần nhất & danh sách điểm (Ảnh 4)
    └── progress/
        ├── parent_progress_screen.dart       <-- Màn hình Tiến độ học tập (Ảnh 2)
        └── widgets/
            ├── progress_kpi_header.dart      <-- 2 Card Khóa đang học & % Tiến độ trung bình
            ├── course_progress_card.dart     <-- Thẻ tiến độ khóa học với thanh progress & cảnh báo
            └── teacher_homeroom_note_card.dart <-- Ghi chú từ Giáo viên chủ nhiệm
```

---

## 5. Lộ trình Triển khai Chi tiết theo từng Giai đoạn (Phased Plan)

### Giai đoạn 1: Xây dựng Data Models & Mở rộng Repository
- [ ] **Bước 1.1:** Tạo `parent_homework_model.dart` chứa:
  - `ParentHomeworkItem` (id, title, subjectCode, subjectName, teacherName, dueDate, dueStatus, timeRemainingText, score, gradeLabel).
  - `ParentHomeworkDetailModel` (id, description, attachments, submittedFiles, teacherFeedback, rubrics).
  - `ParentGradedSummaryModel` (submissionRatio, averageScore, recentGradedItems).
- [ ] **Bước 1.2:** Tạo `parent_course_progress_model.dart` chứa:
  - `ParentProgressOverviewModel` (activeCourseCount, averageProgressPercent, statusSummaryText).
  - `ParentCourseProgressItem` (courseId, courseName, teacherName, roomOrPlatform, completedSessions, totalSessions, progressPercent, warningNote, nextSessionText).
  - `TeacherHomeroomNote` (teacherName, noteContent).
- [ ] **Bước 1.3:** Cập nhật `ParentLearningRepository` và triển khai trong `ParentLearningRepositoryImpl` với dữ liệu bám sát 100% Ảnh 0, 2, 4.

### Giai đoạn 2: Xây dựng Giao diện Bài tập về nhà (`ParentHomeworkScreen`)
- [ ] **Bước 2.1:** Header chuẩn Locked Child Context (`Bài tập về nhà · Minh` + `Lớp 10A1`).
- [ ] **Bước 2.2:** Thanh filter chips cuộn ngang: `Tất cả`, `Cần nộp gấp`, `Đang làm`, `Quá hạn`, `Đã nộp`.
- [ ] **Bước 2.3:** Banner nhắc nhở khẩn cấp khi có bài sắp hết hạn trong ngày (`UrgentHomeworkBanner`).
- [ ] **Bước 2.4:** Danh sách `HomeworkItemCard` với icon môn chuyên biệt (`Σ`, `En`, `Sc`), nhãn hạn nộp, và nút hành động chuẩn phụ huynh `Chi tiết bài tập >` (loại bỏ nhãn sai `Làm tiếp >`).
- [ ] **Bước 2.5:** Trạng thái Empty State tích cực khi chọn filter Quá hạn:
  - Khối All-clear `Không có bài tập nào quá hạn` kèm nút `Xem tất cả bài tập`.
  - Khối `Kết quả tuần gần nhất` hiển thị điểm TB 8.8/10 và danh sách điểm từng môn đã chấm.

### Giai đoạn 3: Xây dựng Chi tiết Bài tập (`ParentHomeworkDetailScreen` — View-only)
- [ ] **Bước 3.1:** Header `Bài tập · [Tên con]` + Nút Back.
- [ ] **Bước 3.2:** Khối thông tin hạn nộp, đếm ngược thời gian và trạng thái bài làm của con.
- [ ] **Bước 3.3:** Khối nội dung đề bài và tài liệu học tập do giáo viên giao.
- [ ] **Bước 3.4:** Khối bài làm của con (file đính kèm, câu trả lời, thời gian con nộp bài).
- [ ] **Bước 3.5:** Khối điểm số và lời phê sư phạm của giáo viên (nếu đã chấm).
- [ ] **Bước 3.6:** Nút hành động phụ huynh: `[ 🔔 Nhắc con nộp bài ]` và `[ 💬 Nhắn giáo viên bộ môn ]`.

### Giai đoạn 4: Xây dựng Giao diện Tiến độ học tập (`ParentProgressScreen`)
- [ ] **Bước 4.1:** Header `Tiến độ học tập · Minh` + Pill `10A1` + Action icons (Tải PDF, Share).
- [ ] **Bước 4.2:** 2 Card KPI trên cùng: `KHÓA ĐANG HỌC (3)` và `TIẾN ĐỘ TRUNG BÌNH (65%)` kèm chỉ số lộ trình.
- [ ] **Bước 4.3:** Danh sách `CourseProgressCard`:
  - Khóa Toán nâng cao (8/12 buổi - 67%, đúng tiến độ).
  - Khóa Tiếng Anh IELTS Junior (5/10 buổi - 50%, cảnh báo bài viết luận).
  - Khóa STEM (12/12 buổi - 100%, huân chương & nút Xem chứng nhận).
- [ ] **Bước 4.4:** Khối Ghi chú từ Giáo viên chủ nhiệm ở đáy trang.
- [ ] **Bước 4.5:** Đấu nối liên kết: Bấm cảnh báo bài viết luận mở thẳng màn hình Bài tập về nhà; Bấm "Xem chứng nhận" mở dialog/bottomsheet chứng nhận.

### Giai đoạn 5: Đấu nối Điều hướng từ Learning Root Hub (`ParentLearningScreen`)
- [ ] **Bước 5.1:** Đấu nối Card 3 (`Bài tập về nhà`) mở `ParentHomeworkScreen`.
- [ ] **Bước 5.2:** Đấu nối Card 4 (`Tiến độ khóa học`) mở `ParentProgressScreen`.
- [ ] **Bước 5.3:** Đấu nối nút đáy `[ Xem bài tập của lớp này → ]` ở `ParentClassDetailScreen` mở `ParentHomeworkScreen`.

### Giai đoạn 6: Kiểm thử, Tối ưu & Báo cáo
- [ ] **Bước 6.1:** Chạy `flutter analyze` đảm bảo 0 lỗi, 0 cảnh báo linting.
- [ ] **Bước 6.2:** Kiểm tra UI responsive, không bị overflow trên mọi kích thước màn hình.
- [ ] **Bước 6.3:** Commit từng giai đoạn bằng **tiếng Việt có dấu**, không push code lên remote.

---

## 6. Tiêu chí Nghiệm thu (Acceptance Criteria)

| Tiêu chí | Điều kiện Đạt (PASS) |
|---|---|
| **Tuân thủ vai trò Phụ huynh** | Tuyệt đối KHÔNG có nút làm bài tập hay nộp bài thay con. Chỉ có nút `Chi tiết bài tập >`, `Nhắc con làm bài` hoặc `Xem bài đã chấm`. |
| **Đầy đủ 2 trạng thái Bài tập** | - Trạng thái có bài: Hiện đúng danh sách bài khẩn cấp, đang làm, đã nộp.<br>- Trạng thái Quá hạn (0): Hiện đúng All-clear illustration + Khối kết quả tuần gần nhất (3/3 bài, 8.8 điểm). |
| **Tiến độ trực quan kép** | Hiển thị đồng thời cả số buổi (`X/Y buổi`), tỷ lệ phần trăm (`%`), số buổi còn lại và thanh progress bar tương ứng. |
| **Chất lượng code & Commit** | - `flutter analyze` 0 issue.<br>- Commit git bằng tiếng Việt có dấu.<br>- Không push lên remote. |
