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

10. [**Kế hoạch Khắc phục Lỗi Điều hướng Khóa học Giảng viên, Tái thiết kế Card Chứng chỉ & Xử lý Toàn diện Dark Mode (Student UI Course, Certificate & Dark Mode Fix Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/STUDENT_UI_COURSE_CERT_DARKMODE_FIX_PLAN.md)
    * **Bóc tách 3 vấn đề cốt lõi:**
      1. Click vào khóa học trong trang khóa học của giảng viên (`InstructorCoursesScreen`) và hồ sơ giảng viên (`InstructorDetailScreen`) không điều hướng do thiếu handler / đang dùng SnackBar tạm thời.
      2. Bug nút "Xem chứng chỉ" bị đơ sau khi back về do điều kiện `(prev.certificate == null && curr.certificate != null)` trong `listenWhen` không còn thỏa mãn; card hoàn thành khóa học có nút xanh lá bị thô cứng, chật chội và vỡ giao diện trong Dark Mode.
      3. Lỗi mất chữ (chữ đen trên nền đen) trên diện rộng khi chuyển sang Dark Mode do extension `TogetherColorsX` trong `app_colors.dart` cố định dải màu `slate*` thành mã màu tối mà không kiểm tra chế độ ban đêm.
    * **Giải pháp kỹ thuật & Thẩm mỹ:**
      * Bổ sung điều hướng chuẩn sang `CourseDetailScreen` bọc trong `CourseDetailBloc`.
      * Sửa logic callback mở trực tiếp chứng chỉ khi đã có trong state; tái thiết kế Card chứng chỉ dạng Milestone Celebration Card sang trọng, phân tầng 2 lớp, chuẩn Design Tokens.
      * Tái cấu trúc linh hoạt hệ thống Slate Tokens tự động đảo màu theo `brightness == Brightness.dark` và thay thế các container `Colors.white` cứng.
    * **Lộ trình 4 giai đoạn & 5 tiêu chí nghiệm thu an toàn.**

11. [**Phân tích UI Hiện tại & Đề xuất Tái thiết kế Giao diện Phân hệ Quiz: Giải pháp "Khử nhựa" & Nâng tầm Đẳng cấp Học thuật Tinh tế (Quiz UI De-plasticize & Redesign Proposal)**](file:///C:/ForteX/mobile/docs/insight_UI_student/QUIZ_UI_REDESIGN_ANALYSIS_AND_PROPOSAL.md)
    * **Tôn vinh nền tảng UX:** Xác nhận luồng nghiệp vụ, tương tác PageView, cắm cờ xem lại, ma trận câu hỏi và persistent review chi tiết từ API đã hoàn thiện vững vàng.
    * **Mổ xẻ 6 triệu chứng thẩm mỹ "UI nhựa":**
      1. Hội chứng "Lạm dụng Pill" (Pill Overdose - 5-6 viên nhộng bo tròn 999px chen chúc).
      2. Bảng màu xung đột & độ bão hòa ngây ngô (5 màu rực tranh nhau thị giác: tím, vàng, xanh lá, đỏ, xanh dương).
      3. Viền dày 2.0px thô cứng & đổ bóng màu đục như khuôn nhựa đúc.
      4. Hộp lồng trong hộp viền màu (Box-in-Box Container Fatigue) ngột ngạt ở màn hình kết quả.
      5. Vòng tròn điểm số & Stat Cards phong cách 2018 lỗi thời.
      6. Ma trận câu hỏi Question Palette sặc sỡ như bàn cờ lô tô.
    * **Định hình phong cách mới: "Refined Academic Minimalism" (Tối giản Học thuật Tinh tế):**
      * 3 Triết lý cốt lõi: *Calm Focus*, *Tactile Elegance*, *Academic Harmony*.
      * Hệ thống Viền Hairline 0.8px - 1.0px siêu mảnh, bóng đa tầng khuếch tán mềm, góc bo Squircle hiện đại.
      * Thẻ đáp án xúc giác với Squircle Letter Box 32px, hiệu ứng chạm haptic và scale 0.985 tinh xảo.
      * Timer capsule Monospace chống giật số, thanh tiến độ siêu mỏng 2.5px gradient.
      * Question Palette phong cách Clean Seat-Map với Indicator Dots thanh lịch.
      * Màn hình kết quả với Hero Radial Score Gauge 8px, Segmented Metric Filter Strip và thẻ xem lại bài làm dùng Left Accent Stripe 3.5px + Callout giải thích phong cách Notion.
    * **Ma trận đối chiếu Before vs. After & Lộ trình thực thi 4 giai đoạn an toàn 100% logic.**

12. [**Kế hoạch Tái thiết kế Card Tổng quan Tab Thành tích: The Academic Honor Deck (Overview Statistics Card Redesign Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/OVERVIEW_STATISTICS_CARD_REDESIGN_PLAN.md)
    * **Bóc tách 4 điểm yếu chí mạng khiến Card Tổng quan bị chìm nghỉm:**
      1. Thiếu tính chủ đạo và điểm rơi thị giác (No Visual Anchor / Lack of Dominance).
      2. Dàn trải 4 cột cơ học và chật chội (Cramped 4-Column Layout, nhãn text bị co ép).
      3. Bỏ quên yếu tố vinh danh cốt lõi: Cấp bậc học thuật (`stats.level`) & Điểm kinh nghiệm tích lũy (`stats.currentXp` / `nextLevelXp`).
      4. Lỗi dữ liệu cứng: Hardcode `value: '18'` cho cột huy hiệu thay vì dùng dữ liệu thực từ state.
    * **Ý tưởng đột phá "The Academic Honor Deck" (Bi-Level Prestige Canvas):**
      * Triết lý thiết kế: *Flat Light Academic Luxury* - Tinh giản, sang trọng, tôn vinh đẳng cấp học thuật, nói không với card-fatigue và gradient tối nặng nề.
      * **Tầng 1 (Upper Deck - Honor & Level Hero):** Squircle Emblem Huân chương vàng kim (48×48px), Bảng danh hiệu học thuật động (`Tân Khoa`, `Học Giả Tiến Bộ`, `Học Giả Tinh Hoa`...), Chip Cấp độ `[ ⭐ CẤP ĐỘ X ]`, và thanh tiến trình kinh nghiệm Slim Tech Bar 6px.
      * **Tầng 2 (Lower Deck - Quad Micro-Stat Pods):** 4 khối thẻ vi mô nền pastel thanh khiết độc lập (🔥 Chuỗi học tập Streak, ⏱️ Giờ học tích lũy, 📚 Bài học hoàn tất, 🏅 Huy hiệu đạt được thực tế) với typography số lớn ấn tượng.
    * **Ma trận đối chiếu Before vs. After, đặc tả Design Tokens & Lộ trình 4 giai đoạn triển khai.**

13. [**Kế hoạch Đập đi Xây lại Phần Tổng quan: Dòng Thời Gian Hành Trình Học Tập (Academic Learning Journey Timeline & Zero-Card Redesign Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/LEARNING_JOURNEY_TIMELINE_REDESIGN_PLAN.md)
    * **Bóc tách 2 yêu cầu cốt lõi từ người dùng:**
      1. Khắc phục triệt để lỗi "lạm dụng Card" (Card Fatigue / Box-in-Box): Bỏ hoàn toàn khung hộp bao bọc và 4 ô vuông con bên trong.
      2. Tái hiện toàn bộ quá trình học tập (The Entire Learning Odyssey): Chuyển đổi con số tĩnh thành Dòng thời gian liên tục từ ngày đầu nhập môn đến đỉnh cao hiện tại và mục tiêu tương lai.
    * **Ý tưởng đột phá "The Academic Chronicle" (Zero-Card Seamless Timeline):**
      * **Trục đường ray ánh sáng (The Living Spine):** Đường ray chuyển màu gradient từ xanh hoàng gia đến ngọc lục bảo rồi nét đứt tương lai.
      * **Mô hình 3 Pha Thời gian:**
        - Trạm 1: Khởi nguyên tri thức (`⏱️ Giờ học` & `📚 Bài học hoàn thành` nhúng trực tiếp không đóng hộp).
        - Trạm 2: Kỷ luật bền bỉ (`🔥 Chuỗi Streak` rực lửa).
        - Trạm 3: Đỉnh cao hiện tại (Huân chương danh dự, Danh hiệu học thuật `Học Giả Tinh Hoa`, Cấp độ, Điểm XP và hiệu ứng hào quang thở nhịp nhàng `Breathing Beacon Glow`).
        - Trạm 4: Chân trời kế tiếp (Cấp độ tiếp theo đang chờ đón với đường nét đứt).
    * **Hiệu ứng Animation đánh thức cảm xúc:** Tia sáng chạy dọc đường ray (Flowing Trail Tracer), vầng sáng hào quang thở (Breathing Aura Pulse 2.2s), xuất hiện so le (Staggered Reveal) và rung phản hồi xúc giác (Micro-Haptic Waypoints).
    * **Lộ trình 4 giai đoạn triển khai chi tiết (Chưa code).**

14. [**Kế hoạch Tái thiết kế Phần Tổng quan: Bản đồ Tiến hóa Cấp bậc (The RPG Level Roadmap - Zero-Card Progression Canvas)**](file:///C:/ForteX/mobile/docs/insight_UI_student/RPG_LEVEL_ROADMAP_OVERVIEW_PLAN.md)
    * **Bóc tách 5 điểm nghẽn thị giác từ ảnh chụp thực tế:**
      1. Cảm giác "form stepper / tracking vận đơn bưu chính" khô cứng, hành chính.
      2. Bội thực văn xuôi tự sự lê thê chiếm 50% diện tích mà không mang lại giá trị.
      3. Điểm rơi Hero bị chìm, bị khối "Huy hiệu gần đây" to rực rỡ bên dưới nuốt chửng hoàn toàn.
      4. Gộp thập cẩm thông tin (giờ học + streak + level) thay vì một Bản đồ Cấp bậc thực thụ (Lv.1 -> Lv.2 -> Lv.3 -> Lv.4 -> Lv.5).
      5. Nghịch lý logic "Tiến trình thăng cấp 100%" nhưng vẫn ở Level 4 và chưa lên Level 5.
    * **Ý tưởng đột phá "The RPG Level Roadmap" (Bản đồ Cấp độ Game-like):**
      * **Tầng 1 (The Waypoint Path):** Trục tiến trình cấp bậc ngang/bậc thang (`[✓ Lv.1]` -> `[✓ Lv.2]` -> `[✓ Lv.3]` -> `[⭐ Lv.4 HERO]` -> `[🔒 Lv.5 NEXT]`).
      * **Tầng 2 (The Hero Zenith Core):** Huy chương 3D mạ vàng 64px, vầng hào quang thở ánh kim (`Breathing Golden Aura 2.4s`), typography số lớn `1,850 XP` uy quyền, và thanh năng lượng thăng cấp chính xác.
      * **Tầng 3 (The Satellite Metric Pods):** 3 Capsule Pods xúc giác thanh nhã bóc tách độc lập (🔥 Chuỗi kỷ luật 12 ngày, ⏱️ Giờ học tích lũy, 📚 Bài học hoàn tất).
      * **Hệ thống Animation Ánh sáng & Dòng chảy:** Dòng sóng ánh sáng trôi trên đường ray (Flowing Energy Conduit), Hào quang thở 3 tầng (Multi-Layer Solar Corona), Thanh năng lượng thủy dịch XP lướt sáng (Liquid Shimmer Gauge), Hạt ngọc dẫn đường (Leading Energy Orb), và Hạt sao vinh danh lấp lánh (Twinkle Glints).
    * **Chuẩn hóa công thức toán học XP/Level Client-side:** Phân rã `total_points` chuẩn 500 XP/level, hiển thị chính xác `350 / 500 XP (70%)` và số XP còn thiếu để lên Cấp 5, triệt tiêu 100% bug hiển thị.
    * **Trạng thái:** Đã triển khai thành công 100% (Hoàn thành canvas gradient, color grading WCAG AAA, test suite PASS 100%).

15. [**Kế hoạch Thiết kế Hệ thống Đề xuất Thông minh cho Màn hình Tìm kiếm (Search Micro-Recommendation System Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/SEARCH_RECOMMENDATION_SYSTEM_PLAN.md)
    * **Phân tích hiện trạng từ ảnh chụp thực tế:** Màn hình tìm kiếm khi chưa gõ chữ (Zero-query state) bị lãng phí hơn 80% diện tích trắng trống; thiếu khả năng khám phá chủ động.
    * **Mục tiêu:** Biến trang Search thành Cổng khám phá cá nhân hóa (Smart Discovery Portal), cung cấp gợi ý khóa học phù hợp ngay khi chạm vào ô tìm kiếm.
    * **Thuật toán Đề xuất Hybrid Heuristic Scoring:** Tính điểm đa tiêu chí $Score = 0.35 \times S_{\text{learning}} + 0.25 \times S_{\text{search}} + 0.25 \times S_{\text{quality}} + 0.15 \times S_{\text{trend}} - P_{\text{enrolled}}$.
    * **Bố cục giao diện 4 tầng:**
      1. Tìm kiếm gần đây (Recent Searches) dạng chip ngang thu gọn.
      2. Xu hướng tìm kiếm (Trending Keywords Pills 🔥).
      3. Gợi ý riêng cho bạn (Personalized Recommendations) kèm huy hiệu minh bạch lý do (`💡 Dựa trên khóa Flutter đang học`).
      4. Khóa học thịnh hành cộng đồng (Top Rated & Trending Courses).
    * **Đặc tả Dark Mode & Kiến trúc kỹ thuật BLoC/Service chi tiết.**

16. [**Kế hoạch Nâng cấp Hiển thị Light Mode cho Bản đồ Cấp bậc: Khay Nền Gradient Khí Quyển & Cân Chỉnh Độ Tương Phản Màu Sắc (The Ambient Honor Canvas & Contrast Grading Plan)**](file:///C:/ForteX/mobile/docs/insight_UI_student/LIGHT_MODE_AMBIENT_CANVAS_PLAN.md)
    * **Phân tích đối chiếu từ ảnh chụp thực tế:** Dark Mode rực rỡ nhờ độ tương phản phát quang cao (> 12:1), trong khi Light Mode bị mờ nhạt do ánh hào quang vàng hòa tan vào nền trắng và thiếu bề mặt nâng đỡ (Visual Grounding).
    * **Giải pháp kết hợp Phương án 1 + Phương án 3:**
      * **Khay Nền Khí Quyển Mở (The Ambient Honor Canvas):** Chuyển màu gradient đa tầng từ Trắng tinh khôi $\rightarrow$ Vàng ngà hoàng gia $\rightarrow$ Xanh ngọc dịu mắt, viền hairline $0.8\text{px}$ mạ vàng hổ phách nhạt bo cong $22\text{px}$, đổ bóng đa tầng khuếch tán $24\text{px}$.
      * **Bảo tồn Dark Mode 100%:** Trong Dark Mode, khay nền tự động chuyển sang bán trong suốt `slate900` $35\%$ viền `slate800`, giữ nguyên vẻ đẹp huyền bí hiện tại.
      * **Cân chỉnh màu sắc đạt chuẩn WCAG AAA:** Chữ mốc cấp độ `Lv.1` - `Lv.3` nâng lên màu nâu hổ phách sẫm `Color(0xFF92400E)` sắc nét; vầng hào quang bổ sung lớp bóng hổ phách ấm; 3 Pods bên dưới nâng cấp thành dạng viên nhộng trắng sứ nổi nhẹ (Elevated Pure-White Pills).
    * **Trạng thái:** Đã triển khai thành công 100% (Hoàn thành canvas gradient, color grading WCAG AAA, test suite PASS 100%).




