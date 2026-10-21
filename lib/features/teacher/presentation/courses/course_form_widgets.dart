import 'package:flutter/material.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/theme/theme.dart';

/// A saved mutation closes the editor; a failed mutation keeps all entered data.
class CourseFormPage extends StatefulWidget {
  const CourseFormPage({
    super.key,
    required this.title,
    required this.fields,
    required this.onSave,
    this.submitLabel = 'Lưu',
    this.onChanged,
  });
  final String title;
  final List<Widget> fields;
  final Future<dynamic> Function() onSave;
  final String submitLabel;
  final VoidCallback? onChanged;
  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  bool _dirty = false;
  bool _canPop = false;
  Object? _error;
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.onSave();
      if (!mounted) return;
      setState(() {
        _dirty = false;
        _canPop = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, result ?? true);
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _busy = false;
        });
      }
    }
  }

  Future<void> _leave() async {
    if (_busy) return;
    final leave =
        !_dirty ||
        await courseConfirm(
          context,
          'Bỏ thay đổi?',
          'Các nội dung chưa lưu sẽ bị mất.',
          confirm: 'Bỏ thay đổi',
        );
    if (leave && mounted) {
      setState(() => _canPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canPop || (!_dirty && !_busy),
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _leave();
    },
    child: Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _form,
        onChanged: () {
          if (!_dirty) setState(() => _dirty = true);
          widget.onChanged?.call();
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...widget.fields.map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: field,
                          ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.lg,
                            ),
                            child: Text(
                              teacherErrorMessage(_error!),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                  AppSpacing.screenPadding,
                  AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_dirty && !_busy)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Text(
                              'Có thay đổi chưa lưu',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        FilledButton(
                          onPressed: _busy ? null : _save,
                          child: Text(_busy ? 'Đang lưu…' : widget.submitLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> courseConfirm(
  BuildContext context,
  String title,
  String body, {
  String confirm = 'Xác nhận',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ??
    false;

TextFormField courseField(
  TextEditingController controller,
  String label, {
  bool required = false,
  int lines = 1,
  TextInputType? keyboard,
  String? Function(String?)? validator,
  String? helper,
}) => TextFormField(
  controller: controller,
  minLines: lines,
  maxLines: lines == 1 ? 1 : lines + 4,
  keyboardType: keyboard,
  decoration: InputDecoration(
    labelText: label,
    helperText: helper,
    border: const OutlineInputBorder(),
  ),
  validator:
      validator ??
      (value) => required && (value ?? '').trim().isEmpty
          ? 'Vui lòng nhập $label'
          : null,
);

Widget courseSwitch(
  String title,
  bool value,
  ValueChanged<bool> onChanged, {
  String? subtitle,
}) => FormField<bool>(
  initialValue: value,
  builder: (field) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle),
    value: value,
    onChanged: (next) {
      field.didChange(next);
      onChanged(next);
    },
  ),
);
