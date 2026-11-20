import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_workplace_controller.dart';

/// Preview has a personal workspace only; it never rotates the signed-in session.
class TeacherPreviewWorkplace extends TeacherWorkplaceController {
  TeacherPreviewWorkplace(TeacherApi api) : super(api: api);

  @override
  Future<void> initialize() async {
    activeOrg = null;
    organizations = [];
    error = null;
    initialized = true;
    notifyListeners();
  }
}
