import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/models.dart';
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

    testWidgets('QuizResultScreen filters right and wrong questions on stat card tap', (tester) async {
      const questions = [
        QuizQuestionModel(
          id: 'q1',
          question: 'Flutter là gì?',
          answers: [
            QuizAnswerModel(id: 'a1', answerText: 'UI Framework', isCorrect: true),
            QuizAnswerModel(id: 'a2', answerText: 'Database', isCorrect: false),
          ],
        ),
        QuizQuestionModel(
          id: 'q2',
          question: 'Widget nào là StatelessWidget?',
          answers: [
            QuizAnswerModel(id: 'a3', answerText: 'Container', isCorrect: true),
            QuizAnswerModel(id: 'a4', answerText: 'Checkbox', isCorrect: false),
          ],
        ),
      ];

      // q1 is correct (chose 0), q2 is wrong (chose 1, correct is 0)
      const userAnswers = {0: 0, 1: 1};

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizResultScreen(
            title: 'Test Quiz',
            correct: 1,
            total: 2,
            score: 50,
            questions: questions,
            userAnswers: userAnswers,
          ),
        ),
      );

      // Initially shows all 2 questions
      expect(find.text('Câu 1'), findsOneWidget);
      expect(find.text('Câu 2'), findsOneWidget);

      // Tap "Câu sai"
      await tester.tap(find.text('Câu sai'));
      await tester.pumpAndSettle();

      // Only Câu 2 is shown
      expect(find.text('Câu 1'), findsNothing);
      expect(find.text('Câu 2'), findsOneWidget);

      // Tap "Câu đúng"
      await tester.tap(find.text('Câu đúng'));
      await tester.pumpAndSettle();

      // Only Câu 1 is shown
      expect(find.text('Câu 1'), findsOneWidget);
      expect(find.text('Câu 2'), findsNothing);

      // Tap "Tổng câu"
      await tester.tap(find.text('Tổng câu'));
      await tester.pumpAndSettle();

      // Both shown again
      expect(find.text('Câu 1'), findsOneWidget);
      expect(find.text('Câu 2'), findsOneWidget);
    });
  });
}
