# Chạy Teacher với API dev hoặc dữ liệu mẫu

Bản dev mặc định gọi API thật. Từ thư mục `backend`, dùng
`go run ./cmd/seed -env=dev -mode=full` để nạp dữ liệu vào PostgreSQL dev cục bộ.
Đăng nhập ở vai trò Teacher bằng tài khoản seed `teacher1@demo.com`.

```sh
flutter run --flavor dev --dart-define=ENV=dev
```

Trong bản dev, Xin nghỉ dùng dữ liệu trong phiên khi API báo chưa hỗ trợ.
Menu Lịch có **Thử gửi bổ sung giờ dạy** để xem riêng chức năng chưa có API.
Hai màn này ghi rõ dữ liệu mẫu và không cập nhật lịch hoặc gửi đến trung tâm.

Để xem toàn bộ giao diện bằng dữ liệu mẫu, chạy từ thư mục `mobile`:

```sh
flutter run --flavor dev --dart-define=ENV=dev --dart-define=TEACHER_UI_PREVIEW=true
```

Khởi động lại app với cấu hình mới khi đổi chế độ. Release luôn tắt preview.
Các tab nghiệp vụ của chế độ preview hiển thị **Dữ liệu mẫu · Chỉ xem giao diện**.

Dữ liệu gồm ba lớp lập trình, ba buổi hôm nay (hoàn thành/đang diễn ra/sắp tới), ba khóa học (đã xuất bản/nháp/chờ duyệt), học viên, điểm và ví cá nhân. Ngày mẫu lấy theo ngày chạy ứng dụng. Ảnh khóa Python dùng asset hiện có của dự án.

Các thao tác ghi trong API nghiệp vụ Teacher của preview trả thông báo không lưu. Endpoint chưa có dữ liệu mẫu báo rõ thay vì gọi máy chủ thật. Preview không đổi phiên đăng nhập hoặc nơi làm việc đã lưu. Tab Tài khoản vẫn là phần dùng chung với các role, sử dụng tài khoản đã đăng nhập.

## Kiểm chứng

- `preview_api_test.dart`: đọc qua logic lịch thật, lọc khóa học, chặn ghi và không fallback mạng.
- `teacher_visual_test.dart`: kiểm tra preview điện thoại/tablet cùng các kiểm tra sáng/tối/chữ lớn sẵn có.
- Native harness nhận thêm `--dart-define=TEACHER_UI_PREVIEW=true` để chụp cùng dữ liệu mẫu này.
