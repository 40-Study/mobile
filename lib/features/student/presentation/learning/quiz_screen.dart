import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_bloc.dart';
import 'package:study/features/student/bloc/quiz/quiz_event.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/di/di_container.dart';

import 'widgets/quiz/quiz_view.dart';

/// Entry point cho quiz, cung cấp BlocProvider
class QuizScreen extends StatelessWidget {
  const QuizScreen({
    super.key,
    required this.quizId,
    required this.title,
    this.duration = 5,
  });

  final String quizId;
  final String title;
  final int duration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizBloc(diContainer<StudentRepository>())
        ..add(QuizStarted(quizId)),
      child: QuizView(quizId: quizId, title: title, duration: duration),
    );
  }
}
