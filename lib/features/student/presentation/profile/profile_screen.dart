import 'package:flutter/material.dart';
import 'package:study/features/account/presentation/shared_account_content.dart';
import 'package:study/features/student/presentation/portfolio/portfolio_screen.dart';
import 'package:study/features/student/presentation/profile/widgets/widgets.dart';
import 'package:study/features/student/presentation/widgets/widgets.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => SharedAccountContent(
    header: const StudentAppHeader(
      categoryLabel: 'TÀI KHOẢN HỌC VIÊN',
      title: 'Thông tin cá nhân',
      icon: Icons.person_rounded,
      showNotification: false,
      showAvatar: false,
    ),
    roleSettings: (context) => [
      SettingItem(
        icon: Icons.web_rounded,
        iconColor: AchievementColors.purple,
        title: AppLocalizations.of(context)!.portfolio,
        subtitle: AppLocalizations.of(context)!.viewPortfolio,
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const PortfolioScreen()),
        ),
      ),
    ],
  );
}
