import 'package:flutter/material.dart';
import 'package:study/features/account/presentation/shared_account_content.dart';
import 'package:study/features/teacher/data/teacher_api.dart';

/// Compatibility wrapper for existing navigation and screen fixtures.
/// Account content is shared with Student/Parent and never calls Teacher APIs.
class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({
    super.key,
    this.api,
    this.workplaceLabel,
    this.onWorkplace,
    this.onAdvanced,
  });
  final TeacherApi? api;
  final String? workplaceLabel;
  final VoidCallback? onWorkplace;
  final VoidCallback? onAdvanced;

  @override
  Widget build(BuildContext context) => const SharedAccountContent();
}
