import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/presentation/learning/quiz_result_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/quiz/answer_option.dart';
import 'package:study/features/student/presentation/learning/widgets/quiz/question_card.dart';
import 'package:study/features/student/presentation/learning/widgets/quiz/score_circle.dart';

void main() {
  group('Quiz UI Flow Widgets Test', () {
    testWidgets('QuestionCard displays question and index correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionCard(
              questionNumber: 2,
              totalQuestions: 5,
              question: 'Flutter là framework của ngôn ngữ nào?',
            ),
          ),
        ),
      );

      expect(find.text('Câu 2 / 5'), findsOneWidget);
      expect(find.text('Flutter là framework của ngôn ngữ nào?'), findsOneWidget);
    });

    testWidgets('AnswerOption renders unselected and selected states', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnswerOption(
              index: 0,
              text: 'Dart',
              isSelected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text('Dart'));
      expect(tapped, isTrue);
    });

    testWidgets('ScoreCircle displays percent score and trophy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreCircle(percent: 85, passed: true),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Điểm số'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });

    testWidgets('QuizResultScreen displays passed result, stats and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizResultScreen(
            title: 'Kiểm tra chương 1',
            correct: 8,
            total: 10,
            score: 80,
            quizId: 'quiz_123',
            duration: 10,
          ),
        ),
      );

      expect(find.text('Kết quả bài kiểm tra'), findsOneWidget);
      expect(find.text('Chúc mừng bạn đã đạt! 👏'), findsOneWidget);
      expect(find.text('8'), findsOneWidget); // Câu đúng
      expect(find.text('2'), findsOneWidget); // Câu sai
      expect(find.text('10'), findsOneWidget); // Tổng câu
      expect(find.text('Đạt yêu cầu (≥70%)'), findsOneWidget);
      expect(find.text('Quay về bài học'), findsOneWidget);
      expect(find.text('Làm lại bài kiểm tra'), findsOneWidget);
    });
  });
}
