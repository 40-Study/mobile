import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lưu kết quả quiz vào local storage, keyed by userId
@lazySingleton
class QuizResultStorage {
  static const _prefix = 'quiz_result_';

  String _key(String userId, String quizId) => '$_prefix${userId}_$quizId';

  Future<void> saveResult({
    required String userId,
    required String quizId,
    required int correctCount,
    required int totalCount,
    required double score,
    String? attemptId,
    int timeSpentSeconds = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'correctCount': correctCount,
      'totalCount': totalCount,
      'score': score,
      if (attemptId != null) 'attemptId': attemptId,
      'timeSpentSeconds': timeSpentSeconds,
      'completedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_key(userId, quizId), jsonEncode(data));
  }

  Future<QuizResultData?> getResult(String userId, String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key(userId, quizId));
    if (json == null) return null;

    final data = jsonDecode(json) as Map<String, dynamic>;
    return QuizResultData(
      correctCount: data['correctCount'] as int,
      totalCount: data['totalCount'] as int,
      score: (data['score'] as num).toDouble(),
      attemptId: data['attemptId'] as String?,
      timeSpentSeconds: data['timeSpentSeconds'] as int? ?? 0,
    );
  }

  Future<bool> hasResult(String userId, String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key(userId, quizId));
  }

  /// Xóa tất cả quiz results - gọi khi logout/clear session
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Xóa legacy keys không có userId (migration)
  Future<void> clearLegacyKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) {
      if (!k.startsWith(_prefix)) return false;
      // Legacy key: quiz_result_<quizId> - không có underscore sau prefix
      final suffix = k.substring(_prefix.length);
      // New key format: quiz_result_<userId>_<quizId> - có underscore
      return !suffix.contains('_');
    }).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

}

class QuizResultData {
  const QuizResultData({
    required this.correctCount,
    required this.totalCount,
    required this.score,
    this.attemptId,
    this.timeSpentSeconds = 0,
  });

  final int correctCount;
  final int totalCount;
  final double score;
  final String? attemptId;
  final int timeSpentSeconds;
}

