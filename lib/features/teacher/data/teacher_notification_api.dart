import 'package:study/features/teacher/data/teacher_api.dart';

class TeacherNotification {
  TeacherNotification.fromJson(Map<String, dynamic> json)
    : id = json['id']?.toString() ?? '',
      type = json['notification_type']?.toString() ?? '',
      title = json['title']?.toString() ?? '',
      content = json['content']?.toString() ?? '',
      createdAt = DateTime.tryParse('${json['created_at']}')?.toLocal(),
      isRead = json['is_read'] == true,
      payload = teacherMap(json['payload']);

  final String id;
  final String type;
  final String title;
  final String content;
  final DateTime? createdAt;
  final bool isRead;
  final Map<String, dynamic> payload;
}

class TeacherNotificationApi {
  const TeacherNotificationApi(this.api);
  final TeacherApi api;
  static const pageSize = 20;

  Future<({List<TeacherNotification> items, bool hasMore})> list(
    int page,
  ) async {
    final data = teacherMap(
      await api.get(
        '/notifications/',
        query: {'page': page, 'page_size': pageSize},
      ),
    );
    final items = teacherList(data, keys: const ['notifications'])
        .map(TeacherNotification.fromJson)
        .where((notification) => notification.id.isNotEmpty)
        .toList();
    final total = data['total'];
    return (
      items: items,
      hasMore:
          items.isNotEmpty &&
          (total is num ? page * pageSize < total : items.length == pageSize),
    );
  }

  Future<int> unreadCount() async {
    final data = teacherMap(await api.get('/notifications/unread-count'));
    final count = data['unread_count'];
    return count is num ? count.toInt() : 0;
  }

  Future<void> markAsRead(String id) async {
    await api.patch('/notifications/${Uri.encodeComponent(id)}/read');
  }
}
