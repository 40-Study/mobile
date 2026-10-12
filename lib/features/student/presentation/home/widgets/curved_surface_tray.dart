import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

/// Khay bề mặt cong (Curved Surface Tray) bao bọc toàn bộ các section tác vụ nửa dưới màn hình.
///
/// Đóng vai trò ẩn dụ "Bàn làm việc":
/// - Bo cong đỉnh Radius 28px tạo sự chuyển tiếp mềm mại từ không gian chào đón xuống khu vực tác vụ
/// - Nền xám nhẹ (surfaceContainerLow / surfaceBg) tạo tương phản tự nhiên giúp các Card trắng bên trong nổi bật
/// - Chấm dứt hiện tượng Card Fatigue bằng cách gom nhóm bề mặt thay vì đóng khung rời rạc.
class CurvedSurfaceTray extends StatelessWidget {
  const CurvedSurfaceTray({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final effectiveBg = backgroundColor ??
        (isLight ? const Color(0xFFF8FAFC) : cs.surfaceContainerLow);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.45),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.xl,
        AppSpacing.screenPadding,
        AppSpacing.xxl,
      ),
      child: child,
    );
  }
}
