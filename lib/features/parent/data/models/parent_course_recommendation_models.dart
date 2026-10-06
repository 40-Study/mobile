import 'package:flutter/material.dart';

/// Item khóa học gợi ý trong danh sách đề xuất cá nhân hoá
@immutable
class ParentRecommendedCourseItem {
  const ParentRecommendedCourseItem({
    required this.id,
    required this.title,
    required this.reasonDescription,
    required this.tagLabel,
    required this.tagTextColor,
    required this.tagBgColor,
    required this.matchPercent,
    required this.sessionInfo,
    required this.teacherName,
    required this.tuitionFee,
    this.originalFee,
    required this.categoryFilter,
    this.isPersonalized = false,
  });

  final String id;
  final String title;
  final String reasonDescription;
  final String tagLabel;
  final Color tagTextColor;
  final Color tagBgColor;
  final int matchPercent;
  final String sessionInfo;
  final String teacherName;
  final int tuitionFee;
  final int? originalFee;
  final String categoryFilter;
  final bool isPersonalized;
}

/// Một chuyên đề trong đề cương học tập cốt lõi của khóa học
@immutable
class CourseSyllabusModule {
  const CourseSyllabusModule({
    required this.order,
    required this.title,
    required this.description,
    this.sessionCountLabel = '2 buổi',
  });

  final int order;
  final String title;
  final String description;
  final String sessionCountLabel;
}

/// Chi tiết đầy đủ của khóa học đề xuất (Course Detail)
@immutable
class ParentRecommendedCourseDetailModel {
  const ParentRecommendedCourseDetailModel({
    required this.courseId,
    required this.courseName,
    required this.subtitle,
    required this.childName,
    this.subjectTag = 'TOÁN HỌC NÂNG CAO',
    this.personalizedTag = 'Gợi ý riêng cho Minh',
    this.rating = 4.9,
    this.reviewCount = 128,
    this.studentCount = 340,
    required this.whyRecommendedReason,
    this.tuitionFee = 1600000,
    this.originalFee = 2200000,
    this.discountLabel = 'Tiết kiệm 27%',
    this.feeSupportText =
        'Hỗ trợ chia kỳ đóng phí linh hoạt · Hoàn 100% nếu không hài lòng',
    this.targetGrade = 'Lớp 10 (Nâng cao & Chuyên Toán)',
    this.durationText = '8 buổi (90 phút/buổi)',
    this.scheduleFixed = 'Thứ 3 & Thứ 5 · 15:00 - 16:30',
    this.formatText = 'Online trực tiếp tương tác (Sĩ số ≤ 12 HS)',
    this.materialsText = 'Tập sách bản cứng + Trợ giảng 1-1',
    this.teacherName = 'ThS. Hoàng Minh Tuấn',
    this.isTeacherVerified = true,
    required this.syllabusModules,
    this.guaranteeNote =
        'Đảm bảo quyền lợi hoàn 100% học phí nếu phụ huynh và con cảm thấy '
        'không phù hợp sau 2 buổi đầu.',
  });

  final String courseId;
  final String courseName;
  final String subtitle;
  final String childName;
  final String subjectTag;
  final String personalizedTag;
  final double rating;
  final int reviewCount;
  final int studentCount;
  final String whyRecommendedReason;

  final int tuitionFee;
  final int originalFee;
  final String discountLabel;
  final String feeSupportText;

  // Thông số lớp học
  final String targetGrade;
  final String durationText;
  final String scheduleFixed;
  final String formatText;
  final String materialsText;
  final String teacherName;
  final bool isTeacherVerified;

  // Đề cương cốt lõi
  final List<CourseSyllabusModule> syllabusModules;
  final String guaranteeNote;
}
