import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  final _goals = <_GoalItem>[];
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addGoal() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _goals.add(_GoalItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text,
      ));
      _controller.clear();
    });
  }

  void _toggleGoal(String id) {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(
          isCompleted: !_goals[index].isCompleted,
        );
      }
    });
  }

  void _deleteGoal(String id) {
    setState(() {
      _goals.removeWhere((g) => g.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final completedCount = _goals.where((g) => g.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mục tiêu ngày ${widget.date.day}/${widget.date.month}'),
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.secondaryContainer],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _goals.isEmpty
                          ? '0'
                          : '${(completedCount / _goals.length * 100).round()}%',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
                AppSpacing.hGap16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoàn thành $completedCount/${_goals.length}',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vGap4,
                      if (_goals.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completedCount / _goals.length,
                            backgroundColor: cs.surface,
                            minHeight: 6,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Add goal input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Thêm mục tiêu mới...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onSubmitted: (_) => _addGoal(),
                  ),
                ),
                AppSpacing.hGap8,
                IconButton.filled(
                  onPressed: _addGoal,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          AppSpacing.vGap16,

          // Goals list
          Expanded(
            child: _goals.isEmpty
                ? _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: _goals.length,
                    separatorBuilder: (_, __) => AppSpacing.vGap8,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      return _GoalTile(
                        goal: goal,
                        onToggle: () => _toggleGoal(goal.id),
                        onDelete: () => _deleteGoal(goal.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GoalItem {
  _GoalItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  _GoalItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return _GoalItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  final _GoalItem goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.delete, color: cs.onErrorContainer),
      ),
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: goal.isCompleted ? cs.primary : Colors.transparent,
                    border: Border.all(
                      color: goal.isCompleted ? cs.primary : cs.outline,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: goal.isCompleted
                      ? Icon(Icons.check, size: 16, color: cs.onPrimary)
                      : null,
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Text(
                    goal.title,
                    style: tt.bodyMedium?.copyWith(
                      decoration:
                          goal.isCompleted ? TextDecoration.lineThrough : null,
                      color: goal.isCompleted ? cs.outline : cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: cs.outline,
          ),
          AppSpacing.vGap12,
          Text(
            'Chưa có mục tiêu nào',
            style: tt.titleSmall?.copyWith(color: cs.outline),
          ),
          AppSpacing.vGap4,
          Text(
            'Thêm mục tiêu để bắt đầu ngày mới!',
            style: tt.bodySmall?.copyWith(color: cs.outline),
          ),
        ],
      ),
    );
  }
}
