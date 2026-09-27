import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/notification/notification_bloc.dart';
import 'package:study/features/student/bloc/notification/notification_event.dart';

import 'widgets/widgets.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => diContainer<NotificationBloc>()
        ..add(const NotificationStarted()),
      child: const NotificationView(),
    );
  }
}
