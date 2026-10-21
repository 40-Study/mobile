import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/course_rules.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

import 'course_form_widgets.dart';
import 'course_tag_picker.dart';

class CourseMetadataEditor extends StatefulWidget {
  const CourseMetadataEditor({super.key, required this.api, this.course});
  final TeacherApi api;
  final Map<String, dynamic>? course;
  @override
  State<CourseMetadataEditor> createState() => _CourseMetadataEditorState();
}

class _CourseMetadataEditorState extends State<CourseMetadataEditor> {
  final Map<String, TextEditingController> _inputs = {};
  late List<Map<String, dynamic>> _tags = teacherList(widget.course?['tags']);
  late bool _free = widget.course?['is_free'] == true;
  late bool _sequential = widget.course?['sequential'] == true;
  late String _level = widget.course?['level']?.toString() ?? 'beginner';
  late String? _category = widget.course?['category_id']?.toString();
  late Future<dynamic> _categories = widget.api.get('/categories');
  TextEditingController _field(String key, {String fallback = ''}) =>
      _inputs.putIfAbsent(key, () {
        final value = widget.course?[key];
        return TextEditingController(
          text: value is List
              ? value.join('\n')
              : value?.toString() ?? fallback,
        );
      });
  @override
  void dispose() {
    for (final input in _inputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  String? _url(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    final uri = Uri.tryParse(value!.trim());
    return uri != null &&
            ['http', 'https'].contains(uri.scheme) &&
            uri.host.isNotEmpty
        ? null
        : 'Nhập URL http/https hợp lệ';
  }

  Future<void> _pickDiscountEnd(FormFieldState<String> field) async {
    final current =
        DateTime.tryParse(_field('discount_expires_at').text)?.toLocal() ??
        DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc().toIso8601String();
    setState(() => _field('discount_expires_at').text = value);
    field.didChange(value);
  }

  Future<dynamic> _save() async {
    final payload = <String, dynamic>{
      for (final key in [
        'title',
        'short_description',
        'description',
        'thumbnail_url',
        'preview_video_url',
        'language',
      ])
        key: _field(key).text.trim(),
      for (final key in ['requirements', 'objectives', 'target_audience'])
        key: _field(key).text
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      'tag_ids': _tags.map((tag) => tag['id']).toList(),
      'level': _level, 'is_free': _free,
      'price': _free ? 0 : double.parse(_field('price').text.trim()),
      'discount_price': _free || _field('discount_price').text.trim().isEmpty
          ? null
          : double.parse(_field('discount_price').text.trim()),
      if (_category != null) 'category_id': _category,
      if (_field('discount_expires_at').text.trim().isNotEmpty)
        'discount_expires_at': DateTime.parse(
          _field('discount_expires_at').text.trim(),
        ).toUtc().toIso8601String(),
      // The backend only accepts progression settings on UpdateCourseDTO.
      if (widget.course != null) 'sequential': _sequential,
      if (widget.course != null)
        'min_video_pct': int.parse(
          _field('min_video_pct', fallback: '80').text,
        ),
    };
    if (widget.course == null) {
      return widget.api.post('/courses/', data: payload);
    }
    return widget.api.put('/courses/${widget.course!['id']}', data: payload);
  }

  @override
  Widget build(BuildContext context) => CourseFormPage(
    title: widget.course == null
        ? 'Tạo khóa học cá nhân'
        : 'Sửa thông tin khóa học',
    onSave: _save,
    fields: [
      const TeacherSectionTitle(title: 'Nội dung'),
      courseField(
        _field('title'),
        'Tên khóa học',
        validator: (v) => (v ?? '').trim().length < 2 || v!.length > 255
            ? 'Tên từ 2 đến 255 ký tự'
            : null,
      ),
      courseField(_field('short_description'), 'Mô tả ngắn', lines: 2),
      courseField(
        _field('description'),
        'Mô tả đầy đủ',
        required: true,
        lines: 5,
      ),
      for (final item in {
        'objectives': 'Mục tiêu',
        'requirements': 'Yêu cầu',
        'target_audience': 'Đối tượng',
      }.entries)
        courseField(
          _field(item.key),
          item.value,
          lines: 2,
          helper: 'Mỗi mục trên một dòng',
        ),
      DropdownButtonFormField<String>(
        initialValue: _level,
        decoration: const InputDecoration(labelText: 'Cấp độ'),
        items: const [
          DropdownMenuItem(value: 'beginner', child: Text('Cơ bản')),
          DropdownMenuItem(value: 'intermediate', child: Text('Trung cấp')),
          DropdownMenuItem(value: 'advanced', child: Text('Nâng cao')),
          DropdownMenuItem(value: 'all_levels', child: Text('Mọi cấp độ')),
        ],
        onChanged: (v) => setState(() => _level = v!),
      ),
      courseField(
        _field('language', fallback: 'vi'),
        'Ngôn ngữ',
        required: true,
        validator: (v) => (v ?? '').isEmpty || v!.length > 10
            ? 'Mã ngôn ngữ từ 1 đến 10 ký tự'
            : null,
      ),
      FutureBuilder<dynamic>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return TeacherErrorView(
              error: snapshot.error!,
              onRetry: () =>
                  setState(() => _categories = widget.api.get('/categories')),
            );
          }
          final values = teacherList(snapshot.data, keys: const ['categories']);
          return DropdownButtonFormField<String>(
            initialValue: values.any((c) => c['id'] == _category)
                ? _category
                : null,
            decoration: const InputDecoration(labelText: 'Danh mục (tùy chọn)'),
            items: values
                .map(
                  (c) => DropdownMenuItem(
                    value: '${c['id']}',
                    child: Text('${c['name']}'),
                  ),
                )
                .toList(),
            onChanged: snapshot.hasData
                ? (v) => setState(() => _category = v)
                : null,
          );
        },
      ),
      FormField<List<Map<String, dynamic>>>(
        initialValue: _tags,
        builder: (field) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final tag in _tags)
                  Chip(
                    label: Text('${tag['name']}'),
                    onDeleted: () {
                      setState(() => _tags.remove(tag));
                      field.didChange(_tags);
                    },
                  ),
              ],
            ),
            OutlinedButton(
              onPressed: () async {
                final tags = await Navigator.push<List<Map<String, dynamic>>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CourseTagPicker(api: widget.api, initial: _tags),
                  ),
                );
                if (tags != null && mounted) {
                  setState(() => _tags = tags);
                  field.didChange(tags);
                }
              },
              child: const Text('Chọn tag khóa học'),
            ),
          ],
        ),
      ),
      const TeacherSectionTitle(title: 'Hình ảnh và giới thiệu'),
      courseField(
        _field('thumbnail_url'),
        'URL ảnh bìa',
        validator: _url,
        keyboard: TextInputType.url,
      ),
      courseField(
        _field('preview_video_url'),
        'URL video giới thiệu',
        validator: _url,
        keyboard: TextInputType.url,
      ),
      const TeacherSectionTitle(title: 'Giá'),
      courseSwitch('Khóa miễn phí', _free, (v) => setState(() => _free = v)),
      if (!_free) ...[
        courseField(
          _field('price', fallback: '0'),
          'Giá gốc (VND)',
          keyboard: TextInputType.number,
          validator: (v) => teacherCoursePriceError(v ?? ''),
        ),
        courseField(
          _field('discount_price'),
          'Giá giảm (tùy chọn)',
          keyboard: TextInputType.number,
          helper: 'Để trống để gỡ giá giảm hiện tại',
          validator: (v) => (v ?? '').isEmpty
              ? null
              : teacherCoursePriceError(
                  v!,
                  below: double.tryParse(_field('price').text) ?? 0,
                ),
        ),
        FormField<String>(
          initialValue: _field('discount_expires_at').text,
          builder: (field) => InkWell(
            onTap: () => _pickDiscountEnd(field),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Hạn giảm giá (tùy chọn)',
                helperText: 'Theo giờ thiết bị. Hạn được gỡ khi bỏ giá giảm.',
                helperMaxLines: 3,
                suffixIcon: Icon(Icons.calendar_month_outlined),
              ),
              child: Text(
                _field('discount_expires_at').text.isEmpty
                    ? 'Chọn ngày và giờ'
                    : teacherDisplayDate(_field('discount_expires_at').text),
              ),
            ),
          ),
        ),
      ],
      if (widget.course != null) ...[
        const TeacherSectionTitle(title: 'Cách học'),
        courseSwitch(
          'Học theo thứ tự',
          _sequential,
          (v) => setState(() => _sequential = v),
          subtitle: 'Học viên hoàn thành bài trước khi mở bài tiếp theo.',
        ),
        courseField(
          _field('min_video_pct', fallback: '80'),
          'Tỷ lệ xem video tối thiểu (%)',
          keyboard: TextInputType.number,
          validator: (v) {
            final n = int.tryParse(v ?? '');
            return n != null && n >= 1 && n <= 100
                ? null
                : 'Nhập số từ 1 đến 100';
          },
        ),
      ],
      const Text(
        'Lưu thông tin không gửi duyệt. Bạn có thể soạn giáo trình rồi gửi duyệt từ trang quản lý khóa.',
      ),
    ],
  );
}
