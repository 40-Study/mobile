import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/voucher/voucher_cubit.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';
import 'package:study/widgets/simple_gradient_background.dart';

// Custom colors for vouchers
class _VoucherColors {
  static const Color percentage = Color(0xFF8B5CF6); // Violet
  static const Color fixed = Color(0xFF10B981); // Emerald
  static const Color saved = Color(0xFFF59E0B); // Amber
  static const Color urgent = Color(0xFFEF4444); // Red
  static const Color minOrder = Color(0xFF3B82F6); // Blue
  static const Color remaining = Color(0xFF06B6D4); // Cyan
  static const Color expired = Color(0xFF6B7280); // Gray
  static const Color copy = Color(0xFF6366F1); // Indigo
}

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  bool _showSavedOnly = false;

  @override
  Widget build(BuildContext context) {
    return SimpleGradientBackground(
      child: BlocProvider(
        create: (context) => VoucherCubit(
          repository: context.read<StudentRepository>(),
        )..loadVouchers(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Ma giam gia'),
          ),
          body: BlocBuilder<VoucherCubit, VoucherState>(
            builder: (context, state) {
              return switch (state) {
                VoucherInitial() || VoucherLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                VoucherLoaded() => _buildContent(context, state),
                VoucherFailure(:final message) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: AppSpacing.md),
                        Text(message),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: () =>
                              context.read<VoucherCubit>().loadVouchers(),
                          child: const Text('Thu lai'),
                        ),
                      ],
                    ),
                  ),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VoucherLoaded state) {
    final cs = Theme.of(context).colorScheme;
    final displayedVouchers = _showSavedOnly
        ? state.savedVouchers
        : state.publicVouchers;

    return Stack(
      children: [
        // Background decorations
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _VoucherColors.percentage.withOpacity(0.08),
                  _VoucherColors.percentage.withOpacity(0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _VoucherColors.fixed.withOpacity(0.06),
                  _VoucherColors.fixed.withOpacity(0.01),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 200,
          right: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _VoucherColors.saved.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Decorative icons
        Positioned(
          top: 80,
          left: 20,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.local_offer,
              size: 24,
              color: _VoucherColors.percentage.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: 30,
          child: Transform.rotate(
            angle: 0.3,
            child: Icon(
              Icons.percent,
              size: 32,
              color: _VoucherColors.fixed.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          left: 40,
          child: Transform.rotate(
            angle: -0.1,
            child: Icon(
              Icons.confirmation_number,
              size: 28,
              color: _VoucherColors.saved.withOpacity(0.06),
            ),
          ),
        ),

        // Main content
        Column(
          children: [
            // Tab bar
            _TabBar(
              showSavedOnly: _showSavedOnly,
              savedCount: state.savedVouchers.length,
              allCount: state.publicVouchers.length,
              onTabChanged: (showSaved) {
                setState(() => _showSavedOnly = showSaved);
              },
            ),

            // Vouchers list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<VoucherCubit>().refresh(),
                child: displayedVouchers.isEmpty
                    ? _buildEmptyState(context, _showSavedOnly)
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: displayedVouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = displayedVouchers[index];
                          final isSaved = state.savedVouchers.any((v) => v.id == voucher.id);
                          return _VoucherCard(
                            voucher: voucher,
                            isSaved: isSaved,
                            onSave: () =>
                                context.read<VoucherCubit>().saveVoucher(voucher.id),
                            onUnsave: () => context
                                .read<VoucherCubit>()
                                .unsaveVoucher(voucher.id),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool showSavedOnly) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            showSavedOnly ? Icons.bookmark_border : Icons.local_offer_outlined,
            size: 64,
            color: cs.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            showSavedOnly ? 'Chua luu voucher nao' : 'Khong co voucher',
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            showSavedOnly
                ? 'Luu voucher de su dung sau'
                : 'Cac ma giam gia se xuat hien o day',
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.showSavedOnly,
    required this.savedCount,
    required this.allCount,
    required this.onTabChanged,
  });

  final bool showSavedOnly;
  final int savedCount;
  final int allCount;
  final ValueChanged<bool> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              icon: Icons.local_offer,
              label: 'Tat ca',
              color: _VoucherColors.percentage,
              badge: allCount > 0 ? allCount : null,
              isSelected: !showSavedOnly,
              onTap: () => onTabChanged(false),
            ),
          ),
          Expanded(
            child: _TabButton(
              icon: Icons.bookmark,
              label: 'Da luu',
              color: _VoucherColors.saved,
              badge: savedCount > 0 ? savedCount : null,
              isSelected: showSavedOnly,
              onTap: () => onTabChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: AppRadius.borderSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : cs.onSurfaceVariant,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.25) : color.withOpacity(0.15),
                  borderRadius: AppRadius.borderXs,
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  const _VoucherCard({
    required this.voucher,
    required this.isSaved,
    required this.onSave,
    required this.onUnsave,
  });

  final VoucherModel voucher;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onUnsave;

  bool get _isValid {
    if (!voucher.isActive) return false;
    if (voucher.endDate != null) {
      final endDate = DateTime.tryParse(voucher.endDate!);
      if (endDate != null && endDate.isBefore(DateTime.now())) {
        return false;
      }
    }
    return true;
  }

  String get _discountDisplay {
    if (voucher.discountType == 'percentage') {
      return '${voucher.discountValue.toInt()}%';
    }
    return '\$${voucher.discountValue.toStringAsFixed(0)}';
  }

  int? get _daysLeft {
    if (voucher.endDate == null) return null;
    final endDate = DateTime.tryParse(voucher.endDate!);
    if (endDate == null) return null;
    return endDate.difference(DateTime.now()).inDays;
  }

  int? get _remainingUsage {
    if (voucher.usageLimit == null) return null;
    return voucher.usageLimit! - voucher.usageCount;
  }

  Color get _primaryColor {
    if (!_isValid) return _VoucherColors.expired;
    return voucher.discountType == 'percentage'
        ? _VoucherColors.percentage
        : _VoucherColors.fixed;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: isSaved
              ? _VoucherColors.saved.withOpacity(0.3)
              : cs.outline.withOpacity(0.1),
          width: isSaved ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left side - Discount
            Stack(
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _primaryColor,
                        _primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (voucher.discountType == 'percentage')
                        Text(
                          'GIAM',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        _discountDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (voucher.discountType != 'percentage')
                        Text(
                          'OFF',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                // Top notch
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Bottom notch
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            // Dashed line
            SizedBox(
              width: 1,
              child: CustomPaint(
                painter: _DashedLinePainter(color: cs.outline.withOpacity(0.2)),
                child: const SizedBox.expand(),
              ),
            ),

            // Right side - Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            voucher.name ?? voucher.code,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Save button
                        GestureDetector(
                          onTap: isSaved ? onUnsave : onSave,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSaved
                                  ? _VoucherColors.saved.withOpacity(0.1)
                                  : cs.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? _VoucherColors.saved : cs.outline,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Description
                    if (voucher.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        voucher.description!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.sm),

                    // Conditions
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (voucher.minOrderValue != null)
                          _ConditionChip(
                            icon: Icons.shopping_cart_outlined,
                            label: 'Min \$${voucher.minOrderValue!.toStringAsFixed(0)}',
                            color: _VoucherColors.minOrder,
                          ),
                        if (_daysLeft != null)
                          _ConditionChip(
                            icon: Icons.schedule,
                            label: '$_daysLeft ngay',
                            color: _daysLeft! <= 3
                                ? _VoucherColors.urgent
                                : _VoucherColors.remaining,
                            isUrgent: _daysLeft! <= 3,
                          ),
                        if (_remainingUsage != null)
                          _ConditionChip(
                            icon: Icons.inventory_2_outlined,
                            label: 'Con $_remainingUsage',
                            color: _VoucherColors.remaining,
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Code row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.08),
                              borderRadius: AppRadius.borderSm,
                              border: Border.all(
                                color: _primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 14,
                                  color: _primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  voucher.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                    color: _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Copy button
                        Material(
                          color: _VoucherColors.copy,
                          borderRadius: AppRadius.borderSm,
                          child: InkWell(
                            onTap: () => _copyCode(context),
                            borderRadius: AppRadius.borderSm,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: voucher.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Da sao chep: ${voucher.code}'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
        backgroundColor: _VoucherColors.copy,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({
    required this.icon,
    required this.label,
    required this.color,
    this.isUrgent = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppRadius.borderXs,
        border: isUrgent ? Border.all(color: color.withOpacity(0.4)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: isUrgent ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
