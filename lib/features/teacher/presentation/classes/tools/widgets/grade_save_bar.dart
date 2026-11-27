import 'package:flutter/material.dart';

class TeacherGradeSaveBar extends StatelessWidget {
  const TeacherGradeSaveBar({
    super.key,
    required this.busy,
    required this.uncertain,
    required this.hasDrafts,
    required this.changedCount,
    required this.draftCount,
    required this.onSave,
    required this.onCheck,
  });
  final bool busy, uncertain, hasDrafts;
  final int changedCount, draftCount;
  final VoidCallback? onSave;
  final VoidCallback onCheck;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$draftCount điểm nháp',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          if (uncertain)
            OutlinedButton(
              onPressed: busy ? null : onCheck,
              child: const Text('Kiểm tra điểm đã lưu'),
            )
          else
            FilledButton(
              onPressed: busy || !hasDrafts ? null : onSave,
              child: Text(
                busy
                    ? 'Đang xử lý…'
                    : changedCount == 0
                    ? 'Lưu điểm'
                    : 'Lưu $changedCount điểm',
              ),
            ),
        ],
      ),
    ),
  );
}
