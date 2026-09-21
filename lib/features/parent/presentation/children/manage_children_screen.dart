import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/data/models/models.dart';
import 'package:study/features/auth/repository/auth_repository.dart';
import 'package:study/features/parent/bloc/manage_children/manage_children_cubit.dart';
import 'package:study/features/parent/bloc/manage_children/manage_children_state.dart';
import 'package:study/features/parent/presentation/children/add_child_screen.dart';
import 'package:study/features/parent/presentation/children/child_detail_screen.dart';
import 'package:study/features/parent/presentation/children/widgets/widgets.dart';
import 'package:study/theme/theme.dart';

class ManageChildrenScreen extends StatelessWidget {
  const ManageChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManageChildrenCubit(context.read<AuthRepository>())
        ..loadChildren(),
      child: const _ManageChildrenContent(),
    );
  }
}

class _ManageChildrenContent extends StatelessWidget {
  const _ManageChildrenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý con'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _navigateToAddChild(context),
            tooltip: 'Liên kết hồ sơ con',
          ),
          AppSpacing.hGap8,
        ],
      ),
      body: BlocBuilder<ManageChildrenCubit, ManageChildrenState>(
        builder: (context, state) {
          return switch (state) {
            ManageChildrenInitial() ||
            ManageChildrenLoading() => const ChildrenLoading(),
            ManageChildrenSuccess(:final children) => children.isEmpty
                ? ChildrenEmptyState(
                    onAddChild: () => _navigateToAddChild(context),
                  )
                : _ChildrenList(
                    children: children,
                    onChildTap: (child) => _navigateToChildDetail(context, child),
                    onAddChild: () => _navigateToAddChild(context),
                  ),
            ManageChildrenFailure(:final message) => ChildrenError(
                message: message,
                onRetry: () => context.read<ManageChildrenCubit>().refresh(),
              ),
          };
        },
      ),
    );
  }

  void _navigateToAddChild(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddChildScreen()),
    ).then((_) {
      context.read<ManageChildrenCubit>().refresh();
    });
  }

  void _navigateToChildDetail(BuildContext context, UserModel child) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChildDetailScreen(child: child)),
    );
  }
}

class _ChildrenList extends StatelessWidget {
  const _ChildrenList({
    required this.children,
    required this.onChildTap,
    required this.onAddChild,
  });

  final List<UserModel> children;
  final ValueChanged<UserModel> onChildTap;
  final VoidCallback onAddChild;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ManageChildrenCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: children.length + 1,
        itemBuilder: (context, index) {
          if (index == children.length) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: AddChildButton(onTap: onAddChild),
            );
          }
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < children.length - 1 ? AppSpacing.md : 0,
            ),
            child: ChildCard(
              child: children[index],
              onTap: () => onChildTap(children[index]),
            ),
          );
        },
      ),
    );
  }
}
