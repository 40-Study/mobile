import 'package:study/features/parent/data/models/parent_home_data.dart';

/// Repository tổng hợp dữ liệu cho Parent Home Screen.
abstract class ParentHomeRepository {
  Future<ParentHomeData> getHomeDashboard({String? childId});
}
