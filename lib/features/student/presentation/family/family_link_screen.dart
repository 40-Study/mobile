import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/family_link/family_link_cubit.dart';
import 'package:study/features/student/bloc/family_link/family_link_state.dart';
import 'package:study/features/student/data/models/family_link_model.dart';
import 'package:study/features/student/repository/student_repository.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/cached_avatar.dart';

class FamilyLinkScreen extends StatelessWidget {
  const FamilyLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FamilyLinkCubit(context.read<StudentRepository>())..load(),
      child: const _FamilyLinkContent(),
    );
  }
}

class _FamilyLinkContent extends StatelessWidget {
  const _FamilyLinkContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liên kết gia đình')),
      body: BlocBuilder<FamilyLinkCubit, FamilyLinkState>(
        builder: (context, state) {
          return switch (state) {
            FamilyLinkInitial() || FamilyLinkLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            FamilyLinkFailure(:final message) => _ErrorView(message: message),
            FamilyLinkSuccess() => _SuccessView(state: state),
          };
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          AppSpacing.vGap16,
          FilledButton(
            onPressed: () => context.read<FamilyLinkCubit>().refresh(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.state});
  final FamilyLinkSuccess state;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final hasPending = state.pendingRequests.isNotEmpty;
    final hasLinked = state.linkedParents.isNotEmpty;

    if (!hasPending && !hasLinked) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FamilyLinkCubit>().refresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (hasPending) ...[
            Text(
              'Yêu cầu liên kết',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap8,
            ...state.pendingRequests.map(
              (r) => _PendingRequestCard(
                request: r,
                isResponding: state.isResponding,
              ),
            ),
            AppSpacing.vGap24,
          ],
          if (hasLinked) ...[
            Text(
              'Phụ huynh đã liên kết',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap8,
            ...state.linkedParents.map(
              (p) => _LinkedParentCard(
                parent: p,
                isResponding: state.isResponding,
              ),
            ),
          ],
          if (!hasLinked && hasPending)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                'Chưa có phụ huynh nào liên kết với bạn.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.family_restroom_rounded,
              size: 64,
              color: cs.onSurfaceVariant,
            ),
            AppSpacing.vGap16,
            Text(
              'Chưa có liên kết',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vGap8,
            Text(
              'Phụ huynh có thể gửi yêu cầu liên kết từ ứng dụng của họ để theo dõi tiến độ học tập của bạn.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.isResponding,
  });

  final ParentLinkRequestModel request;
  final bool isResponding;

  String _relationshipLabel(String relationship) {
    return switch (relationship) {
      'parent' => 'Phụ huynh',
      'guardian' => 'Người giám hộ',
      'grandparent' => 'Ông/Bà',
      _ => 'Người thân',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final parent = request.parent;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CachedAvatar(
                  url: parent?.avatarUrl,
                  name: parent?.fullName ?? parent?.username ?? '?',
                  radius: 24,
                ),
                AppSpacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parent?.fullName ?? parent?.username ?? 'Phụ huynh',
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _relationshipLabel(request.relationship),
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.message != null && request.message!.isNotEmpty) ...[
              AppSpacing.vGap12,
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  request.message!,
                  style: tt.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            AppSpacing.vGap12,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: isResponding
                      ? null
                      : () => _respond(context, accept: false),
                  child: const Text('Từ chối'),
                ),
                AppSpacing.hGap8,
                FilledButton(
                  onPressed: isResponding
                      ? null
                      : () => _respond(context, accept: true),
                  child: const Text('Chấp nhận'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respond(BuildContext context, {required bool accept}) async {
    final success = await context
        .read<FamilyLinkCubit>()
        .respondToRequest(request.id, accept: accept);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (accept ? 'Đã chấp nhận liên kết' : 'Đã từ chối liên kết')
              : 'Không thể xử lý yêu cầu',
        ),
        backgroundColor: success ? Colors.green : null,
      ),
    );
  }
}

class _LinkedParentCard extends StatelessWidget {
  const _LinkedParentCard({
    required this.parent,
    required this.isResponding,
  });

  final LinkedParentModel parent;
  final bool isResponding;

  String _relationshipLabel(String relationship) {
    return switch (relationship) {
      'parent' => 'Phụ huynh',
      'guardian' => 'Người giám hộ',
      'grandparent' => 'Ông/Bà',
      _ => 'Người thân',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CachedAvatar(
          url: parent.avatarUrl,
          name: parent.fullName ?? parent.username,
          radius: 24,
        ),
        title: Text(
          parent.fullName ?? parent.username,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _relationshipLabel(parent.relationship),
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: IconButton(
          icon: Icon(Icons.link_off, color: cs.error),
          onPressed: isResponding ? null : () => _confirmUnlink(context),
          tooltip: 'Hủy liên kết',
        ),
      ),
    );
  }

  void _confirmUnlink(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy liên kết?'),
        content: Text(
          'Bạn có chắc muốn hủy liên kết với ${parent.fullName ?? parent.username}? '
          'Phụ huynh sẽ không thể theo dõi tiến độ học tập của bạn nữa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true || !context.mounted) return;

      final success = await context.read<FamilyLinkCubit>().unlinkParent(parent.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã hủy liên kết' : 'Không thể hủy liên kết'),
          backgroundColor: success ? Colors.green : null,
        ),
      );
    });
  }
}
