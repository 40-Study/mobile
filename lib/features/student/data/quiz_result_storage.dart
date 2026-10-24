import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lưu kết quả quiz vào local storage
class QuizResultStorage {
  static const _prefix = 'quiz_result_';

  static Future<void> saveResult({
    required String quizId,
    required int correctCount,
    required int totalCount,
    required double score,
    String? attemptId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'correctCount': correctCount,
      'totalCount': totalCount,
      'score': score,
      if (attemptId != null) 'attemptId': attemptId,
      'completedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString('$_prefix$quizId', jsonEncode(data));
  }

  static Future<QuizResultData?> getResult(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_prefix$quizId');
    if (json == null) return null;

    final data = jsonDecode(json) as Map<String, dynamic>;
    return QuizResultData(
      correctCount: data['correctCount'] as int,
      totalCount: data['totalCount'] as int,
      score: (data['score'] as num).toDouble(),
      attemptId: data['attemptId'] as String?,
    );
  }

  static Future<bool> hasResult(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_prefix$quizId');
  }
}

class QuizResultData {
  const QuizResultData({
    required this.correctCount,
    required this.totalCount,
    required this.score,
    this.attemptId,
  });

  final int correctCount;
  final int totalCount;
  final double score;
  final String? attemptId;
}

