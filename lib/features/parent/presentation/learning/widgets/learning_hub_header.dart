import 'package:flutter/material.dart';

/// Header trên đỉnh màn hình Tab Học tập
class LearningHubHeader extends StatelessWidget {
  const LearningHubHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: PHỤ HUYNH 40STUDY & Badge CHẾ ĐỘ GIÁM SÁT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PHỤ HUYNH 40STUDY',
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                  letterSpacing: 0.5,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'CHẾ ĐỘ GIÁM SÁT',
                      style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF15803D),
                        fontSize: 11,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dòng 2: Tiêu đề to Học tập
          Text(
            'Học tập',
            style: tt.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 30,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
