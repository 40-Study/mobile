import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';
import 'package:study/features/student/bloc/notification/notification_state.dart';

import 'empty_view.dart';
import 'error_view.dart';
import 'notification_tile.dart';
import 'section_header.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: false,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationSuccess && state.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () => context
                      .read<NotificationBloc>()
                      .add(const NotificationMarkedAllRead()),
                  icon: Icon(Icons.done_all, size: 18, color: cs.primary),
                  label: Text(
                    'Đọc tất cả',
                    style: tt.labelMedium?.copyWith(color: cs.primary),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInProgress) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          if (state is NotificationFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<NotificationBloc>()
                  .add(const NotificationStarted()),
            );
          }

          if (state is NotificationSuccess) {
            if (state.notifications.isEmpty) {
              return const EmptyView();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const NotificationStarted());
                await Future<void>.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  if (state.todayList.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Hôm nay',
                      count: state.todayList.where((n) => !n.isRead).length,
                    ),
                    ...state.todayList.map((n) => NotificationTile(notification: n)),
                  ],
                  if (state.yesterdayList.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Hôm qua',
                      count: state.yesterdayList.where((n) => !n.isRead).length,
                    ),
                    ...state.yesterdayList.map((n) => NotificationTile(notification: n)),
                  ],
                  if (state.olderList.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Trước đó',
                      count: state.olderList.where((n) => !n.isRead).length,
                    ),
                    ...state.olderList.map((n) => NotificationTile(notification: n)),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
