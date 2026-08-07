import 'package:study/features/onboarding/models/onboarding_page_data.dart';
import 'package:study/features/onboarding/widgets/onboarding_illustrations.dart';

/// Danh sách 3 trang onboarding với custom illustrations.
List<OnboardingPageData> get onboardingPages => [
  OnboardingPageData(
    title: 'Làm chủ mọi kỹ năng',
    subtitle: 'Học đúng lộ trình, tiến bộ theo nhịp độ của riêng bạn.',
    highlightText: 'mọi kỹ năng',
    illustrationBuilder: (context, {required isActive}) =>
        AiCardIllustration(isActive: isActive),
  ),
  OnboardingPageData(
    title: 'Học qua thực hành',
    subtitle: 'Biến kiến thức thành năng lực qua bài tập và dự án thực tế.',
    highlightText: 'thực hành',
    illustrationBuilder: (context, {required isActive}) =>
        CodeEditorIllustration(isActive: isActive),
  ),
  OnboardingPageData(
    title: 'Cùng nhau tiến bộ',
    subtitle: 'Kết nối với cộng đồng người học và đội ngũ giảng viên.',
    highlightText: 'tiến bộ',
    buttonLabel: 'Bắt đầu học',
    illustrationBuilder: (context, {required isActive}) =>
        CommunityIllustration(isActive: isActive),
  ),
];
