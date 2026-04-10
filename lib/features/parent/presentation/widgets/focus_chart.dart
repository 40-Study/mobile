import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/theme/app_colors.dart';

enum FocusChartFilter { day, week, month, year }

enum FocusChartClassFilter { all, math, english, science, literature, history }

class FocusChart extends StatefulWidget {
  const FocusChart({
    super.key,
    this.sessions = const [],
    this.height = 220,
    this.showFilters = true,
  });

  final List<FocusSessionModel> sessions;
  final double height;
  final bool showFilters;

  @override
  State<FocusChart> createState() => _FocusChartState();
}

class _FocusChartState extends State<FocusChart> {
  FocusChartFilter _timeFilter = FocusChartFilter.week;
  FocusChartClassFilter _classFilter = FocusChartClassFilter.all;

  List<_ChartPoint> get _chartData {
    switch (_timeFilter) {
      case FocusChartFilter.day:
        return [
          _ChartPoint('8h', 72),
          _ChartPoint('9h', 85),
          _ChartPoint('10h', 78),
          _ChartPoint('11h', 90),
          _ChartPoint('14h', 82),
          _ChartPoint('15h', 75),
          _ChartPoint('16h', 88),
        ];
      case FocusChartFilter.week:
        return [
          _ChartPoint('T2', 75),
          _ChartPoint('T3', 82),
          _ChartPoint('T4', 68),
          _ChartPoint('T5', 90),
          _ChartPoint('T6', 85),
          _ChartPoint('T7', 72),
          _ChartPoint('CN', 88),
        ];
      case FocusChartFilter.month:
        return [
          _ChartPoint('T1', 78),
          _ChartPoint('T2', 82),
          _ChartPoint('T3', 75),
          _ChartPoint('T4', 88),
        ];
      case FocusChartFilter.year:
        return [
          _ChartPoint('T1', 72),
          _ChartPoint('T2', 75),
          _ChartPoint('T3', 80),
          _ChartPoint('T4', 78),
          _ChartPoint('T5', 85),
          _ChartPoint('T6', 82),
          _ChartPoint('T7', 88),
          _ChartPoint('T8', 85),
          _ChartPoint('T9', 90),
          _ChartPoint('T10', 87),
          _ChartPoint('T11', 92),
          _ChartPoint('T12', 89),
        ];
    }
  }

  String get _filterLabel {
    switch (_timeFilter) {
      case FocusChartFilter.day:
        return 'Hom nay';
      case FocusChartFilter.week:
        return '7 ngay qua';
      case FocusChartFilter.month:
        return 'Thang nay';
      case FocusChartFilter.year:
        return 'Nam nay';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = _chartData;
    final avgFocus = data.map((d) => d.value).reduce((a, b) => a + b) / data.length;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Muc do tap trung',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _filterLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.textSecondary,
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
                  color: _getAvgColor(avgFocus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: _getAvgColor(avgFocus),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'TB: ${avgFocus.toStringAsFixed(0)}%',
                      style: textTheme.labelMedium?.copyWith(
                        color: _getAvgColor(avgFocus),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (widget.showFilters) ...[
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Ngay',
                    isSelected: _timeFilter == FocusChartFilter.day,
                    onTap: () => setState(() => _timeFilter = FocusChartFilter.day),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Tuan',
                    isSelected: _timeFilter == FocusChartFilter.week,
                    onTap: () => setState(() => _timeFilter = FocusChartFilter.week),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Thang',
                    isSelected: _timeFilter == FocusChartFilter.month,
                    onTap: () => setState(() => _timeFilter = FocusChartFilter.month),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _FilterChip(
                    label: 'Nam',
                    isSelected: _timeFilter == FocusChartFilter.year,
                    onTap: () => setState(() => _timeFilter = FocusChartFilter.year),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 1,
                    height: 24,
                    color: cs.outlineVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _ClassFilterDropdown(
                    value: _classFilter,
                    onChanged: (v) => setState(() => _classFilter = v),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: widget.height - (widget.showFilters ? 120 : 60),
            child: _LineChart(data: data),
          ),
        ],
      ),
    );
  }

  Color _getAvgColor(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.data});

  final List<_ChartPoint> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
        final minValue = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
        final normalizedMax = ((maxValue + 5) / 10).ceil() * 10;
        final normalizedMin = ((minValue - 5) / 10).floor() * 10;

        return Row(
          children: [
            SizedBox(
              width: 32,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$normalizedMax%',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                  Text(
                    '${(normalizedMax + normalizedMin) ~/ 2}%',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                  Text(
                    '$normalizedMin%',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: Size(width - 40, height - 20),
                      painter: _LineChartPainter(
                        data: data,
                        lineColor: cs.primary,
                        fillColor: cs.primary.withValues(alpha: 0.1),
                        gridColor: cs.outlineVariant.withValues(alpha: 0.3),
                        pointBorderColor: cs.surfaceContainerLowest,
                        normalizedMin: normalizedMin.toDouble(),
                        normalizedMax: normalizedMax.toDouble(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: data.map((point) {
                      return Expanded(
                        child: Text(
                          point.label,
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.pointBorderColor,
    required this.normalizedMin,
    required this.normalizedMax,
  });

  final List<_ChartPoint> data;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color pointBorderColor;
  final double normalizedMin;
  final double normalizedMax;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final range = normalizedMax - normalizedMin;
    final stepX = size.width / (data.length - 1);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i].value - normalizedMin) / range) * size.height;
      points.add(Offset(x, y));
    }

    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    final pointPaint = Paint()..color = lineColor;
    final pointBorderPaint = Paint()
      ..color = pointBorderColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      canvas.drawCircle(point, 5, pointPaint);
      canvas.drawCircle(point, 5, pointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: isSelected ? cs.onPrimary : cs.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ClassFilterDropdown extends StatelessWidget {
  const _ClassFilterDropdown({
    required this.value,
    required this.onChanged,
  });

  final FocusChartClassFilter value;
  final ValueChanged<FocusChartClassFilter> onChanged;

  String get _label {
    switch (value) {
      case FocusChartClassFilter.all:
        return 'Tat ca lop';
      case FocusChartClassFilter.math:
        return 'Toan';
      case FocusChartClassFilter.english:
        return 'Tieng Anh';
      case FocusChartClassFilter.science:
        return 'Khoa hoc';
      case FocusChartClassFilter.literature:
        return 'Ngu van';
      case FocusChartClassFilter.history:
        return 'Lich su';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuButton<FocusChartClassFilter>(
      onSelected: onChanged,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label,
              style: textTheme.labelSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: cs.textSecondary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem(context, FocusChartClassFilter.all, 'Tat ca lop'),
        _buildMenuItem(context, FocusChartClassFilter.math, 'Toan'),
        _buildMenuItem(context, FocusChartClassFilter.english, 'Tieng Anh'),
        _buildMenuItem(context, FocusChartClassFilter.science, 'Khoa hoc'),
        _buildMenuItem(context, FocusChartClassFilter.literature, 'Ngu van'),
        _buildMenuItem(context, FocusChartClassFilter.history, 'Lich su'),
      ],
    );
  }

  PopupMenuItem<FocusChartClassFilter> _buildMenuItem(
    BuildContext context,
    FocusChartClassFilter filter,
    String label,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return PopupMenuItem(
      value: filter,
      height: 40,
      child: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: value == filter ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _ChartPoint {
  _ChartPoint(this.label, this.value);

  final String label;
  final double value;
}

class FocusChartCompact extends StatelessWidget {
  const FocusChartCompact({super.key});

  static final List<_ChartPoint> _mockData = [
    _ChartPoint('T2', 75),
    _ChartPoint('T3', 82),
    _ChartPoint('T4', 68),
    _ChartPoint('T5', 90),
    _ChartPoint('T6', 85),
    _ChartPoint('T7', 72),
    _ChartPoint('CN', 88),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = _mockData;
    final avgFocus = data.map((d) => d.value).reduce((a, b) => a + b) / data.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                    'Muc do tap trung',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '7 ngay qua',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.textSecondary,
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
                  color: _getAvgColor(avgFocus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 16,
                      color: _getAvgColor(avgFocus),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${avgFocus.toStringAsFixed(0)}%',
                      style: textTheme.labelLarge?.copyWith(
                        color: _getAvgColor(avgFocus),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 100,
            child: _LineChartCompact(data: data),
          ),
        ],
      ),
    );
  }

  Color _getAvgColor(double value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _LineChartCompact extends StatelessWidget {
  const _LineChartCompact({required this.data});

  final List<_ChartPoint> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Column(
          children: [
            Expanded(
              child: CustomPaint(
                size: Size(width, height - 20),
                painter: _LineChartPainter(
                  data: data,
                  lineColor: cs.primary,
                  fillColor: cs.primary.withValues(alpha: 0.15),
                  gridColor: cs.outlineVariant.withValues(alpha: 0.2),
                  pointBorderColor: cs.surfaceContainerLowest,
                  normalizedMin: 50,
                  normalizedMax: 100,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.map((point) {
                return Expanded(
                  child: Text(
                    point.label,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
