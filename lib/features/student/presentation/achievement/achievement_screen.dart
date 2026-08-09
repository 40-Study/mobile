import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/presentation/achievement/widgets/badge_grid.dart';
import 'package:study/features/student/presentation/achievement/widgets/stats_hero_card.dart';
import 'package:study/features/student/presentation/achievement/widgets/stats_view.dart';
import 'package:study/theme/theme.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AchievementBloc>().add(const AchievementStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thành tích')),
      body: BlocBuilder<AchievementBloc, AchievementState>(
        builder: (context, state) {
          return switch (state) {
            AchievementInitial() || AchievementInProgress() => const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            AchievementFailure(:final message) => _buildError(context, message),
            AchievementSuccess() => _buildContent(context, state),
          };
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          AppSpacing.vGap16,
          Text(message),
          AppSpacing.vGap16,
          FilledButton(
            onPressed: () =>
                context.read<AchievementBloc>().add(const AchievementStarted()),
            child: const Text('Thu lai'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AchievementSuccess state) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        StatsHeroCard(stats: state.stats),
        AppSpacing.vGap24,

        _TabSelector(
          selectedTab: state.selectedTab,
          onTabChanged: (tab) {
            context.read<AchievementBloc>().add(AchievementTabChanged(tab));
          },
        ),
        AppSpacing.vGap16,

        _buildTabContent(context, state),
        AppSpacing.vGap24,
      ],
    );
  }

  Widget _buildTabContent(BuildContext context, AchievementSuccess state) {
    final tt = Theme.of(context).textTheme;

    return switch (state.selectedTab) {
      AchievementTab.badges => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.earnedBadges.isNotEmpty) ...[
            Text(
              'Đã mở khóa (${state.earnedBadges.length})',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap12,
            BadgeGrid(badges: state.earnedBadges),
            AppSpacing.vGap24,
          ],
          if (state.lockedBadges.isNotEmpty) ...[
            Text(
              'Chưa mở khóa (${state.lockedBadges.length})',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap12,
            BadgeGrid(badges: state.lockedBadges),
          ],
        ],
      ),
      AchievementTab.certificates => _buildCertificates(context, state),
      AchievementTab.stats => StatsView(stats: state.stats),
    };
  }

  Widget _buildCertificates(BuildContext context, AchievementSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (state.certificates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 48,
                color: cs.outline,
              ),
              AppSpacing.vGap12,
              Text(
                'Chưa có chứng chỉ',
                style: tt.bodyMedium?.copyWith(color: cs.outline),
              ),
              AppSpacing.vGap8,
              Text(
                'Hoàn thành khóa học để nhận chứng chỉ',
                style: tt.bodySmall?.copyWith(color: cs.outline),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({required this.selectedTab, required this.onTabChanged});

  final AchievementTab selectedTab;
  final ValueChanged<AchievementTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: AchievementTab.values.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(tab),
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  border: isSelected ? Border.all(color: cs.outline) : null,
                ),
                child: Text(
                  _tabLabel(tab),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _tabLabel(AchievementTab tab) {
    return switch (tab) {
      AchievementTab.badges => 'Huy hiệu',
      AchievementTab.certificates => 'Chứng chỉ',
      AchievementTab.stats => 'Thống kê',
    };
  }
}
