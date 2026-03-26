import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/bloc/classes/teacher_class_detail_cubit.dart';
import 'package:study/features/teacher/data/models/models.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({
    super.key,
    required this.classId,
  });

  final String classId;

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() {
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    context.read<TeacherClassDetailCubit>().loadAttendances(
          widget.classId,
          sessionDate: dateStr,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Diem danh'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAttendance,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Luu'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                    _loadAttendance();
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: cs.primary),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(_selectedDate),
                            style: tt.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _selectedDate.isBefore(DateTime.now())
                      ? () {
                          setState(() {
                            _selectedDate =
                                _selectedDate.add(const Duration(days: 1));
                          });
                          _loadAttendance();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Quick actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    label: 'Tat ca co mat',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onPressed: () => _markAll(AttendanceStatus.present),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    label: 'Tat ca vang',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    onPressed: () => _markAll(AttendanceStatus.absent),
                  ),
                ),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.green, label: 'Co mat'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.red, label: 'Vang'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.orange, label: 'Tre'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.blue, label: 'Phep'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attendance list
          Expanded(
            child: BlocSelector<TeacherClassDetailCubit,
                TeacherClassDetailState, _AttendanceListData>(
              selector: (state) {
                if (state is TeacherClassDetailLoaded) {
                  return _AttendanceListData(
                    attendances: state.attendances,
                    isLoading: state.isLoadingAttendances,
                  );
                }
                return const _AttendanceListData(
                  attendances: [],
                  isLoading: true,
                );
              },
              builder: (context, data) {
                if (data.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (data.attendances.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data.attendances.length,
                  itemBuilder: (context, index) {
                    final attendance = data.attendances[index];
                    return _AttendanceItem(
                      attendance: attendance,
                      onStatusChanged: (status) {
                        context.read<TeacherClassDetailCubit>().updateAttendance(
                              widget.classId,
                              attendance.studentId ?? '',
                              status,
                            );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Stats summary
          BlocSelector<TeacherClassDetailCubit, TeacherClassDetailState,
              _AttendanceStats>(
            selector: (state) {
              if (state is TeacherClassDetailLoaded) {
                final attendances = state.attendances;
                return _AttendanceStats(
                  total: attendances.length,
                  present: attendances.where((a) => a.isPresent).length,
                  absent: attendances.where((a) => a.isAbsent).length,
                  late: attendances.where((a) => a.isLate).length,
                  excused: attendances.where((a) => a.isExcused).length,
                );
              }
              return const _AttendanceStats(
                total: 0,
                present: 0,
                absent: 0,
                late: 0,
                excused: 0,
              );
            },
            builder: (context, stats) {
              if (stats.total == 0) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(color: cs.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBadge(
                      label: 'Co mat',
                      value: stats.present,
                      color: Colors.green,
                    ),
                    _StatBadge(
                      label: 'Vang',
                      value: stats.absent,
                      color: Colors.red,
                    ),
                    _StatBadge(
                      label: 'Tre',
                      value: stats.late,
                      color: Colors.orange,
                    ),
                    _StatBadge(
                      label: 'Phep',
                      value: stats.excused,
                      color: Colors.blue,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
          Icon(Icons.people_outline, size: 64, color: cs.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Khong co du lieu diem danh',
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Hay chon ngay khac hoac tai lai trang',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loadAttendance,
            child: const Text('Tai lai'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Chu Nhat',
      'Thu Hai',
      'Thu Ba',
      'Thu Tu',
      'Thu Nam',
      'Thu Sau',
      'Thu Bay',
    ];
    final weekday = weekdays[date.weekday % 7];
    return '$weekday, ${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      _loadAttendance();
    }
  }

  void _markAll(AttendanceStatus status) {
    final cubit = context.read<TeacherClassDetailCubit>();
    final state = cubit.state;
    if (state is! TeacherClassDetailLoaded) return;

    for (final attendance in state.attendances) {
      cubit.updateAttendance(
        widget.classId,
        attendance.studentId ?? '',
        status.name,
      );
    }
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    try {
      await context
          .read<TeacherClassDetailCubit>()
          .saveAttendances(widget.classId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Luu diem danh thanh cong'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loi: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _AttendanceListData {
  const _AttendanceListData({
    required this.attendances,
    required this.isLoading,
  });

  final List<AttendanceModel> attendances;
  final bool isLoading;
}

class _AttendanceStats {
  const _AttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  });

  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AttendanceItem extends StatelessWidget {
  const _AttendanceItem({
    required this.attendance,
    required this.onStatusChanged,
  });

  final AttendanceModel attendance;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: cs.surfaceContainerHighest,
              backgroundImage: attendance.avatarUrl != null
                  ? NetworkImage(attendance.avatarUrl!)
                  : null,
              child: attendance.avatarUrl == null
                  ? Text(
                      attendance.displayName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    attendance.displayCode,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),

            // Status buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusButton(
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isSelected: attendance.isPresent,
                  onTap: () => onStatusChanged('present'),
                ),
                _StatusButton(
                  icon: Icons.cancel,
                  color: Colors.red,
                  isSelected: attendance.isAbsent,
                  onTap: () => onStatusChanged('absent'),
                ),
                _StatusButton(
                  icon: Icons.schedule,
                  color: Colors.orange,
                  isSelected: attendance.isLate,
                  onTap: () => onStatusChanged('late'),
                ),
                _StatusButton(
                  icon: Icons.event_available,
                  color: Colors.blue,
                  isSelected: attendance.isExcused,
                  onTap: () => onStatusChanged('excused'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? color : Colors.grey.withValues(alpha: 0.5),
          size: 24,
        ),
      ),
    );
  }
}
