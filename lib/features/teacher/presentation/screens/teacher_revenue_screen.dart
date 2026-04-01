import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/weather/presentation/widgets/weather_content_overlay.dart';

class TeacherRevenueScreen extends StatefulWidget {
  const TeacherRevenueScreen({super.key});

  @override
  State<TeacherRevenueScreen> createState() => _TeacherRevenueScreenState();
}

class _TeacherRevenueScreenState extends State<TeacherRevenueScreen> {
  String _selectedPeriod = '7 ngày';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(context),
            const SizedBox(height: AppSpacing.xl),
            _buildRevenueChart(context),
            const SizedBox(height: AppSpacing.xl),
            _buildBalanceCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildPendingCard(context),
            const SizedBox(height: AppSpacing.md),
            _buildTotalRevenueCard(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildCourseRevenueSection(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildRecentTransactions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textColor = context.weatherTextColor;
    final secondaryColor = context.weatherTextColorSecondary;
    final iconBgColor = context.weatherIconBackgroundColor;
    final cs = Theme.of(context).colorScheme;

    // Get user name from auth state
    String userName = 'Bạn';
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        userName = authState.user.fullName ?? authState.user.username;
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hamburger menu
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.menu,
                    color: textColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: cs.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Revenue Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              // User avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primaryContainer,
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/avatar_placeholder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person,
                    color: cs.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '${_getGreeting()}, $userName',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Theo dõi hiệu suất doanh thu của bạn trong tháng này.',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Xuất báo cáo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => _showWithdrawSheet(context),
            icon: const Icon(Icons.account_balance_wallet, size: 18),
            label: const Text('Rút tiền ngay'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biểu đồ doanh thu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thống kê $_selectedPeriod qua',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isDense: true,
                    underline: const SizedBox(),
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ['7 ngày', '30 ngày', '3 tháng']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPeriod = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            // Chart placeholder
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: const Size(double.infinity, 150),
                painter: _ChartPainter(cs.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // X-axis labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                  .map((d) => Text(
                        d,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4F46E5),
              const Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SỐ DƯ KHẢ DỤNG',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatCurrency(24500000),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _showWithdrawSheet(context),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Rút tiền'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đang chờ xử lý',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatCurrency(5200000),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Giải ngân sau 7 ngày',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng doanh thu',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _formatCurrency(158900000),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '+12% so với tháng trước',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseRevenueSection(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = context.weatherTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Doanh thu theo khóa học',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    Text('Xem tất cả'),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Column(
            children: [
              _CourseRevenueCard(
                icon: Icons.code,
                iconColor: Colors.blue,
                title: 'Mastering Next.js 15',
                revenue: 12450000,
                progress: 0.85,
                isBestSeller: true,
              ),
              const SizedBox(height: AppSpacing.md),
              _CourseRevenueCard(
                icon: Icons.data_object,
                iconColor: Colors.green,
                title: 'Python Masterclass',
                revenue: 8100000,
                progress: 0.60,
              ),
              const SizedBox(height: AppSpacing.md),
              _CourseRevenueCard(
                icon: Icons.speed,
                iconColor: Colors.purple,
                title: 'Go Fiber High Performance',
                revenue: 4350000,
                progress: 0.30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = context.weatherTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 16),
                label: const Text('Lọc'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
          child: Column(
            children: [
              _TransactionItem(
                name: 'Trần Huy',
                course: 'Mastering Next.js 15',
                amount: 1250000,
                date: '14:20 • 20 Tháng 10, 2023',
                avatarColor: Colors.blue,
              ),
              const SizedBox(height: AppSpacing.md),
              _TransactionItem(
                name: 'Lê Anh',
                course: 'Python Masterclass',
                amount: 950000,
                date: '11:05 • 20 Tháng 10, 2023',
                avatarColor: Colors.green,
              ),
              const SizedBox(height: AppSpacing.md),
              _TransactionItem(
                name: 'Minh Nguyệt',
                course: 'Go Fiber High Performance',
                amount: 1500000,
                date: '09:45 • 20 Tháng 10, 2023',
                avatarColor: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _WithdrawSheet(),
    );
  }

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)} đ';
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    // Sample data points
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width, size.height * 0.35),
    ];

    path.moveTo(points.first.dx, points.first.dy);
    fillPath.moveTo(points.first.dx, size.height);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final controlX = (p0.dx + p1.dx) / 2;

      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CourseRevenueCard extends StatelessWidget {
  const _CourseRevenueCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.revenue,
    required this.progress,
    this.isBestSeller = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final double revenue;
  final double progress;
  final bool isBestSeller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const Spacer(),
              if (isBestSeller)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BÁN CHẠY NHẤT',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatCurrency(revenue),
            style: TextStyle(
              color: cs.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'MỤC TIÊU THÁNG',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.primaryContainer,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)} đ';
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.name,
    required this.course,
    required this.amount,
    required this.date,
    required this.avatarColor,
  });

  final String name;
  final String course;
  final double amount;
  final String date;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor.withValues(alpha: 0.2),
            child: Text(
              name[0],
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  course,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ ${_formatCurrency(amount)}',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final normalized = amount.round();
    return '${NumberFormat.decimalPattern('vi_VN').format(normalized)} đ';
  }
}

class _WithdrawSheet extends StatelessWidget {
  const _WithdrawSheet();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Rút tiền',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Số dư khả dụng: 24.500.000 đ',
            style: TextStyle(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Số tiền rút',
              hintText: 'Nhập số tiền',
              suffixText: 'đ',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: InputDecoration(
              labelText: 'Ngân hàng',
              hintText: 'Chọn ngân hàng',
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: const OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: InputDecoration(
              labelText: 'Số tài khoản',
              hintText: 'Nhập số tài khoản',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Yêu cầu rút tiền đã được gửi!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Xác nhận rút tiền'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
