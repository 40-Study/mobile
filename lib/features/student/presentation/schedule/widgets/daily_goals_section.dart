import 'package:flutter/material.dart';
import 'package:study/data/daily_goals_storage.dart';
import 'package:study/theme/theme.dart';

import 'goal_tile.dart';
import 'empty_goals.dart';

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

  void _addGoal() {
    final text = _controller.text.trim();
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final goals = _goals;
    final completedCount = goals.where((g) => g.isCompleted).length;
    final progress = goals.isEmpty ? 0.0 : completedCount / goals.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outline),
        boxShadow: AppShadows.layeredCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với progress
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mục tiêu hôm nay',
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$completedCount/${goals.length}',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppSpacing.vGap8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.outline.withValues(alpha: 0.2),
              minHeight: 6,
            ),
          ),

          AppSpacing.vGap16,

          // Goals list or empty state
          if (goals.isEmpty && !_isAdding)
            EmptyGoals(onAdd: () => setState(() => _isAdding = true))
          else ...[
            // Goals
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

            // Add input or button
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            style: tt.bodyLarge,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Viết mục tiêu của bạn...',
              hintStyle: tt.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              filled: true,
              fillColor: cs.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
            onSubmitted: (_) => _addGoal(),
          ),
          AppSpacing.vGap12,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() {
                  _isAdding = false;
                  _controller.clear();
                }),
                child: Text(
                  'Huỷ',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              AppSpacing.hGap8,
              FilledButton.icon(
                onPressed: _addGoal,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ColorScheme cs, TextTheme tt) {
    return InkWell(
      onTap: () => setState(() => _isAdding = true),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: cs.primary),
            AppSpacing.hGap4,
            Text(
              'Thêm mục tiêu',
              style: tt.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
