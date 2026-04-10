import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/parent/bloc/children/children_selector_cubit.dart';
import 'package:study/features/parent/bloc/children/children_selector_state.dart';
import 'package:study/features/parent/data/models/models.dart';
import 'package:study/features/parent/presentation/screens/child_detail_screen.dart';
import 'package:study/theme/app_colors.dart';

class StudentSelectorDropdown extends StatelessWidget {
  const StudentSelectorDropdown({
    super.key,
    this.navigateToProfileOnTap = true,
  });

  final bool navigateToProfileOnTap;

  void _navigateToChildProfile(BuildContext context, ChildModel child) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChildDetailScreen(child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ChildrenSelectorCubit, ChildrenSelectorState>(
      builder: (context, state) {
        if (state is! ChildrenSelectorLoaded) {
          return const SizedBox.shrink();
        }

        final children = state.children;
        final selectedChild = state.selectedChild;

        if (children.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              // Avatar - tap to go to profile
              GestureDetector(
                onTap: navigateToProfileOnTap && selectedChild != null
                    ? () => _navigateToChildProfile(context, selectedChild)
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: selectedChild?.avatarUrl != null
                        ? NetworkImage(selectedChild!.avatarUrl!)
                        : null,
                    child: selectedChild?.avatarUrl == null
                        ? Icon(Icons.person, size: 20, color: cs.primary)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Name - tap to go to profile
              Expanded(
                child: GestureDetector(
                  onTap: navigateToProfileOnTap && selectedChild != null
                      ? () => _navigateToChildProfile(context, selectedChild)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            selectedChild?.name ?? 'Chon hoc sinh',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (navigateToProfileOnTap) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.open_in_new,
                              size: 14,
                              color: cs.primary,
                            ),
                          ],
                        ],
                      ),
                      if (selectedChild != null)
                        Text(
                          '${selectedChild.displayGrade} • ${selectedChild.classCount} lop',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Dropdown button
              if (children.length > 1)
                PopupMenuButton<ChildModel>(
                  onSelected: (child) {
                    context.read<ChildrenSelectorCubit>().selectChild(child);
                  },
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      size: 20,
                      color: cs.primary,
                    ),
                  ),
                  itemBuilder: (context) => children
                      .where((c) => c.id != selectedChild?.id)
                      .map((child) => PopupMenuItem<ChildModel>(
                            value: child,
                            child: _ChildMenuItem(child: child),
                          ))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ChildMenuItem extends StatelessWidget {
  const _ChildMenuItem({required this.child});

  final ChildModel child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: cs.primaryContainer,
          backgroundImage:
              child.avatarUrl != null ? NetworkImage(child.avatarUrl!) : null,
          child: child.avatarUrl == null
              ? Icon(Icons.person, size: 16, color: cs.primary)
              : null,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                child.name,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                child.displayGrade,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StudentSelectorChips extends StatelessWidget {
  const StudentSelectorChips({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ChildrenSelectorCubit, ChildrenSelectorState>(
      builder: (context, state) {
        if (state is! ChildrenSelectorLoaded) {
          return const SizedBox.shrink();
        }

        final children = state.children;
        final selectedChild = state.selectedChild;

        if (children.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final child = children[index];
              final isSelected = selectedChild?.id == child.id;

              return GestureDetector(
                onTap: () {
                  context.read<ChildrenSelectorCubit>().selectChild(child);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: isSelected
                            ? cs.onPrimary.withValues(alpha: 0.2)
                            : cs.primaryContainer,
                        backgroundImage: child.avatarUrl != null
                            ? NetworkImage(child.avatarUrl!)
                            : null,
                        child: child.avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 12,
                                color: isSelected ? cs.onPrimary : cs.primary,
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        child.name,
                        style: textTheme.labelLarge?.copyWith(
                          color: isSelected ? cs.onPrimary : cs.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
