import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_cubit.dart';
import 'package:study/features/parent/bloc/child_selector/child_selector_state.dart';
import 'package:study/theme/theme.dart';

class ChildSwitcher extends StatelessWidget {
  const ChildSwitcher({super.key, this.showAll = false});

  final bool showAll;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildSelectorCubit, ChildSelectorState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              if (showAll)
                _ChildChip(
                  label: 'Tất cả',
                  isSelected: state.selectedChild == null,
                  onTap: () {},
                ),
              ...state.children.map((child) => _ChildChip(
                    label: child.fullName,
                    avatarUrl: child.avatarUrl,
                    isSelected: state.selectedChild?.id == child.id,
                    onTap: () {
                      context.read<ChildSelectorCubit>().select(child);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.avatarUrl,
  });

  final String label;
  final String? avatarUrl;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: isSelected ? cs.primaryContainer : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatarUrl != null) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(avatarUrl!),
                  ),
                  AppSpacing.hGap8,
                ],
                Text(
                  label,
                  style: tt.labelMedium?.copyWith(
                    color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  AppSpacing.hGap4,
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: cs.onPrimaryContainer,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
