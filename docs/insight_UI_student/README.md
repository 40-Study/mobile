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
4. [**Kế hoạch tinh chỉnh giao diện Học sinh theo Kiến trúc Lai Tối ưu (Student UI Refinement Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/STUDENT_UI_REFINEMENT_PLAN.md)
   * **Bối cảnh & Mục tiêu:** Khắc phục hội chứng "Lạm dụng Card", khôi phục cảm xúc chào đón và các điểm chạm hành động trực quan.
   * **Triết lý Kiến trúc Lai (Hybrid Surface Architecture):** Kết hợp nhịp thở thị giác, Hero greeting to bản, Nút CTA tròn xanh, Avatar giảng viên của Old UI với hệ thống Design Tokens và Positive Empty State của New UI.
   * **Bản đồ bố cục Trang chủ mới (ASCII Wireframe):** Chi tiết phân tầng nửa trên trắng tinh khôi + nửa dưới Khay bề mặt cong (Curved Surface Tray bo cong 28px).
   * **Kế hoạch chi tiết 6 component/màn hình:** Top Nav Bar, Hero Greeting & Capsule Pills, Thẻ Tiếp tục học, Khay bề mặt cong, Thẻ Khóa học, và các Tab chức năng.
   * **Lộ trình 5 giai đoạn thực thi tuần tự & Tiêu chí nghiệm thu an toàn 10 điểm.**
5. [**Kế hoạch nâng cấp UI/UX & Chuẩn hóa dữ liệu Phân hệ Quiz (Quiz UI/UX Refinement & Result Fix Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/QUIZ_UI_UX_REFINEMENT_AND_RESULT_FIX_PLAN.md)
   * **Bóc tách nguyên nhân gốc rễ:** Phân tích hội chứng "Card Fatigue" trên màn hình làm bài và lỗi logic so sánh `correctAnswer = -1` dẫn đến câu đúng/sai bị lẫn lộn trên màn hình kết quả.
   * **Giải pháp UI/UX làm bài:** Bố cục mở thoáng đãng, thẻ đáp án có độ nổi xúc giác (tactile elevation), chuyển động vuốt `PageView`, thanh Slim Progress Header, Bottom Sheet ma trận câu hỏi (Question Palette), và tính năng cắm cờ xem lại (Flag for Review).
   * **Chuẩn hóa API & Luồng dữ liệu:** Tích hợp gọi `GET /api/quizzes/:id/attempts/:attemptId` sau khi nộp bài để lấy 100% dữ liệu thật từ Server (`is_correct`, `correct_answer_ids`, `explanation`).
   * **Tái thiết kế màn hình kết quả:** Tách biệt cảm xúc đạt/chưa đạt với Lottie Confetti vinh danh, hộp giải thích sư phạm chi tiết và bộ lọc câu hỏi tương tác.
   * **Lộ trình 4 giai đoạn thực hiện & 4 tiêu chí nghiệm thu chặt chẽ.**
6. [**Kế hoạch nâng cấp Trắc nghiệm chọn nhiều đáp án & Xem lại chi tiết bài làm từ Bài học (Multiple Choice & Persistent Review Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/QUIZ_MULTIPLE_CHOICE_AND_PERSISTENT_REVIEW_PLAN.md)
   * **Khảo sát & Bóc tách nguyên nhân gốc rễ:**
     * Lỗi chỉ chọn được 1 đáp án trên câu Multiple Choice do `QuizReady.answers` dùng `Map<int, int>` và ghi đè lựa chọn, payload nộp bài chỉ gửi 1 ID.
     * Lỗi mất danh sách câu hỏi khi bấm "Xem điểm" từ bài học do `QuizResultScreen` nhận mảng rỗng `reviewItems = []`, ẩn toàn bộ khối review do cờ `hasContent == false`, và `QuizResultStorage` chưa lưu `attemptId`.
   * **Giải pháp kỹ thuật (100% Mobile Flutter, không sửa Backend):**
     * Chuyển đổi kiến trúc sang `Map<int, Set<int>>` hỗ trợ toggle nhiều lựa chọn và submit mảng `selected_answer_ids`.
     * Mở rộng `QuizResultStorage` lưu `attemptId`, bổ sung `getQuizReviewDetails` trong Repository tự động fetch chi tiết bài thi khi mở từ bài học.
     * Thiết kế UI chuyên biệt: Pill Badge `[✓ Chọn nhiều đáp án]`, Checkbox icon, Squircle badge, và hiển thị rõ ràng 4 trạng thái xem lại (bao gồm cảnh báo bỏ sót đáp án đúng).
   * **Lộ trình 4 giai đoạn & 8 tiêu chí nghiệm thu an toàn.**

7. [**Kế hoạch tái thiết kế Hero Banner & Bổ sung cơ chế lướt ngang bộ lọc danh mục (Hero Banner Redesign & Category Swipe Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/BANNER_REDESIGN_BADGES_AND_CERTIFICATES_PLAN.md)
   * **Bóc tách 2 vấn đề cốt lõi:**
     1. Hero Banner dùng `LinearGradient` xanh đen/xanh gắt đối chọi thị giác, đi ngược lại triết lý bề mặt phẳng sáng (Flat Light Surface) của hệ thống.
     2. Bộ lọc danh mục (Category Chips) hiện là dạng tĩnh, bắt buộc người dùng phải chạm (tap) từng chip thủ công, thiếu cơ chế lướt ngang (horizontal swipe) đặc trưng của mobile để chuyển đổi qua lại giữa các danh mục (`All` <-> `Design` <-> `Programming`...).
   * **Triết lý thiết kế Hero Banner mới (Tech & Academic Style):** Loại bỏ 100% gradient gắt, chuyển sang bề mặt trắng tinh tế với viền mỏng `0.8px`, bóng mờ khuếch tán siêu nhẹ, điểm nhấn icon squircle pastel (`amber50`, `blue50`), chip xác thực số điện tử và thanh tiến độ Slim Minimalist 6px.
   * **Kiến trúc lướt ngang chuyển bộ lọc (Swipeable Category View):**
     * Kết hợp `NestedScrollView` + `SliverPersistentHeader` (ghim thanh chip khi cuộn) + `PageView` đa danh mục.
     * Cơ chế đồng bộ 2 chiều: Vuốt ngang trên danh sách sẽ chuyển tab và tự động scroll thanh chip; chạm chip sẽ kích hoạt animation trượt trang.
     * Sử dụng `PageStorageKey` bảo toàn vị trí cuộn độc lập cho từng tab danh mục.
   * **Module hóa mã nguồn:** Tách riêng `AchievementsHeroBanner`, `CertificatesHeroBanner` và `CategoryTabsHeaderDelegate`.


8. [**Kế hoạch tái thiết kế & Nâng cấp giao diện Nhóm Hồ sơ Giảng viên (Instructor Profile Screens Redesign Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/INSTRUCTOR_PROFILE_SCREENS_REDESIGN_PLAN.md)
   * **Bóc tách 3 vấn đề cốt lõi:**
     1. Khối Hero Banner giảng viên trên màn hình Khóa học bị dư thừa thông tin do lặp lại từ màn hình chi tiết trước đó, chiếm dụng không gian hiển thị danh sách.
     2. Giao diện Course Card quá đơn điệu: dùng chung 1 khung thumbnail xanh nhạt và 1 icon sách duy nhất cho mọi khóa học; thiếu sự phân cấp thị giác giữa khóa đang học và khóa chưa mua.
     3. Cả 2 màn hình (Khóa học & Đánh giá) đều thiếu cơ chế lướt ngang (horizontal swipe) đặc trưng của mobile để chuyển đổi qua lại giữa các danh mục / mức lọc sao.
   * **Giải pháp thiết kế thị giác (Flat Light Academic Style - KHÔNG dùng gradient đậm):**
     * Loại bỏ hoàn toàn khối Card thông tin giảng viên lặp lại trên InstructorCoursesScreen.
     * Tinh hoa hóa Thumbnail với hệ Squircle Pastel đa sắc thái theo chuyên môn (UI/UX: Indigo, Product Design: Emerald, User Research: Lavender) kèm badge cấp độ mini.
     * Phân cấp rõ rệt 2 trạng thái: Khóa đang học (pill tiến độ, thanh slim bar 5px, nút tiếp tục học) và Khóa chưa mua (giá học phí nổi bật, số lượng học viên, rating sao).
   * **Kiến trúc Horizontal Swipe 2 chiều:**
     * NestedScrollView + SliverPersistentHeader(pinned: true) + PageView.builder.
     * Ghim thanh Filter Chips khi cuộn dọc và đồng bộ 2 chiều trơn tru giữa cử chỉ vuốt ngang và thanh chip tự cuộn.
     * Áp dụng đồng thời cho InstructorCoursesScreen (chuyển đổi danh mục) và InstructorReviewsScreen (chuyển đổi 6 mức lọc điểm sao kèm Empty State).

9. [**Kế hoạch tái thiết kế Header các màn hình chính phân hệ Học sinh: Phương án Seamless Open Header (Main Screens Seamless Header Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/HEADER_REDESIGN_MAIN_SCREENS_PLAN.md)
   * **Bóc tách vấn đề:** Khắc phục triệt để cảm giác "Header giống một chiếc Card treo ngược từ trên đỉnh" do bo cong đáy và đổ bóng; triệt tiêu hội chứng lạm dụng Card (Card Fatigue).
   * **Đặc tả thiết kế Phương án A (Seamless Open Header – Chuẩn Apple Modern & Notion):**
     * Header hòa tan 100% vào nền trang (`context.surfaceBg` `#F8FAFC`), không có bất kỳ đường viền, bóng đổ hay góc cong đóng hộp nào.
     * Nâng cấp Typography dạng **Large Title (25sp, bold 800)** to rõ, đẳng cấp, mang đậm phong cách công nghệ học thuật hiện đại.
     * Leading Icon Squircle pastel `40×40` và Trailing Action button trắng `38×38` nổi tự nhiên trên nền trang như các điểm chạm tinh tế.
   * **Lộ trình thực hiện:** 6 bước triển khai từ tái cấu trúc `StudentAppHeader`, cập nhật 4 màn hình chính, kiểm tra `flutter analyze` đến build & test thực tế trên Android Emulator.
