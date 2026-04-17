import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/competition_model.dart';

class _CompetitionColors {
  static const upcoming = Color(0xFF8B5CF6);
  static const ongoing = Color(0xFF10B981);
  static const ended = Color(0xFF6B7280);
  static const participants = Color(0xFF3B82F6);
  static const trophy = Color(0xFFF59E0B);
  static const prize = Color(0xFFEC4899);
}

class CompetitionCard extends StatelessWidget {
  const CompetitionCard({
    super.key,
    required this.competition,
    this.onTap,
    this.onJoin,
  });

  final CompetitionModel competition;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  Color get _statusColor {
    if (competition.isUpcoming) return _CompetitionColors.upcoming;
    if (competition.isOngoing) return _CompetitionColors.ongoing;
    return _CompetitionColors.ended;
  }

  String get _statusText {
    if (competition.isUpcoming) return 'Sap dien ra';
    if (competition.isOngoing) return 'Dang dien ra';
    return 'Da ket thuc';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: _statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _statusColor.withValues(alpha: 0.2),
                      _statusColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusText,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.emoji_events,
                        color: _CompetitionColors.trophy,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    competition.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (competition.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      competition.description!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.people,
                        label: competition.participantDisplay,
                        color: _CompetitionColors.participants,
                      ),
                      const SizedBox(width: 12),
                      if (competition.prizePool != null)
                        _InfoChip(
                          icon: Icons.card_giftcard,
                          label: competition.prizePool!,
                          color: _CompetitionColors.prize,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        competition.timeDisplay,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (!competition.isEnded && !competition.isJoined)
                        GestureDetector(
                          onTap: onJoin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tham gia',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else if (competition.isJoined)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _CompetitionColors.ongoing.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Da tham gia',
                            style: TextStyle(
                              color: _CompetitionColors.ongoing,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
