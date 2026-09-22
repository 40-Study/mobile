import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/data/bookmark_storage.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_bloc.dart';
import 'package:study/features/student/bloc/bookmark/bookmark_event.dart';

import 'widgets/widgets.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookmarkBloc(diContainer<BookmarkStorage>())
        ..add(const BookmarkStarted()),
      child: const BookmarkView(),
    );
  }
}
