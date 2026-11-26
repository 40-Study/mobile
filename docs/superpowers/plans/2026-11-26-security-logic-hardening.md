# Security & Logic Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sửa các lỗi security / logic đã xác minh trong review (Claude + Codex, 2026-11-26) để bản prod không lộ token, không hiện dữ liệu giả và không báo thành công sai.

**Architecture:** Không đổi kiến trúc. Thêm một compile-time flag `kPreviewDataEnabled` để gom toàn bộ mock/preview về một chỗ; sửa tại tầng chung (interceptor, repository, bloc) thay vì vá từng màn hình. Mỗi task độc lập, có test riêng, commit riêng.

**Tech Stack:** Flutter ≥3.19.2, Dart ≥3.8, flutter_bloc 9, dio 5.9.2, get_it/injectable, mocktail, bloc_test.

**Spec:** Mục "Findings" ngay bên dưới (kết quả review, không có spec riêng).

## Findings (nguồn của plan)

| # | Mức | Vấn đề | Vị trí | Task |
|---|---|---|---|---|
| F1 | Critical | `TalkerDioLogger` log header `Authorization` + body (password) ở mọi build | `lib/di/di_network_module.dart:41-50` | 1 |
| F2 | Critical | `submitPayment` luôn trả thành công giả; `getPaymentSummary`/`getInvoiceDetail` mock hoàn toàn | `parent_payment_repository_impl.dart:137, 266, 278` | 3 |
| F3 | Critical | Video player gắn Bearer token cho mọi host chứa `api.` / `40study` | `lesson_video_player.dart:56-68` | 5 |
| F4 | Major | `enablePreviewFallback: true` cứng ở DI + 9 màn hình parent → prod hiện dữ liệu giả khi API lỗi | `di_repository_module.dart:82-117`, `parent/presentation/**` | 2 |
| F5 | Major | Lesson / CourseDetail bloc emit `Success` với mock khi API lỗi | `lesson_bloc.dart:53`, `course_detail_bloc.dart:81, 115` | 4 |
| F6 | Major | `LessonCompleted` vẫn set `isCompleted: true` khi server từ chối; clip fallback vẫn kích hoạt hoàn thành bài | `lesson_bloc.dart:80-92`, `lesson_video_player.dart:124, 164` | 4, 5 |
| F7 | Major | Retry sau refresh gọi `_dio.fetch` trong `QueuedInterceptor.onError` → treo nếu retry lỗi (dio issue #1612); nhiều 401 đồng thời refresh nhiều lần; public path so bằng `contains` | `auth_interceptor.dart:38, 60, 80-99` | 6 |
| F8 | Major | Access/refresh token lưu plaintext trong `SharedPreferences` | `auth_storage.dart:61-62` | 7 |
| F9 | Major | Logout không xóa bookmark, daily goals, last-accessed course → user sau trên cùng máy thấy dữ liệu user trước | `auth_repository_impl.dart:386-401, 547` | 8 |
| F10 | Major | Login: không khớp profile → lấy `profiles.first` (sai role); `user == null` → không emit gì (kẹt loading); role lạ → `StudentShell` | `auth_bloc.dart:37-91`, `main_screen.dart:23, 44` | 9 |
| F11 | Major | Release build dùng `--flavor dev` (applicationId `.dev`) | `Makefile:51`, `.github/workflows/release.yml` | Backlog |
| F12 | Minor | Khai báo location permission không dùng | `AndroidManifest.xml:15-16` | 10 |
| F13 | Minor | Bộ lọc kết quả quiz coi câu nhiều đáp án là đúng nếu chỉ *chứa* 1 đáp án đúng | `quiz_result_screen.dart:75-78, 326` | 11 |
| F14 | Critical | `checkPaymentStatus` luôn trả `success`; `getPaymentHistory` trả hóa đơn mẫu; màn payment nuốt lỗi rồi dựng overview `isAllPaid: true` | `parent_payment_repository_impl.dart:305, 324`, `parent_payment_screen.dart:87-90, 310` | 3 |
| F15 | Major | `FamilyInsightsRepositoryImpl` luôn trả `_sampleInsights()`, không đọc `enablePreviewFallback`; `sendEncouragement` báo thành công giả | `family_insights_repository_impl.dart:20, 40` | 2 |
| F16 | Major | `release.yml` không tạo `.env.*` (asset bắt buộc trong `pubspec.yaml:79`) và upload/release theo đường dẫn `dev` | `release.yml:61-62, 93` | Backlog |
| F17 | Major | Login log toàn bộ response thô (`Login raw data: $data`, có token) ở debug/QA | `auth_repository_impl.dart:108` | 1 |
| F18 | Major | Upload video chấp nhận signed URL `http` | `video_upload_controller.dart:90` | 13 |
| F19 | Minor | `_publicPaths` ghi `/api/system-roles`, `/api/auth/select-profile`; API thật là `/api/auth/system-roles`, `/api/auth/select-role` | `auth_interceptor.dart:22-31`, `auth_api_client.dart:38, 43` | 6 |
| F20 | Minor | Nút "Tải tất cả" tài liệu chỉ `Future.delayed` rồi đánh dấu đã tải | `lesson_documents_section.dart:143` | Backlog |

Đã kiểm tra và **bác bỏ**: quiz chấm điểm phía client (server chấm, `quiz_bloc.dart:166`); `BookmarkBloc` giữ dữ liệu sau logout (bloc tạo theo màn hình qua factory, `bookmark_screen.dart:15`); LiveKit token (lấy từ API join, `teacher_live_sessions_screen.dart:280`).

Ngoài scope plan này (xem "Backlog" cuối file): parent screens dùng `setState` + `diContainer` thay vì bloc, `ServerFailure(e.toString())` trong `StudentRepositoryImpl`, file >1000 dòng, `ListView` không builder, `LICENSE` của template.

## Global Constraints

- Máy dev phải có `flutter` trong PATH (hiện chưa có) và các file `.env.dev`, `.env.qa`, `.env.prod` copy từ `.env.example` — nếu thiếu, mọi lệnh `flutter test` đều fail.
- Sau khi sửa file có annotation injectable/freezed: chạy `dart run build_runner build --delete-conflicting-outputs`.
- Business logic (bloc, repository, `lib/config/preview_flags.dart`) không import `package:flutter/*` (rule `bloc.md` › Code Quality 4).
- Test: luôn có `group()` đặt tên theo class, tên test dùng "should" (rule `test.md`).
- Comment ngắn, English + Vietnamese (rule `comment-rule.md`).
- Commit message theo style repo: `fix(scope): mo ta khong dau`.
- Chỉ thêm 1 dependency mới: `flutter_secure_storage` (Task 7).

## Review Focus

1. Dev build vẫn phải xem được dữ liệu demo parent/teacher như trước → Task 2 test `getChildren should merge mock children when preview enabled`.
2. Nhiều request cùng bị 401 lúc token hết hạn (mở home load song song 3-4 API) → chỉ 1 lần refresh, tất cả request retry thành công → Task 6 test `should refresh once for concurrent 401s`.
3. User đã login từ bản cũ (token còn trong SharedPreferences) cập nhật app → không bị đăng xuất → Task 7 test `should migrate legacy token from prefs`.
4. Video URL từ CDN ngoài (S3, Cloudflare) vẫn phát được, chỉ không kèm token → Task 5 test `should not attach auth for other hosts`.
5. Checkout trên prod khi backend payment chưa có → hiện lỗi rõ ràng, không có transaction ID → Task 3 test `submitPayment should throw when preview disabled`.

---

### Task 1: Network logger chỉ chạy ở debug, không log header

**Files:**
- Modify: `lib/di/di_network_module.dart:41-50`

**Interfaces:** không đổi.

- [ ] **Step 1: Bọc `dio.interceptors.add(TalkerDioLogger(...))` trong `if (kDebugMode)`** (import `package:flutter/foundation.dart`), đổi `printRequestHeaders: false`, `printResponseHeaders: false`, thêm `printRequestData: false` để không log password khi login.

- [ ] **Step 2: `lib/features/auth/repository/auth_repository_impl.dart:108`** — xóa dòng `AppLogger.auth('Login raw data: $data')`; giữ dòng 110 (chỉ log `completed`, `hasToken`). Grep thêm `AppLogger.*toJson()\|raw` trong `lib/features/auth` (vd `auth_bloc.dart` log `activeProfile?.toJson()`) và bỏ các log chứa dữ liệu user thô.

  Không viết test: guard một dòng theo `kDebugMode` và xóa log, test chỉ kiểm tra hằng số của Flutter.

- [ ] **Step 3: Verify thủ công**

  Run: `flutter run --flavor prod --release --dart-define=ENV=prod`, login, xem `adb logcat | grep -iE "bearer|access_token|password"`
  Expected: không có dòng nào. Lặp lại với `make runDev`: không còn dòng `Login raw data`.

- [ ] **Step 4: Commit**

```bash
git add lib/di/di_network_module.dart lib/features/auth
git commit -m "fix(network): chi bat dio logger o debug, bo log du lieu login tho"
```

---

### Task 2: Gom preview/mock về một flag theo ENV

**Files:**
- Create: `lib/config/preview_flags.dart`
- Modify: `lib/di/di_repository_module.dart:82-117` (xóa 5 dòng `enablePreviewFallback: true`)
- Modify: default param trong `parent/repository/{family_insights,parent_home,parent_learning,parent_payment,parent_schedule}_repository_impl.dart` (dòng 8/13/19/14/13)
- Modify: `lib/features/parent/repository/family_insights_repository_impl.dart:20, 40` — thêm guard flag (hiện bỏ qua flag)
- Modify: xóa `enablePreviewFallback: true` trong 9 screen: `parent_class_detail_screen.dart:62`, `parent_course_detail_screen.dart:43`, `parent_homework_detail_screen.dart:44`, `parent_homework_screen.dart:54`, `parent_learning_insights_screen.dart:52`, `parent_progress_screen.dart:48`, `parent_recommended_courses_screen.dart:52`, `payment_history_screen.dart:45`, `parent_payment_screen.dart:64`
- Modify: `lib/features/teacher/data/teacher_preview_api.dart:10-16` dùng chung flag
- Test: `test/features/parent/repository/parent_payment_repository_impl_test.dart`

**Interfaces:**
- Produces: `const bool kPreviewDataEnabled` trong `lib/config/preview_flags.dart`. Giá trị: `bool.fromEnvironment('PREVIEW_DATA', defaultValue: String.fromEnvironment('ENV', defaultValue: 'dev') == 'dev')`. Pure Dart, không import Flutter. Ở bản release, `ENV=prod` nên flag là `false`. **`ENV=qa` cũng thành `false`** (QA test với API thật) — nếu QA cần demo thì chạy thêm `--dart-define=PREVIEW_DATA=true`; ghi chú điều này vào `README.md` mục "Môi trường & flavor".
- `FamilyInsightsRepositoryImpl`: khi `!enablePreviewFallback` → `getInsights` trả `const []`, `sendEncouragement` throw `UnsupportedError('Tính năng chưa khả dụng')` (chưa có API thật).
- Mọi `*RepositoryImpl` parent: `this.enablePreviewFallback = kPreviewDataEnabled`.
- `TeacherPreviewApi.enabled` = `!kReleaseMode && kPreviewDataEnabled` (giữ `TEACHER_UI_PREVIEW` override nếu cần: `bool.fromEnvironment('TEACHER_UI_PREVIEW', defaultValue: kPreviewDataEnabled)`).

- [ ] **Step 1: Write the failing tests**

```dart
group('ParentPaymentRepositoryImpl', () {
  test('getChildren should rethrow API error when preview disabled', () async {
    when(() => api.getChildren()).thenThrow(DioException(requestOptions: RequestOptions()));
    final repo = ParentPaymentRepositoryImpl(apiClient: api, enablePreviewFallback: false);
    expect(repo.getChildren(), throwsA(isA<DioException>()));
  });

  test('getChildren should merge mock children when preview enabled', () async {
    when(() => api.getChildren()).thenThrow(DioException(requestOptions: RequestOptions()));
    final repo = ParentPaymentRepositoryImpl(apiClient: api, enablePreviewFallback: true);
    final ids = (await repo.getChildren()).map((c) => c.id);
    expect(ids, contains(ParentPaymentRepositoryImpl.studentMinhId));
  });
});
```

  `api` là `class _Api extends Mock implements ParentHomeApiClient {}`.

  Thêm `test/features/parent/repository/family_insights_repository_impl_test.dart`:

```dart
group('FamilyInsightsRepositoryImpl', () {
  test('getInsights should return empty list when preview disabled', () async {
    expect(await FamilyInsightsRepositoryImpl(enablePreviewFallback: false).getInsights(), isEmpty);
  });
});
```

  Thêm 1 test cho default theo ENV (chạy được vì hằng số đọc `--dart-define` lúc compile test):

```dart
test('default should disable preview for prod', () async {
  expect(await FamilyInsightsRepositoryImpl().getInsights(), isEmpty);
}, skip: const String.fromEnvironment('ENV') != 'prod');
```

  Chạy test này bằng `flutter test --dart-define=ENV=prod test/features/parent/repository`.

- [ ] **Step 2: Run** `flutter test test/features/parent/repository` — Expected: test `getChildren should rethrow...` có thể đã PASS (logic rethrow có sẵn, test khóa hành vi); test FamilyInsights FAIL (đang trả sample).

- [ ] **Step 3: Tạo `preview_flags.dart`, đổi default param, xóa các `enablePreviewFallback: true` cứng** (DI + 9 screen + `payment_checkout_screen.dart:37` dùng default nên tự theo flag).

- [ ] **Step 4: Run** `grep -rn "enablePreviewFallback: true" lib` — Expected: không có kết quả. Run `flutter test test/features/parent/repository` và `flutter test --dart-define=ENV=prod test/features/parent/repository` — Expected: PASS cả hai.

- [ ] **Step 5: Commit**

```bash
git add lib/config/preview_flags.dart lib/di lib/features/parent lib/features/teacher/data/teacher_preview_api.dart test/features/parent
git commit -m "fix(parent): tat preview data o prod qua kPreviewDataEnabled"
```

---

### Task 3: Payment không giả thành công khi tắt preview

**Files:**
- Modify: `lib/features/parent/repository/parent_payment_repository_impl.dart` — `getPaymentSummary` (137), `getInvoices`, `getInvoiceDetail` (266), `submitPayment` (278), `checkPaymentStatus` (305), `getPaymentHistory` (324)
- Modify: `lib/features/parent/presentation/payment/parent_payment_screen.dart:48, 75, 87-90, 310, 319` — thêm error state, bỏ overview mặc định `isAllPaid: true`, ẩn toggle demo `_forceActionableDueMode` khi `!kPreviewDataEnabled`
- Modify: `payment_history_screen.dart`, `payment_invoice_detail_screen.dart`, `result/payment_transaction_result_screen.dart:38` — hiện lỗi khi repository throw
- Test: `test/features/parent/repository/parent_payment_repository_impl_test.dart` (thêm vào group Task 2)

**Interfaces:**
- Consumes: `kPreviewDataEnabled` (Task 2).
- Produces: khi `enablePreviewFallback == false`, 6 method trên throw `const PaymentUnavailableException()` — class mới, khai báo ngay trong `parent_payment_repository.dart`, `toString()` trả `'Thanh toán trực tuyến chưa khả dụng.'`.

- [ ] **Step 1: Write the failing tests**

```dart
test('submitPayment should throw when preview disabled', () {
  final repo = ParentPaymentRepositoryImpl(apiClient: api, enablePreviewFallback: false);
  expect(
    repo.submitPayment(invoiceId: 'inv', method: PaymentMethodType.vietQr, idempotencyKey: 'k'),
    throwsA(isA<PaymentUnavailableException>()),
  );
});

test('getPaymentSummary should throw when preview disabled', () {
  final repo = ParentPaymentRepositoryImpl(apiClient: api, enablePreviewFallback: false);
  expect(repo.getPaymentSummary(childId: 'real-child'), throwsA(isA<PaymentUnavailableException>()));
});

test('checkPaymentStatus should throw when preview disabled', () {
  final repo = ParentPaymentRepositoryImpl(apiClient: api, enablePreviewFallback: false);
  expect(repo.checkPaymentStatus('TXN-1'), throwsA(isA<PaymentUnavailableException>()));
});
```

  Widget test `test/features/parent/presentation/payment/parent_payment_screen_test.dart`: inject repository mock throw `PaymentUnavailableException` → `expect(find.text('Thanh toán trực tuyến chưa khả dụng.'), findsOneWidget)` và `expect(find.textContaining('Hoàn tất 100%'), findsNothing)`.

- [ ] **Step 2: Run** `flutter test test/features/parent` — Expected: FAIL (hiện trả kết quả giả; màn hiện "đã đóng").

- [ ] **Step 3: Thêm guard `if (!enablePreviewFallback) throw const PaymentUnavailableException();` ở đầu 6 method.**
  - Màn checkout đã có `catch` hiện SnackBar (`payment_checkout_screen.dart:71-79`): đổi text thành `'$e'`.
  - `parent_payment_screen`: thêm field `Object? _error`; `catch (e)` ở dòng 87 set `_error = e`; `build` có `_error != null` → hiện message + nút "Thử lại" gọi `_loadData`; xóa fallback `_overview ?? const PaymentSummaryOverviewModel(isAllPaid: true, ...)` ở dòng 310 (chỉ render overview khi `_overview != null`).
  - History / invoice detail / transaction result: `catch` và hiện message thay vì loading mãi.

- [ ] **Step 4: Run** `flutter test test/features/parent` — Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/parent test/features/parent
git commit -m "fix(payment): chan thanh toan gia khi tat preview data"
```

---

### Task 4: Lesson / CourseDetail bloc báo lỗi thật, hoàn thành bài chỉ khi server xác nhận

**Files:**
- Modify: `lib/features/student/bloc/lesson/lesson_bloc.dart:25, 52-58, 80-92`
- Modify: `lib/features/student/bloc/lesson/lesson_state.dart:21-62` (thêm field)
- Modify: `lib/features/student/bloc/course_detail/course_detail_bloc.dart:59, 80-83, 89, 114-117, 184`
- Modify: `lib/features/student/presentation/learning/lesson_detail/lesson_detail_screen.dart` — `BlocListener` hiện SnackBar khi `completionError != null`
- Test: `test/features/student/bloc/lesson/lesson_bloc_test.dart`, `test/features/student/bloc/course_detail/course_detail_bloc_test.dart`

**Interfaces:**
- Consumes: `kPreviewDataEnabled` (Task 2).
- Produces: `LessonSuccess.completionError` (`String?`, default `null`, có trong `props` và `copyWith`).
- Nhánh `MockCourseDetailData.isMockId` / `isMockLessonId` chỉ chạy khi `kPreviewDataEnabled` — ở **cả 4 chỗ**: `lesson_bloc.dart:25`, `course_detail_bloc.dart:59, 89` (load) và `:184` (tạo chứng chỉ mẫu).
- Lưu ý `isMockId(null | '')` trả `true` (`mock_course_detail_data.dart:11`). Khi preview tắt, id rỗng/null → emit `CourseDetailFailure('Không tìm thấy khóa học')`, không gọi API với `_id!`.
- Nhánh `failure` emit `LessonFailure(error.message)` / `CourseDetailFailure(error.message)`. UI đã xử lý 2 state này (`lesson_detail_screen.dart:184`, `course_detail_screen.dart:167`).

- [ ] **Step 1: Write the failing tests** (mock `StudentRepository` bằng mocktail như `quiz_bloc_test.dart`)

```dart
group('LessonBloc', () {
  blocTest<LessonBloc, LessonState>(
    'should emit LessonFailure when getLessonDetail fails',
    build: () { when(() => repo.getLessonDetail('l1')).thenAnswer((_) async => const Result.failure(ServerFailure(message: 'boom'))); return LessonBloc(repo); },
    act: (b) => b.add(LessonStarted('l1')),   // dùng đúng tên event load hiện có
    expect: () => [isA<LessonInProgress>(), const LessonFailure('boom')],
  );

  blocTest<LessonBloc, LessonState>(
    'should keep isCompleted false and set completionError when markLessonComplete fails',
    seed: () => LessonSuccess(lesson: lesson),
    build: ..., // markLessonComplete → Result.failure(ServerFailure(message: 'denied'))
    act: (b) => b.add(LessonCompleted(...)),
    expect: () => [LessonSuccess(lesson: lesson, completionError: 'denied')],
  );
});

group('CourseDetailBloc', () {
  blocTest('should emit CourseDetailFailure when getCourseById fails', ...);  // id dạng UUID, isEnrollment: false
  blocTest('should emit CourseDetailFailure when getCourseDetail fails', ...); // isEnrollment: true
});
```

  Các test này chạy với `kPreviewDataEnabled` mặc định (`ENV` không set → `dev` → `true`), nên phải dùng id dạng UUID (có `-`, không prefix `course_`/`mock_`) để không rơi vào nhánh mock. Thêm 1 test chạy với `--dart-define=ENV=prod`: id `course_1` → `CourseDetailFailure`, không phải mock.

  Lưu ý: `_lessonId` được set khi load; test thứ 2 cần add event load thành công trước rồi mới `LessonCompleted`, thay vì `seed`.

- [ ] **Step 2: Run** `flutter test test/features/student/bloc/lesson test/features/student/bloc/course_detail` — Expected: FAIL (đang emit Success với mock).

- [ ] **Step 3: Implement** theo Interfaces. `LessonCompleted` thành công → `isCompleted: true, completionError: null`; thất bại → giữ `isCompleted` cũ, set `completionError`.

- [ ] **Step 4: Run** lại — Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/student/bloc lib/features/student/presentation/learning/lesson_detail test/features/student/bloc
git commit -m "fix(lesson): emit failure that thay mock va chi hoan thanh bai khi server xac nhan"
```

---

### Task 5: Video chỉ gửi token cho đúng API origin, clip fallback không tính tiến độ

**Files:**
- Create: `lib/core/network/api_origin.dart`
- Modify: `lib/features/student/presentation/learning/widgets/lesson_video_player.dart:56-68, 164`
- Test: `test/core/network/api_origin_test.dart`

**Interfaces:**
- Produces: `bool isSameOrigin(Uri url, Uri apiBase)` — `true` khi `scheme`, `host`, `port` trùng nhau (so sánh không phân biệt hoa thường với host).
- Produces: `Map<String, String> videoAuthHeaders(Uri url, {required Uri apiBase, required String? token})` cùng file — trả `{'Authorization': 'Bearer $token'}` chỉ khi `token != null && isSameOrigin(url, apiBase)`, ngược lại `{}`. Video player gọi hàm này thay khối `isOurApi` (để test chứng minh player không còn logic `contains`).
- Video player: `apiBase = Uri.parse(diContainer<Dio>().options.baseUrl)`.
- Redirect: `video_player` (ExoPlayer/AVPlayer) có thể mang header sang host redirect — chưa xác minh; hỏi backend URL video có redirect không. Nếu có → backend nên trả signed URL thay vì dựa vào Bearer.
- `widget.onProgressThreshold` (dòng 164) không được gọi khi `_usedFallback == true`.

- [ ] **Step 1: Write the failing tests**

```dart
group('isSameOrigin', () {
  final api = Uri.parse('https://api.40study.vn');
  test('should match same scheme host port', () => expect(isSameOrigin(Uri.parse('https://api.40study.vn/v/1.mp4'), api), isTrue));
  test('should not attach auth for other hosts', () {
    expect(isSameOrigin(Uri.parse('https://api.attacker.com/x'), api), isFalse);
    expect(isSameOrigin(Uri.parse('https://40study.evil.io/x'), api), isFalse);
    expect(isSameOrigin(Uri.parse('https://cdn.cloudflare.com/v.mp4'), api), isFalse);
  });
  test('should not match http downgrade', () => expect(isSameOrigin(Uri.parse('http://api.40study.vn/x'), api), isFalse));
});

group('videoAuthHeaders', () {
  final api = Uri.parse('https://api.40study.vn');
  test('should attach bearer for api origin', () => expect(videoAuthHeaders(Uri.parse('https://api.40study.vn/v.mp4'), apiBase: api, token: 't'), {'Authorization': 'Bearer t'}));
  test('should be empty for other host', () => expect(videoAuthHeaders(Uri.parse('https://api.attacker.com/v.mp4'), apiBase: api, token: 't'), isEmpty));
  test('should be empty without token', () => expect(videoAuthHeaders(Uri.parse('https://api.40study.vn/v.mp4'), apiBase: api, token: null), isEmpty));
});
```

  Guard `_usedFallback` trước `onProgressThreshold` không có test tự động (cần mock `VideoPlayerController`); verify thủ công ở Step 4.

- [ ] **Step 2: Run** `flutter test test/core/network/api_origin_test.dart` — Expected: FAIL (`isSameOrigin` chưa có).

- [ ] **Step 3: Implement** `api_origin.dart` và thay khối `isOurApi` trong video player bằng `videoAuthHeaders(...)`; thêm guard `_usedFallback` trước `onProgressThreshold`.

- [ ] **Step 4: Run** test — Expected: PASS. `grep -n "contains('api.')" lib/features/student/presentation/learning/widgets/lesson_video_player.dart` — Expected: không có kết quả. Thủ công: mở bài có `videoUrl` lỗi → clip mẫu phát hết → bài **không** chuyển "đã hoàn thành".

- [ ] **Step 5: Commit**

```bash
git add lib/core/network/api_origin.dart lib/features/student/presentation/learning/widgets/lesson_video_player.dart test/core/network/api_origin_test.dart
git commit -m "fix(video): chi gui bearer token cho dung api origin"
```

---

### Task 6: AuthInterceptor — không deadlock, refresh một lần, so path chính xác

**Files:**
- Modify: `lib/features/auth/data/auth_interceptor.dart`
- Modify: `lib/di/di_network_module.dart:36-42` (truyền thêm `retryDio`)
- Test: `test/features/auth/data/auth_interceptor_test.dart`

**Interfaces:**
- Constructor thêm `Dio? retryDio` (optional, để test inject). Default tạo trong `di_network_module.dart`: `Dio(BaseOptions(baseUrl, timeout giống dio chính))` + `NetworkErrorInterceptor()` (giữ mapping `Failure` cho bloc), **không** gắn `AuthInterceptor`, chỉ gắn `TalkerDioLogger` khi `kDebugMode` như Task 1. Dùng chung instance này cho cả refresh call và retry (thay `refreshDio` tạo mới mỗi lần ở dòng 109).
- `bool _isPublic(String path)`: `_publicPaths.contains(Uri.parse(path).path)` (so khớp chính xác, `_publicPaths` đổi thành `Set<String>`). Sửa entry sai: `/api/system-roles` → `/api/auth/system-roles` (`auth_api_client.dart:43`).
- Trước khi refresh: nếu `err.requestOptions.headers['Authorization'] != 'Bearer ${await getAccessToken()}'` → token đã được refresh bởi request trước trong queue → bỏ qua refresh, retry luôn.
- Retry đúng 1 lần qua `retryDio.fetch(opts)`; không đi lại vào `_dio`. Retry vẫn trả **401** → `clearAll()` + `notify()` một lần, `handler.next(e)`; không refresh lại (tránh vòng lặp).

- [ ] **Step 1: Write the failing tests** — dùng fake `HttpClientAdapter` (class `_FakeAdapter implements HttpClientAdapter`, map `path → queue<ResponseBody>`, đếm số lần gọi `/api/auth/refresh-token`), `AuthStorage` mock bằng mocktail. **Gắn cùng một `_FakeAdapter` cho cả `dio` chính và `retryDio`** (`retryDio.httpClientAdapter = adapter`), nếu không request retry/refresh sẽ ra mạng thật. Token lưu trong mock storage phải đổi sau `saveTokens` (stub `getAccessToken` đọc từ biến cục bộ) để kiểm tra nhánh "token đã đổi".

```dart
group('AuthInterceptor', () {
  test('should refresh once for concurrent 401s', () async {
    // /a và /b trả 401 lần đầu, 200 lần sau; refresh trả token mới
    final results = await Future.wait([dio.get('/a'), dio.get('/b')]);
    expect(results.map((r) => r.statusCode), [200, 200]);
    expect(adapter.calls('/api/auth/refresh-token'), 1);
  });

  test('should complete with error when retried request fails', () async {
    // /a: 401 rồi 500
    await expectLater(
      dio.get('/a').timeout(const Duration(seconds: 2)),
      throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 500)),
    );
  });

  test('should attach token to paths that only share a public prefix', () async {
    await dio.get('/api/auth/register-device');
    expect(adapter.lastHeaders('/api/auth/register-device')['authorization'], 'Bearer old');
  });

  test('should clear session when refresh fails', () async {
    // refresh trả 401
    await expectLater(dio.get('/a'), throwsA(isA<DioException>()));
    verify(() => storage.clearAll()).called(1);
    verify(() => notifier.notify()).called(1);
  });

  test('should clear session once when retried request still returns 401', () async {
    // /a: 401, refresh 200, /a lại 401
    await expectLater(dio.get('/a'), throwsA(isA<DioException>()));
    expect(adapter.calls('/api/auth/refresh-token'), 1);
    verify(() => notifier.notify()).called(1);
  });

  test('should map retry error to Failure', () async {
    // /a: 401 rồi 500
    final e = await dio.get('/a').then((_) => null, onError: (Object e) => e) as DioException;
    expect(e.error, isA<Failure>());
  });
});
```

- [ ] **Step 2: Run** `flutter test test/features/auth/data/auth_interceptor_test.dart` — Expected: test 1 FAIL (refresh 2 lần), test 3 FAIL (contains match). Test 2 có thể FAIL bằng `TimeoutException` (deadlock) — nếu PASS thì deadlock không tái hiện với dio 5.9.2, vẫn giữ test làm regression; ghi kết quả vào commit message.

- [ ] **Step 3: Implement** theo Interfaces.

- [ ] **Step 4: Run** — Expected: 6 PASS.

- [ ] **Step 5: Hỏi backend** `/api/auth/select-role` (endpoint thật, `auth_api_client.dart:38`) có cần Bearer token không; `_publicPaths` đang ghi `/api/auth/select-profile` (không tồn tại). Cập nhật set cho đúng, không đoán.

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/data/auth_interceptor.dart lib/di/di_network_module.dart test/features/auth
git commit -m "fix(auth): retry qua dio rieng, refresh mot lan, so public path chinh xac"
```

---

### Task 7: Token chuyển sang secure storage (có migrate)

**Files:**
- Modify: `pubspec.yaml` — thêm `flutter_secure_storage: ^9.2.4`
- Modify: `lib/features/auth/data/auth_storage.dart` — `SharedPreferencesAuthStorage` nhận thêm `FlutterSecureStorage secure`
- Modify: `lib/di/di_data_module.dart:22` (nơi tạo `SharedPreferencesAuthStorage`) — truyền `const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true))`
- Test: `test/features/auth/data/auth_storage_test.dart`

**Interfaces:**
- Chỉ `access_token` / `refresh_token` vào secure storage (key giữ nguyên `auth_access_token`, `auth_refresh_token`). User/role/profile vẫn ở prefs.
- Migrate **cả cặp** trong một private `Future<void> _migrateLegacyTokens()` (chạy 1 lần, cache `Future` trong field): nếu prefs còn `auth_access_token` hoặc `auth_refresh_token` → `write` cả hai sang secure → **chỉ khi cả hai write không throw** mới `remove` khỏi prefs. Write lỗi → giữ prefs, đọc fallback từ prefs (user không bị logout); lần sau thử lại.
- `getAccessToken()` / `getRefreshToken()`: `await _migrateLegacyTokens()` rồi đọc secure; `secure.read` throw (Keystore hỏng sau restore backup) → `secure.deleteAll()` và trả `null` (buộc login lại, không crash).
- `saveTokens`: write access rồi refresh; nếu write thứ hai throw → delete cả hai key rồi rethrow (không để cặp lệch).
- `hasToken()` dựa trên `getAccessToken() != null` (không còn `containsKey`).
- `clearAll()` / `clearTokens()` xóa ở cả secure lẫn prefs.

- [ ] **Step 1: Write the failing tests** (`SharedPreferences.setMockInitialValues`, `FlutterSecureStorage` mock bằng mocktail)

```dart
group('SharedPreferencesAuthStorage', () {
  test('should write tokens to secure storage only', () async {
    await storage.saveTokens(accessToken: 'a', refreshToken: 'r');
    verify(() => secure.write(key: 'auth_access_token', value: 'a')).called(1);
    expect(prefs.containsKey('auth_access_token'), isFalse);
  });
  test('should migrate legacy token from prefs', () async {
    // prefs có auth_access_token = 'legacy', secure.read trả null
    expect(await storage.getAccessToken(), 'legacy');
    verify(() => secure.write(key: 'auth_access_token', value: 'legacy')).called(1);
    expect(prefs.containsKey('auth_access_token'), isFalse);
  });
  test('should keep legacy prefs token when secure write fails', () async {
    // secure.write throw
    expect(await storage.getAccessToken(), 'legacy');
    expect(prefs.getString('auth_access_token'), 'legacy');
  });
  test('should return null when secure read throws', () async {
    // secure.read throw PlatformException
    expect(await storage.getAccessToken(), isNull);
    verify(() => secure.deleteAll()).called(1);
  });
  test('clearAll should delete tokens from secure storage', () async {
    await storage.clearAll();
    verify(() => secure.delete(key: 'auth_access_token')).called(1);
    verify(() => secure.delete(key: 'auth_refresh_token')).called(1);
  });
});
```

- [ ] **Step 2: Run** `flutter pub get && flutter test test/features/auth/data/auth_storage_test.dart` — Expected: FAIL.

- [ ] **Step 3: Implement**, rồi `dart run build_runner build --delete-conflicting-outputs`.

- [ ] **Step 4: Run** test — Expected: PASS. Verify thủ công: cài bản cũ, login, cài đè bản mới → vẫn đăng nhập.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/auth/data/auth_storage.dart lib/di test/features/auth/data/auth_storage_test.dart
git commit -m "fix(auth): luu token trong secure storage va migrate tu shared prefs"
```

---

### Task 8: Logout xóa dữ liệu local của user

**Files:**
- Modify: `lib/data/daily_goals_storage.dart` — thêm `Future<void> clear()`: `_goalsByDate.clear()` (map trong bộ nhớ, dòng 12) **và** `_prefs?.remove('daily_goals')`
- Modify: `lib/features/auth/repository/auth_repository_impl.dart:386-401, 547` + constructor
- Modify: `lib/di/di_repository_module.dart:48-52`
- Test: `test/features/auth/repository/auth_repository_impl_test.dart`

**Interfaces:**
- `AuthRepositoryImpl` nhận thêm `BookmarkStorage bookmarkStorage`, `LastAccessedCourseStorage lastAccessedStorage` (lấy từ DI) và `DailyGoalsStorage dailyGoalsStorage` (DI truyền `DailyGoalsStorage.instance` — class này là singleton, không đăng ký injectable).
- Private `Future<void> _clearLocalUserData()` gọi `_storage.clearAll()` + 3 `clear()`, **mỗi lệnh trong try/catch riêng** (log `AppLogger.w`) để một storage lỗi không chặn các storage còn lại; `logout`, `logoutAll`, `clearSession` đều dùng nó (trong `finally`).
- Bloc state trong bộ nhớ: `BookmarkBloc` và các bloc student khác là factory theo màn hình, bị hủy khi `MainScreen` chuyển sang unauthenticated → không cần reset thêm. `DailyGoalsStorage` là singleton nên phải clear map như trên.
- `device_id` **không** xóa (giữ nguyên như `clearAll` hiện tại).

- [ ] **Step 1: Write the failing test**

```dart
group('AuthRepositoryImpl', () {
  test('logout should clear bookmarks, goals and last accessed course even when API fails', () async {
    when(() => api.logout()).thenThrow(DioException(requestOptions: RequestOptions()));
    await expectLater(repo.logout(), throwsA(isA<DioException>()));
    verify(() => bookmarks.clear()).called(1);
    verify(() => lastAccessed.clear()).called(1);
    verify(() => goals.clear()).called(1);
  });

  test('clearSession should still clear goals when bookmark clear throws', () async {
    when(() => bookmarks.clear()).thenThrow(Exception('io'));
    await repo.clearSession();
    verify(() => goals.clear()).called(1);
  });
});

group('DailyGoalsStorage', () {
  test('clear should drop in-memory and persisted goals', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = DailyGoalsStorage.instance;
    await storage.init(prefs);
    storage.addGoal(DateTime.now(), 'Đọc bài 1');
    await storage.clear();
    expect(storage.getGoals(DateTime.now()), isEmpty);
    expect(prefs.containsKey('daily_goals'), isFalse);
  });
});
```

- [ ] **Step 2: Run** — Expected: FAIL (constructor chưa nhận storage).

- [ ] **Step 3: Implement**, cập nhật DI, chạy build_runner.

- [ ] **Step 4: Run** — Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/daily_goals_storage.dart lib/features/auth/repository lib/di test/features/auth/repository
git commit -m "fix(auth): xoa du lieu local cua user khi logout"
```

---

### Task 9: Không đoán role khi login / routing

**Files:**
- Modify: `lib/features/auth/bloc/auth/auth_bloc.dart:37-91`
- Modify: `lib/features/main_screen.dart:23, 44-45`
- Test: `test/features/auth/bloc/auth_bloc_test.dart`

**Interfaces:**
- `_onLoggedIn`: `user == null` → `await _authRepository.clearSession()` (token có thể đã được lưu) rồi emit `AuthUnauthenticated()`. Có `activeRole` mà không profile nào khớp → `activeProfile` giữ `null` (bỏ `orElse: () => profiles.first`); không có `activeRole` và chỉ có 1 profile → dùng profile đó; nhiều profile → `null`.
- `MainScreen`: `activeProfile == null` hoặc role không nằm trong `student | parent | teacher | teacherapplicant | teacher_applicant` → render widget private `_InvalidSessionView` (cùng file): text `'Không xác định được vai trò của tài khoản.'` + nút `'Đăng xuất'` → `context.read<AuthBloc>().add(AuthLoggedOut())`. **Không dùng `SelectRoleScreen`** — màn đó dẫn sang đăng ký tài khoản mới (`select_role_screen.dart:256`), không chọn profile cho phiên đã login. Không còn default `StudentShell`.

- [ ] **Step 1: Write the failing tests**

```dart
group('AuthBloc', () {
  blocTest<AuthBloc, AuthState>('should clear session and emit AuthUnauthenticated when login response has no user',
    build: () { when(() => repo.clearSession()).thenAnswer((_) async {}); return AuthBloc(repo); },
    act: (b) => b.add(AuthLoggedIn(const AuthResponse())),
    expect: () => [isA<AuthUnauthenticated>()],
    verify: (_) => verify(() => repo.clearSession()).called(1));

  blocTest<AuthBloc, AuthState>('should not pick first profile when none matches active role',
    build: () { when(() => repo.getProfiles()).thenAnswer((_) async => [parentProfile]); return AuthBloc(repo); },
    act: (b) => b.add(AuthLoggedIn(AuthResponse(user: user, activeRole: teacherRole))),
    expect: () => [isA<AuthAuthenticated>().having((s) => s.activeProfile, 'profile', isNull)]);
});
```

  Thêm widget test `test/features/main_screen_test.dart`: `MainScreen should show logout recovery when profile is null` (mock `AuthBloc` bằng `MockBloc` từ bloc_test, state `AuthAuthenticated(user: user, activeProfile: null)`) → `expect(find.text('Đăng xuất'), findsOneWidget)`; tap → `verify(() => bloc.add(any(that: isA<AuthLoggedOut>()))).called(1)`.

- [ ] **Step 2: Run** `flutter test test/features/auth/bloc test/features/main_screen_test.dart` — Expected: FAIL.

- [ ] **Step 3: Implement.**

- [ ] **Step 4: Run** — Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/bloc/auth/auth_bloc.dart lib/features/main_screen.dart test/features/auth/bloc test/features/main_screen_test.dart
git commit -m "fix(auth): khong doan role khi login, role la chuyen ve chon role"
```

---

### Task 10: Bỏ quyền vị trí không dùng

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml:15-16` — xóa `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`

- [ ] **Step 1: Xóa 2 dòng permission.**

- [ ] **Step 2: Verify**

  Run: `flutter build apk --flavor dev --debug` rồi xem `build/app/intermediates/merged_manifests/devDebug/**/AndroidManifest.xml`
  Expected: không có `ACCESS_FINE_LOCATION`. Nếu vẫn có thì đến từ plugin — thêm `tools:node="remove"` cho 2 quyền đó.

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml
git commit -m "fix(android): bo quyen vi tri khong dung"
```

---

### Task 11: Quiz result filter so đủ tập đáp án

**Files:**
- Modify: `lib/features/student/data/models/quiz_question_model.dart` (thêm method)
- Modify: `lib/features/student/presentation/learning/quiz_result_screen.dart:75-78` (bộ lọc) và `:326` (hiển thị đáp án của user — hiện chỉ lấy phần tử đầu khi `userAns` là `Iterable`; câu nhiều đáp án phải hiện đủ các lựa chọn, nối bằng `', '`)
- Test: `test/features/student/data/quiz_question_model_test.dart`

**Interfaces:**
- Produces: `bool? QuizQuestionModel.isAnsweredCorrectly(Object? userAnswer)` — `int` → `== correctAnswer`; `Set<int>` → `a.length == b.length && a.containsAll(b)` với `b = correctAnswers.toSet()` (không import Flutter); `userAnswer == null` → `false`. **Không có đáp án nào `isCorrect == true`** (API không trả `is_correct`) → trả `null` = "chưa biết"; bộ lọc "Đúng"/"Sai" bỏ qua câu `null` thay vì coi là sai.
- Màn kết quả ưu tiên `reviewItems[i].isCorrect` từ server (nhánh dòng 65-66) khi có; chỉ dùng `isAnsweredCorrectly` khi endpoint review lỗi.

- [ ] **Step 1: Write the failing tests**

```dart
group('QuizQuestionModel', () {
  const q = QuizQuestionModel(answers: [
    QuizAnswerModel(isCorrect: true), QuizAnswerModel(isCorrect: true), QuizAnswerModel(),
  ]);
  test('should be wrong when multi-choice answer misses one correct option', () => expect(q.isAnsweredCorrectly({0}), isFalse));
  test('should be wrong when multi-choice answer has extra option', () => expect(q.isAnsweredCorrectly({0, 1, 2}), isFalse));
  test('should be correct when sets are equal', () => expect(q.isAnsweredCorrectly({1, 0}), isTrue));
  test('should be unknown when API sent no is_correct', () {
    const noKey = QuizQuestionModel(answers: [QuizAnswerModel(), QuizAnswerModel()]);
    expect(noKey.isAnsweredCorrectly(0), isNull);
  });
});
```

  Widget test `test/features/student/presentation/learning/quiz_result_screen_test.dart`: 1 câu multi-choice user chọn thiếu (`{0}`), không có `reviewItems` → chọn filter "Đúng" → `findsNothing` cho câu đó; filter "Sai" → `findsOneWidget`.

- [ ] **Step 2: Run** — Expected: FAIL (method chưa có).

- [ ] **Step 3: Implement**, chạy build_runner (freezed), thay logic trong `quiz_result_screen.dart`.

- [ ] **Step 4: Run** — Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/student/data/models lib/features/student/presentation/learning/quiz_result_screen.dart test/features/student
git commit -m "fix(quiz): so du tap dap an khi loc ket qua"
```

---

### Task 13: Upload video chỉ chấp nhận HTTPS

**Files:**
- Modify: `lib/features/teacher/data/video_upload_controller.dart:90-91`
- Test: thêm vào test hiện có của controller trong `test/features/teacher/` (grep `VideoUploadController`); nếu chưa có, tạo `test/features/teacher/video_upload_controller_test.dart`

**Interfaces:**
- Điều kiện mới: `url.scheme != 'https'` → `throw const FormatException('Địa chỉ lưu trữ không hợp lệ.')`. Ngoại lệ duy nhất: `url.host` là `localhost` / `127.0.0.1` / `10.0.2.2` (MinIO local khi dev).
- Giữ nguyên `storageClient` không gắn Bearer (dòng 7) — đây là hành vi đúng.

- [ ] **Step 1: Write the failing test** — `should reject http signed url`: stub API trả `{'urls': [{'url': 'http://storage.example.com/put'}]}` → upload kết thúc với lỗi `FormatException`, `storageClient` không được gọi `put`. Thêm `should allow http for localhost`.
- [ ] **Step 2: Run** `flutter test test/features/teacher` — Expected: test 1 FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** — Expected: PASS.
- [ ] **Step 5: Commit**

```bash
git add lib/features/teacher/data/video_upload_controller.dart test/features/teacher
git commit -m "fix(teacher): chi upload video qua signed url https"
```

---

### Task 12: Kiểm tra cuối (chạy sau Task 13)

- [ ] **Step 0 (trước Task 1):** lưu baseline: `git checkout main && flutter analyze --no-fatal-infos > /tmp/analyze-main.txt; flutter test > /tmp/test-main.txt`.
- [ ] **Step 1:** `flutter analyze --no-fatal-infos > /tmp/analyze-branch.txt` rồi `diff <(grep -E "error|warning" /tmp/analyze-main.txt | sort) <(grep -E "error|warning" /tmp/analyze-branch.txt | sort)` — Expected: không có dòng `>` (không có error/warning mới).
- [ ] **Step 2:** `flutter test` và `flutter test --dart-define=ENV=prod test/features/parent test/features/student/bloc` — Expected: toàn bộ PASS.
- [ ] **Step 3:** Chạy `make runDev` — parent (home, payment, history, insights) và teacher vẫn hiện dữ liệu demo. Chạy bản `ENV=prod`:
  - Parent: home/learning/schedule hiện lỗi hoặc trống khi API lỗi, không có "Nguyễn Nhật Minh" / "Nguyễn Mai Lan".
  - Payment: hiện "Thanh toán trực tuyến chưa khả dụng.", không có "Hoàn tất 100%", không có mã `TXN-2026-99120`.
  - Family insights: danh sách trống.
  - Tài khoản thiếu profile: hiện màn "Không xác định được vai trò" + nút Đăng xuất.
- [ ] **Step 4:** Hỏi backend: API start quiz có trả `is_correct` cho từng đáp án trước khi nộp không (`QuizAnswerModel.isCorrect` được parse từ JSON). Nếu có → học sinh đọc được đáp án qua proxy; backend phải bỏ field này khỏi response trước khi nộp.

---

## Backlog (plan riêng, không làm trong đợt này)

- Parent screens: chuyển `setState` + `ParentXRepositoryImpl(...)` trong `initState` sang bloc inject qua `BlocProvider` (75 chỗ `diContainer` trong `lib/features`).
- `StudentRepositoryImpl`: ~30 `catch (e) → ServerFailure(e.toString())` → map qua `DioErrorMapper` để giữ loại lỗi và message thân thiện.
- Tách file >1000 dòng: `academic_level_roadmap.dart`, `explore_courses_screen.dart`, `parent_learning_repository_impl.dart` (tách mock data ra file riêng).
- `ListView(children:)` cho danh sách dài → `ListView.builder`; `parent_payment_screen._loadData` gọi 3 API tuần tự → `Future.wait`.
- `LICENSE` còn tên tác giả template.
- `lesson_documents_section.dart:143`: "Tải tất cả" chỉ `Future.delayed` rồi đánh dấu đã tải → nối download thật hoặc ẩn nút.
- `add_child_screen.dart:162`: link-child vẫn là `Future.delayed` + SnackBar "đang phát triển" (trung thực, nhưng cần API `POST /api/parent/link-child`).
- Release prod (F11, F16) — để sau khi chốt phát hành: `Makefile:51` và `release.yml` dùng `--flavor prod`; `release.yml` tạo `.env.*` (`.env.prod` từ secret `ENV_PROD`) và chạy `build_runner` trước build; sửa đường dẫn artifact (dòng 61-62, 93) sang `app-prod-release.apk` / `bundle/prodRelease/app-prod-release.aab`.
- Hỏi backend: URL video có redirect sang host khác không (Task 5); `/api/auth/select-role` có cần Bearer không (Task 6).
