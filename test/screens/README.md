# Kiểm tra màn hình mobile

Chạy trong thư mục `40Study`:

```sh
flutter test test/screens/all_screens_test.dart
flutter test
make performance_screens DEVICE=<device-id>
make performance_screens DEVICE=<physical-device-id> PROFILE=1
```

Widget suite kiểm tra mọi lớp Screen/Shell/SplashView trong `lib/features` có fixture. Mỗi màn được mở và hủy ở 390×844 và 360×800, bắt lỗi dựng giao diện, tràn bố cục và timer/controller chưa được giải phóng. Có thêm kiểm tra tương tác mục tiêu ngày: từ chối nội dung rỗng, thêm, hoàn thành và xóa.

Fixture dùng chung ở `test/support/screen_fixtures.dart`: Bloc thật, repository giả lập, SharedPreferences trong bộ nhớ, theme và font của ứng dụng. Widget test tắt hoạt ảnh Rive vì không có runtime native. Thêm màn hình mới vào `createScreenFixtures`; kiểm tra inventory sẽ thất bại nếu thiếu fixture.

## Hiệu năng toàn bộ màn hình

`integration_test/all_screens_performance_test.dart` chạy trên thiết bị/simulator. Đo FrameTiming thật khi mở màn qua route có hoạt ảnh và cuộn các vùng có thể cuộn theo hai chiều. Rive được bật. Mọi màn được đo ít nhất một lần; các màn trong `variableDataScreens` có thêm dữ liệu thưa (1 mục) và lớn (100 mục mỗi danh sách). Số con được giới hạn ở 5, hồ sơ ở 3 và điểm biểu đồ ở 12. Màn dùng nội dung cố định được ghi là `fixed`.

Báo cáo JSON và Markdown được lưu vào `build/screens_performance_report.*`, gồm P90 build/raster, khung hình chậm nhất, số khung vượt ngân sách, lỗi UI và các trường hợp thiếu dữ liệu đo. Có thể chạy lại một màn:

```sh
make performance_screens DEVICE=<id> SCREEN=HomeScreen
```

Debug là phép kiểm tra thu số liệu và phát hiện màn đáng xem lại. Profile/release yêu cầu ít nhất 15 mẫu mỗi pha, P90 build/raster ≤ 16 ms và tỷ lệ khung vượt ngân sách ≤ 5% mỗi pha. `PROFILE=1` cần điện thoại thật.

Dữ liệu được đưa vào từ repository trong bộ nhớ; provider được dựng trước khi đo route. Bài đo phản ánh chi phí UI, chưa đo độ trễ backend, cold startup toàn ứng dụng, video, OAuth, image picker hoặc giải mã ảnh mạng dung lượng lớn. Chạy ở kích thước thật của thiết bị, theme sáng, tiếng Việt và cỡ chữ mặc định.
