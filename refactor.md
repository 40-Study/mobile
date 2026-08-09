# 40Study Flutter App - Refactoring Guide

> Tài liệu này phân tích chi tiết các vấn đề trong codebase và hướng dẫn cách khắc phục từng vấn đề.

---

## Mục lục

1. [P0 - Critical: Debug Code trong Production](#1-p0---critical-debug-code-trong-production)
2. [P0 - Critical: Hardcoded Debug Flag](#2-p0---critical-hardcoded-debug-flag)
3. [P1 - High: context.watch tại Root Widget](#3-p1---high-contextwatch-tại-root-widget)
4. [P1 - High: Unused Dependencies](#4-p1---high-unused-dependencies)
5. [P1 - High: API Layer Architecture](#5-p1---high-api-layer-architecture)
6. [P2 - Medium: Global Bloc Providers](#6-p2---medium-global-bloc-providers)
7. [P2 - Medium: Inconsistent DI Pattern](#7-p2---medium-inconsistent-di-pattern)
8. [P2 - Medium: Nested BlocBuilder](#8-p2---medium-nested-blocbuilder)
9. [P3 - Low: Dead Code và Unused Fields](#9-p3---low-dead-code-và-unused-fields)
10. [P3 - Low: Duplicate Theme Logic](#10-p3---low-duplicate-theme-logic)
11. [P3 - Low: Magic Numbers](#11-p3---low-magic-numbers)
12. [P3 - Low: Empty Catch Blocks](#12-p3---low-empty-catch-blocks)
13. [P3 - Low: Redundant Cubit Methods](#13-p3---low-redundant-cubit-methods)
14. [P2 - Medium: Dead Code & Unused Components](#14-p2---medium-dead-code--unused-components)
15. [P2 - Medium: Duplicate Components Cần Consolidate](#15-p2---medium-duplicate-components-cần-consolidate)
16. [P3 - Low: Opportunities for Shared Components](#16-p3---low-opportunities-for-shared-components)

---

## 1. P0 - Critical: Debug Code trong Production

### Vấn đề

Có **28+ lệnh `print()`** rải rác trong các file quan trọng:

**Files bị ảnh hưởng:**
- `lib/features/auth/bloc/auth/auth_bloc.dart` (14 lệnh)
- `lib/features/auth/repository/auth_repository_impl.dart` (6 lệnh)
- `lib/features/auth/bloc/select_role/select_role_cubit.dart` (8 lệnh)

**Ví dụ code hiện tại:**
```dart
// auth_bloc.dart:46-67
print('📋 Fetched ${profiles.length} profiles after login');
for (final p in profiles) {
  print('📋 Profile: ${p.roleName} - ${p.type} - systemRoleId: ${p.systemRoleId}');
}
print('📋 Looking for profile matching activeRole: ${activeRole.name}');
```

### Tác động

| Aspect | Impact |
|--------|--------|
| Performance | Mỗi print() gọi I/O operation, làm chậm app |
| Security | Log có thể chứa token, user data, role info |
| Bundle Size | String literals tăng kích thước APK/IPA |
| Production Debugging | Console bị spam, khó tìm log thật sự quan trọng |

### Giải pháp

**Bước 1: Tạo Logger Service**

```dart
// lib/core/logger/app_logger.dart
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

abstract class AppLogger {
  static final Talker _talker = Talker(
    settings: TalkerSettings(
      enabled: kDebugMode, // Auto-disable in release
      useConsoleLogs: true,
    ),
  );

  /// Debug log - chỉ hiện trong debug mode
  static void d(String message, [Object? data]) {
    _talker.debug(message, data);
  }

  /// Info log
  static void i(String message, [Object? data]) {
    _talker.info(message, data);
  }

  /// Warning log
  static void w(String message, [Object? data]) {
    _talker.warning(message, data);
  }

  /// Error log - luôn ghi, có thể gửi lên crash reporting
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _talker.error(message, error, stackTrace);
  }

  /// Log cho Auth flow (có thể tắt riêng)
  static void auth(String message, [Object? data]) {
    if (kDebugMode) {
      _talker.logTyped(AuthLog(message, data));
    }
  }
}

class AuthLog extends TalkerLog {
  AuthLog(String message, [this.data]) : super(message);
  final Object? data;

  @override
  String get title => 'AUTH';

  @override
  AnsiPen get pen => AnsiPen()..cyan();
}
```

**Bước 2: Replace tất cả print() statements**

```dart
// TRƯỚC
print('📋 Fetched ${profiles.length} profiles after login');

// SAU
AppLogger.auth('Fetched ${profiles.length} profiles after login');
```

**Bước 3: Script tự động tìm và replace**

Chạy command sau để tìm tất cả print():
```bash
grep -rn "print(" lib/ --include="*.dart" | grep -v ".g.dart" | grep -v ".freezed.dart"
```

**Bước 4: Thêm lint rule để ngăn print() trong tương lai**

```yaml
# analysis_options.yaml
linter:
  rules:
    avoid_print: true
```

---

## 2. P0 - Critical: Hardcoded Debug Flag

### Vấn đề

**File:** `lib/bloc/init/init_bloc.dart:10-11`

```dart
const Duration _splashDuration = Duration(milliseconds: 2200);
// TODO: Đổi về false khi không cần test onboarding
const bool _alwaysShowOnboarding = true;  // <-- NGUY HIỂM
```

### Tác động

- User production sẽ luôn thấy onboarding screen
- Dễ quên đổi lại khi release
- Không có cơ chế kiểm soát

### Giải pháp

**Bước 1: Sử dụng Environment Variables**

```dart
// lib/config/app_config.dart
class AppConfig {
  AppConfig({required this.envFileName});

  final String envFileName;

  // Thêm config cho debug flags
  bool get forceShowOnboarding {
    // Chỉ cho phép trong debug/qa, không bao giờ trong prod
    if (Environment.instance.buildType == BuildType.release) {
      return false;
    }
    return dotenv.getBool('FORCE_SHOW_ONBOARDING', fallback: false);
  }
}
```

**Bước 2: Cập nhật .env files**

```env
# .env.dev
FORCE_SHOW_ONBOARDING=true

# .env.qa
FORCE_SHOW_ONBOARDING=true

# .env.prod - KHÔNG BAO GIỜ đặt true
FORCE_SHOW_ONBOARDING=false
```

**Bước 3: Cập nhật InitBloc**

```dart
// lib/bloc/init/init_bloc.dart
class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc({
    required OnboardingRepository onboardingRepository,
    required AuthRepository authRepository,
    required AppConfig appConfig,  // Inject config
  }) : _onboardingRepository = onboardingRepository,
       _authRepository = authRepository,
       _appConfig = appConfig,
       super(InitInitial()) {
    on<InitStarted>(_onStarted);
  }

  final OnboardingRepository _onboardingRepository;
  final AuthRepository _authRepository;
  final AppConfig _appConfig;

  Future<void> _onStarted(InitStarted event, Emitter<InitState> emit) async {
    await Future<void>.delayed(_splashDuration);

    // Debug flag được kiểm soát qua config
    if (_appConfig.forceShowOnboarding) {
      emit(InitOpenOnboarding());
      return;
    }

    final seen = await _onboardingRepository.hasSeenOnboarding();
    if (!seen) {
      emit(InitOpenOnboarding());
      return;
    }

    final loggedIn = await _authRepository.isLoggedIn();
    if (loggedIn) {
      emit(InitOpenApp());
    } else {
      emit(InitOpenLogin());
    }
  }
}
```

**Bước 4: Thêm CI check để ngăn hardcoded flags**

```yaml
# .github/workflows/check.yml
- name: Check for debug flags
  run: |
    if grep -rn "alwaysShow\|forceShow\|skipAuth" lib/ --include="*.dart" | grep -v "config"; then
      echo "Found hardcoded debug flags!"
      exit 1
    fi
```

---

## 3. P1 - High: context.watch tại Root Widget

### Vấn đề

**File:** `lib/app/app.dart:45-54`

```dart
return MaterialApp(
  debugShowCheckedModeBanner: kDebugMode,
  restorationScopeId: 'app',
  key: Key('${context.watch<ThemeCubit>().themeMode}'),  // ISSUE 1
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: appSupportedLocales,
  onGenerateTitle: (BuildContext context) => context.appTitle,
  theme: theme.light(),
  darkTheme: theme.dark(),
  themeMode: context.watch<ThemeCubit>().themeMode,      // ISSUE 2
  // ...
);
```

### Tác động

| Issue | Impact |
|-------|--------|
| `context.watch` tại root build | Toàn bộ `_AppState.build()` re-run khi theme đổi |
| `Key` dựa trên themeMode | Force dispose và recreate toàn bộ MaterialApp widget tree |
| Không scope rebuild | Tất cả child widgets đều rebuild không cần thiết |

**Visualize vấn đề:**
```
Theme changed
    ↓
context.watch triggers rebuild
    ↓
MaterialApp gets new Key
    ↓
Flutter disposes OLD MaterialApp (+ all children)
    ↓
Flutter creates NEW MaterialApp
    ↓
ALL navigation state lost
ALL child widgets rebuilt
```

### Giải pháp

**Cách 1: Sử dụng BlocBuilder với scope cụ thể**

```dart
// lib/app/app.dart
@override
Widget build(BuildContext context) => MultiRepositoryProvider(
  providers: [...AppRepositoryProviders.providers()],
  child: MultiBlocProvider(
    providers: [...AppBlocProviders.providers()],
    child: Builder(
      builder: (context) {
        _listenSessionExpired(context);

        return BlocBuilder<ThemeCubit, AppThemeSettings>(
          // Chỉ rebuild MaterialApp khi theme thực sự đổi
          buildWhen: (prev, curr) => prev.darkTheme != curr.darkTheme,
          builder: (context, themeSettings) {
            final navigator = NavigationService.of(context);
            final textTheme = createTextTheme(context: context);
            final theme = MaterialTheme(textTheme);

            return MaterialApp(
              debugShowCheckedModeBanner: kDebugMode,
              restorationScopeId: 'app',
              // KHÔNG dùng Key dựa trên theme
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: appSupportedLocales,
              onGenerateTitle: (BuildContext context) => context.appTitle,
              theme: theme.light(),
              darkTheme: theme.dark(),
              themeMode: _mapThemeMode(themeSettings),
              navigatorKey: appNavigatorKey,
              onGenerateRoute: navigator.onGenerateRoute,
              builder: (_, child) => _buildListeners(context, navigator, child),
            );
          },
        );
      },
    ),
  ),
);

ThemeMode _mapThemeMode(AppThemeSettings settings) {
  return switch (settings.darkTheme.darkThemeValue) {
    DarkThemePreference.on => ThemeMode.dark,
    DarkThemePreference.off => ThemeMode.light,
    _ => ThemeMode.system,
  };
}

Widget _buildListeners(BuildContext context, NavigationService navigator, Widget? child) {
  return MultiBlocListener(
    listeners: [
      BlocListener<InitBloc, InitState>(
        listener: (_, state) {
          if (state is InitOpenApp) {
            navigator.pushAndRemoveAll(Routes.app);
          } else if (state is InitOpenOnboarding) {
            navigator.pushAndRemoveAll(Routes.onboarding);
          } else if (state is InitOpenLogin) {
            navigator.pushAndRemoveAll(Routes.login);
          }
        },
      ),
      BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            prev is! AuthUnauthenticated && curr is AuthUnauthenticated,
        listener: (_, state) {
          if (state is AuthUnauthenticated) {
            navigator.pushAndRemoveAll(Routes.login);
          }
        },
      ),
    ],
    child: child ?? const SizedBox.shrink(),
  );
}
```

**Cách 2: Tách ThemeBuilder riêng (Recommended)**

```dart
// lib/app/theme_builder.dart
class ThemeBuilder extends StatelessWidget {
  const ThemeBuilder({super.key, required this.child});

  final Widget Function(ThemeData light, ThemeData dark, ThemeMode mode) child;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, AppThemeSettings, ThemeMode>(
      selector: (state) {
        return switch (state.darkTheme.darkThemeValue) {
          DarkThemePreference.on => ThemeMode.dark,
          DarkThemePreference.off => ThemeMode.light,
          _ => ThemeMode.system,
        };
      },
      builder: (context, themeMode) {
        final textTheme = createTextTheme(context: context);
        final theme = MaterialTheme(textTheme);
        return child(theme.light(), theme.dark(), themeMode);
      },
    );
  }
}

// lib/app/app.dart
@override
Widget build(BuildContext context) => MultiRepositoryProvider(
  providers: [...AppRepositoryProviders.providers()],
  child: MultiBlocProvider(
    providers: [...AppBlocProviders.providers()],
    child: Builder(
      builder: (context) {
        _listenSessionExpired(context);
        final navigator = NavigationService.of(context);

        return ThemeBuilder(
          child: (lightTheme, darkTheme, themeMode) => MaterialApp(
            debugShowCheckedModeBanner: kDebugMode,
            restorationScopeId: 'app',
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: appSupportedLocales,
            onGenerateTitle: (context) => context.appTitle,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            navigatorKey: appNavigatorKey,
            onGenerateRoute: navigator.onGenerateRoute,
            builder: (_, child) => _buildListeners(context, navigator, child),
          ),
        );
      },
    ),
  ),
);
```

---

## 4. P1 - High: Unused Dependencies

### Vấn đề

**File:** `pubspec.yaml`

```yaml
dependencies:
  # HTTP clients - chỉ cần 1
  http: ^1.4.0           # Không dùng
  dio: ^5.8.0+1          # Đang dùng

  # State management - chỉ cần 1
  provider: ^6.1.5       # Không dùng (chỉ dùng BlocProvider)
  flutter_bloc: ^9.0.0   # Đang dùng

  # Logging - chỉ cần 1
  logger: ^2.5.0         # Không dùng
  talker: ^5.0.0         # Đang dùng
  talker_logger: ^5.0.0
  talker_dio_logger: ^5.0.0
  talker_bloc_logger: ^5.0.0

  # Functional programming
  dartz: ^0.10.1         # Kiểm tra có dùng không

  # Deprecated/unused
  effective_dart: ^1.3.2  # Deprecated, đã được thay bằng lints
```

### Tác động

| Package | Size Impact | Notes |
|---------|-------------|-------|
| http | ~50KB | Hoàn toàn không dùng |
| provider | ~30KB | Chỉ dùng SingleChildWidget |
| logger | ~20KB | Dùng talker thay thế |
| effective_dart | ~10KB | Deprecated |
| dartz | ~100KB | Cần audit xem có dùng không |

**Tổng cộng:** ~200KB+ có thể giảm

### Giải pháp

**Bước 1: Audit dependencies**

```bash
# Tìm xem package nào thực sự được import
grep -rn "import 'package:http" lib/
grep -rn "import 'package:provider" lib/
grep -rn "import 'package:logger" lib/
grep -rn "import 'package:dartz" lib/
```

**Bước 2: Kiểm tra provider usage**

```dart
// Hiện tại chỉ import SingleChildWidget
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

// Có thể thay bằng flutter_bloc's own type
import 'package:flutter_bloc/flutter_bloc.dart';
// BlocProvider và RepositoryProvider đều implement SingleChildWidget
```

**Bước 3: Cập nhật pubspec.yaml**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Core
  flutter_bloc: ^9.0.0
  bloc: ^9.0.0
  equatable: ^2.0.7
  freezed_annotation: ^3.0.0

  # Network
  dio: ^5.8.0+1
  retrofit: ^4.4.2

  # Storage
  shared_preferences: ^2.5.2
  path_provider: ^2.1.5

  # DI
  get_it: 9.2.1
  injectable: ^2.5.0

  # Logging (chỉ giữ talker ecosystem)
  talker: ^5.0.0
  talker_dio_logger: ^5.0.0
  talker_bloc_logger: ^5.0.0

  # UI
  google_fonts: 8.0.2
  flutter_svg: ^2.0.17
  gap: ^3.0.1
  animations: ^2.0.7
  rive: ^0.13.20

  # Utils
  intl: ^0.20.2
  collection: ^1.18.0
  uuid: ^4.5.3
  url_launcher: ^6.3.2
  flutter_dotenv: ^5.2.1
  package_info_plus: ^9.0.0
  geolocator: ^13.0.1

  # Chỉ giữ nếu thực sự dùng Either/Option
  # dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.15
  injectable_generator: ^2.9.1
  flutter_gen_runner: ^5.9.0
  json_serializable: ^6.11.2
  freezed: ^3.2.3
  bloc_test: ^10.0.0
  mocktail: ^1.0.4

  # Linting - dùng flutter_lints thay vì nhiều package
  flutter_lints: ^6.0.0
```

**Bước 4: Verify và clean**

```bash
flutter pub get
flutter pub outdated
flutter analyze
```

---

## 5. P1 - High: API Layer Architecture

### Vấn đề

API layer hiện tại có nhiều vấn đề khiến việc debug và maintain khó khăn:

**Files liên quan:**
- `lib/features/auth/data/auth_api_client.dart`
- `lib/features/auth/repository/auth_repository_impl.dart`
- `lib/features/auth/data/error_handler.dart`
- `lib/features/auth/data/auth_interceptor.dart`

### 5.1 API Client trả về `dynamic`

```dart
// auth_api_client.dart - HIỆN TẠI
@POST('/api/auth/login')
Future<HttpResponse<dynamic>> login(@Body() Map<String, dynamic> body);

@GET('/api/auth/me')
Future<HttpResponse<dynamic>> getMe();
```

**Vấn đề:**
- Không có type safety
- IDE không thể autocomplete
- Runtime errors thay vì compile-time errors
- Repository phải parse data thủ công

### 5.2 Data Extraction Logic Lặp Lại

```dart
// auth_repository_impl.dart - phải làm điều này ở MỌI method
dynamic _extractData(dynamic responseData) {
  if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
    return responseData['data'];
  }
  return responseData;
}

// Rồi gọi khắp nơi:
final data = _extractData(response.data) as Map<String, dynamic>;
final loginResponse = LoginResponse.fromJson(data);
```

### 5.3 Error Handling Phân Tán

```dart
// Mỗi bloc phải tự catch và handle
// login_bloc.dart
try {
  final response = await _authRepository.login(...);
  // ...
} on DioException catch (e) {
  emit(LoginFailure(AuthErrorHandler.extractMessage(e)));
} catch (e) {
  emit(LoginFailure('Có lỗi xảy ra: $e'));
}

// register_bloc.dart - DUPLICATE
try {
  await _authRepository.registerRequest(...);
  // ...
} on DioException catch (e) {
  emit(RegisterFailure(AuthErrorHandler.extractMessage(e)));
} catch (e) {
  emit(RegisterFailure('Có lỗi xảy ra: $e'));
}
```

### 5.4 Empty Catch trong Interceptor

```dart
// auth_interceptor.dart:110
Future<bool> _tryRefreshToken() async {
  try {
    // ...
  } catch (_) {
    return false;  // Silent failure - không biết tại sao fail
  }
}
```

### Tác động

| Issue | Impact |
|-------|--------|
| No type safety | Bugs chỉ phát hiện runtime |
| Duplicate error handling | Code bloat, inconsistent UX |
| Silent failures | Khó debug production issues |
| Manual parsing | Dễ sai, khó maintain |

---

### Giải pháp: Tách API Layer Thành 3 Tầng

```
┌─────────────────────────────────────────────────────────────┐
│                        BLOC/CUBIT                          │
│  - Chỉ handle business logic                               │
│  - Nhận Result<T, Failure> từ Repository                   │
│  - KHÔNG biết về Dio, HTTP, JSON                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       REPOSITORY                            │
│  - Orchestrate data sources                                 │
│  - Transform ApiResponse → Domain Model                     │
│  - Wrap trong Result type                                   │
│  - Handle caching (nếu cần)                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DATA SOURCE                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  ApiClient      │    │  LocalStorage   │                │
│  │  (Retrofit)     │    │  (SharedPrefs)  │                │
│  └─────────────────┘    └─────────────────┘                │
│           │                                                 │
│           ▼                                                 │
│  ┌─────────────────────────────────────────┐               │
│  │  NetworkClient (Dio + Interceptors)     │               │
│  │  - Auth token injection                  │               │
│  │  - Error transformation                  │               │
│  │  - Logging                               │               │
│  │  - Retry logic                           │               │
│  └─────────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

---

### Bước 1: Tạo Core Network Module

```dart
// lib/core/network/network_client.dart
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class NetworkClient {
  NetworkClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Order matters: Auth → Logger → Error
    dio.interceptors.addAll([
      AuthInterceptor(...),
      TalkerDioLogger(...),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  /// Reset instance (useful for testing or logout)
  static void reset() {
    _instance?.close();
    _instance = null;
  }
}
```

---

### Bước 2: Tạo Failure Types

```dart
// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure({this.message, this.code});

  final String? message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Network không khả dụng
class NetworkFailure extends Failure {
  const NetworkFailure([String? message]) : super(message: message ?? 'Không có kết nối mạng');
}

/// Server trả về lỗi (4xx, 5xx)
class ServerFailure extends Failure {
  const ServerFailure({
    super.message,
    super.code,
    this.statusCode,
    this.errors,
  });

  final int? statusCode;
  final List<ValidationError>? errors;

  @override
  List<Object?> get props => [message, code, statusCode, errors];
}

/// Validation errors từ API
class ValidationError extends Equatable {
  const ValidationError({required this.field, required this.message});

  final String field;
  final String message;

  @override
  List<Object?> get props => [field, message];
}

/// Token hết hạn, cần login lại
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super(message: 'Phiên đăng nhập hết hạn');
}

/// Lỗi không xác định
class UnknownFailure extends Failure {
  const UnknownFailure([String? message]) : super(message: message ?? 'Đã có lỗi xảy ra');
}

/// Cache/Storage failure
class CacheFailure extends Failure {
  const CacheFailure([String? message]) : super(message: message);
}
```

---

### Bước 3: Tạo Result Type

```dart
// lib/core/error/result.dart

/// A value that is either a success or a failure.
///
/// Usage:
/// ```dart
/// final result = await repository.login(email, password);
/// result.when(
///   success: (user) => emit(LoginSuccess(user)),
///   failure: (error) => emit(LoginFailure(error.message)),
/// );
/// ```
sealed class Result<T, E> {
  const Result();

  /// Create a success result
  const factory Result.success(T value) = Success<T, E>;

  /// Create a failure result
  const factory Result.failure(E error) = Failure<T, E>;

  /// Pattern match on the result
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  });

  /// Map success value
  Result<R, E> map<R>(R Function(T value) transform);

  /// Map failure value
  Result<T, R> mapFailure<R>(R Function(E error) transform);

  /// Get value or null
  T? get valueOrNull;

  /// Get error or null
  E? get errorOrNull;

  /// Is this a success?
  bool get isSuccess;

  /// Is this a failure?
  bool get isFailure;
}

class Success<T, E> extends Result<T, E> {
  const Success(this.value);
  final T value;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) => success(value);

  @override
  Result<R, E> map<R>(R Function(T value) transform) {
    return Result.success(transform(value));
  }

  @override
  Result<T, R> mapFailure<R>(R Function(E error) transform) {
    return Result.success(value);
  }

  @override
  T? get valueOrNull => value;

  @override
  E? get errorOrNull => null;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;
}

class Failure<T, E> extends Result<T, E> {
  const Failure(this.error);
  final E error;

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) => failure(error);

  @override
  Result<R, E> map<R>(R Function(T value) transform) {
    return Result.failure(error);
  }

  @override
  Result<T, R> mapFailure<R>(R Function(E error) transform) {
    return Result.failure(transform(error));
  }

  @override
  T? get valueOrNull => null;

  @override
  E? get errorOrNull => error;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;
}

/// Type alias for common Result with Failure
typedef ApiResult<T> = Result<T, Failure>;
```

---

### Bước 4: Tạo Error Interceptor

```dart
// lib/core/network/error_interceptor.dart
import 'package:dio/dio.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/logger/app_logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e(
      'API Error: ${err.requestOptions.path}',
      err,
      err.stackTrace,
    );

    // Transform to our Failure type và attach vào error
    final failure = _mapDioError(err);

    // Attach failure vào error để Repository có thể dùng
    err.error = failure;

    handler.next(err);
  }

  Failure _mapDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Kết nối quá chậm, vui lòng thử lại');

      case DioExceptionType.connectionError:
        return const NetworkFailure('Không thể kết nối đến server');

      case DioExceptionType.badResponse:
        return _handleBadResponse(err.response);

      case DioExceptionType.cancel:
        return const UnknownFailure('Request đã bị hủy');

      default:
        return UnknownFailure(err.message);
    }
  }

  Failure _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    // Parse error message từ response
    String? message;
    String? code;
    List<ValidationError>? validationErrors;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? data['error'] as String?;
      code = data['code'] as String?;

      // Parse validation errors
      final errors = data['errors'];
      if (errors is List) {
        validationErrors = errors
            .whereType<Map<String, dynamic>>()
            .map((e) => ValidationError(
                  field: e['field'] as String? ?? '',
                  message: e['message'] as String? ?? e['error'] as String? ?? '',
                ))
            .toList();
      }
    }

    // Map theo status code
    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      403 => ServerFailure(
          message: message ?? 'Bạn không có quyền thực hiện hành động này',
          statusCode: statusCode,
        ),
      404 => ServerFailure(
          message: message ?? 'Không tìm thấy dữ liệu',
          statusCode: statusCode,
        ),
      422 => ServerFailure(
          message: message ?? 'Dữ liệu không hợp lệ',
          statusCode: statusCode,
          errors: validationErrors,
        ),
      >= 500 => ServerFailure(
          message: message ?? 'Lỗi server, vui lòng thử lại sau',
          statusCode: statusCode,
        ),
      _ => ServerFailure(
          message: message ?? 'Đã có lỗi xảy ra',
          statusCode: statusCode,
          code: code,
        ),
    };
  }
}
```

---

### Bước 5: Tạo Base API Response

```dart
// lib/core/network/api_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic wrapper cho API response
///
/// API trả về format:
/// ```json
/// {
///   "data": { ... },        // hoặc [ ... ]
///   "message": "Success",
///   "meta": { "page": 1 }   // optional
/// }
/// ```
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  const ApiResponse({
    this.data,
    this.message,
    this.meta,
  });

  final T? data;
  final String? message;
  final PaginationMeta? meta;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PaginationMeta {
  const PaginationMeta({
    this.page,
    this.pageSize,
    this.total,
    this.totalPages,
  });

  final int? page;
  @JsonKey(name: 'page_size')
  final int? pageSize;
  final int? total;
  @JsonKey(name: 'total_pages')
  final int? totalPages;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
}
```

---

### Bước 6: Tạo Typed API Client

```dart
// lib/features/auth/data/auth_api_client.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:study/core/network/api_response.dart';
import 'package:study/features/auth/data/models/models.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  // ============================================================================
  // PUBLIC APIs
  // ============================================================================

  @POST('/api/auth/register/request')
  Future<ApiResponse<void>> registerRequest(@Body() RegisterRequestDto body);

  @POST('/api/auth/register')
  Future<ApiResponse<UserModel>> registerVerify(@Body() RegisterVerifyDto body);

  @POST('/api/auth/login')
  Future<ApiResponse<LoginResponse>> login(@Body() LoginRequestDto body);

  @POST('/api/auth/select-role')
  Future<ApiResponse<AuthResponse>> selectRole(@Body() SelectRoleDto body);

  @GET('/api/auth/system-roles')
  Future<ApiResponse<List<RoleModel>>> getSystemRoles();

  @POST('/api/auth/refresh-token')
  Future<ApiResponse<TokenPair>> refreshToken(@Body() RefreshTokenDto body);

  // ============================================================================
  // PROTECTED APIs
  // ============================================================================

  @GET('/api/auth/me')
  Future<ApiResponse<UserModel>> getMe();

  @PUT('/api/auth/me')
  Future<ApiResponse<UserModel>> updateMe(@Body() UpdateUserDto body);

  @GET('/api/auth/my-roles')
  Future<ApiResponse<List<RoleModel>>> getMyRoles();

  @POST('/api/auth/switch-role')
  Future<ApiResponse<AuthResponse>> switchRole(@Body() SwitchRoleDto body);

  @GET('/api/auth/me/profiles')
  Future<ApiResponse<List<ProfileModel>>> getProfiles();

  @POST('/api/auth/me/profiles')
  Future<ApiResponse<ProfileModel>> createProfile(@Body() CreateProfileDto body);

  @DELETE('/api/auth/me/profiles/{id}')
  Future<ApiResponse<void>> deleteProfile(@Path('id') String profileId);

  @GET('/api/auth/devices')
  Future<ApiResponse<List<DeviceModel>>> getDevices();

  @POST('/api/auth/logout')
  Future<ApiResponse<void>> logout();

  @POST('/api/auth/logout-all')
  Future<ApiResponse<void>> logoutAll();
}
```

---

### Bước 7: Tạo Request DTOs

```dart
// lib/features/auth/data/dto/login_request_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/auth/data/models/device_info_model.dart';

part 'login_request_dto.freezed.dart';
part 'login_request_dto.g.dart';

@freezed
class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String email,
    required String password,
    @JsonKey(name: 'device_info') required DeviceInfoModel deviceInfo,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}

// lib/features/auth/data/dto/select_role_dto.dart
@freezed
class SelectRoleDto with _$SelectRoleDto {
  const factory SelectRoleDto({
    @JsonKey(name: 'session_token') required String sessionToken,
    @JsonKey(name: 'role_id') required String roleId,
    @JsonKey(name: 'role_type') required String roleType,
    @JsonKey(name: 'organization_id') String? organizationId,
  }) = _SelectRoleDto;

  factory SelectRoleDto.fromJson(Map<String, dynamic> json) =>
      _$SelectRoleDtoFromJson(json);
}
```

---

### Bước 8: Refactor Repository

```dart
// lib/features/auth/repository/auth_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/core/logger/app_logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthApiClient apiClient,
    required AuthStorage storage,
  })  : _api = apiClient,
        _storage = storage;

  final AuthApiClient _api;
  final AuthStorage _storage;

  @override
  Future<ApiResult<LoginResponse>> login({
    required String email,
    required String password,
    required DeviceInfoModel deviceInfo,
  }) async {
    return _safeCall(() async {
      final response = await _api.login(LoginRequestDto(
        email: email,
        password: password,
        deviceInfo: deviceInfo,
      ));

      final loginResponse = response.data!;

      // Lưu session nếu login hoàn tất
      if (loginResponse.completed && loginResponse.accessToken != null) {
        await _saveSession(loginResponse);
      }

      return loginResponse;
    });
  }

  @override
  Future<ApiResult<AuthResponse>> selectRole({
    required String sessionToken,
    required String roleId,
    required String roleType,
    String? organizationId,
  }) async {
    return _safeCall(() async {
      final response = await _api.selectRole(SelectRoleDto(
        sessionToken: sessionToken,
        roleId: roleId,
        roleType: roleType,
        organizationId: organizationId,
      ));

      var authResponse = response.data!;

      // Enrich với user data nếu cần
      authResponse = await _enrichAuthResponse(authResponse);

      await _saveSession(authResponse);
      return authResponse;
    });
  }

  @override
  Future<ApiResult<UserModel>> getMe() async {
    return _safeCall(() async {
      final response = await _api.getMe();
      return response.data!;
    });
  }

  @override
  Future<ApiResult<List<ProfileModel>>> getProfiles() async {
    return _safeCall(() async {
      final response = await _api.getProfiles();
      return response.data ?? [];
    });
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Wrapper an toàn cho tất cả API calls
  Future<ApiResult<T>> _safeCall<T>(Future<T> Function() call) async {
    try {
      final result = await call();
      return Result.success(result);
    } on DioException catch (e) {
      // Error đã được transform bởi ErrorInterceptor
      final failure = e.error is Failure
          ? e.error as Failure
          : UnknownFailure(e.message);
      return Result.failure(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error', e, stackTrace);
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Enrich auth response với thông tin bổ sung
  Future<AuthResponse> _enrichAuthResponse(AuthResponse response) async {
    var result = response;

    // Fetch user nếu chưa có
    if (result.user == null && result.accessToken != null) {
      final userResult = await getMe();
      if (userResult.isSuccess) {
        result = result.copyWith(user: userResult.valueOrNull);
      }
    }

    // Fetch active profile nếu chưa có
    if (result.activeProfile == null) {
      final profilesResult = await getProfiles();
      if (profilesResult.isSuccess) {
        final profiles = profilesResult.valueOrNull ?? [];
        if (profiles.isNotEmpty) {
          result = result.copyWith(activeProfile: profiles.first);
        }
      }
    }

    return result;
  }

  Future<void> _saveSession(dynamic response) async {
    // ... existing save logic
  }
}
```

---

### Bước 9: Refactor Bloc

```dart
// lib/features/auth/bloc/login/login_bloc.dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository authRepository,
    required DeviceInfoHelper deviceInfoHelper,
  })  : _authRepository = authRepository,
        _deviceInfoHelper = deviceInfoHelper,
        super(LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginRoleSelected>(_onRoleSelected);
  }

  final AuthRepository _authRepository;
  final DeviceInfoHelper _deviceInfoHelper;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    final deviceInfo = await _deviceInfoHelper.getDeviceInfo();
    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
      deviceInfo: deviceInfo,
    );

    // Clean pattern matching với Result
    result.when(
      success: (response) {
        if (response.completed && response.accessToken != null) {
          emit(LoginSuccess(AuthResponse(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            user: response.user,
            activeRole: response.activeRole,
          )));
        } else if (response.sessionToken != null) {
          if (response.roles.isEmpty) {
            emit(LoginNeedsRoleRegistration(
              sessionToken: response.sessionToken!,
              user: response.user,
            ));
          } else {
            emit(LoginNeedsRoleSelection(
              sessionToken: response.sessionToken!,
              roles: response.roles,
              requiresOrgSelection: response.requiresOrgSelection,
            ));
          }
        } else {
          emit(const LoginFailure('Có lỗi xảy ra khi đăng nhập'));
        }
      },
      failure: (error) {
        emit(LoginFailure(_mapFailureToMessage(error)));
      },
    );
  }

  Future<void> _onRoleSelected(
    LoginRoleSelected event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    final result = await _authRepository.selectRole(
      sessionToken: event.sessionToken,
      roleId: event.roleId,
      roleType: event.roleType,
      organizationId: event.organizationId,
    );

    result.when(
      success: (response) => emit(LoginSuccess(response)),
      failure: (error) => emit(LoginFailure(_mapFailureToMessage(error))),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      NetworkFailure(:final message) => message ?? 'Lỗi kết nối',
      ServerFailure(:final message, :final errors) =>
        errors?.firstOrNull?.message ?? message ?? 'Lỗi server',
      UnauthorizedFailure() => 'Phiên đăng nhập hết hạn',
      _ => failure.message ?? 'Đã có lỗi xảy ra',
    };
  }
}
```

---

### Bước 10: Tạo Extension cho Bloc

```dart
// lib/core/bloc/bloc_extensions.dart

/// Extension để handle Result trong Bloc dễ dàng hơn
extension ResultEmitterX<T, F> on Result<T, F> {
  /// Emit states dựa trên Result
  void emitWhen<S>({
    required void Function(S state) emit,
    required S Function(T value) onSuccess,
    required S Function(F error) onFailure,
  }) {
    when(
      success: (value) => emit(onSuccess(value)),
      failure: (error) => emit(onFailure(error)),
    );
  }
}

// Usage trong Bloc:
final result = await _authRepository.login(...);
result.emitWhen(
  emit: emit,
  onSuccess: (response) => LoginSuccess(response),
  onFailure: (error) => LoginFailure(error.message ?? ''),
);
```

---

### Cấu trúc thư mục đề xuất

```
lib/
├── core/
│   ├── error/
│   │   ├── failures.dart
│   │   └── result.dart
│   ├── network/
│   │   ├── network_client.dart
│   │   ├── error_interceptor.dart
│   │   ├── auth_interceptor.dart
│   │   └── api_response.dart
│   ├── logger/
│   │   └── app_logger.dart
│   └── bloc/
│       └── bloc_extensions.dart
│
├── features/
│   └── auth/
│       ├── data/
│       │   ├── api/
│       │   │   └── auth_api_client.dart
│       │   ├── dto/
│       │   │   ├── login_request_dto.dart
│       │   │   ├── register_request_dto.dart
│       │   │   └── ...
│       │   ├── models/
│       │   │   ├── user_model.dart
│       │   │   └── ...
│       │   └── storage/
│       │       └── auth_storage.dart
│       ├── repository/
│       │   ├── auth_repository.dart
│       │   └── auth_repository_impl.dart
│       ├── bloc/
│       │   └── login/
│       │       ├── login_bloc.dart
│       │       ├── login_event.dart
│       │       └── login_state.dart
│       └── presentation/
│           └── ...
```

---

### Migration Checklist

| Step | Task | Effort |
|------|------|--------|
| 1 | Tạo `core/error/` (Failure + Result) | 1h |
| 2 | Tạo `core/network/error_interceptor.dart` | 1h |
| 3 | Tạo `core/network/api_response.dart` | 30m |
| 4 | Tạo Request DTOs cho Auth | 2h |
| 5 | Update `AuthApiClient` với typed responses | 1h |
| 6 | Run `build_runner` để generate code | 10m |
| 7 | Refactor `AuthRepositoryImpl` với `_safeCall` | 2h |
| 8 | Refactor `LoginBloc` với Result pattern | 1h |
| 9 | Refactor các Bloc còn lại | 3h |
| 10 | Update tests | 2h |

**Tổng thời gian ước tính:** ~13-15 giờ

---

### Lợi ích sau khi refactor

| Metric | Before | After |
|--------|--------|-------|
| Type Safety | Runtime errors | Compile-time checks |
| Error Handling | Duplicated in every bloc | Centralized in interceptor |
| Code Lines (Bloc) | ~50 lines | ~25 lines |
| Testability | Mock Dio directly | Mock Repository interface |
| Debugging | print() scattered | Structured logs |

---

## 6. P2 - Medium: Global Bloc Providers

### Vấn đề

**File:** `lib/di/app_bloc_providers.dart`

```dart
abstract class AppBlocProviders {
  static List<SingleChildWidget> providers() {
    final authRepo = diContainer.get<AuthRepository>();

    return [
      BlocProvider(create: (_) => ThemeCubit(...)..loadTheme()),  // OK - Global
      BlocProvider<InitBloc>(create: (_) => InitBloc(...)..add(InitStarted())),  // OK - Global
      BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepo)),  // OK - Global

      // ISSUE: Các bloc này chỉ dùng ở màn auth
      BlocProvider<LoginBloc>(create: (_) => LoginBloc(...)),        // Local
      BlocProvider<RegisterBloc>(create: (_) => RegisterBloc(...)), // Local
      BlocProvider<ForgotPasswordBloc>(create: (_) => ForgotPasswordBloc(...)), // Local
    ];
  }
}
```

### Tác động

| Issue | Impact |
|-------|--------|
| Memory | Bloc được tạo ngay từ đầu, dù chưa cần |
| Lifecycle | Bloc không bao giờ dispose cho đến khi app đóng |
| State pollution | State cũ có thể tồn tại khi quay lại màn hình |

### Giải pháp

**Bước 1: Tách global và local blocs**

```dart
// lib/di/app_bloc_providers.dart
abstract class AppBlocProviders {
  /// Blocs cần thiết xuyên suốt app lifecycle
  static List<SingleChildWidget> globalProviders() {
    final authRepo = diContainer.get<AuthRepository>();

    return [
      BlocProvider(
        create: (_) => ThemeCubit(diContainer.get<ThemeRepository>())..loadTheme(),
      ),
      BlocProvider<InitBloc>(
        create: (_) => InitBloc(
          onboardingRepository: diContainer.get<OnboardingRepository>(),
          authRepository: authRepo,
        )..add(InitStarted()),
      ),
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(authRepo),
      ),
    ];
  }
}
```

**Bước 2: Provide LoginBloc locally**

```dart
// lib/features/auth/presentation/login_screen.dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(
        authRepository: diContainer.get<AuthRepository>(),
        deviceInfoHelper: DeviceInfoHelper(diContainer.get<AuthStorage>()),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  // ... existing state code
}
```

**Bước 3: Provide RegisterBloc locally**

```dart
// lib/features/auth/presentation/register_form_screen.dart
class RegisterFormScreen extends StatelessWidget {
  const RegisterFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(
        authRepository: diContainer.get<AuthRepository>(),
      ),
      child: const _RegisterFormView(),
    );
  }
}
```

**Bước 4: Provide ForgotPasswordBloc locally**

```dart
// lib/features/auth/presentation/forgot_password_screen.dart
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(
        authRepository: diContainer.get<AuthRepository>(),
      ),
      child: const _ForgotPasswordView(),
    );
  }
}
```

**Bước 5: Cập nhật app.dart**

```dart
// lib/app/app.dart
@override
Widget build(BuildContext context) => MultiRepositoryProvider(
  providers: [...AppRepositoryProviders.providers()],
  child: MultiBlocProvider(
    providers: AppBlocProviders.globalProviders(),  // Chỉ global
    child: // ...
  ),
);
```

---

## 7. P2 - Medium: Inconsistent DI Pattern

### Vấn đề

App hiện đang dùng **3 cách khác nhau** để inject dependencies:

**Cách 1: Trực tiếp qua diContainer (Service Locator)**
```dart
// onboarding_screen.dart
OnboardingRepository get _onboardingRepo =>
    diContainer.get<OnboardingRepository>();
```

**Cách 2: Qua BlocProvider (Recommended)**
```dart
// app.dart
context.read<AuthBloc>().add(AuthSessionExpired());
```

**Cách 3: Inject qua constructor**
```dart
// login_bloc.dart
LoginBloc({
  required AuthRepository authRepository,
  required DeviceInfoHelper deviceInfoHelper,
})
```

### Tác động

- Code không nhất quán, khó đọc
- Khó test (diContainer là global state)
- Khó trace dependencies

### Giải pháp

**Nguyên tắc:**
1. **Blocs/Cubits**: Inject qua constructor, provide qua BlocProvider
2. **Repositories**: Inject qua constructor, register với GetIt
3. **Widgets**: Access bloc qua context.read/watch, KHÔNG truy cập diContainer trực tiếp

**Bước 1: Refactor OnboardingScreen**

```dart
// TRƯỚC
class _OnboardingScreenState extends State<OnboardingScreen> {
  OnboardingRepository get _onboardingRepo =>
      diContainer.get<OnboardingRepository>();

  Future<void> _onGetStarted() async {
    await _onboardingRepo.setSeenOnboarding();
    // ...
  }
}

// SAU - Option 1: Dùng Cubit
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(
        repository: diContainer.get<OnboardingRepository>(),
      ),
      child: const _OnboardingView(),
    );
  }
}

// lib/features/onboarding/bloc/onboarding_cubit.dart
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required OnboardingRepository repository})
      : _repository = repository,
        super(OnboardingInitial());

  final OnboardingRepository _repository;

  Future<void> completeOnboarding() async {
    await _repository.setSeenOnboarding();
    emit(OnboardingCompleted());
  }
}

// SAU - Option 2: Dùng RepositoryProvider (simpler)
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: diContainer.get<OnboardingRepository>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingViewState extends State<_OnboardingView> {
  Future<void> _onGetStarted() async {
    await context.read<OnboardingRepository>().setSeenOnboarding();
    if (!mounted) return;
    NavigationService.of(context).pushAndRemoveAll(Routes.login);
  }
}
```

**Bước 2: Tạo rule cho team**

```markdown
## DI Rules

1. KHÔNG bao giờ gọi `diContainer.get<T>()` trong Widget/State
2. Blocs được inject qua BlocProvider
3. Repositories được inject qua RepositoryProvider hoặc constructor của Bloc
4. Chỉ gọi `diContainer.get<T>()` trong:
   - `app_bloc_providers.dart`
   - `app_repository_providers.dart`
   - Test setup
```

---

## 8. P2 - Medium: Nested BlocBuilder

### Vấn đề

**File:** `lib/features/auth/presentation/login_screen.dart:203-219`

```dart
BlocBuilder<LoginBloc, LoginState>(
  builder: (context, loginState) {
    return BlocBuilder<AuthAnimationCubit, AuthAnimationState>(
      builder: (context, animState) {
        return AuthButton(
          label: 'Đăng nhập',
          isLoading: loginState is LoginInProgress,
          isSuccess: animState.status == AuthScreenAnimStatus.success,
          onPressed: _onSubmit,
        );
      },
    );
  },
),
```

### Tác động

- 2 levels của nesting khó đọc
- Outer builder rebuild khi inner state thay đổi (không cần thiết)
- Khó maintain khi thêm nhiều blocs hơn

### Giải pháp

**Option 1: Tách thành Widget riêng**

```dart
// lib/features/auth/presentation/widgets/login_submit_button.dart
class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<LoginBloc, bool>(
      (bloc) => bloc.state is LoginInProgress,
    );

    final isSuccess = context.select<AuthAnimationCubit, bool>(
      (cubit) => cubit.state.status == AuthScreenAnimStatus.success,
    );

    return AuthButton(
      label: 'Đăng nhập',
      isLoading: isLoading,
      isSuccess: isSuccess,
      onPressed: onPressed,
    );
  }
}

// Sử dụng trong login_screen.dart
LoginSubmitButton(onPressed: _onSubmit),
```

**Option 2: Dùng BlocSelector**

```dart
BlocSelector<LoginBloc, LoginState, bool>(
  selector: (state) => state is LoginInProgress,
  builder: (context, isLoading) {
    return BlocSelector<AuthAnimationCubit, AuthAnimationState, bool>(
      selector: (state) => state.status == AuthScreenAnimStatus.success,
      builder: (context, isSuccess) {
        return AuthButton(
          label: 'Đăng nhập',
          isLoading: isLoading,
          isSuccess: isSuccess,
          onPressed: _onSubmit,
        );
      },
    );
  },
),
```

**Option 3: Combine states với Record (Dart 3)**

```dart
// Tạo extension
extension LoginScreenSelectors on BuildContext {
  ({bool isLoading, bool isSuccess}) get loginButtonState {
    final loginState = watch<LoginBloc>().state;
    final animState = watch<AuthAnimationCubit>().state;
    return (
      isLoading: loginState is LoginInProgress,
      isSuccess: animState.status == AuthScreenAnimStatus.success,
    );
  }
}

// Sử dụng với Builder để scope rebuild
Builder(
  builder: (context) {
    final (:isLoading, :isSuccess) = context.loginButtonState;
    return AuthButton(
      label: 'Đăng nhập',
      isLoading: isLoading,
      isSuccess: isSuccess,
      onPressed: _onSubmit,
    );
  },
),
```

---

## 9. P3 - Low: Dead Code và Unused Fields

### Vấn đề

**File:** `lib/bloc/init/init_bloc.dart:24-25, 40-48`

```dart
class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc({
    required OnboardingRepository onboardingRepository,
    required AuthRepository authRepository,  // Passed but not used
  }) : _onboardingRepository = onboardingRepository,
       _authRepository = authRepository,
       super(InitInitial()) {
    on<InitStarted>(_onStarted);
  }

  final OnboardingRepository _onboardingRepository;
  // ignore: unused_field
  final AuthRepository _authRepository;  // <-- DEAD CODE

  Future<void> _onStarted(InitStarted event, Emitter<InitState> emit) async {
    // ...

    // TODO: Bật lại khi test API
    // final loggedIn =
    //     await _authRepository.isLoggedIn();  // <-- COMMENTED OUT
    // if (loggedIn) {
    //   emit(InitOpenApp());
    // } else {
    //   emit(InitOpenLogin());
    // }

    // Giả lập: luôn mở login
    emit(InitOpenLogin());
  }
}
```

### Tác động

- Code confusing - người đọc không biết có dùng hay không
- Lint warnings bị suppress bằng ignore comments
- Technical debt tích tụ

### Giải pháp

**Option 1: Nếu sẽ dùng trong tương lai gần - Implement properly**

```dart
class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc({
    required OnboardingRepository onboardingRepository,
    required AuthRepository authRepository,
    required AppConfig appConfig,
  }) : _onboardingRepository = onboardingRepository,
       _authRepository = authRepository,
       _appConfig = appConfig,
       super(InitInitial()) {
    on<InitStarted>(_onStarted);
  }

  final OnboardingRepository _onboardingRepository;
  final AuthRepository _authRepository;
  final AppConfig _appConfig;

  Future<void> _onStarted(InitStarted event, Emitter<InitState> emit) async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    // Skip auth check in dev if configured
    if (_appConfig.skipAuthCheck) {
      emit(InitOpenLogin());
      return;
    }

    final seen = await _onboardingRepository.hasSeenOnboarding();
    if (!seen) {
      emit(InitOpenOnboarding());
      return;
    }

    final loggedIn = await _authRepository.isLoggedIn();
    emit(loggedIn ? InitOpenApp() : InitOpenLogin());
  }
}
```

**Option 2: Nếu không cần - Remove completely**

```dart
class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc({
    required OnboardingRepository onboardingRepository,
  }) : _onboardingRepository = onboardingRepository,
       super(InitInitial()) {
    on<InitStarted>(_onStarted);
  }

  final OnboardingRepository _onboardingRepository;

  Future<void> _onStarted(InitStarted event, Emitter<InitState> emit) async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    final seen = await _onboardingRepository.hasSeenOnboarding();
    emit(seen ? InitOpenLogin() : InitOpenOnboarding());
  }
}
```

---

## 10. P3 - Low: Duplicate Theme Logic

### Vấn đề

**File:** `lib/bloc/theme/app_theme.dart`

```dart
// Hai cách biểu diễn cùng một concept
enum AppTheme { light, dark, system }

class DarkThemePreference extends Equatable {
  static const int followSystem = 1;
  static const int on = 2;
  static const int off = 3;

  final int darkThemeValue;
  // ...
}

class AppThemeSettings extends Equatable {
  final DarkThemePreference darkTheme;
  final AppTheme appTheme;  // Redundant với darkTheme
}
```

### Tác động

- 2 nguồn sự thật cho cùng 1 data
- Có thể conflict: appTheme = light nhưng darkTheme = on
- Khó maintain

### Giải pháp

**Simplify to single source of truth:**

```dart
// lib/bloc/theme/app_theme.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  ThemeMode toFlutterThemeMode() => switch (this) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };

  static AppThemeMode fromString(String? value) => switch (value) {
    'light' => AppThemeMode.light,
    'dark' => AppThemeMode.dark,
    _ => AppThemeMode.system,
  };
}

class AppThemeSettings extends Equatable {
  const AppThemeSettings({
    this.mode = AppThemeMode.system,
    this.highContrast = false,
  });

  final AppThemeMode mode;
  final bool highContrast;

  ThemeMode get themeMode => mode.toFlutterThemeMode();

  AppThemeSettings copyWith({
    AppThemeMode? mode,
    bool? highContrast,
  }) {
    return AppThemeSettings(
      mode: mode ?? this.mode,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  @override
  List<Object?> get props => [mode, highContrast];
}
```

**Cập nhật ThemeCubit:**

```dart
// lib/bloc/theme/theme_cubit.dart
class ThemeCubit extends Cubit<AppThemeSettings> {
  ThemeCubit(this._repository) : super(const AppThemeSettings());

  final ThemeRepository _repository;

  Future<void> loadTheme() async {
    final settings = await _repository.getTheme();
    emit(settings);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final newSettings = state.copyWith(mode: mode);
    await _repository.saveTheme(newSettings);
    emit(newSettings);
  }

  Future<void> toggleHighContrast() async {
    final newSettings = state.copyWith(highContrast: !state.highContrast);
    await _repository.saveTheme(newSettings);
    emit(newSettings);
  }

  // Direct getter for convenience
  ThemeMode get themeMode => state.themeMode;
}
```

---

## 11. P3 - Low: Magic Numbers

### Vấn đề

Hardcoded numbers rải rác trong code:

```dart
// init_bloc.dart
const Duration _splashDuration = Duration(milliseconds: 2200);

// login_screen.dart
Future.delayed(const Duration(milliseconds: 800), () { ... });
Future.delayed(const Duration(milliseconds: 100), () { ... });
Future.delayed(const Duration(milliseconds: 600), () { ... });

// onboarding_screen.dart
duration: const Duration(milliseconds: 400),
duration: const Duration(milliseconds: 200),
const Duration(milliseconds: 280),
```

### Giải pháp

**Tạo Animation Constants:**

```dart
// lib/constants/durations.dart
abstract class AppDurations {
  // Splash & Initialization
  static const splash = Duration(milliseconds: 2200);

  // Page transitions
  static const pageTransition = Duration(milliseconds: 400);
  static const pageTransitionFast = Duration(milliseconds: 280);

  // Auth animations
  static const authSuccess = Duration(milliseconds: 800);
  static const authSuccessNavigate = Duration(milliseconds: 100);
  static const authRolePickerDelay = Duration(milliseconds: 600);

  // UI feedback
  static const fadeIn = Duration(milliseconds: 200);
  static const fadeOut = Duration(milliseconds: 150);
  static const snackbar = Duration(seconds: 3);

  // Debounce & Throttle
  static const debounceSearch = Duration(milliseconds: 300);
  static const throttleButton = Duration(milliseconds: 500);
}
```

**Sử dụng:**

```dart
// login_screen.dart
Future.delayed(AppDurations.authSuccess, () {
  if (!mounted) return;
  context.read<AuthBloc>().add(AuthLoggedIn(response));
  Future.delayed(AppDurations.authSuccessNavigate, () {
    if (!mounted) return;
    navigator.pushAndRemoveAll(Routes.app);
  });
});

// onboarding_screen.dart
_pageController.animateToPage(
  _pageCount - 1,
  duration: AppDurations.pageTransition,
  curve: Curves.easeInOutCubic,
);
```

---

## 12. P3 - Low: Empty Catch Blocks

### Vấn đề

**File:** `lib/features/auth/repository/auth_repository_impl.dart:147,163,311`

```dart
// Swallow errors silently
if (authResponse.user == null && authResponse.accessToken != null) {
  try {
    final user = await getMe();
    authResponse = authResponse.copyWith(user: user);
  } catch (_) {}  // <-- Silent failure
}

try {
  final profiles = await getProfiles();
  // ...
} catch (_) {}  // <-- Silent failure
```

### Tác động

- Không biết khi nào có lỗi
- Khó debug production issues
- App có thể ở trạng thái không nhất quán

### Giải pháp

**Option 1: Log và continue**

```dart
if (authResponse.user == null && authResponse.accessToken != null) {
  try {
    final user = await getMe();
    authResponse = authResponse.copyWith(user: user);
  } catch (e, stackTrace) {
    AppLogger.w('Failed to fetch user after login', e);
    // Continue without user - UI sẽ handle state này
  }
}

try {
  final profiles = await getProfiles();
  // ...
} catch (e, stackTrace) {
  AppLogger.w('Failed to fetch profiles', e);
  // Continue với activeProfile từ response gốc
}
```

**Option 2: Wrap trong Result type (nếu dùng dartz)**

```dart
Future<Either<Failure, AuthResponse>> selectRole({...}) async {
  try {
    // ...
    return Right(authResponse);
  } on DioException catch (e) {
    return Left(NetworkFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

**Option 3: Explicit optional operations**

```dart
Future<AuthResponse> selectRole({...}) async {
  // ... core logic that can throw

  // Optional enrichment - failures are acceptable
  final enrichedResponse = await _enrichAuthResponse(authResponse);
  return enrichedResponse;
}

Future<AuthResponse> _enrichAuthResponse(AuthResponse response) async {
  var result = response;

  // Try to fetch user
  if (result.user == null && result.accessToken != null) {
    result = await _tryFetchUser(result);
  }

  // Try to fetch full profile
  result = await _tryFetchProfile(result);

  return result;
}

Future<AuthResponse> _tryFetchUser(AuthResponse response) async {
  try {
    final user = await getMe();
    return response.copyWith(user: user);
  } catch (e) {
    AppLogger.d('Optional user fetch failed: $e');
    return response;
  }
}
```

---

## 13. P3 - Low: Redundant Cubit Methods

### Vấn đề

**File:** `lib/bloc/theme/theme_cubit.dart:24-31`

```dart
class ThemeCubit extends Cubit<AppThemeSettings> {
  // ...

  AppThemeSettings get theme => state;  // Redundant - state đã public

  set setTheme(AppThemeSettings theme) {  // Setter với tên lạ
    themeRepository.saveTheme(theme.appTheme);
    emit(theme);
  }

  void updateTheme(AppThemeSettings value) => setTheme = value;  // Wrapper cho setter
}
```

### Tác động

- 3 cách làm cùng 1 việc
- API confusing
- `set setTheme` là anti-pattern trong Dart

### Giải pháp

```dart
class ThemeCubit extends Cubit<AppThemeSettings> {
  ThemeCubit(this._repository) : super(_defaultTheme);

  final ThemeRepository _repository;

  static const _defaultTheme = AppThemeSettings();

  Future<void> loadTheme() async {
    final savedTheme = await _repository.getTheme();
    emit(savedTheme);
  }

  /// Update theme mode (light/dark/system)
  Future<void> setThemeMode(AppThemeMode mode) async {
    final newSettings = state.copyWith(mode: mode);
    await _repository.saveTheme(newSettings);
    emit(newSettings);
  }

  /// Convenience getter
  ThemeMode get themeMode => state.themeMode;
}
```

---

## 14. P2 - Medium: Dead Code & Unused Components

### Vấn đề

Có nhiều components được tạo nhưng không được sử dụng, gây bloat code và confuse developers.

### 14.1 Widgets Export Nhưng Không Dùng

**File:** `lib/widgets/widgets.dart`

```dart
export 'bottom_sheet_dialog.dart';      // Không có file nào import
export 'bottom_sheet_dialog_icon.dart'; // Không có file nào import
export 'preference_switch.dart';        // Chỉ dùng ở 1 chỗ
export 'section_header.dart';           // OK - dùng nhiều nơi
export 'separator.dart';                // Không có file nào import
export 'setting_item.dart';             // Không có file nào import
```

**Kiểm tra:**
```bash
grep -rn "bottom_sheet_dialog" lib/ --include="*.dart" | grep -v "widgets.dart"
# Kết quả: No files found

grep -rn "separator" lib/ --include="*.dart" | grep -v "widgets.dart" | grep -v ".g.dart"
# Kết quả: No files found
```

### 14.2 Auth Gradient Header Không Dùng

**File:** `lib/features/auth/presentation/widgets/auth_gradient_header.dart`

```bash
grep -rn "auth_gradient_header" lib/
# Kết quả: No files found

grep -rn "AuthHeader" lib/ --include="*.dart"
# Kết quả: Chỉ có file định nghĩa, không có file import
```

**228 dòng code** không được sử dụng.

### 14.3 Danh sách files có thể xóa

| File | Lines | Lý do |
|------|-------|-------|
| `lib/widgets/bottom_sheet_dialog.dart` | ~50 | Không import |
| `lib/widgets/bottom_sheet_dialog_icon.dart` | ~30 | Không import |
| `lib/widgets/separator.dart` | ~20 | Không import |
| `lib/widgets/setting_item.dart` | ~40 | Không import |
| `lib/features/auth/presentation/widgets/auth_gradient_header.dart` | 228 | Không import |

**Tổng cộng:** ~370 dòng code có thể xóa

### Giải pháp

**Bước 1: Xác nhận không dùng**
```bash
# Script kiểm tra unused exports
for file in lib/widgets/*.dart; do
  name=$(basename "$file" .dart)
  if [ "$name" != "widgets" ]; then
    count=$(grep -rn "$name" lib/ --include="*.dart" | grep -v "widgets.dart" | wc -l)
    if [ "$count" -eq 0 ]; then
      echo "UNUSED: $file"
    fi
  fi
done
```

**Bước 2: Xóa files không dùng**
```bash
rm lib/widgets/bottom_sheet_dialog.dart
rm lib/widgets/bottom_sheet_dialog_icon.dart
rm lib/widgets/separator.dart
rm lib/widgets/setting_item.dart
rm lib/features/auth/presentation/widgets/auth_gradient_header.dart
```

**Bước 3: Cập nhật barrel file**
```dart
// lib/widgets/widgets.dart
export 'preference_switch.dart';
export 'section_header.dart';
export 'together_settings.dart';
```

---

## 15. P2 - Medium: Duplicate Components Cần Consolidate

### Vấn đề

Có nhiều components tương tự nhau nhưng nằm ở các features khác nhau, gây duplicate code.

### 15.1 EmptyState Widget (17+ duplicates)

Có ít nhất **17 empty state widgets** private trong các screens:

```dart
// parent_dashboard_screen.dart
class _EmptyCard extends StatelessWidget { ... }

// parent_finance_screen.dart
class _EmptyCard extends StatelessWidget { ... }  // DUPLICATE!

// parent_tracking_screen.dart
class _EmptyCard extends StatelessWidget { ... }  // DUPLICATE!

// teacher_dashboard_screen.dart
class _EmptyCard extends StatelessWidget { ... }  // DUPLICATE!

// teacher_courses_screen.dart
class _EmptyState extends StatelessWidget { ... }

// teacher_students_screen.dart
class _EmptyState extends StatelessWidget { ... }

// org_dashboard_screen.dart
class _EmptyCard extends StatelessWidget { ... }

// org_students_screen.dart
class _EmptyState extends StatelessWidget { ... }

// ... và nhiều hơn nữa
```

**Giải pháp: Tạo Shared EmptyStateWidget**

```dart
// lib/widgets/empty_state.dart
import 'package:flutter/material.dart';

enum EmptyStateStyle {
  card,      // Có card container
  inline,    // Không có card, inline
  fullPage,  // Full page với illustration
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.iconWidget,
    this.title,
    this.actionLabel,
    this.onAction,
    this.style = EmptyStateStyle.card,
  });

  final String message;
  final IconData? icon;
  final Widget? iconWidget;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateStyle style;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconWidget != null)
          iconWidget!
        else if (icon != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: cs.onSurfaceVariant),
          ),
        if (title != null) ...[
          const SizedBox(height: 16),
          Text(
            title!,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          message,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
        ],
      ],
    );

    return switch (style) {
      EmptyStateStyle.card => Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      EmptyStateStyle.inline => Padding(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      EmptyStateStyle.fullPage => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: content,
          ),
        ),
    };
  }
}
```

**Sử dụng:**
```dart
// TRƯỚC - 17 implementations khác nhau
class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48),
            SizedBox(height: 16),
            Text('Chưa có dữ liệu'),
          ],
        ),
      ),
    );
  }
}

// SAU - 1 shared widget
EmptyState(
  icon: Icons.inbox_outlined,
  message: 'Chưa có dữ liệu',
  style: EmptyStateStyle.card,
)
```

### 15.2 StatsCard (2 duplicates)

```dart
// teacher/presentation/widgets/stats_card.dart
class StatsCard extends StatelessWidget {
  // Layout: Row với icon bên trái
}

// student/presentation/widgets/student_stats_card.dart
class StudentStatsCard extends StatelessWidget {
  // Layout: Column với icon trên đầu
}
```

**Giải pháp: Merge thành một widget với layout option**

```dart
// lib/widgets/stats_card.dart
enum StatsCardLayout { horizontal, vertical }

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.layout = StatsCardLayout.horizontal,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final StatsCardLayout layout;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      StatsCardLayout.horizontal => _buildHorizontal(context),
      StatsCardLayout.vertical => _buildVertical(context),
    };
  }

  Widget _buildHorizontal(BuildContext context) { /* ... */ }
  Widget _buildVertical(BuildContext context) { /* ... */ }
}
```

### 15.3 EnrollmentCard (2 duplicates)

```dart
// student/presentation/widgets/enrollment_card.dart
class EnrollmentCard extends StatelessWidget {
  final EnrollmentModel enrollment;  // Student model
}

// parent/presentation/widgets/enrollment_card.dart
class EnrollmentCard extends StatelessWidget {
  final ChildEnrollmentModel enrollment;  // Parent model
}
```

**Giải pháp: Tạo interface chung**

```dart
// lib/core/models/enrollment_display.dart
abstract class EnrollmentDisplay {
  String get courseName;
  String? get courseDescription;
  String? get instructorName;
  double get progress;
  bool get isCompleted;
  String? get lastLearned;
}

// Implement trong models
class EnrollmentModel implements EnrollmentDisplay { ... }
class ChildEnrollmentModel implements EnrollmentDisplay { ... }

// Widget dùng interface
class EnrollmentCard extends StatelessWidget {
  const EnrollmentCard({
    required this.enrollment,
    this.onTap,
    this.compact = false,
  });

  final EnrollmentDisplay enrollment;  // Interface, không phải concrete class
  final VoidCallback? onTap;
  final bool compact;
}
```

### 15.4 ScheduleCard (3 duplicates)

```dart
// teacher/presentation/widgets/schedule_card.dart
// student/presentation/widgets/schedule/schedule_card.dart
// student/presentation/widgets/schedule_item_card.dart
```

**Giải pháp:** Tương tự EnrollmentCard - tạo `ScheduleDisplay` interface.

---

## 16. P3 - Low: Opportunities for Shared Components

### 16.1 Loading States

**73 lần sử dụng** `CircularProgressIndicator` rải rác. Nên tạo:

```dart
// lib/widgets/loading_indicator.dart
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// Full page loading
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingIndicator(size: 40),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
```

### 16.2 Section Headers

Đã có `section_header.dart` trong `lib/widgets/` nhưng:
- `bi_section_header.dart` trong system_admin
- `explore_section_header.dart` trong student

Nên merge thành một với customization options.

### 16.3 App Bars

```dart
// student/presentation/widgets/student_app_bar.dart
// teacher/presentation/widgets/teacher_app_bar.dart
```

Tương tự nhau, có thể merge thành `RoleAwareAppBar` hoặc generic `AppHeader`.

---

## Component Architecture Đề Xuất

```
lib/
├── widgets/                    # Shared widgets (cross-feature)
│   ├── cards/
│   │   ├── stats_card.dart
│   │   ├── enrollment_card.dart
│   │   └── schedule_card.dart
│   ├── states/
│   │   ├── empty_state.dart
│   │   ├── loading_indicator.dart
│   │   └── error_state.dart
│   ├── layout/
│   │   ├── section_header.dart
│   │   └── app_header.dart
│   └── inputs/
│       └── ...
│
├── core/
│   └── models/
│       ├── enrollment_display.dart   # Interface
│       └── schedule_display.dart     # Interface
│
└── features/
    └── [feature]/
        └── presentation/
            └── widgets/              # Feature-specific widgets only
```

---

## Checklist Implementation

| # | Issue | Priority | Status | Assignee | PR |
|---|-------|----------|--------|----------|-----|
| 1 | Remove print() statements | P0 | [ ] | | |
| 2 | Fix hardcoded debug flag | P0 | [ ] | | |
| 3 | Fix context.watch at root | P1 | [ ] | | |
| 4 | Remove unused dependencies | P1 | [ ] | | |
| 5 | **Refactor API Layer** | P1 | [ ] | | |
| 5.1 | - Create core/error (Failure + Result) | | [ ] | | |
| 5.2 | - Create ErrorInterceptor | | [ ] | | |
| 5.3 | - Create ApiResponse wrapper | | [ ] | | |
| 5.4 | - Create Request DTOs | | [ ] | | |
| 5.5 | - Update AuthApiClient (typed) | | [ ] | | |
| 5.6 | - Refactor AuthRepositoryImpl | | [ ] | | |
| 5.7 | - Refactor Blocs with Result | | [ ] | | |
| 6 | Localize auth blocs | P2 | [ ] | | |
| 7 | Consistent DI pattern | P2 | [ ] | | |
| 8 | Fix nested BlocBuilder | P2 | [ ] | | |
| 9 | Remove dead code | P3 | [ ] | | |
| 10 | Simplify theme logic | P3 | [ ] | | |
| 11 | Extract magic numbers | P3 | [ ] | | |
| 12 | Fix empty catch blocks | P3 | [ ] | | |
| 13 | Clean up ThemeCubit API | P3 | [ ] | | |
| 14 | **Remove Unused Components** | P2 | [ ] | | |
| 14.1 | - Delete unused widgets (~370 lines) | | [ ] | | |
| 14.2 | - Clean widgets.dart barrel | | [ ] | | |
| 15 | **Consolidate Duplicate Widgets** | P2 | [ ] | | |
| 15.1 | - Create shared EmptyState widget | | [ ] | | |
| 15.2 | - Merge StatsCard variants | | [ ] | | |
| 15.3 | - Create EnrollmentDisplay interface | | [ ] | | |
| 15.4 | - Merge ScheduleCard variants | | [ ] | | |
| 16 | **Create Shared Components** | P3 | [ ] | | |
| 16.1 | - LoadingIndicator widget | | [ ] | | |
| 16.2 | - Merge SectionHeader variants | | [ ] | | |
| 16.3 | - Create RoleAwareAppBar | | [ ] | | |

---

## Estimated Impact

| Metric | Before | After (Expected) |
|--------|--------|------------------|
| Bundle Size | ~X MB | -200KB |
| Startup Time | ~2.5s | ~2.0s |
| Theme Switch Rebuild | Full tree | Scoped |
| Memory (Auth screens) | Always allocated | On-demand |
| Lint Warnings | 28+ | 0 |
| API Error Handling | Scattered try-catch | Centralized |
| Type Safety (API) | Runtime errors | Compile-time |
| Bloc Code Lines | ~50 lines/bloc | ~25 lines/bloc |
| Dead Code Removed | 0 | ~370 lines |
| Duplicate Widgets | 17+ EmptyState | 1 shared |
| Code Reuse | Low | High |
