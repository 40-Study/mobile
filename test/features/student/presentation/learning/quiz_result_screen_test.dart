import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/quiz_question_model.dart';
import 'package:study/features/student/presentation/learning/quiz_result_screen.dart';

void main() {
  group('QuizResultScreen', () {
    const question = QuizQuestionModel(
      id: 'q1',
      question: 'Chọn các số chẵn',
      questionType: 'multiple_choice',
      answers: [
        QuizAnswerModel(id: 'a', answerText: '2', isCorrect: true),
        QuizAnswerModel(id: 'b', answerText: '4', isCorrect: true),
        QuizAnswerModel(id: 'c', answerText: '5'),
      ],
    );

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuizResultScreen(
            title: 'Quiz',
            correct: 0,
            total: 1,
            score: 0,
            questions: [question],
            // Thiếu 1 đáp án đúng → phải tính là sai
            userAnswers: {0: {0}},
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('should not list partially answered question as correct', (tester) async {
      await pump(tester);

      await tester.ensureVisible(find.text('Câu đúng'));
      await tester.tap(find.text('Câu đúng'));
      await tester.pumpAndSettle();
      expect(find.text('Chọn các số chẵn'), findsNothing);

      await tester.ensureVisible(find.text('Câu sai'));
      await tester.tap(find.text('Câu sai'));
      await tester.pumpAndSettle();
      expect(find.text('Chọn các số chẵn'), findsOneWidget);
    });
  });
}
