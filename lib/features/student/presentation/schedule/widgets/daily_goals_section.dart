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
  bool _isAdding = false;

  List<DailyGoalItem> get _goals => _storage.getGoals(widget.date);

  @override
  void didUpdateWidget(covariant DailyGoalsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      _isAdding = false;
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addGoal([String? customText]) {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _storage.addGoal(widget.date, text);
      _controller.clear();
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Color(0xFF3D5FC4),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  goals.isEmpty ? '0 mục tiêu' : 'Đã xong $completedCount/${goals.length}',
                  style: const TextStyle(
                    color: Color(0xFF3D5FC4),
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
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3D5FC4)),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const SizedBox(height: 6),

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
                _buildQuickChip('📖 Học 1 bài mới'),
                const SizedBox(width: 6),
                _buildQuickChip('✍️ Làm trắc nghiệm'),
                const SizedBox(width: 6),
                _buildQuickChip('⏱ Ôn bài 30 phút'),
              ],
            ),
          ),
          const Divider(height: 18, thickness: 0.6, color: Color(0xFFF1F5F9)),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => setState(() {
                  _isAdding = false;
                  _controller.clear();
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

  Widget _buildQuickChip(String label) {
    return InkWell(
      onTap: () {
        final text = label.substring(label.indexOf(' ') + 1); // strip emoji
        _controller.text = text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      },
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: const Color(0xFFBFDBFE).withValues(alpha: 0.6),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF3D5FC4),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(ColorScheme cs, TextTheme tt) {
    return Material(
      color: const Color(0xFFF8FAFC),
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
              color: const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: Color(0xFF3D5FC4),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Thêm mục tiêu mới cho hôm nay',
                style: TextStyle(
                  color: Color(0xFF3D5FC4),
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
