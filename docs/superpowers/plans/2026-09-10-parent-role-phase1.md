# Parent Role UI - Phase 1: Core Structure

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build Parent shell with bottom navigation, children loading, child switcher, and dashboard overview

**Architecture:** Feature-based structure mirroring student feature. BLoC for state, Repository for data access. ChildSelectorCubit shared across screens.

**Tech Stack:** Flutter, flutter_bloc, freezed, dio, go_router

**Spec:** `docs/superpowers/specs/2026-09-10-parent-role-design.md`

## Global Constraints

- Follow existing patterns in `lib/features/student/`
- Use existing theme, colors, widgets from `lib/widgets/`
- Vietnamese comments with English technical terms
- Models use freezed for immutability
- API client uses retrofit/dio pattern

---

### Task 1: Data Models

**Files:**
- Create: `lib/features/parent/data/models/child_model.dart`
- Create: `lib/features/parent/data/models/child_overview_model.dart`
- Create: `lib/features/parent/data/models/parent_alert_model.dart`

**Produces:**
- `ChildModel` with id, fullName, avatarUrl, className, enrolledCourses
- `ChildOverviewModel` with progressPercent, avgQuizScore, studyHoursWeek, attendanceRate
- `ParentAlertModel` with type, severity, childId, message, relatedId

- [ ] **Step 1: Create child_model.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

@freezed
class ChildModel with _$ChildModel {
  const factory ChildModel({
    required String id,
    required String fullName,
    String? avatarUrl,
    String? className,
    @Default(0) int enrolledCourses,
    @Default(0) double progressPercent,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}
```

- [ ] **Step 2: Create child_overview_model.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_overview_model.freezed.dart';
part 'child_overview_model.g.dart';

@freezed
class ChildOverviewModel with _$ChildOverviewModel {
  const factory ChildOverviewModel({
    required String childId,
    @Default(0) double progressPercent,
    @Default(0) double avgQuizScore,
    @Default(0) double studyHoursWeek,
    @Default(0) double attendanceRate,
    @Default(0) int totalCourses,
  }) = _ChildOverviewModel;

  factory ChildOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$ChildOverviewModelFromJson(json);
}
```

- [ ] **Step 3: Create parent_alert_model.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_alert_model.freezed.dart';
part 'parent_alert_model.g.dart';

enum AlertSeverity { critical, warning, info }
enum AlertType { missedClass, lowScore, courseExpiring, completed }

@freezed
class ParentAlertModel with _$ParentAlertModel {
  const factory ParentAlertModel({
    required String id,
    required AlertType type,
    required AlertSeverity severity,
    required String childId,
    required String childName,
    required String message,
    String? relatedId,
    required DateTime createdAt,
  }) = _ParentAlertModel;

  factory ParentAlertModel.fromJson(Map<String, dynamic> json) =>
      _$ParentAlertModelFromJson(json);
}
```

- [ ] **Step 4: Create barrel export**

```dart
// lib/features/parent/data/models/models.dart
export 'child_model.dart';
export 'child_overview_model.dart';
export 'parent_alert_model.dart';
```

- [ ] **Step 5: Run build_runner**

```bash
cd /Users/duongwthuj/develop/mobile/40Study && flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/parent/data/models/
git commit -m "feat(parent): add data models for parent feature"
```

---

### Task 2: API Client & Repository

**Files:**
- Create: `lib/features/parent/data/parent_api_client.dart`
- Create: `lib/features/parent/repository/parent_repository.dart`
- Create: `lib/features/parent/repository/parent_repository_impl.dart`

**Consumes:** Models from Task 1
**Produces:**
- `ParentRepository.getChildren()` returns `Result<List<ChildModel>>`
- `ParentRepository.getChildOverview(childId)` returns `Result<ChildOverviewModel>`
- `ParentRepository.getAlerts()` returns `Result<List<ParentAlertModel>>`

- [ ] **Step 1: Create parent_api_client.dart**

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:study/features/parent/data/models/models.dart';

part 'parent_api_client.g.dart';

@RestApi()
abstract class ParentApiClient {
  factory ParentApiClient(Dio dio, {String baseUrl}) = _ParentApiClient;

  @GET('/me/children')
  Future<List<ChildModel>> getChildren();

  @GET('/parent/children/{id}/overview')
  Future<ChildOverviewModel> getChildOverview(@Path('id') String childId);

  @GET('/parent/alerts')
  Future<List<ParentAlertModel>> getAlerts();
}
```

- [ ] **Step 2: Create parent_repository.dart (interface)**

```dart
import 'package:study/core/error/result.dart';
import 'package:study/features/parent/data/models/models.dart';

abstract class ParentRepository {
  Future<Result<List<ChildModel>>> getChildren();
  Future<Result<ChildOverviewModel>> getChildOverview(String childId);
  Future<Result<List<ParentAlertModel>>> getAlerts();
}
```

- [ ] **Step 3: Create parent_repository_impl.dart**

```dart
import 'package:study/core/error/failures.dart';
import 'package:study/core/error/result.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/data/parent_api_client.dart';
import 'package:study/features/parent/repository/parent_repository.dart';

class ParentRepositoryImpl implements ParentRepository {
  ParentRepositoryImpl(this._apiClient);

  final ParentApiClient _apiClient;

  @override
  Future<Result<List<ChildModel>>> getChildren() async {
    try {
      final children = await _apiClient.getChildren();
      return Result.success(children);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<ChildOverviewModel>> getChildOverview(String childId) async {
    try {
      final overview = await _apiClient.getChildOverview(childId);
      return Result.success(overview);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<List<ParentAlertModel>>> getAlerts() async {
    try {
      final alerts = await _apiClient.getAlerts();
      return Result.success(alerts);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
```

- [ ] **Step 4: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/parent/data/ lib/features/parent/repository/
git commit -m "feat(parent): add API client and repository"
```

---

### Task 3: ChildSelectorCubit

**Files:**
- Create: `lib/features/parent/bloc/child_selector/child_selector_cubit.dart`
- Create: `lib/features/parent/bloc/child_selector/child_selector_state.dart`

**Consumes:** `ChildModel` from Task 1
**Produces:** `ChildSelectorCubit.select(child)`, `state.selectedChild`

- [ ] **Step 1: Create child_selector_state.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/parent/data/models/models.dart';

part 'child_selector_state.freezed.dart';

@freezed
class ChildSelectorState with _$ChildSelectorState {
  const factory ChildSelectorState({
    @Default([]) List<ChildModel> children,
    ChildModel? selectedChild,
  }) = _ChildSelectorState;
}
```

- [ ] **Step 2: Create child_selector_cubit.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_state.dart';
import 'package:study/features/parent/data/models/models.dart';

class ChildSelectorCubit extends Cubit<ChildSelectorState> {
  ChildSelectorCubit() : super(const ChildSelectorState());

  void setChildren(List<ChildModel> children) {
    emit(state.copyWith(
      children: children,
      selectedChild: children.isNotEmpty ? children.first : null,
    ));
  }

  void select(ChildModel child) {
    emit(state.copyWith(selectedChild: child));
  }

  void selectById(String childId) {
    final child = state.children.firstWhere(
      (c) => c.id == childId,
      orElse: () => state.children.first,
    );
    select(child);
  }
}
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/parent/bloc/child_selector/
git commit -m "feat(parent): add ChildSelectorCubit for child switching"
```

---

### Task 4: ChildrenBloc

**Files:**
- Create: `lib/features/parent/bloc/children/children_bloc.dart`
- Create: `lib/features/parent/bloc/children/children_event.dart`
- Create: `lib/features/parent/bloc/children/children_state.dart`

**Consumes:** `ParentRepository` from Task 2
**Produces:** `ChildrenBloc` that loads children list on `ChildrenStarted`

- [ ] **Step 1: Create children_event.dart**

```dart
sealed class ChildrenEvent {}

final class ChildrenStarted extends ChildrenEvent {}

final class ChildrenRefreshed extends ChildrenEvent {}
```

- [ ] **Step 2: Create children_state.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/parent/data/models/models.dart';

part 'children_state.freezed.dart';

@freezed
sealed class ChildrenState with _$ChildrenState {
  const factory ChildrenState.initial() = ChildrenInitial;
  const factory ChildrenState.loading() = ChildrenLoading;
  const factory ChildrenState.success(List<ChildModel> children) = ChildrenSuccess;
  const factory ChildrenState.failure(String message) = ChildrenFailure;
}
```

- [ ] **Step 3: Create children_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/children/children_event.dart';
import 'package:study/features/parent/bloc/children/children_state.dart';
import 'package:study/features/parent/repository/parent_repository.dart';

class ChildrenBloc extends Bloc<ChildrenEvent, ChildrenState> {
  ChildrenBloc(this._repository) : super(const ChildrenInitial()) {
    on<ChildrenStarted>(_onStarted);
    on<ChildrenRefreshed>(_onRefreshed);
  }

  final ParentRepository _repository;

  Future<void> _onStarted(
    ChildrenStarted event,
    Emitter<ChildrenState> emit,
  ) async {
    emit(const ChildrenLoading());
    await _loadChildren(emit);
  }

  Future<void> _onRefreshed(
    ChildrenRefreshed event,
    Emitter<ChildrenState> emit,
  ) async {
    await _loadChildren(emit);
  }

  Future<void> _loadChildren(Emitter<ChildrenState> emit) async {
    final result = await _repository.getChildren();
    result.when(
      success: (children) => emit(ChildrenSuccess(children)),
      failure: (error) => emit(ChildrenFailure(error.message)),
    );
  }
}
```

- [ ] **Step 4: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/parent/bloc/children/
git commit -m "feat(parent): add ChildrenBloc for loading children list"
```

---

### Task 5: Dashboard BLoC

**Files:**
- Create: `lib/features/parent/bloc/dashboard/parent_dashboard_bloc.dart`
- Create: `lib/features/parent/bloc/dashboard/parent_dashboard_event.dart`
- Create: `lib/features/parent/bloc/dashboard/parent_dashboard_state.dart`

**Consumes:** `ParentRepository`, models from Task 1
**Produces:** Dashboard state with alerts, children overviews, monthly stats

- [ ] **Step 1: Create parent_dashboard_event.dart**

```dart
sealed class ParentDashboardEvent {}

final class ParentDashboardStarted extends ParentDashboardEvent {}

final class ParentDashboardRefreshed extends ParentDashboardEvent {}
```

- [ ] **Step 2: Create parent_dashboard_state.dart**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:study/features/parent/data/models/models.dart';

part 'parent_dashboard_state.freezed.dart';

@freezed
class MonthlyStats with _$MonthlyStats {
  const factory MonthlyStats({
    @Default(0) int totalCourses,
    @Default(0) double totalStudyHours,
    @Default(0) double avgAttendance,
    @Default(0) double totalExpenses,
  }) = _MonthlyStats;
}

@freezed
sealed class ParentDashboardState with _$ParentDashboardState {
  const factory ParentDashboardState.initial() = ParentDashboardInitial;
  const factory ParentDashboardState.loading() = ParentDashboardLoading;
  const factory ParentDashboardState.success({
    required List<ParentAlertModel> alerts,
    required List<ChildOverviewModel> childOverviews,
    required MonthlyStats monthlyStats,
  }) = ParentDashboardSuccess;
  const factory ParentDashboardState.failure(String message) = ParentDashboardFailure;
}
```

- [ ] **Step 3: Create parent_dashboard_bloc.dart**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_event.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_state.dart';
import 'package:study/features/parent/repository/parent_repository.dart';

class ParentDashboardBloc
    extends Bloc<ParentDashboardEvent, ParentDashboardState> {
  ParentDashboardBloc(this._repository, this._childSelector)
      : super(const ParentDashboardInitial()) {
    on<ParentDashboardStarted>(_onStarted);
    on<ParentDashboardRefreshed>(_onRefreshed);
  }

  final ParentRepository _repository;
  final ChildSelectorCubit _childSelector;

  Future<void> _onStarted(
    ParentDashboardStarted event,
    Emitter<ParentDashboardState> emit,
  ) async {
    emit(const ParentDashboardLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    ParentDashboardRefreshed event,
    Emitter<ParentDashboardState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ParentDashboardState> emit) async {
    final children = _childSelector.state.children;
    if (children.isEmpty) {
      emit(const ParentDashboardFailure('Chua co thong tin con'));
      return;
    }

    // Load alerts and overviews in parallel
    final alertsResult = await _repository.getAlerts();
    final overviewFutures = children.map(
      (c) => _repository.getChildOverview(c.id),
    );
    final overviewResults = await Future.wait(overviewFutures);

    if (alertsResult.isFailure) {
      emit(ParentDashboardFailure(alertsResult.errorOrNull?.message ?? 'Loi'));
      return;
    }

    final overviews = overviewResults
        .where((r) => r.isSuccess)
        .map((r) => r.valueOrNull!)
        .toList();

    // Calculate monthly stats
    final stats = MonthlyStats(
      totalCourses: children.fold(0, (sum, c) => sum + c.enrolledCourses),
      totalStudyHours: overviews.fold(0, (sum, o) => sum + o.studyHoursWeek),
      avgAttendance: overviews.isEmpty
          ? 0
          : overviews.fold(0.0, (sum, o) => sum + o.attendanceRate) /
              overviews.length,
      totalExpenses: 0, // Phase 3
    );

    emit(ParentDashboardSuccess(
      alerts: alertsResult.valueOrNull ?? [],
      childOverviews: overviews,
      monthlyStats: stats,
    ));
  }
}
```

- [ ] **Step 4: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/parent/bloc/dashboard/
git commit -m "feat(parent): add ParentDashboardBloc"
```

---

### Task 6: Shared Widgets

**Files:**
- Create: `lib/features/parent/presentation/widgets/child_switcher.dart`
- Create: `lib/features/parent/presentation/widgets/alert_card.dart`
- Create: `lib/features/parent/presentation/widgets/child_overview_card.dart`
- Create: `lib/features/parent/presentation/widgets/stat_card.dart`

**Consumes:** Models, ChildSelectorCubit
**Produces:** Reusable widgets for all parent screens

- [ ] **Step 1: Create child_switcher.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_state.dart';
import 'package:study/features/parent/data/models/models.dart';

class ChildSwitcher extends StatelessWidget {
  const ChildSwitcher({super.key, this.showAll = false});

  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<ChildSelectorCubit, ChildSelectorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showAll)
                _ChildChip(
                  label: 'Tat ca',
                  isSelected: state.selectedChild == null,
                  onTap: () {
                    // Handle "all" selection if needed
                  },
                ),
              ...state.children.map((child) => _ChildChip(
                    label: child.fullName,
                    avatarUrl: child.avatarUrl,
                    isSelected: state.selectedChild?.id == child.id,
                    onTap: () {
                      context.read<ChildSelectorCubit>().select(child);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.avatarUrl,
  });

  final String label;
  final String? avatarUrl;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: avatarUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl!))
            : null,
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: cs.primaryContainer,
        checkmarkColor: cs.onPrimaryContainer,
      ),
    );
  }
}
```

- [ ] **Step 2: Create alert_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, this.onTap});

  final ParentAlertModel alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (icon, color) = switch (alert.severity) {
      AlertSeverity.critical => (Icons.error, cs.error),
      AlertSeverity.warning => (Icons.warning, Colors.orange),
      AlertSeverity.info => (Icons.info, cs.primary),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(alert.message),
        subtitle: Text(alert.childName),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

- [ ] **Step 3: Create child_overview_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';

class ChildOverviewCard extends StatelessWidget {
  const ChildOverviewCard({
    super.key,
    required this.child,
    this.overview,
    this.onTap,
  });

  final ChildModel child;
  final ChildOverviewModel? overview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = overview?.progressPercent ?? child.progressPercent;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: child.avatarUrl != null
                        ? NetworkImage(child.avatarUrl!)
                        : null,
                    child: child.avatarUrl == null
                        ? Text(child.fullName[0])
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (child.className != null)
                          Text(
                            child.className!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${progress.toStringAsFixed(0)}% hoan thanh'),
                  Text('${child.enrolledCourses} khoa hoc'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create stat_card.dart**

```dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cs.primary),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Create barrel export**

```dart
// lib/features/parent/presentation/widgets/widgets.dart
export 'alert_card.dart';
export 'child_overview_card.dart';
export 'child_switcher.dart';
export 'stat_card.dart';
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/parent/presentation/widgets/
git commit -m "feat(parent): add shared widgets"
```

---

### Task 7: Dashboard Screen

**Files:**
- Create: `lib/features/parent/presentation/dashboard/parent_dashboard_screen.dart`

**Consumes:** All widgets from Task 6, BLoCs from Tasks 3-5

- [ ] **Step 1: Create parent_dashboard_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_state.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_bloc.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_state.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParentDashboardBloc, ParentDashboardState>(
      builder: (context, state) {
        return switch (state) {
          ParentDashboardInitial() ||
          ParentDashboardLoading() =>
            const Center(child: CircularProgressIndicator()),
          ParentDashboardFailure(:final message) =>
            Center(child: Text(message)),
          ParentDashboardSuccess(
            :final alerts,
            :final childOverviews,
            :final monthlyStats,
          ) =>
            _DashboardContent(
              alerts: alerts,
              monthlyStats: monthlyStats,
            ),
        };
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.alerts,
    required this.monthlyStats,
  });

  final List<ParentAlertModel> alerts;
  final MonthlyStats monthlyStats;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<ParentDashboardBloc>()
            .add(ParentDashboardRefreshed());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Alerts section
          if (alerts.isNotEmpty) ...[
            Text(
              'Canh bao',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...alerts.take(3).map((a) => AlertCard(alert: a)),
            const SizedBox(height: 16),
          ],

          // Children section
          Text(
            'Con cua toi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          BlocBuilder<ChildSelectorCubit, ChildSelectorState>(
            builder: (context, state) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.children
                    .map((child) => SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 2,
                          child: ChildOverviewCard(
                            child: child,
                            onTap: () {
                              context.read<ChildSelectorCubit>().select(child);
                              // Navigate to progress screen
                            },
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),

          // Monthly stats
          Text(
            'Tong quan thang nay',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.book,
                  value: '${monthlyStats.totalCourses}',
                  label: 'Khoa hoc',
                ),
              ),
              Expanded(
                child: StatCard(
                  icon: Icons.timer,
                  value: '${monthlyStats.totalStudyHours.toStringAsFixed(0)}h',
                  label: 'Hoc tap',
                ),
              ),
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle,
                  value: '${monthlyStats.avgAttendance.toStringAsFixed(0)}%',
                  label: 'Diem danh',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/parent/presentation/dashboard/
git commit -m "feat(parent): add dashboard screen"
```

---

### Task 8: Parent Shell (Bottom Navigation)

**Files:**
- Create: `lib/features/parent/presentation/parent_shell.dart`
- Modify: `lib/app/app.dart` (add route)

**Consumes:** Dashboard screen, BLoC providers

- [ ] **Step 1: Create parent_shell.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/children/children_bloc.dart';
import 'package:study/features/parent/bloc/children/children_event.dart';
import 'package:study/features/parent/bloc/children/children_state.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_bloc.dart';
import 'package:study/features/parent/bloc/dashboard/parent_dashboard_event.dart';
import 'package:study/features/parent/presentation/dashboard/parent_dashboard_screen.dart';
import 'package:study/features/parent/repository/parent_repository.dart';

enum ParentTab { dashboard, progress, attendance, schedule, expenses }

class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  ParentTab _currentTab = ParentTab.dashboard;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChildrenBloc(getIt<ParentRepository>())
            ..add(ChildrenStarted()),
        ),
        BlocProvider(create: (_) => ChildSelectorCubit()),
      ],
      child: BlocListener<ChildrenBloc, ChildrenState>(
        listener: (context, state) {
          if (state is ChildrenSuccess) {
            context.read<ChildSelectorCubit>().setChildren(state.children);
          }
        },
        child: Builder(
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (ctx) => ParentDashboardBloc(
                    getIt<ParentRepository>(),
                    ctx.read<ChildSelectorCubit>(),
                  )..add(ParentDashboardStarted()),
                ),
              ],
              child: Scaffold(
                body: _buildBody(),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _currentTab.index,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentTab = ParentTab.values[index];
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Trang chu',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.trending_up_outlined),
                      selectedIcon: Icon(Icons.trending_up),
                      label: 'Tien do',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(Icons.calendar_today),
                      label: 'Diem danh',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.schedule_outlined),
                      selectedIcon: Icon(Icons.schedule),
                      label: 'Lich hoc',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.payments_outlined),
                      selectedIcon: Icon(Icons.payments),
                      label: 'Chi phi',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (_currentTab) {
      ParentTab.dashboard => const ParentDashboardScreen(),
      ParentTab.progress => const Center(child: Text('Tien do - Phase 2')),
      ParentTab.attendance => const Center(child: Text('Diem danh - Phase 2')),
      ParentTab.schedule => const Center(child: Text('Lich hoc - Phase 3')),
      ParentTab.expenses => const Center(child: Text('Chi phi - Phase 3')),
    };
  }
}
```

- [ ] **Step 2: Register DI for ParentRepository**

Add to `lib/di/di_repository_module.dart`:

```dart
@module
abstract class DiRepositoryModule {
  // ... existing code ...

  @lazySingleton
  ParentRepository parentRepository(ParentApiClient client) =>
      ParentRepositoryImpl(client);
}
```

- [ ] **Step 3: Register ParentApiClient in DI**

Add to `lib/di/di_data_module.dart`:

```dart
@module
abstract class DiDataModule {
  // ... existing code ...

  @lazySingleton
  ParentApiClient parentApiClient(Dio dio) => ParentApiClient(dio);
}
```

- [ ] **Step 4: Add route for ParentShell**

Check existing routing pattern and add parent route.

- [ ] **Step 5: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/parent/presentation/parent_shell.dart lib/di/
git commit -m "feat(parent): add ParentShell with bottom navigation and DI setup"
```

---

## Phase 1 Complete

After completing all 8 tasks, Phase 1 delivers:
- Data models for children, overviews, alerts
- API client and repository
- ChildSelectorCubit for switching between children
- ChildrenBloc for loading children list
- ParentDashboardBloc for dashboard data
- Shared widgets: ChildSwitcher, AlertCard, ChildOverviewCard, StatCard
- Dashboard screen with alerts, children cards, monthly stats
- ParentShell with bottom navigation (other tabs placeholder)

**Next:** Phase 2 implements Progress and Attendance screens.
