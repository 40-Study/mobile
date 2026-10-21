import 'package:flutter/material.dart';

class TeacherGradeSaveBar extends StatelessWidget {
  const TeacherGradeSaveBar({
    super.key,
    required this.busy,
    required this.uncertain,
    required this.hasDrafts,
    required this.changedCount,
    required this.onSave,
  });
  final bool busy, uncertain, hasDrafts;
  final int changedCount;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: busy || uncertain || !hasDrafts ? null : onSave,
          child: Text(busy ? 'Đang lưu…' : 'Lưu $changedCount điểm mới'),
        ),
      ),
    ),
  );
}
