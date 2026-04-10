import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/data/repository/teacher_repository.dart';
import 'package:study/widgets/simple_gradient_background.dart';

class TeacherCreateClassScreen extends StatefulWidget {
  const TeacherCreateClassScreen({super.key, this.classData});

  /// If provided, we're editing an existing class.
  final Map<String, dynamic>? classData;

  @override
  State<TeacherCreateClassScreen> createState() =>
      _TeacherCreateClassScreenState();
}

class _TeacherCreateClassScreenState extends State<TeacherCreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxStudentsController = TextEditingController(text: '30');

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedCourseId = '';
  bool _isLoading = false;

  bool get _isEditing => widget.classData != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final data = widget.classData!;
      _nameController.text = (data['name'] as String?) ?? '';
      _descriptionController.text = (data['description'] as String?) ?? '';
      _maxStudentsController.text =
          (data['max_students'] as int? ?? 30).toString();
      _selectedCourseId = (data['course_id'] as String?) ?? '';

      final startDateStr = data['start_date'] as String?;
      if (startDateStr != null) {
        _startDate = DateTime.tryParse(startDateStr);
      }
      final endDateStr = data['end_date'] as String?;
      if (endDateStr != null) {
        _endDate = DateTime.tryParse(endDateStr);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SimpleGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
        title: Text(_isEditing ? 'Chinh sua lop hoc' : 'Tao lop hoc moi'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveClass,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Luu'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Class name
            _buildSectionTitle(context, 'Thong tin co ban'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ten lop hoc *',
                hintText: 'VD: Lop React Native - Khoa 1',
                prefixIcon: const Icon(Icons.class_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui long nhap ten lop hoc';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mo ta',
                hintText: 'Mo ta ngan gon ve lop hoc',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Course selection (if applicable)
            _buildSectionTitle(context, 'Khoa hoc'),
            const SizedBox(height: 12),
            _buildCourseDropdown(context),
            const SizedBox(height: 24),

            // Class capacity
            _buildSectionTitle(context, 'Si so'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _maxStudentsController,
              decoration: InputDecoration(
                labelText: 'So luong hoc vien toi da *',
                prefixIcon: const Icon(Icons.people_outline),
                suffixText: 'hoc vien',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui long nhap so luong hoc vien';
                }
                final number = int.tryParse(value);
                if (number == null || number < 1) {
                  return 'So luong phai lon hon 0';
                }
                if (number > 500) {
                  return 'So luong khong duoc vuot qua 500';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Date range
            _buildSectionTitle(context, 'Thoi gian'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Ngay bat dau',
                    value: _startDate,
                    onChanged: (date) {
                      setState(() => _startDate = date);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DatePickerField(
                    label: 'Ngay ket thuc',
                    value: _endDate,
                    onChanged: (date) {
                      setState(() => _endDate = date);
                    },
                    firstDate: _startDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Schedule section (simplified)
            _buildSectionTitle(context, 'Lich hoc'),
            const SizedBox(height: 12),
            _buildScheduleHint(context),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _isLoading ? null : _saveClass,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditing ? 'Cap nhat lop hoc' : 'Tao lop hoc',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildCourseDropdown(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // In a real app, you would fetch courses from the repository
    final courses = [
      {'id': '', 'name': 'Khong chon khoa hoc'},
      {'id': 'c1', 'name': 'React Native Co Ban'},
      {'id': 'c2', 'name': 'UI/UX Design Masterclass'},
      {'id': 'c3', 'name': 'Flutter Development'},
    ];

    return DropdownButtonFormField<String>(
      value: _selectedCourseId,
      decoration: InputDecoration(
        labelText: 'Khoa hoc lien ket',
        prefixIcon: const Icon(Icons.school_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      items: courses
          .map((course) => DropdownMenuItem(
                value: course['id'] as String,
                child: Text(course['name'] as String),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedCourseId = value ?? '');
      },
    );
  }

  Widget _buildScheduleHint(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ban co the thiet lap lich hoc chi tiet sau khi tao lop hoc.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'course_id': _selectedCourseId.isEmpty ? null : _selectedCourseId,
        'max_students': int.parse(_maxStudentsController.text),
        'start_date': _startDate?.toIso8601String().split('T').first,
        'end_date': _endDate?.toIso8601String().split('T').first,
        'status': 'active',
      };

      final repository = context.read<TeacherRepository>();

      if (_isEditing) {
        final classId = widget.classData!['id'] as String;
        await repository.updateClass(classId, data);
      } else {
        await repository.createClass(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Cap nhat lop hoc thanh cong'
                  : 'Tao lop hoc thanh cong',
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        Navigator.pop(context, true);
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
        setState(() => _isLoading = false);
      }
    }
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : 'Chon ngay',
          style: TextStyle(
            color: value != null
                ? cs.onSurface
                : cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
