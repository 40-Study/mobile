import 'package:flutter/material.dart';

enum StudentRank {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
}

extension StudentRankX on StudentRank {
  String get displayName {
    return switch (this) {
      StudentRank.bronze => 'Dong',
      StudentRank.silver => 'Bac',
      StudentRank.gold => 'Vang',
      StudentRank.platinum => 'Bach Kim',
      StudentRank.diamond => 'Kim Cuong',
      StudentRank.master => 'Cao Thu',
    };
  }

  List<Color> get frameColors {
    return switch (this) {
      StudentRank.bronze => const [Color(0xFFCD7F32), Color(0xFF8B5A2B)],
      StudentRank.silver => const [Color(0xFFE8E8E8), Color(0xFFA8A8A8)],
      StudentRank.gold => const [Color(0xFFFFD700), Color(0xFFDAA520)],
      StudentRank.platinum => const [Color(0xFF7DD3FC), Color(0xFF0EA5E9)],
      StudentRank.diamond => const [Color(0xFFC4B5FD), Color(0xFF8B5CF6)],
      StudentRank.master => const [Color(0xFFF472B6), Color(0xFFDB2777)],
    };
  }

  Color get glowColor {
    return switch (this) {
      StudentRank.bronze => const Color(0xFFCD7F32).withValues(alpha: 0.4),
      StudentRank.silver => const Color(0xFFE8E8E8).withValues(alpha: 0.4),
      StudentRank.gold => const Color(0xFFFFD700).withValues(alpha: 0.5),
      StudentRank.platinum => const Color(0xFF0EA5E9).withValues(alpha: 0.5),
      StudentRank.diamond => const Color(0xFF8B5CF6).withValues(alpha: 0.6),
      StudentRank.master => const Color(0xFFDB2777).withValues(alpha: 0.6),
    };
  }

  double get frameWidth {
    return switch (this) {
      StudentRank.bronze => 3.0,
      StudentRank.silver => 3.5,
      StudentRank.gold => 4.0,
      StudentRank.platinum => 4.5,
      StudentRank.diamond => 5.0,
      StudentRank.master => 5.5,
    };
  }

  double get glowRadius {
    return switch (this) {
      StudentRank.bronze => 6.0,
      StudentRank.silver => 8.0,
      StudentRank.gold => 12.0,
      StudentRank.platinum => 16.0,
      StudentRank.diamond => 20.0,
      StudentRank.master => 24.0,
    };
  }

  bool get hasTopDecoration {
    return index >= StudentRank.gold.index;
  }

  bool get hasBottomDecoration {
    return index >= StudentRank.platinum.index;
  }

  static StudentRank fromLevel(int level) {
    if (level >= 100) return StudentRank.master;
    if (level >= 80) return StudentRank.diamond;
    if (level >= 50) return StudentRank.platinum;
    if (level >= 25) return StudentRank.gold;
    if (level >= 10) return StudentRank.silver;
    return StudentRank.bronze;
  }
}

class RankAvatarFrame extends StatelessWidget {
  const RankAvatarFrame({
    super.key,
    required this.rank,
    required this.size,
    this.child,
    this.imageUrl,
  });

  final StudentRank rank;
  final double size;
  final Widget? child;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: size + rank.frameWidth * 2 + (rank.hasTopDecoration ? 16 : 0),
      height: size + rank.frameWidth * 2 + (rank.hasTopDecoration ? 20 : 0),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow effect
          Container(
            width: size + rank.frameWidth * 2,
            height: size + rank.frameWidth * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rank.glowColor,
                  blurRadius: rank.glowRadius,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Main frame with gradient border
          Container(
            width: size + rank.frameWidth * 2,
            height: size + rank.frameWidth * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: rank.frameColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surface,
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildAvatar(cs),
              ),
            ),
          ),

          // Top decoration (crown/wings) for higher ranks
          if (rank.hasTopDecoration)
            Positioned(
              top: 0,
              child: _TopDecoration(rank: rank),
            ),

          // Bottom decoration for platinum+
          if (rank.hasBottomDecoration)
            Positioned(
              bottom: 0,
              child: _BottomDecoration(rank: rank),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(cs),
      );
    }
    if (child != null) {
      return child!;
    }
    return _defaultAvatar(cs);
  }

  Widget _defaultAvatar(ColorScheme cs) {
    return Container(
      color: cs.primaryContainer,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: cs.primary,
      ),
    );
  }
}

class _TopDecoration extends StatelessWidget {
  const _TopDecoration({required this.rank});

  final StudentRank rank;

  @override
  Widget build(BuildContext context) {
    final colors = rank.frameColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: rank.glowColor,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        _getIcon(),
        color: Colors.white,
        size: 16,
      ),
    );
  }

  IconData _getIcon() {
    return switch (rank) {
      StudentRank.gold => Icons.emoji_events,
      StudentRank.platinum => Icons.star,
      StudentRank.diamond => Icons.diamond,
      StudentRank.master => Icons.auto_awesome,
      _ => Icons.shield,
    };
  }
}

class _BottomDecoration extends StatelessWidget {
  const _BottomDecoration({required this.rank});

  final StudentRank rank;

  @override
  Widget build(BuildContext context) {
    final colors = rank.frameColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: rank.glowColor,
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        rank.displayName.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
