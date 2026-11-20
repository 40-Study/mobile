import 'package:flutter/material.dart';
import 'package:study/features/account/presentation/shared_account_content.dart';
import 'package:study/features/parent/presentation/children/manage_children_screen.dart';
import 'package:study/features/parent/presentation/profile/widgets/widgets.dart';
import 'package:study/theme/theme.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => SharedAccountContent(
    roleSettings: (context) => [
      SettingItem(
        icon: Icons.family_restroom_rounded,
        iconColor: AchievementColors.orange,
        title: 'Quản lý con',
        subtitle: 'Xem và liên kết hồ sơ con',
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const ManageChildrenScreen()),
        ),
      ),
    ],
  );
}
