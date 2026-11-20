import 'package:flutter/material.dart';

class TeacherArticlePreview extends StatelessWidget {
  const TeacherArticlePreview({required this.body});
  final String body;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Xem trước văn bản · định dạng HTML được giữ khi lưu',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      const SizedBox(height: 12),
      SelectableText(
        body
            .replaceAll(
              RegExp(r'<(br\s*/?|/p|/h[1-6]|/li)>', caseSensitive: false),
              '\n',
            )
            .replaceAll(RegExp('<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&amp;', '&'),
      ),
    ],
  );
}
