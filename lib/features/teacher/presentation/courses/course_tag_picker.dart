import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

class CourseTagPicker extends StatefulWidget {
  const CourseTagPicker({super.key, required this.api, required this.initial});
  final TeacherApi api;
  final List<Map<String, dynamic>> initial;
  @override
  State<CourseTagPicker> createState() => _CourseTagPickerState();
}

class _CourseTagPickerState extends State<CourseTagPicker> {
  late final _selected = {
    for (final tag in widget.initial) '${tag['id']}': tag,
  };
  final _search = TextEditingController();
  int _page = 1;
  int _revision = 0;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chọn tag khóa học'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _selected.values.toList()),
          child: const Text('Áp dụng'),
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Tìm tag',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => setState(() {
              _page = 1;
              _revision++;
            }),
          ),
        ),
        Text('Đã chọn ${_selected.length} tag'),
        Expanded(
          child: TeacherAsyncView<dynamic>(
            key: ValueKey(_revision),
            load: () => widget.api.get(
              '/tags/',
              query: {
                'page': _page,
                'page_size': 20,
                'keyword': _search.text.trim(),
              },
            ),
            builder: (context, raw) {
              final tags = teacherList(raw, keys: const ['tags']);
              final total =
                  int.tryParse('${teacherMap(raw)['total']}') ?? tags.length;
              return ListView(
                children: [
                  if (tags.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Không tìm thấy tag phù hợp.'),
                    ),
                  for (final tag in tags)
                    CheckboxListTile(
                      title: Text('${tag['name']}'),
                      value: _selected.containsKey('${tag['id']}'),
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          _selected['${tag['id']}'] = tag;
                        } else {
                          _selected.remove('${tag['id']}');
                        }
                      }),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Trang trước',
                        onPressed: _page > 1
                            ? () => setState(() {
                                _page--;
                                _revision++;
                              })
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('Trang $_page'),
                      IconButton(
                        tooltip: 'Trang sau',
                        onPressed: _page * 20 < total
                            ? () => setState(() {
                                _page++;
                                _revision++;
                              })
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}
