import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/student_classes/student_classes_cubit.dart';
import 'package:study/features/student/presentation/widgets/widgets.dart';

class StudentClassesScreen extends StatefulWidget {
  const StudentClassesScreen({super.key});

  @override
  State<StudentClassesScreen> createState() => _StudentClassesScreenState();
}

class _StudentClassesScreenState extends State<StudentClassesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentClassesCubit>().loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const StudentAppBar(title: 'Lop hoc cua toi'),
      body: BlocBuilder<StudentClassesCubit, StudentClassesState>(
        builder: (context, state) {
          return switch (state) {
            StudentClassesInitial() ||
            StudentClassesLoading() =>
              const Center(child: CircularProgressIndicator()),
            StudentClassesLoaded() => RefreshIndicator(
                onRefresh: context.read<StudentClassesCubit>().refresh,
                child: _ClassesContent(state: state),
              ),
            StudentClassesFailure(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<StudentClassesCubit>().loadClasses(),
                      child: const Text('Thu lai'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
    );
  }
}

class _ClassesContent extends StatelessWidget {
  const _ClassesContent({required this.state});

  final StudentClassesLoaded state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _FilterChip(
                label: 'Tat ca',
                isSelected: state.selectedFilter == 'all',
                onTap: () =>
                    context.read<StudentClassesCubit>().changeFilter('all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Dang hoc',
                isSelected: state.selectedFilter == 'active',
                onTap: () =>
                    context.read<StudentClassesCubit>().changeFilter('active'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Da ket thuc',
                isSelected: state.selectedFilter == 'completed',
                onTap: () => context
                    .read<StudentClassesCubit>()
                    .changeFilter('completed'),
              ),
            ],
          ),
        ),
        // Classes list
        Expanded(
          child: state.classes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: cs.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Khong co lop hoc nao',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.classes.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= state.classes.length) {
                      // Load more indicator
                      context.read<StudentClassesCubit>().loadMore();
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final classModel = state.classes[index];
                    return StudentClassCard(
                      classModel: classModel,
                      onTap: () {
                        // TODO: Navigate to class detail
                      },
                      onScheduleTap: () {
                        // TODO: Navigate to schedule
                      },
                      onAttendanceTap: () {
                        // TODO: Navigate to attendance
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap?.call(),
      backgroundColor: cs.surfaceContainerHighest,
      selectedColor: cs.primaryContainer,
      checkmarkColor: cs.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? cs.primary : Colors.transparent,
        ),
      ),
    );
  }
}
