import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/discussion/discussion_cubit.dart';
import 'package:study/features/student/bloc/discussion/discussion_state.dart';
import 'package:study/features/student/data/models/models.dart';
import 'package:study/features/student/data/repository/student_repository.dart';
import 'package:study/index.dart';

class CreateDiscussionScreen extends StatelessWidget {
  const CreateDiscussionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateDiscussionCubit(
        repository: context.read<StudentRepository>(),
      ),
      child: const _CreateDiscussionContent(),
    );
  }
}

class _CreateDiscussionContent extends StatefulWidget {
  const _CreateDiscussionContent();

  @override
  State<_CreateDiscussionContent> createState() =>
      _CreateDiscussionContentState();
}

class _CreateDiscussionContentState extends State<_CreateDiscussionContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DiscussionCategory _selectedCategory = DiscussionCategory.programming;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<CreateDiscussionCubit>().create(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
        );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<CreateDiscussionCubit, CreateDiscussionState>(
      listener: (context, state) {
        if (state is CreateDiscussionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dang bai thanh cong!')),
          );
          Navigator.of(context).pop(state.discussion);
        } else if (state is CreateDiscussionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dang bai moi'),
          actions: [
            BlocBuilder<CreateDiscussionCubit, CreateDiscussionState>(
              builder: (context, state) {
                final isSubmitting = state is CreateDiscussionSubmitting;
                return TextButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Dang'),
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category selector
                _CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tieu de',
                    hintText: 'Nhap tieu de bai viet...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLength: 200,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui long nhap tieu de';
                    }
                    if (value.trim().length < 10) {
                      return 'Tieu de phai co it nhat 10 ky tu';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // Content field
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Noi dung',
                    hintText: 'Viet noi dung bai viet...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 10,
                  minLines: 5,
                  maxLength: 5000,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui long nhap noi dung';
                    }
                    if (value.trim().length < 20) {
                      return 'Noi dung phai co it nhat 20 ky tu';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Guidelines
                Card(
                  color: cs.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: cs.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Huong dan dang bai',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _GuidelineItem(
                          text: 'Dat tieu de ro rang, cu the',
                        ),
                        _GuidelineItem(
                          text: 'Chon danh muc phu hop voi noi dung',
                        ),
                        _GuidelineItem(
                          text: 'Mo ta chi tiet van de hoac y kien',
                        ),
                        _GuidelineItem(
                          text: 'Su dung ngon ngu lich su, ton trong',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final DiscussionCategory selectedCategory;
  final ValueChanged<DiscussionCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh muc',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: DiscussionCategory.values
              .where((c) => c != DiscussionCategory.other)
              .map((category) {
            final isSelected = selectedCategory == category;
            return ChoiceChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(category),
              selectedColor: cs.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? cs.primary : cs.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  const _GuidelineItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: cs.outline),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
