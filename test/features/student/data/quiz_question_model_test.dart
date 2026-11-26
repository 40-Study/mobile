import 'package:flutter_test/flutter_test.dart';
import 'package:study/features/student/data/models/quiz_question_model.dart';

void main() {
  group('QuizQuestionModel', () {
    const multi = QuizQuestionModel(
      questionType: 'multiple_choice',
      answers: [
        QuizAnswerModel(isCorrect: true),
        QuizAnswerModel(isCorrect: true),
        QuizAnswerModel(),
      ],
    );
    const single = QuizQuestionModel(
      answers: [QuizAnswerModel(), QuizAnswerModel(isCorrect: true)],
    );

    test('should be wrong when multi-choice answer misses one correct option', () {
      expect(multi.isAnsweredCorrectly({0}), isFalse);
    });

    test('should be wrong when multi-choice answer has extra option', () {
      expect(multi.isAnsweredCorrectly({0, 1, 2}), isFalse);
    });

    test('should be correct when sets are equal', () {
      expect(multi.isAnsweredCorrectly({1, 0}), isTrue);
    });

    test('should compare single choice by index', () {
      expect(single.isAnsweredCorrectly(1), isTrue);
      expect(single.isAnsweredCorrectly(0), isFalse);
    });

    test('should be wrong when unanswered', () {
      expect(single.isAnsweredCorrectly(null), isFalse);
    });

    test('should be unknown when API sent no is_correct', () {
      const noKey = QuizQuestionModel(
        answers: [QuizAnswerModel(), QuizAnswerModel()],
      );
      expect(noKey.isAnsweredCorrectly(0), isNull);
    });
  });
}
