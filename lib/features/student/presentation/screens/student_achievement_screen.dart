import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/bloc/achievement/achievement_cubit.dart';
import 'package:study/features/student/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/features/student/presentation/screens/leaderboard_screen.dart';
import 'package:study/features/student/presentation/widgets/achievement/achievement_widgets.dart';
import 'package:study/theme/app_colors.dart';

class StudentAchievementScreen extends StatelessWidget {
  const StudentAchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AchievementCubit(
            repository: context.read<StudentRepository>(),
          )..loadAchievements(),
        ),
        BlocProvider(
          create: (context) => LeaderboardCubit(
            repository: context.read<StudentRepository>(),
          )..loadLeaderboard(),
        ),
      ],
      child: const _AchievementScreenContent(),
    );
  }
}

class _AchievementScreenContent extends StatefulWidget {
  const _AchievementScreenContent();

  @override
  State<_AchievementScreenContent> createState() =>
      _AchievementScreenContentState();
}

class _AchievementScreenContentState extends State<_AchievementScreenContent>
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

  void _openLeaderboard(BuildContext context) {
    final repository = context.read<StudentRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepositoryProvider.value(
          value: repository,
          child: const LeaderboardScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<AchievementCubit>().refresh();
            context.read<LeaderboardCubit>().refresh();
          },
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
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.5,
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
                            border: Border.all(color: cs.outline),
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
                  child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
                    builder: (context, state) {
                      if (state is LeaderboardLoaded) {
                        final myRank = state.myRank;
                        return ProfileHeroCard(
                          name: myRank.userName ?? 'Hoc vien',
                          level: _calculateLevel(myRank.points),
                          totalXP: myRank.points,
                          completedCourses: myRank.coursesCompleted,
                          totalHours: myRank.lessonsCompleted * 2,
                          rankPosition: myRank.rank,
                          totalStudents: state.leaderboard.totalParticipants,
                        );
                      }
                      return const ProfileHeroCard();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenMargin,
                    AppSpacing.md,
                    AppLayout.screenMargin,
                    0,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => _openLeaderboard(context),
                    icon: const Icon(Icons.leaderboard),
                    label: const Text('Xem bang xep hang'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenMargin,
                    AppSpacing.lg,
                    AppLayout.screenMargin,
                    0,
                  ),
                  child: const LearningHeatmap(),
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
      ),
    );
  }

  int _calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 500) return 5;
    if (points < 1000) return 10;
    if (points < 2000) return 20;
    if (points < 5000) return 30;
    if (points < 10000) return 40;
    return 50 + (points - 10000) ~/ 1000;
  }
}
