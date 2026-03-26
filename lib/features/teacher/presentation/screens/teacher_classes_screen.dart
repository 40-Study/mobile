import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/bloc/classes/teacher_classes_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';
import 'package:study/features/teacher/presentation/widgets/widgets.dart';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  static const _filters = [
    FilterItem(label: 'Tat ca', value: 'all'),
    FilterItem(label: 'Dang hoat dong', value: 'active'),
    FilterItem(label: 'Da hoan thanh', value: 'completed'),
    FilterItem(label: 'Da huy', value: 'cancelled'),
  ];

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TeacherClassesCubit>().loadClasses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: TeacherAppBar(
        title: 'Quan ly lop hoc',
        showSearch: false,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to create class
              Navigator.pushNamed(context, '/teacher/classes/create');
            },
            icon: Icon(Icons.add_circle_outline, color: cs.primary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TeacherClassesCubit>().refresh(),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tim kiem lop hoc...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            context.read<TeacherClassesCubit>().search('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  context.read<TeacherClassesCubit>().search(value);
                },
              ),
            ),

            // Stats card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: BlocSelector<TeacherClassesCubit, TeacherClassesState,
                  _ClassStats>(
                selector: (state) {
                  if (state is TeacherClassesLoaded) {
                    return _ClassStats(
                      total: state.classes.length,
                      active: state.activeCount,
                      students: state.totalStudents,
                    );
                  }
                  return const _ClassStats(total: 0, active: 0, students: 0);
                },
                builder: (context, stats) {
                  return Row(
                    children: [
                      _StatItem(
                        label: 'Tong lop',
                        value: '${stats.total}',
                        icon: Icons.class_outlined,
                      ),
                      const SizedBox(width: 24),
                      _StatItem(
                        label: 'Dang hoat dong',
                        value: '${stats.active}',
                        icon: Icons.play_circle_outline,
                      ),
                      const SizedBox(width: 24),
                      _StatItem(
                        label: 'Hoc vien',
                        value: '${stats.students}',
                        icon: Icons.people_outline,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocSelector<TeacherClassesCubit, TeacherClassesState,
                  String>(
                selector: (state) => state.selectedFilter,
                builder: (context, selectedFilter) {
                  return FilterChipBar(
                    filters: _filters,
                    selectedFilter: selectedFilter,
                    onFilterChanged:
                        context.read<TeacherClassesCubit>().changeFilter,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Classes list
            Expanded(
              child: BlocBuilder<TeacherClassesCubit, TeacherClassesState>(
                builder: (context, state) {
                  return switch (state) {
                    TeacherClassesInitial() ||
                    TeacherClassesLoading() =>
                      const Center(child: CircularProgressIndicator()),
                    TeacherClassesLoaded(:final classes) => classes.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: classes.length,
                            itemBuilder: (context, index) {
                              final classModel = classes[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ClassCard(
                                  classModel: classModel,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/teacher/classes/detail',
                                      arguments: classModel.id,
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/teacher/classes/edit',
                                      arguments: classModel,
                                    );
                                  },
                                  onDelete: () {
                                    _showDeleteDialog(context, classModel);
                                  },
                                ),
                              );
                            },
                          ),
                    TeacherClassesFailure(:final message) =>
                      _buildErrorState(context, message),
                  };
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/teacher/classes/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Tao lop moi'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Chua co lop hoc nao',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tao lop hoc dau tien cua ban',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.read<TeacherClassesCubit>().loadClasses(),
            child: const Text('Thu lai'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ClassModel classModel) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xac nhan xoa'),
        content: Text(
          'Ban co chac chan muon xoa lop "${classModel.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TeacherClassesCubit>().deleteClass(classModel.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

class _ClassStats {
  const _ClassStats({
    required this.total,
    required this.active,
    required this.students,
  });

  final int total;
  final int active;
  final int students;
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.classModel,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final ClassModel classModel;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.class_outlined,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classModel.displayName,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (classModel.courseName != null)
                          Text(
                            classModel.courseName!,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  _StatusChip(status: classModel.classStatus),
                ],
              ),
              const SizedBox(height: 16),

              // Info row
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.people_outline,
                    label: '${classModel.studentCount}/${classModel.maxStudents}',
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: classModel.dateRange,
                  ),
                ],
              ),

              // Progress bar
              if (classModel.maxStudents > 0) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: classModel.fillPercentage / 100,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: classModel.isFull ? cs.error : cs.primary,
                    minHeight: 4,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Chinh sua'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                    label: Text('Xoa', style: TextStyle(color: cs.error)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ClassStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case ClassStatus.active:
        backgroundColor = cs.tertiary.withValues(alpha: 0.1);
        textColor = cs.tertiary;
        label = 'Hoat dong';
      case ClassStatus.inactive:
        backgroundColor = cs.secondary.withValues(alpha: 0.1);
        textColor = cs.secondary;
        label = 'Tam dung';
      case ClassStatus.completed:
        backgroundColor = cs.primary.withValues(alpha: 0.1);
        textColor = cs.primary;
        label = 'Hoan thanh';
      case ClassStatus.cancelled:
        backgroundColor = cs.error.withValues(alpha: 0.1);
        textColor = cs.error;
        label = 'Da huy';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
