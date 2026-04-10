import 'package:flutter/material.dart';
import 'package:study/theme/app_colors.dart';
import '../../data/models/bi_models.dart';
import '../widgets/widgets.dart';

/// Màn hình Insights tự động
class BIInsightsScreen extends StatefulWidget {
  const BIInsightsScreen({super.key});

  @override
  State<BIInsightsScreen> createState() => _BIInsightsScreenState();
}

class _BIInsightsScreenState extends State<BIInsightsScreen> {
  InsightType? _selectedType;

  final _insights = [
    BusinessInsight(
      id: '1',
      title: 'Đầu tư tăng, doanh thu giảm',
      description:
          'Basic Education Hub đã tăng đầu tư 15% trong tháng này nhưng doanh thu giảm 18.3%. Cần xem xét lại chiến lược marketing hoặc chất lượng nội dung.',
      type: InsightType.risk,
      severity: InsightSeverity.critical,
      centerId: '9',
      centerName: 'Basic Education Hub',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      metadata: {'investment_change': 15, 'revenue_change': -18.3},
    ),
    BusinessInsight(
      id: '2',
      title: 'ROI cao với tăng trưởng ổn định',
      description:
          'Elite Academy duy trì ROI 4.0x với tốc độ tăng trưởng 32.5%. Trung tâm này là mô hình hoạt động hiệu quả.',
      type: InsightType.roi,
      severity: InsightSeverity.positive,
      centerId: '1',
      centerName: 'Elite Academy',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      metadata: {'roi': 4.0, 'growth': 32.5},
    ),
    BusinessInsight(
      id: '3',
      title: 'Chi phí AI cao, hiệu quả thấp',
      description:
          'Classic Learning chi 8 triệu VND cho AI nhưng chỉ tạo ra 12 triệu VND doanh thu. ROI AI 1.5x thấp hơn mức trung bình nền tảng 4.0x.',
      type: InsightType.aiPerformance,
      severity: InsightSeverity.warning,
      centerId: '8',
      centerName: 'Classic Learning',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      metadata: {'ai_cost': 8000000, 'ai_revenue': 12000000, 'ai_roi': 1.5},
    ),
    BusinessInsight(
      id: '4',
      title: 'Tăng tốc tăng trưởng doanh thu',
      description:
          'Future Learn Hub có tốc độ tăng trưởng doanh thu tăng từ 18% lên 24.8% trong quý vừa qua. Mức độ tương tác người dùng mạnh.',
      type: InsightType.growth,
      severity: InsightSeverity.positive,
      centerId: '2',
      centerName: 'Future Learn Hub',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {'previous_growth': 18, 'current_growth': 24.8},
    ),
    BusinessInsight(
      id: '5',
      title: 'Cơ hội tối ưu marketing',
      description:
          'Digital Campus có CAC thấp hơn (50K) so với mức trung bình nền tảng (75K). Có thể tăng ngân sách marketing để thu hút thêm người dùng hiệu quả.',
      type: InsightType.investment,
      severity: InsightSeverity.neutral,
      centerId: '5',
      centerName: 'Digital Campus',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      metadata: {'cac': 50000, 'platform_avg_cac': 75000},
    ),
    BusinessInsight(
      id: '6',
      title: 'Giảm tương tác người dùng',
      description:
          'Knowledge Hub có hoạt động người dùng giảm 25% trong tháng này. Tỷ lệ hoàn thành khóa học cũng giảm. Có thể có vấn đề về chất lượng nội dung.',
      type: InsightType.risk,
      severity: InsightSeverity.warning,
      centerId: '7',
      centerName: 'Knowledge Hub',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      metadata: {'engagement_drop': 25},
    ),
    BusinessInsight(
      id: '7',
      title: 'Cột mốc doanh thu nền tảng',
      description:
          'Tổng doanh thu nền tảng vượt 2.4 tỷ VND trong tháng này, tăng trưởng 18.5% so với cùng kỳ năm trước. Top 3 trung tâm đóng góp 56.5% tổng doanh thu.',
      type: InsightType.revenue,
      severity: InsightSeverity.positive,
      centerId: null,
      centerName: null,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      metadata: {'total_revenue': 2450000000, 'yoy_growth': 18.5},
    ),
  ];

  List<BusinessInsight> get _filteredInsights {
    if (_selectedType == null) return _insights;
    return _insights.where((i) => i.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          BICompactHeader(
            title: 'Insights',
            subtitle: 'Phân tích tự động từ dữ liệu',
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Làm mới',
              ),
            ],
          ),

          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  isSelected: _selectedType == null,
                  onTap: () => setState(() => _selectedType = null),
                ),
                _FilterChip(
                  label: 'Doanh thu',
                  icon: Icons.attach_money_rounded,
                  isSelected: _selectedType == InsightType.revenue,
                  onTap: () => setState(() => _selectedType = InsightType.revenue),
                ),
                _FilterChip(
                  label: 'ROI',
                  icon: Icons.trending_up_rounded,
                  isSelected: _selectedType == InsightType.roi,
                  onTap: () => setState(() => _selectedType = InsightType.roi),
                ),
                _FilterChip(
                  label: 'Tăng trưởng',
                  icon: Icons.show_chart_rounded,
                  isSelected: _selectedType == InsightType.growth,
                  onTap: () => setState(() => _selectedType = InsightType.growth),
                ),
                _FilterChip(
                  label: 'AI',
                  icon: Icons.auto_awesome_rounded,
                  isSelected: _selectedType == InsightType.aiPerformance,
                  onTap: () => setState(() => _selectedType = InsightType.aiPerformance),
                ),
                _FilterChip(
                  label: 'Rủi ro',
                  icon: Icons.warning_rounded,
                  isSelected: _selectedType == InsightType.risk,
                  onTap: () => setState(() => _selectedType = InsightType.risk),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Summary counts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _InsightSummary(insights: _insights),
          ),

          const SizedBox(height: 16),

          // Insights list
          Expanded(
            child: _filteredInsights.isEmpty
                ? BIEmptyState(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Không có insights',
                    subtitle: 'Thử chọn bộ lọc khác',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _filteredInsights.length,
                    itemBuilder: (context, index) {
                      final insight = _filteredInsights[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BIInsightCard(
                          insight: insight,
                          onTap: () => _showInsightDetail(context, insight),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showInsightDetail(BuildContext context, BusinessInsight insight) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _SeverityBadge(severity: insight.severity),
                      const SizedBox(width: 8),
                      Text(
                        _getTypeLabel(insight.type),
                        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    insight.title,
                    style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (insight.centerName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.business_rounded, size: 16, color: cs.primary),
                          const SizedBox(width: 8),
                          Text(
                            insight.centerName!,
                            style: tt.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    insight.description,
                    style: tt.bodyLarge?.copyWith(color: cs.onSurface, height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  if (insight.metadata.isNotEmpty) ...[
                    Text('Dữ liệu chính', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: insight.metadata.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatKey(entry.key),
                                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                ),
                                Text(
                                  _formatValue(entry.value),
                                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  if (insight.centerId != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('Xem chi tiết trung tâm'),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.revenue:
        return 'DOANH THU';
      case InsightType.investment:
        return 'ĐẦU TƯ';
      case InsightType.roi:
        return 'ROI';
      case InsightType.aiPerformance:
        return 'HIỆU SUẤT AI';
      case InsightType.growth:
        return 'TĂNG TRƯỞNG';
      case InsightType.risk:
        return 'RỦI RO';
    }
  }

  String _formatKey(String key) {
    final translations = {
      'investment_change': 'Thay đổi đầu tư',
      'revenue_change': 'Thay đổi doanh thu',
      'roi': 'ROI',
      'growth': 'Tăng trưởng',
      'ai_cost': 'Chi phí AI',
      'ai_revenue': 'Doanh thu AI',
      'ai_roi': 'ROI AI',
      'previous_growth': 'Tăng trưởng trước',
      'current_growth': 'Tăng trưởng hiện tại',
      'cac': 'CAC',
      'platform_avg_cac': 'CAC TB nền tảng',
      'engagement_drop': 'Giảm tương tác',
      'total_revenue': 'Tổng doanh thu',
      'yoy_growth': 'Tăng trưởng YoY',
    };
    return translations[key] ?? key.replaceAll('_', ' ');
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14),
              const SizedBox(width: 4),
            ],
            Text(label),
          ],
        ),
        onSelected: (_) => onTap(),
        selectedColor: cs.primaryContainer,
        checkmarkColor: cs.primary,
        labelStyle: tt.labelMedium?.copyWith(
          color: isSelected ? cs.primary : cs.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _InsightSummary extends StatelessWidget {
  const _InsightSummary({required this.insights});

  final List<BusinessInsight> insights;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final critical = insights.where((i) => i.severity == InsightSeverity.critical).length;
    final warning = insights.where((i) => i.severity == InsightSeverity.warning).length;
    final positive = insights.where((i) => i.severity == InsightSeverity.positive).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _SummaryItem(count: critical, label: 'Nghiêm trọng', color: cs.error),
          _Divider(),
          _SummaryItem(count: warning, label: 'Cảnh báo', color: cs.tertiary),
          _Divider(),
          _SummaryItem(count: positive, label: 'Tích cực', color: cs.secondary),
          _Divider(),
          _SummaryItem(count: insights.length, label: 'Tổng', color: cs.primary),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.count, required this.label, required this.color});

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(count.toString(),
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final InsightSeverity severity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (label, color) = switch (severity) {
      InsightSeverity.positive => ('Tích cực', cs.secondary),
      InsightSeverity.neutral => ('Trung lập', cs.primary),
      InsightSeverity.warning => ('Cảnh báo', cs.tertiary),
      InsightSeverity.critical => ('Nghiêm trọng', cs.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
