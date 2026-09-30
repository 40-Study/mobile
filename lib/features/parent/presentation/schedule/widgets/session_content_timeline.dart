import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_session_detail_model.dart';
import 'package:study/theme/theme.dart';

/// Section chuẩn bị trước buổi học (Tài liệu + Checklist)
class SessionPreparationSection extends StatelessWidget {
  const SessionPreparationSection({
    super.key,
    required this.detail,
    required this.onDownloadMaterial,
  });

  final ParentSessionDetail detail;
  final void Function(SessionMaterial) onDownloadMaterial;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x050F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHUẨN BỊ TRƯỚC BUỔI HỌC',
            style: tt.labelSmall?.copyWith(
              color: cs.slate400,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),

          // Tài liệu đính kèm
          if (detail.hasMaterials)
            ...detail.materials.map((mat) => _MaterialItem(
                  material: mat,
                  onDownload: () => onDownloadMaterial(mat),
                ))
          else
            _EmptyStateBox(
              icon: Icons.folder_open_outlined,
              message: 'Tài liệu đính kèm: Chưa có tài liệu nào cho buổi học này.',
            ),
          const SizedBox(height: 14),

          // Checklist chuẩn bị
          if (detail.hasChecklist)
            ...detail.checklist.map((item) => _ChecklistItem(item: item))
          else
            _EmptyStateBox(
              icon: Icons.assignment_outlined,
              message: 'Nhiệm vụ chuẩn bị: Chưa có yêu cầu riêng cho buổi này.',
            ),
        ],
      ),
    );
  }
}

class _MaterialItem extends StatelessWidget {
  const _MaterialItem({
    required this.material,
    required this.onDownload,
  });

  final SessionMaterial material;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: AppRadius.borderSm,
            ),
            child: const Text(
              'PDF',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.fileName,
                  style: TextStyle(
                    color: cs.slate900,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${material.fileSize} • ${material.uploadTime}',
                  style: TextStyle(color: cs.slate500, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: cs.blue600, size: 20),
            tooltip: 'Tải về',
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.item});

  final SessionChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTask = item.type == ChecklistItemType.task;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTask)
            item.isCompleted
                ? const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF16A34A))
                : const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFFD97706))
          else
            const Icon(Icons.backpack_outlined, size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                color: cs.slate700,
                fontSize: 13,
                height: 1.4,
                fontWeight: item.isCompleted ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section video bài giảng xem lại (Recording)
class SessionRecordingVideoSection extends StatelessWidget {
  const SessionRecordingVideoSection({
    super.key,
    required this.detail,
  });

  final ParentSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final analysis = detail.completedAnalysis;
    final hasRecording = analysis?.hasRecording ?? false;

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x050F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.videocam_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'VIDEO BÀI GIẢNG XEM LẠI',
                style: tt.labelSmall?.copyWith(
                  color: cs.slate400,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasRecording) ...[
            ClipRRect(
              borderRadius: AppRadius.borderMd,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFF0F172A),
                    child: Center(
                      child: Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        analysis?.recordingDuration ?? '48 phút',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              detail.session.lessonTopic.isNotEmpty
                  ? detail.session.lessonTopic
                  : 'Ghi hình buổi học',
              style: TextStyle(
                color: cs.slate900,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Video chất lượng 1080p · Lưu trữ 30 ngày trong hồ sơ',
              style: TextStyle(color: cs.slate500, fontSize: 11.5),
            ),
          ] else
            _EmptyStateBox(
              icon: Icons.videocam_off_outlined,
              message: 'Chưa có video ghi hình cho buổi học này.',
            ),
        ],
      ),
    );
  }
}

/// Card gợi ý đồng hành cùng con (Parent Guidance)
class SessionParentGuidanceCard extends StatelessWidget {
  const SessionParentGuidanceCard({
    super.key,
    required this.detail,
  });

  final ParentSessionDetail detail;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (!detail.hasGuidance) {
      return _EmptyStateBox(
        icon: Icons.lightbulb_outline,
        message: 'Gợi ý đồng hành: Chưa có lưu ý đặc biệt từ giáo viên.',
      );
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: const Color(0xFFDCFCE7)),
        boxShadow: const [
          BoxShadow(color: Color(0x050F172A), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF16A34A), size: 20),
              const SizedBox(width: 8),
              Text(
                'Gợi ý đồng hành cùng con',
                style: tt.titleSmall?.copyWith(
                  color: const Color(0xFF14532D),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail.parentGuidance!,
            style: const TextStyle(
              color: Color(0xFF166534),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateBox extends StatelessWidget {
  const _EmptyStateBox({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.slate400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cs.slate500,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
