import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/quiz_question_model.dart';

/// Model đại diện cho 1 câu hỏi trong bài review kết quả quiz sau khi nộp
class QuizReviewItemModel extends Equatable {
  const QuizReviewItemModel({
    required this.index,
    required this.questionId,
    required this.questionText,
    required this.answers,
    required this.selectedAnswerIds,
    required this.correctAnswerIds,
    required this.isCorrect,
    required this.isSkipped,
    required this.pointsEarned,
    this.explanation,
  });

  final int index;
  final String questionId;
  final String questionText;
  final List<QuizAnswerModel> answers;
  final List<String> selectedAnswerIds;
  final List<String> correctAnswerIds;
  final bool isCorrect;
  final bool isSkipped;
  final double pointsEarned;
  final String? explanation;

  @override
  List<Object?> get props => [
        index,
        questionId,
        questionText,
        answers,
        selectedAnswerIds,
        correctAnswerIds,
        isCorrect,
        isSkipped,
        pointsEarned,
        explanation,
      ];
}
