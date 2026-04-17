import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/leaderboard/leaderboard_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';
import 'package:study/widgets/simple_gradient_background.dart';

// Custom colors for leaderboard
class _LeaderboardColors {
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color rank1Bg = Color(0xFFFFF9E6);
  static const Color rank2Bg = Color(0xFFF5F5F5);
  static const Color rank3Bg = Color(0xFFFFF5EB);
  static const Color points = Color(0xFF6366F1); // Indigo
  static const Color courses = Color(0xFF10B981); // Emerald
  static const Color lessons = Color(0xFF3B82F6); // Blue
  static const Color streak = Color(0xFFF59E0B); // Amber
  static const Color rankUp = Color(0xFF22C55E); // Green
  static const Color rankDown = Color(0xFFEF4444); // Red
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardCubit(
        repository: context.read<StudentRepository>(),
      )..loadLeaderboard(),
      child: const _LeaderboardScreenContent(),
    );
  }
}

class _LeaderboardScreenContent extends StatelessWidget {
  const _LeaderboardScreenContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SimpleGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Bang xep hang'),
        ),
        body: BlocBuilder<LeaderboardCubit, LeaderboardState>(
          builder: (context, state) {
            return switch (state) {
              LeaderboardInitial() || LeaderboardLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              LeaderboardLoaded() => _buildContent(context, state),
              LeaderboardFailure(:final message) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: cs.error),
                      const SizedBox(height: AppSpacing.md),
                      Text(message),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton(
                        onPressed: () =>
                            context.read<LeaderboardCubit>().loadLeaderboard(),
                        child: const Text('Thu lai'),
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LeaderboardLoaded state) {
    final top3 = state.leaderboard.entries.take(3).toList();
    final rest = state.leaderboard.entries.skip(3).toList();

    return Stack(
      children: [
        // Background decorations
        Positioned(
          top: -40,
          right: -50,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _LeaderboardColors.gold.withOpacity(0.1),
                  _LeaderboardColors.gold.withOpacity(0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: -60,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _LeaderboardColors.points.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _LeaderboardColors.streak.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Decorative icons
        Positioned(
          top: 150,
          left: 15,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.emoji_events,
              size: 28,
              color: _LeaderboardColors.gold.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: 350,
          right: 20,
          child: Transform.rotate(
            angle: 0.2,
            child: Icon(
              Icons.star,
              size: 24,
              color: _LeaderboardColors.streak.withOpacity(0.06),
            ),
          ),
        ),

        // Main content
        Column(
          children: [
            // Period filter
            _PeriodFilter(
              selectedPeriod: state.selectedPeriod,
              onPeriodChanged: (period) {
                context.read<LeaderboardCubit>().changePeriod(period);
              },
            ),

            // Content
            Expanded(
              child: state.leaderboard.entries.isEmpty
                  ? _buildEmptyState(context)
                  : RefreshIndicator(
                      onRefresh: () =>
                          context.read<LeaderboardCubit>().loadLeaderboard(),
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          // Top 3 Podium
                          if (top3.isNotEmpty)
                            _TopThreePodium(
                              entries: top3,
                              currentUserId: state.myRank.userId,
                            ),

                          const SizedBox(height: AppSpacing.md),

                          // My rank card
                          _MyRankCard(myRank: state.myRank),

                          const SizedBox(height: AppSpacing.lg),

                          // Rest of leaderboard
                          ...rest.map((entry) => _LeaderboardEntryCard(
                                entry: entry,
                                isCurrentUser: entry.userId == state.myRank.userId,
                              )),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_outlined, size: 64, color: cs.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chua co du lieu xep hang',
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hoc tap de leo hang nhe!',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  const _PeriodFilter({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        children: [
          _PeriodButton(
            label: 'Ngay',
            value: 'daily',
            isSelected: selectedPeriod == 'daily',
            onTap: () => onPeriodChanged('daily'),
          ),
          _PeriodButton(
            label: 'Tuan',
            value: 'weekly',
            isSelected: selectedPeriod == 'weekly',
            onTap: () => onPeriodChanged('weekly'),
          ),
          _PeriodButton(
            label: 'Thang',
            value: 'monthly',
            isSelected: selectedPeriod == 'monthly',
            onTap: () => onPeriodChanged('monthly'),
          ),
          _PeriodButton(
            label: 'Tat ca',
            value: 'all_time',
            isSelected: selectedPeriod == 'all_time',
            onTap: () => onPeriodChanged('all_time'),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _LeaderboardColors.points : Colors.transparent,
            borderRadius: AppRadius.borderSm,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  const _TopThreePodium({
    required this.entries,
    required this.currentUserId,
  });

  final List<LeaderboardEntryModel> entries;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    // Reorder: 2nd, 1st, 3rd
    final podiumOrder = <LeaderboardEntryModel?>[
      entries.length > 1 ? entries[1] : null,
      entries.isNotEmpty ? entries[0] : null,
      entries.length > 2 ? entries[2] : null,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (podiumOrder[0] != null)
          Expanded(
            child: _PodiumItem(
              entry: podiumOrder[0]!,
              rank: 2,
              isCurrentUser: podiumOrder[0]!.userId == currentUserId,
            ),
          ),
        if (podiumOrder[1] != null)
          Expanded(
            child: _PodiumItem(
              entry: podiumOrder[1]!,
              rank: 1,
              isCurrentUser: podiumOrder[1]!.userId == currentUserId,
            ),
          ),
        if (podiumOrder[2] != null)
          Expanded(
            child: _PodiumItem(
              entry: podiumOrder[2]!,
              rank: 3,
              isCurrentUser: podiumOrder[2]!.userId == currentUserId,
            ),
          ),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.isCurrentUser,
  });

  final LeaderboardEntryModel entry;
  final int rank;
  final bool isCurrentUser;

  Color get _medalColor {
    switch (rank) {
      case 1:
        return _LeaderboardColors.gold;
      case 2:
        return _LeaderboardColors.silver;
      case 3:
        return _LeaderboardColors.bronze;
      default:
        return Colors.grey;
    }
  }

  Color get _bgColor {
    switch (rank) {
      case 1:
        return _LeaderboardColors.rank1Bg;
      case 2:
        return _LeaderboardColors.rank2Bg;
      case 3:
        return _LeaderboardColors.rank3Bg;
      default:
        return Colors.grey.shade100;
    }
  }

  double get _height {
    switch (rank) {
      case 1:
        return 90;
      case 2:
        return 70;
      case 3:
        return 55;
      default:
        return 50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for rank 1
        if (rank == 1)
          const Icon(Icons.emoji_events, color: _LeaderboardColors.gold, size: 28)
        else
          const SizedBox(height: 28),

        const SizedBox(height: 4),

        // Avatar with medal ring
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _medalColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: _medalColor.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 28 : 22,
                backgroundColor: _bgColor,
                backgroundImage: entry.avatarUrl != null
                    ? NetworkImage(entry.avatarUrl!)
                    : null,
                child: entry.avatarUrl == null
                    ? Text(
                        entry.userName?.isNotEmpty == true
                            ? entry.userName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: rank == 1 ? 18 : 14,
                          fontWeight: FontWeight.bold,
                          color: _medalColor,
                        ),
                      )
                    : null,
              ),
            ),
            // Rank badge
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _medalColor,
                  borderRadius: AppRadius.borderXs,
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Name
        Text(
          entry.userName ?? 'User',
          style: tt.bodySmall?.copyWith(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
            color: isCurrentUser ? _LeaderboardColors.points : cs.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Points
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 12, color: _medalColor),
            const SizedBox(width: 2),
            Text(
              '${entry.points}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _medalColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Podium stand
        Container(
          height: _height,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _medalColor,
                _medalColor.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: _medalColor.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MyRankCard extends StatelessWidget {
  const _MyRankCard({required this.myRank});

  final LeaderboardEntryModel myRank;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.borderSm,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: myRank.avatarUrl != null
                  ? NetworkImage(myRank.avatarUrl!)
                  : null,
              child: myRank.avatarUrl == null
                  ? Text(
                      myRank.userName?.isNotEmpty == true
                          ? myRank.userName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thu hang cua ban',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  myRank.userName ?? 'Ban',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Stats
                Row(
                  children: [
                    _MiniStat(
                      icon: Icons.star,
                      value: '${myRank.points}',
                      color: _LeaderboardColors.streak,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MiniStat(
                      icon: Icons.school,
                      value: '${myRank.coursesCompleted}',
                      color: _LeaderboardColors.courses,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MiniStat(
                      icon: Icons.local_fire_department,
                      value: '${myRank.streakDays}',
                      color: _LeaderboardColors.streak,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rank
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  '#${myRank.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (myRank.rankChange != null && myRank.rankChange != 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        myRank.rankChange! > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 12,
                        color: myRank.rankChange! > 0
                            ? _LeaderboardColors.rankUp
                            : _LeaderboardColors.rankDown,
                      ),
                      Text(
                        '${myRank.rankChange!.abs()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: myRank.rankChange! > 0
                              ? _LeaderboardColors.rankUp
                              : _LeaderboardColors.rankDown,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntryCard extends StatelessWidget {
  const _LeaderboardEntryCard({
    required this.entry,
    required this.isCurrentUser,
  });

  final LeaderboardEntryModel entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? _LeaderboardColors.points.withOpacity(0.08)
            : cs.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isCurrentUser
              ? _LeaderboardColors.points.withOpacity(0.3)
              : cs.outline.withOpacity(0.1),
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: Text(
              '${entry.rank}',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: cs.surfaceContainerHighest,
            backgroundImage:
                entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
            child: entry.avatarUrl == null
                ? Text(
                    entry.userName?.isNotEmpty == true
                        ? entry.userName![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),

          // Name and stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.userName ?? 'User',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight:
                              isCurrentUser ? FontWeight.bold : FontWeight.w500,
                          color: isCurrentUser
                              ? _LeaderboardColors.points
                              : cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _LeaderboardColors.points,
                          borderRadius: AppRadius.borderXs,
                        ),
                        child: const Text(
                          'Ban',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _SmallStatChip(
                      icon: Icons.school,
                      value: '${entry.coursesCompleted}',
                      color: _LeaderboardColors.courses,
                    ),
                    const SizedBox(width: 6),
                    _SmallStatChip(
                      icon: Icons.play_lesson,
                      value: '${entry.lessonsCompleted}',
                      color: _LeaderboardColors.lessons,
                    ),
                    const SizedBox(width: 6),
                    _SmallStatChip(
                      icon: Icons.local_fire_department,
                      value: '${entry.streakDays}',
                      color: _LeaderboardColors.streak,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _LeaderboardColors.points.withOpacity(0.1),
                  _LeaderboardColors.points.withOpacity(0.05),
                ],
              ),
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  size: 14,
                  color: _LeaderboardColors.points,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.points}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _LeaderboardColors.points,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatChip extends StatelessWidget {
  const _SmallStatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
