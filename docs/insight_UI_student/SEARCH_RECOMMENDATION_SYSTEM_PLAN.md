# KẾ HOẠCH THIẾT KẾ HỆ THỐNG GỢI Ý KHÓA HỌC TRONG TÌM KIẾM
## (THE SMART SEARCH RECOMMENDATION & DISCOVERY SYSTEM)

> **Tài liệu tham chiếu:** `mobile/docs/insight_UI_student/`  
> **Áp dụng cho:** `mobile/lib/features/student/presentation/search/`  
> **Trọng tâm module:** `search_screen.dart`, `search_bloc.dart`, `search_state.dart`, `recent_searches.dart`  
> **Trạng thái:** Kế hoạch chi tiết (Plan Only - Chưa sửa mã nguồn)  
> **Mục tiêu then chốt:**  
> 1. **Khắc phục 75% "vùng đất chết" trên màn hình tìm kiếm:** Biến khoảng trống đen kịt vô nghĩa khi chưa nhập từ khóa thành một Trung tâm Khám phá Tri thức (Discovery Hub) sống động.  
> 2. **Hệ thống Gợi ý Cá nhân hóa Thu nhỏ (Intelligent Mini Recommendation System):** Tự động đề xuất các khóa học liên quan dựa trên chuyên ngành, các khóa học học sinh đang học và các khóa học thịnh hành nhất.  
> 3. **Cụm Chủ đề Thịnh hành (Popular Topics Pills):** Đề xuất các từ khóa/chủ đề hot có icon trực quan, bấm chạm là tìm kiếm tức thì.  
> 4. **Tối ưu trải nghiệm chạm (Zero-Friction UX):** Người học không cần gõ phím vẫn có thể tìm thấy khóa học ưng ý chỉ với 1 cú chạm.  
> 5. **Bảo toàn 100% Backend Go:** Tận dụng triệt để `StudentRepository.getAllCourses()` và `getActiveEnrollments()` sẵn có, thực thi gợi ý client-side heuristic siêu tốc.

---

## 1. BỐI CẢNH & PHÂN TÍCH HIỆN TRẠNG TỪ ẢNH CHỤP THỰC TẾ

Dựa trên hình ảnh chụp màn hình từ thiết bị của người dùng:

```
┌─────────────────────────────────────────────────────────────┐
│ ẢNH 1: HIỆN TRẠNG KHI VỪA MỞ TÌM KIẾM (SearchInitial)       │
│                                                             │
│  [←]  [ 🔍 Tìm kiếm khóa học, bài học... ]                  │
│                                                             │
│  Tìm kiếm gần đây                                Xóa tất cả │
│  [🕒 Flutter]   [🕒 Bloc]   [🕒 UI Design]                  │
│                                                             │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  ░░░░░ TOÀN BỘ 75% DIỆN TÍCH MÀN HÌNH BÊN DƯỚI BỊ BỎ HOANG ░░ │
│  ░░░░░   ĐEN KỊT / TRỐNG TRƠN (DEAD SCREEN SPACE)   ░░░░░░░░ │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
└─────────────────────────────────────────────────────────────┘
```

### 1.1. Ba (03) điểm yếu chí mạng của màn hình tìm kiếm hiện tại:

1. **Lãng phí "Không gian Vàng" (Dead Screen Space):**
   * Sau khi hiển thị 3 chip "Tìm kiếm gần đây", 75% không gian màn hình bên dưới hoàn toàn trống rỗng.
   * Trong thiết kế sản phẩm số (Product Design), trạng thái mở ô tìm kiếm là khoảnh khắc người dùng có **mức độ tập trung cao nhất** (High User Intent). Bỏ trống khu vực này là đánh mất cơ hội vàng để kích thích học tập.
2. **Thiếu tính định hướng cho người học mới hoặc người chưa có từ khóa sẵn:**
   * Không phải lúc nào học sinh cũng biết rõ mình muốn tìm từ khóa gì. Rất nhiều học sinh mở tìm kiếm với tâm lý: *"Để xem ForteX có khóa học nào hay ho/phù hợp với mình không"*.
   * Khi màn hình trống trơn, học sinh bị rơi vào hội chứng **"Sự bế tắc của trang giấy trắng" (Blank Slate Paralysis)** và có xu hướng thoát ra ngoài.
3. **Chưa có sự liên kết cá nhân hóa (Lack of Personalization):**
   * Hiện tại, danh sách "Tìm kiếm gần đây" đang hardcode cứng: `['Flutter', 'Bloc', 'UI Design']`. Hệ thống chưa liên kết với sở thích học tập hay tiến độ thực tế của người học.

---

## 2. Ý TƯỞNG THIẾT KẾ: TRUNG TÂM KHÁM PHÁ & GỢI Ý THÔNG MINH (THE SEARCH DISCOVERY HUB)

Biến màn hình tìm kiếm ban đầu thành một **"Trung tâm Khám phá Cá nhân hóa" (Smart Discovery Hub)** gồm 3 phân khu chức năng mạch lạc:

```
┌─────────────────────────────────────────────────────────────────────────┐
│ [←]  [ 🔍 Tìm kiếm khóa học, bài học...                          ]      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  PHÂN KHU 1: TÌM KIẾM GẦN ĐÂY (Recent Searches)                         │
│  Tìm kiếm gần đây                                             Xóa tất cả│
│  [🕒 Flutter]   [🕒 Lập trình Mobile]   [🕒 Figma UI]                   │
│                                                                         │
│ ─────────────────────────────────────────────────────────────────────── │
│                                                                         │
│  PHÂN KHU 2: CHỦ ĐỀ PHỔ BIẾN (Trending Topics Pills)                   │
│  Chủ đề nổi bật                                          ✨ Xu hướng    │
│  [ 📱 Mobile Dev ]  [ 🎨 UI/UX Design ]  [ 🤖 Trí tuệ AI ]               │
│  [ ⚙️ Backend Go ]   [ 🌐 Frontend Web ]  [ 📊 Khoa học Dữ liệu ]       │
│                                                                         │
│ ─────────────────────────────────────────────────────────────────────── │
│                                                                         │
│  PHÂN KHU 3: GỢI Ý DÀNH RIÊNG CHO BẠN (Curated Recommendations)         │
│  Gợi ý cho bạn                                           Dựa trên lộ trình│
│                                                                         │
│  ┌───────────┐  Flutter Mobile Development                              │
│  │ [THUMB]   │  ⭐ 4.9 (1.2k học viên) • 4 bài học                      │
│  │  16:9     │  🏷️ Lập trình Mobile • Giảng viên: Alex Rivera          │
│  └───────────┘  [ Khám phá ngay ]                                       │
│                                                                         │
│  ┌───────────┐  Advanced State Management with Bloc                     │
│  │ [THUMB]   │  ⭐ 4.8 (850 học viên) • 8 bài học                       │
│  │  16:9     │  🏷️ Nâng cao • Giảng viên: Sophia Chen                  │
│  └───────────┘  [ Khám phá ngay ]                                       │
│                                                                         │
│  ┌───────────┐  Modern UI/UX Design for Mobile Apps                     │
│  │ [THUMB]   │  ⭐ 5.0 (2.1k học viên) • 12 bài học                     │
│  │  16:9     │  🏷️ Thiết kế • Giảng viên: David Miller                 │
│  └───────────┘  [ Khám phá ngay ]                                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. THUẬT TOÁN GỢI Ý CÁ NHÂN HÓA THU NHỎ (CLIENT-SIDE HEURISTIC ENGINE)

Để đảm bảo **không cần can thiệp hay viết thêm API máy học phức tạp ở backend**, thuật toán gợi ý được xây dựng theo cơ chế **Heuristic Scoring Engine 3 Tầng**:

```
                                  [ STUDENT PROFILE ]
                                   │              │
                    Active Enrollments           Completed Lessons / Level
                                   │              │
                                   ▼              ▼
                     ┌────────────────────────────────────────┐
                     │ CLIENT HEURISTIC RECOMMENDATION ENGINE │
                     └────────────────────────────────────────┘
                                          │
              ┌───────────────────────────┼───────────────────────────┐
              ▼                           ▼                           ▼
       [ QUY TẮC 1 ]               [ QUY TẮC 2 ]               [ QUY TẮC 3 ]
  Đồng danh mục (Same Category)    Cùng lộ trình tiếp nối      Thịnh hành & Đánh giá cao
  (+40 điểm ưu tiên)               (+30 điểm cấp bậc)          (+30 điểm rating/popularity)
              │                           │                           │
              └───────────────────────────┼───────────────────────────┘
                                          │
                                          ▼
                         Top 3-5 Khóa Học Gợi Ý Tối Ưu Nhất
```

### 3.1. Chi tiết 3 Quy tắc xếp hạng (Scoring Rules)

1. **Quy tắc 1: Khóa học liên quan đến lộ trình đang học (Content Affinity - +40 điểm):**
   * Lấy danh sách khóa học đang theo học từ `getActiveEnrollments()`.
   * Trích xuất các `categoryId` hoặc `categoryName` (ví dụ: học viên đang học khóa Flutter $\rightarrow$ ưu tiên gợi ý các khóa học khác trong danh mục "Lập trình Mobile" hoặc "Flutter").
2. **Quy tắc 2: Khóa học cấp tiến tiếp theo (Progression Next-Step - +30 điểm):**
   * Nếu học viên đã hoàn thành khóa "Nhập môn / Cơ bản", ưu tiên đề xuất khóa "Nâng cao" hoặc "Thực chiến dự án".
   * Loại trừ các khóa học học viên đã hoàn thành 100% để tránh gợi ý thừa.
3. **Quy tắc 3: Khóa học thịnh hành & Top Rated (Trending & Top Rated Fallback - +30 điểm):**
   * Đối với học viên mới chưa tham gia khóa học nào: Ưu tiên hiển thị các khóa học có rating cao nhất (`rating >= 4.8`) và số lượng bài học phong phú.

---

## 4. MA TRẬN ĐỐI CHIẾU TRẢI NGHIỆM: TRƯỚC VÀ SAU CẢI TIẾN

| Tiêu chí | Bản Hiện Tại (Search Rỗng) | Bản Mới (Search Discovery & Recommendation) |
| :--- | :--- | :--- |
| **Không gian hiển thị** | 75% màn hình dưới đen kịt / trống rỗng | 100% diện tích màn hình được khai thác khoa học, cuốn hút |
| **Hành vi người dùng** | Bắt buộc phải gõ từ khóa thì mới có dữ liệu | Chỉ cần mở ô tìm kiếm là có ngay các khóa học được may đo riêng |
| **Gợi ý chủ đề** | 3 chip text hardcode tĩnh, không đổi | 6-8 chủ đề hot có icon trực quan, tự động cập nhật |
| **Thẻ khóa học gợi ý** | Không có | Thẻ compact 16:9 sắc sảo, hiển thị rating sao vàng, số bài và giảng viên |
| **Tỷ lệ chuyển đổi học** | Thấp, dễ thoát màn hình nếu không biết từ khóa | Rất cao, chạm ngay vào khóa học gợi ý để chuyển sang trang chi tiết |
| **Độ phụ thuộc Backend** | Không có logic gợi ý | 100% Client-side Heuristic trên API `getAllCourses()` sẵn có, 0 sửa Backend |

---

## 5. THIẾT KẾ COMPONENT CHI TIẾT

### 5.1. Component 1: `PopularTopicsSection` (Chủ đề Nổi bật)
* **Bố cục:** Dạng `Wrap` với khoảng cách `spacing: 8`, `runSpacing: 8`.
* **Phần tử:** Chip Squircle hiện đại bo góc `8px`, nền `cs.surfaceContainerHighest`, viền hairline `0.8px` siêu mỏng.
* **Tương tác:** Khi học sinh bấm vào chip chủ đề (ví dụ `📱 Mobile Dev`):
  * Tự động điền text `"Mobile Dev"` vào ô tìm kiếm.
  * Tự động kích hoạt sự kiện `SearchQueryChanged("Mobile Dev")` $\rightarrow$ Chuyển sang kết quả tìm kiếm ngay lập tức.

### 5.2. Component 2: `RecommendedCourseCard` (Thẻ Gợi ý Khóa học Compact)
* **Bố cục:** Hàng ngang `Row` phân tầng 2 cột:
  * Cột trái: Ảnh thumbnail tỷ lệ 16:9 kích thước `96×64px`, bo góc `10px`, có fallback icon tinh tế khi đang tải ảnh.
  * Cột phải:
    * Tag khuyến nghị nhỏ xinh: `✨ DÀNH CHO BẠN` (nền xanh pastel `blue50`, chữ `brandBlueDark`).
    * Tên khóa học: Font size 14px, `FontWeight.w800`, max 2 dòng, `TextOverflow.ellipsis`.
    * Dòng meta thông tin: `⭐ 4.9` vàng hổ phách • `12 bài` • Tên giảng viên.
* **Tương tác:** Tap vào thẻ sẽ điều hướng trực tiếp đến `CourseDetailScreen` của khóa học đó.

---

## 6. LỘ TRÌNH TRIỂN KHAI 4 GIAI ĐOẠN (IMPLEMENTATION ROADMAP)

> **Cam kết:** Đây là tài liệu kế hoạch, CHƯA chỉnh sửa code phân hệ search trong bước này.

### Giai đoạn 1: Nâng cấp Data Layer & Search Bloc State
1. Bổ sung sự kiện `SearchRecommendationsRequested` trong `search_event.dart`.
2. Cập nhật `SearchInitial` trong `search_state.dart` để chứa:
   * `recentSearches: List<String>`
   * `popularTopics: List<String>`
   * `recommendedCourses: List<CourseModel>`
3. Trong `search_bloc.dart`: Khi khởi tạo hoặc khi query rỗng, gọi song song `getAllCourses()` và `getActiveEnrollments()` để tính toán danh sách gợi ý tốt nhất.

### Giai đoạn 2: Hiện thực hóa UI Components
1. Tạo file `mobile/lib/features/student/presentation/search/widgets/popular_topics_section.dart`.
2. Tạo file `mobile/lib/features/student/presentation/search/widgets/recommended_course_card.dart`.
3. Tái cấu trúc `recent_searches.dart` thành `search_discovery_view.dart` tích hợp mượt mà cả 3 phân khu (Recent Searches + Popular Topics + Recommended Courses).

### Giai đoạn 3: Tích hợp vào `SearchScreen` & Xử lý Điều hướng
1. Nhúng `SearchDiscoveryView` vào nhánh `state is SearchInitial` trong `search_screen.dart`.
2. Gắn handler tap:
   * Tap Recent/Topic chip $\rightarrow$ trigger tìm kiếm.
   * Tap Recommended card $\rightarrow$ điều hướng sang `CourseDetailScreen`.
3. Tương thích toàn diện Dark Mode và Light Mode (100% Design Tokens).

### Giai đoạn 4: Kiểm thử Widget Test & Verify trên Thiết bị Thực tế
1. Viết bộ Widget Test `search_discovery_view_test.dart` kiểm tra:
   * Render đầy đủ 3 phân khu khi vừa mở màn hình tìm kiếm.
   * Tap chip topic tự động điền query và gọi event search.
   * Tap khóa học gợi ý gọi đúng navigation callback.
   * Không bị tràn viền (RenderFlex overflow) trên màn hình 360px.
2. Chạy `flutter test` toàn bộ phân hệ search và `flutter analyze` 0 lỗi.

---

## 7. TIÊU CHÍ NGHIỆM THU AN TOÀN (ACCEPTANCE CRITERIA)

1. [ ] **Không còn màn hình đen trống trơn:** Khi học sinh mở tìm kiếm, xuất hiện ngay các chủ đề hot và các khóa học gợi ý đẹp mắt.
2. [ ] **Thao tác 1 chạm (1-Tap Search):** Bấm vào bất kỳ chip chủ đề nào là tìm kiếm ngay, không cần gõ bàn phím.
3. [ ] **Điều hướng mượt mà:** Bấm vào thẻ gợi ý mở thẳng trang chi tiết khóa học.
4. [ ] **0 Sửa Backend:** Toàn bộ thuật toán chạy client-side dựa trên dữ liệu repository có sẵn.
5. [ ] **Mã nguồn sạch & Test xanh:** `flutter analyze` 0 lỗi; Widget Tests PASS 100%.
