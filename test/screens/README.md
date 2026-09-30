# Test màn hình

Chạy từ thư mục `40Study`:

```sh
flutter test test/screens/all_screens_test.dart
flutter test
```

`all_screens_test.dart` chứa 118 test, bao phủ 48 màn hình và shell hiện có:

- Mở và hủy từng màn hình ở 390×844 và 360×800, kiểm tra lỗi dựng giao diện, tràn bố cục và giải phóng timer/controller.
- Kiểm tra danh sách fixture với các lớp Screen/Shell/SplashView trong `lib/features`; thêm màn hình mới mà thiếu fixture sẽ làm test thất bại.
- Kiểm tra biểu mẫu xác thực rỗng không gọi repository; gửi email quên mật khẩu và mở đúng màn hình OTP.
- Kiểm tra điều hướng cả năm tab học sinh và phụ huynh.
- Kiểm tra tìm kiếm, xóa tìm kiếm, lỗi thông báo và thử lại.
- Kiểm tra hiển thị lỗi repository ở Home, Learning, AllCourses, ExploreCourses, Schedule, Achievement, CourseDetail, LessonDetail và Quiz.
- Kiểm tra lưu chế độ tối; quiz chỉ cho nộp khi chọn đáp án và mở kết quả; thêm, hoàn thành và xóa mục tiêu ngày.

Test dùng Bloc thật, repository giả lập, SharedPreferences trong bộ nhớ, theme ứng dụng và font Roboto. Không cần tài khoản, backend hoặc thiết bị để chạy.

Đây là test widget, chưa thay thế kiểm thử tích hợp với API thật, video, image picker hoặc OAuth. Asset gấu Rive được giữ ở trạng thái chờ tải vì môi trường widget test không có thư viện native của Rive; hoạt ảnh cần kiểm tra trên thiết bị. Hai kích thước được kiểm tra ở theme sáng, ngôn ngữ Việt và cỡ chữ mặc định; chưa phải kiểm thử mọi theme, ngôn ngữ và cỡ chữ.

Để thêm màn hình, bổ sung widget vào `_screens`, truyền tham số hợp lệ và khai báo stub cần thiết trong `_setUp`. Thêm test tương tác trong `_interactionTests` khi màn hình có hành vi cần xác nhận.
