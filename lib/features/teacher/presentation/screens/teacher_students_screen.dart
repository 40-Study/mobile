import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/bloc/students/teacher_students_cubit.dart';
import 'package:study/features/teacher/presentation/widgets/widgets.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TeacherStudentsCubit>().loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const TeacherAppBar(title: 'Giảng viên'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new student
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danh sách học viên',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                BlocSelector<TeacherStudentsCubit, TeacherStudentsState, int>(
                  selector: (state) {
                    if (state is TeacherStudentsLoaded) {
                      return state.totalStudents;
                    }
                    return 0;
                  },
                  builder: (context, count) {
                    return Text(
                      'Quản lý và theo dõi tiến độ của $count học viên.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<TeacherStudentsCubit>().search(value);
              },
              decoration: InputDecoration(
                hintText: 'Tìm tên, ID học viên...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                // Show filter bottom sheet
              },
              icon: const Icon(Icons.tune, size: 18),
              label: const Text('Bộ lọc'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Students list
          Expanded(
            child: BlocBuilder<TeacherStudentsCubit, TeacherStudentsState>(
              builder: (context, state) {
                return switch (state) {
                  TeacherStudentsInitial() ||
                  TeacherStudentsLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  TeacherStudentsLoaded(:final students) =>
                    students.isEmpty
                        ? _EmptyState(cs: cs, tt: tt)
                        : RefreshIndicator(
                            onRefresh:
                                context.read<TeacherStudentsCubit>().refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: students.length + 1, // +1 for add card
                              itemBuilder: (context, index) {
                                if (index == students.length) {
                                  return _AddStudentCard(cs: cs, tt: tt);
                                }
                                final student = students[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: StudentCard(
                                    student: student,
                                    onTap: () {
                                      // Navigate to student detail
                                    },
                                    onMoreTap: () {
                                      // Show more options
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                  TeacherStudentsFailure(:final message) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: cs.error,
                          ),
                          const SizedBox(height: 16),
                          Text(message),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context
                                .read<TeacherStudentsCubit>()
                                .loadStudents(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.cs, required this.tt});

  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có học viên nào',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStudentCard extends StatelessWidget {
  const _AddStudentCard({required this.cs, required this.tt});

  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(
          color: cs.outlineVariant,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_outlined,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Thêm học viên',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tạo mới tài khoản nhanh',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
