# Kế hoạch Đồng nhất Sắc xanh Học thuật (#3D5FC4) cho Module Student

> **Tài liệu:** `mobile/docs/insight_UI_student/ACADEMIC_BLUE_UNIFICATION_PLAN.md`  
> **Định hướng phong cách:** Học thuật, chuyên nghiệp, đằm tính & chuẩn mực (Academic & Professional UI)  
> **Mã màu chủ đạo (Single Primary Source):** `#3D5FC4` (`Color(0xFF3D5FC4)`)  
> **Trạng thái:** DRAFT - Chờ duyệt triển khai  

---

## 1. Bối cảnh & Mục tiêu Chiến lược

### 1.1. Hiện trạng xung đột màu sắc
Hiện tại, trên cùng một màn hình (tiêu biểu là màn hình Chi tiết Khóa học), giao diện đang xuất hiện đồng thời 2 sắc thái xanh:
1. **Xanh chàm / Xanh tím (`#3D5FC4` - Theme Primary):** Hiện diện ở gạch chỉ báo Tab bar, text active tab, và các biểu tượng chỉ số thông tin (*Sách, Sao, Học viên*).
2. **Xanh dương tươi / Cobalt (`#2563EB` - Tailwind Blue 600 / Action Blue):** Hiện diện ở nút *"Continue Learning"*, nút *"Tải tài liệu khóa học"*, chỉ số *"0%"* và thanh Progress bar.

Sự pha tạp này gây ra **lệch dải nhiệt độ màu** (Tone clash), làm giảm tính nhất quán thương hiệu và vi phạm nguyên tắc Design Tokens của Material 3.

```
       [HIỆN TẠI: 2 SẮC XANH]                        [MỤC TIÊU: 1 SẮC XANH HỌC THUẬT]
+------------------------------------+        +------------------------------------+
| [0%] [Button: #2563EB (Tươi)]      |        | [0%] [Button: #3D5FC4 (Chủ đạo)]   |
| [Tab Indicator: #3D5FC4 (Trầm)]    |  --->  | [Tab Indicator: #3D5FC4 (Chủ đạo)] |
| [Icon Stats: #3D5FC4 (Trầm)]       |        | [Icon Stats: #3D5FC4 (Chủ đạo)]    |
| [Bottom CTA: #2563EB (Tươi)]       |        | [Bottom CTA: #3D5FC4 (Chủ đạo)]    |
+------------------------------------+        +------------------------------------+
```

### 1.2. Mục tiêu
- **Quy về 1 sắc xanh duy nhất:** Chuyển đổi toàn bộ các phần tử đang dùng `#2563EB` (`cs.blue600`) sang hệ màu dựa trên **`#3D5FC4`** (`cs.primary`).
- **Xây dựng Tonal Hierarchy (Phân cấp sắc độ cùng tone):** Thay vì dùng màu xanh khác để làm nổi bật nút, ta sử dụng độ đậm nhạt và độ tương phản tự nhiên của dải màu `#3D5FC4` để phân cấp thị giác.
- **Chuẩn hóa Design Tokens:** Thay thế hoàn toàn mã màu hardcode hoặc extension rời rạc bằng các token chuẩn của Flutter Material 3 (`cs.primary`, `cs.primaryContainer`, `cs.onPrimaryContainer`).

---

## 2. Kiến trúc Dải màu Bổ trợ cho Sắc xanh Học thuật (#3D5FC4)

Để đảm bảo vừa đồng nhất màu vừa giữ được sự phân cấp thị giác rõ ràng, hệ màu bổ trợ (Tonal Palette) được quy chuẩn như sau:

| Token / Thành phần | Mã màu / Giá trị | Ứng dụng cụ thể trong UI | Cảm nhận thị giác |
|---|---|---|---|
| **Primary Main (Chủ đạo)** | **`#3D5FC4`** (`cs.primary`) | • Nút CTA chính (`FilledButton`).<br>• Gạch chỉ báo Active Tab.<br>• Progress Bar & tỷ lệ % hoàn thành.<br>• Biểu tượng chỉ số & Key headers. | Đằm thắm, học thuật, đáng tin cậy. |
| **Primary Container (Nền nhạt)** | **`#EDF1FF`** (`cs.primaryContainer`) | • Nền thẻ tóm tắt / Goal chips.<br>• Nền avatar placeholder giảng viên.<br>• Nền badge trạng thái nhẹ. | Tươi sáng, êm dịu, không chói mắt. |
| **On Primary Container** | **`#17327F`** (`cs.onPrimaryContainer`) | • Text bên trong badge / chip nền nhạt.<br>• Tiêu đề phụ cần độ tương phản cao. | Rõ ràng, dễ đọc (Chuẩn WCAG AAA). |
| **Primary Dark (Gradient Partner)** | **`#2A48A5`** (Darker Indigo) | • Màu kết thúc của Gradient banner trên `CourseProgressCard` (từ `#3D5FC4` đến `#2A48A5`). | Chiều sâu không gian cao cấp. |
| **Tonal Tint (Surface Accent)** | `cs.primary.withValues(alpha: 0.08)` | • Viền active, highlight nền nhẹ. | Tinh tế, hiện đại. |

---

## 3. Danh mục Rà soát & Chuyển đổi Cụ thể (Detailed Audit & Mapping)

### Nhóm 1: Màn hình Chi tiết Khóa học (`course_detail/`) - *Trọng tâm trực quan*
*Tệp ảnh hưởng: [`course_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/course_detail_screen.dart), [`course_progress_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_progress_card.dart), [`course_enrollment_bar.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_enrollment_bar.dart), [`course_hero.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_hero.dart), [`course_instructor_tab.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_instructor_tab.dart)*

1. **[`course_enrollment_bar.dart:60`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_enrollment_bar.dart#L60):**
   - *Hiện tại:* `backgroundColor: cs.blue600` (`#2563EB`)
   - *Chuyển thành:* `backgroundColor: cs.primary` (`#3D5FC4`)
2. **[`course_progress_card.dart:252`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_progress_card.dart#L252):**
   - *Hiện tại:* Nút *"Continue Learning"* dùng `backgroundColor: cs.blue600`
   - *Chuyển thành:* `backgroundColor: cs.primary` (`#3D5FC4`)
3. **[`course_progress_card.dart:218, 231`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_progress_card.dart#L218-L231):**
   - *Hiện tại:* Text `"0%"` và `LinearProgressIndicator` dùng `cs.blue600`
   - *Chuyển thành:* `cs.primary` (`#3D5FC4`)
4. **[`course_progress_card.dart:36-41`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_progress_card.dart#L36-L41):**
   - *Hiện tại:* Gradient card chưa bắt đầu dùng `[Color(0xFF2563EB), Color(0xFF1D4ED8)]`
   - *Chuyển thành:* `[const Color(0xFF3D5FC4), const Color(0xFF2A48A5)]`
5. **[`course_hero.dart:125`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_hero.dart#L125) & [`course_instructor_tab.dart:48`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_instructor_tab.dart#L48):**
   - *Hiện tại:* Avatar nền xanh nhạt hardcode `Color(0xFFEFF6FF)`
   - *Chuyển thành:* `cs.primaryContainer` (`#EDF1FF`)

---

### Nhóm 2: Màn hình Chi tiết Bài học (`lesson_detail/`)
*Tệp ảnh hưởng: [`lesson_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/lesson_detail_screen.dart), [`lesson_bottom_bar.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_bottom_bar.dart), [`lesson_documents_section.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_documents_section.dart), [`lesson_notes_section.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_notes_section.dart)*

1. **[`lesson_detail_screen.dart:288-290`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/lesson_detail_screen.dart#L288-L290):**
   - TabBar labelColor & indicatorColor: `cs.blue600` -> `cs.primary`.
2. **[`lesson_bottom_bar.dart:134`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_bottom_bar.dart#L134):**
   - Nút *"Bài tiếp theo / Hoàn thành"*: `backgroundColor: cs.blue600` -> `cs.primary`.
3. **[`lesson_documents_section.dart:64`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_documents_section.dart#L64) & [`lesson_notes_section.dart:99`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_notes_section.dart#L99):**
   - Nút *"Tải về"* & *"Lưu ghi chú"*: `backgroundColor: cs.blue600` -> `cs.primary`.

---

### Nhóm 3: Màn hình Học tập & Trang chủ (`learning/`, `home/`)
*Tệp ảnh hưởng: [`learning_cards.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/learning_cards.dart), [`course_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/course_card.dart), [`recent_learning_item.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/recent_learning_item.dart), [`continue_learning_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/continue_learning_card.dart), [`home_daily_goals_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/home_daily_goals_card.dart)*

1. **[`learning_cards.dart:167, 248, 363`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/learning_cards.dart):**
   - Nút *"Tiếp tục học"*, tiến trình phần trăm: `cs.blue600` -> `cs.primary`.
2. **[`course_card.dart:27, 108`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/course_card.dart):**
   - Màu tiến trình khóa học đang học: `cs.blue600` -> `cs.primary`.
3. **[`continue_learning_card.dart:71, 163`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/continue_learning_card.dart):**
   - Thẻ tiếp tục học ở Home: chuyển icon và button sang `cs.primary`.
4. **[`home_daily_goals_card.dart:16`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/home_daily_goals_card.dart#L16):**
   - `final goalColor = cs.primary;` (thay cho `cs.blue600`).

---

### Nhóm 4: Đồng bộ Cấu hình Design System (`lib/theme/`)
*Tệp ảnh hưởng: [`app_colors.dart`](file:///C:/ForteX/mobile/lib/theme/app_colors.dart)*

1. Cập nhật `RoleColors.studentPrimary`:
   ```dart
   // Chuyển từ Color(0xFF2563EB) sang Color(0xFF3D5FC4)
   static const studentPrimary = Color(0xFF3D5FC4);
   static const studentSecondary = Color(0xFFEDF1FF);
   ```

---

## 4. Kế hoạch Triển khai Từng bước (Action Plan)

> [!IMPORTANT]  
> Các bước sẽ được thực hiện tuần tự, mỗi bước hoàn thành sẽ chạy test và commit bằng tiếng Việt có dấu đầy đủ theo cam kết.

### Bước 1: Cập nhật Design System Token trong `lib/theme/`
- Cập nhật `RoleColors.studentPrimary = Color(0xFF3D5FC4)` trong [`app_colors.dart`](file:///C:/ForteX/mobile/lib/theme/app_colors.dart).
- Đảm bảo token `primary` (`#3D5FC4`) và `primaryContainer` (`#EDF1FF`) đóng vai trò là nguồn màu duy nhất cho vai trò Student.
- **Commit:** `refactor(theme): chuẩn hóa màu studentPrimary sang sắc xanh học thuật #3D5FC4`

---

### Bước 2: Đồng nhất sắc xanh tại màn hình Chi tiết Khóa học (`course_detail/`)
- Thay thế triệt để `cs.blue600` và `Color(0xFF2563EB)` trong:
  - [`course_enrollment_bar.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_enrollment_bar.dart)
  - [`course_progress_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_progress_card.dart)
  - [`course_hero.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_hero.dart)
  - [`course_instructor_tab.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_instructor_tab.dart)
- Cập nhật gradient sang tone `#3D5FC4` -> `#2A48A5`.
- **Commit:** `fix(student): đồng nhất sắc xanh học thuật #3D5FC4 trên màn hình chi tiết khóa học`

---

### Bước 3: Đồng nhất sắc xanh tại màn hình Chi tiết Bài học (`lesson_detail/`)
- Chuẩn hóa các nút CTA, TabBar indicator, nút Tải tài liệu, Lưu ghi chú trong:
  - [`lesson_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/lesson_detail_screen.dart)
  - [`lesson_bottom_bar.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_bottom_bar.dart)
  - [`lesson_documents_section.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_documents_section.dart)
  - [`lesson_notes_section.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/lesson_detail/widgets/lesson_notes_section.dart)
- **Commit:** `fix(student): chuẩn hóa sắc xanh học thuật trong luồng chi tiết bài học`

---

### Bước 4: Đồng nhất sắc xanh trong Tab Học tập & Thẻ Khóa học (`learning/`)
- Cập nhật `cs.primary` cho các thanh tiến trình, nút *"Tiếp tục học"*, icon thẻ học trong:
  - [`learning_cards.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/learning_cards.dart)
  - [`course_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/course_card.dart)
  - [`recent_learning_item.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/recent_learning_item.dart)
  - [`section_widgets.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/section_widgets.dart)
- **Commit:** `fix(student): đồng nhất màu tiến trình và nút học tập sang sắc xanh #3D5FC4`

---

### Bước 5: Đồng nhất sắc xanh trên Trang chủ Học viên (`home/`)
- Cập nhật các widget trên Home screen:
  - [`continue_learning_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/continue_learning_card.dart)
  - [`home_daily_goals_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/home_daily_goals_card.dart)
  - [`schedule_timeline.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/schedule_timeline.dart)
  - [`weekly_achievement_card.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/home/widgets/weekly_achievement_card.dart)
- **Commit:** `fix(student): chuẩn hóa sắc xanh đồng nhất trên trang chủ học viên`

---

### Bước 6: Kiểm thử Toàn diện & Nghiệm thu Trực quan (Verification)
- Chạy toàn bộ test suite `flutter test test/features/student/` để đảm bảo 100% tests pass.
- Chạy `flutter analyze` kiểm tra tính toàn vẹn cú pháp và tokens.
- So sánh trực quan giao diện màn hình Chi tiết khóa học để xác nhận:
  - Nút *"Continue Learning"* và nút *"Tải tài liệu khóa học"* hòa hợp 100% với gạch Tab bar và các icon thống kê.
  - Không còn tồn tại bất kỳ pixel nào mang sắc xanh rực `#2563EB`.

---

## 5. Kết luận
Kế hoạch trên chuyển đổi có hệ thống toàn bộ module Student về phong cách **học thuật, chuyên nghiệp, đằm tính (`#3D5FC4`)**, giải quyết triệt để vấn đề lệch tone thị giác và nâng tầm đẳng cấp nhận diện của ForteX.
