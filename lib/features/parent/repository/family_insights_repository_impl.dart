import 'dart:async';

import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/repository/family_insights_repository.dart';

class FamilyInsightsRepositoryImpl implements FamilyInsightsRepository {
  FamilyInsightsRepositoryImpl({
    this.enablePreviewFallback = true,
  });

  final bool enablePreviewFallback;

  static const String studentMinhId = 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
  static const String studentLanId = 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

  final Set<String> _encouragedIds = {};
  bool _allRead = false;

  @override
  Future<List<FamilyInsightItem>> getInsights({String? childId}) async {
    // Giả lập độ trễ mạng nhẹ nhàng
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final items = _sampleInsights();
    final updatedItems = items.map((item) {
      return item.copyWith(
        hasEncouraged: _encouragedIds.contains(item.id),
        isRead: _allRead ? true : item.isRead,
      );
    }).toList();

    if (childId == null) {
      return updatedItems;
    }

    return updatedItems.where((item) => item.childId == childId).toList();
  }

  @override
  Future<void> sendEncouragement(String insightId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _encouragedIds.add(insightId);
  }

  @override
  Future<void> markAllAsRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _allRead = true;
  }

  List<FamilyInsightItem> _sampleInsights() {
    return [
      // Card 1: Minh - Tiến bộ vượt bậc
      const FamilyInsightItem(
        id: 'insight-1',
        childId: studentMinhId,
        childName: 'Minh',
        className: '10A1',
        subjectOrSkill: 'Đọc hiểu Tiếng Anh & Ngữ liệu',
        category: FamilyInsightCategory.breakthrough,
        timeAgoText: '2 giờ trước',
        title: 'Tiến bộ vượt bậc',
        description:
            'Cải thiện rõ rệt ở dạng bài Đọc hiểu so với 3 buổi trước. '
            'Em hoàn thành nhanh hơn 20% thời lượng và suy luận chính xác '
            '9/10 câu mức độ vận dụng cao.',
        highlightText: 'Đọc hiểu',
        metrics: [
          InsightMetric(
            label: 'TỶ LỆ CHÍNH XÁC',
            value: '90%',
            delta: '+15%',
            isPositive: true,
          ),
          InsightMetric(
            label: 'THỜI GIAN ĐỌC',
            value: '14 phút',
            delta: '-3.5m',
            isPositive: true,
          ),
        ],
        actionLabel: 'Xem chi tiết bài thi & gợi ý luyện tập →',
      ),

      // Card 2: Lan - Cần chú ý
      const FamilyInsightItem(
        id: 'insight-2',
        childId: studentLanId,
        childName: 'Lan',
        className: '7B',
        subjectOrSkill: 'Viết luận / Ngữ văn chuyên sâu',
        category: FamilyInsightCategory.attention,
        timeAgoText: 'Hôm qua',
        title: 'Cần chú ý',
        description:
            'Kết quả dạng viết luận nghị luận xã hội đang thấp hơn mức kỳ '
            'vọng. Lan cần củng cố lại phương pháp phân tách luận điểm và liên '
            'kết các đoạn mở - kết để tránh lan man.',
        highlightText: 'viết luận nghị luận xã hội',
        teacherQuote:
            'GV bộ môn đã gửi dàn ý mẫu cho Lan ôn tập cuối tuần. '
            'Gia đình nên nhắc bé dành 20 phút viết thử 1 đoạn văn.',
        actionLabel: 'Xem lộ trình bổ trợ kỹ năng viết →',
      ),

      // Card 3: Minh - Khen thưởng & Thói quen tự học
      const FamilyInsightItem(
        id: 'insight-3',
        childId: studentMinhId,
        childName: 'Minh',
        className: '10A1',
        subjectOrSkill: 'Kỷ luật & Thói quen tự học',
        category: FamilyInsightCategory.reward,
        timeAgoText: '3 ngày trước',
        title: 'Khen thưởng',
        description:
            'Minh đã duy trì xuất sắc chuỗi chuyên cần 5 ngày liên tiếp '
            'trên ứng dụng 40Study. Hoàn thành 100% nhiệm vụ bài tập về nhà '
            'đúng hạn.',
        highlightText: 'chuyên cần 5 ngày liên tiếp',
        streakInfo: InsightStreakInfo(
          currentDays: 5,
          activeDayLabels: ['T2', 'T3', 'T4', 'T5', 'T6'],
        ),
      ),
    ];
  }
}
