import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/presentation/learning/quiz_result_screen.dart';
import 'package:study/features/student/presentation/learning/widgets/quiz/answer_option.dart';
import 'package:study/features/student/presentation/learning/widgets/quiz/question_card.dart';
import 'package:study/features/student/presentation/learning/widgets/quiz/question_review_card.dart';
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

    testWidgets('QuestionCard supports flag for review toggling', (tester) async {
      bool flagToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuestionCard(
              questionNumber: 3,
              totalQuestions: 10,
              question: 'Git commit là gì?',
              isFlagged: false,
              onToggleFlag: () {
                flagToggled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Xem lại'), findsOneWidget);
      await tester.tap(find.text('Xem lại'));
      expect(flagToggled, isTrue);
    });

    testWidgets('QuestionReviewCard displays correct status and explanation', (tester) async {
      const reviewItem = QuizReviewItemModel(
        index: 1,
        questionId: 'q1',
        questionText: 'Lệnh nào dùng để khởi tạo một Git repo?',
        answers: [
          QuizAnswerModel(id: 'a1', answerText: 'git init'),
          QuizAnswerModel(id: 'a2', answerText: 'git start'),
        ],
        selectedAnswerIds: ['a1'],
        correctAnswerIds: ['a1'],
        isCorrect: true,
        isSkipped: false,
        pointsEarned: 1.0,
        explanation: 'git init tạo ra thư mục .git để theo dõi phiên bản.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionReviewCard(
              index: 1,
              reviewItem: reviewItem,
            ),
          ),
        ),
      );

      expect(find.text('Câu 1'), findsOneWidget);
      expect(find.text('Chính xác'), findsOneWidget);
      expect(find.text('git init'), findsOneWidget);
      expect(find.text('Bạn đã chọn đúng'), findsOneWidget);
      expect(find.text('Giải thích kiến thức'), findsOneWidget);
      expect(find.text('git init tạo ra thư mục .git để theo dõi phiên bản.'), findsOneWidget);
    });


    testWidgets('QuizResultScreen with reviewItems correctly separates correct vs wrong answers', (tester) async {
      const reviewItems = [
        QuizReviewItemModel(
          index: 1,
          questionId: 'q1',
          questionText: 'Lệnh nào dùng để khởi tạo Git repo?',
          answers: [
            QuizAnswerModel(id: 'a1', answerText: 'git init'),
            QuizAnswerModel(id: 'a2', answerText: 'git start'),
          ],
          selectedAnswerIds: ['a1'],
          correctAnswerIds: ['a1'],
          isCorrect: true,
          isSkipped: false,
          pointsEarned: 1.0,
          explanation: 'git init là lệnh chính xác.',
        ),
        QuizReviewItemModel(
          index: 2,
          questionId: 'q2',
          questionText: 'Lệnh nào để tạo nhánh mới?',
          answers: [
            QuizAnswerModel(id: 'a3', answerText: 'git branch'),
            QuizAnswerModel(id: 'a4', answerText: 'git new'),
          ],
          selectedAnswerIds: ['a4'],
          correctAnswerIds: ['a3'],
          isCorrect: false,
          isSkipped: false,
          pointsEarned: 0.0,
          explanation: 'git branch dùng để tạo nhánh mới.',
        ),
      ];

      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizResultScreen(
            title: 'Git Basics Quiz',
            correct: 1,
            total: 2,
            score: 50,
            reviewItems: reviewItems,
          ),
        ),
      );

      // Initially shows all 2 questions
      expect(find.text('Câu 1'), findsOneWidget);
      expect(find.text('Câu 2'), findsOneWidget);
      expect(find.text('Chính xác'), findsOneWidget);
      expect(find.text('Chưa chính xác'), findsOneWidget);

      // Tap "Câu đúng"
      await tester.tap(find.text('Câu đúng'));
      await tester.pumpAndSettle();

      // Only Câu 1 (Chính xác) is shown
      expect(find.text('Câu 1'), findsOneWidget);
      expect(find.text('Câu 2'), findsNothing);
      expect(find.text('Chính xác'), findsOneWidget);
      expect(find.text('Chưa chính xác'), findsNothing);

      // Tap "Câu sai"
      await tester.tap(find.text('Câu sai'));
      await tester.pumpAndSettle();

      // Only Câu 2 (Chưa chính xác) is shown
      expect(find.text('Câu 1'), findsNothing);
      expect(find.text('Câu 2'), findsOneWidget);
      expect(find.text('Chưa chính xác'), findsOneWidget);
    });

    testWidgets('QuestionCard displays multiple choice badge and hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionCard(
              questionNumber: 3,
              totalQuestions: 3,
              question: 'Lệnh nào liên quan tới việc đưa thay đổi lên remote repository?',
              isMultipleChoice: true,
            ),
          ),
        ),
      );

      expect(find.text('Câu 3 / 3'), findsOneWidget);
      expect(find.text('Chọn nhiều đáp án'), findsOneWidget);
      expect(find.byIcon(Icons.checklist_rounded), findsOneWidget);
      expect(find.text('Có thể chọn nhiều hơn một đáp án đúng'), findsOneWidget);
    });

    testWidgets('AnswerOption renders checkbox icons when isMultipleChoice is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnswerOption(
                  index: 0,
                  text: 'git push',
                  isSelected: true,
                  isMultipleChoice: true,
                  onTap: () {},
                ),
                AnswerOption(
                  index: 1,
                  text: 'git commit',
                  isSelected: false,
                  isMultipleChoice: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank_rounded), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
    });

    testWidgets('QuestionReviewCard displays missed correct answer for multiple choice', (tester) async {
      const reviewItem = QuizReviewItemModel(
        index: 3,
        questionId: 'q3',
        questionText: 'Lệnh nào liên quan remote repo?',
        answers: [
          QuizAnswerModel(id: 'a1', answerText: 'git push'),
          QuizAnswerModel(id: 'a2', answerText: 'git push origin main'),
          QuizAnswerModel(id: 'a3', answerText: 'git commit'),
        ],
        selectedAnswerIds: ['a1'],
        correctAnswerIds: ['a1', 'a2'],
        isCorrect: false,
        isSkipped: false,
        pointsEarned: 0.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuestionReviewCard(
              index: 3,
              reviewItem: reviewItem,
            ),
          ),
        ),
      );

      expect(find.text('Câu 3'), findsOneWidget);
      expect(find.text('Chọn nhiều'), findsOneWidget);
      expect(find.text('Chưa chính xác'), findsOneWidget);
      expect(find.text('Bạn đã chọn đúng'), findsOneWidget);
      expect(find.text('Đáp án đúng (Chưa chọn)'), findsOneWidget);
    });
  });
}

