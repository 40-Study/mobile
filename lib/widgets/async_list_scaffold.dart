import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/empty_state.dart';

/// Scaffold cho các màn hình list với async loading
/// Handles loading/error/empty/data states
class AsyncListScaffold<T> extends StatelessWidget {
  const AsyncListScaffold({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.itemBuilder,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Không có dữ liệu',
    this.emptyMessage = '',
  });

  final String title;
  final List<T> items;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext, T) itemBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          title,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (error != null) {
      return Center(
        child: EmptyState(
          icon: Icons.error_outline,
          title: 'Lỗi',
          message: error!,
          actionLabel: 'Thử lại',
          onAction: onRefresh,
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: EmptyState(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (_, __) => AppSpacing.vGap12,
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }
}
