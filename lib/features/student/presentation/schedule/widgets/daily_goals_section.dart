import 'package:flutter/material.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/theme/theme.dart';

import 'empty_goals.dart';
import 'goal_tile.dart';

class DailyGoalsSection extends StatefulWidget {
  const DailyGoalsSection({super.key, required this.date});

  final DateTime date;

  @override
  State<DailyGoalsSection> createState() => _DailyGoalsSectionState();
}

class _DailyGoalsSectionState extends State<DailyGoalsSection> {
  final _storage = DailyGoalsStorage.instance;
  final _controller = TextEditingController();
  final _customCategoryController = TextEditingController();
  bool _isAdding = false;
  String _selectedCategory = 'Học tập';

  static const _predefinedCategories = [
    ('Học tập', Icons.auto_stories_rounded, Color(0xFF10B981)),
    ('Bài tập', Icons.edit_note_rounded, Color(0xFFF59E0B)),
    ('Khóa học', Icons.school_rounded, Color(0xFF3D5FC4)),
    ('Ôn tập', Icons.restart_alt_rounded, Color(0xFF8B5CF6)),
    ('Khác', Icons.label_outline_rounded, Color(0xFF6366F1)),
  ];

  List<DailyGoalItem> get _goals => _storage.getGoals(widget.date);

  @override
  void didUpdateWidget(covariant DailyGoalsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _isAdding = false;
      _controller.clear();
      _customCategoryController.clear();
      _selectedCategory = 'Học tập';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _addGoal([String? customText]) {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty) return;

    final String effectiveCategory;
    if (_selectedCategory == 'Khác') {
      final customName = _customCategoryController.text.trim();
      effectiveCategory = customName.isNotEmpty ? customName : 'Khác';
    } else {
      effectiveCategory = _selectedCategory;
    }

    setState(() {
      _storage.addGoal(widget.date, text, category: effectiveCategory);
      _controller.clear();
      _customCategoryController.clear();
      _selectedCategory = 'Học tập';
      _isAdding = false;
    });
  }

  void _toggleGoal(String id) {
    setState(() {
      _storage.toggleGoal(widget.date, id);
    });
  }

  void _deleteGoal(String id) {
    setState(() {
      _storage.deleteGoal(widget.date, id);
    });
  }

  String _getMotivationalQuote(double progress, int total) {
    if (total == 0) {
      return 'Thiết lập các mục tiêu học tập rõ ràng để bứt phá ngày hôm nay!';
    }
    if (progress >= 1.0) {
      return 'Tuyệt vời! Bạn đã hoàn thành 100% mục tiêu hôm nay 🎉';
    }
    if (progress >= 0.5) {
      return 'Cố gắng lên, chỉ còn một chút nữa để hoàn thành ngày!';
    }
    if (progress > 0) {
      return 'Khởi đầu tuyệt vời! Hãy duy trì năng lượng học tập nhé 💪';
    }
    return 'Bắt đầu ngày học đầy hứng khởi bằng mục tiêu đầu tiên nào 🚀';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final goals = _goals;
    final completedCount = goals.where((g) => g.isCompleted).length;
    final progress = goals.isEmpty ? 0.0 : completedCount / goals.length;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Motivational Banner
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: !isLight ? cs.primary.withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.track_changes_rounded,
                  color: !isLight ? cs.primary : const Color(0xFF3D5FC4),
                  size: 22,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mục tiêu hôm nay',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.slate900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getMotivationalQuote(progress, goals.length),
                      style: tt.bodySmall?.copyWith(
                        color: cs.slate500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: !isLight ? cs.primary.withValues(alpha: 0.15) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: !isLight ? cs.primary.withValues(alpha: 0.3) : const Color(0xFFBFDBFE),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  goals.isEmpty ? '0 mục tiêu' : 'Đã xong $completedCount/${goals.length}',
                  style: TextStyle(
                    color: !isLight ? cs.primary : const Color(0xFF3D5FC4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isLight ? const Color(0xFFF1F5F9) : cs.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLight ? const Color(0xFF3D5FC4) : cs.primary,
              ),
              minHeight: 7,
            ),
          ),
          AppSpacing.vGap16,

          // 2. Goals list or empty state
          if (goals.isEmpty && !_isAdding)
            EmptyGoals(onAdd: () => setState(() => _isAdding = true))
          else ...[
            ...List.generate(goals.length, (index) {
              final goal = goals[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < goals.length - 1 ? AppSpacing.sm : 0,
                ),
                child: GoalTile(
                  goal: goal,
                  onToggle: () => _toggleGoal(goal.id),
                  onDelete: () => _deleteGoal(goal.id),
                ),
              );
            }),

            // 3. Add Goal Section
            AppSpacing.vGap12,
            if (_isAdding)
              _buildAddInput(cs, tt)
            else
              _buildAddButton(cs, tt),
          ],
        ],
      ),
    );
  }

  Widget _buildAddInput(ColorScheme cs, TextTheme tt) {
    final isCustomCategory = _selectedCategory == 'Khác';

    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: const Color(0xFF3D5FC4).withValues(alpha: 0.35),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D5FC4).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            style: tt.bodyMedium?.copyWith(
              color: cs.slate900,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Nhập mục tiêu học tập mới...',
              hintStyle: tt.bodySmall?.copyWith(color: cs.slate400),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            ),
            onSubmitted: (_) => _addGoal(),
          ),
          const SizedBox(height: 8),

          // Category Selection Label & Chips
          Row(
            children: [
              Text(
                'Phân loại:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.slate500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _predefinedCategories.map((cat) {
                final name = cat.$1;
                final icon = cat.$2;
                final color = cat.$3;
                final isSelected = _selectedCategory == name;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = name),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: isLight ? 0.12 : 0.22)
                            : (isLight ? const Color(0xFFF8FAFC) : cs.surfaceContainerHigh),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: isSelected
                              ? color.withValues(alpha: isLight ? 0.7 : 0.85)
                              : (isLight ? const Color(0xFFE2E8F0) : cs.outlineVariant.withValues(alpha: 0.4)),
                          width: isSelected ? 1.2 : 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 13,
                            color: isSelected
                                ? color
                                : (isLight ? cs.slate400 : cs.slate400),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? color
                                  : (isLight ? cs.slate600 : cs.slate200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Custom Category Input (When 'Khác' is selected)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isCustomCategory
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLight ? const Color(0xFFF8FAFC) : cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                          width: 0.9,
                        ),
                      ),
                      child: TextField(
                        controller: _customCategoryController,
                        maxLength: 20,
                        style: tt.bodySmall?.copyWith(
                          color: cs.slate900,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên phân loại riêng (VD: Đọc sách, Dự án...)',
                          hintStyle: tt.bodySmall?.copyWith(
                            color: cs.slate400,
                            fontSize: 11.5,
                          ),
                          counterText: '',
                          isDense: true,
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: Color(0xFF6366F1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                        onSubmitted: (_) => _addGoal(),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // Quick Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'Gợi ý:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.slate400,
                  ),
                ),
                const SizedBox(width: 6),
                _buildQuickChip('📖 Học 1 bài mới', 'Khóa học'),
                const SizedBox(width: 6),
                _buildQuickChip('✍️ Làm trắc nghiệm', 'Bài tập'),
                const SizedBox(width: 6),
                _buildQuickChip('⏱ Ôn bài 30 phút', 'Ôn tập'),
              ],
            ),
          ),
          Divider(
            height: 18,
            thickness: 0.6,
            color: isLight
                ? const Color(0xFFF1F5F9)
                : cs.outlineVariant.withValues(alpha: 0.25),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => setState(() {
                  _isAdding = false;
                  _controller.clear();
                  _customCategoryController.clear();
                  _selectedCategory = 'Học tập';
                }),
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Hủy',
                    style: TextStyle(
                      color: cs.slate500,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              AppSpacing.hGap8,
              Material(
                color: const Color(0xFF3D5FC4),
                borderRadius: BorderRadius.circular(AppRadius.full),
                elevation: 1,
                shadowColor: const Color(0xFF3D5FC4).withValues(alpha: 0.3),
                child: InkWell(
                  onTap: () => _addGoal(),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 15, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Thêm mục tiêu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, [String? suggestedCategory]) {
    return InkWell(
      onTap: () {
        final text = label.substring(label.indexOf(' ') + 1); // strip emoji
        _controller.text = text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        if (suggestedCategory != null) {
          setState(() {
            _selectedCategory = suggestedCategory;
          });
        }
      },
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          final isLight = Theme.of(context).brightness == Brightness.light;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isLight ? const Color(0xFFEFF6FF) : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isLight
                    ? const Color(0xFFBFDBFE).withValues(alpha: 0.6)
                    : cs.outlineVariant.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isLight ? const Color(0xFF3D5FC4) : cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(ColorScheme cs, TextTheme tt) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: isLight ? const Color(0xFFF8FAFC) : cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () => setState(() => _isAdding = true),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isLight ? const Color(0xFFE2E8F0) : cs.outlineVariant.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFEFF6FF) : cs.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: isLight ? const Color(0xFF3D5FC4) : cs.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Thêm mục tiêu mới cho hôm nay',
                style: TextStyle(
                  color: isLight ? const Color(0xFF3D5FC4) : cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
