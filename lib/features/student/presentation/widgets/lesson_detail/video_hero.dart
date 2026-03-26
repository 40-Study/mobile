import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/data/models/models.dart';

class VideoHero extends StatelessWidget {
  const VideoHero({super.key, required this.detail});
  final LessonDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0d1b2a),
            cs.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: AppSpacing.massive + AppSpacing.sm,
              height: AppSpacing.massive + AppSpacing.sm,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: cs.onPrimary,
                size: AppIconSize.xxl,
              ),
            ),
          ),
          if (detail.currentTime != null)
            Positioned(
              left: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: AppRadius.borderXs,
                ),
                child: Text(
                  '${detail.currentTime} / ${detail.duration}',
                  style: tt.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Row(
              children: [
                _miniIconBtn(Icons.settings_outlined),
                SizedBox(width: AppSpacing.sm),
                _miniIconBtn(Icons.fullscreen_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniIconBtn(IconData icon) {
    return Container(
      width: AppIconSize.xl,
      height: AppIconSize.xl,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: AppIconSize.sm),
    );
  }
}
