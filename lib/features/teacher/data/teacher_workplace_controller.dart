import 'package:flutter/foundation.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/features/auth/data/models/auth_response.dart';
import 'package:study/features/auth/data/models/organization_model.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/teacher/data/teacher_api.dart';

/// Organization changes rotate the real session, then invalidate Teacher views.
class TeacherWorkplaceController extends ChangeNotifier {
  TeacherWorkplaceController({
    TeacherApi? api,
    AuthStorage? storage,
    AuthRepository? authRepository,
  }) : _api = api ?? TeacherApi(),
       _storage = storage ?? diContainer<AuthStorage>(),
       _authRepository = authRepository ?? diContainer<AuthRepository>();
  final TeacherApi _api;
  final AuthStorage _storage;
  final AuthRepository _authRepository;
  OrganizationModel? activeOrg;
  List<OrganizationModel> organizations = [];
  bool initialized = false;
  bool busy = false;
  String? error;
  int revision = 0;
  bool _disposed = false;

  Future<void> initialize() async {
    try {
      final saved = await _storage.getActiveOrg();
      final memberships = <Map<String, dynamic>>[];
      for (var page = 1; ; page++) {
        final raw = teacherMap(
          await _api.get(
            '/me/organizations',
            query: {'page': page, 'pageSize': 100},
          ),
        );
        if (_disposed) return;
        final rows = teacherList(raw, keys: const ['organizations']);
        memberships.addAll(rows);
        final total = raw['total'];
        if (rows.isEmpty ||
            (total is num && memberships.length >= total) ||
            (total == null && rows.length < 100))
          break;
      }
      if (_disposed) return;
      activeOrg = saved;
      organizations = memberships
          .where((e) => e['status'] == 'active')
          .map(
            (e) => OrganizationModel(
              id: '${e['id'] ?? e['organization_id']}',
              name: '${e['name'] ?? e['organization_name'] ?? 'Tổ chức'}',
            ),
          )
          .toList();
      if (saved != null && !organizations.any((org) => org.id == saved.id)) {
        throw const FormatException(
          'Bạn không còn là thành viên đang hoạt động của nơi làm việc đã chọn. '
          'Chọn lại nơi làm việc hoặc đăng nhập lại.',
        );
      }
      error = null;
    } catch (e) {
      if (_disposed) return;
      // Do not silently fall back to personal data if org discovery failed.
      error = teacherErrorMessage(e);
    }
    if (_disposed) return;
    initialized = true;
    notifyListeners();
  }

  Future<void> select(OrganizationModel? org) async {
    if (busy || !initialized || org?.id == activeOrg?.id) return;
    if (org != null && !organizations.any((e) => e.id == org.id)) {
      throw const FormatException('Nơi làm việc này không còn khả dụng.');
    }
    busy = true;
    error = null;
    notifyListeners();
    try {
      final raw = await _api.post(
        '/auth/select-org',
        data: {'organization_id': org?.id ?? ''},
      );
      if (_disposed) return;
      var response = AuthResponse.fromJson(teacherMap(raw));
      if (response.accessToken == null || response.refreshToken == null) {
        throw const FormatException(
          'Chưa nhận được phiên đăng nhập mới. Vui lòng đăng nhập lại.',
        );
      }
      response = response.copyWith(
        activeProfile: await _storage.getActiveProfile(),
      );
      if (_disposed) return;
      await _authRepository.saveSession(response);
      if (_disposed) return;
      activeOrg = response.activeOrg;
      revision++;
    } catch (e) {
      if (!_disposed) error = teacherErrorMessage(e);
      rethrow;
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
