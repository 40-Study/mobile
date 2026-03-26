import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/mock/mock_contest_data.dart';
import 'package:study/theme/app_colors.dart';

class ContestDetailScreen extends StatelessWidget {
  const ContestDetailScreen({
    super.key,
    required this.title,
    required this.participants,
    required this.deadline,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String title;
  final String participants;
  final String deadline;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chi tiet cuoc thi',
          style: tt.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined,
                color: cs.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.screenMargin,
          AppSpacing.lg,
          AppLayout.screenMargin,
          AppSpacing.massive,
        ),
        children: [
          _HeroCard(
            title: title,
            participants: participants,
            icon: icon,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _CountdownCard(deadline: deadline, cs: cs, tt: tt),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle(title: 'Gioi thieu'),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Cuoc thi nham khich le cac ban tre ung dung '
            'cong nghe de giai quyet cac van de thuc te '
            'trong xa hoi. Day la co hoi tuyet voi de the '
            'hien nang luc, ket noi voi cong dong va nhan '
            'duoc nhung phan thuong gia tri.',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle(title: 'Giai thuong'),
          const SizedBox(height: AppSpacing.lg),
          _PrizeCard(
            label: 'Giai nhat',
            prize: '50.000.000d',
            color: const Color(0xfffbbf24),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PrizeCard(
            label: 'Giai nhi',
            prize: '30.000.000d',
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PrizeCard(
            label: 'Giai ba',
            prize: '15.000.000d',
            color: const Color(0xffcd7f32),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle(title: 'The le tham gia'),
          const SizedBox(height: AppSpacing.lg),
          ...mockContestRules.asMap().entries.map(
                (e) => _RuleRow(
                    index: e.key, text: e.value),
              ),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle(title: 'Lich trinh'),
          const SizedBox(height: AppSpacing.lg),
          ...mockContestTimeline.map(
            (item) => _TimelineItem(
              date: item['date']!,
              event: item['event']!,
              isLast: item == mockContestTimeline.last,
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
      bottomNavigationBar: _BottomBar(cs: cs, tt: tt),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.participants,
    required this.icon,
    required this.cs,
    required this.tt,
  });
  final String title;
  final String participants;
  final IconData icon;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: cs.gradientPrimary,
        borderRadius: AppRadius.borderXl,
        boxShadow: cs.shadowPrimary,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.borderLg,
            ),
            child: Icon(icon,
                size: AppIconSize.hero,
                color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title.replaceAll('\n', ' '),
            style: tt.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline_rounded,
                  size: AppIconSize.sm,
                  color: Colors.white
                      .withValues(alpha: 0.8)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                participants,
                style: tt.labelMedium?.copyWith(
                  color: Colors.white
                      .withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
    required this.deadline,
    required this.cs,
    required this.tt,
  });
  final String deadline;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppLayout.cardPadding,
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: AppRadius.borderLg,
        border: Border.all(
          color: cs.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_rounded,
              size: AppIconSize.lg, color: cs.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text('Thoi gian con lai',
                    style: tt.labelMedium?.copyWith(
                        color: cs.onErrorContainer)),
                Text(
                  deadline,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.error,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: AppRadius.borderXs,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PrizeCard extends StatelessWidget {
  const _PrizeCard({
    required this.label,
    required this.prize,
    required this.color,
  });
  final String label;
  final String prize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: AppLayout.cardPaddingCompact,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: cs.outline),
        boxShadow: cs.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border:
                  Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Icon(
                  Icons.emoji_events_rounded,
                  size: AppIconSize.md,
                  color: color),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                )),
          ),
          Text(prize,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              )),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.index,
    required this.text,
  });
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding:
          const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.surfaceTintedPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                )),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.date,
    required this.event,
    this.isLast = false,
  });
  final String date;
  final String event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin:
                          const EdgeInsets.symmetric(
                        vertical: AppSpacing.xxs,
                      ),
                      color: cs.outline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(date,
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(
                      height: AppSpacing.xxs),
                  Text(event,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.cs,
    required this.tt,
  });
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppLayout.screenMargin,
        AppSpacing.md,
        AppLayout.screenMargin,
        MediaQuery.of(context).padding.bottom +
            AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border:
            Border(top: BorderSide(color: cs.outline)),
        boxShadow: cs.shadowElevated,
      ),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: cs.gradientPrimary,
            borderRadius: AppRadius.borderLg,
            boxShadow: cs.shadowPrimary,
          ),
          child: Center(
            child: Text(
              'Dang ky tham gia',
              style: tt.titleSmall?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
