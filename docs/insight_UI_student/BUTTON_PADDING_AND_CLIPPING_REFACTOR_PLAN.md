# Kế hoạch Rà soát & Chuẩn hóa Toàn diện Lỗi Padding / Cắt xén Button trong Module Student

> **Tài liệu tham chiếu:** `mobile/docs/insight_UI_student/BUTTON_PADDING_AND_CLIPPING_REFACTOR_PLAN.md`  
> **Phiên bản:** 1.0  
> **Trạng thái:** Chờ phê duyệt (DRAFT - Không sửa code ở bước này)  
> **Phạm vi:** Toàn bộ thành phần Button (`FilledButton`, `OutlinedButton`, `ElevatedButton`, `TextButton`) trong `lib/features/student/`

---

## 1. Phân tích Nguyên nhân Gốc rễ (Root Cause Analysis)

### 1.1. Hiện tượng lỗi từ hình ảnh thực tế
Trong màn hình chi tiết giảng viên ([`instructor_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/instructor_detail_screen.dart#L502-L513)), nút CTA ở Bottom Bar **"Nhắn tin cho giảng viên"** gặp phải các khuyết tật hiển thị nghiêm trọng:
1. **Xén góc chữ (Text Clipping):** Chữ cái cuối cùng `"n"` trong từ *"viên"* bị góc bo tròn (`BorderRadius.circular(12)`) cắt xém một phần.
2. **Dính mép viền (Icon Border Hugging):** Biểu tượng tin nhắn ở bên trái dính sát mép cong bên trái của nút mà không có bất kỳ khoảng hở an toàn (safe margin) nào.
3. **Co cụm kích thước (Wrap-content thay vì Full Width):** Là nút hành động chính (Primary CTA) duy nhất ở thanh dưới cùng (Bottom Bar) nhưng không chiếm trọn chiều ngang màn hình, dẫn đến cảm giác chắp vá, mất cân đối công thái học di động.

```
+--------------------------------------------------------+
|  [Icon] Nhắn tin cho giảng viê[Xén]                   |  <- Bị xén do horizontal padding = 0
+--------------------------------------------------------+
```

### 1.2. Cơ chế sinh lỗi trong Flutter
Khi lập trình viên tùy biến style của Button trong Flutter qua `FilledButton.styleFrom()`:
```dart
// CODE GÂY LỖI:
style: FilledButton.styleFrom(
  padding: AppSpacing.paddingVerticalLg, // Hoặc EdgeInsets.symmetric(vertical: 14)
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
)
```
- Thuộc tính `padding` trong `styleFrom` sẽ **ghi đè hoàn toàn** cấu hình padding mặc định của Material 3 (vốn có `EdgeInsets.symmetric(horizontal: 24, vertical: 0)` đối với Button thường hoặc `horizontal: 16` đối với Button có Icon).
- Việc chỉ truyền `vertical:` (hoặc dùng token `AppSpacing.paddingVerticalLg = EdgeInsets.symmetric(vertical: 16)`) đồng nghĩa với việc gán **`horizontal = 0`**.
- Với `horizontal = 0`, nội dung bên trong (`Row` gồm `Icon` và `Text`) sẽ tràn sát tận 2 biên ngoài của Button. Khi Button có bán kính bo góc `BorderRadius` (từ 8dp, 12dp đến pill 999dp), vùng bo góc sẽ trực tiếp ăn sâu vào pixel hiển thị của icon và chữ cái ngoài cùng.

---

## 2. Kết quả Rà soát Toàn diện trong Toàn bộ Module Student

Đã tiến hành rà soát tự động kết hợp thủ công 100% các tệp giao diện trong `lib/features/student/` gồm:
- Màn hình chính: `home/`, `learning/`, `schedule/`, `achievement/`, `portfolio/`, `profile/`, `bookmark/`, `notification/`.
- Toàn bộ các Dialog và Bottom Sheet trong module Student.

### 2.1. Đánh giá tổng quan
- Các nút trong `home/`, `achievement/`, `schedule/`, `profile/`, `bookmark/`, `notification/` và các Dialog (`portfolio/dialogs/`) đều sử dụng padding mặc định của Material 3 (không ghi đè `padding`), nên đều hiển thị an toàn và không bị lỗi xén chữ.
- **Tất cả các vị trí mắc lỗi đều tập trung trong luồng `learning/`**, xuất phát từ việc tùy biến padding cục bộ bằng `padding: EdgeInsets.symmetric(vertical: ...)` hoặc `padding: AppSpacing.paddingVerticalLg`.

### 2.2. Danh sách chi tiết 6 vị trí xuất hiện lỗi

| STT | Tệp tin & Dòng | Widget / Label | Code hiện tại | Vấn đề cụ thể |
|---|---|---|---|---|
| **1** | [`instructor_detail_screen.dart:502-513`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/instructor_detail_screen.dart#L502-L513) | `FilledButton.icon`<br>"Nhắn tin cho giảng viên" | `padding: AppSpacing.paddingVerticalLg` | `horizontal: 0`, không full-width; icon dính mép trái, chữ "n" bị chém góc phải. |
| **2** | [`course_instructor_tab.dart:101-110`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_instructor_tab.dart#L101-L110) | `FilledButton.tonal`<br>"Xem trang giảng viên" | `padding: const EdgeInsets.symmetric(vertical: 14)`, `AppRadius.full` | `horizontal: 0` trên nút viên thuốc (Pill Shape). Hai đầu bán nguyệt lấn sâu cắt xén cả chữ "X" và chữ "n". |
| **3** | [`course_enrollment_bar.dart:52-67`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_enrollment_bar.dart#L52-L67) | `FilledButton.icon`<br>"Tải tài liệu khóa học" | `padding: const EdgeInsets.symmetric(vertical: 14)` | `horizontal: 0`. Nằm trong Bottom Bar; trên màn hình nhỏ hoặc font lớn sẽ chạm sát biên bo góc. |
| **4** | [`quiz_result_screen.dart:257-293`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/quiz_result_screen.dart#L257-L293) | `OutlinedButton.icon`<br>"Quay về bài học"<br>& `FilledButton.icon`<br>"Làm lại bài kiểm tra" | `padding: const EdgeInsets.symmetric(vertical: 14)` (Cả 2 nút) | Cả 2 nút nằm trong `Row` (`Expanded`), chiều ngang bị chia đôi (~160dp). Với `horizontal: 0`, icon và text dài bị ép sát viền bo góc 12dp. |
| **5** | [`quiz_error_view.dart:117-128`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/quiz/quiz_error_view.dart#L117-L128) | `FilledButton.icon`<br>"Quay lại bài học" | `padding: AppSpacing.paddingVerticalLg` | `horizontal: 0`. Mặc dù có `SizedBox(width: double.infinity)` nhưng thiếu padding ngang an toàn. |
| **6** | [`learning_cards.dart:243-257`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/learning_cards.dart#L243-L257) | `FilledButton.icon`<br>"Tiếp tục học" | `padding: const EdgeInsets.symmetric(vertical: 12)` | `horizontal: 0`. Nút CTA trong card khóa học bị ép sát viền, thiếu khoảng đệm hai bên. |

---

## 3. Quy chuẩn Thiết kế Nút (Design Standardization Rules)

Để ngăn ngừa triệt để lỗi này trong tương lai, toàn bộ codebase Student phải tuân thủ nghiêm ngặt các quy tắc sau:

### Quy tắc 1: CẤM tuyệt đối `padding` chỉ có `vertical` trong Button
- ❌ **Cấm:** Không bao giờ truyền `EdgeInsets.symmetric(vertical: ...)` hoặc `AppSpacing.paddingVertical*` độc lập vào `styleFrom` của bất kỳ Button nào (`FilledButton`, `OutlinedButton`, `ElevatedButton`, `TextButton`).
- ✅ **Chuẩn:** Luôn khai báo đầy đủ cả `horizontal` và `vertical`.

### Quy tắc 2: Tiêu chuẩn Padding theo từng loại nút
1. **Nút Primary CTA ở Bottom Bar / Full Width:**
   - Kích thước: `minimumSize: const Size.fromHeight(48)` hoặc bọc `SizedBox(width: double.infinity, child: ...)`
   - Padding nội bộ: `padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)`
   - Đảm bảo vùng bấm công thái học tối thiểu 48dp theo tiêu chuẩn Apple HIG & Material 3.
2. **Nút hình viên thuốc (Pill / Capsule Shape - `AppRadius.full`):**
   - Padding ngang tối thiểu: **24dp** (`horizontal: 24, vertical: 14` hoặc `horizontal: 20, vertical: 12`).
   - Khoảng đệm 20–24dp là bắt buộc để nội dung không bị phần bán nguyệt ở hai đầu bo lấn vào.
3. **Cụm 2 nút hành động song song (Side-by-side trong Row / Expanded):**
   - Padding nội bộ: `padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)` hoặc `(horizontal: 16, vertical: 12)`.
   - Giúp vừa vặn trên các màn hình nhỏ (360dp–375dp) mà vẫn giữ được khoảng đệm an toàn khỏi góc bo.
4. **Nút Action trong Card (Compact CTA):**
   - Padding nội bộ: `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)` hoặc `(horizontal: 16, vertical: 12)`.

---

## 4. Kế hoạch Triển khai Chi tiết Từng bước (Action Plan)

> [!NOTE]  
> Toàn bộ logic Bloc, navigation và cấu trúc dữ liệu được giữ nguyên 100%. Mỗi bước sau khi hoàn thành sẽ chạy test và commit bằng tiếng Việt có dấu.

### Bước 1: Chuẩn hóa Bottom Bar trong [`instructor_detail_screen.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/instructor_detail_screen.dart#L502-L513)
- **Mục tiêu:** Sửa nút "Nhắn tin cho giảng viên" hiển thị full-width chuẩn CTA và padding an toàn.
- **Giải pháp:**
  - Bọc nút trong `SizedBox(width: double.infinity, child: FilledButton.icon(...))`
  - Cập nhật style:
    ```dart
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    ```
- **Commit:** `fix(student): chuẩn hóa padding và full-width nút nhắn tin giảng viên`

---

### Bước 2: Chuẩn hóa nút Pill trong [`course_instructor_tab.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_instructor_tab.dart#L101-L110)
- **Mục tiêu:** Khắc phục lỗi hai đầu bán nguyệt cắt vào chữ "X" và "n" của nút "Xem trang giảng viên".
- **Giải pháp:**
  - Thiết lập full-width cho CTA hoặc thêm padding ngang an toàn:
    ```dart
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
    ),
    ```
- **Commit:** `fix(student): chuẩn hóa padding và kích thước nút xem trang giảng viên`

---

### Bước 3: Chuẩn hóa nút tải tài liệu trong [`course_enrollment_bar.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/course_detail/widgets/course_enrollment_bar.dart#L52-L67)
- **Mục tiêu:** Thêm horizontal padding an toàn cho nút "Tải tài liệu khóa học".
- **Giải pháp:**
  - Cập nhật style:
    ```dart
    style: FilledButton.styleFrom(
      backgroundColor: cs.blue600,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    ```
- **Commit:** `fix(student): thêm padding ngang an toàn cho nút tải tài liệu khóa học`

---

### Bước 4: Chuẩn hóa cụm nút kết quả trong [`quiz_result_screen.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/quiz_result_screen.dart#L257-L293)
- **Mục tiêu:** Sửa cả 2 nút "Quay về bài học" và "Làm lại bài kiểm tra" tránh chèn ép icon/text.
- **Giải pháp:**
  - Cập nhật style cho cả `OutlinedButton` và `FilledButton`:
    ```dart
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ```
- **Commit:** `fix(student): chuẩn hóa padding cụm nút hành động kết quả bài kiểm tra`

---

### Bước 5: Chuẩn hóa nút quay lại trong [`quiz_error_view.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/quiz/quiz_error_view.dart#L117-L128)
- **Mục tiêu:** Sửa nút "Quay lại bài học" có padding ngang chuẩn.
- **Giải pháp:**
  - Đổi `AppSpacing.paddingVerticalLg` thành `const EdgeInsets.symmetric(horizontal: 24, vertical: 14)`.
- **Commit:** `fix(student): chuẩn hóa padding nút quay lại trong quiz error view`

---

### Bước 6: Chuẩn hóa nút thẻ khóa học trong [`learning_cards.dart`](file:///C:/ForteX/mobile/lib/features/student/presentation/learning/widgets/learning_cards.dart#L243-L257)
- **Mục tiêu:** Cung cấp padding ngang 16dp cho nút "Tiếp tục học".
- **Giải pháp:**
  - Đổi `padding: const EdgeInsets.symmetric(vertical: 12)` thành:
    ```dart
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ```
- **Commit:** `fix(student): bổ sung padding ngang cho nút tiếp tục học trên thẻ khóa học`

---

### Bước 7: Kiểm thử Toàn diện & Hậu kiểm (Verification & Analysis)
- **Kiểm thử tự động:**
  - Chạy `flutter test test/features/student/` đảm bảo 100% (33/33 tests) đều pass.
  - Chạy `flutter analyze` để đảm bảo không có cảnh báo/lỗi linting.
- **Kiểm tra trực quan (Visual Checklist):**
  - Mọi nút đều có khoảng đệm tối thiểu ≥ 12dp giữa mép ngoài và icon/chữ.
  - Không có hiện tượng chữ bị vát góc bởi `BorderRadius`.
  - Các nút Bottom Bar ôm trọn chiều rộng đều đặn, cân đối và dễ thao tác ngón tay cái.

---

## 5. Kết luận & Đề xuất Bước tiếp theo
Kế hoạch trên khắc phục triệt để và toàn diện lỗi cắt xén button padding trên toàn bộ module Student theo đúng tiêu chuẩn Design System.  
Sau khi nhận được phản hồi duyệt kế hoạch từ người dùng, quá trình refactoring mã nguồn sẽ được bắt đầu theo thứ tự từng bước từ Bước 1 đến Bước 7.
