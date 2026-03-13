import 'package:flutter/material.dart';
import 'package:study/features/onboarding/models/onboarding_page_data.dart';

/// Danh sách 3 trang splash/onboarding. Tách riêng để dễ chỉnh nội dung và tái sử dụng.
List<OnboardingPageData> get onboardingPages => const [
      OnboardingPageData(
        title: 'Chào mừng đến 40Study',
        subtitle:
            'Ứng dụng học tập đơn giản, giúp bạn quản lý và theo dõi tiến độ mỗi ngày.',
        icon: Icons.school_outlined,
      ),
      OnboardingPageData(
        title: 'Học mọi lúc mọi nơi',
        subtitle:
            'Truy cập tài liệu và bài tập ngay trên điện thoại, đồng bộ và luôn sẵn sàng.',
        icon: Icons.phone_android_outlined,
      ),
      OnboardingPageData(
        title: 'Bắt đầu ngay',
        subtitle:
            'Tạo thói quen học đều đặn và theo dõi tiến độ của bạn từ hôm nay.',
        icon: Icons.rocket_launch_outlined,
      ),
    ];
