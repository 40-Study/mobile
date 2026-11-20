import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/teacher_api.dart';

/// Keeps entered values and server errors visible until a successful write.
Future<bool> teacherToolForm(
  BuildContext context, {
  required String title,
  required Map<String, String> fields,
  required Future<void> Function(Map<String, String>) save,
  String? Function(Map<String, String>)? validate,
  String action = 'Lưu',
  Map<String, Map<String, String>> choices = const {},
  Set<String> dateFields = const {},
}) async {
  final controllers = fields.map(
    (key, value) => MapEntry(key, TextEditingController(text: value)),
  );
  final dates = <String, DateTime>{};
  for (final key in dateFields) {
    final date = DateTime.tryParse(fields[key] ?? '');
    if (date != null) {
      dates[key] = date;
      controllers[key]!.text = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(date.toLocal());
    }
  }
  String? error;
  var busy = false;
  final route = DialogRoute<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => PopScope(
        canPop: !busy,
        child: AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final field in controllers.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: choices.containsKey(field.key)
                          ? DropdownButtonFormField<String>(
                              initialValue: field.value.text,
                              decoration: InputDecoration(labelText: field.key),
                              items: choices[field.key]!.entries
                                  .map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: busy
                                  ? null
                                  : (value) => field.value.text = value ?? '',
                            )
                          : TextField(
                              controller: field.value,
                              enabled: !busy,
                              readOnly: dateFields.contains(field.key),
                              onTap: !dateFields.contains(field.key)
                                  ? null
                                  : () async {
                                      final initial =
                                          dates[field.key]?.toLocal() ??
                                          DateTime.now();
                                      final day = await showDatePicker(
                                        context: context,
                                        initialDate: initial,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                      );
                                      if (day == null || !context.mounted) {
                                        return;
                                      }
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                          initial,
                                        ),
                                      );
                                      if (time == null || !context.mounted) {
                                        return;
                                      }
                                      final date = DateTime(
                                        day.year,
                                        day.month,
                                        day.day,
                                        time.hour,
                                        time.minute,
                                      );
                                      setState(() {
                                        dates[field.key] = date;
                                        field.value.text = DateFormat(
                                          'dd/MM/yyyy HH:mm',
                                        ).format(date);
                                      });
                                    },
                              maxLines:
                                  field.key.contains('Nội dung') ||
                                      field.key.contains('Code')
                                  ? 4
                                  : 1,
                              decoration: InputDecoration(
                                labelText: field.key,
                                suffixIcon: dateFields.contains(field.key)
                                    ? IconButton(
                                        tooltip: 'Xóa thời điểm',
                                        icon: const Icon(Icons.clear),
                                        onPressed: busy
                                            ? null
                                            : () => setState(() {
                                                dates.remove(field.key);
                                                field.value.clear();
                                              }),
                                      )
                                    : null,
                              ),
                            ),
                    ),
                  if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy
                  ? null
                  : () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      final values = controllers.map(
                        (key, c) => MapEntry(
                          key,
                          dateFields.contains(key)
                              ? dates[key]?.toUtc().toIso8601String() ?? ''
                              : c.text.trim(),
                        ),
                      );
                      final invalid = validate?.call(values);
                      if (invalid != null) {
                        setState(() => error = invalid);
                        return;
                      }
                      setState(() {
                        busy = true;
                        error = null;
                      });
                      try {
                        await save(values);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            busy = false;
                            error = e is StateError
                                ? '${e.message}'
                                : teacherErrorMessage(e);
                          });
                        }
                      }
                    },
              child: Text(busy ? 'Đang lưu…' : action),
            ),
          ],
        ),
      ),
    ),
  );
  final result = await Navigator.of(context, rootNavigator: true).push(route);
  await route.completed;
  for (final c in controllers.values) {
    c.dispose();
  }
  return result == true;
}

Future<bool> teacherToolConfirm(BuildContext context, String message) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Quay lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    ) ??
    false;

Map<String, dynamic> toolPayload(dynamic raw) {
  if (raw is! Map) return {};
  final data = raw['data'];
  return Map<String, dynamic>.from(data is Map ? data : raw);
}

Future<List<Map<String, dynamic>>> toolPages(
  TeacherApi api,
  String path, {
  List<String> keys = const [],
  Map<String, dynamic> query = const {},
}) async {
  final rows = <Map<String, dynamic>>[];
  for (var page = 1; ; page++) {
    final raw = await api.get(
      path,
      query: {...query, 'page': page, 'page_size': 100},
    );
    final payload = toolPayload(raw);
    final items = teacherList(raw, keys: keys).map(teacherMap).toList();
    rows.addAll(items);
    final total = num.tryParse('${payload['total'] ?? payload['total_count']}');
    if (items.isEmpty || (total == null || rows.length >= total)) {
      break;
    }
  }
  return rows;
}
