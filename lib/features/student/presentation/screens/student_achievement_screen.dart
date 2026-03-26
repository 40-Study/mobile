import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/presentation/widgets/achievement/achievement_widgets.dart';
import 'package:study/theme/app_colors.dart';

class StudentAchievementScreen extends StatefulWidget {
  const StudentAchievementScreen({super.key});

  @override
  State<StudentAchievementScreen> createState() =>
      _StudentAchievementScreenState();
}

class _StudentAchievementScreenState
    extends State<StudentAchievementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenMargin,
                  AppSpacing.lg,
                  AppLayout.screenMargin,
                  0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: cs.gradientPrimary,
                        borderRadius: AppRadius.borderMd,
                        boxShadow: cs.shadowPrimary,
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: cs.onPrimary,
                        size: AppIconSize.lg,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Thanh tich hoc tap',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: AppRadius.borderMd,
                          border:
                              Border.all(color: cs.outline),
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          color: cs.primary,
                          size: AppIconSize.md,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenMargin,
                  AppSpacing.xxl,
                  AppLayout.screenMargin,
                  0,
                ),
                child: const ProfileHeroCard(),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: AchievementTabBarDelegate(
                tabCtrl: _tabCtrl,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabCtrl,
            children: const [
              BadgesTab(),
              CertificatesTab(),
              StickersTab(),
            ],
          ),
        ),
      ),
    );
  }
}
