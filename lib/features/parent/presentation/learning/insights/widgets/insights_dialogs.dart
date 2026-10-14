import 'package:study/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/parent_learning_insights_model.dart';

void showInsightsTeacherContact(
  BuildContext context,
  ParentLearningInsightsModel insights,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      insights.teacherName.substring(
                        insights.teacherName.lastIndexOf(' ') + 1,
                        insights.teacherName.lastIndexOf(' ') + 2,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${insights.teacherName} '
                        '(${insights.teacherSubject})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Giáo viên phụ trách môn học',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Bạn muốn trao đổi cùng giáo viên về vấn đề:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.assignment_outlined,
                  color: Color(0xFF2563EB),
                ),
                title: const Text('Xin bài tập củng cố cá nhân hoá'),
                subtitle: const Text(
                  'Theo khuyến nghị phân tích sư phạm tuần 12',
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã gửi yêu cầu nhận 3 bài tập củng cố tới '
                        '${insights.teacherName}.',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF16A34A),
                ),
                title: const Text('Hẹn trao đổi trực tiếp 15 phút'),
                subtitle: const Text('Qua Google Meet vào cuối tuần'),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã tạo lịch hẹn trao đổi với '
                        '${insights.teacherName}.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showInsightsEvidence(
  BuildContext context,
  ParentLearningInsightsModel insights,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bằng chứng định lượng (Evidence)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Bài tập về nhà Buổi 8 — Rút gọn phân thức đại số',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Kết quả: Đúng 3/5 bài (Sai câu 2 và 4 do nhầm dấu)',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '2. Mini-quiz kiểm tra nhanh đầu giờ Buổi 8',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Kết quả: 3/5 điểm • Thời gian làm bài: 8p 15s',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
