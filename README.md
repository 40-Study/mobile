# 40Study

Ứng dụng học trực tuyến viết bằng Flutter, có 3 vai trò: **Học sinh**, **Phụ huynh** và **Giáo viên**.

## Tính năng chính

**Học sinh** (`lib/features/student`)
- Trang chủ, tiếp tục học, khám phá và tìm kiếm khóa học (có gợi ý và từ khóa thịnh hành)
- Chi tiết khóa học / bài học, video bài giảng, làm quiz và xem kết quả
- Lịch học, mục tiêu hằng ngày, thông báo, bookmark
- Thành tích, chứng chỉ, bản đồ cấp bậc, portfolio
- Hồ sơ, cài đặt, trung tâm trợ giúp

**Phụ huynh** (`lib/features/parent`)
- Quản lý con, theo dõi tiến độ, bài tập về nhà, insight học tập
- Lịch học, chi tiết buổi học, khóa học gợi ý
- Thanh toán: checkout, lịch sử, hóa đơn

**Giáo viên** (`lib/features/teacher`)
- Quản lý khóa học: outline, nội dung bài học, soạn quiz / bài tập
- Lớp học: giao bài, sổ điểm, cột điểm, điểm danh, lịch dạy
- Livestream (LiveKit), upload video, thảo luận, tin nhắn, cuộc thi
- Thu nhập, hồ sơ chuyên môn, nhắc việc

**Chung**: onboarding, đăng ký / đăng nhập theo vai trò, OTP, quên / đổi mật khẩu, bảo mật tài khoản.

## Công nghệ

| Hạng mục | Thư viện |
|---|---|
| State management | `flutter_bloc`, `provider` |
| DI | `get_it` + `injectable` |
| Network | `dio` + `retrofit`, `talker_dio_logger` |
| Model / codegen | `freezed`, `json_serializable`, `build_runner`, `flutter_gen` |
| Đa ngôn ngữ | `intl`, `intl_utils` (`lib/l10n`) |
| Media | `video_player`, `chewie`, `rive`, `livekit_client` |
| Test | `flutter_test`, `bloc_test`, `mocktail`, `mockito`, `integration_test` |

## Cấu trúc thư mục

```
lib/
├── app/            # App widget, localization
├── bloc/           # Bloc dùng chung (init, theme)
├── config/         # Environment, build type, AppConfig
├── core/           # error, logger, network (interceptor, error mapper), utils
├── data/ repository/
├── di/             # Cấu hình get_it / injectable
├── features/       # auth, onboarding, student, parent, teacher, course, account
│   └── <feature>/  # bloc / data / repository / presentation
├── l10n/ generated/
├── routes/         # router.dart
├── theme/ widgets/ utils/ constants/
├── app_runner.dart
└── main.dart       # Chọn env qua --dart-define=ENV
```

## Bắt đầu

Yêu cầu: Flutter `>=3.19.2`, Dart SDK `>=3.8.0`.

```bash
# 1. Tạo file env từ template (các file .env.* đã bị gitignore)
cp .env.example .env.dev
cp .env.example .env.qa
cp .env.example .env.prod

# 2. Cài dependencies và sinh code
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 3. Chạy app
make runDev
```

Biến môi trường (`.env.*`):

| Biến | Ý nghĩa |
|---|---|
| `BASE_URL` | URL của backend API |
| `FORCE_SHOW_ONBOARDING` | `true` để luôn hiện onboarding |

## Môi trường & flavor

App dùng một `main.dart` duy nhất, môi trường chọn qua `--dart-define=ENV`:

| ENV | Build type | File env | Lệnh |
|---|---|---|---|
| `dev` (mặc định) | debug | `.env.dev` | `make runDev` |
| `qa` | qa | `.env.qa` | `make runQa` |
| `prod` | release | `.env.prod` | `make runProd` |

Android có các flavor `dev`, `qa`, `prod`.

Dữ liệu mẫu (preview/mock cho phụ huynh, giáo viên, khóa học) chỉ bật ở `ENV=dev` và bản không phải release (`--release` luôn tắt). Bản `qa` và `prod` dùng API thật; cần demo thì thêm `--dart-define=PREVIEW_DATA=true`.

## Lệnh Makefile

| Lệnh | Mô tả |
|---|---|
| `make rebuild` | clean, pub get, build_runner, fluttergen |
| `make gen` | Chạy build_runner |
| `make genAll` | build_runner + localization + fluttergen |
| `make localize` | Chỉ sinh localization |
| `make check` | `dart analyze` + `flutter analyze` |
| `make test` | Unit / widget test |
| `make test_coverage` | Test kèm coverage (lcov) |
| `make integration_test` | Integration test |
| `make performance_smoke` | Chạy thử performance test |
| `make performance_test DEVICE=<id>` | Performance test ở profile mode (thiết bị thật) |
| `make performance_screens DEVICE=<id> [PROFILE=1] [SCREEN=...]` | Đo performance từng màn hình |
| `make apk` / `make debug_apk` | Build APK release / debug |

## CI/CD

GitHub Actions (`.github/workflows`):
- `ci.yml`: build_runner, `flutter analyze`, `flutter test --coverage`, upload Codecov / Codacy, integration test trên Android emulator
- `release.yml`: ký keystore, build APK và App Bundle release
- `discord-notify.yml`: gửi thông báo Discord

## Tài liệu

- `docs/APPLICATION_FLOWS.md` — các luồng chính để tích hợp API
- `docs/API_DOCUMENTATION.md`, `FULL_API_DOCUMENTATION.md` — tài liệu API
- `docs/backend-api-requirements.md`, `docs/api-specs/` — yêu cầu API cho backend
- `Design.md`, `PRODUCT.md` — định hướng thiết kế và sản phẩm
- `PERMISSION_BASED_UI.md` — UI theo phân quyền
- `postman_test/` — collection Postman

## License

MIT — xem [LICENSE](LICENSE).
