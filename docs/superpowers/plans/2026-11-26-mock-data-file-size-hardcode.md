# Mock data, file lớn, hardcode — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bản prod không còn hiện dữ liệu giả ở màn học sinh/giáo viên/phụ huynh, không có logic rẽ nhánh theo tên/ID con mẫu, file lớn được tách gọn, và hardcode quan trọng (env, app ID) được gom về cấu hình.

**Architecture:** Tiếp tục dùng cờ `kPreviewDataEnabled` (`lib/config/preview_flags.dart`) làm cổng duy nhất cho mọi dữ liệu mẫu; khi cờ tắt, màn hình hiện trạng thái trống hoặc dữ liệu thật từ API đã có ở backend (`D:\đồ án\backend`). ID con mẫu gom về một file. Tách file lớn bằng cách di chuyển code thuần (không đổi hành vi), kiểm chứng bằng test màn hình sẵn có.

**Tech Stack:** Flutter 3.47.x (xem Global Constraints), flutter_bloc 9, dio + retrofit, mocktail, bloc_test.

**Spec:** Kết quả rà soát trong hội thoại 2026-11-26 (mục "Mock data / Kích thước file / Hardcode"). Không có file spec riêng — các quyết định trong plan là tạm thời theo rà soát đó.

## Global Constraints

- Dùng Flutter **3.47.x** (`pubspec.lock` không resolve được với 3.50). Đường dẫn dự án có dấu (`đồ án`) làm `flutter analyze` crash → chạy qua ổ ảo: `subst W: "D:\đồ án\mobile"` rồi chạy lệnh trong `W:\`.
- Business logic (bloc, cubit, repository, `lib/config/*`, `lib/features/**/data/mock/*`) không import `package:flutter/*` trừ khi file đó đã import sẵn (rule `bloc.md` › Code Quality 4).
- Test: `group()` đặt tên theo class, tên test có "should" (rule `test.md`).
- Comment ngắn, English + Vietnamese (rule `comment-rule.md`).
- Không commit/push khi user chưa yêu cầu (memory `no-commit-without-ask`). Bước "Commit" trong plan chỉ chạy khi user đồng ý.
- Commit message: `fix(scope): mo ta khong dau` / `refactor(scope): ...`.
- Không thêm dependency mới.
- Sau khi sửa file có retrofit/freezed: `dart run build_runner build --delete-conflicting-outputs`.

## Review Focus

1. Dev build (`ENV=dev`, debug) vẫn xem được toàn bộ dữ liệu demo như trước (portfolio, review giảng viên, ghi chú, gợi ý) → mỗi task có test `... when preview enabled`.
2. Con thật có tên chứa "Minh"/"Lan" (vd "Minh Anh", "Thanh Lan") không bị gán mã HS, lớp, màu của con mẫu → Task 1 test `fromSession should not use demo detail for real child named Minh Anh`.
3. Giảng viên chưa có khóa học / chưa có đánh giá → hiện trạng thái trống, không crash, không hiện số 1248 → Task 3 test `should show empty state when instructor has no courses`.
4. Phụ huynh chưa liên kết con mở màn tiến độ/bài tập → hiện `ParentNoChildView`, không hiện "Minh – 10A1" → Task 1 widget test.
5. Tách file (Task 7–8) không đổi giao diện → `flutter test test/screens` pass trước và sau.

---

## Phase 1 — Chặn dữ liệu giả ở prod (làm ngay)

### Task 1: Gom ID con mẫu, bỏ logic theo tên "Minh"/"Lan"

**Files:**
- Create: `lib/features/parent/data/mock/parent_mock_ids.dart`
- Modify (xóa 3 hằng `studentTungId/MinhId/LanId`, dùng `ParentMockIds`): `parent/repository/{family_insights,parent_home,parent_learning,parent_payment,parent_schedule}_repository_impl.dart`
- Modify: `parent/data/models/parent_session_detail_model.dart:265-270` — chỉ dùng chi tiết demo khi `kPreviewDataEnabled && ParentMockIds.isMock(session.childId)`; bỏ so khớp `childName.contains('minh'/'lan')`
- Modify: `parent/data/models/parent_schedule_item.dart:87-90` — fallback màu = `AchievementColors.getBadgeColor((childId ?? childName).hashCode)`
- Modify: `parent/presentation/home/widgets/learning_analytics_card.dart:676-685` — nền `analytics.childBadgeColor ?? AchievementColors.getBadgeColor(analytics.childId.hashCode)`, chữ `cs.primary`; bỏ so sánh `'Minh'`
- Modify: `parent/presentation/learning/progress/parent_progress_screen.dart:120-126`, `homework/parent_homework_screen.dart:205-215` — không có con → `ParentNoChildView` (đã có ở `parent/presentation/home/widgets/parent_no_child_view.dart`), bỏ `FamilyScopeChild.sample(name: 'Minh')`
- Modify: `parent/presentation/learning/class_detail/parent_class_detail_screen.dart:26` — `childName` thành `required`; 2 call site (`parent_learning_screen.dart:419`, `parent_progress_screen.dart:98`) truyền tên thật
- Test: `test/features/parent/data/parent_session_detail_model_test.dart`, `test/features/parent/data/parent_mock_ids_test.dart`

**Interfaces:**
- Produces: `abstract final class ParentMockIds { static const tung = '31843f49-fd61-47aa-af78-d1badbdcce52'; static const minh = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732'; static const lan = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad'; static bool isMock(String? id); }` — `isMock` true chỉ với 3 ID trên. Pure Dart.
- Các repository giữ getter cũ nếu test/màn khác đang dùng (`grep -rn "studentMinhId" lib test`) → thay toàn bộ sang `ParentMockIds.minh`, không giữ alias.

- [ ] **Step 1: Write the failing tests**

```dart
group('ParentSessionDetail', () {
  test('fromSession should not use demo detail for real child named Minh Anh', () {
    final session = ParentScheduleSession(/* childId: 'real-uuid', childName: 'Minh Anh', ... */);
    final detail = ParentSessionDetail.fromSession(session);
    expect(detail.studentCode, isNot('HS-10294'));
  });
});

group('ParentMockIds', () {
  test('isMock should only match the three demo ids', () {
    expect(ParentMockIds.isMock(ParentMockIds.minh), isTrue);
    expect(ParentMockIds.isMock('Minh'), isFalse);
    expect(ParentMockIds.isMock(null), isFalse);
  });
});
```

  Widget test `test/features/parent/presentation/parent_progress_screen_test.dart`: repository mock trả `getChildren() → []` → `expect(find.byType(ParentNoChildView), findsOneWidget)` và `expect(find.text('Minh'), findsNothing)`.

- [ ] **Step 2: Run** `flutter test test/features/parent` — Expected: FAIL (`ParentMockIds` chưa có; session detail vẫn trả `HS-10294`).
- [ ] **Step 3: Implement** theo Interfaces. Run `grep -rn "== 'Minh'\|contains('minh')\|contains('lan')\|a055e1b3\|a0f88b81\|31843f49" lib` — Expected: chỉ còn trong `parent_mock_ids.dart`.
- [ ] **Step 4: Run** `flutter test test/features/parent test/screens` — Expected: PASS.
- [ ] **Step 5: Commit** `refactor(parent): gom id con mau va bo logic theo ten con`

---

### Task 2: Portfolio không dùng mock khi tắt preview

**Files:**
- Modify: `lib/features/student/presentation/portfolio/portfolio_screen.dart:23-27`
- Modify: `lib/features/student/presentation/portfolio/mock_portfolio_data.dart` — chuyển sang `lib/features/student/data/mock/mock_portfolio_data.dart` (cùng chỗ với mock khác)
- Test: `test/features/student/presentation/portfolio/portfolio_screen_test.dart`

**Interfaces:**
- Backend chưa có API portfolio (`GET /api/student/portfolio` — TODO trong file mock). Khi `!kPreviewDataEnabled`: `_profile = PortfolioProfile(name: <fullName của AuthAuthenticated.user, fallback ''>, title: '', location: '', website: '', bio: '')`, `_stats` = `PortfolioStats` toàn 0, `_projects/_skills/_experiences` = `[]`. Mỗi section rỗng hiện text `'Chưa có dữ liệu'` thay vì card giả.
- Lấy user qua `context.read<AuthBloc>().state` trong `didChangeDependencies` (không trong `initState`, rule provider.md 13).

- [ ] **Step 1: Write the failing test** — `PortfolioScreen should not show mock profile when preview disabled`: chạy với `--dart-define=PREVIEW_DATA=false`, `expect(find.text('Linh Nguyen'), findsNothing)`. Test thứ 2 (chạy mặc định, preview bật): `should show mock profile when preview enabled` → `findsOneWidget`.
- [ ] **Step 2: Run** `flutter test --dart-define=PREVIEW_DATA=false test/features/student/presentation/portfolio` — Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run** cả 2 lệnh (`flutter test ...` và `flutter test --dart-define=PREVIEW_DATA=false ...`) — Expected: PASS. Test preview-off dùng `skip: kPreviewDataEnabled` để không fail khi chạy mặc định.
- [ ] **Step 5: Commit** `fix(portfolio): tat du lieu mau khi khong bat preview`

---

### Task 3: Màn giảng viên — khóa học thật, review/rating giả chỉ ở preview

**Files:**
- Modify: `lib/features/course/data/course_api_client.dart:14-22` — thêm `@Query('instructor_id') String? instructorId` vào `getCourses`
- Modify: `lib/features/course/repository/course_repository.dart:7-15` + impl — thêm `String? instructorId`
- Create: `lib/features/student/bloc/instructor_courses/instructor_courses_cubit.dart` (+ `_state.dart`)
- Modify: `lib/features/student/presentation/learning/instructor_courses_screen.dart:63-140` — bỏ `_courses` cứng, dùng cubit
- Modify: `instructor_reviews_screen.dart:35-120`, `instructor_detail_screen.dart:505-530`, `widgets/instructor_rating_summary_card.dart` — chỉ render dữ liệu mẫu khi `kPreviewDataEnabled`; ngược lại hiện `'Chưa có đánh giá'` và ẩn rating summary
- Test: `test/features/student/bloc/instructor_courses_cubit_test.dart`, `test/features/student/presentation/learning/instructor_reviews_screen_test.dart`

**Interfaces:**
- Backend: `GET /api/courses` nhận `instructor_id` (`internal/dto/courseDTO.go:124`, `query:"instructor_id"`). **Verify trước khi code**: đọc handler list public courses trong `internal/handler/course_handler.go` xác nhận filter được áp dụng; nếu không → giữ khóa học giả sau cờ preview như review, ghi `Ruling:`.
- Backend **không có** API review theo giảng viên (chỉ `GET /courses/:courseId/reviews`) và không có rating tổng hợp → review/rating giữ mock sau cờ, prod hiện trống. Ghi vào Backlog "API review giảng viên".
- Produces: `InstructorCoursesCubit(CourseRepository repo)` với `Future<void> load(String instructorId)`; state sealed `InstructorCoursesInitial | InProgress | Success(List<CourseModel> courses) | Failure(String message)`.
- Màn map `CourseModel` → card hiện có; bỏ class `_InstructorCourseData` nếu không còn dùng.

- [ ] **Step 1: Write the failing tests**

```dart
group('InstructorCoursesCubit', () {
  blocTest<InstructorCoursesCubit, InstructorCoursesState>(
    'should emit Success with courses filtered by instructor',
    build: () { when(() => repo.getCourses(instructorId: 'i1')).thenAnswer((_) async => [course]); return InstructorCoursesCubit(repo); },
    act: (c) => c.load('i1'),
    expect: () => [const InstructorCoursesInProgress(), InstructorCoursesSuccess([course])],
  );
  blocTest(... 'should emit Failure when repository throws' ...);
});
```

  Widget test `InstructorReviewsScreen should show empty state when preview disabled` (`skip: kPreviewDataEnabled`, chạy với `--dart-define=PREVIEW_DATA=false`): `find.text('Trần Thị Bích') → findsNothing`, `find.text('Chưa có đánh giá') → findsOneWidget`. Widget test `should show empty state when instructor has no courses`: cubit Success([]) → text trống.

- [ ] **Step 2: Run** — Expected: FAIL.
- [ ] **Step 3: Implement**, chạy build_runner (retrofit).
- [ ] **Step 4: Run** `flutter test test/features/student` và với `--dart-define=PREVIEW_DATA=false` — Expected: PASS.
- [ ] **Step 5: Commit** `fix(instructor): lay khoa hoc that va an danh gia mau o prod`

---

### Task 4: Ghi chú bài học dùng API thật

**Files:**
- Modify: `lib/features/course/data/course_api_client.dart` — thêm `GET/POST /api/lessons/{lessonId}/notes`, `PUT/DELETE /api/notes/{id}` (backend `internal/router/note_router.go:16-20`)
- Create: `lib/features/student/data/models/lesson_note_model.dart` (freezed, field theo DTO backend — đọc `internal/dto/*note*` trước)
- Create: `lib/features/student/bloc/lesson_notes/lesson_notes_cubit.dart` (+ state)
- Modify: `lib/features/student/presentation/learning/lesson_detail/widgets/lesson_notes_section.dart:30-45` — bỏ `_notes` cứng và `_currentTimestamp = '02:45'`; timestamp lấy từ vị trí video hiện tại (truyền vào qua constructor `Duration Function()? currentPosition`)
- Test: `test/features/student/bloc/lesson_notes_cubit_test.dart`

**Interfaces:**
- Produces: `LessonNotesCubit(StudentRepository repo)` với `load(String lessonId)`, `add(String lessonId, String content, {int? timestampSeconds})`, `remove(String noteId)`; state single-class `LessonNotesState { LessonNotesStatus status; List<LessonNoteModel> notes; String? error; }`.
- Khi `kPreviewDataEnabled && MockCourseDetailData.isMockLessonId(lessonId)` → trả 2 note mẫu cũ (giữ demo).

- [ ] **Step 1: Write the failing tests** — `should load notes from repository`, `should append note after add succeeds`, `should keep list and set error when add fails`.
- [ ] **Step 2: Run** — Expected: FAIL.
- [ ] **Step 3: Implement**, build_runner.
- [ ] **Step 4: Run** `flutter test test/features/student` — Expected: PASS.
- [ ] **Step 5: Commit** `feat(lesson): luu ghi chu bai hoc qua api`

---

### Task 5: Gợi ý tìm kiếm, nút giả, badge thông báo

**Files:**
- Modify: `lib/features/student/bloc/search/search_state.dart:32-38` — default `trendingKeywords = kPreviewDataEnabled ? [...5 từ cũ] : const []` (đổi `this.trendingKeywords = const [...]` thành tham số nullable rồi gán trong initializer)
- Modify: `lib/features/student/domain/search_recommendation_engine.dart:158` — `_curatedFallbackCourses()` trả `const []` khi `!kPreviewDataEnabled`
- Modify: `lib/features/student/presentation/learning/lesson_detail/widgets/lesson_documents_section.dart:143` — ẩn nút "Tải tất cả" khi `!kPreviewDataEnabled` (download thật để Backlog)
- Modify: `lib/features/student/presentation/student_shell.dart:76` — `notificationCount` lấy từ `StudentRepository.getUnreadNotificationCount()` (đã có), load một lần trong `initState` qua cubit nhỏ hoặc `NotificationBloc` nếu shell đã có
- Test: `test/features/student/domain/search_recommendation_engine_test.dart`, `test/features/student/bloc/search/search_state_test.dart`

- [ ] **Step 1: Write the failing tests** — `fallback should be empty when preview disabled` và `SearchState trending should be empty when preview disabled` (cả hai `skip: kPreviewDataEnabled`, chạy với `--dart-define=PREVIEW_DATA=false`); `fallback should contain curated courses when preview enabled`.
- [ ] **Step 2: Run** với `--dart-define=PREVIEW_DATA=false` — Expected: FAIL.
- [ ] **Step 3: Implement.** Kiểm tra `student_shell_test.dart` vẫn stub `getUnreadNotificationCount`.
- [ ] **Step 4: Run** `flutter test test/features/student` cả 2 chế độ — Expected: PASS.
- [ ] **Step 5: Commit** `fix(student): an goi y mau va nut gia o prod, badge thong bao that`

---

## Phase 2 — Tách file lớn (không đổi hành vi)

### Task 6: Tách mock data khỏi repository phụ huynh

**Files:**
- Create: `lib/features/parent/data/mock/parent_learning_mock_data.dart`, `parent_schedule_mock_data.dart`, `parent_payment_mock_data.dart`
- Modify: `parent/repository/parent_learning_repository_impl.dart` (1051 dòng — các hàm `_mock*`/`_generate*` từ dòng ~600), `parent_schedule_repository_impl.dart` (từ dòng 321 "MOCK DATA GENERATORS"), `parent_payment_repository_impl.dart` (`_generateSampleInvoices`)

**Interfaces:**
- Mỗi file mock: `abstract final class ParentLearningMockData { static List<...> ...(String childId); }` — chữ ký trả về giữ nguyên kiểu mà hàm private cũ trả. Repository gọi `ParentLearningMockData.xxx(...)` thay hàm private. Dùng `ParentMockIds` (Task 1).
- Mục tiêu: mỗi repository impl < 400 dòng.

- [ ] **Step 1: Run** `flutter test test/features/parent test/screens > before.txt` — baseline PASS.
- [ ] **Step 2: Move code** (cắt/dán, không sửa logic).
- [ ] **Step 3: Run** lại — Expected: cùng số test PASS; `wc -l` 3 repository < 400.
- [ ] **Step 4: Commit** `refactor(parent): tach mock data khoi repository`

### Task 7: Tách widget lớn

**Files:**
- `lib/features/student/presentation/achievement/widgets/academic_level_roadmap.dart` (1253) → thư mục `achievement/widgets/roadmap/` (mỗi widget private lớn thành file public riêng: node, connector, legend, header)
- `lib/features/student/presentation/learning/explore_courses_screen.dart` (1093) → `learning/explore/` (filter bar, section list, card)
- `lib/features/parent/presentation/learning/course_detail/parent_course_detail_screen.dart` (956) → `course_detail/widgets/`
- `lib/features/parent/presentation/home/widgets/learning_analytics_card.dart` (825) → `home/widgets/analytics/`

**Interfaces:** Chỉ đổi `_Foo` → `Foo` (public, cùng constructor) khi chuyển file. Không đổi tham số, không đổi layout. Mục tiêu mỗi file < 500 dòng.

- [ ] **Step 1: Baseline** `flutter test test/screens test/features/student/presentation test/features/parent` — PASS.
- [ ] **Step 2: Tách từng file, sau mỗi file chạy lại test của file đó.**
- [ ] **Step 3: Run** baseline lại + `flutter analyze` các thư mục mới — Expected: PASS, không warning mới.
- [ ] **Step 4: Commit** `refactor(ui): tach widget lon thanh file nho`

---

## Phase 3 — Làm cùng đợt release prod (đang để Backlog theo user)

### Task 8: Chỉ đóng gói `.env` của đúng môi trường

**Files:**
- Modify: `pubspec.yaml:79-82` — asset theo flavor:

```yaml
    - path: .env.dev
      flavors: [dev]
    - path: .env.qa
      flavors: [qa]
    - path: .env.prod
      flavors: [prod]
```

- Modify: `Makefile:44` (`runQa` → `--flavor qa`), `:51` (`apk` → `--flavor prod`), `.github/workflows/release.yml:49,53` → `--flavor prod` (trùng mục F11 Backlog plan trước — làm chung)
- Modify: `README.md` mục "Môi trường & flavor": ENV phải khớp flavor

**Interfaces:** Quy tắc mới: `--flavor X` luôn đi với `--dart-define=ENV=X`. `main.dart` không đổi.

- [ ] **Step 1:** Kiểm tra iOS có scheme theo flavor (`ios/Runner.xcodeproj/xcshareddata/xcschemes`). Không có → asset flavored sẽ bị loại khỏi build iOS → giữ khai báo cũ cho iOS là không được; khi đó ghi `Ruling:` và chỉ áp dụng sau khi tạo scheme iOS.
- [ ] **Step 2:** `flutter build apk --flavor prod --release --dart-define=ENV=prod`, rồi `unzip -l build/app/outputs/flutter-apk/app-prod-release.apk | grep "\.env"` — Expected: chỉ `.env.prod`.
- [ ] **Step 3:** `make runDev` vẫn chạy, `flutter test` PASS (test không load dotenv).
- [ ] **Step 4: Commit** `fix(build): chi dong goi env cua flavor dang build`

### Task 9: App ID và tên app chính thức

**Cần user quyết định trước:** package name chính thức (vd `vn.study40.app`) và tên hiển thị (vd `40Study`). Chưa có quyết định → không làm task này.

**Files:** `android/app/build.gradle.kts:19,34` (`namespace`, `applicationId`), thư mục Kotlin `android/app/src/main/kotlin/dev/shtanko/...` (đổi package của `MainActivity`), `android/app/src/main/AndroidManifest.xml:17` (`android:label`), `ios/Runner.xcodeproj/project.pbxproj` (3 dòng `PRODUCT_BUNDLE_IDENTIFIER`), `pubspec.yaml:2` (`description`), `lib/l10n/*.arb` nếu có `appTitle`.

- [ ] **Step 1:** Thay giá trị; `grep -rn "shtanko\|flutter_bloc_app_template\|template-flutter" android ios pubspec.yaml lib` — Expected: không còn.
- [ ] **Step 2:** `flutter build apk --flavor dev --debug --dart-define=ENV=dev` và `aapt dump badging ... | grep package` — Expected: package mới + hậu tố `.dev`.
- [ ] **Step 3: Commit** `chore(app): doi application id va ten app chinh thuc`

---

## Phase 4 — Hardcode giao diện (làm dần theo feature)

### Task 10: Màu về theme token

**Files:** bắt đầu với 3 file nhiều nhất: `academic_level_roadmap.dart` (66), `parent_course_detail_screen.dart` (59), `parent_homework_detail_screen.dart` (58). Token mới đặt trong `lib/theme/app_colors.dart` (extension trên `ColorScheme` như `cs.blue600` đang dùng).

**Interfaces:** Quy tắc: màu xuất hiện ≥ 3 lần trong codebase → thành token có tên theo vai trò (`cs.statusSuccessBg`, không đặt `cs.green50`); màu dùng 1 lần trong illustration có thể giữ. Mỗi token phải có giá trị cho dark mode.

- [ ] **Step 1:** `grep -rhoE "Color\(0x[0-9A-Fa-f]{8}\)" lib --include=*.dart | sort | uniq -c | sort -rn | head -30` → chọn danh sách token.
- [ ] **Step 2:** Thêm token, thay trong 3 file trên.
- [ ] **Step 3:** `flutter test test/screens` PASS; chụp so sánh light/dark bằng `make performance_screens SCREEN=...` hoặc chạy app.
- [ ] **Step 4: Commit** `refactor(theme): chuyen mau cung sang token`

### Task 11: Chuỗi về l10n, bỏ ngôn ngữ thừa

**Files:**
- `lib/app/localization.dart:9-14` — `appSupportedLocales` chỉ giữ `vi`, `en` nếu team xác nhận không hỗ trợ `de/pt/uk`; xóa `lib/l10n/intl_{de,pt,uk}.arb` + file generated tương ứng (`flutter pub run intl_utils:generate` / `make localize`)
- Feature giáo viên trước (nhiều `Text('...')` nhất): `teacher/presentation/advanced/teacher_live_sessions_screen.dart` (18), `schedule/teacher_attendance_screen.dart` (16), `advanced/teacher_contest_detail_screen.dart` (15), `schedule/teacher_session_screen.dart` (13)

**Interfaces:** Key arb theo dạng `teacherLiveSessionsTitle` (feature + màn + vai trò). Thêm vào `intl_vi.arb` và `intl_en.arb`.

- [ ] **Step 1:** Hỏi team về `de/pt/uk` (template cũ). Có xác nhận → xóa.
- [ ] **Step 2:** Chuyển chuỗi 4 màn trên sang `l10n`; `make localize`.
- [ ] **Step 3:** `flutter test test/features/teacher test/screens` PASS.
- [ ] **Step 4: Commit** `refactor(l10n): chuyen chuoi man giao vien sang arb`

---

## Kiểm tra cuối (sau mỗi Phase)

- [ ] `flutter analyze --no-fatal-infos` (trong `W:\`) — không error/warning mới so với trước Phase.
- [ ] `flutter test` và `flutter test --dart-define=PREVIEW_DATA=false` — PASS.
- [ ] Chạy app `ENV=prod`: portfolio, giảng viên, ghi chú, tìm kiếm không còn tên/số liệu giả ("Linh Nguyen", "Trần Thị Bích", "1248", "Nguyễn Văn A").

## Backlog (ngoài plan này)

- API review theo giảng viên + rating tổng hợp (backend chưa có) → khi có, thay mock ở Task 3.
- API portfolio (`GET /api/student/portfolio`) → thay Task 2.
- Download tài liệu bài học thật ("Tải tất cả").
- API liên kết con (`POST /api/family/link-requests` đã có ở backend `parent_link_router.go:33`) → nối `add_child_screen.dart:162`.
- `fontSize:` cứng (849 chỗ) → `textTheme`, làm cùng Task 10 theo từng feature.
- Thống nhất phiên bản Flutter cho team và CI (đang `channel: stable`), đổi tên thư mục dự án không dấu.
