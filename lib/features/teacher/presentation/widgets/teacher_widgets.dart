import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/widgets/section_header.dart';

Future<T?> teacherPush<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => screen));

String teacherDisplayDate(dynamic value) {
  final date = DateTime.tryParse('$value')?.toLocal();
  return date == null ? '—' : DateFormat('dd/MM/yyyy · HH:mm').format(date);
}

class TeacherSectionTitle extends StatelessWidget {
  const TeacherSectionTitle({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Row(
      children: [
        Expanded(child: SectionHeader(title: title)),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

class TeacherErrorView extends StatelessWidget {
  const TeacherErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });
  final Object error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(teacherErrorMessage(error), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}

class TeacherAsyncView<T> extends StatefulWidget {
  const TeacherAsyncView({
    super.key,
    required this.load,
    required this.builder,
    this.refreshToken,
    this.loading,
  });
  final Future<T> Function() load;
  final Widget Function(BuildContext, T) builder;

  /// Explicit invalidation; a new closure alone never repeats a request.
  final Object? refreshToken;
  final Widget? loading;
  @override
  State<TeacherAsyncView<T>> createState() => _TeacherAsyncViewState<T>();
}

class _TeacherAsyncViewState<T> extends State<TeacherAsyncView<T>> {
  late Future<T> _future;
  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  @override
  void didUpdateWidget(covariant TeacherAsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _future = widget.load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done &&
          !snapshot.hasData) {
        return widget.loading ??
            const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return TeacherErrorView(
          error: snapshot.error!,
          onRetry: () => setState(() {
            _future = widget.load();
          }),
        );
      }
      final content = widget.builder(context, snapshot.data as T);
      if (widget.refreshToken != null) {
        return Stack(
          children: [
            content,
            if (snapshot.connectionState != ConnectionState.done)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(),
              ),
          ],
        );
      }
      return content;
    },
  );
}

class TeacherListPlaceholder extends StatelessWidget {
  const TeacherListPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Đang tải nội dung',
    child: ExcludeSemantics(
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionallySizedBox(
              widthFactor: .72,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const SizedBox(height: 18),
              ),
            ),
            const SizedBox(height: 12),
            FractionallySizedBox(
              widthFactor: .45,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: const SizedBox(height: 12),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
