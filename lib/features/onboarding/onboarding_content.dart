import 'package:study/features/onboarding/models/onboarding_page_data.dart';
import 'package:study/features/onboarding/widgets/onboarding_illustrations.dart';

/// Danh sách 3 trang onboarding với custom illustrations.
List<OnboardingPageData> get onboardingPages => [
  OnboardingPageData(
    title: 'Master Any Skill',
    subtitle: 'Unlock your potential with AI-driven learning paths.',
    highlightText: 'Any Skill',
    illustrationBuilder: (context, {required isActive}) =>
        AiCardIllustration(isActive: isActive),
  ),
  OnboardingPageData(
    title: 'Learn by Doing',
    subtitle: 'Dive into interactive sandboxes where you build real projects.',
    highlightText: 'Doing',
    illustrationBuilder: (context, {required isActive}) =>
        CodeEditorIllustration(isActive: isActive),
  ),
  OnboardingPageData(
    title: 'Join the Community',
    subtitle: 'Connect with thousands of students and expert mentors.',
    highlightText: 'Community',
    buttonLabel: 'Get Started',
    illustrationBuilder: (context, {required isActive}) =>
        CommunityIllustration(isActive: isActive),
  ),
];
