# INSIGHT & KẾ HOẠCH NÂNG CẤP UI STUDENT MOBILE

Tài liệu kế hoạch chi tiết cho 3 yêu cầu khắc phục lỗi UI Role Student đã được lập tại:
👉 [**STUDENT_UI_COURSE_CERT_DARKMODE_FIX_PLAN.md**](file:///C:/ForteX/mobile/docs/insight_UI_student/STUDENT_UI_COURSE_CERT_DARKMODE_FIX_PLAN.md)

---

## Tóm tắt 3 vấn đề & giải pháp:

### 1. Điều hướng khóa học của giảng viên
- **Nguyên nhân:**
  - `InstructorCoursesScreen` (dòng 475-485): `onTap` chỉ hiển thị `SnackBar` giả lập.
  - `InstructorCourseCard` (dùng trong `InstructorDetailScreen`): Thiếu thuộc tính `onTap` và `InkWell`.
- **Giải pháp:** Bổ sung `onTap` và kết nối điều hướng chuẩn `Navigator.push` đến `CourseDetailScreen` bọc trong `BlocProvider<CourseDetailBloc>`.

### 2. Card chứng chỉ thô & Bug không bấm lại được sau khi back
- **Nguyên nhân Bug:** Trong `CourseDetailScreen`, `listenWhen` chỉ kích hoạt khi `prev.certificate == null && curr.certificate != null`. Sau khi người dùng mở chứng chỉ và back về, `certificate` trong state đã khác null, nên lần bấm tiếp theo `listenWhen` trả về `false`, không trigger `listener` $\rightarrow$ nút bị đơ.
- **Giải pháp Bug:** Trong callback `onViewCertificate`, kiểm tra nếu `state.certificate != null` thì lập tức gọi `Navigator.push` mở `CertificateDetailScreen`.
- **Giải pháp Redesign:** Tái thiết kế Card chứng chỉ hoàn thành khóa học từ khối xanh mint thô cứng `#ECFDF5` sang Card tôn vinh thành tích (Milestone Celebration Card) 2 tầng, sử dụng Design Tokens `cs.surfaceContainerLowest` / `cs.surfaceContainerHigh` và `cs.secondary`, nút Pill hiện đại thích ứng 100% Light & Dark Mode.

### 3. Mất chữ / Không đổi màu chữ khi chuyển Dark Mode
- **Nguyên nhân:**
  - Tại `mobile/lib/theme/app_colors.dart` (`TogetherColorsX`), toàn bộ dải màu `slate*` (`slate900`, `slate800`, `slate700`, `slate500`) là các mã màu đen/xám cố định, không kiểm tra `brightness == Brightness.dark`.
  - Trên hầu hết màn hình (Header, Home, CourseCard...), text dùng `cs.slate900` (`#0F172A`) dẫn tới chữ đen hiển thị trên nền đen `#12151B` trong Dark Mode $\rightarrow$ mất chữ hoàn toàn.
  - Ngoài ra, một số thẻ dùng `Colors.white` làm nền cứng nhưng text con dùng theme M3 chuyển sang màu trắng $\rightarrow$ chữ trắng trên nền trắng.
- **Giải pháp:** Nâng cấp `TogetherColorsX` để tự động đảo dải màu `slate*` khi sang Dark Mode, đồng thời thay thế các container `Colors.white` cứng bằng `cs.surfaceContainerLowest` và text màu đen cứng bằng `cs.onSurface`.
