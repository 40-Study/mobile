# Xem thử giao diện Teacher với dữ liệu mẫu

Chạy từ thư mục `40Study`:

```sh
flutter run --flavor dev
```

Dữ liệu mẫu tạm thời bật sẵn trong bản dev. Đăng nhập bằng tài khoản có role Teacher rồi chuyển sang role này như bình thường. Nếu app đang chạy, cần hot restart để khởi tạo lại TeacherShell; hot reload giữ API instance cũ.

Preview mặc định bật khi ENV là dev và không phải release. Dùng `--dart-define=TEACHER_UI_PREVIEW=false` để trở lại API thật. Release luôn tắt preview. Các tab nghiệp vụ hiển thị nhãn **Dữ liệu mẫu · Chỉ xem giao diện**.

Dữ liệu gồm ba lớp lập trình, ba buổi hôm nay (hoàn thành/đang diễn ra/sắp tới), ba khóa học (đã xuất bản/nháp/chờ duyệt), học viên, điểm và ví cá nhân. Ngày mẫu lấy theo ngày chạy ứng dụng. Ảnh khóa Python dùng asset hiện có của dự án.

Các thao tác ghi trong API nghiệp vụ Teacher của preview trả thông báo không lưu. Endpoint chưa có dữ liệu mẫu báo rõ thay vì gọi máy chủ thật. Preview không đổi phiên đăng nhập hoặc nơi làm việc đã lưu. Tab Tài khoản vẫn là phần dùng chung với các role, sử dụng tài khoản đã đăng nhập.

## Kiểm chứng

- `preview_api_test.dart`: đọc qua logic lịch thật, lọc khóa học, chặn ghi và không fallback mạng.
- `teacher_visual_test.dart`: kiểm tra preview điện thoại/tablet cùng các kiểm tra sáng/tối/chữ lớn sẵn có.
- Native harness nhận thêm `--dart-define=TEACHER_UI_PREVIEW=true` để chụp cùng dữ liệu mẫu này.
