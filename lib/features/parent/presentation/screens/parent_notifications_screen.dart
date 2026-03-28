import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/widgets/widgets.dart';

class ParentNotificationsScreen extends StatelessWidget {
  const ParentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Mock notifications for now
    final notifications = [
      const ParentNotificationModel(
        id: '1',
        title: 'Nguyen Van B vang buoi hoc ngay 23/03/2024',
        type: 'attendance',
        childId: '1',
        childName: 'Nguyen Van B',
        createdAt: '2 gio truoc',
      ),
      const ParentNotificationModel(
        id: '2',
        title: 'Nguyen Thi C dat diem 10 bai kiem tra Toan',
        type: 'grade',
        childId: '2',
        childName: 'Nguyen Thi C',
        createdAt: 'Hom qua',
        isRead: true,
      ),
      const ParentNotificationModel(
        id: '3',
        title: 'Lich hop phu huynh: 30/03/2024',
        type: 'event',
        createdAt: '2 ngay truoc',
        isRead: true,
      ),
      const ParentNotificationModel(
        id: '4',
        title: 'Nguyen Van B hoan thanh bai tap Toan',
        type: 'assignment',
        childId: '1',
        childName: 'Nguyen Van B',
        createdAt: '3 ngay truoc',
        isRead: true,
      ),
      const ParentNotificationModel(
        id: '5',
        title: 'Nguyen Thi C tham gia lop Anh Van moi',
        type: 'class',
        childId: '2',
        childName: 'Nguyen Thi C',
        createdAt: '1 tuan truoc',
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Thong bao'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Mark all as read
            },
            child: const Text('Doc tat ca'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Khong co thong bao nao',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ParentNotificationItem(
                    notification: notifications[index],
                    onTap: () {
                      // TODO: Navigate to notification detail
                    },
                  ),
                );
              },
            ),
    );
  }
}
