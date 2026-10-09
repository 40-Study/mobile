# INSIGHT UI STUDENT: PHÂN TÍCH & KẾ HOẠCH NÂNG CẤP GIAO DIỆN

Thư mục này lưu trữ toàn bộ tài liệu phân tích đối chiếu, nghiên cứu UX và kế hoạch thực thi cải tiến giao diện người dùng cho vai trò **Học sinh (Student)** trên ứng dụng 40Study Mobile, hướng tới việc tiệm cận các tiêu chuẩn thiết kế cao cấp của vai trò **Phụ huynh (Parent V2.0)**.

---

## Danh mục tài liệu:

1. [**Báo cáo so sánh Style giao diện: Role Student vs Role Parent**](file:///C:/ForteX/mobile/docs/insight_UI_student/UI_STYLE_COMPARISON_STUDENT_VS_PARENT.md)
   * Đánh giá chi tiết chân dung người dùng (User Persona) & triết lý thiết kế (UX Philosophy).
   * So sánh kiến trúc điều hướng 5 Tab, Header pattern và Data Scoping (Multi-child vs Single-user).
   * Phân tích hệ thống màu sắc (Semantic Mapping) & phân tầng bề mặt thị giác (Surface Layering).
   * Đối chiếu Typography, Spacing và Touch Targets giữa 2 vai trò.
   * Ma trận so sánh tổng hợp 8 tiêu chí.
   * 5 bài học then chốt rút ra từ thành công của Parent UI V2.0.

2. [**Kế hoạch nâng cấp giao diện Role Student chi tiết từng màn hình (Student UI Refactor Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/REFACTOR_STUDENT_UI_PLAN.md)
   * **Cam kết phạm vi:** Tuyệt đối KHÔNG thay đổi logic xử lý, API load data, Bloc/Cubit; chỉ tập trung 100% vào cải tiến Style và Presentation.
   * **5 Trụ cột Style cốt lõi:** Chuẩn hóa `StudentAppHeader`, Phân tầng 3 lớp (High-Contrast Layering), Bóc tách Section Header ra ngoài Card, Thẻ ca học/khóa học độc lập, 100% Design Tokens.
   * **Kế hoạch chi tiết từng màn hình:**
     * Màn hình 0: `StudentShell` & `StudentAppHeader` dùng chung.
     * Màn hình 1: Tab Trang chủ (`HomeScreen`).
     * Màn hình 2: Tab Học tập (`LearningScreen`, `MyCourseCard`, `FilterChipsRow`).
     * Màn hình 3: Tab Lịch học (`ScheduleScreen`, `CalendarWidget`, Ca học độc lập).
     * Màn hình 4: Tab Thành tích (`AchievementScreen`, Overview Stats, Streak).
     * Màn hình 5: Tab Tài khoản (`ProfileScreen`, Grouped Settings Cards).
     * Màn hình 6: Chi tiết Khóa học & Bài học (`CourseDetailScreen`, `LessonDetailScreen`).
   * **Quy chuẩn xử lý trạng thái Empty Data toàn diện (Mục 4):** Ma trận thiết kế chi tiết cho tất cả các tình huống `null` hoặc danh sách rỗng (`[]`) theo triết lý *Positive & Actionable Empty States*.
   * **Lộ trình 6 giai đoạn thực thi tuần tự (Phases 1 - 6).**
   * **Checklist nghiệm thu 9 điểm an toàn (bao gồm kiểm thử Empty Data).**
3. [**Đánh giá chuyên sâu UI Cũ vs Mới & Phân tích hiện tượng Lạm dụng Card (UI Evaluation Old vs New & Card Overuse)**](file:///C:/ForteX/mobile/docs/insight_UI_student/UI_EVALUATION_OLD_VS_NEW_AND_CARD_OVERUSE.md)
   * **Phân tích chi tiết giao diện gốc (Old UI):** Giải mã ý đồ thiết kế ban đầu về màu sắc, bố cục Hero Greeting, Pill Stats, khay nền xám cong (Curved Surface Tray) và nút CTA hành động trực quan.
   * **Đối chiếu Old vs New & Điểm thụt lùi (Design Regressions):** Chỉ rõ các điểm mất mát ở bản mới (mất avatar giảng viên trên thẻ khóa học, mất nút CTA tròn xanh, co cụm lời chào vào AppBar).
   * **Phân tích sâu hiện tượng "Lạm dụng Card" (Card Fatigue / Everything-is-a-box syndrome):** Lý do đóng hộp quá mức gây đứt gãy thị giác và tại sao phong cách của Phụ huynh không thể bê nguyên xi sang Học sinh.
   * **Đề xuất Kiến trúc Lai Tối ưu (Hybrid Surface Architecture):** Giải pháp dung hòa sự thoáng đãng, nồng nhiệt của Old UI với sự chỉn chu, hiện đại của New UI Tokens.
