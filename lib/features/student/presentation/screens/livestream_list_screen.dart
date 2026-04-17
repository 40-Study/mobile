import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/livestream/livestream_cubit.dart';
import 'package:study/features/student/bloc/livestream/livestream_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';
import 'package:study/widgets/simple_gradient_background.dart';

// Custom colors for livestream
class _LivestreamColors {
  static const Color live = Color(0xFFEF4444); // Red
  static const Color liveGlow = Color(0xFFDC2626);
  static const Color scheduled = Color(0xFF8B5CF6); // Violet
  static const Color ended = Color(0xFF6B7280); // Gray
  static const Color viewers = Color(0xFF3B82F6); // Blue
  static const Color time = Color(0xFF10B981); // Emerald
  static const Color class_ = Color(0xFFF59E0B); // Amber
  static const Color recording = Color(0xFFEC4899); // Pink
}

class LivestreamListScreen extends StatelessWidget {
  const LivestreamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LivestreamListCubit(
        repository: context.read<StudentRepository>(),
      )..loadLivestreams(),
      child: const _LivestreamListScreenContent(),
    );
  }
}

class _LivestreamListScreenContent extends StatelessWidget {
  const _LivestreamListScreenContent();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SimpleGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Livestream'),
        ),
        body: BlocBuilder<LivestreamListCubit, LivestreamState>(
        builder: (context, state) {
          return switch (state) {
            LivestreamInitial() || LivestreamLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            LivestreamListLoaded() => _buildContent(context, state),
            LivestreamDetailLoaded() => const SizedBox.shrink(),
            LivestreamError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: cs.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(message),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          context.read<LivestreamListCubit>().loadLivestreams(),
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

  Widget _buildContent(BuildContext context, LivestreamListLoaded state) {
    return Stack(
      children: [
        // Background decorations
        Positioned(
          top: -50,
          right: -40,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _LivestreamColors.live.withOpacity(0.08),
                  _LivestreamColors.live.withOpacity(0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 180,
          left: -50,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _LivestreamColors.scheduled.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 280,
          right: -25,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _LivestreamColors.time.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Decorative icons
        Positioned(
          top: 120,
          left: 20,
          child: Transform.rotate(
            angle: -0.15,
            child: Icon(
              Icons.videocam,
              size: 26,
              color: _LivestreamColors.live.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 320,
          right: 25,
          child: Transform.rotate(
            angle: 0.2,
            child: Icon(
              Icons.play_circle_outline,
              size: 30,
              color: _LivestreamColors.scheduled.withOpacity(0.05),
            ),
          ),
        ),

        // Main content
        Column(
          children: [
            // Status filter
            _StatusFilter(
              selectedStatus: state.selectedStatus,
              onStatusChanged: (status) {
                context.read<LivestreamListCubit>().filterByStatus(status);
              },
              liveCount: state.liveNow.length,
              upcomingCount: state.upcoming.length,
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<LivestreamListCubit>().refresh(),
                child: state.filteredLivestreams.isEmpty
                    ? _buildEmptyState(context, state.selectedStatus)
                    : _buildList(context, state),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, LivestreamListLoaded state) {
    final liveNow = state.liveNow;
    final upcoming = state.upcoming;
    final ended = state.livestreams
        .where((l) => l.status == LivestreamStatus.ended)
        .toList();

    // If filter is applied
    if (state.selectedStatus != null) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount:
            state.filteredLivestreams.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.filteredLivestreams.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return _LivestreamCard(livestream: state.filteredLivestreams[index]);
        },
      );
    }

    // Grouped list
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Live now
        if (liveNow.isNotEmpty) ...[
          _SectionHeader(
            title: 'Dang phat truc tiep',
            icon: Icons.sensors,
            color: _LivestreamColors.live,
            count: liveNow.length,
          ),
          ...liveNow.map((l) => _LivestreamCard(livestream: l)),
          const SizedBox(height: AppSpacing.md),
        ],

        // Upcoming
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(
            title: 'Sap dien ra',
            icon: Icons.schedule,
            color: _LivestreamColors.scheduled,
            count: upcoming.length,
          ),
          ...upcoming.map((l) => _LivestreamCard(livestream: l)),
          const SizedBox(height: AppSpacing.md),
        ],

        // Ended
        if (ended.isNotEmpty) ...[
          _SectionHeader(
            title: 'Da ket thuc',
            icon: Icons.history,
            color: _LivestreamColors.ended,
            count: ended.length,
          ),
          ...ended.map((l) => _LivestreamCard(livestream: l)),
        ],
      ],
    );
  }

  Widget _buildEmptyState(
      BuildContext context, LivestreamStatus? selectedStatus) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    String message;
    switch (selectedStatus) {
      case LivestreamStatus.live:
        message = 'Khong co livestream dang phat';
        break;
      case LivestreamStatus.scheduled:
        message = 'Khong co livestream sap toi';
        break;
      case LivestreamStatus.ended:
        message = 'Khong co livestream da ket thuc';
        break;
      default:
        message = 'Chua co livestream nao';
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.live_tv_outlined, size: 64, color: cs.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hay quay lai sau nhe!',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.liveCount,
    required this.upcomingCount,
  });

  final LivestreamStatus? selectedStatus;
  final ValueChanged<LivestreamStatus?> onStatusChanged;
  final int liveCount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _FilterChip(
            label: 'Tat ca',
            icon: Icons.apps,
            color: const Color(0xFF6B7280),
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'LIVE',
            icon: Icons.sensors,
            color: _LivestreamColors.live,
            isSelected: selectedStatus == LivestreamStatus.live,
            onTap: () => onStatusChanged(LivestreamStatus.live),
            badge: liveCount > 0 ? liveCount : null,
            isLive: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'Sap toi',
            icon: Icons.schedule,
            color: _LivestreamColors.scheduled,
            isSelected: selectedStatus == LivestreamStatus.scheduled,
            onTap: () => onStatusChanged(LivestreamStatus.scheduled),
            badge: upcomingCount > 0 ? upcomingCount : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'Da phat',
            icon: Icons.history,
            color: _LivestreamColors.ended,
            isSelected: selectedStatus == LivestreamStatus.ended,
            onTap: () => onStatusChanged(LivestreamStatus.ended),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.isLive = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : color.withOpacity(0.1),
      borderRadius: AppRadius.borderSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive && isSelected)
                _PulsingDot(color: Colors.white)
              else
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : color,
                ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : color,
                    borderRadius: AppRadius.borderXs,
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});

  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.5 + _controller.value * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.borderSm,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.borderXs,
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivestreamCard extends StatelessWidget {
  const _LivestreamCard({required this.livestream});

  final LivestreamModel livestream;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isLive = livestream.isLive;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isLive
              ? _LivestreamColors.live.withOpacity(0.3)
              : cs.outline.withOpacity(0.1),
          width: isLive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isLive
                ? _LivestreamColors.live.withOpacity(0.08)
                : cs.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openLivestream(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image or placeholder
                  if (livestream.thumbnailUrl != null)
                    Image.network(
                      livestream.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _ThumbnailPlaceholder(isLive: isLive),
                    )
                  else
                    _ThumbnailPlaceholder(isLive: isLive),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Status badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _StatusBadge(status: livestream.status),
                  ),

                  // Viewer count (for live)
                  if (isLive)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatViewers(livestream.activeParticipants),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Host info
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: cs.surfaceContainerHighest,
                            backgroundImage: livestream.hostAvatarUrl != null
                                ? NetworkImage(livestream.hostAvatarUrl!)
                                : null,
                            child: livestream.hostAvatarUrl == null
                                ? Text(
                                    livestream.hostName.isNotEmpty
                                        ? livestream.hostName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            livestream.hostName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Action button
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isLive
                                ? _LivestreamColors.live
                                : Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLive
                                ? Icons.play_arrow
                                : livestream.status == LivestreamStatus.scheduled
                                    ? Icons.notifications_none
                                    : Icons.replay,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    livestream.title,
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        icon: Icons.access_time,
                        label: livestream.scheduledTimeDisplay,
                        color: _LivestreamColors.time,
                      ),
                      if (livestream.className != null)
                        _InfoChip(
                          icon: Icons.class_,
                          label: livestream.className!,
                          color: _LivestreamColors.class_,
                        ),
                      if (livestream.isRecorded)
                        _InfoChip(
                          icon: Icons.videocam,
                          label: 'Ghi hinh',
                          color: _LivestreamColors.recording,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatViewers(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  void _openLivestream(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              livestream.isLive ? Icons.play_circle : Icons.notifications_active,
              color: Colors.white,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              livestream.isLive
                  ? 'Dang vao livestream...'
                  : 'Dat nhac nho thanh cong',
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        backgroundColor:
            livestream.isLive ? _LivestreamColors.live : _LivestreamColors.scheduled,
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({this.isLive = false});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLive
              ? [
                  _LivestreamColors.live.withOpacity(0.3),
                  _LivestreamColors.live.withOpacity(0.1),
                ]
              : [
                  cs.surfaceContainerHighest,
                  cs.surfaceContainerHigh,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.live_tv,
          size: 48,
          color: isLive
              ? _LivestreamColors.live.withOpacity(0.5)
              : cs.outline.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatefulWidget {
  const _StatusBadge({required this.status});

  final LivestreamStatus status;

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.status == LivestreamStatus.live) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;
    IconData? icon;

    switch (widget.status) {
      case LivestreamStatus.live:
        bgColor = _LivestreamColors.live;
        text = 'LIVE';
        break;
      case LivestreamStatus.scheduled:
        bgColor = _LivestreamColors.scheduled;
        text = 'SAP TOI';
        icon = Icons.schedule;
        break;
      case LivestreamStatus.ended:
        bgColor = _LivestreamColors.ended;
        text = 'DA KET THUC';
        icon = Icons.replay;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.borderSm,
        boxShadow: widget.status == LivestreamStatus.live
            ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status == LivestreamStatus.live)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5 + _controller.value * 0.5),
                    shape: BoxShape.circle,
                  ),
                );
              },
            )
          else if (icon != null)
            Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
