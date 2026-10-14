import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';

class HomeworkSubmissionCard extends StatelessWidget {
  const HomeworkSubmissionCard({super.key, required this.detail});

  final ParentHomeworkDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BÀI NỘP CỦA CON',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              if (detail.submittedAtText != null)
                Text(
                  detail.submittedAtText!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
          if (detail.studentSubmissionNote != null) ...[
            const SizedBox(height: 10),
            Text(
              detail.studentSubmissionNote!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (detail.submittedFiles.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...detail.submittedFiles.map((file) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.task_rounded,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
