import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_bloc.dart';
import 'package:study/features/student/bloc/achievement/achievement_event.dart';
import 'package:study/features/student/bloc/achievement/achievement_state.dart';
import 'package:study/features/student/presentation/achievement/widgets/widgets.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/tab_screen_header.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementBloc>().add(const AchievementStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            return switch (state) {
              AchievementInitial() || AchievementInProgress() => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              AchievementFailure(:final message) => _buildError(context, message),
              AchievementSuccess() => _buildContent(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingScreenAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem, color: cs.onErrorContainer),
            ),
            AppSpacing.vGap16,
            Text(
              'Không thể tải thành tích',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap4,
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGap16,
            FilledButton.icon(
              onPressed: () =>
                  context.read<AchievementBloc>().add(const AchievementStarted()),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AchievementSuccess state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AchievementBloc>().add(const AchievementStarted());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          TabScreenHeader(
            title: AppLocalizations.of(context)!.achievementTitle,
            subtitle: 'Theo dõi thành tích của bạn.',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              children: [
                OverviewStatistics(stats: state.stats),
                AppSpacing.vGap24,
                RecentBadges(badges: state.earnedBadges),
                AppSpacing.vGap24,
                if (state.certificates.isNotEmpty) ...[
                  CertificateCarousel(certificates: state.certificates),
                  AppSpacing.vGap24,
                ],
                ContributionGrid(contributionData: state.contributions),
                AppSpacing.vGap24,
                LearningTrendChart(stats: state.stats),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
